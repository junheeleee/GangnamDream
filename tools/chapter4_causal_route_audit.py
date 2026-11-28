#!/usr/bin/env python3
"""Audit the shipping Chapter 4 causal spine introduced by ORDER-131."""

from __future__ import annotations

import argparse
import copy
import hashlib
import json
import re
import sys
from pathlib import Path
from typing import Any


ROOT = Path(__file__).resolve().parents[1]
KO_DIR = ROOT / "content" / "events"
EN_DIR = ROOT / "content" / "events_en"
DIRECTOR = ROOT / "content" / "meta" / "event_director.json"
LIFECYCLE = ROOT / "content" / "meta" / "event_lifecycle.json"
MAIN_GAME = ROOT / "scenes" / "MainGame.gd"
STORY_MODE = ROOT / "scenes" / "StoryMode.gd"
EVENT_MANAGER = ROOT / "autoloads" / "EventManager.gd"
YEAR3_KO = KO_DIR / "arc_year3_drama.json"
YEAR3_EN = EN_DIR / "arc_year3_drama.json"
PERSON_DEAL_ID = "arc_36_unexpected_hand_person_deal"
PERSON_DEAL_LOCALES = ("ko", "en", "ja", "zh-CN", "zh-TW")
PERSON_DEAL_KEYS = ("daeun_divorced", "daeun_romance_started")

FATHER_P0_LOCALES = ("ko", "en", "ja", "zh-CN", "zh-TW")
FATHER_P0_ROOT = "arc_father_passing"
FATHER_P0_TERMINALS = (
    "arc_father_passing_hospital_room",
    "arc_father_passing_deal_morning",
)
FATHER_P0_KNOWN_KEYS = (
    "called_father_on_ktx",
    "did_not_call_father_on_ktx",
    "father_heard_gangnam_reason",
    "father_knew_i_came",
    "father_calls_often",
    "apologized_for_ignoring",
    "father_debt_felt",
)
FATHER_P0_CALLBACK = "callback_tried_to_go_father_echo"
FATHER_P0_YEAR_CLOSE = (
    "arc_y4_year_close_daeun",
    "arc_y4_year_close_unattached",
)

# The P0 unit may add only description_if_known.father_passed to these two
# localized W190 rows.  These fingerprints pin the original location, portrait,
# base prose, existing memory prefixes, three choices, effects, and results.
W190_PRESERVED_SHA256 = {
    "ko": {
        "arc_y4_year_close_daeun": "1cf2262deba8ce521b7efe7d97a81f93417b116b476c3eaed09c12d70dccc4d0",
        "arc_y4_year_close_unattached": "19a9abf51425bc2e11c52d86cad4e9cf383c2e6ad960d722c139b4bedad3dae7",
    },
    "en": {
        "arc_y4_year_close_daeun": "d21486841305cd7e5bf836e96fa7db2e74542c01ead20f435651aa078280d93e",
        "arc_y4_year_close_unattached": "7c34e21e676329e1a4be86192468467d057e27dfe98b7728b44f0063f44e98b5",
    },
    "ja": {
        "arc_y4_year_close_daeun": "a1d233746b280721ce777772a925fc8fd66127610e0b5ea0997f480c9d02da0b",
        "arc_y4_year_close_unattached": "ea99ba03c05ca70ad43faf01cd5b73933dda1995d8899ee8abaf673465839f2f",
    },
    "zh-CN": {
        "arc_y4_year_close_daeun": "6dc42817453f819b2ce43e8ec519d009144e02d1a1ef12bac8b6891f5265933e",
        "arc_y4_year_close_unattached": "1caeaca8d131313180734e32e336dc04db1cf7a295d2fad461f5a7ace2644a03",
    },
    "zh-TW": {
        "arc_y4_year_close_daeun": "1e9df176cec9ea97d911ec060f2927e0472d00b60777c0ed29d635e32e266cf3",
        "arc_y4_year_close_unattached": "0ade994149964945fac1bc9e13c56465cbb24fa57a1c2381e33d4b80684280c6",
    },
}

# Historical P0 fingerprints, retained as the before-image.  The approved
# direct-progress repair changes only the default within this old composite.
W188_PRESERVED_PROSE_SHA256 = {
    "ko": "b96336b211c7b9527ae3e04f177fbf3a7a87179f1aba8c02bb8050a2c1bdf139",
    "en": "5e0e093224bdd155fa379d900390393b8d3c333f483b554031dfcae060ddcec7",
    "ja": "c8fec88cfb56229142f7c4e5e8647e53a64a5f260323917d0d55f35313192df1",
    "zh-CN": "52373e8916ebc4cbb52c74a7584f19699703fddf813decd7946d020a5671d8a0",
    "zh-TW": "52cc4db306d51f10e9eeef8cb36d82e8f73663322c92cf4cadf7351f6042050e",
}
# Split from commit 6b9b09c, not recomputed from the edited product: neither
# moral branch nor any of the five older recollections belongs to this repair.
W188_PROTECTED_PROSE_SHA256 = {
    "ko": "8aa3ade52f43ab6aa436643b4567f18f7805df22f8f316b56aef1b98e1a516cd",
    "en": "f79bb4531bb81651b523fa6abcbda428413b8ec3b8d1e305697d840f081f43b9",
    "ja": "b02c38430afbef3e57e4d30cfcf581338afda145ab9e299193acadfb2cb51009",
    "zh-CN": "ed500d7e88df039642f744eff43adadfcfa71cc718058189166f819f804e41db",
    "zh-TW": "61b9d664b16c2b35eab81e294ae02b6cd55f5bc7dbb3cc99aca159dbbd74c4d6",
}
# Those two KTX recollections were repaired in the earlier P0 unit.  They are
# now accepted history too, not permission for this direct-progress edit.
W188_ACCEPTED_KTX_KNOWN_SHA256 = {
    "ko": "321318385aa6ca769be1be266415ff851afdab780548bc875c362c1656fc30f6",
    "en": "40fecb664a3b583f8efee0c4e653ba2f1533be76a3f995e2ec30fe233234062e",
    "ja": "a70456c6c346e6397239d872ea7248d31c2fc0d3636cdc65746a9ecce309bdfe",
    "zh-CN": "4ff3dd33d264e42c5104d29be8776e192f026bf0b190293c34e65d13716b3714",
    "zh-TW": "30b476b5aae11b36a27ccc1177453a78df9a99d8b07a3b6f8eb396fd1f58149c",
}
# Approved five-locale death-notice default after the official CJK import.
W188_ROOT_DEFAULT_SHA256 = {
    "ko": "007c3f36d4ca2b63b52cec6ecd1ccf408adbbd1253f0a3adb36eddc96b9224f7",
    "en": "a331039af81144ea23c951877cdeb605e87843e85ccbb35be1a87a69e8132f59",
    "ja": "d4fb1755539418248a15e33b23c5e608135f5a45f3b403d1ddd23d59de2520cb",
    "zh-CN": "d8dae57fac3815146a1b00c651d455c56da8a3774b92ebe9c31334645776b478",
    "zh-TW": "05b1e8051d56d1d4ee7cd02fc74fe7bf0fd1fe0eaa9251c9a96702ad5e83c5ef",
}
W188_DIRECT_EDGES = {
    "arc_father_passing_platform": "arc_father_passing_hospital_room",
    "arc_father_passing_deal_room": "arc_father_passing_deal_morning",
}
# Exact old 0/1 key shapes, moral-key shapes, results and edges.  Labels alone
# may be made action-shaped; old cold results must remain byte-for-byte prose.
W188_LEGACY_CHOICES_SHA256 = {
    "ko": "c749810192f7437cb3dc6e345b8850a523d59eda1eafcef33cf3201849d47c7a",
    "en": "59764bdf1ec65da5c4a795e10a01039d0719e34fbd70f41299d4cbec77283a3a",
    "ja": "06bd025d9afad89c63d6db3142c755de2a545d46cdae25d2602d3bf266084a97",
    "zh-CN": "abb67b67367b6b4a78655170e70a4762888036925b358ed9c20a481e4ef84f27",
    "zh-TW": "270be7f9f157257b04ce722f57469775b543886eee588ed5c4ab6aed0f8dba88",
}

SANGCHUL_LIVE_ID = "arc_sangchul_year3"
SANGCHUL_PASSED_ID = "arc_sangchul_year3_father_passed"

GROUPS = {
    "m39": (
        "arc_y4_three_promises",
        "arc_y4_three_promises_deal_only",
    ),
    "m41": (
        "arc_y4_body_witness",
        "arc_y4_body_witness_hyunsu",
    ),
    "m42": (
        "arc_y4_family_partner_collision",
        "arc_y4_family_commitment_none",
        "arc_y4_family_table_missed",
    ),
    "m44": (
        "arc_y4_father_call_answered_on_ktx",
        "arc_y4_father_call_missed_on_ktx",
    ),
    "m45": (
        "arc_y4_borrowed_name",
        "arc_y4_borrowed_name_self",
        "arc_y4_borrowed_name_document_gap",
    ),
    "m46": (
        "arc_y4_bill_night",
        "arc_y4_bill_night_unattached",
    ),
    "m47": (
        "arc_y4_father_final_contact_present",
        "arc_y4_father_final_contact_called",
        "arc_y4_father_final_contact_missed",
    ),
    "m48": (
        "arc_y4_year_close_daeun",
        "arc_y4_year_close_unattached",
    ),
}
PROMOTED = tuple(event_id for rows in GROUPS.values() for event_id in rows)
M40_EVENTS = (
    "arc_36_unexpected_hand",
    "arc_36_unexpected_hand_father_deal",
    "arc_36_unexpected_hand_person_deal",
)
NEW_EVENTS = (
    *M40_EVENTS[1:],
    "arc_y4_father_crisis_contact",
    "arc_y4_father_crisis_stabilized",
    "arc_y4_father_outcome_unknown",
)
EXPECTED_DIRECT = [
    145, 149, 153, 157, 161, 164, 167, 169, 174, 177,
    181, 185, 188, 190, 192,
]
# ORDER-134 adds the W240 responsibility signature after the existing W237
# Chapter-5 boss.  The Chapter-4 positions remain byte-for-byte explicit here.
EXPECTED_BOSSES = [45, 92, 140, 192, 237, 240]
EXPECTED_OWNER_IDS = {
    153: set(GROUPS["m39"]),
    157: set(M40_EVENTS),
    161: {"arc_36_body_signal"},
    164: set(GROUPS["m41"]),
    167: set(GROUPS["m42"]),
    174: {"arc_father_call_on_ktx_number"},
    177: set(GROUPS["m45"]),
    181: set(GROUPS["m46"]),
    185: {"arc_y4_father_crisis_contact"},
    188: {"arc_y4_father_crisis_stabilized", "arc_father_passing"},
    190: set(GROUPS["m48"]),
    192: {"arc_year4_close"},
}
PLACEHOLDER_RE = re.compile(r"\{[A-Za-z_][A-Za-z0-9_]*\}")


def load_events(directory: Path) -> dict[str, dict[str, Any]]:
    result: dict[str, dict[str, Any]] = {}
    for path in sorted(directory.glob("*.json")):
        raw = json.loads(path.read_text(encoding="utf-8"))
        rows = raw.get("events", []) if isinstance(raw, dict) else raw
        if not isinstance(rows, list):
            continue
        for row in rows:
            if isinstance(row, dict) and row.get("id"):
                event_id = str(row["id"])
                if event_id in result:
                    raise ValueError(f"duplicate event id {event_id}")
                result[event_id] = row
    return result


