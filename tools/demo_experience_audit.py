#!/usr/bin/env python3
"""Audit a captured six-month demo as a normal reading experience.

ScreenshotQA owns the real Godot input route and writes the JSON consumed here.
Fast-forward input counts remain reachability evidence only. This audit estimates
reading cadence from the text, choices, AP interventions, and surfaces that were
actually exposed during that route.
"""

from __future__ import annotations

import argparse
import copy
import json
import sys
from dataclasses import dataclass
from pathlib import Path
from typing import Any, Iterable


ROOT = Path(__file__).resolve().parents[1]
SCENE_AUDIO_MANIFEST = ROOT / "assets" / "scene_audio_manifest.json"
SCHEMA_VERSION = 1
EXPECTED_LAST_STORY_EVENT_ID = "hyunsu_exam_day"
KO_CHARS_PER_MINUTE = 390.0
EN_WORDS_PER_MINUTE = 190.0
PARAGRAPH_BREATH_SECONDS = 1.10
MEANINGFUL_CHOICE_SECONDS = 6.0
DIRECT_ACTION_SECONDS = 2.0
AP_ACTION_SECONDS = 12.0
MODAL_REVIEW_SECONDS = 4.0
AP_WEEK_GAP_SECONDS = 24.0

MIN_ESTIMATED_MINUTES = 40.0
MAX_ESTIMATED_MINUTES = 90.0
MAX_FIRST_MEANINGFUL_MINUTE = 7.0
MAX_MEANINGFUL_GAP_MINUTES = 7.5
MIN_MEANINGFUL_CHOICES = 24
MIN_BACKGROUNDS = 12
MIN_PORTRAITS = 5
MIN_CGS = 4
MIN_AMBIENCES = 7
MIN_MUSIC_KEYS = 9
MIN_AUTHORED_MUSIC_EVENTS = 30
MAX_IDENTICAL_ROOT_SURFACE_RUN = 3
MAX_SAME_BACKGROUND_ROOT_RUN = 4
MAX_SAME_AMBIENCE_ROOT_RUN = 5
MAX_UNSCORED_ROOT_RUN = 2
DEMO_SCORE_ANCHORS = {
    "story_knee_door": "family",
    "story_last_payment_wait": "grief",
    "story_last_payment_word": "grief",
    "v2_opening_application_send": "survival",
    "arc_temptation_01": "crisis",
    "arc_intro_03_sns": "ambition",
    "arc_chapter1_close": "reckoning",
    "arc_intro_04_hyunsu": "hyunsu",
    "arc_daeun_01_meet": "daeun",
    "arc_jiyeon_01_crash": "jiyeon",
    "arc_job_vs_invest": "reckoning",
    "arc_four_months_in": "wonder",
    "hyunsu_exam_day": "hyunsu",
    "story_six_months": "reckoning",
}


@dataclass(frozen=True)
class ExperienceMetrics:
    language: str
    device: str
    events: int
    roots: int
    meaningful_choices: int
    direct_actions: int
    manual_story_stops: int
    estimated_minutes: float
    first_meaningful_minute: float
    max_meaningful_gap_minutes: float
    max_meaningful_gap_ids: tuple[str, str]
    unique_backgrounds: int
    unique_portraits: int
    unique_cgs: int
    unique_ambiences: int
    unique_human_ambiences: int
    unique_music_keys: int
    authored_music_events: int
    longest_identical_surface_run: int
    longest_same_background_run: int
    longest_same_ambience_run: int
    longest_unscored_run: int
    fast_inputs: int
    ap_actions: int
    ap_budget: int
    story_commitments: int
    weekly_commitments: int
    commitment_budget: int


def _as_dict(value: Any) -> dict[str, Any]:
    return value if isinstance(value, dict) else {}


def _as_list(value: Any) -> list[Any]:
    return value if isinstance(value, list) else []


def _strings(value: Any) -> list[str]:
    return [str(item) for item in _as_list(value) if str(item)]


def _event_seconds(event: dict[str, Any], language: str) -> float:
    if language.lower().startswith("ko"):
        units = float(event.get("text_chars", 0)) + float(event.get("choice_chars", 0))
        reading = units / KO_CHARS_PER_MINUTE * 60.0
    else:
        units = float(event.get("text_words", 0)) + float(event.get("choice_words", 0))
        reading = units / EN_WORDS_PER_MINUTE * 60.0
    paragraphs = int(event.get("prose_paragraphs", 0)) + int(
        event.get("result_paragraphs", 0)
    )
    pause = paragraphs * PARAGRAPH_BREATH_SECONDS
    if bool(event.get("meaningful_choice", False)):
        pause += MEANINGFUL_CHOICE_SECONDS
    elif bool(event.get("direct_action", False)):
        pause += DIRECT_ACTION_SECONDS
    return reading + pause


