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


# BEGIN_ORDER250_MG9_SELF
# Separate newest MG9 source population. All original25 functions and literals stay raw.
MG9_SPEC = json.loads(r'''{
  "provenance": {
    "plan": ".git/full-game-localization/order250-source-controls-plan.json",
    "sha256": "d7c8cfaf41e42c62e5445acbca70f859947d12dc0517323d35ed167fb1857d26",
    "cases_sha256": "91e1f6187dce9a674648bd34e57627ef2ba879eeb25c9a31fec165860fd5205c",
    "chronology": "Recipes frozen before MG9 implementation. Private source only; no execution or applied-source claim."
  },
  "source_rows18": [
    [
      "holdem_master_title",
      "name",
      "홀덤 무법자",
      "Hold'em Outlaw"
    ],
    [
      "holdem_master_title",
      "desc",
      "지하 홀덤 클럽 15판 이상. 이제 패를 읽는다기보다, 상대를 읽는다.",
      "Played 15 or more underground hold'em games. You read people now, not cards."
    ],
    [
      "racetrack_master_title",
      "name",
      "경마 귀신",
      "Racetrack Ghost"
    ],
    [
      "racetrack_master_title",
      "desc",
      "경마장 15판 이상. 폼지는 가끔 거짓말을 한다. 나는 이제 그것도 안다.",
      "Bet on 15 or more races. Form lies sometimes. Now you know that too."
    ],
    [
      "scalping_master_title",
      "name",
      "스캘퍼",
      "Scalper"
    ],
    [
      "scalping_master_title",
      "desc",
      "스캘핑 트레이딩 15회 이상. 1분 안에 사고 팔고. 손이 기억한다.",
      "Scalped 15 or more times. Buy and sell within a minute. Your hands remember."
    ],
    [
      "baccarat_master_title",
      "name",
      "정선 카지노 상주자",
      "Jeongseon Casino Regular"
    ],
    [
      "baccarat_master_title",
      "desc",
      "바카라 15라운드 이상. 로드맵을 외웠지만 그게 아무 의미도 없다는 것도 안다.",
      "Played 15 or more baccarat rounds. You memorized the roadmap and learned it means nothing."
    ],
    [
      "blackjack_master_title",
      "name",
      "기본전략의 달인",
      "Basic Strategy Master"
    ],
    [
      "blackjack_master_title",
      "desc",
      "블랙잭 15핸드 이상. 패를 보고 멈출지 받을지를 안다. 이게 이 게임의 전부다.",
      "Played 15 or more blackjack hands. Hit or stand. That is the whole game."
    ],
    [
      "slot_master_title",
      "name",
      "잭팟 사냥꾼",
      "Jackpot Hunter"
    ],
    [
      "slot_master_title",
      "desc",
      "슬롯머신 20스핀 이상. 777이 나왔을 때 그 소리가 아직도 귓가에 맴돈다.",
      "Spun slots 20 or more times. The sound of 777 still echoes."
    ],
    [
      "roulette_master_title",
      "name",
      "제로의 지배자",
      "Master of Zero"
    ],
    [
      "roulette_master_title",
      "desc",
      "룰렛 15스핀 이상. 하우스엣지 2.7%는 알지만 멈출 수 없다.",
      "Spun roulette 15 or more times. You know the 2.7% house edge and still cannot stop."
    ],
    [
      "bigwheel_master_title",
      "name",
      "바늘의 눈",
      "Eye of the Needle"
    ],
    [
      "bigwheel_master_title",
      "desc",
      "빅휠 15스핀 이상. 가장 단순한 게임이지만 45:1을 노린다.",
      "Spun the big wheel 15 or more times. The simplest game, still chasing 45:1."
    ],
    [
      "daisai_master_title",
      "name",
      "주사위의 밤",
      "Night of Dice"
    ],
    [
      "daisai_master_title",
      "desc",
      "다이사이 15라운드 이상. 세 개의 주사위가 구르는 소리를 기억한다.",
      "Played 15 or more Dai Sai rounds. You remember the sound of three dice rolling."
    ]
  ],
  "baseline_pins": {
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
    },
    "tools/meta_title_locale_successor_self_test.py": {
      "bytes": 84339,
      "sha256": "3985d7f062682a4290602caac3f37a9427075a358307ff6f8ce5b1c862c63c64"
    },
    "tools/meta_title_locale_history.py": {
      "bytes": 6891,
      "sha256": "0c1d6d950379548c09d9f1a5faaa3749ced06465f34cd06457e9544c598a52f6"
    },
    "tools/meta_title_locale_history_self_test.py": {
      "bytes": 25211,
      "sha256": "0f00061417669ae026bd3d647156dad9a0e0b4920ee0c4414e49a5c26fdfcdf9"
    },
    "tools/full_game_localization.py": {
      "bytes": 282812,
      "sha256": "9aa3e45cbee1831d421315fc43fdcd9351b1e0394f9995931622592d569110b5"
    },
    "tools/full_game_localization_self_test.py": {
      "bytes": 1689986,
      "sha256": "7c6619c4991cb773f3b1958b21e7ec340e596caa0744b0d659fc1c25f022ca8d"
    },
    "autoloads/GameState.gd": {
      "bytes": 217568,
      "sha256": "8a40740286ff910b2a16049e2c2794cc0dc22fed5dfc78d2fc6ce458c833018d"
    }
  },
  "old_self": {
    "bytes": 84339,
    "sha256": "3985d7f062682a4290602caac3f37a9427075a358307ff6f8ce5b1c862c63c64"
  },
  "old_function_count": 25,
  "cases": [
    {
      "id": "mg9_normal_mp",
      "kind": "normal",
      "base_id": null,
      "source": "autoloads/MetaProgression.gd",
      "recipe": {
        "op": "bound_future_raw"
      },
      "expected_profile": "normal_raw"
    },
    {
      "id": "mg9_normal_ja",
      "kind": "normal",
      "base_id": null,
      "source": "tools/ja_translation_pipeline.py",
      "recipe": {
        "op": "bound_future_raw"
      },
      "expected_profile": "normal_raw"
    },
    {
      "id": "mg9_normal_calls",
      "kind": "normal",
      "base_id": null,
      "source": "autoloads/MetaProgression.gd",
      "recipe": {
        "op": "parse_complete_current_MP"
      },
      "expected_profile": "normal_calls"
    },
    {
      "id": "mg9_mp_rollback248",
      "kind": "negative",
      "base_id": "mg9_normal_mp",
      "source": "autoloads/MetaProgression.gd",
      "recipe": {
        "op": "use_pinned_predecessor248"
      },
      "expected_profile": "reject_raw"
    },
    {
      "id": "mg9_ja_rollback248",
      "kind": "negative",
      "base_id": "mg9_normal_ja",
      "source": "tools/ja_translation_pipeline.py",
      "recipe": {
        "op": "use_pinned_predecessor248"
      },
      "expected_profile": "reject_raw"
    },
    {
      "id": "mg9_mp_skip_to245",
      "kind": "negative",
      "base_id": "mg9_normal_mp",
      "source": "autoloads/MetaProgression.gd",
      "recipe": {
        "op": "use_independently_restored245",
        "sha256": "a3435ebd18cee005720a98633fa290754b23cf944b241cef25848b3cf114b7bd"
      },
      "expected_profile": "reject_raw"
    },
    {
      "id": "mg9_mp_LF_forged_live_hash",
      "kind": "negative",
      "base_id": "mg9_normal_mp",
      "source": "autoloads/MetaProgression.gd",
      "recipe": {
        "op": "append",
        "text": "\n",
        "claim": "approved_future_current_sha",
        "force_live_observed_hash": "historical244_sha",
        "must_read_actual_raw": true
      },
      "expected_profile": "reject_raw"
    },
    {
      "id": "mg9_ja_CRLF",
      "kind": "negative",
      "base_id": "mg9_normal_ja",
      "source": "tools/ja_translation_pipeline.py",
      "recipe": {
        "op": "replace_all_LF_with_CRLF",
        "observe": "real JA adapter default Path.read_bytes path; no read_text normalization"
      },
      "expected_profile": "reject_raw"
    },
    {
      "id": "mg9_mp_unowned_condition_change",
      "kind": "negative",
      "base_id": "mg9_normal_mp",
      "source": "autoloads/MetaProgression.gd",
      "recipe": {
        "op": "replace_exact",
        "before": "\t\t\"slot_master_title\":       return int(data.get(\"mg_plays_slot\", 0)) >= 20",
        "after": "\t\t\"slot_master_title\":       return int(data.get(\"mg_plays_slot\", 0)) >= 19",
        "count": 1
      },
      "expected_profile": "reject_raw"
    },
    {
      "id": "mg9_helper_outside_new_span_change",
      "kind": "negative",
      "base_id": "mg9_normal_mp",
      "source": "tools/meta_title_locale_successor.py",
      "recipe": {
        "op": "append",
        "text": "\n",
        "guard": "source4 whole-raw binding before module/corpus/history entry"
      },
      "expected_profile": "reject_physical_binding"
    },
    {
      "id": "mg9_chapter_outer_hook_missing",
      "kind": "negative",
      "base_id": "mg9_normal_mp",
      "source": "tools/chapter1_core_loop_v2_causal_ledger_check.py",
      "recipe": {
        "op": "restore_exact_new_live_hook_to248",
        "hook": "future actual _audited_source_snapshot_errors MG9 outer call -> current _order248_meta_source_errors; exact strings separately bound"
      },
      "expected_profile": "reject_physical_binding"
    },
    {
      "id": "mg9_registry_stage_skip",
      "kind": "negative",
      "base_id": "mg9_normal_mp",
      "source": "autoloads/MetaProgression.gd",
      "recipe": {
        "op": "replace_registry_previous",
        "registry": "MG9_TRANSITIONS",
        "value": "a3435ebd18cee005720a98633fa290754b23cf944b241cef25848b3cf114b7bd",
        "leave_frozen_registry_digest": true
      },
      "expected_profile": "reject_raw"
    },
    {
      "id": "mg9_registry_missing_JA_inverse_hook",
      "kind": "negative",
      "base_id": "mg9_normal_ja",
      "source": "tools/ja_translation_pipeline.py",
      "recipe": {
        "op": "delete_registry_hook",
        "registry": "MG9_TRANSITIONS",
        "index": 0,
        "leave_frozen_registry_digest": true
      },
      "expected_profile": "reject_raw"
    },
    {
      "id": "mg9_false_hash_claim_valid_raw",
      "kind": "negative",
      "base_id": "mg9_normal_mp",
      "source": "autoloads/MetaProgression.gd",
      "recipe": {
        "op": "replace_claim_only",
        "claim": "0000000000000000000000000000000000000000000000000000000000000000"
      },
      "expected_profile": "reject_claim_only"
    },
    {
      "id": "mg9_wrong_predecessor_registration",
      "kind": "negative",
      "base_id": "mg9_normal_mp",
      "source": "autoloads/MetaProgression.gd",
      "recipe": {
        "op": "replace_registered_previous_only",
        "registered_previous": "a3435ebd18cee005720a98633fa290754b23cf944b241cef25848b3cf114b7bd"
      },
      "expected_profile": "reject_registration_only"
    },
    {
      "id": "mg9_call_missing",
      "kind": "negative",
      "base_id": "mg9_normal_calls",
      "source": "autoloads/MetaProgression.gd",
      "recipe": {
        "op": "delete_selected_call",
        "selector": {
          "id": "holdem_master_title",
          "field": "name",
          "path": "autoloads/MetaProgression.gd",
          "function": "_localized_title",
          "korean": "홀덤 무법자",
          "english": "Hold'em Outlaw",
          "api": "legacy",
          "context_id": ""
        },
        "count": 1
      },
      "expected_profile": "reject_calls"
    },
    {
      "id": "mg9_call_duplicate",
      "kind": "negative",
      "base_id": "mg9_normal_calls",
      "source": "autoloads/MetaProgression.gd",
      "recipe": {
        "op": "duplicate_selected_call",
        "selector": {
          "id": "holdem_master_title",
          "field": "name",
          "path": "autoloads/MetaProgression.gd",
          "function": "_localized_title",
          "korean": "홀덤 무법자",
          "english": "Hold'em Outlaw",
          "api": "legacy",
          "context_id": ""
        },
        "count": 1
      },
      "expected_profile": "reject_calls"
    },
    {
      "id": "mg9_call_EN_change",
      "kind": "negative",
      "base_id": "mg9_normal_calls",
      "source": "autoloads/MetaProgression.gd",
      "recipe": {
        "op": "replace_selected_call_field",
        "selector": {
          "id": "holdem_master_title",
          "field": "name",
          "path": "autoloads/MetaProgression.gd",
          "function": "_localized_title",
          "korean": "홀덤 무법자",
          "english": "Hold'em Outlaw",
          "api": "legacy",
          "context_id": ""
        },
        "attribute": "english",
        "before": "Hold'em Outlaw",
        "after": "Hold'em Winner"
      },
      "expected_profile": "reject_calls"
    },
    {
      "id": "mg9_call_owner_change",
      "kind": "negative",
      "base_id": "mg9_normal_calls",
      "source": "autoloads/MetaProgression.gd",
      "recipe": {
        "op": "replace_selected_call_field",
        "selector": {
          "id": "holdem_master_title",
          "field": "name",
          "path": "autoloads/MetaProgression.gd",
          "function": "_localized_title",
          "korean": "홀덤 무법자",
          "english": "Hold'em Outlaw",
          "api": "legacy",
          "context_id": ""
        },
        "attribute": "function",
        "before": "_localized_title",
        "after": "_get_title_info_raw"
      },
      "expected_profile": "reject_calls"
    },
    {
      "id": "mg9_call_API_change",
      "kind": "negative",
      "base_id": "mg9_normal_calls",
      "source": "autoloads/MetaProgression.gd",
      "recipe": {
        "op": "replace_selected_call_field",
        "selector": {
          "id": "holdem_master_title",
          "field": "name",
          "path": "autoloads/MetaProgression.gd",
          "function": "_localized_title",
          "korean": "홀덤 무법자",
          "english": "Hold'em Outlaw",
          "api": "legacy",
          "context_id": ""
        },
        "attribute": "api",
        "before": "legacy",
        "after": "context"
      },
      "expected_profile": "reject_calls"
    },
    {
      "id": "mg9_call_context_change",
      "kind": "negative",
      "base_id": "mg9_normal_calls",
      "source": "autoloads/MetaProgression.gd",
      "recipe": {
        "op": "replace_selected_call_field",
        "selector": {
          "id": "holdem_master_title",
          "field": "name",
          "path": "autoloads/MetaProgression.gd",
          "function": "_localized_title",
          "korean": "홀덤 무법자",
          "english": "Hold'em Outlaw",
          "api": "legacy",
          "context_id": ""
        },
        "attribute": "context_id",
        "before": "",
        "after": "ui.mg9.unapproved"
      },
      "expected_profile": "reject_calls"
    },
    {
      "id": "mg9_call_foreign_extra_owner",
      "kind": "negative",
      "base_id": "mg9_normal_calls",
      "source": "autoloads/MetaProgression.gd",
      "recipe": {
        "op": "append_foreign_duplicate_call",
        "selector": {
          "id": "holdem_master_title",
          "field": "name",
          "path": "autoloads/MetaProgression.gd",
          "function": "_localized_title",
          "korean": "홀덤 무법자",
          "english": "Hold'em Outlaw",
          "api": "legacy",
          "context_id": ""
        },
        "retain_original": true,
        "values": {
          "path": "autoloads/GameState.gd",
          "function": "get_current_title"
        }
      },
      "expected_profile": "reject_calls"
    },
    {
      "id": "mg9_path_OFF",
      "kind": "OFF",
      "base_id": "mg9_normal_mp",
      "source": "autoloads/MetaProgression.gd",
      "recipe": {
        "op": "change_relative_path_only",
        "relative": "autoloads/GameState.gd",
        "raw": "unchanged approved future MP",
        "claim": "its actual SHA256"
      },
      "expected_profile": "path_OFF"
    }
  ],
  "expected_profiles": {
    "normal_raw": {
      "physical_binding": true,
      "source_errors_empty": true,
      "raw_projection": "exact immediate248 predecessor",
      "hash_projection": "immediate248 SHA for correct actual claim",
      "live": "MP: actual Chapter snapshot passes with original registered historical244 pin; JA: actual JA adapter observes valid current MP and physical JA then strips only18"
    },
    "normal_calls": {
      "errors_empty": true,
      "output": "input tuple minus exact MG9 eighteen only; remaining tuple order/values preserved",
      "source": "exact MP248 raw",
      "observation": "Complete MP parse once; projected source and call list compared with independent expected, not SUT-produced expected"
    },
    "reject_raw": {
      "source_errors_empty": false,
      "raw_projection": "input identity",
      "hash_projection": "claim identity",
      "live": "owned MP raw reaches actual Chapter reader and is rejected before old _order248 gate; JA physical raw reaches adapter and returns original calls/source plus errors"
    },
    "reject_physical_binding": {
      "binding_errors_empty": false,
      "new_helper_calls": 0,
      "historical_entries": 0,
      "output": "captured failure, not skipped/PASS; no filesystem write or importing mutated code"
    },
    "reject_claim_only": {
      "source_errors_empty": true,
      "raw_projection": "exact248",
      "hash_projection": "false claim identity",
      "live": "Chapter with same false _file_digest claim must reject; raw validation alone cannot authorize a wrong observation"
    },
    "reject_registration_only": {
      "source_errors_empty": false,
      "raw_projection": "exact248 because pure projector has no registered_previous argument",
      "hash_projection": "exact248 for truthful current hash",
      "live": "new registration API rejects; Chapter tested with wrong registered old pin also rejects. Do not conflate the new-stage immediate248 pin with Chapter historical244 registration"
    },
    "reject_calls": {
      "errors_empty": false,
      "output": "mutated input tuple identity",
      "source": "current source identity",
      "physical_sources": "all normal/raw-bound; one semantic mutation only"
    },
    "path_OFF": {
      "source_errors_empty": false,
      "reason": "new layer owns only MP/JA, not GameState",
      "raw_projection": "input identity",
      "hash_projection": "claim identity",
      "live_or_JA_calls": 0,
      "classification": "not an authorized normal and not counted as a negative efficacy success"
    }
  }
}''')
MG9_BINDING = json.loads(r'''{
  "phase": "APPLIED_SOURCE_BOUND",
  "current_pins": {
    "autoloads/MetaProgression.gd": {
      "bytes": 62214,
      "sha256": "edbcdfdefe7c547edac9a47b71a3892b6fe68c9553c982e914a151ea2e52921b"
    },
    "tools/ja_translation_pipeline.py": {
      "bytes": 255882,
      "sha256": "e2d666c19637fd20df8750187870e27cc1770c63d73db232e8035b8d072abe9c"
    },
    "tools/meta_title_locale_successor.py": {
      "bytes": 27372,
      "sha256": "5cbe5de2669a83d36c5d17c9b3d64293505737c399ce063324f38de8224eac81"
    },
    "tools/chapter1_core_loop_v2_causal_ledger_check.py": {
      "bytes": 1461830,
      "sha256": "ac874ad1587304b4f1802ce2311cbcba231e1fdfb19086cce3a66aa19ee5fac3"
    }
  },
  "production_registry": {
    "autoloads/MetaProgression.gd": {
      "previous_sha256": "afe8bda86177950ef82fb8d2eea339ae398d59534897719c9b803bacf292a1b6",
      "current_sha256": "edbcdfdefe7c547edac9a47b71a3892b6fe68c9553c982e914a151ea2e52921b",
      "start": "\t\t\"holdem_master_title\":\n",
      "end": "\treturn localized\n",
      "include_end": false,
      "span_sha256": "207baf12cad3682d3073da41646183431faca9cc78e09962cde127c0277621d0",
      "hooks": []
    },
    "tools/ja_translation_pipeline.py": {
      "previous_sha256": "504b5ef8707568b199df35179b1753ab25706b2004fa3d0fc0fa879b18303906",
      "current_sha256": "e2d666c19637fd20df8750187870e27cc1770c63d73db232e8035b8d072abe9c",
      "start": "# BEGIN_META_TITLE_SUCCESSOR_250\n",
      "end": "# END_META_TITLE_SUCCESSOR_250\n\n\n",
      "include_end": true,
      "span_sha256": "9c231ba059708f9f5ac1be745fc667941de333b1451af0eb2594ca6aa3aa60d0",
      "hooks": [
        [
          "    predecessor_calls, predecessor_source, next_title_errors = _mg9_meta_title_chain_calls(calls)",
          "    predecessor_calls, predecessor_source, next_title_errors = _a11_meta_title_chain_calls(calls)"
        ],
        [
          "    stats, title_stat_errors = _mg9_meta_title_current_stats(\n        calls, predecessor_calls, predecessor_source, stats)",
          "    stats, title_stat_errors = _a11_meta_title_current_stats(\n        calls, predecessor_calls, predecessor_source, stats)"
        ],
        [
          "        ui_inventory, meta_title_cases, meta_title_failures = _mg9_meta_title_historical_checks(ui_inventory)",
          "        ui_inventory, meta_title_cases, meta_title_failures = _a11_meta_title_historical_checks(ui_inventory)"
        ]
      ]
    }
  },
  "registry_sha256": "78ad53320530e54e2347313e505cf28c4f8991f011e6a91d8e0078831b577515",
  "independent_inverse_rules": {
    "autoloads/MetaProgression.gd": {
      "remove_spans": [
        {
          "start": "\t\t\"holdem_master_title\":\n",
          "end": "\treturn localized\n",
          "include_end": false,
          "sha256": "207baf12cad3682d3073da41646183431faca9cc78e09962cde127c0277621d0"
        }
      ],
      "hooks": []
    },
    "tools/ja_translation_pipeline.py": {
      "remove_spans": [
        {
          "start": "# BEGIN_META_TITLE_SUCCESSOR_250\n",
          "end": "# END_META_TITLE_SUCCESSOR_250\n\n\n",
          "include_end": true,
          "sha256": "9c231ba059708f9f5ac1be745fc667941de333b1451af0eb2594ca6aa3aa60d0"
        }
      ],
      "hooks": [
        [
          "    predecessor_calls, predecessor_source, next_title_errors = _mg9_meta_title_chain_calls(calls)",
          "    predecessor_calls, predecessor_source, next_title_errors = _a11_meta_title_chain_calls(calls)"
        ],
        [
          "    stats, title_stat_errors = _mg9_meta_title_current_stats(\n        calls, predecessor_calls, predecessor_source, stats)",
          "    stats, title_stat_errors = _a11_meta_title_current_stats(\n        calls, predecessor_calls, predecessor_source, stats)"
        ],
        [
          "        ui_inventory, meta_title_cases, meta_title_failures = _mg9_meta_title_historical_checks(ui_inventory)",
          "        ui_inventory, meta_title_cases, meta_title_failures = _a11_meta_title_historical_checks(ui_inventory)"
        ]
      ]
    },
    "tools/meta_title_locale_successor.py": {
      "remove_spans": [
        {
          "start": "\n\n# BEGIN_MG9_META_TITLE_SUCCESSOR_250\n",
          "end": "# END_MG9_META_TITLE_SUCCESSOR_250\n",
          "include_end": true,
          "sha256": "baf8b074f7f8c364c1e4750c173410823707379a05082bc26a20d84503ce6515"
        }
      ],
      "hooks": []
    },
    "tools/chapter1_core_loop_v2_causal_ledger_check.py": {
      "remove_spans": [
        {
          "start": "def _order250_meta_source_errors(\n",
          "end": "def _audited_source_snapshot_errors(\n",
          "include_end": false,
          "sha256": "c98f86241a066056e18bd657806f027ceb431ce6d120cb9af2a8f1ce46c76fa6"
        }
      ],
      "hooks": [
        [
          "            errors.extend(_order250_meta_source_errors(\n",
          "            errors.extend(_order248_meta_source_errors(\n"
        ],
        [
          "                observed_digest = _order250_meta_observed_hash(\n",
          "                observed_digest = _order248_meta_observed_hash(\n"
        ]
      ]
    }
  },
  "binding_provenance": {
    "kind": "ROOT directly reviewed and applied exact source4; authorization for bounded first source controls only",
    "private_candidate": {
      "path": ".git/full-game-localization/order250-source4-private-binding.json",
      "bytes": 16109,
      "sha256": "4c098e5a43a2af1d8f8c9de6c319d709db9f465a74fcc601c5e9d9eca6a86aa7"
    },
    "actual_source": {
      "autoloads/MetaProgression.gd": {
        "bytes": 62214,
        "sha256": "edbcdfdefe7c547edac9a47b71a3892b6fe68c9553c982e914a151ea2e52921b"
      },
      "tools/ja_translation_pipeline.py": {
        "bytes": 255882,
        "sha256": "e2d666c19637fd20df8750187870e27cc1770c63d73db232e8035b8d072abe9c"
      },
      "tools/meta_title_locale_successor.py": {
        "bytes": 27372,
        "sha256": "5cbe5de2669a83d36c5d17c9b3d64293505737c399ce063324f38de8224eac81"
      },
      "tools/chapter1_core_loop_v2_causal_ledger_check.py": {
        "bytes": 1461830,
        "sha256": "ac874ad1587304b4f1802ce2311cbcba231e1fdfb19086cce3a66aa19ee5fac3"
      }
    },
    "chronology": "Fixed23 and private source4/self reviewed before execution. ROOT independently read the whole extension and binding, measured actual source4, and authorizes this constant-only APPLIED delta; no pass yet."
  }
}''')

