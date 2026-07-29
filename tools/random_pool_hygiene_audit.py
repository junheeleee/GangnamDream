#!/usr/bin/env python3
"""Lock ORDER-46 random-pool prose/effect hygiene and anti-sermon ratchets."""

from __future__ import annotations

import json
import sys
from pathlib import Path
from typing import Any


ROOT = Path(__file__).resolve().parents[1]
EVENT_ROOTS = {
    "ko": ROOT / "content" / "events",
    "en": ROOT / "content" / "events_en",
}
EARLY_CALLBACK_RANGE = range(12, 26)
LATE_CALLBACK_RANGE = range(43, 55)
EARLY_LINE_BUDGET = {"ko": 858, "en": 868}
LATE_SECOND_LINE_BUDGET = {"ko": 317, "en": 322}


def load_events(root: Path) -> dict[str, dict[str, Any]]:
    events: dict[str, dict[str, Any]] = {}
    for path in sorted(root.glob("*.json")):
        payload = json.loads(path.read_text(encoding="utf-8"))
        if not isinstance(payload, list):
            raise ValueError(f"{path}: root is not an array")
        for event in payload:
            if not isinstance(event, dict) or not isinstance(event.get("id"), str):
                continue
            event_id = event["id"]
            if event_id in events:
                raise ValueError(f"duplicate event id: {event_id}")
            events[event_id] = event
    return events


def load_callback_file(language: str, number: int) -> list[dict[str, Any]]:
    path = EVENT_ROOTS[language] / f"callback_events_{number}.json"
    payload = json.loads(path.read_text(encoding="utf-8"))
    if not isinstance(payload, list):
        raise ValueError(f"{path}: root is not an array")
    return [event for event in payload if isinstance(event, dict)]


def choice(
    events: dict[str, dict[str, Any]], event_id: str, choice_index: int
) -> dict[str, Any]:
    event = events.get(event_id)
    if event is None:
        raise KeyError(f"missing event: {event_id}")
    choices = event.get("choices")
    if not isinstance(choices, list) or choice_index >= len(choices):
        raise KeyError(f"missing choice {choice_index}: {event_id}")
    selected = choices[choice_index]
    if not isinstance(selected, dict):
        raise TypeError(f"invalid choice {choice_index}: {event_id}")
    return selected


def text_line_count(value: Any) -> int:
    if not isinstance(value, str):
        return 0
    return sum(1 for line in value.splitlines() if line.strip())


