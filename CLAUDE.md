# CLAUDE.md — 강남드림 (Gangnam Dream)

> **세션 시작 시 이 파일을 가장 먼저 읽는다. 30초 안에 현재 상태를 파악하고 작업을 시작한다.**
> 상세 이력: `docs/WORK_LOG.md` · 설계 결정: `docs/DECISIONS.md` · 2026-07-07 이전 상태표 전문: `docs/STATE_LOG_ARCHIVE.md`

---

## 🔴 현재 상태

| 항목 | 내용 |
|---|---|
| **목표 지표** | Steam 유저 평가 **"압도적으로 긍정적"(95%+)**. (Metacritic 90은 방향이지 지표가 아님 — DECISIONS 2026-07-07) |
| **상품 정의** | "강남 가는 게임"이 아니라 **"영혼이 색으로 무너지는 걸 지켜보는 게임"** — MORAL_TINT + description_if_known(재독) + 잃을 수 있는 결혼. 마케팅·데모·트레일러 전부 이 하나로 정렬. |
| **최종 품질 게이트** | 전 영역 기준점·P0~P3·메타90/100만장 검증 조건은 `docs/MASTER_RELEASE_AUDIT.md`. 콘텐츠 수량이 아니라 블랙박스 플레이·한영 패리티·패드 과업·외부 기억/전환 증거로 판정. |
| **이번 스프린트 (5레버)** | ①**루프 압축(몽타주)** ✅완료 ②**데모 훅** ✅완료(콜드오픈+SNS dik 양변주) ③**클립 가능성** ✅완료(시간의 기록 비주얼 카드+데모판) ④**EN 일관성** ✅완료 ⑤**오디오 정체성** ✅완료(moral band BGM 질감 전이+선택적 3변주 슬롯) |
| **최근 진행** | **2026-07-19 (Codex)** — ORDER-17 데이터 모딩 3·4층을 완료했다. 커스텀 랜덤 사건과 안전한 내장 개작, 기존 ID/스키마 전용 밸런스 프리셋, 인게임 활성/순서 목록, 고정 3밴드 Moral 색 테마와 색각 보정·고대비 프리셋, 배포 검증기를 연결했다. 격리 런타임은 잘못된 플래그·빈 문구·자료형/중첩 스키마 변경을 거부하고 양방향 로드 순서·전 계층 폴백·세이브 표식을 통과했다. 1280×720/800 설정 렌더와 일본어 UI 2,194키도 통과했다. 스크립트 모딩은 계속 금지다. |
| **이전 주요** | **2026-07-19 (Codex)** — 실제 첫 24주에서 재컷 3회, 이동 계약 누락 6회, 무관 갈등 교체 5회를 0으로 수렴하고 KO/EN 47사건의 게임플레이 상태를 일치시켰다. 전체 이력 → `docs/WORK_LOG.md` |
| **다음 작업** | **ORDER-28/22 `[~]` 인간 체감 수렴 P0** — 자동 장면 호흡과 한영 결정론 게이트는 통과했다. 다음 권위 게이트는 사용자의 정상 독해 데모 재플레이이며, 그 전에도 승인된 전 범위 개선은 계속하되 새 콘텐츠를 늘리지 않고 `docs/DEMO_SCENE_FLOW_AUDIT.md`의 연결 계약과 5장 인과 스파인을 보존한다. 자동 증거를 재미 GO로 오인하지 않는다. |
| **마지막 업데이트** | 2026-07-19 (Codex: ORDER-17 데이터 모드·프리셋·Moral 접근성 테마·검증기 완료) |

**세션 시작 시 위 "다음 작업"부터. 유저가 다른 지시를 하면 그쪽 우선.**

### 🔁 데모 집중 체제 (2026-07-14 유저 지시 — "데모만 칼같이 갈아보자")
**모든 작업의 우선 필터: "데모(t≤24)를 더 재밌게 하는가."** 루프: ①유저가 데모 실플레이 → ②`docs/DEMO_FIXLOG.md`에 라운드 기록(유저 노트 원문 보존) → ③Claude 진단·수리 오더 → ④Codex 수리·빌드 → ⑤다음 라운드. **데모 GO(유저 판정)가 나와야** 번역(21)·트레일러 최종컷(11)·전체 범위 폴리싱이 재개된다. 데모 밖 오더는 데모 작업이 비는 틈에만.

