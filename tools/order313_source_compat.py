#!/usr/bin/env python3
"""Admit the exact ORDER-313/356 repair, then compare historical source views.

The live boundary is seven JSON files / twenty text leaves plus nine existing
receipts. Only four KO/EN files / eleven leaves are inverted for comparisons.
Prepared translations and the current ledger never become historical reports.
The immutable 309 -> 316 -> 310 -> 305 chain retains its original CLI meanings.
"""

from __future__ import annotations

import argparse
import contextlib
import contextvars
import copy
import functools
import hashlib
import json
import os
import re
import subprocess
import sys
import tempfile
from pathlib import Path
from typing import Any

import order309_source_compat as previous

ROOT = Path(__file__).resolve().parents[1]
BEFORE_COMMIT = "43f76f1bcd25665e765a7ddfff232020d837ca4f"
AFTER_COMMIT = "ac02dbc6a18126dda25e8fea8562faff18c1a365"
KO_PATH = "content/events/arc_events.json"
EN_PATH = "content/events_en/arc_events.json"
MIDGAME_PATH = "content/events_en/arc_midgame.json"
DAEUN_PATH = "content/events_en/arc_daeun.json"
LEDGER_PATH = "content/meta/full_game_localization.json"
LOCALE_PATHS = {locale: f"content/events_{locale}/arc_events.json"
                for locale in ("ja", "zh-CN", "zh-TW")}
SOURCE_LEAVES = (
    ("arc_sangchul_03_network", ("description",)),
    ("arc_father_04_visit", ("description",)),
    ("arc_father_04_visit", ("description_if_known", "arc_sangchul_03_seen")),
)
JSON_LEAVES = {
    KO_PATH: SOURCE_LEAVES,
    EN_PATH: (*SOURCE_LEAVES,
              ("arc_sangchul_03_network", ("choices", 0, "text")),
              ("arc_father_04_visit", ("choices", 0, "text"))),
    MIDGAME_PATH: (("arc_father_medication", ("description",)),
                   ("arc_father_medication", ("choices", 0, "result_text"))),
    DAEUN_PATH: (("arc_daeun_03_fork", ("choices", 1, "result_text")),),
}
PATHS = tuple(JSON_LEAVES)
CURRENT_JSON_LEAVES = {**JSON_LEAVES,
                       **{p: SOURCE_LEAVES for p in LOCALE_PATHS.values()}}
FILE_HASHES = {
    KO_PATH: ("ccd902447b46e10e02128d46ef273e65a30e3df9753b7f257f7fd9accb848f62",
              "4abc2a1e0b61ac4ba9d130aff5a47f696eea27dfdd841ec88f1f4449972768f6"),
    EN_PATH: ("1ecd0007956e0c880827d442bceb3d0459b971d46497db3545eca91e2f80d735",
              "0baf517023e2b922e003a028cd38c9468622879e30cdceb6a1700679ce81fcc4"),
    MIDGAME_PATH: ("b3adbc2d2e92e48564557931c05d58f09b3fd71e9e9d9997b872cae3a44eba02",
                   "5740e9bcb3013e7378c8f7b42e2b70f66efc1cb30f7eeecc933d16ad86ab8c35"),
    DAEUN_PATH: ("0a8be2becbe5a9c33b0a1ec5aed33dfa83f5c55d9bb3f94a5d5f79fe7cd652e2",
                 "0294a462856e7e884789adc27398a245f6cb5aa981ec4af8e6566a4ed25175ca"),
    LOCALE_PATHS["ja"]: ("31fc14e3172e8684de510c66f15f7ea37b1b9101e59026b2b780efcd4c2cd0ab",
                          "807db30f15b0bdcee0cc4cd4d3ea73de5db28f22cdb9958f5416dccabbcf9a99"),
    LOCALE_PATHS["zh-CN"]: ("7610d82061596c3336d26788725351326283f10cb2bb29a9a8a51ad8986b1e6b",
                             "366a883fe87eb5b2a4d01c8a19ec6d23ceba2a8e69fb4f4e336cae388016bfdd"),
    LOCALE_PATHS["zh-TW"]: ("5df838b414cdd294b5cdbf981ab3b9629c92706d96973d0fbe7025de9b7d5947",
                             "6f3d348350779de92d9ca226314ce19f4cdbe1dd0e3f4d83b40d9b086f3cb7f1"),
    LEDGER_PATH: ("4a80832391bce8f0fced8e28ba3d9c5fd03e4b219ec6dab38d4ee6963fcccf35",
                  "30ca5537b6457d1286522bbdda602f01c23ad6bce1c78d9f14e2dba45bce1ece"),
}
CURRENT_PATHS = tuple(FILE_HASHES)
LIVE_PATHS = tuple(dict.fromkeys((*previous.LIVE_PATHS, *CURRENT_PATHS)))
HISTORICAL_PATHS = tuple(dict.fromkeys((*previous.PATHS, *PATHS)))
HISTORICAL_JSON_LEAVES = {
    p: tuple(dict.fromkeys((*previous.JSON_LEAVES.get(p, ()), *JSON_LEAVES.get(p, ()))))
    for p in HISTORICAL_PATHS
}
LIVE_EVENT_IDS = {
    p: frozenset(previous.LIVE_EVENT_IDS.get(p, ()))
    | frozenset(event for event, _leaf_path in CURRENT_JSON_LEAVES.get(p, ()))
    for p in LIVE_PATHS if p.endswith(".json") and p != LEDGER_PATH
}
RECEIPT_IDS = tuple(f"events:{event}:/" + "/".join(map(str, path))
                    for event, path in SOURCE_LEAVES)
