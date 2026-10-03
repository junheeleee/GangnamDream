#!/usr/bin/env python3
"""문장 개선 후보 신호 보고서 (읽기 전용).

docs/queue_backlog/PROSE_REVISION_MASTER_PLAN.md의 R1~R7·E1 후보 신호를 제품 사건에서 센다.
판정 도구가 아니다: 표본 정밀도는 약 50%이며 합격/실패를 내지 않는다.
  python3 tools/prose_signal_report.py            # 층별·신호별 개수
  python3 tools/prose_signal_report.py --write    # PROSE_REVISION_INVENTORY.md 재생성
"""
import json, glob, re, collections, sys

from pathlib import Path
ROOT = str(Path(__file__).resolve().parents[1])
lc = json.load(open(f'{ROOT}/content/meta/event_lifecycle.json'))
AO = set(lc.get('author_only_event_ids', []))

def load(dirname):
    out = {}
    for f in sorted(glob.glob(f'{ROOT}/content/{dirname}/*.json')):
        d = json.load(open(f))
        evs = d if isinstance(d, list) else d.get('events', d)
        it = evs if isinstance(evs, list) else [v for v in evs.values() if isinstance(v, dict)]
        for e in it:
            if isinstance(e, dict) and e.get('id'):
                e['_file'] = f.split('/')[-1]
                out[e['id']] = e
    return out

KO = load('events')
EN = load('events_en')

# ---- month mapping ----
month = {}
sm = json.load(open(f'{ROOT}/content/meta/story_map.json'))
def walk(o, m=None):
    if isinstance(o, dict):
        mm = o.get('month', m)
        for k, v in o.items():
            if isinstance(v, str) and v in KO and isinstance(mm, int):
                month.setdefault(v, mm)
            walk(v, mm)
    elif isinstance(o, list):
        for x in o:
            walk(x, m)
