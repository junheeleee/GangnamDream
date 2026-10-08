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


# ORDER-485 is a separate opt-in corpus. Default unittest discovery remains
# the original ORDER-252 test only; neither old literals nor old functions change.
CASINO_GLOSSARY_ROSTER = json.loads(r'''{
  "cases": [
    {
      "base": null,
      "context": "double",
      "expected": "PASS",
      "id": "cn_double_normal",
      "key": "ui:첫 두 장 받은 후 배팅액을 2배로 늘리고 카드를 한 장만 더 받는 것. 합이 10·11일 때 유리.:/첫 두 장 받은 후 배팅액을 2배로 늘리고 카드를 한 장만 더 받는 것. 합이 10·11일 때 유리.",
      "kind": "normal",
      "locale": "zh-CN",
      "required": [],
      "source": "첫 두 장 받은 후 배팅액을 2배로 늘리고 카드를 한 장만 더 받는 것. 합이 10·11일 때 유리.",
      "static": true,
      "target": "拿到起手2张牌后，将投注额增加到2倍，并且只再拿1张牌。点数合计为10或11时有利。"
    },
    {
      "base": "cn_double_normal",
      "context": "double",
      "expected": "REJECT",
      "id": "cn_double_first_value",
      "key": "ui:첫 두 장 받은 후 배팅액을 2배로 늘리고 카드를 한 장만 더 받는 것. 합이 10·11일 때 유리.:/첫 두 장 받은 후 배팅액을 2배로 늘리고 카드를 한 장만 더 받는 것. 합이 10·11일 때 유리.",
      "kind": "mutant",
      "locale": "zh-CN",
      "required": [],
      "source": "첫 두 장 받은 후 배팅액을 2배로 늘리고 카드를 한 장만 더 받는 것. 합이 10·11일 때 유리.",
      "static": true,
      "target": "拿到起手3张牌后，将投注额增加到2倍，并且只再拿1张牌。点数合计为10或11时有利。"
    },
    {
      "base": "cn_double_normal",
      "context": "double",
      "expected": "REJECT",
      "id": "cn_double_first_missing",
      "key": "ui:첫 두 장 받은 후 배팅액을 2배로 늘리고 카드를 한 장만 더 받는 것. 합이 10·11일 때 유리.:/첫 두 장 받은 후 배팅액을 2배로 늘리고 카드를 한 장만 더 받는 것. 합이 10·11일 때 유리.",
      "kind": "mutant",
      "locale": "zh-CN",
      "required": [],
      "source": "첫 두 장 받은 후 배팅액을 2배로 늘리고 카드를 한 장만 더 받는 것. 합이 10·11일 때 유리.",
      "static": true,
      "target": "拿到起手张牌后，将投注额增加到2倍，并且只再拿1张牌。点数合计为10或11时有利。"
    },
    {
      "base": "cn_double_normal",
      "context": "double",
      "expected": "REJECT",
      "id": "cn_double_first_unit",
      "key": "ui:첫 두 장 받은 후 배팅액을 2배로 늘리고 카드를 한 장만 더 받는 것. 합이 10·11일 때 유리.:/첫 두 장 받은 후 배팅액을 2배로 늘리고 카드를 한 장만 더 받는 것. 합이 10·11일 때 유리.",
      "kind": "mutant",
      "locale": "zh-CN",
      "required": [],
      "source": "첫 두 장 받은 후 배팅액을 2배로 늘리고 카드를 한 장만 더 받는 것. 합이 10·11일 때 유리.",
      "static": true,
      "target": "拿到起手2天后，将投注额增加到2倍，并且只再拿1张牌。点数合计为10或11时有利。"
    },
    {
      "base": "cn_double_normal",
      "context": "double",
      "expected": "REJECT",
      "id": "cn_double_first_sign",
      "key": "ui:첫 두 장 받은 후 배팅액을 2배로 늘리고 카드를 한 장만 더 받는 것. 합이 10·11일 때 유리.:/첫 두 장 받은 후 배팅액을 2배로 늘리고 카드를 한 장만 더 받는 것. 합이 10·11일 때 유리.",
      "kind": "mutant",
      "locale": "zh-CN",
      "required": [],
      "source": "첫 두 장 받은 후 배팅액을 2배로 늘리고 카드를 한 장만 더 받는 것. 합이 10·11일 때 유리.",
      "static": true,
      "target": "拿到起手+2张牌后，将投注额增加到2倍，并且只再拿1张牌。点数合计为10或11时有利。"
    },
    {
      "base": "cn_double_normal",
      "context": "double",
      "expected": "REJECT",
      "id": "cn_double_multiplier_value",
      "key": "ui:첫 두 장 받은 후 배팅액을 2배로 늘리고 카드를 한 장만 더 받는 것. 합이 10·11일 때 유리.:/첫 두 장 받은 후 배팅액을 2배로 늘리고 카드를 한 장만 더 받는 것. 합이 10·11일 때 유리.",
      "kind": "mutant",
      "locale": "zh-CN",
      "required": [],
      "source": "첫 두 장 받은 후 배팅액을 2배로 늘리고 카드를 한 장만 더 받는 것. 합이 10·11일 때 유리.",
      "static": true,
      "target": "拿到起手2张牌后，将投注额增加到3倍，并且只再拿1张牌。点数合计为10或11时有利。"
    },
    {
      "base": "cn_double_normal",
      "context": "double",
      "expected": "REJECT",
      "id": "cn_double_multiplier_missing",
      "key": "ui:첫 두 장 받은 후 배팅액을 2배로 늘리고 카드를 한 장만 더 받는 것. 합이 10·11일 때 유리.:/첫 두 장 받은 후 배팅액을 2배로 늘리고 카드를 한 장만 더 받는 것. 합이 10·11일 때 유리.",
      "kind": "mutant",
      "locale": "zh-CN",
      "required": [],
      "source": "첫 두 장 받은 후 배팅액을 2배로 늘리고 카드를 한 장만 더 받는 것. 합이 10·11일 때 유리.",
      "static": true,
      "target": "拿到起手2张牌后，将投注额增加到倍，并且只再拿1张牌。点数合计为10或11时有利。"
    },
    {
      "base": "cn_double_normal",
      "context": "double",
      "expected": "REJECT",
      "id": "cn_double_multiplier_unit",
      "key": "ui:첫 두 장 받은 후 배팅액을 2배로 늘리고 카드를 한 장만 더 받는 것. 합이 10·11일 때 유리.:/첫 두 장 받은 후 배팅액을 2배로 늘리고 카드를 한 장만 더 받는 것. 합이 10·11일 때 유리.",
      "kind": "mutant",
      "locale": "zh-CN",
      "required": [],
      "source": "첫 두 장 받은 후 배팅액을 2배로 늘리고 카드를 한 장만 더 받는 것. 합이 10·11일 때 유리.",
      "static": true,
      "target": "拿到起手2张牌后，将投注额增加到2天，并且只再拿1张牌。点数合计为10或11时有利。"
    },
    {
      "base": "cn_double_normal",
      "context": "double",
      "expected": "REJECT",
      "id": "cn_double_multiplier_sign",
      "key": "ui:첫 두 장 받은 후 배팅액을 2배로 늘리고 카드를 한 장만 더 받는 것. 합이 10·11일 때 유리.:/첫 두 장 받은 후 배팅액을 2배로 늘리고 카드를 한 장만 더 받는 것. 합이 10·11일 때 유리.",
      "kind": "mutant",
      "locale": "zh-CN",
      "required": [],
      "source": "첫 두 장 받은 후 배팅액을 2배로 늘리고 카드를 한 장만 더 받는 것. 합이 10·11일 때 유리.",
      "static": true,
      "target": "拿到起手2张牌后，将投注额增加到-2倍，并且只再拿1张牌。点数合计为10或11时有利。"
    },
    {
      "base": "cn_double_normal",
      "context": "double",
      "expected": "REJECT",
      "id": "cn_double_additional_value",
      "key": "ui:첫 두 장 받은 후 배팅액을 2배로 늘리고 카드를 한 장만 더 받는 것. 합이 10·11일 때 유리.:/첫 두 장 받은 후 배팅액을 2배로 늘리고 카드를 한 장만 더 받는 것. 합이 10·11일 때 유리.",
      "kind": "mutant",
      "locale": "zh-CN",
      "required": [],
      "source": "첫 두 장 받은 후 배팅액을 2배로 늘리고 카드를 한 장만 더 받는 것. 합이 10·11일 때 유리.",
      "static": true,
      "target": "拿到起手2张牌后，将投注额增加到2倍，并且只再拿2张牌。点数合计为10或11时有利。"
    },
    {
      "base": "cn_double_normal",
      "context": "double",
      "expected": "REJECT",
      "id": "cn_double_additional_missing",
      "key": "ui:첫 두 장 받은 후 배팅액을 2배로 늘리고 카드를 한 장만 더 받는 것. 합이 10·11일 때 유리.:/첫 두 장 받은 후 배팅액을 2배로 늘리고 카드를 한 장만 더 받는 것. 합이 10·11일 때 유리.",
      "kind": "mutant",
      "locale": "zh-CN",
      "required": [],
      "source": "첫 두 장 받은 후 배팅액을 2배로 늘리고 카드를 한 장만 더 받는 것. 합이 10·11일 때 유리.",
      "static": true,
      "target": "拿到起手2张牌后，将投注额增加到2倍，并且只再拿张牌。点数合计为10或11时有利。"
    },
    {
      "base": "cn_double_normal",
      "context": "double",
      "expected": "REJECT",
      "id": "cn_double_additional_unit",
      "key": "ui:첫 두 장 받은 후 배팅액을 2배로 늘리고 카드를 한 장만 더 받는 것. 합이 10·11일 때 유리.:/첫 두 장 받은 후 배팅액을 2배로 늘리고 카드를 한 장만 더 받는 것. 합이 10·11일 때 유리.",
      "kind": "mutant",
      "locale": "zh-CN",
      "required": [],
      "source": "첫 두 장 받은 후 배팅액을 2배로 늘리고 카드를 한 장만 더 받는 것. 합이 10·11일 때 유리.",
      "static": true,
      "target": "拿到起手2张牌后，将投注额增加到2倍，并且只再拿1颗骰子。点数合计为10或11时有利。"
    },
    {
      "base": "cn_double_normal",
      "context": "double",
      "expected": "REJECT",
      "id": "cn_double_additional_sign",
      "key": "ui:첫 두 장 받은 후 배팅액을 2배로 늘리고 카드를 한 장만 더 받는 것. 합이 10·11일 때 유리.:/첫 두 장 받은 후 배팅액을 2배로 늘리고 카드를 한 장만 더 받는 것. 합이 10·11일 때 유리.",
      "kind": "mutant",
      "locale": "zh-CN",
      "required": [],
      "source": "첫 두 장 받은 후 배팅액을 2배로 늘리고 카드를 한 장만 더 받는 것. 합이 10·11일 때 유리.",
      "static": true,
      "target": "拿到起手2张牌后，将投注额增加到2倍，并且只再拿+1张牌。点数合计为10或11时有利。"
    },
    {
      "base": "cn_double_normal",
      "context": "double",
      "expected": "REJECT",
      "id": "cn_double_point10_value",
      "key": "ui:첫 두 장 받은 후 배팅액을 2배로 늘리고 카드를 한 장만 더 받는 것. 합이 10·11일 때 유리.:/첫 두 장 받은 후 배팅액을 2배로 늘리고 카드를 한 장만 더 받는 것. 합이 10·11일 때 유리.",
      "kind": "mutant",
      "locale": "zh-CN",
      "required": [],
      "source": "첫 두 장 받은 후 배팅액을 2배로 늘리고 카드를 한 장만 더 받는 것. 합이 10·11일 때 유리.",
      "static": true,
      "target": "拿到起手2张牌后，将投注额增加到2倍，并且只再拿1张牌。点数合计为9或11时有利。"
    },
    {
      "base": "cn_double_normal",
      "context": "double",
      "expected": "REJECT",
      "id": "cn_double_point11_value",
      "key": "ui:첫 두 장 받은 후 배팅액을 2배로 늘리고 카드를 한 장만 더 받는 것. 합이 10·11일 때 유리.:/첫 두 장 받은 후 배팅액을 2배로 늘리고 카드를 한 장만 더 받는 것. 합이 10·11일 때 유리.",
      "kind": "mutant",
      "locale": "zh-CN",
      "required": [],
      "source": "첫 두 장 받은 후 배팅액을 2배로 늘리고 카드를 한 장만 더 받는 것. 합이 10·11일 때 유리.",
      "static": true,
      "target": "拿到起手2张牌后，将投注额增加到2倍，并且只再拿1张牌。点数合计为10或12时有利。"
    },
    {
      "base": "cn_double_normal",
      "context": "double",
      "expected": "REJECT",
      "id": "cn_double_point_days",
      "key": "ui:첫 두 장 받은 후 배팅액을 2배로 늘리고 카드를 한 장만 더 받는 것. 합이 10·11일 때 유리.:/첫 두 장 받은 후 배팅액을 2배로 늘리고 카드를 한 장만 더 받는 것. 합이 10·11일 때 유리.",
      "kind": "mutant",
      "locale": "zh-CN",
      "required": [],
      "source": "첫 두 장 받은 후 배팅액을 2배로 늘리고 카드를 한 장만 더 받는 것. 합이 10·11일 때 유리.",
      "static": true,
      "target": "拿到起手2张牌后，将投注额增加到2倍，并且只再拿1张牌。点数合计为10或11天时有利。"
    },
    {
      "base": "cn_double_normal",
      "context": "double",
      "expected": "REJECT",
      "id": "cn_double_point_sign",
      "key": "ui:첫 두 장 받은 후 배팅액을 2배로 늘리고 카드를 한 장만 더 받는 것. 합이 10·11일 때 유리.:/첫 두 장 받은 후 배팅액을 2배로 늘리고 카드를 한 장만 더 받는 것. 합이 10·11일 때 유리.",
      "kind": "mutant",
      "locale": "zh-CN",
      "required": [],
      "source": "첫 두 장 받은 후 배팅액을 2배로 늘리고 카드를 한 장만 더 받는 것. 합이 10·11일 때 유리.",
      "static": true,
      "target": "拿到起手2张牌后，将投注额增加到2倍，并且只再拿1张牌。点数合计为+10或11时有利。"
    },
    {
      "base": "cn_double_normal",
      "context": "double",
      "expected": "REJECT",
      "id": "cn_double_point_percent",
      "key": "ui:첫 두 장 받은 후 배팅액을 2배로 늘리고 카드를 한 장만 더 받는 것. 합이 10·11일 때 유리.:/첫 두 장 받은 후 배팅액을 2배로 늘리고 카드를 한 장만 더 받는 것. 합이 10·11일 때 유리.",
      "kind": "mutant",
      "locale": "zh-CN",
      "required": [],
      "source": "첫 두 장 받은 후 배팅액을 2배로 늘리고 카드를 한 장만 더 받는 것. 합이 10·11일 때 유리.",
      "static": true,
      "target": "拿到起手2张牌后，将投注额增加到2倍，并且只再拿1张牌。点数合计为10或11%时有利。"
    },
    {
      "base": "cn_double_normal",
      "context": "double",
      "expected": "REJECT",
      "id": "cn_double_point_time",
      "key": "ui:첫 두 장 받은 후 배팅액을 2배로 늘리고 카드를 한 장만 더 받는 것. 합이 10·11일 때 유리.:/첫 두 장 받은 후 배팅액을 2배로 늘리고 카드를 한 장만 더 받는 것. 합이 10·11일 때 유리.",
      "kind": "mutant",
      "locale": "zh-CN",
      "required": [],
      "source": "첫 두 장 받은 후 배팅액을 2배로 늘리고 카드를 한 장만 더 받는 것. 합이 10·11일 때 유리.",
      "static": true,
      "target": "拿到起手2张牌后，将投注额增加到2倍，并且只再拿1张牌。点数合计为10或11:00时有利。"
    },
    {
      "base": "cn_double_normal",
      "context": "double",
      "expected": "REJECT",
      "id": "cn_double_point_decimal",
      "key": "ui:첫 두 장 받은 후 배팅액을 2배로 늘리고 카드를 한 장만 더 받는 것. 합이 10·11일 때 유리.:/첫 두 장 받은 후 배팅액을 2배로 늘리고 카드를 한 장만 더 받는 것. 합이 10·11일 때 유리.",
      "kind": "mutant",
      "locale": "zh-CN",
      "required": [],
      "source": "첫 두 장 받은 후 배팅액을 2배로 늘리고 카드를 한 장만 더 받는 것. 합이 10·11일 때 유리.",
      "static": true,
      "target": "拿到起手2张牌后，将投注额增加到2倍，并且只再拿1张牌。点数合计为10或11.5时有利。"
    },
    {
      "base": "cn_double_normal",
      "context": "double",
      "expected": "REJECT",
      "id": "cn_double_card_role_swap",
      "key": "ui:첫 두 장 받은 후 배팅액을 2배로 늘리고 카드를 한 장만 더 받는 것. 합이 10·11일 때 유리.:/첫 두 장 받은 후 배팅액을 2배로 늘리고 카드를 한 장만 더 받는 것. 합이 10·11일 때 유리.",
      "kind": "mutant",
      "locale": "zh-CN",
      "required": [],
      "source": "첫 두 장 받은 후 배팅액을 2배로 늘리고 카드를 한 장만 더 받는 것. 합이 10·11일 때 유리.",
      "static": true,
      "target": "拿到起手1张牌后，将投注额增加到2倍，并且只再拿2张牌。点数合计为10或11时有利。"
    },
    {
      "base": "cn_double_normal",
      "context": "double",
      "expected": "REJECT",
      "id": "cn_double_card_point_swap",
      "key": "ui:첫 두 장 받은 후 배팅액을 2배로 늘리고 카드를 한 장만 더 받는 것. 합이 10·11일 때 유리.:/첫 두 장 받은 후 배팅액을 2배로 늘리고 카드를 한 장만 더 받는 것. 합이 10·11일 때 유리.",
      "kind": "mutant",
      "locale": "zh-CN",
      "required": [],
      "source": "첫 두 장 받은 후 배팅액을 2배로 늘리고 카드를 한 장만 더 받는 것. 합이 10·11일 때 유리.",
      "static": true,
      "target": "拿到起手10张牌后，将投注额增加到2倍，并且只再拿1张牌。点数合计为2或11时有利。"
    },
    {
      "base": "cn_double_normal",
      "context": "double",
      "expected": "REJECT",
      "id": "cn_double_multiplier_card_swap",
      "key": "ui:첫 두 장 받은 후 배팅액을 2배로 늘리고 카드를 한 장만 더 받는 것. 합이 10·11일 때 유리.:/첫 두 장 받은 후 배팅액을 2배로 늘리고 카드를 한 장만 더 받는 것. 합이 10·11일 때 유리.",
      "kind": "mutant",
      "locale": "zh-CN",
      "required": [],
      "source": "첫 두 장 받은 후 배팅액을 2배로 늘리고 카드를 한 장만 더 받는 것. 합이 10·11일 때 유리.",
      "static": true,
      "target": "拿到起手2张牌后，将投注额增加到1倍，并且只再拿2张牌。点数合计为10或11时有利。"
    },
    {
      "base": "cn_double_normal",
      "context": "double",
      "expected": "REJECT",
      "id": "cn_double_duplicate_card",
      "key": "ui:첫 두 장 받은 후 배팅액을 2배로 늘리고 카드를 한 장만 더 받는 것. 합이 10·11일 때 유리.:/첫 두 장 받은 후 배팅액을 2배로 늘리고 카드를 한 장만 더 받는 것. 합이 10·11일 때 유리.",
      "kind": "mutant",
      "locale": "zh-CN",
      "required": [],
      "source": "첫 두 장 받은 후 배팅액을 2배로 늘리고 카드를 한 장만 더 받는 것. 합이 10·11일 때 유리.",
      "static": true,
      "target": "拿到起手2张牌后，将投注额增加到2倍，并且只再拿1张牌。点数合计为10或11时有利。再拿2张牌。"
    },
    {
      "base": "cn_double_normal",
      "context": "double",
      "expected": "REJECT",
      "id": "cn_double_duplicate_multiplier",
      "key": "ui:첫 두 장 받은 후 배팅액을 2배로 늘리고 카드를 한 장만 더 받는 것. 합이 10·11일 때 유리.:/첫 두 장 받은 후 배팅액을 2배로 늘리고 카드를 한 장만 더 받는 것. 합이 10·11일 때 유리.",
      "kind": "mutant",
      "locale": "zh-CN",
      "required": [],
      "source": "첫 두 장 받은 후 배팅액을 2배로 늘리고 카드를 한 장만 더 받는 것. 합이 10·11일 때 유리.",
      "static": true,
      "target": "拿到起手2张牌后，将投注额增加到2倍，并且只再拿1张牌。点数合计为10或11时有利。2倍。"
    },
    {
      "base": "cn_double_normal",
      "context": "double",
      "expected": "REJECT",
      "id": "cn_double_extra_number",
      "key": "ui:첫 두 장 받은 후 배팅액을 2배로 늘리고 카드를 한 장만 더 받는 것. 합이 10·11일 때 유리.:/첫 두 장 받은 후 배팅액을 2배로 늘리고 카드를 한 장만 더 받는 것. 합이 10·11일 때 유리.",
      "kind": "mutant",
      "locale": "zh-CN",
      "required": [],
      "source": "첫 두 장 받은 후 배팅액을 2배로 늘리고 카드를 한 장만 더 받는 것. 합이 10·11일 때 유리.",
      "static": true,
      "target": "拿到起手2张牌后，将投注额增加到2倍，并且只再拿1张牌。点数合计为10或11时有利。8。"
    },
    {
      "base": "cn_double_normal",
      "context": "double",
      "expected": "REJECT",
      "id": "cn_double_extra_native_number",
      "key": "ui:첫 두 장 받은 후 배팅액을 2배로 늘리고 카드를 한 장만 더 받는 것. 합이 10·11일 때 유리.:/첫 두 장 받은 후 배팅액을 2배로 늘리고 카드를 한 장만 더 받는 것. 합이 10·11일 때 유리.",
      "kind": "mutant",
      "locale": "zh-CN",
      "required": [],
      "source": "첫 두 장 받은 후 배팅액을 2배로 늘리고 카드를 한 장만 더 받는 것. 합이 10·11일 때 유리.",
      "static": true,
      "target": "拿到起手2张牌后，将投注额增加到2倍，并且只再拿1张牌。点数合计为10或11时有利。八。"
    },
    {
      "base": "cn_double_normal",
      "context": "double",
      "expected": "REJECT",
      "id": "cn_double_money",
      "key": "ui:첫 두 장 받은 후 배팅액을 2배로 늘리고 카드를 한 장만 더 받는 것. 합이 10·11일 때 유리.:/첫 두 장 받은 후 배팅액을 2배로 늘리고 카드를 한 장만 더 받는 것. 합이 10·11일 때 유리.",
      "kind": "mutant",
      "locale": "zh-CN",
      "required": [
        "translation invented a Korean-won label absent from source"
      ],
      "source": "첫 두 장 받은 후 배팅액을 2배로 늘리고 카드를 한 장만 더 받는 것. 합이 10·11일 때 유리.",
      "static": true,
      "target": "拿到起手2张牌后，将投注额增加到2倍，并且只再拿1张牌。点数合计为10或11时有利。1韩元。"
    },
    {
      "base": "cn_double_normal",
      "context": "double",
      "expected": "REJECT",
      "id": "cn_double_wrong_currency",
      "key": "ui:첫 두 장 받은 후 배팅액을 2배로 늘리고 카드를 한 장만 더 받는 것. 합이 10·11일 때 유리.:/첫 두 장 받은 후 배팅액을 2배로 늘리고 카드를 한 장만 더 받는 것. 합이 10·11일 때 유리.",
      "kind": "mutant",
      "locale": "zh-CN",
      "required": [
        "Korean won was relabeled as yen/yuan/Taiwan dollar"
      ],
      "source": "첫 두 장 받은 후 배팅액을 2배로 늘리고 카드를 한 장만 더 받는 것. 합이 10·11일 때 유리.",
      "static": true,
      "target": "拿到起手2张牌后，将投注额增加到2倍，并且只再拿1张牌。点数合计为10或11时有利。1日元。"
    },
    {
      "base": "cn_double_normal",
      "context": "double",
      "expected": "REJECT",
      "id": "cn_double_token",
      "key": "ui:첫 두 장 받은 후 배팅액을 2배로 늘리고 카드를 한 장만 더 받는 것. 합이 10·11일 때 유리.:/첫 두 장 받은 후 배팅액을 2배로 늘리고 카드를 한 장만 더 받는 것. 합이 10·11일 때 유리.",
      "kind": "mutant",
      "locale": "zh-CN",
      "required": [
        "placeholder/BBCode mismatch"
      ],
      "source": "첫 두 장 받은 후 배팅액을 2배로 늘리고 카드를 한 장만 더 받는 것. 합이 10·11일 때 유리.",
      "static": true,
      "target": "拿到起手2张牌后，将投注额增加到2倍，并且只再拿1张牌。点数合计为10或11时有利。%s"
    },
    {
      "base": "cn_double_normal",
      "context": "double",
      "expected": "REJECT",
      "id": "cn_double_bbcode",
      "key": "ui:첫 두 장 받은 후 배팅액을 2배로 늘리고 카드를 한 장만 더 받는 것. 합이 10·11일 때 유리.:/첫 두 장 받은 후 배팅액을 2배로 늘리고 카드를 한 장만 더 받는 것. 합이 10·11일 때 유리.",
      "kind": "mutant",
      "locale": "zh-CN",
      "required": [
        "placeholder/BBCode mismatch"
      ],
      "source": "첫 두 장 받은 후 배팅액을 2배로 늘리고 카드를 한 장만 더 받는 것. 합이 10·11일 때 유리.",
      "static": true,
      "target": "[b]拿到起手2张牌后，将投注额增加到2倍，并且只再拿1张牌。点数合计为10或11时有利。[/b]"
    },
    {
      "base": "cn_double_normal",
      "context": "double",
      "expected": "REJECT",
      "id": "cn_double_hangul",
      "key": "ui:첫 두 장 받은 후 배팅액을 2배로 늘리고 카드를 한 장만 더 받는 것. 합이 10·11일 때 유리.:/첫 두 장 받은 후 배팅액을 2배로 늘리고 카드를 한 장만 더 받는 것. 합이 10·11일 때 유리.",
      "kind": "mutant",
      "locale": "zh-CN",
      "required": [
        "Hangul remains"
      ],
      "source": "첫 두 장 받은 후 배팅액을 2배로 늘리고 카드를 한 장만 더 받는 것. 합이 10·11일 때 유리.",
      "static": true,
      "target": "拿到起手2张牌后，将投注额增加到2倍，并且只再拿1张牌。点数合计为10或11时有利。한글"
    },
    {
      "base": "cn_double_normal",
      "context": "double",
      "expected": "REJECT",
      "id": "cn_double_kana",
      "key": "ui:첫 두 장 받은 후 배팅액을 2배로 늘리고 카드를 한 장만 더 받는 것. 합이 10·11일 때 유리.:/첫 두 장 받은 후 배팅액을 2배로 늘리고 카드를 한 장만 더 받는 것. 합이 10·11일 때 유리.",
      "kind": "mutant",
      "locale": "zh-CN",
      "required": [
        "Japanese kana remains"
      ],
      "source": "첫 두 장 받은 후 배팅액을 2배로 늘리고 카드를 한 장만 더 받는 것. 합이 10·11일 때 유리.",
      "static": true,
      "target": "拿到起手2张牌后，将投注额增加到2倍，并且只再拿1张牌。点数合计为10或11时有利。かな"
    },
    {
      "base": "cn_double_normal",
      "context": "double",
      "expected": "REJECT",
      "id": "cn_double_newline",
      "key": "ui:첫 두 장 받은 후 배팅액을 2배로 늘리고 카드를 한 장만 더 받는 것. 합이 10·11일 때 유리.:/첫 두 장 받은 후 배팅액을 2배로 늘리고 카드를 한 장만 더 받는 것. 합이 10·11일 때 유리.",
      "kind": "mutant",
      "locale": "zh-CN",
      "required": [
        "newline mismatch 0 != 1"
      ],
      "source": "첫 두 장 받은 후 배팅액을 2배로 늘리고 카드를 한 장만 더 받는 것. 합이 10·11일 때 유리.",
      "static": true,
      "target": "拿到起手2张牌后，将投注额增加到2倍，并且只再拿1张牌。点数合计为10或11时有利。\n"
    },
    {
      "base": "cn_double_normal",
      "context": "double",
      "expected": "REJECT",
      "id": "cn_double_paragraph",
      "key": "ui:첫 두 장 받은 후 배팅액을 2배로 늘리고 카드를 한 장만 더 받는 것. 합이 10·11일 때 유리.:/첫 두 장 받은 후 배팅액을 2배로 늘리고 카드를 한 장만 더 받는 것. 합이 10·11일 때 유리.",
      "kind": "mutant",
      "locale": "zh-CN",
      "required": [
        "newline mismatch 0 != 2",
        "paragraph mismatch"
      ],
      "source": "첫 두 장 받은 후 배팅액을 2배로 늘리고 카드를 한 장만 더 받는 것. 합이 10·11일 때 유리.",
      "static": true,
      "target": "拿到起手2张牌后，将投注额增加到2倍，并且只再拿1张牌。点数合计为10或11时有利。\n\n"
    },
    {
      "base": "cn_double_normal",
      "context": "double",
      "expected": "REJECT",
      "id": "cn_double_script",
      "key": "ui:첫 두 장 받은 후 배팅액을 2배로 늘리고 카드를 한 장만 더 받는 것. 합이 10·11일 때 유리.:/첫 두 장 받은 후 배팅액을 2배로 늘리고 카드를 한 장만 더 받는 것. 합이 10·11일 때 유리.",
      "kind": "mutant",
      "locale": "zh-CN",
      "required": [
        "@script"
      ],
      "source": "첫 두 장 받은 후 배팅액을 2배로 늘리고 카드를 한 장만 더 받는 것. 합이 10·11일 때 유리.",
      "static": true,
      "target": "拿到起手2张牌后，将投注额增加到2倍，并且只再拿1张牌。点数合计为10或11时有利。顆"
    },
    {
      "base": "cn_double_normal",
      "context": "double",
      "expected": "REJECT",
      "id": "cn_double_english",
      "key": "ui:첫 두 장 받은 후 배팅액을 2배로 늘리고 카드를 한 장만 더 받는 것. 합이 10·11일 때 유리.:/첫 두 장 받은 후 배팅액을 2배로 늘리고 카드를 한 장만 더 받는 것. 합이 10·11일 때 유리.",
      "kind": "mutant",
      "locale": "zh-CN",
      "required": [
        "@english"
      ],
      "source": "첫 두 장 받은 후 배팅액을 2배로 늘리고 카드를 한 장만 더 받는 것. 합이 10·11일 때 유리.",
      "static": true,
      "target": "拿到起手2张牌后，将投注额增加到2倍，并且只再拿1张牌。点数合计为10或11时有利。 Please read this instruction."
    },
    {
      "base": "cn_double_normal",
      "context": "double",
      "expected": "ORIGINAL",
      "id": "cn_double_source_OFF",
      "key": "ui:첫 두 장 받은 후 배팅액을 2배로 늘리고 카드를 한 장만 더 받는 것. 합이 10·11일 때 유리.:/첫 두 장 받은 후 배팅액을 2배로 늘리고 카드를 한 장만 더 받는 것. 합이 10·11일 때 유리.",
      "kind": "OFF",
      "locale": "zh-CN",
      "required": [],
      "source": "첫 두 장 받은 후 배팅액을 2배로 늘리고 카드를 한 장만 더 받는 것. 합이 10·11일 때 유리. ",
      "static": true,
      "target": "拿到起手2张牌后，将投注额增加到2倍，并且只再拿1张牌。点数合计为10或11时有利。"
    },
    {
      "base": "cn_double_normal",
      "context": "double",
      "expected": "ORIGINAL",
      "id": "cn_double_owner_OFF",
      "key": "ui:foreign-owner:/첫 두 장 받은 후 배팅액을 2배로 늘리고 카드를 한 장만 더 받는 것. 합이 10·11일 때 유리.",
      "kind": "OFF",
      "locale": "zh-CN",
      "required": [],
      "source": "첫 두 장 받은 후 배팅액을 2배로 늘리고 카드를 한 장만 더 받는 것. 합이 10·11일 때 유리.",
      "static": false,
      "target": "拿到起手2张牌后，将投注额增加到2倍，并且只再拿1张牌。点数合计为10或11时有利。"
    },
    {
      "base": "cn_double_normal",
      "context": "double",
      "expected": "ORIGINAL",
      "id": "cn_double_pointer_OFF",
      "key": "ui:첫 두 장 받은 후 배팅액을 2배로 늘리고 카드를 한 장만 더 받는 것. 합이 10·11일 때 유리.:/첫 두 장 받은 후 배팅액을 2배로 늘리고 카드를 한 장만 더 받는 것. 합이 10·11일 때 유리.~wrong",
      "kind": "OFF",
      "locale": "zh-CN",
      "required": [],
      "source": "첫 두 장 받은 후 배팅액을 2배로 늘리고 카드를 한 장만 더 받는 것. 합이 10·11일 때 유리.",
      "static": false,
      "target": "拿到起手2张牌后，将投注额增加到2倍，并且只再拿1张牌。点数合计为10或11时有利。"
    },
    {
      "base": "cn_double_normal",
      "context": "double",
      "expected": "ORIGINAL",
      "id": "cn_double_unrelated_OFF",
      "key": "ui:세 개의 주사위가 구른다.:/세 개의 주사위가 구른다.",
      "kind": "OFF",
      "locale": "zh-CN",
      "required": [],
      "source": "세 개의 주사위가 구른다.",
      "static": true,
      "target": "拿到起手2张牌后，将投注额增加到2倍，并且只再拿1张牌。点数合计为10或11时有利。"
    },
    {
      "base": "cn_double_normal",
      "context": "double",
      "expected": "ORIGINAL",
      "id": "cn_double_locale_OFF",
      "key": "ui:첫 두 장 받은 후 배팅액을 2배로 늘리고 카드를 한 장만 더 받는 것. 합이 10·11일 때 유리.:/첫 두 장 받은 후 배팅액을 2배로 늘리고 카드를 한 장만 더 받는 것. 합이 10·11일 때 유리.",
      "kind": "OFF",
      "locale": "ja",
      "required": [],
      "source": "첫 두 장 받은 후 배팅액을 2배로 늘리고 카드를 한 장만 더 받는 것. 합이 10·11일 때 유리.",
      "static": false,
      "target": "拿到起手2张牌后，将投注额增加到2倍，并且只再拿1张牌。点数合计为10或11时有利。"
    },
    {
      "base": null,
      "context": "dice",
      "expected": "PASS",
      "id": "cn_dice_normal",
      "key": "ui:세 개의 주사위 결과에 거는 카지노 게임. 빅/스몰은 이해하기 쉽지만, 트리플이나 합계 베팅은 배당이 큰 만큼 확률이 낮다.:/세 개의 주사위 결과에 거는 카지노 게임. 빅~1스몰은 이해하기 쉽지만, 트리플이나 합계 베팅은 배당이 큰 만큼 확률이 낮다.",
      "kind": "normal",
      "locale": "zh-CN",
      "required": [],
      "source": "세 개의 주사위 결과에 거는 카지노 게임. 빅/스몰은 이해하기 쉽지만, 트리플이나 합계 베팅은 배당이 큰 만큼 확률이 낮다.",
      "static": true,
      "target": "对3颗骰子的结果下注的赌场游戏。大/小容易理解，但围骰或点数总和投注，赔率虽高，中奖概率也更低。"
    },
    {
      "base": "cn_dice_normal",
      "context": "dice",
      "expected": "REJECT",
      "id": "cn_dice_dice_value",
      "key": "ui:세 개의 주사위 결과에 거는 카지노 게임. 빅/스몰은 이해하기 쉽지만, 트리플이나 합계 베팅은 배당이 큰 만큼 확률이 낮다.:/세 개의 주사위 결과에 거는 카지노 게임. 빅~1스몰은 이해하기 쉽지만, 트리플이나 합계 베팅은 배당이 큰 만큼 확률이 낮다.",
      "kind": "mutant",
      "locale": "zh-CN",
      "required": [],
      "source": "세 개의 주사위 결과에 거는 카지노 게임. 빅/스몰은 이해하기 쉽지만, 트리플이나 합계 베팅은 배당이 큰 만큼 확률이 낮다.",
      "static": true,
      "target": "对4颗骰子的结果下注的赌场游戏。大/小容易理解，但围骰或点数总和投注，赔率虽高，中奖概率也更低。"
    },
    {
      "base": "cn_dice_normal",
      "context": "dice",
      "expected": "REJECT",
      "id": "cn_dice_dice_missing",
      "key": "ui:세 개의 주사위 결과에 거는 카지노 게임. 빅/스몰은 이해하기 쉽지만, 트리플이나 합계 베팅은 배당이 큰 만큼 확률이 낮다.:/세 개의 주사위 결과에 거는 카지노 게임. 빅~1스몰은 이해하기 쉽지만, 트리플이나 합계 베팅은 배당이 큰 만큼 확률이 낮다.",
      "kind": "mutant",
      "locale": "zh-CN",
      "required": [],
      "source": "세 개의 주사위 결과에 거는 카지노 게임. 빅/스몰은 이해하기 쉽지만, 트리플이나 합계 베팅은 배당이 큰 만큼 확률이 낮다.",
      "static": true,
      "target": "对颗骰子的结果下注的赌场游戏。大/小容易理解，但围骰或点数总和投注，赔率虽高，中奖概率也更低。"
    },
    {
      "base": "cn_dice_normal",
      "context": "dice",
      "expected": "REJECT",
      "id": "cn_dice_dice_cards",
      "key": "ui:세 개의 주사위 결과에 거는 카지노 게임. 빅/스몰은 이해하기 쉽지만, 트리플이나 합계 베팅은 배당이 큰 만큼 확률이 낮다.:/세 개의 주사위 결과에 거는 카지노 게임. 빅~1스몰은 이해하기 쉽지만, 트리플이나 합계 베팅은 배당이 큰 만큼 확률이 낮다.",
      "kind": "mutant",
      "locale": "zh-CN",
      "required": [],
      "source": "세 개의 주사위 결과에 거는 카지노 게임. 빅/스몰은 이해하기 쉽지만, 트리플이나 합계 베팅은 배당이 큰 만큼 확률이 낮다.",
      "static": true,
      "target": "对3张牌的结果下注的赌场游戏。大/小容易理解，但围骰或点数总和投注，赔率虽高，中奖概率也更低。"
    },
    {
      "base": "cn_dice_normal",
      "context": "dice",
      "expected": "REJECT",
      "id": "cn_dice_dice_chips",
      "key": "ui:세 개의 주사위 결과에 거는 카지노 게임. 빅/스몰은 이해하기 쉽지만, 트리플이나 합계 베팅은 배당이 큰 만큼 확률이 낮다.:/세 개의 주사위 결과에 거는 카지노 게임. 빅~1스몰은 이해하기 쉽지만, 트리플이나 합계 베팅은 배당이 큰 만큼 확률이 낮다.",
      "kind": "mutant",
      "locale": "zh-CN",
      "required": [],
      "source": "세 개의 주사위 결과에 거는 카지노 게임. 빅/스몰은 이해하기 쉽지만, 트리플이나 합계 베팅은 배당이 큰 만큼 확률이 낮다.",
      "static": true,
      "target": "对3枚筹码的结果下注的赌场游戏。大/小容易理解，但围骰或点数总和投注，赔率虽高，中奖概率也更低。"
    },
    {
      "base": "cn_dice_normal",
      "context": "dice",
      "expected": "REJECT",
      "id": "cn_dice_dice_sign_plus",
      "key": "ui:세 개의 주사위 결과에 거는 카지노 게임. 빅/스몰은 이해하기 쉽지만, 트리플이나 합계 베팅은 배당이 큰 만큼 확률이 낮다.:/세 개의 주사위 결과에 거는 카지노 게임. 빅~1스몰은 이해하기 쉽지만, 트리플이나 합계 베팅은 배당이 큰 만큼 확률이 낮다.",
      "kind": "mutant",
      "locale": "zh-CN",
      "required": [],
      "source": "세 개의 주사위 결과에 거는 카지노 게임. 빅/스몰은 이해하기 쉽지만, 트리플이나 합계 베팅은 배당이 큰 만큼 확률이 낮다.",
      "static": true,
      "target": "对+3颗骰子的结果下注的赌场游戏。大/小容易理解，但围骰或点数总和投注，赔率虽高，中奖概率也更低。"
    },
    {
      "base": "cn_dice_normal",
      "context": "dice",
      "expected": "REJECT",
      "id": "cn_dice_dice_sign_minus",
      "key": "ui:세 개의 주사위 결과에 거는 카지노 게임. 빅/스몰은 이해하기 쉽지만, 트리플이나 합계 베팅은 배당이 큰 만큼 확률이 낮다.:/세 개의 주사위 결과에 거는 카지노 게임. 빅~1스몰은 이해하기 쉽지만, 트리플이나 합계 베팅은 배당이 큰 만큼 확률이 낮다.",
      "kind": "mutant",
      "locale": "zh-CN",
      "required": [],
      "source": "세 개의 주사위 결과에 거는 카지노 게임. 빅/스몰은 이해하기 쉽지만, 트리플이나 합계 베팅은 배당이 큰 만큼 확률이 낮다.",
      "static": true,
      "target": "对-3颗骰子的结果下注的赌场游戏。大/小容易理解，但围骰或点数总和投注，赔率虽高，中奖概率也更低。"
    },
    {
      "base": "cn_dice_normal",
      "context": "dice",
      "expected": "REJECT",
      "id": "cn_dice_dice_decimal",
      "key": "ui:세 개의 주사위 결과에 거는 카지노 게임. 빅/스몰은 이해하기 쉽지만, 트리플이나 합계 베팅은 배당이 큰 만큼 확률이 낮다.:/세 개의 주사위 결과에 거는 카지노 게임. 빅~1스몰은 이해하기 쉽지만, 트리플이나 합계 베팅은 배당이 큰 만큼 확률이 낮다.",
      "kind": "mutant",
      "locale": "zh-CN",
      "required": [],
      "source": "세 개의 주사위 결과에 거는 카지노 게임. 빅/스몰은 이해하기 쉽지만, 트리플이나 합계 베팅은 배당이 큰 만큼 확률이 낮다.",
      "static": true,
      "target": "对3.5颗骰子的结果下注的赌场游戏。大/小容易理解，但围骰或点数总和投注，赔率虽高，中奖概率也更低。"
    },
    {
      "base": "cn_dice_normal",
      "context": "dice",
      "expected": "REJECT",
      "id": "cn_dice_dice_percent",
      "key": "ui:세 개의 주사위 결과에 거는 카지노 게임. 빅/스몰은 이해하기 쉽지만, 트리플이나 합계 베팅은 배당이 큰 만큼 확률이 낮다.:/세 개의 주사위 결과에 거는 카지노 게임. 빅~1스몰은 이해하기 쉽지만, 트리플이나 합계 베팅은 배당이 큰 만큼 확률이 낮다.",
      "kind": "mutant",
      "locale": "zh-CN",
      "required": [],
      "source": "세 개의 주사위 결과에 거는 카지노 게임. 빅/스몰은 이해하기 쉽지만, 트리플이나 합계 베팅은 배당이 큰 만큼 확률이 낮다.",
      "static": true,
      "target": "对3%颗骰子的结果下注的赌场游戏。大/小容易理解，但围骰或点数总和投注，赔率虽高，中奖概率也更低。"
    },
    {
      "base": "cn_dice_normal",
      "context": "dice",
      "expected": "REJECT",
      "id": "cn_dice_dice_time",
      "key": "ui:세 개의 주사위 결과에 거는 카지노 게임. 빅/스몰은 이해하기 쉽지만, 트리플이나 합계 베팅은 배당이 큰 만큼 확률이 낮다.:/세 개의 주사위 결과에 거는 카지노 게임. 빅~1스몰은 이해하기 쉽지만, 트리플이나 합계 베팅은 배당이 큰 만큼 확률이 낮다.",
      "kind": "mutant",
      "locale": "zh-CN",
      "required": [],
      "source": "세 개의 주사위 결과에 거는 카지노 게임. 빅/스몰은 이해하기 쉽지만, 트리플이나 합계 베팅은 배당이 큰 만큼 확률이 낮다.",
      "static": true,
      "target": "对3:00颗骰子的结果下注的赌场游戏。大/小容易理解，但围骰或点数总和投注，赔率虽高，中奖概率也更低。"
    },
    {
      "base": "cn_dice_normal",
      "context": "dice",
      "expected": "REJECT",
      "id": "cn_dice_dice_days",
      "key": "ui:세 개의 주사위 결과에 거는 카지노 게임. 빅/스몰은 이해하기 쉽지만, 트리플이나 합계 베팅은 배당이 큰 만큼 확률이 낮다.:/세 개의 주사위 결과에 거는 카지노 게임. 빅~1스몰은 이해하기 쉽지만, 트리플이나 합계 베팅은 배당이 큰 만큼 확률이 낮다.",
      "kind": "mutant",
      "locale": "zh-CN",
      "required": [],
      "source": "세 개의 주사위 결과에 거는 카지노 게임. 빅/스몰은 이해하기 쉽지만, 트리플이나 합계 베팅은 배당이 큰 만큼 확률이 낮다.",
      "static": true,
      "target": "对3天的结果下注的赌场游戏。大/小容易理解，但围骰或点数总和投注，赔率虽高，中奖概率也更低。"
    },
    {
      "base": "cn_dice_normal",
      "context": "dice",
      "expected": "REJECT",
      "id": "cn_dice_duplicate_dice",
      "key": "ui:세 개의 주사위 결과에 거는 카지노 게임. 빅/스몰은 이해하기 쉽지만, 트리플이나 합계 베팅은 배당이 큰 만큼 확률이 낮다.:/세 개의 주사위 결과에 거는 카지노 게임. 빅~1스몰은 이해하기 쉽지만, 트리플이나 합계 베팅은 배당이 큰 만큼 확률이 낮다.",
      "kind": "mutant",
      "locale": "zh-CN",
      "required": [],
      "source": "세 개의 주사위 결과에 거는 카지노 게임. 빅/스몰은 이해하기 쉽지만, 트리플이나 합계 베팅은 배당이 큰 만큼 확률이 낮다.",
      "static": true,
      "target": "对3颗骰子的结果下注的赌场游戏。大/小容易理解，但围骰或点数总和投注，赔率虽高，中奖概率也更低。3颗骰子。"
    },
    {
      "base": "cn_dice_normal",
      "context": "dice",
      "expected": "REJECT",
      "id": "cn_dice_extra_number",
      "key": "ui:세 개의 주사위 결과에 거는 카지노 게임. 빅/스몰은 이해하기 쉽지만, 트리플이나 합계 베팅은 배당이 큰 만큼 확률이 낮다.:/세 개의 주사위 결과에 거는 카지노 게임. 빅~1스몰은 이해하기 쉽지만, 트리플이나 합계 베팅은 배당이 큰 만큼 확률이 낮다.",
      "kind": "mutant",
      "locale": "zh-CN",
      "required": [],
      "source": "세 개의 주사위 결과에 거는 카지노 게임. 빅/스몰은 이해하기 쉽지만, 트리플이나 합계 베팅은 배당이 큰 만큼 확률이 낮다.",
      "static": true,
      "target": "对3颗骰子的结果下注的赌场游戏。大/小容易理解，但围骰或点数总和投注，赔率虽高，中奖概率也更低。8。"
    },
    {
      "base": "cn_dice_normal",
      "context": "dice",
      "expected": "REJECT",
      "id": "cn_dice_extra_native_number",
      "key": "ui:세 개의 주사위 결과에 거는 카지노 게임. 빅/스몰은 이해하기 쉽지만, 트리플이나 합계 베팅은 배당이 큰 만큼 확률이 낮다.:/세 개의 주사위 결과에 거는 카지노 게임. 빅~1스몰은 이해하기 쉽지만, 트리플이나 합계 베팅은 배당이 큰 만큼 확률이 낮다.",
      "kind": "mutant",
      "locale": "zh-CN",
      "required": [],
      "source": "세 개의 주사위 결과에 거는 카지노 게임. 빅/스몰은 이해하기 쉽지만, 트리플이나 합계 베팅은 배당이 큰 만큼 확률이 낮다.",
      "static": true,
      "target": "对3颗骰子的结果下注的赌场游戏。大/小容易理解，但围骰或点数总和投注，赔率虽高，中奖概率也更低。八。"
    },
    {
      "base": "cn_dice_normal",
      "context": "dice",
      "expected": "REJECT",
      "id": "cn_dice_money",
      "key": "ui:세 개의 주사위 결과에 거는 카지노 게임. 빅/스몰은 이해하기 쉽지만, 트리플이나 합계 베팅은 배당이 큰 만큼 확률이 낮다.:/세 개의 주사위 결과에 거는 카지노 게임. 빅~1스몰은 이해하기 쉽지만, 트리플이나 합계 베팅은 배당이 큰 만큼 확률이 낮다.",
      "kind": "mutant",
      "locale": "zh-CN",
      "required": [
        "translation invented a Korean-won label absent from source"
      ],
      "source": "세 개의 주사위 결과에 거는 카지노 게임. 빅/스몰은 이해하기 쉽지만, 트리플이나 합계 베팅은 배당이 큰 만큼 확률이 낮다.",
      "static": true,
      "target": "对3颗骰子的结果下注的赌场游戏。大/小容易理解，但围骰或点数总和投注，赔率虽高，中奖概率也更低。1韩元。"
    },
    {
      "base": "cn_dice_normal",
      "context": "dice",
      "expected": "REJECT",
      "id": "cn_dice_wrong_currency",
      "key": "ui:세 개의 주사위 결과에 거는 카지노 게임. 빅/스몰은 이해하기 쉽지만, 트리플이나 합계 베팅은 배당이 큰 만큼 확률이 낮다.:/세 개의 주사위 결과에 거는 카지노 게임. 빅~1스몰은 이해하기 쉽지만, 트리플이나 합계 베팅은 배당이 큰 만큼 확률이 낮다.",
      "kind": "mutant",
      "locale": "zh-CN",
      "required": [
        "Korean won was relabeled as yen/yuan/Taiwan dollar"
      ],
      "source": "세 개의 주사위 결과에 거는 카지노 게임. 빅/스몰은 이해하기 쉽지만, 트리플이나 합계 베팅은 배당이 큰 만큼 확률이 낮다.",
      "static": true,
      "target": "对3颗骰子的结果下注的赌场游戏。大/小容易理解，但围骰或点数总和投注，赔率虽高，中奖概率也更低。1日元。"
    },
    {
      "base": "cn_dice_normal",
      "context": "dice",
      "expected": "REJECT",
      "id": "cn_dice_token",
      "key": "ui:세 개의 주사위 결과에 거는 카지노 게임. 빅/스몰은 이해하기 쉽지만, 트리플이나 합계 베팅은 배당이 큰 만큼 확률이 낮다.:/세 개의 주사위 결과에 거는 카지노 게임. 빅~1스몰은 이해하기 쉽지만, 트리플이나 합계 베팅은 배당이 큰 만큼 확률이 낮다.",
      "kind": "mutant",
      "locale": "zh-CN",
      "required": [
        "placeholder/BBCode mismatch"
      ],
      "source": "세 개의 주사위 결과에 거는 카지노 게임. 빅/스몰은 이해하기 쉽지만, 트리플이나 합계 베팅은 배당이 큰 만큼 확률이 낮다.",
      "static": true,
      "target": "对3颗骰子的结果下注的赌场游戏。大/小容易理解，但围骰或点数总和投注，赔率虽高，中奖概率也更低。%s"
    },
    {
      "base": "cn_dice_normal",
      "context": "dice",
      "expected": "REJECT",
      "id": "cn_dice_bbcode",
      "key": "ui:세 개의 주사위 결과에 거는 카지노 게임. 빅/스몰은 이해하기 쉽지만, 트리플이나 합계 베팅은 배당이 큰 만큼 확률이 낮다.:/세 개의 주사위 결과에 거는 카지노 게임. 빅~1스몰은 이해하기 쉽지만, 트리플이나 합계 베팅은 배당이 큰 만큼 확률이 낮다.",
      "kind": "mutant",
      "locale": "zh-CN",
      "required": [
        "placeholder/BBCode mismatch"
      ],
      "source": "세 개의 주사위 결과에 거는 카지노 게임. 빅/스몰은 이해하기 쉽지만, 트리플이나 합계 베팅은 배당이 큰 만큼 확률이 낮다.",
      "static": true,
      "target": "[b]对3颗骰子的结果下注的赌场游戏。大/小容易理解，但围骰或点数总和投注，赔率虽高，中奖概率也更低。[/b]"
    },
    {
      "base": "cn_dice_normal",
      "context": "dice",
      "expected": "REJECT",
      "id": "cn_dice_hangul",
      "key": "ui:세 개의 주사위 결과에 거는 카지노 게임. 빅/스몰은 이해하기 쉽지만, 트리플이나 합계 베팅은 배당이 큰 만큼 확률이 낮다.:/세 개의 주사위 결과에 거는 카지노 게임. 빅~1스몰은 이해하기 쉽지만, 트리플이나 합계 베팅은 배당이 큰 만큼 확률이 낮다.",
      "kind": "mutant",
      "locale": "zh-CN",
      "required": [
        "Hangul remains"
      ],
      "source": "세 개의 주사위 결과에 거는 카지노 게임. 빅/스몰은 이해하기 쉽지만, 트리플이나 합계 베팅은 배당이 큰 만큼 확률이 낮다.",
      "static": true,
      "target": "对3颗骰子的结果下注的赌场游戏。大/小容易理解，但围骰或点数总和投注，赔率虽高，中奖概率也更低。한글"
    },
    {
      "base": "cn_dice_normal",
      "context": "dice",
      "expected": "REJECT",
      "id": "cn_dice_kana",
      "key": "ui:세 개의 주사위 결과에 거는 카지노 게임. 빅/스몰은 이해하기 쉽지만, 트리플이나 합계 베팅은 배당이 큰 만큼 확률이 낮다.:/세 개의 주사위 결과에 거는 카지노 게임. 빅~1스몰은 이해하기 쉽지만, 트리플이나 합계 베팅은 배당이 큰 만큼 확률이 낮다.",
      "kind": "mutant",
      "locale": "zh-CN",
      "required": [
        "Japanese kana remains"
      ],
      "source": "세 개의 주사위 결과에 거는 카지노 게임. 빅/스몰은 이해하기 쉽지만, 트리플이나 합계 베팅은 배당이 큰 만큼 확률이 낮다.",
      "static": true,
      "target": "对3颗骰子的结果下注的赌场游戏。大/小容易理解，但围骰或点数总和投注，赔率虽高，中奖概率也更低。かな"
    },
    {
      "base": "cn_dice_normal",
      "context": "dice",
      "expected": "REJECT",
      "id": "cn_dice_newline",
      "key": "ui:세 개의 주사위 결과에 거는 카지노 게임. 빅/스몰은 이해하기 쉽지만, 트리플이나 합계 베팅은 배당이 큰 만큼 확률이 낮다.:/세 개의 주사위 결과에 거는 카지노 게임. 빅~1스몰은 이해하기 쉽지만, 트리플이나 합계 베팅은 배당이 큰 만큼 확률이 낮다.",
      "kind": "mutant",
      "locale": "zh-CN",
      "required": [
        "newline mismatch 0 != 1"
      ],
      "source": "세 개의 주사위 결과에 거는 카지노 게임. 빅/스몰은 이해하기 쉽지만, 트리플이나 합계 베팅은 배당이 큰 만큼 확률이 낮다.",
      "static": true,
      "target": "对3颗骰子的结果下注的赌场游戏。大/小容易理解，但围骰或点数总和投注，赔率虽高，中奖概率也更低。\n"
    },
    {
      "base": "cn_dice_normal",
      "context": "dice",
      "expected": "REJECT",
      "id": "cn_dice_paragraph",
      "key": "ui:세 개의 주사위 결과에 거는 카지노 게임. 빅/스몰은 이해하기 쉽지만, 트리플이나 합계 베팅은 배당이 큰 만큼 확률이 낮다.:/세 개의 주사위 결과에 거는 카지노 게임. 빅~1스몰은 이해하기 쉽지만, 트리플이나 합계 베팅은 배당이 큰 만큼 확률이 낮다.",
      "kind": "mutant",
      "locale": "zh-CN",
      "required": [
        "newline mismatch 0 != 2",
        "paragraph mismatch"
      ],
      "source": "세 개의 주사위 결과에 거는 카지노 게임. 빅/스몰은 이해하기 쉽지만, 트리플이나 합계 베팅은 배당이 큰 만큼 확률이 낮다.",
      "static": true,
      "target": "对3颗骰子的结果下注的赌场游戏。大/小容易理解，但围骰或点数总和投注，赔率虽高，中奖概率也更低。\n\n"
    },
    {
      "base": "cn_dice_normal",
      "context": "dice",
      "expected": "REJECT",
      "id": "cn_dice_script",
      "key": "ui:세 개의 주사위 결과에 거는 카지노 게임. 빅/스몰은 이해하기 쉽지만, 트리플이나 합계 베팅은 배당이 큰 만큼 확률이 낮다.:/세 개의 주사위 결과에 거는 카지노 게임. 빅~1스몰은 이해하기 쉽지만, 트리플이나 합계 베팅은 배당이 큰 만큼 확률이 낮다.",
      "kind": "mutant",
      "locale": "zh-CN",
      "required": [
        "@script"
      ],
      "source": "세 개의 주사위 결과에 거는 카지노 게임. 빅/스몰은 이해하기 쉽지만, 트리플이나 합계 베팅은 배당이 큰 만큼 확률이 낮다.",
      "static": true,
      "target": "对3颗骰子的结果下注的赌场游戏。大/小容易理解，但围骰或点数总和投注，赔率虽高，中奖概率也更低。顆"
    },
    {
      "base": "cn_dice_normal",
      "context": "dice",
      "expected": "REJECT",
      "id": "cn_dice_english",
      "key": "ui:세 개의 주사위 결과에 거는 카지노 게임. 빅/스몰은 이해하기 쉽지만, 트리플이나 합계 베팅은 배당이 큰 만큼 확률이 낮다.:/세 개의 주사위 결과에 거는 카지노 게임. 빅~1스몰은 이해하기 쉽지만, 트리플이나 합계 베팅은 배당이 큰 만큼 확률이 낮다.",
      "kind": "mutant",
      "locale": "zh-CN",
      "required": [
        "@english"
      ],
      "source": "세 개의 주사위 결과에 거는 카지노 게임. 빅/스몰은 이해하기 쉽지만, 트리플이나 합계 베팅은 배당이 큰 만큼 확률이 낮다.",
      "static": true,
      "target": "对3颗骰子的结果下注的赌场游戏。大/小容易理解，但围骰或点数总和投注，赔率虽高，中奖概率也更低。 Please read this instruction."
    },
    {
      "base": "cn_dice_normal",
      "context": "dice",
      "expected": "ORIGINAL",
      "id": "cn_dice_source_OFF",
      "key": "ui:세 개의 주사위 결과에 거는 카지노 게임. 빅/스몰은 이해하기 쉽지만, 트리플이나 합계 베팅은 배당이 큰 만큼 확률이 낮다.:/세 개의 주사위 결과에 거는 카지노 게임. 빅~1스몰은 이해하기 쉽지만, 트리플이나 합계 베팅은 배당이 큰 만큼 확률이 낮다.",
      "kind": "OFF",
      "locale": "zh-CN",
      "required": [],
      "source": "세 개의 주사위 결과에 거는 카지노 게임. 빅/스몰은 이해하기 쉽지만, 트리플이나 합계 베팅은 배당이 큰 만큼 확률이 낮다. ",
      "static": true,
      "target": "对3颗骰子的结果下注的赌场游戏。大/小容易理解，但围骰或点数总和投注，赔率虽高，中奖概率也更低。"
    },
    {
      "base": "cn_dice_normal",
      "context": "dice",
      "expected": "ORIGINAL",
      "id": "cn_dice_owner_OFF",
      "key": "ui:foreign-owner:/세 개의 주사위 결과에 거는 카지노 게임. 빅~1스몰은 이해하기 쉽지만, 트리플이나 합계 베팅은 배당이 큰 만큼 확률이 낮다.",
      "kind": "OFF",
      "locale": "zh-CN",
      "required": [],
      "source": "세 개의 주사위 결과에 거는 카지노 게임. 빅/스몰은 이해하기 쉽지만, 트리플이나 합계 베팅은 배당이 큰 만큼 확률이 낮다.",
      "static": false,
      "target": "对3颗骰子的结果下注的赌场游戏。大/小容易理解，但围骰或点数总和投注，赔率虽高，中奖概率也更低。"
    },
    {
      "base": "cn_dice_normal",
      "context": "dice",
      "expected": "ORIGINAL",
      "id": "cn_dice_pointer_OFF",
      "key": "ui:세 개의 주사위 결과에 거는 카지노 게임. 빅/스몰은 이해하기 쉽지만, 트리플이나 합계 베팅은 배당이 큰 만큼 확률이 낮다.:/세 개의 주사위 결과에 거는 카지노 게임. 빅~1스몰은 이해하기 쉽지만, 트리플이나 합계 베팅은 배당이 큰 만큼 확률이 낮다.~wrong",
      "kind": "OFF",
      "locale": "zh-CN",
      "required": [],
      "source": "세 개의 주사위 결과에 거는 카지노 게임. 빅/스몰은 이해하기 쉽지만, 트리플이나 합계 베팅은 배당이 큰 만큼 확률이 낮다.",
      "static": false,
      "target": "对3颗骰子的结果下注的赌场游戏。大/小容易理解，但围骰或点数总和投注，赔率虽高，中奖概率也更低。"
    },
    {
      "base": "cn_dice_normal",
      "context": "dice",
      "expected": "ORIGINAL",
      "id": "cn_dice_unrelated_OFF",
      "key": "ui:세 개의 주사위가 구른다.:/세 개의 주사위가 구른다.",
      "kind": "OFF",
      "locale": "zh-CN",
      "required": [],
      "source": "세 개의 주사위가 구른다.",
      "static": true,
      "target": "对3颗骰子的结果下注的赌场游戏。大/小容易理解，但围骰或点数总和投注，赔率虽高，中奖概率也更低。"
    },
    {
      "base": "cn_dice_normal",
      "context": "dice",
      "expected": "ORIGINAL",
      "id": "cn_dice_locale_OFF",
      "key": "ui:세 개의 주사위 결과에 거는 카지노 게임. 빅/스몰은 이해하기 쉽지만, 트리플이나 합계 베팅은 배당이 큰 만큼 확률이 낮다.:/세 개의 주사위 결과에 거는 카지노 게임. 빅~1스몰은 이해하기 쉽지만, 트리플이나 합계 베팅은 배당이 큰 만큼 확률이 낮다.",
      "kind": "OFF",
      "locale": "ja",
      "required": [],
      "source": "세 개의 주사위 결과에 거는 카지노 게임. 빅/스몰은 이해하기 쉽지만, 트리플이나 합계 베팅은 배당이 큰 만큼 확률이 낮다.",
      "static": false,
      "target": "对3颗骰子的结果下注的赌场游戏。大/小容易理解，但围骰或点数总和投注，赔率虽高，中奖概率也更低。"
    },
    {
      "base": "cn_dice_normal",
      "context": "dice",
      "expected": "ORIGINAL",
      "id": "cn_dice_unescaped_pointer_OFF",
      "key": "ui:세 개의 주사위 결과에 거는 카지노 게임. 빅/스몰은 이해하기 쉽지만, 트리플이나 합계 베팅은 배당이 큰 만큼 확률이 낮다.:/세 개의 주사위 결과에 거는 카지노 게임. 빅/스몰은 이해하기 쉽지만, 트리플이나 합계 베팅은 배당이 큰 만큼 확률이 낮다.",
      "kind": "OFF",
      "locale": "zh-CN",
      "required": [],
      "source": "세 개의 주사위 결과에 거는 카지노 게임. 빅/스몰은 이해하기 쉽지만, 트리플이나 합계 베팅은 배당이 큰 만큼 확률이 낮다.",
      "static": false,
      "target": "对3颗骰子的结果下注的赌场游戏。大/小容易理解，但围骰或点数总和投注，赔率虽高，中奖概率也更低。"
    },
    {
      "base": null,
      "context": "ranges",
      "expected": "PASS",
      "id": "cn_ranges_normal",
      "key": "ui:주사위 합계 11~17은 빅, 4~10은 스몰. 단, 세 주사위가 모두 같은 트리플이면 빅/스몰은 패배 처리된다.:/주사위 합계 11~017은 빅, 4~010은 스몰. 단, 세 주사위가 모두 같은 트리플이면 빅~1스몰은 패배 처리된다.",
      "kind": "normal",
      "locale": "zh-CN",
      "required": [],
      "source": "주사위 합계 11~17은 빅, 4~10은 스몰. 단, 세 주사위가 모두 같은 트리플이면 빅/스몰은 패배 처리된다.",
      "static": true,
      "target": "骰子点数总和11~17为大，4~10为小。但若3颗骰子的点数完全相同，构成围骰，押大/小均判输。"
    },
    {
      "base": "cn_ranges_normal",
      "context": "ranges",
      "expected": "REJECT",
      "id": "cn_ranges_dice_value",
      "key": "ui:주사위 합계 11~17은 빅, 4~10은 스몰. 단, 세 주사위가 모두 같은 트리플이면 빅/스몰은 패배 처리된다.:/주사위 합계 11~017은 빅, 4~010은 스몰. 단, 세 주사위가 모두 같은 트리플이면 빅~1스몰은 패배 처리된다.",
      "kind": "mutant",
      "locale": "zh-CN",
      "required": [],
      "source": "주사위 합계 11~17은 빅, 4~10은 스몰. 단, 세 주사위가 모두 같은 트리플이면 빅/스몰은 패배 처리된다.",
      "static": true,
      "target": "骰子点数总和11~17为大，4~10为小。但若4颗骰子的点数完全相同，构成围骰，押大/小均判输。"
    },
    {
      "base": "cn_ranges_normal",
      "context": "ranges",
      "expected": "REJECT",
      "id": "cn_ranges_dice_missing",
      "key": "ui:주사위 합계 11~17은 빅, 4~10은 스몰. 단, 세 주사위가 모두 같은 트리플이면 빅/스몰은 패배 처리된다.:/주사위 합계 11~017은 빅, 4~010은 스몰. 단, 세 주사위가 모두 같은 트리플이면 빅~1스몰은 패배 처리된다.",
      "kind": "mutant",
      "locale": "zh-CN",
      "required": [],
      "source": "주사위 합계 11~17은 빅, 4~10은 스몰. 단, 세 주사위가 모두 같은 트리플이면 빅/스몰은 패배 처리된다.",
      "static": true,
      "target": "骰子点数总和11~17为大，4~10为小。但若颗骰子的点数完全相同，构成围骰，押大/小均判输。"
    },
    {
      "base": "cn_ranges_normal",
      "context": "ranges",
      "expected": "REJECT",
      "id": "cn_ranges_dice_cards",
      "key": "ui:주사위 합계 11~17은 빅, 4~10은 스몰. 단, 세 주사위가 모두 같은 트리플이면 빅/스몰은 패배 처리된다.:/주사위 합계 11~017은 빅, 4~010은 스몰. 단, 세 주사위가 모두 같은 트리플이면 빅~1스몰은 패배 처리된다.",
      "kind": "mutant",
      "locale": "zh-CN",
      "required": [],
      "source": "주사위 합계 11~17은 빅, 4~10은 스몰. 단, 세 주사위가 모두 같은 트리플이면 빅/스몰은 패배 처리된다.",
      "static": true,
      "target": "骰子点数总和11~17为大，4~10为小。但若3张牌的点数完全相同，构成围骰，押大/小均判输。"
    },
    {
      "base": "cn_ranges_normal",
      "context": "ranges",
      "expected": "REJECT",
      "id": "cn_ranges_dice_chips",
      "key": "ui:주사위 합계 11~17은 빅, 4~10은 스몰. 단, 세 주사위가 모두 같은 트리플이면 빅/스몰은 패배 처리된다.:/주사위 합계 11~017은 빅, 4~010은 스몰. 단, 세 주사위가 모두 같은 트리플이면 빅~1스몰은 패배 처리된다.",
      "kind": "mutant",
      "locale": "zh-CN",
      "required": [],
      "source": "주사위 합계 11~17은 빅, 4~10은 스몰. 단, 세 주사위가 모두 같은 트리플이면 빅/스몰은 패배 처리된다.",
      "static": true,
      "target": "骰子点数总和11~17为大，4~10为小。但若3枚筹码的点数完全相同，构成围骰，押大/小均判输。"
    },
    {
      "base": "cn_ranges_normal",
      "context": "ranges",
      "expected": "REJECT",
      "id": "cn_ranges_dice_sign_plus",
      "key": "ui:주사위 합계 11~17은 빅, 4~10은 스몰. 단, 세 주사위가 모두 같은 트리플이면 빅/스몰은 패배 처리된다.:/주사위 합계 11~017은 빅, 4~010은 스몰. 단, 세 주사위가 모두 같은 트리플이면 빅~1스몰은 패배 처리된다.",
      "kind": "mutant",
      "locale": "zh-CN",
      "required": [],
      "source": "주사위 합계 11~17은 빅, 4~10은 스몰. 단, 세 주사위가 모두 같은 트리플이면 빅/스몰은 패배 처리된다.",
      "static": true,
      "target": "骰子点数总和11~17为大，4~10为小。但若+3颗骰子的点数完全相同，构成围骰，押大/小均判输。"
    },
    {
      "base": "cn_ranges_normal",
      "context": "ranges",
      "expected": "REJECT",
      "id": "cn_ranges_dice_sign_minus",
      "key": "ui:주사위 합계 11~17은 빅, 4~10은 스몰. 단, 세 주사위가 모두 같은 트리플이면 빅/스몰은 패배 처리된다.:/주사위 합계 11~017은 빅, 4~010은 스몰. 단, 세 주사위가 모두 같은 트리플이면 빅~1스몰은 패배 처리된다.",
      "kind": "mutant",
      "locale": "zh-CN",
      "required": [],
      "source": "주사위 합계 11~17은 빅, 4~10은 스몰. 단, 세 주사위가 모두 같은 트리플이면 빅/스몰은 패배 처리된다.",
      "static": true,
      "target": "骰子点数总和11~17为大，4~10为小。但若-3颗骰子的点数完全相同，构成围骰，押大/小均判输。"
    },
    {
      "base": "cn_ranges_normal",
      "context": "ranges",
      "expected": "REJECT",
      "id": "cn_ranges_dice_decimal",
      "key": "ui:주사위 합계 11~17은 빅, 4~10은 스몰. 단, 세 주사위가 모두 같은 트리플이면 빅/스몰은 패배 처리된다.:/주사위 합계 11~017은 빅, 4~010은 스몰. 단, 세 주사위가 모두 같은 트리플이면 빅~1스몰은 패배 처리된다.",
      "kind": "mutant",
      "locale": "zh-CN",
      "required": [],
      "source": "주사위 합계 11~17은 빅, 4~10은 스몰. 단, 세 주사위가 모두 같은 트리플이면 빅/스몰은 패배 처리된다.",
      "static": true,
      "target": "骰子点数总和11~17为大，4~10为小。但若3.5颗骰子的点数完全相同，构成围骰，押大/小均判输。"
    },
    {
      "base": "cn_ranges_normal",
      "context": "ranges",
      "expected": "REJECT",
      "id": "cn_ranges_dice_percent",
      "key": "ui:주사위 합계 11~17은 빅, 4~10은 스몰. 단, 세 주사위가 모두 같은 트리플이면 빅/스몰은 패배 처리된다.:/주사위 합계 11~017은 빅, 4~010은 스몰. 단, 세 주사위가 모두 같은 트리플이면 빅~1스몰은 패배 처리된다.",
      "kind": "mutant",
      "locale": "zh-CN",
      "required": [],
      "source": "주사위 합계 11~17은 빅, 4~10은 스몰. 단, 세 주사위가 모두 같은 트리플이면 빅/스몰은 패배 처리된다.",
      "static": true,
      "target": "骰子点数总和11~17为大，4~10为小。但若3%颗骰子的点数完全相同，构成围骰，押大/小均判输。"
    },
    {
      "base": "cn_ranges_normal",
      "context": "ranges",
      "expected": "REJECT",
      "id": "cn_ranges_dice_time",
      "key": "ui:주사위 합계 11~17은 빅, 4~10은 스몰. 단, 세 주사위가 모두 같은 트리플이면 빅/스몰은 패배 처리된다.:/주사위 합계 11~017은 빅, 4~010은 스몰. 단, 세 주사위가 모두 같은 트리플이면 빅~1스몰은 패배 처리된다.",
      "kind": "mutant",
      "locale": "zh-CN",
      "required": [],
      "source": "주사위 합계 11~17은 빅, 4~10은 스몰. 단, 세 주사위가 모두 같은 트리플이면 빅/스몰은 패배 처리된다.",
      "static": true,
      "target": "骰子点数总和11~17为大，4~10为小。但若3:00颗骰子的点数完全相同，构成围骰，押大/小均判输。"
    },
    {
      "base": "cn_ranges_normal",
      "context": "ranges",
      "expected": "REJECT",
      "id": "cn_ranges_dice_days",
      "key": "ui:주사위 합계 11~17은 빅, 4~10은 스몰. 단, 세 주사위가 모두 같은 트리플이면 빅/스몰은 패배 처리된다.:/주사위 합계 11~017은 빅, 4~010은 스몰. 단, 세 주사위가 모두 같은 트리플이면 빅~1스몰은 패배 처리된다.",
      "kind": "mutant",
      "locale": "zh-CN",
      "required": [],
      "source": "주사위 합계 11~17은 빅, 4~10은 스몰. 단, 세 주사위가 모두 같은 트리플이면 빅/스몰은 패배 처리된다.",
      "static": true,
      "target": "骰子点数总和11~17为大，4~10为小。但若3天的点数完全相同，构成围骰，押大/小均判输。"
    },
    {
      "base": "cn_ranges_normal",
      "context": "ranges",
      "expected": "REJECT",
      "id": "cn_ranges_duplicate_dice",
      "key": "ui:주사위 합계 11~17은 빅, 4~10은 스몰. 단, 세 주사위가 모두 같은 트리플이면 빅/스몰은 패배 처리된다.:/주사위 합계 11~017은 빅, 4~010은 스몰. 단, 세 주사위가 모두 같은 트리플이면 빅~1스몰은 패배 처리된다.",
      "kind": "mutant",
      "locale": "zh-CN",
      "required": [],
      "source": "주사위 합계 11~17은 빅, 4~10은 스몰. 단, 세 주사위가 모두 같은 트리플이면 빅/스몰은 패배 처리된다.",
      "static": true,
      "target": "骰子点数总和11~17为大，4~10为小。但若3颗骰子的点数完全相同，构成围骰，押大/小均判输。3颗骰子。"
    },
    {
      "base": "cn_ranges_normal",
      "context": "ranges",
      "expected": "REJECT",
      "id": "cn_ranges_big_lower",
      "key": "ui:주사위 합계 11~17은 빅, 4~10은 스몰. 단, 세 주사위가 모두 같은 트리플이면 빅/스몰은 패배 처리된다.:/주사위 합계 11~017은 빅, 4~010은 스몰. 단, 세 주사위가 모두 같은 트리플이면 빅~1스몰은 패배 처리된다.",
      "kind": "mutant",
      "locale": "zh-CN",
      "required": [],
      "source": "주사위 합계 11~17은 빅, 4~10은 스몰. 단, 세 주사위가 모두 같은 트리플이면 빅/스몰은 패배 처리된다.",
      "static": true,
      "target": "骰子点数总和12~17为大，4~10为小。但若3颗骰子的点数完全相同，构成围骰，押大/小均判输。"
    },
    {
      "base": "cn_ranges_normal",
      "context": "ranges",
      "expected": "REJECT",
      "id": "cn_ranges_big_upper",
      "key": "ui:주사위 합계 11~17은 빅, 4~10은 스몰. 단, 세 주사위가 모두 같은 트리플이면 빅/스몰은 패배 처리된다.:/주사위 합계 11~017은 빅, 4~010은 스몰. 단, 세 주사위가 모두 같은 트리플이면 빅~1스몰은 패배 처리된다.",
      "kind": "mutant",
      "locale": "zh-CN",
      "required": [],
      "source": "주사위 합계 11~17은 빅, 4~10은 스몰. 단, 세 주사위가 모두 같은 트리플이면 빅/스몰은 패배 처리된다.",
      "static": true,
      "target": "骰子点数总和11~18为大，4~10为小。但若3颗骰子的点数完全相同，构成围骰，押大/小均判输。"
    },
    {
      "base": "cn_ranges_normal",
      "context": "ranges",
      "expected": "REJECT",
      "id": "cn_ranges_small_lower",
      "key": "ui:주사위 합계 11~17은 빅, 4~10은 스몰. 단, 세 주사위가 모두 같은 트리플이면 빅/스몰은 패배 처리된다.:/주사위 합계 11~017은 빅, 4~010은 스몰. 단, 세 주사위가 모두 같은 트리플이면 빅~1스몰은 패배 처리된다.",
      "kind": "mutant",
      "locale": "zh-CN",
      "required": [],
      "source": "주사위 합계 11~17은 빅, 4~10은 스몰. 단, 세 주사위가 모두 같은 트리플이면 빅/스몰은 패배 처리된다.",
      "static": true,
      "target": "骰子点数总和11~17为大，5~10为小。但若3颗骰子的点数完全相同，构成围骰，押大/小均判输。"
    },
    {
      "base": "cn_ranges_normal",
      "context": "ranges",
      "expected": "REJECT",
      "id": "cn_ranges_small_upper",
      "key": "ui:주사위 합계 11~17은 빅, 4~10은 스몰. 단, 세 주사위가 모두 같은 트리플이면 빅/스몰은 패배 처리된다.:/주사위 합계 11~017은 빅, 4~010은 스몰. 단, 세 주사위가 모두 같은 트리플이면 빅~1스몰은 패배 처리된다.",
      "kind": "mutant",
      "locale": "zh-CN",
      "required": [],
      "source": "주사위 합계 11~17은 빅, 4~10은 스몰. 단, 세 주사위가 모두 같은 트리플이면 빅/스몰은 패배 처리된다.",
      "static": true,
      "target": "骰子点数总和11~17为大，4~9为小。但若3颗骰子的点数完全相同，构成围骰，押大/小均判输。"
    },
    {
      "base": "cn_ranges_normal",
      "context": "ranges",
      "expected": "REJECT",
      "id": "cn_ranges_big_reverse",
      "key": "ui:주사위 합계 11~17은 빅, 4~10은 스몰. 단, 세 주사위가 모두 같은 트리플이면 빅/스몰은 패배 처리된다.:/주사위 합계 11~017은 빅, 4~010은 스몰. 단, 세 주사위가 모두 같은 트리플이면 빅~1스몰은 패배 처리된다.",
      "kind": "mutant",
      "locale": "zh-CN",
      "required": [],
      "source": "주사위 합계 11~17은 빅, 4~10은 스몰. 단, 세 주사위가 모두 같은 트리플이면 빅/스몰은 패배 처리된다.",
      "static": true,
      "target": "骰子点数总和17~11为大，4~10为小。但若3颗骰子的点数完全相同，构成围骰，押大/小均判输。"
    },
    {
      "base": "cn_ranges_normal",
      "context": "ranges",
      "expected": "REJECT",
      "id": "cn_ranges_small_reverse",
      "key": "ui:주사위 합계 11~17은 빅, 4~10은 스몰. 단, 세 주사위가 모두 같은 트리플이면 빅/스몰은 패배 처리된다.:/주사위 합계 11~017은 빅, 4~010은 스몰. 단, 세 주사위가 모두 같은 트리플이면 빅~1스몰은 패배 처리된다.",
      "kind": "mutant",
      "locale": "zh-CN",
      "required": [],
      "source": "주사위 합계 11~17은 빅, 4~10은 스몰. 단, 세 주사위가 모두 같은 트리플이면 빅/스몰은 패배 처리된다.",
      "static": true,
      "target": "骰子点数总和11~17为大，10~4为小。但若3颗骰子的点数完全相同，构成围骰，押大/小均判输。"
    },
    {
      "base": "cn_ranges_normal",
      "context": "ranges",
      "expected": "REJECT",
      "id": "cn_ranges_big_sign",
      "key": "ui:주사위 합계 11~17은 빅, 4~10은 스몰. 단, 세 주사위가 모두 같은 트리플이면 빅/스몰은 패배 처리된다.:/주사위 합계 11~017은 빅, 4~010은 스몰. 단, 세 주사위가 모두 같은 트리플이면 빅~1스몰은 패배 처리된다.",
      "kind": "mutant",
      "locale": "zh-CN",
      "required": [],
      "source": "주사위 합계 11~17은 빅, 4~10은 스몰. 단, 세 주사위가 모두 같은 트리플이면 빅/스몰은 패배 처리된다.",
      "static": true,
      "target": "骰子点数总和+11~17为大，4~10为小。但若3颗骰子的点数完全相同，构成围骰，押大/小均判输。"
    },
    {
      "base": "cn_ranges_normal",
      "context": "ranges",
      "expected": "REJECT",
      "id": "cn_ranges_small_sign",
      "key": "ui:주사위 합계 11~17은 빅, 4~10은 스몰. 단, 세 주사위가 모두 같은 트리플이면 빅/스몰은 패배 처리된다.:/주사위 합계 11~017은 빅, 4~010은 스몰. 단, 세 주사위가 모두 같은 트리플이면 빅~1스몰은 패배 처리된다.",
      "kind": "mutant",
      "locale": "zh-CN",
      "required": [],
      "source": "주사위 합계 11~17은 빅, 4~10은 스몰. 단, 세 주사위가 모두 같은 트리플이면 빅/스몰은 패배 처리된다.",
      "static": true,
      "target": "骰子点数总和11~17为大，-4~10为小。但若3颗骰子的点数完全相同，构成围骰，押大/小均判输。"
    },
    {
      "base": "cn_ranges_normal",
      "context": "ranges",
      "expected": "REJECT",
      "id": "cn_ranges_range_percent",
      "key": "ui:주사위 합계 11~17은 빅, 4~10은 스몰. 단, 세 주사위가 모두 같은 트리플이면 빅/스몰은 패배 처리된다.:/주사위 합계 11~017은 빅, 4~010은 스몰. 단, 세 주사위가 모두 같은 트리플이면 빅~1스몰은 패배 처리된다.",
      "kind": "mutant",
      "locale": "zh-CN",
      "required": [],
      "source": "주사위 합계 11~17은 빅, 4~10은 스몰. 단, 세 주사위가 모두 같은 트리플이면 빅/스몰은 패배 처리된다.",
      "static": true,
      "target": "骰子点数总和11%~17%为大，4~10为小。但若3颗骰子的点数完全相同，构成围骰，押大/小均判输。"
    },
    {
      "base": "cn_ranges_normal",
      "context": "ranges",
      "expected": "REJECT",
      "id": "cn_ranges_range_days",
      "key": "ui:주사위 합계 11~17은 빅, 4~10은 스몰. 단, 세 주사위가 모두 같은 트리플이면 빅/스몰은 패배 처리된다.:/주사위 합계 11~017은 빅, 4~010은 스몰. 단, 세 주사위가 모두 같은 트리플이면 빅~1스몰은 패배 처리된다.",
      "kind": "mutant",
      "locale": "zh-CN",
      "required": [],
      "source": "주사위 합계 11~17은 빅, 4~10은 스몰. 단, 세 주사위가 모두 같은 트리플이면 빅/스몰은 패배 처리된다.",
      "static": true,
      "target": "骰子点数总和11天~17天为大，4~10为小。但若3颗骰子的点数完全相同，构成围骰，押大/小均判输。"
    },
    {
      "base": "cn_ranges_normal",
      "context": "ranges",
      "expected": "REJECT",
      "id": "cn_ranges_range_role_swap",
      "key": "ui:주사위 합계 11~17은 빅, 4~10은 스몰. 단, 세 주사위가 모두 같은 트리플이면 빅/스몰은 패배 처리된다.:/주사위 합계 11~017은 빅, 4~010은 스몰. 단, 세 주사위가 모두 같은 트리플이면 빅~1스몰은 패배 처리된다.",
      "kind": "mutant",
      "locale": "zh-CN",
      "required": [],
      "source": "주사위 합계 11~17은 빅, 4~10은 스몰. 단, 세 주사위가 모두 같은 트리플이면 빅/스몰은 패배 처리된다.",
      "static": true,
      "target": "骰子点数总和4~10为大，11~17为小。但若3颗骰子的点数完全相同，构成围骰，押大/小均判输。"
    },
    {
      "base": "cn_ranges_normal",
      "context": "ranges",
      "expected": "REJECT",
      "id": "cn_ranges_duplicate_range",
      "key": "ui:주사위 합계 11~17은 빅, 4~10은 스몰. 단, 세 주사위가 모두 같은 트리플이면 빅/스몰은 패배 처리된다.:/주사위 합계 11~017은 빅, 4~010은 스몰. 단, 세 주사위가 모두 같은 트리플이면 빅~1스몰은 패배 처리된다.",
      "kind": "mutant",
      "locale": "zh-CN",
      "required": [],
      "source": "주사위 합계 11~17은 빅, 4~10은 스몰. 단, 세 주사위가 모두 같은 트리플이면 빅/스몰은 패배 처리된다.",
      "static": true,
      "target": "骰子点数总和11~17为大，4~10为小。但若3颗骰子的点数完全相同，构成围骰，押大/小均判输。11~17。"
    },
    {
      "base": "cn_ranges_normal",
      "context": "ranges",
      "expected": "REJECT",
      "id": "cn_ranges_extra_number",
      "key": "ui:주사위 합계 11~17은 빅, 4~10은 스몰. 단, 세 주사위가 모두 같은 트리플이면 빅/스몰은 패배 처리된다.:/주사위 합계 11~017은 빅, 4~010은 스몰. 단, 세 주사위가 모두 같은 트리플이면 빅~1스몰은 패배 처리된다.",
      "kind": "mutant",
      "locale": "zh-CN",
      "required": [],
      "source": "주사위 합계 11~17은 빅, 4~10은 스몰. 단, 세 주사위가 모두 같은 트리플이면 빅/스몰은 패배 처리된다.",
      "static": true,
      "target": "骰子点数总和11~17为大，4~10为小。但若3颗骰子的点数完全相同，构成围骰，押大/小均判输。8。"
    },
    {
      "base": "cn_ranges_normal",
      "context": "ranges",
      "expected": "REJECT",
      "id": "cn_ranges_extra_native_number",
      "key": "ui:주사위 합계 11~17은 빅, 4~10은 스몰. 단, 세 주사위가 모두 같은 트리플이면 빅/스몰은 패배 처리된다.:/주사위 합계 11~017은 빅, 4~010은 스몰. 단, 세 주사위가 모두 같은 트리플이면 빅~1스몰은 패배 처리된다.",
      "kind": "mutant",
      "locale": "zh-CN",
      "required": [],
      "source": "주사위 합계 11~17은 빅, 4~10은 스몰. 단, 세 주사위가 모두 같은 트리플이면 빅/스몰은 패배 처리된다.",
      "static": true,
      "target": "骰子点数总和11~17为大，4~10为小。但若3颗骰子的点数完全相同，构成围骰，押大/小均判输。八。"
    },
    {
      "base": "cn_ranges_normal",
      "context": "ranges",
      "expected": "REJECT",
      "id": "cn_ranges_money",
      "key": "ui:주사위 합계 11~17은 빅, 4~10은 스몰. 단, 세 주사위가 모두 같은 트리플이면 빅/스몰은 패배 처리된다.:/주사위 합계 11~017은 빅, 4~010은 스몰. 단, 세 주사위가 모두 같은 트리플이면 빅~1스몰은 패배 처리된다.",
      "kind": "mutant",
      "locale": "zh-CN",
      "required": [
        "translation invented a Korean-won label absent from source"
      ],
      "source": "주사위 합계 11~17은 빅, 4~10은 스몰. 단, 세 주사위가 모두 같은 트리플이면 빅/스몰은 패배 처리된다.",
      "static": true,
      "target": "骰子点数总和11~17为大，4~10为小。但若3颗骰子的点数完全相同，构成围骰，押大/小均判输。1韩元。"
    },
    {
      "base": "cn_ranges_normal",
      "context": "ranges",
      "expected": "REJECT",
      "id": "cn_ranges_wrong_currency",
      "key": "ui:주사위 합계 11~17은 빅, 4~10은 스몰. 단, 세 주사위가 모두 같은 트리플이면 빅/스몰은 패배 처리된다.:/주사위 합계 11~017은 빅, 4~010은 스몰. 단, 세 주사위가 모두 같은 트리플이면 빅~1스몰은 패배 처리된다.",
      "kind": "mutant",
      "locale": "zh-CN",
      "required": [
        "Korean won was relabeled as yen/yuan/Taiwan dollar"
      ],
      "source": "주사위 합계 11~17은 빅, 4~10은 스몰. 단, 세 주사위가 모두 같은 트리플이면 빅/스몰은 패배 처리된다.",
      "static": true,
      "target": "骰子点数总和11~17为大，4~10为小。但若3颗骰子的点数完全相同，构成围骰，押大/小均判输。1日元。"
    },
    {
      "base": "cn_ranges_normal",
      "context": "ranges",
      "expected": "REJECT",
      "id": "cn_ranges_token",
      "key": "ui:주사위 합계 11~17은 빅, 4~10은 스몰. 단, 세 주사위가 모두 같은 트리플이면 빅/스몰은 패배 처리된다.:/주사위 합계 11~017은 빅, 4~010은 스몰. 단, 세 주사위가 모두 같은 트리플이면 빅~1스몰은 패배 처리된다.",
      "kind": "mutant",
      "locale": "zh-CN",
      "required": [
        "placeholder/BBCode mismatch"
      ],
      "source": "주사위 합계 11~17은 빅, 4~10은 스몰. 단, 세 주사위가 모두 같은 트리플이면 빅/스몰은 패배 처리된다.",
      "static": true,
      "target": "骰子点数总和11~17为大，4~10为小。但若3颗骰子的点数完全相同，构成围骰，押大/小均判输。%s"
    },
    {
      "base": "cn_ranges_normal",
      "context": "ranges",
      "expected": "REJECT",
      "id": "cn_ranges_bbcode",
      "key": "ui:주사위 합계 11~17은 빅, 4~10은 스몰. 단, 세 주사위가 모두 같은 트리플이면 빅/스몰은 패배 처리된다.:/주사위 합계 11~017은 빅, 4~010은 스몰. 단, 세 주사위가 모두 같은 트리플이면 빅~1스몰은 패배 처리된다.",
      "kind": "mutant",
      "locale": "zh-CN",
      "required": [
        "placeholder/BBCode mismatch"
      ],
      "source": "주사위 합계 11~17은 빅, 4~10은 스몰. 단, 세 주사위가 모두 같은 트리플이면 빅/스몰은 패배 처리된다.",
      "static": true,
      "target": "[b]骰子点数总和11~17为大，4~10为小。但若3颗骰子的点数完全相同，构成围骰，押大/小均判输。[/b]"
    },
    {
      "base": "cn_ranges_normal",
      "context": "ranges",
      "expected": "REJECT",
      "id": "cn_ranges_hangul",
      "key": "ui:주사위 합계 11~17은 빅, 4~10은 스몰. 단, 세 주사위가 모두 같은 트리플이면 빅/스몰은 패배 처리된다.:/주사위 합계 11~017은 빅, 4~010은 스몰. 단, 세 주사위가 모두 같은 트리플이면 빅~1스몰은 패배 처리된다.",
      "kind": "mutant",
      "locale": "zh-CN",
      "required": [
        "Hangul remains"
      ],
      "source": "주사위 합계 11~17은 빅, 4~10은 스몰. 단, 세 주사위가 모두 같은 트리플이면 빅/스몰은 패배 처리된다.",
      "static": true,
      "target": "骰子点数总和11~17为大，4~10为小。但若3颗骰子的点数完全相同，构成围骰，押大/小均判输。한글"
    },
    {
      "base": "cn_ranges_normal",
      "context": "ranges",
      "expected": "REJECT",
      "id": "cn_ranges_kana",
      "key": "ui:주사위 합계 11~17은 빅, 4~10은 스몰. 단, 세 주사위가 모두 같은 트리플이면 빅/스몰은 패배 처리된다.:/주사위 합계 11~017은 빅, 4~010은 스몰. 단, 세 주사위가 모두 같은 트리플이면 빅~1스몰은 패배 처리된다.",
      "kind": "mutant",
      "locale": "zh-CN",
      "required": [
        "Japanese kana remains"
      ],
      "source": "주사위 합계 11~17은 빅, 4~10은 스몰. 단, 세 주사위가 모두 같은 트리플이면 빅/스몰은 패배 처리된다.",
      "static": true,
      "target": "骰子点数总和11~17为大，4~10为小。但若3颗骰子的点数完全相同，构成围骰，押大/小均判输。かな"
    },
    {
      "base": "cn_ranges_normal",
      "context": "ranges",
      "expected": "REJECT",
      "id": "cn_ranges_newline",
      "key": "ui:주사위 합계 11~17은 빅, 4~10은 스몰. 단, 세 주사위가 모두 같은 트리플이면 빅/스몰은 패배 처리된다.:/주사위 합계 11~017은 빅, 4~010은 스몰. 단, 세 주사위가 모두 같은 트리플이면 빅~1스몰은 패배 처리된다.",
      "kind": "mutant",
      "locale": "zh-CN",
      "required": [
        "newline mismatch 0 != 1"
      ],
      "source": "주사위 합계 11~17은 빅, 4~10은 스몰. 단, 세 주사위가 모두 같은 트리플이면 빅/스몰은 패배 처리된다.",
      "static": true,
      "target": "骰子点数总和11~17为大，4~10为小。但若3颗骰子的点数完全相同，构成围骰，押大/小均判输。\n"
    },
    {
      "base": "cn_ranges_normal",
      "context": "ranges",
      "expected": "REJECT",
      "id": "cn_ranges_paragraph",
      "key": "ui:주사위 합계 11~17은 빅, 4~10은 스몰. 단, 세 주사위가 모두 같은 트리플이면 빅/스몰은 패배 처리된다.:/주사위 합계 11~017은 빅, 4~010은 스몰. 단, 세 주사위가 모두 같은 트리플이면 빅~1스몰은 패배 처리된다.",
      "kind": "mutant",
      "locale": "zh-CN",
      "required": [
        "newline mismatch 0 != 2",
        "paragraph mismatch"
      ],
      "source": "주사위 합계 11~17은 빅, 4~10은 스몰. 단, 세 주사위가 모두 같은 트리플이면 빅/스몰은 패배 처리된다.",
      "static": true,
      "target": "骰子点数总和11~17为大，4~10为小。但若3颗骰子的点数完全相同，构成围骰，押大/小均判输。\n\n"
    },
    {
      "base": "cn_ranges_normal",
      "context": "ranges",
      "expected": "REJECT",
      "id": "cn_ranges_script",
      "key": "ui:주사위 합계 11~17은 빅, 4~10은 스몰. 단, 세 주사위가 모두 같은 트리플이면 빅/스몰은 패배 처리된다.:/주사위 합계 11~017은 빅, 4~010은 스몰. 단, 세 주사위가 모두 같은 트리플이면 빅~1스몰은 패배 처리된다.",
      "kind": "mutant",
      "locale": "zh-CN",
      "required": [
        "@script"
      ],
      "source": "주사위 합계 11~17은 빅, 4~10은 스몰. 단, 세 주사위가 모두 같은 트리플이면 빅/스몰은 패배 처리된다.",
      "static": true,
      "target": "骰子点数总和11~17为大，4~10为小。但若3颗骰子的点数完全相同，构成围骰，押大/小均判输。顆"
    },
    {
      "base": "cn_ranges_normal",
      "context": "ranges",
      "expected": "REJECT",
      "id": "cn_ranges_english",
      "key": "ui:주사위 합계 11~17은 빅, 4~10은 스몰. 단, 세 주사위가 모두 같은 트리플이면 빅/스몰은 패배 처리된다.:/주사위 합계 11~017은 빅, 4~010은 스몰. 단, 세 주사위가 모두 같은 트리플이면 빅~1스몰은 패배 처리된다.",
      "kind": "mutant",
      "locale": "zh-CN",
      "required": [
        "@english"
      ],
      "source": "주사위 합계 11~17은 빅, 4~10은 스몰. 단, 세 주사위가 모두 같은 트리플이면 빅/스몰은 패배 처리된다.",
      "static": true,
      "target": "骰子点数总和11~17为大，4~10为小。但若3颗骰子的点数完全相同，构成围骰，押大/小均判输。 Please read this instruction."
    },
    {
      "base": "cn_ranges_normal",
      "context": "ranges",
      "expected": "ORIGINAL",
      "id": "cn_ranges_source_OFF",
      "key": "ui:주사위 합계 11~17은 빅, 4~10은 스몰. 단, 세 주사위가 모두 같은 트리플이면 빅/스몰은 패배 처리된다.:/주사위 합계 11~017은 빅, 4~010은 스몰. 단, 세 주사위가 모두 같은 트리플이면 빅~1스몰은 패배 처리된다.",
      "kind": "OFF",
      "locale": "zh-CN",
      "required": [],
      "source": "주사위 합계 11~17은 빅, 4~10은 스몰. 단, 세 주사위가 모두 같은 트리플이면 빅/스몰은 패배 처리된다. ",
      "static": true,
      "target": "骰子点数总和11~17为大，4~10为小。但若3颗骰子的点数完全相同，构成围骰，押大/小均判输。"
    },
    {
      "base": "cn_ranges_normal",
      "context": "ranges",
      "expected": "ORIGINAL",
      "id": "cn_ranges_owner_OFF",
      "key": "ui:foreign-owner:/주사위 합계 11~017은 빅, 4~010은 스몰. 단, 세 주사위가 모두 같은 트리플이면 빅~1스몰은 패배 처리된다.",
      "kind": "OFF",
      "locale": "zh-CN",
      "required": [],
      "source": "주사위 합계 11~17은 빅, 4~10은 스몰. 단, 세 주사위가 모두 같은 트리플이면 빅/스몰은 패배 처리된다.",
      "static": false,
      "target": "骰子点数总和11~17为大，4~10为小。但若3颗骰子的点数完全相同，构成围骰，押大/小均判输。"
    },
    {
      "base": "cn_ranges_normal",
      "context": "ranges",
      "expected": "ORIGINAL",
      "id": "cn_ranges_pointer_OFF",
      "key": "ui:주사위 합계 11~17은 빅, 4~10은 스몰. 단, 세 주사위가 모두 같은 트리플이면 빅/스몰은 패배 처리된다.:/주사위 합계 11~017은 빅, 4~010은 스몰. 단, 세 주사위가 모두 같은 트리플이면 빅~1스몰은 패배 처리된다.~wrong",
      "kind": "OFF",
      "locale": "zh-CN",
      "required": [],
      "source": "주사위 합계 11~17은 빅, 4~10은 스몰. 단, 세 주사위가 모두 같은 트리플이면 빅/스몰은 패배 처리된다.",
      "static": false,
      "target": "骰子点数总和11~17为大，4~10为小。但若3颗骰子的点数完全相同，构成围骰，押大/小均判输。"
    },
    {
      "base": "cn_ranges_normal",
      "context": "ranges",
      "expected": "ORIGINAL",
      "id": "cn_ranges_unrelated_OFF",
      "key": "ui:세 개의 주사위가 구른다.:/세 개의 주사위가 구른다.",
      "kind": "OFF",
      "locale": "zh-CN",
      "required": [],
      "source": "세 개의 주사위가 구른다.",
      "static": true,
      "target": "骰子点数总和11~17为大，4~10为小。但若3颗骰子的点数完全相同，构成围骰，押大/小均判输。"
    },
    {
      "base": "cn_ranges_normal",
      "context": "ranges",
      "expected": "ORIGINAL",
      "id": "cn_ranges_locale_OFF",
      "key": "ui:주사위 합계 11~17은 빅, 4~10은 스몰. 단, 세 주사위가 모두 같은 트리플이면 빅/스몰은 패배 처리된다.:/주사위 합계 11~017은 빅, 4~010은 스몰. 단, 세 주사위가 모두 같은 트리플이면 빅~1스몰은 패배 처리된다.",
      "kind": "OFF",
      "locale": "ja",
      "required": [],
      "source": "주사위 합계 11~17은 빅, 4~10은 스몰. 단, 세 주사위가 모두 같은 트리플이면 빅/스몰은 패배 처리된다.",
      "static": false,
      "target": "骰子点数总和11~17为大，4~10为小。但若3颗骰子的点数完全相同，构成围骰，押大/小均判输。"
    },
    {
      "base": "cn_ranges_normal",
      "context": "ranges",
      "expected": "ORIGINAL",
      "id": "cn_ranges_unescaped_pointer_OFF",
      "key": "ui:주사위 합계 11~17은 빅, 4~10은 스몰. 단, 세 주사위가 모두 같은 트리플이면 빅/스몰은 패배 처리된다.:/주사위 합계 11~17은 빅, 4~10은 스몰. 단, 세 주사위가 모두 같은 트리플이면 빅/스몰은 패배 처리된다.",
      "kind": "OFF",
      "locale": "zh-CN",
      "required": [],
      "source": "주사위 합계 11~17은 빅, 4~10은 스몰. 단, 세 주사위가 모두 같은 트리플이면 빅/스몰은 패배 처리된다.",
      "static": false,
      "target": "骰子点数总和11~17为大，4~10为小。但若3颗骰子的点数完全相同，构成围骰，押大/小均判输。"
    },
    {
      "base": null,
      "context": "double",
      "expected": "PASS",
      "id": "tw_double_normal",
      "key": "ui:첫 두 장 받은 후 배팅액을 2배로 늘리고 카드를 한 장만 더 받는 것. 합이 10·11일 때 유리.:/첫 두 장 받은 후 배팅액을 2배로 늘리고 카드를 한 장만 더 받는 것. 합이 10·11일 때 유리.",
      "kind": "normal",
      "locale": "zh-TW",
      "required": [],
      "source": "첫 두 장 받은 후 배팅액을 2배로 늘리고 카드를 한 장만 더 받는 것. 합이 10·11일 때 유리.",
      "static": true,
      "target": "拿到起手2張牌後，把下注金額加到2倍，並且只再拿1張牌。點數總和是10或11時有利。"
    },
    {
      "base": "tw_double_normal",
      "context": "double",
      "expected": "REJECT",
      "id": "tw_double_first_value",
      "key": "ui:첫 두 장 받은 후 배팅액을 2배로 늘리고 카드를 한 장만 더 받는 것. 합이 10·11일 때 유리.:/첫 두 장 받은 후 배팅액을 2배로 늘리고 카드를 한 장만 더 받는 것. 합이 10·11일 때 유리.",
      "kind": "mutant",
      "locale": "zh-TW",
      "required": [],
      "source": "첫 두 장 받은 후 배팅액을 2배로 늘리고 카드를 한 장만 더 받는 것. 합이 10·11일 때 유리.",
      "static": true,
      "target": "拿到起手3張牌後，把下注金額加到2倍，並且只再拿1張牌。點數總和是10或11時有利。"
    },
    {
      "base": "tw_double_normal",
      "context": "double",
      "expected": "REJECT",
      "id": "tw_double_first_missing",
      "key": "ui:첫 두 장 받은 후 배팅액을 2배로 늘리고 카드를 한 장만 더 받는 것. 합이 10·11일 때 유리.:/첫 두 장 받은 후 배팅액을 2배로 늘리고 카드를 한 장만 더 받는 것. 합이 10·11일 때 유리.",
      "kind": "mutant",
      "locale": "zh-TW",
      "required": [],
      "source": "첫 두 장 받은 후 배팅액을 2배로 늘리고 카드를 한 장만 더 받는 것. 합이 10·11일 때 유리.",
      "static": true,
      "target": "拿到起手張牌後，把下注金額加到2倍，並且只再拿1張牌。點數總和是10或11時有利。"
    },
    {
      "base": "tw_double_normal",
      "context": "double",
      "expected": "REJECT",
      "id": "tw_double_first_unit",
      "key": "ui:첫 두 장 받은 후 배팅액을 2배로 늘리고 카드를 한 장만 더 받는 것. 합이 10·11일 때 유리.:/첫 두 장 받은 후 배팅액을 2배로 늘리고 카드를 한 장만 더 받는 것. 합이 10·11일 때 유리.",
      "kind": "mutant",
      "locale": "zh-TW",
      "required": [],
      "source": "첫 두 장 받은 후 배팅액을 2배로 늘리고 카드를 한 장만 더 받는 것. 합이 10·11일 때 유리.",
      "static": true,
      "target": "拿到起手2天後，把下注金額加到2倍，並且只再拿1張牌。點數總和是10或11時有利。"
    },
    {
      "base": "tw_double_normal",
      "context": "double",
      "expected": "REJECT",
      "id": "tw_double_first_sign",
      "key": "ui:첫 두 장 받은 후 배팅액을 2배로 늘리고 카드를 한 장만 더 받는 것. 합이 10·11일 때 유리.:/첫 두 장 받은 후 배팅액을 2배로 늘리고 카드를 한 장만 더 받는 것. 합이 10·11일 때 유리.",
      "kind": "mutant",
      "locale": "zh-TW",
      "required": [],
      "source": "첫 두 장 받은 후 배팅액을 2배로 늘리고 카드를 한 장만 더 받는 것. 합이 10·11일 때 유리.",
      "static": true,
      "target": "拿到起手+2張牌後，把下注金額加到2倍，並且只再拿1張牌。點數總和是10或11時有利。"
    },
    {
      "base": "tw_double_normal",
      "context": "double",
      "expected": "REJECT",
      "id": "tw_double_multiplier_value",
      "key": "ui:첫 두 장 받은 후 배팅액을 2배로 늘리고 카드를 한 장만 더 받는 것. 합이 10·11일 때 유리.:/첫 두 장 받은 후 배팅액을 2배로 늘리고 카드를 한 장만 더 받는 것. 합이 10·11일 때 유리.",
      "kind": "mutant",
      "locale": "zh-TW",
      "required": [],
      "source": "첫 두 장 받은 후 배팅액을 2배로 늘리고 카드를 한 장만 더 받는 것. 합이 10·11일 때 유리.",
      "static": true,
      "target": "拿到起手2張牌後，把下注金額加到3倍，並且只再拿1張牌。點數總和是10或11時有利。"
    },
    {
      "base": "tw_double_normal",
      "context": "double",
      "expected": "REJECT",
      "id": "tw_double_multiplier_missing",
      "key": "ui:첫 두 장 받은 후 배팅액을 2배로 늘리고 카드를 한 장만 더 받는 것. 합이 10·11일 때 유리.:/첫 두 장 받은 후 배팅액을 2배로 늘리고 카드를 한 장만 더 받는 것. 합이 10·11일 때 유리.",
      "kind": "mutant",
      "locale": "zh-TW",
      "required": [],
      "source": "첫 두 장 받은 후 배팅액을 2배로 늘리고 카드를 한 장만 더 받는 것. 합이 10·11일 때 유리.",
      "static": true,
      "target": "拿到起手2張牌後，把下注金額加到倍，並且只再拿1張牌。點數總和是10或11時有利。"
    },
    {
      "base": "tw_double_normal",
      "context": "double",
      "expected": "REJECT",
      "id": "tw_double_multiplier_unit",
      "key": "ui:첫 두 장 받은 후 배팅액을 2배로 늘리고 카드를 한 장만 더 받는 것. 합이 10·11일 때 유리.:/첫 두 장 받은 후 배팅액을 2배로 늘리고 카드를 한 장만 더 받는 것. 합이 10·11일 때 유리.",
      "kind": "mutant",
      "locale": "zh-TW",
      "required": [],
      "source": "첫 두 장 받은 후 배팅액을 2배로 늘리고 카드를 한 장만 더 받는 것. 합이 10·11일 때 유리.",
      "static": true,
      "target": "拿到起手2張牌後，把下注金額加到2天，並且只再拿1張牌。點數總和是10或11時有利。"
    },
    {
      "base": "tw_double_normal",
      "context": "double",
      "expected": "REJECT",
      "id": "tw_double_multiplier_sign",
      "key": "ui:첫 두 장 받은 후 배팅액을 2배로 늘리고 카드를 한 장만 더 받는 것. 합이 10·11일 때 유리.:/첫 두 장 받은 후 배팅액을 2배로 늘리고 카드를 한 장만 더 받는 것. 합이 10·11일 때 유리.",
      "kind": "mutant",
      "locale": "zh-TW",
      "required": [],
      "source": "첫 두 장 받은 후 배팅액을 2배로 늘리고 카드를 한 장만 더 받는 것. 합이 10·11일 때 유리.",
      "static": true,
      "target": "拿到起手2張牌後，把下注金額加到-2倍，並且只再拿1張牌。點數總和是10或11時有利。"
    },
    {
      "base": "tw_double_normal",
      "context": "double",
      "expected": "REJECT",
      "id": "tw_double_additional_value",
      "key": "ui:첫 두 장 받은 후 배팅액을 2배로 늘리고 카드를 한 장만 더 받는 것. 합이 10·11일 때 유리.:/첫 두 장 받은 후 배팅액을 2배로 늘리고 카드를 한 장만 더 받는 것. 합이 10·11일 때 유리.",
      "kind": "mutant",
      "locale": "zh-TW",
      "required": [],
      "source": "첫 두 장 받은 후 배팅액을 2배로 늘리고 카드를 한 장만 더 받는 것. 합이 10·11일 때 유리.",
      "static": true,
      "target": "拿到起手2張牌後，把下注金額加到2倍，並且只再拿2張牌。點數總和是10或11時有利。"
    },
    {
      "base": "tw_double_normal",
      "context": "double",
      "expected": "REJECT",
      "id": "tw_double_additional_missing",
      "key": "ui:첫 두 장 받은 후 배팅액을 2배로 늘리고 카드를 한 장만 더 받는 것. 합이 10·11일 때 유리.:/첫 두 장 받은 후 배팅액을 2배로 늘리고 카드를 한 장만 더 받는 것. 합이 10·11일 때 유리.",
      "kind": "mutant",
      "locale": "zh-TW",
      "required": [],
      "source": "첫 두 장 받은 후 배팅액을 2배로 늘리고 카드를 한 장만 더 받는 것. 합이 10·11일 때 유리.",
      "static": true,
      "target": "拿到起手2張牌後，把下注金額加到2倍，並且只再拿張牌。點數總和是10或11時有利。"
    },
    {
      "base": "tw_double_normal",
      "context": "double",
      "expected": "REJECT",
      "id": "tw_double_additional_unit",
      "key": "ui:첫 두 장 받은 후 배팅액을 2배로 늘리고 카드를 한 장만 더 받는 것. 합이 10·11일 때 유리.:/첫 두 장 받은 후 배팅액을 2배로 늘리고 카드를 한 장만 더 받는 것. 합이 10·11일 때 유리.",
      "kind": "mutant",
      "locale": "zh-TW",
      "required": [],
      "source": "첫 두 장 받은 후 배팅액을 2배로 늘리고 카드를 한 장만 더 받는 것. 합이 10·11일 때 유리.",
      "static": true,
      "target": "拿到起手2張牌後，把下注金額加到2倍，並且只再拿1顆骰子。點數總和是10或11時有利。"
    },
    {
      "base": "tw_double_normal",
      "context": "double",
      "expected": "REJECT",
      "id": "tw_double_additional_sign",
      "key": "ui:첫 두 장 받은 후 배팅액을 2배로 늘리고 카드를 한 장만 더 받는 것. 합이 10·11일 때 유리.:/첫 두 장 받은 후 배팅액을 2배로 늘리고 카드를 한 장만 더 받는 것. 합이 10·11일 때 유리.",
      "kind": "mutant",
      "locale": "zh-TW",
      "required": [],
      "source": "첫 두 장 받은 후 배팅액을 2배로 늘리고 카드를 한 장만 더 받는 것. 합이 10·11일 때 유리.",
      "static": true,
      "target": "拿到起手2張牌後，把下注金額加到2倍，並且只再拿+1張牌。點數總和是10或11時有利。"
    },
    {
      "base": "tw_double_normal",
      "context": "double",
      "expected": "REJECT",
      "id": "tw_double_point10_value",
      "key": "ui:첫 두 장 받은 후 배팅액을 2배로 늘리고 카드를 한 장만 더 받는 것. 합이 10·11일 때 유리.:/첫 두 장 받은 후 배팅액을 2배로 늘리고 카드를 한 장만 더 받는 것. 합이 10·11일 때 유리.",
      "kind": "mutant",
      "locale": "zh-TW",
      "required": [],
      "source": "첫 두 장 받은 후 배팅액을 2배로 늘리고 카드를 한 장만 더 받는 것. 합이 10·11일 때 유리.",
      "static": true,
      "target": "拿到起手2張牌後，把下注金額加到2倍，並且只再拿1張牌。點數總和是9或11時有利。"
    },
    {
      "base": "tw_double_normal",
      "context": "double",
      "expected": "REJECT",
      "id": "tw_double_point11_value",
      "key": "ui:첫 두 장 받은 후 배팅액을 2배로 늘리고 카드를 한 장만 더 받는 것. 합이 10·11일 때 유리.:/첫 두 장 받은 후 배팅액을 2배로 늘리고 카드를 한 장만 더 받는 것. 합이 10·11일 때 유리.",
      "kind": "mutant",
      "locale": "zh-TW",
      "required": [],
      "source": "첫 두 장 받은 후 배팅액을 2배로 늘리고 카드를 한 장만 더 받는 것. 합이 10·11일 때 유리.",
      "static": true,
      "target": "拿到起手2張牌後，把下注金額加到2倍，並且只再拿1張牌。點數總和是10或12時有利。"
    },
    {
      "base": "tw_double_normal",
      "context": "double",
      "expected": "REJECT",
      "id": "tw_double_point_days",
      "key": "ui:첫 두 장 받은 후 배팅액을 2배로 늘리고 카드를 한 장만 더 받는 것. 합이 10·11일 때 유리.:/첫 두 장 받은 후 배팅액을 2배로 늘리고 카드를 한 장만 더 받는 것. 합이 10·11일 때 유리.",
      "kind": "mutant",
      "locale": "zh-TW",
      "required": [],
      "source": "첫 두 장 받은 후 배팅액을 2배로 늘리고 카드를 한 장만 더 받는 것. 합이 10·11일 때 유리.",
      "static": true,
      "target": "拿到起手2張牌後，把下注金額加到2倍，並且只再拿1張牌。點數總和是10或11天時有利。"
    },
    {
      "base": "tw_double_normal",
      "context": "double",
      "expected": "REJECT",
      "id": "tw_double_point_sign",
      "key": "ui:첫 두 장 받은 후 배팅액을 2배로 늘리고 카드를 한 장만 더 받는 것. 합이 10·11일 때 유리.:/첫 두 장 받은 후 배팅액을 2배로 늘리고 카드를 한 장만 더 받는 것. 합이 10·11일 때 유리.",
      "kind": "mutant",
      "locale": "zh-TW",
      "required": [],
      "source": "첫 두 장 받은 후 배팅액을 2배로 늘리고 카드를 한 장만 더 받는 것. 합이 10·11일 때 유리.",
      "static": true,
      "target": "拿到起手2張牌後，把下注金額加到2倍，並且只再拿1張牌。點數總和是+10或11時有利。"
    },
    {
      "base": "tw_double_normal",
      "context": "double",
      "expected": "REJECT",
      "id": "tw_double_point_percent",
      "key": "ui:첫 두 장 받은 후 배팅액을 2배로 늘리고 카드를 한 장만 더 받는 것. 합이 10·11일 때 유리.:/첫 두 장 받은 후 배팅액을 2배로 늘리고 카드를 한 장만 더 받는 것. 합이 10·11일 때 유리.",
      "kind": "mutant",
      "locale": "zh-TW",
      "required": [],
      "source": "첫 두 장 받은 후 배팅액을 2배로 늘리고 카드를 한 장만 더 받는 것. 합이 10·11일 때 유리.",
      "static": true,
      "target": "拿到起手2張牌後，把下注金額加到2倍，並且只再拿1張牌。點數總和是10或11%時有利。"
    },
    {
      "base": "tw_double_normal",
      "context": "double",
      "expected": "REJECT",
      "id": "tw_double_point_time",
      "key": "ui:첫 두 장 받은 후 배팅액을 2배로 늘리고 카드를 한 장만 더 받는 것. 합이 10·11일 때 유리.:/첫 두 장 받은 후 배팅액을 2배로 늘리고 카드를 한 장만 더 받는 것. 합이 10·11일 때 유리.",
      "kind": "mutant",
      "locale": "zh-TW",
      "required": [],
      "source": "첫 두 장 받은 후 배팅액을 2배로 늘리고 카드를 한 장만 더 받는 것. 합이 10·11일 때 유리.",
      "static": true,
      "target": "拿到起手2張牌後，把下注金額加到2倍，並且只再拿1張牌。點數總和是10或11:00時有利。"
    },
    {
      "base": "tw_double_normal",
      "context": "double",
      "expected": "REJECT",
      "id": "tw_double_point_decimal",
      "key": "ui:첫 두 장 받은 후 배팅액을 2배로 늘리고 카드를 한 장만 더 받는 것. 합이 10·11일 때 유리.:/첫 두 장 받은 후 배팅액을 2배로 늘리고 카드를 한 장만 더 받는 것. 합이 10·11일 때 유리.",
      "kind": "mutant",
      "locale": "zh-TW",
      "required": [],
      "source": "첫 두 장 받은 후 배팅액을 2배로 늘리고 카드를 한 장만 더 받는 것. 합이 10·11일 때 유리.",
      "static": true,
      "target": "拿到起手2張牌後，把下注金額加到2倍，並且只再拿1張牌。點數總和是10或11.5時有利。"
    },
    {
      "base": "tw_double_normal",
      "context": "double",
      "expected": "REJECT",
      "id": "tw_double_card_role_swap",
      "key": "ui:첫 두 장 받은 후 배팅액을 2배로 늘리고 카드를 한 장만 더 받는 것. 합이 10·11일 때 유리.:/첫 두 장 받은 후 배팅액을 2배로 늘리고 카드를 한 장만 더 받는 것. 합이 10·11일 때 유리.",
      "kind": "mutant",
      "locale": "zh-TW",
      "required": [],
      "source": "첫 두 장 받은 후 배팅액을 2배로 늘리고 카드를 한 장만 더 받는 것. 합이 10·11일 때 유리.",
      "static": true,
      "target": "拿到起手1張牌後，把下注金額加到2倍，並且只再拿2張牌。點數總和是10或11時有利。"
    },
    {
      "base": "tw_double_normal",
      "context": "double",
      "expected": "REJECT",
      "id": "tw_double_card_point_swap",
      "key": "ui:첫 두 장 받은 후 배팅액을 2배로 늘리고 카드를 한 장만 더 받는 것. 합이 10·11일 때 유리.:/첫 두 장 받은 후 배팅액을 2배로 늘리고 카드를 한 장만 더 받는 것. 합이 10·11일 때 유리.",
      "kind": "mutant",
      "locale": "zh-TW",
      "required": [],
      "source": "첫 두 장 받은 후 배팅액을 2배로 늘리고 카드를 한 장만 더 받는 것. 합이 10·11일 때 유리.",
      "static": true,
      "target": "拿到起手10張牌後，把下注金額加到2倍，並且只再拿1張牌。點數總和是2或11時有利。"
    },
    {
      "base": "tw_double_normal",
      "context": "double",
      "expected": "REJECT",
      "id": "tw_double_multiplier_card_swap",
      "key": "ui:첫 두 장 받은 후 배팅액을 2배로 늘리고 카드를 한 장만 더 받는 것. 합이 10·11일 때 유리.:/첫 두 장 받은 후 배팅액을 2배로 늘리고 카드를 한 장만 더 받는 것. 합이 10·11일 때 유리.",
      "kind": "mutant",
      "locale": "zh-TW",
      "required": [],
      "source": "첫 두 장 받은 후 배팅액을 2배로 늘리고 카드를 한 장만 더 받는 것. 합이 10·11일 때 유리.",
      "static": true,
      "target": "拿到起手2張牌後，把下注金額加到1倍，並且只再拿2張牌。點數總和是10或11時有利。"
    },
    {
      "base": "tw_double_normal",
      "context": "double",
      "expected": "REJECT",
      "id": "tw_double_duplicate_card",
      "key": "ui:첫 두 장 받은 후 배팅액을 2배로 늘리고 카드를 한 장만 더 받는 것. 합이 10·11일 때 유리.:/첫 두 장 받은 후 배팅액을 2배로 늘리고 카드를 한 장만 더 받는 것. 합이 10·11일 때 유리.",
      "kind": "mutant",
      "locale": "zh-TW",
      "required": [],
      "source": "첫 두 장 받은 후 배팅액을 2배로 늘리고 카드를 한 장만 더 받는 것. 합이 10·11일 때 유리.",
      "static": true,
      "target": "拿到起手2張牌後，把下注金額加到2倍，並且只再拿1張牌。點數總和是10或11時有利。再拿2張牌。"
    },
    {
      "base": "tw_double_normal",
      "context": "double",
      "expected": "REJECT",
      "id": "tw_double_duplicate_multiplier",
      "key": "ui:첫 두 장 받은 후 배팅액을 2배로 늘리고 카드를 한 장만 더 받는 것. 합이 10·11일 때 유리.:/첫 두 장 받은 후 배팅액을 2배로 늘리고 카드를 한 장만 더 받는 것. 합이 10·11일 때 유리.",
      "kind": "mutant",
      "locale": "zh-TW",
      "required": [],
      "source": "첫 두 장 받은 후 배팅액을 2배로 늘리고 카드를 한 장만 더 받는 것. 합이 10·11일 때 유리.",
      "static": true,
      "target": "拿到起手2張牌後，把下注金額加到2倍，並且只再拿1張牌。點數總和是10或11時有利。2倍。"
    },
    {
      "base": "tw_double_normal",
      "context": "double",
      "expected": "REJECT",
      "id": "tw_double_extra_number",
      "key": "ui:첫 두 장 받은 후 배팅액을 2배로 늘리고 카드를 한 장만 더 받는 것. 합이 10·11일 때 유리.:/첫 두 장 받은 후 배팅액을 2배로 늘리고 카드를 한 장만 더 받는 것. 합이 10·11일 때 유리.",
      "kind": "mutant",
      "locale": "zh-TW",
      "required": [],
      "source": "첫 두 장 받은 후 배팅액을 2배로 늘리고 카드를 한 장만 더 받는 것. 합이 10·11일 때 유리.",
      "static": true,
      "target": "拿到起手2張牌後，把下注金額加到2倍，並且只再拿1張牌。點數總和是10或11時有利。8。"
    },
    {
      "base": "tw_double_normal",
      "context": "double",
      "expected": "REJECT",
      "id": "tw_double_extra_native_number",
      "key": "ui:첫 두 장 받은 후 배팅액을 2배로 늘리고 카드를 한 장만 더 받는 것. 합이 10·11일 때 유리.:/첫 두 장 받은 후 배팅액을 2배로 늘리고 카드를 한 장만 더 받는 것. 합이 10·11일 때 유리.",
      "kind": "mutant",
      "locale": "zh-TW",
      "required": [],
      "source": "첫 두 장 받은 후 배팅액을 2배로 늘리고 카드를 한 장만 더 받는 것. 합이 10·11일 때 유리.",
      "static": true,
      "target": "拿到起手2張牌後，把下注金額加到2倍，並且只再拿1張牌。點數總和是10或11時有利。八。"
    },
    {
      "base": "tw_double_normal",
      "context": "double",
      "expected": "REJECT",
      "id": "tw_double_money",
      "key": "ui:첫 두 장 받은 후 배팅액을 2배로 늘리고 카드를 한 장만 더 받는 것. 합이 10·11일 때 유리.:/첫 두 장 받은 후 배팅액을 2배로 늘리고 카드를 한 장만 더 받는 것. 합이 10·11일 때 유리.",
      "kind": "mutant",
      "locale": "zh-TW",
      "required": [
        "translation invented a Korean-won label absent from source"
      ],
      "source": "첫 두 장 받은 후 배팅액을 2배로 늘리고 카드를 한 장만 더 받는 것. 합이 10·11일 때 유리.",
      "static": true,
      "target": "拿到起手2張牌後，把下注金額加到2倍，並且只再拿1張牌。點數總和是10或11時有利。1韓元。"
    },
    {
      "base": "tw_double_normal",
      "context": "double",
      "expected": "REJECT",
      "id": "tw_double_wrong_currency",
      "key": "ui:첫 두 장 받은 후 배팅액을 2배로 늘리고 카드를 한 장만 더 받는 것. 합이 10·11일 때 유리.:/첫 두 장 받은 후 배팅액을 2배로 늘리고 카드를 한 장만 더 받는 것. 합이 10·11일 때 유리.",
      "kind": "mutant",
      "locale": "zh-TW",
      "required": [
        "Korean won was relabeled as yen/yuan/Taiwan dollar"
      ],
      "source": "첫 두 장 받은 후 배팅액을 2배로 늘리고 카드를 한 장만 더 받는 것. 합이 10·11일 때 유리.",
      "static": true,
      "target": "拿到起手2張牌後，把下注金額加到2倍，並且只再拿1張牌。點數總和是10或11時有利。1日元。"
    },
    {
      "base": "tw_double_normal",
      "context": "double",
      "expected": "REJECT",
      "id": "tw_double_token",
      "key": "ui:첫 두 장 받은 후 배팅액을 2배로 늘리고 카드를 한 장만 더 받는 것. 합이 10·11일 때 유리.:/첫 두 장 받은 후 배팅액을 2배로 늘리고 카드를 한 장만 더 받는 것. 합이 10·11일 때 유리.",
      "kind": "mutant",
      "locale": "zh-TW",
      "required": [
        "placeholder/BBCode mismatch"
      ],
      "source": "첫 두 장 받은 후 배팅액을 2배로 늘리고 카드를 한 장만 더 받는 것. 합이 10·11일 때 유리.",
      "static": true,
      "target": "拿到起手2張牌後，把下注金額加到2倍，並且只再拿1張牌。點數總和是10或11時有利。%s"
    },
    {
      "base": "tw_double_normal",
      "context": "double",
      "expected": "REJECT",
      "id": "tw_double_bbcode",
      "key": "ui:첫 두 장 받은 후 배팅액을 2배로 늘리고 카드를 한 장만 더 받는 것. 합이 10·11일 때 유리.:/첫 두 장 받은 후 배팅액을 2배로 늘리고 카드를 한 장만 더 받는 것. 합이 10·11일 때 유리.",
      "kind": "mutant",
      "locale": "zh-TW",
      "required": [
        "placeholder/BBCode mismatch"
      ],
      "source": "첫 두 장 받은 후 배팅액을 2배로 늘리고 카드를 한 장만 더 받는 것. 합이 10·11일 때 유리.",
      "static": true,
      "target": "[b]拿到起手2張牌後，把下注金額加到2倍，並且只再拿1張牌。點數總和是10或11時有利。[/b]"
    },
    {
      "base": "tw_double_normal",
      "context": "double",
      "expected": "REJECT",
      "id": "tw_double_hangul",
      "key": "ui:첫 두 장 받은 후 배팅액을 2배로 늘리고 카드를 한 장만 더 받는 것. 합이 10·11일 때 유리.:/첫 두 장 받은 후 배팅액을 2배로 늘리고 카드를 한 장만 더 받는 것. 합이 10·11일 때 유리.",
      "kind": "mutant",
      "locale": "zh-TW",
      "required": [
        "Hangul remains"
      ],
      "source": "첫 두 장 받은 후 배팅액을 2배로 늘리고 카드를 한 장만 더 받는 것. 합이 10·11일 때 유리.",
      "static": true,
      "target": "拿到起手2張牌後，把下注金額加到2倍，並且只再拿1張牌。點數總和是10或11時有利。한글"
    },
    {
      "base": "tw_double_normal",
      "context": "double",
      "expected": "REJECT",
      "id": "tw_double_kana",
      "key": "ui:첫 두 장 받은 후 배팅액을 2배로 늘리고 카드를 한 장만 더 받는 것. 합이 10·11일 때 유리.:/첫 두 장 받은 후 배팅액을 2배로 늘리고 카드를 한 장만 더 받는 것. 합이 10·11일 때 유리.",
      "kind": "mutant",
      "locale": "zh-TW",
      "required": [
        "Japanese kana remains"
      ],
      "source": "첫 두 장 받은 후 배팅액을 2배로 늘리고 카드를 한 장만 더 받는 것. 합이 10·11일 때 유리.",
      "static": true,
      "target": "拿到起手2張牌後，把下注金額加到2倍，並且只再拿1張牌。點數總和是10或11時有利。かな"
    },
    {
      "base": "tw_double_normal",
      "context": "double",
      "expected": "REJECT",
      "id": "tw_double_newline",
      "key": "ui:첫 두 장 받은 후 배팅액을 2배로 늘리고 카드를 한 장만 더 받는 것. 합이 10·11일 때 유리.:/첫 두 장 받은 후 배팅액을 2배로 늘리고 카드를 한 장만 더 받는 것. 합이 10·11일 때 유리.",
      "kind": "mutant",
      "locale": "zh-TW",
      "required": [
        "newline mismatch 0 != 1"
      ],
      "source": "첫 두 장 받은 후 배팅액을 2배로 늘리고 카드를 한 장만 더 받는 것. 합이 10·11일 때 유리.",
      "static": true,
      "target": "拿到起手2張牌後，把下注金額加到2倍，並且只再拿1張牌。點數總和是10或11時有利。\n"
    },
    {
      "base": "tw_double_normal",
      "context": "double",
      "expected": "REJECT",
      "id": "tw_double_paragraph",
      "key": "ui:첫 두 장 받은 후 배팅액을 2배로 늘리고 카드를 한 장만 더 받는 것. 합이 10·11일 때 유리.:/첫 두 장 받은 후 배팅액을 2배로 늘리고 카드를 한 장만 더 받는 것. 합이 10·11일 때 유리.",
      "kind": "mutant",
      "locale": "zh-TW",
      "required": [
        "newline mismatch 0 != 2",
        "paragraph mismatch"
      ],
      "source": "첫 두 장 받은 후 배팅액을 2배로 늘리고 카드를 한 장만 더 받는 것. 합이 10·11일 때 유리.",
      "static": true,
      "target": "拿到起手2張牌後，把下注金額加到2倍，並且只再拿1張牌。點數總和是10或11時有利。\n\n"
    },
    {
      "base": "tw_double_normal",
      "context": "double",
      "expected": "REJECT",
      "id": "tw_double_script",
      "key": "ui:첫 두 장 받은 후 배팅액을 2배로 늘리고 카드를 한 장만 더 받는 것. 합이 10·11일 때 유리.:/첫 두 장 받은 후 배팅액을 2배로 늘리고 카드를 한 장만 더 받는 것. 합이 10·11일 때 유리.",
      "kind": "mutant",
      "locale": "zh-TW",
      "required": [
        "@script"
      ],
      "source": "첫 두 장 받은 후 배팅액을 2배로 늘리고 카드를 한 장만 더 받는 것. 합이 10·11일 때 유리.",
      "static": true,
      "target": "拿到起手2張牌後，把下注金額加到2倍，並且只再拿1張牌。點數總和是10或11時有利。颗"
    },
    {
      "base": "tw_double_normal",
      "context": "double",
      "expected": "REJECT",
      "id": "tw_double_english",
      "key": "ui:첫 두 장 받은 후 배팅액을 2배로 늘리고 카드를 한 장만 더 받는 것. 합이 10·11일 때 유리.:/첫 두 장 받은 후 배팅액을 2배로 늘리고 카드를 한 장만 더 받는 것. 합이 10·11일 때 유리.",
      "kind": "mutant",
      "locale": "zh-TW",
      "required": [
        "@english"
      ],
      "source": "첫 두 장 받은 후 배팅액을 2배로 늘리고 카드를 한 장만 더 받는 것. 합이 10·11일 때 유리.",
      "static": true,
      "target": "拿到起手2張牌後，把下注金額加到2倍，並且只再拿1張牌。點數總和是10或11時有利。 Please read this instruction."
    },
    {
      "base": "tw_double_normal",
      "context": "double",
      "expected": "ORIGINAL",
      "id": "tw_double_source_OFF",
      "key": "ui:첫 두 장 받은 후 배팅액을 2배로 늘리고 카드를 한 장만 더 받는 것. 합이 10·11일 때 유리.:/첫 두 장 받은 후 배팅액을 2배로 늘리고 카드를 한 장만 더 받는 것. 합이 10·11일 때 유리.",
      "kind": "OFF",
      "locale": "zh-TW",
      "required": [],
      "source": "첫 두 장 받은 후 배팅액을 2배로 늘리고 카드를 한 장만 더 받는 것. 합이 10·11일 때 유리. ",
      "static": true,
      "target": "拿到起手2張牌後，把下注金額加到2倍，並且只再拿1張牌。點數總和是10或11時有利。"
    },
    {
      "base": "tw_double_normal",
      "context": "double",
      "expected": "ORIGINAL",
      "id": "tw_double_owner_OFF",
      "key": "ui:foreign-owner:/첫 두 장 받은 후 배팅액을 2배로 늘리고 카드를 한 장만 더 받는 것. 합이 10·11일 때 유리.",
      "kind": "OFF",
      "locale": "zh-TW",
      "required": [],
      "source": "첫 두 장 받은 후 배팅액을 2배로 늘리고 카드를 한 장만 더 받는 것. 합이 10·11일 때 유리.",
      "static": false,
      "target": "拿到起手2張牌後，把下注金額加到2倍，並且只再拿1張牌。點數總和是10或11時有利。"
    },
    {
      "base": "tw_double_normal",
      "context": "double",
      "expected": "ORIGINAL",
      "id": "tw_double_pointer_OFF",
      "key": "ui:첫 두 장 받은 후 배팅액을 2배로 늘리고 카드를 한 장만 더 받는 것. 합이 10·11일 때 유리.:/첫 두 장 받은 후 배팅액을 2배로 늘리고 카드를 한 장만 더 받는 것. 합이 10·11일 때 유리.~wrong",
      "kind": "OFF",
      "locale": "zh-TW",
      "required": [],
      "source": "첫 두 장 받은 후 배팅액을 2배로 늘리고 카드를 한 장만 더 받는 것. 합이 10·11일 때 유리.",
      "static": false,
      "target": "拿到起手2張牌後，把下注金額加到2倍，並且只再拿1張牌。點數總和是10或11時有利。"
    },
    {
      "base": "tw_double_normal",
      "context": "double",
      "expected": "ORIGINAL",
      "id": "tw_double_unrelated_OFF",
      "key": "ui:세 개의 주사위가 구른다.:/세 개의 주사위가 구른다.",
      "kind": "OFF",
      "locale": "zh-TW",
      "required": [],
      "source": "세 개의 주사위가 구른다.",
      "static": true,
      "target": "拿到起手2張牌後，把下注金額加到2倍，並且只再拿1張牌。點數總和是10或11時有利。"
    },
    {
      "base": "tw_double_normal",
      "context": "double",
      "expected": "ORIGINAL",
      "id": "tw_double_locale_OFF",
      "key": "ui:첫 두 장 받은 후 배팅액을 2배로 늘리고 카드를 한 장만 더 받는 것. 합이 10·11일 때 유리.:/첫 두 장 받은 후 배팅액을 2배로 늘리고 카드를 한 장만 더 받는 것. 합이 10·11일 때 유리.",
      "kind": "OFF",
      "locale": "ja",
      "required": [],
      "source": "첫 두 장 받은 후 배팅액을 2배로 늘리고 카드를 한 장만 더 받는 것. 합이 10·11일 때 유리.",
      "static": false,
      "target": "拿到起手2張牌後，把下注金額加到2倍，並且只再拿1張牌。點數總和是10或11時有利。"
    },
    {
      "base": null,
      "context": "dice",
      "expected": "PASS",
      "id": "tw_dice_normal",
      "key": "ui:세 개의 주사위 결과에 거는 카지노 게임. 빅/스몰은 이해하기 쉽지만, 트리플이나 합계 베팅은 배당이 큰 만큼 확률이 낮다.:/세 개의 주사위 결과에 거는 카지노 게임. 빅~1스몰은 이해하기 쉽지만, 트리플이나 합계 베팅은 배당이 큰 만큼 확률이 낮다.",
      "kind": "normal",
      "locale": "zh-TW",
      "required": [],
      "source": "세 개의 주사위 결과에 거는 카지노 게임. 빅/스몰은 이해하기 쉽지만, 트리플이나 합계 베팅은 배당이 큰 만큼 확률이 낮다.",
      "static": true,
      "target": "以3顆骰子的結果下注的賭場遊戲。大/小很好理解，但押圍骰或點數總和，賠率高，押中的機率也比較低。"
    },
    {
      "base": "tw_dice_normal",
      "context": "dice",
      "expected": "REJECT",
      "id": "tw_dice_dice_value",
      "key": "ui:세 개의 주사위 결과에 거는 카지노 게임. 빅/스몰은 이해하기 쉽지만, 트리플이나 합계 베팅은 배당이 큰 만큼 확률이 낮다.:/세 개의 주사위 결과에 거는 카지노 게임. 빅~1스몰은 이해하기 쉽지만, 트리플이나 합계 베팅은 배당이 큰 만큼 확률이 낮다.",
      "kind": "mutant",
      "locale": "zh-TW",
      "required": [],
      "source": "세 개의 주사위 결과에 거는 카지노 게임. 빅/스몰은 이해하기 쉽지만, 트리플이나 합계 베팅은 배당이 큰 만큼 확률이 낮다.",
      "static": true,
      "target": "以4顆骰子的結果下注的賭場遊戲。大/小很好理解，但押圍骰或點數總和，賠率高，押中的機率也比較低。"
    },
    {
      "base": "tw_dice_normal",
      "context": "dice",
      "expected": "REJECT",
      "id": "tw_dice_dice_missing",
      "key": "ui:세 개의 주사위 결과에 거는 카지노 게임. 빅/스몰은 이해하기 쉽지만, 트리플이나 합계 베팅은 배당이 큰 만큼 확률이 낮다.:/세 개의 주사위 결과에 거는 카지노 게임. 빅~1스몰은 이해하기 쉽지만, 트리플이나 합계 베팅은 배당이 큰 만큼 확률이 낮다.",
      "kind": "mutant",
      "locale": "zh-TW",
      "required": [],
      "source": "세 개의 주사위 결과에 거는 카지노 게임. 빅/스몰은 이해하기 쉽지만, 트리플이나 합계 베팅은 배당이 큰 만큼 확률이 낮다.",
      "static": true,
      "target": "以顆骰子的結果下注的賭場遊戲。大/小很好理解，但押圍骰或點數總和，賠率高，押中的機率也比較低。"
    },
    {
      "base": "tw_dice_normal",
      "context": "dice",
      "expected": "REJECT",
      "id": "tw_dice_dice_cards",
      "key": "ui:세 개의 주사위 결과에 거는 카지노 게임. 빅/스몰은 이해하기 쉽지만, 트리플이나 합계 베팅은 배당이 큰 만큼 확률이 낮다.:/세 개의 주사위 결과에 거는 카지노 게임. 빅~1스몰은 이해하기 쉽지만, 트리플이나 합계 베팅은 배당이 큰 만큼 확률이 낮다.",
      "kind": "mutant",
      "locale": "zh-TW",
      "required": [],
      "source": "세 개의 주사위 결과에 거는 카지노 게임. 빅/스몰은 이해하기 쉽지만, 트리플이나 합계 베팅은 배당이 큰 만큼 확률이 낮다.",
      "static": true,
      "target": "以3張牌的結果下注的賭場遊戲。大/小很好理解，但押圍骰或點數總和，賠率高，押中的機率也比較低。"
    },
    {
      "base": "tw_dice_normal",
      "context": "dice",
      "expected": "REJECT",
      "id": "tw_dice_dice_chips",
      "key": "ui:세 개의 주사위 결과에 거는 카지노 게임. 빅/스몰은 이해하기 쉽지만, 트리플이나 합계 베팅은 배당이 큰 만큼 확률이 낮다.:/세 개의 주사위 결과에 거는 카지노 게임. 빅~1스몰은 이해하기 쉽지만, 트리플이나 합계 베팅은 배당이 큰 만큼 확률이 낮다.",
      "kind": "mutant",
      "locale": "zh-TW",
      "required": [],
      "source": "세 개의 주사위 결과에 거는 카지노 게임. 빅/스몰은 이해하기 쉽지만, 트리플이나 합계 베팅은 배당이 큰 만큼 확률이 낮다.",
      "static": true,
      "target": "以3枚籌碼的結果下注的賭場遊戲。大/小很好理解，但押圍骰或點數總和，賠率高，押中的機率也比較低。"
    },
    {
      "base": "tw_dice_normal",
      "context": "dice",
      "expected": "REJECT",
      "id": "tw_dice_dice_sign_plus",
      "key": "ui:세 개의 주사위 결과에 거는 카지노 게임. 빅/스몰은 이해하기 쉽지만, 트리플이나 합계 베팅은 배당이 큰 만큼 확률이 낮다.:/세 개의 주사위 결과에 거는 카지노 게임. 빅~1스몰은 이해하기 쉽지만, 트리플이나 합계 베팅은 배당이 큰 만큼 확률이 낮다.",
      "kind": "mutant",
      "locale": "zh-TW",
      "required": [],
      "source": "세 개의 주사위 결과에 거는 카지노 게임. 빅/스몰은 이해하기 쉽지만, 트리플이나 합계 베팅은 배당이 큰 만큼 확률이 낮다.",
      "static": true,
      "target": "以+3顆骰子的結果下注的賭場遊戲。大/小很好理解，但押圍骰或點數總和，賠率高，押中的機率也比較低。"
    },
    {
      "base": "tw_dice_normal",
      "context": "dice",
      "expected": "REJECT",
      "id": "tw_dice_dice_sign_minus",
      "key": "ui:세 개의 주사위 결과에 거는 카지노 게임. 빅/스몰은 이해하기 쉽지만, 트리플이나 합계 베팅은 배당이 큰 만큼 확률이 낮다.:/세 개의 주사위 결과에 거는 카지노 게임. 빅~1스몰은 이해하기 쉽지만, 트리플이나 합계 베팅은 배당이 큰 만큼 확률이 낮다.",
      "kind": "mutant",
      "locale": "zh-TW",
      "required": [],
      "source": "세 개의 주사위 결과에 거는 카지노 게임. 빅/스몰은 이해하기 쉽지만, 트리플이나 합계 베팅은 배당이 큰 만큼 확률이 낮다.",
      "static": true,
      "target": "以-3顆骰子的結果下注的賭場遊戲。大/小很好理解，但押圍骰或點數總和，賠率高，押中的機率也比較低。"
    },
    {
      "base": "tw_dice_normal",
      "context": "dice",
      "expected": "REJECT",
      "id": "tw_dice_dice_decimal",
      "key": "ui:세 개의 주사위 결과에 거는 카지노 게임. 빅/스몰은 이해하기 쉽지만, 트리플이나 합계 베팅은 배당이 큰 만큼 확률이 낮다.:/세 개의 주사위 결과에 거는 카지노 게임. 빅~1스몰은 이해하기 쉽지만, 트리플이나 합계 베팅은 배당이 큰 만큼 확률이 낮다.",
      "kind": "mutant",
      "locale": "zh-TW",
      "required": [],
      "source": "세 개의 주사위 결과에 거는 카지노 게임. 빅/스몰은 이해하기 쉽지만, 트리플이나 합계 베팅은 배당이 큰 만큼 확률이 낮다.",
      "static": true,
      "target": "以3.5顆骰子的結果下注的賭場遊戲。大/小很好理解，但押圍骰或點數總和，賠率高，押中的機率也比較低。"
    },
    {
      "base": "tw_dice_normal",
      "context": "dice",
      "expected": "REJECT",
      "id": "tw_dice_dice_percent",
      "key": "ui:세 개의 주사위 결과에 거는 카지노 게임. 빅/스몰은 이해하기 쉽지만, 트리플이나 합계 베팅은 배당이 큰 만큼 확률이 낮다.:/세 개의 주사위 결과에 거는 카지노 게임. 빅~1스몰은 이해하기 쉽지만, 트리플이나 합계 베팅은 배당이 큰 만큼 확률이 낮다.",
      "kind": "mutant",
      "locale": "zh-TW",
      "required": [],
      "source": "세 개의 주사위 결과에 거는 카지노 게임. 빅/스몰은 이해하기 쉽지만, 트리플이나 합계 베팅은 배당이 큰 만큼 확률이 낮다.",
      "static": true,
      "target": "以3%顆骰子的結果下注的賭場遊戲。大/小很好理解，但押圍骰或點數總和，賠率高，押中的機率也比較低。"
    },
    {
      "base": "tw_dice_normal",
      "context": "dice",
      "expected": "REJECT",
      "id": "tw_dice_dice_time",
      "key": "ui:세 개의 주사위 결과에 거는 카지노 게임. 빅/스몰은 이해하기 쉽지만, 트리플이나 합계 베팅은 배당이 큰 만큼 확률이 낮다.:/세 개의 주사위 결과에 거는 카지노 게임. 빅~1스몰은 이해하기 쉽지만, 트리플이나 합계 베팅은 배당이 큰 만큼 확률이 낮다.",
      "kind": "mutant",
      "locale": "zh-TW",
      "required": [],
      "source": "세 개의 주사위 결과에 거는 카지노 게임. 빅/스몰은 이해하기 쉽지만, 트리플이나 합계 베팅은 배당이 큰 만큼 확률이 낮다.",
      "static": true,
      "target": "以3:00顆骰子的結果下注的賭場遊戲。大/小很好理解，但押圍骰或點數總和，賠率高，押中的機率也比較低。"
    },
    {
      "base": "tw_dice_normal",
      "context": "dice",
      "expected": "REJECT",
      "id": "tw_dice_dice_days",
      "key": "ui:세 개의 주사위 결과에 거는 카지노 게임. 빅/스몰은 이해하기 쉽지만, 트리플이나 합계 베팅은 배당이 큰 만큼 확률이 낮다.:/세 개의 주사위 결과에 거는 카지노 게임. 빅~1스몰은 이해하기 쉽지만, 트리플이나 합계 베팅은 배당이 큰 만큼 확률이 낮다.",
      "kind": "mutant",
      "locale": "zh-TW",
      "required": [],
      "source": "세 개의 주사위 결과에 거는 카지노 게임. 빅/스몰은 이해하기 쉽지만, 트리플이나 합계 베팅은 배당이 큰 만큼 확률이 낮다.",
      "static": true,
      "target": "以3天的結果下注的賭場遊戲。大/小很好理解，但押圍骰或點數總和，賠率高，押中的機率也比較低。"
    },
    {
      "base": "tw_dice_normal",
      "context": "dice",
      "expected": "REJECT",
      "id": "tw_dice_duplicate_dice",
      "key": "ui:세 개의 주사위 결과에 거는 카지노 게임. 빅/스몰은 이해하기 쉽지만, 트리플이나 합계 베팅은 배당이 큰 만큼 확률이 낮다.:/세 개의 주사위 결과에 거는 카지노 게임. 빅~1스몰은 이해하기 쉽지만, 트리플이나 합계 베팅은 배당이 큰 만큼 확률이 낮다.",
      "kind": "mutant",
      "locale": "zh-TW",
      "required": [],
      "source": "세 개의 주사위 결과에 거는 카지노 게임. 빅/스몰은 이해하기 쉽지만, 트리플이나 합계 베팅은 배당이 큰 만큼 확률이 낮다.",
      "static": true,
      "target": "以3顆骰子的結果下注的賭場遊戲。大/小很好理解，但押圍骰或點數總和，賠率高，押中的機率也比較低。3顆骰子。"
    },
    {
      "base": "tw_dice_normal",
      "context": "dice",
      "expected": "REJECT",
      "id": "tw_dice_extra_number",
      "key": "ui:세 개의 주사위 결과에 거는 카지노 게임. 빅/스몰은 이해하기 쉽지만, 트리플이나 합계 베팅은 배당이 큰 만큼 확률이 낮다.:/세 개의 주사위 결과에 거는 카지노 게임. 빅~1스몰은 이해하기 쉽지만, 트리플이나 합계 베팅은 배당이 큰 만큼 확률이 낮다.",
      "kind": "mutant",
      "locale": "zh-TW",
      "required": [],
      "source": "세 개의 주사위 결과에 거는 카지노 게임. 빅/스몰은 이해하기 쉽지만, 트리플이나 합계 베팅은 배당이 큰 만큼 확률이 낮다.",
      "static": true,
      "target": "以3顆骰子的結果下注的賭場遊戲。大/小很好理解，但押圍骰或點數總和，賠率高，押中的機率也比較低。8。"
    },
    {
      "base": "tw_dice_normal",
      "context": "dice",
      "expected": "REJECT",
      "id": "tw_dice_extra_native_number",
      "key": "ui:세 개의 주사위 결과에 거는 카지노 게임. 빅/스몰은 이해하기 쉽지만, 트리플이나 합계 베팅은 배당이 큰 만큼 확률이 낮다.:/세 개의 주사위 결과에 거는 카지노 게임. 빅~1스몰은 이해하기 쉽지만, 트리플이나 합계 베팅은 배당이 큰 만큼 확률이 낮다.",
      "kind": "mutant",
      "locale": "zh-TW",
      "required": [],
      "source": "세 개의 주사위 결과에 거는 카지노 게임. 빅/스몰은 이해하기 쉽지만, 트리플이나 합계 베팅은 배당이 큰 만큼 확률이 낮다.",
      "static": true,
      "target": "以3顆骰子的結果下注的賭場遊戲。大/小很好理解，但押圍骰或點數總和，賠率高，押中的機率也比較低。八。"
    },
    {
      "base": "tw_dice_normal",
      "context": "dice",
      "expected": "REJECT",
      "id": "tw_dice_money",
      "key": "ui:세 개의 주사위 결과에 거는 카지노 게임. 빅/스몰은 이해하기 쉽지만, 트리플이나 합계 베팅은 배당이 큰 만큼 확률이 낮다.:/세 개의 주사위 결과에 거는 카지노 게임. 빅~1스몰은 이해하기 쉽지만, 트리플이나 합계 베팅은 배당이 큰 만큼 확률이 낮다.",
      "kind": "mutant",
      "locale": "zh-TW",
      "required": [
        "translation invented a Korean-won label absent from source"
      ],
      "source": "세 개의 주사위 결과에 거는 카지노 게임. 빅/스몰은 이해하기 쉽지만, 트리플이나 합계 베팅은 배당이 큰 만큼 확률이 낮다.",
      "static": true,
      "target": "以3顆骰子的結果下注的賭場遊戲。大/小很好理解，但押圍骰或點數總和，賠率高，押中的機率也比較低。1韓元。"
    },
    {
      "base": "tw_dice_normal",
      "context": "dice",
      "expected": "REJECT",
      "id": "tw_dice_wrong_currency",
      "key": "ui:세 개의 주사위 결과에 거는 카지노 게임. 빅/스몰은 이해하기 쉽지만, 트리플이나 합계 베팅은 배당이 큰 만큼 확률이 낮다.:/세 개의 주사위 결과에 거는 카지노 게임. 빅~1스몰은 이해하기 쉽지만, 트리플이나 합계 베팅은 배당이 큰 만큼 확률이 낮다.",
      "kind": "mutant",
      "locale": "zh-TW",
      "required": [
        "Korean won was relabeled as yen/yuan/Taiwan dollar"
      ],
      "source": "세 개의 주사위 결과에 거는 카지노 게임. 빅/스몰은 이해하기 쉽지만, 트리플이나 합계 베팅은 배당이 큰 만큼 확률이 낮다.",
      "static": true,
      "target": "以3顆骰子的結果下注的賭場遊戲。大/小很好理解，但押圍骰或點數總和，賠率高，押中的機率也比較低。1日元。"
    },
    {
      "base": "tw_dice_normal",
      "context": "dice",
      "expected": "REJECT",
      "id": "tw_dice_token",
      "key": "ui:세 개의 주사위 결과에 거는 카지노 게임. 빅/스몰은 이해하기 쉽지만, 트리플이나 합계 베팅은 배당이 큰 만큼 확률이 낮다.:/세 개의 주사위 결과에 거는 카지노 게임. 빅~1스몰은 이해하기 쉽지만, 트리플이나 합계 베팅은 배당이 큰 만큼 확률이 낮다.",
      "kind": "mutant",
      "locale": "zh-TW",
      "required": [
        "placeholder/BBCode mismatch"
      ],
      "source": "세 개의 주사위 결과에 거는 카지노 게임. 빅/스몰은 이해하기 쉽지만, 트리플이나 합계 베팅은 배당이 큰 만큼 확률이 낮다.",
      "static": true,
      "target": "以3顆骰子的結果下注的賭場遊戲。大/小很好理解，但押圍骰或點數總和，賠率高，押中的機率也比較低。%s"
    },
    {
      "base": "tw_dice_normal",
      "context": "dice",
      "expected": "REJECT",
      "id": "tw_dice_bbcode",
      "key": "ui:세 개의 주사위 결과에 거는 카지노 게임. 빅/스몰은 이해하기 쉽지만, 트리플이나 합계 베팅은 배당이 큰 만큼 확률이 낮다.:/세 개의 주사위 결과에 거는 카지노 게임. 빅~1스몰은 이해하기 쉽지만, 트리플이나 합계 베팅은 배당이 큰 만큼 확률이 낮다.",
      "kind": "mutant",
      "locale": "zh-TW",
      "required": [
        "placeholder/BBCode mismatch"
      ],
      "source": "세 개의 주사위 결과에 거는 카지노 게임. 빅/스몰은 이해하기 쉽지만, 트리플이나 합계 베팅은 배당이 큰 만큼 확률이 낮다.",
      "static": true,
      "target": "[b]以3顆骰子的結果下注的賭場遊戲。大/小很好理解，但押圍骰或點數總和，賠率高，押中的機率也比較低。[/b]"
    },
    {
      "base": "tw_dice_normal",
      "context": "dice",
      "expected": "REJECT",
      "id": "tw_dice_hangul",
      "key": "ui:세 개의 주사위 결과에 거는 카지노 게임. 빅/스몰은 이해하기 쉽지만, 트리플이나 합계 베팅은 배당이 큰 만큼 확률이 낮다.:/세 개의 주사위 결과에 거는 카지노 게임. 빅~1스몰은 이해하기 쉽지만, 트리플이나 합계 베팅은 배당이 큰 만큼 확률이 낮다.",
      "kind": "mutant",
      "locale": "zh-TW",
      "required": [
        "Hangul remains"
      ],
      "source": "세 개의 주사위 결과에 거는 카지노 게임. 빅/스몰은 이해하기 쉽지만, 트리플이나 합계 베팅은 배당이 큰 만큼 확률이 낮다.",
      "static": true,
      "target": "以3顆骰子的結果下注的賭場遊戲。大/小很好理解，但押圍骰或點數總和，賠率高，押中的機率也比較低。한글"
    },
    {
      "base": "tw_dice_normal",
      "context": "dice",
      "expected": "REJECT",
      "id": "tw_dice_kana",
      "key": "ui:세 개의 주사위 결과에 거는 카지노 게임. 빅/스몰은 이해하기 쉽지만, 트리플이나 합계 베팅은 배당이 큰 만큼 확률이 낮다.:/세 개의 주사위 결과에 거는 카지노 게임. 빅~1스몰은 이해하기 쉽지만, 트리플이나 합계 베팅은 배당이 큰 만큼 확률이 낮다.",
      "kind": "mutant",
      "locale": "zh-TW",
      "required": [
        "Japanese kana remains"
      ],
      "source": "세 개의 주사위 결과에 거는 카지노 게임. 빅/스몰은 이해하기 쉽지만, 트리플이나 합계 베팅은 배당이 큰 만큼 확률이 낮다.",
      "static": true,
      "target": "以3顆骰子的結果下注的賭場遊戲。大/小很好理解，但押圍骰或點數總和，賠率高，押中的機率也比較低。かな"
    },
    {
      "base": "tw_dice_normal",
      "context": "dice",
      "expected": "REJECT",
      "id": "tw_dice_newline",
      "key": "ui:세 개의 주사위 결과에 거는 카지노 게임. 빅/스몰은 이해하기 쉽지만, 트리플이나 합계 베팅은 배당이 큰 만큼 확률이 낮다.:/세 개의 주사위 결과에 거는 카지노 게임. 빅~1스몰은 이해하기 쉽지만, 트리플이나 합계 베팅은 배당이 큰 만큼 확률이 낮다.",
      "kind": "mutant",
      "locale": "zh-TW",
      "required": [
        "newline mismatch 0 != 1"
      ],
      "source": "세 개의 주사위 결과에 거는 카지노 게임. 빅/스몰은 이해하기 쉽지만, 트리플이나 합계 베팅은 배당이 큰 만큼 확률이 낮다.",
      "static": true,
      "target": "以3顆骰子的結果下注的賭場遊戲。大/小很好理解，但押圍骰或點數總和，賠率高，押中的機率也比較低。\n"
    },
    {
      "base": "tw_dice_normal",
      "context": "dice",
      "expected": "REJECT",
      "id": "tw_dice_paragraph",
      "key": "ui:세 개의 주사위 결과에 거는 카지노 게임. 빅/스몰은 이해하기 쉽지만, 트리플이나 합계 베팅은 배당이 큰 만큼 확률이 낮다.:/세 개의 주사위 결과에 거는 카지노 게임. 빅~1스몰은 이해하기 쉽지만, 트리플이나 합계 베팅은 배당이 큰 만큼 확률이 낮다.",
      "kind": "mutant",
      "locale": "zh-TW",
      "required": [
        "newline mismatch 0 != 2",
        "paragraph mismatch"
      ],
      "source": "세 개의 주사위 결과에 거는 카지노 게임. 빅/스몰은 이해하기 쉽지만, 트리플이나 합계 베팅은 배당이 큰 만큼 확률이 낮다.",
      "static": true,
      "target": "以3顆骰子的結果下注的賭場遊戲。大/小很好理解，但押圍骰或點數總和，賠率高，押中的機率也比較低。\n\n"
    },
    {
      "base": "tw_dice_normal",
      "context": "dice",
      "expected": "REJECT",
      "id": "tw_dice_script",
      "key": "ui:세 개의 주사위 결과에 거는 카지노 게임. 빅/스몰은 이해하기 쉽지만, 트리플이나 합계 베팅은 배당이 큰 만큼 확률이 낮다.:/세 개의 주사위 결과에 거는 카지노 게임. 빅~1스몰은 이해하기 쉽지만, 트리플이나 합계 베팅은 배당이 큰 만큼 확률이 낮다.",
      "kind": "mutant",
      "locale": "zh-TW",
      "required": [
        "@script"
      ],
      "source": "세 개의 주사위 결과에 거는 카지노 게임. 빅/스몰은 이해하기 쉽지만, 트리플이나 합계 베팅은 배당이 큰 만큼 확률이 낮다.",
      "static": true,
      "target": "以3顆骰子的結果下注的賭場遊戲。大/小很好理解，但押圍骰或點數總和，賠率高，押中的機率也比較低。颗"
    },
    {
      "base": "tw_dice_normal",
      "context": "dice",
      "expected": "REJECT",
      "id": "tw_dice_english",
      "key": "ui:세 개의 주사위 결과에 거는 카지노 게임. 빅/스몰은 이해하기 쉽지만, 트리플이나 합계 베팅은 배당이 큰 만큼 확률이 낮다.:/세 개의 주사위 결과에 거는 카지노 게임. 빅~1스몰은 이해하기 쉽지만, 트리플이나 합계 베팅은 배당이 큰 만큼 확률이 낮다.",
      "kind": "mutant",
      "locale": "zh-TW",
      "required": [
        "@english"
      ],
      "source": "세 개의 주사위 결과에 거는 카지노 게임. 빅/스몰은 이해하기 쉽지만, 트리플이나 합계 베팅은 배당이 큰 만큼 확률이 낮다.",
      "static": true,
      "target": "以3顆骰子的結果下注的賭場遊戲。大/小很好理解，但押圍骰或點數總和，賠率高，押中的機率也比較低。 Please read this instruction."
    },
    {
      "base": "tw_dice_normal",
      "context": "dice",
      "expected": "ORIGINAL",
      "id": "tw_dice_source_OFF",
      "key": "ui:세 개의 주사위 결과에 거는 카지노 게임. 빅/스몰은 이해하기 쉽지만, 트리플이나 합계 베팅은 배당이 큰 만큼 확률이 낮다.:/세 개의 주사위 결과에 거는 카지노 게임. 빅~1스몰은 이해하기 쉽지만, 트리플이나 합계 베팅은 배당이 큰 만큼 확률이 낮다.",
      "kind": "OFF",
      "locale": "zh-TW",
      "required": [],
      "source": "세 개의 주사위 결과에 거는 카지노 게임. 빅/스몰은 이해하기 쉽지만, 트리플이나 합계 베팅은 배당이 큰 만큼 확률이 낮다. ",
      "static": true,
      "target": "以3顆骰子的結果下注的賭場遊戲。大/小很好理解，但押圍骰或點數總和，賠率高，押中的機率也比較低。"
    },
    {
      "base": "tw_dice_normal",
      "context": "dice",
      "expected": "ORIGINAL",
      "id": "tw_dice_owner_OFF",
      "key": "ui:foreign-owner:/세 개의 주사위 결과에 거는 카지노 게임. 빅~1스몰은 이해하기 쉽지만, 트리플이나 합계 베팅은 배당이 큰 만큼 확률이 낮다.",
      "kind": "OFF",
      "locale": "zh-TW",
      "required": [],
      "source": "세 개의 주사위 결과에 거는 카지노 게임. 빅/스몰은 이해하기 쉽지만, 트리플이나 합계 베팅은 배당이 큰 만큼 확률이 낮다.",
      "static": false,
      "target": "以3顆骰子的結果下注的賭場遊戲。大/小很好理解，但押圍骰或點數總和，賠率高，押中的機率也比較低。"
    },
    {
      "base": "tw_dice_normal",
      "context": "dice",
      "expected": "ORIGINAL",
      "id": "tw_dice_pointer_OFF",
      "key": "ui:세 개의 주사위 결과에 거는 카지노 게임. 빅/스몰은 이해하기 쉽지만, 트리플이나 합계 베팅은 배당이 큰 만큼 확률이 낮다.:/세 개의 주사위 결과에 거는 카지노 게임. 빅~1스몰은 이해하기 쉽지만, 트리플이나 합계 베팅은 배당이 큰 만큼 확률이 낮다.~wrong",
      "kind": "OFF",
      "locale": "zh-TW",
      "required": [],
      "source": "세 개의 주사위 결과에 거는 카지노 게임. 빅/스몰은 이해하기 쉽지만, 트리플이나 합계 베팅은 배당이 큰 만큼 확률이 낮다.",
      "static": false,
      "target": "以3顆骰子的結果下注的賭場遊戲。大/小很好理解，但押圍骰或點數總和，賠率高，押中的機率也比較低。"
    },
    {
      "base": "tw_dice_normal",
      "context": "dice",
      "expected": "ORIGINAL",
      "id": "tw_dice_unrelated_OFF",
      "key": "ui:세 개의 주사위가 구른다.:/세 개의 주사위가 구른다.",
      "kind": "OFF",
      "locale": "zh-TW",
      "required": [],
      "source": "세 개의 주사위가 구른다.",
      "static": true,
      "target": "以3顆骰子的結果下注的賭場遊戲。大/小很好理解，但押圍骰或點數總和，賠率高，押中的機率也比較低。"
    },
    {
      "base": "tw_dice_normal",
      "context": "dice",
      "expected": "ORIGINAL",
      "id": "tw_dice_locale_OFF",
      "key": "ui:세 개의 주사위 결과에 거는 카지노 게임. 빅/스몰은 이해하기 쉽지만, 트리플이나 합계 베팅은 배당이 큰 만큼 확률이 낮다.:/세 개의 주사위 결과에 거는 카지노 게임. 빅~1스몰은 이해하기 쉽지만, 트리플이나 합계 베팅은 배당이 큰 만큼 확률이 낮다.",
      "kind": "OFF",
      "locale": "ja",
      "required": [],
      "source": "세 개의 주사위 결과에 거는 카지노 게임. 빅/스몰은 이해하기 쉽지만, 트리플이나 합계 베팅은 배당이 큰 만큼 확률이 낮다.",
      "static": false,
      "target": "以3顆骰子的結果下注的賭場遊戲。大/小很好理解，但押圍骰或點數總和，賠率高，押中的機率也比較低。"
    },
    {
      "base": "tw_dice_normal",
      "context": "dice",
      "expected": "ORIGINAL",
      "id": "tw_dice_unescaped_pointer_OFF",
      "key": "ui:세 개의 주사위 결과에 거는 카지노 게임. 빅/스몰은 이해하기 쉽지만, 트리플이나 합계 베팅은 배당이 큰 만큼 확률이 낮다.:/세 개의 주사위 결과에 거는 카지노 게임. 빅/스몰은 이해하기 쉽지만, 트리플이나 합계 베팅은 배당이 큰 만큼 확률이 낮다.",
      "kind": "OFF",
      "locale": "zh-TW",
      "required": [],
      "source": "세 개의 주사위 결과에 거는 카지노 게임. 빅/스몰은 이해하기 쉽지만, 트리플이나 합계 베팅은 배당이 큰 만큼 확률이 낮다.",
      "static": false,
      "target": "以3顆骰子的結果下注的賭場遊戲。大/小很好理解，但押圍骰或點數總和，賠率高，押中的機率也比較低。"
    },
    {
      "base": null,
      "context": "ranges",
      "expected": "PASS",
      "id": "tw_ranges_normal",
      "key": "ui:주사위 합계 11~17은 빅, 4~10은 스몰. 단, 세 주사위가 모두 같은 트리플이면 빅/스몰은 패배 처리된다.:/주사위 합계 11~017은 빅, 4~010은 스몰. 단, 세 주사위가 모두 같은 트리플이면 빅~1스몰은 패배 처리된다.",
      "kind": "normal",
      "locale": "zh-TW",
      "required": [],
      "source": "주사위 합계 11~17은 빅, 4~10은 스몰. 단, 세 주사위가 모두 같은 트리플이면 빅/스몰은 패배 처리된다.",
      "static": true,
      "target": "骰子點數總和11~17算大，4~10算小。但若3顆骰子點數全部相同，形成圍骰，押大/小都算輸。"
    },
    {
      "base": "tw_ranges_normal",
      "context": "ranges",
      "expected": "REJECT",
      "id": "tw_ranges_dice_value",
      "key": "ui:주사위 합계 11~17은 빅, 4~10은 스몰. 단, 세 주사위가 모두 같은 트리플이면 빅/스몰은 패배 처리된다.:/주사위 합계 11~017은 빅, 4~010은 스몰. 단, 세 주사위가 모두 같은 트리플이면 빅~1스몰은 패배 처리된다.",
      "kind": "mutant",
      "locale": "zh-TW",
      "required": [],
      "source": "주사위 합계 11~17은 빅, 4~10은 스몰. 단, 세 주사위가 모두 같은 트리플이면 빅/스몰은 패배 처리된다.",
      "static": true,
      "target": "骰子點數總和11~17算大，4~10算小。但若4顆骰子點數全部相同，形成圍骰，押大/小都算輸。"
    },
    {
      "base": "tw_ranges_normal",
      "context": "ranges",
      "expected": "REJECT",
      "id": "tw_ranges_dice_missing",
      "key": "ui:주사위 합계 11~17은 빅, 4~10은 스몰. 단, 세 주사위가 모두 같은 트리플이면 빅/스몰은 패배 처리된다.:/주사위 합계 11~017은 빅, 4~010은 스몰. 단, 세 주사위가 모두 같은 트리플이면 빅~1스몰은 패배 처리된다.",
      "kind": "mutant",
      "locale": "zh-TW",
      "required": [],
      "source": "주사위 합계 11~17은 빅, 4~10은 스몰. 단, 세 주사위가 모두 같은 트리플이면 빅/스몰은 패배 처리된다.",
      "static": true,
      "target": "骰子點數總和11~17算大，4~10算小。但若顆骰子點數全部相同，形成圍骰，押大/小都算輸。"
    },
    {
      "base": "tw_ranges_normal",
      "context": "ranges",
      "expected": "REJECT",
      "id": "tw_ranges_dice_cards",
      "key": "ui:주사위 합계 11~17은 빅, 4~10은 스몰. 단, 세 주사위가 모두 같은 트리플이면 빅/스몰은 패배 처리된다.:/주사위 합계 11~017은 빅, 4~010은 스몰. 단, 세 주사위가 모두 같은 트리플이면 빅~1스몰은 패배 처리된다.",
      "kind": "mutant",
      "locale": "zh-TW",
      "required": [],
      "source": "주사위 합계 11~17은 빅, 4~10은 스몰. 단, 세 주사위가 모두 같은 트리플이면 빅/스몰은 패배 처리된다.",
      "static": true,
      "target": "骰子點數總和11~17算大，4~10算小。但若3張牌點數全部相同，形成圍骰，押大/小都算輸。"
    },
    {
      "base": "tw_ranges_normal",
      "context": "ranges",
      "expected": "REJECT",
      "id": "tw_ranges_dice_chips",
      "key": "ui:주사위 합계 11~17은 빅, 4~10은 스몰. 단, 세 주사위가 모두 같은 트리플이면 빅/스몰은 패배 처리된다.:/주사위 합계 11~017은 빅, 4~010은 스몰. 단, 세 주사위가 모두 같은 트리플이면 빅~1스몰은 패배 처리된다.",
      "kind": "mutant",
      "locale": "zh-TW",
      "required": [],
      "source": "주사위 합계 11~17은 빅, 4~10은 스몰. 단, 세 주사위가 모두 같은 트리플이면 빅/스몰은 패배 처리된다.",
      "static": true,
      "target": "骰子點數總和11~17算大，4~10算小。但若3枚籌碼點數全部相同，形成圍骰，押大/小都算輸。"
    },
    {
      "base": "tw_ranges_normal",
      "context": "ranges",
      "expected": "REJECT",
      "id": "tw_ranges_dice_sign_plus",
      "key": "ui:주사위 합계 11~17은 빅, 4~10은 스몰. 단, 세 주사위가 모두 같은 트리플이면 빅/스몰은 패배 처리된다.:/주사위 합계 11~017은 빅, 4~010은 스몰. 단, 세 주사위가 모두 같은 트리플이면 빅~1스몰은 패배 처리된다.",
      "kind": "mutant",
      "locale": "zh-TW",
      "required": [],
      "source": "주사위 합계 11~17은 빅, 4~10은 스몰. 단, 세 주사위가 모두 같은 트리플이면 빅/스몰은 패배 처리된다.",
      "static": true,
      "target": "骰子點數總和11~17算大，4~10算小。但若+3顆骰子點數全部相同，形成圍骰，押大/小都算輸。"
    },
    {
      "base": "tw_ranges_normal",
      "context": "ranges",
      "expected": "REJECT",
      "id": "tw_ranges_dice_sign_minus",
      "key": "ui:주사위 합계 11~17은 빅, 4~10은 스몰. 단, 세 주사위가 모두 같은 트리플이면 빅/스몰은 패배 처리된다.:/주사위 합계 11~017은 빅, 4~010은 스몰. 단, 세 주사위가 모두 같은 트리플이면 빅~1스몰은 패배 처리된다.",
      "kind": "mutant",
      "locale": "zh-TW",
      "required": [],
      "source": "주사위 합계 11~17은 빅, 4~10은 스몰. 단, 세 주사위가 모두 같은 트리플이면 빅/스몰은 패배 처리된다.",
      "static": true,
      "target": "骰子點數總和11~17算大，4~10算小。但若-3顆骰子點數全部相同，形成圍骰，押大/小都算輸。"
    },
    {
      "base": "tw_ranges_normal",
      "context": "ranges",
      "expected": "REJECT",
      "id": "tw_ranges_dice_decimal",
      "key": "ui:주사위 합계 11~17은 빅, 4~10은 스몰. 단, 세 주사위가 모두 같은 트리플이면 빅/스몰은 패배 처리된다.:/주사위 합계 11~017은 빅, 4~010은 스몰. 단, 세 주사위가 모두 같은 트리플이면 빅~1스몰은 패배 처리된다.",
      "kind": "mutant",
      "locale": "zh-TW",
      "required": [],
      "source": "주사위 합계 11~17은 빅, 4~10은 스몰. 단, 세 주사위가 모두 같은 트리플이면 빅/스몰은 패배 처리된다.",
      "static": true,
      "target": "骰子點數總和11~17算大，4~10算小。但若3.5顆骰子點數全部相同，形成圍骰，押大/小都算輸。"
    },
    {
      "base": "tw_ranges_normal",
      "context": "ranges",
      "expected": "REJECT",
      "id": "tw_ranges_dice_percent",
      "key": "ui:주사위 합계 11~17은 빅, 4~10은 스몰. 단, 세 주사위가 모두 같은 트리플이면 빅/스몰은 패배 처리된다.:/주사위 합계 11~017은 빅, 4~010은 스몰. 단, 세 주사위가 모두 같은 트리플이면 빅~1스몰은 패배 처리된다.",
      "kind": "mutant",
      "locale": "zh-TW",
      "required": [],
      "source": "주사위 합계 11~17은 빅, 4~10은 스몰. 단, 세 주사위가 모두 같은 트리플이면 빅/스몰은 패배 처리된다.",
      "static": true,
      "target": "骰子點數總和11~17算大，4~10算小。但若3%顆骰子點數全部相同，形成圍骰，押大/小都算輸。"
    },
    {
      "base": "tw_ranges_normal",
      "context": "ranges",
      "expected": "REJECT",
      "id": "tw_ranges_dice_time",
      "key": "ui:주사위 합계 11~17은 빅, 4~10은 스몰. 단, 세 주사위가 모두 같은 트리플이면 빅/스몰은 패배 처리된다.:/주사위 합계 11~017은 빅, 4~010은 스몰. 단, 세 주사위가 모두 같은 트리플이면 빅~1스몰은 패배 처리된다.",
      "kind": "mutant",
      "locale": "zh-TW",
      "required": [],
      "source": "주사위 합계 11~17은 빅, 4~10은 스몰. 단, 세 주사위가 모두 같은 트리플이면 빅/스몰은 패배 처리된다.",
      "static": true,
      "target": "骰子點數總和11~17算大，4~10算小。但若3:00顆骰子點數全部相同，形成圍骰，押大/小都算輸。"
    },
    {
      "base": "tw_ranges_normal",
      "context": "ranges",
      "expected": "REJECT",
      "id": "tw_ranges_dice_days",
      "key": "ui:주사위 합계 11~17은 빅, 4~10은 스몰. 단, 세 주사위가 모두 같은 트리플이면 빅/스몰은 패배 처리된다.:/주사위 합계 11~017은 빅, 4~010은 스몰. 단, 세 주사위가 모두 같은 트리플이면 빅~1스몰은 패배 처리된다.",
      "kind": "mutant",
      "locale": "zh-TW",
      "required": [],
      "source": "주사위 합계 11~17은 빅, 4~10은 스몰. 단, 세 주사위가 모두 같은 트리플이면 빅/스몰은 패배 처리된다.",
      "static": true,
      "target": "骰子點數總和11~17算大，4~10算小。但若3天點數全部相同，形成圍骰，押大/小都算輸。"
    },
    {
      "base": "tw_ranges_normal",
      "context": "ranges",
      "expected": "REJECT",
      "id": "tw_ranges_duplicate_dice",
      "key": "ui:주사위 합계 11~17은 빅, 4~10은 스몰. 단, 세 주사위가 모두 같은 트리플이면 빅/스몰은 패배 처리된다.:/주사위 합계 11~017은 빅, 4~010은 스몰. 단, 세 주사위가 모두 같은 트리플이면 빅~1스몰은 패배 처리된다.",
      "kind": "mutant",
      "locale": "zh-TW",
      "required": [],
      "source": "주사위 합계 11~17은 빅, 4~10은 스몰. 단, 세 주사위가 모두 같은 트리플이면 빅/스몰은 패배 처리된다.",
      "static": true,
      "target": "骰子點數總和11~17算大，4~10算小。但若3顆骰子點數全部相同，形成圍骰，押大/小都算輸。3顆骰子。"
    },
    {
      "base": "tw_ranges_normal",
      "context": "ranges",
      "expected": "REJECT",
      "id": "tw_ranges_big_lower",
      "key": "ui:주사위 합계 11~17은 빅, 4~10은 스몰. 단, 세 주사위가 모두 같은 트리플이면 빅/스몰은 패배 처리된다.:/주사위 합계 11~017은 빅, 4~010은 스몰. 단, 세 주사위가 모두 같은 트리플이면 빅~1스몰은 패배 처리된다.",
      "kind": "mutant",
      "locale": "zh-TW",
      "required": [],
      "source": "주사위 합계 11~17은 빅, 4~10은 스몰. 단, 세 주사위가 모두 같은 트리플이면 빅/스몰은 패배 처리된다.",
      "static": true,
      "target": "骰子點數總和12~17算大，4~10算小。但若3顆骰子點數全部相同，形成圍骰，押大/小都算輸。"
    },
    {
      "base": "tw_ranges_normal",
      "context": "ranges",
      "expected": "REJECT",
      "id": "tw_ranges_big_upper",
      "key": "ui:주사위 합계 11~17은 빅, 4~10은 스몰. 단, 세 주사위가 모두 같은 트리플이면 빅/스몰은 패배 처리된다.:/주사위 합계 11~017은 빅, 4~010은 스몰. 단, 세 주사위가 모두 같은 트리플이면 빅~1스몰은 패배 처리된다.",
      "kind": "mutant",
      "locale": "zh-TW",
      "required": [],
      "source": "주사위 합계 11~17은 빅, 4~10은 스몰. 단, 세 주사위가 모두 같은 트리플이면 빅/스몰은 패배 처리된다.",
      "static": true,
      "target": "骰子點數總和11~18算大，4~10算小。但若3顆骰子點數全部相同，形成圍骰，押大/小都算輸。"
    },
    {
      "base": "tw_ranges_normal",
      "context": "ranges",
      "expected": "REJECT",
      "id": "tw_ranges_small_lower",
      "key": "ui:주사위 합계 11~17은 빅, 4~10은 스몰. 단, 세 주사위가 모두 같은 트리플이면 빅/스몰은 패배 처리된다.:/주사위 합계 11~017은 빅, 4~010은 스몰. 단, 세 주사위가 모두 같은 트리플이면 빅~1스몰은 패배 처리된다.",
      "kind": "mutant",
      "locale": "zh-TW",
      "required": [],
      "source": "주사위 합계 11~17은 빅, 4~10은 스몰. 단, 세 주사위가 모두 같은 트리플이면 빅/스몰은 패배 처리된다.",
      "static": true,
      "target": "骰子點數總和11~17算大，5~10算小。但若3顆骰子點數全部相同，形成圍骰，押大/小都算輸。"
    },
    {
      "base": "tw_ranges_normal",
      "context": "ranges",
      "expected": "REJECT",
      "id": "tw_ranges_small_upper",
      "key": "ui:주사위 합계 11~17은 빅, 4~10은 스몰. 단, 세 주사위가 모두 같은 트리플이면 빅/스몰은 패배 처리된다.:/주사위 합계 11~017은 빅, 4~010은 스몰. 단, 세 주사위가 모두 같은 트리플이면 빅~1스몰은 패배 처리된다.",
      "kind": "mutant",
      "locale": "zh-TW",
      "required": [],
      "source": "주사위 합계 11~17은 빅, 4~10은 스몰. 단, 세 주사위가 모두 같은 트리플이면 빅/스몰은 패배 처리된다.",
      "static": true,
      "target": "骰子點數總和11~17算大，4~9算小。但若3顆骰子點數全部相同，形成圍骰，押大/小都算輸。"
    },
    {
      "base": "tw_ranges_normal",
      "context": "ranges",
      "expected": "REJECT",
      "id": "tw_ranges_big_reverse",
      "key": "ui:주사위 합계 11~17은 빅, 4~10은 스몰. 단, 세 주사위가 모두 같은 트리플이면 빅/스몰은 패배 처리된다.:/주사위 합계 11~017은 빅, 4~010은 스몰. 단, 세 주사위가 모두 같은 트리플이면 빅~1스몰은 패배 처리된다.",
      "kind": "mutant",
      "locale": "zh-TW",
      "required": [],
      "source": "주사위 합계 11~17은 빅, 4~10은 스몰. 단, 세 주사위가 모두 같은 트리플이면 빅/스몰은 패배 처리된다.",
      "static": true,
      "target": "骰子點數總和17~11算大，4~10算小。但若3顆骰子點數全部相同，形成圍骰，押大/小都算輸。"
    },
    {
      "base": "tw_ranges_normal",
      "context": "ranges",
      "expected": "REJECT",
      "id": "tw_ranges_small_reverse",
      "key": "ui:주사위 합계 11~17은 빅, 4~10은 스몰. 단, 세 주사위가 모두 같은 트리플이면 빅/스몰은 패배 처리된다.:/주사위 합계 11~017은 빅, 4~010은 스몰. 단, 세 주사위가 모두 같은 트리플이면 빅~1스몰은 패배 처리된다.",
      "kind": "mutant",
      "locale": "zh-TW",
      "required": [],
      "source": "주사위 합계 11~17은 빅, 4~10은 스몰. 단, 세 주사위가 모두 같은 트리플이면 빅/스몰은 패배 처리된다.",
      "static": true,
      "target": "骰子點數總和11~17算大，10~4算小。但若3顆骰子點數全部相同，形成圍骰，押大/小都算輸。"
    },
    {
      "base": "tw_ranges_normal",
      "context": "ranges",
      "expected": "REJECT",
      "id": "tw_ranges_big_sign",
      "key": "ui:주사위 합계 11~17은 빅, 4~10은 스몰. 단, 세 주사위가 모두 같은 트리플이면 빅/스몰은 패배 처리된다.:/주사위 합계 11~017은 빅, 4~010은 스몰. 단, 세 주사위가 모두 같은 트리플이면 빅~1스몰은 패배 처리된다.",
      "kind": "mutant",
      "locale": "zh-TW",
      "required": [],
      "source": "주사위 합계 11~17은 빅, 4~10은 스몰. 단, 세 주사위가 모두 같은 트리플이면 빅/스몰은 패배 처리된다.",
      "static": true,
      "target": "骰子點數總和+11~17算大，4~10算小。但若3顆骰子點數全部相同，形成圍骰，押大/小都算輸。"
    },
    {
      "base": "tw_ranges_normal",
      "context": "ranges",
      "expected": "REJECT",
      "id": "tw_ranges_small_sign",
      "key": "ui:주사위 합계 11~17은 빅, 4~10은 스몰. 단, 세 주사위가 모두 같은 트리플이면 빅/스몰은 패배 처리된다.:/주사위 합계 11~017은 빅, 4~010은 스몰. 단, 세 주사위가 모두 같은 트리플이면 빅~1스몰은 패배 처리된다.",
      "kind": "mutant",
      "locale": "zh-TW",
      "required": [],
      "source": "주사위 합계 11~17은 빅, 4~10은 스몰. 단, 세 주사위가 모두 같은 트리플이면 빅/스몰은 패배 처리된다.",
      "static": true,
      "target": "骰子點數總和11~17算大，-4~10算小。但若3顆骰子點數全部相同，形成圍骰，押大/小都算輸。"
    },
    {
      "base": "tw_ranges_normal",
      "context": "ranges",
      "expected": "REJECT",
      "id": "tw_ranges_range_percent",
      "key": "ui:주사위 합계 11~17은 빅, 4~10은 스몰. 단, 세 주사위가 모두 같은 트리플이면 빅/스몰은 패배 처리된다.:/주사위 합계 11~017은 빅, 4~010은 스몰. 단, 세 주사위가 모두 같은 트리플이면 빅~1스몰은 패배 처리된다.",
      "kind": "mutant",
      "locale": "zh-TW",
      "required": [],
      "source": "주사위 합계 11~17은 빅, 4~10은 스몰. 단, 세 주사위가 모두 같은 트리플이면 빅/스몰은 패배 처리된다.",
      "static": true,
      "target": "骰子點數總和11%~17%算大，4~10算小。但若3顆骰子點數全部相同，形成圍骰，押大/小都算輸。"
    },
    {
      "base": "tw_ranges_normal",
      "context": "ranges",
      "expected": "REJECT",
      "id": "tw_ranges_range_days",
      "key": "ui:주사위 합계 11~17은 빅, 4~10은 스몰. 단, 세 주사위가 모두 같은 트리플이면 빅/스몰은 패배 처리된다.:/주사위 합계 11~017은 빅, 4~010은 스몰. 단, 세 주사위가 모두 같은 트리플이면 빅~1스몰은 패배 처리된다.",
      "kind": "mutant",
      "locale": "zh-TW",
      "required": [],
      "source": "주사위 합계 11~17은 빅, 4~10은 스몰. 단, 세 주사위가 모두 같은 트리플이면 빅/스몰은 패배 처리된다.",
      "static": true,
      "target": "骰子點數總和11天~17天算大，4~10算小。但若3顆骰子點數全部相同，形成圍骰，押大/小都算輸。"
    },
    {
      "base": "tw_ranges_normal",
      "context": "ranges",
      "expected": "REJECT",
      "id": "tw_ranges_range_role_swap",
      "key": "ui:주사위 합계 11~17은 빅, 4~10은 스몰. 단, 세 주사위가 모두 같은 트리플이면 빅/스몰은 패배 처리된다.:/주사위 합계 11~017은 빅, 4~010은 스몰. 단, 세 주사위가 모두 같은 트리플이면 빅~1스몰은 패배 처리된다.",
      "kind": "mutant",
      "locale": "zh-TW",
      "required": [],
      "source": "주사위 합계 11~17은 빅, 4~10은 스몰. 단, 세 주사위가 모두 같은 트리플이면 빅/스몰은 패배 처리된다.",
      "static": true,
      "target": "骰子點數總和4~10算大，11~17算小。但若3顆骰子點數全部相同，形成圍骰，押大/小都算輸。"
    },
    {
      "base": "tw_ranges_normal",
      "context": "ranges",
      "expected": "REJECT",
      "id": "tw_ranges_duplicate_range",
      "key": "ui:주사위 합계 11~17은 빅, 4~10은 스몰. 단, 세 주사위가 모두 같은 트리플이면 빅/스몰은 패배 처리된다.:/주사위 합계 11~017은 빅, 4~010은 스몰. 단, 세 주사위가 모두 같은 트리플이면 빅~1스몰은 패배 처리된다.",
      "kind": "mutant",
      "locale": "zh-TW",
      "required": [],
      "source": "주사위 합계 11~17은 빅, 4~10은 스몰. 단, 세 주사위가 모두 같은 트리플이면 빅/스몰은 패배 처리된다.",
      "static": true,
      "target": "骰子點數總和11~17算大，4~10算小。但若3顆骰子點數全部相同，形成圍骰，押大/小都算輸。11~17。"
    },
    {
      "base": "tw_ranges_normal",
      "context": "ranges",
      "expected": "REJECT",
      "id": "tw_ranges_extra_number",
      "key": "ui:주사위 합계 11~17은 빅, 4~10은 스몰. 단, 세 주사위가 모두 같은 트리플이면 빅/스몰은 패배 처리된다.:/주사위 합계 11~017은 빅, 4~010은 스몰. 단, 세 주사위가 모두 같은 트리플이면 빅~1스몰은 패배 처리된다.",
      "kind": "mutant",
      "locale": "zh-TW",
      "required": [],
      "source": "주사위 합계 11~17은 빅, 4~10은 스몰. 단, 세 주사위가 모두 같은 트리플이면 빅/스몰은 패배 처리된다.",
      "static": true,
      "target": "骰子點數總和11~17算大，4~10算小。但若3顆骰子點數全部相同，形成圍骰，押大/小都算輸。8。"
    },
    {
      "base": "tw_ranges_normal",
      "context": "ranges",
      "expected": "REJECT",
      "id": "tw_ranges_extra_native_number",
      "key": "ui:주사위 합계 11~17은 빅, 4~10은 스몰. 단, 세 주사위가 모두 같은 트리플이면 빅/스몰은 패배 처리된다.:/주사위 합계 11~017은 빅, 4~010은 스몰. 단, 세 주사위가 모두 같은 트리플이면 빅~1스몰은 패배 처리된다.",
      "kind": "mutant",
      "locale": "zh-TW",
      "required": [],
      "source": "주사위 합계 11~17은 빅, 4~10은 스몰. 단, 세 주사위가 모두 같은 트리플이면 빅/스몰은 패배 처리된다.",
      "static": true,
      "target": "骰子點數總和11~17算大，4~10算小。但若3顆骰子點數全部相同，形成圍骰，押大/小都算輸。八。"
    },
    {
      "base": "tw_ranges_normal",
      "context": "ranges",
      "expected": "REJECT",
      "id": "tw_ranges_money",
      "key": "ui:주사위 합계 11~17은 빅, 4~10은 스몰. 단, 세 주사위가 모두 같은 트리플이면 빅/스몰은 패배 처리된다.:/주사위 합계 11~017은 빅, 4~010은 스몰. 단, 세 주사위가 모두 같은 트리플이면 빅~1스몰은 패배 처리된다.",
      "kind": "mutant",
      "locale": "zh-TW",
      "required": [
        "translation invented a Korean-won label absent from source"
      ],
      "source": "주사위 합계 11~17은 빅, 4~10은 스몰. 단, 세 주사위가 모두 같은 트리플이면 빅/스몰은 패배 처리된다.",
      "static": true,
      "target": "骰子點數總和11~17算大，4~10算小。但若3顆骰子點數全部相同，形成圍骰，押大/小都算輸。1韓元。"
    },
    {
      "base": "tw_ranges_normal",
      "context": "ranges",
      "expected": "REJECT",
      "id": "tw_ranges_wrong_currency",
      "key": "ui:주사위 합계 11~17은 빅, 4~10은 스몰. 단, 세 주사위가 모두 같은 트리플이면 빅/스몰은 패배 처리된다.:/주사위 합계 11~017은 빅, 4~010은 스몰. 단, 세 주사위가 모두 같은 트리플이면 빅~1스몰은 패배 처리된다.",
      "kind": "mutant",
      "locale": "zh-TW",
      "required": [
        "Korean won was relabeled as yen/yuan/Taiwan dollar"
      ],
      "source": "주사위 합계 11~17은 빅, 4~10은 스몰. 단, 세 주사위가 모두 같은 트리플이면 빅/스몰은 패배 처리된다.",
      "static": true,
      "target": "骰子點數總和11~17算大，4~10算小。但若3顆骰子點數全部相同，形成圍骰，押大/小都算輸。1日元。"
    },
    {
      "base": "tw_ranges_normal",
      "context": "ranges",
      "expected": "REJECT",
      "id": "tw_ranges_token",
      "key": "ui:주사위 합계 11~17은 빅, 4~10은 스몰. 단, 세 주사위가 모두 같은 트리플이면 빅/스몰은 패배 처리된다.:/주사위 합계 11~017은 빅, 4~010은 스몰. 단, 세 주사위가 모두 같은 트리플이면 빅~1스몰은 패배 처리된다.",
      "kind": "mutant",
      "locale": "zh-TW",
      "required": [
        "placeholder/BBCode mismatch"
      ],
      "source": "주사위 합계 11~17은 빅, 4~10은 스몰. 단, 세 주사위가 모두 같은 트리플이면 빅/스몰은 패배 처리된다.",
      "static": true,
      "target": "骰子點數總和11~17算大，4~10算小。但若3顆骰子點數全部相同，形成圍骰，押大/小都算輸。%s"
    },
    {
      "base": "tw_ranges_normal",
      "context": "ranges",
      "expected": "REJECT",
      "id": "tw_ranges_bbcode",
      "key": "ui:주사위 합계 11~17은 빅, 4~10은 스몰. 단, 세 주사위가 모두 같은 트리플이면 빅/스몰은 패배 처리된다.:/주사위 합계 11~017은 빅, 4~010은 스몰. 단, 세 주사위가 모두 같은 트리플이면 빅~1스몰은 패배 처리된다.",
      "kind": "mutant",
      "locale": "zh-TW",
      "required": [
        "placeholder/BBCode mismatch"
      ],
      "source": "주사위 합계 11~17은 빅, 4~10은 스몰. 단, 세 주사위가 모두 같은 트리플이면 빅/스몰은 패배 처리된다.",
      "static": true,
      "target": "[b]骰子點數總和11~17算大，4~10算小。但若3顆骰子點數全部相同，形成圍骰，押大/小都算輸。[/b]"
    },
    {
      "base": "tw_ranges_normal",
      "context": "ranges",
      "expected": "REJECT",
      "id": "tw_ranges_hangul",
      "key": "ui:주사위 합계 11~17은 빅, 4~10은 스몰. 단, 세 주사위가 모두 같은 트리플이면 빅/스몰은 패배 처리된다.:/주사위 합계 11~017은 빅, 4~010은 스몰. 단, 세 주사위가 모두 같은 트리플이면 빅~1스몰은 패배 처리된다.",
      "kind": "mutant",
      "locale": "zh-TW",
      "required": [
        "Hangul remains"
      ],
      "source": "주사위 합계 11~17은 빅, 4~10은 스몰. 단, 세 주사위가 모두 같은 트리플이면 빅/스몰은 패배 처리된다.",
      "static": true,
      "target": "骰子點數總和11~17算大，4~10算小。但若3顆骰子點數全部相同，形成圍骰，押大/小都算輸。한글"
    },
    {
      "base": "tw_ranges_normal",
      "context": "ranges",
      "expected": "REJECT",
      "id": "tw_ranges_kana",
      "key": "ui:주사위 합계 11~17은 빅, 4~10은 스몰. 단, 세 주사위가 모두 같은 트리플이면 빅/스몰은 패배 처리된다.:/주사위 합계 11~017은 빅, 4~010은 스몰. 단, 세 주사위가 모두 같은 트리플이면 빅~1스몰은 패배 처리된다.",
      "kind": "mutant",
      "locale": "zh-TW",
      "required": [
        "Japanese kana remains"
      ],
      "source": "주사위 합계 11~17은 빅, 4~10은 스몰. 단, 세 주사위가 모두 같은 트리플이면 빅/스몰은 패배 처리된다.",
      "static": true,
      "target": "骰子點數總和11~17算大，4~10算小。但若3顆骰子點數全部相同，形成圍骰，押大/小都算輸。かな"
    },
    {
      "base": "tw_ranges_normal",
      "context": "ranges",
      "expected": "REJECT",
      "id": "tw_ranges_newline",
      "key": "ui:주사위 합계 11~17은 빅, 4~10은 스몰. 단, 세 주사위가 모두 같은 트리플이면 빅/스몰은 패배 처리된다.:/주사위 합계 11~017은 빅, 4~010은 스몰. 단, 세 주사위가 모두 같은 트리플이면 빅~1스몰은 패배 처리된다.",
      "kind": "mutant",
      "locale": "zh-TW",
      "required": [
        "newline mismatch 0 != 1"
      ],
      "source": "주사위 합계 11~17은 빅, 4~10은 스몰. 단, 세 주사위가 모두 같은 트리플이면 빅/스몰은 패배 처리된다.",
      "static": true,
      "target": "骰子點數總和11~17算大，4~10算小。但若3顆骰子點數全部相同，形成圍骰，押大/小都算輸。\n"
    },
    {
      "base": "tw_ranges_normal",
      "context": "ranges",
      "expected": "REJECT",
      "id": "tw_ranges_paragraph",
      "key": "ui:주사위 합계 11~17은 빅, 4~10은 스몰. 단, 세 주사위가 모두 같은 트리플이면 빅/스몰은 패배 처리된다.:/주사위 합계 11~017은 빅, 4~010은 스몰. 단, 세 주사위가 모두 같은 트리플이면 빅~1스몰은 패배 처리된다.",
      "kind": "mutant",
      "locale": "zh-TW",
      "required": [
        "newline mismatch 0 != 2",
        "paragraph mismatch"
      ],
      "source": "주사위 합계 11~17은 빅, 4~10은 스몰. 단, 세 주사위가 모두 같은 트리플이면 빅/스몰은 패배 처리된다.",
      "static": true,
      "target": "骰子點數總和11~17算大，4~10算小。但若3顆骰子點數全部相同，形成圍骰，押大/小都算輸。\n\n"
    },
    {
      "base": "tw_ranges_normal",
      "context": "ranges",
      "expected": "REJECT",
      "id": "tw_ranges_script",
      "key": "ui:주사위 합계 11~17은 빅, 4~10은 스몰. 단, 세 주사위가 모두 같은 트리플이면 빅/스몰은 패배 처리된다.:/주사위 합계 11~017은 빅, 4~010은 스몰. 단, 세 주사위가 모두 같은 트리플이면 빅~1스몰은 패배 처리된다.",
      "kind": "mutant",
      "locale": "zh-TW",
      "required": [
        "@script"
      ],
      "source": "주사위 합계 11~17은 빅, 4~10은 스몰. 단, 세 주사위가 모두 같은 트리플이면 빅/스몰은 패배 처리된다.",
      "static": true,
      "target": "骰子點數總和11~17算大，4~10算小。但若3顆骰子點數全部相同，形成圍骰，押大/小都算輸。颗"
    },
    {
      "base": "tw_ranges_normal",
      "context": "ranges",
      "expected": "REJECT",
      "id": "tw_ranges_english",
      "key": "ui:주사위 합계 11~17은 빅, 4~10은 스몰. 단, 세 주사위가 모두 같은 트리플이면 빅/스몰은 패배 처리된다.:/주사위 합계 11~017은 빅, 4~010은 스몰. 단, 세 주사위가 모두 같은 트리플이면 빅~1스몰은 패배 처리된다.",
      "kind": "mutant",
      "locale": "zh-TW",
      "required": [
        "@english"
      ],
      "source": "주사위 합계 11~17은 빅, 4~10은 스몰. 단, 세 주사위가 모두 같은 트리플이면 빅/스몰은 패배 처리된다.",
      "static": true,
      "target": "骰子點數總和11~17算大，4~10算小。但若3顆骰子點數全部相同，形成圍骰，押大/小都算輸。 Please read this instruction."
    },
    {
      "base": "tw_ranges_normal",
      "context": "ranges",
      "expected": "ORIGINAL",
      "id": "tw_ranges_source_OFF",
      "key": "ui:주사위 합계 11~17은 빅, 4~10은 스몰. 단, 세 주사위가 모두 같은 트리플이면 빅/스몰은 패배 처리된다.:/주사위 합계 11~017은 빅, 4~010은 스몰. 단, 세 주사위가 모두 같은 트리플이면 빅~1스몰은 패배 처리된다.",
      "kind": "OFF",
      "locale": "zh-TW",
      "required": [],
      "source": "주사위 합계 11~17은 빅, 4~10은 스몰. 단, 세 주사위가 모두 같은 트리플이면 빅/스몰은 패배 처리된다. ",
      "static": true,
      "target": "骰子點數總和11~17算大，4~10算小。但若3顆骰子點數全部相同，形成圍骰，押大/小都算輸。"
    },
    {
      "base": "tw_ranges_normal",
      "context": "ranges",
      "expected": "ORIGINAL",
      "id": "tw_ranges_owner_OFF",
      "key": "ui:foreign-owner:/주사위 합계 11~017은 빅, 4~010은 스몰. 단, 세 주사위가 모두 같은 트리플이면 빅~1스몰은 패배 처리된다.",
      "kind": "OFF",
      "locale": "zh-TW",
      "required": [],
      "source": "주사위 합계 11~17은 빅, 4~10은 스몰. 단, 세 주사위가 모두 같은 트리플이면 빅/스몰은 패배 처리된다.",
      "static": false,
      "target": "骰子點數總和11~17算大，4~10算小。但若3顆骰子點數全部相同，形成圍骰，押大/小都算輸。"
    },
    {
      "base": "tw_ranges_normal",
      "context": "ranges",
      "expected": "ORIGINAL",
      "id": "tw_ranges_pointer_OFF",
      "key": "ui:주사위 합계 11~17은 빅, 4~10은 스몰. 단, 세 주사위가 모두 같은 트리플이면 빅/스몰은 패배 처리된다.:/주사위 합계 11~017은 빅, 4~010은 스몰. 단, 세 주사위가 모두 같은 트리플이면 빅~1스몰은 패배 처리된다.~wrong",
      "kind": "OFF",
      "locale": "zh-TW",
      "required": [],
      "source": "주사위 합계 11~17은 빅, 4~10은 스몰. 단, 세 주사위가 모두 같은 트리플이면 빅/스몰은 패배 처리된다.",
      "static": false,
      "target": "骰子點數總和11~17算大，4~10算小。但若3顆骰子點數全部相同，形成圍骰，押大/小都算輸。"
    },
    {
      "base": "tw_ranges_normal",
      "context": "ranges",
      "expected": "ORIGINAL",
      "id": "tw_ranges_unrelated_OFF",
      "key": "ui:세 개의 주사위가 구른다.:/세 개의 주사위가 구른다.",
      "kind": "OFF",
      "locale": "zh-TW",
      "required": [],
      "source": "세 개의 주사위가 구른다.",
      "static": true,
      "target": "骰子點數總和11~17算大，4~10算小。但若3顆骰子點數全部相同，形成圍骰，押大/小都算輸。"
    },
    {
      "base": "tw_ranges_normal",
      "context": "ranges",
      "expected": "ORIGINAL",
      "id": "tw_ranges_locale_OFF",
      "key": "ui:주사위 합계 11~17은 빅, 4~10은 스몰. 단, 세 주사위가 모두 같은 트리플이면 빅/스몰은 패배 처리된다.:/주사위 합계 11~017은 빅, 4~010은 스몰. 단, 세 주사위가 모두 같은 트리플이면 빅~1스몰은 패배 처리된다.",
      "kind": "OFF",
      "locale": "ja",
      "required": [],
      "source": "주사위 합계 11~17은 빅, 4~10은 스몰. 단, 세 주사위가 모두 같은 트리플이면 빅/스몰은 패배 처리된다.",
      "static": false,
      "target": "骰子點數總和11~17算大，4~10算小。但若3顆骰子點數全部相同，形成圍骰，押大/小都算輸。"
    },
    {
      "base": "tw_ranges_normal",
      "context": "ranges",
      "expected": "ORIGINAL",
      "id": "tw_ranges_unescaped_pointer_OFF",
      "key": "ui:주사위 합계 11~17은 빅, 4~10은 스몰. 단, 세 주사위가 모두 같은 트리플이면 빅/스몰은 패배 처리된다.:/주사위 합계 11~17은 빅, 4~10은 스몰. 단, 세 주사위가 모두 같은 트리플이면 빅/스몰은 패배 처리된다.",
      "kind": "OFF",
      "locale": "zh-TW",
      "required": [],
      "source": "주사위 합계 11~17은 빅, 4~10은 스몰. 단, 세 주사위가 모두 같은 트리플이면 빅/스몰은 패배 처리된다.",
      "static": false,
      "target": "骰子點數總和11~17算大，4~10算小。但若3顆骰子點數全部相同，形成圍骰，押大/小都算輸。"
    }
  ],
  "counts": {
    "OFF": 34,
    "mutant": 188,
    "normal": 6
  },
  "expectation_rule": "Frozen before author: PASS6; mutants reject on original consumers only after same-context normal passes; OFF arrays equal original observed before arrays. Narrow static fixtures are not live coverage.",
  "order": "ORDER-485",
  "private_inputs": {
    "draft2.json": "9ce301899af1fca8ab5a22952ebfaf9b0b17f6b38f6d10618bada31837e6a213",
    "selection2.json": "c96e50cfdd7417362a7df73044aa2607a7eab39c7c9c2c6c7607086d9fdec3fc"
  },
  "source_path": "scenes/JeongseonCasino.gd",
  "source_sha256": "f6cc7110d512f504b0d2a6dee1314fc7106c6b923c5f928106882d8ed29841b0"
}''')
CASINO_GLOSSARY_OFF_BEFORE = json.loads(r'''{
  "cn_double_source_OFF": [
    "counter quantity missing/changed: expected (duration_day, 11), target candidates=[]",
    "non-money number sequence changed: ['2', '10'] != ['2', '10', '11']"
  ],
  "cn_double_owner_OFF": [
    "counter quantity missing/changed: expected (duration_day, 11), target candidates=[]",
    "non-money number sequence changed: ['2', '10'] != ['2', '10', '11']"
  ],
  "cn_double_pointer_OFF": [
    "counter quantity missing/changed: expected (duration_day, 11), target candidates=[]",
    "non-money number sequence changed: ['2', '10'] != ['2', '10', '11']"
  ],
  "cn_double_unrelated_OFF": [
    "counter quantity missing/changed: expected (entity, 3), target candidates=[('entity', Decimal('2')), ('entity', Decimal('1'))]",
    "unmatched target entity quantity invented: 2",
    "non-money number sequence changed: [] != ['2', '2', '1', '10', '11']"
  ],
  "cn_double_locale_OFF": [
    "unsupported Chinese locale 'ja'"
  ],
  "cn_dice_source_OFF": [
    "counter quantity missing/changed: expected (entity, 3), target candidates=[]",
    "non-money number sequence changed: [] != ['3']"
  ],
  "cn_dice_owner_OFF": [
    "counter quantity missing/changed: expected (entity, 3), target candidates=[]",
    "non-money number sequence changed: [] != ['3']"
  ],
  "cn_dice_pointer_OFF": [
    "counter quantity missing/changed: expected (entity, 3), target candidates=[]",
    "non-money number sequence changed: [] != ['3']"
  ],
  "cn_dice_unrelated_OFF": [
    "counter quantity missing/changed: expected (entity, 3), target candidates=[]",
    "non-money number sequence changed: [] != ['3']"
  ],
  "cn_dice_locale_OFF": [
    "unsupported Chinese locale 'ja'"
  ],
  "cn_dice_unescaped_pointer_OFF": [
    "counter quantity missing/changed: expected (entity, 3), target candidates=[]",
    "non-money number sequence changed: [] != ['3']"
  ],
  "cn_ranges_source_OFF": [
    "non-money number sequence changed: ['11', '17', '4', '10'] != ['11', '17', '4', '10', '3']"
  ],
  "cn_ranges_owner_OFF": [
    "non-money number sequence changed: ['11', '17', '4', '10'] != ['11', '17', '4', '10', '3']"
  ],
  "cn_ranges_pointer_OFF": [
    "non-money number sequence changed: ['11', '17', '4', '10'] != ['11', '17', '4', '10', '3']"
  ],
  "cn_ranges_unrelated_OFF": [
    "counter quantity missing/changed: expected (entity, 3), target candidates=[]",
    "non-money number sequence changed: [] != ['11', '17', '4', '10', '3']"
  ],
  "cn_ranges_locale_OFF": [
    "unsupported Chinese locale 'ja'"
  ],
  "cn_ranges_unescaped_pointer_OFF": [
    "non-money number sequence changed: ['11', '17', '4', '10'] != ['11', '17', '4', '10', '3']"
  ],
  "tw_double_source_OFF": [
    "counter quantity missing/changed: expected (duration_day, 11), target candidates=[]",
    "non-money number sequence changed: ['2', '10'] != ['2', '10', '11']"
  ],
  "tw_double_owner_OFF": [
    "counter quantity missing/changed: expected (duration_day, 11), target candidates=[]",
    "non-money number sequence changed: ['2', '10'] != ['2', '10', '11']"
  ],
  "tw_double_pointer_OFF": [
    "counter quantity missing/changed: expected (duration_day, 11), target candidates=[]",
    "non-money number sequence changed: ['2', '10'] != ['2', '10', '11']"
  ],
  "tw_double_unrelated_OFF": [
    "counter quantity missing/changed: expected (entity, 3), target candidates=[('entity', Decimal('2')), ('entity', Decimal('1'))]",
    "unmatched target entity quantity invented: 2",
    "non-money number sequence changed: [] != ['2', '2', '1', '10', '11']"
  ],
  "tw_double_locale_OFF": [
    "unsupported Chinese locale 'ja'"
  ],
  "tw_dice_source_OFF": [
    "counter quantity missing/changed: expected (entity, 3), target candidates=[]",
    "non-money number sequence changed: [] != ['3']"
  ],
  "tw_dice_owner_OFF": [
    "counter quantity missing/changed: expected (entity, 3), target candidates=[]",
    "non-money number sequence changed: [] != ['3']"
  ],
  "tw_dice_pointer_OFF": [
    "counter quantity missing/changed: expected (entity, 3), target candidates=[]",
    "non-money number sequence changed: [] != ['3']"
  ],
  "tw_dice_unrelated_OFF": [
    "counter quantity missing/changed: expected (entity, 3), target candidates=[]",
    "non-money number sequence changed: [] != ['3']"
  ],
  "tw_dice_locale_OFF": [
    "unsupported Chinese locale 'ja'"
  ],
  "tw_dice_unescaped_pointer_OFF": [
    "counter quantity missing/changed: expected (entity, 3), target candidates=[]",
    "non-money number sequence changed: [] != ['3']"
  ],
  "tw_ranges_source_OFF": [
    "non-money number sequence changed: ['11', '17', '4', '10'] != ['11', '17', '4', '10', '3']"
  ],
  "tw_ranges_owner_OFF": [
    "non-money number sequence changed: ['11', '17', '4', '10'] != ['11', '17', '4', '10', '3']"
  ],
  "tw_ranges_pointer_OFF": [
    "non-money number sequence changed: ['11', '17', '4', '10'] != ['11', '17', '4', '10', '3']"
  ],
  "tw_ranges_unrelated_OFF": [
    "counter quantity missing/changed: expected (entity, 3), target candidates=[]",
    "non-money number sequence changed: [] != ['11', '17', '4', '10', '3']"
  ],
  "tw_ranges_locale_OFF": [
    "unsupported Chinese locale 'ja'"
  ],
  "tw_ranges_unescaped_pointer_OFF": [
    "non-money number sequence changed: ['11', '17', '4', '10'] != ['11', '17', '4', '10', '3']"
  ]
}''')
CASINO_GLOSSARY_SUPPLEMENTARY = json.loads(r'''[
  {
    "base": "cn_dice_normal",
    "context": "dice",
    "expected": "REJECT",
    "id": "cn_dice_classifier_region_supplement",
    "key": "ui:세 개의 주사위 결과에 거는 카지노 게임. 빅/스몰은 이해하기 쉽지만, 트리플이나 합계 베팅은 배당이 큰 만큼 확률이 낮다.:/세 개의 주사위 결과에 거는 카지노 게임. 빅~1스몰은 이해하기 쉽지만, 트리플이나 합계 베팅은 배당이 큰 만큼 확률이 낮다.",
    "kind": "mutant",
    "locale": "zh-CN",
    "required": [
      "@script"
    ],
    "source": "세 개의 주사위 결과에 거는 카지노 게임. 빅/스몰은 이해하기 쉽지만, 트리플이나 합계 베팅은 배당이 큰 만큼 확률이 낮다.",
    "static": true,
    "target": "对3顆骰子的结果下注的赌场游戏。大/小容易理解，但围骰或点数总和投注，赔率虽高，中奖概率也更低。",
    "supplementary": true
  },
  {
    "base": "cn_ranges_normal",
    "context": "ranges",
    "expected": "REJECT",
    "id": "cn_ranges_classifier_region_supplement",
    "key": "ui:주사위 합계 11~17은 빅, 4~10은 스몰. 단, 세 주사위가 모두 같은 트리플이면 빅/스몰은 패배 처리된다.:/주사위 합계 11~017은 빅, 4~010은 스몰. 단, 세 주사위가 모두 같은 트리플이면 빅~1스몰은 패배 처리된다.",
    "kind": "mutant",
    "locale": "zh-CN",
    "required": [
      "@script"
    ],
    "source": "주사위 합계 11~17은 빅, 4~10은 스몰. 단, 세 주사위가 모두 같은 트리플이면 빅/스몰은 패배 처리된다.",
    "static": true,
    "target": "骰子点数总和11~17为大，4~10为小。但若3顆骰子的点数完全相同，构成围骰，押大/小均判输。",
    "supplementary": true
  },
  {
    "base": "tw_dice_normal",
    "context": "dice",
    "expected": "REJECT",
    "id": "tw_dice_classifier_region_supplement",
    "key": "ui:세 개의 주사위 결과에 거는 카지노 게임. 빅/스몰은 이해하기 쉽지만, 트리플이나 합계 베팅은 배당이 큰 만큼 확률이 낮다.:/세 개의 주사위 결과에 거는 카지노 게임. 빅~1스몰은 이해하기 쉽지만, 트리플이나 합계 베팅은 배당이 큰 만큼 확률이 낮다.",
    "kind": "mutant",
    "locale": "zh-TW",
    "required": [
      "@script"
    ],
    "source": "세 개의 주사위 결과에 거는 카지노 게임. 빅/스몰은 이해하기 쉽지만, 트리플이나 합계 베팅은 배당이 큰 만큼 확률이 낮다.",
    "static": true,
    "target": "以3颗骰子的結果下注的賭場遊戲。大/小很好理解，但押圍骰或點數總和，賠率高，押中的機率也比較低。",
    "supplementary": true
  },
  {
    "base": "tw_ranges_normal",
    "context": "ranges",
    "expected": "REJECT",
    "id": "tw_ranges_classifier_region_supplement",
    "key": "ui:주사위 합계 11~17은 빅, 4~10은 스몰. 단, 세 주사위가 모두 같은 트리플이면 빅/스몰은 패배 처리된다.:/주사위 합계 11~017은 빅, 4~010은 스몰. 단, 세 주사위가 모두 같은 트리플이면 빅~1스몰은 패배 처리된다.",
    "kind": "mutant",
    "locale": "zh-TW",
    "required": [
      "@script"
    ],
    "source": "주사위 합계 11~17은 빅, 4~10은 스몰. 단, 세 주사위가 모두 같은 트리플이면 빅/스몰은 패배 처리된다.",
    "static": true,
    "target": "骰子點數總和11~17算大，4~10算小。但若3颗骰子點數全部相同，形成圍骰，押大/小都算輸。",
    "supplementary": true
  }
]''')
CASINO_GLOSSARY_PROVENANCE = {
    "roster_sha256": "839854d2aea6ff4f0b781efb968cfe64a4bf2810aab3b34d5f3af24e632b8541",
    "OFF_before_sha256": "3a66708b8ae12cc500da3c810bf827255c47d367d23dc0d9db18eeeca3746d3d",
    "supplementary_sha256": "cd330a163ad7fc555f95bc5b86162ad036c154768f6e2a5e051ded9781fe0e8c",
    "chronology": "Original228/OFF34 frozen before helper author; classifier-slot supplementary4 frozen after author code but before independent execution.",
    "before_HEAD": "3b416452c680d1157a14740532b0af049ecadbc5",
    "before_whole_tracked_sha256": "f50c3775d2bb1eeee1d278613d5137a527465688a348dcf13255d62c8bb1b9c9",
}


