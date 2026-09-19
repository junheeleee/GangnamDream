#!/usr/bin/env python3
"""ORDER262 finite current controls; old suites run separately in exact views."""
from __future__ import annotations

import base64
import contextlib
import copy
import hashlib
import importlib
import io
import json
from pathlib import Path
import sys
import traceback
from dataclasses import asdict, replace
from unittest.mock import patch

import main_game_locale_history as history
import ja_translation_pipeline as pipeline
import year5_reference_route_audit as year5
import chapter1_core_loop_v2_causal_ledger_check as chapter

ROOT = Path(__file__).resolve().parents[1]
MAIN = "scenes/MainGame.gd"
JA = "tools/ja_translation_pipeline.py"
HELPER = "tools/main_game_locale_history.py"
CI = "tools/ci_localization_reconciliation_self_test.py"
META = "tools/meta_title_locale_successor_self_test.py"
UI = "locale/ui_ja.json"
UI_PATHS = (UI, "locale/ui_zh-CN.json", "locale/ui_zh-TW.json")
DR = "autoloads/DataRegistry.gd"
PHASE = "APPLIED_SOURCE_BOUND"
PRECODE_SHA256 = "f8c5917b472c6b44d34ff00939f558946ede9f15e43daca53874a9abe6639b82"
# Independent values, never populated from the implementation under test.
BEFORE_LINE = '\t\t\titem_content.add_child(_wrap_label(_tr("선물 — 사람 메뉴에서 전달", "Gift — deliver from the People menu"), 13, "#c8a0d8"))\n'
AFTER_LINE = '\t\t\titem_content.add_child(_wrap_label(_tr("선물", "Gift"), 13, "#c8a0d8"))\n'
OLD_KO = "선물 — 사람 메뉴에서 전달"
OLD_UI_ROW = '  "선물 — 사람 메뉴에서 전달": "先物――人物メニューから送る",\n'
UI_ANCHOR = '  "선물": "贈り物",\n'
CAPTION = (MAIN, "_render_sidebars", "legacy", "선물", "Gift", "")
FALLBACK = (MAIN, "_gift_display_name", "legacy", "선물", "Gift", "")
CURRENT = {
    MAIN: "3f42b49c99c94310436661e44c3029d0335b0998d467a7582c8d3524acf55532",
    JA: "8bb536853809fa273587734215bfcb3d6a78b9bd4d4b941b595e2136e8ebec6c",
    HELPER: "f1ef7d55c029982f85f28681898c152344709dbbd63b87e6dabb5d350ed2a55e",
    CI: "3a4f5129fb1bc91bb7dcab21e9f214a0b986a90ee382ccbf701f2f66e3284192",
    META: "50012ad8773c113db1c7fa212af14b791cb770cf953a860bc7c48cd2d4269b1c",
}
PREVIOUS = {
    MAIN: "da046f2bdec4e652b98498c49db67b262ce13f5be5475cc719aa5f938e117445",
    JA: "3a2d791038a46dcf3442776f4703cd1398998590843b91904c2668425a7427f4",
    HELPER: "b37fe2bdb738bd163d132ffa3acf418829ad49888e7cb934a244389609407ad6",
    CI: "7ec161f1149dc201241ff153d409ca0c7b57a6233ed17d3582de4be9cae3fbee",
    META: "ca124901202f3464e3b69a684faa475894f561d390f38f710e4761b9bb39b4d1",
}
PRESERVED = {
    DR: "8887fd8a1c8becaef27e2638efea78218281786699546fda26695753d9978f7e",
    "autoloads/MetaProgression.gd": "6f49a1bdd83b3431b4146bbd2a94956c481bb371202606398167cdec8ae9f8b0",
    "autoloads/LocaleManager.gd": "9417e6b9e241e1d2b9ec7a7668cf4d19fe337ce6719d87e032020fe421ceec9a",
    "tools/meta_title_locale_successor.py": "1df50f967c6fea8711f8375f0c5db940499066d4a0e73f75652d2fc1b39aaf6c",
    "tools/chapter1_core_loop_v2_causal_ledger_check.py": "9e7522cd34f98bd9e54e3148e9f7825731b5b6081e31e33c5a0d8b8c273f959e",
    "tools/year5_reference_route_audit.py": "b4c34f559a458b4ad53ff19a0855d76176ec84083ba7b725f21a4f7aa6f50f82",
}
OFF_ERRORS = ["ORDER-243: locale history path is not the owned path",
              "ORDER-243: unapproved current MainGame source bytes"]
