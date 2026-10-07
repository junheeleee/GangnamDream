"""Exact source-only retirement successor; never a translation receipt.

The seven-file product commit changes routing/classification only. Current
admission requires immutable Git objects and unchanged disk bytes. Historical
views restore only this exact transition, preserving the PR31 e300 census.
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
PRODUCT_PARENT = "9766e70a8652c0c82e07176468542af831b3b644"
PRODUCT_COMMIT = "589a0f60eb29069c68628a39134ea1e68de4e3e0"
MAIN_PATH = "scenes/MainGame.gd"
LIFECYCLE_PATH = "content/meta/event_lifecycle.json"
INVENTORY_PATH = "content/meta/release_content_inventory.json"
DIRECTOR_PATH = "content/meta/event_director.json"
SPINE_PATH = "content/meta/narrative_spine.json"
EXPOSED_PATH = "content/meta/exposed_event_state_contracts.json"
RATING_PATH = "docs/CONTENT_RATING_INVENTORY.md"
PRODUCT_PATHS = (MAIN_PATH, LIFECYCLE_PATH, INVENTORY_PATH, DIRECTOR_PATH,
                 SPINE_PATH, EXPOSED_PATH, RATING_PATH)
SOURCE_PATHS = (MAIN_PATH, LIFECYCLE_PATH, SPINE_PATH)
RETIRED_IDS = (
    "arc_y4_three_promises_jiyeon_and_deal", "arc_y4_body_witness_jiyeon",
    "arc_y4_family_partner_collision_jiyeon", "arc_y4_borrowed_name_jiyeon",
    "arc_y4_bill_night_jiyeon", "arc_y4_year_close_jiyeon",
)
PR31_SOURCE_MANIFEST_SHA256 = "e3005b54d6887c0d819b08c90d30496d32711b4b27dd3ccec15fc9e6dd3a954b"
# Actual direct-parent raw pairs are sealed after the source-only product.
RAW_SHA256 = {
    DIRECTOR_PATH: ("1603fd84db3f6f64535235e685b4ae3dcedda17a01ee8a6c059b1bde292b2891", "6ee296049bae8d6dc7aa2b8784208da4a933aaed33b12d1cdde554d796a3586b"),
    LIFECYCLE_PATH: ("db144848c87cd2d921cc6d27b3e57f7479e9a2567264322d8886dc140a929aa2", "ffd632a812694674388f2191037682aafcc0d220f52ee09cd63cdddd3867a384"),
    EXPOSED_PATH: ("6fa54d253192172aa3eadbcf2c8016a03bd2b721940319e0f6324345b813cf88", "0170af8978acb66c2d793f4dd4552cddd98ec1f44770963f9147cfca187be882"),
    SPINE_PATH: ("6ca02bab7dc3c39ae3a44cd89aafefd1d2d45e2b6cda479fa811678bc1f76a84", "f8f87cfd809d954bc00e19c273866e978669540ad0f7c86f3b0a7eaca7df947c"),
    INVENTORY_PATH: ("0b1c8e86fbb8aa223a89bf9773ff5cdb94d1a3e48e64ecf1a677721ffc65e965", "265dee057cf31eba566362c2003da98b229e3c93e15a631580f21d4a2d5e9694"),
    RATING_PATH: ("85fb1e5c1d868b5b48bd5f750402e850d7485c3961eec196ed72682894e89ea2", "f7d43ddb4e7b6dc10d5462f7601a9b71bf1578c9aa5101802e384756f6e0a7d1"),
    MAIN_PATH: ("83a0c10c2c5878d13afd511c5ebc494dc570380617aedf1dc86151d00ed932e4", "95ccd483779f7a2431f04b650b2c44dbfec8ca06fafb8ef5e7f930eaf65f7751"),
}
_ACTIVE = contextvars.ContextVar("order469_source_proof", default=None)

# A separate source-only Main successor. The seven-file retirement and its
# immutable before/after dictionaries retain their original meaning.
FIRST_LOSS_PARENT = "53b885d66af93532b5c5a3117795be16cbe7e288"
FIRST_LOSS_COMMIT = "54bda08d1c0ec1472b3cf1805703f84e1f533428"
FIRST_LOSS_RAW_SHA256 = ("95ccd483779f7a2431f04b650b2c44dbfec8ca06fafb8ef5e7f930eaf65f7751",
                         "c04f986d7fca16fa1e1023dc90801af373398ce4e94b3baca35ee19e2350bff1")
FIRST_LOSS_PREDECESSOR_CENSUS = "90d88b6fe55939264625f49a36bfdc8ff7d10f93c7cd53b85a394f20f911cc05"
FIRST_LOSS_OLD_LINE = b"\t\t\tand GameState.investment_skill >= 5 \\\n"
FIRST_LOSS_NEW_LINE = b"\t\t\tand GameState.investment_skill >= 5 and _has_current_investment_loss() \\\n"
FIRST_LOSS_APPEND = b'''
func _has_current_investment_loss() -> bool:
\t# Read the live holding and quote only; experience or an old loss is not enough.
\tfor asset_id in GameState.portfolio:
\t\tif DataRegistry.get_asset(asset_id).is_empty():
\t\t\tcontinue
\t\tvar holding: Variant = GameState.portfolio[asset_id]
\t\tif not holding is Dictionary or not GameState.market_prices.has(asset_id):
\t\t\tcontinue
\t\tvar quantity: Variant = holding.get("quantity", null)
\t\tvar average: Variant = holding.get("avg_price", null)
\t\tvar price: Variant = GameState.market_prices[asset_id]
\t\tvar valid := true
\t\tfor value in [quantity, average, price]:
\t\t\tif (typeof(value) != TYPE_INT and typeof(value) != TYPE_FLOAT):
\t\t\t\tvalid = false
\t\t\t\tbreak
\t\t\tif not is_finite(float(value)) or float(value) <= 0.0:
\t\t\t\tvalid = false
\t\t\t\tbreak
\t\tif valid and float(price) < float(average):
\t\t\treturn true
\treturn false
'''


def _require(ok, message):
    if not ok:
        raise ValueError("ORDER-469: " + message)


def _sha(raw):
    return hashlib.sha256(raw).hexdigest()


def _disk_bytes(path):
    # Historical Path views are comparison inputs, not physical-disk evidence.
    with open(path, "rb") as handle:
        return handle.read()


def _configuration():
    return (PRODUCT_PARENT, PRODUCT_COMMIT, PRODUCT_PATHS, SOURCE_PATHS,
            copy.deepcopy(RAW_SHA256), RETIRED_IDS, PR31_SOURCE_MANIFEST_SHA256,
            FIRST_LOSS_PARENT, FIRST_LOSS_COMMIT, FIRST_LOSS_RAW_SHA256,
            FIRST_LOSS_PREDECESSOR_CENSUS, FIRST_LOSS_OLD_LINE,
            FIRST_LOSS_NEW_LINE, FIRST_LOSS_APPEND,
            tuple((fn, fn.__code__) for fn in (_git, _objects, _snapshot,
                  _disk_bytes, product_inverse, first_loss_inverse, _read_proof)))


def _digest(value):
    return _sha(json.dumps(value, ensure_ascii=False, sort_keys=True, separators=(",", ":")).encode())


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
    _require(re.fullmatch(r"[0-9a-f]{40}", revision) is not None, "unbound product revision")
    commit = _objects(root, [(revision, revision, "commit")])[0]
    headers = commit.split(b"\n\n", 1)[0].splitlines()
    trees = [row[5:].decode() for row in headers if row.startswith(b"tree ")]
    _require(len(trees) == 1, "exact commit tree")
    _objects(root, [(trees[0], trees[0], "tree")])
    entries = {}
    for record in _git(root, "ls-tree", "-r", "-z", trees[0], "--", *paths).split(b"\0"):
        if record:
            meta, path = record.split(b"\t", 1)
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
    return json.loads(raw, object_pairs_hook=pairs)


def _ordered(value):
    return json.dumps(value, ensure_ascii=False, separators=(",", ":"))


def _remove_ids(value):
    return [row for row in value if (row.get("id") if isinstance(row, dict) else row) not in RETIRED_IDS]


def product_inverse(before, after, path):
    """Require both raw pins and independently bounded semantic ownership."""
    _require(path in PRODUCT_PATHS and isinstance(before, bytes) and isinstance(after, bytes)
             and (_sha(before), _sha(after)) == RAW_SHA256.get(path), "unapproved raw pair: " + path)
    if path == MAIN_PATH:
        expected = before.replace(b"daeun_id: String, jiyeon_id: String, unattached_id: String",
                                  b"daeun_id: String, unattached_id: String", 1)
        old = b'\tif partner_id == "jiyeon":\n\t\treturn jiyeon_id\n'
        _require(expected.count(old) == 1, "exact selector branch")
        expected = expected.replace(old, b"", 1)
        for eid in RETIRED_IDS:
            old = ('\t\t\t"' + eid + '",\n').encode()
            _require(expected.count(old) == 1, "exact retired call " + eid)
            expected = expected.replace(old, b"", 1)
        _require(expected == after, "Main source exceeds selector and six arguments")
    elif path != RATING_PATH:
        old, new = _loads(before), _loads(after)
        expected = copy.deepcopy(old)
        if path == DIRECTOR_PATH:
            owners = expected["full_run_pacing"]["commitment_event_owners"]
            for week in ("153", "164", "167", "177", "181", "190"):
                rows = owners[week]
                owners[week] = _remove_ids(rows)
                _require(len(rows) - len(owners[week]) == 1, "one owner retired per slot")
        elif path == SPINE_PATH:
            chapters = [c for c in expected["chapters"] if c["number"] == 4]
            _require(len(chapters) == 1, "one Chapter4 spine")
            for key in ("setup", "escalation", "reversal", "boss"):
                chapters[0][key] = _remove_ids(chapters[0][key])
        elif path == LIFECYCLE_PATH:
            _require(not set(RETIRED_IDS) & set(old["author_only_event_ids"]), "already author-only")
            expected["author_only_event_ids"] = sorted([*old["author_only_event_ids"], *RETIRED_IDS])
            for key, delta in (("shipping_events", -6), ("author_only_events", 6),
                               ("ledger_only_author_only_events", 6)):
                expected["counts"][key] += delta
            for key in ("shipping_event_ids", "author_only_event_ids", "ledger_only_author_only_event_ids"):
                _require(re.fullmatch(r"[0-9a-f]{64}", new["sha256"][key]) is not None
                         and new["sha256"][key] != old["sha256"][key], "lifecycle hash delta")
                expected["sha256"][key] = new["sha256"][key]
        elif path == EXPOSED_PATH:
            for eid in RETIRED_IDS:
                expected["state_sensitive"].pop(eid)
            for key in ("root_count", "exposed_count"):
                expected["scope"][key] -= 6
            for key in ("root_ids_sha256", "exposed_ids_sha256"):
                _require(re.fullmatch(r"[0-9a-f]{64}", new["scope"][key]) is not None
                         and new["scope"][key] != old["scope"][key], "exposed hash delta")
                expected["scope"][key] = new["scope"][key]
        elif path == INVENTORY_PATH:
            for key, delta in (("shipping_ko_events", -6), ("shipping_en_events", -6), ("author_only_events", 6)):
                expected["corpus_contract"][key] += delta
            for key in ("shipping_event_ids_sha256", "author_only_event_ids_sha256"):
                _require(re.fullmatch(r"[0-9a-f]{64}", new["corpus_contract"][key]) is not None
                         and new["corpus_contract"][key] != old["corpus_contract"][key], "inventory hash delta")
                expected["corpus_contract"][key] = new["corpus_contract"][key]
            # Exact reachable tobacco example; packaged candidate scans remain.
            found = 0
            def remove_example(value):
                nonlocal found
                if isinstance(value, dict):
                    if value.get("id") == "tobacco_and_medicine_references":
                        _require(RETIRED_IDS[0] in value["event_ids"], "tobacco example missing")
                        value["event_ids"].remove(RETIRED_IDS[0])
                        found += 1
                    for child in value.values():
                        remove_example(child)
                elif isinstance(value, list):
                    for child in value:
                        remove_example(child)
            remove_example(expected)
            _require(found == 1, "one reachable tobacco example")
        _require(_ordered(expected) == _ordered(new), "metadata exceeds six-event retirement: " + path)
    return before


def first_loss_inverse(before, after, path=MAIN_PATH):
    """Exact one-line ingress plus the UI-free EOF predicate; comparison only."""
    _require(path == MAIN_PATH and type(before) is bytes and type(after) is bytes
             and (_sha(before), _sha(after)) == FIRST_LOSS_RAW_SHA256,
             "first-loss unapproved raw pair/path")
    _require(before.count(FIRST_LOSS_OLD_LINE) == 1
             and FIRST_LOSS_NEW_LINE not in before and FIRST_LOSS_APPEND not in before
             and after.count(FIRST_LOSS_NEW_LINE) == 1
             and after.count(FIRST_LOSS_APPEND) == 1 and after.endswith(FIRST_LOSS_APPEND)
             and before.replace(FIRST_LOSS_OLD_LINE, FIRST_LOSS_NEW_LINE, 1)
                 + FIRST_LOSS_APPEND == after,
             "first-loss changes outside the exact ingress and EOF predicate")
    return before


def _read_proof(root):
    root = Path(root).resolve()
    module = Path(__file__).resolve()
    _require(module == root / "tools/order469_source_compat.py", "source proof module/root identity")
    module_raw, configuration = _disk_bytes(module), _configuration()
    head = _git(root, "rev-parse", "--verify", "HEAD^{commit}").decode().strip()
    before, _ = _snapshot(root, PRODUCT_PARENT, PRODUCT_PATHS)
    after, headers = _snapshot(root, PRODUCT_COMMIT, PRODUCT_PATHS)
    _require([h[7:].decode() for h in headers if h.startswith(b"parent ")] == [PRODUCT_PARENT],
             "exact product parent")
    expected = b"".join(b"M\0" + p.encode() + b"\0" for p in sorted(PRODUCT_PATHS))
    _require(_git(root, "diff", "--name-status", "-z", PRODUCT_PARENT, PRODUCT_COMMIT) == expected,
             "exact seven modified paths")
    _git(root, "merge-base", "--is-ancestor", PRODUCT_COMMIT, head)
    _require(set(RAW_SHA256) == set(PRODUCT_PATHS), "complete raw pin population")
    for path in PRODUCT_PATHS:
        product_inverse(before[path], after[path], path)
    loss_before, _ = _snapshot(root, FIRST_LOSS_PARENT, (MAIN_PATH,))
    loss_after, loss_headers = _snapshot(root, FIRST_LOSS_COMMIT, (MAIN_PATH,))
    _require([h[7:].decode() for h in loss_headers if h.startswith(b"parent ")] == [FIRST_LOSS_PARENT],
             "first-loss exact direct parent")
    _require(_git(root, "diff", "--name-status", "-z", FIRST_LOSS_PARENT, FIRST_LOSS_COMMIT)
             == b"M\0" + MAIN_PATH.encode() + b"\0", "first-loss exact Main-only pathset")
    _git(root, "merge-base", "--is-ancestor", PRODUCT_COMMIT, FIRST_LOSS_PARENT)
    _git(root, "merge-base", "--is-ancestor", FIRST_LOSS_COMMIT, head)
    _require(first_loss_inverse(loss_before[MAIN_PATH], loss_after[MAIN_PATH]) == after[MAIN_PATH],
             "first-loss predecessor differs from immutable469 Main")
    actual, _ = _snapshot(root, head, PRODUCT_PATHS)
    import order470_source_compat as later
    with later.fresh_validation_proof(root) as successor:
        comparison = dict(actual)
        _require(actual[MAIN_PATH] == loss_after[MAIN_PATH], "first-loss current HEAD Main differs")
        comparison[MAIN_PATH] = first_loss_inverse(loss_before[MAIN_PATH], actual[MAIN_PATH])
        for path in set(PRODUCT_PATHS) & set(later.PRODUCT_PATHS):
            _require(actual[path] == successor["current"][path], "later actual product binding")
            comparison[path] = successor["before"][path]
    _require(comparison == after, "current HEAD product differs from exact source successors")
    _require(all(_disk_bytes(root / p) == raw for p, raw in actual.items()), "current disk differs from Git")
    _require(_git(root, "rev-parse", "--verify", "HEAD^{commit}").decode().strip() == head
             and _disk_bytes(module) == module_raw and _configuration() == configuration,
             "HEAD/module/configuration changed during source proof")
    return {"root": root, "head": head, "before": before, "after": after, "current": actual,
            "first_loss_before": loss_before, "first_loss_after": loss_after,
            "binding": configuration, "module_raw": module_raw}


@contextlib.contextmanager
def fresh_validation_proof(root=ROOT):
    active = _ACTIVE.get()
    if active is not None:
        _require(Path(root).resolve() == active["root"], "nested proof changed repository")
        _require(_read_proof(root) == active, "nested proof Git/disk/binding changed")
        yield active
        _require(_read_proof(root) == active, "nested proof changed during use")
        return
    proof = _read_proof(root)
    token = _ACTIVE.set(proof)
    try:
        yield proof
        _require(_read_proof(root) == proof, "Git, disk or product binding changed inside proof")
    finally:
        _ACTIVE.reset(token)


def main_predecessor(raw, root=ROOT):
    with fresh_validation_proof(root) as proof:
        _require(type(raw) is bytes and raw == proof["current"][MAIN_PATH], "current Main raw differs")
        return proof["before"][MAIN_PATH]


def first_loss_predecessor(raw, root=ROOT):
    """Actual476 -> immutable post469 Main, never a runtime source replacement."""
    with fresh_validation_proof(root) as proof:
        _require(type(raw) is bytes and raw == proof["current"][MAIN_PATH], "first-loss actual Main raw differs")
        return proof["first_loss_before"][MAIN_PATH]


def source_predecessor_inventory(root, inventory):
    """Full actual current census -> immutable PR31 census; no new receipts."""
    with fresh_validation_proof(root) as proof:
        import order470_source_compat as later
        import market_cycle_label_history as market
        actual_hashes = inventory["source_hashes"]
        _require(type(actual_hashes) is dict and _digest(actual_hashes) == inventory["source_manifest_sha256"]
                 and actual_hashes.get(MAIN_PATH) == _sha(proof["current"][MAIN_PATH]), "current census digest/Main")
        # Prove the entire real population before projecting one comparison
        # hash. Passing a historical census to470's current API would be false.
        actual, _ = _snapshot(root, proof["head"], tuple(actual_hashes))
        _require({p: _sha(raw) for p, raw in actual.items()} == actual_hashes
                 and all(_disk_bytes(Path(root) / p) == raw for p, raw in actual.items()),
                 "complete current Git/disk source binding")
        with later.fresh_validation_proof(root) as successor:
            #477 changes one Korean source, not Main. Prove/project that exact
            #whole parent first, then retain476's original immutable90d88 seam.
            #478 owns only Investment in the source census. Restore it before
            #477's KO and476's Main; keep the supplied runtime inventory actual.
            market_view = market.source_predecessor_inventory(root, inventory)
            hashes = later._loss_hold_source_comparison(root, successor, market_view["source_hashes"])
            hashes = {**hashes, MAIN_PATH: _sha(proof["first_loss_before"][MAIN_PATH])}
            parent, _ = _snapshot(root, FIRST_LOSS_PARENT, tuple(hashes))
            _require({p: _sha(raw) for p, raw in parent.items()} == hashes
                     and _digest(hashes) == FIRST_LOSS_PREDECESSOR_CENSUS,
                     "first-loss exact whole predecessor census")
            _require(all(hashes.get(p) == _sha(successor["wealth_before"][p]) for p in later.SOURCE_PATHS),
                     "proved pre480 source binding before historical470 comparisons")
            # Reuse470's unchanged, pinned comparison sequence only; no new
            # Main ownership, bypass flag, or current-input exception there.
            for compare in (later._night_source_comparison, later._first_win_source_comparison,
                            later._ending_source_comparison, later._prose_source_comparison,
                            later._person_source_comparison):
                hashes = compare(root, successor, hashes)
            hashes = {**hashes, **{p: _sha(successor["before"][p]) for p in later.SOURCE_PATHS}}
            _require(_digest(hashes) == later.PREDECESSOR_SOURCE_MANIFEST_SHA256,
                     "exact pre470 complete source census")
        _require(all(hashes.get(path) == _sha(proof["after"][path]) for path in SOURCE_PATHS),
                 "current census source-only raw binding")
        comparison = {**hashes, **{path: _sha(proof["before"][path]) for path in SOURCE_PATHS}}
        _require(_digest(comparison) == PR31_SOURCE_MANIFEST_SHA256, "exact PR31 predecessor census")
        final, _ = _snapshot(root, proof["head"], tuple(actual_hashes))
        _require(final == actual and all(_disk_bytes(Path(root) / p) == raw for p, raw in actual.items()),
                 "complete current source changed during comparison")
        return {**inventory, "source_hashes": comparison, "source_manifest_sha256": _digest(comparison)}
