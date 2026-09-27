#!/usr/bin/env python3
"""Current ORDER-309 admission, with a separate exact historical comparison view.

Seven JSON files / seventeen text leaves and nine existing localization receipts
are bound to immutable Git bytes. Only four KO/EN files / eight leaves are
inverted for historical comparisons. The three prepared-language Hyunsu files
and current receipt ledger are never projected. Older 305/310/316 modules and
their fixtures retain their original meanings, including their old CLI limits.
"""

from __future__ import annotations

import argparse
import copy
import contextlib
import contextvars
import functools
import hashlib
import json
import re
import subprocess
from pathlib import Path
from typing import Any

import order305_demo_source_compat as original305
import order310_demo_source_compat as original310
import order316_header_source_compat as previous

ROOT = Path(__file__).resolve().parents[1]
BEFORE_COMMIT = "7717fd7f72b04c40d684a8c27c6e93cc546bda4c"
AFTER_COMMIT = "506e4c8ff6e4bf9265706845b4994b6203a05533"
KO_PATH = "content/events/arc_hyunsu.json"
EN_PATH = "content/events_en/arc_hyunsu.json"
MIDGAME_PATH = "content/events_en/arc_midgame.json"
CORE_PATH = "content/events_en/core_loop_v2_events.json"
LEDGER_PATH = "content/meta/full_game_localization.json"
LOCALE_PATHS = {locale: f"content/events_{locale}/arc_hyunsu.json"
                for locale in ("ja", "zh-CN", "zh-TW")}
HYUNSU_LEAVES = (
    ("hyunsu_result_fail", ("description",)),
    ("hyunsu_result_pass", ("description",)),
    ("hyunsu_result_fail", ("choices", 1, "result_text")),
)
JSON_LEAVES = {
    KO_PATH: HYUNSU_LEAVES,
    EN_PATH: HYUNSU_LEAVES,
    MIDGAME_PATH: (("arc_goshiwon_goodbye", ("choices", 2, "result_text")),),
    CORE_PATH: (("v2_jaehyuk_plain_reunion_echo", ("choices", 0, "result_text")),),
}
PATHS = tuple(JSON_LEAVES)
CURRENT_JSON_LEAVES = {**JSON_LEAVES,
                       **{path: HYUNSU_LEAVES for path in LOCALE_PATHS.values()}}
FILE_HASHES = {
    KO_PATH: ("59957c5b85d47766acaff942e95e4499b76c5a60b1db93fc20a56761f1e88d4b",
              "2449594b27187c761db5d94784c5caa0b57c61fa6eb1bdc3e619fc62971a49ca"),
    EN_PATH: ("5e79949d295cf3b7f16b29f1ca7b0de130cfd9c291e7e6a0f5bd719622e391cc",
              "3df4481d5e00fd578019d99dbb23e58821a27c665e4ffd7e1ec6db8b47611069"),
    MIDGAME_PATH: ("a2feade9647a8fbd5ae50c6c3ab28e1df65687ffad91ea88e5b222098674f682",
                   "b3adbc2d2e92e48564557931c05d58f09b3fd71e9e9d9997b872cae3a44eba02"),
    CORE_PATH: ("fc24d9810a65b7cfe824dddc6fe6413820d24fb974442f090f8c0593d9e8c601",
                "0f87d6f554563c776a5922e7126d5c3cd95f6924f1ad774b871c9fb0d5e5657a"),
    LOCALE_PATHS["ja"]: ("ea8341d1725731e28758db47db1ffb736f3214f8841d3a0c04639f9fbae7e6e7",
                          "852d611078d624ae8fd0c5f06cc7fe883ec83ba8a06c127cddf3cc0e8454c57f"),
    LOCALE_PATHS["zh-CN"]: ("590396191dcd8bd4f25ae906e9e15ccc8620caa4e1a776cf7f231cbbfcc6f569",
                             "92fb3f2f9fbd674d0d21d94441131336442fbd4a66f92baa9a473007c08a6832"),
    LOCALE_PATHS["zh-TW"]: ("8e4dc1d23f6cb919ecb63051d0e57425a67407fb0273f6fc016c12ee8362c583",
                             "39ea586335494400eda3f98a8dea909893d3b59a901ef253ce57d9db0554c064"),
    LEDGER_PATH: ("42259f829b69f04346c772c41965bdef5856f142e1e63a47c67b90889c3d283b",
                  "4a80832391bce8f0fced8e28ba3d9c5fd03e4b219ec6dab38d4ee6963fcccf35"),
}
CURRENT_PATHS = tuple(FILE_HASHES)
LIVE_PATHS = tuple(dict.fromkeys((*previous.LIVE_PATHS, *CURRENT_PATHS)))
LIVE_EVENT_IDS = {
    path: frozenset(original310.LIVE_EVENT_IDS.get(path, ()))
    | frozenset(leaf[0] for leaf in CURRENT_JSON_LEAVES.get(path, ()))
    for path in LIVE_PATHS if path.endswith(".json") and path != LEDGER_PATH
}
RECEIPT_IDS = tuple(f"events:{event_id}:/" + "/".join(map(str, path))
                    for event_id, path in HYUNSU_LEAVES)
