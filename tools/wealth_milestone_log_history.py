"""Exact480 source4/first-three-receipt successor, never a runtime rollback.

This leaf proof imports no other project module. Older owners may consume its
comparison views without a recursive history dependency. Every public entry
revalidates actual typed Git objects, physical disk and configuration.
"""
from __future__ import annotations

import contextlib
import contextvars
import copy
import hashlib
import json
import re
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
GAME_STATE_PATH = "autoloads/GameState.gd"
LEDGER_PATH = "content/meta/full_game_localization.json"
LOCALES = ("ja", "zh-CN", "zh-TW")
UI_PATHS = tuple("locale/ui_" + loc + ".json" for loc in LOCALES)
CURRENT_UI_PATHS = (*UI_PATHS, LEDGER_PATH)
SOURCE_PATHS = (GAME_STATE_PATH, *UI_PATHS)
PATHS = (*SOURCE_PATHS, LEDGER_PATH)
PREDECESSOR_COMMIT = "ae01837dc6cfc0a272534ed38e654513d21cc6e5"
PRODUCT_PARENT = "209b79ec7df4e6e3a2bcc652f3371b1b24d862a5"
PRODUCT_COMMIT = "42d30615708ef3344a1cad8af0aad7cebe7e6ca7"
PREDECESSOR_SOURCE_MANIFEST_SHA256 = "877171e48c9d8b595d33144c3cc0c1e79cb4715e81236c1851eb368943d5832d"
SOURCE_LEDGER_SHA256 = "0cbec03c72fbf4818fd9285bf66b95e8630af6a7396e461b9151421348900cf4"
OLD_KEY = "🔥 자산 20억 돌파 — 강남이 손에 잡힐 듯하다. 남은 건 10억."
NEW_KEY = "🔥 자산 20억 돌파 — 강남이 손에 잡힐 듯하다."
OLD_ENGLISH = "🔥 Assets passed KRW 2B — Gangnam feels close. KRW 1B left."
NEW_ENGLISH = "🔥 Assets passed KRW 2B — Gangnam feels close."
TARGETS = {
    "ja": "🔥 資産が20億ウォンを突破 — カンナムに手が届きそうだ。",
    "zh-CN": "🔥 资产突破20亿韩元——江南仿佛触手可及。",
    "zh-TW": "🔥 資產突破20億韓元——江南彷彿近在眼前。",
}
OLD_JA = "🔥 資産20億突破 — カンナムが手に掴めるようだ。残るは10億。"
RECEIPT_ID = "ui:" + NEW_KEY + ":/" + NEW_KEY
OLD_RECEIPT_ID = "ui:" + OLD_KEY + ":/" + OLD_KEY
# Actual acceptance is a separate ledger-only commit; no draft is a receipt.
RECEIPT_PARENT = "2b7ed73b193488f961637d12dbc2173b0523998d"
RECEIPT_COMMIT = "5503f68bfa009478da675e58ab5ffb0e37ecada7"
RECEIPT_RAW_SHA256 = ("0cbec03c72fbf4818fd9285bf66b95e8630af6a7396e461b9151421348900cf4", "fa200e234491545d51e4d0395715eec274dc35cb04f3552003ab3729574cb027")
RECEIPT_BATCH_SHA256 = {
    "ja": "8a43c85ea7a43684b4338c72e1ec0e5ed99ff207bf952d186133c6c498da66e4",
    "zh-CN": "a96ba48fe93ec788eafc50833dc8415b2acd33061829841ecc9ea1026e2f08e7",
    "zh-TW": "e567baec03f92e2257d647e3c4b31aadf67ed7da315f9f10585bbb235e9e1b10",
}
RECEIPT_SOURCE_MANIFEST_SHA256 = "cf4f8f1221742440a4246e96763af707446684d99c69e43884c71d83f0ec7868"
RAW_SHA256 = {'autoloads/GameState.gd': ('03ac214f4ad4fafe5f242c61df79eb89c09aca5b7a0a686a7c386df75a5ba978', 'dfa8c48596917c3b33eb1add4079b790c4bea8b09cc38c03a08165a2955b7bd1'), 'locale/ui_ja.json': ('9b450541a8d51be03f09f2a1f180cf1fb5e548e51a25648dacc9eddb055c32fb', '5a6a314b7fd4a82cf698bd86a832939e47596ece734c0edb4d006714393a8b2c'), 'locale/ui_zh-CN.json': ('5a36d9c19be5ad1dab97e420cdff4b39ad0cf29554213c765991fb7db834cb4f', 'b4b7c60cf82332ae1f58684aaab1ba46451c1e3a5abe6823e6802ec11180df99'), 'locale/ui_zh-TW.json': ('a46a54cf6642c22edae87e3be7b4a70517fe9434cf98437481ed3d07fd17b069', '5d8ca777bda61579b3b1ed44be60840c8984aebc6aaf47b1d545219b23f9fb82')}
RAW_PATCHES = {'autoloads/GameState.gd': (('replace', 4331, 4332, 4331, 4332, '18078176d3dc68ce75bd84d8ff14c6dd99f18c1cc907564d32dbba2c4bdea0d1', 'dce6b917e6249ff93986bf44ee7d6a4bf2f766a5c064005dee8395b395d0adfe'),), 'locale/ui_ja.json': (('insert', 1818, 1818, 1818, 1819, 'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855', '017e4050f506ac183144779004940423d6d0bb6a0b0f4c78c5b292f24cb07ed9'),), 'locale/ui_zh-CN.json': (('insert', 1809, 1809, 1809, 1810, 'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855', '2a0b4c589840063a6e5ba37e82af5f53896ac461a3904cc4682fa2da835bbf58'),), 'locale/ui_zh-TW.json': (('insert', 1809, 1809, 1809, 1810, 'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855', '3adfdc4c7a7dc6e829176f75355fe3dba45b63362edd01f87bf6f1fc1a93b91e'),)}
_ACTIVE = contextvars.ContextVar("wealth_milestone_log_proof", default=None)


