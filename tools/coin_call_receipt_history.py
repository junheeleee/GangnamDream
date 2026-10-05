"""Exact ORDER-458 source/receipt successor; historical comparisons only.

The current census and current event bytes remain current. Only the two
observed transitions below may be inverted for old UI receipt comparisons.
No success cache, general event-correction permission or coverage increment.
"""
from __future__ import annotations

import copy
import hashlib
import re
from pathlib import Path
from typing import Any, Mapping

import full_game_localization as exchange
import coffee_encounter_receipt_history as prior
from order351_source_compat import _Document, _loads, _ordered

ROOT = Path(__file__).resolve().parents[1]
LOCALES = ("ja", "zh-CN", "zh-TW")
KO_PATH = "content/events/amb_scenarios2.json"
EN_PATH = "content/events_en/amb_scenarios2.json"
RULES_PATH = "content/meta/story_rules.json"
VISUAL_PATH = "assets/event_visual_contracts.json"
DIRECTION_PATH = "assets/scene_direction_manifest.json"
SOURCE_PATHS = (KO_PATH, RULES_PATH)
SOURCE_PRODUCT_PATHS = (KO_PATH, EN_PATH, RULES_PATH, VISUAL_PATH, DIRECTION_PATH)
EVENT_PATHS = tuple(f"content/events_{locale}/amb_scenarios2.json" for locale in LOCALES)
LEDGER_PATH = "content/meta/full_game_localization.json"
CURRENT_PATHS = tuple(f"locale/ui_{locale}.json" for locale in LOCALES) + (LEDGER_PATH,)
PRODUCT_PATHS = (*EVENT_PATHS, LEDGER_PATH)
CURRENT_EVENT_PATHS = (*SOURCE_PRODUCT_PATHS, *EVENT_PATHS)
HEADERS_FIELD = "official_receipt_headers_by_locale"
BATCH_INDEX = 228
SELECTORS = (("amb_coin_00", ("choices", 2, "result_text")),
             ("amb_coin_00", ("description",)), ("amb_coin_warn", ("description",)))
COIN_REVIEW = (
    "Korean-direct correction of three existing coin-call leaves: recall the original 3 billion won goal "
    "without assuming distance from current assets; hear Taeho's hardening/sharpening voice rather than "
    "seeing his face during a phone call. No new leaves or gameplay changes. Original receipts and "
    "public-demo binary history retained. Agent source review is not native or release approval.")