_MG9_SOURCE_PATHS = (
    MP, JA, "tools/meta_title_locale_successor.py",
    "tools/chapter1_core_loop_v2_causal_ledger_check.py",
)
_MG9_SELF = "tools/meta_title_locale_successor_self_test.py"


def _mg9_input_pins():
    paths = set(FROZEN["current_pins"]) | set(MG9_SPEC["baseline_pins"]) | {
        _MG9_SELF, "content/meta/chapter1_core_loop_v2_causal_ledger.json",
        "tools/chapter1_core_loop_v2_causal_debt_baseline.json",
    }
    return {p: pin((ROOT / p).read_bytes()) for p in sorted(paths)}


def _mg9_binding_errors(observed):
    errors = []
    if MG9_BINDING["phase"] != "APPLIED_SOURCE_BOUND":
        errors.append("MG9 source binding is not applied/approved")
    wanted = MG9_BINDING.get("current_pins")
    if not isinstance(wanted, dict) or set(wanted) != set(_MG9_SOURCE_PATHS):
        errors.append("MG9 exact four current pins are unavailable")
        return errors
    for relative in _MG9_SOURCE_PATHS:
        if observed.get(relative) != wanted[relative]:
            errors.append("MG9 current raw changed: " + relative)
    preserved = dict(FROZEN["current_pins"])
    preserved.update(MG9_SPEC["baseline_pins"])
    for relative, expected in preserved.items():
        if relative not in (*_MG9_SOURCE_PATHS, _MG9_SELF):
            if observed.get(relative) != expected:
                errors.append("MG9 preserved dependency changed: " + relative)
    return errors