BATCH_HASHES = {
    "ORDER-313": "d21d73e9f576b9a05d8f5319ad61f8f729ee7666363f7e808fb6b7e1f6a7ed66",
    "ORDER-356": "4a916252f53274e5dd4e1fe0a7efe38f247d7d136aed9c7cabf0ebac30348b53",
}
MODULE_HASHES = {
    "tools/order305_demo_source_compat.py": "a6ba3bab8340df736eaf059abc7bb837ccf0474ea22ff66bda7c130619e09cad",
    "tools/order310_demo_source_compat.py": "c2a3208d5515fc70025c536b8069dd1e530ea047ed0fcfc77dc2ea0cad2572cd",
    "tools/order316_header_source_compat.py": "cb058c913bd3b0001e704c99a21a968ee9e8115bd64bcc41311bd4a84604a3c6",
    "tools/order309_source_compat.py": "d1775db6627e5363e3babd236904ed5057bcaf4788ea201faf4525617c91173d",
}
PRE313_LIVE_HASHES = {
    KO_PATH: FILE_HASHES[KO_PATH][0], EN_PATH: FILE_HASHES[EN_PATH][0],
    "content/events_ja/story_demo_events.json": "3ba992ecafbd5b31d00cb9c3630f4f6a9b37fefb41fbe6aba191d3d77076a10b",
    "content/events_zh-CN/story_demo_events.json": "b8ff12758d29a02fd07fdad5f8d3931b805afcbe8e18f1d02db5dfa575c0f05e",
    "content/events_zh-TW/story_demo_events.json": "57929914f0b8c73e8865dd1dde9c45e240fcf0463d327fd32d2225ccf3dc9dca",
    "content/events_en/core_loop_v2_events.json": "0f87d6f554563c776a5922e7126d5c3cd95f6924f1ad774b871c9fb0d5e5657a",
    "playtests/order124/StoryChoiceM1M6Playtest.gd": "feb2f8a20bd8db91579062b1c7449f28f4d0146674c043d262107f1ea53913c2",
    "scenes/StoryMode.gd": "114fdd47d09cb4e3b92b26d094981b8e9b1843639f64cb3914bcce000a76bec7",
    "content/events/arc_hyunsu.json": "2449594b27187c761db5d94784c5caa0b57c61fa6eb1bdc3e619fc62971a49ca",
    "content/events_en/arc_hyunsu.json": "3df4481d5e00fd578019d99dbb23e58821a27c665e4ffd7e1ec6db8b47611069",
    MIDGAME_PATH: FILE_HASHES[MIDGAME_PATH][0],
    "content/events_ja/arc_hyunsu.json": "852d611078d624ae8fd0c5f06cc7fe883ec83ba8a06c127cddf3cc0e8454c57f",
    "content/events_zh-CN/arc_hyunsu.json": "92fb3f2f9fbd674d0d21d94441131336442fbd4a66f92baa9a473007c08a6832",
    "content/events_zh-TW/arc_hyunsu.json": "39ea586335494400eda3f98a8dea909893d3b59a901ef253ce57d9db0554c064",
    LEDGER_PATH: FILE_HASHES[LEDGER_PATH][0],
}
TOKEN_RE = previous.TOKEN_RE
_ACTIVE_PROOF: contextvars.ContextVar[dict[tuple[str, str], bytes] | None] = contextvars.ContextVar(
    "order313_active_git_proof", default=None)


def _sha(raw: bytes) -> str:
    return hashlib.sha256(raw).hexdigest()


def _canonical(value: Any) -> bytes:
    return json.dumps(value, ensure_ascii=False, sort_keys=True,
                      separators=(",", ":"), allow_nan=False).encode("utf-8")


def _digest(value: Any) -> str:
    return _sha(_canonical(value))


def _loads(raw: bytes) -> Any:
    value = previous.original305._loads(raw)
    # Keep the original duplicate/constant rejection and also reject exponent
    # overflow (valid JSON number 1e999 must not become an infinite observation).
    _canonical(value)
    return value


def _git(*args: str) -> bytes:
    result = subprocess.run(("git", *args), cwd=ROOT, capture_output=True)
    if result.returncode:
        raise ValueError("ORDER-313: immutable Git proof unavailable: " + " ".join(args))
    return result.stdout


def _git_blob(revision: str, relative: str) -> bytes:
    proof = _ACTIVE_PROOF.get()
    if proof is not None and (revision, relative) in proof:
        return proof[revision, relative]
    return _git("show", f"{revision}:{relative}")


def _verify_git_registration() -> None:
    if _git("rev-parse", AFTER_COMMIT + "^").decode().strip() != BEFORE_COMMIT:
        raise ValueError("ORDER-313: exact product predecessor drifted")
    actual = _git("diff", "--name-status", "-z", BEFORE_COMMIT, AFTER_COMMIT).split(b"\0")
    expected = [part for p in sorted(CURRENT_PATHS) for part in (b"M", p.encode())] + [b""]
    if actual != expected:
        raise ValueError("ORDER-313: exact seven-JSON/one-ledger population drifted")


