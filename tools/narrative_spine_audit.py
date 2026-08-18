#!/usr/bin/env python3
"""Validate the language-independent five-chapter narrative spine."""

from __future__ import annotations

import glob
import json
import os
import sys
from typing import Any

from event_schedule import deferred_follow_ups


ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SPINE_PATH = os.path.join(ROOT, "content", "meta", "narrative_spine.json")
STORY_MAP_PATH = os.path.join(ROOT, "content", "meta", "story_map.json")
EVENTS_KO = os.path.join(ROOT, "content", "events")
EVENTS_EN = os.path.join(ROOT, "content", "events_en")
PHASES = ("setup", "escalation", "reversal", "boss", "aftermath")
CORE_CAST = {"father", "sangchul", "jaehyuk", "hyunsu", "daeun", "jiyeon"}
CHAPTER_PHASE_REQUIRED = {
    1: {
        "setup": {"story_knee_door", "story_last_payment_wait", "arc_intro_01_meal"},
        "escalation": {"arc_temptation_01", "cafe_00", "arc_sangchul_01_meet"},
        "reversal": {"arc_jiyeon_01_crash", "arc_jaehyuk_01_reunion"},
        "boss": {"arc_year1_close"},
        "aftermath": {"chapter_card_34"},
    },
    2: {
        "setup": {"arc_year_one_mark", "arc_34_money_attracts_money", "arc_sangchul_03_network"},
        "escalation": {"arc_daeun_03_fork", "arc_father_medication", "arc_jiyeon_03_offer"},
        "reversal": {"arc_34_doors_open", "arc_34_parents_visit", "arc_father_03_hospital"},
        "boss": {"arc_sangchul_mirror", "arc_career_ceiling", "arc_father_04_visit"},
        "aftermath": {"arc_year2_close"},
    },
    3: {
        "setup": {"arc_35_birthday", "arc_jiyeon_year3", "arc_jaehyuk_03_pitch"},
        "escalation": {"arc_father_06_confession", "arc_sangchul_known_offer", "arc_why_gangnam_real"},
        "reversal": {"arc_jaehyuk_aftermath", "arc_y3_jiyeon_departure", "arc_midpoint_reckoning"},
        "boss": {"arc_sangchul_confrontation", "arc_goal_vertigo"},
        "aftermath": {"arc_year3_close"},
    },
    4: {
        "setup": {
            "arc_35_path_cost",
            "arc_35_habit_check",
            "arc_36_reality_check",
            "arc_year_three_crossroads",
        },
        "escalation": {"arc_36_trust_crack", "arc_36_unexpected_hand"},
        "reversal": {"arc_father_call_on_ktx"},
        "boss": {"arc_father_passing"},
        "aftermath": {"arc_36_night_doubt", "arc_year4_close"},
    },
    5: {
        "setup": {"arc_37_reckoning", "arc_final_year_start"},
        "reversal": {"arc_father_legacy"},
        "boss": {"arc_final_countdown"},
        "aftermath": {"arc_final_week"},
    },
}

CHAPTER_TEMPORAL_REQUIRED = {
    1: {
        "arc_gosiwon_wall",
        "arc_goshiwon_goodbye",
        "arc_housing_new_life",
        "arc_intro_04_hyunsu",
        "arc_hyunsu_night_talk",
        "hyunsu_exam_day",
        "hyunsu_result_fail",
        "arc_hyunsu_exam_fail",
        "arc_hyunsu_drift",
        "arc_hyunsu_new_path",
    },
    2: {
        "arc_year_one_mark",
        "arc_year_one_half",
        "arc_34_two_years_in",
    },
    3: {
        "arc_jiyeon_year3",
        "arc_y3_jiyeon_departure",
        "arc_jaehyuk_03_pitch",
        "arc_father_06_confession",
        "arc_sangchul_confrontation",
        "arc_why_gangnam_real",
        "arc_goal_vertigo",
    },
    4: {
        "arc_35_path_cost",
        "arc_35_habit_check",
        "arc_almost_there",
        "arc_1b_isolation",
        "arc_final_stretch",
        "arc_36_body_signal",
        "arc_year_three_half",
        "arc_36_night_doubt",
        "arc_year4_close",
        "arc_37_reckoning",
        "arc_final_year_start",
    },
}

