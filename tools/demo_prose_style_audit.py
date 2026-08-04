#!/usr/bin/env python3
"""Enforce the deterministic part of the 24-week demo prose style.

Only Korean clock notation is machine-checked.  Scene endings, sentence
rhythm, and English voice remain editorial judgements: turning those into
regular-expression scores would reject valid prose.  The reachable surface is
borrowed from ``demo_localization_scope`` so this audit neither scans weeks
25-240 nor silently omits dynamic first-bill copy.
"""

from __future__ import annotations

import argparse
import json
import re
import sys
from collections import Counter, defaultdict
from dataclasses import dataclass
from pathlib import Path
from typing import Any, Iterable


ROOT = Path(__file__).resolve().parents[1]
TOOLS = ROOT / "tools"
if str(TOOLS) not in sys.path:
    sys.path.insert(0, str(TOOLS))

import demo_localization_scope as demo_scope  # noqa: E402


MANIFEST_PATH = ROOT / "content/meta/demo_localization_scope.json"
DAYPARTS = ("오전", "오후", "새벽", "아침", "낮", "저녁", "밤")
AM_DAYPARTS = {"오전", "새벽", "아침"}
PM_DAYPARTS = {"오후", "저녁", "밤"}

HOUR_WORD_VALUES = {
    "한": 1,
    "두": 2,
    "세": 3,
    "네": 4,
    "다섯": 5,
    "여섯": 6,
    "일곱": 7,
    "여덟": 8,
    "아홉": 9,
    "열": 10,
    "열한": 11,
    "열두": 12,
    "열세": 13,
    "열네": 14,
    "열다섯": 15,
    "열여섯": 16,
    "열일곱": 17,
    "열여덟": 18,
    "열아홉": 19,
    "스무": 20,
    "스물한": 21,
    "스물두": 22,
    "스물세": 23,
    "스물네": 24,
}

SINO_DIGITS = {
    0: "영",
    1: "일",
    2: "이",
    3: "삼",
    4: "사",
    5: "오",
    6: "육",
    7: "칠",
    8: "팔",
    9: "구",
}


def _sino_number(value: int) -> str:
    if value < 10:
        return SINO_DIGITS[value]
    tens, ones = divmod(value, 10)
    prefix = "십" if tens == 1 else f"{SINO_DIGITS[tens]}십"
    return prefix if ones == 0 else f"{prefix}{SINO_DIGITS[ones]}"


# Generate through 99 so malformed authored minutes such as 칠십오 분 are
# detected and rejected instead of being mistaken for an hour-only mention.
MINUTE_WORD_VALUES = {_sino_number(value): value for value in range(100)}
HOUR_WORD_PATTERN = "|".join(
    re.escape(value) for value in sorted(HOUR_WORD_VALUES, key=len, reverse=True)
)
MINUTE_WORD_PATTERN = "|".join(
    re.escape(value) for value in sorted(MINUTE_WORD_VALUES, key=len, reverse=True)
)
DAYPART_PATTERN = "|".join(DAYPARTS)

# A clock unit can be followed by punctuation, whitespace, or a Korean
# particle.  Lexical continuations such as 시간, 시리즈, 시점, and 시즌 do not
# satisfy this boundary, which keeps durations and names out of the audit.
TOKEN_TAIL = (
    r"(?=$|[\s\n.,!?;:'\"“”‘’()\[\]{}—·/]"
    r"|에|까지|부터|쯤|경|께|가|는|도|를|의|로|이|였다|였고|입니다|이었다)"
)
DAYPART_PREFIX = rf"(?:(?P<daypart>{DAYPART_PATTERN})\s*)?"
MINUTE_VALUE = (
    rf"(?:(?P<minute_digits>\d{{1,2}})"
    rf"|(?P<minute_word>{MINUTE_WORD_PATTERN}))"
)

