#!/usr/bin/env python3
"""Build and validate the full-run scene-direction contract.

Shipping runtime must not infer transition physics from localized prose. This
catalog locks every event, follow-up edge, registered background, activity, and
ending to a reviewed semantic intent. New content fails the gate until the
manifest is regenerated and reviewed.
"""

from __future__ import annotations

import argparse
import glob
import json
import re
import sys
from collections import defaultdict
from pathlib import Path
from typing import Any


ROOT = Path(__file__).resolve().parents[1]
MANIFEST_PATH = ROOT / "assets" / "scene_direction_manifest.json"
EVENT_DIR = ROOT / "content" / "events"
EVENT_EN_DIR = ROOT / "content" / "events_en"
STORY_RULES_PATH = ROOT / "content" / "meta" / "story_rules.json"
VISUAL_CONTRACTS_PATH = ROOT / "assets" / "event_visual_contracts.json"
AUDIO_MANIFEST_PATH = ROOT / "assets" / "scene_audio_manifest.json"
IMAGE_REGISTRY_PATH = ROOT / "autoloads" / "ImageRegistry.gd"
ENDINGS_PATH = ROOT / "content" / "endings.json"

EVENT_INTENTS = (
    "none",
    "same_location",
    "time_cut",
    "explicit_move",
    "memory_cut",
    "remote",
    "activity_enter_return",
    "finale",
)
EDGE_MODES = set(EVENT_INTENTS)
EFFECTS = {"none", "rain", "snow", "memory", "city_light", "fireworks"}
CAMERAS = {"none", "living_drift", "living_push"}
ENVIRONMENTS = {"dynamic", "indoor", "outdoor", "transit", "digital"}
REDUCED_MOTION = {
    "none": "static_update",
    "same_location": "static_update",
    "remote": "static_update",
    "time_cut": "static_fade",
    "explicit_move": "static_fade",
    "memory_cut": "static_fade",
    "activity_enter_return": "static_fade",
    "finale": "static_fade",
}

REMOTE_CHANNELS = {"phone", "video_call", "message"}
TIME_ID_PREFIXES = ("callback_", "chapter_card_", "chapter_break_")
TIME_ID_TOKENS = (
    "_later",
    "_morning_after",
    "_next_",
    "_after_visit",
    "_years_later",
)
TIME_TAGS = {"callback", "echo", "milestone", "chapter"}

RAIN_BACKGROUNDS = {"street_rainy", "street_rainy_bus_stop_wallet"}
SNOW_BACKGROUNDS = {
    "convenience_first_snow_exterior",
    "year2_winter_street_night",
    "year3_hangang_winter_night",
    "year4_winter_rooftop",
}
CITY_LIGHT_BACKGROUNDS = {
    "hangang_riverside",
    "namsan_tower",
    "namsan_observation_deck",
    "rooftop_night",
    "gangnam_night",
}
DYNAMIC_BACKGROUNDS = {"current_housing", "current_workplace"}
DIGITAL_BACKGROUNDS = {"open_chat_screen", "investment", "investment_phone"}
TRANSIT_BACKGROUNDS = {
    "subway",
    "seoul_bus_terminal_night",
    "chuseok_highway",
    "namsan_cable_car",
    "hometown_train_station",
    "seoul_station_ktx_platform_winter",
    "ktx_window",
    "regional_train_window",
    "jiyeon_sedan_night",
    "jiyeon_sedan_first_snow",
}
INDOOR_BACKGROUNDS = {
    "goshiwon",
    "goshiwon_room",
    "goshiwon_hallway",
    "goshiwon_shared_kitchen",
    "v2_first_bill_desk_closeup",
    "convenience_night",
    "cafe",
    "gukbap_restaurant_night",
    "namsan_tonkatsu_restaurant",
    "amusement_photo_booth",
    "suneung_test_hall",
    "community_center",
    "jjimjilbang",
    "saju_cafe",
    "company_dinner_restaurant",
    "open_chat_screen",
    "office",
    "office_interview_day",
    "warehouse_inventory_night",
    "realestate_office",
    "meeting",
    "sangchul_private_dining",
    "gangnam_apartment",
    "hospital",
    "hospital_clinic",
    "changwon_hospital_room_empty",
    "gym",
    "exercise",
    "dad_house",
    "daeun_mother_home_dining",
    "daeun_newlywed_home",
    "jiyeon_newlywed_home",
    "burnout",
    "penthouse",
    "gangnam_penthouse",
    "investment",
    "investment_phone",
    "trading",
    "trading_room",
    "pc_bang",
    "late_night",
    "library",
    "restaurant",
    "apartment",
    "apartment_balcony",
    "convenience_store",
    "racetrack_betting",
    "holdem_club",
    "casino",
    "jeongseon_casino_entrance",
    "scalping_room",
}

