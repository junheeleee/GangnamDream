#!/usr/bin/env python3
"""Validate and aggregate no-instruction external playtest sessions.

This gate measures whether the required human evidence was collected under one
build. It deliberately cannot declare the demo fun or approve release.
"""

from __future__ import annotations

import argparse
import hashlib
import json
import math
import re
import statistics
import sys
from collections import Counter
from pathlib import Path
from typing import Any, Iterable

try:
    from human_gates import LedgerValidationError, canonical_active_candidate
except ModuleNotFoundError:  # package import, e.g. `python -m tools.playtest_report`
    from tools.human_gates import LedgerValidationError, canonical_active_candidate


SCHEMA_VERSION = 2
STATUS_READY = "READY_FOR_HUMAN_VERDICT"
STATUS_INCOMPLETE = "INCOMPLETE_SAMPLE"
STATUS_NO_GO = "NO_GO_REPAIR_REQUIRED"
CANONICAL_GATE_ID = "external_readthrough"

REQUIRED_FIELDS = {
    "schema_version",
    "session_id",
    "build_revision",
    "manifest_sha256",
    "artifact_sha256",
    "platform",
    "language",
    "input",
    "narrative_experience",
    "duration_minutes",
    "completed_full_session",
    "voluntary_stop",
    "p0_errors",
    "plan_score",
    "plan_answer",
    "remembered_choice",
    "remembered_choice_text",
    "remembered_choice_scene",
    "hesitated_choice",
    "hesitated_choice_text",
    "hesitated_choice_scene",
    "goal_clarity",
    "weekly_decision_clarity",
    "consequence_feel",
    "ui_readability",
    "art_fit",
    "continue_intent",
    "primary_reason_category",
    "continue_or_stop_reason",
    "art_outlier_scene",
    "observer_notes",
}

ENUMS = {
    "platform": {"windows", "macos", "linux", "steam_deck"},
    "language": {"ko", "en"},
    "input": {"mouse_keyboard", "xbox", "dualsense", "steam_deck"},
    "narrative_experience": {"experienced", "inexperienced"},
    "primary_reason_category": {
        "continue",
        "text",
        "loop",
        "controls",
        "tone",
        "art",
        "technical",
        "other",
    },
}

SCORE_FIELDS = {
    "goal_clarity",
    "weekly_decision_clarity",
    "consequence_feel",
    "ui_readability",
    "art_fit",
    "continue_intent",
}
TEXT_FIELDS = {
    "plan_answer",
    "remembered_choice_text",
    "remembered_choice_scene",
    "hesitated_choice_text",
    "hesitated_choice_scene",
    "continue_or_stop_reason",
    "art_outlier_scene",
    "observer_notes",
}
REQUIRED_TEXT_FIELDS = {"plan_answer", "continue_or_stop_reason"}
SESSION_ID_RE = re.compile(r"^[A-Za-z0-9][A-Za-z0-9_-]{1,23}$")
REVISION_RE = re.compile(r"^[0-9a-f]{7,40}$")
SHA256_RE = re.compile(r"^[0-9a-f]{64}$")


class ValidationFailure(Exception):
    """Raised when one or more session contracts are invalid."""

    def __init__(self, errors: Iterable[str]):
        self.errors = list(errors)
        super().__init__("; ".join(self.errors))


def _is_int(value: Any) -> bool:
    return isinstance(value, int) and not isinstance(value, bool)


def _clean_text(value: Any, field: str, source: str, errors: list[str]) -> str:
    if not isinstance(value, str):
        errors.append(f"{source}: {field} must be a string")
        return ""
    cleaned = value.strip()
    if field in REQUIRED_TEXT_FIELDS and not cleaned:
        errors.append(f"{source}: {field} must not be empty")
    if len(cleaned) > 2000:
        errors.append(f"{source}: {field} exceeds 2000 characters")
    return cleaned


