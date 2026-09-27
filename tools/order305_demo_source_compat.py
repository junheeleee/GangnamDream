#!/usr/bin/env python3
"""Exact ORDER-305 source successor, not a replacement public-demo approval.

Raw admission and historical views are deliberately separate. Five immutable
Git blobs prove exactly 23 string-leaf edits; projections never admit a changed
neighbor, reorder an event, or overwrite a live file. Older audit pins remain
owned by their original checkers.
"""

from __future__ import annotations

import argparse
import copy
import functools
import hashlib
import json
import subprocess
from pathlib import Path
from typing import Any, Union

ROOT = Path(__file__).resolve().parents[1]
BEFORE_COMMIT = "f537c1ae44a5cc159a46e1c594f168186fc91670"
AFTER_COMMIT = "031f5e50ee0091cd573f78d6fb4a2f358c1d1442"
FILE_HASHES = {
    "content/events/arc_events.json": (
        "317cd11f8cf2cb29f15052fee16b17d5fef568fec1ed86dae26360ca5b5407ae",
        "ccd902447b46e10e02128d46ef273e65a30e3df9753b7f257f7fd9accb848f62"),
    "content/events_en/arc_events.json": (
        "af12b86b48709bb2af0c52baf4036fc4ed902edb6e3cb5b1dc48dafb7de3a982",
        "5c67fde3bae33bb9bc9edabc1ef8d9efde09f4fee2d19fd83ebbdf6c4e69c1ac"),
    "content/events_ja/story_demo_events.json": (
        "661f9dcf1b958ab9edc5707ca3155e675670b1394fc2ce0e341c6d5456e28a08",
        "3ba992ecafbd5b31d00cb9c3630f4f6a9b37fefb41fbe6aba191d3d77076a10b"),
    "content/events_zh-CN/story_demo_events.json": (
        "4e749e041c7d463d26aa3c54da284b4d5da1455611b0af651b74a81b6048bbc8",
        "b8ff12758d29a02fd07fdad5f8d3931b805afcbe8e18f1d02db5dfa575c0f05e"),
    "content/events_zh-TW/story_demo_events.json": (
        "33a5b165970675646d7144d42da92884eb3d4bc9b846635369d6ea2a3d5097a9",
        "57929914f0b8c73e8865dd1dde9c45e240fcf0463d327fd32d2225ccf3dc9dca"),
}
PATHS = tuple(FILE_HASHES)
KO_PATH = PATHS[0]
EN_PATH = PATHS[1]
MEET = "arc_sangchul_01_meet"
ANSWER = "arc_sangchul_01_answer"
CLEAN = "arc_temptation_clean"
Patch = tuple[str, tuple[Union[str, int], ...], str, str]


def _rent(before: str, after: str) -> tuple[Patch, ...]:
    return tuple((MEET, (field,), before, after) for field in (
        "description", "description_orthodox", "description_unorthodox"))


PATCHES: dict[str, tuple[Patch, ...]] = {
    PATHS[0]: _rent("오십오", "칠십") + (
        (ANSWER, ("choices", 0, "result_text"), "김민준", "{name}"),
        (ANSWER, ("choices", 1, "result_text"), "웃는다", "웃었다"),
        (CLEAN, ("description",), "받지 않은 200만원은 없었고", "200만원은 들어오지 않았고")),
    PATHS[1]: _rent("550,000", "700,000"),
    PATHS[2]: _rent("55万", "70万") + (
        (ANSWER, ("choices", 0, "result_text"), "キム・ミンジュン", "{name}"),
        (CLEAN, ("description",), "受け取らなかった200万ウォンは存在せず", "200万ウォンは入ってこず")),
    PATHS[3]: _rent("55万", "70万") + (
        (ANSWER, ("choices", 0, "result_text"), "Kim Minjun", "{name}"),
        (CLEAN, ("description",), "没拿到的200万韩元并不存在", "200万韩元没有进账")),
    PATHS[4]: _rent("55萬", "70萬") + (
        (ANSWER, ("choices", 0, "result_text"), "Kim Minjun", "{name}"),),
}


def _sha(raw: bytes) -> str:
    return hashlib.sha256(raw).hexdigest()


def _canonical(value: Any) -> bytes:
    return json.dumps(value, ensure_ascii=False, sort_keys=True,
                      separators=(",", ":"), allow_nan=False).encode("utf-8")


def _pairs(pairs: list[tuple[str, Any]]) -> dict[str, Any]:
    result: dict[str, Any] = {}
    for key, value in pairs:
        if key in result:
            raise ValueError(f"ORDER-305: duplicate JSON key {key!r}")
        result[key] = value
    return result