def load_event_order(path: Path) -> list[str]:
    raw = json.loads(path.read_text(encoding="utf-8"))
    rows = raw.get("events", []) if isinstance(raw, dict) else raw
    if not isinstance(rows, list):
        raise ValueError(f"event file root is not a list: {path}")
    return [
        str(row.get("id", ""))
        for row in rows
        if isinstance(row, dict) and row.get("id")
    ]


def canonical_sha256(value: Any) -> str:
    payload = json.dumps(
        value, ensure_ascii=False, sort_keys=True, separators=(",", ":"),
    ).encode("utf-8")
    return hashlib.sha256(payload).hexdigest()


def load_father_p0_events() -> dict[str, dict[str, dict[str, Any]]]:
    """Read the three exact owning files for every shipping locale."""
    result: dict[str, dict[str, dict[str, Any]]] = {}
    wanted_by_file = {
        "arc_drama.json": {
            FATHER_P0_ROOT,
            "arc_father_passing_platform",
            "arc_father_passing_deal_room",
            *FATHER_P0_TERMINALS,
        },
        "arc_year_close.json": set(FATHER_P0_YEAR_CLOSE),
        "callback_events_42.json": {
            FATHER_P0_CALLBACK,
            "callback_chose_money_father_echo",
        },
    }
    for locale in FATHER_P0_LOCALES:
        directory = "events" if locale == "ko" else "events_" + locale
        locale_events: dict[str, dict[str, Any]] = {}
        for filename, wanted in wanted_by_file.items():
            path = ROOT / "content" / directory / filename
            payload = json.loads(path.read_text(encoding="utf-8"))
            rows = payload.get("events", []) if isinstance(payload, dict) else payload
            if not isinstance(rows, list):
                raise ValueError(f"{locale}/{filename}: event root is not a list")
            for row in rows:
                if isinstance(row, dict) and str(row.get("id", "")) in wanted:
                    event_id = str(row["id"])
                    if event_id in locale_events:
                        raise ValueError(f"{locale}: duplicate P0 event {event_id}")
                    locale_events[event_id] = row
        expected = set().union(*wanted_by_file.values())
        if set(locale_events) != expected:
            raise ValueError(
                f"{locale}: P0 event set drifted: {sorted(locale_events)}"
            )
        result[locale] = locale_events
    return result


def choice_flags(choice: dict[str, Any]) -> set[str]:
    flags = choice.get("flags", [])
    return {str(flag) for flag in flags} if isinstance(flags, list) else set()


def placeholders(value: Any) -> set[str]:
    return set(PLACEHOLDER_RE.findall(json.dumps(value, ensure_ascii=False)))


def expression(choice: dict[str, Any]) -> bool:
    return str(choice.get("choice_kind", "")).strip() == "expression"


def stateful_keys(choice: dict[str, Any]) -> set[str]:
    keys = {
        "effects", "cast_effects", "flags", "items_add", "items_remove",
        "set_flag", "deferred_follow_up",
    }
    return {key for key in keys if choice.get(key) not in (None, {}, [])}


def assert_exactly_one(
    flags: set[str], allowed: set[str], owner: str, errors: list[str],
) -> None:
    actual = flags & allowed
    if len(actual) != 1:
        errors.append(f"{owner}: expected exactly one of {sorted(allowed)}, got {sorted(actual)}")


def source_function_block(source: str, function_name: str) -> str:
    marker = f"func {function_name}"
    if marker not in source:
        return ""
    return source.split(marker, 1)[1].split("\nfunc ", 1)[0]


def source_return_guard_blocks(
        source: str, function_name: str, event_id: str) -> list[str]:
    """Return the nearest outer `if` guard for each exact event return."""
    function = source_function_block(source, function_name)
    lines = function.splitlines()
    target = f'return "{event_id}"'
    blocks: list[str] = []
    for index, line in enumerate(lines):
        if target not in line:
            continue
        return_indent = len(line) - len(line.lstrip(" \t"))
        guard_index = -1
        for candidate in range(index - 1, -1, -1):
            candidate_line = lines[candidate]
            candidate_indent = len(candidate_line) - len(
                candidate_line.lstrip(" \t"))
            if candidate_line.lstrip().startswith("if ") \
                    and candidate_indent < return_indent:
                guard_index = candidate
                break
        if guard_index < 0:
            blocks.append("")
        else:
            blocks.append("\n".join(lines[guard_index:index + 1]))
    return blocks


def compact_source(source: str) -> str:
    return re.sub(r"\s+", " ", source.replace("\\", " ")).strip()


def load_person_deal_events() -> dict[str, dict[str, Any]]:
    """Read only the five owning files; overlay fallback must not hide a missing key."""
    result = {}
    for locale in PERSON_DEAL_LOCALES:
        directory = "events" if locale == "ko" else "events_" + locale
        path = ROOT / "content" / directory / "arc_chapter_themes.json"
        payload = json.loads(path.read_text(encoding="utf-8"))
        rows = payload.get("events", []) if isinstance(payload, dict) else payload
        if not isinstance(rows, list):
            raise ValueError(f"{locale}: themes event root is not a list")
        targets = [row for row in rows if isinstance(row, dict) and row.get("id") == PERSON_DEAL_ID]
        if len(targets) != 1:
            raise ValueError(f"{locale}: expected one {PERSON_DEAL_ID}")
        result[locale] = targets[0]
    return result


def validate_person_deal_content(events: dict[str, Any]) -> list[str]:
    """The one authored first-match map, not a new relationship interpreter."""
    errors = []
    if set(events) != set(PERSON_DEAL_LOCALES):
        errors.append("person_deal: exact five-locale population required")
    reference = events.get("ko", {})
    reference_text = reference.get("description", "") if isinstance(reference, dict) else ""
    reference_tokens = sorted(PLACEHOLDER_RE.findall(reference_text)) if isinstance(reference_text, str) else []
    for locale in PERSON_DEAL_LOCALES:
        event = events.get(locale)
        if not isinstance(event, dict) or event.get("id") != PERSON_DEAL_ID:
            errors.append(f"person_deal/{locale}: missing target event")
            continue
        description = event.get("description")
        known = event.get("description_if_known")
        if not isinstance(known, dict) or tuple(known) != PERSON_DEAL_KEYS:
            errors.append(f"person_deal/{locale}: DIK must order divorced before started, with no other keys")
            continue
        values = (description, known[PERSON_DEAL_KEYS[0]], known[PERSON_DEAL_KEYS[1]])
        if any(not isinstance(value, str) or not value.strip() for value in values):
            errors.append(f"person_deal/{locale}: empty/nontext body variant")
            continue
        if known["daeun_divorced"] != description:
            errors.append(f"person_deal/{locale}: divorced must equal the default clinic body")
        if known["daeun_romance_started"] == description:
            errors.append(f"person_deal/{locale}: started must have its distinct Daeun body")
        for field, value in zip(("description", *PERSON_DEAL_KEYS), values):
            if value.count("\n") != 2 or value.count("\n\n") != 1 \
                    or not all(part.strip() for part in value.split("\n\n")):
                errors.append(f"person_deal/{locale}/{field}: exact two paragraphs required")
            if sorted(PLACEHOLDER_RE.findall(value)) != reference_tokens:
                errors.append(f"person_deal/{locale}/{field}: source token population differs")
    return errors


def validate_person_deal_source(source: str, story_source: str) -> list[str]:
    errors = []

    def body(text: str, name: str) -> str:
        block = source_function_block(text, name)
        lines = block.splitlines()[1:]
        return compact_source("\n".join(line for line in lines if not line.lstrip().startswith("#")))

    partner = ('var f = GameState.flags '
               'if f.get("daeun_romance_started", false) and not f.get("daeun_divorced", false): '
               'return "daeun" '
               'if f.get("jiyeon_romance_started", false) and not f.get("jiyeon_left", false): '
               'return "jiyeon" return ""')
    if body(source, "_romance_partner_id") != partner:
        errors.append("person_deal: actual Main Daeun-first started&&!divorced predicate changed")
    live = ('for raw_flag_id in condition_key.split("&", false): '
            'var flag_id := str(raw_flag_id).strip_edges() '
            'if flag_id.is_empty() or not GameState.flags.get(flag_id, false): '
            'return false return true')
    if body(story_source, "_live_known_flag_condition_matches") != live:
        errors.append("person_deal: live StoryMode flag truthiness changed")
    dispatch = compact_source(source_function_block(story_source, "_known_flag_condition_matches"))
    if 'return _live_known_flag_condition_matches(condition_key)' not in dispatch:
        errors.append("person_deal: StoryMode no longer dispatches to the live flag consumer")
    first_match = ('var know_map = event.get("description_if_known", null) '
                   'if know_map is Dictionary: for condition_key in know_map.keys(): '
                   'if _known_flag_condition_matches(str(condition_key)): '
                   'know_variant = str(know_map[condition_key]) break')
    resolver = compact_source(source_function_block(story_source, "_resolved_story_description"))
    if first_match not in resolver:
        errors.append("person_deal: StoryMode DIK insertion-order first-match consumer changed")
    return errors


def validate_death_recovery_source(source: str) -> list[str]:
    errors: list[str] = []
    helper = source_function_block(source, "_father_death_is_monotonic")
    for required in (
        'f.get("father_passed", false)',
        'f.get("arc_father_passing_seen", false)',
        'GameState.get_cast_stage("father") == "passed"',
        'f["father_passed"] = true',
        'GameState.apply_cast_effect("father", {"stage": "passed"})',
    ):
        if required not in helper:
            errors.append(f"father death recovery helper missing {required}")

    router = source_function_block(source, "_next_arc_id")
    if "_father_death_is_monotonic(f, not preview_only)" not in router:
        errors.append("live/preview router does not share monotonic father evidence")
    if 'f.get("father_passed"' in router:
        errors.append("router bypasses monotonic father evidence with a raw flag read")

    causal = source_function_block(source, "_chapter_four_causal_arc_id")
    def exact_week_branch(week: int) -> str:
        match = re.search(
            rf"(?m)^([ \t]+)if t == {week}\b", causal)
        if match is None:
            return ""
        indent = re.escape(match.group(1))
        next_match = re.search(
            rf"(?m)^{indent}if t == \d+\b", causal[match.end():])
        end = match.end() + next_match.start() if next_match else len(causal)
        return causal[match.start():end]

    for week in (153, 167, 174, 181, 185):
        if "not father_is_passed" not in exact_week_branch(week):
            errors.append(
                f"W{week} can reopen a living-father scene after terminal evidence"
            )
    if "father_is_passed and missed_father" not in exact_week_branch(157):
        errors.append("W157 can repair Father's ward after terminal evidence")
    father_outcome = source_function_block(
        source, "_chapter_four_father_outcome_id")
    if "if father_is_passed" not in father_outcome:
        errors.append("W188 can replay a father outcome after terminal evidence")
    if 'f.get("father_passed"' in causal:
        errors.append("Chapter 4 causal router bypasses monotonic father evidence")
    for event_id in M40_EVENTS:
        if f'return "{event_id}"' in router:
            errors.append(
                f"legacy full router fabricates exact M40 target: {event_id}"
            )
    return errors


