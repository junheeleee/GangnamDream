#!/usr/bin/env python3
"""Measure whether authored stops read as one novel instead of event cards.

This audit turns the live KO event catalog and representative arc-flow paths
into a stable ledger of scene length, decision count, chain depth, chapter
density, and isolated micro-scenes. Integrity errors always fail. Re-composed
chapters carry strict minimum chain/peak and maximum isolation ratchets so the
novel cannot silently collapse back into disconnected cards.
"""

from __future__ import annotations

import argparse
import json
import re
import subprocess
import sys
from collections import Counter
from dataclasses import asdict, dataclass
from pathlib import Path
from typing import Any


ROOT = Path(__file__).resolve().parents[1]
EVENT_DIR = ROOT / "content" / "events"
EVENT_DIRECTOR = ROOT / "content" / "meta" / "event_director.json"
WEEKS_PER_CHAPTER = 48
TOTAL_CHAPTERS = 5
CHAPTER_RATCHETS = {
    1: {
        "chained_min": 7,
        "peak_roots_min": 1,
        "temporal_roots_min": 3,
        "isolated_micro_max": 0,
        "stops_max": 30,
        "thread_switches_max": 25,
    },
    2: {
        "chained_min": 4,
        "peak_roots_min": 2,
        "temporal_roots_min": 1,
        "isolated_micro_max": 0,
    },
    3: {
        "chained_min": 2,
        "peak_roots_min": 2,
        "temporal_roots_min": 9,
        "isolated_micro_max": 2,
    },
    4: {
        "chained_min": 3,
        "peak_roots_min": 2,
        "temporal_roots_min": 3,
        "isolated_micro_max": 0,
    },
    5: {"chained_min": 2, "peak_roots_min": 1, "isolated_micro_max": 0},
}


@dataclass(frozen=True)
class SceneMetric:
    min_links: int
    max_links: int
    min_panels: int
    max_panels: int
    min_decisions: int
    max_decisions: int
    min_dialogue: int
    max_dialogue: int


def load_events() -> dict[str, dict[str, Any]]:
    events: dict[str, dict[str, Any]] = {}
    for path in sorted(EVENT_DIR.glob("*.json")):
        raw = json.loads(path.read_text(encoding="utf-8"))
        values = raw if isinstance(raw, list) else list(raw.values())
        for value in values:
            if not isinstance(value, dict) or not value.get("id"):
                continue
            event_id = str(value["id"])
            if event_id in events:
                raise ValueError(f"duplicate event id: {event_id}")
            event = dict(value)
            event["_source"] = path.name
            events[event_id] = event
    return events


def paragraph_count(value: Any) -> int:
    return sum(1 for block in str(value or "").split("\n\n") if block.strip())


def dialogue_count(value: Any) -> int:
    text = str(value or "")
    return (
        len(re.findall(r'"[^"\n]+"', text))
        + len(re.findall(r"“[^”\n]+”", text))
        + len(re.findall(r"「[^」\n]+」", text))
    )


def followups(event: dict[str, Any]) -> list[str]:
    """Return same-scene links only; these determine panel and decision depth."""
    result: list[str] = []
    for choice in event.get("choices", []):
        if not isinstance(choice, dict):
            continue
        target = str(choice.get("follow_up_event", "")).strip()
        if target:
            result.append(target)
    return result


def deferred_followups(event: dict[str, Any]) -> list[tuple[str, int]]:
    """Return week-spaced causal links without pretending they are one scene."""
    result: list[tuple[str, int]] = []
    for choice in event.get("choices", []):
        if not isinstance(choice, dict):
            continue
        target = str(choice.get("deferred_follow_up", "")).strip()
        if target:
            result.append((target, int(choice.get("deferred_delay", 6))))
    return result


def causal_followups(event: dict[str, Any]) -> list[str]:
    result = followups(event)
    result.extend(target for target, _ in deferred_followups(event))
    return result