def _root_sequences(events: list[dict[str, Any]]) -> list[list[dict[str, Any]]]:
    sequences: list[list[dict[str, Any]]] = []
    for event in events:
        if not sequences or not bool(event.get("follow_up", False)):
            sequences.append([event])
        else:
            sequences[-1].append(event)
    return sequences


def _first_surface(sequence: list[dict[str, Any]], key: str) -> str:
    for event in sequence:
        values = _strings(event.get(key, []))
        if values:
            return values[0]
    return ""


def _sequence_has_surface(sequence: list[dict[str, Any]], key: str) -> bool:
    return any(_strings(event.get(key, [])) for event in sequence)


def _longest_run(values: Iterable[Any], *, ignore_empty: bool = False) -> int:
    longest = 0
    current = 0
    previous: Any = object()
    for value in values:
        if ignore_empty and (value == "" or value == ("", "", "")):
            current = 0
            previous = object()
            continue
        if value == previous:
            current += 1
        else:
            previous = value
            current = 1
        longest = max(longest, current)
    return longest


def _max_unscored_run(sequences: list[list[dict[str, Any]]]) -> int:
    longest = 0
    current = 0
    for sequence in sequences:
        if _sequence_has_surface(sequence, "authored_music_keys"):
            current = 0
        else:
            current += 1
            longest = max(longest, current)
    return longest


def _unique_surface_count(events: list[dict[str, Any]], keys: tuple[str, ...]) -> int:
    return len(
        {
            value
            for event in events
            for key in keys
            for value in _strings(event.get(key, []))
        }
    )


def _meaningful_timeline(
    events: list[dict[str, Any]], runtime: dict[str, Any], language: str
) -> tuple[float, float, tuple[str, str], float]:
    elapsed = 0.0
    positions: list[tuple[str, float]] = []
    week_kinds = [str(value) for value in _as_list(runtime.get("week_kinds", []))]
    previous_week = int(events[0].get("week", 1)) if events else 1
    for event in events:
        week = int(event.get("week", previous_week))
        for finished_week in range(previous_week, week):
            kind = week_kinds[finished_week - 1] if finished_week <= len(week_kinds) else ""
            if kind in {"decision", "boss"}:
                elapsed += AP_WEEK_GAP_SECONDS
        elapsed += _event_seconds(event, language)
        if bool(event.get("meaningful_choice", False)):
            positions.append((str(event.get("id", "")), elapsed))
        previous_week = week

    if not positions:
        return float("inf"), float("inf"), ("", ""), elapsed
    first = positions[0][1] / 60.0
    max_gap = 0.0
    gap_ids = (positions[0][0], positions[0][0])
    for (left_id, left), (right_id, right) in zip(positions, positions[1:]):
        gap = (right - left) / 60.0
        if gap > max_gap:
            max_gap = gap
            gap_ids = (left_id, right_id)
    return first, max_gap, gap_ids, elapsed


