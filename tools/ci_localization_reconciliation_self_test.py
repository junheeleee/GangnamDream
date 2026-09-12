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



# BEGIN_TITLE_BUTTON_CI_SELF_256
# Independent recipes were frozen by Poincare before this implementation.
# This block is inserted BEFORE the sole __main__ guard.
import sys as _title_button_sys
import base64 as _title_button_base64
import traceback as _title_button_traceback

TITLE_BUTTON_SPEC = json.loads(r'''{
  "provenance": {
    "path": ".git/full-game-localization/order256-source-controls.json",
    "bytes": 40279,
    "sha256": "208a4d0595b595751dd1f85ea0660d510019b0110c2ee257069bf14078672bc9",
    "chronology": "Independent recipes/expectations frozen before helper/self implementation; actual future source4 and ROOT baseline binding are separate."
  },
  "cases_sha256": "0ae98a5ae0fb692c75eaf8f0ffebb69e827ac5283608d53a365801e32220bd21",
  "counts": {
    "normal": 1,
    "raw_mutant": 12,
    "registry_mutant": 3,
    "forged_observation": 2,
    "claim_boundary": 1,
    "off_boundary": 1
  },
  "main_edits": [
    {
      "id": "creation",
      "owner": "_build_top_bar",
      "kind": "replace_once",
      "before": "\t_title_collection_button = _small_button(_tr(\"칭호\", \"Title\"), \"#1a2a1a\")\n",
      "after": "\t_title_collection_button = _small_button(_title_collection_button_text(), \"#1a2a1a\")\n"
    },
    {
      "id": "refresh",
      "owner": "_refresh_all",
      "kind": "replace_once",
      "before": "\tif is_instance_valid(_title_collection_button):\n\t\t_title_collection_button.visible = not DEMO_CORE_LOOP_V2.requested()\n",
      "after": "\tif is_instance_valid(_title_collection_button):\n\t\t_title_collection_button.text = _title_collection_button_text()\n\t\t_title_collection_button.visible = not DEMO_CORE_LOOP_V2.requested()\n"
    },
    {
      "id": "label_helper",
      "owner": "_title_collection_button_text",
      "kind": "append_eof",
      "before": "",
      "after": "\nfunc _title_collection_button_text() -> String:\n\treturn _tr(\"칭호\", \"Title\")\n"
    }
  ],
  "cases": [
    {
      "id": "current_exact",
      "kind": "normal",
      "base": null,
      "relative": "scenes/MainGame.gd",
      "recipe": {
        "op": "approved_current_main",
        "source": "separate ROOT-approved future raw input; must equal frozen three-edit derivation"
      },
      "input_bytes": 1139685,
      "input_sha256": "ca0dd88c1aabd95f621f66a4213b23084de67b937ed9b9236483040d303b0e81",
      "reason": "All new/public APIs and both unchanged live raw gates must accept before any negative is effective.",
      "claim": "ca0dd88c1aabd95f621f66a4213b23084de67b937ed9b9236483040d303b0e81",
      "expected": {
        "exceptions": 0,
        "source_errors": "EMPTY",
        "public_source_errors": "EMPTY",
        "one_step_project_bytes_sha256": "9029fb680033141ce382fa114fafe9e814197e996f7a98fcf622f9bce4b1118d",
        "public_project_bytes_sha256": "5b891505892d3306197cb20b70e4e0d8074941aeb7ec40030857bd32bb912f88",
        "one_step_hash": "9029fb680033141ce382fa114fafe9e814197e996f7a98fcf622f9bce4b1118d",
        "public_hash": "5b891505892d3306197cb20b70e4e0d8074941aeb7ec40030857bd32bb912f88",
        "chapter_source_errors": "EMPTY",
        "year5_source_errors": "EMPTY",
        "effective_negative": false
      }
    },
    {
      "id": "rollback_previous_whole",
      "kind": "raw_mutant",
      "base": "current_exact",
      "relative": "scenes/MainGame.gd",
      "recipe": {
        "op": "baseline_whole",
        "path": "scenes/MainGame.gd",
        "sha256": "9029fb680033141ce382fa114fafe9e814197e996f7a98fcf622f9bce4b1118d"
      },
      "input_bytes": 1139530,
      "input_sha256": "9029fb680033141ce382fa114fafe9e814197e996f7a98fcf622f9bce4b1118d",
      "reason": "9029 is only predecessor output, never a second live normal.",
      "claim": "9029fb680033141ce382fa114fafe9e814197e996f7a98fcf622f9bce4b1118d",
      "expected": {
        "exceptions": 0,
        "source_errors": "NONEMPTY",
        "public_source_errors": "NONEMPTY",
        "one_step_project_bytes_sha256": "9029fb680033141ce382fa114fafe9e814197e996f7a98fcf622f9bce4b1118d",
        "public_project_bytes_sha256": "9029fb680033141ce382fa114fafe9e814197e996f7a98fcf622f9bce4b1118d",
        "one_step_hash": "9029fb680033141ce382fa114fafe9e814197e996f7a98fcf622f9bce4b1118d",
        "public_hash": "9029fb680033141ce382fa114fafe9e814197e996f7a98fcf622f9bce4b1118d",
        "chapter_source_errors": "NONEMPTY",
        "year5_source_errors": "NONEMPTY",
        "effective_negative": "ONLY_IF_CURRENT_EXACT_ALL_ENDPOINTS_PASS"
      }
    },
    {
      "id": "creation_removed",
      "kind": "raw_mutant",
      "base": "current_exact",
      "relative": "scenes/MainGame.gd",
      "recipe": {
        "op": "replace_exact",
        "before": "\t_title_collection_button = _small_button(_title_collection_button_text(), \"#1a2a1a\")\n",
        "after": "\t_title_collection_button = _small_button(_tr(\"칭호\", \"Title\"), \"#1a2a1a\")\n",
        "count": 1
      },
      "input_bytes": 1139676,
      "input_sha256": "7414422016d898cfd7e46b86559d399a4ecbf968357bc9f64b59818312ef331a",
      "reason": "The existing single lookup or refresh obligation cannot be omitted.",
      "claim": "7414422016d898cfd7e46b86559d399a4ecbf968357bc9f64b59818312ef331a",
      "expected": {
        "exceptions": 0,
        "source_errors": "NONEMPTY",
        "public_source_errors": "NONEMPTY",
        "one_step_project_bytes_sha256": "7414422016d898cfd7e46b86559d399a4ecbf968357bc9f64b59818312ef331a",
        "public_project_bytes_sha256": "7414422016d898cfd7e46b86559d399a4ecbf968357bc9f64b59818312ef331a",
        "one_step_hash": "7414422016d898cfd7e46b86559d399a4ecbf968357bc9f64b59818312ef331a",
        "public_hash": "7414422016d898cfd7e46b86559d399a4ecbf968357bc9f64b59818312ef331a",
        "chapter_source_errors": "NONEMPTY",
        "year5_source_errors": "NONEMPTY",
        "effective_negative": "ONLY_IF_CURRENT_EXACT_ALL_ENDPOINTS_PASS"
      }
    },
    {
      "id": "refresh_removed",
      "kind": "raw_mutant",
      "base": "current_exact",
      "relative": "scenes/MainGame.gd",
      "recipe": {
        "op": "replace_exact",
        "before": "\tif is_instance_valid(_title_collection_button):\n\t\t_title_collection_button.text = _title_collection_button_text()\n\t\t_title_collection_button.visible = not DEMO_CORE_LOOP_V2.requested()\n",
        "after": "\tif is_instance_valid(_title_collection_button):\n\t\t_title_collection_button.visible = not DEMO_CORE_LOOP_V2.requested()\n",
        "count": 1
      },
      "input_bytes": 1139619,
      "input_sha256": "954e309c6c9c13f058021f6e968c4bd07a480e8e1c45d8fbd7d19e76cc798551",
      "reason": "The existing single lookup or refresh obligation cannot be omitted.",
      "claim": "954e309c6c9c13f058021f6e968c4bd07a480e8e1c45d8fbd7d19e76cc798551",
      "expected": {
        "exceptions": 0,
        "source_errors": "NONEMPTY",
        "public_source_errors": "NONEMPTY",
        "one_step_project_bytes_sha256": "954e309c6c9c13f058021f6e968c4bd07a480e8e1c45d8fbd7d19e76cc798551",
        "public_project_bytes_sha256": "954e309c6c9c13f058021f6e968c4bd07a480e8e1c45d8fbd7d19e76cc798551",
        "one_step_hash": "954e309c6c9c13f058021f6e968c4bd07a480e8e1c45d8fbd7d19e76cc798551",
        "public_hash": "954e309c6c9c13f058021f6e968c4bd07a480e8e1c45d8fbd7d19e76cc798551",
        "chapter_source_errors": "NONEMPTY",
        "year5_source_errors": "NONEMPTY",
        "effective_negative": "ONLY_IF_CURRENT_EXACT_ALL_ENDPOINTS_PASS"
      }
    },
    {
      "id": "label_helper_removed",
      "kind": "raw_mutant",
      "base": "current_exact",
      "relative": "scenes/MainGame.gd",
      "recipe": {
        "op": "remove_exact_suffix",
        "text": "\nfunc _title_collection_button_text() -> String:\n\treturn _tr(\"칭호\", \"Title\")\n",
        "count": 1
      },
      "input_bytes": 1139605,
      "input_sha256": "9e7c66ae9456aa378acfc4273e6077bfc66ed51118f57027bc82b6af10df3175",
      "reason": "Calls without the approved pure label function are not valid current source.",
      "claim": "9e7c66ae9456aa378acfc4273e6077bfc66ed51118f57027bc82b6af10df3175",
      "expected": {
        "exceptions": 0,
        "source_errors": "NONEMPTY",
        "public_source_errors": "NONEMPTY",
        "one_step_project_bytes_sha256": "9e7c66ae9456aa378acfc4273e6077bfc66ed51118f57027bc82b6af10df3175",
        "public_project_bytes_sha256": "9e7c66ae9456aa378acfc4273e6077bfc66ed51118f57027bc82b6af10df3175",
        "one_step_hash": "9e7c66ae9456aa378acfc4273e6077bfc66ed51118f57027bc82b6af10df3175",
        "public_hash": "9e7c66ae9456aa378acfc4273e6077bfc66ed51118f57027bc82b6af10df3175",
        "chapter_source_errors": "NONEMPTY",
        "year5_source_errors": "NONEMPTY",
        "effective_negative": "ONLY_IF_CURRENT_EXACT_ALL_ENDPOINTS_PASS"
      }
    },
    {
      "id": "ko_literal_changed",
      "kind": "raw_mutant",
      "base": "current_exact",
      "relative": "scenes/MainGame.gd",
      "recipe": {
        "op": "replace_exact",
        "before": "\treturn _tr(\"칭호\", \"Title\")\n",
        "after": "\treturn _tr(\"업적\", \"Title\")\n",
        "count": 1
      },
      "input_bytes": 1139685,
      "input_sha256": "2d21b5672b48830b70f17a012c6a6bae33953e01f492b03f1f409250b4c537db",
      "reason": "Same owner but wrong Korean lookup key.",
      "claim": "2d21b5672b48830b70f17a012c6a6bae33953e01f492b03f1f409250b4c537db",
      "expected": {
        "exceptions": 0,
        "source_errors": "NONEMPTY",
        "public_source_errors": "NONEMPTY",
        "one_step_project_bytes_sha256": "2d21b5672b48830b70f17a012c6a6bae33953e01f492b03f1f409250b4c537db",
        "public_project_bytes_sha256": "2d21b5672b48830b70f17a012c6a6bae33953e01f492b03f1f409250b4c537db",
        "one_step_hash": "2d21b5672b48830b70f17a012c6a6bae33953e01f492b03f1f409250b4c537db",
        "public_hash": "2d21b5672b48830b70f17a012c6a6bae33953e01f492b03f1f409250b4c537db",
        "chapter_source_errors": "NONEMPTY",
        "year5_source_errors": "NONEMPTY",
        "effective_negative": "ONLY_IF_CURRENT_EXACT_ALL_ENDPOINTS_PASS"
      }
    },
    {
      "id": "en_literal_changed",
      "kind": "raw_mutant",
      "base": "current_exact",
      "relative": "scenes/MainGame.gd",
      "recipe": {
        "op": "replace_exact",
        "before": "\treturn _tr(\"칭호\", \"Title\")\n",
        "after": "\treturn _tr(\"칭호\", \"Achievement\")\n",
        "count": 1
      },
      "input_bytes": 1139691,
      "input_sha256": "1feecf741ae2d87ba497ef0b52fc0d6be01f0c1d991f4cad163dd012d1ec545c",
      "reason": "English compatibility fallback may not change.",
      "claim": "1feecf741ae2d87ba497ef0b52fc0d6be01f0c1d991f4cad163dd012d1ec545c",
      "expected": {
        "exceptions": 0,
        "source_errors": "NONEMPTY",
        "public_source_errors": "NONEMPTY",
        "one_step_project_bytes_sha256": "1feecf741ae2d87ba497ef0b52fc0d6be01f0c1d991f4cad163dd012d1ec545c",
        "public_project_bytes_sha256": "1feecf741ae2d87ba497ef0b52fc0d6be01f0c1d991f4cad163dd012d1ec545c",
        "one_step_hash": "1feecf741ae2d87ba497ef0b52fc0d6be01f0c1d991f4cad163dd012d1ec545c",
        "public_hash": "1feecf741ae2d87ba497ef0b52fc0d6be01f0c1d991f4cad163dd012d1ec545c",
        "chapter_source_errors": "NONEMPTY",
        "year5_source_errors": "NONEMPTY",
        "effective_negative": "ONLY_IF_CURRENT_EXACT_ALL_ENDPOINTS_PASS"
      }
    },
    {
      "id": "owner_renamed",
      "kind": "raw_mutant",
      "base": "current_exact",
      "relative": "scenes/MainGame.gd",
      "recipe": {
        "op": "replace_exact",
        "before": "_title_collection_button_text",
        "after": "_qa_other_title_button_text",
        "count": 3
      },
      "input_bytes": 1139679,
      "input_sha256": "cd1d3a187a979353e4943355e7706aaab8ffd8ce817c32269dd8ac6729cc820e",
      "reason": "Exact helper owner moves even though all three references follow it.",
      "claim": "cd1d3a187a979353e4943355e7706aaab8ffd8ce817c32269dd8ac6729cc820e",
      "expected": {
        "exceptions": 0,
        "source_errors": "NONEMPTY",
        "public_source_errors": "NONEMPTY",
        "one_step_project_bytes_sha256": "cd1d3a187a979353e4943355e7706aaab8ffd8ce817c32269dd8ac6729cc820e",
        "public_project_bytes_sha256": "cd1d3a187a979353e4943355e7706aaab8ffd8ce817c32269dd8ac6729cc820e",
        "one_step_hash": "cd1d3a187a979353e4943355e7706aaab8ffd8ce817c32269dd8ac6729cc820e",
        "public_hash": "cd1d3a187a979353e4943355e7706aaab8ffd8ce817c32269dd8ac6729cc820e",
        "chapter_source_errors": "NONEMPTY",
        "year5_source_errors": "NONEMPTY",
        "effective_negative": "ONLY_IF_CURRENT_EXACT_ALL_ENDPOINTS_PASS"
      }
    },
    {
      "id": "nonlocalized_return",
      "kind": "raw_mutant",
      "base": "current_exact",
      "relative": "scenes/MainGame.gd",
      "recipe": {
        "op": "replace_exact",
        "before": "\treturn _tr(\"칭호\", \"Title\")\n",
        "after": "\treturn \"칭호\"\n",
        "count": 1
      },
      "input_bytes": 1139671,
      "input_sha256": "cb272c2aa730b45fc30b66248848f4b9a57f3775b18a382984fed29073d47b23",
      "reason": "Direct Korean return is not the shared localized pair.",
      "claim": "cb272c2aa730b45fc30b66248848f4b9a57f3775b18a382984fed29073d47b23",
      "expected": {
        "exceptions": 0,
        "source_errors": "NONEMPTY",
        "public_source_errors": "NONEMPTY",
        "one_step_project_bytes_sha256": "cb272c2aa730b45fc30b66248848f4b9a57f3775b18a382984fed29073d47b23",
        "public_project_bytes_sha256": "cb272c2aa730b45fc30b66248848f4b9a57f3775b18a382984fed29073d47b23",
        "one_step_hash": "cb272c2aa730b45fc30b66248848f4b9a57f3775b18a382984fed29073d47b23",
        "public_hash": "cb272c2aa730b45fc30b66248848f4b9a57f3775b18a382984fed29073d47b23",
        "chapter_source_errors": "NONEMPTY",
        "year5_source_errors": "NONEMPTY",
        "effective_negative": "ONLY_IF_CURRENT_EXACT_ALL_ENDPOINTS_PASS"
      }
    },
    {
      "id": "duplicate_helper",
      "kind": "raw_mutant",
      "base": "current_exact",
      "relative": "scenes/MainGame.gd",
      "recipe": {
        "op": "append_exact",
        "text": "\nfunc _title_collection_button_text() -> String:\n\treturn _tr(\"칭호\", \"Title\")\n",
        "expected_original_count": 1
      },
      "input_bytes": 1139765,
      "input_sha256": "4debc94393a349ce19e212087d7810f0476f5cbd177ea772b8d6a664cd1b3416",
      "reason": "Duplicate complete function must not satisfy inverse uniqueness.",
      "claim": "4debc94393a349ce19e212087d7810f0476f5cbd177ea772b8d6a664cd1b3416",
      "expected": {
        "exceptions": 0,
        "source_errors": "NONEMPTY",
        "public_source_errors": "NONEMPTY",
        "one_step_project_bytes_sha256": "4debc94393a349ce19e212087d7810f0476f5cbd177ea772b8d6a664cd1b3416",
        "public_project_bytes_sha256": "4debc94393a349ce19e212087d7810f0476f5cbd177ea772b8d6a664cd1b3416",
        "one_step_hash": "4debc94393a349ce19e212087d7810f0476f5cbd177ea772b8d6a664cd1b3416",
        "public_hash": "4debc94393a349ce19e212087d7810f0476f5cbd177ea772b8d6a664cd1b3416",
        "chapter_source_errors": "NONEMPTY",
        "year5_source_errors": "NONEMPTY",
        "effective_negative": "ONLY_IF_CURRENT_EXACT_ALL_ENDPOINTS_PASS"
      }
    },
    {
      "id": "extra_lf",
      "kind": "raw_mutant",
      "base": "current_exact",
      "relative": "scenes/MainGame.gd",
      "recipe": {
        "op": "append_exact",
        "text": "\n",
        "expected_original_eof_lf_count": 1
      },
      "input_bytes": 1139686,
      "input_sha256": "5df13e30d2dfc4f2b6a03ab4c9e96627ffe83ba856a310d51b406216397a47a7",
      "reason": "Whole raw byte authority includes final LF; do not normalize it.",
      "claim": "5df13e30d2dfc4f2b6a03ab4c9e96627ffe83ba856a310d51b406216397a47a7",
      "expected": {
        "exceptions": 0,
        "source_errors": "NONEMPTY",
        "public_source_errors": "NONEMPTY",
        "one_step_project_bytes_sha256": "5df13e30d2dfc4f2b6a03ab4c9e96627ffe83ba856a310d51b406216397a47a7",
        "public_project_bytes_sha256": "5df13e30d2dfc4f2b6a03ab4c9e96627ffe83ba856a310d51b406216397a47a7",
        "one_step_hash": "5df13e30d2dfc4f2b6a03ab4c9e96627ffe83ba856a310d51b406216397a47a7",
        "public_hash": "5df13e30d2dfc4f2b6a03ab4c9e96627ffe83ba856a310d51b406216397a47a7",
        "chapter_source_errors": "NONEMPTY",
        "year5_source_errors": "NONEMPTY",
        "effective_negative": "ONLY_IF_CURRENT_EXACT_ALL_ENDPOINTS_PASS"
      }
    },
    {
      "id": "all_crlf",
      "kind": "raw_mutant",
      "base": "current_exact",
      "relative": "scenes/MainGame.gd",
      "recipe": {
        "op": "replace_all_lf_with_crlf",
        "lf_count": 23874,
        "expected_original_cr_count": 0
      },
      "input_bytes": 1163559,
      "input_sha256": "4679bc9eed3c0938e130567010ec27d8e84f7dad6f2f05700cf21264360a9be8",
      "reason": "read_text newline normalization must not admit CRLF raw.",
      "claim": "4679bc9eed3c0938e130567010ec27d8e84f7dad6f2f05700cf21264360a9be8",
      "expected": {
        "exceptions": 0,
        "source_errors": "NONEMPTY",
        "public_source_errors": "NONEMPTY",
        "one_step_project_bytes_sha256": "4679bc9eed3c0938e130567010ec27d8e84f7dad6f2f05700cf21264360a9be8",
        "public_project_bytes_sha256": "4679bc9eed3c0938e130567010ec27d8e84f7dad6f2f05700cf21264360a9be8",
        "one_step_hash": "4679bc9eed3c0938e130567010ec27d8e84f7dad6f2f05700cf21264360a9be8",
        "public_hash": "4679bc9eed3c0938e130567010ec27d8e84f7dad6f2f05700cf21264360a9be8",
        "chapter_source_errors": "NONEMPTY",
        "year5_source_errors": "NONEMPTY",
        "effective_negative": "ONLY_IF_CURRENT_EXACT_ALL_ENDPOINTS_PASS"
      }
    },
    {
      "id": "visibility_policy_changed",
      "kind": "raw_mutant",
      "base": "current_exact",
      "relative": "scenes/MainGame.gd",
      "recipe": {
        "op": "replace_exact",
        "before": "\t\t_title_collection_button.visible = not DEMO_CORE_LOOP_V2.requested()\n",
        "after": "\t\t_title_collection_button.visible = true\n",
        "count": 1
      },
      "input_bytes": 1139656,
      "input_sha256": "4b2a2d61202d01062f24161b18e98c7fe5e5edbb37a9cec76bf9380df3774920",
      "reason": "Nonlanguage access/visibility policy is outside the three edits.",
      "claim": "4b2a2d61202d01062f24161b18e98c7fe5e5edbb37a9cec76bf9380df3774920",
      "expected": {
        "exceptions": 0,
        "source_errors": "NONEMPTY",
        "public_source_errors": "NONEMPTY",
        "one_step_project_bytes_sha256": "4b2a2d61202d01062f24161b18e98c7fe5e5edbb37a9cec76bf9380df3774920",
        "public_project_bytes_sha256": "4b2a2d61202d01062f24161b18e98c7fe5e5edbb37a9cec76bf9380df3774920",
        "one_step_hash": "4b2a2d61202d01062f24161b18e98c7fe5e5edbb37a9cec76bf9380df3774920",
        "public_hash": "4b2a2d61202d01062f24161b18e98c7fe5e5edbb37a9cec76bf9380df3774920",
        "chapter_source_errors": "NONEMPTY",
        "year5_source_errors": "NONEMPTY",
        "effective_negative": "ONLY_IF_CURRENT_EXACT_ALL_ENDPOINTS_PASS"
      }
    },
    {
      "id": "registry_wrong_previous",
      "kind": "registry_mutant",
      "base": "current_exact",
      "relative": "scenes/MainGame.gd",
      "recipe": {
        "op": "current_raw_registry_mutation",
        "mutation": {
          "op": "set",
          "path": [
            "previous_sha256"
          ],
          "value": "014bdae5a87cb3a873f61c5f83d8337f6d686068366641eb92c94e515bebad86"
        },
        "reseal": "_TITLE_BUTTON_REGISTRY_SHA256",
        "raw_unchanged": true
      },
      "input_bytes": 1139685,
      "input_sha256": "ca0dd88c1aabd95f621f66a4213b23084de67b937ed9b9236483040d303b0e81",
      "reason": "Checksum resealing cannot jump over the fixed9029 predecessor.",
      "claim": "ca0dd88c1aabd95f621f66a4213b23084de67b937ed9b9236483040d303b0e81",
      "expected": {
        "exceptions": 0,
        "source_errors": "NONEMPTY",
        "public_source_errors": "NONEMPTY",
        "one_step_project_bytes_sha256": "ca0dd88c1aabd95f621f66a4213b23084de67b937ed9b9236483040d303b0e81",
        "public_project_bytes_sha256": "ca0dd88c1aabd95f621f66a4213b23084de67b937ed9b9236483040d303b0e81",
        "one_step_hash": "ca0dd88c1aabd95f621f66a4213b23084de67b937ed9b9236483040d303b0e81",
        "public_hash": "ca0dd88c1aabd95f621f66a4213b23084de67b937ed9b9236483040d303b0e81",
        "chapter_source_errors": "NONEMPTY",
        "year5_source_errors": "NONEMPTY",
        "effective_negative": "ONLY_IF_CURRENT_EXACT_ALL_ENDPOINTS_PASS"
      }
    },
    {
      "id": "registry_missing_creation",
      "kind": "registry_mutant",
      "base": "current_exact",
      "relative": "scenes/MainGame.gd",
      "recipe": {
        "op": "current_raw_registry_mutation",
        "mutation": {
          "op": "remove_inverse_by_id",
          "id": "creation"
        },
        "reseal": "_TITLE_BUTTON_REGISTRY_SHA256",
        "raw_unchanged": true
      },
      "input_bytes": 1139685,
      "input_sha256": "ca0dd88c1aabd95f621f66a4213b23084de67b937ed9b9236483040d303b0e81",
      "reason": "Valid current raw with missing one inverse is still invalid after checksum reseal.",
      "claim": "ca0dd88c1aabd95f621f66a4213b23084de67b937ed9b9236483040d303b0e81",
      "expected": {
        "exceptions": 0,
        "source_errors": "NONEMPTY",
        "public_source_errors": "NONEMPTY",
        "one_step_project_bytes_sha256": "ca0dd88c1aabd95f621f66a4213b23084de67b937ed9b9236483040d303b0e81",
        "public_project_bytes_sha256": "ca0dd88c1aabd95f621f66a4213b23084de67b937ed9b9236483040d303b0e81",
        "one_step_hash": "ca0dd88c1aabd95f621f66a4213b23084de67b937ed9b9236483040d303b0e81",
        "public_hash": "ca0dd88c1aabd95f621f66a4213b23084de67b937ed9b9236483040d303b0e81",
        "chapter_source_errors": "NONEMPTY",
        "year5_source_errors": "NONEMPTY",
        "effective_negative": "ONLY_IF_CURRENT_EXACT_ALL_ENDPOINTS_PASS"
      }
    },
    {
      "id": "registry_duplicate_refresh",
      "kind": "registry_mutant",
      "base": "current_exact",
      "relative": "scenes/MainGame.gd",
      "recipe": {
        "op": "current_raw_registry_mutation",
        "mutation": {
          "op": "append_inverse_copy_by_id",
          "id": "refresh"
        },
        "reseal": "_TITLE_BUTTON_REGISTRY_SHA256",
        "raw_unchanged": true
      },
      "input_bytes": 1139685,
      "input_sha256": "ca0dd88c1aabd95f621f66a4213b23084de67b937ed9b9236483040d303b0e81",
      "reason": "Duplicate inverse/cardinality is rejected even with recomputed registry checksum.",
      "claim": "ca0dd88c1aabd95f621f66a4213b23084de67b937ed9b9236483040d303b0e81",
      "expected": {
        "exceptions": 0,
        "source_errors": "NONEMPTY",
        "public_source_errors": "NONEMPTY",
        "one_step_project_bytes_sha256": "ca0dd88c1aabd95f621f66a4213b23084de67b937ed9b9236483040d303b0e81",
        "public_project_bytes_sha256": "ca0dd88c1aabd95f621f66a4213b23084de67b937ed9b9236483040d303b0e81",
        "one_step_hash": "ca0dd88c1aabd95f621f66a4213b23084de67b937ed9b9236483040d303b0e81",
        "public_hash": "ca0dd88c1aabd95f621f66a4213b23084de67b937ed9b9236483040d303b0e81",
        "chapter_source_errors": "NONEMPTY",
        "year5_source_errors": "NONEMPTY",
        "effective_negative": "ONLY_IF_CURRENT_EXACT_ALL_ENDPOINTS_PASS"
      }
    },
    {
      "id": "forged_visibility",
      "kind": "forged_observation",
      "base": "current_exact",
      "relative": "scenes/MainGame.gd",
      "recipe": {
        "op": "raw_from_case",
        "id": "visibility_policy_changed",
        "live_only_projector_override": true
      },
      "input_bytes": 1139656,
      "input_sha256": "4b2a2d61202d01062f24161b18e98c7fe5e5edbb37a9cec76bf9380df3774920",
      "reason": "Forged old220 projector bytes/hash observations must not bypass either real raw source gate.",
      "claim": "4b2a2d61202d01062f24161b18e98c7fe5e5edbb37a9cec76bf9380df3774920",
      "expected": {
        "exceptions": 0,
        "source_errors": "NONEMPTY",
        "public_source_errors": "NONEMPTY",
        "one_step_project_bytes_sha256": "4b2a2d61202d01062f24161b18e98c7fe5e5edbb37a9cec76bf9380df3774920",
        "public_project_bytes_sha256": "4b2a2d61202d01062f24161b18e98c7fe5e5edbb37a9cec76bf9380df3774920",
        "one_step_hash": "4b2a2d61202d01062f24161b18e98c7fe5e5edbb37a9cec76bf9380df3774920",
        "public_hash": "4b2a2d61202d01062f24161b18e98c7fe5e5edbb37a9cec76bf9380df3774920",
        "chapter_source_errors": "NONEMPTY",
        "year5_source_errors": "NONEMPTY",
        "effective_negative": "ONLY_IF_CURRENT_EXACT_ALL_ENDPOINTS_PASS"
      }
    },
    {
      "id": "forged_crlf",
      "kind": "forged_observation",
      "base": "current_exact",
      "relative": "scenes/MainGame.gd",
      "recipe": {
        "op": "raw_from_case",
        "id": "all_crlf",
        "live_only_projector_override": true
      },
      "input_bytes": 1163559,
      "input_sha256": "4679bc9eed3c0938e130567010ec27d8e84f7dad6f2f05700cf21264360a9be8",
      "reason": "Forged old220 projector bytes/hash observations must not bypass either real raw source gate.",
      "claim": "4679bc9eed3c0938e130567010ec27d8e84f7dad6f2f05700cf21264360a9be8",
      "expected": {
        "exceptions": 0,
        "source_errors": "NONEMPTY",
        "public_source_errors": "NONEMPTY",
        "one_step_project_bytes_sha256": "4679bc9eed3c0938e130567010ec27d8e84f7dad6f2f05700cf21264360a9be8",
        "public_project_bytes_sha256": "4679bc9eed3c0938e130567010ec27d8e84f7dad6f2f05700cf21264360a9be8",
        "one_step_hash": "4679bc9eed3c0938e130567010ec27d8e84f7dad6f2f05700cf21264360a9be8",
        "public_hash": "4679bc9eed3c0938e130567010ec27d8e84f7dad6f2f05700cf21264360a9be8",
        "chapter_source_errors": "NONEMPTY",
        "year5_source_errors": "NONEMPTY",
        "effective_negative": "ONLY_IF_CURRENT_EXACT_ALL_ENDPOINTS_PASS"
      }
    },
    {
      "id": "wrong_claim",
      "kind": "claim_boundary",
      "base": "current_exact",
      "relative": "scenes/MainGame.gd",
      "recipe": {
        "op": "current_raw_with_claim",
        "claim": "0000000000000000000000000000000000000000000000000000000000000000"
      },
      "input_bytes": 1139685,
      "input_sha256": "ca0dd88c1aabd95f621f66a4213b23084de67b937ed9b9236483040d303b0e81",
      "reason": "Valid source plus wrong claim: source gates pass, both hash APIs preserve the original bad claim.",
      "claim": "0000000000000000000000000000000000000000000000000000000000000000",
      "expected": {
        "exceptions": 0,
        "source_errors": "EMPTY",
        "public_source_errors": "EMPTY",
        "one_step_project_bytes_sha256": "9029fb680033141ce382fa114fafe9e814197e996f7a98fcf622f9bce4b1118d",
        "public_project_bytes_sha256": "5b891505892d3306197cb20b70e4e0d8074941aeb7ec40030857bd32bb912f88",
        "one_step_hash": "0000000000000000000000000000000000000000000000000000000000000000",
        "public_hash": "0000000000000000000000000000000000000000000000000000000000000000",
        "chapter_source_errors": "EMPTY",
        "year5_source_errors": "EMPTY",
        "effective_negative": false
      }
    },
    {
      "id": "off_path",
      "kind": "off_boundary",
      "base": "current_exact",
      "relative": "scenes/MainGame.gd.unowned",
      "recipe": {
        "op": "current_raw_with_relative",
        "relative": "scenes/MainGame.gd.unowned"
      },
      "input_bytes": 1139685,
      "input_sha256": "ca0dd88c1aabd95f621f66a4213b23084de67b937ed9b9236483040d303b0e81",
      "reason": "New one-step rejects OFF; public calls preserve exact old APIs/errors and identity.",
      "claim": "ca0dd88c1aabd95f621f66a4213b23084de67b937ed9b9236483040d303b0e81",
      "expected": {
        "exceptions": 0,
        "source_errors": "NONEMPTY",
        "public_source_errors": "BASELINE_OFF_EXACT",
        "one_step_project_bytes_sha256": "ca0dd88c1aabd95f621f66a4213b23084de67b937ed9b9236483040d303b0e81",
        "public_project_bytes_sha256": "ca0dd88c1aabd95f621f66a4213b23084de67b937ed9b9236483040d303b0e81",
        "one_step_hash": "ca0dd88c1aabd95f621f66a4213b23084de67b937ed9b9236483040d303b0e81",
        "public_hash": "ca0dd88c1aabd95f621f66a4213b23084de67b937ed9b9236483040d303b0e81",
        "chapter_source_errors": "BASELINE_OFF_EXACT",
        "year5_source_errors": "BASELINE_OFF_EXACT",
        "effective_negative": false
      }
    }
  ]
}''')
# BEGIN_TITLE_BUTTON_BINDING_256
TITLE_BUTTON_BINDING = json.loads(r'''{
  "phase": "APPLIED_SOURCE_BOUND",
  "current_pins": {
    "scenes/MainGame.gd": {
      "bytes": 1139685,
      "sha256": "ca0dd88c1aabd95f621f66a4213b23084de67b937ed9b9236483040d303b0e81"
    },
    "tools/main_game_locale_history.py": {
      "bytes": 12116,
      "sha256": "dbba098883a7407f039381f366ce87dd0e265ddbed88beabd5ee687793b9db68"
    },
    "tools/ci_localization_reconciliation_self_test.py": {
      "bytes": 84017,
      "sha256": "52ae7c24618689fe00b369418a05035060ac64f3d66878ee22657e7d27698a1a"
    },
    "tools/meta_title_locale_successor_self_test.py": {
      "bytes": 274977,
      "sha256": "5af619d0afda083934221201a5a704bf8bb4679442cb38eba9901beb35d259b0"
    }
  },
  "code_pin_note": "CI current_pins entry is exact whole bytes with only the clearly delimited TITLE_BUTTON_BINDING block replaced by its canonical empty-object form; all other current entries are full raw. Physical before/after still hash full unmasked CI bytes. This avoids self-referential hashes and permits ROOT phase/provenance binding without changing methods/expected.",
  "previous_pins": {
    "scenes/MainGame.gd": {
      "bytes": 1139530,
      "sha256": "9029fb680033141ce382fa114fafe9e814197e996f7a98fcf622f9bce4b1118d"
    },
    "tools/main_game_locale_history.py": {
      "bytes": 5261,
      "sha256": "268be5cdd6de2bdd36e862951d87710899889c2c53acd327408c2675f7463490"
    },
    "tools/ci_localization_reconciliation_self_test.py": {
      "bytes": 31464,
      "sha256": "12ff8ba402154da0318565dc1b985676e6d2f679f9213c0ca8ff4f17a019ea38"
    },
    "tools/meta_title_locale_successor_self_test.py": {
      "bytes": 268857,
      "sha256": "6872a159ffd4fb4ba2203b92408ce58f6149001403f50efc33fc0354d4faeaf9"
    }
  },
  "preserved_pins": {
    "tools/year5_reference_route_audit.py": {
      "bytes": 620325,
      "sha256": "b4c34f559a458b4ad53ff19a0855d76176ec84083ba7b725f21a4f7aa6f50f82"
    },
    "tools/chapter1_core_loop_v2_causal_ledger_check.py": {
      "bytes": 1461830,
      "sha256": "ac874ad1587304b4f1802ce2311cbcba231e1fdfb19086cce3a66aa19ee5fac3"
    },
    "autoloads/MetaProgression.gd": {
      "bytes": 65836,
      "sha256": "6f49a1bdd83b3431b4146bbd2a94956c481bb371202606398167cdec8ae9f8b0"
    },
    "autoloads/LocaleManager.gd": {
      "bytes": 20574,
      "sha256": "9417e6b9e241e1d2b9ec7a7668cf4d19fe337ce6719d87e032020fe421ceec9a"
    },
    "tools/ja_translation_pipeline.py": {
      "bytes": 264116,
      "sha256": "3a2d791038a46dcf3442776f4703cd1398998590843b91904c2668425a7427f4"
    },
    "tools/meta_title_locale_successor.py": {
      "bytes": 46649,
      "sha256": "1df50f967c6fea8711f8375f0c5db940499066d4a0e73f75652d2fc1b39aaf6c"
    }
  },
  "inverse_spans": {
    "tools/main_game_locale_history.py": {
      "start": "\n# BEGIN_TITLE_BUTTON_MAIN_SUCCESSOR_256\n",
      "end": "# END_TITLE_BUTTON_MAIN_SUCCESSOR_256\n",
      "hooks": []
    },
    "tools/ci_localization_reconciliation_self_test.py": {
      "start": "\n# BEGIN_TITLE_BUTTON_CI_SELF_256\n",
      "end": "# END_TITLE_BUTTON_CI_SELF_256\n",
      "hooks": [
        [
          "    raise SystemExit(_title_button_main())\n",
          "    raise SystemExit(main())\n"
        ]
      ]
    },
    "tools/meta_title_locale_successor_self_test.py": {
      "start": "\n# BEGIN_TITLE_BUTTON_META_SELF_256\n",
      "end": "# END_TITLE_BUTTON_META_SELF_256\n",
      "hooks": [
        [
          "    raise SystemExit(_title_button_meta_main())\n",
          "    raise SystemExit(_last11_main())\n"
        ]
      ]
    }
  },
  "baseline_off_errors": {
    "public_source_errors": [
      "ORDER-243: locale history path is not the owned path",
      "ORDER-243: unapproved current MainGame source bytes"
    ],
    "chapter_source_errors": [
      "ORDER-243: locale history path is not the owned path",
      "ORDER-243: unapproved current MainGame source bytes"
    ],
    "year5_source_errors": [
      "ORDER-243: locale history path is not the owned path",
      "ORDER-243: unapproved current MainGame source bytes"
    ]
  },
  "provenance": {
    "controls": {
      "path": ".git/full-game-localization/order256-source-controls.json",
      "sha256": "208a4d0595b595751dd1f85ea0660d510019b0110c2ee257069bf14078672bc9"
    },
    "baseline": {
      "path": ".git/full-game-localization/order256-source-baseline-first.json",
      "bytes": 42830483,
      "sha256": "e714fd3222937810ce5e931fe17d54c5bd51eab4571fc67d2183c4c794807293",
      "meaning": "ROOT old-product first capture complete; new APIs absent; effective negatives0; not post PASS. Original OFF arrays read from off_original_observation."
    },
    "candidate": "B2 private candidate: meta adds frozen current_exact prerequisite1/new20=0 before history; CI preserves unexpected byte return via base64 only when no exact known raw reference. B1 artifacts preserved; no candidate imported, applied or executed.",
    "actual_applied_source4": {
      "external_raw_binding": ".git/full-game-localization/order256-source4-applied-binding.json",
      "meaning": "ROOT serially applied the independently reviewed B2 source4. Exact full CI raw is bound externally after this phase/provenance-only patch; embedded CI codeview remains distinct."
    },
    "independent_review": {
      "path": ".git/full-game-localization/order256-source4-private-final-review.json",
      "bytes": 5709,
      "sha256": "f0f4c9eb93aa917fa6d41a87f33435aac40ac77f0fd2053c8ffb0322b6c684db"
    },
    "chronology": "Frozen20 preceded source authorship; first baseline e330 captured old-product20/effective0. B1 static REWORK2 was repaired in B2 and reviewed required0. ROOT applied B2, then changed only this binding phase/provenance. First current20 and old28 execution are still unobserved."
  }
}''')
# END_TITLE_BUTTON_BINDING_256


