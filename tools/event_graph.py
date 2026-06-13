#!/usr/bin/env python3
"""
event_graph.py — 강남드림 이벤트 흐름도 (CDN 불필요, file:// 로컬 열기 가능)
실행: python3 tools/event_graph.py
결과: tools/event_graph.html
"""
import json, glob, os, sys, html as html_mod

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

# 아크 이벤트 순서 (MainGame._next_arc_id 기준 — 직접 관리하는 주요 분기점)
ARC_SEQUENCE = [
    ("story_arrival",          "프롤로그 1: 눈을 뜬다",          "prologue",   None),
    ("story_prologue_dad",     "프롤로그 2: 아버지 전화",         "prologue",   None),
    ("story_prologue_goal",    "프롤로그 3: 강남",                "prologue",   None),
    ("story_prologue_meal",    "프롤로그 4: 첫 끼니",             "prologue",   None),
    ("story_pressure",         "프롤로그 5: 더는 못 미룬다",      "prologue",   None),
    ("arc_intro_01_meal",      "인트로: 첫 끼니",                 "intro",      "t≥2"),
    ("arc_intro_02_dad_call",  "인트로: 아버지 전화 2",           "intro",      "t≥3"),
    ("arc_temptation_01",      "★ 첫 유혹 — 정석 vs 지름길",     "temptation", "t≥4"),
    ("arc_intro_03_sns",       "인트로: SNS",                     "intro",      "t≥5"),
    ("cafe_00",                "★ 카페 분기 시나리오",            "cafe",       "t≥6"),
    ("arc_intro_04_hyunsu",    "인트로: 현수",                    "intro",      "t≥7"),
    ("arc_temptation_fallout", "유혹 후폭풍 (lent_account)",      "temptation", "t≥8"),
    ("arc_temptation_clean",   "유혹 보상 (kept_clean_hands)",    "temptation", "t≥8"),
    ("arc_rescue_job",         "안전망: 무직 구조",               "rescue",     "t≥5 무직"),
    ("arc_spec_career",        "전문화: 커리어",                  "spec",       "pending_spec_career"),
    ("arc_spec_invest",        "전문화: 투자",                    "spec",       "pending_spec_invest"),
    ("arc_spec_found",         "전문화: 창업",                    "spec",       "pending_spec_found"),
    ("arc_daeun_01_meet",      "다은 1: 첫 만남",                 "daeun",      "t≥9"),
    ("arc_sangchul_01_meet",   "상철 1: 첫 만남",                 "sangchul",   "t≥10"),
    ("arc_daeun_02_regular",      "다은 2: 단골",                      "daeun",   "t≥15, 호감도≥8"),
    ("arc_jiyeon_01_crash",       "지연 1: 접촉",                      "jiyeon",  "t≥17"),
    ("arc_jiyeon_02_store",       "지연 2: 또, 너",                    "jiyeon",  "t≥20, crash_seen"),
    ("arc_jiyeon_03_offer",       "지연 3: 갚고 싶어요",               "jiyeon",  "t≥23, store_seen"),
    ("arc_jiyeon_03b_lunch",      "지연 3b: 그녀의 세계",              "jiyeon",  "t≥27, offer_seen"),
    ("cafe_cb_stole_00",          "카페 콜백: 절도",                   "cafe",    "t≥13, cafe_stole_lead"),
    ("cafe_cb_honest_00",         "카페 콜백: 정직",                   "cafe",    "t≥13, cafe_got_card_honest"),
    ("cafe_cb_humiliated_00",     "카페 콜백: 수치",                   "cafe",    "t≥13, cafe_humiliated"),
    ("arc_daeun_03_fork",         "다은 3: 분기",                      "daeun",   "t≥23, 호감도≥12"),
    ("arc_father_01_call",        "아버지 1: 전화",                    "father",  "t≥20"),
    ("arc_father_02_signal",      "아버지 2: 신호",                    "father",  "t≥25"),
    ("arc_father_03_hospital",    "아버지 3: 병원",                    "father",  "t≥32"),
    ("arc_father_04_visit",       "아버지 4: 방문",                    "father",  "t≥35"),
    ("arc_father_05_after_visit", "아버지 5: 방문 이후",               "father",  "father_hospital_seen"),
    ("arc_jaehyuk_01_reunion",    "재혁 1: 10년 만에",                 "jaehyuk", "t≥27"),
    ("arc_jaehyuk_01b_real_face", "재혁 1b: 야, 사실 나도...",         "jaehyuk", "t≥29, reunion_seen"),
    ("arc_jaehyuk_02_bond",       "재혁 2: 형 동생",                   "jaehyuk", "t≥32, reunion_seen"),
    ("arc_jaehyuk_02b_favor",     "재혁 2b: 조건 없는 도움",           "jaehyuk", "t≥34, bond_seen"),
    ("arc_jaehyuk_03_pitch",      "재혁 3: 마지막 기회",               "jaehyuk", "t≥37, bond_seen"),
    ("arc_jaehyuk_hyunsu_warning","재혁↔현수: 너무 늦은 연락",         "jaehyuk", "t≥39, pitch_seen"),
    ("arc_jaehyuk_04a_ghost",     "재혁 4a: 연락 두절",                "jaehyuk", "t≥42, invested"),
    ("arc_jaehyuk_04b_counter",   "재혁 4b: 역으로",                   "jaehyuk", "t≥42, suspected"),
    ("arc_jaehyuk_04c_stand_up",  "재혁 4c: 0에서 다시",               "jaehyuk", "t≥44, ghost+scammed"),
    ("arc_sangchul_jiyeon_reveal","지연↔상철: 두 세계",                "jiyeon",  "t≥35, offer_seen"),
    ("arc_opp_jiyeon_bunyang",    "지연 기회: 분양권",                 "jiyeon",  "affinity≥25"),
    ("arc_opp_jiyeon_win",        "지연 기회 결과: 프리미엄",          "jiyeon",  "jiyeon_deal_won"),
    ("arc_opp_jiyeon_lose",       "지연 기회 결과: 취소",              "jiyeon",  "jiyeon_deal_lost"),
    ("arc_jiyeon_truth_moment",   "지연 진실: 그때 말 못 한 것들",     "jiyeon",  "t≥44, reveal_seen"),
    ("arc_jiyeon_truth_warned",   "지연 진실(경고): 미리 알았던 것들", "jiyeon",  "t≥44, warned"),
    ("arc_jiyeon_05_epilogue",    "지연 에필로그",                     "jiyeon",  "t≥50, truth_seen"),
    ("arc_jaehyuk_aftermath",     "재혁 에필로그",                     "jaehyuk", "t≥50"),
    ("story_six_months",       "마일스톤: 6개월",                 "milestone",  "t=6"),
    ("story_one_year",         "마일스톤: 1년",                   "milestone",  "t=12"),
    ("story_one_half_year",    "마일스톤: 18개월",                "milestone",  "t=18"),
    ("story_two_year",         "마일스톤: 2년",                   "milestone",  "t=24"),
    ("age_35_checkpoint",      "마일스톤: 35세",                  "milestone",  "t=30"),
    ("story_three_year",       "마일스톤: 3년",                   "milestone",  "t=36"),
    ("story_four_year",        "마일스톤: 4년",                   "milestone",  "t=48"),
    ("age_39_final",           "마일스톤: 최후",                  "milestone",  "t=54"),
]

