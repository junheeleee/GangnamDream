#!/usr/bin/env python3
"""Admit ORDER-365 and source-bound, append-only Chinese UI receipts above it.

This is a current-observation boundary, not an event-history projection.
ORDER-351 and its seven historical comparison APIs/corpora remain untouched.
"""
from __future__ import annotations

import argparse
import contextlib
import contextvars
import copy
import functools
import hashlib
import itertools
import json
import re
import subprocess
from pathlib import Path
from typing import Any, Mapping

import order351_source_compat as previous
import ui_translation_append as ui_append
import coffee_encounter_receipt_history as coffee_history
import coin_call_receipt_history as coin_history

ROOT = Path(__file__).resolve().parents[1]
LEDGER_PATH = "content/meta/full_game_localization.json"
LOCALES = ("zh-CN", "zh-TW")
UI_PATHS = tuple(f"locale/ui_{locale}.json" for locale in LOCALES)
CURRENT_PATHS = (*UI_PATHS, LEDGER_PATH)
LIVE_PATHS = tuple(dict.fromkeys((*previous.LIVE_PATHS, *ui_append.CURRENT_UI_PATHS,
                                *coin_history.EVENT_PATHS)))
# An additional current dictionary, not part of the immutable three-file365 delta.
JA_BASELINE_BLOB = "11cdf6beae26d2eb2174af79253cfe802254079e"
JA_BASELINE_SHA256 = "9881e43fc34ac67241dc4819068f0dcda8ee714119778d059ddd7088fce75f1d"
PREVIOUS_MODULE_PATH = "tools/order351_source_compat.py"
PREVIOUS_MODULE_SHA256 = "0d5de5fa6d80a87f1794f0ccfabee5b972feb195d09703474f040cb5481314ff"
RUNTIME_PATH = "scenes/JobHuntMiniGame.gd"
RUNTIME_COMPARISON_PATHS = (RUNTIME_PATH, ui_append.ARUBA_FONT_PATH)
KEYS = (
    "자기소개서 완성", "모의 면접 종료", "첫 장으로 돌아간 원고", "마지막 답 뒤 이어진 질문",
    "멈춰 다시 읽은 줄", "메모가 남은 면접", "끝까지 쓴 한 장", "예정된 마지막 질문",
    "다시 고칠 표시가 많은 초안", "일찍 닫힌 수첩", "첫 장으로 돌아가 경력 문장을 한 번 더 고쳤다.",
    "면접관이 정해 둔 시간을 넘겨 다음 질문을 꺼냈다.", "경력 문장 옆에 고쳐 쓸 표시 하나가 남았다.",
    "면접관은 답변 하나를 적고 마지막 질문까지 이어 갔다.", "마지막 줄까지 썼지만 접힌 모서리나 메모는 남지 않았다.",
    "면접관은 고개를 한 번 끄덕인 뒤 예정된 질문만 마쳤다.", "끝까지 썼지만 네 답 옆에는 근거를 다시 채울 표시가 남았다.",
    "면접관은 수첩을 먼저 닫았고, 방 안의 침묵이 길어졌다.", "화면을 닫고도 어깨의 힘이 오래 빠지지 않았다.",
    "마지막 문장을 저장하자 막혔던 숨이 조금 풀렸다.", "문을 닫고 나와도 어깨의 힘이 오래 빠지지 않았다.",
    "밖으로 나오자 막혔던 숨이 조금 풀렸다.",
)

# Sealed from the actual product commit and official import receipts, not HEAD.
BEFORE_COMMIT = "3401d6283e1c1e83bedf0608afb2e7942d9c04c8"
AFTER_COMMIT = "003b68c7491333285b2c545bd9c95761efea05c0"
BEFORE_TREE = "673e54305fdd7df5af2aab97b2462ed30c284bad"
AFTER_TREE = "62f6f93d93218aab80dd30f90cedce7ee5265c63"
FILE_HASHES: dict[str, tuple[str, str]] = {
    "locale/ui_zh-CN.json": ("efcbfb55b62ad640a744f332fd69d05c65b2cdbf782e0cfb7885920d1013561c",
                             "35e3b0a7a01976213d9d7aa4d709e2e9fb9b7c405e6ef09c038af9aae2fdf859"),
    "locale/ui_zh-TW.json": ("7f2aaac865ed2e89920ccffaa8a258ca984e1d01f9307bd0012653276796af68",
                             "c48b67ec15cc37c7af2cf2107bc0559876b6bb330d7c57791acf469175f19862"),
    LEDGER_PATH: ("451995650b797fd9f112887026ea55f43b1edda4d204e16ecfdf66d57ef61805",
                  "bb5522252e7a8fd86203ea45f41575180e76b658ae2c7112162878975c3b1080"),
}
FILE_BLOBS: dict[str, tuple[str, str]] = {
    "locale/ui_zh-CN.json": ("b7524a576fcde4bd970d558d10ccf2508330d2ad", "d8a5787eefc779268cbeda0c2e5df70e974a6ab1"),
    "locale/ui_zh-TW.json": ("d4431e77e68e1f635f89ebb94998f8acc9297fbb", "f9f56fd123cbf079bb427de4a3b8d97ed986efb6"),
    LEDGER_PATH: ("34712e834dd1541bdb969a968db48670c17ae398", "f864fecafab5d935d0d373e491a1a59fa1eb240f"),
}
DEPENDENCIES: dict[str, tuple[str, str]] = {
    PREVIOUS_MODULE_PATH: ("c95e392bac6668c788932ed1ad41874d1c620dbb", PREVIOUS_MODULE_SHA256),
    RUNTIME_PATH: ("59e66b4f502a0da3bd33a5fd8f0247fa2eef606b", "d737a4fcda1619dab86a3da89a726a385d1b4751002217616c9b366917301d4b"),
}
# The original runtime dependency above remains the ORDER-365 comparison.
# Only this separately proved local-font successor is admitted as current.
FONT_BEFORE_COMMIT = "73adabd958429d746c9197eb4ce86b979e7c7cf0"
FONT_AFTER_COMMIT = "fb007ebecb2f0d877635f1215e657d185c64f731"
FONT_BEFORE_TREE = "5e64fb40f49ebe16862bf063f6fec2dec46606be"
FONT_AFTER_TREE = "07277884cb0ac50b9d05edfe4872c4d13c30db7f"
FONT_AFTER_BLOB = "60d1714ba4604694bbf71bd6e8e61ca13b882c2e"
FONT_AFTER_SHA256 = "d7394c2308cad6f5f0712b0bcfced9d4e23c69132e8ad55d74a1cf9d365d7618"
FONT_ANCHOR = (b"func _ready() -> void:\n"
               b"\tset_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)\n")