def _mg9_approved_span():
    lines, previous = [], None
    for title_id, field, ko, en in MG9_SPEC["source_rows18"]:
        if previous != title_id:
            lines.append("\t\t" + json.dumps(title_id) + ":\n")
            previous = title_id
        lines.append("\t\t\tlocalized[" + json.dumps(field)
                     + "] = LocaleManager.ui(" + json.dumps(ko, ensure_ascii=False)
                     + ", " + json.dumps(en, ensure_ascii=False) + ")\n")
    return "".join(lines).encode("utf-8")


def _mg9_independent_inverse(raw, relative):
    """Independent frozen rules only; never ask the production projector."""
    if relative == _MG9_SELF:
        start, end = b"# BEGIN_ORDER250_MG9_SELF\n", b"# END_ORDER250_MG9_SELF\n\n\n"
        if raw.count(start) != 1 or raw.count(end) != 1:
            raise AssertionError("MG9 self insertion is not exact1")
        a, z = raw.index(start), raw.index(end) + len(end)
        old = raw[:a] + raw[z:]
        now = b"raise SystemExit(_mg9_main())"
        if old.count(now) != 1:
            raise AssertionError("MG9 self CLI hook is not exact1")
        old = old.replace(now, b"raise SystemExit(_a11_main())", 1)
        if pin(old) != MG9_SPEC["old_self"]:
            raise AssertionError("original25 functions/19/24/18 self raw changed")
        return old
    rules = MG9_BINDING.get("independent_inverse_rules")
    if not isinstance(rules, dict) or relative not in rules:
        raise AssertionError("MG9 independent source inverse is unbound")
    rule, out = rules[relative], raw
    for span in rule["remove_spans"]:
        start, end = span["start"].encode(), span["end"].encode()
        if out.count(start) != 1 or out.count(end) != 1:
            raise AssertionError("MG9 independent span boundary is not unique")
        a = out.index(start)
        z = out.index(end, a) + (len(end) if span["include_end"] else 0)
        removed = out[a:z]
        if sha256(removed) != span["sha256"]:
            raise AssertionError("MG9 independent span digest differs")
        if relative == MP and removed != _mg9_approved_span():
            raise AssertionError("MG9 exact9 ID/18 field/KO/EN/order changed")
        out = out[:a] + out[z:]
    for current, previous in rule["hooks"]:
        current = current.encode("utf-8")
        if out.count(current) != 1:
            raise AssertionError("MG9 independent hook is not unique")
        out = out.replace(current, previous.encode("utf-8"), 1)
    if pin(out) != MG9_SPEC["baseline_pins"][relative]:
        raise AssertionError("MG9 inverse failed to recover whole248: " + relative)
    return out


def _mg9_without_selected(calls):
    keys = {row[2] for row in MG9_SPEC["source_rows18"]}
    return tuple(c for c in calls if not (
        (c.path, c.function) == (MP, "_localized_title") and c.korean in keys))


def _mg9_materialize(case, current, old248):
    relative, recipe = case["source"], case["recipe"]
    raw, op = current[relative], recipe["op"]
    if op in ("bound_future_raw", "replace_registry_previous",
              "delete_registry_hook", "replace_claim_only",
              "replace_registered_previous_only", "change_relative_path_only"):
        return raw
    if op == "use_pinned_predecessor248":
        return old248[relative]
    if op == "use_independently_restored245":
        old = _a11_inverse_file(old248[relative], relative)
        if sha256(old) != recipe["sha256"]:
            raise AssertionError("fixed245 predecessor pin differs")
        return old
    if op == "append":
        return raw + recipe["text"].encode()
    if op == "replace_all_LF_with_CRLF":
        if b"\r" in raw or b"\n" not in raw:
            raise AssertionError("CRLF base must be unchanged LF-only")
        return raw.replace(b"\n", b"\r\n")
    if op == "replace_exact":
        before, after = recipe["before"].encode(), recipe["after"].encode()
        if before == after or raw.count(before) != recipe["count"]:
            raise AssertionError("frozen nonlocalized mutation anchor differs")
        return raw.replace(before, after, recipe["count"])
    if op == "restore_exact_new_live_hook_to248":
        hooks = MG9_BINDING["independent_inverse_rules"][relative]["hooks"]
        matches = [(now, old) for now, old in hooks
                   if "_order250_meta_source_errors(" in now
                   and "_order248_meta_source_errors(" in old]
        if len(matches) != 1:
            raise AssertionError("independent Chapter live source hook is not exact1")
        now, old = (v.encode() for v in matches[0])
        if raw.count(now) != 1 or now == old:
            raise AssertionError("fixed Chapter live hook base differs")
        return raw.replace(now, old, 1)
    raise AssertionError("unknown frozen MG9 raw recipe: " + op)


def _mg9_registry_context(case, successor):
    op = case["recipe"]["op"]
    if op not in ("replace_registry_previous", "delete_registry_hook"):
        return contextlib.nullcontext()
    changed = copy.deepcopy(successor.MG9_TRANSITIONS)
    if op == "replace_registry_previous":
        changed[MP]["previous_sha256"] = case["recipe"]["value"]
    else:
        index = case["recipe"]["index"]
        if len(changed[JA]["hooks"]) <= index:
            raise AssertionError("frozen missing-hook recipe has no real hook")
        del changed[JA]["hooks"][index]
    return patch.object(successor, "MG9_TRANSITIONS", changed)


def _mg9_snapshot(chapter, raw, claim, registered, force_old, counts):
    original_read, original_digest = Path.read_bytes, chapter._file_digest
    original_outer = chapter._order250_meta_observed_hash
    original_old_gate = chapter._order248_meta_source_errors
    raw_reads, hash_reads, old_gate_calls = [], [], []

    def read_bytes(path):
        if path == ROOT / MP:
            raw_reads.append(MP)
            return raw
        return original_read(path)

    def digest(relative):
        if relative == MP:
            hash_reads.append(relative)
            return claim
        return original_digest(relative)

    def previous_gate(relative, source, old):
        old_gate_calls.append(relative)
        return original_old_gate(relative, source, old)

    with contextlib.ExitStack() as stack:
        stack.enter_context(patch.object(Path, "read_bytes", read_bytes))
        stack.enter_context(patch.object(chapter, "_file_digest", digest))
        stack.enter_context(patch.object(chapter, "_order248_meta_source_errors",
                                        previous_gate))
        if force_old:
            stack.enter_context(patch.object(
                chapter, "_order250_meta_observed_hash",
                return_value=FROZEN["historical_mp"]["sha256"]))
        counts["Chapter_actual_snapshot"] += 1
        errors = chapter._audited_source_snapshot_errors({MP: registered})
    return {
        "errors": errors, "raw_reads": raw_reads, "hash_reads": hash_reads,
        "old248_gate_calls": old_gate_calls, "forced_observation": force_old,
        "registered": registered,
        "restored": (Path.read_bytes is original_read
                     and chapter._file_digest is original_digest
                     and chapter._order250_meta_observed_hash is original_outer
                     and chapter._order248_meta_source_errors is original_old_gate),
    }


def _mg9_ja_observation(pipeline, calls, current, old248, ja_raw, normal, counts):
    original_read = Path.read_bytes

    def read_bytes(path):
        return ja_raw if path == ROOT / JA else original_read(path)

    with patch.object(Path, "read_bytes", read_bytes):
        counts["MG9_JA_call_contract"] += 1
        # Exercise the default physical MP read, including its byte/CRLF policy.
        out_calls, source, errors = pipeline._mg9_meta_title_predecessor_calls(calls)
    wanted_calls = _mg9_without_selected(calls) if normal else tuple(calls)
    wanted_source = old248[MP] if normal else current[MP]
    checks = {
        "errors": isinstance(errors, list) and (not errors) == normal,
        "calls_exact": tuple(out_calls) == wanted_calls,
        "source_exact": source.encode("utf-8") == wanted_source,
        "restored": Path.read_bytes is original_read,
    }
    return {"errors": errors, "output_calls": len(out_calls),
            "source": pin(source.encode("utf-8")), "checks": checks,
            "passed": all(checks.values())}


def _mg9_raw_case(case, current, old248, calls, successor, pipeline, chapter, counts):
    relative, recipe = case["source"], case["recipe"]
    raw = _mg9_materialize(case, current, old248)
    profile = case["expected_profile"]
    path = recipe.get("relative", relative)
    claim = (sha256(current[relative]) if recipe.get("claim") == "approved_future_current_sha"
             else recipe["claim"] if recipe["op"] == "replace_claim_only"
             else sha256(raw))
    if profile == "reject_physical_binding":
        observed = _mg9_input_pins()
        observed[relative] = pin(raw)
        counts["physical_binding_probe"] += 1
        errors = _mg9_binding_errors(observed)
        checks = {"binding_rejected": bool(errors),
                  "owned_path_named": any(relative in e for e in errors)}
        return {"id": case["id"], "kind": case["kind"], "base_id": case["base_id"],
                "input": pin(raw), "binding_errors": errors,
                "helper_calls": 0, "historical_entries": 0,
                "checks": checks, "passed": all(checks.values())}
    normal = case["kind"] == "normal"
    valid_raw = normal or profile in ("reject_claim_only", "reject_registration_only")
    registered = (recipe["registered_previous"] if profile == "reject_registration_only"
                  else MG9_SPEC["baseline_pins"][relative]["sha256"])
    original_registry = copy.deepcopy(successor.MG9_TRANSITIONS)
    live, ja_view = None, None
    with _mg9_registry_context(case, successor):
        counts["MG9_source_errors"] += 1
        errors = successor.mg9_source_errors(path, raw, registered)
        counts["MG9_raw_projection"] += 1
        projected = successor.mg9_project_bytes(raw, path)
        counts["MG9_hash_projection"] += 1
        projected_hash = successor.mg9_project_byte_hash(claim, path, raw)
        if relative == MP and path == MP:
            live_registered = (recipe["registered_previous"]
                               if profile == "reject_registration_only"
                               else FROZEN["historical_mp"]["sha256"])
            live = _mg9_snapshot(chapter, raw, claim, live_registered,
                                 bool(recipe.get("force_live_observed_hash")), counts)
        if relative == JA:
            ja_view = _mg9_ja_observation(
                pipeline, calls, current, old248, raw, normal, counts)
    wanted = old248[relative] if valid_raw else raw
    wanted_hash = (sha256(wanted) if valid_raw and profile != "reject_claim_only"
                   else claim)
    checks = {
        "source_errors": isinstance(errors, list) and (not errors) == (
            normal or profile == "reject_claim_only"),
        "raw_projection": projected == wanted,
        "hash_projection": projected_hash == wanted_hash,
        "registry_restored": successor.MG9_TRANSITIONS == original_registry,
    }
    if live is not None:
        checks["live_raw_gate"] = (isinstance(live["errors"], list)
                                  and (not live["errors"]) == normal
                                  and bool(live["raw_reads"]) and live["restored"])
        if not valid_raw:
            checks["old_gate_not_reached"] = not live["old248_gate_calls"]
    if ja_view is not None:
        checks["JA_current_file_gate"] = ja_view["passed"]
    return {
        "id": case["id"], "kind": case["kind"], "base_id": case["base_id"],
        "path": path, "input": pin(raw), "claim": claim, "registered": registered,
        "source_errors": errors, "projection": pin(projected),
        "projected_hash": projected_hash, "live_snapshot": live,
        "JA_observation": ja_view, "checks": checks, "passed": all(checks.values()),
    }


