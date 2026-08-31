#!/usr/bin/env python3
"""Lock state assumptions for every event exposed by the live director.

This audit deliberately does not claim that dormant catalog events are safe.
It owns the smaller set that can currently enter play through a director root,
the arc scheduler, or an explicit/deferred follow-up.
"""

from __future__ import annotations

import argparse
import hashlib
import json
import re
import sys
from pathlib import Path
from typing import Any, Iterable

from event_director_audit import (
    event_follow_up_targets,
    exposed_event_reachability,
    load_registered_events,
    scheduled_arc_ids,
)


ROOT = Path(__file__).resolve().parents[1]
DIRECTOR_PATH = ROOT / "content" / "meta" / "event_director.json"
CONTRACT_PATH = ROOT / "content" / "meta" / "exposed_event_state_contracts.json"
STORY_RULES_PATH = ROOT / "content" / "meta" / "story_rules.json"
VISUAL_PATH = ROOT / "assets" / "event_visual_contracts.json"
AUDIO_PATH = ROOT / "assets" / "scene_audio_manifest.json"
EVENT_EN_DIR = ROOT / "content" / "events_en"

EXPECTED_ROOT_COUNT = 386
EXPECTED_EXPOSED_COUNT = 536
ALLOWED_DOMAINS = {
    "employment",
    "housing",
    "relationship",
    "father_life",
    "location",
}
DYNAMIC_LOCATIONS = {"current_housing", "current_workplace"}
TEMPORAL_CONDITIONS = {"min_turn", "max_turn"}

EMPLOYMENT_RE = re.compile(
    r"(?:^|[_\\s])(job|career|office|salary|paycheck|workplace|hoesik|kkondae)"
    r"(?:$|[_\\s])|팀장|부장|직장|회사|사무실|월급|출근|해고|인사팀|"
    r"team leader|manager|paycheck|salary|at the office|human resources",
    re.IGNORECASE,
)
HOUSING_RE = re.compile(
    r"gosiwon|goshiwon|current_housing|housing|jeonse|월세|전세|고시원|"
    r"지금 사는 방|현재 집|shared kitchen",
    re.IGNORECASE,
)
FATHER_RE = re.compile(
    r"father|dad|아버지|아빠|father_passed|father_hospital",
    re.IGNORECASE,
)
RELATIONSHIP_RE = re.compile(
    r"daeun|jiyeon|jaehyuk|hyunsu|sangchul|minseo|seongjun|"
    r"다은|지연|재혁|현수|상철|민서|성준|romance|wedding|married|"
    r"연애|결혼|약혼|이별",
    re.IGNORECASE,
)

DEFAULT_FIXED_LOCATION_CONTEXTS = {
    "arc_gosiwon_wall": "chapter_one_canon",
    "arc_intro_02_dad_call": "chapter_one_canon",
    "arc_intro_03_sns": "chapter_one_canon",
    "arc_temptation_01": "chapter_one_canon",
    "hyunsu_result_pass": "hyunsu_residence",
    "hyunsu_pivot": "hyunsu_residence",
    "hyunsu_pass_news": "hyunsu_residence",
}

DEFAULT_REVIEWED_NEUTRAL_CONTEXTS = {
    "amb_wallet_00": {
        "housing": "financial pressure does not assert a specific dwelling type"
    },
    "class_reunion": {
        "relationship": "the marriage reference describes classmates, not Minjun"
    },
    "hidden_gangnam_open_house": {
        "housing": "the apartment is a property being viewed, not Minjun's residence"
    },
}