def validate_session(raw: Any, source: str = "<memory>") -> dict[str, Any]:
    if not isinstance(raw, dict):
        raise ValidationFailure([f"{source}: session root must be an object"])

    errors: list[str] = []
    missing = sorted(REQUIRED_FIELDS - raw.keys())
    unknown = sorted(raw.keys() - REQUIRED_FIELDS)
    if missing:
        errors.append(f"{source}: missing fields: {', '.join(missing)}")
    if unknown:
        errors.append(f"{source}: unknown fields: {', '.join(unknown)}")
    if errors:
        raise ValidationFailure(errors)

    session = dict(raw)
    if not _is_int(session["schema_version"]) or session["schema_version"] != SCHEMA_VERSION:
        errors.append(
            f"{source}: schema_version must be {SCHEMA_VERSION}, "
            f"got {session['schema_version']!r}"
        )

    session_id = session["session_id"]
    if not isinstance(session_id, str) or not SESSION_ID_RE.fullmatch(session_id):
        errors.append(f"{source}: invalid session_id {session_id!r}")

    revision = session["build_revision"]
    if not isinstance(revision, str) or not REVISION_RE.fullmatch(revision):
        errors.append(f"{source}: build_revision must be 7-40 lowercase hex chars")
    for field in ("manifest_sha256", "artifact_sha256"):
        value = session[field]
        if not isinstance(value, str) or not SHA256_RE.fullmatch(value):
            errors.append(f"{source}: {field} must be a lowercase SHA-256")

    for field, allowed in ENUMS.items():
        value = session[field]
        if not isinstance(value, str) or value not in allowed:
            errors.append(
                f"{source}: {field} must be one of {sorted(allowed)}, "
                f"got {value!r}"
            )

    duration = session["duration_minutes"]
    if isinstance(duration, bool) or not isinstance(duration, (int, float)):
        errors.append(f"{source}: duration_minutes must be a number")
    elif not 0 < float(duration) <= 120:
        errors.append(f"{source}: duration_minutes must be within (0, 120]")

    for field in (
        "completed_full_session",
        "voluntary_stop",
        "remembered_choice",
        "hesitated_choice",
    ):
        if not isinstance(session[field], bool):
            errors.append(f"{source}: {field} must be boolean")

    p0_errors = session["p0_errors"]
    if not isinstance(p0_errors, list):
        errors.append(f"{source}: p0_errors must be an array")
    elif len(p0_errors) > 10:
        errors.append(f"{source}: p0_errors may contain at most 10 entries")
    else:
        cleaned_p0: list[str] = []
        for index, entry in enumerate(p0_errors):
            if not isinstance(entry, str) or not entry.strip():
                errors.append(f"{source}: p0_errors[{index}] must be non-empty text")
            elif len(entry.strip()) > 500:
                errors.append(f"{source}: p0_errors[{index}] exceeds 500 characters")
            else:
                cleaned_p0.append(entry.strip())
        session["p0_errors"] = cleaned_p0

    if not _is_int(session["plan_score"]) or session["plan_score"] not in {0, 1, 2}:
        errors.append(f"{source}: plan_score must be 0, 1, or 2")
    for field in SCORE_FIELDS:
        if not _is_int(session[field]) or not 1 <= session[field] <= 5:
            errors.append(f"{source}: {field} must be an integer from 1 to 5")

    for field in TEXT_FIELDS:
        session[field] = _clean_text(session[field], field, source, errors)

    if session.get("remembered_choice") and not session.get("remembered_choice_text"):
        errors.append(
            f"{source}: remembered_choice_text is required when remembered_choice is true"
        )
    if session.get("hesitated_choice") and not session.get("hesitated_choice_text"):
        errors.append(
            f"{source}: hesitated_choice_text is required when hesitated_choice is true"
        )
    if session.get("completed_full_session") and session.get("voluntary_stop"):
        errors.append(
            f"{source}: completed_full_session and voluntary_stop cannot both be true"
        )
    if (
        isinstance(duration, (int, float))
        and not isinstance(duration, bool)
        and session.get("completed_full_session")
        and float(duration) < 29.0
    ):
        errors.append(
            f"{source}: a completed 30-minute session must last at least 29 minutes"
        )
    if (
        session.get("completed_full_session") is False
        and session.get("voluntary_stop") is False
        and not session.get("p0_errors")
    ):
        errors.append(
            f"{source}: an incomplete session needs voluntary_stop or a P0 error"
        )

    if errors:
        raise ValidationFailure(errors)
    return session


def validate_collection(
    sessions: list[dict[str, Any]],
    expected_candidate: dict[str, Any] | None = None,
) -> None:
    errors: list[str] = []
    if not sessions:
        errors.append("no sessions supplied")
        raise ValidationFailure(errors)

    ids = [session["session_id"] for session in sessions]
    duplicates = sorted(session_id for session_id, count in Counter(ids).items() if count > 1)
    if duplicates:
        errors.append(f"duplicate session_id values: {', '.join(duplicates)}")

    revisions = sorted({session["build_revision"] for session in sessions})
    manifests = sorted({session["manifest_sha256"] for session in sessions})
    if len(revisions) != 1:
        errors.append(f"mixed build revisions: {', '.join(revisions)}")
    if len(manifests) != 1:
        errors.append(f"mixed manifest hashes: {', '.join(manifests)}")

    if expected_candidate is not None:
        expected_revision = expected_candidate.get("commit")
        expected_manifest = expected_candidate.get("manifest_sha256")
        if revisions != [expected_revision]:
            errors.append(
                "stale or foreign build revision: "
                f"sessions={', '.join(revisions)} canonical={expected_revision}"
            )
        if manifests != [expected_manifest]:
            errors.append(
                "stale or foreign manifest: "
                f"sessions={', '.join(manifests)} canonical={expected_manifest}"
            )

    platform_hashes: dict[str, set[str]] = {}
    for session in sessions:
        platform_hashes.setdefault(session["platform"], set()).add(
            session["artifact_sha256"]
        )
    for platform, hashes in sorted(platform_hashes.items()):
        if len(hashes) != 1:
            errors.append(
                f"platform {platform} has mixed artifact hashes: {', '.join(sorted(hashes))}"
            )

    if errors:
        raise ValidationFailure(errors)