def is_authored(event: dict[str, Any]) -> bool:
    conditions = event.get("conditions", {})
    min_turn = int(conditions.get("min_turn", 1)) if isinstance(conditions, dict) else 1
    return (
        float(event.get("weight", 1.0)) <= 0.0
        or min_turn >= 9999
        or str(event.get("rarity", "")) == "story"
    )


def scene_metric(
    event_id: str,
    events: dict[str, dict[str, Any]],
    memo: dict[str, SceneMetric],
    stack: tuple[str, ...] = (),
) -> SceneMetric:
    if event_id in memo:
        return memo[event_id]
    if event_id in stack:
        raise ValueError("follow-up loop: " + " -> ".join(stack + (event_id,)))
    event = events.get(event_id)
    if event is None:
        raise ValueError(f"missing follow-up event: {event_id}")

    choices = event.get("choices") or []
    if not isinstance(choices, list):
        raise ValueError(f"choices must be an array: {event_id}")
    base_panels = paragraph_count(event.get("description"))
    base_dialogue = dialogue_count(event.get("description"))
    decision = int(len(choices) > 1)

    if not choices:
        metric = SceneMetric(1, 1, base_panels, base_panels, 0, 0, base_dialogue, base_dialogue)
        memo[event_id] = metric
        return metric

    branches: list[SceneMetric] = []
    for choice in choices:
        if not isinstance(choice, dict):
            raise ValueError(f"choice must be an object: {event_id}")
        result_panels = 1 + paragraph_count(choice.get("result_text"))
        result_dialogue = dialogue_count(choice.get("result_text"))
        target = str(choice.get("follow_up_event", "")).strip()
        if target:
            child = scene_metric(target, events, memo, stack + (event_id,))
            branches.append(SceneMetric(
                1 + child.min_links,
                1 + child.max_links,
                base_panels + result_panels + child.min_panels,
                base_panels + result_panels + child.max_panels,
                decision + child.min_decisions,
                decision + child.max_decisions,
                base_dialogue + result_dialogue + child.min_dialogue,
                base_dialogue + result_dialogue + child.max_dialogue,
            ))
        else:
            branches.append(SceneMetric(
                1,
                1,
                base_panels + result_panels,
                base_panels + result_panels,
                decision,
                decision,
                base_dialogue + result_dialogue,
                base_dialogue + result_dialogue,
            ))

    metric = SceneMetric(
        min(item.min_links for item in branches),
        max(item.max_links for item in branches),
        min(item.min_panels for item in branches),
        max(item.max_panels for item in branches),
        min(item.min_decisions for item in branches),
        max(item.max_decisions for item in branches),
        min(item.min_dialogue for item in branches),
        max(item.max_dialogue for item in branches),
    )
    memo[event_id] = metric
    return metric


def run_arc_paths() -> dict[str, dict[int, str]]:
    proc = subprocess.run(
        [sys.executable, str(ROOT / "tools" / "arc_flow_sim.py"), "--verbose"],
        cwd=ROOT,
        check=True,
        text=True,
        capture_output=True,
    )
    paths: dict[str, dict[int, str]] = {}
    current = ""
    for line in proc.stdout.splitlines():
        header = re.match(r"=== Path (.+) ===", line.strip())
        if header:
            current = header.group(1)
            paths[current] = {}
            continue
        fired = re.match(r"\s*t\s*(\d+)\s+([a-zA-Z0-9_]+)\s*$", line)
        if fired and current:
            paths[current][int(fired.group(1))] = fired.group(2)
    if not paths:
        raise ValueError("arc_flow_sim produced no representative paths")
    return paths


