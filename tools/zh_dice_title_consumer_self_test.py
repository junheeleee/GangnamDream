#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""One finite Chinese validator/static-consumer regression; no collector/engine."""
from __future__ import annotations

import contextlib
import copy
import dataclasses
import hashlib
import io
import json
import traceback
import unittest
from pathlib import Path
from unittest.mock import patch

import ja_translation_pipeline as ja
import zh_translation_audit as zh

ROOT = Path(__file__).resolve().parents[1]
# Original25114 literal inputs + new252 route-OFF2; expectations pre-code.
# The private source corpus and baseline are provenance, never runtime inputs.
DIRECT = json.loads(r'''[
  {
    "id": "actual_cn",
    "kind": "normal",
    "locale": "zh-CN",
    "key": "ui:다이사이 15라운드 이상. 세 개의 주사위가 구르는 소리를 기억한다.:/다이사이 15라운드 이상. 세 개의 주사위가 구르는 소리를 기억한다.",
    "source": "다이사이 15라운드 이상. 세 개의 주사위가 구르는 소리를 기억한다.",
    "target": "骰宝玩过15轮以上。还记得三颗骰子滚动的声音。",
    "base": null,
    "expected_direct": "PASS",
    "independent_diagnostics_to_retain": []
  },
  {
    "id": "actual_tw",
    "kind": "normal",
    "locale": "zh-TW",
    "key": "ui:다이사이 15라운드 이상. 세 개의 주사위가 구르는 소리를 기억한다.:/다이사이 15라운드 이상. 세 개의 주사위가 구르는 소리를 기억한다.",
    "source": "다이사이 15라운드 이상. 세 개의 주사위가 구르는 소리를 기억한다.",
    "target": "骰寶玩了15局以上。還記得三顆骰子滾動的聲音。",
    "base": null,
    "expected_direct": "PASS",
    "independent_diagnostics_to_retain": []
  },
  {
    "id": "cn_dice_value4",
    "kind": "mutant",
    "locale": "zh-CN",
    "key": "ui:다이사이 15라운드 이상. 세 개의 주사위가 구르는 소리를 기억한다.:/다이사이 15라운드 이상. 세 개의 주사위가 구르는 소리를 기억한다.",
    "source": "다이사이 15라운드 이상. 세 개의 주사위가 구르는 소리를 기억한다.",
    "target": "骰宝玩过15轮以上。还记得四颗骰子滚动的声音。",
    "base": "actual_cn",
    "expected_direct": "REJECT",
    "independent_diagnostics_to_retain": []
  },
  {
    "id": "tw_round_dice_exchange",
    "kind": "mutant",
    "locale": "zh-TW",
    "key": "ui:다이사이 15라운드 이상. 세 개의 주사위가 구르는 소리를 기억한다.:/다이사이 15라운드 이상. 세 개의 주사위가 구르는 소리를 기억한다.",
    "source": "다이사이 15라운드 이상. 세 개의 주사위가 구르는 소리를 기억한다.",
    "target": "骰寶玩了3局以上。還記得十五顆骰子滾動的聲音。",
    "base": "actual_tw",
    "expected_direct": "REJECT",
    "independent_diagnostics_to_retain": []
  },
  {
    "id": "tw_chip_owner",
    "kind": "mutant",
    "locale": "zh-TW",
    "key": "ui:다이사이 15라운드 이상. 세 개의 주사위가 구르는 소리를 기억한다.:/다이사이 15라운드 이상. 세 개의 주사위가 구르는 소리를 기억한다.",
    "source": "다이사이 15라운드 이상. 세 개의 주사위가 구르는 소리를 기억한다.",
    "target": "骰寶玩了15局以上。還記得三顆籌碼滾動的聲音。",
    "base": "actual_tw",
    "expected_direct": "REJECT",
    "independent_diagnostics_to_retain": []
  },
  {
    "id": "tw_duplicate_dice_count",
    "kind": "mutant",
    "locale": "zh-TW",
    "key": "ui:다이사이 15라운드 이상. 세 개의 주사위가 구르는 소리를 기억한다.:/다이사이 15라운드 이상. 세 개의 주사위가 구르는 소리를 기억한다.",
    "source": "다이사이 15라운드 이상. 세 개의 주사위가 구르는 소리를 기억한다.",
    "target": "骰寶玩了15局以上。還記得三顆骰子、三顆骰子滾動的聲音。",
    "base": "actual_tw",
    "expected_direct": "REJECT",
    "independent_diagnostics_to_retain": []
  },
  {
    "id": "cn_missing_round_count",
    "kind": "mutant",
    "locale": "zh-CN",
    "key": "ui:다이사이 15라운드 이상. 세 개의 주사위가 구르는 소리를 기억한다.:/다이사이 15라운드 이상. 세 개의 주사위가 구르는 소리를 기억한다.",
    "source": "다이사이 15라운드 이상. 세 개의 주사위가 구르는 소리를 기억한다.",
    "target": "骰宝玩过。还记得三颗骰子滚动的声音。",
    "base": "actual_cn",
    "expected_direct": "REJECT",
    "independent_diagnostics_to_retain": []
  },
  {
    "id": "cn_newline_movement",
    "kind": "mutant",
    "locale": "zh-CN",
    "key": "ui:다이사이 15라운드 이상. 세 개의 주사위가 구르는 소리를 기억한다.:/다이사이 15라운드 이상. 세 개의 주사위가 구르는 소리를 기억한다.",
    "source": "다이사이 15라운드 이상. 세 개의 주사위가 구르는 소리를 기억한다.",
    "target": "骰宝玩过15轮以上。\n还记得三颗骰子滚动的声音。",
    "base": "actual_cn",
    "expected_direct": "REJECT",
    "independent_diagnostics_to_retain": [
      "newline mismatch 0 != 1"
    ]
  },
  {
    "id": "cn_added_money",
    "kind": "mutant",
    "locale": "zh-CN",
    "key": "ui:다이사이 15라운드 이상. 세 개의 주사위가 구르는 소리를 기억한다.:/다이사이 15라운드 이상. 세 개의 주사위가 구르는 소리를 기억한다.",
    "source": "다이사이 15라운드 이상. 세 개의 주사위가 구르는 소리를 기억한다.",
    "target": "骰宝玩过15轮以上。还记得三颗骰子滚动的声音。花了1韩元。",
    "base": "actual_cn",
    "expected_direct": "REJECT",
    "independent_diagnostics_to_retain": [
      "Korean-won values changed: [] != [Decimal('1')]",
      "translation invented a Korean-won label absent from source"
    ]
  },
  {
    "id": "tw_added_BBCode",
    "kind": "mutant",
    "locale": "zh-TW",
    "key": "ui:다이사이 15라운드 이상. 세 개의 주사위가 구르는 소리를 기억한다.:/다이사이 15라운드 이상. 세 개의 주사위가 구르는 소리를 기억한다.",
    "source": "다이사이 15라운드 이상. 세 개의 주사위가 구르는 소리를 기억한다.",
    "target": "骰寶玩了15局以上。還記得三顆骰子滾動的聲音。[b]",
    "base": "actual_tw",
    "expected_direct": "REJECT",
    "independent_diagnostics_to_retain": [
      "placeholder/BBCode mismatch"
    ]
  },
  {
    "id": "cn_traditional_classifier",
    "kind": "mutant",
    "locale": "zh-CN",
    "key": "ui:다이사이 15라운드 이상. 세 개의 주사위가 구르는 소리를 기억한다.:/다이사이 15라운드 이상. 세 개의 주사위가 구르는 소리를 기억한다.",
    "source": "다이사이 15라운드 이상. 세 개의 주사위가 구르는 소리를 기억한다.",
    "target": "骰宝玩过15轮以上。还记得三顆骰子滚动的声音。",
    "base": "actual_cn",
    "expected_direct": "REJECT",
    "independent_diagnostics_to_retain": [
      "regional script mismatch: characters='顆' belongs to zh-TW in this gate"
    ]
  },
  {
    "id": "tw_simplified_classifier",
    "kind": "mutant",
    "locale": "zh-TW",
    "key": "ui:다이사이 15라운드 이상. 세 개의 주사위가 구르는 소리를 기억한다.:/다이사이 15라운드 이상. 세 개의 주사위가 구르는 소리를 기억한다.",
    "source": "다이사이 15라운드 이상. 세 개의 주사위가 구르는 소리를 기억한다.",
    "target": "骰寶玩了15局以上。還記得三颗骰子滾動的聲音。",
    "base": "actual_tw",
    "expected_direct": "REJECT",
    "independent_diagnostics_to_retain": [
      "regional script mismatch: characters='颗' belongs to zh-CN in this gate"
    ]
  },
  {
    "id": "source_OFF",
    "kind": "OFF",
    "locale": "zh-CN",
    "key": "ui:다이사이 15라운드 이상. 세 개의 주사위가 구르는 소리를 기억한다.:/다이사이 15라운드 이상. 세 개의 주사위가 구르는 소리를 기억한다.",
    "source": "다이사이 15라운드 이상. 세 개의 주사위가 구르는 소리를 기억한다. ",
    "target": "骰宝玩过15轮以上。还记得三颗骰子滚动的声音。",
    "base": null,
    "expected_direct": "PRESERVE_BASELINE",
    "independent_diagnostics_to_retain": []
  },
  {
    "id": "unrelated_counter_OFF",
    "kind": "OFF",
    "locale": "zh-TW",
    "key": "ui:세 개의 주사위가 구른다.:/세 개의 주사위가 구른다.",
    "source": "세 개의 주사위가 구른다.",
    "target": "三顆骰子滾動。",
    "base": null,
    "expected_direct": "PRESERVE_BASELINE",
    "independent_diagnostics_to_retain": []
  },
  {
    "id": "owner_OFF_cn",
    "kind": "OFF",
    "locale": "zh-CN",
    "key": "ui:dice_title_wrong_owner:/다이사이 15라운드 이상. 세 개의 주사위가 구르는 소리를 기억한다.",
    "source": "다이사이 15라운드 이상. 세 개의 주사위가 구르는 소리를 기억한다.",
    "target": "骰宝玩过15轮以上。还记得三颗骰子滚动的声音。",
    "base": null,
    "expected_direct": "PRESERVE_BASELINE",
    "independent_diagnostics_to_retain": []
  },
  {
    "id": "locale_OFF_ja",
    "kind": "OFF",
    "locale": "ja",
    "key": "ui:다이사이 15라운드 이상. 세 개의 주사위가 구르는 소리를 기억한다.:/다이사이 15라운드 이상. 세 개의 주사위가 구르는 소리를 기억한다.",
    "source": "다이사이 15라운드 이상. 세 개의 주사위가 구르는 소리를 기억한다.",
    "target": "大小（タイサイ）を15ラウンド以上。3個のサイコロが転がる音を覚えている。",
    "base": null,
    "expected_direct": "PRESERVE_BASELINE",
    "independent_diagnostics_to_retain": []
  }
]''')
STATIC = json.loads(r'''[
  {
    "id": "static_actual_cn",
    "kind": "normal",
    "locale": "zh-CN",
    "direct_id": "actual_cn",
    "base": null,
    "override": {
      "다이사이 15라운드 이상. 세 개의 주사위가 구르는 소리를 기억한다.": "骰宝玩过15轮以上。还记得三颗骰子滚动的声音。"
    },
    "expected_counts": [
      1,
      1,
      0,
      0,
      0,
      0
    ],
    "expected_errors": [],
    "expected_validate_calls": 1,
    "expected_validation_key": "ui:다이사이 15라운드 이상. 세 개의 주사위가 구르는 소리를 기억한다.:/다이사이 15라운드 이상. 세 개의 주사위가 구르는 소리를 기억한다."
  },
  {
    "id": "static_actual_tw",
    "kind": "normal",
    "locale": "zh-TW",
    "direct_id": "actual_tw",
    "base": null,
    "override": {
      "다이사이 15라운드 이상. 세 개의 주사위가 구르는 소리를 기억한다.": "骰寶玩了15局以上。還記得三顆骰子滾動的聲音。"
    },
    "expected_counts": [
      1,
      1,
      0,
      0,
      0,
      0
    ],
    "expected_errors": [],
    "expected_validate_calls": 1,
    "expected_validation_key": "ui:다이사이 15라운드 이상. 세 개의 주사위가 구르는 소리를 기억한다.:/다이사이 15라운드 이상. 세 개의 주사위가 구르는 소리를 기억한다."
  },
  {
    "id": "static_foreign_script_tw",
    "kind": "mutant",
    "locale": "zh-TW",
    "direct_id": "tw_simplified_classifier",
    "base": "static_actual_tw",
    "override": {
      "다이사이 15라운드 이상. 세 개의 주사위가 구르는 소리를 기억한다.": "骰寶玩了15局以上。還記得三颗骰子滾動的聲音。"
    },
    "expected_counts": [
      1,
      1,
      0,
      0,
      0,
      0
    ],
    "expected_errors": [
      "zh-TW:ui::0924::8f82759e883c: regional script mismatch: characters='颗' belongs to zh-CN in this gate"
    ],
    "expected_validate_calls": 1,
    "expected_validation_key": "ui:다이사이 15라운드 이상. 세 개의 주사위가 구르는 소리를 기억한다.:/다이사이 15라운드 이상. 세 개의 주사위가 구르는 소리를 기억한다."
  },
  {
    "id": "static_unknown_owner_cn",
    "kind": "mutant",
    "locale": "zh-CN",
    "direct_id": "owner_OFF_cn",
    "base": "static_actual_cn",
    "override": {
      "dice_title_wrong_owner": "骰宝玩过15轮以上。还记得三颗骰子滚动的声音。"
    },
    "expected_counts": [
      0,
      1,
      0,
      0,
      0,
      0
    ],
    "expected_errors": [
      "zh-CN:ui: unknown source keys count=1 preview=['dice_title_wrong_owner']"
    ],
    "expected_validate_calls": 0,
    "expected_validation_key": null
  }
]''')
OFF_BASELINE = json.loads(r'''{
  "source_OFF": [
    "counter quantity missing/changed: expected (entity, 3), target candidates=[]"
  ],
  "unrelated_counter_OFF": [
    "counter quantity missing/changed: expected (entity, 3), target candidates=[]"
  ],
  "owner_OFF_cn": [
    "counter quantity missing/changed: expected (entity, 3), target candidates=[]"
  ],
  "locale_OFF_ja": [
    "unsupported Chinese locale 'ja'"
  ]
}''')
SOURCE_FIXTURE = json.loads(r'''{
  "runtime": {
    "merged_pairs": {}
  },
  "entry": {
    "key": "ui::0924::8f82759e883c",
    "source": "다이사이 15라운드 이상. 세 개의 주사위가 구르는 소리를 기억한다.",
    "context": "ORDER252 isolated actual MetaProgression dice title description",
    "context_id": "",
    "format_template": false
  },
  "inventory": {
    "calls": [],
    "legacy_entries": "one real-source Entry above",
    "legacy_blueprint": {
      "다이사이 15라운드 이상. 세 개의 주사위가 구르는 소리를 기억한다.": {
        "$entry": "ui::0924::8f82759e883c"
      }
    },
    "planned_context_entries": [],
    "planned_context_blueprint": {},
    "observed_context_entries": [],
    "observed_context_blueprint": {},
    "errors": [],
    "stats": {}
  },
  "story_exclusive_return": [
    {},
    []
  ],
  "strict": false,
  "raw_text_override": null,
  "patches_only": [
    "_static_ui_inventory returns the fixed one-entry source fixture",
    "_story_demo_exclusive_ui_pairs returns the fixed empty out-of-scope population"
  ],
  "validation_observer": "Optional forwarding wrapper may record actual validate_text inputs/returned errors and must call original function once, return unchanged and propagate exceptions; no fabricated return/diagnostic.",
  "raw_source_binding": "DaiSai exact source/current CN/TW values and alias were read from real MP/UI and original named result. Inventory is deliberately isolated, NOT live inventory coverage. No collector/build_scope.",
  "restore": "Scoped patches restored even on exceptions; _STATIC_UI_CACHE and validator/provider identities must remain unchanged."
}''')
INPUTS = (
    "tools/zh_translation_audit.py", "tools/zh_dice_title_consumer_self_test.py",
    "tools/full_game_localization.py", "tools/full_game_localization_self_test.py",
    "tools/ja_translation_pipeline.py", "autoloads/MetaProgression.gd",
    "locale/ui_zh-CN.json", "locale/ui_zh-TW.json",
    "tools/data/opencc_script_variants_1_3_1.json", "tools/data/LICENSE-OpenCC-2.0.txt",
)


