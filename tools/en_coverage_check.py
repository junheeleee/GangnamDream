#!/usr/bin/env python3
"""EN 커버리지 누수 체커 — KR 본문/변형/선택지가 EN 오버레이에 빠져 영어
플레이어에게 한글이 새는 경우를 전수 검출한다. audit 보조용(재발 방지턱).

사용: python3 tools/en_coverage_check.py   (누수 0이면 exit 0)
"""
import json, glob, os, sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
KRDIR = os.path.join(ROOT, 'content', 'events')
ENDIR = os.path.join(ROOT, 'content', 'events_en')
VARIANTS = ['description_orthodox', 'description_unorthodox',
            'description_low_mental', 'description_long_gosiwon']

def load(p):
    try:
        d = json.load(open(p, encoding='utf-8'))
        return d if isinstance(d, list) else []
    except Exception:
        return []

en_by_id = {}
for f in glob.glob(os.path.join(ENDIR, '*.json')):
    for e in load(f):
        if isinstance(e, dict) and 'id' in e:
            en_by_id[e['id']] = e

leaks = []
for f in glob.glob(os.path.join(KRDIR, '*.json')):
    for e in load(f):
        if not isinstance(e, dict) or 'description' not in e:
            continue
        eid = e['id']
        en = en_by_id.get(eid)
        if en is None:
            leaks.append((eid, 'NO_EN_OVERLAY'))
            continue
        for v in VARIANTS:
            if v in e and v not in en:
                leaks.append((eid, 'MISSING_' + v))
        # description_if_known: KR이 분기 본문을 가지면 EN도 같은 플래그 키를
        # 가져야 한다(merge가 per-key라 EN에 키 없으면 KR 한글이 그대로 렌더됨).
        kr_dik = e.get('description_if_known')
        if isinstance(kr_dik, dict) and kr_dik:
            en_dik = en.get('description_if_known')
            if not isinstance(en_dik, dict):
                leaks.append((eid, 'MISSING_description_if_known(%d keys)' % len(kr_dik)))
            else:
                miss = [k for k in kr_dik if k not in en_dik]
                if miss:
                    leaks.append((eid, 'MISSING_dik_keys:' + ','.join(miss)))
        if len(en.get('choices', [])) < len(e.get('choices', [])):
            leaks.append((eid, 'FEWER_CHOICES %d<%d' % (
                len(en.get('choices', [])), len(e.get('choices', [])))))

if leaks:
    print('EN coverage leaks: %d' % len(leaks))
    for eid, why in leaks:
        print('  %s  %s' % (eid, why))
    sys.exit(1)
print('EN coverage: clean (no Korean leaking to EN players)')
sys.exit(0)