SOURCE_BEFORE_COMMIT = "f9b4337caeb6e634538c49ab00323c2b9111eea2"
SOURCE_AFTER_COMMIT = "632f88babba781e639157e33ac1a06744b987c1b"
SOURCE_TREES = ("1bcbd691170c7c2df3d4b4a30915970943dfdd93", "acce110705d94b45c35f233b4820561a2980c987")
SOURCE_BLOBS = {
    VISUAL_PATH: ("1256bab7f2228e69a09717fb17d58daa04068c71", "d895c81019b2e85baac49020ee066c5abfa8145c"),
    DIRECTION_PATH: ("95a93c1121f7ad7330e597f496642870feeb0707", "a0a8486c70b3ee0e1e1839aba55d4a944bf4af78"),
    KO_PATH: ("7455e09dc0368a3519e60db84fc25d3c68ae949b", "ab005a1f1536bbb1e4dd0e450b1fc562dfda8522"),
    EN_PATH: ("843ec53133712ae18c26c63a46dd6d1f41232462", "2e6924c6b985d1c1ead06a8e83878abcfa202fdd"),
    RULES_PATH: ("8b2a027eb3a233201133928aee741c1bf5b551f2", "249477d4d27fb3c4fef921af9f394d5843d4211a"),
    "docs/STATUS.md": ("67be577d8a7a9e6c238a78d6fb1aea6612df825a", "4e0dd12817578c278142ec2e0307eeac348e399b"),
    "docs/WORK_LOG.md": ("cef69f8b228b0080ff14153c1ec39f8bcd722d34", "29a7f2faa33ac05c54d20027d48aa74d4f9ffe0a"),
}
SOURCE_HASHES = {
    VISUAL_PATH: ("32c1afc21301d1d75d07c3d69f96f64193e17a442cca449fff06a38055d6d600", "ee2b618e6b200e74982374682b3404fbb5c5905fb5386807d937d7e9de1ad7de"),
    DIRECTION_PATH: ("2217b70f75195812516ecc526b8274e8f1ad6db1a37f626e8d2229f91ff83858", "b7598d4ad0c0100fcb914ba28926fc274075fcc63d1f03e8329d1d73286659dc"),
    KO_PATH: ("37840cac7b72a1b4570dabf77316fef4ef7c9e0a0b630a883e2ece8e41ff3b43", "47d428b7d94593b4bc0558e0b8f1012442f8e3ecbee2957f9883ef965a25b058"),
    EN_PATH: ("f726184755c3e53df29c6f01d380a272cd4be44ed74cecd20ee034d9c6b9d0cd", "c77a6b7949a6e541ef0adc6014ebade9d2f3178c8ae2a7bf53fcd2d791032e5f"),
    RULES_PATH: ("9d9f63f24e516e2fb339d9c5c11e821074135d2dbd63848a7f8b6902b7a6b7cb", "7ecb85c1fee8d26b8bdd24e3c0b51ff3aba150f132f53a4503286fbca4d022af"),
    "docs/STATUS.md": ("16634560b9215fbe154ba3de8d0f3f4d251675adc7c7b8a2285bbfdc56108a6c", "9f9b62901e12942991f09990915aa211ce99c2f5a8334fdbe5e48ef9b89c9c66"),
    "docs/WORK_LOG.md": ("fd899a13cba60d286fd35336ad37817c784ded6e564958420fd001c53c419eab", "d79faf6bde46aff8fce2f20c1d422067e942f51836f07533f7a5ac43e6f1152c"),
}
COIN_BEFORE_COMMIT = SOURCE_AFTER_COMMIT
COIN_AFTER_COMMIT = "49124fd03067fc5f57d6f617610f82776f5e89e2"
COIN_TREES = (SOURCE_TREES[1], "a0212289915ca112998aa7cc715c6034d5161eca")
COIN_BLOBS = {
    "CLAUDE.md": ("c97790be4cbd7cc518d3a59454572f947f511005", "2eb97baf331687bff4d082c1801d1c671cb08ff1"),
    EVENT_PATHS[0]: ("091b2177b76c4772ec31bb52fd972f1d79606aae", "2cd6b8d6fbb16a1ac2ba4f1f93cdf7ec9d3a78d0"),
    EVENT_PATHS[1]: ("54a4cb0297476d8b8de736f6f611ccc7e1c309e4", "de814a5017499f929e83cee90d6b503c7420fc12"),
    EVENT_PATHS[2]: ("55ca2704d80c0b35c67ade8c6348049cca2bf0ab", "d2a5bcaae2c1117b408002bb1b95977f89dea9d8"),
    LEDGER_PATH: ("fddbaa537c335fa2be0f71ed8010833143673090", "d3cd1e81995a2f151c6ba2967d0b375e8318db56"),
    "docs/STATUS.md": ("4e0dd12817578c278142ec2e0307eeac348e399b", "9718252a053f998fc8ff3de7192c4dfbdcdce6bb"),
    "docs/WORK_LOG.md": ("29a7f2faa33ac05c54d20027d48aa74d4f9ffe0a", "43a429f7497a48203fa34841be6d99c564f3568f"),
    CURRENT_PATHS[0]: ("c1b6060f79854125fa08364fc7eea16497066922",) * 2,
    CURRENT_PATHS[1]: ("043da5ab11a40ba5d337530a340706b6a3f6fb78",) * 2,
    CURRENT_PATHS[2]: ("654e86adc00d942bce29f929e834cb53c6502c9f",) * 2,
}
COIN_HASHES = {
    "CLAUDE.md": ("e669f3e361be3852c710caf51746b424371f9fea339c65e8b16152ab750830e8", "7891086e102ebf4c0e4b4b798ed172cf384b89707caaf42f3b5dd001226a824b"),
    EVENT_PATHS[0]: ("f0d3545f18d0ab4a96598ba2005cdd0d50e7d2274a4c44f297b63cbe533a1f5b", "efe2cecba9034885653a2ae6f49d4933ba9dca7a7b1a43ccc923dcbbb385126b"),
    EVENT_PATHS[1]: ("81426bbb1eb30be1ae4f321bebd5369df32104e866e472b96ad4e3809ffa4795", "4271106a8a398dc4b56b671e89010f95f6aad5b32da2caedccb015cc499917ef"),
    EVENT_PATHS[2]: ("6f5c7eab456330855884bc5abe5b23b774d186e73739220fab1df671e5380693", "0d627f023e0630682453d5e130aac2ce01a3cf088d89c2eb2b49f35953011ef7"),
    LEDGER_PATH: ("095d5e46dca4c4ddabcfde1f255565ff18f6cc913997238ca22ea812c102f53d", "8de0b236d59eccd0f1b0a0c475a1fbf33ce3d32bf324e839148bc94f1a040661"),
    "docs/STATUS.md": ("9f9b62901e12942991f09990915aa211ce99c2f5a8334fdbe5e48ef9b89c9c66", "0930c7f1790c1166ea999f0a3deba888f470747596295ec1cbeab779ba24ad45"),
    "docs/WORK_LOG.md": ("d79faf6bde46aff8fce2f20c1d422067e942f51836f07533f7a5ac43e6f1152c", "f46604a7bf0a02a7462be4c8f85fa460a4206bad939e6195a4cc6f860078273f"),
    CURRENT_PATHS[0]: ("c056e24b20ad6e9711bce82eaaface23edc49d62d4598d397baf08ed5a7b2816",) * 2,
    CURRENT_PATHS[1]: ("56aa8c8320624223159f6d0034121aef0b8699ec51788c095b96627be2b3e863",) * 2,
    CURRENT_PATHS[2]: ("b589d1887d3660c9f3122e371ef5b28d06c258c23ddad18bfa6d8f5bef312ce0",) * 2,
}

