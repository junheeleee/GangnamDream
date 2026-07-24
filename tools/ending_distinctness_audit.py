#!/usr/bin/env python3
"""Validate the 35-ending player-facing distinctness audit.

The JSON `condition` field is old authoring metadata in several rows. ROUTES is
therefore a compact mirror of the authoritative branch order in
GameState.check_game_over(), written for human review rather than execution.
"""

from __future__ import annotations

import json
import hashlib
import re
import struct
import sys
from difflib import SequenceMatcher
from itertools import combinations
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
ENDINGS_PATH = ROOT / "content" / "endings.json"
ENDINGS_EN_PATH = ROOT / "content" / "endings_en.json"
AUDIT_PATH = ROOT / "docs" / "ENDING_AUDIT.md"
VISUAL_BIBLE_PATH = ROOT / "assets" / "ENDING_COMPLETE_VISUAL_BIBLE.md"
IMAGE_REGISTRY_PATH = ROOT / "autoloads" / "ImageRegistry.gd"
REGISTRY_ENTRY = re.compile(r'"([^"]+)":\s*"(res://[^"]+)"')

ROUTES = {
    "gangnam_dream": "순자산 30억+; 선행 NG+/신화/배우자 상실/Deep Black/고립/White 분기 미해당",
    "empty_house": "순자산 30억+; 가까운 관계 없음; 아버지 미화해 또는 별세",
    "with_daeun": "38세 종료; 다은 연애 시작; 이혼 아님; 선행 특수 엔딩 미해당",
    "jiyeon_man": "38세 종료; 지연 연애 유지; 지연이 떠나지 않음; 순자산 30억 미만",
    "jaehyuk_way": "순자산 30억+; fell_to_darkness 또는 crossed_line; 배우자 분기 미해당",
    "late_call": "38세 종료; 아버지 화해; 모든 상위 결산 분기 미해당",
    "stable_success": "38세 종료; 순자산 10억+; 정석 정점 등 상위 자산 분기 미해당",
    "ordinary_life": "38세 종료 기본값; 또는 지연 이탈/강남 미달 이혼 변주",
    "burnout": "건강 0 이하 즉시 종료",
    "mental_break": "정신력 0 이하 즉시 종료",
    "bankruptcy": "순자산 -2억 이상 -1억 미만 즉시 종료",
    "crypto_ghost": "도박 중독 성향 90+ 즉시 종료; 파산 분기 뒤",
    "startup_exit": "startup_exit 플래그; NG+ 특수 결말 뒤·일반 30억 분기보다 우선",
    "political_fix": "political_winner 플래그; 창업/크리에이터 성공 미해당",
    "lonely_rich": "순자산 30억+ 이혼; 또는 가까운 관계 없이 아버지만 화해·생존",
    "investment_master": "38세 종료; (순자산 5억+·투자감각 55+) 또는 (1억+·투자감각 85+·투자 성향 자각·비정석 우세 15+); 상위 결산 미해당",
    "reputation_legend": "38세 종료; 평판 80+; 회복/상철 청산 등 선행 분기 미해당",
    "healthy_retirement": "38세 종료; 건강·정신 70+; 가까운 관계 있음; 상위 결산 미해당",
    "debt_spiral": "순자산 -2억 미만 즉시 종료",
    "orthodox_pinnacle": "38세 종료; 순자산 10억+; 정석-비정석 15+",
    "orthodox_hollow": "38세 종료; 정석 20+; 순자산 3억 미만; 상위 결산 미해당",
    "balanced_life": "38세 종료; 순자산 1억+; 양 루트 8+; 격차 5 이하",
    "unorthodox_legend": "38세 종료; 순자산 5억+; 비정석-정석 15+",
    "early_retirement": "38세 종료; 순자산 5억+; 현재 무직; 상위 결산 미해당",
    "creator_success": "creator_viral 플래그; 순자산 3억+; 30억 미만",
    "instant_legend": "33세 안에 순자산 30억+",
    "full_circle": "NG+ 상철 진실 기억; 30억+; 아버지 화해·생존; 빚 청산",
    "gangnam_dream_white": "순자산 30억+; moral stage White(+2); 배우자/고립/Deep Black 분기 미해당",
    "second_love": "NG+ 다은 엔딩 기억; 다은 재선택·04b 완료; 순자산 10억+",
    "guardian": "NG+ 아버지 별세 기억; 아버지 우선; 화해·생존",
    "gambling_recovery": "38세 종료; 도박 회복 아크 완료; 연애 결산 미해당",
    "career_climber": "38세 종료; 재직; 순자산 1억+; 이직 성공 또는 최고 티어 4+",
    "career_burnout": "38세 종료; 재직; 번아웃 인지 또는 이직 시동; 상위 결산 미해당",
    "sangchul_reckoning": "38세 종료; 상철 신고 또는 아버지 빚 청산; 아버지 생존",
    "writer": "38세 종료; 사건 90+; 지력 65+; 고시원; 순자산 3억 미만; 상위 결산 미해당",
}