DEFAULT_REQUIRED_LAYER_CONTRACTS = {
    "amb_hoesik_drink": {
        "scene_location": "current_housing",
        "visual_background": "current_housing",
        "audio_ambience": "current_housing",
    },
    "anxiety_pension_crisis": {
        "scene_location": "current_housing",
        "visual_background": "current_housing",
        "audio_ambience": "current_housing",
    },
    "arc_chapter1_close": {
        "scene_location": "current_housing",
        "visual_background": "current_housing",
        "audio_ambience": "current_housing",
    },
    "arc_daeun_04_morning": {
        "scene_location": "current_housing",
        "visual_background": "current_housing",
        "audio_ambience": "current_housing",
    },
    "arc_daeun_04b_future": {
        "scene_location": "current_housing",
        "visual_background": "current_housing",
        "audio_ambience": "current_housing",
    },
    "arc_daeun_05_together": {
        "scene_location": "current_housing",
        "visual_background": "current_housing",
        "audio_ambience": "current_housing",
    },
    "arc_daeun_our_home": {
        "scene_location": "current_housing",
        "visual_background": "current_housing",
        "audio_ambience": "current_housing",
    },
    "arc_father_ng_call": {
        "scene_location": "current_housing",
        "visual_background": "current_housing",
        "audio_ambience": "current_housing",
    },
    "arc_invest_guidance": {
        "scene_location": "realestate_office",
        "visual_background": "realestate_office",
        "audio_ambience": "office",
    },
    "arc_job_first_rejection": {
        "scene_location": "current_housing",
        "visual_background": "current_housing",
        "audio_ambience": "current_housing",
    },
    "arc_pre_ending_winter": {
        "scene_location": "current_housing",
        "visual_background": "current_housing",
        "audio_ambience": "current_housing",
    },
    "arc_temptation_clean": {
        "scene_location": "current_housing",
        "visual_background": "current_housing",
        "audio_ambience": "current_housing",
    },
    "butterfly_mystery_info_result_scam": {
        "scene_location": "current_housing",
        "visual_background": "current_housing",
        "audio_ambience": "current_housing",
    },
    "cafe_cb_stole_00": {
        "scene_location": "current_housing",
        "visual_background": "current_housing",
        "audio_ambience": "current_housing",
    },
    "callback_guarantee_default": {
        "scene_location": "current_housing",
        "visual_background": "current_housing",
        "audio_ambience": "current_housing",
    },
    "callback_guarantee_refused_news": {
        "scene_location": "current_housing",
        "visual_background": "current_housing",
        "audio_ambience": "current_housing",
    },
    "callback_investment_lesson_echo": {
        "scene_location": "current_housing",
        "visual_background": "current_housing",
        "audio_ambience": "current_housing",
    },
    "callback_jeonse_auction_insured": {
        "scene_location": "current_housing",
        "visual_background": "current_housing",
        "audio_ambience": "current_housing",
    },
    "callback_kkondae_respect": {
        "scene_location": "current_workplace",
        "visual_background": "current_workplace",
        "audio_ambience": "current_workplace",
    },
    "callback_mindset_investor_echo": {
        "scene_location": "current_housing",
        "visual_background": "current_housing",
        "audio_ambience": "current_housing",
    },
    "callback_tax_windfall": {
        "scene_location": "current_housing",
        "visual_background": "current_housing",
        "audio_ambience": "current_housing",
    },
    "final_last_winter": {
        "scene_location": "current_housing",
        "visual_background": "current_housing",
        "audio_ambience": "current_housing",
    },
    "flex_sns_envy": {
        "scene_location": "current_housing",
        "visual_background": "current_housing",
        "audio_ambience": "current_housing",
    },
    "ng_recovery_echo": {
        "scene_location": "current_housing",
        "visual_background": "current_housing",
        "audio_ambience": "current_housing",
    },
    "recovery_first_week": {
        "scene_location": "current_housing",
        "visual_background": "current_housing",
        "audio_ambience": "current_housing",
    },
    "yolo_morning_after": {
        "scene_location": "current_housing",
        "visual_background": "current_housing",
        "audio_ambience": "current_housing",
    },
}


def load_json(path: Path) -> Any:
    return json.loads(path.read_text(encoding="utf-8"))