def _require(ok, detail):
    if not ok:
        raise ValueError("ORDER-480: " + detail)


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
    _require(len(a["batches"]) == 274 and len(b["batches"]) == 277
             and b["batches"][:274] == a["batches"], "exact old274 batch prefix")
    _require(old.text[old.spans[("batches",)][0]:old.spans[("batches", 273)][1]]
             == new.text[new.spans[("batches",)][0]:new.spans[("batches", 273)][1]],
             "original274 batch raw prefix changed")
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
             and [sum(len(v) for v in x["accepted"].values()) for x in (a, b)] == [41849, 41852],
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
    for batch in new["batches"][274:]:
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
        _require(batch.get("order") == "ORDER-480" and batch.get("group") == "ui"
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


def _read_proof(root):
    root = Path(root).resolve()
    module = Path(__file__).resolve()
    _require(module == root / "tools/wealth_milestone_log_history.py", "module/root identity")
    module_raw, binding = _disk_bytes(module), _configuration()
    head = _git(root, "rev-parse", "--verify", "HEAD^{commit}").decode().strip()
    before, _ = _snapshot(root, PREDECESSOR_COMMIT, PATHS)
    _git(root, "merge-base", "--is-ancestor", PREDECESSOR_COMMIT, PRODUCT_PARENT)
    source = _transition(root, head, PRODUCT_PARENT, PRODUCT_COMMIT, before, SOURCE_PATHS)
    _require(set(RAW_SHA256) == set(RAW_PATCHES) == set(SOURCE_PATHS), "exact four source pins")
    for path in SOURCE_PATHS:
        product_inverse(before[path], source[path], path)
    _require(_sha(source[LEDGER_PATH]) == SOURCE_LEDGER_SHA256, "source stage retains immutable478 ledger")
    current, receipts = source, None
    if RECEIPT_COMMIT is not None:
        _git(root, "merge-base", "--is-ancestor", PRODUCT_COMMIT, RECEIPT_PARENT)
        receipts = _transition(root, head, RECEIPT_PARENT, RECEIPT_COMMIT, source, (LEDGER_PATH,))
        revision = _receipt_semantics(source, receipts)
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
                 and _digest(compared) == PREDECESSOR_SOURCE_MANIFEST_SHA256, "exact whole pre480 census")
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
    """Actual four-raw only -> pre480 copy, never runtime values."""
    with fresh_validation_proof(root) as proof:
        current = {p: proof["current"][p] for p in CURRENT_UI_PATHS}
        _require(type(snapshot) is dict and set(snapshot) == set(CURRENT_UI_PATHS)
                 and all(type(v) is bytes for v in snapshot.values()) and snapshot == current,
                 "actual current four-raw identity required")
        return {p: proof["before"][p] for p in CURRENT_UI_PATHS}