TOKEN_RE = re.compile(r"\{[^{}]*\}|%(?:\d+\$)?[sdif]|\[/?(?:b|i|color)[^\]]*\]")
_ACTIVE_PROOF: contextvars.ContextVar[dict[tuple[str, str], bytes] | None] = contextvars.ContextVar(
    "order309_active_git_proof", default=None)


def _sha(raw: bytes) -> str:
    return hashlib.sha256(raw).hexdigest()


def _canonical(value: Any) -> bytes:
    return json.dumps(value, ensure_ascii=False, sort_keys=True,
                      separators=(",", ":"), allow_nan=False).encode("utf-8")


def _digest(value: Any) -> str:
    return _sha(_canonical(value))


def _loads(raw: bytes) -> Any:
    # Keep the original strict duplicate/nonfinite parser; no permissive reload.
    return original305._loads(raw)


def _git(*args: str) -> bytes:
    result = subprocess.run(("git", *args), cwd=ROOT, capture_output=True)
    if result.returncode:
        raise ValueError("ORDER-309: immutable Git proof unavailable: " + " ".join(args))
    return result.stdout


def _git_blob(revision: str, relative: str) -> bytes:
    snapshot = _ACTIVE_PROOF.get()
    if snapshot is not None and (revision, relative) in snapshot:
        return snapshot[revision, relative]
    return _git("show", f"{revision}:{relative}")


def _verify_git_registration() -> None:
    if _git("rev-parse", AFTER_COMMIT + "^").decode().strip() != BEFORE_COMMIT:
        raise ValueError("ORDER-309: exact product predecessor drifted")
    actual = _git("diff", "--name-status", "-z", BEFORE_COMMIT, AFTER_COMMIT).split(b"\0")
    expected = [part for path in sorted(CURRENT_PATHS) for part in (b"M", path.encode())] + [b""]
    if actual != expected:
        raise ValueError("ORDER-309: exact seven-JSON/one-ledger population drifted")


@contextlib.contextmanager
def _fresh_proof(paths: tuple[str, ...]):
    """One fresh bulk Git read per public guard, never a cross-call proof cache."""
    _verify_git_registration()
    if LEDGER_PATH in paths:
        paths = tuple(dict.fromkeys((*paths, KO_PATH, *LOCALE_PATHS.values())))
    requests = [(revision, path) for path in paths for revision in (BEFORE_COMMIT, AFTER_COMMIT)]
    query = "".join(f"{revision}:{path}\n" for revision, path in requests).encode()
    result = subprocess.run(("git", "cat-file", "--batch"), cwd=ROOT, input=query, capture_output=True)
    if result.returncode:
        raise ValueError("ORDER-309: bulk immutable Git proof unavailable")
    cursor = 0
    blobs: dict[tuple[str, str], bytes] = {}
    for request in requests:
        end = result.stdout.find(b"\n", cursor)
        header = result.stdout[cursor:end].split()
        if (end < cursor or len(header) != 3 or not re.fullmatch(rb"[0-9a-f]{40}", header[0])
                or header[1] != b"blob" or not header[2].isdigit()):
            raise ValueError("ORDER-309: missing/malformed immutable blob " + ":".join(request))
        size = int(header[2])
        cursor = end + 1
        if result.stdout[cursor + size:cursor + size + 1] != b"\n":
            raise ValueError("ORDER-309: incomplete immutable blob " + ":".join(request))
        blobs[request] = result.stdout[cursor:cursor + size]
        cursor += size + 1
    if cursor != len(result.stdout):
        raise ValueError("ORDER-309: unexpected bulk Git proof trailing bytes")
    token = _ACTIVE_PROOF.set(blobs)
    try:
        yield
    finally:
        _ACTIVE_PROOF.reset(token)


