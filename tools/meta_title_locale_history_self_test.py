#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Finite raw/consumer regressions for the one ORDER242 title insertion.

This is the separately frozen 18-case population, not the original ORDER243
28 or the historical ORDER220 26. It invokes the real Chapter snapshot entry
with scoped in-memory source/observed-hash injection; no full audit or collector.
"""

from __future__ import annotations

import contextlib
import hashlib
import importlib
import json
from pathlib import Path
import sys
from unittest.mock import patch

sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parents[1]
FROZEN = json.loads(r'''{
  "source_path": "autoloads/MetaProgression.gd",
  "current": {
    "bytes": 52819,
    "sha256": "5bc1465e18ae3e36ef5daef1c27dd3923d1566884e5d0545e6b00c2c7893ab58"
  },
  "historical": {
    "bytes": 49996,
    "sha256": "a36617f4979e08a37e89cecc0566a4e64d54bb5373469e2fa1e162d10dde34dc"
  },
  "insertion": {
    "start_line": 679,
    "end_line": 708,
    "bytes": 2823,
    "lines": 30,
    "sha256": "d41086a12e72eeaf72c5f17666ecc45a5bc863dad8e75c7f53bc2493df1bf694",
    "exact_text": "\t# Only these existing title fields opt into prepared-language UI lookup.\n\t# Preserve KO/EN compatibility, raw constants, and every unselected title.\n\tmatch title_id:\n\t\t\"gosiwon_survivor\":\n\t\t\tlocalized[\"name\"] = LocaleManager.ui(\"고시원 생존자\", \"Gosiwon Survivor\")\n\t\t\tlocalized[\"desc\"] = LocaleManager.ui(\"고시원에서 12개월을 버텼다. 이 경험은 잊지 못할 것이다.\", \"Survived 12 months in a gosiwon. You will not forget that room.\")\n\t\t\"first_move\":\n\t\t\tlocalized[\"name\"] = LocaleManager.ui(\"첫 이사\", \"First Move\")\n\t\t\tlocalized[\"desc\"] = LocaleManager.ui(\"처음으로 고시원을 벗어나 새 공간으로 이사했다.\", \"Left the gosiwon for the first time and moved into a new space.\")\n\t\t\"apartment_life\":\n\t\t\tlocalized[\"name\"] = LocaleManager.ui(\"아파트 입성\", \"Apartment Life\")\n\t\t\tlocalized[\"desc\"] = LocaleManager.ui(\"드디어 아파트에 살게 됐다. 경비 아저씨가 반겨준다.\", \"Finally living in an apartment. Even the security guard greets you.\")\n\t\t\"gangnam_resident\":\n\t\t\tlocalized[\"name\"] = LocaleManager.ui(\"강남 입성\", \"Gangnam Resident\")\n\t\t\tlocalized[\"desc\"] = LocaleManager.ui(\"강남 아파트. 주소만으로도 사람들의 눈빛이 달라진다.\", \"A Gangnam apartment. The address alone changes how people look at you.\")\n\t\t\"long_gosiwon\":\n\t\t\tlocalized[\"name\"] = LocaleManager.ui(\"고시원 장기거주자\", \"Long-Term Gosiwon Tenant\")\n\t\t\tlocalized[\"desc\"] = LocaleManager.ui(\"고시원 24개월. 이제 이 냄새도 집냄새처럼 느껴진다.\", \"24 months in a gosiwon. Even the smell has started to feel like home.\")\n\t\t\"first_paycheck\":\n\t\t\tlocalized[\"name\"] = LocaleManager.ui(\"첫 월급의 무게\", \"Weight of the First Paycheck\")\n\t\t\tlocalized[\"desc\"] = LocaleManager.ui(\"통장에 처음으로 월급이 찍혔다. 기쁘면서도 이상하게 허탈했다.\", \"Your first salary hit the account. It felt joyful and strangely hollow.\")\n\t\t\"one_year_worker\":\n\t\t\tlocalized[\"name\"] = LocaleManager.ui(\"1년 직장인\", \"One-Year Worker\")\n\t\t\tlocalized[\"desc\"] = LocaleManager.ui(\"같은 회사를 1년 다녔다. 어느새 선배가 돼 있었다.\", \"Stayed at the same company for a year. Somehow, you became senior to someone.\")\n\t\t\"three_year_worker\":\n\t\t\tlocalized[\"name\"] = LocaleManager.ui(\"베테랑 직장인\", \"Office Veteran\")\n\t\t\tlocalized[\"desc\"] = LocaleManager.ui(\"3년. 회사 서류함에 내 이름이 녹아들었다.\", \"Three years. Your name has seeped into the company's filing cabinets.\")\n\t\t\"long_unemployed\":\n\t\t\tlocalized[\"name\"] = LocaleManager.ui(\"백수의 자유\", \"Freedom of Unemployment\")\n\t\t\tlocalized[\"desc\"] = LocaleManager.ui(\"12개월을 무직으로 버텼다. 누군가는 백수라 하고 누군가는 자유인이라 한다.\", \"Stayed unemployed for 12 months. Some call it joblessness. Some call it freedom.\")\n"
  },
  "provenance": {
    "path": ".git/full-game-localization/order244-self-test-specification.json",
    "sha256": "b19daec06150fecf571dbc034d257c43ef9d6f463686294b267cdf1f86a49556",
    "cases_source": {
      "path": ".git/full-game-localization/order244-meta-title-history-preflight.json",
      "bytes": 16998,
      "sha256": "b5c51b34637f594755a583436d9023547b70056344a6c4c452f8c4d2916967de",
      "count": 18,
      "preserve_case_ids_recipes_expectations": true
    }
  },
  "required_preserved": {
    "tools/ci_localization_reconciliation_self_test.py": {
      "bytes": 31464,
      "sha256": "12ff8ba402154da0318565dc1b985676e6d2f679f9213c0ca8ff4f17a019ea38"
    },
    "tools/main_game_locale_history.py": {
      "bytes": 5261,
      "sha256": "268be5cdd6de2bdd36e862951d87710899889c2c53acd327408c2675f7463490"
    },
    "tools/ja_translation_pipeline.py": {
      "bytes": 234100,
      "sha256": "f761bceb5c4ad7f34816aba75cc46866b037bdbfa2ca4141becb5c17e11d1987"
    }
  },
  "cases": [
    {
      "id": "current_exact",
      "base_id": null,
      "path": "autoloads/MetaProgression.gd",
      "recipe": {
        "op": "same"
      },
      "raw_sha256": "5bc1465e18ae3e36ef5daef1c27dd3923d1566884e5d0545e6b00c2c7893ab58",
      "expect_gate_errors": false,
      "expect_projection": "old",
      "input_bytes": 52819
    },
    {
      "id": "old_whole_rollback",
      "base_id": "current_exact",
      "path": "autoloads/MetaProgression.gd",
      "recipe": {
        "op": "git_blob",
        "commit": "c2cc7fd5fe8658f59301b3a1bce7f5966dc1e3c6",
        "path": "autoloads/MetaProgression.gd"
      },
      "raw_sha256": "a36617f4979e08a37e89cecc0566a4e64d54bb5373469e2fa1e162d10dde34dc",
      "expect_gate_errors": true,
      "expect_projection": "identity",
      "input_bytes": 49996
    },
    {
      "id": "extra_lf",
      "base_id": "current_exact",
      "path": "autoloads/MetaProgression.gd",
      "recipe": {
        "op": "append",
        "value": "\n"
      },
      "raw_sha256": "fa2eff423435e0849654b4504d1de2784a770ec10432db9eb9b2fcc112ae128c",
      "expect_gate_errors": true,
      "expect_projection": "identity",
      "input_bytes": 52820
    },
    {
      "id": "wrong_path",
      "base_id": "current_exact",
      "path": "autoloads/GameState.gd",
      "recipe": {
        "op": "same"
      },
      "raw_sha256": "5bc1465e18ae3e36ef5daef1c27dd3923d1566884e5d0545e6b00c2c7893ab58",
      "expect_gate_errors": true,
      "expect_projection": "identity",
      "input_bytes": 52819
    },
    {
      "id": "case_path",
      "base_id": "current_exact",
      "path": "autoloads/metaprogression.gd",
      "recipe": {
        "op": "same"
      },
      "raw_sha256": "5bc1465e18ae3e36ef5daef1c27dd3923d1566884e5d0545e6b00c2c7893ab58",
      "expect_gate_errors": true,
      "expect_projection": "identity",
      "input_bytes": 52819
    },
    {
      "id": "selected_ko",
      "base_id": "current_exact",
      "path": "autoloads/MetaProgression.gd",
      "recipe": {
        "op": "replace_once",
        "from": "localized[\"name\"] = LocaleManager.ui(\"첫 이사\", \"First Move\")",
        "to": "localized[\"name\"] = LocaleManager.ui(\"두 번째 이사\", \"First Move\")"
      },
      "raw_sha256": "9f1545b1f6e6fd0f472070c2673c13c98125fbc5bdff7b34cec301dce96a7339",
      "expect_gate_errors": true,
      "expect_projection": "identity",
      "input_bytes": 52826
    },
    {
      "id": "selected_en",
      "base_id": "current_exact",
      "path": "autoloads/MetaProgression.gd",
      "recipe": {
        "op": "replace_once",
        "from": "localized[\"name\"] = LocaleManager.ui(\"첫 이사\", \"First Move\")",
        "to": "localized[\"name\"] = LocaleManager.ui(\"첫 이사\", \"Last Move\")"
      },
      "raw_sha256": "93ad3a6b3880dd314e8704f2869e414026b3d07887edaa95531954ee392ef755",
      "expect_gate_errors": true,
      "expect_projection": "identity",
      "input_bytes": 52818
    },
    {
      "id": "selected_id",
      "base_id": "current_exact",
      "path": "autoloads/MetaProgression.gd",
      "recipe": {
        "op": "replace_once",
        "from": "\t\t\"first_move\":\n",
        "to": "\t\t\"unknown_move\":\n"
      },
      "raw_sha256": "2e43333912bd2a46189fc9c9d53660563932a04c3943d939631c870ec53ba429",
      "expect_gate_errors": true,
      "expect_projection": "identity",
      "input_bytes": 52821
    },
    {
      "id": "selected_field",
      "base_id": "current_exact",
      "path": "autoloads/MetaProgression.gd",
      "recipe": {
        "op": "replace_once",
        "from": "localized[\"name\"] = LocaleManager.ui(\"첫 이사\", \"First Move\")",
        "to": "localized[\"desc\"] = LocaleManager.ui(\"첫 이사\", \"First Move\")"
      },
      "raw_sha256": "c61b77b0457c072ad198ff27474e8aafd5edc01a8d7a15aca813250519c18172",
      "expect_gate_errors": true,
      "expect_projection": "identity",
      "input_bytes": 52819
    },
    {
      "id": "missing_assignment",
      "base_id": "current_exact",
      "path": "autoloads/MetaProgression.gd",
      "recipe": {
        "op": "replace_once",
        "from": "\t\t\tlocalized[\"desc\"] = LocaleManager.ui(\"처음으로 고시원을 벗어나 새 공간으로 이사했다.\", \"Left the gosiwon for the first time and moved into a new space.\")\n",
        "to": ""
      },
      "raw_sha256": "7a77b4b572009aeddb5917b21939a720face3af6ba8cb2be266c491b21ad499d",
      "expect_gate_errors": true,
      "expect_projection": "identity",
      "input_bytes": 52642
    },
    {
      "id": "duplicate_insert",
      "base_id": "current_exact",
      "path": "autoloads/MetaProgression.gd",
      "recipe": {
        "op": "duplicate_exact_insertion"
      },
      "raw_sha256": "493edd80fc875099da29053e9acdea280c739c11a5ddd6018cc3f79db22f3645",
      "expect_gate_errors": true,
      "expect_projection": "identity",
      "input_bytes": 55642
    },
    {
      "id": "outside_deepcopy",
      "base_id": "current_exact",
      "path": "autoloads/MetaProgression.gd",
      "recipe": {
        "op": "replace_once",
        "from": "\tvar localized := title.duplicate(true)\n",
        "to": "\tvar localized := title.duplicate(false)\n"
      },
      "raw_sha256": "f9a964e3429911b1c4d4a28f50554440a5c5ac2a7bd5c22ee8b9c9493b368334",
      "expect_gate_errors": true,
      "expect_projection": "identity",
      "input_bytes": 52820
    },
    {
      "id": "outside_save_key",
      "base_id": "current_exact",
      "path": "autoloads/MetaProgression.gd",
      "recipe": {
        "op": "replace_once",
        "from": "\tdata[\"unlocked_titles\"] = titles\n",
        "to": "\tdata[\"unlocked_title_ids\"] = titles\n"
      },
      "raw_sha256": "d179bdba10d09bf3f41851216d1c60059fa17a96cf88d348d35e5715ef887649",
      "expect_gate_errors": true,
      "expect_projection": "identity",
      "input_bytes": 52822
    },
    {
      "id": "wrong_registered_old",
      "base_id": "current_exact",
      "path": "autoloads/MetaProgression.gd",
      "recipe": {
        "op": "same",
        "registered_previous": "0000000000000000000000000000000000000000000000000000000000000000"
      },
      "raw_sha256": "5bc1465e18ae3e36ef5daef1c27dd3923d1566884e5d0545e6b00c2c7893ab58",
      "expect_gate_errors": true,
      "expect_projection": "old",
      "note": "Pure projector validates its own raw registry, while live source_errors must reject mismatched caller historical pin.",
      "input_bytes": 52819
    },
    {
      "id": "registry_old",
      "base_id": "current_exact",
      "path": "autoloads/MetaProgression.gd",
      "recipe": {
        "op": "same",
        "fault": {
          "field": "previous_sha256",
          "value": "0000000000000000000000000000000000000000000000000000000000000000"
        }
      },
      "raw_sha256": "5bc1465e18ae3e36ef5daef1c27dd3923d1566884e5d0545e6b00c2c7893ab58",
      "expect_gate_errors": true,
      "expect_projection": "identity",
      "input_bytes": 52819
    },
    {
      "id": "registry_current",
      "base_id": "current_exact",
      "path": "autoloads/MetaProgression.gd",
      "recipe": {
        "op": "same",
        "fault": {
          "field": "current_sha256",
          "value": "0000000000000000000000000000000000000000000000000000000000000000"
        }
      },
      "raw_sha256": "5bc1465e18ae3e36ef5daef1c27dd3923d1566884e5d0545e6b00c2c7893ab58",
      "expect_gate_errors": true,
      "expect_projection": "identity",
      "input_bytes": 52819
    },
    {
      "id": "registry_inverse",
      "base_id": "current_exact",
      "path": "autoloads/MetaProgression.gd",
      "recipe": {
        "op": "same",
        "fault": {
          "field": "insertion",
          "value": "wrong insertion\n"
        }
      },
      "raw_sha256": "5bc1465e18ae3e36ef5daef1c27dd3923d1566884e5d0545e6b00c2c7893ab58",
      "expect_gate_errors": true,
      "expect_projection": "identity",
      "input_bytes": 52819
    },
    {
      "id": "forged_observation",
      "base_id": "current_exact",
      "path": "autoloads/MetaProgression.gd",
      "recipe": {
        "op": "append",
        "value": "\n",
        "claimed_sha256": "5bc1465e18ae3e36ef5daef1c27dd3923d1566884e5d0545e6b00c2c7893ab58"
      },
      "raw_sha256": "fa2eff423435e0849654b4504d1de2784a770ec10432db9eb9b2fcc112ae128c",
      "expect_gate_errors": true,
      "expect_projection": "identity",
      "expect_hash": "claim_identity",
      "input_bytes": 52820
    }
  ]
}''')


def sha256(raw: bytes) -> str:
    return hashlib.sha256(raw).hexdigest()


def input_pins() -> dict:
    paths = (
        "autoloads/MetaProgression.gd",
        "tools/meta_title_locale_history.py",
        "tools/meta_title_locale_history_self_test.py",
        "tools/chapter1_core_loop_v2_causal_ledger_check.py",
        "tools/main_game_locale_history.py",
        "tools/ci_localization_reconciliation_self_test.py",
        "tools/ja_translation_pipeline.py",
        "content/meta/chapter1_core_loop_v2_causal_ledger.json",
        "tools/chapter1_core_loop_v2_causal_debt_baseline.json",
    )
    result = {}
    for relative in paths:
        path = ROOT / relative
        try:
            raw = path.read_bytes()
        except FileNotFoundError:
            result[relative] = {"exists": False}
        else:
            result[relative] = {"bytes": len(raw), "sha256": sha256(raw)}
    return result


def materialize(case: dict, current: bytes) -> bytes:
    recipe = case["recipe"]
    operation = recipe["op"]
    block = FROZEN["insertion"]["exact_text"].encode("utf-8")
    raw = current
    if operation == "git_blob":
        # The pre-code Git blob was measured; avoid mutable Git dependencies
        # during regression by reconstructing and checking its exact bytes.
        if (recipe["path"] != FROZEN["source_path"]
                or current.count(block) != 1):
            raise AssertionError("historical fixture anchor differs")
        raw = current.replace(block, b"", 1)
    elif operation == "append":
        raw += recipe["value"].encode("utf-8")
    elif operation == "replace_once":
        before = recipe["from"].encode("utf-8")
        if current.count(before) != 1:
            raise AssertionError("frozen mutation anchor is not unique")
        raw = current.replace(before, recipe["to"].encode("utf-8"), 1)
    elif operation == "duplicate_exact_insertion":
        if current.count(block) != 1:
            raise AssertionError("frozen insertion anchor is not unique")
        raw = current.replace(block, block + block, 1)
    elif operation != "same":
        raise AssertionError("unknown frozen input recipe")
    if len(raw) != case["input_bytes"] or sha256(raw) != case["raw_sha256"]:
        raise AssertionError("materialized input differs from pre-code fixture")
    return raw


def registry_fault(history, fault: dict) -> tuple:
    row = list(history.META_TITLE_TRANSITION)
    if len(row) != 4:
        raise AssertionError("transition seam must have four fields")
    field = fault["field"]
    indexes = {"previous_sha256": 1, "current_sha256": 2, "insertion": 3}
    value = fault["value"]
    row[indexes[field]] = value.encode("utf-8") if field == "insertion" else value
    return tuple(row)


def snapshot_observation(chapter, history, raw: bytes, relative: str,
                         registered: str, claim: str,
                         force_historical_observation: bool) -> dict:
    """Run the actual narrow consumer, never replace its source/error logic."""
    original_read = Path.read_bytes
    original_digest = chapter._file_digest
    selected_path = ROOT / relative
    reads = []
    digest_reads = []

    def read_bytes(path):
        if path != selected_path:
            raise AssertionError("unexpected live snapshot raw read: " + str(path))
        reads.append(str(path.relative_to(ROOT)))
        return raw

    def observed_digest(path):
        if path != relative:
            raise AssertionError("unexpected live snapshot digest key: " + path)
        digest_reads.append(path)
        return claim

    with contextlib.ExitStack() as stack:
        stack.enter_context(patch.object(Path, "read_bytes", read_bytes))
        stack.enter_context(patch.object(chapter, "_file_digest", observed_digest))
        if force_historical_observation:
            # Same frozen raw+LF case: even a forged already-historical
            # observation must not remove the independent current-raw error.
            stack.enter_context(patch.object(
                history, "meta_title_history_project_byte_hash",
                return_value=FROZEN["historical"]["sha256"]))
        errors = chapter._audited_source_snapshot_errors({relative: registered})
    return {
        "errors": errors,
        "raw_reads": reads,
        "digest_reads": digest_reads,
        "forced_historical_hash_observation": force_historical_observation,
        "patches_restored": (
            Path.read_bytes is original_read and chapter._file_digest is original_digest),
    }


def run_case(case: dict, current: bytes, history, chapter,
             execution: dict) -> dict:
    raw = materialize(case, current)
    relative = case["path"]
    recipe = case["recipe"]
    registered = recipe.get("registered_previous", FROZEN["historical"]["sha256"])
    claim = recipe.get("claimed_sha256", sha256(raw))
    manager = contextlib.nullcontext()
    if "fault" in recipe:
        manager = patch.object(
            history, "META_TITLE_TRANSITION", registry_fault(history, recipe["fault"]))
    with manager:
        execution["source_errors"] += 1
        errors = history.meta_title_history_source_errors(relative, raw, registered)
        execution["raw_projection"] += 1
        projected = history.meta_title_history_project_bytes(raw, relative)
        execution["hash_projection"] += 1
        projected_hash = history.meta_title_history_project_byte_hash(claim, relative, raw)
        execution["chapter_snapshot_entry"] += 1
        live = snapshot_observation(
            chapter, history, raw, relative, registered, claim,
            force_historical_observation=case["id"] == "forged_observation")

    expected_projected = (
        current.replace(FROZEN["insertion"]["exact_text"].encode("utf-8"), b"", 1)
        if case["expect_projection"] == "old" else raw)
    expected_hash = (
        FROZEN["historical"]["sha256"]
        if case["expect_projection"] == "old" else claim)
    if case.get("expect_hash") == "claim_identity":
        expected_hash = claim
    expected_errors = case["expect_gate_errors"]
    checks = {
        "helper_errors": isinstance(errors, list) and bool(errors) == expected_errors,
        "raw_projection": projected == expected_projected,
        "hash_projection": projected_hash == expected_hash,
        "live_snapshot": isinstance(live["errors"], list)
        and bool(live["errors"]) == expected_errors,
        "patch_restoration": live["patches_restored"],
    }
    # The actual MP-key consumer must read raw independently of _file_digest.
    if relative == FROZEN["source_path"]:
        checks["live_raw_read"] = bool(live["raw_reads"])
    return {
        "id": case["id"], "base_id": case["base_id"],
        "kind": "normal" if case["base_id"] is None else "negative",
        "path": relative, "input_bytes": len(raw), "input_sha256": sha256(raw),
        "registered_previous": registered, "claimed_sha256": claim,
        "expected_errors": expected_errors,
        "expected_projection": case["expect_projection"],
        "helper_errors": errors,
        "projected_bytes": len(projected), "projected_sha256": sha256(projected),
        "projected_hash": projected_hash, "live_snapshot": live,
        "checks": checks, "passed": all(checks.values()),
    }


def main() -> int:
    before = input_pins()
    results = []
    fatal = None
    execution = {
        "source_errors": 0, "raw_projection": 0, "hash_projection": 0,
        "chapter_snapshot_entry": 0,
        "old243_28": 0, "old220_26": 0, "full_audit": 0,
        "collector": 0, "engine": 0,
    }
    try:
        for relative, expected in FROZEN["required_preserved"].items():
            if before.get(relative) != expected:
                raise AssertionError("preserved product pin differs: " + relative)
        current = (ROOT / FROZEN["source_path"]).read_bytes()
        if {"bytes": len(current), "sha256": sha256(current)} != FROZEN["current"]:
            raise AssertionError("current MetaProgression is not the approved raw")
        block = FROZEN["insertion"]["exact_text"].encode("utf-8")
        if (len(block) != FROZEN["insertion"]["bytes"]
                or sha256(block) != FROZEN["insertion"]["sha256"]
                or current.count(block) != 1):
            raise AssertionError("frozen insertion identity differs")
        old = current.replace(block, b"", 1)
        if {"bytes": len(old), "sha256": sha256(old)} != FROZEN["historical"]:
            raise AssertionError("whole historical raw inverse differs")
        cases = FROZEN["cases"]
        if (len(cases) != 18 or len({row["id"] for row in cases}) != 18
                or cases[0]["id"] != "current_exact"
                or any(row["base_id"] != "current_exact" for row in cases[1:])):
            raise AssertionError("frozen population or base links differ")
        history = importlib.import_module("meta_title_locale_history")
        chapter = importlib.import_module("chapter1_core_loop_v2_causal_ledger_check")
        if (chapter.EXPECTED_AUDITED_SOURCE_FILE_SHA256[FROZEN["source_path"]]
                != FROZEN["historical"]["sha256"]):
            raise AssertionError("historical Chapter registration was rewritten")
        expected_registry = (
            FROZEN["source_path"], FROZEN["historical"]["sha256"],
            FROZEN["current"]["sha256"], block)
        if history.META_TITLE_TRANSITION != expected_registry:
            raise AssertionError("production transition differs from frozen source")
        for case in cases:
            try:
                results.append(run_case(case, current, history, chapter, execution))
            except Exception as error:
                results.append({
                    "id": case["id"], "base_id": case["base_id"],
                    "error": type(error).__name__ + ": " + str(error), "passed": False})
        if history.META_TITLE_TRANSITION != expected_registry:
            raise AssertionError("production registry was not restored")
    except Exception as error:
        fatal = type(error).__name__ + ": " + str(error)
    after = input_pins()
    by_id = {row["id"]: row for row in results}
    for row in results:
        base = row.get("base_id")
        row["normal_base_passed"] = (
            base is None or bool(by_id.get(base, {}).get("passed")))
        row["valid_result"] = row["passed"] and row["normal_base_passed"]
    passed = (fatal is None and len(results) == 18
              and all(row["valid_result"] for row in results) and before == after)
    output = {
        "schema_version": 1,
        "scope": "ORDER244 one-transition MetaProgression raw history regression",
        "fixture_provenance": FROZEN["provenance"],
        "expected_cases": 18, "cases": len(results),
        "normal": 1, "linked_negatives": 17,
        "results": results, "fatal": fatal,
        "execution_counts": execution,
        "input_before": before, "input_after": after,
        "inputs_unchanged": before == after,
        "limits": "Finite raw/consumer contract only; no runtime, translation or product GO.",
        "passed": passed,
    }
    print(json.dumps(output, ensure_ascii=False, indent=2))
    print("META_TITLE_LOCALE_HISTORY_SELF_TEST_" + ("OK" if passed else "FAIL")
          + f" cases={len(results)} expected=18 inputs={len(before)} unchanged={before == after}")
    return 0 if passed else 1


if __name__ == "__main__":
    raise SystemExit(main())
