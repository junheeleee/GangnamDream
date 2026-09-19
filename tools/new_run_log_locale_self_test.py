#!/usr/bin/env python3
"""ORDER267 finite source controls; old suites are delegated, never copied."""
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
from collections import Counter
from dataclasses import asdict, replace
from unittest.mock import patch

import main_game_locale_history as history
import ja_translation_pipeline as pipeline
import year5_reference_route_audit as year5
import chapter1_core_loop_v2_causal_ledger_check as chapter

ROOT = Path(__file__).resolve().parents[1]
SELF = "tools/new_run_log_locale_self_test.py"
GS = "autoloads/GameState.gd"
JA = "tools/ja_translation_pipeline.py"
UI = ("locale/ui_ja.json", "locale/ui_zh-CN.json", "locale/ui_zh-TW.json")
# BEGIN_NEW_RUN_BINDING_267
BINDING = json.loads(r'''{
  "phase": "APPLIED_SOURCE_BOUND",
  "code": {
    "tools/main_game_locale_history.py": {
      "bytes": 40220,
      "current_sha256": "0b23de3212a1f86dd6216bb93640dc5e263aed3609372e7860c0a4505bb4a951",
      "previous_sha256": "f1ef7d55c029982f85f28681898c152344709dbbd63b87e6dabb5d350ed2a55e",
      "inverse": {
        "kind": "span",
        "start": "\n# BEGIN_NEW_RUN_LOG_HISTORY_267\n",
        "end": null,
        "span_sha256": "2c75a982f8d117ccc9e3021217ada9941a15fa2485a0d47cee76694d4fb1d181"
      }
    },
    "tools/ja_translation_pipeline.py": {
      "bytes": 279420,
      "current_sha256": "fdbcc5701bc78e6dac5023d6b2e295cfdf2f96f40e039f07f0f02f6985e0779b",
      "previous_sha256": "8bb536853809fa273587734215bfcb3d6a78b9bd4d4b941b595e2136e8ebec6c",
      "inverse": {
        "kind": "span",
        "start": "# BEGIN_NEW_RUN_LOG_COLLECTOR_267\n",
        "end": "# END_NEW_RUN_LOG_COLLECTOR_267\n\n",
        "span_sha256": "6cd6cf8e6e0c5060de710adf5f94f488f1cf90d9bd1100431eb6be81a8580bee"
      }
    },
    "tools/year5_reference_route_audit.py": {
      "bytes": 621471,
      "current_sha256": "e00a3e9d0a5bcd269f5d33026d33242d2cb67469a68e45ac1ee6084ce21a1240",
      "previous_sha256": "b4c34f559a458b4ad53ff19a0855d76176ec84083ba7b725f21a4f7aa6f50f82",
      "inverse": {
        "kind": "span",
        "start": "# BEGIN_NEW_RUN_LOG_YEAR5_267\n",
        "end": "# END_NEW_RUN_LOG_YEAR5_267\n\n",
        "span_sha256": "98c3356d8c3072cfae95710e7c65b4fa15685aa9519b05fa1460725b68f91889"
      }
    },
    "tools/chapter1_core_loop_v2_causal_ledger_check.py": {
      "bytes": 1464280,
      "current_sha256": "6994cff5a6ef41a4a256c286d553c068f42ed00b279ea6a78fcd07ea9581d28b",
      "previous_sha256": "9e7522cd34f98bd9e54e3148e9f7825731b5b6081e31e33c5a0d8b8c273f959e",
      "inverse": {
        "kind": "span",
        "start": "# BEGIN_NEW_RUN_LOG_CHAPTER_267\n",
        "end": "# END_NEW_RUN_LOG_CHAPTER_267\n\n",
        "span_sha256": "1a85131547e2f612d6de809782da9e416651360457a82ea791deea7ce404e7bf"
      }
    },
    "tools/ci_localization_reconciliation_self_test.py": {
      "bytes": 149814,
      "current_sha256": "cf5846ea7b4cce9f473b1254fa95ccae3c35af485f69a320269e621a5ed3c46b",
      "previous_sha256": "3a4f5129fb1bc91bb7dcab21e9f214a0b986a90ee382ccbf701f2f66e3284192",
      "inverse": {
        "kind": "replace",
        "before": "if __name__ == \"__main__\":\n    raise SystemExit(_gift_caption_ci_main())\n",
        "after": "if __name__ == \"__main__\":\n    from new_run_log_locale_self_test import historical_entry\n    raise SystemExit(historical_entry(_gift_caption_ci_main, \"ci\"))\n"
      }
    },
    "tools/meta_title_locale_successor_self_test.py": {
      "bytes": 278049,
      "current_sha256": "9a2a951d3f21d8a58a48cfd64d8d0e7c6730461e8bcb8a4ff778e1140e89de80",
      "previous_sha256": "50012ad8773c113db1c7fa212af14b791cb770cf953a860bc7c48cd2d4269b1c",
      "inverse": {
        "kind": "replace",
        "before": "if __name__ == \"__main__\":\n    raise SystemExit(_gift_caption_meta_main())\n",
        "after": "if __name__ == \"__main__\":\n    from new_run_log_locale_self_test import historical_entry\n    raise SystemExit(historical_entry(_gift_caption_meta_main, \"meta\"))\n"
      }
    },
    "tools/gift_caption_locale_self_test.py": {
      "bytes": 29187,
      "current_sha256": "f52a4bcf4efb94043e70b9a89f8f802d083e1c9e1e853d83220dec6f274cd814",
      "previous_sha256": "ce2fdced32ff61954160cacd6c2bb3938fa7813624f40ae6d95b67bc8c3bf877",
      "inverse": {
        "kind": "replace",
        "before": "if __name__ == \"__main__\":\n    raise SystemExit(main())\n",
        "after": "if __name__ == \"__main__\":\n    from new_run_log_locale_self_test import historical_entry\n    raise SystemExit(historical_entry(main, \"gift\"))\n"
      }
    }
  },
  "gs_plan": {
    "phase": "PROPOSED_NOT_APPLIED",
    "path": "autoloads/GameState.gd",
    "previous_sha256": "8a40740286ff910b2a16049e2c2794cc0dc22fed5dfc78d2fc6ce458c833018d",
    "proposed_sha256": "5076adf75b13920ae97ff9174945acf9c43fc80dec73cb356da44f314b7741d8",
    "inverses": [
      {
        "id": "profile_parent",
        "before": "\tadd_log(LocaleManager.ui(\n\t\t\"다시 시작한 아침. 출발점은 %s였다.\",\n\t\t\"Another beginning. He started out %s.\") %\n\t\t_localized_profile_label(starting_profile), \"system\")\n",
        "after": "\tadd_log(LocaleManager.ui_format(\n\t\t\"다시 시작한 아침. 출발점은 %s였다.\",\n\t\t\"Another beginning. He started out %s.\",\n\t\t[_localized_profile_label(starting_profile)],\n\t\t[_localized_profile_label(starting_profile, true)]), \"system\")\n"
      },
      {
        "id": "profile_label",
        "before": "func _localized_profile_label(profile: String) -> String:\n\tif not LocaleManager.is_english():\n\t\treturn profile\n\tvar labels := {\n\t\t\"백수\": \"unemployed\",\n\t\t\"알바\": \"working part-time\",\n\t}\n\treturn str(labels.get(profile, profile))\n",
        "after": "func _localized_profile_label(profile: String, english_only: bool = false) -> String:\n\tvar labels := {\n\t\t\"백수\": \"unemployed\",\n\t\t\"알바\": \"working part-time\",\n\t}\n\tif english_only:\n\t\treturn str(labels.get(profile, profile))\n\tmatch profile:\n\t\t\"백수\":\n\t\t\treturn LocaleManager.ui(\"백수\", \"unemployed\")\n\t\t\"알바\":\n\t\t\treturn LocaleManager.ui(\"알바\", \"working part-time\")\n\treturn profile\n"
      },
      {
        "id": "theme_log",
        "before": "func _roll_run_theme():\n\tvar pool = [\"investment\", \"jobs\", \"social\", \"health\", \"relationship\", \"gambling\", \"finance\"]\n\tpool.shuffle()\n\trun_theme_categories = [pool[0], pool[1]]\n\tvar label_map = {\n\t\t\"investment\": \"투자\", \"jobs\": \"직장\", \"social\": \"인간관계\",\n\t\t\"health\": \"건강\", \"relationship\": \"연애\", \"gambling\": \"도박\", \"finance\": \"재정\"\n\t}\n\tif LocaleManager.is_english():\n\t\tlabel_map = {\n\t\t\t\"investment\": \"Investing\", \"jobs\": \"Jobs\", \"social\": \"Social\",\n\t\t\t\"health\": \"Health\", \"relationship\": \"Relationships\", \"gambling\": \"Gambling\", \"finance\": \"Finance\"\n\t\t}\n\tvar a = label_map.get(pool[0], pool[0])\n\tvar b = label_map.get(pool[1], pool[1])\n\tadd_log(LocaleManager.ui(\n\t\t\"이번에는 %s와 %s에 얽힌 소식이 유난히 먼저 눈에 들어왔다.\",\n\t\t\"This time, news tied to %s and %s caught his eye first.\"\n\t) % [a, b], \"system\")\n",
        "after": "func _roll_run_theme():\n\tvar pool = [\"investment\", \"jobs\", \"social\", \"health\", \"relationship\", \"gambling\", \"finance\"]\n\tpool.shuffle()\n\trun_theme_categories = [pool[0], pool[1]]\n\tvar label_map = {\n\t\t\"investment\": LocaleManager.ui(\"투자\", \"Investing\"),\n\t\t\"jobs\": LocaleManager.ui(\"직장\", \"Jobs\"),\n\t\t\"social\": LocaleManager.ui(\"인간관계\", \"Social\"),\n\t\t\"health\": LocaleManager.ui(\"건강\", \"Health\"),\n\t\t\"relationship\": LocaleManager.ui(\"연애\", \"Relationships\"),\n\t\t\"gambling\": LocaleManager.ui(\"도박\", \"Gambling\"),\n\t\t\"finance\": LocaleManager.ui(\"재정\", \"Finance\"),\n\t}\n\tvar english_labels = {\n\t\t\"investment\": \"Investing\", \"jobs\": \"Jobs\", \"social\": \"Social\",\n\t\t\"health\": \"Health\", \"relationship\": \"Relationships\", \"gambling\": \"Gambling\", \"finance\": \"Finance\"\n\t}\n\tvar a = label_map.get(pool[0], pool[0])\n\tvar b = label_map.get(pool[1], pool[1])\n\tadd_log(LocaleManager.ui_format(\n\t\t\"이번에는 %s와 %s에 얽힌 소식이 유난히 먼저 눈에 들어왔다.\",\n\t\t\"This time, news tied to %s and %s caught his eye first.\",\n\t\t[a, b], [english_labels.get(pool[0], pool[0]), english_labels.get(pool[1], pool[1])]\n\t), \"system\")\n"
      }
    ],
    "planned_selectors": "Two new legacy profile literals in _localized_profile_label; seven new legacy category literals in _roll_run_theme. Same two parent KO/EN texts change legacy to format; start_new_game explicit target/English arg calls; theme uses a,b versus english_labels in same order. No context IDs.",
    "lookup_boundary": "Seven category lookups are evaluated into the label map, including unselected keys; misses can be recorded for unselected keys, but RNG/game state/category IDs are unchanged."
  },
  "source_case_plan_sha256": "1d364fa88985a2d13ca9c4c73df488fbac7d5253b101c1913bee911b4bfea960",
  "source_cases_sha256": "d51ad6d47bd32ab0684c62a8299bc30225606554de4737cbddd7942ca35c9bf5",
  "self_code_view_sha256": "0d26391083032e5f23a78b498726dbc963446b6245b3c8cec29219fc5d41af6d",
  "provenance": {
    "root_execution_approval": "2026-09-20 ROOT: tools8 independent pre-execution PASS ee004c83324fa283f8e46d32963718bbc9bf0a4ccdd29e141afa477d40b63ac0; only binding phase/provenance changed, full raw externally pinned before execution. Original GS proposal remains quoted below its original phase.",
    "chronology": "Post-independent36 freeze, pre-this-self first execution; first tools7 review found copied format_calls stale. Revised only current-derived format/branch counts and connected pins; prior binding preserved. All repository imports and QA executions remain ROOT-owned.",
    "actual_gs_sha256": "5076adf75b13920ae97ff9174945acf9c43fc80dec73cb356da44f314b7741d8",
    "first_binding": "order267-tools7-first-binding.json",
    "self_full_raw_sha256": "EXTERNAL approval; deliberately outside recursive code-view binding"
  }
}''')
FROZEN = json.loads(r'''[
  {
    "id": "current_normal",
    "kind": "normal",
    "base": null,
    "recipe": "Approved current GS + pipeline bytes; actual calls and shapes, no substitutions.",
    "expected": "new3+public3 GS success; GS→8a407, pipeline→8bb536; optional previous8a407 accepted; live Year5/Chapter success; collector returns current nine additions and two format parents/current locations, old remaining calls exact.",
    "endpoint": "helper/public/live2/collector/semantic"
  },
  {
    "id": "gs_whole_rollback",
    "kind": "negative",
    "base": "current_normal",
    "recipe": "GS := exact old8a407 bytes.",
    "expected": "REJECT; byte projection identity; claim unchanged.",
    "endpoint": "helper3+public3+live2"
  },
  {
    "id": "gs_rollback_profile_parent",
    "kind": "negative",
    "base": "current_normal",
    "recipe": "Replace exactly one approved after span by before for inverses.id=profile_parent in pinned GS plan64cbb; other two after spans unchanged.",
    "expected": "REJECT; identity/original claim.",
    "endpoint": "helper3"
  },
  {
    "id": "gs_rollback_profile_label",
    "kind": "negative",
    "base": "current_normal",
    "recipe": "Replace exactly one approved after span by before for inverses.id=profile_label in pinned GS plan64cbb; other two after spans unchanged.",
    "expected": "REJECT; identity/original claim.",
    "endpoint": "helper3"
  },
  {
    "id": "gs_rollback_theme_log",
    "kind": "negative",
    "base": "current_normal",
    "recipe": "Replace exactly one approved after span by before for inverses.id=theme_log in pinned GS plan64cbb; other two after spans unchanged.",
    "expected": "REJECT; identity/original claim.",
    "endpoint": "helper3"
  },
  {
    "id": "gs_unrelated_byte",
    "kind": "negative",
    "base": "current_normal",
    "recipe": "Append exactly '\\n# ORDER267_UNOWNED\\n' to current GS.",
    "expected": "REJECT; identity/original claim.",
    "endpoint": "helper3+live2"
  },
  {
    "id": "gs_crlf",
    "kind": "negative",
    "base": "current_normal",
    "recipe": "Replace every LF in current GS by CRLF; assert source had zero CR first.",
    "expected": "REJECT; no universal-newline laundering; identity.",
    "endpoint": "helper3"
  },
  {
    "id": "gs_final_lf_missing",
    "kind": "negative",
    "base": "current_normal",
    "recipe": "Remove exactly one final LF from current GS; assert present.",
    "expected": "REJECT; identity.",
    "endpoint": "helper3"
  },
  {
    "id": "pipeline_whole_rollback",
    "kind": "negative",
    "base": "current_normal",
    "recipe": "Pipeline := exact old8bb536 bytes; GS stays approved current.",
    "expected": "REJECT pipeline raw; current collector must not claim normal.",
    "endpoint": "helper3+collector"
  },
  {
    "id": "pipeline_unrelated_byte",
    "kind": "negative",
    "base": "current_normal",
    "recipe": "Append exactly '\\n# ORDER267_UNOWNED\\n' to current pipeline.",
    "expected": "REJECT pipeline raw; identity/original claim.",
    "endpoint": "helper3"
  },
  {
    "id": "selector_path",
    "kind": "negative",
    "base": "current_normal",
    "recipe": {
      "op": "replace_exact_one_UiCall_field",
      "selector": {
        "path": "autoloads/GameState.gd",
        "function": "_localized_profile_label",
        "api": "legacy",
        "korean": "백수",
        "english": "unemployed",
        "context_id": ""
      },
      "field": "path",
      "value": "autoloads/Other.gd"
    },
    "expected": "Semantic REJECT while raw source guard remains PASS; not counted as a raw-gate negative.",
    "endpoint": "semantic"
  },
  {
    "id": "selector_function",
    "kind": "negative",
    "base": "current_normal",
    "recipe": {
      "op": "replace_exact_one_UiCall_field",
      "selector": {
        "path": "autoloads/GameState.gd",
        "function": "_localized_profile_label",
        "api": "legacy",
        "korean": "백수",
        "english": "unemployed",
        "context_id": ""
      },
      "field": "function",
      "value": "_localized_route_label"
    },
    "expected": "Semantic REJECT while raw source guard remains PASS; not counted as a raw-gate negative.",
    "endpoint": "semantic"
  },
  {
    "id": "selector_api",
    "kind": "negative",
    "base": "current_normal",
    "recipe": {
      "op": "replace_exact_one_UiCall_field",
      "selector": {
        "path": "autoloads/GameState.gd",
        "function": "_localized_profile_label",
        "api": "legacy",
        "korean": "백수",
        "english": "unemployed",
        "context_id": ""
      },
      "field": "api",
      "value": "context"
    },
    "expected": "Semantic REJECT while raw source guard remains PASS; not counted as a raw-gate negative.",
    "endpoint": "semantic"
  },
  {
    "id": "selector_korean",
    "kind": "negative",
    "base": "current_normal",
    "recipe": {
      "op": "replace_exact_one_UiCall_field",
      "selector": {
        "path": "autoloads/GameState.gd",
        "function": "_localized_profile_label",
        "api": "legacy",
        "korean": "백수",
        "english": "unemployed",
        "context_id": ""
      },
      "field": "korean",
      "value": "백수 변조"
    },
    "expected": "Semantic REJECT while raw source guard remains PASS; not counted as a raw-gate negative.",
    "endpoint": "semantic"
  },
  {
    "id": "selector_english",
    "kind": "negative",
    "base": "current_normal",
    "recipe": {
      "op": "replace_exact_one_UiCall_field",
      "selector": {
        "path": "autoloads/GameState.gd",
        "function": "_localized_profile_label",
        "api": "legacy",
        "korean": "백수",
        "english": "unemployed",
        "context_id": ""
      },
      "field": "english",
      "value": "employed"
    },
    "expected": "Semantic REJECT while raw source guard remains PASS; not counted as a raw-gate negative.",
    "endpoint": "semantic"
  },
  {
    "id": "selector_context_id",
    "kind": "negative",
    "base": "current_normal",
    "recipe": {
      "op": "replace_exact_one_UiCall_field",
      "selector": {
        "path": "autoloads/GameState.gd",
        "function": "_localized_profile_label",
        "api": "legacy",
        "korean": "백수",
        "english": "unemployed",
        "context_id": ""
      },
      "field": "context_id",
      "value": "ui.order267.unowned"
    },
    "expected": "Semantic REJECT while raw source guard remains PASS; not counted as a raw-gate negative.",
    "endpoint": "semantic"
  },
  {
    "id": "selector_missing_profile",
    "kind": "negative",
    "base": "current_normal",
    "recipe": {
      "op": "remove_exact_one",
      "selector": {
        "path": "autoloads/GameState.gd",
        "function": "_localized_profile_label",
        "api": "legacy",
        "korean": "백수",
        "english": "unemployed",
        "context_id": ""
      }
    },
    "expected": "Semantic REJECT.",
    "endpoint": "semantic"
  },
  {
    "id": "selector_duplicate_category",
    "kind": "negative",
    "base": "current_normal",
    "recipe": {
      "op": "append_duplicate_exact_one",
      "selector": {
        "path": "autoloads/GameState.gd",
        "function": "_roll_run_theme",
        "api": "legacy",
        "korean": "건강",
        "english": "Health",
        "context_id": ""
      }
    },
    "expected": "Semantic REJECT.",
    "endpoint": "semantic"
  },
  {
    "id": "selector_missing_parent",
    "kind": "negative",
    "base": "current_normal",
    "recipe": {
      "op": "remove_exact_one",
      "selector": {
        "path": "autoloads/GameState.gd",
        "function": "start_new_game",
        "api": "format",
        "korean": "다시 시작한 아침. 출발점은 %s였다.",
        "english": "Another beginning. He started out %s.",
        "context_id": ""
      }
    },
    "expected": "Semantic REJECT.",
    "endpoint": "semantic"
  },
  {
    "id": "selector_extra_owner_call",
    "kind": "negative",
    "base": "current_normal",
    "recipe": {
      "op": "append_call",
      "path": "autoloads/GameState.gd",
      "function": "_roll_run_theme",
      "api": "legacy",
      "korean": "미승인",
      "english": "Unapproved",
      "context_id": "",
      "line": 1
    },
    "expected": "Semantic REJECT; approved owner cannot acquire an unregistered extra call.",
    "endpoint": "semantic"
  },
  {
    "id": "selector_nonselected_drift",
    "kind": "negative",
    "base": "current_normal",
    "recipe": {
      "op": "replace_exact_one_UiCall_field",
      "selector": {
        "path": "autoloads/GameState.gd",
        "function": "get_job_display_name",
        "api": "legacy",
        "korean": "직장",
        "english": "Job",
        "context_id": ""
      },
      "field": "english",
      "value": "Employer"
    },
    "expected": "Semantic REJECT; historical nonselected projection must match exact old parsed GS calls (line observations excluded).",
    "endpoint": "semantic"
  },
  {
    "id": "arguments_profile_en_uses_target",
    "kind": "negative",
    "base": "current_normal",
    "recipe": {
      "op": "replace_exact_one_UiFormatArgumentShape_field",
      "owner": "start_new_game",
      "field": "en_args",
      "value": "[_localized_profile_label(starting_profile)]"
    },
    "expected": "Semantic provenance REJECT with normal source/calls unchanged; compare existing normalized argument expressions, not pretty-print whitespace.",
    "endpoint": "semantic"
  },
  {
    "id": "arguments_theme_en_uses_target",
    "kind": "negative",
    "base": "current_normal",
    "recipe": {
      "op": "replace_exact_one_UiFormatArgumentShape_field",
      "owner": "_roll_run_theme",
      "field": "en_args",
      "value": "[a, b]"
    },
    "expected": "Semantic provenance REJECT with normal source/calls unchanged; compare existing normalized argument expressions, not pretty-print whitespace.",
    "endpoint": "semantic"
  },
  {
    "id": "arguments_theme_en_reversed",
    "kind": "negative",
    "base": "current_normal",
    "recipe": {
      "op": "replace_exact_one_UiFormatArgumentShape_field",
      "owner": "_roll_run_theme",
      "field": "en_args",
      "value": "[english_labels.get(pool[1], pool[1]), english_labels.get(pool[0], pool[0])]"
    },
    "expected": "Semantic provenance REJECT with normal source/calls unchanged; compare existing normalized argument expressions, not pretty-print whitespace.",
    "endpoint": "semantic"
  },
  {
    "id": "arguments_profile_target_uses_en",
    "kind": "negative",
    "base": "current_normal",
    "recipe": {
      "op": "replace_exact_one_UiFormatArgumentShape_field",
      "owner": "start_new_game",
      "field": "ko_args",
      "value": "[_localized_profile_label(starting_profile, true)]"
    },
    "expected": "Semantic provenance REJECT with normal source/calls unchanged; compare existing normalized argument expressions, not pretty-print whitespace.",
    "endpoint": "semantic"
  },
  {
    "id": "arguments_missing_parent_shape",
    "kind": "negative",
    "base": "current_normal",
    "recipe": {
      "op": "remove_exact_one_UiFormatArgumentShape",
      "owner": "_roll_run_theme"
    },
    "expected": "Semantic REJECT; calls still contain both parents.",
    "endpoint": "semantic"
  },
  {
    "id": "semantic_order_and_locations",
    "kind": "normal",
    "base": "current_normal",
    "recipe": "Reverse calls and shapes; set supplied line observations to original line+31. Do not alter owner/API/pairs/context/arguments.",
    "expected": "Semantic PASS; line/order are observations, not semantic authority. Actual collector normal independently binds refreshed real lines from current raw.",
    "endpoint": "semantic"
  },
  {
    "id": "registry_gs_prior",
    "kind": "negative",
    "base": "current_normal",
    "recipe": {
      "path": "autoloads/GameState.gd",
      "mutation": {
        "field": "previous_sha256",
        "value": "0000000000000000000000000000000000000000000000000000000000000000"
      },
      "reseal": "Canonical json ensure_ascii=False/sort_keys=True/separators(',',':'); recalculate registry digest only; do not alter independent fixed pins or code."
    },
    "expected": "REJECT despite digest reseal; invalid projector identity.",
    "endpoint": "helper3"
  },
  {
    "id": "registry_gs_missing_inverse",
    "kind": "negative",
    "base": "current_normal",
    "recipe": {
      "path": "autoloads/GameState.gd",
      "mutation": {
        "remove_inverse_id": "profile_parent"
      },
      "reseal": "Canonical json ensure_ascii=False/sort_keys=True/separators(',',':'); recalculate registry digest only; do not alter independent fixed pins or code."
    },
    "expected": "REJECT despite digest reseal; invalid projector identity.",
    "endpoint": "helper3"
  },
  {
    "id": "registry_gs_duplicate_inverse",
    "kind": "negative",
    "base": "current_normal",
    "recipe": {
      "path": "autoloads/GameState.gd",
      "mutation": {
        "duplicate_inverse_id": "profile_parent"
      },
      "reseal": "Canonical json ensure_ascii=False/sort_keys=True/separators(',',':'); recalculate registry digest only; do not alter independent fixed pins or code."
    },
    "expected": "REJECT despite digest reseal; invalid projector identity.",
    "endpoint": "helper3"
  },
  {
    "id": "registry_pipeline_prior",
    "kind": "negative",
    "base": "current_normal",
    "recipe": {
      "path": "tools/ja_translation_pipeline.py",
      "mutation": {
        "field": "previous_sha256",
        "value": "0000000000000000000000000000000000000000000000000000000000000000"
      },
      "reseal": "Canonical json ensure_ascii=False/sort_keys=True/separators(',',':'); recalculate registry digest only; do not alter independent fixed pins or code."
    },
    "expected": "REJECT despite digest reseal; invalid projector identity.",
    "endpoint": "helper3"
  },
  {
    "id": "forged_year5",
    "kind": "negative",
    "base": "current_normal",
    "recipe": {
      "raw": "gs_unrelated_byte",
      "spoof_scope": "year5",
      "spoof": "Only public byte projector→old8a407 bytes and this consumer's observed-hash return→8a407. Keep new source_errors original; collect direct helper observations outside spoof."
    },
    "expected": "Actual consumer REJECT from physical raw prerequisite despite apparently historical observations; all aliases restored.",
    "endpoint": "live"
  },
  {
    "id": "forged_chapter",
    "kind": "negative",
    "base": "current_normal",
    "recipe": {
      "raw": "gs_unrelated_byte",
      "spoof_scope": "chapter",
      "spoof": "Only public byte projector→old8a407 bytes and this consumer's observed-hash return→8a407. Keep new source_errors original; collect direct helper observations outside spoof."
    },
    "expected": "Actual consumer REJECT from physical raw prerequisite despite apparently historical observations; all aliases restored.",
    "endpoint": "live"
  },
  {
    "id": "wrong_registered_previous",
    "kind": "negative",
    "base": "current_normal",
    "recipe": "new_run_log_source_errors(GS, current, '0'*64); actual raw normal.",
    "expected": "REJECT optional registration; default registration normal is separate.",
    "endpoint": "registered_source"
  },
  {
    "id": "wrong_claim",
    "kind": "claim",
    "base": "current_normal",
    "recipe": "Call new and GS public hash projector with claim='0'*64 and valid current raw.",
    "expected": "Source validation PASS; hash returns unchanged wrong claim, not previous hash. Not an effective source rejection.",
    "endpoint": "hash2"
  },
  {
    "id": "off_path",
    "kind": "off",
    "base": "current_normal",
    "recipe": "relative='autoloads/NotOwned.gd', current=b'ORDER267_OFF\\r\\n', claim='0'*64.",
    "expected": "New errors=[]/bytes identity/hash identity; public result equals captured predecessor API with same arguments exactly.",
    "endpoint": "helper/public"
  }
]''')
# END_NEW_RUN_BINDING_267


