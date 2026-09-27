#!/usr/bin/env python3
"""Exact ORDER-310 English successor and a composed historical audit view.

The ORDER-305 module remains immutable. Its transition-specific fixtures still
use its original APIs; live callers use this module's explicit latest admission.
No historical package, source pin, or human verdict is refreshed here.
"""

from __future__ import annotations

import argparse
import copy
import functools
import json
from pathlib import Path
from typing import Any, Union

import order305_demo_source_compat as previous

ROOT = Path(__file__).resolve().parents[1]
BEFORE_COMMIT = "0f0b5e85cd9262f8efb4ccf2d20b7b9deaed7efa"
AFTER_COMMIT = "4de3bbb1959f5e69a0aad0a72fca81a82d2ca47a"
ARC_PATH = "content/events_en/arc_events.json"
CORE_PATH = "content/events_en/core_loop_v2_events.json"
CONTROLLER_PATH = "playtests/order124/StoryChoiceM1M6Playtest.gd"
PATHS = (ARC_PATH, CORE_PATH, CONTROLLER_PATH)
FILE_HASHES = {
    ARC_PATH: ("5c67fde3bae33bb9bc9edabc1ef8d9efde09f4fee2d19fd83ebbdf6c4e69c1ac", "1ecd0007956e0c880827d442bceb3d0459b971d46497db3545eca91e2f80d735"),
    CORE_PATH: ("d4414a4bf004f83602af378527b78c4cd1682fc2d393c9dc8e0e9cf2a7fa2f60", "fc24d9810a65b7cfe824dddc6fe6413820d24fb974442f090f8c0593d9e8c601"),
    CONTROLLER_PATH: ("7a9af7ce1fe20a5f5296dd5e8107ad6062629159fbf41443785dfc8537535ceb", "156bdda2571bc4b95f44b3a0e9d71a42193d0386919496f15be0d624753200ea"),
}
Leaf = tuple[str, tuple[Union[str, int], ...]]
JSON_LEAVES: dict[str, tuple[Leaf, ...]] = {
    ARC_PATH: (
        ("arc_sangchul_01_meet", ("description",)),
        ("arc_sangchul_01_meet", ("description_orthodox",)),
        ("arc_sangchul_01_meet", ("description_unorthodox",)),
        ("arc_sangchul_01_meet", ("choices", 0, "result_text")),
        ("arc_sangchul_01_meet", ("choices", 1, "result_text")),
        ("arc_temptation_clean", ("description",)),
        ("arc_jiyeon_01_crash", ("choices", 0, "text")),
        ("arc_jiyeon_01_crash", ("choices", 1, "text")),
        ("arc_jiyeon_01_crash", ("choices", 2, "text")),
        ("arc_jiyeon_01_crash", ("choices", 1, "result_text")),
        ("arc_jiyeon_01_crash", ("choices", 2, "result_text")),
        ("arc_sangchul_01_answer", ("choices", 0, "text")),
        ("arc_sangchul_01_answer", ("choices", 1, "text")),
        ("arc_sangchul_01_answer", ("choices", 2, "text")),
        ("arc_sangchul_01_answer", ("choices", 1, "result_text")),
        ("arc_sangchul_01_answer", ("choices", 2, "result_text")),
        ("arc_jaehyuk_01_reunion", ("choices", 0, "result_text")),
        ("arc_jaehyuk_01_reunion", ("description",)),
    ),
    CORE_PATH: (
        ("v2_demo_first_bill", ("choices", 3, "result_text")),
        ("v2_demo_first_bill", ("choices", 4, "result_text")),
    ),
}
LIVE_PATHS = tuple(dict.fromkeys((*previous.PATHS, *PATHS)))
LIVE_EVENT_IDS = {
    path: frozenset([patch[0] for patch in previous.PATCHES.get(path, ())]
                    + [leaf[0] for leaf in JSON_LEAVES.get(path, ())])
    for path in LIVE_PATHS if path.endswith(".json")
}
CONTROLLER_LINE_PREFIX = '\t\t\t"{name} leaves his room at once.'


def _controller_forward(before: bytes) -> bytes:
    lines = before.decode("utf-8").splitlines(keepends=True)
    candidates = [line for line in lines if line.startswith(CONTROLLER_LINE_PREFIX)]
    if len(candidates) != 1 or not candidates[0].endswith('\")\n'):
        raise ValueError("ORDER-310: controller EN literal owner/cardinality drifted")
    old = candidates[0]
    if old.count("“") != 5 or old.count("”") != 5:
        raise ValueError("ORDER-310: controller five dialogue pairs drifted")
    new = old.replace("“", '\\"').replace("”", '\\"')
    return before.replace(old.encode("utf-8"), new.encode("utf-8"), 1)