def validate_intro_route_source(source: str) -> list[str]:
    errors: list[str] = []
    contracts = (
        ("arc_intro_01_meal", 2, False, True),
        ("arc_intro_02_dad_call", 3, True, False),
    )
    for event_id, minimum_week, needs_father_guard, has_upper_bound in contracts:
        guards = source_return_guard_blocks(source, "_next_arc_id", event_id)
        if len(guards) != 1:
            errors.append(
                f"{event_id}: expected one legacy root return, got {len(guards)}"
            )
            continue
        guard = compact_source(guards[0])
        if re.search(rf"\bt\s*>=\s*{minimum_week}\b", guard) is None:
            errors.append(
                f"{event_id}: legacy intro root lost its W{minimum_week} lower bound"
            )
        upper_bound_present = re.search(r"\bt\s*<=\s*8\b", guard) is not None
        if has_upper_bound and not upper_bound_present:
            errors.append(
                f"{event_id}: legacy intro root can reopen after W8"
            )
        if not has_upper_bound and upper_bound_present:
            errors.append(
                f"{event_id}: valid receiptless legacy fallback is capped at W8"
            )
        if needs_father_guard and "not father_is_passed" not in guard:
            errors.append(
                f"{event_id}: direct root can call Father after terminal evidence"
            )
    return errors


def validate_late_father_content(
        ko: dict[str, dict[str, Any]],
        en: dict[str, dict[str, Any]],
        ko_year3_order: list[str],
        en_year3_order: list[str],
) -> list[str]:
    errors: list[str] = []
    intro_call = ko.get("arc_intro_02_dad_call", {})
    if "requires_living_father" not in intro_call.get("tags", []):
        errors.append("intro Dad call lost its living-Father hard-state tag")
    primary_bridge = ko.get("sangchul_becomes_primary", {})
    if primary_bridge.get("conditions", {}).get("no_flag") != "father_passed":
        errors.append(
            "Sangchul primary bridge lost its living-Father hard-state condition"
        )

    original = ko.get(SANGCHUL_LIVE_ID)
    passed = ko.get(SANGCHUL_PASSED_ID)
    en_original = en.get(SANGCHUL_LIVE_ID)
    en_passed = en.get(SANGCHUL_PASSED_ID)
    if original is None or passed is None or en_original is None or en_passed is None:
        missing = [
            event_id
            for event_id, ko_row, en_row in (
                (SANGCHUL_LIVE_ID, original, en_original),
                (SANGCHUL_PASSED_ID, passed, en_passed),
            )
            if ko_row is None or en_row is None
        ]
        errors.append(f"missing KO/EN Sangchul late variant: {missing}")
        return errors

    if "father_passed_variant" in original:
        errors.append(
            "Sangchul live event reintroduced the unsupported father_passed_variant root key"
        )

    if ko_year3_order != en_year3_order:
        errors.append("Sangchul Year 3 KO/EN event order drifted")
    for label, order in (("KO", ko_year3_order), ("EN", en_year3_order)):
        if not order or order[-1] != SANGCHUL_PASSED_ID:
            errors.append(
                f"{label} Sangchul passed variant must be appended to preserve existing indices"
            )
        if order.count(SANGCHUL_LIVE_ID) != 1 \
                or order.count(SANGCHUL_PASSED_ID) != 1:
            errors.append(f"{label} Sangchul live/passed ids must each occur once")

    for field in ("title", "description"):
        if passed.get(field) != original.get(field):
            errors.append(f"Sangchul passed variant changed the article {field}")
        if en_passed.get(field) != en_original.get(field):
            errors.append(f"Sangchul EN passed variant changed the article {field}")
    for field in ("background", "portrait", "category", "rarity"):
        if passed.get(field) != original.get(field):
            errors.append(f"Sangchul passed variant changed shared scene field {field}")
    if passed.get("weight") != 0 or passed.get("hidden") is not True \
            or passed.get("conditions", {}).get("min_turn") != 9999:
        errors.append("Sangchul passed variant lost its direct-only ingress contract")

    original_choices = original.get("choices", [])
    passed_choices = passed.get("choices", [])
    en_original_choices = en_original.get("choices", [])
    en_passed_choices = en_passed.get("choices", [])
    for label, choices in (
        ("KO live", original_choices), ("KO passed", passed_choices),
        ("EN live", en_original_choices), ("EN passed", en_passed_choices),
    ):
        if len(choices) != 3:
            errors.append(f"{label} Sangchul article must keep three choices")
    if any(len(choices) != 3 for choices in (
        original_choices, passed_choices, en_original_choices, en_passed_choices,
    )):
        return errors

    for index in (0, 2):
        if passed_choices[index] != original_choices[index]:
            errors.append(
                f"Sangchul passed choice {index + 1} no longer preserves live semantics"
            )
        if en_passed_choices[index] != en_original_choices[index]:
            errors.append(
                f"Sangchul EN passed choice {index + 1} no longer preserves live semantics"
            )

    live_call = original_choices[1]
    passed_call = passed_choices[1]
    if passed_call.get("effects") != live_call.get("effects"):
        errors.append("Sangchul passed choice 2 changed the non-cast consequence")
    if choice_flags(passed_call) != {"arc_sangchul_year3_seen"}:
        errors.append("Sangchul passed choice 2 must write only the common seen receipt")
    for forbidden_field in (
        "cast_effects", "follow_up_event", "deferred_follow_up", "set_flag",
    ):
        if passed_call.get(forbidden_field) not in (None, {}, []):
            errors.append(
                f"Sangchul passed choice 2 can revive Father via {forbidden_field}"
            )
    if "sangchul_news_told_father" in json.dumps(
            passed_call, ensure_ascii=False):
        errors.append("Sangchul passed choice 2 still claims Father was told")
    ko_result = str(passed_call.get("result_text", ""))
    en_result = str(en_passed_choices[1].get("result_text", ""))
    for marker in ("더는 연결될 번호가 아니었다", "전송되지 않았다"):
        if marker not in ko_result:
            errors.append(f"Sangchul passed choice 2 lost dead-safe KO fact: {marker}")
    for marker in ("no longer a number that could connect", "never sent"):
        if marker not in en_result:
            errors.append(f"Sangchul passed choice 2 lost dead-safe EN fact: {marker}")
    if placeholders(passed) != placeholders(en_passed):
        errors.append("Sangchul passed variant KO/EN placeholder drift")
    for index, en_choice in enumerate(en_passed_choices):
        for field in (
            "flags", "effects", "cast_effects", "follow_up_event",
            "choice_kind", "items_add", "items_remove", "set_flag",
            "deferred_follow_up",
        ):
            if field in en_choice:
                errors.append(
                    f"{SANGCHUL_PASSED_ID}.choices[{index}]: "
                    f"EN overlay owns gameplay field {field}"
                )
    return errors


def validate_event_manager_hard_state_source(source: str) -> list[str]:
    errors: list[str] = []
    if re.search(
        rf'"{re.escape(SANGCHUL_LIVE_ID)}"\s*:\s*'
        rf'"{re.escape(SANGCHUL_PASSED_ID)}"', source,
    ) is None:
        errors.append("EventManager lacks the explicit Sangchul father-passed mapping")

    death = source_function_block(source, "father_death_is_monotonic")
    for marker in (
        'GameState.flags.get("father_passed", false)',
        'GameState.flags.get(',
        '"arc_father_passing_seen", false)',
        'GameState.get_cast_stage("father") == "passed"',
    ):
        if marker not in death:
            errors.append(f"EventManager monotonic father helper missing {marker}")

    variant = source_function_block(source, "live_event_variant_id")
    for marker in (
        "father_death_is_monotonic()",
        "FATHER_PASSED_EVENT_VARIANTS.get(",
        "DataRegistry.find_event(variant_id).is_empty()",
        "return variant_id",
    ):
        if marker not in variant:
            errors.append(f"EventManager live variant router missing {marker}")

    hard_state = source_function_block(
        source, "_event_passes_hard_state_contracts")
    for marker in (
        'tags.has("requires_living_father")',
        '"father_passed"',
        "father_death_is_monotonic()",
    ):
        if marker not in hard_state:
            errors.append(f"EventManager hard-state contract missing {marker}")

    queue = source_function_block(source, "queue_event")
    for marker in (
        "live_event_variant_id(event_id)",
        "_event_passes_hard_state_contracts(event)",
    ):
        if marker not in queue:
            errors.append(f"EventManager live queue guard missing {marker}")
    pop = source_function_block(source, "get_next_event")
    for marker in (
        "live_event_variant_id(queued_id)",
        "_event_passes_hard_state_contracts(current_event)",
    ):
        if marker not in pop:
            errors.append(f"EventManager restored queue guard missing {marker}")
    eligibility = source_function_block(source, "_is_event_eligible")
    if not re.search(
        r"_event_passes_hard_state_contracts\(\s*"
        r"(?:event|eligibility_event)\s*\)",
        eligibility,
    ):
        errors.append("EventManager random eligibility bypasses hard-state contracts")
    deferred = source_function_block(source, "deferred_event_is_eligible")
    for marker in (
        "live_event_variant_id(event_id)",
        "_event_passes_hard_state_contracts(event)",
    ):
        if marker not in deferred:
            errors.append(f"EventManager deferred queue guard missing {marker}")
    bridge = source_function_block(source, "resolve_narrative_bridge")
    if "_event_passes_hard_state_contracts(event)" not in bridge:
        errors.append("EventManager direct narrative bridge bypasses hard-state contracts")
    return errors


def validate_w193_handoff_source(source: str) -> list[str]:
    errors: list[str] = []
    handoff = source_function_block(source, "_go_story_mode")
    for required in (
        'GameState.turn == 193',
        'first_event_id == "chapter_card_37"',
        'GameState.claim_deferred_event(',
        '"arc_37_reckoning", 193',
        'story_queue.append("arc_37_reckoning")',
    ):
        if required not in handoff:
            errors.append(f"W193 same-queue handoff missing {required}")
    return errors


def validate_story_queue_hard_state(
        ko: dict[str, dict[str, Any]], source: str) -> list[str]:
    errors: list[str] = []
    medication = ko.get("arc_father_medication", {})
    if "requires_living_father" not in medication.get("tags", []):
        errors.append("father medication lost its living-Father hard-state tag")
    loader = source_function_block(source, "_load_next_event")
    for marker in (
        "not _read_only_replay",
        "EventManager.live_event_variant_id(event_id)",
        "not EventManager._event_passes_hard_state_contracts(_current)",
        "_pending_restore_context.clear()",
        "while true:",
        "continue",
    ):
        if marker not in loader:
            errors.append(f"StoryMode hard-state queue guard missing {marker}")
    return errors