# Exact replacements within the three selected leaves, not global text rewrites.
REPLACEMENTS = {
    "ko": ((("태호의 표정이 굳었다.", "태호의 목소리가 굳었다."),),
           (("30억까지의 까마득한 거리도.", "처음 세운 30억이라는 목표도."),),
           (("태호의 얼굴이 일그러진다.", "태호의 목소리가 날카로워진다."),)),
    "en": ((("Taeho's face hardened.", "Taeho's voice hardens."), ("he shot back.", "he shoots back.")),
           (("And beyond it — the impossible distance to 3 billion won.", "And with it — the original goal of 3 billion won."),),
           (("Taeho's face hardens.", "Taeho's voice turns sharp."),)),
    "ja": ((("テホの表情がこわばった。", "テホの声が硬くなった。"),),
           (("30億ウォンまでの、途方もない距離も。", "最初に掲げた30億ウォンという目標も。"),),
           (("テホの顔がゆがむ。", "テホの声が鋭くなる。"),)),
    "zh-CN": ((("Taeho的表情僵了", "Taeho的语气变得生硬"),),
              (("距离30亿韩元那遥不可及的路。", "最初定下的30亿韩元目标。"),),
              (("Taeho的脸却扭曲起来。", "Taeho的声音却尖锐起来。"),)),
    "zh-TW": ((("Taeho的表情僵住了。", "Taeho的語氣變得生硬。"),),
              (("離30億韓元那遙不可及的距離。", "最初訂下的30億韓元目標。"),),
              (("Taeho的臉扭曲了。", "Taeho的聲音變得尖銳。"),)),
}
SOURCE_TEXTS = (
    '태호의 목소리가 굳었다. "형은 항상 그래요"라는 말이 날아왔다.',
    '오랜만에 태호에게서 연락이 왔다. 잔뜩 들뜬 목소리.\n"형, 이건 진짜 확실해요. 내부 정보예요.\n'
    '이 코인 다음 주에 상장 호재 뜬다고요. 저 전세금 뺐어요.\n형도 지금 들어가요. 같이 인생 바꿔봐요."\n\n'
    '{name}의 통장 잔고가 떠오른다. 그리고 — 처음 세운 30억이라는 목표도.',
    '"태호야, 전세금까지 뺐다고? 그건 진짜 아니야."\n{name}은 진심으로 말렸다. 태호의 목소리가 날카로워진다.\n'
    '"형은 항상 그래요. 기회를 기회로 못 봐요.\n나중에 저 강남 갈 때 후회하지 마요."\n\n'
    '우정과 돈 사이, 무슨 말을 더 해야 할까.',
)
PHONE_RULE = {"logic": {}, "presentation": {
    "channel": "phone", "scene_location": "investment_phone", "remote_location": "taeho_current_location",
    "remote_actor": "taeho", "participants": ["player"], "portrait_role": "local", "nameplate_role": "hidden",
    "expected_background": "investment_phone", "expected_portrait": "player_tired"}}