def analyze_report(report: dict[str, Any]) -> tuple[ExperienceMetrics, list[str]]:
    errors: list[str] = []
    if int(report.get("schema_version", 0)) != SCHEMA_VERSION:
        errors.append(
            f"schema version {report.get('schema_version')} != {SCHEMA_VERSION}"
        )
    language = str(report.get("language", ""))
    device = str(report.get("device", ""))
    events = [event for event in _as_list(report.get("events")) if isinstance(event, dict)]
    runtime = _as_dict(report.get("runtime"))
    sequences = _root_sequences(events)
    flow_summary = _as_dict(runtime.get("scene_flow_summary"))
    roots = int(flow_summary.get("roots", len(sequences)))
    meaningful = sum(bool(event.get("meaningful_choice", False)) for event in events)
    direct = sum(bool(event.get("direct_action", False)) for event in events)
    # Cinematic playback carries prose, results, and one-way actions. Player input is
    # reserved for authored decisions and explicit chapter handoffs.
    manual_story_stops = meaningful + sum(
        str(event.get("boundary", "")) == "chapter_handoff" for event in events
    )
    first_choice, max_gap, gap_ids, story_elapsed = _meaningful_timeline(
        events, runtime, language
    )
    ap_actions = int(runtime.get("ap_action_inputs", 0))
    ap_budget = int(runtime.get("available_ap_budget", 0))
    story_commitments = int(
        runtime.get("story_commitments", runtime.get("story_boss_commitments", 0))
    )
    weekly_commitments = int(
        runtime.get("weekly_commitments", ap_actions + story_commitments)
    )
    commitment_budget = int(
        runtime.get("available_commitment_budget", ap_budget + story_commitments)
    )
    modal_count = sum(int(value) for value in _as_dict(runtime.get("modal_counts")).values())
    total_seconds = (
        story_elapsed
        + ap_actions * AP_ACTION_SECONDS
        + modal_count * MODAL_REVIEW_SECONDS
    )

    backgrounds = _unique_surface_count(events, ("backgrounds",))
    portraits = _unique_surface_count(events, ("portraits",))
    cgs = _unique_surface_count(events, ("cgs",))
    ambiences = _unique_surface_count(events, ("ambience_keys", "season_ambience_keys"))
    human_ambiences = _unique_surface_count(events, ("human_ambience_keys",))
    music_keys = _unique_surface_count(events, ("authored_music_keys",))
    authored_music_events = sum(
        bool(_strings(event.get("authored_music_keys", []))) for event in events
    )

    background_sequence = [_first_surface(sequence, "backgrounds") for sequence in sequences]
    ambience_sequence = [_first_surface(sequence, "ambience_keys") for sequence in sequences]
    music_sequence = [_first_surface(sequence, "authored_music_keys") for sequence in sequences]
    surface_sequence = list(zip(background_sequence, ambience_sequence, music_sequence))

    metrics = ExperienceMetrics(
        language=language,
        device=device,
        events=len(events),
        roots=roots,
        meaningful_choices=meaningful,
        direct_actions=direct,
        manual_story_stops=manual_story_stops,
        estimated_minutes=total_seconds / 60.0,
        first_meaningful_minute=first_choice,
        max_meaningful_gap_minutes=max_gap,
        max_meaningful_gap_ids=gap_ids,
        unique_backgrounds=backgrounds,
        unique_portraits=portraits,
        unique_cgs=cgs,
        unique_ambiences=ambiences,
        unique_human_ambiences=human_ambiences,
        unique_music_keys=music_keys,
        authored_music_events=authored_music_events,
        longest_identical_surface_run=_longest_run(surface_sequence, ignore_empty=True),
        longest_same_background_run=_longest_run(background_sequence, ignore_empty=True),
        longest_same_ambience_run=_longest_run(ambience_sequence, ignore_empty=True),
        longest_unscored_run=_max_unscored_run(sequences),
        fast_inputs=int(runtime.get("input_count_fast_path", 0)),
        ap_actions=ap_actions,
        ap_budget=ap_budget,
        story_commitments=story_commitments,
        weekly_commitments=weekly_commitments,
        commitment_budget=commitment_budget,
    )

    if int(runtime.get("weeks", 0)) != 24:
        errors.append(f"demo weeks {runtime.get('weeks')} != 24")
    last_story_event_id = str(runtime.get("last_story_event_id", ""))
    if last_story_event_id != EXPECTED_LAST_STORY_EVENT_ID:
        errors.append(
            f"last story event {last_story_event_id!r} != "
            f"{EXPECTED_LAST_STORY_EVENT_ID!r}"
        )
    if not events or str(events[-1].get("id", "")) != EXPECTED_LAST_STORY_EVENT_ID:
        errors.append(
            "captured event order does not end on "
            f"{EXPECTED_LAST_STORY_EVENT_ID}"
        )
    if not 40 <= metrics.events <= 60:
        errors.append(f"event count outside 40..60: {metrics.events}")
    if metrics.roots != 25 or len(sequences) != 25:
        errors.append(f"root sequence count must be 25: runtime={metrics.roots} actual={len(sequences)}")
    if metrics.meaningful_choices < MIN_MEANINGFUL_CHOICES:
        errors.append(
            f"meaningful choices {metrics.meaningful_choices} < {MIN_MEANINGFUL_CHOICES}"
        )
    if not MIN_ESTIMATED_MINUTES <= metrics.estimated_minutes <= MAX_ESTIMATED_MINUTES:
        errors.append(
            f"estimated normal reading {metrics.estimated_minutes:.1f}m outside "
            f"{MIN_ESTIMATED_MINUTES:.0f}..{MAX_ESTIMATED_MINUTES:.0f}m"
        )
    if metrics.first_meaningful_minute > MAX_FIRST_MEANINGFUL_MINUTE:
        errors.append(
            f"first meaningful choice at {metrics.first_meaningful_minute:.1f}m > "
            f"{MAX_FIRST_MEANINGFUL_MINUTE:.1f}m"
        )
    if metrics.max_meaningful_gap_minutes > MAX_MEANINGFUL_GAP_MINUTES:
        errors.append(
            f"meaningful-choice gap {metrics.max_meaningful_gap_minutes:.1f}m > "
            f"{MAX_MEANINGFUL_GAP_MINUTES:.1f}m between "
            f"{metrics.max_meaningful_gap_ids[0]} and {metrics.max_meaningful_gap_ids[1]}"
        )
    # The base director owns two generic AP weeks. A causal first-job route can
    # add one live cash-crisis intervention after the opening interview.
    if metrics.ap_actions != metrics.ap_budget or not 2 <= metrics.ap_actions <= 3:
        errors.append(
            f"AP intervention mismatch: used={metrics.ap_actions} budget={metrics.ap_budget}"
        )
    week_kind_counts = _as_dict(runtime.get("week_kind_counts"))
    decision_weeks = int(week_kind_counts.get("decision", 0)) + int(
        week_kind_counts.get("boss", 0)
    )
    if not 8 <= decision_weeks <= 10:
        errors.append(f"direct decision weeks outside 8..10: {decision_weeks}")
    if (
        metrics.story_commitments != 7
        or metrics.weekly_commitments != metrics.commitment_budget
        or metrics.weekly_commitments != decision_weeks
    ):
        errors.append(
            "weekly commitment mismatch: "
            f"ap={metrics.ap_actions} story={metrics.story_commitments} "
            f"used={metrics.weekly_commitments} budget={metrics.commitment_budget} "
            f"direct_weeks={decision_weeks}"
        )
    surface_minimums = {
        "backgrounds": (metrics.unique_backgrounds, MIN_BACKGROUNDS),
        "portraits": (metrics.unique_portraits, MIN_PORTRAITS),
        "CGs": (metrics.unique_cgs, MIN_CGS),
        "ambiences": (metrics.unique_ambiences, MIN_AMBIENCES),
        "music keys": (metrics.unique_music_keys, MIN_MUSIC_KEYS),
        "authored music events": (metrics.authored_music_events, MIN_AUTHORED_MUSIC_EVENTS),
    }
    for label, (actual, minimum) in surface_minimums.items():
        if actual < minimum:
            errors.append(f"unique {label} {actual} < {minimum}")
    run_limits = {
        "identical root surface": (
            metrics.longest_identical_surface_run,
            MAX_IDENTICAL_ROOT_SURFACE_RUN,
        ),
        "same root background": (
            metrics.longest_same_background_run,
            MAX_SAME_BACKGROUND_ROOT_RUN,
        ),
        "same root ambience": (
            metrics.longest_same_ambience_run,
            MAX_SAME_AMBIENCE_ROOT_RUN,
        ),
        "unscored root": (metrics.longest_unscored_run, MAX_UNSCORED_ROOT_RUN),
    }
    for label, (actual, maximum) in run_limits.items():
        if actual > maximum:
            errors.append(f"longest {label} run {actual} > {maximum}")
    return metrics, errors