THREAD_TOKENS: tuple[tuple[str, tuple[str, ...]], ...] = (
    ("father", ("father", "dad_", "_dad", "paternal")),
    ("daeun", ("daeun",)),
    ("jiyeon", ("jiyeon",)),
    ("sangchul", ("sangchul",)),
    ("jaehyuk", ("jaehyuk",)),
    ("hyunsu", ("hyunsu",)),
    ("minseo", ("minseo",)),
    ("career", ("career", "job_", "_job", "interview", "workplace")),
    ("capital", ("money", "invest", "finance", "capital", "asset", "gangnam")),
    ("housing", ("housing", "gosiwon", "goshiwon", "rent", "jeonse")),
    ("reckoning", ("ending", "final", "reckoning", "summit", "countdown")),
    ("chapter", ("chapter", "year_close", "year1_close", "year2_close", "year3_close", "year4_close")),
)


def story_thread(event: dict[str, Any]) -> str:
    fields: list[str] = [
        str(event.get("id", "")),
        str(event.get("portrait", "")),
        str(event.get("category", "")),
        " ".join(str(tag) for tag in event.get("tags", []) if isinstance(tag, str)),
        " ".join(str(key) for key in (event.get("cast_effects") or {}).keys()),
    ]
    corpus = " ".join(fields).lower()
    matches = [name for name, tokens in THREAD_TOKENS if any(token in corpus for token in tokens)]
    if matches:
        return "+".join(matches[:2])
    if "intro" in corpus or "prologue" in corpus:
        return "origin"
    return "world"


def collect_descendants(root: str, events: dict[str, dict[str, Any]], output: set[str]) -> None:
    if root in output or root not in events:
        return
    output.add(root)
    for target in followups(events[root]):
        collect_descendants(target, events, output)


def peak_members(events: dict[str, dict[str, Any]]) -> set[str]:
    from peak_scene_chain_audit import PEAK_ROOTS

    result: set[str] = set()
    for _, root in PEAK_ROOTS:
        collect_descendants(root, events, result)
    return result


def is_short_standalone(metric: SceneMetric) -> bool:
    return metric.max_links == 1 and metric.max_panels <= 6 and metric.max_dialogue <= 1