FONT_ADDITION = (b"\tvar local_theme := Theme.new()\n"
                 b"\tlocal_theme.default_font = FontKit.ui_regular()\n"
                 b"\ttheme = local_theme\n")
RECEIPT_BATCHES: dict[str, dict] = {
    "zh-CN": {
        "kind": "full_game_localization_batch", "schema_version": 1, "locale": "zh-CN",
        "source_revision": BEFORE_COMMIT, "prompt_version": "full-ko-direct-2026-09-07.1",
        "source_manifest_sha256": "56eb815e61b5ca714766056a3f7c85a34643057c1c8f237e3fa9118620133548",
        "selection_sha256": "9dbe943cb574d56a95216a23e0a912dfc71acd70f1fe8e392cc08af85e0c6908",
        "count": 22, "source_language": "ko", "native_review": "OPEN",
        "batch_id": "f7b84bee384e37317db5372ee81193f0caa0e5e816e56c8610fc1c66ad949755",
    },
    "zh-TW": {
        "kind": "full_game_localization_batch", "schema_version": 1, "locale": "zh-TW",
        "source_revision": BEFORE_COMMIT, "prompt_version": "full-ko-direct-2026-09-07.1",
        "source_manifest_sha256": "56eb815e61b5ca714766056a3f7c85a34643057c1c8f237e3fa9118620133548",
        "selection_sha256": "b5f161f2f0245ee63fb9255f3ccc2e566286e5ce93a4e5d5c2c672e6483ee5bb",
        "count": 22, "source_language": "ko", "native_review": "OPEN",
        "batch_id": "44e08d461ce25a63d9b2479da32b5851fe9f1e27b37637a42bcfd57cdf72f6b1",
    },
}
RECEIPT_HASHES: dict[str, str] = {
    "zh-CN": "31e2c627590e744bd407cac91055c109236e91ba9b35341c67c3bfb4e4d0bd00",
    "zh-TW": "d6a568875ccf8430287fab8891a552cf1efa8d44a4cd828dbf3b749656d2882a",
}
RECEIPT_RAW_HASHES: dict[str, str] = {
    "zh-CN": "bcf6db5d60696fa9d5b2b5b1f40466e894dc7156f25b6e497763191509f0a9fc",
    "zh-TW": "0ff59873eb0cad829bbb09d86566bacec72f25fe2eb82635ac1b30c441ce62b6",
}
BATCH_HASH = "891413a2a8b707e09199205a5a3700d1c01a5ce810c1dbce075b2bb3667b021c"

_ACTIVE_PROOF = contextvars.ContextVar("order365_ui_receipt_proof", default=None)
_ACTIVE_CURRENT = contextvars.ContextVar("order365_current_ui_append", default=None)
_sha = previous._sha
_digest = previous._digest
_ordered = previous._ordered
_loads = previous._loads
_Document = previous._Document


def _require(ok: bool, detail: str) -> None:
    if not ok:
        raise ValueError("ORDER-365: " + detail)


def _git(*args: str, input: bytes | None = None) -> bytes:
    result = subprocess.run(("git", "--no-replace-objects", *args), cwd=ROOT,
                            input=input, capture_output=True, timeout=30)
    _require(result.returncode == 0, "immutable Git proof unavailable: " + " ".join(args))
    return result.stdout


def _read_objects(requests: list[tuple[str, str, str]]) -> list[bytes]:
    output = _git("cat-file", "--batch", input="".join(r + "\n" for r, _, _ in requests).encode())
    cursor, objects = 0, []
    for expression, oid, kind in requests:
        end = output.find(b"\n", cursor)
        header = output[cursor:end].split() if end >= cursor else []
        _require(len(header) == 3 and header[:2] == [oid.encode(), kind.encode()]
                 and header[2].isdigit(), "missing/forged Git object " + expression)
        size, cursor = int(header[2]), end + 1
        raw = output[cursor:cursor + size]
        _require(len(raw) == size and output[cursor + size:cursor + size + 1] == b"\n",
                 "truncated Git object " + expression)
        actual = hashlib.sha1(kind.encode() + b" " + str(size).encode() + b"\0" + raw).hexdigest()
        _require(actual == oid, "altered Git object " + expression)
        objects.append(raw)
        cursor += size + 1
    _require(cursor == len(output), "trailing Git proof bytes")
    return objects


