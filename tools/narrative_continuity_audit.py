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
import copy
import json
import re
import subprocess
import sys
from collections import Counter
from dataclasses import asdict, dataclass
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from human_gates import print_pending  # noqa: E402
from typing import Any

from event_schedule import deferred_follow_ups


ROOT = Path(__file__).resolve().parents[1]
EVENT_DIR = ROOT / "content" / "events"
EVENT_DIRECTOR = ROOT / "content" / "meta" / "event_director.json"
CHAPTER5_TYPED_LEDGERS = (
    (
        ROOT / "content" / "meta" / "chapter5_causal_ledger.json",
        "chapter5_m49_m55_causal_route_v1",
        19,
        47,
    ),
    (
        ROOT / "content" / "meta" / "chapter5_finale_ledger.json",
        "chapter5_m56_m60_safe_finale_v1",
        11,
        30,
    ),
    (
        ROOT / "content" / "meta" / "chapter5_general_finale_ledger.json",
        "chapter5_general_near_goal_passed_finale_v2",
        8,
        17,
    ),
)
CHAPTER5_GENERAL_SELECTOR_ROOTS = {
    "arc_y5_general_name_boundary_exact",
    "arc_y5_general_debt_memory_reconnect",
}
CHAPTER4_BODY_RECEIPT_GROUPS = (
    (("arc_36_body_signal",), "arc_36_body_signal_seen"),
    (("arc_y4_body_witness", "arc_y4_body_witness_hyunsu"),
     "arc_y4_body_witness_seen"),
    (("arc_y4_family_partner_collision", "arc_y4_family_commitment_none",
      "arc_y4_family_table_missed"), "arc_y4_family_table_seen"),
)
CHAPTER4_BODY_GUARDS = (
    '''if t == 161 and not f.get("arc_36_body_signal_seen", false):
        return "arc_36_body_signal"''',
    '''if t == 164 and f.get("arc_36_body_signal_seen", false) \\
            and not f.get("arc_y4_body_witness_seen", false):
        return _chapter_four_relationship_event_id(
            "arc_y4_body_witness", "arc_y4_body_witness_hyunsu")''',
    '''if t == 167 and not father_is_passed \\
            and f.get("arc_y4_body_witness_seen", false) \\
            and not f.get("arc_y4_family_table_seen", false):
        var unattached_family_id := "arc_y4_family_commitment_none"
        if f.get("arc_y4_three_promises_missed_father", false):
            unattached_family_id = "arc_y4_family_table_missed"
        return _chapter_four_relationship_event_id(
            "arc_y4_family_partner_collision", unattached_family_id)''',
)
WEEKS_PER_CHAPTER = 48
TOTAL_CHAPTERS = 5
CHAPTER_RATCHETS = {
    1: {
        # Survival-job paths use the substantial Hyunsu kitchen scene directly
        # at week 20 instead of inventing a company-manager prelude.
        "chained_min": 6,
        "peak_roots_min": 1,
        "temporal_roots_min": 3,
        "isolated_micro_max": 0,
        # The investment representative now carries its real route identity
        # from W1, so the already-shipping first-chart scene is measured instead
        # of silently omitted. This is audit-fidelity debt, not a new stop.
        # The exact representative ledger below already freezes the denser
        # investment path at 35 authored stops. Keep the aggregate ratchet on
        # that same reviewed inventory instead of failing one behind it.
        "stops_max": 35,
        "thread_switches_max": 30,
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
    min_chars: int
    max_chars: int


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


def typed_chapter5_chain_members(events: dict[str, dict[str, Any]]) -> set[str]:
    """Return roots whose links are owned by the three typed product ledgers."""
    members: set[str] = set()
    for path, ledger_id, root_count, choice_count in CHAPTER5_TYPED_LEDGERS:
        payload = json.loads(path.read_text(encoding="utf-8"))
        roots = payload.get("roots", []) if isinstance(payload, dict) else []
        if not isinstance(payload, dict) \
                or payload.get("schema_version") != 1 \
                or payload.get("ledger_id") != ledger_id \
                or payload.get("expected_root_count") != root_count \
                or payload.get("expected_choice_count") != choice_count \
                or not isinstance(roots, list) \
                or len(roots) != root_count \
                or not all(isinstance(root, dict) for root in roots) \
                or sum(int(root.get("choice_count", -1)) for root in roots) \
                    != choice_count:
            raise ValueError(f"typed Chapter 5 ledger drifted: {path.name}")
        event_ids = [str(root.get("event_id", "")) for root in roots]
        if any(not event_id or event_id not in events for event_id in event_ids) \
                or len(event_ids) != len(set(event_ids)):
            raise ValueError(
                f"typed Chapter 5 ledger has missing/duplicate roots: {path.name}")
        members.update(event_ids)
    return members


def paragraph_count(value: Any) -> int:
    return sum(1 for block in str(value or "").split("\n\n") if block.strip())


def chapter4_body_chain_members(
        events: dict[str, dict[str, Any]], source: str,
        model_source: str) -> set[str]:
    """Count the existing runtime receipt chain, never an ID-only exemption.

    These links are scheduled by MainGame, not JSON follow_up_event. Every
    choice must write the receipt, and both downstream selectors must still
    require it. Missing evidence fails rather than relaxing the micro ratchet.
    """
    from chapter4_causal_route_audit import source_function_block

    function = source_function_block(source, "_chapter_four_causal_arc_id")
    code = "\n".join(line for line in function.splitlines()
                     if not line.lstrip().startswith("#"))

    def compact(value: str) -> str:
        return re.sub(r"\s+", "", value.replace("\\\n", ""))

    for guard in CHAPTER4_BODY_GUARDS:
        if compact(guard) not in compact(code):
            raise ValueError("Chapter 4 body receipt chain lost runtime guard/selector")
    runtime_selector = source_function_block(source, "_chapter_four_relationship_event_id")
    if compact('''var partner_id := _romance_partner_id()
        if partner_id == "daeun":
            return daeun_id
        return unattached_id''') not in compact(runtime_selector):
        raise ValueError("Chapter 4 body receipt chain lost runtime partner selector")
    if any(marker not in model_source for marker in (
            "def chapter_four_causal_event(", "def chapter_four_relationship_event(")):
        raise ValueError("Chapter 4 body receipt chain lost model function")
    model_function = model_source.split("def chapter_four_causal_event", 1)[1].split(
        "\ndef ", 1)[0]
    for guard in CHAPTER4_BODY_GUARDS:
        model_guard = guard.replace(', false', '').replace('var ', '').replace(':=', '=')
        model_guard = model_guard.replace('not father_is_passed',
                                          'not father_death_is_monotonic(S)')
        model_guard = model_guard.replace('_chapter_four_relationship_event_id(',
                                          'chapter_four_relationship_event(S,')
        model_guard = model_guard.replace('unattached_family_id', 'unattached_id')
        if compact(model_guard) not in compact(model_function):
            raise ValueError("Chapter 4 body receipt chain lost model guard/selector parity")
    model_selector = model_source.split("def chapter_four_relationship_event", 1)[1].split(
        "\ndef ", 1)[0]
    if compact('''partner_id = chapter_four_partner_id(S)
        if partner_id == "daeun":
            return daeun_id
        return unattached_id''') not in compact(model_selector):
        raise ValueError("Chapter 4 body receipt chain lost model partner selector")
    members: set[str] = set()
    for roots, receipt in CHAPTER4_BODY_RECEIPT_GROUPS:
        for event_id in roots:
            event = events.get(event_id, {})
            choices = event.get("choices", [])
            if len(choices) != 3 or any(
                    not isinstance(choice, dict)
                    or receipt not in choice.get("flags", [])
                    for choice in choices):
                raise ValueError(
                    f"Chapter 4 body receipt chain lost producer: {event_id}/{receipt}")
            members.add(event_id)
    return members


def dialogue_count(value: Any) -> int:
    text = str(value or "")
    return (
        len(re.findall(r'"[^"\n]+"', text))
        + len(re.findall(r"“[^”\n]+”", text))
        + len(re.findall(r"「[^」\n]+」", text))
    )


def prose_char_count(value: Any) -> int:
    """Count authored characters without normalizing the source prose."""
    return len(str(value or ""))


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
        result.extend(deferred_follow_ups(choice))
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
    base_chars = prose_char_count(event.get("description"))
    decision = int(len(choices) > 1)

    if not choices:
        metric = SceneMetric(
            1,
            1,
            base_panels,
            base_panels,
            0,
            0,
            base_dialogue,
            base_dialogue,
            base_chars,
            base_chars,
        )
        memo[event_id] = metric
        return metric

    branches: list[SceneMetric] = []
    for choice in choices:
        if not isinstance(choice, dict):
            raise ValueError(f"choice must be an object: {event_id}")
        result_panels = 1 + paragraph_count(choice.get("result_text"))
        result_dialogue = dialogue_count(choice.get("result_text"))
        branch_chars = (
            base_chars
            + prose_char_count(choice.get("text"))
            + prose_char_count(choice.get("result_text"))
        )
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
                branch_chars + child.min_chars,
                branch_chars + child.max_chars,
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
                branch_chars,
                branch_chars,
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
        min(item.min_chars for item in branches),
        max(item.max_chars for item in branches),
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
    tags = {
        str(tag).lower()
        for tag in event.get("tags", [])
        if isinstance(tag, str)
    }
    # Explicit chapter-boundary tags own the thread classification. This keeps
    # an approach scene such as arc_final_stretch attached to the close it
    # leads into instead of treating the incidental word "final" as a detached
    # endgame micro-scene.
    if "year_close" in tags or "chapter_bridge" in tags:
        return "chapter"
    fields: list[str] = [
        str(event.get("id", "")),
        str(event.get("portrait", "")),
        str(event.get("category", "")),
        " ".join(tags),
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


def has_micro_scene_shape(metric: SceneMetric) -> bool:
    return metric.max_links == 1 and metric.max_panels <= 6 and metric.max_dialogue <= 1


def is_short_standalone(metric: SceneMetric) -> bool:
    return has_micro_scene_shape(metric) and metric.max_chars <= 420


def _paragraph_fixture(total_chars: int, panels: int = 6) -> str:
    separator_chars = (panels - 1) * 2
    if total_chars <= separator_chars:
        raise ValueError("fixture character count is too small for its panels")
    prose_chars = total_chars - separator_chars
    base, remainder = divmod(prose_chars, panels)
    return "\n\n".join(
        "가" * (base + int(index < remainder))
        for index in range(panels)
    )


def run_self_test() -> None:
    boundary_events = {
        "micro_420": {
            "id": "micro_420",
            "description": _paragraph_fixture(420),
            "choices": [],
        },
        "substantial_421": {
            "id": "substantial_421",
            "description": _paragraph_fixture(421),
            "choices": [],
        },
    }
    memo: dict[str, SceneMetric] = {}
    micro = scene_metric("micro_420", boundary_events, memo)
    substantial = scene_metric("substantial_421", boundary_events, memo)
    if micro.max_chars != 420 or not is_short_standalone(micro):
        raise AssertionError("420-character six-panel fixture must remain a micro-scene")
    if substantial.max_chars != 421 or is_short_standalone(substantial):
        raise AssertionError("421-character six-panel fixture must not be a micro-scene")

    branch_events = {
        "branch_root": {
            "id": "branch_root",
            "description": "가" * 100,
            "choices": [
                {"text": "나" * 10, "result_text": "다" * 20},
                {
                    "text": "라" * 11,
                    "result_text": "마" * 21,
                    "follow_up_event": "branch_child",
                },
            ],
        },
        "branch_child": {
            "id": "branch_child",
            "description": "바" * 50,
            "choices": [],
        },
    }
    branch = scene_metric("branch_root", branch_events, {})
    if (branch.min_chars, branch.max_chars) != (130, 182):
        raise AssertionError(
            "branch character range must include description, choice, result, and child prose"
        )
    if (branch.min_links, branch.max_links) != (1, 2):
        raise AssertionError("branch fixture link range drifted")

    mixed_boundary_events = {
        "mixed_boundary": {
            "id": "mixed_boundary",
            "description": "가" * 400,
            "choices": [
                {"text": "나" * 10, "result_text": "다" * 10},
                {"text": "라" * 10, "result_text": "마" * 11},
            ],
        },
    }
    mixed_boundary = scene_metric("mixed_boundary", mixed_boundary_events, {})
    if (mixed_boundary.min_chars, mixed_boundary.max_chars) != (420, 421):
        raise AssertionError("mixed branch fixture must retain its 420..421 range")
    if is_short_standalone(mixed_boundary):
        raise AssertionError("one 421-character branch must keep the scene out of micro")

    body_events = {
        event_id: {"id": event_id, "choices": [{"flags": [receipt]} for _ in range(3)]}
        for roots, receipt in CHAPTER4_BODY_RECEIPT_GROUPS for event_id in roots
    }
    body_source = ("func _chapter_four_causal_arc_id():\n"
                   + "\n".join(CHAPTER4_BODY_GUARDS)
                   + '''\nfunc _chapter_four_relationship_event_id():
    var partner_id := _romance_partner_id()
    if partner_id == "daeun":
        return daeun_id
    return unattached_id
func next(): pass\n''')
    model_source = '''def chapter_four_causal_event(S):
    if t == 161 and not f.get("arc_36_body_signal_seen"):
        return "arc_36_body_signal"
    if t == 164 and f.get("arc_36_body_signal_seen") \\
            and not f.get("arc_y4_body_witness_seen"):
        return chapter_four_relationship_event(
            S, "arc_y4_body_witness", "arc_y4_body_witness_hyunsu")
    if t == 167 and not father_death_is_monotonic(S) \\
            and f.get("arc_y4_body_witness_seen") \\
            and not f.get("arc_y4_family_table_seen"):
        unattached_id = "arc_y4_family_commitment_none"
        if f.get("arc_y4_three_promises_missed_father"):
            unattached_id = "arc_y4_family_table_missed"
        return chapter_four_relationship_event(
            S, "arc_y4_family_partner_collision", unattached_id)
def chapter_four_relationship_event(S, daeun_id, unattached_id):
    partner_id = chapter_four_partner_id(S)
    if partner_id == "daeun":
        return daeun_id
    return unattached_id
def next(): pass
'''
    members = chapter4_body_chain_members(body_events, body_source, model_source)
    if len(members) != 6:
        raise AssertionError("receipt chain must contain exactly its six runtime roots")
    mutations = []
    missing = copy.deepcopy(body_events)
    missing.pop("arc_y4_body_witness_hyunsu")
    mutations.append((missing, body_source))
    for event_id, index in (("arc_36_body_signal", 0),
                            ("arc_y4_body_witness_hyunsu", 2),
                            ("arc_y4_family_table_missed", 1)):
        damaged = copy.deepcopy(body_events)
        damaged[event_id]["choices"][index]["flags"] = []
        mutations.append((damaged, body_source))
    for old, new in (
            ('not f.get("arc_36_body_signal_seen", false)', 'true'),
            ('if t == 164 and f.get("arc_36_body_signal_seen", false)',
             'if t == 164 and true'),
            ('and f.get("arc_y4_body_witness_seen", false)', 'and true'),
            ('"arc_y4_body_witness_hyunsu"', '"unrelated"'),
            ('t == 167', 't == 168')):
        mutations.append((body_events, body_source.replace(old, new, 1)))
    for damaged, source in mutations:
        try:
            chapter4_body_chain_members(damaged, source, model_source)
        except ValueError:
            continue
        raise AssertionError("broken runtime receipt chain was counted as connected")
    for runtime_source, simulated_source in (
            (body_source.replace('if partner_id == "daeun"',
                                 'if partner_id == "jiyeon"'), model_source),
            (body_source, model_source.replace('t == 164', 't == 165')),
            (body_source, model_source.replace('def chapter_four_causal_event(',
                                               'def unrelated_event(')),
            (body_source, model_source.replace('if partner_id == "daeun"',
                                               'if partner_id == "jiyeon"'))):
        try:
            chapter4_body_chain_members(body_events, runtime_source, simulated_source)
        except ValueError:
            continue
        raise AssertionError("runtime/model selector or guard drift was accepted")
    # The same 417-character shape remains short. Only proven receipt members
    # are connected; unrelated short scenes still enter the isolation ratchet.
    short = SceneMetric(1, 1, 6, 6, 1, 1, 0, 0, 403, 417)
    if not is_short_standalone(short) or "unrelated" in members:
        raise AssertionError("receipt proof weakened unrelated micro-scene detection")


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
    # M49-M60 product sequencing is deliberately not encoded as generic JSON
    # follow_up_event links: exact reducers own turn, receipt, save, and variant
    # routing. Count those roots as chained so a short cross-character climax
    # is not mislabeled as an isolated event card.
    chain_members.update(typed_chapter5_chain_members(events))
    missing_general_selectors = CHAPTER5_GENERAL_SELECTOR_ROOTS - set(events)
    if missing_general_selectors:
        raise ValueError(
            "missing Chapter 5 general selector roots: "
            f"{sorted(missing_general_selectors)}")
    chain_members.update(CHAPTER5_GENERAL_SELECTOR_ROOTS)
    body_chain = chapter4_body_chain_members(
        events, (ROOT / "scenes" / "MainGame.gd").read_text(encoding="utf-8"),
        (ROOT / "tools" / "arc_flow_sim.py").read_text(encoding="utf-8"))
    chain_members.update(body_chain)
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
        path_substantial_single: list[dict[str, Any]] = []
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
            chars_min = 0
            chars_max = 0
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
                chars_min += metric.min_chars
                chars_max += metric.max_chars
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
                    path_micro.append({
                        "week": week,
                        "event": event_id,
                        "thread": thread,
                        "min_chars": metric.min_chars,
                        "max_chars": metric.max_chars,
                    })
                if has_micro_scene_shape(metric) and metric.max_chars > 420:
                    path_substantial_single.append({
                        "week": week,
                        "event": event_id,
                        "min_chars": metric.min_chars,
                        "max_chars": metric.max_chars,
                    })

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
                "chars_min": chars_min,
                "chars_max": chars_max,
                "thread_switches": switches,
            })

        path_reports.append({
            "name": path_name,
            "chapters": chapter_rows,
            "isolated_micro_scenes": path_micro,
            "substantial_single_scenes": path_substantial_single,
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
            "runtime_body_receipt_members": len(body_chain),
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
                "chars={chars_min}-{chars_max} switches={thread_switches}".format(**row)
            )
        micro = path["isolated_micro_scenes"]
        preview = ",".join(
            f"t{item['week']}:{item['event']}:{item['min_chars']}-{item['max_chars']}"
            for item in micro[:16]
        )
        print(f"  ISOLATED_MICRO count={len(micro)} sample={preview or 'none'}")
        substantial = path["substantial_single_scenes"]
        substantial_preview = ",".join(
            f"t{item['week']}:{item['event']}:{item['min_chars']}-{item['max_chars']}"
            for item in substantial[:16]
        )
        print(
            "  SUBSTANTIAL_SINGLE "
            f"count={len(substantial)} sample={substantial_preview or 'none'}"
        )
    print_pending("narrative")
    print("NARRATIVE_CONTINUITY_AUDIT_OK")


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--json", action="store_true", help="print the ledger as JSON")
    parser.add_argument("--self-test", action="store_true", help="run boundary fixtures")
    args = parser.parse_args()
    if args.self_test:
        try:
            run_self_test()
        except (AssertionError, ValueError) as exc:
            print(f"NARRATIVE_CONTINUITY_SELF_TEST_FAIL {exc}", file=sys.stderr)
            return 1
        print(
            "NARRATIVE_CONTINUITY_SELF_TEST_OK "
            "cases=20 boundary=420/421 mixed=420-421 "
            "runtime_receipt=positive+13_mutations unrelated_micro=preserved"
        )
        return 0
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