def sha(raw):
    return hashlib.sha256(raw).hexdigest()


def canonical(value):
    return sha(json.dumps(value, ensure_ascii=False, sort_keys=True, separators=(",", ":")).encode())


def code_view(raw):
    start, end = b"# BEGIN_NEW_RUN_BINDING_267\n", b"# END_NEW_RUN_BINDING_267\n"
    if raw.count(start) != 1 or raw.count(end) != 1:
        raise AssertionError("binding boundaries")
    a, z = raw.index(start), raw.index(end) + len(end)
    return raw[:a] + b"# NEW_RUN_BINDING_VIEW\n" + raw[z:]


def pins():
    paths = set(BINDING["code"]) | set(UI) | {GS, SELF, "scenes/MainGame.gd",
        "autoloads/DataRegistry.gd", "autoloads/LocaleManager.gd", "autoloads/MetaProgression.gd"}
    return {p: {"bytes": len(raw), "sha256": sha(raw)} for p in sorted(paths)
            for raw in [(ROOT / p).read_bytes()]}


def once(raw, before, after):
    before, after = before.encode(), after.encode()
    if not before or raw.count(before) != 1:
        raise AssertionError("exact-one materialization")
    return raw.replace(before, after, 1)


def inverse(raw, rule):
    if rule["kind"] == "replace":
        return once(raw, rule["after"], rule["before"])
    start = rule["start"].encode()
    end = rule["end"].encode() if rule["end"] is not None else None
    if raw.count(start) != 1 or (end is not None and raw.count(end) != 1):
        raise AssertionError("inverse boundaries")
    a = raw.index(start)
    z = len(raw) if end is None else raw.index(end, a) + len(end)
    if sha(raw[a:z]) != rule["span_sha256"]:
        raise AssertionError("independent inverse span hash")
    return raw[:a] + raw[z:]


