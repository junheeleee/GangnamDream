#!/usr/bin/env python3
"""Audit the factual release-content ledger and optional exported pack ZIPs.

This tool deliberately separates three questions that are easy to conflate:
what an all-resources package contains, what runtime eagerly/lazily loads, and
what an official fresh-start route can reach.  It never chooses an age rating,
deletes content, or changes an export filter.

    python3 tools/release_content_inventory.py
    python3 tools/release_content_inventory.py --self-test
    python3 tools/release_content_inventory.py --write-report
    python3 tools/release_content_inventory.py --print-baselines
    python3 tools/release_content_inventory.py \
      --pack-zip retail_full=build/qa/release_content_inventory/full.zip \
      --pack-zip v2_playtest=build/qa/release_content_inventory/v2.zip
"""

from __future__ import annotations

import argparse
import ast
import copy
import hashlib
import json
import re
import sys
import zipfile
from pathlib import Path, PurePosixPath
from typing import Any


ROOT = Path(__file__).resolve().parents[1]
LEDGER_PATH = ROOT / "content/meta/release_content_inventory.json"
REPORT_PATH = ROOT / "docs/CONTENT_RATING_INVENTORY.md"
EVENT_ROOT = ROOT / "content/events"
EVENT_EN_ROOT = ROOT / "content/events_en"
DEMO_V2_PATH = ROOT / "content/meta/demo_core_loop_v2.json"
NARRATIVE_SPINE_PATH = ROOT / "content/meta/narrative_spine.json"
PROFILE_IDS = ("retail_full", "legacy_demo", "v2_playtest")
AXIS_IDS = {
    "gambling", "sexuality", "violence", "fear", "language", "crime",
    "alcohol_tobacco_drugs", "generative_ai", "online_features",
}
RUNTIME_LOAD = {"boot_eager", "main_entry_eager", "lazy", "none"}
FRESH_START = {"contracted", "static_possible", "blocked", "unknown", "not_applicable"}
INTENSITIES = {
    "none", "mild", "moderate", "strong", "disclosure_required",
    "external_link_only",
}
AI_RUNTIME_TOKENS = (
    "api.openai.com", "api.anthropic.com", "GenerativeAI", "OpenAIClient",
    "AnthropicClient", "LLMClient",
)
EXPECTED_RUNTIME_ROOTS = ("autoloads", "scenes", "systems", "ui_components")
REQUIRED_NETWORK_TOKENS = (
    "HTTPRequest", "HTTPClient", "WebSocketPeer", "WebSocketMultiplayerPeer",
    "ENetMultiplayerPeer", "MultiplayerAPI", "PacketPeerUDP", "TCPServer",
    "StreamPeerTCP",
)
NETWORK_FALSE_FIELDS = (
    "multiplayer", "chat", "remote_ugc", "telemetry",
    "real_money_transactions", "live_ai",
)


def load_json(path: Path) -> Any:
    with path.open(encoding="utf-8") as handle:
        return json.load(handle)


def sha_lines(values: list[str]) -> str:
    return hashlib.sha256("\n".join(values).encode("utf-8")).hexdigest()


def is_below_gdignore(path: Path) -> bool:
    parent = path.parent
    while parent != ROOT and ROOT in parent.parents:
        if (parent / ".gdignore").is_file():
            return True
        parent = parent.parent
    return False


def event_array(data: Any, path: Path) -> list[dict[str, Any]]:
    if isinstance(data, list):
        return data
    if isinstance(data, dict) and isinstance(data.get("events"), list):
        return data["events"]
    raise ValueError(f"{path.relative_to(ROOT)}: event array shape not recognized")


def load_event_corpus(root: Path) -> tuple[dict[str, dict[str, Any]], dict[str, str], list[Path]]:
    events: dict[str, dict[str, Any]] = {}
    owners: dict[str, str] = {}
    files = sorted(root.glob("*.json"))
    for path in files:
        for event in event_array(load_json(path), path):
            event_id = event.get("id")
            if not isinstance(event_id, str) or not event_id:
                raise ValueError(f"{path.relative_to(ROOT)}: event without id")
            if event_id in events:
                raise ValueError(f"duplicate event id: {event_id}")
            events[event_id] = event
            owners[event_id] = path.relative_to(ROOT).as_posix()
    return events, owners, files


def strings_in(value: Any) -> list[str]:
    out: list[str] = []
    if isinstance(value, str):
        out.append(value)
    elif isinstance(value, dict):
        for item in value.values():
            out.extend(strings_in(item))
    elif isinstance(value, list):
        for item in value:
            out.extend(strings_in(item))
    return out


def parse_string_value(raw: str) -> str:
    raw = raw.strip()
    try:
        parsed = ast.literal_eval(raw)
    except (ValueError, SyntaxError):
        return raw
    return parsed if isinstance(parsed, str) else raw


def parse_export_presets() -> list[dict[str, str]]:
    text = (ROOT / "export_presets.cfg").read_text(encoding="utf-8")
    starts = list(re.finditer(r"(?m)^\[preset\.(\d+)\]\s*$", text))
    presets: list[dict[str, str]] = []
    for index, match in enumerate(starts):
        end = starts[index + 1].start() if index + 1 < len(starts) else len(text)
        block = text[match.end():end]
        options = re.search(r"(?m)^\[preset\.\d+\.options\]\s*$", block)
        if options:
            block = block[:options.start()]
        values: dict[str, str] = {"index": match.group(1)}
        for line in block.splitlines():
            if "=" not in line or line.lstrip().startswith("#"):
                continue
            key, raw = line.split("=", 1)
            values[key.strip()] = parse_string_value(raw)
        presets.append(values)
    return presets


def gd_function_block(path: Path, function_name: str) -> str:
    """Return one top-level GDScript function for runtime-marker audits."""
    text = path.read_text(encoding="utf-8")
    marker = re.search(
        rf"(?m)^(?:static\s+)?func\s+{re.escape(function_name)}\s*\(", text
    )
    if marker is None:
        raise ValueError(f"{path.relative_to(ROOT)}: function missing: {function_name}")
    next_marker = re.search(r"(?m)^(?:static\s+)?func\s+", text[marker.end():])
    end = marker.end() + next_marker.start() if next_marker else len(text)
    return text[marker.start():end]


def candidate_fingerprint(
    axis: dict[str, Any],
    ko_events: dict[str, dict[str, Any]],
    en_events: dict[str, dict[str, Any]],
    owners: dict[str, str],
) -> dict[str, Any] | None:
    scan = axis.get("candidate_scan")
    if not scan:
        return None
    categories = set(scan.get("categories", []))
    tags = set(scan.get("tags", []))
    ko_tokens = [token.casefold() for token in scan.get("tokens_ko", [])]
    en_tokens = [token.casefold() for token in scan.get("tokens_en", [])]
    found: list[str] = []
    for event_id, event in ko_events.items():
        overlay = en_events.get(event_id, {})
        category = str(event.get("category", ""))
        event_tags = {str(tag) for tag in event.get("tags", [])}
        ko_text = "\n".join(strings_in(event)).casefold()
        en_text = "\n".join(strings_in(overlay)).casefold()
        if (
            category in categories
            or bool(event_tags & tags)
            or any(token in ko_text for token in ko_tokens)
            or any(token in en_text for token in en_tokens)
        ):
            found.append(event_id)
    found.sort()
    files = sorted({owners[event_id] for event_id in found})
    content_rows = [
        json.dumps(
            {"id": event_id, "ko": ko_events[event_id], "en": en_events[event_id]},
            ensure_ascii=False,
            sort_keys=True,
            separators=(",", ":"),
        )
        for event_id in found
    ]
    return {
        "event_count": len(found),
        "file_count": len(files),
        "ids_sha256": sha_lines(found),
        "content_sha256": sha_lines(content_rows),
        "event_ids": found,
        "files": files,
    }


def reachable_registered_event_ids(
    roots: set[str],
    events: dict[str, dict[str, Any]],
    errors: list[str],
    owner: str,
    suppressed: set[str] | None = None,
    follow_up_replacements: dict[tuple[str, str], str] | None = None,
) -> set[str]:
    """Traverse immediate authored choice links and fail closed on registry gaps."""
    excluded = suppressed or set()
    reachable: set[str] = set()
    pending = list(roots)
    while pending:
        event_id = str(pending.pop()).strip()
        if not event_id or event_id in excluded or event_id in reachable:
            continue
        event = events.get(event_id)
        if not isinstance(event, dict):
            errors.append(f"{owner}: missing registered event {event_id}")
            continue
        reachable.add(event_id)
        for raw_choice in event.get("choices", []):
            if not isinstance(raw_choice, dict):
                continue
            follow_up = str(raw_choice.get("follow_up_event", "")).strip()
            if follow_up_replacements:
                follow_up = follow_up_replacements.get(
                    (event_id, follow_up), follow_up
                )
            if follow_up and follow_up not in excluded:
                pending.append(follow_up)
    return reachable


