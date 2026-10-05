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
import copy
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
import order305_demo_source_compat as demo_source  # noqa: E402
import order310_demo_source_compat as latest_demo_source  # noqa: E402
import order309_source_compat as prior_source  # noqa: E402
import order313_source_compat as chapter2_source  # noqa: E402
import order350_source_compat as chapter3_source  # noqa: E402
import pr31_intake_history as current_source  # noqa: E402
import order365_ui_receipt_compat as ui_receipts  # noqa: E402


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
    "shipping_standard_leaves": 11547,
    "shipping_chapter5_reader_leaves": 133,
    "shipping_leaves": 11680,
    "shipping_event_ids_sha256": (
        "0254f6d7938d7e281204b5b730d6b59e179efbe12595ef16fa72d3b378b6a6de"
    ),
    "shipping_source_leaves_sha256": (
        "7a0aa5f7f4c4531a49dc041ca2519657c58b2e216ff6bfae2580cc5bc5b803b3"
    ),
    "m07_m60_root_refs": 162,
    "m07_m60_shipping_root_refs": 132,
    "m07_m60_shipping_seed_events": 129,
    "m07_m60_author_only_root_refs": 19,
    "m07_m60_planned_missing_root_refs": 11,
    "m07_m60_immediate_events": 168,
    "m07_m60_immediate_leaves": 1586,
    "m07_m60_events": 192,
    "m07_m60_leaves": 1751,
    "m07_m60_event_ids_sha256": (
        "7fef47a76488b7b15276c289b8a6be7ef381d982c9c6c317fd768efed20b5600"
    ),
    "m07_m60_source_leaves_sha256": (
        "8765f617e9eed51c115ed5e3e90178d0f7c3729661c00d491931bfcb6f7bfd33"
    ),
    "deferred_added_events": 24,
    "deferred_added_leaves": 165,
    "public_demo_events": 14,
    "protected_overlap_events": 1,
    "protected_overlap_leaves": 8,
    "target_shipping_leaves": {"ja": 108, "zh-CN": 100, "zh-TW": 100},
    "target_m07_m60_leaves": {"ja": 8, "zh-CN": 8, "zh-TW": 8},
}

# Current raw-source observation, separate from the predecessor ratchet above.
# The exact five-file guard and copied historical leaf proof bind this change.
ORDER305_SHIPPING_SOURCE_SHA256 = (
    "cb3dc8bdbbe3edbe1255d19ee3d68a6c55a04a9e2ebfc73e74f0aeff0ac1918e"
)

# Preserve the original target baseline independently of later accepted batches.
# These are the public-demo 14 roots (100 leaves), plus the existing JA-only
# story_prologue_goal (8). One CN leaf's omitted explicit two was repaired under
# ORDER-165; its preceding fingerprint is retained in that spec, not silently
# treated as the already-shipped demo. Hashes use sorted [id,path,target text].
FROZEN_TARGET_BASELINE_SHA256 = {
    "ja": "92a579b66a365d27c2314d21f15e45195e26f7f202f754a1cf8fa1716f7c8dc0",
    "zh-CN": "98b443122569e285f516eb6f378251f807aef15696e00b468843b982329c3bd1",
    "zh-TW": "912b402fba34238e570c65ac50528c4814b07720b58b056fbf53ba7fee7108f6",
}
ACCEPTANCE_LEDGER_PATH = Path("content/meta/full_game_localization.json")

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
CHOICE_TEXT_FIELDS = ("text", "result_text", "bridge_summary", "foreshadow")
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


def _scope_accepted_count(scope_ids: set[str], keys: set[tuple[str, str]]) -> int:
    return sum(event_id in scope_ids for event_id, _path in keys)


def _receipt_source_index(
    events: Mapping[str, SourceEvent],
    leaf_index: Mapping[str, tuple[TextLeaf, ...]],
) -> dict[str, tuple[tuple[str, str], str]]:
    """Map this collector's exact leaves to the shared portable receipt format."""
    result = {}
    for event_id, record in events.items():
        wanted = {leaf.path for leaf in leaf_index.get(event_id, ())}

        def walk(value: Any, tokens: tuple[Any, ...] = (), path: str = "") -> None:
            if isinstance(value, str) and path in wanted:
                pointer = "/" + "/".join(str(t).replace("~", "~0").replace("/", "~1") for t in tokens)
                result[f"events:{event_id}:{pointer}"] = ((event_id, path), canonical_sha({
                    "path": record.source_file, "field": tokens, "ko": value,
                }))
            elif isinstance(value, dict):
                for key, child in value.items():
                    walk(child, tokens + (key,), f"{path}.{key}" if path else str(key))
            elif isinstance(value, list):
                for index, child in enumerate(value):
                    walk(child, tokens + (index,), f"{path}[{index}]")

        walk(record.row)
    return result