VISUAL_RULE = {"id": "amb_coin_warn", "background": "investment_phone", "portrait": "player_tired"}

# Reuse the already reviewed typed Git-object and strict raw-token readers.
_git, _objects = prior._git, prior._objects
_apply, _token_edit = prior._apply, prior._token_edit


def require(ok: bool, message: str) -> None:
    if not ok:
        raise ValueError("ORDER-459 coin-call successor: " + message)


def _at(value: Any, path: tuple) -> Any:
    for token in path:
        value = value[token]
    return value


def _index(value: Any, event_id: str) -> int:
    exchange.row_index(value, "coin-call event overlay")
    indices = [i for i, row in enumerate(value) if row["id"] == event_id]
    require(len(indices) == 1, "missing/duplicate event selector: " + event_id)
    return indices[0]


def _event_inverse(current: bytes, before: bytes, locale: str) -> bytes:
    a, b = _Document(before), _Document(current)
    edits = []
    for (event, leaf_path), replacements in zip(SELECTORS, REPLACEMENTS[locale]):
        index = _index(a.value, event)
        require(_index(b.value, event) == index, "event array selector moved")
        path = (index, *leaf_path)
        expected = _at(a.value, path)
        require(isinstance(expected, str), "old event leaf is not text")
        for old, new in replacements:
            require(expected.count(old) == 1 and new not in expected, "old leaf semantic anchor differs")
            expected = expected.replace(old, new, 1)
        require(_at(b.value, path) == expected, "selected leaf differs from exact repair")
        edits.append(_token_edit(b, a, b, path))
    result = _apply(b, edits)
    require(result == before, "event bytes outside selected three leaves changed")
    return result


