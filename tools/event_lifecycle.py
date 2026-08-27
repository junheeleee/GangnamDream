#!/usr/bin/env python3
"""Validate the packaged/shipping boundary for dormant authored events.

The machine ledger owns the exact author-only corpus.  A ledger declaration is
exempt from shipping audits only while its schedule metadata is dormant and no
product ingress can reach it.  Tags alone never grant an exemption.
"""

from __future__ import annotations

import argparse
import copy
import hashlib
import json
import re
import sys
from collections import deque
from dataclasses import dataclass, replace
from pathlib import Path
from typing import Any, Iterable, Mapping, Sequence

from event_schedule import DeferredFollowUpError, deferred_follow_ups


ROOT = Path(__file__).resolve().parents[1]
LEDGER_RELATIVE_PATH = Path("content/meta/event_lifecycle.json")
PRODUCT_GDSCRIPT_DIRS = ("autoloads", "scenes", "systems", "ui_components")
EXPECTED_SCHEMA_VERSION = 1
EXPECTED_LEDGER_ID = "event_lifecycle_v1"
EXPECTED_BASELINE_COMMIT = "3b275a913053412a3e2ff52fc9588d71d3a9bb37"
HASH_SEMANTICS = "sha256(UTF-8 sorted unique IDs joined by LF with one trailing LF)"


@dataclass(frozen=True)
class EventRecord:
    event_id: str
    relative_path: str
    row: dict[str, Any]


@dataclass(frozen=True)
class EventEdge:
    source_id: str
    target_id: str
    kind: str
    location: str


@dataclass(frozen=True)
class IngressEvidence:
    target_id: str
    kind: str
    location: str


@dataclass(frozen=True)
class LifecycleInputs:
    ledger: dict[str, Any]
    events: tuple[EventRecord, ...]
    edges: tuple[EventEdge, ...]
    explicit_ingress: tuple[IngressEvidence, ...]
    load_errors: tuple[str, ...] = ()


@dataclass(frozen=True)
class AuthorOnlyReport:
    declared_ids: frozenset[str]
    meta_valid_ids: frozenset[str]
    exempt_ids: frozenset[str]
    product_event_ids: frozenset[str]
    packaged_event_ids: frozenset[str]
    ingress_conflict_ids: frozenset[str]
    errors: tuple[str, ...]
    conflict_evidence: tuple[IngressEvidence, ...] = ()


def event_id_digest(values: Iterable[str]) -> str:
    payload = "\n".join(sorted(set(values))) + "\n"
    return hashlib.sha256(payload.encode("utf-8")).hexdigest()


def _load_event_rows(path: Path) -> list[dict[str, Any]]:
    raw = json.loads(path.read_text(encoding="utf-8"))
    if isinstance(raw, list):
        return [row for row in raw if isinstance(row, dict)]
    if isinstance(raw, dict) and isinstance(raw.get("events"), list):
        return [row for row in raw["events"] if isinstance(row, dict)]
    if isinstance(raw, dict):
        values = list(raw.values())
        if values and all(isinstance(value, dict) for value in values):
            return values
    raise ValueError("event JSON must be an array or an object containing events")


def _owner_edges(
    source_id: str,
    owner: Mapping[str, Any],
    location: str,
) -> tuple[list[EventEdge], list[str]]:
    edges: list[EventEdge] = []
    errors: list[str] = []
    for key in ("follow_up", "follow_up_event", "next_event"):
        target = owner.get(key)
        if isinstance(target, str) and target.strip():
            edges.append(EventEdge(source_id, target.strip(), key, f"{location}.{key}"))
    try:
        for target, _delay in deferred_follow_ups(dict(owner)):
            edges.append(EventEdge(
                source_id,
                target,
                "deferred_follow_up",
                f"{location}.deferred_follow_up",
            ))
    except DeferredFollowUpError as exc:
        errors.append(f"{location}.deferred_follow_up: {exc}")
    return edges, errors