def _accepted_event_additions(
    payload: Any, language: str,
    source_index: Mapping[str, tuple[tuple[str, str], str]],
    target_texts: Mapping[tuple[str, str], str],
    baseline_keys: set[tuple[str, str]], errors: list[str],
) -> set[tuple[str, str]]:
    """Only exact current event receipts may extend, never replace, the baseline."""
    from full_game_localization import PROMPT_VERSION

    accepted: dict[str, Any] = {}
    if payload is not None:
        if not isinstance(payload, dict) or payload.get("schema_version") != 1 \
                or payload.get("prompt_version") != PROMPT_VERSION or payload.get("native_review") != "OPEN":
            errors.append("acceptance ledger schema/prompt/native-review mismatch")
        else:
            candidate = payload.get("accepted")
            if not isinstance(candidate, dict) or set(candidate) != set(TARGET_LANGUAGES) \
                    or payload.get("accepted_sha256") != canonical_sha(candidate):
                errors.append("acceptance ledger locale/checksum mismatch")
            else:
                accepted = candidate
    verified: set[tuple[str, str]] = set()
    records = accepted.get(language, {})
    if not isinstance(records, dict):
        errors.append(f"{language}: acceptance ledger records must be an object")
        records = {}
    for receipt_id, receipt in records.items():
        if not isinstance(receipt_id, str) or not isinstance(receipt, dict) \
                or set(receipt) != {"source_sha256", "target_sha256"} \
                or any(not isinstance(v, str) or not re.fullmatch(r"[a-f0-9]{64}", v) for v in receipt.values()):
            errors.append(f"{language}: malformed accepted leaf receipt {receipt_id}")
            continue
        # Endings/catalog/UI have their own denominators and audits. They can
        # never authorize or inflate an event-prose observation.
        if not receipt_id.startswith("events:"):
            continue
        if receipt_id not in source_index:
            errors.append(f"{language}: accepted event leaf lacks supported Korean source: {receipt_id}")
            continue
        key, source_sha = source_index[receipt_id]
        if receipt["source_sha256"] != source_sha:
            errors.append(f"{language}: stale accepted event source hash: {receipt_id}")
            continue
        text = target_texts.get(key)
        if not isinstance(text, str) or not text.strip():
            errors.append(f"{language}: accepted event target missing/blank: {receipt_id}")
            continue
        if receipt["target_sha256"] != canonical_sha(text):
            errors.append(f"{language}: stale accepted event target hash: {receipt_id}")
            continue
        if key not in baseline_keys:
            verified.add(key)
    unapproved = set(target_texts) - baseline_keys - verified
    if unapproved:
        errors.append(f"{language}: target leaves without current source-bound acceptance: "
                      f"count={len(unapproved)} examples={sorted(unapproved)[:5]}")
    return verified


def _baseline_target_errors(
    language: str, baseline_keys: set[tuple[str, str]],
    target_texts: Mapping[tuple[str, str], str], expected_sha: str,
) -> list[str]:
    errors = []
    if baseline_keys - set(target_texts):
        errors.append(f"{language}: frozen target baseline lost leaf paths")
    actual = canonical_sha(sorted((eid, path, target_texts.get((eid, path)))
                                  for eid, path in baseline_keys))
    if actual != expected_sha:
        errors.append(f"{language}: frozen target baseline text/shape drifted")
    return errors


def _order305_historical_events(events: Mapping[str, SourceEvent]) -> dict[str, SourceEvent]:
    """Copy only exact successor objects; current inventory/receipts stay raw."""
    # One fresh invocation-bound proof for this vector, not one full Git/ledger
    # read per event. The context verifies Git/disk again before returning.
    with current_source.fresh_validation_proof():
        return {eid: replace(event, row=current_source.project_payload(
            [event.row], event.source_file)[0]) for eid, event in events.items()}


