"""Exact482 source4/first-three-receipt successor, never a runtime rollback.

This leaf proof imports no other project module. Older owners may consume its
comparison views without a recursive history dependency. Every public entry
revalidates actual typed Git objects, physical disk and configuration.
"""
from __future__ import annotations

import asyncio
import contextlib
import contextvars
import copy
import hashlib
import json
import re
import subprocess
import threading
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
GAME_STATE_PATH = "autoloads/GameState.gd"
LEDGER_PATH = "content/meta/full_game_localization.json"
LOCALES = ("ja", "zh-CN", "zh-TW")
UI_PATHS = tuple("locale/ui_" + loc + ".json" for loc in LOCALES)
CURRENT_UI_PATHS = (*UI_PATHS, LEDGER_PATH)
SOURCE_PATHS = (GAME_STATE_PATH, *UI_PATHS)
PATHS = (*SOURCE_PATHS, LEDGER_PATH)
PREDECESSOR_COMMIT = '5503f68bfa009478da675e58ab5ffb0e37ecada7'
PRODUCT_PARENT = '586bd23e7a6c5f2a7ebe67d94b00be30106787c4'
PRODUCT_COMMIT = 'fedf0c71ac890d258322e2c0464d9f7989c61dcd'
PREDECESSOR_SOURCE_MANIFEST_SHA256 = 'cf4f8f1221742440a4246e96763af707446684d99c69e43884c71d83f0ec7868'
SOURCE_LEDGER_SHA256 = 'fa200e234491545d51e4d0395715eec274dc35cb04f3552003ab3729574cb027'
OLD_KEY = '💰 자산 10억 돌파 — 30억의 3분의 1. 이제부터 가속이 붙는다.'
NEW_KEY = '💰 자산 10억 돌파 — 30억의 3분의 1.'
OLD_ENGLISH = '💰 Assets passed KRW 1B — one third of the goal. Acceleration starts now.'
NEW_ENGLISH = '💰 Assets passed KRW 1B — one third of the goal.'
TARGETS = {'ja': '💰 資産が10億ウォンを突破 — 30億ウォンの3分の1。', 'zh-CN': '💰 资产突破10亿韩元 — 30亿韩元的三分之一。', 'zh-TW': '💰 資產突破10億韓元 — 30億韓元的三分之一。'}
OLD_JA = '💰 資産10億突破 — 30億の3分の1。ここから加速がつく。'
RECEIPT_ID = "ui:" + NEW_KEY + ":/" + NEW_KEY
OLD_RECEIPT_ID = "ui:" + OLD_KEY + ":/" + OLD_KEY
# Actual acceptance is a separate ledger-only commit; no draft is a receipt.
RECEIPT_PARENT = "2ef1d958b2589fae5e0187380bf10dcbb4e1e58f"
RECEIPT_COMMIT = "6dd8fb87765622d7ba91d9b1bddb407f6fb51d91"
RECEIPT_RAW_SHA256 = ("fa200e234491545d51e4d0395715eec274dc35cb04f3552003ab3729574cb027", "9262c8e68528d85c53c3ff9b156e8135932b237a78b6936d3098476b00c2eff2")
RECEIPT_BATCH_SHA256 = {"ja": "5659029e58762f7231b3f493cf03bfe11d2c03c4f02adc09247c06d616db2a35", "zh-CN": "33155f3112d2441295651a8c0ae5f44f6741d8af9d2b57cfddb796c48a50e7b3", "zh-TW": "e4bc2ddb9e26cdc96c60cecfbd03c1a71443088ef8a2b221da618fd804b71e30"}
RECEIPT_SOURCE_MANIFEST_SHA256 = "caa02cb8435eee1d9e7fb99c36fe3886743e6a7ef65e3699ffe2991fb6396c5b"
RAW_SHA256 = {'autoloads/GameState.gd': ('dfa8c48596917c3b33eb1add4079b790c4bea8b09cc38c03a08165a2955b7bd1', '88182e54aef1138a867441c6261dd62548e0291715c4c985c893c1c2d680a694'), 'locale/ui_ja.json': ('5a6a314b7fd4a82cf698bd86a832939e47596ece734c0edb4d006714393a8b2c', '24f09bc604698bca7a4665ac9072cff8bae88b500770a321dccb37e8467d75b1'), 'locale/ui_zh-CN.json': ('b4b7c60cf82332ae1f58684aaab1ba46451c1e3a5abe6823e6802ec11180df99', '79b953c7cdb1a344fb35d34bcd5c4b78deb1660a4821d1af7767b713cbf8495c'), 'locale/ui_zh-TW.json': ('5d8ca777bda61579b3b1ed44be60840c8984aebc6aaf47b1d545219b23f9fb82', '36325c9dc6703a293c6f3a99d9c4598d1cb7142b96bcd838a5b5b1561bcd45de')}
RAW_PATCHES = {'autoloads/GameState.gd': (('replace', 4328, 4329, 4328, 4329, '8786a9157d53e61ce4b4bfa46552b6b3a76de7d6d1d38b5229d7dd3d81cb4840', '5ad4af3a796e7889fce1fa7c95fdf75550244e55ac69f1b9e6d97b4c2207a361'),), 'locale/ui_ja.json': (('insert', 3054, 3054, 3054, 3055, 'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855', '6c07b2d7475b6f071a165f34acd4afbdfde9f956810ac2ed98d70d21ce2161bc'),), 'locale/ui_zh-CN.json': (('insert', 1810, 1810, 1810, 1811, 'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855', '95c3621c54b9efac2bf1d46ab734d2f5a32762b61e9cdfd10545e385541c7393'),), 'locale/ui_zh-TW.json': (('insert', 1810, 1810, 1810, 1811, 'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855', 'ebb7e6f53e20f983f29d434d94b2116232b3603bc3c34977eb2d8fff7500578a'),)}
_ACTIVE = contextvars.ContextVar("asset_one_billion_log_proof", default=None)
_PURE_SEMANTIC_OWNER = contextvars.ContextVar("asset_one_billion_pure_semantic_owner", default=None)
_PURE_SEMANTIC_CONTEXT = contextvars.ContextVar("asset_one_billion_pure_semantic_context", default=None)