**2026-07-18 사용자 우선순위 갱신:** 데모 플레이 가능 여부와 판정을 기다리지 않고 게임 전체 개선을 계속한다. 위 NO-GO와 데모 품질 필터는 유지하지만, 승인된 ORDER-28 전 범위 인과 편집·정합 수리·출시 게이트를 차단하지 않는다.

### 🧊 콘텐츠 동결 (2026-07-13 선언 — ORDER-13·19 완료로 조건 충족)
**이 시점부터 신규 기능·신규 콘텐츠 금지.** 허용: 수리(사실 정렬·버그·판정 집행), QA·게이트, 번역, 마케팅 산출물, 승인된 인프라(ORDER-12·15·16·18A). 새 아이디어는 전부 `docs/POST_LAUNCH_NOTES.md`(v1.x/DLC 백로그)로 — 추가가 아니라 기록한다. 해제 권한: 유저 직접 지시만. **예외:** 유저가 2026-07-16 ORDER-28의 전체 루프·챕터·모달·엔딩 재편을 직접 승인했다. 이 예외는 새 콘텐츠 양산이 아니라 기존 1,505개 사건의 편집과 데모 수직 슬라이스 검증에만 적용한다.

### 다듬기 이후의 3대 목표 게이트 (2026-07-07 유저 지시 — 모든 요소가 다듬어진 뒤 이 셋으로 판정)
1. **데모(6개월)가 사람을 끌어당기는가** — 콜드오픈·대포통장 타이머·SNS dik·다은 라인 시동(t9~23)이 데모의 무기. 약점: 미연시 소구가 데모 범위 밖(연애는 t24 이후) → 스토어/데모 엔딩 카피로 예고 보완.
2. **스팀 환불선(2시간)을 넘기는 흡입력** — 2시간 ≈ Y1 (보장 비트 최밀 구간 + 상철 진실 시동 t26). 감시 지점: t25~48 밀도(보장 1/8주).
3. **엔딩이 대박인가** — 35종+dik+시간의 기록+크레딧 후 히든+리캡 카드+CG. 기준: 엔딩 스크린샷이 공유되는가.

### 상시 감사 의무 (유저 위임 2026-07-07)
- **재량 위임**: 유저 지시 외에도 기존 기능과 조화되는 한 스스로 넣고·빼고·조절한다. 단 조화 원칙: 정본 규칙·설교 방지 5원칙·audit 래칫 안에서.
- **업적**: 신규 기능마다 업적 설계 동반. 15종 전수 감사와 실제 해금 경로 게이트는 2026-07-13 완료했으며, 이후 추가 업적은 카탈로그·EN·명패·실행 경로를 `AchievementPathCheck`에 함께 등록한다.
- **밸런스·밀도·참신성**: 수치 변경 시 밴드, 콘텐츠 추가 시 챕터별 밀도 지도 갱신, 스토리 비트는 "회수>발명" 원칙과 참신성(장르 관습의 한국 성인 번역) 기준.

---

## 운영 모델 (2026-07-06 유저 지시)

> **v3 (2026-07-16 유저 지시)**: **Codex 의견 1차 채택, Claude 의견은 참고.** 방향·취향·기획 제안은 Claude가 먼저 밀지 않고 **유저가 물을 때만** 낸다. Claude 상시 역할은 **사실 검증·병합 정합·라우팅/정본 안전장치**로 한정(취향 아닌 맞고 틀림의 영역 — 파산 도움말 오류·브랜치 계보 소실·이중 구현 같은 사고 예방). 판매 톤·마케팅·연출 방향 등은 Codex(ORDER-27 등)·유저가 결정, Claude는 요청 시만 관여.
> **v2 (2026-07-13 유저 지시)**: Codex 토큰 상시 가용 → **Claude=오더 발행·판정·병합 정합·정본 수호 전용**, 구현·산문·QA·이미지·번역·반복 작업 전부 Codex. 오더 큐·프로토콜 = `docs/CODEX_QUEUE.md` 🎖 섹션. Claude 컨테이너 Godot 소실(2026-07-13) — 컴파일 게이트는 Codex 몫.