def _mg9_call_case(case, calls, current, old248, pipeline, counts):
    recipe, changed = case["recipe"], list(calls)
    normal = case["kind"] == "normal"
    if not normal:
        selector = recipe["selector"]
        indices = [i for i, c in enumerate(changed) if all(
            getattr(c, k) == selector[k] for k in (
                "path", "function", "korean", "english", "api", "context_id"))]
        if len(indices) != 1:
            raise AssertionError("frozen MG9 semantic selector is not exact1")
        index, op = indices[0], recipe["op"]
        if op == "delete_selected_call":
            del changed[index]
        elif op == "duplicate_selected_call":
            changed.insert(index, changed[index])
        elif op == "replace_selected_call_field":
            if getattr(changed[index], recipe["attribute"]) != recipe["before"]:
                raise AssertionError("frozen MG9 call before differs")
            changed[index] = dataclasses.replace(
                changed[index], **{recipe["attribute"]: recipe["after"]})
        elif op == "append_foreign_duplicate_call":
            changed.append(dataclasses.replace(changed[index], **recipe["values"]))
        else:
            raise AssertionError("unknown frozen MG9 call recipe")
    changed = tuple(changed)
    source = current[MP].decode("utf-8")
    counts["MG9_JA_call_contract"] += 1
    out_calls, out_source, errors = pipeline._mg9_meta_title_predecessor_calls(
        changed, source)
    checks = {
        "errors": isinstance(errors, list) and (not errors) == normal,
        "calls_exact": tuple(out_calls) == (
            _mg9_without_selected(calls) if normal else changed),
        "source_exact": out_source.encode("utf-8") == (
            old248[MP] if normal else current[MP]),
    }
    return {"id": case["id"], "kind": case["kind"], "base_id": case["base_id"],
            "input_calls": [dataclasses.asdict(c) for c in changed],
            "output_calls": [dataclasses.asdict(c) for c in out_calls],
            "source": pin(out_source.encode("utf-8")), "errors": errors,
            "checks": checks, "passed": all(checks.values())}


def _mg9_historical248(old248, chapter, counts):
    """Unchanged A11 nineteen, whose own wrappers retain old24 and old18."""
    original_read, original_text = Path.read_bytes, Path.read_text
    original_gate = chapter._order250_meta_source_errors
    original_hash = chapter._order250_meta_observed_hash
    stdout, stderr = io.StringIO(), io.StringIO()
    reads = {p: 0 for p in old248}

    def read_bytes(path):
        for relative, raw in old248.items():
            if path == ROOT / relative:
                reads[relative] += 1
                return raw
        return original_read(path)

    def read_text(path, *args, **kwargs):
        for relative, raw in old248.items():
            if path == ROOT / relative:
                reads[relative] += 1
                encoding = kwargs.get("encoding") or (args[0] if args else None) or "utf-8"
                return raw.decode(encoding, errors=kwargs.get("errors") or "strict")
        return original_text(path, *args, **kwargs)

    def gate(relative, raw, registered):
        return chapter._order248_meta_source_errors(relative, raw, registered)

    def observed_hash(claim, relative, raw):
        # Dynamic lookup preserves the unchanged old19/24/18 forged-hash mocks.
        return chapter._order248_meta_observed_hash(claim, relative, raw)

    code, exception, trace = None, None, None
    with contextlib.ExitStack() as stack:
        stack.enter_context(patch.object(Path, "read_bytes", read_bytes))
        stack.enter_context(patch.object(Path, "read_text", read_text))
        stack.enter_context(patch.object(chapter, "_order250_meta_source_errors", gate))
        stack.enter_context(patch.object(chapter, "_order250_meta_observed_hash", observed_hash))
        stack.enter_context(contextlib.redirect_stdout(stdout))
        stack.enter_context(contextlib.redirect_stderr(stderr))
        counts["historical248_main"] += 1
        try:
            code = _a11_main()
        except Exception as error:
            exception = type(error).__name__ + ": " + str(error)
            trace = _a11_traceback.format_exc()
    restored = (Path.read_bytes is original_read and Path.read_text is original_text
                and chapter._order250_meta_source_errors is original_gate
                and chapter._order250_meta_observed_hash is original_hash)
    parsed, marker, parse_error = None, None, None
    try:
        parsed, end = json.JSONDecoder().raw_decode(stdout.getvalue())
        marker = stdout.getvalue()[end:].strip()
    except (TypeError, ValueError) as error:
        parse_error = type(error).__name__ + ": " + str(error)
    logical_before = parsed.get("physical_input_before") if isinstance(parsed, dict) else None
    logical_after = parsed.get("physical_input_after") if isinstance(parsed, dict) else None
    logical_exact = (isinstance(logical_before, dict) and logical_before == logical_after
                     and all(logical_before.get(p) == pin(raw) for p, raw in old248.items()))
    wanted_marker = ("META_TITLE_A11_SOURCE_SELF_TEST_OK current=19/19"
                     " historical245=24/24 historical244=18/18 unchanged=True")
    passed = (code == 0 and exception is None and parse_error is None and restored
              and not stderr.getvalue() and marker == wanted_marker and logical_exact
              and isinstance(parsed, dict) and parsed.get("passed") is True
              and parsed.get("current", {}).get("cases") == 19
              and len(parsed.get("current", {}).get("results", [])) == 19
              and all(r.get("valid_result") for r in parsed["current"]["results"])
              and parsed.get("historical", {}).get("passed") is True
              and parsed["historical"].get("cases") == 24
              and parsed["historical"].get("nested_historical_cases") == 18)
    return {
        "scope": "logical248 old19, containing logical24524/logical24418",
        "exit": code, "exception": exception, "traceback": trace, "parse_error": parse_error,
        "stdout": stdout.getvalue(), "stderr": stderr.getvalue(), "marker": marker,
        "logical_input_before": logical_before, "logical_input_after": logical_after,
        "logical_exact": logical_exact, "view_reads": reads, "restored": restored,
        "historical_current_fields_are_logical_not_actual": True,
        "cases": parsed.get("current", {}).get("cases", 0) if parsed else 0,
        "nested245": parsed.get("historical", {}).get("cases", 0) if parsed else 0,
        "nested244": parsed.get("historical", {}).get("nested_historical_cases", 0) if parsed else 0,
        "passed": passed,
    }


def _mg9_main():
    before, after, fatal, trace = None, None, None, None
    results, parse_observation = [], None
    historical = {"passed": False, "cases": 0, "nested245": 0, "nested244": 0,
                  "skipped": "newest MG9 source controls have not passed"}
    counts = {"physical_binding_probe": 0, "MG9_source_errors": 0,
              "MG9_raw_projection": 0, "MG9_hash_projection": 0,
              "MG9_JA_call_contract": 0, "Chapter_actual_snapshot": 0,
              "parse_one_MP": 0, "historical248_main": 0,
              "collector": 0, "engine": 0, "numeric_validation": 0}
    try:
        before = _mg9_input_pins()
        binding_errors = _mg9_binding_errors(before)
        if binding_errors:
            raise AssertionError("; ".join(binding_errors))
        roster = MG9_SPEC["cases"]
        if sha256(_a11_canonical(roster)) != MG9_SPEC["provenance"]["cases_sha256"]:
            raise AssertionError("pre-code MG9 recipe/expectation digest drift")
        if (len(roster) != 23 or len({r["id"] for r in roster}) != 23
                or sum(r["kind"] == "normal" for r in roster) != 3
                or sum(r["kind"] == "negative" for r in roster) != 19
                or sum(r["kind"] == "OFF" for r in roster) != 1):
            raise AssertionError("pre-code MG9 roster shape drift")
        current = {p: (ROOT / p).read_bytes() for p in (*_MG9_SOURCE_PATHS, _MG9_SELF)}
        old248 = {p: _mg9_independent_inverse(raw, p) for p, raw in current.items()}
        successor = importlib.import_module("meta_title_locale_successor")
        pipeline = importlib.import_module("ja_translation_pipeline")
        chapter = importlib.import_module("chapter1_core_loop_v2_causal_ledger_check")
        if (successor.MG9_TRANSITIONS != MG9_BINDING["production_registry"]
                or successor._MG9_REGISTRY_SHA256 != MG9_BINDING["registry_sha256"]
                or [list(r) for r in successor.MG9_SOURCE_ROWS] != MG9_SPEC["source_rows18"]
                or successor.A11_TRANSITIONS != A11_BINDING["production_registry"]
                or [list(r) for r in successor.A11_SOURCE_ROWS] != A11_SPEC["source_rows22"]
                or successor.SUCCESSOR_TRANSITIONS != FROZEN["transitions"]
                or [list(r) for r in successor.SOURCE_ROWS] != FROZEN["source_rows20"]):
            raise AssertionError("MG9 or original source rows/registry drift")
        counts["parse_one_MP"] += 1
        calls, errors = pipeline.parse_ui_calls(MP, current[MP].decode("utf-8"))
        selected = len(calls) - len(_mg9_without_selected(calls))
        parse_observation = {"actual_calls": len(calls), "actual_selected": selected,
                             "actual_preserved": len(calls) - selected,
                             "predicted_calls": 83, "predicted_selected": 18,
                             "predicted_preserved": 65, "errors": errors}
        if errors or (len(calls), selected) != (83, 18):
            raise AssertionError("first complete MP parse differs; do not clip or reclassify")
        for case in roster:
            stdout, stderr = io.StringIO(), io.StringIO()
            with contextlib.redirect_stdout(stdout), contextlib.redirect_stderr(stderr):
                try:
                    if (case["recipe"]["op"] == "parse_complete_current_MP"
                            or case["expected_profile"] == "reject_calls"):
                        row = _mg9_call_case(case, calls, current, old248, pipeline, counts)
                    else:
                        row = _mg9_raw_case(case, current, old248, calls,
                                            successor, pipeline, chapter, counts)
                except Exception as error:
                    row = {"id": case["id"], "kind": case["kind"],
                           "base_id": case["base_id"], "passed": False,
                           "exception": type(error).__name__ + ": " + str(error),
                           "traceback": _a11_traceback.format_exc()}
            row["stdout"], row["stderr"] = stdout.getvalue(), stderr.getvalue()
            results.append(row)
        by_id = {r["id"]: r for r in results}
        normals_ok = all(by_id.get(c["id"], {}).get("passed")
                         for c in roster if c["kind"] == "normal")
        for row in results:
            base = row["base_id"]
            row["normal_base_passed"] = base is None or bool(by_id.get(base, {}).get("passed"))
            row["all_three_normals_passed"] = normals_ok
            row["valid_result"] = (row["passed"] and row["normal_base_passed"]
                                   and (row["kind"] == "normal" or normals_ok))
        if len(results) == 23 and all(r["valid_result"] for r in results):
            if before != _mg9_input_pins():
                raise AssertionError("actual inputs changed before historical248 view")
            historical = _mg9_historical248(old248, chapter, counts)
    except Exception as error:
        fatal = type(error).__name__ + ": " + str(error)
        trace = _a11_traceback.format_exc()
    finally:
        try:
            after = _mg9_input_pins()
        except Exception as error:
            fatal = (fatal or "") + "; after pins: " + type(error).__name__ + ": " + str(error)
    unchanged = before is not None and after is not None and before == after
    current_passed = (fatal is None and len(results) == 23
                      and all(r.get("valid_result") for r in results))
    passed = current_passed and historical["passed"] and unchanged
    output = {
        "scope": "MG9 newest23, separately labelled historical24819/24524/24418",
        "provenance": MG9_SPEC["provenance"], "binding": MG9_BINDING["binding_provenance"],
        "current": {"expected": 23, "normal": 3, "negative": 19, "OFF": 1,
                    "cases": len(results), "results": results, "passed": current_passed,
                    "valid_negative_count": sum(r["kind"] == "negative"
                                               and bool(r.get("valid_result")) for r in results)},
        "parse_observation": parse_observation, "historical": historical,
        "execution_counts": counts, "fatal": fatal, "traceback": trace,
        "physical_input_before": before, "physical_input_after": after,
        "physical_inputs_unchanged": unchanged,
        "limits": "Finite raw/consumer authority only; nested physical/current fields are logical. No collector/engine/native/render/human/full-product approval.",
        "passed": passed,
    }
    print(json.dumps(output, ensure_ascii=False, indent=2))
    print("META_TITLE_MG9_SOURCE_SELF_TEST_" + ("OK" if passed else "FAIL")
          + f" current={len(results)}/23 historical248={historical.get('cases', 0)}/19"
          + f" historical245={historical.get('nested245', 0)}/24"
          + f" historical244={historical.get('nested244', 0)}/18 unchanged={unchanged}")
    return 0 if passed else 1
# END_ORDER250_MG9_SELF