def _require(ok, detail):
    if not ok:
        raise ValueError("ORDER-482: " + detail)


def _sha(raw):
    return hashlib.sha256(raw).hexdigest()


def _digest(value):
    return _sha(json.dumps(value, ensure_ascii=False, sort_keys=True, allow_nan=False,
                           separators=(",", ":")).encode())


def _disk_bytes(path):
    with open(path, "rb") as handle:
        return handle.read()


def _git(root, *args, input=None):
    result = subprocess.run(("git", "--no-replace-objects", *args), cwd=root,
                            input=input, capture_output=True, timeout=30)
    _require(result.returncode == 0, "Git proof unavailable: " + " ".join(args))
    return result.stdout


def _objects(root, requests):
    output = _git(root, "cat-file", "--batch", input="".join(r[0] + "\n" for r in requests).encode())
    cursor, result = 0, []
    for expression, oid, kind in requests:
        end = output.find(b"\n", cursor)
        header = output[cursor:end].split() if end >= cursor else []
        _require(len(header) == 3 and header[:2] == [oid.encode(), kind.encode()]
                 and header[2].isdigit(), "object identity/type: " + expression)
        size = int(header[2])
        raw = output[end + 1:end + 1 + size]
        cursor = end + 1 + size
        _require(len(raw) == size and output[cursor:cursor + 1] == b"\n"
                 and hashlib.sha1(kind.encode() + b" " + str(size).encode() + b"\0" + raw).hexdigest() == oid,
                 "object bytes: " + expression)
        cursor += 1
        result.append(raw)
    _require(cursor == len(output), "trailing object proof")
    return result


def _snapshot(root, revision, paths):
    _require(type(revision) is str and re.fullmatch(r"[0-9a-f]{40}", revision) is not None,
             "unbound revision")
    commit = _objects(root, [(revision, revision, "commit")])[0]
    headers = commit.split(b"\n\n", 1)[0].splitlines()
    trees = [row[5:].decode() for row in headers if row.startswith(b"tree ")]
    _require(len(trees) == 1, "exact commit tree")
    _objects(root, [(trees[0], trees[0], "tree")])
    entries = {}
    for row in _git(root, "ls-tree", "-r", "-z", trees[0], "--", *paths).split(b"\0"):
        if row:
            meta, path = row.split(b"\t", 1)
            mode, kind, oid = meta.decode().split()
            _require(mode == "100644" and kind == "blob", "source mode/type " + path.decode())
            entries[path.decode()] = oid
    _require(set(entries) == set(paths), "exact snapshot path population")
    raw = _objects(root, [(revision + ":" + p, entries[p], "blob") for p in paths])
    return dict(zip(paths, raw)), headers


