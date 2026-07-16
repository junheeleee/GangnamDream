# 강남드림 기술 부채 원장

> 기준일: 2026-07-16 · 정본 오더: `CODEX_QUEUE.md` ORDER-18
> 원칙: **하드코딩이라는 이유만으로 고치지 않는다. 출시·DLC 로드맵을 막는가로 판정한다.**

## 재현 방법

```bash
python3 tools/tech_debt_inventory.py
python3 tools/tech_debt_inventory.py --json > /tmp/gangnam_tech_debt.json
```

이 도구는 `.godot`, `.git`, 외부 `addons`를 제외한 모든 GDScript를 읽는다. 긴 함수, 파일 규모, 동일 함수 본문, 문자열 동적 호출, 반복 리터럴, `TODO/FIXME/pass`, 텍스트상 독자가 하나뿐인 함수 후보를 기록한다. **죽은 코드 후보는 증거가 아니라 조사 시작점**이다. Godot 콜백, 시그널, 문자열 디스패치, 외부 공개 API는 텍스트 검색만으로 삭제하지 않는다.

## 2026-07-16 기준선

| 지표 | 값 | 판정 |
|---|---:|---|
| GDScript | 91파일 / 61,569줄 | 도구 포함 |
| 제품 코드 | 58파일 | `autoloads/data/scenes/systems/ui_components` |
| 함수 | 2,448 | 도구 포함 |
| 제품 핫스팟 | 17파일 | 1,000줄 이상 또는 함수 35개 이상 |
| 120줄 이상 함수 | 44 | 제품 코드 37, QA 도구 7 |
| 동일 본문 그룹 | 15 | 대부분 미니게임 표면 헬퍼 |
| 문자열 동적 호출 | 45 | 대부분 포커스 복구와 지연 호출 |
| TODO/pass | 4 | 실제 미완 1, 명시적 무동작 3 |
| 죽은 코드 후보 | 54 | 공개 API와 콜백 오탐 포함 |
| 12줄 이상 인라인 데이터 후보 | 49 | 위치 제시용이며 자동 이관 대상 아님 |

전체 원시 목록은 위 JSON 명령으로 보존한다. 이 문서는 원시 후보를 출시 판단으로 바꾼 정본이다.

## A급 수리 후 기준선

| 지표 | 수리 전 | 수리 후 | 변화 |
|---|---:|---:|---:|
| GDScript | 91파일 / 61,569줄 | 86파일 / 59,524줄 | **-5파일 / -2,045줄** |
| 제품 코드 | 58파일 | 53파일 | **-5파일** |
| 함수 | 2,448 | 2,429 | **-19** |
| 제품 핫스팟 | 17파일 | 16파일 | **-1** |
| 120줄 이상 함수 | 44 | 43 | **-1** |
| 문자열 동적 호출 | 45 | 44 | **-1** |
| TODO/pass | 4 | 2 | **-2** |
| 죽은 코드 후보 | 54 | 47 | **-7** |

`python3 tools/tech_debt_inventory.py`의 2026-07-16 사후 출력이다. 동일 본문 그룹 15개와 인라인 데이터 후보 49개는 줄지 않았다. 이 둘은 삭제로 해결할 A급 결함이 아니라, 장치 매트릭스와 정본 소유권을 먼저 잠가야 하는 B급 이관 작업이다.

## 분류 요약

| 등급 | 뜻 | 출시 전 정책 |
|---|---|---|
| **A** | 로드맵을 막거나, 참조 0이 기계적으로 입증된 저위험 부채 | 개별 선언·커밋·전체 audit 후 수리 |
| **B** | 구조 수술 또는 공용화가 필요한 부채 | v1.1 엔진 경화 / DLC 인프라 트랙 |
| **C** | 겉보기엔 하드코딩이나 현재 게임 규칙의 정본 | 문서화만 하고 손대지 않음 |

## A · 출시 전 수리

