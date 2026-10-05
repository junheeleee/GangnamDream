#!/usr/bin/env python3
"""Observe four prepared legacy Main GUI routes, never natural-play or release GO.

Only --run launches Godot. Every label, log, PNG and namespace is retained,
including failures. Importing the old runner uses safety utilities, not its main.
"""
from __future__ import annotations

import argparse
import copy
import hashlib
import json
import math
import os
from pathlib import Path
import re
import secrets
import shutil
import struct
import subprocess
import sys
import time

sys.dont_write_bytecode = True
import run_routine_background_context_check as safe

ROOT = Path(__file__).resolve().parents[1]
PLAYER = Path("/Users/junheelee/Library/Application Support/Godot/app_userdata/강남드림")
UNIT = "ORDER-456"
SCENE = "res://tools/RoutineBackgroundInputCheck.tscn"
INPUTS = (
    "project.godot", "scenes/MainGame.gd", "scenes/MainGame.tscn",
    "autoloads/GameState.gd", "autoloads/LocaleManager.gd", "autoloads/SaveManager.gd",
    "autoloads/MetaProgression.gd", "autoloads/EventManager.gd", "autoloads/ImageRegistry.gd",
    "autoloads/AudioManager.gd", "autoloads/BGMPlayer.gd", "autoloads/ControllerHints.gd",
    "autoloads/UIStyle.gd", "tools/StoryNameplateBootstrap.gd",
    "tools/RoutineBackgroundContextCheck.gd", "tools/run_routine_background_context_check.py",
    "tools/RoutineBackgroundInputCheck.gd", "tools/RoutineBackgroundInputCheck.tscn",
    "tools/run_routine_background_input_check.py", "tools/audit_scope.json",
    "assets/backgrounds/goshiwon_shared_kitchen.png", "assets/backgrounds/park_bench_day.png",
)
FIXTURES = (
    {"id": "general_w230_save0", "turn": 230, "action": "save", "index": 0,
     "pressure": "final_reckoning", "family": "reckoning", "person": "",
     "actions": ["side_shift", "study", "save"], "background": "goshiwon_shared_kitchen",
     "ambience": "goshiwon_hallway",
     "ko": "편의점 도시락 대신 집에서 밥을 했다. 재료비 이천 원으로 하루를 버텼다.",
     "en": "Cooked at home instead of a convenience store lunch box. Made it through the day on 2,000 won of ingredients."},
    {"id": "general_w216_rest5", "turn": 216, "action": "rest", "index": 5,
     "pressure": "relationship", "family": "human", "person": "jiyeon",
     "actions": ["contact", "side_shift", "rest"], "background": "park_bench_day", "ambience": "street",
     "ko": "공원 벤치에서 멍하니 사람들을 봤다. 다들 어딘가로 바쁘다.",
     "en": "Sat on a park bench watching people drift by. Everyone seems busy going somewhere."},
)
FAILURE = re.compile(r"SCRIPT ERROR|Parse Error|Compile Error|Failed to load script|\bERROR:|"
                     r"ObjectDB instances leaked|resources still in use|ROUTINE_BACKGROUND_\w*FAIL|"
                     r"STORY_NAMEPLATE_\w*FAIL", re.IGNORECASE)


def require(condition, message):
    if not condition:
        raise ValueError(message)


def strict_json(raw):
    def pairs(items):
        result = {}
        for key, value in items:
            require(key not in result, "duplicate JSON key: " + key)
            result[key] = value
        return result
    def bad_number(value):
        raise ValueError("non-finite JSON number: " + value)
    return json.loads(raw, object_pairs_hook=pairs, parse_constant=bad_number)


def write_json(path, value):
    with path.open("x", encoding="utf-8") as stream:
        json.dump(value, stream, ensure_ascii=False, indent=2, sort_keys=True, allow_nan=False)
        stream.write("\n")


def pin(path):
    require(path.is_file() and not path.is_symlink(), "required plain file missing: " + str(path))
    digest, size = hashlib.sha256(), 0
    with path.open("rb") as stream:
        for block in iter(lambda: stream.read(1024 * 1024), b""):
            digest.update(block)
            size += len(block)
    return {"exists": True, "bytes": size, "sha256": digest.hexdigest()}


