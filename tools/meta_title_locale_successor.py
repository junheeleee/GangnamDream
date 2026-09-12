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


# BEGIN_A11_META_TITLE_SUCCESSOR_248
A11_SOURCE_ROWS = tuple(tuple(row) for row in json.loads('[["first_investment","name","첫 투자","First Investment"],["first_investment","desc","처음으로 주식을 샀다. 그날부터 매일 앱을 열게 됐다.","Bought your first stock. From that day on, you opened the app every day."],["margin_called","name","마진콜의 교훈","Lesson of the Margin Call"],["margin_called","desc","레버리지 포지션이 강제청산됐다. 비싼 수업료였다.","A leveraged position was liquidated. An expensive lesson."],["invest_master_title","name","닫힌 노트북","The Closed Laptop"],["invest_master_title","desc","새벽 시장을 지켜보다 스스로 정한 때에 화면을 닫을 수 있게 됐다.","After watching the market before dawn, you learned to close the screen at the moment you had set for yourself."],["survived_broke","name","통장 0원 생존자","Zero-Balance Survivor"],["survived_broke","desc","잔고가 마이너스까지 내려갔다 돌아왔다.","Your balance went below zero and came back."],["first_10m_title","name","첫 1000만원","First KRW 10M"],["first_10m_title","desc","현금 1000만원. 서울에서 처음으로 숨이 트이는 느낌이었다.","KRW 10 million cash. For the first time in Seoul, you could breathe."],["first_100m_title","name","첫 1억","First KRW 100M"],["first_100m_title","desc","총자산 1억. 뭔가 달라지는 것 같기도 하고 아닌 것 같기도 하다.","KRW 100 million net worth. Something changed. Or maybe nothing did."],["five_runs_title","name","다섯 번의 인생","Five Lives"],["five_runs_title","desc","다섯 번의 삶을 끝까지 살아냈다. 매번 달랐다.","Lived five lives all the way through. Each one was different."],["ten_runs_title","name","열 번의 인생","Ten Lives"],["ten_runs_title","desc","열 번을 살았다. 이제 이 도시의 반복되는 얼굴이 보이기 시작한다.","Lived ten lives. The city\'s recurring patterns are starting to show."],["gangnam_dream_title","name","강남드림 달성자","Gangnam Dream Achiever"],["gangnam_dream_title","desc","총자산 30억. 강남드림을 이뤘다. 다음엔 뭘 꿈꿔야 할까.","KRW 3 billion net worth. You achieved the Gangnam Dream. What do you dream of next?"],["burnout_survivor","name","번아웃 생존자","Burnout Survivor"],["burnout_survivor","desc","번아웃 엔딩을 경험했다. 열심히 사는 것의 대가를 배웠다.","Experienced the burnout ending. You learned the price of trying too hard."],["ordinary_end_title","name","평범한 행복","Ordinary Happiness"],["ordinary_end_title","desc","ordinary_life 엔딩. 평범함도 하나의 성취다.","Ordinary Life ending. Even normalcy can be an achievement."]]'))
A11_TRANSITIONS = json.loads('{"autoloads/MetaProgression.gd":{"previous_sha256":"a3435ebd18cee005720a98633fa290754b23cf944b241cef25848b3cf114b7bd","current_sha256":"afe8bda86177950ef82fb8d2eea339ae398d59534897719c9b803bacf292a1b6","start":"\\t\\t\\"first_investment\\":\\n","end":"\\treturn localized\\n","include_end":false,"span_sha256":"d0db7f3704a135af6ed405bfba5aefb87bac41516e495af7483a8f7c4c940035","hooks":[]},"tools/ja_translation_pipeline.py":{"previous_sha256":"173228d3c6641b95b8fe5f09f7696a15af2ff44f7871d01f9a0f13947458f376","current_sha256":"504b5ef8707568b199df35179b1753ab25706b2004fa3d0fc0fa879b18303906","start":"# BEGIN_META_TITLE_SUCCESSOR_248\\n","end":"# END_META_TITLE_SUCCESSOR_248\\n\\n\\n","include_end":true,"span_sha256":"c3cf305eff0db369341a9e28ea2d45465295da26003b56eb5d8e3ff7b2280726","hooks":[["    predecessor_calls, predecessor_source, next_title_errors = _a11_meta_title_chain_calls(calls)","    predecessor_calls, predecessor_source, next_title_errors = _next_meta_title_predecessor_calls(calls)"],["    stats, title_stat_errors = _a11_meta_title_current_stats(\\n        calls, predecessor_calls, predecessor_source, stats)","    stats, title_stat_errors = _next_meta_title_current_stats(\\n        calls, predecessor_calls, predecessor_source, stats)"],["        ui_inventory, meta_title_cases, meta_title_failures = _a11_meta_title_historical_checks(ui_inventory)","        ui_inventory, meta_title_cases, meta_title_failures = _next_meta_title_historical_checks(ui_inventory)"]]}}')
_A11_REGISTRY_SHA256 = 'c2607093a0cc3fe0ab4c44d926d891f519347bc0b6e0134d1a4298a8d8e71ef2'


