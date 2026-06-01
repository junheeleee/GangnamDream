#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""일방적 선택지(트레이드오프 없는 것) 탐지.
좋기만/나쁘기만 한 선택지를 찾는다. opportunity(도박)·follow_up(하류 분기)은 제외."""
import json, glob, os
ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
GOOD_POS = {"money","health","mental","intelligence","social_skill",
            "investment_skill","luck","reputation","appearance"}
GOOD_NEG = {"stress","gambling_tendency","addiction_tendency"}

def load(p):
    d=json.load(open(p,encoding="utf-8"))
    if isinstance(d,list): return d
    if isinstance(d,dict): return d.get("events", list(d.values()))
    return []

one_good=[]; one_bad=[]; total_choices=0; flat=0
for p in glob.glob(os.path.join(ROOT,"content/events/*.json")):
    for e in load(p):
        if str(e.get("rarity",""))=="story": continue   # 스토리/시나리오는 별도
        for ci,ch in enumerate(e.get("choices",[])):
            total_choices+=1
            if ch.get("opportunity") or ch.get("follow_up_event"): continue
            eff=ch.get("effects",{}) or {}
            if not eff: flat+=1; continue
            ben=det=False
            for k,v in eff.items():
                if v==0: continue
                if (k in GOOD_POS and v>0) or (k in GOOD_NEG and v<0): ben=True
                elif (k in GOOD_POS and v<0) or (k in GOOD_NEG and v>0): det=True
            tag="%s [%s] 선택%d: %s" % (os.path.basename(p), e.get("id","?"), ci, str(ch.get("text",""))[:28])
            if ben and not det: one_good.append((tag,eff))
            elif det and not ben: one_bad.append((tag,eff))

print("총 선택지: %d" % total_choices)
print("효과 없음(중립): %d" % flat)
print("■ 좋기만 한 선택지: %d" % len(one_good))
print("■ 나쁘기만 한 선택지: %d" % len(one_bad))
print("\n=== 좋기만 한 것 샘플 10 ===")
for t,e in one_good[:10]: print("  +", t, dict(e))
print("\n=== 나쁘기만 한 것 샘플 6 ===")
for t,e in one_bad[:6]: print("  -", t, dict(e))
