#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
강남드림 정적 감사 (audit) — 플레이 없이 옛/새 시스템 모순을 잡는다.

검사 항목
  1) GDScript dangling 호출    : self.call("_x") / Callable(self,"_x") / 헬퍼에 넘긴 "_x"
                                 문자열이 가리키는 함수가 정의돼 있는가
  2) 폐기 키워드 스캔          : age=30, 65세, 은퇴, 가짜 랜덤 인물 이름 등 옛 설계 잔재
  3) 이벤트 JSON 무결성        : 파싱/중복 id/없는 follow_up/없는 portrait·background·cg
                                 /빈 result_text/모르는 cast 인물
  4) 플래그 교차 검증          : 코드/JSON에서 읽는 플래그가 실제로 어딘가에서 set되는가
                                 (← 문자열 플래그라 오타·이름 불일치가 조용히 죽는 버그)

ERROR가 하나라도 있으면 exit code 1.  WARNING은 통과(코드 0)하되 보고만 한다.
"""
import json, os, re, sys, glob

from event_schedule import DeferredFollowUpError, deferred_follow_ups

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

# ── 색/출력 헬퍼 ──────────────────────────────────────────────
class C:
    R = "\033[31m"; Y = "\033[33m"; G = "\033[32m"; B = "\033[36m"; Z = "\033[0m"; BOLD = "\033[1m"

errors = []
warns = []
def err(msg):  errors.append(msg)
def warn(msg): warns.append(msg)

def rel(p): return os.path.relpath(p, ROOT)

# ══════════════════════════════════════════════════════════════
# 0) ImageRegistry에서 유효한 portrait/background/cg/cast id 추출
# ══════════════════════════════════════════════════════════════
def dict_keys_from_const(text, const_name):
    """const NAME = { "key": ..., ... } 블록의 키들을 뽑는다."""
    m = re.search(r'const\s+%s\s*=\s*\{' % re.escape(const_name), text)
    if not m:
        return set()
    i = m.end()
    depth = 1
    body_start = i
    while i < len(text) and depth > 0:
        if text[i] == '{': depth += 1
        elif text[i] == '}': depth -= 1
        i += 1
    body = text[body_start:i-1]
    return set(re.findall(r'"([^"]+)"\s*:', body))

img_path = os.path.join(ROOT, "autoloads", "ImageRegistry.gd")
VALID_PORTRAITS = VALID_BACKGROUNDS = VALID_CG = set()
VALID_AMBIENCE = {"current_housing"}
CAST_IDS = set()
if os.path.exists(img_path):
    itext = open(img_path, encoding="utf-8").read()
    VALID_PORTRAITS  = dict_keys_from_const(itext, "PORTRAITS")
    VALID_BACKGROUNDS = dict_keys_from_const(itext, "BACKGROUNDS")
    VALID_CG         = dict_keys_from_const(itext, "CG")
    CAST_IDS         = dict_keys_from_const(itext, "PERSON_INFO")  # 인물 id 집합

audio_path = os.path.join(ROOT, "autoloads", "BGMPlayer.gd")
if os.path.exists(audio_path):
    atext = open(audio_path, encoding="utf-8").read()
    VALID_AMBIENCE |= dict_keys_from_const(atext, "AMBIENCE_TRACKS")

# ══════════════════════════════════════════════════════════════
# 1) GDScript dangling 동적 호출
# ══════════════════════════════════════════════════════════════
GD_DIRS = ["autoloads", "scenes", "systems", "ui_components"]
# 문자열이 "함수 이름"으로 쓰이는 정밀 패턴 (딕셔너리 키/람다 내부 오탐 방지)
DISPATCH_PATTERNS = [
    r'Callable\(\s*self\s*,\s*"(_\w+)"',   # Callable(self, "_x")
    r'\bcall\(\s*"(_\w+)"',                # self.call("_x") / .call("_x")
    r'\bconnect\(\s*"(_\w+)"',             # .connect("_x")  (구식 문자열 연결)
    r'"fn"\s*:\s*"(_\w+)"',                # {"fn": "_x"}  (액션 카드)
]
# fn 이름을 위치 인자로 받는 헬퍼 — 이 줄에선 "_x" 토큰 전부가 함수 후보
HELPER_LINE_FUNCS = ("_cat_modal_button(", "_add_category_card(")

# ':=' 추론이 Variant(.get())를 받는 패턴.
# Dictionary.get()/Object.get()은 Variant를 반환 → Godot 'inferred from Variant'
# 경고를 에러로 승격해 스크립트 컴파일이 통째로 실패한다(게임 안 켜짐).
# 헤드리스 --check-only는 autoload-not-found에서 조기 중단해 이걸 못 잡으므로 grep으로 방어.
INFER_RHS_RE  = re.compile(r':=\s*(.+)$')
CAST_WRAP_RE  = re.compile(r'^\s*(str|int|float|bool|String|StringName)\s*\(')
# 배열 리터럴을 바로 인덱싱 → Variant ( var x := [...][i] )
INFER_LIT_IDX = re.compile(r':=\s*\[.*\]\s*\[')

def check_gdscript():
    gd_files = []
    for d in GD_DIRS:
        gd_files += glob.glob(os.path.join(ROOT, d, "**", "*.gd"), recursive=True)
    # 전체 정의된 함수 (전역 풀 — 상속/타파일 정의 오탐 방지)
    global_defs = set()
    per_file_text = {}
    for f in gd_files:
        t = open(f, encoding="utf-8").read()
        per_file_text[f] = t
        global_defs |= set(re.findall(r'^func\s+(_?\w+)', t, re.M))

    def report(f, ln_no, ref, file_defs):
        if ref in file_defs or ref in global_defs:
            return
        err('%s:%d  문자열로 호출되지만 정의 없는 함수 → "%s"  (눌러도 무반응 버그)'
            % (rel(f), ln_no, ref))

    for f, t in per_file_text.items():
        file_defs = set(re.findall(r'^func\s+(_?\w+)', t, re.M))
        for ln_no, line in enumerate(t.splitlines(), 1):
            for pat in DISPATCH_PATTERNS:
                for ref in re.findall(pat, line):
                    report(f, ln_no, ref, file_defs)
            if any(h in line for h in HELPER_LINE_FUNCS):
                for ref in re.findall(r'"(_\w+)"', line):
                    report(f, ln_no, ref, file_defs)
            # := 가 Variant(.get())를 추론 받는 컴파일-실패 패턴
            mi = INFER_RHS_RE.search(line)
            if mi:
                rhs = mi.group(1)
                bad = (".get(" in rhs and not CAST_WRAP_RE.match(rhs)) \
                      or INFER_LIT_IDX.search(line) is not None
                if bad:
                    err('%s:%d  := 가 Variant(.get()/배열인덱싱)를 추론 → "경고=에러"로 컴파일 실패(게임 안 켜짐). 명시적 타입 지정(: String 등).  %s'
                        % (rel(f), ln_no, line.strip()[:60]))

# ══════════════════════════════════════════════════════════════
# 2) 폐기 키워드 스캔
# ══════════════════════════════════════════════════════════════
# (정규식, 설명)
DEPRECATED = [
    (r'\bage\s*=\s*30\b',          "시작 나이 30 (→ 33이어야 함)"),
    (r'\bage\s*=\s*20\b',          "시작 나이 20 (옛 설계)"),
    (r'65세',                      "옛 마감 65세 (→ 38세)"),
    (r'은퇴\s*조건',                "은퇴 시스템 (드라마 피벗으로 폐기)"),
    (r'(이수민|박지훈|김나연|이준호|최서연)',
                                   "가짜 랜덤 인물 이름 (named cast로 대체됨)"),
]
# 코드(.gd/.json)는 항상 검사. .md는 "살아있는 진실 문서"만 검사한다.
# (WORK_LOG/RELEASE_NOTES/BALANCE/ROADMAP/GAME_DESIGN 등은 과거 기록·구버전이라 제외)
LIVING_DOCS = {"CLAUDE.md", "STORY_BIBLE.md"}
SCAN_SKIP_DIRS = (".git", ".godot", "assets", "tools")

def _scan_target(path):
    fn = os.path.basename(path)
    if fn.endswith(".gd") or fn.endswith(".json"):
        return True
    if fn.endswith(".md"):
        return fn in LIVING_DOCS
    return False

def check_deprecated():
    for dirpath, dirnames, filenames in os.walk(ROOT):
        dirnames[:] = [d for d in dirnames if d not in SCAN_SKIP_DIRS]
        for fn in filenames:
            p = os.path.join(dirpath, fn)
            if not _scan_target(p):
                continue
            try:
                lines = open(p, encoding="utf-8").read().splitlines()
            except Exception:
                continue
            for pat, desc in DEPRECATED:
                for ln_no, line in enumerate(lines, 1):
                    if "audit-ignore" in line:   # 라인 단위 예외 (문서에서 패턴 자체를 설명할 때)
                        continue
                    if re.search(pat, line):
                        warn('%s:%d  폐기 키워드 [%s] → %s'
                             % (rel(p), ln_no, desc, line.strip()[:70]))

# ══════════════════════════════════════════════════════════════
# 3) 이벤트 JSON 무결성
# ══════════════════════════════════════════════════════════════
def load_events(path):
    d = json.load(open(path, encoding="utf-8"))
    if isinstance(d, list):
        return d
    if isinstance(d, dict):
        if "events" in d and isinstance(d["events"], list):
            return d["events"]
        # id→event 형태
        vals = list(d.values())
        if vals and all(isinstance(v, dict) for v in vals):
            return vals
    return []

def check_events():
    # 모든 json 파싱 검증
    all_json = glob.glob(os.path.join(ROOT, "content", "**", "*.json"), recursive=True)
    for p in all_json:
        try:
            json.load(open(p, encoding="utf-8"))
        except Exception as e:
            err("%s  JSON 파싱 실패: %s" % (rel(p), e))

    event_files = glob.glob(os.path.join(ROOT, "content", "events", "*.json"))
    all_events = {}      # id -> (file)
    events_by_file = {}
    for p in event_files:
        try:
            evs = load_events(p)
        except Exception:
            continue
        events_by_file[p] = evs
        for e in evs:
            eid = e.get("id")
            if not eid:
                err("%s  id 없는 이벤트: %s" % (rel(p), str(e.get("title", "?"))[:30]))
                continue
            if eid in all_events:
                err('중복 이벤트 id "%s"  (%s + %s)' % (eid, rel(all_events[eid]), rel(p)))
            else:
                all_events[eid] = p
    known_ids = set(all_events.keys())

    # 허용 카테고리 화이트리스트
    VALID_CATEGORIES = {
        "finance", "family", "jobs", "social", "gambling", "health",
        "investment", "relationship", "disasters", "politics", "comedy",
        "military", "story", "romance", "housing", "daily_life",
        "self_development", "career", "reflection",
    }

    for p, evs in events_by_file.items():
        for e in evs:
            eid = e.get("id", "?")
            # 카테고리 화이트리스트 검증
            cat = str(e.get("category", ""))
            if cat and cat not in VALID_CATEGORIES:
                warn('%s  [%s] 미등록 category → "%s"' % (rel(p), eid, cat))
            # 이미지 참조 검증 (없으면 placeholder로 폴백되지만 오타 가능성)
            port = e.get("portrait")
            if port and VALID_PORTRAITS and port not in VALID_PORTRAITS:
                warn('%s  [%s] 모르는 portrait id → "%s"' % (rel(p), eid, port))
            portrait_variants = e.get("portrait_if_known")
            if portrait_variants is not None:
                if not isinstance(portrait_variants, dict) or not portrait_variants:
                    err('%s  [%s] portrait_if_known은 비어 있지 않은 {flag: portrait_id} 객체여야 함'
                        % (rel(p), eid))
                else:
                    for flag_id, portrait_id in portrait_variants.items():
                        if not isinstance(flag_id, str) or not flag_id.strip():
                            err('%s  [%s] portrait_if_known 플래그 키가 비어 있음' % (rel(p), eid))
                        if not isinstance(portrait_id, str) or not portrait_id.strip():
                            err('%s  [%s] portrait_if_known[%s] 초상 ID가 비어 있음'
                                % (rel(p), eid, flag_id))
                        elif VALID_PORTRAITS and portrait_id not in VALID_PORTRAITS:
                            err('%s  [%s] portrait_if_known[%s] 모르는 portrait id → "%s"'
                                % (rel(p), eid, flag_id, portrait_id))
            bg = e.get("background")
            if bg and VALID_BACKGROUNDS and bg not in VALID_BACKGROUNDS:
                warn('%s  [%s] 모르는 background id → "%s"' % (rel(p), eid, bg))
            for paragraph_index, paragraph_bg in enumerate(e.get("paragraph_backgrounds", [])):
                if VALID_BACKGROUNDS and paragraph_bg not in VALID_BACKGROUNDS:
                    err('%s  [%s] paragraph_backgrounds[%d] 모르는 background id → "%s"'
                        % (rel(p), eid, paragraph_index, paragraph_bg))
            cg = e.get("cg")
            if cg and VALID_CG and cg not in VALID_CG:
                warn('%s  [%s] 모르는 cg id → "%s"' % (rel(p), eid, cg))
            cg_variants = e.get("cg_if_known")
            if cg_variants is not None:
                if not isinstance(cg_variants, dict) or not cg_variants:
                    err('%s  [%s] cg_if_known은 비어 있지 않은 {flag: cg_id} 객체여야 함'
                        % (rel(p), eid))
                else:
                    for flag_id, variant_cg_id in cg_variants.items():
                        if not isinstance(flag_id, str) or not flag_id.strip():
                            err('%s  [%s] cg_if_known 플래그 키가 비어 있음' % (rel(p), eid))
                        if not isinstance(variant_cg_id, str) or not variant_cg_id.strip():
                            err('%s  [%s] cg_if_known[%s] CG ID가 비어 있음'
                                % (rel(p), eid, flag_id))
                        elif VALID_CG and variant_cg_id not in VALID_CG:
                            err('%s  [%s] cg_if_known[%s] 모르는 cg id → "%s"'
                                % (rel(p), eid, flag_id, variant_cg_id))
            result_cg = e.get("result_cg")
            result_bg = e.get("result_background")
            result_reveal = e.get("result_cg_reveal_paragraph")
            if result_cg and VALID_CG and result_cg not in VALID_CG:
                err('%s  [%s] 모르는 공통 result_cg id → "%s"' % (rel(p), eid, result_cg))
            if result_bg and VALID_BACKGROUNDS and result_bg not in VALID_BACKGROUNDS:
                err('%s  [%s] 모르는 공통 result_background id → "%s"'
                    % (rel(p), eid, result_bg))
            if result_cg and result_bg:
                err('%s  [%s] 공통 result_cg와 result_background를 동시에 지정할 수 없음'
                    % (rel(p), eid))
            if result_reveal is not None:
                if not result_cg:
                    err('%s  [%s] result_cg_reveal_paragraph에는 공통 result_cg가 필요함'
                        % (rel(p), eid))
                if not isinstance(result_reveal, int) or isinstance(result_reveal, bool) \
                        or result_reveal < 1:
                    err('%s  [%s] result_cg_reveal_paragraph는 1 이상의 정수여야 함'
                        % (rel(p), eid))
            # choices
            for ci, ch in enumerate(e.get("choices", [])):
                result_cg = ch.get("result_cg")
                result_bg = ch.get("result_background")
                result_ambience = ch.get("result_ambience")
                result_reveal = ch.get("result_cg_reveal_paragraph")
                if result_cg and VALID_CG and result_cg not in VALID_CG:
                    err('%s  [%s] 선택지%d 모르는 result_cg id → "%s"'
                        % (rel(p), eid, ci, result_cg))
                if result_bg and VALID_BACKGROUNDS and result_bg not in VALID_BACKGROUNDS:
                    err('%s  [%s] 선택지%d 모르는 result_background id → "%s"'
                        % (rel(p), eid, ci, result_bg))
                if result_cg and result_bg:
                    err('%s  [%s] 선택지%d result_cg와 result_background를 동시에 지정할 수 없음'
                        % (rel(p), eid, ci))
                if result_ambience is not None:
                    if not isinstance(result_ambience, str) or result_ambience not in VALID_AMBIENCE:
                        err('%s  [%s] 선택지%d 모르는 result_ambience id → "%s"'
                            % (rel(p), eid, ci, result_ambience))
                    if not result_bg:
                        err('%s  [%s] 선택지%d result_ambience에는 result_background가 필요함'
                            % (rel(p), eid, ci))
                if result_reveal is not None:
                    if not result_cg:
                        err('%s  [%s] 선택지%d result_cg_reveal_paragraph에는 result_cg가 필요함'
                            % (rel(p), eid, ci))
                    if not isinstance(result_reveal, int) or isinstance(result_reveal, bool) \
                            or result_reveal < 1:
                        err('%s  [%s] 선택지%d result_cg_reveal_paragraph는 1 이상의 정수여야 함'
                            % (rel(p), eid, ci))
                fu = ch.get("follow_up_event", "")
                if fu and fu not in known_ids:
                    err('%s  [%s] 선택지%d follow_up_event "%s" 가 존재하지 않음 (스토리 체인 끊김)'
                        % (rel(p), eid, ci, fu))
                try:
                    delayed_links = deferred_follow_ups(ch)
                except DeferredFollowUpError as exc:
                    err('%s  [%s] 선택지%d deferred_follow_up 형식 오류: %s'
                        % (rel(p), eid, ci, exc))
                    delayed_links = []
                for dfu, _delay in delayed_links:
                    if dfu not in known_ids:
                        err('%s  [%s] 선택지%d deferred_follow_up "%s" 가 존재하지 않음 '
                            '(그림자 체인 끊김)' % (rel(p), eid, ci, dfu))
                # follow_up이 있는 '이어지는 선택지'는 result_text 없이 바로 다음 노드로
                # 내려가는 게 정상(연속 분기). 그 경우는 빈 result_text를 경고하지 않는다.
                if "result_text" in ch and not str(ch["result_text"]).strip() and not fu:
                    warn('%s  [%s] 선택지%d result_text 가 비어 있음' % (rel(p), eid, ci))
                ce = ch.get("cast_effects", {})
                if isinstance(ce, dict):
                    for pid in ce.keys():
                        if CAST_IDS and pid not in CAST_IDS:
                            warn('%s  [%s] 선택지%d 모르는 cast 인물 → "%s"' % (rel(p), eid, ci, pid))

def check_romance_visual_manifest():
    path = os.path.join(ROOT, "assets", "romance_visual_manifest.json")
    if not os.path.exists(path):
        err("assets/romance_visual_manifest.json  로맨스 비주얼 계약 누락")
        return
    try:
        root = json.load(open(path, encoding="utf-8"))
    except Exception as e:
        err("%s  JSON 파싱 실패: %s" % (rel(path), e))
        return
    t0_rows = root.get("t0", []) if isinstance(root, dict) else []
    t1_rows = root.get("t1", []) if isinstance(root, dict) else []
    t2_rows = root.get("t2", []) if isinstance(root, dict) else []
    if not isinstance(t0_rows, list) or len(t0_rows) != 10:
        err("%s  T0 계약은 정확히 10개여야 함" % rel(path))
        return
    if not isinstance(t1_rows, list):
        err("%s  T1 계약은 배열이어야 함" % rel(path))
        return
    if not isinstance(t2_rows, list) or len(t2_rows) != 2:
        err("%s  T2 이별 계약은 정확히 2개여야 함" % rel(path))
        return
    rows = t0_rows + t1_rows + t2_rows

    events = {}
    for event_path in glob.glob(os.path.join(ROOT, "content", "events", "*.json")):
        try:
            for event in load_events(event_path):
                events[str(event.get("id", ""))] = event
        except Exception:
            continue

    player_spec = root.get("player_outfit", {})
    player_portrait = str(player_spec.get("portrait", "")) if isinstance(player_spec, dict) else ""
    if player_portrait not in VALID_PORTRAITS:
        err('%s  모르는 Minjun portrait id → "%s"' % (rel(path), player_portrait))

    owners = set()
    valid_visibility = {"pov", "cropped_left", "visible_left", "visible_right"}
    for row in rows:
        if not isinstance(row, dict):
            err("%s  로맨스 비주얼 계약 행이 dictionary가 아님" % rel(path))
            continue
        event_id = str(row.get("event_id", ""))
        if not event_id or event_id in owners:
            err('%s  비어 있거나 중복된 event_id → "%s"' % (rel(path), event_id))
            continue
        owners.add(event_id)
        event = events.get(event_id)
        if not event:
            err('%s  없는 이벤트 계약 → "%s"' % (rel(path), event_id))
            continue
        cg_id = str(row.get("cg", ""))
        portrait_id = str(row.get("heroine_portrait", ""))
        choice_index = row.get("choice_index")
        placement = str(row.get("cg_placement", "choice_result" if choice_index is not None else "event"))
        actual_cg = str(event.get("cg", ""))
        if placement == "event_result":
            actual_cg = str(event.get("result_cg", ""))
        elif placement == "choice_result":
            choices = event.get("choices", [])
            if not isinstance(choice_index, int) or isinstance(choice_index, bool) \
                    or choice_index < 0 or choice_index >= len(choices):
                err('%s  [%s] choice_index 범위 오류' % (rel(path), event_id))
                actual_cg = ""
            else:
                actual_cg = str(choices[choice_index].get("result_cg", ""))
        elif placement != "event":
            err('%s  [%s] cg_placement 값 오류 → "%s"' % (rel(path), event_id, placement))
            actual_cg = ""
        if actual_cg != cg_id:
            err('%s  [%s] CG가 romance manifest와 다름' % (rel(path), event_id))
        if str(event.get("portrait", "")) != portrait_id:
            err('%s  [%s] 초상화 의상이 romance manifest와 다름' % (rel(path), event_id))
        if cg_id not in VALID_CG:
            err('%s  [%s] 모르는 CG id → "%s"' % (rel(path), event_id, cg_id))
        portrait_visibility = str(row.get("portrait_visibility", "visible"))
        if not portrait_id and portrait_visibility != "hidden_before_reveal":
            err('%s  [%s] 빈 heroine_portrait에는 hidden_before_reveal 계약이 필요함'
                % (rel(path), event_id))
        elif portrait_id and portrait_id not in VALID_PORTRAITS:
            err('%s  [%s] 모르는 portrait id → "%s"' % (rel(path), event_id, portrait_id))
        if not str(row.get("heroine_outfit", "")).strip():
            err('%s  [%s] heroine_outfit 계약 누락' % (rel(path), event_id))
        if not str(row.get("eye_line", "")).strip():
            err('%s  [%s] eye_line 계약 누락' % (rel(path), event_id))
        if str(row.get("player_visibility", "")) not in valid_visibility:
            err('%s  [%s] player_visibility 값 오류' % (rel(path), event_id))
        season_months = row.get("season_months")
        if season_months is not None:
            if not isinstance(season_months, list) or not season_months \
                    or any(not isinstance(month, int) or isinstance(month, bool)
                           or month < 1 or month > 12 for month in season_months):
                err('%s  [%s] season_months 계약 오류' % (rel(path), event_id))

# ══════════════════════════════════════════════════════════════
# 4) 플래그 교차 검증 — 읽기만 하고 아무도 set 안 하는 플래그를 잡는다
# ══════════════════════════════════════════════════════════════
# 게임 플래그 SET 위치:
#   JSON: choices[].flags[], effects.flag, opportunity.win_flag/lose_flag
#   GD  : flags["x"] = ... 또는 원자 트랜잭션의 flag_updates["x"] = ...
# 게임 플래그 READ 위치:
#   GD  : f.get("x") / flags.get("x") / f.has("x") / flags.has("x")
#   JSON: conditions.flag / conditions.no_flag
# cast 플래그(인물별 네임스페이스):
#   SET : cast_effects.<pid>.flags[]
#   READ: cast_has_flag("pid","flag"), conditions.cast_flag {person,flag}
FLAG_SET_GD   = re.compile(
    r'\b(?:flags|flag_updates)\["([A-Za-z0-9_]+)"\]\s*=\s*[^=]')
FLAG_READ_GD  = [
    re.compile(r'\bf\.get\("([A-Za-z0-9_]+)"'),
    re.compile(r'\bflags\.get\("([A-Za-z0-9_]+)"'),
    re.compile(r'\bf\.has\("([A-Za-z0-9_]+)"'),
    re.compile(r'\bflags\.has\("([A-Za-z0-9_]+)"'),
    re.compile(r'\bflags\["([A-Za-z0-9_]+)"\]\s*=='),
]
CAST_READ_GD  = re.compile(r'cast_has_flag\(\s*"([a-z0-9_]+)"\s*,\s*"([A-Za-z0-9_]+)"')

def _known_condition_flags(raw_key):
    """Known-variant keys may require several flags with `a&b` syntax."""
    if not isinstance(raw_key, str):
        return []
    return [part.strip() for part in raw_key.split("&") if part.strip()]

def _walk_event_flags(ev, game_sets, game_reads_json, cast_sets, cast_reads_json, where):
    cond = ev.get("conditions", {})
    if isinstance(cond, dict):
        for key in ("flag", "no_flag"):
            v = cond.get(key)
            if isinstance(v, str) and v:
                game_reads_json.setdefault(v, []).append(where)
            elif isinstance(v, list):  # no_flag 배열 지원
                for fl in v:
                    if isinstance(fl, str) and fl:
                        game_reads_json.setdefault(fl, []).append(where)
        cf = cond.get("cast_flag")
        if isinstance(cf, dict):
            p, fl = str(cf.get("person", "")), str(cf.get("flag", ""))
            if p and fl:
                cast_reads_json.setdefault((p, fl), []).append(where)
    # description_if_known 키 = 렌더링 엔진이 flags.get()으로 읽는 플래그
    dik = ev.get("description_if_known", {})
    if isinstance(dik, dict):
        for condition_key in dik.keys():
            for fl in _known_condition_flags(condition_key):
                game_reads_json.setdefault(fl, []).append(where)
    memory_dik = ev.get("description_memory_if_known", {})
    if isinstance(memory_dik, dict):
        for condition_key in memory_dik.keys():
            for fl in _known_condition_flags(condition_key):
                if fl.startswith((
                    "relationship_memory:",
                    "future_story_source:",
                    "obligation_receipt:",
                )):
                    continue
                game_reads_json.setdefault(fl, []).append(where)
    pik = ev.get("portrait_if_known", {})
    if isinstance(pik, dict):
        for condition_key in pik.keys():
            for fl in _known_condition_flags(condition_key):
                game_reads_json.setdefault(fl, []).append(where)
    cik = ev.get("cg_if_known", {})
    if isinstance(cik, dict):
        for condition_key in cik.keys():
            for fl in _known_condition_flags(condition_key):
                game_reads_json.setdefault(fl, []).append(where)
    # 생각정리(thoughts.json) on_complete.flags = 완료 시 set되는 플래그
    oc = ev.get("on_complete", {})
    if isinstance(oc, dict):
        for fl in oc.get("flags", []):
            if isinstance(fl, str) and fl:
                game_sets.add(str(fl))
    for ch in ev.get("choices", []):
        for fl in ch.get("flags", []):
            game_sets.add(str(fl))
        eff = ch.get("effects", {})
        if isinstance(eff, dict) and isinstance(eff.get("flag"), str):
            game_sets.add(eff["flag"])
        opp = ch.get("opportunity", {})
        if isinstance(opp, dict):
            for key in ("win_flag", "lose_flag"):
                if isinstance(opp.get(key), str) and opp[key]:
                    game_sets.add(opp[key])
        ce = ch.get("cast_effects", {})
        if isinstance(ce, dict):
            for pid, pe in ce.items():
                if isinstance(pe, dict):
                    for fl in pe.get("flags", []):
                        cast_sets.add((str(pid), str(fl)))

def check_flags():
    game_sets = set()           # set되는 게임 플래그 전체
    cast_sets = set()           # set되는 (인물, 플래그) 전체
    game_reads_gd   = {}        # flag -> [위치]
    game_reads_json = {}
    cast_reads_gd   = {}
    cast_reads_json = {}

    # ── JSON 수집 ──
    for p in glob.glob(os.path.join(ROOT, "content", "**", "*.json"), recursive=True):
        try:
            evs = load_events(p)
        except Exception:
            continue
        for ev in evs:
            if not isinstance(ev, dict):
                continue
            where = "%s [%s]" % (rel(p), ev.get("id", "?"))
            _walk_event_flags(ev, game_sets, game_reads_json,
                              cast_sets, cast_reads_json, where)

    # ── GDScript 수집 ──
    for d in GD_DIRS:
        for f in glob.glob(os.path.join(ROOT, d, "**", "*.gd"), recursive=True):
            for ln_no, line in enumerate(open(f, encoding="utf-8").read().splitlines(), 1):
                if "audit-ignore" in line:
                    continue
                for m in FLAG_SET_GD.finditer(line):
                    game_sets.add(m.group(1))
                for pat in FLAG_READ_GD:
                    for name in pat.findall(line):
                        game_reads_gd.setdefault(name, []).append("%s:%d" % (rel(f), ln_no))
                for m in CAST_READ_GD.finditer(line):
                    cast_reads_gd.setdefault((m.group(1), m.group(2)), []).append(
                        "%s:%d" % (rel(f), ln_no))

    # ── 대조: 읽기만 하고 set 없는 플래그 → ERROR ──
    for name, locs in sorted(game_reads_gd.items()):
        if name not in game_sets:
            err('플래그 "%s" 를 코드가 읽지만 아무도 set 안 함 (패널/분기 조용히 죽음)  %s'
                % (name, locs[0]))
    for name, locs in sorted(game_reads_json.items()):
        if name not in game_sets:
            err('플래그 "%s" 를 이벤트 조건이 읽지만 아무도 set 안 함 (이벤트 영영 안 뜸)  %s'
                % (name, locs[0]))
    for (pid, fl), locs in sorted(cast_reads_gd.items()):
        if (pid, fl) not in cast_sets:
            err('cast 플래그 %s.%s 를 코드가 읽지만 어떤 cast_effects도 set 안 함  %s'
                % (pid, fl, locs[0]))
    for (pid, fl), locs in sorted(cast_reads_json.items()):
        if (pid, fl) not in cast_sets:
            err('cast 플래그 %s.%s 를 이벤트 조건이 읽지만 어떤 cast_effects도 set 안 함  %s'
                % (pid, fl, locs[0]))

# ══════════════════════════════════════════════════════════════
# 5) serialize 완전성 — GameState var 선언 vs serialize() 키 대조
#    (run_theme/events_seen 류: 변수는 추가했는데 저장 누락 → 로드 시 조용히 리셋)
# ══════════════════════════════════════════════════════════════
# 의도적으로 저장하지 않는 transient 변수 (씬 전환용 임시 상태)
SERIALIZE_EXEMPT = {
    "pending_story_queue", "story_return_scene", "returning_from_story", "story_replay_mode",
    "pending_tint_vignette", "pending_scar_vignette",
}

def check_serialize():
    gs_path = os.path.join(ROOT, "autoloads", "GameState.gd")
    if not os.path.exists(gs_path):
        return
    src = open(gs_path, encoding="utf-8").read()
    var_names = re.findall(r'^var\s+([a-z_][a-z0-9_]*)\b', src, re.M)
    m = re.search(r'func serialize\(\):\s*\n\treturn \{(.*?)\n\t\}', src, re.S)
    if not m:
        warn("GameState.serialize() 본문을 찾지 못해 완전성 검사 건너뜀")
        return
    ser_keys = set(re.findall(r'"([a-z_][a-z0-9_]*)"\s*:', m.group(1)))
    for v in var_names:
        if v not in ser_keys and v not in SERIALIZE_EXEMPT:
            err('GameState.%s 가 serialize()에 없음 — 저장 후 로드하면 조용히 기본값으로 리셋. '
                '저장 대상이면 serialize()에 추가, transient면 audit.py SERIALIZE_EXEMPT에 등록' % v)

# ══════════════════════════════════════════════════════════════
# 6) 이벤트 키 화이트리스트 — effects/conditions/opportunity/cast_effects의
#    미지의 키를 잡는다 ("metal": 5 같은 오타는 apply_effects가 조용히 무시함)
# ══════════════════════════════════════════════════════════════
OPPORTUNITY_KEYS = {"cost", "stake_ratio", "success_rate", "win_multiplier",
                    "loss_ratio", "luck_factor", "win_flag", "lose_flag", "skill_gain"}
CAST_EFFECT_KEYS = {"affinity", "stage", "met", "flags"}
# 이벤트 루트에서 허용되는 키 (스키마)
EVENT_ROOT_KEYS = {"id", "title", "description", "category", "rarity", "weight",
                   "hidden", "conditions", "tags", "cooldown", "choices",
                   "portrait", "portrait_if_known", "portrait_reveal_paragraph", "background", "paragraph_backgrounds", "cg", "cg_if_known", "cg_reveal_paragraph", "speaker", "one_time", "_file",
                   "result_cg", "result_cg_reveal_paragraph", "result_background",
                   "timed", "timer_seconds",
                   "description_orthodox", "description_unorthodox",
                   "description_low_mental", "description_long_gosiwon",
                   "description_if_known", "description_memory_if_known",
                   "description_if_moral", "direction"}
EVENT_ROOT_KEYS.update({"year_scene_year", "timer_default_choice", "living_scene"})
MORAL_PERCEPTION_KEYS = {"deep_black", "black", "gray", "white", "deep_white"}
DIRECTION_KEYS = {"pace", "amb", "sting", "camera", "hold", "visual"}
DIRECTION_VALUES = {
    "pace": {"slow", "beat"},
    "amb": {"cut", "duck"},
    "sting": {"reveal", "loss", "cold"},
    "camera": {"slow_zoom", "drift"},
    "visual": {"black_future"},
}
LIVING_SCENE_KEYS = {"effect", "intensity", "blur_px", "memory"}
LIVING_SCENE_EFFECTS = {"none", "rain", "snow", "memory", "city_light", "fireworks"}
# apply_choice()가 실제로 처리하는 선택지 키 + 주석용 키
CHOICE_KEYS = {"text", "text_if_moral", "effects", "flags", "follow_up_event",
               "follow_up_requires_flags", "result_text",
               "result_cg", "result_cg_reveal_paragraph", "result_background", "result_ambience",
               "opportunity", "cast_effects", "relationship_effects",
               "investment_effects", "tendency", "route", "grant_job",
               "grant_job_display", "first_paycheck_ratio", "replace_current_job",
               "conditions_note", "deferred_follow_up", "deferred_delay",
               "foreshadow", "bridge_summary", "clues", "give_items", "requires_item", "housing_keepsake",
               "year_scene", "choice_kind", "v2_obligation_id",
               "v2_player_initiated_character"}
CHOICE_KINDS = {"expression", "memory", "decision"}
EXPRESSION_CHOICE_KEYS = {
    "text", "choice_kind", "follow_up_event", "result_text",
    "result_cg", "result_cg_reveal_paragraph", "result_background",
    "result_ambience",
}

def _match_arm_keys(src, func_pattern):
    """함수 본문 안 match 문의 따옴표 키들을 수집 (코드가 진실 — 목록 자동 동기화)."""
    m = re.search(func_pattern, src)
    if not m:
        return set()
    body = src[m.end():]
    nxt = re.search(r'\nfunc ', body)
    if nxt:
        body = body[:nxt.start()]
    keys = set()
    for line in body.splitlines():
        s = line.strip()
        if re.match(r'^"[a-z_]', s) and s.endswith(':'):
            keys.update(re.findall(r'"([a-z_][a-z0-9_]*)"', s))
    return keys

def _check_moral_text_map(value, label):
    if not isinstance(value, dict) or not value:
        err('%s는 비어 있지 않은 object여야 함' % label)
        return
    for key, text in value.items():
        if key not in MORAL_PERCEPTION_KEYS:
            err('%s 미지원 밴드 "%s"' % (label, key))
        if not isinstance(text, str) or not text.strip():
            err('%s.%s는 빈 값이 아닌 문자열이어야 함' % (label, key))

def check_event_registry_coverage():
    """모든 이벤트 JSON이 런타임 DataRegistry에 실제로 연결됐는지 확인한다."""
    registry_path = os.path.join(ROOT, "autoloads", "DataRegistry.gd")
    registry_src = open(registry_path, encoding="utf-8").read()
    registered_list = re.findall(r'res://content/events/([^"\n]+\.json)', registry_src)
    registered = set(registered_list)
    disk = {
        os.path.basename(path)
        for path in glob.glob(os.path.join(ROOT, "content", "events", "*.json"))
    }
    duplicates = sorted(name for name in registered if registered_list.count(name) > 1)
    missing = sorted(disk - registered)
    dangling = sorted(registered - disk)
    if duplicates:
        err("DataRegistry EVENT_PATHS 중복 등록: %s" % ", ".join(duplicates))
    if missing:
        err("DataRegistry EVENT_PATHS 미등록 이벤트 파일: %s" % ", ".join(missing))
    if dangling:
        err("DataRegistry EVENT_PATHS가 없는 파일을 참조: %s" % ", ".join(dangling))

def check_event_keys():
    gs = open(os.path.join(ROOT, "autoloads", "GameState.gd"), encoding="utf-8").read()
    em = open(os.path.join(ROOT, "autoloads", "EventManager.gd"), encoding="utf-8").read()
    effect_keys = _match_arm_keys(gs, r'func apply_effects\([^)]*\):')
    cond_keys = _match_arm_keys(em, r'func _check_conditions\([^)]*\):')
    if not effect_keys or not cond_keys:
        warn("apply_effects/_check_conditions 파싱 실패 — 키 화이트리스트 검사 건너뜀")
        return
    for p in glob.glob(os.path.join(ROOT, "content", "events", "*.json")):
        try:
            evs = load_events(p)
        except Exception:
            continue
        for e in evs:
            if not isinstance(e, dict):
                continue
            eid = e.get("id", "?")
            for k in e.keys():
                if k not in EVENT_ROOT_KEYS:
                    warn('%s  [%s] 모르는 이벤트 루트 키 "%s"' % (rel(p), eid, k))
            if "year_scene_year" in e:
                year_scene_year = e.get("year_scene_year")
                if not isinstance(year_scene_year, int) or isinstance(year_scene_year, bool) \
                        or year_scene_year < 1 or year_scene_year > 5:
                    err('%s  [%s] year_scene_year는 1~5 정수여야 함' % (rel(p), eid))
                if "year_scene_curation" not in e.get("tags", []):
                    err('%s  [%s] year_scene_year 이벤트에 year_scene_curation 태그 누락' % (rel(p), eid))
            if e.get("timed", False):
                timer_seconds = e.get("timer_seconds", 0)
                if not isinstance(timer_seconds, int) or isinstance(timer_seconds, bool) or timer_seconds < 1:
                    err('%s  [%s] timed 이벤트의 timer_seconds는 1 이상 정수여야 함' % (rel(p), eid))
                timer_default = e.get("timer_default_choice", 0)
                choice_count = len(e.get("choices", []))
                if not isinstance(timer_default, int) or isinstance(timer_default, bool) \
                        or timer_default < 0 or timer_default >= choice_count:
                    err('%s  [%s] timer_default_choice %s가 선택지 범위 0..%d 밖' \
                        % (rel(p), eid, timer_default, max(0, choice_count - 1)))
            direction = e.get("direction")
            if direction is not None:
                if not isinstance(direction, dict):
                    err('%s  [%s] direction은 object여야 함' % (rel(p), eid))
                else:
                    for dk, dv in direction.items():
                        if dk not in DIRECTION_KEYS:
                            err('%s  [%s] direction 미지 필드 "%s"' % (rel(p), eid, dk))
                        elif dk == "hold":
                            if not isinstance(dv, (int, float)) or isinstance(dv, bool) or not 0.5 <= float(dv) <= 2.0:
                                err('%s  [%s] direction.hold는 0.5~2.0초 숫자여야 함' % (rel(p), eid))
                        elif dv not in DIRECTION_VALUES.get(dk, set()):
                            err('%s  [%s] direction.%s 값 "%s"를 렌더러가 처리하지 않음' % (rel(p), eid, dk, dv))
            living_scene = e.get("living_scene")
            if living_scene is not None:
                if not isinstance(living_scene, dict):
                    err('%s  [%s] living_scene은 object여야 함' % (rel(p), eid))
                else:
                    for lk, lv in living_scene.items():
                        if lk not in LIVING_SCENE_KEYS:
                            err('%s  [%s] living_scene 미지 필드 "%s"' % (rel(p), eid, lk))
                        elif lk == "effect" and lv not in LIVING_SCENE_EFFECTS:
                            err('%s  [%s] living_scene.effect 값 "%s"를 렌더러가 처리하지 않음' % (rel(p), eid, lv))
                        elif lk == "intensity" and (not isinstance(lv, (int, float)) or isinstance(lv, bool) or not 0.0 <= float(lv) <= 0.65):
                            err('%s  [%s] living_scene.intensity는 0.0~0.65 숫자여야 함' % (rel(p), eid))
                        elif lk == "blur_px" and (not isinstance(lv, (int, float)) or isinstance(lv, bool) or not 0.0 <= float(lv) <= 2.0):
                            err('%s  [%s] living_scene.blur_px는 0.0~2.0 숫자여야 함' % (rel(p), eid))
                        elif lk == "memory" and not isinstance(lv, bool):
                            err('%s  [%s] living_scene.memory는 bool이어야 함' % (rel(p), eid))
            if "description_if_moral" in e:
                _check_moral_text_map(
                    e.get("description_if_moral"),
                    '%s  [%s] description_if_moral' % (rel(p), eid))
            cg_reveal = e.get("cg_reveal_paragraph")
            if cg_reveal is not None:
                if not isinstance(cg_reveal, int) or isinstance(cg_reveal, bool) or cg_reveal < 1:
                    err('%s  [%s] cg_reveal_paragraph는 1 이상의 문단 인덱스여야 함' % (rel(p), eid))
                if not str(e.get("cg", "")):
                    err('%s  [%s] cg_reveal_paragraph에는 cg가 필요함' % (rel(p), eid))
            paragraph_backgrounds = e.get("paragraph_backgrounds")
            if paragraph_backgrounds is not None:
                if not isinstance(paragraph_backgrounds, list) or len(paragraph_backgrounds) < 2:
                    err('%s  [%s] paragraph_backgrounds는 2개 이상의 배경 ID 배열이어야 함' % (rel(p), eid))
                elif any(not isinstance(bg, str) or not bg.strip() for bg in paragraph_backgrounds):
                    err('%s  [%s] paragraph_backgrounds의 모든 항목은 빈 값이 아닌 문자열이어야 함' % (rel(p), eid))
                else:
                    paragraph_texts = [("description", e.get("description", ""))]
                    for variant_key in ["description_orthodox", "description_unorthodox",
                                        "description_low_mental", "description_long_gosiwon"]:
                        if variant_key in e:
                            paragraph_texts.append((variant_key, e.get(variant_key, "")))
                    known_map = e.get("description_if_known", {})
                    if isinstance(known_map, dict):
                        for flag_id, text in known_map.items():
                            paragraph_texts.append(("description_if_known.%s" % flag_id, text))
                    moral_map = e.get("description_if_moral", {})
                    if isinstance(moral_map, dict):
                        for moral_band, text in moral_map.items():
                            paragraph_texts.append(("description_if_moral.%s" % moral_band, text))
                    for variant_name, variant_text in paragraph_texts:
                        paragraph_count = len([part for part in str(variant_text).split("\n\n") if part.strip()])
                        if paragraph_count and len(paragraph_backgrounds) != paragraph_count:
                            err('%s  [%s] paragraph_backgrounds %d개가 %s 문단 %d개와 일치하지 않음'
                                % (rel(p), eid, len(paragraph_backgrounds), variant_name, paragraph_count))
            portrait_reveal = e.get("portrait_reveal_paragraph")
            if portrait_reveal is not None:
                if not isinstance(portrait_reveal, int) or isinstance(portrait_reveal, bool) or portrait_reveal < 1:
                    err('%s  [%s] portrait_reveal_paragraph는 1 이상의 문단 인덱스여야 함' % (rel(p), eid))
                if not str(e.get("portrait", "")):
                    err('%s  [%s] portrait_reveal_paragraph에는 portrait가 필요함' % (rel(p), eid))
                if str(e.get("cg", "")):
                    err('%s  [%s] portrait_reveal_paragraph는 전체화면 cg와 함께 쓸 수 없음' % (rel(p), eid))
            cond = e.get("conditions", {})
            if isinstance(cond, dict):
                for k in cond.keys():
                    if k not in cond_keys:
                        err('%s  [%s] 조건 키 "%s" 를 EventManager가 처리하지 않음 — 조건이 조용히 무시돼 이벤트가 잘못 뜸'
                            % (rel(p), eid, k))
            for ci, ch in enumerate(e.get("choices", [])):
                if not isinstance(ch, dict):
                    continue
                for k in ch.keys():
                    if k not in CHOICE_KEYS:
                        warn('%s  [%s] 선택지%d 모르는 키 "%s"' % (rel(p), eid, ci, k))
                if "choice_kind" in ch:
                    choice_kind = ch.get("choice_kind")
                    if choice_kind not in CHOICE_KINDS:
                        err('%s  [%s] 선택지%d choice_kind "%s"는 expression/memory/decision 중 하나여야 함'
                            % (rel(p), eid, ci, choice_kind))
                    elif choice_kind == "expression":
                        permanent_keys = sorted(set(ch) - EXPRESSION_CHOICE_KEYS)
                        if permanent_keys:
                            err('%s  [%s] 선택지%d expression 선택은 현재 장면 밖 상태를 바꾸는 키를 가질 수 없음: %s'
                                % (rel(p), eid, ci, permanent_keys))
                        if not isinstance(ch.get("result_text"), str) or not ch.get("result_text", "").strip():
                            err('%s  [%s] 선택지%d expression 선택에는 고유한 비어 있지 않은 result_text가 필요함'
                                % (rel(p), eid, ci))
                if "follow_up_requires_flags" in ch:
                    required_flags = ch.get("follow_up_requires_flags")
                    if (
                        not isinstance(required_flags, list)
                        or not required_flags
                        or any(
                            not isinstance(flag, str) or not flag.strip()
                            for flag in required_flags
                        )
                        or not str(ch.get("follow_up_event", "")).strip()
                    ):
                        err(
                            '%s  [%s] 선택지%d follow_up_requires_flags는 '
                            '비어 있지 않은 플래그 배열과 follow_up_event가 필요함'
                            % (rel(p), eid, ci)
                        )
                if "text_if_moral" in ch:
                    _check_moral_text_map(
                        ch.get("text_if_moral"),
                        '%s  [%s] 선택지%d text_if_moral' % (rel(p), eid, ci))
                if "year_scene" in ch:
                    year_scene = ch.get("year_scene")
                    if not isinstance(year_scene, dict):
                        err('%s  [%s] 선택지%d year_scene은 object여야 함' % (rel(p), eid, ci))
                    else:
                        year_index = year_scene.get("year", 0)
                        scene_id = year_scene.get("scene_id", "")
                        if not isinstance(year_index, int) or isinstance(year_index, bool) \
                                or year_index < 1 or year_index > 5 or not isinstance(scene_id, str):
                            err('%s  [%s] 선택지%d year_scene의 year/scene_id 형식 오류' \
                                % (rel(p), eid, ci))
                eff = ch.get("effects", {})
                if isinstance(eff, dict):
                    for k in eff.keys():
                        if k not in effect_keys:
                            err('%s  [%s] 선택지%d 효과 키 "%s" 를 apply_effects가 처리하지 않음 — 효과가 조용히 무시됨'
                                % (rel(p), eid, ci, k))
                opp = ch.get("opportunity", {})
                if isinstance(opp, dict):
                    for k in opp.keys():
                        if k not in OPPORTUNITY_KEYS:
                            err('%s  [%s] 선택지%d opportunity 키 "%s" 미지원' % (rel(p), eid, ci, k))
                ce = ch.get("cast_effects", {})
                if isinstance(ce, dict):
                    for pid, pe in ce.items():
                        if isinstance(pe, dict):
                            for k in pe.keys():
                                if k not in CAST_EFFECT_KEYS:
                                    err('%s  [%s] 선택지%d cast_effects.%s 키 "%s" 미지원'
                                        % (rel(p), eid, ci, pid, k))

# ══════════════════════════════════════════════════════════════
# 7) 인물 stage 상태기계 — content/meta/cast_stages.json 이 정본.
#    선언 안 된 stage를 set/read하면 ERROR (acquaint vs acquaintance,
#    trust vs trusted 같은 "같은 단계의 두 이름" 서사 모순을 잡는다)
# ══════════════════════════════════════════════════════════════
def check_cast_stages():
    sp = os.path.join(ROOT, "content", "meta", "cast_stages.json")
    if not os.path.exists(sp):
        warn("content/meta/cast_stages.json 없음 — stage 상태기계 검사 건너뜀")
        return
    canon = {k: set(v) for k, v in json.load(open(sp, encoding="utf-8")).items()
             if not k.startswith("_")}

    def check(pid, stage, where):
        if pid not in canon:
            err('%s  cast_stages.json에 선언 안 된 인물 "%s"' % (where, pid))
        elif stage not in canon[pid]:
            err('%s  %s의 stage "%s" 가 cast_stages.json에 없음 — 오타거나 같은 단계의 다른 이름 (서사 모순)'
                % (where, pid, stage))

    # JSON: cast_effects.stage (set) + conditions.cast_stage (read)
    for p in glob.glob(os.path.join(ROOT, "content", "events", "*.json")):
        try:
            evs = load_events(p)
        except Exception:
            continue
        for e in evs:
            if not isinstance(e, dict):
                continue
            where = "%s [%s]" % (rel(p), e.get("id", "?"))
            cs = e.get("conditions", {}).get("cast_stage", {})
            if isinstance(cs, dict) and cs.get("person"):
                pid = str(cs["person"])
                vals = ([cs["is"]] if "is" in cs else []) \
                     + list(cs.get("in", [])) \
                     + ([cs["not"]] if "not" in cs else [])
                for s in vals:
                    check(pid, str(s), where)
            for ch in e.get("choices", []):
                ce = ch.get("cast_effects", {})
                if isinstance(ce, dict):
                    for pid, pe in ce.items():
                        if isinstance(pe, dict) and "stage" in pe:
                            check(str(pid), str(pe["stage"]), where)

    # GD: get_cast_stage("pid") 비교가 들어간 줄의 문자열 리터럴 검사
    GD_STAGE = re.compile(r'get_cast_stage\(\s*"([a-z_]+)"\s*\)')
    for d in GD_DIRS:
        for f in glob.glob(os.path.join(ROOT, d, "**", "*.gd"), recursive=True):
            for ln_no, line in enumerate(open(f, encoding="utf-8").read().splitlines(), 1):
                if "audit-ignore" in line:
                    continue
                m = GD_STAGE.search(line)
                if not m:
                    continue
                pid = m.group(1)
                # 같은 줄의 나머지 문자열 리터럴 = 비교 대상 stage 후보
                rest = line[m.end():]
                for s in re.findall(r'"([a-z_]+)"', rest):
                    check(pid, s, "%s:%d" % (rel(f), ln_no))

# ══════════════════════════════════════════════════════════════
# 8) 인물 시간 외형 — 관계 stage와 분리된 1·3·5년 앵커 계약.
#    런타임은 이 파일에 명시된 반복 초상만 교체하며, 상황복/회상은 고정한다.
# ══════════════════════════════════════════════════════════════
def check_cast_visual_years():
    path = os.path.join(ROOT, "content", "meta", "cast_visual_years.json")
    if not os.path.exists(path):
        err("content/meta/cast_visual_years.json 없음 — 1·3·5년 외형 계약 소실")
        return
    try:
        data = json.load(open(path, encoding="utf-8"))
    except Exception as exc:
        err("content/meta/cast_visual_years.json 파싱 실패: %s" % exc)
        return

    expected_windows = [
        ("y1", 1, 96, [1, 2]),
        ("y3", 97, 192, [3, 4]),
        ("y5", 193, 240, [5]),
    ]
    windows = data.get("stage_windows", [])
    actual_windows = []
    if isinstance(windows, list):
        for row in windows:
            if isinstance(row, dict):
                actual_windows.append((
                    row.get("id"),
                    row.get("min_turn"),
                    row.get("max_turn"),
                    row.get("chapters"),
                ))
    if actual_windows != expected_windows:
        err("cast_visual_years stage_windows가 1·2장=y1, 3·4장=y3, 5장=y5 정본과 다름: %s"
            % actual_windows)

    characters = data.get("characters", {})
    if not isinstance(characters, dict):
        err("cast_visual_years characters가 Dictionary가 아님")
        return
    required_a = {"minjun", "daeun", "jiyeon", "hyunsu", "jaehyuk", "sangchul", "father"}
    declared_a = {
        cid for cid, row in characters.items()
        if isinstance(row, dict) and row.get("tier") == "A_story_anchor"
    }
    if declared_a != required_a:
        err("cast_visual_years A급 핵심 인물 집합 불일치 expected=%s actual=%s"
            % (sorted(required_a), sorted(declared_a)))

    owners = {}
    for character_id, row in characters.items():
        where = "content/meta/cast_visual_years.json [%s]" % character_id
        if not isinstance(row, dict):
            err("%s 인물 계약이 Dictionary가 아님" % where)
            continue
        tier = row.get("tier")
        if tier not in {"A_story_anchor", "B_scene_actor"}:
            err("%s 지원하지 않는 tier=%s" % (where, tier))
        if tier == "A_story_anchor":
            start_age = row.get("start_age")
            ages = row.get("anchor_ages", {})
            expected_ages = {
                "y1": start_age,
                "y3": start_age + 2 if isinstance(start_age, int) else None,
                "y5": start_age + 4 if isinstance(start_age, int) else None,
            }
            if not isinstance(start_age, int) or ages != expected_ages:
                err("%s anchor_ages는 시작 나이,+2,+4여야 함 expected=%s actual=%s"
                    % (where, expected_ages, ages))

        fixed = row.get("fixed_portraits", [])
        if not isinstance(fixed, list):
            err("%s fixed_portraits가 Array가 아님" % where)
            fixed = []
        for portrait_id in fixed:
            if portrait_id not in VALID_PORTRAITS:
                err('%s 고정 portrait "%s"가 ImageRegistry에 없음' % (where, portrait_id))

        overrides = row.get("portrait_overrides", {})
        if not isinstance(overrides, dict):
            err("%s portrait_overrides가 Dictionary가 아님" % where)
            continue
        if tier == "A_story_anchor" and not overrides:
            err("%s A급 인물인데 런타임 반복 초상 앵커가 없음" % where)
        for base_id, variants in overrides.items():
            if base_id in owners and owners[base_id] != character_id:
                err('%s portrait "%s"가 %s와 중복 소유됨'
                    % (where, base_id, owners[base_id]))
            owners[base_id] = character_id
            if base_id not in VALID_PORTRAITS:
                err('%s 기준 portrait "%s"가 ImageRegistry에 없음' % (where, base_id))
            if base_id in fixed:
                err('%s portrait "%s"가 교체와 고정에 동시에 선언됨' % (where, base_id))
            if not isinstance(variants, dict) or set(variants) != {"y3", "y5"}:
                err('%s portrait "%s"는 y3·y5 두 변형을 모두 가져야 함: %s'
                    % (where, base_id, variants))
                continue
            for stage_id in ("y3", "y5"):
                target_id = variants.get(stage_id)
                if target_id not in VALID_PORTRAITS:
                    err('%s %s target portrait "%s"가 ImageRegistry에 없음'
                        % (where, stage_id, target_id))
                if target_id == base_id:
                    err('%s %s target이 기준 portrait와 같아 시간 변화가 무효: %s'
                        % (where, stage_id, base_id))

    father = characters.get("father", {})
    if isinstance(father, dict):
        father_overrides = father.get("portrait_overrides", {})
        father_fixed = father.get("fixed_portraits", [])
        if "father_past" in father_overrides or "father_past" not in father_fixed:
            err("father_past는 2020년 고정 회상이며 시간 외형 교체 대상이 될 수 없음")

# ══════════════════════════════════════════════════════════════
# 9) 죽은 아크 이벤트 — 트리거 전용(min_turn>=9999)인데 코드/follow_up
#    어디서도 호출 안 되는 이벤트. 작성됐지만 영원히 안 뜨는 죽은 콘텐츠.
#    (← 난개발로 구버전 아크가 신버전으로 교체되며 안 지워진 잔재)
# ══════════════════════════════════════════════════════════════
def check_dead_arc_events():
    # GD 코드 전체 텍스트 (id 문자열 참조 탐색용)
    code = ""
    for d in GD_DIRS:
        for f in glob.glob(os.path.join(ROOT, d, "**", "*.gd"), recursive=True):
            code += open(f, encoding="utf-8").read()
    # follow_up 타깃 수집 (KR 이벤트)
    follow_targets = set()
    trigger_only = []   # (id, file)
    for p in glob.glob(os.path.join(ROOT, "content", "events", "*.json")):
        try:
            evs = load_events(p)
        except Exception:
            continue
        for e in evs:
            if not isinstance(e, dict):
                continue
            for key in ("follow_up", "follow_up_event"):
                v = e.get(key)
                if isinstance(v, str) and v:
                    follow_targets.add(v)
            try:
                follow_targets.update(target for target, _delay in deferred_follow_ups(e))
            except DeferredFollowUpError:
                pass
            for ch in e.get("choices", []) or []:
                v = ch.get("follow_up_event")
                if isinstance(v, str) and v:
                    follow_targets.add(v)
                try:
                    follow_targets.update(
                        target for target, _delay in deferred_follow_ups(ch))
                except DeferredFollowUpError:
                    pass
            cond = e.get("conditions", {}) or {}
            mt = cond.get("min_turn", 0)
            if isinstance(mt, (int, float)) and mt >= 9999:
                trigger_only.append((e.get("id"), p))
    # 생각정리(thoughts) on_complete.unlock_event 도 정당한 트리거 경로
    tp = os.path.join(ROOT, "content", "meta", "thoughts.json")
    if os.path.exists(tp):
        try:
            for t in json.load(open(tp, encoding="utf-8")):
                ue = (t.get("on_complete", {}) or {}).get("unlock_event")
                if isinstance(ue, str) and ue:
                    follow_targets.add(ue)
        except Exception:
            pass
    # Core Loop V2 resolves authored roots from its machine-readable bundle
    # contract rather than hard-coding every event ID in GDScript. Count only
    # executable existing_roots here; planned_scene_id remains design data and
    # must not make an unfinished event look reachable.
    v2_contract_path = os.path.join(
        ROOT, "content", "meta", "demo_core_loop_v2.json")
    if os.path.exists(v2_contract_path):
        try:
            v2_contract = json.load(
                open(v2_contract_path, encoding="utf-8"))
            for bundle in (
                    v2_contract.get("scene_bundles", {}) or {}).values():
                if not isinstance(bundle, dict):
                    continue
                for root_id in bundle.get("existing_roots", []) or []:
                    if isinstance(root_id, str) and root_id:
                        follow_targets.add(root_id)
        except Exception:
            pass
    for eid, p in trigger_only:
        if not eid:
            continue
        if ('"%s"' % eid) in code or eid in follow_targets:
            continue
        err('%s [%s] 트리거 전용(min_turn>=9999)인데 코드/follow_up 어디서도 호출 안 됨 '
            '— 영원히 안 뜨는 죽은 아크 (구버전 잔재거나 _next_arc_id 트리거 누락)'
            % (rel(p), eid))

# ══════════════════════════════════════════════════════════════
# 10) 죽은 cast-stage 분기 — 코드/조건이 비교하는 cast stage인데
#     어떤 이벤트도 그 stage를 set하지 않는 경우. 도달 불가 분기.
#     (← 다은 with_daeun 엔딩이 committed를 안 보던 버그의 거울상:
#      엔딩이 lover를 보는데 lover를 set하는 이벤트가 사라진 경우)
# ══════════════════════════════════════════════════════════════
def check_dead_cast_branches():
    # set 소스 ① 이벤트 cast_effects.stage
    set_pairs = set()
    for p in glob.glob(os.path.join(ROOT, "content", "events", "*.json")):
        try:
            evs = load_events(p)
        except Exception:
            continue
        for e in evs:
            if not isinstance(e, dict):
                continue
            srcs = [e.get("cast_effects", {})] + \
                   [c.get("cast_effects", {}) for c in e.get("choices", []) or []]
            for ce in srcs:
                if isinstance(ce, dict):
                    for pid, pe in ce.items():
                        if isinstance(pe, dict) and "stage" in pe:
                            set_pairs.add((str(pid), str(pe["stage"])))
    # set 소스 ② GameState.gd 초기/리셋 stage 리터럴 ("father":{"stage":"distant"} 등)
    gs = os.path.join(ROOT, "autoloads", "GameState.gd")
    casts_seen = set(pid for pid, _ in set_pairs)
    if os.path.exists(gs):
        gtext = open(gs, encoding="utf-8").read()
        for pid, st in re.findall(r'"([a-z_]+)"\s*:\s*\{\s*"stage"\s*:\s*"([a-z_]+)"', gtext):
            set_pairs.add((pid, st)); casts_seen.add(pid)
    # 모든 인물의 초기 unknown 은 reset 경로에서 항상 set됨
    for pid in casts_seen:
        set_pairs.add((pid, "unknown"))

    # read 소스 ① GD: get_cast_stage("pid") ... "stage"
    GD_STAGE = re.compile(r'get_cast_stage\(\s*"([a-z_]+)"\s*\)')
    for d in GD_DIRS:
        for f in glob.glob(os.path.join(ROOT, d, "**", "*.gd"), recursive=True):
            for ln_no, line in enumerate(open(f, encoding="utf-8").read().splitlines(), 1):
                if "audit-ignore" in line:
                    continue
                m = GD_STAGE.search(line)
                if not m:
                    continue
                pid = m.group(1)
                for s in re.findall(r'"([a-z_]+)"', line[m.end():]):
                    if (pid, s) not in set_pairs:
                        err('%s:%d  get_cast_stage("%s") 가 "%s" 와 비교하지만 이 stage를 '
                            'set하는 이벤트가 없음 — 도달 불가 죽은 분기'
                            % (rel(f), ln_no, pid, s))
    # read 소스 ② conditions.cast_stage (is/in/not)
    for p in glob.glob(os.path.join(ROOT, "content", "events", "*.json")):
        try:
            evs = load_events(p)
        except Exception:
            continue
        for e in evs:
            if not isinstance(e, dict):
                continue
            cs = e.get("conditions", {}).get("cast_stage", {})
            if not (isinstance(cs, dict) and cs.get("person")):
                continue
            pid = str(cs["person"])
            vals = ([cs["is"]] if "is" in cs else []) + list(cs.get("in", []))
            # "not" 비교는 set 안 돼도 의미가 없을 뿐 도달성과 무관하므로 제외
            for s in vals:
                if (pid, str(s)) not in set_pairs:
                    err('%s [%s] conditions.cast_stage 가 %s="%s" 를 요구하지만 이 stage를 '
                        'set하는 이벤트가 없음 — 절대 발동 안 됨'
                        % (rel(p), e.get("id", "?"), pid, s))

# ══════════════════════════════════════════════════════════════
# 11) 구조 부채 래칫 — write-only 플래그 / inert 이벤트 수를 baseline에
#     고정하고, 늘어나면 ERROR. (난개발이 다시 자라지 못하게 하는 톱니.
#     Phase 2 정리로 수가 줄면 baseline을 낮춰 톱니를 조인다.)
#     baseline: tools/debt_baseline.json
# ══════════════════════════════════════════════════════════════
def _gather_game_flags():
    """(set되는 플래그, 참조되는 플래그).
    write-only 오탐(정상 배선된 플래그를 죽었다고 잘못 잡는 것)을 막기 위해
    참조 판정을 넓게 잡는다: JSON 조건(flag/no_flag) + GD 코드의 모든 문자열
    리터럴(f.get/match/배열 등 간접 읽기까지 포함)."""
    game_sets, reads = set(), set()
    # 게임플레이 플래그는 이벤트 파일에서만 set/조건읽기 된다 (설정 JSON 제외 — 오탐 방지)
    for p in glob.glob(os.path.join(ROOT, "content", "events", "*.json")):
        try:
            evs = load_events(p)
        except Exception:
            continue
        for ev in evs:
            if not isinstance(ev, dict):
                continue
            gr_json = {}
            _walk_event_flags(ev, game_sets, gr_json, set(), {}, "x")
            reads |= set(gr_json.keys())
    # Declarative story prerequisites read the same GameState flags without
    # repeating them in MainGame.gd. Keep the debt ratchet aware of that
    # canonical reader so moving a gate into story_rules does not create a
    # false write-only flag.
    try:
        story_rules = json.load(open(
            os.path.join(ROOT, "content", "meta", "story_rules.json"),
            encoding="utf-8",
        ))
        for rule in story_rules.get("events", {}).values():
            prerequisites = (
                rule.get("logic", {}).get("prerequisites", {})
                if isinstance(rule, dict) else {}
            )
            if not isinstance(prerequisites, dict):
                continue
            for group in ("all", "any"):
                clauses = prerequisites.get(group, [])
                if not isinstance(clauses, list):
                    continue
                for clause in clauses:
                    path = str(clause.get("path", "")) if isinstance(clause, dict) else ""
                    if path.startswith("flags.") and len(path) > len("flags."):
                        reads.add(path[len("flags."):])
    except (OSError, ValueError, TypeError, json.JSONDecodeError):
        pass
    # 엔딩 description_if_known 키도 read — _show_ending()이 flags.get()으로 읽는다.
    # (events/*.json만 스캔하면 엔딩 변주가 읽는 플래그가 write-only로 오탐됨)
    try:
        endings = json.load(open(os.path.join(ROOT, "content", "endings.json"), encoding="utf-8"))
        for en in endings:
            if isinstance(en, dict) and isinstance(en.get("description_if_known"), dict):
                for condition_key in en["description_if_known"].keys():
                    reads |= set(_known_condition_flags(condition_key))
    except Exception:
        pass
    LIT = re.compile(r'"([A-Za-z0-9_]+)"')
    for d in GD_DIRS:
        for f in glob.glob(os.path.join(ROOT, d, "**", "*.gd"), recursive=True):
            text = open(f, encoding="utf-8").read()
            for line in text.splitlines():
                if "audit-ignore" in line:
                    continue
                for m in FLAG_SET_GD.finditer(line):
                    game_sets.add(m.group(1))
            # 코드 내 모든 문자열 리터럴을 '참조'로 간주 (보수적 — 오탐 방지)
            reads |= set(LIT.findall(text))
    return game_sets, reads

def _choice_is_inert(ch):
    if isinstance(ch.get("effects"), dict) and ch["effects"]:
        return False
    if ch.get("flags"):
        return False
    if ch.get("follow_up_event") or ch.get("deferred_follow_up"):
        return False
    if isinstance(ch.get("cast_effects"), dict) and ch["cast_effects"]:
        return False
    if isinstance(ch.get("opportunity"), dict) and ch["opportunity"]:
        return False
    return True

def check_structural_debt():
    # 1) write-only 플래그: set되지만 코드/조건 어디서도 안 읽힘
    game_sets, reads = _gather_game_flags()
    write_only = sorted(f for f in game_sets if f not in reads)
    # 2) inert 이벤트: 선택지 2개+인데 전 선택지가 기계적 영향 0
    inert = []
    for p in glob.glob(os.path.join(ROOT, "content", "events", "*.json")):
        try:
            evs = load_events(p)
        except Exception:
            continue
        for ev in evs:
            if not isinstance(ev, dict):
                continue
            chs = ev.get("choices", []) or []
            if len(chs) >= 2 and all(_choice_is_inert(c) for c in chs):
                inert.append(ev.get("id", "?"))
    metrics = {"write_only_flags": len(write_only), "inert_events": len(inert)}

    bp = os.path.join(ROOT, "tools", "debt_baseline.json")
    baseline = {}
    if os.path.exists(bp):
        try:
            baseline = json.load(open(bp, encoding="utf-8"))
        except Exception:
            baseline = {}

    print(C.B + "● 구조 부채 래칫" + C.Z)
    for k, cur in metrics.items():
        base = baseline.get(k)
        if base is None:
            print("  %s: %d  (baseline 미설정 — tools/debt_baseline.json 생성 필요)" % (k, cur))
        elif cur > base:
            err('구조 부채 증가: %s %d→%d. 새로 추가한 항목을 배선(읽기/효과)하거나 제거할 것 '
                '(의도된 증가면 tools/debt_baseline.json 갱신)' % (k, base, cur))
            print("  %s%s: %d (baseline %d) ▲%s" % (C.R, k, cur, base, C.Z))
        elif cur < base:
            print("  %s%s: %d (baseline %d) ▼ — baseline 낮춰 톱니를 조이세요%s"
                  % (C.G, k, cur, base, C.Z))
        else:
            print("  %s: %d (baseline 유지)" % (k, cur))

# ══════════════════════════════════════════════════════════════
# 8) EN/KR 조건 일치 검사 — events_en/ 파일의 conditions가
#    KR 원본과 다를 경우 WARNING. (수동 번역 시 조건 불일치 회귀 방지)
# ══════════════════════════════════════════════════════════════
def check_en_conditions():
    """EN overlay 파일이 KR 조건을 실제로 덮어씌우는 경우만 검출한다.
    EN에 "conditions" 키 자체가 없으면 KR 조건이 그대로 유지돼 안전하므로 무시."""
    kr_dir = os.path.join(ROOT, "content", "events")
    en_dir = os.path.join(ROOT, "content", "events_en")
    if not os.path.isdir(en_dir):
        return

    for en_path in glob.glob(os.path.join(en_dir, "*.json")):
        fname = os.path.basename(en_path)
        kr_path = os.path.join(kr_dir, fname)
        if not os.path.exists(kr_path):
            continue
        try:
            kr_list = json.load(open(kr_path, encoding="utf-8"))
            en_list = json.load(open(en_path, encoding="utf-8"))
        except Exception:
            continue
        kr_map = {e["id"]: e for e in kr_list if isinstance(e, dict) and "id" in e}
        en_map = {e["id"]: e for e in en_list if isinstance(e, dict) and "id" in e}
        for eid, en_ev in en_map.items():
            if eid not in kr_map:
                continue
            if "conditions" not in en_ev:
                continue  # EN에 조건 키 없음 → KR 조건 유지, 안전
            kr_cond = kr_map[eid].get("conditions", {})
            en_cond = en_ev["conditions"]
            if kr_cond != en_cond:
                warn('EN/KR 조건 불일치 [%s] %s\n    KR: %s\n    EN: %s'
                     % (fname, eid, kr_cond, en_cond))

# ══════════════════════════════════════════════════════════════
# 9) 영어 콘텐츠 한글 문자 금지 — 영어 플레이 중 한글 노출 회귀 방지
# ══════════════════════════════════════════════════════════════
def check_en_content_no_hangul():
    targets = []
    en_dir = os.path.join(ROOT, "content", "events_en")
    if os.path.isdir(en_dir):
        targets.extend(sorted(glob.glob(os.path.join(en_dir, "*.json"))))
    endings_en = os.path.join(ROOT, "content", "endings_en.json")
    if os.path.exists(endings_en):
        targets.append(endings_en)

    bad = []
    hangul_re = re.compile(r"[가-힣]")
    for path in targets:
        try:
            with open(path, encoding="utf-8") as f:
                for lineno, line in enumerate(f, 1):
                    if hangul_re.search(line):
                        bad.append("%s:%d: %s" % (rel(path), lineno, line.strip()[:160]))
                        break
        except Exception as e:
            err("영어 콘텐츠 한글 검사 실패 [%s]: %s" % (rel(path), e))

    if bad:
        err("영어 콘텐츠에 한글 문자가 남아 있습니다. 영어판은 로마자/영문 설명만 사용하세요.\n    "
            + "\n    ".join(bad[:20])
            + ("\n    ... 외 %d건" % (len(bad) - 20) if len(bad) > 20 else ""))

# ══════════════════════════════════════════════════════════════
# ══════════════════════════════════════════════════════════════
# 13) 발견 레이어 무결성 — 단서/생각정리(clues.json/thoughts.json)
#     이벤트가 주는 clue id·생각의 required_clues·unlock_event가
#     실제로 정의돼 있는지 대조 (← 오타로 조용히 죽는 추론 경로 방지)
# ══════════════════════════════════════════════════════════════
def check_clues_thoughts():
    cp = os.path.join(ROOT, "content", "meta", "clues.json")
    tp = os.path.join(ROOT, "content", "meta", "thoughts.json")
    if not os.path.exists(cp) or not os.path.exists(tp):
        return
    try:
        clue_rows = json.load(open(cp, encoding="utf-8"))
        thought_rows = json.load(open(tp, encoding="utf-8"))
    except Exception as e:
        err("clues.json/thoughts.json 파싱 실패: %s" % e)
        return
    clue_ids = set()
    for c in clue_rows:
        cid = c.get("id", "")
        if cid in clue_ids:
            err("clues.json 중복 id: %s" % cid)
        clue_ids.add(cid)
    # 이벤트가 주는 clue id가 실제로 존재하는지
    for p in glob.glob(os.path.join(ROOT, "content", "events", "*.json")):
        try:
            evs = load_events(p)
        except Exception:
            continue
        for e in evs:
            if not isinstance(e, dict):
                continue
            for ch in e.get("choices", []) or []:
                for cid in ch.get("clues", []) or []:
                    if str(cid) not in clue_ids:
                        err("%s [%s] 없는 단서 id 부여: %s (clues.json에 없음)"
                            % (rel(p), e.get("id", "?"), cid))
    # 생각의 required_clues / unlock_event 검증
    thought_ids = set()
    for t in thought_rows:
        tid = t.get("id", "")
        if tid in thought_ids:
            err("thoughts.json 중복 id: %s" % tid)
        thought_ids.add(tid)
        for req in t.get("required_clues", []) or []:
            if str(req) not in clue_ids:
                err("thoughts.json [%s] 없는 required_clue: %s" % (tid, req))
        ue = (t.get("on_complete", {}) or {}).get("unlock_event")
        if ue and not DataRegistry_has_event(ue):
            err("thoughts.json [%s] unlock_event 없는 이벤트: %s" % (tid, ue))

_ALL_EVENT_IDS = None
def DataRegistry_has_event(eid):
    global _ALL_EVENT_IDS
    if _ALL_EVENT_IDS is None:
        _ALL_EVENT_IDS = set()
        for p in glob.glob(os.path.join(ROOT, "content", "events", "*.json")):
            try:
                for e in load_events(p):
                    if isinstance(e, dict) and e.get("id"):
                        _ALL_EVENT_IDS.add(e["id"])
            except Exception:
                pass
    return eid in _ALL_EVENT_IDS

def check_dik_shadowing():
    """description_if_known 섀도잉 — 첫 매치 키가 뒤 키를 영원히 가리는 죽은 변주 검출.
    ① 앞 키가 이벤트 트리거 필수 플래그(conditions.flag)면 항상 매치 → 뒤 키 전부 사망.
    ② 뒤 키의 모든 세터 선택지가 앞 키도 함께 set(부분집합)이면 뒤 키 완전 섀도잉.
    (2026-07-02 도입 시점에 denied_sangchul_mirror 죽은 변주 1건 검출·수정)"""
    setters = {}
    dik_owners = []  # (owner_label, dik_dict, trigger_flag)
    for f in glob.glob(os.path.join(ROOT, "content", "events", "*.json")):
        try:
            evs = load_events(f)
        except Exception:
            continue
        for e in evs:
            if not isinstance(e, dict):
                continue
            for ci, c in enumerate(e.get("choices", []) or []):
                for fl in (c.get("flags") or []):
                    setters.setdefault(fl, set()).add((e.get("id"), ci))
            dik = e.get("description_if_known")
            if isinstance(dik, dict) and len(dik) >= 2:
                dik_owners.append(("event:" + str(e.get("id")), dik,
                                   (e.get("conditions") or {}).get("flag")))
            memory_dik = e.get("description_memory_if_known")
            if isinstance(memory_dik, dict) and len(memory_dik) >= 2:
                dik_owners.append(("event-memory:" + str(e.get("id")), memory_dik,
                                   (e.get("conditions") or {}).get("flag")))
    try:
        for e in json.load(open(os.path.join(ROOT, "content", "endings.json"), encoding="utf-8")):
            dik = e.get("description_if_known") if isinstance(e, dict) else None
            if isinstance(dik, dict) and len(dik) >= 2:
                dik_owners.append(("ending:" + str(e.get("id")), dik, None))
    except Exception:
        pass
    for owner, dik, trig in dik_owners:
        keys = list(dik.keys())
        for i, late in enumerate(keys):
            late_flags = set(_known_condition_flags(late))
            for early in keys[:i]:
                early_flags = set(_known_condition_flags(early))
                trigger_flags = set(_known_condition_flags(trig))
                if trigger_flags and early_flags and early_flags.issubset(trigger_flags):
                    errors.append("dik 섀도잉: %s의 '%s'는 트리거 필수 키 '%s' 뒤라 영원히 발화 불가 — 앞으로 이동할 것" % (owner, late, early))
                elif early_flags and early_flags.issubset(late_flags):
                    errors.append("dik 섀도잉: %s의 복합 조건 '%s'는 더 넓은 선행 조건 '%s' 뒤라 발화 불가 — 구체 키를 앞으로" % (owner, late, early))
                elif len(late_flags) == 1 and len(early_flags) == 1:
                    late_flag = next(iter(late_flags))
                    early_flag = next(iter(early_flags))
                    ls, es = setters.get(late_flag, set()), setters.get(early_flag, set())
                    if ls and ls.issubset(es):
                        errors.append("dik 섀도잉: %s의 '%s'는 '%s'와 항상 함께 set되는데 뒤 순서라 발화 불가 — 구체 키를 앞으로" % (owner, late, early))

def main():
    print(C.BOLD + "═══ 강남드림 정적 감사 ═══" + C.Z)
    check_gdscript()
    check_deprecated()
    check_events()
    check_romance_visual_manifest()
    check_flags()
    check_serialize()
    check_event_registry_coverage()
    check_event_keys()
    check_cast_stages()
    check_cast_visual_years()
    check_dead_arc_events()
    check_dead_cast_branches()
    check_structural_debt()
    check_dik_shadowing()
    check_en_conditions()
    check_en_content_no_hangul()
    check_clues_thoughts()

    if errors:
        print("\n" + C.R + C.BOLD + "● ERROR (%d)" % len(errors) + C.Z)
        for m in errors:
            print(C.R + "  ✗ " + C.Z + m)
    if warns:
        print("\n" + C.Y + C.BOLD + "● WARNING (%d)" % len(warns) + C.Z)
        for m in warns:
            print(C.Y + "  ! " + C.Z + m)
    if not errors and not warns:
        print(C.G + "\n✓ 모순 없음 — 깨끗합니다." + C.Z)

    print()
    print("요약: %sERROR %d%s, %sWARNING %d%s"
          % (C.R, len(errors), C.Z, C.Y, len(warns), C.Z))
    sys.exit(1 if errors else 0)

if __name__ == "__main__":
    main()
