"""Exact PR31 intake, separate current admission and historical comparisons.

Only the pinned, reviewed product transition is admitted. Old 351/350/313/309
modules, their immutable objects and their original corpora remain untouched.
The old prose returned here is comparison-only, never a current inventory.
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

import order351_source_compat as previous
import order469_source_compat as source_successor
import order470_source_compat as fact_successor
import market_cycle_label_history as market_successor
import wealth_milestone_log_history as wealth_successor

ROOT = Path(__file__).resolve().parents[1]
INTAKE_PARENT = "8a2c9a9e5cc61c05c9f58b238d59bbbe7a3ce39b"
INTAKE_COMMIT = "4b2679239bb76fdc7963f47ee25a505820efcca7"
PR_COMMIT = "b9284e3d28116c93e441e12c346fe15ee2f69fef"
MERGE_BASE = "366e0e621e266eeb1d260b9b614af8a92b38027d"
REPAIR_COMMIT = "db4de2f3ebbc87f60d6877fde0af4d23fbe27757"
# Actual official export/check/import rows, each correcting eight existing
# accepted leaves without changing the already-reviewed localized prose.
REPAIR_BATCH_SHA256 = {
    "ja": "f006e2fc1f836edd7a173da44af3f252d442ff9378a5e560fda0c2ab0b1af4f9",
    "zh-CN": "beb3267f1a5d366898f2c6978b4ff003849069b93c416e12a65ce8cef90f622c",
    "zh-TW": "3373439863962a650c6c1afe1bda3e07c689d123a52fcdbdaeba9ec754039726",
}
SECOND_COMMIT = "134a45baa932e20c093262165a5c6599ff1625ed"
SECOND_BATCH_SHA256 = {
    "ja": "68ef2d15541a5f1295c8b2b0e84bbb892027ac21706c01c85994509f005dfa01",
    "zh-CN": "ef583b9771e431c26bed6efac7bfe767b3a886813cb6e73de6c054045e975f6c",
    "zh-TW": "c403cd7ce000128ce985b47f25b47ca1182fa984faa732a7d7c23de6398d4fd2",
}
SECOND_IDS = (
    "events:arc_minseo_03_arrival:/description_if_known/contacted_minseo",
    "events:arc_jiyeon_wedding_gap_father_passed:/choices/1/result_text",
    "events:arc_year4_close_father_passed:/choices/1/result_text",
)
SECOND_SENTENCES = {
    "ja": ("小さな空欄から、屋上の床の灰色が見えた。", "紙一枚にすべて収まった。"),
    "zh-CN": ("从小小的空格间，能看见天台地面的灰色。", "全都写在一张纸上了。"),
    "zh-TW": ("從小小的空格間，看得見屋頂地面的灰色。", "全都寫在一張紙上了。"),
}
# The third correction separates authored KO/EN/target prose from the later
# official receipt import. Pins are filled only from those actual commits.
THIRD_SOURCE_COMMIT = "24d02ae8d7a8e357002b8103129b8bf22dd6a2ea"
THIRD_LEDGER_COMMIT = "b41adeca25132f25daac6c9be76a22e614304c0d"
FOURTH_COMMIT = "1b9bd164c501cad44ab061ba12d2a32b12db39ef"
FOURTH_BATCH_SHA256 = {
    "ja": "f1302879d8c0bbfd6a74aae123e4d13c7044ffef7a4714b556e57b76e5dd70b3",
    "zh-CN": "ff8fff1a0455e6e5ffebe8c4201cd4169e95459ee52d7ae52bd965915c1f0e61",
    "zh-TW": "5544ca22f2ec04af247062c2d9c30ef5b2032c09511d8786a9a985d3fce9cb74",
}
FOURTH_IDS = (
    "events:arc_minseo_03_arrival:/description_if_known/minseo_real_talk",
    "events:arc_minseo_03_arrival:/description_if_known/contacted_minseo&minseo_real_talk",
)
THIRD_PRODUCT_SHA256 = {
    "content/endings.json": (
        "25f1e5b7f3236454e19ceb452274a61737f098198d07598c7c36d5a69d7cae77",
        "92fdbd1767de9b389e8a6416c9fba7f84260cf874e4f27d4f7ebcf964ab7e9a5"),
    "content/endings_en.json": (
        "34f9ed752d9d160bf51416a3ae6849e6a2d4a3ad94ce73f52e6014b30d5453d4",
        "8f9eb23d08089e8ca90fc80b22fdccfc70caf4374b519b362b97da986a4330d8"),
    "content/endings_ja.json": (
        "3701abfa421c9b601b2eb9c5bf597f7a902f1e26d1a512704e6312efe7e7e41b",
        "de27f165baefc6585a1125e85e5e402ce7bb612c23f1508cba075fcbacdb2ae7"),
    "content/endings_zh-CN.json": (
        "c4fc187548d582c2768af288b8af422dc002d33af7a5ca7236a02bcb6886298f",
        "ca31a4300b1811f9799d4d93096483ad0ca0d62d921f5ad775c94a7c1b274898"),
    "content/endings_zh-TW.json": (
        "7055428cd8247a086412a8b3e5d1a0417241035ea0ab5997da6dc6d37dcb5ad0",
        "511d191b67d1252aa306bc71acc53a6c47a97a725cc6cab072548bc98f86f546"),
    "content/events/arc_daeun_married.json": (
        "f935ae2990f34964cf130c9a7a08cc18b95ef862abfd255f824456d7b196d6c9",
        "2da9d8190ba2efc04258f944e8b65c6d8bbc1983929acca2f866ae054a284d59"),
    "content/events/arc_year3_drama.json": (
        "db8d0f8c95db610d4ff2a7c7f89610c7f8a6a342513580aa1bc3d71bd958075f",
        "df143e94f0997f47f92e027e5ee42d5c742f4e6e64db1486cc6bedf01cdccf30"),
    "content/events_en/arc_daeun_married.json": (
        "be62e408358861cad4ea0270fc6da8604372191e8cbe7a8ba7fdb44b78891a1a",
        "366af0764c0a46ae545bf645b8015b4df2ecf57e8d8c0e183a4892d5ef7e43c5"),
    "content/events_en/arc_year3_drama.json": (
        "52465fa76b2540072d3788f11a9504accc6a482eff6e70fac7b990dfbca426ff",
        "854eec5882ceb9659e62314f291d1abc0dd7655dff9e9c14de972e1b58aeae13"),
    "content/events_ja/arc_daeun_married.json": (
        "191c0419812e1b9a3189adeae75e2faaace056d1af7cb03c48d767b795500eb7",
        "f8c7af2d815f6016f67534bf33c066162756e177ee9e7813beee1e05dbef6d69"),
    "content/events_ja/arc_year3_drama.json": (
        "8e469bf866c29df08c704ed3130a8bd4462d681817f59b81f5934081ea506ffb",
        "81465a04d7904f3da09a2a516fb73b2ef48031983fd7eda5ed7c1fb2948a6781"),
    "content/events_zh-CN/arc_daeun_married.json": (
        "485b6de2eebe8d572501aedaa289790bbde247a8e6a5d32b15d6cea8d3b872ed",
        "d078c1c388231d5194b49866dcf05a7b8b26fbbef956b669d11fe24c7fdb99a7"),
    "content/events_zh-CN/arc_year3_drama.json": (
        "d1fbe3c5af4a13a7e7addae6d2f2f8251ee85e69abecef9013a56a2bae67f633",
        "e0596274a3d127ef4521a512266a98083bb5bceba35d5488165c57b220dfcdd7"),
    "content/events_zh-TW/arc_daeun_married.json": (
        "2aeb852be8fc7bd1d6494ef30bce674cd9fdcc3d4a62b2bf51bea7a900b26114",
        "c609a07f1ceb99002347d47786b22c293ac4076897ff699fd4f9541a18a3bdad"),
    "content/events_zh-TW/arc_year3_drama.json": (
        "0eabfab2435f145a1b9bf157e275b0b3a527107cc7674ceb7feb69d5fd530132",
        "75d5dfa962e3f53fd30d764ac3a2ef7c073a989ee04c05eb8d79edf34abdb054"),
    "content/meta/release_content_inventory.json": (
        "3ff3828edbd8146cbcf3d24e7ad8850945db8603f71b80f664c975dbabfb1e6b",
        "0b1c8e86fbb8aa223a89bf9773ff5cdb94d1a3e48e64ecf1a677721ffc65e965"),
    "docs/CONTENT_RATING_INVENTORY.md": (
        "d1fba997c2b7543954e1eedeb0022d841882ce6e758ca1a615cf6c206339ea6f",
        "85fb1e5c1d868b5b48bd5f750402e850d7485c3961eec196ed72682894e89ea2"),
}
THIRD_BATCH_SHA256 = {
    ("events", "ja"): "bfe4ea41e831a07d35336e014c1f0025f8e3a2c82dd7a0dcd1c086e83f7e9c58",
    ("endings", "ja"): "3b0859c333f0948efbd361681d026a47f23a5a8092310ba2311f60de3f9beb2a",
    ("events", "zh-CN"): "1eafa957b02f2a4e01cba027153e722e1975909f89a5592bd05761ca219cd279",
    ("endings", "zh-CN"): "cece368555640d2e967ece60eea3c5c0ee2300418de94c87b3153df276b5d209",
    ("events", "zh-TW"): "5c7060f11fd6b5b4d91f6ff9800bcb626326007025abccc763f7abee77a45994",
    ("endings", "zh-TW"): "998f17f1ed6e13414405ac41633cc656fa2bf7b4d68c5d2ab4e4abe8ddcd1ca5",
}
# This digest binds the complete actual collector path/hash population, not
# just the fifteen changed Korean content files. It is the source census in
# all six pinned third-stage official headers (export revision 6a324be...).
CURRENT_SOURCE_MANIFEST_SHA256 = "e3005b54d6887c0d819b08c90d30496d32711b4b27dd3ccec15fc9e6dd3a954b"
THIRD_INVENTORY_FIELDS = frozenset({("corpus_contract", "ending_content_sha256")})
THIRD_EVENT_IDS = (
    "events:arc_daeun_final_choice:/description",
    "events:arc_daeun_final_choice:/description_if_known/namsan_lock_daeun",
    "events:arc_daeun_final_choice_kitchen:/description",
    "events:arc_jiyeon_year5_return:/choices/1/result_text",
)
THIRD_ENDING_IDS = (
    "endings:stable_success:/description",
    "endings:orthodox_pinnacle:/description",
    *("endings:orthodox_pinnacle:/description_if_known/" + name for name in (
        "salary_raised", "salary_denied", "credit_asserted", "credit_recognized",
        "jobswitch_reconnected", "declined_golf", "extreme_frugal", "frugal_quiet",
        "skipped_staycation", "ignored_mystery_info", "orthodox_wavered")),
    "endings:unorthodox_legend:/description",
    *("endings:unorthodox_legend:/description_if_known/" + name for name in (
        "cafe_double_jackpot", "coin_second_win", "holdem_high_stakes_win",
        "own_path_solidified", "investigating_gray_contact", "gray_tip_debt_paid")),
)
THIRD_IDS_BY_GROUP = {"events": THIRD_EVENT_IDS, "endings": THIRD_ENDING_IDS}
THIRD_CONTENT_PATHS = tuple(sorted(
    ["content/" + directory + "/" + name + ".json"
     for directory in ("events", "events_en", "events_ja", "events_zh-CN", "events_zh-TW")
     for name in ("arc_daeun_married", "arc_year3_drama")]
    + ["content/endings" + suffix + ".json" for suffix in ("", "_en", "_ja", "_zh-CN", "_zh-TW")]))
LEDGER_PATH = "content/meta/full_game_localization.json"
INVENTORY_PATH = "content/meta/release_content_inventory.json"
INVENTORY_RAW_SHA256 = (
    "f46041343731f5cd64b680f778cff9ee77ea0c67fe114536f27a557fe5c1ead0",
    "3ff3828edbd8146cbcf3d24e7ad8850945db8603f71b80f664c975dbabfb1e6b",
)
LOCALES = ("ja", "zh-CN", "zh-TW")
UI_PATHS = tuple("locale/ui_" + locale + ".json" for locale in LOCALES)
CURRENT_UI_PATHS = (*UI_PATHS, LEDGER_PATH)
SECOND_TARGET_PATHS = tuple("content/events_" + locale + "/arc_year_close.json" for locale in LOCALES)
_NAMES = ("arc_chapter_themes", "arc_daeun", "arc_daeun_extension", "arc_daeun_married",
          "arc_daeun_romance", "arc_drama", "arc_h2_beats", "arc_midgame",
          "arc_new_characters", "arc_pre_ending", "arc_web_crossbeams",
          "arc_year3_drama", "arc_year_close")
CONTENT_PATHS = tuple(sorted(
    ["content/" + directory + "/" + name + ".json"
     for directory in ("events", "events_en", "events_ja", "events_zh-CN", "events_zh-TW")
     for name in _NAMES]
    + ["content/events/arc_jiyeon_married.json"]
    + ["content/endings" + suffix + ".json" for suffix in ("", "_en", "_ja", "_zh-CN", "_zh-TW")]))
SOURCE_PATHS = tuple(path for path in CONTENT_PATHS
                     if path.startswith("content/events/") or path == "content/endings.json")
ENDING_PATHS = tuple(path for path in CONTENT_PATHS if path.startswith("content/endings"))
HISTORY_CONTENT_PATHS = tuple(path for path in CONTENT_PATHS
                             if path.startswith(("content/events/", "content/events_en/")))
PRODUCT_PATHS = (*CONTENT_PATHS, LEDGER_PATH, INVENTORY_PATH, "docs/CONTENT_RATING_INVENTORY.md")
PROTECTED_PATHS = (*UI_PATHS, "scenes/MainGame.gd", "project.godot", "docs/human_gates.json",
                   *("content/events_" + locale + "/arc_jiyeon_married.json" for locale in LOCALES),
                   *("content/" + directory + "/arc_events.json" for directory in
                     ("events", "events_en", "events_ja", "events_zh-CN", "events_zh-TW")))
REPAIR_IDS = (
    "events:arc_father_legacy:/description",
    "events:arc_father_legacy:/description_memory_if_known/chapter5_general_debt_memory_reconnect_0",
    "events:arc_father_legacy:/description_memory_if_known/chapter5_general_debt_memory_reconnect_1",
    "events:arc_minseo_03_arrival:/description",
    "events:arc_y5_general_name_boundary_exact:/description",
    "events:arc_y5_general_debt_memory_reconnect:/description",
    "events:arc_y5_general_debt_memory_reconnect:/choices/0/result_text",
    "events:arc_y5_final_father_answer_alive:/description",
)
_ACTIVE = contextvars.ContextVar("pr31_intake_proof", default=None)
_Document = previous._Document
_loads = previous._loads
_ordered = previous._ordered
CURRENT_HISTORY_PATHS = tuple(dict.fromkeys((*HISTORY_CONTENT_PATHS, *fact_successor.PROSE_PRODUCT_PATHS)))
HISTORICAL_PATHS = tuple(dict.fromkeys((*previous.HISTORICAL_PATHS, *CURRENT_HISTORY_PATHS)))
CURRENT_CONTENT_PATHS = tuple(dict.fromkeys((*CONTENT_PATHS, *fact_successor.ARC_PATHS,
                                            *fact_successor.PROSE_PATHS)))


def _sha(raw):
    return hashlib.sha256(raw).hexdigest()


def _digest(value):
    return _sha(json.dumps(value, ensure_ascii=False, sort_keys=True, separators=(",", ":")).encode())


def _require(ok, detail):
    if not ok:
        raise ValueError("PR31 intake: " + detail)


def _git(root, *args, input=None):
    result = subprocess.run(("git", "--no-replace-objects", *args), cwd=root,
                            input=input, capture_output=True, timeout=30)
    _require(result.returncode == 0, "Git proof unavailable: " + " ".join(args))
    return result.stdout


def _objects(root, requests):
    """Fresh typed/hash-checked objects; no success persists across invocations."""
    output = _git(root, "cat-file", "--batch", input="".join(row[0] + "\n" for row in requests).encode())
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
    """Object membership is bound to a verified immutable commit/tree."""
    _require(re.fullmatch(r"[0-9a-f]{40}", revision) is not None, "unbound product revision")
    commit = _objects(root, [(revision, revision, "commit")])[0]
    headers = commit.split(b"\n\n", 1)[0].splitlines()
    trees = [line[5:].decode() for line in headers if line.startswith(b"tree ")]
    _require(len(trees) == 1 and re.fullmatch(r"[0-9a-f]{40}", trees[0]) is not None, "commit tree")
    _objects(root, [(trees[0], trees[0], "tree")])
    entries = {}
    for record in _git(root, "ls-tree", "-r", "-z", trees[0], "--", *paths).split(b"\0"):
        if record:
            meta, path = record.split(b"\t", 1)
            mode, kind, oid = meta.decode().split()
            _require(mode == "100644" and kind == "blob", "source mode/type " + path.decode())
            entries[path.decode()] = oid
    _require(set(entries) == set(paths), "exact snapshot path population")
    requests = [(revision + ":" + path, entries[path], "blob") for path in paths]
    return dict(zip(paths, _objects(root, requests))), headers


def _changes(before, after, path=()):
    if type(before) is not type(after):
        yield path, before, after
    elif isinstance(before, dict):
        for key in dict.fromkeys((*before, *after)):
            if key not in before or key not in after:
                yield path + (key,), before.get(key), after.get(key)
            else:
                yield from _changes(before[key], after[key], path + (key,))
    elif isinstance(before, list):
        if len(before) != len(after):
            yield path, before, after
        else:
            for index, (old, new) in enumerate(zip(before, after)):
                yield from _changes(old, new, path + (index,))
    elif before != after:
        yield path, before, after


def _rows(raw):
    rows = _loads(raw)
    _require(isinstance(rows, list) and all(isinstance(row, dict) and isinstance(row.get("id"), str)
                                         for row in rows), "ID-array source shape")
    result = {row["id"]: row for row in rows}
    _require(len(result) == len(rows), "duplicate source ID")
    return result


def _validate_content(before, after):
    """The pinned PR can change prose/variant keys, never gameplay values."""
    changed = {}
    fields = {"title", "description", "description_if_known", "description_if_moral",
              "description_memory_if_known", "description_if_partner", "description_if_flag",
              "condition", "choices"}
    for path in CONTENT_PATHS:
        old, new = _rows(before[path]), _rows(after[path])
        _require(list(old) == list(new), "event/ending identity or order changed: " + path)
        selectors = []
        for eid in old:
            for key, a, b in _changes(old[eid], new[eid]):
                _require(key and key[0] in fields, "gameplay field changed: " + path + "#" + eid + repr(key))
                if key[0] == "choices":
                    _require(len(key) >= 3 and key[2] in {"text", "result_text", "result_text_if_known",
                             "result_text_if_moral", "result_text_if_partner", "result_text_memory_if_known"},
                             "choice gameplay changed: " + path + "#" + eid + repr(key))
                _require((isinstance(a, str) or a is None) and (isinstance(b, str) or b is None),
                         "non-text content delta: " + path + "#" + eid + repr(key))
                selectors.append((eid, key))
        _require(bool(selectors), "registered content file has no semantic change: " + path)
        changed[path] = tuple(selectors)
    return changed


def _ledger_union(base_raw, main_raw, branch_raw, merged_raw):
    base, main, branch, merged = map(_loads, (base_raw, main_raw, branch_raw, merged_raw))
    expected = copy.deepcopy(main)
    for locale in LOCALES:
        a, b, c = (doc["accepted"][locale] for doc in (base, main, branch))
        _require(set(a) <= set(b) and set(a) <= set(c), "accepted receipt deletion")
        for key, value in c.items():
            if key in a and value == a[key]:
                continue
            _require(key not in b or key in a and b[key] == a[key] or b[key] == value,
                     "unresolved three-way receipt conflict: " + locale + ":" + key)
            expected["accepted"][locale][key] = value
    _require(base["batches"] == branch["batches"] and main["batches"][:len(base["batches"])] == base["batches"],
             "branch batch history is not preserved")
    for key in branch:
        if key not in {"accepted", "accepted_sha256"}:
            _require(branch[key] == base[key], "unowned branch ledger metadata: " + key)
    expected["accepted_sha256"] = _digest(expected["accepted"])
    _require(_ordered(merged) == _ordered(expected), "merged ledger is not the exact ordered three-way union")
    _require(sum(map(len, merged["accepted"].values())) == 41830 and len(merged["batches"]) == 237,
             "intake accepted/batch census differs")
    return expected


def inventory_inverse(before, after):
    _require(isinstance(before, bytes) and isinstance(after, bytes)
             and (_sha(before), _sha(after)) == INVENTORY_RAW_SHA256,
             "inventory raw pair is not the reviewed immutable transition")
    old, new = _Document(before), _Document(after)
    allowed = {("corpus_contract", "ending_content_sha256")}
    ids = [row["id"] for row in old.value["content_axes"]]
    _require(ids == [row["id"] for row in new.value["content_axes"]], "inventory axis identity/order")
    for axis in ("gambling", "sexuality", "violence", "fear", "alcohol_tobacco_drugs"):
        allowed.add(("content_axes", ids.index(axis), "candidate_scan", "expected_content_sha256"))
    for axis in ("violence", "fear"):
        for field in ("expected_event_count", "expected_ids_sha256"):
            allowed.add(("content_axes", ids.index(axis), "candidate_scan", field))
    for field in ("expected_file_count", "reviewed_search_noise_ids"):
        allowed.add(("content_axes", ids.index("violence"), "candidate_scan", field))
    changes = list(_changes(old.value, new.value))
    _require({path for path, _, _ in changes} == allowed, "inventory exact reviewed field population")
    text = new.text
    replacements = []
    for path, _, _ in changes:
        a, z = old.spans[path]
        p, q = new.spans[path]
        replacements.append((p, q, old.text[a:z]))
    for p, q, literal in sorted(replacements, reverse=True):
        text = text[:p] + literal + text[q:]
    _require(text.encode() == before, "inventory bytes outside reviewed fields changed")
    return before


def _read_proof(root=ROOT):
    root = Path(root)
    head = _git(root, "rev-parse", "--verify", "HEAD^{commit}").decode().strip()
    paths = tuple(dict.fromkeys((*PRODUCT_PATHS, *PROTECTED_PATHS, *fact_successor.PROSE_PATHS)))
    before, _ = _snapshot(root, INTAKE_PARENT, paths)
    after, headers = _snapshot(root, INTAKE_COMMIT, paths)
    branch, _ = _snapshot(root, PR_COMMIT, paths)
    base, _ = _snapshot(root, MERGE_BASE, (LEDGER_PATH,))
    parents = [line[7:].decode() for line in headers if line.startswith(b"parent ")]
    _require(parents == [INTAKE_PARENT, PR_COMMIT], "exact merge parents")
    _require(_git(root, "merge-base", INTAKE_PARENT, PR_COMMIT).decode().strip() == MERGE_BASE, "merge base differs")
    _git(root, "merge-base", "--is-ancestor", INTAKE_COMMIT, head)
    changed_paths = _git(root, "diff", "--name-only", "-z", INTAKE_PARENT, INTAKE_COMMIT, "--", "content", "scenes", "project.godot").split(b"\0")
    expected_paths = sorted(path for path in PRODUCT_PATHS if path.startswith("content/"))
    _require(changed_paths == [path.encode() for path in expected_paths] + [b""], "product content/runtime path set")
    for path in CONTENT_PATHS:
        _require(after[path] == branch[path], "intake content differs from reviewed PR tip: " + path)
    for path in PROTECTED_PATHS:
        _require(before[path] == after[path], "protected source changed: " + path)
    changes = _validate_content(before, after)
    _ledger_union(base[LEDGER_PATH], before[LEDGER_PATH], branch[LEDGER_PATH], after[LEDGER_PATH])
    inventory_inverse(before[INVENTORY_PATH], after[INVENTORY_PATH])
    current = dict(after)
    repair = None
    if REPAIR_COMMIT is not None:
        repair, repair_headers = _snapshot(root, REPAIR_COMMIT, paths)
        _git(root, "merge-base", "--is-ancestor", INTAKE_COMMIT, REPAIR_COMMIT)
        _git(root, "merge-base", "--is-ancestor", REPAIR_COMMIT, head)
        # The separately reviewed receipt-only product may follow support commits.
        repair_parents = [line[7:].decode() for line in repair_headers if line.startswith(b"parent ")]
        _require(len(repair_parents) == 1, "receipt repair is not a direct-parent product")
        repair_before, _ = _snapshot(root, repair_parents[0], paths)
        _require(repair_before == after, "receipt repair predecessor changed product bytes")
        _require(_git(root, "diff", "--name-status", "-z", repair_parents[0], REPAIR_COMMIT)
                 == b"M\0" + LEDGER_PATH.encode() + b"\0", "receipt repair path set")
        _validate_repair(after, repair, root)
        current = repair
    second = None
    if SECOND_COMMIT is not None:
        _require(repair is not None, "conditional repair requires the original24 receipt successor")
        second, second_headers = _snapshot(root, SECOND_COMMIT, paths)
        _git(root, "merge-base", "--is-ancestor", REPAIR_COMMIT, SECOND_COMMIT)
        _git(root, "merge-base", "--is-ancestor", SECOND_COMMIT, head)
        second_parents = [line[7:].decode() for line in second_headers if line.startswith(b"parent ")]
        _require(len(second_parents) == 1, "conditional repair is not a direct-parent product")
        second_before, _ = _snapshot(root, second_parents[0], paths)
        _require(second_before == repair, "conditional repair predecessor changed product bytes")
        expected = b"".join(b"M\0" + path.encode() + b"\0"
                            for path in sorted((*SECOND_TARGET_PATHS, LEDGER_PATH)))
        _require(_git(root, "diff", "--name-status", "-z", second_parents[0], SECOND_COMMIT) == expected,
                 "conditional repair exact4 path set")
        _validate_second_successor(repair, second, root)
        current = second
    third_source = None
    if THIRD_SOURCE_COMMIT is not None:
        _require(second is not None, "prose correction requires the conditional9 successor")
        third_source = _successor_snapshot(root, SECOND_COMMIT, THIRD_SOURCE_COMMIT,
                                           head, second, tuple(THIRD_PRODUCT_SHA256))
        _validate_third_source(second, third_source)
        for path in THIRD_CONTENT_PATHS:
            old, new = _rows(second[path]), _rows(third_source[path])
            added = ((eid, keys) for eid in old for keys, _, _ in _changes(old[eid], new[eid]))
            changes[path] = tuple(dict.fromkeys((*changes[path], *added)))
        current = third_source
    third_receipts = None
    if THIRD_LEDGER_COMMIT is not None:
        _require(third_source is not None, "prose receipts require the authored source successor")
        third_receipts = _successor_snapshot(root, THIRD_SOURCE_COMMIT, THIRD_LEDGER_COMMIT,
                                             head, third_source, (LEDGER_PATH,))
        _validate_third_receipts(third_source, third_receipts, root)
        current = third_receipts
    fourth = None
    if FOURTH_COMMIT is not None:
        _require(third_receipts is not None, "first receipt successor requires the prior72 corrections")
        fourth = _successor_snapshot(root, THIRD_LEDGER_COMMIT, FOURTH_COMMIT,
                                     head, third_receipts, (LEDGER_PATH,))
        _validate_fourth_first_receipts(third_receipts, fourth, root)
        current = fourth
    # Source-only retirement is not another receipt stage. Keep every PR31
    # historical snapshot and census pin intact, then admit the exact successor.
    pre_source_successor = current
    with source_successor.fresh_validation_proof(root) as successor:
        _require(successor["head"] == head, "source successor HEAD differs")
        successor_before, _ = _snapshot(root, source_successor.PRODUCT_PARENT, paths)
        _require(successor_before == pre_source_successor, "source successor predecessor differs from PR31")
        current = {**current, **{path: successor["after"][path]
                   for path in paths if path in source_successor.PRODUCT_PATHS}}
        actual_main = successor["current"][source_successor.MAIN_PATH]
    pre_fact_successor = current
    with fact_successor.fresh_validation_proof(root) as successor:
        _require(successor["head"] == head, "fact successor HEAD differs")
        predecessor, _ = _snapshot(root, fact_successor.PRODUCT_PARENT, paths)
        _require(predecessor == pre_fact_successor, "fact successor predecessor differs from PR31/469")
        fact_raw = successor["receipts"] if successor["receipts"] is not None else successor["after"]
        fact_current = {**current, **{path: fact_raw[path] for path in paths if path in fact_raw}}
        person_source = (None if successor["person_source"] is None else
                         {**fact_current, **{path: successor["person_source"][path]
                          for path in paths if path in successor["person_source"]}})
        person_raw = successor["person_receipts"] if successor["person_receipts"] is not None else successor["person_source"]
        person_current = (fact_current if person_raw is None else
                          {**fact_current, **{path: person_raw[path] for path in paths if path in person_raw}})
        prose_source = (None if successor["prose_source"] is None else
                        {**person_current, **{path: successor["prose_source"][path]
                         for path in paths if path in successor["prose_source"]}})
        prose_current = {**person_current, **{path: successor["prose_current"][path]
                         for path in paths if path in successor["prose_current"]}}
        pre_ending_successor = {**prose_current, **{path: successor["ending_before"][path]
                                for path in paths if path in successor["ending_before"]}}
        ending_source = (None if successor["ending_source"] is None else
                         {**pre_ending_successor, **{path: successor["ending_source"][path]
                          for path in paths if path in successor["ending_source"]}})
        ending_raw = (successor["ending_receipts"] if successor["ending_receipts"] is not None
                      else successor["ending_source"])
        ending_current = (pre_ending_successor if ending_raw is None else
                          {**pre_ending_successor, **{path: ending_raw[path] for path in paths if path in ending_raw}})
        pre_first_win_successor = {**ending_current, **{path: successor["first_win_before"][path]
                                   for path in paths if path in successor["first_win_before"]}}
        first_win_initial = (None if successor["first_win_initial"] is None else
                             {**pre_first_win_successor, **{path: successor["first_win_initial"][path]
                              for path in paths if path in successor["first_win_initial"]}})
        first_win_source = (None if successor["first_win_source"] is None else
                            {**pre_first_win_successor, **{path: successor["first_win_source"][path]
                             for path in paths if path in successor["first_win_source"]}})
        first_win_raw = (successor["first_win_receipts"] if successor["first_win_receipts"] is not None
                         else successor["first_win_source"])
        first_win_current = (pre_first_win_successor if first_win_raw is None else
                             {**pre_first_win_successor, **{path: first_win_raw[path]
                              for path in paths if path in first_win_raw}})
        pre_night_successor = {**first_win_current, **{path: successor["night_before"][path]
                               for path in paths if path in successor["night_before"]}}
        night_source = (None if successor["night_source"] is None else
                        {**pre_night_successor, **{path: successor["night_source"][path]
                         for path in paths if path in successor["night_source"]}})
        night_raw = successor["night_receipts"] if successor["night_receipts"] is not None else successor["night_source"]
        night_current = (pre_night_successor if night_raw is None else
                         {**pre_night_successor, **{path: night_raw[path] for path in paths if path in night_raw}})
        night_metadata = (None if successor["night_metadata"] is None else
                          {**night_current, **{path: successor["night_metadata"][path]
                           for path in paths if path in successor["night_metadata"]}})
        pre_first_loss_successor = {**current, **{path: successor["loss_hold_before"][path]
                                    for path in paths if path in successor["loss_hold_before"]}}
        pre_loss_hold_successor = {**pre_first_loss_successor, source_successor.MAIN_PATH: actual_main}
        loss_hold_source = {**pre_loss_hold_successor, **{path: successor["loss_hold_source"][path]
                            for path in paths if path in successor["loss_hold_source"]}}
        loss_hold_current = (loss_hold_source if successor["loss_hold_receipts"] is None else
                             {**loss_hold_source, **{path: successor["loss_hold_receipts"][path]
                              for path in paths if path in successor["loss_hold_receipts"]}})
        loss_hold_metadata = (None if successor["loss_hold_metadata"] is None else
                              {**loss_hold_current, **{path: successor["loss_hold_metadata"][path]
                               for path in paths if path in successor["loss_hold_metadata"]}})
        current = loss_hold_current if loss_hold_metadata is None else loss_hold_metadata
    pre_market_successor = dict(current)
    with market_successor.fresh_validation_proof(root) as market:
        _require(market["head"] == head and all(current[p] == market["before"][p] for p in CURRENT_UI_PATHS),
                 "market successor predecessor differs from immutable477 four-raw")
        market_source = {**current, **{p: market["source"][p] for p in CURRENT_UI_PATHS}}
        market_receipts = (None if market["receipts"] is None else
                           {**current, **{p: market["receipts"][p] for p in CURRENT_UI_PATHS}})
        current = market_source if market_receipts is None else market_receipts
    pre_wealth_successor = dict(current)
    with wealth_successor.fresh_validation_proof(root) as wealth:
        _require(wealth["head"] == head
                 and all(current[p] == wealth["before"][p] for p in wealth_successor.PATHS),
                 "wealth predecessor differs from immutable478/470 endpoint")
        wealth_source = {**current, **wealth["source"]}
        wealth_receipts = None if wealth["receipts"] is None else {**current, **wealth["receipts"]}
        current = wealth_source if wealth_receipts is None else wealth_receipts
    # Every469..475 stage above remains its immutable historical endpoint.
    #476's completed current endpoint stays separate from477 source/receipt/
    #metadata. Runtime-facing current is always the final actual product.
    actual, _ = _snapshot(root, head, paths)
    _require(actual == current, "current HEAD product differs from approved intake/receipt repair")
    for path in paths:
        _require((root / path).read_bytes() == current[path], "current disk differs from Git: " + path)
    _require(_git(root, "rev-parse", "--verify", "HEAD^{commit}").decode().strip() == head, "HEAD changed during proof")
    return {"root": root.resolve(), "head": head, "before": before, "after": after, "current": current,
            "repair": repair, "second": second, "third_source": third_source,
            "third_receipts": third_receipts, "fourth": fourth, "changes": changes, "branch": branch,
            "pre_source_successor": pre_source_successor, "pre_fact_successor": pre_fact_successor,
            "fact_current": fact_current, "person_source": person_source,
            "person_current": person_current, "prose_source": prose_source, "prose_current": prose_current,
            "pre_ending_successor": pre_ending_successor,
            "ending_source": ending_source, "ending_current": ending_current,
            "pre_first_win_successor": pre_first_win_successor,
            "first_win_initial": first_win_initial,
            "first_win_source": first_win_source, "first_win_current": first_win_current,
            "pre_night_successor": pre_night_successor, "night_source": night_source, "night_current": night_current,
            "night_metadata": night_metadata, "pre_first_loss_successor": pre_first_loss_successor,
            "pre_loss_hold_successor": pre_loss_hold_successor, "loss_hold_source": loss_hold_source,
            "loss_hold_current": loss_hold_current, "loss_hold_metadata": loss_hold_metadata,
            "pre_market_successor": pre_market_successor,
            "market_source": market_source, "market_receipts": market_receipts,
            "pre_wealth_successor": pre_wealth_successor,
            "wealth_source": wealth_source, "wealth_receipts": wealth_receipts}


def _successor_snapshot(root, predecessor, commit, head, before, changed_paths):
    """A pinned direct-parent transition after product-neutral support commits."""
    after, headers = _snapshot(root, commit, tuple(before))
    _git(root, "merge-base", "--is-ancestor", predecessor, commit)
    _git(root, "merge-base", "--is-ancestor", commit, head)
    parents = [line[7:].decode() for line in headers if line.startswith(b"parent ")]
    _require(len(parents) == 1, "prose successor is not a direct-parent product")
    actual_before, _ = _snapshot(root, parents[0], tuple(before))
    _require(actual_before == before, "prose successor predecessor changed product bytes")
    expected = b"".join(b"M\0" + path.encode() + b"\0" for path in sorted(changed_paths))
    _require(_git(root, "diff", "--name-status", "-z", parents[0], commit) == expected,
             "prose successor exact product path set")
    return after


@contextlib.contextmanager
def fresh_validation_proof(root=ROOT):
    if _ACTIVE.get() is not None:
        _require(Path(root).resolve() == _ACTIVE.get()["root"], "nested proof changed repository")
        yield _ACTIVE.get()
        return
    proof = _read_proof(root)
    token = _ACTIVE.set(proof)
    try:
        yield proof
        # This is a current-intake-only boundary. Later content, receipt or UI
        # work needs its own declared successor; no future append is normalized.
        _require(_git(root, "rev-parse", "--verify", "HEAD^{commit}").decode().strip() == proof["head"],
                 "HEAD changed inside proof scope")
        actual, _ = _snapshot(root, proof["head"], tuple(proof["current"]))
        _require(actual == proof["current"], "Git product changed inside proof scope")
        _require(all((Path(root) / path).read_bytes() == raw for path, raw in proof["current"].items()),
                 "disk product changed inside proof scope")
        if "source_census" in proof:
            census = proof["source_census"]
            actual, _ = _snapshot(root, proof["head"], tuple(census))
            _require(actual == census, "Git source census changed inside proof scope")
            _require(all((Path(root) / path).read_bytes() == raw for path, raw in census.items()),
                     "disk source census changed inside proof scope")
    finally:
        _ACTIVE.reset(token)


def current_content_raw(root=ROOT):
    with fresh_validation_proof(root) as proof:
        return {path: proof["current"][path] for path in CURRENT_CONTENT_PATHS}


def source_predecessor_inventory(root, inventory):
    with fresh_validation_proof(root) as proof:
        hashes = inventory["source_hashes"]
        _require(_digest(hashes) == inventory["source_manifest_sha256"], "current source census digest")
        _require(all(hashes.get(path) == _sha(proof["current"][path]) for path in SOURCE_PATHS),
                 "current source census/content raw binding")
        comparison = dict(hashes)
        if market_successor.INVESTMENT_PATH in hashes:
            # Preserve the public partial15 API. Full inventories restore only
            #the new source hash here; the actual Main is still owned by Main.
            comparison = market_successor.source_predecessor_inventory(root, inventory)["source_hashes"]
        with fact_successor.fresh_validation_proof(root) as successor:
            if successor["prose_before"] is not None:
                for path in fact_successor.PROSE_KO_PATHS:
                    if path in hashes:
                        _require(hashes[path] == _sha(successor["current"][path]),
                                 "current recall source census binding")
                        comparison[path] = _sha(successor["prose_before"][path])
            comparison.update({path: _sha(proof["before"][path]) for path in SOURCE_PATHS})
            for path in fact_successor.SOURCE_PATHS:
                if path in hashes:
                    _require(hashes[path] == _sha(successor["current"][path]), "current fact source census binding")
                    comparison[path] = _sha(successor["before"][path])
        with source_successor.fresh_validation_proof(root) as successor:
            for path in source_successor.SOURCE_PATHS:
                if path != source_successor.MAIN_PATH and path in hashes:
                    _require(hashes[path] == _sha(successor["after"][path]), "current classification census raw binding")
                    comparison[path] = _sha(successor["before"][path])
        return {**inventory, "source_hashes": comparison, "source_manifest_sha256": _digest(comparison)}


def source_stage_manifest_digests(root, inventory):
    """Historical PR31 stages plus the exact source-only successor census.

    Current admission proves the actual complete Git/disk population. Only
    the historical comparison restores the three ORDER-469 source hashes
    (Main/lifecycle/spine), then the approved Korean content stage hashes.
    The original e300 pin and receipt headers remain unchanged. The scoped
    proof rechecks its actual current census when the outer scope exits.
    """
    with fresh_validation_proof(root) as proof:
        hashes = inventory["source_hashes"]
        predecessor_inventory = source_successor.source_predecessor_inventory(root, inventory)
        historical_hashes = predecessor_inventory["source_hashes"]
        _require(isinstance(hashes, dict)
                 and _digest(hashes) == inventory["source_manifest_sha256"]
                 and predecessor_inventory["source_manifest_sha256"] == CURRENT_SOURCE_MANIFEST_SHA256,
                 "complete current source census differs from official source pin")
        _require(all(hashes.get(path) == _sha(proof["current"][path]) for path in SOURCE_PATHS)
                 and hashes.get("scenes/MainGame.gd") == _sha(proof["current"]["scenes/MainGame.gd"]),
                 "current source census/content/Main raw binding")
        if "source_stage_manifests" not in proof:
            actual, _ = _snapshot(root, proof["head"], tuple(hashes))
            _require({path: _sha(raw) for path, raw in actual.items()} == hashes,
                     "complete source census differs from current Git")
            _require(all((Path(root) / path).read_bytes() == raw for path, raw in actual.items()),
                     "complete source census differs from current disk")
            manifests = {inventory["source_manifest_sha256"],
                         fact_successor.PREDECESSOR_SOURCE_MANIFEST_SHA256}
            if proof["person_source"] is not None:
                # The preceding source_successor call proved the entire471
                # predecessor census against its typed immutable snapshot.
                manifests.add(fact_successor.RECEIPT_SOURCE_MANIFEST_SHA256)
            if proof["prose_source"] is not None:
                manifests.add(fact_successor.PERSON_RECEIPT_SOURCE_MANIFEST_SHA256)
            if proof["ending_source"] is not None:
                manifests.add(fact_successor.PROSE_RECEIPT_SOURCE_MANIFEST_SHA256)
            if proof["first_win_source"] is not None:
                manifests.add(fact_successor.ENDING_RECEIPT_SOURCE_MANIFEST_SHA256)
            if proof["night_source"] is not None:
                manifests.add(fact_successor.FIRST_WIN_RECEIPT_SOURCE_MANIFEST_SHA256)
            # The complete476 -> pre476 census was just independently proved
            # by source_successor. This is a source-only stage, not a receipt.
            manifests.add(source_successor.FIRST_LOSS_PREDECESSOR_CENSUS)
            #480 proves its whole parent before478 Investment is projected;
            #the original478 export census remains a separate immutable stage.
            pre_wealth = wealth_successor.source_predecessor_inventory(root, inventory)
            manifests.add(pre_wealth["source_manifest_sha256"])
            #source_successor proved477's full parent before applying the476
            #Main inverse. Keep that actual476 endpoint distinct from90d88.
            pre_market = market_successor.source_predecessor_inventory(root, inventory)["source_hashes"]
            manifests.add(_digest(pre_market))
            pre_hold = {**pre_market, fact_successor.LOSS_HOLD_KO_PATH:
                        _sha(proof["pre_loss_hold_successor"][fact_successor.LOSS_HOLD_KO_PATH])}
            manifests.add(_digest(pre_hold))
            for stage, revision in (("before", INTAKE_PARENT), ("after", INTAKE_COMMIT),
                                    ("second", SECOND_COMMIT), ("third_source", THIRD_SOURCE_COMMIT)):
                if revision is None:
                    continue
                _require(proof[stage] is not None, "source stage lacks product proof")
                candidate = {**historical_hashes, **{path: _sha(proof[stage][path]) for path in SOURCE_PATHS}}
                stage_raw, _ = _snapshot(root, revision, tuple(hashes))
                _require({path: _sha(raw) for path, raw in stage_raw.items()} == candidate,
                         "fixed stage source census differs outside approved Korean content")
                manifests.add(_digest(candidate))
            # Stored only after every immutable stage and the actual source
            # have passed; none of these derived values survives this scope.
            proof["source_census"] = actual
            proof["source_stage_manifests"] = frozenset(manifests)
        return proof["source_stage_manifests"]


def release_inventory_predecessor(raw, root=ROOT):
    with fresh_validation_proof(root) as proof:
        _require(raw == proof["current"][INVENTORY_PATH], "current inventory raw differs")
        raw = fact_successor.predecessor_bytes(raw, INVENTORY_PATH, root)
        raw = source_successor.product_inverse(proof["pre_source_successor"][INVENTORY_PATH], raw, INVENTORY_PATH)
        if INVENTORY_PATH in THIRD_PRODUCT_SHA256:
            raw = third_product_inverse(proof["second"][INVENTORY_PATH], raw, INVENTORY_PATH)
        return inventory_inverse(proof["before"][INVENTORY_PATH], raw)


def _leaf_receipt(snapshot, locale, identifier):
    group, owner, pointer = identifier.split(":", 2)
    _require(group in {"events", "endings"}, "receipt recovery group")
    source_path = "content/endings.json" if group == "endings" else next((
        path for path in SOURCE_PATHS if path.startswith("content/events/")
        and owner in _rows(snapshot[path])), None)
    _require(source_path is not None, "receipt recovery owner")
    tokens = tuple(int(k) if k.isdigit() else k.replace("~1", "/").replace("~0", "~") for k in pointer[1:].split("/"))
    target_path = "content/endings_" + locale + ".json" if group == "endings" else source_path.replace("/events/", "/events_" + locale + "/")
    source, target = _rows(snapshot[source_path])[owner], _rows(snapshot[target_path])[owner]
    for key in tokens:
        source, target = source[key], target[key]
    _require(isinstance(source, str) and isinstance(target, str), "receipt text leaf shape")
    return {"source_sha256": _digest({"path": source_path, "field": tokens, "ko": source}),
            "target_sha256": _digest(target)}


def _validate_repair(before, after, root=ROOT):
    _require(all(before[path] == after[path] for path in before if path != LEDGER_PATH), "receipt recovery changed content")
    return _validate_receipt_recovery(before, after, REPAIR_IDS, REPAIR_BATCH_SHA256, REPAIR_COMMIT, root)


def _validate_receipt_recovery(before, after, identifiers, batch_sha256, commit, root, *, groups=None):
    """One explicit pinned receipt correction, never an append exemption."""
    if groups is None:
        groups = {"events": identifiers}
        _require(set(batch_sha256) == set(LOCALES), "actual official receipt row pins are missing")
        batch_sha256 = {("events", locale): digest for locale, digest in batch_sha256.items()}
    _require(tuple(identifier for ids in groups.values() for identifier in ids) == tuple(identifiers)
             and all(identifier.startswith(group + ":") for group, ids in groups.items() for identifier in ids),
             "receipt recovery exact group populations")
    expected_batches = {(group, locale) for group in groups for locale in LOCALES}
    _require(set(batch_sha256) == expected_batches, "actual grouped official receipt row pins are missing")
    old, new = _loads(before[LEDGER_PATH]), _loads(after[LEDGER_PATH])
    expected = copy.deepcopy(old)
    for locale in LOCALES:
        for identifier in identifiers:
            receipt = _leaf_receipt(after, locale, identifier)
            _require(identifier in old["accepted"][locale] and old["accepted"][locale][identifier] != receipt,
                     "recovery must correct an existing stale receipt")
            expected["accepted"][locale][identifier] = receipt
    expected["accepted_sha256"] = _digest(expected["accepted"])
    _require(new["batches"][:len(old["batches"])] == old["batches"]
             and len(new["batches"]) == len(old["batches"]) + len(expected_batches),
             "receipt recovery must preserve the exact original batch prefix and bounded additions")
    seen, source_snapshots = set(), {}
    for batch in new["batches"][len(old["batches"]):]:
        headers = batch.get("official_receipt_headers_by_locale", {})
        _require(isinstance(headers, dict) and len(headers) == 1, "one official locale per recovery batch")
        locale = next(iter(headers))
        group = batch.get("group")
        batch_key = (group, locale)
        _require(batch_key in expected_batches and batch_key not in seen
                 and _digest(batch) == batch_sha256[batch_key], "exact official recovery batch row")
        seen.add(batch_key)
        selected = groups[group]
        header = headers[locale]
        _require(set(header) == {"kind", "schema_version", "locale", "source_revision", "prompt_version",
                                "source_manifest_sha256", "selection_sha256", "count", "source_language",
                                "native_review", "batch_id"}
                 and header["kind"] == "full_game_localization_batch"
                 and header["schema_version"] == 1 and header["locale"] == locale
                 and header["prompt_version"] == old["prompt_version"]
                 and header["count"] == len(selected) and header["source_language"] == "ko"
                 and header["native_review"] == "OPEN"
                 and header["batch_id"] == _digest({k: v for k, v in header.items() if k != "batch_id"}),
                 "official recovery header identity/count/state")
        _require(batch.get("order") == "ORDER-468"
                 and batch.get("source_leaves") == len(selected)
                 and batch.get("machine_validation") == "PASS"
                 and batch.get("native_review") == batch.get("rendered_review") == "OPEN",
                 "recovery row scope or machine/native distinction")
        counts = batch.get("target_leaves_by_locale", {})
        _require(set(counts) <= set(LOCALES)
                 and all(counts.get(loc, 0) == (len(selected) if loc == locale else 0) for loc in LOCALES),
                 "recovery target census differs from the exact owned leaf count")
        receipt = {"batch": header, "state": "accepted_machine_validated", "native_review": "OPEN",
                   "translations": {identifier: new["accepted"][locale][identifier] for identifier in selected}}
        _require(batch.get("receipt_sha256_by_locale") == {locale: _digest(receipt)},
                 "official accepted receipt does not match the exact current leaves")
        revision = header["source_revision"]
        _git(root, "merge-base", "--is-ancestor", revision, commit)
        if revision not in source_snapshots:
            source_snapshots[revision], _ = _snapshot(root, revision, tuple(before))
        _require(source_snapshots[revision] == before,
                 "official export revision has a different product source/ledger")
    _require(seen == expected_batches, "official recovery group/locales are incomplete")
    expected["batches"] = new["batches"]
    _require(_ordered(new) == _ordered(expected), "receipt recovery exceeds exact owned values/batch additions")


def second_overlay_inverse(before, after, path):
    """Restore one final sentence and require the entire original raw file."""
    _require(path in SECOND_TARGET_PATHS, "unowned conditional target path")
    locale = path.split("/")[1].removeprefix("events_")
    old, new = _Document(before), _Document(after)
    index = next((i for i, row in enumerate(old.value) if row.get("id") == "arc_year4_close_father_passed"), None)
    _require(index is not None, "conditional target event missing")
    pointer = (index, "choices", 1, "result_text")
    changes = list(_changes(old.value, new.value))
    _require(len(changes) == 1 and changes[0][0] == pointer, "conditional target changed outside exact result leaf")
    _, old_text, new_text = changes[0]
    old_sentence, new_sentence = SECOND_SENTENCES[locale]
    _require(isinstance(old_text, str) and old_text.endswith(old_sentence)
             and new_text == old_text[:-len(old_sentence)] + new_sentence,
             "conditional target must change only the reviewed final sentence")
    a, z = old.spans[pointer]
    p, q = new.spans[pointer]
    restored = (new.text[:p] + old.text[a:z] + new.text[q:]).encode()
    _require(restored == before, "conditional target raw bytes outside owned literal changed")
    return restored


def _validate_second_successor(before, after, root=ROOT):
    _require(set(before) == set(after), "conditional successor snapshot path population")
    for path in before:
        if path in SECOND_TARGET_PATHS:
            second_overlay_inverse(before[path], after[path], path)
        elif path != LEDGER_PATH:
            _require(before[path] == after[path], "conditional successor changed protected product: " + path)
    return _validate_receipt_recovery(before, after, SECOND_IDS, SECOND_BATCH_SHA256, SECOND_COMMIT, root)


def third_product_inverse(before, after, path):
    """Exact reviewed prose/metadata raw pair, with no other JSON leaf edit."""
    _require(path in THIRD_PRODUCT_SHA256 and isinstance(before, bytes) and isinstance(after, bytes)
             and (_sha(before), _sha(after)) == THIRD_PRODUCT_SHA256[path],
             "prose correction raw pair differs: " + path)
    if path == "docs/CONTENT_RATING_INVENTORY.md":
        # Generated text is owned as an entire pinned artifact, not JSON prose.
        return before
    old, new = _Document(before), _Document(after)
    if path == INVENTORY_PATH:
        allowed = THIRD_INVENTORY_FIELDS
        _require(bool(allowed), "prose inventory field pins are missing")
    else:
        _require(path in THIRD_CONTENT_PATHS, "unowned prose correction path")
        identifiers = THIRD_ENDING_IDS if path.startswith("content/endings") else (
            THIRD_EVENT_IDS[:3] if path.endswith("/arc_daeun_married.json") else THIRD_EVENT_IDS[3:])
        _require(list(_rows(before)) == list(_rows(after)), "prose correction changed ID order")
        indices = {row["id"]: index for index, row in enumerate(old.value)}
        allowed = set()
        for identifier in identifiers:
            _, owner, pointer = identifier.split(":", 2)
            tokens = tuple(int(key) if key.isdigit() else key.replace("~1", "/").replace("~0", "~")
                           for key in pointer[1:].split("/"))
            _require(owner in indices, "prose correction owner missing")
            allowed.add((indices[owner], *tokens))
    changes = list(_changes(old.value, new.value))
    _require({keys for keys, _, _ in changes} == set(allowed), "prose correction exact owned JSON leaves")
    _require(all(isinstance(a, str) and isinstance(b, str) for _, a, b in changes),
             "prose correction touched non-string data")
    text, replacements = new.text, []
    for keys, _, _ in changes:
        a, z = old.spans[keys]
        p, q = new.spans[keys]
        replacements.append((p, q, old.text[a:z]))
    for p, q, literal in sorted(replacements, reverse=True):
        text = text[:p] + literal + text[q:]
    _require(text.encode() == before, "prose correction changed bytes outside exact owned literals")
    return before


def _validate_third_source(before, after):
    _require(set(before) == set(after), "prose successor snapshot path population")
    _require(set(THIRD_CONTENT_PATHS) <= set(THIRD_PRODUCT_SHA256)
             <= set(THIRD_CONTENT_PATHS) | {INVENTORY_PATH, "docs/CONTENT_RATING_INVENTORY.md"},
             "prose correction exact15 text files and bounded generated metadata")
    for path in before:
        if path in THIRD_PRODUCT_SHA256:
            third_product_inverse(before[path], after[path], path)
        else:
            _require(before[path] == after[path], "prose correction changed protected product: " + path)


def _validate_third_receipts(before, after, root=ROOT):
    _require(set(before) == set(after)
             and all(before[path] == after[path] for path in before if path != LEDGER_PATH),
             "prose receipt successor changed product content")
    return _validate_receipt_recovery(before, after, (*THIRD_EVENT_IDS, *THIRD_ENDING_IDS),
                                      THIRD_BATCH_SHA256, THIRD_LEDGER_COMMIT, root,
                                      groups=THIRD_IDS_BY_GROUP)


def _validate_fourth_first_receipts(before, after, root=ROOT):
    """Six absent receipts only; deliberately separate from stale recovery."""
    _require(set(before) == set(after)
             and all(before[path] == after[path] for path in before if path != LEDGER_PATH),
             "first receipt successor changed product content")
    old, new = _loads(before[LEDGER_PATH]), _loads(after[LEDGER_PATH])
    _require(set(FOURTH_BATCH_SHA256) == set(LOCALES), "first receipt row pins are incomplete")
    expected = copy.deepcopy(old)
    for locale in LOCALES:
        _require(all(identifier not in old["accepted"][locale] for identifier in FOURTH_IDS),
                 "first receipt successor cannot replace an existing receipt")
        _require(set(new["accepted"][locale]) == set(old["accepted"][locale]) | set(FOURTH_IDS),
                 "first receipt successor must add exactly2 absent IDs per locale")
        # Preserve the actual official import's two-key insertion order while
        # requiring every pre-existing key and its order to remain unchanged.
        for identifier in new["accepted"][locale]:
            if identifier in FOURTH_IDS:
                expected["accepted"][locale][identifier] = _leaf_receipt(after, locale, identifier)
    expected["accepted_sha256"] = _digest(expected["accepted"])
    _require(new["batches"][:len(old["batches"])] == old["batches"]
             and len(new["batches"]) == len(old["batches"]) + len(LOCALES),
             "first receipt successor must preserve old batches and add exactly3")
    seen, source_snapshots = set(), {}
    for batch in new["batches"][len(old["batches"]):]:
        headers = batch.get("official_receipt_headers_by_locale", {})
        _require(isinstance(headers, dict) and len(headers) == 1, "one official locale per first receipt row")
        locale = next(iter(headers))
        _require(locale in LOCALES and locale not in seen and _digest(batch) == FOURTH_BATCH_SHA256[locale],
                 "exact official first receipt row")
        seen.add(locale)
        header = headers[locale]
        _require(set(header) == {"kind", "schema_version", "locale", "source_revision", "prompt_version",
                                "source_manifest_sha256", "selection_sha256", "count", "source_language",
                                "native_review", "batch_id"}
                 and header["kind"] == "full_game_localization_batch"
                 and header["schema_version"] == 1 and header["locale"] == locale
                 and header["prompt_version"] == old["prompt_version"]
                 and header["source_manifest_sha256"] == CURRENT_SOURCE_MANIFEST_SHA256
                 and header["count"] == len(FOURTH_IDS) and header["source_language"] == "ko"
                 and header["native_review"] == "OPEN"
                 and header["batch_id"] == _digest({key: value for key, value in header.items() if key != "batch_id"}),
                 "official first receipt header identity/count/state")
        _require(batch.get("group") == "events" and batch.get("order") == "ORDER-468"
                 and batch.get("source_leaves") == len(FOURTH_IDS)
                 and batch.get("machine_validation") == "PASS"
                 and batch.get("native_review") == batch.get("rendered_review") == "OPEN",
                 "first receipt row scope or machine/native distinction")
        counts = batch.get("target_leaves_by_locale", {})
        _require(set(counts) <= set(LOCALES)
                 and all(counts.get(loc, 0) == (len(FOURTH_IDS) if loc == locale else 0) for loc in LOCALES),
                 "first receipt target census differs from exact2 leaves")
        receipt = {"batch": header, "state": "accepted_machine_validated", "native_review": "OPEN",
                   "translations": {identifier: expected["accepted"][locale][identifier] for identifier in FOURTH_IDS}}
        _require(batch.get("receipt_sha256_by_locale") == {locale: _digest(receipt)},
                 "official first receipt does not match exact current leaves")
        revision = header["source_revision"]
        _git(root, "merge-base", "--is-ancestor", revision, FOURTH_COMMIT)
        if revision not in source_snapshots:
            source_snapshots[revision], _ = _snapshot(root, revision, tuple(before))
        _require(source_snapshots[revision] == before,
                 "first receipt export revision has a different product source/ledger")
    _require(seen == set(LOCALES), "official first receipt locales are incomplete")
    expected["batches"] = new["batches"]
    _require(_ordered(new) == _ordered(expected), "first receipt successor exceeds exact6 additions")


def _receipt_comparison(snapshot, before, after):
    _require(set(snapshot) == set(before) == set(after) == set(CURRENT_UI_PATHS), "receipt comparison path population")
    _require(snapshot[LEDGER_PATH] == after[LEDGER_PATH], "receipt comparison is not exact approved ledger")
    _require(all(snapshot[path] == after[path] == before[path] for path in UI_PATHS), "receipt comparison changed UI dictionary")
    return {**snapshot, LEDGER_PATH: before[LEDGER_PATH]}


def receipt_transitions(root, inventory):
    """Actual four-raw snapshots for the UI verifier's existing correction seam."""
    with fresh_validation_proof(root) as proof:
        result = []
        for commit, a, b in ((INTAKE_COMMIT, proof["before"], proof["after"]),
                             (REPAIR_COMMIT, proof["after"], proof["repair"]),
                             (SECOND_COMMIT, proof["repair"], proof["second"]),
                             (THIRD_LEDGER_COMMIT, proof["third_source"], proof["third_receipts"]),
                             (FOURTH_COMMIT, proof["third_receipts"], proof["fourth"]),
                             (fact_successor.RECEIPT_COMMIT, proof["pre_fact_successor"], proof["fact_current"]),
                             (fact_successor.PERSON_RECEIPT_COMMIT, proof["person_source"], proof["person_current"]),
                             (fact_successor.PROSE_RECEIPT_COMMIT, proof["prose_source"], proof["prose_current"]),
                             (fact_successor.ENDING_RECEIPT_COMMIT, proof["ending_source"], proof["ending_current"]),
                             (fact_successor.FIRST_WIN_RECEIPT_COMMIT, proof["first_win_source"], proof["first_win_current"]),
                             (fact_successor.NIGHT_RECEIPT_COMMIT, proof["night_source"], proof["night_current"]),
                             (fact_successor.LOSS_HOLD_RECEIPT_COMMIT, proof["loss_hold_source"], proof["loss_hold_current"])):
            if commit is None:
                continue
            before = {path: a[path] for path in CURRENT_UI_PATHS}
            after = {path: b[path] for path in CURRENT_UI_PATHS}
            old, new = _loads(before[LEDGER_PATH]), _loads(after[LEDGER_PATH])
            first = sum(len(set(new["accepted"][loc]) - set(old["accepted"][loc])) for loc in LOCALES)
            corrected = sum(sum(new["accepted"][loc][key] != value
                                for key, value in old["accepted"][loc].items()) for loc in LOCALES)
            manifests = {header["source_revision"]: header["source_manifest_sha256"]
                         for batch in new["batches"][len(old["batches"]):]
                         for header in batch["official_receipt_headers_by_locale"].values()}
            change = {"ui_by_locale": {locale: 0 for locale in LOCALES}, "receipts": 0,
                      "batches": 0, "first_receipts": first, "corrections": corrected,
                      "correction_batches": len(new["batches"]) - len(old["batches"]),
                      "source_manifests": manifests, "pr31_intake_comparison": True}
            result.append((commit, before, after, change, _receipt_comparison))
        for commit, a, b in ((market_successor.PRODUCT_COMMIT, proof["pre_market_successor"], proof["market_source"]),
                             (market_successor.RECEIPT_COMMIT, proof["market_source"], proof["market_receipts"])):
            if commit is None:
                continue
            before, after = ({p: snapshot[p] for p in CURRENT_UI_PATHS} for snapshot in (a, b))
            is_receipt = commit == market_successor.RECEIPT_COMMIT
            change = {"ui_by_locale": {locale: 0 for locale in LOCALES}, "receipts": 0, "batches": 0,
                      "first_receipts": int(is_receipt), "corrections": 0, "correction_batches": int(is_receipt),
                      "source_manifests": ({market_successor.RECEIPT_PARENT: market_successor.RECEIPT_SOURCE_MANIFEST_SHA256}
                                           if is_receipt else {}), "pr31_intake_comparison": True}
            result.append((commit, before, after, change, market_successor.ui_comparison))
        for commit, a, b in ((wealth_successor.PRODUCT_COMMIT, proof["pre_wealth_successor"], proof["wealth_source"]),
                             (wealth_successor.RECEIPT_COMMIT, proof["wealth_source"], proof["wealth_receipts"])):
            if commit is None:
                continue
            before, after = ({p: snapshot[p] for p in CURRENT_UI_PATHS} for snapshot in (a, b))
            is_receipt = commit == wealth_successor.RECEIPT_COMMIT
            change = {"ui_by_locale": {locale: int(not is_receipt) for locale in LOCALES},
                      "receipts": 0, "batches": 0, "first_receipts": 3 * int(is_receipt),
                      "corrections": 0, "correction_batches": 3 * int(is_receipt),
                      "source_manifests": ({wealth_successor.RECEIPT_PARENT: wealth_successor.RECEIPT_SOURCE_MANIFEST_SHA256}
                                           if is_receipt else {}), "pr31_intake_comparison": True}
            result.append((commit, before, after, change, wealth_successor.ui_comparison))
        return tuple(result)


