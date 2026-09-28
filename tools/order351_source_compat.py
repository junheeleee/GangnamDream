#!/usr/bin/env python3
"""Exact ORDER-351 current admission and KO/EN-only historical comparison.

Current translations, inventory and receipts are never projected.  Original
350/313/309/316/310/305 modules and their historical corpora remain immutable.
"""
from __future__ import annotations

import argparse
import contextlib
import contextvars
import copy
import functools
import json
import os
import re
import subprocess
import sys
import tempfile
from pathlib import Path
from typing import Any

import order350_source_compat as previous

ROOT = Path(__file__).resolve().parents[1]
BEFORE_COMMIT = "6297e8cbcd4e77278055b5e332f545ea32de90f9"
AFTER_COMMIT = "3f0aa92dc9c3bdefd6a333fa84481a318baad907"
LEDGER_PATH = "content/meta/full_game_localization.json"
LOCALES = ("ja", "zh-CN", "zh-TW")
TOKEN_RE = previous.TOKEN_RE
FILE_HASHES = {
    "content/events/arc_chapter_themes.json": ("ab8cc4b2a1e38ff62b036f0d1045a8af556b85f3a4e4980e2c7341630bbe15d3", "e36b903ed30e9e87ba96147f0a49b83c7c20b00f112a7b78d8563634147904c5"),
    "content/events/arc_drama.json": ("88ddf36bdc1f7a51228873393f0680be3d3dd5fc238817451258932c23651537", "b4ff30efc3847bd857d8d285dada49d97dad9a4e7b26833d24a8c5c412b629bd"),
    "content/events_en/arc_chapter_themes.json": ("6e116be1bbe1d325ae221e53e61fc9e31e872d11ab09a6b3fed2eabe241c3025", "c39b2ba2eb934d860db2bf27c7d425922479ae4454f0a6e4bed063ec9ee74f7a"),
    "content/events_en/arc_drama.json": ("62a4dbe004fdfdb05901b44f82f027766a84e94270ce7b366680ed7c9185bd69", "7df4cc14ecc46331c373cacd6c8629362a3c1fb8bbdf6c93cf49edaaf662679d"),
    "content/events_en/arc_new_characters.json": ("97a465d537505d111df089949c4baba2e41791b98718feed65e83fe222d976d5", "7ca1f00c1bb3993847c298b9ec828a416b5f3a90bf45093e0469253d11261184"),
    "content/events_ja/arc_chapter_themes.json": ("8bd19877aba7f55dde6243888c78bcad5ef8ee100cb01da82e26e255a6735448", "185465f5b1f0a92bd6d1f12255700893466d4954225a2ae967da5bd00a12adb4"),
    "content/events_ja/arc_drama.json": ("9a835aa45cc3e16d9612ee696b715c3189efddb67d3cc6692603978a9c697750", "809a523a8a88eaa8fc928b62b0de9d8c54595cf10e586e60dfd074c7782b0687"),
    "content/events_zh-CN/arc_chapter_themes.json": ("065c7016a3cb1fa55ca0576a21e57031af946c3d1fa326f9d7ebe47bd627539f", "cfc2e4744ebd7bf80c923bb72b3c676490237b4404094ceececdefe4fd367650"),
    "content/events_zh-CN/arc_drama.json": ("0d5abd71dfc8f9f4d7c06491d5c76740def789a699e8f3142be9906d878fc9bd", "75b11ac9bcb1957b2cbdd4686895b2e5452dd1cae5be69588c30f91316d28c4e"),
    "content/events_zh-TW/arc_chapter_themes.json": ("8b0f9130e83f2b7f526e6a94279d81bef56e795328718546293eafe59a8fb2a7", "94eff438be2fa4c4b7a44cf178ca3e07db5d88162460b6f6b28a72b267ae66f0"),
    "content/events_zh-TW/arc_drama.json": ("96be10f8d5cd065dd4f828bd8ad36ff13443b7667e0c74667e281fd2d732f7ff", "88c29c15e94c7aeb68051e62b4feb321ed9e7fdf1f1cd23621c133fa21d40aa4"),
    LEDGER_PATH: ("786003ef4a6da383f52c3945fb58b1782cf7e95775d1a2bd9ff4a23e7f5c5c91", "451995650b797fd9f112887026ea55f43b1edda4d204e16ecfdf66d57ef61805"),
}
_THEME_LEAVES = (
    ("arc_35_path_cost", ("choices", 1, "result_text")),
    ("arc_36_unexpected_hand", ("description",)),
    ("arc_36_unexpected_hand", ("description_if_known", "arc_y4_three_promises_missed_father&arc_y4_three_promises_missed_person")),
    ("arc_36_unexpected_hand", ("choices", 1, "text")),
    ("arc_36_unexpected_hand", ("choices", 1, "result_text")),
    ("arc_36_unexpected_hand_person_deal", ("description",)),
    ("arc_36_unexpected_hand_person_deal", ("choices", 0, "text")),
    ("arc_36_unexpected_hand_person_deal", ("choices", 0, "result_text")),
    ("arc_36_unexpected_hand_person_deal", ("choices", 1, "result_text")),
    ("arc_y4_three_promises", ("description",)),
    ("arc_y4_three_promises_jiyeon_and_deal", ("description",)),
    ("arc_y4_three_promises_deal_only", ("description",)),
    ("arc_y4_family_partner_collision", ("description",)),
    ("arc_y4_family_partner_collision_jiyeon", ("description",)),
)
_EN_THEME_EXTRA = (
    ("arc_y4_family_partner_collision", ("choices", 0, "result_text")),
    ("arc_y4_bill_night", ("description",)),
    ("arc_y4_bill_night", ("choices", 0, "result_text")),
    ("arc_y4_bill_night_jiyeon", ("description",)),
    ("arc_y4_bill_night_unattached", ("description",)),
    ("arc_y4_bill_night_unattached", ("choices", 0, "result_text")),
)
_DRAMA_LEAVES = (
    ("arc_father_call_on_ktx", ("description",)),
    ("arc_father_call_on_ktx_number", ("description",)),
)
CURRENT_PATHS = tuple(FILE_HASHES)
CURRENT_JSON_LEAVES = {
    f"content/{directory}/arc_chapter_themes.json": _THEME_LEAVES
    + (_EN_THEME_EXTRA if directory == "events_en" else ())
    for directory in ("events", "events_en", "events_ja", "events_zh-CN", "events_zh-TW")
}
CURRENT_JSON_LEAVES.update({
    f"content/{directory}/arc_drama.json": _DRAMA_LEAVES
    for directory in ("events", "events_en", "events_ja", "events_zh-CN", "events_zh-TW")
})
CURRENT_JSON_LEAVES["content/events_en/arc_new_characters.json"] = (
    ("arc_minseo_01_meet", ("description",)),
)
JSON_LEAVES = {p: CURRENT_JSON_LEAVES[p] for p in CURRENT_PATHS
               if p.startswith(("content/events/", "content/events_en/"))}