def _a11_registry_digest() -> str:
    return hashlib.sha256(json.dumps(
        {"rows": A11_SOURCE_ROWS, "transitions": A11_TRANSITIONS},
        ensure_ascii=False, sort_keys=True, separators=(",", ":")
    ).encode("utf-8")).hexdigest()


def _approved_a11_mp_span() -> bytes:
    lines = []
    previous_id = None
    for title_id, field, ko, en in A11_SOURCE_ROWS:
        if title_id != previous_id:
            lines.append("\t\t" + json.dumps(title_id, ensure_ascii=False) + ":\n")
            previous_id = title_id
        lines.append("\t\t\tlocalized[" + json.dumps(field) + "] = LocaleManager.ui("
                     + json.dumps(ko, ensure_ascii=False) + ", "
                     + json.dumps(en, ensure_ascii=False) + ")\n")
    return "".join(lines).encode("utf-8")


def _a11_projection(current: bytes, relative: str) -> tuple[bytes, list[str]]:
    if relative not in (MP_PATH, JA_PATH):
        return current, ["ORDER-248: A11 successor path is not owned"]
    try:
        if (MP_PATH, JA_PATH) != (
                "autoloads/MetaProgression.gd", "tools/ja_translation_pipeline.py"
        ) or _a11_registry_digest() != _A11_REGISTRY_SHA256 \
                or _registry_digest() != _REGISTRY_SHA256:
            return current, ["ORDER-248: exact A11/predecessor registry drifted"]
        rule = A11_TRANSITIONS[relative]
        if rule["previous_sha256"] != SUCCESSOR_TRANSITIONS[relative]["current_sha256"]:
            return current, ["ORDER-248: A11 predecessor step is not old245"]
        if hashlib.sha256(current).hexdigest() != rule["current_sha256"]:
            return current, ["ORDER-248: unapproved current A11 source bytes " + relative]
        start, end = rule["start"].encode("utf-8"), rule["end"].encode("utf-8")
        if current.count(start) != 1 or current.count(end) != 1:
            return current, ["ORDER-248: A11 span boundary is not unique"]
        begin = current.index(start)
        finish = current.index(end, begin)
        if rule["include_end"]:
            finish += len(end)
        span = current[begin:finish]
        if hashlib.sha256(span).hexdigest() != rule["span_sha256"]:
            return current, ["ORDER-248: A11 span raw mismatch"]
        if relative == MP_PATH and span != _approved_a11_mp_span():
            return current, ["ORDER-248: A11 title ID/field/KO/EN mismatch"]
        projected = current[:begin] + current[finish:]
        for current_hook, previous_hook in rule["hooks"]:
            current_hook = current_hook.encode("utf-8")
            if projected.count(current_hook) != 1:
                return current, ["ORDER-248: A11 hook is not unique"]
            projected = projected.replace(current_hook, previous_hook.encode("utf-8"), 1)
        if hashlib.sha256(projected).hexdigest() != rule["previous_sha256"]:
            return current, ["ORDER-248: A11 inverse does not restore old245"]
        return projected, []
    except (KeyError, TypeError, ValueError, AttributeError, UnicodeError):
        return current, ["ORDER-248: malformed A11 registry/source"]


