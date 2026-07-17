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

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
os.chdir(ROOT)
VERBOSE = "--verbose" in sys.argv

# ── ground truth: event -> 설정 가능한 플래그 ─────────────────────────────
event_sets = {}
for fp in glob.glob("content/events/*.json"):
    try:
        data = json.load(open(fp, encoding="utf-8"))
    except Exception:
        continue
    for ev in (data if isinstance(data, list) else list(data.values())):
        if isinstance(ev, dict) and ev.get("id"):
            event_sets[ev["id"]] = set(
                fl for ch in ev.get("choices", []) for fl in ch.get("flags", []))

# ── _next_arc_id() 파싱 (들여쓰기 스택으로 중첩 if AND) ───────────────────
src = open("scenes/MainGame.gd").read()
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
    m_ret = re.search(r'return "(arc_[a-z0-9_]+)"', tx)
    if m_ret:
        conds = [c for _, c in stack]
        inl = re.match(r'if\s+(.*):\s*return', tx)
        if inl:
            conds = conds + [inl.group(1)]
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
        s.t = 0; s.age = 33; s.flags = {}
        s.route_orthodox = 0; s.route_unorthodox = 0; s.intelligence = 50
        s.money = 500000; s.investment_skill = 0; s.job_tenure = 0
        s.housing = "gosiwon"; s.current_job = Job(); s.nav = 500000
        s.cast = {k: {"aff": 0, "stage": "none"} for k in
                  ["sangchul", "daeun", "jiyeon", "jaehyuk", "father"]}

    def get_total_asset_value(s): return s.nav
    def get_cast_affinity(s, n): return s.cast.get(n, {}).get("aff", 0)
    def get_cast_stage(s, n): return s.cast.get(n, {}).get("stage", "none")
    def cast_has_flag(s, n, fl): return fl in s.cast.get(n, {}).get("flags", set())
    def pop_ready_deferred_events(s): return []


def evalconds(conds, S):
    for r in conds:
        c = r.strip().rstrip(':')
        c = re.sub(r'_mp\.get\([^)]*\)', 'False', c)
        c = re.sub(r'MetaProgression\.meta\.get\([^)]*\)', 'False', c)
        c = c.replace("false", "False").replace("true", "True")
        c = c.replace("GameState.flags", "S.flags").replace("GameState.", "S.")
        c = re.sub(r'\bf\.get\(', 'S.flags.get(', c)
        c = re.sub(r'\bnav\b', 'S.nav', c)
        c = re.sub(r'\b_asset\b', 'S.nav', c)
        c = re.sub(r'(?<![\w.])t(?![\w])', 'S.t', c)
        c = c.replace("_age", "S.age")
        try:
            if not bool(eval(c, {"S": S})):
                return False
        except Exception:
            return False  # 평가 불가 조건은 보수적으로 미발동 처리
    return True


