#!/usr/bin/env python3
"""Bounded PR31 elapsed-quantity regression, not a prose or father-state verdict."""

from __future__ import annotations

import json
from pathlib import Path

import zh_translation_audit as audit


ROOT = Path(__file__).resolve().parents[1]
SOURCE = "아버지가 떠난 지 여덟 달이 넘었다."
SOURCE_NINE = SOURCE.replace("여덟", "아홉")
SOURCE_EQUAL = "아버지가 떠난 지 여덟 달이었다."
YEAR_SOURCE = "십 년이 넘은 보증인 칸."


def _description(directory: str, event_id: str = "arc_father_legacy") -> str:
    path = ROOT / "content" / directory / "arc_year3_drama.json"
    rows = json.loads(path.read_text(encoding="utf-8"))
    matches = [row for row in rows if row.get("id") == event_id]
    if len(matches) != 1 or not isinstance(matches[0].get("description"), str):
        raise ValueError(f"expected one {event_id} description: {path}")
    return matches[0]["description"]


def main() -> int:
    failures: list[str] = []
    cases = 0

    def numeric(label: str, source: str, target: str, valid: bool) -> None:
        nonlocal cases
        cases += 1
        errors = audit._numeric_errors(source, target)
        if bool(errors) == valid:
            failures.append(f"{label}: expected valid={valid}, got {errors}")

    # Check the classification independently of targets. A different actor
    # predicate or non-over threshold does not acquire this narrow admission.
    # The returned-father case tests parser scope, not whether he is alive.
    for label, source, kind, value in (
        ("departed-over", SOURCE, "duration_month_over", 8),
        ("changed-source", SOURCE_NINE, "duration_month_over", 9),
        ("equal-source", SOURCE_EQUAL, "duration_month", 8),
        ("other-predicate", "아버지가 돌아온 지 여덟 달이 넘었다.", "duration_month", 8),
        ("guarantor-year-over", YEAR_SOURCE, "duration_year_over", 10),
        ("guarantor-changed-years", YEAR_SOURCE.replace("십 년", "십일 년"), "duration_year_over", 11),
        ("guarantor-equal-years", "십 년 된 보증인 칸.", "year", 10),
        ("other-year-predicate", "십 년이 넘은 연락처.", "year", 10),
    ):
        cases += 1
        actual = [(q.kind, q.value) for q in audit._source_counter_quantities(source)]
        if actual != [(kind, value)]:
            failures.append(f"{label}: expected {[(kind, value)]}, got {actual}")

    actual_source = _description("events")
    if not actual_source.startswith(SOURCE):
        raise ValueError("PR31 father-description source no longer has the observed prefix")
    for lang, unit, over, father, extra in (
        ("zh-CN", "个", "超过", "父亲离开，已经", "另有九个人。"),
        ("zh-TW", "個", "超過", "父親離開，已經", "另有九個人。"),
    ):
        more_months = f"八{unit}多月"
        equal_months = f"八{unit}月"
        target = f"{father}{more_months}了。"
        actual_target = _description(f"events_{lang}")
        if not actual_target.startswith(target):
            raise ValueError(f"{lang}: observed PR31 target prefix changed")
        numeric(f"{lang}/actual-full-description", actual_source, actual_target, True)
        numeric(f"{lang}/explicit-over", SOURCE, f"{father}{over}{equal_months}了。", True)
        numeric(f"{lang}/old-over", "생각해보니 여덟 달이 넘었다.", target, True)
        numeric(f"{lang}/equality-control", SOURCE_EQUAL, target.replace(more_months, equal_months), True)

        # Every mutation derives from a passing control. No new target syntax
        # is accepted: value, unit, threshold, sign and extra count guards stay.
        for label, changed in (
            ("nine", target.replace("八", "九")),
            ("eighty", target.replace("八", "八十")),
            ("year-unit", target.replace("多月", "多年")),
            ("lost-over", target.replace(more_months, equal_months)),
            ("under", target.replace(more_months, f"不到{equal_months}")),
            ("negated-over", target.replace(more_months, f"未{over}{equal_months}")),
            ("negative-count", target.replace("八", "-八")),
            ("extra-count", target + extra),
        ):
            numeric(f"{lang}/{label}", SOURCE, changed, False)
        for prefix in ("不是", "並不是", "并不是"):
            numeric(f"{lang}/direct-negation-{prefix}", SOURCE,
                    target.replace(more_months, prefix + more_months), False)
        numeric(f"{lang}/source-value-changed", SOURCE_NINE, target, False)

    year_event = "arc_y5_final_father_answer_alive"
    actual_year_source = _description("events", year_event)
    if "십 년이 넘은 보증인 칸" not in actual_year_source:
        raise ValueError("PR31 guarantor-description source predicate changed")
    for lang, field, month_unit, extra in (
        ("zh-CN", "担保人栏", "个月", "另有九个人。"),
        ("zh-TW", "保證人欄", "個月", "另有九個人。"),
    ):
        target = f"十多年前的{field}。"
        actual_target = _description(f"events_{lang}", year_event)
        if target[:-1] not in actual_target:
            raise ValueError(f"{lang}: observed PR31 guarantor target changed")
        numeric(f"{lang}/actual-guarantor-description", actual_year_source, actual_target, True)
        numeric(f"{lang}/guarantor-over-control", YEAR_SOURCE, target, True)
        for label, changed in (
            ("changed-years", target.replace("十", "十一")),
            ("month-unit", target.replace("多年", f"多{month_unit}")),
            ("lost-over", target.replace("多年", "年")),
            ("under", "不到" + target),
            ("negative-years", "-" + target),
            ("extra-count", target + extra),
        ):
            numeric(f"{lang}/guarantor-{label}", YEAR_SOURCE, changed, False)
        for prefix in ("不是", "並不是", "并不是", "未", "没有", "沒有"):
            numeric(f"{lang}/guarantor-direct-negation-{prefix}",
                    YEAR_SOURCE, prefix + target, False)

    for failure in failures:
        print(f"PR31_QUANTITY_CHECK_FAIL {failure}")
    print(f"PR31_QUANTITY_CHECK {'FAIL' if failures else 'OK'} cases={cases} failures={len(failures)}")
    return int(bool(failures))


if __name__ == "__main__":
    raise SystemExit(main())