PARITY_KEYS = (
    "id",
    "week",
    "choice_count",
    "meaningful_choice",
    "direct_action",
    "boundary",
    "mode",
    "follow_up",
    "same_week",
    "location",
    "backgrounds",
    "portraits",
    "cgs",
    "ambience_keys",
    "season_ambience_keys",
    "human_ambience_keys",
    "authored_music_keys",
)


def parity_errors(left: dict[str, Any], right: dict[str, Any]) -> list[str]:
    errors: list[str] = []
    left_events = _as_list(left.get("events"))
    right_events = _as_list(right.get("events"))
    if len(left_events) != len(right_events):
        return [f"KO/EN event count mismatch: {len(left_events)} != {len(right_events)}"]
    for index, (left_event, right_event) in enumerate(zip(left_events, right_events), start=1):
        if not isinstance(left_event, dict) or not isinstance(right_event, dict):
            errors.append(f"KO/EN event {index} is not an object")
            continue
        for key in PARITY_KEYS:
            if left_event.get(key) != right_event.get(key):
                errors.append(
                    f"KO/EN event {index} {left_event.get('id')} differs at {key}: "
                    f"{left_event.get(key)!r} != {right_event.get(key)!r}"
                )
    for key in (
        "weeks",
        "week_kinds",
        "week_kind_counts",
        "pressure_sequence",
        "pressure_family_sequence",
        "action_counts",
        "ap_action_inputs",
        "available_ap_budget",
        "story_commitments",
        "story_commitment_axes",
        "weekly_commitments",
        "available_commitment_budget",
        "narrative_bridge_count",
        "narrative_bridge_ids",
        "last_story_event_id",
        "scene_flow_summary",
    ):
        left_value = _as_dict(left.get("runtime")).get(key)
        right_value = _as_dict(right.get("runtime")).get(key)
        if left_value != right_value:
            errors.append(f"KO/EN runtime differs at {key}: {left_value!r} != {right_value!r}")
    return errors


