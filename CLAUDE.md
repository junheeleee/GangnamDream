# CLAUDE.md — 강남드림 (Gangnam Dream)

Codex / Claude Code 세션 시작 시 이 파일을 읽고 프로젝트 컨텍스트를 파악한다.

---

## 프로젝트 개요

- **장르**: 한국 현대 생활 로그라이크 텍스트 RPG
- **엔진**: Godot 4.6 (GDScript)
- **프로젝트 경로**: `/Users/junheelee/Documents/GitHub/GangnamDream/project.godot`
- **현재 단계**: Prototype → Playable Alpha 전환 중
- **주요 언어**: 한국어 (UI, 이벤트, 뉴스, 설명)

---

## 디렉토리 구조

```
GangnamDream/
├── CLAUDE.md                  ← 이 파일 (Codex 컨텍스트)
├── project.godot
├── autoloads/                 ← 전역 싱글턴 (Godot autoload)
│   ├── DataRegistry.gd        # JSON 콘텐츠 로더 & 인덱스
│   ├── GameState.gd           # 런 상태, 스탯, 돈, 플래그, 직업, 관계, 포트폴리오
│   ├── EventManager.gd        # 조건/가중치/쿨다운/연쇄 이벤트
│   ├── NewsManager.gd         # 월별 뉴스 생성 & 시장 영향
│   ├── MetaProgression.gd     # 런 히스토리, 해금, 업적
│   └── SaveManager.gd         # 자동저장 + 다중 슬롯
├── content/                   ← 모든 게임 데이터 (JSON)
│   ├── events/
│   │   ├── life_events.json        # 100개 일반 현대 생활 이벤트
│   │   ├── investment_events.json  # 30개 투자 이벤트
│   │   ├── relationship_events.json # 30개 관계 이벤트
│   │   └── hidden_events.json      # 20개 히든/희귀 이벤트
│   ├── assets.json            # 투자 자산 정의
│   ├── jobs.json              # 직업 15개
│   ├── items.json             # 아이템 30개
│   ├── endings.json           # 엔딩 10개
│   ├── news_templates.json    # 뉴스 템플릿 79개
│   └── meta/default_meta.json # 메타 진행도 초기값
├── systems/                   ← 게임 시스템 스크립트
│   ├── InvestmentSystem.gd    # 매수/매도, 변동성, 버블, 폭락
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
└── docs/                      ← 프로젝트 문서 (세션마다 업데이트)
    ├── WORK_LOG.md            # 날짜별 작업 기록
    ├── RELEASE_NOTES.md       # 버전별 변경사항
    ├── DECISIONS.md           # 설계 결정 근거
    ├── BALANCE.md             # 밸런스 조정 이력
    ├── BUILD_NOTES.md         # 빌드/테스트 기록
    ├── QA_CHECKLIST.md        # QA 체크리스트
    ├── REQUIREMENTS.md        # 시스템 요구사항
    ├── ROADMAP.md             # 개발 로드맵
    ├── VISION.md              # 게임 정체성 & 디자인 원칙
    └── IP_BIBLE.md            # 톤, 세계관, 금지사항
```

---

## 핵심 설계 규칙

### GDScript
- 모든 게임 데이터는 `content/` 폴더의 JSON으로 관리. 스크립트에 하드코딩 금지.
- 전역 상태는 `GameState` autoload에만 저장.
- 시스템 스크립트(`systems/`)는 `GameState`를 읽고 쓰되 서로 직접 참조하지 않는다.
- UI는 `MainGame.gd`에서 `_refresh_all()`로 일괄 갱신.
- `stats_changed` 시그널이 발생하면 `_refresh_all()` 자동 호출.

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
    "has_job": true, "flag": "flag_name"
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
      "relationship_effects": [],
      "investment_effects": [],
      "flags": [],
      "follow_up_event": "",
      "result_text": "선택 후 결과 텍스트 (1-3문장)"
    }
  ]
}
```

### 엔딩 ID (GameState → endings.json 매핑)
| GameState 호출 | endings.json id |
|---|---|
| `finish_run("burnout")` | `burnout` |
| `finish_run("mental_break")` | `mental_break` |
| `finish_run("bankruptcy")` | `bankruptcy` |
| `finish_run("stable_success")` | `stable_success` |
| `finish_run("ordinary_life")` | `ordinary_life` |
| `finish_run("gangnam_dream")` | `gangnam_dream` |

특수 조건 엔딩(플래그/중독 등): `crypto_ghost`, `startup_exit`, `political_fix`, `lonely_rich`

---

## 개발 워크플로

### 세션 시작
1. 이 파일(`CLAUDE.md`)을 읽는다.
2. `docs/WORK_LOG.md` 최근 항목으로 현재 상태 파악.
3. `docs/ROADMAP.md`로 다음 우선순위 확인.

### 세션 종료 (매 작업 후 필수)
1. `docs/WORK_LOG.md` — 날짜 + 작업 내용 추가.
2. `docs/RELEASE_NOTES.md` — 변경사항이 있으면 `## Unreleased`에 항목 추가.
3. `docs/DECISIONS.md` — 설계 결정이 있으면 날짜 + 근거 기록.
4. `docs/BALANCE.md` — 수치 조정이 있으면 Change Log 항목 추가.
5. `docs/BUILD_NOTES.md` — 빌드/테스트 결과가 있으면 기록.

### JSON 수정 후
- Python으로 JSON 문법 검증: `python3 -c "import json; json.load(open('파일.json'))"`
- 엔딩 ID 변경 시 GameState.gd의 `check_game_over()`와 endings.json 동기화 확인.

### 새 이벤트 추가
- `id`는 `snake_case`, 고유해야 함.
- `result_text`는 반드시 채울 것 (빈 문자열 금지).
- `cooldown`은 최소 3 이상 권장.
- `conditions`가 없으면 `{}`.

---

## 현재 밸런스 기준값 (Prototype)

| 항목 | 값 |
|---|---|
| 시작 자금 | 1,000,000원 |
| 시작 나이 | 20세 |
| 기본 고정 지출 | 650,000원/월 |
| 건강/정신력 초기값 | 70 |
| 스트레스 초기값 | 25 |
| 월별 스트레스 자연 증가 | +2 |
| 강남드림 조건 | 총자산 20억 이상 |
| 파산 조건 | 현금 -3000만 이하 |
| 은퇴 조건 | 나이 65세 |

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