ACTIVITY_CONTRACTS = {
    "commitment_task": {
        "mode": "activity_enter_return",
        "ambience": "public_office",
        "entry": "covered_cut",
        "return": "static_fade",
    },
    "investment": {
        "mode": "activity_enter_return",
        "ambience": "office",
        "entry": "covered_cut",
        "return": "static_fade",
    },
    "job_hunt": {
        "mode": "activity_enter_return",
        "ambience": "office",
        "entry": "covered_cut",
        "return": "static_fade",
    },
    "delivery": {
        "mode": "activity_enter_return",
        "ambience": "street",
        "entry": "covered_cut",
        "return": "static_fade",
    },
    "racetrack": {
        "mode": "activity_enter_return",
        "ambience": "racetrack",
        "entry": "covered_cut",
        "return": "static_fade",
    },
    "holdem": {
        "mode": "activity_enter_return",
        "ambience": "casino",
        "entry": "covered_cut",
        "return": "static_fade",
    },
    "scalping": {
        "mode": "activity_enter_return",
        "ambience": "office",
        "entry": "covered_cut",
        "return": "static_fade",
    },
    "casino": {
        "mode": "activity_enter_return",
        "ambience": "casino",
        "entry": "covered_cut",
        "return": "static_fade",
    },
}

ENDING_FAMILIES = {
    "cold_hold": {"bankruptcy", "debt_spiral", "crypto_ghost"},
    "fade_out": {"burnout", "mental_break", "career_burnout"},
    "black_resolve": {
        "gangnam_dream",
        "gangnam_dream_white",
        "empty_house",
        "jaehyuk_way",
        "lonely_rich",
        "instant_legend",
        "full_circle",
    },
    "human_release": {
        "with_daeun",
        "second_love",
        "guardian",
        "late_call",
        "gambling_recovery",
        "sangchul_reckoning",
    },
    "ledger_resolve": {
        "orthodox_pinnacle",
        "career_climber",
        "political_fix",
        "startup_exit",
        "reputation_king",
    },
}


def load_json(path: Path) -> Any:
    with path.open(encoding="utf-8") as handle:
        return json.load(handle)


def load_events(directory: Path) -> dict[str, dict[str, Any]]:
    events: dict[str, dict[str, Any]] = {}
    for raw_path in sorted(glob.glob(str(directory / "*.json"))):
        payload = load_json(Path(raw_path))
        if not isinstance(payload, list):
            continue
        for event in payload:
            if isinstance(event, dict) and event.get("id"):
                events[str(event["id"])] = event
    return events


def registered_backgrounds() -> list[str]:
    source = IMAGE_REGISTRY_PATH.read_text(encoding="utf-8")
    try:
        block = source.split("const BACKGROUNDS = {", 1)[1].split("\n}", 1)[0]
    except IndexError as exc:
        raise ValueError("ImageRegistry BACKGROUNDS could not be parsed") from exc
    return re.findall(r'^\s*"([^"]+)"\s*:', block, re.M)


def visual_contract_index() -> dict[str, dict[str, Any]]:
    payload = load_json(VISUAL_CONTRACTS_PATH)
    rows = payload.get("contracts", []) if isinstance(payload, dict) else []
    return {
        str(row["id"]): row
        for row in rows
        if isinstance(row, dict) and row.get("id")
    }


def story_presentations() -> dict[str, dict[str, Any]]:
    payload = load_json(STORY_RULES_PATH)
    event_rules = payload.get("events", {}) if isinstance(payload, dict) else {}
    output: dict[str, dict[str, Any]] = {}
    if not isinstance(event_rules, dict):
        return output
    for event_id, rule in event_rules.items():
        presentation = rule.get("presentation", {}) if isinstance(rule, dict) else {}
        if isinstance(presentation, dict):
            output[str(event_id)] = presentation
    return output


