#!/usr/bin/env python3
"""Static regression contract for the ORDER-150 Chapter 5 human REJECT repair.

This checker owns facts that were observable in the rejected normal-speed
playthrough but are cheap and deterministic to protect in source.  It does not
replace either the Godot route check or the required human M49-M60 replays.
"""

from __future__ import annotations

import argparse
import copy
import hashlib
import json
import re
import sys
from dataclasses import dataclass
from pathlib import Path
from typing import Any, Iterable


ROOT = Path(__file__).resolve().parents[1]
KO_DIR = ROOT / "content" / "events"
EN_DIR = ROOT / "content" / "events_en"
RULES_PATH = ROOT / "content" / "meta" / "story_rules.json"
INVENTORY_PATH = ROOT / "content" / "meta" / "release_content_inventory.json"
HUMAN_GATES_PATH = ROOT / "docs" / "human_gates.json"
GAME_STATE_PATH = ROOT / "autoloads" / "GameState.gd"
IMAGE_REGISTRY_PATH = ROOT / "autoloads" / "ImageRegistry.gd"
BGM_PLAYER_PATH = ROOT / "autoloads" / "BGMPlayer.gd"
MAIN_GAME_PATH = ROOT / "scenes" / "MainGame.gd"

PUBLIC_DEMO_PACKAGE_COMMIT = "362578d8f4c0781fe35f643a74cc3037e7a80b21"
PUBLIC_DEMO_PACKAGE_TREE = "e7f50b065b3369afa1894df8292756a95f94fd11"
PUBLIC_DEMO_PRODUCT_COMMIT = "4e80a63e89821094b8bab21b8d5c73ecfc9b6278"
PUBLIC_DEMO_PRODUCT_TREE = "0fdddf11e2ef030cd172d23e691e3d7da4ea29ff"
PUBLIC_DEMO_MANIFEST_SHA256 = (
    "50eed10b18c2c2b056f875a8df55230dc07b5535c55e59ddb89fff1d64e91870"
)
PUBLIC_DEMO_FROZEN_FILES = {
    "content/events_ja/story_demo_events.json":
        "661f9dcf1b958ab9edc5707ca3155e675670b1394fc2ce0e341c6d5456e28a08",
    "content/events_zh-CN/story_demo_events.json":
        "cd67bf8007c6dad44d8c6161a52ad44484ea510ab084acd18f68ba4c535dc142",
    "content/events_zh-TW/story_demo_events.json":
        "33a5b165970675646d7144d42da92884eb3d4bc9b846635369d6ea2a3d5097a9",
    "content/meta/story_map_m1m6_en.json":
        "f250eeac5a987537f4382fd2e66c879f7310b4895d72b258401f216764a8bab1",
    "tools/StoryDemoFourLanguageCheck.gd":
        "df12e1dd57eb768c40ac5beec563b845a03bac9639a4b9506050e14278f1d7eb",
    "tools/build_story_demo_macos.sh":
        "68f3cfaf64ce3e55332c379b930d7d6d5240bd2bc74e938861913a37f7b0e6a4",
    "tools/fixtures/story_demo_density_contract.json":
        "208755a56c09943c033c653efca9f2fda65bfacf43abd91780483c513c4e0ca3",
    "tools/story_demo_localization_audit.py":
        "39c1f2ab38d273bc2f2f6d629008484f603edae083a9ebcf026a2c003c9f0ebe",
    "tools/story_demo_package_audit.py":
        "6da7ea2acaa83b7e4dd859fdbe1406d3c11d967f350cfba4907f6da753389df4",
}

# These are hashes of the rejected product's economic housing functions.  The
# repair may add a presentation projection, but must not rewrite rent, deposit,
# ownership, upgrade, or month-end settlement semantics.
ECONOMIC_HOUSING_FUNCTION_SHA256 = {
    "get_housing_expense":
        "c0babcc878d2f6a33793f703a055292d637318acdf6f44d4570b6683e362fb05",
    "get_housing_info":
        "fad79c8a285f2f5eb211718a6667731d89bcb3c61014676f70a10ecc73af0c4c",
    "can_upgrade_housing":
        "aee407cdab629a3d4a69f547ac09b18cbc5379b781e5e57be2dc35345de37a5b",
    "upgrade_housing":
        "a2a08afd118260a100f8e5a98a5004769341987248c5ebbc18e8ee017f08b55a",
    "apply_monthly_pressure":
        "4b2039750f03a405ab9aa20c806849abb8ae826dc1af3978120b7b03354033c1",
}

EXPECTED_INSTANT_LEGEND_SHA256 = (
    "70b9a867122a27f80830cf43a2e4626032ee76bf10cd16a828d4de18aa41ebc6"
)

RAW_HOUSING_PRESENTATION_NAMES = {
    "gosiwon": {
        "ko": "고시원",
        "narrative_en": "goshiwon",
        "display_en": "Goshiwon Room",
    },
    "oneroom": {
        "ko": "원룸",
        "narrative_en": "one-room studio",
        "display_en": "One-room Studio",
    },
    "villa": {
        "ko": "빌라 전세",
        "narrative_en": "villa jeonse",
        "display_en": "Villa Jeonse",
    },
    "apartment": {
        "ko": "아파트 전세",
        "narrative_en": "apartment jeonse",
        "display_en": "Apartment Jeonse",
    },
    # The current ladder has four steps, but legacy saves and ending snapshots
    # can still contain this retired fifth housing state.
    "gangnam": {
        "ko": "강남 아파트",
        "narrative_en": "Gangnam apartment",
        "display_en": "Gangnam Apartment",
    },
}

LEGACY_MAX_TURNS = {
    "hyunsu_study_together": 23,
    "casino_chip_exchange": 192,
    "amb_credit_steal_00": 192,
    "leading_room_joined": 192,
    "debt_invest_margin_call": 192,
    "anxiety_pension_crisis": 192,
    "flex_sns_envy": 192,
    "godsaeng_start": 192,
}

SNS_GATED_ROOTS = (
    "flex_sns_envy",
    "flex_hotel_staycation",
    "godsaeng_start",
    "shadow_old_promise",
    "shadow_promise_again",
)

SHADOW_PROMISE_ROOTS = (
    "shadow_old_promise",
    "shadow_promise_again",
)
SHADOW_LEGACY_JOINED_FLAG = "startup_collab_joined"
SHADOW_TERMINAL_PROPOSAL_FLAG = "startup_collab_proposed"

JIYEON_TRUTH_CONTACT_PAIRS = (
    (
        "오늘은 잘 지낸다는 말부터 꺼내지 않았다. 지연에게 지금 감당할 수 있는 사정 하나를 먼저 말했다. "
        "숨기지 않는 연습은 매번 다른 데서 시작됐다.",
        "Today I didn't begin by saying everything was fine. I told Jiyeon one circumstance I could actually face. "
        "Practicing honesty began somewhere different each time.",
    ),
    (
        "예전 같으면 숫자를 크게 말했을 대목에서, 오늘은 모르는 것을 모른다고 말했다. "
        "지연과의 대화는 그렇게 한 겹 덜 꾸며졌다.",
        "Where I once would have made the numbers sound bigger, today I said I didn't know. "
        "That left one less layer of performance in my conversation with Jiyeon.",
    ),
    (
        "그날 털어놓은 진실을 되풀이하는 대신, 이번 주에 실제로 놓친 일을 하나 말했다. "
        "숨기지 않는다는 건 같은 말을 반복하는 일이 아니었다.",
        "Instead of repeating the truth we had already laid bare, I named one thing I had actually missed this week. "
        "Hiding nothing did not mean repeating the same words.",
    ),
)

PRESENTATION_CONTRACTS: dict[str, dict[str, Any]] = {
    "arc_y5_burnout_check_reference": {
        "channel": "in_person",
        "scene_location": "hospital_clinic",
        "participants": ["player", "clinician"],
        "portrait_role": "local",
        "nameplate_role": "hidden",
    },
    "arc_y5_jaehyuk_guarantee_request_reference": {
        "channel": "message",
        "scene_location": "current_housing",
        "remote_location": "jaehyuk_current_location",
        "remote_actor": "jaehyuk",
        "portrait_role": "local",
        "nameplate_role": "hidden",
    },
    "arc_y5_jaehyuk_return_call_reference": {
        "channel": "phone",
        "scene_location": "current_housing",
        "remote_location": "jaehyuk_current_location",
        "remote_actor": "jaehyuk",
        "portrait_role": "local",
        "nameplate_role": "hidden",
    },
    "arc_minseo_03_arrival": {
        "channel": "message",
        "scene_location": "current_housing",
        "remote_location": "minseo_current_location",
        "remote_actor": "minseo",
        "participants": ["player"],
        "portrait_role": "none",
        "nameplate_role": "hidden",
    },
    "amb_coin_00": {
        "channel": "phone",
        "scene_location": "investment_phone",
        "remote_location": "taeho_current_location",
        "remote_actor": "taeho",
        "portrait_role": "local",
        "nameplate_role": "hidden",
    },
    "amb_hoesik_00": {
        "channel": "in_person",
        "scene_location": "company_dinner_restaurant",
        "participants": ["player", "boss"],
        "portrait_role": "local",
        "nameplate_role": "hidden",
    },
    "casino_comp_offer": {
        "channel": "in_person",
        "scene_location": "casino",
        "participants": ["player", "casino_manager"],
        "portrait_role": "local",
        "nameplate_role": "hidden",
    },
    "arc_y5_general_name_boundary_exact": {
        "channel": "phone",
        "scene_location": "current_housing",
        "remote_location": "housing_broker_office",
        "remote_actor": "housing_broker",
        "portrait_role": "local",
        "nameplate_role": "hidden",
    },
    "amb_credit_steal_00": {
        "channel": "in_person",
        "scene_location": "office",
        "participants": ["player", "boss"],
        "portrait_role": "local",
        "nameplate_role": "hidden",
    },
    "amb_credit_confront": {
        "channel": "in_person",
        "scene_location": "office",
        "participants": ["player", "boss"],
        "portrait_role": "local",
        "nameplate_role": "hidden",
    },
}


