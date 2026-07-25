#!/usr/bin/env python3
"""Audit scene direction and A/V ownership across shipping data and 240-week traces."""

from __future__ import annotations

import argparse
import json
import sys
from collections import Counter
from pathlib import Path
from typing import Any

from full_run_audio_audit import (
    event_surface,
    grouped_intents as grouped_audio_intents,
    housing_for,
)
from full_run_pacing_audit import lists
from narrative_continuity_audit import load_events, run_arc_paths


ROOT = Path(__file__).resolve().parents[1]
DIRECTION_PATH = ROOT / "assets" / "scene_direction_manifest.json"
AUDIO_PATH = ROOT / "assets" / "scene_audio_manifest.json"
DIRECTOR_PATH = ROOT / "content" / "meta" / "event_director.json"
ENDINGS_PATH = ROOT / "content" / "endings.json"
ENDINGS_EN_PATH = ROOT / "content" / "endings_en.json"

INTENTS = {
    "none",
    "same_location",
    "time_cut",
    "explicit_move",
    "memory_cut",
    "remote",
    "activity_enter_return",
    "finale",
}
CAMERAS = {"none", "slow_zoom", "living_push", "living_drift"}
EFFECTS = {"none", "rain", "snow", "fog", "fireworks", "city_light", "memory"}
PRECIPITATION = {"rain", "snow"}
INDOOR_FORBIDDEN = {"rain", "snow", "fog", "fireworks"}
AUDIO_BY_MODE = {
    "none": {"continue"},
    "same_location": {"continue"},
    "remote": {"continue", "duck"},
    "time_cut": {"crossfade"},
    "explicit_move": {"crossfade"},
    "memory_cut": {"duck"},
    "activity_enter_return": {"crossfade"},
    "finale": {"crossfade"},
}
ROUTE_ENDINGS = ["orthodox_pinnacle", "unorthodox_legend"]


def load_json(path: Path) -> Any:
    with path.open(encoding="utf-8") as handle:
        return json.load(handle)


def flatten_direction_intents(manifest: dict[str, Any]) -> tuple[dict[str, str], list[str]]:
    owners: dict[str, str] = {}
    errors: list[str] = []
    groups = manifest.get("event_intents", {})
    if not isinstance(groups, dict):
        return owners, ["event_intents is not a dictionary"]
    for intent, event_ids in groups.items():
        if intent not in INTENTS:
            errors.append(f"unknown intent group {intent}")
        if not isinstance(event_ids, list):
            errors.append(f"intent group {intent} is not a list")
            continue
        for event_id in event_ids:
            key = str(event_id)
            if key in owners:
                errors.append(f"event {key} is classified twice")
            owners[key] = str(intent)
    return owners, errors


def ending_ids(path: Path) -> set[str]:
    payload = load_json(path)
    return {
        str(row["id"])
        for row in payload
        if isinstance(row, dict) and row.get("id")
    }