ARC_COLOR = {
    "prologue":    ("#e8a000", "#1a1200"),
    "intro":       ("#c678dd", "#1a0a1a"),
    "temptation":  ("#e06c75", "#1a0a0a"),
    "cafe":        ("#d4a76a", "#1a1008"),
    "daeun":       ("#98c379", "#0a1a0a"),
    "jiyeon":      ("#e8a0c0", "#1a0a12"),
    "father":      ("#e06c75", "#1a0808"),
    "jaehyuk":     ("#d19a66", "#1a1008"),
    "sangchul":    ("#56b6c2", "#081214"),
    "spec":        ("#61afef", "#080f1a"),
    "rescue":      ("#61afef", "#080f1a"),
    "milestone":   ("#f0b429", "#1a1400"),
}

def load_events():
    events = {}
    for path in sorted(glob.glob(os.path.join(ROOT, "content/events", "*.json"))):
        try:
            data = json.load(open(path, encoding="utf-8"))
            if isinstance(data, list):
                for ev in data:
                    eid = ev.get("id", "")
                    if eid:
                        ev["_file"] = os.path.basename(path)
                        events[eid] = ev
        except Exception as e:
            print(f"  warn: {path}: {e}", file=sys.stderr)
    return events

def follow_chain(eid, events, visited=None):
    """follow_up_event 체인을 재귀로 수집."""
    if visited is None:
        visited = set()
    if eid in visited or eid not in events:
        return []
    visited.add(eid)
    ev = events[eid]
    result = [ev]
    for choice in ev.get("choices", []):
        fu = choice.get("follow_up_event", "")
        if fu and fu not in visited:
            result.extend(follow_chain(fu, events, visited))
    return result