- **Claude(메인 세션)**: 진단·설계 스펙·서브에이전트 산출물 판정·병합 정합·최종 커밋. **직접 반복 타이핑 최소화** — 잡일은 위임.
- **서브에이전트**: 전수조사, 스펙 기반 구현, 반복 텍스트 작업. 메인이 정밀 스펙을 쓰고 diff를 판정한다. (스펙에 검증 명령·수정 허용 파일·커밋 금지를 반드시 명시)
- **Codex**: 외형(이미지·오디오·UI 표면·카지노 미니게임 메커니즘). main에서 작업. `docs/GANGNAM_INK_ART_DIRECTION.md`, `docs/PRODUCTION_ASSET_PIPELINE.md` 기준.
- **주의**: Codex는 Claude의 설계 문서를 읽고 독자 구현할 수 있다(2026-07-07 축 시스템 이중 구현 사례). **설계 문서의 "구현 예정" 항목엔 담당을 명시**하고, main 병합 시 이중 구현 정합부터 확인한다.
- 브랜치: Claude=`claude/game-polish-steam-uh6ldg`, main 병합은 Codex 담당. Claude는 유저 지시 시 main을 받아온다.

---

## 정본 규칙 (Canon — 어기면 감사/서사가 깨진다)

### 서사·인물
- **호칭/스피치 정본** (`docs/ROMANCE_SYSTEM.md`): 다은→민준 **"민준씨"+존댓말**(진심·따뜻). 지연→민준 **"오빠"+반말**(도도·직설) — 단 **연애 확정 후부터** 반말, 첫 만남~알던 사이는 존댓말(오빠 호칭은 친해지면). EN: 다은="Minjun", 지연="oppa"(로마자). 민준은 두 여성에게 존댓말 기조.
- **로맨스 상호배타**: `daeun_romance_started` ↔ `jiyeon_romance_started`. 결혼은 잃을 수 있다: 다은=배신하면 이혼(→lonely_rich), 지연=작게 살면 그녀가 떠남(jiyeon_left→ordinary_life). 30억+배우자 유지=gangnam_dream 변주.
- **선택적 가상화** (DECISIONS 2026-07-03): 구조적 한국 현실(서울·강남·전세·정선·카카오톡·코스피 지수)=실명. 변동 자산·기업·아파트 단지명=투명 아날로그(한성전자·코어코인·성원아파트). 특정 시사=제네릭. asset id 불변(저장 호환).
- **인물 stage**: `content/meta/cast_stages.json`이 정본. 새 stage는 거기 먼저 선언.
- **숨은 시스템 비노출**: moral_tint/route 수치는 UI 텍스트로 절대 노출 금지 — 색·질감·서술로만.

### AP 축 + 몽타주 (docs/AP_REDESIGN.md)
- **분류 정본**: human = 휴식·인연 연락·운동·명상. money = 구직·알바·절약·**인맥·VIP인맥**(도구적 사교)·투자·도박·스펙(자소서/면접/심화독서/창업/콘텐츠)·독서·투자공부. study 카드 태그=mixed.
- **등록은 각 `_ap_*` 함수 내부 1회** (`GameState.register_action_axis`). 래퍼/성공 분기 재등록 금지(이중 집계).
- **그라인드 마모**: 사람축 0인 주 4연속마다 정신-1·tint-1, **루프 드립 총합 상한 -20**(`loop_tint_spent`).
- **몽타주 불변 조건**: 보장 아크(`_next_arc_id`)·월말·위기(건강<=35/정신<=25/현금<고정지출)·게임오버 앞 **절대 정지**. 주간 경제는 `_run_week_start_economy`/`_run_month_end_transition`을 정상 경로와 공유(중복 구현 금지).

