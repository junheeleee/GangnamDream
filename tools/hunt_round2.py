#!/usr/bin/env python3
"""Round 2 hunt: two questions the shipped audits do not ask.

  1. Ending reachability - is every declared ending actually produced by
     something the runtime can reach?
  2. Near-duplicate prose - paragraphs repeated across events, which a player
     experiences as the game saying the same thing twice.
"""
import glob
import json
import re
from collections import defaultdict

# ------------------------------------------------------------------ corpus
EV = {}
for path in glob.glob("content/events/*.json"):
    data = json.load(open(path, encoding="utf-8"))
    items = data.get("events", data) if isinstance(data, dict) else data
    if isinstance(items, list):
        for ev in items:
            if isinstance(ev, dict) and ev.get("id"):
                EV[ev["id"]] = (path.split("/")[-1], ev)

code = ""
for path in (glob.glob("scenes/*.gd") + glob.glob("autoloads/*.gd")
             + glob.glob("systems/*.gd")):
    code += open(path, encoding="utf-8", errors="ignore").read()

# ------------------------------------------------------- 1. ending reachability
endings = {}
for path in glob.glob("content/**/ending*.json", recursive=True):
    data = json.load(open(path, encoding="utf-8"))
    items = data.get("endings", data) if isinstance(data, dict) else data
    if isinstance(items, list):
        for e in items:
            if isinstance(e, dict) and e.get("id"):
                endings[e["id"]] = path.split("/")[-1]
    elif isinstance(items, dict):
        for k in items:
            endings[k] = path.split("/")[-1]

print(f"[1] 선언된 엔딩 {len(endings)}개")
unreachable = []
for eid, src in endings.items():
    # produced by finish_run("id"), an ending table, or an event flag
    produced = (f'"{eid}"' in code) or any(
        f'"{eid}"' in json.dumps(ev, ensure_ascii=False)
        for _, ev in EV.values())
    if not produced:
        for meta in glob.glob("content/meta/*.json"):
            if f'"{eid}"' in open(meta, encoding="utf-8").read():
                produced = True
                break
    if not produced:
        unreachable.append((eid, src))
print(f"    런타임·사건·메타 어디서도 생산되지 않는 엔딩: {len(unreachable)}")
for eid, src in unreachable[:12]:
    print(f"      · {eid}  ({src})")

# ------------------------------------------------------ 2. near-duplicate prose
def paragraphs(text):
    for p in re.split(r"\n\s*\n", text or ""):
        p = re.sub(r"\s+", " ", p).strip()
        if len(p) >= 60:            # ignore one-liners and stage fragments
            yield p

seen = defaultdict(list)
for eid, (src, ev) in EV.items():
    for p in paragraphs(ev.get("description", "")):
        seen[p].append((eid, "desc"))
    for i, c in enumerate(ev.get("choices", [])):
        for p in paragraphs(c.get("result_text", "")):
            seen[p].append((eid, f"result[{i}]"))

dupes = {p: locs for p, locs in seen.items()
         if len({l[0] for l in locs}) > 1}
print(f"\n[2] 서로 다른 사건에 그대로 반복되는 문단: {len(dupes)}")
ranked = sorted(dupes.items(), key=lambda kv: -len(kv[1]))
for p, locs in ranked[:10]:
    ids = sorted({l[0] for l in locs})
    print(f"    {len(ids)}개 사건 · {len(p)}자")
    print(f"      {p[:96]}")
    print(f"      → {', '.join(ids[:4])}{' …' if len(ids) > 4 else ''}")

# chapter-5 only view, since that is where repetition was reported
c5 = [(p, locs) for p, locs in dupes.items()
      if any(i.startswith("arc_y5_") or i.startswith("arc_final_countdown")
             for i, _ in locs)]
print(f"\n    그중 5장 종막 계열이 걸린 것: {len(c5)}")
for p, locs in sorted(c5, key=lambda kv: -len(kv[1]))[:6]:
    ids = sorted({l[0] for l in locs})
    print(f"      {len(ids)}개 · {p[:80]}")
    print(f"        → {', '.join(ids[:4])}")
