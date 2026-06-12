# CLAUDE.md — 강남드림 (Gangnam Dream)

> **세션 시작 시 이 파일을 가장 먼저 읽는다. 30초 안에 현재 상태를 파악하고 작업을 시작한다.**

---

## 🔴 현재 상태 (매 세션 종료 시 업데이트)

| 항목 | 내용 |
|---|---|
| **단계** | **콘텐츠 심화** — 죽은 플래그 → 콜백 이벤트 연결 작업 중 |
| **최근 완료** | **콜백 이벤트 배치 17~19 완성** — 44개 추가. 버그픽스 3건 (cafe_00 무직텍스트/finance_012 max_money/season_lunar_new_year no_job). 배치 1~9 총 131개 콜백 이벤트 완성. |
| **다음 작업** | **콜백 10차 배치** — 잔여 dead flag: father_going_soon / startup_exit / startup_founded / startup_growing / jobswitch_took/declined/hesitated / headhunted / lied_at_reunion / came_clean_to_friend / deleted_gambling_apps / hit_rock_bottom / promised_father_gangnam / took_gray_tip / took_high_road |
| **마지막 업데이트** | 2026-06-12 (콜백 배치 17~19 완성, 버그픽스 3건) |

**세션 시작 시 위 "다음 작업"부터 시작한다. 유저가 다른 지시를 하면 그쪽 우선.**

---

## 세션 프로토콜

### 시작 (3분 이내)
1. 이 파일 (`CLAUDE.md`) — 현재 상태 블록 확인 ✓ (지금 읽는 중)
2. `docs/ROADMAP.md` — 현재 단계 `[ ]` 항목 확인
3. `docs/WORK_LOG.md` 최근 3개 항목 — 지난 세션 마무리 상태 확인
4. **유저 지시가 없으면 "다음 작업"부터 바로 시작**

### 종료 (매 작업 후 필수)
1. `CLAUDE.md` 현재 상태 블록 업데이트 (다음 작업 갱신)
2. `docs/ROADMAP.md` — 완료 항목 `[x]` 처리
3. `docs/WORK_LOG.md` — 날짜 + 작업 내용 추가
4. `docs/RELEASE_NOTES.md` — `## Unreleased`에 변경사항 추가
5. `docs/DECISIONS.md` — 설계 결정이 있으면 날짜 + 근거 기록
6. 수치 조정 시 `docs/BALANCE.md` 업데이트

### ⭐ 커밋 전 정적 감사 (필수)
```bash
./tools/audit.sh
```
플레이 없이 옛/새 시스템 모순을 잡는다:
1. **dangling 동적 호출** — `self.call("_x")`/`Callable(self,"_x")`/헬퍼에 넘긴 함수명이
   실제 정의돼 있는지 (← 문자열 호출이라 Godot 파싱을 통과해버리는 "눌러도 무반응" 버그)
2. **폐기 키워드** — 옛 설계 잔재(시작 나이·옛 마감·은퇴·가짜 랜덤 인물 이름 등) <!-- audit-ignore -->
   (코드 전체 + CLAUDE.md·STORY_BIBLE.md만 검사. 과거 로그 문서는 제외)
3. **이벤트 JSON 무결성** — 파싱/중복 id/없는 follow_up/없는 portrait·background·cg/빈 result_text
4. **플래그 교차 검증** — 코드/이벤트 조건이 읽는 플래그(`f.get`/`flags.get`/`flag`/`no_flag`/
   `cast_has_flag`)를 실제로 누가 set하는지 대조 (← 오타·이름 불일치로 패널/분기/이벤트가
   조용히 죽는 버그. 2026-06-10 도입 시점에 잠재 버그 15개 일괄 검출)
5. **serialize 완전성** — GameState var 선언 vs serialize() 키 대조 (← 저장 누락으로 로드 시
   조용히 리셋. transient 변수는 audit.py SERIALIZE_EXEMPT에 등록)
6. **이벤트 키 화이트리스트** — effects/conditions/opportunity/cast_effects 키를
   apply_effects·_check_conditions가 실제 처리하는 키와 대조 (← 오타 키가 조용히 무시되는
   버그. 2026-06-11 도입 시점에 죽은 효과 5건·죽은 조건 2건 검출)
7. **인물 stage 상태기계** — `content/meta/cast_stages.json`이 정본. 선언 안 된 stage를
   set/read하면 ERROR (← acquaint vs acquaintance 같은 "같은 단계의 두 이름" 서사 모순.
   **새 stage 추가 시 이 파일에 먼저 선언할 것**)
8. **밸런스 회귀 밴드** — balance_check.py가 핵심 정책 시뮬로 30억 도달률·실패율 밴드 검증
   (← 경제 파라미터 변경의 의도치 않은 파급. 의도된 변경이면 BALANCE.md 기록 + 밴드 갱신)