def id_hash(ids: Iterable[str]) -> str:
    payload = "\n".join(sorted(str(event_id) for event_id in ids)) + "\n"
    return hashlib.sha256(payload.encode("utf-8")).hexdigest()


def flatten_strings(value: Any) -> list[str]:
    if isinstance(value, str):
        return [value]
    if isinstance(value, list):
        return [text for item in value for text in flatten_strings(item)]
    if isinstance(value, dict):
        return [text for item in value.values() for text in flatten_strings(item)]
    return []


def load_en_events() -> dict[str, dict[str, Any]]:
    events: dict[str, dict[str, Any]] = {}
    for path in sorted(EVENT_EN_DIR.glob("*.json")):
        raw = load_json(path)
        rows = raw.get("events", []) if isinstance(raw, dict) else raw
        if not isinstance(rows, list):
            continue
        for row in rows:
            if isinstance(row, dict) and str(row.get("id", "")):
                events[str(row["id"])] = row
    return events


def non_temporal_conditions(event: dict[str, Any]) -> set[str]:
    conditions = event.get("conditions", {})
    if not isinstance(conditions, dict):
        return set()
    return {str(key) for key in conditions if str(key) not in TEMPORAL_CONDITIONS}


def detected_domains(
    event: dict[str, Any],
    event_en: dict[str, Any],
    story_rule: dict[str, Any],
) -> set[str]:
    conditions = event.get("conditions", {})
    conditions = conditions if isinstance(conditions, dict) else {}
    tags = event.get("tags", [])
    tags = tags if isinstance(tags, list) else []
    searchable = " ".join(
        [
            str(event.get("id", "")),
            str(event.get("background", "")),
            str(event.get("portrait", "")),
            " ".join(str(tag) for tag in tags),
            *flatten_strings(event),
            *flatten_strings(event_en),
        ]
    )
    domains: set[str] = set()
    if (
        {"has_job", "no_job", "job_id", "job_category", "min_job_tier", "max_job_tier"}
        & set(conditions)
        or EMPLOYMENT_RE.search(searchable)
    ):
        domains.add("employment")
    if (
        {"housing", "housing_in", "min_housing_months"} & set(conditions)
        or HOUSING_RE.search(searchable)
    ):
        domains.add("housing")
    if FATHER_RE.search(searchable):
        domains.add("father_life")
    if RELATIONSHIP_RE.search(searchable):
        domains.add("relationship")
    presentation = story_rule.get("presentation", {})
    if (
        str(event.get("background", ""))
        or (isinstance(presentation, dict) and str(presentation.get("scene_location", "")))
    ):
        domains.add("location")
    return domains


def graph_parents(
    exposed: set[str], by_id: dict[str, dict[str, Any]]
) -> dict[str, set[str]]:
    parents = {event_id: set() for event_id in exposed}
    for source_id in exposed:
        for target_id in event_follow_up_targets(by_id[source_id]):
            if target_id in exposed:
                parents[target_id].add(source_id)
    return parents


def has_story_guard(rule: dict[str, Any]) -> bool:
    logic = rule.get("logic", {})
    if not isinstance(logic, dict):
        return False
    if logic.get("prerequisites") or logic.get("requires") or logic.get("forbids"):
        return True
    legacy = logic.get("legacy", {})
    return isinstance(legacy, dict) and bool(
        legacy.get("requires_flags") or legacy.get("forbids_flags")
    )


def guard_sources(
    event_id: str,
    event: dict[str, Any],
    scheduler_ids: set[str],
    parents: dict[str, set[str]],
    story_rule: dict[str, Any],
) -> set[str]:
    sources: set[str] = set()
    if event_id in scheduler_ids:
        sources.add("arc_scheduler")
    if non_temporal_conditions(event):
        sources.add("event_conditions")
    if parents.get(event_id):
        sources.add("follow_up_parent")
    if str(event.get("background", "")) in DYNAMIC_LOCATIONS:
        sources.add("dynamic_location")
    if has_story_guard(story_rule):
        sources.add("story_rule")
    return sources


