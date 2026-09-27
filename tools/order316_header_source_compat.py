#!/usr/bin/env python3
"""Exact two-file header successor and fail-closed historical audit views.

ORDER-315 changes display geometry only. Its immutable product commit, parent,
file population, byte hashes, and function boundary are verified before either
inverse is exposed. ORDER-310/305/156 pins and historical fixtures are unchanged;
live admission never accepts a rollback merely because it has a historical view.
"""

from __future__ import annotations

import argparse
import functools
import hashlib
import re
import subprocess
from pathlib import Path

import order310_demo_source_compat as previous

ROOT = Path(__file__).resolve().parents[1]
BEFORE_COMMIT = "7f9160a0327d66ffb37a6369f135cec350c69735"
AFTER_COMMIT = "1e141ea3bc117de8be31632a083c37ffc7ba152a"
STORY_PATH = "scenes/StoryMode.gd"
CONTROLLER_PATH = "playtests/order124/StoryChoiceM1M6Playtest.gd"
FILE_HASHES = {
    STORY_PATH: (
        "e6d5c9f0612138d6a82b7b69bdab0cbcc1c657ad3b4461284f6c3236b36e6343",
        "114fdd47d09cb4e3b92b26d094981b8e9b1843639f64cb3914bcce000a76bec7"),
    CONTROLLER_PATH: (
        "156bdda2571bc4b95f44b3a0e9d71a42193d0386919496f15be0d624753200ea",
        "feb2f8a20bd8db91579062b1c7449f28f4d0146674c043d262107f1ea53913c2"),
}
PATHS = tuple(FILE_HASHES)
LIVE_PATHS = tuple(dict.fromkeys((*previous.LIVE_PATHS, *PATHS)))
CHANGED_FUNCTIONS = {
    STORY_PATH: frozenset(("_build_ui", "_build_dialogue_log_button",
                           "_build_story_audio_settings_button")),
    CONTROLLER_PATH: frozenset(("_apply_margins", "_on_resized")),
}
ADDED_FUNCTIONS = {
    STORY_PATH: frozenset(("_on_story_header_resized", "_layout_story_header")),
    CONTROLLER_PATH: frozenset(),
}


def _sha(raw: bytes) -> str:
    return hashlib.sha256(raw).hexdigest()


def _git(*args: str) -> bytes:
    result = subprocess.run(("git", *args), cwd=ROOT, capture_output=True)
    if result.returncode:
        raise ValueError("ORDER-316: immutable Git proof unavailable: " + " ".join(args))
    return result.stdout


def _git_blob(revision: str, relative: str) -> bytes:
    return _git("show", f"{revision}:{relative}")


def _verify_git_registration() -> None:
    if _git("rev-parse", AFTER_COMMIT + "^").decode().strip() != BEFORE_COMMIT:
        raise ValueError("ORDER-316: exact product predecessor drifted")
    changed = _git("diff", "--name-status", "-z", BEFORE_COMMIT, AFTER_COMMIT).split(b"\0")
    expected = [part for path in sorted(PATHS) for part in (b"M", path.encode())] + [b""]
    if changed != expected:
        raise ValueError("ORDER-316: exact two-file product population drifted")


def _function_blocks(raw: bytes) -> tuple[bytes, dict[str, bytes]]:
    matches = list(re.finditer(rb"(?m)^(?:static )?func (\w+)\b", raw))
    blocks: dict[str, bytes] = {}
    for index, match in enumerate(matches):
        name = match[1].decode("ascii")
        if name in blocks:
            raise ValueError("ORDER-316: duplicate function owner " + name)
        end = matches[index + 1].start() if index + 1 < len(matches) else len(raw)
        blocks[name] = raw[match.start():end]
    return raw[:matches[0].start()] if matches else raw, blocks