# Same 22 IDs/kinds/recipes as the pre-code plan; old suites/data are not copied.
CASES = (
    ("current_exact", "normal"),
    ("main_rollback", "raw"), ("main_extra_lf", "raw"), ("main_branch_change", "raw"),
    ("pipeline_rollback", "raw"), ("pipeline_extra_lf", "raw"),
    ("call_path", "semantic"), ("call_function", "semantic"), ("call_api", "semantic"),
    ("call_context", "semantic"), ("call_ko", "semantic"), ("call_en", "semantic"),
    ("call_missing", "semantic"), ("call_duplicate", "semantic"), ("shared_fallback_missing", "semantic"),
    ("registry_prior", "registry"), ("registry_inverse_missing", "registry"),
    ("registry_inverse_duplicate", "registry"), ("forged_bytes", "forged"),
    ("forged_hash", "forged"), ("wrong_claim", "claim"), ("off_dr", "OFF"),
)


def sha(raw):
    return hashlib.sha256(raw).hexdigest()


def canonical(value):
    return sha(json.dumps(value, ensure_ascii=False, sort_keys=True, separators=(",", ":")).encode())


def pins():
    return {p: {"bytes": len(raw), "sha256": sha(raw)} for p in
            sorted(set(CURRENT) | set(PRESERVED) | set(UI_PATHS) | {"tools/gift_caption_locale_self_test.py"})
            for raw in [(ROOT / p).read_bytes()]}


def once(raw, before, after):
    before, after = before.encode(), after.encode()
    if not before or raw.count(before) != 1:
        raise AssertionError("independent exact1 replacement")
    return raw.replace(before, after, 1)


def remove_span(raw, start, end):
    start, end = start.encode(), end.encode()
    if raw.count(start) != 1 or raw.count(end) != 1:
        raise AssertionError("independent span cardinality")
    a, z = raw.index(start), raw.index(end) + len(end)
    if a >= z:
        raise AssertionError("independent span order")
    return raw[:a] + raw[z:]


def prepare():
    if PHASE != "APPLIED_SOURCE_BOUND":
        raise AssertionError("ORDER262 source fixture is not authorized")
    current = {p: (ROOT / p).read_bytes() for p in (*CURRENT, *UI_PATHS)}
    for p, wanted in {**CURRENT, **PRESERVED}.items():
        if sha((ROOT / p).read_bytes()) != wanted:
            raise AssertionError("physical pin differs: " + p)
    # Whole UI bytes are observed before/after, not permanently pinned here.
    # This unit's exact dictionary delta belongs to its external preservation proof.
    for p, wanted in zip(UI_PATHS, ("贈り物", "礼物", "禮物")):
        table = json.loads(current[p])
        if table.get("선물") != wanted or OLD_KO in table:
            raise AssertionError("Gift literal/retired source dictionary contract: " + p)
    previous = {p: current[p] for p in CURRENT}
    previous[MAIN] = once(current[MAIN], AFTER_LINE, BEFORE_LINE)
    previous[JA] = remove_span(current[JA], "# BEGIN_GIFT_CAPTION_COLLECTOR_262\n", "# END_GIFT_CAPTION_COLLECTOR_262\n\n")
    previous[HELPER] = remove_span(current[HELPER], "\n# BEGIN_GIFT_CAPTION_HISTORY_262\n", "# END_GIFT_CAPTION_HISTORY_262\n")
    for p, tag, old_entry, new_entry in ((CI, "CI", "_inventory_main", "_gift_caption_ci_main"),
                                       (META, "META", "_inventory_meta_main", "_gift_caption_meta_main")):
        previous[p] = remove_span(current[p], f"# BEGIN_GIFT_CAPTION_{tag}_ENTRY_262\n", f"# END_GIFT_CAPTION_{tag}_ENTRY_262\n")
        previous[p] = once(previous[p], f"raise SystemExit({new_entry}())", f"raise SystemExit({old_entry}())")
    previous[UI] = once(current[UI], UI_ANCHOR, UI_ANCHOR + OLD_UI_ROW)
    if once(previous[UI], UI_ANCHOR + OLD_UI_ROW, UI_ANCHOR) != current[UI]:
        raise AssertionError("historical JA row view is not reversible")
    if {p: sha(previous[p]) for p in PREVIOUS} != PREVIOUS:
        raise AssertionError("independent whole predecessor inverse differs")
    return current, previous