def _capture(callback):
    out, err = io.StringIO(), io.StringIO()
    value, exception = None, None
    with contextlib.redirect_stdout(out), contextlib.redirect_stderr(err):
        try:
            value = callback()
        except Exception:
            exception = traceback.format_exc()
    return {"value": value, "exception": exception,
            "stdout": out.getvalue(), "stderr": err.getvalue()}


def _pins():
    result = {}
    for relative in INPUTS:
        raw = (ROOT / relative).read_bytes()
        result[relative] = {"bytes": len(raw), "sha256": hashlib.sha256(raw).hexdigest()}
    return result


def _error_list(value):
    return isinstance(value, list) and all(isinstance(error, str) for error in value)


class ChineseDiceConsumerTests(unittest.TestCase):
    def test_fixed_direct_and_static_consumers(self):
        before = _capture(_pins)
        original_validate = zh.validate_text
        original_inventory = zh._static_ui_inventory
        original_story = zh._story_demo_exclusive_ui_pairs
        original_cache = zh._STATIC_UI_CACHE
        direct_results, static_results = [], []
        for case in DIRECT:
            observed = _capture(lambda: original_validate(
                case["locale"], case["key"], case["source"], case["target"]))
            errors = observed["value"]
            checks = {"no_exception": observed["exception"] is None,
                      "error_list": _error_list(errors)}
            if case["expected_direct"] == "PASS":
                checks["direct_pass"] = errors == []
            elif case["expected_direct"] == "REJECT":
                checks["direct_reject"] = _error_list(errors) and bool(errors)
            else:
                checks["OFF_original_errors_exact"] = errors == OFF_BASELINE[case["id"]]
            checks["independent_original_diagnostics_retained"] = _error_list(errors) and all(
                error in errors for error in case["independent_diagnostics_to_retain"])
            direct_results.append({
                **case, "observed": observed, "checks": checks,
                "passed": all(checks.values())})

        fixture = copy.deepcopy(SOURCE_FIXTURE)
        entry = ja.Entry(**fixture["entry"])
        inventory = ja.UiInventory(
            calls=(), legacy_entries=(entry,),
            legacy_blueprint=copy.deepcopy(fixture["inventory"]["legacy_blueprint"]),
            planned_context_entries=(), planned_context_blueprint={},
            observed_context_entries=(), observed_context_blueprint={},
            errors=(), stats={})
        inventory_before = dataclasses.asdict(inventory)
        runtime = copy.deepcopy(fixture["runtime"])
        runtime_before = copy.deepcopy(runtime)
        # Source providers ONLY are narrowed to one frozen real-source row.
        # This is NOT a current whole-inventory or public-story coverage claim.
        for case in STATIC:
            trace = []
            def forwarding(lang, key, source, target):
                call = {"locale": lang, "key": key, "source": source, "target": target}
                try:
                    errors = original_validate(lang, key, source, target)
                except Exception:
                    call["exception"] = traceback.format_exc()
                    trace.append(call)
                    raise
                call["errors"] = errors
                call["exception"] = None
                trace.append(call)
                return errors

            override = copy.deepcopy(case["override"])
            override_before = copy.deepcopy(override)
            actual_normal = None
            if case["kind"] == "normal":
                actual_normal = _capture(lambda: json.loads(
                    (ROOT / ("locale/ui_" + case["locale"] + ".json")).read_bytes()).get(entry.source))
            with patch.object(zh, "_static_ui_inventory", return_value=inventory), \
                    patch.object(zh, "_story_demo_exclusive_ui_pairs",
                                 return_value=copy.deepcopy(fixture["story_exclusive_return"])), \
                    patch.object(zh, "validate_text", side_effect=forwarding):
                observed = _capture(lambda: zh.static_ui_coverage(
                    case["locale"], runtime, False, actual_override=override))
            value = observed["value"]
            shape = (isinstance(value, tuple) and len(value) == 7
                     and all(isinstance(count, int) for count in value[:6])
                     and _error_list(value[-1]))
            checks = {
                "no_exception": observed["exception"] is None,
                "counts_and_errors_shape": shape,
                "counts_exact": shape and list(value[:6]) == case["expected_counts"],
                "errors_exact": shape and value[-1] == case["expected_errors"],
                "actual_validate_call_count": len(trace) == case["expected_validate_calls"],
                "override_unchanged": override == override_before,
            }
            if case["expected_validate_calls"]:
                checks["original_validator_called_with_canonical_source_key"] = (
                    len(trace) == 1 and trace[0]["locale"] == case["locale"]
                    and trace[0]["key"] == case["expected_validation_key"]
                    and trace[0]["source"] == entry.source
                    and trace[0]["target"] == override_before[entry.source]
                    and trace[0]["exception"] is None)
                checks["actual_returned_errors_have_alias_only_for_display"] = (
                    shape and len(trace) == 1 and trace[0]["exception"] is None
                    and value[-1] == [
                        case["locale"] + ":" + entry.key + ": " + error
                        for error in trace[0]["errors"]])
            if actual_normal is not None:
                checks["actual_ui_normal_value_exact"] = (
                    actual_normal["exception"] is None
                    and actual_normal["value"] == override_before[entry.source])
            static_results.append({
                **case, "observed": observed, "actual_validate_trace": trace,
                "actual_normal_read": actual_normal,
                "checks": checks, "passed": all(checks.values())})
        restored = (
            zh.validate_text is original_validate and zh._static_ui_inventory is original_inventory
            and zh._story_demo_exclusive_ui_pairs is original_story
            and zh._STATIC_UI_CACHE is original_cache)
        fixture_unchanged = (
            dataclasses.asdict(inventory) == inventory_before and runtime == runtime_before
            and fixture == SOURCE_FIXTURE)
        for population in (direct_results, static_results):
            by_id = {row["id"]: row for row in population}
            for row in population:
                base = by_id.get(row["base"])
                same_direct_owner = ("source" not in row or (
                    base is not None and all(
                        base[key] == row[key] for key in ("locale", "key", "source"))))
                row["normal_base_passed"] = bool(
                    base and base["kind"] == "normal" and base["passed"] and same_direct_owner)
                row["valid_negative"] = (
                    row["kind"] == "mutant" and row["normal_base_passed"] and row["passed"])
                row["valid_result"] = row["passed"] and (
                    row["kind"] != "mutant" or row["normal_base_passed"])
        after = _capture(_pins)
        unchanged = (before["exception"] is None and after["exception"] is None
                     and before["value"] == after["value"])
        counts = {
            "direct": {kind: sum(row["kind"] == kind for row in direct_results)
                       for kind in ("normal", "mutant", "OFF")},
            "static": {kind: sum(row["kind"] == kind for row in static_results)
                       for kind in ("normal", "mutant")},
        }
        roster_ok = (
            len(direct_results) == 16 and len({row["id"] for row in direct_results}) == 16
            and len(static_results) == 4 and len({row["id"] for row in static_results}) == 4
            and counts == {"direct": {"normal": 2, "mutant": 10, "OFF": 4},
                           "static": {"normal": 2, "mutant": 2}}
            and set(OFF_BASELINE) == {row["id"] for row in DIRECT if row["kind"] == "OFF"})
        passed = (roster_ok and unchanged and restored and fixture_unchanged
                  and all(row["valid_result"] for row in direct_results + static_results))
        print("ZH_DICE_TITLE_CONSUMER_FIXED " + json.dumps({
            "provenance": {
                "spec_sha256": "8b3cdca8644c6b71679cb1cff68a8d92dc3290a918908559118863ca2b243b34",
                "original_direct_spec_sha256": "f12d4c388af002fe11224632449f1ed4ffcfbda89277470346617cc55428367e",
                "original_static_spec_sha256": "7ec805951635484f0f0ac0c11515fa95d6932652b359d010059aad8a3dab603a",
                "baseline_sha256": "58a5a5e393cc2234306d52cff3fba6e0f790a71a34e3b67b8dba134d13639275",
                "chronology": "Inputs/expected outcomes pre-code; OFF4 arrays separately observed in ROOT first baseline."},
            "direct": direct_results, "static": static_results, "counts": counts,
            "valid_negatives": {
                "direct": sum(row["valid_negative"] for row in direct_results),
                "static": sum(row["valid_negative"] for row in static_results)},
            "roster_ok": roster_ok, "providers_restored": restored,
            "fixture_unchanged": fixture_unchanged,
            "input_before": before, "input_after": after, "inputs_unchanged": unchanged,
            "execution_counts": {
                "explicit_direct_validate_text": len(direct_results),
                "isolated_static_ui_coverage": len(static_results),
                "static_forwarded_validate_text": sum(
                    len(row["actual_validate_trace"]) for row in static_results),
                "collector": 0, "build_scope": 0, "engine": 0},
            "limits": "Two finite populations, not20 gameplay cases or actual whole-liveUI coverage; no native/render/full-product GO.",
            "passed": passed,
        }, ensure_ascii=False), flush=True)
        # Complete both populations and preserve every result before assertions.
        for row in direct_results + static_results:
            with self.subTest(id=row["id"]):
                self.assertTrue(row["valid_result"], row)
        self.assertTrue(roster_ok, counts)
        self.assertTrue(unchanged, {"before": before, "after": after})
        self.assertTrue(restored)
        self.assertTrue(fixture_unchanged)


if __name__ == "__main__":
    unittest.main()