def has_gosiwon_condition(event: dict[str, Any]) -> bool:
    conditions = event.get("conditions", {})
    if not isinstance(conditions, dict):
        return False
    if str(conditions.get("housing", "")) in {"gosiwon", "goshiwon"}:
        return True
    values = conditions.get("housing_in", [])
    return isinstance(values, list) and bool(
        {"gosiwon", "goshiwon"} & {str(value) for value in values}
    )


def build_contract(
    events: list[dict[str, Any]],
    director: dict[str, Any],
    story_rules: dict[str, Any],
    events_en: dict[str, dict[str, Any]],
    existing: dict[str, Any] | None = None,
) -> dict[str, Any]:
    roots, exposed = exposed_event_reachability(events, director)
    by_id = {str(event["id"]): event for event in events}
    scheduler_ids = scheduled_arc_ids(events)
    parents = graph_parents(exposed, by_id)
    rules = story_rules.get("events", {})
    rules = rules if isinstance(rules, dict) else {}
    neutral_contexts = DEFAULT_REVIEWED_NEUTRAL_CONTEXTS
    if isinstance(existing, dict) and isinstance(
        existing.get("reviewed_neutral_contexts"), dict
    ):
        neutral_contexts = existing["reviewed_neutral_contexts"]

    sensitive: dict[str, list[str]] = {}
    neutral: list[str] = []
    for event_id in sorted(exposed):
        event = by_id[event_id]
        rule = rules.get(event_id, {})
        rule = rule if isinstance(rule, dict) else {}
        domains = detected_domains(event, events_en.get(event_id, {}), rule)
        reviewed_domains = neutral_contexts.get(event_id, {})
        if isinstance(reviewed_domains, dict):
            domains -= {str(domain) for domain in reviewed_domains}
        state_domains = domains - {"location"}
        is_sensitive = bool(
            event_id in scheduler_ids
            or non_temporal_conditions(event)
            or parents.get(event_id)
            or str(event.get("background", "")) in DYNAMIC_LOCATIONS
            or state_domains
        )
        if is_sensitive:
            if not domains:
                domains.add("location")
            sensitive[event_id] = sorted(domains)
        else:
            neutral.append(event_id)

    fixed_contexts = DEFAULT_FIXED_LOCATION_CONTEXTS
    if isinstance(existing, dict) and isinstance(
        existing.get("fixed_location_contexts"), dict
    ):
        fixed_contexts = {
            str(key): str(value)
            for key, value in existing["fixed_location_contexts"].items()
        }
    required_layers = DEFAULT_REQUIRED_LAYER_CONTRACTS
    if isinstance(existing, dict) and isinstance(
        existing.get("required_layer_contracts"), dict
    ):
        required_layers = existing["required_layer_contracts"]
    return {
        "schema_version": 1,
        "scope": {
            "root_count": len(roots),
            "exposed_count": len(exposed),
            "root_ids_sha256": id_hash(roots),
            "exposed_ids_sha256": id_hash(exposed),
        },
        "state_sensitive": sensitive,
        "reviewed_neutral": neutral,
        "reviewed_neutral_contexts": neutral_contexts,
        "fixed_location_contexts": fixed_contexts,
        "required_layer_contracts": required_layers,
    }