def _read_git_pairs(paths: tuple[str, ...]) -> dict[tuple[str, str], bytes]:
    requests = [(rev, path) for path in paths for rev in (BEFORE_COMMIT, AFTER_COMMIT)]
    query = "".join(f"{rev}:{path}\n" for rev, path in requests).encode()
    result = subprocess.run(("git", "cat-file", "--batch"), cwd=ROOT, input=query, capture_output=True)
    if result.returncode:
        raise ValueError("ORDER-313: bulk immutable Git proof unavailable")
    cursor = 0
    blobs: dict[tuple[str, str], bytes] = {}
    for request in requests:
        end = result.stdout.find(b"\n", cursor)
        header = result.stdout[cursor:end].split()
        if (end < cursor or len(header) != 3 or not re.fullmatch(rb"[0-9a-f]{40}", header[0])
                or header[1] != b"blob" or not header[2].isdigit()):
            raise ValueError("ORDER-313: missing/malformed immutable blob " + ":".join(request))
        size = int(header[2])
        cursor = end + 1
        if result.stdout[cursor + size:cursor + size + 1] != b"\n":
            raise ValueError("ORDER-313: incomplete immutable blob " + ":".join(request))
        blobs[request] = result.stdout[cursor:cursor + size]
        cursor += size + 1
    if cursor != len(result.stdout):
        raise ValueError("ORDER-313: unexpected bulk Git proof trailing bytes")
    return blobs


@contextlib.contextmanager
def _fresh_proof(paths: tuple[str, ...]):
    _verify_git_registration()
    if LEDGER_PATH in paths:
        paths = tuple(dict.fromkeys((*paths, KO_PATH, *LOCALE_PATHS.values())))
    token = _ACTIVE_PROOF.set(_read_git_pairs(paths))
    try:
        yield
    finally:
        _ACTIVE_PROOF.reset(token)


@contextlib.contextmanager
def fresh_validation_proof():
    """Fresh proof per invocation; nested consumers share only this invocation."""
    if _ACTIVE_PROOF.get() is not None:
        yield
    else:
        with _fresh_proof(CURRENT_PATHS), previous.fresh_validation_proof():
            yield


def _rows(payload: Any) -> dict[str, dict[str, Any]]:
    if not isinstance(payload, list):
        raise ValueError("ORDER-313: expected complete event array")
    rows: dict[str, dict[str, Any]] = {}
    for row in payload:
        if (not isinstance(row, dict) or not isinstance(row.get("id"), str)
                or not row["id"] or row["id"] in rows):
            raise ValueError("ORDER-313: missing/duplicate event identity")
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
        raise ValueError("ORDER-313: unregistered text path " + relative)
    old, new = _loads(before), _loads(after)
    expected = copy.deepcopy(old)
    old_rows, new_rows = _rows(expected), _rows(new)
    expected_raw = before
    for event_id, path in CURRENT_JSON_LEAVES[relative]:
        if event_id not in old_rows or event_id not in new_rows:
            raise ValueError("ORDER-313: declared event missing " + event_id)
        old_text, new_text = _leaf(old_rows[event_id], path), _leaf(new_rows[event_id], path)
        if not isinstance(old_text, str) or not isinstance(new_text, str) or old_text == new_text:
            raise ValueError("ORDER-313: declared leaf is not a text delta " + event_id)
        if (old_text.count("\n") != new_text.count("\n")
                or TOKEN_RE.findall(old_text) != TOKEN_RE.findall(new_text)):
            raise ValueError("ORDER-313: newline/token preservation drifted " + event_id)
        old_literal = json.dumps(old_text, ensure_ascii=False).encode("utf-8")
        new_literal = json.dumps(new_text, ensure_ascii=False).encode("utf-8")
        if expected_raw.count(old_literal) != 1:
            raise ValueError("ORDER-313: complete leaf literal is not unique " + event_id)
        expected_raw = expected_raw.replace(old_literal, new_literal, 1)
        _set_leaf(old_rows[event_id], path, new_text)
    if _canonical(expected) != _canonical(new) or expected_raw != after:
        raise ValueError("ORDER-313: source exceeds exact declared leaves " + relative)


def _receipt_for(rows: dict[str, Any], targets: dict[str, Any],
                 event: str, path: tuple[str | int, ...]) -> dict[str, str]:
    return {"source_sha256": _digest({"path": KO_PATH, "field": path, "ko": _leaf(rows[event], path)}),
            "target_sha256": _digest(_leaf(targets[event], path))}


