#!/usr/bin/env python3
"""Audit ORDER-156 routine locations and the W220 frozen-location echo.

This checker owns static source contracts only.  The companion live Godot check
owns random selection, settled textures, ambience, and save/load execution; neither
automatic check closes the Chapter 5 human-play gate.
"""

from __future__ import annotations

import argparse
import ast
import copy
import hashlib
import json
import re
from pathlib import Path
from typing import Any, Dict, Iterable, List, Optional, Sequence, Tuple


ROOT = Path(__file__).resolve().parents[1]
PATHS = {
    "main_game": ROOT / "scenes" / "MainGame.gd",
    "story_mode": ROOT / "scenes" / "StoryMode.gd",
    "game_state": ROOT / "autoloads" / "GameState.gd",
    "image_registry": ROOT / "autoloads" / "ImageRegistry.gd",
    "events": ROOT / "content" / "events" / "arc_pre_ending.json",
    "director": ROOT / "content" / "meta" / "event_director.json",
}

EXPECTED_BACKGROUNDS = {
    "_SAVE_SCENES": (
        "current_home_cooking",
        "current_housing",
        "street_day",
        "convenience_night",
        "current_home_cooking",
    ),
    "REST_VIGNETTES": (
        "hangang_riverside",
        "current_housing",
        "current_housing",
        "current_housing",
        "pojangmacha",
        "park_bench_day",
        "current_housing",
        "jjimjilbang",
        "street_day",
        "current_housing",
    ),
}
EXPECTED_KEYS = {
    "_SAVE_SCENES": frozenset(("t", "et", "background")),
    "REST_VIGNETTES": frozenset(("t", "et", "e", "background")),
}
EXPECTED_PROJECTION_SHA256 = {
    "_SAVE_SCENES": (
        "15f44fdba72f83007f4ce084632dcf623a0baf7009929c7e9f0373bb0a50627f"
    ),
    "REST_VIGNETTES": (
        "502b97fa07811b5eda6ee8af6998dd4c0cca732c4ad0d9f208d4b8f76e9daf5d"
    ),
}
CONTEXTUAL_SENTINELS = frozenset(("current_housing", "current_home_cooking"))
ALLOWED_BACKGROUND_IDS = frozenset(
    (
        "current_housing",
        "current_home_cooking",
        "street_day",
        "convenience_night",
        "hangang_riverside",
        "pojangmacha",
        "park_bench_day",
        "jjimjilbang",
    )
)
EXPECTED_CONCRETE_PATHS = {
    "street_day": "res://assets/backgrounds/street_seoul_day.png",
    "convenience_night": "res://assets/backgrounds/convenience_store_night_v2.png",
    "hangang_riverside": "res://assets/backgrounds/hangang_riverside_walk.png",
    "pojangmacha": "res://assets/backgrounds/pojangmacha.png",
    "park_bench_day": "res://assets/backgrounds/park_bench_day.png",
    "jjimjilbang": "res://assets/backgrounds/jjimjilbang.png",
    "goshiwon_shared_kitchen": (
        "res://assets/backgrounds/goshiwon_shared_kitchen.png"
    ),
    "daeun_newlywed_home": (
        "res://assets/backgrounds/daeun_newlywed_home_night.png"
    ),
}
W220_EVENT_ID = "arc_y5_general_debt_memory_reconnect"


class AuditParseError(ValueError):
    """A source contract could not be decoded."""


def _extract_literal_text(source: str, name: str) -> str:
    match = re.search(
        r"(?m)^const\s+" + re.escape(name) + r"\s*(?::=|=)\s*", source
    )
    if match is None:
        raise AuditParseError("constant %s is missing" % name)
    index = match.end()
    while index < len(source) and source[index].isspace():
        index += 1
    if index >= len(source) or source[index] not in "[{(":
        raise AuditParseError("constant %s has no literal value" % name)

    pairs = {"[": "]", "{": "}", "(": ")"}
    stack: List[str] = []
    quote = ""
    escaped = False
    in_comment = False
    start = index
    while index < len(source):
        char = source[index]
        if in_comment:
            if char == "\n":
                in_comment = False
            index += 1
            continue
        if quote:
            if escaped:
                escaped = False
            elif char == "\\":
                escaped = True
            elif char == quote:
                quote = ""
            index += 1
            continue
        if char == "#":
            in_comment = True
        elif char in "\"'":
            quote = char
        elif char in pairs:
            stack.append(pairs[char])
        elif char in "]})":
            if not stack or char != stack[-1]:
                raise AuditParseError("constant %s has unbalanced brackets" % name)
            stack.pop()
            if not stack:
                return source[start : index + 1]
        index += 1
    raise AuditParseError("constant %s has an unterminated literal" % name)