def render_event_card(ev, events, depth=0):
    eid = ev.get("id", "")
    title = ev.get("title", eid)
    desc = (ev.get("description", "") or "")[:120].replace("\n", " ")
    choices = ev.get("choices", [])
    bg = ev.get("background", "")
    portrait = ev.get("portrait", "")
    indent = depth * 32

    lines = []
    lines.append(f'<div class="event-card" style="margin-left:{indent}px">')
    lines.append(f'  <div class="event-id">{html_mod.escape(eid)}</div>')
    lines.append(f'  <div class="event-title">{html_mod.escape(title)}</div>')
    if desc:
        lines.append(f'  <div class="event-desc">{html_mod.escape(desc)}…</div>')
    meta = []
    if bg: meta.append(f"배경: {bg}")
    if portrait: meta.append(f"인물: {portrait}")
    if meta:
        lines.append(f'  <div class="event-meta">{" | ".join(meta)}</div>')

    for i, ch in enumerate(choices):
        ch_text = ch.get("text", "")
        ch_flags = ch.get("flags", [])
        ch_fu = ch.get("follow_up_event", "")
        ch_effects = ch.get("effects", {})

        eff_parts = []
        for k, v in ch_effects.items():
            sign = "+" if v > 0 else ""
            eff_parts.append(f"{k}: {sign}{v}")

        lines.append(f'  <div class="choice">')
        lines.append(f'    <span class="choice-num">선택 {i+1}</span> {html_mod.escape(ch_text)}')
        if eff_parts:
            lines.append(f'    <span class="effects">[{", ".join(eff_parts[:4])}]</span>')
        if ch_flags:
            lines.append(f'    <span class="flags">🚩 {", ".join(ch_flags)}</span>')
        if ch_fu:
            lines.append(f'    <span class="follow-up">→ {html_mod.escape(ch_fu)}</span>')
        lines.append(f'  </div>')

    lines.append('</div>')
    return "\n".join(lines)

def render_arc_section(arc_id, arc_label, arc_type, condition, events):
    color, bg = ARC_COLOR.get(arc_type, ("#abb2bf", "#1e2127"))
    chain = follow_chain(arc_id, events)

    lines = []
    cond_html = f'<span class="condition">조건: {html_mod.escape(condition)}</span>' if condition else ""
    lines.append(f'<div class="arc-section" id="arc-{html_mod.escape(arc_id)}" style="border-color:{color};background:{bg}">')
    lines.append(f'  <div class="arc-header" style="color:{color}" onclick="toggle(this)">')
    lines.append(f'    <span class="arc-type">[{arc_type}]</span> {html_mod.escape(arc_label)} {cond_html}')
    lines.append(f'    <span class="arc-count">{len(chain)}단계</span>')
    lines.append(f'  </div>')
    lines.append(f'  <div class="arc-body">')
    for i, ev in enumerate(chain):
        lines.append(render_event_card(ev, events, depth=i))
    if not chain:
        lines.append(f'    <div class="missing">⚠ 이벤트 없음 (JSON에 미정의)</div>')
    lines.append(f'  </div>')
    lines.append('</div>')
    return "\n".join(lines)