def background_profile(background_id: str) -> dict[str, Any]:
    if background_id in DYNAMIC_BACKGROUNDS:
        environment = "dynamic"
    elif background_id in DIGITAL_BACKGROUNDS:
        environment = "digital"
    elif background_id in TRANSIT_BACKGROUNDS:
        environment = "transit"
    elif background_id in INDOOR_BACKGROUNDS:
        environment = "indoor"
    else:
        environment = "outdoor"

    effect = "none"
    intensity = 0.0
    camera = "none"
    weather_source = "none"
    if background_id in RAIN_BACKGROUNDS:
        effect, intensity, camera, weather_source = (
            "rain",
            0.24,
            "living_drift",
            "background",
        )
    elif background_id in SNOW_BACKGROUNDS:
        effect, intensity, camera, weather_source = (
            "snow",
            0.20,
            "living_drift",
            "background",
        )
    elif background_id in CITY_LIGHT_BACKGROUNDS:
        effect, intensity, camera = "city_light", 0.10, "living_drift"

    depth = {
        "dynamic": "mid",
        "digital": "flat",
        "transit": "mid",
        "indoor": "near",
        "outdoor": "far",
    }[environment]
    return {
        "environment": environment,
        "depth": depth,
        "effect": effect,
        "camera": camera,
        "intensity": intensity,
        "weather_source": weather_source,
    }


def normalize_surface(surface: str) -> str:
    aliases = {
        "convenience_store": "convenience_night",
        "current_location": "current_housing",
        "seoul_station_ktx_platform": "seoul_station_ktx_platform_winter",
        "changwon_hospital_room": "changwon_hospital_room_empty",
        "seoulbound_ktx_after_changwon": "ktx_window",
        "changwon_home": "dad_house",
        "changwon_factory": "current_workplace",
        "changwon_hospital": "hospital",
        "goshiwon_room": "goshiwon_room",
        "off_scene": "current_housing",
    }
    return aliases.get(surface, surface)


def cg_scene(cg_id: str, event_id: str) -> str:
    token = f"{event_id} {cg_id}".lower()
    if "wedding" in token:
        return "wedding_hall"
    if "firework" in token:
        return "hangang_riverside"
    if "sea_" in token or "beach" in token:
        return "beach"
    if "namsan" in token:
        return "namsan"
    return f"cg:{cg_id}"


def structured_surface(
    event_id: str,
    event: dict[str, Any],
    presentations: dict[str, dict[str, Any]],
    visuals: dict[str, dict[str, Any]],
) -> str:
    presentation = presentations.get(event_id, {})
    scene_location = str(presentation.get("scene_location", "")).strip()
    if scene_location:
        return normalize_surface(scene_location)
    background = str(event.get("background", "")).strip()
    if background:
        return normalize_surface(background)
    visual = visuals.get(event_id, {})
    visual_background = str(visual.get("background") or "").strip()
    if visual_background:
        return normalize_surface(visual_background)
    cg_id = str(event.get("cg", "") or visual.get("cg") or "").strip()
    if cg_id:
        return cg_scene(cg_id, event_id)

    tags = {str(tag).lower() for tag in event.get("tags", [])}
    category = str(event.get("category", "")).lower()
    if "racetrack" in tags or "race" in tags:
        return "racetrack_betting"
    if "holdem" in tags:
        return "holdem_club"
    if "casino" in tags or "jeongseon" in tags:
        return "casino"
    if "hospital" in tags or category == "health":
        return "hospital"
    if "office" in tags or "job" in tags or category == "jobs":
        return "office"
    if "family" in tags or category == "family":
        return "dad_house"
    if (
        "social" in tags
        or "relationship" in tags
        or "date" in tags
        or category in {"social", "relationship", "romance"}
    ):
        return "cafe"
    if (
        "finance" in tags
        or "investment" in tags
        or "gambling" in tags
        or category in {"finance", "investment", "gambling"}
    ):
        return "investment_phone"
    return "current_housing"


def is_finale(event_id: str, event: dict[str, Any]) -> bool:
    tags = {str(tag).lower() for tag in event.get("tags", [])}
    return "finale" in tags or event_id == "age_39_final"