def validate_father_p0_content(
        localized: dict[str, dict[str, dict[str, Any]]],
        main_source: str) -> list[str]:
    """Pin W188 death-notice prose, live continuation and unchanged cold routes/writes."""
    errors: list[str] = []
    old_hour_markers = {
        "ko": ("한 시간 전에", "한 시간만 빨랐"),
        "en": ("an hour ago", "one hour earlier", "one hour before"),
        "ja": ("一時間前", "一時間でも早"),
        "zh-CN": ("一个小时前", "早一个小时"),
        "zh-TW": ("一個小時前", "早一個小時"),
    }
    gameplay_fields = {
        "flags", "effects", "cast_effects", "follow_up_event",
        "choice_kind", "items_add", "items_remove", "set_flag",
        "deferred_follow_up", "deferred_delay",
    }

    def choice_contract(choice: dict[str, Any]) -> dict[str, Any]:
        return {
            key: choice[key]
            for key in gameplay_fields
            if key in choice
        }

    expected_ko_choice_contracts = {
        FATHER_P0_ROOT: [
            {"choice_kind": "decision",
             "follow_up_event": "arc_father_passing_platform"},
            {"choice_kind": "decision",
             "follow_up_event": "arc_father_passing_deal_room"},
        ],
        "arc_father_passing_platform": [
            {"follow_up_event": "arc_father_passing_hospital_room"},
            {"follow_up_event": "arc_father_passing_deal_morning"},
            {"choice_kind": "decision",
             "follow_up_event": "arc_father_passing_hospital_room"},
        ],
        "arc_father_passing_deal_room": [
            {"follow_up_event": "arc_father_passing_hospital_room"},
            {"follow_up_event": "arc_father_passing_deal_morning"},
            {"choice_kind": "decision",
             "follow_up_event": "arc_father_passing_deal_morning"},
        ],
        "arc_father_passing_hospital_room": [{
            "effects": {"mental": -40, "tint": 10},
            "cast_effects": {"father": {"stage": "passed"}},
            "flags": [
                "arc_father_passing_seen", "father_passed",
                "tried_to_go_to_father",
            ],
        }],
        "arc_father_passing_deal_morning": [{
            "effects": {"mental": -25, "money": 5_000_000, "tint": -8},
            "cast_effects": {"father": {"stage": "passed"}},
            "flags": [
                "arc_father_passing_seen", "father_passed",
                "chose_money_over_father",
            ],
            "deferred_follow_up": "callback_chose_money_father_echo",
            "deferred_delay": 12,
        }],
        FATHER_P0_CALLBACK: [
            {"effects": {"mental": 6}, "flags": [], "follow_up_event": ""},
            {"effects": {"mental": -8}, "flags": [], "follow_up_event": ""},
        ],
    }

    if set(localized) != set(FATHER_P0_LOCALES):
        errors.append("father P0: exact five-locale population required")
        return errors
    for locale in FATHER_P0_LOCALES:
        events = localized.get(locale, {})
        root = events.get(FATHER_P0_ROOT, {})
        known = root.get("description_if_known", {})
        if not isinstance(known, dict) or tuple(known) != FATHER_P0_KNOWN_KEYS:
            errors.append(
                f"father P0/{locale}: W188 known order/population drifted"
            )
            continue
        preserved_known = {
            key: value for key, value in known.items()
            if key not in FATHER_P0_KNOWN_KEYS[:2]
        }
        preserved = {
            "description_if_moral": root.get("description_if_moral"),
            "other_known": preserved_known,
        }
        if canonical_sha256(preserved) != W188_PROTECTED_PROSE_SHA256[locale]:
            errors.append(
                f"father P0/{locale}: W188 moral/older-known prose changed"
            )
        accepted_ktx = {key: known.get(key) for key in FATHER_P0_KNOWN_KEYS[:2]}
        if canonical_sha256(accepted_ktx) != W188_ACCEPTED_KTX_KNOWN_SHA256[locale]:
            errors.append(f"father P0/{locale}: accepted KTX death-notice recollections changed")
        if canonical_sha256(root.get("description")) != W188_ROOT_DEFAULT_SHA256[locale]:
            errors.append(f"father P0/{locale}: W188 approved death-notice default changed")

        legacy_choices = {}
        for event_id, direct_edge in W188_DIRECT_EDGES.items():
            choices = events.get(event_id, {}).get("choices", [])
            if not isinstance(choices, list) or len(choices) != 3 \
                    or any(not isinstance(choice, dict) for choice in choices):
                errors.append(
                    f"father P0/{locale}/{event_id}: exact legacy 0/1 plus live 2 required"
                )
                continue
            legacy_choices[event_id] = []
            for choice in choices[:2]:
                locked = {
                    key: value for key, value in choice.items()
                    if key not in ("text", "text_if_moral")
                }
                locked["keys"] = sorted(choice)
                moral = choice.get("text_if_moral", {})
                locked["moral_keys"] = sorted(moral) if isinstance(moral, dict) else None
                legacy_choices[event_id].append(locked)
                labels = [choice.get("text"), *moral.values()] \
                    if isinstance(moral, dict) else []
                if not labels or any(not isinstance(label, str) or not label.strip()
                                     for label in labels):
                    errors.append(
                        f"father P0/{locale}/{event_id}: legacy action labels must remain populated"
                    )
            direct = choices[2]
            exact_keys = {"choice_kind", "text", "result_text", "follow_up_event"} \
                if locale == "ko" else {"text", "result_text"}
            if set(direct) != exact_keys:
                errors.append(
                    f"father P0/{locale}/{event_id}[2]: direct continuation exact keys changed"
                )
            if locale == "ko" and (
                    direct.get("choice_kind") != "decision"
                    or direct.get("follow_up_event") != direct_edge):
                errors.append(
                    f"father P0/ko/{event_id}[2]: direct continuation changed decision/edge"
                )
            if any(not isinstance(direct.get(key), str) or not direct[key].strip()
                   for key in ("text", "result_text")):
                errors.append(
                    f"father P0/{locale}/{event_id}[2]: empty direct continuation prose"
                )
        if canonical_sha256(legacy_choices) != W188_LEGACY_CHOICES_SHA256[locale]:
            errors.append(
                f"father P0/{locale}: legacy middle shape/result/edge contract changed"
            )
        for key in FATHER_P0_KNOWN_KEYS[:2]:
            body = known.get(key)
            if not isinstance(body, str) or not body.strip():
                errors.append(f"father P0/{locale}/{key}: missing death-notice body")
            elif any(marker.casefold() in body.casefold()
                     for marker in old_hour_markers[locale]):
                errors.append(
                    f"father P0/{locale}/{key}: obsolete preventable-hour fact remains"
                )
        if known.get(FATHER_P0_KNOWN_KEYS[0]) == known.get(FATHER_P0_KNOWN_KEYS[1]):
            errors.append(f"father P0/{locale}: the two KTX receipts collapsed")

        callback = events.get(FATHER_P0_CALLBACK, {})
        callback_text = json.dumps(callback, ensure_ascii=False)
        if any(marker.casefold() in callback_text.casefold()
               for marker in old_hour_markers[locale]):
            errors.append(
                f"father P0/{locale}: current-home callback still rewinds one hour"
            )
        hospital = events.get(FATHER_P0_TERMINALS[0], {})
        if any(marker.casefold() in json.dumps(hospital, ensure_ascii=False).casefold()
               for marker in old_hour_markers[locale]):
            errors.append(
                f"father P0/{locale}: hospital terminal still invents one-hour causality"
            )
        money_terminal = events.get(FATHER_P0_TERMINALS[1], {})
        money_body = str(money_terminal.get("description", ""))
        if money_body.count("{assets}") != 1:
            errors.append(
                f"father P0/{locale}: money terminal must compare one live assets token"
            )

        for event_id in FATHER_P0_YEAR_CLOSE:
            event = events.get(event_id, {})
            preserved_w190 = {
                key: event.get(key)
                for key in (
                    "background", "portrait", "description",
                    "description_memory_if_known", "choices",
                )
            }
            if canonical_sha256(preserved_w190) \
                    != W190_PRESERVED_SHA256[locale][event_id]:
                errors.append(
                    f"father P0/{locale}/{event_id}: old location/memory/three choices changed"
                )
            passed_map = event.get("description_if_known")
            if not isinstance(passed_map, dict) or tuple(passed_map) != ("father_passed",):
                errors.append(
                    f"father P0/{locale}/{event_id}: expected only father_passed DIK"
                )
                continue
            passed_body = passed_map.get("father_passed")
            if not isinstance(passed_body, str) or not passed_body.strip() \
                    or passed_body == event.get("description"):
                errors.append(
                    f"father P0/{locale}/{event_id}: missing distinct belongings body"
                )
            elif passed_body.count("\n\n") != 1 \
                    or placeholders(passed_body) != {"{name}"}:
                errors.append(
                    f"father P0/{locale}/{event_id}: passed body must be two paragraphs with name"
                )

        if locale == "ko":
            for event_id, expected in expected_ko_choice_contracts.items():
                choices = events.get(event_id, {}).get("choices", [])
                actual = [
                    choice_contract(choice)
                    for choice in (choices if isinstance(choices, list) else [])
                    if isinstance(choice, dict)
                ]
                if actual != expected:
                    errors.append(
                        f"father P0/ko/{event_id}: choice kind/effect/edge contract changed"
                    )
        else:
            for event_id, expected in expected_ko_choice_contracts.items():
                localized_choices = events.get(event_id, {}).get("choices", [])
                if not isinstance(localized_choices, list) \
                        or len(localized_choices) != len(expected):
                    errors.append(
                        f"father P0/{locale}/{event_id}: choice population drifted"
                    )
                for index, choice in enumerate(
                        localized_choices if isinstance(localized_choices, list) else []):
                    leaked = gameplay_fields & set(choice) \
                        if isinstance(choice, dict) else set()
                    if leaked:
                        errors.append(
                            f"father P0/{locale}/{event_id}[{index}]: "
                            f"overlay owns gameplay fields {sorted(leaked)}"
                        )

    ending = source_function_block(main_source, "_ending_cast_epilogue")
    for obsolete in (
        "아버지가 떠나던 밤, 나는 딜을 했다.",
        "The night Father passed, I closed a deal.",
        "마지막 기차를 탔지만 한 시간 늦었다.",
        "I caught the last train but was an hour too late.",
    ):
        if obsolete in ending:
            errors.append(f"father P0 ending still carries obsolete fact: {obsolete}")
    for required in (
        "사망 소식을 듣고도 그날은 거래를 택했다.",
        "I chose the deal even after I heard that Father had died.",
        "사망 소식을 들은 뒤 창원행 열차를 탔다.",
        "I took the train to Changwon after I heard that Father had died.",
    ):
        if required not in ending:
            errors.append(f"father P0 ending missing exact chronology: {required}")
    return errors