def prepare():
    if BINDING["phase"] != "APPLIED_SOURCE_BOUND":
        raise AssertionError("ORDER267 candidate is not authorized for execution")
    if sha(code_view((ROOT / SELF).read_bytes())) != BINDING["self_code_view_sha256"]:
        raise AssertionError("self code view changed; full raw pin is external")
    if len(FROZEN) != 36 or canonical(FROZEN) != BINDING["source_cases_sha256"]:
        raise AssertionError("independent36 changed")
    current, previous = {}, {}
    for p, row in BINDING["code"].items():
        raw = (ROOT / p).read_bytes()
        if sha(raw) != row["current_sha256"]:
            raise AssertionError("physical code pin: " + p)
        current[p], previous[p] = raw, inverse(raw, row["inverse"])
        if sha(previous[p]) != row["previous_sha256"]:
            raise AssertionError("whole code inverse: " + p)
    plan = BINDING["gs_plan"]
    current[GS] = (ROOT / GS).read_bytes()
    if sha(current[GS]) != plan["proposed_sha256"]:
        raise AssertionError("physical GameState pin")
    previous[GS] = current[GS]
    for row in reversed(plan["inverses"]):
        previous[GS] = once(previous[GS], row["after"], row["before"])
    if sha(previous[GS]) != plan["previous_sha256"]:
        raise AssertionError("whole GameState inverse")
    return current, previous