def load_sessions(
    paths: list[Path],
    expected_candidate: dict[str, Any] | None = None,
) -> list[dict[str, Any]]:
    sessions: list[dict[str, Any]] = []
    errors: list[str] = []
    for path in paths:
        try:
            raw = json.loads(path.read_text(encoding="utf-8"))
            sessions.append(validate_session(raw, str(path)))
        except (OSError, json.JSONDecodeError) as exc:
            errors.append(f"{path}: cannot read JSON: {exc}")
        except ValidationFailure as exc:
            errors.extend(exc.errors)
    if errors:
        raise ValidationFailure(errors)
    validate_collection(sessions, expected_candidate)
    return sessions


def _median(sessions: list[dict[str, Any]], field: str) -> float:
    return float(statistics.median(session[field] for session in sessions))


def _nonempty_counts(sessions: list[dict[str, Any]], field: str) -> Counter[str]:
    return Counter(session[field] for session in sessions if session[field])


def aggregate(
    sessions: list[dict[str, Any]],
    expected_candidate: dict[str, Any] | None = None,
) -> dict[str, Any]:
    validate_collection(sessions, expected_candidate)
    total = len(sessions)
    language_counts = Counter(session["language"] for session in sessions)
    experience_counts = Counter(session["narrative_experience"] for session in sessions)
    input_counts = Counter(session["input"] for session in sessions)
    reason_counts = Counter(session["primary_reason_category"] for session in sessions)
    plan_counts = Counter(session["plan_score"] for session in sessions)
    concrete_plans = plan_counts[2]
    required_concrete = math.ceil(total * 0.7)
    p0_session_count = sum(bool(session["p0_errors"]) for session in sessions)
    voluntary_stops = sum(session["voluntary_stop"] for session in sessions)

    sample_requirements = {
        "total_at_least_10": total >= 10,
        "english_at_least_3": language_counts["en"] >= 3,
        "experienced_at_least_4": experience_counts["experienced"] >= 4,
        "inexperienced_at_least_4": experience_counts["inexperienced"] >= 4,
    }
    sample_complete = all(sample_requirements.values())
    if p0_session_count:
        status = STATUS_NO_GO
    elif not sample_complete:
        status = STATUS_INCOMPLETE
    elif concrete_plans < required_concrete:
        status = STATUS_NO_GO
    else:
        status = STATUS_READY

    remembered_scenes = _nonempty_counts(sessions, "remembered_choice_scene")
    hesitated_scenes = _nonempty_counts(sessions, "hesitated_choice_scene")
    art_outliers = _nonempty_counts(sessions, "art_outlier_scene")
    hesitated_choice_count = sum(session["hesitated_choice"] for session in sessions)
    return {
        "schema_version": SCHEMA_VERSION,
        "status": status,
        "human_verdict_required": True,
        "build_revision": sessions[0]["build_revision"],
        "manifest_sha256": sessions[0]["manifest_sha256"],
        "session_count": total,
        "sample_requirements": sample_requirements,
        "language_counts": dict(sorted(language_counts.items())),
        "experience_counts": dict(sorted(experience_counts.items())),
        "input_counts": dict(sorted(input_counts.items())),
        "plan_score_counts": {str(score): plan_counts[score] for score in (0, 1, 2)},
        "concrete_plan_count": concrete_plans,
        "concrete_plan_required": required_concrete,
        "remembered_choice_count": sum(session["remembered_choice"] for session in sessions),
        "hesitated_choice_count": hesitated_choice_count,
        "hesitation_stake_review_recommended": total >= 10 and hesitated_choice_count <= 1,
        "voluntary_stop_count": voluntary_stops,
        "p0_session_count": p0_session_count,
        "medians": {
            field: _median(sessions, field)
            for field in sorted(SCORE_FIELDS)
        },
        "primary_reason_counts": dict(sorted(reason_counts.items())),
        "remembered_scene_counts": dict(remembered_scenes.most_common()),
        "hesitated_scene_counts": dict(hesitated_scenes.most_common()),
        "art_outlier_counts": dict(art_outliers.most_common()),
    }