def _verify_transition(before: bytes, after: bytes, relative: str) -> None:
    if relative not in FILE_HASHES or (previous._sha(before), previous._sha(after)) != FILE_HASHES[relative]:
        raise ValueError(f"ORDER-310: immutable source hashes drifted {relative}")
    if relative == CONTROLLER_PATH:
        if _controller_forward(before) != after:
            raise ValueError("ORDER-310: controller exceeds the one English quotation literal")
        return
    old, new = previous._loads(before), previous._loads(after)
    expected = copy.deepcopy(old)
    expected_raw = before
    for event_id, path in JSON_LEAVES[relative]:
        old_row, new_row = previous._row(expected, event_id), previous._row(new, event_id)
        if old_row is None or new_row is None:
            raise ValueError(f"ORDER-310: event identity/cardinality drifted {relative}:{event_id}")
        owner = previous._parent(old_row, path)
        old_text, new_text = owner[path[-1]], previous._parent(new_row, path)[path[-1]]
        if not isinstance(old_text, str) or not isinstance(new_text, str) or old_text == new_text:
            raise ValueError(f"ORDER-310: declared leaf is not a string delta {event_id}:{path}")
        old_literal = json.dumps(old_text, ensure_ascii=False).encode("utf-8")
        new_literal = json.dumps(new_text, ensure_ascii=False).encode("utf-8")
        if expected_raw.count(old_literal) != 1:
            raise ValueError(f"ORDER-310: complete JSON leaf is not unique {event_id}:{path}")
        expected_raw = expected_raw.replace(old_literal, new_literal, 1)
        owner[path[-1]] = new_text
    if previous._canonical(expected) != previous._canonical(new) or expected_raw != after:
        raise ValueError(f"ORDER-310: source exceeds the declared exact leaves {relative}")


@functools.lru_cache(maxsize=3)
def verified_blobs(relative: str) -> tuple[bytes, bytes]:
    if relative not in PATHS:
        raise ValueError(f"ORDER-310: unregistered transition path {relative}")
    before = previous._git_blob(BEFORE_COMMIT, relative)
    after = previous._git_blob(AFTER_COMMIT, relative)
    _verify_transition(before, after, relative)
    if relative in previous.PATHS and previous.source_errors(before, relative):
        raise ValueError(f"ORDER-310: predecessor does not bind to ORDER-305 {relative}")
    return before, after


def inverse_310_bytes(raw: bytes, relative: str) -> bytes:
    if relative not in FILE_HASHES or previous._sha(raw) != FILE_HASHES[relative][1]:
        return raw
    try:
        before, after = verified_blobs(relative)
    except (OSError, ValueError):
        return raw
    return before if raw == after else raw


def inverse_310_payload(payload: Any, relative: str) -> Any:
    projected = copy.deepcopy(payload)
    if relative not in JSON_LEAVES or not isinstance(projected, list):
        return projected
    try:
        before, after = map(previous._loads, verified_blobs(relative))
        for event_id in dict.fromkeys(leaf[0] for leaf in JSON_LEAVES[relative]):
            row, expected = previous._row(projected, event_id), previous._row(after, event_id)
            if row is None or previous._canonical(row) != previous._canonical(expected):
                continue
            old = previous._row(before, event_id)
            for target, path in JSON_LEAVES[relative]:
                if target == event_id:
                    previous._parent(row, path)[path[-1]] = previous._parent(old, path)[path[-1]]
    except (OSError, ValueError, TypeError, KeyError, IndexError):
        return copy.deepcopy(payload)
    return projected


def inverse_310_hash(digest: str, relative: str) -> str:
    if relative in FILE_HASHES and digest == FILE_HASHES[relative][1]:
        try:
            before, after = verified_blobs(relative)
        except (OSError, ValueError):
            return digest
        if inverse_310_bytes(after, relative) == before:
            return FILE_HASHES[relative][0]
    return digest


def project_bytes(raw: bytes, relative: str) -> bytes:
    return previous.project_bytes(inverse_310_bytes(raw, relative), relative)


def project_payload(payload: Any, relative: str) -> Any:
    return previous.project_payload(inverse_310_payload(payload, relative), relative)


def project_byte_hash(digest: str, relative: str) -> str:
    return previous.project_byte_hash(inverse_310_hash(digest, relative), relative)


def source_errors(raw: bytes, relative: str) -> list[str]:
    """Latest raw admission; a predecessor is never accepted as live source."""
    if relative not in PATHS:
        return previous.source_errors(raw, relative)
    try:
        before, after = verified_blobs(relative)
    except (OSError, ValueError) as exc:
        return [str(exc)]
    if raw != after:
        return [f"ORDER-310: current source exceeds exact approved successor {relative}"]
    if inverse_310_bytes(raw, relative) != before:
        return [f"ORDER-310: exact inverse failed {relative}"]
    return []


def current_source_errors(root: Path = ROOT) -> list[str]:
    errors: list[str] = []
    for relative in LIVE_PATHS:
        try:
            errors.extend(source_errors((root / relative).read_bytes(), relative))
        except OSError as exc:
            errors.append(f"ORDER-310: live source unavailable {relative}: {exc}")
    return errors