# BEGIN_TWO_DESC_SELF_254
# New physical description authority precedes unchanged logical23/19/24/18.
DESC_SPEC = json.loads(r'''{
  "unit_id": "ORDER-254",
  "phase": "PRECODE_FROZEN_INDEPENDENT_INPUTS_NOT_EXECUTED",
  "author": "Rawls",
  "approved_wording": {
    "path": ".git/full-game-localization/order254-desc-approved.json",
    "sha256": "91de1e8f9c2d61f54fd2830dec44ccf2401804cbef8954e23d48562aa2c2292a"
  },
  "baseline_mp": {
    "path": ".git/full-game-localization/order254-mp-before.gd",
    "bytes": 62214,
    "sha256": "edbcdfdefe7c547edac9a47b71a3892b6fe68c9553c982e914a151ea2e52921b"
  },
  "unchanged_ja": {
    "path": "tools/ja_translation_pipeline.py",
    "bytes": 255882,
    "sha256": "e2d666c19637fd20df8750187870e27cc1770c63d73db232e8035b8d072abe9c"
  },
  "independent_owner_patches": [
    {
      "id": "clean_run_title",
      "field": "desc",
      "catalog": "ALL_TITLES",
      "locale": "ko",
      "before": "\t{\"id\":\"clean_run_title\",    \"name\":\"청렴한 강남행\",      \"cat\":\"메타\", \"rare\":\"rare\",\n\t \"desc\":\"도박 없이 30억에 도달했다. 이 도시에서 끝까지 원칙을 지켰다.\"},\n",
      "after": "\t{\"id\":\"clean_run_title\",    \"name\":\"청렴한 강남행\",      \"cat\":\"메타\", \"rare\":\"rare\",\n\t \"desc\":\"도박판에서 손을 떼겠다고 시작한 인생. 마지막에 남은 자산은 30억 이상이었다.\"},\n"
    },
    {
      "id": "clean_run_title",
      "field": "desc",
      "catalog": "TITLE_EN",
      "locale": "en",
      "before": "\t\"clean_run_title\": {\"name\":\"Clean Road to Gangnam\", \"cat\":\"Meta\", \"desc\":\"Reached 3 billion won without gambling and held to your principles in this city.\"},\n",
      "after": "\t\"clean_run_title\": {\"name\":\"Clean Road to Gangnam\", \"cat\":\"Meta\", \"desc\":\"You began that life intending to leave gambling behind. It ended with at least 3 billion won in assets.\"},\n"
    },
    {
      "id": "father_peace_title",
      "field": "desc",
      "catalog": "ALL_TITLES",
      "locale": "ko",
      "before": "\t{\"id\":\"father_peace_title\", \"name\":\"마지막 봄\",          \"cat\":\"이야기\", \"rare\":\"uncommon\",\n\t \"desc\":\"아버지와 화해했다. 벚꽃이 피기 전에, 늦지 않게.\"},\n",
      "after": "\t{\"id\":\"father_peace_title\", \"name\":\"마지막 봄\",          \"cat\":\"이야기\", \"rare\":\"uncommon\",\n\t \"desc\":\"아버지와 화해했다. 둘 사이의 침묵이 조금 달라졌다.\"},\n"
    },
    {
      "id": "father_peace_title",
      "field": "desc",
      "catalog": "TITLE_EN",
      "locale": "en",
      "before": "\t\"father_peace_title\": {\"name\":\"Last Spring\", \"cat\":\"Story\", \"desc\":\"Made peace with your father. Before the cherry blossoms. Before it was too late.\"},\n",
      "after": "\t\"father_peace_title\": {\"name\":\"Last Spring\", \"cat\":\"Story\", \"desc\":\"Made peace with your father. The silence between you felt a little different.\"},\n"
    }
  ],
  "candidate_mp": {
    "bytes": 62261,
    "sha256": "b5c73771546c1fdc0d136aed45cdd14ee8e829fcc6aff88dfb607288cecf4f7d",
    "actual_applied": null,
    "meaning": "Deterministic private candidate from approved four owner fields; not current runtime observation"
  },
  "api": {
    "one_step": [
      "desc_source_errors(relative,current,registered_previous=None)",
      "desc_project_bytes(current,relative)",
      "desc_project_byte_hash(claim,relative,current)"
    ],
    "one_step_registered_previous": "edbcdfdefe7c547edac9a47b71a3892b6fe68c9553c982e914a151ea2e52921b",
    "public_mg9_registered_previous": "afe8bda86177950ef82fb8d2eea339ae398d59534897719c9b803bacf292a1b6",
    "registry": "DESC_TRANSITION; edits must not reseal _DESC_REGISTRY_SHA256",
    "legacy_ja_previous": "504b5ef8707568b199df35179b1753ab25706b2004fa3d0fc0fa879b18303906"
  },
  "cases": [
    {
      "id": "normal_current_mp",
      "kind": "normal",
      "normal_base": null,
      "recipe": {
        "base": "approved_candidate_mp"
      },
      "expected_reason": "Exact approved owner4 and unchanged whole remainder; one-step inverse restores edbc; public mg9 still projects to afe8.",
      "expected": {
        "desc_source": "PASS",
        "desc_projection": "baseline_mp",
        "public_source": "PASS",
        "public_projection": "previous_MG9_MP",
        "JA_live_calls": "unchanged",
        "Chapter_live_source": "PASS"
      },
      "materialized_input": {
        "bytes": 62261,
        "sha256": "b5c73771546c1fdc0d136aed45cdd14ee8e829fcc6aff88dfb607288cecf4f7d",
        "phase": "PRIVATE_RECIPE_BYTES_NOT_APPLIED"
      }
    },
    {
      "id": "normal_unchanged_ja",
      "kind": "normal",
      "normal_base": null,
      "recipe": {
        "base": "unchanged_ja"
      },
      "expected_reason": "New layer is MP-only; original public JA registration/source/projection behavior remains exact.",
      "expected": {
        "desc_source": "OFF_ERROR",
        "desc_projection": "identity",
        "public_source": "PASS",
        "public_projection": "previous_MG9_JA",
        "Chapter_live_source": "PASS"
      },
      "materialized_input": {
        "bytes": 255882,
        "sha256": "e2d666c19637fd20df8750187870e27cc1770c63d73db232e8035b8d072abe9c",
        "phase": "PRIVATE_RECIPE_BYTES_NOT_APPLIED"
      }
    },
    {
      "id": "rollback_clean_run_title_ko",
      "kind": "negative",
      "normal_base": "normal_current_mp",
      "recipe": {
        "base": "approved_candidate_mp",
        "exact_replacements": [
          {
            "before": "\t{\"id\":\"clean_run_title\",    \"name\":\"청렴한 강남행\",      \"cat\":\"메타\", \"rare\":\"rare\",\n\t \"desc\":\"도박판에서 손을 떼겠다고 시작한 인생. 마지막에 남은 자산은 30억 이상이었다.\"},\n",
            "after": "\t{\"id\":\"clean_run_title\",    \"name\":\"청렴한 강남행\",      \"cat\":\"메타\", \"rare\":\"rare\",\n\t \"desc\":\"도박 없이 30억에 도달했다. 이 도시에서 끝까지 원칙을 지켰다.\"},\n",
            "count": 1
          }
        ]
      },
      "expected_reason": "One approved owner field reverted; current whole/raw authority must reject.",
      "expected": {
        "desc_source": "REJECT",
        "desc_projection": "identity",
        "public_source": "REJECT",
        "public_projection": "identity",
        "hash_projection": "identity_claim",
        "JA_live_raw_gate": "REJECT",
        "Chapter_live_raw_gate": "REJECT"
      },
      "materialized_input": {
        "bytes": 62239,
        "sha256": "e3374f42f2e2f26a25f0ebc69aabfd526455819ceafe6d8bd16ee67fd93c6843",
        "phase": "PRIVATE_RECIPE_BYTES_NOT_APPLIED"
      }
    },
    {
      "id": "rollback_clean_run_title_en",
      "kind": "negative",
      "normal_base": "normal_current_mp",
      "recipe": {
        "base": "approved_candidate_mp",
        "exact_replacements": [
          {
            "before": "\t\"clean_run_title\": {\"name\":\"Clean Road to Gangnam\", \"cat\":\"Meta\", \"desc\":\"You began that life intending to leave gambling behind. It ended with at least 3 billion won in assets.\"},\n",
            "after": "\t\"clean_run_title\": {\"name\":\"Clean Road to Gangnam\", \"cat\":\"Meta\", \"desc\":\"Reached 3 billion won without gambling and held to your principles in this city.\"},\n",
            "count": 1
          }
        ]
      },
      "expected_reason": "One approved owner field reverted; current whole/raw authority must reject.",
      "expected": {
        "desc_source": "REJECT",
        "desc_projection": "identity",
        "public_source": "REJECT",
        "public_projection": "identity",
        "hash_projection": "identity_claim",
        "JA_live_raw_gate": "REJECT",
        "Chapter_live_raw_gate": "REJECT"
      },
      "materialized_input": {
        "bytes": 62238,
        "sha256": "04def49ef06b36599dbc682632a6037ea8ca7fa31039e2ec03797d6c546ced0f",
        "phase": "PRIVATE_RECIPE_BYTES_NOT_APPLIED"
      }
    },
    {
      "id": "rollback_father_peace_title_ko",
      "kind": "negative",
      "normal_base": "normal_current_mp",
      "recipe": {
        "base": "approved_candidate_mp",
        "exact_replacements": [
          {
            "before": "\t{\"id\":\"father_peace_title\", \"name\":\"마지막 봄\",          \"cat\":\"이야기\", \"rare\":\"uncommon\",\n\t \"desc\":\"아버지와 화해했다. 둘 사이의 침묵이 조금 달라졌다.\"},\n",
            "after": "\t{\"id\":\"father_peace_title\", \"name\":\"마지막 봄\",          \"cat\":\"이야기\", \"rare\":\"uncommon\",\n\t \"desc\":\"아버지와 화해했다. 벚꽃이 피기 전에, 늦지 않게.\"},\n",
            "count": 1
          }
        ]
      },
      "expected_reason": "One approved owner field reverted; current whole/raw authority must reject.",
      "expected": {
        "desc_source": "REJECT",
        "desc_projection": "identity",
        "public_source": "REJECT",
        "public_projection": "identity",
        "hash_projection": "identity_claim",
        "JA_live_raw_gate": "REJECT",
        "Chapter_live_raw_gate": "REJECT"
      },
      "materialized_input": {
        "bytes": 62256,
        "sha256": "0609fd16aa1ef8a51f2d21eb64a8a7e82c4c3439abcfa7d7bde758e2d80f5694",
        "phase": "PRIVATE_RECIPE_BYTES_NOT_APPLIED"
      }
    },
    {
      "id": "rollback_father_peace_title_en",
      "kind": "negative",
      "normal_base": "normal_current_mp",
      "recipe": {
        "base": "approved_candidate_mp",
        "exact_replacements": [
          {
            "before": "\t\"father_peace_title\": {\"name\":\"Last Spring\", \"cat\":\"Story\", \"desc\":\"Made peace with your father. The silence between you felt a little different.\"},\n",
            "after": "\t\"father_peace_title\": {\"name\":\"Last Spring\", \"cat\":\"Story\", \"desc\":\"Made peace with your father. Before the cherry blossoms. Before it was too late.\"},\n",
            "count": 1
          }
        ]
      },
      "expected_reason": "One approved owner field reverted; current whole/raw authority must reject.",
      "expected": {
        "desc_source": "REJECT",
        "desc_projection": "identity",
        "public_source": "REJECT",
        "public_projection": "identity",
        "hash_projection": "identity_claim",
        "JA_live_raw_gate": "REJECT",
        "Chapter_live_raw_gate": "REJECT"
      },
      "materialized_input": {
        "bytes": 62264,
        "sha256": "b5739a708e6be174d27cadf028933d9912d1d9874059c51f923fcb04a15a7043",
        "phase": "PRIVATE_RECIPE_BYTES_NOT_APPLIED"
      }
    },
    {
      "id": "replay_old_whole",
      "kind": "negative",
      "normal_base": "normal_current_mp",
      "recipe": {
        "base": "baseline_mp"
      },
      "expected_reason": "Historical edbc cannot acquire live current authority.",
      "expected": {
        "desc_source": "REJECT",
        "desc_projection": "identity",
        "public_source": "REJECT",
        "public_projection": "identity",
        "hash_projection": "identity_claim",
        "JA_live_raw_gate": "REJECT",
        "Chapter_live_raw_gate": "REJECT"
      },
      "materialized_input": {
        "bytes": 62214,
        "sha256": "edbcdfdefe7c547edac9a47b71a3892b6fe68c9553c982e914a151ea2e52921b",
        "phase": "PRIVATE_RECIPE_BYTES_NOT_APPLIED"
      }
    },
    {
      "id": "swap_approved_ko_owners",
      "kind": "negative",
      "normal_base": "normal_current_mp",
      "recipe": {
        "base": "approved_candidate_mp",
        "simultaneous_exact_replacements": [
          {
            "before": "\t{\"id\":\"clean_run_title\",    \"name\":\"청렴한 강남행\",      \"cat\":\"메타\", \"rare\":\"rare\",\n\t \"desc\":\"도박판에서 손을 떼겠다고 시작한 인생. 마지막에 남은 자산은 30억 이상이었다.\"},\n",
            "after": "\t{\"id\":\"clean_run_title\",    \"name\":\"청렴한 강남행\",      \"cat\":\"메타\", \"rare\":\"rare\",\n\t \"desc\":\"아버지와 화해했다. 둘 사이의 침묵이 조금 달라졌다.\"},\n",
            "count": 1
          },
          {
            "before": "\t{\"id\":\"father_peace_title\", \"name\":\"마지막 봄\",          \"cat\":\"이야기\", \"rare\":\"uncommon\",\n\t \"desc\":\"아버지와 화해했다. 둘 사이의 침묵이 조금 달라졌다.\"},\n",
            "after": "\t{\"id\":\"father_peace_title\", \"name\":\"마지막 봄\",          \"cat\":\"이야기\", \"rare\":\"uncommon\",\n\t \"desc\":\"도박판에서 손을 떼겠다고 시작한 인생. 마지막에 남은 자산은 30억 이상이었다.\"},\n",
            "count": 1
          }
        ]
      },
      "expected_reason": "Two correct strings on wrong owner IDs are not approved; EN remains unchanged.",
      "expected": {
        "desc_source": "REJECT",
        "desc_projection": "identity",
        "public_source": "REJECT",
        "public_projection": "identity",
        "hash_projection": "identity_claim",
        "JA_live_raw_gate": "REJECT",
        "Chapter_live_raw_gate": "REJECT"
      },
      "materialized_input": {
        "bytes": 62261,
        "sha256": "cd72d087bda628556876fea05f30ab489a7f90d0a97ef566feef6dccb0aec484",
        "phase": "PRIVATE_RECIPE_BYTES_NOT_APPLIED"
      }
    },
    {
      "id": "unselected_name",
      "kind": "negative",
      "normal_base": "normal_current_mp",
      "recipe": {
        "base": "approved_candidate_mp",
        "exact_replacements": [
          {
            "before": "\"name\":\"엘리트의 길\"",
            "after": "\"name\":\"엘리트의 날\"",
            "count": 1
          }
        ]
      },
      "expected_reason": "Non-owned name change rejected.",
      "expected": {
        "desc_source": "REJECT",
        "desc_projection": "identity",
        "public_source": "REJECT",
        "public_projection": "identity",
        "hash_projection": "identity_claim",
        "JA_live_raw_gate": "REJECT",
        "Chapter_live_raw_gate": "REJECT"
      },
      "materialized_input": {
        "bytes": 62261,
        "sha256": "e9f7e11a7016a79a581f531b792ebb849aab314a960fa594e1b62c58ea6b8287",
        "phase": "PRIVATE_RECIPE_BYTES_NOT_APPLIED"
      }
    },
    {
      "id": "condition_threshold",
      "kind": "negative",
      "normal_base": "normal_current_mp",
      "recipe": {
        "base": "approved_candidate_mp",
        "exact_replacements": [
          {
            "before": "\t\t\t\tif run.get(\"run_theme\",\"\") == \"청렴런\" and float(run.get(\"total_assets\",0)) >= 3_000_000_000: return true\n",
            "after": "\t\t\t\tif run.get(\"run_theme\",\"\") == \"청렴런\" and float(run.get(\"total_assets\",0)) >= 3_000_000_001: return true\n",
            "count": 1
          }
        ]
      },
      "expected_reason": "Condition byte/token is outside four description owners.",
      "expected": {
        "desc_source": "REJECT",
        "desc_projection": "identity",
        "public_source": "REJECT",
        "public_projection": "identity",
        "hash_projection": "identity_claim",
        "JA_live_raw_gate": "REJECT",
        "Chapter_live_raw_gate": "REJECT"
      },
      "materialized_input": {
        "bytes": 62261,
        "sha256": "5aa49b4a76cc0195fbfbee0c1136e2c48a60f6a82056128b8e79f5d82401cb26",
        "phase": "PRIVATE_RECIPE_BYTES_NOT_APPLIED"
      }
    },
    {
      "id": "extra_lf",
      "kind": "negative",
      "normal_base": "normal_current_mp",
      "recipe": {
        "base": "approved_candidate_mp",
        "append": "\n"
      },
      "expected_reason": "Whole raw strict LF boundary.",
      "expected": {
        "desc_source": "REJECT",
        "desc_projection": "identity",
        "public_source": "REJECT",
        "public_projection": "identity",
        "hash_projection": "identity_claim",
        "JA_live_raw_gate": "REJECT",
        "Chapter_live_raw_gate": "REJECT"
      },
      "materialized_input": {
        "bytes": 62262,
        "sha256": "97c2014691c3c2325b7e7db0f25e75d85aa9175e86e73ccc3436bcf69522f949",
        "phase": "PRIVATE_RECIPE_BYTES_NOT_APPLIED"
      }
    },
    {
      "id": "crlf",
      "kind": "negative",
      "normal_base": "normal_current_mp",
      "recipe": {
        "base": "approved_candidate_mp",
        "newline": "LF_to_CRLF"
      },
      "expected_reason": "CRLF cannot be silently normalized into approved raw.",
      "expected": {
        "desc_source": "REJECT",
        "desc_projection": "identity",
        "public_source": "REJECT",
        "public_projection": "identity",
        "hash_projection": "identity_claim",
        "JA_live_raw_gate": "REJECT",
        "Chapter_live_raw_gate": "REJECT"
      },
      "materialized_input": {
        "bytes": 63322,
        "sha256": "100c869cb2121289822b463a24ce5fde85565672b64ada72b4e29c7f5164b827",
        "phase": "PRIVATE_RECIPE_BYTES_NOT_APPLIED"
      }
    },
    {
      "id": "forged_observation",
      "kind": "negative",
      "normal_base": "normal_current_mp",
      "recipe": {
        "base": "approved_candidate_mp",
        "append": "\n",
        "claimed_sha256": "b5c73771546c1fdc0d136aed45cdd14ee8e829fcc6aff88dfb607288cecf4f7d",
        "mock_observed_hash": "b5c73771546c1fdc0d136aed45cdd14ee8e829fcc6aff88dfb607288cecf4f7d"
      },
      "expected_reason": "Actual mutated bytes must be rejected by live raw gate even when digest observer and supplied claim report approved current.",
      "expected": {
        "desc_source": "REJECT",
        "desc_projection": "identity",
        "public_source": "REJECT",
        "public_projection": "identity",
        "hash_projection": "identity_claim",
        "JA_live_raw_gate": "REJECT",
        "Chapter_live_raw_gate": "REJECT"
      },
      "materialized_input": {
        "bytes": 62262,
        "sha256": "97c2014691c3c2325b7e7db0f25e75d85aa9175e86e73ccc3436bcf69522f949",
        "phase": "PRIVATE_RECIPE_BYTES_NOT_APPLIED"
      }
    },
    {
      "id": "wrong_previous_registry",
      "kind": "negative",
      "normal_base": "normal_current_mp",
      "recipe": {
        "base": "approved_candidate_mp",
        "registry_edit": {
          "path": [
            "previous_sha256"
          ],
          "value": "afe8bda86177950ef82fb8d2eea339ae398d59534897719c9b803bacf292a1b6",
          "semantic_value": "MG9_CURRENT_PREDECESSOR_AFE8"
        }
      },
      "expected_reason": "Skip to afe8 is not the edbc immediate description predecessor.",
      "expected": {
        "desc_source": "REJECT",
        "desc_projection": "identity",
        "public_source": "REJECT",
        "public_projection": "identity",
        "hash_projection": "identity_claim",
        "JA_live_raw_gate": "REJECT",
        "Chapter_live_raw_gate": "REJECT"
      },
      "materialized_input": {
        "bytes": 62261,
        "sha256": "b5c73771546c1fdc0d136aed45cdd14ee8e829fcc6aff88dfb607288cecf4f7d",
        "phase": "PRIVATE_RECIPE_BYTES_NOT_APPLIED"
      }
    },
    {
      "id": "missing_inverse",
      "kind": "negative",
      "normal_base": "normal_current_mp",
      "recipe": {
        "base": "approved_candidate_mp",
        "registry_edit": {
          "operation": "delete",
          "path": [
            "patches",
            0
          ]
        }
      },
      "expected_reason": "Registered inverse must contain all four distinct owner patches; registry seal unchanged.",
      "expected": {
        "desc_source": "REJECT",
        "desc_projection": "identity",
        "public_source": "REJECT",
        "public_projection": "identity",
        "hash_projection": "identity_claim",
        "JA_live_raw_gate": "REJECT",
        "Chapter_live_raw_gate": "REJECT"
      },
      "materialized_input": {
        "bytes": 62261,
        "sha256": "b5c73771546c1fdc0d136aed45cdd14ee8e829fcc6aff88dfb607288cecf4f7d",
        "phase": "PRIVATE_RECIPE_BYTES_NOT_APPLIED"
      }
    },
    {
      "id": "duplicate_inverse",
      "kind": "negative",
      "normal_base": "normal_current_mp",
      "recipe": {
        "base": "approved_candidate_mp",
        "registry_edit": {
          "operation": "append_copy",
          "path": [
            "patches"
          ],
          "index": 0
        }
      },
      "expected_reason": "Duplicated owner inverse rejected even if literal itself is approved; registry seal unchanged.",
      "expected": {
        "desc_source": "REJECT",
        "desc_projection": "identity",
        "public_source": "REJECT",
        "public_projection": "identity",
        "hash_projection": "identity_claim",
        "JA_live_raw_gate": "REJECT",
        "Chapter_live_raw_gate": "REJECT"
      },
      "materialized_input": {
        "bytes": 62261,
        "sha256": "b5c73771546c1fdc0d136aed45cdd14ee8e829fcc6aff88dfb607288cecf4f7d",
        "phase": "PRIVATE_RECIPE_BYTES_NOT_APPLIED"
      }
    },
    {
      "id": "wrong_claim_only",
      "kind": "claim_probe",
      "normal_base": "normal_current_mp",
      "recipe": {
        "base": "approved_candidate_mp",
        "claimed_sha256": "0000000000000000000000000000000000000000000000000000000000000000"
      },
      "expected_reason": "Valid raw remains authorized, pure inverse valid; hash projector preserves the false claim.",
      "expected": {
        "desc_source": "PASS",
        "desc_projection": "baseline_mp",
        "public_source": "PASS",
        "hash_projection": "identity_claim",
        "Chapter_live_source": "PASS"
      },
      "materialized_input": {
        "bytes": 62261,
        "sha256": "b5c73771546c1fdc0d136aed45cdd14ee8e829fcc6aff88dfb607288cecf4f7d",
        "phase": "PRIVATE_RECIPE_BYTES_NOT_APPLIED"
      }
    },
    {
      "id": "unowned_path",
      "kind": "OFF",
      "normal_base": null,
      "recipe": {
        "base": "approved_candidate_mp",
        "relative": "autoloads/NotMetaProgression.gd"
      },
      "expected_reason": "New MP-only rejection and identity; public old unsupported-path errors/projection remain exactly baseline, not None.",
      "expected": {
        "desc_source": "OFF_ERROR",
        "desc_projection": "identity",
        "public_source": "OLD_OFF_EXACT",
        "hash_projection": "identity_claim"
      },
      "materialized_input": {
        "bytes": 62261,
        "sha256": "b5c73771546c1fdc0d136aed45cdd14ee8e829fcc6aff88dfb607288cecf4f7d",
        "phase": "PRIVATE_RECIPE_BYTES_NOT_APPLIED"
      }
    }
  ],
  "counts": {
    "normal": 2,
    "negative": 14,
    "claim_probe": 1,
    "OFF": 1,
    "total": 18
  },
  "evaluation_contract": {
    "precode": "helper_absent is absence, not new OFF semantics. Evaluate original public/live gates once on these frozen bytes; preserve all original errors/stdout/stderr/exit; normal MP expected blocked under edbc guard.",
    "post": "same raw18 once; capture all results before assertion; both normal cases must pass respective public/live contracts before effective negative count can be14.",
    "consumer_scope": "same input recipes through original JA owner entry and actual Chapter raw snapshot; hash-only spoof must not bypass raw read. No direct dummy source_errors replacement. Registry mutation is scoped to new registry, leaving seal unchanged.",
    "normal_failure_effective_negatives": 0,
    "exception": "record unexpected exceptions separately and restore all temporary patches/capture streams; no exception becomes REJECT",
    "raw_identity": "every rejected projector returns original exact bytes; wrong claim-only returns its supplied64hex claim"
  },
  "execution": {
    "repository_imports": 0,
    "tests": 0,
    "collector": 0,
    "engine": 0,
    "product_writes": 0
  },
  "cases_sha256": "9a1a3a5295c9ae40ccb09dc87ab59da0898a68e87f9ffffc970b4705f3c04a63"
}''')
DESC_BINDING = json.loads(r'''{
  "phase": "APPLIED_SOURCE_BOUND",
  "provenance": {
    "approved_wording_sha256": "91de1e8f9c2d61f54fd2830dec44ccf2401804cbef8954e23d48562aa2c2292a",
    "fixed18_sha256": "1804a8194bccd71894f4e1baf2aa98ee72e407e5169f2820bfd68bee93f8f6a0",
    "actual_applied_pins": {
      "autoloads/MetaProgression.gd": {"bytes": 62261, "sha256": "b5c73771546c1fdc0d136aed45cdd14ee8e829fcc6aff88dfb607288cecf4f7d"},
      "tools/meta_title_locale_successor.py": {"bytes": 34883, "sha256": "07c6d0d9cbd8fa21dcabcd7472977ca35b480d95218a6de8bf7345d312981779"}
    },
    "first_baseline": {"path": ".git/full-game-localization/order254-baseline-first.json", "bytes": 428756, "sha256": "17e5f4d9d697aacb2b31398abcb4b2142e6185e86b28223017220936c6dd053e", "head": "d0ca4d939ea7e3b926296602fc2b79f2302d252d", "capture_complete": true, "effective_negative_count": 0},
    "independent_helper_controls": "7bab378fc130715658f707317f5d634db7876c6b143c97ed266f167dda70a8a5",
    "independent_self_v1": "47e3288d75d406d2fb0a7cf8592e70a51fe4fddf5f141c6177ed5447a1e9263c",
    "chronology": "ROOT read full fixed18/helper/self and two independent reports; v2 self differs only in helper bytes/SHA. First original18 capture precedes application. Actual MP/helper pins above measured after apply; only provenance/OFF changes authorize first post execution, not a PASS.",
    "post_execution_at_binding": 0
  },
  "candidate_pins": {
    "autoloads/MetaProgression.gd": {
      "bytes": 62261,
      "sha256": "b5c73771546c1fdc0d136aed45cdd14ee8e829fcc6aff88dfb607288cecf4f7d"
    },
    "tools/meta_title_locale_successor.py": {
      "bytes": 34883,
      "sha256": "07c6d0d9cbd8fa21dcabcd7472977ca35b480d95218a6de8bf7345d312981779"
    }
  },
  "previous_pins": {
    "autoloads/MetaProgression.gd": {
      "bytes": 62214,
      "sha256": "edbcdfdefe7c547edac9a47b71a3892b6fe68c9553c982e914a151ea2e52921b"
    },
    "tools/meta_title_locale_successor.py": {
      "bytes": 27372,
      "sha256": "5cbe5de2669a83d36c5d17c9b3d64293505737c399ce063324f38de8224eac81"
    },
    "tools/meta_title_locale_successor_self_test.py": {
      "bytes": 136612,
      "sha256": "f09bca5c3b50494e1f66ad0f31d22b77179d8c875deea6811746354ef8364c1f"
    },
    "tools/ja_translation_pipeline.py": {
      "bytes": 255882,
      "sha256": "e2d666c19637fd20df8750187870e27cc1770c63d73db232e8035b8d072abe9c"
    },
    "tools/chapter1_core_loop_v2_causal_ledger_check.py": {
      "bytes": 1461830,
      "sha256": "ac874ad1587304b4f1802ce2311cbcba231e1fdfb19086cce3a66aa19ee5fac3"
    }
  },
  "previous_MG9_MP": {
    "bytes": 59337,
    "sha256": "afe8bda86177950ef82fb8d2eea339ae398d59534897719c9b803bacf292a1b6"
  },
  "previous_MG9_JA": {
    "bytes": 248524,
    "sha256": "504b5ef8707568b199df35179b1753ab25706b2004fa3d0fc0fa879b18303906"
  },
  "production_registry": {
    "path": "autoloads/MetaProgression.gd",
    "previous_sha256": "edbcdfdefe7c547edac9a47b71a3892b6fe68c9553c982e914a151ea2e52921b",
    "current_sha256": "b5c73771546c1fdc0d136aed45cdd14ee8e829fcc6aff88dfb607288cecf4f7d",
    "patches": [
      {
        "catalog": "ALL_TITLES",
        "owner": "clean_run_title",
        "field": "desc",
        "before": "\t{\"id\":\"clean_run_title\",    \"name\":\"청렴한 강남행\",      \"cat\":\"메타\", \"rare\":\"rare\",\n\t \"desc\":\"도박 없이 30억에 도달했다. 이 도시에서 끝까지 원칙을 지켰다.\"},\n",
        "after": "\t{\"id\":\"clean_run_title\",    \"name\":\"청렴한 강남행\",      \"cat\":\"메타\", \"rare\":\"rare\",\n\t \"desc\":\"도박판에서 손을 떼겠다고 시작한 인생. 마지막에 남은 자산은 30억 이상이었다.\"},\n"
      },
      {
        "catalog": "TITLE_EN",
        "owner": "clean_run_title",
        "field": "desc",
        "before": "\t\"clean_run_title\": {\"name\":\"Clean Road to Gangnam\", \"cat\":\"Meta\", \"desc\":\"Reached 3 billion won without gambling and held to your principles in this city.\"},\n",
        "after": "\t\"clean_run_title\": {\"name\":\"Clean Road to Gangnam\", \"cat\":\"Meta\", \"desc\":\"You began that life intending to leave gambling behind. It ended with at least 3 billion won in assets.\"},\n"
      },
      {
        "catalog": "ALL_TITLES",
        "owner": "father_peace_title",
        "field": "desc",
        "before": "\t{\"id\":\"father_peace_title\", \"name\":\"마지막 봄\",          \"cat\":\"이야기\", \"rare\":\"uncommon\",\n\t \"desc\":\"아버지와 화해했다. 벚꽃이 피기 전에, 늦지 않게.\"},\n",
        "after": "\t{\"id\":\"father_peace_title\", \"name\":\"마지막 봄\",          \"cat\":\"이야기\", \"rare\":\"uncommon\",\n\t \"desc\":\"아버지와 화해했다. 둘 사이의 침묵이 조금 달라졌다.\"},\n"
      },
      {
        "catalog": "TITLE_EN",
        "owner": "father_peace_title",
        "field": "desc",
        "before": "\t\"father_peace_title\": {\"name\":\"Last Spring\", \"cat\":\"Story\", \"desc\":\"Made peace with your father. Before the cherry blossoms. Before it was too late.\"},\n",
        "after": "\t\"father_peace_title\": {\"name\":\"Last Spring\", \"cat\":\"Story\", \"desc\":\"Made peace with your father. The silence between you felt a little different.\"},\n"
      }
    ]
  },
  "registry_sha256": "6d7962acd9d554d27ef383e6b3d62f3b7e7512597740c412bbe356bba60eece9"
}''')
DESC_BASELINE_OFF = ["ORDER-250: MG9 successor path is not owned"]  # First original18 capture, not new OFF semantics.
_DESC_HELPER = "tools/meta_title_locale_successor.py"
_DESC_SELF = "tools/meta_title_locale_successor_self_test.py"


