#!/usr/bin/env python3
"""Current recall/time/place facts; runtime and language quality remain separate."""
from __future__ import annotations

import argparse
import copy
import json
from pathlib import Path

from ui_translation_append import _Document
import full_game_localization as full

ROOT = Path(__file__).resolve().parents[1]
LOCALES = {"ko": "events", "en": "events_en", "ja": "events_ja",
           "zh-CN": "events_zh-CN", "zh-TW": "events_zh-TW"}
MEMORY_KEY = "arc_y4_missed_cost_seen&arc_y4_missed_cost_repaired_person"
SELECTORS = {
    "arc_midgame.json": {
        "arc_year_one_mark": (
            ("description",),
            *(("description_memory_if_known", "m4_housing_priority_" + key)
              for key in ("runway", "privacy", "time")),
            *(("choices", i, key) for i in (0, 1) for key in ("text", "result_text")),
        ),
    },
    "arc_year_close.json": {
        "arc_year2_close": (
            ("description",),
            *(("description_if_known", key) for key in (
                "y2_lease_renewed_one_year", "y2_lease_renewed_six_months",
                "y2_lease_move_out_scheduled", "year1_resolve", "year1_numb",
                "jaehyuk_stood_up", "chose_money_over_father", "crossed_line")),
            *(("choices", i, key) for i in range(3) for key in ("text", "result_text")),
        ),
    },
    "arc_hyunsu.json": {
        eid: (("title",), ("description",),
              ("description_if_known", "crossed_line"),
              ("description_if_known", "called_hyunsu_first"),
              ("choices", 1, "result_text"))
        for eid in ("hyunsu_year5_call", "hyunsu_year5_call_father_passed")
    },
    "arc_daeun_extension.json": {
        "arc_daeun_year5_apart": (("description",),),
        "arc_daeun_year5_ending": (("description",),
            *(("description_if_known", key) for key in
              ("daeun_married", "daeun_year4_close", "daeun_romance_started"))),
    },
    "arc_chapter_themes.json": {
        eid: (("description_memory_if_known", MEMORY_KEY),)
        for eid in ("arc_y4_body_witness", "arc_y4_body_witness_hyunsu")
    },
}


HOME = {"ko": "지금 사는 방", "en": "current room", "ja": "今暮らす部屋",
        "zh-CN": "如今住处", "zh-TW": "目前住處"}
STREET = {"ko": "가로등", "en": "streetlamp", "ja": "街灯", "zh-CN": "路灯", "zh-TW": "路燈"}
FINAL_YEAR = {"ko": "마지막 해", "en": "final year", "ja": "最後の年",
              "zh-CN": "最后一年", "zh-TW": "最後一年"}
KIMBAP = {"ko": "삼각김밥", "en": "triangle kimbap", "ja": "三角キンパ",
          "zh-CN": "三角紫菜包饭", "zh-TW": "三角飯捲"}
FIRST_YEAR = {"ko": "첫해", "en": "first year", "ja": "最初の年",
              "zh-CN": "第一年", "zh-TW": "第一年"}
CALENDAR = {"ko": "달력", "en": "calendar", "ja": "カレンダー", "zh-CN": "日历", "zh-TW": "行事曆"}
TRAVEL = {"ko": "이동 시간", "en": "travel time", "ja": "移動時間",
          "zh-CN": "路上所需的时间", "zh-TW": "路程所需的時間"}
GAMEPLAY = {
    "arc_year_one_mark": ("current_housing", [
        ({"mental": 4, "intelligence": 1}, ["arc_year_one_mark_seen", "keeps_records"]),
        ({"mental": -1}, ["arc_year_one_mark_seen"]),
        ({"mental": -2, "investment_skill": 1, "luck": 1}, ["arc_year_one_mark_seen", "grind_mentality"])]),
    "arc_year2_close": ("year2_winter_street_night", [
        ({"mental": 2}, ["arc_year2_close_seen", "year2_confident"]),
        ({"mental": 1}, ["arc_year2_close_seen", "year2_conflicted"]),
        ({}, ["arc_year2_close_seen"])]),
    "hyunsu_year5_call": ("current_housing", [
        ({"mental": 3}, ["hyunsu_year5_call_seen"]), ({"mental": 1}, ["hyunsu_year5_call_seen"])]),
    "hyunsu_year5_call_father_passed": ("current_housing", [
        ({"mental": 3}, ["hyunsu_year5_call_seen"]), ({"mental": 1}, ["hyunsu_year5_call_seen"])]),
    "arc_daeun_year5_apart": ("gangnam_night", [
        ({"mental": 8, "tint": 3}, ["arc_daeun_year5_apart_seen"]),
        ({"mental": 3, "tint": 2}, ["arc_daeun_year5_apart_seen"])]),
    "arc_daeun_year5_ending": ("apartment", [
        ({"mental": 20, "tint": 8}, ["arc_daeun_year5_seen", "daeun_final_together"]),
        ({"mental": 15, "tint": 3}, ["arc_daeun_year5_seen"])]),
}
for event_id in ("arc_y4_body_witness", "arc_y4_body_witness_hyunsu"):
    GAMEPLAY[event_id] = ("current_housing", [
        ({}, ["arc_y4_body_witness_seen", "arc_y4_body_chose_" + action])
        for action in ("care", "deadline", "alone")])


def require(ok, message):
    if not ok:
        raise ValueError(message)


def at(value, keys):
    for key in keys:
        value = value[key]
    return value


