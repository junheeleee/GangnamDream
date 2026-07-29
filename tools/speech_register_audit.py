#!/usr/bin/env python3
"""Lock the authored Korean speech-register repairs from ORDER-45."""

from __future__ import annotations

import json
import sys
from pathlib import Path
from typing import Any


ROOT = Path(__file__).resolve().parents[1]
EVENT_ROOT = ROOT / "content" / "events"
EVENT_ROOT_EN = ROOT / "content" / "events_en"
ENDING_PATHS = {
    "ko": ROOT / "content" / "endings.json",
    "en": ROOT / "content" / "endings_en.json",
}


def flatten_strings(value: Any) -> list[str]:
    if isinstance(value, str):
        return [value]
    if isinstance(value, list):
        result: list[str] = []
        for item in value:
            result.extend(flatten_strings(item))
        return result
    if isinstance(value, dict):
        result = []
        for item in value.values():
            result.extend(flatten_strings(item))
        return result
    return []


def iter_string_paths(
    value: Any, path: tuple[str | int, ...] = ()
) -> list[tuple[tuple[str | int, ...], str]]:
    if isinstance(value, str):
        return [(path, value)]
    result: list[tuple[tuple[str | int, ...], str]] = []
    if isinstance(value, list):
        for index, item in enumerate(value):
            result.extend(iter_string_paths(item, path + (index,)))
    elif isinstance(value, dict):
        for key, item in value.items():
            result.extend(iter_string_paths(item, path + (key,)))
    return result


def value_at_path(value: Any, path: tuple[str | int, ...]) -> Any:
    current = value
    for part in path:
        if not isinstance(current, (dict, list)):
            return None
        try:
            current = current[part]
        except (IndexError, KeyError, TypeError):
            return None
    return current


def load_events(event_root: Path) -> dict[str, tuple[str, dict[str, Any]]]:
    events: dict[str, tuple[str, dict[str, Any]]] = {}
    errors: list[str] = []
    for path in sorted(event_root.glob("*.json")):
        payload = json.loads(path.read_text(encoding="utf-8"))
        if not isinstance(payload, list):
            errors.append(f"{path.name}: root is not an array")
            continue
        for event in payload:
            if not isinstance(event, dict) or not isinstance(event.get("id"), str):
                continue
            event_id = event["id"]
            if event_id in events:
                errors.append(
                    f"duplicate event id {event_id}: "
                    f"{events[event_id][0]} and {path.name}"
                )
                continue
            events[event_id] = (path.name, event)
    if errors:
        raise ValueError("\n".join(errors))
    return events


def load_endings() -> dict[str, dict[str, dict[str, Any]]]:
    endings: dict[str, dict[str, dict[str, Any]]] = {}
    for language, path in ENDING_PATHS.items():
        payload = json.loads(path.read_text(encoding="utf-8"))
        if not isinstance(payload, list):
            raise ValueError(f"{path.name}: root is not an array")
        language_endings: dict[str, dict[str, Any]] = {}
        for ending in payload:
            if not isinstance(ending, dict) or not isinstance(ending.get("id"), str):
                continue
            ending_id = ending["id"]
            if ending_id in language_endings:
                raise ValueError(f"{path.name}: duplicate ending id {ending_id}")
            language_endings[ending_id] = ending
        endings[language] = language_endings
    return endings