def _extract_literal(source: str, name: str) -> Any:
    literal = _extract_literal_text(source, name)
    try:
        return ast.literal_eval(literal)
    except (SyntaxError, ValueError) as exc:
        raise AuditParseError("constant %s is not a static literal: %s" % (name, exc))


def _extract_function(source: str, name: str) -> str:
    match = re.search(r"(?m)^func\s+" + re.escape(name) + r"\s*\(", source)
    if match is None:
        raise AuditParseError("function %s is missing" % name)
    next_match = re.search(r"(?m)^func\s+[A-Za-z_][A-Za-z0-9_]*\s*\(", source[match.end() :])
    if next_match is None:
        return source[match.start() :]
    return source[match.start() : match.end() + next_match.start()]


def _projection_sha256(rows: Sequence[Dict[str, Any]]) -> str:
    projection = [
        {key: row[key] for key in ("t", "et", "e") if key in row}
        for row in rows
    ]
    payload = json.dumps(
        projection, ensure_ascii=False, sort_keys=True, separators=(",", ":")
    ).encode("utf-8")
    return hashlib.sha256(payload).hexdigest()


def _require_fragments(
    errors: List[str], label: str, source: str, fragments: Sequence[str]
) -> None:
    missing = [fragment for fragment in fragments if fragment not in source]
    if missing:
        errors.append("%s missing %s" % (label, ", ".join(repr(x) for x in missing)))


def _require_order(
    errors: List[str], label: str, source: str, fragments: Sequence[str]
) -> None:
    positions = [source.find(fragment) for fragment in fragments]
    if any(position < 0 for position in positions):
        errors.append("%s is incomplete" % label)
    elif positions != sorted(positions) or len(set(positions)) != len(positions):
        errors.append("%s is out of order" % label)


def _find_event(catalog: Any, event_id: str) -> Optional[Dict[str, Any]]:
    rows: Any = catalog
    if isinstance(catalog, dict):
        rows = catalog.get("events", [])
    if not isinstance(rows, list):
        return None
    for value in rows:
        if isinstance(value, dict) and value.get("id") == event_id:
            return value
    return None


