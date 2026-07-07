# CODEX_QUEUE.md — Codex 작업 대기열 (2026-07-07 Claude 작성)

> **Codex 세션 시작 시 이 파일을 CLAUDE.md 직후에 읽는다.** 위에서부터 우선순위순.
> 전략 맥락: Steam "압도적으로 긍정적"이 목표 지표, 5레버는 `CLAUDE.md` 현재 상태 참조.
> 신규 정본: `docs/DECISIONS.md` 2026-07-07 3건(외부 파이프라인 판정 / 설교 방지 5원칙 / AP 축 정본) 먼저 읽을 것.

---

## 병합 프로토콜 (필독 — 이중 구현 사고 방지)

- 2026-07-07에 `claude/game-polish-steam-uh6ldg`에서 **큰 병합**이 있었다: Codex의 act-rail·축 표면과 Claude의 축 엔진을 정합 통합(카운터 `action_axis_this_week` dict 단일화, 등록은 각 `_ap_*` 함수 내부 1회, 드립 캡 -20, 인맥/VIP=돈축). **main으로 가져갈 때 이 정합을 되돌리지 말 것.**
- Claude 브랜치에 신규 대형 기능 있음: **몽타주 시간 압축**(`_montage_advance`, `_open_routine_modal`, `_maybe_add_montage_card`, GameState `week_routine`/`month_*_weeks`), H2 데드존 비트(`content/events/arc_h2_beats.json`, 병합 시점 기준 작업 중일 수 있음 — WORK_LOG 확인).
- 설계 문서의 "구현 예정" 항목은 **담당 명시**를 확인하고, 명시 없으면 착수 전 WORK_LOG로 중복 여부 확인.

## 표면 용어 원칙 (2026-07-07 사고 사례)

- 내부 시스템 용어(자유런/현실 모드/런/몽타주/tint/moral/축/axis)는 **플레이어 화면에 절대 노출 금지**. 시작화면의 "자유런/현실 모드/매 런" 노출을 이미 제거했음(StartMenu.gd).
- "없는 것을 해명하는 문구" 금지 — "고르는 설정은 없다" 같은 개발자 메모형 카피는 삭제 대상.
- 모든 신규 카피는 `docs/DECISIONS.md`의 **설교 방지 5원칙** 검수를 통과해야 한다(서술자 판단 금지 / 어둠의 문장 품질 / 기록>지시).

---

## P1 — 신규 기능 표면 폴리싱 (기능은 있고 옷이 없다)

### 1. 몽타주 표면 (최우선 — 방금 들어간 최대 기능)
- 대상: `_maybe_add_montage_card`(레일 카드), `_open_routine_modal`(루틴 2슬롯 선택), `_show_montage_card`(결과 카드) — 전부 기능 최소선으로 구현돼 있음.
- 할 것: ①레일 카드에 전용 픽토그램(시계/달력 계열, action_tiles 스타일) ②루틴 모달을 카드형 선택으로(현 버튼 나열) ③결과 카드 "N주가 흘렀다"를 기록장/몽타주 필름 톤으로 — 돈/건강/정신 Δ 배지는 AP 결과 카드(`ACTION RESULT`)와 같은 문법 ④몽타주 진행 중 짧은 전환 연출(잉크 페이드 몇 프레임 — 즉시 끝나도 "시간이 흐른" 느낌).
- 카피 제약: "몽타주" 단어 표면 노출 금지(현재 안 나옴 — 유지). 축 요약 문장("돈에 3주, 사람에게 1주")은 원문 유지.
- 검증: `ScreenshotQA --qa=ap-en --lang=en` + 몽타주 카드/루틴 모달/결과 카드 컷 추가 권장(`--qa=ap-en`에 씬 심기), `CompileCheck`, `./tools/audit.sh`.
- 수용 기준: 1280×800에서 루틴 모달·결과 카드 노스크롤, 결과 카드가 웹 모달이 아니라 게임 내 기록물로 보일 것.

### 2. 곁의 사람 셀 + 포기 힌트 폴리싱
- 대상: This Week 압박 행 4번째 셀 "곁의 사람"(`_people_pressure_state`), ACTION RAIL 위 그라인드 힌트("돈을 쫓는 사이 — %s에게 연락 못 한 지 %d주"), "이번 주도 전부 돈에 썼다" 라벨.
- 할 것: 셀 상태(곁에 있다/뜸하다/멀어진다)별 미세한 색온도 차이(따뜻함→식음), 힌트 라인의 타이포/여백 정리. 4셀이 EN 장문에서 잘리지 않는지 재확인.
- 제약: 관계 수치·tint 노출 금지(서술로만 — 현행 유지).
- 검증: `ScreenshotQA --qa=ap-en` (grind_streak 상태 시드 컷 추가 권장).