# Contracts are deliberately event-scoped. A phrase such as "다은아" can be
# correct when spoken by her mother, while it violates Minjun's established
# register in the final-choice scene.
CONTRACTS: dict[str, dict[str, Any]] = {
    "arc_opp_jiyeon_bunyang": {
        "file": "arc_events.json",
        "required": [
            "오빠한테만 말하는 거예요",
            "왜 저한테 이걸 주는 거예요?",
            "고마워요. 근데 이건 제 힘으로 하고 싶어요.",
        ],
        "forbidden": [
            "너한테만 말하는 거야",
            "왜 나한테 이걸 줘?",
            "잘 생각했어.",
            "넌 진짜 이상한 사람이야",
        ],
    },
    "arc_jiyeon_y5_feelings": {
        "file": "arc_romance_y5.json",
        "required": ["이번 달에 서울 올라와요. 보고 싶으면 연락해요."],
        "forbidden": ["이번 달에 서울 올라와. 보고 싶으면 연락해."],
    },
    "jiyeon_world_gap": {
        "file": "relationship_events.json",
        "required": [
            "오늘 멋있었어.",
            "그게 멋있어요?",
            "오늘 좀 불편했지?",
        ],
        "forbidden": [
            "오늘 멋있었어요.",
            "그게 멋있어?",
            "오늘 좀 불편했죠?",
        ],
    },
    "jiyeon_mother": {
        "file": "relationship_events.json",
        "required": ["엄마가 문자 했어.", "엄마가 오빠 직업 물어봤어."],
        "forbidden": ["엄마가 문자 했어요.", "엄마가 당신 직업 물어봤어요."],
    },
    "jiyeon_gangnam_moment": {
        "file": "relationship_events.json",
        "required": ["'왔어?'", "'...네.'", "'축하해. 진심으로.'"],
        "forbidden": ["'왔어요?'", "'축하해요. 진심으로.'"],
    },
    "arc_jiyeon_verdict_decision": {
        "file": "arc_jiyeon_married.json",
        "required": ["바뀔게요. 당신 세계에 맞출게요. 뭐든 할게요."],
        "forbidden": ["바뀔게. 당신 세계에 맞출게. 뭐든 할게."],
    },
    "arc_jiyeon_narrow_room_2": {
        "file": "arc_romance_specials.json",
        "required": ["오늘은 뭐가 거짓이었어요?"],
        "forbidden": ["오늘은 뭐가 거짓이었어?"],
    },
    "arc_jiyeon_narrow_room_decision": {
        "file": "arc_romance_specials.json",
        "required": ["불기 전에 먹어요."],
        "forbidden": ['불기 전에 먹어."'],
    },
    "arc_jiyeon_wedding_night": {
        "file": "arc_romance_specials.json",
        "required": ["왜 그렇게 서 있어요.", "한 모금도 안 마셨잖아요."],
        "forbidden": ['왜 그렇게 서 있어."', '한 모금도 안 마셨잖아."'],
    },
    "arc_jiyeon_wedding_night_window": {
        "file": "arc_romance_specials.json",
        "required": ["뭘 봤는데요?", "지금 제 앞에 서 있는 사람이요."],
        "forbidden": ['"뭘 봤는데?"', "지금 내 앞에 서 있는 사람."],
    },
    "arc_jiyeon_wedding_night_glass": {
        "file": "arc_romance_specials.json",
        "required": ["그럼 핑계 없이 긴장한 거네요.", "알았어요."],
        "forbidden": ["그럼 핑계 없이 긴장한 거네.", '"알았지."'],
    },
    "arc_jiyeon_wedding_night_choice": {
        "file": "arc_romance_specials.json",
        "required": ["천하의 한지연이 말이 없네요."],
        "forbidden": ["천하의 한지연이 말이 없네."],
    },
    "callback_jiyeon_gangnam_called_echo": {
        "file": "callback_events_23.json",
        "required": ['"됐어요"라고 했다'],
        "forbidden": ['"됐어"라고 했다'],
    },
    "arc_daeun_later_echo": {
        "file": "arc_events.json",
        "required": ["거의 다 왔어요.", "저도 여기 있어요, 민준씨."],
        "forbidden": ['"거의 다 왔어."', '"나도 여기 있어."'],
    },
    "callback_daeun_understood_echo": {
        "file": "callback_events_18.json",
        "required": [
            "민준씨한테만 하는 말이에요",
            "같이 생각할 수 있을 줄 몰랐어요.",
        ],
        "forbidden": [
            "너한테만 하는 말이야",
            "같이 할 수 있을 줄 몰랐어.",
        ],
    },
    "arc_daeun_year3_together": {
        "file": "arc_daeun_extension.json",
        "required": [
            "2년이나 됐네요. 저도 실감이 안 나요.",
            "지금 다은씨랑 가는 이 지하철이 안 끊겼으면 좋겠어요.",
        ],
        "forbidden": [
            "2년이나 됐네. 나도 실감이 안 나요.",
            "지금 너랑 가는 이 지하철이 안 끊겼으면 좋겠어.",
        ],
    },
    "arc_daeun_year5_ending": {
        "file": "arc_daeun_extension.json",
        "required": [
            "같이 온 거예요. 다은씨 아니었으면 중간에 접었어요.",
            "다은씨가 있어서 포기 안 한 거예요.",
            "저는 벌써 다 가진 것 같은데요.",
        ],
        "forbidden": [
            "같이 온 거야. 너 아니었으면",
            "네가 있어서 포기 안 한 거야.",
            "나는 벌써 다 가진 것 같은데.",
        ],
    },
    "arc_daeun_final_choice_name": {
        "file": "arc_daeun_married.json",
        "required": ['"다은씨."', '"...아니에요."'],
        "forbidden": ['"다은아."', '"...아니야."'],
    },
    "arc_daeun_final_choice_decision": {
        "file": "arc_daeun_married.json",
        "required": ["다은씨, 우리 그냥... 좀 늦게 가요.", "다은씨. 우리 그냥… 좀 늦게 가요."],
        "forbidden": ["다은아, 우리 그냥", "다은아. 우리 그냥"],
    },
    "arc_daeun_money_gap": {
        "file": "arc_midgame.json",
        "required": [
            "카페 이번엔 제가 살게요",
            "저 요즘 투자 좀 되고 있어요",
            "진짜 대단하네요.",
        ],
        "forbidden": [
            "카페 이번엔 내가 살게",
            "나 요즘 투자 좀 되고 있어",
            "진짜 대단하다.",
        ],
    },
    "callback_told_daeun_investing_echo": {
        "file": "callback_events_44.json",
        "required": [
            "민준씨, 그때 투자 얘기 했었잖아요.",
            "말해줘서 고마워요. 민준씨 세계가 조금 보여서 좋아요.",
            "네, 천천히 말해도 돼요.",
        ],
        "forbidden": [
            "너 그때 투자 얘기 했었잖아.",
            "말해줘서 고마워. 네 세계가 조금 보여서 좋아.",
            "응, 천천히 말해도 돼.",
        ],
    },
    "callback_heeded_sangchul_warning_result": {
        "file": "callback_events_12.json",
        "required": ["그때 경고 덕분에 안 갔어요. 고마워요."],
        "forbidden": ["그때 경고 덕분에 안 갔어. 고마워."],
    },
    "callback_dismissed_sangchul_warning_result": {
        "file": "callback_events_12.json",
        "required": ["말씀이 맞았어요."],
        "forbidden": ["네 말이 맞았어."],
    },
    "callback_took_sangchul_tip_result": {
        "file": "callback_events_12.json",
        "required": ['"잘됐어요."라고만 했다'],
        "forbidden": ['"됐어."라고만 했다'],
    },
    "callback_sangchul_deal_regret_echo": {
        "file": "callback_events_17.json",
        "required": ["그때 안 한 게 아쉬웠어요."],
        "forbidden": ["그때 안 한 게 아쉬워."],
    },
    "arc_y3_hyunsu_verdict": {
        "file": "arc_h2_beats.json",
        "required": ["다시 하죠 뭐. 저는 이 속도로 사는 사람이에요."],
        "forbidden": ["다시 하지 뭐. 나는 이 속도로 사는 사람이야."],
    },
    "arc_jiyeon_year5_return": {
        "file": "arc_year3_drama.json",
        "required": [
            "그럼 강남에서 봐, 오빠. 꼭.",
            "처음으로 존댓말이 사라진 문장",
        ],
        "forbidden": [],
    },
    "arc_jiyeon_father_records": {
        "file": "arc_web_crossbeams.json",
        "required": [
            "그게 무슨 말이에요.",
            "저는... 그냥 아빠 회사인 줄 알았어요.",
        ],
        "forbidden": [
            "그게 무슨 말이야.",
            "나는... 그냥 아빠 회사인 줄 알았어.",
        ],
    },
}