CLOCK_PATTERNS: tuple[tuple[str, re.Pattern[str]], ...] = (
    (
        "colon",
        re.compile(
            rf"(?<![0-9A-Za-z가-힣]){DAYPART_PREFIX}"
            rf"(?P<hour_digits>\d{{1,2}}):(?P<minute_digits>\d{{2}})"
            rf"{TOKEN_TAIL}"
        ),
    ),
    (
        "digit_minute",
        re.compile(
            rf"(?<![0-9A-Za-z가-힣]){DAYPART_PREFIX}"
            rf"(?P<hour_digits>\d{{1,2}})\s*시\s*{MINUTE_VALUE}\s*분"
            rf"{TOKEN_TAIL}"
        ),
    ),
    (
        "word_minute",
        re.compile(
            rf"(?<![0-9A-Za-z가-힣]){DAYPART_PREFIX}"
            rf"(?P<hour_word>{HOUR_WORD_PATTERN})\s*시\s*{MINUTE_VALUE}\s*분"
            rf"{TOKEN_TAIL}"
        ),
    ),
    (
        "digit_hour",
        re.compile(
            rf"(?<![0-9A-Za-z가-힣]){DAYPART_PREFIX}"
            rf"(?P<hour_digits>\d{{1,2}})\s*시"
            rf"(?!\s*(?:\d{{1,2}}|{MINUTE_WORD_PATTERN})\s*분)"
            rf"{TOKEN_TAIL}"
        ),
    ),
    (
        "word_hour",
        re.compile(
            rf"(?<![0-9A-Za-z가-힣]){DAYPART_PREFIX}"
            rf"(?P<hour_word>{HOUR_WORD_PATTERN})\s*시"
            rf"(?!\s*(?:\d{{1,2}}|{MINUTE_WORD_PATTERN})\s*분)"
            rf"{TOKEN_TAIL}"
        ),
    ),
)


@dataclass(frozen=True)
class SurfaceRow:
    source_id: str
    text: str


@dataclass(frozen=True)
class ClockMention:
    source_id: str
    literal: str
    canonical: str
    minute_precision: bool
    written_hour: bool
    written_minute: bool
    start: int
    end: int


def korean_surface_rows(runtime: dict[str, Any]) -> list[SurfaceRow]:
    rows: list[SurfaceRow] = []
    for leaf in runtime.get("leaves", []):
        rows.append(SurfaceRow(
            f"event::{leaf.owner}::{leaf.path}", leaf.source
        ))
    for pair in runtime.get("pairs", []):
        rows.append(SurfaceRow(f"dynamic::{pair.source_id}", pair.korean))
    return rows


def _clock_value(
    match: re.Match[str], kind: str,
) -> tuple[str, bool, bool, str]:
    groups = match.groupdict()
    daypart = groups.get("daypart") or ""
    hour_word = groups.get("hour_word")
    minute_word = groups.get("minute_word")
    written_hour = hour_word is not None
    written_minute = minute_word is not None
    hour = (
        HOUR_WORD_VALUES[hour_word]
        if hour_word is not None
        else int(groups.get("hour_digits") or -1)
    )
    minute_precision = kind in {"colon", "digit_minute", "word_minute"}
    if minute_precision:
        minute = (
            MINUTE_WORD_VALUES[minute_word]
            if minute_word is not None
            else int(groups.get("minute_digits") or -1)
        )
    else:
        minute = 0

    if daypart:
        if not 1 <= hour <= 12:
            return "", written_hour, written_minute, (
                f"daypart clock hour is outside 1..12: {hour}"
            )
        if daypart in AM_DAYPARTS:
            hour = 0 if hour == 12 else hour
        elif daypart in PM_DAYPARTS:
            hour = 12 if hour == 12 else hour + 12
        elif daypart == "낮" and hour == 12:
            hour = 12
    elif not 0 <= hour <= 24:
        return "", written_hour, written_minute, (
            f"clock hour is outside 0..24: {hour}"
        )
    elif hour == 24:
        hour = 0

    if not 0 <= minute <= 59:
        return "", written_hour, written_minute, (
            f"clock minute is outside 0..59: {minute}"
        )
    return (
        f"{hour:02d}:{minute:02d}", written_hour, written_minute, ""
    )


def clock_mentions(row: SurfaceRow) -> tuple[list[ClockMention], list[str]]:
    candidates: list[tuple[int, int, int, str, re.Match[str]]] = []
    for priority, (kind, pattern) in enumerate(CLOCK_PATTERNS):
        for match in pattern.finditer(row.text):
            candidates.append((
                match.start(), -len(match.group(0)), priority, kind, match
            ))

    mentions: list[ClockMention] = []
    errors: list[str] = []
    occupied: list[tuple[int, int]] = []
    for _start, _negative_length, _priority, kind, match in sorted(candidates):
        if any(
            match.start() < end and start < match.end()
            for start, end in occupied
        ):
            continue
        occupied.append(match.span())
        canonical, written_hour, written_minute, value_error = _clock_value(
            match, kind
        )
        literal = match.group(0)
        if value_error:
            errors.append(
                f"{row.source_id}: invalid clock {literal!r}: {value_error}"
            )
        mentions.append(ClockMention(
            source_id=row.source_id,
            literal=literal,
            canonical=canonical,
            minute_precision=kind in {
                "colon", "digit_minute", "word_minute"
            },
            written_hour=written_hour,
            written_minute=written_minute,
            start=match.start(),
            end=match.end(),
        ))
    return sorted(mentions, key=lambda value: value.start), errors