def _casino_digest(value):
    return hashlib.sha256(json.dumps(value, ensure_ascii=False, sort_keys=True,
                                     separators=(",", ":")).encode()).hexdigest()


def _casino_snapshot():
    import subprocess

    paths = subprocess.check_output(["git", "ls-files", "-z"], cwd=ROOT).split(b"\0")
    tracked = {}
    for encoded in paths:
        if not encoded:
            continue
        relative = encoded.decode()
        path = ROOT / relative
        tracked[relative] = hashlib.sha256(path.read_bytes()).hexdigest() if path.is_file() else None
    private = ROOT / ".git/order484-20261008.QsF61I"
    private_names = ("draft2.json", "selection2.json", "order485-freeze.py",
                     "order485-roster.json", "order485-before-OFF.json",
                     "order485-supplementary4.json")
    return {
        "HEAD": subprocess.check_output(["git", "rev-parse", "HEAD"], cwd=ROOT).decode().strip(),
        "status": subprocess.check_output(["git", "status", "--porcelain=v1", "-z"], cwd=ROOT).decode(),
        "tracked_files": len(tracked), "whole_tracked_sha256": _casino_digest(tracked),
        # Private originals are evidence, not a required runtime dependency.
        "private_inputs_present": {
            name: hashlib.sha256((private / name).read_bytes()).hexdigest()
            for name in private_names if (private / name).is_file()},
    }


