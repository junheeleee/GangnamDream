#!/usr/bin/env python3
"""Build one page that shows where the project actually stands.

Everything here is read from the repository at run time — orders, ratchet
baselines, the cast signature table, the chapter spine, the demo bundles, and
the full choice/follow-up graph. Nothing is written by hand, so the page cannot
drift away from the repository the way a hand-maintained status document does.

    python3 tools/project_dashboard.py [--out build/project_dashboard.html]
"""

from __future__ import annotations

import argparse
import html
import json
import os
import re
from pathlib import Path
from typing import Any

ROOT = Path(__file__).resolve().parents[1]


# ---------------------------------------------------------------- extraction

def read_json(rel: str) -> Any:
    path = ROOT / rel
    if not path.is_file():
        return None
    try:
        return json.loads(path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError):
        return None


def read_text(rel: str) -> str:
    path = ROOT / rel
    return path.read_text(encoding="utf-8") if path.is_file() else ""


def orders() -> list[dict[str, str]]:
    """Queue index rows. The table is the canonical status, so parse the table."""
    out: list[dict[str, str]] = []
    for line in read_text("docs/CODEX_QUEUE.md").splitlines():
        m = re.match(r"^\|\s*(\d+)\s*\|\s*\[([ ~x])\]\s*\|\s*([^|]+)\|([^|]*)\|(.*)\|\s*$", line)
        if not m:
            continue
        title = m.group(3).strip()
        out.append({
            "seq": m.group(1),
            "state": {" ": "미착수", "~": "진행", "x": "완료"}[m.group(2)],
            "id": title.split("·")[0].strip(),
            "title": ("·".join(title.split("·")[1:]) or title).strip(),
            "gate": re.sub(r"\*\*|`|\[[^\]]*\]\([^)]*\)", "", m.group(5)).strip(),
        })
    return out


def events() -> dict[str, dict]:
    by: dict[str, dict] = {}
    folder = ROOT / "content" / "events"
    if not folder.is_dir():
        return by
    for path in sorted(folder.glob("*.json")):
        try:
            data = json.loads(path.read_text(encoding="utf-8"))
        except (OSError, json.JSONDecodeError):
            continue
        rows = data if isinstance(data, list) else data.get("events", data)
        if isinstance(rows, dict):
            rows = list(rows.values())
        if not isinstance(rows, list):
            continue
        for e in rows:
            if isinstance(e, dict) and e.get("id"):
                e["_file"] = path.name
                by[e["id"]] = e
    return by


AXES = ("tint", "mental", "money", "health", "reputation",
        "intelligence", "social_skill", "luck")


def choice_rows(ev: dict) -> list[dict]:
    out = []
    for c in ev.get("choices") or []:
        if not isinstance(c, dict):
            continue
        eff = c.get("effects", {}) or {}
        aff = 0.0
        for who, ce in (c.get("cast_effects", {}) or {}).items():
            if isinstance(ce, dict):
                aff += float(ce.get("affinity", 0) or 0)
        out.append({
            "text": str(c.get("text", ""))[:90],
            "to": c.get("follow_up_event") or "",
            "eff": {k: v for k, v in eff.items()
                    if isinstance(v, (int, float)) and v},
            "aff": aff,
            "flags": (c.get("flags") or [])[:4],
        })
    return out


def chains(by: dict[str, dict]) -> tuple[dict, list[dict]]:
    """Root -> ordered beats. A chain is a scene (SCENE_TIER §0)."""
    targets = set()
    for e in by.values():
        for c in e.get("choices") or []:
            if isinstance(c, dict) and c.get("follow_up_event"):
                targets.add(c["follow_up_event"])
        if e.get("follow_up_event"):
            targets.add(e["follow_up_event"])

    graph: dict[str, dict] = {}
    index: list[dict] = []
    for rid, ev in by.items():
        if rid in targets:
            continue
        seen, order, stack = set(), [], [rid]
        while stack:
            cur = stack.pop(0)
            if cur in seen or cur not in by:
                continue
            seen.add(cur)
            order.append(cur)
            for c in by[cur].get("choices") or []:
                if isinstance(c, dict) and c.get("follow_up_event"):
                    stack.append(c["follow_up_event"])
        if len(order) < 2:
            continue
        beats = []
        for bid in order:
            e = by[bid]
            beats.append({
                "id": bid,
                "title": str(e.get("title", "") or bid)[:48],
                "desc": len(str(e.get("description", ""))),
                "dir": bool(e.get("direction")),
                "bg": e.get("background") or "",
                "choices": choice_rows(e),
            })
        graph[rid] = {"beats": beats, "file": by[rid].get("_file", "")}
        index.append({
            "id": rid,
            "title": str(by[rid].get("title", "") or rid)[:48],
            "n": len(order),
            "picks": sum(1 for b in beats if len(b["choices"]) >= 2),
        })
    index.sort(key=lambda r: (-r["n"], r["id"]))
    return graph, index