def check() -> tuple[list[str], dict[str, int]]:
    errors: list[str] = []
    loaded = {language: load_events(root) for language, root in EVENT_ROOTS.items()}

    unsupported_money = (
        ("jobs_026", 0),
        ("politics_038", 0),
        ("comedy_043", 0),
        ("hidden_007", 0),
        ("gambling_002", 0),
    )
    for event_id, index in unsupported_money:
        effects = choice(loaded["ko"], event_id, index).get("effects", {})
        if isinstance(effects, dict) and effects.get("money", 0) != 0:
            errors.append(
                f"{event_id} choice {index}: unsupported money={effects.get('money')}"
            )

    romance_ko = choice(loaded["ko"], "romance_029", 2)
    romance_en = choice(loaded["en"], "romance_029", 2)
    if romance_ko.get("text") != "프로필 사진을 확인한다":
        errors.append("romance_029: contradictory Korean choice text returned")
    if romance_en.get("text") != "Check their profile picture":
        errors.append("romance_029: English choice parity drifted")
    romance_effects = romance_ko.get("effects", {})
    if not isinstance(romance_effects, dict) or romance_effects != {
        "mental": -2,
        "tint": -1,
    }:
        errors.append(f"romance_029: unrelated effects returned: {romance_effects}")

    gambling_ko = loaded["ko"]["gambling_002"]
    gambling_en = loaded["en"]["gambling_002"]
    required_gambling = (
        (gambling_ko, "거래소 앱을 설치하지 않는다", "앱은 없었다"),
        (gambling_en, "Do not install the exchange app", "app was not there"),
    )
    for event, expected_choice, expected_result in required_gambling:
        first = event["choices"][0]
        if first.get("text") != expected_choice:
            errors.append(f"gambling_002: choice drifted: {first.get('text')}")
        if expected_result not in first.get("result_text", ""):
            errors.append("gambling_002: pre-install result no longer matches its premise")
    third_effects = gambling_ko["choices"][2].get("effects", {})
    if isinstance(third_effects, dict) and "reputation" in third_effects:
        errors.append("gambling_002: anonymous leverage bet grants reputation")

    fomo_ko = choice(loaded["ko"], "hidden_bull_market_fomo", 0)
    fomo_en = choice(loaded["en"], "hidden_bull_market_fomo", 0)
    if fomo_ko.get("effects", {}).get("money") != -300_000:
        errors.append("hidden_bull_market_fomo: execution amount changed")
    if "30만원을 넣었다" not in fomo_ko.get("result_text", ""):
        errors.append("hidden_bull_market_fomo: Korean prose is not 300,000 won")
    if "300,000 won" not in fomo_en.get("result_text", ""):
        errors.append("hidden_bull_market_fomo: English prose is not 300,000 won")

    phone_cost_contracts = {
        "disasters_009": [-180_000, 0, -250_000],
        "disasters_006": [-300_000, -180_000],
        "hidden_004": [-120_000, -60_000, -100_000],
    }
    for event_id, expected_money in phone_cost_contracts.items():
        event = loaded["ko"][event_id]
        actual_money = [
            int(item.get("effects", {}).get("money", 0))
            for item in event.get("choices", [])
            if isinstance(item, dict)
        ]
        if actual_money != expected_money:
            errors.append(
                f"{event_id}: phone repair money {actual_money} != {expected_money}"
            )
        all_event_text = json.dumps(event, ensure_ascii=False)
        if "새 기기를 산다" in all_event_text or "중고폰으로 바꾼다" in all_event_text:
            errors.append(
                f"{event_id}: same-device repair event changes phone ownership in prose"
            )
        for item in event.get("choices", []):
            if isinstance(item, dict) and "investment_effects" in item:
                errors.append(
                    f"{event_id}: phone repair still mutates unrelated market state"
                )
            effects = item.get("effects", {}) if isinstance(item, dict) else {}
            unrelated = {
                "luck", "reputation", "investment_skill", "tint"
            }.intersection(effects)
            if unrelated:
                errors.append(
                    f"{event_id}: phone repair mutates unrelated "
                    f"{sorted(unrelated)}"
                )

    if "18만원" not in loaded["ko"]["disasters_009"].get("description", "") \
            or "25만원" not in loaded["ko"]["disasters_009"].get(
                "description", ""):
        errors.append("disasters_009: repair quote and charged amounts diverged")
    if "180,000 won" not in loaded["en"]["disasters_009"].get(
            "description", "") \
            or "250,000 won" not in loaded["en"]["disasters_009"].get(
                "description", ""):
        errors.append("disasters_009: English repair quote parity drifted")
    rent_ko = loaded["ko"]["survival_rent_due"]
    rent_en = loaded["en"]["survival_rent_due"]
    rent_money = [
        int(item.get("effects", {}).get("money", 0))
        for item in rent_ko.get("choices", [])
        if isinstance(item, dict)
    ]
    if rent_money != [0] \
            or len(rent_ko.get("choices", [])) != 1 \
            or int(rent_ko["choices"][0].get(
                "effects", {}).get("mental", 0)) != -3:
        errors.append(
            "survival_rent_due: reminder is not one honest -3 mental "
            "acknowledgement before monthly settlement"
        )
    if rent_ko.get("conditions", {}).get("housing") != "gosiwon":
        errors.append(
            "survival_rent_due: goshiwon reminder can appear after moving out"
        )
    if "65만원" not in rent_ko.get("description", "") \
            or "52만" in json.dumps(rent_ko, ensure_ascii=False):
        errors.append(
            "survival_rent_due: Korean reminder drifted from 650,000-won housing"
        )
    if "650,000 won" not in rent_en.get("description", "") \
            or "520,000" in json.dumps(rent_en, ensure_ascii=False):
        errors.append(
            "survival_rent_due: English reminder drifted from 650,000-won housing"
        )

    political_ko = choice(loaded["ko"], "political_election_victory", 0)
    political_en = choice(loaded["en"], "political_election_victory", 0)
    if "공천장이 도착했다" not in political_ko.get("result_text", ""):
        errors.append("political_election_victory: Korean scale repair drifted")
    if "당선" in political_ko.get("result_text", ""):
        errors.append("political_election_victory: random card claims election victory")
    if "nomination papers arrived" not in political_en.get("result_text", ""):
        errors.append("political_election_victory: English scale repair drifted")
    if "political_winner" not in political_ko.get("flags", []):
        errors.append("political_election_victory: earned ending flag was disconnected")

    forbidden_fragments = {
        "ko": (
            "감정은 파밈코인만",
            "뉴스를 빨리 읽는 것이 시장을 앞서는 기술이다",
            "뉴스가 뜨기 전에 움직이는 것이 핵심이다",
            "선은 한 번 긋는 게 아니라 반복해서 긋는 것이다",
            "당당한 검소함은, 흔들리지 않는 사람의 표식이었다",
            "남의 방식을 흉내 내지 않으면서도, 배울 건 배웠다",
        ),
        "en": (
            "Reading the news fast is the skill of staying ahead of the market",
            "The key is moving before the news breaks",
            "Proud frugality was the mark of someone unshaken",
            "they still learned what was worth learning",
        ),
    }
    for language, events in loaded.items():
        all_text = json.dumps(events, ensure_ascii=False)
        for fragment in forbidden_fragments[language]:
            if fragment in all_text:
                errors.append(f"{language}: sermon/corruption fragment returned: {fragment}")

    required_labels = {
        "callback_hoesik_boundary_set_echo": ("이번에도 선을 긋는다", "이번엔 참는다"),
        "callback_creator_viral_echo": ("그다음을 준비한다",),
    }
    for event_id, labels in required_labels.items():
        actual = tuple(
            item.get("text", "") for item in loaded["ko"][event_id].get("choices", [])
        )
        for label in labels:
            if label not in actual:
                errors.append(f"{event_id}: declarative choice label missing: {label}")

    early_choices = 0
    early_lines = {"ko": 0, "en": 0}
    late_second_choices = 0
    late_second_lines = {"ko": 0, "en": 0}
    for language in ("ko", "en"):
        for number in EARLY_CALLBACK_RANGE:
            for event in load_callback_file(language, number):
                for item in event.get("choices", []):
                    if not isinstance(item, dict):
                        continue
                    lines = text_line_count(item.get("result_text"))
                    if lines == 0:
                        errors.append(f"{language}:{event.get('id')}: empty callback result")
                    early_lines[language] += lines
                    if language == "ko":
                        early_choices += 1
        for number in LATE_CALLBACK_RANGE:
            for event in load_callback_file(language, number):
                choices = event.get("choices", [])
                if not isinstance(choices, list) or len(choices) < 2:
                    errors.append(f"{language}:{event.get('id')}: late callback lacks two choices")
                    continue
                lines = text_line_count(choices[1].get("result_text"))
                if lines == 0 or lines > 2:
                    errors.append(
                        f"{language}:{event.get('id')}: reserved branch has {lines} lines"
                    )
                late_second_lines[language] += lines
                if language == "ko":
                    late_second_choices += 1

    if early_choices != 400:
        errors.append(f"early callback choice count drifted: {early_choices}")
    if late_second_choices != 162:
        errors.append(f"late callback event count drifted: {late_second_choices}")
    for language, budget in EARLY_LINE_BUDGET.items():
        if early_lines[language] > budget:
            errors.append(
                f"{language}: early callback sermon budget regressed "
                f"{early_lines[language]}>{budget}"
            )
    for language, budget in LATE_SECOND_LINE_BUDGET.items():
        if late_second_lines[language] > budget:
            errors.append(
                f"{language}: late callback sermon budget regressed "
                f"{late_second_lines[language]}>{budget}"
            )

    counts = {
        "events_ko": len(loaded["ko"]),
        "events_en": len(loaded["en"]),
        "early_choices": early_choices,
        "late_second_choices": late_second_choices,
        "early_lines_ko": early_lines["ko"],
        "early_lines_en": early_lines["en"],
        "late_lines_ko": late_second_lines["ko"],
        "late_lines_en": late_second_lines["en"],
    }
    return errors, counts


def main() -> int:
    try:
        errors, counts = check()
    except (OSError, ValueError, KeyError, TypeError, json.JSONDecodeError) as exc:
        print(f"RANDOM_POOL_HYGIENE_AUDIT_FAIL {exc}")
        return 1
    if errors:
        print("RANDOM_POOL_HYGIENE_AUDIT_FAIL")
        for error in errors:
            print(f"  - {error}")
        return 1
    print(
        "RANDOM_POOL_HYGIENE_AUDIT_OK "
        + " ".join(f"{key}={value}" for key, value in counts.items())
    )
    return 0


if __name__ == "__main__":
    sys.exit(main())