@contextlib.contextmanager
def path_view(values, observation):
    views = {ROOT / p: raw for p, raw in values.items()}
    read0, text0 = Path.read_bytes, Path.read_text
    def read(path):
        return views[path] if path in views else read0(path)
    def text(path, *args, **kwargs):
        if path in views:
            return views[path].decode(kwargs.get("encoding") or (args[0] if args else None) or "utf-8",
                                      errors=kwargs.get("errors") or "strict")
        return text0(path, *args, **kwargs)
    try:
        with patch.object(Path, "read_bytes", read), patch.object(Path, "read_text", text):
            yield
    finally:
        observation["path_restored"] = Path.read_bytes is read0 and Path.read_text is text0


def selector(c):
    return c.path, c.function, c.api, c.korean, c.english, c.context_id


def live(path, raw):
    return {
        "year5": year5._order243_main_source_errors(path, raw, year5.ORDER156_SOURCE_FILE_TRANSITIONS[MAIN][1]),
        "chapter": chapter._order243_main_source_errors(path, raw, chapter.ORDER156_AUDITED_SOURCE_FILE_TRANSITIONS[MAIN][1]),
    }


def identity():
    return (Path.read_bytes, Path.read_text, history.main_game_history_source_errors,
            history.main_game_history_project_bytes, history.main_game_history_project_byte_hash,
            pipeline.collect_ui_inventory, pipeline._last11_meta_title_historical_checks,
            history.GIFT_CAPTION_TRANSITIONS, history._GIFT_CAPTION_REGISTRY_SHA256)


def probe(path, raw, claim):
    return {"one_source": history.gift_caption_source_errors(path, raw),
            "one_bytes": history.gift_caption_project_bytes(raw, path),
            "one_hash": history.gift_caption_project_byte_hash(claim, path, raw),
            "public_source": history.main_game_history_source_errors(path, raw),
            "public_bytes": history.main_game_history_project_bytes(raw, path),
            "public_hash": history.main_game_history_project_byte_hash(claim, path, raw)}


def normal(current, previous, collect):
    values = probe(MAIN, current[MAIN], sha(current[MAIN]))
    values["live"] = live(MAIN, current[MAIN])
    values["pipeline_source"] = history.gift_caption_source_errors(JA, current[JA])
    values["pipeline_bytes"] = history.gift_caption_project_bytes(current[JA], JA)
    values["pipeline_hash"] = history.gift_caption_project_byte_hash(sha(current[JA]), JA, current[JA])
    calls, parse_errors = pipeline.parse_ui_calls(MAIN, current[MAIN].decode("utf-8"))
    old_calls, semantic_errors = pipeline._gift_caption_predecessor_calls(calls)
    values.update(parse_errors=parse_errors, semantic_errors=semantic_errors,
                  caption_count=sum(selector(c) == CAPTION for c in calls),
                  fallback_count=sum(selector(c) == FALLBACK for c in calls),
                  previous_caption_count=sum(c.korean == OLD_KO for c in old_calls))
    good = (not values["one_source"] and values["one_bytes"] == previous[MAIN]
            and values["one_hash"] == PREVIOUS[MAIN] and not values["public_source"]
            and sha(values["public_bytes"]) == history.ORDER220_SHA256
            and values["public_hash"] == history.ORDER220_SHA256
            and all(not e for e in values["live"].values()) and not values["pipeline_source"]
            and values["pipeline_bytes"] == previous[JA] and values["pipeline_hash"] == PREVIOUS[JA]
            and not parse_errors and not semantic_errors
            and (values["caption_count"], values["fallback_count"], values["previous_caption_count"]) == (1, 1, 1))
    if collect:
        inventory = pipeline.collect_ui_inventory()
        calls = inventory.calls
        expected = {"source_calls":3456,"legacy_calls":3422,"legacy_api_calls":3366,"legacy_keys":2944,"collision_keys":104}
        values["collector"] = {"errors": list(inventory.errors), "stats": inventory.stats,
            "legacy_entries": len(inventory.legacy_entries), "old_key_present": OLD_KO in inventory.blueprint,
            "call_sha256": canonical([asdict(c) for c in calls]),
            "gift_calls": [asdict(c) for c in calls if c.korean in ("선물", OLD_KO)]}
        historical_calls, errors = pipeline._gift_caption_predecessor_calls(calls)
        values["collector"]["historical_key_count"] = len({c.korean for c in historical_calls})
        values["collector"]["historical_errors"] = errors
        good = (good and not inventory.errors and not errors and OLD_KO not in inventory.blueprint
                and all(inventory.stats.get(k) == v for k, v in expected.items())
                and len(inventory.legacy_entries) == 2944
                and len({c.korean for c in historical_calls}) == 2945
                and OLD_KO not in json.loads(current[UI]))
    return good, values, tuple(calls)


