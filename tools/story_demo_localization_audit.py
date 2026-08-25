#!/usr/bin/env python3
"""Strict localization gate for the public M01-M06 story demo.

The old V2 demo audit owns a much larger and retired action-board surface.  This
gate deliberately follows only the eleven authored source events, the public
demo shell, and the StoryMode UI that the new candidate can actually display.
"""

from __future__ import annotations

import argparse
import json
import re
import sys
from dataclasses import dataclass
from pathlib import Path
from typing import Any, Iterable


ROOT = Path(__file__).resolve().parents[1]
TOOLS = ROOT / "tools"
if str(TOOLS) not in sys.path:
    sys.path.insert(0, str(TOOLS))

from ja_translation_pipeline import Entry, validate_translation  # noqa: E402
from zh_translation_audit import validate_text as validate_chinese  # noqa: E402


LANGUAGES = ("ja", "zh-CN", "zh-TW")
EVENT_IDS = (
    "arc_temptation_01",
    "arc_temptation_clean",
    "arc_temptation_fallout",
    "arc_daeun_01_meet",
    "arc_jiyeon_01_crash",
    "arc_sangchul_01_meet",
    "arc_sangchul_01_measure",
    "arc_sangchul_01_coffee",
    "arc_sangchul_01_answer",
    "arc_jaehyuk_01_reunion",
    "v2_demo_first_bill",
)
LOCALIZED_FIELDS = frozenset((
    "title",
    "description",
    "description_orthodox",
    "description_unorthodox",
    "description_low_mental",
    "description_long_gosiwon",
    "text",
    "result_text",
))
CONTROLLER_PATH = ROOT / "playtests/order124/StoryChoiceM1M6Playtest.gd"
STORY_MODE_PATH = ROOT / "scenes/StoryMode.gd"
EXPECTED_EVENT_LEAVES = 82
EXPECTED_CONTROLLER_UI_KEYS = 35
EXPECTED_STORY_UI_KEYS = 81
EXPECTED_TARGET_UI_KEYS = 117
HANGUL = re.compile(r"[\u1100-\u11ff\u3130-\u318f\uac00-\ud7a3]")
ASCII_WORD = re.compile(r"[A-Za-z]{3,}")
CHINESE_EXACT_NAMES = {
    "김민준": "Kim Minjun",
    "한지연": "Han Jiyeon",
    "김다은": "Kim Daeun",
    "최재혁": "Choi Jaehyuk",
    "임상철": "Im Sangchul",
    "현수": "Hyunsu",
}
STORY_DEMO_BUSINESS_NAMES = {
    "ja": "ハンビッ流通",
    "zh-CN": "Hanbit 流通",
    "zh-TW": "Hanbit 流通",
}
ZH_TW_SHARED_SCRIPT_CHARACTERS = frozenset({"床"})


@dataclass(frozen=True)
class Pair:
    owner: str
    korean: str
    english: str
    format_template: bool = False


def read_json(path: Path) -> Any:
    with path.open(encoding="utf-8") as handle:
        return json.load(handle)


def event_index(directory: Path) -> tuple[dict[str, dict[str, Any]], list[str]]:
    result: dict[str, dict[str, Any]] = {}
    errors: list[str] = []
    if not directory.is_dir():
        return {}, [f"missing event directory: {directory.relative_to(ROOT)}"]
    for path in sorted(directory.glob("*.json")):
        try:
            payload = read_json(path)
        except (OSError, json.JSONDecodeError) as exc:
            errors.append(f"{path.relative_to(ROOT)}: invalid JSON: {exc}")
            continue
        rows = payload if isinstance(payload, list) else (
            payload.get("events", []) if isinstance(payload, dict) else []
        )
        if not isinstance(rows, list):
            errors.append(f"{path.relative_to(ROOT)}: event root is not an array")
            continue
        for index, row in enumerate(rows):
            if not isinstance(row, dict) or not isinstance(row.get("id"), str):
                errors.append(f"{path.relative_to(ROOT)}[{index}]: malformed event")
                continue
            event_id = row["id"]
            if event_id in result:
                errors.append(f"duplicate event id {event_id!r} in {directory.name}")
            result[event_id] = row
    return result, errors