def a11_source_errors(
    relative: str, current: bytes, registered_previous: str | None = None,
) -> list[str]:
    """Current raw authority for exactly the new11 step, before old245."""
    _old, errors = _a11_projection(current, relative)
    if registered_previous is not None:
        rule = A11_TRANSITIONS.get(relative, {})
        if registered_previous != rule.get("previous_sha256"):
            errors.append("ORDER-248: A11 predecessor registration drifted")
    return errors


def a11_project_bytes(current: bytes, relative: str) -> bytes:
    """Reject/unknown inputs remain identical; success returns old245 bytes."""
    return _a11_projection(current, relative)[0]


def a11_project_byte_hash(claim: str, relative: str, current: bytes) -> str:
    """A digest claim cannot replace actual current raw validation."""
    old, errors = _a11_projection(current, relative)
    if errors or hashlib.sha256(current).hexdigest() != claim:
        return claim
    return hashlib.sha256(old).hexdigest()
# END_A11_META_TITLE_SUCCESSOR_248


# BEGIN_MG9_META_TITLE_SUCCESSOR_250
MG9_SOURCE_ROWS = tuple(tuple(row) for row in json.loads(r'''[
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
]'''))
MG9_TRANSITIONS = json.loads(r'''{
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
}''')
_MG9_REGISTRY_SHA256 = '78ad53320530e54e2347313e505cf28c4f8991f011e6a91d8e0078831b577515'


def _mg9_registry_digest() -> str:
    return hashlib.sha256(json.dumps(
        {"rows": MG9_SOURCE_ROWS, "transitions": MG9_TRANSITIONS},
        ensure_ascii=False, sort_keys=True, separators=(",", ":")
    ).encode("utf-8")).hexdigest()


def _approved_mg9_mp_span() -> bytes:
    lines = []
    previous_id = None
    for title_id, field, ko, en in MG9_SOURCE_ROWS:
        if title_id != previous_id:
            lines.append("\t\t" + json.dumps(title_id, ensure_ascii=False) + ":\n")
            previous_id = title_id
        lines.append("\t\t\tlocalized[" + json.dumps(field) + "] = LocaleManager.ui("
                     + json.dumps(ko, ensure_ascii=False) + ", "
                     + json.dumps(en, ensure_ascii=False) + ")\n")
    return "".join(lines).encode("utf-8")


def _mg9_projection(current: bytes, relative: str) -> tuple[bytes, list[str]]:
    if relative not in (MP_PATH, JA_PATH):
        return current, ["ORDER-250: MG9 successor path is not owned"]
    try:
        if (MP_PATH, JA_PATH) != (
                "autoloads/MetaProgression.gd", "tools/ja_translation_pipeline.py"
        ) or _mg9_registry_digest() != _MG9_REGISTRY_SHA256 \
                or _a11_registry_digest() != _A11_REGISTRY_SHA256 \
                or _registry_digest() != _REGISTRY_SHA256:
            return current, ["ORDER-250: exact MG9/predecessor registry drifted"]
        rule = MG9_TRANSITIONS[relative]
        if rule["previous_sha256"] != A11_TRANSITIONS[relative]["current_sha256"]:
            return current, ["ORDER-250: MG9 predecessor step is not old248"]
        if hashlib.sha256(current).hexdigest() != rule["current_sha256"]:
            return current, ["ORDER-250: unapproved current MG9 source bytes " + relative]
        start, end = rule["start"].encode("utf-8"), rule["end"].encode("utf-8")
        if current.count(start) != 1 or current.count(end) != 1:
            return current, ["ORDER-250: MG9 span boundary is not unique"]
        begin = current.index(start)
        finish = current.index(end, begin)
        if rule["include_end"]:
            finish += len(end)
        span = current[begin:finish]
        if hashlib.sha256(span).hexdigest() != rule["span_sha256"]:
            return current, ["ORDER-250: MG9 span raw mismatch"]
        if relative == MP_PATH and span != _approved_mg9_mp_span():
            return current, ["ORDER-250: MG9 title ID/field/KO/EN mismatch"]
        projected = current[:begin] + current[finish:]
        for current_hook, previous_hook in rule["hooks"]:
            current_hook = current_hook.encode("utf-8")
            if projected.count(current_hook) != 1:
                return current, ["ORDER-250: MG9 hook is not unique"]
            projected = projected.replace(current_hook, previous_hook.encode("utf-8"), 1)
        if hashlib.sha256(projected).hexdigest() != rule["previous_sha256"]:
            return current, ["ORDER-250: MG9 inverse does not restore old248"]
        return projected, []
    except (KeyError, TypeError, ValueError, AttributeError, UnicodeError):
        return current, ["ORDER-250: malformed MG9 registry/source"]