def validate_model(
    ko: dict[str, dict[str, Any]],
    en: dict[str, dict[str, Any]],
    director: dict[str, Any],
    lifecycle: dict[str, Any],
    source: str,
    story_source: str,
    event_manager_source: str,
    ko_year3_order: list[str],
    en_year3_order: list[str],
) -> list[str]:
    errors: list[str] = []
    errors.extend(validate_death_recovery_source(source))
    errors.extend(validate_intro_route_source(source))
    errors.extend(validate_late_father_content(
        ko, en, ko_year3_order, en_year3_order))
    errors.extend(validate_story_queue_hard_state(ko, story_source))
    errors.extend(validate_event_manager_hard_state_source(event_manager_source))
    errors.extend(validate_w193_handoff_source(source))
    if len(PROMOTED) != 19 or len(set(PROMOTED)) != 19:
        errors.append("promoted population must be exactly 19 unique events")

    for event_id in (*PROMOTED, *NEW_EVENTS):
        if event_id not in ko or event_id not in en:
            errors.append(f"missing KO/EN event: {event_id}")
            continue
        ko_event = ko[event_id]
        en_event = en[event_id]
        if len(ko_event.get("choices", [])) != len(en_event.get("choices", [])):
            errors.append(f"{event_id}: KO/EN choice count drift")
        if placeholders(ko_event) != placeholders(en_event):
            errors.append(f"{event_id}: KO/EN placeholder drift")
        for index, (ko_choice, en_choice) in enumerate(
            zip(ko_event.get("choices", []), en_event.get("choices", []))
        ):
            # English event files are text-only overlays. Gameplay state remains
            # authoritative in Korean and must not be duplicated into a locale.
            for field in (
                "flags", "effects", "cast_effects", "follow_up_event",
                "choice_kind", "items_add", "items_remove", "set_flag",
                "deferred_follow_up",
            ):
                if field in en_choice:
                    errors.append(
                        f"{event_id}.choices[{index}]: EN overlay owns gameplay field {field}"
                    )
    for event_id in PROMOTED:
        event = ko.get(event_id, {})
        if "author_only" in event.get("tags", []):
            errors.append(f"{event_id}: author_only tag remains")
        if event.get("weight") != 0 or event.get("hidden") is not True:
            errors.append(f"{event_id}: shipping ingress must preserve weight=0/hidden=true")
        if event.get("conditions", {}).get("min_turn") != 9999:
            errors.append(f"{event_id}: direct-only min_turn contract drift")

    author_only = set(lifecycle.get("author_only_event_ids", []))
    leaked = set(PROMOTED) & author_only
    if leaked:
        errors.append(f"promoted events remain in lifecycle author-only ledger: {sorted(leaked)}")

    full = director.get("full_run_pacing", {})
    chapter4_direct = [
        int(week) for week in full.get("decision_weeks", [])
        if 145 <= int(week) <= 192
    ]
    if chapter4_direct != EXPECTED_DIRECT:
        errors.append(f"Chapter 4 direct weeks drifted: {chapter4_direct}")
    if full.get("boss_weeks") != EXPECTED_BOSSES:
        errors.append(f"full boss weeks drifted: {full.get('boss_weeks')}")
    owners = full.get("commitment_event_owners", {})
    for week, expected_ids in EXPECTED_OWNER_IDS.items():
        actual_ids = {
            str(row.get("id", "")) if isinstance(row, dict) else str(row)
            for row in owners.get(str(week), [])
        }
        if actual_ids != expected_ids:
            errors.append(f"W{week} owner ids drifted: {sorted(actual_ids)}")
        for event_id in actual_ids:
            event = ko.get(event_id, {})
            choices = event.get("choices", [])
            if len(choices) < 2:
                errors.append(f"W{week}/{event_id}: owner needs at least two choices")
            if any(expression(choice) for choice in choices):
                errors.append(f"W{week}/{event_id}: owner choice is expression")
    if owners.get("169"):
        errors.append("M43 consequence owns a duplicate weekly action")

    if "func _chapter_four_causal_arc_id" not in source:
        errors.append("MainGame lacks the Chapter 4 causal router")
    for week in (153, 157, 161, 164, 167, 169, 174, 177, 181, 185, 188, 190):
        if f"t == {week}" not in source:
            errors.append(f"MainGame lacks exact W{week} route")
    if re.search(r"t\s*>=\s*176[^\n]{0,500}arc_father_passing", source):
        errors.append("legacy W176+ father death route remains")

    protected = {
        "arc_y4_three_promises_protected_father",
        "arc_y4_three_promises_protected_person",
        "arc_y4_three_promises_protected_deal",
    }
    missed = {
        "arc_y4_three_promises_missed_father",
        "arc_y4_three_promises_missed_person",
        "arc_y4_three_promises_missed_deal",
    }
    for event_id in GROUPS["m39"]:
        for index, choice in enumerate(ko[event_id]["choices"]):
            flags = choice_flags(choice)
            assert_exactly_one(flags, protected, f"{event_id}[{index}] protected", errors)
            if len(flags & missed) != 2:
                errors.append(f"{event_id}[{index}]: must name both forgone promises")
            if "arc_y4_three_promises_seen" not in flags:
                errors.append(f"{event_id}[{index}]: common receipt missing")

    m40_targets = {
        "arc_y4_missed_cost_repaired_father",
        "arc_y4_missed_cost_repaired_person",
        "arc_y4_missed_cost_repaired_deal",
    }
    m40_pairs = {
        "arc_36_unexpected_hand": {
            "arc_y4_missed_cost_repaired_father",
            "arc_y4_missed_cost_repaired_person",
        },
        "arc_36_unexpected_hand_father_deal": {
            "arc_y4_missed_cost_repaired_father",
            "arc_y4_missed_cost_repaired_deal",
        },
        "arc_36_unexpected_hand_person_deal": {
            "arc_y4_missed_cost_repaired_person",
            "arc_y4_missed_cost_repaired_deal",
        },
    }
    m40_pair_receipts = {
        "arc_36_unexpected_hand":
            "arc_y4_three_promises_missed_father&arc_y4_three_promises_missed_person",
        "arc_36_unexpected_hand_father_deal":
            "arc_y4_three_promises_missed_father&arc_y4_three_promises_missed_deal",
        "arc_36_unexpected_hand_person_deal":
            "arc_y4_three_promises_missed_person&arc_y4_three_promises_missed_deal",
    }
    all_pair_receipts = set(m40_pair_receipts.values())
    for event_id, expected_targets in m40_pairs.items():
        choices = ko.get(event_id, {}).get("choices", [])
        if len(choices) != 2:
            errors.append(f"{event_id}: M40 must offer the two actually missed targets")
            continue
        actual_targets: set[str] = set()
        for index, choice in enumerate(choices):
            flags = choice_flags(choice)
            if not {"arc_y4_missed_cost_seen", "arc_36_unexpected_hand_seen"}.issubset(flags):
                errors.append(f"{event_id}[{index}]: M40 common receipts missing")
            assert_exactly_one(flags, m40_targets, f"{event_id}[{index}] target", errors)
            actual_targets |= flags & m40_targets
            repaired_person = "arc_y4_missed_cost_repaired_person" in flags
            if ("accepted_grace" in flags) != repaired_person:
                errors.append(
                    f"{event_id}[{index}]: Chapter 5 callback must follow only a repaired person/clinic"
                )
            if expression(choice):
                errors.append(f"{event_id}[{index}]: M40 action became expression")
        if actual_targets != expected_targets:
            errors.append(
                f"{event_id}: M40 target pair drifted: {sorted(actual_targets)}"
            )
        ko_event = ko.get(event_id, {})
        en_event = en.get(event_id, {})
        ko_known = ko_event.get("description_if_known", {})
        en_known = en_event.get("description_if_known", {})
        ko_description = " ".join(
            [str(ko_event.get("description", ""))]
            + [str(value) for value in ko_known.values()]
        )
        en_description = " ".join(
            [str(en_event.get("description", ""))]
            + [str(value) for value in en_known.values()]
        )
        if any(token in ko_description for token in ("서면으로", "직접 찾아")) \
                or any(token in en_description for token in (
                    "in writing", "go in person", "close one window")):
            errors.append(
                f"{event_id}: prompt still advertises the removed third M40 action"
            )
        allowed_pair_receipt = m40_pair_receipts[event_id]
        stale_pair_receipts = (
            set(ko_known) | set(en_known)
        ) & (all_pair_receipts - {allowed_pair_receipt})
        if stale_pair_receipts:
            errors.append(
                f"{event_id}: prompt carries another M40 pair: "
                f"{sorted(stale_pair_receipts)}"
            )

    trust_crack = ko.get("arc_36_trust_crack", {})
    for index, choice in enumerate(trust_crack.get("choices", [])):
        if str(choice.get("follow_up_event", "")).strip() in M40_EVENTS:
            errors.append(
                f"arc_36_trust_crack[{index}]: M40 bypasses protected W157"
            )
    grace_writers = {
        event_id
        for event_id, event in ko.items()
        if any("accepted_grace" in choice_flags(choice) for choice in event.get("choices", []))
    }
    if grace_writers != {
        "arc_36_unexpected_hand", "arc_36_unexpected_hand_person_deal",
    }:
        errors.append(f"accepted_grace writer set drifted: {sorted(grace_writers)}")
    grace_echo = ko.get("cb_grace_echo", {})
    if grace_echo.get("conditions", {}).get("flag") != "accepted_grace":
        errors.append("Chapter 5 repaired-person callback lost its exact receipt gate")
    if "실제로 비울 수 있는 두 시각" not in str(grace_echo.get("description", "")):
        errors.append("Chapter 5 repaired-person callback no longer recalls the concrete M40 action")

    exclusive_contracts = (
        (GROUPS["m41"], "arc_y4_body_witness_seen", {
            "arc_y4_body_chose_care", "arc_y4_body_chose_deadline", "arc_y4_body_chose_alone",
        }),
        (GROUPS["m42"], "arc_y4_family_table_seen", {
            "arc_y4_family_attended_together", "arc_y4_family_attended_alone",
            "arc_y4_family_missed",
        }),
        (GROUPS["m48"], "arc_y4_year_close_boundary_seen", {
            "arc_y4_year_close_protected_relationship",
            "arc_y4_year_close_protected_body",
            "arc_y4_year_close_protected_family",
        }),
    )
    for event_ids, common, allowed in exclusive_contracts:
        for event_id in event_ids:
            for index, choice in enumerate(ko[event_id]["choices"]):
                flags = choice_flags(choice)
                if common not in flags:
                    errors.append(f"{event_id}[{index}]: common receipt {common} missing")
                assert_exactly_one(flags, allowed, f"{event_id}[{index}]", errors)
                if expression(choice):
                    errors.append(f"{event_id}[{index}]: actual action became expression")

    for event_id in (*GROUPS["m46"], "arc_y4_bill_night_jiyeon"):
        for index, choice in enumerate(ko[event_id]["choices"]):
            if index == 0 and choice.get("effects") != {"money": -487300}:
                errors.append(f"{event_id}[0]: hospital transfer must debit exactly 487300 won")
            if index != 0 and choice.get("effects") not in (None, {}):
                errors.append(f"{event_id}[{index}]: hospital debit leaked to another action")
            if ("arc_y4_bill_chose_payment" in choice_flags(choice)) != (index == 0):
                errors.append(f"{event_id}[{index}]: payment receipt moved from its authored option")
            flags = choice_flags(choice)
            if "arc_y4_bill_night_seen" not in flags:
                errors.append(f"{event_id}[{index}]: M46 common receipt missing")
            assert_exactly_one(
                flags, {"father_care_coordinated", "father_care_left_open"},
                f"{event_id}[{index}] care", errors,
            )

    ktx = ko.get("arc_father_call_on_ktx_number", {})
    ktx_choices = ktx.get("choices", [])
    expected_ktx = (
        {"arc_father_call_on_ktx_seen", "called_father_on_ktx"},
        {"arc_father_call_on_ktx_seen", "did_not_call_father_on_ktx"},
    )
    if len(ktx_choices) != 2:
        errors.append("KTX terminal must have two choices")
    else:
        for index, expected in enumerate(expected_ktx):
            if choice_flags(ktx_choices[index]) != expected:
                errors.append(f"KTX terminal choice {index} flag drift")
            if expression(ktx_choices[index]):
                errors.append(f"KTX terminal choice {index} became expression")
    for event_id in (
        "arc_father_call_on_ktx", "arc_father_call_on_ktx_memory",
        *GROUPS["m44"],
    ):
        if any(not expression(choice) for choice in ko.get(event_id, {}).get("choices", [])):
            errors.append(f"{event_id}: staging/result choice must be expression")
    ktx_ko = "\n".join(
        json.dumps(ko.get(event_id, {}), ensure_ascii=False)
        for event_id in ("arc_father_call_on_ktx", "arc_father_call_on_ktx_memory", *GROUPS["m44"])
    )
    if "창원행" in ktx_ko or "서울역을 떠난" in ktx_ko:
        errors.append("KTX prose reintroduced the opposite Seoul-to-Changwon direction")
    if "서울행" not in ktx_ko or "창원" not in ktx_ko:
        errors.append("KTX prose does not establish Changwon-to-Seoul travel")

    contact = ko.get("arc_y4_father_crisis_contact", {})
    contact_flags = {
        "father_crisis_contact_present",
        "father_crisis_contact_called",
        "father_crisis_contact_missed",
    }
    if len(contact.get("choices", [])) != 3:
        errors.append("M47 crisis contact gateway must have three choices")
    for index, choice in enumerate(contact.get("choices", [])):
        flags = choice_flags(choice)
        if "arc_y4_father_crisis_contact_seen" not in flags:
            errors.append(f"M47 gateway choice {index}: common receipt missing")
        assert_exactly_one(flags, contact_flags, f"M47 gateway choice {index}", errors)
        if {"father_passed", "father_crisis_stabilized"} & flags:
            errors.append(f"M47 gateway choice {index}: contact writes life outcome")
    contact_memory = contact.get("description_memory_if_known", {})
    ktx_receipts = ("called_father_on_ktx", "did_not_call_father_on_ktx")
    bill_receipts = (
        "arc_y4_bill_chose_payment",
        "arc_y4_bill_chose_body_care",
        "arc_y4_bill_chose_father_care",
    )
    for receipt in ktx_receipts:
        if receipt not in contact_memory:
            errors.append(f"M47 gateway does not recall M44 receipt {receipt}")
    memory_keys = list(contact_memory)
    for bill_receipt in bill_receipts:
        for ktx_receipt in ktx_receipts:
            combined = f"{bill_receipt}&{ktx_receipt}"
            if combined not in contact_memory:
                errors.append(f"M47 gateway loses simultaneous M44/M46 receipt {combined}")
                continue
            # StoryMode appends one ordinary memory paragraph. The combined
            # variant must therefore precede either single-receipt fallback.
            if (
                bill_receipt in memory_keys
                and memory_keys.index(combined) > memory_keys.index(bill_receipt)
            ) or (
                ktx_receipt in memory_keys
                and memory_keys.index(combined) > memory_keys.index(ktx_receipt)
            ):
                errors.append(f"M47 combined memory is shadowed: {combined}")
    for event_id in GROUPS["m47"]:
        for index, choice in enumerate(ko[event_id]["choices"]):
            if not expression(choice) or stateful_keys(choice):
                errors.append(f"{event_id}[{index}]: expression result mutates state")

    stable = ko.get("arc_y4_father_crisis_stabilized", {})
    for index, choice in enumerate(stable.get("choices", [])):
        flags = choice_flags(choice)
        if not {
            "arc_y4_father_crisis_stabilized_seen", "father_crisis_stabilized",
        }.issubset(flags):
            errors.append(f"stable choice {index}: durable receipts missing")
        if choice.get("cast_effects", {}).get("father", {}).get("stage") != "health_crisis":
            errors.append(f"stable choice {index}: father must remain in health_crisis")
    unknown = ko.get("arc_y4_father_outcome_unknown", {})
    if len(unknown.get("choices", [])) != 1:
        errors.append("damaged-save recovery must be one acknowledgement")
    elif choice_flags(unknown["choices"][0]) != {"arc_y4_father_outcome_unknown_seen"}:
        errors.append("damaged-save recovery invented a life outcome")

    outcome_block = source_function_block(source, "_chapter_four_father_outcome_id")
    for forbidden in contact_flags | {"visited_father", "rushed_to_father", "sent_money_instead"}:
        if f'"{forbidden}"' in outcome_block:
            errors.append(f"medical outcome illegally reads contact/nonmedical flag {forbidden}")
    for required in (
        "called_about_medication", "visited_for_medication",
        "sangchul_helped_with_father", "father_care_coordinated",
        "medical_evidence >= 2",
    ):
        if required not in outcome_block:
            errors.append(f"medical 2-of-3 contract missing {required}")
    if "father_is_passed" not in outcome_block:
        errors.append("father outcome bypasses normalized monotonic death evidence")

    death_writers = {
        event_id
        for event_id, event in ko.items()
        if any("father_passed" in choice_flags(choice) for choice in event.get("choices", []))
    }
    if death_writers != {
        "arc_father_passing_hospital_room", "arc_father_passing_deal_morning",
    }:
        errors.append(f"father death writer set drifted: {sorted(death_writers)}")

    # Preserved author-only manuscripts, not a live Chapter 4 romance route.
    jiyeon_reference_text = json.dumps(
        [ko[event_id] for event_id in (
            "arc_y4_three_promises_jiyeon_and_deal",
            "arc_y4_body_witness_jiyeon",
            "arc_y4_family_partner_collision_jiyeon",
            "arc_y4_bill_night_jiyeon",
            "arc_y4_year_close_jiyeon",
        )], ensure_ascii=False,
    )
    if "부산" not in jiyeon_reference_text:
        errors.append("Jiyeon reference manuscripts lost their Busan long-distance fact")
    document_gap = json.dumps(ko.get("arc_y4_borrowed_name_document_gap", {}), ensure_ascii=False)
    for term in ("대주", "원금", "만기", "담보"):
        if term not in document_gap:
            errors.append(f"M45 document gap omits {term}")
    en_document_gap = json.dumps(en.get("arc_y4_borrowed_name_document_gap", {}), ensure_ascii=False).lower()
    for term in ("lender", "principal", "maturity", "collateral"):
        if term not in en_document_gap:
            errors.append(f"M45 EN document gap omits {term}")

    forbidden_surface = re.compile(r"\bAP\b|행동력|여력\s*[0-9]|beat\s*(?:count|quota)", re.IGNORECASE)
    for event_id in (*PROMOTED, *NEW_EVENTS):
        if forbidden_surface.search(json.dumps(ko.get(event_id, {}), ensure_ascii=False)):
            errors.append(f"{event_id}: AP/quota language leaked into player prose")
    return errors


