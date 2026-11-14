#!/usr/bin/env python3
"""Validate scene-level music, ambience, and paragraph cue coverage."""

from __future__ import annotations

import glob
import json
import re
from pathlib import Path

import peak_scene_chain_audit as peaks


ROOT = Path(__file__).resolve().parents[1]
MANIFEST_PATH = ROOT / "assets" / "scene_audio_manifest.json"
ACTING_PATH = ROOT / "assets" / "cg_acting_manifest.json"
DYNAMIC_AMBIENCE_KEYS = {"current_housing", "current_workplace"}
HYUNSU_EXAM_FAILURE_EVENT = "hyunsu_result_fail"
HYUNSU_EXAM_FAILURE_AUDIO = {
    "ambience": "apartment", "suppress_music": True,
    "suppress_human_ambience": True, "suppress_season_ambience": True,
}
GOSHIWON_MOVEOUT_EVENT = "arc_goshiwon_goodbye"
GOSHIWON_MOVEOUT_AUDIO = {
    "ambience": "goshiwon_hallway", "suppress_music": True,
    "suppress_human_ambience": True, "suppress_season_ambience": True,
    "result_paragraph_cues": {"0": {"2": [{"sfx": "traffic_pass", "volume_db": -10.0}]}},
}
HYUNSU_DRIFT_EVENT = "arc_hyunsu_drift"
HYUNSU_CALL_EVENT = "arc_hyunsu_new_path"
HYUNSU_DRIFT_AUDIO = {
    "ambience": "apartment", "suppress_music": True,
    "suppress_human_ambience": True, "suppress_season_ambience": True,
}
M14_BANK_EVENT = "arc_y2_bank_limit_review"
M14_BANK_BACKGROUNDS = ("bank_loan_counter_day", "bank_loan_exit_day")
M14_BANK_RESULT_CUES = {
    "0": {"0": [{"sfx": "paper_handle", "volume_db": -8.0}]},
    "1": {"1": [{"sfx": "paper_handle", "volume_db": -8.0}]},
    "2": {"0": [{"sfx": "pen_write", "volume_db": -8.0}],
          "1": [{"sfx": "traffic_pass", "volume_db": -10.0}]},
}
W224_CUSTODY_EVENT = "arc_y5_father_trace_custody"
W224_CUSTODY_AUDIO = {
    "ambience": "intentional_silence",
    "music": {"key": "reckoning", "start_paragraph": 1},
    "paragraph_cues": {"0": [{"sfx": "paper_handle", "volume_db": -7.0}]},
    "result_paragraph_cues": {
        "0": {"0": [{"sfx": "paper_handle", "volume_db": -6.0}]},
        "1": {"0": [{"sfx": "paper_handle", "volume_db": -8.0}]},
    },
}
W227_INTAKE_EVENT = "arc_y5_name_on_line_daeun_routed"
W227_INTAKE_BACKGROUND = "finale_intake_blue_pen"
W227_INTAKE_AUDIO = {
    "ambience": "intentional_silence",
    "music": {"key": "reckoning", "start_paragraph": 1},
    "result_paragraph_cues": {
        "0": {"0": [{"sfx": "paper_handle", "volume_db": -6.0}]},
        "1": {"0": [{"sfx": "pen_write", "volume_db": -5.0}]},
        "3": {"0": [{"sfx": "pen_write", "volume_db": -5.0}]},
    },
}
W230_VERDICT_EVENT = "arc_y5_people_verdict_daeun_exact"
W230_VERDICT_AUDIO = {
    "ambience": "intentional_silence",
    "music": {"key": "reckoning", "start_paragraph": 1},
    "paragraph_cues": {"0": [{"sfx": "paper_handle", "volume_db": -7.0}]},
    "result_paragraph_cues": {
        "0": {"0": [{"sfx": "pen_write", "volume_db": -7.0}]},
        "1": {"0": [{"sfx": "pen_write", "volume_db": -6.0}]},
        "2": {"0": [{"sfx": "pen_write", "volume_db": -7.0}]},
    },
}
W234_SUMMIT_EVENT = "arc_y5_general_pre_ending_summit_exact"
W234_SUMMIT_AUDIO = {
    "ambience": "intentional_silence",
    "music": {"key": "reckoning", "start_paragraph": 1},
    "paragraph_cues": {"0": [{"sfx": "paper_handle", "volume_db": -8.0}]},
    "result_paragraph_cues": {"1": {"0": [{"sfx": "paper_handle", "volume_db": -8.0}]}},
}
W235_NOTICE_EVENT = "arc_y5_property_not_executed_notice"
W235_NOTICE_AUDIO = {
    "ambience": "current_housing",
    "suppress_music": True,
    "result_paragraph_cues": {"0": {"1": [{"sfx": "paper_handle", "volume_db": -8.0}]}},
}
W237_FINAL_RECORD_EVENT = "arc_y5_general_final_record_seal"
W237_FINAL_RECORD_AUDIO = {
    "ambience": "current_housing",
    "music": {"key": "reckoning", "start_paragraph": 1},
    "paragraph_cues": {
        "0": [{"sfx": "phone_vibrate", "volume_db": -8.0}],
        "3": [{"sfx": "phone_vibrate", "volume_db": -8.0}],
    },
    "result_paragraph_cues": {"0": {"1": [{"sfx": "page_turn", "volume_db": -7.0}]}},
}
W240_OUTDOOR_SIGNATURE_EVENT = "arc_final_countdown_property_not_executed"
W240_OUTDOOR_SIGNATURE_AUDIO = {
    "ambience": "intentional_silence",
    "music": {"key": "reckoning", "start_paragraph": 1},
    "paragraph_cues": {"0": [{"sfx": "paper_handle", "volume_db": -9.0}]},
    "result_paragraph_cues": {
        "0": {"0": [{"sfx": "pen_write", "volume_db": -5.0}]},
        "1": {"0": [{"sfx": "pen_write", "volume_db": -6.0}]},
        "2": {"0": [{"sfx": "pen_write", "volume_db": -6.0}]},
    },
}
SINCHON_REUNION_EVENT = "arc_jiyeon_02_store"
SINCHON_REUNION_BACKGROUNDS = (
    "sinchon_bus_stop_after_rain_night",
    "sinchon_bus_stop_sedan_night",
    "sinchon_bus_stop_distant_bus_night",
)
SINCHON_REUNION_AUDIO = {
    "ambience": "intentional_silence",
    "music": {"key": "jiyeon", "start_paragraph": 2},
    "paragraph_cues": {"1": [{"sfx": "traffic_pass", "volume_db": -10.0}]},
}
SINCHON_OFFER_EVENT = "arc_jiyeon_03_offer"
SINCHON_OFFER_STOP = "sinchon_main_road_bus_stop_rain_overcast"
SINCHON_OFFER_SEDAN = "sinchon_offer_sedan_rain"
SINCHON_OFFER_RESULTS = (
    ("sinchon_offer_station_approach_rain", None),
    ("sinchon_offer_cafe_two_coffees", "intentional_silence"),
    (SINCHON_OFFER_SEDAN, None),
)
SINCHON_OFFER_AUDIO = {
    "ambience": "rain",
    "suppress_music": True,
    "suppress_human_ambience": True,
    "suppress_season_ambience": True,
    "paragraph_cues": {"1": [{"sfx": "traffic_pass", "volume_db": -10.0}]},
}
M23_PARENTS_EVENT = "arc_34_parents_visit"
M23_PARENTS_CONCOURSE = "seoul_station_parents_concourse"
M23_PARENTS_GATE = "seoul_station_parents_ticket_gate"
M23_PARENTS_QUIET_BACKGROUNDS = (
    M23_PARENTS_CONCOURSE,
    M23_PARENTS_GATE,
    "parents_visit_food_bag_in_transit",
)
M23_PARENTS_END_BACKGROUNDS = (M23_PARENTS_GATE, "current_housing")
M23_PARENTS_AUDIO = {
    "ambience": "intentional_silence",
    "suppress_music": True,
    "suppress_human_ambience": True,
    "suppress_season_ambience": True,
}
M23_MOTHER_CALL_EVENT = "arc_father_03_hospital"
M23_FIRST_KTX_PLATFORM = "seoul_station_first_ktx_predawn"
M23_FIRST_KTX_CABIN = "ktx_changwon_first_train_predawn"
NEUTRAL_HOME_AUDIO = {
    "ambience": "apartment",
    "suppress_music": True,
    "suppress_human_ambience": True,
    "suppress_season_ambience": True,
}
HYUNSU_CALL_AUDIO = {
    **NEUTRAL_HOME_AUDIO,
    "paragraph_cues": {"2": [{"sfx": "keyboard_phone", "volume_db": -1.0}]},
    "result_paragraph_cues": {"1": {"1": [{"sfx": "keyboard_phone", "volume_db": -1.0}]}},
}
W96_HOSPITAL_VISIT_EVENT = "arc_father_04_visit"
W96_SEOUL_ARRIVAL = "seoul_station_visitor_sticker"
W96_HOSPITAL_VISIT_AUDIO = {
    "ambience": "hospital",
    "music": {"key": "grief", "start_paragraph": 0},
}
W100_FATHER_OUTREACH_EVENT = "arc_y3_father_avoidance_document"
W53_NETWORK_EVENT = "arc_sangchul_03_network"
W53_DINING = "sangchul_private_dining"
W72_DINNER_EVENT = "arc_sangchul_human"
W72_DINNER_AUDIO = {
    "ambience": "intentional_silence", "suppress_human_ambience": True, "suppress_season_ambience": True,
}
W82_BUS_EVENT = "arc_y2_hyunsu_night_bus"
W161_BODY_EVENT = "arc_36_body_signal"
W161_MOVING_AUDIO = {"ambience": "seoul_subway_onboard", "suppress_music": True,
                     "suppress_human_ambience": True, "suppress_season_ambience": True}
