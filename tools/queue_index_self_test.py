#!/usr/bin/env python3
"""Bounded continuation fixtures; no game, approval, or rendering verdict."""

from __future__ import annotations

import contextlib
import io
import tempfile
from pathlib import Path
from unittest.mock import patch

import context_manifest_check as context_check
import project_dashboard as dashboard
import queue_consistency_check as consistency
from queue_index import (CONTINUATION, INCLUDE, PRIMARY, SECTION, TABLE_HEADER,
                         TABLE_RULE, QueueIndexError, read_queue_index)


def row(seq: int, order: int) -> str:
    return (f"| {seq} | [~] | ORDER-{order} · 검토 {order} | "
            f"[{order}](queue_active/ORDER-{order}.md) | L1/L2 PASS · L3 OPEN |\n")


ROWS = [row(1, 3), row(2, 2), row(3, 1)]
HEADING = f"# Queue fixture\n\n{SECTION}\n\n{TABLE_HEADER}\n{TABLE_RULE}\n"
PRIMARY_TEXT = HEADING + ROWS[0] + "\n" + INCLUDE + "\n\n" + TABLE_HEADER + "\n" + TABLE_RULE + "\n" + ROWS[2]
SIDE_TEXT = HEADING + ROWS[1]


def write(root: Path, relative: str, text: str) -> None:
    target = root / relative
    target.parent.mkdir(parents=True, exist_ok=True)
    target.write_text(text, encoding="utf-8")


def fixture(root: Path, continuation: bool = True) -> None:
    write(root, PRIMARY, PRIMARY_TEXT if continuation else HEADING + "".join(ROWS))
    if continuation:
        write(root, CONTINUATION, SIDE_TEXT)
    for order in (3, 2, 1):
        write(root, f"docs/queue_active/ORDER-{order}.md", f"#### [~] ORDER-{order} fixture\n")
    write(root, "CLAUDE.md", "실행 우선순위·상태의 단일 정본\n")
    write(root, "docs/HANDOFF.md", "실행 순서·상태는 CODEX_QUEUE.md\n")


def check_consistency(root: Path) -> tuple[int, str]:
    output = io.StringIO()
    with contextlib.redirect_stdout(output):
        code = consistency.main(root)
    return code, output.getvalue()


def reject(root: Path, expected: str) -> None:
    try:
        read_queue_index(root)
    except QueueIndexError as exc:
        assert expected in str(exc), (expected, str(exc))
    else:
        raise AssertionError(f"mutation accepted; expected {expected}")


def mutate(root: Path, relative: str, before: str, after: str) -> None:
    original = (root / relative).read_text(encoding="utf-8")
    assert original.count(before) == 1, before
    write(root, relative, original.replace(before, after, 1))


