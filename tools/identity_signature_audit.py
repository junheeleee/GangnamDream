#!/usr/bin/env python3
"""Check that the flagship signature table is enforced instead of merely written.

`docs/IP_VISUAL_IDENTITY.md` gives each of the six leads a locked silhouette, a
signature material, an owned prop, and an audio motif. Until now no tool read
it. A signature is not what a document declares; it is what recurs.

Honesty rules for this check:

* Known defects present when this tool was written are recorded in the
  baseline and only ratchet: a **new** failure fails the audit, an existing one
  does not block the build. Resolving one is reported and asks for a baseline
  update, so debt cannot quietly return.
* Prop recurrence is a **text proxy** — it counts how often the prop's keywords
  appear in asset canon, which is not the same as seeing it in the picture. It
  ratchets but never claims a visual pass.
* The 64 px silhouette gate and scene ownership **cannot be automated**. They
  are reported as pending human judgment and are never counted as passing.
"""

from __future__ import annotations

import argparse
import json
import re
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from human_gates import print_pending  # noqa: E402

ROOT = Path(__file__).resolve().parents[1]
SIGNATURE = ROOT / "content" / "meta" / "identity_signature.json"
PROSE_CANON = ROOT / "docs" / "IP_VISUAL_IDENTITY.md"
AUDIO_CHECK = ROOT / "tools" / "AudioAssetCheck.gd"
AUDIO_DIR = ROOT / "assets" / "audio"
BASELINE = Path(__file__).resolve().parent / "identity_signature_baseline.json"

ASSET_CANON = [
    ROOT / "assets" / "ASSET_INDEX.md",
    ROOT / "assets" / "CHARACTER_VISUAL_BIBLE.md",
]

# 파생값이므로 정본 JSON이 아니라 검사 도구가 갖는다. 소품 문장에서 뽑은
# 검색어이며, 그림에 실제로 있는지가 아니라 자산 정본이 그것을 말하는지를 센다.
PROP_KEYWORDS = {
    "minjun": ["account statement", "잔고", "명세서"],
    "jiyeon": ["car key", "차 키", "earring", "귀걸이"],
    "daeun": ["hair clip", "머리핀", "post-it", "포스트잇"],
    "jaehyuk": ["pocha photograph", "포장마차", "photograph", "사진"],
    "sangchul": ["business card", "명함"],
    "father": ["23-second", "23초", "debt record", "빚"],
}

# 사람 게이트는 docs/human_gates.json 이 소유한다. 이 도구가 목록을 들고 있으면
# 다른 도메인의 검사들과 갈라져, 어디까지가 사람 몫인지 저장소가 두 벌로 답한다.


def load_signature() -> dict:
    return json.loads(SIGNATURE.read_text(encoding="utf-8"))


def motif_roster_from_gd() -> list[str]:
    if not AUDIO_CHECK.is_file():
        return []
    text = AUDIO_CHECK.read_text(encoding="utf-8")
    match = re.search(r"STORY_MOTIF_KEYS\s*=\s*\[([^\]]*)\]", text)
    if not match:
        return []
    return re.findall(r'"([^"]+)"', match.group(1))


def audio_assets() -> list[str]:
    if not AUDIO_DIR.is_dir():
        return []
    return [p.stem for p in AUDIO_DIR.iterdir() if p.is_file()]