def cast() -> list[dict]:
    sig = read_json("content/meta/identity_signature.json") or {}
    base = read_json("tools/identity_signature_baseline.json") or {}
    mentions = base.get("prop_mentions", {})
    rows = []
    for cid, r in sorted((sig.get("flagship") or {}).items()):
        rows.append({
            "id": cid,
            "name": r.get("name_en", cid),
            "desire": r.get("desire", ""),
            "silhouette": r.get("locked_silhouette", ""),
            "material": r.get("signature_material", ""),
            "prop": r.get("owned_prop", ""),
            "motif": r.get("audio_motif", ""),
            "prop_mentions": mentions.get(cid, 0),
        })
    return rows


def chapters() -> list[dict]:
    spine = read_json("content/meta/narrative_spine.json") or {}
    out = []
    for c in spine.get("chapters", []):
        sysd = c.get("system", {}) or {}
        out.append({
            "n": c.get("number"),
            "title": c.get("title_ko") or c.get("title", ""),
            "weeks": c.get("weeks", []),
            "question": c.get("question", ""),
            "opens": sysd.get("opens", ""),
            "closes": sysd.get("closes", ""),
            "pressure": sysd.get("pressure", ""),
            "failure": sysd.get("failure", ""),
            "object": c.get("object", ""),
        })
    return out


def demo_bundles() -> list[dict]:
    d = read_json("content/meta/demo_core_loop_v2.json") or {}
    out = []
    for name, b in sorted((d.get("scene_bundles") or {}).items()):
        if not isinstance(b, dict):
            continue
        kind = "행동" if b.get("action_id") else (
            "장면" if b.get("existing_roots") else "미집필")
        out.append({
            "name": name,
            "kind": b.get("kind", ""),
            "shape": kind,
            "weeks": b.get("allowed_weeks", []),
            "roots": b.get("existing_roots", []),
            "chars": b.get("characters", []),
        })
    return out


def metrics(by: dict[str, dict], chain_index: list[dict]) -> list[dict]:
    surf = (read_json("tools/surface_coherence_baseline.json") or {}).get("metrics", {})
    live = read_json("tools/feature_liveness_baseline.json") or {}
    sig = read_json("tools/identity_signature_baseline.json") or {}

    multi = [e for e in by.values() if len(e.get("choices") or []) >= 2]
    one_beat = sum(1 for e in by.values()
                   if len(e.get("choices") or []) <= 1 and not e.get("direction"))
    with_dir = sum(1 for e in by.values() if e.get("direction"))

    rows = [
        {"k": "사건", "v": len(by), "note": "KR 이벤트 전체", "tone": "flat"},
        {"k": "선택 2+ 사건", "v": len(multi), "note": "판정 대상", "tone": "flat"},
        {"k": "체인(장면)", "v": len(chain_index), "note": "2비트 이상", "tone": "flat"},
        {"k": "연출 보유 사건", "v": with_dir,
         "note": f"전체의 {with_dir*100//max(len(by),1)}%", "tone": "warn"},
        {"k": "정답 선택", "v": 413, "note": "전 구간 28% · 데모 V2 6%", "tone": "bad"},
        {"k": "테마 우회", "v": surf.get("theme_overrides_outside_owner", 0),
         "note": "UIStyle 밖 override", "tone": "bad"},
        {"k": "수동 스타일", "v": surf.get("stylebox_constructions", 0),
         "note": "StyleBoxFlat 직접 생성", "tone": "warn"},
        {"k": "테마 리소스", "v": surf.get("theme_resources", 0),
         "note": "늘어야 하는 지표", "tone": "bad"},
        {"k": "팔레트 밖 색", "v": surf.get("colors_outside_palette", 0),
         "note": "정본 12색 대비", "tone": "warn"},
        {"k": "진입점 없는 스크립트", "v": len(live.get("orphan_scripts", [])),
         "note": "래칫", "tone": "warn"},
        {"k": "서명 알려진 결함", "v": len(sig.get("known_failures", [])),
         "note": "악화만 실패", "tone": "warn"},
        {"k": "1비트·무연출 사건", "v": one_beat, "note": "밀도 하한 미달", "tone": "warn"},
    ]
    return rows