ENDING_CONTRACTS: dict[tuple[str, str], dict[str, list[str]]] = {
    ("ko", "gangnam_dream"): {
        "required": [
            "거봐. 오빠는 원래 이런 사람이었잖아.",
            '"내일이죠?" "네."',
        ],
        "forbidden": [
            "거봐요. 당신 이런 사람이었잖아요.",
            '"내일이죠?" "응."',
        ],
    },
    ("ko", "jiyeon_man"): {
        "required": [
            "오빠, 아직 안 자?",
            "…뭘 봐, 오빠.",
            "왔네, 오빠.",
            "오빠가 스스로 나올 사람인 걸 알아서야.",
        ],
        "forbidden": [
            "자, 오빠?",
            "거봐요. 당신",
            "오셨네요.",
            "당신이 스스로 나올 사람인 걸 알아서예요.",
        ],
    },
    ("en", "gangnam_dream"): {
        "required": [
            "This is who you were all along, oppa.",
            '"Tomorrow, right?" "Yes."',
        ],
        "forbidden": [
            "This is who you were all along.",
            '"Tomorrow, right?" "Yeah."',
        ],
    },
    ("en", "jiyeon_man"): {
        "required": [
            "Still awake, oppa?",
            "What are you looking at, oppa?",
            "You made it, oppa.",
            "walk out on your own, oppa.",
        ],
        "forbidden": [
            "You up, oppa?",
            "Sleeping, oppa?",
            '"You made it."',
        ],
    },
}