def _event_edges(record: EventRecord) -> tuple[list[EventEdge], list[str]]:
    edges, errors = _owner_edges(
        record.event_id, record.row, f"{record.relative_path} [{record.event_id}]"
    )
    choices = record.row.get("choices", [])
    if not isinstance(choices, list):
        return edges, errors
    for index, choice in enumerate(choices):
        if not isinstance(choice, dict):
            continue
        child_edges, child_errors = _owner_edges(
            record.event_id,
            choice,
            f"{record.relative_path} [{record.event_id}].choices[{index}]",
        )
        edges.extend(child_edges)
        errors.extend(child_errors)
    return edges, errors


def _quoted_literal_ingress(
    text: str,
    candidates: set[str],
    location: str,
) -> list[IngressEvidence]:
    evidence: list[IngressEvidence] = []
    for event_id in candidates:
        literals = (
            json.dumps(event_id, ensure_ascii=False),
            "'" + event_id.replace("\\", "\\\\").replace("'", "\\'") + "'",
        )
        for literal in literals:
            start = 0
            while True:
                offset = text.find(literal, start)
                if offset < 0:
                    break
                line = text.count("\n", 0, offset) + 1
                evidence.append(IngressEvidence(
                    event_id, "product_gdscript_literal", f"{location}:{line}"
                ))
                start = offset + len(literal)
    return evidence


def _lifecycle_manifest_load_errors(text: str, location: str) -> list[str]:
    manifest_path = LEDGER_RELATIVE_PATH.as_posix()
    if manifest_path not in text:
        return []
    return [
        f"{location}: product source references the non-runtime lifecycle ledger "
        f"{manifest_path}"
    ]


def _thought_ingress(raw: Any, candidates: set[str]) -> list[IngressEvidence]:
    evidence: list[IngressEvidence] = []
    if not isinstance(raw, list):
        return evidence
    for index, thought in enumerate(raw):
        if not isinstance(thought, dict):
            continue
        complete = thought.get("on_complete", {})
        target = complete.get("unlock_event") if isinstance(complete, dict) else None
        if isinstance(target, str) and target in candidates:
            evidence.append(IngressEvidence(
                target,
                "thought_unlock",
                f"content/meta/thoughts.json[{index}].on_complete.unlock_event",
            ))
    return evidence


def _demo_ingress(raw: Any, candidates: set[str]) -> list[IngressEvidence]:
    evidence: list[IngressEvidence] = []
    bundles = raw.get("scene_bundles", {}) if isinstance(raw, dict) else {}
    if not isinstance(bundles, dict):
        return evidence
    for bundle_id, bundle in bundles.items():
        if not isinstance(bundle, dict):
            continue
        roots = bundle.get("existing_roots", [])
        if not isinstance(roots, list):
            continue
        for index, target in enumerate(roots):
            if isinstance(target, str) and target in candidates:
                evidence.append(IngressEvidence(
                    target,
                    "demo_existing_root",
                    "content/meta/demo_core_loop_v2.json."
                    f"scene_bundles.{bundle_id}.existing_roots[{index}]",
                ))

    for owner_key, evidence_kind in (
        ("future_story_contracts", "demo_future_story_result"),
        ("post_demo_application_contracts", "demo_application_result"),
    ):
        contracts = raw.get(owner_key, {}) if isinstance(raw, dict) else {}
        if not isinstance(contracts, dict):
            continue
        for contract_id, spec in contracts.items():
            target = spec.get("result_event") if isinstance(spec, dict) else None
            if isinstance(target, str) and target in candidates:
                evidence.append(IngressEvidence(
                    target,
                    evidence_kind,
                    "content/meta/demo_core_loop_v2.json."
                    f"{owner_key}.{contract_id}.result_event",
                ))
    return evidence


