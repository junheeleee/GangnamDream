#!/usr/bin/env python3
"""Lock the exact player-visible localization surface of the 24-week V2 demo.

Prepared languages are intentionally allowed to be incomplete.  The default
mode validates source reachability, runtime routing, hidden-language state, and
every target row that already exists; ``--strict`` additionally requires full
coverage of the demo-only surface.  It never treats the 24-week CTA as a retail
ending and never expands the wave into weeks 25-240.
"""

from __future__ import annotations

import argparse
import copy
import hashlib
import json
import re
import sys
from collections import Counter
from dataclasses import dataclass
from pathlib import Path
from typing import Any, Iterable


ROOT = Path(__file__).resolve().parents[1]
TOOLS = ROOT / "tools"
if str(TOOLS) not in sys.path:
    sys.path.insert(0, str(TOOLS))

import i18n_coverage_check as coverage  # noqa: E402
import release_content_inventory as release_inventory  # noqa: E402


MANIFEST_PATH = ROOT / "content/meta/demo_localization_scope.json"
RELEASE_LEDGER_PATH = ROOT / "content/meta/release_content_inventory.json"
DEMO_CONTRACT_PATH = ROOT / "content/meta/demo_core_loop_v2.json"
OPENING_PATH = ROOT / "scenes/OpeningCinematic.gd"
IMAGE_REGISTRY_PATH = ROOT / "autoloads/ImageRegistry.gd"
LOCALE_MANAGER_PATH = ROOT / "autoloads/LocaleManager.gd"
PREPARED_LANGUAGES = ("ja", "zh-CN", "zh-TW")