def _validate_rows(main_game: str, image_registry: str, errors: List[str]) -> None:
    decoded: Dict[str, List[Dict[str, Any]]] = {}
    for name in ("_SAVE_SCENES", "REST_VIGNETTES"):
        try:
            value = _extract_literal(main_game, name)
        except AuditParseError as exc:
            errors.append("%s table parse failed: %s" % (name, exc))
            continue
        if not isinstance(value, list):
            errors.append("%s must be an array" % name)
            continue
        rows: List[Dict[str, Any]] = []
        for index, raw_row in enumerate(value):
            if not isinstance(raw_row, dict):
                errors.append("%s row=%d must be a dictionary" % (name, index))
                continue
            row = raw_row
            rows.append(row)
            actual_keys = frozenset(row.keys())
            if actual_keys != EXPECTED_KEYS[name]:
                errors.append(
                    "%s unexpected keys row=%d expected=%s actual=%s"
                    % (
                        name,
                        index,
                        sorted(EXPECTED_KEYS[name]),
                        sorted(str(key) for key in actual_keys),
                    )
                )
            for prose_key in ("t", "et"):
                if not isinstance(row.get(prose_key), str) or not row[prose_key].strip():
                    errors.append("%s row=%d has invalid %s" % (name, index, prose_key))
            if name == "REST_VIGNETTES":
                effects = row.get("e")
                if not isinstance(effects, dict) or not effects:
                    errors.append("REST_VIGNETTES row=%d has invalid effects" % index)
                elif any(
                    not isinstance(key, str)
                    or not key
                    or not isinstance(amount, int)
                    or isinstance(amount, bool)
                    for key, amount in effects.items()
                ):
                    errors.append("REST_VIGNETTES row=%d has non-integer effects" % index)
            background = row.get("background")
            if not isinstance(background, str) or background not in ALLOWED_BACKGROUND_IDS:
                errors.append(
                    "%s row=%d has disallowed background %r" % (name, index, background)
                )

        decoded[name] = rows
        expected = EXPECTED_BACKGROUNDS[name]
        if len(rows) != len(expected):
            errors.append(
                "%s row count mismatch expected=%d actual=%d"
                % (name, len(expected), len(rows))
            )
        for index, expected_background in enumerate(expected):
            if index >= len(rows):
                break
            actual_background = rows[index].get("background")
            if actual_background != expected_background:
                errors.append(
                    "%s background mismatch row=%d expected=%s actual=%r"
                    % (name, index, expected_background, actual_background)
                )
        if len(rows) == len(value):
            actual_hash = _projection_sha256(rows)
            expected_hash = EXPECTED_PROJECTION_SHA256[name]
            if actual_hash != expected_hash:
                errors.append(
                    "%s source projection SHA256 mismatch expected=%s actual=%s"
                    % (name, expected_hash, actual_hash)
                )

    try:
        backgrounds = _extract_literal(image_registry, "BACKGROUNDS")
    except AuditParseError as exc:
        errors.append("ImageRegistry BACKGROUNDS parse failed: %s" % exc)
        return
    if not isinstance(backgrounds, dict):
        errors.append("ImageRegistry BACKGROUNDS must be a dictionary")
        return
    for background_id, expected_path in EXPECTED_CONCRETE_PATHS.items():
        actual_path = backgrounds.get(background_id)
        if actual_path != expected_path:
            errors.append(
                "ImageRegistry background path mismatch id=%s expected=%s actual=%r"
                % (background_id, expected_path, actual_path)
            )
            continue
        relative_path = expected_path[len("res://") :]
        if not (ROOT / relative_path).is_file():
            errors.append(
                "ImageRegistry background asset missing id=%s path=%s"
                % (background_id, expected_path)
            )


def _validate_current_home_contract(
    image_registry: str, game_state: str, errors: List[str]
) -> None:
    try:
        resolver = _extract_function(image_registry, "resolve_contextual_background_id")
        housing_resolver = _extract_function(image_registry, "_housing_background_id")
        shared_home = _extract_function(game_state, "uses_daeun_shared_home_presentation")
        presentation_home = _extract_function(
            game_state, "get_presentation_home_background_id"
        )
    except AuditParseError as exc:
        errors.append("current_home_cooking resolver code contract parse failed: %s" % exc)
        return

    _require_fragments(
        errors,
        "current_home_cooking resolver code contract",
        resolver,
        (
            '"current_housing":',
            '"current_home_cooking":',
            "GameState.get_presentation_home_background_id()",
            'if str(GameState.housing) == "gosiwon":',
            'return "goshiwon_shared_kitchen"',
            "return _housing_background_id(str(GameState.housing))",
        ),
    )
    cooking_start = resolver.find('"current_home_cooking":')
    workplace_start = resolver.find('"current_workplace":', cooking_start + 1)
    cooking_arm = resolver[cooking_start:workplace_start] if workplace_start >= 0 else ""
    _require_order(
        errors,
        "current_home_cooking resolver precedence",
        cooking_arm,
        (
            "GameState.get_presentation_home_background_id()",
            "if not presentation_id.is_empty():",
            "return presentation_id",
            'if str(GameState.housing) == "gosiwon":',
            'return "goshiwon_shared_kitchen"',
            "return _housing_background_id(str(GameState.housing))",
        ),
    )
    _require_fragments(
        errors,
        "current home housing resolver",
        housing_resolver,
        (
            '"gangnam":   return "gangnam_apartment"',
            '"apartment": return "gangnam_apartment"',
            '"villa":     return "apartment"',
            '"oneroom":   return "apartment"',
            '_:           return "goshiwon_room"',
        ),
    )
    if not re.search(
        r'(?m)^const\s+DAEUN_SHARED_HOME_BACKGROUND_ID\s*:=\s*"daeun_newlywed_home"\s*$',
        game_state,
    ):
        errors.append("current home marriage background constant is not exact")
    _require_fragments(
        errors,
        "current home marriage-divorce boundary",
        shared_home,
        (
            'flags.get("arc_daeun_wedding_day_seen", false)',
            'not bool(flags.get("daeun_divorced", false))',
        ),
    )
    _require_fragments(
        errors,
        "current home presentation resolver",
        presentation_home,
        ("DAEUN_SHARED_HOME_BACKGROUND_ID", "uses_daeun_shared_home_presentation()"),
    )