def identity():
    return (Path.read_bytes, Path.read_text, history.main_game_history_source_errors,
        history.main_game_history_project_bytes, history.main_game_history_project_byte_hash,
        pipeline.collect_ui_inventory, pipeline._last11_meta_title_historical_checks,
        year5.validate_order156_registration, year5._order243_history_byte_hash,
        chapter._audited_source_snapshot_errors, chapter._order243_history_byte_hash,
        history.new_run_log_source_errors)


@contextlib.contextmanager
def path_view(values, observation):
    values = {ROOT / p: raw for p, raw in values.items()}
    read0, text0 = Path.read_bytes, Path.read_text

    def read_bytes(path):
        return values[path] if path in values else read0(path)

    def read_text(path, *args, **kwargs):
        if path in values:
            return values[path].decode(kwargs.get("encoding") or (args[0] if args else None) or "utf-8",
                                       errors=kwargs.get("errors") or "strict")
        return text0(path, *args, **kwargs)

    try:
        with patch.object(Path, "read_bytes", read_bytes), patch.object(Path, "read_text", read_text):
            yield
    finally:
        observation["path_restored"] = Path.read_bytes is read0 and Path.read_text is text0


def json_value(value, references):
    if isinstance(value, bytes):
        names = [name for name, raw in references.items() if value == raw]
        result = {"bytes": len(value), "sha256": sha(value), "exact_raw_references": names}
        if not names:
            result["base64"] = base64.b64encode(value).decode()
        return result
    if hasattr(value, "__dataclass_fields__"):
        return json_value(asdict(value), references)
    if isinstance(value, dict):
        return {str(k): json_value(v, references) for k, v in value.items()}
    if isinstance(value, (list, tuple)):
        return [json_value(v, references) for v in value]
    return value