9. **Godot 헤드리스 파싱** (로컬 Godot 필요 — 없으면 CI가 수행)

ERROR 0 이면 통과. **새 함수·이벤트·인물·플래그·stage 추가 후 반드시 돌릴 것.**
푸시하면 GitHub Actions(`.github/workflows/ci.yml`)가 같은 감사 + Godot 컴파일/SimRun을 돌린다.

### JSON 수정 후
```bash
python3 -c "import json; json.load(open('파일.json'))"
```

### 새 이벤트 추가 시 체크
- `id`는 `snake_case`, 전체에서 고유
- `result_text` 반드시 채울 것 (빈 문자열 금지)
- `cooldown` 최소 3 이상 권장
- `conditions`가 없으면 `{}`

---

## 프로젝트 개요

- **한 줄 정의**: 33세 백수 김민준이 통장 50만원으로 시작해 5년(38세) 안에 자산 30억을 모아 강남에 입성하는 한국 사회 리얼리티 인터랙티브 드라마
- **장르**: 인터랙티브 드라마 / 비주얼노벨 (드라마처럼 "보는" 게임)
- **엔진**: Godot 4.6 (GDScript)
- **주요 언어**: 한국어 (UI, 이벤트, 뉴스, 설명)
- **설계 바이블**: `docs/GAME_DESIGN.md` — 반드시 읽고 기능을 추가할 것

---

## 디렉토리 구조

```
GangnamDream/
├── CLAUDE.md                  ← 이 파일 (항상 먼저 읽기)
├── project.godot
├── autoloads/
│   ├── DataRegistry.gd        # JSON 콘텐츠 로더 & 인덱스
│   ├── GameState.gd           # 런 상태, 스탯, 돈, 플래그, 직업, 관계, 포트폴리오
│   │                          # + route_orthodox/unorthodox, month_focus, housing_months
│   ├── EventManager.gd        # 조건/가중치/쿨다운/연쇄 이벤트
│   ├── NewsManager.gd         # 월별 뉴스 생성 & 시장 영향
│   ├── MetaProgression.gd     # 런 히스토리, 업적, 칭호(29개) 해금
│   └── SaveManager.gd         # 자동저장 + 다중 슬롯
├── content/
│   ├── events/
│   │   ├── life_events.json        # ~113개 일반 이벤트
│   │   ├── investment_events.json  # 30개 투자 이벤트
│   │   ├── relationship_events.json # 30개 관계 이벤트
│   │   └── hidden_events.json      # 20개 히든/희귀 이벤트
│   ├── assets.json            # 투자 자산
│   ├── jobs.json              # 직업 15개
│   ├── items.json             # 아이템 28개
│   ├── endings.json           # 엔딩 10개
│   ├── news_templates.json    # 뉴스 템플릿 79개
│   └── meta/default_meta.json # 메타 초기값 (unlocked_titles 포함)
├── systems/
│   ├── InvestmentSystem.gd    # 매수/매도, 레버리지, 마진콜, 배당
│   ├── JobSystem.gd           # 취업/퇴직/승진
│   ├── RelationshipSystem.gd  # 관계 패시브, 소멸
│   ├── InventorySystem.gd     # 아이템 구매/사용
│   └── EndingSystem.gd        # 엔딩 조회 & 점수
├── scenes/
│   ├── StartMenu.tscn / .gd   # 시작 화면, 저장 슬롯 (드라마 모드: 고정 시작)
│   └── MainGame.tscn / .gd    # 메인 대시보드 UI
├── ui_components/
│   ├── StatRow.gd
│   └── NotificationToast.gd
└── docs/
    ├── GAME_DESIGN.md         ← 게임 설계 바이블 (반드시 읽기)
    ├── ROADMAP.md             ← 개발 단계 & 체크박스
    ├── WORK_LOG.md            ← 날짜별 작업 기록
    ├── RELEASE_NOTES.md       ← 버전별 변경사항
    ├── DECISIONS.md           ← 설계 결정 근거
    ├── BALANCE.md             ← 밸런스 조정 이력
    └── BUILD_NOTES.md         ← 빌드/테스트 기록
```

---

## 핵심 설계 규칙 (불변)

### GDScript 아키텍처
- 모든 게임 데이터는 `content/` JSON으로 관리. 스크립트 하드코딩 금지.
- 전역 상태는 `GameState` autoload에만 저장.
- 시스템 스크립트(`systems/`)는 `GameState`를 읽고 쓰되 서로 직접 참조하지 않는다.
- UI는 `MainGame.gd`에서 `_refresh_all()`로 일괄 갱신.
- `stats_changed` 시그널 발생 → `_refresh_all()` 자동 호출.