def _loads(raw):
    def pairs(rows):
        result = {}
        for key, value in rows:
            _require(key not in result, "duplicate JSON key")
            result[key] = value
        return result
    return json.loads(raw, object_pairs_hook=pairs, parse_constant=lambda _:
                      (_ for _ in ()).throw(ValueError("nonfinite JSON")))


class _Document:
    """Literal and member spans, retaining every non-owned byte."""
    def __init__(self, raw):
        self.value, self.text, self.spans, self.members = _loads(raw), raw.decode(), {}, {}
        end = self.walk(0, ())
        _require(not self.text[end:].strip(), "trailing JSON bytes")

    def ws(self, index):
        while index < len(self.text) and self.text[index].isspace():
            index += 1
        return index

    def walk(self, index, keys):
        start = index = self.ws(index)
        if self.text[index] == "{":
            index = self.ws(index + 1)
            while self.text[index] != "}":
                member_start = index
                key, index = json.JSONDecoder().raw_decode(self.text, index)
                index = self.ws(index)
                _require(self.text[index] == ":", "missing JSON colon")
                end = self.walk(index + 1, (*keys, key))
                self.members[(*keys, key)] = (member_start, end)
                index = self.ws(end)
                if self.text[index] != ",":
                    break
                index = self.ws(index + 1)
            index += 1
        elif self.text[index] == "[":
            index, ordinal = self.ws(index + 1), 0
            while self.text[index] != "]":
                index = self.ws(self.walk(index, (*keys, ordinal)))
                ordinal += 1
                if self.text[index] != ",":
                    break
                index = self.ws(index + 1)
            index += 1
        else:
            _, index = json.JSONDecoder().raw_decode(self.text, index)
        self.spans[keys] = (start, index)
        return index


def _member_removal(document, keys):
    parent = document.value
    for key in keys[:-1]:
        parent = parent[key]
    names = list(parent)
    index = names.index(keys[-1])
    if index:
        start = document.spans[(*keys[:-1], names[index - 1])][1]
        end = document.spans[keys][1]
    elif len(names) > 1:
        start = document.members[keys][0]
        end = document.members[(*keys[:-1], names[1])][0]
    else:
        start, end = document.members[keys]
    return start, end, ""


def _source_semantics(before, after, path):
    if path == GAME_STATE_PATH:
        old = ('LocaleManager.ui("' + OLD_KEY + '", "' + OLD_ENGLISH + '")').encode()
        new = ('LocaleManager.ui("' + NEW_KEY + '", "' + NEW_ENGLISH + '")').encode()
        _require(before.count(old) == after.count(new) == 1 and new not in before
                 and old not in after and after == before.replace(old, new, 1),
                 "only milestone KO/EN literals may change")
    else:
        _require(path in UI_PATHS, "unowned source path")
        locale = LOCALES[UI_PATHS.index(path)]
        old, new = _Document(before), _Document(after)
        _require(type(old.value) is dict and type(new.value) is dict
                 and NEW_KEY not in old.value and new.value.get(NEW_KEY) == TARGETS[locale]
                 and {**old.value, NEW_KEY: TARGETS[locale]} == new.value
                 and [key for key in new.value if key != NEW_KEY] == list(old.value),
                 "exact one new translated UI key, old values/order preserved")
        if locale == "ja":
            _require(old.value.get(OLD_KEY) == new.value.get(OLD_KEY) == OLD_JA,
                     "original retained Japanese value")
        start, end, _ = _member_removal(new, (NEW_KEY,))
        _require((new.text[:start] + new.text[end:]).encode() == before,
                 "UI neighboring raw bytes changed")
    return before


def product_inverse(before, after, path):
    _require(path in SOURCE_PATHS and type(before) is bytes and type(after) is bytes
             and (_sha(before), _sha(after)) == RAW_SHA256.get(path), "unapproved source raw/path")
    old, new = before.splitlines(True), after.splitlines(True)
    restored = list(new)
    for tag, a, z, b, end, prior_sha, current_sha in reversed(RAW_PATCHES[path]):
        _require(_sha(b"".join(old[a:z])) == prior_sha and _sha(b"".join(new[b:end])) == current_sha
                 and tag in {"replace", "insert"}, "exact source hunk coordinate/bytes")
        restored[b:end] = old[a:z]
    _require(b"".join(restored) == before, "source changed outside owned hunks")
    return _source_semantics(before, after, path)