def api_values(path, raw, claim=None):
    claim = sha(raw) if claim is None else claim
    return {
        "new_errors": history.new_run_log_source_errors(path, raw),
        "new_bytes": history.new_run_log_project_bytes(raw, path),
        "new_hash": history.new_run_log_project_byte_hash(claim, path, raw),
        "public_errors": history.main_game_history_source_errors(path, raw),
        "public_bytes": history.main_game_history_project_bytes(raw, path),
        "public_hash": history.main_game_history_project_byte_hash(claim, path, raw),
    }


def live_values(raw, which="both", forged=False, old=None):
    result, restored = {}, {}
    with path_view({GS: raw}, restored):
        for name, module in (("year5", year5), ("chapter", chapter)):
            if which not in ("both", name):
                continue
            project0, observed0 = history.main_game_history_project_bytes, module._order243_history_byte_hash
            with contextlib.ExitStack() as stack:
                if forged:
                    stack.enter_context(patch.object(history, "main_game_history_project_bytes",
                        lambda value, p: old if p == GS else project0(value, p)))
                    stack.enter_context(patch.object(module, "_order243_history_byte_hash",
                        lambda claim, p: sha(old) if p == GS else observed0(claim, p)))
                if name == "year5":
                    errors = []
                    stats = module.validate_order156_registration(errors)
                    result[name] = {"errors": errors, "stats": stats,
                        "registered_pair": list(module.ORDER156_SOURCE_FILE_TRANSITIONS[GS]),
                        "provider_isolation": "Only GameState Path bytes/text; original registration/Git providers and gate execute."}
                else:
                    hashes = {GS: module.EXPECTED_AUDITED_SOURCE_FILE_SHA256[GS]}
                    result[name] = {"errors": module._audited_source_snapshot_errors(hashes),
                        "source_hashes": hashes, "provider_isolation": "Only GameState Path bytes/text; original snapshot gate and _file_digest execute."}
            restored[name + "_observer_restored"] = (history.main_game_history_project_bytes is project0
                and module._order243_history_byte_hash is observed0)
    result["restoration"] = restored
    return result