def v2_reachable_event_surfaces(
    ledger: dict[str, Any],
    events: dict[str, dict[str, Any]],
    errors: list[str],
) -> tuple[set[str], set[str], set[str]]:
    """Build every authored surface shown before and during the 24-week demo."""
    contract = load_json(DEMO_V2_PATH)
    bundles = contract.get("scene_bundles", {})
    if not isinstance(bundles, dict):
        errors.append("demo_core_loop_v2.scene_bundles must be an object")
        return set(), set(), set()

    suppressions_by_root: dict[str, set[str]] = {}
    reachable: set[str] = set()
    for bundle_id, raw_bundle in bundles.items():
        if not isinstance(raw_bundle, dict):
            errors.append(f"demo bundle {bundle_id} must be an object")
            continue
        raw_roots = raw_bundle.get("existing_roots", [])
        raw_suppressed = raw_bundle.get("suppress_follow_up_events", [])
        if not isinstance(raw_roots, list) or not isinstance(raw_suppressed, list):
            errors.append(f"demo bundle {bundle_id}: roots/suppressions must be arrays")
            continue
        roots = {str(value).strip() for value in raw_roots if str(value).strip()}
        suppressed = {
            str(value).strip() for value in raw_suppressed if str(value).strip()
        }
        for root in roots:
            suppressions_by_root.setdefault(root, set()).update(suppressed)
        reachable.update(reachable_registered_event_ids(
            roots, events, errors, f"V2 bundle {bundle_id}", suppressed
        ))

    spine = load_json(NARRATIVE_SPINE_PATH)
    scope = contract.get("scope", {})
    min_week = int(scope.get("min_week", 1)) if isinstance(scope, dict) else 1
    max_week = int(scope.get("max_week", 24)) if isinstance(scope, dict) else 24
    demo = spine.get("demo", {}) if isinstance(spine, dict) else {}
    sequences = demo.get("sequences", []) if isinstance(demo, dict) else []
    if not isinstance(sequences, list) or not sequences:
        errors.append("narrative_spine.demo.sequences must be a non-empty array")
        sequences = []
    spine_roots: set[str] = set()
    for index, raw_sequence in enumerate(sequences):
        if not isinstance(raw_sequence, dict):
            errors.append(f"narrative spine demo sequence {index} must be an object")
            continue
        weeks = raw_sequence.get("weeks", [])
        if not isinstance(weeks, list) or len(weeks) != 2 or any(
            not isinstance(value, int) for value in weeks
        ):
            errors.append(f"narrative spine demo sequence {index}: invalid weeks")
            continue
        if max(weeks[0], min_week) > min(weeks[1], max_week):
            continue
        raw_roots = raw_sequence.get("foreground_roots", [])
        if not isinstance(raw_roots, list):
            errors.append(f"narrative spine demo sequence {index}: roots must be an array")
            continue
        spine_roots.update(str(value).strip() for value in raw_roots if str(value).strip())
    runtime_text = gd_function_block(
        ROOT / "systems/DemoCoreLoopV2.gd", "prepare_demo_collision"
    )
    dynamic_matches = re.findall(
        r'(?:dirty_root\s*=\s*"([^"]+)"|roots\.append\(\s*"([^"]+)"\s*\))',
        runtime_text,
    )
    dynamic_roots = {
        value for pair in dynamic_matches for value in pair if value
    }
    expected_dynamic_roots = set(
        ledger["v2_reachability_contract"][
            "runtime_dynamic_roots"
        ]
    )
    if dynamic_roots != expected_dynamic_roots:
        errors.append(
            "V2 runtime dynamic roots differ from ledger: "
            f"runtime={sorted(dynamic_roots)} ledger={sorted(expected_dynamic_roots)}"
        )
    if not dynamic_roots <= spine_roots:
        errors.append(
            "V2 runtime dynamic roots missing from narrative spine: "
            f"{sorted(dynamic_roots - spine_roots)}"
        )
    for root in sorted(dynamic_roots):
        reachable.update(reachable_registered_event_ids(
            {root}, events, errors, "V2 runtime dynamic root",
            suppressions_by_root.get(root, set()),
        ))

    missing_spine_surface = spine_roots - reachable
    if missing_spine_surface:
        errors.append(
            "V2 narrative spine claims roots absent from executable bundle/dynamic surface: "
            f"{sorted(missing_spine_surface)}"
        )

    prologue_block = gd_function_block(
        ROOT / "scenes/MainGame.gd", "_begin_month_story_and_render"
    )
    resume_prologue_markers = re.findall(
        r'var\s+prologue_root\s*:=\s*"([^"]+)"',
        prologue_block,
    )
    retail_cold_open_markers = re.findall(
        r'if\s+not\s+GameState\.flags\.get\('
        r'"story_flashforward_seen",\s*false\s*\)\s*:\s*'
        r'prologue_root\s*=\s*"([^"]+)"',
        prologue_block,
    )
    expected_prologue = str(
        ledger["v2_reachability_contract"][
            "fresh_start_prologue_root"
        ]
    ).strip()
    fresh_prologue_contract = all((
        re.search(r'DEMO_CORE_LOOP_V2\.is_active\(\)', prologue_block),
        re.search(r'DEMO_CORE_LOOP_V2\.begin_fresh_w1_onboarding\(\)', prologue_block),
        re.search(r'_go_story_mode\(\s*\[\s*prologue_root\s*\]\s*\)', prologue_block),
    ))
    if not fresh_prologue_contract \
            or retail_cold_open_markers != [expected_prologue] \
            or resume_prologue_markers != ["story_arrival"]:
        errors.append(
            "V2 fresh-start prologue runtime marker differs from ledger: "
            f"cold_open={retail_cold_open_markers} "
            f"resume={resume_prologue_markers} ledger={expected_prologue!r}"
        )

    opening = bundles.get("opening_interview_math", {})
    if not isinstance(opening, dict):
        errors.append("opening_interview_math bundle must be an object")
        opening = {}
    trigger = opening.get("preplan_trigger", {})
    if not isinstance(trigger, dict):
        errors.append("opening_interview_math.preplan_trigger must be an object")
        trigger = {}
    trigger_event_id = str(trigger.get("event_id", "")).strip()
    if not trigger_event_id:
        errors.append("opening_interview_math pre-plan trigger event is empty")

    replacement_block = gd_function_block(
        ROOT / "systems/DemoCoreLoopV2.gd", "opening_follow_up_event"
    )
    legacy_queue_block = gd_function_block(
        ROOT / "systems/DemoCoreLoopV2.gd",
        "_legacy_preplan_opening_queue_matches",
    )
    source_match = re.search(r'event_id\s*!=\s*"([^"]+)"', replacement_block)
    target_match = re.search(r'follow_up_id\s*!=\s*"([^"]+)"', replacement_block)
    replacement_source = source_match.group(1) if source_match else ""
    replacement_target = target_match.group(1) if target_match else ""
    if (replacement_source, replacement_target) != (
        "story_prologue_meal", "story_pressure"
    ):
        errors.append(
            "V2 fresh-start replacement must target only "
            "story_prologue_meal->story_pressure"
        )
    fresh_w1_replacement = re.search(
        r'if\s+str\(onboarding\.get\(\s*"origin",\s*""\s*\)\)\s*'
        r'==\s*W1_ONBOARDING_ORIGIN.*?'
        r'and\s+str\(onboarding\.get\(\s*"phase",\s*""\s*\)\)\s*'
        r'==\s*"prologue".*?'
        r'and\s+int\(GameState\.turn\)\s*==\s*1\s*:\s*'
        r'(?:#[^\n]*\n\s*)*return\s+""',
        replacement_block,
        re.S,
    )
    if not fresh_w1_replacement:
        errors.append(
            "V2 fresh-start replacement must end the ORDER-101 W1 prologue "
            "without a follow-up event"
        )
    for marker in (
        "_preplan_opening_base_available(state)",
        "_legacy_preplan_opening_queue_matches(reserved_queue)",
        "_preplan_opening_trigger()",
        '"story_job_unlocked"',
        '"opening_interview_application_sent"',
    ):
        if marker not in replacement_block:
            errors.append(
                f"V2 legacy opening replacement lost runtime guard {marker!r}"
            )
    for marker in (
        "resolved_event_roots(OPENING_INTERVIEW_BUNDLE_ID)",
        "reserved_queue.size()",
        "reserved_queue[root_index]",
    ):
        if marker not in legacy_queue_block:
            errors.append(
                f"V2 legacy opening queue check lost runtime guard {marker!r}"
            )
    if not re.search(
        r"return\s+OPENING_APPLICATION_EVENT_ID\s*\\?\s*"
        r"if\s+trigger_event_id\s*==\s*OPENING_APPLICATION_EVENT_ID\s+"
        r"else\s+follow_up_id",
        replacement_block,
        re.S,
    ):
        errors.append("V2 legacy opening replacement lost its trigger return")
    replacements = {
        (replacement_source, replacement_target): "",
    } if replacement_source and replacement_target else {}
    prologue = reachable_registered_event_ids(
        {expected_prologue},
        events,
        errors,
        "V2 fresh-start prologue",
        follow_up_replacements=replacements,
    )
    if (
        "story_prologue_meal" not in prologue
        or "story_pressure" in prologue
        or trigger_event_id in prologue
    ):
        errors.append(
            "V2 fresh-start prologue must end after story_prologue_meal "
            "without story_pressure or the legacy application preview"
        )
    legacy_replacements = {
        (replacement_source, replacement_target): trigger_event_id,
    } if replacement_source and replacement_target and trigger_event_id else {}
    legacy_prologue = reachable_registered_event_ids(
        {expected_prologue},
        events,
        errors,
        "V2 legacy pre-ORDER-101 prologue",
        follow_up_replacements=legacy_replacements,
    )
    if "story_pressure" in legacy_prologue or trigger_event_id not in legacy_prologue:
        errors.append(
            "V2 legacy pre-ORDER-101 prologue must still replace story_pressure "
            f"with {trigger_event_id or '<missing trigger>'}"
        )

    chapter_block = gd_function_block(
        ROOT / "scenes/MainGame.gd", "_opening_chapter_event_id"
    )
    chapter_markers = re.findall(r'return\s+"([^"]+)"', chapter_block)
    expected_chapter = str(
        ledger["v2_reachability_contract"]["fresh_start_chapter_root"]
    ).strip()
    if chapter_markers != [expected_chapter]:
        errors.append(
            "V2 fresh-start chapter runtime marker differs from ledger: "
            f"runtime={chapter_markers} ledger={expected_chapter!r}"
        )
    chapter = reachable_registered_event_ids(
        {expected_chapter}, events, errors, "V2 fresh-start chapter card"
    )
    return reachable, prologue, chapter