def git(*args):
    return subprocess.check_output(["git", *args], cwd=ROOT)


def player_snapshot():
    require(PLAYER.is_dir() and not PLAYER.is_symlink(), "actual player directory unavailable")
    entries = sorted(PLAYER.rglob("*"))
    require(not any(path.is_symlink() for path in entries), "player symlink is not a plain-file witness")
    files = {str(path.relative_to(PLAYER)): pin(path) for path in entries if path.is_file()}
    return {"path": str(PLAYER), "exists": True, "files": files, "file_count": len(files)}


def snapshot():
    head = git("rev-parse", "HEAD").decode().strip()
    result = {"head": head, "tree": git("rev-parse", "HEAD^{tree}").decode().strip(),
              "status_hex": git("status", "--porcelain=v1", "-z", "--untracked-files=all").hex(),
              "inputs": {path: pin(ROOT / path) for path in INPUTS}, "player": player_snapshot()}
    require(git("rev-parse", "HEAD").decode().strip() == head, "HEAD changed during snapshot")
    return result


def expected_marker(locale):
    return ("ROUTINE_BACKGROUND_INPUT_CHECK_OK cases=2 raw=12 taps=6 pressed=2 "
            "receipts=2 screenshots=2 locale=" + locale)


def untyped(node):
    require(isinstance(node, dict) and set(node) == ({"type", "value", "typed_builtin"} if node.get("type") == "Array" else {"type", "value"}), "typed witness shape differs")
    kind, value = node["type"], node["value"]
    if kind == "Dictionary":
        require(isinstance(value, dict), "typed Dictionary payload differs")
        return {key: untyped(item) for key, item in value.items()}
    if kind == "Array":
        require(isinstance(value, list) and type(node["typed_builtin"]) is int, "typed Array payload differs")
        return [untyped(item) for item in value]
    if kind == "PackedStringArray":
        require(isinstance(value, list) and all(isinstance(item, str) for item in value), "packed string payload differs")
        return value[:]
    checks = {"Nil": value is None, "bool": type(value) is bool,
              "int": type(value) is int, "float": type(value) in (int, float) and math.isfinite(value),
              "String": isinstance(value, str), "StringName": isinstance(value, str)}
    require(checks.get(kind, False), "unsupported or malformed typed scalar: " + str(kind))
    return float(value) if kind == "float" else value


def typed(value, previous=None):
    """Build an expected witness; retain existing Variant tags, infer new fields only."""
    if isinstance(value, dict):
        old = previous["value"] if previous and previous["type"] == "Dictionary" else {}
        return {"type": "Dictionary", "value": {key: typed(item, old.get(key)) for key, item in value.items()}}
    if isinstance(value, list):
        if previous and previous["type"] == "PackedStringArray":
            return {"type": "PackedStringArray", "value": value[:]}
        old = previous["value"] if previous and previous["type"] == "Array" else []
        return {"type": "Array", "value": [typed(item, old[index] if index < len(old) else None)
                                            for index, item in enumerate(value)],
                "typed_builtin": previous["typed_builtin"] if previous and previous["type"] == "Array" else 0}
    kind = ("Nil" if value is None else "bool" if type(value) is bool else "int" if type(value) is int
            else "float" if type(value) is float else "String" if isinstance(value, str) else "unsupported")
    if previous is not None:
        kind = previous["type"]
    result = {"type": kind, "value": value}
    untyped(result)
    return result


def money_text(saved, locale):
    # This fixture's exact 30,000..99,999 range uses these two current format branches.
    return ("%.0f만원" % (saved / 10000.0)) if locale == "ko" else ("%.0f thousand won" % (saved / 1000.0))


