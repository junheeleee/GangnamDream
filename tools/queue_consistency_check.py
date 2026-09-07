#!/usr/bin/env python3
"""실행 큐와 작은 활성 사양이 같은 상태·순서를 말하는지 검사한다."""

from __future__ import annotations

import re
import sys
from pathlib import Path

from queue_index import QueueIndexError, read_queue_index

ROOT = Path(__file__).resolve().parents[1]

HEADER_RE = re.compile(r"^####\s+\[([ ~x])\]\s+(ORDER-\d+)\b", re.MULTILINE)
BATCH_RE = re.compile(r"^##\s+배치(?:\s|$)", re.MULTILINE)


def main(root: Path = ROOT) -> int:
    errors: list[str] = []
    try:
        index = read_queue_index(root)
    except QueueIndexError as exc:
        print(f"QUEUE_CONSISTENCY_FAIL — {exc}")
        return 1
    rows = [(row.seq, row.state, row.order_id, row.spec_stem) for row in index]
    row_ids = [row[2] for row in rows]
    if len(row_ids) != len(set(row_ids)):
        errors.append(f"실행 큐에 중복 ID가 있다: {row_ids}")

    active_files = {path.stem: path for path in sorted((root / "docs/queue_active").glob("*.md"))}
    if set(row_ids) != set(active_files):
        missing_rows = sorted(set(active_files) - set(row_ids))
        missing_specs = sorted(set(row_ids) - set(active_files))
        if missing_rows:
            errors.append(f"queue_active에만 있고 실행 표에 없는 사양: {missing_rows}")
        if missing_specs:
            errors.append(f"실행 표에만 있고 queue_active에 없는 사양: {missing_specs}")

    for _seq, state, order_id, linked_stem in rows:
        if linked_stem != order_id:
            errors.append(f"{order_id}: 링크 파일명이 {linked_stem}이다")
            continue
        path = active_files.get(order_id)
        if path is None:
            continue
        body = path.read_text(encoding="utf-8")
        header = HEADER_RE.search(body)
        if not header:
            errors.append(f"{order_id}: 상태 머리말이 없다")
        else:
            spec_state, spec_id = header.groups()
            if spec_id != order_id:
                errors.append(f"{order_id}: 사양 머리말 ID가 {spec_id}다")
            if spec_state != state:
                errors.append(
                    f"{order_id}: 큐 상태 [{state}]와 사양 상태 [{spec_state}]가 다르다")
        batches = len(BATCH_RE.findall(body))
        if batches > 2:
            errors.append(
                f"{order_id}: 활성 사양이 {batches}배치다 — 부모 계획으로 내리고 1~2배치로 나눈다")

    claude_path, handoff_path = root / "CLAUDE.md", root / "docs/HANDOFF.md"
    claude = claude_path.read_text(encoding="utf-8") if claude_path.is_file() else ""
    handoff = handoff_path.read_text(encoding="utf-8") if handoff_path.is_file() else ""
    if "실행 우선순위·상태의 단일 정본" not in claude:
        errors.append("CLAUDE.md가 CODEX_QUEUE의 우선순위·상태 단일 소유권을 말하지 않는다")
    if "실행 순서·상태는" not in handoff or "CODEX_QUEUE.md" not in handoff:
        errors.append("HANDOFF.md가 실행 순서를 복제하지 않고 CODEX_QUEUE를 가리켜야 한다")

    if errors:
        print("QUEUE_CONSISTENCY_FAIL")
        for error in errors:
            print(f"  ERROR: {error}")
        return 1

    print(
        f"QUEUE_CONSISTENCY_OK active={len(rows)} "
        f"in_progress={sum(1 for row in rows if row[1] == '~')} max_batches=2")
    return 0


if __name__ == "__main__":
    sys.exit(main())
