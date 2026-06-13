#!/usr/bin/env python3
"""
event_graph.py — 강남드림 이벤트 흐름 시각화
실행: python3 tools/event_graph.py
결과: tools/event_graph.html (브라우저로 열기)

노드 = 이벤트, 엣지:
  파란 실선  — follow_up_event (이벤트 체인)
  초록 점선  — flag 조건 (flags 세팅 → 다음 이벤트 조건)
  빨간 점선  — no_flag 조건
"""
import json, glob, os, sys, html, re

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
EVENT_DIRS = [os.path.join(ROOT, "content/events")]

# ── 카테고리/접두어별 색상 ──────────────────────────
COLOR_MAP = {
    "story":        "#e8a000",   # 스토리 (프롤로그 등)
    "arc":          "#c678dd",   # 아크
    "arc_intro":    "#c678dd",
    "arc_father":   "#e06c75",
    "arc_daeun":    "#98c379",
    "arc_jiyeon":   "#e8a0c0",
    "arc_sangchul": "#d19a66",
    "arc_jaehyuk":  "#e06c75",
    "arc_temptation":"#be5046",
    "arc_spec":     "#56b6c2",
    "arc_rescue":   "#61afef",
    "cafe":         "#d4a76a",
    "callback":     "#5c6370",
    "chain":        "#528bff",
    "butterfly":    "#2bbac5",
    "drama":        "#c678dd",
    "hidden":       "#3e4451",
    "rare":         "#f0b429",
    "holdem":       "#e5c07b",
    "racetrack":    "#e5c07b",
    "investment":   "#98c379",
    "relationship": "#e8a0c0",
    "life":         "#61afef",
    "amb":          "#4b5263",
}

def node_color(eid: str, category: str) -> str:
    for prefix, color in COLOR_MAP.items():
        if eid.startswith(prefix) or category == prefix:
            return color
    return "#4b5263"

def short(eid: str, max_len=28) -> str:
    return eid if len(eid) <= max_len else eid[:max_len-1] + "…"

def load_events():
    events = {}
    for pattern in ["*.json"]:
        for path in sorted(glob.glob(os.path.join(ROOT, "content/events", pattern))):
            try:
                data = json.load(open(path, encoding="utf-8"))
                if not isinstance(data, list):
                    continue
                for ev in data:
                    eid = ev.get("id", "")
                    if eid:
                        ev["_file"] = os.path.basename(path)
                        events[eid] = ev
            except Exception as e:
                print(f"  warn: {path}: {e}", file=sys.stderr)
    return events

def build_graph(events):
    nodes = []
    edges = []
    edge_set = set()

    def add_edge(src, dst, color, label, dashes):
        key = (src, dst, label)
        if key in edge_set or src == dst:
            return
        edge_set.add(key)
        edges.append({"from": src, "to": dst,
                      "color": color, "label": label, "dashes": dashes})

    for eid, ev in events.items():
        cat = ev.get("category", "")
        color = node_color(eid, cat)
        title_kr = ev.get("title", eid)
        file_src = ev.get("_file", "")
        rarity = ev.get("rarity", "common")
        cond = ev.get("conditions", {})
        cond_str = ""
        if cond:
            parts = []
            for k, v in cond.items():
                parts.append(f"{k}={v}")
            cond_str = ", ".join(parts[:4])

        # 툴팁
        tooltip = (f"<b>{eid}</b><br>"
                   f"<i>{html.escape(title_kr)}</i><br>"
                   f"카테고리: {cat} | 희귀도: {rarity}<br>"
                   f"파일: {file_src}")
        if cond_str:
            tooltip += f"<br>조건: {cond_str}"

        border = "#ffd700" if rarity in ("legendary", "story") else color

        nodes.append({
            "id": eid,
            "label": short(eid),
            "title": tooltip,
            "color": {"background": color, "border": border,
                      "highlight": {"background": "#abb2bf", "border": "#ffd700"}},
            "font": {"color": "#abb2bf", "size": 11},
            "borderWidth": 2 if rarity in ("legendary", "story") else 1,
        })

        # follow_up_event 엣지 (선택지별)
        for choice in ev.get("choices", []):
            fu = choice.get("follow_up_event", "")
            if fu and fu in events:
                add_edge(eid, fu, "#61afef", "", False)

            # 이 선택이 세트하는 플래그가 조건인 이벤트 연결 (flag_set → flag_req)
            for flag in choice.get("flags", []):
                for tid, tev in events.items():
                    tcond = tev.get("conditions", {})
                    if tcond.get("flag") == flag or flag in tcond.get("flags", []):
                        add_edge(eid, tid, "#98c379", flag[:20], True)

        # 조건의 flag → 이것을 세트하는 이벤트 (역방향은 무겁고 중복 많아 skip)
        # no_flag 조건
        nf = cond.get("no_flag", "")
        if nf:
            for sid, sev in events.items():
                for sch in sev.get("choices", []):
                    if nf in sch.get("flags", []):
                        add_edge(sid, eid, "#e06c75", f"!{nf[:18]}", True)
                        break

    return nodes, edges