def _director_ingress(raw: Any, candidates: set[str]) -> list[IngressEvidence]:
    evidence: list[IngressEvidence] = []
    if not isinstance(raw, dict):
        return evidence

    content_diet = raw.get("content_diet", {})
    if isinstance(content_diet, dict):
        for key in (
            "foreground_event_ids",
            "bridge_event_ids",
            "bridge_fallback_event_ids",
        ):
            values = content_diet.get(key, [])
            if not isinstance(values, list):
                continue
            for index, target in enumerate(values):
                if isinstance(target, str) and target in candidates:
                    evidence.append(IngressEvidence(
                        target,
                        "event_director",
                        f"content/meta/event_director.json.content_diet.{key}[{index}]",
                    ))

    for pacing_key in ("demo_pacing", "full_run_pacing"):
        pacing = raw.get(pacing_key, {})
        owners = pacing.get("commitment_event_owners", {}) \
            if isinstance(pacing, dict) else {}
        if not isinstance(owners, dict):
            continue
        for week, rows in owners.items():
            if not isinstance(rows, list):
                continue
            for index, row in enumerate(rows):
                target = row.get("id") if isinstance(row, dict) else row
                if isinstance(target, str) and target in candidates:
                    evidence.append(IngressEvidence(
                        target,
                        "event_director",
                        "content/meta/event_director.json."
                        f"{pacing_key}.commitment_event_owners.{week}[{index}]",
                    ))

    relationships = raw.get("relationships", {})
    introductions = relationships.get("introduction_events", {}) \
        if isinstance(relationships, dict) else {}
    if isinstance(introductions, dict):
        for person_id, values in introductions.items():
            if not isinstance(values, list):
                continue
            for index, target in enumerate(values):
                if isinstance(target, str) and target in candidates:
                    evidence.append(IngressEvidence(
                        target,
                        "event_director",
                        "content/meta/event_director.json.relationships."
                        f"introduction_events.{person_id}[{index}]",
                    ))

    for key in ("repeatable_events", "context_requirements"):
        values = raw.get(key, {})
        if not isinstance(values, dict):
            continue
        for target in values:
            if isinstance(target, str) and target in candidates:
                evidence.append(IngressEvidence(
                    target,
                    "event_director",
                    f"content/meta/event_director.json.{key}.{target}",
                ))
    return evidence


def _release_inventory_ingress(
    raw: Any,
    candidates: set[str],
    location: str = "content/meta/release_content_inventory.json",
) -> list[IngressEvidence]:
    evidence: list[IngressEvidence] = []
    if isinstance(raw, dict):
        for key, value in raw.items():
            child_location = f"{location}.{key}"
            if key == "event_ids" and isinstance(value, list):
                for index, target in enumerate(value):
                    if isinstance(target, str) and target in candidates:
                        evidence.append(IngressEvidence(
                            target,
                            "release_inventory",
                            f"{child_location}[{index}]",
                        ))
                continue
            evidence.extend(
                _release_inventory_ingress(value, candidates, child_location)
            )
    elif isinstance(raw, list):
        for index, value in enumerate(raw):
            evidence.extend(_release_inventory_ingress(
                value, candidates, f"{location}[{index}]"
            ))
    return evidence


def _load_json_ingress(
    path: Path,
    collector: Any,
    candidates: set[str],
) -> tuple[list[IngressEvidence], list[str]]:
    try:
        raw = json.loads(path.read_text(encoding="utf-8"))
    except (OSError, ValueError, json.JSONDecodeError) as exc:
        return [], [f"{path}: cannot load ingress source: {exc}"]
    return collector(raw, candidates), []