PATHS = tuple(JSON_LEAVES)
LIVE_PATHS = tuple(dict.fromkeys((*previous.LIVE_PATHS, *CURRENT_PATHS)))
HISTORICAL_PATHS = tuple(dict.fromkeys((*previous.HISTORICAL_PATHS, *PATHS)))
HISTORICAL_JSON_LEAVES = {
    p: tuple(dict.fromkeys((*previous.HISTORICAL_JSON_LEAVES.get(p, ()), *JSON_LEAVES.get(p, ()))))
    for p in HISTORICAL_PATHS
}
LIVE_EVENT_IDS = {
    p: frozenset(previous.LIVE_EVENT_IDS.get(p, ()))
    | frozenset(event for event, _ in CURRENT_JSON_LEAVES.get(p, ()))
    for p in LIVE_PATHS if p.endswith(".json") and p != LEDGER_PATH
}
MODULE_HASHES = {**previous.MODULE_HASHES,
    "tools/order350_source_compat.py": "05b0037f7c08889c9cf4a7ed13fa64c09bbd6139cb8c5af53a554f4abb010e60"}
BATCH_HASH = "ff01fa4d4118869e60ceee02818e6902768a0c35556081e4f47ac36ed15b501d"
_ACTIVE_PROOF = contextvars.ContextVar("order351_git_proof", default=None)
_sha = previous._sha
_canonical = previous._canonical
_digest = previous._digest
_ordered = previous._ordered
_loads = previous._loads
_rows = previous._rows
_leaf = previous._leaf
_set_leaf = previous._set_leaf
_Document = previous._Document


def _git(*args: str) -> bytes:
    result = subprocess.run(("git", *args), cwd=ROOT, capture_output=True)
    if result.returncode:
        raise ValueError("ORDER-351: immutable Git proof unavailable: " + " ".join(args))
    return result.stdout


def _git_blob(revision: str, relative: str) -> bytes:
    proof = _ACTIVE_PROOF.get()
    if proof is not None and (revision, relative) in proof:
        return proof[revision, relative]
    return _git("show", f"{revision}:{relative}")


def _verify_git_registration() -> None:
    if _git("rev-parse", AFTER_COMMIT + "^").decode().strip() != BEFORE_COMMIT:
        raise ValueError("ORDER-351: exact direct parent drifted")
    actual = _git("diff", "--name-status", "-z", BEFORE_COMMIT, AFTER_COMMIT).split(b"\0")
    expected = [part for p in sorted(CURRENT_PATHS) for part in (b"M", p.encode())] + [b""]
    if actual != expected:
        raise ValueError("ORDER-351: exact 12-path transition population drifted")


def _read_git_pairs() -> dict[tuple[str, str], bytes]:
    requests = [(rev, p) for p in CURRENT_PATHS for rev in (BEFORE_COMMIT, AFTER_COMMIT)]
    result = subprocess.run(("git", "cat-file", "--batch"), cwd=ROOT,
                            input="".join(f"{rev}:{p}\n" for rev, p in requests).encode(),
                            capture_output=True)
    if result.returncode:
        raise ValueError("ORDER-351: bulk immutable proof unavailable")
    cursor, blobs = 0, {}
    for request in requests:
        end = result.stdout.find(b"\n", cursor)
        header = result.stdout[cursor:end].split()
        if (end < cursor or len(header) != 3 or not re.fullmatch(rb"[0-9a-f]{40}", header[0])
                or header[1] != b"blob" or not header[2].isdigit()):
            raise ValueError("ORDER-351: malformed immutable blob " + str(request))
        size, cursor = int(header[2]), end + 1
        if result.stdout[cursor + size:cursor + size + 1] != b"\n":
            raise ValueError("ORDER-351: truncated immutable blob " + str(request))
        blobs[request] = result.stdout[cursor:cursor + size]
        cursor += size + 1
    if cursor != len(result.stdout):
        raise ValueError("ORDER-351: trailing bulk proof bytes")
    return blobs