def _verify_receipt_delta(before: bytes, after: bytes,
                          texts: dict[str, tuple[bytes, bytes]]) -> None:
    old, new = _loads(before), _loads(after)
    owned = {"accepted", "accepted_sha256", "batches"}
    if (list(old) != list(new) or {k: v for k, v in old.items() if k not in owned}
            != {k: v for k, v in new.items() if k not in owned}):
        raise ValueError("ORDER-313: receipt non-owned metadata drifted")
    if (len(old["batches"]) != 137 or len(new["batches"]) != 139
            or new["batches"][:-2] != old["batches"]):
        raise ValueError("ORDER-313: prior 137-batch receipt history changed")
    for batch, order, roots, count in zip(
            new["batches"][-2:], ("ORDER-313", "ORDER-356"),
            (["arc_sangchul_03_network", "arc_father_04_visit"], ["arc_father_04_visit"]), (2, 1)):
        if (batch.get("order") != order or batch.get("group") != "events"
                or batch.get("roots") != roots or batch.get("source_leaves") != count
                or batch.get("target_leaves_by_locale") != {loc: count for loc in LOCALE_PATHS}
                or batch.get("added_accepted_leaves") != 0
                or batch.get("revalidated_existing_leaves") is not True
                or batch.get("machine_validation") != "PASS"
                or batch.get("native_review") != "OPEN" or batch.get("rendered_review") != "OPEN"
                or _digest(batch) != BATCH_HASHES[order]):
            raise ValueError("ORDER-313: separate bounded receipt batch drifted " + order)
    if list(old["accepted"]) != list(new["accepted"]) or set(new["accepted"]) != set(LOCALE_PATHS):
        raise ValueError("ORDER-313: receipt locale population drifted")
    ko = [_rows(_loads(raw)) for raw in texts[KO_PATH]]
    for locale, relative in LOCALE_PATHS.items():
        targets = [_rows(_loads(raw)) for raw in texts[relative]]
        prior, current = old["accepted"][locale], new["accepted"][locale]
        changed = {key for key in prior if prior[key] != current.get(key)}
        if list(prior) != list(current) or changed != set(RECEIPT_IDS):
            raise ValueError("ORDER-313: expected exactly three existing receipts " + locale)
        for (event, path), receipt_id in zip(SOURCE_LEAVES, RECEIPT_IDS):
            for index, records in enumerate((prior, current)):
                if records[receipt_id] != _receipt_for(ko[index], targets[index], event, path):
                    raise ValueError("ORDER-313: stale source/wrong target receipt " + locale + ":" + receipt_id)
    for ledger in (old, new):
        if (sum(len(rows) for rows in ledger["accepted"].values()) != 40299
                or ledger["accepted_sha256"] != _digest(ledger["accepted"])):
            raise ValueError("ORDER-313: receipt total/checksum drifted")


@functools.lru_cache(maxsize=8)
def _verify_transition(before: bytes, after: bytes, relative: str,
                       receipt_texts: tuple[tuple[str, bytes, bytes], ...] = ()) -> None:
    # Pure byte verification only. Git access/registration is never cached.
    if relative not in FILE_HASHES or (_sha(before), _sha(after)) != FILE_HASHES[relative]:
        raise ValueError("ORDER-313: immutable byte hashes drifted " + relative)
    if relative == LEDGER_PATH:
        _verify_receipt_delta(before, after, {p: (a, b) for p, a, b in receipt_texts})
    else:
        _verify_json_delta(before, after, relative)


def verified_blobs(relative: str) -> tuple[bytes, bytes]:
    """Fresh exact current transition; old-only history paths delegate to 309."""
    if relative not in CURRENT_PATHS:
        if relative in previous.PATHS:
            return previous.verified_blobs(relative)
        raise ValueError("ORDER-313: unregistered transition path " + relative)
    if _ACTIVE_PROOF.get() is None:
        with _fresh_proof((relative,)):
            return verified_blobs(relative)
    before, after = _git_blob(BEFORE_COMMIT, relative), _git_blob(AFTER_COMMIT, relative)
    receipt_texts = ()
    if relative == LEDGER_PATH:
        receipt_texts = tuple((p, *verified_blobs(p)) for p in (KO_PATH, *LOCALE_PATHS.values()))
    _verify_transition(before, after, relative, receipt_texts)
    if relative in previous.LIVE_PATHS and previous.source_errors(before, relative):
        raise ValueError("ORDER-313: predecessor does not bind to immutable 309/316/310/305 " + relative)
    return before, after


def inverse_313_bytes(raw: bytes, relative: str) -> bytes:
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
        for event in dict.fromkeys(leaf[0] for leaf in JSON_LEAVES[relative]):
            if event not in rows or _canonical(rows[event]) != _canonical(new[event]):
                continue
            for owner, path in JSON_LEAVES[relative]:
                if owner == event:
                    _set_leaf(rows[event], path, _leaf(old[event], path))
    except (ValueError, TypeError, KeyError, IndexError):
        return copy.deepcopy(payload)
    return projected


def inverse_313_payload(payload: Any, relative: str) -> Any:
    """Copy/invert complete exact events only; never use this as admission."""
    if (relative not in PATHS or not isinstance(payload, list)
            or not any(isinstance(row, dict) and row.get("id") in
                       {leaf[0] for leaf in JSON_LEAVES[relative]} for row in payload)):
        return copy.deepcopy(payload)
    try:
        return _inverse_payload(payload, relative, verified_blobs(relative))
    except (OSError, ValueError):
        return copy.deepcopy(payload)


def inverse_313_hash(digest: str, relative: str) -> str:
    if relative in PATHS and digest == FILE_HASHES[relative][1]:
        try:
            before, after = verified_blobs(relative)
        except (OSError, ValueError):
            return digest
        if _sha(after) == digest:
            return _sha(before)
    return digest


def inverse_current_bytes(raw: bytes, relative: str) -> bytes:
    """Comparison-only post-305 view: undo 313/356 and 309, not older repairs."""
    if relative in PATHS:
        try:
            before, after = verified_blobs(relative)
        except (OSError, ValueError):
            return raw
        raw = before if raw == after else raw
    return previous.inverse_309_bytes(raw, relative)


def inverse_current_payload(payload: Any, relative: str) -> Any:
    if relative in PATHS:
        try:
            payload = _inverse_payload(payload, relative, verified_blobs(relative))
        except (OSError, ValueError):
            return copy.deepcopy(payload)
    return previous.inverse_309_payload(payload, relative)