def json_values(value, refs):
    if isinstance(value, bytes):
        names = [name for name, raw in refs.items() if raw == value]
        result = {"bytes": len(value), "sha256": sha(value), "exact_raw_references": names}
        if not names:
            result["raw_base64"] = base64.b64encode(value).decode("ascii")
        return result
    if isinstance(value, dict):
        return {k: json_values(v, refs) for k, v in value.items()}
    if isinstance(value, (tuple, list)):
        return [json_values(v, refs) for v in value]
    return value


def run_case(case, current, previous, normal_calls):
    name, kind = case
    output, errors_out, values, restoration = io.StringIO(), io.StringIO(), {}, {}
    api0, passed, exception, calls = identity(), False, None, normal_calls
    path = JA if name.startswith("pipeline_") else (DR if kind == "OFF" else MAIN)
    raw = current[path] if path in current else (ROOT / path).read_bytes()
    if name.endswith("rollback"):
        raw = previous[path]
    elif name.endswith("extra_lf") or kind == "forged":
        raw += b"\n"
    elif name == "main_branch_change":
        raw = once(raw, '\t\telif str(item.get("category", "")) == "gift":\n',
                        '\t\telif str(item.get("category", "")) == "food":\n')
    claim = "0" * 64 if kind == "claim" else sha(raw)
    refs = {"INPUT":raw, "PREDECESSOR":previous.get(path, raw),
            "CURRENT_MAIN":current[MAIN], "PREVIOUS_PIPELINE":previous[JA]}
    old220 = history._GIFT_OLD_PROJECT_BYTES(previous[MAIN], MAIN)
    if sha(old220) == history.ORDER220_SHA256:
        refs["ORDER220"] = old220
    try:
        with contextlib.redirect_stdout(output), contextlib.redirect_stderr(errors_out), contextlib.ExitStack() as stack:
            if kind == "registry":
                registry = copy.deepcopy(history.GIFT_CAPTION_TRANSITIONS)
                if name == "registry_prior":
                    registry[MAIN]["previous_sha256"] = "ca0dd88c1aabd95f621f66a4213b23084de67b937ed9b9236483040d303b0e81"
                elif name == "registry_inverse_missing":
                    registry[MAIN]["inverses"] = []
                else:
                    registry[MAIN]["inverses"] *= 2
                stack.enter_context(patch.object(history, "GIFT_CAPTION_TRANSITIONS", registry))
                stack.enter_context(patch.object(history, "_GIFT_CAPTION_REGISTRY_SHA256", canonical(registry)))
                values["registry"] = registry
            stack.enter_context(path_view({path:raw}, restoration))
            if kind == "normal":
                passed, values, calls = normal(current, previous, True)
            elif kind == "semantic":
                changed = list(normal_calls)
                index = next(i for i, c in enumerate(changed) if selector(c) == CAPTION)
                fields = {"call_path":("path","scenes/Other.gd"), "call_function":("function","_gift_display_name"),
                    "call_api":("api","context"), "call_context":("context_id","ui.inventory.false_context"),
                    "call_ko":("korean","선물 안내"), "call_en":("english","Present")}
                if name in fields:
                    field, value = fields[name]
                    changed[index] = replace(changed[index], **{field:value})
                elif name == "call_missing":
                    changed.pop(index)
                elif name == "call_duplicate":
                    changed.append(changed[index])
                else:
                    changed = [c for c in changed if selector(c) != FALLBACK]
                result, errors = pipeline._gift_caption_predecessor_calls(changed)
                values = {"errors":errors, "identity":result == tuple(changed),
                    "input_calls_sha256":canonical([asdict(c) for c in changed]),
                    "changed_owner_calls":[asdict(c) for c in changed if c.function in ("_render_sidebars","_gift_display_name") and c.korean in ("선물",OLD_KO,"선물 안내")]}
                passed = bool(errors) and values["identity"]
            else:
                # Direct original observations precede every forged live scope.
                values.update(probe(path, raw, claim))
                if path == JA:
                    inventory = pipeline.collect_ui_inventory()
                    values["collector_errors"] = list(inventory.errors)
                    values["collector_calls"] = len(inventory.calls)
                    passed = (bool(values["one_source"]) and values["one_bytes"] == raw
                              and values["one_hash"] == claim and bool(inventory.errors) and not inventory.calls)
                else:
                    with contextlib.ExitStack() as forged:
                        if kind == "forged":
                            old220 = history._GIFT_OLD_PROJECT_BYTES(previous[MAIN], MAIN)
                            refs["ORDER220"] = old220
                            attr = "main_game_history_project_bytes" if name == "forged_bytes" else "main_game_history_project_byte_hash"
                            value = old220 if name == "forged_bytes" else history.ORDER220_SHA256
                            forged.enter_context(patch.object(history, attr, return_value=value))
                            values["spoofed_return"] = getattr(history, attr)(raw, path) if name == "forged_bytes" else getattr(history, attr)(claim,path,raw)
                        values["live"] = live(path, raw)
                    if kind == "claim":
                        passed = (not values["one_source"] and not values["public_source"]
                            and all(not e for e in values["live"].values()) and values["one_bytes"] == previous[MAIN]
                            and sha(values["public_bytes"]) == history.ORDER220_SHA256
                            and values["one_hash"] == claim and values["public_hash"] == claim)
                    elif kind == "OFF":
                        passed = (values["one_source"] == ["ORDER-262: gift caption path is not owned"]
                            and values["public_source"] == OFF_ERRORS and all(e == OFF_ERRORS for e in values["live"].values())
                            and values["one_bytes"] == raw and values["public_bytes"] == raw
                            and values["one_hash"] == claim and values["public_hash"] == claim)
                    else:
                        passed = (bool(values["one_source"]) and bool(values["public_source"])
                            and all(bool(e) for e in values["live"].values()) and values["one_bytes"] == raw
                            and values["public_bytes"] == raw and values["one_hash"] == claim and values["public_hash"] == claim)
    except Exception as error:
        exception = {"error": type(error).__name__ + ": " + str(error), "traceback":traceback.format_exc()}
    finally:
        restoration["callables_restored"] = identity() == api0
    return {"id":name,"kind":kind,"base":None if kind == "normal" else "current_exact",
            "input":{"path":path,"bytes":len(raw),"sha256":sha(raw),"claim":claim},
            "values":json_values(values, refs),"stdout":output.getvalue(),"stderr":errors_out.getvalue(),
            "exception":exception,"restoration":restoration,
            "passed":passed and exception is None and all(restoration.values())}, calls