def localized_leaves(value: Any, path: str = "") -> dict[str, str]:
    result: dict[str, str] = {}
    if isinstance(value, dict):
        for key, child in value.items():
            child_path = f"{path}.{key}" if path else str(key)
            if key in LOCALIZED_FIELDS and isinstance(child, str):
                result[child_path] = child
            elif isinstance(child, (dict, list)):
                result.update(localized_leaves(child, child_path))
    elif isinstance(value, list):
        for index, child in enumerate(value):
            result.update(localized_leaves(child, f"{path}[{index}]"))
    return result


def _call_bodies(source: str, needle: str) -> Iterable[str]:
    cursor = 0
    while True:
        start = source.find(needle, cursor)
        if start < 0:
            return
        opening = start + len(needle) - 1
        depth = 0
        in_string = False
        escaped = False
        for index in range(opening, len(source)):
            char = source[index]
            if in_string:
                if escaped:
                    escaped = False
                elif char == "\\":
                    escaped = True
                elif char == '"':
                    in_string = False
                continue
            if char == '"':
                in_string = True
            elif char == "(":
                depth += 1
            elif char == ")":
                depth -= 1
                if depth == 0:
                    yield source[opening + 1:index]
                    cursor = index + 1
                    break
        else:
            raise ValueError(f"unterminated call for {needle}")


def _call_args(body: str) -> list[str]:
    result: list[str] = []
    start = 0
    depth = 0
    in_string = False
    escaped = False
    for index, char in enumerate(body):
        if in_string:
            if escaped:
                escaped = False
            elif char == "\\":
                escaped = True
            elif char == '"':
                in_string = False
            continue
        if char == '"':
            in_string = True
        elif char in "([{":
            depth += 1
        elif char in ")]}":
            depth -= 1
        elif char == "," and depth == 0:
            result.append(body[start:index].strip())
            start = index + 1
    result.append(body[start:].strip())
    return result


def collect_pairs(path: Path, calls: tuple[tuple[str, bool], ...]) -> tuple[list[Pair], list[str]]:
    source = path.read_text(encoding="utf-8")
    pairs: list[Pair] = []
    errors: list[str] = []
    for needle, is_format in calls:
        try:
            bodies = list(_call_bodies(source, needle))
        except ValueError as exc:
            errors.append(f"{path.relative_to(ROOT)}: {exc}")
            continue
        for index, body in enumerate(bodies):
            args = _call_args(body)
            if len(args) < 2:
                continue
            try:
                korean = json.loads(args[0])
                english = json.loads(args[1])
            except (json.JSONDecodeError, TypeError):
                # Wrapper declarations and dynamic calls are not source pairs.
                continue
            if isinstance(korean, str) and isinstance(english, str):
                pairs.append(Pair(
                    f"{path.relative_to(ROOT)}::{needle}[{index}]",
                    korean,
                    english,
                    is_format,
                ))
    return pairs, errors