def collect_lifecycle_inputs(root: Path | str = ROOT) -> LifecycleInputs:
    repo = Path(root).resolve()
    errors: list[str] = []
    ledger_path = repo / LEDGER_RELATIVE_PATH
    try:
        ledger = json.loads(ledger_path.read_text(encoding="utf-8"))
    except (OSError, ValueError, json.JSONDecodeError) as exc:
        ledger = {}
        errors.append(f"{LEDGER_RELATIVE_PATH}: cannot load lifecycle ledger: {exc}")
    if not isinstance(ledger, dict):
        errors.append(f"{LEDGER_RELATIVE_PATH}: ledger root must be an object")
        ledger = {}

    raw_declared = ledger.get("author_only_event_ids", [])
    candidates = {
        value for value in raw_declared
        if isinstance(value, str) and value
    } if isinstance(raw_declared, list) else set()

    records: list[EventRecord] = []
    for path in sorted((repo / "content/events").glob("*.json")):
        relative = path.relative_to(repo).as_posix()
        try:
            rows = _load_event_rows(path)
        except (OSError, ValueError, json.JSONDecodeError) as exc:
            errors.append(f"{relative}: cannot load events: {exc}")
            continue
        for index, row in enumerate(rows):
            event_id = row.get("id")
            if not isinstance(event_id, str) or not event_id:
                errors.append(f"{relative}[{index}]: event id must be a non-empty string")
                continue
            records.append(EventRecord(event_id, relative, row))

    edges: list[EventEdge] = []
    for record in records:
        event_edges, edge_errors = _event_edges(record)
        edges.extend(event_edges)
        errors.extend(edge_errors)

    explicit: list[IngressEvidence] = []
    for directory in PRODUCT_GDSCRIPT_DIRS:
        for path in sorted((repo / directory).rglob("*.gd")):
            try:
                text = path.read_text(encoding="utf-8")
            except OSError as exc:
                errors.append(f"{path.relative_to(repo)}: cannot scan product code: {exc}")
                continue
            errors.extend(_lifecycle_manifest_load_errors(
                text, path.relative_to(repo).as_posix()
            ))
            explicit.extend(_quoted_literal_ingress(
                text, candidates, path.relative_to(repo).as_posix()
            ))

    sources = (
        (repo / "content/meta/thoughts.json", _thought_ingress),
        (repo / "content/meta/demo_core_loop_v2.json", _demo_ingress),
        (repo / "content/meta/event_director.json", _director_ingress),
        (
            repo / "content/meta/release_content_inventory.json",
            _release_inventory_ingress,
        ),
    )
    for path, collector in sources:
        source_evidence, source_errors = _load_json_ingress(
            path, collector, candidates
        )
        explicit.extend(source_evidence)
        errors.extend(source_errors)

    return LifecycleInputs(
        ledger=ledger,
        events=tuple(records),
        edges=tuple(edges),
        explicit_ingress=tuple(explicit),
        load_errors=tuple(errors),
    )


def _number_zero(value: Any) -> bool:
    return isinstance(value, (int, float)) \
        and not isinstance(value, bool) and value == 0


def _safe_author_metadata(event: Mapping[str, Any]) -> list[str]:
    problems: list[str] = []
    if not _number_zero(event.get("weight")):
        problems.append("weight must be numeric zero")
    if event.get("hidden") is not True:
        problems.append("hidden must be true")
    conditions = event.get("conditions")
    if not isinstance(conditions, dict) or set(conditions) != {"min_turn"}:
        problems.append("conditions must contain only min_turn")
    else:
        min_turn = conditions.get("min_turn")
        if not isinstance(min_turn, int) or isinstance(min_turn, bool) \
                or min_turn != 9999:
            problems.append("conditions.min_turn must be integer 9999")
    return problems


def _manifest_integer(
    owner: Mapping[str, Any], key: str, errors: list[str]
) -> int | None:
    value = owner.get(key)
    if not isinstance(value, int) or isinstance(value, bool) or value < 0:
        errors.append(f"ledger counts.{key} must be a non-negative integer")
        return None
    return value


def _manifest_digest(
    owner: Mapping[str, Any], key: str, errors: list[str]
) -> str | None:
    value = owner.get(key)
    if not isinstance(value, str) or re.fullmatch(r"[0-9a-f]{64}", value) is None:
        errors.append(f"ledger sha256.{key} must be a lowercase SHA-256")
        return None
    return value