@contextlib.contextmanager
def historical_view(previous, observation):
    """Restore reads and imported aliases even if an old suite raises."""
    api0 = identity()
    current_collect, current_checks = pipeline.collect_ui_inventory, pipeline._last11_meta_title_historical_checks
    aliases = []
    try:
        with contextlib.ExitStack() as stack:
            stack.enter_context(path_view(previous, observation))
            for attr, target in (("main_game_history_source_errors","_GIFT_OLD_SOURCE_ERRORS"),
                                 ("main_game_history_project_bytes","_GIFT_OLD_PROJECT_BYTES"),
                                 ("main_game_history_project_byte_hash","_GIFT_OLD_PROJECT_HASH")):
                def forwarding(*args, _target=target, **kwargs):
                    return getattr(history, _target)(*args, **kwargs)
                stack.enter_context(patch.object(history, attr, forwarding))
            # Only aliases of these exact two current function objects are replaced.
            for module in tuple(sys.modules.values()):
                if module is None or not str(getattr(module,"__file__","")).startswith(str(ROOT / "tools")):
                    continue
                for attr, value in tuple(vars(module).items()):
                    if value is current_collect or value is current_checks:
                        aliases.append((module,attr,value))
                        stack.enter_context(patch.object(module,attr,
                            pipeline._GIFT_OLD_COLLECT if value is current_collect else pipeline._GIFT_OLD_CHECKS))
            observation["imported_aliases"] = [m.__name__ + "." + a for m,a,_ in aliases]
            yield
    finally:
        observation["callables_restored"] = identity() == api0
        observation["imported_aliases_restored"] = all(getattr(m,a) is value for m,a,value in aliases)