def main() -> int:
    try:
        events = load_events(EVENT_ROOT)
        events_en = load_events(EVENT_ROOT_EN)
        endings = load_endings()
    except (OSError, ValueError, json.JSONDecodeError) as exc:
        print(f"SPEECH_REGISTER_AUDIT_FAIL load: {exc}")
        return 1

    errors: list[str] = []
    for event_id, contract in CONTRACTS.items():
        record = events.get(event_id)
        if record is None:
            errors.append(f"{event_id}: event missing")
            continue
        source_file, event = record
        if source_file != contract["file"]:
            errors.append(
                f"{event_id}: expected {contract['file']}, found {source_file}"
            )
        blob = "\n".join(flatten_strings(event))
        for fragment in contract["required"]:
            if fragment not in blob:
                errors.append(f"{event_id}: required fragment missing: {fragment}")
        for fragment in contract["forbidden"]:
            if fragment in blob:
                errors.append(f"{event_id}: forbidden fragment remains: {fragment}")

    for event_id, (_, event) in events.items():
        if "jiyeon" not in event_id:
            continue
        en_record = events_en.get(event_id)
        if en_record is None:
            if any("오빠" in text for _, text in iter_string_paths(event)):
                errors.append(f"{event_id}: English overlay missing for oppa register")
            continue
        for path, ko_text in iter_string_paths(event):
            if "오빠" not in ko_text:
                continue
            en_text = value_at_path(en_record[1], path)
            if not isinstance(en_text, str) or "oppa" not in en_text.lower():
                rendered_path = ".".join(str(part) for part in path)
                errors.append(
                    f"{event_id}:{rendered_path}: English overlay drops "
                    "Jiyeon's oppa register"
                )

    for (language, ending_id), contract in ENDING_CONTRACTS.items():
        ending = endings.get(language, {}).get(ending_id)
        if ending is None:
            errors.append(f"{language}:{ending_id}: ending missing")
            continue
        blob = "\n".join(flatten_strings(ending))
        for fragment in contract["required"]:
            if fragment not in blob:
                errors.append(
                    f"{language}:{ending_id}: required fragment missing: {fragment}"
                )
        for fragment in contract["forbidden"]:
            if fragment in blob:
                errors.append(
                    f"{language}:{ending_id}: forbidden fragment remains: {fragment}"
                )

    if errors:
        print("SPEECH_REGISTER_AUDIT_FAIL")
        for error in errors:
            print(f"  - {error}")
        return 1

    print(
        "SPEECH_REGISTER_AUDIT_OK "
        f"events_ko={len(events)} events_en={len(events_en)} "
        f"event_contracts={len(CONTRACTS)} "
        f"ending_contracts={len(ENDING_CONTRACTS)} "
        "daeun=polite jiyeon=staged minjun=polite"
    )
    return 0


if __name__ == "__main__":
    sys.exit(main())