def inverse_current_hash(digest: str, relative: str) -> str:
    if relative in PATHS:
        try:
            before, after = verified_blobs(relative)
        except (OSError, ValueError):
            return digest
        digest = _sha(before) if digest == _sha(after) else digest
    return previous.inverse_309_hash(digest, relative)


def historical_blobs(relative: str) -> tuple[bytes, bytes]:
    """Exact post-305 comparison bytes and actual latest bytes for union seven."""
    if relative not in HISTORICAL_PATHS:
        raise ValueError("ORDER-313: unregistered historical path " + relative)
    with fresh_validation_proof():
        _before, current = verified_blobs(relative)
        return inverse_current_bytes(current, relative), current


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
    return previous.project_payload(payload, relative)


def project_byte_hash(digest: str, relative: str) -> str:
    if relative in PATHS:
        try:
            before, after = verified_blobs(relative)
        except (OSError, ValueError):
            return digest
        digest = _sha(before) if digest == _sha(after) else digest
    return previous.project_byte_hash(digest, relative)


def source_errors(raw: bytes, relative: str) -> list[str]:
    """Exact latest raw admission, never an inverse/rollback acceptance gate."""
    if relative not in CURRENT_PATHS:
        return previous.source_errors(raw, relative)
    if _sha(raw) != FILE_HASHES[relative][1]:
        return ["ORDER-313: current source exceeds exact approved successor " + relative]
    try:
        _before, after = verified_blobs(relative)
    except (OSError, ValueError) as exc:
        return [str(exc)]
    return [] if raw == after else ["ORDER-313: raw source differs from immutable proof " + relative]


def current_source_errors(root: Path = ROOT) -> list[str]:
    errors: list[str] = []
    try:
        with fresh_validation_proof():
            for relative in LIVE_PATHS:
                try:
                    errors.extend(source_errors((root / relative).read_bytes(), relative))
                except OSError as exc:
                    errors.append(f"ORDER-313: current source unavailable {relative}: {exc}")
    except (OSError, ValueError) as exc:
        errors.append(str(exc))
    return errors


def source_observation_errors(raw: bytes, payload: Any, relative: str) -> list[str]:
    errors = source_errors(raw, relative)
    try:
        if _canonical(_loads(raw)) != _canonical(payload):
            errors.append("ORDER-313: observed payload is not bound to raw current bytes " + relative)
    except (ValueError, TypeError, UnicodeError):
        errors.append("ORDER-313: malformed raw/payload observation " + relative)
    return errors


def observed_byte_hash(relative: str, observed: str, raw: bytes) -> tuple[str, list[str]]:
    errors = source_errors(raw, relative)
    if _sha(raw) != observed:
        errors.append("ORDER-313: observed hash is not bound to raw current bytes " + relative)
    if errors:
        return observed, errors
    if relative in PATHS:
        return inverse_current_hash(observed, relative), []
    if relative in CURRENT_PATHS:
        return observed, []
    return previous.observed_byte_hash(relative, observed, raw)


def _verify_original_modules() -> dict[str, bytes]:
    """Bind original imports and their on-disk bytes to the immutable pre313 tree."""
    modules = (previous.original305, previous.original310, previous.previous, previous)
    blobs: dict[str, bytes] = {}
    for (relative, digest), module in zip(MODULE_HASHES.items(), modules):
        raw = _git_blob(BEFORE_COMMIT, relative)
        if (_sha(raw) != digest or Path(module.__file__).resolve() != ROOT / relative
                or module.ROOT != ROOT or (ROOT / relative).read_bytes() != raw):
            raise ValueError("ORDER-313: immutable original module/import drifted " + relative)
        blobs[relative] = raw
    return blobs