def _title_button_code_view(raw):
    start = b"# BEGIN_TITLE_BUTTON_BINDING_256\n"
    end = b"# END_TITLE_BUTTON_BINDING_256\n"
    if raw.count(start) != 1 or raw.count(end) != 1:
        raise AssertionError("title-button binding block is not unique")
    a, z = raw.index(start), raw.index(end) + len(end)
    if a >= z:
        raise AssertionError("title-button binding order differs")
    return raw[:a] + start + b"TITLE_BUTTON_BINDING = {}\n" + end + raw[z:]


def _title_button_physical_pins():
    paths = set(TITLE_BUTTON_BINDING["previous_pins"]) | set(
        TITLE_BUTTON_BINDING["preserved_pins"])
    return {p: {"bytes": len(raw), "sha256": digest(raw)}
            for p in sorted(paths) for raw in [(ROOT / p).read_bytes()]}


def _title_button_inverse(raw, relative):
    """Independent byte edits, not the production projector under test."""
    previous = TITLE_BUTTON_BINDING["previous_pins"][relative]
    if relative == MAIN_PATH:
        old = raw
        for row in reversed(TITLE_BUTTON_SPEC["main_edits"]):
            before, after = row["before"].encode("utf-8"), row["after"].encode("utf-8")
            if old.count(after) != 1:
                raise AssertionError("independent Main inverse is not unique")
            if row["kind"] == "append_eof":
                if not old.endswith(after):
                    raise AssertionError("independent Main EOF differs")
                old = old[:-len(after)]
            else:
                old = old.replace(after, before, 1)
    else:
        rule = TITLE_BUTTON_BINDING["inverse_spans"][relative]
        start, end = rule["start"].encode("utf-8"), rule["end"].encode("utf-8")
        if raw.count(start) != 1 or raw.count(end) != 1:
            raise AssertionError("independent inverse span is not unique: " + relative)
        a, z = raw.index(start), raw.index(end) + len(end)
        if a >= z:
            raise AssertionError("independent inverse span order differs")
        old = raw[:a] + raw[z:]
        for current, prior in rule["hooks"]:
            current, prior = current.encode("utf-8"), prior.encode("utf-8")
            if old.count(current) != 1:
                raise AssertionError("independent entry hook is not unique")
            old = old.replace(current, prior, 1)
    if {"bytes": len(old), "sha256": digest(old)} != previous:
        raise AssertionError("independent whole predecessor differs: " + relative)
    return old


