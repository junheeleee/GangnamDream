#!/usr/bin/env python3
"""변경 파일에 필요한 감사만 골라 실행한다.

전체 `tools/audit.sh`는 순차 10분이다. 작은 단위를 많이 통과시키는
`docs/WORK_UNIT.md` 규격에서는 단위마다 10분을 낼 수 없으므로, 변경 파일에
실제로 영향받는 검사만 고른다.

  python3 tools/audit_select.py                 # 워킹 트리 변경 기준으로 실행
  python3 tools/audit_select.py --base main     # main 대비 변경 기준
  python3 tools/audit_select.py --list          # 실행하지 않고 목록만
  python3 tools/audit_select.py --verify        # audit.sh 검사가 전부 등록됐는지
  python3 tools/audit_select.py -- a.json b.gd  # 파일을 직접 지정

안전 기본값: 어떤 규칙에도 매칭되지 않는 변경이 있으면 전체 감사를 요구한다.
표적 감사는 전체 감사를 대체하지 않는다 — 배치 마감과 CI는 계속 audit.sh를 돈다.
"""

from __future__ import annotations

import argparse
import fnmatch
import json
import os
import re
import shlex
import shutil
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SCOPE = ROOT / "tools" / "audit_scope.json"
AUDIT_SH = ROOT / "tools" / "audit.sh"


def load_scope() -> dict:
    with SCOPE.open(encoding="utf-8") as handle:
        return json.load(handle)


def changed_files(base: str | None) -> list[str]:
    if base:
        cmd = ["git", "diff", "--name-only", f"{base}...HEAD"]
    else:
        cmd = ["git", "status", "--porcelain"]
    out = subprocess.run(cmd, cwd=ROOT, capture_output=True, text=True, check=False)
    if out.returncode != 0:
        return []
    files: list[str] = []
    for line in out.stdout.splitlines():
        line = line.rstrip()
        if not line:
            continue
        files.append(line[3:].strip() if not base else line.strip())
    return [f for f in files if f]


def matches(path: str, patterns: list[str]) -> bool:
    for pattern in patterns:
        if fnmatch.fnmatch(path, pattern):
            return True
        # "content/**" 는 content/ 아래 전부를 뜻한다.
        if pattern.endswith("/**") and path.startswith(pattern[:-2]):
            return True
        if pattern.startswith("**/") and fnmatch.fnmatch(Path(path).name, pattern[3:]):
            return True
    return False


def select(files: list[str], scope: dict) -> tuple[list[dict], list[str]]:
    checks = scope["checks"]
    selected: list[dict] = []
    unmatched: list[str] = []
    for path in files:
        hit = False
        for check in checks:
            if matches(path, check["paths"]):
                hit = True
                if check not in selected:
                    selected.append(check)
        if not hit:
            unmatched.append(path)
    for always in scope.get("always", []):
        if not any(c["tool"] == always for c in selected):
            found = next((c for c in checks if c["tool"] == always), None)
            if found:
                selected.append(found)
    return selected, unmatched


def registered_tools(scope: dict) -> set[str]:
    # run_check는 `tool`에 인자를 붙여 쓸 수 있게 돼 있다(`X.py --flag`).
    # 대조는 audit.sh가 부르는 파일 이름과 하는 것이므로 첫 토큰만 본다.
    # 이 구분이 없으면 인자를 단 등록이 MISSING으로 잘못 잡힌다.
    tools = {c["tool"].split()[0] for c in scope["checks"]}
    tools |= {t.split()[0] for t in scope.get("always", [])}
    return tools


def audit_sh_tools() -> set[str]:
    text = AUDIT_SH.read_text(encoding="utf-8")
    found = set(re.findall(r"python3 (tools/[\w_]+\.py)", text))
    found |= set(re.findall(r"res://(tools/[\w]+\.tscn)", text))
    return found