### 콘텐츠 데이터
- KR 소스(`content/events/`) + EN 오버레이(`content/events_en/`, **text-only**, id 병합 — 게임플레이 키는 KR에만).
- `description_if_known`(dik): 첫 매치 우선 → **항상-매치 키 뒤에 두면 영원히 발화 불가**(섀도잉). 엔딩 오버레이는 dict 통째 덮어쓰기라 EN 패리티 키 필수. dik는 StoryMode 렌더 경로에서만 적용(아크·주간 사건은 전부 StoryMode 경유라 안전).
- **write-only 플래그 baseline 0** (2026-07-02 달성): 새 플래그는 반드시 독자(조건/코드/dik)를 갖는다. 고아=audit ERROR.
- 유저 표면 문자열은 **`_tr(kr, en)` 필수** — 한글 리터럴이 `_tr` 밖이면 영어 표면 스캐너가 감사 실패. 어순 다르면 `_tr("...{p}...", "...").format({"p": x})`.
- EN 표기 정본 (DECISIONS 2026-07-07): 통화="N billion/million won"(₩·KRW 접두 금지, **문장 첫머리는 스펠아웃**), 라면="ramyeon", 문맥으로 못 푸는 한국어 명사만 첫 등장 인라인 글로스, 9급="the Grade 9 civil service exam".

---

## 세션 프로토콜

### 시작 (3분 이내)
1. 이 파일 현재 상태 블록 ✓ → 2. `docs/ROADMAP.md` 현재 단계 + `docs/WORK_LOG.md` 최근 항목 → 3. 유저 지시 없으면 "다음 작업"부터

### 종료 (매 작업 후)
1. 이 파일 현재 상태 블록 업데이트
2. `docs/WORK_LOG.md` 기록 / `docs/RELEASE_NOTES.md` Unreleased / 설계 결정 시 `docs/DECISIONS.md` / 수치 조정 시 `docs/BALANCE.md`
3. 커밋·푸시 (`claude/game-polish-steam-uh6ldg`)

### ⭐ 검증 스위트 (커밋 전 필수)
```bash
GODOT=/usr/local/bin/godot ./tools/audit.sh     # 마지막 줄 "✅ 감사 통과" 확인 (exit 0)
python3 tools/en_coverage_check.py              # EN 커버리지 + 엔딩 dik 패리티
python3 tools/arc_flow_sim.py                   # 아크 체인/잼 (아크 트리거 변경 시)
```
- **main에서 신규 바이너리 자산을 받았으면** 먼저 `godot --headless --import` (임포트 캐시 — 안 하면 오디오/텍스처 체크 로드 실패).
- 실렌더: `xvfb-run -a godot --display-driver x11 --rendering-driver opengl3 --resolution 1280x800 res://tools/ScreenshotQA.tscn -- --qa=<scope> --lang=en` (scope 매트릭스: `docs/QA_CHECKLIST.md`)
- JSON 단건: `python3 -c "import json; json.load(open('파일.json'))"`

audit.sh가 잡는 것(요약): dangling 동적 호출 / 폐기 키워드 / 이벤트 JSON 무결성 / **DataRegistry 이벤트 파일 등록 누락** / 플래그 교차검증 / serialize 완전성(신규 var는 serialize 또는 audit.py SERIALIZE_EXEMPT) / 이벤트 키 화이트리스트 / cast stage 상태기계 / 밸런스 밴드 / 죽은 아크·stage 분기 / **구조 부채 래칫(write-only 0·inert 0)** / dik 섀도잉 / UI 이모지 표면 / 영어 표면 한글 스캐너 / Godot 컴파일. <!-- audit-ignore -->

### 새 이벤트 추가 체크
- `id`=snake_case 전역 고유, `result_text` 빈 문자열 금지, `cooldown` 3+, `conditions` 없으면 `{}`
- 아크(보장) 이벤트: `min_turn: 9999`+`weight: 0` + `_next_arc_id()` 트리거 배선 (없으면 죽은 아크 ERROR)
- 선택지는 효과/플래그/tint로 반드시 구분(전부 동일=inert ERROR)
- KR 작성 → EN 오버레이 동시 → 검증 스위트

---

## 프로젝트 개요