def _runtime_predecessor(raw: bytes) -> bytes:
    """Prove the exact three-line font change; never admit its old raw rollback."""
    _require(isinstance(raw, bytes) and _sha(raw) == FONT_AFTER_SHA256,
             "ORDER-372 current runtime exceeds exact font successor " + RUNTIME_PATH)
    old_blob, old_sha = DEPENDENCIES[RUNTIME_PATH]
    objects = _read_objects([
        (FONT_BEFORE_COMMIT, FONT_BEFORE_COMMIT, "commit"),
        (FONT_AFTER_COMMIT, FONT_AFTER_COMMIT, "commit"),
        (FONT_BEFORE_TREE, FONT_BEFORE_TREE, "tree"),
        (FONT_AFTER_TREE, FONT_AFTER_TREE, "tree"),
        (FONT_BEFORE_COMMIT + ":" + RUNTIME_PATH, old_blob, "blob"),
        (FONT_AFTER_COMMIT + ":" + RUNTIME_PATH, FONT_AFTER_BLOB, "blob"),
    ])
    old_headers, new_headers = (body.split(b"\n\n", 1)[0].splitlines() for body in objects[:2])
    _require([s for s in old_headers if s.startswith(b"tree ")] == [b"tree " + FONT_BEFORE_TREE.encode()]
             and [s for s in new_headers if s.startswith(b"tree ")] == [b"tree " + FONT_AFTER_TREE.encode()]
             and [s for s in new_headers if s.startswith(b"parent ")] == [b"parent " + FONT_BEFORE_COMMIT.encode()],
             "ORDER-372 exact direct parent/tree mismatch")
    _require(_git("diff", "--name-status", "-z", FONT_BEFORE_COMMIT, FONT_AFTER_COMMIT).split(b"\0")
             == [b"M", RUNTIME_PATH.encode(), b""], "ORDER-372 exact one-file transition mismatch")
    before, after = objects[4:]
    _require(_sha(before) == old_sha and _sha(after) == FONT_AFTER_SHA256 and after == raw,
             "ORDER-372 immutable/current runtime mismatch")
    _require(before.count(FONT_ANCHOR) == after.count(FONT_ANCHOR + FONT_ADDITION) == 1
             and FONT_ADDITION not in before and after.count(FONT_ADDITION) == 1
             and after.replace(FONT_ANCHOR + FONT_ADDITION, FONT_ANCHOR, 1) == before,
             "ORDER-372 bytes outside exact local font addition changed")
    return before


def _read_proof() -> dict[str, tuple[bytes, bytes]]:
    _require(all(re.fullmatch(r"[0-9a-f]{40}", value or "") for value in
                 (BEFORE_COMMIT, AFTER_COMMIT, BEFORE_TREE, AFTER_TREE))
             and set(FILE_HASHES) == set(CURRENT_PATHS) == set(FILE_BLOBS),
             "product transition is not sealed")
    requests = [(BEFORE_COMMIT, BEFORE_COMMIT, "commit"),
                (AFTER_COMMIT, AFTER_COMMIT, "commit"),
                (BEFORE_TREE, BEFORE_TREE, "tree"), (AFTER_TREE, AFTER_TREE, "tree")]
    requests += [(revision + ":" + path, FILE_BLOBS[path][i], "blob")
                 for path in CURRENT_PATHS for i, revision in enumerate((BEFORE_COMMIT, AFTER_COMMIT))]
    requests += [(BEFORE_COMMIT + ":" + path, oid, "blob")
                 for path, (oid, _sha256) in DEPENDENCIES.items()]
    objects = _read_objects(requests)
    old_headers, new_headers = (raw.split(b"\n\n", 1)[0].splitlines() for raw in objects[:2])
    _require([s for s in old_headers if s.startswith(b"tree ")] == [b"tree " + BEFORE_TREE.encode()]
             and [s for s in new_headers if s.startswith(b"tree ")] == [b"tree " + AFTER_TREE.encode()]
             and [s for s in new_headers if s.startswith(b"parent ")] == [b"parent " + BEFORE_COMMIT.encode()],
             "exact direct parent/tree mismatch")
    expected = [v for path in sorted(CURRENT_PATHS) for v in (b"M", path.encode())] + [b""]
    _require(_git("diff", "--name-status", "-z", BEFORE_COMMIT, AFTER_COMMIT).split(b"\0") == expected,
             "exact three-file transition population mismatch")
    _require(set(DEPENDENCIES) == {PREVIOUS_MODULE_PATH, RUNTIME_PATH}, "proof dependency population drifted")
    for (path, (_oid, digest)), raw in zip(DEPENDENCIES.items(), objects[10:]):
        current = (ROOT / path).read_bytes()
        comparison = _runtime_predecessor(current) if path == RUNTIME_PATH else current
        _require(_sha(raw) == digest and comparison == raw,
                 "original module/runtime bytes drifted " + path)
    _require(DEPENDENCIES[PREVIOUS_MODULE_PATH][1] == PREVIOUS_MODULE_SHA256
             and previous.ROOT == ROOT and Path(previous.__file__).resolve() == ROOT / PREVIOUS_MODULE_PATH,
             "original351 import identity drifted")
    return {path: tuple(objects[4 + i * 2:6 + i * 2]) for i, path in enumerate(CURRENT_PATHS)}


def _receipt_id(key: str) -> str:
    return "ui:" + key + ":/" + key.replace("~", "~0").replace("/", "~1")


def _receipt(key: str, target: str) -> dict[str, str]:
    return {"source_sha256": _digest({"path": "runtime:static_ui", "field": [key], "ko": key}),
            "target_sha256": _digest(target)}


def _verify_ui_values(old: Any, new: Any) -> None:
    _require(isinstance(old, dict) and isinstance(new, dict), "UI dictionary shape mismatch")
    _require(len(old) == 1065 and len(new) == 1087 and not set(KEYS).intersection(old)
             and list(new) == [*old, *KEYS], "exact22 appended UI keys/order mismatch")
    _require(_ordered({key: new[key] for key in old}) == _ordered(old), "existing UI value drifted")
    _require(all(isinstance(new[key], str) and new[key].strip() for key in KEYS), "empty/nontext UI addition")
    for key in KEYS:
        _require(previous.TOKEN_RE.findall(key) == previous.TOKEN_RE.findall(new[key])
                 and key.count("\n") == new[key].count("\n"), "UI token/paragraph mismatch " + key)


