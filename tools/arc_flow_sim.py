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
        s.housing = "gosiwon"; s.current_job = Job(); s.nav = 500000
        s.deferred_events = []
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
        selected = min(ready, key=lambda entry: (entry[0], s.deferred_events.index(entry)))
        s.deferred_events.remove(selected)
        return selected[1]

    def pop_ready_deferred_events(s):
        event_id = s.pop_ready_deferred_event()
        return [event_id] if event_id else []


def father_death_is_monotonic(S):
    """Mirror every durable death receipt accepted by MainGame."""
    return bool(
        S.flags.get("father_passed")
        or S.flags.get("arc_father_passing_seen")
        or S.get_cast_stage("father") == "passed"
    )


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
    # The Chapter 2 mirror root now immediately reaches the hospital-door
    # choice. Model the same deferred branch here so the scheduler does not
    # count the terminal event a second time at t90.
    "arc_sangchul_mirror": ["arc_sangchul_mirror_seen", "father_visit_deferred"],
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
    # Path B enters the room when the Chapter 2 mirror chain reaches its
    # terminal hospital-door choice.
    "arc_sangchul_mirror": ["arc_sangchul_mirror_seen", "visited_father"],
    "arc_sangchul_deduction": ["arc_sangchul_deduction_seen", "sangchul_truth_known", "deduced_sangchul_truth"],
    "arc_sangchul_known_offer": ["arc_sangchul_known_offer_seen", "used_sangchul_knowingly"],
    "arc_sangchul_known_reflex": ["arc_sangchul_known_reflex_seen"],
    "arc_sangchul_confrontation": ["arc_sangchul_confrontation_seen", "sangchul_confronted", "crossed_line"],
    "arc_sangchul_year3": ["arc_sangchul_year3_seen"],
    "arc_daeun_03_fork": ["arc_daeun_fork_seen", "daeun_chose_her", "daeun_together_path"],
    "arc_daeun_03b_date": ["arc_daeun_03b_seen"],
    "arc_daeun_04_morning": ["arc_daeun_04_seen"],
    "arc_daeun_04b_future": ["arc_daeun_04b_seen", "daeun_committed", "daeun_romance_started"],
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
    """Model MainGame's same-StoryMode-root handoff at the Year 5 boundary."""
    story_queue = list(event_ids)
    first_event_id = story_queue[0] if story_queue else ""
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
        elif t == 192 and not S.flags.get("arc_year4_close_seen"):
            chosen = "arc_year4_close"
        else:
            chosen = chapter_four_causal_event(S)
            protected_chapter_four_action = bool(chosen)
        if not chosen:
            chosen = S.pop_ready_deferred_event()
        if not chosen:
            for eid, conds in triggers:
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
                if protected_chapter_four_action and root_id == chosen:
                    apply_immediate_choice_state(S, root_id, choice_indices)
                for deferred_id, delay in canonical_deferred_links(
                        root_id, choice_indices):
                    S.add_deferred_event(deferred_id, delay)
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
        "hyunsu_study_together": 1,
        "hyunsu_result_fail": 0,
        "arc_hyunsu_exam_fail": 0,
        "arc_hyunsu_drift": 1,
    }),
    ("B 비정석/진실/committed", PATH_B, traj_B, hookB, {
        "arc_jaehyuk_03_pitch": 2,
        "hyunsu_study_together": 1,
        "hyunsu_result_fail": 0,
        "arc_hyunsu_exam_fail": 2,
        "arc_hyunsu_drift": 2,
    }),
]
# 경로별 완결돼야 하는 대표 체인
CHAINS = {
    "A 정석/다은보냄/사기": [
        "arc_year_one_mark", "arc_daeun_03_fork", "arc_34_doors_open",
        "arc_sangchul_mirror",
        "arc_daeun_ghost", "arc_jaehyuk_04c_stand_up", "arc_36_trust_crack",
        "arc_father_call_on_ktx", "arc_father_passing", "arc_father_legacy",
        "arc_final_countdown",
    ],
    "B 비정석/진실/committed": [
        "arc_year_one_mark", "arc_daeun_03_fork", "arc_34_doors_open",
        "arc_sangchul_mirror",
        "arc_sangchul_confrontation", "arc_jaehyuk_mirror", "arc_daeun_proposal",
        "arc_daeun_wedding_day", "arc_daeun_final_choice", "arc_36_trust_crack",
        "arc_father_passing", "arc_father_legacy", "arc_final_countdown",
    ],
}
REQUIRED_FLAGS = {
    "A 정석/다은보냄/사기": [
        "arc_sangchul_03_seen", "arc_jiyeon_offer_seen", "arc_father_03_seen",
        "father_visit_deferred", "arc_36_unexpected_hand_seen", "arc_final_week_seen",
        "arc_final_year_start_seen",
    ],
    "B 비정석/진실/committed": [
        "arc_sangchul_03_seen", "arc_jiyeon_offer_seen", "arc_father_03_seen",
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
        149: "arc_35_path_cost",
        151: "arc_almost_there",
        152: "arc_35_habit_check",
        154: "arc_36_reality_check",
        155: "arc_1b_isolation",
        180: "arc_36_night_doubt",
        192: "arc_year4_close",
        191: "arc_final_stretch",
        193: "arc_37_reckoning",
        204: "arc_37_burn_or_light",
        210: "arc_gangnam_real_estate_father_passed",
    },
    "B 비정석/진실/committed": {
        # This route refuses Jiyeon's coffee/meal offer, so the restaurant
        # branch and its occupied foreground week no longer exist.
        75: "arc_year_one_half",
        93: "arc_34_two_years_in",
        149: "arc_35_path_cost",
        152: "arc_35_habit_check",
        154: "arc_almost_there",
        158: "arc_1b_isolation",
        159: "arc_36_reality_check",
        180: "arc_36_night_doubt",
        192: "arc_year4_close",
        191: "arc_final_stretch",
        193: "arc_37_reckoning",
        204: "arc_37_burn_or_light",
        215: "arc_gangnam_real_estate_father_passed",
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
        101: "arc_35_birthday",
        102: "arc_jiyeon_year3",
        104: "arc_jaehyuk_03_pitch",
        106: "arc_jaehyuk_wait",
        108: "arc_jaehyuk_hyunsu_warning",
        109: "arc_35_orthodox_weight",
        110: "arc_y3_jiyeon_departure",
        115: "arc_why_gangnam_real",
        116: "arc_jaehyuk_04a_ghost",
        117: "arc_jaehyuk_aftermath",
        118: "arc_jaehyuk_mirror",
        121: "arc_midpoint_reckoning",
        122: "arc_year_two_half",
        126: "callback_jiyeon_busan_postcard",
        127: "arc_goal_vertigo",
        144: "arc_year3_close",
    },
    "B 비정석/진실/committed": {
        100: "arc_father_05_after_visit",
        102: "arc_jiyeon_year3",
        105: "arc_jaehyuk_03_pitch",
        108: "arc_35_unorthodox_weight",
        110: "arc_y3_jiyeon_departure",
        112: "arc_father_06_confession",
        113: "arc_sangchul_known_offer",
        115: "arc_why_gangnam_real",
        117: "arc_jaehyuk_04b_counter",
        118: "arc_jaehyuk_aftermath",
        119: "arc_jaehyuk_mirror",
        120: "arc_sangchul_known_reflex",
        121: "arc_midpoint_reckoning",
        122: "arc_year_two_half",
        124: "callback_father_confession_echo",
        125: "arc_jaehyuk_sangchul_echo",
        126: "callback_jiyeon_busan_postcard",
        127: "arc_goal_vertigo",
        129: "arc_jiyeon_father_records",
        130: "arc_y3_sangchul_deeper_room",
        132: "arc_sangchul_confrontation",
        133: "arc_sangchul_year3",
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
        "callback_jiyeon_together_pressure": 88,
        "callback_rushed_to_father_echo": 91,
        "callback_jiyeon_took_deal_consequence": 112,
        "callback_jiyeon_busan_postcard": 126,
    },
    "B 비정석/진실/committed": {
        "callback_escaped_dirty_trace": 24,
        "callback_investment_lesson_echo": 28,
        "callback_daeun_supportive_warmth": 46,
        "callback_jiyeon_took_deal_consequence": 59,
        "callback_jiyeon_together_pressure": 86,
        "callback_rushed_to_father_echo": 88,
        "callback_father_confession_echo": 124,
        "callback_jiyeon_busan_postcard": 126,
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
    "arc_y3_jiyeon_departure": (110, 135),
    "arc_endgame_sixmonths": (216, 237),
    "arc_daeun_money_gap": (60, 70),
}

EXPECTED_CAPPED_ARCS = {
    "A 정석/다은보냄/사기": {
        "arc_36_body_signal",
        "arc_year_three_half",
        "arc_36_night_doubt",
        "arc_y3_jiyeon_departure",
        "arc_endgame_sixmonths",
    },
    "B 비정석/진실/committed": set(CAPPED_ARC_WINDOWS),
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
if not W193_STORY_HANDOFF_SOURCE_OK:
    fail += 1
    print(
        "  ✗ W193 인계 소스 계약: chapter_card_37과 "
        "arc_37_reckoning이 같은 StoryMode 큐가 아님"
    )
else:
    print("  ✓ W193 인계 소스 계약=chapter_card_37→reckoning 같은 큐")

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