def own_seen_flags(eid):
    return [fl for fl in event_sets.get(eid, set())
            if fl.endswith(("_seen", "_done", "_closed"))]


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
    "arc_father_medication": ["arc_father_medication_seen"],
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
    "arc_hyunsu_night_talk": ["arc_hyunsu_night_seen"],
    "hyunsu_exam_day": ["hyunsu_exam_day_seen"],
    "arc_hyunsu_exam_fail": ["arc_hyunsu_exam_fail_seen"],
    "arc_hyunsu_new_path": ["arc_hyunsu_new_path_seen", "hyunsu_failed"],
    "hyunsu_pivot": ["hyunsu_pivoted"],
    # The reunion now writes its guard on the in-person terminal link.
    "hyunsu_reunion_later": ["hyunsu_reconnected"],
    "arc_midpoint_reckoning": ["arc_midpoint_reckoning_seen"],
    "arc_goshiwon_goodbye": ["arc_goshiwon_goodbye_seen"],
    "arc_jaewon_01_meet": ["arc_jaewon_01_seen"],
    "arc_jaewon_02_advice": ["arc_jaewon_02_seen"],
    "arc_jaewon_03_farewell": ["arc_jaewon_03_seen"],
    "arc_father_passing": ["father_passed"],
    "arc_34_money_attracts_money": ["arc_34_money_attracts_seen"],
    "arc_34_doors_open": ["arc_34_doors_open_seen"],
    "arc_35_path_cost": ["arc_35_path_cost_seen", "embraced_cost"],
    "arc_36_unexpected_hand": ["arc_36_unexpected_hand_seen", "accepted_grace"],
}
PATH_A = dict(SPINE_COMMON, **{  # 정석/다은 보냄/사기당함/진실모름
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
    "arc_sangchul_deduction": ["arc_sangchul_deduction_seen", "sangchul_truth_known", "deduced_sangchul_truth"],
    "arc_sangchul_known_offer": ["arc_sangchul_known_offer_seen", "used_sangchul_knowingly"],
    "arc_sangchul_known_reflex": ["arc_sangchul_known_reflex_seen"],
    "arc_sangchul_confrontation": ["arc_sangchul_confrontation_seen", "sangchul_confronted", "crossed_line"],
    "arc_sangchul_year3": ["arc_sangchul_year3_seen"],
    "arc_daeun_03_fork": ["arc_daeun_fork_seen", "daeun_chose_her", "daeun_together_path"],
    "arc_daeun_03b_date": ["arc_daeun_03b_seen"],
    "arc_daeun_04_morning": ["arc_daeun_04_seen"],
    "arc_daeun_04b_future": ["arc_daeun_04b_seen", "daeun_committed"],
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
    if t in (2, 5, 8, 12, 20, 30, 45, 60): S.route_orthodox += 1
    if t in (4, 25, 55): S.route_unorthodox += 1
    if t == 6: S.current_job = Job(title="staff")
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
    if t == 6: S.current_job = Job(title="staff")
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
    if t >= 9: S.cast["daeun"]["aff"] = min(40, t - 9)
    if t >= 17: S.cast["jiyeon"]["aff"] = min(40, t - 17)
    if t == 42: S.flags["jaehyuk_suspected"] = True


def run(spine, traj, cast_flag_hook):
    S = State(); fired = {}; firelog = {}; repeats = {}
    for t in range(1, 241):
        S.t = t; traj(S); cast_flag_hook(S)
        chosen = None
        for eid, conds in triggers:
            if evalconds(conds, S):
                chosen = eid; break
        if chosen:
            if chosen in fired:
                repeats[chosen] = repeats.get(chosen, 1) + 1
            fired[chosen] = t; firelog[t] = chosen
            for fl in own_seen_flags(chosen): S.flags[fl] = True
            for fl in spine.get(chosen, []): S.flags[fl] = True
    return fired, firelog, repeats, S


def hookA(S):
    if S.flags.get("jaehyuk_trusted_fully"):
        S.cast["jaehyuk"].setdefault("flags", set()).add("invested")


def hookB(S):
    if S.flags.get("jaehyuk_suspected"):
        S.cast["jaehyuk"].setdefault("flags", set()).add("suspected")


YEARS = {1: (1, 48), 2: (49, 96), 3: (97, 144), 4: (145, 192), 5: (193, 240)}
PATHS = [("A 정석/다은보냄/사기", PATH_A, traj_A, hookA),
         ("B 비정석/진실/committed", PATH_B, traj_B, hookB)]
# 경로별 완결돼야 하는 대표 체인
CHAINS = {
    "A 정석/다은보냄/사기": ["arc_daeun_ghost", "arc_jaehyuk_04c_stand_up", "arc_father_06_confession"],
    "B 비정석/진실/committed": ["arc_sangchul_confrontation", "arc_daeun_year4_together", "arc_jaehyuk_mirror"],
}

fail = 0
for name, spine, traj, hook in PATHS:
    fired, firelog, repeats, S = run(spine, traj, hook)
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
    if VERBOSE:
        for t in range(1, 241):
            if t in firelog: print(f"     t{t:3d} {firelog[t]}")

print("\n" + ("❌ 회귀 발견 (잼 또는 미완결)" if fail else "✅ 흐름 무결 — 잼 0, 대표 체인 완결"))
sys.exit(1 if fail else 0)