def prop_mentions(character: str) -> int:
    total = 0
    for path in ASSET_CANON:
        if not path.is_file():
            continue
        text = path.read_text(encoding="utf-8").lower()
        for keyword in PROP_KEYWORDS.get(character, []):
            total += text.count(keyword.lower())
    return total


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--update-baseline", action="store_true")
    args = parser.parse_args()

    if not SIGNATURE.is_file():
        print("IDENTITY_SIGNATURE_FAIL: content/meta/identity_signature.json 이 없다")
        return 1

    data = load_signature()
    flagship = data.get("flagship", {})
    # (키, 사람이 읽는 문장). 키는 안정적이어야 래칫이 성립한다.
    failures: list[tuple[str, str]] = []
    notes: list[str] = []

    # 1) 표 완전성 — 빈 칸은 발견 대상이지 통과 대상이 아니다.
    required = ("locked_silhouette", "signature_material", "owned_prop", "audio_motif")
    for cid, row in sorted(flagship.items()):
        for field in required:
            if not str(row.get(field, "")).strip():
                failures.append((f"empty:{cid}.{field}", f"{cid}.{field}: 서명표가 비어 있다"))

    # 2) 산문 정본과의 인물 집합 일치
    if PROSE_CANON.is_file():
        prose = PROSE_CANON.read_text(encoding="utf-8")
        for cid, row in sorted(flagship.items()):
            if row.get("name_en", "") and row["name_en"] not in prose:
                failures.append((
                    f"stale:{cid}",
                    f"{cid}: `{row['name_en']}` 가 산문 정본에 없다. 투영이 낡았다",
                ))

    # 3) 모티프 명단 정합 — 두 정본이 다른 인물을 모티프 주체로 보면 실패다.
    roster = motif_roster_from_gd()
    if roster:
        missing = sorted(set(flagship) - set(roster))
        extra = sorted(set(roster) - set(flagship))
        if missing or extra:
            failures.append((
                "motif_roster_mismatch",
                "모티프 명단 불일치 — AudioAssetCheck.STORY_MOTIF_KEYS 에 "
                f"없는 주연 {missing or '없음'} / 서명표에 없는 키 {extra or '없음'}",
            ))

    # 4) 모티프 자산 존재. 아버지 모티프는 민준의 4음 테마에서 파생되므로
    #    민준의 것이 없으면 아버지의 정의가 성립하지 않는다.
    stems = audio_assets()
    have = {cid: any(cid in s for s in stems) for cid in flagship}
    absent = sorted(c for c, ok in have.items() if not ok)
    if absent:
        notes.append(f"모티프 오디오 없음: {', '.join(absent)}")
    if "minjun" in absent and "father" in flagship:
        failures.append((
            "father_motif_depends_on_absent_minjun_theme",
            "민준의 4음 테마 자산이 없는데 아버지 모티프가 그 결손으로 정의돼 있다 "
            "— 존재하지 않는 테마에 기대는 정의다",
        ))

    # 5) 소품 되풀이 — 텍스트 프록시. 래칫만 걸고 시각 통과를 주장하지 않는다.
    mentions = {cid: prop_mentions(cid) for cid in sorted(flagship)}
    zero = [c for c, n in mentions.items() if n == 0]
    if zero:
        for cid in zero:
            failures.append((
                f"prop_unmentioned:{cid}",
                f"{cid}: 소유 소품이 자산 정본에서 한 번도 언급되지 않는다",
            ))

    if args.update_baseline or not BASELINE.is_file():
        BASELINE.write_text(
            json.dumps(
                {"prop_mentions": mentions, "known_failures": sorted(k for k, _ in failures)},
                ensure_ascii=False,
                indent=2,
            )
            + "\n",
            encoding="utf-8",
        )
        print(
            "IDENTITY_SIGNATURE_BASELINE_WRITTEN known_failures="
            f"{len(failures)} " + json.dumps(mentions)
        )
        return 0

    stored = json.loads(BASELINE.read_text(encoding="utf-8"))
    baseline = stored["prop_mentions"]
    known = set(stored.get("known_failures", []))
    for cid, count in mentions.items():
        before = baseline.get(cid)
        if before is not None and count < before:
            failures.append((f"prop_regression:{cid}", f"{cid} 소품 언급: {before} → {count} (줄었다)"))

    width = max(len(c) for c in flagship)
    print("  소품 언급(텍스트 프록시)")
    for cid, count in mentions.items():
        before = baseline.get(cid, "-")
        mark = "" if str(before) == str(count) else f"  (기준선 {before})"
        motif = "모티프 자산 있음" if have.get(cid) else "모티프 자산 없음"
        print(f"    {cid:<{width}}  {count:>3}   {motif}{mark}")

    print_pending("identity")

    for note in notes:
        print(f"\n  참고: {note}")

    current = {key for key, _ in failures}
    new_failures = [(k, msg) for k, msg in failures if k not in known]
    resolved = sorted(known - current)

    if failures:
        print("\n  알려진 결함 (기준선에 기록됨. 빌드를 막지 않는다):")
        for key, msg in failures:
            if key in known:
                print(f"    · {msg}")

    if resolved:
        print("\n  해소됨 — 기준선에서 지운다:")
        for key in resolved:
            print(f"    ✓ {key}")
        print("    `--update-baseline` 으로 기준선을 갱신해 되돌아오지 못하게 한다.")

    if new_failures:
        print("\nIDENTITY_SIGNATURE_FAIL — 서명이 더 약해졌다:")
        for _, msg in new_failures:
            print(f"  - {msg}")
        return 1

    print(
        f"\nIDENTITY_SIGNATURE_OK flagship={len(flagship)} "
        f"known_failures={len(known)} " + json.dumps(mentions)
    )
    return 0


if __name__ == "__main__":
    sys.exit(main())
