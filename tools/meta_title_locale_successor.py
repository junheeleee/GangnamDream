#!/usr/bin/env python3
"""One approved title-locale successor; never a general source normalization.

Current raw must validate before a small span/hook inverse can expose the exact
244 predecessor. The old helper, old18 and old JA constants remain independent.
"""
from __future__ import annotations

import hashlib
import json

MP_PATH = "autoloads/MetaProgression.gd"
JA_PATH = "tools/ja_translation_pipeline.py"
SOURCE_ROWS = tuple(tuple(row) for row in json.loads(r'''[["steady_youth","name","놓인 계단","The Stairs Already There"],["steady_youth","desc","낯선 지름길보다 이미 놓인 계단을 골라, 한 걸음씩 올라왔다.","You kept choosing the stairs already there over unfamiliar shortcuts, one step at a time."],["elite_course","name","오래 오른 계단","The Long Climb"],["elite_course","desc","같은 계단을 오래 올랐다. 익숙해진 풍경만큼 지나친 갈림길도 남았다.","You stayed on the same staircase for a long time. The view grew familiar, and some turnoffs slipped behind you."],["outsider_title","name","다른 출구","Another Exit"],["outsider_title","desc","사람들이 몰린 방향에서 벗어나, 다른 출구를 여러 번 골랐다.","More than once, you stepped away from the crowd and chose another exit."],["dangerous_dreamer","name","지도 밖의 길","Beyond the Map"],["dangerous_dreamer","desc","지도에 없는 길을 오래 걸었다. 발밑이 흔들린 날에도 방향을 쉽게 바꾸지 않았다.","You stayed on roads the map did not show, even on days when the ground felt uncertain."],["my_own_way","name","두 길 사이","Between Two Roads"],["my_own_way","desc","이미 놓인 길과 지도 밖의 길을 오갔다. 어느 한쪽만으로는 이 5년을 설명할 수 없다.","You moved between the road already laid out and the road beyond the map. Neither one alone explains these five years."],["free_spirit","name","비어 있던 오후","An Afternoon of Your Own"],["free_spirit","desc","한강과 편의점, 오래 걷던 길에서 누구의 일정도 아닌 시간을 보냈다.","By the Han River, at convenience stores, and on long walks, you spent time that belonged to no one else's schedule."],["seoul_love","name","서울에서 사랑","Love in Seoul"],["seoul_love","desc","이 복잡한 도시에서도 사람을 좋아하게 됐다.","Even in this complicated city, you came to care for someone."],["social_king_title","name","낯익은 자리들","Familiar Seats"],["social_king_title","desc","서울 곳곳에 먼저 인사를 건네고 자리를 내어 주는 사람들이 생겼다.","Around Seoul, people began greeting you first and making room when you arrived."],["loner_title","name","혼자 걷는 저녁","Evenings Walked Alone"],["loner_title","desc","연락할 이름이 떠오르지 않는 저녁에도, 혼자 걷는 길은 어느새 익숙해졌다.","Even on evenings when no one came to mind to call, walking alone had become familiar."],["stress_survivor","name","다음 아침","The Next Morning"],["stress_survivor","desc","마음이 버티기 어려웠던 밤이 지나고도, 다음 아침은 왔다.","A night when it was hard to hold yourself together passed, and the next morning still came."]]'''))
SUCCESSOR_TRANSITIONS = json.loads(r'''{"autoloads/MetaProgression.gd":{"previous_sha256":"5bc1465e18ae3e36ef5daef1c27dd3923d1566884e5d0545e6b00c2c7893ab58","current_sha256":"a3435ebd18cee005720a98633fa290754b23cf944b241cef25848b3cf114b7bd","start":"\t\t\"steady_youth\":\n","end":"\treturn localized\n","include_end":false,"span_sha256":"db1f4a8b1326ea99b613ddc08acba3d7fafafff2e2b1b1d3c7eb630a17274d17","hooks":[]},"tools/ja_translation_pipeline.py":{"previous_sha256":"f761bceb5c4ad7f34816aba75cc46866b037bdbfa2ca4141becb5c17e11d1987","current_sha256":"173228d3c6641b95b8fe5f09f7696a15af2ff44f7871d01f9a0f13947458f376","start":"# BEGIN_META_TITLE_SUCCESSOR_245\n","end":"# END_META_TITLE_SUCCESSOR_245\n\n\n","include_end":true,"span_sha256":"835a74a8b33bf4fd111badc6d1457aa4f07bc33786014f69a8157aeec8c7b959","hooks":[["def _meta_title_current_stats(\n    calls: Iterable[UiCall], previous: dict[str, Any], source: Optional[str] = None,","def _meta_title_current_stats(\n    calls: Iterable[UiCall], previous: dict[str, Any],"],["    historical, errors = _meta_title_ui_historical_calls(calls, source)\n    stats = dict(previous)","    historical, errors = _meta_title_ui_historical_calls(calls)\n    stats = dict(previous)"],["    predecessor_calls, predecessor_source, next_title_errors = _next_meta_title_predecessor_calls(calls)\n    errors.extend(next_title_errors)\n    historical_calls, title_errors = _meta_title_ui_historical_calls(predecessor_calls, predecessor_source)\n    errors.extend(title_errors)","    historical_calls, title_errors = _meta_title_ui_historical_calls(calls)\n    errors.extend(title_errors)"],["    stats, title_stat_errors = _next_meta_title_current_stats(\n        calls, predecessor_calls, predecessor_source, stats)","    stats, title_stat_errors = _meta_title_current_stats(calls, stats)"],["        # Current raw is validated before the explicitly historical old20+4.\n        ui_inventory, meta_title_cases, meta_title_failures = _next_meta_title_historical_checks(ui_inventory)\n        cases += meta_title_cases\n        failures.extend(meta_title_failures)","        meta_title_cases, meta_title_failures = _meta_title_inventory_self_test(ui_inventory)\n        cases += meta_title_cases\n        failures.extend(meta_title_failures)\n        retained_cases, retained_failures = _meta_title_retained_owner_self_test(ui_inventory)\n        cases += retained_cases\n        failures.extend(retained_failures)\n        # Old fixtures retain their exact pre-title population and expectations.\n        ui_inventory = _meta_title_historical_inventory(ui_inventory)"]]}}''')
_REGISTRY_SHA256 = "89e7de286907d9780d28e38e7c5345797e73af3d31f645dc4f0b58d0dbc7c6ac"


