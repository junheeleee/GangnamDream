#!/usr/bin/env python3
"""Closed two-scene choice facts, shared by the Python schema and simulations.

Godot remains the runtime authority. This module has no import-time disk reads
or project imports; its oracle and schema are also exercised by a real fixture.
"""
from __future__ import annotations

import argparse
import ast
import copy
import json
import re
import tempfile
from pathlib import Path
from typing import Any
from types import SimpleNamespace

ROOT = Path(__file__).resolve().parents[1]
STORY_FACT_SLOTS = {
    "arc_jaehyuk_aftermath": (
        "jaehyuk_reported", "jaehyuk_used", "jaehyuk_victim", "jaehyuk_unknown",
    ),
    "arc_daeun_later_echo": ("daeun_together", ""),
}
JAEHYUK_FLAGS = (
    "jaehyuk_reported", "took_high_road", "jaehyuk_exploited",
    "jaehyuk_partnered", "jaehyuk_scammed",
)
DAEUN_SEPARATION_FLAGS = (
    "daeun_let_her_go", "daeun_breakup_accepted", "daeun_breakup_begged",
    "daeun_let_drift", "daeun_asked_finally", "daeun_romance_blocked",
    "daeun_divorced", "arc_daeun_year3_apart_seen", "arc_daeun_ghost_seen",
    "arc_daeun_year5_apart_seen",
)
MARKER = "requires_story_fact"


def story_fact_layout_errors(event: Any) -> list[str]:
    if not isinstance(event, dict):
        return ["event must be an object"]
    event_id = event.get("id", "")
    slots = STORY_FACT_SLOTS.get(event_id) if isinstance(event_id, str) else None
    choices = event.get("choices", [])
    if not isinstance(choices, list):
        return ["choices must be an array"]
    errors = []
    if slots is not None and len(choices) != len(slots):
        errors.append("story fact choice count changed")
    for index, choice in enumerate(choices):
        if not isinstance(choice, dict):
            if slots is not None:
                errors.append(f"choice {index} must be an object")
            continue
        expected = slots[index] if slots is not None and index < len(slots) else ""
        if expected:
            if type(choice.get(MARKER)) is not str or choice[MARKER] != expected:
                errors.append(f"choice {index} requires exact story fact {expected}")
        elif MARKER in choice:
            errors.append(f"choice {index} has a story fact outside its owned slot")
        if slots is not None and choice in choices[:index]:
            errors.append(f"choice {index} duplicates another choice")
    return errors


def story_fact_available(flags: dict[str, Any], event: Any, choice: Any) -> bool:
    if not isinstance(event, dict) or not isinstance(choice, dict):
        return False
    event_id = event.get("id", "")
    if not isinstance(event_id, str) or event_id not in STORY_FACT_SLOTS:
        return MARKER not in choice
    if story_fact_layout_errors(event):
        return False
    if not any(candidate is choice for candidate in event["choices"]):
        return False
    marker = choice.get(MARKER, "")
    if not marker:
        return True
    relevant = ("daeun_romance_started", *DAEUN_SEPARATION_FLAGS) \
        if marker == "daeun_together" else JAEHYUK_FLAGS
    if any(type(flags.get(flag, False)) is not bool for flag in relevant):
        return False
    if marker == "daeun_together":
        return flags.get("daeun_romance_started", False) and not any(
            flags.get(flag, False) for flag in DAEUN_SEPARATION_FLAGS)
    if marker == "jaehyuk_reported":
        return flags.get("jaehyuk_reported", False) or flags.get("took_high_road", False)
    if marker == "jaehyuk_used":
        return flags.get("jaehyuk_exploited", False) or flags.get("jaehyuk_partnered", False)
    if marker == "jaehyuk_victim":
        return flags.get("jaehyuk_scammed", False)
    return not any(flags.get(flag, False) for flag in JAEHYUK_FLAGS)


def legacy_aftermath_override(base: dict, choices: Any) -> bool:
    """Only the known 3 -> 4 source-owned neutral-choice migration is legal."""
    return base.get("id") == "arc_jaehyuk_aftermath" \
        and not story_fact_layout_errors(base) \
        and isinstance(choices, list) and len(choices) == 3