def historical_main(function, kind):
    before, after, fatal, prerequisite, result = None, None, None, {}, {}
    output, errors, restoration = io.StringIO(), io.StringIO(), {}
    passed = False
    try:
        # Load the old CI's dependencies before taking the reversible alias view.
        # This imports definitions only; it does not run any suite.
        importlib.import_module("ci_localization_reconciliation_self_test")
        before = pins()
        current, previous = prepare()
        okay, values, _calls = normal(current, previous, False)
        prerequisite = {"passed":okay,"values":json_values(values,{"PREDECESSOR":previous[MAIN],"PREVIOUS_PIPELINE":previous[JA]})}
        if okay:
            with historical_view(previous, restoration), contextlib.redirect_stdout(output), contextlib.redirect_stderr(errors):
                code = function()
            parsed, end = json.JSONDecoder().raw_decode(output.getvalue())
            marker = output.getvalue()[end:].strip()
            marker_expected = ("INVENTORY_DISPLAY_SOURCE_SELF_TEST_OK current=25/25 historical20_28=True unchanged=True"
                if kind == "ci" else "INVENTORY_DISPLAY_META_HISTORY_SELF_TEST_OK normal=2 historical=True unchanged=True")
            result = {"exit":code,"marker":marker,"passed":parsed.get("passed") is True,
                      "logical_before":parsed.get("physical_input_before"),"logical_after":parsed.get("physical_input_after")}
            logical = result["logical_before"] == result["logical_after"] and all(
                result["logical_before"].get(p,{}).get("sha256") == PREVIOUS[p] for p in (MAIN,HELPER,CI,META,JA))
            result["logical_pins_exact"] = logical
            passed = code == 0 and result["passed"] and marker == marker_expected and logical and all(
                restoration.get(k) is True for k in ("path_restored","callables_restored","imported_aliases_restored"))
    except Exception as error:
        fatal = {"error":type(error).__name__ + ": " + str(error),"traceback":traceback.format_exc()}
    finally:
        after = pins()
    passed = passed and before == after and fatal is None and not errors.getvalue()
    print(json.dumps({"scope":"ORDER262 current prerequisite; separate pre262 " + kind + " history",
        "passed":passed,"normal_prerequisite":prerequisite,"historical":result,
        "stdout":output.getvalue(),"stderr":errors.getvalue(),"fatal":fatal,"restoration":restoration,
        "physical_before":before,"physical_after":after,"unchanged":before is not None and before == after,
        "execution_counts":{"new22":0,"normal_prerequisite":1,"collector":0,"historical_entry":int(bool(result))}},ensure_ascii=False,indent=2))
    print("GIFT_CAPTION_HISTORY_" + ("OK" if passed else "FAIL") + " kind=" + kind)
    return 0 if passed else 1


