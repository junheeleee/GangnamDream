#!/usr/bin/env python3
"""Observe M01-M60 story volume without turning length into a quality quota.

The story map is the authoring-schedule owner, not proof of runtime exposure.
This audit joins every base and
coverage-fallback root to the Korean/English event graph, lifecycle boundary,
story rules, and the map's explicit memory/decision/carryover receipts.  It
reports authored volume and playable path depth, but only structural defects
are blocking.  Short bridges and scenes with more than ten surface beats are
both legal.

Known structural debt is an exact allowlist in
``tools/full_game_volume_baseline.json``.  A new defect fails; a repaired debt
also asks for an intentional baseline refresh so the old hole cannot silently
return.
"""

from __future__ import annotations

import argparse
import copy
import hashlib
import json
import re
import statistics
import sys
from collections import defaultdict
from dataclasses import dataclass
from pathlib import Path
from typing import Any, Iterable, Mapping, Sequence


ROOT = Path(__file__).resolve().parents[1]
BASELINE_PATH = ROOT / "tools" / "full_game_volume_baseline.json"
STORY_MAP_PATH = ROOT / "content" / "meta" / "story_map.json"
RULES_PATH = ROOT / "content" / "meta" / "story_rules.json"
LIFECYCLE_PATH = ROOT / "content" / "meta" / "event_lifecycle.json"
DIRECTOR_PATH = ROOT / "content" / "meta" / "event_director.json"
SPINE_PATH = ROOT / "content" / "meta" / "narrative_spine.json"
YEAR5_REFERENCE_PATH = ROOT / "content" / "meta" / "year5_reference_routes.json"
KO_DIR = ROOT / "content" / "events"
EN_DIR = ROOT / "content" / "events_en"

sys.path.insert(0, str(ROOT / "tools"))
from event_lifecycle import audit_author_only  # noqa: E402
from event_schedule import DeferredFollowUpError, deferred_follow_ups  # noqa: E402


SCHEMA_VERSION = 1
MAX_GRAPH_DEPTH = 24
IMMEDIATE_EDGE_KEYS = ("follow_up", "follow_up_event", "next_event")
TOPOLOGY_KEYS = set(IMMEDIATE_EDGE_KEYS) | {
    "deferred_follow_up", "deferred_delay", "follow_up_requires_flags",
}
TEXT_SCALAR_KEYS = {
    "title", "description", "text", "result_text", "foreshadow",
    "bridge_summary", "speaker", "speaker_name",
}
TEXT_CONTAINER_KEYS = {
    "description_if_known", "description_memory_if_known", "text_if_moral",
    "texts", "result_texts", "description_variants",
}
WRITE_KEYS = {
    "flags", "set_flag", "set_flags", "chapter5_receipt",
    "chapter5_receipts", "v2_obligation_id", "receipt_id",
}
READ_CONTAINER_KEYS = {
    "description_if_known", "description_memory_if_known",
    "chapter5_causal_reads", "chapter5_finale_reads", "chapter5_reads",
    "causal_reads", "receipt_reads",
}
GENERIC_TAGS = {
    "story", "arc", "intro", "fork", "consequence", "finale",
    "year_close", "chapter5", "year5", "reference",
}
SEGMENT_KEYS = ("start", "mid", "boss")
SEGMENT_METRICS = (
    "root_refs", "present_roots", "terminal_paths", "choices",
    "dedup_choices", "unique_reachable_events", "dedup_ko_visible_chars",
    "ko_visible_chars", "ko_paragraphs", "receipt_writes",
    "receipt_readers", "decision_readers", "cost_signal_choices",
    "long_range_readers", "max_surface_beat_depth",
)


@dataclass(frozen=True)
class EventRecord:
    event_id: str
    source: str
    data: dict[str, Any]


@dataclass(frozen=True)
class RootRef:
    ref_id: str
    chapter: int
    month: int
    beat_id: str
    root_id: str
    source: str
    kind: str
    work: str
    rule_status: str
    channel: str
    cast: tuple[str, ...]
    reads: dict[str, Any]
    writes: dict[str, Any]
    forgone: tuple[str, ...]


@dataclass(frozen=True)
class PathMetric:
    event_ids: tuple[str, ...]
    choices: int
    visible_chars: int
    paragraphs: int
    surface_beats: int


def load_json(path: Path) -> Any:
    return json.loads(path.read_text(encoding="utf-8"))


def canonical_sha(value: Any) -> str:
    payload = json.dumps(
        value, ensure_ascii=False, sort_keys=True, separators=(",", ":"),
    ).encode("utf-8")
    return hashlib.sha256(payload).hexdigest()