GD_SUFFIX_PAIR = re.compile(
    r'"(?P<stem>[A-Za-z_][A-Za-z0-9_]*)"\s*:\s*'
    r'(?P<ko>"(?:\\.|[^"\\])*")\s*,\s*'
    r'"(?P=stem)_en"\s*:\s*(?P<en>"(?:\\.|[^"\\])*")',
    re.DOTALL,
)
GD_T_ET_PAIR = re.compile(
    r'"t"\s*:\s*(?P<ko>"(?:\\.|[^"\\])*")\s*,\s*'
    r'"et"\s*:\s*(?P<en>"(?:\\.|[^"\\])*")',
    re.DOTALL,
)
# Only constants reachable through a legal 24-week V2 action belong here.
# Aruba's legacy SCENARIOS_* card mode and MainGame's legacy AP pools are not
# reachable while V2 owns the demo, so including them would make the manifest
# broader than the product being reviewed.
DEMO_GD_PAIR_BLOCKS: tuple[tuple[str, str, str], ...] = (
    ("scenes/ArubaGame.gd", "CUSTOMER_TYPES", "suffix"),
    ("scenes/ArubaGame.gd", "DEL_ORDERS_DATA", "suffix"),
    ("scenes/JobHuntMiniGame.gd", "RESUME_QUESTION_POOL", "suffix"),
    ("scenes/JobHuntMiniGame.gd", "INTERVIEW_QUESTION_POOL", "suffix"),
    (
        "scenes/MainGame.gd",
        "SIDE_JOB_VIGNETTES_CONVENIENCE",
        "t_et",
    ),
)
DEMO_ACTIVITY_BUNDLE_ACTIONS: dict[str, str] = {
    "m1_convenience_trial_shift": "side_shift",
    "m2_rain_delivery_shift": "side_shift",
    "m1_youth_center_resume_clinic": "resume",
    "m2_youth_center_mock_interview": "interview",
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
HANGUL = re.compile(r"[\u1100-\u11ff\u3130-\u318f\uac00-\ud7a3]")
PLACEHOLDER = re.compile(
    r"\{[^{}]+\}|%(?:\d+\$)?[-+#0 .\d]*[a-zA-Z]|"
    r"\[/?(?:b|i|u|s|center|right|fill|color(?:=[^\]]+)?|font(?:=[^\]]+)?|"
    r"font_size(?:=[^\]]+)?|url(?:=[^\]]+)?|img(?:=[^\]]+)?)]"
)
OPENING_LITERAL = re.compile(
    r'"(?P<stem>title|body)_(?P<lang>ko|en)"\s*:\s*'
    r'(?P<literal>"(?:\\.|[^"\\])*")'
)

ROUTE_FUNCTIONS: dict[str, tuple[str, ...]] = {
    "scenes/MainGame.gd": (
        "_core_loop_v2_present_pre_bundle_declines",
        "_core_loop_v2_localized",
        "_core_loop_v2_final_decline_messages",
        "_localized_pair",
        "_on_aruba_closed",
    ),
    "scenes/ArubaGame.gd": ("_loc",),
    "scenes/JobHuntMiniGame.gd": ("_loc",),
    "scenes/CoreLoopPlanner.gd": (
        "_rebuild",
        "_build_record_surface",
        "_localized",
    ),
    "scenes/CommunicationPhone.gd": ("_optional_phone_copy", "_localized"),
    "scenes/OpeningCinematic.gd": ("_localized",),
    "scenes/StartMenu.gd": (
        "_theme_text",
        "_difficulty_text",
        "_format_start_money",
        "_title_wordmark",
        "_notice_localized",
    ),
    "scenes/StoryMode.gd": (
        "_story_money",
        "_story_result_value_text",
        "_stat_display_name",
    ),
    "systems/DemoCoreLoopV2.gd": ("_first_bill_localized_player_name",),
    "autoloads/GameState.gd": ("get_date_string", "get_job_display_name"),
    "autoloads/ImageRegistry.gd": ("get_person_info",),
}

ROUTE_REQUIRED_FRAGMENTS: dict[tuple[str, str], str] = {
    ("scenes/MainGame.gd", "_localized_pair"): (
        "return LocaleManager.ui(korean, english)"
    ),
    ("scenes/MainGame.gd", "_on_aruba_closed"): (
        "mood = _localized_pair(_sj_v)"
    ),
    ("scenes/ArubaGame.gd", "_loc"): (
        "return LocaleManager.ui(korean, english)"
    ),
    ("scenes/JobHuntMiniGame.gd", "_loc"): (
        "return LocaleManager.ui(korean, english)"
    ),
}


@dataclass(frozen=True)
class TextLeaf:
    event_id: str
    tokens: tuple[Any, ...]
    source: str
    owner: str

    @property
    def path(self) -> str:
        parts: list[str] = [self.event_id]
        for token in self.tokens:
            parts.append(f"[{token}]" if isinstance(token, int) else str(token))
        return "::".join(parts)


@dataclass(frozen=True)
class Pair:
    source_id: str
    korean: str
    english: str


def read_json(path: Path) -> Any:
    with path.open(encoding="utf-8") as handle:
        return json.load(handle)


def sha_rows(rows: Iterable[str]) -> str:
    return hashlib.sha256("\n".join(rows).encode("utf-8")).hexdigest()


def _add_leaf(
    leaves: list[TextLeaf], event_id: str, tokens: tuple[Any, ...],
    value: Any, owner: str,
) -> None:
    if isinstance(value, str) and value.strip():
        leaves.append(TextLeaf(event_id, tokens, value, owner))


def event_text_leaves(
    event_ids: Iterable[str], events: dict[str, dict[str, Any]],
    owners: dict[str, str],
) -> list[TextLeaf]:
    leaves: list[TextLeaf] = []
    for event_id in sorted(event_ids):
        event = events[event_id]
        owner = owners[event_id]
        for field in EVENT_TEXT_FIELDS:
            _add_leaf(leaves, event_id, (field,), event.get(field), owner)
        for field in EVENT_DICT_FIELDS:
            value = event.get(field)
            if isinstance(value, dict):
                for variant in sorted(value):
                    _add_leaf(
                        leaves, event_id, (field, str(variant)),
                        value[variant], owner,
                    )
        choices = event.get("choices", [])
        if not isinstance(choices, list):
            continue
        for index, raw_choice in enumerate(choices):
            if not isinstance(raw_choice, dict):
                continue
            for field in CHOICE_TEXT_FIELDS:
                _add_leaf(
                    leaves, event_id, ("choices", index, field),
                    raw_choice.get(field), owner,
                )
            for field in CHOICE_DICT_FIELDS:
                value = raw_choice.get(field)
                if isinstance(value, dict):
                    for variant in sorted(value):
                        _add_leaf(
                            leaves,
                            event_id,
                            ("choices", index, field, str(variant)),
                            value[variant],
                            owner,
                        )
    return leaves


def collect_json_suffix_pairs(value: Any, path: str = "$") -> tuple[list[Pair], list[str]]:
    pairs: list[Pair] = []
    errors: list[str] = []
    if isinstance(value, dict):
        ko_stems = {
            key[:-3] for key, child in value.items()
            if key.endswith("_ko") and isinstance(child, str)
        }
        en_stems = {
            key[:-3] for key, child in value.items()
            if key.endswith("_en") and isinstance(child, str)
        }
        for stem in sorted(ko_stems | en_stems):
            ko_value = value.get(f"{stem}_ko")
            en_value = value.get(f"{stem}_en")
            source_id = f"{path}.{stem}"
            if not isinstance(ko_value, str) or not ko_value.strip():
                errors.append(f"{source_id}: missing/non-string Korean pair value")
                continue
            if not isinstance(en_value, str) or not en_value.strip():
                errors.append(f"{source_id}: missing/non-string English pair value")
                continue
            pairs.append(Pair(source_id, ko_value, en_value))
        for key, child in value.items():
            child_pairs, child_errors = collect_json_suffix_pairs(
                child, f"{path}.{key}"
            )
            pairs.extend(child_pairs)
            errors.extend(child_errors)
    elif isinstance(value, list):
        for index, child in enumerate(value):
            child_pairs, child_errors = collect_json_suffix_pairs(
                child, f"{path}[{index}]"
            )
            pairs.extend(child_pairs)
            errors.extend(child_errors)
    return pairs, errors


def collect_opening_pairs() -> tuple[list[Pair], list[str]]:
    text = OPENING_PATH.read_text(encoding="utf-8")
    values: dict[tuple[str, str], list[str]] = {}
    errors: list[str] = []
    for match in OPENING_LITERAL.finditer(text):
        try:
            decoded = json.loads(match.group("literal"))
        except json.JSONDecodeError as exc:
            errors.append(f"OpeningCinematic: invalid string literal ({exc})")
            continue
        values.setdefault((match.group("stem"), match.group("lang")), []).append(
            decoded
        )
    pairs: list[Pair] = []
    for stem in ("title", "body"):
        ko_values = values.get((stem, "ko"), [])
        en_values = values.get((stem, "en"), [])
        if len(ko_values) != len(en_values):
            errors.append(
                f"OpeningCinematic {stem}: ko/en count {len(ko_values)}/{len(en_values)}"
            )
            continue
        for index, (ko_value, en_value) in enumerate(zip(ko_values, en_values)):
            pairs.append(Pair(
                f"scenes/OpeningCinematic.gd::BEATS[{index}].{stem}",
                ko_value,
                en_value,
            ))
    return sorted(pairs, key=lambda row: row.source_id), errors


def _gd_const_array_block(text: str, name: str) -> str:
    match = re.search(
        rf"(?ms)^const\s+{re.escape(name)}\s*(?::=|=)\s*\[\s*\n(.*?)^\]\s*$",
        text,
    )
    if match is None:
        raise ValueError(f"GDScript const array not found: {name}")
    return match.group(1)


def collect_demo_gd_pairs() -> tuple[list[Pair], list[str], dict[str, int]]:
    """Collect non-literal lookup pairs from reachable demo activities."""
    pairs: list[Pair] = []
    errors: list[str] = []
    owner_counts: dict[str, int] = {}
    for relative, const_name, pair_kind in DEMO_GD_PAIR_BLOCKS:
        path = ROOT / relative
        owner = f"{relative}::{const_name}"
        try:
            block = _gd_const_array_block(
                path.read_text(encoding="utf-8"), const_name
            )
        except ValueError as exc:
            errors.append(f"{relative}: {exc}")
            continue
        pattern = GD_SUFFIX_PAIR if pair_kind == "suffix" else GD_T_ET_PAIR
        matches = list(pattern.finditer(block))
        if not matches:
            errors.append(f"{owner}: no localized pairs found")
            continue
        owner_counts[owner] = len(matches)
        for index, match in enumerate(matches):
            stem = match.groupdict().get("stem") or "t"
            try:
                korean = json.loads(match.group("ko"))
                english = json.loads(match.group("en"))
            except json.JSONDecodeError as exc:
                errors.append(f"{owner}[{index}].{stem}: invalid literal ({exc})")
                continue
            if not korean.strip() or not english.strip():
                errors.append(f"{owner}[{index}].{stem}: empty pair value")
                continue
            pairs.append(Pair(
                f"{owner}[{index}].{stem}", korean, english
            ))
    return pairs, errors, owner_counts


def collect_event_runtime_pairs(
    event_ids: Iterable[str], events: dict[str, dict[str, Any]],
) -> list[Pair]:
    pairs: list[Pair] = []

    def walk(value: Any, path: str) -> None:
        if isinstance(value, dict):
            if isinstance(value.get("ko"), str) and isinstance(value.get("en"), str):
                pairs.append(Pair(path, value["ko"], value["en"]))
            for key, child in value.items():
                walk(child, f"{path}.{key}")
        elif isinstance(value, list):
            for index, child in enumerate(value):
                walk(child, f"{path}[{index}]")

    for event_id in sorted(event_ids):
        walk(events[event_id], f"event::{event_id}")
    return pairs


def _gd_const_block(text: str, name: str) -> str:
    match = re.search(
        rf"(?ms)^const\s+{re.escape(name)}\s*=\s*\{{\s*\n(.*?)^\}}\s*$",
        text,
    )
    if match is None:
        raise ValueError(f"ImageRegistry: const {name} not found")
    return match.group(1)


def _decode_gd_literal(raw: str) -> str:
    return json.loads(f'"{raw}"')


def collect_person_pairs(
    event_ids: Iterable[str], events: dict[str, dict[str, Any]],
) -> tuple[list[Pair], list[str]]:
    text = IMAGE_REGISTRY_PATH.read_text(encoding="utf-8")
    errors: list[str] = []
    try:
        info_block = _gd_const_block(text, "PERSON_INFO")
        en_block = _gd_const_block(text, "PERSON_NAMES_EN")
    except ValueError as exc:
        return [], [str(exc)]
    info = {
        key: _decode_gd_literal(name)
        for key, name in re.findall(
            r'^\s*"([^"]+)"\s*:\s*\{\s*"name"\s*:\s*"((?:\\.|[^"\\])*)"',
            info_block,
            re.MULTILINE,
        )
    }
    names_en = {
        key: _decode_gd_literal(name)
        for key, name in re.findall(
            r'^\s*"([^"]+)"\s*:\s*"((?:\\.|[^"\\])*)"',
            en_block,
            re.MULTILINE,
        )
    }
    portrait_ids: set[str] = set()

    def walk(value: Any) -> None:
        if isinstance(value, dict):
            for key, child in value.items():
                if key == "portrait" and isinstance(child, str) and child:
                    portrait_ids.add(child)
                walk(child)
        elif isinstance(value, list):
            for child in value:
                walk(child)

    for event_id in event_ids:
        walk(events[event_id])
    person_ids: set[str] = set()
    for portrait_id in portrait_ids:
        matches = [
            key for key in info
            if portrait_id == key or portrait_id.startswith(f"{key}_")
        ]
        if not matches:
            errors.append(f"demo portrait has no PERSON_INFO owner: {portrait_id}")
            continue
        person_ids.add(max(matches, key=len))
    pairs: list[Pair] = []
    for person_id in sorted(person_ids):
        ko_value = info.get(person_id, "")
        if person_id not in names_en:
            errors.append(f"PERSON_NAMES_EN missing demo person: {person_id}")
            continue
        en_value = names_en[person_id]
        if ko_value == "{name}" and en_value == "{name}":
            continue
        if not ko_value or not en_value:
            errors.append(f"PERSON_INFO {person_id}: empty ko/en name")
            continue
        pairs.append(Pair(
            f"autoloads/ImageRegistry.gd::PERSON_INFO.{person_id}",
            ko_value,
            en_value,
        ))
    return pairs, errors


def merge_pairs(pairs: Iterable[Pair]) -> tuple[dict[str, str], list[str]]:
    merged: dict[str, str] = {}
    errors: list[str] = []
    for pair in pairs:
        prior = merged.get(pair.korean)
        if prior is not None and prior != pair.english:
            errors.append(
                f"ambiguous Korean UI key {pair.korean!r}: {prior!r} != {pair.english!r}"
            )
        else:
            merged[pair.korean] = pair.english
    return merged, errors


def build_scope() -> tuple[dict[str, Any], dict[str, Any], list[str]]:
    errors: list[str] = []
    ledger = read_json(RELEASE_LEDGER_PATH)
    events, owners, _files = release_inventory.load_event_corpus(
        ROOT / "content/events"
    )
    week, prologue, chapter = release_inventory.v2_reachable_event_surfaces(
        ledger, events, errors
    )
    event_ids = sorted(week | prologue | chapter)
    leaves = event_text_leaves(event_ids, events, owners)

    demo_pairs, pair_errors = collect_json_suffix_pairs(read_json(DEMO_CONTRACT_PATH))
    opening_pairs, opening_errors = collect_opening_pairs()
    event_pairs = collect_event_runtime_pairs(event_ids, events)
    person_pairs, person_errors = collect_person_pairs(event_ids, events)
    activity_pairs, activity_errors, activity_owner_counts = (
        collect_demo_gd_pairs()
    )
    all_pairs = sorted(
        demo_pairs + opening_pairs + event_pairs + person_pairs + activity_pairs,
        key=lambda row: row.source_id,
    )
    merged_pairs, merge_errors = merge_pairs(all_pairs)
    errors.extend(
        pair_errors + opening_errors + person_errors + activity_errors
        + merge_errors
    )

    owner_counts = Counter(owners[event_id] for event_id in event_ids)
    catalog_asset_ids = [
        str(row.get("id", ""))
        for row in read_json(ROOT / "content/assets.json")[:4]
    ]
    asset_rows = {
        str(row.get("id", "")): row
        for row in read_json(ROOT / "content/assets.json")
        if isinstance(row, dict)
    }
    catalog_sources = [
        f"{asset_id}\t{asset_rows.get(asset_id, {}).get('name', '')}"
        for asset_id in catalog_asset_ids
    ]

    observed = {
        "week_1_24_event_count": len(week),
        "week_1_24_event_ids_sha256": sha_rows(sorted(week)),
        "prologue_event_count": len(prologue),
        "prologue_event_ids_sha256": sha_rows(sorted(prologue)),
        "chapter_event_count": len(chapter),
        "chapter_event_ids_sha256": sha_rows(sorted(chapter)),
        "visible_event_count": len(event_ids),
        "visible_event_ids_sha256": sha_rows(event_ids),
        "event_text_count": len(leaves),
        "event_text_ko_chars": sum(len(leaf.source) for leaf in leaves),
        "event_text_sha256": sha_rows(
            f"{leaf.event_id}\0{leaf.path}\0{leaf.source}" for leaf in leaves
        ),
        "event_owner_counts": {
            owner: owner_counts[owner] for owner in sorted(owner_counts)
        },
        "demo_json_pair_occurrences": len(demo_pairs),
        "demo_json_unique_keys": len(merge_pairs(demo_pairs)[0]),
        "demo_json_pairs_sha256": sha_rows(
            f"{pair.source_id}\0{pair.korean}\0{pair.english}"
            for pair in sorted(demo_pairs, key=lambda row: row.source_id)
        ),
        "opening_pair_occurrences": len(opening_pairs),
        "opening_pairs_sha256": sha_rows(
            f"{pair.source_id}\0{pair.korean}\0{pair.english}"
            for pair in opening_pairs
        ),
        "event_runtime_pair_occurrences": len(event_pairs),
        "person_pair_occurrences": len(person_pairs),
        "activity_gd_pair_occurrences": len(activity_pairs),
        "activity_gd_pair_owner_counts": {
            owner: activity_owner_counts[owner]
            for owner in sorted(activity_owner_counts)
        },
        "activity_gd_pairs_sha256": sha_rows(
            f"{pair.source_id}\0{pair.korean}\0{pair.english}"
            for pair in activity_pairs
        ),
        "dynamic_pair_occurrences": len(all_pairs),
        "dynamic_unique_keys": len(merged_pairs),
        "dynamic_pairs_sha256": sha_rows(
            f"{pair.source_id}\0{pair.korean}\0{pair.english}"
            for pair in all_pairs
        ),
        "dynamic_unique_sha256": sha_rows(
            f"{korean}\0{merged_pairs[korean]}" for korean in sorted(merged_pairs)
        ),
        "demo_ending_count": 0,
        "catalog_asset_name_ids": catalog_asset_ids,
        "catalog_asset_names_sha256": sha_rows(catalog_sources),
        "receipt_only_event_ids": ["callback_escaped_dirty_trace"],
    }
    runtime = {
        "events": events,
        "owners": owners,
        "event_ids": event_ids,
        "leaves": leaves,
        "pairs": all_pairs,
        "merged_pairs": merged_pairs,
        "catalog_asset_ids": catalog_asset_ids,
        "catalog_asset_names": {
            asset_id: str(asset_rows.get(asset_id, {}).get("name", ""))
            for asset_id in catalog_asset_ids
        },
    }
    return observed, runtime, errors


def compare_contract(expected: Any, observed: Any, path: str = "source_contract") -> list[str]:
    errors: list[str] = []
    if isinstance(expected, dict):
        if not isinstance(observed, dict):
            return [f"{path}: expected object"]
        if set(expected) != set(observed):
            errors.append(
                f"{path}: keys differ missing={sorted(set(expected)-set(observed))} "
                f"extra={sorted(set(observed)-set(expected))}"
            )
        for key in sorted(set(expected) & set(observed)):
            errors.extend(compare_contract(expected[key], observed[key], f"{path}.{key}"))
        return errors
    if expected != observed:
        errors.append(f"{path}: observed {observed!r} != contract {expected!r}")
    return errors


def _value_at_tokens(value: Any, tokens: tuple[Any, ...]) -> Any:
    current = value
    for token in tokens:
        if isinstance(token, int):
            if not isinstance(current, list) or token >= len(current):
                return None
            current = current[token]
        else:
            if not isinstance(current, dict) or token not in current:
                return None
            current = current[token]
    return current


def _source_text_present(value: Any) -> bool:
    return isinstance(value, str) and bool(value.strip())


def event_overlay_topology_errors(
    lang: str,
    event_id: str,
    base: dict[str, Any],
    overlay: dict[str, Any],
) -> list[str]:
    """Require the target row to mirror only the source's text topology.

    Without this exact shape, an overlay can invent an optional variant or
    bridge summary that the Korean event never authored, and runtime merge will
    expose it even though leaf coverage never counted it.
    """
    errors: list[str] = []
    expected_event_keys = {"id"}
    for field in EVENT_TEXT_FIELDS:
        if _source_text_present(base.get(field)):
            expected_event_keys.add(field)
    for field in EVENT_DICT_FIELDS:
        source = base.get(field)
        if isinstance(source, dict) and any(
            _source_text_present(value) for value in source.values()
        ):
            expected_event_keys.add(field)
    base_choices = base.get("choices", [])
    if isinstance(base_choices, list) and base_choices:
        expected_event_keys.add("choices")

    actual_event_keys = set(overlay)
    if actual_event_keys != expected_event_keys:
        errors.append(
            f"{lang}:{event_id}: text topology mismatch "
            f"missing={sorted(expected_event_keys-actual_event_keys)} "
            f"extra={sorted(actual_event_keys-expected_event_keys)}"
        )
    if overlay.get("id") != event_id:
        errors.append(f"{lang}:{event_id}: overlay id mismatch")

    for field in EVENT_DICT_FIELDS:
        source = base.get(field)
        target = overlay.get(field)
        if not isinstance(source, dict) or not isinstance(target, dict):
            continue
        expected_variants = {
            str(key) for key, value in source.items()
            if _source_text_present(value)
        }
        if set(target) != expected_variants:
            errors.append(
                f"{lang}:{event_id}:{field}: text variants mismatch "
                f"missing={sorted(expected_variants-set(target))} "
                f"extra={sorted(set(target)-expected_variants)}"
            )

    target_choices = overlay.get("choices", [])
    if not isinstance(base_choices, list) or not isinstance(target_choices, list):
        return errors
    for index, base_choice in enumerate(base_choices):
        if index >= len(target_choices) or not isinstance(base_choice, dict) \
                or not isinstance(target_choices[index], dict):
            continue
        expected_choice_keys: set[str] = set()
        for field in CHOICE_TEXT_FIELDS:
            if _source_text_present(base_choice.get(field)):
                expected_choice_keys.add(field)
        for field in CHOICE_DICT_FIELDS:
            source = base_choice.get(field)
            if isinstance(source, dict) and any(
                _source_text_present(value) for value in source.values()
            ):
                expected_choice_keys.add(field)
        target_choice = target_choices[index]
        if set(target_choice) != expected_choice_keys:
            errors.append(
                f"{lang}:{event_id}:choice:{index}: text topology mismatch "
                f"missing={sorted(expected_choice_keys-set(target_choice))} "
                f"extra={sorted(set(target_choice)-expected_choice_keys)}"
            )
        for field in CHOICE_DICT_FIELDS:
            source = base_choice.get(field)
            target = target_choice.get(field)
            if not isinstance(source, dict) or not isinstance(target, dict):
                continue
            expected_variants = {
                str(key) for key, value in source.items()
                if _source_text_present(value)
            }
            if set(target) != expected_variants:
                errors.append(
                    f"{lang}:{event_id}:choice:{index}:{field}: variants mismatch"
                )
    return errors


def load_overlay_events(lang: str) -> tuple[dict[str, dict[str, Any]], list[str]]:
    errors: list[str] = []
    rows = coverage.load_event_directory(
        str(ROOT / "content" / f"events_{lang}"), errors
    )
    return rows, errors


def _common_target_errors(source: str, target: str) -> list[str]:
    errors: list[str] = []
    if HANGUL.search(target):
        errors.append("Hangul remains")
    if sorted(PLACEHOLDER.findall(source)) != sorted(PLACEHOLDER.findall(target)):
        errors.append("placeholder mismatch")
    if source.count("\n\n") != target.count("\n\n"):
        errors.append("paragraph mismatch")
    return errors


def _validate_target_text(lang: str, key: str, source: str, target: str) -> list[str]:
    errors = _common_target_errors(source, target)
    if lang in ("zh-CN", "zh-TW"):
        # ORDER-82 owns Chinese regional semantics.  Keep this demo collector
        # as the topology/coverage source while reusing the language-specific
        # script, won, number, terminology, and name gate for every existing
        # target row.
        import zh_translation_audit as zh_audit

        errors.extend(zh_audit.validate_text(lang, key, source, target))
        return list(dict.fromkeys(errors))
    if lang != "ja":
        return errors
    # Lazy import keeps the exact Japanese terminology gate reusable by the
    # demo-only translation collector without a module-import cycle.
    import ja_translation_audit as ja_audit
    from ja_translation_pipeline import Entry

    entry = Entry(key, source, f"24-week demo / {key}")
    ja_errors: list[str] = []
    ja_audit.check_text(entry, target, ja_errors)
    errors.extend(ja_errors)
    return list(dict.fromkeys(errors))


def language_coverage(
    lang: str, runtime: dict[str, Any], strict: bool,
) -> tuple[dict[str, int], list[str]]:
    errors: list[str] = []
    overlays, load_errors = load_overlay_events(lang)
    errors.extend(load_errors)
    base_events: dict[str, dict[str, Any]] = runtime["events"]
    event_ids: list[str] = runtime["event_ids"]
    leaves: list[TextLeaf] = runtime["leaves"]

    covered_events = 0
    covered_strings = 0
    for event_id in event_ids:
        overlay = overlays.get(event_id)
        if overlay is None:
            continue
        covered_events += 1
        structural_errors: list[str] = []
        coverage.validate_event(
            lang, event_id, base_events[event_id], overlay, structural_errors
        )
        base_choices = base_events[event_id].get("choices", [])
        target_choices = overlay.get("choices", [])
        if isinstance(base_choices, list) and isinstance(target_choices, list) \
                and len(base_choices) != len(target_choices):
            structural_errors.append(
                f"{lang}:{event_id}: choice count {len(target_choices)} != {len(base_choices)}"
            )
        structural_errors.extend(event_overlay_topology_errors(
            lang, event_id, base_events[event_id], overlay
        ))
        errors.extend(structural_errors)

    for leaf in leaves:
        overlay = overlays.get(leaf.event_id)
        if overlay is None:
            continue
        translated = _value_at_tokens(overlay, leaf.tokens)
        if not isinstance(translated, str):
            continue
        if not translated.strip():
            errors.append(f"{lang}:event::{leaf.path}: empty translation")
            continue
        covered_strings += 1
        for error in _validate_target_text(
            lang, f"event::{leaf.path}", leaf.source, translated
        ):
            errors.append(f"{lang}:event::{leaf.path}: {error}")

    ui_path = ROOT / "locale" / f"ui_{lang}.json"
    ui_table = read_json(ui_path) if ui_path.is_file() else {}
    if not isinstance(ui_table, dict):
        errors.append(f"{ui_path.relative_to(ROOT)}: expected object")
        ui_table = {}
    covered_dynamic = 0
    for korean, english in sorted(runtime["merged_pairs"].items()):
        translated = ui_table.get(korean)
        if not isinstance(translated, str):
            continue
        if not translated.strip():
            errors.append(f"{lang}:dynamic:{korean!r}: empty translation")
            continue
        covered_dynamic += 1
        for error in _validate_target_text(
            lang,
            f"ui::demo::{hashlib.sha1(korean.encode()).hexdigest()[:12]}",
            korean,
            translated,
        ):
            errors.append(f"{lang}:dynamic:{korean!r}: {error}")

    catalog_path = ROOT / "locale" / f"catalog_{lang}.json"
    catalog = read_json(catalog_path) if catalog_path.is_file() else {}
    assets = catalog.get("assets", {}) if isinstance(catalog, dict) else {}
    if not isinstance(assets, dict):
        errors.append(f"{catalog_path.relative_to(ROOT)}.assets: expected object")
        assets = {}
    covered_catalog = 0
    for asset_id in runtime["catalog_asset_ids"]:
        row = assets.get(asset_id)
        if not isinstance(row, dict) or not isinstance(row.get("name"), str):
            continue
        translated_name = row["name"]
        if not translated_name.strip():
            errors.append(f"{lang}:catalog:assets:{asset_id}: empty name")
            continue
        covered_catalog += 1
        source_name = runtime["catalog_asset_names"].get(asset_id, "")
        for error in _validate_target_text(
            lang, f"catalog::assets::{asset_id}::name", source_name,
            translated_name,
        ):
            errors.append(f"{lang}:catalog:assets:{asset_id}: {error}")

    totals = {
        "events": len(event_ids),
        "event_strings": len(leaves),
        "dynamic": len(runtime["merged_pairs"]),
        "catalog": len(runtime["catalog_asset_ids"]),
    }
    covered = {
        "events": covered_events,
        "event_strings": covered_strings,
        "dynamic": covered_dynamic,
        "catalog": covered_catalog,
    }
    if strict:
        for key, total in totals.items():
            if covered[key] != total:
                errors.append(
                    f"{lang}: strict {key} coverage {covered[key]}/{total}"
                )
    return {**covered, **{f"total_{key}": value for key, value in totals.items()}}, errors


def shipping_languages() -> list[str]:
    source = LOCALE_MANAGER_PATH.read_text(encoding="utf-8")
    match = re.search(
        r"SHIPPING_LANGUAGES[^=]*=\s*\[([^\]]*)\]", source
    )
    if match is None:
        return []
    return re.findall(r'"([^"]+)"', match.group(1))


def _route_block_errors(
    relative: str, function_name: str, block: str,
) -> tuple[list[str], int]:
    errors: list[str] = []
    found = block.count("LocaleManager.is_english()")
    found += len(re.findall(
        r"LocaleManager\.language\s*==\s*[\"']en[\"']", block
    ))
    if found:
        errors.append(
            f"{relative}:{function_name}: prepared locale uses is_english()"
        )
    required = ROUTE_REQUIRED_FRAGMENTS.get((relative, function_name), "")
    if required and required not in block:
        errors.append(
            f"{relative}:{function_name}: missing translated lookup route"
        )
    return errors, found


def activity_contract_errors(contract: dict[str, Any]) -> list[str]:
    """Prove that every extracted activity pool still has a legal V2 owner."""
    errors: list[str] = []
    bundles = contract.get("scene_bundles", {})
    months = contract.get("months", [])
    offered: set[str] = set()
    if isinstance(months, list):
        for month in months:
            if not isinstance(month, dict):
                continue
            raw_offers = month.get("offers", [])
            if isinstance(raw_offers, list):
                offered.update(str(value) for value in raw_offers)
    for bundle_id, action_id in DEMO_ACTIVITY_BUNDLE_ACTIONS.items():
        bundle = bundles.get(bundle_id) if isinstance(bundles, dict) else None
        if not isinstance(bundle, dict):
            errors.append(f"demo activity bundle missing: {bundle_id}")
            continue
        if str(bundle.get("action_id", "")) != action_id:
            errors.append(
                f"demo activity bundle {bundle_id}: action_id is not {action_id}"
            )
        if bundle_id not in offered:
            errors.append(f"demo activity bundle is not legally offered: {bundle_id}")

    main_path = ROOT / "scenes/MainGame.gd"
    try:
        dispatch = release_inventory.gd_function_block(
            main_path, "_core_loop_v2_begin_action_bundle"
        )
        side_shift = release_inventory.gd_function_block(
            main_path, "_core_loop_v2_open_side_shift"
        )
    except ValueError as exc:
        return errors + [str(exc)]
    for fragment in (
        '"side_shift":\n\t\t\t_core_loop_v2_open_side_shift(bundle_id)',
        '"resume":\n\t\t\t_ap_write_resume()',
        '"interview":\n\t\t\t_ap_interview_prep()',
    ):
        if fragment not in dispatch:
            errors.append(f"MainGame V2 activity dispatch missing: {fragment!r}")
    for fragment in (
        '"job_01" if bundle_id == "m1_convenience_trial_shift" else "job_02"',
        'if bundle_id == "m2_rain_delivery_shift"',
    ):
        if fragment not in side_shift:
            errors.append(f"MainGame V2 side-shift route missing: {fragment!r}")
    return errors


def route_errors() -> tuple[list[str], int]:
    errors: list[str] = []
    bypasses = 0
    for relative, functions in ROUTE_FUNCTIONS.items():
        path = ROOT / relative
        for function_name in functions:
            try:
                block = release_inventory.gd_function_block(path, function_name)
            except ValueError as exc:
                errors.append(str(exc))
                continue
            block_errors, found = _route_block_errors(
                relative, function_name, block
            )
            errors.extend(block_errors)
            bypasses += found
    planner = release_inventory.gd_function_block(
        ROOT / "scenes/CoreLoopPlanner.gd", "_rebuild"
    )
    if '_localized(_month_data, "title")' not in planner:
        errors.append("CoreLoopPlanner._rebuild: month title bypasses pair lookup")
    errors.extend(activity_contract_errors(read_json(DEMO_CONTRACT_PATH)))
    return errors, bypasses


def boundary_errors(event_ids: Iterable[str], manifest: dict[str, Any]) -> list[str]:
    errors: list[str] = []
    event_set = set(event_ids)
    for event_id in manifest.get("receipt_only_event_ids", []):
        if event_id in event_set:
            errors.append(f"receipt-only event entered visible scope: {event_id}")
    if "v2_dirty_trace_initial_call" not in event_set:
        errors.append("visible dirty-trace replacement root is missing")
    return errors


def run_self_test(
    manifest: dict[str, Any], observed: dict[str, Any], runtime: dict[str, Any],
) -> list[str]:
    failures: list[str] = []
    cases = 0

    changed = copy.deepcopy(observed)
    changed["visible_event_count"] -= 1
    cases += 1
    if not compare_contract(manifest["source_contract"], changed):
        failures.append("event-count mutation was not rejected")

    changed = copy.deepcopy(observed)
    changed["dynamic_unique_keys"] -= 1
    cases += 1
    if not compare_contract(manifest["source_contract"], changed):
        failures.append("dynamic-key mutation was not rejected")

    changed_ids = list(runtime["event_ids"]) + ["callback_escaped_dirty_trace"]
    cases += 1
    if not boundary_errors(changed_ids, manifest):
        failures.append("receipt-only foreground mutation was not rejected")

    base = runtime["events"]["story_prologue_goal"]
    overlay = copy.deepcopy(base)
    overlay["choices"].append(copy.deepcopy(overlay["choices"][0]))
    mutation_errors: list[str] = []
    coverage.validate_event("ja", "story_prologue_goal", base, overlay, mutation_errors)
    if len(overlay["choices"]) != len(base["choices"]):
        mutation_errors.append("choice count mismatch")
    cases += 1
    if not mutation_errors:
        failures.append("extra-choice mutation was not rejected")

    changed_shipping = list(manifest["shipping_languages"]) + ["ja"]
    cases += 1
    if not set(changed_shipping) & set(PREPARED_LANGUAGES):
        failures.append("prepared-language visibility mutation was not rejected")

    overlays, overlay_errors = load_overlay_events("ja")
    source_event = runtime["events"]["story_prologue_goal"]
    target_event = copy.deepcopy(overlays.get("story_prologue_goal", {}))
    target_event["description_low_mental"] = "存在しない追加文"
    cases += 1
    if overlay_errors or not event_overlay_topology_errors(
        "ja", "story_prologue_goal", source_event, target_event
    ):
        failures.append("invented event-text topology was not rejected")

    cases += 1
    if not _validate_target_text("ja", "self-test-empty", "제목", ""):
        failures.append("empty existing Japanese target was not rejected")

    cases += 1
    if not _validate_target_text(
        "ja", "self-test-catalog", "한성전자", "x"
    ):
        failures.append("invalid Japanese catalog name was not rejected")

    cases += 1
    short_errors = _validate_target_text(
        "ja", "self-test-short-korean", "돈", "Money"
    )
    if not any("no Japanese glyphs" in error for error in short_errors):
        failures.append("short Korean source with English target was not rejected")

    aruba_block = release_inventory.gd_function_block(
        ROOT / "scenes/ArubaGame.gd", "_loc"
    )
    mutated_aruba = aruba_block.replace(
        "return LocaleManager.ui(korean, english)",
        "return english if LocaleManager.is_english() else korean",
    )
    cases += 1
    mutation_errors, _mutation_count = _route_block_errors(
        "scenes/ArubaGame.gd", "_loc", mutated_aruba
    )
    if not mutation_errors:
        failures.append("Aruba direct-English route mutation was not rejected")

    mutated_contract = copy.deepcopy(read_json(DEMO_CONTRACT_PATH))
    mutated_contract["scene_bundles"][
        "m1_youth_center_resume_clinic"
    ]["action_id"] = "rest"
    cases += 1
    if not activity_contract_errors(mutated_contract):
        failures.append("demo activity-owner mutation was not rejected")

    _zh_result, zh_errors = language_coverage("zh-CN", runtime, True)
    cases += 1
    if any("strict is unavailable" in error for error in zh_errors):
        failures.append("Chinese strict mode still uses the pre-ORDER-82 refusal")
    if not any("strict events coverage" in error for error in zh_errors):
        failures.append("empty Chinese event coverage was not rejected by strict mode")

    cases += 1
    wrong_region = _validate_target_text(
        "zh-CN", "self-test-cn-script", "강남에서 목표는 30억원.",
        "在江南，目標是30億韓元。",
    )
    if not any("regional script mismatch" in error for error in wrong_region):
        failures.append("Traditional Chinese mutation passed the Simplified gate")

    if failures:
        return failures
    print(f"DEMO_I18N_SELF_TEST_OK cases={cases}")
    return []


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--lang", choices=("all",) + PREPARED_LANGUAGES, default="all"
    )
    parser.add_argument("--strict", action="store_true")
    parser.add_argument("--self-test", action="store_true")
    parser.add_argument("--print-observed", action="store_true")
    args = parser.parse_args()

    observed, runtime, errors = build_scope()
    if args.print_observed:
        print(json.dumps(observed, ensure_ascii=False, indent=2))
        return 1 if errors else 0
    if not MANIFEST_PATH.is_file():
        print("DEMO_I18N_SCOPE_FAIL — manifest missing")
        return 1
    manifest = read_json(MANIFEST_PATH)
    errors.extend(compare_contract(manifest.get("source_contract"), observed))
    errors.extend(boundary_errors(runtime["event_ids"], manifest))
    routes, bypasses = route_errors()
    errors.extend(routes)

    actual_shipping = shipping_languages()
    if actual_shipping != manifest.get("shipping_languages"):
        errors.append(
            f"shipping languages {actual_shipping} != {manifest.get('shipping_languages')}"
        )
    exposed = sorted(set(actual_shipping) & set(PREPARED_LANGUAGES))
    if exposed:
        errors.append(f"prepared languages exposed before approval: {exposed}")

    print(
        "DEMO_I18N_SCOPE "
        f"events={observed['visible_event_count']} "
        f"strings={observed['event_text_count']} endings=0 "
        f"dynamic_pairs={observed['dynamic_pair_occurrences']} "
        f"dynamic_keys={observed['dynamic_unique_keys']} "
        f"catalog={len(observed['catalog_asset_name_ids'])}"
    )
    languages = PREPARED_LANGUAGES if args.lang == "all" else (args.lang,)
    for lang in languages:
        result, lang_errors = language_coverage(lang, runtime, args.strict)
        errors.extend(lang_errors)
        mode = "strict" if args.strict else "skeleton"
        print(
            "DEMO_I18N_COVERAGE "
            f"lang={lang} events={result['events']}/{result['total_events']} "
            f"strings={result['event_strings']}/{result['total_event_strings']} "
            f"dynamic={result['dynamic']}/{result['total_dynamic']} "
            f"catalog={result['catalog']}/{result['total_catalog']} mode={mode}"
        )
        print(
            "DEMO_I18N_ROUTE "
            f"language={lang} translated_lookup={result['dynamic']} "
            f"direct_english_bypass={bypasses} shipping=0"
        )

    if args.self_test:
        errors.extend(run_self_test(manifest, observed, runtime))
    if errors:
        print(f"DEMO_I18N_SCOPE_FAIL errors={len(errors)}")
        for error in errors[:200]:
            print(f"  {error}")
        if len(errors) > 200:
            print(f"  ... {len(errors) - 200} more")
        return 1
    print("DEMO_I18N_SCOPE_OK")
    return 0


if __name__ == "__main__":
    sys.exit(main())