def _desc_inverse(raw, relative):
    """Independent literal inverse; never call the implementation projector."""
    if relative == MP:
        out = raw
        for item in DESC_SPEC["independent_owner_patches"]:
            after, before = item["after"].encode(), item["before"].encode()
            if out.count(after) != 1 or out.count(before) != 0:
                raise AssertionError("description owner inverse is not exact1")
            out = out.replace(after, before, 1)
    elif relative == _DESC_HELPER:
        marker = b"\n# BEGIN_TWO_DESC_HISTORY_254\n"
        if raw.count(marker) != 1 or not raw.endswith(b"# END_TWO_DESC_HISTORY_254\n"):
            raise AssertionError("description helper append boundary differs")
        # Append starts with two LF bytes after the old EOF LF.
        index = raw.index(marker)
        out = raw[:index - 1]
    elif relative == _DESC_SELF:
        start = b"\n# BEGIN_TWO_DESC_SELF_254\n"
        end = b"# END_TWO_DESC_SELF_254\n"
        if raw.count(start) != 1 or raw.count(end) != 1:
            raise AssertionError("description self boundary differs")
        a, z = raw.index(start), raw.index(end) + len(end)
        out = raw[:a - 1] + raw[z:]
        current = b"    raise SystemExit(_desc_main())"
        previous = b"    raise SystemExit(_mg9_main())"
        if out.count(current) != 1:
            raise AssertionError("description CLI hook differs")
        out = out.replace(current, previous, 1)
    else:
        out = raw
    expected = DESC_BINDING["previous_pins"].get(relative)
    if expected is not None and pin(out) != expected:
        raise AssertionError("description independent whole inverse differs: " + relative)
    return out


