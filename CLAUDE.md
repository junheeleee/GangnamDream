# CLAUDE.md — 강남드림 (Gangnam Dream)

> **세션 시작 시 이 파일을 가장 먼저 읽는다. 30초 안에 현재 상태를 파악하고 작업을 시작한다.**

---

## 🔴 현재 상태 (매 세션 종료 시 업데이트)

| 항목 | 내용 |
|---|---|
| **단계** | Phase 1 — 핵심 루프 완성 |
| **최근 완료** | 1-A 행동 시스템 개편 + 1-B 루트/칭호 시스템 |
| **다음 작업** | 1-C: 거주지별 전용 이벤트 (고시원/반지하 처절함 등 각 2-3개) |
| **마지막 업데이트** | 2026-05-28 |

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

- **한 줄 정의**: 서울 고시원 100만원으로 시작해 65세까지 자산 20억을 만드는 한국 현대 생활 로그라이크
- **장르**: 텍스트 RPG + 로그라이크
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
│   ├── RivalSystem.gd         # 라이벌 캐릭터 매달 진행
│   └── SaveManager.gd         # 자동저장 + 다중 슬롯
├── content/
│   ├── events/
│   │   ├── life_events.json        # ~113개 일반 이벤트
│   │   ├── investment_events.json  # 30개 투자 이벤트
│   │   ├── relationship_events.json # 30개 관계 이벤트
│   │   └── hidden_events.json      # 20개 히든/희귀 이벤트
│   ├── assets.json            # 투자 자산
│   ├── jobs.json              # 직업 15개
│   ├── items.json             # 아이템 30개
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
│   ├── StartMenu.tscn / .gd   # 시작 화면, 특성 선택, 저장 슬롯
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
| 시작 자금 | 1,000,000원 |
| 시작 나이 | 20세 |
| 기본 고정 지출 | 650,000원/월 |
| 건강/정신력 초기값 | 70 |
| 스트레스 초기값 | 25 |
| 월별 스트레스 자연 증가 | +2 |
| 강남드림 조건 | 총자산 20억 이상 |
| 파산 조건 | 현금 -3,000만 이하 |
| 은퇴 조건 | 나이 65세 |