def _verify_original_modules() -> dict[str, bytes]:
    original309 = previous.previous.previous
    modules = (original309.original305, original309.original310, original309.previous,
               original309, previous.previous, previous)
    blobs = {}
    for (relative, digest), module in zip(MODULE_HASHES.items(), modules):
        raw = _git_blob(BEFORE_COMMIT, relative)
        if (_sha(raw) != digest or Path(module.__file__).resolve() != ROOT / relative
                or module.ROOT != ROOT or (ROOT / relative).read_bytes() != raw):
            raise ValueError("ORDER-351: original module/import identity drifted " + relative)
        blobs[relative] = raw
    return blobs


@contextlib.contextmanager
def fresh_validation_proof():
    """Fresh outer invocation; nested callers share immutable reads, not admission."""
    if _ACTIVE_PROOF.get() is not None:
        yield
        return
    _verify_git_registration()
    token = _ACTIVE_PROOF.set(_read_git_pairs())
    try:
        with previous.fresh_validation_proof():
            _verify_original_modules()
            yield
    finally:
        _ACTIVE_PROOF.reset(token)


def _verify_json_delta(before: bytes, after: bytes, relative: str) -> None:
    old_doc, new_doc = _Document(before), _Document(after)
    old, new = old_doc.value, new_doc.value
    old_rows, new_rows = _rows(old), _rows(new)
    if list(old_rows) != list(new_rows):
        raise ValueError("ORDER-351: event roster/order drifted " + relative)
    restored = copy.deepcopy(new)
    restored_rows = _rows(restored)
    indexes = {row["id"]: i for i, row in enumerate(new)}
    replacements = []
    for event, path in CURRENT_JSON_LEAVES[relative]:
        old_text, new_text = _leaf(old_rows[event], path), _leaf(new_rows[event], path)
        if not isinstance(old_text, str) or not isinstance(new_text, str) or old_text == new_text:
            raise ValueError("ORDER-351: declared existing text delta drifted " + event)
        # Only this approved note-removal changes paragraphs.  The immutable
        # whole-file pair additionally binds the exact old and new wording.
        newline_exception = (relative == "content/events_en/arc_new_characters.json"
                             and event == "arc_minseo_01_meet" and path == ("description",)
                             and (old_text.count("\n"), new_text.count("\n")) == (8, 6))
        if (TOKEN_RE.findall(old_text) != TOKEN_RE.findall(new_text)
                or (old_text.count("\n") != new_text.count("\n") and not newline_exception)):
            raise ValueError("ORDER-351: token/newline boundary drifted " + event)
        location = (indexes[event], *path)
        a, b = old_doc.spans[location]
        start, end = new_doc.spans[location]
        replacements.append((start, end, old_doc.text[a:b]))
        _set_leaf(restored_rows[event], path, old_text)
    raw = new_doc.text
    for start, end, text in sorted(replacements, reverse=True):
        raw = raw[:start] + text + raw[end:]
    if raw.encode() != before or _ordered(restored) != _ordered(old):
        raise ValueError("ORDER-351: non-owned raw/JSON source drifted " + relative)


def _verify_receipt_delta(before: bytes, after: bytes,
                          texts: dict[str, tuple[bytes, bytes]]) -> None:
    old, new = _loads(before), _loads(after)
    owned = {"accepted", "accepted_sha256", "batches"}
    if (list(old) != list(new)
            or _ordered({k: v for k, v in old.items() if k not in owned})
            != _ordered({k: v for k, v in new.items() if k not in owned})):
        raise ValueError("ORDER-351: receipt metadata drifted")
    if ([len(x["batches"]) for x in (old, new)] != [141, 142]
            or _ordered(new["batches"][:-1]) != _ordered(old["batches"])
            or _digest(new["batches"][-1]) != BATCH_HASH):
        raise ValueError("ORDER-351: immutable batch history drifted")
    if list(old["accepted"]) != list(new["accepted"]) or set(new["accepted"]) != set(LOCALES):
        raise ValueError("ORDER-351: receipt locale population drifted")
    for locale in LOCALES:
        edits = set()
        prior, current = old["accepted"][locale], new["accepted"][locale]
        for relative, leaves in CURRENT_JSON_LEAVES.items():
            if not relative.startswith(f"content/events_{locale}/"):
                continue
            ko_path = relative.replace(f"events_{locale}/", "events/", 1)
            ko = [_rows(_loads(raw)) for raw in texts[ko_path]]
            target = [_rows(_loads(raw)) for raw in texts[relative]]
            for event, path in leaves:
                receipt_id = f"events:{event}:/" + "/".join(map(str, path))
                edits.add(receipt_id)
                for index, accepted in enumerate((prior, current)):
                    if accepted.get(receipt_id) != previous._receipt(ko[index][event], ko_path,
                                                                   target[index][event], path):
                        raise ValueError("ORDER-351: receipt text binding drifted " + receipt_id)
        if (len(edits) != 16 or list(current) != list(prior)
                or {k for k in prior if prior[k] != current.get(k)} != edits):
            raise ValueError("ORDER-351: non-owned receipt/key/order drifted " + locale)
    for ledger in (old, new):
        if (sum(map(len, ledger["accepted"].values())) != 40302
                or ledger["accepted_sha256"] != _digest(ledger["accepted"])):
            raise ValueError("ORDER-351: receipt total/checksum drifted")