def _validated_ledger_documents(before, after):
    old, new = _Document(before), _Document(after)
    a, b = old.value, new.value
    _require(len(a["batches"]) == 277 and len(b["batches"]) == 280
             and b["batches"][:277] == a["batches"], "exact old277 batch prefix")
    _require(old.text[old.spans[("batches",)][0]:old.spans[("batches", 276)][1]]
             == new.text[new.spans[("batches",)][0]:new.spans[("batches", 276)][1]],
             "original277 batch raw prefix changed")
    _require(list(a["accepted"]) == list(b["accepted"]) == list(LOCALES), "exact accepted locales")
    expected = copy.deepcopy(a)
    replacements = []
    for locale in LOCALES:
        _require(RECEIPT_ID not in a["accepted"][locale]
                 and OLD_RECEIPT_ID not in a["accepted"][locale], "first receipt and no retained-key acceptance")
        expected["accepted"][locale][RECEIPT_ID] = b["accepted"][locale][RECEIPT_ID]
        _require([key for key in b["accepted"][locale] if key != RECEIPT_ID]
                 == list(a["accepted"][locale]), "existing receipt key order")
        replacements.append(_member_removal(new, ("accepted", locale, RECEIPT_ID)))
    expected["accepted_sha256"], expected["batches"] = _digest(expected["accepted"]), b["batches"]
    _require(expected == b and all(x["accepted_sha256"] == _digest(x["accepted"]) for x in (a, b))
             and [sum(len(v) for v in x["accepted"].values()) for x in (a, b)] == [41852, 41855],
             "exact first3/current population, checksum and unchanged old receipts")
    for key in (("accepted_sha256",), ("batches",)):
        p, q = old.spans[key]
        x, y = new.spans[key]
        replacements.append((x, y, old.text[p:q]))
    restored = new.text
    for x, y, literal in sorted(replacements, reverse=True):
        restored = restored[:x] + literal + restored[y:]
    _require(restored.encode() == before, "ledger raw outside first3/append changed")
    return old, new


def _ledger_inverse(before, after):
    _validated_ledger_documents(before, after)
    return before


def _receipt_semantics(before, after):
    _require(type(before) is dict and type(after) is dict and set(before) == set(after) == set(PATHS),
             "receipt snapshot population")
    _require(all(before[p] == after[p] for p in SOURCE_PATHS)
             and (_sha(before[LEDGER_PATH]), _sha(after[LEDGER_PATH])) == RECEIPT_RAW_SHA256,
             "ledger-only receipt raw binding")
    old_document, new_document = _validated_ledger_documents(before[LEDGER_PATH], after[LEDGER_PATH])
    old, new = old_document.value, new_document.value
    _require(old.get("schema_version") == 1 and old.get("prompt_version") == "full-ko-direct-2026-09-07.1"
             and old.get("native_review") == "OPEN" and set(RECEIPT_BATCH_SHA256) == set(LOCALES),
             "original receipt schema/native/prompt and three batch pins")
    source_hash = _digest({"path": "runtime:static_ui", "field": (NEW_KEY,), "ko": NEW_KEY})
    seen = set()
    for batch in new["batches"][277:]:
        headers = batch.get("official_receipt_headers_by_locale", {})
        _require(len(headers) == 1, "one portable locale header per batch")
        locale = next(iter(headers))
        _require(locale in LOCALES and locale not in seen and _digest(batch) == RECEIPT_BATCH_SHA256[locale],
                 "actual portable batch identity")
        seen.add(locale)
        path = UI_PATHS[LOCALES.index(locale)]
        target = _loads(after[path])[NEW_KEY]
        _require(target == TARGETS[locale], "receipt target is exact source4 draft")
        translation = {"source_sha256": source_hash, "target_sha256": _digest(target)}
        _require(new["accepted"][locale][RECEIPT_ID] == translation, "current source/target receipt binding")
        header = headers[locale]
        row = {"group": "ui", "owner": NEW_KEY, "source_path": "runtime:static_ui", "path": [NEW_KEY],
               "source": NEW_KEY, "category": "ui_static_context", "lifecycle": "not_applicable",
               "protected": False, "runtime_support": "builtin_overlay_static_only", "format_template": False,
               "id": RECEIPT_ID, "source_sha256": source_hash, "locale": locale, "prompt_version": old["prompt_version"],
               "target_path": path, "previous_target_sha256": _digest(_loads(before[path])[NEW_KEY])}
        expected = {"kind": "full_game_localization_batch", "schema_version": 1, "locale": locale,
                    "source_revision": header.get("source_revision"), "prompt_version": old["prompt_version"],
                    "source_manifest_sha256": RECEIPT_SOURCE_MANIFEST_SHA256,
                    "selection_sha256": _digest([row]), "count": 1, "source_language": "ko", "native_review": "OPEN"}
        expected["batch_id"] = _digest(expected)
        _require(header == expected and header["source_revision"] == RECEIPT_PARENT,
                 "official source4 export selection/current target/revision")
        _require(batch.get("order") == "ORDER-482" and batch.get("group") == "ui"
                 and batch.get("source_leaves") == 1 and batch.get("machine_validation") == "PASS"
                 and batch.get("native_review") == batch.get("rendered_review") == "OPEN"
                 and set(batch.get("target_leaves_by_locale", {})) <= set(LOCALES)
                 and all(batch.get("target_leaves_by_locale", {}).get(loc, 0) == int(loc == locale) for loc in LOCALES),
                 "first3 machine-only acceptance counts")
        receipt = {"batch": header, "state": "accepted_machine_validated", "native_review": "OPEN",
                   "translations": {RECEIPT_ID: translation}}
        _require(batch.get("receipt_sha256_by_locale") == {locale: _digest(receipt)}, "official receipt digest")
    _require(seen == set(LOCALES), "all three first receipts")
    return RECEIPT_PARENT