def _loads(raw: bytes) -> Any:
    def reject_constant(value: str) -> None:
        raise ValueError(f"ORDER-305: non-JSON numeric constant {value}")
    return json.loads(raw.decode("utf-8"), object_pairs_hook=_pairs,
                      parse_constant=reject_constant)


def _row(payload: Any, event_id: str) -> dict[str, Any] | None:
    if not isinstance(payload, list):
        return None
    rows = [row for row in payload if isinstance(row, dict) and row.get("id") == event_id]
    return rows[0] if len(rows) == 1 else None


def _parent(row: Any, path: tuple[str | int, ...]) -> Any:
    for part in path[:-1]:
        row = row[part]
    return row


def _git_blob(revision: str, relative: str) -> bytes:
    result = subprocess.run(["git", "show", f"{revision}:{relative}"], cwd=ROOT,
                            check=False, capture_output=True)
    if result.returncode:
        raise ValueError(f"ORDER-305: immutable source unavailable {revision}:{relative}")
    return result.stdout


def _verify_transition(previous: bytes, current: bytes, relative: str) -> None:
    if relative not in FILE_HASHES or (_sha(previous), _sha(current)) != FILE_HASHES[relative]:
        raise ValueError(f"ORDER-305: immutable file hashes drifted {relative}")
    old, new = _loads(previous), _loads(current)
    expected = copy.deepcopy(old)
    expected_raw = previous
    for event_id, path, before, after in PATCHES[relative]:
        row = _row(expected, event_id)
        if row is None:
            raise ValueError(f"ORDER-305: non-unique event {relative}:{event_id}")
        parent = _parent(row, path)
        text = parent[path[-1]]
        if not isinstance(text, str) or text.count(before) != 1:
            raise ValueError(f"ORDER-305: non-unique leaf anchor {relative}:{event_id}:{path}")
        replacement = text.replace(before, after, 1)
        old_literal = json.dumps(text, ensure_ascii=False).encode("utf-8")
        new_literal = json.dumps(replacement, ensure_ascii=False).encode("utf-8")
        if expected_raw.count(old_literal) != 1:
            raise ValueError(f"ORDER-305: non-unique complete JSON string {relative}:{event_id}:{path}")
        expected_raw = expected_raw.replace(old_literal, new_literal, 1)
        parent[path[-1]] = replacement
    if _canonical(expected) != _canonical(new) or expected_raw != current:
        raise ValueError(f"ORDER-305: successor exceeds declared leaf/byte delta {relative}")


@functools.lru_cache(maxsize=5)
def verified_blobs(relative: str) -> tuple[bytes, bytes]:
    """Prove both immutable hashes and the complete declared forward delta."""
    if relative not in FILE_HASHES:
        raise ValueError(f"ORDER-305: unregistered path {relative}")
    previous = _git_blob(BEFORE_COMMIT, relative)
    current = _git_blob(AFTER_COMMIT, relative)
    _verify_transition(previous, current, relative)
    return previous, current


def project_bytes(current: bytes, relative: str) -> bytes:
    if relative not in FILE_HASHES or _sha(current) != FILE_HASHES[relative][1]:
        return current
    try:
        previous, registered = verified_blobs(relative)
    except (OSError, ValueError):
        return current
    return previous if current == registered else current


def project_payload(payload: Any, relative: str) -> Any:
    """Inverse only declared leaves of complete exact successor event objects.

    Neighbor mutations and event order remain visible to older callers. A raw
    source guard is additionally required at each live-file entry point.
    """
    projected = copy.deepcopy(payload)
    if relative not in FILE_HASHES or not isinstance(projected, list):
        return projected
    try:
        previous, current = map(_loads, verified_blobs(relative))
        for event_id in dict.fromkeys(patch[0] for patch in PATCHES[relative]):
            row, expected = _row(projected, event_id), _row(current, event_id)
            if row is None or _canonical(row) != _canonical(expected):
                continue
            old = _row(previous, event_id)
            for target, path, _before, _after in PATCHES[relative]:
                if target == event_id:
                    _parent(row, path)[path[-1]] = _parent(old, path)[path[-1]]
    except (OSError, ValueError, TypeError, KeyError, IndexError):
        return copy.deepcopy(payload)
    return projected


def project_byte_hash(current_hash: str, relative: str) -> str:
    if relative in FILE_HASHES and current_hash == FILE_HASHES[relative][1]:
        try:
            previous, current = verified_blobs(relative)
        except (OSError, ValueError):
            return current_hash
        if project_bytes(current, relative) == previous:
            return FILE_HASHES[relative][0]
    return current_hash


