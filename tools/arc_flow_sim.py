#!/usr/bin/env python3
"""arc_flow_sim.py — _next_arc_id() 턴별 흐름 시뮬레이터 (회귀 검증용)

목적: 보장 비트 개수만 세는 게 아니라, 실제 한 플레이가 240턴 동안 어떤 아크를
발동하는지 턴별로 추적해 다음을 잡는다.
  1) 아크 잼   — 같은 아크가 여러 턴 반복 발동(윈도우/가드 누락 = 중첩 if 버그 등)
  2) 데드존    — authored 아크가 길게 침묵하는 구간(랜덤풀이 메우지만 스파인 thin 신호)
  3) 아크 완결 — 캐릭터 아크가 경로별로 start→finish 도달하는지

방법: _next_arc_id()를 들여쓰기-인식 파싱(중첩 if·백슬래시 연속행·inline if),
이벤트 JSON에서 self-guard 플래그를 ground-truth로 추출, 상태 궤적과 스파인 선택
플래그를 스크립트로 구동해 GDScript 조건을 Python에서 평가.

주의: 근사 시뮬레이터다(스크립트 경로). 절대적 진실이 아니라 "잼/데드엔드/미완결"
같은 구조 회귀를 빨리 잡는 용도. 경로 정의(PATHS)를 늘려 커버리지를 넓힐 수 있다.

사용: python3 tools/arc_flow_sim.py [--verbose]
종료코드: 잼이 1건이라도 있으면 1, 아니면 0.
"""
import re, json, glob, sys, os

from event_schedule import deferred_follow_ups

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
os.chdir(ROOT)
VERBOSE = "--verbose" in sys.argv
BRIDGE_EVENTS = {
    "arc_money_check_low",
    "arc_money_check_mid",
    "arc_money_check_high",
    "arc_gosiwon_wall",
    "arc_invest_guidance",
    "arc_paycheck_reality",
    "arc_office_routine",
    "arc_night_routine",
}

# ── ground truth: event -> 본문/설정 가능한 플래그 ────────────────────────
events = {}
event_sets = {}
for fp in glob.glob("content/events/*.json"):
    try:
        data = json.load(open(fp, encoding="utf-8"))
    except Exception:
        continue
    for ev in (data if isinstance(data, list) else list(data.values())):
        if isinstance(ev, dict) and ev.get("id"):
            events[ev["id"]] = ev
            event_sets[ev["id"]] = set(
                fl for ch in ev.get("choices", []) for fl in ch.get("flags", []))

with open("content/meta/chapter5_causal_ledger.json", encoding="utf-8") as fp:
    CHAPTER5_LEDGER = json.load(fp)
CHAPTER5_ROOTS = CHAPTER5_LEDGER.get("roots", [])
CHAPTER5_ROOT_IDS = [str(root.get("event_id", "")) for root in CHAPTER5_ROOTS]
CHAPTER5_DEFAULT_CHOICES = {
    event_id: 0 for event_id in CHAPTER5_ROOT_IDS
}
# Exercise both conditional receipts in the representative product trace.
CHAPTER5_DEFAULT_CHOICES["arc_sangchul_final_door"] = 0
CHAPTER5_DEFAULT_CHOICES["arc_y5_three_in_room_decision"] = 1
CHAPTER5_DEFAULT_CHOICES["arc_y5_jaehyuk_guarantee_decision_reference"] = 1
CHAPTER5_ENTRY = {
    "route_id": "investment_property",
    "turn": 195,
    "economic_route": "investment",
    "asset_band": "at_least_2b",
    "actor_bindings": {
        "chooser": "player",
        "proposer": "sangchul",
        "reviewer": "sangchul",
        "protected_person": "daeun",
        "guarantee_party": "jaehyuk",
        "cost_witness": "minseo",
    },
}
with open("content/meta/chapter5_finale_ledger.json", encoding="utf-8") as fp:
    CHAPTER5_FINALE_LEDGER = json.load(fp)
CHAPTER5_FINALE_ROOTS = CHAPTER5_FINALE_LEDGER.get("roots", [])
CHAPTER5_FINALE_ROOT_IDS = [
    str(root.get("event_id", "")) for root in CHAPTER5_FINALE_ROOTS
]
CHAPTER5_FINALE_DEFAULT_CHOICES = {
    event_id: 0 for event_id in CHAPTER5_FINALE_ROOT_IDS
}
CHAPTER5_FINALE_NO_EXECUTION = {
    "kind": "none",
    "reason": "no_executable_contract",
    "cash_delta_krw": 0,
    "asset_delta_krw": 0,
    "debt_delta_krw": 0,
}
CHAPTER5_FINALE_ACTORS = (
    CHAPTER5_FINALE_LEDGER.get("entry_contract", {})
    .get("actor_bindings", {})
)
W212_OUTCOMES = [
    {
        "effects": {"mental": -8, "tint": 7},
        "flags": ["arc_jaehyuk_mirror_seen", "refused_jaehyuk_guarantee"],
    },
    {
        "effects": {"mental": -15, "tint": -6},
        "flags": [
            "arc_jaehyuk_mirror_seen", "vouched_jaehyuk_guarantee",
            "jaehyuk_exploited", "crossed_line",
        ],
    },
    {
        "effects": {"mental": -5, "tint": -2},
        "flags": ["arc_jaehyuk_mirror_seen", "blocked_jaehyuk_guarantee"],
    },
]

# ── _next_arc_id() 파싱 (들여쓰기 스택으로 중첩 if AND) ───────────────────
src = open("scenes/MainGame.gd").read()


def source_function_block(function_name):
    """Return one top-level GDScript function for source-contract checks."""
    declaration = re.search(
        rf"^func {re.escape(function_name)}\(", src, re.MULTILINE)
    if declaration is None:
        return ""
    end = src.find("\nfunc ", declaration.end())
    return src[declaration.start():end if end >= 0 else len(src)]


go_story_mode_source = source_function_block("_go_story_mode")
W193_STORY_HANDOFF_SOURCE_OK = all(re.search(pattern, go_story_mode_source) for pattern in (
    r'GameState\.turn\s*==\s*193',
    r'first_event_id\s*==\s*"chapter_card_37"',
    r'var\s+reckoning_claim\s*:=\s*GameState\.claim_deferred_event\(\s*'
    r'"arc_37_reckoning"\s*,\s*193\s*\)',
    r'if\s+not\s+reckoning_claim\.is_empty\(\)\s*:',
    r'story_queue\.append\(\s*"arc_37_reckoning"\s*\)',
))
chapter5_finale_route_source = source_function_block(
    "_route_chapter5_finale_week")
chapter5_finale_complete_source = source_function_block(
    "_complete_chapter5_finale_week_after_story")
continue_after_story_source = source_function_block("_continue_after_story")
CHAPTER5_FINALE_DIRECT_SOURCE_OK = all((
    "GameState.prepare_chapter5_finale_route_entry()"
    in chapter5_finale_route_source,
    "GameState.chapter5_finale_next_event_for_turn()"
    in chapter5_finale_route_source,
    "CHAPTER5_FINALE_ROUTE.is_owned_event(event_id)"
    in chapter5_finale_route_source,
    "_go_story_mode([event_id], keep_cover)"
    in chapter5_finale_route_source,
    "GameState.chapter5_finale_ending_ready()"
    in chapter5_finale_complete_source,
    "GameState.consume_chapter5_finale_ending_check()"
    in chapter5_finale_complete_source,
    "_check_game_over_with_monotonic_story_state()"
    in chapter5_finale_complete_source,
    "GameState.chapter5_finale_week_completed()"
    in chapter5_finale_complete_source,
    "_demo_director_finish_auto_week()"
    in chapter5_finale_complete_source,
    "_render_ap_actions" not in chapter5_finale_route_source,
    "_render_ap_actions" not in chapter5_finale_complete_source,
    continue_after_story_source.find("_route_chapter5_finale_week(true)")
    < continue_after_story_source.find("_render_ap_actions"),
    continue_after_story_source.find(
        "_complete_chapter5_finale_week_after_story()")
    < continue_after_story_source.find("_render_ap_actions"),
))
next_arc_source = source_function_block("_next_arc_id")
generic_finale_source = source_function_block("_generic_finale_arc_id")
generic_router_index = next_arc_source.find("var generic_finale_id")
chapter_card_index = next_arc_source.find(
    'if f.get("prologue_done", false)')
generic_countdown_index = generic_finale_source.find(
    'return "arc_final_countdown"')
generic_final_week_index = generic_finale_source.find(
    'return "arc_final_week"')
GENERIC_FINALE_SOURCE_OK = all((
    re.search(
        r"if\s+at_turn\s*!=\s*240\s+or\s+chapter5_finale_locked\s*:",
        generic_finale_source,
    ),
    re.search(
        r'not\s+f\.get\("arc_final_countdown_seen",\s*false\)',
        generic_finale_source,
    ),
    re.search(
        r'not\s+f\.get\("arc_final_week_seen",\s*false\)',
        generic_finale_source,
    ),
    re.search(
        r"_generic_finale_arc_id\(\s*t,\s*f,\s*chapter5_finale_locked\s*\)",
        next_arc_source,
    ),
    re.search(
        r"if\s+not\s+generic_finale_id\.is_empty\(\)\s*:\s*"
        r"return\s+generic_finale_id",
        next_arc_source,
    ),
    0 <= generic_countdown_index < generic_final_week_index,
    0 <= generic_router_index < chapter_card_index,
))
generic_countdown_choices = events.get(
    "arc_final_countdown", {}).get("choices", [])
generic_final_week_choices = events.get(
    "arc_final_week", {}).get("choices", [])
GENERIC_FINALE_FOLLOW_UP_OK = bool(generic_countdown_choices) \
    and bool(generic_final_week_choices) \
    and all(
        choice.get("follow_up_event") == "arc_final_week"
        and "arc_final_countdown_seen" in choice.get("flags", [])
        for choice in generic_countdown_choices
    ) \
    and all(
        "arc_final_week_seen" in choice.get("flags", [])
        for choice in generic_final_week_choices
    )

next_arc_decl = re.search(
    r"^func _next_arc_id\([^)]*\)(?:\s*->\s*[^:]+)?\s*:", src, re.MULTILINE)
if next_arc_decl is None:
    print("❌ _next_arc_id declaration not found")
    sys.exit(1)
s = next_arc_decl.start()
e = src.find("\nfunc ", next_arc_decl.end())
raw = src[s:e].split("\n")
merged = []
i = 0
while i < len(raw):
    ln = raw[i]
    if ln.strip() == "" or ln.strip().startswith("#"):
        i += 1
        continue
    ind = len(ln) - len(ln.lstrip("\t"))
    tx = ln.strip()
    while tx.rstrip().endswith("\\"):
        i += 1
        tx = tx.rstrip()[:-1] + " " + raw[i].strip()
    merged.append((ind, tx))
    i += 1

triggers = []  # (arc_id, [conditions])
stack = []
for ind, tx in merged:
    while stack and stack[-1][0] >= ind:
        stack.pop()
    m_if = re.match(r'(if|elif)\s+(.*):$', tx)
    m_else = re.match(r'else\s*:$', tx)
    m_ret = re.search(r'return "((?:arc_|hyunsu_)[a-z0-9_]+)"', tx)
    if m_ret:
        conds = [c for _, c in stack]
        inl = re.match(r'if\s+(.*):\s*return', tx)
        if inl:
            conds = conds + [inl.group(1)]
        if m_ret.group(1) in BRIDGE_EVENTS:
            conds = [c for c in conds if "_resolve_demo_narrative_bridge" not in c]
        triggers.append((m_ret.group(1), conds))
    if m_if and not re.search(r':\s*return', tx):
        stack.append((ind, m_if.group(2)))
    elif m_else:
        stack.append((ind, "True"))


class Job(dict):
    def is_empty(self):
        return len(self) == 0


class State:
    def __init__(s):
        s.t = 0; s.age = 33; s.flags = {
            # Representative A/B traces take the week-one Secure Work route.
            # Non-application causality is locked by the Godot runtime checks.
            "opening_interview_application_sent": True,
            "opening_interview_application_turn": 1,
        }
        s.items = set()
        s.route_orthodox = 0; s.route_unorthodox = 0; s.intelligence = 50
        s.money = 500000; s.investment_skill = 0; s.job_tenure = 0
        s.player_route = "직장형"; s.moral_tint = 0
        s.housing = "gosiwon"; s.current_job = Job(); s.nav = 500000
        s.deferred_events = []
        s.chapter5_receipts = {}
        s.chapter5_order = []
        s.chapter5_entry = {}
        s.chapter5_w212_tint = None
        s.chapter5_finale_receipts = {}
        s.chapter5_finale_order = []
        s.chapter5_finale_entry = {}
        s.chapter5_finale_ending_check = "pending"
        s.chapter5_finale_release_count = 0
        s.chapter5_finale_economic_mutations = 0
        s.cast = {k: {"aff": 0, "stage": "none"} for k in
                  ["sangchul", "daeun", "jiyeon", "jaehyuk", "father", "hyunsu"]}

    def get_total_asset_value(s): return s.nav
    def get_cast_affinity(s, n): return s.cast.get(n, {}).get("aff", 0)
    def get_cast_stage(s, n): return s.cast.get(n, {}).get("stage", "none")
    def cast_has_flag(s, n, fl): return fl in s.cast.get(n, {}).get("flags", set())
    def has_item(s, item_id): return item_id in s.items
    def add_deferred_event(s, event_id, delay):
        trigger_turn = s.t + max(int(delay), 0)
        for entry in s.deferred_events:
            if entry[1] == event_id:
                entry[0] = min(entry[0], trigger_turn)
                return
        s.deferred_events.append([trigger_turn, event_id])

    def has_deferred_event(s, event_id):
        return any(entry[1] == event_id for entry in s.deferred_events)

    def claim_deferred_event(s, event_id, due_turn=-1):
        candidates = [
            (index, entry) for index, entry in enumerate(s.deferred_events)
            if entry[1] == event_id
            and entry[0] <= s.t
            and (due_turn < 0 or entry[0] == due_turn)
        ]
        if not candidates:
            return {}
        selected_index, selected = min(candidates, key=lambda row: row[1][0])
        s.deferred_events.pop(selected_index)
        return {
            "event_id": event_id,
            "trigger_turn": selected[0],
            "claimed_turn": s.t,
        }

    def pop_ready_deferred_event(s):
        ready = [entry for entry in s.deferred_events if entry[0] <= s.t]
        if not ready:
            return ""
        selectable = []
        for entry in ready:
            if entry[1] != "arc_jaehyuk_mirror":
                selectable.append(entry)
                continue
            resolved = any(s.flags.get(flag) for flag in (
                "arc_jaehyuk_mirror_seen", "refused_jaehyuk_guarantee",
                "vouched_jaehyuk_guarantee", "blocked_jaehyuk_guarantee",
            ))
            if resolved:
                s.deferred_events.remove(entry)
                continue
            if chapter5_guarantee_relocation_reserved(s) \
                    and (s.t < 209 or bool(s.chapter5_entry)):
                continue
            selectable.append(entry)
        if not selectable:
            return ""
        selected = min(
            selectable,
            key=lambda entry: (entry[0], s.deferred_events.index(entry)))
        s.deferred_events.remove(selected)
        return selected[1]

    def pop_ready_deferred_events(s):
        event_id = s.pop_ready_deferred_event()
        return [event_id] if event_id else []

    def chapter5_causal_product_path_available(s):
        return chapter5_product_path_available(s)

    def chapter5_general_finale_w220_available(s, at_turn=-1):
        """Approximate the exact W220 gate used by the runtime router."""
        query_turn = s.t if int(at_turn) < 0 else int(at_turn)
        if query_turn != 220 or s.chapter5_entry or s.chapter5_finale_entry:
            return False
        route_invest = s.flags.get("route_invest") is True
        route_career = s.flags.get("route_career") is True
        route_startup = s.flags.get("route_startup") is True
        neutral = s.player_route == "none" \
            and not route_invest and not route_career and not route_startup
        investment_general = s.player_route == "투자형" \
            and route_invest and not route_career and not route_startup
        if not (neutral or investment_general) or not father_death_is_monotonic(s):
            return False
        minseo_sources = sum(bool(s.flags.get(
            f"chapter5_general_minseo_arrival_{index}")) for index in range(2))
        if minseo_sources != 1:
            return False
        if any(key in s.flags for key in (
            "arc_endgame_sixmonths_seen",
            "arc_y5_general_last_page_instruction_seen",
            "chapter5_general_last_page_instruction_0",
            "chapter5_general_last_page_instruction_1",
            "arc_y5_general_debt_memory_reconnect_seen",
            "chapter5_general_debt_memory_reconnect_0",
            "chapter5_general_debt_memory_reconnect_1",
        )):
            return False
        return True