def _verify_header_scope(before: bytes, after: bytes, relative: str) -> None:
    if relative not in PATHS:
        raise ValueError("ORDER-316: unregistered header path " + relative)
    old_prefix, old = _function_blocks(before)
    new_prefix, new = _function_blocks(after)
    added = set(new) - set(old)
    changed = {name for name in old if old[name] != new.get(name)}
    if (old_prefix != new_prefix or added != ADDED_FUNCTIONS[relative]
            or changed != CHANGED_FUNCTIONS[relative]
            or [name for name in new if name not in added] != list(old)):
        raise ValueError("ORDER-316: source exceeds declared header functions " + relative)
    if relative == STORY_PATH:
        # _build_ui also owns body/choices. Even that function may differ only
        # from the existing header-construction marker onward.
        marker = "\t# 10. 얇은 상단 HUD".encode("utf-8")
        if (old["_build_ui"].count(marker) != 1 or new["_build_ui"].count(marker) != 1
                or old["_build_ui"].split(marker)[0] != new["_build_ui"].split(marker)[0]):
            raise ValueError("ORDER-316: non-header UI construction drifted")


def _verify_transition(before: bytes, after: bytes, relative: str) -> None:
    if relative not in FILE_HASHES or (_sha(before), _sha(after)) != FILE_HASHES[relative]:
        raise ValueError("ORDER-316: immutable source byte hashes drifted " + relative)
    _verify_header_scope(before, after, relative)


@functools.lru_cache(maxsize=2)
def verified_blobs(relative: str) -> tuple[bytes, bytes]:
    if relative not in PATHS:
        raise ValueError("ORDER-316: unregistered transition path " + relative)
    _verify_git_registration()
    before = _git_blob(BEFORE_COMMIT, relative)
    after = _git_blob(AFTER_COMMIT, relative)
    _verify_transition(before, after, relative)
    if relative == CONTROLLER_PATH and previous.source_errors(before, relative):
        raise ValueError("ORDER-316: controller predecessor does not bind to ORDER-310")
    return before, after


def inverse_316_bytes(raw: bytes, relative: str) -> bytes:
    if relative not in FILE_HASHES or _sha(raw) != FILE_HASHES[relative][1]:
        return raw
    try:
        before, after = verified_blobs(relative)
    except (OSError, ValueError):
        return raw
    return before if raw == after else raw


def inverse_316_hash(digest: str, relative: str) -> str:
    if relative in FILE_HASHES and digest == FILE_HASHES[relative][1]:
        try:
            before, after = verified_blobs(relative)
        except (OSError, ValueError):
            return digest
        if inverse_316_bytes(after, relative) == before:
            return _sha(before)
    return digest


def project_bytes(raw: bytes, relative: str) -> bytes:
    return previous.project_bytes(inverse_316_bytes(raw, relative), relative)


def project_byte_hash(digest: str, relative: str) -> str:
    return previous.project_byte_hash(inverse_316_hash(digest, relative), relative)


def source_errors(raw: bytes, relative: str) -> list[str]:
    if relative not in PATHS:
        return previous.source_errors(raw, relative)
    try:
        before, after = verified_blobs(relative)
    except (OSError, ValueError) as exc:
        return [str(exc)]
    if raw != after:
        return ["ORDER-316: live source exceeds exact header successor " + relative]
    if inverse_316_bytes(raw, relative) != before:
        return ["ORDER-316: exact header inverse failed " + relative]
    return []


def current_source_errors(root: Path = ROOT) -> list[str]:
    errors: list[str] = []
    for relative in LIVE_PATHS:
        try:
            errors.extend(source_errors((root / relative).read_bytes(), relative))
        except OSError as exc:
            errors.append(f"ORDER-316: current source unavailable {relative}: {exc}")
    return errors


def observed_byte_hash(relative: str, observed: str, raw: bytes) -> tuple[str, list[str]]:
    """Keep legacy observation pins, but bind each live claim to its raw bytes."""
    if relative not in PATHS:
        return observed, []
    errors = source_errors(raw, relative)
    if _sha(raw) != observed:
        errors.append("ORDER-316: observed hash is not bound to raw current bytes " + relative)
    return (observed if errors else inverse_316_hash(observed, relative)), errors