def current_rows(raw, filename):
    rows = _Document(raw).value
    require(isinstance(rows, list), "current event array required")
    ids = [row["id"] for row in rows]
    require(len(ids) == len(set(ids)), "duplicate current event ID")
    selected = {row["id"]: row for row in rows if row["id"] in SELECTORS[filename]}
    require(set(selected) == set(SELECTORS[filename]), "current recall event absent")
    return selected


def validate_current(raw, filename, locale, sources):
    rows = current_rows(raw, filename)
    count = 0
    for event_id, selectors in SELECTORS[filename].items():
        row = rows[event_id]
        if locale == "ko":
            background, choices = GAMEPLAY[event_id]
            require(row.get("background") == background, event_id + ": current physical location differs")
            require(len(row["choices"]) == len(choices), event_id + ": choice producer absent")
            for choice, (effects, flags) in zip(row["choices"], choices):
                require(choice.get("effects", {}) == effects
                        and all(type(value) in (int, float) for value in choice.get("effects", {}).values())
                        and choice.get("flags") == flags, event_id + ": typed effects/flag producer differs")
        for keys in selectors:
            text = at(row, keys)
            require(isinstance(text, str) and bool(text.strip()), f"current text absent {event_id}:{keys}")
            facts = []
            if event_id == "arc_year_one_mark" and keys == ("description",):
                facts.append(HOME[locale])
            elif event_id == "arc_year2_close" and keys[0].startswith("description"):
                facts.append(STREET[locale])
            elif event_id.startswith("hyunsu_year5_call") and keys[0] != "choices":
                facts.append(FINAL_YEAR[locale])
            elif event_id == "arc_daeun_year5_apart":
                facts.append(KIMBAP[locale])
            elif event_id == "arc_daeun_year5_ending" and keys == ("description",):
                facts.append(FIRST_YEAR[locale])
            elif keys == ("description_memory_if_known", MEMORY_KEY):
                facts.extend((TRAVEL[locale], CALENDAR[locale]))
            require(all(fact.lower() in text.lower() for fact in facts),
                    f"current chronology/place/recall fact differs {locale}:{event_id}:{keys}")
            if locale in full.LOCALES:
                source = at(sources[event_id], keys)
                leaf = full.Leaf("events", event_id, "content/events/" + filename,
                                 keys, source, "event_standard", lifecycle="shipping")
                require(not full.translation_errors(leaf, locale, text),
                        f"current direct-source translation contract differs {locale}:{event_id}:{keys}")
            count += 1
    return count


def snapshots(locales):
    return {(locale, filename): (ROOT / f"content/{LOCALES[locale]}/{filename}").read_bytes()
            for locale in locales for filename in SELECTORS}


def self_test(files):
    cases = 0
    for locale in LOCALES:
        for filename, event_id, keys, required in (
            ("arc_midgame.json", "arc_year_one_mark", ("description",), HOME[locale]),
            ("arc_year_close.json", "arc_year2_close", ("description",), STREET[locale]),
            ("arc_hyunsu.json", "hyunsu_year5_call", ("description",), FINAL_YEAR[locale]),
            ("arc_daeun_extension.json", "arc_daeun_year5_apart", ("description",), KIMBAP[locale]),
            ("arc_chapter_themes.json", "arc_y4_body_witness",
             ("description_memory_if_known", MEMORY_KEY), CALENDAR[locale]),
        ):
            raw = files[(locale, filename)]
            document = _Document(raw)
            index = next(i for i, row in enumerate(document.value) if row["id"] == event_id)
            previous = at(document.value[index], keys)
            changed = previous.replace(required, "wrong fact", 1)
            require(changed != previous, "inert fact mutation")
            start, end = document.spans[(index, *keys)]
            mutant = (document.text[:start] + json.dumps(changed, ensure_ascii=False)
                      + document.text[end:]).encode()
            sources = current_rows(files[("ko", filename)], filename)
            try:
                validate_current(mutant, filename, locale, sources)
            except ValueError:
                cases += 1
            else:
                raise ValueError("current fact mutation accepted")
    filename = "arc_midgame.json"
    sources = current_rows(files[("ko", filename)], filename)
    changed = copy.deepcopy(_Document(files[("ko", filename)]).value)
    next(row for row in changed if row["id"] == "arc_year_one_mark")["choices"][0]["flags"] = ["wrong"]
    try:
        validate_current(json.dumps(changed, ensure_ascii=False).encode(), filename, "ko", sources)
    except ValueError:
        cases += 1
    else:
        raise ValueError("current producer mutation accepted")
    validate_current(files[("ko", filename)] + b"\n", filename, "ko", sources)
    cases += 1
    print(f"PROSE_RECALL_SELF_TEST_OK cases={cases}")


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--source-only", action="store_true")
    parser.add_argument("--self-test", action="store_true")
    args = parser.parse_args()
    locales = ("ko", "en") if args.source_only else tuple(LOCALES)
    files = snapshots(tuple(LOCALES) if args.self_test else locales)
    counts = {locale: 0 for locale in locales}
    for locale in locales:
        for filename in SELECTORS:
            sources = current_rows(files[("ko", filename)], filename)
            counts[locale] += validate_current(files[(locale, filename)], filename, locale, sources)
    if args.self_test:
        self_test(files)
    print("PROSE_RECALL_OK " + json.dumps({"files": len(locales) * len(SELECTORS),
          "current_leaves": counts, "runtime_or_quality_claim": False}, ensure_ascii=False))
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except (ValueError, KeyError, IndexError, OSError) as exc:
        print("PROSE_RECALL_FAIL " + str(exc))
        raise SystemExit(1)