def _configuration():
    constants = tuple((k, copy.deepcopy(v)) for k, v in sorted(globals().items())
                      if k.isupper() and not k.startswith("_"))
    functions = tuple((k, v, v.__code__, getattr(getattr(v, "__wrapped__", None), "__code__", None))
                      for k, v in sorted(globals().items())
                      if callable(v) and hasattr(v, "__code__") and v.__module__ == __name__)
    return constants, functions, (_Document, _Document.__init__.__code__, _Document.walk.__code__, _Document.ws.__code__)


def _pure_semantic_value(value):
    """Detach mutable defaults/config without using the primitives being sealed."""
    if type(value) in (tuple, list):
        return type(value), tuple(_pure_semantic_value(item) for item in value)
    if type(value) is dict:
        return dict, tuple((_pure_semantic_value(key), _pure_semantic_value(item))
                           for key, item in value.items())
    if type(value) in (set, frozenset):
        return type(value), frozenset(_pure_semantic_value(item) for item in value)
    if isinstance(value, Path):
        return type(value), str(value)
    if hasattr(value, "__code__"):
        return _pure_semantic_callable(value)
    return type(value), value


def _pure_semantic_callable(function):
    wrapped = getattr(function, "__wrapped__", None)
    return (function, getattr(function, "__code__", None),
            _pure_semantic_value(getattr(function, "__defaults__", None)),
            _pure_semantic_value(getattr(function, "__kwdefaults__", None)),
            None if wrapped is None else _pure_semantic_callable(wrapped))


def _pure_semantic_primitives():
    """Bind selected external globals whose mutation could stale a pure result."""
    functions = (json.loads, json.dumps, copy.deepcopy, hashlib.sha1, hashlib.sha256,
                 json.decoder.scanstring, json.scanner.make_scanner,
                 json.encoder.encode_basestring, json.encoder.encode_basestring_ascii,
                 json.encoder.c_make_encoder, re.fullmatch, Path.resolve, open,
                 threading.get_ident, threading.current_thread, asyncio.get_running_loop)
    classes = tuple((cls, tuple((name, _pure_semantic_callable(getattr(cls, name)))
                               for name in names))
                    for cls, names in ((json.JSONDecoder, ("__init__", "decode", "raw_decode")),
                                       (json.JSONEncoder, ("__init__", "default", "encode", "iterencode")),
                                       (_Document, ("__init__", "walk", "ws"))))
    dispatch = tuple((kind, _pure_semantic_callable(function))
                     for kind, function in sorted(copy._deepcopy_dispatch.items(),
                                                  key=lambda item: (item[0].__module__, item[0].__qualname__)))
    return ((json, copy, hashlib, re, Path, threading, asyncio),
            tuple(_pure_semantic_callable(function) for function in functions), classes, dispatch,
            _PURE_SEMANTIC_OWNER, _PURE_SEMANTIC_CONTEXT)