@contextlib.contextmanager
def fresh_validation_proof():
    """Share one fresh Git snapshot within ONE validation invocation only.

    Nested calls reuse that invocation's immutable snapshot. Normal and
    exceptional exits restore the previous context; the next outer invocation
    always reads Git again. Never wrap a complete mutation corpus or multiple
    validation invocations in this scope.
    """
    if _ACTIVE_PROOF.get() is not None:
        yield
    else:
        with _fresh_proof(CURRENT_PATHS):
            yield


def _rows(payload: Any) -> dict[str, dict[str, Any]]:
    if not isinstance(payload, list):
        raise ValueError("ORDER-309: expected complete event array")
    rows: dict[str, dict[str, Any]] = {}
    for row in payload:
        if (not isinstance(row, dict) or not isinstance(row.get("id"), str)
                or not row["id"] or row["id"] in rows):
            raise ValueError("ORDER-309: missing/duplicate event identity")
        rows[row["id"]] = row
    return rows


def _leaf(row: Any, path: tuple[str | int, ...]) -> Any:
    for key in path:
        row = row[key]
    return row


def _set_leaf(row: Any, path: tuple[str | int, ...], value: Any) -> None:
    for key in path[:-1]:
        row = row[key]
    row[path[-1]] = value


def _verify_json_delta(before: bytes, after: bytes, relative: str) -> None:
    if relative not in CURRENT_JSON_LEAVES:
        raise ValueError("ORDER-309: unregistered text path " + relative)
    old, new = _loads(before), _loads(after)
    expected = copy.deepcopy(old)
    old_rows, new_rows = _rows(expected), _rows(new)
    expected_raw = before
    for event_id, path in CURRENT_JSON_LEAVES[relative]:
        if event_id not in old_rows or event_id not in new_rows:
            raise ValueError("ORDER-309: declared event missing " + event_id)
        old_text, new_text = _leaf(old_rows[event_id], path), _leaf(new_rows[event_id], path)
        if not isinstance(old_text, str) or not isinstance(new_text, str) or old_text == new_text:
            raise ValueError("ORDER-309: declared leaf is not a text delta " + event_id)
        if (old_text.count("\n") != new_text.count("\n")
                or TOKEN_RE.findall(old_text) != TOKEN_RE.findall(new_text)):
            raise ValueError("ORDER-309: newline/token preservation drifted " + event_id)
        old_literal = json.dumps(old_text, ensure_ascii=False).encode("utf-8")
        new_literal = json.dumps(new_text, ensure_ascii=False).encode("utf-8")
        if expected_raw.count(old_literal) != 1:
            raise ValueError("ORDER-309: complete leaf literal is not unique " + event_id)
        expected_raw = expected_raw.replace(old_literal, new_literal, 1)
        _set_leaf(old_rows[event_id], path, new_text)
    if _canonical(expected) != _canonical(new) or expected_raw != after:
        raise ValueError("ORDER-309: source exceeds exact declared leaves " + relative)


def _receipt_for(rows: dict[str, Any], targets: dict[str, Any],
                 event_id: str, path: tuple[str | int, ...]) -> dict[str, str]:
    return {"source_sha256": _digest({"path": KO_PATH, "field": path,
                                     "ko": _leaf(rows[event_id], path)}),
            "target_sha256": _digest(_leaf(targets[event_id], path))}