### 3. 시장 생동감 표면화 (레버: "정적/웹소설" 체감 해소)
- 배경: 시장 시뮬(장세·공포탐욕·폭락 리스크·뉴스→가격)이 실재하는데 플레이어가 "살아있는 시스템 위에 서 있다"를 못 느낌.
- 할 것: ①주 시작 시 티커가 실제로 *움직이는* 짧은 모션(전주 대비 등락 스윕) ②보유 자산이 있으면 상단/정보패널에서 포트폴리오 등락이 그 주에 체감되게(±색 펄스 1회) ③뉴스 이벤트 직후 "이 뉴스가 어느 자산을 흔들지"가 다음 주 티커에서 이어져 보이는 연출(인과 체감) ④투자 모달 Market 페이지의 스파크라인 강조.
- 데이터는 전부 있음: `GameState.market_prices/price_history/market_context`, NewsManager 영향 계수.
- 제약: 예측 정보를 공짜로 주지 말 것(Market Analysis 스킬 게이트 유지). 장식이지 치트 아님.
- 검증: `ScreenshotQA --qa=invest-en`, `--qa=ap-en`.

## P2 — 흥행 표면

### 4. 잔인한 통계 리캡 카드 (클립/공유용)
- 배경: 런 종료 화면에 스크린샷 한 장으로 퍼지는 카드. 예: "5년간 다은에게 연락한 횟수: 3회 / 돈에 쓴 주 178, 사람에게 쓴 주 12 / 아버지와의 마지막 통화: 죽기 11개월 전".
- 지금 쓸 수 있는 데이터: `money_weeks_total` / `human_weeks_total` / `grind_streak_weeks`(최종), cast affinity/stage/met, 주요 플래그(결혼/이혼/사별). **인물별 연락 원장 존재(2026-07-07)**: `GameState.contact_counts`/`last_contact_turn`(연락 횟수·마지막 턴). 텍스트 1차 버전은 엔딩 화면 '시간의 기록'(`_ending_time_ledger`)으로 이미 렌더 — Codex는 이걸 공유 특화 비주얼 카드로 승격.
- 할 것: 엔딩/데모 종료 화면에 `RUN RECORD` 계열의 공유 특화 카드 1장 — Gangnam Ink 톤, 게임 로고+엔딩명+통계 3~4줄. 기존 공유 텍스트(`_ending_run_summary`)와 별개의 *시각* 카드.
- 카피 제약: **설교 방지 4원칙 "기록하되 지시하지 않는다"** — 통계는 사실 서술만, 평가 어휘 금지.
- 검증: `ScreenshotQA --qa=endings-en`, `--qa=demo-end-en`.

### 5. 오디오 moral-shift (레버⑤ — 시각이 하는 걸 청각이 완성)
- 배경: moral band(−2~+2)에 따라 화면은 이미 변하는데 음악은 불변. `docs/DECISIONS.md` 2026-07-07 파이프라인 판정: **메인 테마+3변주(회색/검정/하양 — 같은 멜로디의 탈색 편곡)만 외부(작곡 외주 또는 AI 초안+큐레이션), 나머지 오디오는 로컬 파이프라인 유지.**
- 할 것(외부 소스 확보 전이라도): ①`BGMPlayer`에 moral band 구독(`GameState.moral_tint_changed` 시그널 이미 존재) → 밴드 전이 시 크로스페이드 훅 골격 ②현행 트랙으로 임시 매핑(low-pass/볼륨 레이어 등 코드 처리로 어둠 밴드 톤 다운) ③외부 트랙 도착 시 교체만 하면 되는 구조.
- 검증: `BGMContinuityCheck`(밴드 전이 시 재시작 없이 크로스페이드), `AudioAssetCheck`.