| ID | 상태 | 위치 | 증거 | 수리 / 검증 | 로드맵 |
|---|---|---|---|---|---|
| A-01 | **완료** | `data/EventData.gd`, `InvestmentData.gd`, `ItemData.gd`, `JobData.gd`, `NewsData.gd`와 UID | 초기 커밋의 GDScript 데이터 1,771줄. 전체 코드·씬·리소스에서 파일명, `res://data/`, 정적 배열 독자 0. 현재 실행은 `DataRegistry`의 `content/*.json`만 사용 | 10파일 삭제. 정적 감사와 53스크립트 컴파일, 이벤트/투자/직업/상점/뉴스 계약 통과 | JSON 정본 단일화, ORDER-12/17 모딩 전 혼선 제거 |
| A-02 | **완료** | `scenes/StartMenu.gd`의 `_build_legacy_ui`, `_splash_meta_badge`, `_section_header` | 각 함수 정의 외 참조 0. `_build_legacy_ui` 주석도 “더 이상 호출하지 않음”을 명시. 약 250줄의 폐기 타이틀 표면 | 함수 세 개와 고아 일본어 키 5개 삭제. 1920×1080 KO/EN, Xbox 글리프, 키보드/패드 시작 메뉴 과업 통과 | 데모 첫 화면의 단일 구현 유지 |
| A-03 | **완료** | `autoloads/GameState.gd::_apply_background_bonus`, `scenes/MainGame.gd::life_skills_game`, `_build_bottom_bar` | 각각 명시적 legacy `pass`, 제거된 미니게임 필드, 호출 1회뿐인 빈 빌더 | 선언·대입·빈 호출/함수만 삭제. 저장 키·게임 규칙 변경 없음. 컴파일 및 AP 화면 회귀 통과 | 컴파일 표면과 신규 작업자의 오해 감소 |
| A-04 | **외부 대기** | `scenes/MainGame.gd::STEAM_APP_ID` | 실제 미완 TODO 1건. 현재 문자열 placeholder라 스토어 이동은 검색 폴백 URL 사용 | Steamworks AppID 발급 즉시 숫자 설정. 발급 전 임의 값 금지 | 패키징 외부 게이트. 코드 정리와 별개 |

A-01~03은 동작을 바꾸지 않는 삭제만 허용한다. A-04는 외부 값이 생기기 전에는 TODO를 유지한다.

## B · v1.1 엔진 경화

| ID | 위치 / 규모 | 부채 | 안전한 이관 경계 | 연관 |
|---|---|---|---|---|
| B-01 | `scenes/MainGame.gd` 16,100줄 / 549함수 | UI 조립, 주간 경제, 아크 편성, AP 행동, 투자·상점, 엔딩·결산이 한 노드에 공존 | 아래 책임 지도 단위로 먼저 테스트를 소유권 이전한 뒤 분리. 출시 전 파일 쪼개기 금지 | DLC, 유지보수 |
| B-02 | `_next_arc_id()` 1,127줄 | 턴 창·플래그·체인 순서가 코드 분기 | v1.1에서 읽기 전용 스케줄 데이터 + 현 함수와 결과 비교 하니스부터. 즉시 치환 금지 | ORDER-17 커스텀 아크 |
| B-03 | 미니게임 9개 | `_pulse_node` 7복제, `_shake_node` 5복제, `_screen_flash` 5복제, `_mark_pad_button` 4복제, 패드 입력 2복제 | 규칙 엔진이 아니라 표면 효과·의미 입력만 공용 컴포넌트화. 장치 매트릭스로 선행 잠금 | 콘솔 포팅 |
| B-04 | 슬롯 `_build_ui` 479줄, 룰렛 322줄, 빅휠 249줄, 다이사이 168줄 | 코드 생성 UI가 규칙·레이아웃과 결합 | 게임별 테이블 상태와 표현 노드를 먼저 분리하고 1080p/Deck 골든 캡처 비교 | 미니게임 폴리시 |
| B-05 | `ImageRegistry.infer_background_id()` 243줄 | 이벤트 문자열에서 장소를 추론하는 규칙이 코드에 누적 | `story_rules.json`의 명시 장소 계약이 데모 밖까지 충분해진 뒤 폴백만 남김 | 배경·오디오 정합 |
| B-06 | `TutorialOverlay._get_slides()` 455줄 | 튜토리얼 본문·레이아웃이 코드 배열 | 튜토리얼 단계 JSON화는 번역 스키마 일반화와 함께 | ORDER-12 다국어 |
| B-07 | `data` 제거 뒤에도 UI 크기·간격·색 리터럴이 각 씬에 산재 | 반복 숫자의 대부분은 레이아웃 값이며 현재 즉시 버그는 아님 | 공식 Theme/토큰 자원으로 값만 이동. Moral band 구조는 유지 | ORDER-17 테마 팔레트 |
| B-08 | `tools/ScreenshotQA.gd` 5,808줄 / 181함수 | QA 스코프가 한 하니스에 집중 | 출시 후 scope driver와 seed fixture 분리. 제품 코드와 별도라 출시 차단 아님 | 테스트 유지비 |
| B-09 | `StoryMode._build_ui` 323줄, `_render_current` 165줄 | VN 표시·입력·타이핑·오디오·Living Scene이 한 클래스 | 화면 상태별 계약 테스트를 유지한 채 presenter 분리 | DLC 장면 문법 |
| B-10 | 12줄 이상 인라인 데이터 49개 | `PERSON_INFO` 610줄, `EVENT_PATHS` 128줄, 타이틀·면접·알바·오디오 표 등이 코드에 존재 | 소유 정본과 로더가 확정된 표만 ID 패리티 테스트 후 이동. 에셋 레지스트리와 규칙 상수는 무조건 JSON화하지 않음 | ORDER-12/17, DLC |