def self_test() -> tuple[list[str], int]:
    failures: list[str] = []
    cases = 0

    def check(ok: bool, label: str) -> None:
        nonlocal cases
        cases += 1
        if not ok:
            failures.append(label)

    check(sum(map(len, JSON_LEAVES.values())) + 1 == 21 and len(LIVE_PATHS) == 7,
          "exact 21-leaf/three-successor/seven-live-file population")
    for relative in PATHS:
        try:
            before, after = verified_blobs(relative)
        except (OSError, ValueError) as exc:
            check(False, str(exc))
            continue
        check(not source_errors(after, relative), relative + " current admission")
        check(inverse_310_bytes(after, relative) == before, relative + " single inverse")
        check(project_bytes(after, relative) == previous.project_bytes(before, relative),
              relative + " composed inverse")
        check(project_byte_hash(previous._sha(after), relative)
              == previous.project_byte_hash(previous._sha(before), relative), relative + " hash composition")
        check(bool(source_errors(before, relative)) and inverse_310_bytes(before, relative) == before,
              relative + " predecessor is not live admission")
        for label, candidate_path, candidate in (
            ("wrong path", relative + ".other", after),
            ("newline", relative, after + b"\n"),
            ("missing bytes", relative, b""),
        ):
            check(bool(source_errors(candidate, candidate_path))
                  and inverse_310_bytes(candidate, candidate_path) == candidate
                  and inverse_310_hash(previous._sha(candidate), candidate_path) == previous._sha(candidate),
                  relative + " rejects " + label)
        if relative == CONTROLLER_PATH:
            drift = after.replace(b'unknown_choice["text"]', b'unknown_choice["subtitle"]', 1)
            check(drift != after and bool(source_errors(drift, relative))
                  and project_bytes(drift, relative) == drift, "controller neighboring logic stays visible")
            continue
        old, new = previous._loads(before), previous._loads(after)
        saved = copy.deepcopy(new)
        check(inverse_310_payload(new, relative) == old and new == saved, relative + " copied leaf inverse")
        check(project_payload(new, relative) == previous.project_payload(old, relative), relative + " payload composition")
        check(inverse_310_payload(list(reversed(new)), relative) == list(reversed(old)), relative + " order preserved")
        duplicate = after.replace(b'"id":', b'"id":"duplicate", "id":', 1)
        check(bool(source_errors(duplicate, relative)) and inverse_310_bytes(duplicate, relative) == duplicate,
              relative + " duplicate raw keys rejected")
        for event_id, path in JSON_LEAVES[relative]:
            for label, replacement in (("mutation", "unapproved"), ("type", 310),
                                       ("partial rollback", previous._parent(previous._row(old, event_id), path)[path[-1]])):
                row = copy.deepcopy(previous._row(new, event_id))
                previous._parent(row, path)[path[-1]] = replacement
                check(inverse_310_payload([row], relative) == [row], f"{relative}:{event_id}:{path} {label}")
        event_id = JSON_LEAVES[relative][0][0]
        row = copy.deepcopy(previous._row(new, event_id))
        for label, payload in (("duplicate ID", [row, copy.deepcopy(row)]), ("root type", {"events": new})):
            check(inverse_310_payload(payload, relative) == payload, relative + " " + label)
        for label, field, value in (("wrong ID", "id", "other"), ("gameplay", "conditions", {"money": 1}),
                                    ("non-target prose", "title", "unapproved")):
            mutant = copy.deepcopy(row)
            mutant[field] = value
            check(inverse_310_payload([mutant], relative) == [mutant], relative + " " + label)
        neighbor = copy.deepcopy(new)
        untouched = next(row for row in neighbor if row["id"] not in LIVE_EVENT_IDS[relative])
        untouched["title"] += "!"
        projected = project_payload(neighbor, relative)
        check(previous._row(projected, untouched["id"]) == untouched
              and projected != previous.project_payload(old, relative), relative + " neighbor is not erased")
    return failures, cases


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    mode = parser.add_mutually_exclusive_group()
    mode.add_argument("--self-test", action="store_true")
    mode.add_argument("--historical-self-test", action="store_true",
                      help="Run the unchanged ORDER-305 corpus after latest raw admission")
    args = parser.parse_args()
    errors = current_source_errors()
    cases = 0
    if args.self_test:
        failures, cases = self_test()
        errors.extend(failures)
    if args.historical_self_test:
        failures, cases = previous.self_test()
        errors.extend(failures)
    for error in errors:
        print("ORDER310_DEMO_SOURCE_ERROR " + error)
    marker = "ORDER310_HISTORICAL_305" if args.historical_self_test else "ORDER310_DEMO_SOURCE"
    print(f"{marker}_{'FAIL' if errors else 'OK'} files=3 leaves=21 live_files=7 cases={cases}")
    return int(bool(errors))


if __name__ == "__main__":
    raise SystemExit(main())