def _verify_receipt_delta(before: bytes, after: bytes,
                          texts: dict[str, tuple[bytes, bytes]]) -> None:
    old, new = _loads(before), _loads(after)
    allowed = {"accepted", "accepted_sha256", "batches"}
    if (list(old) != list(new) or {k: v for k, v in old.items() if k not in allowed}
            != {k: v for k, v in new.items() if k not in allowed}):
        raise ValueError("ORDER-309: receipt non-owned metadata drifted")
    if (len(old["batches"]) != 136 or len(new["batches"]) != 137
            or new["batches"][:-1] != old["batches"]):
        raise ValueError("ORDER-309: prior receipt history changed")
    batch = new["batches"][-1]
    if (batch.get("order") != "ORDER-309" or batch.get("group") != "events"
            or batch.get("roots") != ["hyunsu_result_fail", "hyunsu_result_pass"]
            or batch.get("source_leaves") != 3
            or batch.get("target_leaves_by_locale") != {locale: 3 for locale in LOCALE_PATHS}
            or batch.get("added_accepted_leaves") != 0
            or batch.get("revalidated_existing_leaves") is not True
            or batch.get("native_review") != "OPEN" or batch.get("rendered_review") != "OPEN"):
        raise ValueError("ORDER-309: bounded revalidation receipt batch drifted")
    if list(old["accepted"]) != list(new["accepted"]) or set(new["accepted"]) != set(LOCALE_PATHS):
        raise ValueError("ORDER-309: receipt locale population drifted")
    ko = [_rows(_loads(raw)) for raw in texts[KO_PATH]]
    for locale, relative in LOCALE_PATHS.items():
        targets = [_rows(_loads(raw)) for raw in texts[relative]]
        prior, current = old["accepted"][locale], new["accepted"][locale]
        changed = {key for key in prior if prior[key] != current.get(key)}
        if list(prior) != list(current) or changed != set(RECEIPT_IDS):
            raise ValueError("ORDER-309: expected exactly three existing receipts " + locale)
        for (event_id, path), receipt_id in zip(HYUNSU_LEAVES, RECEIPT_IDS):
            for index, records in enumerate((prior, current)):
                if records[receipt_id] != _receipt_for(ko[index], targets[index], event_id, path):
                    raise ValueError("ORDER-309: stale source/wrong target receipt " + locale + ":" + receipt_id)
    for ledger in (old, new):
        if (sum(len(rows) for rows in ledger["accepted"].values()) != 40299
                or ledger["accepted_sha256"] != _digest(ledger["accepted"])):
            raise ValueError("ORDER-309: receipt total/checksum drifted")


@functools.lru_cache(maxsize=8)
def _verify_transition(before: bytes, after: bytes, relative: str,
                       receipt_texts: tuple[tuple[str, bytes, bytes], ...] = ()) -> None:
    # Only pure verification is cached by actual bytes. Git access is NEVER
    # cached: a warmed process still rejects unavailable/altered immutable proof.
    if relative not in FILE_HASHES or (_sha(before), _sha(after)) != FILE_HASHES[relative]:
        raise ValueError("ORDER-309: immutable byte hashes drifted " + relative)
    if relative == LEDGER_PATH:
        _verify_receipt_delta(before, after, {p: (a, b) for p, a, b in receipt_texts})
    else:
        _verify_json_delta(before, after, relative)


def verified_blobs(relative: str) -> tuple[bytes, bytes]:
    """Fresh Git proof; returns immutable before/after for one of eight paths."""
    if relative not in CURRENT_PATHS:
        raise ValueError("ORDER-309: unregistered transition path " + relative)
    if _ACTIVE_PROOF.get() is None:
        with _fresh_proof((relative,)):
            return verified_blobs(relative)
    before, after = _git_blob(BEFORE_COMMIT, relative), _git_blob(AFTER_COMMIT, relative)
    receipt_texts = ()
    if relative == LEDGER_PATH:
        receipt_texts = tuple((p, *verified_blobs(p)) for p in (KO_PATH, *LOCALE_PATHS.values()))
    _verify_transition(before, after, relative, receipt_texts)
    if relative == CORE_PATH and previous.source_errors(before, relative):
        raise ValueError("ORDER-309: core predecessor does not bind to ORDER-316/310")
    return before, after


def inverse_309_bytes(raw: bytes, relative: str) -> bytes:
    if relative not in PATHS or _sha(raw) != FILE_HASHES[relative][1]:
        return raw
    try:
        before, after = verified_blobs(relative)
    except (OSError, ValueError):
        return raw
    return before if raw == after else raw