def validate_structure(ledger: dict[str, Any]) -> list[str]:
    errors: list[str] = []
    if ledger.get("schema_version") != 1:
        errors.append("schema_version must be 1")
    decisions = ledger.get("decision_boundary", {})
    for key in ("final_age_rating", "content_removal", "export_filter_change"):
        if decisions.get(key) != "user_required":
            errors.append(f"decision_boundary.{key} must remain user_required")

    sources = ledger.get("official_sources", [])
    if not isinstance(sources, list) or not sources:
        errors.append("official_sources must be a non-empty list")
    else:
        source_ids: set[str] = set()
        for index, source in enumerate(sources):
            where = f"official_sources[{index}]"
            if not isinstance(source, dict):
                errors.append(f"{where}: must be an object")
                continue
            source_id = str(source.get("id", "")).strip()
            if not source_id or source_id in source_ids:
                errors.append(f"{where}: id missing/duplicate")
            source_ids.add(source_id)
            if not str(source.get("url", "")).startswith("https://"):
                errors.append(f"{where}: https URL required")
            if not re.fullmatch(r"\d{4}-\d{2}-\d{2}", str(source.get("accessed", ""))):
                errors.append(f"{where}: accessed must be YYYY-MM-DD")
            if not str(source.get("boundary", "")).strip():
                errors.append(f"{where}: boundary missing")

    raster_review = ledger.get("registry_external_raster_review", {})
    if raster_review.get("final_human_verdict") != "user_required":
        errors.append("registry external raster final_human_verdict must remain user_required")
    groups = raster_review.get("groups", [])
    if not isinstance(groups, list) or not groups:
        errors.append("registry_external_raster_review.groups must be non-empty")
    else:
        review_paths: list[str] = []
        group_ids: set[str] = set()
        for group in groups:
            group_id = str(group.get("id", "")).strip() if isinstance(group, dict) else ""
            if not group_id or group_id in group_ids:
                errors.append("registry external raster review group id missing/duplicate")
                continue
            group_ids.add(group_id)
            paths = group.get("paths", [])
            if not isinstance(paths, list) or not paths:
                errors.append(f"registry raster group {group_id}: paths missing")
                continue
            if not str(group.get("review", "")).strip():
                errors.append(f"registry raster group {group_id}: review missing")
            if not isinstance(group.get("packaged"), bool):
                errors.append(f"registry raster group {group_id}: packaged must be boolean")
            review_paths.extend(str(path) for path in paths)
        if len(review_paths) != len(set(review_paths)):
            errors.append("registry external raster review paths must be unique")

    profiles = ledger.get("export_contract", {}).get("profiles", {})
    if set(profiles) != set(PROFILE_IDS):
        errors.append(f"export profiles must be exactly {list(PROFILE_IDS)}")
    export_contract = ledger.get("export_contract", {})
    for key in ("main_entry_eager_paths", "main_entry_hub_paths", "pack_smoke_paths"):
        values = export_contract.get(key, [])
        if not isinstance(values, list) or not values or len(values) != len(set(values)):
            errors.append(f"export_contract.{key} must be a non-empty unique list")
    eager_paths = set(export_contract.get("main_entry_eager_paths", []))
    hub_paths = set(export_contract.get("main_entry_hub_paths", []))
    if not hub_paths <= eager_paths:
        errors.append("export_contract.main_entry_hub_paths must be a subset of eager paths")

    v2_contract = ledger.get("v2_reachability_contract", {})
    dynamic_roots = v2_contract.get("runtime_dynamic_roots", [])
    if (
        not isinstance(dynamic_roots, list)
        or not dynamic_roots
        or dynamic_roots != sorted(set(dynamic_roots))
    ):
        errors.append("v2 runtime_dynamic_roots must be a non-empty sorted unique list")
    if not str(v2_contract.get("fresh_start_prologue_root", "")).strip():
        errors.append("v2 fresh_start_prologue_root must be non-empty")
    if not str(v2_contract.get("fresh_start_chapter_root", "")).strip():
        errors.append("v2 fresh_start_chapter_root must be non-empty")

    legacy_contract = ledger.get("legacy_reachability_contract", {})
    if legacy_contract.get("owner") != "content/meta/event_director.json":
        errors.append("legacy reachability owner must be content/meta/event_director.json")
    for key in ("required_foreground_ids", "registered_but_not_foreground_ids"):
        values = legacy_contract.get(key, [])
        if (
            not isinstance(values, list)
            or not values
            or values != sorted(set(values))
        ):
            errors.append(f"legacy_reachability_contract.{key} must be sorted/unique")
    required_foreground = set(legacy_contract.get("required_foreground_ids", []))
    condition_anchors = legacy_contract.get("required_event_conditions", {})
    if not isinstance(condition_anchors, dict) or set(condition_anchors) != required_foreground:
        errors.append(
            "legacy condition anchors must exactly match required foreground IDs"
        )
    axes = ledger.get("content_axes", [])
    axis_ids = [axis.get("id") for axis in axes]
    if len(axis_ids) != len(set(axis_ids)):
        errors.append("content axis ids must be unique")
    if set(axis_ids) != AXIS_IDS:
        errors.append(f"content axes mismatch: {sorted(set(axis_ids) ^ AXIS_IDS)}")

    network = ledger.get("network_contract", {})
    if tuple(network.get("runtime_roots", [])) != EXPECTED_RUNTIME_ROOTS:
        errors.append(f"network runtime_roots must be exactly {list(EXPECTED_RUNTIME_ROOTS)}")
    if tuple(network.get("forbidden_api_tokens", [])) != REQUIRED_NETWORK_TOKENS:
        errors.append("network forbidden_api_tokens must match the required fail-closed set")
    for field in NETWORK_FALSE_FIELDS:
        if network.get(field) is not False:
            errors.append(f"network_contract.{field} must remain false")
    if network.get("local_data_mods") is not True:
        errors.append("network_contract.local_data_mods must remain true")

    for axis in axes:
        axis_id = axis.get("id", "<missing>")
        facts = axis.get("facts")
        if not isinstance(facts, list) or not facts:
            errors.append(f"{axis_id}: facts must be non-empty")
            continue
        fact_ids: set[str] = set()
        for fact in facts:
            fact_id = fact.get("id", "<missing>")
            where = f"{axis_id}.{fact_id}"
            if fact_id in fact_ids:
                errors.append(f"{where}: duplicate fact id")
            fact_ids.add(fact_id)
            if not fact.get("summary_ko"):
                errors.append(f"{where}: summary_ko missing")
            if not isinstance(fact.get("event_backed"), bool):
                errors.append(f"{where}: event_backed must be boolean")
            if fact.get("intensity") not in INTENSITIES:
                errors.append(f"{where}: intensity missing/invalid")
            if not fact.get("media"):
                errors.append(f"{where}: media missing")
            owners = fact.get("owner_paths")
            if not isinstance(owners, list) or not owners:
                errors.append(f"{where}: owner_paths missing")
            if not isinstance(fact.get("event_ids"), list):
                errors.append(f"{where}: event_ids must be a list")
            elif fact.get("event_backed") is True and not fact["event_ids"]:
                errors.append(f"{where}: event-backed fact requires event_ids")
            elif fact.get("event_backed") is False and fact["event_ids"]:
                errors.append(f"{where}: non-event fact must not claim event_ids")
            if not fact.get("evidence_tokens"):
                errors.append(f"{where}: evidence_tokens missing")
            per_profile = fact.get("per_profile", {})
            if set(per_profile) != set(PROFILE_IDS):
                errors.append(f"{where}: per_profile must cover all three profiles")
                continue
            for profile_id, state in per_profile.items():
                pwhere = f"{where}.{profile_id}"
                if not isinstance(state.get("packaged"), bool):
                    errors.append(f"{pwhere}: packaged must be boolean")
                elif ledger.get("export_contract", {}).get("export_filter") == "all_resources" and not state["packaged"]:
                    errors.append(f"{pwhere}: all_resources fact cannot claim package absence")
                if state.get("runtime_load") not in RUNTIME_LOAD:
                    errors.append(f"{pwhere}: runtime_load missing/invalid")
                if state.get("fresh_start_reachability") not in FRESH_START:
                    errors.append(f"{pwhere}: fresh_start_reachability missing/invalid")
                if not state.get("basis"):
                    errors.append(f"{pwhere}: reachability basis missing")
    return errors