def coin_source_inverse(current: Mapping[str, bytes], before: Mapping[str, bytes]) -> dict[str, bytes]:
    """Pure exact source5 inverse; does not admit caller-provided Git evidence."""
    require(set(current) == set(before) == set(SOURCE_PRODUCT_PATHS), "source product path population")
    result = dict(current)
    for locale, path in (("ko", KO_PATH), ("en", EN_PATH)):
        result[path] = _event_inverse(current[path], before[path], locale)
    a, b = _Document(before[RULES_PATH]), _Document(current[RULES_PATH])
    expected = copy.deepcopy(a.value)
    require("amb_coin_warn" not in expected["events"], "phone rule already existed")
    expected["events"] = {key: value for event, rule in a.value["events"].items()
                          for key, value in ((event, rule), ("amb_coin_warn", PHONE_RULE))
                          if key == event or event == "amb_coin_00"}
    require(_ordered(b.value) == _ordered(expected), "phone rule changed outside exact presentation")
    keys = list(b.value["events"])
    require(keys.index("amb_coin_warn") == keys.index("amb_coin_00") + 1, "phone rule insertion moved")
    start, end = b.spans[("events", "amb_coin_00")][1], b.spans[("events", "amb_coin_warn")][1]
    result[RULES_PATH] = _apply(b, [(start, end, "")])
    a, b = _Document(before[VISUAL_PATH]), _Document(current[VISUAL_PATH])
    expected = copy.deepcopy(a.value)
    index = _index(expected["contracts"], "amb_coin_00") + 1
    require(not any(row["id"] == "amb_coin_warn" for row in expected["contracts"]), "visual rule already existed")
    expected["contracts"].insert(index, VISUAL_RULE)
    require(_ordered(b.value) == _ordered(expected), "visual rule changed outside exact local portrait")
    result[VISUAL_PATH] = _apply(b, [(b.spans[("contracts", index - 1)][1], b.spans[("contracts", index)][1], "")])
    a, b = _Document(before[DIRECTION_PATH]), _Document(current[DIRECTION_PATH])
    expected = copy.deepcopy(a.value)
    key = "event_intents"
    require(expected[key]["same_location"].count("amb_coin_warn") == 1
            and "amb_coin_warn" not in expected[key]["remote"], "old direction membership differs")
    expected[key]["same_location"].remove("amb_coin_warn")
    expected[key]["remote"].insert(expected[key]["remote"].index("amb_coin_00") + 1, "amb_coin_warn")
    edge = "amb_coin_00->amb_coin_warn"
    require(expected["transition_edges"][edge]["mode"] == "same_location", "old edge mode differs")
    expected["transition_edges"][edge]["mode"] = "remote"
    require(_ordered(b.value) == _ordered(expected), "direction changed outside exact remote edge/membership")
    paths = ((key, "same_location"), (key, "remote"), ("transition_edges", edge, "mode"))
    result[DIRECTION_PATH] = _apply(b, [_token_edit(b, a, b, path) for path in paths])
    require(result == dict(before), "source bytes outside exact source/phone repair changed")
    return result


def _ledger_inverse(current: bytes, before: bytes, after: bytes) -> bytes:
    a, b, doc = map(_Document, (before, after, current))
    value = doc.value
    require(value["accepted_sha256"] == exchange.digest(value["accepted"]), "current accepted checksum")
    require(len(value["batches"]) >= BATCH_INDEX + 3
            and _ordered(value["batches"][BATCH_INDEX:BATCH_INDEX + 3])
            == _ordered(b.value["batches"][BATCH_INDEX:BATCH_INDEX + 3]), "coin batches changed/removed/reordered")
    start, end = doc.spans[("batches", BATCH_INDEX - 1)][1], doc.spans[("batches", BATCH_INDEX + 2)][1]
    first, last = b.spans[("batches", BATCH_INDEX - 1)][1], b.spans[("batches", BATCH_INDEX + 2)][1]
    require(doc.text[start:end] == b.text[first:last], "coin batch raw changed")
    edits, accepted = [(start, end, "")], copy.deepcopy(value["accepted"])
    for locale in LOCALES:
        for event, path in SELECTORS:
            identifier = "events:" + event + ":" + exchange.pointer(path)
            field = ("accepted", locale, identifier)
            require(_ordered(_at(value, field)) == _ordered(_at(b.value, field)), "coin receipt changed/rolled back")
            edits.append(_token_edit(doc, a, b, field))
            accepted[locale][identifier] = copy.deepcopy(_at(a.value, field))
    start, end = doc.spans[("accepted_sha256",)]
    edits.append((start, end, _ordered(exchange.digest(accepted)).decode()))
    return _apply(doc, edits)