def chapter5_condition_active(root, receipts):
    condition = root.get("condition")
    if condition is None:
        return True
    source = receipts.get(str(condition.get("event_id", "")), {})
    return int(source.get("choice_index", -1)) == int(
        condition.get("choice_index", -2))


def chapter5_daeun_path_live(S):
    return bool(
        S.flags.get("arc_daeun_met")
        and any(S.flags.get(flag) for flag in (
            "daeun_chose_her", "daeun_together_path", "daeun_close_bond",
            "daeun_romance_started", "daeun_married", "daeun_final_together",
        ))
        and not S.flags.get("daeun_let_her_go")
        and not S.flags.get("daeun_divorced")
    )


def chapter5_guarantee_relocation_reserved(S):
    return bool(
        S.player_route == "투자형"
        and S.flags.get("route_invest")
        and chapter5_daeun_path_live(S)
        and S.flags.get("arc_jaehyuk_reunion_seen")
        and S.flags.get("arc_jaehyuk_aftermath_seen")
        and not any(S.flags.get(flag) for flag in (
            "arc_jaehyuk_mirror_seen", "refused_jaehyuk_guarantee",
            "vouched_jaehyuk_guarantee", "blocked_jaehyuk_guarantee",
            "jaehyuk_final_break",
        ))
    )


def chapter5_participants_ready(S):
    return bool(
        S.flags.get("arc_sangchul_met_seen")
        and not any(S.flags.get(flag) for flag in (
            "sangchul_reported", "sangchul_cut_ties",
            "sangchul_quietly_distanced",
        ))
        and chapter5_daeun_path_live(S)
        and S.flags.get("arc_minseo_02_seen")
        and chapter5_guarantee_relocation_reserved(S)
    )


def chapter5_product_path_available(S):
    if S.chapter5_entry:
        return S.chapter5_entry == CHAPTER5_ENTRY
    return bool(
        S.player_route == "투자형"
        and S.flags.get("route_invest")
        and chapter5_participants_ready(S)
        and S.nav >= 2_000_000_000
    )


def lock_chapter5_entry(S):
    if S.chapter5_entry:
        return S.chapter5_entry == CHAPTER5_ENTRY
    if S.t != 195 or not chapter5_product_path_available(S):
        return False
    S.chapter5_entry = json.loads(json.dumps(CHAPTER5_ENTRY))
    return True


def old_jaehyuk_mirror_event(S):
    if not S.flags.get("arc_jaehyuk_aftermath_seen"):
        return ""
    if any(S.flags.get(flag) for flag in (
        "arc_jaehyuk_mirror_seen", "refused_jaehyuk_guarantee",
        "vouched_jaehyuk_guarantee", "blocked_jaehyuk_guarantee",
    )) or S.has_deferred_event("arc_jaehyuk_mirror"):
        return ""
    minimum_turn = 209 if chapter5_guarantee_relocation_reserved(S) else 60
    return "arc_jaehyuk_mirror" if S.t >= minimum_turn else ""


def chapter5_next_root(S):
    for root in CHAPTER5_ROOTS:
        event_id = str(root.get("event_id", ""))
        if event_id in S.chapter5_receipts:
            continue
        if not chapter5_condition_active(root, S.chapter5_receipts):
            continue
        return root
    return {}


def chapter5_causal_event(S):
    if not chapter5_product_path_available(S):
        return ""
    if S.t == 195 and not S.chapter5_entry and not lock_chapter5_entry(S):
        return ""
    root = chapter5_next_root(S)
    if int(root.get("turn", -1)) != S.t:
        return ""
    return str(root.get("event_id", ""))


def commit_chapter5_choice(S, event_id, choice_indices):
    if not chapter5_product_path_available(S):
        return False
    if not S.chapter5_entry and not lock_chapter5_entry(S):
        return False
    root = chapter5_next_root(S)
    if str(root.get("event_id", "")) != event_id:
        return False
    choices = root.get("choices", [])
    choice_index = int(choice_indices.get(
        event_id, CHAPTER5_DEFAULT_CHOICES.get(event_id, 0)))
    if choice_index < 0 or choice_index >= len(choices):
        return False
    S.chapter5_receipts[event_id] = {
        "event_id": event_id,
        "turn": int(root.get("turn", -1)),
        "choice_index": choice_index,
    }
    S.chapter5_order.append(event_id)
    authored_choices = events.get(event_id, {}).get("choices", [])
    if choice_index < len(authored_choices):
        authored_choice = authored_choices[choice_index]
        for flag in authored_choice.get("flags", []):
            S.flags[str(flag)] = True
        effects = authored_choice.get("effects", {})
        S.moral_tint += float(effects.get("tint", 0))
    if event_id == "arc_y5_jaehyuk_guarantee_decision_reference":
        S.chapter5_w212_tint = S.moral_tint
    return True


def eligible_chapter5_fixture():
    S = State()
    S.t = 195
    S.player_route = "투자형"
    S.nav = 2_000_000_000
    S.flags.update({
        "route_invest": True,
        "arc_sangchul_met_seen": True,
        "arc_daeun_met": True,
        "daeun_romance_started": True,
        "arc_minseo_02_seen": True,
        "arc_jaehyuk_reunion_seen": True,
        "arc_jaehyuk_aftermath_seen": True,
    })
    return S


def father_death_is_monotonic(S):
    """Mirror every durable death receipt accepted by MainGame."""
    return bool(
        S.flags.get("father_passed")
        or S.flags.get("arc_father_passing_seen")
        or S.get_cast_stage("father") == "passed"
    )


def chapter5_causal_route_complete(S):
    return bool(S.chapter5_entry) and not chapter5_next_root(S)


def chapter5_finale_source_choices(S):
    source_events = {
        "m55_decision": "arc_y5_three_in_room_decision",
        "w212_guarantee": "arc_y5_jaehyuk_guarantee_decision_reference",
        "w215_final_door": "arc_sangchul_final_door",
    }
    return {
        key: int(S.chapter5_receipts.get(event_id, {}).get(
            "choice_index", -1))
        for key, event_id in source_events.items()
    }


def chapter5_finale_father_snapshot(S):
    modes = [
        mode for mode, flag in (
            ("present", "father_crisis_contact_present"),
            ("called", "father_crisis_contact_called"),
            ("missed", "father_crisis_contact_missed"),
        )
        if S.flags.get(flag)
    ]
    return {
        "life": "passed" if father_death_is_monotonic(S) else "alive",
        "contact_mode": modes[0] if len(modes) == 1 else "records_only",
    }


def chapter5_finale_expected_entry(S):
    return {
        "route_id": "chapter5_safe_finale",
        "turn": 221,
        "profile_id": "investment_safe_no_execution",
        "source_route_id": "investment_property",
        "source_choices": chapter5_finale_source_choices(S),
        "father": chapter5_finale_father_snapshot(S),
        "actor_bindings": json.loads(json.dumps(CHAPTER5_FINALE_ACTORS)),
    }


def chapter5_finale_root_active(root, entry):
    condition = root.get("active_when")
    if condition is None:
        return True
    value = entry
    for key in str(condition.get("entry_path", "")).split("."):
        if not isinstance(value, dict) or key not in value:
            return False
        value = value[key]
    return value == condition.get("equals")


def chapter5_finale_next_root(S):
    if not S.chapter5_finale_entry:
        return {}
    for root in CHAPTER5_FINALE_ROOTS:
        event_id = str(root.get("event_id", ""))
        if event_id in S.chapter5_finale_receipts:
            continue
        if not chapter5_finale_root_active(root, S.chapter5_finale_entry):
            continue
        return root
    return {}


def lock_chapter5_finale_entry(S):
    if S.chapter5_finale_entry:
        return S.chapter5_finale_entry == chapter5_finale_expected_entry(S)
    if S.t != 221 or not chapter5_causal_route_complete(S):
        return False
    source_choices = chapter5_finale_source_choices(S)
    if set(source_choices.values()) & {-1}:
        return False
    S.chapter5_finale_entry = chapter5_finale_expected_entry(S)
    return True


def chapter5_finale_event(S):
    if S.t == 221 and not S.chapter5_finale_entry \
            and not lock_chapter5_finale_entry(S):
        return ""
    root = chapter5_finale_next_root(S)
    if int(root.get("turn", -1)) != S.t:
        return ""
    return str(root.get("event_id", ""))


def chapter5_finale_holds_ending(S):
    return bool(S.chapter5_finale_entry) \
        and S.chapter5_finale_ending_check in ("pending", "ready")


def generic_finale_event(S):
    """Mirror MainGame's exact W240 fallback outside the typed finale."""
    if S.t != 240 or chapter5_finale_holds_ending(S):
        return ""
    if not S.flags.get("arc_final_countdown_seen"):
        return "arc_final_countdown"
    if not S.flags.get("arc_final_week_seen"):
        return "arc_final_week"
    return ""


def chapter5_finale_receipt(root, choice_index):
    choice = root.get("choices", [])[choice_index]
    outcome = choice.get("economic_outcome", {})
    if str(root.get("stage", "")) == "nontransaction":
        outcome = CHAPTER5_FINALE_NO_EXECUTION
    return {
        "stage": str(root.get("stage", "")),
        "event_id": str(root.get("event_id", "")),
        "turn": int(root.get("turn", -1)),
        "choice_index": choice_index,
        "actors": json.loads(json.dumps(root.get("actors", {}))),
        "receipt_ids": list(choice.get("receipt_ids", [])),
        "document_ids": list(choice.get("document_ids", [])),
        "economic_outcome": json.loads(json.dumps(outcome)),
    }


def commit_chapter5_finale_choice(S, event_id, choice_indices):
    root = chapter5_finale_next_root(S)
    if str(root.get("event_id", "")) != event_id \
            or int(root.get("turn", -1)) != S.t:
        return False
    choices = root.get("choices", [])
    choice_index = int(choice_indices.get(
        event_id, CHAPTER5_FINALE_DEFAULT_CHOICES.get(event_id, 0)))
    if choice_index < 0 or choice_index >= len(choices):
        return False
    economic_before = (S.money, S.nav)
    S.chapter5_finale_receipts[event_id] = chapter5_finale_receipt(
        root, choice_index)
    S.chapter5_finale_order.append(event_id)
    authored_choices = events.get(event_id, {}).get("choices", [])
    if choice_index < len(authored_choices):
        authored_choice = authored_choices[choice_index]
        for flag in authored_choice.get("flags", []):
            S.flags[str(flag)] = True
        S.moral_tint += float(
            authored_choice.get("effects", {}).get("tint", 0))
    if economic_before != (S.money, S.nav):
        S.chapter5_finale_economic_mutations += 1
    if str(root.get("stage", "")) == "outbound":
        S.chapter5_finale_ending_check = "ready"
    return True


def evalconds(conds, S):
    for r in conds:
        c = r.strip().rstrip(':')
        c = re.sub(r'_mp\.get\([^)]*\)', 'False', c)
        c = re.sub(r'MetaProgression\.meta\.get\([^)]*\)', 'False', c)
        # The two representative 240-week traces model the legacy director,
        # not a Core Loop V2 save. V2's receipt-backed Week-27 result has its
        # own runtime gate; here the memory helper must remain false so the
        # canonical legacy Week-25 failure branch stays in the simulated graph.
        c = re.sub(r'\bv2_hyunsu_receipt_known\b', 'False', c)
        c = c.replace("false", "False").replace("true", "True")
        c = c.replace(
            "CHAPTER5_CAUSAL_ROUTE.ENTRY_PLAYER_ROUTE", '"투자형"')
        c = re.sub(
            r'\bchapter5_finale_locked\b',
            str(chapter5_finale_holds_ending(S)), c)
        c = c.replace("GameState.flags", "S.flags").replace("GameState.", "S.")
        c = re.sub(r'\bf\.get\(', 'S.flags.get(', c)
        c = re.sub(r'\bnav\b', 'S.nav', c)
        c = re.sub(r'\b_asset\b', 'S.nav', c)
        c = re.sub(r'(?<![\w.])t(?![\w])', 'S.t', c)
        c = c.replace("_age", "S.age")
        try:
            if not bool(eval(c, {
                "S": S,
                "father_is_passed": father_death_is_monotonic(S),
                "_chapter5_general_w220_reserves_generic": (
                    lambda at_turn: int(at_turn) <= 220
                    and S.chapter5_general_finale_w220_available(220)
                ),
            })):
                return False
        except Exception:
            return False  # 평가 불가 조건은 보수적으로 미발동 처리
    return True