def run_person_deal_self_test() -> int:
    """Pure fixtures: no project import, disk read, Godot, or source mutation."""
    cases = 0

    def check(condition: bool, message: str) -> None:
        nonlocal cases
        cases += 1
        if not condition:
            raise AssertionError(message)

    clinic = "{name}, the clinic deadline has passed.\n\nThe review seat is cancelled."
    daeun = "{name}, Daeun's refrigerator photo is on the phone.\n\nThe review seat is cancelled."
    event = {"id": PERSON_DEAL_ID, "description": clinic,
             "description_if_known": {"daeun_divorced": clinic, "daeun_romance_started": daeun}}
    events = {locale: copy.deepcopy(event) for locale in PERSON_DEAL_LOCALES}
    check(not validate_person_deal_content(events), "valid five-locale person_deal fixture rejected")
    mutations = (
        ("map missing", lambda row: row.pop("description_if_known")),
        ("map non-dictionary", lambda row: row.update(description_if_known=[])),
        ("reversed precedence", lambda row: row.update(description_if_known={
            "daeun_romance_started": daeun, "daeun_divorced": clinic})),
        ("divorce key missing", lambda row: row["description_if_known"].pop("daeun_divorced")),
        ("started key missing", lambda row: row["description_if_known"].pop("daeun_romance_started")),
        ("unrelated gate", lambda row: row["description_if_known"].update(daeun_romance_blocked=clinic)),
        ("divorce body differs", lambda row: row["description_if_known"].update(daeun_divorced=daeun)),
        ("started body empty", lambda row: row["description_if_known"].update(daeun_romance_started=" ")),
        ("started body nontext", lambda row: row["description_if_known"].update(daeun_romance_started=1)),
        ("started body equals clinic", lambda row: row["description_if_known"].update(daeun_romance_started=clinic)),
        ("default body missing", lambda row: row.pop("description")),
        ("default body nontext", lambda row: row.update(description=False)),
        ("wrong event", lambda row: row.update(id="arc_36_unexpected_hand_father_deal")),
        ("missing token", lambda row: row["description_if_known"].update(
            daeun_romance_started=daeun.replace("{name}", "Minjun"))),
        ("duplicated token", lambda row: row["description_if_known"].update(
            daeun_romance_started=daeun.replace("{name}", "{name} {name}"))),
        ("paragraph removed", lambda row: row["description_if_known"].update(
            daeun_romance_started=daeun.replace("\n\n", " "))),
        ("paragraph added", lambda row: row["description_if_known"].update(
            daeun_romance_started=daeun + "\n\nExtra.")),
    )
    for label, mutate in mutations:
        changed = copy.deepcopy(events)
        mutate(changed["ko"])
        check(bool(validate_person_deal_content(changed)), "person_deal mutation not detected: " + label)
    for locale in PERSON_DEAL_LOCALES[1:]:
        changed = copy.deepcopy(events)
        changed[locale]["description_if_known"].pop("daeun_divorced")
        check(bool(validate_person_deal_content(changed)), locale + " overlay missing-key mutation not detected")
        changed = copy.deepcopy(events)
        changed[locale]["description_if_known"] = dict(reversed(list(event["description_if_known"].items())))
        check(bool(validate_person_deal_content(changed)), locale + " overlay order mutation not detected")
    changed = copy.deepcopy(events)
    changed.pop("zh-TW")
    check(bool(validate_person_deal_content(changed)), "missing target locale not detected")

    source = '''
func _romance_partner_id() -> String:
    var f = GameState.flags
    if f.get("daeun_romance_started", false) and not f.get("daeun_divorced", false):
        return "daeun"
    if f.get("jiyeon_romance_started", false) and not f.get("jiyeon_left", false):
        return "jiyeon"
    return ""
func next(): pass
'''
    story = '''
func _known_flag_condition_matches(condition_key: String) -> bool:
    if _read_only_replay:
        return _gallery_selector_matches(str(_current.get("id", "")), condition_key)
    return _live_known_flag_condition_matches(condition_key)
func _live_known_flag_condition_matches(condition_key: String) -> bool:
    for raw_flag_id in condition_key.split("&", false):
        var flag_id := str(raw_flag_id).strip_edges()
        if flag_id.is_empty() or not GameState.flags.get(flag_id, false):
            return false
    return true
func _resolved_story_description(event: Dictionary) -> String:
    var know_map = event.get("description_if_known", null)
    if know_map is Dictionary:
        for condition_key in know_map.keys():
            if _known_flag_condition_matches(str(condition_key)):
                know_variant = str(know_map[condition_key])
                break
func next(): pass
'''
    check(not validate_person_deal_source(source, story), "valid Main/StoryMode source fixtures rejected")
    source_mutations = (
        source.replace(' and not f.get("daeun_divorced", false)', ''),
        source.replace('f.get("daeun_romance_started", false)', 'f.get("daeun_married", false)'),
        source.replace('f.get("daeun_romance_started", false)',
                       '(f.get("daeun_romance_started", false) or f.get("daeun_married", false))'),
        source.replace('and not f.get("daeun_divorced", false)',
                       'and not f.get("daeun_divorced", false) and not f.get("daeun_romance_blocked", false)'),
        source.replace('var f = GameState.flags', 'var f = saved_flags'),
        source.replace('return "daeun"', 'return "jiyeon"'),
    )
    for changed_source in source_mutations:
        check(bool(validate_person_deal_source(changed_source, story)), "Main predicate mutation not detected")
    story_mutations = (
        story.replace('break', 'continue'),
        story.replace('know_map.keys()', 'sorted_keys'),
        story.replace('GameState.flags.get(flag_id, false)', 'GameState.flags.get(flag_id, false) == true'),
        story.replace('return _live_known_flag_condition_matches(condition_key)', 'return true'),
    )
    for changed_story in story_mutations:
        check(bool(validate_person_deal_source(source, changed_story)), "StoryMode first-match/truthiness mutation not detected")
    return cases