def _contract_entries(
    contract: dict[str, Any], key: str, require_minute: bool,
) -> tuple[Counter[tuple[str, str, str]], list[dict[str, Any]], list[str]]:
    counter: Counter[tuple[str, str, str]] = Counter()
    entries: list[dict[str, Any]] = []
    errors: list[str] = []
    raw_entries = contract.get(key, [])
    if not isinstance(raw_entries, list):
        return counter, entries, [f"korean_clock_contract.{key}: expected array"]

    seen: set[tuple[str, str, str]] = set()
    for index, raw_entry in enumerate(raw_entries):
        label = f"korean_clock_contract.{key}[{index}]"
        if not isinstance(raw_entry, dict):
            errors.append(f"{label}: expected object")
            continue
        source_id = raw_entry.get("source_id")
        literal = raw_entry.get("literal")
        canonical = raw_entry.get("canonical")
        count = raw_entry.get("count", 1)
        reason = raw_entry.get("reason")
        if not isinstance(source_id, str) or not source_id:
            errors.append(f"{label}: missing source_id")
            continue
        if not isinstance(literal, str) or not literal:
            errors.append(f"{label}: missing literal")
            continue
        if not isinstance(canonical, str) or not re.fullmatch(
            r"(?:[01]\d|2[0-3]):[0-5]\d", canonical
        ):
            errors.append(f"{label}: invalid canonical clock {canonical!r}")
            continue
        if not isinstance(count, int) or isinstance(count, bool) or count < 1:
            errors.append(f"{label}: count must be a positive integer")
            continue
        if not isinstance(reason, str) or not reason.strip():
            errors.append(f"{label}: reason is required")
            continue

        probe = SurfaceRow(source_id, literal)
        parsed, parse_errors = clock_mentions(probe)
        errors.extend(f"{label}: {error}" for error in parse_errors)
        if len(parsed) != 1 or parsed[0].literal != literal:
            errors.append(f"{label}: literal must be exactly one clock mention")
            continue
        mention = parsed[0]
        if mention.canonical != canonical:
            errors.append(
                f"{label}: canonical {canonical} != parsed {mention.canonical}"
            )
            continue
        if mention.written_hour or mention.written_minute:
            errors.append(f"{label}: allowlisted clock must use Arabic digits")
            continue
        if require_minute and not mention.minute_precision:
            errors.append(f"{label}: minute precision entry has no minute")
            continue
        entry_key = (source_id, literal, canonical)
        if entry_key in seen:
            errors.append(f"{label}: duplicate contract row {entry_key!r}")
            continue
        seen.add(entry_key)
        counter[entry_key] = count
        entries.append(raw_entry)
    return counter, entries, errors