def _title_button_prepare():
    """Validate physical four and every inverse before opening any logical view."""
    if TITLE_BUTTON_BINDING["phase"] != "APPLIED_SOURCE_BOUND":
        raise AssertionError("private title-button candidate is not authorized")
    current = {p: (ROOT / p).read_bytes() for p in TITLE_BUTTON_BINDING["previous_pins"]}
    ci_path = "tools/ci_localization_reconciliation_self_test.py"
    for relative, raw in current.items():
        checked = _title_button_code_view(raw) if relative == ci_path else raw
        if {"bytes": len(checked), "sha256": digest(checked)} != TITLE_BUTTON_BINDING["current_pins"][relative]:
            raise AssertionError("physical title-button source differs: " + relative)
    for relative, wanted in TITLE_BUTTON_BINDING["preserved_pins"].items():
        raw = (ROOT / relative).read_bytes()
        if {"bytes": len(raw), "sha256": digest(raw)} != wanted:
            raise AssertionError("preserved physical dependency differs: " + relative)
    cases = TITLE_BUTTON_SPEC["cases"]
    if (len(cases) != 20 or len({r["id"] for r in cases}) != 20
            or digest(json.dumps(cases, ensure_ascii=False, sort_keys=True,
                                 separators=(",", ":")).encode("utf-8"))
            != TITLE_BUTTON_SPEC["cases_sha256"]):
        raise AssertionError("independent fixed20 changed")
    off = TITLE_BUTTON_BINDING["baseline_off_errors"]
    if (not isinstance(off, dict)
            or set(off) != {"public_source_errors", "chapter_source_errors", "year5_source_errors"}
            or not all(isinstance(v, list) and all(isinstance(s, str) for s in v)
                       for v in off.values())):
        raise AssertionError("ROOT first baseline OFF arrays are not bound")
    previous = {p: _title_button_inverse(raw, p) for p, raw in current.items()}
    # Reconstruct old220 without asking a projector for its own expected value.
    old220 = previous[MAIN_PATH]
    for stage in ("ORDER240", "ORDER239"):
        for row in FROZEN["patches"]:
            if row["order"] == stage:
                old220 = _replace_once(old220, row["after"], row["before"])
    if digest(old220) != ORDER220_SHA:
        raise AssertionError("independent old220 whole raw differs")
    return current, previous, old220