def run_father_direct_mutation_self_test() -> int:
    """Source-bound negatives for the approved live-2/legacy-0/1 separation."""
    localized = load_father_p0_events()
    main_source = MAIN_GAME.read_text(encoding="utf-8")
    baseline = validate_father_p0_content(localized, main_source)
    if baseline:
        raise AssertionError(f"father direct baseline invalid: {baseline}")
    cases = 0

    def reject(mutated: dict, label: str) -> None:
        nonlocal cases
        if not validate_father_p0_content(mutated, main_source):
            raise AssertionError(f"father direct accepted mutation: {label}")
        cases += 1

    for locale in FATHER_P0_LOCALES:
        for event_id in W188_DIRECT_EDGES:
            for index in (0, 1):
                for field, value in (("result_text", "changed old cold result"),
                                     ("effects", {})):
                    bad = copy.deepcopy(localized)
                    bad[locale][event_id]["choices"][index][field] = value
                    reject(bad, f"{locale}/{event_id}/legacy {index}/{field}")
                bad = copy.deepcopy(localized)
                bad[locale][event_id]["choices"][index]["text_if_moral"].pop("black")
                reject(bad, f"{locale}/{event_id}/legacy {index}/moral shape")
                bad = copy.deepcopy(localized)
                bad[locale][event_id]["choices"][index]["text"] = ""
                reject(bad, f"{locale}/{event_id}/legacy {index}/empty label")
            for field, value in (("effects", {}), ("text_if_moral", {}),
                                 ("text", ""), ("result_text", ""),
                                 ("result_text", ["not prose"])):
                bad = copy.deepcopy(localized)
                bad[locale][event_id]["choices"][2][field] = value
                reject(bad, f"{locale}/{event_id}/direct 2/{field}")
            bad = copy.deepcopy(localized)
            bad[locale][event_id]["choices"].pop()
            reject(bad, f"{locale}/{event_id}/remove direct 2")
            bad = copy.deepcopy(localized)
            bad[locale][event_id]["choices"].append(
                copy.deepcopy(bad[locale][event_id]["choices"][2]))
            reject(bad, f"{locale}/{event_id}/extra choice")
            if locale == "ko":
                for field, value in (("follow_up_event", FATHER_P0_ROOT),
                                     ("choice_kind", "expression")):
                    bad = copy.deepcopy(localized)
                    bad[locale][event_id]["choices"][2][field] = value
                    reject(bad, f"{locale}/{event_id}/direct 2/{field}")
                bad = copy.deepcopy(localized)
                bad[locale][event_id]["choices"][0]["follow_up_event"] = FATHER_P0_ROOT
                reject(bad, f"{locale}/{event_id}/legacy edge")
            else:
                for field, value in (("follow_up_event", FATHER_P0_ROOT),
                                     ("choice_kind", "decision")):
                    bad = copy.deepcopy(localized)
                    bad[locale][event_id]["choices"][2][field] = value
                    reject(bad, f"{locale}/{event_id}/overlay gameplay {field}")
        for field in ("description", "description_if_moral", "description_if_known"):
            bad = copy.deepcopy(localized)
            root = bad[locale][FATHER_P0_ROOT]
            if field == "description":
                root[field] += "\n\nBecause one choice meant this and the other meant that."
            elif field == "description_if_moral":
                key = next(iter(root[field]))
                root[field][key] += "changed protected moral prose"
            else:
                root[field][FATHER_P0_KNOWN_KEYS[2]] += "changed protected recollection"
            reject(bad, f"{locale}/root {field} prose pin")
        for key in FATHER_P0_KNOWN_KEYS[:2]:
            bad = copy.deepcopy(localized)
            bad[locale][FATHER_P0_ROOT]["description_if_known"][key] += "changed accepted KTX prose"
            reject(bad, f"{locale}/accepted KTX {key} prose pin")
    return cases