def validate_presets(ledger: dict[str, Any], errors: list[str]) -> list[dict[str, str]]:
    contract = ledger["export_contract"]
    presets = parse_export_presets()
    if len(presets) != contract["preset_count"]:
        errors.append(f"export preset count {len(presets)} != {contract['preset_count']}")
    by_name = {preset.get("name", ""): preset for preset in presets}
    expected_names: set[str] = set()
    for profile_id, profile in contract["profiles"].items():
        expected_names.update(profile["preset_names"])
        expected_features = set(profile["features"])
        for name in profile["preset_names"]:
            preset = by_name.get(name)
            if not preset:
                errors.append(f"{profile_id}: missing preset {name}")
                continue
            actual_features = {item for item in preset.get("custom_features", "").split(",") if item}
            if actual_features != expected_features:
                errors.append(f"{name}: features {sorted(actual_features)} != {sorted(expected_features)}")
    if set(by_name) != expected_names:
        errors.append(f"unexpected/missing preset names: {sorted(set(by_name) ^ expected_names)}")
    for preset in presets:
        name = preset.get("name", f"preset.{preset.get('index')}")
        for key in ("export_filter", "include_filter", "exclude_filter"):
            if preset.get(key) != contract[key]:
                errors.append(f"{name}: {key}={preset.get(key)!r} != {contract[key]!r}")
    return presets


def validate_corpus(
    ledger: dict[str, Any],
    errors: list[str],
) -> tuple[dict[str, dict[str, Any]], dict[str, dict[str, Any]], dict[str, str], dict[str, dict[str, Any]]]:
    ko_events, owners, ko_files = load_event_corpus(EVENT_ROOT)
    en_events, _en_owners, en_files = load_event_corpus(EVENT_EN_ROOT)
    corpus = ledger["corpus_contract"]
    observed = {
        "ko_event_files": len(ko_files),
        "en_event_files": len(en_files),
        "ko_events": len(ko_events),
        "en_events": len(en_events),
        "event_ids_sha256": sha_lines(sorted(ko_events)),
    }
    for key, value in observed.items():
        if corpus.get(key) != value:
            errors.append(f"corpus {key}: observed {value!r} != ledger {corpus.get(key)!r}")
    if set(ko_events) != set(en_events):
        errors.append(f"KO/EN event id mismatch count={len(set(ko_events) ^ set(en_events))}")
    ending_ids_by_locale: dict[str, list[str]] = {}
    endings_by_locale: dict[str, dict[str, dict[str, Any]]] = {}
    for locale, path_key, expected_key in (
        ("ko", "content/endings.json", "ko_endings"),
        ("en", "content/endings_en.json", "en_endings"),
    ):
        value = load_json(ROOT / path_key)
        endings = value if isinstance(value, list) else value.get("endings", [])
        if not isinstance(endings, list):
            errors.append(f"{path_key}: endings must be an array")
            endings = []
        if len(endings) != corpus[expected_key]:
            errors.append(f"{path_key}: {len(endings)} != {corpus[expected_key]}")
        ending_ids = [
            str(ending.get("id", "")).strip()
            for ending in endings if isinstance(ending, dict)
        ]
        if len(ending_ids) != len(endings) or any(not value for value in ending_ids):
            errors.append(f"{path_key}: every ending must have a non-empty id")
        if len(set(ending_ids)) != len(ending_ids):
            errors.append(f"{path_key}: duplicate ending ids")
        ending_ids_by_locale[locale] = ending_ids
        endings_by_locale[locale] = {
            str(ending.get("id")): ending
            for ending in endings
            if isinstance(ending, dict) and ending.get("id")
        }
    if set(ending_ids_by_locale.get("ko", [])) != set(ending_ids_by_locale.get("en", [])):
        errors.append("KO/EN ending id mismatch")
    ending_ids_sha = sha_lines(sorted(ending_ids_by_locale.get("ko", [])))
    if corpus.get("ending_ids_sha256") != ending_ids_sha:
        errors.append(
            f"corpus ending_ids_sha256: observed {ending_ids_sha!r} "
            f"!= ledger {corpus.get('ending_ids_sha256')!r}"
        )
    ending_content_rows = [
        json.dumps(
            {
                "id": ending_id,
                "ko": endings_by_locale.get("ko", {}).get(ending_id, {}),
                "en": endings_by_locale.get("en", {}).get(ending_id, {}),
            },
            ensure_ascii=False,
            sort_keys=True,
            separators=(",", ":"),
        )
        for ending_id in sorted(endings_by_locale.get("ko", {}))
    ]
    ending_content_sha = sha_lines(ending_content_rows)
    if corpus.get("ending_content_sha256") != ending_content_sha:
        errors.append(
            f"corpus ending_content_sha256: observed {ending_content_sha!r} "
            f"!= ledger {corpus.get('ending_content_sha256')!r}"
        )

    registry = (ROOT / ledger["export_contract"]["boot_registered_owner"]).read_text(encoding="utf-8")
    event_paths = set(re.findall(r'"res://(content/events/[^"\n]+\.json)"', registry))
    source_paths = {path.relative_to(ROOT).as_posix() for path in ko_files}
    if event_paths != source_paths:
        errors.append(f"DataRegistry event paths mismatch source files={len(event_paths ^ source_paths)}")

    art_text = (ROOT / "docs/ART_AI_AUDIT.md").read_text(encoding="utf-8")
    art_match = re.search(r"Inventory:\s*\d+ CG / \d+ portraits / \d+ backgrounds / (\d+) total", art_text)
    if not art_match or int(art_match.group(1)) != corpus["active_art_assets"]:
        errors.append("active art inventory total does not match docs/ART_AI_AUDIT.md")
    raster_suffixes = {".png", ".jpg", ".jpeg", ".webp"}
    source_rasters = sorted(
        path.relative_to(ROOT).as_posix()
        for path in (ROOT / "assets").rglob("*")
        if path.is_file() and path.suffix.lower() in raster_suffixes
    )
    packaged_rasters = sorted(
        relative
        for relative in source_rasters
        if not is_below_gdignore(ROOT / relative)
    )
    image_registry = (ROOT / "autoloads/ImageRegistry.gd").read_text(encoding="utf-8")
    active_rasters = set(re.findall(
        r'"res://(assets/(?:backgrounds|characters|cg)/[^"\n]+'
        r'\.(?:png|jpg|jpeg|webp))"',
        image_registry,
        re.IGNORECASE,
    ))
    if len(active_rasters) != corpus["active_art_assets"]:
        errors.append(
            f"active ImageRegistry raster count {len(active_rasters)} "
            f"!= ledger {corpus['active_art_assets']}"
        )
    external_rasters = sorted(set(source_rasters) - active_rasters)
    external_packaged_rasters = sorted(set(packaged_rasters) - active_rasters)
    source_only_rasters = sorted(set(source_rasters) - set(packaged_rasters))
    external_content_rows = [
        f"{relative}:{file_sha256(ROOT / relative)}"
        for relative in external_rasters
    ]
    external_packaged_content_rows = [
        f"{relative}:{file_sha256(ROOT / relative)}"
        for relative in external_packaged_rasters
    ]
    raster_observed = {
        "source_raster_assets": len(source_rasters),
        "packaged_raster_assets": len(packaged_rasters),
        "registry_external_source_raster_assets": len(external_rasters),
        "registry_external_packaged_raster_assets": len(external_packaged_rasters),
        "source_only_gdignored_raster_assets": len(source_only_rasters),
        "registry_external_raster_paths_sha256": sha_lines(external_rasters),
        "registry_external_raster_content_sha256": sha_lines(external_content_rows),
        "registry_external_packaged_paths_sha256": sha_lines(external_packaged_rasters),
        "registry_external_packaged_content_sha256": sha_lines(
            external_packaged_content_rows
        ),
        "source_only_gdignored_paths_sha256": sha_lines(source_only_rasters),
    }
    for key, value in raster_observed.items():
        if corpus.get(key) != value:
            errors.append(
                f"corpus {key}: observed {value!r} != ledger {corpus.get(key)!r}"
            )
    review_groups = ledger["registry_external_raster_review"]["groups"]
    reviewed_rasters = {
        str(path)
        for group in review_groups if isinstance(group, dict)
        for path in group.get("paths", [])
    }
    if reviewed_rasters != set(external_rasters):
        errors.append(
            "registry external raster review coverage mismatch: "
            f"delta={sorted(reviewed_rasters ^ set(external_rasters))[:8]}"
        )
    reviewed_packaged = {
        str(path)
        for group in review_groups
        if isinstance(group, dict) and group.get("packaged") is True
        for path in group.get("paths", [])
    }
    reviewed_source_only = {
        str(path)
        for group in review_groups
        if isinstance(group, dict) and group.get("packaged") is False
        for path in group.get("paths", [])
    }
    if reviewed_packaged != set(external_packaged_rasters):
        errors.append(
            "registry external packaged raster classification mismatch: "
            f"delta={sorted(reviewed_packaged ^ set(external_packaged_rasters))[:8]}"
        )
    if reviewed_source_only != set(source_only_rasters):
        errors.append(
            "source-only .gdignore raster classification mismatch: "
            f"delta={sorted(reviewed_source_only ^ set(source_only_rasters))[:8]}"
        )
    audio = load_json(ROOT / "assets/audio/AUDIO_SOURCE_MANIFEST.json")
    if len(audio.get("assets", [])) != corpus["audio_source_assets"]:
        errors.append("audio source manifest count does not match ledger")

    fingerprints: dict[str, dict[str, Any]] = {}
    for axis in ledger["content_axes"]:
        result = candidate_fingerprint(axis, ko_events, en_events, owners)
        if result is None:
            continue
        fingerprints[axis["id"]] = result
        scan = axis["candidate_scan"]
        comparisons = {
            "expected_event_count": result["event_count"],
            "expected_file_count": result["file_count"],
            "expected_ids_sha256": result["ids_sha256"],
            "expected_content_sha256": result["content_sha256"],
        }
        for key, value in comparisons.items():
            if scan.get(key) != value:
                errors.append(f"{axis['id']}.{key}: observed {value!r} != ledger {scan.get(key)!r}")
        reviewed_noise = scan.get("reviewed_search_noise_ids", [])
        if not isinstance(reviewed_noise, list):
            errors.append(f"{axis['id']}.reviewed_search_noise_ids must be a list")
            continue
        if len(reviewed_noise) != len(set(reviewed_noise)):
            errors.append(f"{axis['id']}: reviewed search-noise IDs must be unique")
        unknown_noise = set(reviewed_noise) - set(result["event_ids"])
        if unknown_noise:
            errors.append(
                f"{axis['id']}: reviewed search-noise IDs are not candidates: "
                f"{sorted(unknown_noise)}"
            )
        fact_event_ids = {
            event_id
            for fact in axis["facts"]
            for event_id in fact["event_ids"]
        }
        overlap = set(reviewed_noise) & fact_event_ids
        if overlap:
            errors.append(
                f"{axis['id']}: search-noise IDs overlap fact evidence: {sorted(overlap)}"
            )
    return ko_events, en_events, owners, fingerprints