def _pure_semantic_binding(root):
    """Physical/config binding only; this is never a fresh Git admission."""
    root = Path(root).resolve()
    module = Path(__file__).resolve()
    _require(module == root / "tools/asset_one_billion_log_history.py", "pure semantic module/root identity")
    primitives = _pure_semantic_primitives()
    configuration = _configuration()
    functions = tuple((name, _pure_semantic_callable(function))
                      for name, function in sorted(globals().items())
                      if callable(function) and hasattr(function, "__code__"))
    physical = _disk_bytes(module)
    _require(_pure_semantic_primitives() == primitives, "pure semantic primitive changed during binding")
    return root, module, physical, configuration, functions, primitives


def _invalidate_pure_semantics(owner):
    if owner is not None:
        owner["cache"].clear()
        owner["poisoned"] = True


def _require_synchronous_pure_semantics():
    try:
        asyncio.get_running_loop()
    except RuntimeError:
        return
    raise ValueError("ORDER-482: async pure semantic owner is unsupported")


def _require_pure_semantic_owner(root, owner):
    _require_synchronous_pure_semantics()
    _require(_PURE_SEMANTIC_OWNER.get() is owner and owner["open"] and not owner["poisoned"],
             "pure semantic owner is not healthy/open")
    _require(threading.get_ident() == owner["thread"] and _PURE_SEMANTIC_CONTEXT.get() is owner["marker"],
             "pure semantic owner cannot cross thread/context")
    # A copied Context carries our state reference, but cannot reset the token
    # issued by the owning Context. Rotate only this marker, not any proof scope.
    _PURE_SEMANTIC_CONTEXT.reset(owner["context_token"])
    owner["context_token"] = _PURE_SEMANTIC_CONTEXT.set(owner["marker"])
    _require(_pure_semantic_binding(root) == owner["binding"], "pure semantic root/module/config/primitive changed")


@contextlib.contextmanager
def pure_semantic_scope(root=ROOT):
    """One synchronous cold owner; no proof/Document or Git verdict is retained."""
    active = _PURE_SEMANTIC_OWNER.get()
    if active is not None:
        _invalidate_pure_semantics(active)
        raise ValueError("ORDER-482: nested pure semantic owner is unsupported")
    _require_synchronous_pure_semantics()
    root = Path(root).resolve()
    owner = {"root": root, "binding": _pure_semantic_binding(root), "cache": {},
             "poisoned": False, "open": True, "thread": threading.get_ident(), "marker": object()}
    token = _PURE_SEMANTIC_OWNER.set(owner)
    owner["token"] = token
    owner["context_token"] = _PURE_SEMANTIC_CONTEXT.set(owner["marker"])
    try:
        try:
            yield
            _require_pure_semantic_owner(root, owner)
        except BaseException:
            _invalidate_pure_semantics(owner)
            raise
    finally:
        owner["cache"].clear()
        owner["open"] = False
        try:
            _PURE_SEMANTIC_CONTEXT.reset(owner["context_token"])
        finally:
            _PURE_SEMANTIC_OWNER.reset(token)


def _receipt_semantic_key(before, after):
    _require(type(before) is dict and type(after) is dict and set(before) == set(after) == set(PATHS),
             "pure receipt exact path population")
    _require(all(type(before[path]) is bytes and type(after[path]) is bytes for path in PATHS),
             "pure receipt requires exact immutable bytes")
    return tuple((path, before[path], after[path]) for path in PATHS)


def _memoized_receipt_semantics(root, before, after):
    owner = _PURE_SEMANTIC_OWNER.get()
    if owner is None:
        return _receipt_semantics(before, after)
    try:
        _require_pure_semantic_owner(root, owner)
        key = _receipt_semantic_key(before, after)
        if key in owner["cache"]:
            result = owner["cache"][key]
        else:
            result = _receipt_semantics(before, after)
            _require_pure_semantic_owner(root, owner)
            _require(_receipt_semantic_key(before, after) == key, "pure receipt inputs changed during calculation")
            _require(type(result) is str and result == RECEIPT_PARENT, "pure receipt result is not immutable parent")
            owner["cache"].clear()
            owner["cache"][key] = result
        _require(type(result) is str and result == RECEIPT_PARENT, "pure receipt result is not immutable parent")
        return result
    except BaseException:
        _invalidate_pure_semantics(owner)
        raise