### MainGame 책임 지도

라인 번호 대신 함수 앵커로 소유권을 잡는다. 삭제·삽입에도 문서가 썩지 않게 하기 위함이다.

| 책임 | 시작 앵커 | 현재 소유 데이터 | 미래 모듈 후보 |
|---|---|---|---|
| 부팅·시스템 연결 | `_ready`, `_init_systems`, `_connect_signals` | 서브시스템 인스턴스와 신호 | `GameSession` |
| Moral 표면·전환 | `_apply_moral_visuals`~`_play_ink_transition` | 팔레트, 셰이더, 돈 강조 | `MoralPresentation` |
| 셸 UI | `_build_ui`~`_build_modal` | HUD, 초상, 정보, 모달 | `LifeSimShell` |
| 주간 경제·스토리 | `_run_week_start_economy`~`_go_story_mode` | 주 시작, 월말, StoryMode 왕복 | `WeekDirector` |
| 아크 편성 | `_next_arc_id` | 턴 창, 플래그, 순서 | `ArcScheduler` + 데이터 |
| 주간 AP 표면 | `_render_ap_actions`~행동 카드 빌더 | 현재 압박, 카드, 패드 포커스 | `ActionBoard` |
| 행동 실행 | `_ap_*`, `_open_cat_*` | AP 소비, 축 등록, 모달 | 기능별 command/service |
| 투자·상점·관계 | 각 `_open_*` 모달 | DataRegistry 조회와 구매/매도 | 기존 system 노드의 presenter |
| 이벤트·결과 | `_show_result`, 배경/초상 갱신 | 현재 이벤트와 피드백 | `LifeEventPresenter` |
| 엔딩·결산 | `_show_ending`~`_show_month_summary` | 엔딩 카드, 시간 원장, 월말 | `EndingPresenter`, `MonthSummary` |

분리 순서는 **테스트 소유권 → 읽기 전용 추출 → 쓰기 위임 → 원본 삭제**다. 한 번에 파일을 나누지 않는다.

### 중복 본문 15그룹 판정

| 그룹 | 위치 | 분류 |
|---|---|---|
| pulse/shake/flash | 바카라·블랙잭·홀덤·경마·스캘핑·트레이딩·MainGame | B-03. 동일하지만 타이밍 손맛 검증 뒤 공용화 |
| `_mark_pad_button`, `_add_pad_hint` | 블랙잭·홀덤·경마·룰렛 | B-03. 의미 입력층과 합칠 후보 |
| `_ui_icon_texture` | MainGame·StartMenu·Tutorial | B-07. ImageRegistry/UIStyle 소유권 결정 후 |
| `_story_result_visible_cast_effects` | MainGame·StoryMode | B-09. 결과 표시 두 경로의 패리티 테스트가 먼저 |
| 칩 색/아이콘 | 블랙잭·다이사이·빅휠·룰렛 | B-03. denomination 정본과 함께 |
| 다이사이/룰렛 `_unhandled_input` | 두 테이블 | B-03. 현재 45줄 완전 동일 |
| 패널 스타일 | MainGame·StoryMode·홀덤·경마 | B-07. 우연히 같은 값인 것까지 성급히 묶지 않음 |
| QA 메타 복원/Hangul 검사 | `tools/*` | B-08, 제품 위험 없음 |
| BigWheel/DaiSai `_ready` | 두 테이블 | B-03, 공용 base 도입은 출시 후 |

## C · 의도된 정본, 건드리지 말 것