def run_check(check: dict, godot: str | None) -> int:
    tool = check["tool"]
    parts = shlex.split(tool)
    tool_path = parts[0]
    tool_args = parts[1:]
    if check.get("godot") and not godot:
        print(f"  ⚠ {tool} — Godot 없음, 건너뜀")
        return 0
    if tool_path.endswith(".tscn"):
        if not godot:
            print(f"  ⚠ {tool} — Godot 없음, 건너뜀")
            return 0
        cmd = [godot, "--headless", "--quit-after", "3600", f"res://{tool_path}"]
        scene_args = check.get("args", [])
        if scene_args:
            cmd.extend(["--", *scene_args])
    elif tool_path.endswith(".py"):
        cmd = ["python3", tool_path, *tool_args]
    elif tool_path.endswith(".sh"):
        cmd = [tool_path, *tool_args]
    else:
        cmd = [tool_path, *tool_args]
    arg_label = ""
    if tool_path.endswith(".tscn") and check.get("args"):
        arg_label = " -- " + " ".join(check["args"])
    print(f"● {tool}{arg_label}")
    child_env = os.environ.copy()
    if godot:
        child_env["GODOT"] = godot
    proc = subprocess.run(
        cmd, cwd=ROOT, capture_output=True, text=True,
        check=False, env=child_env)
    tail = (proc.stdout or proc.stderr).strip().splitlines()
    for line in tail[-3:]:
        print(f"    {line}")
    if proc.returncode != 0:
        print(f"  ✗ {tool} 실패 (exit {proc.returncode})")
    return proc.returncode


def main() -> int:
    parser = argparse.ArgumentParser(add_help=True)
    parser.add_argument("--base", help="이 ref 대비 변경을 본다 (예: main)")
    parser.add_argument("--list", action="store_true", help="실행하지 않고 목록만")
    parser.add_argument("--verify", action="store_true",
                        help="audit.sh의 검사가 전부 등록됐는지 확인")
    parser.add_argument("files", nargs="*", help="파일을 직접 지정")
    args = parser.parse_args()

    scope = load_scope()

    if args.verify:
        missing = sorted(audit_sh_tools() - registered_tools(scope))
        stale = sorted(registered_tools(scope) - audit_sh_tools())
        for tool in missing:
            print(f"MISSING {tool} — audit.sh에 있으나 audit_scope.json에 없음")
        for tool in stale:
            if (ROOT / tool).exists():
                print(f"EXTRA   {tool} — scope에 있으나 audit.sh가 부르지 않음")
        if missing:
            print(f"AUDIT_SCOPE_VERIFY_FAIL missing={len(missing)}")
            return 1
        print(f"AUDIT_SCOPE_VERIFY_OK registered={len(registered_tools(scope))}")
        return 0

    files = args.files or changed_files(args.base)
    if not files:
        print("변경 없음 — 실행할 검사 없음")
        return 0

    selected, unmatched = select(files, scope)

    print(f"변경 파일 {len(files)}개 → 검사 {len(selected)}개")
    if unmatched:
        print()
        print("⚠ 매칭 규칙이 없는 변경:")
        for path in unmatched:
            print(f"    {path}")
        print("  → 안전을 위해 전체 감사가 필요하다: ./tools/audit.sh")
        print("  → 이 경로가 앞으로도 쓰인다면 tools/audit_scope.json에 규칙을 추가한다.")
        if not args.list:
            return 2

    for check in selected:
        print(f"  · {check['tool']}  — {check['why']}")
    if args.list:
        return 0

    godot = os.environ.get("GODOT") or shutil.which("godot")
    if not godot and any(c.get("godot", False) for c in selected):
        print("\n⚠ Godot 없음 — 런타임 검사는 건너뛴다. 배치 마감 전 CI에서 확인할 것.")

    print()
    failed = [c["tool"] for c in selected if run_check(c, godot) != 0]

    print()
    if failed:
        print("❌ 표적 감사 실패:")
        for tool in failed:
            print(f"   - {tool}")
        return 1
    print(f"✅ 표적 감사 통과 ({len(selected)}개)")
    print("   전체 감사를 대체하지 않는다 — 배치 마감과 CI는 ./tools/audit.sh를 돈다.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