def _transition(root, head, parent, commit, before, changed):
    actual_before, _ = _snapshot(root, parent, PATHS)
    after, headers = _snapshot(root, commit, PATHS)
    _require(actual_before == before, "stage parent raw differs from immutable predecessor")
    _require([h[7:].decode() for h in headers if h.startswith(b"parent ")] == [parent], "exact direct parent")
    _require(_git(root, "diff", "--name-status", "-z", parent, commit)
             == b"".join(b"M\0" + p.encode() + b"\0" for p in sorted(changed)), "exact global changed pathset")
    _git(root, "merge-base", "--is-ancestor", commit, head)
    _require(all(after[p] == before[p] for p in PATHS if p not in changed), "protected stage raw changed")
    return after


def _read_proof_current(root):
    root = Path(root).resolve()
    module = Path(__file__).resolve()
    _require(module == root / "tools/asset_one_billion_log_history.py", "module/root identity")
    module_raw, binding = _disk_bytes(module), _configuration()
    head = _git(root, "rev-parse", "--verify", "HEAD^{commit}").decode().strip()
    before, _ = _snapshot(root, PREDECESSOR_COMMIT, PATHS)
    _git(root, "merge-base", "--is-ancestor", PREDECESSOR_COMMIT, PRODUCT_PARENT)
    source = _transition(root, head, PRODUCT_PARENT, PRODUCT_COMMIT, before, SOURCE_PATHS)
    _require(set(RAW_SHA256) == set(RAW_PATCHES) == set(SOURCE_PATHS), "exact four source pins")
    for path in SOURCE_PATHS:
        product_inverse(before[path], source[path], path)
    _require(_sha(source[LEDGER_PATH]) == SOURCE_LEDGER_SHA256, "source stage retains immutable480 ledger")
    current, receipts = source, None
    if RECEIPT_COMMIT is not None:
        _git(root, "merge-base", "--is-ancestor", PRODUCT_COMMIT, RECEIPT_PARENT)
        receipts = _transition(root, head, RECEIPT_PARENT, RECEIPT_COMMIT, source, (LEDGER_PATH,))
        revision = _memoized_receipt_semantics(root, source, receipts)
        export, _ = _snapshot(root, revision, PATHS)
        _require(export == source, "export typed snapshot differs from actual source4")
        _git(root, "merge-base", "--is-ancestor", revision, RECEIPT_COMMIT)
        current = receipts
    else:
        _require(RECEIPT_PARENT is RECEIPT_SOURCE_MANIFEST_SHA256 is None
                 and RECEIPT_BATCH_SHA256 == {} and RECEIPT_RAW_SHA256 == (), "partial unbound receipt configuration")
    actual, _ = _snapshot(root, head, PATHS)
    _require(actual == current and all(_disk_bytes(root / p) == raw for p, raw in actual.items()),
             "actual current Git/disk differs")
    _require(_git(root, "rev-parse", "--verify", "HEAD^{commit}").decode().strip() == head
             and _disk_bytes(module) == module_raw and _configuration() == binding,
             "HEAD/module/function/config changed during proof")
    return {"root": root, "head": head, "before": before, "source": source, "receipts": receipts,
            "current": actual, "binding": binding, "module_raw": module_raw}


def _read_proof(root):
    """Keep every original fresh edge; poison pure reuse on even a caught failure."""
    owner = _PURE_SEMANTIC_OWNER.get()
    try:
        proof = _read_proof_current(root)
        if owner is not None:
            _require_pure_semantic_owner(root, owner)
            active = _ACTIVE.get()
            if active is not None and proof != active:
                _invalidate_pure_semantics(owner)
        return proof
    except BaseException:
        _invalidate_pure_semantics(owner)
        raise


@contextlib.contextmanager
def fresh_validation_proof(root=ROOT):
    active = _ACTIVE.get()
    if active is not None:
        _require(Path(root).resolve() == active["root"] and _read_proof(root) == active,
                 "nested current/typed/config proof differs")
        try:
            yield copy.deepcopy(active)
        finally:
            _require(_read_proof(root) == active, "nested proof changed during use")
        return
    proof = _read_proof(root)
    token = _ACTIVE.set(proof)
    try:
        try:
            yield copy.deepcopy(proof)
        finally:
            _require(_read_proof(root) == proof, "actual proof changed during use")
    finally:
        _ACTIVE.reset(token)