def selector(call):
    return (call.path, call.function, call.api, call.korean, call.english, call.context_id)


def current_normal(current, previous):
    values = {"gs": api_values(GS, current[GS]), "pipeline": api_values(JA, current[JA]),
        "registered_errors": history.new_run_log_source_errors(GS, current[GS], sha(previous[GS]))}
    calls, parse_errors = pipeline.parse_ui_calls(GS, current[GS].decode())
    shapes, shape_errors = pipeline._new_run_log_argument_shapes(current[GS].decode())
    old_calls, old_parse = pipeline.parse_ui_calls(GS, previous[GS].decode())
    projected, old_source, semantic_errors = pipeline._new_run_log_predecessor_calls(calls, current[GS].decode(), shapes)
    inventory = pipeline.collect_ui_inventory()
    actual_gs = [c for c in inventory.calls if c.path == GS]
    values["semantic"] = {"errors": semantic_errors, "parse_errors": parse_errors + shape_errors + old_parse,
        "previous_source_exact": old_source.encode() == previous[GS],
        "previous_calls_exact": Counter(map(selector, projected)) == Counter(map(selector, old_calls))}
    values["collector"] = {"errors": list(inventory.errors), "stats": inventory.stats,
        "current_api_counts_exact": all(inventory.stats.get(key) == sum(c.api == api for c in inventory.calls)
            for key, api in (("legacy_api_calls", "legacy"), ("branch_variant_calls", "branch"), ("format_calls", "format"), ("context_calls", "context"))),
        "current_api_partition_exact": inventory.stats.get("legacy_calls") == sum(inventory.stats.get(key, -1)
            for key in ("legacy_api_calls", "branch_variant_calls", "format_calls"))
            and inventory.stats.get("source_calls") == inventory.stats.get("legacy_calls", -1) + inventory.stats.get("context_calls", -1),
        "physical_gs_calls_exact": sorted(map(asdict, actual_gs), key=lambda c: (c["line"], c["api"])) == sorted(map(asdict, calls), key=lambda c: (c["line"], c["api"])),
        "gs_call_delta": len(calls) - len(old_calls),
        "gs_format_delta": sum(c.api == "format" for c in calls) - sum(c.api == "format" for c in old_calls),
        "current_gs_calls": calls, "argument_shapes": shapes}
    values["live"] = live_values(current[GS])
    gs, ja, semantic, collector = values["gs"], values["pipeline"], values["semantic"], values["collector"]
    passed = (not gs["new_errors"] and not gs["public_errors"] and gs["new_bytes"] == gs["public_bytes"] == previous[GS]
        and gs["new_hash"] == gs["public_hash"] == sha(previous[GS]) and not ja["new_errors"]
        and ja["new_bytes"] == previous[JA] and ja["new_hash"] == sha(previous[JA]) and not values["registered_errors"]
        and not semantic["errors"] and not semantic["parse_errors"] and semantic["previous_source_exact"] and semantic["previous_calls_exact"]
        and not collector["errors"] and collector["physical_gs_calls_exact"] and collector["current_api_counts_exact"] and collector["current_api_partition_exact"]
        and collector["gs_call_delta"] == 9 and collector["gs_format_delta"] == 2
        and all(not values["live"][name]["errors"] for name in ("year5", "chapter")) and all(values["live"]["restoration"].values()))
    return passed, values


def mutate_semantic(case, calls, shapes):
    recipe = case["recipe"]
    if isinstance(recipe, str):
        return [replace(c, line=c.line + 31) for c in reversed(calls)], [replace(r, line=r.line + 31) for r in reversed(shapes)]
    calls, shapes = list(calls), list(shapes)
    op = recipe["op"]
    if "UiFormatArgumentShape" in op:
        indices = [i for i, r in enumerate(shapes) if r.function == recipe["owner"]]
        if len(indices) != 1:
            raise AssertionError("shape target is not exact1")
        i = indices[0]
        if op.startswith("remove"):
            shapes.pop(i)
        else:
            shapes[i] = replace(shapes[i], **{recipe["field"]: recipe["value"]})
    elif op == "append_call":
        calls.append(pipeline.UiCall(**{k: v for k, v in recipe.items() if k != "op"}))
    else:
        wanted = recipe["selector"]
        indices = [i for i, c in enumerate(calls) if all(getattr(c, k) == v for k, v in wanted.items())]
        if len(indices) != 1:
            raise AssertionError("call target is not exact1")
        i = indices[0]
        if op == "remove_exact_one":
            calls.pop(i)
        elif op == "append_duplicate_exact_one":
            calls.append(calls[i])
        else:
            calls[i] = replace(calls[i], **{recipe["field"]: recipe["value"]})
    return calls, shapes