def _casino_leaf(case, full):
    group, owner, raw_pointer = case["key"].split(":", 2)
    tokens = tuple(token.replace("~1", "/").replace("~0", "~")
                   for token in raw_pointer.removeprefix("/").split("/"))
    return full.Leaf(group, owner, "runtime:static_ui", tokens, case["source"],
                     "ui_static_context")


def _casino_required(case):
    required = []
    probes = {}
    for error in case["required"]:
        if error == "@script":
            probes[error] = zh._script_errors(case["locale"], case["target"])
            required.extend(probes[error])
        elif error == "@english":
            probes[error] = zh._untranslated_english_errors(case["source"], case["target"])
            required.extend(probes[error])
        else:
            required.append(error)
    return required, probes


def _casino_error_checks(case, observed, before_errors, required):
    errors = observed["value"]
    checks = {"no_exception": observed["exception"] is None,
              "error_list": _error_list(errors)}
    if case["expected"] == "PASS":
        checks["actual_consumer_pass"] = errors == []
    elif case["expected"] == "REJECT":
        checks["actual_consumer_reject"] = _error_list(errors) and bool(errors)
    else:
        checks["original_OFF_errors_exact"] = errors == before_errors
    checks["independent_original_diagnostics_retained"] = (
        _error_list(errors) and all(error in errors for error in required))
    return checks