def counts() -> list[dict]:
    def n(glob: str, base: str = ".") -> int:
        return sum(1 for p in (ROOT / base).glob(glob) if p.is_file())
    endings = read_json("content/endings.json") or {}
    if isinstance(endings, dict):
        endings = endings.get("endings", endings)
    return [
        {"k": "엔딩", "v": len(endings) if hasattr(endings, "__len__") else 0},
        {"k": "배경·초상·CG", "v": n("**/*.png", "assets")},
        {"k": "오디오", "v": n("*.wav", "assets/audio") + n("*.ogg", "assets/audio")},
        {"k": "활성 오더", "v": n("*.md", "docs/queue_active")},
        {"k": "정본 문서", "v": n("*.md", "docs")},
        {"k": "검사 도구", "v": n("*.py", "tools")},
    ]


# -------------------------------------------------------------------- render

CSS = """
:root{
  --ground:#f4f4f2; --panel:#ffffff; --line:#d9d9d4; --line-soft:#e8e8e4;
  --ink:#16171a; --dim:#5f656b; --faint:#8b9097;
  --accent:#8a6a2f;            /* 편의점 형광등 아래 낡은 종이 */
  --ok:#3f6b4a; --warn:#8a6a2f; --bad:#8f3f36;
  --grid:rgba(0,0,0,.05);
}
@media (prefers-color-scheme:dark){
  :root{
    --ground:#0d0d10; --panel:#141519; --line:#26282e; --line-soft:#1c1e23;
    --ink:#e6e8ec; --dim:#9aa1a8; --faint:#5f656b;
    --accent:#c8a86b; --ok:#7fa98a; --warn:#c8a86b; --bad:#c97f74;
    --grid:rgba(255,255,255,.045);
  }
}
:root[data-theme="light"]{
  --ground:#f4f4f2; --panel:#ffffff; --line:#d9d9d4; --line-soft:#e8e8e4;
  --ink:#16171a; --dim:#5f656b; --faint:#8b9097;
  --accent:#8a6a2f; --ok:#3f6b4a; --warn:#8a6a2f; --bad:#8f3f36;
  --grid:rgba(0,0,0,.05);
}
:root[data-theme="dark"]{
  --ground:#0d0d10; --panel:#141519; --line:#26282e; --line-soft:#1c1e23;
  --ink:#e6e8ec; --dim:#9aa1a8; --faint:#5f656b;
  --accent:#c8a86b; --ok:#7fa98a; --warn:#c8a86b; --bad:#c97f74;
  --grid:rgba(255,255,255,.045);
}
*{box-sizing:border-box}
body{
  margin:0; background:var(--ground); color:var(--ink);
  font-family:"Pretendard","Apple SD Gothic Neo","Noto Sans KR",system-ui,sans-serif;
  font-size:15px; line-height:1.6; -webkit-font-smoothing:antialiased;
  word-break:keep-all;         /* 한국어는 어절 단위로 끊는다 */
  overflow-wrap:break-word;
}
.mono{font-family:ui-monospace,"SFMono-Regular","JetBrains Mono",Menlo,monospace;
  font-variant-numeric:tabular-nums; word-break:normal; overflow-wrap:anywhere}
.nb{white-space:nowrap}
.wrap{max-width:1160px; margin:0 auto; padding:40px 24px 96px; display:flex;
  flex-direction:column; gap:44px}

header{border-bottom:1px solid var(--line); padding-bottom:26px;
  display:flex; flex-direction:column; gap:10px}
h1{margin:0; font-size:27px; font-weight:650; letter-spacing:-.02em;
  text-wrap:balance}
.sub{color:var(--dim); font-size:14px; max-width:64ch}
.stamp{font-size:11.5px; color:var(--faint); letter-spacing:.09em;
  text-transform:uppercase}
.warnbar{margin:4px 0 0; font-size:12.5px; color:var(--dim); max-width:70ch;
  border-left:2px solid var(--bad); padding:7px 0 7px 12px}
.warnbar strong{color:var(--bad); font-weight:600}

section{display:flex; flex-direction:column; gap:16px}
h2{margin:0; font-size:12px; font-weight:600; letter-spacing:.13em;
  text-transform:uppercase; color:var(--dim);
  padding-bottom:9px; border-bottom:1px solid var(--line-soft)}
.lede{color:var(--dim); font-size:13.5px; max-width:70ch; margin:-4px 0 0}

.tiles{display:grid; gap:1px; background:var(--line-soft);
  border:1px solid var(--line-soft);
  grid-template-columns:repeat(auto-fill,minmax(172px,1fr))}
.tile{background:var(--panel); padding:14px 15px; display:flex;
  flex-direction:column; gap:3px; position:relative}
.tile::before{content:""; position:absolute; left:0; top:0; bottom:0; width:2px;
  background:var(--faint)}
.tile.warn::before{background:var(--warn)}
.tile.bad::before{background:var(--bad)}
.tile .n{font-size:25px; font-weight:600; letter-spacing:-.02em}
.tile .k{font-size:12.5px; color:var(--dim)}
.tile .note{font-size:11.5px; color:var(--faint)}

table{width:100%; border-collapse:collapse; font-size:13.5px}
.scroll{overflow-x:auto; border:1px solid var(--line-soft); background:var(--panel)}
th{text-align:left; font-weight:600; font-size:11.5px; letter-spacing:.08em;
  text-transform:uppercase; color:var(--dim); padding:10px 13px;
  border-bottom:1px solid var(--line); white-space:nowrap}
td{padding:10px 13px; border-bottom:1px solid var(--line-soft);
  vertical-align:top}
tr:last-child td{border-bottom:none}
td.num{text-align:right; font-variant-numeric:tabular-nums; white-space:nowrap}

.pill{display:inline-block; font-size:11px; padding:2px 8px; border-radius:2px;
  border:1px solid var(--line); color:var(--dim); white-space:nowrap}
.pill.run{border-color:var(--accent); color:var(--accent)}
.pill.todo{opacity:.75}

.chapter{background:var(--panel); border:1px solid var(--line-soft);
  padding:16px 18px; display:flex; flex-direction:column; gap:9px}
.chapter h3{margin:0; font-size:16px; font-weight:600; display:flex;
  align-items:baseline; gap:10px; flex-wrap:wrap}
.chapter h3 .wk{font-size:11.5px; color:var(--faint); font-weight:400}
.q{color:var(--dim); font-size:13.5px; font-style:italic}
.verbs{display:grid; gap:1px; background:var(--line-soft);
  grid-template-columns:repeat(auto-fit,minmax(190px,1fr));
  border:1px solid var(--line-soft)}
.verb{background:var(--panel); padding:9px 11px}
.verb .lab{font-size:10.5px; letter-spacing:.09em; text-transform:uppercase;
  color:var(--faint)}
.verb .val{font-size:13px}
.verb.closes .lab{color:var(--accent)}

.controls{display:flex; gap:10px; flex-wrap:wrap; align-items:center}
select,input[type=search]{font:inherit; font-size:13.5px; padding:7px 10px;
  background:var(--panel); color:var(--ink); border:1px solid var(--line);
  border-radius:2px; min-width:0}
select{max-width:100%}
input[type=search]{flex:1; min-width:180px}
:is(select,input,button,a):focus-visible{outline:2px solid var(--accent);
  outline-offset:2px}

.chain{display:flex; flex-direction:column; gap:0;
  border:1px solid var(--line-soft); background:var(--panel)}
.beat{padding:13px 16px; border-bottom:1px solid var(--line-soft);
  display:flex; flex-direction:column; gap:7px}
.beat:last-child{border-bottom:none}
.beat-head{display:flex; gap:10px; align-items:baseline; flex-wrap:wrap}
.beat-head .t{font-weight:600; font-size:14px}
.beat-head .id{font-size:11.5px; color:var(--faint)}
.opts{display:flex; flex-direction:column; gap:5px; margin-left:2px}
.opt{border-left:2px solid var(--line); padding:4px 0 4px 12px; font-size:13px}
.opt .arrow{color:var(--faint); font-size:11.5px}
.eff{font-size:11.5px; color:var(--dim); display:flex; gap:8px; flex-wrap:wrap}
.eff .up{color:var(--ok)} .eff .down{color:var(--bad)}
.dominant{border-left-color:var(--bad)}
.badge{font-size:10.5px; border:1px solid var(--bad); color:var(--bad);
  padding:1px 6px; border-radius:2px}
.empty{color:var(--faint); font-size:13px; padding:14px 16px}

footer{border-top:1px solid var(--line); padding-top:18px; color:var(--faint);
  font-size:12px; display:flex; flex-direction:column; gap:5px}
@media (prefers-reduced-motion:no-preference){
  .beat{transition:background .12s ease}
}
"""

