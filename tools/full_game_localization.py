#!/usr/bin/env python3
"""Source-bound full-game translation inventory and bounded JSONL exchange.

This tool never generates translations, converts Chinese scripts, deletes locale
files, or changes shipping claims. ``inventory`` separates source, present,
validated and receipted leaves. A successful batch is not full-game completion.
``export`` emits a manifest followed by source rows. The response has the same
manifest and one {id, locale, source_sha256, prompt_version, text} per source row.
``check`` is read-only; ``import --accept`` merges only those validated leaves.
Unverified dynamic candidates and fields outside the existing overlay validator
contract can be exported for drafting but not imported.
"""
from __future__ import annotations

import argparse
import copy
import hashlib
import json
import os
import re
import subprocess
import sys
import tempfile
from collections import Counter, defaultdict
from dataclasses import asdict, dataclass
from pathlib import Path
from typing import Any

ROOT = Path(__file__).resolve().parents[1]
LOCALES = ("ja", "zh-CN", "zh-TW")
PROMPT_VERSION = "full-ko-direct-2026-09-07.1"
SCHEMA_VERSION = 1
# Exact nine historical receipts from 6e088e5 (three unused condition notes per
# locale). Never recompute this from mutable metadata to accept new/deleted notes.
RETAINED_ENDING_NOTES_SHA256 = "fec66e4714d357df965e1d3576dcf61991ad5615326d78e8e2795ec701f77fdb"
GROUPS = ("events", "endings", "catalog", "ui", "ui_unverified")
READER = re.compile(r"^chapter5_[a-z0-9_]+_reads$")
CHAPTER5_INLINE_SLOT = re.compile(r"\[\[c5read:[0-9]+\]\]")
HANGUL = re.compile(r"[\u1100-\u11ff\u3130-\u318f\uac00-\ud7a3]")


class ContractError(ValueError):
    pass


def strict_pairs(pairs: list[tuple[str, Any]]) -> dict[str, Any]:
    result: dict[str, Any] = {}
    for key, value in pairs:
        if key in result:
            raise ContractError(f"duplicate raw JSON key: {key}")
        result[key] = value
    return result


def loads(text: str) -> Any:
    return json.loads(text, object_pairs_hook=strict_pairs,
                      parse_constant=lambda token: (_ for _ in ()).throw(
                          ContractError(f"nonfinite JSON value: {token}")))


def read_json(path: Path) -> Any:
    return loads(path.read_text(encoding="utf-8"))


def digest(value: Any) -> str:
    return hashlib.sha256(json.dumps(value, ensure_ascii=False, sort_keys=True,
                                    separators=(",", ":")).encode()).hexdigest()