def __getattr__(name):
    if name in {"HISTORICAL_JSON_LEAVES", "LIVE_EVENT_IDS"}:
        with fresh_validation_proof() as proof:
            if name == "HISTORICAL_JSON_LEAVES":
                result = dict(previous.HISTORICAL_JSON_LEAVES)
                for path in HISTORY_CONTENT_PATHS:
                    result[path] = tuple(dict.fromkeys((*result.get(path, ()), *proof["changes"][path])))
                for path in fact_successor.ARC_PATHS[:2]:
                    changes = fact_successor.changed_text_selectors(
                        proof["pre_fact_successor"][path], proof["current"][path])
                    result[path] = tuple(dict.fromkeys((*result.get(path, ()), *changes)))
                if proof["person_source"] is not None:
                    for path in fact_successor.PERSON_PATHS[:2]:
                        result[path] = tuple(dict.fromkeys((*result.get(path, ()),
                                                           *fact_successor.PERSON_TEXT_LEAVES)))
                if proof["prose_source"] is not None:
                    for path in fact_successor.PROSE_PRODUCT_PATHS:
                        result[path] = tuple(dict.fromkeys((*result.get(path, ()),
                                                           *fact_successor.prose_selectors(path))))
                if proof["first_win_source"] is not None:
                    for path in fact_successor.FIRST_WIN_PATHS[:2]:
                        result[path] = tuple(dict.fromkeys((*result.get(path, ()),
                                                           *fact_successor.FIRST_WIN_TEXT_LEAVES)))
                if proof["night_source"] is not None:
                    for path in fact_successor.NIGHT_PATHS[:2]:
                        result[path] = tuple(dict.fromkeys((*result.get(path, ()), *fact_successor.NIGHT_TEXT_LEAVES)))
                for path in fact_successor.LOSS_HOLD_PATHS[:2]:
                    result[path] = tuple(dict.fromkeys((*result.get(path, ()), *fact_successor.LOSS_HOLD_TEXT_LEAVES)))
                return result
            result = dict(previous.LIVE_EVENT_IDS)
            for path in HISTORY_CONTENT_PATHS:
                result[path] = frozenset(result.get(path, ())) | frozenset(eid for eid, _ in proof["changes"][path])
            for path in fact_successor.ARC_PATHS[:2]:
                result[path] = frozenset(result.get(path, ())) | frozenset(fact_successor.EVENT_IDS)
            if proof["person_source"] is not None:
                for path in fact_successor.PERSON_PATHS[:2]:
                    result[path] = frozenset(result.get(path, ())) | {fact_successor.PERSON_EVENT_ID}
            if proof["prose_source"] is not None:
                for path in fact_successor.PROSE_PRODUCT_PATHS:
                    result[path] = frozenset(result.get(path, ())) | frozenset(
                        eid for eid, _keys in fact_successor.prose_selectors(path))
            if proof["first_win_source"] is not None:
                for path in fact_successor.FIRST_WIN_PATHS[:2]:
                    result[path] = frozenset(result.get(path, ())) | frozenset(fact_successor.FIRST_WIN_EVENT_IDS)
            if proof["night_source"] is not None:
                for path in fact_successor.NIGHT_PATHS[:2]:
                    result[path] = frozenset(result.get(path, ())) | {fact_successor.NIGHT_EVENT_ID}
            for path in fact_successor.LOSS_HOLD_PATHS[:2]:
                result[path] = frozenset(result.get(path, ())) | {eid for eid, _ in fact_successor.LOSS_HOLD_TEXT_LEAVES}
            return result
    return getattr(previous, name)