### 5.5 씬 연출 디렉션 키 (Claude 협업 — "애니메이션 없이 연출을")
- 배경(유저 질문 2026-07-07): "연출이 중요한데 애니메이션을 만들어야 하나?" → 판정: **아니오.** 이 장르의 연출 = 타이밍·소리·정적·정지화면의 카메라. 준거: Disco Elysium/Kentucky Route Zero(애니메이션 최소, 연출 최대), 실패 준거: 감정 강요 QTE.
- 컨셉: 이벤트 JSON에 선택적 `direction` 키를 도입해 **작가가 장면을 연출**할 수 있게 — 예: `{"pace":"slow","amb":"cut","sting":"low_note","camera":"slow_zoom"}`.
  - `pace`: 타이핑 속도 변주(무거운 문장은 느리게, 문단 사이 박자 멈춤)
  - `amb`: 앰비언스 컷/드랍(아버지 위독 전화 직전, 소리가 먼저 사라진다)
  - `sting`: 원샷 스팅어(진실 재독 dik 발화 순간의 낮은 현 한 음)
  - `camera`: 배경 정지화면의 느린 팬/줌(Ken Burns), 초상화 미세 호흡 스케일(1~2%)
- 분담: **키 스키마 설계+어느 장면에 어떤 연출을 쓸지(연출 대본)=Claude**, StoryMode 렌더러 구현+audit 이벤트 키 화이트리스트 등록=Codex. Claude의 스키마 문서(`docs/SCENE_DIRECTION.md` 예정)가 먼저 — WORK_LOG 확인 후 착수.
- 제약: 설교 방지 5원칙의 연출판 — **감정을 명령하는 연출 금지**(강제 슬로우+눈물 BGM 조합 남발 등). 절제·여백·침묵이 이 게임의 연출 언어. 남발 방지를 위해 direction 키는 **아크 이벤트의 정점 비트에만**(전체 이벤트의 ~5% 이하).

## P3 — 대형 (착수 전 설계 합의)

### 6. 서울 지도 허브 (웹소설→게임 체감의 최대 변환)
- 컨셉: AP 행동 메뉴를 "장소"로 재프레임 — 편의점(다은)·사무실·한강·헬스장·지하 홀덤·정선行·강남(목표, 처음엔 멀리 흐릿). 몽타주/주간 보드와 공존.
- **바로 착수 금지** — 규모가 큼. 1단계 제안서(와이어프레임 수준: 지도가 레일을 대체하는가/병행하는가, Steam Deck 조작 모델, 기존 act-rail과의 관계)를 `docs/`에 작성 → 유저 승인 후 구현. Claude가 장소↔행동 매핑 정본을 협의해줄 것.
- 참고: `docs/CONTROLLER_UX_STRATEGY.md`(화면당 하나의 명확한 조작 모델 원칙 준수).

### 7. 엔딩 CG 파이프라인 가동
- `docs/DECISIONS.md` 파이프라인 판정 + `docs/ENDING_ART.md` P0 큐 기준: 외부 생성 → 큐레이션 → **Gangnam Ink 그레이딩 셰이더 통과**(스타일 통일 장치). 결혼식·gangnam_dream·lonely_rich 등 페이오프 화면 우선.
- `docs/PRODUCTION_ASSET_PIPELINE.md` Gate 기준 적용.

### 8. 데모 플래시포워드 콜드오픈 (Claude 협업 — 콘텐츠는 Claude)
- 배경: 데모가 셀링포인트(tint 붕괴)를 못 보여줌(2026-07-07 감사). 처방: 데모 시작에 5년 뒤 새까만 tint의 민준 10초 컷 — "이게 누구인지는, 당신이 정한다."
- 분담: 장면 텍스트/타이밍=Claude(후속 예정), **tint −80 상태 셰이더 강제+연출**=Codex. Claude 콘텐츠가 먼저 — WORK_LOG에서 `demo_flashforward` 착수 여부 확인 후 진행.

---

## 공통 검증 (모든 항목)
```bash
GODOT=<경로> ./tools/audit.sh          # ✅ 감사 통과 (영어 표면 스캐너 포함 — 한글 리터럴은 _tr 안으로)
python3 tools/english_hangul_audit.py  # content_issues=0, runtime_candidate=0
xvfb-run -a godot ... ScreenshotQA -- --qa=<해당 스코프> --lang=en   # 수정 부위 스코프만
```
- 새 GameState var 추가 시 serialize 또는 audit.py SERIALIZE_EXEMPT.
- 완료 시 CLAUDE.md 현재 상태 + docs/WORK_LOG.md 갱신, 이 파일의 해당 항목에 `[x]`와 날짜.