def _validate_routine_runtime_wiring(
    main_game: str, game_state: str, errors: List[str]
) -> None:
    function_names = (
        "_ap_save_money",
        "_ap_vignette",
        "_show_vignette",
        "_vignette_commitment_details",
        "_set_scene_ambience_for_background",
    )
    try:
        functions = {
            name: _extract_function(main_game, name) for name in function_names
        }
        finalize = _extract_function(game_state, "finalize_weekly_effect_action")
    except AuditParseError as exc:
        errors.append("routine settled-result wiring parse failed: %s" % exc)
        return

    _require_fragments(
        errors,
        "SAVE direct-result wiring",
        functions["_ap_save_money"],
        (
            "_SAVE_SCENES[randi() % _SAVE_SCENES.size()]",
            "_vignette_commitment_details(_sv",
            'str(_sv.get("background", ""))',
        ),
    )
    _require_fragments(
        errors,
        "REST direct-result wiring",
        functions["_ap_vignette"],
        (
            "pool[randi() % pool.size()]",
            "_vignette_commitment_details(v)",
            'str(v.get("background", ""))',
        ),
    )
    _require_order(
        errors,
        "routine settled background application",
        functions["_show_vignette"],
        (
            "ImageRegistry.resolve_contextual_background_id(",
            "ImageRegistry.get_background(resolved_background_id)",
            "_event_bg_id = resolved_background_id",
            "_apply_event_bg_path(vignette_bg)",
            "_set_scene_ambience_for_background(",
        ),
    )
    _require_fragments(
        errors,
        "routine settled ambience identity",
        functions["_show_vignette"],
        ("vignette_bg, title, body, resolved_background_id",),
    )
    _require_fragments(
        errors,
        "routine ambience consumer",
        functions["_set_scene_ambience_for_background"],
        (
            "exact_background_id.strip_edges()",
            "BGMPlayer.update_event_ambience(ambience_event, \"\", background_id)",
        ),
    )
    _require_fragments(
        errors,
        "routine receipt background producer",
        functions["_vignette_commitment_details"],
        (
            'vignette.get("background", "")',
            "ImageRegistry.resolve_contextual_background_id(",
            "ImageRegistry.BACKGROUNDS.has(background_id)",
            'details["scene_background_id"] = background_id',
        ),
    )
    _require_order(
        errors,
        "routine receipt background promotion",
        finalize,
        (
            'resolved_details.get(\n\t\t"scene_background_id", "")',
            'pending_weekly_commitment["scene_background_id"] = scene_background_id',
        ),
    )


def _validate_w220_data(events: Any, director: Any, errors: List[str]) -> None:
    event = _find_event(events, W220_EVENT_ID)
    if event is None:
        errors.append("W220 authored event is missing: %s" % W220_EVENT_ID)
    else:
        if event.get("background") != "current_housing":
            errors.append(
                "W220 root background mismatch expected=current_housing actual=%r"
                % event.get("background")
            )
        choices = event.get("choices")
        if not isinstance(choices, list) or len(choices) != 2:
            errors.append("W220 choice inventory mismatch expected=2")
        else:
            choice0 = choices[0] if isinstance(choices[0], dict) else {}
            choice1 = choices[1] if isinstance(choices[1], dict) else {}
            if (
                "result_background" in choice0
                or "result_cg" in choice0
                or "result_ambience" in choice0
            ):
                errors.append(
                    "W220 choice0 must retain the settled root home location and ambience"
                )
            if choice1.get("result_background") != "cafe":
                errors.append("W220 choice1 result background must be cafe")
            if choice1.get("result_ambience") != "cafe":
                errors.append("W220 choice1 result ambience must be cafe")

    if not isinstance(director, dict):
        errors.append("event director must be a dictionary")
        return
    pacing = director.get("full_run_pacing")
    if not isinstance(pacing, dict):
        errors.append("event director full_run_pacing is missing")
        return
    owners = pacing.get("commitment_event_owners", {})
    owner_rows = owners.get("220", []) if isinstance(owners, dict) else []
    expected_owner = {
        "id": W220_EVENT_ID,
        "axis": "human",
        "person_id": "minseo",
    }
    if expected_owner not in owner_rows:
        errors.append("W220 commitment owner is missing or changed")
    echo_weeks = pacing.get("echo_weeks", [])
    if not isinstance(echo_weeks, list) or 231 not in echo_weeks:
        errors.append("full_run_pacing echo_weeks missing W231")