def mg9_source_errors(
    relative: str, current: bytes, registered_previous: str | None = None,
) -> list[str]:
    """Newest raw authority before the unchanged248 predecessor."""
    _old, errors = _mg9_projection(current, relative)
    if registered_previous is not None:
        rule = MG9_TRANSITIONS.get(relative, {})
        if registered_previous != rule.get("previous_sha256"):
            errors.append("ORDER-250: MG9 predecessor registration drifted")
    return errors


def mg9_project_bytes(current: bytes, relative: str) -> bytes:
    """Reject and OFF inputs remain identical; success exposes only old248."""
    return _mg9_projection(current, relative)[0]


def mg9_project_byte_hash(claim: str, relative: str, current: bytes) -> str:
    """A claim never substitutes for the actual current raw authority."""
    old, errors = _mg9_projection(current, relative)
    if errors or hashlib.sha256(current).hexdigest() != claim:
        return claim
    return hashlib.sha256(old).hexdigest()
# END_MG9_META_TITLE_SUCCESSOR_250


# BEGIN_TWO_DESC_HISTORY_254
# Paired description-only successor. Old source/registry/functions above stay raw.
DESC_TRANSITION = json.loads(r'''{
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
}''')
_DESC_REGISTRY_SHA256 = "6d7962acd9d554d27ef383e6b3d62f3b7e7512597740c412bbe356bba60eece9"


def _desc_projection(current: bytes, relative: str) -> tuple[bytes, list[str]]:
    """Recognize only approved MP bytes, then restore the four owner spans."""
    if relative != "autoloads/MetaProgression.gd":
        return current, ["ORDER-254: description successor path is not owned"]
    try:
        digest = hashlib.sha256(json.dumps(
            DESC_TRANSITION, ensure_ascii=False, sort_keys=True,
            separators=(",", ":")).encode("utf-8")).hexdigest()
        rule = DESC_TRANSITION
        if (MP_PATH != relative or rule["path"] != relative
                or digest != _DESC_REGISTRY_SHA256
                or rule["previous_sha256"] != MG9_TRANSITIONS[relative]["current_sha256"]):
            return current, ["ORDER-254: exact description registry/predecessor drifted"]
        if hashlib.sha256(current).hexdigest() != rule["current_sha256"]:
            return current, ["ORDER-254: unapproved current description source bytes"]
        owners = [(p["catalog"], p["owner"], p["field"]) for p in rule["patches"]]
        if owners != [
            ("ALL_TITLES", "clean_run_title", "desc"),
            ("TITLE_EN", "clean_run_title", "desc"),
            ("ALL_TITLES", "father_peace_title", "desc"),
            ("TITLE_EN", "father_peace_title", "desc"),
        ]:
            return current, ["ORDER-254: exact four description owners drifted"]
        old = current
        for item in rule["patches"]:
            before, after = item["before"].encode("utf-8"), item["after"].encode("utf-8")
            if before == after or old.count(after) != 1 or old.count(before) != 0:
                return current, ["ORDER-254: description owner span is not exact1"]
            old = old.replace(after, before, 1)
        if hashlib.sha256(old).hexdigest() != rule["previous_sha256"]:
            return current, ["ORDER-254: four-description inverse is not whole MG9"]
        return old, []
    except (KeyError, TypeError, ValueError, AttributeError, UnicodeError):
        return current, ["ORDER-254: malformed description registry/source"]