def coin_product_inverse(current: Mapping[str, bytes], before: Mapping[str, bytes]) -> dict[str, bytes]:
    require(set(current) == set(before) == set(PRODUCT_PATHS), "receipt product path population")
    result = {path: _event_inverse(current[path], before[path], locale) for locale, path in zip(LOCALES, EVENT_PATHS)}
    result[LEDGER_PATH] = _ledger_inverse(current[LEDGER_PATH], before[LEDGER_PATH], current[LEDGER_PATH])
    require(result == dict(before), "bytes outside exact translation/receipt correction changed")
    return result


def coin_call_comparison(snapshot: Mapping[str, bytes], before: Mapping[str, bytes],
                         after: Mapping[str, bytes]) -> dict[str, bytes]:
    """Undo nine whole event receipts only; preserve later UI appends verbatim."""
    require(set(snapshot) == set(before) == set(after) == set(CURRENT_PATHS), "exact UI4 comparison required")
    require(all(before[p] == after[p] for p in CURRENT_PATHS if p != LEDGER_PATH), "coin correction changed UI dictionary")
    result = dict(snapshot)
    result[LEDGER_PATH] = _ledger_inverse(snapshot[LEDGER_PATH], before[LEDGER_PATH], after[LEDGER_PATH])
    return result


def validate_coin_correction(before: Mapping[str, bytes], after: Mapping[str, bytes],
                             inventory: dict[str, Any]) -> dict[str, Any]:
    require(set(before) == set(after) == set(PRODUCT_PATHS), "exact translation/ledger4 required")
    old, new = ({p: _loads(raw) for p, raw in snapshot.items()} for snapshot in (before, after))
    a, b = old[LEDGER_PATH], new[LEDGER_PATH]
    require(len(a["batches"]) == BATCH_INDEX and len(b["batches"]) == BATCH_INDEX + 3
            and sum(map(len, a["accepted"].values())) == sum(map(len, b["accepted"].values())) == 41755,
            "existing nine corrections/three batches/zero coverage census differs")
    require(all(v["accepted_sha256"] == exchange.digest(v["accepted"]) for v in (a, b)), "accepted checksum mismatch")
    leaves = [exchange.Leaf("events", event, KO_PATH, path, text, "event_standard", lifecycle="shipping")
              for (event, path), text in zip(SELECTORS, SOURCE_TEXTS)]
    ids = {leaf.id for leaf in leaves}
    selected = sorted((leaf for leaf in inventory["leaves"] if leaf.id in ids), key=lambda leaf: leaf.id)
    require(_ordered([vars(leaf) for leaf in selected]) == _ordered([vars(leaf) for leaf in leaves]),
            "current exact Korean leaf/source/address/support differs")
    accepted, manifests = copy.deepcopy(a["accepted"]), {}
    for offset, (locale, relative) in enumerate(zip(LOCALES, EVENT_PATHS)):
        receipts, old_hashes = {}, {}
        for leaf, replacements in zip(leaves, REPLACEMENTS["ko"]):
            old_source = leaf.source
            for old_text, new_text in replacements:
                require(old_source.count(new_text) == 1, "Korean source inverse anchor differs")
                old_source = old_source.replace(new_text, old_text, 1)
            old_target = _at(old[relative][_index(old[relative], leaf.owner)], leaf.path)
            target = _at(new[relative][_index(new[relative], leaf.owner)], leaf.path)
            old_hashes[leaf.id] = exchange.digest(old_target)
            require(accepted[locale].get(leaf.id) == {"source_sha256": exchange.digest({"path": KO_PATH, "field": leaf.path, "ko": old_source}),
                                                     "target_sha256": exchange.digest(old_target)}, "old coin receipt differs")
            require(not exchange.translation_errors(leaf, locale, target), "coin translation contract failed")
            receipts[leaf.id] = {"source_sha256": leaf.source_sha256, "target_sha256": exchange.digest(target)}
        batch = b["batches"][BATCH_INDEX + offset]
        expected = {"order": "ORDER-458", "group": "events_correction", "roots": ["amb_coin_00", "amb_coin_warn"],
                    "source_leaves": 3, "prior_acceptance": "existing",
                    "before_target_sha256_by_locale": {locale: old_hashes},
                    "target_leaves_by_locale": {loc: 3 if loc == locale else 0 for loc in LOCALES},
                    "source_review": COIN_REVIEW, "machine_validation": "PASS", "rendered_review": "OPEN", "native_review": "OPEN"}
        require(isinstance(batch, dict) and set(batch) == set(expected) | {HEADERS_FIELD, "receipt_sha256_by_locale"}
                and all(_ordered(batch[k]) == _ordered(v) for k, v in expected.items())
                and all(isinstance(batch[k], dict) and set(batch[k]) == {locale}
                        for k in (HEADERS_FIELD, "receipt_sha256_by_locale")), "coin batch identity/locale/order differs")
        header = batch[HEADERS_FIELD][locale]
        require(header.get("source_revision") == COIN_BEFORE_COMMIT
                and re.fullmatch(r"[0-9a-f]{64}", str(header.get("source_manifest_sha256", ""))), "coin official revision/manifest differs")
        rebuilt = exchange.make_batch({**inventory, "source_manifest_sha256": header["source_manifest_sha256"]},
                                      locale, leaves, COIN_BEFORE_COMMIT, {relative: old[relative]},
                                      {leaf.owner: relative for leaf in leaves})[0]
        require(_ordered(header) == _ordered(rebuilt), "coin official source/target/header selection differs")
        receipt = {"batch": header, "state": "accepted_machine_validated", "native_review": "OPEN", "translations": receipts}
        require(batch["receipt_sha256_by_locale"][locale] == exchange.digest(receipt), "coin official receipt digest differs")
        accepted[locale].update(receipts)
        revision, manifest = header["source_revision"], header["source_manifest_sha256"]
        require(revision not in manifests or manifests[revision] == manifest, "coin export revision manifest differs between locales")
        manifests[revision] = manifest
    require(_ordered(b) == _ordered({**a, "accepted": accepted, "accepted_sha256": exchange.digest(accepted),
                                    "batches": [*a["batches"], *b["batches"][BATCH_INDEX:]]}), "unowned ledger value/order changed")
    coin_product_inverse(after, before)
    return {"ui_by_locale": {locale: 0 for locale in LOCALES}, "receipts": 0, "batches": 0,
            "corrections": 9, "correction_batches": 3, "first_receipts": 0, "source_manifests": manifests}