def owner_text(path_text: str) -> str:
    path = ROOT / path_text
    if not path.exists():
        return ""
    if path.is_file():
        if path.suffix.lower() in {".png", ".jpg", ".jpeg", ".ogg", ".wav", ".mp3"}:
            return path.name
        return path.read_text(encoding="utf-8", errors="ignore")
    pieces: list[str] = []
    for child in sorted(path.rglob("*")):
        if child.is_file() and child.suffix.lower() in {".gd", ".json", ".md", ".txt"}:
            pieces.append(child.read_text(encoding="utf-8", errors="ignore"))
    return "\n".join(pieces)


def validate_facts(
    ledger: dict[str, Any],
    ko_events: dict[str, dict[str, Any]],
    en_events: dict[str, dict[str, Any]],
    errors: list[str],
) -> None:
    runtime_blob = "\n".join(
        path.read_text(encoding="utf-8", errors="ignore")
        for path in runtime_files(ledger)
    )
    for axis in ledger["content_axes"]:
        for fact in axis["facts"]:
            where = f"{axis['id']}.{fact['id']}"
            evidence_parts: list[str] = []
            for owner in fact["owner_paths"]:
                path = ROOT / owner
                if not path.exists():
                    errors.append(f"{where}: owner missing: {owner}")
                else:
                    evidence_parts.append(owner_text(owner))
            for event_id in fact["event_ids"]:
                if event_id not in ko_events or event_id not in en_events:
                    errors.append(f"{where}: bilingual event missing: {event_id}")
                    continue
                evidence_parts.append(json.dumps(ko_events[event_id], ensure_ascii=False))
                evidence_parts.append(json.dumps(en_events[event_id], ensure_ascii=False))
            evidence = "\n".join(evidence_parts)
            for token in fact["evidence_tokens"]:
                if token not in evidence:
                    errors.append(f"{where}: evidence token not found: {token!r}")
            unreferenced_paths = fact.get("runtime_unreferenced_paths", [])
            if not isinstance(unreferenced_paths, list):
                errors.append(f"{where}: runtime_unreferenced_paths must be a list")
                continue
            for relative in unreferenced_paths:
                relative = str(relative)
                path = ROOT / relative
                if not path.is_file():
                    errors.append(f"{where}: runtime-unreferenced file missing: {relative}")
                    continue
                if relative not in fact["owner_paths"]:
                    errors.append(f"{where}: runtime-unreferenced path lacks fact ownership: {relative}")
                if f"res://{relative}" in runtime_blob or Path(relative).name in runtime_blob:
                    errors.append(f"{where}: claimed unreferenced asset appears in runtime source: {relative}")
            if unreferenced_paths:
                for profile_id, state in fact["per_profile"].items():
                    if state["runtime_load"] != "none" or state["fresh_start_reachability"] != "blocked":
                        errors.append(
                            f"{where}.{profile_id}: runtime-unreferenced assets require none/blocked"
                        )


def validate_legacy_reachability(
    ledger: dict[str, Any],
    ko_events: dict[str, dict[str, Any]],
    errors: list[str],
) -> None:
    contract = ledger["legacy_reachability_contract"]
    director = load_json(ROOT / contract["owner"])
    content_diet = director.get("content_diet", {})
    foreground = set(content_diet.get("foreground_event_ids", []))
    required = set(contract["required_foreground_ids"])
    absent = set(contract["registered_but_not_foreground_ids"])
    if not required <= foreground:
        errors.append(
            f"legacy required foreground IDs missing: {sorted(required - foreground)}"
        )
    unexpected = absent & foreground
    if unexpected:
        errors.append(
            f"legacy registered/package-only IDs unexpectedly foreground: {sorted(unexpected)}"
        )
    for event_id in sorted(required | absent):
        if event_id not in ko_events:
            errors.append(f"legacy reachability contract event missing: {event_id}")
    for event_id, expected_conditions in contract["required_event_conditions"].items():
        event = ko_events.get(event_id, {})
        if event.get("conditions", {}) != expected_conditions:
            errors.append(
                f"legacy anchor {event_id} conditions {event.get('conditions', {})!r} "
                f"!= {expected_conditions!r}"
            )
        weight = event.get("weight", 0)
        if not isinstance(weight, (int, float)) or weight <= 0:
            errors.append(f"legacy anchor {event_id} must keep positive weight")


def validate_v2_reachability(
    ledger: dict[str, Any],
    ko_events: dict[str, dict[str, Any]],
    errors: list[str],
) -> set[str]:
    week_reachable, prologue_reachable, chapter_reachable = v2_reachable_event_surfaces(
        ledger, ko_events, errors
    )
    reachable = week_reachable | prologue_reachable | chapter_reachable
    contract = ledger.get("v2_reachability_contract", {})
    observed = {
        "week_1_24_event_count": len(week_reachable),
        "week_1_24_event_ids_sha256": sha_lines(sorted(week_reachable)),
        "prologue_event_count": len(prologue_reachable),
        "prologue_event_ids_sha256": sha_lines(sorted(prologue_reachable)),
        "chapter_event_count": len(chapter_reachable),
        "chapter_event_ids_sha256": sha_lines(sorted(chapter_reachable)),
        "fresh_start_event_count": len(reachable),
        "fresh_start_event_ids_sha256": sha_lines(sorted(reachable)),
    }
    for key, value in observed.items():
        if contract.get(key) != value:
            errors.append(
                f"v2 reachability {key}: observed {value!r} != ledger {contract.get(key)!r}"
            )

    for axis in ledger["content_axes"]:
        for fact in axis["facts"]:
            if not fact["event_backed"]:
                continue
            event_ids = set(fact["event_ids"])
            intersection = sorted(event_ids & reachable)
            state = fact["per_profile"]["v2_playtest"]["fresh_start_reachability"]
            where = f"{axis['id']}.{fact['id']}.v2_playtest"
            if intersection and state != "contracted":
                errors.append(
                    f"{where}: V2 closure contains {intersection}, so state must be contracted"
                )
            elif not intersection and state != "blocked":
                errors.append(
                    f"{where}: no fact event is in V2 closure, so state must be blocked"
                )
    return reachable


def runtime_files(ledger: dict[str, Any]) -> list[Path]:
    files: list[Path] = []
    for root_text in EXPECTED_RUNTIME_ROOTS:
        files.extend(sorted((ROOT / root_text).rglob("*.gd")))
    return sorted(set(files))


