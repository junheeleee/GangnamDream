#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Finite CI reconciliation regressions; not a full localization or release audit.

The new 28 controls are separate from the immutable older ORDER-220 26-case
expectations in each consumer. MainGame mutations are in memory; event overlays
are only replaced through the production helper's scoped loader injection.
"""
from __future__ import annotations

import contextlib
import copy
import hashlib
import io
import json
from pathlib import Path
from unittest.mock import patch

import demo_localization_scope as demo
import ja_translation_audit as ja
import ja_translation_pipeline as pipeline
import main_game_locale_history as history
import story_demo_localization_audit as story_demo
import year5_reference_route_audit as year5
import chapter1_core_loop_v2_causal_ledger_check as chapter1

ROOT = Path(__file__).resolve().parents[1]
MAIN_PATH = "scenes/MainGame.gd"
CURRENT_SHA = "9029fb680033141ce382fa114fafe9e814197e996f7a98fcf622f9bce4b1118d"
ORDER220_SHA = "5b891505892d3306197cb20b70e4e0d8074941aeb7ec40030857bd32bb912f88"
# Frozen source-derived expectations, not fitted to a post-code result.
FROZEN = json.loads(r'''
{
  "schema_version": 1,
  "unit": "ORDER-243",
  "patches": [
    {
      "patch_id": 1,
      "order": "ORDER239",
      "before": "\t\tvar name_lbl: Label = _label(str(rel.get(\"name\", \"?\")), 16, \"#e8eaf0\")\n",
      "after": "\t\tvar name_lbl: Label = _label(relationship_system.get_display_name(str(rel.get(\"name\", \"?\"))), 16, \"#e8eaf0\")\n"
    },
    {
      "patch_id": 2,
      "order": "ORDER239",
      "before": "\t\trel_names.append(str(rel.get(\"name\", \"?\")))\n",
      "after": "\t\trel_names.append(relationship_system.get_display_name(str(rel.get(\"name\", \"?\"))))\n"
    },
    {
      "patch_id": 3,
      "order": "ORDER240",
      "before": "\t\trelationship_box.add_child(_info_empty_card(_tr(\"아직 중요한 인연이 없습니다. 관계 행동이나 스토리 진행으로 인물이 기록됩니다.\", \"No important relationships yet. People appear here through relationship actions or story progress.\"), \"#64748b\"))\n",
      "after": "\t\trelationship_box.add_child(_info_empty_card(_tr(\"아직 기록된 인연이 없습니다. 이야기를 진행하며 맺은 인연이 여기에 표시됩니다.\", \"No connections recorded yet. Connections formed through the story appear here.\"), \"#64748b\"))\n"
    },
    {
      "patch_id": 4,
      "order": "ORDER240",
      "before": "\t\t\"romantic\": _tr(\"연인\", \"Partner\"),\n",
      "after": "\t\t\"romantic\": _tr(\"연애 관련\", \"Romance\"),\n"
    }
  ],
  "history_cases": [
    {
      "id": "history_current_9029",
      "kind": "normal",
      "base_id": null,
      "recipe": {
        "op": "none"
      },
      "input_sha256": "9029fb680033141ce382fa114fafe9e814197e996f7a98fcf622f9bce4b1118d",
      "expected_errors_empty": true,
      "expected_project_to_order220": true,
      "expected_raw_unchanged_on_reject": false
    },
    {
      "id": "history_rollback_line_1",
      "kind": "negative",
      "base_id": "history_current_9029",
      "recipe": {
        "op": "replace_once",
        "from": "\t\tvar name_lbl: Label = _label(relationship_system.get_display_name(str(rel.get(\"name\", \"?\"))), 16, \"#e8eaf0\")\n",
        "to": "\t\tvar name_lbl: Label = _label(str(rel.get(\"name\", \"?\")), 16, \"#e8eaf0\")\n"
      },
      "input_sha256": "efd5d96139b8bd41a2da681f5b88a16b496ee9c2792865cde2e84fe0fd172602",
      "expected_errors_empty": false,
      "expected_project_to_order220": false,
      "expected_raw_unchanged_on_reject": true
    },
    {
      "id": "history_rollback_line_2",
      "kind": "negative",
      "base_id": "history_current_9029",
      "recipe": {
        "op": "replace_once",
        "from": "\t\trel_names.append(relationship_system.get_display_name(str(rel.get(\"name\", \"?\"))))\n",
        "to": "\t\trel_names.append(str(rel.get(\"name\", \"?\")))\n"
      },
      "input_sha256": "9ab24ee9026cac76e822c231364bbb760b42330863448dea6db18bfc5292e7f0",
      "expected_errors_empty": false,
      "expected_project_to_order220": false,
      "expected_raw_unchanged_on_reject": true
    },
    {
      "id": "history_rollback_line_3",
      "kind": "negative",
      "base_id": "history_current_9029",
      "recipe": {
        "op": "replace_once",
        "from": "\t\trelationship_box.add_child(_info_empty_card(_tr(\"아직 기록된 인연이 없습니다. 이야기를 진행하며 맺은 인연이 여기에 표시됩니다.\", \"No connections recorded yet. Connections formed through the story appear here.\"), \"#64748b\"))\n",
        "to": "\t\trelationship_box.add_child(_info_empty_card(_tr(\"아직 중요한 인연이 없습니다. 관계 행동이나 스토리 진행으로 인물이 기록됩니다.\", \"No important relationships yet. People appear here through relationship actions or story progress.\"), \"#64748b\"))\n"
      },
      "input_sha256": "c2b0653e012ab3243e47703a37e9236f91450086013a58290699074e1ef054b6",
      "expected_errors_empty": false,
      "expected_project_to_order220": false,
      "expected_raw_unchanged_on_reject": true
    },
    {
      "id": "history_rollback_line_4",
      "kind": "negative",
      "base_id": "history_current_9029",
      "recipe": {
        "op": "replace_once",
        "from": "\t\t\"romantic\": _tr(\"연애 관련\", \"Romance\"),\n",
        "to": "\t\t\"romantic\": _tr(\"연인\", \"Partner\"),\n"
      },
      "input_sha256": "4d99614edbf8602c02bc10bc3b453fe2e7e872ef0309dc6ab2621bfb9474ec93",
      "expected_errors_empty": false,
      "expected_project_to_order220": false,
      "expected_raw_unchanged_on_reject": true
    },
    {
      "id": "history_whole_239_rollback",
      "kind": "negative",
      "base_id": "history_current_9029",
      "recipe": {
        "op": "git_blob",
        "commit": "978a9ed670105b023059a38e4377d1e1c73ba208",
        "path": "scenes/MainGame.gd"
      },
      "input_sha256": "014bdae5a87cb3a873f61c5f83d8337f6d686068366641eb92c94e515bebad86",
      "expected_errors_empty": false,
      "expected_project_to_order220": false,
      "expected_raw_unchanged_on_reject": true
    },
    {
      "id": "history_whole_220_rollback",
      "kind": "negative",
      "base_id": "history_current_9029",
      "recipe": {
        "op": "git_blob",
        "commit": "10dec57c46c457eb9d189064314a3d876706c303",
        "path": "scenes/MainGame.gd"
      },
      "input_sha256": "5b891505892d3306197cb20b70e4e0d8074941aeb7ec40030857bd32bb912f88",
      "expected_errors_empty": false,
      "expected_project_to_order220": false,
      "expected_raw_unchanged_on_reject": true
    },
    {
      "id": "history_extra_lf",
      "kind": "negative",
      "base_id": "history_current_9029",
      "recipe": {
        "op": "append",
        "text": "\n"
      },
      "input_sha256": "e99410e11ea1a51b7c0259fd01e08d1cd6c822ff44d89831e2a635887f1e423d",
      "expected_errors_empty": false,
      "expected_project_to_order220": false,
      "expected_raw_unchanged_on_reject": true
    },
    {
      "id": "history_nonlocalized_health_mutation",
      "kind": "negative",
      "base_id": "history_current_9029",
      "recipe": {
        "op": "replace_once",
        "from": "stat_name = _tr(\"건강\", \"Health\")",
        "to": "stat_name = _tr(\"건강\", \"Stamina\")"
      },
      "input_sha256": "8f956e0bdce9361b1845435d743982d74ecddc15839fbee49af0778a07c2761c",
      "expected_errors_empty": false,
      "expected_project_to_order220": false,
      "expected_raw_unchanged_on_reject": true
    },
    {
      "id": "history_wrong_path",
      "kind": "negative",
      "base_id": "history_current_9029",
      "recipe": {
        "op": "path",
        "path": "scenes/StoryMode.gd"
      },
      "input_sha256": "9029fb680033141ce382fa114fafe9e814197e996f7a98fcf622f9bce4b1118d",
      "expected_errors_empty": false,
      "expected_project_to_order220": false,
      "expected_raw_unchanged_on_reject": true
    },
    {
      "id": "history_case_path",
      "kind": "negative",
      "base_id": "history_current_9029",
      "recipe": {
        "op": "path",
        "path": "scenes/maingame.gd"
      },
      "input_sha256": "9029fb680033141ce382fa114fafe9e814197e996f7a98fcf622f9bce4b1118d",
      "expected_errors_empty": false,
      "expected_project_to_order220": false,
      "expected_raw_unchanged_on_reject": true
    },
    {
      "id": "history_forged_hash_claim",
      "kind": "negative",
      "base_id": "history_current_9029",
      "recipe": {
        "op": "append",
        "text": "\n"
      },
      "input_sha256": "e99410e11ea1a51b7c0259fd01e08d1cd6c822ff44d89831e2a635887f1e423d",
      "expected_errors_empty": false,
      "expected_project_to_order220": false,
      "expected_raw_unchanged_on_reject": true,
      "fault": {
        "kind": "forged_observation_hash",
        "claimed_sha256": "9029fb680033141ce382fa114fafe9e814197e996f7a98fcf622f9bce4b1118d"
      }
    },
    {
      "id": "history_wrong_intermediate",
      "kind": "negative",
      "base_id": "history_current_9029",
      "recipe": {
        "op": "none"
      },
      "input_sha256": "9029fb680033141ce382fa114fafe9e814197e996f7a98fcf622f9bce4b1118d",
      "expected_errors_empty": false,
      "expected_project_to_order220": false,
      "expected_raw_unchanged_on_reject": true,
      "fault": {
        "kind": "intermediate_pin",
        "value": "0000000000000000000000000000000000000000000000000000000000000000"
      }
    },
    {
      "id": "history_wrong_old_pin",
      "kind": "negative",
      "base_id": "history_current_9029",
      "recipe": {
        "op": "none"
      },
      "input_sha256": "9029fb680033141ce382fa114fafe9e814197e996f7a98fcf622f9bce4b1118d",
      "expected_errors_empty": false,
      "expected_project_to_order220": false,
      "expected_raw_unchanged_on_reject": true,
      "fault": {
        "kind": "old_pin",
        "value": "0000000000000000000000000000000000000000000000000000000000000000"
      }
    },
    {
      "id": "history_stage_order_swap",
      "kind": "negative",
      "base_id": "history_current_9029",
      "recipe": {
        "op": "none"
      },
      "input_sha256": "9029fb680033141ce382fa114fafe9e814197e996f7a98fcf622f9bce4b1118d",
      "expected_errors_empty": false,
      "expected_project_to_order220": false,
      "expected_raw_unchanged_on_reject": true,
      "fault": {
        "kind": "reverse_stages"
      }
    },
    {
      "id": "history_missing_inverse_240",
      "kind": "negative",
      "base_id": "history_current_9029",
      "recipe": {
        "op": "none"
      },
      "input_sha256": "9029fb680033141ce382fa114fafe9e814197e996f7a98fcf622f9bce4b1118d",
      "expected_errors_empty": false,
      "expected_project_to_order220": false,
      "expected_raw_unchanged_on_reject": true,
      "fault": {
        "kind": "remove_first_inverse",
        "stage": 240
      }
    },
    {
      "id": "history_missing_inverse_239",
      "kind": "negative",
      "base_id": "history_current_9029",
      "recipe": {
        "op": "none"
      },
      "input_sha256": "9029fb680033141ce382fa114fafe9e814197e996f7a98fcf622f9bce4b1118d",
      "expected_errors_empty": false,
      "expected_project_to_order220": false,
      "expected_raw_unchanged_on_reject": true,
      "fault": {
        "kind": "remove_first_inverse",
        "stage": 239
      }
    },
    {
      "id": "history_duplicate_inverse_240",
      "kind": "negative",
      "base_id": "history_current_9029",
      "recipe": {
        "op": "none"
      },
      "input_sha256": "9029fb680033141ce382fa114fafe9e814197e996f7a98fcf622f9bce4b1118d",
      "expected_errors_empty": false,
      "expected_project_to_order220": false,
      "expected_raw_unchanged_on_reject": true,
      "fault": {
        "kind": "duplicate_first_inverse",
        "stage": 240
      }
    },
    {
      "id": "history_duplicate_inverse_239",
      "kind": "negative",
      "base_id": "history_current_9029",
      "recipe": {
        "op": "none"
      },
      "input_sha256": "9029fb680033141ce382fa114fafe9e814197e996f7a98fcf622f9bce4b1118d",
      "expected_errors_empty": false,
      "expected_project_to_order220": false,
      "expected_raw_unchanged_on_reject": true,
      "fault": {
        "kind": "duplicate_first_inverse",
        "stage": 239
      }
    }
  ],
  "ja_inputs": {
    "old_ko": "아직 중요한 인연이 없습니다. 관계 행동이나 스토리 진행으로 인물이 기록됩니다.",
    "old_ja": "まだ重要な縁がありません。関係行動やストーリー進行で人物が記録されます。",
    "current_ko": "아직 기록된 인연이 없습니다. 이야기를 진행하며 맺은 인연이 여기에 표시됩니다.",
    "current_ja": "まだ記録された縁はありません。物語を進める中で結んだ縁が、ここに表示されます。"
  },
  "ja_calls": [
    {
      "path": "scenes/MainGame.gd",
      "function": "_relationship_type_label",
      "api": "legacy",
      "korean": "연애 관련",
      "english": "Romance",
      "context_id": ""
    },
    {
      "path": "scenes/MainGame.gd",
      "function": "_render_sidebars",
      "api": "legacy",
      "korean": "아직 기록된 인연이 없습니다. 이야기를 진행하며 맺은 인연이 여기에 표시됩니다.",
      "english": "No connections recorded yet. Connections formed through the story appear here.",
      "context_id": ""
    },
    {
      "path": "scenes/MainGame.gd",
      "function": "_maybe_add_date_card",
      "api": "legacy",
      "korean": "연인",
      "english": "partner",
      "context_id": ""
    }
  ],
  "ja_cases": [
    {
      "id": "ja_retired_actual",
      "kind": "normal",
      "base_id": null,
      "recipe": {
        "op": "none"
      },
      "expected_errors_empty": true,
      "expected_authorized_retired_keys": [
        "아직 중요한 인연이 없습니다. 관계 행동이나 스토리 진행으로 인물이 기록됩니다."
      ]
    },
    {
      "id": "ja_retired_legitimate_variation",
      "kind": "normal",
      "base_id": null,
      "recipe": {
        "op": "target",
        "key": "아직 중요한 인연이 없습니다. 관계 행동이나 스토리 진행으로 인물이 기록됩니다.",
        "value": "まだ大切な縁はありません。人間関係の行動や物語の進行を通じて、人物が記録されます。"
      },
      "expected_errors_empty": true,
      "note": "Valid Japanese variation is not rejected by a hardcoded historical-target canon."
    },
    {
      "id": "ja_unrelated_extra",
      "kind": "negative",
      "base_id": "ja_retired_actual",
      "recipe": {
        "op": "add",
        "key": "승인되지 않은 추가 키",
        "value": "承認されていない追加キー"
      },
      "expected_errors_empty": false,
      "expected_error_contains": "unknown extra keys"
    },
    {
      "id": "ja_retired_empty_target",
      "kind": "negative",
      "base_id": "ja_retired_actual",
      "recipe": {
        "op": "target",
        "key": "아직 중요한 인연이 없습니다. 관계 행동이나 스토리 진행으로 인물이 기록됩니다.",
        "value": ""
      },
      "expected_errors_empty": false
    },
    {
      "id": "ja_retired_english_target",
      "kind": "negative",
      "base_id": "ja_retired_actual",
      "recipe": {
        "op": "target",
        "key": "아직 중요한 인연이 없습니다. 관계 행동이나 스토리 진행으로 인물이 기록됩니다.",
        "value": "No important relationships yet. People appear here through relationship actions or story progress."
      },
      "expected_errors_empty": false
    },
    {
      "id": "ja_current_source_rollback",
      "kind": "negative",
      "base_id": "ja_retired_actual",
      "recipe": {
        "op": "rollback_current_empty_owner_to_old_pair"
      },
      "expected_errors_empty": false,
      "expected_authorized_retired_keys": []
    },
    {
      "id": "ja_missing_retired_key",
      "kind": "negative",
      "base_id": "ja_retired_actual",
      "recipe": {
        "op": "delete",
        "key": "아직 중요한 인연이 없습니다. 관계 행동이나 스토리 진행으로 인물이 기록됩니다."
      },
      "expected_errors_empty": false,
      "expected_error_contains": "missing retained source key"
    }
  ],
  "demo_cases": [
    {
      "id": "cn_real_populated_events",
      "kind": "normal",
      "base_id": null,
      "recipe": {
        "op": "language_coverage",
        "lang": "zh-CN",
        "strict": true,
        "runtime": "real build_scope current frozen source",
        "overlay": "real current files"
      },
      "expected_event_count": 72,
      "expected_event_string_count": 467,
      "expected_error_absent": "strict events coverage",
      "other_strict_errors": "Dynamic coverage may remain incomplete. This is not a strict whole-demo PASS."
    },
    {
      "id": "cn_actual_empty_overlay",
      "kind": "negative",
      "base_id": "cn_real_populated_events",
      "recipe": {
        "op": "empty_chinese_event_coverage_fixture",
        "lang": "zh-CN",
        "strict": true,
        "overlay_loader_result": [
          {},
          []
        ]
      },
      "expected_event_count": 0,
      "expected_event_string_count": 0,
      "expected_error_contains": "strict events coverage 0/72",
      "expected_loader_identity_restored": true,
      "expected_overlay_raw_unchanged": true
    }
  ],
  "total_new_cases": 28
}
''')


def digest(raw: bytes) -> str:
    return hashlib.sha256(raw).hexdigest()


def _pins() -> dict[str, str]:
    paths = {
        ROOT / name for name in (
            MAIN_PATH, "tools/main_game_locale_history.py",
            "tools/ci_localization_reconciliation_self_test.py",
            "tools/year5_reference_route_audit.py",
            "tools/chapter1_core_loop_v2_causal_ledger_check.py",
            "tools/ja_translation_pipeline.py", "tools/ja_translation_audit.py",
            "tools/demo_localization_scope.py", "tools/zh_translation_audit.py",
            "tools/release_content_inventory.py", "tools/i18n_coverage_check.py",
            "content/meta/demo_localization_scope.json",
            "content/meta/demo_core_loop_v2.json",
            "content/meta/release_content_inventory.json",
            "content/assets.json", "content/portraits.json",
            "locale/ui_ja.json", "locale/ui_zh-CN.json",
            "locale/catalog_zh-CN.json",
            "scenes/OpeningCinematic.gd", "scenes/TutorialOverlay.gd",
            "scenes/ArubaGame.gd", "scenes/JobHuntMiniGame.gd",
            "autoloads/ImageRegistry.gd", "autoloads/LocaleManager.gd",
        )
    }
    for directory in ("content/events", "content/events_zh-CN"):
        paths.update((ROOT / directory).glob("*.json"))
    # build_scope source declarations include additional exact read owners.
    manifest = json.loads((ROOT / "content/meta/demo_localization_scope.json").read_text(encoding="utf-8"))
    sources = manifest.get("source_files", [])
    if isinstance(sources, dict):
        sources = list(sources)
    for relative in sources:
        if isinstance(relative, str) and (ROOT / relative).is_file():
            paths.add(ROOT / relative)
    return {
        str(path.relative_to(ROOT)): digest(path.read_bytes())
        for path in sorted(paths) if path.is_file()
    }


def _replace_once(raw: bytes, before: str, after: str) -> bytes:
    left, right = before.encode("utf-8"), after.encode("utf-8")
    if raw.count(left) != 1:
        raise AssertionError("frozen mutation anchor is not unique")
    return raw.replace(left, right, 1)


def _history_input(case: dict, current: bytes) -> tuple[bytes, str]:
    recipe = case["recipe"]
    raw, relative = current, MAIN_PATH
    if recipe["op"] == "replace_once":
        raw = _replace_once(raw, recipe["from"], recipe["to"])
    elif recipe["op"] == "append":
        raw += recipe["text"].encode("utf-8")
    elif recipe["op"] == "path":
        relative = recipe["path"]
    elif recipe["op"] == "git_blob":
        # Reconstruct the fixed historical blob without a mutable Git checkout.
        stages = ("ORDER240",) if "239" in case["id"] else ("ORDER240", "ORDER239")
        for stage in stages:
            for item in FROZEN["patches"]:
                if item["order"] == stage:
                    raw = _replace_once(raw, item["after"], item["before"])
    elif recipe["op"] != "none":
        raise AssertionError("unknown frozen recipe")
    if digest(raw) != case["input_sha256"]:
        raise AssertionError("frozen materialized input hash differs")
    return raw, relative


def _fault_stages(fault: dict) -> tuple:
    stages = copy.deepcopy(history.HISTORY_STAGES)
    if fault["kind"] == "reverse_stages":
        return tuple(reversed(stages))
    rows = [list(row) for row in stages]
    if len(rows) != 2:
        raise AssertionError("production history seam must contain two stages")
    if fault["kind"] == "intermediate_pin":
        rows[0][2] = fault["value"]
    elif fault["kind"] == "old_pin":
        rows[1][2] = fault["value"]
    else:
        indexes = [i for i, row in enumerate(rows) if str(fault["stage"]) in row[0]]
        if len(indexes) != 1:
            raise AssertionError("stage selector not unique")
        index = indexes[0]
        inverses = tuple(rows[index][3])
        if fault["kind"] == "remove_first_inverse":
            inverses = inverses[1:]
        elif fault["kind"] == "duplicate_first_inverse":
            inverses = inverses + (inverses[0],)
        else:
            raise AssertionError("unknown fixed registry mutation")
        rows[index][3] = inverses
    return tuple(tuple(row) for row in rows)


def history_cases(current: bytes, results: list[dict]) -> None:
    for case in FROZEN["history_cases"]:
        raw, relative = _history_input(case, current)
        fault = case.get("fault")
        manager = contextlib.nullcontext()
        if fault and fault["kind"] != "forged_observation_hash":
            manager = patch.object(history, "HISTORY_STAGES", _fault_stages(fault))
        with manager:
            errors = history.main_game_history_source_errors(relative, raw)
            projected = history.main_game_history_project_bytes(raw, relative)
            claimed = fault["claimed_sha256"] if fault and fault["kind"] == "forged_observation_hash" else digest(raw)
            projected_hash = history.main_game_history_project_byte_hash(claimed, relative, raw)
            # Exercise the two real live entry functions on the same frozen
            # roster, not a second population or the giant audit commands.
            claim_manager = contextlib.nullcontext()
            if fault and fault["kind"] == "forged_observation_hash":
                claim_manager = patch.object(
                    history, "main_game_history_project_byte_hash", return_value=ORDER220_SHA)
            with claim_manager:
                consumer_errors = {
                    "year5": year5._order243_main_source_errors(
                        relative, raw, year5.ORDER156_SOURCE_FILE_TRANSITIONS[MAIN_PATH][1]),
                    "chapter1": chapter1._order243_main_source_errors(
                        relative, raw, chapter1.ORDER156_AUDITED_SOURCE_FILE_TRANSITIONS[MAIN_PATH][1]),
                }
        expected = case["expected_errors_empty"]
        passed = ((not errors) == expected and all(
            (not value) == expected for value in consumer_errors.values()))
        if expected:
            passed = passed and digest(projected) == ORDER220_SHA and projected_hash == ORDER220_SHA
        else:
            passed = passed and projected == raw and projected_hash == claimed
        results.append({
            "id": case["id"], "kind": case["kind"], "base_id": case["base_id"],
            "input_sha256": digest(raw), "path": relative,
            "errors": errors, "projected_sha256": digest(projected),
            "claimed_sha256": claimed, "projected_hash": projected_hash,
            "live_consumer_errors": consumer_errors,
            "passed": bool(passed),
        })


def _ja_inventory(calls: list[pipeline.UiCall]) -> pipeline.UiInventory:
    entries = tuple(pipeline.Entry(row.korean, row.korean, row.function) for row in calls)
    blueprint = {entry.key: {"$entry": entry.key} for entry in entries}
    return pipeline.UiInventory(
        calls=tuple(calls), legacy_entries=entries, legacy_blueprint=blueprint,
        planned_context_entries=(), planned_context_blueprint={},
        observed_context_entries=(), observed_context_blueprint={}, errors=(),
        stats={"implemented": True, "planned_context_ids": 0, "migrated_context_ids": 0},
    )


def japanese_cases(results: list[dict]) -> None:
    inputs = FROZEN["ja_inputs"]
    old, current = inputs["old_ko"], inputs["current_ko"]
    source_calls = [pipeline.UiCall(line=0, **row) for row in FROZEN["ja_calls"]]
    table = json.loads((ROOT / "locale/ui_ja.json").read_text(encoding="utf-8"))
    normal = {row.korean: table[row.korean] for row in source_calls}
    normal[old] = inputs["old_ja"]
    for case in FROZEN["ja_cases"]:
        calls = list(source_calls)
        actual = dict(normal)
        recipe = case["recipe"]
        if recipe["op"] in ("target", "add"):
            actual[recipe["key"]] = recipe["value"]
        elif recipe["op"] == "delete":
            del actual[recipe["key"]]
        elif recipe["op"] == "rollback_current_empty_owner_to_old_pair":
            calls[1] = pipeline.UiCall(
                MAIN_PATH, "_render_sidebars", 0, "legacy", old,
                "No important relationships yet. People appear here through relationship actions or story progress.",
            )
            actual.pop(current)
        elif recipe["op"] != "none":
            raise AssertionError("unknown JA fixed recipe")
        inventory = _ja_inventory(calls)
        errors: list[str] = []
        capture = io.StringIO()
        with patch.object(ja, "collect_ui_inventory", return_value=inventory), \
                patch.object(ja, "_demo_runtime", return_value=({}, {"merged_pairs": {}})), \
                patch.object(story_demo, "ui_pairs", return_value=({}, [], {})), \
                contextlib.redirect_stdout(capture):
            ja.check_ui_scope(actual, errors)
        authorized, source_errors = ja.retired_relationship_ui_entries(inventory)
        passed = (not errors) == case["expected_errors_empty"]
        if "expected_authorized_retired_keys" in case:
            passed = passed and sorted(authorized) == sorted(case["expected_authorized_retired_keys"])
        if "expected_error_contains" in case:
            passed = passed and any(case["expected_error_contains"] in error for error in errors)
        results.append({
            "id": case["id"], "kind": case["kind"], "base_id": case["base_id"],
            "errors": errors, "source_errors": source_errors,
            "authorized_retired_keys": sorted(authorized),
            "stdout": capture.getvalue(), "passed": bool(passed),
        })


def chinese_cases(results: list[dict], execution_counts: dict[str, int]) -> None:
    # One narrow demo source collection, not the full-game collector or CLI.
    execution_counts["demo_build_scope"] += 1
    observed, runtime, source_errors = demo.build_scope()
    if source_errors:
        raise AssertionError("actual demo source fixture invalid: " + repr(source_errors))
    loader_before = demo.load_overlay_events
    runtime_before = copy.deepcopy(runtime)
    execution_counts["demo_real_language_coverage"] += 1
    normal, normal_errors = demo.language_coverage("zh-CN", runtime, True)
    normal_ok = (
        observed["visible_event_count"] == 72 and observed["event_text_count"] == 467
        and normal["events"] == normal["total_events"] == 72
        and normal["event_strings"] == normal["total_event_strings"] == 467
        and not any("strict events coverage" in error for error in normal_errors)
    )
    results.append({
        "id": "cn_real_populated_events", "kind": "normal", "base_id": None,
        "coverage": normal, "errors": normal_errors, "passed": normal_ok,
        "claim": "Event coverage only; dynamic strict deficits do not imply full-demo PASS.",
    })
    execution_counts["demo_empty_fixture"] += 1
    empty, empty_errors = demo.empty_chinese_event_coverage_fixture(runtime)
    restored = demo.load_overlay_events is loader_before
    unchanged = runtime == runtime_before
    empty_ok = (
        empty["events"] == empty["event_strings"] == 0
        and empty["total_events"] == 72 and empty["total_event_strings"] == 467
        and any("strict events coverage 0/72" in error for error in empty_errors)
        and restored and unchanged
    )
    results.append({
        "id": "cn_actual_empty_overlay", "kind": "negative",
        "base_id": "cn_real_populated_events", "coverage": empty,
        "errors": empty_errors, "loader_identity_restored": restored,
        "runtime_unchanged": unchanged, "passed": empty_ok,
    })


def main() -> int:
    before = _pins()
    results: list[dict] = []
    execution_counts = {
        "demo_build_scope": 0, "demo_real_language_coverage": 0,
        "demo_empty_fixture": 0, "full_game_collector": 0,
        "whole_ja_cli": 0, "whole_demo_cli": 0, "old_26_self": 0, "engine": 0,
    }
    fatal = None
    try:
        current = (ROOT / MAIN_PATH).read_bytes()
        if digest(current) != CURRENT_SHA:
            raise AssertionError("current MainGame is not the exact approved source")
        history_cases(current, results)
        japanese_cases(results)
        chinese_cases(results, execution_counts)
    except Exception as error:
        fatal = f"{type(error).__name__}: {error}"
    after = _pins()
    by_id = {row["id"]: row for row in results}
    for row in results:
        base_id = row.get("base_id")
        row["normal_base_passed"] = base_id is None or bool(by_id.get(base_id, {}).get("passed"))
        row["valid_result"] = bool(row["passed"] and row["normal_base_passed"])
    passed = (
        fatal is None and len(results) == FROZEN["total_new_cases"]
        and len(by_id) == len(results)
        and all(row["valid_result"] for row in results) and before == after
    )
    output = {
        "schema_version": 1, "scope": "ORDER-243 finite reconciliation controls",
        "cases": len(results), "expected_cases": 28,
        "groups": {"history": 19, "ja": 7, "demo": 2},
        "results": results, "fatal": fatal,
        "input_before": before, "input_after": after, "inputs_unchanged": before == after,
        "execution_counts": execution_counts,
        "old_26_population": "Separate, unchanged expectations; not executed or counted here.",
        "passed": passed,
    }
    print(json.dumps(output, ensure_ascii=False, indent=2))
    print("CI_LOCALIZATION_RECONCILIATION_SELF_TEST_" + ("OK" if passed else "FAIL")
          + f" cases={len(results)} expected=28 inputs={len(before)} unchanged={before == after}")
    return 0 if passed else 1


if __name__ == "__main__":
    raise SystemExit(main())