def representative_story_fact_index(flags: dict, event: dict, requested: int) -> int:
    """Arc traces choose a legal representative only for these two scenes."""
    if event.get("id") not in STORY_FACT_SLOTS:
        return requested
    available = [index for index, choice in enumerate(event.get("choices", []))
                 if story_fact_available(flags, event, choice)]
    return requested if requested in available else (available[0] if available else -1)


def _gd_array(source: str, name: str) -> tuple[str, ...]:
    match = re.search(rf"const {name} := \[(.*?)\n\]", source, re.S)
    return tuple(re.findall(r'"([^"]+)"', match[1])) if match else ()


def audit(root: Path = ROOT) -> list[str]:
    errors = []
    owned = {}
    for path in sorted((root / "content/events").glob("*.json")):
        rows = json.loads(path.read_text(encoding="utf-8"))
        for event in rows if isinstance(rows, list) else []:
            if not isinstance(event, dict):
                continue
            for error in story_fact_layout_errors(event):
                errors.append(f"{path.name}/{event.get('id')}: {error}")
            if event.get("id") in STORY_FACT_SLOTS:
                if event["id"] in owned:
                    errors.append(f"duplicate owned event: {event['id']}")
                owned[event["id"]] = event
    if set(owned) != set(STORY_FACT_SLOTS):
        errors.append("missing owned story fact events")
    aftermath = owned.get("arc_jaehyuk_aftermath", {})
    if len(aftermath.get("choices", [])) == 4:
        neutral = dict(aftermath["choices"][3])
        for text_key in ("text", "result_text"):
            if not isinstance(neutral.pop(text_key, None), str):
                errors.append(f"neutral missing {text_key}")
        if neutral != {
            MARKER: "jaehyuk_unknown", "flags": ["arc_jaehyuk_aftermath_seen"],
            "deferred_follow_up": "arc_jaehyuk_mirror", "deferred_delay": 1,
        }:
            errors.append("neutral choice must only record seen and schedule mirror at +1")
    for language in ("en", "ja", "zh-CN", "zh-TW"):
        path = root / f"content/events_{language}/arc_events.json"
        translated = {row["id"]: row for row in json.loads(path.read_text(encoding="utf-8"))}
        for event_id, slots in STORY_FACT_SLOTS.items():
            choices = translated.get(event_id, {}).get("choices", [])
            if len(choices) != len(slots):
                errors.append(f"{language}/{event_id}: translated choice count drift")
            if any(MARKER in choice for choice in choices):
                errors.append(f"{language}/{event_id}: gameplay marker leaked into overlay")
    game = (root / "autoloads/GameState.gd").read_text(encoding="utf-8")
    registry = (root / "autoloads/DataRegistry.gd").read_text(encoding="utf-8")
    if _gd_array(game, "JAEHYUK_CHOICE_FACT_FLAGS") != JAEHYUK_FLAGS:
        errors.append("runtime Jaehyuk facts differ from Python contract")
    if _gd_array(game, "DAEUN_CHOICE_SEPARATION_FLAGS") != DAEUN_SEPARATION_FLAGS:
        errors.append("runtime Daeun separation facts differ from Python contract")
    slots_match = re.search(r"const STORY_FACT_SLOTS := (\{.*?\n\})", registry, re.S)
    try:
        gd_slots = json.loads(re.sub(r",\s*([\]}])", r"\1", slots_match[1])) \
            if slots_match else {}
    except json.JSONDecodeError:
        gd_slots = {}
    if gd_slots != {key: list(value) for key, value in STORY_FACT_SLOTS.items()}:
        errors.append("runtime story fact slots differ from Python contract")
    return errors