| ID | 위치 | 왜 하드코딩을 유지하는가 | 금지 |
|---|---|---|---|
| C-01 | `GameState.check_game_over()` → `finish_run()` | 배우자·배신·도덕 붕괴·30억·연령 엔딩의 **순서 자체가 서사 규칙** | 정렬, dict 순회, 범용 rule engine으로 즉시 치환 금지 |
| C-02 | `MainGame._next_arc_id()` | B-02의 장기 부채지만 현 출시에서는 명시 순서가 240주 정본 | 출시 전 데이터화·자동 정렬 금지 |
| C-03 | `StoryMode`와 엔딩의 `description_if_known` | 첫 매치가 우선순위다. 여러 기억 문단 누적을 막는 연출 규칙 | 모든 매치 합성·키 정렬 금지 |
| C-04 | 각 `_ap_*` 내부 `register_action_axis` 1회 | 축 집계가 행동 실행과 원자적으로 붙어야 저장·몽타주가 맞음 | 버튼 래퍼와 성공 분기에 중복 등록 금지 |
| C-05 | `GameState.serialize()`의 명시 키 | 세이브 호환 표면이 코드 리뷰에서 보여야 함 | 무차별 reflection 직렬화 금지 |
| C-06 | 원화 단위와 `format_money` | 영문도 환율 환산하지 않는 한국 배경·밸런스 정본 | USD 환산, 로케일별 경제 수치 변경 금지 |
| C-07 | `ImageRegistry`의 여러 ID→같은 파일 별칭 | 사건 의미 ID와 물리 파일을 분리해 향후 에셋 교체를 허용 | “중복 경로”라는 이유로 의미 ID 병합 금지 |
| C-08 | 포커스 복구의 `call_deferred("grab_focus")` | Godot 트리 반영 다음 프레임에 포커스를 잡기 위한 엔진 문법 | 즉시 호출로 기계 치환 금지 |
| C-09 | `AudioManager` 파형 숫자 | UI SFX의 합성 레시피이며 일반 밸런스 수치가 아님 | 반복 숫자라는 이유로 게임 밸런스 JSON에 이동 금지 |
| C-10 | 외부에 쓰이지 않는 public getter 후보 | 모딩·QA·콘솔 포팅 표면일 수 있고 삭제 이득이 작음 | 텍스트 독자 1이라는 이유만으로 삭제 금지 |

## 죽은 코드 후보 전수 판정

54개 후보는 다음처럼 처리한다.

| 묶음 | 후보 | 판정 |
|---|---|---|
| 명시 폐기 | `_apply_background_bonus`, `_build_legacy_ui`, `_splash_meta_badge`, StartMenu `_section_header` | A-02/A-03 삭제 |
| 구 AP 표면 | `_goal_sep`, `_render_action_cards`, `_add_action_section_header`, `_add_action_buttons`, `_ap_selfdev`, 주간 축/압박의 미호출 빌더, 월말 구형 helper 다수 | A 후보이나 연결된 dead island를 별도 런타임 검증한 뒤에만 삭제. 이번 첫 수리는 명시 폐기부터 |
| autoload public API | `get_events`, `process_month_events`, `get_route_label`, `get_run_pace`, `get_wealth_tier`, `has_clue`, `is_thought_done`, `get_slots`, 메타 getter 등 | C-10 유지 |
| 공용 UIStyle factory | `make_wrap_label`, `make_button`, `make_small_button`, `make_panel`, `make_lineedit`, `make_separator` | B-07까지 유지 |
| 데이터 유틸 | Investment/Item/News 정적 getter | 파일 전체가 A-01로 제거됨 |
| 게임별 보조 | 블랙잭 dealer silhouette, StoryMode effect preview, BigWheel house edge, HorseWorld underpriced 등 | 화면·QA·향후 확장 가능성 확인 전 유지 |

## 매직 리터럴 판정

- 반복 숫자 최다는 `MainGame`의 8/10/12px 간격·글자 크기다. 이는 현재 화면 결함이 아니라 B-07 테마 토큰 후보이다.
- 룰렛 36, 블랙잭 21, 다이사이 배당처럼 규칙을 표현하는 숫자는 게임별 `const` 또는 규칙 엔진에 남긴다.
- 배경·초상 경로 중복은 C-07 의미 별칭이다.
- 같은 hex가 3회 이상 반복되는 후보는 `MainGame` 101종을 포함해 여러 화면에 존재한다. 대부분 Moral 역할색·간격 토큰과 게임별 테이블 색이므로 B-07에서 공식 Theme/토큰 소유권을 정한 뒤 이동한다. 반복 횟수만으로 A급 상수 추출을 하지 않는다.
- 영어 표면 하드코딩 누수는 `en_coverage_check`와 `english_hangul_audit` 기준 0이다. 문자열을 무조건 JSON으로 옮기는 작업은 A가 아니다.

## 코드 동결 판정

A-01~03과 해당 audit가 끝나면 ORDER-18의 출시 전 코드 정리는 종료한다. 이후 B 항목은 버그 수정처럼 위장해 착수하지 않는다. 데모 출시 전에는 사용자 재현 버그, 컴파일 실패, 저장 손상, 입력 막힘만 코드 변경 사유로 인정한다.