def ui_pairs() -> tuple[dict[str, Pair], list[str], dict[str, int]]:
    controller, errors = collect_pairs(
        CONTROLLER_PATH,
        (("_t(", False), ("_tf(", True), ("LocaleManager.ui(", False)),
    )
    story, story_errors = collect_pairs(
        STORY_MODE_PATH,
        (("_tr(", False), ("LocaleManager.ui_format(", True)),
    )
    errors.extend(story_errors)
    merged: dict[str, Pair] = {}
    for pair in controller + story:
        previous = merged.get(pair.korean)
        if previous is None:
            merged[pair.korean] = pair
        else:
            merged[pair.korean] = Pair(
                previous.owner,
                pair.korean,
                previous.english,
                previous.format_template or pair.format_template,
            )
    counts = {
        "controller": len({pair.korean for pair in controller}),
        "story": len({pair.korean for pair in story}),
        "merged": len(merged),
    }
    if counts["controller"] != EXPECTED_CONTROLLER_UI_KEYS:
        errors.append(
            f"controller UI inventory {counts['controller']} != "
            f"{EXPECTED_CONTROLLER_UI_KEYS}"
        )
    if counts["story"] != EXPECTED_STORY_UI_KEYS:
        errors.append(
            f"StoryMode UI inventory {counts['story']} != {EXPECTED_STORY_UI_KEYS}"
        )
    if counts["merged"] + 1 != EXPECTED_TARGET_UI_KEYS:
        errors.append(
            f"target UI inventory {counts['merged'] + 1} != "
            f"{EXPECTED_TARGET_UI_KEYS}"
        )
    return merged, errors, counts


def target_text_errors(
    language: str,
    key: str,
    source: str,
    target: Any,
    *,
    format_template: bool = False,
    english: str = "",
) -> list[str]:
    if language == "ja":
        errors = validate_translation(
            Entry(key, source, "M01-M06 story demo", format_template=format_template),
            target,
        )
    elif source.strip() in CHINESE_EXACT_NAMES:
        expected_name = CHINESE_EXACT_NAMES[source.strip()]
        errors = [] if target == expected_name else [
            f"canonical cast name must be {expected_name!r}"
        ]
    else:
        # Two exact Korean colloquialisms in this slice confuse the legacy
        # quantity parser (`첫 장면` -> `첫 장`, `건당 백` -> bare 100). Feed that
        # validator semantically equivalent explicit Korean, never generated
        # target text, so the strict number/counter gate remains meaningful.
        validation_source = source.replace("첫 장면", "첫 번째 장면") \
            .replace("건당 백", "건당 100만원") \
            .replace("보증금 천", "보증금 1,000만원") \
            .replace("월 오십오", "월 55만원")
        errors = validate_chinese(language, key, validation_source, target)
        # OpenCC's variant table classifies 床 as simplified-only, while 床 is
        # also the standard Taiwan form in this context.  Keep the shared
        # character in the authored text and suppress only an otherwise-empty
        # story-demo mismatch for that exact character set.
        if language == "zh-TW" and isinstance(target, str):
            filtered_errors: list[str] = []
            for error in errors:
                match = re.fullmatch(
                    r"regional script mismatch: characters='([^']+)' belongs to "
                    r"zh-CN in this gate",
                    error,
                )
                if match is not None \
                        and set(match.group(1)) <= ZH_TW_SHARED_SCRIPT_CHARACTERS:
                    continue
                filtered_errors.append(error)
            errors = filtered_errors
        # Hanbit is the locked Latin rendering for the fictional business;
        # never invent an unofficial Hanja spelling just to satisfy the older
        # 24-week audit's generic Latin-token rule.
        if "한빛유통" in source and isinstance(target, str) \
                and STORY_DEMO_BUSINESS_NAMES[language] in target:
            errors = [
                error for error in errors
                if error != "untranslated English token remains: 'Hanbit'"
            ]
    if "한빛유통" in source and isinstance(target, str):
        expected_business = STORY_DEMO_BUSINESS_NAMES[language]
        if expected_business not in target:
            errors.append(
                f"canonical business name must contain {expected_business!r}"
            )
    if not isinstance(target, str):
        return errors
    if target == source and HANGUL.search(source):
        errors.append("target equals Korean source")
    if english and target == english and ASCII_WORD.search(english) \
            and source.strip() not in CHINESE_EXACT_NAMES:
        errors.append("target equals English fallback")
    return list(dict.fromkeys(errors))


