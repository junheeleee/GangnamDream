#!/usr/bin/env python3
"""Trace authored audio ownership through two representative 240-week runs."""

from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path
from typing import Any

from full_run_pacing_audit import lists
from narrative_continuity_audit import load_events, run_arc_paths


ROOT = Path(__file__).resolve().parents[1]
SCENE_MANIFEST_PATH = ROOT / "assets" / "scene_audio_manifest.json"
GAME_MANIFEST_PATH = ROOT / "assets" / "game_audio_manifest.json"
DIRECTOR_PATH = ROOT / "content" / "meta" / "event_director.json"
ENDINGS_PATH = ROOT / "content" / "endings.json"
ENDINGS_EN_PATH = ROOT / "content" / "endings_en.json"
PRIVATE_DYNAMIC_BACKGROUNDS = {"current_housing", "late_night", "investment_phone"}


def load_json(path: Path) -> Any:
    with path.open(encoding="utf-8") as handle:
        return json.load(handle)


def grouped_intents(manifest: dict[str, Any]) -> dict[str, str]:
    owners: dict[str, str] = {}
    groups = manifest.get("event_intents", {})
    if not isinstance(groups, dict):
        return owners
    for group, event_ids in groups.items():
        if not isinstance(event_ids, list):
            continue
        for event_id in event_ids:
            owners[str(event_id)] = str(group)
    return owners


def housing_for(route_index: int, week: int) -> str:
    if week <= 48:
        return "room"
    if route_index == 0:
        return "oneroom" if week <= 144 else "apartment"
    return "oneroom" if week <= 96 else "apartment"


def resolve_dynamic(key: str, route_index: int, week: int) -> str:
    if key == "current_housing":
        return housing_for(route_index, week)
    if key == "current_workplace":
        return "office"
    return key


def event_surface(
    event_id: str,
    event: dict[str, Any],
    manifest: dict[str, Any],
    intents: dict[str, str],
    route_index: int,
    week: int,
) -> tuple[str, str, str]:
    event_contracts = manifest.get("events", {})
    cg_contracts = manifest.get("cg", {})
    profiles = manifest.get("background_profiles", {})
    source = intents.get(event_id, "")
    contract: dict[str, Any] = {}
    if isinstance(event_contracts.get(event_id), dict):
        contract = event_contracts[event_id]
    elif source == "cg_contract":
        cg_id = str(event.get("cg", ""))
        raw_contract = cg_contracts.get(cg_id, {})
        if isinstance(raw_contract, dict):
            contract = raw_contract

    if source == "intentional_silence":
        return "", "", source
    ambience = str(contract.get("ambience", ""))
    if not ambience:
        background_id = str(event.get("background", ""))
        ambience = str(profiles.get(background_id, ""))
    ambience = resolve_dynamic(ambience, route_index, week)
    music = ""
    raw_music = contract.get("music")
    if isinstance(raw_music, dict):
        music = str(raw_music.get("key", ""))
    return ambience, music, source