def desc_source_errors(
    relative: str, current: bytes, registered_previous: str | None = None,
) -> list[str]:
    """New step's registration is edbc, not the public MG9 predecessor afe8."""
    _old, errors = _desc_projection(current, relative)
    if registered_previous is not None:
        if (not isinstance(DESC_TRANSITION, dict)
                or registered_previous != DESC_TRANSITION.get("previous_sha256")):
            errors.append("ORDER-254: description predecessor registration drifted")
    return errors


def desc_project_bytes(current: bytes, relative: str) -> bytes:
    """Only the new step: approved current -> edbc; all failures/OFF identity."""
    return _desc_projection(current, relative)[0]


def desc_project_byte_hash(claim: str, relative: str, current: bytes) -> str:
    old, errors = _desc_projection(current, relative)
    if errors or hashlib.sha256(current).hexdigest() != claim:
        return claim
    return hashlib.sha256(old).hexdigest()


# Save original callables, not rewritten historical functions or their registries.
_DESC_OLD_MG9_SOURCE_ERRORS = mg9_source_errors
_DESC_OLD_MG9_PROJECT_BYTES = mg9_project_bytes
_DESC_OLD_MG9_PROJECT_HASH = mg9_project_byte_hash


def _desc_mg9_source_errors(
    relative: str, current: bytes, registered_previous: str | None = None,
) -> list[str]:
    if relative != "autoloads/MetaProgression.gd":
        return _DESC_OLD_MG9_SOURCE_ERRORS(relative, current, registered_previous)
    old, errors = _desc_projection(current, relative)
    if errors:
        return errors
    # Existing callers still register afe8; do not reinterpret that argument.
    return _DESC_OLD_MG9_SOURCE_ERRORS(relative, old, registered_previous)


def _desc_mg9_project_bytes(current: bytes, relative: str) -> bytes:
    if relative != "autoloads/MetaProgression.gd":
        return _DESC_OLD_MG9_PROJECT_BYTES(current, relative)
    old, errors = _desc_projection(current, relative)
    if errors or _DESC_OLD_MG9_SOURCE_ERRORS(relative, old):
        return current
    return _DESC_OLD_MG9_PROJECT_BYTES(old, relative)


def _desc_mg9_project_hash(claim: str, relative: str, current: bytes) -> str:
    if relative != "autoloads/MetaProgression.gd":
        return _DESC_OLD_MG9_PROJECT_HASH(claim, relative, current)
    old, errors = _desc_projection(current, relative)
    if (errors or hashlib.sha256(current).hexdigest() != claim
            or _DESC_OLD_MG9_SOURCE_ERRORS(relative, old)):
        return claim
    return _DESC_OLD_MG9_PROJECT_HASH(hashlib.sha256(old).hexdigest(), relative, old)


# Existing JA/Chapter module-attribute callers enter the new raw gate first.
mg9_source_errors = _desc_mg9_source_errors
mg9_project_bytes = _desc_mg9_project_bytes
mg9_project_byte_hash = _desc_mg9_project_hash
# END_TWO_DESC_HISTORY_254