def current_target_acceptance(
    root: Path, events: Mapping[str, SourceEvent],
    leaf_index: Mapping[str, tuple[TextLeaf, ...]],
    target_events: Mapping[str, Mapping[str, SourceEvent]],
    target_leaves: Mapping[str, Mapping[str, tuple[TextLeaf, ...]]],
    public_demo_ids: set[str], shipping_ids: set[str], static_ids: set[str],
    errors: list[str],
) -> dict[str, Any]:
    from story_demo_localization_audit import EXPECTED_EVENT_LEAVES, localized_leaves

    public_keys = {(eid, path) for eid in public_demo_ids if eid in events
                   for path in localized_leaves(events[eid].row)}
    if len(public_keys) != EXPECTED_EVENT_LEAVES:
        errors.append("public-demo baseline source leaf count drifted")
    source_index = _receipt_source_index(events, leaf_index)
    ledger_path = root / ACCEPTANCE_LEDGER_PATH
    ledger = load_json(ledger_path, errors) if ledger_path.exists() else None
    report = {}
    for language in TARGET_LANGUAGES:
        baseline_keys = set(public_keys)
        if language == "ja":
            baseline_keys.update(("story_prologue_goal", leaf.path)
                                 for leaf in leaf_index.get("story_prologue_goal", ()))
        texts = {(eid, leaf.path): leaf.source for eid, leaves in target_leaves[language].items()
                 for leaf in leaves}
        historical_leaves = collect_leaf_index(
            _order305_historical_events(target_events[language]), errors)
        historical_texts = {(eid, leaf.path): leaf.source
                            for eid, leaves in historical_leaves.items() for leaf in leaves}
        errors.extend(_baseline_target_errors(language, baseline_keys, historical_texts,
                                             FROZEN_TARGET_BASELINE_SHA256[language]))
        for eid in target_events[language]:
            if eid not in {key[0] for key in baseline_keys} and not target_leaves[language].get(eid):
                errors.append(f"{language}: new target row has no accepted text leaves: {eid}")
        additions = _accepted_event_additions(ledger, language, source_index, texts, baseline_keys, errors)
        counts = {
            "historical_shipping_baseline_leaves": _scope_accepted_count(shipping_ids, baseline_keys),
            "historical_static_baseline_leaves": _scope_accepted_count(static_ids, baseline_keys),
            "accepted_current_event_addition_leaves": len(additions),
            "accepted_current_shipping_addition_leaves": _scope_accepted_count(shipping_ids, additions),
            "accepted_current_static_addition_leaves": _scope_accepted_count(static_ids, additions),
        }
        if counts["historical_shipping_baseline_leaves"] != EXPECTED["target_shipping_leaves"][language] \
                or counts["historical_static_baseline_leaves"] != EXPECTED["target_m07_m60_leaves"][language]:
            errors.append(f"{language}: historical baseline source/scope membership drifted")
        report[language] = counts
    return report


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
    errors: list[str] = ui_receipts.current_source_errors(repo)

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
    acceptance = current_target_acceptance(repo, events, leaf_index, target_events,
                                          target_leaves, public_demo_ids,
                                          shipping_ids, static_ids, errors)
    for language in TARGET_LANGUAGES:
        target_report[language] = {
            **acceptance[language],
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
            "historical_comparison_only": (
                "ORDER-351, ORDER-350/359 and preceding exact admitted Korean event vectors are inverted only when "
                "comparing preceding source pins; inventory text, hashes and receipts stay current"
            ),
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


def _source_history_observations(report: Mapping[str, Any]) -> tuple[dict[str, Any], list[str]]:
    """Open one fresh, whole-live-source proof before deriving historical data."""
    empty = {SCOPE_LIFECYCLE_SHIPPING: "", SCOPE_M07_M60_STATIC: "", "denominators": {}}
    try:
        with ui_receipts.fresh_validation_proof():
            errors = ui_receipts.current_source_errors()
            if errors:
                return empty, errors
            return _admitted_source_history_observations(report)
    except (OSError, ValueError) as exc:
        return empty, [f"ORDER-365 current source proof unavailable: {exc}"]


def _retirement_comparison_report(report: Mapping[str, Any], errors: list[str]) -> dict[str, Any]:
    """Restore classification only for old ratchets, never the emitted report.

    Both scope populations and every current event vector are independently
    rebuilt before restoring the exact six still-packaged reference events.
    No new receipt or target-translation claim is derived from this view.
    """
    successor = current_source.source_successor
    with successor.fresh_validation_proof(ROOT) as proof:
        old_author = set(json.loads(proof["before"][successor.LIFECYCLE_PATH])["author_only_event_ids"])
        new_author = set(json.loads(proof["after"][successor.LIFECYCLE_PATH])["author_only_event_ids"])
        if new_author - old_author != set(successor.RETIRED_IDS) or old_author - new_author:
            raise ValueError("ORDER-469 lifecycle inverse population differs")
        if report.get("source_files", {}).get("event_lifecycle_sha256") != successor._sha(
                proof["after"][successor.LIFECYCLE_PATH]):
            errors.append("ORDER-469 current report lifecycle raw binding differs")
        events = load_source_events(ROOT, errors)
        leaves = collect_leaf_index(events, errors)
        refs = collect_map_root_refs(load_json(ROOT / STORY_MAP_PATH, errors), errors)
        views = []
        for author in (new_author, old_author):
            shipping = set(events) - author
            classified = classify_m07_m60_refs(refs, set(events), shipping, author, errors)
            seeds = set(classified["shipping_seed_ids"])
            immediate = static_translation_closure(seeds, events, shipping, author, False, errors)
            static = static_translation_closure(seeds, events, shipping, author, True, errors)
            deferred = static - immediate
            def selected(ids):
                return [leaf for eid in ids for leaf in leaves[eid]]
            shipping_leaves, static_leaves = selected(shipping), selected(static)
            views.append({
                SCOPE_LIFECYCLE_SHIPPING: {
                    "packaged_event_count": len(events), "event_count": len(shipping),
                    "leaf_count": len(shipping_leaves),
                    "standard_leaf_count": sum(not leaf.chapter5_reader for leaf in shipping_leaves),
                    "chapter5_reader_leaf_count": sum(leaf.chapter5_reader for leaf in shipping_leaves),
                    "event_ids_sha256": event_id_digest(shipping),
                    "source_leaves_sha256": leaves_sha(shipping_leaves),
                    "author_only_excluded_event_count": len(author), "author_only_overlap_event_count": 0,
                    "events": [_event_inventory(eid, events, leaves) for eid in sorted(shipping)],
                },
                SCOPE_M07_M60_STATIC: {
                    "map_root_ref_count": len(classified["all"]),
                    "lifecycle_shipping_root_ref_count": len(classified["shipping"]),
                    "lifecycle_shipping_seed_event_count": len(seeds),
                    "author_only_root_ref_count": len(classified["author_only"]),
                    "planned_missing_root_ref_count": len(classified["planned_missing"]),
                    "immediate_closure_event_count": len(immediate),
                    "immediate_closure_leaf_count": len(selected(immediate)),
                    "event_count": len(static), "leaf_count": len(static_leaves),
                    "event_ids_sha256": event_id_digest(static), "source_leaves_sha256": leaves_sha(static_leaves),
                    "deferred_added_event_count": len(deferred), "deferred_added_leaf_count": len(selected(deferred)),
                    "author_only_overlap_event_count": 0, "event_ids": sorted(static),
                    "deferred_added_event_ids": sorted(deferred),
                    "excluded_author_only_event_ids": sorted({ref.event_id for ref in classified["author_only"]}),
                    "excluded_planned_missing_event_ids": sorted({ref.event_id for ref in classified["planned_missing"]}),
                },
            })
        current, historical = views
        for scope, values in current.items():
            for key, value in values.items():
                if report.get(scope, {}).get(key) != value:
                    errors.append(f"ORDER-469 current report is not the actual scope: {scope}.{key}")
        return {**report, **historical}


def _admitted_source_history_observations(report: Mapping[str, Any]) -> tuple[dict[str, Any], list[str]]:
    """Compare old pins without relabeling the current inventory or receipts.

    A historical leaf vector is substituted only for the exact current event
    vector from verified Git blobs; neighbors, wrong paths and edited report
    hashes remain visible. Undo 351, 359/350, 313/356 and 309 only, retaining 305.
    Counts are derived from those same verified vectors, never rewritten in
    the current report. The new ghost leaf exists only in the current vector.
    """
    errors: list[str] = []
    report = _retirement_comparison_report(report, errors)
    live: list[TextLeaf] = []
    historical: list[TextLeaf] = []
    # PR31 also edits dormant author-only prose. Bind the report population to
    # the independently evaluated lifecycle, never to the submitted report.
    lifecycle = evaluate_author_only(collect_lifecycle_inputs(ROOT))
    errors.extend("event lifecycle: " + message for message in lifecycle.errors)
    shipping_ids = set(lifecycle.product_event_ids) | set(current_source.source_successor.RETIRED_IDS)
    expected_paths = {eid: relative for relative, changes in current_source.HISTORICAL_JSON_LEAVES.items()
                      if relative.startswith("content/events/") for eid, _path in changes
                      if eid in shipping_ids}
    # Reuse proof only within this observation, not across calls or mutations.
    proof_rows: dict[str, tuple[dict[str, Any], dict[str, Any]]] = {}
    for relative in sorted(set(expected_paths.values())):
        try:
            before, after = current_source.historical_blobs(relative)
            proof_rows[relative] = (
                {row["id"]: row for row in json.loads(before)},
                {row["id"]: row for row in json.loads(after)},
            )
        except (OSError, ValueError) as exc:
            errors.append(str(exc))
    seen: set[str] = set()
    for event in report.get(SCOPE_LIFECYCLE_SHIPPING, {}).get("events", []):
        eid, relative = event["id"], event["source_file"]
        if eid in expected_paths:
            if relative != expected_paths[eid] or eid in seen:
                errors.append(f"ORDER-309 current report event path/count is unbound: {eid}")
            seen.add(eid)
        leaves = tuple(TextLeaf(eid, row["path"], row["source"], row["chapter5_reader"])
                       for row in event["leaves"])
        live.extend(leaves)
        if leaves_sha(leaves) != event["source_leaves_sha256"]:
            errors.append(f"current event observation is unbound: {eid}")
        replacement = leaves
        if relative in current_source.HISTORICAL_PATHS:
            if relative in proof_rows:
                old = proof_rows[relative][0].get(eid)
                new = proof_rows[relative][1].get(eid)
                if old is not None and new is not None:
                    approved = collect_event_leaves(eid, new, errors)
                    if leaves == approved:
                        replacement = collect_event_leaves(eid, old, errors)
                    elif eid in current_source.LIVE_EVENT_IDS.get(relative, ()):
                        errors.append(f"ORDER-309 current report event is not the admitted successor: {relative}#{eid}")
        historical.extend(replacement)
    if seen != set(expected_paths):
        errors.append("ORDER-309 current report is missing an admitted source event")
    static_ids = set(report.get(SCOPE_M07_M60_STATIC, {}).get("event_ids", []))
    result: dict[str, Any] = {"denominators": {}, "scope_observations": {
        scope: report[scope] for scope in (SCOPE_LIFECYCLE_SHIPPING, SCOPE_M07_M60_STATIC)}}
    for scope, ids in ((SCOPE_LIFECYCLE_SHIPPING, None), (SCOPE_M07_M60_STATIC, static_ids)):
        selected_live = [leaf for leaf in live if ids is None or leaf.event_id in ids]
        selected_history = [leaf for leaf in historical if ids is None or leaf.event_id in ids]
        if leaves_sha(selected_live) != report.get(scope, {}).get("source_leaves_sha256"):
            errors.append(f"current source observation hash is unbound: {scope}")
        result[scope] = leaves_sha(selected_history)
        historical_counts = {"leaf_count": len(selected_history)}
        live_counts = {"leaf_count": len(selected_live)}
        if scope == SCOPE_LIFECYCLE_SHIPPING:
            for name, reader in (("standard_leaf_count", False), ("chapter5_reader_leaf_count", True)):
                historical_counts[name] = sum(leaf.chapter5_reader == reader for leaf in selected_history)
                live_counts[name] = sum(leaf.chapter5_reader == reader for leaf in selected_live)
        else:
            deferred_ids = set(report.get(scope, {}).get("deferred_added_event_ids", []))
            for name, deferred in (("deferred_added_leaf_count", True), ("immediate_closure_leaf_count", False)):
                historical_counts[name] = sum((leaf.event_id in deferred_ids) == deferred for leaf in selected_history)
                live_counts[name] = sum((leaf.event_id in deferred_ids) == deferred for leaf in selected_live)
        for name, count in live_counts.items():
            if report.get(scope, {}).get(name) != count:
                errors.append(f"current source observation count is unbound: {scope}.{name}")
        result["denominators"][scope] = historical_counts
    return result, errors


def _expected_observation_errors(report: Mapping[str, Any]) -> list[str]:
    errors: list[str] = []
    shipping = report.get(SCOPE_LIFECYCLE_SHIPPING, {})
    static = report.get(SCOPE_M07_M60_STATIC, {})
    protected = report.get("protected_demo_reuse", {})
    targets = report.get("target_structure_inventory", {})
    historical, binding_errors = _source_history_observations(report)
    errors.extend(binding_errors)
    # Only EXPECTED comparisons use the restored classification. Caller report,
    # target acceptance, and emitted 1702/111 corpus remain the actual product.
    shipping = historical.get("scope_observations", {}).get(SCOPE_LIFECYCLE_SHIPPING, shipping)
    static = historical.get("scope_observations", {}).get(SCOPE_M07_M60_STATIC, static)
    historical_shipping = historical["denominators"].get(SCOPE_LIFECYCLE_SHIPPING, {})
    historical_static = historical["denominators"].get(SCOPE_M07_M60_STATIC, {})

    observed = {
        "packaged_events": shipping.get("packaged_event_count"),
        "author_only_events": shipping.get("author_only_excluded_event_count"),
        "shipping_events": shipping.get("event_count"),
        "shipping_standard_leaves": historical_shipping.get("standard_leaf_count"),
        "shipping_chapter5_reader_leaves": historical_shipping.get(
            "chapter5_reader_leaf_count"
        ),
        "shipping_leaves": historical_shipping.get("leaf_count"),
        "shipping_event_ids_sha256": shipping.get("event_ids_sha256"),
        "shipping_source_leaves_sha256": historical[SCOPE_LIFECYCLE_SHIPPING],
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
        "m07_m60_immediate_leaves": historical_static.get("immediate_closure_leaf_count"),
        "m07_m60_events": static.get("event_count"),
        "m07_m60_leaves": historical_static.get("leaf_count"),
        "m07_m60_event_ids_sha256": static.get("event_ids_sha256"),
        "m07_m60_source_leaves_sha256": historical[SCOPE_M07_M60_STATIC],
        "deferred_added_events": static.get("deferred_added_event_count"),
        "deferred_added_leaves": historical_static.get("deferred_added_leaf_count"),
        "protected_overlap_events": len(
            protected.get("public_demo_static_overlap_event_ids", [])
        ),
        "protected_overlap_leaves": protected.get("source_leaf_count"),
        "public_demo_events": protected.get("public_demo_event_count"),
    }
    for key, actual in observed.items():
        expected = (ORDER305_SHIPPING_SOURCE_SHA256
                    if key == "shipping_source_leaves_sha256" else EXPECTED[key])
        if actual != expected:
            errors.append(
                f"source observation (359→350→313/356→309 historical text view; post305) {key} drifted: "
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
        expected_shipping_target = EXPECTED["target_shipping_leaves"][language] + row.get(
            "accepted_current_shipping_addition_leaves", 0)
        expected_static_target = EXPECTED["target_m07_m60_leaves"][language] + row.get(
            "accepted_current_static_addition_leaves", 0)
        if shipping_target != expected_shipping_target:
            errors.append(
                f"{language} shipping target leaf observation drifted: "
                f"expected=historical+accepted:{expected_shipping_target} "
                f"actual={shipping_target}"
            )
        if static_target != expected_static_target:
            errors.append(
                f"{language} M07-M60 target leaf observation drifted: "
                f"expected=historical+accepted:{expected_static_target} "
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
    # The retirement inverse is comparison-only: exercise it separately from
    # prose history, including forged current populations and omitted rows.
    untouched_report = copy.deepcopy(report)
    retirement_errors: list[str] = []
    retirement_view = _retirement_comparison_report(report, retirement_errors)
    retired = set(current_source.source_successor.RETIRED_IDS)
    require("ORDER-469 report remains current after inverse", report == untouched_report
            and not retirement_errors and shipping.get("event_count") == 1702
            and shipping.get("author_only_excluded_event_count") == 111
            and retirement_view[SCOPE_LIFECYCLE_SHIPPING]["event_count"] == 1708
            and retirement_view[SCOPE_LIFECYCLE_SHIPPING]["author_only_excluded_event_count"] == 105)
    require("ORDER-469 exact six events restored only for comparison",
            {row["id"] for row in retirement_view[SCOPE_LIFECYCLE_SHIPPING]["events"]}
            - {row["id"] for row in shipping.get("events", [])} == retired
            and not retired & {row["id"] for row in shipping.get("events", [])})
    for label, field, value in (("old count", "event_count", 1708),
                                ("old author count", "author_only_excluded_event_count", 105),
                                ("omitted event", "events", shipping.get("events", [])[1:]),
                                ("old IDs hash", "event_ids_sha256", EXPECTED["shipping_event_ids_sha256"])):
        forged = copy.deepcopy(report)
        forged[SCOPE_LIFECYCLE_SHIPPING][field] = value
        rejected: list[str] = []
        _retirement_comparison_report(forged, rejected)
        require("ORDER-469 inverse rejects " + label, bool(rejected))
    source_history, source_binding_errors = _source_history_observations(report)
    historical_shipping = source_history["denominators"].get(SCOPE_LIFECYCLE_SHIPPING, {})
    historical_static = source_history["denominators"].get(SCOPE_M07_M60_STATIC, {})
    require(
        "shipping exact event and leaf denominator",
        (shipping.get("event_count"), shipping.get("leaf_count"), historical_shipping.get("leaf_count"))
        == (1702, 11622, 11680),
    )
    require(
        "Chapter 5 nested reader leaves included",
        historical_shipping.get("chapter5_reader_leaf_count") == 133
        and historical_shipping.get("standard_leaf_count") == 11547,
    )
    require(
        "M07-M60 static exact event and leaf denominator",
        (static.get("event_count"), static.get("leaf_count"),
         source_history.get("scope_observations", {}).get(SCOPE_M07_M60_STATIC, {}).get("event_count"),
         historical_static.get("leaf_count")) == (186, 1693, 192, 1751),
    )
    require(
        "ORDER-350 current inventory retains the added ghost leaf",
        not source_binding_errors
        and (source_history["scope_observations"][SCOPE_LIFECYCLE_SHIPPING].get("leaf_count"),
             source_history["scope_observations"][SCOPE_LIFECYCLE_SHIPPING].get("standard_leaf_count"),
             source_history["scope_observations"][SCOPE_M07_M60_STATIC].get("leaf_count"))
        == (11681, 11548, 1752),
    )
    require(
        "deferred follow-up expands static closure",
        source_history.get("scope_observations", {}).get(SCOPE_M07_M60_STATIC, {}).get("immediate_closure_event_count") == 168
        and static.get("deferred_added_event_count") == 24
        and static.get("deferred_added_leaf_count") == 165,
    )
    require(
        "author-only excluded from both source scopes",
        shipping.get("author_only_excluded_event_count") == 111
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

    source_history, source_binding_errors = _source_history_observations(report)
    comparison_shipping = source_history.get("scope_observations", {}).get(SCOPE_LIFECYCLE_SHIPPING, {})
    comparison_static = source_history.get("scope_observations", {}).get(SCOPE_M07_M60_STATIC, {})
    current_shipping_ids = {row["id"] for row in shipping.get("events", [])}
    comparison_shipping_ids = {row["id"] for row in comparison_shipping.get("events", [])}
    current_static_ids = set(static.get("event_ids", []))
    comparison_static_ids = set(comparison_static.get("event_ids", []))
    require(
        "source observations separate current and proven historical ID hashes",
        shipping.get("event_ids_sha256") == event_id_digest(current_shipping_ids)
        and static.get("event_ids_sha256") == event_id_digest(current_static_ids)
        and comparison_shipping_ids - current_shipping_ids == retired
        and not current_shipping_ids - comparison_shipping_ids
        and comparison_static_ids - current_static_ids == retired
        and not current_static_ids - comparison_static_ids
        and comparison_shipping.get("event_ids_sha256") == EXPECTED["shipping_event_ids_sha256"]
        and not source_binding_errors
        and source_history[SCOPE_LIFECYCLE_SHIPPING]
        == ORDER305_SHIPPING_SOURCE_SHA256
        and comparison_static.get("event_ids_sha256")
        == EXPECTED["m07_m60_event_ids_sha256"]
        and source_history[SCOPE_M07_M60_STATIC]
        == EXPECTED["m07_m60_source_leaves_sha256"],
    )

    # Recompute forged hashes and counts: self-consistency is not source identity.
    def rehash_observation(forged: dict[str, Any]) -> None:
        all_leaves = []
        for event in forged[SCOPE_LIFECYCLE_SHIPPING]["events"]:
            leaves = tuple(TextLeaf(event["id"], row["path"], row["source"], row["chapter5_reader"])
                           for row in event["leaves"])
            event["source_leaves_sha256"] = leaves_sha(leaves)
            all_leaves.extend(leaves)
        forged[SCOPE_LIFECYCLE_SHIPPING]["source_leaves_sha256"] = leaves_sha(all_leaves)
        forged[SCOPE_LIFECYCLE_SHIPPING]["leaf_count"] = len(all_leaves)
        forged[SCOPE_LIFECYCLE_SHIPPING]["standard_leaf_count"] = sum(not leaf.chapter5_reader for leaf in all_leaves)
        forged[SCOPE_LIFECYCLE_SHIPPING]["chapter5_reader_leaf_count"] = sum(leaf.chapter5_reader for leaf in all_leaves)
        static_ids = set(forged[SCOPE_M07_M60_STATIC]["event_ids"])
        static_leaves = [leaf for leaf in all_leaves if leaf.event_id in static_ids]
        forged[SCOPE_M07_M60_STATIC]["source_leaves_sha256"] = leaves_sha(static_leaves)
        forged[SCOPE_M07_M60_STATIC]["leaf_count"] = len(static_leaves)
        deferred_ids = set(forged[SCOPE_M07_M60_STATIC]["deferred_added_event_ids"])
        forged[SCOPE_M07_M60_STATIC]["deferred_added_leaf_count"] = sum(leaf.event_id in deferred_ids for leaf in static_leaves)
        forged[SCOPE_M07_M60_STATIC]["immediate_closure_leaf_count"] = sum(leaf.event_id not in deferred_ids for leaf in static_leaves)

    # All six remain packaged and retain PR31's immutable raw admission. They
    # are no longer live rollback fixtures: even an exact current/raw-approved
    # row must be rejected if it is inserted into the current shipping report.
    retired_rows = {row["id"]: row for row in comparison_shipping.get("events", []) if row["id"] in retired}
    retired_sources: dict[str, tuple[dict[str, Any], dict[str, Any]]] = {}
    with current_source.fresh_validation_proof() as proof:
        for relative in sorted({row["source_file"] for row in retired_rows.values()}):
            before, after = current_source.historical_blobs(relative)
            retired_sources[relative] = (
                {row["id"]: row for row in json.loads(before)},
                {row["id"]: row for row in json.loads(after)},
            )
            require("ORDER-469 retained source binds to unchanged PR31 raw: " + relative,
                    after == proof["current"][relative] == proof["pre_source_successor"][relative]
                    and not current_source.source_errors(after, relative))
            require("ORDER-469 retained source cannot borrow admission after raw mutation: " + relative,
                    bool(current_source.source_errors(after + b"\n", relative)))
    checked_retired: set[str] = set()
    for event_id in sorted(retired):
        template = retired_rows.get(event_id)
        require("ORDER-469 retired event is packaged but absent from both live scopes: " + event_id,
                template is not None and event_id not in current_shipping_ids and event_id not in current_static_ids)
        if template is None:
            continue  # The explicit missing-packaged-source assertion failed.
        relative = template["source_file"]
        old_events, current_events = retired_sources[relative]
        require("ORDER-469 comparison row uses exact current packaged source: " + event_id,
                template["source_leaves_sha256"] == leaves_sha(collect_event_leaves(
                    event_id, current_events[event_id], [])))
        for kind in ("current-raw", "historical-raw", "wrong-path", "neighbor", "wrong-hash"):
            forged = copy.deepcopy(report)
            event = copy.deepcopy(template)
            if kind == "historical-raw":
                event["leaves"] = [{"path": leaf.path, "source": leaf.source,
                    "source_text_sha256": hashlib.sha256(leaf.source.encode("utf-8")).hexdigest(),
                    "chapter5_reader": leaf.chapter5_reader}
                    for leaf in collect_event_leaves(event_id, old_events[event_id], [])]
            elif kind == "wrong-path":
                event["source_file"] = "content/events/unapproved.json"
            elif kind == "neighbor":
                event["leaves"][0]["source"] += "!"
            rows = forged[SCOPE_LIFECYCLE_SHIPPING]["events"]
            rows.append(event)
            rows.sort(key=lambda row: row["id"])
            forged[SCOPE_LIFECYCLE_SHIPPING]["event_count"] = len(rows)
            forged[SCOPE_LIFECYCLE_SHIPPING]["author_only_excluded_event_count"] -= 1
            forged[SCOPE_LIFECYCLE_SHIPPING]["event_ids_sha256"] = event_id_digest(row["id"] for row in rows)
            rehash_observation(forged)
            if kind == "wrong-hash":
                event["source_leaves_sha256"] = "0" * 64
            require(f"ORDER-469 rejects retired {kind} population intrusion: {event_id}",
                    bool(_expected_observation_errors(forged)))
        checked_retired.add(event_id)
    require("ORDER-469 non-live negative coverage is exactly all six", checked_retired == retired)

    # Preserve the existing bounded351 corpus. PR31's independent delta corpus
    # checks all71 raw files; do not multiply every old fixture by every PR row.
    for relative, changes in current_source.previous.HISTORICAL_JSON_LEAVES.items():
        if not relative.startswith("content/events/"):
            continue
        before, _after = current_source.historical_blobs(relative)
        old_events = {event["id"]: event for event in json.loads(before)}
        for event_id in sorted({eid for eid, _path in changes}):
            if event_id in retired:
                require("historical retired selector has explicit non-live/raw controls: " + event_id,
                        event_id in checked_retired and retired_rows[event_id]["source_file"] == relative)
                continue
            require("historical live selector remains in the current shipping population: " + event_id,
                    event_id in current_shipping_ids)
            if event_id not in current_shipping_ids:
                continue  # Unexpected absence is a recorded failure, never a silent skip.
            for kind in ("rollback", "wrong-path-rollback", "neighbor", "wrong-hash", "missing"):
                forged = copy.deepcopy(report)
                rows = forged[SCOPE_LIFECYCLE_SHIPPING]["events"]
                event = next(row for row in rows if row["id"] == event_id)
                if kind == "missing":
                    rows.remove(event)
                elif kind == "neighbor":
                    event["leaves"][0]["source"] += "!"
                elif kind != "wrong-hash":
                    old_leaves = {leaf.path: leaf.source for leaf in collect_event_leaves(event_id, old_events[event_id], [])}
                    event["leaves"] = [leaf for leaf in event["leaves"] if leaf["path"] in old_leaves]
                    for leaf in event["leaves"]:
                        leaf["source"] = old_leaves[leaf["path"]]
                    if kind == "wrong-path-rollback":
                        event["source_file"] = "content/events/unapproved.json"
                rehash_observation(forged)
                if kind == "wrong-hash":
                    event["source_leaves_sha256"] = "0" * 64
                owner = next((label for label, source in (
                    ("ORDER-309", prior_source), ("ORDER-313", chapter2_source),
                    ("ORDER-350", chapter3_source), ("ORDER-351", current_source),
                ) if event_id in {eid for eid, _path in source.JSON_LEAVES.get(relative, ())}), "ORDER-351")
                require(f"{owner} report rejects {kind}: {event_id}",
                        bool(_expected_observation_errors(forged)))

    for scope, field in ((SCOPE_LIFECYCLE_SHIPPING, "leaf_count"),
                         (SCOPE_LIFECYCLE_SHIPPING, "standard_leaf_count"),
                         (SCOPE_M07_M60_STATIC, "leaf_count")):
        forged = copy.deepcopy(report)
        forged[scope][field] -= 1
        require(f"ORDER-350 rejects historical count presented as current: {scope}.{field}",
                bool(_expected_observation_errors(forged)))

    from full_game_localization import PROMPT_VERSION, Leaf

    history_errors: list[str] = []
    historical_index = collect_leaf_index(_order305_historical_events(
        load_source_events(Path(root), history_errors)), history_errors)
    historical_shipping = [leaf for event_id in comparison_shipping_ids
                           for leaf in historical_index.get(event_id, ())]
    require("ORDER-305 preserves the exact preceding Korean leaf fingerprint",
            not history_errors and leaves_sha(historical_shipping)
            == EXPECTED["shipping_source_leaves_sha256"])

    # The source-denominator increase is exactly the six previously omitted
    # foreshadows. Removing only those leaves must reproduce both old source
    # fingerprints; target acceptance and public-demo baselines never change.
    for scope, old_hash in (
        (comparison_shipping_ids, "2f5e7a457f93d4e735b87d9a5e65f7dc01f467c6705bf33568fc76a7969a9184"),
        (comparison_static_ids, "682b871a66662b36f7f18e97c9c41623c558bd06d2b403b47c40e8ecadcc37a8"),
    ):
        legacy = [leaf for event_id in scope
                  for leaf in historical_index.get(event_id, ())
                  if not leaf.path.endswith(".foreshadow")]
        require("foreshadow addition preserves every legacy Korean leaf", leaves_sha(legacy) == old_hash)
    hints = {(event["id"], leaf["path"]) for event in shipping.get("events", [])
             for leaf in event["leaves"] if leaf["path"].endswith(".foreshadow")}
    require("all six source foreshadows remain counted including protected demo", hints == {
        ("arc_temptation_01", "choices[0].foreshadow"),
        ("arc_temptation_01", "choices[1].foreshadow"),
        ("arc_jaehyuk_mirror_decision", "choices[1].foreshadow"),
        ("arc_sangchul_confrontation", "choices[0].foreshadow"),
        ("arc_father_ng_call", "choices[1].foreshadow"),
        ("arc_sangchul_ng_meet", "choices[0].foreshadow"),
    })
    hint_event = SourceEvent("hint", "content/events/fixture.json", {
        "id": "hint", "choices": [{}, {"foreshadow": "{name}의 선택."}],
    })
    hint_errors: list[str] = []
    hint_leaves = collect_event_leaves("hint", hint_event.row, hint_errors)
    hint_full = Leaf("events", "hint", hint_event.source_file,
                     ("choices", 1, "foreshadow"), "{name}의 선택.", "choice_foreshadow")
    hint_index = _receipt_source_index({"hint": hint_event}, {"hint": hint_leaves})
    require("foreshadow source path and hash match full collector exactly",
            not hint_errors and len(hint_leaves) == 1 and hint_full.id in hint_index
            and hint_index[hint_full.id] == (("hint", "choices[1].foreshadow"), hint_full.source_sha256))
    for invalid in (None, 3, [], {"text": "암시"}):
        malformed_errors: list[str] = []
        malformed_leaves = collect_event_leaves("hint", {"choices": [{"foreshadow": invalid}]}, malformed_errors)
        require("foreshadow cannot hide structured or numeric payload", bool(malformed_errors) and not malformed_leaves)
    hint_targets = {("hint", "choices[1].foreshadow"): "{name}の選択。"}
    hint_accepted = {lang: {} for lang in TARGET_LANGUAGES}
    hint_accepted["ja"][hint_full.id] = {"source_sha256": hint_full.source_sha256,
                                        "target_sha256": canonical_sha("{name}の選択。")}
    hint_payload = {"schema_version": 1, "prompt_version": PROMPT_VERSION,
                    "native_review": "OPEN", "accepted": hint_accepted,
                    "accepted_sha256": canonical_sha(hint_accepted)}
    hint_findings: list[str] = []
    hint_additions = _accepted_event_additions(hint_payload, "ja", hint_index, hint_targets, set(), hint_findings)
    require("only current source-bound foreshadow receipt extends count",
            not hint_findings and hint_additions == set(hint_targets))
    for mutated in ({}, {("hint", "choices[0].foreshadow"): "{name}の選択。"},
                    {("hint", "choices[1].foreshadow"): "別の選択。"}):
        findings: list[str] = []
        verified = _accepted_event_additions(hint_payload, "ja", hint_index, mutated, set(), findings)
        require("missing moved or changed foreshadow cannot use old receipt", bool(findings) and not verified)

    receipt_event = SourceEvent("new", "content/events/fixture.json", {
        "id": "new", "choices": [{"result_text": "새 결과"}],
    })
    receipt_leaf = TextLeaf("new", "choices[0].result_text", "새 결과")
    receipt_index = _receipt_source_index({"new": receipt_event}, {"new": (receipt_leaf,)})
    full_leaf = Leaf("events", "new", receipt_event.source_file,
                     ("choices", 0, "result_text"), "새 결과", "event_standard")
    require("portable source hash exactly matches full-game collector",
            receipt_index[full_leaf.id][1] == full_leaf.source_sha256)
    baseline_keys = {("old", "title")}
    fixture_targets = {("old", "title"): "旧", ("new", "choices[0].result_text"): "新しい結果"}
    accepted = {language: {} for language in TARGET_LANGUAGES}
    accepted["ja"][full_leaf.id] = {
        "source_sha256": full_leaf.source_sha256,
        "target_sha256": canonical_sha("新しい結果"),
    }
    receipt_payload = {"schema_version": 1, "prompt_version": PROMPT_VERSION,
                       "native_review": "OPEN", "accepted": accepted,
                       "accepted_sha256": canonical_sha(accepted)}

    def receipt_case(payload: Any, texts: Mapping[tuple[str, str], str] = fixture_targets,
                     baseline: set[tuple[str, str]] = baseline_keys) -> tuple[set[tuple[str, str]], list[str]]:
        findings: list[str] = []
        additions = _accepted_event_additions(payload, "ja", receipt_index, texts, baseline, findings)
        return additions, findings

    additions, findings = receipt_case(receipt_payload)
    require("current hash-approved event extends baseline", additions == {("new", receipt_leaf.path)} and not findings)
    endings_payload = copy.deepcopy(receipt_payload)
    endings_payload["accepted"]["ja"]["endings:instant_legend:/title"] = {
        "source_sha256": "a" * 64, "target_sha256": "b" * 64,
    }
    endings_payload["accepted_sha256"] = canonical_sha(endings_payload["accepted"])
    ending_additions, findings = receipt_case(endings_payload)
    require("ending receipts never inflate event scope", ending_additions == additions and not findings)
    baseline_only, findings = receipt_case(None, {("old", "title"): "旧"})
    require("legacy baseline alone works without a ledger", not baseline_only and not findings)
    require("new target without ledger fails closed", bool(receipt_case(None)[1]))
    revoked = copy.deepcopy(receipt_payload)
    revoked["accepted"]["ja"].clear()
    revoked["accepted_sha256"] = canonical_sha(revoked["accepted"])
    require("deleted acceptance cannot authorize existing target", bool(receipt_case(revoked)[1]))
    corrupted = copy.deepcopy(receipt_payload)
    corrupted["accepted_sha256"] = "0" * 64
    require("acceptance checksum corruption fails closed", bool(receipt_case(corrupted)[1]))
    for key in ("source_sha256", "target_sha256"):
        stale = copy.deepcopy(receipt_payload)
        stale["accepted"]["ja"][full_leaf.id][key] = "0" * 64
        stale["accepted_sha256"] = canonical_sha(stale["accepted"])
        verified, findings = receipt_case(stale)
        require(f"stale accepted {key} cannot increase count", not verified and any("stale" in f for f in findings))
    missing = {("old", "title"): "旧"}
    require("accepted target deletion fails closed", any("missing/blank" in f for f in receipt_case(receipt_payload, missing)[1]))
    blank = {**fixture_targets, ("new", receipt_leaf.path): " "}
    require("accepted target blank fails closed", any("missing/blank" in f for f in receipt_case(receipt_payload, blank)[1]))
    wrong_id = copy.deepcopy(receipt_payload)
    wrong_id["accepted"]["ja"]["events:unknown:/title"] = wrong_id["accepted"]["ja"].pop(full_leaf.id)
    wrong_id["accepted_sha256"] = canonical_sha(wrong_id["accepted"])
    require("unknown event receipt cannot authorize target", bool(receipt_case(wrong_id)[1]))
    already_baseline, findings = receipt_case(receipt_payload, baseline=baseline_keys | {("new", receipt_leaf.path)})
    require("baseline receipt is not counted twice", not already_baseline and not findings)
    scope_fixture = {("static", "title"), ("shipping_only", "title"), ("author_only", "title")}
    require("source scopes count accepted set intersections independently",
            _scope_accepted_count({"static", "shipping_only"}, scope_fixture) == 2
            and _scope_accepted_count({"static"}, scope_fixture) == 1)
    frozen_sha = canonical_sha([("old", "title", "旧")])
    require("frozen baseline removal cannot be offset by an approved addition",
            bool(_baseline_target_errors("ja", baseline_keys, {("new", "title"): "新"}, frozen_sha)))
    require("frozen baseline same-count rewrite is rejected",
            bool(_baseline_target_errors("ja", baseline_keys, {("old", "title"): "改変"}, frozen_sha)))

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