def supplemental_ui_views():
    """Three prepare-only memory fixtures; not translations or source cases."""
    results = []
    for p, options in ((UI, ("今回のお話", "今回の物語")),
            ("locale/ui_zh-CN.json", ("本次故事", "这段故事")),
            ("locale/ui_zh-TW.json", ("本次故事", "這段故事"))):
        before, api0 = pins(), identity()
        restoration, values, fatal = {}, {}, None
        old_value, new_value, existed = None, None, False
        out, err = io.StringIO(), io.StringIO()
        try:
            original = (ROOT / p).read_bytes()
            table = json.loads(original)
            existed, old_value = "이번 이야기" in table, table.get("이번 이야기")
            new_value = options[1] if old_value == options[0] else options[0]
            expected_table = dict(table)
            expected_table["이번 이야기"] = new_value
            changed = (json.dumps(expected_table, ensure_ascii=False, indent=2) + "\n").encode()
            if new_value == old_value or json.loads(changed) != expected_table:
                raise AssertionError("supplemental fixture changed another semantic row")
            with contextlib.redirect_stdout(out), contextlib.redirect_stderr(err), path_view({p:changed}, restoration):
                current, previous = prepare()
                recovered = once(previous[UI], UI_ANCHOR + OLD_UI_ROW, UI_ANCHOR)
                values = {"prepare_passed":True, "changed_input_sha256":sha(changed),
                    "observed_ui_sha256":sha(current[p]), "gift_literals":[json.loads(current[q]).get("선물") for q in UI_PATHS],
                    "retired_absent":all(OLD_KO not in json.loads(current[q]) for q in UI_PATHS),
                    "ja_row_recovery_exact":recovered == current[UI],
                    "code5_previous_exact":{q:sha(previous[q]) for q in PREVIOUS} == PREVIOUS}
        except Exception as error:
            fatal = {"error":type(error).__name__ + ": " + str(error),"traceback":traceback.format_exc()}
        after = pins()
        restoration["callables_restored"] = identity() == api0
        passed = (fatal is None and before == after and all(restoration.values())
            and values.get("prepare_passed") is True and values.get("retired_absent") is True
            and values.get("observed_ui_sha256") == values.get("changed_input_sha256")
            and values.get("ja_row_recovery_exact") is True and values.get("code5_previous_exact") is True
            and values.get("gift_literals") == ["贈り物","礼物","禮物"])
        results.append({"path":p,"fixture_key":"이번 이야기","fixture_english":"This Episode",
            "original_key_existed":existed,"old_value":old_value,"new_value":new_value,"values":values,"passed":passed,
            "stdout":out.getvalue(),"stderr":err.getvalue(),"exception":fatal,"restoration":restoration,
            "physical_before":before,"physical_after":after,"unchanged":before == after})
    return results


def main():
    before, after, fatal, results, calls = None, None, None, [], ()
    supplemental = []
    try:
        before = pins()
        current, previous = prepare()
        for case in CASES:
            row, observed = run_case(case,current,previous,calls)
            results.append(row)
            if case[1] == "normal":
                calls = observed
        supplemental = supplemental_ui_views()
    except Exception as error:
        fatal = {"error":type(error).__name__ + ": " + str(error),"traceback":traceback.format_exc()}
    finally:
        after = pins()
    normal_ok = bool(results and results[0]["passed"])
    for row in results:
        row["normal_base_passed"] = normal_ok
        row["valid_result"] = bool(row["passed"] and normal_ok)
    passed = (len(results) == 22 and all(r["valid_result"] for r in results) and before == after and fatal is None
              and len(supplemental) == 3 and all(r["passed"] for r in supplemental))
    print(json.dumps({"scope":"ORDER262 current22 only; no historical-suite/engine replay",
        "passed":passed,"precode_sha256":PRECODE_SHA256,"results":results,"fatal":fatal,
        "supplemental_ui3":supplemental,
        "physical_before":before,"physical_after":after,"unchanged":before is not None and before == after,
        "execution_counts":{"new_cases":len(results),"normal":int(normal_ok),
            "valid_negatives":sum(r["valid_result"] for r in results if r["kind"] in ("raw","semantic","registry","forged")),
            "claim":sum(r["valid_result"] for r in results if r["kind"] == "claim"),
            "OFF":sum(r["valid_result"] for r in results if r["kind"] == "OFF"),
            "supplemental_prepare_only":len(supplemental),"supplemental_collector":0,
            "historical_suites":0,"engine":0}},ensure_ascii=False,indent=2))
    print("GIFT_CAPTION_SOURCE_SELF_TEST_" + ("OK" if passed else "FAIL") + f" cases={len(results)} unchanged={before == after}")
    return 0 if passed else 1


if __name__ == "__main__":
    raise SystemExit(main())