def _run_isolated_309() -> dict[str, Any]:
    """Execute the unmodified 286-case CLI on verified pre313 files, not mocks."""
    blobs = _verify_original_modules()
    if set(PRE313_LIVE_HASHES) != set(previous.LIVE_PATHS) or len(PRE313_LIVE_HASHES) != 15:
        raise ValueError("ORDER-313: isolated original live population drifted")
    for relative, digest in PRE313_LIVE_HASHES.items():
        raw = _git_blob(BEFORE_COMMIT, relative)
        if _sha(raw) != digest:
            raise ValueError("ORDER-313: isolated pre313 source drifted " + relative)
        blobs[relative] = raw
    git_dir = Path(_git("rev-parse", "--absolute-git-dir").decode().strip())
    scratch = git_dir / "full-game-localization"
    scratch.mkdir(parents=True, exist_ok=True)
    # This generated test fixture is private and short lived. No checkout,
    # original module, corpus assertion or product file is rewritten.
    with tempfile.TemporaryDirectory(prefix="order357-compat-original309-", dir=scratch) as directory:
        root = Path(directory).resolve()
        for relative, raw in blobs.items():
            target = root / relative
            target.parent.mkdir(parents=True, exist_ok=True)
            target.write_bytes(raw)
            target.chmod(0o444)
        runner = """
import hashlib, importlib, json, pathlib, sys
root = pathlib.Path(sys.argv[1]).resolve()
hashes = json.loads(sys.argv[2])
sys.path.insert(0, str(root / 'tools'))
identity = {}
for relative, expected in hashes.items():
    module = importlib.import_module(pathlib.Path(relative).stem)
    path = pathlib.Path(module.__file__).resolve()
    digest = hashlib.sha256(path.read_bytes()).hexdigest()
    if path != root / relative or module.ROOT != root or digest != expected:
        raise RuntimeError('isolated import identity mismatch: ' + relative)
    identity[relative] = {'file': str(path), 'root': str(module.ROOT), 'sha256': digest}
print('ORDER313_ISOLATED_IDENTITY ' + json.dumps(identity, sort_keys=True), flush=True)
sys.argv = [str(root / 'tools/order309_source_compat.py'), '--self-test']
raise SystemExit(importlib.import_module('order309_source_compat').main())
"""
        env = dict(os.environ, GIT_DIR=str(git_dir), GIT_WORK_TREE=str(root),
                   GIT_OPTIONAL_LOCKS="0", PYTHONDONTWRITEBYTECODE="1")
        process = subprocess.run(
            (sys.executable, "-I", "-B", "-c", runner, str(root), json.dumps(MODULE_HASHES)),
            cwd=root, env=env, capture_output=True, text=True, timeout=180)
        marker = ("ORDER309_SOURCE_OK current_files=7 leaves=17 receipts=9 "
                  "historical_files=4 historical_leaves=8 live_files=15 cases=286")
        errors = []
        if process.returncode != 0 or marker not in process.stdout.splitlines() or process.stderr.strip():
            errors.append("isolated unmodified ORDER-309 CLI failed: "
                          + process.stdout.strip() + " " + process.stderr.strip())
        identity_lines = [line.removeprefix("ORDER313_ISOLATED_IDENTITY ")
                          for line in process.stdout.splitlines()
                          if line.startswith("ORDER313_ISOLATED_IDENTITY ")]
        identity = json.loads(identity_lines[0]) if len(identity_lines) == 1 else {}
        if set(identity) != set(MODULE_HASHES):
            errors.append("isolated original module identity output missing")
        for relative, raw in blobs.items():
            if (root / relative).read_bytes() != raw:
                errors.append("isolated original corpus mutated " + relative)
        return {"corpus": "ORDER-309", "cases": 286 if marker in process.stdout.splitlines() else 0,
                "errors": errors, "source_revision": BEFORE_COMMIT,
                "live_files": PRE313_LIVE_HASHES, "modules": identity,
                "isolation": "fresh -I -B subprocess; immutable module4/live15; Git objects read-only",
                "stdout": process.stdout.strip(), "stderr": process.stderr.strip(),
                "returncode": process.returncode}


def historical_self_test() -> tuple[list[str], int, list[dict[str, Any]]]:
    """Current admission -> unchanged 301 current callers + isolated old309 286.

    The 316 corpus must use real current consumers in this checkout. The 309
    corpus must instead use its own pre313 live bytes in a fresh isolated root.
    Neither corpus is patched, mocked, filtered or credited before execution.
    """
    failures = current_source_errors()
    results: list[dict[str, Any]] = []
    cases = 0
    if failures:
        return failures, cases, results
    try:
        _verify_original_modules()
        old_failures, old_cases, old_results = previous.historical_self_test()
        failures.extend(old_failures)
        cases += old_cases
        results.extend(old_results)
        isolated = _run_isolated_309()
        failures.extend("ORDER-309: " + error for error in isolated["errors"])
        cases += isolated["cases"]
        results.append(isolated)
    except (OSError, ValueError, subprocess.TimeoutExpired) as exc:
        failures.append("ORDER-313: historical corpus unavailable: " + str(exc))
    if cases != 587:
        failures.append(f"ORDER-313: historical corpus population expected587 observed{cases}")
    return failures, cases, results