def game_state_predecessor(actual_raw, root=ROOT):
    with fresh_validation_proof(root) as proof:
        _require(type(actual_raw) is bytes and actual_raw == proof["current"][GAME_STATE_PATH],
                 "actual GameState raw required")
        return proof["before"][GAME_STATE_PATH]


def game_state_inverse(actual_raw):
    """Pure pinned482 -> post480 bytes; never admits a live Git claim."""
    _require(type(actual_raw) is bytes, "GameState inverse requires raw bytes")
    old = ('LocaleManager.ui("' + OLD_KEY + '", "' + OLD_ENGLISH + '")').encode()
    new = ('LocaleManager.ui("' + NEW_KEY + '", "' + NEW_ENGLISH + '")').encode()
    prior = actual_raw.replace(new, old, 1)
    return product_inverse(prior, actual_raw, GAME_STATE_PATH)


def source_predecessor(snapshot, root=ROOT):
    """Actual source4 -> immutable post480 source4, for comparison only."""
    with fresh_validation_proof(root) as proof:
        _require(type(snapshot) is dict and set(snapshot) == set(SOURCE_PATHS)
                 and all(type(raw) is bytes and raw == proof["current"][path]
                         for path, raw in snapshot.items()), "actual source4 identity required")
        return {path: proof["before"][path] for path in SOURCE_PATHS}


def source_predecessor_inventory(root, inventory):
    with fresh_validation_proof(root) as proof:
        hashes = inventory["source_hashes"]
        _require(type(hashes) is dict and _digest(hashes) == inventory["source_manifest_sha256"]
                 and hashes.get(GAME_STATE_PATH) == _sha(proof["current"][GAME_STATE_PATH]), "actual source census")
        actual, _ = _snapshot(root, proof["head"], tuple(hashes))
        _require({p: _sha(raw) for p, raw in actual.items()} == hashes
                 and all(_disk_bytes(Path(root) / p) == raw for p, raw in actual.items()), "whole actual census Git/disk")
        compared = {**hashes, GAME_STATE_PATH: _sha(proof["before"][GAME_STATE_PATH])}
        parent, _ = _snapshot(root, PRODUCT_PARENT, tuple(compared))
        _require({p: _sha(raw) for p, raw in parent.items()} == compared
                 and _digest(compared) == PREDECESSOR_SOURCE_MANIFEST_SHA256, "exact whole pre482 census")
        final, _ = _snapshot(root, proof["head"], tuple(hashes))
        _require(final == actual and all(_disk_bytes(Path(root) / p) == raw for p, raw in final.items()),
                 "whole census changed during comparison")
        return {**inventory, "source_hashes": compared, "source_manifest_sha256": _digest(compared)}


def ui_comparison(snapshot, before, after):
    """Exact current four-raw stage -> its immutable comparison, not runtime."""
    _require(type(snapshot) is dict and type(before) is dict and type(after) is dict
             and set(snapshot) == set(before) == set(after) == set(CURRENT_UI_PATHS)
             and snapshot == after and all(type(v) is bytes for v in snapshot.values()),
             "exact current four-raw comparison")
    if before[UI_PATHS[0]] != after[UI_PATHS[0]]:
        for path in UI_PATHS:
            product_inverse(before[path], after[path], path)
        _require(before[LEDGER_PATH] == after[LEDGER_PATH]
                 and _sha(before[LEDGER_PATH]) == SOURCE_LEDGER_SHA256, "source4 ledger unchanged")
    else:
        _require(RECEIPT_COMMIT is not None and all(before[p] == after[p] for p in UI_PATHS)
                 and all(_sha(after[p]) == RAW_SHA256[p][1] for p in UI_PATHS)
                 and (_sha(before[LEDGER_PATH]), _sha(after[LEDGER_PATH])) == RECEIPT_RAW_SHA256,
                 "exact bound receipt comparison")
        _ledger_inverse(before[LEDGER_PATH], after[LEDGER_PATH])
    return dict(before)


def ui_predecessor(snapshot, root=ROOT):
    """Actual four-raw only -> pre482 copy, never runtime values."""
    with fresh_validation_proof(root) as proof:
        current = {p: proof["current"][p] for p in CURRENT_UI_PATHS}
        _require(type(snapshot) is dict and set(snapshot) == set(CURRENT_UI_PATHS)
                 and all(type(v) is bytes for v in snapshot.values()) and snapshot == current,
                 "actual current four-raw identity required")
        return {p: proof["before"][p] for p in CURRENT_UI_PATHS}