def source_errors(current: bytes, relative: str) -> list[str]:
    """Require the approved *raw current* bytes, never merely projected bytes."""
    try:
        previous, registered = verified_blobs(relative)
    except (OSError, ValueError) as exc:
        return [str(exc)]
    if current != registered:
        return [f"ORDER-305: current source exceeds exact approved successor {relative}"]
    if project_bytes(current, relative) != previous:
        return [f"ORDER-305: inverse failed {relative}"]
    return []


def current_source_errors(root: Path = ROOT) -> list[str]:
    errors: list[str] = []
    for relative in PATHS:
        try:
            errors.extend(source_errors((root / relative).read_bytes(), relative))
        except OSError as exc:
            errors.append(f"ORDER-305: current source unavailable {relative}: {exc}")
    return errors


def self_test() -> tuple[list[str], int]:
    failures: list[str] = []
    cases = 0

    def check(ok: bool, label: str) -> None:
        nonlocal cases
        cases += 1
        if not ok:
            failures.append(label)

    check(sum(map(len, PATCHES.values())) == 23 and tuple(PATCHES) == PATHS,
          "exact five-file/23-leaf registry")
    for relative in PATHS:
        try:
            previous, current = verified_blobs(relative)
        except (OSError, ValueError) as exc:
            check(False, str(exc))
            continue
        old, new = _loads(previous), _loads(current)
        saved = copy.deepcopy(new)
        check(not source_errors(current, relative), f"{relative}: current admission")
        check(project_bytes(current, relative) == previous, f"{relative}: byte inverse")
        check(project_payload(new, relative) == old and new == saved, f"{relative}: copied payload inverse")
        check(project_byte_hash(_sha(current), relative) == _sha(previous), f"{relative}: hash inverse")
        check(project_bytes(previous, relative) == previous
              and project_payload(old, relative) == old
              and bool(source_errors(previous, relative)), f"{relative}: no-op is not admission")
        check(project_payload(list(reversed(new)), relative) == list(reversed(old)),
              f"{relative}: preserve event order")
        wrong_path = relative + ".other"
        check(project_bytes(current, wrong_path) == current
              and project_payload(new, wrong_path) == new
              and project_byte_hash(_sha(current), wrong_path) == _sha(current)
              and bool(source_errors(current, wrong_path)), f"{relative}: reject wrong path")
        for mutant in (current + b"\n", current.replace(b'"id":', b'"id":"duplicate", "id":', 1)):
            check(project_bytes(mutant, relative) == mutant
                  and project_byte_hash(_sha(mutant), relative) == _sha(mutant)
                  and bool(source_errors(mutant, relative)), f"{relative}: raw drift rejected")
        for event_id, path, _before, _after in PATCHES[relative]:
            row = copy.deepcopy(_row(new, event_id))
            _parent(row, path)[path[-1]] += "!"
            check(project_payload([row], relative) == [row], f"{relative}:{event_id}:{path}: leaf drift")
            row = copy.deepcopy(_row(new, event_id))
            _parent(row, path)[path[-1]] = _parent(_row(old, event_id), path)[path[-1]]
            check(project_payload([row], relative) == [row], f"{relative}:{event_id}:{path}: partial rollback")
        row = copy.deepcopy(_row(new, MEET))
        mutants = []
        for field, value in (("id", 305), ("title", "changed"), ("conditions", {"money": 0}),
                             ("description", [row["description"]])):
            mutant = copy.deepcopy(row)
            mutant[field] = value
            mutants.append([mutant])
        mutant = copy.deepcopy(row)
        mutant["choices"].reverse()
        mutants.extend(([mutant], [row, copy.deepcopy(row)], {"events": new}))
        for mutant in mutants:
            check(project_payload(mutant, relative) == mutant, f"{relative}: object/type/order/duplicate guard")
        neighbor = copy.deepcopy(new)
        untouched = next(row for row in neighbor if row["id"] not in {p[0] for p in PATCHES[relative]})
        untouched["title"] += "!"
        projected = project_payload(neighbor, relative)
        check(_row(projected, untouched["id"]) == untouched and projected != old,
              f"{relative}: neighbor drift remains visible")
    return failures, cases


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--self-test", action="store_true")
    args = parser.parse_args()
    errors = current_source_errors()
    cases = 0
    if args.self_test:
        failures, cases = self_test()
        errors.extend(failures)
    for error in errors:
        print("ORDER305_DEMO_SOURCE_ERROR " + error)
    print(f"ORDER305_DEMO_SOURCE_{'FAIL' if errors else 'OK'} files=5 leaves=23 cases={cases}")
    return int(bool(errors))


if __name__ == "__main__":
    raise SystemExit(main())