def self_test() -> tuple[list[str], int]:
    """Actual current positives plus rollback, receipt, raw/index and proof negatives."""
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

    check(len(PATHS) == 4 and sum(map(len, JSON_LEAVES.values())) == 11
          and len(CURRENT_JSON_LEAVES) == 7 and sum(map(len, CURRENT_JSON_LEAVES.values())) == 20
          and len(CURRENT_PATHS) == 8 and len(LIVE_PATHS) == 19,
          "exact current7/20 ledger1/9 historical4/11 live19 population")
    check(len(HISTORICAL_PATHS) == 7 and sum(map(len, HISTORICAL_JSON_LEAVES.values())) == 19
          and len(HISTORICAL_JSON_LEAVES[MIDGAME_PATH]) == 3,
          "historical union retains old Hyunsu/core/midgame and new4/11")
    check(not current_source_errors(), "actual latest whole-source admission")
    check(len(_verify_original_modules()) == 4, "four original module/import identities unchanged")
    all_blobs = {path: verified_blobs(path) for path in CURRENT_PATHS}
    for relative, (before, after) in all_blobs.items():
        old, new = _loads(before), _loads(after)
        check((ROOT / relative).read_bytes() == after and not source_errors(after, relative),
              relative + " actual current raw positive")
        check(not source_observation_errors(after, new, relative), relative + " exact raw/payload binding")
        check(not observed_byte_hash(relative, _sha(after), after)[1], relative + " exact raw/hash binding")
        check(bool(source_observation_errors(after, old, relative)), relative + " stale payload rejected")
        for value, label in ((_sha(before), "stale"), ("0" * 64, "forged")):
            check(bool(observed_byte_hash(relative, value, after)[1]), relative + " " + label + " hash rejected")
        for label, path, raw in (
            ("rollback", relative, before), ("wrong path", relative + ".other", after),
            ("swapped path", next(p for p in CURRENT_PATHS if p != relative), after),
            ("trailing byte", relative, after + b"\n"), ("missing raw", relative, b""),
            ("duplicate key", relative, after.replace(b'"id":', b'"id":"duplicate", "id":', 1)
             if relative != LEDGER_PATH else after.replace(b'"accepted":', b'"accepted":{}, "accepted":', 1)),
        ):
            check(bool(source_errors(raw, path)) and inverse_313_bytes(raw, path) == raw
                  and inverse_313_hash(_sha(raw), path) == _sha(raw), relative + " rejects " + label)
        if relative not in PATHS:
            check(inverse_313_bytes(after, relative) == after and inverse_current_bytes(after, relative) == after
                  and inverse_313_payload(new, relative) == new and inverse_current_payload(new, relative) == new
                  and inverse_current_hash(_sha(after), relative) == _sha(after)
                  and project_bytes(after, relative) == after and project_payload(new, relative) == new
                  and project_byte_hash(_sha(after), relative) == _sha(after),
                  relative + " current prepared language/ledger never projects")
        else:
            check(inverse_313_bytes(after, relative) == before, relative + " exact current byte inverse")
            check(inverse_313_hash(_sha(after), relative) == _sha(before), relative + " exact current hash inverse")
            check(inverse_313_payload(new, relative) == old, relative + " exact current payload inverse")
            check(project_bytes(after, relative) == previous.project_bytes(before, relative), relative + " byte chain")
            check(project_payload(new, relative) == previous.project_payload(old, relative), relative + " payload chain")
            check(project_byte_hash(_sha(after), relative) == previous.project_byte_hash(_sha(before), relative),
                  relative + " hash chain")
            check(inverse_current_bytes(after, relative) == previous.inverse_309_bytes(before, relative)
                  and inverse_current_payload(new, relative) == previous.inverse_309_payload(old, relative)
                  and inverse_current_hash(_sha(after), relative) == previous.inverse_309_hash(_sha(before), relative),
                  relative + " post305 comparison keeps 310/305 repairs")
            check(observed_byte_hash(relative, _sha(after), after)
                  == (inverse_current_hash(_sha(after), relative), []), relative + " raw-bound observed positive")
            saved = copy.deepcopy(new)
            check(inverse_313_payload(list(reversed(new)), relative) == list(reversed(old)) and new == saved,
                  relative + " copied projection preserves order/input")
        if relative in CURRENT_JSON_LEAVES:
            old_rows, new_rows = _rows(old), _rows(new)
            for event, path in CURRENT_JSON_LEAVES[relative]:
                row = new_rows[event]
                for label, value in (("mutation", "unapproved"), ("type", 313),
                                     ("partial rollback", _leaf(old_rows[event], path))):
                    mutated = copy.deepcopy(row)
                    _set_leaf(mutated, path, value)
                    mutant = copy.deepcopy(new)
                    mutant[mutant.index(row)] = mutated
                    raw = json.dumps(mutant, ensure_ascii=False, indent=2).encode() + b"\n"
                    check(bool(source_errors(raw, relative)) and inverse_313_payload([mutated], relative) == [mutated],
                          f"{relative}:{event}:{path} {label}")
            event = CURRENT_JSON_LEAVES[relative][0][0]
            row = new_rows[event]
            for label, field, value in (("neighbor prose", "title", "unapproved"),
                                         ("gameplay", "conditions", {"money": 1}),
                                         ("wrong ID", "id", "not_the_event")):
                mutated = copy.deepcopy(row)
                mutated[field] = value
                check(inverse_313_payload([mutated], relative) == [mutated], relative + " " + label)
            for label, payload in (("duplicate event", [row, copy.deepcopy(row)]),
                                    ("missing event", []), ("root type", {"events": new})):
                check(inverse_313_payload(payload, relative) == payload, relative + " " + label)
                check(bool(source_observation_errors(after, payload, relative)), relative + " rejects observed " + label)
            neighbor = copy.deepcopy(new)
            untouched = next(r for r in neighbor if r["id"] not in LIVE_EVENT_IDS[relative])
            untouched["title"] += "!"
            check(_rows(project_payload(neighbor, relative))[untouched["id"]] == untouched,
                  relative + " unrelated neighbor remains visible")
            check(bool(source_observation_errors(after, neighbor, relative)), relative + " unbound neighbor rejected")
            rejected(lambda: _verify_json_delta(before, after + b"\n", relative), relative + " exact byte scope")
        for label, proof in (("warm missing proof", mock.Mock(side_effect=OSError("missing proof"))),
                              ("warm altered proof", lambda rev, path: _git("show", f"{rev}:{path}") + b"\n")):
            verified_blobs(relative)
            with mock.patch(__name__ + "._git_blob", proof):
                check(bool(source_errors(after, relative)) and inverse_313_bytes(after, relative) == after
                      and inverse_313_payload(new, relative) == new
                      and inverse_313_hash(_sha(after), relative) == _sha(after)
                      and inverse_current_bytes(after, relative) == after
                      and inverse_current_payload(new, relative) == new
                      and inverse_current_hash(_sha(after), relative) == _sha(after)
                      and project_bytes(after, relative) == after and project_payload(new, relative) == new
                      and project_byte_hash(_sha(after), relative) == _sha(after), relative + " " + label)
    for relative in HISTORICAL_PATHS:
        comparison, current = historical_blobs(relative)
        check((ROOT / relative).read_bytes() == current and not source_errors(current, relative)
              and comparison == inverse_current_bytes(current, relative), relative + " complete union historical binding")
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
        ("batch separation", lambda x: x["batches"][-1].update({"order": "ORDER-313"})),
        ("batch detail", lambda x: x["batches"][-2].update({"source_review": "forged"})),
        ("batch receipt digest", lambda x: x["batches"][-1]["receipt_sha256_by_locale"].update({"ja": "0" * 64})),
        ("neighbor receipt", lambda x: x["accepted"]["ja"][next(k for k in x["accepted"]["ja"] if k not in RECEIPT_IDS)].update({"target_sha256": "0" * 64})),
        ("unowned ledger metadata", lambda x: x.update({"full_game_status": "GO"})),
        ("missing receipt", lambda x: x["accepted"]["ja"].pop(RECEIPT_IDS[0])),
    ):
        mutated = copy.deepcopy(ledger)
        mutate(mutated)
        mutated["accepted_sha256"] = _digest(mutated["accepted"])
        rejected(lambda: _verify_receipt_delta(ledger_old, _canonical(mutated), text_blobs), label)
    for raw in (b'{"a":1,"a":2}', b'[NaN]', b'[Infinity]', b'[-Infinity]', b'{"x":1e999}'):
        rejected(lambda: _loads(raw), "strict raw duplicate/nonfinite rejection " + raw.decode())
    for value in (float("nan"), float("inf"), float("-inf")):
        check(bool(source_observation_errors(all_blobs[KO_PATH][1], [{"id": "nonfinite", "x": value}], KO_PATH)),
              "nonfinite observed payload rejected")
    # Real temporary whole-source roots demonstrate that mixtures are never
    # admitted, even when every individual file is an approved old/new blob.
    scratch = Path(_git("rev-parse", "--absolute-git-dir").decode().strip()) / "full-game-localization"
    scratch.mkdir(parents=True, exist_ok=True)
    with tempfile.TemporaryDirectory(prefix="order357-compat-mixed-", dir=scratch) as directory:
        root = Path(directory)
        for relative in LIVE_PATHS:
            target = root / relative
            target.parent.mkdir(parents=True, exist_ok=True)
            target.write_bytes((ROOT / relative).read_bytes())
        check(not current_source_errors(root), "actual nineteen-file copied root admitted")
        for relative, (before, after) in all_blobs.items():
            (root / relative).write_bytes(before)
            check(bool(current_source_errors(root)), relative + " mixed old/new root rejected")
            (root / relative).write_bytes(after)
        for relative, (before, _after) in all_blobs.items():
            (root / relative).write_bytes(before)
        check(bool(current_source_errors(root)), "complete pre313 rollback rejected as live")
    real_git = _git
    for label, which, reply in (("wrong parent", "rev-parse", b"0" * 40 + b"\n"),
                                ("wrong population", "diff", b"")):
        def changed_git(*args: str) -> bytes:
            return reply if args[0] == which else real_git(*args)
        with mock.patch(__name__ + "._git", changed_git):
            rejected(_verify_git_registration, label)
            check(bool(source_errors(all_blobs[KO_PATH][1], KO_PATH)), label + " live rejection")
    check(_ACTIVE_PROOF.get() is None, "scope begins without leaked proof")
    with mock.patch(__name__ + "._fresh_proof", wraps=_fresh_proof) as fresh_reads:
        with fresh_validation_proof():
            snapshot = _ACTIVE_PROOF.get()
            check(snapshot is not None and set(snapshot) == {
                (rev, path) for path in CURRENT_PATHS for rev in (BEFORE_COMMIT, AFTER_COMMIT)},
                "scope binds all eight immutable file pairs")
            with fresh_validation_proof():
                check(_ACTIVE_PROOF.get() is snapshot, "nested validation shares same snapshot")
                check(not current_source_errors(), "nested guard validates current nineteen")
            check(fresh_reads.call_count == 1 and _ACTIVE_PROOF.get() is snapshot,
                  "nested exit preserves outer proof")
        check(_ACTIVE_PROOF.get() is None, "normal scope exit clears proof")
        with fresh_validation_proof():
            check(_ACTIVE_PROOF.get() is not snapshot and fresh_reads.call_count == 2,
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
            check(not source_errors(all_blobs[KO_PATH][1], KO_PATH), label + " warmed previous scope")
        with mock.patch(__name__ + "._git_blob", proof):
            with fresh_validation_proof():
                check(bool(current_source_errors()), label + " next validation rejects")
        check(_ACTIVE_PROOF.get() is None, label + " cleanup")
    with mock.patch(__name__ + "._git", side_effect=OSError("Git unavailable")):
        check(bool(current_source_errors()), "unavailable next proof fails before context entry")
    check(_ACTIVE_PROOF.get() is None, "failed context entry does not leak proof")
    return failures, cases


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
            print("ORDER313_ORIGINAL_CORPUS " + json.dumps(result, ensure_ascii=False, sort_keys=True))
    for error in errors:
        print("ORDER313_SOURCE_ERROR " + error)
    marker = "ORDER313_HISTORICAL" if args.historical_self_test else "ORDER313_SOURCE"
    print(f"{marker}_{'FAIL' if errors else 'OK'} current_files=7 leaves=20 receipts=9 "
          f"historical_files=4 historical_leaves=11 live_files={len(LIVE_PATHS)} "
          f"historical_union={len(HISTORICAL_PATHS)} units=313,356 cases={cases}")
    return int(bool(errors))


if __name__ == "__main__":
    raise SystemExit(main())