def sha_file(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def pointer(tokens: tuple[Any, ...]) -> str:
    return "/" + "/".join(str(x).replace("~", "~0").replace("/", "~1") for x in tokens)


@dataclass(frozen=True)
class Leaf:
    group: str
    owner: str
    source_path: str
    path: tuple[Any, ...]
    source: str
    category: str
    lifecycle: str = "not_applicable"
    protected: bool = False
    runtime_support: str = "builtin_overlay_static_only"
    format_template: bool = False

    @property
    def id(self) -> str:
        return f"{self.group}:{self.owner}:{pointer(self.path)}"

    @property
    def source_sha256(self) -> str:
        return digest({"path": self.source_path, "field": self.path, "ko": self.source})


def row_index(rows: Any, owner: str) -> dict[str, dict[str, Any]]:
    if not isinstance(rows, list):
        raise ContractError(f"{owner}: expected ID array")
    result = {}
    for row in rows:
        if not isinstance(row, dict) or not isinstance(row.get("id"), str) or not row["id"]:
            raise ContractError(f"{owner}: malformed ID row")
        if row["id"] in result:
            raise ContractError(f"{owner}: duplicate ID {row['id']}")
        result[row["id"]] = row
    return result


def strings(value: Any, path: tuple[Any, ...] = ()):
    if isinstance(value, str):
        yield path, value
    elif isinstance(value, dict):
        for key, child in value.items():
            yield from strings(child, path + (key,))
    elif isinstance(value, list):
        for index, child in enumerate(value):
            yield from strings(child, path + (index,))


def reader_strings(value: Any, path: tuple[Any, ...]):
    if isinstance(value, str):
        yield path, value
    elif isinstance(value, list):
        for index, child in enumerate(value):
            yield from reader_strings(child, path + (index,))
    else:
        raise ContractError(f"reader texts contain a non-array/non-string at {pointer(path)}")


def event_overlay_support(path: tuple[Any, ...]) -> str:
    """The permissive built-in loader alone does not prove gate support."""
    from i18n_coverage_check import TEXT_CHOICE_KEYS, TEXT_EVENT_KEYS

    if not path or path[0] not in TEXT_EVENT_KEYS \
            or (path[0] == "choices" and (len(path) < 3 or path[2] not in TEXT_CHOICE_KEYS)):
        return "validator_contract_missing"
    return "builtin_overlay_static_only"


def unsupported_relationship_display_names(owner: str, row: dict[str, Any], file: str) -> list[dict[str, Any]]:
    """Record display copy embedded in gameplay payloads, without overlaying it."""
    result = []
    for path, text in strings(row):
        if len(path) == 5 and path[0] == "choices" and path[2] == "relationship_effects" \
                and path[4] == "name" and HANGUL.search(text):
            result.append({"kind": "unsupported_relationship_display_name",
                           "source_id": f"events:{owner}:{pointer(path)}", "source_path": file,
                           "path": pointer(path), "ko": text,
                           "detail": "Stored/displayed without a locale resolver; gameplay overlay remains forbidden."})
    return result


def get_at(value: Any, path: tuple[Any, ...]) -> Any:
    try:
        for key in path:
            value = value[key]
        return value
    except (KeyError, IndexError, TypeError):
        return None


def set_at(value: Any, path: tuple[Any, ...], text: str) -> None:
    for index, key in enumerate(path):
        last = index == len(path) - 1
        if isinstance(value, list):
            if not isinstance(key, int) or key < 0:
                raise ContractError("array path must be a nonnegative index")
            while len(value) <= key:
                value.append(None)
        elif not isinstance(value, dict) or not isinstance(key, str):
            raise ContractError("target container shape drift")
        if last:
            value[key] = text
        else:
            if get_at(value, (key,)) is None:
                value[key] = [] if isinstance(path[index + 1], int) else {}
            value = value[key]


def _safe_path(root: Path, relative: str) -> Path:
    path = root / relative
    if Path(relative).is_absolute() or ".." in Path(relative).parts:
        raise ContractError(f"unsafe path: {relative}")
    if root.resolve() not in path.resolve().parents:
        raise ContractError(f"path escapes checkout: {relative}")
    return path


def private_dir(root: Path, locale: str) -> Path:
    if locale not in LOCALES:
        raise ContractError("unsupported locale")
    result = subprocess.run(["git", "rev-parse", "--absolute-git-dir"], cwd=root,
                            capture_output=True, text=True, check=True)
    return Path(result.stdout.strip()) / "full-game-localization" / locale / PROMPT_VERSION


def collect(root: Path = ROOT) -> dict[str, Any]:
    """Collect source independently of targets; never infer coverage from a cache."""
    import ja_translation_pipeline as ja
    import demo_localization_scope as demo
    import story_demo_localization_audit as public
    from event_lifecycle import audit_author_only

    if root.resolve() != ROOT.resolve():
        raise ContractError("repository collectors require this tool's checkout")
    leaves: list[Leaf] = []
    source_files: set[str] = set()
    unsupported: list[dict[str, Any]] = []
    internal_ending_notes: list[dict[str, str]] = []
    public_pairs, public_errors, _ = public.ui_pairs()
    if public_errors:
        raise ContractError("public-demo protection source: " + "; ".join(public_errors))
    protected_ui = set(public_pairs) | {"김민준"}
    lifecycle = audit_author_only(root)
    if lifecycle.errors:
        raise ContractError("lifecycle: " + "; ".join(lifecycle.errors))
    author_only = set(lifecycle.exempt_ids)
    source_events: dict[str, Any] = {}
    source_endings: dict[str, Any] = {}
    source_catalog: dict[str, Any] = {}

    def add(group, owner, file, path, text, category, **kwargs):
        if not isinstance(text, str):
            raise ContractError(f"{file}:{owner}:{pointer(path)}: non-string text")
        if not text.strip():
            return
        if group == "events":
            kwargs["runtime_support"] = event_overlay_support(tuple(path))
        leaves.append(Leaf(group, owner, file, tuple(path), text, category, **kwargs))
        if leaves[-1].runtime_support == "validator_contract_missing":
            unsupported.append({"kind": "validator_contract_missing", "source_id": leaves[-1].id,
                                "source_path": file, "path": pointer(tuple(path)),
                                "detail": "Built-in loader permits this field, but i18n_coverage_check rejects it."})

    for file in sorted((root / "content/events").glob("*.json")):
        relative = file.relative_to(root).as_posix()
        source_files.add(relative)
        for eid, row in row_index(read_json(file), relative).items():
            if eid in source_events:
                raise ContractError(f"duplicate source event ID: {eid}")
            source_events[eid] = row
            unsupported.extend(unsupported_relationship_display_names(eid, row, relative))
            kwargs = {"lifecycle": "author_only" if eid in author_only else "shipping",
                      "protected": eid in public.EVENT_IDS}
            for field in ja.EVENT_TEXT_FIELDS:
                if field in row:
                    add("events", eid, relative, (field,), row[field], "event_standard", **kwargs)
            for field in ja.EVENT_DICT_FIELDS:
                if field in row:
                    if not isinstance(row[field], dict):
                        raise ContractError(f"{eid}:{field}: expected text dictionary")
                    for key, text in row[field].items():
                        add("events", eid, relative, (field, key), text, "event_standard", **kwargs)
            for index, choice in enumerate(row.get("choices", [])):
                if not isinstance(choice, dict):
                    raise ContractError(f"{eid}: malformed choice")
                for field in (*ja.CHOICE_TEXT_FIELDS, "foreshadow"):
                    if field in choice:
                        category = "choice_foreshadow" if field == "foreshadow" else "event_standard"
                        add("events", eid, relative, ("choices", index, field), choice[field], category, **kwargs)
                for field in ja.CHOICE_DICT_FIELDS:
                    if field in choice:
                        for key, text in choice[field].items():
                            add("events", eid, relative, ("choices", index, field, key), text, "event_standard", **kwargs)
            for field, value in row.items():
                if READER.fullmatch(field):
                    if not isinstance(value, dict) or "texts" not in value:
                        raise ContractError(f"{eid}:{field}: malformed reader")
                    for path, text in reader_strings(value["texts"], (field, "texts")):
                        add("events", eid, relative, path, text, "chapter5_reader", **kwargs)

    ending_file = "content/endings.json"
    source_files.add(ending_file)
    source_endings = row_index(read_json(root / ending_file), ending_file)
    for eid, row in source_endings.items():
        for field in ja.ENDING_TEXT_FIELDS:
            if field in row:
                if field == "condition":
                    note = Leaf("endings", eid, ending_file, (field,), row[field], "internal_metadata")
                    internal_ending_notes.append({"id": note.id, "source": note.source,
                                                  "source_sha256": note.source_sha256})
                    continue
                add("endings", eid, ending_file, (field,), row[field], "ending")
        for field in ja.ENDING_DICT_FIELDS:
            for key, text in row.get(field, {}).items():
                add("endings", eid, ending_file, (field, key), text, "ending")
    for section, (relative, fields) in ja.CATALOG_SOURCES.items():
        source_files.add(relative)
        source_catalog[section] = row_index(read_json(root / relative), relative)
        for eid, row in source_catalog[section].items():
            for field in fields:
                if field in row:
                    for path, text in strings(row[field], (section, eid, field)):
                        add("catalog", section + ":" + eid, relative, path, text, "catalog",
                            protected=(section, eid, field) == ("jobs", "job_01", "name"))

    ui = ja.collect_ui_inventory()
    unsupported.extend({"kind": "static_ui_contract", "detail": e} for e in ui.errors)
    ui_seen: set[str] = set()
    for entry in ui.entries:
        key = entry.context_id or entry.source
        add("ui", key, "runtime:static_ui", (key,), entry.source, "ui_static_context",
            protected=key in protected_ui, format_template=entry.format_template)
        ui_seen.add(key)
    _, runtime, errors = demo.build_scope()
    unsupported.extend({"kind": "demo_dynamic_contract", "detail": e} for e in errors)
    demo_keys = set(runtime["merged_pairs"])
    for key in sorted(demo_keys - ui_seen):
        add("ui", key, "runtime:demo_dynamic", (key,), key, "ui_demo_dynamic",
            protected=key in protected_ui, format_template="%" in key)
        ui_seen.add(key)

    # Literal pairs outside the old demo are candidates until their runtime
    # consumer is proven. Counting them does not declare the lookup supported.
    candidates: dict[str, list[str]] = defaultdict(list)
    for file in sorted((root / "content").rglob("*.json")):
        relative = file.relative_to(root).as_posix()
        if any(p.startswith("events_") for p in file.parts) or re.search(r"endings_[^.]+\.json$", file.name):
            continue
        if file.name in {"full_game_localization.json"}:
            continue
        value = read_json(file)
        pairs, pair_errors = demo.collect_json_suffix_pairs(value, relative)
        inline, inline_errors = demo.collect_json_inline_pairs(value, relative)
        unsupported.extend({"kind": "unresolved_json_pair", "detail": error}
                           for error in pair_errors + inline_errors)
        if pairs or inline:
            source_files.add(relative)
        for pair in pairs + inline:
            candidates[pair.korean].append(pair.source_id)
    for directory in ja.RUNTIME_DIRS:
        for file in sorted((root / directory).rglob("*.gd")):
            relative = file.relative_to(root).as_posix()
            source_files.add(relative)
            source = file.read_text(encoding="utf-8")
            for pattern in (demo.GD_SUFFIX_PAIR, demo.GD_T_ET_PAIR):
                for match in pattern.finditer(source):
                    korean = loads(match.group("ko"))
                    if isinstance(korean, str) and korean.strip():
                        candidates[korean].append(f"{relative}:{source.count(chr(10), 0, match.start()) + 1}")
            for match in re.finditer(r"\bis_english\s*\(", source):
                unsupported.append({"kind": "legacy_language_branch", "path": relative,
                                    "line": source.count("\n", 0, match.start()) + 1})
    for korean, locations in sorted(candidates.items()):
        if korean in ui_seen:
            continue
        add("ui_unverified", korean, locations[0], (korean,), korean, "ui_global_candidate",
            protected=korean in protected_ui, runtime_support="unverified_consumer")
        unsupported.append({"kind": "unverified_dynamic_pair", "source_id": leaves[-1].id,
                            "locations": sorted(set(locations))})
    source_files.update({"content/meta/event_lifecycle.json", "content/meta/demo_localization_scope.json",
                         "playtests/order124/StoryChoiceM1M6Playtest.gd"})
    if len({leaf.id for leaf in leaves}) != len(leaves):
        raise ContractError("duplicate collected leaf ID")
    hashes = {name: sha_file(root / name) for name in sorted(source_files)}
    return {"leaves": sorted(leaves, key=lambda leaf: leaf.id), "source_hashes": hashes,
            "source_manifest_sha256": digest(hashes), "unsupported": unsupported,
            "internal_ending_notes": internal_ending_notes,
            "events": source_events, "endings": source_endings, "catalog": source_catalog,
            "source_counts": {"packaged_events": len(source_events), "shipping_events": len(source_events) - len(author_only),
                              "author_only_events": len(author_only), "endings": len(source_endings),
                              "ui_static_context": len(ui.entries), "demo_dynamic_unique": len(demo_keys),
                              "demo_dynamic_overlap_static": len(demo_keys & {e.source for e in ui.entries})}}


def translation_errors(leaf: Leaf, locale: str, text: Any) -> list[str]:
    import ja_translation_pipeline as ja
    if leaf.group == "endings" and leaf.path == ("condition",):
        return ["internal ending condition is not player translation"]
    if locale not in LOCALES:
        return ["unsupported locale"]
    if not isinstance(text, str) or not text.strip():
        return ["blank/non-string translation"]
    if locale == "ja":
        errors = ja.validate_translation(ja.Entry(leaf.id, leaf.source, leaf.owner,
                                                 format_template=leaf.format_template), text)
        # Exact catalogue names may legitimately be all Latin. This does not
        # excuse English descriptions or partial brand-only translations.
        if leaf.group == "catalog":
            from zh_translation_audit import catalog_latin_only, CATALOG_YOUNG_ADULT_SOURCES
            if catalog_latin_only(leaf.source, text):
                errors = [e for e in errors if e != "no Japanese glyphs in translated Korean source"]
        if leaf.source.count("\n") != text.count("\n"):
            errors.append("newline mismatch")
        # Explicit Arabic digits remain exact; written counters are a reviewer gate.
        numeric = re.compile(r"(?<![\d.])[+-]?\d+(?:[,.]\d+)*")
        source_numbers = ja.PLACEHOLDER.sub("", leaf.source)
        target_numbers = ja.PLACEHOLDER.sub("", text)
        from zh_translation_audit import (
            _source_money_amounts, _target_money_amounts,
            _has_numeric_sign_prefix, MoneyAmount,
        )
        # Mixed Korean thousand/hundred-man notation is one won amount.
        # Match its value/currency, then normalize those exact spans so Japanese
        # comma grouping does not pretend to change the explicit digit contract.
        mixed_source = [amount for amount in _source_money_amounts(source_numbers)
            if source_numbers[amount.start:amount.end].endswith('원')
            and re.search(r'\d+\s*[천백]', source_numbers[amount.start:amount.end])]
        mixed_target = list(re.finditer(
            r"[+-]?\d+(?:,\d{3})*(?:億\s*\d+(?:,\d{3})*)?(?:千万|万|千)ウォン(?!円|韓元|韩元|元|ドル|ウォン)", target_numbers,
        ))
        consumed = []
        if '1인당 4만 5천원이 나왔다' in leaf.source:
            mixed_target.extend(re.finditer(
                r"[+-]?\d+万\d+千ウォン(?!円|韓元|韩元|元|ドル|ウォン)",
                target_numbers,
            ))
            mixed_target.sort(key=lambda item: item.start())
        for amount in mixed_source:
            value = amount.won
            required_plus = source_numbers[amount.start:amount.end].startswith('+')
            found = None
            for candidate in mixed_target:
                if candidate.start() in {start for start, _ in consumed}:
                    continue
                parsed = _target_money_amounts(candidate.group().replace('ウォン', '韓元'))
                if len(parsed) == 1 and parsed[0].won == value \
                        and candidate.group().startswith('+') == required_plus \
                        and not _has_numeric_sign_prefix(target_numbers, candidate.start()):
                    found = candidate
                    break
            if found is None:
                errors.append('mixed Korean thousand-hundred-man won amount/currency mismatch')
            else:
                consumed.append((found.start(), found.end()))
        # Keep the normalized amounts in the ordered numeric stream. Masking
        # them would let two correctly valued fees exchange their owners, or
        # let a mixed amount move across an ordinary number unnoticed.
        def normalized_money_numbers(value, spans):
            for span in sorted(spans, key=lambda item: item.start, reverse=True):
                value = value[:span.start] + format(span.won, 'f') + value[span.end:]
            return value
        source_numbers = normalized_money_numbers(source_numbers, mixed_source)
        target_numbers = normalized_money_numbers(target_numbers, [
            MoneyAmount(start, end, amount.won)
            for amount, (start, end) in zip(mixed_source, consumed)
        ]) if len(consumed) == len(mixed_source) else target_numbers
        # Korean mixed notation 5백만원 is 500万ウォン, not 5万ウォン.
        # Bind both the magnitude and currency before normalizing digits.
        for amount in re.finditer(r"(?<![\d.])(?P<number>[+-]?\d+)백만원", source_numbers):
            from zh_translation_audit import _has_numeric_sign_prefix
            raw = amount.group('number')
            normalized = ('+' if raw.startswith('+') else '') + str(int(raw) * 100)
            pattern = re.escape(normalized) + r"万ウォン"
            matches = list(re.finditer(pattern, target_numbers))
            if len(matches) != len(re.findall(re.escape(amount.group()), source_numbers)) or any(
                _has_numeric_sign_prefix(target_numbers, match.start())
                for match in matches
            ):
                errors.append("mixed Korean hundred-man won amount/currency mismatch")
        source_numbers = re.sub(r"(?<![\d.])([+-]?\d+)백만원",
                                lambda m: ('+' if m.group(1).startswith('+') else '') + str(int(m.group(1)) * 100) + '만원',
                                source_numbers)
        # A reunion's third WEEK Saturday is not necessarily the month's third
        # Saturday. Bind the whole calendar phrase before normalizing its native
        # ordinal; do not exempt arbitrary written numerals in Japanese prose.
        source_week = list(re.finditer(r"(?<![가-힣])다음 달 셋째 주 토요일", source_numbers))
        target_week = list(re.finditer(r"来月(?:の)?第(?:3|三)週(?:の)?土曜日", target_numbers))
        if source_week or target_week:
            if len(source_week) != len(target_week) or any(
                _has_numeric_sign_prefix(target_numbers, match.start())
                or re.search(r"再\s*$", target_numbers[:match.start()])
                for match in target_week
            ):
                errors.append("source-bound calendar week/day mismatch")
            source_numbers = source_numbers.replace("다음 달 셋째 주 토요일", "다음 달 3 주 토요일")
            target_numbers = re.sub(r"来月(?:の)?第三週(?:の)?土曜日",
                                    lambda match: match.group().replace("第三", "第3"), target_numbers)
        # Source 1인 5만 원 is a per-person fee, not a new one-person event.
        # Accept its native counter only next to the exact unsigned won fee.
        source_person_fee = list(re.finditer(r"(?<![가-힣\d])1인\s+5만\s*원", source_numbers))
        target_person_fee = list(re.finditer(
            r"(?<![0-9一二三四五六七八九十百千萬万億兆])(?:一|1)人(?:当たり)?\s*5万ウォン(?!円|韓元|韩元|元|ドル|ウォン)",
            target_numbers,
        ))
        if source_person_fee or target_person_fee:
            if len(source_person_fee) != len(target_person_fee) or any(
                _has_numeric_sign_prefix(value, match.start())
                for value, matches in ((source_numbers, source_person_fee), (target_numbers, target_person_fee))
                for match in matches
            ):
                errors.append("source-bound per-person won fee mismatch")
            for match in reversed(target_person_fee):
                value = match.group()
                if value.startswith("一"):
                    target_numbers = target_numbers[:match.start()] + "1" + value[1:] + target_numbers[match.end():]
        if leaf.group == "catalog":
            if leaf.source in CATALOG_YOUNG_ADULT_SOURCES:
                age_groups = list(re.finditer(r"(?<![0-9一二三四五六七八九十百千])20[・、/](?:\s*)30代(?!\d)", text))
                if len(age_groups) != 1:
                    errors.append("catalog age-group grammar mismatch")
                for age in re.finditer(r"[0-9一二三四五六七八九十百千]+\s*(?:代|歳)", text):
                    if not any(group.start() <= age.start() and age.end() <= group.end() for group in age_groups):
                        errors.append("catalog added age mismatch")
                source_numbers = source_numbers.replace("2030", "20 30")
                remainder = text
                for group in reversed(age_groups):
                    remainder = remainder[:group.start()] + " " * (group.end() - group.start()) + remainder[group.end():]
                if re.search(r"[二三四五六七八九十百千萬万億兆]", remainder):
                    errors.append("catalog added native number mismatch")
            for source, before, after in (
                ("2차전지주", "二次電池", "2次電池"),
                ("1인 가구", "一人暮らし", "1人暮らし"),
                ("2차 창업자 네트워크", "二度目", "2度目"),
            ):
                if leaf.source == source:
                    allowed = list(re.finditer(re.escape(before) + "|" + re.escape(after), target_numbers))
                    if len(allowed) != 1:
                        errors.append("catalog numeric expression count mismatch")
                    for value in allowed:
                        if re.search(r"[0-9一二三四五六七八九十百千萬万億兆]\s*$", target_numbers[:value.start()]):
                            errors.append("catalog native numeric prefix mismatch")
                    remainder = target_numbers
                    for value in reversed(allowed):
                        remainder = remainder[:value.start()] + " " * (value.end() - value.start()) + remainder[value.end():]
                    if re.search(r"[二三四五六七八九十百千萬万億兆]", remainder):
                        errors.append("catalog added native number mismatch")
                    target_numbers = re.sub(r"(?<![0-9一二三四五六七八九十百千萬万億兆])" + re.escape(before), after, target_numbers)
        if sorted(numeric.findall(source_numbers)) != sorted(numeric.findall(target_numbers)):
            errors.append("explicit numeric value/sign mismatch")
        if mixed_source and numeric.findall(source_numbers) != numeric.findall(target_numbers):
            errors.append("mixed Korean-won ordered numeric ownership mismatch")
    else:
        from zh_translation_audit import validate_text
        errors = validate_text(locale, leaf.id, leaf.source, text)
        if leaf.format_template:
            errors.extend(ja.ui_placeholder_errors(leaf.source, text))
    # StoryMode replaces each indexed slot exactly once, in source order, then
    # rejects any leftover c5read prefix. Generic printf/BBCode audits do not
    # recognize this runtime-owned syntax.
    source_slots = CHAPTER5_INLINE_SLOT.findall(leaf.source)
    target_slots = CHAPTER5_INLINE_SLOT.findall(text)
    if source_slots != target_slots or leaf.source.count("[[c5read:") != len(source_slots) \
            or text.count("[[c5read:") != len(target_slots):
        errors.append("Chapter 5 inline slot token/order/count mismatch")
    if not leaf.format_template:
        source_printf = [t for t in ja.PLACEHOLDER.findall(leaf.source) if t.startswith("%")]
        target_printf = [t for t in ja.PLACEHOLDER.findall(text) if t.startswith("%")]
        if source_printf != target_printf:
            errors.append("printf token order mismatch")
    return sorted(set(errors))


def retained_ending_notes(root: Path, locale: str, inventory: dict[str, Any]) -> dict[str, dict[str, str]]:
    """Keep the first pilot's unused notes byte-bound, outside accepted text."""
    path = root / "content/meta/full_game_localization.json"
    if not path.exists():
        if root.resolve() == ROOT.resolve():
            raise ContractError("retained internal metadata ledger disappeared")
        return {}
    ledger = read_json(path)
    records = ledger.get("retained_internal_metadata")
    if records is None:
        raise ContractError("retained internal metadata is missing")
    if not isinstance(records, dict) or set(records) != set(LOCALES) \
            or ledger.get("retained_internal_metadata_sha256") != digest(records):
        raise ContractError("retained internal metadata locale/checksum mismatch")
    if digest(records) != RETAINED_ENDING_NOTES_SHA256:
        raise ContractError("retained internal metadata historical fingerprint changed")
    for values in records.values():
        if not isinstance(values, dict):
            raise ContractError("retained internal metadata must be leaf receipts")
        for key, receipt in values.items():
            owner = key.split(":")[1] if isinstance(key, str) and key.count(":") == 2 else ""
            source = inventory["endings"].get(owner, {}).get("condition")
            if key != f"endings:{owner}:/condition" or not isinstance(source, str) \
                    or not isinstance(receipt, dict) or set(receipt) != {"source_sha256", "target_sha256"} \
                    or any(not isinstance(v, str) or not re.fullmatch(r"[a-f0-9]{64}", v) for v in receipt.values()):
                raise ContractError("retained internal metadata ID/hash shape mismatch")
            note = Leaf("endings", owner, "content/endings.json", ("condition",), source, "internal_metadata")
            if receipt["source_sha256"] != note.source_sha256:
                raise ContractError("retained internal metadata source changed")
    return records[locale]


def targets(root: Path, locale: str, inventory: dict[str, Any]) -> tuple[dict[str, Any], dict[str, str]]:
    """Load target arrays without last-row/last-file wins; reject gameplay keys."""
    documents: dict[str, Any] = {}
    event_files: dict[str, str] = {}
    retained_notes = retained_ending_notes(root, locale, inventory)
    observed_notes: set[str] = set()
    allowed: dict[tuple[str, str], set[tuple[Any, ...]]] = defaultdict(set)
    for leaf in inventory["leaves"]:
        allowed[(leaf.group, leaf.owner)].add(leaf.path)
    paths = sorted((root / f"content/events_{locale}").glob("*.json"))
    paths += [root / f"content/endings_{locale}.json", root / f"locale/catalog_{locale}.json",
              root / f"locale/ui_{locale}.json"]
    for file in paths:
        if not file.exists():
            continue
        relative = file.relative_to(root).as_posix()
        value = read_json(file)
        documents[relative] = value
        if file.parent.name.startswith("events_") or file.name.startswith("endings_"):
            group = "events" if file.parent.name.startswith("events_") else "endings"
            for eid, row in row_index(value, relative).items():
                if (group, eid) not in allowed:
                    raise ContractError(f"{relative}: extra target ID {eid}")
                if group == "events":
                    if eid in event_files:
                        raise ContractError(f"duplicate target event ID across files: {eid}")
                    event_files[eid] = relative
                paths_allowed = allowed[(group, eid)]
                if group == "endings" and "condition" in row:
                    key = f"endings:{eid}:/condition"
                    if key not in retained_notes or retained_notes[key]["target_sha256"] != digest(row["condition"]):
                        raise ContractError("new/changed internal ending note is not a translation")
                    observed_notes.add(key)
                    paths_allowed = paths_allowed | {("condition",)}
                validate_overlay(row, paths_allowed, inventory[group][eid])
        elif not isinstance(value, dict):
            raise ContractError(f"{relative}: expected dictionary")
        elif file.name.startswith("catalog_"):
            all_catalog_paths = {leaf.path for leaf in inventory["leaves"] if leaf.group == "catalog"}
            validate_overlay(value, all_catalog_paths, inventory["catalog"])
        elif any(not isinstance(text, str) or not text.strip() for text in value.values()):
            raise ContractError(f"{relative}: UI values must be nonblank strings")
    if observed_notes != set(retained_notes):
        raise ContractError("retained internal ending note disappeared")
    return documents, event_files


def validate_overlay(row: dict[str, Any], allowed: set[tuple[Any, ...]], source: dict[str, Any]) -> None:
    def walk(value: Any, path: tuple[Any, ...]):
        if path == ("id",):
            return
        if not path or any(p[:len(path)] == path for p in allowed):
            if isinstance(value, dict):
                for key, child in value.items():
                    walk(child, path + (key,))
                return
            if isinstance(value, list):
                source_array = get_at(source, path)
                if not isinstance(source_array, list) or len(value) != len(source_array):
                    raise ContractError("array length drift / incomplete translated array")
                if len(path) == 3 and path[0] in {"chapter5_causal_reads", "chapter5_finale_reads"} \
                        and path[1] == "texts":
                    # StoryMode rejects duplicate alternatives within each read
                    # source row, not repeated copy across unrelated rows.
                    if any(not isinstance(text, str) for text in value) or len(set(value)) != len(value):
                        raise ContractError("Chapter 5 reader alternatives must be distinct strings per row")
                for index, child in enumerate(value):
                    walk(child, path + (index,))
                return
            if path in allowed and isinstance(value, str) and value.strip():
                if len(path) == 4 and path[:2] == ("chapter5_finale_reads", "texts") \
                        and "[[c5read:" in value:
                    raise ContractError("Chapter 5 finale reader text cannot introduce an inline slot")
                return
        raise ContractError(f"overlay gameplay/extra/blank/shape field: {pointer(path)}")
    walk(row, ())


def target_location(leaf: Leaf, locale: str, event_files: dict[str, str]) -> tuple[str, tuple[Any, ...]]:
    if leaf.group == "events":
        relative = event_files.get(leaf.owner, f"content/events_{locale}/{Path(leaf.source_path).name}")
    elif leaf.group == "endings":
        relative = f"content/endings_{locale}.json"
    elif leaf.group == "catalog":
        relative = f"locale/catalog_{locale}.json"
    else:
        relative = f"locale/ui_{locale}.json"
    return relative, leaf.path


def target_value(leaf: Leaf, documents: dict[str, Any], locale: str, event_files: dict[str, str]) -> Any:
    relative, path = target_location(leaf, locale, event_files)
    value = documents.get(relative)
    if leaf.group in {"events", "endings"}:
        value = next((r for r in value or [] if r.get("id") == leaf.owner), None)
    return get_at(value, path)


def committed_receipts(root: Path, inventory: dict[str, Any], locale: str) -> dict[str, list[dict[str, str]]]:
    """Portable machine acceptance evidence, never a native-review verdict."""
    path = root / "content/meta/full_game_localization.json"
    if not path.exists():
        return {}
    ledger = read_json(path)
    if not isinstance(ledger, dict) or ledger.get("schema_version") != SCHEMA_VERSION \
            or ledger.get("prompt_version") != PROMPT_VERSION or ledger.get("native_review") != "OPEN":
        raise ContractError("committed localization ledger schema/prompt/native-review mismatch")
    accepted = ledger.get("accepted")
    if not isinstance(accepted, dict) or set(accepted) != set(LOCALES) \
            or ledger.get("accepted_sha256") != digest(accepted):
        raise ContractError("committed localization ledger locale/checksum mismatch")
    leaves = {leaf.id: leaf for leaf in inventory["leaves"]}
    for accepted_locale, values in accepted.items():
        if not isinstance(values, dict):
            raise ContractError("committed localization ledger locale must contain leaf receipts")
        for leaf_id, receipt in values.items():
            if leaf_id not in leaves or leaves[leaf_id].runtime_support != "builtin_overlay_static_only":
                raise ContractError(f"committed localization ledger unknown/unsupported leaf: {leaf_id}")
            if not isinstance(receipt, dict) or set(receipt) != {"source_sha256", "target_sha256"} \
                    or any(not isinstance(v, str) or not re.fullmatch(r"[a-f0-9]{64}", v) for v in receipt.values()):
                raise ContractError(f"committed localization ledger malformed hash: {accepted_locale}:{leaf_id}")
    return {leaf_id: [receipt] for leaf_id, receipt in accepted[locale].items()}


def status(root: Path, inventory: dict[str, Any], locale: str) -> dict[str, Any]:
    documents, event_files = targets(root, locale, inventory)
    groups: dict[str, Counter] = defaultdict(Counter)
    invalid = []
    receipts: dict[str, list[dict[str, str]]] = defaultdict(list, committed_receipts(root, inventory, locale))
    for path in sorted(private_dir(root, locale).glob("*.accepted.json")):
        receipt = read_json(path)
        if not isinstance(receipt, dict) or not isinstance(receipt.get("batch"), dict) \
                or not isinstance(receipt.get("translations"), dict):
            raise ContractError("corrupt accepted receipt")
        if receipt.get("receipt_sha256") != digest({k: v for k, v in receipt.items() if k != "receipt_sha256"}):
            raise ContractError("accepted receipt checksum drift")
        header = receipt.get("batch", {})
        if header.get("locale") != locale or header.get("prompt_version") != PROMPT_VERSION:
            raise ContractError("accepted receipt locale/prompt mismatch")
        for key, value in receipt.get("translations", {}).items():
            if not isinstance(value, dict) or set(value) != {"source_sha256", "target_sha256"} \
                    or any(not isinstance(v, str) or not re.fullmatch(r"[a-f0-9]{64}", v) for v in value.values()):
                raise ContractError("corrupt accepted leaf receipt")
            receipts[key].append(value)
    for leaf in inventory["leaves"]:
        counts = groups[leaf.category]
        counts["source"] += 1
        text = target_value(leaf, documents, locale, event_files)
        if text is None:
            counts["missing"] += 1
        else:
            counts["present"] += 1
            errors = translation_errors(leaf, locale, text)
            if errors:
                counts["invalid"] += 1
                invalid.append({"id": leaf.id, "errors": errors})
            else:
                counts["machine_valid"] += 1
                if any(r.get("source_sha256") == leaf.source_sha256 and
                       r.get("target_sha256") == digest(text) for r in receipts.get(leaf.id, [])):
                    counts["receipted_current_source"] += 1
                elif leaf.id in receipts:
                    counts["stale_receipt"] += 1
    return {"locale": locale, "status": "INCOMPLETE", "native_review": "OPEN",
            "groups": {key: dict(value) for key, value in groups.items()}, "invalid": invalid,
            "note": "Existing target presence does not prove source freshness or native acceptance."}


def make_batch(inventory: dict[str, Any], locale: str, selected: list[Leaf], revision: str,
               documents: dict[str, Any], event_files: dict[str, str]) -> list[dict[str, Any]]:
    if not selected or len({leaf.id for leaf in selected}) != len(selected):
        raise ContractError("empty/duplicate selection")
    rows = []
    for leaf in selected:
        value = asdict(leaf)
        value.update({"id": leaf.id, "source_sha256": leaf.source_sha256, "locale": locale,
                      "prompt_version": PROMPT_VERSION,
                      "target_path": target_location(leaf, locale, event_files)[0],
                      "previous_target_sha256": digest(target_value(leaf, documents, locale, event_files))})
        value["path"] = list(leaf.path)
        rows.append(value)
    header = {"kind": "full_game_localization_batch", "schema_version": SCHEMA_VERSION,
              "locale": locale, "source_revision": revision, "prompt_version": PROMPT_VERSION,
              "source_manifest_sha256": inventory["source_manifest_sha256"],
              "selection_sha256": digest(rows), "count": len(rows), "source_language": "ko",
              "native_review": "OPEN"}
    header["batch_id"] = digest(header)
    return [header, *rows]


def read_jsonl(path: Path) -> list[dict[str, Any]]:
    rows = [loads(line) for line in path.read_text(encoding="utf-8").splitlines() if line.strip()]
    if not rows or any(not isinstance(row, dict) for row in rows):
        raise ContractError("JSONL requires object rows and a manifest")
    return rows


def check_batch(inventory: dict[str, Any], batch: list[dict[str, Any]], response: list[dict[str, Any]]) -> dict[str, str]:
    if not batch or not response:
        raise ContractError("empty batch/response")
    header, rows = batch[0], batch[1:]
    if set(header) != {"kind", "schema_version", "locale", "source_revision", "prompt_version",
                       "source_manifest_sha256", "selection_sha256", "count", "source_language",
                       "native_review", "batch_id"} or header.get("kind") != "full_game_localization_batch":
        raise ContractError("invalid manifest shape")
    if not re.fullmatch(r"[0-9a-f]{40}", str(header.get("source_revision", ""))):
        raise ContractError("source revision must be exact Git commit")
    if header != response[0]:
        raise ContractError("response manifest differs from batch")
    unsigned = {k: v for k, v in header.items() if k != "batch_id"}
    if header.get("batch_id") != digest(unsigned) or header.get("selection_sha256") != digest(rows):
        raise ContractError("batch manifest or selection checksum drift")
    if header.get("schema_version") != SCHEMA_VERSION or header.get("prompt_version") != PROMPT_VERSION:
        raise ContractError("stale schema/prompt version")
    if header.get("source_language") != "ko" or header.get("locale") not in LOCALES \
            or header.get("native_review") != "OPEN":
        raise ContractError("wrong source/target locale")
    if header.get("source_manifest_sha256") != inventory["source_manifest_sha256"]:
        raise ContractError("stale source manifest")
    current = {leaf.id: leaf for leaf in inventory["leaves"]}
    ids = [row.get("id") for row in rows]
    if any(not isinstance(identifier, str) for identifier in ids) \
            or len(set(ids)) != len(ids) or header.get("count") != len(rows) or not rows:
        raise ContractError("empty/duplicate/miscounted source batch")
    result = {}
    for row in rows:
        leaf = current.get(row.get("id"))
        if leaf is None or row.get("source_sha256") != leaf.source_sha256:
            raise ContractError("unknown/stale source leaf")
        if set(row) != set(asdict(leaf)) | {"id", "source_sha256", "locale", "prompt_version",
                                          "target_path", "previous_target_sha256"}:
            raise ContractError("source row has extra/gameplay or missing fields")
        for key, value in asdict(leaf).items():
            if key == "path":
                value = list(value)
            if row.get(key) != value:
                raise ContractError(f"source metadata drift: {leaf.id}:{key}")
        if row.get("locale") != header["locale"] or row.get("prompt_version") != PROMPT_VERSION:
            raise ContractError("mixed locale/prompt in source batch")
    for row in response[1:]:
        if set(row) != {"id", "locale", "source_sha256", "prompt_version", "text"}:
            raise ContractError("response has extra/gameplay or missing fields")
        identifier = row["id"]
        if not isinstance(identifier, str) or identifier not in ids or identifier in result:
            raise ContractError("extra/duplicate response ID")
        leaf = current[identifier]
        if (row["locale"], row["source_sha256"], row["prompt_version"]) != (
                header["locale"], leaf.source_sha256, PROMPT_VERSION):
            raise ContractError("response locale/source/prompt binding drift")
        errors = translation_errors(leaf, header["locale"], row["text"])
        if errors:
            raise ContractError(f"{identifier}: " + "; ".join(errors))
        result[identifier] = row["text"]
    if set(result) != set(ids):
        raise ContractError("missing response IDs")
    return result


def merge_selected(inventory: dict[str, Any], batch: list[dict[str, Any]], translations: dict[str, str],
                   documents: dict[str, Any], event_files: dict[str, str], replace_existing: bool = False) -> dict[str, Any]:
    locale = batch[0]["locale"]
    leaves = {leaf.id: leaf for leaf in inventory["leaves"]}
    modified = {}
    allowed: dict[tuple[str, str], set[tuple[Any, ...]]] = defaultdict(set)
    for leaf in leaves.values():
        allowed[(leaf.group, leaf.owner)].add(leaf.path)
    for row in batch[1:]:
        leaf = leaves[row["id"]]
        if leaf.group == "endings" and leaf.path == ("condition",):
            raise ContractError("internal ending metadata cannot be imported as translation")
        if leaf.runtime_support != "builtin_overlay_static_only":
            raise ContractError(f"unsupported runtime/validator contract cannot be accepted: {leaf.runtime_support}")
        before = target_value(leaf, documents, locale, event_files)
        if digest(before) != row["previous_target_sha256"]:
            raise ContractError("target changed since export")
        text = translations[leaf.id]
        if leaf.protected and before != text:
            raise ContractError("public-demo translation is protected")
        if before is not None and before != text and not replace_existing:
            raise ContractError("existing target requires explicit --replace-existing")
        relative, path = target_location(leaf, locale, event_files)
        if row["target_path"] != relative:
            raise ContractError("target path drift")
        if before == text:
            continue
        if relative not in modified:
            modified[relative] = copy.deepcopy(documents.get(relative, [] if leaf.group in {"events", "endings"} else {}))
        target = modified[relative]
        if leaf.group in {"events", "endings"}:
            target_row = next((r for r in target if r["id"] == leaf.owner), None)
            if target_row is None:
                target_row = {"id": leaf.owner}
                target.append(target_row)
            target = target_row
            if path[0] == "choices" and "choices" not in target:
                target["choices"] = [{} for _ in inventory["events"][leaf.owner].get("choices", [])]
        set_at(target, path, text)
    # Validate every changed container after the whole batch, not per leaf.
    # None holes reject partially translated arrays (tags / reader texts).
    for relative, value in modified.items():
        if isinstance(value, list):
            group = "events" if "/events_" in relative else "endings"
            for eid, row in row_index(value, relative).items():
                paths_allowed = allowed[(group, eid)]
                if group == "endings" and "condition" in row:
                    # targets() already verified the historical receipt. A text
                    # merge may preserve this old note, never add or change it.
                    previous = next((r for r in documents.get(relative, []) if r.get("id") == eid), {})
                    if "condition" not in previous or previous["condition"] != row["condition"]:
                        raise ContractError("internal ending metadata changed during merge")
                    paths_allowed = paths_allowed | {("condition",)}
                validate_overlay(row, paths_allowed, inventory[group][eid])
        else:
            if "/catalog_" in relative:
                catalog_paths = {l.path for l in leaves.values() if l.group == "catalog"}
                validate_overlay(value, catalog_paths, inventory["catalog"])
            elif any(not isinstance(text, str) or not text.strip() for text in value.values()):
                raise ContractError("UI values must be nonblank strings")
    return modified


def atomic_json(path: Path, value: Any) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    with tempfile.NamedTemporaryFile(mode="w", encoding="utf-8", dir=path.parent,
                                     prefix=".localization-", delete=False) as stream:
        temporary = Path(stream.name)
        json.dump(value, stream, ensure_ascii=False, indent=2)
        stream.write("\n")
    os.replace(temporary, path)


def main(argv=None) -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("command", choices=("inventory", "export", "check", "import"))
    parser.add_argument("--locale", choices=LOCALES, default="ja")
    parser.add_argument("--group", choices=GROUPS)
    parser.add_argument("--ids", help="comma-separated source root IDs; UI uses the exact Korean key")
    parser.add_argument("--leaf-ids", help="JSON array file of exact collected leaf IDs")
    parser.add_argument("--limit", type=int, default=80)
    parser.add_argument("--batch", type=Path)
    parser.add_argument("--response", type=Path)
    parser.add_argument("--output", type=Path)
    parser.add_argument("--accept", action="store_true")
    parser.add_argument("--replace-existing", action="store_true")
    parser.add_argument("--include-leaves", action="store_true")
    args = parser.parse_args(argv)
    try:
        inventory = collect()
        if args.command == "inventory":
            output = {"schema_version": SCHEMA_VERSION, "prompt_version": PROMPT_VERSION,
                      "source_counts": inventory["source_counts"],
                      "source_leaf_categories": dict(Counter(l.category for l in inventory["leaves"])),
                      "source_lifecycle_leaves": dict(Counter(l.lifecycle for l in inventory["leaves"])),
                      "source_manifest_sha256": inventory["source_manifest_sha256"],
                      "internal_ending_notes": inventory["internal_ending_notes"],
                      "unsupported": inventory["unsupported"],
                      "unsupported_relationship_display_names": {
                          "occurrences": sum(u["kind"] == "unsupported_relationship_display_name" for u in inventory["unsupported"]),
                          "unique_korean": len({u["ko"] for u in inventory["unsupported"] if u["kind"] == "unsupported_relationship_display_name"}),
                          "scope": "Outside leaf denominator; needs a locale resolver, not gameplay overlay translation."},
                      "target": status(ROOT, inventory, args.locale),
                      "full_game_status": "INCOMPLETE", "human_gate": "OPEN",
                      "coverage_boundary": "Global pair candidates are source-discovered, not proven runtime exposure; unresolved consumers stay unsupported.",
                      "numeric_boundary": "Japanese explicit-digit checks are conservative; written numbers and implicit units need source review and may be reported as unresolved invalid rows."}
            if args.include_leaves:
                output["leaves"] = [{**asdict(l), "id": l.id, "source_sha256": l.source_sha256} for l in inventory["leaves"]]
            if args.output:
                atomic_json(args.output, output)
            else:
                print(json.dumps(output, ensure_ascii=False, indent=2))
            return 0
        documents, event_files = targets(ROOT, args.locale, inventory)
        if args.command == "export":
            if not args.group or not (args.ids or args.leaf_ids):
                raise ContractError("bounded export requires --group and --ids/--leaf-ids")
            ids = set(args.ids.split(",")) if args.ids else set()
            exact = set(read_json(Path(args.leaf_ids))) if args.leaf_ids else set()
            selected = [l for l in inventory["leaves"] if l.group == args.group and (l.owner in ids or l.id in exact)]
            if ids - {l.owner for l in selected} or exact - {l.id for l in selected}:
                raise ContractError("selection contains unknown IDs")
            if args.limit < 1 or len(selected) > args.limit:
                raise ContractError(f"selection has {len(selected)} leaves, limit={args.limit}")
            revision = subprocess.check_output(["git", "rev-parse", "HEAD"], cwd=ROOT, text=True).strip()
            batch = make_batch(inventory, args.locale, selected, revision, documents, event_files)
            out = args.output or private_dir(ROOT, args.locale) / (batch[0]["batch_id"] + ".source.jsonl")
            if out.exists():
                raise ContractError("export output already exists; preserve the previous batch")
            out.parent.mkdir(parents=True, exist_ok=True)
            out.write_text("".join(json.dumps(row, ensure_ascii=False) + "\n" for row in batch), encoding="utf-8")
            print(f"FULL_LOCALIZATION_BATCH_EXPORTED locale={args.locale} leaves={len(selected)} path={out} full_status=INCOMPLETE")
            return 0
        if not args.batch or not args.response:
            raise ContractError("check/import requires --batch and --response")
        batch, response = read_jsonl(args.batch), read_jsonl(args.response)
        if batch[0].get("locale") != args.locale:
            raise ContractError("CLI locale differs from batch")
        accepted = check_batch(inventory, batch, response)
        modified = merge_selected(inventory, batch, accepted, documents, event_files, args.replace_existing)
        if args.command == "import":
            if not args.accept:
                raise ContractError("import requires explicit --accept after Korean-source review")
            for relative in modified:
                path = _safe_path(ROOT, relative)
                current = read_json(path) if path.exists() else None
                if current != documents.get(relative):
                    raise ContractError("target file changed during validation")
            for relative, value in modified.items():
                atomic_json(_safe_path(ROOT, relative), value)
            receipt = {"batch": batch[0], "state": "accepted_machine_validated", "native_review": "OPEN",
                       "translations": {key: {"source_sha256": next(l.source_sha256 for l in inventory["leaves"] if l.id == key),
                                              "target_sha256": digest(text)} for key, text in accepted.items()}}
            receipt["receipt_sha256"] = digest(receipt)
            atomic_json(private_dir(ROOT, args.locale) / (batch[0]["batch_id"] + ".accepted.json"), receipt)
        print(f"FULL_LOCALIZATION_BATCH_VALID locale={args.locale} leaves={len(accepted)} changed_files={len(modified)} action={args.command} full_status=INCOMPLETE human_gate=OPEN")
        return 0
    except (ContractError, OSError, ValueError, subprocess.CalledProcessError) as exc:
        print(f"FULL_LOCALIZATION_FAIL {exc}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
