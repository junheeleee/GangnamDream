#!/usr/bin/env python3
"""Inventory Korean event prose for future full-body localization.

Two deliberately different source scopes are reported:

* ``lifecycle_shipping_source_corpus`` is every packaged Korean event that the
  lifecycle ledger has not proven to be dormant author-only reference prose.
* ``story_map_m07_m60_static_translation_closure`` is the union obtained by
  starting at lifecycle-shipping story-map roots in Months 7-60 and following
  authored immediate and deferred follow-up links.

Neither name claims runtime reachability.  The second scope is a static source
closure for translation planning, not evidence that MainGame displays every
event.  Native-language quality and rendered play remain separate human gates.
"""

from __future__ import annotations

import argparse
import ast
import hashlib
import json
import re
import sys
import tempfile
from dataclasses import dataclass, replace
from pathlib import Path
from typing import Any, Iterable, Mapping, Sequence


ROOT = Path(__file__).resolve().parents[1]
TOOLS = ROOT / "tools"
if str(TOOLS) not in sys.path:
    sys.path.insert(0, str(TOOLS))

from event_lifecycle import (  # noqa: E402
    collect_lifecycle_inputs,
    evaluate_author_only,
    event_id_digest,
)
from event_schedule import DeferredFollowUpError, deferred_follow_ups  # noqa: E402


SCHEMA_VERSION = 1
SCOPE_LIFECYCLE_SHIPPING = "lifecycle_shipping_source_corpus"
SCOPE_M07_M60_STATIC = "story_map_m07_m60_static_translation_closure"
SOURCE_DIR = Path("content/events")
STORY_MAP_PATH = Path("content/meta/story_map.json")
LIFECYCLE_PATH = Path("content/meta/event_lifecycle.json")
PUBLIC_DEMO_AUDIT_PATH = Path("tools/story_demo_localization_audit.py")
TARGET_LANGUAGES = ("ja", "zh-CN", "zh-TW")
PROTECTED_REUSE_EVENT_ID = "arc_jaehyuk_01_reunion"

# This one source was approved and translated in the exact public M01-M06
# story demo, then legitimately appears again in the M07-M60 static closure.
# Freeze its eight source leaves so later batches reuse the reviewed row instead
# of silently translating a changed Korean source under the old target text.
PROTECTED_REUSE_SOURCE_LEAVES_SHA256 = (
    "e2efdecc78d14630c3dd63a32da530e17a8b10af253139bee7d0d240e65710ab"
)

# Exact current-corpus observations.  These are self-test ratchets, not prose
# quotas.  If authored source evolves, the failure prints both expected and
# observed evidence and this table must be refreshed intentionally.
EXPECTED = {
    "packaged_events": 1813,
    "author_only_events": 105,
    "shipping_events": 1708,
    "shipping_standard_leaves": 11541,
    "shipping_chapter5_reader_leaves": 133,
    "shipping_leaves": 11674,
    "shipping_event_ids_sha256": (
        "0254f6d7938d7e281204b5b730d6b59e179efbe12595ef16fa72d3b378b6a6de"
    ),
    "shipping_source_leaves_sha256": (
        "fbcf80b56487555529b500f1b68b357941d5e1e164e41a5bf71590775b4ddb11"
    ),
    "m07_m60_root_refs": 162,
    "m07_m60_shipping_root_refs": 132,
    "m07_m60_shipping_seed_events": 129,
    "m07_m60_author_only_root_refs": 19,
    "m07_m60_planned_missing_root_refs": 11,
    "m07_m60_immediate_events": 168,
    "m07_m60_immediate_leaves": 1584,
    "m07_m60_events": 192,
    "m07_m60_leaves": 1749,
    "m07_m60_event_ids_sha256": (
        "7fef47a76488b7b15276c289b8a6be7ef381d982c9c6c317fd768efed20b5600"
    ),
    "m07_m60_source_leaves_sha256": (
        "682b871a66662b36f7f18e97c9c41623c558bd06d2b403b47c40e8ecadcc37a8"
    ),
    "deferred_added_events": 24,
    "deferred_added_leaves": 165,
    "public_demo_events": 14,
    "protected_overlap_events": 1,
    "protected_overlap_leaves": 8,
    "target_shipping_leaves": {"ja": 108, "zh-CN": 100, "zh-TW": 100},
    "target_m07_m60_leaves": {"ja": 8, "zh-CN": 8, "zh-TW": 8},
}

EVENT_TEXT_FIELDS = (
    "title",
    "description",
    "description_orthodox",
    "description_unorthodox",
    "description_low_mental",
    "description_long_gosiwon",
)
EVENT_DICT_FIELDS = (
    "description_if_known",
    "description_memory_if_known",
    "description_if_moral",
)
CHOICE_TEXT_FIELDS = ("text", "result_text", "bridge_summary")
CHOICE_DICT_FIELDS = ("text_if_moral",)
IMMEDIATE_EDGE_KEYS = ("follow_up", "follow_up_event", "next_event")
CHAPTER5_READER_KEY = re.compile(r"^chapter5_[a-z0-9_]+_reads$")


@dataclass(frozen=True)
class SourceEvent:
    event_id: str
    source_file: str
    row: dict[str, Any]


@dataclass(frozen=True)
class TextLeaf:
    event_id: str
    path: str
    source: str
    chapter5_reader: bool = False


@dataclass(frozen=True)
class MapRootRef:
    event_id: str
    month: int
    source: str
    work: str
    rule_status: str
    location: str


class DuplicateKeyError(ValueError):
    """Raised when raw JSON contains an object key more than once."""


def canonical_sha(value: Any) -> str:
    payload = json.dumps(
        value, ensure_ascii=False, sort_keys=True, separators=(",", ":"),
    ).encode("utf-8")
    return hashlib.sha256(payload).hexdigest()