def is_time_cut(event_id: str, event: dict[str, Any]) -> bool:
    tags = {str(tag).lower() for tag in event.get("tags", [])}
    return (
        event_id.startswith(TIME_ID_PREFIXES)
        or any(token in event_id for token in TIME_ID_TOKENS)
        or bool(tags & TIME_TAGS)
    )


def follow_up_edges(
    events: dict[str, dict[str, Any]],
) -> list[tuple[str, str]]:
    edges: set[tuple[str, str]] = set()
    for event_id, event in events.items():
        for choice in event.get("choices", []):
            if not isinstance(choice, dict):
                continue
            target = str(choice.get("follow_up_event", "")).strip()
            if target:
                edges.add((event_id, target))
    return sorted(edges)


def edge_mode(
    source_id: str,
    target_id: str,
    events: dict[str, dict[str, Any]],
    surfaces: dict[str, str],
    presentations: dict[str, dict[str, Any]],
    authored: dict[str, Any],
) -> str:
    source = events[source_id]
    target = events[target_id]
    target_channel = str(presentations.get(target_id, {}).get("channel", "in_person"))
    authored_mode = str(authored.get("mode", ""))
    same_surface = surfaces[source_id] == surfaces[target_id]

    if authored_mode in {"memory_cut", "time_cut", "explicit_move"}:
        return authored_mode
    if target_channel == "memory":
        return "memory_cut"
    if is_finale(target_id, target) and not is_finale(source_id, source):
        return "finale"
    if target_channel in REMOTE_CHANNELS and same_surface:
        return "remote"
    if authored_mode == "same_location":
        return "same_location"
    if is_time_cut(target_id, target):
        return "time_cut"
    if same_surface:
        return "same_location"
    return "explicit_move"


def edge_audio_policy(mode: str) -> str:
    return {
        "none": "continue",
        "same_location": "continue",
        "remote": "continue",
        "memory_cut": "duck",
        "time_cut": "crossfade",
        "explicit_move": "crossfade",
        "activity_enter_return": "crossfade_restore",
        "finale": "resolve",
    }[mode]


def runtime_story_edges(
    events: dict[str, dict[str, Any]],
    authored_edges: dict[str, Any],
) -> list[tuple[str, str]]:
    """Return both authored follow-ups and roots sequenced in one StoryMode queue."""
    pairs = set(follow_up_edges(events))
    for edge_id, raw_contract in authored_edges.items():
        if not isinstance(raw_contract, dict) or not raw_contract.get("queue_only", False):
            continue
        parts = str(edge_id).split("->")
        if len(parts) != 2:
            continue
        source_id, target_id = (part.strip() for part in parts)
        if source_id in events and target_id in events and source_id != target_id:
            pairs.add((source_id, target_id))
    return sorted(pairs)


def build_edge_contracts(
    events: dict[str, dict[str, Any]],
    surfaces: dict[str, str],
    presentations: dict[str, dict[str, Any]],
) -> dict[str, dict[str, Any]]:
    rules = load_json(STORY_RULES_PATH)
    authored_edges = rules.get("transition_contracts", {})
    if not isinstance(authored_edges, dict):
        authored_edges = {}
    contracts: dict[str, dict[str, Any]] = {}
    for source_id, target_id in runtime_story_edges(events, authored_edges):
        key = f"{source_id}->{target_id}"
        authored = authored_edges.get(key, {})
        authored = authored if isinstance(authored, dict) else {}
        mode = edge_mode(
            source_id,
            target_id,
            events,
            surfaces,
            presentations,
            authored,
        )
        contract = {
            "mode": mode,
            "from_surface": surfaces[source_id],
            "to_surface": surfaces[target_id],
            "audio_policy": edge_audio_policy(mode),
            "reduced_motion": REDUCED_MOTION[mode],
        }
        for key_name in ("arrival_cue_ko", "arrival_cue_en"):
            if authored.get(key_name):
                contract[key_name] = authored[key_name]
        contracts[key] = contract
    return contracts