def _inverse_payload(payload: Any, relative: str, blobs: tuple[bytes, bytes]) -> Any:
    projected = copy.deepcopy(payload)
    if not isinstance(projected, list):
        return projected
    try:
        rows = _rows(projected)
        old, new = (_rows(_loads(raw)) for raw in blobs)
        for event_id in dict.fromkeys(leaf[0] for leaf in JSON_LEAVES[relative]):
            if event_id not in rows or _canonical(rows[event_id]) != _canonical(new[event_id]):
                continue
            for owner, path in JSON_LEAVES[relative]:
                if owner == event_id:
                    _set_leaf(rows[event_id], path, _leaf(old[event_id], path))
    except (ValueError, TypeError, KeyError, IndexError):
        return copy.deepcopy(payload)
    return projected


def inverse_309_payload(payload: Any, relative: str) -> Any:
    """Copy/invert only complete exact event objects, including singleton lists.

    This is NOT admission. Callers must bind their complete live raw source and
    observed event indexes separately; mutations and untouched neighbors survive.
    """
    if (relative not in PATHS or not isinstance(payload, list)
            or not any(isinstance(row, dict) and row.get("id") in
                       {leaf[0] for leaf in JSON_LEAVES[relative]} for row in payload)):
        return copy.deepcopy(payload)
    try:
        return _inverse_payload(payload, relative, verified_blobs(relative))
    except (OSError, ValueError):
        return copy.deepcopy(payload)


def inverse_309_hash(digest: str, relative: str) -> str:
    if relative in PATHS and digest == FILE_HASHES[relative][1]:
        try:
            before, after = verified_blobs(relative)
        except (OSError, ValueError):
            return digest
        if _sha(after) == digest:
            return _sha(before)
    return digest


def project_bytes(raw: bytes, relative: str) -> bytes:
    if relative in PATHS:
        try:
            before, after = verified_blobs(relative)
        except (OSError, ValueError):
            return raw
        raw = before if raw == after else raw
    return previous.project_bytes(raw, relative)


def project_payload(payload: Any, relative: str) -> Any:
    if (relative in PATHS and isinstance(payload, list)
            and any(isinstance(row, dict) and row.get("id") in
                    {leaf[0] for leaf in JSON_LEAVES[relative]} for row in payload)):
        try:
            payload = _inverse_payload(payload, relative, verified_blobs(relative))
        except (OSError, ValueError):
            return copy.deepcopy(payload)
    # ORDER-316 owns GDScript headers, not JSON. Its JSON chain is ORDER-310.
    return original310.project_payload(payload, relative)


def project_byte_hash(digest: str, relative: str) -> str:
    if relative in PATHS:
        try:
            before, after = verified_blobs(relative)
        except (OSError, ValueError):
            return digest
        digest = _sha(before) if digest == _sha(after) else digest
    return previous.project_byte_hash(digest, relative)


def source_errors(raw: bytes, relative: str) -> list[str]:
    """Admit exact latest bytes; rollback/projection is never live admission."""
    if relative not in CURRENT_PATHS:
        return previous.source_errors(raw, relative)
    if _sha(raw) != FILE_HASHES[relative][1]:
        return ["ORDER-309: current source exceeds exact approved successor " + relative]
    try:
        _before, after = verified_blobs(relative)
    except (OSError, ValueError) as exc:
        return [str(exc)]
    return [] if raw == after else ["ORDER-309: raw source differs from immutable proof " + relative]


def current_source_errors(root: Path = ROOT) -> list[str]:
    errors: list[str] = []
    try:
        with fresh_validation_proof():
            for relative in LIVE_PATHS:
                try:
                    errors.extend(source_errors((root / relative).read_bytes(), relative))
                except OSError as exc:
                    errors.append(f"ORDER-309: current source unavailable {relative}: {exc}")
    except (OSError, ValueError) as exc:
        errors.append(str(exc))
    return errors


def source_observation_errors(raw: bytes, payload: Any, relative: str) -> list[str]:
    """Bind a full parsed observation to admitted raw JSON (not a subset view)."""
    errors = source_errors(raw, relative)
    try:
        if _canonical(_loads(raw)) != _canonical(payload):
            errors.append("ORDER-309: observed payload is not bound to raw current bytes " + relative)
    except (ValueError, TypeError, UnicodeError):
        errors.append("ORDER-309: malformed raw/payload observation " + relative)
    return errors


