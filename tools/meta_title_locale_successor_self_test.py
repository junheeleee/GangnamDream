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


if __name__ == "__main__":
    raise SystemExit(main())