def _title_button_materialize(case, current, previous, inputs):
    raw, recipe = current[MAIN_PATH], case["recipe"]
    op = recipe["op"]
    if op == "baseline_whole":
        raw = previous[MAIN_PATH]
    elif op == "replace_exact":
        before, after = recipe["before"].encode("utf-8"), recipe["after"].encode("utf-8")
        if raw.count(before) != recipe["count"]:
            raise AssertionError("fixed replacement count differs")
        raw = raw.replace(before, after, recipe["count"])
    elif op == "remove_exact_suffix":
        suffix = recipe["text"].encode("utf-8")
        if raw.count(suffix) != recipe["count"] or not raw.endswith(suffix):
            raise AssertionError("fixed suffix differs")
        raw = raw[:-len(suffix)]
    elif op == "append_exact":
        text = recipe["text"].encode("utf-8")
        if ("expected_original_count" in recipe
                and raw.count(text) != recipe["expected_original_count"]):
            raise AssertionError("fixed append original count differs")
        if ("expected_original_eof_lf_count" in recipe
                and len(raw) - len(raw.rstrip(b"\n")) != recipe["expected_original_eof_lf_count"]):
            raise AssertionError("fixed original EOF differs")
        raw += text
    elif op == "replace_all_lf_with_crlf":
        if raw.count(b"\n") != recipe["lf_count"] or raw.count(b"\r") != recipe["expected_original_cr_count"]:
            raise AssertionError("fixed newline population differs")
        raw = raw.replace(b"\n", b"\r\n")
    elif op == "raw_from_case":
        raw = inputs[recipe["id"]]
    elif op not in {"approved_current_main", "current_raw_registry_mutation",
                    "current_raw_with_claim", "current_raw_with_relative"}:
        raise AssertionError("unknown frozen recipe")
    if len(raw) != case["input_bytes"] or digest(raw) != case["input_sha256"]:
        raise AssertionError("fixed materialized input differs")
    inputs[case["id"]] = raw
    return raw


