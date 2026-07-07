#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Background semantic audit for Gangnam Dream events.

This is a lightweight QA helper, not a hard gate. It scans event title,
description, tags, and choice result text for strong place signals and reports
where the effective runtime background appears inconsistent or where the event
would benefit from a dedicated explicit background.
"""
from __future__ import annotations

import argparse
import json
import os
import re
from dataclasses import dataclass
from typing import Dict, Iterable, List, Optional, Sequence, Tuple


ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))


@dataclass
class Finding:
    severity: str
    file: str
    event_id: str
    title: str
    expected: str
    actual: str
    reason: str
    choice: str = ""

    def line(self) -> str:
        ch = f" | choice={self.choice}" if self.choice else ""
        return (
            f"[{self.severity}] {self.file}::{self.event_id} "
            f"({self.title}) expected={self.expected} actual={self.actual} "
            f"| {self.reason}{ch}"
        )


def load_json(path: str):
    with open(path, encoding="utf-8") as fh:
        return json.load(fh)


def event_files(lang: str) -> List[str]:
    base = os.path.join(ROOT, "content", "events" if lang == "ko" else "events_en")
    if not os.path.isdir(base):
        return []
    return sorted(
        os.path.join(base, fn)
        for fn in os.listdir(base)
        if fn.endswith(".json")
    )


def load_raw_events(lang: str) -> Iterable[Tuple[str, Dict]]:
    for path in event_files(lang):
        try:
            data = load_json(path)
        except Exception as exc:
            yield path, {"id": "__parse_error__", "title": str(exc)}
            continue
        if isinstance(data, list):
            for ev in data:
                if isinstance(ev, dict):
                    yield path, ev


def index_ko_events() -> Dict[str, Dict]:
    indexed: Dict[str, Dict] = {}
    for _path, ev in load_raw_events("ko"):
        eid = str(ev.get("id", ""))
        if eid:
            indexed[eid] = ev
    return indexed


def merge_event_overlay(base: Dict, overlay: Dict) -> Dict:
    merged = json.loads(json.dumps(base, ensure_ascii=False))
    for key, value in overlay.items():
        if key == "choices" and isinstance(value, list) and isinstance(base.get("choices"), list):
            merged_choices = []
            base_choices = base.get("choices", [])
            for i in range(max(len(base_choices), len(value))):
                base_choice = dict(base_choices[i]) if i < len(base_choices) and isinstance(base_choices[i], dict) else {}
                overlay_choice = value[i] if i < len(value) and isinstance(value[i], dict) else {}
                base_choice.update(overlay_choice)
                merged_choices.append(base_choice)
            merged["choices"] = merged_choices
        else:
            merged[key] = value
    return merged


def load_events(lang: str) -> Iterable[Tuple[str, Dict]]:
    if lang == "ko":
        yield from load_raw_events("ko")
        return
    ko_index = index_ko_events()
    for path, ev in load_raw_events("en"):
        eid = str(ev.get("id", ""))
        if eid in ko_index:
            yield path, merge_event_overlay(ko_index[eid], ev)
        else:
            yield path, ev


def text_blob(parts: Sequence[object]) -> str:
    return " ".join(str(p or "") for p in parts).lower()


def has_any(text: str, needles: Sequence[str]) -> bool:
    return any(n.lower() in text for n in needles)


def tags(ev: Dict) -> List[str]:
    return [str(t).lower() for t in ev.get("tags", [])]


def housing_bg(housing: str = "gosiwon") -> str:
    if housing in ("gangnam", "apartment"):
        return "gangnam_apartment"
    if housing in ("villa", "oneroom"):
        return "apartment"
    return "goshiwon_room"


def infer_background_id(ev: Dict, housing: str = "gosiwon") -> str:
    """Mirror ImageRegistry.infer_background_id for audit purposes."""
    tag_list = tags(ev)
    event_id = str(ev.get("id", ""))
    category = str(ev.get("category", "")).lower()
    search = text_blob([
        ev.get("id", ""),
        ev.get("title", ""),
        ev.get("description", ""),
        ev.get("category", ""),
        *tag_list,
    ])

    if "jeongseon" in tag_list or "jeongseon_casino" in tag_list or has_any(search, [
        "정선 카지노", "정선카지노", "jeongseon casino", "casino resort",
    ]):
        if has_any(search, [
            "카지노 입구", "입구", "로비", "서비스 데스크", "출입", "입장",
            "다시 들어", "발이 안 떨어", "나오면서", "entrance", "lobby", "check-in",
        ]):
            return "jeongseon_casino_entrance"
        return "jeongseon_casino_exterior"
    if "hangang" in tag_list or has_any(search, [
        "한강", "한강공원", "한강변", "강변", "여의도공원", "반포대교",
        "han river", "hangang", "riverside promenade", "river walk",
    ]):
        return "hangang_riverside"
    if "namsan" in tag_list or has_any(search, [
        "남산", "남산타워", "n서울타워", "서울타워", "n seoul tower",
        "namsan", "seoul tower",
    ]):
        return "namsan_tower"
    if event_id == "arc_minseo_01_meet":
        return "meeting"
    if event_id in ("arc_minseo_02_real", "arc_minseo_03_arrival", "arc_minseo_03b_not_arrived"):
        return "cafe"
    if event_id in ("arc_jaehyuk_sangchul_echo", "arc_jiyeon_father_records"):
        return "cafe"
    if event_id == "arc_pre_ending_summit":
        return "realestate_office"
    if event_id == "arc_gangnam_real_estate":
        return "investment_phone"
    if event_id == "arc_36_body_signal":
        return "goshiwon_hallway"
    if event_id == "callback_hoesik_payoff":
        return "office"
    if event_id == "casino_chip_exchange":
        return "jeongseon_casino_entrance"
    if event_id == "amb_jeonse_00":
        return "apartment"
    if event_id in ("amb_coin_00", "amb_coin_warn"):
        return "investment_phone"
    if event_id == "amb_hoesik_drink":
        return "goshiwon_room"
    if event_id == "amb_jobswitch_in":
        return "office"
    if event_id == "amb_quit_impulse":
        return "subway"
    if event_id in ("arc_daeun_03b_date", "arc_daeun_05_breaking"):
        return "pojangmacha"
    if "cherry_blossom" in tag_list or "spring_cherry" in tag_list or has_any(search, [
        "벚꽃", "여의도 둑방", "석촌호수", "꽃잎", "cherry blossom", "cherry blossoms",
        "yeouido embankment", "seokchon lake", "petals",
    ]):
        return "cherry_blossom_path"
    if "saju" in tag_list or has_any(search, [
        "사주카페", "사주", "생년월일시", "fortune-reading", "fortune reading",
        "fortune cafe", "saju",
    ]):
        return "saju_cafe"
    if "pojangmacha" in tag_list or has_any(search, [
        "포장마차", "street stall", "pojangmacha",
    ]):
        return "pojangmacha"
    if "hoesik" in tag_list or has_any(search, [
        "회식", "삼겹살집", "삼겹살", "소주", "노래방", "포장마차",
        "company dinner", "hoesik", "samgyeopsal", "soju", "noraebang", "karaoke",
    ]):
        return "company_dinner_restaurant"
    if "heatwave" in tag_list or has_any(search, [
        "폭염", "체감온도 40도", "아스팔트 열기", "냉방 쉼터", "heatwave",
        "heat wave", "feels like 40", "asphalt heat", "cooling shelter",
    ]):
        return "heatwave_city"
    if event_id == "kx_fine_dust" or "fine_dust" in tag_list or has_any(search, [
        "미세먼지", "황사", "kf94", "초미세먼지", "air pollution", "fine dust",
        "yellow dust", "smog", "kf94 mask",
    ]):
        return "fine_dust_sky"
    if event_id == "kx_chuseok_traffic" or has_any(search, [
        "추석 귀성길", "귀성길", "추석 연휴", "고속도로", "시외버스", "ktx는",
        "chuseok traffic", "holiday traffic", "homecoming traffic", "intercity bus",
    ]):
        return "chuseok_highway"
    if event_id == "kx_open_chat" or has_any(search, [
        "오픈채팅", "오픈 채팅", "open chat", "open chatroom", "anonymous chat",
        "online investing chat", "chat room",
    ]):
        return "open_chat_screen"
    if event_id == "kx_monsoon" or has_any(search, [
        "장마", "며칠 째 비", "젖은 우산", "monsoon", "raining for days", "wet umbrellas",
    ]):
        return "street_rainy"
    if event_id == "kx_civil_defense_siren" or has_any(search, [
        "민방위", "사이렌", "civil defense siren", "civil defense drill",
    ]):
        return "street"
    if "hagwon" in tag_list or has_any(search, [
        "학원가", "학원", "대치동", "입시학원", "보습학원", "private academy",
        "academy street", "hagwon", "daechi",
    ]):
        return "hagwon_street"
    if "suneung" in tag_list or has_any(search, [
        "수능", "시험장", "고사장", "수험표", "감독관",
        "college scholastic ability test", "csat", "exam hall", "test hall",
    ]):
        return "suneung_test_hall"
    if "community_center" in tag_list or has_any(search, [
        "주민센터", "동사무소", "행정복지센터", "번호표", "확정일자", "민원 창구",
        "community center", "district office", "public service office", "queue ticket",
    ]):
        return "community_center"
    if "jjimjilbang" in tag_list or has_any(search, [
        "찜질방", "황토방", "사우나", "목욕탕", "찜질복", "나무 베개",
        "jjimjilbang", "korean sauna", "sauna room",
    ]):
        return "jjimjilbang"
    if "reserve_duty" in tag_list or has_any(search, [
        "예비군", "입소 통지서", "훈련 통지", "불참 시 과태료", "reserve forces",
        "reserve duty", "reserve-force", "reserve training", "no-show fine",
    ]):
        return "military_base_gate"
    if event_id == "kx_convenience_store_job" or has_any(search, [
        "편의점 알바 면접", "편의점 점장", "convenience store interview",
        "convenience-store interview",
    ]):
        return "convenience_night"
    if event_id == "kx_claw_machine" or has_any(search, [
        "인형뽑기", "뽑기의 함정", "지하철역 출구 인형뽑기", "claw machine",
    ]):
        return "gangnam_station"
    if event_id == "kx_room_escape" or has_any(search, [
        "방탈출", "방탈출 카페", "escape room",
    ]):
        return "cafe"
    if event_id == "kx_health_insurance" or has_any(search, [
        "건강보험료 고지서", "지역가입자", "health insurance bill",
    ]):
        return "goshiwon_room"
    if event_id == "kx_holiday_alone" or has_any(search, [
        "혼자 보내는 명절", "명절 연휴, 서울은 텅 비었다", "holidays alone",
    ]):
        return "goshiwon_room"
    if event_id == "kx_naver_cafe" or has_any(search, [
        "네이버 카페", "naver café", "naver cafe",
    ]):
        return "goshiwon_room"
    if has_any(search, [
        "신촌 이면도로", "back-alley in sinchon",
    ]):
        return "street"
    if event_id in ("friend_housewarming", "housewarming_alone") or has_any(search, [
        "집들이", "방 안", "방안을", "창문 밖", "옆 건물", "my room",
        "inside the room", "housewarming",
    ]):
        return housing_bg(housing)
    if "holdem" in tag_list or has_any(search, [
        "홀덤", "포커", "텍사스 홀덤", "poker", "holdem",
        "texas hold'em", "green felt", "felt table",
    ]):
        return "holdem_club"
    if "racetrack" in tag_list or "race" in tag_list or has_any(search, [
        "경마", "경마장", "경마공원", "과천", "마권", "기수", "말들이",
        "최종 직선", "horse race", "racetrack", "racecourse", "betting hall",
    ]):
        if has_any(search, ["결과", "스타트", "제1코너", "최종 직선", "관람대", "track view", "finish"]):
            return "racetrack_track"
        return "racetrack_betting"
    if "lotto" in tag_list or has_any(search, ["복권", "로또", "스크래치", "lottery", "scratch"]):
        return "convenience_night"
    if "gym" in tag_list or "exercise" in tag_list or has_any(search, [
        "헬스장", "운동", "달리기", "달렸다", "러닝", "pt ", "gym",
        "exercise", "workout", "fitness", "trainer",
    ]):
        return "gym"
    if "hospital" in tag_list or has_any(search, [
        "병원", "의사", "검진", "응급실", "진료", "입원", "퇴원", "hospital",
        "doctor", "checkup", "clinic", "emergency room", "medical",
    ]):
        return "hospital"
    if "convenience" in tag_list or has_any(search, ["편의점", "convenience store"]):
        return "convenience_night"
    if "scalping" in tag_list:
        return "scalping_room"
    if "realestate" in tag_list or has_any(search, [
        "부동산", "중개소", "청약", "전세", "경매", "보증금", "재개발", "빌라",
        "real estate", "redevelopment", "deposit", "auction",
    ]):
        return "realestate_office"
    if category == "housing" or "housing" in tag_list:
        if "gangnam" in tag_list or "gangnam_station" in tag_list:
            return "gangnam_apartment"
        return housing_bg(housing)
    if "study" in tag_list or has_any(search, [
        "도서관", "열람실", "스터디카페", "독서", "책을", "library", "reading room", "study cafe",
    ]):
        return "library"
    if (
        "job" in tag_list or "work" in tag_list or "office" in tag_list or category == "jobs"
        or has_any(search, ["사무실", "회사", "직장", "면접", "office", "interview"])
    ):
        return "office"
    if "commute" in tag_list or "subway" in tag_list or has_any(search, ["지하철", "subway"]):
        return "subway"
    if (
        "social" in tag_list or "date" in tag_list or "cafe" in tag_list
        or "relationship" in tag_list or category == "romance"
        or has_any(search, ["카페", "커피", "cafe", "coffee"])
    ):
        return "cafe"
    if "investment" in tag_list or category == "investment" or "finance" in tag_list:
        return "investment_phone"
    if "family" in tag_list or category == "family":
        return "dad_house"
    if "hometown" in tag_list:
        return "ktx_window"
    if "rooftop" in tag_list:
        return "rooftop_day"
    if category == "health":
        if "stress" in tag_list or "burnout" in tag_list or "mental" in tag_list:
            return "late_night"
        return "hospital"
    if category == "military" or "military" in tag_list:
        return "military"
    if category == "politics":
        return "gangnam_night"
    if category == "gambling" or "gambling" in tag_list or "crypto" in tag_list:
        return "investment_phone"
    if "pc_bang" in tag_list or "gaming" in tag_list or has_any(search, [
        "pc방", "피시방", "pc bang", "pc cafe", "internet cafe"
    ]):
        return "pc_bang"
    if "gangnam_station" in tag_list:
        return "gangnam_station"
    if "night" in tag_list or "stress" in tag_list:
        return "late_night"
    if "gosiwon" in tag_list:
        return "goshiwon_room"
    return housing_bg(housing)


SEMANTIC_RULES: List[Tuple[str, str, Sequence[str]]] = [
    ("jeongseon_entrance", "jeongseon_casino_entrance", (
        "정선 카지노 카지노 입구", "정선 카지노 입구", "정선 카지노 로비", "카지노 입구",
        "카지노 로비", "서비스 데스크", "출입 게이트", "카지노에 다시 들어",
        "다시 들어간다", "발이 안 떨어", "정선 카지노에서 나오면서",
        "casino entrance", "casino lobby", "casino check-in", "check-in gate",
    )),
    ("jeongseon", "jeongseon_casino_exterior", ("정선 카지노", "정선카지노", "jeongseon casino")),
    ("hangang", "hangang_riverside", ("한강", "한강공원", "한강변", "강변", "han river", "hangang")),
    ("namsan", "namsan_tower", ("남산", "남산타워", "n서울타워", "서울타워", "namsan", "seoul tower")),
    ("cherry_blossom", "cherry_blossom_path", ("벚꽃", "석촌호수", "여의도 둑방", "cherry blossom", "seokchon lake")),
    ("saju", "saju_cafe", ("사주카페", "사주", "생년월일시", "fortune-reading", "fortune cafe", "saju")),
    ("hoesik", "company_dinner_restaurant", ("회식", "삼겹살집", "삼겹살", "company dinner", "hoesik", "samgyeopsal")),
    ("heatwave", "heatwave_city", ("폭염", "체감온도 40도", "아스팔트 열기", "heatwave", "heat wave", "asphalt heat")),
    ("fine_dust", "fine_dust_sky", ("미세먼지", "황사", "kf94", "fine dust", "yellow dust", "air pollution")),
    ("chuseok_highway", "chuseok_highway", ("추석 귀성길", "귀성길", "고속도로", "시외버스", "chuseok traffic", "homecoming traffic")),
    ("open_chat", "open_chat_screen", ("오픈채팅", "오픈 채팅", "open chat", "anonymous chat", "chat room")),
    ("monsoon", "street_rainy", ("장마", "며칠 째 비", "젖은 우산", "monsoon", "raining for days", "wet umbrellas")),
    ("civil_defense", "street", ("민방위", "사이렌", "civil defense siren", "civil defense drill")),
    ("hagwon", "hagwon_street", ("학원가", "학원", "대치동", "입시학원", "hagwon", "private academy")),
    ("suneung", "suneung_test_hall", ("수능", "시험장", "고사장", "수험표", "csat", "exam hall", "test hall")),
    ("community_center", "community_center", ("주민센터", "동사무소", "행정복지센터", "번호표", "community center", "district office")),
    ("jjimjilbang", "jjimjilbang", ("찜질방", "황토방", "사우나", "목욕탕", "jjimjilbang", "korean sauna")),
    ("reserve_duty", "military_base_gate", ("예비군", "입소 통지서", "reserve forces", "reserve duty", "reserve training")),
    ("convenience_store_job", "convenience_night", ("편의점 알바 면접", "편의점 점장", "convenience store interview")),
    ("claw_machine_station", "gangnam_station", ("인형뽑기", "뽑기의 함정", "claw machine")),
    ("room_escape_cafe", "cafe", ("방탈출", "방탈출 카페", "escape room")),
    ("health_insurance_bill", "goshiwon_room", ("건강보험료 고지서", "지역가입자", "health insurance bill")),
    ("holiday_alone_room", "goshiwon_room", ("혼자 보내는 명절", "명절 연휴, 서울은 텅 비었다", "holidays alone")),
    ("online_naver_cafe", "goshiwon_room", ("네이버 카페", "naver café", "naver cafe")),
    ("jiyeon_accident_street", "street", ("신촌 이면도로", "back-alley in sinchon")),
    ("housing_room", "goshiwon_room", ("집들이", "방 안", "방안을", "옆 건물", "창문 밖", "my room", "housewarming")),
    ("gym", "gym", ("헬스장", "운동", "달리기", "러닝", "workout", "gym", "exercise")),
    ("hospital", "hospital", ("병원", "의사", "검진", "응급실", "입원", "퇴원", "hospital", "doctor", "checkup", "clinic")),
    ("study", "library", ("도서관", "열람실", "독서", "책을", "library", "reading room")),
    ("study_cafe", "study_cafe", ("스터디카페", "공부 카페", "study cafe")),
    ("cafe", "cafe", ("카페", "커피", "cafe", "coffee")),
    ("office", "office", ("사무실", "회사", "직장", "면접", "office", "interview")),
    ("convenience", "convenience_night", ("편의점", "convenience store")),
    ("subway", "subway", ("지하철", "subway")),
    ("pojangmacha", "pojangmacha", ("포장마차", "street stall", "pojangmacha")),
    ("realestate", "realestate_office", ("부동산", "중개소", "청약", "전세", "real estate")),
    ("holdem", "holdem_club", ("홀덤", "포커", "poker", "holdem", "texas hold'em")),
    ("racetrack", "racetrack_betting", ("경마", "경마장", "경마공원", "마권", "racetrack", "racecourse")),
]

EXPECTED_BY_EVENT_ID: Dict[str, Tuple[str, str]] = {
    "arc_minseo_01_meet": ("event_id: minseo seminar", "meeting"),
    "arc_minseo_02_real": ("event_id: minseo cafe talk", "cafe"),
    "arc_minseo_03_arrival": ("event_id: minseo cafe reunion", "cafe"),
    "arc_minseo_03b_not_arrived": ("event_id: minseo cafe call", "cafe"),
    "arc_jaehyuk_sangchul_echo": ("event_id: sangchul cafe echo", "cafe"),
    "arc_jiyeon_father_records": ("event_id: jiyeon cafe truth", "cafe"),
    "arc_pre_ending_summit": ("event_id: gangnam real-estate closing", "realestate_office"),
    "arc_gangnam_real_estate": ("event_id: real-estate app check", "investment_phone"),
    "arc_36_body_signal": ("event_id: body signal in goshiwon stairs", "goshiwon_hallway"),
    "callback_hoesik_payoff": ("event_id: manager office callback", "office"),
    "casino_chip_exchange": ("event_id: casino cashier entrance", "jeongseon_casino_entrance"),
    "amb_jeonse_00": ("event_id: neighbor jeonse warning at home", "apartment"),
    "amb_coin_00": ("event_id: coin tip phone call", "investment_phone"),
    "amb_coin_warn": ("event_id: coin warning phone call", "investment_phone"),
    "amb_hoesik_drink": ("event_id: next morning hangover", "goshiwon_room"),
    "amb_jobswitch_in": ("event_id: new office after job switch", "office"),
    "amb_quit_impulse": ("event_id: subway quit impulse", "subway"),
    "arc_daeun_03b_date": ("event_id: Daeun pojangmacha date", "pojangmacha"),
    "arc_daeun_05_breaking": ("event_id: Daeun pojangmacha breakup", "pojangmacha"),
}


def expected_for_text(text: str) -> Optional[Tuple[str, str]]:
    # More specific places first.
    for reason, expected, needles in SEMANTIC_RULES:
        if has_any(text, needles):
            return reason, expected
    return None


def compatible(expected: str, actual: str) -> bool:
    if expected == actual:
        return True
    groups = [
        {"goshiwon_room", "late_night", "apartment", "gangnam_apartment"},
        {"library", "study_cafe", "cafe"},
        {"hospital", "hospital_clinic", "burnout"},
        {"gym", "rooftop_day"},
        {"investment_phone", "trading", "trading_room", "scalping_room"},
        {"convenience_night", "convenience_store"},
        {"racetrack_betting", "racetrack_track"},
    ]
    return any(expected in group and actual in group for group in groups)


def audit(lang: str, include_results: bool = False) -> List[Finding]:
    findings: List[Finding] = []
    for path, ev in load_events(lang):
        eid = str(ev.get("id", ""))
        if eid == "__parse_error__":
            findings.append(Finding("ERROR", rel(path), eid, str(ev.get("title", "")), "parse", "parse", "JSON parse error"))
            continue
        explicit = str(ev.get("background", ""))
        actual = explicit or infer_background_id(ev)
        title = str(ev.get("title", eid))
        start_text = text_blob([
            ev.get("id", ""),
            ev.get("title", ""),
            ev.get("description", ""),
            ev.get("category", ""),
            *tags(ev),
        ])
        expected = EXPECTED_BY_EVENT_ID.get(eid) or expected_for_text(start_text)
        if expected and not compatible(expected[1], actual):
            findings.append(Finding(
                "REVIEW",
                rel(path),
                eid,
                title,
                expected[1],
                actual,
                f"start scene signal: {expected[0]}",
            ))
        if include_results:
            for i, choice in enumerate(ev.get("choices", [])):
                if not isinstance(choice, dict):
                    continue
                result = str(choice.get("result_text", ""))
                if not result.strip():
                    continue
                result_expected = expected_for_text(result.lower())
                if result_expected and not compatible(result_expected[1], actual):
                    findings.append(Finding(
                        "REVIEW",
                        rel(path),
                        eid,
                        title,
                        result_expected[1],
                        actual,
                        f"result text signal: {result_expected[0]}",
                        choice=f"{i + 1}:{str(choice.get('text', ''))[:32]}",
                    ))
    return findings


def rel(path: str) -> str:
    return os.path.relpath(path, ROOT)


def write_markdown(findings: List[Finding], out_path: str) -> None:
    by_sev: Dict[str, List[Finding]] = {}
    for finding in findings:
        by_sev.setdefault(finding.severity, []).append(finding)
    lines = [
        "# Background Semantic Audit",
        "",
        "Generated by `python3 tools/background_semantic_audit.py --markdown docs/BACKGROUND_SEMANTIC_AUDIT.md`.",
        "",
        "This report checks whether event text and effective runtime background semantics appear aligned. It is a QA guide, not a hard failure gate.",
        "",
        "## Summary",
        "",
    ]
    total = len(findings)
    lines.append(f"- Total findings: {total}")
    for sev in sorted(by_sev):
        lines.append(f"- {sev}: {len(by_sev[sev])}")
    if total == 0:
        lines.extend(["", "No semantic background review findings."])
    else:
        lines.extend(["", "## Findings", ""])
        for finding in findings:
            lines.append(f"- `{finding.line()}`")
    with open(out_path, "w", encoding="utf-8") as fh:
        fh.write("\n".join(lines) + "\n")


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--lang", choices=["ko", "en", "both"], default="both")
    ap.add_argument("--include-results", action="store_true", help="Also scan choice result_text for possible scene transitions")
    ap.add_argument("--markdown", help="Write a markdown report to this path")
    args = ap.parse_args()

    langs = ["ko", "en"] if args.lang == "both" else [args.lang]
    findings: List[Finding] = []
    for lang in langs:
        for finding in audit(lang, include_results=args.include_results):
            finding.file = f"{lang}:{finding.file}"
            findings.append(finding)

    for finding in findings:
        print(finding.line())
    print(f"SUMMARY total={len(findings)}")

    if args.markdown:
        out = args.markdown
        if not os.path.isabs(out):
            out = os.path.join(ROOT, out)
        write_markdown(findings, out)
        print(f"WROTE {rel(out)}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