def _validate_w220_code(
    story_mode: str, game_state: str, main_game: str, errors: List[str]
) -> None:
    try:
        result_resolver = _extract_function(story_mode, "_choice_result_background_id")
        on_choice = _extract_function(story_mode, "_on_choice")
        record = _extract_function(game_state, "record_story_weekly_commitment")
        consume = _extract_function(game_state, "consume_weekly_commitment_echoes")
        serialize = _extract_function(game_state, "serialize")
        load_from_dict = _extract_function(game_state, "load_from_dict")
        reader = _extract_function(main_game, "_scene_background_for_commitment")
        auto_week = _extract_function(main_game, "_demo_director_auto_week")
        render_beat = _extract_function(main_game, "_render_demo_director_beat")
    except AuditParseError as exc:
        errors.append("W220 record/consume producer-reader parse failed: %s" % exc)
        return

    _require_fragments(
        errors,
        "StoryMode settled result background resolver",
        result_resolver,
        (
            'choice.get(\n\t\t\t"result_background", _current.get("result_background", ""))',
            "_resolve_story_background_id(",
            "ImageRegistry.BACKGROUNDS.has(result_background_id)",
            "return result_background_id",
            "var current_background_id := _event_background_id.strip_edges()",
            "return current_background_id",
        ),
    )
    _require_order(
        errors,
        "StoryMode producer order",
        on_choice,
        (
            "var commitment_background_id := _choice_result_background_id(choice)",
            'commitment_contract["scene_background_id"] = commitment_background_id',
            "GameState.apply_choice(_current, choice)",
            "GameState.record_story_weekly_commitment(",
        ),
    )
    _require_order(
        errors,
        "GameState W220 receipt writer",
        record,
        (
            'contract.get(\n\t\t"scene_background_id", "")',
            'record["scene_background_id"] = scene_background_id',
            "weekly_commitments.append(record)",
        ),
    )
    _require_fragments(
        errors,
        "GameState weekly commitment save contract",
        serialize,
        ('"weekly_commitments": weekly_commitments',),
    )
    _require_fragments(
        errors,
        "GameState weekly commitment load contract",
        load_from_dict,
        (
            'data.has("weekly_commitments")',
            "valid_commitments.append((value as Dictionary).duplicate(true))",
            "weekly_commitments = valid_commitments",
        ),
    )
    _require_order(
        errors,
        "GameState echo consumer",
        consume,
        (
            'int(record.get("turn", turn)) < turn',
            'int(record.get("echoed_turn", -1)) < 0',
            'updated["echoed_turn"] = turn',
            "returned.append(updated.duplicate(true))",
        ),
    )
    _require_order(
        errors,
        "MainGame echo reader",
        reader,
        (
            'record.get("scene_background_id", "")',
            "if not recorded_background_id.is_empty():",
            "return ImageRegistry.get_background(recorded_background_id)",
            "if GameState.is_story_weekly_commitment_record(record):",
        ),
    )
    _require_fragments(
        errors,
        "MainGame echo consume routing",
        auto_week,
        (
            "GameState.consume_weekly_commitment_echoes(2)",
            'if kind == "echo" else []',
            "_render_demo_director_beat(kind, used, narrative_bridge_results, commitment_echoes)",
        ),
    )
    _require_fragments(
        errors,
        "MainGame echo background application",
        render_beat,
        (
            'if kind == "echo" and not commitment_echoes.is_empty()',
            "beat_bg = _scene_background_for_commitment(commitment_echoes.back())",
            "_apply_event_bg_path(beat_bg)",
            "_set_scene_ambience_for_background(beat_bg, event_title.text)",
        ),
    )