def _verify_ledger_values(old: Any, new: Any, targets: Mapping[str, dict]) -> None:
    _require(isinstance(old, dict) and isinstance(new, dict), "ledger shape mismatch")
    owned = {"accepted", "accepted_sha256", "batches"}
    _require(list(old) == list(new) and _ordered({k: v for k, v in old.items() if k not in owned})
             == _ordered({k: v for k, v in new.items() if k not in owned}), "existing ledger metadata drifted")
    _require(list(old["accepted"]) == list(new["accepted"])
             and set(new["accepted"]) == {"ja", *LOCALES}, "receipt locale/order mismatch")
    _require([sum(map(len, value["accepted"].values())) for value in (old, new)] == [40302, 40346],
             "accepted population mismatch")
    _require(all(value["accepted_sha256"] == _digest(value["accepted"]) for value in (old, new)),
             "accepted checksum mismatch")
    _require(len(old["batches"]) == 142 and len(new["batches"]) == 143
             and _ordered(new["batches"][:-1]) == _ordered(old["batches"]), "existing batch history drifted")
    batch = new["batches"][-1]
    _require(_digest(batch) == BATCH_HASH and batch["order"] == "ORDER-365" and batch["group"] == "ui"
             and batch["roots"] == list(KEYS) and batch["source_leaves"] == 22
             and batch["target_leaves_by_locale"] == {"ja": 0, "zh-CN": 22, "zh-TW": 22}
             and batch["receipt_sha256_by_locale"] == RECEIPT_HASHES, "exact work-unit batch mismatch")
    for locale in new["accepted"]:
        prior, current = old["accepted"][locale], new["accepted"][locale]
        additions = {_receipt_id(key): _receipt(key, targets[locale][key]) for key in sorted(KEYS)} \
                    if locale in LOCALES else {}
        _require(not set(prior).intersection(additions) and list(current) == [*prior, *additions]
                 and _ordered({key: current[key] for key in prior}) == _ordered(prior)
                 and {key: current[key] for key in additions} == additions,
                 "existing or new source/target receipt drifted " + locale)
        if locale in LOCALES:
            header = RECEIPT_BATCHES[locale]
            _require(header["locale"] == locale and header["count"] == 22
                     and header["source_language"] == "ko" and header["native_review"] == "OPEN",
                     "official import header mismatch " + locale)
            _require(header["source_revision"] == BEFORE_COMMIT
                     and header["batch_id"] == _digest({k: v for k, v in header.items() if k != "batch_id"}),
                     "official import source revision/batch identity mismatch " + locale)
            receipt = {"batch": header, "state": "accepted_machine_validated", "native_review": "OPEN",
                       "translations": additions}
            _require(_digest(receipt) == RECEIPT_HASHES[locale], "official receipt digest mismatch " + locale)
            receipt["receipt_sha256"] = RECEIPT_HASHES[locale]
            raw = (json.dumps(receipt, ensure_ascii=False, indent=2) + "\n").encode()
            _require(_sha(raw) == RECEIPT_RAW_HASHES[locale], "official receipt raw reconstruction mismatch " + locale)


def _tail_removal(document, path: tuple, old_keys: list, new_keys: list) -> tuple[int, int, str]:
    _require(bool(old_keys) and len(new_keys) > len(old_keys)
             and new_keys[:len(old_keys)] == old_keys, "inverse requires exact appended members")
    return (document.spans[(*path, old_keys[-1])][1], document.spans[(*path, new_keys[-1])][1], "")


def _inverse_raw(before: bytes, after: bytes, relative: str) -> bytes:
    """Internal proof only; no consumer ever receives this predecessor ledger/UI."""
    old_doc, new_doc = _Document(before), _Document(after)
    old, new = old_doc.value, new_doc.value
    replacements = []
    if relative in UI_PATHS:
        _verify_ui_values(old, new)
        replacements.append(_tail_removal(new_doc, (), list(old), list(new)))
    elif relative == LEDGER_PATH:
        for locale in LOCALES:
            replacements.append(_tail_removal(new_doc, ("accepted", locale),
                                list(old["accepted"][locale]), list(new["accepted"][locale])))
        replacements.append(_tail_removal(new_doc, ("batches",),
                            list(range(len(old["batches"]))), list(range(len(new["batches"])))))
        start, end = new_doc.spans[("accepted_sha256",)]
        a, b = old_doc.spans[("accepted_sha256",)]
        replacements.append((start, end, old_doc.text[a:b]))
    else:
        raise ValueError("ORDER-365: unregistered inverse path " + relative)
    text = new_doc.text
    for start, end, replacement in sorted(replacements, reverse=True):
        text = text[:start] + replacement + text[end:]
    restored = text.encode("utf-8")
    _require(restored == before, "bytes outside exact additions/checksum changed " + relative)
    return restored


@functools.lru_cache(maxsize=1)
def _verify_transition(pairs: tuple[tuple[str, bytes, bytes], ...]) -> None:
    # Only immutable byte arguments are cached; each invocation rereads all Git
    # objects/import identities before reaching this deterministic comparison.
    _require(tuple(path for path, _, _ in pairs) == CURRENT_PATHS, "proof path population mismatch")
    raw = {path: (before, after) for path, before, after in pairs}
    for path, before, after in pairs:
        _require((_sha(before), _sha(after)) == FILE_HASHES[path], "immutable raw hash mismatch " + path)
    targets = {locale: _loads(raw[path][1]) for locale, path in zip(LOCALES, UI_PATHS)}
    _verify_ledger_values(*map(_loads, raw[LEDGER_PATH]), targets)
    for path, before, after in pairs:
        _inverse_raw(before, after, path)