def _synthetic_report(language: str) -> dict[str, Any]:
    events: list[dict[str, Any]] = []
    for index in range(50):
        root_index = index // 2
        meaningful = index % 2 == 0
        scored = index % 9 != 1
        event = {
            "order": index + 1,
            "week": min(root_index + 1, 24),
            "id": f"synthetic_{index + 1:02d}",
            "boundary": "new_week" if meaningful else "same_location",
            "mode": "" if meaningful else "same_location",
            "follow_up": not meaningful,
            "same_week": not meaningful,
            "location": f"location_{root_index % 12}",
            "choice_count": 3 if meaningful else 1,
            "meaningful_choice": meaningful,
            "direct_action": not meaningful,
            "prose_paragraphs": 5,
            "result_paragraphs": 1,
            "text_chars": 360,
            "choice_chars": 30,
            "text_words": 175,
            "choice_words": 15,
            "backgrounds": [f"background_{root_index % 12}"],
            "portraits": [f"res://portrait_{root_index % 6}.png"],
            "cgs": [f"cg_{root_index // 6}"] if index % 12 == 0 else [],
            "ambience_keys": [f"ambience_{root_index % 7}"],
            "season_ambience_keys": ["winter"] if root_index < 8 else [],
            "human_ambience_keys": [f"human_{root_index % 4}"],
            "music_keys": [f"music_{index % 10}"] if scored else [],
            "authored_music_keys": [f"music_{index % 10}"] if scored else [],
        }
        events.append(event)
    events[-1]["id"] = EXPECTED_LAST_STORY_EVENT_ID
    return {
        "schema_version": SCHEMA_VERSION,
        "language": language,
        "device": "gamepad",
        "events": events,
        "runtime": {
            "weeks": 24,
            "input_count_fast_path": 600,
            "week_kinds": ["decision" if index % 3 == 0 else "quiet" for index in range(24)],
            "week_kind_counts": {"decision": 7, "quiet": 11, "boss": 2, "echo": 4},
            "pressure_sequence": ["employment", "human"],
            "pressure_family_sequence": ["employment", "human"],
            "action_counts": {"study": 8},
            "ap_action_inputs": 2,
            "available_ap_budget": 2,
            "story_commitments": 7,
            "story_commitment_axes": {"money": 5, "human": 2},
            "weekly_commitments": 9,
            "available_commitment_budget": 9,
            "narrative_bridge_count": 0,
            "narrative_bridge_ids": [],
            "last_story_event_id": EXPECTED_LAST_STORY_EVENT_ID,
            "modal_counts": {"month_summary": 6},
            "scene_flow_summary": {"events": 50, "roots": 25, "followups": 25},
        },
    }


