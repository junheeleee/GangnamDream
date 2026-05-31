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

ERROR가 하나라도 있으면 exit code 1.  WARNING은 통과(코드 0)하되 보고만 한다.
"""
import json, os, re, sys, glob

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
CAST_IDS = set()
if os.path.exists(img_path):
    itext = open(img_path, encoding="utf-8").read()
    VALID_PORTRAITS  = dict_keys_from_const(itext, "PORTRAITS")
    VALID_BACKGROUNDS = dict_keys_from_const(itext, "BACKGROUNDS")
    VALID_CG         = dict_keys_from_const(itext, "CG")
    CAST_IDS         = dict_keys_from_const(itext, "PERSON_INFO")  # 인물 id 집합

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

    for p, evs in events_by_file.items():
        for e in evs:
            eid = e.get("id", "?")
            # 이미지 참조 검증 (없으면 placeholder로 폴백되지만 오타 가능성)
            port = e.get("portrait")
            if port and VALID_PORTRAITS and port not in VALID_PORTRAITS:
                warn('%s  [%s] 모르는 portrait id → "%s"' % (rel(p), eid, port))
            bg = e.get("background")
            if bg and VALID_BACKGROUNDS and bg not in VALID_BACKGROUNDS:
                warn('%s  [%s] 모르는 background id → "%s"' % (rel(p), eid, bg))
            cg = e.get("cg")
            if cg and VALID_CG and cg not in VALID_CG:
                warn('%s  [%s] 모르는 cg id → "%s"' % (rel(p), eid, cg))
            # choices
            for ci, ch in enumerate(e.get("choices", [])):
                fu = ch.get("follow_up_event", "")
                if fu and fu not in known_ids:
                    err('%s  [%s] 선택지%d follow_up_event "%s" 가 존재하지 않음 (스토리 체인 끊김)'
                        % (rel(p), eid, ci, fu))
                if "result_text" in ch and not str(ch["result_text"]).strip():
                    warn('%s  [%s] 선택지%d result_text 가 비어 있음' % (rel(p), eid, ci))
                ce = ch.get("cast_effects", {})
                if isinstance(ce, dict):
                    for pid in ce.keys():
                        if CAST_IDS and pid not in CAST_IDS:
                            warn('%s  [%s] 선택지%d 모르는 cast 인물 → "%s"' % (rel(p), eid, ci, pid))

# ══════════════════════════════════════════════════════════════
def main():
    print(C.BOLD + "═══ 강남드림 정적 감사 ═══" + C.Z)
    check_gdscript()
    check_deprecated()
    check_events()

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