@contextlib.contextmanager
def fresh_validation_proof():
    """Fresh Git/module proof per outer validation; no cross-invocation success."""
    if _ACTIVE_PROOF.get() is not None:
        yield
        return
    proof = _read_proof()
    with previous.fresh_validation_proof():
        _verify_transition(tuple((path, *proof[path]) for path in CURRENT_PATHS))
        _require(not previous.source_errors(proof[LEDGER_PATH][0], LEDGER_PATH),
                 "predecessor ledger does not bind to immutable351")
        baseline = {p: proof[p][1] for p in CURRENT_PATHS}
        ja_path = "locale/ui_ja.json"
        ja_raw = ui_append._objects(ROOT, [(AFTER_COMMIT + ":" + ja_path, JA_BASELINE_BLOB, "blob")])[0]
        _require(_sha(ja_raw) == JA_BASELINE_SHA256, "immutable Japanese baseline bytes differ")
        baseline[ja_path] = ja_raw
        current = ui_append.current_proof(ROOT, AFTER_COMMIT, baseline)
        current["baseline_raw"] = baseline
        if coffee_history.COFFEE_AFTER_COMMIT is not None:
            current["coffee_event_raw"] = coffee_history.coffee_encounter_current_events(ROOT)
            _require(ui_append._git(ROOT, "rev-parse", "--verify", "HEAD^{commit}").decode().strip()
                     == current["evidence"]["head"], "coffee/UI current proofs observed different Git candidates")
        current["coin_event_raw"] = coin_history.coin_call_current_events(ROOT)
        _require(ui_append._git(ROOT, "rev-parse", "--verify", "HEAD^{commit}").decode().strip()
                 == current["evidence"]["head"], "coin/UI current proofs observed different Git candidates")
        token = _ACTIVE_PROOF.set(proof)
        current_token = _ACTIVE_CURRENT.set(current)
        try:
            yield
        finally:
            _ACTIVE_CURRENT.reset(current_token)
            _ACTIVE_PROOF.reset(token)


def source_errors(raw: bytes, relative: str) -> list[str]:
    if relative not in LIVE_PATHS:
        return ["ORDER-365: unregistered current source path " + str(relative)]
    if not isinstance(raw, bytes):
        return ["ORDER-365: current source is not raw bytes " + relative]
    try:
        with fresh_validation_proof():
            if relative in ui_append.CURRENT_PATHS:
                _require(raw == _ACTIVE_CURRENT.get()["raw"][relative], "current raw differs from Git " + relative)
                return []
            if relative in coffee_history.EVENT_PATHS and "coffee_event_raw" in _ACTIVE_CURRENT.get():
                _require(raw == _ACTIVE_CURRENT.get()["coffee_event_raw"][relative],
                         "current coffee event raw differs from exact Git successor " + relative)
                return []
            if relative in coin_history.EVENT_PATHS:
                _require(raw == _ACTIVE_CURRENT.get()["coin_event_raw"][relative],
                         "current coin event raw differs from exact Git successor " + relative)
                return []
            return previous.source_errors(raw, relative)
    except (OSError, ValueError, KeyError, TypeError, IndexError, subprocess.TimeoutExpired) as exc:
        return ["ORDER-365: current proof rejected: " + str(exc)]


def snapshot_errors(snapshot: Mapping[str, bytes]) -> list[str]:
    """Admit the submitted whole50 snapshot, including the exact coin targets."""
    errors = []
    if set(snapshot) != set(LIVE_PATHS):
        errors.append("ORDER-365: exact50 current snapshot paths drifted")
    try:
        with fresh_validation_proof():
            for relative in LIVE_PATHS:
                errors.extend(source_errors(snapshot.get(relative), relative))
    except (OSError, ValueError, KeyError, TypeError, IndexError, subprocess.TimeoutExpired) as exc:
        errors.append("ORDER-365: whole current proof rejected: " + str(exc))
    return errors


def current_source_errors(root: Path = ROOT) -> list[str]:
    snapshot, errors = {}, []
    for relative in LIVE_PATHS:
        try:
            snapshot[relative] = (Path(root) / relative).read_bytes()
        except OSError as exc:
            errors.append("ORDER-365: current source unavailable " + relative + ": " + str(exc))
    return errors + snapshot_errors(snapshot)


def source_observation_errors(raw: bytes, payload: Any, relative: str) -> list[str]:
    errors = source_errors(raw, relative)
    try:
        _require(_ordered(_loads(raw)) == _ordered(payload), "observed payload not bound to raw " + relative)
    except (ValueError, TypeError, UnicodeError, AttributeError) as exc:
        errors.append("ORDER-365: malformed/unbound current payload: " + str(exc))
    return errors


def observed_byte_hash(relative: str, observed: str, raw: bytes) -> tuple[str, list[str]]:
    """Current identity only: never expose historical receipt/dictionary bytes."""
    errors = source_errors(raw, relative)
    if not isinstance(raw, bytes) or _sha(raw) != observed:
        errors.append("ORDER-365: observed hash not bound to raw " + relative)
    return observed, errors


def runtime_observed_hash(relative: str, observed: str, raw: bytes, *,
                          current_admitted: bool) -> tuple[str, list[str]]:
    """Comparison-only font inverse, separate from the actual-current UI API."""
    if relative not in RUNTIME_COMPARISON_PATHS:
        return observed, []
    try:
        owner = "ORDER-377" if relative == ui_append.ARUBA_FONT_PATH else "ORDER-372"
        _require(current_admitted, owner + " current admission failed before runtime comparison")
        _require(isinstance(raw, bytes) and _sha(raw) == observed,
                 owner + " runtime observation is not bound to current raw")
        with fresh_validation_proof():
            predecessor = (ui_append.aruba_font_predecessor(ROOT, raw)
                           if relative == ui_append.ARUBA_FONT_PATH else _runtime_predecessor(raw))
            return _sha(predecessor), []
    except (OSError, ValueError, KeyError, TypeError, IndexError, subprocess.TimeoutExpired) as exc:
        return observed, ["ORDER-365: runtime comparison rejected: " + str(exc)]