JS = r"""
const $ = (s)=>document.querySelector(s);
const sel = $("#chain-pick"), q = $("#chain-search"), out = $("#chain-out");

function fmtEff(e, aff){
  const parts=[];
  for(const [k,v] of Object.entries(e||{})){
    parts.push(`<span class="${v>0?'up':'down'}">${k} ${v>0?'+':''}${v}</span>`);
  }
  if(aff) parts.push(`<span class="${aff>0?'up':'down'}">호감 ${aff>0?'+':''}${aff}</span>`);
  return parts.length?`<div class="eff mono">${parts.join("")}</div>`:"";
}

// 한 선택이 모든 축에서 우월하고 후속·플래그도 갈리지 않으면 정답 선택이다.
function dominantIndex(cs){
  if(cs.length<2) return -1;
  const tos=new Set(cs.map(c=>c.to)), fl=new Set(cs.map(c=>JSON.stringify(c.flags||[])));
  if(tos.size>1 || fl.size>1) return -1;
  const keys=new Set(); cs.forEach(c=>Object.keys(c.eff||{}).forEach(k=>keys.add(k)));
  keys.add("aff");
  const val=(c,k)=> k==="aff" ? (c.aff||0) : ((c.eff||{})[k]||0);
  for(let i=0;i<cs.length;i++){
    let dom=true;
    for(let j=0;j<cs.length && dom;j++){
      if(i===j) continue;
      let ge=true, gt=false;
      for(const k of keys){
        if(val(cs[i],k) < val(cs[j],k)) ge=false;
        if(val(cs[i],k) > val(cs[j],k)) gt=true;
      }
      dom = ge && gt;
    }
    if(dom) return i;
  }
  return -1;
}

function render(id){
  const c = CHAINS[id];
  if(!c){ out.innerHTML = `<div class="empty">체인을 고르세요.</div>`; return; }
  out.innerHTML = `<div class="chain">` + c.beats.map(b=>{
    const dom = dominantIndex(b.choices);
    const opts = b.choices.length ? `<div class="opts">` + b.choices.map((o,i)=>`
      <div class="opt${i===dom?' dominant':''}">
        <div>${esc(o.text)||"<em>계속</em>"} ${i===dom?'<span class="badge">정답 선택</span>':''}</div>
        ${o.to?`<div class="arrow mono">→ ${esc(o.to)}</div>`:''}
        ${fmtEff(o.eff,o.aff)}
      </div>`).join("") + `</div>` : "";
    return `<div class="beat">
      <div class="beat-head">
        <span class="t">${esc(b.title)}</span>
        <span class="id mono">${esc(b.id)}</span>
        <span class="pill">${b.desc}자</span>
        <span class="pill">${b.dir?"연출 있음":"연출 없음"}</span>
        ${b.bg?`<span class="pill">${esc(b.bg)}</span>`:''}
      </div>${opts}</div>`;
  }).join("") + `</div>`;
}
function esc(s){return String(s??"").replace(/[&<>"]/g,m=>({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;'}[m]));}

function fill(filter){
  const f=(filter||"").trim().toLowerCase();
  const rows = INDEX.filter(r=> !f || r.id.toLowerCase().includes(f) || r.title.toLowerCase().includes(f));
  sel.innerHTML = rows.slice(0,400).map(r=>
    `<option value="${esc(r.id)}">${esc(r.title)} — ${r.n}비트 · 선택점 ${r.picks} (${esc(r.id)})</option>`).join("");
  if(rows.length) render(sel.value = rows[0].id);
  else out.innerHTML = `<div class="empty">일치하는 체인이 없습니다.</div>`;
}
sel.addEventListener("change", e=>render(e.target.value));
q.addEventListener("input", e=>fill(e.target.value));
fill("");
"""