@contextlib.contextmanager
def _title_button_registry(case, observation):
    registry0, seal0 = history.TITLE_BUTTON_TRANSITION, history._TITLE_BUTTON_REGISTRY_SHA256
    try:
        if case["kind"] != "registry_mutant":
            yield
        else:
            changed = copy.deepcopy(registry0)
            mutation = case["recipe"]["mutation"]
            if mutation["op"] == "set" and mutation["path"] == ["previous_sha256"]:
                changed["previous_sha256"] = mutation["value"]
            elif mutation["op"] == "remove_inverse_by_id":
                matches = [r for r in changed["inverses"] if r["id"] == mutation["id"]]
                if len(matches) != 1:
                    raise AssertionError("fixed inverse removal selector differs")
                changed["inverses"].remove(matches[0])
            elif mutation["op"] == "append_inverse_copy_by_id":
                matches = [r for r in changed["inverses"] if r["id"] == mutation["id"]]
                if len(matches) != 1:
                    raise AssertionError("fixed inverse copy selector differs")
                changed["inverses"].append(copy.deepcopy(matches[0]))
            else:
                raise AssertionError("unknown fixed registry mutation")
            resealed = digest(json.dumps(changed, ensure_ascii=False, sort_keys=True,
                                         separators=(",", ":")).encode("utf-8"))
            observation.update(original=copy.deepcopy(registry0), mutated=copy.deepcopy(changed),
                               original_checksum=seal0, recomputed_checksum=resealed,
                               checksum_recomputed=True)
            with patch.object(history, "TITLE_BUTTON_TRANSITION", changed), \
                    patch.object(history, "_TITLE_BUTTON_REGISTRY_SHA256", resealed):
                observation["installed_checksum_exact"] = history._TITLE_BUTTON_REGISTRY_SHA256 == resealed
                yield
    finally:
        observation["restored"] = (history.TITLE_BUTTON_TRANSITION is registry0
                                   and history._TITLE_BUTTON_REGISTRY_SHA256 == seal0)