CHAPTER_TEMPORAL_COUNTS = {1: 2, 2: 1, 3: 4, 4: 3}
RELOCATED_SPINE_EVENTS = {"arc_jaehyuk_mirror"}
REQUIRED_CHAPTER_RELOCATIONS = {
    5: {("escalation", "arc_jaehyuk_mirror", 15)},
}
REQUIRED_DEFERRED_EDGES = {
    ("arc_year_one_half", "arc_34_two_years_in"): 18,
    ("arc_goal_vertigo", "arc_35_path_cost"): 22,
    ("arc_35_path_cost", "arc_35_habit_check"): 3,
    ("arc_almost_there", "arc_1b_isolation"): 4,
    ("arc_36_body_signal", "arc_year_three_half"): 6,
    ("arc_year_three_half", "arc_36_night_doubt"): 12,
    ("arc_year4_close", "arc_37_reckoning"): 5,
}
REQUIRED_IMMEDIATE_EDGES = {
    ("arc_37_reckoning", "arc_final_year_start"),
}


def load_json(path: str) -> Any:
    with open(path, encoding="utf-8") as handle:
        return json.load(handle)


def load_event_ids(directory: str) -> set[str]:
    event_ids: set[str] = set()
    for path in sorted(glob.glob(os.path.join(directory, "*.json"))):
        data = load_json(path)
        if not isinstance(data, list):
            continue
        for event in data:
            if isinstance(event, dict) and event.get("id"):
                event_ids.add(str(event["id"]))
    return event_ids


def load_event_map(directory: str) -> dict[str, dict[str, Any]]:
    events: dict[str, dict[str, Any]] = {}
    for path in sorted(glob.glob(os.path.join(directory, "*.json"))):
        data = load_json(path)
        if not isinstance(data, list):
            continue
        for event in data:
            if isinstance(event, dict) and event.get("id"):
                events[str(event["id"])] = event
    return events


def fail(errors: list[str], message: str) -> None:
    errors.append(message)


def collect_planned_events(
    story_map: Any, errors: list[str]
) -> tuple[dict[str, tuple[int, int]], dict[str, tuple[int, int, int]]]:
    """Index NEW roots and EXPAND+source relocations in one story-map traversal."""
    planned_events: dict[str, tuple[int, int]] = {}
    planned_relocations: dict[str, tuple[int, int, int]] = {}
    if not isinstance(story_map, dict):
        fail(errors, "story_map root must be an object")
        return planned_events, planned_relocations
    story_chapters = story_map.get("chapters", [])
    if not isinstance(story_chapters, list):
        fail(errors, "story_map chapters must be an array")
        return planned_events, planned_relocations
    for chapter in story_chapters:
        if not isinstance(chapter, dict):
            fail(errors, "story_map chapter must be an object")
            continue
        chapter_number = int(chapter.get("chapter", 0))
        months = chapter.get("months", [])
        if not isinstance(months, list):
            fail(errors, f"story_map chapter {chapter_number} months must be an array")
            continue
        for month in months:
            if not isinstance(month, dict):
                fail(errors, f"story_map chapter {chapter_number} month must be an object")
                continue
            month_number = int(month.get("month", 0))
            for beat in month.get("beats", []):
                if not isinstance(beat, dict):
                    continue
                event_id = str(beat.get("root", "")).strip()
                if beat.get("work") == "NEW" and beat.get("rule_status") == "planned":
                    if not event_id:
                        fail(
                            errors,
                            f"story_map chapter {chapter_number} month {month_number} "
                            "has a NEW/planned beat without a root",
                        )
                        continue
                    if event_id in planned_events:
                        fail(errors, f"story_map planned root duplicated: {event_id}")
                        continue
                    planned_events[event_id] = (chapter_number, month_number)
                if beat.get("work") == "EXPAND" and "source_month" in beat:
                    source_month = int(beat.get("source_month", 0))
                    if not event_id or source_month <= 0:
                        fail(
                            errors,
                            f"story_map chapter {chapter_number} month {month_number} "
                            "has an EXPAND relocation beat without root/source_month",
                        )
                        continue
                    if event_id in planned_relocations:
                        fail(errors, f"story_map relocated root duplicated: {event_id}")
                        continue
                    planned_relocations[event_id] = (
                        chapter_number,
                        month_number,
                        source_month,
                    )
    return planned_events, planned_relocations