CSS = """
* { box-sizing: border-box; margin: 0; padding: 0; }
body { background: #1e2127; color: #abb2bf; font-family: 'Segoe UI', 'Noto Sans KR', sans-serif; }
#toolbar { position: sticky; top: 0; z-index: 100; padding: 8px 16px; background: #21252b;
           border-bottom: 2px solid #3e4451; display: flex; gap: 8px; align-items: center; flex-wrap: wrap; }
#toolbar h1 { font-size: 14px; color: #e5c07b; }
input[type=text] { background: #282c34; border: 1px solid #3e4451; color: #abb2bf;
                   padding: 5px 10px; border-radius: 4px; width: 260px; font-size: 12px; }
.btn { background: #2c313a; border: 1px solid #3e4451; color: #abb2bf;
       padding: 4px 10px; border-radius: 4px; cursor: pointer; font-size: 12px; }
.btn:hover { background: #3e4451; }
#content { padding: 16px; max-width: 1100px; margin: 0 auto; }
.arc-section { border-left: 4px solid; border-radius: 6px; margin-bottom: 10px;
               padding: 0; overflow: hidden; }
.arc-header { padding: 10px 14px; cursor: pointer; display: flex; align-items: center;
              gap: 8px; font-size: 13px; font-weight: 600; user-select: none; }
.arc-header:hover { filter: brightness(1.15); }
.arc-type { font-size: 10px; opacity: 0.7; background: rgba(255,255,255,0.08);
            padding: 1px 6px; border-radius: 3px; }
.arc-count { margin-left: auto; font-size: 11px; opacity: 0.6; }
.condition { font-size: 10px; opacity: 0.7; background: rgba(255,255,255,0.06);
             padding: 1px 8px; border-radius: 10px; font-weight: 400; }
.arc-body { padding: 10px 12px; display: none; }
.arc-body.open { display: block; }
.event-card { background: rgba(255,255,255,0.04); border-radius: 5px;
              padding: 8px 12px; margin-bottom: 8px; border-left: 2px solid rgba(255,255,255,0.1); }
.event-id { font-size: 10px; color: #5c6370; font-family: monospace; }
.event-title { font-size: 13px; font-weight: 600; color: #e5c07b; margin: 2px 0; }
.event-desc { font-size: 11px; color: #7a8a9a; margin-bottom: 4px; }
.event-meta { font-size: 10px; color: #4b5263; margin-bottom: 4px; }
.choice { font-size: 11px; padding: 3px 0 3px 10px; border-left: 2px solid #3e4451;
          margin: 3px 0; display: flex; flex-wrap: wrap; align-items: baseline; gap: 6px; }
.choice-num { background: #3e4451; color: #abb2bf; padding: 0 5px; border-radius: 3px;
              font-size: 10px; flex-shrink: 0; }
.effects { color: #98c379; font-size: 10px; font-family: monospace; }
.flags { color: #e5c07b; font-size: 10px; }
.follow-up { color: #61afef; font-size: 10px; font-family: monospace; }
.missing { color: #5c6370; font-style: italic; padding: 8px; }
.section-title { font-size: 11px; color: #3e4451; padding: 6px 0 2px; font-weight: 600;
                 letter-spacing: 1px; text-transform: uppercase; }
"""

JS = """
function toggle(header) {
  var body = header.nextElementSibling;
  body.classList.toggle('open');
}
function expandAll() {
  document.querySelectorAll('.arc-body').forEach(b => b.classList.add('open'));
}
function collapseAll() {
  document.querySelectorAll('.arc-body').forEach(b => b.classList.remove('open'));
}
function filterType(type) {
  document.querySelectorAll('.arc-section').forEach(sec => {
    if (!type) { sec.style.display = ''; return; }
    var h = sec.querySelector('.arc-type');
    sec.style.display = (h && h.textContent.includes(type)) ? '' : 'none';
  });
}
function doSearch() {
  var val = document.getElementById('search').value.trim().toLowerCase();
  document.querySelectorAll('.arc-section').forEach(sec => {
    if (!val) { sec.style.display = ''; return; }
    sec.style.display = sec.textContent.toLowerCase().includes(val) ? '' : 'none';
  });
}
"""

def generate(events, out_path):
    type_buttons = ""
    seen_types = list(dict.fromkeys(a[2] for a in ARC_SEQUENCE))
    for t in seen_types:
        c, _ = ARC_COLOR.get(t, ("#abb2bf", ""))
        type_buttons += f'<button class="btn" style="border-color:{c};color:{c}" onclick="filterType(\'{t}\')">{t}</button>'

    sections_html = []
    prev_type = None
    for arc_id, arc_label, arc_type, condition in ARC_SEQUENCE:
        if arc_type != prev_type:
            sections_html.append(f'<div class="section-title">{arc_type}</div>')
            prev_type = arc_type
        sections_html.append(render_arc_section(arc_id, arc_label, arc_type, condition, events))

    page = f"""<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<title>강남드림 — 이벤트 흐름도</title>
<style>{CSS}</style>
</head>
<body>
<div id="toolbar">
  <h1>🗺 강남드림 이벤트 흐름도</h1>
  <input type="text" id="search" placeholder="ID / 텍스트 검색…" oninput="doSearch()"/>
  <button class="btn" onclick="expandAll()">전체 펼치기</button>
  <button class="btn" onclick="collapseAll()">전체 접기</button>
  <button class="btn" onclick="filterType('')">전체 보기</button>
  {type_buttons}
</div>
<div id="content">
{"".join(sections_html)}
</div>
<script>{JS}</script>
</body>
</html>"""

    with open(out_path, "w", encoding="utf-8") as f:
        f.write(page)
    print(f"✅ {out_path}  ({len(ARC_SEQUENCE)}개 아크, 이벤트 {len(events)}개 로드됨)")

if __name__ == "__main__":
    print("이벤트 로딩 중...")
    events = load_events()
    print(f"  총 {len(events)}개")
    out = os.path.join(ROOT, "tools", "event_graph.html")
    generate(events, out)
    print(f"브라우저로 열기: open \"{out}\"")