def audit_rows(
    rows: Iterable[SurfaceRow], contract: dict[str, Any],
) -> tuple[list[str], dict[str, int]]:
    row_list = list(rows)
    errors: list[str] = []
    allowlist, _allow_entries, allow_errors = _contract_entries(
        contract, "minute_precision_allowlist", True
    )
    anchor_counter, anchor_entries, anchor_errors = _contract_entries(
        contract, "required_anchors", False
    )
    errors.extend(allow_errors + anchor_errors)

    # A required anchor can itself use minute precision.  In that case the
    # exact source-scoped anchor is also its permission; do not force the same
    # row to be duplicated in the minute allowlist.  The 17:52 opening appears
    # in both lists for clarity, so identical entries are merged, not summed.
    authorized_minutes = allowlist.copy()
    anchor_minute_permissions = 0
    for key, count in anchor_counter.items():
        source_id, literal, _canonical = key
        parsed, _parse_errors = clock_mentions(SurfaceRow(source_id, literal))
        if not parsed or not parsed[0].minute_precision:
            continue
        prior = authorized_minutes.get(key)
        if prior is not None and prior != count:
            errors.append(
                f"minute permission count disagrees between allowlist and "
                f"required anchor: {key!r} {prior}!={count}"
            )
            continue
        if prior is None:
            authorized_minutes[key] = count
            anchor_minute_permissions += count

    mentions: list[ClockMention] = []
    texts_by_source: dict[str, list[str]] = defaultdict(list)
    for row in row_list:
        texts_by_source[row.source_id].append(row.text)
        found, parse_errors = clock_mentions(row)
        mentions.extend(found)
        errors.extend(parse_errors)
        for mention in found:
            if mention.written_hour or mention.written_minute:
                errors.append(
                    f"{mention.source_id}: Korean clock must use Arabic digits: "
                    f"{mention.literal!r}"
                )

    actual_minutes: Counter[tuple[str, str, str]] = Counter(
        (mention.source_id, mention.literal, mention.canonical)
        for mention in mentions
        if mention.minute_precision
    )
    for key in sorted(set(actual_minutes) | set(authorized_minutes)):
        actual = actual_minutes[key]
        allowed = authorized_minutes[key]
        source_id, literal, canonical = key
        if actual > allowed:
            errors.append(
                f"{source_id}: unapproved minute precision "
                f"{literal!r} ({canonical}) count={actual} allowed={allowed}"
            )
        elif allowed > actual:
            errors.append(
                f"{source_id}: stale minute allowlist "
                f"{literal!r} ({canonical}) count={allowed} actual={actual}"
            )

    for index, entry in enumerate(anchor_entries):
        source_id = str(entry["source_id"])
        literal = str(entry["literal"])
        expected = int(entry.get("count", 1))
        actual = sum(
            text.count(literal) for text in texts_by_source.get(source_id, [])
        )
        if actual != expected:
            errors.append(
                f"required clock anchor missing/drifted: {source_id}: "
                f"{literal!r} count={actual} expected={expected} "
                f"(contract row {index})"
            )

    stats = {
        "rows": len(row_list),
        "clock_mentions": len(mentions),
        "minute_mentions": sum(
            1 for mention in mentions if mention.minute_precision
        ),
        "minute_allowlist": sum(allowlist.values()),
        "minute_anchor_permissions": anchor_minute_permissions,
        "written_clocks": sum(
            1 for mention in mentions
            if mention.written_hour or mention.written_minute
        ),
    }
    return sorted(dict.fromkeys(errors)), stats


def _empty_contract() -> dict[str, Any]:
    return {
        "minute_precision_allowlist": [],
        "required_anchors": [],
    }


def _allowed_entry(
    source_id: str = "test::allowed",
    literal: str = "오후 5시 52분",
    canonical: str = "17:52",
) -> dict[str, Any]:
    return {
        "source_id": source_id,
        "literal": literal,
        "canonical": canonical,
        "count": 1,
        "reason": "self-test authored minute",
    }