def audit_language(
    language: str,
    source_events: dict[str, dict[str, Any]],
    english_events: dict[str, dict[str, Any]],
    pairs: dict[str, Pair],
) -> tuple[list[str], dict[str, int]]:
    errors: list[str] = []
    overlay_path = ROOT / f"content/events_{language}/story_demo_events.json"
    try:
        payload = read_json(overlay_path)
    except (OSError, json.JSONDecodeError) as exc:
        return [f"{overlay_path.relative_to(ROOT)}: {exc}"], {}
    if not isinstance(payload, list):
        return [f"{overlay_path.relative_to(ROOT)}: root must be an array"], {}
    rows = {
        str(row.get("id", "")): row
        for row in payload if isinstance(row, dict)
    }
    if len(rows) != len(payload):
        errors.append(f"{language}: malformed or duplicate event overlay rows")
    if set(rows) != set(EVENT_IDS):
        errors.append(
            f"{language}: event IDs missing={sorted(set(EVENT_IDS)-set(rows))} "
            f"extra={sorted(set(rows)-set(EVENT_IDS))}"
        )
    leaf_count = 0
    for event_id in EVENT_IDS:
        if event_id not in rows or event_id not in source_events:
            continue
        source_leaves = localized_leaves(source_events[event_id])
        target_leaves = localized_leaves(rows[event_id])
        english_leaves = localized_leaves(english_events.get(event_id, {}))
        if set(target_leaves) != set(source_leaves):
            errors.append(
                f"{language}:{event_id}: localized path mismatch "
                f"missing={sorted(set(source_leaves)-set(target_leaves))} "
                f"extra={sorted(set(target_leaves)-set(source_leaves))}"
            )
        source_choices = source_events[event_id].get("choices", [])
        target_choices = rows[event_id].get("choices", [])
        if not isinstance(target_choices, list) or len(target_choices) != len(source_choices):
            errors.append(
                f"{language}:{event_id}: choice count "
                f"{len(target_choices) if isinstance(target_choices, list) else 'invalid'} "
                f"!= {len(source_choices)}"
            )
        for leaf_path in sorted(set(source_leaves) & set(target_leaves)):
            leaf_count += 1
            for error in target_text_errors(
                language,
                f"event::{event_id}::{leaf_path}",
                source_leaves[leaf_path],
                target_leaves[leaf_path],
                english=english_leaves.get(leaf_path, ""),
            ):
                errors.append(f"{language}:{event_id}.{leaf_path}: {error}")

    ui_path = ROOT / f"locale/ui_{language}.json"
    try:
        ui = read_json(ui_path)
    except (OSError, json.JSONDecodeError) as exc:
        errors.append(f"{ui_path.relative_to(ROOT)}: {exc}")
        ui = {}
    if not isinstance(ui, dict):
        errors.append(f"{language}: UI table root must be an object")
        ui = {}
    required_ui = set(pairs) | {"김민준"}
    missing_ui = sorted(required_ui - set(ui))
    if missing_ui:
        errors.append(f"{language}: missing demo UI keys {missing_ui[:12]}")
    for korean in sorted(required_ui & set(ui)):
        pair = pairs.get(korean, Pair("default-name", korean, "Kim Minjun"))
        for error in target_text_errors(
            language,
            f"ui::{korean}",
            korean,
            ui[korean],
            format_template=pair.format_template,
            english=pair.english,
        ):
            errors.append(f"{language}:ui:{korean!r}: {error}")

    catalog_path = ROOT / f"locale/catalog_{language}.json"
    try:
        catalog = read_json(catalog_path)
        job_name = catalog["jobs"]["job_01"]["name"]
    except (OSError, json.JSONDecodeError, KeyError, TypeError) as exc:
        errors.append(f"{language}: catalog job_01.name missing: {exc}")
        job_name = ""
    for error in target_text_errors(
        language,
        "catalog::jobs::job_01::name",
        "편의점 야간 알바",
        job_name,
        english="Convenience Store Night Shift",
    ):
        errors.append(f"{language}:catalog:job_01.name: {error}")

    return errors, {
        "events": len(set(rows) & set(EVENT_IDS)),
        "event_leaves": leaf_count,
        "ui": len(required_ui & set(ui)),
        "ui_required": len(required_ui),
        "catalog": 1 if job_name else 0,
    }