def evaluate_author_only(inputs: LifecycleInputs) -> AuthorOnlyReport:
    errors = list(inputs.load_errors)
    ledger = inputs.ledger
    expected_top = {
        "schema_version", "ledger_id", "baseline_commit", "hash_semantics",
        "counts", "sha256", "contract", "author_only_event_ids",
    }
    if set(ledger) != expected_top:
        errors.append(
            "lifecycle ledger keys differ: "
            f"missing={sorted(expected_top - set(ledger))} "
            f"extra={sorted(set(ledger) - expected_top)}"
        )
    if ledger.get("schema_version") != EXPECTED_SCHEMA_VERSION:
        errors.append("lifecycle ledger schema_version must be 1")
    if ledger.get("ledger_id") != EXPECTED_LEDGER_ID:
        errors.append(f"lifecycle ledger_id must be {EXPECTED_LEDGER_ID}")
    if ledger.get("baseline_commit") != EXPECTED_BASELINE_COMMIT:
        errors.append(
            f"lifecycle baseline_commit must remain {EXPECTED_BASELINE_COMMIT}"
        )
    if ledger.get("hash_semantics") != HASH_SEMANTICS:
        errors.append("lifecycle hash_semantics drifted")

    raw_ids = ledger.get("author_only_event_ids")
    if not isinstance(raw_ids, list):
        errors.append("author_only_event_ids must be an array")
        raw_ids = []
    invalid_ids = [value for value in raw_ids if not isinstance(value, str) or not value]
    if invalid_ids:
        errors.append("author_only_event_ids must contain only non-empty strings")
    declared_values = [value for value in raw_ids if isinstance(value, str) and value]
    if len(declared_values) != len(set(declared_values)):
        errors.append("author_only_event_ids contains duplicate IDs")
    if declared_values != sorted(declared_values):
        errors.append("author_only_event_ids must be sorted lexicographically")
    declared = set(declared_values)

    records_by_id: dict[str, EventRecord] = {}
    duplicate_event_ids: set[str] = set()
    for record in inputs.events:
        if record.event_id in records_by_id:
            duplicate_event_ids.add(record.event_id)
        else:
            records_by_id[record.event_id] = record
    if duplicate_event_ids:
        errors.append(
            f"packaged event IDs are duplicated: {sorted(duplicate_event_ids)}"
        )
    packaged = set(records_by_id)

    counts = ledger.get("counts", {})
    expected_count_keys = {
        "packaged_events", "shipping_events", "author_only_events",
        "tagged_author_only_events", "ledger_only_author_only_events",
    }
    if not isinstance(counts, dict) or set(counts) != expected_count_keys:
        errors.append("lifecycle ledger counts keys differ")
        counts = counts if isinstance(counts, dict) else {}
    count_values = {
        key: _manifest_integer(counts, key, errors) for key in expected_count_keys
    }

    digests = ledger.get("sha256", {})
    expected_digest_keys = {
        "packaged_event_ids", "shipping_event_ids", "author_only_event_ids",
        "tagged_author_only_event_ids", "ledger_only_author_only_event_ids",
    }
    if not isinstance(digests, dict) or set(digests) != expected_digest_keys:
        errors.append("lifecycle ledger sha256 keys differ")
        digests = digests if isinstance(digests, dict) else {}
    digest_values = {
        key: _manifest_digest(digests, key, errors)
        for key in expected_digest_keys
    }

    contract = ledger.get("contract", {})
    if not isinstance(contract, dict):
        errors.append("lifecycle contract must be an object")
        contract = {}
    if contract.get("weight") != 0 or isinstance(contract.get("weight"), bool):
        errors.append("lifecycle contract weight must be numeric zero")
    if contract.get("hidden") is not True:
        errors.append("lifecycle contract hidden must be true")
    if contract.get("conditions") != {"min_turn": 9999}:
        errors.append("lifecycle contract conditions must be exact min_turn 9999")
    if contract.get("product_ingress_must_be_empty") is not True:
        errors.append("lifecycle contract must forbid product ingress")
    if not isinstance(contract.get("activation_requirements"), list) \
            or len(contract.get("activation_requirements", [])) != 3:
        errors.append("lifecycle activation_requirements must contain three steps")
    if not isinstance(contract.get("non_product_reference_sources"), list) \
            or len(contract.get("non_product_reference_sources", [])) != 2:
        errors.append("lifecycle non_product_reference_sources must contain two rows")

    def check_inventory(
        label: str,
        values: set[str],
        count_key: str,
        digest_key: str,
    ) -> None:
        wanted_count = count_values.get(count_key)
        if wanted_count is not None and len(values) != wanted_count:
            errors.append(
                f"{label} count drifted: expected {wanted_count}, got {len(values)}"
            )
        wanted_digest = digest_values.get(digest_key)
        actual_digest = event_id_digest(values)
        if wanted_digest is not None and actual_digest != wanted_digest:
            errors.append(
                f"{label} ID digest drifted: expected {wanted_digest}, "
                f"got {actual_digest}"
            )

    tagged: set[str] = set()
    for event_id, record in records_by_id.items():
        tags = record.row.get("tags")
        if isinstance(tags, list) and "author_only" in tags:
            tagged.add(event_id)
            if any(not isinstance(tag, str) for tag in tags):
                errors.append(f"{event_id}: tags must contain only strings")
    unexpected_tags = tagged - declared
    if unexpected_tags:
        errors.append(
            "author_only tagged IDs absent from lifecycle ledger: "
            f"{sorted(unexpected_tags)}"
        )
    missing_declared = declared - packaged
    if missing_declared:
        errors.append(
            f"lifecycle ledger IDs absent from packaged events: {sorted(missing_declared)}"
        )
    ledger_only = declared - tagged
    ledger_shipping = packaged - declared

    check_inventory(
        "packaged events", packaged, "packaged_events", "packaged_event_ids"
    )
    check_inventory(
        "author-only events", declared,
        "author_only_events", "author_only_event_ids",
    )
    check_inventory(
        "tagged author-only events", tagged,
        "tagged_author_only_events", "tagged_author_only_event_ids",
    )
    check_inventory(
        "ledger-only author events", ledger_only,
        "ledger_only_author_only_events", "ledger_only_author_only_event_ids",
    )
    check_inventory(
        "ledger shipping events", ledger_shipping,
        "shipping_events", "shipping_event_ids",
    )

    meta_valid: set[str] = set()
    for event_id in sorted(declared):
        record = records_by_id.get(event_id)
        if record is None:
            continue
        problems = _safe_author_metadata(record.row)
        if problems:
            errors.append(
                f"{record.relative_path} [{event_id}] invalid author-only metadata: "
                + "; ".join(problems)
            )
        else:
            meta_valid.add(event_id)

    adjacency: dict[str, list[EventEdge]] = {}
    for edge in inputs.edges:
        adjacency.setdefault(edge.source_id, []).append(edge)

    explicit_by_target: dict[str, list[IngressEvidence]] = {}
    for evidence in inputs.explicit_ingress:
        explicit_by_target.setdefault(evidence.target_id, []).append(evidence)

    # Any event not proven dormant is a conservative product seed.  Following
    # edges only in source->target direction catches active->author and
    # active->author->author without making author->active an ingress.
    reachable = set(packaged - meta_valid)
    predecessor: dict[str, EventEdge | IngressEvidence] = {}
    for target, evidence_rows in explicit_by_target.items():
        if target not in reachable:
            reachable.add(target)
            predecessor[target] = evidence_rows[0]
    pending = deque(reachable)
    while pending:
        source = pending.popleft()
        for edge in adjacency.get(source, []):
            if edge.target_id in reachable:
                continue
            reachable.add(edge.target_id)
            predecessor[edge.target_id] = edge
            pending.append(edge.target_id)

    conflicts = meta_valid & reachable
    conflict_evidence: list[IngressEvidence] = []
    for event_id in sorted(conflicts):
        source = predecessor.get(event_id)
        if isinstance(source, IngressEvidence):
            evidence = source
        elif isinstance(source, EventEdge):
            evidence = IngressEvidence(
                event_id,
                f"event_{source.kind}",
                f"{source.location} ({source.source_id}->{source.target_id})",
            )
        else:
            evidence = IngressEvidence(event_id, "product_graph", "unknown seed")
        conflict_evidence.append(evidence)
        errors.append(
            f"author-only product ingress: {event_id} via "
            f"{evidence.kind} at {evidence.location}"
        )

    exempt = meta_valid - conflicts
    product = packaged - exempt
    check_inventory(
        "validated shipping events", product,
        "shipping_events", "shipping_event_ids",
    )

    return AuthorOnlyReport(
        declared_ids=frozenset(declared),
        meta_valid_ids=frozenset(meta_valid),
        exempt_ids=frozenset(exempt),
        product_event_ids=frozenset(product),
        packaged_event_ids=frozenset(packaged),
        ingress_conflict_ids=frozenset(conflicts),
        errors=tuple(errors),
        conflict_evidence=tuple(conflict_evidence),
    )