def _mark(passed: bool) -> str:
    return "PASS" if passed else "OPEN"


def render_markdown(report: dict[str, Any]) -> str:
    requirements = report["sample_requirements"]
    lines = [
        "# External Playtest Gate Report",
        "",
        f"- Status: **{report['status']}**",
        f"- Build revision: `{report['build_revision']}`",
        f"- Manifest SHA-256: `{report['manifest_sha256']}`",
        f"- Sessions: **{report['session_count']}**",
        "- Final fun/release verdict: **HUMAN REVIEW REQUIRED**",
        "",
        "## Sample Contract",
        "",
        f"- [{_mark(requirements['total_at_least_10'])}] total >= 10",
        f"- [{_mark(requirements['english_at_least_3'])}] English >= 3",
        f"- [{_mark(requirements['experienced_at_least_4'])}] narrative-experienced >= 4",
        f"- [{_mark(requirements['inexperienced_at_least_4'])}] narrative-inexperienced >= 4",
        f"- Concrete three-week plans: **{report['concrete_plan_count']}/{report['session_count']}** "
        f"(required {report['concrete_plan_required']})",
        f"- P0 sessions: **{report['p0_session_count']}**",
        f"- Voluntary stops: **{report['voluntary_stop_count']}**",
        f"- Hesitated choices: **{report['hesitated_choice_count']}/{report['session_count']}**",
        "- Choice-stakes follow-up evidence: **{}** (report only; does not change status)".format(
            "REVIEW" if report["hesitation_stake_review_recommended"] else "not triggered"
        ),
        "",
        "## Response Medians",
        "",
    ]
    for field, value in report["medians"].items():
        lines.append(f"- {field}: **{value:g}/5**")
    lines.extend(
        [
            "",
            "## Distribution",
            "",
            f"- Languages: `{json.dumps(report['language_counts'], ensure_ascii=False, sort_keys=True)}`",
            f"- Experience: `{json.dumps(report['experience_counts'], ensure_ascii=False, sort_keys=True)}`",
            f"- Input: `{json.dumps(report['input_counts'], ensure_ascii=False, sort_keys=True)}`",
            f"- Plan scores: `{json.dumps(report['plan_score_counts'], sort_keys=True)}`",
            f"- Primary reasons: `{json.dumps(report['primary_reason_counts'], ensure_ascii=False, sort_keys=True)}`",
            f"- Remembered scenes: `{json.dumps(report['remembered_scene_counts'], ensure_ascii=False)}`",
            f"- Hesitated scenes: `{json.dumps(report['hesitated_scene_counts'], ensure_ascii=False)}`",
            f"- Art outliers: `{json.dumps(report['art_outlier_counts'], ensure_ascii=False)}`",
            "",
            "This report verifies sample integrity and threshold evidence only. "
            "It cannot certify that the demo is fun, commercially ready, or release-ready.",
        ]
    )
    return "\n".join(lines) + "\n"


def _fixture(index: int, plan_score: int = 2) -> dict[str, Any]:
    platform = "windows" if index % 2 else "macos"
    artifact = hashlib.sha256(platform.encode("ascii")).hexdigest()
    return {
        "schema_version": SCHEMA_VERSION,
        "session_id": f"P{index:02d}",
        "build_revision": "abcdef0",
        "manifest_sha256": "a" * 64,
        "artifact_sha256": artifact,
        "platform": platform,
        "language": "en" if index <= 3 else "ko",
        "input": "xbox" if index % 2 else "mouse_keyboard",
        "narrative_experience": "experienced" if index % 2 else "inexperienced",
        "duration_minutes": 30.0,
        "completed_full_session": True,
        "voluntary_stop": False,
        "p0_errors": [],
        "plan_score": plan_score,
        "plan_answer": "Find work, build a cash buffer, then study investing.",
        "remembered_choice": True,
        "remembered_choice_text": "The burner account offer.",
        "remembered_choice_scene": "arc_temptation_01",
        "hesitated_choice": index <= 3,
        "hesitated_choice_text": "The burner account offer." if index <= 3 else "",
        "hesitated_choice_scene": "week 4 / arc_temptation_01" if index <= 3 else "",
        "goal_clarity": 4,
        "weekly_decision_clarity": 4,
        "consequence_feel": 4,
        "ui_readability": 4,
        "art_fit": 4,
        "continue_intent": 4,
        "primary_reason_category": "continue",
        "continue_or_stop_reason": "I want to see the delayed result.",
        "art_outlier_scene": "",
        "observer_notes": "",
    }