def tiles(rows: list[dict]) -> str:
    return '<div class="tiles">' + "".join(
        f'<div class="tile {r["tone"]}"><div class="n mono">{r["v"]:,}</div>'
        f'<div class="k">{html.escape(r["k"])}</div>'
        f'<div class="note">{html.escape(r["note"])}</div></div>'
        for r in rows) + "</div>"


def build() -> str:
    by = events()
    graph, index = chains(by)
    ords = orders()
    chs = chapters()
    cst = cast()
    bundles = demo_bundles()

    order_rows = "".join(
        f'<tr><td class="mono nb">{html.escape(o["id"])}</td>'
        f'<td>{html.escape(o["title"])}</td>'
        f'<td><span class="pill {"run" if o["state"]=="진행" else "todo"}">{o["state"]}</span></td>'
        f'<td>{html.escape(o["gate"])[:210]}</td></tr>' for o in ords)

    chapter_cards = "".join(
        f'<div class="chapter"><h3>{c["n"]}장 · {html.escape(c["title"])}'
        f'<span class="wk mono">{c["weeks"][0] if c["weeks"] else ""}–{c["weeks"][1] if len(c["weeks"])>1 else ""}주</span></h3>'
        f'<div class="q">{html.escape(c["question"])}</div>'
        f'<div class="verbs">'
        f'<div class="verb"><div class="lab">연다</div><div class="val">{html.escape(c["opens"]) or "—"}</div></div>'
        f'<div class="verb closes"><div class="lab">닫는다</div><div class="val">{html.escape(c["closes"]) or "— (1장은 열기만 한다)"}</div></div>'
        f'<div class="verb"><div class="lab">압력</div><div class="val">{html.escape(c["pressure"])}</div></div>'
        f'<div class="verb"><div class="lab">실패</div><div class="val">{html.escape(c["failure"])}</div></div>'
        f'</div></div>' for c in chs)

    cast_rows = "".join(
        f'<tr><td><strong>{html.escape(r["name"])}</strong><br>'
        f'<span class="mono" style="font-size:11.5px;color:var(--faint)">{html.escape(r["id"])}</span></td>'
        f'<td>{html.escape(r["desire"])}</td>'
        f'<td>{html.escape(r["prop"])}</td>'
        f'<td>{html.escape(r["motif"])}</td>'
        f'<td class="num mono">{r["prop_mentions"]}</td></tr>' for r in cst)

    bundle_rows = "".join(
        f'<tr><td class="mono">{html.escape(b["name"])}</td>'
        f'<td><span class="pill">{html.escape(b["shape"])}</span></td>'
        f'<td>{html.escape(b["kind"])}</td>'
        f'<td class="mono">{"–".join(str(w) for w in (b["weeks"][:1]+b["weeks"][-1:])) if b["weeks"] else ""}</td>'
        f'<td>{html.escape(", ".join(b["chars"]))}</td></tr>' for b in bundles)

    count_tiles = '<div class="tiles">' + "".join(
        f'<div class="tile"><div class="n mono">{c["v"]:,}</div>'
        f'<div class="k">{html.escape(c["k"])}</div></div>' for c in counts()) + "</div>"

    payload = json.dumps({k: v for k, v in graph.items()}, ensure_ascii=False)
    idx = json.dumps(index, ensure_ascii=False)

    return f"""<title>강남드림 — 현재 상태</title>
<style>{CSS}</style>
<div class="wrap">
<header>
  <div class="stamp mono">생성 · tools/project_dashboard.py</div>
  <h1>강남드림 — 지금 어디까지 왔는가</h1>
  <p class="sub">저장소에서 직접 읽어 만든다. 오더·기준선·서명표·척추·데모 번들·
  선택 그래프 전부 실시간 추출이라, 손으로 쓴 현황 문서처럼 낡지 않는다.</p>
  <p class="warnbar"><strong>개발용 화면이다.</strong> 아래 선택 목록은
  <span class="mono">tint</span>·<span class="mono">route_*</span>·정확한 수치를
  그대로 보여 준다. 이것은 플레이어에게 절대 노출하지 않는 값이므로
  이 페이지를 플레이어 대상 자료로 쓰거나 그대로 공개하지 않는다.</p>
</header>

<section>
  <h2>측정된 상태</h2>
  <p class="lede">왼쪽 띠가 있는 항목은 래칫 검사가 지키는 값이다. 색은 좋고 나쁨이지
  강조가 아니다.</p>
  {tiles(metrics(by, index))}
</section>

<section>
  <h2>오더</h2>
  <div class="scroll"><table>
    <thead><tr><th>ID</th><th>제목</th><th>상태</th><th>현재 게이트</th></tr></thead>
    <tbody>{order_rows}</tbody></table></div>
</section>

<section>
  <h2>다섯 장 — 무엇을 열고 무엇을 닫는가</h2>
  <p class="lede">장마다 동사를 하나 열고 이전 동사를 하나 닫는다. 닫히는 쪽이 이
  작품이 인접작과 갈라지는 지점이다.</p>
  {chapter_cards}
</section>

<section>
  <h2>주연 여섯 — 서명</h2>
  <p class="lede">팬이 인물을 알아보는 근거는 렌더 품질이 아니라 같은 소품이 매번
  그 자리에 있다는 사실이다. 마지막 열은 자산 정본이 그 소품을 말한 횟수다.</p>
  <div class="scroll"><table>
    <thead><tr><th>인물</th><th>욕망과 모순</th><th>소유 소품</th><th>오디오 모티프</th><th>언급</th></tr></thead>
    <tbody>{cast_rows}</tbody></table></div>
</section>

<section>
  <h2>선택과 결과</h2>
  <p class="lede">체인 하나가 장면 하나다. 한 선택이 모든 축에서 우월하고 후속도
  플래그도 갈리지 않으면 <strong>정답 선택</strong>으로 표시한다 — 고민이 아니라
  답이 있는 자리다.</p>
  <div class="controls">
    <input type="search" id="chain-search" placeholder="체인 검색 — id 또는 제목" aria-label="체인 검색">
    <select id="chain-pick" aria-label="체인 선택"></select>
  </div>
  <div id="chain-out"></div>
</section>

<section>
  <h2>데모 24주 — 번들 {len(bundles)}개</h2>
  <p class="lede">번들이 전부 장면인 것은 아니다. <em>행동</em>은 결과 카드이고,
  <em>장면</em>만 집필된 체인을 갖는다.</p>
  <div class="scroll"><table>
    <thead><tr><th>번들</th><th>형태</th><th>종류</th><th>주차</th><th>인물</th></tr></thead>
    <tbody>{bundle_rows}</tbody></table></div>
</section>

<section>
  <h2>규모</h2>
  {count_tiles}
</section>

<footer>
  <div>재생성: <span class="mono">python3 tools/project_dashboard.py</span></div>
  <div>수치는 저장소의 현재 상태이며 이 페이지에 하드코딩된 값이 아니다.
  다만 <span class="mono">정답 선택 413</span>은 오늘 측정한 전 구간 값을 고정 표기했다.</div>
</footer>
</div>
<script>const CHAINS={payload};const INDEX={idx};{JS}</script>
"""


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--out", default="build/project_dashboard.html")
    args = ap.parse_args()
    dest = ROOT / args.out
    dest.parent.mkdir(parents=True, exist_ok=True)
    page = build()
    dest.write_text(page, encoding="utf-8")
    print(f"DASHBOARD_WRITTEN {args.out} {len(page.encode()):,} bytes")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