def build_event_intents(
    events: dict[str, dict[str, Any]],
    presentations: dict[str, dict[str, Any]],
    edges: dict[str, dict[str, Any]],
) -> dict[str, list[str]]:
    inbound: dict[str, list[str]] = defaultdict(list)
    for edge_key, contract in edges.items():
        target = edge_key.split("->", 1)[1]
        inbound[target].append(str(contract["mode"]))

    groups = {intent: [] for intent in EVENT_INTENTS}
    for event_id in sorted(events):
        event = events[event_id]
        channel = str(presentations.get(event_id, {}).get("channel", "in_person"))
        modes = inbound.get(event_id, [])
        if is_finale(event_id, event):
            intent = "finale"
        elif channel == "memory":
            intent = "memory_cut"
        elif channel in REMOTE_CHANNELS:
            intent = "remote"
        elif is_time_cut(event_id, event):
            intent = "time_cut"
        elif modes and set(modes) == {"same_location"}:
            intent = "same_location"
        elif modes and "explicit_move" in modes:
            intent = "explicit_move"
        elif event.get("background") or event.get("cg"):
            intent = "explicit_move"
        else:
            intent = "none"
        groups[intent].append(event_id)
    return groups


def ending_contracts() -> dict[str, dict[str, Any]]:
    endings = load_json(ENDINGS_PATH)
    output: dict[str, dict[str, Any]] = {}
    for ending in endings:
        if not isinstance(ending, dict) or not ending.get("id"):
            continue
        ending_id = str(ending["id"])
        family = "quiet_resolve"
        for candidate, members in ENDING_FAMILIES.items():
            if ending_id in members:
                family = candidate
                break
        durations = {
            "cold_hold": (0.18, 0.72),
            "fade_out": (0.42, 0.74),
            "black_resolve": (0.34, 0.62),
            "human_release": (0.48, 0.58),
            "ledger_resolve": (0.28, 0.54),
            "quiet_resolve": (0.36, 0.58),
        }
        hold, reveal = durations[family]
        output[ending_id] = {
            "mode": "finale",
            "family": family,
            "hold_seconds": hold,
            "reveal_seconds": reveal,
            "reduced_motion": "static_fade",
        }
    return output


def build_manifest() -> dict[str, Any]:
    events = load_events(EVENT_DIR)
    presentations = story_presentations()
    visuals = visual_contract_index()
    surfaces = {
        event_id: structured_surface(event_id, event, presentations, visuals)
        for event_id, event in events.items()
    }
    edges = build_edge_contracts(events, surfaces, presentations)
    return {
        "version": 1,
        "updated": "2026-08-05",
        "policy": {
            "unknown_transition": "none",
            "same_location_restarts": False,
            "prose_inference": False,
            "reduce_motion_preserves_order": True,
        },
        "background_profiles": {
            background_id: background_profile(background_id)
            for background_id in registered_backgrounds()
        },
        "event_intents": build_event_intents(events, presentations, edges),
        "transition_edges": edges,
        "activity_contracts": ACTIVITY_CONTRACTS,
        "ending_contracts": ending_contracts(),
    }