@dataclass
class AuditModel:
    ko: dict[str, dict[str, Any]]
    en: dict[str, dict[str, Any]]
    rules: dict[str, Any]
    inventory: dict[str, Any]
    human_gates: dict[str, Any]
    game_state: str
    image_registry: str
    bgm_player: str
    main_game: str


def _sha256_bytes(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def _sha256_text(text: str) -> str:
    return _sha256_bytes(text.encode("utf-8"))


def _load_json(path: Path) -> Any:
    return json.loads(path.read_text(encoding="utf-8"))


def _load_events(directory: Path) -> dict[str, dict[str, Any]]:
    result: dict[str, dict[str, Any]] = {}
    for path in sorted(directory.glob("*.json")):
        payload = _load_json(path)
        rows = payload.get("events", []) if isinstance(payload, dict) else payload
        if not isinstance(rows, list):
            continue
        for row in rows:
            if not isinstance(row, dict) or not str(row.get("id", "")):
                continue
            event_id = str(row["id"])
            if event_id in result:
                raise ValueError(f"duplicate event id {event_id} in {directory}")
            result[event_id] = row
    return result


def _load_model() -> AuditModel:
    return AuditModel(
        ko=_load_events(KO_DIR),
        en=_load_events(EN_DIR),
        rules=_load_json(RULES_PATH),
        inventory=_load_json(INVENTORY_PATH),
        human_gates=_load_json(HUMAN_GATES_PATH),
        game_state=GAME_STATE_PATH.read_text(encoding="utf-8"),
        image_registry=IMAGE_REGISTRY_PATH.read_text(encoding="utf-8"),
        bgm_player=BGM_PLAYER_PATH.read_text(encoding="utf-8"),
        main_game=MAIN_GAME_PATH.read_text(encoding="utf-8"),
    )


def _function_block(source: str, function_name: str) -> str:
    match = re.search(rf"(?m)^func {re.escape(function_name)}\b", source)
    if match is None:
        return ""
    following = re.search(r"(?m)^func \w", source[match.end():])
    end = match.end() + following.start() if following is not None else len(source)
    return source[match.start():end].rstrip() + "\n"


def _gdscript_child_block(source: str, header: str) -> str:
    """Return one GDScript header and its strictly more-indented children."""
    lines = source.splitlines()
    for index, line in enumerate(lines):
        if line.strip() != header:
            continue
        parent_indent = len(line) - len(line.lstrip("\t "))
        selected = [line]
        for child in lines[index + 1:]:
            if not child.strip():
                selected.append(child)
                continue
            child_indent = len(child) - len(child.lstrip("\t "))
            if child_indent <= parent_indent:
                break
            selected.append(child)
        return "\n".join(selected).rstrip() + "\n"
    return ""


def _instant_legend_block(source: str) -> str:
    start_marker = "\t# ── 첫해 30억 = 즉시 비밀 엔딩"
    end_marker = "\n\t# ── 일반 30억"
    if start_marker not in source:
        return ""
    start = source.index(start_marker)
    end = source.find(end_marker, start)
    return source[start:end] if end >= 0 else ""


def _all_strings(value: Any) -> list[str]:
    if isinstance(value, str):
        return [value]
    if isinstance(value, dict):
        result: list[str] = []
        for child in value.values():
            result.extend(_all_strings(child))
        return result
    if isinstance(value, list):
        result = []
        for child in value:
            result.extend(_all_strings(child))
        return result
    return []


def _event_text(event: dict[str, Any]) -> str:
    return "\n".join(_all_strings(event))


def _conditions(event: dict[str, Any]) -> dict[str, Any]:
    raw = event.get("conditions", {})
    return raw if isinstance(raw, dict) else {}


def _condition_values(event: dict[str, Any], key: str) -> list[str]:
    raw = _conditions(event).get(key)
    if isinstance(raw, list):
        return [str(value) for value in raw]
    if raw is None:
        return []
    return [str(raw)]


def _has_condition_value(event: dict[str, Any], key: str, value: str) -> bool:
    return value in _condition_values(event, key)


def _choice_flags(event: dict[str, Any]) -> list[str]:
    result: list[str] = []
    choices = event.get("choices", [])
    if not isinstance(choices, list):
        return result
    for choice in choices:
        if not isinstance(choice, dict):
            continue
        raw_flags = choice.get("flags", [])
        if isinstance(raw_flags, list):
            result.extend(str(flag) for flag in raw_flags)
    return result


def _shadow_terminal_errors(event_id: str, event: dict[str, Any]) -> list[str]:
    errors: list[str] = []
    flags = _choice_flags(event)
    if SHADOW_LEGACY_JOINED_FLAG in flags:
        errors.append(
            f"{event_id} still produces legacy {SHADOW_LEGACY_JOINED_FLAG}"
        )
    if flags.count(SHADOW_TERMINAL_PROPOSAL_FLAG) != 1:
        errors.append(
            f"{event_id} must produce {SHADOW_TERMINAL_PROPOSAL_FLAG} "
            f"exactly once (actual={flags.count(SHADOW_TERMINAL_PROPOSAL_FLAG)})"
        )
    for terminal_flag in ("sns_detoxed", SHADOW_TERMINAL_PROPOSAL_FLAG):
        if not _has_condition_value(event, "no_flag", terminal_flag):
            errors.append(
                f"{event_id} does not close after {terminal_flag}"
            )
    return errors


def _wallet_meal_structure_errors(
    seed: dict[str, Any],
    invitation: dict[str, Any],
    arrival: dict[str, Any],
) -> list[str]:
    """Require player-owned consent before the wallet-owner meal can exist."""
    errors: list[str] = []
    seed_choices = seed.get("choices", [])
    if not isinstance(seed_choices, list) or len(seed_choices) < 1 \
            or not isinstance(seed_choices[0], dict):
        errors.append("rare_wallet_executive return choice is missing")
    else:
        seed_return = seed_choices[0]
        if seed_return.get("deferred_follow_up") != "chain_exec_meal" \
                or seed_return.get("deferred_delay") != 8:
            errors.append("wallet return no longer queues the reply scene at +8")

    if invitation.get("background") != "current_housing":
        errors.append("wallet meal invitation must begin at current_housing")
    if _conditions(invitation).get("flag") != "returned_wallet":
        errors.append("wallet meal invitation lost the returned_wallet receipt")
    invitation_choices = invitation.get("choices", [])
    if not isinstance(invitation_choices, list) or len(invitation_choices) != 2 \
            or any(not isinstance(choice, dict) for choice in invitation_choices):
        errors.append("wallet meal invitation must keep accept and decline choices")
    else:
        accept, decline = invitation_choices
        if "chain_exec_meal_accepted" not in accept.get("flags", []):
            errors.append("wallet meal acceptance does not persist consent")
        if accept.get("follow_up_event") != "chain_exec_meal_arrival":
            errors.append("wallet meal acceptance does not own the restaurant arrival")
        if accept.get("deferred_follow_up"):
            errors.append("wallet meal acceptance bypasses the visible arrival scene")
        if decline.get("follow_up_event") or decline.get("deferred_follow_up"):
            errors.append("wallet meal decline still schedules a meeting")
        if "chain_exec_meal_accepted" in decline.get("flags", []):
            errors.append("wallet meal decline falsely persists consent")

    if arrival.get("background") != "restaurant":
        errors.append("wallet meal arrival must occur at the restaurant")
    if _conditions(arrival).get("flag") != "chain_exec_meal_accepted":
        errors.append("wallet meal arrival can occur without explicit consent")
    arrival_choices = arrival.get("choices", [])
    if not isinstance(arrival_choices, list) or len(arrival_choices) != 2 \
            or any(not isinstance(choice, dict) for choice in arrival_choices):
        errors.append("wallet meal arrival lost its two disclosure choices")
    else:
        honest, distance = arrival_choices
        if "chain_exec_referral" not in honest.get("flags", []) \
                or honest.get("deferred_follow_up") != "chain_exec_interview" \
                or honest.get("deferred_delay") != 10:
            errors.append("wallet meal honest branch lost the interview chain")
        if "chain_exec_kept_distance" not in distance.get("flags", []) \
                or distance.get("deferred_follow_up"):
            errors.append("wallet meal distance branch no longer closes in place")
    return errors


def _jiyeon_truth_contact_block(source: str) -> str:
    branch_start = source.find('\t\t"jiyeon":')
    if branch_start < 0:
        return ""
    truth_start = source.find(
        'if f.get("arc_jiyeon_truth_seen", false):', branch_start
    )
    if truth_start < 0:
        return ""
    truth_end = source.find("\n\t\t\tif aff >= 25:", truth_start)
    if truth_end < 0:
        return ""
    return source[truth_start:truth_end]


def _event(
    catalog: dict[str, dict[str, Any]],
    event_id: str,
    language: str,
    errors: list[str],
) -> dict[str, Any]:
    row = catalog.get(event_id)
    if not isinstance(row, dict):
        errors.append(f"{language} event missing: {event_id}")
        return {}
    return row


def _require_tokens(label: str, source: str, tokens: Iterable[str], errors: list[str]) -> None:
    for token in tokens:
        if token not in source:
            errors.append(f"{label} missing required contract token: {token!r}")


def _forbid_tokens(label: str, source: str, tokens: Iterable[str], errors: list[str]) -> None:
    for token in tokens:
        if token in source:
            errors.append(f"{label} retains rejected token: {token!r}")


def _raw_housing_name_errors(source: str) -> list[str]:
    """Protect all live ladder names plus the retired Gangnam save state."""
    errors: list[str] = []
    blocks = {
        "narrative": _function_block(source, "get_housing_name"),
        "display": _function_block(source, "get_housing_display_name"),
    }
    for surface, block in blocks.items():
        if not block:
            errors.append(f"raw housing {surface} helper is missing")
            continue
        english_field = f"{surface}_en"
        for housing_id, names in RAW_HOUSING_PRESENTATION_NAMES.items():
            ko_name = str(names["ko"])
            en_name = str(names[english_field])
            row_prefix = f'"{housing_id}": {{"name_ko": "{ko_name}", '
            if row_prefix not in block:
                errors.append(
                    f"raw KO housing {surface} name drifted: "
                    f"{housing_id}={ko_name!r}"
                )
            if f'"name_en": "{en_name}"}}' not in block.split(
                    row_prefix, 1)[-1].split("\n", 1)[0]:
                errors.append(
                    f"raw EN housing {surface} name drifted: "
                    f"{housing_id}={en_name!r}"
                )
    return errors


def validate_housing_projection(model: AuditModel, errors: list[str]) -> None:
    source = model.game_state
    _require_tokens(
        "GameState presentation home constants",
        source,
        (
            'const DAEUN_SHARED_HOME_BACKGROUND_ID := "daeun_newlywed_home"',
            'const DAEUN_SHARED_HOME_AMBIENCE_HOUSING_ID := "oneroom"',
        ),
        errors,
    )
    gate = _function_block(source, "uses_daeun_shared_home_presentation")
    _require_tokens(
        "uses_daeun_shared_home_presentation",
        gate,
        ('flags.get("arc_daeun_wedding_day_seen", false)',
         'flags.get("daeun_divorced", false)'),
        errors,
    )
    if "daeun_married" in gate:
        errors.append("presentation home must not begin at engagement/daeun_married")
    if re.search(r"(?m)^\s*housing\s*=", gate):
        errors.append("presentation-home predicate mutates economic housing")

    expected_blocks = {
        "get_presentation_home_background_id": (
            "DAEUN_SHARED_HOME_BACKGROUND_ID",
            "uses_daeun_shared_home_presentation()",
        ),
        "get_presentation_home_ambience_housing_id": (
            "DAEUN_SHARED_HOME_AMBIENCE_HOUSING_ID",
            "uses_daeun_shared_home_presentation()",
            "else housing",
        ),
        "get_presentation_home_name": (
            "uses_daeun_shared_home_presentation()",
            "다은과 사는 작은 서울 신혼집",
            "small Seoul newlywed home with Daeun",
            "return get_housing_name()",
        ),
        "get_presentation_home_display_name": (
            "uses_daeun_shared_home_presentation()",
            "다은과 사는 신혼집",
            "Shared Home with Daeun",
            "return get_housing_display_name()",
        ),
    }
    for name, tokens in expected_blocks.items():
        block = _function_block(source, name)
        if not block:
            errors.append(f"GameState missing presentation function: {name}")
            continue
        _require_tokens(name, block, tokens, errors)
        if re.search(r"(?m)^\s*housing\s*=", block):
            errors.append(f"{name} mutates economic housing")

    errors.extend(_raw_housing_name_errors(source))

    for name, expected_hash in ECONOMIC_HOUSING_FUNCTION_SHA256.items():
        block = _function_block(source, name)
        actual_hash = _sha256_text(block) if block else "missing"
        if actual_hash != expected_hash:
            errors.append(
                f"economic housing function drifted: {name} "
                f"sha256={actual_hash}, expected={expected_hash}"
            )

    serialize = _function_block(source, "serialize")
    if serialize.count('"housing": housing') != 1:
        errors.append("serialize must keep exactly one raw economic housing field")
    if "presentation_home" in serialize or "newlywed_home" in serialize:
        errors.append("derived presentation home must not become a serialized economy field")

    _require_tokens(
        "ImageRegistry current_housing projection",
        _function_block(model.image_registry, "resolve_contextual_background_id"),
        ("get_presentation_home_background_id()", "_housing_background_id"),
        errors,
    )
    _require_tokens(
        "BGMPlayer live home projection",
        _function_block(model.bgm_player, "_active_housing_id"),
        ("get_presentation_home_ambience_housing_id()", "_gallery_replay_context"),
        errors,
    )
    _require_tokens(
        "MainGame home projection",
        model.main_game,
        (
            'stat_labels["housing"].text = GameState.get_presentation_home_display_name()',
            "GameState.get_presentation_home_background_id()",
            "GameState.get_presentation_home_ambience_housing_id()",
            "GameState.get_presentation_home_name()",
            "GameState.get_presentation_home_display_name()",
        ),
        errors,
    )

    # Short title-case UI labels and sentence-ready narrative names are separate
    # APIs.  Only the four compact fact surfaces consume the display helper;
    # contextual prose and the shareable run card retain the narrative helper.
    display_consumers = {
        "_refresh_all": (
            'stat_labels["housing"].text = '
            "GameState.get_presentation_home_display_name()",
        ),
        "_open_cat_life": (
            "var current_name: String = "
            "GameState.get_presentation_home_display_name()",
        ),
        "_ending_last_home_label": (
            "return GameState.get_presentation_home_display_name()",
        ),
        "_ending_stat_grid": (
            "GameState.get_presentation_home_display_name()",
        ),
    }
    for function_name, tokens in display_consumers.items():
        block = _function_block(model.main_game, function_name)
        _require_tokens(
            f"MainGame display-name consumer {function_name}",
            block,
            tokens,
            errors,
        )
        if "GameState.get_presentation_home_name()" in block:
            errors.append(
                f"MainGame display-name consumer uses narrative helper: {function_name}"
            )
    narrative_consumers = {
        "_contextual_week_pressure": (
            "var housing_name := GameState.get_presentation_home_name()",
        ),
        "_run_card_text": (
            "var housing_name := GameState.get_presentation_home_name()",
        ),
    }
    for function_name, tokens in narrative_consumers.items():
        block = _function_block(model.main_game, function_name)
        _require_tokens(
            f"MainGame narrative-name consumer {function_name}",
            block,
            tokens,
            errors,
        )
        if "GameState.get_presentation_home_display_name()" in block:
            errors.append(
                f"MainGame narrative-name consumer uses display helper: {function_name}"
            )
    display_call = "GameState.get_presentation_home_display_name()"
    narrative_call = "GameState.get_presentation_home_name()"
    if model.main_game.count(display_call) != len(display_consumers):
        errors.append(
            "MainGame presentation display-name consumer set drifted: "
            f"actual={model.main_game.count(display_call)}, "
            f"expected={len(display_consumers)}"
        )
    if model.main_game.count(narrative_call) != len(narrative_consumers):
        errors.append(
            "MainGame presentation narrative-name consumer set drifted: "
            f"actual={model.main_game.count(narrative_call)}, "
            f"expected={len(narrative_consumers)}"
        )

    # Chapter 5 marriage changes the lived-home presentation, not the economic
    # housing ladder. Every living-menu surface must call that distinction a
    # contract update and must not send the couple through a moving keepsake cut.
    shared_surface_contracts = {
        "_render_action_cards": (
            "GameState.uses_daeun_shared_home_presentation()",
            "내 주거 계약 갱신 가능!",
            "Housing contract update available!",
        ),
        "_open_cat_life": (
            "var shared_home := GameState.uses_daeun_shared_home_presentation()",
            "GameState.get_presentation_home_display_name()",
            "지금 사는 신혼집과 내 이름으로 남겨 두는 주거 계약은 따로 표시된다.",
            "The newlywed home you share and the housing contract kept in your name are shown separately.",
            "내 주거 계약 갱신",
            "Update my housing contract",
        ),
        "_ap_move_housing": (
            "var keepsake_event_id := _housing_keepsake_event_id()",
            "GameState.upgrade_housing()",
            "GameState.uses_daeun_shared_home_presentation()",
            "✓ 내 주거 계약",
            "✓ My housing contract",
            "내 주거 계약을 %s 단계로 갱신했다.",
            "Updated my housing contract to the %s tier.",
        ),
        "_get_month_advice": (
            "if not GameState.uses_daeun_shared_home_presentation()",
            "and GameState.can_upgrade_housing()",
            "이사할 자금이 생겼습니다",
            "You can afford to move",
        ),
    }
    for function_name, tokens in shared_surface_contracts.items():
        _require_tokens(
            f"MainGame shared-home {function_name}",
            _function_block(model.main_game, function_name),
            tokens,
            errors,
        )

    # All three raw-housing recommendations must live below the one shared-home
    # exclusion gate.  Token presence alone is insufficient: an accidentally
    # dedented branch would reintroduce the post-wedding move prompt.
    recommend_block = _function_block(model.main_game, "_recommend_action")
    shared_recommend_block = _gdscript_child_block(
        recommend_block,
        "if not GameState.uses_daeun_shared_home_presentation():",
    )
    if not shared_recommend_block:
        errors.append("MainGame recommendations lack the shared-home exclusion block")
    for housing_id, threshold in (
        ("gosiwon", "8_000_000"),
        ("oneroom", "40_000_000"),
        ("villa", "130_000_000"),
    ):
        branch_header = f'if housing == "{housing_id}" and total >= {threshold}:'
        branch = _gdscript_child_block(shared_recommend_block, branch_header)
        if not branch:
            errors.append(
                f"MainGame {housing_id} move recommendation escaped the shared-home gate"
            )
            continue
        _require_tokens(
            f"MainGame gated {housing_id} recommendation",
            branch,
            ("이사 고려", "Consider Moving"),
            errors,
        )
    for token in ("이사 고려", "Consider Moving"):
        if recommend_block.count(token) != 3:
            errors.append(
                f"MainGame raw recommendation count drifted for {token!r}: "
                f"{recommend_block.count(token)}"
            )
        if recommend_block.count(token) != shared_recommend_block.count(token):
            errors.append(
                f"MainGame raw recommendation escaped shared-home gate: {token!r}"
            )

    # Raw-room month prose is likewise valid only before the completed wedding.
    narration_block = _function_block(model.main_game, "_month_narration")
    shared_narration_block = _gdscript_child_block(
        narration_block,
        "if not GameState.uses_daeun_shared_home_presentation():",
    )
    raw_narration_tokens = (
        'if housing == "gosiwon":',
        'elif housing == "apartment":',
        'elif housing == "gangnam":',
        "1평 반에서 2년이 넘었다.",
        "Seoul looks different from an apartment window.",
        "I made it to Gangnam.",
    )
    _require_tokens(
        "MainGame shared-home month narration gate",
        shared_narration_block,
        raw_narration_tokens,
        errors,
    )
    for token in raw_narration_tokens:
        if narration_block.count(token) != shared_narration_block.count(token):
            errors.append(
                f"MainGame raw month narration escaped shared-home gate: {token!r}"
            )

    # Updating the raw contract after marriage must not replay either half of
    # the old physical-move chain.  Check each return inside its complete if
    # block so a nearby but unrelated shared-home token cannot satisfy this.
    graph_router = _function_block(
        model.main_game, "_story_graph_contract_event_id")
    housing_closure = _gdscript_child_block(
        graph_router, "if t >= 25 and t <= 240 \\")
    _require_tokens(
        "MainGame shared-home housing closure exclusion",
        housing_closure,
        (
            "and not GameState.uses_daeun_shared_home_presentation()",
            'f.get("arc_goshiwon_goodbye_seen", false)',
            'not f.get("arc_housing_new_life_seen", false)',
            'return "arc_housing_new_life"',
        ),
        errors,
    )
    closure_order = tuple(housing_closure.find(token) for token in (
        "and not GameState.uses_daeun_shared_home_presentation()",
        'f.get("arc_goshiwon_goodbye_seen", false)',
        'not f.get("arc_housing_new_life_seen", false)',
        'return "arc_housing_new_life"',
    ))
    if not all(index >= 0 for index in closure_order) \
            or list(closure_order) != sorted(closure_order):
        errors.append(
            "arc_housing_new_life closure is not ordered behind the shared-home gate"
        )

    next_arc_router = _function_block(model.main_game, "_next_arc_id")
    housing_ingress = _gdscript_child_block(
        next_arc_router, 'if GameState.housing != "gosiwon" \\')
    _require_tokens(
        "MainGame shared-home goshiwon-goodbye exclusion",
        housing_ingress,
        (
            "and not GameState.uses_daeun_shared_home_presentation()",
            'not f.get("arc_goshiwon_goodbye_seen", false)',
            'not f.get("arc_housing_new_life_seen", false)',
            'return "arc_goshiwon_goodbye"',
        ),
        errors,
    )
    ingress_order = tuple(housing_ingress.find(token) for token in (
        "and not GameState.uses_daeun_shared_home_presentation()",
        'not f.get("arc_goshiwon_goodbye_seen", false)',
        'not f.get("arc_housing_new_life_seen", false)',
        'return "arc_goshiwon_goodbye"',
    ))
    if not all(index >= 0 for index in ingress_order) \
            or list(ingress_order) != sorted(ingress_order):
        errors.append(
            "arc_goshiwon_goodbye ingress is not ordered behind the shared-home gate"
        )

    keepsake_gate = _function_block(model.main_game, "_housing_keepsake_event_id")
    _require_tokens(
        "MainGame married keepsake bypass",
        keepsake_gate,
        (
            "if GameState.uses_daeun_shared_home_presentation():",
            'return ""',
            "GameState.prepare_housing_keepsake()",
        ),
        errors,
    )
    shared_gate_index = keepsake_gate.find(
        "if GameState.uses_daeun_shared_home_presentation():")
    empty_return_index = keepsake_gate.find('return ""', shared_gate_index)
    prepare_index = keepsake_gate.find("GameState.prepare_housing_keepsake()")
    if not (0 <= shared_gate_index < empty_return_index < prepare_index):
        errors.append(
            "married shared-home keepsake bypass must return before preparing a move"
        )


def validate_tutorial_and_credits(model: AuditModel, errors: list[str]) -> None:
    tutorial_gate = _function_block(model.main_game, "_main_game_tutorial_allowed")
    if tutorial_gate.count("return GameState.turn == 1") != 1:
        errors.append("late MainGame tutorial gate must be exact turn == 1")
    _forbid_tokens(
        "late MainGame tutorial gate",
        tutorial_gate,
        ("GameState.turn <=", "GameState.turn >=", "tutorial_step"),
        errors,
    )
    maybe_block = _function_block(model.main_game, "_maybe_show_tutorial")
    _require_tokens(
        "_maybe_show_tutorial",
        maybe_block,
        ("if not _main_game_tutorial_allowed():", "return", "_show_tutorial()"),
        errors,
    )
    if model.main_game.count('TutorialOverlay.maybe_show("main_game", self)') != 1:
        errors.append("MainGame must have exactly one direct main_game overlay call")
    continue_block = _function_block(model.main_game, "_continue_after_story")
    _require_tokens(
        "_continue_after_story tutorial call",
        continue_block,
        ('TutorialOverlay.maybe_show("main_game", self)',
         "_main_game_tutorial_allowed()"),
        errors,
    )

    finale = _function_block(model.main_game, "_ending_build_finale_page")
    _require_tokens(
        "ending finale progress",
        finale,
        (
            '"1 / %d  ·  %s"',
            "ENDING_PAGE_COUNT",
            '"장면 %d / %d"',
            '"SCENE %d / %d"',
            "_ending_finale_beat_index + 1",
            "beat_count",
        ),
        errors,
    )


def validate_time_and_money_copy(model: AuditModel, errors: list[str]) -> None:
    ko_winter = _event(model.ko, "final_last_winter", "KO", errors)
    en_winter = _event(model.en, "final_last_winter", "EN", errors)
    conditions = _conditions(ko_winter)
    try:
        min_turn = int(conditions.get("min_turn", -1))
        max_turn = int(conditions.get("max_turn", -1))
        month = int(conditions.get("month", -1))
    except (TypeError, ValueError):
        min_turn = max_turn = month = -1
    if month != 9 or not (min_turn <= 225 <= max_turn) or max_turn > 227:
        errors.append(
            "final_last_winter must be a September W225-W227 event "
            f"(conditions={conditions!r})"
        )
    _require_tokens("KO final_last_winter", _event_text(ko_winter), ("9월", "넉 달"), errors)
    _require_tokens("EN final_last_winter", _event_text(en_winter), ("September", "Four months"), errors)
    _forbid_tokens(
        "KO final_last_winter",
        _event_text(ko_winter),
        ("12월", "마지막 겨울", "마지막 달"),
        errors,
    )
    _forbid_tokens(
        "EN final_last_winter",
        _event_text(en_winter),
        ("December", "The Last Winter", "the last month"),
        errors,
    )

    for language, catalog in (("KO", model.ko), ("EN", model.en)):
        peace = _event(catalog, "arc_37_ending_peace", language, errors)
        forbidden = (
            ("석 달", "열두 주", "3개월", "12주")
            if language == "KO" else
            ("three months", "twelve weeks", "3 months", "12 weeks")
        )
        _forbid_tokens(f"{language} arc_37_ending_peace", _event_text(peace), forbidden, errors)

        stretch = _event(catalog, "arc_final_stretch", language, errors)
        _require_tokens(f"{language} arc_final_stretch", _event_text(stretch), ("{assets}",), errors)
        stale_stretch = (
            ("지금 자산 20억", "현재 자산 20억", "이제 자산 20억", "이제 20억", "10억 남았다")
            if language == "KO" else
            ("assets now stood at two billion", "now had two billion", "one billion left")
        )
        _forbid_tokens(f"{language} arc_final_stretch", _event_text(stretch), stale_stretch, errors)

        for event_id in ("arc_gangnam_real_estate", "arc_gangnam_real_estate_father_passed"):
            row = _event(catalog, event_id, language, errors)
            text = _event_text(row)
            _require_tokens(f"{language} {event_id}", text, ("{assets}",), errors)
            stale_property = (
                ("이제 25억이다", "자산 25억과 집을 사는 사람의 25억")
                if language == "KO" else
                ("Now it was 2.5 billion", "Assets of 2.5 billion")
            )
            _forbid_tokens(f"{language} {event_id}", text, stale_property, errors)

        pension = _event(catalog, "anxiety_pension_crisis", language, errors)
        _require_tokens(f"{language} anxiety_pension_crisis", _event_text(pension), ("2055",), errors)
        pension_forbidden = ("65세",) if language == "KO" else ("at sixty-five", "age sixty-five")
        _forbid_tokens(
            f"{language} anxiety_pension_crisis",
            _event_text(pension),
            pension_forbidden,
            errors,
        )


def validate_remote_and_no_reply(model: AuditModel, errors: list[str]) -> None:
    ko_minseo = _event(model.ko, "arc_minseo_03_arrival", "KO", errors)
    if str(ko_minseo.get("background", "")) != "current_housing":
        errors.append("arc_minseo_03_arrival must occur at current_housing")
    if str(ko_minseo.get("portrait", "")) != "":
        errors.append("arc_minseo_03_arrival must have no physical Minseo portrait")
    _forbid_tokens(
        "KO arc_minseo_03_arrival",
        _event_text(ko_minseo),
        ("그때 그 카페에서 다시 만났다", "이민서가 고개를 끄덕였다", "이민서가 웃었다"),
        errors,
    )
    _forbid_tokens(
        "EN arc_minseo_03_arrival",
        _event_text(_event(model.en, "arc_minseo_03_arrival", "EN", errors)),
        ("They met again at that same cafe", "Lee Minseo nodded", "Lee Minseo laughed"),
        errors,
    )

    minseo_result_contracts = {
        "KO": (
            model.ko,
            (
                ("적어 보냈다", "자기 말풍선 아래에는 발신 시각만 남았다",
                 "읽음도 답장도, 다음 약속도 생기지 않았다"),
                ("적어 보냈다", "화면에는 자기 쪽 발신 시각만 생겼다",
                 "읽음도 답장도 없었다"),
            ),
            ("민서가 답", "민서가 웃", "민서가 고개를 끄덕",
             "읽음 표시가 떴", "답장이 왔다", "다음 약속을 잡"),
        ),
        "EN": (
            model.en,
            (
                ("pressed send", "Only the sent time remained beneath his bubble",
                 "No read receipt, reply, or next appointment appeared"),
                ("pressed send", "The screen showed only his sent time",
                 "No read receipt or reply appeared"),
            ),
            ("Minseo replied", "Minseo smiled", "Minseo nodded",
             "A read receipt appeared", "A reply came", "They set the next"),
        ),
    }
    for language, (catalog, expected_choices, forbidden) in \
            minseo_result_contracts.items():
        event = _event(catalog, "arc_minseo_03_arrival", language, errors)
        choices = event.get("choices", [])
        if not isinstance(choices, list) or len(choices) != 2:
            errors.append(
                f"{language} arc_minseo_03_arrival must keep exactly two choices"
            )
            continue
        for index, required in enumerate(expected_choices):
            choice = choices[index]
            result_text = str(choice.get("result_text", "")) \
                if isinstance(choice, dict) else ""
            _require_tokens(
                f"{language} arc_minseo_03_arrival choice {index} outbound result",
                result_text,
                required,
                errors,
            )
            _forbid_tokens(
                f"{language} arc_minseo_03_arrival choice {index} outbound result",
                result_text,
                forbidden,
                errors,
            )

    downstream = (
        "arc_y5_general_debt_memory_reconnect",
        "arc_y5_general_father_legacy_voice_exact",
        "arc_y5_general_father_legacy_cafe_exact",
        "arc_y5_final_week_general_people_outbound",
    )
    for language, catalog in (("KO", model.ko), ("EN", model.en)):
        for event_id in downstream:
            text = _event_text(_event(catalog, event_id, language, errors))
            forbidden = (
                ("민서를 다시 만난", "민서와 마지막으로 만난 자리", "민서가 이 방에 들어왔다")
                if language == "KO" else
                ("met Minseo again", "At their last meeting", "Minseo entered this room")
            )
            _forbid_tokens(f"{language} {event_id}", text, forbidden, errors)

    outbound_ko = _event_text(_event(
        model.ko, "arc_y5_final_week_general_people_outbound", "KO", errors))
    outbound_en = _event_text(_event(
        model.en, "arc_y5_final_week_general_people_outbound", "EN", errors))
    _require_tokens(
        "KO W240 general outbound",
        outbound_ko,
        ("같은 방에는 {name} 혼자였다", "읽음도 답장도 다음 만남도 생기지 않았다",
         "읽음도 답장도 약속된 만남도 생기지 않았다"),
        errors,
    )
    _require_tokens(
        "EN W240 general outbound",
        outbound_en,
        ("He was alone in the room", "No read receipt, reply, or next meeting appeared",
         "No read receipt, reply, or confirmed meeting appeared"),
        errors,
    )

    reaction_contracts = {
        "callback_hoesik_left_early_office": {
            "ko_required": ("읽음 표시도 답장도 생기지 않았",),
            "en_required": ("No read receipt or reply appeared",),
            "ko_forbidden": ('읽음 표시가 뜬 뒤 "알았어"',),
            "en_forbidden": ("A read receipt appeared, followed by",),
        },
        "cb_grace_echo": {
            "ko_required": ("읽음도 답장도, 확정된 시간도 생기지 않았다", "달력에 약속을 잠그지 않은"),
            "en_required": ("No read receipt, reply, or confirmed time appeared", "locked no appointment into the calendar"),
            "ko_forbidden": ("상대가 고른 한 칸만 달력에 잠갔다",),
            "en_forbidden": ("slot the other person chose into his calendar",),
        },
        "shadow_old_promise": {
            "ko_required": ("읽음도 답장도", "상대가 기다리겠다는 답이나 약속은 생기지 않았다", "주말 만남도 아직 생기지 않았다"),
            "en_required": ("No read receipt, reply", "No reply or promise to wait appeared", "no read receipt, reply, agreement, or weekend meeting appeared"),
            "ko_forbidden": ('"그래, 괜찮아."', '"알겠어, 기다릴게."', "주말에 카페에서 만났다"),
            "en_forbidden": ('"Okay, I\'ll wait."', "They met at a café on the weekend"),
        },
        "shadow_promise_again": {
            "ko_required": (
                "읽음도 답장도 없었으므로",
                "읽음도 답장도 합의도 없었다",
                "읽음도 답장도 관계의 결론도 생기지 않았다",
            ),
            "en_required": (
                "no read receipt or reply",
                "no read receipt, reply, or agreement",
                "No read receipt, reply, or verdict on the relationship appeared",
            ),
            "ko_forbidden": (
                '"알겠어, 기다릴게."', "답장이 왔다", "상대도 동의했다",
                "주말에 카페에서 만났다",
            ),
            "en_forbidden": (
                '"Okay, I\'ll wait."', "A reply came", "the other person agreed",
                "They met at a café on the weekend",
            ),
        },
    }
    for event_id, contract in reaction_contracts.items():
        ko_text = _event_text(_event(model.ko, event_id, "KO", errors))
        en_text = _event_text(_event(model.en, event_id, "EN", errors))
        _require_tokens(f"KO {event_id}", ko_text, contract["ko_required"], errors)
        _require_tokens(f"EN {event_id}", en_text, contract["en_required"], errors)
        _forbid_tokens(f"KO {event_id}", ko_text, contract["ko_forbidden"], errors)
        _forbid_tokens(f"EN {event_id}", en_text, contract["en_forbidden"], errors)


def validate_wallet_meal_consent(model: AuditModel, errors: list[str]) -> None:
    ko_seed = _event(model.ko, "rare_wallet_executive", "KO", errors)
    ko_invitation = _event(model.ko, "chain_exec_meal", "KO", errors)
    ko_arrival = _event(model.ko, "chain_exec_meal_arrival", "KO", errors)
    errors.extend(_wallet_meal_structure_errors(
        ko_seed, ko_invitation, ko_arrival))

    en_seed = _event(model.en, "rare_wallet_executive", "EN", errors)
    en_invitation = _event(model.en, "chain_exec_meal", "EN", errors)
    en_arrival = _event(model.en, "chain_exec_meal_arrival", "EN", errors)

    language_contracts = {
        "KO": {
            "seed": ko_seed,
            "seed_required": ("분실물 접수증", "새 번호도, 약속도 없었다"),
            "seed_forbidden": ("약속 장소", "밥 한 번 사도 될까요"),
            "invitation": ko_invitation,
            "invitation_required": (
                "밥 한 번 사도 될까요", "답장 칸은 비어 있었다",
                "날짜도 장소도 아직 정해지지 않았다",
            ),
            "invitation_forbidden": ("약속한 한정식집",),
            "accept_required": (
                "가능한 시간을 먼저 적었다", "토요일 12시 30분",
                "날짜와 주소를 다시 확인해 보냈다", "두 사람의 확인이 끝난 뒤",
            ),
            "decline_required": (
                "날짜나 장소를 묻지 않았다", "달력에도 아무것도 적지 않았다",
                "만남은 잡히지 않았다",
            ),
            "decline_forbidden": ("한정식집에서", "먼저 와 있었다"),
            "arrival": ko_arrival,
            "arrival_required": ("토요일 12시 30분", "서로 확인한 강남의 한정식집"),
        },
        "EN": {
            "seed": en_seed,
            "seed_required": ("lost-property receipt", "No new number or appointment"),
            "seed_forbidden": ("meeting place", "Can I buy you a meal"),
            "invitation": en_invitation,
            "invitation_required": (
                "Can I buy you a meal", "reply field beneath the message was still empty",
                "No date or place had been set",
            ),
            "invitation_forbidden": ("promised Korean restaurant",),
            "accept_required": (
                "typed an available time", "Saturday at 12:30",
                "sent the date and address back for confirmation",
                "Only after both sides confirmed",
            ),
            "decline_required": (
                "did not ask for a date or place", "Nothing went on the calendar",
                "No meeting was arranged",
            ),
            "decline_forbidden": ("at the Korean restaurant", "was already there"),
            "arrival": en_arrival,
            "arrival_required": (
                "Saturday, 12:30", "restaurant in Gangnam they had both confirmed",
            ),
        },
    }
    for language, contract in language_contracts.items():
        seed_choices = contract["seed"].get("choices", [])
        seed_result = str(seed_choices[0].get("result_text", "")) \
            if isinstance(seed_choices, list) and seed_choices \
            and isinstance(seed_choices[0], dict) else ""
        _require_tokens(
            f"{language} wallet seed result", seed_result,
            contract["seed_required"], errors)
        _forbid_tokens(
            f"{language} wallet seed result", seed_result,
            contract["seed_forbidden"], errors)

        invitation_text = str(contract["invitation"].get("description", ""))
        _require_tokens(
            f"{language} wallet invitation", invitation_text,
            contract["invitation_required"], errors)
        _forbid_tokens(
            f"{language} wallet invitation", invitation_text,
            contract["invitation_forbidden"], errors)
        invitation_choices = contract["invitation"].get("choices", [])
        if isinstance(invitation_choices, list) and len(invitation_choices) == 2:
            accept_result = str(invitation_choices[0].get("result_text", ""))
            decline_result = str(invitation_choices[1].get("result_text", ""))
            _require_tokens(
                f"{language} wallet acceptance receipt", accept_result,
                contract["accept_required"], errors)
            _require_tokens(
                f"{language} wallet decline receipt", decline_result,
                contract["decline_required"], errors)
            _forbid_tokens(
                f"{language} wallet decline receipt", decline_result,
                contract["decline_forbidden"], errors)

        _require_tokens(
            f"{language} wallet restaurant arrival",
            str(contract["arrival"].get("description", "")),
            contract["arrival_required"], errors)


def validate_late_ingress_and_sns(model: AuditModel, errors: list[str]) -> None:
    for event_id, maximum in LEGACY_MAX_TURNS.items():
        row = _event(model.ko, event_id, "KO", errors)
        raw = _conditions(row).get("max_turn")
        try:
            actual = int(raw)
        except (TypeError, ValueError):
            actual = -1
        if actual < 0 or actual > maximum:
            errors.append(
                f"late legacy ingress remains open: {event_id} "
                f"max_turn={raw!r}, expected <= {maximum}"
            )

    credit = _event(model.ko, "amb_credit_steal_00", "KO", errors)
    required_credit_closures = {
        "credit_swallowed", "credit_went_over_head",
        "credit_drew_line", "credit_backed_down",
    }
    actual_credit_closures = set(_condition_values(credit, "no_flag"))
    if not required_credit_closures.issubset(actual_credit_closures):
        errors.append("amb_credit_steal_00 lacks terminal no_flag closures")
    follow_up = ""
    choices = credit.get("choices", [])
    if isinstance(choices, list):
        for choice in choices:
            if isinstance(choice, dict) and choice.get("follow_up_event") == "amb_credit_confront":
                follow_up = "amb_credit_confront"
    if follow_up != "amb_credit_confront":
        errors.append("amb_credit_confront must remain an explicit early follow-up")
    confront = _event(model.ko, "amb_credit_confront", "KO", errors)
    try:
        confront_min = int(_conditions(confront).get("min_turn", -1))
    except (TypeError, ValueError):
        confront_min = -1
    if confront_min < 9999:
        errors.append("amb_credit_confront must not enter the random pool directly")

    for event_id in SNS_GATED_ROOTS:
        row = _event(model.ko, event_id, "KO", errors)
        if not _has_condition_value(row, "no_flag", "sns_detoxed"):
            errors.append(f"{event_id} can re-enter after sns_detoxed")
    flex = _event(model.ko, "flex_sns_envy", "KO", errors)
    flex_choices = flex.get("choices", [])
    produced = any(
        isinstance(choice, dict)
        and "sns_detoxed" in [str(flag) for flag in choice.get("flags", [])]
        for choice in flex_choices if isinstance(flex_choices, list)
    )
    if not produced:
        errors.append("flex_sns_envy no longer produces sns_detoxed")


def validate_shadow_promise_terminal(model: AuditModel, errors: list[str]) -> None:
    for event_id in SHADOW_PROMISE_ROOTS:
        ko_event = _event(model.ko, event_id, "KO", errors)
        errors.extend(_shadow_terminal_errors(event_id, ko_event))
        _forbid_tokens(
            f"KO {event_id} gameplay object",
            _event_text(ko_event),
            (SHADOW_LEGACY_JOINED_FLAG,),
            errors,
        )
        _forbid_tokens(
            f"EN {event_id} player surface",
            _event_text(_event(model.en, event_id, "EN", errors)),
            (SHADOW_LEGACY_JOINED_FLAG,),
            errors,
        )

    # Generic flags serialization owns old-save compatibility.  There must be
    # no new special-case writer that can manufacture the retired agreement;
    # the runtime check separately proves an old true value round-trips.
    special_writer = re.search(
        r'flags\[\s*["\']startup_collab_joined["\']\s*\]\s*=\s*true',
        model.game_state,
    )
    if special_writer is not None:
        errors.append(
            "GameState contains a special-case startup_collab_joined writer; "
            "generic flags save/load must own legacy preservation"
        )


def validate_jiyeon_truth_contact(model: AuditModel, errors: list[str]) -> None:
    block = _jiyeon_truth_contact_block(model.main_game)
    if not block:
        errors.append("MainGame Jiyeon truth-contact branch is missing")
        return
    if block.count("_tr(") != len(JIYEON_TRUTH_CONTACT_PAIRS):
        errors.append(
            "Jiyeon truth contact must contain exactly three KO/EN _tr variants "
            f"(actual={block.count('_tr(')})"
        )
    for index, (ko_text, en_text) in enumerate(JIYEON_TRUTH_CONTACT_PAIRS, 1):
        _require_tokens(
            f"Jiyeon truth contact variant {index}",
            block,
            (ko_text, en_text),
            errors,
        )
    _require_tokens(
        "Jiyeon truth contact rotation",
        block,
        (
            "var truth_lines: Array[String] = [",
            "GameState.contact_counts.get(person_id, 1)",
            "return truth_lines[(contact_number - 1) % truth_lines.size()]",
        ),
        errors,
    )
    if len({ko for ko, _en in JIYEON_TRUTH_CONTACT_PAIRS}) != 3 \
            or len({en for _ko, en in JIYEON_TRUTH_CONTACT_PAIRS}) != 3:
        errors.append("Jiyeon truth-contact canonical variants are not unique")


def _presentation_errors(
    event_id: str,
    presentation: dict[str, Any],
    expected: dict[str, Any],
) -> list[str]:
    errors: list[str] = []
    for key, value in expected.items():
        if presentation.get(key) != value:
            errors.append(
                f"story_rules {event_id}.presentation.{key}="
                f"{presentation.get(key)!r}, expected {value!r}"
            )
    return errors


def validate_story_rules(model: AuditModel, errors: list[str]) -> None:
    rules = model.rules.get("events", {}) if isinstance(model.rules, dict) else {}
    if not isinstance(rules, dict):
        errors.append("story_rules events must be an object")
        return
    for event_id, expected in PRESENTATION_CONTRACTS.items():
        raw = rules.get(event_id, {})
        presentation = raw.get("presentation", {}) if isinstance(raw, dict) else {}
        if not isinstance(presentation, dict):
            presentation = {}
        errors.extend(_presentation_errors(event_id, presentation, expected))


def validate_preserved_product_boundaries(model: AuditModel, errors: list[str]) -> None:
    instant_block = _instant_legend_block(model.game_state)
    instant_hash = _sha256_text(instant_block) if instant_block else "missing"
    if instant_hash != EXPECTED_INSTANT_LEGEND_SHA256:
        errors.append(
            "30B instant_legend easter egg drifted: "
            f"sha256={instant_hash}, expected={EXPECTED_INSTANT_LEGEND_SHA256}"
        )

    public = model.inventory.get("public_story_demo_package_contract", {})
    expected_public = {
        "profile": "story_demo_rc",
        "package_source_commit": PUBLIC_DEMO_PACKAGE_COMMIT,
        "package_source_tree": PUBLIC_DEMO_PACKAGE_TREE,
        "product_commit": PUBLIC_DEMO_PRODUCT_COMMIT,
        "product_tree": PUBLIC_DEMO_PRODUCT_TREE,
    }
    if not isinstance(public, dict):
        errors.append("public_story_demo_package_contract must be an object")
    else:
        for key, value in expected_public.items():
            if public.get(key) != value:
                errors.append(
                    f"public story demo {key}={public.get(key)!r}, expected {value!r}"
                )

    export_contract = model.inventory.get("export_contract", {})
    staged_demo = export_contract.get("staged_public_demo", {}) \
        if isinstance(export_contract, dict) else {}
    expected_staged = {
        "profile": "story_demo_rc",
        "package_source_commit": PUBLIC_DEMO_PACKAGE_COMMIT,
        "package_source_tree": PUBLIC_DEMO_PACKAGE_TREE,
        "product_commit": PUBLIC_DEMO_PRODUCT_COMMIT,
        "product_tree": PUBLIC_DEMO_PRODUCT_TREE,
        "manifest_sha256": PUBLIC_DEMO_MANIFEST_SHA256,
        "export_filter": "all_resources",
        "public_months": [1, 6],
        "internal_weeks": [1, 24],
        "settlements": 6,
        "range_and_structure_verdict": "user_go",
    }
    if not isinstance(staged_demo, dict):
        errors.append("export_contract.staged_public_demo must be an object")
    else:
        for key, value in expected_staged.items():
            if staged_demo.get(key) != value:
                errors.append(
                    f"staged public demo {key}={staged_demo.get(key)!r}, "
                    f"expected {value!r}"
                )

    candidates = model.human_gates.get("release_candidates", {})
    candidate = candidates.get("story_demo_rc", {}) if isinstance(candidates, dict) else {}
    expected_candidate = {
        "status": "active",
        "commit": PUBLIC_DEMO_PACKAGE_COMMIT,
        "tree": PUBLIC_DEMO_PACKAGE_TREE,
        "manifest_sha256": PUBLIC_DEMO_MANIFEST_SHA256,
    }
    if not isinstance(candidate, dict):
        errors.append("human gate story_demo_rc candidate must be an object")
    else:
        for key, value in expected_candidate.items():
            if candidate.get(key) != value:
                errors.append(
                    f"human gate story_demo_rc {key}={candidate.get(key)!r}, "
                    f"expected {value!r}"
                )
        note = str(candidate.get("note", ""))
        _require_tokens(
            "story_demo_rc candidate note",
            note,
            ("BUILD 2026.08.31.1", "M01~M06", "AP 원장 0"),
            errors,
        )

    gates = model.human_gates.get("gates", [])
    demo_gate = next((
        row for row in gates
        if isinstance(row, dict) and row.get("id") == "story_demo_m1_m6_user_play"
    ), None) if isinstance(gates, list) else None
    if not isinstance(demo_gate, dict):
        errors.append("story_demo_m1_m6_user_play gate is missing")
    else:
        if demo_gate.get("state") != "done":
            errors.append("public M01-M06 user gate must retain user GO/done")
        evidence = demo_gate.get("evidence", {})
        expected_evidence = {
            "authority": "user_final",
            "verdict": "GO",
            "commit": PUBLIC_DEMO_PACKAGE_COMMIT,
            "tree": PUBLIC_DEMO_PACKAGE_TREE,
            "manifest_sha256": PUBLIC_DEMO_MANIFEST_SHA256,
        }
        if not isinstance(evidence, dict):
            errors.append("public M01-M06 user gate evidence must be an object")
        else:
            for key, value in expected_evidence.items():
                if evidence.get(key) != value:
                    errors.append(
                        f"public M01-M06 evidence {key}={evidence.get(key)!r}, "
                        f"expected {value!r}"
                    )
        _require_tokens(
            "public M01-M06 AP-zero evidence",
            str(demo_gate.get("why", "")),
            ("AP 표면 0",),
            errors,
        )

    for relative, expected_hash in PUBLIC_DEMO_FROZEN_FILES.items():
        path = ROOT / relative
        try:
            actual_hash = _sha256_bytes(path.read_bytes())
        except OSError as exc:
            errors.append(f"public demo frozen file unavailable: {relative}: {exc}")
            continue
        if actual_hash != expected_hash:
            errors.append(
                f"public demo frozen file drifted: {relative} "
                f"sha256={actual_hash}, expected={expected_hash}"
            )


def validate_model(model: AuditModel) -> list[str]:
    errors: list[str] = []
    validate_housing_projection(model, errors)
    validate_tutorial_and_credits(model, errors)
    validate_time_and_money_copy(model, errors)
    validate_remote_and_no_reply(model, errors)
    validate_wallet_meal_consent(model, errors)
    validate_late_ingress_and_sns(model, errors)
    validate_shadow_promise_terminal(model, errors)
    validate_jiyeon_truth_contact(model, errors)
    validate_story_rules(model, errors)
    validate_preserved_product_boundaries(model, errors)
    return errors


def run_self_test() -> int:
    cases = 0

    def check(condition: bool, message: str) -> None:
        nonlocal cases
        cases += 1
        if not condition:
            raise AssertionError(message)

    function_fixture = (
        "func alpha() -> int:\n\treturn 1\n\n"
        "func beta() -> int:\n\treturn 2\n"
    )
    check(
        _function_block(function_fixture, "alpha") ==
        "func alpha() -> int:\n\treturn 1\n",
        "function block extraction drifted",
    )
    check(_function_block(function_fixture, "missing") == "", "missing function accepted")

    raw_housing_fixture = (
        'func get_housing_name(housing_id: String = "") -> String:\n'
        '\tvar names := {\n'
        '\t\t"gosiwon": {"name_ko": "고시원", "name_en": "goshiwon"},\n'
        '\t\t"oneroom": {"name_ko": "원룸", "name_en": "one-room studio"},\n'
        '\t\t"villa": {"name_ko": "빌라 전세", "name_en": "villa jeonse"},\n'
        '\t\t"apartment": {"name_ko": "아파트 전세", "name_en": "apartment jeonse"},\n'
        '\t\t"gangnam": {"name_ko": "강남 아파트", "name_en": "Gangnam apartment"},\n'
        '\t}\n'
        '\treturn ""\n\n'
        'func get_housing_display_name(housing_id: String = "") -> String:\n'
        '\tvar names := {\n'
        '\t\t"gosiwon": {"name_ko": "고시원", "name_en": "Goshiwon Room"},\n'
        '\t\t"oneroom": {"name_ko": "원룸", "name_en": "One-room Studio"},\n'
        '\t\t"villa": {"name_ko": "빌라 전세", "name_en": "Villa Jeonse"},\n'
        '\t\t"apartment": {"name_ko": "아파트 전세", "name_en": "Apartment Jeonse"},\n'
        '\t\t"gangnam": {"name_ko": "강남 아파트", "name_en": "Gangnam Apartment"},\n'
        '\t}\n'
        '\treturn ""\n'
    )
    check(
        not _raw_housing_name_errors(raw_housing_fixture),
        "valid five-state raw housing names rejected",
    )
    check(
        any("gangnam" in error and "display" in error for error in
            _raw_housing_name_errors(raw_housing_fixture.replace(
                '"name_en": "Gangnam Apartment"',
                '"name_en": "Gangnam Penthouse"'))),
        "retired Gangnam ending-display mutation accepted",
    )
    check(
        any("gangnam" in error and "narrative" in error for error in
            _raw_housing_name_errors(raw_housing_fixture.replace(
                '"name_en": "Gangnam apartment"',
                '"name_en": "gangnam apartment"'))),
        "retired Gangnam narrative-name mutation accepted",
    )

    nested_fixture = (
        "func recommendation():\n"
        "\tif not shared_home:\n"
        "\t\tif housing == \"gosiwon\":\n"
        "\t\t\treturn \"move\"\n"
        "\treturn \"stay\"\n"
    )
    shared_fixture = _gdscript_child_block(
        nested_fixture, "if not shared_home:")
    check(
        'if housing == "gosiwon":' in shared_fixture
        and 'return "stay"' not in shared_fixture,
        "GDScript nested child extraction drifted",
    )
    dedented_fixture = nested_fixture.replace(
        '\t\tif housing == "gosiwon":', '\tif housing == "gosiwon":')
    check(
        'if housing == "gosiwon":' not in _gdscript_child_block(
            dedented_fixture, "if not shared_home:"),
        "GDScript child extraction accepted a dedented housing branch",
    )

    scalar = {"conditions": {"no_flag": "sns_detoxed"}}
    listed = {"conditions": {"no_flag": ["other", "sns_detoxed"]}}
    check(_has_condition_value(scalar, "no_flag", "sns_detoxed"), "scalar no_flag rejected")
    check(_has_condition_value(listed, "no_flag", "sns_detoxed"), "list no_flag rejected")
    check(not _has_condition_value({}, "no_flag", "sns_detoxed"), "missing no_flag accepted")

    valid_shadow = {
        "conditions": {
            "no_flag": ["sns_detoxed", SHADOW_TERMINAL_PROPOSAL_FLAG],
        },
        "choices": [
            {"flags": ["shadow_promise_declined"]},
            {"flags": [SHADOW_TERMINAL_PROPOSAL_FLAG]},
        ],
    }
    check(
        not _shadow_terminal_errors("shadow_fixture", valid_shadow),
        "valid shadow proposal terminal rejected",
    )
    joined_shadow = copy.deepcopy(valid_shadow)
    joined_shadow["choices"][1]["flags"] = [SHADOW_LEGACY_JOINED_FLAG]
    check(
        any("legacy" in error for error in _shadow_terminal_errors(
            "shadow_fixture", joined_shadow)),
        "legacy joined producer mutation accepted",
    )
    open_shadow = copy.deepcopy(valid_shadow)
    open_shadow["conditions"]["no_flag"].remove(SHADOW_TERMINAL_PROPOSAL_FLAG)
    check(
        any("does not close" in error for error in _shadow_terminal_errors(
            "shadow_fixture", open_shadow)),
        "non-terminal proposal mutation accepted",
    )

    wallet_seed_fixture = {
        "choices": [{
            "deferred_follow_up": "chain_exec_meal",
            "deferred_delay": 8,
        }],
    }
    wallet_invitation_fixture = {
        "background": "current_housing",
        "conditions": {"flag": "returned_wallet"},
        "choices": [
            {
                "flags": ["chain_exec_meal_accepted"],
                "follow_up_event": "chain_exec_meal_arrival",
            },
            {"flags": [], "follow_up_event": ""},
        ],
    }
    wallet_arrival_fixture = {
        "background": "restaurant",
        "conditions": {"flag": "chain_exec_meal_accepted"},
        "choices": [
            {
                "flags": ["chain_exec_referral"],
                "deferred_follow_up": "chain_exec_interview",
                "deferred_delay": 10,
            },
            {"flags": ["chain_exec_kept_distance"]},
        ],
    }
    check(
        not _wallet_meal_structure_errors(
            wallet_seed_fixture, wallet_invitation_fixture,
            wallet_arrival_fixture),
        "valid wallet meal consent bridge rejected",
    )
    forged_invitation = copy.deepcopy(wallet_invitation_fixture)
    forged_invitation["choices"][1]["follow_up_event"] = \
        "chain_exec_meal_arrival"
    check(
        any("decline" in error for error in _wallet_meal_structure_errors(
            wallet_seed_fixture, forged_invitation, wallet_arrival_fixture)),
        "wallet meal decline was allowed to schedule the restaurant",
    )
    forged_arrival = copy.deepcopy(wallet_arrival_fixture)
    forged_arrival["conditions"]["flag"] = "returned_wallet"
    check(
        any("without explicit consent" in error for error in
            _wallet_meal_structure_errors(
                wallet_seed_fixture, wallet_invitation_fixture,
                forged_arrival)),
        "wallet meal arrival accepted the return receipt as consent",
    )
    forged_acceptance = copy.deepcopy(wallet_invitation_fixture)
    forged_acceptance["choices"][0]["follow_up_event"] = ""
    check(
        any("restaurant arrival" in error for error in
            _wallet_meal_structure_errors(
                wallet_seed_fixture, forged_acceptance,
                wallet_arrival_fixture)),
        "wallet meal acceptance lost its owned arrival without detection",
    )

    contact_fixture = (
        '\t\t"jiyeon":\n'
        '\t\t\tif f.get("arc_jiyeon_truth_seen", false):\n'
        '\t\t\t\tvar truth_lines: Array[String] = []\n'
        '\t\t\t\treturn truth_lines[0]\n'
        '\t\t\tif aff >= 25:\n'
        '\t\t\t\treturn "later"\n'
    )
    check(
        "var truth_lines" in _jiyeon_truth_contact_block(contact_fixture),
        "Jiyeon truth-contact block extraction drifted",
    )
    check(
        not _jiyeon_truth_contact_block(contact_fixture.replace(
            '"jiyeon"', '"daeun"')),
        "non-Jiyeon branch accepted as truth-contact block",
    )

    valid_presentation = copy.deepcopy(PRESENTATION_CONTRACTS["arc_minseo_03_arrival"])
    check(
        not _presentation_errors(
            "arc_minseo_03_arrival", valid_presentation,
            PRESENTATION_CONTRACTS["arc_minseo_03_arrival"]),
        "valid remote Minseo contract rejected",
    )
    invalid_presentation = copy.deepcopy(valid_presentation)
    invalid_presentation["channel"] = "in_person"
    check(
        any("channel" in error for error in _presentation_errors(
            "arc_minseo_03_arrival", invalid_presentation,
            PRESENTATION_CONTRACTS["arc_minseo_03_arrival"])),
        "physical Minseo mutation accepted",
    )
    invalid_presentation = copy.deepcopy(valid_presentation)
    invalid_presentation["nameplate_role"] = "auto"
    check(
        any("nameplate_role" in error for error in _presentation_errors(
            "arc_minseo_03_arrival", invalid_presentation,
            PRESENTATION_CONTRACTS["arc_minseo_03_arrival"])),
        "speaker-nameplate mutation accepted",
    )

    collected = _event_text({"description": "first", "choices": [{"result_text": "second"}]})
    check("first" in collected and "second" in collected, "event prose traversal drifted")

    instant_fixture = (
        "func check_game_over():\n"
        "\t# ── 첫해 30억 = 즉시 비밀 엔딩 ──────────────────────\n"
        "\t# 현재 자산으로 첫해 안에 30억을 만든 순간만 신화로 즉시 닫는다.\n"
        "\t# 과거 peak만으로 나중에 이 비밀 엔딩이 발동해서는 안 된다.\n"
        "\tif total_now >= 3_000_000_000:\n"
        "\t\t# ★ 히든 이스터에그 — 첫 해(33세=챕터1)에 30억은 거의 불가능한 초고속 달성.\n"
        "\t\t#   변칙 플레이(경마/투자 대박)에 대한 보상 엔딩. 인물 아크는 챕터2+라\n"
        "\t\t#   아직 아무도 못 만난 상태 → 빈 집 대신 '신화' 엔딩으로 인정해준다.\n"
        "\t\tif age <= 33:\n"
        "\t\t\tfinish_run(\"instant_legend\"); return\n"
        "\n\t# ── 일반 30억 = M60 마지막 서명 뒤 성공 엔딩"
    )
    check(
        _sha256_text(_instant_legend_block(instant_fixture)) ==
        EXPECTED_INSTANT_LEGEND_SHA256,
        "valid instant_legend fixture rejected",
    )
    check(
        _sha256_text(_instant_legend_block(
            instant_fixture.replace("age <= 33", "age <= 34"))) !=
        EXPECTED_INSTANT_LEGEND_SHA256,
        "instant_legend age mutation accepted",
    )

    errors: list[str] = []
    _require_tokens("fixture", "AP 표면 0", ("AP 표면 0",), errors)
    check(not errors, "required-token helper rejected a valid contract")
    errors = []
    _require_tokens("fixture", "", ("AP 표면 0",), errors)
    check(bool(errors), "required-token helper accepted a missing contract")
    errors = []
    _forbid_tokens("fixture", "No reply appeared", ("reply came",), errors)
    check(not errors, "forbidden-token helper rejected a safe sentence")
    errors = []
    _forbid_tokens("fixture", "A reply came", ("reply came",), errors)
    check(bool(errors), "forbidden-token helper accepted a fake reply")

    return cases


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--self-test", action="store_true")
    args = parser.parse_args(argv)
    if args.self_test:
        try:
            cases = run_self_test()
        except AssertionError as exc:
            print(f"CHAPTER5_HUMAN_REJECT_SELF_TEST_FAIL {exc}", file=sys.stderr)
            return 1
        print(f"CHAPTER5_HUMAN_REJECT_SELF_TEST_OK cases={cases}")
        return 0

    try:
        model = _load_model()
    except (OSError, ValueError, json.JSONDecodeError) as exc:
        print(f"CHAPTER5_HUMAN_REJECT_AUDIT_FAIL load={exc}", file=sys.stderr)
        return 1
    errors = validate_model(model)
    if errors:
        print(f"CHAPTER5_HUMAN_REJECT_AUDIT_FAIL errors={len(errors)}")
        for error in errors:
            print(f"  ERROR {error}")
        print(
            "  NOTE static GREEN cannot close either Chapter 5 human gate; "
            "both exact M49-M60 normal-speed replays remain required"
        )
        return 1
    print(
        "CHAPTER5_HUMAN_REJECT_AUDIT_OK "
        "housing=presentation_only/shared-living-contract/no-old-move-ingress "
        "names=5x-raw-display-ko-en/legacy-gangnam/shared-display-vs-narrative/consumer-split "
        "tutorial=turn1 credits=1of6+beat "
        "timeline=calendar_safe money=dynamic remote=no_copresence/no_fake_reply "
        "wallet=player_acceptance/mutual-schedule/decline-closes "
        "legacy=bounded/old-flags-preserved sns=detox_bounded "
        "shadow=proposal-terminal/no-fake-agreement "
        "jiyeon=truth-contact-3x-ko-en speakers=hidden_contract "
        "instant_legend=preserved ap_surface=public_demo_zero "
        "public_demo=M01-M06/frozen human_gates=pending"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