def self_test() -> tuple[list[str], int]:
    from unittest import mock
    failures, cases = [], 0

    def check(ok: bool, label: str) -> None:
        nonlocal cases
        cases += 1
        if not ok:
            failures.append("ORDER-365 boundary: " + label)

    def rejected(action, label: str) -> None:
        try:
            action()
        except (OSError, ValueError, KeyError, TypeError, IndexError):
            check(True, label)
        else:
            check(False, label)

    snapshot = {path: (ROOT / path).read_bytes() for path in LIVE_PATHS}
    with fresh_validation_proof():
        proof = _ACTIVE_PROOF.get()
        check(len(LIVE_PATHS) == 46 and len(previous.HISTORICAL_PATHS) == 17
              and sum(map(len, previous.HISTORICAL_JSON_LEAVES.values())) == 107,
              "current46 / historical17 / leaves107")
        check(not snapshot_errors(snapshot), "actual whole current admission")
        for path, (before, after) in proof.items():
            check(_inverse_raw(before, after, path) == before, path + " exact raw inverse proof")
            check(observed_byte_hash(path, _sha(after), after) == (_sha(after), []), path + " current raw hash retained")
            check(bool(source_errors(before, path)), path + " rollback with actual old bytes")
            for label, mutant in (("leading space", b" " + after), ("trailing newline", after + b"\n"),
                                  ("reformat", _ordered(_loads(after))), ("empty", b"")):
                check(bool(source_errors(mutant, path)), path + " " + label)
            check(bool(observed_byte_hash(path, _sha(before), after)[1]), path + " stale claim")
            check(bool(observed_byte_hash(path, _sha(after), after + b" ")[1]), path + " forged claim")
            check(not source_observation_errors(after, _loads(after), path), path + " bound payload")
            check(bool(source_observation_errors(after, _loads(before), path)), path + " rollback payload/current raw")
            check(bool(source_errors(after, "outside/" + path)), path + " wrong path")
        for bits in itertools.product((0, 1), repeat=3):
            mixed = {**snapshot, **{path: proof[path][i] for path, i in zip(CURRENT_PATHS, bits)}}
            check(bool(snapshot_errors(mixed)) == (bits != (1, 1, 1)), "all old/new snapshot " + str(bits))
        for path in CURRENT_PATHS:
            missing = dict(snapshot)
            del missing[path]
            check(bool(snapshot_errors(missing)), path + " missing snapshot")
        check(bool(snapshot_errors({**snapshot, "unregistered.json": b"{}"})), "extra snapshot path")
        for locale, path in zip(LOCALES, UI_PATHS):
            old, new = map(_loads, proof[path])
            for key in KEYS:
                mutant = dict(new)
                mutant[key] += " unapproved"
                check(bool(source_errors(_ordered(mutant), path)), locale + " changed target " + key)
            mutant = dict(new)
            mutant[next(iter(old))] += " unapproved"
            rejected(lambda: _verify_ui_values(old, mutant), locale + " changed old neighbor")
            mutant = dict(reversed(list(new.items())))
            rejected(lambda: _verify_ui_values(old, mutant), locale + " key order")
            for value in ("", None, 0, float("nan")):
                mutant = {**new, KEYS[0]: value}
                rejected(lambda: _verify_ui_values(old, mutant), locale + " empty/nontext target")
        old, new = map(_loads, proof[LEDGER_PATH])
        targets = {locale: _loads(proof[path][1]) for locale, path in zip(LOCALES, UI_PATHS)}
        for locale in LOCALES:
            for key in KEYS:
                for field in ("source_sha256", "target_sha256"):
                    mutant = copy.deepcopy(new)
                    mutant["accepted"][locale][_receipt_id(key)][field] = "0" * 64
                    mutant["accepted_sha256"] = _digest(mutant["accepted"])
                    rejected(lambda: _verify_ledger_values(old, mutant, targets), locale + " " + field + " " + key)
            mutant = copy.deepcopy(new)
            mutant["accepted"][locale][next(iter(old["accepted"][locale]))]["source_sha256"] = "0" * 64
            mutant["accepted_sha256"] = _digest(mutant["accepted"])
            rejected(lambda: _verify_ledger_values(old, mutant, targets), locale + " changed old receipt")
        for key in set(new) - {"accepted", "accepted_sha256", "batches"}:
            mutant = {**new, key: "unapproved"}
            rejected(lambda: _verify_ledger_values(old, mutant, targets), "old metadata " + key)
        mutant = copy.deepcopy(new)
        mutant["batches"][0]["order"] = "forged"
        rejected(lambda: _verify_ledger_values(old, mutant, targets), "old batch mutation")
        mutant = copy.deepcopy(new)
        mutant["batches"][-1]["receipt_sha256_by_locale"][LOCALES[0]] = "0" * 64
        rejected(lambda: _verify_ledger_values(old, mutant, targets), "forged receipt evidence")
        for raw in (b'{"a":1,"a":2}', b'[NaN]', b'[Infinity]', b'[-Infinity]', b'[1e999]'):
            rejected(lambda: _loads(raw), "strict JSON " + raw.decode())
        for value in (None, [], {"x": float("inf")}, {"x": float("nan")}):
            check(bool(source_observation_errors(proof[UI_PATHS[0]][1], value, UI_PATHS[0])), "malformed payload")
        first = _ACTIVE_PROOF.get()
        with fresh_validation_proof():
            check(_ACTIVE_PROOF.get() is first, "nested same-invocation proof")
    check(_ACTIVE_PROOF.get() is None, "scope cleanup")
    with fresh_validation_proof():
        check(_ACTIVE_PROOF.get() is not first, "next invocation fresh proof")
    real_git = _git
    for label, replacement in (("missing", b""), ("forged", b"0" * 40 + b" blob 1\nx\n")):
        with mock.patch(__name__ + "._git", return_value=replacement):
            check(bool(source_errors(snapshot[LEDGER_PATH], LEDGER_PATH)), "warm " + label + " Git")
        check(not source_errors(snapshot[LEDGER_PATH], LEDGER_PATH), "recovery after " + label + " Git")
    for label, transform in (("object body", lambda raw: raw[:-2] + b"!\n"),
                              ("truncated", lambda raw: raw[:-1]),
                              ("trailing", lambda raw: raw + b"extra")):
        def changed_git(*args, **kwargs):
            raw = real_git(*args, **kwargs)
            return transform(raw) if args[0] == "cat-file" else raw
        with mock.patch(__name__ + "._git", changed_git):
            check(bool(source_errors(snapshot[LEDGER_PATH], LEDGER_PATH)), "warm " + label + " proof")
    with mock.patch(__name__ + "._git", side_effect=OSError("Git unavailable")):
        check(bool(snapshot_errors(snapshot)), "whole admission fails before historical access")
    def wrong_population(*args, **kwargs):
        return b"" if args[0] == "diff" else real_git(*args, **kwargs)
    with mock.patch(__name__ + "._git", wrong_population):
        check(bool(source_errors(snapshot[LEDGER_PATH], LEDGER_PATH)), "wrong product path population")
    read_bytes = Path.read_bytes
    for dependency in DEPENDENCIES:
        def altered_dependency(path):
            raw = read_bytes(path)
            return raw + b"\n" if path == ROOT / dependency else raw
        with mock.patch.object(Path, "read_bytes", altered_dependency):
            check(bool(source_errors(snapshot[LEDGER_PATH], LEDGER_PATH)), "warm dependency mutation " + dependency)
    for attribute, value in (("ROOT", ROOT / "wrong"), ("__file__", str(ROOT / "wrong.py"))):
        with mock.patch.object(previous, attribute, value):
            check(bool(source_errors(snapshot[LEDGER_PATH], LEDGER_PATH)), "old351 import " + attribute)
    check(_ACTIVE_PROOF.get() is None, "failed proof cleanup")
    return failures, cases