def _registry_digest() -> str:
    return hashlib.sha256(json.dumps(
        {"rows": SOURCE_ROWS, "transitions": SUCCESSOR_TRANSITIONS},
        ensure_ascii=False, sort_keys=True, separators=(",", ":")
    ).encode("utf-8")).hexdigest()


def _approved_mp_span() -> bytes:
    lines = []
    previous_id = None
    for title_id, field, ko, en in SOURCE_ROWS:
        if title_id != previous_id:
            lines.append("\t\t" + json.dumps(title_id, ensure_ascii=False) + ":\n")
            previous_id = title_id
        lines.append("\t\t\tlocalized[" + json.dumps(field) + "] = LocaleManager.ui("
                     + json.dumps(ko, ensure_ascii=False) + ", "
                     + json.dumps(en, ensure_ascii=False) + ")\n")
    return "".join(lines).encode("utf-8")


def _projection(current: bytes, relative: str) -> tuple[bytes, list[str]]:
    if relative not in (MP_PATH, JA_PATH):
        return current, ["ORDER-245: successor path is not owned"]
    try:
        if (MP_PATH, JA_PATH) != (
                "autoloads/MetaProgression.gd", "tools/ja_translation_pipeline.py"
        ) or _registry_digest() != _REGISTRY_SHA256:
            return current, ["ORDER-245: exact successor registry drifted"]
        rule = SUCCESSOR_TRANSITIONS[relative]
        if hashlib.sha256(current).hexdigest() != rule["current_sha256"]:
            return current, ["ORDER-245: unapproved current source bytes " + relative]
        start, end = rule["start"].encode("utf-8"), rule["end"].encode("utf-8")
        if current.count(start) != 1 or current.count(end) != 1:
            return current, ["ORDER-245: successor span boundary is not unique"]
        begin = current.index(start)
        finish = current.index(end, begin)
        if rule["include_end"]:
            finish += len(end)
        span = current[begin:finish]
        if hashlib.sha256(span).hexdigest() != rule["span_sha256"]:
            return current, ["ORDER-245: successor span raw mismatch"]
        if relative == MP_PATH and span != _approved_mp_span():
            return current, ["ORDER-245: successor title ID/field/KO/EN mismatch"]
        projected = current[:begin] + current[finish:]
        for current_hook, previous_hook in rule["hooks"]:
            current_hook = current_hook.encode("utf-8")
            if projected.count(current_hook) != 1:
                return current, ["ORDER-245: successor hook is not unique"]
            projected = projected.replace(current_hook, previous_hook.encode("utf-8"), 1)
        if hashlib.sha256(projected).hexdigest() != rule["previous_sha256"]:
            return current, ["ORDER-245: successor inverse does not restore predecessor"]
        return projected, []
    except (KeyError, TypeError, ValueError, AttributeError, UnicodeError):
        return current, ["ORDER-245: malformed successor registry/source"]


def successor_source_errors(
    relative: str, current: bytes, registered_previous: str | None = None,
) -> list[str]:
    """Live raw authority. An optional caller registration must match this step."""
    _old, errors = _projection(current, relative)
    if registered_previous is not None:
        rule = SUCCESSOR_TRANSITIONS.get(relative, {})
        if registered_previous != rule.get("previous_sha256"):
            errors.append("ORDER-245: successor predecessor registration drifted")
    return errors


def successor_project_bytes(current: bytes, relative: str) -> bytes:
    """Rejected and off-scope inputs are returned byte-for-byte unchanged."""
    return _projection(current, relative)[0]


def successor_project_byte_hash(claim: str, relative: str, current: bytes) -> str:
    """A claim cannot substitute for actual raw validation."""
    old, errors = _projection(current, relative)
    if errors or hashlib.sha256(current).hexdigest() != claim:
        return claim
    return hashlib.sha256(old).hexdigest()
