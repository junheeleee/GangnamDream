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
    if "pc_bang" in tag_list or "gaming" in tag_list:
        return "pc_bang"
    if "gangnam_station" in tag_list:
        return "gangnam_station"
    if "night" in tag_list or "stress" in tag_list:
        return "late_night"
    if "gosiwon" in tag_list:
        return "goshiwon_room"
    return housing_bg(housing)


SEMANTIC_RULES: List[Tuple[str, str, Sequence[str]]] = [
    ("housing_room", "goshiwon_room", ("집들이", "방 안", "방안을", "옆 건물", "창문 밖", "my room", "housewarming")),
    ("gym", "gym", ("헬스장", "운동", "달리기", "러닝", "workout", "gym", "exercise")),
    ("hospital", "hospital", ("병원", "의사", "검진", "응급실", "입원", "퇴원", "hospital", "doctor", "checkup", "clinic")),
    ("study", "library", ("도서관", "열람실", "독서", "책을", "library", "reading room")),
    ("study_cafe", "study_cafe", ("스터디카페", "공부 카페", "study cafe")),
    ("cafe", "cafe", ("카페", "커피", "cafe", "coffee")),
    ("office", "office", ("사무실", "회사", "직장", "면접", "office", "interview")),
    ("convenience", "convenience_night", ("편의점", "convenience store")),
    ("subway", "subway", ("지하철", "subway")),
    ("realestate", "realestate_office", ("부동산", "중개소", "청약", "전세", "real estate")),
    ("holdem", "holdem_club", ("홀덤", "포커", "poker", "holdem", "texas hold'em")),
    ("racetrack", "racetrack_betting", ("경마", "경마장", "경마공원", "마권", "racetrack", "racecourse")),
]


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
        expected = expected_for_text(start_text)
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