def run() -> int:
    count = 0
    # Every negative case starts from an independently passing, complete fixture.
    cases = [
        ("missing page", lambda r: (r / CONTINUATION).unlink(), "missing or unsafe"),
        ("orphan page", lambda r: mutate(r, PRIMARY, INCLUDE, ""), "orphan"),
        ("duplicate include", lambda r: mutate(r, PRIMARY, INCLUDE, INCLUDE + "\n" + INCLUDE), "duplicate queue include"),
        ("unknown path", lambda r: mutate(r, PRIMARY, "(CODEX_QUEUE_L3_PENDING.md)", "(OTHER.md)"), "unsafe queue include"),
        ("traversal", lambda r: mutate(r, PRIMARY, "(CODEX_QUEUE_L3_PENDING.md)", "(../CODEX_QUEUE_L3_PENDING.md)"), "unsafe queue include"),
        ("absolute path", lambda r: mutate(r, PRIMARY, "(CODEX_QUEUE_L3_PENDING.md)", "(/tmp/CODEX_QUEUE_L3_PENDING.md)"), "unsafe queue include"),
        ("nested include", lambda r: write(r, CONTINUATION, SIDE_TEXT + INCLUDE + "\n"), "nested"),
        ("missing middle row", lambda r: mutate(r, PRIMARY, ROWS[2], ROWS[2].replace("| 3 |", "| 4 |")), "sequence"),
        ("duplicate ID", lambda r: mutate(r, PRIMARY, ROWS[2], row(3, 3)), "duplicate queue order ID"),
        ("reversed rows", lambda r: mutate(r, PRIMARY, ROWS[0], row(3, 3)), "sequence"),
        ("malformed primary row", lambda r: mutate(r, PRIMARY, ROWS[0], ROWS[0].replace("[~]", "[?]")), "malformed queue row"),
        ("malformed side row", lambda r: mutate(r, CONTINUATION, ROWS[1], ROWS[1].replace("| 2 |", "| bad |")), "malformed queue row"),
        ("false completion", lambda r: mutate(r, CONTINUATION, "[~]", "[x]"), "must remain [~]"),
        ("false L3 GO", lambda r: mutate(r, CONTINUATION, "L3 OPEN", "L3 GO"), "must remain [~]"),
        ("conflicting L3 claims", lambda r: mutate(r, CONTINUATION, "L3 OPEN", "L3 GO · L3 OPEN"), "must remain [~]"),
        ("row outside index", lambda r: write(r, PRIMARY, ROWS[0] + PRIMARY_TEXT), "outside execution index"),
        ("fenced row", lambda r: mutate(r, PRIMARY, ROWS[0], "```\n" + ROWS[0] + "```\n"), "inside code fence"),
        ("include outside index", lambda r: write(r, PRIMARY, INCLUDE + "\n" + PRIMARY_TEXT), "outside execution index"),
        ("link mismatch", lambda r: mutate(r, CONTINUATION, "(queue_active/ORDER-2.md)", "(queue_active/ORDER-1.md)"), "link ID mismatch"),
    ]
    with tempfile.TemporaryDirectory(prefix="queue-index-test-") as temp:
        base = Path(temp)
        legacy = base / "legacy"
        fixture(legacy, False)
        assert check_consistency(legacy)[0] == 0
        with patch.object(dashboard, "ROOT", legacy):
            expected_dashboard = dashboard.orders()
        assert [x["id"] for x in expected_dashboard] == ["ORDER-3", "ORDER-2", "ORDER-1"]
        count += 1
        split = base / "split"
        fixture(split)
        assert check_consistency(split)[0] == 0
        assert [r.raw for r in read_queue_index(split)] == ROWS
        with patch.object(dashboard, "ROOT", split):
            assert dashboard.orders() == expected_dashboard
        count += 1
        for name, change, message in cases:
            root = base / str(count)
            fixture(root)
            assert check_consistency(root)[0] == 0, name
            change(root)
            reject(root, message)
            if name == "fenced row":
                # Independent review: heading-before-fence state, short closes,
                # and mixed marker types must not turn examples into real rows.
                fenced_documents = [
                    "```markdown\n" + PRIMARY_TEXT + "```\n",
                    PRIMARY_TEXT.replace(SECTION, "```\n" + SECTION, 1),
                    PRIMARY_TEXT.replace(ROWS[0], "````\n```\n" + ROWS[0], 1),
                    PRIMARY_TEXT.replace(ROWS[0], "```\n~~~\n" + ROWS[0], 1),
                ]
                for index, document in enumerate(fenced_documents):
                    subcase = base / f"fenced-{index}"
                    fixture(subcase)
                    assert check_consistency(subcase)[0] == 0
                    write(subcase, PRIMARY, document)
                    reject(subcase, "inside code fence")
            count += 1
        root = base / "symlink"
        fixture(root)
        assert check_consistency(root)[0] == 0
        (root / CONTINUATION).unlink()
        (root / CONTINUATION).symlink_to(split / CONTINUATION)
        reject(root, "symlink")
        count += 1
        root = base / "spec"
        fixture(root)
        assert check_consistency(root)[0] == 0
        mutate(root, "docs/queue_active/ORDER-2.md", "[~]", "[ ]")
        code, output = check_consistency(root)
        assert code == 1 and "큐 상태 [~]와 사양 상태 [ ]" in output
        count += 1
        root = base / "missing-last"
        fixture(root)
        assert check_consistency(root)[0] == 0
        mutate(root, PRIMARY, ROWS[2], "")
        code, output = check_consistency(root)
        assert code == 1 and "queue_active에만" in output and "ORDER-1" in output
        count += 1
        manifest = {"boot": {"queue_continuation": {"path": CONTINUATION, "max_bytes": 16000}}}
        with patch.object(context_check, "ROOT", split):
            errors = []
            context_check.validate_budgets(manifest, errors)
            assert not errors, errors
            write(split, CONTINUATION, "x" * 16001)
            context_check.validate_budgets(manifest, errors)
            assert len(errors) == 1 and "16001 bytes (max 16000)" in errors[0], errors
        count += 1
    print(f"QUEUE_INDEX_SELF_TEST_OK fixtures={count} fence_review_subcases=4")
    return 0


if __name__ == "__main__":
    raise SystemExit(run())