def run_self_test() -> int:
    cases = 0

    def check(condition: bool, message: str) -> None:
        nonlocal cases
        cases += 1
        if not condition:
            raise AssertionError(message)

    base_event = {
        "choices": [{
            "choice_kind": "expression",
            "result_text": "receipt",
        }]
    }
    check(
        not stateful_keys(base_event["choices"][0]),
        "state-free expression fixture rejected",
    )
    mutated = copy.deepcopy(base_event)
    mutated["choices"][0]["flags"] = ["father_passed"]
    check(
        bool(stateful_keys(mutated["choices"][0])),
        "expression mutation was not detected",
    )

    allowed = {"a", "b", "c"}
    errors: list[str] = []
    assert_exactly_one({"a"}, allowed, "positive", errors)
    check(not errors, errors[0] if errors else "exclusive positive fixture rejected")
    assert_exactly_one({"a", "b"}, allowed, "negative", errors)
    check(bool(errors), "exclusive receipt mutation was not detected")

    source = """
func _chapter_four_father_outcome_id(f):
    var medication_called = f.get("called_about_medication", false)
    var medication_visited = f.get("visited_for_medication", false)
    var care = f.get("father_care_coordinated", false)
    if f.get("sangchul_helped_with_father", false): pass
    if medical_evidence >= 2: pass
    if GameState.get_cast_stage("father") == "passed": pass
func next(): pass
"""
    block = source.split("func _chapter_four_father_outcome_id", 1)[1].split("\nfunc ", 1)[0]
    check(
        "father_crisis_contact_called" not in block,
        "fixture contact leaked into medical evidence",
    )
    mutated_source = source.replace(
        'var care = f.get("father_care_coordinated", false)',
        'var care = f.get("father_crisis_contact_called", false)',
    )
    mutated_block = mutated_source.split(
        "func _chapter_four_father_outcome_id", 1
    )[1].split("\nfunc ", 1)[0]
    check(
        "father_crisis_contact_called" in mutated_block,
        "contact-evidence mutation was not detected",
    )

    recovery_source = '''
func _father_death_is_monotonic(f, normalize=false):
    var death = f.get("father_passed", false) or f.get("arc_father_passing_seen", false) or GameState.get_cast_stage("father") == "passed"
    if death and normalize:
        f["father_passed"] = true
        GameState.apply_cast_effect("father", {"stage": "passed"})
func _chapter_four_father_outcome_id(f, father_is_passed):
    if father_is_passed: return ""
func _chapter_four_causal_arc_id(t, f, father_is_passed):
    if t == 153 and not father_is_passed: pass
    if t == 157:
        var missed_father = true
        if father_is_passed and missed_father: return ""
    if t == 167 and not father_is_passed: pass
    if t == 174 and not father_is_passed: pass
    if t == 181 and not father_is_passed: pass
    if t == 185 and not father_is_passed: pass
func _next_arc_id(at_turn=-1, preview_only=false):
    var father_is_passed = _father_death_is_monotonic(f, not preview_only)
'''
    check(
        not validate_death_recovery_source(recovery_source),
        "valid death-recovery fixture was rejected",
    )
    mutated_recovery = recovery_source.replace('f["father_passed"] = true', "pass")
    check(
        bool(validate_death_recovery_source(mutated_recovery)),
        "death-recovery mutation was not detected",
    )
    mutated_bill = recovery_source.replace(
        "if t == 181 and not father_is_passed: pass",
        "if t == 181: pass",
    )
    check(
        bool(validate_death_recovery_source(mutated_bill)),
        "W181 father-resurrection mutation was not detected",
    )
    fabricated_legacy = recovery_source.replace(
        "var father_is_passed = _father_death_is_monotonic(f, not preview_only)",
        "var father_is_passed = _father_death_is_monotonic(f, not preview_only)\n"
        "    return \"arc_36_unexpected_hand\"",
    )
    check(
        bool(validate_death_recovery_source(fabricated_legacy)),
        "legacy M40 target fabrication was not detected",
    )

    handoff_source = '''
func _go_story_mode(event_ids):
    var first_event_id = "chapter_card_37"
    var story_queue = event_ids.duplicate()
    if GameState.turn == 193 and first_event_id == "chapter_card_37":
        var claim = GameState.claim_deferred_event("arc_37_reckoning", 193)
        if not claim.is_empty():
            story_queue.append("arc_37_reckoning")
'''
    check(
        not validate_w193_handoff_source(handoff_source),
        "valid W193 same-queue fixture was rejected",
    )
    mutated_handoff = handoff_source.replace("GameState.turn == 193", "GameState.turn == 194")
    check(
        bool(validate_w193_handoff_source(mutated_handoff)),
        "W193 same-queue mutation was not detected",
    )

    story_ko = {
        "arc_father_medication": {"tags": ["requires_living_father"]},
    }
    story_source = '''
func _load_next_event():
    while true:
        var event_id = "arc_sangchul_year3"
        var live_event_id = EventManager.live_event_variant_id(event_id)
        if not _read_only_replay and not EventManager._event_passes_hard_state_contracts(_current):
            _pending_restore_context.clear()
            continue
        break
'''
    check(
        not validate_story_queue_hard_state(story_ko, story_source),
        "valid StoryMode hard-state fixture was rejected",
    )
    mutated_story = story_source.replace("not _read_only_replay", "_read_only_replay")
    check(
        bool(validate_story_queue_hard_state(story_ko, mutated_story)),
        "StoryMode live/replay guard mutation was not detected",
    )
    story_without_mapping = story_source.replace(
        "EventManager.live_event_variant_id(event_id)", "event_id")
    check(
        bool(validate_story_queue_hard_state(story_ko, story_without_mapping)),
        "StoryMode restored-variant mutation was not detected",
    )
    recursive_story = story_source.replace(
        "            continue", "            _load_next_event()")
    check(
        bool(validate_story_queue_hard_state(story_ko, recursive_story)),
        "StoryMode recursive stale-queue mutation was not detected",
    )

    intro_source = '''
func _next_arc_id(t, father_is_passed):
    if t >= 2 and t <= 8 and ready:
        return "arc_intro_01_meal"
    if t >= 3 and not father_is_passed and meal_seen:
        return "arc_intro_02_dad_call"
'''
    check(
        not validate_intro_route_source(intro_source),
        "valid bounded intro fixture was rejected",
    )
    unbounded_meal = intro_source.replace(
        "t >= 2 and t <= 8 and ready", "t >= 2 and ready")
    check(
        bool(validate_intro_route_source(unbounded_meal)),
        "late intro-meal reopening mutation was not detected",
    )
    bounded_dad = intro_source.replace(
        "t >= 3 and not father_is_passed",
        "t >= 3 and t <= 8 and not father_is_passed",
    )
    check(
        bool(validate_intro_route_source(bounded_dad)),
        "receiptless legacy Dad fallback cap mutation was not detected",
    )
    unguarded_dad = intro_source.replace(
        " and not father_is_passed and meal_seen", " and meal_seen")
    check(
        bool(validate_intro_route_source(unguarded_dad)),
        "dead-Father intro-call mutation was not detected",
    )

    live_choices = [
        {
            "text": "move on", "effects": {"mental": 4},
            "flags": ["arc_sangchul_year3_seen"], "result_text": "closed",
        },
        {
            "text": "call Father", "effects": {"mental": 10, "tint": 4},
            "flags": ["arc_sangchul_year3_seen", "sangchul_news_told_father"],
            "cast_effects": {"father": {"affinity": 5}},
            "result_text": "Father answered.",
        },
        {
            "text": "mixed feelings", "effects": {"mental": -3},
            "flags": [
                "arc_sangchul_year3_seen", "sangchul_complicated_feelings",
            ],
            "result_text": "Both are true.",
        },
    ]
    passed_choices = [
        copy.deepcopy(live_choices[0]),
        {
            "text": "open Father's number",
            "effects": {"mental": 10, "tint": 4},
            "flags": ["arc_sangchul_year3_seen"],
            "result_text": (
                "그 번호는 더는 연결될 번호가 아니었다. 링크는 전송되지 않았다."
            ),
        },
        copy.deepcopy(live_choices[2]),
    ]
    en_live_choices = [
        {"text": "move on", "result_text": "closed"},
        {"text": "call Father", "result_text": "Father answered."},
        {"text": "mixed feelings", "result_text": "Both are true."},
    ]
    en_passed_choices = [
        copy.deepcopy(en_live_choices[0]),
        {
            "text": "open Father's number",
            "result_text": (
                "This was no longer a number that could connect. The link was never sent."
            ),
        },
        copy.deepcopy(en_live_choices[2]),
    ]
    shared = {
        "title": "article", "description": "article for {name}",
        "background": "street", "portrait": "player_normal",
        "category": "story", "rarity": "story",
    }
    content_ko = {
        "arc_intro_02_dad_call": {"tags": ["requires_living_father"]},
        "sangchul_becomes_primary": {
            "conditions": {"no_flag": "father_passed"},
        },
        SANGCHUL_LIVE_ID: {**shared, "choices": live_choices},
        SANGCHUL_PASSED_ID: {
            **shared, "weight": 0, "hidden": True,
            "conditions": {"min_turn": 9999}, "choices": passed_choices,
        },
    }
    content_en = {
        SANGCHUL_LIVE_ID: {
            "title": "article", "description": "article for {name}",
            "choices": en_live_choices,
        },
        SANGCHUL_PASSED_ID: {
            "title": "article", "description": "article for {name}",
            "choices": en_passed_choices,
        },
    }
    year3_order = [SANGCHUL_LIVE_ID, "preserved_event", SANGCHUL_PASSED_ID]
    check(
        not validate_late_father_content(
            content_ko, content_en, year3_order, year3_order),
        "valid Sangchul father-passed fixture was rejected",
    )
    missing_intro_tag = copy.deepcopy(content_ko)
    missing_intro_tag["arc_intro_02_dad_call"]["tags"] = []
    check(
        bool(validate_late_father_content(
            missing_intro_tag, content_en, year3_order, year3_order)),
        "intro Dad hard-state tag mutation was not detected",
    )
    missing_bridge_guard = copy.deepcopy(content_ko)
    missing_bridge_guard["sangchul_becomes_primary"]["conditions"].clear()
    check(
        bool(validate_late_father_content(
            missing_bridge_guard, content_en, year3_order, year3_order)),
        "Sangchul bridge hard-state mutation was not detected",
    )
    unsupported_root = copy.deepcopy(content_ko)
    unsupported_root[SANGCHUL_LIVE_ID]["father_passed_variant"] = SANGCHUL_PASSED_ID
    check(
        bool(validate_late_father_content(
            unsupported_root, content_en, year3_order, year3_order)),
        "unsupported event-root mapping mutation was not detected",
    )
    inserted_order = [SANGCHUL_LIVE_ID, SANGCHUL_PASSED_ID, "preserved_event"]
    check(
        bool(validate_late_father_content(
            content_ko, content_en, inserted_order, inserted_order)),
        "non-appended variant mutation was not detected",
    )
    changed_choice = copy.deepcopy(content_ko)
    changed_choice[SANGCHUL_PASSED_ID]["choices"][0]["text"] = "changed"
    check(
        bool(validate_late_father_content(
            changed_choice, content_en, year3_order, year3_order)),
        "choice 1 semantic drift mutation was not detected",
    )
    changed_third_choice = copy.deepcopy(content_en)
    changed_third_choice[SANGCHUL_PASSED_ID]["choices"][2]["result_text"] = (
        "changed")
    check(
        bool(validate_late_father_content(
            content_ko, changed_third_choice, year3_order, year3_order)),
        "choice 3 semantic drift mutation was not detected",
    )
    unsafe_choice = copy.deepcopy(content_ko)
    unsafe_choice[SANGCHUL_PASSED_ID]["choices"][1]["flags"].append(
        "sangchul_news_told_father")
    unsafe_choice[SANGCHUL_PASSED_ID]["choices"][1]["cast_effects"] = {
        "father": {"affinity": 5}}
    check(
        bool(validate_late_father_content(
            unsafe_choice, content_en, year3_order, year3_order)),
        "choice 2 father-resurrection mutation was not detected",
    )
    short_en = copy.deepcopy(content_en)
    short_en[SANGCHUL_PASSED_ID]["choices"].pop()
    check(
        bool(validate_late_father_content(
            content_ko, short_en, year3_order, year3_order)),
        "passed-variant EN choice-count mutation was not detected",
    )

    manager_source = f'''
const FATHER_PASSED_EVENT_VARIANTS := {{
    "{SANGCHUL_LIVE_ID}": "{SANGCHUL_PASSED_ID}",
}}
func father_death_is_monotonic():
    return GameState.flags.get("father_passed", false) or GameState.flags.get("arc_father_passing_seen", false) or GameState.get_cast_stage("father") == "passed"
func live_event_variant_id(event_id):
    if not father_death_is_monotonic(): return event_id
    var variant_id = FATHER_PASSED_EVENT_VARIANTS.get(event_id, "")
    if DataRegistry.find_event(variant_id).is_empty(): return ""
    return variant_id
func _event_passes_hard_state_contracts(event):
    var tags = event.get("tags", [])
    var no_flag = event.get("conditions", {{}}).get("no_flag", "father_passed")
    if tags.has("requires_living_father") and father_death_is_monotonic(): return false
    return true
func queue_event(event):
    var event_id = event.get("id", "")
    var live_id = live_event_variant_id(event_id)
    if not _event_passes_hard_state_contracts(event): return
func get_next_event():
    var queued_id = current_event.get("id", "")
    var live_id = live_event_variant_id(queued_id)
    if _event_passes_hard_state_contracts(current_event): return current_event
func _is_event_eligible(event):
    var eligibility_event = event
    if not _event_passes_hard_state_contracts(eligibility_event): return false
func deferred_event_is_eligible(event_id):
    var live_id = live_event_variant_id(event_id)
    if not _event_passes_hard_state_contracts(event): return false
func resolve_narrative_bridge(event_id, choice_index):
    var event = DataRegistry.find_event(event_id)
    if not _event_passes_hard_state_contracts(event): return false
'''
    check(
        not validate_event_manager_hard_state_source(manager_source),
        "valid EventManager hard-state fixture was rejected",
    )
    wrong_mapping = manager_source.replace(
        f'"{SANGCHUL_PASSED_ID}"', '"wrong_variant"', 1)
    check(
        bool(validate_event_manager_hard_state_source(wrong_mapping)),
        "EventManager explicit mapping mutation was not detected",
    )
    stale_pop = manager_source.replace(
        "live_event_variant_id(queued_id)", "queued_id")
    check(
        bool(validate_event_manager_hard_state_source(stale_pop)),
        "EventManager stale queued-event mutation was not detected",
    )
    unsafe_random = manager_source.replace(
        "if not _event_passes_hard_state_contracts(eligibility_event): return false",
        "if false: return false",
        1,
    )
    check(
        bool(validate_event_manager_hard_state_source(unsafe_random)),
        "EventManager random eligibility hard-state mutation was not detected",
    )
    missing_hard_tag = manager_source.replace(
        'tags.has("requires_living_father")', "false")
    check(
        bool(validate_event_manager_hard_state_source(missing_hard_tag)),
        "EventManager living-Father tag mutation was not detected",
    )
    unsafe_bridge = manager_source.replace(
        "func resolve_narrative_bridge(event_id, choice_index):\n"
        "    var event = DataRegistry.find_event(event_id)\n"
        "    if not _event_passes_hard_state_contracts(event): return false",
        "func resolve_narrative_bridge(event_id, choice_index):\n"
        "    var event = DataRegistry.find_event(event_id)\n"
        "    return true",
        1,
    )
    check(
        bool(validate_event_manager_hard_state_source(unsafe_bridge)),
        "EventManager direct bridge hard-state mutation was not detected",
    )
    return cases + run_person_deal_self_test() + run_father_direct_mutation_self_test()


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--self-test", action="store_true")
    parser.add_argument("--self-test-person-deal", action="store_true",
                        help="pure person-deal DIK/source mutation fixtures only")
    args = parser.parse_args()
    if args.self_test_person_deal:
        try:
            cases = run_person_deal_self_test()
        except AssertionError as exc:
            print(f"CHAPTER4_PERSON_DEAL_SELF_TEST_FAIL {exc}", file=sys.stderr)
            return 1
        print(f"CHAPTER4_PERSON_DEAL_SELF_TEST_OK cases={cases}")
        return 0
    if args.self_test:
        try:
            cases = run_self_test()
        except AssertionError as exc:
            print(f"CHAPTER4_CAUSAL_ROUTE_SELF_TEST_FAIL {exc}", file=sys.stderr)
            return 1
        print(f"CHAPTER4_CAUSAL_ROUTE_SELF_TEST_OK cases={cases}")
        return 0
    try:
        ko = load_events(KO_DIR)
        en = load_events(EN_DIR)
        director = json.loads(DIRECTOR.read_text(encoding="utf-8"))
        lifecycle = json.loads(LIFECYCLE.read_text(encoding="utf-8"))
        source = MAIN_GAME.read_text(encoding="utf-8")
        story_source = STORY_MODE.read_text(encoding="utf-8")
        event_manager_source = EVENT_MANAGER.read_text(encoding="utf-8")
        ko_year3_order = load_event_order(YEAR3_KO)
        en_year3_order = load_event_order(YEAR3_EN)
        errors = validate_model(
            ko, en, director, lifecycle, source, story_source,
            event_manager_source, ko_year3_order, en_year3_order)
        errors.extend(validate_person_deal_content(load_person_deal_events()))
        errors.extend(validate_person_deal_source(source, story_source))
        errors.extend(validate_father_p0_content(
            load_father_p0_events(), source))
    except (OSError, ValueError, json.JSONDecodeError) as exc:
        print(f"CHAPTER4_CAUSAL_ROUTE_AUDIT_FAIL {exc}", file=sys.stderr)
        return 1
    if errors:
        print(f"CHAPTER4_CAUSAL_ROUTE_AUDIT_FAIL errors={len(errors)}")
        for error in errors:
            print(f"  ERROR {error}")
        return 1
    print(
        "CHAPTER4_CAUSAL_ROUTE_AUDIT_OK "
        "promoted_events=19 direct=15 owners=12 "
        "medical=2-of-3 contact_life_writers=0 person_deal_locales=5 "
        "father_p0_locales=5 w190_passed_variants=10"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
