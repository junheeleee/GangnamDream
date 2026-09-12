#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Frozen current source24 and separately labelled historical244 unit18.

No full collector, runtime engine, or historical fixture rewriting. Raw authority
is checked at the actual Chapter snapshot before observing a projected hash.
"""
from __future__ import annotations

import contextlib
import copy
import dataclasses
import hashlib
import importlib
import io
import json
from pathlib import Path
import sys
from unittest.mock import patch

sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parents[1]
FROZEN = json.loads(r'''{
  "provenance": {
    "path": ".git/full-game-localization/order245-source-controls-precode.json",
    "sha256": "e632efe93da6e112f5b3952a4b05fac8f3c6d09e3bd699e1e149ed6a89deccf6",
    "chronology": "Recipes and expectations pre-code; current source and inverse pins measured after source authoring, before this self-test first execution. Initial collector NameError retained separately in order245-l1-first.json; one Path import repair is separately bound."
  },
  "source_rows20": [
    [
      "steady_youth",
      "name",
      "놓인 계단",
      "The Stairs Already There"
    ],
    [
      "steady_youth",
      "desc",
      "낯선 지름길보다 이미 놓인 계단을 골라, 한 걸음씩 올라왔다.",
      "You kept choosing the stairs already there over unfamiliar shortcuts, one step at a time."
    ],
    [
      "elite_course",
      "name",
      "오래 오른 계단",
      "The Long Climb"
    ],
    [
      "elite_course",
      "desc",
      "같은 계단을 오래 올랐다. 익숙해진 풍경만큼 지나친 갈림길도 남았다.",
      "You stayed on the same staircase for a long time. The view grew familiar, and some turnoffs slipped behind you."
    ],
    [
      "outsider_title",
      "name",
      "다른 출구",
      "Another Exit"
    ],
    [
      "outsider_title",
      "desc",
      "사람들이 몰린 방향에서 벗어나, 다른 출구를 여러 번 골랐다.",
      "More than once, you stepped away from the crowd and chose another exit."
    ],
    [
      "dangerous_dreamer",
      "name",
      "지도 밖의 길",
      "Beyond the Map"
    ],
    [
      "dangerous_dreamer",
      "desc",
      "지도에 없는 길을 오래 걸었다. 발밑이 흔들린 날에도 방향을 쉽게 바꾸지 않았다.",
      "You stayed on roads the map did not show, even on days when the ground felt uncertain."
    ],
    [
      "my_own_way",
      "name",
      "두 길 사이",
      "Between Two Roads"
    ],
    [
      "my_own_way",
      "desc",
      "이미 놓인 길과 지도 밖의 길을 오갔다. 어느 한쪽만으로는 이 5년을 설명할 수 없다.",
      "You moved between the road already laid out and the road beyond the map. Neither one alone explains these five years."
    ],
    [
      "free_spirit",
      "name",
      "비어 있던 오후",
      "An Afternoon of Your Own"
    ],
    [
      "free_spirit",
      "desc",
      "한강과 편의점, 오래 걷던 길에서 누구의 일정도 아닌 시간을 보냈다.",
      "By the Han River, at convenience stores, and on long walks, you spent time that belonged to no one else's schedule."
    ],
    [
      "seoul_love",
      "name",
      "서울에서 사랑",
      "Love in Seoul"
    ],
    [
      "seoul_love",
      "desc",
      "이 복잡한 도시에서도 사람을 좋아하게 됐다.",
      "Even in this complicated city, you came to care for someone."
    ],
    [
      "social_king_title",
      "name",
      "낯익은 자리들",
      "Familiar Seats"
    ],
    [
      "social_king_title",
      "desc",
      "서울 곳곳에 먼저 인사를 건네고 자리를 내어 주는 사람들이 생겼다.",
      "Around Seoul, people began greeting you first and making room when you arrived."
    ],
    [
      "loner_title",
      "name",
      "혼자 걷는 저녁",
      "Evenings Walked Alone"
    ],
    [
      "loner_title",
      "desc",
      "연락할 이름이 떠오르지 않는 저녁에도, 혼자 걷는 길은 어느새 익숙해졌다.",
      "Even on evenings when no one came to mind to call, walking alone had become familiar."
    ],
    [
      "stress_survivor",
      "name",
      "다음 아침",
      "The Next Morning"
    ],
    [
      "stress_survivor",
      "desc",
      "마음이 버티기 어려웠던 밤이 지나고도, 다음 아침은 왔다.",
      "A night when it was hard to hold yourself together passed, and the next morning still came."
    ]
  ],
  "cases": [
    {
      "id": "mp_current",
      "kind": "raw",
      "source": "MP",
      "base_id": null,
      "recipe": {
        "op": "same"
      },
      "expected_pass": true,
      "expected_projection": "predecessor",
      "consumer": "successor and live Chapter snapshot"
    },
    {
      "id": "ja_current",
      "kind": "raw",
      "source": "JA",
      "base_id": null,
      "recipe": {
        "op": "same"
      },
      "expected_pass": true,
      "expected_projection": "predecessor",
      "consumer": "successor raw"
    },
    {
      "id": "mp_old_rollback",
      "kind": "raw",
      "source": "MP",
      "base_id": "mp_current",
      "recipe": {
        "op": "predecessor"
      },
      "expected_pass": false,
      "expected_projection": "identity",
      "consumer": "successor and live Chapter snapshot"
    },
    {
      "id": "ja_old_rollback",
      "kind": "raw",
      "source": "JA",
      "base_id": "ja_current",
      "recipe": {
        "op": "predecessor"
      },
      "expected_pass": false,
      "expected_projection": "identity",
      "consumer": "successor raw"
    },
    {
      "id": "mp_extra_lf",
      "kind": "raw",
      "source": "MP",
      "base_id": "mp_current",
      "recipe": {
        "op": "append",
        "text": "\n"
      },
      "expected_pass": false,
      "expected_projection": "identity",
      "consumer": "successor and live Chapter snapshot"
    },
    {
      "id": "ja_extra_lf",
      "kind": "raw",
      "source": "JA",
      "base_id": "ja_current",
      "recipe": {
        "op": "append",
        "text": "\n"
      },
      "expected_pass": false,
      "expected_projection": "identity",
      "consumer": "successor raw"
    },
    {
      "id": "mp_missing_next_branch",
      "kind": "raw",
      "source": "MP",
      "base_id": "mp_current",
      "recipe": {
        "op": "delete_next_branch",
        "id": "steady_youth"
      },
      "expected_pass": false,
      "expected_projection": "identity",
      "consumer": "successor and live Chapter snapshot"
    },
    {
      "id": "mp_duplicate_next_branch",
      "kind": "raw",
      "source": "MP",
      "base_id": "mp_current",
      "recipe": {
        "op": "duplicate_next_branch",
        "id": "steady_youth"
      },
      "expected_pass": false,
      "expected_projection": "identity",
      "consumer": "successor and live Chapter snapshot"
    },
    {
      "id": "mp_wrong_next_id",
      "kind": "raw",
      "source": "MP",
      "base_id": "mp_current",
      "recipe": {
        "op": "replace_in_next",
        "before": "\t\t\"steady_youth\":\n",
        "after": "\t\t\"unowned_title\":\n",
        "count": 1
      },
      "expected_pass": false,
      "expected_projection": "identity",
      "consumer": "successor and live Chapter snapshot"
    },
    {
      "id": "mp_wrong_output_field",
      "kind": "raw",
      "source": "MP",
      "base_id": "mp_current",
      "recipe": {
        "op": "replace_in_next",
        "before": "localized[\"name\"]",
        "after": "localized[\"desc\"]",
        "count": 1
      },
      "expected_pass": false,
      "expected_projection": "identity",
      "consumer": "successor and live Chapter snapshot"
    },
    {
      "id": "mp_wrong_ko",
      "kind": "raw",
      "source": "MP",
      "base_id": "mp_current",
      "recipe": {
        "op": "replace_in_next",
        "before": "\"놓인 계단\"",
        "after": "\"놓인 계단!\"",
        "count": 1
      },
      "expected_pass": false,
      "expected_projection": "identity",
      "consumer": "successor and live Chapter snapshot"
    },
    {
      "id": "mp_wrong_en",
      "kind": "raw",
      "source": "MP",
      "base_id": "mp_current",
      "recipe": {
        "op": "replace_in_next",
        "before": "\"The Stairs Already There\"",
        "after": "\"Changed Stairs\"",
        "count": 1
      },
      "expected_pass": false,
      "expected_projection": "identity",
      "consumer": "successor and live Chapter snapshot"
    },
    {
      "id": "mp_nonlocal_rule",
      "kind": "raw",
      "source": "MP",
      "base_id": "mp_current",
      "recipe": {
        "op": "replace",
        "before": "GameState.route_orthodox >= 10",
        "after": "GameState.route_orthodox >= 11",
        "count": 1
      },
      "expected_pass": false,
      "expected_projection": "identity",
      "consumer": "successor and live Chapter snapshot"
    },
    {
      "id": "wrong_registry_current",
      "kind": "registry",
      "source": "MP",
      "base_id": "mp_current",
      "recipe": {
        "op": "registry_current",
        "value": "0000000000000000000000000000000000000000000000000000000000000000"
      },
      "expected_pass": false,
      "expected_projection": "identity",
      "consumer": "successor and live Chapter snapshot"
    },
    {
      "id": "wrong_registry_previous",
      "kind": "registry",
      "source": "MP",
      "base_id": "mp_current",
      "recipe": {
        "op": "registry_previous",
        "value": "0000000000000000000000000000000000000000000000000000000000000000"
      },
      "expected_pass": false,
      "expected_projection": "identity",
      "consumer": "successor and live Chapter snapshot"
    },
    {
      "id": "wrong_ja_inverse_marker",
      "kind": "registry",
      "source": "JA",
      "base_id": "ja_current",
      "recipe": {
        "op": "registry_span",
        "field": "start",
        "value": "# WRONG_SUCCESSOR_BEGIN\n"
      },
      "expected_pass": false,
      "expected_projection": "identity",
      "consumer": "successor raw"
    },
    {
      "id": "forged_observation",
      "kind": "raw",
      "source": "MP",
      "base_id": "mp_current",
      "recipe": {
        "op": "append",
        "text": "\n",
        "claim": "approved_current",
        "force_hash_projector_old": true
      },
      "expected_pass": false,
      "expected_projection": "identity",
      "consumer": "successor and live Chapter snapshot"
    },
    {
      "id": "ja_calls_exact",
      "kind": "calls",
      "source": "MP",
      "base_id": null,
      "recipe": {
        "op": "parse_current_MP"
      },
      "expected_pass": true,
      "expected_projection": "old242_calls_and_source",
      "consumer": "JA new20 semantic boundary"
    },
    {
      "id": "ja_call_missing",
      "kind": "calls",
      "source": "MP",
      "base_id": "ja_calls_exact",
      "recipe": {
        "op": "delete",
        "row": 0
      },
      "expected_pass": false,
      "expected_projection": "identity",
      "consumer": "JA new20 semantic boundary"
    },
    {
      "id": "ja_call_duplicate",
      "kind": "calls",
      "source": "MP",
      "base_id": "ja_calls_exact",
      "recipe": {
        "op": "duplicate",
        "row": 0
      },
      "expected_pass": false,
      "expected_projection": "identity",
      "consumer": "JA new20 semantic boundary"
    },
    {
      "id": "ja_call_wrong_owner",
      "kind": "calls",
      "source": "MP",
      "base_id": "ja_calls_exact",
      "recipe": {
        "op": "replace_call",
        "row": 0,
        "field": "function",
        "value": "wrong_owner"
      },
      "expected_pass": false,
      "expected_projection": "identity",
      "consumer": "JA new20 semantic boundary"
    },
    {
      "id": "ja_call_wrong_pair",
      "kind": "calls",
      "source": "MP",
      "base_id": "ja_calls_exact",
      "recipe": {
        "op": "replace_call",
        "row": 0,
        "field": "english",
        "value": "Changed Stairs"
      },
      "expected_pass": false,
      "expected_projection": "identity",
      "consumer": "JA new20 semantic boundary"
    },
    {
      "id": "ja_call_wrong_context",
      "kind": "calls",
      "source": "MP",
      "base_id": "ja_calls_exact",
      "recipe": {
        "op": "replace_call",
        "row": 0,
        "field": "context_id",
        "value": "ui.unowned"
      },
      "expected_pass": false,
      "expected_projection": "identity",
      "consumer": "JA new20 semantic boundary"
    },
    {
      "id": "path_OFF",
      "kind": "raw",
      "source": "MP",
      "base_id": "mp_current",
      "recipe": {
        "op": "same",
        "path": "autoloads/GameState.gd"
      },
      "expected_pass": false,
      "expected_projection": "identity",
      "consumer": "successor and live Chapter snapshot"
    }
  ],
  "baseline": {
    "autoloads/MetaProgression.gd": {
      "bytes": 52819,
      "sha256": "5bc1465e18ae3e36ef5daef1c27dd3923d1566884e5d0545e6b00c2c7893ab58"
    },
    "tools/ja_translation_pipeline.py": {
      "bytes": 234100,
      "sha256": "f761bceb5c4ad7f34816aba75cc46866b037bdbfa2ca4141becb5c17e11d1987"
    },
    "tools/chapter1_core_loop_v2_causal_ledger_check.py": {
      "bytes": 1459355,
      "sha256": "a20e52504bfa2b764e0a5ed4522dcdb19b3165ee3915d9d7fadd79cfeaaebdf9"
    },
    "tools/meta_title_locale_history.py": {
      "bytes": 6891,
      "sha256": "0c1d6d950379548c09d9f1a5faaa3749ced06465f34cd06457e9544c598a52f6"
    },
    "tools/meta_title_locale_history_self_test.py": {
      "bytes": 25211,
      "sha256": "0f00061417669ae026bd3d647156dad9a0e0b4920ee0c4414e49a5c26fdfcdf9"
    },
    "tools/ci_localization_reconciliation_self_test.py": {
      "bytes": 31464,
      "sha256": "12ff8ba402154da0318565dc1b985676e6d2f679f9213c0ca8ff4f17a019ea38"
    },
    "docs/queue_active/ORDER-245.md": {
      "bytes": 4893,
      "sha256": "4cc4e6fb8378f5c99fda07dc5cc1c3fadf1ba7dd3494a189bd26f8627c193938"
    }
  },
  "current_pins": {
    "autoloads/MetaProgression.gd": {
      "bytes": 56110,
      "sha256": "a3435ebd18cee005720a98633fa290754b23cf944b241cef25848b3cf114b7bd"
    },
    "tools/ja_translation_pipeline.py": {
      "bytes": 240183,
      "sha256": "173228d3c6641b95b8fe5f09f7696a15af2ff44f7871d01f9a0f13947458f376"
    },
    "tools/meta_title_locale_successor.py": {
      "bytes": 9828,
      "sha256": "5dc0f6ddc14ef5f427010cdebb225ce66bd25e42d9671c2889eb671b2b42cd74"
    },
    "tools/chapter1_core_loop_v2_causal_ledger_check.py": {
      "bytes": 1460248,
      "sha256": "0c8d5db6f0ad4d9d34518eaf531cc543c153b48c64efd71f05f5d33c64cc1f79"
    },
    "tools/meta_title_locale_history.py": {
      "bytes": 6891,
      "sha256": "0c1d6d950379548c09d9f1a5faaa3749ced06465f34cd06457e9544c598a52f6"
    },
    "tools/meta_title_locale_history_self_test.py": {
      "bytes": 25211,
      "sha256": "0f00061417669ae026bd3d647156dad9a0e0b4920ee0c4414e49a5c26fdfcdf9"
    },
    "tools/ci_localization_reconciliation_self_test.py": {
      "bytes": 31464,
      "sha256": "12ff8ba402154da0318565dc1b985676e6d2f679f9213c0ca8ff4f17a019ea38"
    },
    "tools/main_game_locale_history.py": {
      "bytes": 5261,
      "sha256": "268be5cdd6de2bdd36e862951d87710899889c2c53acd327408c2675f7463490"
    }
  },
  "transitions": {
    "autoloads/MetaProgression.gd": {
      "previous_sha256": "5bc1465e18ae3e36ef5daef1c27dd3923d1566884e5d0545e6b00c2c7893ab58",
      "current_sha256": "a3435ebd18cee005720a98633fa290754b23cf944b241cef25848b3cf114b7bd",
      "start": "\t\t\"steady_youth\":\n",
      "end": "\treturn localized\n",
      "include_end": false,
      "span_sha256": "db1f4a8b1326ea99b613ddc08acba3d7fafafff2e2b1b1d3c7eb630a17274d17",
      "hooks": []
    },
    "tools/ja_translation_pipeline.py": {
      "previous_sha256": "f761bceb5c4ad7f34816aba75cc46866b037bdbfa2ca4141becb5c17e11d1987",
      "current_sha256": "173228d3c6641b95b8fe5f09f7696a15af2ff44f7871d01f9a0f13947458f376",
      "start": "# BEGIN_META_TITLE_SUCCESSOR_245\n",
      "end": "# END_META_TITLE_SUCCESSOR_245\n\n\n",
      "include_end": true,
      "span_sha256": "835a74a8b33bf4fd111badc6d1457aa4f07bc33786014f69a8157aeec8c7b959",
      "hooks": [
        [
          "def _meta_title_current_stats(\n    calls: Iterable[UiCall], previous: dict[str, Any], source: Optional[str] = None,",
          "def _meta_title_current_stats(\n    calls: Iterable[UiCall], previous: dict[str, Any],"
        ],
        [
          "    historical, errors = _meta_title_ui_historical_calls(calls, source)\n    stats = dict(previous)",
          "    historical, errors = _meta_title_ui_historical_calls(calls)\n    stats = dict(previous)"
        ],
        [
          "    predecessor_calls, predecessor_source, next_title_errors = _next_meta_title_predecessor_calls(calls)\n    errors.extend(next_title_errors)\n    historical_calls, title_errors = _meta_title_ui_historical_calls(predecessor_calls, predecessor_source)\n    errors.extend(title_errors)",
          "    historical_calls, title_errors = _meta_title_ui_historical_calls(calls)\n    errors.extend(title_errors)"
        ],
        [
          "    stats, title_stat_errors = _next_meta_title_current_stats(\n        calls, predecessor_calls, predecessor_source, stats)",
          "    stats, title_stat_errors = _meta_title_current_stats(calls, stats)"
        ],
        [
          "        # Current raw is validated before the explicitly historical old20+4.\n        ui_inventory, meta_title_cases, meta_title_failures = _next_meta_title_historical_checks(ui_inventory)\n        cases += meta_title_cases\n        failures.extend(meta_title_failures)",
          "        meta_title_cases, meta_title_failures = _meta_title_inventory_self_test(ui_inventory)\n        cases += meta_title_cases\n        failures.extend(meta_title_failures)\n        retained_cases, retained_failures = _meta_title_retained_owner_self_test(ui_inventory)\n        cases += retained_cases\n        failures.extend(retained_failures)\n        # Old fixtures retain their exact pre-title population and expectations.\n        ui_inventory = _meta_title_historical_inventory(ui_inventory)"
        ]
      ]
    }
  },
  "historical_mp": {
    "bytes": 49996,
    "sha256": "a36617f4979e08a37e89cecc0566a4e64d54bb5373469e2fa1e162d10dde34dc"
  }
}''')


MP = "autoloads/MetaProgression.gd"
JA = "tools/ja_translation_pipeline.py"


def sha256(raw: bytes) -> str:
    return hashlib.sha256(raw).hexdigest()


def pin(raw: bytes) -> dict:
    return {"bytes": len(raw), "sha256": sha256(raw)}


def input_pins() -> dict:
    paths = tuple(FROZEN["current_pins"]) + (
        "tools/meta_title_locale_successor_self_test.py",
        "content/meta/chapter1_core_loop_v2_causal_ledger.json",
        "tools/chapter1_core_loop_v2_causal_debt_baseline.json",
    )
    result = {}
    for relative in paths:
        try:
            result[relative] = pin((ROOT / relative).read_bytes())
        except OSError as error:
            result[relative] = {"error": type(error).__name__ + ": " + str(error)}
    return result


def independent_inverse(raw: bytes, relative: str) -> bytes:
    """Fixture reconstruction, not the production projection under test.

    These measured span/hook constants were separately compared to declaration
    Git blobs before execution. Rejected-case expectations never call the SUT.
    """
    rule = FROZEN["transitions"][relative]
    if pin(raw) != FROZEN["current_pins"][relative]:
        raise AssertionError("fixture current raw pin differs: " + relative)
    start, end = rule["start"].encode(), rule["end"].encode()
    if raw.count(start) != 1 or raw.count(end) != 1:
        raise AssertionError("fixture span boundary is not unique")
    a = raw.index(start)
    z = raw.index(end, a) + (len(end) if rule["include_end"] else 0)
    if sha256(raw[a:z]) != rule["span_sha256"]:
        raise AssertionError("fixture span hash differs")
    old = raw[:a] + raw[z:]
    for current, previous in rule["hooks"]:
        current, previous = current.encode(), previous.encode()
        if old.count(current) != 1:
            raise AssertionError("fixture inverse hook is not unique")
        old = old.replace(current, previous, 1)
    if pin(old) != FROZEN["baseline"][relative]:
        raise AssertionError("fixture does not recover the declared predecessor")
    return old


def materialize(case: dict, current: dict, predecessor: dict) -> bytes:
    relative = MP if case["source"] == "MP" else JA
    raw = current[relative]
    recipe = case["recipe"]
    operation = recipe["op"]
    if operation == "predecessor":
        return predecessor[relative]
    if operation == "append":
        return raw + recipe["text"].encode()
    if operation in ("same", "registry_current", "registry_previous", "registry_span"):
        return raw
    rule = FROZEN["transitions"][MP]
    a = raw.index(rule["start"].encode())
    z = raw.index(rule["end"].encode(), a)
    span = raw[a:z]
    if operation in ("delete_next_branch", "duplicate_next_branch"):
        ids = list(dict.fromkeys(row[0] for row in FROZEN["source_rows20"]))
        title_id = recipe["id"]
        index = ids.index(title_id)
        start = ("\t\t" + json.dumps(title_id) + ":\n").encode()
        end = (("\t\t" + json.dumps(ids[index + 1]) + ":\n").encode()
               if index + 1 < len(ids) else rule["end"].encode())
        begin = raw.index(start, a)
        finish = raw.index(end, begin)
        branch = raw[begin:finish]
        return raw[:begin] + (branch + branch if operation == "duplicate_next_branch"
                              else b"") + raw[finish:]
    if operation in ("replace", "replace_in_next"):
        before, after = recipe["before"].encode(), recipe["after"].encode()
        count = recipe["count"]
        region = span if operation == "replace_in_next" else raw
        if count < 1 or region.count(before) < count:
            raise AssertionError("frozen mutation anchor missing")
        replaced = region.replace(before, after, count)
        if replaced == region:
            raise AssertionError("mutation must change its base")
        return raw[:a] + replaced + raw[z:] if operation == "replace_in_next" else replaced
    raise AssertionError("unknown frozen raw recipe: " + operation)


def registry_mutation(case: dict, successor):
    recipe = case["recipe"]
    if case["kind"] != "registry":
        return contextlib.nullcontext()
    registry = copy.deepcopy(successor.SUCCESSOR_TRANSITIONS)
    relative = MP if case["source"] == "MP" else JA
    fields = {"registry_current": "current_sha256",
              "registry_previous": "previous_sha256",
              "registry_span": recipe.get("field")}
    registry[relative][fields[recipe["op"]]] = recipe["value"]
    return patch.object(successor, "SUCCESSOR_TRANSITIONS", registry)


def snapshot_observation(chapter, raw: bytes, relative: str,
                         claim: str, force_old: bool) -> dict:
    """Exercise the actual Chapter snapshot, never replace the live raw gate."""
    original_read = Path.read_bytes
    original_digest = chapter._file_digest
    original_outer_hash = chapter._order245_meta_observed_hash
    reads, digest_reads = [], []

    def read_bytes(path):
        if path != ROOT / relative:
            raise AssertionError("unexpected snapshot raw read: " + str(path))
        reads.append(relative)
        return raw

    def digest(path):
        if path != relative:
            raise AssertionError("unexpected snapshot hash key: " + path)
        digest_reads.append(path)
        return claim

    with contextlib.ExitStack() as stack:
        stack.enter_context(patch.object(Path, "read_bytes", read_bytes))
        stack.enter_context(patch.object(chapter, "_file_digest", digest))
        if force_old:
            # Same frozen raw+LF mutant; a forged observation alone must never
            # remove the independently executed current-raw authority error.
            stack.enter_context(patch.object(
                chapter, "_order245_meta_observed_hash",
                return_value=FROZEN["historical_mp"]["sha256"]))
        errors = chapter._audited_source_snapshot_errors({
            relative: FROZEN["historical_mp"]["sha256"]})
    return {
        "errors": errors, "raw_reads": reads, "digest_reads": digest_reads,
        "forced_historical_hash_observation": force_old,
        "patches_restored": (
            Path.read_bytes is original_read and chapter._file_digest is original_digest
            and chapter._order245_meta_observed_hash is original_outer_hash),
        "scope": ("actual MP raw entry" if relative == MP
                  else "OFF path: general snapshot mismatch, no MP raw gate claimed"),
    }


def run_raw_case(case, current, predecessor, successor, chapter, counts):
    source_path = MP if case["source"] == "MP" else JA
    relative = case["recipe"].get("path", source_path)
    raw = materialize(case, current, predecessor)
    recipe = case["recipe"]
    claim = (FROZEN["current_pins"][source_path]["sha256"]
             if recipe.get("claim") == "approved_current" else sha256(raw))
    expected = case["expected_pass"]
    expected_raw = predecessor[source_path] if expected else raw
    expected_hash = sha256(expected_raw) if expected else claim
    registry_before = copy.deepcopy(successor.SUCCESSOR_TRANSITIONS)
    live = None
    with registry_mutation(case, successor):
        counts["source_errors"] += 1
        errors = successor.successor_source_errors(
            relative, raw, FROZEN["baseline"][source_path]["sha256"])
        counts["raw_projection"] += 1
        projected = successor.successor_project_bytes(raw, relative)
        counts["hash_projection"] += 1
        projected_hash = successor.successor_project_byte_hash(claim, relative, raw)
        if case["source"] == "MP":
            counts["chapter_snapshot_entry"] += 1
            live = snapshot_observation(
                chapter, raw, relative, claim, recipe.get("force_hash_projector_old", False))
    checks = {
        "source_errors": isinstance(errors, list) and (not errors) == expected,
        "raw_projection": projected == expected_raw,
        "hash_projection": projected_hash == expected_hash,
        "registry_restored": successor.SUCCESSOR_TRANSITIONS == registry_before,
    }
    if live is not None:
        checks["live_snapshot"] = (
            isinstance(live["errors"], list) and (not live["errors"]) == expected)
        checks["snapshot_patch_restored"] = live["patches_restored"]
        if relative == MP:
            checks["live_raw_read"] = bool(live["raw_reads"])
    return {
        "id": case["id"], "base_id": case["base_id"],
        "path": relative, "input": pin(raw), "claim": claim,
        "expected_pass": expected, "expected_projection": case["expected_projection"],
        "source_errors": errors, "projection": pin(projected),
        "projected_hash": projected_hash, "live_snapshot": live,
        "checks": checks, "passed": all(checks.values()),
    }


def run_call_case(case, calls, current, predecessor, pipeline, counts):
    keys = {row[2] for row in FROZEN["source_rows20"]}
    selected_indexes = [index for index, call in enumerate(calls) if call.korean in keys]
    # Whole MP parse also includes the five unchanged get_mastery_label calls.
    # Keep them in the predecessor population; do not filter the parser input.
    nonselected_count = len(calls) - len(selected_indexes)
    if len(calls) != 43 or len(selected_indexes) != 20 or nonselected_count != 23:
        raise AssertionError("whole MP must expose new20 plus old18 titles and mastery5")
    mutated = list(calls)
    recipe = case["recipe"]
    operation = recipe["op"]
    # Frozen row0 is the first of the new20, not old gosiwon row0.
    if operation != "parse_current_MP":
        index = selected_indexes[recipe["row"]]
        if operation == "delete":
            del mutated[index]
        elif operation == "duplicate":
            mutated.insert(index, mutated[index])
        elif operation == "replace_call":
            mutated[index] = dataclasses.replace(
                mutated[index], **{recipe["field"]: recipe["value"]})
        else:
            raise AssertionError("unknown frozen call recipe")
    mutated = tuple(mutated)
    source = current[MP].decode("utf-8")
    counts["JA_predecessor_call_contract"] += 1
    observed_calls, observed_source, errors = pipeline._next_meta_title_predecessor_calls(
        mutated, source=source)
    expected = case["expected_pass"]
    wanted_calls = (tuple(c for c in calls if c.korean not in keys) if expected else mutated)
    wanted_source = predecessor[MP].decode("utf-8") if expected else source
    checks = {
        "errors": isinstance(errors, list) and (not errors) == expected,
        "calls": tuple(observed_calls) == wanted_calls,
        "source": observed_source == wanted_source,
    }
    return {
        "id": case["id"], "base_id": case["base_id"],
        "expected_pass": expected, "expected_projection": case["expected_projection"],
        "input_calls": [dataclasses.asdict(c) for c in mutated],
        "input_source": pin(source.encode()), "errors": errors,
        "output_calls": len(observed_calls), "output_source": pin(observed_source.encode()),
        "checks": checks, "passed": all(checks.values()),
    }


def historical_old18(predecessor, chapter, history, counts) -> dict:
    """Execute unchanged old18 once in an explicitly validated logical view."""
    old_self = importlib.import_module("meta_title_locale_history_self_test")
    original_read = Path.read_bytes
    original_gate = chapter._order245_meta_source_errors
    original_hash = chapter._order245_meta_observed_hash
    reads = {MP: 0, JA: 0}
    output, stderr = io.StringIO(), io.StringIO()
    code = None
    exception = None

    def read_bytes(path):
        for relative in (MP, JA):
            if path == ROOT / relative:
                reads[relative] += 1
                return predecessor[relative]
        return original_read(path)

    def historical_observed_hash(claim, relative, raw):
        # Lookup at call time: unchanged old18 patches this history API for its
        # forged-observation case. Capturing its earlier function object would
        # silently disconnect that mock from the real Chapter reader.
        return history.meta_title_history_project_byte_hash(claim, relative, raw)

    with contextlib.ExitStack() as stack:
        stack.enter_context(patch.object(Path, "read_bytes", read_bytes))
        # Only the new outer layer is switched to the unchanged old244 APIs.
        # The old raw authority, registration, fixtures, and consumer stay live.
        stack.enter_context(patch.object(
            chapter, "_order245_meta_source_errors",
            history.meta_title_history_source_errors))
        stack.enter_context(patch.object(
            chapter, "_order245_meta_observed_hash",
            historical_observed_hash))
        stack.enter_context(contextlib.redirect_stdout(output))
        stack.enter_context(contextlib.redirect_stderr(stderr))
        counts["historical_old244_main"] += 1
        try:
            code = old_self.main()
        except Exception as error:
            exception = type(error).__name__ + ": " + str(error)
    stdout = output.getvalue()
    parsed, marker = None, None
    parse_error = None
    try:
        parsed, end = json.JSONDecoder().raw_decode(stdout)
        marker = stdout[end:].strip()
    except (ValueError, TypeError) as error:
        parse_error = type(error).__name__ + ": " + str(error)
    restored = (Path.read_bytes is original_read
                and chapter._order245_meta_source_errors is original_gate
                and chapter._order245_meta_observed_hash is original_hash)
    expected_marker = (
        "META_TITLE_LOCALE_HISTORY_SELF_TEST_OK cases=18 expected=18 "
        "inputs=9 unchanged=True")
    logical_exact = False
    if isinstance(parsed, dict):
        logical_before = parsed.get("input_before", {})
        logical_exact = (
            logical_before == parsed.get("input_after")
            and all(logical_before.get(p) == FROZEN["baseline"][p] for p in (MP, JA)))
    passed = (
        code == 0 and exception is None and parse_error is None and restored
        and stderr.getvalue() == "" and marker == expected_marker
        and isinstance(parsed, dict) and parsed.get("passed") is True
        and parsed.get("cases") == 18 and logical_exact
        and len(parsed.get("results", [])) == 18
        and all(row.get("valid_result") for row in parsed["results"]))
    return {
        "scope": "historical old244 unit only, not live current18",
        "exit": code, "exception": exception, "parse_error": parse_error,
        "stdout": stdout, "stderr": stderr.getvalue(),
        "logical_input_before": parsed.get("input_before") if parsed else None,
        "logical_input_after": parsed.get("input_after") if parsed else None,
        "logical_view_exact": logical_exact, "view_reads": reads,
        "patches_restored": restored, "cases": parsed.get("cases") if parsed else 0,
        "passed": passed,
    }


def main() -> int:
    before = input_pins()
    results = []
    historical = {"passed": False, "cases": 0, "skipped": "current contract not yet passed"}
    fatal = None
    counts = {
        "source_errors": 0, "raw_projection": 0, "hash_projection": 0,
        "chapter_snapshot_entry": 0, "parse_one_MP_source": 0,
        "JA_predecessor_call_contract": 0, "historical_old244_main": 0,
        "collector": 0, "full_audit": 0, "engine": 0,
        "old243_28": 0, "old220_26": 0,
    }
    try:
        if len(FROZEN["cases"]) != 24 or len({r["id"] for r in FROZEN["cases"]}) != 24:
            raise AssertionError("frozen24 population drifted")
        if sum(r["base_id"] is None for r in FROZEN["cases"]) != 3:
            raise AssertionError("frozen three normal bases drifted")
        for relative, expected in FROZEN["current_pins"].items():
            if before.get(relative) != expected:
                raise AssertionError("measured current/preserved input changed: " + relative)
        current = {p: (ROOT / p).read_bytes() for p in (MP, JA)}
        predecessor = {p: independent_inverse(current[p], p) for p in (MP, JA)}
        successor = importlib.import_module("meta_title_locale_successor")
        pipeline = importlib.import_module("ja_translation_pipeline")
        chapter = importlib.import_module("chapter1_core_loop_v2_causal_ledger_check")
        history = importlib.import_module("meta_title_locale_history")
        if successor.SUCCESSOR_TRANSITIONS != FROZEN["transitions"]:
            raise AssertionError("production registry differs from measured frozen binding")
        if [list(r) for r in successor.SOURCE_ROWS] != FROZEN["source_rows20"]:
            raise AssertionError("source20 KO/EN changed")
        if chapter.EXPECTED_AUDITED_SOURCE_FILE_SHA256[MP] != FROZEN["historical_mp"]["sha256"]:
            raise AssertionError("old Chapter MP registration changed")
        counts["parse_one_MP_source"] += 1
        calls, parse_errors = pipeline.parse_ui_calls(MP, current[MP].decode("utf-8"))
        if parse_errors:
            raise AssertionError("single MP literal parse errors: " + repr(parse_errors))
        for case in FROZEN["cases"]:
            try:
                if case["kind"] == "calls":
                    result = run_call_case(
                        case, calls, current, predecessor, pipeline, counts)
                else:
                    result = run_raw_case(
                        case, current, predecessor, successor, chapter, counts)
                results.append(result)
            except Exception as error:
                results.append({
                    "id": case["id"], "base_id": case["base_id"], "passed": False,
                    "error": type(error).__name__ + ": " + str(error)})
        by_id = {r["id"]: r for r in results}
        for row in results:
            base = row["base_id"]
            row["normal_base_passed"] = base is None or bool(by_id.get(base, {}).get("passed"))
            row["valid_result"] = row["passed"] and row["normal_base_passed"]
        if (len(results) == 24 and all(r["valid_result"] for r in results)
                and successor.SUCCESSOR_TRANSITIONS == FROZEN["transitions"]):
            historical = historical_old18(predecessor, chapter, history, counts)
    except Exception as error:
        fatal = type(error).__name__ + ": " + str(error)
    after = input_pins()
    current_passed = (fatal is None and len(results) == 24
                      and all(r.get("valid_result") for r in results))
    passed = current_passed and historical["passed"] and before == after
    output = {
        "schema_version": 1, "scope": "ORDER245 current24 plus validated historical18",
        "fixture_provenance": FROZEN["provenance"],
        "current": {"expected": 24, "cases": len(results), "normal": 3, "negative": 21,
                    "results": results, "passed": current_passed},
        "historical": historical, "fatal": fatal, "execution_counts": counts,
        "physical_input_before": before, "physical_input_after": after,
        "physical_inputs_unchanged": before == after,
        "limits": ("Finite static source/consumer contracts. Historical18 is a logical "
                   "predecessor view, not present-day runtime. No engine, translations, "
                   "native/render/human/full-product approval."),
        "passed": passed,
    }
    print(json.dumps(output, ensure_ascii=False, indent=2))
    print("META_TITLE_LOCALE_SUCCESSOR_SELF_TEST_" + ("OK" if passed else "FAIL")
          + f" current={len(results)}/24 historical={historical.get('cases', 0)}/18"
          + f" inputs={len(before)} unchanged={before == after}")
    return 0 if passed else 1


# BEGIN_ORDER248_A11_SELF
# Separate current248 population; all original245 functions and FROZEN stay raw.
import traceback as _a11_traceback
A11_SPEC = json.loads(r'''{
  "provenance": {
    "plan": ".git/full-game-localization/order248-source-controls-plan.json",
    "sha256": "25c84ae0b4cf3f7d2dcb3873bfa18e072c466eaafed144b589103344df2c9932",
    "cases_sha256": "d62c7e28fdf3f65ffe13a428394eb9874547713ea64954e7933a8bddb09b8414",
    "chronology": "Recipes and expectations frozen before A11 implementation. Private candidate only; no product or test execution authorized by this artifact."
  },
  "source_rows22": [
    [
      "first_investment",
      "name",
      "첫 투자",
      "First Investment"
    ],
    [
      "first_investment",
      "desc",
      "처음으로 주식을 샀다. 그날부터 매일 앱을 열게 됐다.",
      "Bought your first stock. From that day on, you opened the app every day."
    ],
    [
      "margin_called",
      "name",
      "마진콜의 교훈",
      "Lesson of the Margin Call"
    ],
    [
      "margin_called",
      "desc",
      "레버리지 포지션이 강제청산됐다. 비싼 수업료였다.",
      "A leveraged position was liquidated. An expensive lesson."
    ],
    [
      "invest_master_title",
      "name",
      "닫힌 노트북",
      "The Closed Laptop"
    ],
    [
      "invest_master_title",
      "desc",
      "새벽 시장을 지켜보다 스스로 정한 때에 화면을 닫을 수 있게 됐다.",
      "After watching the market before dawn, you learned to close the screen at the moment you had set for yourself."
    ],
    [
      "survived_broke",
      "name",
      "통장 0원 생존자",
      "Zero-Balance Survivor"
    ],
    [
      "survived_broke",
      "desc",
      "잔고가 마이너스까지 내려갔다 돌아왔다.",
      "Your balance went below zero and came back."
    ],
    [
      "first_10m_title",
      "name",
      "첫 1000만원",
      "First KRW 10M"
    ],
    [
      "first_10m_title",
      "desc",
      "현금 1000만원. 서울에서 처음으로 숨이 트이는 느낌이었다.",
      "KRW 10 million cash. For the first time in Seoul, you could breathe."
    ],
    [
      "first_100m_title",
      "name",
      "첫 1억",
      "First KRW 100M"
    ],
    [
      "first_100m_title",
      "desc",
      "총자산 1억. 뭔가 달라지는 것 같기도 하고 아닌 것 같기도 하다.",
      "KRW 100 million net worth. Something changed. Or maybe nothing did."
    ],
    [
      "five_runs_title",
      "name",
      "다섯 번의 인생",
      "Five Lives"
    ],
    [
      "five_runs_title",
      "desc",
      "다섯 번의 삶을 끝까지 살아냈다. 매번 달랐다.",
      "Lived five lives all the way through. Each one was different."
    ],
    [
      "ten_runs_title",
      "name",
      "열 번의 인생",
      "Ten Lives"
    ],
    [
      "ten_runs_title",
      "desc",
      "열 번을 살았다. 이제 이 도시의 반복되는 얼굴이 보이기 시작한다.",
      "Lived ten lives. The city's recurring patterns are starting to show."
    ],
    [
      "gangnam_dream_title",
      "name",
      "강남드림 달성자",
      "Gangnam Dream Achiever"
    ],
    [
      "gangnam_dream_title",
      "desc",
      "총자산 30억. 강남드림을 이뤘다. 다음엔 뭘 꿈꿔야 할까.",
      "KRW 3 billion net worth. You achieved the Gangnam Dream. What do you dream of next?"
    ],
    [
      "burnout_survivor",
      "name",
      "번아웃 생존자",
      "Burnout Survivor"
    ],
    [
      "burnout_survivor",
      "desc",
      "번아웃 엔딩을 경험했다. 열심히 사는 것의 대가를 배웠다.",
      "Experienced the burnout ending. You learned the price of trying too hard."
    ],
    [
      "ordinary_end_title",
      "name",
      "평범한 행복",
      "Ordinary Happiness"
    ],
    [
      "ordinary_end_title",
      "desc",
      "ordinary_life 엔딩. 평범함도 하나의 성취다.",
      "Ordinary Life ending. Even normalcy can be an achievement."
    ]
  ],
  "cases": [
    {
      "id": "mp_current",
      "kind": "raw",
      "source": "MP",
      "base_id": null,
      "recipe": {
        "op": "current_bound_raw"
      },
      "expected": "pass_project_to_245",
      "reason": "New A11 current MP must recover exact a343 predecessor and enter the actual Chapter raw gate."
    },
    {
      "id": "ja_current",
      "kind": "raw",
      "source": "JA",
      "base_id": null,
      "recipe": {
        "op": "current_bound_raw"
      },
      "expected": "pass_project_to_245",
      "reason": "New A11 JA file must recover exact 1732 predecessor; current-file authority is also consumed by the A11 call observer."
    },
    {
      "id": "mp_245_rollback",
      "kind": "raw",
      "source": "MP",
      "base_id": "mp_current",
      "recipe": {
        "op": "predecessor_245"
      },
      "expected": "reject_identity",
      "reason": "The current entry must not treat old245 as present-day approved bytes."
    },
    {
      "id": "ja_245_rollback",
      "kind": "raw",
      "source": "JA",
      "base_id": "ja_current",
      "recipe": {
        "op": "predecessor_245"
      },
      "expected": "reject_identity",
      "reason": "The second owned raw path cannot bypass the new stage."
    },
    {
      "id": "mp_244_stage_skip",
      "kind": "raw",
      "source": "MP",
      "base_id": "mp_current",
      "recipe": {
        "op": "historical_244",
        "sha256": "5bc1465e18ae3e36ef5daef1c27dd3923d1566884e5d0545e6b00c2c7893ab58"
      },
      "expected": "reject_identity",
      "reason": "Direct old244 input must not skip either current stage."
    },
    {
      "id": "mp_lf_forged_observation",
      "kind": "raw",
      "source": "MP",
      "base_id": "mp_current",
      "recipe": {
        "op": "append",
        "text": "\n",
        "claim": "approved_current",
        "force_outer_hash_to": "registered_historical_a366"
      },
      "expected": "reject_identity",
      "reason": "Same altered raw checks strict bytes and forged observed-hash resistance at the actual Chapter snapshot; the raw gate is never mocked."
    },
    {
      "id": "ja_crlf",
      "kind": "raw",
      "source": "JA",
      "base_id": "ja_current",
      "recipe": {
        "op": "replace_all_lf",
        "before": "\n",
        "after": "\r\n"
      },
      "expected": "reject_identity",
      "reason": "UTF8 text loading must not normalize unapproved raw line endings into a valid source."
    },
    {
      "id": "mp_nonlocalized_condition",
      "kind": "raw",
      "source": "MP",
      "base_id": "mp_current",
      "recipe": {
        "op": "replace_exact",
        "before": "GameState.investment_skill >= 70",
        "after": "GameState.investment_skill >= 71",
        "count": 1
      },
      "expected": "reject_identity",
      "reason": "The one text-only stage cannot authorize gameplay condition drift elsewhere."
    },
    {
      "id": "mp_path_off",
      "kind": "raw",
      "source": "MP",
      "base_id": "mp_current",
      "recipe": {
        "op": "current_bound_raw",
        "path": "autoloads/GameState.gd"
      },
      "expected": "reject_identity",
      "reason": "Off-path projector returns identity and source gate rejects; no claim that the MP-specific live raw gate ran on GameState."
    },
    {
      "id": "registry_wrong_intermediate",
      "kind": "registry",
      "source": "MP",
      "base_id": "mp_current",
      "recipe": {
        "op": "replace_new_registry_previous",
        "value": "5bc1465e18ae3e36ef5daef1c27dd3923d1566884e5d0545e6b00c2c7893ab58",
        "preserve_registry_digest": true
      },
      "expected": "reject_identity",
      "reason": "The sole new step must target a343, not skip directly to pre245; old20 registry is never mutated."
    },
    {
      "id": "registry_missing_ja_hook",
      "kind": "registry",
      "source": "JA",
      "base_id": "ja_current",
      "recipe": {
        "op": "remove_first_new_ja_inverse_hook",
        "preserve_registry_digest": true
      },
      "expected": "reject_identity",
      "reason": "Dropping a declared inverse hook must fail closed, not silently expose mixed-version JA."
    },
    {
      "id": "mp_wrong_output_field",
      "kind": "raw",
      "source": "MP",
      "base_id": "mp_current",
      "recipe": {
        "op": "replace_in_new_branch",
        "id": "first_investment",
        "before": "localized[\"name\"]",
        "after": "localized[\"desc\"]",
        "count": 1
      },
      "expected": "reject_identity",
      "reason": "ID/field structure is owned in addition to the set of prose pairs."
    },
    {
      "id": "mp_branch_order",
      "kind": "raw",
      "source": "MP",
      "base_id": "mp_current",
      "recipe": {
        "op": "swap_adjacent_new_branches",
        "ids": [
          "first_investment",
          "margin_called"
        ]
      },
      "expected": "reject_identity",
      "reason": "An equal bag of correct pairs is not the approved raw/order source."
    },
    {
      "id": "calls_with_retained_gs",
      "kind": "calls",
      "source": "MP+GS",
      "base_id": null,
      "recipe": {
        "op": "parse_current_MP_plus_raw_bound_shared_GS"
      },
      "expected": "pass_project_to_245",
      "reason": "Remove exactly new MP22, preserving old MP43 and the existing GameState shared owner/English."
    },
    {
      "id": "calls_missing",
      "kind": "calls",
      "source": "MP+GS",
      "base_id": "calls_with_retained_gs",
      "recipe": {
        "op": "delete_selected_call",
        "id": "first_investment",
        "field": "name"
      },
      "expected": "reject_identity",
      "reason": "Missing one owned field fails exact22 cardinality."
    },
    {
      "id": "calls_duplicate",
      "kind": "calls",
      "source": "MP+GS",
      "base_id": "calls_with_retained_gs",
      "recipe": {
        "op": "duplicate_selected_call",
        "id": "first_investment",
        "field": "name"
      },
      "expected": "reject_identity",
      "reason": "Duplicate one owned field fails exact22 cardinality."
    },
    {
      "id": "calls_shared_english_collision",
      "kind": "calls",
      "source": "MP+GS",
      "base_id": "calls_with_retained_gs",
      "recipe": {
        "op": "replace_selected_call",
        "id": "gangnam_dream_title",
        "field": "name",
        "attribute": "english",
        "before": "Gangnam Dream Achiever",
        "after": "Gangnam Dreamer"
      },
      "expected": "reject_identity",
      "reason": "MP and retained GS have different legitimate English arguments; a KO-global one-to-one mapping is invalid."
    },
    {
      "id": "calls_wrong_owner",
      "kind": "calls",
      "source": "MP+GS",
      "base_id": "calls_with_retained_gs",
      "recipe": {
        "op": "replace_selected_call",
        "id": "first_investment",
        "field": "name",
        "attribute": "function",
        "before": "_localized_title",
        "after": "unowned_title_function"
      },
      "expected": "reject_identity",
      "reason": "Correct prose at the wrong owner cannot supply the missing approved MP field."
    },
    {
      "id": "calls_wrong_api_context",
      "kind": "calls",
      "source": "MP+GS",
      "base_id": "calls_with_retained_gs",
      "recipe": {
        "op": "replace_selected_call_fields",
        "id": "first_investment",
        "field": "name",
        "values": {
          "api": "context",
          "context_id": "ui.meta.unowned_a11"
        }
      },
      "expected": "reject_identity",
      "reason": "The new stage owns exact rawKO legacy calls, not an unapproved context route."
    }
  ],
  "source_pair_sha256": "7f91d316e709949bb81787db51870309f30383ec7b1c751711a50e4ceb2beb54",
  "old_self": {
    "bytes": 38295,
    "sha256": "78408176dbcc94fe18a81f33e74224d493d913234bb9e20ccfa585b193559ee0"
  },
  "GS": {
    "bytes": 217568,
    "sha256": "8a40740286ff910b2a16049e2c2794cc0dc22fed5dfc78d2fc6ce458c833018d"
  },
  "shared": {
    "path": "autoloads/GameState.gd",
    "function": "get_current_title",
    "line": 3634,
    "api": "legacy",
    "context_id": "",
    "korean": "강남드림 달성자",
    "english": "Gangnam Dreamer",
    "MP_english": "Gangnam Dream Achiever",
    "freeze_basis": "Exact existing getter source was read. Its whole GS raw pin is above. This is a source-fixture literal, not an added runtime/UI call.",
    "presence_policy": "Do not require a GS row for every possible MP-only API input. The mixed normal proves that when the row is supplied it survives exactly. No invented missing-GS rejection case."
  }
}''')
A11_BINDING = json.loads(r'''{
  "phase": "APPLIED_SOURCE_BOUND",
  "current_pins": {
    "autoloads/MetaProgression.gd": {
      "bytes": 59337,
      "sha256": "afe8bda86177950ef82fb8d2eea339ae398d59534897719c9b803bacf292a1b6"
    },
    "tools/ja_translation_pipeline.py": {
      "bytes": 248524,
      "sha256": "504b5ef8707568b199df35179b1753ab25706b2004fa3d0fc0fa879b18303906"
    },
    "tools/meta_title_locale_successor.py": {
      "bytes": 18347,
      "sha256": "de4e215e3b6fbc7aa36651446bc0fc42845da580136d293a424a03b366cc88a4"
    },
    "tools/chapter1_core_loop_v2_causal_ledger_check.py": {
      "bytes": 1461039,
      "sha256": "f0284d2ff4159b0cfffd5e3888e0e736e1b6ee7f38e32f32d1009485f748682e"
    }
  },
  "independent_inverse_rules": {
    "autoloads/MetaProgression.gd": {
      "remove_spans": [
        {
          "start": "\t\t\"first_investment\":\n",
          "end": "\treturn localized\n",
          "include_end": false,
          "sha256": "d0db7f3704a135af6ed405bfba5aefb87bac41516e495af7483a8f7c4c940035"
        }
      ],
      "hooks": []
    },
    "tools/ja_translation_pipeline.py": {
      "remove_spans": [
        {
          "start": "# BEGIN_META_TITLE_SUCCESSOR_248\n",
          "end": "# END_META_TITLE_SUCCESSOR_248\n\n\n",
          "include_end": true,
          "sha256": "c3cf305eff0db369341a9e28ea2d45465295da26003b56eb5d8e3ff7b2280726"
        }
      ],
      "hooks": [
        [
          "    predecessor_calls, predecessor_source, next_title_errors = _a11_meta_title_chain_calls(calls)",
          "    predecessor_calls, predecessor_source, next_title_errors = _next_meta_title_predecessor_calls(calls)"
        ],
        [
          "    stats, title_stat_errors = _a11_meta_title_current_stats(\n        calls, predecessor_calls, predecessor_source, stats)",
          "    stats, title_stat_errors = _next_meta_title_current_stats(\n        calls, predecessor_calls, predecessor_source, stats)"
        ],
        [
          "        ui_inventory, meta_title_cases, meta_title_failures = _a11_meta_title_historical_checks(ui_inventory)",
          "        ui_inventory, meta_title_cases, meta_title_failures = _next_meta_title_historical_checks(ui_inventory)"
        ]
      ]
    },
    "tools/meta_title_locale_successor.py": {
      "remove_spans": [
        {
          "start": "\n\n# BEGIN_A11_META_TITLE_SUCCESSOR_248\n",
          "end": "# END_A11_META_TITLE_SUCCESSOR_248\n",
          "include_end": true,
          "sha256": "50709e33d1409765b90b0d0e16598ca72e073239e24e0c529e60b1a6ed222226"
        }
      ],
      "hooks": []
    },
    "tools/chapter1_core_loop_v2_causal_ledger_check.py": {
      "remove_spans": [
        {
          "start": "def _order248_meta_source_errors(\n",
          "end": "def _audited_source_snapshot_errors(\n",
          "include_end": false,
          "sha256": "b10bde21024e31f1fbbaac37bd593a415fc521ee8a71865beb9c3bd62276f9bf"
        }
      ],
      "hooks": [
        [
          "            errors.extend(_order248_meta_source_errors(\n",
          "            errors.extend(_order245_meta_source_errors(\n"
        ],
        [
          "                observed_digest = _order248_meta_observed_hash(\n",
          "                observed_digest = _order245_meta_observed_hash(\n"
        ]
      ]
    }
  },
  "production_registry": {
    "autoloads/MetaProgression.gd": {
      "previous_sha256": "a3435ebd18cee005720a98633fa290754b23cf944b241cef25848b3cf114b7bd",
      "current_sha256": "afe8bda86177950ef82fb8d2eea339ae398d59534897719c9b803bacf292a1b6",
      "start": "\t\t\"first_investment\":\n",
      "end": "\treturn localized\n",
      "include_end": false,
      "span_sha256": "d0db7f3704a135af6ed405bfba5aefb87bac41516e495af7483a8f7c4c940035",
      "hooks": []
    },
    "tools/ja_translation_pipeline.py": {
      "previous_sha256": "173228d3c6641b95b8fe5f09f7696a15af2ff44f7871d01f9a0f13947458f376",
      "current_sha256": "504b5ef8707568b199df35179b1753ab25706b2004fa3d0fc0fa879b18303906",
      "start": "# BEGIN_META_TITLE_SUCCESSOR_248\n",
      "end": "# END_META_TITLE_SUCCESSOR_248\n\n\n",
      "include_end": true,
      "span_sha256": "c3cf305eff0db369341a9e28ea2d45465295da26003b56eb5d8e3ff7b2280726",
      "hooks": [
        [
          "    predecessor_calls, predecessor_source, next_title_errors = _a11_meta_title_chain_calls(calls)",
          "    predecessor_calls, predecessor_source, next_title_errors = _next_meta_title_predecessor_calls(calls)"
        ],
        [
          "    stats, title_stat_errors = _a11_meta_title_current_stats(\n        calls, predecessor_calls, predecessor_source, stats)",
          "    stats, title_stat_errors = _next_meta_title_current_stats(\n        calls, predecessor_calls, predecessor_source, stats)"
        ],
        [
          "        ui_inventory, meta_title_cases, meta_title_failures = _a11_meta_title_historical_checks(ui_inventory)",
          "        ui_inventory, meta_title_cases, meta_title_failures = _next_meta_title_historical_checks(ui_inventory)"
        ]
      ]
    }
  },
  "binding_provenance": {
    "kind": "observed_applied_source4",
    "source4_patch": {
      "path": ".git/full-game-localization/order248-source4-private.patch",
      "bytes": 24921,
      "sha256": "6d86175f11d3450b4573271a5168e8c73fab1ab7dae2c2a45b63edb7fbf0f80f"
    },
    "source4_binding": {
      "path": ".git/full-game-localization/order248-source4-private-binding.json",
      "bytes": 10952,
      "sha256": "a612dc8f89481bf00b9372c2f852622e9d3c2b8ca2ab661e74f60bb40e887392"
    },
    "actual_applied_pins": {
      "autoloads/MetaProgression.gd": {
        "bytes": 59337,
        "sha256": "afe8bda86177950ef82fb8d2eea339ae398d59534897719c9b803bacf292a1b6"
      },
      "tools/ja_translation_pipeline.py": {
        "bytes": 248524,
        "sha256": "504b5ef8707568b199df35179b1753ab25706b2004fa3d0fc0fa879b18303906"
      },
      "tools/meta_title_locale_successor.py": {
        "bytes": 18347,
        "sha256": "de4e215e3b6fbc7aa36651446bc0fc42845da580136d293a424a03b366cc88a4"
      },
      "tools/chapter1_core_loop_v2_causal_ledger_check.py": {
        "bytes": 1461039,
        "sha256": "f0284d2ff4159b0cfffd5e3888e0e736e1b6ee7f38e32f32d1009485f748682e"
      }
    },
    "static_inverse4_exact": true,
    "source_rows22_sha256": "7f91d316e709949bb81787db51870309f30383ec7b1c751711a50e4ceb2beb54",
    "registry_sha256": "c2607093a0cc3fe0ab4c44d926d891f519347bc0b6e0134d1a4298a8d8e71ef2",
    "execution_gate": "ROOT authorized self application after actual source4 readback. APPLIED_SOURCE_BOUND enables the unchanged checks; all first QA/test executions remain ROOT-owned.",
    "actual_observation": {
      "declaration_head": "58a00c874acaa0faefed09084767793b70903b50",
      "declaration_tree": "fd9cdc720a34f16c8211c25fbf844de113352aa3",
      "source4_bytes_sha256_equal_private_candidate": true,
      "observer": "Plato",
      "method": "RO wc and SHA-256 of all four actual applied paths before self application; no repo import or test.",
      "test_execution": 0
    }
  }
}''')
_A11_SOURCE_PATHS = (
    MP, JA, "tools/meta_title_locale_successor.py",
    "tools/chapter1_core_loop_v2_causal_ledger_check.py",
)
_A11_SELF = "tools/meta_title_locale_successor_self_test.py"
_A11_GS = "autoloads/GameState.gd"


def _a11_canonical(value):
    return json.dumps(value, ensure_ascii=False, sort_keys=True,
                      separators=(",", ":")).encode("utf-8")


def _a11_physical_inputs():
    paths = set(FROZEN["current_pins"]) | set(_A11_SOURCE_PATHS) | {
        _A11_SELF, _A11_GS,
        "content/meta/chapter1_core_loop_v2_causal_ledger.json",
        "tools/chapter1_core_loop_v2_causal_debt_baseline.json",
    }
    return {relative: pin((ROOT / relative).read_bytes()) for relative in sorted(paths)}


def _a11_inverse_file(raw, relative):
    """Independent fixture inverse rules; never obtain expected bytes from SUT."""
    if relative == _A11_SELF:
        # No self-referential SHA inside the inserted block. Its full actual
        # hash belongs to the external code binding; old raw is checked here.
        start = b"# BEGIN_ORDER248_A11_SELF\n"
        end = b"# END_ORDER248_A11_SELF\n\n\n"
        if raw.count(start) != 1 or raw.count(end) != 1:
            raise AssertionError("nonunique248 self insertion")
        a, z = raw.index(start), raw.index(end) + len(end)
        old = raw[:a] + raw[z:]
        now = b"raise SystemExit(_a11_main())"
        if old.count(now) != 1:
            raise AssertionError("nonunique248 CLI hook")
        old = old.replace(now, b"raise SystemExit(main())", 1)
        if pin(old) != A11_SPEC["old_self"]:
            raise AssertionError("old11 functions/FROZEN/whole self raw changed")
        return old
    rule = A11_BINDING["independent_inverse_rules"][relative]
    wanted = FROZEN["current_pins"][relative]
    current = raw
    for span in rule["remove_spans"]:
        start, end = span["start"].encode(), span["end"].encode()
        if current.count(start) != 1 or current.count(end) != 1:
            raise AssertionError("nonunique independent248 inverse span: " + relative)
        begin = current.index(start)
        finish = current.index(end, begin) + (len(end) if span["include_end"] else 0)
        deleted = current[begin:finish]
        if sha256(deleted) != span["sha256"]:
            raise AssertionError("independent248 span pin differs: " + relative)
        if relative == MP:
            if deleted != _a11_mp_span():
                raise AssertionError("independent248 exact22 ID/field/order differs")
        current = current[:begin] + current[finish:]
    for now, old in rule["hooks"]:
        now, old = now.encode(), old.encode()
        if current.count(now) != 1:
            raise AssertionError("nonunique independent248 inverse hook: " + relative)
        current = current.replace(now, old, 1)
    if pin(current) != wanted:
        raise AssertionError("independent248 inverse does not recover245: " + relative)
    return current


def _a11_mp_span():
    lines, previous = [], None
    for title_id, field, ko, en in A11_SPEC["source_rows22"]:
        if title_id != previous:
            lines.append("\t\t" + json.dumps(title_id) + ":\n")
            previous = title_id
        lines.append("\t\t\tlocalized[" + json.dumps(field) + "] = LocaleManager.ui("
                     + json.dumps(ko, ensure_ascii=False) + ", "
                     + json.dumps(en, ensure_ascii=False) + ")\n")
    return "".join(lines).encode("utf-8")


def _a11_branch_bounds(raw, title_id):
    span = _a11_mp_span()
    if raw.count(span) != 1:
        raise AssertionError("approved A11 MP span missing/duplicate in fixture")
    ids = list(dict.fromkeys(r[0] for r in A11_SPEC["source_rows22"]))
    first = raw.index(span)
    marker = ("\t\t" + json.dumps(title_id) + ":\n").encode()
    start = raw.index(marker, first, first + len(span))
    at = ids.index(title_id)
    end = (raw.index(("\t\t" + json.dumps(ids[at + 1]) + ":\n").encode(), start)
           if at + 1 < len(ids) else first + len(span))
    return start, end


def _a11_materialize(case, current, old245):
    relative = MP if case["source"] == "MP" else JA
    raw, recipe = current[relative], case["recipe"]
    op = recipe["op"]
    if op in ("current_bound_raw", "replace_new_registry_previous",
              "remove_first_new_ja_inverse_hook"):
        return raw
    if op == "predecessor_245":
        return old245[relative]
    if op == "historical_244":
        old = independent_inverse(old245[MP], MP)
        if sha256(old) != recipe["sha256"]:
            raise AssertionError("separately frozen historical244 pin differs")
        return old
    if op == "append":
        return raw + recipe["text"].encode()
    if op == "replace_all_lf":
        if b"\r" in raw or b"\n" not in raw:
            raise AssertionError("CRLF mutation base is not original LF-only")
        return raw.replace(recipe["before"].encode(), recipe["after"].encode())
    if op == "replace_exact":
        before, after = recipe["before"].encode(), recipe["after"].encode()
        if raw.count(before) != recipe["count"] or before == after:
            raise AssertionError("nonlocal mutation anchor drift")
        return raw.replace(before, after, recipe["count"])
    if op == "replace_in_new_branch":
        start, end = _a11_branch_bounds(raw, recipe["id"])
        branch = raw[start:end]
        before, after = recipe["before"].encode(), recipe["after"].encode()
        if branch.count(before) != recipe["count"] or before == after:
            raise AssertionError("new-field mutation anchor drift")
        return raw[:start] + branch.replace(before, after, recipe["count"]) + raw[end:]
    if op == "swap_adjacent_new_branches":
        a, b = _a11_branch_bounds(raw, recipe["ids"][0])
        c, d = _a11_branch_bounds(raw, recipe["ids"][1])
        if b != c:
            raise AssertionError("fixed A11 branches are not adjacent")
        return raw[:a] + raw[c:d] + raw[a:b] + raw[d:]
    raise AssertionError("unknown frozen248 raw recipe: " + op)


def _a11_registry_context(case, successor):
    if case["kind"] != "registry":
        return contextlib.nullcontext()
    registry = copy.deepcopy(successor.A11_TRANSITIONS)
    if case["recipe"]["op"] == "replace_new_registry_previous":
        registry[MP]["previous_sha256"] = case["recipe"]["value"]
    else:
        if not registry[JA]["hooks"]:
            raise AssertionError("fixed missing-hook recipe requires a real new JA hook")
        del registry[JA]["hooks"][0]
    return patch.object(successor, "A11_TRANSITIONS", registry)


def _a11_snapshot(chapter, raw, claim, force_old, counts):
    real_read, real_digest = Path.read_bytes, chapter._file_digest
    real_hash = chapter._order248_meta_observed_hash
    reads, hashes = [], []

    def read_bytes(path):
        if path == ROOT / MP:
            reads.append(MP)
            return raw
        return real_read(path)

    def digest(relative):
        if relative == MP:
            hashes.append(relative)
            return claim
        return real_digest(relative)

    with contextlib.ExitStack() as stack:
        stack.enter_context(patch.object(Path, "read_bytes", read_bytes))
        stack.enter_context(patch.object(chapter, "_file_digest", digest))
        if force_old:
            stack.enter_context(patch.object(
                chapter, "_order248_meta_observed_hash",
                return_value=FROZEN["historical_mp"]["sha256"]))
        counts["Chapter_actual_snapshot"] += 1
        errors = chapter._audited_source_snapshot_errors({
            MP: FROZEN["historical_mp"]["sha256"]})
    return {
        "errors": errors, "raw_reads": reads, "hash_reads": hashes,
        "forced_observation": force_old,
        "restored": (Path.read_bytes is real_read
                     and chapter._file_digest is real_digest
                     and chapter._order248_meta_observed_hash is real_hash),
    }


def _a11_current_calls(pipeline, current, counts):
    counts["parse_one_MP"] += 1
    parsed, errors = pipeline.parse_ui_calls(MP, current[MP].decode("utf-8"))
    if errors:
        raise AssertionError("current MP literal parse errors: " + repr(errors))
    # Complete MP: prior38 title calls + mastery5 + new22; never pre-filter it.
    keys = {r[2] for r in A11_SPEC["source_rows22"]}
    selected = [c for c in parsed if (c.path, c.function) == (MP, "_localized_title")
                and c.korean in keys]
    if len(parsed) != 65 or len(selected) != 22:
        raise AssertionError("current literal count differs from planned65/22; preserve first result")
    gs = (ROOT / _A11_GS).read_bytes()
    if pin(gs) != A11_SPEC["GS"]:
        raise AssertionError("retained GS source raw changed")
    shared = A11_SPEC["shared"]
    literal = ('\tif total >= 3_000_000_000: return LocaleManager.ui('
               '"강남드림 달성자", "Gangnam Dreamer")')
    lines = gs.decode("utf-8").splitlines()
    if lines.count(literal) != 1 or lines[shared["line"] - 1] != literal:
        raise AssertionError("frozen retained GS shared owner literal/line drift")
    retained = pipeline.UiCall(**{key: shared[key] for key in (
        "path", "function", "line", "api", "korean", "english", "context_id")})
    return tuple(parsed) + (retained,)


def _a11_raw_case(case, current, old245, calls, successor, pipeline, chapter, counts):
    relative = MP if case["source"] == "MP" else JA
    path = case["recipe"].get("path", relative)
    raw = _a11_materialize(case, current, old245)
    expected = case["base_id"] is None
    claim = (sha256(current[relative]) if case["recipe"].get("claim") == "approved_current"
             else sha256(raw))
    original_registry = copy.deepcopy(successor.A11_TRANSITIONS)
    live, ja_view = None, None
    with _a11_registry_context(case, successor):
        counts["A11_source_errors"] += 1
        errors = successor.a11_source_errors(path, raw, FROZEN["current_pins"][relative]["sha256"])
        counts["A11_raw_projection"] += 1
        projected = successor.a11_project_bytes(raw, path)
        counts["A11_hash_projection"] += 1
        observed_hash = successor.a11_project_byte_hash(claim, path, raw)
        if relative == MP and path == MP:
            live = _a11_snapshot(chapter, raw, claim,
                                 bool(case["recipe"].get("force_outer_hash_to")), counts)
        if relative == JA:
            original_read = Path.read_bytes

            def read_bytes(p):
                return raw if p == ROOT / JA else original_read(p)

            with patch.object(Path, "read_bytes", read_bytes):
                counts["A11_JA_call_contract"] += 1
                out_calls, out_source, ja_errors = pipeline._a11_meta_title_predecessor_calls(
                    calls, source=current[MP].decode("utf-8"))
            wanted_calls = _a11_without_new_calls(calls) if expected else calls
            wanted_source = old245[MP].decode("utf-8") if expected else current[MP].decode("utf-8")
            ja_view = {
                "errors": ja_errors, "output_calls": len(out_calls),
                "source": pin(out_source.encode("utf-8")),
                "passed": (isinstance(ja_errors, list) and (not ja_errors) == expected
                           and tuple(out_calls) == wanted_calls and out_source == wanted_source
                           and Path.read_bytes is original_read),
            }
    wanted = old245[relative] if expected else raw
    checks = {
        "source_errors": isinstance(errors, list) and (not errors) == expected,
        "raw_projection": projected == wanted,
        "hash_projection": observed_hash == (sha256(wanted) if expected else claim),
        "registry_restored": successor.A11_TRANSITIONS == original_registry,
    }
    if live is not None:
        checks["live_raw_gate"] = (isinstance(live["errors"], list)
                                  and (not live["errors"]) == expected
                                  and bool(live["raw_reads"]) and live["restored"])
    if ja_view is not None:
        checks["JA_current_file_gate"] = ja_view["passed"]
    return {
        "id": case["id"], "base_id": case["base_id"], "path": path,
        "input": pin(raw), "claim": claim, "source_errors": errors,
        "projection": pin(projected), "projected_hash": observed_hash,
        "live_snapshot": live, "JA_observation": ja_view,
        "checks": checks, "passed": all(checks.values()),
    }


def _a11_without_new_calls(calls):
    keys = {r[2] for r in A11_SPEC["source_rows22"]}
    return tuple(c for c in calls if not (
        (c.path, c.function) == (MP, "_localized_title") and c.korean in keys))


def _a11_call_case(case, calls, current, old245, pipeline, counts):
    recipe, mutated = case["recipe"], list(calls)
    expected = case["base_id"] is None
    if not expected:
        ko = next(r[2] for r in A11_SPEC["source_rows22"]
                  if (r[0], r[1]) == (recipe["id"], recipe["field"]))
        indices = [i for i, c in enumerate(mutated)
                   if (c.path, c.function, c.korean) == (MP, "_localized_title", ko)]
        if len(indices) != 1:
            raise AssertionError("semantic mutant base selector is not exact1")
        index = indices[0]
        if recipe["op"] == "delete_selected_call":
            del mutated[index]
        elif recipe["op"] == "duplicate_selected_call":
            mutated.insert(index, mutated[index])
        elif recipe["op"] == "replace_selected_call":
            if getattr(mutated[index], recipe["attribute"]) != recipe["before"]:
                raise AssertionError("semantic before value drift")
            mutated[index] = dataclasses.replace(
                mutated[index], **{recipe["attribute"]: recipe["after"]})
        elif recipe["op"] == "replace_selected_call_fields":
            mutated[index] = dataclasses.replace(mutated[index], **recipe["values"])
        else:
            raise AssertionError("unknown frozen248 call recipe")
    mutated = tuple(mutated)
    source = current[MP].decode("utf-8")
    counts["A11_JA_call_contract"] += 1
    out_calls, out_source, errors = pipeline._a11_meta_title_predecessor_calls(mutated, source)
    wanted_calls = _a11_without_new_calls(calls) if expected else mutated
    wanted_source = old245[MP].decode("utf-8") if expected else source
    checks = {
        "errors": isinstance(errors, list) and (not errors) == expected,
        "calls_exact": tuple(out_calls) == wanted_calls,
        "source_exact": out_source == wanted_source,
        "retained_GS": (calls[-1] in out_calls if expected else True),
    }
    return {
        "id": case["id"], "base_id": case["base_id"],
        "input_calls": [dataclasses.asdict(c) for c in mutated],
        "input_source": pin(source.encode()), "errors": errors,
        "output_calls": [dataclasses.asdict(c) for c in out_calls],
        "output_source": pin(out_source.encode()),
        "checks": checks, "passed": all(checks.values()),
    }


def _a11_historical245(old245, chapter, counts):
    """Original24 then its own18, not another copy or current runtime claim."""
    original_read, original_text = Path.read_bytes, Path.read_text
    original_gate = chapter._order248_meta_source_errors
    original_hash = chapter._order248_meta_observed_hash
    reads = {path: 0 for path in old245}
    stdout, stderr = io.StringIO(), io.StringIO()
    exception, exit_code = None, None

    def read_bytes(path):
        for relative, raw in old245.items():
            if path == ROOT / relative:
                reads[relative] += 1
                return raw
        return original_read(path)

    def read_text(path, *args, **kwargs):
        for relative, raw in old245.items():
            if path == ROOT / relative:
                reads[relative] += 1
                encoding = kwargs.get("encoding") or (args[0] if args else None) or "utf-8"
                return raw.decode(encoding, errors=kwargs.get("errors") or "strict")
        return original_text(path, *args, **kwargs)

    def gate(relative, raw, registered):
        return chapter._order245_meta_source_errors(relative, raw, registered)

    def observed_hash(claim, relative, raw):
        # Dynamic lookup is essential for the preserved24/18 forged-hash mocks.
        return chapter._order245_meta_observed_hash(claim, relative, raw)

    with contextlib.ExitStack() as stack:
        stack.enter_context(patch.object(Path, "read_bytes", read_bytes))
        stack.enter_context(patch.object(Path, "read_text", read_text))
        stack.enter_context(patch.object(chapter, "_order248_meta_source_errors", gate))
        stack.enter_context(patch.object(chapter, "_order248_meta_observed_hash", observed_hash))
        stack.enter_context(contextlib.redirect_stdout(stdout))
        stack.enter_context(contextlib.redirect_stderr(stderr))
        counts["historical245_main"] += 1
        try:
            exit_code = main()
        except Exception as error:
            exception = type(error).__name__ + ": " + str(error)
    restored = (Path.read_bytes is original_read and Path.read_text is original_text
                and chapter._order248_meta_source_errors is original_gate
                and chapter._order248_meta_observed_hash is original_hash)
    parsed, marker, parse_error = None, None, None
    try:
        parsed, end = json.JSONDecoder().raw_decode(stdout.getvalue())
        marker = stdout.getvalue()[end:].strip()
    except (TypeError, ValueError) as error:
        parse_error = type(error).__name__ + ": " + str(error)
    expected_marker = (
        "META_TITLE_LOCALE_SUCCESSOR_SELF_TEST_OK current=24/24 historical=18/18"
        + f" inputs={len(FROZEN['current_pins']) + 3} unchanged=True")
    logical = {}
    if isinstance(parsed, dict):
        logical = parsed.get("physical_input_before", {})
    logical_exact = (isinstance(parsed, dict)
                     and logical == parsed.get("physical_input_after")
                     and all(logical.get(p) == pin(raw) for p, raw in old245.items()))
    passed = (
        exit_code == 0 and exception is None and parse_error is None and restored
        and stderr.getvalue() == "" and marker == expected_marker
        and isinstance(parsed, dict) and parsed.get("passed") is True and logical_exact
        and parsed.get("current", {}).get("cases") == 24
        and len(parsed.get("current", {}).get("results", [])) == 24
        and all(r.get("valid_result") for r in parsed["current"]["results"])
        and parsed.get("historical", {}).get("cases") == 18
        and parsed.get("historical", {}).get("passed") is True)
    return {
        "scope": "logical245 old24, containing its unchanged logical244 old18",
        "exit": exit_code, "exception": exception, "parse_error": parse_error,
        "stdout": stdout.getvalue(), "stderr": stderr.getvalue(),
        "logical_input_before": logical,
        "logical_input_after": parsed.get("physical_input_after") if parsed else None,
        "logical_exact": logical_exact, "view_reads": reads, "restored": restored,
        "current_named_by_old_report": "Its 'current' and 'physical' fields refer to the explicitly projected245 view, not actual248 bytes.",
        "cases": parsed.get("current", {}).get("cases", 0) if parsed else 0,
        "nested_historical_cases": parsed.get("historical", {}).get("cases", 0) if parsed else 0,
        "passed": passed,
    }


def _a11_main():
    before, after = None, None
    results = []
    historical = {"passed": False, "cases": 0, "nested_historical_cases": 0,
                  "skipped": "new248 current contract has not passed"}
    fatal, fatal_traceback, counts = None, None, {
        "A11_source_errors": 0, "A11_raw_projection": 0, "A11_hash_projection": 0,
        "A11_JA_call_contract": 0,
        "Chapter_actual_snapshot": 0, "parse_one_MP": 0,
        "historical245_main": 0, "collector": 0, "engine": 0,
    }
    try:
        before = _a11_physical_inputs()
        if A11_BINDING["phase"] != "APPLIED_SOURCE_BOUND":
            raise AssertionError("private248 binding is not an applied/approved source")
        if sha256(_a11_canonical(A11_SPEC["cases"])) != A11_SPEC["provenance"]["cases_sha256"]:
            raise AssertionError("pre-code19 recipe/expectation drift")
        if len(A11_SPEC["cases"]) != 19 or len({r["id"] for r in A11_SPEC["cases"]}) != 19:
            raise AssertionError("frozen248 population drift")
        if sum(r["base_id"] is None for r in A11_SPEC["cases"]) != 3:
            raise AssertionError("frozen248 normal3 drift")
        for relative in _A11_SOURCE_PATHS:
            if before.get(relative) != A11_BINDING["current_pins"][relative]:
                raise AssertionError("actual248 source pin mismatch: " + relative)
        for relative, expected in FROZEN["current_pins"].items():
            if relative not in _A11_SOURCE_PATHS and before.get(relative) != expected:
                raise AssertionError("preserved old source changed: " + relative)
        if before.get(_A11_GS) != A11_SPEC["GS"]:
            raise AssertionError("retained shared GameState source changed")
        current = {p: (ROOT / p).read_bytes() for p in _A11_SOURCE_PATHS}
        current[_A11_SELF] = (ROOT / _A11_SELF).read_bytes()
        old245 = {p: _a11_inverse_file(raw, p) for p, raw in current.items()}
        successor = importlib.import_module("meta_title_locale_successor")
        pipeline = importlib.import_module("ja_translation_pipeline")
        chapter = importlib.import_module("chapter1_core_loop_v2_causal_ledger_check")
        if successor.A11_TRANSITIONS != A11_BINDING["production_registry"]:
            raise AssertionError("new248 registry differs from independent binding")
        if [list(r) for r in successor.A11_SOURCE_ROWS] != A11_SPEC["source_rows22"]:
            raise AssertionError("new22 source contract drift")
        if successor.SUCCESSOR_TRANSITIONS != FROZEN["transitions"]:
            raise AssertionError("original245 registry changed")
        if [list(r) for r in successor.SOURCE_ROWS] != FROZEN["source_rows20"]:
            raise AssertionError("original20 rows changed")
        calls = _a11_current_calls(pipeline, current, counts)
        for case in A11_SPEC["cases"]:
            stdout, stderr = io.StringIO(), io.StringIO()
            with contextlib.redirect_stdout(stdout), contextlib.redirect_stderr(stderr):
                try:
                    if case["kind"] == "calls":
                        result = _a11_call_case(case, calls, current, old245, pipeline, counts)
                    else:
                        result = _a11_raw_case(case, current, old245, calls,
                                              successor, pipeline, chapter, counts)
                except Exception as error:
                    result = {"id": case["id"], "base_id": case["base_id"],
                              "passed": False, "exception": type(error).__name__ + ": " + str(error),
                              "traceback": _a11_traceback.format_exc()}
            result["stdout"], result["stderr"] = stdout.getvalue(), stderr.getvalue()
            results.append(result)
        by_id = {r["id"]: r for r in results}
        all_normal_passed = all(
            by_id.get(c["id"], {}).get("passed")
            for c in A11_SPEC["cases"] if c["base_id"] is None)
        for row in results:
            row["normal_base_passed"] = (row["base_id"] is None
                                        or bool(by_id.get(row["base_id"], {}).get("passed")))
            row["all_three_normals_passed"] = all_normal_passed
            row["valid_result"] = (row["passed"] and row["normal_base_passed"]
                                   and (row["base_id"] is None or all_normal_passed))
        if len(results) == 19 and all(r["valid_result"] for r in results):
            if before != _a11_physical_inputs():
                raise AssertionError("physical input drift before historical view")
            historical = _a11_historical245(old245, chapter, counts)
    except Exception as error:
        fatal = type(error).__name__ + ": " + str(error)
        fatal_traceback = _a11_traceback.format_exc()
    finally:
        try:
            after = _a11_physical_inputs()
        except Exception as error:
            fatal = (fatal or "") + "; post pins: " + type(error).__name__ + ": " + str(error)
    current_passed = (fatal is None and len(results) == 19
                      and all(r.get("valid_result") for r in results))
    unchanged = before is not None and after is not None and before == after
    passed = current_passed and historical["passed"] and unchanged
    output = {
        "scope": "ORDER248 current19 plus separately labelled historical24524/24418",
        "provenance": A11_SPEC["provenance"], "binding": A11_BINDING["binding_provenance"],
        "current": {"expected": 19, "normal": 3, "negative": 16, "cases": len(results),
                    "valid_negative_count": sum(bool(r.get("valid_result"))
                                                for r in results if r["base_id"] is not None),
                    "results": results, "passed": current_passed},
        "historical": historical, "execution_counts": counts, "fatal": fatal,
        "fatal_traceback": fatal_traceback,
        "physical_input_before": before, "physical_input_after": after,
        "physical_inputs_unchanged": unchanged,
        "limits": "Finite source/raw authority only. Historical outputs are logical views; no engine/collector/native/render/human/full-product approval.",
        "passed": passed,
    }
    print(json.dumps(output, ensure_ascii=False, indent=2))
    print("META_TITLE_A11_SOURCE_SELF_TEST_" + ("OK" if passed else "FAIL")
          + f" current={len(results)}/19 historical245={historical.get('cases', 0)}/24"
          + f" historical244={historical.get('nested_historical_cases', 0)}/18"
          + f" unchanged={unchanged}")
    return 0 if passed else 1
# END_ORDER248_A11_SELF


if __name__ == "__main__":
    raise SystemExit(_a11_main())