# BEGIN_LAST11_META_TITLE_SUCCESSOR_255
# Fixed source22; current254 is the immediate predecessor, not pre-DESC MG9.
LAST11_SOURCE_ROWS = tuple(tuple(row) for row in json.loads(r'''[
  [
    "spec_elite_title",
    "name",
    "엘리트의 길",
    "Path of the Elite"
  ],
  [
    "spec_elite_title",
    "desc",
    "엘리트 전문화 선택. 정석의 끝에는 무엇이 있을까.",
    "Chose the elite specialization. What waits at the end of the proper path?"
  ],
  [
    "spec_quant_title",
    "name",
    "퀀트 마인드",
    "Quant Mind"
  ],
  [
    "spec_quant_title",
    "desc",
    "퀀트형 전문화 선택. 시장을 수식으로 본다.",
    "Chose the quant specialization. You see the market as equations."
  ],
  [
    "spec_founder_title",
    "name",
    "창업가 정신",
    "Founder Spirit"
  ],
  [
    "spec_founder_title",
    "desc",
    "창업형 전문화 선택. 아무것도 없는 곳에서 시작한 사람.",
    "Chose the founder specialization. Someone who began from nothing."
  ],
  [
    "clean_run_title",
    "name",
    "청렴한 강남행",
    "Clean Road to Gangnam"
  ],
  [
    "clean_run_title",
    "desc",
    "도박판에서 손을 떼겠다고 시작한 인생. 마지막에 남은 자산은 30억 이상이었다.",
    "You began that life intending to leave gambling behind. It ended with at least 3 billion won in assets."
  ],
  [
    "network_run_title",
    "name",
    "서울 인맥왕",
    "Seoul Network King"
  ],
  [
    "network_run_title",
    "desc",
    "맺어 온 인연을 따라 강남에 들어섰다. 결국 사람이 가장 큰 자산이었다.",
    "The people you came to know opened the way into Gangnam. In the end, people were the greatest asset."
  ],
  [
    "temptation_resist_title",
    "name",
    "그날 밤의 선택",
    "Choice That Night"
  ],
  [
    "temptation_resist_title",
    "desc",
    "가장 어려울 때 쉬운 돈을 거절했다. 그 선택이 모든 것의 시작이었다.",
    "Refused easy money when things were hardest. That choice began everything."
  ],
  [
    "high_road_title",
    "name",
    "선을 지킨 사람",
    "One Who Held the Line"
  ],
  [
    "high_road_title",
    "desc",
    "친구를 경찰에 넘겼다. 옳은 일은 가끔 가장 아픈 일이다.",
    "Turned your friend over to the police. The right thing is sometimes the most painful thing."
  ],
  [
    "father_peace_title",
    "name",
    "마지막 봄",
    "Last Spring"
  ],
  [
    "father_peace_title",
    "desc",
    "아버지와 화해했다. 둘 사이의 침묵이 조금 달라졌다.",
    "Made peace with your father. The silence between you felt a little different."
  ],
  [
    "love_chosen_title",
    "name",
    "사랑을 택한 사람",
    "One Who Chose Love"
  ],
  [
    "love_chosen_title",
    "desc",
    "갈림길에서 다은을 붙잡았다. 강남보다 먼저 잡은 것.",
    "Held onto Daeun at the crossroads. Something you caught before Gangnam."
  ],
  [
    "investigator_title",
    "name",
    "의심하는 자",
    "The Suspicious One"
  ],
  [
    "investigator_title",
    "desc",
    "친구의 경고를 흘려듣지 않았다. 의심은 때로 우정의 다른 이름이다.",
    "Did not dismiss your friend's warning. Suspicion is sometimes another name for friendship."
  ],
  [
    "white_gangnam_title",
    "name",
    "수첩의 다음 장",
    "The Notebook's Next Page"
  ],
  [
    "white_gangnam_title",
    "desc",
    "30억과 강남의 등기를 손에 쥔 뒤, 하지 않았던 일들을 돌아보며 오래된 수첩의 다음 장을 폈다.",
    "With 3 billion won and a Gangnam deed in hand, you looked back on what you had refused to do and opened the old notebook to its next page."
  ]
]'''))
LAST11_TRANSITIONS = json.loads(r'''{
  "autoloads/MetaProgression.gd": {
    "previous_sha256": "b5c73771546c1fdc0d136aed45cdd14ee8e829fcc6aff88dfb607288cecf4f7d",
    "current_sha256": "6f49a1bdd83b3431b4146bbd2a94956c481bb371202606398167cdec8ae9f8b0",
    "start": "\t\t\"spec_elite_title\":\n",
    "end": "\treturn localized\n",
    "include_end": false,
    "span_sha256": "c3bdb2a9960108983f3ebce98d355ae302c81e28a6c67dc9b091bba4f256787c",
    "hooks": []
  },
  "tools/ja_translation_pipeline.py": {
    "previous_sha256": "e2d666c19637fd20df8750187870e27cc1770c63d73db232e8035b8d072abe9c",
    "current_sha256": "3a2d791038a46dcf3442776f4703cd1398998590843b91904c2668425a7427f4",
    "start": "# BEGIN_LAST11_META_TITLE_SUCCESSOR_255\n",
    "end": "# END_LAST11_META_TITLE_SUCCESSOR_255\n\n\n",
    "include_end": true,
    "span_sha256": "a9e90571e14e8cbc8a8d293119ce037f2d297a3d5cd510612250a72bbf228718",
    "hooks": [
      [
        "    predecessor_calls, predecessor_source, next_title_errors = _last11_meta_title_chain_calls(calls)",
        "    predecessor_calls, predecessor_source, next_title_errors = _mg9_meta_title_chain_calls(calls)"
      ],
      [
        "    stats, title_stat_errors = _last11_meta_title_current_stats(\n        calls, predecessor_calls, predecessor_source, stats)",
        "    stats, title_stat_errors = _mg9_meta_title_current_stats(\n        calls, predecessor_calls, predecessor_source, stats)"
      ],
      [
        "        ui_inventory, meta_title_cases, meta_title_failures = _last11_meta_title_historical_checks(ui_inventory)",
        "        ui_inventory, meta_title_cases, meta_title_failures = _mg9_meta_title_historical_checks(ui_inventory)"
      ]
    ]
  }
}''')
_LAST11_REGISTRY_SHA256 = '57e9268bf877ae98dcc66af56d8bcec8151bcc7ce4f8dbe283515455a839bc16'