def validate_runtime_and_ai(ledger: dict[str, Any], errors: list[str]) -> None:
    network = ledger["network_contract"]
    sources = {path: path.read_text(encoding="utf-8", errors="ignore") for path in runtime_files(ledger)}
    forbidden: list[str] = []
    for path, text in sources.items():
        for token in REQUIRED_NETWORK_TOKENS:
            if token in text:
                forbidden.append(f"{path.relative_to(ROOT)}:{token}")
        for token in AI_RUNTIME_TOKENS:
            if token in text:
                forbidden.append(f"{path.relative_to(ROOT)}:{token}")
    if forbidden:
        errors.append(f"runtime network/live-AI APIs found: {forbidden[:8]}")
    if network.get("runtime_network_api_count") != 0:
        errors.append("network_contract.runtime_network_api_count must remain 0")
    for action in network["allowed_external_actions"]:
        path = ROOT / action["path"]
        if not path.is_file():
            errors.append(f"external action owner missing: {action['path']}")
            continue
        count = path.read_text(encoding="utf-8").count(action["token"])
        if count != action["expected_count"]:
            errors.append(f"{action['path']}:{action['token']} count {count} != {action['expected_count']}")

    disclosure = ledger["ai_disclosure_contract"]
    steam_text = (ROOT / disclosure["owner"]).read_text(encoding="utf-8")
    for phrase in disclosure["required_ko_phrases"] + disclosure["required_en_phrases"]:
        if phrase not in steam_text:
            errors.append(f"Steam AI disclosure phrase missing: {phrase!r}")
    decision_text = (ROOT / disclosure["decision_owner"]).read_text(encoding="utf-8")
    for phrase in disclosure["required_decision_phrases"]:
        if phrase not in decision_text:
            errors.append(f"canonical AI decision phrase missing: {phrase!r}")
    for evidence in disclosure["evidence"]:
        if not (ROOT / evidence).exists():
            errors.append(f"AI disclosure evidence missing: {evidence}")
    if disclosure.get("audio_production_assistance") is not True:
        errors.append("audio_production_assistance must remain disclosed")
    if disclosure.get("audio_source_waveform_generation") != "recording_or_sample_only":
        errors.append("audio source waveform provenance must remain recording_or_sample_only")
    if disclosure.get("runtime_generation") is not False:
        errors.append("runtime_generation must remain false unless runtime evidence changes")
    if disclosure.get("external_ai_service_during_play") is not False:
        errors.append("external_ai_service_during_play must remain false unless runtime evidence changes")

    main_text = (ROOT / "scenes/MainGame.gd").read_text(encoding="utf-8")
    for relative in ledger["export_contract"]["main_entry_eager_paths"]:
        marker = f'load("res://{relative}").new()'
        if marker not in main_text:
            errors.append(f"MainGame eager-load marker missing: {marker}")


def render_report(
    ledger: dict[str, Any],
    fingerprints: dict[str, dict[str, Any]],
) -> str:
    contract = ledger["export_contract"]
    corpus = ledger["corpus_contract"]
    access_dates = sorted({source["accessed"] for source in ledger["official_sources"]})
    access_label = ", ".join(access_dates)
    lines: list[str] = [
        "# 출시 콘텐츠·심의 사실 인벤토리",
        "",
        "> 이 문서는 `content/meta/release_content_inventory.json`과 현재 소스에서 자동 생성한다.",
        "> 최종 연령 등급·법률 의견·콘텐츠 삭제 결정이 아니며 수동 편집하지 않는다.",
        "",
        f"갱신 기준: {ledger['updated']}",
        "",
        "## 가장 중요한 범위 판정",
        "",
        f"현재 {contract['preset_count']}개 export preset은 모두 `all_resources`다. 따라서 V2의 공식 24주 경로가",
        f"열지 않는 5년 사건·카지노·경마·홀덤·단타도 패키지에는 포함되며, 사건 {corpus['ko_event_files']}파일은",
        f"DataRegistry가 부팅 때 등록하고 도박·위험거래 노드 {len(contract['main_entry_eager_paths'])}개(직접 미니게임 {len(contract['main_entry_eager_paths']) - len(contract['main_entry_hub_paths'])}개 + 허브 {len(contract['main_entry_hub_paths'])}개)는 MainGame 진입 때 생성한다.",
        "`패키지 포함`, `런타임 로드`, `공식 fresh-start 도달`을 같은 값으로 읽지 않는다.",
        "",
        "| 프로필 | feature | 공식 범위 | 콘텐츠 필터 |",
        "|---|---|---:|---|",
    ]
    for profile_id in PROFILE_IDS:
        profile = contract["profiles"][profile_id]
        features = ", ".join(profile["features"]) or "없음"
        weeks = f"{profile['official_weeks'][0]}–{profile['official_weeks'][1]}주"
        lines.append(f"| `{profile_id}` | {features} | {weeks} | `{contract['export_filter']}` |")

    lines.extend([
        "",
        "## 현재 코퍼스",
        "",
        f"- KO/EN 사건: 각각 {corpus['ko_event_files']}파일 · {corpus['ko_events']}건, ID 일치",
        f"- KO/EN 엔딩: 각각 {corpus['ko_endings']}건",
        f"- 활성 스토리 이미지: {corpus['active_art_assets']}장 · source raster: {corpus['source_raster_assets']}장",
        f"- 게임 pack 대상 raster: {corpus['packaged_raster_assets']}장 · ImageRegistry 외부 pack 대상: {corpus['registry_external_packaged_raster_assets']}장",
        f"- `.gdignore` source-only 상점 스크린샷: {corpus['source_only_gdignored_raster_assets']}장 · 출처 원장 오디오: {corpus['audio_source_assets']}개",
        f"- 사건 ID SHA-256: `{corpus['event_ids_sha256']}`",
        f"- KO/EN 엔딩 본문 SHA-256: `{corpus['ending_content_sha256']}`",
        "",
        "후보 fingerprint는 표현의 최종 등급이 아니라 검토 코퍼스가 조용히 바뀌는 것을",
        "막는 자동검색 래칫이다. fact의 사건 ID는 결정적 증거 앵커이지 후보 전부의 1:1",
        "처분표가 아니다. 후보가 바뀌면 사람이 원문·이미지·음향·플레이를 다시 확인한다.",
        "",
        "| 축 | 후보 사건/파일 | ID SHA-256 | KO/EN 본문 SHA-256 | 최고 사실 강도 |",
        "|---|---:|---|---|---|",
    ])
    for axis in ledger["content_axes"]:
        fp = fingerprints.get(axis["id"])
        candidate = "기술 축" if not fp else f"{fp['event_count']} / {fp['file_count']}"
        digest = "—" if not fp else f"`{fp['ids_sha256']}`"
        content_digest = "—" if not fp else f"`{fp['content_sha256']}`"
        intensities = ", ".join(dict.fromkeys(fact["intensity"] for fact in axis["facts"]))
        lines.append(
            f"| {axis['label_ko']} | {candidate} | {digest} | {content_digest} | {intensities} |"
        )

    reviewed_noise_axes = [
        axis for axis in ledger["content_axes"]
        if axis.get("candidate_scan", {}).get("reviewed_search_noise_ids")
    ]
    if reviewed_noise_axes:
        lines.extend([
            "",
            "명시 검토한 검색 오탐(후보 해시에는 남겨 검색 규칙 변화도 드러낸다):",
        ])
        for axis in reviewed_noise_axes:
            noise_ids = axis["candidate_scan"]["reviewed_search_noise_ids"]
            lines.append(
                f"- {axis['label_ko']}: {', '.join(f'`{event_id}`' for event_id in noise_ids)}"
            )

    lines.extend([
        "",
        f"## ImageRegistry 외부 source raster {corpus['registry_external_source_raster_assets']}장",
        "",
        "`all_resources`라 ImageRegistry 외부 구버전·마케팅·UI raster 중",
        f"{corpus['registry_external_packaged_raster_assets']}장도 게임 pack 대상이다. 나머지 {corpus['source_only_gdignored_raster_assets']}장 상점 스크린샷은 `.gdignore` 아래 source-only라 게임 pack에는 없다.",
        f"전체 {corpus['registry_external_source_raster_assets']}장은 원본·접촉표로 에이전트 시각 검토했지만 최종 사람 판정은",
        "여전히 `user_required`다. 실제 pack 검사는 대상 raster의 각 `.import`가 가리키는 `.ctex`까지 확인한다.",
        "",
        f"- 경로 SHA-256: `{corpus['registry_external_raster_paths_sha256']}`",
        f"- 경로+파일 SHA-256: `{corpus['registry_external_raster_content_sha256']}`",
        f"- 실제 pack 대상 외부 raster 경로 SHA-256: `{corpus['registry_external_packaged_paths_sha256']}`",
        f"- 실제 pack 대상 외부 raster 경로+파일 SHA-256: `{corpus['registry_external_packaged_content_sha256']}`",
        f"- `.gdignore` source-only 경로 SHA-256: `{corpus['source_only_gdignored_paths_sha256']}`",
    ])
    for group in ledger["registry_external_raster_review"]["groups"]:
        package_label = "게임 pack 포함" if group["packaged"] else "source-only / 게임 pack 제외"
        lines.append(
            f"- `{group['id']}` {len(group['paths'])}장 · {package_label} — {group['review']}"
        )

    lines.extend(["", "## 축별 실제 표현과 세 범위", ""])
    reach_labels = {
        "contracted": "명시 계약", "static_possible": "정적 가능", "blocked": "차단",
        "unknown": "미확인", "not_applicable": "해당 없음",
    }
    load_labels = {
        "boot_eager": "부팅 등록", "main_entry_eager": "메인 진입 생성",
        "lazy": "지연", "none": "로드 없음",
    }
    for axis in ledger["content_axes"]:
        lines.append(f"### {axis['label_ko']}")
        lines.append("")
        for fact in axis["facts"]:
            lines.append(f"- **{fact['id']} · {fact['intensity']}** — {fact['summary_ko']}")
            lines.append(f"  - 소유: {', '.join(f'`{path}`' for path in fact['owner_paths'])}")
            if fact["event_ids"]:
                lines.append(f"  - 사건: {', '.join(f'`{event_id}`' for event_id in fact['event_ids'])}")
            for profile_id in PROFILE_IDS:
                state = fact["per_profile"][profile_id]
                packaged = "포함" if state["packaged"] else "제외"
                lines.append(
                    f"  - `{profile_id}`: 패키지 {packaged} / {load_labels[state['runtime_load']]} / "
                    f"fresh-start {reach_labels[state['fresh_start_reachability']]} — {state['basis']}"
                )
        lines.append("")

    lines.extend([
        "## 생성형 AI·온라인 공시 경계",
        "",
        "- 사전 생성 보조: 일부 2D 아트, 서사, 영문 현지화, 프로그래밍/코드,",
        "  오디오 소스 선별·편집·배열·믹싱.",
        "- 오디오 원음은 현장·사물 녹음 또는 녹음된 실악기 샘플이며 텍스트-투-오디오·",
        "  코드 합성 파형은 없다. 이 출처 사실이 오디오 제작 과정의 AI 보조 공시를 없애지는 않는다.",
        "- 런타임 생성, 플레이 중 외부 AI 서비스: 없음.",
        "- 오프라인 싱글플레이. 서버·멀티플레이·채팅·원격 UGC·텔레메트리·실결제 없음.",
        "- 예외는 데모 CTA의 `OS.shell_open` Steam 위시리스트/스토어 링크 1곳이며,",
        "  `user://mods/`는 로컬 데이터 모드다.",
        "",
        "## 제출 직전 수동 절차",
        "",
        "1. 제출 후보의 full/V2 실제 pack ZIP을 아래 명령으로 검사하고 출력 해시를 보관한다.",
        "2. Steam 파트너 설문과 국내 접수 화면을 다시 캡처해 문항·버전·빌드 해시를 묶는다.",
        "3. 최종 등급·삭제·export 필터 변경은 사용자와 심의 주체가 결정한다.",
        "4. 필수 심의 공시는 상점 마케팅에서 숨은 반전·Moral Tint를 공개할 허가가 아니다.",
        "",
        "```bash",
        "python3 tools/release_content_inventory.py --self-test",
        "python3 tools/release_content_inventory.py \\",
        "  --pack-zip retail_full=build/qa/release_content_inventory/full.zip \\",
        "  --pack-zip v2_playtest=build/qa/release_content_inventory/v2.zip",
        "```",
        "",
        f"## 공식 공개 근거 (확인일 {access_label})",
        "",
    ])
    for source in ledger["official_sources"]:
        lines.append(f"- [{source['id']}]({source['url']}) — {source['boundary']}")
    lines.extend([
        "",
        "Steam 공개 문서는 설문을 General Content, Mature Content, Generative AI의",
        "세 구획으로 나누며, 업로드된 성인 콘텐츠는 접근 불가여도 공개하라고 안내한다.",
        "공개 페이지에는 파트너 전용 전체 문항이 없고 Steam 답변이 한국 등급분류를",
        "자동 대체하지 않는다. 이 문서는 법률 자문이 아니다.",
        "",
    ])
    return "\n".join(lines)


