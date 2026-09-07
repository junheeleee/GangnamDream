#!/usr/bin/env python3
"""Read the single execution index, with one fixed active L3 continuation.

This is not a Markdown include engine. Rows are never sorted or assigned a new
state; the primary document owns the one insertion point and reading contract.
"""

from __future__ import annotations

import re
from dataclasses import dataclass
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
PRIMARY = "docs/CODEX_QUEUE.md"
CONTINUATION = "docs/CODEX_QUEUE_L3_PENDING.md"
SECTION = "### 실행 오더 인덱스"
INCLUDE = "[활성 L3 검수 대기 행 이어보기](CODEX_QUEUE_L3_PENDING.md) <!-- queue-index-include -->"
TABLE_HEADER = "| 순서 | 상태 | 항목 | 실행 사양 | 현재 게이트 |"
TABLE_RULE = "|---:|:---:|---|---|---|"
ROW_RE = re.compile(
    r"^\|\s*(\d+)\s*\|\s*\[([ ~x])\]\s*\|\s*"
    r"(ORDER-\d+)\s*·\s*([^|]+?)\s*\|\s*"
    r"\[[^\]\n]+\]\(queue_active/(ORDER-\d+)\.md\)\s*\|\s*([^|]+?)\s*\|\s*$"
)


class QueueIndexError(ValueError):
    pass


@dataclass(frozen=True)
class QueueRow:
    seq: int
    state: str
    order_id: str
    title: str
    spec_stem: str
    gate: str
    raw: str


def execution_section(text: str) -> str:
    """Only the named heading owns executable rows, not prose or examples."""
    headings = list(re.finditer(r"^" + re.escape(SECTION) + r"$", text, re.MULTILINE))
    if len(headings) != 1:
        raise QueueIndexError("execution index heading must occur exactly once")
    start = headings[0].end()
    following = re.search(r"^#{1,3} ", text[start:], re.MULTILINE)
    end = start + following.start() if following else len(text)
    return text[start:end]


def _read(root: Path, relative: str) -> str:
    path = root / relative
    if path.is_symlink() or path.parent.is_symlink():
        raise QueueIndexError(f"queue index symlink is forbidden: {relative}")
    if not path.is_file() or path.resolve().parent != (root / "docs").resolve():
        raise QueueIndexError(f"missing or unsafe queue index: {relative}")
    try:
        return path.read_text(encoding="utf-8")
    except (OSError, UnicodeError) as exc:
        raise QueueIndexError(f"cannot read queue index: {relative}: {exc}") from exc


def _reject_fenced_index(text: str) -> None:
    # Track from the document start: a fence may open before the index heading.
    # A different marker or shorter run cannot close it. No Markdown rendering
    # is needed; only prevent executable-looking content being read as prose.
    fence: tuple[str, int] | None = None
    for line in text.splitlines():
        marker = re.match(r"^ {0,3}(`{3,}|~{3,})(.*)$", line)
        if marker:
            run, tail = marker.groups()
            if fence is None:
                fence = (run[0], len(run))
            elif run[0] == fence[0] and len(run) >= fence[1] and not tail.strip():
                fence = None
            continue
        if fence and (line == SECTION or ROW_RE.fullmatch(line) or "queue-index-include" in line):
            raise QueueIndexError("queue index content inside code fence")


def _lines(text: str, continuation: bool) -> list[QueueRow | None]:
    _reject_fenced_index(text)
    section = execution_section(text)
    # A lookalike outside the index must not be borrowed to hide a missing row.
    outside = text.replace(section, "", 1)
    if "queue-index-include" in outside or any(ROW_RE.fullmatch(line) for line in outside.splitlines()):
        raise QueueIndexError("queue row/include outside execution index")
    rows: list[QueueRow | None] = []
    for line in section.splitlines(keepends=True):
        stripped = line.strip()
        if "queue-index-include" in line:
            if continuation or stripped != INCLUDE:
                raise QueueIndexError("unknown, nested, or unsafe queue include")
            rows.append(None)
            continue
        match = ROW_RE.fullmatch(line.rstrip("\r\n"))
        if match:
            seq, state, order_id, title, spec_stem, gate = match.groups()
            if order_id != spec_stem:
                raise QueueIndexError(f"queue link ID mismatch: {order_id} -> {spec_stem}")
            if continuation and (state != "~" or not re.search(r"(?:^|·)\s*L3 OPEN$", gate)
                                 or len(re.findall(r"\bL3\b", gate)) != 1):
                raise QueueIndexError("continuation rows must remain [~] with L3 OPEN")
            rows.append(QueueRow(int(seq), state, order_id, title, spec_stem, gate, line))
        elif stripped not in ("", TABLE_HEADER, TABLE_RULE):
            if continuation or stripped.startswith("|") or "queue_active/ORDER-" in line:
                raise QueueIndexError(f"malformed queue row: {stripped}")
    return rows


def read_queue_index(root: Path = ROOT) -> list[QueueRow]:
    root = root.resolve()
    primary = _lines(_read(root, PRIMARY), False)
    includes = primary.count(None)
    side = root / CONTINUATION
    if includes > 1:
        raise QueueIndexError("duplicate queue include")
    if not includes and (side.exists() or side.is_symlink()):
        raise QueueIndexError("orphan continuation without queue include")
    continuation = _lines(_read(root, CONTINUATION), True) if includes else []
    if includes and not continuation:
        raise QueueIndexError("empty queue continuation")
    rows = [child for row in primary for child in (continuation if row is None else [row])]
    if not rows:
        raise QueueIndexError("execution index has no rows")
    if [row.seq for row in rows] != list(range(1, len(rows) + 1)):
        raise QueueIndexError("execution sequence must be continuous in source order")
    if len({row.order_id for row in rows}) != len(rows):
        raise QueueIndexError("duplicate queue order ID")
    return rows