def _casino_static(case, original_validate, required):
    source = case["source"]
    entry = ja.Entry(key="ui::485::" + case["id"], source=source,
                     context="ORDER-485 isolated real casino source fixture",
                     context_id="", format_template=False)
    inventory = ja.UiInventory(
        calls=(), legacy_entries=(entry,), legacy_blueprint={source: {"$entry": entry.key}},
        planned_context_entries=(), planned_context_blueprint={},
        observed_context_entries=(), observed_context_blueprint={}, errors=(), stats={})
    fixture_before = dataclasses.asdict(inventory)
    runtime, override = {"merged_pairs": {}}, {source: case["target"]}
    inputs_before = copy.deepcopy((runtime, override))
    canonical = "ui:" + source + ":/" + source.replace("~", "~0").replace("/", "~1")
    trace = []

    def forwarding(lang, key, raw_source, target):
        errors = original_validate(lang, key, raw_source, target)
        trace.append({"locale": lang, "key": key, "source": raw_source,
                      "target": target, "errors": list(errors)})
        return errors

    identities = (zh.validate_text, zh._static_ui_inventory,
                  zh._story_demo_exclusive_ui_pairs, zh._STATIC_UI_CACHE)
    with patch.object(zh, "_static_ui_inventory", return_value=inventory), \
            patch.object(zh, "_story_demo_exclusive_ui_pairs", return_value=({}, [])), \
            patch.object(zh, "validate_text", side_effect=forwarding):
        observed = _capture(lambda: zh.static_ui_coverage(
            case["locale"], runtime, False, actual_override=override))
    value = observed["value"]
    shape = (isinstance(value, tuple) and len(value) == 7
             and all(isinstance(n, int) for n in value[:6]) and _error_list(value[-1]))
    direct_errors = trace[0]["errors"] if len(trace) == 1 else None
    checks = {
        "no_exception": observed["exception"] is None,
        "isolated_counts_exact": shape and value[:6] == (1, 1, 0, 0, 0, 0),
        "actual_original_validate_once": len(trace) == 1,
        "escaped_canonical_source_owner": len(trace) == 1 and trace[0] == {
            "locale": case["locale"], "key": canonical, "source": source,
            "target": case["target"], "errors": direct_errors},
        "display_alias_only": shape and len(trace) == 1 and value[-1] == [
            case["locale"] + ":" + entry.key + ": " + error for error in direct_errors],
        "providers_cache_restored": all(before is after for before, after in zip(
            identities, (zh.validate_text, zh._static_ui_inventory,
                         zh._story_demo_exclusive_ui_pairs, zh._STATIC_UI_CACHE))),
        "fixture_runtime_override_unchanged": fixture_before == dataclasses.asdict(inventory)
        and inputs_before == (runtime, override),
        "independent_original_diagnostics_retained": _error_list(direct_errors)
        and all(error in direct_errors for error in required),
    }
    if case["expected"] == "PASS":
        checks["actual_static_pass"] = shape and value[-1] == []
    elif case["expected"] == "REJECT":
        checks["actual_static_reject"] = shape and bool(value[-1])
    else:
        # Source-OFF static canonical key differs from the original direct key.
        # This expectation is the frozen generic-error array, not an assertion
        # that a before static invocation was performed.
        checks["generic_OFF_array_matches_before_direct"] = (
            direct_errors == CASINO_GLOSSARY_OFF_BEFORE[case["id"]])
    return {"observed": observed, "actual_validate_trace": trace,
            "checks": checks, "passed": all(checks.values())}