def _last11_registry_digest() -> str:
    return hashlib.sha256(json.dumps(
        {"rows": LAST11_SOURCE_ROWS, "transitions": LAST11_TRANSITIONS},
        ensure_ascii=False, sort_keys=True, separators=(",", ":")
    ).encode("utf-8")).hexdigest()


def _approved_last11_mp_span() -> bytes:
    lines, previous_id = [], None
    for title_id, field, ko, en in LAST11_SOURCE_ROWS:
        if title_id != previous_id:
            lines.append("\t\t" + json.dumps(title_id, ensure_ascii=False) + ":\n")
            previous_id = title_id
        lines.append("\t\t\tlocalized[" + json.dumps(field) + "] = LocaleManager.ui("
                     + json.dumps(ko, ensure_ascii=False) + ", "
                     + json.dumps(en, ensure_ascii=False) + ")\n")
    return "".join(lines).encode("utf-8")


def _last11_projection(current: bytes, relative: str) -> tuple[bytes, list[str]]:
    if relative not in (MP_PATH, JA_PATH):
        return current, ["ORDER-255: last11 successor path is not owned"]
    try:
        if (MP_PATH, JA_PATH) != (
                "autoloads/MetaProgression.gd", "tools/ja_translation_pipeline.py"
        ) or set(LAST11_TRANSITIONS) != {MP_PATH, JA_PATH} \
                or _last11_registry_digest() != _LAST11_REGISTRY_SHA256:
            return current, ["ORDER-255: exact last11 registry drifted"]
        rule = LAST11_TRANSITIONS[relative]
        prior = (DESC_TRANSITION["current_sha256"] if relative == MP_PATH
                 else MG9_TRANSITIONS[JA_PATH]["current_sha256"])
        if rule["previous_sha256"] != prior:
            return current, ["ORDER-255: last11 predecessor is not current254"]
        if hashlib.sha256(current).hexdigest() != rule["current_sha256"]:
            return current, ["ORDER-255: unapproved current last11 source bytes " + relative]
        start, end = rule["start"].encode("utf-8"), rule["end"].encode("utf-8")
        if not start or not end or current.count(start) != 1 or current.count(end) != 1:
            return current, ["ORDER-255: last11 span boundary is not unique"]
        begin = current.index(start)
        finish = current.index(end, begin) + (len(end) if rule["include_end"] else 0)
        span = current[begin:finish]
        if hashlib.sha256(span).hexdigest() != rule["span_sha256"]:
            return current, ["ORDER-255: last11 span raw mismatch"]
        if relative == MP_PATH and span != _approved_last11_mp_span():
            return current, ["ORDER-255: last11 title ID/field/KO/EN mismatch"]
        hooks = rule["hooks"]
        if (len(hooks) != (0 if relative == MP_PATH else 3)
                or len({tuple(hook) for hook in hooks}) != len(hooks)):
            return current, ["ORDER-255: last11 exact inverse hook count/uniqueness drifted"]
        projected = current[:begin] + current[finish:]
        for current_hook, previous_hook in hooks:
            current_hook, previous_hook = current_hook.encode("utf-8"), previous_hook.encode("utf-8")
            if not current_hook or current_hook == previous_hook or projected.count(current_hook) != 1:
                return current, ["ORDER-255: last11 hook is not exact1"]
            projected = projected.replace(current_hook, previous_hook, 1)
        if hashlib.sha256(projected).hexdigest() != prior:
            return current, ["ORDER-255: last11 inverse does not restore whole current254"]
        return projected, []
    except (KeyError, TypeError, ValueError, AttributeError, UnicodeError):
        return current, ["ORDER-255: malformed last11 registry/source"]