def execute_case(case, current, previous):
    cid, endpoint = case["id"], case["endpoint"]
    if cid == "current_normal":
        return current_normal(current, previous)
    if endpoint == "semantic":
        calls, errors = pipeline.parse_ui_calls(GS, current[GS].decode())
        shapes, shape_errors = pipeline._new_run_log_argument_shapes(current[GS].decode())
        changed_calls, changed_shapes = mutate_semantic(case, calls, shapes)
        if changed_calls == calls and changed_shapes == shapes:
            raise AssertionError("semantic mutation did not change input")
        raw_errors = history.new_run_log_source_errors(GS, current[GS]) + history.new_run_log_source_errors(JA, current[JA])
        old, source, result_errors = pipeline._new_run_log_predecessor_calls(changed_calls, current[GS].decode(), changed_shapes)
        normal = case["kind"] == "normal"
        old_calls, old_errors = pipeline.parse_ui_calls(GS, previous[GS].decode())
        passed = (not raw_errors and not errors and not shape_errors and not old_errors
            and ((not result_errors and source.encode() == previous[GS] and Counter(map(selector, old)) == Counter(map(selector, old_calls))) if normal
                 else (bool(result_errors) and tuple(old) == tuple(changed_calls) and source.encode() == current[GS])))
        return passed, {"raw_errors": raw_errors, "semantic_errors": result_errors, "input_calls": changed_calls,
            "input_shapes": changed_shapes, "returned_calls": old, "returned_source": source.encode(), "mutation_changed": True}
    if cid.startswith("registry_"):
        registry = copy.deepcopy(history.NEW_RUN_LOG_TRANSITIONS)
        recipe = case["recipe"]
        row, mutation = registry[recipe["path"]], recipe["mutation"]
        if "field" in mutation:
            row[mutation["field"]] = mutation["value"]
        else:
            ident = mutation.get("remove_inverse_id", mutation.get("duplicate_inverse_id"))
            found = [r for r in row["inverses"] if r["id"] == ident]
            if len(found) != 1:
                raise AssertionError("registry target not exact1")
            if "remove_inverse_id" in mutation:
                row["inverses"].remove(found[0])
            else:
                row["inverses"].append(copy.deepcopy(found[0]))
        digest = canonical(registry)
        with patch.object(history, "NEW_RUN_LOG_TRANSITIONS", registry), patch.object(history, "_NEW_RUN_LOG_REGISTRY_SHA256", digest):
            path = recipe["path"]
            values = api_values(path, current[path])
        passed = bool(values["new_errors"]) and values["new_bytes"] == current[path] and values["new_hash"] == sha(current[path])
        return passed, {"registry": registry, "resealed_sha256": digest, "values": values}
    if cid == "wrong_registered_previous":
        errors = history.new_run_log_source_errors(GS, current[GS], "0" * 64)
        default_errors = history.new_run_log_source_errors(GS, current[GS])
        return bool(errors) and not default_errors, {"errors": errors, "default_errors": default_errors}
    if cid == "wrong_claim":
        values = api_values(GS, current[GS], "0" * 64)
        return not values["new_errors"] and not values["public_errors"] and values["new_hash"] == values["public_hash"] == "0" * 64, values
    if cid == "off_path":
        path, raw, claim = "autoloads/NotOwned.gd", b"ORDER267_OFF\r\n", "0" * 64
        values = api_values(path, raw, claim)
        old = {"errors": history._NEW_RUN_OLD_SOURCE_ERRORS(path, raw), "bytes": history._NEW_RUN_OLD_PROJECT_BYTES(raw, path),
            "hash": history._NEW_RUN_OLD_PROJECT_HASH(claim, path, raw)}
        return (values["new_errors"] == [] and values["new_bytes"] == raw and values["new_hash"] == claim
            and (values["public_errors"], values["public_bytes"], values["public_hash"]) == (old["errors"], old["bytes"], old["hash"])), {"values": values, "old": old}
    path = JA if cid.startswith("pipeline_") else GS
    raw = current[path]
    if cid.endswith("whole_rollback"):
        raw = previous[path]
    elif cid.startswith("gs_rollback_"):
        ident = cid.removeprefix("gs_rollback_")
        rows = [r for r in BINDING["gs_plan"]["inverses"] if r["id"] == ident]
        if len(rows) != 1:
            raise AssertionError("frozen inverse ID")
        raw = once(raw, rows[0]["after"], rows[0]["before"])
    elif cid == "gs_crlf":
        if b"\r" in raw:
            raise AssertionError("CRLF recipe needs LF input")
        raw = raw.replace(b"\n", b"\r\n")
    elif cid == "gs_final_lf_missing":
        if not raw.endswith(b"\n"):
            raise AssertionError("final LF missing in base")
        raw = raw[:-1]
    else:
        raw += b"\n# ORDER267_UNOWNED\n"
    if raw == current[path]:
        raise AssertionError("raw mutation did not change input")
    values = api_values(path, raw)  # Direct observation is deliberately OUTSIDE forged live scope.
    passed = bool(values["new_errors"]) and values["new_bytes"] == raw and values["new_hash"] == sha(raw)
    result = {"path": path, "input_base64": base64.b64encode(raw).decode(), "values": values,
        "direct_outside_spoof": True}
    if "public3" in endpoint:
        passed = passed and bool(values["public_errors"]) and values["public_bytes"] == raw and values["public_hash"] == sha(raw)
    if "live" in endpoint:
        which = cid.removeprefix("forged_") if cid.startswith("forged_") else "both"
        live = live_values(raw, which, cid.startswith("forged_"), previous[GS])
        result["live"] = live
        names = ("year5", "chapter") if which == "both" else (which,)
        passed = passed and all(live[name]["errors"] for name in names) and all(live["restoration"].values())
    if "collector" in endpoint:
        restored = {}
        with path_view({path: raw}, restored):
            inventory = pipeline.collect_ui_inventory()
        result["collector"] = {"errors": list(inventory.errors), "stats": inventory.stats, "restoration": restored}
        passed = passed and bool(inventory.errors) and all(restored.values())
    return passed, result


def capture_case(case, current, previous):
    before = identity()
    registry_before = canonical(history.NEW_RUN_LOG_TRANSITIONS)
    out, err, fatal, values, passed = io.StringIO(), io.StringIO(), None, {}, False
    references = {"current:" + p: raw for p, raw in current.items()} | {"previous:" + p: raw for p, raw in previous.items()}
    try:
        with contextlib.redirect_stdout(out), contextlib.redirect_stderr(err):
            passed, values = execute_case(case, current, previous)
    except Exception as exc:
        fatal = {"error": type(exc).__name__ + ": " + str(exc), "traceback": traceback.format_exc()}
    restored = identity() == before and canonical(history.NEW_RUN_LOG_TRANSITIONS) == registry_before
    return {"id": case["id"], "kind": case["kind"], "endpoint": case["endpoint"],
        "passed": bool(passed and fatal is None and restored and not err.getvalue()),
        "values": json_value(values, references), "stdout": out.getvalue(), "stderr": err.getvalue(),
        "exception": fatal, "callables_registry_restored": restored}


@contextlib.contextmanager
def historical_view(previous, observation):
    before, aliases = identity(), []
    pairs = [(history.main_game_history_source_errors, history._NEW_RUN_OLD_SOURCE_ERRORS),
        (history.main_game_history_project_bytes, history._NEW_RUN_OLD_PROJECT_BYTES),
        (history.main_game_history_project_byte_hash, history._NEW_RUN_OLD_PROJECT_HASH),
        (pipeline.collect_ui_inventory, pipeline._NEW_RUN_OLD_COLLECT),
        (pipeline._last11_meta_title_historical_checks, pipeline._NEW_RUN_OLD_CHECKS),
        (year5.validate_order156_registration, year5._NEW_RUN_OLD_REGISTRATION),
        (year5._order243_history_byte_hash, year5._NEW_RUN_OLD_OBSERVED_HASH),
        (chapter._audited_source_snapshot_errors, chapter._NEW_RUN_OLD_SNAPSHOT_ERRORS),
        (chapter._order243_history_byte_hash, chapter._NEW_RUN_OLD_OBSERVED_HASH)]
    try:
        with contextlib.ExitStack() as stack:
            stack.enter_context(path_view(previous, observation))
            for module in tuple(sys.modules.values()):
                if module is None or not str(getattr(module, "__file__", "")).startswith(str(ROOT / "tools")):
                    continue
                for attr, value in tuple(vars(module).items()):
                    for current, old in pairs:
                        if value is current:
                            aliases.append((module, attr, value))
                            stack.enter_context(patch.object(module, attr, old))
                            break
            observation["imported_aliases"] = [m.__name__ + "." + a for m, a, _ in aliases]
            yield
    finally:
        observation["callables_restored"] = identity() == before
        observation["imported_aliases_restored"] = all(getattr(m, a) is old for m, a, old in aliases)