def self_test() -> None:
    ready = [validate_session(_fixture(i, 2 if i <= 7 else 1)) for i in range(1, 11)]
    assert aggregate(ready)["status"] == STATUS_READY
    assert aggregate(ready[:5])["status"] == STATUS_INCOMPLETE

    canonical = {
        "id": "demo_rc_fixture",
        "status": "active",
        "commit": "abcdef0",
        "manifest_sha256": "a" * 64,
    }
    assert aggregate(ready, canonical)["status"] == STATUS_READY

    low_hesitation = [dict(session) for session in ready]
    for session in low_hesitation:
        session["hesitated_choice"] = False
        session["hesitated_choice_text"] = ""
        session["hesitated_choice_scene"] = ""
    low_hesitation[0]["hesitated_choice"] = True
    low_hesitation[0]["hesitated_choice_text"] = "The burner account offer."
    low_hesitation[0]["hesitated_choice_scene"] = "week 4 / arc_temptation_01"
    low_hesitation_report = aggregate(low_hesitation)
    assert low_hesitation_report["status"] == STATUS_READY
    assert low_hesitation_report["hesitation_stake_review_recommended"] is True

    weak = [validate_session(_fixture(i, 2 if i <= 6 else 1)) for i in range(1, 11)]
    assert aggregate(weak)["status"] == STATUS_NO_GO

    p0 = [dict(session) for session in ready]
    p0[0]["p0_errors"] = ["Progression blocked"]
    assert aggregate(p0)["status"] == STATUS_NO_GO

    duplicate = [dict(session) for session in ready]
    duplicate[1]["session_id"] = duplicate[0]["session_id"]
    try:
        validate_collection(duplicate)
        raise AssertionError("duplicate session was accepted")
    except ValidationFailure:
        pass

    mixed = [dict(session) for session in ready]
    mixed[-1]["build_revision"] = "1234567"
    try:
        validate_collection(mixed)
        raise AssertionError("mixed build revision was accepted")
    except ValidationFailure:
        pass

    stale_uniform = [dict(session) for session in ready]
    for session in stale_uniform:
        session["build_revision"] = "1234567"
        session["manifest_sha256"] = "b" * 64
    try:
        validate_collection(stale_uniform, canonical)
        raise AssertionError("uniform stale release candidate was accepted")
    except ValidationFailure as exc:
        assert any("stale or foreign build revision" in error for error in exc.errors)
        assert any("stale or foreign manifest" in error for error in exc.errors)

    invalid = _fixture(1)
    invalid["ui_readability"] = 6
    try:
        validate_session(invalid)
        raise AssertionError("invalid score was accepted")
    except ValidationFailure:
        pass

    malformed_enum = _fixture(1)
    malformed_enum["input"] = []
    try:
        validate_session(malformed_enum)
        raise AssertionError("malformed enum was accepted")
    except ValidationFailure:
        pass

    missing_hesitation_text = _fixture(1)
    missing_hesitation_text["hesitated_choice"] = True
    missing_hesitation_text["hesitated_choice_text"] = ""
    try:
        validate_session(missing_hesitation_text)
        raise AssertionError("hesitation without choice text was accepted")
    except ValidationFailure:
        pass

    print("PLAYTEST_REPORT_SELF_TEST_OK cases=11 stale_uniform=blocked")


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Validate and aggregate external no-instruction playtest JSON files."
    )
    parser.add_argument("sessions", nargs="*", type=Path)
    parser.add_argument("--self-test", action="store_true")
    parser.add_argument("--format", choices=("markdown", "json"), default="markdown")
    parser.add_argument(
        "--require-ready",
        action="store_true",
        help="exit 1 unless the structural evidence is ready for a human verdict",
    )
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    if args.self_test:
        self_test()
        return 0
    if not args.sessions:
        print("ERROR: supply one or more session JSON files", file=sys.stderr)
        return 2
    try:
        candidate = canonical_active_candidate(CANONICAL_GATE_ID)
        report = aggregate(
            load_sessions(args.sessions, candidate),
            candidate,
        )
    except (ValidationFailure, LedgerValidationError) as exc:
        for error in exc.errors:
            print(f"ERROR: {error}", file=sys.stderr)
        return 2

    if args.format == "json":
        print(json.dumps(report, ensure_ascii=False, indent=2, sort_keys=True))
    else:
        print(render_markdown(report), end="")
    if args.require_ready and report["status"] != STATUS_READY:
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