def chapter_of(week: int) -> int:
    return min(5, (week - 1) // 48 + 1)


def ending_by_id(path: Path) -> dict[str, dict[str, Any]]:
    payload = load_json(path)
    return {
        str(ending["id"]): ending
        for ending in payload
        if isinstance(ending, dict) and ending.get("id")
    }


def trace_run(
    route_name: str,
    route_index: int,
    firelog: dict[int, str],
    locale: str,
    events: dict[str, dict[str, Any]],
    manifest: dict[str, Any],
    intents: dict[str, str],
    director: dict[str, Any],
    ending_id: str,
) -> tuple[list[dict[str, Any]], list[str]]:
    errors: list[str] = []
    direct = lists(director, "decision_weeks")
    bosses = lists(director, "boss_weeks")
    echoes = lists(director, "echo_weeks")
    trace: list[dict[str, Any]] = []
    previous_ambience = ""
    ambience_starts = 0

    for week in range(1, 241):
        event_id = str(firelog.get(week, ""))
        housing = housing_for(route_index, week)
        if event_id:
            event = events.get(event_id)
            if not isinstance(event, dict):
                errors.append(f"{route_name}: week {week} missing event {event_id}")
                continue
            ambience, music, source = event_surface(
                event_id, event, manifest, intents, route_index, week
            )
            surface = "event"
            background = str(event.get("background", ""))
            contract = manifest.get("events", {}).get(event_id, {})
            if (
                week > 48
                and background in PRIVATE_DYNAMIC_BACKGROUNDS
                and isinstance(contract, dict)
                and contract.get("ambience") == "room"
            ):
                errors.append(
                    f"{route_name}: week {week} {event_id} hardcodes the old goshiwon"
                )
        else:
            ambience = housing
            music = ""
            source = "weekly_profile"
            background = "current_housing"
            if week in bosses:
                surface = "boss"
            elif week in direct:
                surface = "decision"
            elif week in echoes:
                surface = "echo"
            else:
                surface = "quiet"
        if not ambience:
            errors.append(
                f"{route_name}: week {week} {event_id or surface} has no resolved ambience"
            )
        restarted = bool(ambience and ambience != previous_ambience)
        if restarted:
            ambience_starts += 1
        trace.append(
            {
                "week": week,
                "chapter": chapter_of(week),
                "surface": surface,
                "event_id": event_id,
                "background": background,
                "housing": housing,
                "ambience": ambience,
                "music": music,
                "intent": source,
                "ambience_restart": restarted,
                "locale": locale,
            }
        )
        previous_ambience = ambience

    ending = ending_by_id(ENDINGS_PATH).get(ending_id, {})
    ending_cg = str(ending.get("cg", ""))
    ending_contract = manifest.get("cg", {}).get(ending_cg, {})
    ending_ambience = (
        str(ending_contract.get("ambience", ""))
        if isinstance(ending_contract, dict)
        else ""
    )
    if not ending_ambience:
        errors.append(f"{route_name}: ending {ending_id} lacks CG ambience")
    trace.append(
        {
            "week": 240,
            "chapter": 5,
            "surface": "ending",
            "event_id": ending_id,
            "background": ending_cg,
            "housing": housing_for(route_index, 240),
            "ambience": ending_ambience,
            "music": "ending_good" if route_index == 0 else "ending_bad",
            "intent": "ending_cg",
            "ambience_restart": ending_ambience != previous_ambience,
            "locale": locale,
        }
    )

    chapter_rows = {
        chapter: [row for row in trace if row["chapter"] == chapter]
        for chapter in range(1, 6)
    }
    for chapter, rows in chapter_rows.items():
        authored = sum(
            row["intent"] in {"event_contract", "cg_contract"} for row in rows
        )
        profiled = sum(
            row["intent"] in {"rendered_profile", "weekly_profile"} for row in rows
        )
        scored = sum(bool(row["music"]) for row in rows)
        if authored == 0:
            errors.append(f"{route_name}: chapter {chapter} has no authored audio scene")
        if profiled == 0:
            errors.append(f"{route_name}: chapter {chapter} has no profiled connective scene")
        if scored == 0:
            errors.append(f"{route_name}: chapter {chapter} has no authored music entrance")

    trace[0]["ambience_start_count"] = ambience_starts
    return trace, errors


def parity_signature(trace: list[dict[str, Any]]) -> list[tuple[Any, ...]]:
    return [
        (
            row["week"],
            row["surface"],
            row["event_id"],
            row["ambience"],
            row["music"],
            row["intent"],
        )
        for row in trace
    ]


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--output-dir", type=Path)
    args = parser.parse_args()
    try:
        scene_manifest = load_json(SCENE_MANIFEST_PATH)
        game_manifest = load_json(GAME_MANIFEST_PATH)
        director = load_json(DIRECTOR_PATH)
        events = load_events()
        paths = run_arc_paths()
        intents = grouped_intents(scene_manifest)
        endings_ko = ending_by_id(ENDINGS_PATH)
        endings_en = ending_by_id(ENDINGS_EN_PATH)
    except (OSError, ValueError, json.JSONDecodeError) as exc:
        print(f"FULL_RUN_AUDIO_AUDIT_FAIL {exc}", file=sys.stderr)
        return 1

    errors: list[str] = []
    if set(endings_ko) != set(endings_en):
        errors.append("KO/EN ending catalogs differ")
    activity_ambience = game_manifest.get("activity_ambience", {})
    if not isinstance(activity_ambience, dict) or len(activity_ambience) < 7:
        errors.append("activity ambience contracts are incomplete")
    elif any(not str(row.get("key", "")) for row in activity_ambience.values()):
        errors.append("an activity has no ambience owner")

    route_endings = ["orthodox_pinnacle", "unorthodox_legend"]
    reports: dict[str, list[dict[str, Any]]] = {}
    for route_index, (route_name, firelog) in enumerate(paths.items()):
        localized: dict[str, list[dict[str, Any]]] = {}
        for locale in ("ko", "en"):
            trace, trace_errors = trace_run(
                route_name,
                route_index,
                firelog,
                locale,
                events,
                scene_manifest,
                intents,
                director,
                route_endings[route_index],
            )
            localized[locale] = trace
            reports[f"route_{route_index + 1}_{locale}"] = trace
            errors.extend(trace_errors)
        if parity_signature(localized["ko"]) != parity_signature(localized["en"]):
            errors.append(f"{route_name}: KO/EN audio trace differs")

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
            print(f"FULL_RUN_AUDIO_AUDIT_FAIL {error}", file=sys.stderr)
        return 1

    for route_index, route_name in enumerate(paths):
        trace = reports[f"route_{route_index + 1}_ko"]
        chapter_summary = []
        for chapter in range(1, 6):
            rows = [row for row in trace if row["chapter"] == chapter]
            chapter_summary.append(
                f"{chapter}:events={sum(bool(row['event_id']) for row in rows)}"
                f"/music={sum(bool(row['music']) for row in rows)}"
                f"/places={len({row['ambience'] for row in rows})}"
            )
        print(
            "FULL_RUN_AUDIO_PATH "
            f"route={route_index + 1} weeks=240 ending={route_endings[route_index]} "
            f"ambience_starts={trace[0]['ambience_start_count']} "
            f"chapters={';'.join(chapter_summary)}"
        )
    print(
        "FULL_RUN_AUDIO_AUDIT_OK "
        f"routes={len(paths)} locales=ko/en weeks={len(paths) * 2 * 240} "
        f"activities={len(activity_ambience)} endings=2"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