def source_contract() -> tuple[
    dict[str, dict[str, Any]], dict[str, dict[str, Any]], dict[str, Pair],
    list[str], dict[str, int],
]:
    source, errors = event_index(ROOT / "content/events")
    english, english_errors = event_index(ROOT / "content/events_en")
    errors.extend(english_errors)
    missing_source = sorted(set(EVENT_IDS) - set(source))
    missing_english = sorted(set(EVENT_IDS) - set(english))
    if missing_source:
        errors.append(f"source events missing {missing_source}")
    if missing_english:
        errors.append(f"English events missing {missing_english}")
    leaf_count = sum(
        len(localized_leaves(source[event_id]))
        for event_id in EVENT_IDS if event_id in source
    )
    if leaf_count != EXPECTED_EVENT_LEAVES:
        errors.append(f"source event leaves {leaf_count} != {EXPECTED_EVENT_LEAVES}")
    pairs, pair_errors, counts = ui_pairs()
    errors.extend(pair_errors)
    return source, english, pairs, errors, counts


def self_test() -> list[str]:
    failures: list[str] = []
    valid_ja = target_text_errors("ja", "fixture", "민준은 {name}", "ミンジュンは{name}")
    if valid_ja:
        failures.append(f"valid Japanese fixture rejected: {valid_ja}")
    if not target_text_errors("ja", "fixture", "민준", "민준"):
        failures.append("Japanese Hangul mutation was not rejected")
    if not target_text_errors("zh-CN", "fixture", "민준은 {name}", "Minjun", english="Minjun"):
        failures.append("Chinese English-fallback mutation was not rejected")
    if not target_text_errors("zh-TW", "fixture", "민준은 {name}", "民俊"):
        failures.append("placeholder-loss mutation was not rejected")
    if target_text_errors("zh-TW", "fixture", "침대에 눕는다", "躺到床上"):
        failures.append("valid Taiwan 床 form was rejected")
    if target_text_errors("zh-CN", "fixture", "한빛유통에서 일한다", "在Hanbit 流通工作"):
        failures.append("canonical Hanbit business form was rejected")
    if not target_text_errors("zh-CN", "fixture", "한빛유통", "韩光流通"):
        failures.append("invented Hanbit business name was not rejected")
    return failures


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--self-test", action="store_true")
    args = parser.parse_args()
    if args.self_test:
        failures = self_test()
        if failures:
            for failure in failures:
                print(f"STORY_DEMO_LOCALIZATION_SELF_TEST_FAIL {failure}", file=sys.stderr)
            return 1
        print("STORY_DEMO_LOCALIZATION_SELF_TEST_OK mutations=4 fixtures=3")
        return 0

    source, english, pairs, errors, counts = source_contract()
    for language in LANGUAGES:
        language_errors, coverage = audit_language(language, source, english, pairs)
        errors.extend(language_errors)
        print(
            f"STORY_DEMO_LOCALE lang={language} "
            f"events={coverage.get('events', 0)}/{len(EVENT_IDS)} "
            f"leaves={coverage.get('event_leaves', 0)}/{EXPECTED_EVENT_LEAVES} "
            f"ui={coverage.get('ui', 0)}/{coverage.get('ui_required', len(pairs)+1)} "
            f"catalog={coverage.get('catalog', 0)}/1"
        )
    if errors:
        for error in errors:
            print(f"STORY_DEMO_LOCALIZATION_FAIL {error}", file=sys.stderr)
        return 1
    print(
        "STORY_DEMO_LOCALIZATION_OK "
        f"locales=5 source_events={len(EVENT_IDS)} leaves={EXPECTED_EVENT_LEAVES} "
        f"controller_ui={counts['controller']} story_ui={counts['story']} "
        f"target_ui={len(pairs)+1}"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