def _title_button_live(case, raw, old220, observation, counts):
    project0 = history.main_game_history_project_bytes
    hash0 = history.main_game_history_project_byte_hash
    source0 = history.main_game_history_source_errors
    originals = (chapter1.order220_main_source_errors, year5.order220_main_source_errors)
    result = {}
    try:
        with contextlib.ExitStack() as stack:
            spies = (
                stack.enter_context(patch.object(chapter1, "order220_main_source_errors", wraps=originals[0])),
                stack.enter_context(patch.object(year5, "order220_main_source_errors", wraps=originals[1])),
            )
            if case["kind"] == "forged_observation":
                stack.enter_context(patch.object(history, "main_game_history_project_bytes", return_value=old220))
                stack.enter_context(patch.object(history, "main_game_history_project_byte_hash", return_value=ORDER220_SHA))
                observation["spoofed_hash"] = history.main_game_history_project_byte_hash(
                    case["claim"], case["relative"], raw)
                observation["spoofed_bytes_sha256"] = digest(
                    history.main_game_history_project_bytes(raw, case["relative"]))
            endpoints = (
                ("chapter_source_errors", chapter1._order243_main_source_errors,
                 chapter1.ORDER156_AUDITED_SOURCE_FILE_TRANSITIONS[MAIN_PATH][1]),
                ("year5_source_errors", year5._order243_main_source_errors,
                 year5.ORDER156_SOURCE_FILE_TRANSITIONS[MAIN_PATH][1]),
            )
            for name, function, registered in endpoints:
                counts[name] += 1
                try:
                    result[name] = function(case["relative"], raw, registered)
                except Exception as error:
                    result[name] = {"exception": type(error).__name__ + ": " + str(error),
                                    "traceback": _title_button_traceback.format_exc()}
            observation["downstream_call_counts"] = {"chapter": spies[0].call_count, "year5": spies[1].call_count}
    finally:
        observation["restored"] = (
            history.main_game_history_project_bytes is project0
            and history.main_game_history_project_byte_hash is hash0
            and history.main_game_history_source_errors is source0
            and chapter1.order220_main_source_errors is originals[0]
            and year5.order220_main_source_errors is originals[1])
    return result