W132_CAFE_EVENTS = ("arc_sangchul_reckoning", "arc_sangchul_stairwell")
W132_CAFE_AUDIO = {**W72_DINNER_AUDIO, "music": {"key": "reckoning", "start_paragraph": 0}}
W205_MINSEO_PHONE = "arc_minseo_03b_not_arrived"
W57_MEDICATION_EVENT = "arc_father_medication"
W57_MEDICATION_AUDIO = {
    "ambience": "intentional_silence",
    "suppress_music": True,
    "suppress_human_ambience": True,
    "suppress_season_ambience": True,
    "paragraph_cues": {"0": [{"sfx": "phone_vibrate", "volume_db": -8.0}]},
}
W37_FIRST_BILL_EVENT = "arc_y1_new_room_first_month"
W45_DECEMBER_EVENT = "story_one_year"
W45_DECEMBER_AUDIO = {
    "ambience": "apartment", "suppress_human_ambience": True, "suppress_season_ambience": True,
}
DAEUN_CONVENIENCE_EVENT = "arc_daeun_02_regular"
DAEUN_CONVENIENCE_INSIDE = "convenience_afternoon"
DAEUN_CONVENIENCE_OUTSIDE = "convenience_afternoon_exterior"
DAEUN_QUIET_RESULT_CGS = (
    "cg_daeun_regular_bunsik", "cg_daeun_regular_walk", "cg_daeun_regular_night_wait",
)
DAEUN_EMPTY_STORE_EVENT = "arc_daeun_02b_dream"
DAEUN_EMPTY_STORE_AUDIO = {
    "ambience": "convenience",
    "suppress_human_ambience": True,
    "suppress_season_ambience": True,
    "suppress_music": True,
}
W108_HYUNSU_WARNING_EVENT = "arc_jaehyuk_hyunsu_warning"
W108_HYUNSU_WARNING_AUDIO = {
    "ambience": "apartment",
    "suppress_human_ambience": True,
    "suppress_season_ambience": True,
    "music": {"key": "reckoning", "start_paragraph": 3},
}
W112_FATHER_RETURN_CALL = "arc_y3_father_deferred_call"
M27_JAEHYUK_PITCH_EVENT = "arc_jaehyuk_03_pitch"
M27_JAEHYUK_PITCH_CG = "cg_jaehyuk_reveal"
M27_JAEHYUK_PITCH_AUDIO = {
    "ambience": "cafe",
    "music": {"key": "reckoning", "start_paragraph": 3},
}
M27_JAEHYUK_PITCH_RESULTS = ("current_housing", None, "current_housing")
W116_GHOST_SCORE_ENTRANCES = {
    "arc_jaehyuk_04a_ghost": 3,
    "arc_jaehyuk_ghost_read": 1,
    "arc_jaehyuk_ghost_message": 1,
    "arc_jaehyuk_ghost_decision": 0,
    "arc_jaehyuk_photo_in_dark": 0,
}
W117_COUNTER_EVENT = "arc_jaehyuk_04b_counter"
W117_POLICE_RECEPTION = "police_evidence_reception"
W117_COUNTER_AUDIO = {
    "ambience": "apartment",
    "suppress_human_ambience": True,
    "suppress_season_ambience": True,
    "music": {"key": "reckoning", "start_paragraph": 2},
}
DEMO_EVENT_IDS = set("""
story_flashforward story_arrival story_knee_door story_knee_witness
story_knee_choice story_last_payment_wait story_last_payment_word
story_last_payment_exit story_prologue_dad story_prologue_goal
story_prologue_meal v2_opening_application_send arc_intro_01_meal
v2_opening_return_math
arc_first_job_week_convenience arc_temptation_01 arc_intro_03_sns cafe_00
cafe_listen_01 cafe_peek_01 cafe_caught_honest story_first_paycheck_feel
arc_temptation_clean arc_intro_04_hyunsu arc_chapter1_close
arc_ch1_career_first_spec arc_sangchul_01_meet arc_sangchul_01_measure
arc_sangchul_01_answer arc_daeun_01_meet cafe_cb_honest_00
cafe_cb_honest_in arc_father_01_call arc_invest_first_loss
arc_father_quiet_call arc_jiyeon_01_crash hyunsu_study_together
arc_jaehyuk_01_reunion arc_job_vs_invest arc_hyunsu_night_talk
arc_father_02_signal arc_gangnam_visit_alone arc_four_months_in
story_first_savings_milestone hyunsu_exam_day
""".split())
DEMO_MOTIF_KEYS = {"family", "survival", "hyunsu", "ambition", "daeun", "jiyeon"}
DEMO_SCORE_ANCHORS = {
    "story_knee_door": "family",
    "story_last_payment_wait": "grief",
    "v2_opening_application_send": "survival",
    "arc_temptation_01": "crisis",
    "arc_intro_03_sns": "ambition",
    "arc_intro_04_hyunsu": "hyunsu",
    "arc_daeun_01_meet": "daeun",
    "arc_jiyeon_01_crash": "jiyeon",
    "arc_job_vs_invest": "reckoning",
    "arc_four_months_in": "wonder",
    "hyunsu_exam_day": "hyunsu",
}
MIN_DEMO_FOLEY_EVENTS = 24
PRIVATE_OFFICE_EVENT_IDS = {
    "arc_sangchul_01_meet",
    "arc_sangchul_01_measure",
    "arc_sangchul_01_coffee",
    "arc_sangchul_01_answer",
}
PRIVATE_OFFICE_FOLEY = {
    "arc_sangchul_01_meet": {"4": [{"sfx": "cup_set", "volume_db": -5.0}]},
    "arc_sangchul_01_measure": {},
    "arc_sangchul_01_coffee": {},
    "arc_sangchul_01_answer": {"3": [{"sfx": "traffic_pass", "volume_db": -7.0}]},
}
FIRST_BILL_CHAIN = (
    "v2_demo_first_bill_opening",
    "v2_demo_first_bill",
    "v2_demo_first_bill_ledger",
)
FRESH_OPENING_CHAIN = (
    "v2_opening_application_send",
    "arc_intro_01_meal",
    "v2_opening_return_math",
)