def runtime_font_self_test() -> tuple[list[str], int]:
    """Bounded font successor cases; the original receipt/corpus tests stay intact."""
    from unittest import mock
    import chapter1_core_loop_v2_causal_ledger_check as chapter1

    failures, cases = [], 0

    def check(ok: bool, label: str) -> None:
        nonlocal cases
        cases += 1
        if not ok:
            failures.append("ORDER-372 font boundary: " + label)

    current = (ROOT / RUNTIME_PATH).read_bytes()
    old = _runtime_predecessor(current)
    old_sha, current_sha = _sha(old), _sha(current)

    def observe(raw=current, claim=current_sha, admitted=True, relative=RUNTIME_PATH):
        return runtime_observed_hash(relative, claim, raw, current_admitted=admitted)

    check(old_sha == DEPENDENCIES[RUNTIME_PATH][1]
          == chapter1.EXPECTED_AUDITED_SOURCE_FILE_SHA256[RUNTIME_PATH], "immutable old pins retained")
    check(current_sha == FONT_AFTER_SHA256 and observe() == (old_sha, []), "exact current comparison")
    check(not chapter1._audited_source_snapshot_errors({RUNTIME_PATH: old_sha}), "actual chapter1 snapshot entry")
    check(RUNTIME_PATH not in LIVE_PATHS and len(LIVE_PATHS) == 46, "runtime dependency is not a new live UI path")
    check(observe(claim=old_sha)[0] == old_sha and bool(observe(claim=old_sha)[1]), "stale observed hash rejected")
    with mock.patch(__name__ + "._runtime_predecessor", wraps=_runtime_predecessor) as inverse:
        value, errors = observe(admitted=False)
        check(value == current_sha and bool(errors) and not inverse.called, "failed admission cannot project")
    with mock.patch(__name__ + "._git", side_effect=AssertionError("unrelated path must not request proof")):
        check(observe(relative=RUNTIME_PATH + ".other") == (current_sha, []), "other path is not projected")
    for value in (None, "not bytes", bytearray(current)):
        result, errors = observe(raw=value)
        check(result == current_sha and bool(errors), "nonbyte observed runtime " + type(value).__name__)
    variants = [
        ("full rollback", old), ("leading space", b" " + current),
        ("trailing newline", current + b"\n"), ("empty", b""),
        ("wrong weight", current.replace(b"FontKit.ui_regular()", b"FontKit.ui_bold()")),
        ("wrong font", current.replace(b"FontKit.ui_regular()", b"SystemFont.new()")),
        ("wrong theme", current.replace(b"\ttheme = local_theme\n", b"\ttheme = Theme.new()\n")),
        ("global theme", current.replace(b"\ttheme = local_theme\n", b"\tThemeDB.default_theme = local_theme\n")),
        ("duplicate addition", current.replace(FONT_ADDITION, FONT_ADDITION * 2)),
        ("neighbor gameplay", current.replace(b"_stress_delta += 2", b"_stress_delta += 3")),
        ("neighbor text", current.replace("취업 준비".encode(), "취업 준비!".encode())),
    ]
    lines = FONT_ADDITION.splitlines(keepends=True)
    for bits in itertools.product((0, 1), repeat=3):
        if bits != (1, 1, 1):
            partial = b"".join(line for line, keep in zip(lines, bits) if keep)
            variants.append(("partial addition " + str(bits), current.replace(FONT_ADDITION, partial)))
    read_bytes = Path.read_bytes
    for label, mutant in variants:
        claim = _sha(mutant)
        actual, errors = observe(raw=mutant, claim=claim)
        check(mutant != current and actual == claim and bool(errors), label + " observed bytes")

        def changed_runtime(path):
            return mutant if path == ROOT / RUNTIME_PATH else read_bytes(path)

        with mock.patch.object(Path, "read_bytes", changed_runtime):
            check(bool(source_errors(read_bytes(ROOT / LEDGER_PATH), LEDGER_PATH)), label + " current dependency")
    with mock.patch.object(chapter1, "_file_digest", return_value="0" * 64):
        errors = chapter1._audited_source_snapshot_errors({RUNTIME_PATH: old_sha})
        check(any("not bound to current raw" in error for error in errors)
              and any("audited file snapshot mismatch " + RUNTIME_PATH in error for error in errors),
              "chapter1 forged hash still reaches original mismatch")

    real_git = _git
    for label in ("missing", "forged", "wrong population"):
        def changed_git(*args, **kwargs):
            if args[0] == "cat-file" and FONT_AFTER_COMMIT.encode() in (kwargs.get("input") or b""):
                if label == "missing":
                    return b""
                if label == "forged":
                    return b"0" * 40 + b" blob 1\nx\n"
            if args[0] == "diff" and FONT_AFTER_COMMIT in args and label == "wrong population":
                return b"M\0scenes/Other.gd\0"
            return real_git(*args, **kwargs)

        with mock.patch(__name__ + "._git", changed_git):
            result, errors = observe()
            check(result == current_sha and bool(errors), "warm successor-only " + label + " proof")
        check(observe() == (old_sha, []), "fresh recovery after " + label)
    # Corrupt each of the six successor objects, not the earlier ORDER-365 proof.
    for object_index in range(6):
        def altered_object(*args, **kwargs):
            raw = real_git(*args, **kwargs)
            if args[0] != "cat-file" or FONT_AFTER_COMMIT.encode() not in (kwargs.get("input") or b""):
                return raw
            cursor = 0
            for index in range(6):
                end = raw.index(b"\n", cursor)
                size = int(raw[cursor:end].split()[2])
                cursor = end + 1
                if index == object_index:
                    return raw[:cursor] + bytes([raw[cursor] ^ 1]) + raw[cursor + 1:]
                cursor += size + 1
            raise AssertionError("missing successor object")

        with mock.patch(__name__ + "._git", altered_object):
            result, errors = observe()
            check(result == current_sha and bool(errors), "altered successor object " + str(object_index))
    check(observe() == (old_sha, []) and _ACTIVE_PROOF.get() is None, "fresh proof restored without leaked scope")
    return failures, cases


