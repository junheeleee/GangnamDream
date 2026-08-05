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
        if not ambience or ambience not in ambience_keys | DYNAMIC_AMBIENCE_KEYS:
            errors.append(f"{owner}: unknown or empty ambience key {ambience!r}")
        music = contract.get("music")
        if bool(contract.get("suppress_music", False)) and music is not None:
            errors.append(f"{owner}: suppress_music and music cannot coexist")
        suppress_human = contract.get("suppress_human_ambience", False)
        if not isinstance(suppress_human, bool):
            errors.append(f"{owner}: suppress_human_ambience must be a boolean")
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

    for event_id in sorted(PRIVATE_OFFICE_EVENT_IDS):
        contract = event_contracts.get(event_id, {})
        if not isinstance(contract, dict):
            errors.append(f"{event_id}: private-office audio contract is missing")
            continue
        if contract.get("ambience") != "office":
            errors.append(f"{event_id}: private office must retain office room tone")
        if contract.get("suppress_human_ambience") is not True:
            errors.append(f"{event_id}: private office must suppress anonymous human ambience")

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