def _title_button_case(case, raw, old9029, old220, counts):
    values, endpoint_exceptions, registry, live = {}, {}, {}, {}
    # Byte-valued returns are losslessly bound to input/old9029/old220 raw,
    # instead of repeating two megabyte-sized sources in every JSON row.
    references = {"input": raw, "old9029": old9029, "old220": old220}
    with _title_button_registry(case, registry):
        endpoints = (
            ("source_errors", lambda: history.title_button_source_errors(case["relative"], raw)),
            ("one_step_project_bytes_sha256", lambda: history.title_button_project_bytes(raw, case["relative"])),
            ("one_step_hash", lambda: history.title_button_project_byte_hash(case["claim"], case["relative"], raw)),
            ("public_source_errors", lambda: history.main_game_history_source_errors(case["relative"], raw)),
            ("public_project_bytes_sha256", lambda: history.main_game_history_project_bytes(raw, case["relative"])),
            ("public_hash", lambda: history.main_game_history_project_byte_hash(case["claim"], case["relative"], raw)),
        )
        byte_returns = {}
        for name, function in endpoints:
            counts[name] += 1
            try:
                value = function()
                if name.endswith("project_bytes_sha256"):
                    byte_returns[name] = {"bytes": len(value), "sha256": digest(value),
                                         "exact_raw_references": [p for p, v in references.items() if value == v]}
                    if not byte_returns[name]["exact_raw_references"]:
                        byte_returns[name]["unexpected_raw_base64"] = (
                            _title_button_base64.b64encode(value).decode("ascii"))
                    values[name] = digest(value)
                else:
                    values[name] = value
            except Exception as error:
                endpoint_exceptions[name] = {
                    "exception": type(error).__name__ + ": " + str(error),
                    "traceback": _title_button_traceback.format_exc()}
        values.update(_title_button_live(case, raw, old220, live, counts))
    checks = {}
    for name, wanted in case["expected"].items():
        if name in {"exceptions", "effective_negative"}:
            continue
        actual = values.get(name)
        if wanted in ("EMPTY", "NONEMPTY"):
            checks[name] = isinstance(actual, list) and all(isinstance(v, str) for v in actual) and (
                (not actual) if wanted == "EMPTY" else bool(actual))
        elif wanted == "BASELINE_OFF_EXACT":
            checks[name] = actual == TITLE_BUTTON_BINDING["baseline_off_errors"][name]
        else:
            checks[name] = actual == wanted
    checks["exceptions"] = not endpoint_exceptions and all(
        not isinstance(v, dict) or "exception" not in v for v in values.values())
    checks["raw_byte_returns"] = all(row["exact_raw_references"] for row in byte_returns.values()) and len(byte_returns) == 2
    checks["restored"] = registry.get("restored") is True and live.get("restored") is True
    if case["kind"] == "registry_mutant":
        checks["registry_resealed"] = registry.get("checksum_recomputed") is True and registry.get("installed_checksum_exact") is True
    if case["kind"] == "forged_observation":
        checks["forged_raw_authority"] = (
            live.get("spoofed_hash") == ORDER220_SHA
            and live.get("spoofed_bytes_sha256") == ORDER220_SHA
            and live.get("downstream_call_counts") == {"chapter": 0, "year5": 0})
    return {"id": case["id"], "kind": case["kind"], "base": case["base"],
            "recipe": case["recipe"], "path": case["relative"], "claim": case["claim"],
            "input": {"bytes": len(raw), "sha256": digest(raw)},
            "returns": values, "byte_return_bindings": byte_returns,
            "endpoint_exceptions": endpoint_exceptions, "checks": checks,
            "registry": registry, "live": live, "passed": all(checks.values())}