def chapter_of(week: int) -> int:
    return min(5, (week - 1) // 48 + 1)


def visual_surface(
    event_id: str,
    event: dict[str, Any],
    direction: dict[str, Any],
    intents: dict[str, str],
) -> tuple[str, str, dict[str, Any]]:
    intent = intents.get(event_id, "")
    background = str(event.get("background", "current_housing"))
    profiles = direction.get("background_profiles", {})
    profile = profiles.get(background, {}) if isinstance(profiles, dict) else {}
    return intent, background, profile if isinstance(profile, dict) else {}


def trace_route(
    route_name: str,
    route_index: int,
    firelog: dict[int, str],
    locale: str,
    events: dict[str, dict[str, Any]],
    direction: dict[str, Any],
    direction_intents: dict[str, str],
    audio: dict[str, Any],
    audio_intents: dict[str, str],
    director: dict[str, Any],
) -> tuple[list[dict[str, Any]], list[str]]:
    errors: list[str] = []
    direct = lists(director, "decision_weeks")
    bosses = lists(director, "boss_weeks")
    echoes = lists(director, "echo_weeks")
    trace: list[dict[str, Any]] = []
    previous_ambience = ""

    for week in range(1, 241):
        event_id = str(firelog.get(week, ""))
        if event_id:
            event = events.get(event_id, {})
            intent, background, profile = visual_surface(
                event_id, event, direction, direction_intents
            )
            ambience, music, audio_source = event_surface(
                event_id,
                event,
                audio,
                audio_intents,
                route_index,
                week,
            )
            surface = "event"
        else:
            event = {}
            intent = "same_location"
            background = "current_housing"
            profile = direction.get("background_profiles", {}).get(background, {})
            ambience = housing_for(route_index, week)
            music = ""
            audio_source = "weekly_profile"
            if week in bosses:
                surface = "boss"
            elif week in direct:
                surface = "decision"
            elif week in echoes:
                surface = "echo"
            else:
                surface = "quiet"

        if not intent:
            errors.append(f"{route_name}: week {week} {event_id} has no visual intent")
        if not isinstance(profile, dict) or not profile:
            errors.append(
                f"{route_name}: week {week} {event_id or surface} "
                f"has no background profile for {background}"
            )
            profile = {}
        if not ambience:
            errors.append(
                f"{route_name}: week {week} {event_id or surface} has no ambience owner"
            )

        trace.append(
            {
                "week": week,
                "chapter": chapter_of(week),
                "surface": surface,
                "event_id": event_id,
                "visual_intent": intent,
                "background": background,
                "environment": str(profile.get("environment", "")),
                "depth": str(profile.get("depth", "")),
                "effect": str(profile.get("effect", "")),
                "camera": str(profile.get("camera", "")),
                "ambience": ambience,
                "music": music,
                "audio_source": audio_source,
                "ambience_restart": bool(
                    ambience and previous_ambience and ambience != previous_ambience
                ),
                "locale": locale,
            }
        )
        previous_ambience = ambience

    ending_id = ROUTE_ENDINGS[route_index]
    ending_contract = direction.get("ending_contracts", {}).get(ending_id, {})
    trace.append(
        {
            "week": 240,
            "chapter": 5,
            "surface": "ending",
            "event_id": ending_id,
            "visual_intent": str(ending_contract.get("mode", "")),
            "background": "",
            "environment": "",
            "depth": "",
            "effect": "none",
            "camera": "none",
            "ambience": "",
            "music": "ending_good" if route_index == 0 else "ending_bad",
            "audio_source": "ending",
            "ambience_restart": False,
            "locale": locale,
        }
    )

    for chapter in range(1, 6):
        rows = [row for row in trace if row["chapter"] == chapter]
        if not any(row["event_id"] for row in rows):
            errors.append(f"{route_name}: chapter {chapter} has no authored scene")
        if len({row["background"] for row in rows}) < 2:
            errors.append(f"{route_name}: chapter {chapter} has no spatial variation")
        if not any(row["ambience"] for row in rows):
            errors.append(f"{route_name}: chapter {chapter} has no audible space")
    return trace, errors


def parity_signature(trace: list[dict[str, Any]]) -> list[tuple[Any, ...]]:
    keys = (
        "week",
        "surface",
        "event_id",
        "visual_intent",
        "background",
        "effect",
        "camera",
        "ambience",
        "music",
        "audio_source",
    )
    return [tuple(row[key] for key in keys) for row in trace]


def validate_manifest(
    direction: dict[str, Any],
    events: dict[str, dict[str, Any]],
    intents: dict[str, str],
) -> list[str]:
    errors: list[str] = []
    event_ids = set(events)
    if set(intents) != event_ids:
        missing = sorted(event_ids - set(intents))
        extra = sorted(set(intents) - event_ids)
        errors.append(
            f"event classification mismatch missing={missing[:5]} extra={extra[:5]}"
        )

    policy = direction.get("policy", {})
    if not isinstance(policy, dict) or policy.get("unknown_transition") != "none":
        errors.append("unknown transitions do not fail closed to none")
    if not bool(policy.get("reduce_motion_preserves_order", False)):
        errors.append("Reduce Motion does not preserve scene order")
    if bool(policy.get("prose_inference", True)):
        errors.append("direction still infers effects from prose")

    profiles = direction.get("background_profiles", {})
    if not isinstance(profiles, dict) or not profiles:
        errors.append("background profiles are missing")
        profiles = {}
    for background_id, profile in profiles.items():
        if not isinstance(profile, dict):
            errors.append(f"background {background_id} profile is invalid")
            continue
        effect = str(profile.get("effect", ""))
        camera = str(profile.get("camera", ""))
        environment = str(profile.get("environment", ""))
        if effect not in EFFECTS:
            errors.append(f"background {background_id} has unknown effect {effect}")
        if camera not in CAMERAS:
            errors.append(f"background {background_id} has unknown camera {camera}")
        if environment == "indoor" and effect in INDOOR_FORBIDDEN:
            errors.append(f"background {background_id} invents indoor {effect}")
        if effect in PRECIPITATION and profile.get("weather_source") == "none":
            errors.append(f"background {background_id} has unauthored {effect}")
        if float(profile.get("intensity", 0.0)) < 0.0:
            errors.append(f"background {background_id} has negative intensity")

    edges = direction.get("transition_edges", {})
    if not isinstance(edges, dict) or not edges:
        errors.append("transition edge registry is missing")
        edges = {}
    for edge_id, contract in edges.items():
        if not isinstance(contract, dict):
            errors.append(f"edge {edge_id} has invalid contract")
            continue
        mode = str(contract.get("mode", ""))
        audio_policy = str(contract.get("audio_policy", ""))
        if mode not in INTENTS:
            errors.append(f"edge {edge_id} has unknown mode {mode}")
        elif audio_policy not in AUDIO_BY_MODE.get(mode, set()):
            errors.append(
                f"edge {edge_id} mode {mode} conflicts with audio {audio_policy}"
            )
        if mode == "same_location" and (
            contract.get("from_surface") != contract.get("to_surface")
        ):
            errors.append(f"edge {edge_id} claims same_location across surfaces")
        if not str(contract.get("reduced_motion", "")):
            errors.append(f"edge {edge_id} lacks reduced-motion replacement")

    activities = direction.get("activity_contracts", {})
    if not isinstance(activities, dict) or len(activities) < 7:
        errors.append("activity direction contracts are incomplete")
    else:
        for activity_id, contract in activities.items():
            if not isinstance(contract, dict):
                errors.append(f"activity {activity_id} contract is invalid")
                continue
            if contract.get("mode") != "activity_enter_return":
                errors.append(f"activity {activity_id} uses the wrong transition mode")
            if not all(str(contract.get(key, "")) for key in ("entry", "return", "ambience")):
                errors.append(f"activity {activity_id} lacks entry/return/audio ownership")

    endings = direction.get("ending_contracts", {})
    ko_endings = ending_ids(ENDINGS_PATH)
    en_endings = ending_ids(ENDINGS_EN_PATH)
    if ko_endings != en_endings:
        errors.append("KO/EN ending IDs differ")
    if not isinstance(endings, dict) or set(endings) != ko_endings:
        errors.append("not all 35 endings have finale direction contracts")
    else:
        for ending_id, contract in endings.items():
            if contract.get("mode") != "finale":
                errors.append(f"ending {ending_id} is not a finale")
            if float(contract.get("reveal_seconds", 0.0)) <= 0.0:
                errors.append(f"ending {ending_id} has no reveal time")
            if contract.get("reduced_motion") != "static_fade":
                errors.append(f"ending {ending_id} lacks static Reduce Motion finale")
    return errors


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--output-dir", type=Path)
    args = parser.parse_args()
    try:
        direction = load_json(DIRECTION_PATH)
        audio = load_json(AUDIO_PATH)
        director = load_json(DIRECTOR_PATH)
        events = load_events()
        paths = run_arc_paths()
    except (OSError, ValueError, json.JSONDecodeError) as exc:
        print(f"FULL_RUN_DIRECTION_AUDIT_FAIL {exc}", file=sys.stderr)
        return 1

    direction_intents, errors = flatten_direction_intents(direction)
    errors.extend(validate_manifest(direction, events, direction_intents))
    audio_intents = grouped_audio_intents(audio)
    reports: dict[str, list[dict[str, Any]]] = {}

    for route_index, (route_name, firelog) in enumerate(paths.items()):
        localized: dict[str, list[dict[str, Any]]] = {}
        for locale in ("ko", "en"):
            trace, trace_errors = trace_route(
                route_name,
                route_index,
                firelog,
                locale,
                events,
                direction,
                direction_intents,
                audio,
                audio_intents,
                director,
            )
            localized[locale] = trace
            reports[f"route_{route_index + 1}_{locale}"] = trace
            errors.extend(trace_errors)
        if parity_signature(localized["ko"]) != parity_signature(localized["en"]):
            errors.append(f"{route_name}: KO/EN scene direction differs")

    if args.output_dir:
        output_dir = args.output_dir
        if not output_dir.is_absolute():
            output_dir = ROOT / output_dir
        output_dir.mkdir(parents=True, exist_ok=True)
        for name, trace in reports.items():
            (output_dir / f"{name}.json").write_text(
                json.dumps(trace, ensure_ascii=False, indent=2) + "\n",
                encoding="utf-8",
            )

    if errors:
        for error in errors:
            print(f"FULL_RUN_DIRECTION_AUDIT_FAIL {error}", file=sys.stderr)
        return 1

    for route_index, route_name in enumerate(paths):
        trace = reports[f"route_{route_index + 1}_ko"]
        intent_counts = Counter(row["visual_intent"] for row in trace)
        effect_counts = Counter(row["effect"] for row in trace)
        print(
            "FULL_RUN_DIRECTION_PATH "
            f"route={route_index + 1} weeks=240 ending={ROUTE_ENDINGS[route_index]} "
            f"intents={dict(sorted(intent_counts.items()))} "
            f"effects={dict(sorted(effect_counts.items()))}"
        )
    print(
        "FULL_RUN_DIRECTION_AUDIT_OK "
        f"events={len(events)} edges={len(direction['transition_edges'])} "
        f"backgrounds={len(direction['background_profiles'])} "
        f"activities={len(direction['activity_contracts'])} "
        f"endings={len(direction['ending_contracts'])} "
        f"routes={len(paths)} locales=ko/en weeks={len(paths) * 2 * 240}"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