def _casino_exception_restoration(case, original_validate):
    source = case["source"]
    entry = ja.Entry(key="ui::485::exception", source=source,
                     context="ORDER-485 exception-only isolated fixture",
                     context_id="", format_template=False)
    inventory = ja.UiInventory(
        calls=(), legacy_entries=(entry,), legacy_blueprint={source: {"$entry": entry.key}},
        planned_context_entries=(), planned_context_blueprint={},
        observed_context_entries=(), observed_context_blueprint={}, errors=(), stats={})
    identities = (zh.validate_text, zh._static_ui_inventory,
                  zh._story_demo_exclusive_ui_pairs, zh._STATIC_UI_CACHE)
    runtime, override = {"merged_pairs": {}}, {source: case["target"]}
    inputs_before = copy.deepcopy((dataclasses.asdict(inventory), runtime, override))
    result = []
    for where in ("inventory_provider", "story_provider", "after_original_validator"):
        calls = []
        def forwarding(lang, key, raw_source, target):
            errors = original_validate(lang, key, raw_source, target)
            calls.append({"locale": lang, "key": key, "source": raw_source,
                          "target": target, "actual_errors": errors})
            if where == "after_original_validator":
                raise RuntimeError("ORDER485 injected after actual original validator")
            return errors
        with patch.object(zh, "_STATIC_UI_CACHE", new=object()), \
                patch.object(zh, "_static_ui_inventory", return_value=inventory) as provider, \
                patch.object(zh, "_story_demo_exclusive_ui_pairs", return_value=({}, [])) as story, \
                patch.object(zh, "validate_text", side_effect=forwarding):
            if where == "inventory_provider":
                provider.side_effect = RuntimeError("ORDER485 injected inventory provider")
            if where == "story_provider":
                story.side_effect = RuntimeError("ORDER485 injected story provider")
            observed = _capture(lambda: zh.static_ui_coverage(
                case["locale"], runtime, False, actual_override=override))
        checks = {
            "injected_exception_propagated": observed["exception"] is not None
            and "ORDER485 injected" in observed["exception"],
            "validator_provider_cache_identity_restored": all(before is after for before, after in zip(
                identities, (zh.validate_text, zh._static_ui_inventory,
                             zh._story_demo_exclusive_ui_pairs, zh._STATIC_UI_CACHE))),
            "fixtures_unchanged": inputs_before == (dataclasses.asdict(inventory), runtime, override),
            "actual_validator_before_raise": (
                len(calls) == 1 and calls[0]["actual_errors"] == []
                if where == "after_original_validator" else calls == []),
        }
        result.append({"site": where, "observed": observed, "actual_validate_trace": calls,
                       "checks": checks, "passed": all(checks.values())})
    return result


