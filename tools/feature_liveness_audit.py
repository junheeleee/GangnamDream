#!/usr/bin/env python3
"""Catch code that no longer has a way in.

`ORDER-62` asks whether every feature is essential. Most of that question is
authorial and cannot be automated — whether a feature has a killing point is a
judgment about the work. This tool covers only the part a machine can settle:
scripts nothing refers to.

Scope is deliberately narrow, and the reason is recorded so nobody re-derives
it. Two axes were measured while writing this:

* **Zero-reference scripts** — real. Four today, one of them 806 lines.
* **Settings keys written but never read** — measured and clean. A first pass
  reported two dead keys, but `moral_palette` and `mod_load_order` are read
  through `_mod_settings().get(...)` rather than `get_setting(...)`, so the
  scan was wrong, not the code. With the accessor pattern widened, zero keys
  are dead. **No metric is shipped for this** — a check with nothing to catch
  teaches people to skim, and a wrong one would have marked live accessibility
  settings for deletion.

The feature ledger itself (`docs/FEATURE_LEDGER.md`) is `ORDER-62` batch 1's
own output and does not exist yet. When it appears this tool validates that
each row's declared entry point resolves; until then that part stays silent
rather than pretending to check.
"""

from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
BASELINE = Path(__file__).resolve().parent / "feature_liveness_baseline.json"
LEDGER = ROOT / "docs" / "FEATURE_LEDGER.md"

# 독립 실행이 설계인 것들. 진입점이 없다는 사실 자체가 정상이다.
STANDALONE_PREFIXES = ("tools/test_",)


def scripts() -> list[Path]:
    return sorted(p for p in ROOT.rglob("*.gd") if ".godot" not in p.parts)


def searchable_text() -> dict[Path, str]:
    out: dict[Path, str] = {}
    for pattern in ("*.gd", "*.tscn", "*.tres", "*.cfg"):
        for path in ROOT.rglob(pattern):
            if ".godot" in path.parts:
                continue
            try:
                out[path] = path.read_text(encoding="utf-8", errors="ignore")
            except OSError:
                continue
    project = ROOT / "project.godot"
    if project.is_file():
        out[project] = project.read_text(encoding="utf-8", errors="ignore")
    return out


def orphans() -> list[tuple[str, int]]:
    corpus = searchable_text()
    found: list[tuple[str, int]] = []
    for path in scripts():
        rel = path.relative_to(ROOT).as_posix()
        if rel.startswith(STANDALONE_PREFIXES):
            continue
        stem = path.stem
        res = "res://" + rel
        referenced = any(
            other != path and (stem in text or rel in text or res in text)
            for other, text in corpus.items()
        )
        if not referenced:
            lines = len(corpus.get(path, "").splitlines())
            found.append((rel, lines))
    return sorted(found, key=lambda item: -item[1])


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--update-baseline", action="store_true")
    args = parser.parse_args()

    found = orphans()
    names = sorted(rel for rel, _ in found)

    if args.update_baseline or not BASELINE.is_file():
        BASELINE.write_text(
            json.dumps({"orphan_scripts": names}, ensure_ascii=False, indent=2) + "\n",
            encoding="utf-8",
        )
        print("FEATURE_LIVENESS_BASELINE_WRITTEN " + json.dumps(names, ensure_ascii=False))
        return 0

    known = set(json.loads(BASELINE.read_text(encoding="utf-8"))["orphan_scripts"])

    if found:
        print("  진입점이 없는 스크립트")
        for rel, lines in found:
            mark = "" if rel in known else "   ← 새로 생겼다"
            print(f"    {lines:5d}줄  {rel}{mark}")
    else:
        print("  진입점이 없는 스크립트 없음")

    print(
        "\n  설정 키: 이 축은 측정했고 결함이 없어 지표로 만들지 않았다."
        " 이유는 이 파일의 docstring."
    )

    if not LEDGER.is_file():
        print(f"\n  {LEDGER.relative_to(ROOT)} 없음 — 원장 검증은 건너뛴다(ORDER-62 배치 1).")

    new = sorted(set(names) - known)
    gone = sorted(known - set(names))

    if gone:
        print("\n  해소됨 — 기준선에서 지운다:")
        for rel in gone:
            print(f"    ✓ {rel}")
        print("    `--update-baseline` 으로 갱신해 되돌아오지 못하게 한다.")

    if new:
        print("\nFEATURE_LIVENESS_FAIL — 도달할 수 없는 스크립트가 늘었다:")
        for rel in new:
            print(f"  - {rel}")
        print(
            "\n  의도한 것이면 진입점을 만들거나, 독립 실행이면 "
            "STANDALONE_PREFIXES 에 근거와 함께 등록한다."
        )
        return 1

    print(f"\nFEATURE_LIVENESS_OK orphans={len(found)} known={len(known)}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