def source_errors(raw, relative):
    if relative not in CURRENT_CONTENT_PATHS:
        return previous.source_errors(raw, relative)
    try:
        with fresh_validation_proof() as proof:
            _require(isinstance(raw, bytes) and raw == proof["current"][relative], "current content differs: " + relative)
        return []
    except (OSError, ValueError, KeyError, TypeError, IndexError, subprocess.TimeoutExpired) as exc:
        return [str(exc)]


def project_bytes(raw, relative):
    if relative in fact_successor.ARC_PATHS:
        with fresh_validation_proof() as proof:
            compared = proof["pre_fact_successor"][relative] if raw == proof["current"][relative] else raw
            return previous.project_bytes(compared, relative)
    if relative not in CURRENT_HISTORY_PATHS:
        return previous.project_bytes(raw, relative)
    with fresh_validation_proof() as proof:
        # Projection is comparison-only and idempotent. Current admission is
        # source_errors(); an unknown/mutated image must never get this inverse.
        compared = proof["before"][relative] if raw == proof["current"][relative] else raw
        return previous.project_bytes(compared, relative)


def project_payload(payload, relative):
    if relative in fact_successor.ARC_PATHS:
        with fresh_validation_proof() as proof:
            old, current = _rows(proof["pre_fact_successor"][relative]), _rows(proof["current"][relative])
            projected = copy.deepcopy(payload)
            if isinstance(projected, list):
                for index, row in enumerate(projected):
                    eid = row.get("id") if isinstance(row, dict) else None
                    if eid in current and _ordered(row) == _ordered(current[eid]):
                        projected[index] = copy.deepcopy(old[eid])
            return previous.project_payload(projected, relative)
    if relative not in CURRENT_HISTORY_PATHS:
        return previous.project_payload(payload, relative)
    with fresh_validation_proof() as proof:
        old, current = _rows(proof["before"][relative]), _rows(proof["current"][relative])
        projected = copy.deepcopy(payload)
        if not isinstance(projected, list):
            return previous.project_payload(projected, relative)
        for index, row in enumerate(projected):
            eid = row.get("id") if isinstance(row, dict) else None
            if eid in current and current[eid] != old[eid] and _ordered(row) == _ordered(current[eid]):
                projected[index] = copy.deepcopy(old[eid])
        return previous.project_payload(projected, relative)