@functools.lru_cache(maxsize=12)
def _verify_transition(before: bytes, after: bytes, relative: str,
                       receipt_texts: tuple = ()) -> None:
    # Memoize only immutable byte arguments. Git provenance is never cached
    # across validation invocations, including after a previous successful call.
    if (_sha(before), _sha(after)) != FILE_HASHES[relative]:
        raise ValueError("ORDER-351: immutable raw hashes drifted " + relative)
    if relative == LEDGER_PATH:
        _verify_receipt_delta(before, after, {p: (a, b) for p, a, b in receipt_texts})
    else:
        _verify_json_delta(before, after, relative)


def verified_blobs(relative: str) -> tuple[bytes, bytes]:
    """Own paths: pre351/current; old-only paths: original350 predecessor/latest."""
    if _ACTIVE_PROOF.get() is None:
        with fresh_validation_proof():
            return verified_blobs(relative)
    if relative not in CURRENT_PATHS:
        return previous.verified_blobs(relative)
    before, after = (_git_blob(revision, relative) for revision in (BEFORE_COMMIT, AFTER_COMMIT))
    texts = ()
    if relative == LEDGER_PATH:
        texts = tuple((p, *verified_blobs(p)) for p in CURRENT_JSON_LEAVES
                      if not p.startswith("content/events_en/"))
    _verify_transition(before, after, relative, texts)
    if relative in previous.LIVE_PATHS and previous.source_errors(before, relative):
        raise ValueError("ORDER-351: predecessor does not bind to original350 chain " + relative)
    return before, after


def inverse_351_bytes(raw: bytes, relative: str) -> bytes:
    if relative not in PATHS or _sha(raw) != FILE_HASHES[relative][1]:
        return raw
    try:
        before, after = verified_blobs(relative)
        return before if raw == after else raw
    except (OSError, ValueError):
        return raw


def inverse_351_payload(payload: Any, relative: str) -> Any:
    """Restore only complete exact owned rows in a comparison-only copy."""
    projected = copy.deepcopy(payload)
    if relative not in PATHS or not isinstance(payload, list):
        return projected
    try:
        rows = _rows(projected)
        if not any(event in rows for event, _ in JSON_LEAVES[relative]):
            return projected
        old, new = (_rows(_loads(raw)) for raw in verified_blobs(relative))
        for event in dict.fromkeys(event for event, _ in JSON_LEAVES[relative]):
            if event not in rows or _ordered(rows[event]) != _ordered(new[event]):
                continue
            for owner, path in JSON_LEAVES[relative]:
                if owner == event:
                    _set_leaf(rows[event], path, _leaf(old[event], path))
    except (OSError, ValueError, KeyError, TypeError, IndexError):
        return copy.deepcopy(payload)
    return projected


def inverse_351_hash(digest: str, relative: str) -> str:
    if relative in PATHS and digest == FILE_HASHES[relative][1]:
        try:
            before, after = verified_blobs(relative)
            return _sha(before) if digest == _sha(after) else digest
        except (OSError, ValueError):
            pass
    return digest


def _compose(value: Any, relative: str, inverse, next_step):
    if relative in CURRENT_PATHS and relative not in PATHS:
        return copy.deepcopy(value)
    if relative not in HISTORICAL_PATHS:
        return next_step(value, relative)
    original = value
    try:
        with fresh_validation_proof():
            verified_blobs(relative)
            if relative in PATHS:
                value = inverse(value, relative)
            return next_step(value, relative)
    except (OSError, ValueError):
        # Missing new proof may not be masked by successful older projection.
        return copy.deepcopy(original)


def inverse_current_bytes(raw: bytes, relative: str) -> bytes:
    """Post305 comparison only: undo351 -> 359/350 -> 313 -> 309."""
    return _compose(raw, relative, inverse_351_bytes, previous.inverse_current_bytes)


def inverse_current_payload(payload: Any, relative: str) -> Any:
    return _compose(payload, relative, inverse_351_payload, previous.inverse_current_payload)


def inverse_current_hash(digest: str, relative: str) -> str:
    return _compose(digest, relative, inverse_351_hash, previous.inverse_current_hash)


def project_bytes(raw: bytes, relative: str) -> bytes:
    return _compose(raw, relative, inverse_351_bytes, previous.project_bytes)


def project_payload(payload: Any, relative: str) -> Any:
    return _compose(payload, relative, inverse_351_payload, previous.project_payload)


def project_byte_hash(digest: str, relative: str) -> str:
    return _compose(digest, relative, inverse_351_hash, previous.project_byte_hash)