def validate_contract(
    contract: dict[str, Any],
    events: list[dict[str, Any]],
    director: dict[str, Any],
    story_rules: dict[str, Any],
    visual_data: dict[str, Any],
    audio_data: dict[str, Any],
    events_en: dict[str, dict[str, Any]],
) -> list[str]:
    errors: list[str] = []
    by_id = {str(event["id"]): event for event in events}
    roots, exposed = exposed_event_reachability(events, director)
    scheduler_ids = scheduled_arc_ids(events)
    parents = graph_parents(exposed, by_id)
    rules = story_rules.get("events", {})
    rules = rules if isinstance(rules, dict) else {}

    if int(contract.get("schema_version", 0)) != 1:
        errors.append("schema_version must be 1")
    scope = contract.get("scope", {})
    if not isinstance(scope, dict):
        errors.append("scope must be an object")
        scope = {}
    if len(roots) != EXPECTED_ROOT_COUNT:
        errors.append(f"runtime roots drifted: {len(roots)} != {EXPECTED_ROOT_COUNT}")
    if len(exposed) != EXPECTED_EXPOSED_COUNT:
        errors.append(
            f"runtime exposed closure drifted: {len(exposed)} != {EXPECTED_EXPOSED_COUNT}"
        )
    expected_scope = {
        "root_count": len(roots),
        "exposed_count": len(exposed),
        "root_ids_sha256": id_hash(roots),
        "exposed_ids_sha256": id_hash(exposed),
    }
    for key, value in expected_scope.items():
        if scope.get(key) != value:
            errors.append(f"scope.{key} drifted")

    sensitive_raw = contract.get("state_sensitive", {})
    neutral_raw = contract.get("reviewed_neutral", [])
    if not isinstance(sensitive_raw, dict):
        errors.append("state_sensitive must be an object")
        sensitive_raw = {}
    if not isinstance(neutral_raw, list) or any(
        not isinstance(event_id, str) for event_id in neutral_raw
    ):
        errors.append("reviewed_neutral must be an array of event ids")
        neutral_raw = []
    sensitive_ids = {str(event_id) for event_id in sensitive_raw}
    neutral_ids = {str(event_id) for event_id in neutral_raw}
    neutral_contexts = contract.get("reviewed_neutral_contexts", {})
    if not isinstance(neutral_contexts, dict):
        errors.append("reviewed_neutral_contexts must be an object")
        neutral_contexts = {}
    for event_id, exemptions in neutral_contexts.items():
        if event_id not in neutral_ids:
            errors.append(
                f"{event_id}: neutral context belongs to a non-neutral event"
            )
        if not isinstance(exemptions, dict) or not exemptions:
            errors.append(f"{event_id}: neutral context must explain at least one domain")
            continue
        unknown = {str(domain) for domain in exemptions} - ALLOWED_DOMAINS
        if unknown:
            errors.append(f"{event_id}: neutral context has unknown domains {sorted(unknown)}")
        if any(not str(reason).strip() for reason in exemptions.values()):
            errors.append(f"{event_id}: neutral context reason must not be empty")
    if len(neutral_ids) != len(neutral_raw):
        errors.append("reviewed_neutral contains duplicates")
    overlap = sensitive_ids & neutral_ids
    if overlap:
        errors.append(f"classifications overlap: {sorted(overlap)}")
    missing = exposed - sensitive_ids - neutral_ids
    extra = (sensitive_ids | neutral_ids) - exposed
    if missing:
        errors.append(f"exposed events are unclassified: {sorted(missing)}")
    if extra:
        errors.append(f"contract classifies non-exposed events: {sorted(extra)}")

    visual_rows = visual_data.get("contracts", [])
    visual_rows = visual_rows if isinstance(visual_rows, list) else []
    visual = {
        str(row.get("id", "")): row
        for row in visual_rows
        if isinstance(row, dict) and str(row.get("id", ""))
    }
    audio = audio_data.get("events", {})
    audio = audio if isinstance(audio, dict) else {}
    required_layers = contract.get("required_layer_contracts", {})
    if not isinstance(required_layers, dict):
        errors.append("required_layer_contracts must be an object")
        required_layers = {}
    for event_id, layer_contract in required_layers.items():
        if event_id not in exposed:
            errors.append(f"required layer contract is not exposed: {event_id}")
        if not isinstance(layer_contract, dict):
            errors.append(f"{event_id}: required layer contract must be an object")
            continue
        unknown_keys = set(layer_contract) - {
            "scene_location",
            "visual_background",
            "audio_ambience",
        }
        if unknown_keys:
            errors.append(
                f"{event_id}: required layer contract has unknown keys "
                f"{sorted(unknown_keys)}"
            )
        for key in ("scene_location", "visual_background", "audio_ambience"):
            if not str(layer_contract.get(key, "")):
                errors.append(f"{event_id}: required layer contract needs {key}")

    for event_id in sorted(sensitive_ids & exposed):
        raw_domains = sensitive_raw.get(event_id, [])
        if not isinstance(raw_domains, list) or not raw_domains:
            errors.append(f"{event_id}: state-sensitive domains must be non-empty")
            continue
        domains = {str(domain) for domain in raw_domains}
        unknown = domains - ALLOWED_DOMAINS
        if unknown:
            errors.append(f"{event_id}: unknown domains {sorted(unknown)}")
        if len(domains) != len(raw_domains):
            errors.append(f"{event_id}: duplicate domains")
        event = by_id[event_id]
        rule = rules.get(event_id, {})
        rule = rule if isinstance(rule, dict) else {}
        detected = detected_domains(event, events_en.get(event_id, {}), rule)
        exemptions = neutral_contexts.get(event_id, {})
        if isinstance(exemptions, dict):
            detected -= {str(domain) for domain in exemptions}
        undeclared = detected - domains
        if undeclared:
            errors.append(
                f"{event_id}: source adds undeclared domains {sorted(undeclared)}"
            )
        if not guard_sources(event_id, event, scheduler_ids, parents, rule):
            errors.append(f"{event_id}: state-sensitive event has no executable guard")

    for event_id in sorted(neutral_ids & exposed):
        event = by_id[event_id]
        rule = rules.get(event_id, {})
        rule = rule if isinstance(rule, dict) else {}
        detected = detected_domains(event, events_en.get(event_id, {}), rule)
        exemptions = neutral_contexts.get(event_id, {})
        if isinstance(exemptions, dict):
            detected -= {str(domain) for domain in exemptions}
        state_domains = detected - {"location"}
        if state_domains:
            errors.append(
                f"{event_id}: reviewed-neutral source now assumes {sorted(state_domains)}"
            )
        if (
            event_id in scheduler_ids
            or non_temporal_conditions(event)
            or parents.get(event_id)
            or str(event.get("background", "")) in DYNAMIC_LOCATIONS
        ):
            errors.append(f"{event_id}: reviewed-neutral event gained stateful routing")

    fixed_contexts = contract.get("fixed_location_contexts", {})
    if not isinstance(fixed_contexts, dict):
        errors.append("fixed_location_contexts must be an object")
        fixed_contexts = {}
    for event_id, context in fixed_contexts.items():
        if event_id not in exposed:
            errors.append(f"fixed location context is not exposed: {event_id}")
        if context not in {"chapter_one_canon", "hyunsu_residence"}:
            errors.append(f"{event_id}: unknown fixed location context {context!r}")

    for event_id in sorted(exposed):
        event = by_id[event_id]
        background = str(event.get("background", ""))
        presentation = rules.get(event_id, {}).get("presentation", {})
        presentation = presentation if isinstance(presentation, dict) else {}
        visual_contract = visual.get(event_id)
        audio_contract = audio.get(event_id)
        if background in DYNAMIC_LOCATIONS:
            if presentation and str(
                presentation.get("scene_location", "")
            ) != background:
                errors.append(
                    f"{event_id}: story presentation conflicts with {background}"
                )
            if visual_contract is not None and str(
                visual_contract.get("background", "")
            ) != background:
                errors.append(
                    f"{event_id}: visual contract conflicts with {background}"
                )
        layer_contract = required_layers.get(event_id)
        if isinstance(layer_contract, dict):
            scene_location = str(layer_contract.get("scene_location", ""))
            visual_background = str(layer_contract.get("visual_background", ""))
            audio_ambience = str(layer_contract.get("audio_ambience", ""))
            if background != scene_location:
                errors.append(
                    f"{event_id}: event background {background!r} != required "
                    f"{scene_location!r}"
                )
            if str(presentation.get("scene_location", "")) != scene_location:
                errors.append(
                    f"{event_id}: missing required story location {scene_location!r}"
                )
            if str((visual_contract or {}).get("background", "")) != visual_background:
                errors.append(
                    f"{event_id}: missing required visual background "
                    f"{visual_background!r}"
                )
            if str((audio_contract or {}).get("ambience", "")) != audio_ambience:
                errors.append(
                    f"{event_id}: missing required audio ambience {audio_ambience!r}"
                )
        if background != "goshiwon_room" or has_gosiwon_condition(event):
            continue
        context = str(fixed_contexts.get(event_id, ""))
        if not context:
            errors.append(
                f"{event_id}: exposed fixed goshiwon needs a state guard or authored context"
            )
        elif context == "chapter_one_canon" and event_id not in scheduler_ids:
            errors.append(f"{event_id}: chapter-one fixed room is not scheduler-owned")
        elif context == "hyunsu_residence":
            ko = " ".join(flatten_strings(event))
            en = " ".join(flatten_strings(events_en.get(event_id, {})))
            if "현수가 사는 고시원" not in ko:
                errors.append(f"{event_id}: Korean prose does not establish Hyunsu's room")
            if "Hyunsu's goshiwon" not in en:
                errors.append(f"{event_id}: English prose does not establish Hyunsu's room")

    return errors


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--write-contract",
        action="store_true",
        help="write the current reviewed classification before running the audit",
    )
    args = parser.parse_args()
    try:
        events = load_registered_events()
        director = load_json(DIRECTOR_PATH)
        story_rules = load_json(STORY_RULES_PATH)
        visual_data = load_json(VISUAL_PATH)
        audio_data = load_json(AUDIO_PATH)
        events_en = load_en_events()
        existing = load_json(CONTRACT_PATH) if CONTRACT_PATH.exists() else None
    except (OSError, ValueError, RuntimeError) as exc:
        print(f"EXPOSED_STATE_CONSISTENCY_AUDIT_FAIL {exc}")
        return 1

    if args.write_contract:
        contract = build_contract(
            events, director, story_rules, events_en, existing
        )
        CONTRACT_PATH.write_text(
            json.dumps(contract, ensure_ascii=False, indent=2) + "\n",
            encoding="utf-8",
        )
    else:
        if not isinstance(existing, dict):
            print("EXPOSED_STATE_CONSISTENCY_AUDIT_FAIL missing contract")
            return 1
        contract = existing

    errors = validate_contract(
        contract,
        events,
        director,
        story_rules,
        visual_data,
        audio_data,
        events_en,
    )
    if errors:
        print(f"EXPOSED_STATE_CONSISTENCY_AUDIT_FAIL errors={len(errors)}")
        for message in errors:
            print(f"  ERROR {message}")
        return 1

    sensitive = contract.get("state_sensitive", {})
    neutral = contract.get("reviewed_neutral", [])
    domain_counts = {
        domain: sum(domain in domains for domains in sensitive.values())
        for domain in sorted(ALLOWED_DOMAINS)
    }
    print(
        "EXPOSED_STATE_CONSISTENCY_AUDIT_OK "
        f"roots={contract['scope']['root_count']} "
        f"exposed={contract['scope']['exposed_count']} "
        f"sensitive={len(sensitive)} neutral={len(neutral)} "
        + " ".join(f"{domain}={count}" for domain, count in domain_counts.items())
    )
    return 0


if __name__ == "__main__":
    sys.exit(main())