def self_test() -> tuple[list[str], int]:
    from unittest import mock

    failures: list[str] = []
    cases = 0

    def check(ok: bool, label: str) -> None:
        nonlocal cases
        cases += 1
        if not ok:
            failures.append(label)

    def rejected(callable_, label: str) -> None:
        try:
            callable_()
        except (OSError, ValueError):
            check(True, label)
        else:
            check(False, label)

    check(len(PATHS) == 2 and len(LIVE_PATHS) == 8, "exact two-successor/eight-live population")
    for relative in PATHS:
        before, after = verified_blobs(relative)
        old_hash, new_hash = FILE_HASHES[relative]
        check(not source_errors(after, relative), relative + " live admission")
        check(inverse_316_bytes(after, relative) == before, relative + " byte inverse")
        check(inverse_316_hash(new_hash, relative) == old_hash, relative + " hash inverse")
        check(project_bytes(after, relative) == previous.project_bytes(before, relative),
              relative + " composed byte inverse")
        check(project_byte_hash(new_hash, relative) == previous.project_byte_hash(old_hash, relative),
              relative + " composed hash inverse")
        check(observed_byte_hash(relative, new_hash, after) == (old_hash, []),
              relative + " raw-bound observation")
        check(bool(observed_byte_hash(relative, old_hash, after)[1]), relative + " unbound hash rejected")
        for label, candidate_path, candidate in (
            ("rollback", relative, before),
            ("wrong path", relative + ".other", after),
            ("swapped path", next(path for path in PATHS if path != relative), after),
            ("extra bytes", relative, after + b"\n"),
            ("missing bytes", relative, b""),
            ("neighbor", relative, after.replace(b"GameState.", b"OtherState.", 1)),
            ("header mutation", relative, after.replace(b"0.025", b"0.026", 1)),
        ):
            check(bool(source_errors(candidate, candidate_path))
                  and inverse_316_bytes(candidate, candidate_path) == candidate
                  and inverse_316_hash(_sha(candidate), candidate_path) == _sha(candidate),
                  relative + " rejects/preserves " + label)
        rejected(lambda: _verify_header_scope(before, after + b"\n", relative),
                 relative + " function-boundary neighbor rejected")
        if relative == STORY_PATH:
            rejected(lambda: _verify_header_scope(before, after.replace(
                b"_bg_img = TextureRect.new()", b"_bg_img = Control.new()", 1), relative),
                "non-header _build_ui prefix rejected")
        for label, replacement in (
            ("missing proof", mock.Mock(side_effect=OSError("missing immutable proof"))),
            ("altered proof", lambda commit, path: _git("show", f"{commit}:{path}") + b"\n"),
        ):
            verified_blobs.cache_clear()
            with mock.patch(__name__ + "._git_blob", replacement):
                check(bool(source_errors(after, relative))
                      and inverse_316_bytes(after, relative) == after
                      and inverse_316_hash(new_hash, relative) == new_hash,
                      relative + " fail-closed " + label)
            verified_blobs.cache_clear()
    for label, reply in (("wrong parent", b"0" * 40 + b"\n"),
                         ("missing file population", BEFORE_COMMIT.encode() + b"\n")):
        with mock.patch(__name__ + "._git", return_value=reply):
            rejected(_verify_git_registration, label)
    caller_failures, caller_cases = _live_caller_self_tests()
    return failures + caller_failures, cases + caller_cases