def validate_sources(sources: Dict[str, str]) -> List[str]:
    errors: List[str] = []
    parsed_json: Dict[str, Any] = {}
    for key in ("events", "director"):
        try:
            parsed_json[key] = json.loads(sources[key])
        except (KeyError, TypeError, json.JSONDecodeError) as exc:
            errors.append("%s JSON could not be loaded: %s" % (key, exc))
            parsed_json[key] = None

    required_text = ("main_game", "story_mode", "game_state", "image_registry")
    for key in required_text:
        if not isinstance(sources.get(key), str) or not sources[key]:
            errors.append("%s source is missing" % key)
    if any(not sources.get(key) for key in required_text):
        return errors

    _validate_rows(sources["main_game"], sources["image_registry"], errors)
    _validate_current_home_contract(
        sources["image_registry"], sources["game_state"], errors
    )
    _validate_routine_runtime_wiring(
        sources["main_game"], sources["game_state"], errors
    )
    _validate_w220_data(parsed_json["events"], parsed_json["director"], errors)
    _validate_w220_code(
        sources["story_mode"], sources["game_state"], sources["main_game"], errors
    )
    return errors


def load_sources() -> Tuple[Dict[str, str], List[str]]:
    sources: Dict[str, str] = {}
    errors: List[str] = []
    for key, path in PATHS.items():
        try:
            sources[key] = path.read_text(encoding="utf-8")
        except OSError as exc:
            sources[key] = ""
            errors.append("%s could not be read: %s" % (path.relative_to(ROOT), exc))
    return sources, errors


def _mutate_once(source: str, old: str, new: str, label: str) -> str:
    if source.count(old) != 1:
        raise AssertionError(
            "%s mutation anchor count expected=1 actual=%d" % (label, source.count(old))
        )
    return source.replace(old, new, 1)


def _mutate_function_once(
    source: str, function_name: str, old: str, new: str, label: str
) -> str:
    block = _extract_function(source, function_name)
    mutated = _mutate_once(block, old, new, label)
    return source.replace(block, mutated, 1)


def _json_mutation(source: str, mutation: Any) -> str:
    value = json.loads(source)
    mutation(value)
    return json.dumps(value, ensure_ascii=False, sort_keys=True, separators=(",", ":"))