def historical_blobs(relative: str) -> tuple[bytes, bytes]:
    if relative not in HISTORICAL_PATHS:
        raise ValueError("ORDER-351: unregistered historical path " + relative)
    with fresh_validation_proof():
        _, current = verified_blobs(relative)
        return inverse_current_bytes(current, relative), current


def source_errors(raw: bytes, relative: str) -> list[str]:
    if relative not in CURRENT_PATHS:
        return previous.source_errors(raw, relative)
    if _sha(raw) != FILE_HASHES[relative][1]:
        return ["ORDER-351: current source exceeds exact approved successor " + relative]
    try:
        _, after = verified_blobs(relative)
        return [] if raw == after else ["ORDER-351: immutable raw proof mismatch " + relative]
    except (OSError, ValueError) as exc:
        return [str(exc)]


def current_source_errors(root: Path = ROOT) -> list[str]:
    errors = []
    try:
        with fresh_validation_proof():
            for relative in LIVE_PATHS:
                try:
                    errors.extend(source_errors((root / relative).read_bytes(), relative))
                except OSError as exc:
                    errors.append("ORDER-351: current source unavailable " + relative + ": " + str(exc))
    except (OSError, ValueError) as exc:
        errors.append(str(exc))
    return errors


def source_observation_errors(raw: bytes, payload: Any, relative: str) -> list[str]:
    errors = source_errors(raw, relative)
    try:
        if _ordered(_loads(raw)) != _ordered(payload):
            errors.append("ORDER-351: observed payload not bound to raw bytes " + relative)
    except (ValueError, TypeError, UnicodeError):
        errors.append("ORDER-351: malformed raw/payload observation " + relative)
    return errors


def observed_byte_hash(relative: str, observed: str, raw: bytes) -> tuple[str, list[str]]:
    errors = source_errors(raw, relative)
    if _sha(raw) != observed:
        errors.append("ORDER-351: observed hash not bound to raw bytes " + relative)
    if errors:
        return observed, errors
    if relative in HISTORICAL_PATHS:
        return inverse_current_hash(observed, relative), []
    if relative in CURRENT_PATHS:
        return observed, []
    return previous.observed_byte_hash(relative, observed, raw)


def _run_isolated_350() -> dict[str, Any]:
    """Run the unchanged 998-case CLI on actual pre351 bytes, not today's root."""
    blobs = _verify_original_modules()
    live_hashes = {}
    with previous.fresh_validation_proof():
        for relative in previous.LIVE_PATHS:
            raw = _git_blob(BEFORE_COMMIT, relative)
            errors = previous.source_errors(raw, relative)
            if errors:
                raise ValueError("ORDER-351: pre351 fixture admission: " + "; ".join(errors))
            blobs[relative] = raw
            live_hashes[relative] = _sha(raw)
    if len(live_hashes) != 38:
        raise ValueError("ORDER-351: isolated pre351 live population drifted")
    git_dir = Path(_git("rev-parse", "--absolute-git-dir").decode().strip())
    scratch = git_dir / "full-game-localization"
    scratch.mkdir(parents=True, exist_ok=True)
    with tempfile.TemporaryDirectory(prefix="order361-original350-", dir=scratch) as directory:
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
        raise RuntimeError('isolated module/import identity mismatch: ' + relative)
    identity[relative] = {'file': str(path), 'root': str(module.ROOT), 'sha256': digest}