def self_test() -> int:
    count = 0

    def check(value: bool, label: str) -> None:
        nonlocal count
        count += 1
        if not value:
            raise AssertionError(label)

    events = {event_id: {"id": event_id, "choices": [
        {"text": str(index), "result_text": str(index), **({MARKER: marker} if marker else {})}
        for index, marker in enumerate(slots)]}
        for event_id, slots in STORY_FACT_SLOTS.items()}
    event = events["arc_jaehyuk_aftermath"]

    def visible(flags: dict, row: dict = event) -> list[int]:
        return [index for index, choice in enumerate(row["choices"])
                if story_fact_available(flags, row, choice)]

    for mask in range(32):
        flags = {flag: bool(mask & (1 << index)) for index, flag in enumerate(JAEHYUK_FLAGS)}
        expected = [index for index, truth in enumerate((
            bool(mask & 3), bool(mask & 12), bool(mask & 16), mask == 0)) if truth]
        check(visible(flags) == expected, f"Jaehyuk mask {mask}")
    check(visible({"crossed_line": True}) == [3], "generic moral flag invented a Jaehyuk fact")
    for flag in JAEHYUK_FLAGS:
        for bad in (None, 0, 1, "true", [], {}):
            check(visible({flag: bad}) == [], f"malformed {flag} {bad!r}")
    daeun = events["arc_daeun_later_echo"]
    check(visible({"daeun_romance_started": True}, daeun) == [0, 1], "Daeun positive")
    for flag in DAEUN_SEPARATION_FLAGS:
        for value in (True, None, 1, "false"):
            check(visible({"daeun_romance_started": True, flag: value}, daeun) == [1], flag)
    for flag in ("daeun_married", "daeun_close_bond", "daeun_together_path"):
        check(visible({flag: True}, daeun) == [1], f"unapproved Daeun positive {flag}")
    check(visible({"daeun_romance_started": True, "daeun_ended": True}, daeun) == [0, 1],
          "shared ended flag was treated as a breakup")
    for bad in (None, True, 3, "", "unknown", "jaehyuk_used"):
        mutated = copy.deepcopy(event)
        mutated["choices"][0][MARKER] = bad
        check(bool(story_fact_layout_errors(mutated)) and visible({}, mutated) == [], "bad marker")
    mutated = copy.deepcopy(event)
    del mutated["choices"][0][MARKER]
    check(visible({}, mutated) == [], "missing marker")
    check(not story_fact_available({}, event, copy.deepcopy(event["choices"][3])), "detached choice")
    check(story_fact_available({}, {"id": "unrelated"}, {}), "unrelated membership restricted")
    check(not story_fact_available({}, {"id": "unrelated"}, {MARKER: "jaehyuk_unknown"}),
          "misplaced marker admitted")
    check(legacy_aftermath_override(event, [{}, {}, {}]), "legacy mod not admitted")
    check(not legacy_aftermath_override(event, [{}, {}]), "arbitrary count migration")
    check(not legacy_aftermath_override(daeun, [{}, {}, {}]), "migration escaped owned event")
    for shape in (None, {}, [], [None], [event["choices"][3]] * 2):
        malformed = {"id": event["id"], "choices": shape}
        check(not story_fact_available({}, malformed, event["choices"][3]), "malformed choices")

    # Exercise the actual mod validator, including old text-only arrays. The
    # runtime fixture independently exercises DataRegistry's corresponding merge.
    from mod_pack_validator import Report, validate_choice, validate_event_file
    with tempfile.TemporaryDirectory(prefix="gangnam-story-fact-") as temporary:
        path = Path(temporary) / "facts.json"
        for base in (event, daeun):
            for length in range(1, 6):
                source = {"id": base["id"], "override": True, "choices": [
                    {"text": str(index), "result_text": str(index)} for index in range(length)]}
                path.write_text(json.dumps([source]), encoding="utf-8")
                report = Report()
                validate_event_file(path, {base["id"]: base}, report)
                allowed = length == len(base["choices"]) or (base is event and length == 3)
                check((not report.errors) == allowed, f"mod count {base['id']}/{length}")
            for marker in (None, True, 1, "", "bad", "jaehyuk_victim", []):
                source = {"id": base["id"], "override": True, "choices": [
                    {"text": str(index), "result_text": str(index)}
                    for index in range(len(base["choices"]))]}
                source["choices"][0][MARKER] = marker
                path.write_text(json.dumps([source]), encoding="utf-8")
                report = Report()
                validate_event_file(path, {base["id"]: base}, report)
                check(bool(report.errors), f"mod forged marker {marker!r}")
            source = copy.deepcopy(base)
            source["override"] = True
            path.write_text(json.dumps([source]), encoding="utf-8")
            report = Report()
            validate_event_file(path, {base["id"]: base}, report)
            check(not report.errors, "exact marker inheritance rejected")
            for gate in ({"requires_item": "ticket"}, {"opportunity": {"cost": 999999999}},
                         {"opportunity_unavailable_fallback": True}):
                guarded = copy.deepcopy(source)
                guarded["choices"][0].update(gate)
                path.write_text(json.dumps([guarded]), encoding="utf-8")
                report = Report()
                validate_event_file(path, {base["id"]: base}, report)
                check(bool(report.errors), f"extra choice gate {gate}")
        report = Report()
        validate_choice(event["choices"][0], "custom", report, set(), set())
        check(bool(report.errors), "new mod authored a source-owned marker")

    from convergence_sim import SimState, _choice_available
    state = SimState()
    for mask in range(32):
        state.flags = {flag for index, flag in enumerate(JAEHYUK_FLAGS) if mask & (1 << index)}
        actual = [index for index, choice in enumerate(event["choices"])
                  if _choice_available(state, event, choice)]
        check(actual == visible({flag: True for flag in state.flags}), f"convergence mask {mask}")
    risk = {"text": "risk", "opportunity": {"cost": 50}}
    fallback = {"text": "leave", "opportunity_unavailable_fallback": True}
    opportunity_event = {"id": "unrelated", "choices": [risk, fallback]}
    state.money = 49
    check(not _choice_available(state, opportunity_event, risk)
          and _choice_available(state, opportunity_event, fallback), "convergence unfunded fallback")
    state.money = 50
    check(_choice_available(state, opportunity_event, risk)
          and not _choice_available(state, opportunity_event, fallback), "convergence funded choice")
    risk["requires_item"] = "ticket"
    check(not _choice_available(state, opportunity_event, risk), "convergence item rule")

    # Read and execute only these function bodies, never the arc simulator's
    # import-time 240-week run. This is a targeted consumer check, not full play.
    from event_schedule import deferred_follow_ups
    source = ast.parse((ROOT / "tools/arc_flow_sim.py").read_text(encoding="utf-8"))
    names = {"canonical_deferred_links", "apply_immediate_choice_state"}
    selected = ast.Module(body=[node for node in source.body
        if isinstance(node, ast.FunctionDef) and node.name in names], type_ignores=[])
    arc_event = copy.deepcopy(event)
    for choice in arc_event["choices"]:
        choice.update({"flags": ["arc_jaehyuk_aftermath_seen"],
                       "deferred_follow_up": "arc_jaehyuk_mirror", "deferred_delay": 1})
    namespace = {"events": {arc_event["id"]: arc_event}, "STORY_FACT_SLOTS": STORY_FACT_SLOTS,
                 "story_fact_available": story_fact_available, "deferred_follow_ups": deferred_follow_ups}
    exec(compile(selected, "arc_flow_sim.py::targeted", "exec"), namespace)
    state = SimpleNamespace(flags={}, cast={})
    namespace["apply_immediate_choice_state"](state, arc_event["id"], {arc_event["id"]: 0})
    check(not state.flags, "arc consumer invented a reported outcome")
    check(namespace["canonical_deferred_links"](arc_event["id"], {arc_event["id"]: 0}, flags={}) == [],
          "arc consumer scheduled a forbidden choice")
    check(representative_story_fact_index({}, arc_event, 0) == 3, "arc unknown index")
    check(namespace["canonical_deferred_links"](arc_event["id"], {arc_event["id"]: 3}, flags={})
          == [("arc_jaehyuk_mirror", 1)], "arc neutral mirror")
    namespace["apply_immediate_choice_state"](state, arc_event["id"], {arc_event["id"]: 3})
    check(state.flags == {"arc_jaehyuk_aftermath_seen": True}, "arc neutral state")
    return count


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--self-test", action="store_true")
    args = parser.parse_args()
    errors = audit()
    if args.self_test:
        print(f"STORY_CHOICE_FACT_SELF_TEST_OK cases={self_test()}")
    for error in errors:
        print("STORY_CHOICE_FACT_AUDIT_FAIL " + error)
    if errors:
        return 1
    print("STORY_CHOICE_FACT_AUDIT_OK events=2 gated_slots=5 locales=5")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