def _live_caller_self_tests() -> tuple[list[str], int]:
    """Execute only the three affected static caller boundaries, not full suites."""
    import importlib
    from unittest import mock

    live = importlib.import_module("order316_header_source_compat")
    chapter5 = importlib.import_module("chapter5_human_reject_audit")
    year5 = importlib.import_module("year5_reference_route_audit")
    chapter1 = importlib.import_module("chapter1_core_loop_v2_causal_ledger_check")
    model = chapter5._load_model()
    failures: list[str] = []
    cases = 0

    def check(ok: bool, label: str) -> None:
        nonlocal cases
        cases += 1
        if not ok:
            failures.append("live caller: " + label)

    def run_boundaries() -> tuple[list[str], list[str], list[str]]:
        chapter5_errors: list[str] = []
        chapter5.validate_preserved_product_boundaries(model, chapter5_errors)
        year5_errors: list[str] = []
        year5.validate_order156_registration(year5_errors)
        chapter1_errors = chapter1._audited_source_snapshot_errors({
            STORY_PATH: chapter1.EXPECTED_AUDITED_SOURCE_FILE_SHA256[STORY_PATH]})
        return chapter5_errors, year5_errors, chapter1_errors

    for name, errors in zip(("chapter5", "year5", "chapter1"), run_boundaries()):
        check(not errors, name + " exact successor: " + "; ".join(errors))
    story_before, story_after = live.verified_blobs(STORY_PATH)
    controller_before, controller_after = live.verified_blobs(CONTROLLER_PATH)
    check(year5.order156_project_bytes(story_after, STORY_PATH)
          == year5.order156_baseline_bytes(STORY_PATH), "year5 full Story byte projection")
    check(year5.order156_project_byte_hash(_sha(story_after), STORY_PATH)
          == year5.ORDER156_SOURCE_FILE_TRANSITIONS[STORY_PATH][0], "year5 full Story hash projection")
    check(FILE_HASHES[STORY_PATH][0] == year5.ORDER156_SOURCE_FILE_TRANSITIONS[STORY_PATH][1],
          "unchanged ORDER-156 Story successor pin")
    check(FILE_HASHES[CONTROLLER_PATH][0] == previous.FILE_HASHES[CONTROLLER_PATH][1],
          "unchanged ORDER-310 controller successor pin")
    real_read_bytes = Path.read_bytes
    for label, relative, raw in (
        ("Story rollback", STORY_PATH, story_before),
        ("Story neighbor", STORY_PATH, story_after.replace(b"GameState.", b"OtherState.", 1)),
        ("controller rollback", CONTROLLER_PATH, controller_before),
        ("controller neighbor", CONTROLLER_PATH, controller_after + b"\n"),
    ):
        def read_bytes(path: Path) -> bytes:
            return raw if path == ROOT / relative else real_read_bytes(path)

        with mock.patch.object(Path, "read_bytes", read_bytes):
            boundaries = run_boundaries()
        # Year5 registration reads Story only; its root validator owns the
        # controller's latest admission. Test that exact root entry separately.
        for name, errors in zip(("chapter5", "year5", "chapter1"), boundaries):
            if name == "year5" and relative == CONTROLLER_PATH:
                with mock.patch.object(Path, "read_bytes", read_bytes):
                    errors, _ = year5.validate_manifest(None, year5.AuditContext({}, []))
                check(any("ORDER-316:" in error for error in errors), name + " rejects " + label)
            else:
                check(bool(errors), name + " rejects " + label)
    for label, proof in (
        ("missing immutable proof", mock.Mock(side_effect=OSError("missing proof"))),
        ("altered immutable proof", lambda commit, path: _git("show", f"{commit}:{path}") + b"\n"),
    ):
        live.verified_blobs.cache_clear()
        with mock.patch.object(live, "_git_blob", proof):
            for name, errors in zip(("chapter5", "year5", "chapter1"), run_boundaries()):
                check(bool(errors), name + " rejects " + label)
        live.verified_blobs.cache_clear()
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
        print("ORDER316_HEADER_SOURCE_ERROR " + error)
    print(f"ORDER316_HEADER_SOURCE_{'FAIL' if errors else 'OK'} files=2 live_files=8 cases={cases}")
    return int(bool(errors))


if __name__ == "__main__":
    raise SystemExit(main())