_guaranteed_flag_memo = {}


def guaranteed_path_flags(eid, stack=()):
    """Return flags written on every possible immediate StoryMode path."""
    if eid in _guaranteed_flag_memo:
        return _guaranteed_flag_memo[eid]
    if eid in stack or eid not in events:
        return set()
    choices = events[eid].get("choices", [])
    if not choices:
        return set()
    branches = []
    for choice in choices:
        branch = set(choice.get("flags", []))
        follow_up = str(choice.get("follow_up_event", "")).strip()
        if follow_up:
            branch |= guaranteed_path_flags(follow_up, stack + (eid,))
        branches.append(branch)
    guaranteed = set.intersection(*branches) if branches else set()
    _guaranteed_flag_memo[eid] = guaranteed
    return guaranteed


def own_seen_flags(eid):
    return [fl for fl in guaranteed_path_flags(eid)
            if fl.endswith(("_seen", "_done", "_closed"))]


def canonical_deferred_links(eid, choice_indices, stack=()):
    """Follow one representative immediate branch and collect its timed echoes."""
    if eid in stack or eid not in events:
        return []
    choices = events[eid].get("choices", [])
    if not choices:
        return []
    index = int(choice_indices.get(eid, 0))
    if index < 0 or index >= len(choices):
        index = 0
    choice = choices[index]
    links = []
    links.extend(deferred_follow_ups(choice))
    follow_up = str(choice.get("follow_up_event", "")).strip()
    if follow_up:
        links.extend(canonical_deferred_links(follow_up, choice_indices, stack + (eid,)))
    return links


# ── 경로 정의: 각 아크 발동 시 세팅할 스파인 진행 플래그 ──────────────────
# (없는 키는 own _seen만 자동 세팅)
SPINE_COMMON = {
    "arc_intro_04_hyunsu": ["arc_intro_hyunsu_seen"],
    "arc_sangchul_01_meet": ["arc_sangchul_met_seen", "sangchul_met"],
    "arc_sangchul_02_coffee": ["arc_sangchul_02_seen"],
    "arc_sangchul_03_network": ["arc_sangchul_03_seen"],
    "arc_sangchul_offguard": ["arc_sangchul_offguard_seen"],
    "arc_sangchul_human": ["arc_sangchul_human_seen"],
    "arc_daeun_01_meet": ["arc_daeun_met", "daeun_met"],
    "arc_daeun_02_regular": ["arc_daeun_regular_seen"],
    "arc_father_01_call": ["arc_father_01_seen"],
    "arc_father_02_signal": ["arc_father_02_done"],
    "arc_father_03_hospital": ["arc_father_03_seen"],
    "arc_father_04_visit": ["visited_father"],
    "arc_father_05_after_visit": ["arc_father_05_seen"],
    # Representative traces take the first medication action: call and check.
    # W188 reads this durable medical receipt, not the later crisis-contact mode.
    "arc_father_medication": ["arc_father_medication_seen", "called_about_medication"],
    "arc_father_06_confession": ["arc_father_06_seen", "father_confession_heard", "father_reconciled"],
    "arc_jiyeon_01_crash": ["arc_jiyeon_crash_seen"],
    "arc_jiyeon_02_store": ["arc_jiyeon_store_seen"],
    "arc_jiyeon_03_offer": ["arc_jiyeon_offer_seen"],
    "arc_jiyeon_03b_lunch": ["arc_jiyeon_03b_seen"],
    "arc_jiyeon_05_epilogue": ["arc_jiyeon_epilogue_seen"],
    "arc_jaehyuk_01_reunion": ["arc_jaehyuk_reunion_seen"],
    "arc_jaehyuk_01b_real_face": ["arc_jaehyuk_01b_seen"],
    "arc_jaehyuk_02_bond": ["arc_jaehyuk_bond_seen"],
    "arc_jaehyuk_02b_favor": ["arc_jaehyuk_02b_seen"],
    "arc_jaehyuk_aftermath": ["arc_jaehyuk_aftermath_seen"],
    # The expanded mirror chain writes its route guard on the terminal link,
    # not on the scheduled root event. Model one canonical terminal outcome so
    # both representative paths match StoryMode's immediate follow-up chain.
    "arc_jaehyuk_mirror": ["arc_jaehyuk_mirror_seen", "refused_jaehyuk_guarantee"],
    "hyunsu_study_together": ["hyunsu_study_together_seen"],
    "arc_hyunsu_night_talk": ["arc_hyunsu_night_seen"],
    "hyunsu_exam_day": ["hyunsu_exam_day_seen"],
    "hyunsu_result_fail": ["hyunsu_failed"],
    "hyunsu_result_pass": ["hyunsu_passed"],
    "arc_hyunsu_exam_fail": ["arc_hyunsu_exam_fail_seen"],
    "arc_hyunsu_drift": ["arc_hyunsu_drift_seen"],
    "arc_hyunsu_new_path": ["arc_hyunsu_new_path_seen", "hyunsu_pivoted"],
    "hyunsu_pivot": ["hyunsu_pivoted"],
    # The reunion now writes its guard on the in-person terminal link.
    "hyunsu_reunion_later": ["hyunsu_reconnected"],
    "arc_midpoint_reckoning": ["arc_midpoint_reckoning_seen"],
    "arc_goshiwon_goodbye": ["arc_goshiwon_goodbye_seen"],
    "arc_housing_new_life": ["arc_housing_new_life_seen"],
    "arc_jaewon_01_meet": ["arc_jaewon_01_seen"],
    "arc_jaewon_02_advice": ["arc_jaewon_02_seen"],
    "arc_jaewon_03_farewell": ["arc_jaewon_03_seen"],
    "arc_father_passing": ["father_passed"],
    "arc_34_money_attracts_money": ["arc_34_money_attracts_seen"],
    "arc_34_doors_open": ["arc_34_doors_open_seen"],
    "arc_35_path_cost": ["arc_35_path_cost_seen", "embraced_cost"],
    "arc_36_unexpected_hand": ["arc_36_unexpected_hand_seen"],
    "arc_36_unexpected_hand_father_deal": ["arc_36_unexpected_hand_seen"],
    "arc_36_unexpected_hand_person_deal": ["arc_36_unexpected_hand_seen"],
}
PATH_A = dict(SPINE_COMMON, **{  # 정석/다은 보냄/사기당함/진실모름
    "arc_temptation_01": ["arc_temptation_seen", "kept_clean_hands"],
    # 방문하지 못한 경로를 고정해 23초 KTX 전처리와 임종 체인을 검증한다.
    "arc_father_04_visit": ["father_visit_deferred"],
    # The mirror is now independent from the M23 hospital-door decision.
    "arc_sangchul_mirror": ["arc_sangchul_mirror_seen"],
    "arc_daeun_03_fork": ["arc_daeun_fork_seen", "daeun_let_her_go"],
    "arc_daeun_ghost": ["arc_daeun_ghost_seen"],
    "arc_daeun_year3_apart": ["arc_daeun_year3_apart_seen"],
    "arc_jaehyuk_03_pitch": ["arc_jaehyuk_pitch_seen", "jaehyuk_trusted_fully"],
    "arc_jaehyuk_04a_ghost": ["arc_jaehyuk_ghost_seen", "jaehyuk_scammed"],
    "arc_jaehyuk_04c_stand_up": ["arc_jaehyuk_standup_seen"],
    "arc_sangchul_jiyeon_reveal": ["arc_sangchul_jiyeon_reveal_seen"],
    "arc_jiyeon_truth_moment": ["arc_jiyeon_truth_seen"],
    "arc_35_orthodox_weight": ["arc_35_orthodox_weight_seen", "stayed_my_path"],
    "arc_36_trust_crack": ["arc_36_trust_crack_seen", "crack_distanced"],
})
PATH_B = dict(SPINE_COMMON, **{  # 비정석/진실/다은 함께/재혁 역공
    "arc_temptation_01": ["arc_temptation_seen", "lent_account"],
    "arc_sangchul_mirror": ["arc_sangchul_mirror_seen"],
    "arc_sangchul_deduction": ["arc_sangchul_deduction_seen", "sangchul_truth_known", "deduced_sangchul_truth"],
    "arc_sangchul_known_offer": ["arc_sangchul_known_offer_seen", "used_sangchul_knowingly"],
    "arc_sangchul_known_reflex": ["arc_sangchul_known_reflex_seen"],
    "arc_sangchul_confrontation": ["arc_sangchul_confrontation_seen", "sangchul_confronted", "crossed_line"],
    "arc_sangchul_year3": ["arc_sangchul_year3_seen"],
    "arc_daeun_03_fork": ["arc_daeun_fork_seen", "daeun_chose_her", "daeun_together_path"],
    "arc_daeun_03b_date": ["arc_daeun_03b_seen"],
    "arc_daeun_04_morning": ["arc_daeun_04_seen"],
    "arc_daeun_04b_future": ["arc_daeun_04b_seen", "daeun_romance_started"],
    "arc_daeun_proposal": ["arc_daeun_proposal_seen", "daeun_married"],
    "arc_daeun_the_test": ["arc_daeun_test_seen", "used_daeun_as_means"],
    "arc_daeun_year3_together": ["arc_daeun_year3_together_seen"],
    "arc_daeun_year4_together": ["arc_daeun_year4_together_seen"],
    "arc_sangchul_jiyeon_reveal": ["arc_sangchul_jiyeon_reveal_seen", "warned_about_jiyeon"],
    "arc_jiyeon_truth_warned": ["arc_jiyeon_truth_seen"],
    "arc_jaehyuk_03_pitch": ["arc_jaehyuk_pitch_seen"],
    "arc_jaehyuk_04b_counter": ["arc_jaehyuk_counter_seen"],
    "arc_35_unorthodox_weight": ["arc_35_unorthodox_weight_seen", "adjusted_my_path"],
    "arc_36_trust_crack": ["arc_36_trust_crack_seen", "crack_softened"],
})


def traj_A(S):
    t = S.t; S.age = 33 + (t - 1) // 48 if t > 0 else 33
    S.player_route = "직장형"
    if t == 1: S.items.add("artifact_father_call")
    if t in (2, 5, 8, 12, 20, 30, 45, 60): S.route_orthodox += 1
    if t in (4, 25, 55): S.route_unorthodox += 1
    if t == 6: S.current_job = Job(id="job_01", title="staff", category="survival")
    if t >= 6: S.job_tenure = t - 5
    if t == 10: S.flags["has_received_paycheck"] = True
    if t == 30: S.housing = "oneroom"
    for tt, v in [(1, 5e5), (9, 3e6), (15, 1.2e7), (30, 5e7), (45, 9e7), (70, 1.5e8),
                  (100, 4e8), (150, 1e9), (190, 2e9), (210, 2.6e9), (235, 3e9)]:
        if t >= tt: S.nav = v
    if t >= 15: S.investment_skill = min(40, t - 10)
    if t >= 10:
        S.cast["sangchul"]["aff"] = min(70, (t - 10) * 2)
        if S.cast["sangchul"]["aff"] >= 20: S.cast["sangchul"]["stage"] = "interested"
    if t >= 9: S.cast["daeun"]["aff"] = min(30, t - 9)
    if t >= 17: S.cast["jiyeon"]["aff"] = min(40, t - 17)