def repository_demo_music_errors() -> list[str]:
    try:
        manifest = json.loads(SCENE_AUDIO_MANIFEST.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as exc:
        return [f"cannot read scene audio manifest: {exc}"]
    contracts = _as_dict(_as_dict(manifest).get("events"))
    errors: list[str] = []
    for event_id, expected_key in DEMO_SCORE_ANCHORS.items():
        contract = _as_dict(contracts.get(event_id))
        music = _as_dict(contract.get("music"))
        if str(music.get("key", "")) != expected_key:
            errors.append(
                f"{event_id} demo score must use {expected_key}, got {music.get('key')!r}"
            )
        if not str(contract.get("ambience", "")):
            errors.append(f"{event_id} demo score lacks its place ambience")
        start = music.get("start_paragraph")
        if not isinstance(start, int) or isinstance(start, bool) or start < 1:
            errors.append(f"{event_id} demo score must enter after ambience establishes")
    return errors


def run_self_test() -> int:
    ko = _synthetic_report("ko")
    en = _synthetic_report("en")
    for report in (ko, en):
        _, errors = analyze_report(report)
        if errors:
            print(f"DEMO_EXPERIENCE_SELF_TEST_FAIL valid fixture: {errors}", file=sys.stderr)
            return 1
    if parity_errors(ko, en):
        print("DEMO_EXPERIENCE_SELF_TEST_FAIL valid parity fixture", file=sys.stderr)
        return 1

    broken_music = copy.deepcopy(ko)
    for event in broken_music["events"]:
        event["music_keys"] = []
        event["authored_music_keys"] = []
    _, music_errors = analyze_report(broken_music)
    if not any("music" in error or "unscored" in error for error in music_errors):
        print("DEMO_EXPERIENCE_SELF_TEST_FAIL music regression escaped", file=sys.stderr)
        return 1

    broken_parity = copy.deepcopy(en)
    broken_parity["events"][5]["id"] = "wrong_event"
    if not parity_errors(ko, broken_parity):
        print("DEMO_EXPERIENCE_SELF_TEST_FAIL parity regression escaped", file=sys.stderr)
        return 1
    repository_music_errors = repository_demo_music_errors()
    if repository_music_errors:
        print(
            f"DEMO_EXPERIENCE_SELF_TEST_FAIL repository music: {repository_music_errors}",
            file=sys.stderr,
        )
        return 1
    print("DEMO_EXPERIENCE_SELF_TEST_OK")
    return 0


def _format_metrics(metrics: ExperienceMetrics) -> str:
    gap = ">".join(metrics.max_meaningful_gap_ids)
    return (
        "DEMO_EXPERIENCE_METRICS "
        f"lang={metrics.language} device={metrics.device} "
        f"events={metrics.events} roots={metrics.roots} "
        f"choices={metrics.meaningful_choices} direct={metrics.direct_actions} "
        f"story_stops={metrics.manual_story_stops} "
        f"estimated={metrics.estimated_minutes:.1f}m "
        f"first_choice={metrics.first_meaningful_minute:.1f}m "
        f"max_choice_gap={metrics.max_meaningful_gap_minutes:.1f}m({gap}) "
        f"surfaces=bg{metrics.unique_backgrounds}/portrait{metrics.unique_portraits}/"
        f"cg{metrics.unique_cgs}/amb{metrics.unique_ambiences}/"
        f"human{metrics.unique_human_ambiences}/music{metrics.unique_music_keys} "
        f"authored_music={metrics.authored_music_events} "
        f"runs=surface{metrics.longest_identical_surface_run}/"
        f"bg{metrics.longest_same_background_run}/"
        f"amb{metrics.longest_same_ambience_run}/"
        f"unscored{metrics.longest_unscored_run} "
        f"ap={metrics.ap_actions}/{metrics.ap_budget} "
        f"story={metrics.story_commitments} "
        f"commitments={metrics.weekly_commitments}/{metrics.commitment_budget} "
        f"fast_inputs={metrics.fast_inputs}"
    )


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("reports", nargs="*", type=Path)
    parser.add_argument("--self-test", action="store_true")
    args = parser.parse_args()
    if args.self_test:
        return run_self_test()
    if not args.reports:
        parser.error("provide KO and EN ScreenshotQA experience JSON reports")

    loaded: list[tuple[Path, dict[str, Any]]] = []
    all_errors: list[str] = []
    for path in args.reports:
        try:
            report = json.loads(path.read_text(encoding="utf-8"))
        except (OSError, json.JSONDecodeError) as exc:
            all_errors.append(f"{path}: cannot read report: {exc}")
            continue
        if not isinstance(report, dict):
            all_errors.append(f"{path}: report root is not an object")
            continue
        metrics, errors = analyze_report(report)
        print(_format_metrics(metrics))
        all_errors.extend(f"{path.name}: {error}" for error in errors)
        loaded.append((path, report))

    by_language = {str(report.get("language", "")): report for _, report in loaded}
    if "ko" not in by_language or "en" not in by_language:
        all_errors.append("both ko and en reports are required for structural parity")
    else:
        all_errors.extend(parity_errors(by_language["ko"], by_language["en"]))

    if all_errors:
        for error in all_errors:
            print(f"DEMO_EXPERIENCE_AUDIT_FAIL {error}", file=sys.stderr)
        return 1
    print("DEMO_EXPERIENCE_AUDIT_OK reports=2 parity=ko/en")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