def load_json(path: Path):
    with path.open(encoding="utf-8") as handle:
        return json.load(handle)


def load_events() -> dict[str, dict]:
    events: dict[str, dict] = {}
    for raw_path in sorted(glob.glob(str(ROOT / "content" / "events" / "*.json"))):
        data = load_json(Path(raw_path))
        if not isinstance(data, list):
            continue
        for event in data:
            if isinstance(event, dict) and event.get("id"):
                events[str(event["id"])] = event
    return events


def gd_audio_keys(path: Path, constant: str) -> set[str]:
    source = path.read_text(encoding="utf-8")
    match = re.search(rf"const\s+{re.escape(constant)}\s*=\s*\{{(.*?)\n\}}", source, re.S)
    if not match:
        raise ValueError(f"cannot locate {constant} in {path.relative_to(ROOT)}")
    return set(re.findall(r'^\s*"([a-z0-9_]+)"\s*:', match.group(1), re.M))


def description_variants(event: dict) -> list[str]:
    variants = [str(event.get("description", ""))]
    for key, value in event.items():
        if not str(key).startswith("description_"):
            continue
        # Memory lines are appended to the resolved description; they are not
        # standalone prose variants and therefore do not own paragraph cues.
        if key == "description_memory_if_known":
            continue
        if isinstance(value, str):
            variants.append(value)
        elif isinstance(value, dict):
            variants.extend(str(item) for item in value.values() if isinstance(item, str))
    return [value for value in variants if value.strip()]


def paragraph_count(text: str) -> int:
    return sum(1 for paragraph in text.split("\n\n") if paragraph.strip())