- **한 줄**: 33세 백수 김민준이 통장 50만원으로 5년(38세) 안에 자산 30억을 모아 강남에 입성하는 한국 사회 리얼리티 인터랙티브 드라마.
- **Question A (주제 스파인)**: "같은 길을 오르면서 — 같은 사람이 되지 않을 수 있을까." 모든 신규 콘텐츠는 이 질문을 육화해야 한다.
- **4대 가치 축 (2026-07-07 유저 정본)**: **돈 · 사랑 · 가족 · 신념** — 이 게임의 모든 결정적 장면은 이 넷 중 둘 이상을 한 프레임에 놓는다(남산 야경="타워가 묻는다" 4문이 원형). 신규 정점 비트 설계 시 체크리스트로 사용.
- **명장면 산문 밀도 (2026-07-08 유저 정본)**: 몽타주가 루틴을 압축하는 건 **정점 씬을 소설로 쓰기 위한 예산 확보**다. 하이라이트(로맨스·상철 진실·아버지·재혁·4대 가치 정점)는 감각 구체·시간 늘리기·절제의 관능·여운 비트로 육화 — "두세 문장으로 처리" 금지. 외설 아닌 밀도(§5 페이드아웃 유지). 정본·루브릭·레지스트리 = `docs/ROMANCE_SYSTEM.md` §8. 골드 스탠다드=「그 밤」·첫날밤 2종.
- **장르/엔진**: 인터랙티브 드라마·라이프심 / **Godot 4.6** GDScript / KR 주 언어 + EN 완전 지원 / Steam·Steam Deck 타깃
- **Steam 피치**: KR "빚을 다 갚고 남은 건 50만원. 강남까지 30억이 필요하다. 5년밖에 없다." / EN "₩500,000 in the bank. ₩3B to reach Gangnam, Seoul's status district. Five years, no guarantee."
- **데모 범위**: OpeningCinematic→프롤로그→arc_intro→arc_chapter1_close(t=8)→자유플레이→t=24 데모 엔딩+위시리스트 CTA. 데모 최강 순간=t4 대포통장 12초 타이머. **데모 훅 2026-07-07 해소**: 플래시포워드 콜드오픈(전 빌드 공통) + t5 SNS dik 양변주. tint 셰이더 강제 연출은 Codex(CODEX_QUEUE 8).

### 핵심 시스템 지도
| 시스템 | 정본 문서 | 코어 |
|---|---|---|
| MORAL_TINT (색으로 보는 자기 파괴) | `docs/MORAL_TINT.md` | moral_tint −100~+100, 밴드 ±20/±60, 흉터 상한(crossed_line→−20) |
| AP 축 + 몽타주 | `docs/AP_REDESIGN.md` | action_axis_this_week, 그라인드 마모, Codex act-rail, `_montage_advance` |
| 로맨스/결혼 | `docs/ROMANCE_SYSTEM.md` | 상호배타, 조기 연애 가능, 잃을 수 있는 결혼, 호칭 정본 |
| 발견 레이어 | dik 엔진 (StoryMode.gd) | 진실을 알면 같은 장면이 다르게 읽힘 |
| 상철 진실 아크 | `docs/STORY_BIBLE.md` | t10 만남→t26+ 추론/고백→t60 대면→엔딩 4경로 |
| 캘린더 | — | **turn=1주**, 1개월=4턴, 5년=240턴, 종료 age>=38 |

### 콘텐츠 밀도 지도 (2026-07-18 ORDER-28 동기화)
- 전체 카탈로그 1,565개 중 작성형 388, 랜덤 풀 1,177. 대표 A/B 경로의 장별 전경 뿌리는 `26/25/26/16/13`, `28/24/32/23/15`다. 1장은 8체인·시간 인과 4/3, 2장은 4체인·2정점과 2년 시간축, 3장은 시간 연결 15/20, 4·5장은 10억·몸·연말·20억의 시간축과 setup→escalation→reversal→boss→aftermath를 가진다. 두 경로 모두 1~5장 고립 단편 0이다. 5아키타입×3,000런은 우세 엔딩 5/5·평균 JSD 0.989로 재통과했다. 실제 KO/EN 240주 패드 완주, 6단계 장면 우선 피날레, 전 범위 7가족 맥락 압박과 3선택 계약, 고유 AP 선택의 20개 Echo·매치 사건 인과도 통과했다. 다음 P0는 정상 독해 사용자 재플레이로 사람이 실제로 다른 5년처럼 읽는지 판정하는 일이다.
- 처방은 풀 확장이 아니다. Quiet/Echo/Decision/Boss 편성, 32개 Tier-1 체인, 장별 인과 스파인을 사용자 재플레이로 검증한다. 정확한 기준과 실행 게이트는 `docs/GAME_RECOMPOSITION_PLAN.md`와 `docs/NARRATIVE_RECOMPOSITION_PLAN.md`.