def expected_effects(row, fixture, locale):
    """Source-derived narrow model of the two existing atomic action producers."""
    before = row["ready_before"]
    game = copy.deepcopy(untyped(before["game"]))
    extra = copy.deepcopy(untyped(before["extra"]))
    action, turn, person = fixture["action"], fixture["turn"], fixture["person"]
    save = action == "save"
    require(game["turn"] == turn and game["action_points"] == game["max_action_points"] == 1
            and game["mental"] == 80 and game["money"] == 100000000
            and not game["pending_weekly_commitment"] and not game["weekly_commitments"]
            and not game["forgone_path_debts"], "preinput baseline differs from the two prepared fixtures")
    roll = row["roll"]
    draws = [roll["draw1"], roll["draw2"]] if save else [roll["draw1"]]
    require(type(roll["seed"]) is int and roll["seed"] > 0 and len(draws) == (2 if save else 1)
            and all(type(value) is int and 0 <= value <= 0xffffffff for value in draws), "RNG prediction witness differs")
    require(save or roll["draw2"] == -1, "REST unexpectedly predicts a second draw")
    saved = 30000 + draws[0] % 70000 if save else 0
    require(roll["saved"] == saved and roll["index"] == fixture["index"] == draws[-1] % (5 if save else 10),
            "preinput RNG prediction/index differs")
    axis, place = ("money", "store") if save else ("human", "home")
    game["action_points"] = 0
    game["money"] += saved
    game["mental"] += -2 if save else 9
    game["action_axis_this_week"][axis] = int(game["action_axis_this_week"].get(axis, 0)) + 1
    visit = game["action_places_this_week"].setdefault(place, {"count": 0, "money": 0, "human": 0})
    visit["count"] += 1
    visit[axis] += 1
    recent = game["recent_action_places"]
    if not recent or recent[-1] != place:
        recent.append(place)
        del recent[:-8]
    families = ["finance", "money", "daily_life", "daily"] if save else ["health", "rest", "mental", "daily_life", "family", "relationship"]
    game["action_records_this_week"].append({"id": action, "axis": axis, "place": place, "subject": "", "families": families})
    if save:
        game["tendency"]["career"] += 4
        require(game["tendency"]["career"] < 12, "fixture unexpectedly crosses a tendency threshold")
    else:
        game["flags"]["free_time_count"] = int(game["flags"].get("free_time_count", 0)) + 1
    forgone = fixture["actions"][:2]
    debt_rows = []
    for alternative in forgone:
        debt_person = person if alternative == "contact" else ""
        key = "contact:" + person if alternative == "contact" else alternative
        game["forgone_path_debts"][key] = {"action_id": alternative, "person_id": debt_person,
            "first_turn": turn, "last_turn": turn, "count": 1, "pressure_family": fixture["family"]}
        debt_rows.append({"action_id": alternative, "person_id": debt_person, "count": 1,
                          "first_turn": turn, "last_turn": turn})
    details = {"receipt_prose_ko": fixture["ko"], "receipt_prose_en": fixture["en"], "scene_background_id": fixture["background"]}
    outcome = {"mental": -2.0 if save else 9.0}
    if save:
        details["saved"] = saved
        outcome.update(money=float(saved), total_assets=float(saved))
    receipt = {"turn": turn, "pressure_id": fixture["pressure"], "pressure_family": fixture["family"],
        "choice_id": action, "person_id": person, "forgone_ids": forgone, "scene_background_id": fixture["background"],
        "actual_action_id": action, "outcome": outcome, "details": details, "forgone_debts": debt_rows, "echoed_turn": -1}
    if save:
        receipt["identity_evidence"] = {"kind": "career", "weight": 4, "version": game["tendency_evidence_version"]}
    game["weekly_commitments"].append(receipt)
    title = ("절약" if locale == "ko" else "Saving") if save else ("휴식" if locale == "ko" else "Rest")
    prose = fixture[locale]
    log = ("💰 " if save else "") + title + " — " + prose
    date = ("%d년 %d월 %d주차" if locale == "ko" else "%04d-%02d W%d") % (game["year"], game["month"], game["week_of_month"])
    game["action_log"].append({"turn": turn, "date": date, "message": log, "type": "event"})
    game["action_log"] = game["action_log"][-120:]
    extra["turn_action_log"].append(("✓ 💰 " + title + " — " + money_text(saved, locale)) if save
                                    else "✓ " + title + " — " + prose[:22])
    body = prose + (("\n\n%s 절약했다." if locale == "ko" else "\n\nSaved %s.") % money_text(saved, locale) if save else "")
    game_typed = typed(game, before["game"])
    # _register_action_record declares families as Array[String], including its new entry.
    game_typed["value"]["action_records_this_week"]["value"][-1]["value"]["families"]["typed_builtin"] = 4
    return {"game": game_typed, "extra": typed(extra, before["extra"]),
            "meta": before["meta"], "event": before["event"]}, receipt, body