def consumer_boundary_self_test() -> tuple[list[str], int]:
    """Five real current entry points, one raw mutation each; no legacy suites."""
    from unittest import mock
    import full_body_translation_scope as body
    import story_graph_contract_audit as graph
    import chapter5_human_reject_audit as chapter5
    import year5_reference_route_audit as year5
    import chapter1_core_loop_v2_causal_ledger_check as chapter1

    failures, cases = [], 0

    def check(ok: bool, label: str) -> None:
        nonlocal cases
        cases += 1
        if not ok:
            failures.append("ORDER-365 consumer boundary: " + label)

    read_bytes = Path.read_bytes

    @contextlib.contextmanager
    def mutated_current(relative):
        def read(path):
            raw = read_bytes(path)
            return raw + b"\n" if path == ROOT / relative else raw
        with mock.patch.object(Path, "read_bytes", read):
            yield

    def rejected(errors, relative):
        return any("ORDER-365" in error and relative in error for error in errors)

    for module in (body, graph, chapter5, year5, chapter1):
        check(module.current_source is previous
              and Path(module.ui_receipts.__file__).resolve() == Path(__file__).resolve(),
              module.__name__ + " historical/current import separation")
    with mutated_current(UI_PATHS[0]), \
            mock.patch.object(previous, "historical_blobs", wraps=previous.historical_blobs) as history:
        _empty, errors = body._source_history_observations({})
        check(rejected(errors, UI_PATHS[0]) and not history.called, "full-body fail before historical observation")
    data = graph.load_inputs()
    check(set(data.source_bytes) == set(LIVE_PATHS), "graph submits all46 raw snapshots")
    data.source_bytes[UI_PATHS[1]] += b"\n"
    check(rejected(graph.validate(data), UI_PATHS[1]), "graph rejects submitted UI snapshot")
    model = chapter5._load_model()
    with mutated_current(LEDGER_PATH):
        errors = []
        chapter5.validate_preserved_product_boundaries(model, errors)
        check(rejected(errors, LEDGER_PATH), "chapter5 rejects current ledger mutation")
    context, context_errors = year5.build_context()
    check(not context_errors, "year5 unmodified context fixture")
    with mutated_current(UI_PATHS[0]):
        errors, _stats = year5.validate_manifest(year5.load_json(year5.MANIFEST_PATH), context)
        check(rejected(errors, UI_PATHS[0]), "year5 rejects current UI mutation")
    relative = "content/events/arc_midgame.json"
    with mutated_current(UI_PATHS[1]), \
            mock.patch.object(previous, "observed_byte_hash", wraps=previous.observed_byte_hash) as history:
        errors = chapter1._audited_source_snapshot_errors(
            {relative: chapter1.EXPECTED_AUDITED_SOURCE_FILE_SHA256[relative]})
        check(rejected(errors, UI_PATHS[1]) and not history.called, "chapter1 fail before audited projection")
    return failures, cases


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--self-test", action="store_true")
    args = parser.parse_args()
    errors, cases = current_source_errors(), 0
    if args.self_test and not errors:
        from ui_translation_append_self_test import historical_self_test
        result = historical_self_test()
        errors.extend(result["errors"])
        cases = result["cases"]
        print("ORDER365_HISTORICAL_CORPUS " + json.dumps(result, ensure_ascii=False, sort_keys=True))
        print(f"ORDER365_HISTORICAL_{'FAIL' if result['errors'] else 'OK'} cases={cases} current_claim=false")
    for error in errors:
        print("ORDER365_UI_RECEIPT_ERROR " + error)
    ledger = _loads((ROOT / LEDGER_PATH).read_bytes())
    accepted = sum(len(rows) for rows in ledger["accepted"].values())
    print(f"ORDER365_UI_RECEIPT_{'FAIL' if errors else 'OK'} current_files=4 baseline_ui_keys=44 "
          f"baseline_receipts=40346 baseline_batches=143 accepted={accepted} batch_total={len(ledger['batches'])} "
          f"live_files={len(LIVE_PATHS)} historical_files=17 historical_leaves=107 historical_cases={cases}")
    return int(bool(errors))


if __name__ == "__main__":
    raise SystemExit(main())