def _read_transition(root: Path, revisions: tuple, trees: tuple, blobs: dict, hashes: dict,
                     changed: set[str]) -> tuple[dict[str, bytes], dict[str, bytes]]:
    require(set(blobs) == set(hashes) and changed <= set(blobs), "transition pin population differs")
    paths = tuple(blobs)
    requests = [(c, c, "commit") for c in revisions] + [(t, t, "tree") for t in trees]
    requests += [(c + ":" + p, blobs[p][i], "blob") for p in paths for i, c in enumerate(revisions)]
    values = _objects(root, requests)
    for index in range(2):
        headers = values[index].split(b"\n\n", 1)[0].splitlines()
        require([h for h in headers if h.startswith(b"tree ")] == [b"tree " + trees[index].encode()], "exact transition tree differs")
        if index:
            require([h for h in headers if h.startswith(b"parent ")] == [b"parent " + revisions[0].encode()], "exact direct parent differs")
    require(_git(root, "diff", "--name-status", "-z", *revisions).split(b"\0")
            == [v for p in sorted(changed) for v in (b"M", p.encode())] + [b""], "exact transition changed-path population differs")
    before, after = {}, {}
    for index, path in enumerate(paths):
        old, new = values[4 + 2 * index:6 + 2 * index]
        require(tuple(hashlib.sha256(raw).hexdigest() for raw in (old, new)) == hashes[path], "immutable whole raw differs: " + path)
        require(path in changed or old == new, "protected transition path changed: " + path)
        before[path], after[path] = old, new
    return before, after