def main() -> int:
    errors: list[str] = []
    manifest = load_json(MANIFEST_PATH)
    acting = load_json(ACTING_PATH)
    events = load_events()
    cg_contracts = manifest.get("cg", {})
    event_contracts = manifest.get("events", {})
    policy = manifest.get("policy", {})

    if policy.get("diegetic_spoken_language") != "ko":
        errors.append("diegetic spoken language must remain Korean")
    if policy.get("localize_diegetic_speech") is not False:
        errors.append("diegetic speech must not change nationality with text locale")

    active_cgs = set((acting.get("cg") or {}).keys())
    contract_cgs = set(cg_contracts.keys()) if isinstance(cg_contracts, dict) else set()
    for cg_id in sorted(active_cgs - contract_cgs):
        errors.append(f"active CG lacks ambience contract: {cg_id}")
    for cg_id in sorted(contract_cgs - active_cgs):
        errors.append(f"stale CG audio contract: {cg_id}")
    if cg_contracts.get("cg_ending_with_daeun") != {
        "ambience": "apartment", "suppress_human_ambience": True, "suppress_season_ambience": True,
    }:
        errors.append("with_daeun: the present-day meal must not play the remembered goshiwon refrigerator")

    try:
        ambience_keys = gd_audio_keys(ROOT / "autoloads" / "BGMPlayer.gd", "AMBIENCE_TRACKS")
        music_keys = gd_audio_keys(ROOT / "autoloads" / "BGMPlayer.gd", "TRACKS")
        sfx_keys = gd_audio_keys(ROOT / "autoloads" / "AudioManager.gd", "_SFX_FILES")
    except ValueError as exc:
        errors.append(str(exc))
        ambience_keys, music_keys, sfx_keys = set(), set(), set()

    peak_event_ids: set[str] = set()
    peak_events = peaks.load_events(str(ROOT / "content" / "events"))
    for _, root_id in peaks.PEAK_ROOTS:
        for path in peaks.walk_paths(peak_events, root_id):
            peak_event_ids.update(path.event_ids)
    contract_event_ids = set(event_contracts.keys()) if isinstance(event_contracts, dict) else set()
    for event_id in sorted(peak_event_ids - contract_event_ids):
        errors.append(f"Tier-1 peak event lacks audio contract: {event_id}")
    for event_id in sorted(contract_event_ids - events.keys()):
        errors.append(f"scene audio contract references missing event: {event_id}")

    for owner, contract in list(cg_contracts.items()) + list(event_contracts.items()):
        if not isinstance(contract, dict):
            errors.append(f"{owner}: audio contract must be an object")
            continue
        ambience = str(contract.get("ambience", ""))
        if owner == M14_BANK_EVENT:
            if (ambience != "intentional_silence" or contract.get("suppress_music") is not True
                    or contract.get("paragraph_cues")
                    or contract.get("result_paragraph_cues") != M14_BANK_RESULT_CUES):
                errors.append(f"{owner}: keep the bank beds quiet and use only the four result cues")
        elif owner == W224_CUSTODY_EVENT:
            if contract != W224_CUSTODY_AUDIO:
                errors.append(f"{owner}: the rear table must stay free of checkout ambience and retain its paper and score")
        elif owner == W227_INTAKE_EVENT:
            if contract != W227_INTAKE_AUDIO:
                errors.append(f"{owner}: no borrowed office ambience, only the authored score and exact result cues")
        elif owner == W230_VERDICT_EVENT:
            if contract != W230_VERDICT_AUDIO:
                errors.append(f"{owner}: keep the cafe bed silent, with only the authored score, paper and writing")
        elif owner == W234_SUMMIT_EVENT:
            if contract != W234_SUMMIT_AUDIO:
                errors.append(f"{owner}: keep the solo office free of chatter and machinery, with the authored score and paper")
        elif owner == W240_OUTDOOR_SIGNATURE_EVENT:
            if contract != W240_OUTDOOR_SIGNATURE_AUDIO:
                errors.append(f"{owner}: keep the outdoor signature free of borrowed beds and use only authored score, paper and writing")
        elif owner == SINCHON_REUNION_EVENT:
            if contract != SINCHON_REUNION_AUDIO:
                errors.append(f"{owner}: after rain, only the P1 car cue and P2 score are authored")
        elif owner == SINCHON_OFFER_EVENT:
            if contract != SINCHON_OFFER_AUDIO or ambience not in ambience_keys:
                errors.append(f"{owner}: keep only exterior rain and the P1 car cue")
        elif owner == M23_PARENTS_EVENT:
            if contract != M23_PARENTS_AUDIO:
                errors.append(f"{owner}: station and dinner must not borrow pub ambience, music or foley")
        elif owner == W57_MEDICATION_EVENT:
            if contract != W57_MEDICATION_AUDIO:
                errors.append(f"{owner}: only the received handset vibration is an event-level cue")
        elif owner in {W72_DINNER_EVENT, W82_BUS_EVENT, W205_MINSEO_PHONE}:
            if contract != W72_DINNER_AUDIO:
                errors.append(f"{owner}: do not borrow the wrong location's recorded bed")
        elif owner in W132_CAFE_EVENTS:
            if contract != W132_CAFE_AUDIO:
                errors.append(f"{owner}: keep the score, not the unrelated street or bar recording")
        elif owner in DAEUN_QUIET_RESULT_CGS:
            if contract != {"ambience": "intentional_silence"}:
                errors.append(f"{owner}: do not borrow the recorded bar or street crowd")
        elif not ambience or ambience not in ambience_keys | DYNAMIC_AMBIENCE_KEYS:
            errors.append(f"{owner}: unknown or empty ambience key {ambience!r}")
        music = contract.get("music")
        if bool(contract.get("suppress_music", False)) and music is not None:
            errors.append(f"{owner}: suppress_music and music cannot coexist")
        suppress_human = contract.get("suppress_human_ambience", False)
        if not isinstance(suppress_human, bool):
            errors.append(f"{owner}: suppress_human_ambience must be a boolean")
        suppress_season = contract.get("suppress_season_ambience", False)
        if not isinstance(suppress_season, bool):
            errors.append(f"{owner}: suppress_season_ambience must be a boolean")
        if "ambience_from_result_cg" in contract:
            cg_id = contract["ambience_from_result_cg"]
            owner_event = events.get(owner, {}) if owner in event_contracts else {}
            choices = [row for row in owner_event.get("choices", []) if isinstance(row, dict)]
            result_cgs = {str(row.get("result_cg", "")) for row in [owner_event, *choices]}
            opening_cgs = {str(owner_event.get("cg", ""))}
            opening_cg_variants = owner_event.get("cg_if_known", {})
            if isinstance(opening_cg_variants, dict):
                opening_cgs.update(str(value) for value in opening_cg_variants.values())
            if (not isinstance(cg_id, str) or not cg_id or cg_id not in result_cgs
                    or cg_id in opening_cgs or cg_id not in contract_cgs):
                errors.append(f"{owner}: ambience_from_result_cg must name a contracted result-only CG")
            elif isinstance(cg_contracts[cg_id], dict) and cg_contracts[cg_id].get("ambience") == ambience:
                errors.append(f"{owner}: ambience_from_result_cg must change the physical ambience")
        if music is not None:
            if not isinstance(music, dict):
                errors.append(f"{owner}: music must be an object")
            else:
                key = str(music.get("key", ""))
                start = music.get("start_paragraph", 0)
                if key not in music_keys:
                    errors.append(f"{owner}: unknown music key {key!r}")
                if not isinstance(start, int) or isinstance(start, bool) or start < 0:
                    errors.append(f"{owner}: invalid music start_paragraph {start!r}")

    if M14_BANK_EVENT not in event_contracts:
        errors.append(f"{M14_BANK_EVENT}: missing bank audio contract")
    if (event_contracts.get(HYUNSU_EXAM_FAILURE_EVENT) != HYUNSU_EXAM_FAILURE_AUDIO
            or events.get(HYUNSU_EXAM_FAILURE_EVENT, {}).get("background") != "goshiwon_hallway"
            or any(manifest.get("background_profiles", {}).get(key) != "apartment"
                   for key in ("hyunsu_exam_room", "goshiwon_shared_washbasin"))):
        errors.append(f"{HYUNSU_EXAM_FAILURE_EVENT}: keep the hall, room and washbasin free of borrowed machinery and cues")
    if (event_contracts.get(GOSHIWON_MOVEOUT_EVENT) != GOSHIWON_MOVEOUT_AUDIO
            or events.get(GOSHIWON_MOVEOUT_EVENT, {}).get("background") != "goshiwon_hallway"
            or manifest.get("background_profiles", {}).get("goshiwon_moveout_wet_street")
            != "intentional_silence"):
        errors.append(f"{GOSHIWON_MOVEOUT_EVENT}: hallway bed and one exterior cue on choice 0 paragraph 2")
    if (event_contracts.get(HYUNSU_DRIFT_EVENT) != HYUNSU_DRIFT_AUDIO
            or events.get(HYUNSU_DRIFT_EVENT, {}).get("background") != "current_housing"):
        errors.append(f"{HYUNSU_DRIFT_EVENT}: remote messages keep actual home art and a neutral bed without a phone cue")
    hyunsu_call = events.get(HYUNSU_CALL_EVENT, {})
    hyunsu_call_choices = hyunsu_call.get("choices", [])
    if (event_contracts.get(HYUNSU_CALL_EVENT) != HYUNSU_CALL_AUDIO
            or hyunsu_call.get("background") != "current_housing"
            or not isinstance(hyunsu_call_choices, list) or len(hyunsu_call_choices) != 3
            or any(not isinstance(row, dict) or any(key in row
                   for key in ("result_ambience", "result_background", "result_cg"))
                   for row in [hyunsu_call, *hyunsu_call_choices])):
        errors.append(f"{HYUNSU_CALL_EVENT}: quiet home with telephone keyboard only at intro 2 and choice 1 result 1")
    telephone_owners = sorted(
        event_id for event_id, contract in event_contracts.items()
        if '"keyboard_phone"' in json.dumps(contract)
    )
    if telephone_owners != [HYUNSU_CALL_EVENT] or any(
            '"keyboard_phone"' in json.dumps(manifest.get(field, {}))
            for field in ("background_profiles", "cg", "event_intents")):
        errors.append(f"{HYUNSU_CALL_EVENT}: dedicated telephone sound must have exactly one scene owner")
    if W224_CUSTODY_EVENT not in event_contracts:
        errors.append(f"{W224_CUSTODY_EVENT}: missing rear-table audio contract")
    if W230_VERDICT_EVENT not in event_contracts:
        errors.append(f"{W230_VERDICT_EVENT}: missing cafe verdict audio contract")
    if W234_SUMMIT_EVENT not in event_contracts:
        errors.append(f"{W234_SUMMIT_EVENT}: missing quiet solo office audio contract")
    if (event_contracts.get(W235_NOTICE_EVENT) != W235_NOTICE_AUDIO
            or events.get(W235_NOTICE_EVENT, {}).get("background") != "current_housing"
            or manifest.get("background_profiles", {}).get("finale_notice_desk") != "current_housing"):
        errors.append(f"{W235_NOTICE_EVENT}: preserve the live room and only sound the papers being put away")
    final_record = events.get(W237_FINAL_RECORD_EVENT, {})
    final_record_choices = final_record.get("choices", [])
    if (event_contracts.get(W237_FINAL_RECORD_EVENT) != W237_FINAL_RECORD_AUDIO
            or final_record.get("background") != "current_housing"
            or not isinstance(final_record_choices, list) or len(final_record_choices) != 2):
        errors.append(f"{W237_FINAL_RECORD_EVENT}: play two vibrations, then only the quiet result's page turn")
    if W240_OUTDOOR_SIGNATURE_EVENT not in event_contracts:
        errors.append(f"{W240_OUTDOOR_SIGNATURE_EVENT}: missing outdoor signature audio contract")
    if (event_contracts.get(M23_MOTHER_CALL_EVENT) != NEUTRAL_HOME_AUDIO
            or "apartment" not in ambience_keys):
        errors.append(f"{M23_MOTHER_CALL_EVENT}: retain only neutral room tone without added cues or score")
    mother_call = events.get(M23_MOTHER_CALL_EVENT, {})
    mother_choices = mother_call.get("choices", [])
    first_ktx = mother_choices[0] if isinstance(mother_choices, list) and mother_choices else {}
    first_ktx_profiles = manifest.get("background_profiles", {})
    if (not isinstance(first_ktx, dict) or first_ktx.get("result_background") != M23_FIRST_KTX_CABIN
            or "result_ambience" in first_ktx or "result_ambience" in mother_call
            or any(first_ktx_profiles.get(background) != "intentional_silence"
                   for background in (M23_FIRST_KTX_PLATFORM, M23_FIRST_KTX_CABIN))):
        errors.append(f"{M23_MOTHER_CALL_EVENT}: first KTX platform and cabin must not borrow a train or room bed")
    hospital_visit = events.get(W96_HOSPITAL_VISIT_EVENT, {})
    hospital_choices = hospital_visit.get("choices", [])
    hospital_visit_profiles = manifest.get("background_profiles", {})
    if (event_contracts.get(W96_HOSPITAL_VISIT_EVENT) != W96_HOSPITAL_VISIT_AUDIO
            or hospital_visit.get("background") != "hospital"
            or hospital_visit_profiles.get("hospital") != "hospital"
            or hospital_visit_profiles.get(W96_SEOUL_ARRIVAL) != "intentional_silence"):
        errors.append(f"{W96_HOSPITAL_VISIT_EVENT}: keep hospital ambience and grief score, with a quiet Seoul arrival")
    if ("result_background" in hospital_visit or "result_ambience" in hospital_visit
            or not isinstance(hospital_choices, list) or len(hospital_choices) != 4
            or any(not isinstance(choice, dict) or "result_ambience" in choice
                   or ("result_background" in choice if index < 3
                       else choice.get("result_background") != W96_SEOUL_ARRIVAL)
                   for index, choice in enumerate(hospital_choices))):
        errors.append(f"{W96_HOSPITAL_VISIT_EVENT}: only the deferred visit may end at Seoul Station without a new bed")
    if event_contracts.get(W45_DECEMBER_EVENT) != W45_DECEMBER_AUDIO:
        errors.append(f"{W45_DECEMBER_EVENT}: keep the current-room scene unscored and free of borrowed machinery, people, and cues")
    w53_event = events.get(W53_NETWORK_EVENT, {})
    w53_choices = w53_event.get("choices", [])
    if (event_contracts.get(W53_NETWORK_EVENT) != NEUTRAL_HOME_AUDIO
            or w53_event.get("background") != W53_DINING
            or manifest.get("background_profiles", {}).get(W53_DINING) != "apartment"
            or "result_ambience" in w53_event
            or not isinstance(w53_choices, list) or len(w53_choices) != 2
            or any(not isinstance(choice, dict) or "result_ambience" in choice for choice in w53_choices)):
        errors.append(f"{W53_NETWORK_EVENT}: don't substitute generic bar or pub recordings for the private gathering")
    if (W57_MEDICATION_EVENT not in event_contracts
            or manifest.get("background_profiles", {}).get("seoul_subway_commuters_w57") != "seoul_subway_onboard"
            or "seoul_subway_onboard" not in ambience_keys):
        errors.append(f"{W57_MEDICATION_EVENT}: missing incoming message or separately bound onboard audio")
    if (event_contracts.get(W72_DINNER_EVENT) != W72_DINNER_AUDIO
            or events.get(W72_DINNER_EVENT, {}).get("background") != "restaurant"
            or manifest.get("background_profiles", {}).get("restaurant") != "hoesik"):
        errors.append(f"{W72_DINNER_EVENT}: preserve the restaurant and isolate the dinner audio change")
    if (event_contracts.get(W82_BUS_EVENT) != W72_DINNER_AUDIO
            or manifest.get("background_profiles", {}).get("seoul_bus_terminal_departure") != "intentional_silence"
            or events.get(W82_BUS_EVENT, {}).get("background") != "current_housing"):
        errors.append(f"{W82_BUS_EVENT}: isolate bus sendoff from unrelated highway and human ambience")
    if (event_contracts.get(W205_MINSEO_PHONE) != W72_DINNER_AUDIO
            or events.get(W205_MINSEO_PHONE, {}).get("background") != ""):
        errors.append(f"{W205_MINSEO_PHONE}: don't stage the remote call in an unestablished café")
    if (event_contracts.get(W161_BODY_EVENT) != W161_MOVING_AUDIO
            or events.get(W161_BODY_EVENT, {}).get("background") != "seoul_subway_commuters_w57"
            or manifest.get("background_profiles", {}).get("seoul_subway_stopped_w161") != "intentional_silence"):
        errors.append(f"{W161_BODY_EVENT}: recorded onboard motion only between stops, never at the open door")
    if (any(event_contracts.get(owner) != W132_CAFE_AUDIO
            or events.get(owner, {}).get("background") != "cafe" for owner in W132_CAFE_EVENTS)
            or manifest.get("background_profiles", {}).get("sangchul_cafe_stairs") != "intentional_silence"):
        errors.append("W132: exact café owners, unchanged score and a quiet stairwell")
    for event_id, expected_audio in ((W37_FIRST_BILL_EVENT, NEUTRAL_HOME_AUDIO),
                                     (W100_FATHER_OUTREACH_EVENT, NEUTRAL_HOME_AUDIO),
                                     (W108_HYUNSU_WARNING_EVENT, W108_HYUNSU_WARNING_AUDIO),
                                     (W112_FATHER_RETURN_CALL, NEUTRAL_HOME_AUDIO)):
        home_event = events.get(event_id, {})
        home_choices = home_event.get("choices", [])
        if (event_contracts.get(event_id) != expected_audio
                or home_event.get("background") != "current_housing"
                or "result_background" in home_event or "result_ambience" in home_event
                or not isinstance(home_choices, list) or len(home_choices) != 3
                or any(not isinstance(choice, dict) or "result_background" in choice
                       or "result_ambience" in choice for choice in home_choices)):
            errors.append(f"{event_id}: preserve neutral home tone, exact score, and no extra scene cues")
    for event_id, entrance in W116_GHOST_SCORE_ENTRANCES.items():
        event = events.get(event_id, {})
        expected_audio = {"ambience": "apartment", "suppress_human_ambience": True,
                          "suppress_season_ambience": True,
                          "music": {"key": "reckoning", "start_paragraph": entrance}}
        if (event_contracts.get(event_id) != expected_audio
                or event.get("background") != "current_housing" or event.get("cg")
                or "result_background" in event or "result_ambience" in event
                or any(not isinstance(choice, dict) or any(key in choice for key in
                       ("result_background", "result_ambience", "result_cg"))
                       for choice in event.get("choices", []))):
            errors.append(f"{event_id}: keep the same home bed and exact score through the ghost chain")
    ghost_direction = events.get("arc_jaehyuk_ghost_decision", {}).get("direction", {})
    if ghost_direction.get("amb") != "duck" or ghost_direction.get("sting") != "loss":
        errors.append("arc_jaehyuk_ghost_decision: preserve the authored loss sound and ambience duck")
    intake = events.get(W227_INTAKE_EVENT, {})
    intake_choices = intake.get("choices", [])
    if (event_contracts.get(W227_INTAKE_EVENT) != W227_INTAKE_AUDIO
            or intake.get("background") != W227_INTAKE_BACKGROUND
            or manifest.get("background_profiles", {}).get(W227_INTAKE_BACKGROUND) != "intentional_silence"
            or "result_background" in intake or "result_ambience" in intake
            or not isinstance(intake_choices, list) or len(intake_choices) != 4
            or any(not isinstance(choice, dict) or any(key in choice for key in
                   ("result_background", "result_ambience", "result_cg")) for choice in intake_choices)):
        errors.append(f"{W227_INTAKE_EVENT}: preserve the quiet common counter through all four results")
    counter = events.get(W117_COUNTER_EVENT, {})
    counter_choices = counter.get("choices", [])
    if (event_contracts.get(W117_COUNTER_EVENT) != W117_COUNTER_AUDIO
            or manifest.get("background_profiles", {}).get(W117_POLICE_RECEPTION) != "intentional_silence"
            or counter.get("background") != "meeting" or counter.get("cg")
            or any(key in counter.get("direction", {}) for key in ("amb", "sting"))):
        errors.append(f"{W117_COUNTER_EVENT}: keep the quiet reception, neutral meeting, and prose P2 score only")
    if (any(key in counter for key in ("result_background", "result_ambience", "result_cg"))
            or not isinstance(counter_choices, list) or len(counter_choices) != 3
            or any(not isinstance(choice, dict) or any(key in choice for key in
                   ("result_background", "result_ambience", "result_cg")) for choice in counter_choices)):
        errors.append(f"{W117_COUNTER_EVENT}: result audio and location must follow the staged beats, not generic overrides")
    pitch = events.get(M27_JAEHYUK_PITCH_EVENT, {})
    if (event_contracts.get(M27_JAEHYUK_PITCH_EVENT) != M27_JAEHYUK_PITCH_AUDIO
            or cg_contracts.get(M27_JAEHYUK_PITCH_CG) != {"ambience": "cafe"}
            or pitch.get("background") != "meeting" or pitch.get("cg") != M27_JAEHYUK_PITCH_CG):
        errors.append(f"{M27_JAEHYUK_PITCH_EVENT}: preserve the hotel ambience and prose P3 score")
    pitch_choices = pitch.get("choices", [])
    if ("result_background" in pitch or "result_ambience" in pitch
            or not isinstance(pitch_choices, list) or len(pitch_choices) != len(M27_JAEHYUK_PITCH_RESULTS)
            or any(not isinstance(choice, dict) or "result_ambience" in choice
                   or ("result_background" in choice if background is None
                       else choice.get("result_background") != background)
                   for choice, background in zip(pitch_choices, M27_JAEHYUK_PITCH_RESULTS))):
        errors.append(f"{M27_JAEHYUK_PITCH_EVENT}: only full payment and refusal may end at home without overriding the cut mix")
    if events.get(M14_BANK_EVENT, {}).get("background") != M14_BANK_BACKGROUNDS[0] or any(
        manifest.get("background_profiles", {}).get(background) != "intentional_silence"
        for background in M14_BANK_BACKGROUNDS
    ):
        errors.append(f"{M14_BANK_EVENT}: both exact bank backgrounds must retain their quiet profile")

    stop, sedan, _headlights = SINCHON_REUNION_BACKGROUNDS
    reunion = events.get(SINCHON_REUNION_EVENT, {})
    if (SINCHON_REUNION_EVENT not in event_contracts or reunion.get("background") != stop
            or reunion.get("paragraph_backgrounds") != [stop, sedan, sedan, sedan, sedan]
            or any(manifest.get("background_profiles", {}).get(background) != "intentional_silence"
                   for background in SINCHON_REUNION_BACKGROUNDS)):
        errors.append(f"{SINCHON_REUNION_EVENT}: the exact post-rain stop surfaces must remain quiet")

    offer = events.get(SINCHON_OFFER_EVENT, {})
    offer_profiles = manifest.get("background_profiles", {})
    if (SINCHON_OFFER_EVENT not in event_contracts
            or offer.get("background") != SINCHON_OFFER_STOP
            or offer.get("paragraph_backgrounds") != [SINCHON_OFFER_STOP, *[SINCHON_OFFER_SEDAN] * 4]
            or offer_profiles.get(SINCHON_OFFER_STOP) != "rain"
            or any(offer_profiles.get(background) != (ambience or "rain")
                   for background, ambience in SINCHON_OFFER_RESULTS)):
        errors.append(f"{SINCHON_OFFER_EVENT}: verify exact recurring rain and quiet cafe profiles")
    offer_choices = offer.get("choices", [])
    if not isinstance(offer_choices, list) or len(offer_choices) != len(SINCHON_OFFER_RESULTS):
        errors.append(f"{SINCHON_OFFER_EVENT}: missing exact exterior/cafe result choices")
    else:
        for index, (choice, (background, ambience)) in enumerate(zip(offer_choices, SINCHON_OFFER_RESULTS)):
            # A direct rain override would let the generic street voices back in.
            if (not isinstance(choice, dict) or choice.get("result_background") != background
                    or ("result_ambience" in choice if ambience is None
                        else choice.get("result_ambience") != ambience)):
                errors.append(f"{SINCHON_OFFER_EVENT}: result {index} has the wrong location or ambience path")

    parents = events.get(M23_PARENTS_EVENT, {})
    profiles = manifest.get("background_profiles", {})
    daeun = events.get(DAEUN_CONVENIENCE_EVENT, {})
    daeun_choices = daeun.get("choices", [])
    if (DAEUN_CONVENIENCE_EVENT in event_contracts
            or daeun.get("background") != DAEUN_CONVENIENCE_INSIDE
            or daeun.get("paragraph_backgrounds") != [DAEUN_CONVENIENCE_INSIDE] * 2 + [DAEUN_CONVENIENCE_OUTSIDE]
            or profiles.get(DAEUN_CONVENIENCE_INSIDE) != "convenience"
            or profiles.get(DAEUN_CONVENIENCE_OUTSIDE) != "intentional_silence"
            or any(cg_contracts.get(key) != {"ambience": "intentional_silence"} for key in DAEUN_QUIET_RESULT_CGS)
            or not isinstance(daeun_choices, list) or len(daeun_choices) != 3
            or any(not isinstance(choice, dict) or choice.get("result_cg") != key
                   or choice.get("result_cg_reveal_paragraph") != cut
                   for choice, key, cut in zip(daeun_choices, DAEUN_QUIET_RESULT_CGS, (1, 1, 2)))
            or daeun_choices[2].get("follow_up_event") != DAEUN_EMPTY_STORE_EVENT
            or profiles.get("convenience_night_dry") != "convenience"
            or events.get(DAEUN_EMPTY_STORE_EVENT, {}).get("background") != "convenience_night_dry"
            or event_contracts.get(DAEUN_EMPTY_STORE_EVENT) != DAEUN_EMPTY_STORE_AUDIO):
        errors.append("Daeun afternoon/night: keep the fridge inside, no borrowed crowd after the cut, and fridge only at night")
    if (M23_PARENTS_EVENT not in event_contracts
            or parents.get("background") != M23_PARENTS_CONCOURSE
            or any(profiles.get(background) != "intentional_silence"
                   for background in M23_PARENTS_QUIET_BACKGROUNDS)):
        errors.append(f"{M23_PARENTS_EVENT}: exact station and transit profiles must stay quiet")
    parents_choices = parents.get("choices", [])
    # Choice metadata identifies the terminal location; StoryMode owns the
    # first (table) page and the precise point at which its audio changes.
    if ("result_ambience" in parents or not isinstance(parents_choices, list)
            or len(parents_choices) != len(M23_PARENTS_END_BACKGROUNDS)
            or any(not isinstance(choice, dict) or choice.get("result_background") != background
                   or "result_ambience" in choice
                   for choice, background in zip(parents_choices, M23_PARENTS_END_BACKGROUNDS))):
        errors.append(f"{M23_PARENTS_EVENT}: station/home result locations must not override authored audio cuts")

    for event_id in sorted(PRIVATE_OFFICE_EVENT_IDS):
        contract = event_contracts.get(event_id, {})
        if not isinstance(contract, dict):
            errors.append(f"{event_id}: private-office audio contract is missing")
            continue
        if contract.get("ambience") != "office":
            errors.append(f"{event_id}: private office must retain office room tone")
        if contract.get("suppress_human_ambience") is not True:
            errors.append(f"{event_id}: private office must suppress anonymous human ambience")
        if (contract.get("paragraph_cues", {}) != PRIVATE_OFFICE_FOLEY[event_id]
                or contract.get("result_paragraph_cues", {})):
            errors.append(f"{event_id}: private office cues must match the exact authored action")

    for event_id, contract in event_contracts.items():
        event = events.get(event_id)
        if not isinstance(event, dict) or not isinstance(contract, dict):
            continue
        variants = description_variants(event)
        music = contract.get("music")
        if isinstance(music, dict):
            start = int(music.get("start_paragraph", 0))
            if any(paragraph_count(text) <= start for text in variants):
                errors.append(f"{event_id}: music paragraph {start} is absent from a prose variant")
        paragraph_cues = contract.get("paragraph_cues", {})
        if not isinstance(paragraph_cues, dict):
            errors.append(f"{event_id}: paragraph_cues must be an object")
            continue
        for raw_index, cues in paragraph_cues.items():
            try:
                cue_index = int(raw_index)
            except (TypeError, ValueError):
                errors.append(f"{event_id}: invalid cue paragraph {raw_index!r}")
                continue
            if cue_index < 0 or any(paragraph_count(text) <= cue_index for text in variants):
                errors.append(f"{event_id}: cue paragraph {cue_index} is absent from a prose variant")
            if not isinstance(cues, list) or not cues:
                errors.append(f"{event_id}: paragraph {cue_index} needs a nonempty cue list")
                continue
            for cue in cues:
                if not isinstance(cue, dict):
                    errors.append(f"{event_id}: paragraph {cue_index} cue must be an object")
                    continue
                sfx = str(cue.get("sfx", ""))
                if sfx not in sfx_keys:
                    errors.append(f"{event_id}: paragraph {cue_index} uses unknown SFX {sfx!r}")
                delay = cue.get("delay", 0.0)
                volume = cue.get("volume_db", 0.0)
                if not isinstance(delay, (int, float)) or isinstance(delay, bool) or delay < 0.0:
                    errors.append(f"{event_id}: invalid cue delay {delay!r}")
                if not isinstance(volume, (int, float)) or isinstance(volume, bool) or not -30.0 <= volume <= 6.0:
                    errors.append(f"{event_id}: invalid cue volume {volume!r}")

        result_paragraph_cues = contract.get("result_paragraph_cues", {})
        if not isinstance(result_paragraph_cues, dict):
            errors.append(f"{event_id}: result_paragraph_cues must be an object")
            continue
        choices = event.get("choices", [])
        if not isinstance(choices, list):
            choices = []
        for raw_choice_index, paragraph_map in result_paragraph_cues.items():
            try:
                choice_index = int(raw_choice_index)
            except (TypeError, ValueError):
                errors.append(
                    f"{event_id}: invalid result cue choice {raw_choice_index!r}"
                )
                continue
            if choice_index < 0 or choice_index >= len(choices):
                errors.append(
                    f"{event_id}: result cue choice {choice_index} is absent"
                )
                continue
            if not isinstance(paragraph_map, dict):
                errors.append(
                    f"{event_id}: result cue choice {choice_index} must be an object"
                )
                continue
            result_text = str(choices[choice_index].get("result_text", ""))
            result_count = paragraph_count(result_text)
            for raw_index, cues in paragraph_map.items():
                try:
                    cue_index = int(raw_index)
                except (TypeError, ValueError):
                    errors.append(
                        f"{event_id}: invalid result cue paragraph {raw_index!r}"
                    )
                    continue
                if cue_index < 0 or cue_index >= result_count:
                    errors.append(
                        f"{event_id}: result cue paragraph {cue_index} is absent "
                        f"from choice {choice_index}"
                    )
                if not isinstance(cues, list) or not cues:
                    errors.append(
                        f"{event_id}: result choice {choice_index} paragraph "
                        f"{cue_index} needs a nonempty cue list"
                    )
                    continue
                for cue in cues:
                    if not isinstance(cue, dict):
                        errors.append(
                            f"{event_id}: result choice {choice_index} paragraph "
                            f"{cue_index} cue must be an object"
                        )
                        continue
                    sfx = str(cue.get("sfx", ""))
                    if sfx not in sfx_keys:
                        errors.append(
                            f"{event_id}: result choice {choice_index} paragraph "
                            f"{cue_index} uses unknown SFX {sfx!r}"
                        )
                    delay = cue.get("delay", 0.0)
                    volume = cue.get("volume_db", 0.0)
                    if (
                        not isinstance(delay, (int, float))
                        or isinstance(delay, bool)
                        or delay < 0.0
                    ):
                        errors.append(
                            f"{event_id}: invalid result cue delay {delay!r}"
                        )
                    if (
                        not isinstance(volume, (int, float))
                        or isinstance(volume, bool)
                        or not -30.0 <= volume <= 6.0
                    ):
                        errors.append(
                            f"{event_id}: invalid result cue volume {volume!r}"
                        )

    demo_contracts = {
        event_id: event_contracts.get(event_id, {})
        for event_id in DEMO_EVENT_IDS
        if isinstance(event_contracts.get(event_id), dict)
    }
    missing_demo_contracts = sorted(DEMO_EVENT_IDS - demo_contracts.keys())
    if missing_demo_contracts:
        errors.append("demo events lack audio contract: " + ", ".join(missing_demo_contracts))
    demo_music_keys = {
        str(contract.get("music", {}).get("key", ""))
        for contract in demo_contracts.values()
        if isinstance(contract.get("music"), dict)
    }
    missing_motifs = sorted(DEMO_MOTIF_KEYS - demo_music_keys)
    if missing_motifs:
        errors.append("demo lacks authored motif keys: " + ", ".join(missing_motifs))
    for event_id, expected_key in DEMO_SCORE_ANCHORS.items():
        contract = demo_contracts.get(event_id, {})
        actual_key = str(contract.get("music", {}).get("key", ""))
        if actual_key != expected_key:
            errors.append(
                f"{event_id}: expected demo score {expected_key!r}, got {actual_key!r}"
            )

    # Fresh V2 swaps out the legacy app-open card, then carries one survival
    # score through the actual Send, same-day interview, and room calculation.
    opening_ambiences = ("room", "office", "room")
    for event_id, expected_ambience in zip(
        FRESH_OPENING_CHAIN, opening_ambiences
    ):
        contract = demo_contracts.get(event_id, {})
        if not isinstance(contract, dict):
            errors.append(f"{event_id}: fresh-opening audio contract is missing")
            continue
        if contract.get("ambience") != expected_ambience:
            errors.append(
                f"{event_id}: fresh opening must use {expected_ambience} ambience"
            )
        music = contract.get("music", {})
        if not isinstance(music, dict) or music.get("key") != "survival":
            errors.append(f"{event_id}: fresh opening must preserve survival score")
        elif music.get("start_paragraph") != 1:
            errors.append(
                f"{event_id}: fresh-opening survival score must enter at paragraph 1"
            )
    foley_events = sum(
        bool(contract.get("paragraph_cues"))
        or bool(contract.get("result_paragraph_cues"))
        for contract in demo_contracts.values()
    )
    if foley_events < MIN_DEMO_FOLEY_EVENTS:
        errors.append(
            f"demo physical-sound events {foley_events} < {MIN_DEMO_FOLEY_EVENTS}"
        )
    for event_id in ("story_knee_door", "story_knee_witness", "story_knee_choice"):
        contract = demo_contracts.get(event_id, {})
        if contract.get("ambience") != "family_home":
            errors.append(f"{event_id}: prologue memory must use family_home ambience")
        if str(contract.get("music", {}).get("key", "")) != "family":
            errors.append(f"{event_id}: prologue memory must preserve family motif")

    queue_contract = demo_contracts.get("story_last_payment_wait", {})
    if queue_contract.get("ambience") != "public_office":
        errors.append("story_last_payment_wait: queue scene must use public_office ambience")
    description_queue_cues = [
        cue
        for cues in queue_contract.get("paragraph_cues", {}).values()
        if isinstance(cues, list)
        for cue in cues
        if isinstance(cue, dict) and cue.get("sfx") == "queue_chime"
    ]
    if description_queue_cues:
        errors.append(
            "story_last_payment_wait: queue chime must not play before the number call"
        )
    result_queue_cues = (
        queue_contract.get("result_paragraph_cues", {})
        .get("0", {})
        .get("0", [])
    )
    queue_chime_count = sum(
        isinstance(cue, dict) and cue.get("sfx") == "queue_chime"
        for cue in result_queue_cues
    )
    if queue_chime_count != 1:
        errors.append(
            "story_last_payment_wait: choice 0 result paragraph 0 must own "
            "exactly one queue_chime"
        )

    # The First Bill is one continuous scene even though authored as three linked
    # events.  The score key therefore stays identical across every link;
    # BGMPlayer's same-key keep path preserves playback instead of rewinding.
    first_bill_contracts = {
        event_id: event_contracts.get(event_id, {})
        for event_id in FIRST_BILL_CHAIN
    }
    for event_id, expected_start in zip(FIRST_BILL_CHAIN, (1, 0, 0)):
        contract = first_bill_contracts[event_id]
        if not isinstance(contract, dict):
            errors.append(f"{event_id}: first-bill audio contract is missing")
            continue
        if contract.get("ambience") != "current_housing":
            errors.append(f"{event_id}: first-bill chain must use current_housing")
        music = contract.get("music", {})
        if not isinstance(music, dict) or music.get("key") != "reckoning":
            errors.append(f"{event_id}: first-bill chain must preserve reckoning")
        elif music.get("start_paragraph") != expected_start:
            errors.append(
                f"{event_id}: first-bill reckoning must start at paragraph "
                f"{expected_start}"
            )

    first_bill_cues: list[tuple[str, str, str, str]] = []
    for event_id, contract in first_bill_contracts.items():
        if not isinstance(contract, dict):
            continue
        description_maps = contract.get("paragraph_cues", {})
        if not isinstance(description_maps, dict):
            description_maps = {}
        for paragraph_index, cues in description_maps.items():
            if not isinstance(cues, list):
                continue
            for cue in cues:
                if isinstance(cue, dict):
                    first_bill_cues.append(
                        (
                            event_id,
                            "description",
                            str(paragraph_index),
                            str(cue.get("sfx", "")),
                        )
                    )
        result_maps = contract.get("result_paragraph_cues", {})
        if not isinstance(result_maps, dict):
            result_maps = {}
        for choice_index, paragraph_map in result_maps.items():
            if not isinstance(paragraph_map, dict):
                continue
            for paragraph_index, cues in paragraph_map.items():
                if not isinstance(cues, list):
                    continue
                for cue in cues:
                    if isinstance(cue, dict):
                        first_bill_cues.append(
                            (
                                event_id,
                                f"result:{choice_index}",
                                str(paragraph_index),
                                str(cue.get("sfx", "")),
                            )
                        )

    expected_first_bill_cues = [
        ("v2_demo_first_bill_opening", "description", "0", "paper_handle"),
        ("v2_demo_first_bill_ledger", "result:0", "0", "pen_write"),
    ]
    if sorted(first_bill_cues) != sorted(expected_first_bill_cues):
        errors.append(
            "first-bill physical cues must be exactly opening description 0 "
            "paper_handle and ledger choice 0 result 0 pen_write; got "
            + repr(first_bill_cues)
        )

    if errors:
        for error in errors:
            print("SCENE_AUDIO_CONTRACT_FAIL", error)
        return 1
    print(
        "SCENE_AUDIO_CONTRACT_OK "
        f"cg={len(active_cgs)} peak_events={len(peak_event_ids)} "
        f"ambience_keys={len(ambience_keys)} music_keys={len(music_keys)} "
        f"demo_contracts={len(demo_contracts)} demo_foley_events={foley_events}"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