def run_self_test() -> int:
    baseline, load_errors = load_sources()
    baseline_errors = load_errors + validate_sources(baseline)
    if baseline_errors:
        raise AssertionError("baseline rejected: %s" % "; ".join(baseline_errors))

    cases: List[Tuple[str, Dict[str, str], str]] = []

    def add_text_case(
        label: str, key: str, old: str, new: str, expected_error: str
    ) -> None:
        mutated = copy.deepcopy(baseline)
        mutated[key] = _mutate_once(mutated[key], old, new, label)
        cases.append((label, mutated, expected_error))

    add_text_case(
        "save exact location",
        "main_game",
        'Made it through the day on 2,000 won of ingredients.", "background":"current_home_cooking"',
        'Made it through the day on 2,000 won of ingredients.", "background":"convenience_night"',
        "_SAVE_SCENES background mismatch row=0",
    )
    add_text_case(
        "rest exact location",
        "main_game",
        '"background":"park_bench_day"',
        '"background":"current_housing"',
        "REST_VIGNETTES background mismatch row=5",
    )
    add_text_case(
        "source projection",
        "main_game",
        "Made it through the day on 2,000 won of ingredients.",
        "Made it through today on 2,000 won of ingredients.",
        "_SAVE_SCENES source projection SHA256 mismatch",
    )
    add_text_case(
        "row key allowlist",
        "main_game",
        '"background":"hangang_riverside"}',
        '"background":"hangang_riverside","note":"drift"}',
        "REST_VIGNETTES unexpected keys row=0",
    )
    add_text_case(
        "registry exact path",
        "image_registry",
        '"park_bench_day":    "res://assets/backgrounds/park_bench_day.png"',
        '"park_bench_day":    "res://assets/backgrounds/street_seoul_day.png"',
        "ImageRegistry background path mismatch id=park_bench_day",
    )

    mutated = copy.deepcopy(baseline)
    mutated["image_registry"] = _mutate_function_once(
        mutated["image_registry"],
        "resolve_contextual_background_id",
        'return "goshiwon_shared_kitchen"',
        'return "goshiwon_room"',
        "cooking resolver",
    )
    cases.append(
        (
            "cooking resolver",
            mutated,
            "current_home_cooking resolver code contract",
        )
    )

    mutated = copy.deepcopy(baseline)
    mutated["story_mode"] = _mutate_function_once(
        mutated["story_mode"],
        "_on_choice",
        'commitment_contract["scene_background_id"] = commitment_background_id',
        'commitment_contract["discarded_background_id"] = commitment_background_id',
        "story producer",
    )
    cases.append(("story producer", mutated, "StoryMode producer order"))

    mutated = copy.deepcopy(baseline)
    mutated["game_state"] = _mutate_function_once(
        mutated["game_state"],
        "record_story_weekly_commitment",
        'record["scene_background_id"] = scene_background_id',
        'record["discarded_background_id"] = scene_background_id',
        "receipt writer",
    )
    cases.append(("receipt writer", mutated, "GameState W220 receipt writer"))

    mutated = copy.deepcopy(baseline)
    mutated["game_state"] = _mutate_function_once(
        mutated["game_state"],
        "consume_weekly_commitment_echoes",
        'updated["echoed_turn"] = turn',
        'updated["echoed_turn"] = -1',
        "echo consumer",
    )
    cases.append(("echo consumer", mutated, "GameState echo consumer"))

    mutated = copy.deepcopy(baseline)
    mutated["main_game"] = _mutate_function_once(
        mutated["main_game"],
        "_scene_background_for_commitment",
        'record.get("scene_background_id", "")',
        'record.get("discarded_background_id", "")',
        "echo reader",
    )
    cases.append(("echo reader", mutated, "MainGame echo reader"))

    mutated = copy.deepcopy(baseline)

    def mutate_w220(events: Any) -> None:
        event = _find_event(events, W220_EVENT_ID)
        if event is None:
            raise AssertionError("W220 fixture event missing")
        event["choices"][1]["result_background"] = "current_housing"

    mutated["events"] = _json_mutation(mutated["events"], mutate_w220)
    cases.append(("W220 authored result", mutated, "W220 choice1 result background must be cafe"))

    mutated = copy.deepcopy(baseline)

    def mutate_w220_home_ambience(events: Any) -> None:
        event = _find_event(events, W220_EVENT_ID)
        if event is None:
            raise AssertionError("W220 fixture event missing")
        event["choices"][0]["result_ambience"] = "cafe"

    mutated["events"] = _json_mutation(
        mutated["events"], mutate_w220_home_ambience
    )
    cases.append(
        (
            "W220 home ambience",
            mutated,
            "W220 choice0 must retain the settled root home location and ambience",
        )
    )

    mutated = copy.deepcopy(baseline)

    def mutate_echo_week(director: Any) -> None:
        director["full_run_pacing"]["echo_weeks"].remove(231)

    mutated["director"] = _json_mutation(mutated["director"], mutate_echo_week)
    cases.append(("W231 schedule", mutated, "full_run_pacing echo_weeks missing W231"))

    for label, sources, expected_error in cases:
        errors = validate_sources(sources)
        if not any(expected_error in error for error in errors):
            raise AssertionError(
                "%s mutation was not rejected by %r; errors=%r"
                % (label, expected_error, errors)
            )
    return len(cases)


def main(argv: Optional[Iterable[str]] = None) -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--self-test", action="store_true")
    args = parser.parse_args(list(argv) if argv is not None else None)
    if args.self_test:
        try:
            cases = run_self_test()
        except (AssertionError, AuditParseError, OSError, ValueError) as exc:
            print("ROUTINE_BACKGROUND_CONTEXT_AUDIT_SELF_TEST_FAIL %s" % exc)
            return 1
        print("ROUTINE_BACKGROUND_CONTEXT_AUDIT_SELF_TEST_OK cases=%d" % cases)
        return 0

    sources, load_errors = load_sources()
    errors = load_errors + validate_sources(sources)
    if errors:
        print("ROUTINE_BACKGROUND_CONTEXT_AUDIT_FAIL errors=%d" % len(errors))
        for error in errors:
            print("  ERROR %s" % error)
        return 1
    print(
        "ROUTINE_BACKGROUND_CONTEXT_AUDIT_OK "
        "save_rows=5 rest_rows=10 source_hashes=2 allowed_backgrounds=8 "
        "sentinels=2 current_home_cooking=1 w220_record_echo=1 human_gate=OPEN"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