def normalize_member(name: str) -> str:
    name = name.replace("\\", "/")
    if name.startswith("res://"):
        name = name[6:]
    while name.startswith("./"):
        name = name[2:]
    return name


def resource_present(
    archive: zipfile.ZipFile,
    member_by_normalized: dict[str, str],
    expected: str,
) -> bool:
    members = set(member_by_normalized)
    if expected in members:
        return True
    if expected.endswith(".gd"):
        stem = expected[:-3]
        variants = {
            stem + ".gdc", expected + ".remap", stem + ".gdc.remap",
            stem + ".gd.remap",
        }
        return bool(members & variants)
    if Path(expected).suffix.lower() in {".png", ".jpg", ".jpeg", ".webp"}:
        import_sidecar = expected + ".import"
        raw_sidecar = member_by_normalized.get(import_sidecar)
        if raw_sidecar is None:
            return False
        sidecar_text = archive.read(raw_sidecar).decode("utf-8", errors="ignore")
        targets = {
            normalize_member(value)
            for value in re.findall(r'"res://([^"]+\.(?:ctex|stex))"', sidecar_text)
        }
        return bool(targets) and any(target in members for target in targets)
    return False


def file_sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        while chunk := handle.read(1024 * 1024):
            digest.update(chunk)
    return digest.hexdigest()


def validate_pack_zip(ledger: dict[str, Any], spec: str) -> list[str]:
    errors: list[str] = []
    if "=" not in spec:
        return [f"--pack-zip requires profile=path, got {spec!r}"]
    profile_id, path_text = spec.split("=", 1)
    if profile_id not in PROFILE_IDS:
        return [f"unknown pack profile: {profile_id}"]
    path = Path(path_text)
    if not path.is_absolute():
        path = ROOT / path
    if not path.is_file():
        return [f"pack ZIP missing: {path}"]
    if not zipfile.is_zipfile(path):
        return [f"not a ZIP pack: {path}"]
    with zipfile.ZipFile(path) as archive:
        raw_members = [info.filename for info in archive.infolist() if not info.is_dir()]
    members_list = [normalize_member(name) for name in raw_members]
    members = set(members_list)
    if len(members) != len(members_list):
        errors.append(f"{profile_id}: duplicate ZIP member paths")
    unsafe = [name for name in members if name.startswith("/") or ".." in PurePosixPath(name).parts]
    if unsafe:
        errors.append(f"{profile_id}: unsafe ZIP paths: {unsafe[:5]}")
    forbidden = [name for name in members if name.startswith(("tools/", "docs/", "build/"))]
    if forbidden:
        errors.append(f"{profile_id}: excluded roots packaged: {forbidden[:5]}")
    with zipfile.ZipFile(path) as archive:
        member_by_normalized = {
            normalize_member(info.filename): info.filename
            for info in archive.infolist() if not info.is_dir()
        }
        expected_paths = list(ledger["export_contract"]["pack_smoke_paths"])
        expected_paths.extend(
            path.relative_to(ROOT).as_posix()
            for path in sorted(EVENT_ROOT.glob("*.json"))
        )
        expected_paths.extend(
            path.relative_to(ROOT).as_posix()
            for path in sorted(EVENT_EN_ROOT.glob("*.json"))
        )
        expected_paths.extend(
            str(relative)
            for group in ledger["registry_external_raster_review"]["groups"]
            if group["packaged"]
            for relative in group["paths"]
        )
        expected_paths.extend(
            asset.relative_to(ROOT).as_posix()
            for asset in sorted((ROOT / "assets").rglob("*"))
            if asset.is_file()
            and asset.suffix.lower() in {".png", ".jpg", ".jpeg", ".webp"}
            and not is_below_gdignore(asset)
        )
        expected_paths.extend([
            "content/endings.json", "content/endings_en.json", "project.binary"
        ])
        missing = [
            expected for expected in sorted(set(expected_paths))
            if not resource_present(archive, member_by_normalized, expected)
        ]
        if missing:
            errors.append(f"{profile_id}: representative resources missing: {missing}")
        source_only_present = [
            str(relative)
            for group in ledger["registry_external_raster_review"]["groups"]
            if not group["packaged"]
            for relative in group["paths"]
            if resource_present(archive, member_by_normalized, str(relative))
        ]
        if source_only_present:
            errors.append(
                f"{profile_id}: .gdignore source-only rasters unexpectedly packaged: "
                f"{source_only_present}"
            )
        project_member = member_by_normalized.get("project.binary")
        project_binary = archive.read(project_member) if project_member else b""
        known_features = {
            feature
            for profile in ledger["export_contract"]["profiles"].values()
            for feature in profile["features"]
        }
        expected_features = set(
            ledger["export_contract"]["profiles"][profile_id]["features"]
        )
        for feature in sorted(known_features):
            present = feature.encode("utf-8") in project_binary
            if present != (feature in expected_features):
                errors.append(
                    f"{profile_id}: project.binary feature {feature!r} "
                    f"present={present} expected={feature in expected_features}"
                )

        current_json_paths = [
            path.relative_to(ROOT).as_posix()
            for path in sorted(EVENT_ROOT.glob("*.json"))
        ] + [
            path.relative_to(ROOT).as_posix()
            for path in sorted(EVENT_EN_ROOT.glob("*.json"))
        ] + [
            "content/endings.json",
            "content/endings_en.json",
            "content/meta/release_content_inventory.json",
        ]
        stale_json: list[str] = []
        for relative in current_json_paths:
            raw_name = member_by_normalized.get(relative)
            if raw_name is None:
                continue
            if archive.read(raw_name) != (ROOT / relative).read_bytes():
                stale_json.append(relative)
        if stale_json:
            errors.append(
                f"{profile_id}: packaged JSON differs from current source: {stale_json[:8]}"
            )
    if not errors:
        entries_digest = sha_lines(sorted(members))
        print(
            f"PACK_ZIP_OK profile={profile_id} entries={len(members)} "
            f"sha256={file_sha256(path)} entries_sha256={entries_digest} path={path}"
        )
    return errors