def run_self_test() -> list[str]:
    failures: list[str] = []
    cases = 0

    safe_texts = (
        "한 시간 뒤",
        "두 시간짜리 수업",
        "한 시간 반",
        "24시간 편의점",
        "BMW 3시리즈 키",
        "11분 뒤",
        "오후 6시까지",
        "오전 9시에 시작했다",
    )
    for text in safe_texts:
        cases += 1
        errors, _stats = audit_rows(
            [SurfaceRow(f"test::safe::{cases}", text)], _empty_contract()
        )
        if errors:
            failures.append(f"safe text was rejected: {text!r}: {errors}")

    rejected = (
        ("새벽 두 시", "Arabic digits"),
        ("오전 열한 시 팔 분", "Arabic digits"),
        ("오후 5시 십 분", "Arabic digits"),
        ("오전 10시 17분", "unapproved minute precision"),
        ("시계가 2:17로 바뀌었다", "unapproved minute precision"),
        ("시계는 18:00이 되었다", "unapproved minute precision"),
        ("오후 25시", "invalid clock"),
        ("오후 5시 75분", "invalid clock"),
    )
    for text, fragment in rejected:
        cases += 1
        errors, _stats = audit_rows(
            [SurfaceRow(f"test::reject::{cases}", text)], _empty_contract()
        )
        if not any(fragment in error for error in errors):
            failures.append(
                f"mutation was not rejected ({fragment}): {text!r}: {errors}"
            )

    allowed_contract = _empty_contract()
    allowed_contract["minute_precision_allowlist"] = [_allowed_entry()]
    cases += 1
    errors, _stats = audit_rows(
        [SurfaceRow("test::allowed", "오후 5시 52분")], allowed_contract
    )
    if errors:
        failures.append(f"authored minute was rejected: {errors}")

    cases += 1
    errors, _stats = audit_rows(
        [SurfaceRow("test::allowed", "오후 5시 51분")], allowed_contract
    )
    if not any("unapproved minute precision" in error for error in errors) \
            or not any("stale minute allowlist" in error for error in errors):
        failures.append(f"allowlisted literal mutation passed: {errors}")

    cases += 1
    errors, _stats = audit_rows([], allowed_contract)
    if not any("stale minute allowlist" in error for error in errors):
        failures.append(f"stale allowlist row passed: {errors}")

    cases += 1
    errors, _stats = audit_rows([
        SurfaceRow(
            "test::allowed", "오후 5시 52분, 오후 5시 52분"
        )
    ], allowed_contract)
    if not any("count=2 allowed=1" in error for error in errors):
        failures.append(f"duplicate authored minute passed: {errors}")

    anchor_contract = {
        "minute_precision_allowlist": [_allowed_entry()],
        "required_anchors": [
            _allowed_entry(),
            _allowed_entry(
                "test::cutoff", "오후 6시", "18:00"
            ),
        ],
    }
    anchor_rows = [
        SurfaceRow("test::allowed", "오후 5시 52분"),
        SurfaceRow("test::cutoff", "오후 6시까지"),
    ]
    cases += 1
    errors, _stats = audit_rows(anchor_rows, anchor_contract)
    if errors:
        failures.append(f"required anchors were rejected: {errors}")

    for missing_source in ("test::allowed", "test::cutoff"):
        cases += 1
        errors, _stats = audit_rows(
            [row for row in anchor_rows if row.source_id != missing_source],
            anchor_contract,
        )
        if not any(
            "required clock anchor missing/drifted" in error
            and missing_source in error
            for error in errors
        ):
            failures.append(
                f"missing anchor passed ({missing_source}): {errors}"
            )

    # The real collector carries only derived leaves and pairs.  An unrelated
    # event dictionary is deliberately not scanned merely because it exists.
    cases += 1
    fake_runtime = {
        "events": {"unreachable": {"description": "새벽 두 시"}},
        "leaves": [],
        "pairs": [],
    }
    rows = korean_surface_rows(fake_runtime)
    errors, _stats = audit_rows(rows, _empty_contract())
    if rows or errors:
        failures.append(f"unreachable event entered style scope: {rows} {errors}")

    if not failures:
        print(f"DEMO_PROSE_STYLE_SELF_TEST_OK cases={cases}")
    return failures


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--self-test", action="store_true")
    args = parser.parse_args()

    errors: list[str] = []
    if args.self_test:
        errors.extend(run_self_test())

    try:
        observed, runtime, scope_errors = demo_scope.build_scope()
        manifest = demo_scope.read_json(MANIFEST_PATH)
    except (
        OSError, ValueError, KeyError, TypeError, json.JSONDecodeError
    ) as exc:
        print(f"DEMO_PROSE_STYLE_AUDIT_FAIL {exc}")
        return 1
    errors.extend(scope_errors)
    if not isinstance(manifest, dict):
        print("DEMO_PROSE_STYLE_AUDIT_FAIL manifest must be an object")
        return 1
    contract = manifest.get("korean_clock_contract", {})
    if not isinstance(contract, dict):
        errors.append("korean_clock_contract: expected object")
        contract = {}
    elif contract.get("schema_version") != 1:
        errors.append("korean_clock_contract.schema_version must be 1")
    audit_errors, stats = audit_rows(korean_surface_rows(runtime), contract)
    errors.extend(audit_errors)

    print(
        "DEMO_PROSE_STYLE "
        f"events={observed['event_text_count']} "
        f"dynamic_occurrences={observed['dynamic_pair_occurrences']} "
        f"dynamic_keys={observed['dynamic_unique_keys']} "
        + " ".join(f"{key}={value}" for key, value in stats.items())
    )
    if errors:
        errors = sorted(dict.fromkeys(errors))
        print(f"DEMO_PROSE_STYLE_AUDIT_FAIL errors={len(errors)}")
        for error in errors[:200]:
            print(f"  {error}")
        if len(errors) > 200:
            print(f"  ... {len(errors) - 200} more")
        return 1
    print("DEMO_PROSE_STYLE_AUDIT_OK")
    return 0


if __name__ == "__main__":
    sys.exit(main())