def validate(manifest: dict[str, Any]) -> list[str]:
    errors: list[str] = []
    events = load_events(EVENT_DIR)
    events_en = load_events(EVENT_EN_DIR)
    if set(events) != set(events_en):
        errors.append("Korean and English event IDs differ")

    expected = build_manifest()
    if manifest != expected:
        errors.append(
            "scene direction manifest is stale; run "
            "python3 tools/scene_direction_catalog.py --write and review the diff"
        )

    profiles = manifest.get("background_profiles", {})
    if not isinstance(profiles, dict):
        return errors + ["background_profiles must be an object"]
    registered = set(registered_backgrounds())
    if set(profiles) != registered:
        errors.append("background profile coverage differs from ImageRegistry")
    audio_profiles = load_json(AUDIO_MANIFEST_PATH).get("background_profiles", {})
    if set(profiles) != set(audio_profiles):
        errors.append("visual/audio background profile coverage differs")
    for background_id, profile in profiles.items():
        if not isinstance(profile, dict):
            errors.append(f"{background_id}: profile is not an object")
            continue
        environment = str(profile.get("environment", ""))
        effect = str(profile.get("effect", ""))
        camera = str(profile.get("camera", ""))
        if environment not in ENVIRONMENTS:
            errors.append(f"{background_id}: unknown environment {environment}")
        if effect not in EFFECTS:
            errors.append(f"{background_id}: unknown effect {effect}")
        if camera not in CAMERAS:
            errors.append(f"{background_id}: unknown camera {camera}")
        if effect in {"rain", "snow"}:
            if environment != "outdoor":
                errors.append(f"{background_id}: indoor/transit weather is forbidden")
            if profile.get("weather_source") != "background":
                errors.append(f"{background_id}: weather lacks a visible source")
        if effect == "fireworks":
            errors.append(f"{background_id}: fireworks must be event-authored")

    intents = manifest.get("event_intents", {})
    if not isinstance(intents, dict) or set(intents) != set(EVENT_INTENTS):
        errors.append("event intent groups are incomplete")
        intents = {}
    owners: dict[str, str] = {}
    for intent in EVENT_INTENTS:
        values = intents.get(intent, [])
        if not isinstance(values, list) or any(not isinstance(v, str) for v in values):
            errors.append(f"event_intents.{intent} must be a string array")
            continue
        for event_id in values:
            if event_id in owners:
                errors.append(f"{event_id}: duplicate event intent")
            owners[event_id] = intent
    if set(owners) != set(events):
        errors.append("event intent coverage is not exactly the shipping event set")

    edges = manifest.get("transition_edges", {})
    story_rules = load_json(STORY_RULES_PATH)
    authored_edges = story_rules.get("transition_contracts", {})
    if not isinstance(authored_edges, dict):
        authored_edges = {}
    expected_edges = set(
        f"{a}->{b}" for a, b in runtime_story_edges(events, authored_edges)
    )
    if not isinstance(edges, dict) or set(edges) != expected_edges:
        errors.append("runtime story transition coverage is incomplete")
        edges = {}
    for edge_id, contract in edges.items():
        if not isinstance(contract, dict):
            errors.append(f"{edge_id}: transition contract is not an object")
            continue
        mode = str(contract.get("mode", ""))
        if mode not in EDGE_MODES:
            errors.append(f"{edge_id}: unknown mode {mode}")
        if contract.get("reduced_motion") != REDUCED_MOTION.get(mode):
            errors.append(f"{edge_id}: reduced-motion contract drifted")
        if mode == "same_location" and (
            contract.get("from_surface") != contract.get("to_surface")
        ):
            errors.append(f"{edge_id}: same_location changes physical surface")
        if mode in {"same_location", "remote"} and contract.get("audio_policy") != "continue":
            errors.append(f"{edge_id}: continuity edge restarts audio")

    activities = manifest.get("activity_contracts", {})
    if activities != ACTIVITY_CONTRACTS:
        errors.append("activity contracts are incomplete or stale")
    for activity_id, contract in ACTIVITY_CONTRACTS.items():
        if contract.get("mode") != "activity_enter_return":
            errors.append(f"{activity_id}: activity mode drifted")

    endings = manifest.get("ending_contracts", {})
    if endings != ending_contracts():
        errors.append("ending finale contracts are incomplete or stale")

    for event_id in sorted(set(events) & set(events_en)):
        ko, en = events[event_id], events_en[event_id]
        for field in (
            "background",
            "paragraph_backgrounds",
            "cg",
            "result_background",
            "result_cg",
            "direction",
            "living_scene",
        ):
            if field in en and en.get(field) != ko.get(field):
                errors.append(f"{event_id}: English {field} changes scene direction")

    if not errors:
        counts = {
            key: len(manifest["event_intents"].get(key, []))
            for key in EVENT_INTENTS
        }
        print(
            "SCENE_DIRECTION_CATALOG_OK "
            f"events={len(events)} edges={len(edges)} "
            f"backgrounds={len(profiles)} activities={len(activities)} "
            f"endings={len(endings)} intents={json.dumps(counts, sort_keys=True)}"
        )
    return errors


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--write",
        action="store_true",
        help="regenerate the canonical manifest, then validate it",
    )
    args = parser.parse_args()
    try:
        if args.write:
            MANIFEST_PATH.write_text(
                json.dumps(build_manifest(), ensure_ascii=False, indent=2) + "\n",
                encoding="utf-8",
            )
        manifest = load_json(MANIFEST_PATH)
        errors = validate(manifest)
    except (OSError, ValueError, json.JSONDecodeError) as exc:
        print(f"SCENE_DIRECTION_CATALOG_FAIL {exc}", file=sys.stderr)
        return 1
    if errors:
        for error in errors:
            print(f"SCENE_DIRECTION_CATALOG_FAIL {error}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