def build_report() -> dict[str, Any]:
    events = load_events()
    memo: dict[str, SceneMetric] = {}
    for event_id in events:
        scene_metric(event_id, events, memo)

    incoming: Counter[str] = Counter()
    immediate_edge_count = 0
    temporal_edge_count = 0
    for event in events.values():
        for target in followups(event):
            if target not in events:
                raise ValueError(f"dangling follow-up: {event['id']} -> {target}")
            incoming[target] += 1
            immediate_edge_count += 1
        for target, delay in deferred_followups(event):
            if target not in events:
                raise ValueError(f"dangling deferred follow-up: {event['id']} -> {target}")
            if delay < 1:
                raise ValueError(f"non-temporal deferred follow-up: {event['id']} -> {target} delay={delay}")
            incoming[target] += 1
            temporal_edge_count += 1

    peaks = peak_members(events)
    authored = {event_id for event_id, event in events.items() if is_authored(event)}
    chain_members = {
        event_id
        for event_id, event in events.items()
        if incoming[event_id] > 0 or bool(causal_followups(event))
    }
    temporal_sources = {
        event_id for event_id, event in events.items() if deferred_followups(event)
    }
    temporal_targets = {
        target
        for event in events.values()
        for target, _ in deferred_followups(event)
    }
    temporal_members = temporal_sources | temporal_targets
    standalone = set(events) - chain_members
    short_standalone = {event_id for event_id in standalone if is_short_standalone(memo[event_id])}

    from event_director_audit import (
        EXPECTED_BRIDGE_RANDOM,
        EXPECTED_FOREGROUND_RANDOM,
        EXPECTED_IMPLICIT_BRIDGE_ROOTS,
        follow_up_targets,
        is_bridge_random,
        is_foreground_random,
    )

    director_manifest = json.loads(EVENT_DIRECTOR.read_text(encoding="utf-8"))
    direct_targets = follow_up_targets(list(events.values()))
    foreground_ids = {
        event_id
        for event_id, event in events.items()
        if is_foreground_random(event, director_manifest, direct_targets)
    }
    bridge_ids = {
        event_id
        for event_id, event in events.items()
        if is_bridge_random(event, director_manifest, direct_targets)
    }
    if len(foreground_ids) != EXPECTED_FOREGROUND_RANDOM \
            or len(bridge_ids) != EXPECTED_BRIDGE_RANDOM:
        raise ValueError(
            "content diet drifted: "
            f"foreground={len(foreground_ids)} bridge={len(bridge_ids)}"
        )

    paths = run_arc_paths()
    path_reports: list[dict[str, Any]] = []
    for path_name, firelog in paths.items():
        chapter_rows: list[dict[str, Any]] = []
        path_micro: list[dict[str, Any]] = []
        ordered = sorted(firelog.items())
        threads = [story_thread(events[event_id]) for _, event_id in ordered]

        for chapter in range(1, TOTAL_CHAPTERS + 1):
            start = (chapter - 1) * WEEKS_PER_CHAPTER + 1
            end = chapter * WEEKS_PER_CHAPTER
            selected = [(week, event_id) for week, event_id in ordered if start <= week <= end]
            single_link = 0
            chained = 0
            peak_roots = 0
            temporal_roots = 0
            temporal_chained = 0
            short = 0
            isolated = 0
            panels_min = 0
            panels_max = 0
            links_min = 0
            links_max = 0
            decisions_min = 0
            decisions_max = 0
            switches = 0
            previous_thread = ""

            for week, event_id in selected:
                metric = memo[event_id]
                thread = story_thread(events[event_id])
                panels_min += metric.min_panels
                panels_max += metric.max_panels
                links_min += metric.min_links
                links_max += metric.max_links
                decisions_min += metric.min_decisions
                decisions_max += metric.max_decisions
                single_link += int(metric.max_links == 1)
                chained += int(metric.max_links > 1)
                peak_roots += int(event_id in peaks)
                temporal_roots += int(bool(deferred_followups(events[event_id])))
                temporal_chained += int(event_id in temporal_members)
                short_here = event_id in standalone and is_short_standalone(metric)
                short += int(short_here)
                if previous_thread and thread != previous_thread:
                    switches += 1
                previous_thread = thread

                index = ordered.index((week, event_id))
                before = threads[index - 1] if index > 0 else ""
                after = threads[index + 1] if index + 1 < len(threads) else ""
                isolated_here = short_here and thread not in {before, after}
                isolated += int(isolated_here)
                if isolated_here:
                    path_micro.append({"week": week, "event": event_id, "thread": thread})

            chapter_rows.append({
                "chapter": chapter,
                "weeks": f"{start}-{end}",
                "stops": len(selected),
                "single_link": single_link,
                "chained": chained,
                "peak_roots": peak_roots,
                "temporal_roots": temporal_roots,
                "temporal_chained": temporal_chained,
                "short_standalone": short,
                "isolated_micro": isolated,
                "panels_min": panels_min,
                "panels_max": panels_max,
                "links_min": links_min,
                "links_max": links_max,
                "decisions_min": decisions_min,
                "decisions_max": decisions_max,
                "thread_switches": switches,
            })

        path_reports.append({
            "name": path_name,
            "chapters": chapter_rows,
            "isolated_micro_scenes": path_micro,
        })

    ratchet_errors: list[str] = []
    for path in path_reports:
        rows = {int(row["chapter"]): row for row in path["chapters"]}
        for chapter, contract in CHAPTER_RATCHETS.items():
            row = rows[chapter]
            if int(row["chained"]) < contract["chained_min"]:
                ratchet_errors.append(
                    f"{path['name']} chapter {chapter} chains "
                    f"{row['chained']}<{contract['chained_min']}"
                )
            if int(row["peak_roots"]) < contract["peak_roots_min"]:
                ratchet_errors.append(
                    f"{path['name']} chapter {chapter} peaks "
                    f"{row['peak_roots']}<{contract['peak_roots_min']}"
                )
            temporal_roots_min = int(contract.get("temporal_roots_min", 0))
            if int(row["temporal_roots"]) < temporal_roots_min:
                ratchet_errors.append(
                    f"{path['name']} chapter {chapter} temporal roots "
                    f"{row['temporal_roots']}<{temporal_roots_min}"
                )
            if int(row["isolated_micro"]) > contract["isolated_micro_max"]:
                ratchet_errors.append(
                    f"{path['name']} chapter {chapter} isolated "
                    f"{row['isolated_micro']}>{contract['isolated_micro_max']}"
                )
            stops_max = int(contract.get("stops_max", sys.maxsize))
            if int(row["stops"]) > stops_max:
                ratchet_errors.append(
                    f"{path['name']} chapter {chapter} stops "
                    f"{row['stops']}>{stops_max}"
                )
            switches_max = int(contract.get("thread_switches_max", sys.maxsize))
            if int(row["thread_switches"]) > switches_max:
                ratchet_errors.append(
                    f"{path['name']} chapter {chapter} thread switches "
                    f"{row['thread_switches']}>{switches_max}"
                )
    if ratchet_errors:
        raise ValueError("chapter pacing ratchet: " + "; ".join(ratchet_errors))

    return {
        "catalog": {
            "events": len(events),
            "authored": len(authored),
            "random_pool": len(events) - len(authored),
            "followup_edges": immediate_edge_count,
            "temporal_edges": temporal_edge_count,
            "chain_members": len(chain_members),
            "temporal_members": len(temporal_members),
            "peak_members": len(peaks),
            "standalone": len(standalone),
            "short_standalone": len(short_standalone),
            "authored_short_standalone": len(short_standalone & authored),
            "random_short_standalone": len(short_standalone - authored),
            "director_foreground": len(foreground_ids),
            "director_bridge": len(bridge_ids),
            "foreground_implicit_bridge_roots": len(
                foreground_ids & EXPECTED_IMPLICIT_BRIDGE_ROOTS
            ),
            "foreground_short_standalone": len(
                (foreground_ids & short_standalone) - EXPECTED_IMPLICIT_BRIDGE_ROOTS
            ),
            "foreground_chain_members": len(
                foreground_ids & (chain_members | EXPECTED_IMPLICIT_BRIDGE_ROOTS)
            ),
        },
        "paths": path_reports,
    }