print('ORDER351_ISOLATED_IDENTITY ' + json.dumps(identity, sort_keys=True), flush=True)
sys.argv = [str(root / 'tools/order350_source_compat.py'), '--self-test']
raise SystemExit(importlib.import_module('order350_source_compat').main())
"""
        env = dict(os.environ, GIT_DIR=str(git_dir), GIT_WORK_TREE=str(root),
                   GIT_OPTIONAL_LOCKS="0", PYTHONDONTWRITEBYTECODE="1")
        command = (sys.executable, "-I", "-B", "-c", runner, str(root), json.dumps(MODULE_HASHES))
        timed_out = False
        try:
            process = subprocess.run(command, cwd=root, env=env, capture_output=True,
                                     text=True, timeout=1200)
        except subprocess.TimeoutExpired as exc:
            timed_out = True
            def partial(value):
                return value.decode("utf-8", errors="replace") if isinstance(value, bytes) else value or ""
            process = subprocess.CompletedProcess(command, -1, partial(exc.stdout), partial(exc.stderr))
        marker = ("ORDER350_SOURCE_OK current_files=21 leaves=106 receipts=57 "
                  "new_receipts=3 historical_files=9 historical_leaves=49 live_files=38 "
                  "historical_union=14 units=350,359 cases=998")
        errors = ["unmodified isolated ORDER-350 CLI timed out after1200s"] if timed_out else []
        if process.returncode or marker not in process.stdout.splitlines() or process.stderr.strip():
            errors.append("unmodified isolated ORDER-350 CLI failed")
        identity_lines = [line.removeprefix("ORDER351_ISOLATED_IDENTITY ")
                          for line in process.stdout.splitlines()
                          if line.startswith("ORDER351_ISOLATED_IDENTITY ")]
        identities = json.loads(identity_lines[0]) if len(identity_lines) == 1 else {}
        if set(identities) != set(MODULE_HASHES):
            errors.append("isolated module identity output missing")
        for relative, raw in blobs.items():
            if (root / relative).read_bytes() != raw:
                errors.append("isolated original fixture changed " + relative)
        return {"corpus": "ORDER-350", "cases": 998 if not errors else 0,
                "source_revision": BEFORE_COMMIT, "live_files": live_hashes,
                "modules": identities, "errors": errors, "returncode": process.returncode,
                "stdout": process.stdout, "stderr": process.stderr,
                "command": list(command), "timeout_seconds": 1200, "timed_out": timed_out,
                "meaning": "historical CLI on immutable pre351 fixture, not current admission"}


def historical_self_test() -> tuple[list[str], int, list[dict[str, Any]]]:
    """Keep original301 current callers and isolated309/313/350 CLI meanings."""
    errors, cases, results = current_source_errors(), 0, []
    if errors:
        return errors, cases, results
    try:
        _verify_original_modules()
        # These original functions deliberately import the real current callers.
        # The three later CLIs instead require their own immutable live roots.
        failures, count, original = previous.previous.previous.historical_self_test()
        errors.extend(failures)
        cases += count
        for item in original:
            item["meaning"] = "unchanged original function corpus using actual current consumers"
        results.extend(original)
        for runner in (previous.previous._run_isolated_309,
                       previous._run_isolated_313, _run_isolated_350):
            result = runner()
            errors.extend(result["errors"])
            cases += result["cases"]
            results.append(result)
    except (OSError, ValueError, subprocess.TimeoutExpired) as exc:
        errors.append("ORDER-351: historical corpus unavailable: " + str(exc))
    if cases != 1955:
        errors.append(f"ORDER-351: expected historical cases1955 observed{cases}")
    return errors, cases, results


def self_test() -> tuple[list[str], int]:
    """Actual current positives and fail-closed transition/admission negatives."""
    from unittest import mock
    failures, cases = [], 0

    def check(ok, label):
        nonlocal cases
        cases += 1
        if not ok:
            failures.append(label)

    def rejected(call, label):
        try:
            call()
        except (OSError, ValueError, TypeError, KeyError, IndexError):
            check(True, label)
        else:
            check(False, label)

    check(len(CURRENT_PATHS) == 12 and len(CURRENT_JSON_LEAVES) == 11
          and sum(map(len, CURRENT_JSON_LEAVES.values())) == 87 and len(LIVE_PATHS) == 44,
          "current population 12paths/87leaves union44")
    check(len(PATHS) == 5 and sum(map(len, JSON_LEAVES.values())) == 39
          and len(HISTORICAL_PATHS) == 17
          and sum(map(len, HISTORICAL_JSON_LEAVES.values())) == 107,
          "historical population 5files/39leaves union17/107")
    check(not current_source_errors(), "actual current whole-union admission")
    check(len(_verify_original_modules()) == 6, "six original module identities")
    with fresh_validation_proof():
        blobs = {p: verified_blobs(p) for p in CURRENT_PATHS}
        for relative, (before, after) in blobs.items():
            old, new = _loads(before), _loads(after)
            check((ROOT / relative).read_bytes() == after and not source_errors(after, relative),
                  relative + " current exact bytes")
            check(not source_observation_errors(after, new, relative), relative + " raw/payload binding")
            check(not observed_byte_hash(relative, _sha(after), after)[1], relative + " raw/hash binding")
            check(bool(source_observation_errors(after, old, relative)), relative + " stale payload")
            check(bool(observed_byte_hash(relative, _sha(before), after)[1]), relative + " stale hash")
            for label, raw in (("rollback", before), ("raw format", after + b"\n"),
                               ("empty", b""), ("malformed", b"[")):
                check(bool(source_errors(raw, relative)) and inverse_351_bytes(raw, relative) == raw
                      and inverse_351_hash(_sha(raw), relative) == _sha(raw), relative + " rejects " + label)
            check(bool(source_errors(after, relative + ".wrong")), relative + " wrong path")
            if relative not in PATHS:
                check(inverse_current_bytes(after, relative) == after
                      and inverse_current_payload(new, relative) == new
                      and inverse_current_hash(_sha(after), relative) == _sha(after)
                      and project_bytes(after, relative) == after
                      and project_payload(new, relative) == new
                      and project_byte_hash(_sha(after), relative) == _sha(after),
                      relative + " prepared targets/ledger stay current")
            else:
                check(inverse_351_bytes(after, relative) == before
                      and inverse_351_payload(new, relative) == old
                      and inverse_351_hash(_sha(after), relative) == _sha(before),
                      relative + " exact351 inverse")
                check(project_bytes(after, relative) == previous.project_bytes(before, relative)
                      and project_payload(new, relative) == previous.project_payload(old, relative)
                      and project_byte_hash(_sha(after), relative) == previous.project_byte_hash(_sha(before), relative),
                      relative + " complete historical chain")
                check(inverse_current_bytes(after, relative) == previous.inverse_current_bytes(before, relative)
                      and inverse_current_payload(new, relative) == previous.inverse_current_payload(old, relative),
                      relative + " post305 comparison")
                saved = copy.deepcopy(new)
                check(inverse_351_payload(list(reversed(new)), relative) == list(reversed(old)) and new == saved,
                      relative + " projection preserves input/row order")
            if relative not in CURRENT_JSON_LEAVES:
                continue
            old_rows, new_rows = _rows(old), _rows(new)
            for event, path in CURRENT_JSON_LEAVES[relative]:
                for label, value in (("mutation", "unapproved"), ("type", 351),
                                     ("partial rollback", _leaf(old_rows[event], path))):
                    mutated = copy.deepcopy(new_rows[event])
                    _set_leaf(mutated, path, value)
                    check(bool(source_observation_errors(after, [mutated], relative))
                          and inverse_351_payload([mutated], relative) == [mutated],
                          f"{relative}:{event}:{path} {label}")
            event = CURRENT_JSON_LEAVES[relative][0][0]
            for field, value in (("title", "neighbor"), ("conditions", {"money": 1}),
                                 ("id", "wrong-id"), ("extra_key", "unapproved")):
                mutated = copy.deepcopy(new_rows[event])
                mutated[field] = value
                check(inverse_351_payload([mutated], relative) == [mutated], relative + " altered " + field)
            duplicate = [new_rows[event], copy.deepcopy(new_rows[event])]
            check(inverse_351_payload(duplicate, relative) == duplicate
                  and bool(source_observation_errors(after, duplicate, relative)), relative + " duplicate event")
            check(inverse_351_payload([], relative) == []
                  and bool(source_observation_errors(after, [], relative)), relative + " missing event")
            reordered = dict(reversed(list(new_rows[event].items())))
            check(inverse_351_payload([reordered], relative) == [reordered]
                  and bool(source_observation_errors(after, [reordered], relative)), relative + " key order")
            rejected(lambda: _verify_json_delta(before, after + b"\n", relative), relative + " raw formatting proof")
            for invalid in (None, {}, [None], [{"id": ""}], [{"id": "other", "description": "unowned"}]):
                check(inverse_351_payload(invalid, relative) == invalid, relative + " malformed/unowned projection")
        # The new owned conditional has one key, so reversing it would be a
        # false negative fixture. Exercise the actual multi-key prior layer.
        conditional = "content/events/arc_year_close.json"
        conditional_raw = (ROOT / conditional).read_bytes()
        row = copy.deepcopy(_rows(_loads(conditional_raw))["arc_year3_close"])
        row["description_if_known"] = dict(reversed(list(row["description_if_known"].items())))
        check(project_payload([row], conditional) == [row]
              and bool(source_observation_errors(conditional_raw, [row], conditional)),
              "condition priority order rejected")
        for relative in HISTORICAL_PATHS:
            historical, current = historical_blobs(relative)
            check(current == (ROOT / relative).read_bytes()
                  and historical == inverse_current_bytes(current, relative)
                  and not source_errors(current, relative), relative + " union historical binding")
        before, after = blobs[LEDGER_PATH]
        old, new = _loads(before), _loads(after)
        texts = {p: blobs[p] for p in CURRENT_JSON_LEAVES if not p.startswith("content/events_en/")}
        for locale in LOCALES:
            changed = [k for k in new["accepted"][locale]
                       if new["accepted"][locale][k] != old["accepted"][locale].get(k)]
            check(len(changed) == 16, locale + " existing16 receipt census")
            for key in changed:
                for field in ("source_sha256", "target_sha256"):
                    mutant = copy.deepcopy(new)
                    mutant["accepted"][locale][key][field] = "0" * 64
                    mutant["accepted_sha256"] = _digest(mutant["accepted"])
                    rejected(lambda: _verify_receipt_delta(before, _ordered(mutant), texts),
                             locale + ":" + key + ":" + field)
        for label, mutate in (
            ("old batch", lambda x: x["batches"][0].update({"order": "forged"})),
            ("new batch", lambda x: x["batches"][-1].update({"native_review": "GO"})),
            ("metadata", lambda x: x.update({"full_game_status": "GO"})),
            ("receipt removed", lambda x: x["accepted"]["ja"].pop(next(iter(x["accepted"]["ja"])))),
            ("receipt added", lambda x: x["accepted"]["ja"].update({"unapproved": {}})),
        ):
            mutant = copy.deepcopy(new)
            mutate(mutant)
            mutant["accepted_sha256"] = _digest(mutant["accepted"])
            rejected(lambda: _verify_receipt_delta(before, _ordered(mutant), texts), label)
        # The entire rollback/mixed-root series is one invocation, never a
        # cross-invocation proof cache; each actual file is read on every pass.
        scratch = Path(_git("rev-parse", "--absolute-git-dir").decode().strip()) / "full-game-localization"
        scratch.mkdir(parents=True, exist_ok=True)
        with tempfile.TemporaryDirectory(prefix="order361-mixed-", dir=scratch) as directory:
            root = Path(directory)
            for relative in LIVE_PATHS:
                target = root / relative
                target.parent.mkdir(parents=True, exist_ok=True)
                target.write_bytes((ROOT / relative).read_bytes())
            check(not current_source_errors(root), "copied exact live44 root")
            for relative in LIVE_PATHS:
                target = root / relative
                raw = target.read_bytes()
                target.write_bytes(raw + b"\n")
                check(bool(current_source_errors(root)), "live union raw drift " + relative)
                target.write_bytes(raw)
            for relative, (before, after) in blobs.items():
                (root / relative).write_bytes(before)
                check(bool(current_source_errors(root)), "mixed prior/latest " + relative)
                (root / relative).write_bytes(after)
            for relative, (before, _) in blobs.items():
                (root / relative).write_bytes(before)
            check(bool(current_source_errors(root)), "whole pre351 rollback")
    # Warm proof tampering occurs after normal identity checks so identity
    # rejection cannot hide the stage-proof negative being exercised.
    for relative in CURRENT_PATHS:
        after = blobs[relative][1]
        new = _loads(after)
        for label, proof in (("missing", mock.Mock(side_effect=OSError("missing immutable proof"))),
                             ("altered", lambda rev, path: _git("show", f"{rev}:{path}") + b"\n")):
            with fresh_validation_proof(), mock.patch(__name__ + "._git_blob", proof):
                check(bool(source_errors(after, relative))
                      and inverse_current_bytes(after, relative) == after
                      and inverse_current_payload(new, relative) == new
                      and inverse_current_hash(_sha(after), relative) == _sha(after)
                      and project_bytes(after, relative) == after
                      and project_payload(new, relative) == new
                      and project_byte_hash(_sha(after), relative) == _sha(after), relative + " warm " + label + " proof")
    for raw in (b'{"a":1,"a":2}', b'[NaN]', b'[Infinity]', b'[-Infinity]', b'[1e999]'):
        rejected(lambda: _loads(raw), "strict JSON " + raw.decode())
    for value in (float("nan"), float("inf"), float("-inf")):
        path = PATHS[0]
        check(bool(source_observation_errors(blobs[path][1], [value], path)), "nonfinite payload")
    original309 = previous.previous.previous
    for module in (original309.original305, original309.original310, original309.previous,
                   original309, previous.previous, previous):
        with mock.patch.object(module, "ROOT", ROOT / "wrong-root"):
            check(bool(current_source_errors()), module.__name__ + " wrong imported ROOT")
        with mock.patch.object(module, "__file__", str(ROOT / "wrong-module.py")):
            check(bool(current_source_errors()), module.__name__ + " wrong imported file")
    real_blob = _git_blob
    for module_path in MODULE_HASHES:
        def changed_module_blob(revision, relative):
            raw = real_blob(revision, relative)
            return raw + b"\n" if relative == module_path else raw
        with mock.patch(__name__ + "._git_blob", changed_module_blob):
            check(bool(current_source_errors()), module_path + " altered original Git bytes")
    real_git = _git
    for label, command, reply in (("parent", "rev-parse", b"0" * 40 + b"\n"),
                                   ("population", "diff", b"")):
        def changed_git(*args):
            return reply if args[0] == command else real_git(*args)
        with mock.patch(__name__ + "._git", changed_git):
            check(bool(current_source_errors()), "wrong immutable " + label)
    check(_ACTIVE_PROOF.get() is None, "no leaked proof before scope test")
    with fresh_validation_proof():
        first = _ACTIVE_PROOF.get()
        check(len(first) == 24, "12 immutable pairs")
        with fresh_validation_proof():
            check(_ACTIVE_PROOF.get() is first, "nested same invocation snapshot")
    check(_ACTIVE_PROOF.get() is None, "normal scope cleanup")
    with fresh_validation_proof():
        check(_ACTIVE_PROOF.get() is not first, "fresh next invocation")
    try:
        with fresh_validation_proof():
            raise RuntimeError("intentional cleanup test")
    except RuntimeError:
        pass
    check(_ACTIVE_PROOF.get() is None, "exception cleanup")
    with mock.patch(__name__ + "._git", side_effect=OSError("Git unavailable")):
        check(bool(current_source_errors()), "proof unavailable before context entry")
    check(_ACTIVE_PROOF.get() is None, "failed entry cleanup")
    return failures, cases


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    mode = parser.add_mutually_exclusive_group()
    mode.add_argument("--self-test", action="store_true")
    mode.add_argument("--historical-self-test", action="store_true")
    args = parser.parse_args()
    errors, cases = current_source_errors(), 0
    if args.self_test and not errors:
        failures, cases = self_test()
        errors.extend(failures)
    if args.historical_self_test and not errors:
        failures, cases, results = historical_self_test()
        errors.extend(failures)
        for result in results:
            print("ORDER351_ORIGINAL_CORPUS " + json.dumps(result, ensure_ascii=False, sort_keys=True))
    for error in errors:
        print("ORDER351_SOURCE_ERROR " + error)
    marker = "ORDER351_HISTORICAL" if args.historical_self_test else "ORDER351_SOURCE"
    print(f"{marker}_{'FAIL' if errors else 'OK'} current_files=11 leaves=87 receipts=48 "
          f"new_receipts=0 historical_files=5 historical_leaves=39 live_files={len(LIVE_PATHS)} "
          f"historical_union={len(HISTORICAL_PATHS)} units=351 cases={cases}")
    return int(bool(errors))


if __name__ == "__main__":
    raise SystemExit(main())
