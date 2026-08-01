#!/usr/bin/env python3
"""자동으로 잴 수 없는 판정을 출력하고, 원장이 실제와 어긋나면 실패한다.

`identity_signature_audit`만 하던 일을 모든 도메인으로 넓힌 것이다. 못 재는 것을
조용히 넘어가면 초록불이 "다 됐다"로 읽힌다. **이 도구는 아무것도 통과시키지
않는다** — 남은 사람 판정을 매번 화면에 올려 초록불의 뜻을 좁히는 것이 전부다.

    python3 tools/human_gates.py            # 열린 게이트 전부 + 원장 검사
    python3 tools/human_gates.py --domain audio

검사 도구에서 자기 도메인 몫만 찍으려면:

    from human_gates import print_pending
    print_pending("audio")
"""

from __future__ import annotations

import argparse
import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
LEDGER = ROOT / "docs/human_gates.json"
QUEUE = ROOT / "docs/CODEX_QUEUE.md"


def load() -> list[dict]:
    if not LEDGER.is_file():
        return []
    try:
        return json.loads(LEDGER.read_text(encoding="utf-8")).get("gates", [])
    except (OSError, json.JSONDecodeError):
        return []


def open_gates(domain: str | None = None) -> list[dict]:
    return [g for g in load()
            if g.get("state") == "open" and (domain is None or g.get("domain") == domain)]


def print_pending(domain: str, indent: str = "  ") -> None:
    """검사 도구가 자기 도메인 몫을 찍는다. 아무것도 반환하지 않고 판정도 안 한다."""
    gates = open_gates(domain)
    if not gates:
        return
    print(f"\n{indent}사람 판정 대기 — 자동으로 잴 수 없다. 통과 처리하지 않는다.")
    for g in gates:
        print(f"{indent}  · {g['gate']}  [{g['owner']}]")


def known_orders() -> set[str]:
    """큐 표에 실재하는 오더 ID. 원장이 사라진 오더를 가리키는 것을 막는다."""
    if not QUEUE.is_file():
        return set()
    return set(re.findall(r"\|\s*((?:ORDER|USER)-[\w]+)\s*·",
                          QUEUE.read_text(encoding="utf-8")))


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--domain")
    args = ap.parse_args()

    gates = load()
    if not gates:
        print("HUMAN_GATES_FAIL — docs/human_gates.json 을 읽을 수 없다")
        return 1

    errors: list[str] = []
    seen: set[str] = set()
    orders = known_orders()
    for g in gates:
        gid = g.get("id", "")
        for field in ("id", "domain", "gate", "why", "owner", "state"):
            if not g.get(field):
                errors.append(f"{gid or '<id 없음>'}: {field} 가 비어 있다")
        if gid in seen:
            errors.append(f"{gid}: 중복된 id")
        seen.add(gid)
        if g.get("state") not in {"open", "done"}:
            errors.append(f"{gid}: state 는 open 또는 done 이어야 한다")
        if g.get("state") == "done" and not g.get("evidence"):
            errors.append(f"{gid}: done 이면 누가 언제 무엇으로 통과시켰는지 evidence 가 있어야 한다")
        owner = g.get("owner", "")
        if orders and owner and owner not in orders:
            errors.append(
                f"{gid}: owner {owner} 가 큐 표에 없다 — 오더가 끝났으면 게이트도 정리한다")

    if errors:
        print("HUMAN_GATES_FAIL")
        for e in errors:
            print(f"  ERROR: {e}")
        return 1

    rows = open_gates(args.domain)
    scope = f"domain={args.domain} " if args.domain else ""
    print(f"● 사람 판정 대기 {scope}— 자동 검사가 대신할 수 없다. 통과 처리하지 않는다.")
    if not rows:
        print("    (열린 게이트 없음)")
    for domain in sorted({g["domain"] for g in rows}):
        print(f"\n  [{domain}]")
        for g in [r for r in rows if r["domain"] == domain]:
            print(f"    · {g['gate']}  [{g['owner']}]")
            print(f"      왜 사람이어야 하나 — {g['why']}")

    done = sum(1 for g in gates if g.get("state") == "done")
    print(f"\nHUMAN_GATES_OK open={len(open_gates())} done={done} total={len(gates)}")
    print("  이 도구는 아무것도 통과시키지 않는다. 초록불은 계약을 지켰다는 뜻이지")
    print("  좋다는 뜻이 아니다.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