def print_text(report: dict[str, Any]) -> None:
    catalog = report["catalog"]
    print("NARRATIVE_CONTINUITY_AUDIT")
    print("CATALOG " + " ".join(f"{key}={value}" for key, value in catalog.items()))
    for path in report["paths"]:
        print("PATH name=" + str(path["name"]).replace(" ", "_"))
        for row in path["chapters"]:
            print(
                "  CHAPTER {chapter} weeks={weeks} stops={stops} single={single_link} "
                "chains={chained} temporal={temporal_chained}/{temporal_roots} "
                "peaks={peak_roots} short={short_standalone} "
                "isolated={isolated_micro} panels={panels_min}-{panels_max} "
                "links={links_min}-{links_max} decisions={decisions_min}-{decisions_max} "
                "switches={thread_switches}".format(**row)
            )
        micro = path["isolated_micro_scenes"]
        preview = ",".join(f"t{item['week']}:{item['event']}" for item in micro[:16])
        print(f"  ISOLATED_MICRO count={len(micro)} sample={preview or 'none'}")
    print("NARRATIVE_CONTINUITY_AUDIT_OK")


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--json", action="store_true", help="print the ledger as JSON")
    args = parser.parse_args()
    try:
        report = build_report()
    except (OSError, ValueError, json.JSONDecodeError, subprocess.CalledProcessError) as exc:
        print(f"NARRATIVE_CONTINUITY_AUDIT_FAIL {exc}", file=sys.stderr)
        return 1
    if args.json:
        print(json.dumps(report, ensure_ascii=False, indent=2))
    else:
        print_text(report)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