def _desc_materialize(case, current, previous):
    recipe = case["recipe"]
    raw = {"approved_candidate_mp": current[MP], "baseline_mp": previous[MP],
           "unchanged_ja": current[JA]}[recipe["base"]]
    for change in recipe.get("exact_replacements", []):
        before, after = change["before"].encode(), change["after"].encode()
        if raw.count(before) != change["count"]:
            raise AssertionError("frozen description mutation anchor differs")
        raw = raw.replace(before, after, change["count"])
    simultaneous = recipe.get("simultaneous_exact_replacements", [])
    spans = []
    for change in simultaneous:
        before, after = change["before"].encode(), change["after"].encode()
        if raw.count(before) != change["count"] or change["count"] != 1:
            raise AssertionError("frozen owner swap anchor differs")
        spans.append((raw.index(before), len(before), after))
    for index, length, after in sorted(spans, reverse=True):
        raw = raw[:index] + after + raw[index + length:]
    if "append" in recipe:
        raw += recipe["append"].encode()
    if recipe.get("newline") == "LF_to_CRLF":
        if b"\r" in raw:
            raise AssertionError("CRLF mutation requires literal LF base")
        raw = raw.replace(b"\n", b"\r\n")
    expected = case["materialized_input"]
    if pin(raw) != {"bytes": expected["bytes"], "sha256": expected["sha256"]}:
        raise AssertionError("frozen description input pin differs: " + case["id"])
    return raw


def _desc_registry_context(case, successor):
    edit = case["recipe"].get("registry_edit")
    if edit is None:
        return contextlib.nullcontext()
    value = copy.deepcopy(successor.DESC_TRANSITION)
    parent = value
    for key in edit["path"][:-1]:
        parent = parent[key]
    key = edit["path"][-1]
    if edit.get("operation") == "delete":
        del parent[key]
    elif edit.get("operation") == "append_copy":
        parent[key].append(copy.deepcopy(parent[key][edit["index"]]))
    else:
        parent[key] = edit["value"]
    return patch.object(successor, "DESC_TRANSITION", value)


def _desc_live(case, path, raw, claim, current, calls, successor, pipeline, chapter, counts):
    """Actual unchanged JA owner entry and Chapter raw snapshot; providers only."""
    if case["kind"] == "OFF":
        return {"skipped": "unowned path has no real MP/JA consumer"}
    actual_mp = raw if path == MP else current[MP]
    actual_ja = raw if path == JA else current[JA]
    original_read, original_digest = Path.read_bytes, chapter._file_digest
    original_old_gate = chapter._order248_meta_source_errors
    reads, hashes, old_gates = [], [], []

    def read_bytes(file):
        if file == ROOT / MP:
            reads.append(MP)
            return actual_mp
        if file == ROOT / JA:
            reads.append(JA)
            return actual_ja
        return original_read(file)

    def digest(relative):
        if relative == MP:
            hashes.append(relative)
            return case["recipe"].get("mock_observed_hash", claim) if path == MP else sha256(actual_mp)
        return original_digest(relative)

    def old_gate(relative, source, registered):
        old_gates.append({"path": relative, "input": pin(source)})
        return original_old_gate(relative, source, registered)

    with contextlib.ExitStack() as stack:
        stack.enter_context(patch.object(Path, "read_bytes", read_bytes))
        stack.enter_context(patch.object(chapter, "_file_digest", digest))
        stack.enter_context(patch.object(chapter, "_order248_meta_source_errors", old_gate))
        counts["JA_owner_entry"] += 1
        out_calls, out_source, ja_errors = pipeline._mg9_meta_title_predecessor_calls(calls)
        counts["Chapter_source_entry"] += 1
        source_errors = chapter._order250_meta_source_errors(
            MP, actual_mp, FROZEN["historical_mp"]["sha256"])
        counts["Chapter_actual_snapshot"] += 1
        snapshot_errors = chapter._audited_source_snapshot_errors(
            {MP: FROZEN["historical_mp"]["sha256"]})
    restored = (Path.read_bytes is original_read and chapter._file_digest is original_digest
                and chapter._order248_meta_source_errors is original_old_gate)
    valid_raw = case["kind"] in ("normal", "claim_probe")
    expected_source = (DESC_BINDING["previous_MG9_MP"] if valid_raw else pin(actual_mp))
    checks = {
        "JA_raw_gate": isinstance(ja_errors, list) and (not ja_errors) == valid_raw,
        "JA_calls": tuple(out_calls) == (_mg9_without_selected(calls) if valid_raw else tuple(calls)),
        "JA_source": pin(out_source.encode()) == expected_source,
        "Chapter_source": isinstance(source_errors, list) and (not source_errors) == valid_raw,
        "Chapter_snapshot": (isinstance(snapshot_errors, list)
                             and (not snapshot_errors) == (case["kind"] == "normal")),
        "actual_raw_read": MP in reads and JA in reads,
        "reader_restore": restored,
        "old_chain_only_after_new_raw": valid_raw or not old_gates,
    }
    return {"JA_errors": ja_errors, "JA_calls": len(out_calls),
            "JA_output_source": pin(out_source.encode()), "Chapter_source_errors": source_errors,
            "Chapter_snapshot_errors": snapshot_errors, "raw_reads": reads,
            "digest_reads": hashes, "old248_entries": old_gates,
            "provider_patches": ["Path.read_bytes(MP,JA)", "Chapter._file_digest(MP)",
                                 "Chapter._order248_meta_source_errors(call-through observer)"],
            "checks": checks, "passed": all(checks.values())}