REVIEW_MARKER = re.compile(r"<!-- reviewed-pair: ([a-z0-9_]+)\|([a-z0-9_]+) -->")
TABLE_ID = re.compile(r"^\| `([a-z0-9_]+)` \|", re.MULTILINE)


def _load_rows(path: Path) -> list[dict]:
    return json.loads(path.read_text(encoding="utf-8"))


def _body(row: dict) -> str:
    return "\n".join(
        str(row.get(key, "")) for key in ("description", "detailed_description", "epilogue")
    ).strip()


def _normalized(text: str) -> str:
    text = re.sub(r"\{[^}]+\}", " ", text.lower())
    text = re.sub(r"[^0-9a-z가-힣]+", "", text)
    return text


def _visual_owner(row: dict) -> str:
    if row.get("cg"):
        return "cg:" + str(row["cg"])
    if row.get("background"):
        return "background:" + str(row["background"])
    return "mood-card:generic"


def _png_size(path: Path) -> tuple[int, int] | None:
    header = path.read_bytes()[:24]
    if len(header) != 24 or header[:8] != b"\x89PNG\r\n\x1a\n":
        return None
    return struct.unpack(">II", header[16:24])


def _all_text(row: dict) -> str:
    return json.dumps(row, ensure_ascii=False)


def main() -> int:
    errors: list[str] = []
    rows = _load_rows(ENDINGS_PATH)
    rows_en = _load_rows(ENDINGS_EN_PATH)
    by_id = {str(row.get("id", "")): row for row in rows}
    by_en_id = {str(row.get("id", "")): row for row in rows_en}
    en_ids = set(by_en_id)

    if len(rows) != 35 or len(by_id) != 35:
        errors.append("expected 35 unique endings, got rows=%d ids=%d" % (len(rows), len(by_id)))
    if set(by_id) != en_ids:
        errors.append("KO/EN ending id mismatch")
    if set(by_id) != set(ROUTES):
        errors.append(
            "route mirror mismatch missing=%s extra=%s"
            % (sorted(set(by_id) - set(ROUTES)), sorted(set(ROUTES) - set(by_id)))
        )
    for ending_id, row in by_id.items():
        if not str(row.get("title", "")).strip():
            errors.append("%s: missing title" % ending_id)
        if not _body(row):
            errors.append("%s: missing ending body" % ending_id)

    jiyeon_ko = _all_text(by_id["jiyeon_man"])
    jiyeon_en = _all_text(by_en_id["jiyeon_man"])
    if not str(by_id["jiyeon_man"].get("description", "")).startswith("강남에 살고 있다. 한지연의 강남에."):
        errors.append("jiyeon_man: Korean base must frame Jiyeon's Gangnam, not a 3B arrival")
    if not str(by_en_id["jiyeon_man"].get("description", "")).startswith("He lives in Gangnam. In Han Jiyeon's Gangnam."):
        errors.append("jiyeon_man: English base must frame Jiyeon's Gangnam, not a 3B arrival")
    if "강남에 입성했다. 한지연과 함께." in jiyeon_ko or "He made it to Gangnam. With Han Jiyeon." in jiyeon_en:
        errors.append("jiyeon_man: stale self-funded Gangnam arrival remains in a DIK branch")

    second_ko = _all_text(by_id["second_love"])
    second_en = _all_text(by_en_id["second_love"])
    if "강 건너에서 강남 불빛" not in second_ko or "across the river" not in second_en:
        errors.append("second_love: 1B home must look toward Gangnam from across the river")
    if "강남 아파트" in second_ko or "Gangnam apartment" in second_en:
        errors.append("second_love: stale 3B Gangnam apartment claim remains")

    healthy_ko = _all_text(by_id["healthy_retirement"])
    healthy_en = _all_text(by_en_id["healthy_retirement"])
    if "서른여덟" not in healthy_ko or "Thirty-eight" not in healthy_en:
        errors.append("healthy_retirement: ending must begin at the actual age-38 finish")
    if "55세" in healthy_ko or "fifty-five" in healthy_en.lower():
        errors.append("healthy_retirement: stale age-55 present tense remains")

    early_ko = _all_text(by_id["early_retirement"])
    early_en = _all_text(by_en_id["early_retirement"])
    if "서른여덟" not in early_ko or "thirty-eight" not in early_en.lower():
        errors.append("early_retirement: ending must distinguish age-38 pause from future retirement")
    if "50세 이전에 은퇴했다" in early_ko or "retired before fifty" in early_en.lower():
        errors.append("early_retirement: stale completed-retirement claim remains")

    orthodox_ko = _all_text(by_id["orthodox_pinnacle"])
    orthodox_en = _all_text(by_en_id["orthodox_pinnacle"])
    if "10억. 강남은 아니었다." not in orthodox_ko or "One billion won. It wasn't Gangnam." not in orthodox_en:
        errors.append("orthodox_pinnacle: body must match the actual 1B threshold")
    if "2억. 강남은 아니었다." in orthodox_ko or "Two hundred million" in orthodox_en:
        errors.append("orthodox_pinnacle: stale 200M amount remains")

    startup_ko = by_id["gangnam_dream"].get("description_if_known", {}).get("startup_exit", "")
    startup_en = by_en_id["gangnam_dream"].get("description_if_known", {}).get("startup_exit", "")
    if "엑싯 계약서" not in str(startup_ko) or "acquisition contract" not in str(startup_en):
        errors.append("gangnam_dream: startup_exit DIK is missing or not localized")

    invest_dik_ko = by_id["investment_master"].get("description_if_known", {})
    invest_dik_en = by_en_id["investment_master"].get("description_if_known", {})
    if next(iter(invest_dik_ko), "") != "route_invest" or next(iter(invest_dik_en), "") != "route_invest":
        errors.append("investment_master: route_invest must be the first KO/EN DIK branch")
    committed_ko = str(invest_dik_ko.get("route_invest", ""))
    committed_en = str(invest_dik_en.get("route_invest", ""))
    if "시장에서 살아남는 법" not in committed_ko or "survive it" not in committed_en:
        errors.append("investment_master: committed investor conclusion is missing or not localized")
    if "5억" in committed_ko or "five hundred million" in committed_en.lower():
        errors.append("investment_master: committed investor branch falsely claims the legacy 500M total")

    main_game_source = (ROOT / "scenes" / "MainGame.gd").read_text(encoding="utf-8")
    if "ENDING_CARD_SYMBOL_PATHS" in main_game_source:
        errors.append("MainGame still exposes geometric ending-symbol fallbacks")
    image_registry_source = IMAGE_REGISTRY_PATH.read_text(encoding="utf-8")
    registry = dict(REGISTRY_ENTRY.findall(image_registry_source))
    cg_owners: dict[str, list[str]] = {}
    path_owners: dict[str, list[str]] = {}
    digest_owners: dict[str, list[str]] = {}
    for ending_id, row in by_id.items():
        cg_id = str(row.get("cg", "")).strip()
        if not cg_id:
            errors.append("%s: missing dedicated ending CG id" % ending_id)
            continue
        cg_owners.setdefault(cg_id, []).append(ending_id)
        resource_path = registry.get(cg_id, "")
        if not resource_path:
            errors.append("%s: %s is not wired into ImageRegistry" % (ending_id, cg_id))
            continue
        if not resource_path.startswith("res://"):
            errors.append("%s: non-resource ending CG path %s" % (ending_id, resource_path))
            continue
        path_owners.setdefault(resource_path, []).append(ending_id)
        cg_path = ROOT / resource_path.removeprefix("res://")
        if not cg_path.exists():
            errors.append("%s: dedicated ending CG file missing: %s" % (ending_id, cg_path))
            continue
        size = _png_size(cg_path)
        if size != (1280, 800):
            errors.append("%s: ending CG must be 1280x800 PNG, got %s" % (ending_id, size))
        digest = hashlib.sha256(cg_path.read_bytes()).hexdigest()
        digest_owners.setdefault(digest, []).append(ending_id)
    for cg_id, owners in cg_owners.items():
        if len(owners) > 1:
            errors.append("shared ending CG id %s -> %s" % (cg_id, owners))
    for resource_path, owners in path_owners.items():
        if len(owners) > 1:
            errors.append("shared ending CG path %s -> %s" % (resource_path, owners))
    for digest, owners in digest_owners.items():
        if len(owners) > 1:
            errors.append("pixel-identical ending CGs %s -> %s" % (digest[:12], owners))

    if not AUDIT_PATH.exists():
        errors.append("docs/ENDING_AUDIT.md missing")
        audit_text = ""
    else:
        audit_text = AUDIT_PATH.read_text(encoding="utf-8")
    if not VISUAL_BIBLE_PATH.exists():
        errors.append("assets/ENDING_COMPLETE_VISUAL_BIBLE.md missing")
    else:
        visual_bible_text = VISUAL_BIBLE_PATH.read_text(encoding="utf-8")
        documented = set(TABLE_ID.findall(visual_bible_text))
        if documented != set(by_id):
            errors.append(
                "ending visual bible table mismatch missing=%s extra=%s"
                % (sorted(set(by_id) - documented), sorted(documented - set(by_id)))
            )

    similarity_pairs = []
    for left, right in combinations(rows, 2):
        score = SequenceMatcher(None, _normalized(_body(left)), _normalized(_body(right))).ratio()
        if score >= 0.68:
            pair = tuple(sorted((str(left["id"]), str(right["id"]))))
            similarity_pairs.append((score, pair))
    reviewed_pairs = {tuple(sorted(match)) for match in REVIEW_MARKER.findall(audit_text)}
    unreviewed = [pair for _score, pair in similarity_pairs if pair not in reviewed_pairs]
    if unreviewed:
        errors.append("high-similarity ending pairs not reviewed: %s" % unreviewed)

    visual_groups: dict[str, list[str]] = {}
    for ending_id, row in by_id.items():
        visual_groups.setdefault(_visual_owner(row), []).append(ending_id)
    shared_visuals = {owner: ids for owner, ids in visual_groups.items() if len(ids) > 1}
    generic_ids = set(visual_groups.get("mood-card:generic", []))
    if generic_ids:
        errors.append("generic mood-card backlog must be empty: %s" % sorted(generic_ids))

    print(
        "ENDING_DISTINCTNESS_AUDIT count=%d high_similarity=%d shared_visual_groups=%d symbols=%d dedicated_cg=%d generic=%d"
        % (
            len(rows),
            len(similarity_pairs),
            len(shared_visuals),
            0,
            len(cg_owners),
            len(generic_ids),
        )
    )
    for score, pair in sorted(similarity_pairs, reverse=True):
        print("  text %.3f %s | %s" % (score, pair[0], pair[1]))
    for owner, ids in sorted(shared_visuals.items()):
        print("  visual %s -> %s" % (owner, ", ".join(ids)))
    if errors:
        for error in errors:
            print("ENDING_DISTINCTNESS_ERROR " + error)
        return 1
    print("ENDING_DISTINCTNESS_AUDIT_OK")
    return 0


if __name__ == "__main__":
    sys.exit(main())