### JSON 이벤트 형식
```json
{
  "id": "unique_snake_case_id",
  "title": "이벤트 제목",
  "description": "상황 설명 (2-4문장)",
  "category": "finance|family|jobs|social|gambling|health|investment|relationship|disasters|politics|comedy|military",
  "rarity": "common|uncommon|rare|legendary",
  "weight": 1.0,
  "hidden": false,
  "conditions": {
    "min_money": 0, "max_stress": 100, "min_intelligence": 0,
    "has_job": true, "flag": "flag_name",
    "min_route_orthodox": 0, "min_route_unorthodox": 0,
    "month_focus": "투자"
  },
  "tags": ["tag1", "tag2"],
  "cooldown": 6,
  "choices": [
    {
      "text": "선택지 텍스트",
      "effects": {
        "money": 100000, "health": -5, "mental": 3,
        "stress": -2, "intelligence": 1, "social_skill": 0,
        "investment_skill": 2, "luck": 0, "reputation": 1
      },
      "flags": ["flag_to_set"],
      "follow_up_event": "",
      "result_text": "선택 후 결과 텍스트 (1-3문장, 빈 문자열 금지)"
    }
  ]
}
```

### 엔딩 ID 매핑
| `finish_run()` 호출 | endings.json id |
|---|---|
| `finish_run("burnout")` | `burnout` |
| `finish_run("mental_break")` | `mental_break` |
| `finish_run("bankruptcy")` | `bankruptcy` |
| `finish_run("stable_success")` | `stable_success` |
| `finish_run("ordinary_life")` | `ordinary_life` |
| `finish_run("gangnam_dream")` | `gangnam_dream` |

특수 엔딩: `crypto_ghost`, `startup_exit`, `political_fix`, `lonely_rich`

---

## 밸런스 기준값

| 항목 | 값 |
|---|---|
| 시작 자금 | 500,000원 (백수, 통장 50만원) |
| 시작 나이 | **33세** (김민준) |
| 마감 기한 | **38세 = 5년 = 60턴** (`age >= 38` 타임리밋) |
| 기본 고정 지출 | 650,000원/월 (고시원) → 원룸/빌라/아파트 전세 (HOUSING_DATA) |
| 건강 초기값 | 65 / 정신력 60 |
| 스트레스 초기값 | 35 |
| 월별 스트레스 자연 증가 | +3 (무직 시 추가 +3, 총 +6) |
| 월별 건강 자동 감소 | -2 |
| 월별 정신력 자동 감소 | -3 (무직 시 추가 -2, 총 -5) |
| **강남 입성(승리) 조건** | **총자산 30억 이상** → `finish_run("gangnam_dream")` |
| 파산 조건 | 순자산(현금+포트폴리오-대출) -1억 이하 (부채 나락 -2억) |
| 대출 | 신용등급(1~10, 직장·근속·소득·자산·부채로 산정)이 한도·금리 결정. 1금융 월 0.4~0.88%·소득 18~6배·7등급 이내 / 2금융 월 1.28~2.0%·4,600만~1,000만. 변동금리 |

---

## 알려진 미구현 / 다음 작업

현재 코드 레이어는 모두 구현 완료. 아래는 로컬 Godot 필요 항목:

- **QA 플레이스루** — 실제 실행 후 스크립트 에러·UI 레이아웃·클릭 흐름 검증
- **빌드/Export 패키징** — Godot Export Templates 설치 후 Web/PC 빌드
- **스토어 페이지 소재** — 스크린샷, 설명문, 태그 (선택사항)

### 구현 완료 항목 (이전 TODO)
- ✅ `NotificationToast.gd` 연동
- ✅ 엔딩 화면 메타 진행도 업적 해금 표시
- ✅ `appearance` 스탯 효과 (직업 요건 3종 + 연애 호감도 감소 완화)
- ✅ 직업별 이벤트 트리거 조건 (`min_job_tier`, `max_job_tier`, `job_category`)
- ✅ 투자 차트 히스토리 시각화 (스파크라인, 수익률 요약)
- ✅ 관계 패널 능동 상호작용 (유형별 전용 선택지 모달)
- ✅ 특수 엔딩 6종 도달 경로 구현
- ✅ 배경 이미지 19종 이벤트 자동 매핑
- ✅ 엔딩 화면 배경 전환 (penthouse/burnout/gangnam_night/rooftop)
- ✅ FM SFX 14종 + BGM 6트랙 (AudioManager + BGMPlayer)
- ✅ Pretendard 한국어 폰트 적용
- ✅ 런 테마 시스템 (매 런 카테고리 2개 부스트)
- ❎ 트레이트(특성) 시스템 — 드라마 피벗으로 제거. 성향(tendency) 자각 시스템으로 대체.