def casino_glossary_main():
    import sys
    import full_game_localization as full

    before = _capture(_casino_snapshot)
    frozen_inputs = copy.deepcopy((CASINO_GLOSSARY_ROSTER, CASINO_GLOSSARY_OFF_BEFORE,
                                   CASINO_GLOSSARY_SUPPLEMENTARY))
    functions = (
        zh.validate_text, zh.static_ui_coverage, zh._static_ui_inventory,
        zh._story_demo_exclusive_ui_pairs, zh._numeric_errors,
        zh._ui_casino_glossary_numbers, full.translation_errors, full.collect, full.main,
    )
    cache_identity, cache_value = zh._STATIC_UI_CACHE, copy.deepcopy(zh._STATIC_UI_CACHE)
    original_validate = zh.validate_text
    cases = CASINO_GLOSSARY_ROSTER["cases"] + CASINO_GLOSSARY_SUPPLEMENTARY
    results = []
    forbidden_calls = {"full.collect": 0, "full.main": 0}
    watched = {full.collect.__code__: "full.collect", full.main.__code__: "full.main"}
    if hasattr(ja, "build_scope"):
        watched[ja.build_scope.__code__] = "ja.build_scope"
        forbidden_calls["ja.build_scope"] = 0
    previous_profile = sys.getprofile()

    def profile(frame, event, arg):
        if event == "call" and frame.f_code in watched:
            forbidden_calls[watched[frame.f_code]] += 1

    source_observation = _capture(lambda: {
        "path": CASINO_GLOSSARY_ROSTER["source_path"],
        "sha256": hashlib.sha256((ROOT / CASINO_GLOSSARY_ROSTER["source_path"]).read_bytes()).hexdigest(),
        "normal_literal_occurrences": {
            case["id"]: (ROOT / CASINO_GLOSSARY_ROSTER["source_path"]).read_text(encoding="utf-8").count(case["source"])
            for case in cases if case["kind"] == "normal"}})
    fatal = None
    restoration = []
    sys.setprofile(profile)
    try:
        for case in cases:
            required, probes = _casino_required(case)
            checks = {"independent_probes_have_original_diagnostics": all(probes.values())}
            helper = _capture(lambda: zh._ui_casino_glossary_numbers(
                case["locale"], case["key"], case["source"], case["target"]))
            pair = helper["value"]
            checks["helper_no_exception"] = helper["exception"] is None
            if case["kind"] == "OFF":
                checks["helper_OFF_is_None"] = pair is None
            else:
                checks["owned_helper_shape"] = (
                    isinstance(pair, tuple) and len(pair) == 3
                    and isinstance(pair[0], str) and isinstance(pair[1], str) and _error_list(pair[2]))
                if checks["owned_helper_shape"]:
                    checks["failed_helper_original_pair_preserved"] = (
                        not pair[2] or pair[:2] == (case["source"], case["target"]))
                    if case["kind"] == "normal" or case.get("supplementary"):
                        checks["normal_numeric_roles_verified"] = pair[2] == []
                        checks["only_numeric_copy_changes"] = (
                            len(pair[0]) == len(case["source"]) and len(pair[1]) == len(case["target"])
                            and pair[0] != case["source"] and pair[1] != case["target"]
                            and all(a == b or b == " " for a, b in zip(case["source"], pair[0]))
                            and all(a == b or b == " " for a, b in zip(case["target"], pair[1])))
            direct = _capture(lambda: original_validate(
                case["locale"], case["key"], case["source"], case["target"]))
            direct_checks = _casino_error_checks(
                case, direct, CASINO_GLOSSARY_OFF_BEFORE.get(case["id"]), required)
            checks["direct"] = all(direct_checks.values())

            leaf = _casino_leaf(case, full)
            leaf_record = dataclasses.asdict(leaf)
            full_observed = None
            full_checks = {}
            full_skip = None
            if case["locale"] not in ("zh-CN", "zh-TW"):
                full_skip = "Chinese locale-OFF tested directly; actual full ja branch is a different consumer."
            elif leaf.id != case["key"]:
                full_skip = "Malformed raw pointer is not representable as an actual canonical Leaf.id; direct-only OFF."
            else:
                full_observed = _capture(lambda: full.translation_errors(
                    leaf, case["locale"], case["target"]))
                full_checks = _casino_error_checks(case, full_observed,
                    sorted(CASINO_GLOSSARY_OFF_BEFORE.get(case["id"], [])), required)
                full_checks["actual_Leaf_unchanged"] = leaf_record == dataclasses.asdict(leaf)
                checks["actual_full_consumer"] = all(full_checks.values())
            static = None
            if case["static"]:
                static = _casino_static(case, original_validate, required)
                checks["actual_isolated_static_consumer"] = static["passed"]
            results.append({"case": case, "helper": helper, "direct": direct,
                            "direct_checks": direct_checks, "required_original_diagnostics": required,
                            "independent_raw_probes": probes,
                            "actual_leaf": {"fields": leaf_record, "id": leaf.id,
                                            "source_sha256": leaf.source_sha256},
                            "full": full_observed, "full_checks": full_checks, "full_skipped": full_skip,
                            "static": static, "checks": checks, "passed": all(checks.values())})
        restoration = _casino_exception_restoration(
            next(case for case in cases if case["kind"] == "normal"), original_validate)
    except Exception:
        fatal = traceback.format_exc()
    finally:
        sys.setprofile(previous_profile)
    by_id = {row["case"]["id"]: row for row in results}
    for row in results:
        case = row["case"]
        base = by_id.get(case["base"])
        row["normal_base_passed"] = (
            case["kind"] != "mutant" or bool(base and base["passed"]
                and base["case"]["kind"] == "normal" and all(
                    case[key] == base["case"][key] for key in ("locale", "key", "source", "context"))))
        row["valid_negative"] = case["kind"] == "mutant" and row["passed"] and row["normal_base_passed"]
        row["valid_result"] = row["passed"] and row["normal_base_passed"]
    after = _capture(_casino_snapshot)
    current_functions = (
        zh.validate_text, zh.static_ui_coverage, zh._static_ui_inventory,
        zh._story_demo_exclusive_ui_pairs, zh._numeric_errors,
        zh._ui_casino_glossary_numbers, full.translation_errors, full.collect, full.main,
    )
    global_checks = {
        "no_fatal_exception": fatal is None,
        "original_frozen_roster_counts": CASINO_GLOSSARY_ROSTER["counts"] == {
            "normal": 6, "mutant": 188, "OFF": 34}
            and len(CASINO_GLOSSARY_ROSTER["cases"]) == 228,
        "all_unique_ids": len({case["id"] for case in cases}) == len(cases) == 232,
        "OFF_before_arrays_complete": set(CASINO_GLOSSARY_OFF_BEFORE) == {
            case["id"] for case in CASINO_GLOSSARY_ROSTER["cases"] if case["kind"] == "OFF"},
        "supplementary_four_separate": len(CASINO_GLOSSARY_SUPPLEMENTARY) == 4
            and all(case.get("supplementary") for case in CASINO_GLOSSARY_SUPPLEMENTARY),
        "all_cases_executed": len(results) == len(cases),
        "all_results_valid": all(row["valid_result"] for row in results),
        "actual_source_file_unchanged_identity": source_observation["exception"] is None
            and source_observation["value"]["sha256"] == CASINO_GLOSSARY_ROSTER["source_sha256"]
            and all(source_observation["value"]["normal_literal_occurrences"].values()),
        "whole_tracked_HEAD_private_unchanged": before["exception"] is None
            and after["exception"] is None and before["value"] == after["value"],
        "functions_identity_unchanged": all(a is b for a, b in zip(functions, current_functions)),
        "static_cache_identity_value_unchanged": zh._STATIC_UI_CACHE is cache_identity
            and zh._STATIC_UI_CACHE == cache_value,
        "all_injected_exception_scopes_restored": len(restoration) == 3
            and all(row["passed"] for row in restoration),
        "frozen_literals_unchanged": frozen_inputs == (
            CASINO_GLOSSARY_ROSTER, CASINO_GLOSSARY_OFF_BEFORE, CASINO_GLOSSARY_SUPPLEMENTARY),
        "collector_main_build_scope_zero": not any(forbidden_calls.values()),
        "profile_restored": sys.getprofile() is previous_profile,
    }
    passed = all(global_checks.values())
    report = {
        "provenance": CASINO_GLOSSARY_PROVENANCE, "global_checks": global_checks,
        "cases": results, "exception_restoration": restoration,
        "source_observation": source_observation, "before": before, "after": after,
        "counts": {"original": CASINO_GLOSSARY_ROSTER["counts"], "supplementary": 4,
                   "actual_direct": len(results),
                   "actual_full": sum(row["full"] is not None for row in results),
                   "actual_isolated_static": sum(row["static"] is not None for row in results),
                   "valid_negatives": sum(row["valid_negative"] for row in results)},
        "execution_counts": {"forbidden_functions_observed": forbidden_calls,
                             "engine": 0, "old_test_or_roster_execution": 0},
        "fatal_exception": fatal,
        "limits": "Source3 only: six normal private translation drafts, finite negatives/OFF and isolated static fixtures. Not whole live UI, translation acceptance, native/render/input observation or product GO. Source path/hash observed separately; helper API has only locale, exact source and canonical ID.",
        "passed": passed,
    }
    print("ORDER485_CASINO_GLOSSARY_RESULT " + json.dumps(report, ensure_ascii=False), flush=True)
    print("ORDER485_CASINO_GLOSSARY_OK" if passed else "ORDER485_CASINO_GLOSSARY_FAIL", flush=True)
    return 0 if passed else 1


if __name__ == "__main__":
    if __import__("sys").argv[1:] == ["--casino-glossary-only"]:
        raise SystemExit(casino_glossary_main())
    unittest.main()