def render_html(nodes, edges, out_path):
    nodes_json = json.dumps(nodes, ensure_ascii=False)
    edges_json = json.dumps(edges, ensure_ascii=False)
    n_nodes = len(nodes)
    n_edges = len(edges)

    html_content = f"""<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<title>강남드림 — 이벤트 흐름도</title>
<script src="https://unpkg.com/vis-network@9.1.9/dist/vis-network.min.js"></script>
<link href="https://unpkg.com/vis-network@9.1.9/dist/vis-network.min.css" rel="stylesheet"/>
<style>
* {{ box-sizing: border-box; margin: 0; padding: 0; }}
body {{ background: #1e2127; color: #abb2bf; font-family: 'Segoe UI', sans-serif; height: 100vh; display: flex; flex-direction: column; }}
#toolbar {{ padding: 8px 12px; background: #21252b; border-bottom: 1px solid #3e4451; display: flex; gap: 8px; align-items: center; flex-wrap: wrap; }}
#toolbar h1 {{ font-size: 14px; color: #e5c07b; margin-right: 8px; }}
input[type=text] {{ background: #282c34; border: 1px solid #3e4451; color: #abb2bf; padding: 4px 8px; border-radius: 4px; width: 220px; font-size: 12px; }}
button {{ background: #2c313a; border: 1px solid #3e4451; color: #abb2bf; padding: 4px 10px; border-radius: 4px; cursor: pointer; font-size: 12px; }}
button:hover {{ background: #3e4451; }}
.tag {{ font-size: 11px; color: #5c6370; }}
#network {{ flex: 1; }}
#info {{ position: fixed; bottom: 12px; right: 12px; background: #282c34; border: 1px solid #3e4451; border-radius: 6px; padding: 10px 14px; max-width: 340px; font-size: 12px; display: none; z-index: 10; }}
#info h3 {{ color: #e5c07b; margin-bottom: 4px; }}
</style>
</head>
<body>
<div id="toolbar">
  <h1>🗺 강남드림 이벤트 흐름도</h1>
  <input type="text" id="search" placeholder="이벤트 ID 검색…" oninput="doSearch(this.value)"/>
  <button onclick="resetView()">전체 보기</button>
  <button onclick="filterArcs()">아크만</button>
  <button onclick="filterStory()">스토리만</button>
  <button onclick="filterAll()">전체</button>
  <span class="tag">{n_nodes}개 노드 · {n_edges}개 엣지</span>
  <span class="tag">— 파란 실선: follow_up | 초록 점선: flag 세팅→조건 | 빨간 점선: no_flag</span>
</div>
<div id="network"></div>
<div id="info"><h3 id="info-id"></h3><div id="info-body"></div></div>
<script>
const ALL_NODES = {nodes_json};
const ALL_EDGES = {edges_json};

var nodesDS = new vis.DataSet(ALL_NODES);
var edgesDS = new vis.DataSet(ALL_EDGES);

var network = new vis.Network(
  document.getElementById('network'),
  {{ nodes: nodesDS, edges: edgesDS }},
  {{
    physics: {{ solver: 'forceAtlas2Based', forceAtlas2Based: {{ gravitationalConstant: -40, springLength: 120 }}, stabilization: {{ iterations: 300 }} }},
    edges: {{ arrows: {{ to: {{ enabled: true, scaleFactor: 0.6 }} }}, smooth: {{ type: 'continuous' }}, width: 1.2 }},
    nodes: {{ shape: 'box', margin: 6, widthConstraint: {{ maximum: 160 }} }},
    interaction: {{ hover: true, tooltipDelay: 200, navigationButtons: true, keyboard: true }},
  }}
);

network.on('click', function(params) {{
  if (params.nodes.length > 0) {{
    var nid = params.nodes[0];
    var node = nodesDS.get(nid);
    document.getElementById('info-id').textContent = nid;
    document.getElementById('info-body').innerHTML = node.title || '';
    document.getElementById('info').style.display = 'block';
    // 연결된 노드 하이라이트
    var connected = network.getConnectedNodes(nid);
    network.selectNodes([nid].concat(connected));
  }} else {{
    document.getElementById('info').style.display = 'none';
    network.unselectAll();
  }}
}});

function doSearch(val) {{
  if (!val) {{ resetView(); return; }}
  val = val.toLowerCase();
  var matching = ALL_NODES.filter(n => n.id.toLowerCase().includes(val));
  nodesDS.clear(); edgesDS.clear();
  var ids = new Set(matching.map(n => n.id));
  var edges = ALL_EDGES.filter(e => ids.has(e.from) && ids.has(e.to));
  nodesDS.add(matching); edgesDS.add(edges);
}}

function filterArcs() {{
  var matching = ALL_NODES.filter(n => n.id.startsWith('arc_') || n.id.startsWith('story_') || n.id.startsWith('cafe_'));
  apply(matching);
}}

function filterStory() {{
  var matching = ALL_NODES.filter(n => n.id.startsWith('story_'));
  apply(matching);
}}

function filterAll() {{ resetView(); }}

function apply(matching) {{
  nodesDS.clear(); edgesDS.clear();
  var ids = new Set(matching.map(n => n.id));
  var edges = ALL_EDGES.filter(e => ids.has(e.from) && ids.has(e.to));
  nodesDS.add(matching); edgesDS.add(edges);
}}

function resetView() {{
  nodesDS.clear(); edgesDS.clear();
  nodesDS.add(ALL_NODES); edgesDS.add(ALL_EDGES);
  network.fit();
}}
</script>
</body>
</html>"""
    with open(out_path, "w", encoding="utf-8") as f:
        f.write(html_content)
    print(f"✅ {out_path} ({n_nodes} 노드, {n_edges} 엣지)")

if __name__ == "__main__":
    print("이벤트 로딩 중...")
    events = load_events()
    print(f"  총 {len(events)}개 이벤트")
    print("그래프 생성 중...")
    nodes, edges = build_graph(events)
    out = os.path.join(ROOT, "tools", "event_graph.html")
    render_html(nodes, edges, out)
    print(f"브라우저로 열기: open {out}")
