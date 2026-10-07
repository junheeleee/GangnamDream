"""Exact478 source2/first-JA-receipt successor, never a runtime rollback.

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
INVESTMENT_PATH = "systems/InvestmentSystem.gd"
JA_PATH = "locale/ui_ja.json"
LEDGER_PATH = "content/meta/full_game_localization.json"
LOCALES = ("ja", "zh-CN", "zh-TW")
UI_PATHS = tuple("locale/ui_" + loc + ".json" for loc in LOCALES)
CURRENT_UI_PATHS = (*UI_PATHS, LEDGER_PATH)
PATHS = (INVESTMENT_PATH, *CURRENT_UI_PATHS)
SOURCE_PATHS = (INVESTMENT_PATH, JA_PATH)
PREDECESSOR_COMMIT = "d1ef3d225b2364f90163cb7bb734ea03655ae45c"
PRODUCT_PARENT = "dfc23a93d8f3c028528dae2405bd63b11e6fac4d"
PRODUCT_COMMIT = "20443aa07a5f260ec4b581aaec97c89388004705"
PREDECESSOR_SOURCE_MANIFEST_SHA256 = "cd3a8af9a4f972f4fea87ea1630b6d31013418d35e0b4b29f01c0a7cc67a314b"
RAW_SHA256 = {
    INVESTMENT_PATH: ("b44a5c60c9f0ffd5d49829a3e041ea6a304ad46717683bfd8a9eb6d7b1f2c718", "b2f4f8dc1658d6003884ac6ebc3f1803429490d8585a7121edfab3128777e019"),
    JA_PATH: ("c056e24b20ad6e9711bce82eaaface23edc49d62d4598d397baf08ed5a7b2816", "9b450541a8d51be03f09f2a1f180cf1fb5e548e51a25648dacc9eddb055c32fb"),
}
SOURCE_LEDGER_SHA256 = "3902a0003fc48ca635510061d07fe6a1354bde5a46257c52de12164829b8f9cc"
PROTECTED_RAW_SHA256 = {
    UI_PATHS[1]: "5a36d9c19be5ad1dab97e420cdff4b39ad0cf29554213c765991fb7db834cb4f",
    UI_PATHS[2]: "a46a54cf6642c22edae87e3be7b4a70517fe9434cf98437481ed3d07fd17b069",
}
RAW_PATCHES = {
    INVESTMENT_PATH: (("replace", 137, 138, 137, 138, "ca16dd1ea1d0476d60c2faed76419789ba6c8035a4882a644340e4503b13a07b", "3f8f5034be84937602381a0319e7baba7621970cf3e674e06264dd6f0a41a8ba"),
                      ("insert", 291, 291, 291, 302, "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855", "5928888ad18e454440d62fc22cc326ef673f11a404d8a4901d4cbdf0d153f4d5")),
    JA_PATH: (("replace", 1763, 1764, 1763, 1764, "186343378b504ce97d08ec79089e796f6e9d8df13984a21b8b814249646cddc5", "56414e62fed593d69280a8976d3ede6c5f694b45a7f87dfc65277a519a4b3128"),),
}
SOURCE_KEY = "횡보장"
OLD_JA, CURRENT_JA = "横歩場", "横ばい相場"
RECEIPT_ID = "ui:횡보장:/횡보장"
OLD_LOG = '\tGameState.add_log(LocaleManager.ui("시장 국면 전환: %s", "Market cycle shifted: %s") % cycle, "market")\n'.encode()
NEW_LOG = OLD_LOG.replace(b"% cycle,", b"% _cycle_display_name(cycle),")
HELPER_APPEND = '''
func _cycle_display_name(cycle: String) -> String:
\tmatch cycle:
\t\t"bull":
\t\t\treturn LocaleManager.ui("상승장", "Bull Market")
\t\t"bear":
\t\t\treturn LocaleManager.ui("하락장", "Bear Market")
\t\t"neutral":
\t\t\treturn LocaleManager.ui("횡보장", "Sideways")
\t\t_:
\t\t\treturn cycle
'''.encode()
# No invented acceptance: filled only from the actual separate ledger commit.
RECEIPT_PARENT = "d68bc66b228b0a908defef747d206e05ac66a0fc"
RECEIPT_COMMIT = "ae01837dc6cfc0a272534ed38e654513d21cc6e5"
RECEIPT_RAW_SHA256 = ("3902a0003fc48ca635510061d07fe6a1354bde5a46257c52de12164829b8f9cc", "0cbec03c72fbf4818fd9285bf66b95e8630af6a7396e461b9151421348900cf4")
RECEIPT_BATCH_SHA256 = "d0025f2b84e0be33521ad38eabcdd09423336999249961e23913e229dc144f85"
RECEIPT_SOURCE_MANIFEST_SHA256 = "877171e48c9d8b595d33144c3cc0c1e79cb4715e81236c1851eb368943d5832d"
_ACTIVE = contextvars.ContextVar("market_cycle_label_proof", default=None)


def _require(ok, detail):
    if not ok:
        raise ValueError("ORDER-478: " + detail)


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
        if type(self.text) is str and type(index) is int and 0 <= index <= len(self.text):
            if index == len(self.text) or not self.text[index].isspace():
                return index
            return re.compile(r"\s*").match(self.text, index).end()
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


def _source_semantics(before, after, path):
    if path == INVESTMENT_PATH:
        _require(before.count(OLD_LOG) == after.count(NEW_LOG) == 1
                 and b"func _cycle_display_name(" not in before
                 and after == before.replace(OLD_LOG, NEW_LOG, 1) + HELPER_APPEND,
                 "only log argument and exact pure helper may change")
    else:
        _require(path == JA_PATH, "unowned source path")
        old, new = _Document(before), _Document(after)
        _require(type(old.value) is dict and type(new.value) is dict
                 and list(old.value) == list(new.value)
                 and old.value.get(SOURCE_KEY) == OLD_JA and new.value.get(SOURCE_KEY) == CURRENT_JA
                 and {**old.value, SOURCE_KEY: CURRENT_JA} == new.value,
                 "exact Japanese existing neutral label only")
        a, z = old.spans[(SOURCE_KEY,)]
        b, end = new.spans[(SOURCE_KEY,)]
        _require((new.text[:b] + old.text[a:z] + new.text[end:]).encode() == before,
                 "Japanese neighboring raw bytes changed")
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
    """Return fresh documents only after the complete raw inverse passes."""
    old, new = _Document(before), _Document(after)
    a, b = old.value, new.value
    _require(len(a["batches"]) == 273 and len(b["batches"]) == 274
             and b["batches"][:273] == a["batches"], "exact old273 batch prefix")
    _require(old.text[old.spans[("batches",)][0]:old.spans[("batches", 272)][1]]
             == new.text[new.spans[("batches",)][0]:new.spans[("batches", 272)][1]],
             "original273 batch raw prefix changed")
    _require(RECEIPT_ID not in a["accepted"]["ja"]
             and list(a["accepted"]) == list(b["accepted"]) == list(LOCALES), "exact new JA receipt locale")
    expected = copy.deepcopy(a)
    expected["accepted"]["ja"][RECEIPT_ID] = b["accepted"]["ja"][RECEIPT_ID]
    expected["accepted_sha256"], expected["batches"] = _digest(expected["accepted"]), b["batches"]
    _require(expected == b and all(x["accepted_sha256"] == _digest(x["accepted"]) for x in (a, b))
             and [sum(len(v) for v in x["accepted"].values()) for x in (a, b)] == [41848, 41849],
             "exact first1/current key population, checksum and existing receipts")
    keys = list(b["accepted"]["ja"])
    index = keys.index(RECEIPT_ID)
    _require([k for k in keys if k != RECEIPT_ID] == list(a["accepted"]["ja"]), "existing JA receipt order")
    own = ("accepted", "ja", RECEIPT_ID)
    if index:
        start = new.spans[("accepted", "ja", keys[index - 1])][1]
        end = new.spans[own][1]
    else:
        start = new.members[own][0]
        end = new.members[("accepted", "ja", keys[1])][0]
    replacements = [(start, end, "")]
    for key in (("accepted_sha256",), ("batches",)):
        p, q = old.spans[key]
        x, y = new.spans[key]
        replacements.append((x, y, old.text[p:q]))
    restored = new.text
    for x, y, literal in sorted(replacements, reverse=True):
        restored = restored[:x] + literal + restored[y:]
    _require(restored.encode() == before, "ledger raw outside owned first receipt/append changed")
    return old, new


def _ledger_inverse(before, after):
    _validated_ledger_documents(before, after)
    return before


def _receipt_semantics(before, after):
    _require(type(before) is dict and set(before) == set(after) == set(PATHS), "receipt snapshot population")
    _require(all(before[p] == after[p] for p in PATHS if p != LEDGER_PATH)
             and (_sha(before[LEDGER_PATH]), _sha(after[LEDGER_PATH])) == RECEIPT_RAW_SHA256,
             "ledger-only receipt raw binding")
    old_document, new_document = _validated_ledger_documents(before[LEDGER_PATH], after[LEDGER_PATH])
    old, new = old_document.value, new_document.value
    _require(old.get("schema_version") == 1 and old.get("prompt_version") == "full-ko-direct-2026-09-07.1"
             and old.get("native_review") == "OPEN", "original receipt schema/native/prompt")
    source_hash = _digest({"path": "runtime:static_ui", "field": (SOURCE_KEY,), "ko": SOURCE_KEY})
    target = _loads(after[JA_PATH])[SOURCE_KEY]
    _require(target == CURRENT_JA, "receipt target must be actual new Japanese")
    translation = {"source_sha256": source_hash, "target_sha256": _digest(target)}
    _require(new["accepted"]["ja"][RECEIPT_ID] == translation, "current source/target receipt binding")
    batch = new["batches"][-1]
    _require(_digest(batch) == RECEIPT_BATCH_SHA256
             and set(batch["official_receipt_headers_by_locale"]) == {"ja"}, "actual portable batch pin")
    header = batch["official_receipt_headers_by_locale"]["ja"]
    row = {"group": "ui", "owner": SOURCE_KEY, "source_path": "runtime:static_ui", "path": [SOURCE_KEY],
           "source": SOURCE_KEY, "category": "ui_static_context", "lifecycle": "not_applicable",
           "protected": False, "runtime_support": "builtin_overlay_static_only", "format_template": False,
           "id": RECEIPT_ID, "source_sha256": source_hash, "locale": "ja", "prompt_version": old["prompt_version"],
           "target_path": JA_PATH, "previous_target_sha256": _digest(_loads(before[JA_PATH])[SOURCE_KEY])}
    expected = {"kind": "full_game_localization_batch", "schema_version": 1, "locale": "ja",
                "source_revision": header.get("source_revision"), "prompt_version": old["prompt_version"],
                "source_manifest_sha256": RECEIPT_SOURCE_MANIFEST_SHA256,
                "selection_sha256": _digest([row]), "count": 1, "source_language": "ko", "native_review": "OPEN"}
    expected["batch_id"] = _digest(expected)
    _require(header == expected and header["source_revision"] == RECEIPT_PARENT,
             "official export selection/current prior target/revision")
    _require(batch.get("order") == "ORDER-478" and batch.get("group") == "ui"
             and batch.get("source_leaves") == 1 and batch.get("machine_validation") == "PASS"
             and batch.get("native_review") == batch.get("rendered_review") == "OPEN"
             and set(batch.get("target_leaves_by_locale", {})) <= set(LOCALES)
             and all(batch.get("target_leaves_by_locale", {}).get(loc, 0) == int(loc == "ja") for loc in LOCALES),
             "first1 machine-only acceptance counts")
    receipt = {"batch": header, "state": "accepted_machine_validated", "native_review": "OPEN",
               "translations": {RECEIPT_ID: translation}}
    _require(batch.get("receipt_sha256_by_locale") == {"ja": _digest(receipt)}, "official receipt digest")
    return header["source_revision"]


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
    _require(module == root / "tools/market_cycle_label_history.py", "module/root identity")
    module_raw, binding = _disk_bytes(module), _configuration()
    head = _git(root, "rev-parse", "--verify", "HEAD^{commit}").decode().strip()
    before, _ = _snapshot(root, PREDECESSOR_COMMIT, PATHS)
    _git(root, "merge-base", "--is-ancestor", PREDECESSOR_COMMIT, PRODUCT_PARENT)
    source = _transition(root, head, PRODUCT_PARENT, PRODUCT_COMMIT, before, SOURCE_PATHS)
    _require(set(RAW_SHA256) == set(RAW_PATCHES) == set(SOURCE_PATHS), "exact two source pins")
    for path in SOURCE_PATHS:
        product_inverse(before[path], source[path], path)
    _require(_sha(source[LEDGER_PATH]) == SOURCE_LEDGER_SHA256, "source stage retains immutable477 ledger")
    _require(all(_sha(source[p]) == sha for p, sha in PROTECTED_RAW_SHA256.items()), "unchanged regional UI raw")
    current, receipts = source, None
    if RECEIPT_COMMIT is not None:
        _git(root, "merge-base", "--is-ancestor", PRODUCT_COMMIT, RECEIPT_PARENT)
        receipts = _transition(root, head, RECEIPT_PARENT, RECEIPT_COMMIT, source, (LEDGER_PATH,))
        revision = _receipt_semantics(source, receipts)
        export, _ = _snapshot(root, revision, PATHS)
        _require(export == source, "export typed snapshot differs from actual source2")
        _git(root, "merge-base", "--is-ancestor", revision, RECEIPT_COMMIT)
        current = receipts
    else:
        _require(RECEIPT_PARENT is RECEIPT_BATCH_SHA256 is RECEIPT_SOURCE_MANIFEST_SHA256 is None
                 and RECEIPT_RAW_SHA256 == (), "partial unbound receipt configuration")
    #480 is a separate leaf authority. Preserve478 source/receipt endpoints;
    #only the final physical UI/ledger endpoint advances.
    import wealth_milestone_log_history as wealth
    with wealth.fresh_validation_proof(root) as successor:
        _require(successor["head"] == head
                 and all(current[p] == successor["before"][p] for p in CURRENT_UI_PATHS),
                 "wealth predecessor differs from immutable478 UI/ledger")
        wealth_before = dict(current)
        wealth_source = {**current, **{p: successor["source"][p] for p in CURRENT_UI_PATHS}}
        wealth_receipts = (None if successor["receipts"] is None else
                           {**current, **{p: successor["receipts"][p] for p in CURRENT_UI_PATHS}})
        wealth.ui_comparison({p: wealth_source[p] for p in CURRENT_UI_PATHS},
                             {p: current[p] for p in CURRENT_UI_PATHS},
                             {p: wealth_source[p] for p in CURRENT_UI_PATHS})
        if wealth_receipts is not None:
            wealth.ui_comparison({p: wealth_receipts[p] for p in CURRENT_UI_PATHS},
                                 {p: wealth_source[p] for p in CURRENT_UI_PATHS},
                                 {p: wealth_receipts[p] for p in CURRENT_UI_PATHS})
        current = wealth_source if wealth_receipts is None else wealth_receipts
    actual, _ = _snapshot(root, head, PATHS)
    _require(actual == current and all(_disk_bytes(root / p) == raw for p, raw in actual.items()),
             "actual current Git/disk differs")
    _require(_git(root, "rev-parse", "--verify", "HEAD^{commit}").decode().strip() == head
             and _disk_bytes(module) == module_raw and _configuration() == binding,
             "HEAD/module/function/config changed during proof")
    return {"root": root, "head": head, "before": before, "source": source, "receipts": receipts,
            "current": actual, "binding": binding, "module_raw": module_raw,
            "wealth_before": wealth_before, "wealth_source": wealth_source,
            "wealth_receipts": wealth_receipts}


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


def market_cycle_predecessor(actual_raw, root=ROOT):
    with fresh_validation_proof(root) as proof:
        _require(type(actual_raw) is bytes and actual_raw == proof["current"][INVESTMENT_PATH],
                 "actual Investment raw required")
        return proof["before"][INVESTMENT_PATH]


def source_predecessor_inventory(root, inventory):
    with fresh_validation_proof(root) as proof:
        hashes = inventory["source_hashes"]
        _require(type(hashes) is dict and _digest(hashes) == inventory["source_manifest_sha256"]
                 and hashes.get(INVESTMENT_PATH) == _sha(proof["current"][INVESTMENT_PATH]), "actual source census")
        actual, _ = _snapshot(root, proof["head"], tuple(hashes))
        _require({p: _sha(raw) for p, raw in actual.items()} == hashes
                 and all(_disk_bytes(Path(root) / p) == raw for p, raw in actual.items()), "whole actual census Git/disk")
        import wealth_milestone_log_history as wealth
        pre_wealth = wealth.source_predecessor_inventory(root, inventory)["source_hashes"]
        compared = {**pre_wealth, INVESTMENT_PATH: _sha(proof["before"][INVESTMENT_PATH])}
        parent, _ = _snapshot(root, PRODUCT_PARENT, tuple(compared))
        _require({p: _sha(raw) for p, raw in parent.items()} == compared
                 and _digest(compared) == PREDECESSOR_SOURCE_MANIFEST_SHA256, "exact whole pre478 census")
        final, _ = _snapshot(root, proof["head"], tuple(hashes))
        _require(final == actual and all(_disk_bytes(Path(root) / p) == raw for p, raw in final.items()),
                 "whole census changed during comparison")
        return {**inventory, "source_hashes": compared, "source_manifest_sha256": _digest(compared)}


def ui_comparison(snapshot, before, after):
    """Pure exact four-raw inverse for PR31's existing history seam."""
    _require(type(snapshot) is dict and set(snapshot) == set(before) == set(after) == set(CURRENT_UI_PATHS)
             and snapshot == after and all(type(v) is bytes for v in snapshot.values()), "exact current four-raw comparison")
    if before[JA_PATH] != after[JA_PATH]:
        product_inverse(before[JA_PATH], after[JA_PATH], JA_PATH)
        _require(all(before[p] == after[p] for p in CURRENT_UI_PATHS if p != JA_PATH)
                 and _sha(before[LEDGER_PATH]) == SOURCE_LEDGER_SHA256
                 and all(_sha(before[p]) == sha for p, sha in PROTECTED_RAW_SHA256.items()),
                 "JA source stage changed another raw")
    else:
        _require(RECEIPT_COMMIT is not None and all(before[p] == after[p] for p in UI_PATHS)
                 and _sha(after[JA_PATH]) == RAW_SHA256[JA_PATH][1]
                 and all(_sha(after[p]) == sha for p, sha in PROTECTED_RAW_SHA256.items())
                 and (_sha(before[LEDGER_PATH]), _sha(after[LEDGER_PATH])) == RECEIPT_RAW_SHA256,
                 "exact bound receipt comparison")
        _ledger_inverse(before[LEDGER_PATH], after[LEDGER_PATH])
    return dict(before)


def ui_predecessor(snapshot, root=ROOT):
    """Actual four-raw only -> pre478 comparison copy, never runtime values."""
    with fresh_validation_proof(root) as proof:
        current = {p: proof["current"][p] for p in CURRENT_UI_PATHS}
        _require(type(snapshot) is dict and set(snapshot) == set(CURRENT_UI_PATHS)
                 and all(type(v) is bytes for v in snapshot.values()) and snapshot == current,
                 "actual current four-raw identity required")
        return {p: proof["before"][p] for p in CURRENT_UI_PATHS}
