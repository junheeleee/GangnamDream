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
FULLSELF = "tools/full_game_localization_self_test.py"
UI = ("locale/ui_ja.json", "locale/ui_zh-CN.json", "locale/ui_zh-TW.json")
# BEGIN_NEW_RUN_BINDING_267
BINDING = json.loads(r'''{
  "phase": "APPLIED_SOURCE_BOUND",
  "code": {
    "tools/main_game_locale_history.py": {
      "bytes": 40220,
      "current_sha256": "734fab4d28ee5907b5ecb0441f5c37cd0e0fefc3b922784a3b8882959d90d6d5",
      "previous_sha256": "f1ef7d55c029982f85f28681898c152344709dbbd63b87e6dabb5d350ed2a55e",
      "inverse": {
        "kind": "span",
        "start": "\n# BEGIN_NEW_RUN_LOG_HISTORY_267\n",
        "end": null,
        "span_sha256": "10cf40dd79292fd2a2b1632b606280e10e764039eeea19b92421850d6096600e"
      }
    },
    "tools/ja_translation_pipeline.py": {
      "bytes": 280548,
      "current_sha256": "90ad8caf9efc07d217cb8960715434ae09ae227de4ce0dee36e5ad74278ea270",
      "previous_sha256": "8bb536853809fa273587734215bfcb3d6a78b9bd4d4b941b595e2136e8ebec6c",
      "inverse": {
        "kind": "span",
        "start": "# BEGIN_NEW_RUN_LOG_COLLECTOR_267\n",
        "end": "# END_NEW_RUN_LOG_COLLECTOR_267\n\n",
        "span_sha256": "991227b74314628c16bfe403046787b9620f10b942d5ab6c2fd94df8156fce2a"
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
  "self_code_view_sha256": "15c8ceba38130c61d35ea84794dbeb26e11f2f0dfa801a8eb2bf3cc1376a577a",
  "provenance": {
    "root_execution_approval": "2026-09-20 ROOT: tools8 independent pre-execution PASS ee004c83324fa283f8e46d32963718bbc9bf0a4ccdd29e141afa477d40b63ac0; only binding phase/provenance changed, full raw externally pinned before execution. Original GS proposal remains quoted below its original phase.",
    "chronology": "Post-independent36 freeze, pre-this-self first execution; first tools7 review found copied format_calls stale. Revised only current-derived format/branch counts and connected pins; prior binding preserved. All repository imports and QA executions remain ROOT-owned.",
    "actual_gs_sha256": "5076adf75b13920ae97ff9174945acf9c43fc80dec73cb356da44f314b7741d8",
    "first_binding": "order267-tools7-first-binding.json",
    "self_full_raw_sha256": "EXTERNAL approval; deliberately outside recursive code-view binding"
  },
  "repair_plan_sha256": "40fa274bc28a7280534703e64540ac4cb0436e8e3df78d65c570b8fb3eae1218",
  "repair_plan_canonical_sha256": "0c08051eef4cfe6204c002c25696835c1ab6e998128609ba62f3e6db69cc2afc",
  "repair_provenance": {
    "phase": "APPLIED_SOURCE_BOUND",
    "root_execution_approval": "2026-09-20 ROOT: independent repair3 static PASS ff8732f36546ca768fb2e8254f94def87d1fa4f552d322f22a1216bc6bfd4570; binding-only approval, original failures preserved. Declared affected8 and current-source preservation must execute; no actual PASS or final GO inferred.",
    "declaration": "7e55a1bbfd72cf92b9c6bb7cf5c18227c397b864",
    "first_named_sha256": "21d1d7ff7ec5926883877019d8deee120d34a5a231790c68ff3f973040c111f3",
    "meaning": "First36 passed but missed synthetic housing10; first meta/pipeline/JA UI failed. Repair12 frozen before this change. Source36 semantics preserved, current collector oracle strengthened to complete GS. Existing fullself methods/pins untouched; scoped raw inverse of approved264/266 additions only. ROOT owns execution after independent repair review."
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
REPAIR = json.loads(r'''{
  "schema_version": 1,
  "unit_id": "ORDER-267",
  "reviewer": "Poincare",
  "phase": "FROZEN_BEFORE_REPAIR_IMPLEMENTATION",
  "scope": "Two independently identified first-named defects: lost existing synthesized housing calls and approved264/266 methods missing from the historical fullself view. Supplement12 is separate from unchanged original source36.",
  "first_evidence": {
    "path": ".git/full-game-localization/order267-named-first.json",
    "sha256": "21d1d7ff7ec5926883877019d8deee120d34a5a231790c68ff3f973040c111f3",
    "result": "15 PASS / meta historical entry, JA pipeline self and JA UI audit FAIL. Original source36 PASS did not cover lost synthesized calls."
  },
  "housing_contract": {
    "path": "autoloads/GameState.gd",
    "current_sha256": "5076adf75b13920ae97ff9174945acf9c43fc80dec73cb356da44f314b7741d8",
    "previous_sha256": "8a40740286ff910b2a16049e2c2794cc0dc22fed5dfc78d2fc6ce458c833018d",
    "existing_provider": "collect_dynamic_housing_ui_calls(contract, game_state_source)",
    "registry_sha256": "df45ab1e2954d29eed5b44f086fffa23c4162d2787245fc6bdc4bb5313ff005d",
    "api": "legacy",
    "context_id": "",
    "owners": {
      "get_housing_name": {
        "english_field": "narrative_en",
        "current_line": 1531,
        "previous_line": 1520
      },
      "get_housing_display_name": {
        "english_field": "display_en",
        "current_line": 1551,
        "previous_line": 1540
      }
    },
    "rows": [
      {
        "id": "gosiwon",
        "ko": "고시원",
        "narrative_en": "goshiwon",
        "display_en": "Goshiwon Room"
      },
      {
        "id": "oneroom",
        "ko": "원룸",
        "narrative_en": "one-room studio",
        "display_en": "One-room Studio"
      },
      {
        "id": "villa",
        "ko": "빌라 전세",
        "narrative_en": "villa jeonse",
        "display_en": "Villa Jeonse"
      },
      {
        "id": "apartment",
        "ko": "아파트 전세",
        "narrative_en": "apartment jeonse",
        "display_en": "Apartment Jeonse"
      },
      {
        "id": "gangnam",
        "ko": "강남 아파트",
        "narrative_en": "Gangnam apartment",
        "display_en": "Gangnam Apartment"
      }
    ],
    "normal_oracle": [
      "Use the unchanged validated dynamic provider with explicit current GS text, and separately with exact inverse previous GS text. Combine each with generic literal parse results exactly once. Full current GS152=generic142+housing10; previous GS143=generic133+housing10.",
      "Derive the expected10 from the frozen rows/owner/API/context above independently of the implementation's assembled list. Check all seven UiCall fields, including current and historical physical line positions separately. Both data maps remain source-bound by the existing provider.",
      "Current actual collector must contain this complete GS multiset once. Predecessor output must equal the complete previous GS multiset and restore previous physical line positions; all non-GS supplied records retain identity. Input permutation/line annotations are not semantic authority; returned physical locations are reparsed from the appropriate approved raw source.",
      "Compare complete current and saved pre267 collector populations, source-key sets, keyset hashes and API partitions. Fixed arithmetic: previous source3456/legacy3422/legacyAPI3366/format50/branch6/context34; current source3465/legacy3431/legacyAPI3373/format52/branch6/context34. Current semantic source keys equal previous keys union nine new literal keys, 2948 versus previous2944. No copied dynamic_stats5/10 may stand in for actual10 occurrence observations.",
      "The failed first collector observed3455/3421/3363 and2945 keys. These failed-subject observations stay preserved, not relabelled corrected. Any downstream collected-leaf/manifest counts must be freshly observed after repair; expected prior17484 is not a success oracle for the repaired collector."
    ]
  },
  "housing_cases": [
    {
      "id": "housing_complete_normal",
      "kind": "normal",
      "recipe": "Execute the complete current+previous normal_oracle, independent10 literal reconstruction and actual collector comparison.",
      "expected": "PASS all source, selector, physical provenance, multiset, partition and keyset assertions; no repository file mutations."
    },
    {
      "id": "housing_reordered_line_normal",
      "kind": "normal",
      "base": "housing_complete_normal",
      "recipe": "Reverse the complete current supplied call list and add31 to every supplied line only; shapes follow the existing permitted line-only contract.",
      "expected": "Accept unchanged selectors. Project complete previous calls with old physical lines1520/1540, not supplied lines or current1531/1551; preserve non-GS records."
    },
    {
      "id": "housing_drop_all10",
      "kind": "negative",
      "base": "housing_complete_normal",
      "recipe": "Remove exactly the frozen10 synthesized housing records from the complete current supplied calls; raw source, shapes, provider and all other calls stay unchanged.",
      "expected": "Nonempty predecessor semantic errors; identity returned supplied calls/current source; no successful historical projection. This directly reproduces the original defect."
    },
    {
      "id": "housing_drop_one",
      "kind": "negative",
      "base": "housing_complete_normal",
      "recipe": "Remove exactly1 current record pathGS/function get_housing_name/api legacy/KO 강남 아파트/EN Gangnam apartment/context empty.",
      "expected": "Same rejection/identity contract; source raw gate itself remains valid."
    },
    {
      "id": "housing_duplicate_one",
      "kind": "negative",
      "base": "housing_complete_normal",
      "recipe": "Append an exact duplicate of the same unique narrative 강남 아파트 record.",
      "expected": "Same rejection/identity contract; multiplicity must not be set-collapsed."
    },
    {
      "id": "housing_wrong_owner",
      "kind": "negative",
      "base": "housing_complete_normal",
      "recipe": "On that unique narrative 강남 아파트 record replace function with get_housing_display_name only; all other fields unchanged.",
      "expected": "Same rejection/identity contract; both owner-specific English fallbacks remain bound."
    },
    {
      "id": "housing_wrong_english",
      "kind": "negative",
      "base": "housing_complete_normal",
      "recipe": "On that unique narrative 강남 아파트 record replace EN Gangnam apartment with Gangnam Apartment only.",
      "expected": "Same rejection/identity contract; capitalization difference is meaningful source provenance, not a translation rewrite."
    }
  ],
  "fullself_inverse_contract": {
    "path": "tools/full_game_localization_self_test.py",
    "current": {
      "bytes": 1715268,
      "sha256": "332446ba4b1120e265f96430773c0c3e15f35b6075b43335c82c518589619fb9"
    },
    "previous": {
      "bytes": 1689986,
      "sha256": "7c6619c4991cb773f3b1958b21e7ec340e596caa0744b0d659fc1c25f022ca8d"
    },
    "spans": [
      {
        "method": "test_order266_ui_story_relationship_name_scope",
        "start_line": 17,
        "next_method_line": 209,
        "bytes_including_blank_separator": 11450,
        "sha256": "c024a6d0890d796cb4927643e59c7272e3addede3e81fe191bbaaf8538fff60c"
      },
      {
        "method": "test_order264_ui_story_coffee_ordinal_scope",
        "start_line": 209,
        "next_method_line": 435,
        "bytes_including_blank_separator": 13832,
        "sha256": "1a0ccaaf1e575adc96141b8832faa13b9b1a891fcc5ca79dc3f868d3416297d5"
      }
    ],
    "following_method": "test_order251_ui_dice_title_frozen",
    "boundary": "Only scoped historical read view removes these two approved raw spans after exact current/span checks and verifies whole previous bytes. Existing MG9 pins and old methods do not change; actual current fullself264 execution retains both methods. No permanent global monkeypatch or file edit."
  },
  "fullself_cases": [
    {
      "id": "fullself_inverse_normal",
      "kind": "normal",
      "recipe": "Prepare exact current fullself above; remove both exact spans including their following blank separator only; validate whole previous digest. Observe byte and text reads inside the existing scoped historical view and actual current bytes outside.",
      "expected": "Exact previous1689986/7c6619 inside; current1715268/332446 outside. Current source normal prerequisites remain mandatory before the old meta entry."
    },
    {
      "id": "fullself_order264_changed",
      "kind": "negative",
      "base": "fullself_inverse_normal",
      "recipe": "In-memory raw only, replace the unique method identifier test_order264_ui_story_coffee_ordinal_scope with that identifier plus _forged.",
      "expected": "Reject before old entry; do not return an approved previous view or count a historical suite PASS. Provider restored."
    },
    {
      "id": "fullself_order266_changed",
      "kind": "negative",
      "base": "fullself_inverse_normal",
      "recipe": "In-memory raw only, replace the unique method identifier test_order266_ui_story_relationship_name_scope with that identifier plus _forged.",
      "expected": "Reject before old entry with the same restoration boundary."
    },
    {
      "id": "fullself_unrelated_byte",
      "kind": "negative",
      "base": "fullself_inverse_normal",
      "recipe": "Append exactly one LF to current whole raw outside both approved spans.",
      "expected": "Whole-current/inverse mismatch rejects before old entry; two correct spans do not authorize unrelated drift."
    },
    {
      "id": "fullself_view_exception_restore",
      "kind": "restoration",
      "base": "fullself_inverse_normal",
      "recipe": "Inside a valid scoped historical view, confirm previous byte/text reads then raise a deliberate private exception before invoking an old suite. Catch outside and compare all patched read providers/function bindings and actual fullself file bytes.",
      "expected": "Exception visibly captured, original providers/callables and physical current file exact; no old-suite call for this probe."
    }
  ],
  "execution_accounting": "Supplement12 = housing7 (2normal/5negative) + fullself5 (1normal/3negative/1restoration). Effectiveness only after the relevant normal succeeds. Capture every actual input/result/error/restoration before final assertions. No source36 IDs removed or semantic requirements relaxed; adapt its generic GS oracle to the complete existing canonical inventory as the defect correction, without calling the supplement original36.",
  "affected_verification": [
    "One repaired newsource self pass covers unchanged36 plus separately reported12 and existing delegation4; it must independently validate complete collector populations.",
    "Run the three failed consumers (meta historical, JA pipeline self, JA UI audit) on the repaired clean subject. Their original failures remain recorded.",
    "Because the shared collector actually changes, refresh preservation/current source-manifest and new27 L1 once; retained official27 source/response/receipt digests may be reused only after exact selected-leaf/current-target verification. Do not rewrite historical receipt headers as new exports.",
    "ZH self/skeleton directly consumes current collector; run that affected consumer once. CI and gift historical adapters share the changed raw/helper view; rerun these two small affected historical entries once, rather than the entire passed15 by inertia.",
    "Keep runtime104/34input component unchanged and reuse after exact input rebinding; no new engine run. Other passed checks may be reused with exact inputs or explicit narrowly explained dependency deltas. A final selector/ownership verification may be needed if dependency rows change, not a reason to run every selected check."
  ],
  "limits": "Read-only source/AST/raw arithmetic only. No repair implementation, modules, collector, test or engine execution by this reviewer. This is a finite precode expectation supplement, not actual PASS or final work-unit GO."
}''')
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
    paths = set(BINDING["code"]) | set(UI) | {GS, SELF, FULLSELF, "scenes/MainGame.gd",
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


def fullself_previous(raw):
    """Exact approved264/266 additions only; original MG9 pin stays untouched."""
    spec = REPAIR["fullself_inverse_contract"]
    if {"bytes": len(raw), "sha256": sha(raw)} != spec["current"]:
        raise AssertionError("fullself physical current differs")
    spans = []
    for index, row in enumerate(spec["spans"]):
        following = spec["spans"][index + 1]["method"] if index + 1 < len(spec["spans"]) else spec["following_method"]
        start = ("    def " + row["method"] + "(self):\n").encode()
        end = ("    def " + following + "(self):\n").encode()
        if raw.count(start) != 1 or raw.count(end) != 1:
            raise AssertionError("fullself exact method boundaries differ")
        a, z = raw.index(start), raw.index(end)
        if a >= z or len(raw[a:z]) != row["bytes_including_blank_separator"] or sha(raw[a:z]) != row["sha256"]:
            raise AssertionError("fullself approved method span differs")
        spans.append((a, z))
    previous = raw
    for a, z in sorted(spans, reverse=True):
        previous = previous[:a] + previous[z:]
    if {"bytes": len(previous), "sha256": sha(previous)} != spec["previous"]:
        raise AssertionError("fullself whole historical inverse differs")
    return previous


def prepare():
    if BINDING["phase"] != "APPLIED_SOURCE_BOUND":
        raise AssertionError("ORDER267 candidate is not authorized for execution")
    if sha(code_view((ROOT / SELF).read_bytes())) != BINDING["self_code_view_sha256"]:
        raise AssertionError("self code view changed; full raw pin is external")
    if len(FROZEN) != 36 or canonical(FROZEN) != BINDING["source_cases_sha256"]:
        raise AssertionError("independent36 changed")
    if canonical(REPAIR) != BINDING["repair_plan_canonical_sha256"]:
        raise AssertionError("independent repair12 changed")
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
    current[FULLSELF] = (ROOT / FULLSELF).read_bytes()
    previous[FULLSELF] = fullself_previous(current[FULLSELF])
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


def physical_calls(calls):
    return Counter((c.path, c.function, c.line, c.api, c.korean, c.english, c.context_id) for c in calls)


def frozen_housing(line_field):
    spec = REPAIR["housing_contract"]
    return [pipeline.UiCall(GS, owner, row_owner[line_field], spec["api"], row["ko"],
                row[row_owner["english_field"]], spec["context_id"])
            for row in spec["rows"] for owner, row_owner in spec["owners"].items()]


def current_normal(current, previous):
    values = {"gs": api_values(GS, current[GS]), "pipeline": api_values(JA, current[JA]),
        "registered_errors": history.new_run_log_source_errors(GS, current[GS], sha(previous[GS]))}
    calls, parse_errors = pipeline.parse_ui_calls(GS, current[GS].decode())
    shapes, shape_errors = pipeline._new_run_log_argument_shapes(current[GS].decode())
    old_calls, old_parse = pipeline.parse_ui_calls(GS, previous[GS].decode())
    projected, old_source, semantic_errors = pipeline._new_run_log_predecessor_calls(calls, current[GS].decode(), shapes)
    contract = pipeline.read_ui_context_contract()
    dynamic, dynamic_errors, dynamic_stats = pipeline.collect_dynamic_housing_ui_calls(contract, current[GS].decode())
    complete = [*calls, *dynamic]
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
        "physical_gs_calls_exact": physical_calls(actual_gs) == physical_calls(complete),
        "literal_probe_calls": len(calls), "complete_inventory_calls": len(complete),
        "housing_provider_errors": dynamic_errors, "housing_provider_stats": dynamic_stats,
        "housing_frozen10_exact": physical_calls(dynamic) == physical_calls(frozen_housing("current_line")),
        "gs_call_delta": len(calls) - len(old_calls),
        "gs_format_delta": sum(c.api == "format" for c in calls) - sum(c.api == "format" for c in old_calls),
        "current_gs_calls": complete, "literal_gs_calls": calls, "argument_shapes": shapes}
    values["live"] = live_values(current[GS])
    gs, ja, semantic, collector = values["gs"], values["pipeline"], values["semantic"], values["collector"]
    passed = (not gs["new_errors"] and not gs["public_errors"] and gs["new_bytes"] == gs["public_bytes"] == previous[GS]
        and gs["new_hash"] == gs["public_hash"] == sha(previous[GS]) and not ja["new_errors"]
        and ja["new_bytes"] == previous[JA] and ja["new_hash"] == sha(previous[JA]) and not values["registered_errors"]
        and not semantic["errors"] and not semantic["parse_errors"] and semantic["previous_source_exact"] and semantic["previous_calls_exact"]
        and not collector["errors"] and collector["physical_gs_calls_exact"] and collector["current_api_counts_exact"] and collector["current_api_partition_exact"]
        and not dynamic_errors and collector["housing_frozen10_exact"]
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


def housing_repair_case(case, current, previous, base):
    cid = case["id"]
    if cid == "housing_complete_normal":
        contract = pipeline.read_ui_context_contract()
        if canonical(contract["dynamic_housing_registry"]) != REPAIR["housing_contract"]["registry_sha256"]:
            raise AssertionError("housing registry differs from independent frozen rows")
        provider = {}
        for name, raw, line in (("current", current[GS], "current_line"), ("previous", previous[GS], "previous_line")):
            literal, parse_errors = pipeline.parse_ui_calls(GS, raw.decode())
            dynamic, errors, stats = pipeline.collect_dynamic_housing_ui_calls(contract, raw.decode())
            provider[name] = {"literal": literal, "dynamic": dynamic, "complete": [*literal, *dynamic],
                "errors": [*parse_errors, *errors], "stats": stats,
                "independent10_exact": physical_calls(dynamic) == physical_calls(frozen_housing(line))}
        actual = pipeline.collect_ui_inventory(contract)
        with pipeline._new_run_log_previous_reads({GS: current[GS], JA: current[JA]}):
            saved = pipeline._NEW_RUN_OLD_COLLECT(contract)
        shapes, shape_errors = pipeline._new_run_log_argument_shapes(current[GS].decode())
        base = {"contract": contract, "provider": provider, "actual": actual, "saved": saved,
                "shapes": shapes, "shape_errors": shape_errors}
    if base is None:
        raise AssertionError("complete housing normal input unavailable")
    supplied = list(base["actual"].calls)
    shapes = base["shapes"]
    target = (GS, "get_housing_name", "legacy", "강남 아파트", "Gangnam apartment", "")
    matches = [i for i, call in enumerate(supplied) if selector(call) == target]
    if len(matches) != 1:
        raise AssertionError("housing narrative target is not exact1")
    i = matches[0]
    if cid == "housing_reordered_line_normal":
        supplied = [replace(c, line=c.line + 31) for c in reversed(supplied)]
        shapes = [replace(s, line=s.line + 31) for s in reversed(shapes)]
    elif cid == "housing_drop_all10":
        wanted = Counter(map(selector, frozen_housing("current_line")))
        kept = []
        for call in supplied:
            key = selector(call)
            if wanted[key]:
                wanted[key] -= 1
            else:
                kept.append(call)
        if any(wanted.values()) or len(supplied) - len(kept) != 10:
            raise AssertionError("drop-all10 recipe did not remove the exact10")
        supplied = kept
    elif cid == "housing_drop_one":
        supplied.pop(i)
    elif cid == "housing_duplicate_one":
        supplied.append(supplied[i])
    elif cid == "housing_wrong_owner":
        supplied[i] = replace(supplied[i], function="get_housing_display_name")
    elif cid == "housing_wrong_english":
        supplied[i] = replace(supplied[i], english="Gangnam Apartment")
    raw_errors = history.new_run_log_source_errors(GS, current[GS]) + history.new_run_log_source_errors(JA, current[JA])
    output, source, errors = pipeline._new_run_log_predecessor_calls(supplied, current[GS].decode(), shapes,
        call_mode="complete", contract=base["contract"])
    observation = {"call_mode": "complete", "raw_errors": raw_errors, "errors": errors,
        "supplied_GS": [c for c in supplied if c.path == GS], "returned_GS": [c for c in output if c.path == GS],
        "returned_source": source.encode(), "non_GS_identity": tuple(c for c in output if c.path != GS)
            == tuple(c for c in supplied if c.path != GS)}
    if case["kind"] == "negative":
        passed = not raw_errors and bool(errors) and tuple(output) == tuple(supplied) and source.encode() == current[GS]
        return passed, observation, base
    provider, actual, saved = base["provider"], base["actual"], base["saved"]
    expected_current = [c for c in saved.calls if c.path != GS] + provider["current"]["complete"]
    previous_GS = [c for c in output if c.path == GS]
    fields = ("source_calls", "legacy_calls", "legacy_api_calls", "format_calls", "branch_variant_calls", "context_calls")
    previous_counts = dict(zip(fields, (3456, 3422, 3366, 50, 6, 34)))
    current_counts = dict(zip(fields, (3465, 3431, 3373, 52, 6, 34)))
    current_keys, saved_keys = {c.korean for c in actual.calls}, {c.korean for c in saved.calls}
    added = {"백수", "알바", "투자", "직장", "인간관계", "건강", "연애", "도박", "재정"}
    checks = {
        "source_and_provider_valid": not raw_errors and not base["shape_errors"] and all(not p["errors"] for p in provider.values()),
        "independent_current_old10": all(p["independent10_exact"] and len(p["dynamic"]) == 10 for p in provider.values()),
        "GS_populations": len(provider["current"]["literal"]) == 142 and len(provider["previous"]["literal"]) == 133
            and len(provider["current"]["complete"]) == 152 and len(provider["previous"]["complete"]) == 143,
        "current_collector_exact": not actual.errors and physical_calls(actual.calls) == physical_calls(expected_current),
        "saved_collector_exact": not saved.errors and physical_calls(c for c in saved.calls if c.path == GS)
            == physical_calls(provider["previous"]["complete"]),
        "old_projection_exact": not errors and source.encode() == previous[GS]
            and physical_calls(previous_GS) == physical_calls(provider["previous"]["complete"]),
        "non_GS_identity": observation["non_GS_identity"],
        "current_counts": all(actual.stats.get(k) == v for k, v in current_counts.items()),
        "previous_counts": all(saved.stats.get(k) == v for k, v in previous_counts.items()),
        "key_union": current_keys == saved_keys | added and len(current_keys) == 2948 and len(saved_keys) == 2944,
        "key_hashes": all(inv.stats.get("parameter_legacy_korean_source_keys_sha256")
            == sha("\n".join(sorted(keys)).encode()) for inv, keys in ((actual, current_keys), (saved, saved_keys))),
    }
    observation.update(checks=checks, provider=provider, current_stats=actual.stats, saved_stats=saved.stats,
        current_keys=sorted(current_keys), saved_keys=sorted(saved_keys))
    return all(checks.values()), observation, base


def fullself_repair_case(case, current, previous):
    cid, raw = case["id"], current[FULLSELF]
    observed, returned, caught = {}, None, None
    if case["kind"] == "negative":
        if cid == "fullself_unrelated_byte":
            raw += b"\n"
        else:
            method = ("test_order264_ui_story_coffee_ordinal_scope" if cid == "fullself_order264_changed"
                      else "test_order266_ui_story_relationship_name_scope")
            raw = once(raw, method, method + "_forged")
        with path_view({FULLSELF: raw}, observed):
            try:
                returned = fullself_previous((ROOT / FULLSELF).read_bytes())
            except AssertionError as exc:
                caught = str(exc)
        passed = caught is not None and returned is None and observed.get("path_restored") is True
    else:
        returned = fullself_previous(raw)
        with_text = None
        try:
            with historical_view(previous, observed):
                inside = (ROOT / FULLSELF).read_bytes()
                with_text = (ROOT / FULLSELF).read_text(encoding="utf-8")
                observed["inside_bytes_exact"] = inside == returned == previous[FULLSELF]
                observed["inside_text_exact"] = with_text == returned.decode()
                if cid == "fullself_view_exception_restore":
                    raise RuntimeError("ORDER267 fullself history deliberate exception")
        except RuntimeError as exc:
            caught = str(exc)
        passed = (all(observed.get(k) is True for k in ("inside_bytes_exact", "inside_text_exact", "path_restored",
            "callables_restored", "imported_aliases_restored")) and (caught == "ORDER267 fullself history deliberate exception"
                if cid == "fullself_view_exception_restore" else caught is None))
    outside = (ROOT / FULLSELF).read_bytes()
    return passed and outside == current[FULLSELF], {"input": raw, "returned": returned, "caught": caught,
        "restoration": observed, "physical_current_exact": outside == current[FULLSELF], "old_suite_calls": 0}


def repair_supplement(current, previous):
    rows, housing = [], None
    references = {"current:" + p: raw for p, raw in current.items()} | {"previous:" + p: raw for p, raw in previous.items()}
    for case in [*REPAIR["housing_cases"], *REPAIR["fullself_cases"]]:
        before, out, err, fatal, passed, values = identity(), io.StringIO(), io.StringIO(), None, False, {}
        try:
            with contextlib.redirect_stdout(out), contextlib.redirect_stderr(err):
                if case["id"].startswith("housing_"):
                    passed, values, housing = housing_repair_case(case, current, previous, housing)
                else:
                    passed, values = fullself_repair_case(case, current, previous)
        except Exception as exc:
            fatal = {"error": type(exc).__name__ + ": " + str(exc), "traceback": traceback.format_exc()}
        restored = identity() == before
        rows.append({"id": case["id"], "kind": case["kind"], "passed": bool(passed and restored and fatal is None and not err.getvalue()),
            "values": json_value(values, references), "stdout": out.getvalue(), "stderr": err.getvalue(),
            "exception": fatal, "callables_restored": restored})
    bases = {row["id"]: row["passed"] for row in rows}
    for row in rows:
        row["normal_base_passed"] = bases["housing_complete_normal" if row["id"].startswith("housing_") else "fullself_inverse_normal"]
        row["effective_negative"] = row["normal_base_passed"] and row["passed"] and row["kind"] == "negative"
    return rows


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
    before, after, fatal, after_error, results, supplement, repair = None, None, None, None, [], [], []
    try:
        before = pins()
        current, previous = prepare()
        for case in FROZEN:
            results.append(capture_case(case, current, previous))
        repair = repair_supplement(current, previous)
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
        and len(repair) == 12 and all(r["passed"] and r["normal_base_passed"] for r in repair)
        and all(r["passed"] for r in supplement) and fatal is None and after_error is None and before is not None and before == after)
    print(json.dumps({"scope": "ORDER267 original36 plus separate repair12/delegation4; historical suites separate", "passed": passed,
        "precode_sha256": BINDING["source_case_plan_sha256"], "results": results, "delegation_supplement": supplement,
        "repair_plan_sha256": BINDING["repair_plan_sha256"], "repair_supplement": repair,
        "fatal": fatal, "after_error": after_error, "physical_before": before, "physical_after": after, "unchanged": before is not None and before == after,
        "execution_counts": {"source_cases": len(results), "normal": sum(r["passed"] for r in results if r["kind"] == "normal"),
            "effective_negative": sum(r["effective_negative"] for r in results), "claim": 1 if len(results) == 36 else 0,
            "OFF": 1 if len(results) == 36 else 0, "repair_supplement": len(repair),
            "repair_normal": sum(r["passed"] for r in repair if r["kind"] == "normal"),
            "repair_effective_negative": sum(r["effective_negative"] for r in repair),
            "repair_restoration": sum(r["passed"] for r in repair if r["kind"] == "restoration"),
            "delegation_supplement": len(supplement), "historical_suites": 0, "engine": 0}},
        ensure_ascii=False, indent=2))
    print("NEW_RUN_LOG_SOURCE_SELF_TEST_" + ("OK" if passed else "FAIL") + f" cases={len(results)} unchanged={before == after}")
    return 0 if passed else 1


# BEGIN_FIRST_START_NOTICE_ENTRY_274
_NOTICE_SAVED_MAIN = main
_NOTICE_SAVED_HISTORICAL_ENTRY = historical_entry


def main():
    from first_start_notice_self_test import previous_entry
    return previous_entry(_NOTICE_SAVED_MAIN, "source")


def historical_entry(function, kind):
    from first_start_notice_self_test import previous_entry
    return previous_entry(lambda: _NOTICE_SAVED_HISTORICAL_ENTRY(function, kind), kind)
# END_FIRST_START_NOTICE_ENTRY_274

if __name__ == "__main__":
    raise SystemExit(main())