def observed_byte_hash(relative: str, observed: str, raw: bytes) -> tuple[str, list[str]]:
    """Raw-bound observation, undoing this successor only before older callers."""
    errors = source_errors(raw, relative)
    if _sha(raw) != observed:
        errors.append("ORDER-309: observed hash is not bound to raw current bytes " + relative)
    if errors:
        return observed, errors
    if relative in PATHS:
        return inverse_309_hash(observed, relative), []
    return previous.observed_byte_hash(relative, observed, raw)


def self_test() -> tuple[list[str], int]:
    """Bounded positive/negative source, projection, receipt and proof corpus."""
    from unittest import mock

    failures: list[str] = []
    cases = 0

    def check(ok: bool, label: str) -> None:
        nonlocal cases
        cases += 1
        if not ok:
            failures.append(label)

    def rejected(call, label: str) -> None:
        try:
            call()
        except (ValueError, OSError, KeyError, IndexError, TypeError):
            check(True, label)
        else:
            check(False, label)

    check(len(PATHS) == 4 and sum(map(len, JSON_LEAVES.values())) == 8
          and len(CURRENT_JSON_LEAVES) == 7
          and sum(map(len, CURRENT_JSON_LEAVES.values())) == 17
          and len(CURRENT_PATHS) == 8 and len(LIVE_PATHS) == 15,
          "exact historical4/8 current7/17 ledger1 live15 population")
    check(not current_source_errors(), "latest whole-source admission")
    all_blobs = {path: verified_blobs(path) for path in CURRENT_PATHS}
    for relative, (before, after) in all_blobs.items():
        old, new = _loads(before), _loads(after)
        check(not source_errors(after, relative), relative + " raw admission")
        check(not source_observation_errors(after, new, relative), relative + " raw/payload binding")
        check(bool(source_observation_errors(after, old, relative)), relative + " stale payload rejected")
        check(bool(observed_byte_hash(relative, _sha(before), after)[1]), relative + " stale observed hash rejected")
        check(bool(observed_byte_hash(relative, "0" * 64, after)[1]), relative + " forged observed hash rejected")
        for label, path, raw in (
            ("rollback", relative, before), ("wrong path", relative + ".other", after),
            ("swapped path", next(p for p in CURRENT_PATHS if p != relative), after),
            ("trailing byte", relative, after + b"\n"), ("missing raw", relative, b""),
            ("duplicate key", relative, after.replace(b'"id":', b'"id":"duplicate", "id":', 1)
             if relative != LEDGER_PATH else after.replace(b'"accepted":', b'"accepted":{}, "accepted":', 1)),
        ):
            check(bool(source_errors(raw, path)) and inverse_309_bytes(raw, path) == raw
                  and inverse_309_hash(_sha(raw), path) == _sha(raw), relative + " rejects " + label)
        if relative not in PATHS:
            check(inverse_309_bytes(after, relative) == after
                  and inverse_309_payload(new, relative) == new
                  and inverse_309_hash(_sha(after), relative) == _sha(after)
                  and project_bytes(after, relative) == after
                  and project_payload(new, relative) == new
                  and project_byte_hash(_sha(after), relative) == _sha(after),
                  relative + " never projects prepared target/receipt")
        else:
            check(inverse_309_bytes(after, relative) == before, relative + " exact byte inverse")
            check(inverse_309_hash(_sha(after), relative) == _sha(before), relative + " exact hash inverse")
            check(inverse_309_payload(new, relative) == old, relative + " exact payload inverse")
            check(project_bytes(after, relative) == previous.project_bytes(before, relative), relative + " byte chain")
            check(project_payload(new, relative) == original310.project_payload(old, relative), relative + " payload chain")
            check(project_byte_hash(_sha(after), relative) == previous.project_byte_hash(_sha(before), relative),
                  relative + " hash chain")
            saved = copy.deepcopy(new)
            check(inverse_309_payload(list(reversed(new)), relative) == list(reversed(old)) and new == saved,
                  relative + " copied projection preserves input/order")
        if relative in CURRENT_JSON_LEAVES:
            old_rows, new_rows = _rows(old), _rows(new)
            for event_id, path in CURRENT_JSON_LEAVES[relative]:
                row = new_rows[event_id]
                for label, value in (("mutation", "unapproved"), ("type", 309),
                                     ("partial rollback", _leaf(old_rows[event_id], path))):
                    mutated = copy.deepcopy(row)
                    _set_leaf(mutated, path, value)
                    mutant = copy.deepcopy(new)
                    mutant[mutant.index(row)] = mutated
                    raw = json.dumps(mutant, ensure_ascii=False, indent=2).encode() + b"\n"
                    check(bool(source_errors(raw, relative))
                          and inverse_309_payload([mutated], relative) == [mutated],
                          f"{relative}:{event_id}:{path} {label}")
            event_id = CURRENT_JSON_LEAVES[relative][0][0]
            row = new_rows[event_id]
            for label, field, value in (("neighbor prose", "title", "unapproved"),
                                         ("gameplay", "conditions", {"money": 1}),
                                         ("wrong ID", "id", "not_the_event")):
                mutated = copy.deepcopy(row)
                mutated[field] = value
                check(inverse_309_payload([mutated], relative) == [mutated], relative + " " + label)
            for label, payload in (("duplicate event", [row, copy.deepcopy(row)]),
                                    ("missing event", []), ("root type", {"events": new})):
                check(inverse_309_payload(payload, relative) == payload, relative + " " + label)
            neighbor = copy.deepcopy(new)
            untouched = next(r for r in neighbor if r["id"] not in LIVE_EVENT_IDS[relative])
            untouched["title"] += "!"
            check(_rows(project_payload(neighbor, relative))[untouched["id"]] == untouched,
                  relative + " unrelated neighbor stays visible")
            rejected(lambda: _verify_json_delta(before, after + b"\n", relative), relative + " byte scope")
        # Warm every successful path first, then remove/corrupt proof without
        # clearing caches. No stale successful verification may admit it.
        for label, proof in (("warm missing proof", mock.Mock(side_effect=OSError("missing proof"))),
                              ("warm altered proof", lambda rev, path: _git("show", f"{rev}:{path}") + b"\n")):
            verified_blobs(relative)
            with mock.patch(__name__ + "._git_blob", proof):
                check(bool(source_errors(after, relative))
                      and inverse_309_bytes(after, relative) == after
                      and inverse_309_payload(new, relative) == new
                      and inverse_309_hash(_sha(after), relative) == _sha(after)
                      and project_bytes(after, relative) == after
                      and project_payload(new, relative) == new
                      and project_byte_hash(_sha(after), relative) == _sha(after), relative + " " + label)
    ledger_old, ledger_new = all_blobs[LEDGER_PATH]
    ledger = _loads(ledger_new)
    text_blobs = {p: all_blobs[p] for p in (KO_PATH, *LOCALE_PATHS.values())}
    for locale in LOCALE_PATHS:
        for receipt_id in RECEIPT_IDS:
            for field in ("source_sha256", "target_sha256"):
                mutated = copy.deepcopy(ledger)
                mutated["accepted"][locale][receipt_id][field] = "0" * 64
                mutated["accepted_sha256"] = _digest(mutated["accepted"])
                rejected(lambda: _verify_receipt_delta(ledger_old, _canonical(mutated), text_blobs),
                         f"{locale}:{receipt_id} wrong {field} with repaired checksum")
    for label, mutate in (
        ("prior history", lambda x: x["batches"][0].update({"order": "forged"})),
        ("neighbor receipt", lambda x: x["accepted"]["ja"][next(k for k in x["accepted"]["ja"] if k not in RECEIPT_IDS)].update({"target_sha256": "0" * 64})),
        ("unowned ledger metadata", lambda x: x.update({"full_game_status": "GO"})),
    ):
        mutated = copy.deepcopy(ledger)
        mutate(mutated)
        rejected(lambda: _verify_receipt_delta(ledger_old, _canonical(mutated), text_blobs), label)
    real_git = _git
    for label, which, reply in (("wrong parent", "rev-parse", b"0" * 40 + b"\n"),
                                ("missing file population", "diff", b"")):
        def changed_git(*args: str) -> bytes:
            return reply if args[0] == which else real_git(*args)
        with mock.patch(__name__ + "._git", changed_git):
            rejected(_verify_git_registration, label)
            check(bool(source_errors(all_blobs[KO_PATH][1], KO_PATH)), label + " live rejection")
    # A single validation may share immutable proof, but separate tests and
    # validations must never inherit a prior invocation's successful snapshot.
    check(_ACTIVE_PROOF.get() is None, "scope begins without leaked proof")
    with mock.patch(__name__ + "._fresh_proof", wraps=_fresh_proof) as fresh_reads:
        with fresh_validation_proof():
            first_snapshot = _ACTIVE_PROOF.get()
            check(first_snapshot is not None and set(first_snapshot) == {
                (revision, path) for path in CURRENT_PATHS
                for revision in (BEFORE_COMMIT, AFTER_COMMIT)}, "scope binds all eight immutable file pairs")
            with fresh_validation_proof():
                check(_ACTIVE_PROOF.get() is first_snapshot, "nested validation shares same proof")
                check(not current_source_errors(), "nested current guard uses valid scope")
            check(fresh_reads.call_count == 1 and _ACTIVE_PROOF.get() is first_snapshot,
                  "nested guard neither reloads nor clears outer proof")
        check(_ACTIVE_PROOF.get() is None, "normal scope exit clears proof")
        with fresh_validation_proof():
            check(_ACTIVE_PROOF.get() is not first_snapshot and fresh_reads.call_count == 2,
                  "next outer validation reads fresh proof")
    try:
        with fresh_validation_proof():
            raise RuntimeError("intentional scope cleanup test")
    except RuntimeError:
        pass
    check(_ACTIVE_PROOF.get() is None, "exceptional scope exit clears proof")
    for label, proof in (("next scope missing proof", mock.Mock(side_effect=OSError("missing proof"))),
                          ("next scope altered proof", lambda rev, path: _git("show", f"{rev}:{path}") + b"\n")):
        with fresh_validation_proof():
            check(not source_errors(all_blobs[KO_PATH][1], KO_PATH), label + " warm predecessor scope")
        with mock.patch(__name__ + "._git_blob", proof):
            with fresh_validation_proof():
                check(bool(current_source_errors()), label + " rejected after successful prior scope")
        check(_ACTIVE_PROOF.get() is None, label + " rejected scope cleans up")
    with mock.patch(__name__ + "._git", side_effect=OSError("Git unavailable on next invocation")):
        check(bool(current_source_errors()), "next scope Git unavailable rejected before snapshot")
    check(_ACTIVE_PROOF.get() is None, "failed snapshot entry does not leak context")
    return failures, cases