def traj_B(S):
    t = S.t; S.age = 33 + (t - 1) // 48 if t > 0 else 33
    S.player_route = "투자형"
    S.flags["route_invest"] = True
    if t in (4, 8, 12, 18, 25, 33, 44, 55): S.route_unorthodox += 1
    if t in (20, 40): S.route_orthodox += 1
    S.intelligence = min(80, 50 + max(0, (t - 10)) // 4)
    if t == 6: S.current_job = Job(id="job_01", title="staff", category="survival")
    if t >= 6: S.job_tenure = t - 5
    if t == 10: S.flags["has_received_paycheck"] = True
    if t == 28: S.housing = "oneroom"
    for tt, v in [(1, 5e5), (9, 4e6), (15, 2e7), (30, 8e7), (45, 2e8), (70, 4e8),
                  (100, 8e8), (150, 1.5e9), (190, 2.3e9), (215, 2.7e9), (232, 3.1e9)]:
        if t >= tt: S.nav = v
    if t >= 15: S.investment_skill = min(60, t - 8)
    if t >= 10:
        S.cast["sangchul"]["aff"] = min(80, (t - 10) * 2)
        if S.cast["sangchul"]["aff"] >= 20: S.cast["sangchul"]["stage"] = "interested"
    if t >= 9: S.cast["daeun"]["aff"] = min(70, t - 9)
    if t >= 17: S.cast["jiyeon"]["aff"] = min(40, t - 17)
    if t == 42: S.flags["jaehyuk_suspected"] = True


def apply_bridge_choice(S, event_id, choice_indices):
    """Apply the representative existing choice without creating a foreground stop."""
    event = events[event_id]
    choices = event.get("choices", [])
    index = int(choice_indices.get(event_id, 0))
    if index < 0 or index >= len(choices):
        index = 0
    choice = choices[index]
    for flag in choice.get("flags", []):
        S.flags[str(flag)] = True
    effects = choice.get("effects", {})
    S.money += float(effects.get("money", 0))
    S.investment_skill += int(effects.get("investment_skill", 0))
    S.intelligence += int(effects.get("intelligence", 0))
    if str(choice.get("route", "")) == "orthodox":
        S.route_orthodox += 1
    elif str(choice.get("route", "")) == "unorthodox":
        S.route_unorthodox += 1
    for cast_id, cast_effect in choice.get("cast_effects", {}).items():
        S.cast.setdefault(str(cast_id), {"aff": 0, "stage": "none"})
        S.cast[str(cast_id)]["aff"] += int(cast_effect.get("affinity", 0))
    for deferred_id, delay in canonical_deferred_links(event_id, choice_indices):
        S.add_deferred_event(deferred_id, delay)


def apply_immediate_choice_state(S, event_id, choice_indices, stack=()):
    """Apply the representative terminal path for a protected StoryMode action."""
    if event_id in stack or event_id not in events:
        return
    choices = events[event_id].get("choices", [])
    if not choices:
        return
    index = int(choice_indices.get(event_id, 0))
    if index < 0 or index >= len(choices):
        index = 0
    choice = choices[index]
    for flag in choice.get("flags", []):
        S.flags[str(flag)] = True
    for cast_id, cast_effect in choice.get("cast_effects", {}).items():
        S.cast.setdefault(str(cast_id), {"aff": 0, "stage": "none"})
        S.cast[str(cast_id)]["aff"] += int(cast_effect.get("affinity", 0))
        if cast_effect.get("stage"):
            S.cast[str(cast_id)]["stage"] = str(cast_effect["stage"])
    follow_up = str(choice.get("follow_up_event", "")).strip()
    if follow_up:
        apply_immediate_choice_state(
            S, follow_up, choice_indices, stack + (event_id,))


def chapter_four_partner_id(S):
    if any(S.flags.get(flag) for flag in (
        "daeun_married", "daeun_romance_started", "daeun_together_path",
    )):
        return "daeun"
    if any(S.flags.get(flag) for flag in (
        "jiyeon_romance_started", "jiyeon_committed", "jiyeon_together",
    )):
        return "jiyeon"
    return ""


def chapter_four_relationship_event(S, daeun_id, jiyeon_id, unattached_id):
    partner_id = chapter_four_partner_id(S)
    if partner_id == "daeun":
        return daeun_id
    if partner_id == "jiyeon":
        return jiyeon_id
    return unattached_id


def chapter_four_father_outcome(S):
    if father_death_is_monotonic(S) or any(S.flags.get(flag) for flag in (
        "father_crisis_stabilized",
        "arc_y4_father_crisis_stabilized_seen",
        "arc_y4_father_outcome_unknown_seen",
    )):
        return ""
    if not all(S.flags.get(flag) for flag in (
        "arc_father_medication_seen", "arc_father_03_seen",
        "arc_y4_bill_night_seen",
    )):
        return "arc_y4_father_outcome_unknown"
    medication_called = bool(S.flags.get("called_about_medication"))
    medication_visited = bool(S.flags.get("visited_for_medication"))
    if medication_called and medication_visited:
        return "arc_y4_father_outcome_unknown"
    care_coordinated = bool(S.flags.get("father_care_coordinated"))
    care_left_open = bool(S.flags.get("father_care_left_open"))
    if care_coordinated == care_left_open:
        return "arc_y4_father_outcome_unknown"
    medical_evidence = int(medication_called or medication_visited)
    medical_evidence += int(bool(S.flags.get("sangchul_helped_with_father")))
    medical_evidence += int(care_coordinated)
    if medical_evidence >= 2:
        return "arc_y4_father_crisis_stabilized"
    return "arc_father_passing"


def story_graph_contract_event(S):
    """Mirror ORDER-143's exact M08+ typed story-graph router."""
    t = S.t
    f = S.flags
    father_is_passed = father_death_is_monotonic(S)
    if 25 <= t <= 240 \
            and f.get("arc_goshiwon_goodbye_seen") \
            and not f.get("arc_housing_new_life_seen"):
        return "arc_housing_new_life"
    if 193 <= t <= 208 \
            and f.get("arc_37_reckoning_seen") \
            and not f.get("arc_final_year_start_seen"):
        return "arc_final_year_start"
    if 197 <= t <= 208 \
            and not S.has_deferred_event("arc_37_reckoning") \
            and not f.get("arc_37_reckoning_seen") \
            and not f.get("arc_final_year_start_seen"):
        return "arc_37_reckoning"
    if t == 37 \
            and f.get("arc_housing_new_life_seen") \
            and S.housing != "gosiwon" \
            and not f.get("arc_y1_new_room_first_month_seen"):
        return "arc_y1_new_room_first_month"
    if 49 <= t <= 52:
        if not f.get("arc_year_one_mark_seen") \
                and not f.get("arc_34_money_attracts_seen"):
            return "arc_year_one_mark"
        if not f.get("arc_34_money_attracts_seen"):
            return "arc_34_money_attracts_money"
    if 53 <= t <= 56 and f.get("arc_34_money_attracts_seen"):
        network_eligible = bool(f.get("arc_sangchul_02_seen")) \
            and S.get_total_asset_value() >= 1_000_000
        if network_eligible:
            return "" if f.get("arc_sangchul_03_seen") \
                or f.get("arc_y2_bank_limit_review_seen") \
                else "arc_sangchul_03_network"
        return "" if f.get("arc_y2_bank_limit_review_seen") \
            or f.get("arc_sangchul_03_seen") \
            else "arc_y2_bank_limit_review"
    if 57 <= t <= 60 \
            and not father_is_passed \
            and f.get("arc_father_02_done") \
            and not f.get("arc_father_medication_seen"):
        return "arc_father_medication"
    if 77 <= t <= 80 and not f.get("arc_34_doors_open_seen"):
        return "arc_34_doors_open"
    if 82 <= t <= 88 \
            and not father_is_passed \
            and f.get("arc_father_02_done") \
            and f.get("arc_father_medication_seen") \
            and f.get("arc_34_parents_visit_seen") \
            and not f.get("arc_father_03_seen"):
        return "arc_father_03_hospital"
    if 85 <= t <= 88:
        chose_daeun = bool(f.get("daeun_chose_her"))
        released_daeun = bool(f.get("daeun_let_her_go"))
        if not f.get("arc_daeun_fork_seen") \
                and (chose_daeun or released_daeun):
            return ""
        if f.get("arc_daeun_fork_seen") \
                and not f.get("arc_daeun_fork_receipt_seen"):
            if chose_daeun and not released_daeun:
                return "arc_daeun_03_fork_hold_receipt"
            if released_daeun and not chose_daeun:
                return "arc_daeun_03_fork_release_receipt"
        if f.get("arc_daeun_fork_seen") \
                or f.get("arc_jiyeon_offer_seen") \
                or f.get("arc_y2_relationship_fork_unattached_seen"):
            return ""
        daeun_eligible = bool(f.get("arc_daeun_regular_seen")) \
            and S.get_cast_affinity("daeun") >= 12
        if daeun_eligible:
            return "" if f.get("arc_daeun_fork_seen") else "arc_daeun_03_fork"
        if f.get("arc_jiyeon_store_seen"):
            return "" if f.get("arc_jiyeon_offer_seen") else "arc_jiyeon_03_offer"
        return "" if f.get("arc_y2_relationship_fork_unattached_seen") \
            else "arc_y2_relationship_fork_unattached"
    if 89 <= t <= 92 \
            and not father_is_passed \
            and f.get("arc_father_02_done") \
            and f.get("arc_father_medication_seen"):
        if not f.get("arc_34_parents_visit_seen") \
                and not f.get("arc_father_03_seen"):
            return "arc_34_parents_visit"
        if f.get("arc_34_parents_visit_seen") \
                and not f.get("arc_father_03_seen"):
            return "arc_father_03_hospital"
    if t == 93 \
            and not father_is_passed \
            and f.get("arc_father_03_seen") \
            and S.get_cast_affinity("sangchul") >= 65 \
            and f.get("arc_sangchul_human_seen") \
            and not f.get("sangchul_truth_known") \
            and not f.get("arc_sangchul_mirror_seen"):
        return "arc_sangchul_mirror"
    if 94 <= t <= 95 \
            and f.get("arc_sangchul_mirror_seen") \
            and not f.get("arc_sangchul_mirror_receipt_seen") \
            and not f.get("sangchul_mirror_hospital_face_up") \
            and not f.get("sangchul_mirror_deal_face_up"):
        return "arc_sangchul_mirror_receipt"
    if 94 <= t <= 95 \
            and f.get("arc_sangchul_mirror_seen") \
            and not S.current_job.is_empty() \
            and S.job_tenure >= 6 \
            and not f.get("arc_career_ceiling_seen"):
        return "arc_career_ceiling"
    if t == 95 \
            and f.get("daeun_chose_her") \
            and not f.get("daeun_let_her_go") \
            and not f.get("arc_daeun_money_gap_seen"):
        return "arc_daeun_money_gap"
    if t == 96:
        if not father_is_passed \
                and f.get("arc_father_03_seen") \
                and not f.get("visited_father") \
                and not f.get("father_visit_deferred"):
            return "arc_father_04_visit"
        if not f.get("arc_year2_close_seen"):
            return "arc_year2_close"
    if t == 132 \
            and f.get("arc_sangchul_confrontation_seen") \
            and f.get("sangchul_confronted") \
            and not f.get("arc_sangchul_reckoning_seen") \
            and not f.get("sangchul_truth_buried") \
            and not f.get("sangchul_quietly_distanced"):
        return "arc_sangchul_reckoning"
    if t == 132 \
            and f.get("sangchul_truth_known") \
            and not f.get("sangchul_confronted") \
            and not f.get("sangchul_truth_buried") \
            and not f.get("sangchul_quietly_distanced") \
            and not f.get("arc_sangchul_reckoning_seen") \
            and not f.get("arc_sangchul_confrontation_seen"):
        if S.has_item("artifact_sangchul_card") \
                and not f.get("arc_sangchul_card_at_confrontation_seen"):
            return "arc_sangchul_card_at_confrontation"
        return "arc_sangchul_confrontation"
    if 133 <= t <= 136 \
            and (f.get("arc_sangchul_reckoning_seen") \
                 or f.get("sangchul_truth_buried") \
                 or f.get("sangchul_quietly_distanced")) \
            and not f.get("arc_y3_cost_of_knowing_seen"):
        return "arc_y3_cost_of_knowing"
    return ""


def chapter_four_causal_event(S):
    """Mirror MainGame's exact W153-W190 Chapter 4 product router."""
    t = S.t
    f = S.flags
    if t == 153 and not father_death_is_monotonic(S) \
            and not f.get("arc_y4_three_promises_seen"):
        return chapter_four_relationship_event(
            S, "arc_y4_three_promises",
            "arc_y4_three_promises_jiyeon_and_deal",
            "arc_y4_three_promises_deal_only")
    if t == 157 and f.get("arc_y4_three_promises_seen") \
            and not f.get("arc_36_unexpected_hand_seen"):
        missed_father = bool(f.get("arc_y4_three_promises_missed_father"))
        missed_person = bool(f.get("arc_y4_three_promises_missed_person"))
        missed_deal = bool(f.get("arc_y4_three_promises_missed_deal"))
        if sum((missed_father, missed_person, missed_deal)) != 2:
            return ""
        if father_death_is_monotonic(S) and missed_father:
            return ""
        if missed_father and missed_deal:
            return "arc_36_unexpected_hand_father_deal"
        if missed_person and missed_deal:
            return "arc_36_unexpected_hand_person_deal"
        return "arc_36_unexpected_hand"
    if t == 161 and not f.get("arc_36_body_signal_seen"):
        return "arc_36_body_signal"
    if t == 164 and f.get("arc_36_body_signal_seen") \
            and not f.get("arc_y4_body_witness_seen"):
        return chapter_four_relationship_event(
            S, "arc_y4_body_witness", "arc_y4_body_witness_jiyeon",
            "arc_y4_body_witness_hyunsu")
    if t == 167 and not father_death_is_monotonic(S) \
            and f.get("arc_y4_body_witness_seen") \
            and not f.get("arc_y4_family_table_seen"):
        unattached_id = "arc_y4_family_commitment_none"
        if f.get("arc_y4_three_promises_missed_father"):
            unattached_id = "arc_y4_family_table_missed"
        return chapter_four_relationship_event(
            S, "arc_y4_family_partner_collision",
            "arc_y4_family_partner_collision_jiyeon", unattached_id)
    if t == 169 and f.get("arc_y4_family_table_seen") \
            and not f.get("arc_year_three_half_seen"):
        return "arc_year_three_half"
    if t == 174 and f.get("arc_father_03_seen") \
            and f.get("arc_father_medication_seen") \
            and not father_death_is_monotonic(S) \
            and not f.get("arc_father_call_on_ktx_seen"):
        if S.has_item("artifact_father_call"):
            return "arc_father_call_on_ktx"
        return "arc_father_call_on_ktx_number"
    if t == 177 and not f.get("arc_y4_borrowed_name_seen"):
        unattached_id = "arc_y4_borrowed_name_self"
        if f.get("arc_y4_three_promises_missed_deal"):
            unattached_id = "arc_y4_borrowed_name_document_gap"
        return chapter_four_relationship_event(
            S, "arc_y4_borrowed_name", "arc_y4_borrowed_name_jiyeon",
            unattached_id)
    if t == 181 and not father_death_is_monotonic(S) \
            and not f.get("arc_y4_bill_night_seen"):
        return chapter_four_relationship_event(
            S, "arc_y4_bill_night", "arc_y4_bill_night_jiyeon",
            "arc_y4_bill_night_unattached")
    if t == 185 and f.get("arc_y4_bill_night_seen") \
            and not father_death_is_monotonic(S) \
            and not f.get("arc_y4_father_crisis_contact_seen"):
        return "arc_y4_father_crisis_contact"
    if t == 188:
        return chapter_four_father_outcome(S)
    if t == 190 and not f.get("arc_y4_year_close_boundary_seen"):
        return chapter_four_relationship_event(
            S, "arc_y4_year_close_daeun", "arc_y4_year_close_jiyeon",
            "arc_y4_year_close_unattached")
    return ""


def story_mode_root_queue(S, event_ids):
    """Model MainGame's same-StoryMode-root handoff at protected boundaries."""
    story_queue = list(event_ids)
    first_event_id = story_queue[0] if story_queue else ""
    if S.t == 96 and first_event_id == "arc_father_04_visit" \
            and not S.flags.get("arc_year2_close_seen"):
        story_queue.append("arc_year2_close")
    if W193_STORY_HANDOFF_SOURCE_OK \
            and S.t == 193 \
            and first_event_id == "chapter_card_37":
        reckoning_claim = S.claim_deferred_event("arc_37_reckoning", 193)
        if reckoning_claim:
            story_queue.append("arc_37_reckoning")
    return story_queue


def run(spine, traj, cast_flag_hook, choice_indices):
    S = State(); fired = {}; firelog = {}; repeats = {}; bridge_log = {}
    story_queue_log = {}
    for t in range(1, 241):
        S.t = t; traj(S); cast_flag_hook(S)
        protected_chapter_four_action = False
        protected_story_graph_action = False
        protected_chapter_five_action = False
        protected_chapter_five_finale_action = False
        # MainGame protects the exact Year 4 close and causal actions before
        # the deferred queue. Model that priority instead of allowing an old
        # callback to consume a commitment week.
        chosen = ""
        if t == 193 and S.age == 37 \
                and not S.flags.get("chapter_37_seen"):
            # _next_arc_id gives the chapter card priority over ready deferred
            # roots. The W193 handoff must therefore happen inside the same
            # StoryMode queue or reckoning slips to Week 194.
            chosen = "chapter_card_37"
        elif t in (48, 144, 192) \
                and not S.flags.get(f"arc_year{t // 48}_close_seen"):
            # Exact year closes sit above the deferred foreground queue in
            # _next_arc_id. ORDER-143's M34 echo may become ready at W144,
            # but it cannot replace the canonical boundary.
            chosen = f"arc_year{t // 48}_close"
        else:
            chosen = chapter5_causal_event(S)
            protected_chapter_five_action = bool(chosen)
            if not chosen:
                chosen = chapter5_finale_event(S)
                protected_chapter_five_finale_action = bool(chosen)
            if not chosen:
                # _next_arc_id() gives this exact fallback top priority, but
                # typed Chapter 5 owns W240 before the generic router is asked.
                chosen = generic_finale_event(S)
            if not chosen:
                chosen = story_graph_contract_event(S)
                protected_story_graph_action = bool(chosen)
            if not chosen:
                chosen = chapter_four_causal_event(S)
                protected_chapter_four_action = bool(chosen)
            if not chosen:
                chosen = old_jaehyuk_mirror_event(S)
        if not chosen:
            chosen = S.pop_ready_deferred_event()
        if not chosen:
            for eid, conds in triggers:
                if eid == "arc_jaehyuk_mirror":
                    # The singular mirror is manually modeled above because its
                    # W209 relocation uses a local GDScript min-turn variable.
                    continue
                if evalconds(conds, S):
                    if eid in BRIDGE_EVENTS:
                        apply_bridge_choice(S, eid, choice_indices)
                        bridge_log.setdefault(t, []).append(eid)
                        continue
                    chosen = eid; break
        if chosen:
            story_roots = story_mode_root_queue(S, [chosen])
            story_queue_log[t] = story_roots
            for root_id in story_roots:
                if root_id in fired:
                    repeats[root_id] = repeats.get(root_id, 1) + 1
                fired[root_id] = t
                firelog[t] = root_id
                for fl in own_seen_flags(root_id): S.flags[fl] = True
                for fl in spine.get(root_id, []): S.flags[fl] = True
                if protected_story_graph_action and root_id == chosen:
                    apply_immediate_choice_state(S, root_id, choice_indices)
                if protected_chapter_four_action and root_id == chosen:
                    apply_immediate_choice_state(S, root_id, choice_indices)
                if protected_chapter_five_action \
                        and root_id in CHAPTER5_ROOT_IDS:
                    if not commit_chapter5_choice(
                            S, root_id, choice_indices):
                        repeats["chapter5_commit_rejected"] = \
                            repeats.get("chapter5_commit_rejected", 0) + 1
                    same_turn_root = chapter5_causal_event(S)
                    if same_turn_root and same_turn_root not in story_roots:
                        story_roots.append(same_turn_root)
                if protected_chapter_five_finale_action \
                        and root_id in CHAPTER5_FINALE_ROOT_IDS:
                    if not commit_chapter5_finale_choice(
                            S, root_id, choice_indices):
                        repeats["chapter5_finale_commit_rejected"] = \
                            repeats.get(
                                "chapter5_finale_commit_rejected", 0) + 1
                    same_turn_root = chapter5_finale_event(S)
                    if same_turn_root and same_turn_root not in story_roots:
                        story_roots.append(same_turn_root)
                for deferred_id, delay in canonical_deferred_links(
                        root_id, choice_indices):
                    S.add_deferred_event(deferred_id, delay)
            if protected_chapter_five_finale_action \
                    and S.chapter5_finale_ending_check == "ready" \
                    and not chapter5_finale_next_root(S):
                S.chapter5_finale_ending_check = "consumed"
                S.chapter5_finale_release_count += 1
    return fired, firelog, repeats, S, bridge_log, story_queue_log


def hookA(S):
    if S.flags.get("jaehyuk_trusted_fully"):
        S.cast["jaehyuk"].setdefault("flags", set()).add("invested")


def hookB(S):
    if S.flags.get("jaehyuk_suspected"):
        S.cast["jaehyuk"].setdefault("flags", set()).add("suspected")


YEARS = {1: (1, 48), 2: (49, 96), 3: (97, 144), 4: (145, 192), 5: (193, 240)}
PATHS = [
    ("A 정석/다은보냄/사기", PATH_A, traj_A, hookA, {
        "arc_jaehyuk_03_pitch": 0,
        "arc_daeun_03_fork": 1,
        "arc_father_04_visit": 3,
        "hyunsu_study_together": 1,
        "hyunsu_result_fail": 0,
        "arc_hyunsu_exam_fail": 0,
        "arc_hyunsu_drift": 1,
    }),
    ("B 비정석/진실/committed", PATH_B, traj_B, hookB, {
        "arc_jaehyuk_03_pitch": 2,
        "arc_daeun_03_fork": 0,
        "arc_father_04_visit": 0,
        "arc_sangchul_reckoning": 2,
        "hyunsu_study_together": 1,
        "hyunsu_result_fail": 0,
        "arc_hyunsu_exam_fail": 2,
        "arc_hyunsu_drift": 2,
    }),
]
# 경로별 완결돼야 하는 대표 체인
CHAINS = {
    "A 정석/다은보냄/사기": [
        "arc_y1_new_room_first_month", "arc_year_one_mark",
        "arc_sangchul_03_network", "arc_father_medication",
        "arc_34_doors_open", "arc_daeun_03_fork",
        "arc_34_parents_visit", "arc_father_04_visit",
        "arc_sangchul_mirror", "arc_career_ceiling",
        "arc_daeun_ghost", "arc_jaehyuk_04c_stand_up", "arc_36_trust_crack",
        "arc_father_call_on_ktx", "arc_father_passing", "arc_father_legacy",
        "arc_final_countdown",
    ],
    "B 비정석/진실/committed": [
        "arc_y1_new_room_first_month", "arc_year_one_mark",
        "arc_sangchul_03_network", "arc_father_medication",
        "arc_34_doors_open", "arc_daeun_03_fork",
        "arc_34_parents_visit", "arc_father_04_visit",
        "arc_sangchul_mirror", "arc_career_ceiling",
        "arc_daeun_money_gap", "arc_sangchul_confrontation",
        "arc_y3_cost_of_knowing", "arc_daeun_proposal",
        "arc_daeun_wedding_day", "arc_daeun_final_choice", "arc_36_trust_crack",
        "arc_father_passing", "arc_y5_father_trace_passed_exact",
        "arc_y5_father_trace_custody", "arc_y5_name_on_line_daeun_routed",
        "arc_y5_people_verdict_daeun_exact",
        "arc_y5_property_not_executed_notice",
        "arc_y5_remaining_jaehyuk_or_self",
        "arc_y5_final_father_answer_passed",
        "arc_final_countdown_property_not_executed",
        "arc_y5_final_week_daeun_outbound",
    ],
}
REQUIRED_FLAGS = {
    "A 정석/다은보냄/사기": [
        "arc_sangchul_03_seen", "arc_father_03_seen",
        "father_visit_deferred", "arc_36_unexpected_hand_seen", "arc_final_week_seen",
        "arc_final_year_start_seen",
    ],
    "B 비정석/진실/committed": [
        "arc_sangchul_03_seen", "arc_father_03_seen",
        "visited_father", "arc_36_unexpected_hand_seen", "arc_final_week_seen",
        "arc_final_year_start_seen",
    ],
}
EXPECTED_YEAR_CLOSES = {
    "arc_year1_close": 48,
    "arc_year2_close": 96,
    "arc_year3_close": 144,
    "arc_year4_close": 192,
}
EXPECTED_LATE_TEMPORAL = {
    "A 정석/다은보냄/사기": {
        69: "arc_year_one_half",
        87: "arc_34_two_years_in",
        148: "arc_35_path_cost",
        151: "arc_35_habit_check",
        152: "arc_almost_there",
        154: "arc_36_reality_check",
        156: "arc_1b_isolation",
        180: "arc_36_night_doubt",
        192: "arc_year4_close",
        191: "arc_final_stretch",
        193: "arc_37_reckoning",
    },
    "B 비정석/진실/committed": {
        # M22 is Daeun-owned on this route; Jiyeon's old offer no longer
        # occupies the early chapter-two foreground.
        69: "arc_year_one_half",
        87: "arc_34_two_years_in",
        148: "arc_35_path_cost",
        151: "arc_35_habit_check",
        154: "arc_almost_there",
        156: "arc_daeun_our_home",
        159: "arc_36_reality_check",
        158: "arc_1b_isolation",
        180: "arc_36_night_doubt",
        192: "arc_year4_close",
        191: "arc_final_stretch",
        193: "arc_37_reckoning",
    },
}
EXPECTED_CHAPTER4_CAUSAL = {
    "A 정석/다은보냄/사기": {
        153: "arc_y4_three_promises_deal_only",
        157: "arc_36_unexpected_hand_person_deal",
        161: "arc_36_body_signal",
        164: "arc_y4_body_witness_hyunsu",
        167: "arc_y4_family_commitment_none",
        169: "arc_year_three_half",
        174: "arc_father_call_on_ktx",
        177: "arc_y4_borrowed_name_document_gap",
        181: "arc_y4_bill_night_unattached",
        185: "arc_y4_father_crisis_contact",
        188: "arc_father_passing",
        190: "arc_y4_year_close_unattached",
        192: "arc_year4_close",
    },
    "B 비정석/진실/committed": {
        153: "arc_y4_three_promises",
        157: "arc_36_unexpected_hand_person_deal",
        161: "arc_36_body_signal",
        164: "arc_y4_body_witness",
        167: "arc_y4_family_partner_collision",
        169: "arc_year_three_half",
        174: "arc_father_call_on_ktx_number",
        177: "arc_y4_borrowed_name",
        181: "arc_y4_bill_night",
        185: "arc_y4_father_crisis_contact",
        188: "arc_father_passing",
        190: "arc_y4_year_close_daeun",
        192: "arc_year4_close",
    },
}
EXPECTED_CHAPTER5_CAUSAL = {
    "A 정석/다은보냄/사기": {},
    "B 비정석/진실/committed": {
        str(root["event_id"]): int(root["turn"])
        for root in CHAPTER5_ROOTS
    },
}
EXPECTED_CHAPTER5_FINALE = {
    "A 정석/다은보냄/사기": {},
    "B 비정석/진실/committed": {
        str(root["event_id"]): int(root["turn"])
        for root in CHAPTER5_FINALE_ROOTS
        if root.get("active_when") is None
        or root.get("active_when", {}).get("equals") == "passed"
    },
}
EXPECTED_CHAPTER2_COMPARISON = {
    "A 정석/다은보냄/사기": {
        92: "arc_social_comparison",
        105: "arc_year_two_pressure",
    },
    "B 비정석/진실/committed": {
        92: "arc_social_comparison",
        106: "arc_year_two_pressure",
    },
}
EXPECTED_CHAPTER3 = {
    "A 정석/다은보냄/사기": {
        100: "arc_opp_jiyeon_bunyang",
        101: "arc_35_birthday",
        104: "arc_jaehyuk_03_pitch",
        106: "arc_jaehyuk_wait",
        108: "arc_jaehyuk_hyunsu_warning",
        109: "arc_35_orthodox_weight",
        112: "callback_jiyeon_took_deal_consequence",
        115: "arc_why_gangnam_real",
        116: "arc_jaehyuk_04a_ghost",
        117: "arc_jaehyuk_aftermath",
        118: "arc_jaehyuk_mirror",
        121: "arc_midpoint_reckoning",
        122: "arc_year_two_half",
        126: "arc_goal_vertigo",
        130: "arc_minjun_first_call",
        144: "arc_year3_close",
    },
    "B 비정석/진실/committed": {
        100: "arc_father_05_after_visit",
        101: "arc_35_birthday",
        102: "arc_daeun_year3_together",
        104: "arc_sangchul_deduction",
        105: "arc_jaehyuk_03_pitch",
        106: "arc_year_two_pressure",
        108: "arc_35_unorthodox_weight",
        112: "arc_father_06_confession",
        113: "arc_sangchul_known_offer",
        115: "arc_why_gangnam_real",
        117: "arc_jaehyuk_04b_counter",
        118: "arc_jaehyuk_aftermath",
        120: "arc_sangchul_known_reflex",
        121: "arc_midpoint_reckoning",
        122: "arc_year_two_half",
        124: "callback_father_confession_echo",
        125: "arc_jaehyuk_sangchul_echo",
        126: "arc_goal_vertigo",
        128: "arc_y3_sangchul_deeper_room",
        130: "arc_minjun_first_call",
        132: "arc_sangchul_confrontation",
        133: "arc_y3_cost_of_knowing",
        134: "arc_sangchul_year3",
        144: "arc_year3_close",
    },
}

EXPECTED_CHAPTER1 = {
    "A 정석/다은보냄/사기": {
        2: "arc_intro_01_meal",
        4: "arc_temptation_01",
        5: "arc_intro_03_sns",
        8: "arc_temptation_clean",
        9: "arc_intro_04_hyunsu",
        10: "arc_sangchul_01_meet",
        11: "hyunsu_study_together",
        12: "arc_daeun_01_meet",
        14: "arc_father_01_call",
        15: "arc_invest_first_loss",
        16: "arc_father_quiet_call",
        17: "arc_jiyeon_01_crash",
        19: "arc_jaehyuk_01_reunion",
        20: "arc_hyunsu_night_talk",
        21: "arc_father_02_signal",
        22: "arc_gangnam_visit_alone",
        24: "hyunsu_exam_day",
        25: "hyunsu_result_fail",
        28: "callback_investment_lesson_echo",
        29: "arc_hyunsu_exam_fail",
        30: "arc_goshiwon_goodbye",
        31: "arc_sangchul_02_coffee",
        32: "arc_first_real_win",
        34: "arc_hyunsu_drift",
        35: "arc_daeun_02_regular",
        36: "arc_jiyeon_02_store",
        37: "arc_y1_new_room_first_month",
        40: "arc_hyunsu_new_path",
        41: "arc_opp_sangchul_realty",
        47: "callback_daeun_supportive_warmth",
        48: "arc_year1_close",
    },
    "B 비정석/진실/committed": {
        2: "arc_intro_01_meal",
        4: "arc_temptation_01",
        5: "arc_intro_03_sns",
        8: "arc_temptation_fallout",
        9: "arc_intro_04_hyunsu",
        10: "arc_ch1_invest_first_chart",
        11: "arc_sangchul_01_meet",
        12: "arc_daeun_01_meet",
        13: "hyunsu_study_together",
        14: "arc_father_01_call",
        15: "arc_invest_first_loss",
        16: "arc_father_quiet_call",
        17: "arc_jiyeon_01_crash",
        19: "arc_jaehyuk_01_reunion",
        20: "arc_hyunsu_night_talk",
        21: "arc_father_02_signal",
        22: "arc_gangnam_visit_alone",
        24: "callback_escaped_dirty_trace",
        25: "hyunsu_exam_day",
        26: "hyunsu_result_fail",
        28: "callback_investment_lesson_echo",
        29: "arc_goshiwon_goodbye",
        30: "arc_hyunsu_exam_fail",
        31: "arc_sangchul_02_coffee",
        32: "arc_first_real_win",
        34: "arc_daeun_02_regular",
        35: "arc_hyunsu_drift",
        36: "arc_jiyeon_02_store",
        37: "arc_y1_new_room_first_month",
        40: "arc_opp_sangchul_realty",
        41: "arc_hyunsu_new_path",
        45: "arc_money_loneliness",
        46: "callback_daeun_supportive_warmth",
        47: "arc_opp_jiyeon_bunyang",
        48: "arc_year1_close",
    },
}

EXPECTED_CHAPTER1_BRIDGES = {
    11: ["arc_gosiwon_wall"],
    12: ["arc_invest_guidance"],
    13: ["arc_night_routine"],
    15: ["arc_paycheck_reality"],
}

EXPECTED_T1_DELAYED_PAYOFFS = {
    "A 정석/다은보냄/사기": {
        "callback_investment_lesson_echo": 28,
        "callback_daeun_supportive_warmth": 47,
        "callback_rushed_to_father_echo": 103,
        "callback_jiyeon_took_deal_consequence": 112,
    },
    "B 비정석/진실/committed": {
        "callback_escaped_dirty_trace": 24,
        "callback_investment_lesson_echo": 28,
        "callback_daeun_supportive_warmth": 46,
        "callback_jiyeon_took_deal_consequence": 59,
        "callback_rushed_to_father_echo": 103,
        "callback_father_confession_echo": 124,
        "callback_used_sangchul_after_echo": 143,
        "callback_daeun_gangnam_first_echo": 155,
    },
}

T1_DELAYED_PAYOFF_IDS = {
    "callback_hoesik_left_early_office",
    "callback_hoesik_caved_reputation",
    "callback_daeun_supportive_warmth",
    "callback_investment_lesson_echo",
    "callback_escaped_dirty_trace",
    "callback_cafe_stole_gambled_result",
    "callback_told_daeun_everything_echo",
    "callback_told_daeun_investing_echo",
    "callback_sent_money_instead_echo",
    "callback_rushed_to_father_echo",
    "callback_medication_visited_echo",
    "callback_medication_ignored_echo",
    "callback_jiyeon_honest_referral",
    "callback_jiyeon_together_pressure",
    "callback_jiyeon_took_deal_consequence",
    "callback_declined_sangchul_deal_echo",
    "callback_shadow_investors_proposal",
    "callback_hyunsu_departure_meal_echo",
    "callback_daeun_deferred_silence",
    "callback_daeun_breakup_begged_echo",
    "callback_daeun_daily_life_echo",
    "callback_daeun_married_echo",
    "callback_father_confession_echo",
    "callback_sangchul_truth_buried_echo",
    "callback_jiyeon_busan_postcard",
    "callback_daeun_gangnam_first_echo",
    "callback_chose_money_father_echo",
    "callback_used_sangchul_after_echo",
    "callback_daeun_committed_gangnam_eve",
}

CAPPED_ARC_WINDOWS = {
    "arc_36_body_signal": (161, 161),
    "arc_year_three_half": (169, 169),
    "arc_36_night_doubt": (180, 187),
    # M22's Daeun-owned route moves this first concrete money cost to M24.
    "arc_daeun_money_gap": (95, 95),
    "arc_endgame_sixmonths": (216, 237),
}

EXPECTED_CAPPED_ARCS = {
    "A 정석/다은보냄/사기": {
        "arc_36_body_signal",
        "arc_year_three_half",
        "arc_36_night_doubt",
        "arc_endgame_sixmonths",
    },
    # The 19-root causal ledger owns W216-W220 and the safe finale locks W221.
    # Its nine exact final roots replace the generic six-month montage here.
    "B 비정석/진실/committed": set(CAPPED_ARC_WINDOWS) - {
        "arc_endgame_sixmonths",
    },
}

HYUNSU_CHAPTER1_SEQUENCE = [
    "arc_intro_04_hyunsu",
    "hyunsu_study_together",
    "hyunsu_exam_day",
    "hyunsu_result_fail",
    "arc_hyunsu_exam_fail",
    "arc_hyunsu_drift",
    "arc_hyunsu_new_path",
]

HYUNSU_TEMPORAL_GATES = {
    "hyunsu_exam_day": 24,
    "hyunsu_result_pass": 25,
    "hyunsu_result_fail": 25,
}

fail = 0


if not GENERIC_FINALE_SOURCE_OK or not GENERIC_FINALE_FOLLOW_UP_OK:
    fail += 1
    print(
        "  ✗ generic finale source/data contract="
        "exact W240·typed lock·countdown→final-week"
    )
else:
    print(
        "  ✓ generic finale source/data contract="
        "exact W240·typed lock·countdown→final-week"
    )

generic_finale_cases = []
for label, turn, flags, expected in (
        ("W239 blocked", 239, {}, ""),
        ("W240 fresh countdown", 240, {}, "arc_final_countdown"),
        ("W240 interrupted follow-up", 240,
         {"arc_final_countdown_seen": True}, "arc_final_week"),
        ("W240 complete", 240, {
            "arc_final_countdown_seen": True,
            "arc_final_week_seen": True,
        }, ""),
        ("W241 blocked", 241, {}, "")):
    fixture = State()
    fixture.t = turn
    fixture.flags.update(flags)
    generic_finale_cases.append(
        (label, generic_finale_event(fixture), expected))
typed_lock_fixture = State()
typed_lock_fixture.t = 240
typed_lock_fixture.chapter5_finale_entry = {"route_id": "typed_fixture"}
generic_finale_cases.append((
    "W240 typed lock",
    generic_finale_event(typed_lock_fixture),
    "",
))
generic_finale_failures = [
    f"{label}:{actual!r}!={expected!r}"
    for label, actual, expected in generic_finale_cases
    if actual != expected
]
if generic_finale_failures:
    fail += 1
    print("  ✗ generic finale boundary matrix:",
          ", ".join(generic_finale_failures))
else:
    print("  ✓ generic finale boundary matrix=6 cases W239/W240/W241+typed lock")


def graph_contract_fixture(turn, flags=None, *, nav=2_000_000,
                           housing="oneroom", employed=True,
                           daeun_affinity=20, sangchul_affinity=70,
                           items=()):
    state = State()
    state.t = turn
    state.nav = nav
    state.housing = housing
    state.job_tenure = 12
    if employed:
        state.current_job = Job(id="job_01", category="survival")
    state.cast["daeun"]["aff"] = daeun_affinity
    state.cast["sangchul"]["aff"] = sangchul_affinity
    state.flags.update(flags or {})
    state.items.update(items)
    return state


# ORDER-143 counterexamples exercise the typed selector itself. They are kept
# separate from the two long representative paths so one false prerequisite is
# isolated at a time instead of being hidden by a later foreground collision.
story_graph_cases = []

state = graph_contract_fixture(32, {
    "arc_goshiwon_goodbye_seen": True,
})
story_graph_cases.append(("M08 interrupted move closure", state,
                          "arc_housing_new_life"))

state = graph_contract_fixture(120, {
    "arc_goshiwon_goodbye_seen": True,
})
story_graph_cases.append(("dynamic late-move closure recovery", state,
                          "arc_housing_new_life"))

state = graph_contract_fixture(37, {
    "arc_housing_new_life_seen": True,
})
story_graph_cases.append(("M10 first-month cost", state,
                          "arc_y1_new_room_first_month"))

state = graph_contract_fixture(52, {
    "arc_year_one_mark_seen": True,
    "arc_34_money_attracts_seen": True,
}, nav=0)
story_graph_cases.append(("W52 network prelaunch blocked", state, ""))

state = graph_contract_fixture(53, {
    "arc_year_one_mark_seen": True,
    "arc_34_money_attracts_seen": True,
}, nav=0)
story_graph_cases.append(("M14 ineligible bank fallback", state,
                          "arc_y2_bank_limit_review"))

state = graph_contract_fixture(53, {
    "arc_year_one_mark_seen": True,
    "arc_34_money_attracts_seen": True,
    "arc_sangchul_02_seen": True,
})
story_graph_cases.append(("M14 eligible network", state,
                          "arc_sangchul_03_network"))

state = graph_contract_fixture(74, {
    "arc_father_02_done": True,
    "arc_father_medication_seen": True,
})
story_graph_cases.append(("W74 doors and parents blocked", state, ""))

state = graph_contract_fixture(77, {
    "arc_34_doors_open_seen": True,
    "arc_father_02_done": True,
    "arc_father_medication_seen": True,
})
story_graph_cases.append(("W77 parents blocked after doors", state, ""))

state = graph_contract_fixture(82, {
    "arc_father_02_done": True,
    "arc_father_medication_seen": True,
})
story_graph_cases.append(("W82 normal hospital prefire blocked", state, ""))

state = graph_contract_fixture(82, {
    "arc_father_02_done": True,
    "arc_father_medication_seen": True,
    "arc_34_parents_visit_seen": True,
})
story_graph_cases.append(("W82 damaged-save hospital recovery", state,
                          "arc_father_03_hospital"))

state = graph_contract_fixture(58, {
    "arc_father_02_done": True,
    "arc_jiyeon_store_seen": True,
})
story_graph_cases.append(("W58 medication owns foreground", state,
                          "arc_father_medication"))
state = graph_contract_fixture(58, {
    "arc_father_02_done": True,
    "arc_father_medication_seen": True,
    "arc_jiyeon_store_seen": True,
})
story_graph_cases.append(("W58 medication cannot summon Jiyeon", state, ""))

state = graph_contract_fixture(85, {
    "arc_father_02_done": True,
    "arc_father_medication_seen": True,
    "arc_daeun_regular_seen": True,
})
story_graph_cases.append(("W85 Daeun without medication replay", state,
                          "arc_daeun_03_fork"))

state = graph_contract_fixture(86, {
    "arc_daeun_fork_seen": True,
    "daeun_chose_her": True,
})
story_graph_cases.append(("M22 interrupted Daeun hold receipt", state,
                          "arc_daeun_03_fork_hold_receipt"))

state = graph_contract_fixture(86, {
    "arc_daeun_fork_seen": True,
    "daeun_let_her_go": True,
})
story_graph_cases.append(("M22 interrupted Daeun release receipt", state,
                          "arc_daeun_03_fork_release_receipt"))

state = graph_contract_fixture(86, {
    "daeun_chose_her": True,
})
story_graph_cases.append(("M22 branch-only corruption stays closed", state, ""))

state = graph_contract_fixture(86, {
    "arc_daeun_fork_seen": True,
    "daeun_chose_her": True,
    "arc_daeun_fork_receipt_seen": True,
})
story_graph_cases.append(("M22 completed Daeun receipt stays closed", state, ""))

state = graph_contract_fixture(85, {
    "arc_father_02_done": True,
    "arc_father_medication_seen": True,
    "arc_jiyeon_store_seen": True,
}, daeun_affinity=0)
story_graph_cases.append(("W85 Jiyeon route fallback", state,
                          "arc_jiyeon_03_offer"))

state = graph_contract_fixture(85, {
    "arc_father_02_done": True,
    "arc_father_medication_seen": True,
}, daeun_affinity=0)
story_graph_cases.append(("W85 unattached fallback", state,
                          "arc_y2_relationship_fork_unattached"))

state = graph_contract_fixture(89, {
    "arc_father_02_done": True,
    "arc_father_medication_seen": True,
})
story_graph_cases.append(("W89 normal parents visit", state,
                          "arc_34_parents_visit"))

state = graph_contract_fixture(90, {
    "arc_father_02_done": True,
    "arc_father_medication_seen": True,
    "arc_34_parents_visit_seen": True,
})
story_graph_cases.append(("M23 interrupted chain recovers hospital first", state,
                          "arc_father_03_hospital"))
state = graph_contract_fixture(90, {
    "arc_father_02_done": True,
    "arc_father_medication_seen": True,
    "arc_34_parents_visit_seen": True,
    "arc_father_03_seen": True,
})
story_graph_cases.append(("M23 hospital fact waits for canonical boss order", state, ""))

state = graph_contract_fixture(93, {
    "arc_father_03_seen": True,
    "arc_sangchul_human_seen": True,
}, sangchul_affinity=65)
story_graph_cases.append(("W93 mirror follows hospital fact", state,
                          "arc_sangchul_mirror"))

state = graph_contract_fixture(89, {
    "father_passed": True,
    "arc_father_02_done": True,
    "arc_father_medication_seen": True,
})
story_graph_cases.append(("passed father blocks family chain", state, ""))

state = graph_contract_fixture(94, {
    "arc_sangchul_mirror_seen": True,
}, employed=False)
story_graph_cases.append(("old mirror save recovers durable receipt", state,
                          "arc_sangchul_mirror_receipt"))

state = graph_contract_fixture(94, {
    "arc_sangchul_mirror_seen": True,
    "sangchul_mirror_hospital_face_up": True,
}, employed=False)
story_graph_cases.append(("unemployed career ceiling blocked", state, ""))

state = graph_contract_fixture(94, {
    "arc_sangchul_mirror_seen": True,
    "sangchul_mirror_hospital_face_up": True,
})
story_graph_cases.append(("employed career ceiling", state,
                          "arc_career_ceiling"))

state = graph_contract_fixture(95, {
    "daeun_chose_her": True,
    "arc_career_ceiling_seen": True,
})
story_graph_cases.append(("M24 Daeun money cost survives moved fork", state,
                          "arc_daeun_money_gap"))

state = graph_contract_fixture(96, {"arc_father_03_seen": True})
story_graph_cases.append(("W96 hospital door is Ch2 boss", state,
                          "arc_father_04_visit"))

state = graph_contract_fixture(132, {
    "sangchul_truth_known": True,
})
story_graph_cases.append(("M33 confrontation stays in owner week", state,
                          "arc_sangchul_confrontation"))

state = graph_contract_fixture(132, {
    "sangchul_truth_known": True,
}, items=("artifact_sangchul_card",))
story_graph_cases.append(("M33 optional card same-week prelude", state,
                          "arc_sangchul_card_at_confrontation"))

state = graph_contract_fixture(200, {
    "arc_37_reckoning_seen": True,
})
story_graph_cases.append(("late M49 closure recovery", state,
                          "arc_final_year_start"))

state = graph_contract_fixture(200)
story_graph_cases.append(("late M49 missing-source recovery", state,
                          "arc_37_reckoning"))

for terminal_index, terminal_flag in enumerate((
    "arc_sangchul_reckoning_seen",
    "sangchul_truth_buried",
    "sangchul_quietly_distanced",
)):
    state = graph_contract_fixture(133 + terminal_index, {terminal_flag: True})
    story_graph_cases.append((f"M34 aftermath accepts {terminal_flag}", state,
                              "arc_y3_cost_of_knowing"))

story_graph_failures = [
    f"{name}:{story_graph_contract_event(state)!r}!={expected!r}"
    for name, state, expected in story_graph_cases
    if story_graph_contract_event(state) != expected
]
if story_graph_failures:
    fail += 1
    print("  ✗ ORDER-143 typed selector 반례:", ", ".join(story_graph_failures))
else:
    print(f"  ✓ ORDER-143 typed selector 반례 {len(story_graph_cases)}개")

# Product-entry matrix: these are deliberately synthetic one-step states so each
# rejected prerequisite is isolated from the long representative trajectories.
eligible_entry = eligible_chapter5_fixture()
entry_matrix_ok = chapter5_product_path_available(eligible_entry)
for route_name in ("직장형", "창업형"):
    candidate = eligible_chapter5_fixture()
    candidate.player_route = route_name
    entry_matrix_ok = entry_matrix_ok and not chapter5_product_path_available(candidate)
candidate = eligible_chapter5_fixture()
candidate.flags.pop("route_invest")
entry_matrix_ok = entry_matrix_ok and not chapter5_product_path_available(candidate)
candidate = eligible_chapter5_fixture()
candidate.nav = 1_999_999_999
entry_matrix_ok = entry_matrix_ok and not chapter5_product_path_available(candidate)
for missing_flag in (
        "arc_sangchul_met_seen", "arc_daeun_met", "daeun_romance_started",
        "arc_minseo_02_seen", "arc_jaehyuk_reunion_seen",
        "arc_jaehyuk_aftermath_seen"):
    candidate = eligible_chapter5_fixture()
    candidate.flags.pop(missing_flag)
    entry_matrix_ok = entry_matrix_ok and not chapter5_product_path_available(candidate)
sent_away = eligible_chapter5_fixture()
sent_away.flags["daeun_let_her_go"] = True
entry_matrix_ok = entry_matrix_ok and not chapter5_product_path_available(sent_away)
if not entry_matrix_ok:
    fail += 1
    print("  ✗ 5장 투자형/20억/actual-participant 진입 행렬 회귀")
else:
    print("  ✓ 5장 entry 행렬=career/startup/<20억/미정체성/인물누락/다은보냄 거절")

sticky = eligible_chapter5_fixture()
sticky_started = chapter5_causal_event(sticky) == CHAPTER5_ROOT_IDS[0] \
    and sticky.chapter5_entry == CHAPTER5_ENTRY \
    and commit_chapter5_choice(sticky, CHAPTER5_ROOT_IDS[0], {})
sticky.t = 196
sticky.nav = 0
sticky.player_route = "직장형"
sticky.flags.pop("route_invest", None)
sticky.flags["daeun_let_her_go"] = True
sticky.flags["sangchul_cut_ties"] = True
sticky_continued = chapter5_product_path_available(sticky) \
    and chapter5_causal_event(sticky) == CHAPTER5_ROOT_IDS[1]
tampered_entry = eligible_chapter5_fixture()
tampered_entry.chapter5_entry = json.loads(json.dumps(CHAPTER5_ENTRY))
tampered_entry.chapter5_entry["economic_route"] = "career"
if not sticky_started or not sticky_continued \
        or chapter5_product_path_available(tampered_entry):
    fail += 1
    print("  ✗ durable entry lock/first-receipt continuation/tamper 회귀")
else:
    print("  ✓ durable entry=W195 actual context·외부조건 하락 후 sticky·tamper 거절")

fallback_matrix_ok = True
for failure_kind in ("assets", "sangchul", "minseo"):
    fallback = eligible_chapter5_fixture()
    if failure_kind == "assets":
        fallback.nav = 1_999_999_999
    elif failure_kind == "sangchul":
        fallback.flags.pop("arc_sangchul_met_seen")
    else:
        fallback.flags.pop("arc_minseo_02_seen")
    fallback.t = 208
    fallback_matrix_ok = fallback_matrix_ok \
        and chapter5_guarantee_relocation_reserved(fallback) \
        and not chapter5_product_path_available(fallback) \
        and old_jaehyuk_mirror_event(fallback) == ""
    fallback.t = 209
    fallback_matrix_ok = fallback_matrix_ok \
        and old_jaehyuk_mirror_event(fallback) == "arc_jaehyuk_mirror"
if not fallback_matrix_ok:
    fail += 1
    print("  ✗ 미진입 reserved candidate W209 old-mirror fallback 회귀")
else:
    print("  ✓ 미진입 fallback=<20억/상철누락/민서누락 W208 억제→W209 old mirror")

w212_choices = events.get(
    "arc_y5_jaehyuk_guarantee_decision_reference", {}).get("choices", [])
w212_exact = len(w212_choices) == 3 and all(
    choice.get("effects", {}) == expected["effects"]
    and choice.get("flags", []) == expected["flags"]
    for choice, expected in zip(w212_choices, W212_OUTCOMES)
)
if not w212_exact:
    fail += 1
    print("  ✗ W212 singular Jaehyuk mirror outcome semantics 회귀")
else:
    print("  ✓ W212=기존 singular mirror 3결과/effects/flags exact relocation")

minseo_duplicate_free = True
for post_lock_nav in (2_100_000_000, 1_900_000_000):
    locked_minseo = eligible_chapter5_fixture()
    chapter5_causal_event(locked_minseo)
    locked_minseo.t = 202
    locked_minseo.nav = post_lock_nav
    for event_id in ("arc_minseo_03_arrival", "arc_minseo_03b_not_arrived"):
        if any(evalconds(conditions, locked_minseo)
               for trigger_id, conditions in triggers if trigger_id == event_id):
            minseo_duplicate_free = False
if not minseo_duplicate_free:
    fail += 1
    print("  ✗ locked product route가 W202 generic Minseo arrival 변주를 중복 수신")
else:
    print("  ✓ locked product route=W202 Minseo generic arrival/not-arrived 중복 0")

if not W193_STORY_HANDOFF_SOURCE_OK:
    fail += 1
    print(
        "  ✗ W193 인계 소스 계약: chapter_card_37과 "
        "arc_37_reckoning이 같은 StoryMode 큐가 아님"
    )
else:
    print("  ✓ W193 인계 소스 계약=chapter_card_37→reckoning 같은 큐")

finale_inventory_ok = (
    CHAPTER5_FINALE_LEDGER.get("ledger_id")
    == "chapter5_m56_m60_safe_finale_v1"
    and int(CHAPTER5_FINALE_LEDGER.get("expected_root_count", -1)) == 11
    and int(CHAPTER5_FINALE_LEDGER.get("expected_choice_count", -1)) == 30
    and len(CHAPTER5_FINALE_ROOTS) == 11
    and sum(len(root.get("choices", []))
            for root in CHAPTER5_FINALE_ROOTS) == 30
)
for father_life in ("alive", "passed"):
    entry = {
        "father": {"life": father_life},
    }
    active_roots = [
        root for root in CHAPTER5_FINALE_ROOTS
        if chapter5_finale_root_active(root, entry)
    ]
    finale_inventory_ok = finale_inventory_ok \
        and len(active_roots) == 9 \
        and sum(len(root.get("choices", [])) for root in active_roots) == 24 \
        and sorted(set(int(root.get("turn", -1)) for root in active_roots)) \
        == [221, 224, 227, 230, 235, 238, 239, 240]
nontransaction_roots = [
    root for root in CHAPTER5_FINALE_ROOTS
    if root.get("stage") == "nontransaction"
]
finale_inventory_ok = finale_inventory_ok \
    and len(nontransaction_roots) == 1 \
    and all(
        choice.get("economic_outcome") == CHAPTER5_FINALE_NO_EXECUTION
        for choice in nontransaction_roots[0].get("choices", [])
    )
outbound_choices = events.get(
    "arc_y5_final_week_daeun_outbound", {}).get("choices", [])
finale_inventory_ok = finale_inventory_ok \
    and len(outbound_choices) == 3 \
    and all(choice.get("effects", {}) == {} for choice in outbound_choices) \
    and all(
        not {"final_week_self_approval", "final_week_gratitude"}
        & set(choice.get("flags", []))
        for choice in outbound_choices
    )
if not finale_inventory_ok:
    fail += 1
    print("  ✗ M56~M60 finale 11/30·active 9/24·no-execution inventory 회귀")
else:
    print("  ✓ M56~M60 finale=11루트/30선택·active 9/24·8 direct weeks·경제 실행 0")

if not CHAPTER5_FINALE_DIRECT_SOURCE_OK:
    fail += 1
    print("  ✗ M56~M60 direct StoryMode ingress/AP 비재질문/ending release 소스 계약")
else:
    print("  ✓ M56~M60 direct StoryMode ingress·AP 재질문 0·W240 canonical release")

alive_father_state = State()
damaged_father_states = []
damaged_father_routes = []
for evidence_kind in ("canonical_flag", "legacy_receipt", "cast_stage"):
    damaged = State()
    if evidence_kind == "canonical_flag":
        damaged.flags["father_passed"] = True
    elif evidence_kind == "legacy_receipt":
        damaged.flags["arc_father_passing_seen"] = True
    else:
        damaged.cast["father"]["stage"] = "passed"
    damaged_father_states.append(father_death_is_monotonic(damaged))
    damaged.flags.update({
        "arc_father_03_seen": True,
        "arc_father_medication_seen": True,
    })
    damaged.t = 153
    promises_blocked = chapter_four_causal_event(damaged) == ""
    damaged.flags.update({
        "arc_y4_three_promises_seen": True,
        "arc_y4_three_promises_missed_father": True,
        "arc_y4_three_promises_missed_deal": True,
    })
    damaged.t = 157
    father_repair_blocked = chapter_four_causal_event(damaged) == ""
    damaged.flags["arc_y4_body_witness_seen"] = True
    damaged.t = 167
    family_table_blocked = chapter_four_causal_event(damaged) == ""
    damaged.t = 174
    call_blocked = chapter_four_causal_event(damaged) == ""
    damaged.t = 181
    bill_night_blocked = chapter_four_causal_event(damaged) == ""
    damaged.flags["arc_y4_bill_night_seen"] = True
    damaged.t = 185
    crisis_blocked = chapter_four_causal_event(damaged) == ""
    damaged.t = 188
    outcome_blocked = chapter_four_causal_event(damaged) == ""
    damaged_father_routes.append(all((
        promises_blocked,
        father_repair_blocked,
        family_table_blocked,
        call_blocked,
        bill_night_blocked,
        crisis_blocked,
        outcome_blocked,
    )))
father_free_repair_state = State()
father_free_repair_state.t = 157
father_free_repair_state.flags.update({
    "father_passed": True,
    "arc_y4_three_promises_seen": True,
    "arc_y4_three_promises_missed_person": True,
    "arc_y4_three_promises_missed_deal": True,
})
father_free_repair_survives = chapter_four_causal_event(
    father_free_repair_state) == "arc_36_unexpected_hand_person_deal"
if father_death_is_monotonic(alive_father_state) \
        or not all(damaged_father_states) \
        or not all(damaged_father_routes) \
        or not father_free_repair_survives:
    fail += 1
    print("  ✗ 손상 저장 아버지 사망 증거 또는 호출 차단 누락")
else:
    print(
        "  ✓ 아버지 사망 단조 모델=정본·옛 영수증·cast stage"
        "·W153/W157/W167/W174/W181/W185/W188 재진입 차단"
        "·father-free M40 유지"
    )

job_invest_followups = {
    str(choice.get("follow_up_event", ""))
    for choice in events["arc_job_vs_invest"].get("choices", [])
}
if job_invest_followups != {"arc_hyunsu_night_talk"}:
    fail += 1
    print("  ✗ 현수 야간 거울이 직장-투자 선택 전부의 직접 후속이 아님")
else:
    print("  ✓ 현수 야간 거울=20주 직장-투자 선택의 직접 후속")
for event_id, minimum_week in HYUNSU_TEMPORAL_GATES.items():
    event_conditions = [
        " ".join(conditions)
        for trigger_id, conditions in triggers
        if trigger_id == event_id
    ]
    gate_pattern = re.compile(rf"\bt\s*>=\s*{minimum_week}\b")
    if not event_conditions or not any(gate_pattern.search(row) for row in event_conditions):
        fail += 1
        print(
            f"  ✗ 현수 시간 간격 회귀: {event_id}에 t>={minimum_week} 게이트가 없음"
        )
    else:
        print(f"  ✓ 현수 시간 게이트 {event_id}=t>={minimum_week}")

for name, spine, traj, hook, choice_indices in PATHS:
    fired, firelog, repeats, S, bridge_log, story_queue_log = run(
        spine, traj, hook, choice_indices)
    counts = {y: sum(1 for t in range(a, b + 1) if t in firelog) for y, (a, b) in YEARS.items()}
    print(f"\n=== Path {name} ===")
    print("  연차 authored 비트:", "  ".join(f"Y{y}={counts[y]}" for y in range(1, 6)))
    if repeats:
        fail += 1
        print("  ✗ 아크 잼:", ", ".join(f"{k}×{v}" for k, v in repeats.items()))
    else:
        print("  ✓ 아크 잼 없음")
    miss = [c for c in CHAINS[name] if c not in fired]
    if miss:
        fail += 1
        print("  ✗ 미완결 체인:", miss)
    else:
        print("  ✓ 대표 체인 완결")
    missing_flags = [flag for flag in REQUIRED_FLAGS[name] if not S.flags.get(flag)]
    if missing_flags:
        fail += 1
        print("  ✗ 후속 체인 플래그 누락:", missing_flags)
    else:
        print("  ✓ 즉시 후속 체인 플래그 완결")
    actual_year_closes = {
        event_id: fired.get(event_id)
        for event_id in EXPECTED_YEAR_CLOSES
    }
    if actual_year_closes != EXPECTED_YEAR_CLOSES:
        fail += 1
        print(
            "  ✗ 연말 결산 주차 회귀:",
            ", ".join(
                f"{event_id}@t{actual_year_closes.get(event_id, 'missing')}"
                f"!=t{expected_turn}"
                for event_id, expected_turn in EXPECTED_YEAR_CLOSES.items()
                if actual_year_closes.get(event_id) != expected_turn
            ),
        )
    else:
        print("  ✓ 연말 결산 W48/W96/W144/W192 정확 고정")
    expected_payoffs = EXPECTED_T1_DELAYED_PAYOFFS[name]
    actual_payoffs = {
        event_id: turn for event_id, turn in fired.items()
        if event_id in T1_DELAYED_PAYOFF_IDS
    }
    if actual_payoffs != expected_payoffs:
        fail += 1
        missing_payoffs = [
            f"{event_id}@t{actual_payoffs.get(event_id, 'missing')}!=t{turn}"
            for event_id, turn in expected_payoffs.items()
            if actual_payoffs.get(event_id) != turn
        ]
        unexpected_payoffs = [
            f"{event_id}@t{turn}"
            for event_id, turn in actual_payoffs.items()
            if event_id not in expected_payoffs
        ]
        print("  ✗ T1 지연 회수 시간축:", ", ".join(missing_payoffs + unexpected_payoffs))
    else:
        payoff_counts = {
            year: sum(
                1 for turn in actual_payoffs.values()
                if start <= turn <= end
            )
            for year, (start, end) in YEARS.items()
        }
        print(
            f"  ✓ T1 지연 회수 {len(actual_payoffs)}건·중복 0: "
            + " ".join(f"Y{year}={payoff_counts[year]}" for year in range(1, 6))
        )
    capped_errors = []
    for event_id in EXPECTED_CAPPED_ARCS[name]:
        start, end = CAPPED_ARC_WINDOWS[event_id]
        turn = fired.get(event_id)
        if turn is None:
            capped_errors.append(f"{event_id}=missing")
        elif not start <= turn <= end:
            capped_errors.append(f"{event_id}@t{turn} not in {start}..{end}")
    if capped_errors:
        fail += 1
        print("  ✗ 상한 아크 잠식:", ", ".join(capped_errors))
    else:
        print(f"  ✓ 상한 아크 {len(EXPECTED_CAPPED_ARCS[name])}종 윈도우 내 생존")
    chapter1_log = {turn: event_id for turn, event_id in firelog.items() if turn <= 48}
    if chapter1_log != EXPECTED_CHAPTER1[name]:
        fail += 1
        missing = [
            f"t{turn}:{chapter1_log.get(turn, 'missing')}!={event_id}"
            for turn, event_id in EXPECTED_CHAPTER1[name].items()
            if chapter1_log.get(turn) != event_id
        ]
        extras = [
            f"t{turn}:{event_id}"
            for turn, event_id in chapter1_log.items()
            if EXPECTED_CHAPTER1[name].get(turn) != event_id
        ]
        print("  ✗ 1장 전경 회귀:", ", ".join(missing + extras))
    else:
        print(
            f"  ✓ 1장 전경 {len(EXPECTED_CHAPTER1[name])}앵커 고정"
            "·생존직 20주 현수 대체 장면"
        )
    chapter1_bridges = {
        turn: bridge_ids for turn, bridge_ids in bridge_log.items() if turn <= 48
    }
    if chapter1_bridges != EXPECTED_CHAPTER1_BRIDGES:
        fail += 1
        print("  ✗ 1장 비차단 다리 회귀:", chapter1_bridges)
    else:
        print("  ✓ 1장 비차단 다리 4개 고정·생존직 사무실 장면 0")
    hyunsu_sequence = [
        event_id for _, event_id in sorted(chapter1_log.items())
        if event_id in HYUNSU_CHAPTER1_SEQUENCE
    ]
    if hyunsu_sequence != HYUNSU_CHAPTER1_SEQUENCE \
            or not S.flags.get("arc_hyunsu_night_seen") \
            or "hyunsu_pivot" in fired:
        fail += 1
        print("  ✗ 현수 1장 시간축 회귀:", hyunsu_sequence)
    elif not S.flags.get("arc_housing_new_life_seen"):
        fail += 1
        print("  ✗ 고시원 퇴실 뒤 현재 주거 첫날 플래그 누락")
    else:
        print("  ✓ 현수 7뿌리+20주 직접 야간 거울·이사 첫날 연결 고정")
    chapter3_mismatch = [
        f"t{turn}:{firelog.get(turn, 'missing')}!={event_id}"
        for turn, event_id in EXPECTED_CHAPTER3[name].items()
        if firelog.get(turn) != event_id
    ]
    if chapter3_mismatch:
        fail += 1
        print("  ✗ 3장 시간축 회귀:", ", ".join(chapter3_mismatch))
    else:
        print(f"  ✓ 3장 시간축 {len(EXPECTED_CHAPTER3[name])}앵커 고정")
    comparison_mismatch = [
        f"t{turn}:{firelog.get(turn, 'missing')}!={event_id}"
        for turn, event_id in EXPECTED_CHAPTER2_COMPARISON[name].items()
        if firelog.get(turn) != event_id
    ]
    if comparison_mismatch:
        fail += 1
        print("  ✗ 2장 비교 장면 간격 회귀:", ", ".join(comparison_mismatch))
    else:
        print("  ✓ 2장 대면 비교→SNS 압박 간격 고정")
    chapter4_causal_mismatch = [
        f"t{turn}:{firelog.get(turn, 'missing')}!={event_id}"
        for turn, event_id in EXPECTED_CHAPTER4_CAUSAL[name].items()
        if firelog.get(turn) != event_id
    ]
    if chapter4_causal_mismatch:
        fail += 1
        print("  ✗ 4장 인과 행동 시간축 회귀:", ", ".join(chapter4_causal_mismatch))
    else:
        print("  ✓ 4장 실제 행동→비용→의료 경과→연말 인과축 고정")
    late_push_expected = name == "B 비정석/진실/committed"
    if ("arc_late_game_push" in fired) != late_push_expected:
        fail += 1
        print("  ✗ arc_late_game_push career/investment 경로 gate 회귀")
    else:
        print("  ✓ arc_late_game_push=investment Path B only")
    expected_chapter5 = EXPECTED_CHAPTER5_CAUSAL[name]
    chapter5_causal_mismatch = [
        f"{event_id}:t{fired.get(event_id, 'missing')}!={turn}"
        for event_id, turn in expected_chapter5.items()
        if fired.get(event_id) != turn
    ]
    unexpected_chapter5 = sorted(
        event_id for event_id in CHAPTER5_ROOT_IDS
        if event_id in fired and event_id not in expected_chapter5
    )
    if chapter5_causal_mismatch or unexpected_chapter5:
        fail += 1
        print("  ✗ 5장 19루트 인과 시간축 회귀:",
              ", ".join(chapter5_causal_mismatch + [
                  f"unexpected:{event_id}" for event_id in unexpected_chapter5
              ]))
    elif not expected_chapter5:
        if S.chapter5_order or S.chapter5_receipts or S.chapter5_entry:
            fail += 1
            print("  ✗ career/다은보냄 Path A가 투자 부동산 entry/receipt를 획득")
        else:
            print("  ✓ career/다은보냄 Path A=19루트 부동산 vertical 미진입")
    elif story_queue_log.get(210) != [
            "arc_y5_jaehyuk_return_call_reference",
            "arc_y5_jaehyuk_father_document_reference",
    ]:
        fail += 1
        print("  ✗ W210 통화→아버지 문서 동일 큐 순서 회귀:",
              story_queue_log.get(210, []))
    elif len(S.chapter5_order) != 19 \
            or len(S.chapter5_receipts) != 19:
        fail += 1
        print("  ✗ 5장 write-once receipt 인구 회귀:",
              len(S.chapter5_order), len(S.chapter5_receipts))
    else:
        w212_flags = W212_OUTCOMES[1]["flags"]
        if S.chapter5_entry != CHAPTER5_ENTRY \
                or not all(S.flags.get(flag) for flag in w212_flags) \
                or S.chapter5_w212_tint != -6:
            fail += 1
            print("  ✗ Path B durable entry 또는 W212 singular mirror state 회귀")
        else:
            print(
                "  ✓ investment/다은함께 Path B=M49~M55 19루트·47선택"
                "·durable entry·W210 동일 큐·W212 canonical outcome"
            )
    expected_finale = EXPECTED_CHAPTER5_FINALE[name]
    chapter5_finale_mismatch = [
        f"{event_id}:t{fired.get(event_id, 'missing')}!={turn}"
        for event_id, turn in expected_finale.items()
        if fired.get(event_id) != turn
    ]
    unexpected_finale = sorted(
        event_id for event_id in CHAPTER5_FINALE_ROOT_IDS
        if event_id in fired and event_id not in expected_finale
    )
    if chapter5_finale_mismatch or unexpected_finale:
        fail += 1
        print(
            "  ✗ M56~M60 finale direct 시간축 회귀:",
            ", ".join(chapter5_finale_mismatch + [
                f"unexpected:{event_id}" for event_id in unexpected_finale
            ]),
        )
    elif not expected_finale:
        if S.chapter5_finale_entry \
                or S.chapter5_finale_receipts \
                or S.chapter5_finale_order \
                or S.chapter5_finale_ending_check != "pending" \
                or S.chapter5_finale_release_count != 0:
            fail += 1
            print("  ✗ career Path A가 safe-no-execution finale 상태를 획득")
        else:
            print("  ✓ career Path A=M56~M60 finale 미진입·legacy ending 축 유지")
    else:
        active_roots = [
            root for root in CHAPTER5_FINALE_ROOTS
            if chapter5_finale_root_active(root, S.chapter5_finale_entry)
        ]
        expected_queues = {}
        for root in active_roots:
            expected_queues.setdefault(int(root["turn"]), []).append(
                str(root["event_id"]))
        actual_queues = {
            turn: [
                event_id for event_id in story_queue_log.get(turn, [])
                if event_id in CHAPTER5_FINALE_ROOT_IDS
            ]
            for turn in expected_queues
        }
        nontransaction_receipt = S.chapter5_finale_receipts.get(
            "arc_y5_property_not_executed_notice", {})
        finale_state_ok = all((
            S.chapter5_finale_entry.get("profile_id")
            == "investment_safe_no_execution",
            S.chapter5_finale_entry.get("source_route_id")
            == "investment_property",
            S.chapter5_finale_entry.get("father", {}).get("life") == "passed",
            len(S.chapter5_finale_order) == 9,
            len(S.chapter5_finale_receipts) == 9,
            sum(len(root.get("choices", [])) for root in active_roots) == 24,
            actual_queues == expected_queues,
            story_queue_log.get(240) == [
                "arc_final_countdown_property_not_executed",
                "arc_y5_final_week_daeun_outbound",
            ],
            nontransaction_receipt.get("economic_outcome")
            == CHAPTER5_FINALE_NO_EXECUTION,
            S.chapter5_finale_economic_mutations == 0,
            S.chapter5_finale_ending_check == "consumed",
            S.chapter5_finale_release_count == 1,
            not chapter5_finale_holds_ending(S),
            "arc_final_countdown" not in fired,
            "arc_final_week" not in fired,
        ))
        if not finale_state_ok:
            fail += 1
            print(
                "  ✗ safe-no-execution finale receipt/queue/release 회귀:",
                S.chapter5_finale_entry,
                len(S.chapter5_finale_order),
                S.chapter5_finale_ending_check,
                S.chapter5_finale_release_count,
                actual_queues,
            )
        else:
            print(
                "  ✓ Path B=M56~M60 active 9루트/24선택·W240 서명→outbound"
                "·no-exec·canonical ending exactly once"
            )
    if not expected_finale:
        generic_finale_trace_ok = all((
            fired.get("arc_final_countdown") == 240,
            firelog.get(240) == "arc_final_countdown",
            story_queue_log.get(240) == ["arc_final_countdown"],
            S.flags.get("arc_final_countdown_seen") is True,
            S.flags.get("arc_final_week_seen") is True,
        ))
        if not generic_finale_trace_ok:
            fail += 1
            print(
                "  ✗ generic W240 countdown→same-turn final-week 회귀:",
                fired.get("arc_final_countdown"),
                story_queue_log.get(240, []),
                bool(S.flags.get("arc_final_week_seen")),
            )
        else:
            print(
                "  ✓ generic W240=countdown→same-turn final-week"
                "·W237 조기 종막 0"
            )
    late_temporal_mismatch = [
        f"t{turn}:{firelog.get(turn, 'missing')}!={event_id}"
        for turn, event_id in EXPECTED_LATE_TEMPORAL[name].items()
        if firelog.get(turn) != event_id
    ]
    if late_temporal_mismatch:
        fail += 1
        print("  ✗ 2·4·5장 시간축 회귀:", ", ".join(late_temporal_mismatch))
    elif fired["arc_final_stretch"] >= fired.get(
            "arc_gangnam_real_estate",
            fired.get("arc_gangnam_real_estate_father_passed", 9999),
    ):
        fail += 1
        print("  ✗ 자산 이정표 역순: 20억 장면이 25억 장면보다 늦음")
    else:
        print(
            "  ✓ 2·4장 예약 간격·연말→정산·20억→25억 이정표 순서 고정"
        )
    expected_w193_queue = ["chapter_card_37", "arc_37_reckoning"]
    if story_queue_log.get(193) != expected_w193_queue \
            or fired.get("arc_37_reckoning") != 193:
        fail += 1
        print(
            "  ✗ W193 StoryMode 인계 회귀:",
            story_queue_log.get(193, []),
        )
    else:
        print("  ✓ W193 챕터 카드→마지막 정산 동일 StoryMode 큐")
    if VERBOSE:
        for t, bridge_ids in sorted(bridge_log.items()):
            for bridge_id in bridge_ids:
                print(f"     b{t:3d} {bridge_id}")
        for t in range(1, 241):
            if t in firelog: print(f"     t{t:3d} {firelog[t]}")

print("\n" + ("❌ 회귀 발견 (잼 또는 미완결)" if fail else "✅ 흐름 무결 — 잼 0, 대표 체인 완결"))
sys.exit(1 if fail else 0)
