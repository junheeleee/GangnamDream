#!/usr/bin/env python3
"""Throwaway hunting probe: look where the shipped audits do not.

Three static questions over the real event corpus:
  1. Dead choices  - a choice that changes nothing at all.
  2. Lethal beats  - an authored beat whose stat cost can end the run outright,
                     including beats the player did not choose into.
  3. Orphan events - authored events nothing can ever reach.
"""
import glob
import json
import re
from collections import defaultdict

EVENTS = {}
FILE_OF = {}
for path in glob.glob("content/events/*.json"):
    data = json.load(open(path, encoding="utf-8"))
    items = data.get("events", data) if isinstance(data, dict) else data
    if not isinstance(items, list):
        continue
    for ev in items:
        if isinstance(ev, dict) and ev.get("id"):
            EVENTS[ev["id"]] = ev
            FILE_OF[ev["id"]] = path.split("/")[-1]

print(f"corpus: {len(EVENTS)} authored events\n")

# ---------------------------------------------------------------- 1. dead choices
dead = []
for eid, ev in EVENTS.items():
    choices = ev.get("choices", [])
    if len(choices) < 2:
        continue  # a single-choice rail is a "continue", not a decision
    for i, c in enumerate(choices):
        if (not c.get("effects")
                and not c.get("flags")
                and not c.get("follow_up_event")
                and not str(c.get("result_text", "")).strip()
                and "opportunity" not in c
                and "action" not in c):
            dead.append((eid, i, str(c.get("text", ""))[:40], FILE_OF[eid]))
print(f"[1] 아무것도 바꾸지 않는 선택: {len(dead)}건")
for eid, i, txt, f in dead[:12]:
    print(f"    {eid}[{i}] {txt!r}  ({f})")

# ------------------------------------------------------------- 2. lethal beats
# check_game_over(): health <= 0 or mental <= 0 ends the run immediately.
lethal = []
for eid, ev in EVENTS.items():
    for i, c in enumerate(ev.get("choices", [])):
        eff = c.get("effects", {}) or {}
        for stat in ("mental", "health"):
            d = float(eff.get(stat, 0) or 0)
            if d <= -25:
                lethal.append((d, stat, eid, i, len(ev.get("choices", [])),
                               str(c.get("text", ""))[:34], FILE_OF[eid]))
lethal.sort()
print(f"\n[2] 한 선택이 {'mental/health'} 25 이상을 깎는 경우: {len(lethal)}건")
print("    (check_game_over는 mental<=0 또는 health<=0에서 즉시 런 종료)")
for d, stat, eid, i, n, txt, f in lethal[:14]:
    rail = "단일" if n < 2 else f"{n}지"
    print(f"    {stat:>6} {d:>6.0f}  {eid}[{i}] ({rail}) {txt!r}")

# ------------------------------------------------------------ 3. orphan events
referenced = set()
for ev in EVENTS.values():
    for c in ev.get("choices", []):
        fu = c.get("follow_up_event")
        if fu:
            referenced.add(fu)
    for key in ("follow_up_event", "next_event"):
        if ev.get(key):
            referenced.add(ev[key])

code = ""
for path in (glob.glob("scenes/*.gd") + glob.glob("autoloads/*.gd")
             + glob.glob("systems/*.gd") + glob.glob("content/meta/*.json")):
    code += open(path, encoding="utf-8", errors="ignore").read()

orphans = []
for eid, ev in EVENTS.items():
    if eid in referenced:
        continue
    if float(ev.get("weight", 0) or 0) > 0:
        continue  # drawable from the ambient pool
    if eid in code:
        continue  # named by runtime or a meta ledger
    orphans.append((eid, str(ev.get("title", ""))[:28],
                    json.dumps(ev.get("conditions", {}), ensure_ascii=False)[:44],
                    FILE_OF[eid]))
print(f"\n[3] weight 0 · 아무 데서도 참조되지 않는 사건: {len(orphans)}건")
by_file = defaultdict(int)
for eid, t, cond, f in orphans:
    by_file[f] += 1
for f, n in sorted(by_file.items(), key=lambda kv: -kv[1])[:10]:
    print(f"    {n:>4}  {f}")
for eid, t, cond, f in orphans[:10]:
    print(f"    · {eid}  {t!r}  cond={cond}")