@contextlib.contextmanager
def _title_button_logical_view(previous, observation):
    """Only independently recovered bytes; real consumers and old expectations stay live."""
    read0, text0 = Path.read_bytes, Path.read_text
    api0 = (history.main_game_history_source_errors, history.main_game_history_project_bytes,
            history.main_game_history_project_byte_hash)
    stdout0, stderr0 = _title_button_sys.stdout, _title_button_sys.stderr
    reads = {p: 0 for p in previous}
    def read_bytes(path):
        for relative, raw in previous.items():
            if path == ROOT / relative:
                reads[relative] += 1
                return raw
        return read0(path)
    def read_text(path, *args, **kwargs):
        for relative, raw in previous.items():
            if path == ROOT / relative:
                reads[relative] += 1
                encoding = kwargs.get("encoding") or (args[0] if args else None) or "utf-8"
                return raw.decode(encoding, errors=kwargs.get("errors") or "strict")
        return text0(path, *args, **kwargs)
    def source(relative, raw):
        return history._TITLE_BUTTON_OLD_SOURCE_ERRORS(relative, raw)
    def project(raw, relative):
        return history._TITLE_BUTTON_OLD_PROJECT_BYTES(raw, relative)
    def observed(claim, relative, raw):
        return history._TITLE_BUTTON_OLD_PROJECT_HASH(claim, relative, raw)
    try:
        with contextlib.ExitStack() as stack:
            stack.enter_context(patch.object(Path, "read_bytes", read_bytes))
            stack.enter_context(patch.object(Path, "read_text", read_text))
            for name, function in (("main_game_history_source_errors", source),
                                   ("main_game_history_project_bytes", project),
                                   ("main_game_history_project_byte_hash", observed)):
                stack.enter_context(patch.object(history, name, function))
            yield
    finally:
        observation.update(reads=reads, restored=(
            Path.read_bytes is read0 and Path.read_text is text0
            and _title_button_sys.stdout is stdout0 and _title_button_sys.stderr is stderr0
            and (history.main_game_history_source_errors, history.main_game_history_project_bytes,
                 history.main_game_history_project_byte_hash) == api0))


def _title_button_main():
    before, after, fatal, trace = None, None, None, None
    results, inputs = [], {}
    counts = {k: 0 for k in (
        "source_errors", "one_step_project_bytes_sha256", "one_step_hash",
        "public_source_errors", "public_project_bytes_sha256", "public_hash",
        "chapter_source_errors", "year5_source_errors", "old28", "engine")}
    historical = {"passed": False, "skipped": "new fixed20 not passed", "cases": 0}
    try:
        before = _title_button_physical_pins()
        current, previous, old220 = _title_button_prepare()
        for case in TITLE_BUTTON_SPEC["cases"]:
            stdout, stderr = io.StringIO(), io.StringIO()
            with contextlib.redirect_stdout(stdout), contextlib.redirect_stderr(stderr):
                try:
                    raw = _title_button_materialize(case, current, previous, inputs)
                    row = _title_button_case(case, raw, previous[MAIN_PATH], old220, counts)
                except Exception as error:
                    row = {"id": case["id"], "kind": case["kind"], "base": case["base"],
                           "passed": False, "exception": type(error).__name__ + ": " + str(error),
                           "traceback": _title_button_traceback.format_exc()}
            row.update(stdout=stdout.getvalue(), stderr=stderr.getvalue())
            results.append(row)
        by_id = {r["id"]: r for r in results}
        normal_ok = by_id.get("current_exact", {}).get("passed") is True
        for row in results:
            row["normal_base_passed"] = row["base"] is None or by_id.get(row["base"], {}).get("passed") is True
            row["valid_result"] = bool(row["passed"] and row["normal_base_passed"]
                                       and (row["kind"] == "normal" or normal_ok))
        if len(results) == 20 and all(r["valid_result"] for r in results):
            if before != _title_button_physical_pins():
                raise AssertionError("physical inputs changed before old28")
            stdout, stderr, view = io.StringIO(), io.StringIO(), {}
            code, error, oldtrace = None, None, None
            # redirect is inside the view, so its finally can attest restoration.
            with _title_button_logical_view(previous, view):
                with contextlib.redirect_stdout(stdout), contextlib.redirect_stderr(stderr):
                    counts["old28"] += 1
                    try:
                        code = main()
                    except Exception as exc:
                        error = type(exc).__name__ + ": " + str(exc)
                        oldtrace = _title_button_traceback.format_exc()
            parsed, marker, parse_error = None, None, None
            try:
                parsed, end = json.JSONDecoder().raw_decode(stdout.getvalue())
                marker = stdout.getvalue()[end:].strip()
            except (ValueError, TypeError) as exc:
                parse_error = type(exc).__name__ + ": " + str(exc)
            logical_exact = (isinstance(parsed, dict)
                and parsed.get("input_before") == parsed.get("input_after")
                and all(parsed.get("input_before", {}).get(p) == digest(previous[p])
                        for p in (MAIN_PATH, "tools/main_game_locale_history.py",
                                  "tools/ci_localization_reconciliation_self_test.py")))
            old_ok = (code == 0 and error is None and parse_error is None
                and not stderr.getvalue() and view.get("restored") is True
                and logical_exact and parsed.get("passed") is True
                and parsed.get("cases") == 28 and len(parsed.get("results", [])) == 28
                and all(r.get("valid_result") for r in parsed["results"])
                and marker == ("CI_LOCALIZATION_RECONCILIATION_SELF_TEST_OK cases=28 expected=28 inputs="
                               + str(len(parsed["input_before"])) + " unchanged=True"))
            historical = {"scope": "old243 logical28, not current physical28", "cases": parsed.get("cases", 0) if parsed else 0,
                          "exit": code, "exception": error, "traceback": oldtrace, "parse_error": parse_error,
                          "stdout": stdout.getvalue(), "stderr": stderr.getvalue(), "marker": marker,
                          "logical_exact": logical_exact, "view": view, "passed": old_ok}
    except Exception as error:
        fatal, trace = type(error).__name__ + ": " + str(error), _title_button_traceback.format_exc()
    finally:
        try:
            after = _title_button_physical_pins()
        except Exception as error:
            fatal = (fatal or "") + "; after pins: " + type(error).__name__ + ": " + str(error)
    unchanged = before is not None and before == after
    current_ok = fatal is None and len(results) == 20 and all(r.get("valid_result") for r in results)
    passed = current_ok and historical["passed"] and unchanged
    negative_kinds = {"raw_mutant", "registry_mutant", "forged_observation"}
    print(json.dumps({"scope": "ORDER256 physical source20; old243 logical28 separate",
        "binding": TITLE_BUTTON_BINDING["provenance"], "current": {
            "cases": len(results), "results": results, "passed": current_ok,
            "valid_negative_count": sum(r["kind"] in negative_kinds and bool(r.get("valid_result")) for r in results)},
        "historical": historical, "execution_counts": counts, "fatal": fatal, "traceback": trace,
        "physical_input_before": before, "physical_input_after": after,
        "physical_inputs_unchanged": unchanged, "passed": passed,
        "limits": "Finite source contract only; not runtime, translation, native or full-product GO."},
        ensure_ascii=False, indent=2))
    print("TITLE_BUTTON_MAIN_SOURCE_SELF_TEST_" + ("OK" if passed else "FAIL")
          + f" current={len(results)}/20 historical28={historical['passed']} unchanged={unchanged}")
    return 0 if passed else 1
# END_TITLE_BUTTON_CI_SELF_256
if __name__ == "__main__":
    raise SystemExit(_title_button_main())
