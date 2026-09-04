#!/usr/bin/env python3
"""실행 큐와 작은 활성 사양이 같은 상태·순서를 말하는지 검사한다."""

from __future__ import annotations

import re
import sys
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
QUEUE = ROOT / "docs/CODEX_QUEUE.md"
ACTIVE = ROOT / "docs/queue_active"
ARCHIVE = ROOT / "docs/queue_archive"
BACKLOG = ROOT / "docs/queue_backlog"
CLAUDE = ROOT / "CLAUDE.md"
HANDOFF = ROOT / "docs/HANDOFF.md"

ROW_RE = re.compile(
    r"^\|\s*(\d+)\s*\|\s*\[([ ~x])\]\s*\|\s*"
    r"(ORDER-\d+)\s*·[^|]*\|\s*\[[^]]+\]\((queue_active/([^)]+)\.md)\)\s*\|"
)
HEADER_RE = re.compile(r"^####\s+\[([ ~x])\]\s+(ORDER-\d+)\b", re.MULTILINE)
BATCH_RE = re.compile(r"^##\s+배치(?:\s|$)", re.MULTILINE)
# An order spec is exactly ORDER-<n>.md. Evidence attachments such as
# ORDER-100_L1_L2_2026-08-12.md share the number on purpose and are not reuse.
SPEC_FILE_RE = re.compile(r"^ORDER-(\d+)\.md$")


def order_ids(directory: Path) -> dict[str, Path]:
    """Order IDs whose spec file lives in this directory."""
    found: dict[str, Path] = {}
    if not directory.is_dir():
        return found
    for path in sorted(directory.glob("ORDER-*.md")):
        match = SPEC_FILE_RE.match(path.name)
        if match:
            found[f"ORDER-{match.group(1)}"] = path
    return found


def check_id_reuse(errors: list[str]) -> None:
    """An ID may name only one order across the whole queue.

    The row check below only sees the index table, so an active spec that
    reuses a number already spent in the archive passes it unnoticed. That
    happened to ORDER-148 and cost a rename after the fact.
    """
    seen: dict[str, list[str]] = {}
    for label, directory in (
        ("queue_active", ACTIVE),
        ("queue_archive", ARCHIVE),
        ("queue_backlog", BACKLOG),
    ):
        for order_id in order_ids(directory):
            seen.setdefault(order_id, []).append(label)
    for order_id, places in sorted(seen.items()):
        if len(places) > 1:
            errors.append(
                f"같은 오더 ID가 여러 큐 디렉터리에 있다: {order_id} → "
                f"{', '.join(places)}. 새 오더는 아카이브·백로그에서 쓰지 않은 "
                f"번호를 써야 한다")


def execution_section(text: str) -> str:
    marker = "### 실행 오더 인덱스"
    start = text.find(marker)
    if start < 0:
        return ""
    end = text.find("\n### ", start + len(marker))
    return text[start:] if end < 0 else text[start:end]


def main() -> int:
    errors: list[str] = []
    if not QUEUE.is_file():
        print("QUEUE_CONSISTENCY_FAIL — docs/CODEX_QUEUE.md 없음")
        return 1

    section = execution_section(QUEUE.read_text(encoding="utf-8"))
    if not section:
        errors.append("CODEX_QUEUE에 '실행 오더 인덱스' 절이 없다")

    rows: list[tuple[int, str, str, str]] = []
    for line in section.splitlines():
        match = ROW_RE.match(line)
        if match:
            rows.append((int(match.group(1)), match.group(2), match.group(3), match.group(5)))

    if not rows:
        errors.append("실행 오더 행을 읽지 못했다")
    sequences = [row[0] for row in rows]
    if sequences != list(range(1, len(rows) + 1)):
        errors.append(f"실행 순서가 1부터 연속이 아니다: {sequences}")

    row_ids = [row[2] for row in rows]
    if len(row_ids) != len(set(row_ids)):
        errors.append(f"실행 큐에 중복 ID가 있다: {row_ids}")

    check_id_reuse(errors)

    active_files = {path.stem: path for path in sorted(ACTIVE.glob("*.md"))}
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

    claude = CLAUDE.read_text(encoding="utf-8") if CLAUDE.is_file() else ""
    handoff = HANDOFF.read_text(encoding="utf-8") if HANDOFF.is_file() else ""
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