def _read_source_pair(root: Path) -> tuple[dict[str, bytes], dict[str, bytes]]:
    before, after = _read_transition(root, (SOURCE_BEFORE_COMMIT, SOURCE_AFTER_COMMIT), SOURCE_TREES,
                                     SOURCE_BLOBS, SOURCE_HASHES, set(SOURCE_BLOBS))
    coin_source_inverse({p: after[p] for p in SOURCE_PRODUCT_PATHS}, {p: before[p] for p in SOURCE_PRODUCT_PATHS})
    return before, after


def _read_pair(root: Path) -> tuple[dict[str, bytes], dict[str, bytes]]:
    before, after = _read_transition(root, (COIN_BEFORE_COMMIT, COIN_AFTER_COMMIT), COIN_TREES,
                                     COIN_BLOBS, COIN_HASHES, set(COIN_BLOBS) - set(CURRENT_PATHS[:-1]))
    coin_product_inverse({p: after[p] for p in PRODUCT_PATHS}, {p: before[p] for p in PRODUCT_PATHS})
    return before, after


def _current(root: Path, ancestor: str, expected: Mapping[str, bytes], blobs: Mapping[str, str]) -> dict[str, bytes]:
    head = _git(root, "rev-parse", "--verify", "HEAD^{commit}").decode().strip()
    require(re.fullmatch(r"[0-9a-f]{40}", head) is not None and set(expected) == set(blobs), "current identity/population differs")
    _git(root, "merge-base", "--is-ancestor", ancestor, head)
    paths = tuple(expected)
    ids = _git(root, "rev-parse", *(head + ":" + p for p in paths)).decode().splitlines()
    require(ids == [blobs[p] for p in paths], "current HEAD coin product blobs differ")
    raw = _objects(root, [(head + ":" + p, oid, "blob") for p, oid in zip(paths, ids)])
    result = dict(zip(paths, raw))
    require(all(result[p] == expected[p] == (root / p).read_bytes() for p in paths), "current coin disk/Git bytes differ")
    require(_git(root, "rev-parse", "--verify", "HEAD^{commit}").decode().strip() == head, "current candidate moved during coin proof")
    return result


def coin_source_predecessor(root: Path, inventory: dict[str, Any]) -> dict[str, bytes]:
    before, after = _read_source_pair(root)
    current = _current(root, SOURCE_AFTER_COMMIT, {p: after[p] for p in SOURCE_PRODUCT_PATHS},
                       {p: SOURCE_BLOBS[p][1] for p in SOURCE_PRODUCT_PATHS})
    require(exchange.digest(inventory["source_hashes"]) == inventory["source_manifest_sha256"]
            and all(inventory["source_hashes"].get(p) == hashlib.sha256(current[p]).hexdigest() for p in SOURCE_PATHS),
            "current coin source census/raw differs")
    return {p: before[p] for p in SOURCE_PATHS}


def coin_call_proof(root: Path, inventory: dict[str, Any]) -> tuple[dict, dict, dict]:
    _read_source_pair(root)
    before, after = _read_pair(root)
    change = validate_coin_correction({p: before[p] for p in PRODUCT_PATHS},
                                     {p: after[p] for p in PRODUCT_PATHS}, inventory)
    return ({p: before[p] for p in CURRENT_PATHS}, {p: after[p] for p in CURRENT_PATHS}, change)


def coin_call_current_events(root: Path = ROOT) -> dict[str, bytes]:
    """Fresh exact product8 current bytes, excluding appendable UI/ledger data."""
    _, source = _read_source_pair(root)
    _, targets = _read_pair(root)
    expected = {**{p: source[p] for p in SOURCE_PRODUCT_PATHS}, **{p: targets[p] for p in EVENT_PATHS}}
    blobs = {**{p: SOURCE_BLOBS[p][1] for p in SOURCE_PRODUCT_PATHS}, **{p: COIN_BLOBS[p][1] for p in EVENT_PATHS}}
    return _current(root, COIN_AFTER_COMMIT, expected, blobs)