def historical_self_test() -> tuple[list[str], int, list[dict[str, Any]]]:
    """Invoke unchanged original corpora, including ORDER-316 live callers.

    No patched fixture, function replacement, skipped assertion or filtered
    failure is used. The old modules' direct CLIs still perform their own older
    current-source admission; that is different from these original functions.
    """
    failures: list[str] = []
    results: list[dict[str, Any]] = []
    cases = 0
    for name, module in (("ORDER-305", original305), ("ORDER-310", original310), ("ORDER-316", previous)):
        errors, count = module.self_test()
        results.append({"corpus": name, "cases": count, "errors": errors})
        failures.extend(name + ": " + error for error in errors)
        cases += count
    return failures, cases, results


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    mode = parser.add_mutually_exclusive_group()
    mode.add_argument("--self-test", action="store_true")
    mode.add_argument("--historical-self-test", action="store_true")
    args = parser.parse_args()
    errors = current_source_errors()
    cases = 0
    if args.self_test:
        failures, cases = self_test()
        errors.extend(failures)
    if args.historical_self_test and not errors:
        failures, cases, results = historical_self_test()
        errors.extend(failures)
        for result in results:
            print("ORDER309_ORIGINAL_CORPUS " + json.dumps(result, ensure_ascii=False, sort_keys=True))
    for error in errors:
        print("ORDER309_SOURCE_ERROR " + error)
    marker = "ORDER309_HISTORICAL" if args.historical_self_test else "ORDER309_SOURCE"
    print(f"{marker}_{'FAIL' if errors else 'OK'} current_files=7 leaves=17 receipts=9 "
          f"historical_files=4 historical_leaves=8 live_files={len(LIVE_PATHS)} cases={cases}")
    return int(bool(errors))


if __name__ == "__main__":
    raise SystemExit(main())