def project_byte_hash(observed, relative):
    if relative in fact_successor.ARC_PATHS:
        with fresh_validation_proof() as proof:
            if observed == _sha(proof["current"][relative]):
                return previous.project_byte_hash(_sha(proof["pre_fact_successor"][relative]), relative)
            return previous.project_byte_hash(observed, relative)
    if relative in ENDING_PATHS:
        # Ending text participates only in this raw-hash comparison. Do not
        # project its current payload or return old prose to runtime consumers.
        with fresh_validation_proof() as proof:
            if observed == _sha(proof["current"][relative]):
                return previous.project_byte_hash(_sha(proof["before"][relative]), relative)
            return previous.project_byte_hash(observed, relative)
    if relative not in CURRENT_HISTORY_PATHS:
        return previous.project_byte_hash(observed, relative)
    with fresh_validation_proof() as proof:
        if observed == _sha(proof["current"][relative]):
            return _sha(previous.project_bytes(proof["before"][relative], relative))
        return previous.project_byte_hash(observed, relative)


def historical_blobs(relative):
    if relative in fact_successor.ARC_PATHS:
        with fresh_validation_proof() as proof:
            # Keep ORDER305 when constructing its post305 historical vector.
            before = previous.inverse_current_bytes(proof["pre_fact_successor"][relative], relative)
            return before, proof["current"][relative]
    if relative not in CURRENT_HISTORY_PATHS:
        return previous.historical_blobs(relative)
    with fresh_validation_proof() as proof:
        return previous.project_bytes(proof["before"][relative], relative), proof["current"][relative]


def verified_blobs(relative):
    if relative not in CURRENT_CONTENT_PATHS:
        return previous.verified_blobs(relative)
    with fresh_validation_proof() as proof:
        return proof["before"][relative], proof["current"][relative]


def source_observation_errors(raw, payload, relative):
    errors = source_errors(raw, relative)
    try:
        _require(_ordered(_loads(raw)) == _ordered(payload), "payload differs from observed raw: " + relative)
    except (ValueError, TypeError, UnicodeError) as exc:
        errors.append(str(exc))
    return errors


def observed_byte_hash(relative, observed, raw):
    errors = source_errors(raw, relative)
    if not isinstance(raw, bytes) or _sha(raw) != observed:
        errors.append("PR31 intake: observed hash differs from raw: " + relative)
    return (observed, errors) if errors else (project_byte_hash(observed, relative), [])