def last11_source_errors(
    relative: str, current: bytes, registered_previous: str | None = None,
) -> list[str]:
    _old, errors = _last11_projection(current, relative)
    if registered_previous is not None:
        rule = LAST11_TRANSITIONS.get(relative) if isinstance(LAST11_TRANSITIONS, dict) else None
        if not isinstance(rule, dict) or registered_previous != rule.get("previous_sha256"):
            errors.append("ORDER-255: last11 predecessor registration drifted")
    return errors


def last11_project_bytes(current: bytes, relative: str) -> bytes:
    return _last11_projection(current, relative)[0]


def last11_project_byte_hash(claim: str, relative: str, current: bytes) -> str:
    old, errors = _last11_projection(current, relative)
    if errors or hashlib.sha256(current).hexdigest() != claim:
        return claim
    return hashlib.sha256(old).hexdigest()


# Capture the current DESC-bound public layer, not the older pre-DESC alias.
_LAST11_OLD_MG9_SOURCE_ERRORS = mg9_source_errors
_LAST11_OLD_MG9_PROJECT_BYTES = mg9_project_bytes
_LAST11_OLD_MG9_PROJECT_HASH = mg9_project_byte_hash


def _last11_mg9_source_errors(
    relative: str, current: bytes, registered_previous: str | None = None,
) -> list[str]:
    if relative not in (MP_PATH, JA_PATH):
        return _LAST11_OLD_MG9_SOURCE_ERRORS(relative, current, registered_previous)
    old, errors = _last11_projection(current, relative)
    if errors:
        return errors
    return _LAST11_OLD_MG9_SOURCE_ERRORS(relative, old, registered_previous)


def _last11_mg9_project_bytes(current: bytes, relative: str) -> bytes:
    if relative not in (MP_PATH, JA_PATH):
        return _LAST11_OLD_MG9_PROJECT_BYTES(current, relative)
    old, errors = _last11_projection(current, relative)
    if errors or _LAST11_OLD_MG9_SOURCE_ERRORS(relative, old):
        return current
    return _LAST11_OLD_MG9_PROJECT_BYTES(old, relative)


def _last11_mg9_project_hash(claim: str, relative: str, current: bytes) -> str:
    if relative not in (MP_PATH, JA_PATH):
        return _LAST11_OLD_MG9_PROJECT_HASH(claim, relative, current)
    old, errors = _last11_projection(current, relative)
    if (errors or hashlib.sha256(current).hexdigest() != claim
            or _LAST11_OLD_MG9_SOURCE_ERRORS(relative, old)):
        return claim
    return _LAST11_OLD_MG9_PROJECT_HASH(hashlib.sha256(old).hexdigest(), relative, old)


mg9_source_errors = _last11_mg9_source_errors
mg9_project_bytes = _last11_mg9_project_bytes
mg9_project_byte_hash = _last11_mg9_project_hash
# END_LAST11_META_TITLE_SUCCESSOR_255