def validate_source(ledger: dict[str, Any]) -> tuple[list[str], dict[str, dict[str, Any]]]:
    errors = validate_structure(ledger)
    validate_presets(ledger, errors)
    ko_events, en_events, _owners, fingerprints = validate_corpus(ledger, errors)
    validate_legacy_reachability(ledger, ko_events, errors)
    validate_facts(ledger, ko_events, en_events, errors)
    validate_v2_reachability(ledger, ko_events, errors)
    validate_runtime_and_ai(ledger, errors)
    return errors, fingerprints


def self_test(ledger: dict[str, Any]) -> list[str]:
    failures: list[str] = []
    cases: list[tuple[str, dict[str, Any], str]] = []

    changed = copy.deepcopy(ledger)
    changed["decision_boundary"]["final_age_rating"] = "12_plus"
    cases.append(("rating_autodecision", changed, "final_age_rating"))

    changed = copy.deepcopy(ledger)
    del changed["content_axes"][0]["facts"][0]["intensity"]
    cases.append(("missing_intensity", changed, "intensity"))

    changed = copy.deepcopy(ledger)
    del changed["content_axes"][0]["facts"][0]["per_profile"]["v2_playtest"]
    cases.append(("missing_reachability", changed, "per_profile"))

    changed = copy.deepcopy(ledger)
    changed["content_axes"][0]["facts"][0]["per_profile"]["v2_playtest"]["packaged"] = False
    cases.append(("false_package_absence", changed, "package absence"))

    changed = copy.deepcopy(ledger)
    changed["content_axes"][0]["facts"][0]["owner_paths"] = []
    cases.append(("missing_owner", changed, "owner_paths"))

    changed = copy.deepcopy(ledger)
    changed["network_contract"]["runtime_roots"] = []
    cases.append(("empty_network_scan_scope", changed, "runtime_roots"))

    changed = copy.deepcopy(ledger)
    changed["network_contract"]["telemetry"] = True
    cases.append(("false_offline_claim", changed, "telemetry"))

    changed = copy.deepcopy(ledger)
    changed["content_axes"][0]["facts"][0]["event_ids"] = []
    cases.append(("event_backed_without_event_ids", changed, "requires event_ids"))

    changed = copy.deepcopy(ledger)
    del changed["legacy_reachability_contract"]["required_event_conditions"][
        "racetrack_mentor_meet"
    ]
    cases.append(("missing_legacy_condition_anchor", changed, "condition anchors"))

    for name, candidate, marker in cases:
        messages = validate_structure(candidate)
        if not any(marker in message for message in messages):
            failures.append(f"self-test {name}: mutation was not rejected with {marker!r}: {messages}")

    ko_events, _owners, _files = load_event_corpus(EVENT_ROOT)
    for bad_state in ("blocked", "static_possible"):
        changed = copy.deepcopy(ledger)
        for axis in changed["content_axes"]:
            if axis["id"] != "language":
                continue
            axis["facts"][0]["per_profile"]["v2_playtest"][
                "fresh_start_reachability"
            ] = bad_state
        reachability_errors: list[str] = []
        validate_v2_reachability(changed, ko_events, reachability_errors)
        if not any("state must be contracted" in message for message in reachability_errors):
            failures.append(
                f"self-test v2_reachability_{bad_state}: mutation was not rejected: "
                f"{reachability_errors}"
            )

    changed = copy.deepcopy(ledger)
    changed["v2_reachability_contract"]["runtime_dynamic_roots"] = []
    reachability_errors = []
    validate_v2_reachability(changed, ko_events, reachability_errors)
    if not any("dynamic roots differ from ledger" in message for message in reachability_errors):
        failures.append(
            "self-test v2_runtime_root_contract: mutation was not rejected: "
            f"{reachability_errors}"
        )

    changed = copy.deepcopy(ledger)
    changed["v2_reachability_contract"]["fresh_start_prologue_root"] = "story_arrival"
    reachability_errors = []
    validate_v2_reachability(changed, ko_events, reachability_errors)
    if not any("prologue runtime marker differs" in message for message in reachability_errors):
        failures.append(
            "self-test v2_prologue_contract: mutation was not rejected: "
            f"{reachability_errors}"
        )

    changed = copy.deepcopy(ledger)
    changed["v2_reachability_contract"]["fresh_start_chapter_root"] = "chapter_card_34"
    reachability_errors = []
    validate_v2_reachability(changed, ko_events, reachability_errors)
    if not any("chapter runtime marker differs" in message for message in reachability_errors):
        failures.append(
            "self-test v2_chapter_contract: mutation was not rejected: "
            f"{reachability_errors}"
        )
    return failures


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--write-report", action="store_true", help="regenerate the deterministic Markdown reviewer view")
    parser.add_argument("--self-test", action="store_true", help="prove missing ownership/scope/intensity and auto-decisions are rejected")
    parser.add_argument("--print-baselines", action="store_true", help="print current candidate fingerprints without accepting them")
    parser.add_argument("--pack-zip", action="append", default=[], metavar="PROFILE=PATH", help="inspect an actual Godot export-pack ZIP")
    args = parser.parse_args()

    try:
        ledger = load_json(LEDGER_PATH)
        if args.self_test:
            failures = self_test(ledger)
            if failures:
                print("RELEASE_CONTENT_INVENTORY_SELF_TEST_FAIL")
                for failure in failures:
                    print(f"  ERROR: {failure}")
                return 1
            print("RELEASE_CONTENT_INVENTORY_SELF_TEST_OK cases=13")
            return 0

        errors, fingerprints = validate_source(ledger)
        if args.print_baselines:
            print(json.dumps({key: {k: v for k, v in value.items() if k not in {"event_ids", "files"}} for key, value in fingerprints.items()}, ensure_ascii=False, indent=2))
            return 1 if any("expected_" not in error for error in errors) else 0

        report = render_report(ledger, fingerprints)
        if args.write_report:
            REPORT_PATH.write_text(report, encoding="utf-8")
        elif not REPORT_PATH.is_file():
            errors.append(f"generated report missing: {REPORT_PATH.relative_to(ROOT)}; run --write-report")
        elif REPORT_PATH.read_text(encoding="utf-8") != report:
            errors.append(f"generated report stale: {REPORT_PATH.relative_to(ROOT)}; run --write-report")

        pack_sets: list[tuple[str, set[str]]] = []
        seen_pack_profiles: set[str] = set()
        seen_pack_paths: set[Path] = set()
        seen_pack_hashes: dict[str, str] = {}
        for spec in args.pack_zip:
            errors.extend(validate_pack_zip(ledger, spec))
            if "=" not in spec:
                continue
            profile_id, path_text = spec.split("=", 1)
            if profile_id in seen_pack_profiles:
                errors.append(f"duplicate --pack-zip profile: {profile_id}")
            seen_pack_profiles.add(profile_id)
            path = Path(path_text)
            if not path.is_absolute():
                path = ROOT / path
            if profile_id in PROFILE_IDS and path.is_file() and zipfile.is_zipfile(path):
                resolved = path.resolve()
                if resolved in seen_pack_paths:
                    errors.append(f"duplicate --pack-zip resolved path: {resolved}")
                seen_pack_paths.add(resolved)
                digest = file_sha256(path)
                previous_profile = seen_pack_hashes.get(digest)
                if previous_profile is not None and previous_profile != profile_id:
                    errors.append(
                        f"pack ZIP bytes reused across profiles: {previous_profile} and {profile_id}"
                    )
                seen_pack_hashes[digest] = profile_id
                with zipfile.ZipFile(path) as archive:
                    pack_sets.append((profile_id, {
                        normalize_member(info.filename)
                        for info in archive.infolist() if not info.is_dir()
                    }))
        if len(pack_sets) > 1 and ledger["export_contract"]["export_filter"] == "all_resources":
            baseline_profile, baseline = pack_sets[0]
            for profile_id, members in pack_sets[1:]:
                if members != baseline:
                    errors.append(
                        f"all_resources entry-set mismatch: {baseline_profile} vs {profile_id} "
                        f"delta={len(baseline ^ members)}")

        if errors:
            print("RELEASE_CONTENT_INVENTORY_FAIL")
            for error in errors:
                print(f"  ERROR: {error}")
            return 1
        print(
            "RELEASE_CONTENT_INVENTORY_OK "
            f"presets={ledger['export_contract']['preset_count']} "
            f"events_ko_en={ledger['corpus_contract']['ko_events']}/{ledger['corpus_contract']['en_events']} "
            f"axes={len(ledger['content_axes'])} network_apis=0 decisions=user_required"
        )
        return 0
    except (OSError, ValueError, KeyError, json.JSONDecodeError, zipfile.BadZipFile) as exc:
        print(f"RELEASE_CONTENT_INVENTORY_FAIL\n  ERROR: {exc}")
        return 1


if __name__ == "__main__":
    sys.exit(main())