---

## 디렉토리 구조 (요약)

```
GangnamDream/
├── CLAUDE.md                  ← 이 파일
├── autoloads/                 # DataRegistry(JSON 로더·EN 오버레이) / GameState(상태·축·tint·serialize·finish_run)
│                              # EventManager(조건·가중치·쿨다운) / NewsManager / MetaProgression / SaveManager
├── content/
│   ├── events/                # KR 이벤트 70+ 파일 (life/investment/relationship/hidden/arc_*/callback_*)
│   ├── events_en/             # EN 오버레이 (id 병합, text-only)
│   ├── endings.json (+_en)    # 35 엔딩 + dik 변주 (EN 패리티 필수)
│   ├── assets.json / jobs.json / items.json / news_templates.json
│   └── meta/cast_stages.json  # 인물 stage 상태기계 정본
├── systems/                   # Investment / Job / Relationship / Inventory / Ending
├── scenes/                    # StartMenu / MainGame(AP 대시보드·_next_arc_id·몽타주) / StoryMode(VN·dik)
├── tools/                     # audit.py+.sh / balance_check.py / en_coverage_check.py /
│                              # english_hangul_audit.py / arc_flow_sim.py / ScreenshotQA / debt_baseline.json
└── docs/                      # 정본 문서 (아래 색인)
```

### 문서 색인 (자주 쓰는 것)
`STORY_BIBLE.md`(설계·서사 바이블) · `ROADMAP.md` · `WORK_LOG.md` · `DECISIONS.md` · `BALANCE.md` · `MORAL_TINT.md` · `AP_REDESIGN.md` · `ROMANCE_SYSTEM.md` · `QA_CHECKLIST.md` · `GANGNAM_INK_ART_DIRECTION.md`(Codex 표면) · `ENDING_ART.md`(CG 큐) · `I18N_GLOSSARY.md`

---

## 밸런스 기준값 (변경 시 BALANCE.md 기록 + 밴드 갱신)

| 항목 | 값 |
|---|---|
| 시작 | 33세 백수, 현금 50만원, 건강 65/정신력 60, AP 2/주 |
| 승리 | 총자산 30억 → `finish_run("gangnam_dream")` (배우자 변주는 finish_run 캐스케이드) |
| 마감 | age>=38 (240턴) / 파산 순자산 -1억 |
| 고정지출 | 고시원 65만/월 → HOUSING_DATA 사다리 |
| 밸런스 밴드 | 무직 방치 실패 95~100% / 직장 실패 0~2% / 직장+베팅 30억 도달 8~25% / 직장 중앙값 5천만~1.5억 |
| 대출 | 신용등급 1~10, 법정 최고금리 연 20% 클램프 |

### 엔딩 라우팅 요점 (GameState.finish_run 캐스케이드 — 순서가 정본)
- 30억 분기: `daeun_divorced`→lonely_rich → `daeun_married`→gangnam_dream → `jiyeon_romance_started`(not jiyeon_left)→gangnam_dream → **그 다음** crossed_line→jaehyuk_way (배우자 실이 crossed_line보다 먼저)
- age>=38 분기: daeun_divorced→ordinary_life의 이혼 변주(30억 달성 이혼만 lonely_rich) / jiyeon_left→ordinary_life / with_daeun / jiyeon_man / …
- 전체 35 엔딩: `content/endings.json` + `EndingSystem.gd`