def _desc_case(case, current, previous, calls, successor, pipeline, chapter, counts):
    raw = _desc_materialize(case, current, previous)
    path = case["recipe"].get("relative", JA if case["recipe"]["base"] == "unchanged_ja" else MP)
    claim = case["recipe"].get("claimed_sha256", sha256(raw))
    registered = (DESC_SPEC["api"]["legacy_ja_previous"] if path == JA
                  else DESC_SPEC["api"]["public_mg9_registered_previous"] if path == MP else None)
    registry = copy.deepcopy(successor.DESC_TRANSITION)
    with _desc_registry_context(case, successor):
        counts["one_step_source"] += 1
        errors = successor.desc_source_errors(path, raw)
        counts["one_step_bytes"] += 1
        projected = successor.desc_project_bytes(raw, path)
        counts["one_step_hash"] += 1
        projected_hash = successor.desc_project_byte_hash(claim, path, raw)
        counts["public_source"] += 1
        public_errors = successor.mg9_source_errors(path, raw, registered)
        counts["public_bytes"] += 1
        public_bytes = successor.mg9_project_bytes(raw, path)
        counts["public_hash"] += 1
        public_hash = successor.mg9_project_byte_hash(claim, path, raw)
        live = _desc_live(case, path, raw, claim, current, calls, successor, pipeline, chapter, counts)
    one_valid = case["expected"]["desc_source"] == "PASS"
    public_valid = case["expected"]["public_source"] == "PASS"
    wanted = previous[MP] if one_valid else raw
    wanted_public_pin = (DESC_BINDING["previous_MG9_JA"] if path == JA
                         else DESC_BINDING["previous_MG9_MP"]) if public_valid else pin(raw)
    wrong_claim = claim != sha256(raw)
    checks = {
        "one_step_source": isinstance(errors, list) and (not errors) == one_valid,
        "one_step_bytes": projected == wanted,
        "one_step_hash": projected_hash == (sha256(wanted) if one_valid and not wrong_claim else claim),
        "public_source": isinstance(public_errors, list) and (not public_errors) == public_valid,
        "public_bytes": pin(public_bytes) == wanted_public_pin,
        "public_hash": public_hash == (wanted_public_pin["sha256"] if public_valid and not wrong_claim else claim),
        "registry_restore": successor.DESC_TRANSITION == registry,
        "live": live.get("passed", case["kind"] == "OFF"),
    }
    if case["kind"] == "OFF":
        checks["OFF_original_errors"] = public_errors == DESC_BASELINE_OFF
        checks["OFF_exact_bytes"] = public_bytes == raw
    return {"id": case["id"], "kind": case["kind"], "normal_base": case["normal_base"],
            "input": pin(raw), "path": path, "claim": claim, "registered_previous": registered,
            "desc_source_errors": errors, "desc_projection": pin(projected),
            "desc_projected_hash": projected_hash, "public_source_errors": public_errors,
            "public_projection": pin(public_bytes), "public_projected_hash": public_hash,
            "live": live, "checks": checks, "passed": all(checks.values())}


def _desc_historical(previous, successor, counts):
    """Restore only file views/public API dispatch; every old method stays whole."""
    read0, text0 = Path.read_bytes, Path.read_text
    stdout0, stderr0 = sys.stdout, sys.stderr
    api0 = (successor.mg9_source_errors, successor.mg9_project_bytes,
            successor.mg9_project_byte_hash)
    reads = {p: 0 for p in previous}
    stdout, stderr = io.StringIO(), io.StringIO()

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

    def source(relative, raw, registered_previous=None):
        return successor._DESC_OLD_MG9_SOURCE_ERRORS(relative, raw, registered_previous)

    def project(raw, relative):
        return successor._DESC_OLD_MG9_PROJECT_BYTES(raw, relative)

    def observed(claim, relative, raw):
        return successor._DESC_OLD_MG9_PROJECT_HASH(claim, relative, raw)

    code, exception, trace = None, None, None
    with contextlib.ExitStack() as stack:
        stack.enter_context(patch.object(Path, "read_bytes", read_bytes))
        stack.enter_context(patch.object(Path, "read_text", read_text))
        for name, function in (("mg9_source_errors", source), ("mg9_project_bytes", project),
                               ("mg9_project_byte_hash", observed)):
            stack.enter_context(patch.object(successor, name, function))
        stack.enter_context(contextlib.redirect_stdout(stdout))
        stack.enter_context(contextlib.redirect_stderr(stderr))
        counts["historical_MG9_main"] += 1
        try:
            code = _mg9_main()
        except Exception as error:
            exception = type(error).__name__ + ": " + str(error)
            trace = _a11_traceback.format_exc()
    restored = (Path.read_bytes is read0 and Path.read_text is text0
                and sys.stdout is stdout0 and sys.stderr is stderr0
                and (successor.mg9_source_errors, successor.mg9_project_bytes,
                     successor.mg9_project_byte_hash) == api0)
    parsed, marker, parse_error = None, None, None
    try:
        parsed, end = json.JSONDecoder().raw_decode(stdout.getvalue())
        marker = stdout.getvalue()[end:].strip()
    except (ValueError, TypeError) as error:
        parse_error = type(error).__name__ + ": " + str(error)
    before = parsed.get("physical_input_before") if isinstance(parsed, dict) else None
    after = parsed.get("physical_input_after") if isinstance(parsed, dict) else None
    logical_exact = (isinstance(before, dict) and before == after
                     and all(before.get(p) == pin(raw) for p, raw in previous.items()))
    wanted = ("META_TITLE_MG9_SOURCE_SELF_TEST_OK current=23/23 historical248=19/19"
              " historical245=24/24 historical244=18/18 unchanged=True")
    passed = (code == 0 and exception is None and restored and not stderr.getvalue()
              and parse_error is None and marker == wanted and logical_exact
              and parsed.get("passed") is True
              and parsed.get("current", {}).get("cases") == 23
              and len(parsed.get("current", {}).get("results", [])) == 23
              and all(r.get("valid_result") for r in parsed["current"]["results"])
              and parsed.get("historical", {}).get("passed") is True)
    return {"scope": "logical25023 -> logical24819 -> logical24524 -> logical24418",
            "exit": code, "exception": exception, "traceback": trace, "parse_error": parse_error,
            "stdout": stdout.getvalue(), "stderr": stderr.getvalue(), "marker": marker,
            "logical_input_before": before, "logical_input_after": after,
            "logical_exact": logical_exact, "view_reads": reads, "restored": restored,
            "physical_current_fields_below_are_logical": True, "passed": passed}


def _desc_main():
    before, after, fatal, trace = None, None, None, None
    results, parse_observation = [], None
    historical = {"passed": False, "skipped": "new physical18 not passed", "exit": None}
    counts = {name: 0 for name in ("one_step_source", "one_step_bytes", "one_step_hash",
                                  "public_source", "public_bytes", "public_hash",
                                  "JA_owner_entry", "Chapter_source_entry", "Chapter_actual_snapshot",
                                  "parse_one_MP", "historical_MG9_main", "collector", "engine")}
    try:
        before = _mg9_input_pins()
        if DESC_BINDING["phase"] != "APPLIED_SOURCE_BOUND" or not isinstance(DESC_BASELINE_OFF, list):
            raise AssertionError("private candidate/baseline is not authorized for execution")
        for relative, expected in DESC_BINDING["candidate_pins"].items():
            if before.get(relative) != expected:
                raise AssertionError("description actual source pin differs: " + relative)
        current = {p: (ROOT / p).read_bytes() for p in (*_MG9_SOURCE_PATHS, _MG9_SELF)}
        previous = {p: _desc_inverse(raw, p) for p, raw in current.items()}
        logical = dict(before)
        logical.update({p: pin(raw) for p, raw in previous.items()})
        errors = _mg9_binding_errors(logical)
        if errors:
            raise AssertionError("; ".join(errors))
        roster = DESC_SPEC["cases"]
        if sha256(_a11_canonical(roster)) != DESC_SPEC["cases_sha256"]:
            raise AssertionError("independent18 literal digest changed")
        if (len(roster) != 18 or len({c["id"] for c in roster}) != 18
                or {k: sum(c["kind"] == k for c in roster) for k in
                    ("normal", "negative", "claim_probe", "OFF")}
                != {"normal": 2, "negative": 14, "claim_probe": 1, "OFF": 1}):
            raise AssertionError("independent18 roster drifted")
        successor = importlib.import_module("meta_title_locale_successor")
        pipeline = importlib.import_module("ja_translation_pipeline")
        chapter = importlib.import_module("chapter1_core_loop_v2_causal_ledger_check")
        if (successor.DESC_TRANSITION != DESC_BINDING["production_registry"]
                or successor._DESC_REGISTRY_SHA256 != DESC_BINDING["registry_sha256"]):
            raise AssertionError("new description registry differs from frozen binding")
        counts["parse_one_MP"] += 1
        calls, errors = pipeline.parse_ui_calls(MP, current[MP].decode())
        parse_observation = {"calls": len(calls), "errors": errors,
                             "selected_MG9": len(calls) - len(_mg9_without_selected(calls))}
        if errors or parse_observation != {"calls": 83, "errors": [], "selected_MG9": 18}:
            raise AssertionError("description-only change unexpectedly changed actual UI calls")
        for case in roster:
            stdout, stderr = io.StringIO(), io.StringIO()
            with contextlib.redirect_stdout(stdout), contextlib.redirect_stderr(stderr):
                try:
                    row = _desc_case(case, current, previous, calls,
                                     successor, pipeline, chapter, counts)
                except Exception as error:
                    row = {"id": case["id"], "kind": case["kind"],
                           "normal_base": case["normal_base"], "passed": False,
                           "exception": type(error).__name__ + ": " + str(error),
                           "traceback": _a11_traceback.format_exc()}
            row["stdout"], row["stderr"] = stdout.getvalue(), stderr.getvalue()
            results.append(row)
        by_id = {r["id"]: r for r in results}
        normals_ok = all(by_id.get(c["id"], {}).get("passed")
                         for c in roster if c["kind"] == "normal")
        for row in results:
            base = row["normal_base"]
            row["normal_base_passed"] = base is None or bool(by_id.get(base, {}).get("passed"))
            row["all_two_normals_passed"] = normals_ok
            row["valid_result"] = (row["passed"] and row["normal_base_passed"]
                                   and (row["kind"] == "normal" or normals_ok))
        if len(results) == 18 and all(r["valid_result"] for r in results):
            if before != _mg9_input_pins():
                raise AssertionError("physical inputs changed before historical dispatch")
            historical = _desc_historical(previous, successor, counts)
    except Exception as error:
        fatal = type(error).__name__ + ": " + str(error)
        trace = _a11_traceback.format_exc()
    finally:
        try:
            after = _mg9_input_pins()
        except Exception as error:
            fatal = (fatal or "") + "; after pins: " + type(error).__name__ + ": " + str(error)
    unchanged = before is not None and before == after
    current_ok = fatal is None and len(results) == 18 and all(r.get("valid_result") for r in results)
    passed = current_ok and historical["passed"] and unchanged
    print(json.dumps({
        "scope": "physical description18, separately historical23/19/24/18",
        "binding": DESC_BINDING["provenance"],
        "current": {"cases": len(results), "normal": 2, "negative": 14, "claim_probe": 1,
                    "OFF": 1, "results": results, "passed": current_ok,
                    "valid_negative_count": sum(r["kind"] == "negative"
                                               and bool(r.get("valid_result")) for r in results)},
        "parse_observation": parse_observation, "historical": historical,
        "execution_counts": counts, "fatal": fatal, "traceback": trace,
        "physical_input_before": before, "physical_input_after": after,
        "physical_inputs_unchanged": unchanged, "passed": passed,
        "limits": "Finite source/consumer authority; no collector, engine, translation acceptance or human observation."
    }, ensure_ascii=False, indent=2))
    print("META_TITLE_DESC_SOURCE_SELF_TEST_" + ("OK" if passed else "FAIL")
          + f" current={len(results)}/18 historical23_19_24_18={historical['passed']} unchanged={unchanged}")
    return 0 if passed else 1
# END_TWO_DESC_SELF_254


if __name__ == "__main__":
    raise SystemExit(_desc_main())