def restoration_exception(previous):
    out, err, observed, caught = io.StringIO(), io.StringIO(), {}, None
    try:
        with historical_view(previous, observed), contextlib.redirect_stdout(out), contextlib.redirect_stderr(err):
            print("ORDER267_HISTORY_EXCEPTION_STDOUT")
            print("ORDER267_HISTORY_EXCEPTION_STDERR", file=sys.stderr)
            raise RuntimeError("ORDER267 deliberate history exception")
    except RuntimeError as exc:
        caught = str(exc)
    passed = (caught == "ORDER267 deliberate history exception" and out.getvalue() == "ORDER267_HISTORY_EXCEPTION_STDOUT\n"
        and err.getvalue() == "ORDER267_HISTORY_EXCEPTION_STDERR\n" and all(observed.get(k) is True
            for k in ("path_restored", "callables_restored", "imported_aliases_restored")))
    return {"passed": passed, "exception": caught, "stdout": out.getvalue(), "stderr": err.getvalue(),
        "restoration": observed, "old_suite_calls": 0}


def delegation_supplement():
    results = []
    for path in ("scenes/MainGame.gd", "autoloads/DataRegistry.gd"):
        for label, raw in (("actual", (ROOT / path).read_bytes()), ("malformed", b"ORDER267_OFF\r\n")):
            claim = sha(raw)
            current = (history.main_game_history_source_errors(path, raw), history.main_game_history_project_bytes(raw, path),
                       history.main_game_history_project_byte_hash(claim, path, raw))
            old = (history._NEW_RUN_OLD_SOURCE_ERRORS(path, raw), history._NEW_RUN_OLD_PROJECT_BYTES(raw, path),
                   history._NEW_RUN_OLD_PROJECT_HASH(claim, path, raw))
            results.append({"path": path, "input": label, "passed": current == old,
                "current": json_value(current, {"input": raw}), "saved": json_value(old, {"input": raw})})
    return results


def historical_entry(function, kind):
    before, after, fatal, prerequisite, old_result, exception_probe, restored = None, None, None, {}, {}, {}, {}
    out, err, passed, old_invoked, after_error = io.StringIO(), io.StringIO(), False, False, None
    try:
        for name in ("gift_caption_locale_self_test", "ci_localization_reconciliation_self_test", "meta_title_locale_successor_self_test"):
            importlib.import_module(name)  # Definitions only; no __main__ execution.
        before = pins()
        current, previous = prepare()
        prerequisite = capture_case(FROZEN[0], current, previous)
        if prerequisite["passed"]:
            exception_probe = restoration_exception(previous)
            if exception_probe["passed"]:
                with historical_view(previous, restored), contextlib.redirect_stdout(out), contextlib.redirect_stderr(err):
                    old_invoked = True
                    code = function()
                parsed, end = json.JSONDecoder().raw_decode(out.getvalue())
                marker = out.getvalue()[end:].strip()
                wanted = {"ci": "GIFT_CAPTION_HISTORY_OK kind=ci", "meta": "GIFT_CAPTION_HISTORY_OK kind=meta",
                          "gift": "GIFT_CAPTION_SOURCE_SELF_TEST_OK cases=22 unchanged=True"}[kind]
                logical = parsed.get("physical_before")
                logical_ok = logical == parsed.get("physical_after") and isinstance(logical, dict) and all(
                    logical.get(p, {}).get("sha256") == row["previous_sha256"] for p, row in BINDING["code"].items())
                old_result = {"exit": code, "marker": marker, "passed": parsed.get("passed") is True,
                    "logical_pins_exact": logical_ok, "logical_before": logical, "logical_after": parsed.get("physical_after")}
                passed = code == 0 and marker == wanted and old_result["passed"] and logical_ok and all(
                    restored.get(k) is True for k in ("path_restored", "callables_restored", "imported_aliases_restored"))
    except Exception as exc:
        fatal = {"error": type(exc).__name__ + ": " + str(exc), "traceback": traceback.format_exc()}
    finally:
        try:
            after = pins()
        except Exception as exc:
            after_error = {"error": type(exc).__name__ + ": " + str(exc), "traceback": traceback.format_exc()}
    passed = bool(passed and fatal is None and after_error is None and before is not None and before == after and not err.getvalue())
    print(json.dumps({"scope": "ORDER267 current prerequisite then pre267 " + kind, "passed": passed,
        "normal_prerequisite": prerequisite, "exception_probe": exception_probe, "historical": old_result,
        "stdout": out.getvalue(), "stderr": err.getvalue(), "fatal": fatal, "after_error": after_error, "restoration": restored,
        "physical_before": before, "physical_after": after, "unchanged": before is not None and before == after,
        "execution_counts": {"normal_prerequisite": int(bool(prerequisite)), "new36": 0,
            "old_entry": int(old_invoked), "exception_old_suite_calls": 0, "engine": 0}}, ensure_ascii=False, indent=2))
    print("NEW_RUN_LOG_HISTORY_" + ("OK" if passed else "FAIL") + " kind=" + kind)
    return 0 if passed else 1


def main():
    before, after, fatal, after_error, results, supplement = None, None, None, None, [], []
    try:
        before = pins()
        current, previous = prepare()
        for case in FROZEN:
            results.append(capture_case(case, current, previous))
        supplement = delegation_supplement()
    except Exception as exc:
        fatal = {"error": type(exc).__name__ + ": " + str(exc), "traceback": traceback.format_exc()}
    finally:
        try:
            after = pins()
        except Exception as exc:
            after_error = {"error": type(exc).__name__ + ": " + str(exc), "traceback": traceback.format_exc()}
    normal = bool(results and results[0]["passed"])
    for result in results:
        result["normal_base_passed"] = normal
        result["effective_negative"] = normal and result["passed"] and result["kind"] == "negative"
    passed = bool(len(results) == 36 and all(r["passed"] for r in results) and normal and len(supplement) == 4
        and all(r["passed"] for r in supplement) and fatal is None and after_error is None and before is not None and before == after)
    print(json.dumps({"scope": "ORDER267 source36 only; historical suites are separate entries", "passed": passed,
        "precode_sha256": BINDING["source_case_plan_sha256"], "results": results, "delegation_supplement": supplement,
        "fatal": fatal, "after_error": after_error, "physical_before": before, "physical_after": after, "unchanged": before is not None and before == after,
        "execution_counts": {"source_cases": len(results), "normal": sum(r["passed"] for r in results if r["kind"] == "normal"),
            "effective_negative": sum(r["effective_negative"] for r in results), "claim": 1 if len(results) == 36 else 0,
            "OFF": 1 if len(results) == 36 else 0, "delegation_supplement": len(supplement), "historical_suites": 0, "engine": 0}},
        ensure_ascii=False, indent=2))
    print("NEW_RUN_LOG_SOURCE_SELF_TEST_" + ("OK" if passed else "FAIL") + f" cases={len(results)} unchanged={before == after}")
    return 0 if passed else 1


if __name__ == "__main__":
    raise SystemExit(main())