def require_planned_event(
    event_id: str,
    chapter_number: int,
    context: str,
    planned_events: dict[str, tuple[int, int]],
    ko_ids: set[str],
    en_ids: set[str],
    errors: list[str],
) -> None:
    planned_location = planned_events.get(event_id)
    if planned_location is None:
        fail(errors, f"{context} is not a story_map NEW/planned root: {event_id}")
    elif planned_location[0] != chapter_number:
        fail(
            errors,
            f"{context} chapter mismatch: {event_id} is declared for "
            f"chapter {planned_location[0]}, not {chapter_number}",
        )
    if event_id in ko_ids or event_id in en_ids:
        fail(errors, f"{context} already exists: {event_id}")


def require_planned_relocation(
    event_id: str,
    chapter_number: int,
    source_month: int,
    context: str,
    planned_relocations: dict[str, tuple[int, int, int]],
    ko_ids: set[str],
    en_ids: set[str],
    errors: list[str],
) -> None:
    planned_location = planned_relocations.get(event_id)
    if planned_location is None:
        fail(errors, f"{context} is not a story_map EXPAND+source root: {event_id}")
    elif planned_location[0] != chapter_number or planned_location[2] != source_month:
        fail(
            errors,
            f"{context} relocation mismatch: {event_id} is chapter "
            f"{planned_location[0]} from M{planned_location[2]}, not chapter "
            f"{chapter_number} from M{source_month}",
        )
    if event_id not in ko_ids:
        fail(errors, f"{context} lacks existing KO event: {event_id}")
    if event_id not in en_ids:
        fail(errors, f"{context} lacks existing EN event: {event_id}")


def require_event(
    event_id: str,
    context: str,
    ko_ids: set[str],
    en_ids: set[str],
    errors: list[str],
) -> None:
    if event_id not in ko_ids:
        fail(errors, f"{context}: missing KO event {event_id}")
    if event_id not in en_ids:
        fail(errors, f"{context}: missing EN event {event_id}")