def audit_author_only(root: Path | str = ROOT) -> AuthorOnlyReport:
    return evaluate_author_only(collect_lifecycle_inputs(root))


def _mutate_event(
    inputs: LifecycleInputs,
    event_id: str,
    mutate: Any,
) -> LifecycleInputs:
    records: list[EventRecord] = []
    for record in inputs.events:
        if record.event_id != event_id:
            records.append(record)
            continue
        row = copy.deepcopy(record.row)
        mutate(row)
        records.append(replace(record, row=row))
    return replace(inputs, events=tuple(records))


def run_self_test(root: Path | str = ROOT) -> tuple[list[str], int]:
    inputs = collect_lifecycle_inputs(root)
    baseline = evaluate_author_only(inputs)
    failures: list[str] = []
    cases = 0

    def require(name: str, condition: bool, detail: str = "") -> None:
        nonlocal cases
        cases += 1
        if not condition:
            failures.append(f"{name}: {detail or 'assertion failed'}")

    require("current ledger", not baseline.errors, "; ".join(baseline.errors[:3]))
    require("current counts", (
        len(baseline.declared_ids), len(baseline.exempt_ids),
        len(baseline.packaged_event_ids), len(baseline.product_event_ids),
    ) == (110, 110, 1800, 1690))
    require("current ingress", not baseline.ingress_conflict_ids)

    target = sorted(baseline.declared_ids)[0]
    second = sorted(baseline.declared_ids)[1]
    active = sorted(baseline.product_event_ids)[0]

    meta_mutations = (
        ("weight one", lambda row: row.__setitem__("weight", 1), "weight"),
        ("weight bool", lambda row: row.__setitem__("weight", False), "weight"),
        ("hidden false", lambda row: row.__setitem__("hidden", False), "hidden"),
        ("conditions extra", lambda row: row.__setitem__(
            "conditions", {"min_turn": 9999, "flag": "x"}), "conditions"),
        ("min turn low", lambda row: row.__setitem__(
            "conditions", {"min_turn": 9998}), "min_turn"),
        ("min turn bool", lambda row: row.__setitem__(
            "conditions", {"min_turn": True}), "min_turn"),
    )
    for name, mutation, token in meta_mutations:
        report = evaluate_author_only(_mutate_event(inputs, target, mutation))
        require(
            name,
            target not in report.exempt_ids
            and any(token in message for message in report.errors),
        )

    missing_ledger = copy.deepcopy(inputs.ledger)
    missing_ledger["author_only_event_ids"].pop()
    report = evaluate_author_only(replace(inputs, ledger=missing_ledger))
    require("ledger missing", any("author-only events" in e for e in report.errors))

    duplicate_ledger = copy.deepcopy(inputs.ledger)
    duplicate_ledger["author_only_event_ids"].append(target)
    report = evaluate_author_only(replace(inputs, ledger=duplicate_ledger))
    require("ledger duplicate", any("duplicate IDs" in e for e in report.errors))

    digest_ledger = copy.deepcopy(inputs.ledger)
    digest_ledger["sha256"]["author_only_event_ids"] = "0" * 64
    report = evaluate_author_only(replace(inputs, ledger=digest_ledger))
    require("ledger hash", any("author-only events ID digest" in e for e in report.errors))

    tagged_active = _mutate_event(
        inputs,
        active,
        lambda row: row.__setitem__("tags", [
            *(row.get("tags", []) if isinstance(row.get("tags"), list) else []),
            "author_only",
        ]),
    )
    report = evaluate_author_only(tagged_active)
    require("tag alone", any("tagged IDs absent" in e for e in report.errors))

    literal = _quoted_literal_ingress(
        f'const ROOT = "{target}"', {target}, "systems/Synthetic.gd"
    )
    single_literal = _quoted_literal_ingress(
        f"const ROOT = '{target}'", {target}, "systems/SyntheticSingle.gd"
    )
    source_cases: list[tuple[str, list[IngressEvidence]]] = [
        ("product literal", literal),
        ("product single-quoted literal", single_literal),
        ("thought unlock", _thought_ingress([
            {"id": "thought", "on_complete": {"unlock_event": target}}
        ], {target})),
        ("demo root", _demo_ingress({
            "scene_bundles": {"demo": {"existing_roots": [target]}}
        }, {target})),
        ("demo future result", _demo_ingress({
            "future_story_contracts": {
                "future": {"result_event": target},
            },
        }, {target})),
        ("demo application result", _demo_ingress({
            "post_demo_application_contracts": {
                "application": {"result_event": target},
            },
        }, {target})),
        ("director root", _director_ingress({
            "content_diet": {"foreground_event_ids": [target]}
        }, {target})),
        ("release root", _release_inventory_ingress({
            "rating_axes": [{"evidence": {"event_ids": [target]}}]
        }, {target})),
    ]
    for name, evidence in source_cases:
        report = evaluate_author_only(replace(
            inputs, explicit_ingress=inputs.explicit_ingress + tuple(evidence)
        ))
        require(
            name,
            bool(evidence) and target in report.ingress_conflict_ids
            and target not in report.exempt_ids,
        )

    manifest_load_errors = _lifecycle_manifest_load_errors(
        'var ledger = load("res://content/meta/event_lifecycle.json")',
        "systems/SyntheticLifecycleLoader.gd",
    )
    report = evaluate_author_only(replace(
        inputs,
        load_errors=inputs.load_errors + tuple(manifest_load_errors),
    ))
    require(
        "product lifecycle manifest load",
        bool(manifest_load_errors)
        and any("non-runtime lifecycle ledger" in error for error in report.errors),
    )

    immediate = EventEdge(
        active, target, "follow_up_event", "synthetic.active.follow_up_event"
    )
    report = evaluate_author_only(replace(
        inputs, edges=inputs.edges + (immediate,)
    ))
    require("live follow-up", target in report.ingress_conflict_ids)

    deferred = EventEdge(
        active, target, "deferred_follow_up", "synthetic.active.deferred_follow_up"
    )
    report = evaluate_author_only(replace(
        inputs, edges=inputs.edges + (deferred,)
    ))
    require("live deferred follow-up", target in report.ingress_conflict_ids)

    transitive = (
        EventEdge(active, target, "follow_up_event", "synthetic.active.to_a"),
        EventEdge(target, second, "follow_up_event", "synthetic.a.to_b"),
    )
    report = evaluate_author_only(replace(
        inputs, edges=inputs.edges + transitive
    ))
    require(
        "transitive active ingress",
        {target, second}.issubset(report.ingress_conflict_ids),
    )

    report = evaluate_author_only(replace(
        inputs,
        edges=inputs.edges + (
            EventEdge(target, second, "follow_up_event", "synthetic.author.to_author"),
            EventEdge(target, active, "follow_up_event", "synthetic.author.to_active"),
        ),
    ))
    require(
        "author edge direction",
        target in report.exempt_ids and second in report.exempt_ids
        and not report.ingress_conflict_ids and not report.errors,
        "; ".join(report.errors[:2]),
    )

    invalid_source = _mutate_event(
        inputs, target, lambda row: row.__setitem__("weight", 1)
    )
    report = evaluate_author_only(replace(
        invalid_source,
        edges=invalid_source.edges + (
            EventEdge(target, second, "follow_up_event", "synthetic.invalid.to_valid"),
        ),
    ))
    require(
        "invalid author reaches valid author",
        target not in report.meta_valid_ids and second in report.ingress_conflict_ids,
    )

    return failures, cases