def focused_card(row, index, fixture, card):
    return (row.get("valid") is True and row.get("owned") is True and row.get("button") is True
            and row.get("visible") is True and row.get("queued") is False and row.get("disabled") is False
            and row.get("focus_mode") in (1, 2) and row.get("index") == index
            and row.get("action") == fixture["actions"][index] and row.get("result_confirm") is False
            and row.get("path") == card["path"] and row.get("instance_id") == card["instance_id"])


def settled(row):
    return (all(row.get(key) is False for key in ("typing", "fade", "commit", "milestone"))
            and row.get("visible_ratio") == 1 and 0 <= row.get("elapsed_usec", -1) < 15000000)


def validate_case(row, fixture, locale):
    require(row["id"] == fixture["id"] and row["errors"] == [], "case identity/error differs")
    for key in ("id", "turn", "action", "index", "pressure", "ko", "en"):
        require(row["fixture"][key] == fixture[key], "fixture " + key + " differs")
    require(row["fixture"]["expected_background"] == fixture["background"]
            and row["fixture"]["expected_ambience"] == fixture["ambience"], "fixture location differs")
    for phase in ("preparation_before", "prepared_seeded", "ready_before", "after"):
        require(set(row[phase]) == {"game", "extra", "meta", "event"}, "snapshot owners differ")
        for value in row[phase].values():
            untyped(value)
    require(settled(row["ready_settled"]) and settled(row["settled"]), "typing/fade was not naturally settled")
    pressure = row["pressure"]
    require((pressure["id"], pressure["family"], pressure["person_id"], pressure["action_ids"])
            == (fixture["pressure"], fixture["family"], fixture["person"], fixture["actions"]), "actual pressure differs")
    cards = row["cards"]
    require(len(cards) == len(row["focus_trace"]) == len(row["taps"]) == 3, "three real cards/focus/taps required")
    require(len({card["instance_id"] for card in cards}) == len({card["path"] for card in cards}) == 3, "card identity duplicate")
    for index, card in enumerate(cards):
        require((card["index"], card["action"], card["disabled"], card["visible"])
                == (index, fixture["actions"][index], False, True) and card["focus_mode"] in (1, 2), "actual card differs")
        require(focused_card(row["focus_trace"][index], index, fixture, card), "native focus sequence differs")
        require(focused_card(row["taps"][index]["before"], index, fixture, card), "tap started on another control")
        if index < 2:
            require(focused_card(row["taps"][index]["after"], index + 1, fixture, cards[index + 1]), "Right did not reach next card")
    codes = [4194321, 4194321, 4194309]  # Godot KEY_RIGHT, KEY_RIGHT, KEY_ENTER.
    require([item["keycode"] for item in row["taps"]] == codes and len(row["raw_events"]) == 6, "raw/tap population differs")
    for index, event in enumerate(row["raw_events"]):
        require(event["keycode"] == event["physical_keycode"] == codes[index // 2]
                and event["pressed"] is (index % 2 == 0) and event["echo"] is False, "raw key edge differs")
        tap = row["taps"][index // 2]
        require(tap["started_usec"] <= event["ticks_usec"] <= tap["finished_usec"], "raw event outside its tap")
    require(len(row["pressed"]) == 1 and row["pressed"][0]["action"] == fixture["action"]
            and row["pressed"][0]["index"] == 2
            and row["taps"][-1]["started_usec"] <= row["pressed"][0]["ticks_usec"] <= row["taps"][-1]["finished_usec"],
            "real pressed signal is missing/duplicated/not inside Enter")
    require(row["boundary_pressed"] == [], "Enter leaked into result/next-week button")
    expected, receipt, body = expected_effects(row, fixture, locale)
    require(row["after"] == expected, "typed after differs from independent action model")
    require(row["receipt"] == receipt, "actual weekly receipt differs")
    signals = row["signals"]
    require([signal["name"] for signal in signals] == ["money_changed", "moral_tint_changed", "stats_changed", "weekly_commitment_finalized", "log_added"],
            "atomic signal population/order differs (including forbidden save/load/turn)")
    game = untyped(expected["game"])
    tint = game["moral_tint"]
    stage = 2 if tint >= 60 else 1 if tint >= 20 else -2 if tint <= -60 else -1 if tint <= -20 else 0
    args = [[game["money"]], [max(-1, min(1, tint / 100.0)), stage], [], [receipt], [game["action_log"][-1]]]
    require([untyped(signal["args"]) for signal in signals] == args, "atomic signal payload differs")
    require(row["body"]["parsed"] == body and row["body"]["visible_ratio"] == 1, "actual fully typed body differs")
    require(row["body"]["content_height"] <= row["body"]["rect"][3] + 1, "actual body overflows its label")
    surface = row["surface"]
    require(surface["background_id"] == fixture["background"] and surface["ambience"] == fixture["ambience"]
            and surface["texture"] == "res://assets/backgrounds/" + fixture["background"] + ".png"
            and surface["visible"] is True and surface["target_alpha"] > 0
            and abs(surface["alpha"] - surface["target_alpha"]) <= 0.02, "actual settled surface differs")


def validate_report(report, locale, storage):
    require(report["unit"] == UNIT and report["locale"] == locale and report["pass"] is True
            and report["failures"] == [] and report["isolation_before"] == report["isolation_after"] == storage, "report identity/isolation/failures differ")
    require(report["boundary_pressed"] == [], "aggregate result/next-week input leaked")
    require(len(report["cases"]) == 2, "case population differs")
    for row, fixture in zip(report["cases"], FIXTURES):
        validate_case(row, fixture, locale)
    for key, count in (("raw_events", 12), ("taps", 6), ("pressed", 2)):
        require(len(report[key]) == count and report[key] == [item for row in report["cases"] for item in row[key]], "aggregate " + key + " differs")
    require(report["receipts"] == [row["receipt"] for row in report["cases"]]
            and report["pngs"] == [row["png"] for row in report["cases"]] and len(set(report["pngs"])) == 2,
            "aggregate receipt/PNG population differs")


def log_errors(stdout, stderr, engine, locale, exit_code):
    errors = []
    if exit_code != 0:
        errors.append("engine exit is not zero")
    markers = [line for line in stdout.splitlines() if "ROUTINE_BACKGROUND_INPUT_CHECK_OK" in line]
    if markers != [expected_marker(locale)]:
        errors.append("exact success marker population differs")
    if not engine:
        errors.append("engine log is empty or missing")
    errors.extend("logged failure: " + line for line in (stdout + "\n" + stderr + "\n" + engine).splitlines()
                  if FAILURE.search(line))
    return errors


def png_pin(value, directory):
    path = Path(value)
    require(path.is_absolute() and path.parent.resolve() == directory.resolve()
            and path.suffix == ".png" and not path.is_symlink(), "PNG escapes fresh locale directory")
    record = pin(path)
    with path.open("rb") as stream:
        header = stream.read(24)
    require(header[:8] == b"\x89PNG\r\n\x1a\n" and header[12:16] == b"IHDR"
            and struct.unpack(">II", header[16:24]) == (1280, 800), "PNG size/signature differs")
    return record


def self_test():
    """Small in-memory controls; no project collector, old cases, process or file writes."""
    rows = []
    for fixture in FIXTURES:
        game = {"turn": fixture["turn"], "action_points": 1, "max_action_points": 1,
            "year": 2030, "month": 10 if fixture["action"] == "save" else 6, "week_of_month": 2,
            "mental": 80, "money": 100000000.0, "pending_weekly_commitment": {}, "weekly_commitments": [],
            "forgone_path_debts": {}, "action_axis_this_week": {"money": 0, "human": 0},
            "action_places_this_week": {}, "recent_action_places": [], "action_records_this_week": [],
            "tendency": {"career": 0, "invest": 0, "found": 0}, "tendency_evidence_version": 2,
            "flags": {}, "action_log": [], "moral_tint": 0.0, "untouched": {"sentinel": "keep"}}
        base = {"game": typed(game), "extra": typed({"pending_tint_vignette": {}, "pending_scar_vignette": "",
                "unlocked_stat_thresholds": {}, "turn_action_log": []}), "meta": typed({}), "event": typed({})}
        cards = [{"index": index, "action": action, "path": "/fixture/" + action, "instance_id": index + 1,
                  "disabled": False, "visible": True, "focus_mode": 2} for index, action in enumerate(fixture["actions"])]
        focus = [{**card, "valid": True, "owned": True, "button": True, "queued": False, "result_confirm": False} for card in cards]
        codes = [4194321, 4194321, 4194309]
        taps = [{"keycode": code, "before": focus[index], "after": focus[index + 1] if index < 2 else {},
                 "started_usec": index * 100, "finished_usec": index * 100 + 99} for index, code in enumerate(codes)]
        raw = [{"keycode": code, "physical_keycode": code, "pressed": down, "echo": False,
                "ticks_usec": index * 100 + 10 + edge} for index, code in enumerate(codes) for edge, down in enumerate((True, False))]
        save = fixture["action"] == "save"
        stable = {"typing": False, "fade": False, "commit": False, "milestone": False, "visible_ratio": 1, "elapsed_usec": 50000}
        row = {"id": fixture["id"], "fixture": {**fixture, "expected_background": fixture["background"], "expected_ambience": fixture["ambience"]},
               "preparation_before": copy.deepcopy(base), "prepared_seeded": copy.deepcopy(base), "ready_before": base,
               "ready_settled": stable, "settled": stable, "pressure": {"id": fixture["pressure"], "family": fixture["family"],
                   "person_id": fixture["person"], "action_ids": fixture["actions"]}, "cards": cards, "focus_trace": focus,
               "taps": taps, "raw_events": raw, "pressed": [{"action": fixture["action"], "index": 2, "ticks_usec": 220}],
               "roll": {"seed": 1, "draw1": 0 if save else 5, "draw2": 0 if save else -1, "saved": 30000 if save else 0, "index": fixture["index"]},
               "boundary_pressed": [], "errors": [], "png": "/synthetic/" + fixture["id"] + ".png"}
        row["after"], row["receipt"], body = expected_effects(row, fixture, "ko")
        after = untyped(row["after"]["game"])
        names = ["money_changed", "moral_tint_changed", "stats_changed", "weekly_commitment_finalized", "log_added"]
        args = [[after["money"]], [0.0, 0], [], [row["receipt"]], [after["action_log"][-1]]]
        row["signals"] = [{"name": name, "args": typed(value)} for name, value in zip(names, args)]
        row["body"] = {"parsed": body, "visible_ratio": 1, "content_height": 50, "rect": [0, 0, 700, 300]}
        row["surface"] = {"background_id": fixture["background"], "ambience": fixture["ambience"],
            "texture": "res://assets/backgrounds/" + fixture["background"] + ".png", "visible": True, "alpha": 0.4, "target_alpha": 0.4}
        rows.append(row)
    good = {"unit": UNIT, "locale": "ko", "pass": True, "failures": [], "boundary_pressed": [],
            "isolation_before": "/synthetic", "isolation_after": "/synthetic", "cases": rows,
            "receipts": [row["receipt"] for row in rows], "pngs": [row["png"] for row in rows]}
    for key in ("raw_events", "taps", "pressed"):
        good[key] = [item for row in rows for item in row[key]]
    validate_report(good, "ko", "/synthetic")
    mutations = (
        lambda value: value["cases"].pop(),
        lambda value: value["cases"][0]["raw_events"].pop(),
        lambda value: value["cases"][0]["pressed"].append(value["cases"][0]["pressed"][0]),
        lambda value: value["cases"][0]["boundary_pressed"].append({"kind": "result_confirm"}),
        lambda value: value["cases"][0]["after"]["game"]["value"]["turn"].update(value=231),
        lambda value: value["cases"][0]["after"]["game"]["value"]["untouched"]["value"]["sentinel"].update(value="changed"),
        lambda value: value["cases"][0]["ready_settled"].update(typing=True),
        lambda value: value["cases"][0]["roll"].update(saved=30001),
        lambda value: value["cases"][0]["focus_trace"][0].update(index=2),
        lambda value: value["cases"][0]["after"]["game"]["value"]["action_records_this_week"]["value"][-1]["value"]["families"].update(typed_builtin=0),
    )
    for mutation in mutations:
        bad = copy.deepcopy(good)
        mutation(bad)
        try:
            validate_report(bad, "ko", "/synthetic")
        except ValueError:
            continue
        raise AssertionError("synthetic report mutation was admitted")
    marker = expected_marker("ko")
    require(not log_errors(marker + "\n", "", "engine", "ko", 0), "good marker rejected")
    controls = ((marker + " extra\n", "", "engine", 0), (marker + "\n" + marker, "", "engine", 0),
                (marker, "SCRIPT ERROR: sentinel", "engine", 0), (marker, "", "ERROR: sentinel", 0), (marker, "", "engine", 1))
    for stdout, stderr, engine, code in controls:
        require(bool(log_errors(stdout, stderr, engine, "ko", code)), "bad log/exit admitted")
    print("ROUTINE_BACKGROUND_INPUT_RUNNER_SELF_TEST_OK cases=17 historical_cases=0")
    return 0


def run_locale(godot, locale, directory, timeout):
    directory.mkdir()
    screenshots = directory / "screenshots"
    screenshots.mkdir()
    parent = safe.user_data_parent()
    require(parent is not None, "unknown Godot userdata parent")
    namespace = safe.PREFIX + secrets.token_hex(16)
    storage = parent / namespace
    require(not os.path.lexists(storage), "refused existing QA namespace")
    report_path, engine_path = directory / "report.json", directory / "godot.log"
    command = [godot, "--path", str(ROOT), "--rendering-method", "gl_compatibility", "--max-fps", "60", "--resolution", "1280x800",
               "--audio-driver", "Dummy", "--quit-after", "14400", "--log-file", str(engine_path),
               "--script", "res://tools/StoryNameplateBootstrap.gd", "--scene", SCENE]
    env = os.environ.copy()
    env.update(STORY_NAMEPLATE_QA_NAMESPACE=namespace, ROUTINE_INPUT_LOCALE=locale,
               ROUTINE_INPUT_REPORT_PATH=str(report_path), ROUTINE_INPUT_SCREENSHOT_DIR=str(screenshots))
    result = {"locale": locale, "command": command, "storage": str(storage), "storage_retained": True,
              "errors": [], "exit": None, "exception": None, "pid": None}
    write_json(directory / "entry.json", result)
    stdout, stderr, proc, handlers = "", "", None, {}
    started = time.monotonic()
    try:
        handlers = safe.install_handlers()
        options = {"creationflags": subprocess.CREATE_NEW_PROCESS_GROUP} if os.name == "nt" else {"start_new_session": True}
        proc = subprocess.Popen(command, cwd=ROOT, env=env, stdout=subprocess.PIPE, stderr=subprocess.PIPE,
                                text=True, encoding="utf-8", errors="replace", **options)
        result["pid"] = proc.pid
        stdout, stderr = proc.communicate(timeout=timeout)
        safe.set_handlers(handlers, True)
        result["process_group_error"] = safe.kill_remaining_group(proc)
    except BaseException as exc:
        result["exception"] = repr(exc)
        if proc is not None:
            safe.set_handlers(handlers, True)
            stdout, stderr, result["process_group_error"] = safe.terminate_tree(proc)
    finally:
        safe.set_handlers(handlers, False)
        result.update(exit=proc.returncode if proc is not None else None, seconds=time.monotonic() - started)
        for name, value in (("stdout.log", stdout), ("stderr.log", stderr)):
            with (directory / name).open("x", encoding="utf-8") as stream:
                stream.write(value)
    engine = engine_path.read_text(errors="replace") if engine_path.is_file() else ""
    result["errors"].extend(log_errors(stdout, stderr, engine, locale, result["exit"]))
    if result["exception"] or result.get("process_group_error"):
        result["errors"].append("process did not finish cleanly")
    try:
        actual_storage, error = safe.validated_storage(stdout, storage)
        require(error is None and actual_storage == storage, error or "isolation marker differs")
        report = strict_json(report_path.read_text(encoding="utf-8"))
        validate_report(report, locale, str(storage))
        result["pngs"] = {value: png_pin(value, screenshots) for value in report["pngs"]}
        require(len(result["pngs"]) == 2, "PNG identity repeated")
        result["counts"] = {key: len(report[key]) for key in ("cases", "raw_events", "taps", "pressed", "receipts", "pngs")}
    except (OSError, ValueError, TypeError, KeyError, IndexError) as exc:
        result["errors"].append("report/artifact validation: " + str(exc))
    result["artifacts"] = {str(path.relative_to(directory)): pin(path) for path in sorted(directory.rglob("*"))
                           if path.is_file()}
    result["all_pass"] = not result["errors"]
    write_json(directory / "result.json", result)
    print(stdout, end="" if stdout.endswith("\n") else "\n", flush=True)
    if stderr:
        print(stderr, end="" if stderr.endswith("\n") else "\n", file=sys.stderr, flush=True)
    return result


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    mode = parser.add_mutually_exclusive_group(required=True)
    mode.add_argument("--run", action="store_true")
    mode.add_argument("--self-test", action="store_true")
    parser.add_argument("--expected-head")
    parser.add_argument("--label")
    parser.add_argument("--locale", choices=("all", "ko", "en"), default="all")
    parser.add_argument("--timeout", type=int, default=240)
    parser.add_argument("--godot", default=os.environ.get("GODOT"))
    args = parser.parse_args()
    if args.self_test:
        return self_test()
    if not re.fullmatch(r"[0-9a-f]{40}", args.expected_head or ""):
        parser.error("--run requires the exact full --expected-head")
    if not re.fullmatch(r"[a-z0-9][a-z0-9-]{0,48}", args.label or "") or not 1 <= args.timeout <= 600:
        parser.error("fresh simple --label and timeout1..600 required")
    godot = args.godot or shutil.which("godot") or shutil.which("godot4")
    if not godot:
        parser.error("Godot is required")
    evidence = ROOT / ".git/full-game-localization" / ("order456-" + args.label)
    evidence.mkdir(parents=True, exist_ok=False)
    result = {"unit": UNIT, "expected_head": args.expected_head, "errors": [], "runs": [],
              "claim": "Prepared legacy/internal GUI key delivery only; no natural-play/physical-input/release verdict."}
    print("ROUTINE_BACKGROUND_INPUT_EVIDENCE=" + str(evidence), flush=True)
    try:
        result["before"] = snapshot()
        write_json(evidence / "entry.json", result)
        require(result["before"]["head"] == args.expected_head and not result["before"]["status_hex"], "candidate is not exact clean HEAD")
        require(result["before"]["player"]["file_count"] == 34, "actual player34 population differs")
        for locale in (("ko", "en") if args.locale == "all" else (args.locale,)):
            row = run_locale(godot, locale, evidence / locale, args.timeout)
            result["runs"].append(row)
            if not row["all_pass"]:
                result["errors"].append(locale + " runtime failed; artifacts retained")
                break
    except BaseException as exc:
        result["errors"].append("runner failure: " + repr(exc))
    finally:
        try:
            result["after"] = snapshot()
            require(result.get("before") == result["after"], "candidate/input/player bytes or paths changed")
        except BaseException as exc:
            result["errors"].append("preservation failure: " + repr(exc))
        expected_runs = 2 if args.locale == "all" else 1
        result["all_pass"] = not result["errors"] and len(result["runs"]) == expected_runs
        result["expected_population"] = {"locales": expected_runs, "cases": 2 * expected_runs,
                                         "raw": 12 * expected_runs, "taps": 6 * expected_runs,
                                         "pressed": 2 * expected_runs, "receipts": 2 * expected_runs,
                                         "screenshots": 2 * expected_runs}
        write_json(evidence / "result.json", result)
    marker = "ROUTINE_BACKGROUND_INPUT_RUNNER_OK" if result["all_pass"] else "ROUTINE_BACKGROUND_INPUT_RUNNER_FAIL"
    print(marker + " " + json.dumps(result["expected_population"], sort_keys=True), flush=True)
    return 0 if result["all_pass"] else 1


if __name__ == "__main__":
    raise SystemExit(main())