def file_sha(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def visible_chars(value: Any) -> int:
    return len(re.sub(r"\s+", "", str(value or "")))


def paragraph_count(value: Any) -> int:
    text = str(value or "").strip()
    if not text:
        return 0
    return sum(1 for part in re.split(r"\n\s*\n", text) if part.strip())


def _string_leaves(value: Any) -> list[str]:
    if isinstance(value, str):
        return [value]
    if isinstance(value, list):
        result: list[str] = []
        for item in value:
            result.extend(_string_leaves(item))
        return result
    if isinstance(value, dict):
        result = []
        for item in value.values():
            result.extend(_string_leaves(item))
        return result
    return []


def authored_texts(value: Any) -> list[str]:
    """Collect player-facing prose without counting IDs/tags/gameplay values."""
    result: list[str] = []
    if not isinstance(value, dict):
        return result
    for key, item in value.items():
        if key in TEXT_SCALAR_KEYS or key.endswith("_text"):
            if isinstance(item, str):
                result.append(item)
            else:
                result.extend(_string_leaves(item))
            continue
        if key in TEXT_CONTAINER_KEYS:
            result.extend(_string_leaves(item))
            continue
        if isinstance(item, dict):
            result.extend(authored_texts(item))
        elif isinstance(item, list):
            for child in item:
                if isinstance(child, dict):
                    result.extend(authored_texts(child))
    return result


def load_events(directory: Path) -> tuple[dict[str, EventRecord], list[str]]:
    events: dict[str, EventRecord] = {}
    errors: list[str] = []
    for path in sorted(directory.glob("*.json")):
        rel = path.relative_to(ROOT).as_posix()
        try:
            raw = load_json(path)
        except (OSError, ValueError, json.JSONDecodeError) as exc:
            errors.append(f"{rel}: cannot load event JSON: {exc}")
            continue
        rows = raw.get("events", []) if isinstance(raw, dict) else raw
        if not isinstance(rows, list):
            errors.append(f"{rel}: event JSON must be an array or contain events")
            continue
        for index, row in enumerate(rows):
            if not isinstance(row, dict):
                errors.append(f"{rel}[{index}]: event must be an object")
                continue
            event_id = row.get("id")
            if not isinstance(event_id, str) or not event_id.strip():
                errors.append(f"{rel}[{index}]: event id must be non-empty")
                continue
            if event_id in events:
                errors.append(
                    f"duplicate event id {event_id}: {events[event_id].source}, {rel}"
                )
                continue
            events[event_id] = EventRecord(event_id, rel, row)
    return events, errors


def collect_root_refs(story_map: Any) -> tuple[list[RootRef], list[str]]:
    refs: list[RootRef] = []
    errors: list[str] = []
    chapters = story_map.get("chapters", []) if isinstance(story_map, dict) else []
    if not isinstance(chapters, list):
        return refs, ["story_map.chapters must be an array"]
    for chapter in chapters:
        if not isinstance(chapter, dict):
            errors.append("story_map chapter must be an object")
            continue
        chapter_id = chapter.get("chapter")
        months = chapter.get("months", [])
        if not isinstance(chapter_id, int) or isinstance(chapter_id, bool):
            errors.append("story_map chapter number must be an integer")
            continue
        if not isinstance(months, list):
            errors.append(f"chapter {chapter_id} months must be an array")
            continue
        for month_row in months:
            if not isinstance(month_row, dict):
                errors.append(f"chapter {chapter_id} month must be an object")
                continue
            month = month_row.get("month")
            beats = month_row.get("beats", [])
            if not isinstance(month, int) or isinstance(month, bool):
                errors.append(f"chapter {chapter_id} has an invalid month")
                continue
            if not isinstance(beats, list):
                errors.append(f"M{month:02d} beats must be an array")
                continue
            for beat_index, beat in enumerate(beats):
                if not isinstance(beat, dict):
                    errors.append(f"M{month:02d} beat[{beat_index}] must be an object")
                    continue
                beat_id = str(beat.get("id", ""))
                root_id = str(beat.get("root", ""))
                if not beat_id or not root_id:
                    errors.append(f"M{month:02d} beat[{beat_index}] lacks id/root")
                    continue
                common_writes = beat.get("writes", {})
                if not isinstance(common_writes, dict):
                    common_writes = {}
                refs.append(RootRef(
                    ref_id=f"M{month:02d}:{beat_id}:base:{root_id}",
                    chapter=chapter_id,
                    month=month,
                    beat_id=beat_id,
                    root_id=root_id,
                    source="base",
                    kind=str(beat.get("kind", "")),
                    work=str(beat.get("work", "")),
                    rule_status=str(beat.get("rule_status", "")),
                    channel=str(beat.get("channel", "")),
                    cast=tuple(str(v) for v in beat.get("cast", []) if isinstance(v, str)),
                    reads=copy.deepcopy(beat.get("reads", {}))
                    if isinstance(beat.get("reads"), dict) else {},
                    writes=copy.deepcopy(common_writes),
                    forgone=tuple(str(v) for v in beat.get("forgone", []) if isinstance(v, str)),
                ))
                coverage = beat.get("coverage", {})
                fallbacks = coverage.get("fallbacks", []) \
                    if isinstance(coverage, dict) else []
                if not isinstance(fallbacks, list):
                    errors.append(f"M{month:02d} {beat_id} coverage fallbacks must be an array")
                    continue
                for fallback_index, fallback in enumerate(fallbacks):
                    if not isinstance(fallback, dict):
                        errors.append(
                            f"M{month:02d} {beat_id} fallback[{fallback_index}] must be an object"
                        )
                        continue
                    fallback_root = str(fallback.get("root", ""))
                    if not fallback_root:
                        errors.append(
                            f"M{month:02d} {beat_id} fallback[{fallback_index}] lacks root"
                        )
                        continue
                    refs.append(RootRef(
                        ref_id=(
                            f"M{month:02d}:{beat_id}:fallback{fallback_index}:"
                            f"{fallback_root}"
                        ),
                        chapter=chapter_id,
                        month=month,
                        beat_id=beat_id,
                        root_id=fallback_root,
                        source="fallback",
                        kind=str(beat.get("kind", "")),
                        work=str(fallback.get("work", "")),
                        rule_status=str(fallback.get("rule_status", "")),
                        channel=str(fallback.get("channel", "")),
                        cast=tuple(
                            str(v) for v in fallback.get("cast", [])
                            if isinstance(v, str)
                        ),
                        reads=copy.deepcopy(fallback.get("reads", {}))
                        if isinstance(fallback.get("reads"), dict) else {},
                        # Fallbacks share the beat's output contract; the schema
                        # intentionally does not duplicate writes per fallback.
                        writes=copy.deepcopy(common_writes),
                        forgone=tuple(
                            str(v) for v in fallback.get("forgone", [])
                            if isinstance(v, str)
                        ),
                    ))
    return refs, errors


def _owner_immediate_targets(owner: Mapping[str, Any]) -> list[str]:
    targets: list[str] = []
    for key in IMMEDIATE_EDGE_KEYS:
        value = owner.get(key)
        if isinstance(value, str) and value.strip():
            targets.append(value.strip())
    return targets


def _owner_deferred_targets(owner: Mapping[str, Any]) -> tuple[list[str], list[str]]:
    try:
        return [target for target, _delay in deferred_follow_ups(dict(owner))], []
    except DeferredFollowUpError as exc:
        return [], [str(exc)]


def event_targets(event: Mapping[str, Any], include_deferred: bool) -> tuple[list[str], list[str]]:
    targets = _owner_immediate_targets(event)
    errors: list[str] = []
    if include_deferred:
        deferred, deferred_errors = _owner_deferred_targets(event)
        targets.extend(deferred)
        errors.extend(deferred_errors)
    choices = event.get("choices", [])
    if isinstance(choices, list):
        for choice in choices:
            if not isinstance(choice, dict):
                continue
            targets.extend(_owner_immediate_targets(choice))
            if include_deferred:
                deferred, deferred_errors = _owner_deferred_targets(choice)
                targets.extend(deferred)
                errors.extend(deferred_errors)
    return list(dict.fromkeys(targets)), errors


def immediate_successors(event: Mapping[str, Any], choice: Mapping[str, Any]) -> list[str]:
    return list(dict.fromkeys(
        _owner_immediate_targets(event) + _owner_immediate_targets(choice)
    ))


def _owner_topology(owner: Mapping[str, Any]) -> dict[str, Any]:
    immediate = [
        [key, owner[key]]
        for key in IMMEDIATE_EDGE_KEYS
        if isinstance(owner.get(key), str) and owner[key].strip()
    ]
    try:
        deferred = [list(row) for row in deferred_follow_ups(dict(owner))]
        deferred_error = None
    except DeferredFollowUpError as exc:
        deferred = []
        deferred_error = str(exc)
    flags = owner.get("follow_up_requires_flags", [])
    return {
        "immediate": immediate,
        "deferred": deferred,
        "deferred_error": deferred_error,
        "requires_flags": flags if isinstance(flags, list) else flags,
    }


def _effective_topology_owner(
    ko_owner: Mapping[str, Any], en_owner: Mapping[str, Any],
) -> dict[str, Any]:
    merged = dict(ko_owner)
    for key in TOPOLOGY_KEYS:
        if key in en_owner:
            merged[key] = copy.deepcopy(en_owner[key])
    return _owner_topology(merged)


def event_topology(
    ko_event: Mapping[str, Any], en_event: Mapping[str, Any] | None = None,
) -> dict[str, Any]:
    overlay = en_event or {}
    ko_choices = ko_event.get("choices", [])
    en_choices = overlay.get("choices", [])
    if not isinstance(ko_choices, list):
        ko_choices = []
    if not isinstance(en_choices, list):
        en_choices = []
    return {
        "event": _effective_topology_owner(ko_event, overlay),
        "choices": [
            _effective_topology_owner(
                choice if isinstance(choice, dict) else {},
                en_choices[index] if index < len(en_choices)
                and isinstance(en_choices[index], dict) else {},
            )
            for index, choice in enumerate(ko_choices)
        ],
    }


def english_topology_override_locations(event: Mapping[str, Any]) -> list[str]:
    found = [key for key in TOPOLOGY_KEYS if key in event]
    choices = event.get("choices", [])
    if isinstance(choices, list):
        for index, choice in enumerate(choices):
            if not isinstance(choice, dict):
                continue
            found.extend(
                f"choices[{index}].{key}" for key in TOPOLOGY_KEYS if key in choice
            )
    return sorted(found)


def _primary_text_metric(event: Mapping[str, Any], choice: Mapping[str, Any]) -> tuple[int, int, int]:
    description = event.get("description", "")
    result = choice.get("result_text", "")
    chars = visible_chars(description) + visible_chars(choice.get("text", "")) \
        + visible_chars(result)
    paragraphs = paragraph_count(description) + paragraph_count(result)
    # One selector is a playable beat even when its label is one line.
    surface_beats = paragraph_count(description) + 1 + paragraph_count(result)
    return chars, paragraphs, surface_beats


def walk_terminal_paths(
    events: Mapping[str, EventRecord],
    event_id: str,
    stack: tuple[str, ...] = (),
    prefix: PathMetric | None = None,
) -> tuple[list[PathMetric], list[dict[str, Any]]]:
    findings: list[dict[str, Any]] = []
    if event_id in stack:
        findings.append({
            "code": "event_graph_cycle",
            "root": stack[0] if stack else event_id,
            "event": event_id,
            "path": list(stack + (event_id,)),
        })
        return [], findings
    if len(stack) >= MAX_GRAPH_DEPTH:
        findings.append({
            "code": "event_graph_depth_exceeded",
            "root": stack[0] if stack else event_id,
            "event": event_id,
            "depth": len(stack),
        })
        return [], findings
    record = events.get(event_id)
    if record is None:
        findings.append({
            "code": "missing_followup_target",
            "root": stack[0] if stack else event_id,
            "event": event_id,
            "path": list(stack),
        })
        return [], findings
    event = record.data
    choices = event.get("choices", [])
    if not isinstance(choices, list):
        findings.append({
            "code": "invalid_choices",
            "root": stack[0] if stack else event_id,
            "event": event_id,
        })
        return [], findings
    if not choices:
        findings.append({
            "code": "zero_terminal_paths",
            "root": stack[0] if stack else event_id,
            "event": event_id,
            "reason": "mapped graph event has no choice/result terminal",
        })
        return [], findings

    base = prefix or PathMetric((), 0, 0, 0, 0)
    paths: list[PathMetric] = []
    for index, choice in enumerate(choices):
        if not isinstance(choice, dict):
            findings.append({
                "code": "invalid_choice",
                "root": stack[0] if stack else event_id,
                "event": event_id,
                "choice": index,
            })
            continue
        chars, paragraphs, surface_beats = _primary_text_metric(event, choice)
        selected = PathMetric(
            event_ids=base.event_ids + (event_id,),
            choices=base.choices + 1,
            visible_chars=base.visible_chars + chars,
            paragraphs=base.paragraphs + paragraphs,
            surface_beats=base.surface_beats + surface_beats,
        )
        if not isinstance(choice.get("result_text"), str) \
                or not choice.get("result_text", "").strip():
            findings.append({
                "code": "missing_choice_result",
                "root": stack[0] if stack else event_id,
                "event": event_id,
                "choice": index,
            })
        successors = immediate_successors(event, choice)
        if not successors:
            if isinstance(choice.get("result_text"), str) and choice["result_text"].strip():
                paths.append(selected)
            continue
        for successor in successors:
            child_paths, child_findings = walk_terminal_paths(
                events, successor, stack + (event_id,), selected,
            )
            paths.extend(child_paths)
            findings.extend(child_findings)
    return paths, findings


def reachable_events(
    events: Mapping[str, EventRecord], root_id: str,
) -> tuple[set[str], int, list[dict[str, Any]]]:
    reachable: set[str] = set()
    pending = [root_id]
    deferred_edges = 0
    findings: list[dict[str, Any]] = []
    while pending:
        event_id = pending.pop()
        if event_id in reachable:
            continue
        record = events.get(event_id)
        if record is None:
            findings.append({
                "code": "missing_followup_target",
                "root": root_id,
                "event": event_id,
            })
            continue
        reachable.add(event_id)
        immediate, target_errors = event_targets(record.data, include_deferred=False)
        all_targets, deferred_errors = event_targets(record.data, include_deferred=True)
        deferred_edges += max(0, len(set(all_targets)) - len(set(immediate)))
        for message in target_errors + deferred_errors:
            findings.append({
                "code": "invalid_deferred_followup",
                "root": root_id,
                "event": event_id,
                "detail": message,
            })
        for target in all_targets:
            if target not in events:
                findings.append({
                    "code": "missing_followup_target",
                    "root": root_id,
                    "event": target,
                    "source_event": event_id,
                })
                continue
            # Deferred events are validated for existence but are not charged to
            # this month's playable scene volume.  They may be mapped later.
            if target in immediate:
                pending.append(target)
    return reachable, deferred_edges, findings


def _flatten_signal_values(value: Any) -> set[str]:
    result: set[str] = set()
    if isinstance(value, str) and value.strip():
        result.add(value.strip())
    elif isinstance(value, list):
        for item in value:
            result.update(_flatten_signal_values(item))
    elif isinstance(value, dict):
        for key, item in value.items():
            if key in {
                "id", "event_id", "source_event_id", "source_event_ids",
                "optional_source_event_ids", "source_receipt_id", "receipt_id",
                "commitment_id", "flag", "flags", "memory", "decision",
            }:
                result.update(_flatten_signal_values(item))
            elif isinstance(item, (dict, list)):
                result.update(_flatten_signal_values(item))
    return result


def event_receipt_signals(event: Mapping[str, Any]) -> tuple[set[str], set[str]]:
    writes: set[str] = set()
    readers: set[str] = set()

    def walk(owner: Any, parent_key: str = "") -> None:
        if isinstance(owner, list):
            for item in owner:
                walk(item, parent_key)
            return
        if not isinstance(owner, dict):
            return
        for key, value in owner.items():
            if key in WRITE_KEYS:
                writes.update(_flatten_signal_values(value))
            if key in READ_CONTAINER_KEYS or key.endswith("_reads"):
                readers.update(_flatten_signal_values(value))
                if key in {"description_if_known", "description_memory_if_known"} \
                        and isinstance(value, dict):
                    readers.update(str(item) for item in value if str(item).strip())
            if key in {
                "requires_flag", "requires_flags", "flags_all", "flags_any",
                "flags_none", "required_flags", "forbidden_flags",
            }:
                readers.update(_flatten_signal_values(value))
            if key == "conditions" and isinstance(value, dict):
                for condition_key, condition_value in value.items():
                    if "flag" in condition_key or "receipt" in condition_key:
                        readers.update(_flatten_signal_values(condition_value))
            if isinstance(value, (dict, list)):
                walk(value, key)

    walk(event)
    return writes, readers


def map_signals(ref: RootRef) -> tuple[set[str], set[str], set[str], set[str]]:
    writes: set[str] = set()
    readers: set[str] = set()
    decision_writes: set[str] = set()
    decision_readers: set[str] = set()
    for kind in ("memories", "carryovers"):
        raw = ref.writes.get(kind, [])
        if isinstance(raw, list):
            writes.update(str(v) for v in raw if isinstance(v, str) and v)
        raw = ref.reads.get(kind, [])
        if isinstance(raw, list):
            readers.update(str(v) for v in raw if isinstance(v, str) and v)
    decision = ref.writes.get("decision")
    if isinstance(decision, str) and decision:
        writes.add(decision)
        decision_writes.add(decision)
    decision = ref.reads.get("decision")
    if isinstance(decision, str) and decision:
        readers.add(decision)
        decision_readers.add(decision)
    return writes, readers, decision_writes, decision_readers


def _negative_effect_choice(choice: Any) -> bool:
    if not isinstance(choice, dict):
        return False
    effects = choice.get("effects", {})
    if not isinstance(effects, dict):
        return False
    return any(
        isinstance(value, (int, float)) and not isinstance(value, bool) and value < 0
        for value in effects.values()
    )


def _aggregate_text(events: Mapping[str, EventRecord], ids: Iterable[str]) -> tuple[int, int]:
    texts: list[str] = []
    for event_id in sorted(set(ids)):
        record = events.get(event_id)
        if record is not None:
            texts.extend(authored_texts(record.data))
    return sum(visible_chars(v) for v in texts), sum(paragraph_count(v) for v in texts)


def _root_cost_choices(events: Mapping[str, EventRecord], ids: Iterable[str]) -> int:
    total = 0
    for event_id in set(ids):
        record = events.get(event_id)
        if record is None:
            continue
        choices = record.data.get("choices", [])
        if isinstance(choices, list):
            total += sum(_negative_effect_choice(choice) for choice in choices)
    return total


def finding_identity(finding: Mapping[str, Any]) -> str:
    identity = {
        key: finding[key]
        for key in (
            "code", "month", "root", "event", "choice", "ref_id",
            "target_month", "target_root", "target_ref_id",
        )
        if key in finding
    }
    return json.dumps(identity, ensure_ascii=False, sort_keys=True, separators=(",", ":"))


def _dedupe_findings(rows: Iterable[dict[str, Any]]) -> list[dict[str, Any]]:
    found: dict[str, dict[str, Any]] = {}
    for row in rows:
        found.setdefault(finding_identity(row), row)
    return [found[key] for key in sorted(found)]


def _source_hashes(
    refs: Sequence[RootRef], ko: Mapping[str, EventRecord], en: Mapping[str, EventRecord],
    lifecycle_product_ids: Iterable[str],
) -> dict[str, str]:
    root_ids = {ref.root_id for ref in refs}

    def graph_rows(events: Mapping[str, EventRecord]) -> dict[str, Any]:
        seen: set[str] = set()
        pending = [root for root in sorted(root_ids) if root in events]
        while pending:
            event_id = pending.pop()
            if event_id in seen:
                continue
            seen.add(event_id)
            targets, _errors = event_targets(events[event_id].data, include_deferred=False)
            pending.extend(target for target in targets if target in events)
        return {event_id: events[event_id].data for event_id in sorted(seen)}

    return {
        STORY_MAP_PATH.relative_to(ROOT).as_posix(): file_sha(STORY_MAP_PATH),
        RULES_PATH.relative_to(ROOT).as_posix(): file_sha(RULES_PATH),
        LIFECYCLE_PATH.relative_to(ROOT).as_posix(): file_sha(LIFECYCLE_PATH),
        DIRECTOR_PATH.relative_to(ROOT).as_posix(): file_sha(DIRECTOR_PATH),
        SPINE_PATH.relative_to(ROOT).as_posix(): file_sha(SPINE_PATH),
        YEAR5_REFERENCE_PATH.relative_to(ROOT).as_posix(): file_sha(YEAR5_REFERENCE_PATH),
        "graph:ko_mapped_immediate": canonical_sha(graph_rows(ko)),
        "graph:en_mapped_immediate": canonical_sha(graph_rows(en)),
        "lifecycle:product_event_ids": canonical_sha(sorted(lifecycle_product_ids)),
        "story_map:root_refs": canonical_sha([ref.__dict__ for ref in refs]),
    }


def _empty_month(month: int, chapter: int) -> dict[str, Any]:
    return {
        "month": month,
        "chapter": chapter,
        "root_refs": 0,
        "unique_roots": 0,
        "present_roots": 0,
        "missing_roots": 0,
        "terminal_paths": 0,
        "choices": 0,
        "dedup_choices": 0,
        "reachable_events": 0,
        "unique_reachable_events": 0,
        "ko_visible_chars": 0,
        "dedup_ko_visible_chars": 0,
        "en_visible_chars": 0,
        "ko_paragraphs": 0,
        "en_paragraphs": 0,
        "receipt_writes": 0,
        "receipt_readers": 0,
        "decision_writes": 0,
        "decision_readers": 0,
        "cost_signal_choices": 0,
        "long_range_readers": 0,
        "max_surface_beat_depth": 0,
        "min_surface_beat_depth": 0,
        "cast": [],
        "channels": [],
        "roots": [],
    }


def _scope_metrics(
    root_rows: Sequence[Mapping[str, Any]], ko: Mapping[str, EventRecord],
) -> dict[str, Any]:
    result: dict[str, Any] = {
        "root_refs": len(root_rows),
        "unique_roots": len({row["root"] for row in root_rows}),
        "present_roots": sum(bool(row["present"]) for row in root_rows),
        "missing_roots": sum(not bool(row["present"]) for row in root_rows),
    }
    for key in (
        "terminal_paths", "choices", "reachable_events", "ko_visible_chars",
        "en_visible_chars", "ko_paragraphs", "en_paragraphs",
        "receipt_writes", "receipt_readers", "decision_writes",
        "decision_readers", "cost_signal_choices", "long_range_readers",
    ):
        result[key] = sum(int(row[key]) for row in root_rows)
    unique_reachable = {
        event_id
        for row in root_rows
        for event_id in row.get("reachable_event_ids", [])
    }
    result["unique_reachable_events"] = len(unique_reachable)
    result["dedup_choices"] = sum(
        len(ko[event_id].data.get("choices", []))
        for event_id in unique_reachable
        if event_id in ko and isinstance(ko[event_id].data.get("choices", []), list)
    )
    result["dedup_ko_visible_chars"] = _aggregate_text(ko, unique_reachable)[0]
    depths = [
        int(row["max_surface_beat_depth"])
        for row in root_rows if row["present"]
    ]
    minimums = [
        int(row["min_surface_beat_depth"])
        for row in root_rows if row["present"]
    ]
    result["max_surface_beat_depth"] = max(depths, default=0)
    result["min_surface_beat_depth"] = min(minimums, default=0)
    return result


def _sum_metrics(rows: Sequence[Mapping[str, Any]]) -> dict[str, int]:
    result: dict[str, int] = {}
    for key in SEGMENT_METRICS:
        if key == "max_surface_beat_depth":
            result[key] = max((int(row.get(key, 0)) for row in rows), default=0)
        else:
            result[key] = sum(int(row.get(key, 0)) for row in rows)
    return result


def collect_typed_reference_ids(reference: Any) -> set[str]:
    """Return roots whose non-product status has an explicit typed owner."""
    if not isinstance(reference, dict) or reference.get("activation") != "reference_only":
        return set()
    found: set[str] = set()
    protected = reference.get("protected_hashes", {})
    consumers = protected.get("runtime_consumers", {}) \
        if isinstance(protected, dict) else {}
    forbidden = consumers.get("forbidden_root_ids", []) \
        if isinstance(consumers, dict) else []
    if isinstance(forbidden, list):
        found.update(value for value in forbidden if isinstance(value, str) and value)
    for route in reference.get("routes", []) if isinstance(reference.get("routes"), list) else []:
        if not isinstance(route, dict):
            continue
        roots = route.get("roots", [])
        if isinstance(roots, list):
            for row in roots:
                if not isinstance(row, dict):
                    continue
                root_id = row.get("root_id", row.get("id"))
                if isinstance(root_id, str) and root_id:
                    found.add(root_id)
    return found


def collect_reference_inventory(reference: Any, refs: Sequence[RootRef]) -> dict[str, Any]:
    """Keep the dormant 32-root/86-choice corpus out of mapped static totals."""
    root_ids: list[str] = []
    choices = 0
    route_rows: list[dict[str, Any]] = []
    routes = reference.get("routes", []) if isinstance(reference, dict) else []
    if isinstance(routes, list):
        for route in routes:
            if not isinstance(route, dict):
                continue
            route_roots: list[str] = []
            route_choices = 0
            rows = route.get("roots", [])
            if isinstance(rows, list):
                for row in rows:
                    if not isinstance(row, dict):
                        continue
                    root_id = row.get("root_id", row.get("id"))
                    if isinstance(root_id, str) and root_id:
                        route_roots.append(root_id)
                        root_ids.append(root_id)
                    count = row.get("choice_count")
                    if isinstance(count, int) and not isinstance(count, bool):
                        route_choices += count
                    elif isinstance(row.get("choices"), list):
                        route_choices += len(row["choices"])
            choices += route_choices
            route_rows.append({
                "route_id": route.get("route_id"),
                "roots": len(route_roots),
                "choices": route_choices,
            })
    mapped_ids = {ref.root_id for ref in refs}
    unique = set(root_ids)
    return {
        "activation": reference.get("activation") if isinstance(reference, dict) else None,
        "reachability_claim": reference.get("reachability_claim")
        if isinstance(reference, dict) else None,
        "runtime_owner": reference.get("runtime_owner") if isinstance(reference, dict) else None,
        "roots": len(unique),
        "choices": choices,
        "routes": route_rows,
        "mapped_root_overlap": sorted(unique & mapped_ids),
        "included_in_shipping_eligible_static_totals": False,
        "owner": "content/meta/year5_reference_routes.json",
    }


def cross_month_overlap_findings(
    refs: Sequence[RootRef], events: Mapping[str, EventRecord],
) -> list[dict[str, Any]]:
    """Find a scheduled root consumed early by another month's forced closure.

    Same-month chains are legal and are handled by deduplicated month metrics.
    A cross-month edge consumes a future monthly beat too early, or in the
    reverse direction replays an already elapsed beat.  Conditional/branch
    overlaps are named separately so they are not mistaken for unconditional
    product reachability.
    """
    mapped: dict[str, list[RootRef]] = defaultdict(list)
    for ref in refs:
        mapped[ref.root_id].append(ref)
    findings: list[dict[str, Any]] = []
    for source in refs:
        record = events.get(source.root_id)
        if record is None:
            continue
        choices = record.data.get("choices", [])
        if not isinstance(choices, list) or not choices:
            continue
        choice_targets: list[set[str]] = []
        target_choice_indexes: dict[str, list[int]] = defaultdict(list)
        target_required_flags: dict[str, set[str]] = defaultdict(set)
        event_targets = set(_owner_immediate_targets(record.data))
        for index, choice in enumerate(choices):
            if not isinstance(choice, dict):
                choice_targets.append(set(event_targets))
                continue
            targets = set(immediate_successors(record.data, choice))
            choice_targets.append(targets)
            for target in targets:
                target_choice_indexes[target].append(index)
                flags = choice.get("follow_up_requires_flags", [])
                if isinstance(flags, list):
                    target_required_flags[target].update(
                        flag for flag in flags if isinstance(flag, str) and flag
                    )
        for target, indexes in sorted(target_choice_indexes.items()):
            for target_ref in mapped.get(target, []):
                if target_ref.month == source.month:
                    continue
                all_choices = all(target in targets for targets in choice_targets)
                required_flags = sorted(target_required_flags.get(target, set()))
                if target_ref.month < source.month:
                    code = "time_inversion_root_overlap"
                elif all_choices and not required_flags:
                    code = "forced_cross_month_root_overlap"
                elif required_flags:
                    code = "conditional_cross_month_root_overlap"
                else:
                    code = "branch_cross_month_root_overlap"
                findings.append({
                    "code": code,
                    "month": source.month,
                    "root": source.root_id,
                    "ref_id": source.ref_id,
                    "target_month": target_ref.month,
                    "target_root": target_ref.root_id,
                    "target_ref_id": target_ref.ref_id,
                    "choice_indexes": indexes,
                    "all_choices_same_target": all_choices,
                    "required_flags": required_flags,
                })
    return _dedupe_findings(findings)


def _segment_rows(
    months: Mapping[str, Mapping[str, Any]], chapter: int, scope: str,
) -> dict[str, list[Mapping[str, Any]]]:
    start = (chapter - 1) * 12 + 1
    return {
        "start": [months[f"M{month:02d}"][scope] for month in range(start, start + 4)],
        "mid": [months[f"M{month:02d}"][scope] for month in range(start + 4, start + 8)],
        "boss": [months[f"M{month:02d}"][scope] for month in range(start + 8, start + 12)],
    }


def _segment_comparison(
    months: Mapping[str, Mapping[str, Any]], chapter: int, scope: str,
) -> tuple[dict[str, dict[str, int]], dict[str, dict[str, int]]]:
    segments = {
        key: _sum_metrics(rows)
        for key, rows in _segment_rows(months, chapter, scope).items()
    }
    deltas = {
        "boss_minus_start": {
            key: segments["boss"][key] - segments["start"][key]
            for key in SEGMENT_METRICS
        },
        "boss_minus_mid": {
            key: segments["boss"][key] - segments["mid"][key]
            for key in SEGMENT_METRICS
        },
    }
    return segments, deltas


def build_chapter_comparison(
    months: Mapping[str, Mapping[str, Any]], chapter: int,
) -> dict[str, Any]:
    segments, deltas = _segment_comparison(months, chapter, "scheduled_all")
    product_segments, product_deltas = _segment_comparison(
        months, chapter, "shipping_eligible_static",
    )
    return {
        "chapter": chapter,
        "scope_default": "shipping_eligible_static",
        "scheduled_all_segments": segments,
        "scheduled_all_deltas": deltas,
        "shipping_eligible_segments": product_segments,
        "shipping_eligible_deltas": product_deltas,
        # Backward-compatible aliases are explicitly scheduled-all, never the
        # default product view used by the human report.
        "segments": segments,
        "deltas": deltas,
        "interpretation": (
            "Observation only: larger is not automatically better; inspect distant "
            "readers, actual sacrifice, and distinct scene functions together."
        ),
    }


def validate_report_consistency(report: Mapping[str, Any]) -> list[str]:
    errors: list[str] = []
    months = report.get("months", {})
    chapters = report.get("chapters", [])
    if not isinstance(months, dict) or not isinstance(chapters, list):
        return ["report lacks months/chapters"]
    for chapter in range(1, 6):
        expected = build_chapter_comparison(months, chapter)
        actual = next(
            (row for row in chapters if isinstance(row, dict) and row.get("chapter") == chapter),
            None,
        )
        if actual is None:
            errors.append(f"chapter {chapter} comparison is missing")
            continue
        if actual.get("segments") != expected["segments"]:
            errors.append(f"chapter {chapter} escalation segments are corrupted")
        if actual.get("deltas") != expected["deltas"]:
            errors.append(f"chapter {chapter} escalation deltas are corrupted")
        if actual.get("shipping_eligible_segments") != expected["shipping_eligible_segments"]:
            errors.append(
                f"chapter {chapter} shipping-eligible escalation segments are corrupted"
            )
        if actual.get("shipping_eligible_deltas") != expected["shipping_eligible_deltas"]:
            errors.append(
                f"chapter {chapter} shipping-eligible escalation deltas are corrupted"
            )
    return errors


def _gap_rows(appearances: Mapping[str, set[int]], limit: int = 20) -> list[dict[str, Any]]:
    rows: list[dict[str, Any]] = []
    for key, raw_months in appearances.items():
        months = sorted(raw_months)
        if len(months) < 2:
            continue
        candidates = [
            (right - left - 1, left, right)
            for left, right in zip(months, months[1:])
        ]
        gap, left, right = max(candidates)
        rows.append({
            "id": key,
            "from_month": left,
            "to_month": right,
            "empty_months": gap,
            "appearances": len(months),
        })
    return sorted(
        rows, key=lambda row: (-row["empty_months"], row["id"]),
    )[:limit]


def _outliers(root_rows: Sequence[Mapping[str, Any]]) -> list[dict[str, Any]]:
    """Heuristic attention list only; never a pass/fail quota."""
    groups: dict[tuple[int, str], list[Mapping[str, Any]]] = defaultdict(list)
    for row in root_rows:
        if row.get("present"):
            groups[(int(row["chapter"]), str(row["kind"]))].append(row)
    findings: list[dict[str, Any]] = []
    for (chapter, kind), rows in sorted(groups.items()):
        if len(rows) < 4:
            continue
        char_median = statistics.median(int(row["ko_visible_chars"]) for row in rows)
        beat_median = statistics.median(int(row["max_surface_beat_depth"]) for row in rows)
        for row in rows:
            chars = int(row["ko_visible_chars"])
            beats = int(row["max_surface_beat_depth"])
            label = ""
            if char_median and beat_median and chars < char_median * 0.45 \
                    and beats < beat_median * 0.60:
                label = "thin_relative_to_same_chapter_role"
            elif char_median and chars > char_median * 2.50:
                label = "dense_relative_to_same_chapter_role"
            if label:
                findings.append({
                    "code": label,
                    "chapter": chapter,
                    "month": row["month"],
                    "root": row["root"],
                    "kind": kind,
                    "ko_visible_chars": chars,
                    "max_surface_beat_depth": beats,
                    "group_char_median": char_median,
                    "group_beat_median": beat_median,
                    "blocking": False,
                })
    return sorted(findings, key=lambda row: (row["chapter"], row["month"], row["root"]))


def analyze(
    story_map: Any,
    rules: Any,
    ko: Mapping[str, EventRecord],
    en: Mapping[str, EventRecord],
    lifecycle_declared: set[str],
    lifecycle_exempt: set[str],
    lifecycle_product: set[str],
    typed_reference_ids: set[str] | None = None,
    reference_inventory: Mapping[str, Any] | None = None,
    source_hashes: Mapping[str, str] | None = None,
    load_errors: Sequence[str] = (),
) -> dict[str, Any]:
    refs, ref_errors = collect_root_refs(story_map)
    typed_reference_ids = set(typed_reference_ids or set())
    structural: list[dict[str, Any]] = [
        {"code": "source_load_error", "detail": message}
        for message in list(load_errors) + ref_errors
    ]
    rule_events = rules.get("events", {}) if isinstance(rules, dict) else {}
    if not isinstance(rule_events, dict):
        structural.append({"code": "invalid_story_rules_events"})
        rule_events = {}

    # Explicit map memory/decision/carryover topology is the hard write-only
    # contract.  Event flags remain observational because they include legacy
    # compatibility writes outside the canonical map grammar.
    decision_writers: dict[str, list[RootRef]] = defaultdict(list)
    decision_readers: dict[str, list[RootRef]] = defaultdict(list)
    all_writers: dict[str, list[RootRef]] = defaultdict(list)
    all_readers: dict[str, list[RootRef]] = defaultdict(list)
    for ref in refs:
        writes, readers, decision_writes, decision_reads = map_signals(ref)
        for signal in writes:
            all_writers[signal].append(ref)
        for signal in readers:
            all_readers[signal].append(ref)
        for signal in decision_writes:
            decision_writers[signal].append(ref)
        for signal in decision_reads:
            decision_readers[signal].append(ref)
    for signal, writers in sorted(all_writers.items()):
        readers = all_readers.get(signal, [])
        if signal in decision_writers:
            code = "write_only_decision"
            kind = "decision"
        elif signal.startswith("memory."):
            code = "write_only_memory"
            kind = "memory"
        else:
            code = "write_only_carryover"
            kind = "carryover"
        for writer in writers:
            if not any(reader.month > writer.month for reader in readers):
                structural.append({
                    "code": code,
                    "month": writer.month,
                    "root": writer.root_id,
                    "ref_id": writer.ref_id,
                    kind: signal,
                })

    structural.extend(cross_month_overlap_findings(refs, ko))

    receipt_delays: list[dict[str, Any]] = []
    for signal, writers in all_writers.items():
        readers = all_readers.get(signal, [])
        for writer in writers:
            future = [reader for reader in readers if reader.month > writer.month]
            if not future:
                continue
            farthest = max(future, key=lambda row: (row.month, row.ref_id))
            receipt_delays.append({
                "signal": signal,
                "writer_month": writer.month,
                "writer_root": writer.root_id,
                "reader_month": farthest.month,
                "reader_root": farthest.root_id,
                "delay_months": farthest.month - writer.month,
            })
    receipt_delays.sort(key=lambda row: (-row["delay_months"], row["signal"]))

    root_rows: list[dict[str, Any]] = []
    cast_appearances: dict[str, set[int]] = defaultdict(set)
    channel_appearances: dict[str, set[int]] = defaultdict(set)
    tag_appearances: dict[str, set[int]] = defaultdict(set)

    for ref in refs:
        root_finding_prefix = {
            "month": ref.month, "root": ref.root_id, "ref_id": ref.ref_id,
        }
        map_writes, map_readers, decision_writes, decision_reads = map_signals(ref)
        present = ref.root_id in ko
        row: dict[str, Any] = {
            "ref_id": ref.ref_id,
            "chapter": ref.chapter,
            "month": ref.month,
            "beat_id": ref.beat_id,
            "root": ref.root_id,
            "source": ref.source,
            "kind": ref.kind,
            "work": ref.work,
            "rule_status": ref.rule_status,
            "channel": ref.channel,
            "cast": list(ref.cast),
            "forgone": list(ref.forgone),
            "present": present,
            "english_present": ref.root_id in en,
            "lifecycle": (
                "planned_missing" if not present and ref.rule_status == "planned"
                else "missing" if not present
                else "typed_reference_only" if ref.root_id in typed_reference_ids
                else "referenced_author_only" if ref.root_id in lifecycle_exempt
                else "shipping_eligible_static" if ref.root_id in lifecycle_product
                else "packaged_unclassified"
            ),
            "lifecycle_shipping_eligible": ref.root_id in lifecycle_product,
            "runtime_exposure_proven": False,
            "rule_present": ref.root_id in rule_events,
            "rule_logic_present": bool(
                isinstance(rule_events.get(ref.root_id), dict)
                and rule_events[ref.root_id].get("logic")
            ),
            "terminal_paths": 0,
            "choices": 0,
            "reachable_events": 0,
            "reachable_event_ids": [],
            "deferred_edges": 0,
            "ko_visible_chars": 0,
            "en_visible_chars": 0,
            "ko_paragraphs": 0,
            "en_paragraphs": 0,
            "min_surface_beat_depth": 0,
            "max_surface_beat_depth": 0,
            "min_path_chars": 0,
            "max_path_chars": 0,
            "receipt_writes": len(map_writes),
            "receipt_readers": len(map_readers),
            "decision_writes": len(decision_writes),
            "decision_readers": len(decision_reads),
            "receipt_write_ids": sorted(map_writes),
            "receipt_reader_ids": sorted(map_readers),
            "cost_signal_choices": 0,
            "long_range_readers": 0,
            "theme_tags": [],
        }
        for cast_id in ref.cast:
            if cast_id != "player":
                cast_appearances[cast_id].add(ref.month)
        if ref.channel:
            channel_appearances[ref.channel].add(ref.month)

        for signal in map_readers:
            prior = [writer.month for writer in all_writers.get(signal, []) if writer.month < ref.month]
            if prior and ref.month - min(prior) >= 12:
                row["long_range_readers"] += 1

        if not present:
            structural.append({
                "code": "missing_mapped_root",
                **root_finding_prefix,
                "work": ref.work,
                "rule_status": ref.rule_status,
            })
            root_rows.append(row)
            continue

        if ref.root_id in lifecycle_exempt and ref.work == "EXPAND" \
                and ref.rule_status == "needs_rule":
            if ref.root_id in typed_reference_ids:
                structural.append({
                    "code": "typed_reference_only_root",
                    **root_finding_prefix,
                    "work": ref.work,
                    "rule_status": ref.rule_status,
                    "owner_evidence": (
                        "content/meta/year5_reference_routes.json "
                        "activation=reference_only product_consumer_count=0"
                    ),
                })
            else:
                structural.append({
                    "code": "non_product_expand_root",
                    **root_finding_prefix,
                    "work": ref.work,
                    "rule_status": ref.rule_status,
                    "owner_evidence": (
                        "content/meta/event_lifecycle.json author_only_event_ids"
                    ),
                })

        reachable, deferred_edges, reach_findings = reachable_events(ko, ref.root_id)
        paths, path_findings = walk_terminal_paths(ko, ref.root_id)
        for finding in reach_findings + path_findings:
            finding.update({key: value for key, value in root_finding_prefix.items() if key not in finding})
            structural.append(finding)
        if not paths:
            structural.append({
                "code": "zero_terminal_paths",
                **root_finding_prefix,
                "event": ref.root_id,
            })
        row["terminal_paths"] = len(paths)
        row["reachable_events"] = len(reachable)
        row["reachable_event_ids"] = sorted(reachable)
        row["deferred_edges"] = deferred_edges
        row["choices"] = sum(
            len(ko[event_id].data.get("choices", []))
            for event_id in reachable
            if isinstance(ko[event_id].data.get("choices", []), list)
        )
        if paths:
            row["min_surface_beat_depth"] = min(path.surface_beats for path in paths)
            row["max_surface_beat_depth"] = max(path.surface_beats for path in paths)
            row["min_path_chars"] = min(path.visible_chars for path in paths)
            row["max_path_chars"] = max(path.visible_chars for path in paths)

        ko_chars, ko_paragraphs = _aggregate_text(ko, reachable)
        row["ko_visible_chars"] = ko_chars
        row["ko_paragraphs"] = ko_paragraphs
        en_missing = sorted(reachable - set(en))
        for event_id in en_missing:
            structural.append({
                "code": "missing_english_event",
                **root_finding_prefix,
                "event": event_id,
            })
        en_reachable = reachable & set(en)
        en_chars, en_paragraphs = _aggregate_text(en, en_reachable)
        row["en_visible_chars"] = en_chars
        row["en_paragraphs"] = en_paragraphs
        for event_id in sorted(en_reachable):
            ko_event = ko[event_id].data
            en_event = en[event_id].data
            ko_choices = ko_event.get("choices", [])
            en_choices = en_event.get("choices", [])
            if not isinstance(ko_choices, list) or not isinstance(en_choices, list) \
                    or len(ko_choices) != len(en_choices):
                structural.append({
                    "code": "english_choice_mismatch",
                    **root_finding_prefix,
                    "event": event_id,
                    "ko": len(ko_choices) if isinstance(ko_choices, list) else -1,
                    "en": len(en_choices) if isinstance(en_choices, list) else -1,
                })
                continue
            for choice_index, choice in enumerate(en_choices):
                if not isinstance(choice, dict) \
                        or not isinstance(choice.get("result_text"), str) \
                        or not choice.get("result_text", "").strip():
                    structural.append({
                        "code": "missing_english_choice_result",
                        **root_finding_prefix,
                        "event": event_id,
                        "choice": choice_index,
                    })
            overrides = english_topology_override_locations(en_event)
            if overrides:
                structural.append({
                    "code": "english_gameplay_topology_override",
                    **root_finding_prefix,
                    "event": event_id,
                    "locations": overrides,
                })
            if event_topology(ko_event) != event_topology(ko_event, en_event):
                structural.append({
                    "code": "english_topology_mismatch",
                    **root_finding_prefix,
                    "event": event_id,
                    "ko_topology": event_topology(ko_event),
                    "effective_en_topology": event_topology(ko_event, en_event),
                })

        event_writes: set[str] = set()
        event_readers: set[str] = set()
        root_tags: set[str] = set()
        for event_id in reachable:
            writes, readers = event_receipt_signals(ko[event_id].data)
            event_writes.update(writes)
            event_readers.update(readers)
            tags = ko[event_id].data.get("tags", [])
            if isinstance(tags, list):
                for tag in tags:
                    if isinstance(tag, str) and tag not in GENERIC_TAGS \
                            and not re.fullmatch(r"(?:chapter|year)\d+", tag):
                        root_tags.add(tag)
                        tag_appearances[tag].add(ref.month)
        combined_writes = map_writes | event_writes
        combined_readers = map_readers | event_readers
        row["receipt_writes"] = len(combined_writes)
        row["receipt_readers"] = len(combined_readers)
        row["receipt_write_ids"] = sorted(combined_writes)
        row["receipt_reader_ids"] = sorted(combined_readers)
        row["cost_signal_choices"] = _root_cost_choices(ko, reachable)
        row["theme_tags"] = sorted(root_tags)
        root_rows.append(row)

    structural = _dedupe_findings(structural)
    months: dict[str, dict[str, Any]] = {}
    for month in range(1, 61):
        chapter = (month - 1) // 12 + 1
        month_rows = [row for row in root_rows if row["month"] == month]
        aggregate = _empty_month(month, chapter)
        scheduled_all = _scope_metrics(month_rows, ko)
        product = _scope_metrics(
            [
                row for row in month_rows
                if row["lifecycle"] == "shipping_eligible_static"
            ], ko,
        )
        # Flat keys are the shipping-eligible static default.  Scheduled-all
        # authoring debt is always explicit so API consumers cannot inflate the
        # default by reading an unlabelled count.
        aggregate.update(product)
        aggregate["scheduled_all"] = scheduled_all
        aggregate["shipping_eligible_static"] = product
        shipping_rows = [
            row for row in month_rows
            if row["lifecycle"] == "shipping_eligible_static"
        ]
        aggregate["cast"] = sorted({
            cast for row in shipping_rows for cast in row["cast"]
        })
        aggregate["channels"] = sorted({
            row["channel"] for row in shipping_rows if row["channel"]
        })
        aggregate["roots"] = [row["ref_id"] for row in shipping_rows]
        aggregate["scheduled_all_cast"] = sorted({
            cast for row in month_rows for cast in row["cast"]
        })
        aggregate["scheduled_all_channels"] = sorted({
            row["channel"] for row in month_rows if row["channel"]
        })
        aggregate["scheduled_all_roots"] = [row["ref_id"] for row in month_rows]
        months[f"M{month:02d}"] = aggregate

    chapters = [build_chapter_comparison(months, chapter) for chapter in range(1, 6)]
    for chapter in chapters:
        chapter_rows = [
            row for row in root_rows if row["chapter"] == chapter["chapter"]
        ]
        chapter["inventory"] = {
            "root_refs": len(chapter_rows),
            "shipping_eligible_static": sum(
                row["lifecycle"] == "shipping_eligible_static"
                for row in chapter_rows
            ),
            "referenced_author_only": sum(
                row["lifecycle"] == "referenced_author_only" for row in chapter_rows
            ),
            "typed_reference_only": sum(
                row["lifecycle"] == "typed_reference_only" for row in chapter_rows
            ),
            "planned_missing": sum(
                row["lifecycle"] == "planned_missing" for row in chapter_rows
            ),
        }
    overall_rows = list(months.values())
    overall = _sum_metrics(overall_rows)
    product_overall = _sum_metrics([
        row["shipping_eligible_static"] for row in overall_rows
    ])
    global_reachable = {
        event_id
        for row in root_rows
        for event_id in row.get("reachable_event_ids", [])
    }
    product_root_rows = [
        row for row in root_rows
        if row["lifecycle"] == "shipping_eligible_static"
    ]
    product_global_reachable = {
        event_id
        for row in product_root_rows
        for event_id in row.get("reachable_event_ids", [])
    }
    scheduled_all_scope = _sum_metrics([
        row["scheduled_all"] for row in overall_rows
    ])
    scheduled_all_scope.update({
        "unique_roots": len({ref.root_id for ref in refs}),
        "missing_roots": sum(not row["present"] for row in root_rows),
        "global_unique_reachable_events": len(global_reachable),
        "global_dedup_choices": sum(
            len(ko[event_id].data.get("choices", []))
            for event_id in global_reachable
            if event_id in ko and isinstance(ko[event_id].data.get("choices", []), list)
        ),
        "global_dedup_ko_visible_chars": _aggregate_text(ko, global_reachable)[0],
    })
    product_overall.update({
        "unique_roots": len({row["root"] for row in product_root_rows}),
        "missing_roots": 0,
        "global_unique_reachable_events": len(product_global_reachable),
        "global_dedup_choices": sum(
            len(ko[event_id].data.get("choices", []))
            for event_id in product_global_reachable
            if event_id in ko and isinstance(ko[event_id].data.get("choices", []), list)
        ),
        "global_dedup_ko_visible_chars": _aggregate_text(
            ko, product_global_reachable,
        )[0],
    })
    overall.update({
        "scope_default": "shipping_eligible_static",
        "scheduled_all": scheduled_all_scope,
        "shipping_eligible_static": product_overall,
        "chapters": 5,
        "months": 60,
        "unique_roots": product_overall["unique_roots"],
        "fallback_root_refs": sum(
            row["source"] == "fallback" for row in product_root_rows
        ),
        "missing_roots": 0,
        "scheduled_all_unique_roots": len({ref.root_id for ref in refs}),
        "scheduled_all_fallback_root_refs": sum(
            ref.source == "fallback" for ref in refs
        ),
        "scheduled_all_missing_roots": sum(
            not row["present"] for row in root_rows
        ),
        "planned_root_refs": sum(row["lifecycle"] == "planned_missing" for row in root_rows),
        "referenced_author_only_root_refs": sum(
            row["lifecycle"] == "referenced_author_only" for row in root_rows
        ),
        "typed_reference_only_root_refs": sum(
            row["lifecycle"] == "typed_reference_only" for row in root_rows
        ),
        "shipping_eligible_static_root_refs": sum(
            row["lifecycle"] == "shipping_eligible_static" for row in root_rows
        ),
        "rule_present_root_refs": sum(
            bool(row["rule_present"]) for row in product_root_rows
        ),
        "needs_rule_root_refs": sum(
            row["rule_status"] == "needs_rule" for row in product_root_rows
        ),
        "mapped_rule_root_refs": sum(
            row["rule_status"] == "mapped" for row in product_root_rows
        ),
        "scheduled_all_rule_present_root_refs": sum(
            bool(row["rule_present"]) for row in root_rows
        ),
        "global_unique_reachable_events": len(product_global_reachable),
        "global_dedup_choices": sum(
            len(ko[event_id].data.get("choices", []))
            for event_id in product_global_reachable
            if event_id in ko and isinstance(ko[event_id].data.get("choices", []), list)
        ),
        "global_dedup_ko_visible_chars": _aggregate_text(
            ko, product_global_reachable,
        )[0],
    })

    product_cast_appearances: dict[str, set[int]] = defaultdict(set)
    product_channel_appearances: dict[str, set[int]] = defaultdict(set)
    product_tag_appearances: dict[str, set[int]] = defaultdict(set)
    for row in product_root_rows:
        for cast_id in row.get("cast", []):
            if cast_id != "player":
                product_cast_appearances[cast_id].add(int(row["month"]))
        channel = row.get("channel")
        if isinstance(channel, str) and channel:
            product_channel_appearances[channel].add(int(row["month"]))
        for tag in row.get("theme_tags", []):
            if isinstance(tag, str) and tag:
                product_tag_appearances[tag].add(int(row["month"]))
    shipping_root_ids = {row["root"] for row in product_root_rows}
    shipping_receipt_delays = [
        row for row in receipt_delays
        if row["writer_root"] in shipping_root_ids
        and row["reader_root"] in shipping_root_ids
    ]
    product_outliers = _outliers(product_root_rows)
    scheduled_all_outliers = _outliers(root_rows)

    report = {
        "schema_version": SCHEMA_VERSION,
        # A green baseline comparison only proves that the exact known debt did
        # not change.  It is deliberately separate from product readiness.
        "full_game_volume_status": "HOLD",
        "runtime_trace_status": "PENDING",
        "human_density_gate": "OPEN",
        "policy": {
            "blocking": (
                "missing/unreachable roots, graph cycles or zero terminal paths, missing "
                "choice results, cross-month forced closures/time inversion, KO/EN "
                "topology drift, non-product EXPAND roots, and write-only canonical "
                "memory/decision/carryover receipts"
            ),
            "observational": (
                "characters, paragraphs, choice counts, surface-beat depth, relative "
                "outliers, cast/tag gaps, and chapter escalation deltas"
            ),
            "no_length_quota": True,
            "ten_is_not_a_target_or_cap": True,
            "english_overlay": (
                "EN is text-only: effective edges inherit KO; any EN immediate/deferred "
                "edge override, choice-count drift, or missing result is blocking."
            ),
            "runtime_exposure": (
                "PENDING: MainGame runtime trace is required; lifecycle shipping eligibility "
                "and story_map membership do not prove actual exposure."
            ),
            "human_gate": "Automation cannot decide density, attachment, escalation, or fun.",
        },
        "source_hashes": dict(source_hashes or {}),
        "overall": overall,
        "months": months,
        "chapters": chapters,
        "roots": product_root_rows,
        "shipping_eligible_roots": product_root_rows,
        "scheduled_all_roots": root_rows,
        "receipt_reader_delay_scope": "shipping_eligible_static",
        "receipt_reader_delays": shipping_receipt_delays[:40],
        "scheduled_all_receipt_reader_delays": receipt_delays[:40],
        "longest_gaps": {
            "scope_default": "shipping_eligible_static",
            "cast": _gap_rows(product_cast_appearances),
            "channel": _gap_rows(product_channel_appearances),
            "theme_tag": _gap_rows(product_tag_appearances),
            "mapped_story": {
                "empty_months": sum(
                    1 for month in months.values() if month["root_refs"] == 0
                ),
                "longest_empty_run": _longest_empty_month_run(months),
            },
            "scheduled_all": {
                "cast": _gap_rows(cast_appearances),
                "channel": _gap_rows(channel_appearances),
                "theme_tag": _gap_rows(tag_appearances),
                "mapped_story": {
                    "empty_months": sum(
                        1 for month in months.values()
                        if month["scheduled_all"]["root_refs"] == 0
                    ),
                    "longest_empty_run": _longest_empty_month_run(
                        months, "scheduled_all",
                    ),
                },
            },
        },
        "relative_outlier_scope": "shipping_eligible_static",
        "relative_outliers": product_outliers,
        "scheduled_all_relative_outliers": scheduled_all_outliers,
        "structural_findings": structural,
        "lifecycle": {
            "declared_author_only": len(lifecycle_declared),
            "validated_author_only": len(lifecycle_exempt),
            "shipping_eligible_events": len(lifecycle_product),
        },
        "reference_inventory": dict(reference_inventory or {}),
    }
    report["consistency_errors"] = validate_report_consistency(report)
    return report


def _longest_empty_month_run(
    months: Mapping[str, Mapping[str, Any]], scope: str | None = None,
) -> int:
    best = 0
    current = 0
    for month in range(1, 61):
        row = months[f"M{month:02d}"]
        owner = row.get(scope, {}) if scope else row
        if int(owner.get("root_refs", 0)) == 0:
            current += 1
            best = max(best, current)
        else:
            current = 0
    return best


def current_report() -> tuple[dict[str, Any], list[str]]:
    load_errors: list[str] = []
    try:
        story_map = load_json(STORY_MAP_PATH)
        rules = load_json(RULES_PATH)
        year5_reference = load_json(YEAR5_REFERENCE_PATH)
    except (OSError, ValueError, json.JSONDecodeError) as exc:
        return {}, [f"cannot load canonical meta: {exc}"]
    ko, ko_errors = load_events(KO_DIR)
    en, en_errors = load_events(EN_DIR)
    load_errors.extend(ko_errors)
    load_errors.extend(en_errors)
    lifecycle = audit_author_only(ROOT)
    load_errors.extend(f"event lifecycle: {message}" for message in lifecycle.errors)
    refs, _ref_errors = collect_root_refs(story_map)
    reference_inventory = collect_reference_inventory(year5_reference, refs)
    hashes = _source_hashes(refs, ko, en, lifecycle.product_event_ids)
    report = analyze(
        story_map, rules, ko, en,
        set(lifecycle.declared_ids), set(lifecycle.exempt_ids),
        set(lifecycle.product_event_ids),
        typed_reference_ids=collect_typed_reference_ids(year5_reference),
        reference_inventory=reference_inventory,
        source_hashes=hashes,
        load_errors=load_errors,
    )
    return report, []


def baseline_payload(report: Mapping[str, Any]) -> dict[str, Any]:
    observations = {
        "overall": report.get("overall", {}),
        "chapters": report.get("chapters", []),
        "relative_outliers": report.get("relative_outliers", []),
        "longest_gaps": report.get("longest_gaps", {}),
        "reference_inventory": report.get("reference_inventory", {}),
    }
    return {
        "schema_version": SCHEMA_VERSION,
        "policy": {
            "source_hashes_are_exact": True,
            "observations_are_not_quality_quotas": True,
            "character_paragraph_choice_and_beat_counts_are_informational": True,
            "known_structural_debt_is_exact_allowlist": True,
        },
        "source_hashes": report.get("source_hashes", {}),
        "allowlisted_findings": [
            {
                key: finding[key]
                for key in (
                    "code", "month", "root", "event", "choice", "ref_id",
                    "target_month", "target_root", "target_ref_id",
                    "work", "rule_status",
                )
                if key in finding
            }
            for finding in report.get("structural_findings", [])
        ],
        "observations": observations,
    }


def compare_baseline(report: Mapping[str, Any], baseline: Any) -> list[str]:
    errors: list[str] = []
    if not isinstance(baseline, dict) or baseline.get("schema_version") != SCHEMA_VERSION:
        return ["baseline is missing or has the wrong schema_version"]
    expected_hashes = baseline.get("source_hashes", {})
    actual_hashes = report.get("source_hashes", {})
    if expected_hashes != actual_hashes:
        keys = sorted(set(expected_hashes) | set(actual_hashes))
        changed = [key for key in keys if expected_hashes.get(key) != actual_hashes.get(key)]
        errors.append(
            "source hash drift requires intentional observation refresh: "
            + ", ".join(changed)
        )
    allowed_rows = baseline.get("allowlisted_findings", [])
    if not isinstance(allowed_rows, list):
        return errors + ["baseline allowlisted_findings must be an array"]
    allowed = {finding_identity(row) for row in allowed_rows if isinstance(row, dict)}
    actual = {
        finding_identity(row)
        for row in report.get("structural_findings", [])
        if isinstance(row, dict)
    }
    unexpected = sorted(actual - allowed)
    resolved = sorted(allowed - actual)
    if unexpected:
        errors.extend(f"new structural finding: {identity}" for identity in unexpected)
    if resolved:
        errors.extend(
            f"allowlisted debt changed/resolved; refresh baseline intentionally: {identity}"
            for identity in resolved
        )
    expected_observations = baseline.get("observations")
    actual_observations = baseline_payload(report)["observations"]
    if expected_observations != actual_observations:
        errors.append(
            "volume observations drifted; refresh baseline intentionally after "
            "reviewing the M01-M60 delta"
        )
    errors.extend(str(value) for value in report.get("consistency_errors", []))
    return errors


def _mutate_all_decision_reads(story_map: dict[str, Any], decision: str) -> None:
    for chapter in story_map.get("chapters", []):
        for month in chapter.get("months", []):
            for beat in month.get("beats", []):
                reads = beat.get("reads", {})
                if isinstance(reads, dict) and reads.get("decision") == decision:
                    reads["decision"] = None
                coverage = beat.get("coverage", {})
                for fallback in coverage.get("fallbacks", []) \
                        if isinstance(coverage, dict) else []:
                    reads = fallback.get("reads", {}) if isinstance(fallback, dict) else {}
                    if isinstance(reads, dict) and reads.get("decision") == decision:
                        reads["decision"] = None


def _mutate_all_list_reads(
    story_map: dict[str, Any], collection: str, signal: str,
) -> None:
    for chapter in story_map.get("chapters", []):
        for month in chapter.get("months", []):
            for beat in month.get("beats", []):
                owners = [beat]
                coverage = beat.get("coverage", {})
                if isinstance(coverage, dict):
                    owners.extend(
                        row for row in coverage.get("fallbacks", [])
                        if isinstance(row, dict)
                    )
                for owner in owners:
                    reads = owner.get("reads", {})
                    values = reads.get(collection, []) if isinstance(reads, dict) else []
                    if isinstance(values, list):
                        reads[collection] = [value for value in values if value != signal]


def run_self_test() -> tuple[list[str], int]:
    failures: list[str] = []
    cases = 0

    def require(name: str, condition: bool, detail: str = "") -> None:
        nonlocal cases
        cases += 1
        if not condition:
            failures.append(f"{name}: {detail or 'assertion failed'}")

    story_map = load_json(STORY_MAP_PATH)
    rules = load_json(RULES_PATH)
    typed_reference_ids = collect_typed_reference_ids(load_json(YEAR5_REFERENCE_PATH))
    reference_inventory = collect_reference_inventory(
        load_json(YEAR5_REFERENCE_PATH), collect_root_refs(story_map)[0],
    )
    ko, ko_errors = load_events(KO_DIR)
    en, en_errors = load_events(EN_DIR)
    lifecycle = audit_author_only(ROOT)
    base = analyze(
        story_map, rules, ko, en,
        set(lifecycle.declared_ids), set(lifecycle.exempt_ids),
        set(lifecycle.product_event_ids),
        typed_reference_ids=typed_reference_ids,
        reference_inventory=reference_inventory,
        source_hashes={},
        load_errors=ko_errors + en_errors + list(lifecycle.errors),
    )
    require("current comparison", not validate_report_consistency(base))
    require(
        "green audit is not product GO",
        base.get("full_game_volume_status") == "HOLD"
        and base.get("runtime_trace_status") == "PENDING"
        and base.get("human_density_gate") == "OPEN",
    )
    require(
        "reference inventory separation",
        reference_inventory.get("roots") == 32
        and reference_inventory.get("choices") == 86
        and reference_inventory.get("mapped_root_overlap") == []
        and reference_inventory.get("included_in_shipping_eligible_static_totals") is False,
        json.dumps(reference_inventory, ensure_ascii=False, sort_keys=True),
    )
    require(
        "shipping-eligible default scope",
        base["months"]["M09"]["root_refs"]
        == base["months"]["M09"]["shipping_eligible_static"]["root_refs"]
        and base["months"]["M09"]["choices"]
        == base["months"]["M09"]["shipping_eligible_static"]["choices"]
        and base["overall"]["root_refs"]
        == base["overall"]["shipping_eligible_static"]["root_refs"]
        and base["overall"]["ko_visible_chars"]
        == base["overall"]["shipping_eligible_static"]["ko_visible_chars"],
    )

    # A formerly present mapped root disappears.  It must be a new finding,
    # even though exact planned NEW roots already live in the allowlist.
    missing_map = copy.deepcopy(story_map)
    original_root = missing_map["chapters"][0]["months"][0]["beats"][0]["root"]
    missing_map["chapters"][0]["months"][0]["beats"][0]["root"] = \
        "self_test_missing_root"
    report = analyze(
        missing_map, rules, ko, en,
        set(lifecycle.declared_ids), set(lifecycle.exempt_ids),
        set(lifecycle.product_event_ids),
        typed_reference_ids=typed_reference_ids,
        reference_inventory=reference_inventory,
        source_hashes={},
    )
    require(
        "missing root",
        any(row.get("code") == "missing_mapped_root"
            and row.get("root") == "self_test_missing_root"
            for row in report["structural_findings"]),
        original_root,
    )

    cycle_events = copy.deepcopy(ko)
    cycle_record = cycle_events[original_root]
    cycle_data = copy.deepcopy(cycle_record.data)
    cycle_data["choices"][0]["follow_up_event"] = original_root
    cycle_events[original_root] = EventRecord(
        original_root, cycle_record.source, cycle_data,
    )
    report = analyze(
        story_map, rules, cycle_events, en,
        set(lifecycle.declared_ids), set(lifecycle.exempt_ids),
        set(lifecycle.product_event_ids),
        typed_reference_ids=typed_reference_ids,
        reference_inventory=reference_inventory,
        source_hashes={},
    )
    require(
        "cycle",
        any(row.get("code") == "event_graph_cycle"
            and row.get("root") == original_root
            for row in report["structural_findings"]),
    )

    en_topology_events = copy.deepcopy(en)
    en_record = en_topology_events[original_root]
    en_data = copy.deepcopy(en_record.data)
    en_data["choices"][0]["follow_up_event"] = "self_test_wrong_en_target"
    en_topology_events[original_root] = EventRecord(
        original_root, en_record.source, en_data,
    )
    report = analyze(
        story_map, rules, ko, en_topology_events,
        set(lifecycle.declared_ids), set(lifecycle.exempt_ids),
        set(lifecycle.product_event_ids),
        typed_reference_ids=typed_reference_ids,
        reference_inventory=reference_inventory,
        source_hashes={},
    )
    require(
        "English topology override",
        any(row.get("code") == "english_topology_mismatch"
            and row.get("event") == original_root
            for row in report["structural_findings"]),
    )

    zero_events = copy.deepcopy(ko)
    zero_record = zero_events[original_root]
    zero_data = copy.deepcopy(zero_record.data)
    zero_data["choices"] = []
    zero_events[original_root] = EventRecord(
        original_root, zero_record.source, zero_data,
    )
    report = analyze(
        story_map, rules, zero_events, en,
        set(lifecycle.declared_ids), set(lifecycle.exempt_ids),
        set(lifecycle.product_event_ids),
        typed_reference_ids=typed_reference_ids,
        reference_inventory=reference_inventory,
        source_hashes={},
    )
    require(
        "zero terminal",
        any(row.get("code") == "zero_terminal_paths"
            and row.get("root") == original_root
            for row in report["structural_findings"]),
    )

    # A forced closure into a separately scheduled future month makes that
    # monthly root play twice (now and at its own slot).
    forced_events = copy.deepcopy(ko)
    future_root = story_map["chapters"][0]["months"][1]["beats"][0]["root"]
    forced_record = forced_events[original_root]
    forced_data = copy.deepcopy(forced_record.data)
    for choice in forced_data["choices"]:
        choice["follow_up_event"] = future_root
        choice.pop("follow_up_requires_flags", None)
    forced_events[original_root] = EventRecord(
        original_root, forced_record.source, forced_data,
    )
    report = analyze(
        story_map, rules, forced_events, en,
        set(lifecycle.declared_ids), set(lifecycle.exempt_ids),
        set(lifecycle.product_event_ids),
        typed_reference_ids=typed_reference_ids,
        reference_inventory=reference_inventory,
        source_hashes={},
    )
    require(
        "forced closure duplication",
        any(row.get("code") == "forced_cross_month_root_overlap"
            and row.get("root") == original_root
            and row.get("target_root") == future_root
            for row in report["structural_findings"]),
    )

    # The same defect in reverse is stronger: a later month re-enters an
    # already elapsed monthly root.
    inversion_source = story_map["chapters"][0]["months"][9]["beats"][0]["root"]
    inversion_events = copy.deepcopy(ko)
    inversion_record = inversion_events[inversion_source]
    inversion_data = copy.deepcopy(inversion_record.data)
    for choice in inversion_data["choices"]:
        choice["follow_up_event"] = original_root
        choice.pop("follow_up_requires_flags", None)
    inversion_events[inversion_source] = EventRecord(
        inversion_source, inversion_record.source, inversion_data,
    )
    report = analyze(
        story_map, rules, inversion_events, en,
        set(lifecycle.declared_ids), set(lifecycle.exempt_ids),
        set(lifecycle.product_event_ids),
        typed_reference_ids=typed_reference_ids,
        reference_inventory=reference_inventory,
        source_hashes={},
    )
    require(
        "time inversion",
        any(row.get("code") == "time_inversion_root_overlap"
            and row.get("root") == inversion_source
            and row.get("target_root") == original_root
            for row in report["structural_findings"]),
    )

    write_only_memory_map = copy.deepcopy(story_map)
    first_memory = write_only_memory_map["chapters"][0]["months"][0]["beats"][0]["writes"]["memories"][0]
    _mutate_all_list_reads(write_only_memory_map, "memories", first_memory)
    report = analyze(
        write_only_memory_map, rules, ko, en,
        set(lifecycle.declared_ids), set(lifecycle.exempt_ids),
        set(lifecycle.product_event_ids),
        typed_reference_ids=typed_reference_ids,
        reference_inventory=reference_inventory,
        source_hashes={},
    )
    require(
        "write-only memory",
        any(row.get("code") == "write_only_memory"
            and row.get("memory") == first_memory
            for row in report["structural_findings"]),
    )

    write_only_map = copy.deepcopy(story_map)
    first_decision = write_only_map["chapters"][0]["months"][0]["beats"][0]["writes"]["decision"]
    _mutate_all_decision_reads(write_only_map, first_decision)
    report = analyze(
        write_only_map, rules, ko, en,
        set(lifecycle.declared_ids), set(lifecycle.exempt_ids),
        set(lifecycle.product_event_ids),
        typed_reference_ids=typed_reference_ids,
        reference_inventory=reference_inventory,
        source_hashes={},
    )
    require(
        "write-only decision",
        any(row.get("code") == "write_only_decision"
            and row.get("decision") == first_decision
            for row in report["structural_findings"]),
    )

    corrupt = copy.deepcopy(base)
    corrupt["chapters"][0]["segments"]["boss"]["choices"] += 1
    require(
        "chapter escalation comparison corruption",
        any("chapter 1 escalation segments" in message
            for message in validate_report_consistency(corrupt)),
    )
    baseline = baseline_payload(base)
    drifted = copy.deepcopy(base)
    drifted["overall"]["shipping_eligible_static"]["choices"] += 1
    require(
        "baseline observation drift",
        any("volume observations drifted" in message
            for message in compare_baseline(drifted, baseline)),
    )
    return failures, cases


def print_human(report: Mapping[str, Any], errors: Sequence[str]) -> None:
    overall = report.get("overall", {})
    product = overall.get("shipping_eligible_static", {}) \
        if isinstance(overall, dict) else {}
    scheduled_all = overall.get("scheduled_all", {}) \
        if isinstance(overall, dict) else {}
    print(
        "FULL_GAME_VOLUME "
        f"months={overall.get('months', 0)} chapters={overall.get('chapters', 0)} "
        f"scheduled_refs={scheduled_all.get('root_refs', 0)} "
        f"shipping_eligible_refs={product.get('root_refs', 0)} "
        f"planned_missing={overall.get('planned_root_refs', 0)} "
        f"static_paths={product.get('terminal_paths', 0)} "
        f"static_choices={product.get('choices', 0)}"
    )
    print(
        "  lifecycle "
        f"shipping_eligible_refs={overall.get('shipping_eligible_static_root_refs', 0)} "
        f"referenced_author_only_refs={overall.get('referenced_author_only_root_refs', 0)} "
        f"typed_reference_only_refs={overall.get('typed_reference_only_root_refs', 0)} "
        f"planned_missing_refs={overall.get('planned_root_refs', 0)} "
        f"rules={overall.get('rule_present_root_refs', 0)}/{overall.get('root_refs', 0)}"
    )
    print(
        "  shipping-eligible mapped static volume (not runtime exposure; not quota) "
        f"ko_chars={product.get('ko_visible_chars', 0)} "
        f"ko_paragraphs={product.get('ko_paragraphs', 0)} "
        f"max_surface_beats={product.get('max_surface_beat_depth', 0)} "
        f"global_dedup_chars={product.get('global_dedup_ko_visible_chars', 0)}"
    )
    print(
        "  scheduled-all authoring view (includes debt; not runtime exposure) "
        f"ko_chars={scheduled_all.get('ko_visible_chars', 0)} "
        f"choices={scheduled_all.get('choices', 0)} "
        f"global_dedup_chars={scheduled_all.get('global_dedup_ko_visible_chars', 0)}"
    )
    print("  shipping-eligible static chapter start/mid/boss observations")
    for chapter in report.get("chapters", []):
        if not isinstance(chapter, dict):
            continue
        segments = chapter.get("shipping_eligible_segments", {})
        cells = []
        for key in SEGMENT_KEYS:
            row = segments.get(key, {})
            cells.append(
                f"{key}:roots{row.get('present_roots', 0)}/"
                f"paths{row.get('terminal_paths', 0)}/choices{row.get('choices', 0)}/"
                f"reads{row.get('receipt_readers', 0)}/beats≤{row.get('max_surface_beat_depth', 0)}"
            )
        print(f"    C{chapter.get('chapter')}: " + " | ".join(cells))
    reference = report.get("reference_inventory", {})
    print(
        "  dormant reference inventory (excluded from mapped static totals) "
        f"roots={reference.get('roots', 0)} choices={reference.get('choices', 0)} "
        f"mapped_overlap={len(reference.get('mapped_root_overlap', []))} "
        f"activation={reference.get('activation')}"
    )
    findings = report.get("structural_findings", [])
    print(
        f"  structural_findings={len(findings)} "
        f"relative_outliers={len(report.get('relative_outliers', []))} "
        f"receipt_delays={len(report.get('receipt_reader_delays', []))}"
    )
    for finding in findings[:24]:
        print("  FINDING " + json.dumps(finding, ensure_ascii=False, sort_keys=True))
    if len(findings) > 24:
        print(f"  FINDING ... {len(findings) - 24} more (use --json)")
    for error in errors:
        print(f"ERROR full game volume: {error}")
    marker = "FULL_GAME_VOLUME_AUDIT_FAIL" if errors else "FULL_GAME_VOLUME_AUDIT_OK"
    print(
        f"{marker} findings={len(findings)} outliers={len(report.get('relative_outliers', []))} "
        f"known_debt={len(findings)} full_game_volume_status=HOLD "
        "runtime_trace=PENDING human_density_gate=OPEN"
    )


def main(argv: Sequence[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--json", action="store_true", help="print the full machine-readable report")
    parser.add_argument("--self-test", action="store_true", help="run in-memory rejection cases")
    parser.add_argument(
        "--write-baseline", action="store_true",
        help="intentionally record current hashes, observations, and exact known debt",
    )
    args = parser.parse_args(argv)

    if args.self_test:
        failures, cases = run_self_test()
        if failures:
            for failure in failures:
                print(f"ERROR full game volume self-test: {failure}")
            print(
                f"FULL_GAME_VOLUME_SELF_TEST_FAIL cases={cases} failures={len(failures)}"
            )
            return 1
        print(f"FULL_GAME_VOLUME_SELF_TEST_OK cases={cases}")
        return 0

    report, load_errors = current_report()
    if load_errors:
        for error in load_errors:
            print(f"ERROR full game volume: {error}")
        print("FULL_GAME_VOLUME_AUDIT_FAIL load=1")
        return 1

    if args.write_baseline:
        payload = baseline_payload(report)
        BASELINE_PATH.write_text(
            json.dumps(payload, ensure_ascii=False, indent=2, sort_keys=True) + "\n",
            encoding="utf-8",
        )
        print(
            "FULL_GAME_VOLUME_BASELINE_WRITTEN "
            f"findings={len(payload['allowlisted_findings'])} "
            f"source_hashes={len(payload['source_hashes'])}"
        )
        return 0

    try:
        baseline = load_json(BASELINE_PATH)
    except (OSError, ValueError, json.JSONDecodeError) as exc:
        baseline = {}
        baseline_error = [f"cannot load baseline: {exc}"]
    else:
        baseline_error = []
    errors = baseline_error + compare_baseline(report, baseline)
    if args.json:
        output = copy.deepcopy(report)
        output["status"] = "FAIL" if errors else "OK"
        output["baseline_errors"] = errors
        print(json.dumps(output, ensure_ascii=False, indent=2, sort_keys=True))
    else:
        print_human(report, errors)
    return 1 if errors else 0


if __name__ == "__main__":
    raise SystemExit(main())