def _print_report(report: AuthorOnlyReport, marker: str) -> None:
    print(
        f"{marker} declared={len(report.declared_ids)} "
        f"meta_valid={len(report.meta_valid_ids)} exempt={len(report.exempt_ids)} "
        f"product_ingress={len(report.ingress_conflict_ids)} "
        f"packaged={len(report.packaged_event_ids)} "
        f"shipping={len(report.product_event_ids)}"
    )


def main(argv: Sequence[str] | None = None) -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--self-test", action="store_true")
    args = parser.parse_args(argv)

    if args.self_test:
        failures, cases = run_self_test(ROOT)
        if failures:
            for failure in failures:
                print(f"ERROR event lifecycle self-test: {failure}")
            print(f"EVENT_LIFECYCLE_SELF_TEST_FAIL cases={cases} failures={len(failures)}")
            return 1
        report = audit_author_only(ROOT)
        _print_report(report, f"EVENT_LIFECYCLE_SELF_TEST_OK cases={cases}")
        return 0

    report = audit_author_only(ROOT)
    if report.errors:
        for message in report.errors:
            print(f"ERROR event lifecycle: {message}")
        _print_report(report, "EVENT_LIFECYCLE_FAIL")
        return 1
    _print_report(report, "EVENT_LIFECYCLE_OK")
    return 0


if __name__ == "__main__":
    sys.exit(main())