walk(sm)
story_map_ids = set(month)
mg = open(f'{ROOT}/scenes/MainGame.gd').read().split('\n')
for i, line in enumerate(mg):
    m = re.search(r'return "([a-z0-9_]+)"', line)
    if not m or m.group(1) not in KO:
        continue
    for j in range(i, max(0, i - 8), -1):
        t = re.search(r'\bt\s*>=\s*(\d+)', mg[j])
        if t:
            month.setdefault(m.group(1), int(t.group(1)) // 4 + 1)
            break
for eid, e in KO.items():
    c = e.get('conditions') or {}
    mt = c.get('min_turn') if isinstance(c, dict) else None
    if isinstance(mt, (int, float)) and mt < 400:
        month.setdefault(eid, int(mt) // 4 + 1)
# inherit via follow-ups
changed = True
while changed:
    changed = False
    for eid, e in KO.items():
        if eid not in month:
            continue
        for c in e.get('choices', []):
            for k in ('follow_up_event', 'next_event', 'chain_next'):
                nx = c.get(k)
                if isinstance(nx, str) and nx in KO and nx not in month:
                    month[nx] = month[eid]
                    changed = True

def chapter(eid):
    m = month.get(eid)
    if m is None:
        return 0
    return min(5, (m - 1) // 12 + 1) if m <= 60 else 5

# ---- tier proxy ----
registry = set()
rs = open(f'{ROOT}/docs/ROMANCE_SYSTEM.md').read()
for eid in KO:
    if eid in rs:
        registry.add(eid)
def tier(eid, e):
    if eid in registry or e.get('cg') or e.get('cg_if_known'):
        return 'T1'
    if eid in story_map_ids or e.get('category') == 'story' or e.get('rarity') == 'story' or eid.startswith('arc_'):
        return 'T2'
    return 'T3'

# ---- patterns ----
def strip_dialogue(t):
    return re.sub(r'"[^"]*"|“[^”]*”|「[^」]*」', '', t)
def sentences(t):
    t = t.strip()
    return [s for s in re.split(r'(?<=[.!?…])\s+|\n+', t) if s.strip()]

ABS_N = r'(사실|길|자리|시간|대답|의미|선택|빈칸|기록|시각|말|문장|거리|체면|가능성|결과|이유|약속)'
ABS_V = r'(닫혔다|사라졌다|남았다|남지 않았다|확정됐다|확정되었다|바뀌지 않았다|바꾸지 못했다|바꾸어 주지 않았다|줄여 주지는 않았다|되지는 않았다|없어졌다|좁아졌다|숨지 않았다|생겼다)'
P1 = re.compile(ABS_N + r'[^.]{0,30}' + ABS_V)
P1b = re.compile(r'(확정|실제로 .{0,10}(됐다|했다)|따로 남|서로 다른 사실|없던 일로)')
P2 = re.compile(r'(하나(만|뿐)|고르기로|골랐다|셋 다|둘 다 .{0,12}수 있|그중 하나|한 가지만)')
CV = ['실제로', '확정', '사실로', '빈칸', '기록', '시각']
KO_PRES = re.compile(r'[가-힣](ㄴ다|는다|한다|된다|진다|린다|른다|운다|간다|온다|본다|준다)\.?$')
KO_PAST = re.compile(r'(었다|았다|였다|했다|됐다|렸다|졌다)\.?$')

def texts(e):
    out = []
    if e.get('description'):
        out.append(('desc', e['description']))
    for k, v in (e.get('description_if_known') or {}).items():
        out.append((f'dik:{k}', v))
    for i, c in enumerate(e.get('choices', [])):
        if c.get('result_text'):
            out.append((f'r{i+1}', c['result_text']))
    return out

rows = []
for eid, e in KO.items():
    if eid in AO:
        continue
    tr = tier(eid, e)
    flags = collections.OrderedDict()
    alltext = ''
    for key, t in texts(e):
        alltext += t
        ss = sentences(strip_dialogue(t))
        if not ss:
            continue
        last = ss[-1]
        if P1.search(last) or P1b.search(last):
            flags.setdefault('P1', []).append(key)
        if key == 'desc' or key.startswith('dik'):
            tail = ' '.join(ss[-2:])
            if P2.search(tail):
                flags.setdefault('P2', []).append(key)
        pres = sum(1 for s in ss if KO_PRES.search(s.strip()))
        past = sum(1 for s in ss if KO_PAST.search(s.strip()))
        if pres >= 2 and past >= 2:
            flags.setdefault('TENSE', []).append(key)
    base = e.get('description', '')
    for k, v in (e.get('description_if_known') or {}).items():
        if base and len(v) < 0.6 * len(base) and len(base) > 250:
            flags.setdefault('P4', []).append(k)
    n = len(alltext)
    cv = sum(alltext.count(w) for w in CV)
    dens = 10000 * cv / n if n else 0
    if n > 300 and dens > 40:
        flags['CV'] = [f'{dens:.0f}']
    if tr in ('T1', 'T2') and e.get('choices'):
        rl = [len(c.get('result_text', '')) for c in e['choices'] if c.get('result_text')]
        if rl and sum(rl) / len(rl) < 90 and len(base) < 400:
            flags['THIN'] = [f'avg{sum(rl)//len(rl)}']
    en = EN.get(eid)
    if en:
        et = strip_dialogue(' '.join([en.get('description', '')] + [c.get('result_text', '') for c in en.get('choices', [])]))
        past = len(re.findall(r'\b(was|were|had|did|said|looked|stood|sat|came|went|took|felt)\b', et))
        pres = len(re.findall(r'\b(is|are|has|does|says|looks|stands|sits|comes|goes|takes|feels)\b', et))
        if pres >= 4 and pres >= past * 0.5:
            flags['EN_PRESENT'] = [f'{pres}/{past}']
    if flags:
        rows.append({'id': eid, 'file': e['_file'], 'tier': tr, 'ch': chapter(eid),
                     'month': month.get(eid), 'flags': dict(flags)})




ROWS = {r['id']: r for r in rows}

LES = re.compile(r'(법이다|의미가 있다|배운 사람|성숙|교훈|알게 됐다|깨달았다|중요한 건|아니라[^.]{0,30}(이었다|였다|이다|됐다|뿐이다)|배신하지 않|완성된다|남는다\.?$|뜻이었다|수확이었다)')
def lesson(e):
    for c in e.get('choices', []):
        t = re.sub(r'"[^"]*"|“[^”]*”', '', c.get('result_text', '')).strip()
        ss = [s for s in re.split(r'(?<=[.!?…])\s+|\n+', t) if s.strip()]
        if any(LES.search(s) for s in ss[-3:]):
            return True
    return False

product = [k for k in KO if k not in AO]
def layer(eid):
    if eid.startswith('callback'):
        return 'C'
    t = tier(eid, KO[eid])
    if t == 'T1':
        return 'A'
    if eid.startswith('arc_') or eid in story_map_ids:
        return 'B'
    return 'E'

groups = collections.defaultdict(list)
for eid in product:
    groups[layer(eid)].append(eid)

def flagstr(eid):
    r = ROWS.get(eid)
    fl = list(r['flags'].keys()) if r else []
    if lesson(KO[eid]):
        fl.append('LESSON')
    fl = [f for f in fl if f != 'THIN' or layer(eid) == 'A']
    return '·'.join(fl)

def mkey(eid):
    m = month.get(eid)
    return (m if m is not None else 999, eid)

out = []
W = out.append
W('# 문장 개선 전체 목록 (2026-09-30 Claude 생성)')
W('')
W('> 기준서는 [`PROSE_REVISION_MASTER_PLAN.md`](PROSE_REVISION_MASTER_PLAN.md)다. 이 목록은 작업 범위와 순서만')
W('> 소유한다. 표시는 **후보 신호**이며 판정이 아니다. 표본 검증 정밀도는 약 50%이므로,')
W('> 각 장면을 읽고 기준서로 판정한다. 표시가 없는 장면도 배치 안에서 함께 읽는다.')
W('')
W(f'제품 사건 {len(product)}개(author_only 제외). 월 추정은 story_map·스케줄 코드·min_turn·')
W('follow-up 상속으로 붙였고, `?`는 추정 실패(무작위 풀·조건부 사건)다.')
W('')
W('| 신호 | 뜻 |')
W('|---|---|')
W('| P1 | 끝 문장이 추상 명사+상태 동사(해설·규칙 확인)로 닫힘 |')
W('| P2 | 선택 직전 산문이 선택지를 요약·예고 |')
W('| P4 | 조건 변형 본문이 원문보다 40% 넘게 짧음(원문 핵심 비트 손실 의심) |')
W('| CV | 계약어(실제로·확정·사실로·빈칸·기록·시각) 1만 자당 40회 초과 |')
W('| TENSE | KO 한 텍스트 안 현재형·과거형 서술 혼용 |')
W('| LESSON | 결과문 마지막 세 문장 안에 격언·교훈형 문장 |')
W('| THIN | (A층만) 결과문 평균 90자 미만 |')
W('| EN_PRESENT | EN 서술이 현재형 위주(과거형 기본 규칙 전환 대상) |')
W('')
names = {'A': 'A층 — 정점(T1 추정: 레지스트리·전용 CG)', 'B': 'B층 — 이야기 장면(arc·story_map)',
         'C': 'C층 — 여파 장면(callback)', 'E': 'E층 — 일반·무작위 사건'}
for g in 'ABCE':
    ids = groups[g]
    flagged = [i for i in ids if flagstr(i)]
    W(f'## {names[g]}')
    W('')
    W(f'전체 {len(ids)}개, 신호 {len(flagged)}개.')
    W('')
    if g == 'C':
        byfile = collections.defaultdict(list)
        for i in sorted(ids):
            byfile[KO[i]['_file']].append(i)
        W('C층은 탐지에 기대지 않고 **파일 단위로 전부** 읽는다. 표의 LESSON 수는 우선순위 참고용이다.')
        W('')
        W('| 배치 | 파일 | 사건 수 | LESSON 신호 | 신호 사건 |')
        W('|---|---|---:|---:|---|')
        fl = sorted(byfile.items(), key=lambda kv: -sum(1 for i in kv[1] if 'LESSON' in flagstr(i)))
        for n, (f, lst) in enumerate(fl, 1):
            sig = [i for i in lst if flagstr(i)]
            W(f'| C{n:02d} | `{f}` | {len(lst)} | {sum(1 for i in lst if "LESSON" in flagstr(i))} | '
              + ', '.join(f'`{i}`({flagstr(i)})' for i in sig[:40]) + (' …' if len(sig) > 40 else '') + ' |')
        W('')
        continue
    if g == 'E':
        W('E층은 신호 사건만 싣는다. 무작위 풀이라 노출 빈도가 높은 것부터 본다(가중치 내림차순).')
        W('')
        W('| 사건 | 파일 | 가중치 | 신호 |')
        W('|---|---|---:|---|')
        for i in sorted(flagged, key=lambda x: -(KO[x].get('weight') or 0)):
            W(f'| `{i}` | `{KO[i]["_file"]}` | {KO[i].get("weight")} | {flagstr(i)} |')
        W('')
        continue
    W('| 월 | 사건 | 파일 | 신호 |')
    W('|---:|---|---|---|')
    for i in sorted(ids, key=mkey):
        fs = flagstr(i)
        if g == 'B' and not fs:
            continue
        m = month.get(i)
        W(f'| {m if m is not None else "?"} | `{i}` | `{KO[i]["_file"]}` | {fs or "—"} |')
    W('')



if __name__ == '__main__':
    fc = collections.Counter(f for r in rows for f in r['flags'])
    print('PROSE_SIGNAL_REPORT product=%d flagged=%d' % (len(product), len(rows)))
    print('by_flag', dict(fc.most_common()))
    print('lesson', sum(1 for i in product if lesson(KO[i])))
    print('by_layer', {g: (len(groups[g]), sum(1 for i in groups[g] if flagstr(i))) for g in 'ABCE'})
    if '--write' in sys.argv:
        open(ROOT + '/docs/queue_backlog/PROSE_REVISION_INVENTORY.md', 'w').write('\n'.join(out) + '\n')
        print('wrote docs/queue_backlog/PROSE_REVISION_INVENTORY.md')