def main() -> int:
    errors: list[str] = []
    if not os.path.exists(SPINE_PATH):
        print(f"NARRATIVE_SPINE_AUDIT_ERROR missing {SPINE_PATH}")
        return 1

    spine = load_json(SPINE_PATH)
    story_map = load_json(STORY_MAP_PATH)
    ko_ids = load_event_ids(EVENTS_KO)
    en_ids = load_event_ids(EVENTS_EN)
    ko_events = load_event_map(EVENTS_KO)
    if not isinstance(spine, dict):
        print("NARRATIVE_SPINE_AUDIT_ERROR root must be an object")
        return 1
    planned_events, planned_relocations = collect_planned_events(story_map, errors)
    authored_story_events: set[tuple[int, str]] = set()
    for chapter in story_map.get("chapters", []) if isinstance(story_map, dict) else []:
        if not isinstance(chapter, dict):
            continue
        chapter_number = int(chapter.get("chapter", 0))
        for month in chapter.get("months", []):
            if not isinstance(month, dict):
                continue
            for beat in month.get("beats", []):
                if not isinstance(beat, dict) or beat.get("work") == "NEW":
                    continue
                event_id = str(beat.get("root", ""))
                if event_id in ko_ids and event_id in en_ids:
                    authored_story_events.add((chapter_number, event_id))

    central_question = str(spine.get("central_question", "")).strip()
    if len(central_question) < 20:
        fail(errors, "central_question is missing or too shallow")
    if len(str(spine.get("player_promise", "")).strip()) < 20:
        fail(errors, "player_promise is missing or too shallow")

    world_laws = spine.get("world_laws", [])
    if not isinstance(world_laws, list) or len(world_laws) < 5:
        fail(errors, "world_laws must contain at least five dramatic laws")
        world_laws = []
    law_ids: set[str] = set()
    for law in world_laws:
        if not isinstance(law, dict):
            fail(errors, "world_laws entries must be objects")
            continue
        law_id = str(law.get("id", ""))
        if not law_id or law_id in law_ids:
            fail(errors, f"world law id missing or duplicated: {law_id}")
        law_ids.add(law_id)
        proof = law.get("proof", [])
        if not isinstance(proof, list) or len(proof) < 3:
            fail(errors, f"world law {law_id} needs at least three event proofs")
        for event_id in proof if isinstance(proof, list) else []:
            require_event(str(event_id), f"world law {law_id}", ko_ids, en_ids, errors)

    characters = spine.get("characters", [])
    character_ids = {
        str(row.get("id", "")) for row in characters if isinstance(row, dict)
    }
    if character_ids != CORE_CAST:
        fail(errors, f"core cast mismatch: {sorted(character_ids)}")
    planned_character_anchors = 0
    required_ensemble_anchors = {
        "sangchul": (5, "arc_y5_three_in_room"),
        "jaehyuk": (5, "arc_y5_three_in_room"),
    }
    required_character_relocations = {
        "jaehyuk": (5, "arc_jaehyuk_mirror", 15),
    }
    for row in characters if isinstance(characters, list) else []:
        if not isinstance(row, dict):
            continue
        character_id = str(row.get("id", ""))
        chapters = row.get("chapters", [])
        anchors = row.get("anchors", [])
        planned_anchors = row.get("planned_anchors", [])
        if len(str(row.get("function", "")).strip()) < 15:
            fail(errors, f"character {character_id} lacks a dramatic function")
        if not isinstance(chapters, list) or len(set(chapters)) < 4:
            fail(errors, f"character {character_id} is not carried across the epic")
        if not isinstance(anchors, list) or len(anchors) < 3:
            fail(errors, f"character {character_id} needs at least three anchors")
        for event_id in anchors if isinstance(anchors, list) else []:
            if str(event_id) in RELOCATED_SPINE_EVENTS:
                fail(
                    errors,
                    f"character {character_id} authored anchor is planned for relocation: "
                    f"{event_id}",
                )
            require_event(str(event_id), f"character {character_id}", ko_ids, en_ids, errors)
        if not isinstance(planned_anchors, list):
            fail(errors, f"character {character_id} planned_anchors must be an array")
            planned_anchors = []
        planned_pairs: set[tuple[int, str]] = set()
        relocation_pairs: set[tuple[int, str, int]] = set()
        for planned_anchor in planned_anchors:
            if not isinstance(planned_anchor, dict):
                fail(errors, f"character {character_id} planned anchor must be an object")
                continue
            chapter_number = int(planned_anchor.get("chapter", 0))
            event_id = str(planned_anchor.get("event", "")).strip()
            mode = str(planned_anchor.get("mode", "new"))
            planned_pair = (chapter_number, event_id)
            if planned_pair in planned_pairs:
                fail(errors, f"character {character_id} planned anchor duplicated: {event_id}")
                continue
            planned_pairs.add(planned_pair)
            planned_character_anchors += 1
            if chapter_number not in chapters:
                fail(
                    errors,
                    f"character {character_id} planned anchor chapter {chapter_number} "
                    "is absent from its declared chapters",
                )
            if event_id in anchors:
                fail(
                    errors,
                    f"character {character_id} planned anchor is already authored: {event_id}",
                )
            if mode == "new":
                require_planned_event(
                    event_id,
                    chapter_number,
                    f"character {character_id} planned anchor",
                    planned_events,
                    ko_ids,
                    en_ids,
                    errors,
                )
            elif mode == "expand":
                source_month = int(planned_anchor.get("source_month", 0))
                relocation_pair = (chapter_number, event_id, source_month)
                relocation_pairs.add(relocation_pair)
                require_planned_relocation(
                    event_id,
                    chapter_number,
                    source_month,
                    f"character {character_id} planned anchor",
                    planned_relocations,
                    ko_ids,
                    en_ids,
                    errors,
                )
            else:
                fail(errors, f"character {character_id} planned anchor has invalid mode: {mode}")
        required_ensemble_anchor = required_ensemble_anchors.get(character_id)
        if required_ensemble_anchor:
            if required_ensemble_anchor in authored_story_events:
                if required_ensemble_anchor[1] not in anchors:
                    fail(
                        errors,
                        f"character {character_id} must own authored chapter 5 ensemble "
                        "anchor arc_y5_three_in_room",
                    )
            elif required_ensemble_anchor not in planned_pairs:
                fail(
                    errors,
                    f"character {character_id} must plan chapter 5 ensemble anchor "
                    "arc_y5_three_in_room",
                )
        required_relocation = required_character_relocations.get(character_id)
        if required_relocation and required_relocation not in relocation_pairs:
            fail(
                errors,
                f"character {character_id} must expand/relocate arc_jaehyuk_mirror "
                "from M15 to chapter 5",
            )

    # 조연 정본: CORE_CAST의 "전 편 관통" 계약을 흔들지 않으면서 반복 등장
    # 인물을 등재한다. 특정 장에만 존재하는 것이 설계인 인물이 있다 —
    # 먼저 도착한 사람은 주인공이 도착 근처에 갔을 때만 의미를 가진다.
    supporting = spine.get("supporting_cast", [])
    if not isinstance(supporting, list):
        fail(errors, "supporting_cast must be a list")
        supporting = []
    for row in supporting:
        if not isinstance(row, dict):
            fail(errors, "supporting cast entry must be an object")
            continue
        support_id = str(row.get("id", ""))
        if support_id in CORE_CAST:
            fail(errors, f"supporting cast {support_id} duplicates the core cast")
        if len(str(row.get("function", "")).strip()) < 15:
            fail(errors, f"supporting cast {support_id} lacks a dramatic function")
        support_chapters = row.get("chapters", [])
        if not isinstance(support_chapters, list) or not support_chapters:
            fail(errors, f"supporting cast {support_id} needs at least one chapter")
        if len(set(support_chapters)) >= 4:
            fail(errors, f"supporting cast {support_id} spans the epic; promote to core cast")
        if len(set(support_chapters)) < 4 and not str(row.get("late_by_design", "")).strip():
            fail(errors, f"supporting cast {support_id} must state why it is confined")
        support_anchors = row.get("anchors", [])
        if not isinstance(support_anchors, list) or len(support_anchors) < 3:
            fail(errors, f"supporting cast {support_id} needs at least three anchors")
        for event_id in support_anchors if isinstance(support_anchors, list) else []:
            require_event(
                str(event_id), f"supporting cast {support_id}", ko_ids, en_ids, errors
            )

    chapters = spine.get("chapters", [])
    if not isinstance(chapters, list) or len(chapters) != 5:
        fail(errors, "exactly five chapters are required")
        chapters = []
    expected_start = 1
    phase_owner: dict[str, int] = {}
    chapter_relocations: set[tuple[int, str, str, int]] = set()
    for expected_number, chapter in enumerate(chapters, start=1):
        if not isinstance(chapter, dict):
            fail(errors, f"chapter {expected_number} must be an object")
            continue
        number = int(chapter.get("number", 0))
        if number != expected_number:
            fail(errors, f"chapter order mismatch: expected {expected_number}, got {number}")

        # 시스템 척추: 서사가 다섯 번 질문을 바꾸는 동안 플레이어의 동사가
        # 그대로면 5년이 수치 등반이 된다. 각 장은 무엇을 열고 무엇을 닫는지
        # 선언하며, 닫는 것이 없는 장은 첫 장뿐이다.
        system = chapter.get("system", {})
        if not isinstance(system, dict):
            fail(errors, f"chapter {expected_number} system must be an object")
            system = {}
        for field in ("opens", "pressure", "failure"):
            if len(str(system.get(field, "")).strip()) < 5:
                fail(errors, f"chapter {expected_number} system lacks {field}")
        closes = str(system.get("closes", "")).strip()
        if expected_number == 1 and closes:
            fail(errors, "chapter 1 closes nothing; it opens the verbs")
        if expected_number > 1 and len(closes) < 5:
            fail(errors,
                 f"chapter {expected_number} must close something the run already opened")
        weeks = chapter.get("weeks", [])
        if not isinstance(weeks, list) or len(weeks) != 2:
            fail(errors, f"chapter {number} has invalid week window")
        else:
            start, end = int(weeks[0]), int(weeks[1])
            if start != expected_start or end - start != 47:
                fail(errors, f"chapter {number} must own 48 contiguous weeks")
            expected_start = end + 1
        for key in ("title_ko", "title_en", "question", "object", "handoff"):
            minimum = 2 if key == "title_ko" else 4
            if len(str(chapter.get(key, "")).strip()) < minimum:
                fail(errors, f"chapter {number} missing {key}")
        for phase in PHASES:
            event_ids = chapter.get(phase, [])
            if not isinstance(event_ids, list) or not event_ids:
                fail(errors, f"chapter {number} has no {phase}")
                continue
            for raw_event_id in event_ids:
                event_id = str(raw_event_id)
                if event_id in RELOCATED_SPINE_EVENTS:
                    fail(
                        errors,
                        f"chapter {number} {phase} still authors relocated event {event_id}",
                    )
                require_event(event_id, f"chapter {number} {phase}", ko_ids, en_ids, errors)
                if event_id in phase_owner:
                    fail(
                        errors,
                        f"event {event_id} belongs to chapters {phase_owner[event_id]} and {number}",
                    )
                phase_owner[event_id] = number
        for phase, required_ids in CHAPTER_PHASE_REQUIRED.get(number, {}).items():
            actual_ids = {str(value) for value in chapter.get(phase, [])}
            missing_ids = sorted(required_ids - actual_ids)
            if missing_ids:
                fail(
                    errors,
                    f"chapter {number} {phase} lost required anchors: {missing_ids}",
                )
        relocation_rows = chapter.get("planned_relocations", [])
        if not isinstance(relocation_rows, list):
            fail(errors, f"chapter {number} planned_relocations must be an array")
            relocation_rows = []
        for relocation in relocation_rows:
            if not isinstance(relocation, dict):
                fail(errors, f"chapter {number} planned relocation must be an object")
                continue
            phase = str(relocation.get("phase", ""))
            event_id = str(relocation.get("event", "")).strip()
            source_month = int(relocation.get("source_month", 0))
            relocation_contract = (number, phase, event_id, source_month)
            if relocation_contract in chapter_relocations:
                fail(errors, f"chapter {number} planned relocation duplicated: {event_id}")
                continue
            chapter_relocations.add(relocation_contract)
            if phase not in PHASES:
                fail(errors, f"chapter {number} planned relocation has invalid phase: {phase}")
            require_planned_relocation(
                event_id,
                number,
                source_month,
                f"chapter {number} planned relocation",
                planned_relocations,
                ko_ids,
                en_ids,
                errors,
            )
        if number in CHAPTER_TEMPORAL_COUNTS:
            temporal_spines = chapter.get("temporal_spines", [])
            required_count = CHAPTER_TEMPORAL_COUNTS[number]
            if not isinstance(temporal_spines, list) or len(temporal_spines) != required_count:
                fail(
                    errors,
                    f"chapter {number} must contain exactly {required_count} temporal spines",
                )
                temporal_spines = []
            temporal_ids: set[str] = set()
            temporal_events: set[str] = set()
            for temporal_spine in temporal_spines:
                if not isinstance(temporal_spine, dict):
                    fail(errors, f"chapter {number} temporal spine entries must be objects")
                    continue
                temporal_id = str(temporal_spine.get("id", ""))
                if not temporal_id or temporal_id in temporal_ids:
                    fail(
                        errors,
                        f"chapter {number} temporal spine id missing or duplicated: {temporal_id}",
                    )
                temporal_ids.add(temporal_id)
                temporal_event_ids = temporal_spine.get("events", [])
                if not isinstance(temporal_event_ids, list) or len(temporal_event_ids) < 3:
                    fail(
                        errors,
                        f"chapter {number} temporal spine {temporal_id} needs at least three events",
                    )
                    temporal_event_ids = []
                if len(str(temporal_spine.get("payoff", "")).strip()) < 15:
                    fail(
                        errors,
                        f"chapter {number} temporal spine {temporal_id} lacks a payoff",
                    )
                for temporal_event_id in temporal_event_ids:
                    event_id = str(temporal_event_id)
                    if event_id in RELOCATED_SPINE_EVENTS:
                        fail(
                            errors,
                            f"chapter {number} temporal spine {temporal_id} still authors "
                            f"relocated event {event_id}",
                        )
                    require_event(
                        event_id,
                        f"chapter {number} temporal spine {temporal_id}",
                        ko_ids,
                        en_ids,
                        errors,
                    )
                    temporal_events.add(event_id)
            required_temporal_events = CHAPTER_TEMPORAL_REQUIRED[number]
            missing_temporal_events = sorted(required_temporal_events - temporal_events)
            if missing_temporal_events:
                fail(
                    errors,
                    f"chapter {number} temporal spines lost anchors: {missing_temporal_events}",
                )
    for chapter_number, required_relocations in REQUIRED_CHAPTER_RELOCATIONS.items():
        missing_relocations = sorted(
            required_relocations
            - {
                (phase, event_id, source_month)
                for owner, phase, event_id, source_month in chapter_relocations
                if owner == chapter_number
            }
        )
        if missing_relocations:
            fail(
                errors,
                f"chapter {chapter_number} lost planned relocations: {missing_relocations}",
            )
    if expected_start != 241:
        fail(errors, f"chapter windows must end at week 240, got {expected_start - 1}")

    for (source, target), delay in REQUIRED_DEFERRED_EDGES.items():
        choices = ko_events.get(source, {}).get("choices", [])
        if not choices or any(
            (target, delay) not in deferred_follow_ups(choice)
            for choice in choices
            if isinstance(choice, dict)
        ):
            fail(errors, f"temporal edge drift: {source} -{delay}w-> {target}")
    for source, target in REQUIRED_IMMEDIATE_EDGES:
        choices = ko_events.get(source, {}).get("choices", [])
        if not choices or any(
            str(choice.get("follow_up_event", "")) != target
            for choice in choices
            if isinstance(choice, dict)
        ):
            fail(errors, f"immediate edge drift: {source} -> {target}")

    motifs = spine.get("motifs", [])
    if not isinstance(motifs, list) or len(motifs) < 5:
        fail(errors, "at least five recurring motifs are required")
        motifs = []
    motif_ids: set[str] = set()
    chapter_five_readers = 0
    for motif in motifs:
        if not isinstance(motif, dict):
            fail(errors, "motif entries must be objects")
            continue
        motif_id = str(motif.get("id", ""))
        if not motif_id or motif_id in motif_ids:
            fail(errors, f"motif id missing or duplicated: {motif_id}")
        motif_ids.add(motif_id)
        plant = motif.get("plant", {})
        readers = motif.get("readers", [])
        planned_readers = motif.get("planned_readers", [])
        if not isinstance(plant, dict) or int(plant.get("chapter", 0)) != 1:
            fail(errors, f"motif {motif_id} must be planted in chapter 1")
            plant = {}
        plant_event = str(plant.get("event", ""))
        require_event(plant_event, f"motif {motif_id} plant", ko_ids, en_ids, errors)
        if not isinstance(readers, list) or len(readers) < 2:
            fail(errors, f"motif {motif_id} needs at least two later readers")
            readers = []
        if not isinstance(planned_readers, list):
            fail(errors, f"motif {motif_id} planned_readers must be an array")
            planned_readers = []
        seen_late = False
        has_chapter_five_reader = False
        for reader in readers:
            if not isinstance(reader, dict):
                fail(errors, f"motif {motif_id} reader must be an object")
                continue
            chapter_number = int(reader.get("chapter", 0))
            if chapter_number <= int(plant.get("chapter", 1)):
                fail(errors, f"motif {motif_id} reader must occur after its plant")
            if chapter_number >= 3:
                seen_late = True
            if chapter_number == 5:
                has_chapter_five_reader = True
            reader_event_id = str(reader.get("event", ""))
            if reader_event_id in RELOCATED_SPINE_EVENTS:
                fail(
                    errors,
                    f"motif {motif_id} authored reader is planned for relocation: "
                    f"{reader_event_id}",
                )
            require_event(
                reader_event_id,
                f"motif {motif_id} reader",
                ko_ids,
                en_ids,
                errors,
            )
        for reader in planned_readers:
            if not isinstance(reader, dict):
                fail(errors, f"motif {motif_id} planned reader must be an object")
                continue
            chapter_number = int(reader.get("chapter", 0))
            event_id = str(reader.get("event", "")).strip()
            mode = str(reader.get("mode", "new"))
            if chapter_number <= int(plant.get("chapter", 1)):
                fail(errors, f"motif {motif_id} planned reader must occur after its plant")
            if chapter_number >= 3:
                seen_late = True
            if chapter_number == 5:
                has_chapter_five_reader = True
            if mode == "new":
                require_planned_event(
                    event_id,
                    chapter_number,
                    f"motif {motif_id} planned reader",
                    planned_events,
                    ko_ids,
                    en_ids,
                    errors,
                )
            elif mode == "expand":
                require_planned_relocation(
                    event_id,
                    chapter_number,
                    int(reader.get("source_month", 0)),
                    f"motif {motif_id} planned reader",
                    planned_relocations,
                    ko_ids,
                    en_ids,
                    errors,
                )
            else:
                fail(errors, f"motif {motif_id} planned reader has invalid mode: {mode}")
        if has_chapter_five_reader:
            chapter_five_readers += 1
        if not seen_late:
            fail(errors, f"motif {motif_id} never survives into chapter 3+")
        if motif_id == "signature":
            signature_readers = {
                (int(reader.get("chapter", 0)), str(reader.get("event", "")))
                for reader in readers
                if isinstance(reader, dict)
            }
            if (5, "arc_final_countdown") not in signature_readers:
                fail(errors, "signature motif must resolve through arc_final_countdown")
    if chapter_five_readers < len(motifs):
        fail(errors, "every chapter-1 motif needs at least one chapter-5 reader")

    demo = spine.get("demo", {})
    sequences = demo.get("sequences", []) if isinstance(demo, dict) else []
    if not isinstance(sequences, list) or not 7 <= len(sequences) <= 9:
        fail(errors, "demo must contain seven to nine novel sequences")
        sequences = []
    foreground_roots: set[str] = set()
    last_end = -1
    for sequence in sequences:
        if not isinstance(sequence, dict):
            fail(errors, "demo sequence must be an object")
            continue
        sequence_id = str(sequence.get("id", ""))
        weeks = sequence.get("weeks", [])
        roots = sequence.get("foreground_roots", [])
        if not isinstance(weeks, list) or len(weeks) != 2:
            fail(errors, f"demo sequence {sequence_id} has invalid weeks")
        else:
            start, end = int(weeks[0]), int(weeks[1])
            if start > end or start <= last_end:
                fail(errors, f"demo sequence {sequence_id} overlaps or reverses time")
            last_end = end
        if not isinstance(roots, list) or len(roots) < 2:
            fail(errors, f"demo sequence {sequence_id} needs at least two foreground roots")
            roots = []
        if len(str(sequence.get("promise", "")).strip()) < 15:
            fail(errors, f"demo sequence {sequence_id} lacks an end promise")
        for event_id in roots:
            event_id = str(event_id)
            require_event(event_id, f"demo sequence {sequence_id}", ko_ids, en_ids, errors)
            if event_id in foreground_roots:
                fail(errors, f"demo foreground root duplicated: {event_id}")
            foreground_roots.add(event_id)
    if last_end != 24:
        fail(errors, f"demo sequence windows must end at week 24, got {last_end}")

    bridge_roots = demo.get("bridge_roots", []) if isinstance(demo, dict) else []
    if not isinstance(bridge_roots, list) or len(bridge_roots) < 4:
        fail(errors, "demo needs at least four explicitly demoted bridge roots")
        bridge_roots = []
    for bridge in bridge_roots:
        if not isinstance(bridge, dict):
            fail(errors, "bridge root must be an object")
            continue
        event_id = str(bridge.get("event", ""))
        require_event(event_id, "demo bridge", ko_ids, en_ids, errors)
        if event_id in foreground_roots:
            fail(errors, f"demo bridge is also foreground: {event_id}")
        if len(str(bridge.get("resolution", "")).strip()) < 10:
            fail(errors, f"demo bridge {event_id} lacks a resolution contract")

    if errors:
        for error in errors:
            print(f"NARRATIVE_SPINE_AUDIT_ERROR {error}")
        return 1

    print(
        "NARRATIVE_SPINE_AUDIT_OK "
        f"chapters={len(chapters)} characters={len(characters)} "
        f"planned_character_anchors={planned_character_anchors} "
        f"planned_relocations={len(chapter_relocations)} "
        f"supporting={len(supporting)} system_spine=5 "
        f"world_laws={len(world_laws)} motifs={len(motifs)} "
        f"chapter5_readers={chapter_five_readers} "
        f"demo_sequences={len(sequences)} foreground={len(foreground_roots)} "
        f"bridges={len(bridge_roots)}"
    )
    return 0


if __name__ == "__main__":
    sys.exit(main())