def file_sha(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def safe_file_sha(path: Path, errors: list[str]) -> str:
    try:
        return file_sha(path)
    except OSError as exc:
        errors.append(f"{path}: cannot hash source file: {exc}")
        return ""


def leaves_sha(leaves: Iterable[TextLeaf]) -> str:
    rows = sorted(
        (leaf.event_id, leaf.path, leaf.source) for leaf in leaves
    )
    return canonical_sha(rows)


def _strict_json_text(text: str, label: str) -> Any:
    def object_hook(pairs: list[tuple[str, Any]]) -> dict[str, Any]:
        result: dict[str, Any] = {}
        for key, value in pairs:
            if key in result:
                raise DuplicateKeyError(f"{label}: duplicate object key {key!r}")
            result[key] = value
        return result

    return json.loads(text, object_pairs_hook=object_hook)


def load_json(path: Path, errors: list[str]) -> Any:
    try:
        return _strict_json_text(path.read_text(encoding="utf-8"), str(path))
    except (OSError, ValueError, json.JSONDecodeError) as exc:
        errors.append(f"{path}: cannot load strict JSON: {exc}")
        return None


def _event_rows(payload: Any, label: str, errors: list[str]) -> list[Any]:
    if isinstance(payload, list):
        return payload
    if isinstance(payload, dict) and isinstance(payload.get("events"), list):
        return payload["events"]
    if isinstance(payload, dict) and payload \
            and all(isinstance(value, dict) for value in payload.values()):
        return list(payload.values())
    errors.append(f"{label}: event JSON must be an array or contain events")
    return []


def load_source_events(root: Path, errors: list[str]) -> dict[str, SourceEvent]:
    events: dict[str, SourceEvent] = {}
    directory = root / SOURCE_DIR
    if not directory.is_dir():
        errors.append(f"missing Korean event directory: {SOURCE_DIR.as_posix()}")
        return events
    for path in sorted(directory.glob("*.json")):
        relative = path.relative_to(root).as_posix()
        payload = load_json(path, errors)
        for index, row in enumerate(_event_rows(payload, relative, errors)):
            if not isinstance(row, dict):
                errors.append(f"{relative}[{index}]: event must be an object")
                continue
            event_id = row.get("id")
            if not isinstance(event_id, str) or not event_id.strip():
                errors.append(f"{relative}[{index}]: event id must be non-empty")
                continue
            if event_id in events:
                errors.append(
                    f"duplicate event id {event_id}: "
                    f"{events[event_id].source_file}, {relative}"
                )
                continue
            events[event_id] = SourceEvent(event_id, relative, row)
    return events


def _scalar_leaf(
    event_id: str,
    owner: Mapping[str, Any],
    field: str,
    path: str,
    errors: list[str],
) -> TextLeaf | None:
    if field not in owner:
        return None
    value = owner[field]
    if not isinstance(value, str):
        errors.append(f"{event_id}.{path}: localized scalar must be a string")
        return None
    if not value.strip():
        return None
    return TextLeaf(event_id, path, value)


def _dict_leaves(
    event_id: str,
    owner: Mapping[str, Any],
    field: str,
    path: str,
    errors: list[str],
) -> list[TextLeaf]:
    if field not in owner:
        return []
    value = owner[field]
    if not isinstance(value, dict):
        errors.append(f"{event_id}.{path}: localized variants must be an object")
        return []
    leaves: list[TextLeaf] = []
    for key, text in value.items():
        leaf_path = f"{path}.{key}"
        if not isinstance(text, str):
            errors.append(f"{event_id}.{leaf_path}: localized variant must be a string")
            continue
        if text.strip():
            leaves.append(TextLeaf(event_id, leaf_path, text))
    return leaves


def _reader_text_leaves(
    event_id: str,
    value: Any,
    path: str,
    errors: list[str],
) -> list[TextLeaf]:
    if isinstance(value, str):
        if not value.strip():
            return []
        return [TextLeaf(event_id, path, value, True)]
    if isinstance(value, list):
        leaves: list[TextLeaf] = []
        for index, child in enumerate(value):
            leaves.extend(_reader_text_leaves(
                event_id, child, f"{path}[{index}]", errors,
            ))
        return leaves
    errors.append(
        f"{event_id}.{path}: Chapter 5 reader texts may contain only arrays/strings"
    )
    return []


def collect_event_leaves(
    event_id: str,
    row: Mapping[str, Any],
    errors: list[str],
) -> tuple[TextLeaf, ...]:
    leaves: list[TextLeaf] = []
    for field in EVENT_TEXT_FIELDS:
        leaf = _scalar_leaf(event_id, row, field, field, errors)
        if leaf is not None:
            leaves.append(leaf)
    for field in EVENT_DICT_FIELDS:
        leaves.extend(_dict_leaves(event_id, row, field, field, errors))

    choices = row.get("choices", [])
    if not isinstance(choices, list):
        errors.append(f"{event_id}.choices: choices must be an array")
        choices = []
    for index, choice in enumerate(choices):
        if not isinstance(choice, dict):
            errors.append(f"{event_id}.choices[{index}]: choice must be an object")
            continue
        prefix = f"choices[{index}]"
        for field in CHOICE_TEXT_FIELDS:
            leaf = _scalar_leaf(
                event_id, choice, field, f"{prefix}.{field}", errors,
            )
            if leaf is not None:
                leaves.append(leaf)
        for field in CHOICE_DICT_FIELDS:
            leaves.extend(_dict_leaves(
                event_id, choice, field, f"{prefix}.{field}", errors,
            ))

    for key, owner in row.items():
        if CHAPTER5_READER_KEY.fullmatch(str(key)) is None:
            continue
        if not isinstance(owner, dict):
            errors.append(f"{event_id}.{key}: Chapter 5 reader must be an object")
            continue
        if "texts" not in owner:
            errors.append(f"{event_id}.{key}: Chapter 5 reader lacks texts")
            continue
        leaves.extend(_reader_text_leaves(
            event_id, owner["texts"], f"{key}.texts", errors,
        ))

    paths = [leaf.path for leaf in leaves]
    duplicate_paths = sorted({path for path in paths if paths.count(path) > 1})
    if duplicate_paths:
        errors.append(f"{event_id}: duplicate localized leaf paths {duplicate_paths}")
    return tuple(sorted(leaves, key=lambda leaf: leaf.path))


def collect_leaf_index(
    events: Mapping[str, SourceEvent], errors: list[str],
) -> dict[str, tuple[TextLeaf, ...]]:
    return {
        event_id: collect_event_leaves(event_id, record.row, errors)
        for event_id, record in sorted(events.items())
    }


def collect_map_root_refs(story_map: Any, errors: list[str]) -> list[MapRootRef]:
    refs: list[MapRootRef] = []
    if not isinstance(story_map, dict):
        errors.append("story_map root must be an object")
        return refs
    chapters = story_map.get("chapters")
    if not isinstance(chapters, list):
        errors.append("story_map.chapters must be an array")
        return refs

    chapter_ids: list[int] = []
    seen_months: list[int] = []
    for chapter_index, chapter in enumerate(chapters):
        location = f"story_map.chapters[{chapter_index}]"
        if not isinstance(chapter, dict):
            errors.append(f"{location}: chapter must be an object")
            continue
        chapter_id = chapter.get("chapter")
        if not isinstance(chapter_id, int) or isinstance(chapter_id, bool):
            errors.append(f"{location}.chapter: must be an integer")
            continue
        chapter_ids.append(chapter_id)
        months = chapter.get("months")
        if not isinstance(months, list):
            errors.append(f"{location}.months: must be an array")
            continue
        for month_index, month_row in enumerate(months):
            month_location = f"{location}.months[{month_index}]"
            if not isinstance(month_row, dict):
                errors.append(f"{month_location}: month must be an object")
                continue
            month = month_row.get("month")
            if not isinstance(month, int) or isinstance(month, bool) \
                    or not 1 <= month <= 60:
                errors.append(f"{month_location}.month: must be integer 1..60")
                continue
            seen_months.append(month)
            expected_chapter = (month - 1) // 12 + 1
            if chapter_id != expected_chapter:
                errors.append(
                    f"{month_location}: M{month:02d} belongs to chapter "
                    f"{expected_chapter}, not {chapter_id}"
                )
            beats = month_row.get("beats")
            if not isinstance(beats, list):
                errors.append(f"{month_location}.beats: must be an array")
                continue
            for beat_index, beat in enumerate(beats):
                beat_location = f"{month_location}.beats[{beat_index}]"
                if not isinstance(beat, dict):
                    errors.append(f"{beat_location}: beat must be an object")
                    continue
                root_id = beat.get("root")
                work = beat.get("work", "")
                rule_status = beat.get("rule_status", "")
                if not isinstance(root_id, str) or not root_id.strip():
                    errors.append(f"{beat_location}.root: must be a non-empty string")
                else:
                    refs.append(MapRootRef(
                        root_id.strip(), month, "base", str(work),
                        str(rule_status), f"{beat_location}.root",
                    ))
                coverage = beat.get("coverage", {})
                if not isinstance(coverage, dict):
                    errors.append(f"{beat_location}.coverage: must be an object")
                    continue
                fallbacks = coverage.get("fallbacks", [])
                if not isinstance(fallbacks, list):
                    errors.append(f"{beat_location}.coverage.fallbacks: must be an array")
                    continue
                for fallback_index, fallback in enumerate(fallbacks):
                    fallback_location = (
                        f"{beat_location}.coverage.fallbacks[{fallback_index}]"
                    )
                    if not isinstance(fallback, dict):
                        errors.append(f"{fallback_location}: must be an object")
                        continue
                    fallback_root = fallback.get("root")
                    if not isinstance(fallback_root, str) or not fallback_root.strip():
                        errors.append(f"{fallback_location}.root: must be non-empty")
                        continue
                    refs.append(MapRootRef(
                        fallback_root.strip(), month, "fallback",
                        str(fallback.get("work", "")),
                        str(fallback.get("rule_status", "")),
                        f"{fallback_location}.root",
                    ))

    if sorted(chapter_ids) != list(range(1, 6)) \
            or len(chapter_ids) != len(set(chapter_ids)):
        errors.append(
            f"story_map chapter inventory must be exact 1..5, got {chapter_ids}"
        )
    if sorted(seen_months) != list(range(1, 61)) \
            or len(seen_months) != len(set(seen_months)):
        errors.append(
            "story_map month inventory must contain each M01..M60 exactly once"
        )
    return refs


def classify_m07_m60_refs(
    refs: Iterable[MapRootRef],
    packaged_ids: set[str],
    product_ids: set[str],
    author_only_ids: set[str],
    errors: list[str],
) -> dict[str, Any]:
    selected = [ref for ref in refs if 7 <= ref.month <= 60]
    shipping: list[MapRootRef] = []
    author_only: list[MapRootRef] = []
    planned_missing: list[MapRootRef] = []
    for ref in selected:
        if ref.event_id in product_ids:
            shipping.append(ref)
            continue
        if ref.event_id in author_only_ids:
            author_only.append(ref)
            if ref.work != "EXPAND" or ref.rule_status != "needs_rule":
                errors.append(
                    f"{ref.location}: author-only map reference must remain "
                    "EXPAND/needs_rule"
                )
            continue
        if ref.event_id not in packaged_ids:
            planned_missing.append(ref)
            if not (
                ref.source == "fallback"
                and ref.work == "NEW"
                and ref.rule_status == "planned"
            ):
                errors.append(
                    f"{ref.location}: missing map root is not exact "
                    "NEW/planned fallback"
                )
            continue
        errors.append(
            f"{ref.location}: packaged map root is outside validated lifecycle "
            f"classes: {ref.event_id}"
        )
    return {
        "all": selected,
        "shipping": shipping,
        "author_only": author_only,
        "planned_missing": planned_missing,
        "shipping_seed_ids": {ref.event_id for ref in shipping},
    }


def owner_targets(
    owner: Mapping[str, Any],
    location: str,
    include_deferred: bool,
    errors: list[str],
) -> list[str]:
    targets: list[str] = []
    for key in IMMEDIATE_EDGE_KEYS:
        target = owner.get(key)
        if isinstance(target, str) and target.strip():
            targets.append(target.strip())
        elif key in owner and target not in (None, ""):
            errors.append(f"{location}.{key}: target must be a string")
    if include_deferred:
        try:
            targets.extend(target for target, _delay in deferred_follow_ups(dict(owner)))
        except DeferredFollowUpError as exc:
            errors.append(f"{location}.deferred_follow_up: {exc}")
    return list(dict.fromkeys(targets))


def event_targets(
    record: SourceEvent,
    include_deferred: bool,
    errors: list[str],
) -> list[str]:
    targets = owner_targets(
        record.row,
        f"{record.source_file}[{record.event_id}]", include_deferred, errors,
    )
    choices = record.row.get("choices", [])
    if not isinstance(choices, list):
        return targets
    for index, choice in enumerate(choices):
        if not isinstance(choice, dict):
            continue
        targets.extend(owner_targets(
            choice,
            f"{record.source_file}[{record.event_id}].choices[{index}]",
            include_deferred, errors,
        ))
    return list(dict.fromkeys(targets))


def static_translation_closure(
    seed_ids: Iterable[str],
    events: Mapping[str, SourceEvent],
    product_ids: set[str],
    author_only_ids: set[str],
    include_deferred: bool,
    errors: list[str],
) -> set[str]:
    closure: set[str] = set()
    pending = list(sorted(set(seed_ids), reverse=True))
    while pending:
        event_id = pending.pop()
        if event_id in closure:
            continue
        record = events.get(event_id)
        if record is None:
            errors.append(f"static translation closure target is missing: {event_id}")
            continue
        if event_id in author_only_ids:
            errors.append(
                f"static translation closure entered author-only source: {event_id}"
            )
            continue
        if event_id not in product_ids:
            errors.append(
                f"static translation closure target lacks lifecycle shipping class: "
                f"{event_id}"
            )
            continue
        closure.add(event_id)
        for target in event_targets(record, include_deferred, errors):
            if target in author_only_ids:
                errors.append(
                    f"{event_id}: follow-up enters author-only source {target}"
                )
                continue
            if target not in events:
                errors.append(f"{event_id}: follow-up target is missing: {target}")
                continue
            if target not in product_ids:
                errors.append(
                    f"{event_id}: follow-up target lacks lifecycle shipping class: {target}"
                )
                continue
            if target not in closure:
                pending.append(target)
    return closure


def load_public_demo_event_ids(root: Path, errors: list[str]) -> tuple[str, ...]:
    path = root / PUBLIC_DEMO_AUDIT_PATH
    try:
        module = ast.parse(path.read_text(encoding="utf-8"), filename=str(path))
    except (OSError, SyntaxError) as exc:
        errors.append(f"{path}: cannot read public demo EVENT_IDS: {exc}")
        return ()
    value: Any = None
    for node in module.body:
        if not isinstance(node, ast.Assign):
            continue
        if any(isinstance(target, ast.Name) and target.id == "EVENT_IDS"
               for target in node.targets):
            try:
                value = ast.literal_eval(node.value)
            except (ValueError, TypeError, SyntaxError) as exc:
                errors.append(f"{path}: EVENT_IDS is not a literal tuple: {exc}")
            break
    if not isinstance(value, (tuple, list)) \
            or any(not isinstance(item, str) or not item for item in value):
        errors.append(f"{path}: EVENT_IDS must be a literal string sequence")
        return ()
    if len(value) != len(set(value)):
        errors.append(f"{path}: EVENT_IDS contains duplicates")
    return tuple(value)


def load_target_events(
    root: Path, language: str, errors: list[str],
) -> dict[str, SourceEvent]:
    directory = root / f"content/events_{language}"
    events: dict[str, SourceEvent] = {}
    if not directory.is_dir():
        errors.append(f"missing target event directory: content/events_{language}")
        return events
    for path in sorted(directory.glob("*.json")):
        relative = path.relative_to(root).as_posix()
        payload = load_json(path, errors)
        for index, row in enumerate(_event_rows(payload, relative, errors)):
            if not isinstance(row, dict):
                errors.append(f"{relative}[{index}]: target event must be an object")
                continue
            event_id = row.get("id")
            if not isinstance(event_id, str) or not event_id:
                errors.append(f"{relative}[{index}]: target event id must be non-empty")
                continue
            if event_id in events:
                errors.append(
                    f"{language}: duplicate target event id {event_id}: "
                    f"{events[event_id].source_file}, {relative}"
                )
                continue
            events[event_id] = SourceEvent(event_id, relative, row)
    return events


def target_leaf_index(
    language: str,
    target_events: Mapping[str, SourceEvent],
    source_leaves: Mapping[str, tuple[TextLeaf, ...]],
    errors: list[str],
) -> dict[str, tuple[TextLeaf, ...]]:
    result: dict[str, tuple[TextLeaf, ...]] = {}
    for event_id, record in sorted(target_events.items()):
        if event_id not in source_leaves:
            errors.append(f"{language}: target row has no Korean source: {event_id}")
            continue
        leaves = collect_event_leaves(event_id, record.row, errors)
        source_paths = {leaf.path for leaf in source_leaves[event_id]}
        extra = sorted({leaf.path for leaf in leaves} - source_paths)
        if extra:
            errors.append(
                f"{language}:{event_id}: target-only localized leaf paths {extra}"
            )
        result[event_id] = tuple(
            leaf for leaf in leaves if leaf.path in source_paths
        )
    return result


def _scope_target_count(
    scope_ids: set[str], target_leaves: Mapping[str, tuple[TextLeaf, ...]],
) -> int:
    return sum(len(target_leaves.get(event_id, ())) for event_id in scope_ids)


def protected_reuse_errors(
    static_ids: set[str],
    public_demo_ids: set[str],
    source_leaves: Mapping[str, tuple[TextLeaf, ...]],
    target_leaves: Mapping[str, Mapping[str, tuple[TextLeaf, ...]]],
) -> list[str]:
    errors: list[str] = []
    overlap = static_ids & public_demo_ids
    expected_overlap = {PROTECTED_REUSE_EVENT_ID}
    if overlap != expected_overlap:
        errors.append(
            "public-demo/M07-M60 static overlap drifted: "
            f"expected={sorted(expected_overlap)} actual={sorted(overlap)}"
        )
    protected = source_leaves.get(PROTECTED_REUSE_EVENT_ID, ())
    if len(protected) != EXPECTED["protected_overlap_leaves"]:
        errors.append(
            f"{PROTECTED_REUSE_EVENT_ID}: protected source leaf count drifted: "
            f"{len(protected)}"
        )
    actual_hash = leaves_sha(protected)
    if actual_hash != PROTECTED_REUSE_SOURCE_LEAVES_SHA256:
        errors.append(
            f"{PROTECTED_REUSE_EVENT_ID}: frozen source leaves drifted: "
            f"expected={PROTECTED_REUSE_SOURCE_LEAVES_SHA256} actual={actual_hash}"
        )
    source_paths = {leaf.path for leaf in protected}
    for language in TARGET_LANGUAGES:
        target = target_leaves.get(language, {}).get(PROTECTED_REUSE_EVENT_ID, ())
        target_paths = {leaf.path for leaf in target}
        if target_paths != source_paths:
            errors.append(
                f"{language}:{PROTECTED_REUSE_EVENT_ID}: protected target shape drifted: "
                f"missing={sorted(source_paths-target_paths)} "
                f"extra={sorted(target_paths-source_paths)}"
            )
    return errors


def _event_inventory(
    event_id: str,
    events: Mapping[str, SourceEvent],
    leaf_index: Mapping[str, tuple[TextLeaf, ...]],
) -> dict[str, Any]:
    leaves = leaf_index[event_id]
    return {
        "id": event_id,
        "source_file": events[event_id].source_file,
        "leaf_count": len(leaves),
        "standard_leaf_count": sum(not leaf.chapter5_reader for leaf in leaves),
        "chapter5_reader_leaf_count": sum(leaf.chapter5_reader for leaf in leaves),
        "source_leaves_sha256": leaves_sha(leaves),
        "leaves": [
            {
                "path": leaf.path,
                "source": leaf.source,
                "source_text_sha256": hashlib.sha256(
                    leaf.source.encode("utf-8")
                ).hexdigest(),
                "chapter5_reader": leaf.chapter5_reader,
            }
            for leaf in leaves
        ],
    }


def _source_file_digest(root: Path, errors: list[str]) -> str:
    rows = {}
    for path in sorted((root / SOURCE_DIR).glob("*.json")):
        digest = safe_file_sha(path, errors)
        if digest:
            rows[path.relative_to(root).as_posix()] = digest
    return canonical_sha(rows)


def build_scope(root: Path | str = ROOT) -> tuple[dict[str, Any], list[str]]:
    repo = Path(root).resolve()
    errors: list[str] = []

    lifecycle_inputs = collect_lifecycle_inputs(repo)
    lifecycle = evaluate_author_only(lifecycle_inputs)
    errors.extend(f"event lifecycle: {message}" for message in lifecycle.errors)

    events = load_source_events(repo, errors)
    if set(events) != set(lifecycle.packaged_event_ids):
        errors.append(
            "strict Korean event inventory differs from lifecycle packaged IDs: "
            f"missing={sorted(set(lifecycle.packaged_event_ids)-set(events))[:20]} "
            f"extra={sorted(set(events)-set(lifecycle.packaged_event_ids))[:20]}"
        )
    leaf_index = collect_leaf_index(events, errors)

    story_map = load_json(repo / STORY_MAP_PATH, errors)
    refs = collect_map_root_refs(story_map, errors)
    classified = classify_m07_m60_refs(
        refs,
        set(lifecycle.packaged_event_ids),
        set(lifecycle.product_event_ids),
        set(lifecycle.exempt_ids),
        errors,
    )
    seed_ids = set(classified["shipping_seed_ids"])
    immediate_ids = static_translation_closure(
        seed_ids, events, set(lifecycle.product_event_ids),
        set(lifecycle.exempt_ids), False, errors,
    )
    static_ids = static_translation_closure(
        seed_ids, events, set(lifecycle.product_event_ids),
        set(lifecycle.exempt_ids), True, errors,
    )

    public_demo_ids = set(load_public_demo_event_ids(repo, errors))
    missing_demo_source = public_demo_ids - set(events)
    if missing_demo_source:
        errors.append(
            f"public demo EVENT_IDS missing Korean source: {sorted(missing_demo_source)}"
        )

    target_events: dict[str, dict[str, SourceEvent]] = {}
    target_leaves: dict[str, dict[str, tuple[TextLeaf, ...]]] = {}
    for language in TARGET_LANGUAGES:
        target_events[language] = load_target_events(repo, language, errors)
        target_leaves[language] = target_leaf_index(
            language, target_events[language], leaf_index, errors,
        )
    errors.extend(protected_reuse_errors(
        static_ids, public_demo_ids, leaf_index, target_leaves,
    ))

    shipping_ids = set(lifecycle.product_event_ids)
    shipping_leaves = [
        leaf for event_id in shipping_ids for leaf in leaf_index.get(event_id, ())
    ]
    immediate_leaves = [
        leaf for event_id in immediate_ids for leaf in leaf_index.get(event_id, ())
    ]
    static_leaves = [
        leaf for event_id in static_ids for leaf in leaf_index.get(event_id, ())
    ]
    deferred_added_ids = static_ids - immediate_ids
    deferred_added_leaves = [
        leaf for event_id in deferred_added_ids for leaf in leaf_index.get(event_id, ())
    ]

    author_overlap = shipping_ids & set(lifecycle.exempt_ids)
    static_author_overlap = static_ids & set(lifecycle.exempt_ids)
    if author_overlap:
        errors.append(
            f"lifecycle shipping source includes author-only IDs: {sorted(author_overlap)}"
        )
    if static_author_overlap:
        errors.append(
            f"M07-M60 static translation closure includes author-only IDs: "
            f"{sorted(static_author_overlap)}"
        )

    target_report: dict[str, Any] = {}
    for language in TARGET_LANGUAGES:
        target_report[language] = {
            "authored_target_event_rows": len(target_events[language]),
            "lifecycle_shipping_structurally_present_target_leaves": (
                _scope_target_count(shipping_ids, target_leaves[language])
            ),
            "m07_m60_static_structurally_present_target_leaves": (
                _scope_target_count(static_ids, target_leaves[language])
            ),
            "protected_reuse_target_leaves": len(
                target_leaves[language].get(PROTECTED_REUSE_EVENT_ID, ())
            ),
            "quality_or_native_review_claim": False,
        }

    report = {
        "schema_version": SCHEMA_VERSION,
        "status": "SOURCE_INVENTORY_ONLY",
        "scope_ids": {
            "lifecycle_shipping": SCOPE_LIFECYCLE_SHIPPING,
            "m07_m60": SCOPE_M07_M60_STATIC,
        },
        "scope_boundary": {
            "does_not_prove_product_runtime_exposure": True,
            "does_not_prove_translation_quality": True,
            "does_not_close_native_or_rendered_human_gates": True,
            "public_demo_remains_exact_m01_m06": True,
        },
        "hash_semantics": {
            "event_ids": (
                "sha256(UTF-8 sorted unique IDs joined by LF with one trailing LF)"
            ),
            "source_leaves": (
                "sha256(canonical UTF-8 JSON of sorted [event_id,path,Korean text])"
            ),
            "per_event_source_leaves": (
                "sha256(canonical UTF-8 JSON of sorted [event_id,path,Korean text])"
            ),
        },
        SCOPE_LIFECYCLE_SHIPPING: {
            "packaged_event_count": len(lifecycle.packaged_event_ids),
            "event_count": len(shipping_ids),
            "leaf_count": len(shipping_leaves),
            "standard_leaf_count": sum(
                not leaf.chapter5_reader for leaf in shipping_leaves
            ),
            "chapter5_reader_leaf_count": sum(
                leaf.chapter5_reader for leaf in shipping_leaves
            ),
            "event_ids_sha256": event_id_digest(shipping_ids),
            "source_leaves_sha256": leaves_sha(shipping_leaves),
            "author_only_excluded_event_count": len(lifecycle.exempt_ids),
            "author_only_overlap_event_count": len(author_overlap),
            "events": [
                _event_inventory(event_id, events, leaf_index)
                for event_id in sorted(shipping_ids & set(events) & set(leaf_index))
            ],
        },
        SCOPE_M07_M60_STATIC: {
            "map_root_ref_count": len(classified["all"]),
            "lifecycle_shipping_root_ref_count": len(classified["shipping"]),
            "lifecycle_shipping_seed_event_count": len(seed_ids),
            "author_only_root_ref_count": len(classified["author_only"]),
            "planned_missing_root_ref_count": len(classified["planned_missing"]),
            "immediate_closure_event_count": len(immediate_ids),
            "immediate_closure_leaf_count": len(immediate_leaves),
            "event_count": len(static_ids),
            "leaf_count": len(static_leaves),
            "event_ids_sha256": event_id_digest(static_ids),
            "source_leaves_sha256": leaves_sha(static_leaves),
            "deferred_added_event_count": len(deferred_added_ids),
            "deferred_added_leaf_count": len(deferred_added_leaves),
            "author_only_overlap_event_count": len(static_author_overlap),
            "event_ids": sorted(static_ids),
            "deferred_added_event_ids": sorted(deferred_added_ids),
            "excluded_author_only_event_ids": sorted({
                ref.event_id for ref in classified["author_only"]
            }),
            "excluded_planned_missing_event_ids": sorted({
                ref.event_id for ref in classified["planned_missing"]
            }),
        },
        "protected_demo_reuse": {
            "event_id": PROTECTED_REUSE_EVENT_ID,
            "public_demo_event_count": len(public_demo_ids),
            "public_demo_static_overlap_event_ids": sorted(
                public_demo_ids & static_ids
            ),
            "source_leaf_count": len(
                leaf_index.get(PROTECTED_REUSE_EVENT_ID, ())
            ),
            "source_leaves_sha256": leaves_sha(
                leaf_index.get(PROTECTED_REUSE_EVENT_ID, ())
            ),
            "frozen_source_leaves_sha256": (
                PROTECTED_REUSE_SOURCE_LEAVES_SHA256
            ),
            "target_locales": {
                language: {
                    "leaf_count": len(
                        target_leaves[language].get(
                            PROTECTED_REUSE_EVENT_ID, (),
                        )
                    ),
                    "source_shape_exact": (
                        {leaf.path for leaf in target_leaves[language].get(
                            PROTECTED_REUSE_EVENT_ID, (),
                        )}
                        == {leaf.path for leaf in leaf_index.get(
                            PROTECTED_REUSE_EVENT_ID, (),
                        )}
                    ),
                }
                for language in TARGET_LANGUAGES
            },
        },
        "target_structure_inventory": target_report,
        "source_files": {
            "korean_event_files_sha256": _source_file_digest(repo, errors),
            "story_map_sha256": safe_file_sha(repo / STORY_MAP_PATH, errors),
            "event_lifecycle_sha256": safe_file_sha(
                repo / LIFECYCLE_PATH, errors,
            ),
        },
    }
    return report, list(dict.fromkeys(errors))


def _expected_observation_errors(report: Mapping[str, Any]) -> list[str]:
    errors: list[str] = []
    shipping = report.get(SCOPE_LIFECYCLE_SHIPPING, {})
    static = report.get(SCOPE_M07_M60_STATIC, {})
    protected = report.get("protected_demo_reuse", {})
    targets = report.get("target_structure_inventory", {})

    observed = {
        "packaged_events": shipping.get("packaged_event_count"),
        "author_only_events": shipping.get("author_only_excluded_event_count"),
        "shipping_events": shipping.get("event_count"),
        "shipping_standard_leaves": shipping.get("standard_leaf_count"),
        "shipping_chapter5_reader_leaves": shipping.get(
            "chapter5_reader_leaf_count"
        ),
        "shipping_leaves": shipping.get("leaf_count"),
        "shipping_event_ids_sha256": shipping.get("event_ids_sha256"),
        "shipping_source_leaves_sha256": shipping.get("source_leaves_sha256"),
        "m07_m60_root_refs": static.get("map_root_ref_count"),
        "m07_m60_shipping_root_refs": static.get(
            "lifecycle_shipping_root_ref_count"
        ),
        "m07_m60_shipping_seed_events": static.get(
            "lifecycle_shipping_seed_event_count"
        ),
        "m07_m60_author_only_root_refs": static.get(
            "author_only_root_ref_count"
        ),
        "m07_m60_planned_missing_root_refs": static.get(
            "planned_missing_root_ref_count"
        ),
        "m07_m60_immediate_events": static.get("immediate_closure_event_count"),
        "m07_m60_immediate_leaves": static.get("immediate_closure_leaf_count"),
        "m07_m60_events": static.get("event_count"),
        "m07_m60_leaves": static.get("leaf_count"),
        "m07_m60_event_ids_sha256": static.get("event_ids_sha256"),
        "m07_m60_source_leaves_sha256": static.get("source_leaves_sha256"),
        "deferred_added_events": static.get("deferred_added_event_count"),
        "deferred_added_leaves": static.get("deferred_added_leaf_count"),
        "protected_overlap_events": len(
            protected.get("public_demo_static_overlap_event_ids", [])
        ),
        "protected_overlap_leaves": protected.get("source_leaf_count"),
        "public_demo_events": protected.get("public_demo_event_count"),
    }
    for key, actual in observed.items():
        expected = EXPECTED[key]
        if actual != expected:
            errors.append(
                f"current source observation {key} drifted: "
                f"expected={expected} actual={actual}"
            )
    for language in TARGET_LANGUAGES:
        row = targets.get(language, {}) if isinstance(targets, dict) else {}
        shipping_target = row.get(
            "lifecycle_shipping_structurally_present_target_leaves"
        )
        static_target = row.get(
            "m07_m60_static_structurally_present_target_leaves"
        )
        if shipping_target != EXPECTED["target_shipping_leaves"][language]:
            errors.append(
                f"{language} shipping target leaf observation drifted: "
                f"expected={EXPECTED['target_shipping_leaves'][language]} "
                f"actual={shipping_target}"
            )
        if static_target != EXPECTED["target_m07_m60_leaves"][language]:
            errors.append(
                f"{language} M07-M60 target leaf observation drifted: "
                f"expected={EXPECTED['target_m07_m60_leaves'][language]} "
                f"actual={static_target}"
            )
    return errors


def run_self_test(root: Path | str = ROOT) -> tuple[list[str], int]:
    failures: list[str] = []
    cases = 0

    def require(name: str, condition: bool, detail: str = "") -> None:
        nonlocal cases
        cases += 1
        if not condition:
            failures.append(f"{name}: {detail or 'assertion failed'}")

    report, errors = build_scope(root)
    require("current source is structurally clean", not errors, "; ".join(errors[:3]))
    observation_errors = _expected_observation_errors(report)
    require(
        "current exact observations",
        not observation_errors,
        "; ".join(observation_errors[:3]),
    )

    shipping = report.get(SCOPE_LIFECYCLE_SHIPPING, {})
    static = report.get(SCOPE_M07_M60_STATIC, {})
    require(
        "shipping exact event and leaf denominator",
        (shipping.get("event_count"), shipping.get("leaf_count"))
        == (1708, 11674),
    )
    require(
        "Chapter 5 nested reader leaves included",
        shipping.get("chapter5_reader_leaf_count") == 133
        and shipping.get("standard_leaf_count") == 11541,
    )
    require(
        "M07-M60 static exact event and leaf denominator",
        (static.get("event_count"), static.get("leaf_count")) == (192, 1749),
    )
    require(
        "deferred follow-up expands static closure",
        static.get("immediate_closure_event_count") == 168
        and static.get("deferred_added_event_count") == 24
        and static.get("deferred_added_leaf_count") == 165,
    )
    require(
        "author-only excluded from both source scopes",
        shipping.get("author_only_excluded_event_count") == 105
        and shipping.get("author_only_overlap_event_count") == 0
        and static.get("author_only_overlap_event_count") == 0,
    )

    protected = report.get("protected_demo_reuse", {})
    require(
        "protected overlap is exact Jaehyuk reuse",
        protected.get("public_demo_static_overlap_event_ids")
        == [PROTECTED_REUSE_EVENT_ID]
        and protected.get("source_leaf_count") == 8
        and protected.get("source_leaves_sha256")
        == PROTECTED_REUSE_SOURCE_LEAVES_SHA256,
    )
    require(
        "protected target shape exists in all three locales",
        all(
            protected.get("target_locales", {}).get(language, {}).get(
                "source_shape_exact"
            ) is True
            for language in TARGET_LANGUAGES
        ),
    )

    scope_ids = report.get("scope_ids", {})
    forbidden_claim = re.compile(r"(?:runtime|reachable|playable)", re.IGNORECASE)
    require(
        "scope names do not claim runtime reachability",
        all(
            isinstance(value, str) and forbidden_claim.search(value) is None
            for value in scope_ids.values()
        ),
    )
    require(
        "report explicitly denies runtime proof",
        report.get("scope_boundary", {}).get(
            "does_not_prove_product_runtime_exposure"
        ) is True,
    )

    with tempfile.TemporaryDirectory(prefix="gangnam-full-body-scope-selftest-") as tmp:
        _missing_report, missing_repo_errors = build_scope(Path(tmp))
    require(
        "missing lifecycle and story map fail closed without a crash",
        bool(missing_repo_errors)
        and any("event lifecycle" in error for error in missing_repo_errors)
        and any("story_map" in error for error in missing_repo_errors),
        "; ".join(missing_repo_errors[:3]),
    )

    malformed_map_errors: list[str] = []
    collect_map_root_refs({"chapters": {}}, malformed_map_errors)
    require(
        "malformed map fails closed",
        any("chapters must be an array" in error for error in malformed_map_errors),
    )

    classification_errors: list[str] = []
    fixture_refs = [
        MapRootRef("planned", 7, "fallback", "NEW", "planned", "fixture.valid"),
        MapRootRef("missing", 8, "base", "EXPAND", "mapped", "fixture.invalid"),
        MapRootRef("author", 9, "base", "KEEP", "mapped", "fixture.author"),
    ]
    classified = classify_m07_m60_refs(
        fixture_refs, {"author"}, set(), {"author"}, classification_errors,
    )
    require(
        "planned missing and author-only map classes fail closed",
        len(classified["planned_missing"]) == 2
        and any("NEW/planned fallback" in error for error in classification_errors)
        and any("EXPAND/needs_rule" in error for error in classification_errors),
    )

    fixture_events = {
        "a": SourceEvent("a", "fixture.json", {
            "id": "a", "title": "A", "deferred_follow_up": "b",
        }),
        "b": SourceEvent("b", "fixture.json", {
            "id": "b", "title": "B", "follow_up_event": "c",
        }),
        "c": SourceEvent("c", "fixture.json", {"id": "c", "title": "C"}),
    }
    fixture_errors: list[str] = []
    immediate_fixture = static_translation_closure(
        {"a"}, fixture_events, set(fixture_events), set(), False, fixture_errors,
    )
    deferred_fixture = static_translation_closure(
        {"a"}, fixture_events, set(fixture_events), set(), True, fixture_errors,
    )
    require(
        "deferred parser participates in transitive closure",
        immediate_fixture == {"a"} and deferred_fixture == {"a", "b", "c"}
        and not fixture_errors,
    )

    invalid_deferred_events = dict(fixture_events)
    invalid_deferred_events["a"] = SourceEvent("a", "fixture.json", {
        "id": "a", "deferred_follow_up": {"id": "b"},
    })
    invalid_deferred_errors: list[str] = []
    static_translation_closure(
        {"a"}, invalid_deferred_events, set(invalid_deferred_events), set(),
        True, invalid_deferred_errors,
    )
    require(
        "malformed deferred follow-up fails closed",
        any("deferred_follow_up" in error for error in invalid_deferred_errors),
    )

    author_intrusion_events = dict(fixture_events)
    author_intrusion_events["a"] = SourceEvent("a", "fixture.json", {
        "id": "a", "follow_up_event": "author",
    })
    author_intrusion_events["author"] = SourceEvent(
        "author", "fixture.json", {"id": "author", "title": "Reference"},
    )
    author_intrusion_errors: list[str] = []
    author_intrusion = static_translation_closure(
        {"a"}, author_intrusion_events, {"a"}, {"author"}, True,
        author_intrusion_errors,
    )
    require(
        "closure refuses author-only ingress",
        author_intrusion == {"a"}
        and any("author-only" in error for error in author_intrusion_errors),
    )

    nested_errors: list[str] = []
    nested = collect_event_leaves("nested", {
        "id": "nested",
        "title": "제목",
        "chapter5_finale_reads": {
            "sources": [{"kind": "flag", "id": "not_text"}],
            "texts": [["첫 회수", "둘째 회수"], ["셋째 회수"]],
            "mode": "inline_slots",
        },
    }, nested_errors)
    require(
        "reader collector counts only nested authored texts",
        len(nested) == 4
        and sum(leaf.chapter5_reader for leaf in nested) == 3
        and all("not_text" not in leaf.source for leaf in nested)
        and not nested_errors,
    )

    malformed_reader_errors: list[str] = []
    collect_event_leaves("malformed", {
        "id": "malformed",
        "chapter5_causal_reads": {"texts": [["ok", 7]]},
    }, malformed_reader_errors)
    require(
        "malformed nested reader leaf fails closed",
        any("arrays/strings" in error for error in malformed_reader_errors),
    )

    protected_inventory = next(
        (
            row for row in shipping.get("events", [])
            if row.get("id") == PROTECTED_REUSE_EVENT_ID
        ),
        None,
    )
    mutated_source: dict[str, tuple[TextLeaf, ...]] = {}
    if isinstance(protected_inventory, dict):
        original = tuple(
            TextLeaf(PROTECTED_REUSE_EVENT_ID, row["path"], row["source"])
            for row in protected_inventory.get("leaves", [])
        )
        if original:
            mutated_source[PROTECTED_REUSE_EVENT_ID] = (
                replace(original[0], source=original[0].source + " 변경"),
                *original[1:],
            )
    mutation_errors = protected_reuse_errors(
        {PROTECTED_REUSE_EVENT_ID}, {PROTECTED_REUSE_EVENT_ID},
        mutated_source,
        {
            language: {
                PROTECTED_REUSE_EVENT_ID: mutated_source.get(
                    PROTECTED_REUSE_EVENT_ID, (),
                )
            }
            for language in TARGET_LANGUAGES
        },
    )
    require(
        "frozen reuse rejects changed Korean source",
        any("frozen source leaves drifted" in error for error in mutation_errors),
    )

    missing_target = {
        language: {
            PROTECTED_REUSE_EVENT_ID: tuple(
                list(mutated_source.get(PROTECTED_REUSE_EVENT_ID, ()))[:-1]
            )
        }
        for language in TARGET_LANGUAGES
    }
    missing_target_errors = protected_reuse_errors(
        {PROTECTED_REUSE_EVENT_ID}, {PROTECTED_REUSE_EVENT_ID},
        {
            PROTECTED_REUSE_EVENT_ID: tuple(
                TextLeaf(PROTECTED_REUSE_EVENT_ID, row["path"], row["source"])
                for row in (protected_inventory or {}).get("leaves", [])
            )
        },
        missing_target,
    )
    require(
        "protected reuse rejects missing target path",
        any("protected target shape drifted" in error
            for error in missing_target_errors),
    )

    hash_fixture = tuple([
        TextLeaf("b", "title", "둘"),
        TextLeaf("a", "title", "하나"),
    ])
    require(
        "source leaf hash is order-independent",
        leaves_sha(hash_fixture) == leaves_sha(reversed(hash_fixture)),
    )

    duplicate_errors: list[str] = []
    try:
        _strict_json_text('{"a":1,"a":2}', "fixture.json")
    except DuplicateKeyError as exc:
        duplicate_errors.append(str(exc))
    require(
        "raw duplicate JSON keys fail closed",
        any("duplicate object key" in error for error in duplicate_errors),
    )

    require(
        "source observations expose exact hashes",
        shipping.get("event_ids_sha256") == EXPECTED["shipping_event_ids_sha256"]
        and shipping.get("source_leaves_sha256")
        == EXPECTED["shipping_source_leaves_sha256"]
        and static.get("event_ids_sha256")
        == EXPECTED["m07_m60_event_ids_sha256"]
        and static.get("source_leaves_sha256")
        == EXPECTED["m07_m60_source_leaves_sha256"],
    )

    return failures, cases


def _summary(report: Mapping[str, Any], marker: str) -> str:
    shipping = report.get(SCOPE_LIFECYCLE_SHIPPING, {})
    static = report.get(SCOPE_M07_M60_STATIC, {})
    protected = report.get("protected_demo_reuse", {})
    return (
        f"{marker} status=SOURCE_INVENTORY_ONLY "
        f"shipping_events={shipping.get('event_count', 0)} "
        f"shipping_leaves={shipping.get('leaf_count', 0)} "
        f"chapter5_reader_leaves={shipping.get('chapter5_reader_leaf_count', 0)} "
        f"m07_m60_static_events={static.get('event_count', 0)} "
        f"m07_m60_static_leaves={static.get('leaf_count', 0)} "
        f"deferred_added_events={static.get('deferred_added_event_count', 0)} "
        f"protected_reuse_events={len(protected.get('public_demo_static_overlap_event_ids', []))} "
        f"protected_reuse_leaves={protected.get('source_leaf_count', 0)} "
        "runtime_claim=0 native_quality_claim=0"
    )


def main(argv: Sequence[str] | None = None) -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--json", action="store_true",
        help="print the complete source inventory, including every Korean leaf",
    )
    parser.add_argument("--self-test", action="store_true")
    args = parser.parse_args(argv)

    if args.self_test:
        failures, cases = run_self_test(ROOT)
        if failures:
            for failure in failures:
                print(f"ERROR full-body translation scope self-test: {failure}")
            print(
                "FULL_BODY_TRANSLATION_SCOPE_SELF_TEST_FAIL "
                f"cases={cases} failures={len(failures)}"
            )
            return 1
        report, errors = build_scope(ROOT)
        if errors:
            for error in errors:
                print(f"ERROR full-body translation scope: {error}")
            return 1
        print(_summary(
            report,
            f"FULL_BODY_TRANSLATION_SCOPE_SELF_TEST_OK cases={cases}",
        ))
        return 0

    report, errors = build_scope(ROOT)
    if errors:
        for error in errors:
            print(f"ERROR full-body translation scope: {error}")
        print(_summary(report, "FULL_BODY_TRANSLATION_SCOPE_FAIL"))
        return 1
    if args.json:
        print(json.dumps(report, ensure_ascii=False, indent=2, sort_keys=True))
    else:
        print(_summary(report, "FULL_BODY_TRANSLATION_SCOPE_OK"))
    return 0


if __name__ == "__main__":
    sys.exit(main())
