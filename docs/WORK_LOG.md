# Gangnam Dream Work Log

## 2026-06-29 (Codex Demo AP Focus Surface Pass)

### 수정
- `scenes/MainGame.gd`: AP 행동 화면의 `This Week` 포커스 카드에 남은 행동력을 숫자뿐 아니라 슬롯 막대로 표시해 Steam Deck 크기에서도 즉시 읽히게 했다.
- `scenes/MainGame.gd`: 추천 행동 문구에서 이모지 접두어를 제거해 영어판 AP 루프가 덜 모바일 위젯처럼 보이게 정리했다.
- `scenes/MainGame.gd`: 직접 행동 카드가 화면에 뜰 때 짧은 순차 reveal 애니메이션을 추가해 정적인 게시판식 UI 느낌을 줄였다.
- `scenes/MainGame.gd`: 목표 달성 예상 문구의 영어를 `At current income: ...` 형태로 보정해 기계번역 느낌을 낮췄다.

### 검증
- `./tools/audit.sh` 통과: ERROR 0 / WARNING 0, 밸런스 밴드 통과, Godot 컴파일 클린.
- `python3 tools/english_hangul_audit.py` 통과: content/runtime 한글 누수 0건.
- `ScreenshotQA.tscn -- --qa=surface-en` 실행 완료. `surface_en_03_ap_actions` 직접 확인: AP 슬롯/영어 추천 문구/행동 카드 배치 정상. 종료 시 기존 Godot RID/Texture cleanup 경고는 남지만 exit code 0.

---

## 2026-06-29 (Codex Gangnam Ink StoryMode Surface Pass)

### 수정
- `scenes/StoryMode.gd`: VN/스토리 화면 배경에 `background_grade.gdshader`와 `moral_surface.gdshader`를 적용해 메인 화면과 같은 Gangnam Ink 필름을 통과하게 했다.
- `scenes/StoryMode.gd`: `GameState.moral_tint_changed`를 구독해 배경 dim, 텍스트 박스, 이름표, 상단 HUD, 챕터 카드, 튜토리얼 팝업, 토스트가 회색/검정/흰색 축으로 함께 변하도록 연결했다.
- `scenes/StoryMode.gd`: 선택지 버튼을 금색/갈색 스타일에서 matte graphite 번호 선택지로 교체하고, 선택지 등장 페이드와 패드 포커스 테두리, 선택 직후 텍스트 박스 펄스를 추가했다.
- `scenes/StoryMode.gd`: 선택지가 뜰 때 초상화를 뒤로 물려 얼굴과 선택지가 서로 싸우지 않게 했고, 작은 스탯 효과 미리보기는 제거해 문장 선택 자체에 집중하게 했다.
- `tools/ScreenshotQA.gd`: `surface-en` QA에 영어 스토리 선택지 캡처 `surface_en_02b_story_choices`를 추가했다.

### 검증
- `./tools/audit.sh` 통과: ERROR 0 / WARNING 0, 밸런스 밴드 통과, Godot 컴파일 클린.
- `python3 tools/english_hangul_audit.py` 통과: content/runtime 한글 누수 0건.
- `ScreenshotQA.tscn -- --qa=surface-en` 실행 완료. `surface_en_02b_story_choices` 직접 확인: 선택지 번호/포커스/초상화 후퇴/영어 가독성 정상.
- `ScreenshotQA.tscn -- --qa=demo-blackbox --lang=en` 실행 완료. 챕터 카드와 초반 StoryMode 샷 직접 확인. 종료 시 기존 Godot RID/Texture cleanup 경고는 남지만 exit code 0.

---

## 2026-06-28 (Codex Casino Tactile Pass)

### 수정
- `autoloads/AudioManager.gd`: `play_delayed()`를 추가해 카드 딜/칩 이동 같은 미니게임 SFX를 짧은 간격으로 순차 재생할 수 있게 했다.
- `scenes/BaccaratTable.gd`: 베팅 시 선택 칩이 테이블 베팅 영역으로 날아가는 짧은 칩 이동 연출, 코인 SFX, 약한 게임패드 진동을 추가했다. 카드 공개는 플레이어/뱅커 방향에 맞춰 좌우에서 미끄러져 들어오는 애니메이션으로 교체했다.
- `scenes/BlackjackTable.gd`: 첫 딜 카드 SFX를 4회 순차 재생하고, 베팅/더블다운/스플릿 시 칩 이동·코인 SFX·진동을 추가했다. 딜러/플레이어 카드는 슈 방향에서 슬라이드 인하도록 보정했다.
- `scenes/HoldemClub.gd`: 블라인드/콜/레이즈/보드 공개/쇼다운 SFX를 카지노 카드·칩 계열로 정리하고, 콜/레이즈에 약한 진동과 칩 피드백을 추가했다.
- `scenes/BigWheelGame.gd`: 결과 메시지를 잔액 라인과 겹치지 않도록 상향 배치했다.
- `scenes/RouletteTable.gd`: 결과 메시지가 베팅/잔액 정보와 겹치지 않도록 메시지 표시 중 하단 정보 라인을 잠시 숨기게 했다.

### 검증
- `CompileCheck.tscn` 통과.
- `ScreenshotQA.tscn -- --qa=casino-en` 실행 완료. 바카라/블랙잭/룰렛/빅휠 영어 캡처 직접 확인. 종료 시 기존 Godot RID/Texture cleanup 경고는 남지만 exit code 0.

---

## 2026-06-28 (Codex Demo AP Loop + CTA Surface Pass)

### 수정
- `scenes/MainGame.gd`: AP 화면의 메인 날짜를 `2026-03 W1` / `2026년 3월 1주차`처럼 주차 기준으로 명확히 표시하도록 수정했다.
- `scenes/MainGame.gd`: AP 화면 상단에 `이번 주 / This Week` 포커스 카드를 추가했다. 남은 선택 수, 월 현금흐름, 총자산, 추천 행동을 버튼 목록 위에 묶어 초견 유저가 다음 행동을 바로 읽게 했다.
- `scenes/MainGame.gd`: AP 화면 본문에 남아 있던 `Monthly net`/`이번 달 추천`류 문구를 `Month cashflow`/주간 추천 카드 구조로 정리했다. 패드 힌트도 `Next Month`가 아니라 `Next Week`로 정정했다.
- `scenes/MainGame.gd`: 데모 종료 월말 요약에 전용 안내 카드와 밝은 primary CTA 버튼을 추가했다. `6개월 기록 보기` / `See 6-Month Record`가 포커스 상태에서도 검정 글자로 읽히도록 `_primary_cta_button()`을 추가했다.
- `scenes/MainGame.gd`: 데모 최종 화면의 Steam 위시리스트 CTA를 작은 보조 버튼에서 큰 primary CTA로 격상하고, 풀버전에서 4년 반이 이어진다는 전용 안내 카드를 추가했다.
- `scenes/MainGame.gd`: 월말 요약에서 `_next_milestone_hint()`의 BBCode가 일반 Label에 그대로 노출되던 표면 버그를 제거했다.
- `tools/ScreenshotQA.gd`: `--qa=demo-flow`가 AP 루프, 데모 완료 요약, 데모 엔딩 CTA까지 캡처하도록 확장했다. AP 화면 캡처 전 타이핑을 강제로 완료해 QA PNG가 중간 문장으로 남지 않게 했다.

### 검증
- `CompileCheck.tscn` 통과.
- `python3 tools/english_hangul_audit.py` 통과: content/runtime 한글 누수 0건.
- `./tools/audit.sh` 통과: ERROR 0 / WARNING 0, 밸런스 밴드 통과, Godot 컴파일 클린.
- `LocaleSurfaceCheck.tscn` 통과.
- `ScreenshotQA.tscn -- --qa=demo-flow --lang=en` 실행 완료. `demo_en_02_ap_loop`, `demo_en_03_demo_complete_summary`, `demo_en_04_demo_ending_cta` 직접 확인.
- `ScreenshotQA.tscn` full 1280x800 실행 완료. 종료 시 기존 Godot RID/Texture cleanup 경고는 남지만 exit code 0.

---

## 2026-06-28 (Codex Demo Flow Surface QA)

### 수정
- `tools/ScreenshotQA.gd`: `--qa=demo-flow` / `--qa=demo_flow` / `--demo` 스코프를 추가했다. 영어/한국어 데모 초반 흐름을 OpeningCinematic 첫/마지막 카드 → `chapter_card_33` → `arc_intro_01~04` → `arc_chapter1_close` 순서로 캡처한다.
- `scenes/StoryMode.gd`: 챕터 카드 시 상단 HUD 패널까지 숨기고, 일반 이벤트로 돌아올 때 복원하도록 수정했다. 챕터 카드가 게임 HUD가 겹친 화면이 아니라 온전한 시네마틱 전환으로 보인다.
- `content/events/arc_events.json`, `content/events_en/arc_events.json`: `arc_intro_02_dad_call` 배경을 편의점 밤에서 고시원 방으로 교체했다. 현수 첫 만남은 실제 보유 배경에 맞춰 "공용 주방"이 아니라 "공용 주방 앞 복도"로 텍스트를 맞췄다.
- `arc_chapter1_close` KR/EN 문구를 현수가 들어간 뒤 복도에 남았다가 방으로 돌아오는 흐름으로 보정했다. 영어판 원화 표기는 `₩` 대신 `KRW` 표기로 통일했다.

### 검증
- `python3 -c "import json; ..."` 통과: KR/EN arc 이벤트 JSON 파싱 OK.
- `python3 tools/english_hangul_audit.py` 통과: content/runtime 한글 누수 0건.
- `./tools/audit.sh` 통과: ERROR 0 / WARNING 0, 밸런스 밴드 통과, Godot 컴파일 클린.
- `LocaleSurfaceCheck.tscn` 통과.
- `ScreenshotQA.tscn -- --qa=demo-flow --lang=en` 실행 완료. `demo_en_01_chapter_card_33`에서 HUD 겹침 제거 확인, `arc_intro_02_dad_call` 고시원 방, `arc_intro_04_hyunsu` 고시원 복도 확인.
- `ScreenshotQA.tscn` full 1280x800 실행 완료. 종료 시 기존 Godot RID/Texture cleanup 경고는 남지만 exit code 0.

---

## 2026-06-28 (Codex Gangnam Ink Surface Lock)

### 수정
- `docs/GANGNAM_INK_ART_DIRECTION.md`: 강남드림의 최종 표면 언어를 `Gangnam Ink`로 고정했다. 콘크리트 회색/차콜/잉크 검정/창백한 흰색 축, 이미지 생성 prompt prefix, Black/White variant 규칙, UI/전환/QA 기준을 정리했다.
- `assets/shaders/background_grade.gdshader`: 기존 desaturation/contrast 필터 위에 종이결, 잉크 번짐, pale fade, edge burn 파라미터를 추가해 여러 세대의 배경 이미지가 같은 필름을 통과한 것처럼 보이게 했다.
- `assets/shaders/moral_surface.gdshader`: Black 경로 표면 부식색을 브라운 rust에서 차가운 흑회색 ink/concrete 계열로 교체했다.
- `scenes/MainGame.gd`: `MORAL_TINT` 값에 따라 배경 grain/ink/edge burn이 강해지거나 White에서 선명도가 회복되도록 셰이더 파라미터를 연결했다.
- `docs/UI_ART_DIRECTION.md`, `docs/MORAL_TINT.md`, `docs/NEW_ASSET_REQUESTS.md`, `docs/DECISIONS.md`: 향후 이미지/CG/UI 작업이 `Gangnam Ink`를 기준으로 진행되도록 정본 문서를 연결했다.

### 검증
- `./tools/audit.sh` 통과: ERROR 0 / WARNING 0, 밸런스 밴드 통과, Godot 컴파일 클린.
- `python3 tools/english_hangul_audit.py` 통과: content/runtime 한글 누수 0건.
- `LocaleSurfaceCheck.tscn` 통과.
- `ScreenshotQA.tscn -- --qa=moral` 실행 후 Black/Gray/White/echo 캡처 확인. Black 표면이 브라운으로 새지 않고 흑회색 ink/concrete로 읽힘.
- `ScreenshotQA.tscn` full 1280x800 실행 후 영어 스토리, 이벤트, 바카라, 엔딩 컷신 캡처 확인. 종료 시 기존 Godot RID/Texture cleanup 경고는 남지만 exit code 0.

---

## 2026-06-28 (Codex Moral Surface Continuity Pass)

### 수정
- `scenes/MainGame.gd`: 본편 기본 라디얼 배경/딤 오버레이를 흑갈·남색 누아르에서 흑회색 바닥으로 낮춰 `MORAL_TINT`의 회색/흰색/검정 축과 맞췄다.
- `scenes/MainGame.gd`: 시간대 앰비언트와 이벤트 카테고리 틴트를 `_moral_signal_color()`로 저채도화해, 투자/관계/도박 같은 정보 신호는 남기되 화면 전체가 색 장식처럼 튀지 않게 했다.
- `scenes/MainGame.gd`: 선택지 구분선, 선택지 효과 미리보기, 패드 힌트, AP 행동 섹션 문구, 정보 패널 탭을 `moral_role` 기반 팔레트에 연결했다.
- `scenes/MainGame.gd`: 엔딩/데모 종료 화면의 금색·초록 보상색을 텍스트용 `_moral_text_accent()`와 테두리용 `_moral_gray_accent()`로 분리해 무채색 축으로 정리했다.
- `scenes/MainGame.gd`: Black 경로에서 HUD/선택지 아이콘이 초록빛으로 보이던 부식색을 차가운 회색으로 교체했다.
- `scenes/MainGame.gd`: 엔딩 스탯 그리드 값 라벨이 `clip_text`/최소폭 문제로 보이지 않던 렌더 버그를 수정했다.

### 검증
- `./tools/audit.sh` 통과: ERROR 0 / WARNING 0, 밸런스 밴드 통과, Godot 컴파일 클린.
- `python3 tools/english_hangul_audit.py` 통과: content/runtime 한글 누수 0건.
- `LocaleSurfaceCheck.tscn` 통과.
- `ScreenshotQA.tscn -- --qa=moral` 실행 후 `03b_moral_black`, `03c_moral_gray`, `03d_moral_white`, echo 2종 직접 확인.
- `ScreenshotQA.tscn` full 1280x800 실행 후 `00f_en_info_stats`, `04_ap_actions_dashboard`, `13_ending_gangnam_win`, `15_ending_stable_success` 직접 확인. `15_ending_stable_success`에서 엔딩 스탯 값 가독성 수정 확인.

---

## 2026-06-28 (Codex Start Surface Monochrome Pass)

### 수정
- `scenes/StartMenu.gd`: 시작 메뉴 전용 `MENU_*` 무채색 팔레트를 추가하고, 로고/스토리 패널/난이도 카드/런 테마 카드/새 게임 CTA/슬롯 포커스/콘텐츠 안내/언어 토글의 금색·초록 강조를 회색·흰색 축으로 교체했다.
- `scenes/MainGame.gd`: `_modal_section_header()`가 전달받은 색을 그대로 쓰지 않고 현재 `MORAL_TINT` 팔레트에 맞는 회색 액센트로 변환하도록 변경했다.
- `scenes/MainGame.gd`: 상점 아이템 카드의 구조 테두리·가격·구매 버튼을 무채색 계열로 낮췄다. 투자 장세/손익 같은 정보색은 의미 신호라 유지했다.

### 검증
- `CompileCheck.tscn` 통과.
- `ScreenshotQA.tscn` full 1280x800 캡처 완료. `00_start_menu`, `00b_start_menu_en`, `02_investment_portfolio_chart`, `02b_shop_modal`, `04_ap_actions_dashboard` 직접 확인.
- `LocaleSurfaceCheck`, `AudioAssetCheck`, `BGMContinuityCheck` 통과.

---

## 2026-06-28 (Codex MORAL_TINT Visual Link)

### 수정
- `scenes/MainGame.gd`: `GameState.moral_tint_changed(norm, stage)`를 구독해 `MORAL_TINT` 값을 실제 화면에 연결했다.
- 배경 전역 필터를 추가해 Black 쪽은 차갑고 어둡게, White 쪽은 따뜻하게 보이도록 조정했다. UI 텍스트 가독성을 해치지 않도록 필터는 메인 UI 아래 레이어에 배치했다.
- Black stage에서는 돈 HUD와 목표 자산 숫자만 형광 녹색으로 밝아지게 해 "돈만 밝아지는" 주제문을 화면에 반영했다. White stage에서는 같은 영역을 따뜻한 아이보리 톤으로 낮췄다.
- 엔딩 모달 진입 시 최종 moral stage에 따라 딤 오버레이, 패널 테두리, 타이틀 색을 바꾸도록 했다.
- `tools/ScreenshotQA.gd`: `--qa=moral` 스코프를 추가해 Black/Gray/White 3상태와 Black/White 선택 직후 echo 캡처를 빠르게 생성할 수 있게 했다.
- 2차 수정: 단순 배경 틴트가 아니라 상단 HUD/초상화 패널/선택지 카드/버튼/뱃지까지 moral palette를 적용하도록 확장했다. White는 브라운/골드가 아닌 청백색 선명도 계열로 보정했다.
- `assets/shaders/moral_surface.gdshader`: Black 쪽 표면 부식·긁힘·가장자리 어둠, White 쪽 중심부 선명도 레이어를 추가했다.
- 3차 수정: 기본 비주얼 언어를 금색·남색 누아르에서 무채색 moral spectrum으로 재정의했다. 회색/진회색/검정/연회색/흰색이 기본 상태가 되도록 주요 HUD/목표바/선택지 색과 메인 루프 이모지·금색 힌트를 정리했다.
- `assets/shaders/background_grade.gdshader`: 이벤트 배경 이미지 자체를 desaturation/brightness/contrast로 그레이딩해, UI만 바뀌고 배경은 기존 색으로 남는 문제를 줄였다.
- 4차 수정: `MORAL_TINT`가 단순 정적 필터로 보이지 않도록 선택 직후 actual tint delta를 감지해 짧은 화면 반응을 추가했다. Black 방향 선택은 화면이 잠깐 꺼지고 표면 부식이 치솟으며 돈 HUD가 맥박처럼 밝아진다. White 방향 선택은 본문/타이틀과 표면 선명도가 잠깐 맑아진다. 숫자·게이지·설명문은 추가하지 않았다.

### 검증
- `CompileCheck.tscn` 통과.
- `audit.py` ERROR 0 / WARNING 0.
- `english_hangul_audit.py` 통과.
- `VisualCropQA.tscn` 통과.
- `ScreenshotQA.tscn -- --qa=moral` 실행 완료. `03b_moral_black`, `03c_moral_gray`, `03d_moral_white`, `03e_moral_black_choice_echo`, `03f_moral_white_choice_echo` 직접 확인.

---

## 2026-06-28 (Codex English Casino Surface QA)

### 수정
- `tools/ScreenshotQA.gd`: 카지노 전용 QA에 `--qa=casino-en` / `--qa=casino --lang=en` 모드를 추가. 영어 카지노 허브와 바카라/블랙잭/슬롯/룰렛/빅휠/다이사이 캡처를 `en_` 접두사로 생성해 외국 유저 표면 QA를 빠르게 반복할 수 있게 했다.
- `scenes/JeongseonCasino.gd`: 영어 허브 잔액/세션 손익 표기를 `₩5,000,000` 대신 `KRW 5.0M` 계열의 `GameState.format_money()`로 통일.
- `scenes/SlotMachineGame.gd`: 슬롯 하단 잔액 문구의 `₩KRW 10.0M` 중복 통화 표기 제거.
- `tools/ScreenshotQA.gd`: 슬롯 QA 강제 당첨 데이터의 `체리 2개` 문자열을 로케일 기반 `2 Cherries`로 전환.

### 검증
- `CompileCheck.tscn` 통과.
- `english_hangul_audit.py` 통과.
- `audit.py` ERROR 0 / WARNING 0.
- `ScreenshotQA.tscn -- --qa=casino-en` 실행 완료. `en_08_jeongseon_casino`, `en_11_slot_machine`, `en_12_roulette_spin`, `en_12b_daisai_table` 직접 확인.

---

## 2026-06-27 (Codex Final Surface QA Pass 1)

### 수정
- `tools/LocaleSurfaceCheck.gd`, `tools/ScreenshotQA.gd`: QA 언어 전환을 `LocaleManager.language` 직접 대입에서 실제 저장 설정 경로인 `LocaleManager.set_language()`로 변경. 영어 시작 화면/오프닝 검사가 실제 사용자 경로와 맞도록 정리.
- `scenes/MainGame.gd`: 첫 월급 후 영어 힌트의 이모지/대괄호 기반 표기를 제거하고 `First paycheck received — Invest is now available.`로 단순화.
- `scenes/MainGame.gd`: 공통 모달의 빨간 X 버튼을 어두운 버튼으로 낮춰, 일반 모달/엔딩이 위급 경고처럼 보이지 않게 수정.
- `scenes/MainGame.gd`: 엔딩 화면을 `Finale/최종 기록` 전용 대형 시네마틱 모달로 조정. 패널 980×720, CG 높이 430, 금색 테두리/강한 딤 오버레이 적용.
- `scenes/MainGame.gd`: 좌측 초상화 패널을 196px→224px, 초상화 높이를 248px→310px로 확대해 캐릭터 존재감을 강화.
- `docs/PLAYER_FACING_POLISH_AUDIT.md`: 2026-06-27 실제 렌더 QA 결과와 남은 외형 우선순위 기록.

### 검증
- `CompileCheck.tscn` 통과.
- `LocaleSurfaceCheck.tscn` 통과.
- `VisualCropQA.tscn` 통과.
- `ScreenshotQA.tscn` full 1280×800 캡처 완료. `00c_en_ap_actions`, `04_ap_actions_dashboard`, `13_ending_gangnam_win` 직접 확인.

---

## 2026-06-27 (Blackjack Table Shape Polish)

### 수정
- `scenes/BlackjackTable.gd`: 블랙잭 베팅 매트 중앙의 원형 아크/가이드 느낌 도형을 제거하고, 실제 테이블에 가까운 직사각형 `BETTING SPOT` 패널로 교체.
- 베팅 매트 왼쪽의 임시 딜러 실루엣/팔 선을 제거하고 낮은 대비의 `DEALER AREA` 박스로 정리.
- 블랙잭 액션/결과 배너 위치를 테이블 카드 영역 아래쪽으로 내려 카드가 가려지지 않도록 수정.

### 검증
- `CompileCheck.tscn` 통과.
- 카지노 전용 `ScreenshotQA` 실행 완료. `10a_blackjack_betting`, `10_blackjack_table` 직접 확인.

---
## 2026-06-24 (다은/지연 로맨스 상호배타 + 지연 Y4-Y5 아크 완성)

### 수정 내용

#### 한지연 Y4-Y5 아크 신규 이벤트 4종
- `arc_jiyeon_year4_call` (t>=145): Y4 부산 첫 전화 — 3가지 반응, `jiyeon_year4_wants_more` 플래그
- `arc_jiyeon_year4_seoul` (t165-192, 표준): 서울 방문 — 연인 인정 → `lover`/`jiyeon_lovers_acknowledged`, 아름다운 이별 → `jiyeon_beautifully_apart`, 침묵 → `distant`
- `arc_jiyeon_year4_seoul_daeun` (t165-192, 다은 갈등): 다은 연인 경로 전용 — 솔직 고백 +5 → `jiyeon_respectfully_distanced`/`respected`, 침묵 -5 → `jiyeon_hidden_feelings`/`close`
- `arc_jiyeon_year5_return` (Y5, lover 경로): "강남에서 봐요" → `jiyeon_gangnam_together`
- `arc_jiyeon_year5_news` (Y5, 비연인 경로): 부산 소식 + `description_if_known` 2종(솔직한 작별 / 침묵의 무게)

#### 다은/지연 상호배타 dispatch 분기
- `_next_arc_id()` t165-192 블록: `daeun_together_path`/`lover`/`together`/`committed` → `arc_jiyeon_year4_seoul_daeun`; 아니면 조건부 `arc_jiyeon_year4_seoul`
- 최종 엔딩에서 두 로맨스 동시 진행 불가 — 다은 연인 경로 플레이어는 지연에게 솔직해지거나 침묵하는 선택만 가능

#### description_if_known 전환 (write-only→read)
- `arc_jiyeon_year5_news`: `jiyeon_respectfully_distanced` / `jiyeon_hidden_feelings` 두 플래그 소비 — 갈등 씬 선택이 Y5 소식 반응에 반영
- KR+EN 동기화
- write-only 226 baseline 유지 (두 플래그 all read로 전환)

### 결과
- 지연 아크 Y1→Y5 완전 연결 (Y4-Y5 공백 해소)
- 다은 연인 경로 ↔ 지연 로맬스 상호배타 보장
- `jiyeon_man` 엔딩 `lover` stage도 포함 (GameState.gd)
- audit ERROR 0 / WARNING 0 / 밴드 통과

---

## 2026-06-24 (MORAL_TINT 6차 확장 — shadow/chain/butterfly/NG+ 고도덕강도 이벤트 + cut_sangchul_network 엔딩 변주)

### 수정 내용

#### MORAL_TINT 선택지 tint 추가 (34개 선택지)
- **shadow_events.json** (8개): 사채업자 응대/모른 척/직접고발, 오래된 약속 솔직/시간끌기, 신고 vs 체념 등
- **work_events.json** (1개): `work_credit_stolen` — 팀장에게 직접 이야기하기 +4
- **story_events.json** (2개): 프롤로그 아버지 전화 — 챙기는 말 +2 / 짧게 끊기 -2
- **butterfly_events.json** (5개): 내부정보 거절 +2/구입 -5, 사기 확인 시 신고 +5/바로 투자 -6
- **chain_events.json** (8개): 임원 식사 솔직 +5/둘러대기 -3, 봉투 돌려줌 +8/못 본 척 -8, 사기꾼 제보 +6/지나침 -5
- **drama_events.json** (2개): 도박 회복 직후 솔직 고백 +5 / 자리 피함 -2
- **ng_plus_events.json** (8개): 상철 모른 척(알면서 이용) -6 / 직접 대면 +7, 아버지 전화 주말 방문 +3 / 짧게 끊기 -2, 카지노 거부 +3 / 자기기만으로 재입장 -4, 낯선 도박꾼에게 손 내밀기 +5 / 외면 -3

#### cut_sangchul_network 엔딩 발견 레이어 (endings.json + endings_en.json)
- `stable_success`, `ordinary_life`, `balanced_life` 3개 엔딩에 `description_if_known["cut_sangchul_network"]` 변주 추가(KR+EN)
- 상철 네트워크를 스스로 끊은 플레이어가 각 엔딩에서 "그 출처를 설명할 수 없는 돈은 없다"는 자각으로 읽힘

### 결과
- tint 커버리지 약 610+/3170+ 선택지 (~19-20%)
- `cut_sangchul_network` 플래그: write-only → 엔딩 3종이 읽어 부채 해소
- audit ERROR 0 / WARNING 0 / 밸런스 밴드 전부 통과

---

## 2026-06-24 (서사 무결성 수정 5종 — 내러티브 QA 후속 픽스)

### 수정 내용

#### [HIGH] 다은 아크 데드엔드 2건
1. `arc_daeun_04_morning` choice 2 ("노트북을 연다")가 `daeun_together_path` 플래그를 설정하지 않아
   Y3~Y5 연속 아크(`arc_daeun_year3_together`→`year4`→`year5`)가 완전히 잘려나가는 데드엔드 수정.
   → choice 2 flags에 `daeun_together_path` 추가.

2. `arc_daeun_year3_apart` 트리거가 `arc_daeun_ghost_seen`을 요구했는데,
   이 플래그는 `daeun_let_her_go` 경로에서만 설정됨.
   `daeun_breakup_accepted`(명시적 이별) 경로는 ghost 씬 없이도 year3_apart 진입해야 하는데 막혀 있었음.
   → `(arc_daeun_ghost_seen OR daeun_breakup_accepted)` OR 조건으로 수정.

#### [HIGH] 상철 타임라인 수학적 모순
`arc_sangchul_deduction` + `arc_father_06_confession` 두 곳에서
"5년 전 아버지를 무너뜨렸다"고 하는데, 아버지 빚 상환 기간이 6년으로 명시돼 있어 수학적으로 불가능.
→ "5년 전" → "몇 년 전"으로 수정(2곳, arc_drama.json).

#### [MED] Y5 echo 4종 시간 표현 오류
Y3(35세) 씬에서 나온 선택에 대한 echo가 Y5(37세)에 발동하면서 "작년에"로 언급.
Y3→Y5는 2년 간격이므로 "작년"은 사실 오류.
→ cb_weight_stayed/adjusted + cb_cost_embraced/reclaimed echo 4종:
   "작년 이맘때" → "2년 전 이맘때", "작년에" → "2년 전," , "1년이 더 지났다" → "2년이 더 지났다"
   (KR + EN 동기화, content/events/callback_chapter_themes.json + content/events_en/callback_chapter_themes.json)

#### [MED] arc_34_two_years_in 윈도우 starved 방지
윈도우 t89-96이 높은 우선순위 씬들(two_years_mark 등)에 의해 잘릴 수 있어 발동 불가 가능성.
→ t89-100으로 상한 확장 (scenes/MainGame.gd).

### 검증
- audit.sh: ERROR 0, WARNING 0, write_only 210 baseline 유지, 밴드 전부 통과
- arc_flow_sim.py: 잼 0, 대표 체인 완결 (Path A Y1=47/Y2=24/Y3=12/Y4=12/Y5=9, Path B 유사)
- JSON 파싱: 전부 valid

---

## 2026-06-24 (전 구간 무결성 검증 — 턴별 _next_arc_id 시뮬레이터로 2개 주요 경로 정밀 추적)

### 목적
"껍데기만 채운 게 아니라 처음부터 끝까지 탄탄한가"를 정량 검증. 보장 비트 개수만 세는 게 아니라
실제 한 플레이가 240턴 동안 어떤 아크가 발동되는지 턴별로 시뮬레이션.

### 방법
`_next_arc_id()`를 들여쓰기-인식 파서로 추출(중첩 if·백슬래시 연속행·inline if 처리),
이벤트 JSON에서 self-guard 플래그를 ground-truth로 추출, 상태 궤적(자산/route/직업/주거/호감도)과
스파인 선택 플래그를 스크립트로 구동해 GDScript 조건을 Python에서 충실히 평가.

### 발견 (구조)
- **잼(같은 아크 반복 발동) 0건** — 두 경로 모두. (초기 시뮬의 t1부터 orthodox_weight 무한반복은
  중첩 if를 못 읽은 **시뮬레이터 파서 버그**였고, 게임 자체는 정상 — 윈도우 가드 정상 작동 확인.)
- **데드엔드/고아 아크 0건** — 모든 아크가 도달 가능, 발동 후 _seen으로 재발동 차단.
- **빈 턴은 랜덤풀로 충전** — Y3~Y5 가용 풀 ~900개. 빈 화면/반복 없음.

### 발견 (페이싱 — 의도된 front-load, 단 확인됨)
실제 한 경로의 연차별 "authored 아크 발동 턴" 수:
| | Path A(정석/다은 보냄/사기당함) | Path B(비정석/진실/다은 함께) |
|--|--|--|
| Y1 | 47/48 | 47/48 |
| Y2 | 24 | 23 |
| Y3 | 12 | 12 |
| Y4 | 12 | 13 |
| Y5 | 8 | 9 |
- 밀집 도입(Y1) → 구두점식 그라인드(Y3~5). 큰 침묵 구간(t125~137/t169~189/t196~209/t223~240)은
  랜덤풀+마일스톤+엔드게임 비트가 메움. 엔드게임 비트(final_year_start/reckoning/burn_or_light/
  six_months/ending_peace/gangnam_real_estate)는 자산 반응형으로 잘 escalate — shell 아님.

### 발견 (캐릭터 아크 완결성 — 양 경로 start→finish)
- **Path B 진실 아크 완결**: deduction(t30)→known_offer(t38)→known_reflex(t51)→confrontation(t60)→year3(t101).
- **Path B 다은 committed 5년 관통**: fork(t23)→future(t42)→year3(t103)→year4(t147)→year5(t195).
- **Y5 echo 콜백 페이오프 확인**: Path B에서 adjusted_my_path/reclaimed_cost/crack_softened/accepted_grace
  4개 stance 플래그 전부 set → 마지막 해 echo가 실제로 발동·회수됨.
- 신규 테마 6씬 전부 정확한 연차에 안착(Y2 확장 t63/t74, Y3 무게 t108/t124, Y4 균열 t151/t156).

### 결론
구조는 양대 경로에서 처음부터 끝까지 탄탄(잼·데드엔드·고아·빈화면 0, 아크 완결, 테마·echo 회수).
front-load는 의도적·방어 가능한 페이싱이며, 추가 reflection 비트는 오히려 "shell"이 될 위험이 커
이번 라운드는 **검증으로 마무리**(불필요한 패딩 지양).

### 산출물: `tools/arc_flow_sim.py` (영구 회귀 도구)
시뮬레이터를 scratchpad→tools로 승격. 2개 캐논 경로(A 정석/다은보냄/사기, B 비정석/진실/committed)에서
아크 잼(같은 아크 반복 발동=윈도우/가드 버그)과 대표 체인 미완결을 검출, 발견 시 종료코드 1.
중첩 if를 못 읽으면 잼으로 드러나므로 이번 같은 _next_arc_id 구조 회귀를 CI에서 빨리 잡는다.

## 2026-06-24 (연차별 챕터 테마 분배 — 챕터2~4 테마 씬 신설 + Y5 echo 콜백)

### 문제 진단 (연차별 콘텐츠/스토리 분배 점검)
- `_next_arc_id()` 보장 스토리 비트(턴만으로 게이트, 모든 플레이 공통) 연차별 집계:
  - **Before**: Y1=34, Y2=8, Y3=6, Y4=8, Y5=7 — Y2~Y5가 일반 마커(생일/루틴/연도)뿐, **챕터 카드 테마(확장/무게/균열)를 직접 구현하는 씬이 없음**.
- 챕터 카드는 Y2="확장(돈이 돈을, 사람이 기회)", Y3="무게(선택한 길의 대가)", Y4="균열(믿었던 사람이 흔든다)"를 약속하나 실제 콘텐츠가 부재.

### 신규 콘텐츠 (17개 이벤트, KR+EN, 전부 챕터 테마 직결)
**Y3 "무게" (3종, route 반응형)** — `arc_chapter_themes.json`
- `arc_35_orthodox_weight`(정석 우세, t108~138): 지루함의 무게. `arc_35_unorthodox_weight`(비정석 우세): 불안의 무게. route 합산 비교로 분기.
- `arc_35_path_cost`(t124~144): 3년치 잃은 것의 영수증 (무조건).

**Y4 "균열" (2종)** — 챕터4 카드 직결
- `arc_36_trust_crack`(t150~178): 믿었던 사람이 흔든다 (끊다/이해하다/거리두다).
- `arc_36_unexpected_hand`(t156~188, trust_crack 이후): 예상치 못한 사람이 잡는다.

**Y2 "확장" (2종)** — 챕터2 카드 직결
- `arc_34_money_attracts_money`(t54~74): 돈이 돈을 부른다 + 출발선 격차 자각.
- `arc_34_doors_open`(t74~94): 기회는 사람을 통해 온다.

**Y5 echo 콜백 (8종)** — `callback_chapter_themes.json`, 위 선택의 stance 플래그를 마지막 해에 페이오프
- 8개 cluster 플래그(stayed_my_path/adjusted_my_path/embraced_cost/reclaimed_cost/crack_hardened/crack_softened/crack_distanced/accepted_grace)를 전부 읽음 → write-only 부채 0.
- grace echo: 1년 전 받은 손을 이번엔 내가 내미는 pay-it-forward (tint +6).

### 결과
- **After**: Y1=34, Y2=10, Y3=9, Y4=10, Y5=7(+echo 8). Y2~Y4 균형(9~10), 각 연차가 고유 챕터 테마를 보장 씬으로 전달.
- 5막 구조 명확화: Y1 시작/도입 → Y2 확장 → Y3 무게 → Y4 균열 → Y5 강남/정산.
- write-only 플래그 210 유지(echo가 전부 소비), audit ERROR 0/WARNING 0, 밸런스 밴드 통과.

## 2026-06-23 (자율 사각지대 감사 + MORAL_TINT 4차 확장 63개 + 진엔딩 자산 버그 수정)

### 자율 감사 발견사항 (전수 점검)
1. **17개 조건 플래그 → 전부 합법** (cafe/coin은 opportunity win_flag/lose_flag, jeongseon은 GDScript, is_repeat_run/housing_moved_once는 GameState, formed_whole_picture는 thoughts.json)
2. **gangnam_penthouse 배경 ID 버그** — endings.json `full_circle`이 ImageRegistry에 없는 ID 사용 → `gangnam_penthouse` 알리아스 추가 (penthouse_view.png로 매핑)
3. **아크 체인 전수** — _next_arc_id() 반환 158개 ID 전부 JSON에 존재
4. **이벤트 조건 모순 0건** — min_money>max_money, 동일 flag/no_flag, min_turn>max_turn 없음
5. **중복 ID 0건** (KR/EN 오버레이 쌍은 의도된 중복)
6. **NG+ full_circle 체인 확인** — MetaProgression.sangchul_truth_ever_known + ng_plus_events.json 완전 배선
7. **thoughts.json 체인 확인** — clue 3종 전부 이벤트 choice flags로 설정됨

### MORAL_TINT 4차 확장 (63개 tint, KR+EN 동기화)
**1차 배치 (25개)** — 최고가중치 이벤트 14종:
- life_events: chapter_break_30(반환점 +4/+3), chapter_break_45(5년의미+5), father_wedding_call(아버지전화+5/-3), father_missed_chance(입원+8/-6), are_you_happy(모르겠다+2/아니다+4), orthodox_promotion_mirror(거울+4/-2), orthodox_overtime_fomo(야근+2/-1), orthodox_award_ceremony(서랍+3), orthodox_senior_farewell(선배+2/-1)
- investment_events: invest_first_win(확정+1/-2), invest_first_loss(버팀+1)
- relationship_events: daeun_regular(말받기+3/-1), daeun_share(내얘기+5/-3), daeun_feeling(나간다+4/-3)

**2차 배치 (38개)** — weight=8 이벤트 16종:
- relationship_events: family_007(병원비 대출+6/솔직+4/-3), social_life_001(+1/-1), jobs_010(경청+2), jobs_026(박씨유튜브+2/-3), romance_017(먼저카톡+3/약속+2), romance_020(빗속+4/기다림+2/+1), romance_029(뒤집기+1/-1)
- life_events: family_013(집안병원비+4/죄책감+2/형편껏+3), jobs_036(야근카톡: 솔직+4/네-3/퇴근+2/-1), disasters_020(전세사기: 확인+2/-3/전화+3/닫는다-4), jobs_014(억울-2/당당+3), finance_033(조용히+1/-1), family_035(일찍자리+2/둘러대기-1), jobs_025(계획+1/사직서+2), finance_011(차분+1/-1), military_007(-1)

### 전체 tint 커버리지
- **347/3090 선택지 (11.2%)** (이전 284 → 9.2%)

---

## 2026-06-23 (MORAL_TINT 딥 점검 + 3차 스파인 확장 52개)

### 자율 점검 발견사항 7종
1. `gambling_006[0]` — MORAL_TINT.md §2 직접 명시 "사기 제안 거절 +6" 누락
2. `father_health_call` / `father_first_visit` — life_events 아버지 씬 tint 없음
3. `sangchul_why_gangnam[0]` — 아버지 사기 고백 핵심 감정 씬 tint 없음
4. `cafe_talk_01` / `cafe_bluff_01` — scenario_cafe 인터트 이벤트 (effects: {} 기계적 null + tint 기회)
5. `arc_jaehyuk_04a/04b/04c` — 재혁 사기 대응 3씬 tint 없음
6. `write_only_flags` 211 vs baseline 211 — 래칫 조임 기회
7. EN 오버레이 커버리지: KR 전체 ID 포함 확인 (정상)

### 구현 (52개 tint, KR+EN 동기화)
- life_events.json (17개): gambling사기차단+6, 아버지 방문+8, 솔직힘들다+5, 야근약속+4, 동창회 솔직+4, 아버지건강전화+5
- relationship_events.json (20개): 상철 아버지사기고백+7, 지연 솔직+5, 다은 드리프트 연락+4, 명절 약속+4, 멘토 솔직+5
- scenario_cafe.json (5개): 솔직무직+4/있는척-3, 모른다고+5/아는척-4
- scenario_cafe_callback.json (2개): 훔친번호 양심 +4, 아직이다 정직 +3
- arc_events.json (6개): 재혁대응 경찰+6/협박-5/합류(crossed_line)-8

### 구조 부채
- `debt_baseline.json` write_only_flags 211→210 (톱니 조임)

### 전체 tint 커버리지
- 284/3090 선택지 (9.2%)

---

## 2026-06-23 (MORAL_TINT 스파인 확장 2차 — arc_events + arc_midgame)

### 추가 tint 저작 (58개 선택지 KR+EN)
- arc_events.json (33개): 아버지 아크 전 5씬(call/signal/hospital/visit/after), 재혁 pitch(통장털어 -5/일부만 +2), 지연 epilogue 3선택지, 자소서 정직(3년 이유 그대로 +4), 상철 도움 거절(혼자 하겠다 +5), KTX 즉시 예매 +8
- arc_midgame.json (25개): 첫 수익 아버지 전화 +6, 외로움→아버지 전화 +5, 약 전달 직접 +5, 35세 생일 아버지 +5, 37세 평화 +4, 다은 솔직 고백 +7, 현수 진심 응원 +4, 더 묻는다 +5, 지침 인정 +3, 소셜 비교 진심 +4
- EN 오버레이 58개 자동 동기화

### 전체 tint 커버리지
- 232/3090 선택지 (7.5%)
- 서사 핵심 파일(arc_drama/daeun/gambling/addiction/hyunsu/pre_ending/year3): 100%
- audit ERROR 0 / WARNING 0 / 밸런스 밴드 전부 통과

---

## 2026-06-23 (MORAL_TINT 스파인 확장 + White/Black 시뮬 검증)

### 스파인 확장 (57개 선택지 KR+EN tint 저작)
- arc_daeun.json (12개 이벤트): 갈림길 붙잡음 +9/보냄 -7, 30억전날밤 "같이 이룬 거야" +8 등
- arc_daeun_extension.json (5개): year3~5 전 씬 tint 배선
- arc_new_characters.json (6개): 재원 지혜나눔 +7, 솔직털어놓기 +6, 민서 편한칭찬 -2/진실요청 +6
- arc_year3_drama.json (3개): 상철year3, 지연year3, 아버지 레거시
- EN 오버레이 57개 자동 동기화

### White/Black 30억 시뮬 검증 (N=3000)
- 혼합(70% White선택): 15.3% 30억 도달, 승자 평균 tint +54.8
- 순수 White (착취 거절·수입 -12%): 0.1% 30억 도달 — "가능하되 극악" 설계 의도 확인
- Black 베팅: 14.8% (기존 밴드 유지)

### 용어 통일
- 문서 전체 "하양" → White, "검정" → Black

---

## 2026-06-23 (MORAL_TINT 밴드 전이 비네트)

### 구현
- `GameState.shift_moral_tint()` — 밴드 경계(0/±1/±2) 넘을 때 `pending_tint_vignette: {from, to}` 기록
- `MainGame._on_result_confirmed()` — vignette 있으면 `_render_event()` 전에 `_show_moral_beat()` 선점
- `_show_moral_beat(from, to)` — 조용한 패널, 빈 제목, "…" 확인 버튼, 스탯/숫자 없음
- `_moral_beat_text()` 비네트 3종 KR+EN:
  - 0→−1: "밥을 먹는데 맛이 안 났다. 그냥 연료 같았다."
  - −1→−2: "거울을 봤다. 5년 전 라면 먹던 얼굴이 안 떠올랐다."
  - 회복(음→양): "오랜만에 통화 끝에 웃었다. 웃는 게 어색했다는 걸, 웃고 나서 알았다."
- `audit.py SERIALIZE_EXEMPT` — pending_tint_vignette 트랜지언트 등록
- 헤드리스 밴드 감지 검증 + xvfb 비트 패널 렌더 검증 완료

---

## 2026-06-23 (★MORAL_TINT 신규 시스템 — 엔진 코어 + 수직 슬라이스)

### 설계 (docs/MORAL_TINT.md)
- "가질수록 나를 잃는다. 회색 시작 → 인간성=하양 / 돈=검정. 30억 쥐었을 때 화면 색이 진짜 결말."
- DE 무관 고유 시스템. 플레이어에겐 숫자 미노출, 오직 테마색으로만.
- 네 칸 매트릭스(tint×30억)가 기존 엔딩 변주(jaehyuk_way/late_call 2/gangnam_dream 3)와 맞물림

### 엔진 코어 (GameState)
- `moral_tint: float` −100(검정/돈) ~ 0(회색/시작) ~ +100(하양/인간)
- `shift_moral_tint(delta)` — clamp + 흉터 상한
- 흉터(영구): crossed_line→상한 −20(양수 불가), chose_money_over_father→상한 0(하양 불가)
- `moral_stage()` −2~+2 (이산), `moral_tint_norm()` −1~+1 (Codex 보간)
- apply_effects에 `tint` 효과 키 추가
- serialize/load/start_new_game 반영, moral_band_last(전이 비네트용) 추가

### 수직 슬라이스 tint 저작
- 상철: known_offer(집음 −8/거절 +6), reflex(자기기만 −2/합리화 −5/정직 +4),
  confrontation(묻음 −3/떠남 +8), reckoning(신고 +8/용서 +5/레버리지 −8), mirror(부정 +2)
- 아버지 병원: 달려감 +10 / 상철인맥 −6 / 돈만 −4 / 미룸 −2

### 헤드리스 검증 (전부 통과)
- 누적(−8×3=−24, stage −1), 회복(+10→−14, stage 0), 깊은 검정(−74, stage −2)
- 흉터: crossed_line+200→−20 상한 / death-ignored+50→0 상한
- serialize 라운드트립(−33, band_last −1)

### Codex 핸드오프
- NEW_ASSET_REQUESTS.md에 시각 스펙: moral_tint_norm()/moral_stage() 구독 →
  테마색 보간 + 돈 글로우 반비례 + stage −2 틀어짐 + 엔딩 팔레트

### audit ERROR 0 / Godot 55개 컴파일 클린 / 게임 동작 무변(값만 쌓임)

## 2026-06-23 (데모 빌드 export QA — Windows + Linux/Steam Deck)

### export 환경
- export 템플릿 4.6.2.stable 설치 확인, export_presets.cfg 4종(Win/macOS/Web/Linux) 존재

### Linux / Steam Deck 빌드 (네이티브 타깃)
- godot --headless --import → --export-release "Linux / Steam Deck"
- 산출: build/linux/GangnamDream.x86_64 (167MB ELF 64-bit)
- xvfb 실행 검증: 18초 메인루프 부팅, SCRIPT/Parse/Compile/Load 에러 0
  (exit 124=timeout 강제종료=정상 구동 중이었음)
- 패키징된 빌드가 에디터가 아닌 독립 실행에서도 무에러 부팅 확인

### Windows 빌드 (주요 Steam 데스크톱 타깃)
- --export-release "Windows" → build/windows/GangnamDream.exe (201MB PE32+ x86-64)
- 패키징 성공(project.binary 저장 완료)

### 비고
- 빌드 산출물은 .gitignore 처리됨(git check-ignore 확인) — 미커밋, QA 후 삭제
- 패키지 빌드는 메인씬 baked-in이라 임의 씬 인자 미수용 → 데모 콘텐츠 시각 검증은
  source ScreenshotQA(동일 코드/데이터)로 기검증분 활용
- 두 주요 Steam 타깃(Windows 데스크톱 + Linux/Steam Deck) 패키징·실행 모두 통과

## 2026-06-23 (다은/지연/재혁 아크 reachability 트레이스 — 데드엔드 없음 확정)

### 점검 방법
- 각 인물 _next_arc_id 트리거의 상한 윈도우(t<=X) 전수 추출
- 바운드 윈도우는 선행 _seen 플래그가 윈도우 안에 도착 가능한지 trace

### 다은 아크 — 데드엔드 없음
- 01_meet(t9)→02_regular(t15,affinity≥8)→03_fork(t23,affinity≥12)→
  03b_date/04_morning/04b_future/ghost/regret/05_* 전부 하한(t>=)만
- affinity 게이트는 의도된 관계-상태 게이트(저친밀=미심화). 윈도우 데드엔드 아님

### 지연 아크 — 데드엔드 없음
- 01_crash(t17)→02_store(t26)→03_offer(t36)→03b_lunch(t40) 전부 하한만
- 03b_lunch는 sangchul_jiyeon_reveal과 either/or (동일 비트 — 정상 분기)

### 재혁 아크 — 바운드 1개(wait t38~41), 코어는 안전
- reunion(t19)→bond(t32)→pitch(t37)→[wait t38~41]→hyunsu_warning(t39)→ghost(t42)→standup(t44)
- wait만 상한 윈도우. pitch가 아크 경쟁으로 지연되면 wait 스킵 가능
- 트레이스: pitch t37/t40 → wait+코어 전부 도달 / pitch t42(심한 지연) → wait 스킵,
  but ghost→standup 코어 도달 ✓
- ghost(invested 플래그, 하한만)·standup(ghost_seen, 하한만)은 열린 윈도우 — 항상 도달
- 결론: wait는 선택적 페이싱 비트(투자 후 불안의 일주일). pitch가 늦으면 그 비트 자체가
  서사적으로 안 맞음(reveal 임박) → 스킵 허용. 코어 아크 무손상. 수정 불요

### 종합: 4개 인물 아크 중 데드엔드는 상철 known_offer뿐(직전 수정 완료). 나머지 3개 안전.

## 2026-06-23 (상철 진실 아크 타임라인 reachability 점검 + 데드엔드 수정)

### 전체 체인 매핑
- 01_meet(t10)→02_coffee(t14)→03_network(t20,자산≥100만)→deduction(t26~50,지력55/비정통20)
- offguard(t26)→human(t30~42)
- known_offer(t38~55,truth+human_seen)→reflex(t50~59)→confrontation(t60)→reckoning→엔딩

### 발견한 데드엔드
- 네트워크(03) 합류가 늦으면(자산<100만 장기) offguard도 늦어지고
  human 윈도우(t30~42)를 놓침 → human_seen 미설정 → known_offer 영구 스킵
- 100만 자산은 보통 일찍 충족되나, 장기 빈곤+추론적격(지력55) 교집합에서 발생

### 수정: arc_sangchul_human 상한 t42→t52
- 일반 케이스(human t30 발동)는 무영향 — 첫 적격 턴에 발동하므로
- 늦은 합류(offguard ~t51까지)만 구제

### 오프라인 트레이스 검증 (함수 순서·매 턴 첫 매치 모델)
- 조기 네트워크(t20): offer(t38)/reflex(t50)/confrontation(t60) 전부 ✓
- 늦은 네트워크(t40): offer(t44)/reflex/confrontation ✓ (기존 t42캡이면 데드엔드)
- 매우 늦은(t48): human(t51)/offer(t52)/reflex(t53) — t52 확장이 구제 ✓
- 추론 안함: offguard→human→mirror, gap 씬 없음 (진실 모름 — 정상)
- t50+ 합류: deduction 윈도우(t26~50) 닫혀 confession 경로로 (데드엔드 아님)

### Godot 55개 컴파일 클린 / audit ERROR 0 / WARNING 0 / 밴드 통과

## 2026-06-23 (description_if_known 엔딩 변주 실기 렌더 검증)

### xvfb + opengl3 실제 렌더 캡처로 변주 시각 검증
- 임시 QAVariants.tscn 하니스 작성 → MainGame 부팅 후 _show_ending에 플래그 주입 캡처
- 9컷 캡처 성공:
  - KR: gangnam_dream(truth_buried/forgiven/quietly_distanced/base), jaehyuk_way(used_fully),
        late_call(used_fully/truth_known)
  - EN: jaehyuk_way(used_fully), late_call(truth_known)
- 육안 확인:
  - jaehyuk_way+used_fully: "그를 미워하며 시작해서, 정확히 그가 되어 끝났다" 정상 렌더
  - late_call+truth_known: "진실을 민준은 안다. 아버지는 모른다... 들뜸을 깨고 싶지 않았다" 정상
  - EN jaehyuk_way: "He started out hating him, and ended up exactly him." 영어 정상 렌더
- description_if_known 엔진이 실제 렌더러에서 엔딩 경로 end-to-end 작동 확인
- 검증 후 임시 하니스 삭제(레포 정리)

### 참고: 테스트 아티팩트
- EN 캡처에서 HUD 라벨이 KR로 남고 {name}이 "민준"으로 뜬 것은 하니스가 KR로 부팅 후
  DataRegistry.reload()만 한 한계 — 실제 EN 게임은 전체 EN 부팅. 엔딩 본문 자체는 언어별 정상.

## 2026-06-23 (late_call 비-강남 엔딩 상철 진실 변주 2종)

### 배경
- 진실(sangchul_truth_known)을 안 플레이어가 30억 미달 시 age>=38 타임리밋 엔딩으로
- 그중 father_reconciled면 late_call(화해 엔딩) — 상철 진실이 본질적으로 '아버지' 건이라 최적

### late_call description_if_known 2종 (KR+EN)
- sangchul_used_fully (우선): 그를 끝까지 이용했는데도 강남 미달 — 가장 쓴 결말
  "팔 건 다 팔았는데 강남은 안 왔다. 남은 건 국밥 한 그릇과, 말할 수 없는 것 하나."
- sangchul_truth_known (일반): 진실을 아버지 평안 위해 혼자 짊어짐
  "아버지가 모르는 채로 평안하도록 — 그 진실을 혼자 들기로 했다.
   어쩌면 이게 강남보다 어려운 일이었는지도."

### 라우팅/우선순위 검증
- reported → sangchul_reckoning 전용 엔딩으로 분기 → late_call 미도달, 충돌 없음
- description_if_known 첫 일치: used_fully > truth_known (착취 경로가 더 구체적)
- crossed_line은 30억 도달 시에만 jaehyuk_way 가로채기 → 미달 leveraged 플레이어는
  late_call 도달 가능 → used_fully 변주가 정확히 커버

### 런타임 검증: ko(346/389자) en(771/805자) 양언어 정상 로드
### audit ERROR 0 / WARNING 0 / write_only_flags 211

## 2026-06-23 (상철 진실 4경로 엔딩 페이오프 완비 + 에필로그 톤 점검)

### gangnam_dream + sangchul_quietly_distanced 변주 (KR+EN)
- 진실 알고 말없이 떠난 뒤, 그의 사다리 없이 30억 도달
- "그게 강남까지 길을 몇 배 멀게 만든 걸 안다. 그래도 이 풍경 어디에도 그 손이 닿지 않았다.
  이건 온전히 내 것이었다. ...적어도 빌리지 않았다."

### 상철 진실 경로별 엔딩 페이오프 — 전 경로 완비
- used_fully / leveraged → jaehyuk_way (그가 되어 끝남)
- truth_buried → gangnam_dream 변주 (묻어둔 채 올라옴)
- forgiven → gangnam_dream 변주 (원망 내려놓음)
- quietly_distanced → gangnam_dream 변주 (빌리지 않음)
- reported / cut_ties → sangchul_reckoning (전용 엔딩)

### task② 다른 인물 에필로그 톤 점검 (결론: 추가 수정 불요)
- 다은/지연: stage가 관계 건강을 정직히 반영 — drift가 affinity↓→stage↓→콜드 라인
  자동 처리. "착취하면서도 high-stage 유지" 패턴(상철 leverage)이 없음
- 재혁: 에필로그 이미 플래그 기반(betrayed/reported/partner_in_crime/blackmailed)
- 결론: 상철 톤버그는 leverage가 관계를 끊지 않고 이어가는 고유 구조 때문 — 확정

### audit ERROR 0 / WARNING 0 / write_only_flags 211 / 런타임 양언어 로드 확인

## 2026-06-23 (엔딩 EN 검증 + gangnam_dream 변주 2종 + 에필로그 톤버그)

### run_summary / cast_epilogue EN 커버리지 검증 (완료)
- _ending_run_summary: 34개 엔딩 + ng_gambling_premonition 전수 _tr() + fallback
- _ending_cast_epilogue: 아버지/어머니/지연/다은/상철/재혁 전 분기 _tr()
- 누락 없음 — 완전 이중언어 확인

### gangnam_dream description_if_known 2종 (KR+EN)
- sangchul_truth_buried: "됐어요 잊어버려요"로 진실 묻고 올라온 승리
  아버지가 "좋구나 아들" — 그는 이 풍경의 절반이 자신을 무너뜨린 사람을 거친 걸 모른다
  묻어둔 것이 거실에서 같이 야경을 본다
- sangchul_forgiven: 신고 대신 용서한 경로
  "용서가 아니라 더 이상 미워할 힘이 없었던 건지도" / "더 이상 누구도 미워하지 않게 됐을 뿐"
- 라우팅 검증: 둘 다 crossed_line 미설정 → jaehyuk_way 가로채기 없이 gangnam_dream 도달
- 런타임 검증: ko/en 양 언어 변주 정상 로드

### 인연 에필로그 상철 착취 톤버그 수정 (MainGame.gd)
- 버그: sangchul stage가 trusted/mentoring이면 착취 플레이어도 따뜻한 라인
  ("내가 사람 하나는 잘 본다" / "국밥 같이 먹는다")이 떴음
- 수정: sangchul_used_fully / sangchul_leveraged 플래그를 stage보다 우선 체크
  - used_fully: "필요하면 또 쓸 것이다. 그는 그걸 알면서도 전화를 받는다"
  - leveraged: "그의 죄책감은 좋은 지렛대였다. 그 사실이 가끔 마음에 걸린다"
- KR+EN, Godot 55개 컴파일 클린

### audit ERROR 0 / WARNING 0 / write_only_flags 211 / 밸런스 밴드 통과

## 2026-06-23 (엔딩 EN 번역 인프라 + 34개 엔딩 전체 영어화)

### 발견: 엔딩 전체가 KR 전용
- content/endings.json은 한국어만 — EN 오버레이 인프라가 아예 없었음
- 데모(t24 종료)는 미차단이나, 풀 릴리스 전 필수

### content/endings_en.json 신규 (34개 전체)
- gangnam_dream, empty_house, with_daeun, jiyeon_man, jaehyuk_way, late_call,
  stable_success, ordinary_life, burnout, mental_break, bankruptcy, crypto_ghost,
  startup_exit, political_fix, lonely_rich, investment_master, reputation_legend,
  healthy_retirement, debt_spiral, orthodox_pinnacle, orthodox_hollow, balanced_life,
  unorthodox_legend, early_retirement, creator_success, instant_legend, full_circle,
  second_love, guardian, gambling_recovery, career_climber, career_burnout,
  sangchul_reckoning, writer
- title + description 번역, jaehyuk_way는 description_if_known(sangchul_used_fully)도
- {name}/{housing} 플레이스홀더 보존
- condition은 내부 dev 메타데이터(미렌더링)라 번역 생략

### DataRegistry._apply_endings_en_overlay()
- events_en 오버레이 패턴 미러
- ENDINGS_EN_PATH 상수 추가, reload()에서 language=="en"일 때 적용
- 같은 id의 텍스트 필드를 영어로 덮어씀, 없는 엔딩은 KR 유지(graceful)

### 런타임 검증
- 임시 TestEndingsEN.tscn로 헤드리스 검증 (오토로드 로드 상태)
- EN모드: gangnam_dream="Gangnam Dream", jaehyuk_way="Jaehyuk's Way", dik 정상
- KR모드: gangnam_dream="강남드림" (오버레이 미적용 확인)
- 검증 후 테스트 파일 삭제

### audit ERROR 0 / WARNING 0 / Godot 55개 컴파일 클린 / 밸런스 밴드 통과

## 2026-06-23 (drift EN + jaehyuk_way 상철 변주 엔딩 + 파스 에러 수정)

### relationship drift 5종 EN 번역
- daeun_drift_quiet, sangchul_becomes_primary, daeun_birthday_missed,
  sangchul_world_absorbed, jiyeon_notices_daeun
- KR/EN 선택지 수·effects·flags 완전 일치 (EN은 텍스트 오버레이만, 엔진이 KR effects 적용)

### jaehyuk_way 엔딩 상철 변주 (description_if_known)
- 기존 jaehyuk_way는 "최재혁의 방식" — 일반 포식자 엔딩
- sangchul_used_fully 플래그 보유 시 상철 전용 변주로 교체
  - "임상철. 아버지를 빚으로 밀어 넣은 사람. ...그의 죄책감을 자산으로 썼다"
  - 거울 씬 콜백: "나랑 비슷해요" — "그때는 부정하고 싶었다. 지금은 부정할 게 없었다"
  - "그를 미워하며 시작해서, 정확히 그가 되어 끝났다"
- _show_ending()에 지식 반응형 변주 엔진 추가 (StoryMode description_if_known 패턴 미러)
- 전체 체인 완성:
  used_sangchul_knowingly(알면서 이용) → callback_sangchul_leveraged_cost(거울)
  → sangchul_used_fully + crossed_line → 30억 → jaehyuk_way 상철 변주

### 발견: confrontation 이후 t70~90 여파 씬은 이미 완비
- 5종 터미널 상태 모두 echo 씬 존재(KR+EN): truth_buried(t84)/quietly_distanced(t84)
  /cut_ties(t90)/forgiven(t76)/leveraged_cost(t76)
- callback_sangchul_leveraged_cost "쓰는 사람의 얼굴" — 이미 강력한 거울

### var t 셰도잉 파스 에러 수정 (기존 버그)
- MainGame.gd _refresh_arc_box(): 3132 `var t: int` vs 3288 `for t in ...` 충돌
- 엄격 파서(--check-only --script)가 검출, 커밋 HEAD에 이미 존재하던 버그
- 루프 변수 t → th 로 변경
- Godot 전체 컴파일 55개 스크립트 클린 (audit.sh CompileCheck.tscn)

### audit ERROR 0 / WARNING 0 / 밸런스 밴드 통과 / write_only_flags 211

## 2026-06-23 (상철 이후 중간 씬 — 알면서도 이용하는 구간)

### 빈 구간 발견
- deduction 경로는 t26~50에 sangchul_truth_known을 일찍 set
- 하지만 confrontation은 t60+ — 그 사이 "알면서도 계속 이용하는" 구간이 비어있었음
- 이게 핵심 메커니즘: "사람이 도구가 되는 순간" — 알고도 멈추지 않는다

### arc_sangchul_known_offer (t38~55, KR+EN)
- 상철이 진짜 유용한 재개발 정보를 내민다. 플레이어는 그가 누구인지 안다.
- 종이를 집으면: money +180만, mental -7~-12, used_sangchul_knowingly 플래그
- "이번엔 됐어요" 거절도 가능하지만, 거절은 이번 한 번뿐이라는 걸 둘 다 안다
- description_if_known(sangchul_helped_with_father): 빚으로 민 손과 병실 잡아준 손이 같은 손

### arc_sangchul_known_reflex (t50~59, KR+EN)
- 현수가 후배를 소개하려 하자, 플레이어가 무의식적으로 그 사람을 계산하고 있는 걸 발견
- "임상철이 자기를 처음 봤을 때 이렇게 봤을 것이다"
- rationalized_using_people 플래그 ("다들 이렇게 산다 — 편해졌다는 게 가장 무서웠다")

### 페이오프 배선
- used_sangchul_knowingly → arc_sangchul_confrontation description_if_known
  (그 사람 돈으로 불린 계좌 — 이 질문을 할 자격이 있는지)
- rationalized_using_people → arc_sangchul_reckoning description_if_known
  (상철의 사과가 자기가 했던 합리화와 똑같이 들린다)

### 비대칭 설계
- deduction 경로: 진실(t26~50) → offer(t38~55) → reflex(t50~59) → confrontation(t60)
- confession 경로(t56+): 진실 → 대면 직행
- 스스로 알아챈 자만 그 무게를 더 오래 진다

### audit ERROR 0 / WARNING 0 / write_only_flags 211 (baseline 유지) / KR+EN 완전 동기화

## 2026-06-23 (선택지 재작성 + arc_sangchul_mirror + 관계 균열)

### 선택지 텍스트 219개 전수 인간행동 재작성
- life_events 50개, relationship_events 30개, investment_events 22개, hidden_events 23개
- callback_events 26개 파일 94개
- 패턴: "X한다" 단일동사 → 구체 장면 ("링크를 눌렀다. 소액이었다", "이어폰을 꼈다. 볼륨을 올렸다")
- 선택지 효과 미리보기 필터: money/health/mental 3종만 표시 — 관계/스킬은 서사로 발견

### arc_sangchul_mirror 신규 이벤트 (KR+EN)
- t>=50, sangchul_affinity>=65, arc_sangchul_human_seen 조건
- 상철: "나랑 비슷해요" — 3가지 반응 (건배/질문/"저는 좀 달라요")
- `sangchul_called_you_his_mirror` / `denied_sangchul_mirror` 플래그 → arc_sangchul_reckoning 반응 분기

### arc_father_03_hospital 4번째 선택지 (KR+EN)
- "상철에게 연락했다 — 그가 아는 사람이 있을 것이다"
- `sangchul_helped_with_father` 플래그 → arc_sangchul_confrontation description_if_known 분기

### EN 오버레이 완성
- arc_sangchul_confrontation/reckoning description_if_known EN 번역 (거울 인식·부정 2경로)
- arc_father_03_hospital 4번째 선택지 EN

### audit ERROR 0 / WARNING 0 / write_only_flags 211 (baseline 유지)

## 2026-06-23 (발견 레이어 — DE식 지식반응형 서사 엔진)

### description_if_known 엔진 (StoryMode.gd)
- `_render_current()`에 `description_if_known` 지원 추가
- `{플래그: 대체본문}` dict — 플레이어가 해당 플래그를 가지면 장면 설명이 교체됨
- 최우선 적용 (orthodox/low_mental/gosiwon 변형보다 우선)

### arc_sangchul_deduction — 새 이벤트 (KR+EN)
- t>=26, 지력55+ 또는 route_unorthodox>20 조건으로 발동
- 상철이 네트워크에서 돌렸던 이름(한PD건설)을 혼자 추적해 진실 자가발견
- deduced_sangchul_truth 경로: sangchul_truth_known 획득 (아버지 고백 불필요)
- sangchul_clue_noted 경로: 알면서 묻어두는 선택 — 이후 아버지 고백에서 더 무거움

### description_if_known 적용 6개 장면 (KR+EN)
- arc_sangchul_02_coffee: 따뜻한 멘토 장면이 쓴맛으로
- arc_sangchul_03_network: 모르는 척 앉아 있는 어려움
- arc_sangchul_offguard: 나쁜 사람도 진짜로 걱정한다는 복잡함
- arc_sangchul_human: 거짓말이 아니라는 게 더 쓸쓸한 이유
- sangchul_why_gangnam: 그 '왜'는 답을 몰라서가 아니었다
- sangchul_past: 두 가난 이야기가 같은 지점에서 서로를 향함

### arc_father_06_confession 2경로 대응
- deduced_sangchul_truth: 혼자 알고 있던 무게가 이제 둘의 것이 됨
- sangchul_clue_noted: 묻어둔 날이 갑자기 무거워짐

### audit.py 개선
- _walk_event_flags: description_if_known 키를 flag-read로 인식
- audit ERROR 0 / WARNING 0

---

## 2026-06-22 (Steam 데모 QA + 위시리스트 CTA)

### Steam 데모 크리티컬 패스 검증
- OpeningCinematic 7카드 → 프롤로그 3씬 → chapter_card_33 → arc_intro_01~04 → arc_chapter1_close 전 이벤트 확인
- EN 100% 커버리지 확인 (1369/1369)
- 밸런스 밴드 전부 통과 재확인

### 콜백 트리거 전수 검증
- callback_events_35~54 파일 416개 flag-triggered 콜백 전부 reachable
- opportunity.win_flag/lose_flag 경로까지 포함해 정확하게 검증

### Steam 위시리스트 CTA 추가
- `_show_demo_ending()` 내 wishlist_btn 추가 (KR: "♥ Steam 위시리스트에 추가" / EN: "♥ Add to Steam Wishlist")
- `OS.shell_open(STEAM_STORE_URL)` 연결; URL 상수는 TODO 주석으로 App ID 교체 안내
- audit ERROR 0 / WARNING 0 유지

---

## 2026-06-22 (Phase 3 배선: inert 이벤트 106개 전수 effect 연결)

### callback_events_19~26 wiring 완료
- 8개 파일 (~107 이벤트, ~214 선택지) 모든 선택지에 effects/cast_effects 추가
- 이전까지 게임 상태에 아무 흔적도 없던 "가짜 분기(inert)" 해소
- 선택 패턴: 따뜻/적극→mental +3~+6 + 카테고리별 스탯; 소극/위험→mental -4~+2 (도박 재발: money 페널티)
- 관계 이벤트: cast_effects (daeun, father, jiyeon, jaehyuk affinity ±2~±8)
- audit inert_events: 106 → 0. debt_baseline.json inert 래칫 0으로 조임 (이후 추가 시 즉시 ERROR)
- ERROR 0 / WARNING 0

---

## 2026-06-22 (5년 서사 구조 재편 — Year 3-5 인물 재등장 아크 + 지연 타이밍)

### 1. 신규 인물 2명 추가 (arc_new_characters.json)
- **박재원** (고시원 후배, Year 3): 첫만남→조언→이사→5년후재회 4이벤트. 처음 서울 온 26세가 2년 뒤 50M 저축 성공 — 뭔가 남기는 것의 의미.
- **이민서** (강남 먼저 간 여성, Year 4): 세미나에서 만남→카페에서 현실 고백 2이벤트. "목표가 사라질 때를 준비해야 한다" 메시지.
- ImageRegistry portrait 키 등록(jaewon/jaewon_normal/minseo/minseo_normal), cast_stages.json stage 선언.

### 2. Year 3-5 인물 재등장 아크 (arc_daeun_extension.json, arc_year3_drama.json)
- **다은** 5이벤트: 2주년(t100)·결혼사진(t100 이별루트)·강남취직(t145)·30억전날밤(t193)·강남대로(t193 이별루트)
- **임상철** Year 3: 신문기사 입건(t100, 대면 후) — 배운 것과 잃은 것이 동시에 사실
- **지연** Year 3: 카카오톡 재연락(t100, 에필로그 후) — 각자의 삶 가장자리에서 가끔 안부
- **아버지** 기일 씬(t150) + arc_father_passing 트리거 추가
- KR/EN 동시 (EN에 전세·부동산 브로커 사기 문화 설명 포함)

### 3. MainGame.gd _next_arc_id() 9구간 블록 추가
- Year 3(t96-100)~Year 5(t193) 인물별 분기 트리거 삽입

### 4. 한지연 아크 타이밍 현실화
- 기존: 5주 만에 첫만남→재회→제안→점심 (비현실적 신뢰 형성)
- 변경: store t20→t26, offer t21→t36, lunch t22→t40 (2~3개월 간격)
- 연쇄: reveal t35→t48, truth t44→t56, epilogue t50→t64
- 관계 패널 개월 레이블 수정

### 결과
- audit ERROR 0 / WARNING 0 / 밸런스 밴드 전부 통과
- 이벤트 신규 14개 (총 1057개)

### 5. 다은 with_daeun 엔딩 버그 픽스
- 다은 아크 최종 stage는 `committed`인데 엔딩 판정이 `["lover","together"]`만 봐서, 가장 헌신적으로 키운 플레이어가 오히려 with_daeun 엔딩을 놓치던 버그. `committed` 추가로 회수 (GameState.gd:1313).

### 6. audit 하드닝 — 죽은 코드 자동 검출 체크 2종 영구 추가
- **배경**: 유저 지적 "난개발로 컨텐츠가 유기적으로 안 돌고 죽은 코드가 너무 많다." 한 개씩 손으로 찾는 대신, 죽은 코드 클래스를 CI가 자동으로 잡도록 audit.py 하드닝.
- **체크 #9 죽은 아크 이벤트**: `min_turn>=9999`(트리거 전용)인데 코드/follow_up 어디서도 호출 안 되는 이벤트 = 영원히 안 뜨는 죽은 콘텐츠 (구버전 잔재 / 트리거 누락).
- **체크 #10 죽은 cast-stage 분기**: 코드/조건이 비교하는 cast stage인데 어떤 이벤트도 set 안 하는 도달 불가 분기 (다은 committed 버그의 거울상).
- **검출·제거**: 두 체크가 **옛 지연(jiyeon) 레거시 아크 전체**를 적발 — `arc_jiyeon_*` 신버전으로 교체됐는데 안 지워진 잔재. 레거시 이벤트 5개(jiyeon_meet/coffee/date/crisis/confession) + 거기에만 매달린 콜백 11개 = **16개(KR+EN) 제거**. jiyeon 엔딩 체크의 죽은 `"lover"` stage도 제거(→`honest_together`만).
- 두 체크 음성 테스트로 회귀 검출 동작 확인. audit ERROR 0 / WARNING 0 / 밴드 통과.

---

## 2026-06-22 (Codex: English Surface + AP Modal Polish)

### 수정
- `scenes/MainGame.gd`: AP 세부 카테고리 모달 버튼을 기존 긴 텍스트 버튼에서 아이콘/제목/보조설명/AP 배지를 갖춘 카드형 버튼으로 전환. 메인 행동 카드와 같은 시각 언어를 사용하도록 정리.
- 영어 모드 탑바에서 `Gangnam Dream` 로고와 `Title` 버튼이 1280x800에서 잘리던 문제 수정. 영어 탑바 금액 표기는 `KRW 3.5M | KRW 7.3M` 형태로 압축.
- 영어 모드의 날짜, 금액, 주거명, 인물명, 칭호/성향, 월 조언 문구가 한국어 표면으로 남는 문제를 보정.
- 영어권 주 타깃 기준으로 HUD/모달/마일스톤/요약의 통화 표기를 `₩`에서 `KRW`로 전환. 1280x800 캡처에서 `₩` 글리프가 `W`처럼 읽히는 문제 방지.
- `autoloads/GameState.gd`, `systems/RelationshipSystem.gd`, `systems/InvestmentSystem.gd`: 새 런/런 테마/칭호 보너스/시장 국면/관계 단계 로그를 영어 모드에서 영어로 남기도록 수정.
- `tools/ScreenshotQA.gd`: 영어 메인 HUD, 영어 돈/관계 모달, 영어 정보 패널 Stats/Relations, 영어 StoryMode 초반 이벤트 캡처를 전체 QA 루틴에 추가.
- QA 언어 전환 시 `DataRegistry.reload()`를 강제해 영어 이벤트 오버레이가 한국어 캐시에 가려지던 ScreenshotQA 사각지대 수정.
- 리베이스 후 원격 변경에서 드러난 Godot 4.6 파서 오류 보정: `GameState.get_run_pace()` 타입 명시, `TutorialOverlay` JS식 삼항 연산자 제거.

### 검증
- 전체 `ScreenshotQA` 반복 실행 완료. `00h_en_story_intro`, `00c_en_ap_actions`, `00d_en_money_modal`, `00e_en_people_modal`, `00f_en_info_stats`, `00g_en_info_relations` 직접 확인.
- 1280x800 기준 영어 로고/탑바 버튼/목표 라벨 잘림 없음. 영어 초반 StoryMode 이벤트와 정보 패널의 주요 로그/관계 단계 라벨 영어 표시 확인.
- `./tools/audit.sh` 통과: ERROR 0 / WARNING 0, Godot 전체 스크립트 컴파일 깨끗, 밸런스 밴드 전부 통과.

---

## 2026-06-21 (품질 버그 일제 수정 — 도달불가 엔딩/고아 플래그/EN 오버레이)

> **방향 결정 (유저):** ①버그 잡기 + 아크 구멍 메우기 → ②게임 전반 다이어트 → ③후킹 → ④재미 검증. "결국 다 해야 한다." 이번 세션은 ① 집중.

### 1. 도달 불가 엔딩 `sangchul_reckoning` 완전 연결
- 증상: 에필로그(`_ending_run_summary`/`_ending_cast_epilogue`)는 있는데 **finish_run 트리거 없음 + endings.json 엔트리 없음 + BGM good 목록 누락** → 절대 도달 불가
- `autoloads/GameState.gd check_game_over()`: `sangchul_reported`(임상철 신고) + 아버지 생존 시 발동 (age≥38, 30억 미달자). gambling_recovery 뒤, reputation_legend 앞에 배치
- `content/endings.json`: "청산" 엔트리 추가 (grade B, cafe 배경) — 강남 포기하고 아버지를 빚에서 해방시킨 도덕적 엔딩, late_call의 형제
- `autoloads/BGMPlayer.gd`: good 목록에 추가
- 엔딩 33→34개. finish_run ↔ endings.json 양방향 100% 매칭 재확인

### 2. 임상철 용서/역이용 분기 콜백 (`callback_events_33.json`, KR+EN)
- arc_sangchul_reckoning 3분기 중 신고(reported)만 회수돼 있었음 → 용서(forgiven)/역이용(leveraged) 2분기는 플래그만 set, 후속 無
- `callback_sangchul_forgiven_echo` (flag: sangchul_forgiven, t≥76): 용서가 진짜 평화였나 회피였나 — 다시 만남/거리 둠
- `callback_sangchul_leveraged_cost` (flag: sangchul_leveraged, t≥76): 죄책감을 자산으로 쓰는 대가, 거울 속 재혁의 얼굴 — 계속 씀/관계 끊음
- DataRegistry EVENT_PATHS 등록

### 3. 아버지 별세 에필로그 분기화 + 어머니 에필로그 (고아 플래그 4개 회수)
- `scenes/MainGame.gd _ending_cast_epilogue()`:
  - `fs == "passed"` 한 줄 고정 → `chose_money_over_father`(딜 택함, 오르는 통장의 아이러니) / `tried_to_go_to_father`(늦게라도 감) 분기
  - 어머니 줄 신규 추가 (`mother_reconciled`/`mother_reconnected` 회수, good/bad 분기)

### 4. EN 오버레이 버그 일제 수정 (전수 QA)
- 전수 스캔으로 발견: 선택지 개수 불일치/빈 필드/한글 잔존
- **빈 result_text 28개**: EN 오버레이 choice의 `result_text: ""`가 인덱스 병합에서 KR을 덮어써 영어 결과창 공백 → 28개 전부 KR에서 번역
- **stale 오버레이 3건**: 옛 KR 버전 번역이 남아 병합 시 프랑켄슈타인(EN 설명=옛 이야기 + KR 선택지=새 이야기):
  - hyunsu_pivot, hyunsu_reunion_later: 현재 KR로 전면 재번역
  - arc_jiyeon_03_offer: 오역된 선택지2 수정 + 누락된 선택지3 추가 (KR 3개 / EN 2개 → 3번째가 한국어로 노출되던 버그)
- **한글 잔존 EN 설명 3건**: drama_housing_lottery, drama_sogeuting_00, drama_tax_return_00 번역
- EN 오버레이 QA: 구조 문제 0 / 한글 잔존 0

### 검증
- audit.sh ERROR 0 / WARNING 0, 밸런스 밴드 전부 통과
- 이벤트 1101→1103개, 엔딩 34개

---

## 2026-06-21 (arc_daeun_later_echo 범용 확장 + career_burnout 엔딩 — 엔딩 33개)

### 수정
- `content/events/arc_events.json` `arc_daeun_later_echo` — 다은 경로 범용화:
  - 기존: [daeun_together_path] / [daeun_let_her_go] 전용 선택지 문구
  - 변경: "아직 함께다 — 이 길 끝에도 그녀가 있다" / "각자의 방향으로 갔다 — 그래도 시작은 그녀였다"
  - description 업데이트: "이 길을 걷는 동안 다은이 옆에 있었거나, 어느 지점에서 각자의 방향으로 갔거나"
  - committed/deferred/uncertain 세 신규 경로를 자연스럽게 커버
  - EN 오버레이 동기화
- `content/endings.json` — 신규 엔딩 `career_burnout` (버텨온 것들, grade B):
  - 38세 + 직장 유지 + (번아웃_acknowledged or 이직_trigger) + 자산 1억 미만
  - career_climber(A)의 bittersweet 짝: 이직·번아웃을 겪었지만 자산 대박은 못 친 직장인 서사
  - 퇴근 버스 씬. "버텨온 것들이 있다. 숫자에는 안 잡히는 것들."
- `autoloads/GameState.gd` — check_game_over late_call 이후, writer 직전에 career_burnout 분기 추가
- BGM good 목록 + _ending_run_summary + _ending_cast_epilogue(good) 등록
- 엔딩 32 → 33개. audit ERROR 0/WARNING 0. 밴드 통과.

## 2026-06-21 (우정 이벤트 콜백 체인 4종 — callback_events_32)

### 수정
- `content/events/callback_events_32.json` 신규 — 우정 플래그 회수 콜백 4종:
  - `callback_reached_out_echo` ← `reached_out_to_friend` (t≥32): "야, 밥 먹자" 이후 실제 어떻게 됐나 — 지속된 관계 vs 한 번의 의무
  - `callback_friends_world_echo` ← `accepted_friends_growth` (t≥40): 친구 결혼식 낯선 얼굴 수용 이후, 오히려 더 가까워지는 씬
  - `callback_startup_friend_update` ← `celebrated_friends_success` (t≥48): 시리즈 A 친구 이후 소식 — 시리즈 B 성공 or 런웨이 부족
  - `callback_drift_accepted_now` ← `accepted_friendship_change` (t≥52): 반년만에 만남 수용 이후 다음 만남이 훨씬 자연스러워진 씬
- `content/events_en/callback_events_32.json` — EN 오버레이 동시 추가
- `autoloads/DataRegistry.gd` — 등록
- 총 이벤트: 1095 → 1099개. audit ERROR 0/WARNING 0.

### 의도
- friendship_events.json에서 설정한 4개 플래그(reached_out_to_friend / accepted_friends_growth / celebrated_friends_success / accepted_friendship_change)가 회수 이벤트 없이 끊겨 있던 서사 공백 해소
- "먼저 연락하면 뭔가 달라진다"는 선택이 실제 게임 내에서 결실을 보도록

## 2026-06-21 (직장/이직 루트 전용 엔딩 보강 — career_climber)

### 수정
- `content/endings.json` — 신규 엔딩 `career_climber` (갈아탄 사다리, grade A) 추가:
  - 5년간 명함을 3번 갈아탄 이직·승진 서사. 연봉 협상·헤드헌터·사표의 날들.
  - "한자리에서 버티는 것만 끈기인가" 라는 질문을 던지는 직장인 루트 전용 결말.
- `autoloads/GameState.gd` `check_game_over()` — 38세 종료 분기에 트리거 추가:
  - `not current_job.is_empty() and total >= 100_000_000 and (job_changed_success or max_job_tier>=4)`
  - reputation_legend 다음, orthodox_pinnacle 앞에 배치 (자산 대박 미달 직장인 catch)
- `autoloads/BGMPlayer.gd` — good 엔딩 목록에 career_climber 추가
- `scenes/MainGame.gd` — `_ending_run_summary` / `_ending_cast_epilogue`(good)에 career_climber 등록
- 엔딩 32개. audit ERROR 0/WARNING 0. 밸런스 밴드 전부 통과.

### 의도
- 성실히 이직·승진해 tier 4에 도달했으나 5억/10억 자산 대박은 못 친 플레이어가
  `ordinary_life`(C, "그냥 사람")로 떨어지던 약점 해소. 직장 루트에 A급 보상 결말 부여.
- work_events(job_change_trigger)→callback_events_31(job_changed_success) 체인이 비로소 엔딩으로 회수됨.

## 2026-06-21 (arc_daeun / arc_hyunsu 후속 완결 — 4종)

### 수정
- `content/events/arc_daeun.json` — 3종 추가 (arc_daeun_04b_future 이후 분기 완결):
  - `arc_daeun_05_together` (daeun_committed 경로, t≥50) — 같이 가기로 한 뒤 일상 씬
  - `arc_daeun_05_breaking` (daeun_deferred 경로, t≥50) — "나중에" 말의 결말, 이별
  - `arc_daeun_05_uncertain` (daeun_uncertain 경로, t≥50) — 어중간한 거리의 자연 소멸
- `content/events/arc_hyunsu.json` — 1종 추가 (hyunsu_result_pass 이후 미완성 경로 완결):
  - `hyunsu_pass_news` (hyunsu_passed 경로, t≥80) — 합격 후 발령, 고시원 떠나는 씬
- `scenes/MainGame.gd` `_next_arc_id()` — 트리거 4개 추가 (t≥50 daeun 3종, t≥80 hyunsu 1종)
- `content/events_en/arc_daeun.json` / `arc_hyunsu.json` — EN 오버레이 동시 추가
- 총 이벤트: 1091 → 1095개, EN 누락 0, audit ERROR 0/WARNING 0

### 의도
- arc_daeun_04b_future의 세 선택지(committed/deferred/uncertain)가 각각 결말 씬 없이 끊겨 있던 내러티브 공백 해소
- hyunsu_result_pass 이후 합격 경로에 발령 씬 없어 pass 루트가 불완전했던 문제 해소
- cast_stages.json 기존 stage만 사용 (신규 stage 없음)

## 2026-06-21 (P3 7차 직장인 일상 서사 6종 + 정체성 콜백 3종)

### 수정
- `content/events/work_events.json` 신규 — 직장인 일상 서사 6종:
  - `work_credit_stolen` (t≥20, has_job) — 성과 가로채기 3선택지 (참기/직접대응/그냥퇴근)
  - `work_burnout_monday` (t≥24, has_job) — 번아웃 신호 인식 vs 무시
  - `work_headhunter_call` (t≥28, has_job) — 헤드헌터 연락 3선택지 (탐색/거절/정보수집)
  - `work_peer_salary_slip` (t≥16, has_job) — 동기 연봉 공개 3선택지 (재협상/침묵/정보취합)
  - `work_lunch_alone` (t≥12, has_job) — 혼밥: 생산적 시간 vs 외로움 인정
  - `work_year_review` (t≥32, has_job) — 연말 B+ 성과면담 3선택지
- `content/events/callback_events_30.json` 신규 — 정체성 플래그 콜백 3종:
  - `callback_midnight_echo` ← `midnight_conviction` (t≥28) — 낮에도 유효한가
  - `callback_vision_midcheck` ← `long_vision_set` (t≥52) — 43세 비전 중간점검
  - `callback_gangnam_standard_held` ← `gangnam_redefined` (t≥44) — 기준 내면화 확인
- EN 오버레이 동시 추가, DataRegistry 등록
- 총 이벤트: 1073 → 1082개, EN 누락 0, audit ERROR 0/WARNING 0

### 의도
- 직장인 루트 플레이어의 현실 밀도 강화: 회사 정치/번아웃/이직 딜레마는 30대 직장인이 매일 만나는 문제
- 정체성 씬(P3 6차)에서 심은 플래그들의 서사 완결: 확신이 낮에도 유효한지, 비전이 현실에서 버텨주는지 회수

## 2026-06-21 (P3 6차 자아 정체성 5종 + 불안 콜백 4종)

### 수정
- `content/events/identity_events.json` 신규 — 자아 정체성·30대 위기 서사 5종:
  - `identity_midnight_question` (t≥8) — 새벽 3시 천장, "이게 맞는 건가"
  - `identity_old_notebook` (t≥16) — 대학 꿈 적힌 노트 발견
  - `identity_gangnam_why` (t≥20) — 왜 강남인지 스스로에게 묻기 (재정의 분기)
  - `identity_10year_vision` (t≥32) — 43세의 나를 그려보기 vs 지금이 먼저
  - `identity_define_success` (t≥40) — 성공의 정의: 숫자 vs 모르겠다
- `content/events/callback_events_29.json` 신규 — 불안 플래그 콜백 4종:
  - `callback_child_cost_grind` ← `child_cost_motivated` (t≥50)
  - `callback_pension_self_fund` ← `pension_anxiety_awakened` (t≥40)
  - `callback_parent_first_money` ← `parent_care_researched` (t≥60)
  - `callback_own_path_confirmed` ← `accepted_different_path` (t≥48)
- `content/events_en/identity_events.json`, `content/events_en/callback_events_29.json` 신규 EN 동기화
- `autoloads/DataRegistry.gd` — identity_events.json, callback_events_29.json 등록
- 총 이벤트: 1064 → 1073개, EN 누락 0, audit ERROR 0/WARNING 0

### 의도
- 30대 위기 서사 레이어 추가: 불안(P3 5차)이 "뭔가 두렵다" → 정체성(P3 6차)이 "나는 누구인가"로 심화
- 불안 이벤트가 설정한 플래그(child_cost_motivated 등)의 서사 완결을 위한 콜백 체인 연결
- 플레이어가 30억 목표를 "왜" 갖고 있는지 다층적으로 확인하는 씬 설계

## 2026-06-21 (P3 5차 자녀·노후 불안 서사 6종)

### 수정
- `content/events/anxiety_events.json` 신규 — 자녀/노후 불안 6종:
  - `anxiety_friend_baby` (t≥20) — 친구 임신 소식, 비교 불안
  - `anxiety_marriage_pressure` (t≥12) — 명절 결혼 압박 3선택지
  - `anxiety_child_cost_calc` (t≥30) — 육아비용 3억 2천 계산 3선택지
  - `anxiety_pension_crisis` (t≥8) — 국민연금 2055년 고갈 뉴스
  - `anxiety_parents_aging` (t≥24) — 아버지 무릎 3선택지 (부모 노환 시작)
  - `anxiety_early_retirement_witness` (t≥36, has_job) — 53세 명퇴 목격
- `content/events_en/anxiety_events.json` 신규 — EN 오버레이 6종 동기화
- `autoloads/DataRegistry.gd` — `anxiety_events.json` 등록
- `audit.py` ERROR 0 / WARNING 0, balance 밴드 전부 통과
- 총 이벤트: 1058 → 1064개, EN 누락 0

### 의도
- 한국 사회 특유의 30대 불안 서사 추가: 결혼 압박, 출산 비용, 연금 불신, 부모 노환, 50대 명퇴 공포
- 플레이어의 30억 목표에 "왜"를 복층으로 부여 (단순 부자 욕심 → 자녀·부모·노후를 위한 절박함)
- 플렉스 서사(P3 4차)와 대비되는 불안/현실 서사 레이어 추가
## 2026-06-22 (PC/Steam Deck Readability Pass 3)

### 수정
- `scenes/MainGame.gd`: 우측 정보 패널 폭을 400px로 확대하고 헤더/탭/스탯 글자 크기와 여백을 상향.
- 정보 패널 탭명에서 장식 이모지를 제거하고, 패널 헤더를 `정보 패널` 기준으로 정리.
- 시황 탭 뉴스 항목을 루머/호재/악재 태그가 있는 카드형 UI로 변경.
- 관계 탭을 인물 카드 UI로 변경. 인물명, 관계 타입, 호감도/신뢰 바, 관계 효과 힌트를 한 카드에 묶어 표시.
- 소지품 탭을 아이템 카드 UI로 변경. 아이템명, 수량, 효과, 사용/자동 활성 상태를 한 카드에 묶어 표시.
- 스토리 탭을 아크 진행 카드 UI로 변경. 아크별 진행률, 단계 완료 상태, 힌트, 런 정보를 카드로 표시.
- `tools/ScreenshotQA.gd`: 우측 정보 패널 탭별 캡처(`04b_info_stats`~`04f_info_story`)를 추가하고, 관계/소지품/아크 QA용 상태를 시드하도록 보강.

### 검증
- 전체 `ScreenshotQA` 실행 완료. `04b_info_stats`, `04c_info_market`, `04d_info_relations`, `04e_info_items`, `04f_info_story` 직접 확인.
- `./tools/audit.sh` 통과: ERROR 0 / WARNING 0, Godot 전체 스크립트 컴파일 깨끗, 밸런스 밴드 전부 통과.

## 2026-06-22 (PC/Steam Deck Readability Pass 2)

### 수정
- `scenes/RouletteTable.gd`: 숫자 베팅 매트 버튼을 58×34/13px 기준으로 확대하고, 베팅 타입/스테이크/SPIN/BET 버튼에 3px 금색 포커스 링을 추가. 스팀덱/패드 조작 시 현재 선택 위치가 더 명확하게 보이도록 개선.
- 룰렛 휠 상단에 `PLACE YOUR BETS` / `SPINNING · NO MORE BETS` / `WINNING POCKET` 상태 배지를 추가해 작은 HUD 텍스트에 의존하지 않게 수정.
- `scenes/MainGame.gd`: 투자 첫 방문 가이드를 긴 설명문에서 핵심 3줄 안내로 압축.
- 투자 자산 목록을 텍스트 줄+버튼 나열에서 자산 카드 구조로 전환. 자산명, 리스크, 가격, 가격 기록 상태, 매수/매도 버튼이 한 덩어리로 읽히도록 개선.
- 상점 아이템 목록도 카드형으로 전환. 아이템명, 가격, 효과, 설명, 구매 버튼을 같은 패널에 묶어 웹 게시판식 목록 느낌을 줄임.
- `_open_modal()`이 기존 스크롤 위치를 물고 다음 모달을 중간부터 여는 문제를 수정. 모달 기본 크기도 760×610, 스크롤 영역 468px 기준으로 복원.
- `tools/ScreenshotQA.gd`: 투자 자산 카드 하단 스크롤 캡처(`02d_investment_asset_cards`)를 추가해 촘촘한 거래 UI를 자동 QA에 포함.

### 검증
- 전체 `ScreenshotQA` 실행 완료. `02_investment_portfolio_chart`, `02d_investment_asset_cards`, `02b_shop_modal`, `02c_system_menu`, `12_roulette_spin`, `12_roulette_table` 직접 확인.
- 1280×800 기준 상점 모달이 항상 맨 위에서 열리고, 투자/상점 카드와 룰렛 숫자 매트의 텍스트·버튼 겹침 없음.

## 2026-06-22 (PC/Steam Deck Readability Pass 1)

### 수정
- `scenes/MainGame.gd`: PC 기본 UI도 Steam Deck/콘솔 기준으로 읽히도록 공통 가독성 상수(`UI_MIN_BODY_FONT`, `UI_MIN_BUTTON_FONT`, `UI_MIN_BUTTON_HEIGHT`, `UI_MIN_SMALL_BUTTON_HEIGHT`, `UI_FOCUS_BORDER`) 추가.
- `_label()`, `_button()`, `_action_button()`, `_small_button()`, `_modal_section_header()`의 최소 폰트/버튼 높이/포커스 테두리를 상향해 작은 웹앱 UI 느낌을 줄임.
- 기본 모달 크기를 `640x560`에서 `760x610`으로 확대하고 스크롤 영역/섹션 간격을 넓혀 투자·상점·관계·시스템 메뉴의 읽기 피로를 줄임.
- 상단 HUD는 버튼이 커진 뒤 1280x800에서 `칭호`가 잘리는 문제를 확인하고, HUD 전용 압축 폭/폰트 규칙으로 재조정.

### 검증
- 전체 `ScreenshotQA` 2회 실행 완료. `04_ap_actions_dashboard`, `01_event_gambling_wave`, `02_investment_portfolio_chart`, `02b_shop_modal`, `02c_system_menu`, `05_people_relationships`, `08_jeongseon_casino` 직접 확인.
- 1280x800 기준 상단바 잘림 해소, 주요 모달/선택지/카지노 허브 겹침 없음.

## 2026-06-21 (투자 모달 시장 보드 추가)

### 수정
- `scenes/MainGame.gd`: 투자/매수·매도 모달 상단에 `MARKET BOARD` 패널 추가.
- 현재 장세, 공포/탐욕 게이지, 크래시 리스크, 현금, 포트폴리오 평가액, 수익률을 한 화면에 요약해 투자 화면이 단순 목록이 아니라 시장 판단 UI처럼 보이게 개선.
- 기존 텍스트형 시장 분위기 줄은 제거해 정보 중복을 줄이고, 첫 방문 가이드 전에 핵심 상태가 먼저 보이도록 재배치.

### 검증
- 전체 `ScreenshotQA` 실행 완료. `02_investment_portfolio_chart` 직접 확인: 시장 보드, 은행 버튼, 첫 방문 안내가 겹치지 않고 첫 화면 안에서 정상 표시됨.

## 2026-06-21 (홀덤 쇼다운 판정 연출 강화)

### 수정
- `scenes/HoldemClub.gd`: 쇼다운 시 중앙 판정 패널을 추가해 승자, 승리 핸드, POT 정산, 손익을 즉시 읽히게 개선.
- 쇼다운 상태에서 POT에서 승자 좌석으로 이어지는 칩 흐름 라인을 그려, 누가 팟을 가져갔는지 시각적으로 드러나게 수정.
- 새 핸드 시작 시 쇼다운 판정 상태를 초기화해 이전 판정 패널이 다음 판에 잔류하지 않도록 정리.

### 검증
- 전체 `ScreenshotQA` 실행 완료. `06a_holdem_showdown` 직접 확인: 판정 패널, 카드, 좌석, 하단 버튼 겹침 없음.

## 2026-06-21 (경마 결과 화면 정산 보드화)

### 수정
- `scenes/RaceTrack.gd`: 경마 결과 화면을 단순 텍스트 목록에서 중앙 결과 보드 형태로 재구성.
- 착순 보드, 내 베팅 정산표, 베팅금/배당금/손익, PHOTO FINISH 패널을 한 화면에 묶어 경주가 끝났을 때 실제 정산 화면처럼 읽히게 개선.
- 다음 경주/나가기 버튼을 하단 가로 확장 버튼으로 정리해 결과 패널과 조작부가 분리되어 보이도록 수정.

### 검증
- 전체 `ScreenshotQA` 실행 완료. `07b_racetrack_result` 직접 확인: 착순 보드, 내 베팅 정산표, 포토피니시, 하단 버튼 겹침 없음.

## 2026-06-21 (카지노 미니게임 외형 폴리싱 2차)

### 수정
- `scenes/RouletteTable.gd`: 숫자 베팅 매트 내부의 0~36 그리드를 `CenterContainer`로 감싸 매트 중앙에 오도록 수정. 오른쪽 빈 공간이 몰려 보이던 문제 해소.
- `scenes/SlotMachineGame.gd`: 슬롯 당첨 시 하단 `PAYOUT TRAY`에 당첨 금액과 코인 잔상 연출을 표시. 직접 `casino_win/lose/jackpot` 호출을 `AudioManager.play_casino_result()` 중심으로 정리해 승패 사운드/진동 톤을 다른 카지노 게임과 맞춤.
- `scenes/BigWheelGame.gd`: 휠 오른쪽에 `READY/SPINNING/WINNER` 상태 플레이트를 추가. 잘 안 보이던 작은 `스핀 중...` 바닥 텍스트를 제거하고 `NO MORE BETS`를 큰 상태판으로 표시.
- `scenes/JeongseonCasino.gd`: 허브 게임 카드에 그림자, 어두운 아트 프레임, 게임 타입 라벨(`TABLE GAME`, `MACHINE`, `WHEEL`, `DICE TABLE`), 버튼 테두리/호버 스타일을 추가해 웹 메뉴 느낌을 줄임.
- `tools/ScreenshotQA.gd`: 슬롯 QA 결과를 체리 2개 당첨으로 고정해 payout tray를 안정적으로 검수. 빅휠 QA도 스핀 중(`12a_bigwheel_spin`)과 결과 후(`12a_bigwheel`) 두 상태로 분리.

### 검증
- `ScreenshotQA --qa=casino`: `08_jeongseon_casino`, `11_slot_machine`, `12_roulette_spin`, `12_roulette_table`, `12a_bigwheel_spin`, `12a_bigwheel` 직접 확인. 룰렛 매트 중앙 정렬, 슬롯 트레이, 빅휠 상태판, 허브 카드 겹침 없음.

## 2026-06-21 (룰렛 부유 칩 제거)

### 수정
- `scenes/RouletteTable.gd`: 상단 룰렛 휠 옆에 떠 있던 베팅 칩 스택을 제거. 실제 룰렛 베팅존이 아닌 위치에 칩이 놓여 플레이어에게 오브젝트 의미가 애매하게 보이던 문제를 정리.
- 베팅 상태는 왼쪽 `BET PLACED` 패널의 `ON TABLE` 텍스트, 하단 선택 금액 버튼, 선택된 베팅 타입 버튼으로만 표현하도록 단순화.

### 검증
- `ScreenshotQA --qa=casino`: `12_roulette_spin`, `12_roulette_table` 직접 확인. 상단 테이블의 부유 칩 제거 확인.

## 2026-06-21 (룰렛 칩/결과 콜아웃 정리)

### 수정
- `scenes/RouletteTable.gd`: 상단 테이블 위 임시 원형 칩 스택을 기존 denomination SVG(`chip_*.svg`) 기반 스택으로 교체.
- 베팅 칩 위치를 오른쪽 결과 패널에서 분리해 왼쪽 베팅 패널과 휠 사이 펠트 공간에 배치. `NO MORE BETS`/`WINNING POCKET` 텍스트와 칩이 겹치지 않게 수정.
- 결과 확정 시 공 주변에 포켓 안착 링을 그리고, 오른쪽 패널에 winning pocket 번호 마커를 추가.
- 룰렛 결과 표시 중에는 방금 올린 베팅 칩이 테이블에 남아 보이도록 `_bet_amount` 리셋 타이밍을 결과 연출 이후로 이동.
- `tools/ScreenshotQA.gd`: 룰렛 QA를 스핀 중(`12_roulette_spin`)과 결과 후(`12_roulette_table`) 두 상태로 분리 캡처.

### 검증
- `./tools/audit.sh` 통과: ERROR 0 / WARNING 0, 밸런스 밴드 통과, Godot compile clean.
- `ScreenshotQA --qa=casino`: `12_roulette_spin`, `12_roulette_table` 직접 확인. 칩/결과 패널/공/숫자 매트 겹침 없음.

## 2026-06-21 (다이사이 테이블 고급화)

### 수정
- `scenes/DaiSaiTable.gd`: 상단 주사위 영역에 실제 테이블 소품처럼 보이는 주사위 컵, 브라스 트레이, 유리 돔 하이라이트, 롤링 모션 라인을 추가.
- 결과/안내 패널 상단에 `SELECTED BET` 콜 패널을 추가해 현재 선택한 베팅, 배당, 베팅 칩, 금액을 한눈에 보이게 수정.
- 콜 패널의 베팅 칩은 기존 denomination SVG(`chip_*.svg`)를 사용해 다른 카지노 게임과 시각 언어를 맞춤.
- 다이사이 주사위 레이아웃을 주사위 컵+트레이 중심으로 재배치해 단순 보드판 UI 느낌을 줄임.

### 검증
- `CompileCheck` 통과.
- `ScreenshotQA --qa=casino`: `12b_daisai_table` 직접 확인. 주사위 컵/칩/콜 패널/베팅 버튼 겹침 없음.

## 2026-06-21 (카지노 카드 배치 정렬 핫픽스)

### 수정
- `scenes/BaccaratTable.gd`: 바카라 결과 카드 시작점을 하드코딩 좌표에서 PLAYER/BANKER 박스 중앙 기준으로 계산하도록 변경. 실제 카드 수가 2장/3장일 때도 묶음이 박스 중앙에 오도록 수정.
- 바카라 결과 점수 배지도 각 박스 내부 오른쪽으로 이동해 카드/점수/테두리 위치 관계를 정리.
- `scenes/BlackjackTable.gd`: 딜러/플레이어 카드 시작점을 핸드 박스 중앙 기준으로 계산하도록 변경.
- 블랙잭 플레이어 칩 스택과 `ON TABLE` 텍스트를 카드 영역 왼쪽으로 분리해 카드와 겹치지 않게 수정.
- 블랙잭 베팅 화면의 과도하게 큰 반원 아크를 제거하고, 베팅 원 안에는 선택 금액에 맞는 denomination 칩 SVG를 표시하도록 수정.
- 블랙잭 칩 스택 드로잉을 임시 원형 구슬 형태에서 실제 칩 SVG 기반의 작은 스택으로 교체.

### 검증
- `CompileCheck` 통과.
- `ScreenshotQA --qa=casino`: `09_baccarat_table`, `10a_blackjack_betting`, `10_blackjack_table` 직접 확인. 카드가 하단 테두리나 칩 스택과 겹치지 않고, 블랙잭 베팅 화면의 이상한 반원 아크 제거 확인.

## 2026-06-21 (ScreenshotQA 카지노 전용 모드 추가)

### 수정
- `tools/ScreenshotQA.gd`: `--qa=casino` 실행 인자를 추가해 카지노 허브/바카라/블랙잭/슬롯/룰렛/빅휠/다이사이 캡처만 빠르게 찍을 수 있게 분리.
- 전체 QA 경로의 중복 카지노 캡처 호출을 `_shot_casino_suite()`로 묶어 유지보수성을 개선.
- 카지노 전용 모드에서도 MainGame 부팅, 튜토리얼 억제, StoryMode 전환 차단을 동일하게 적용해 실제 미니게임 화면만 안정적으로 캡처.

### 사용법
- `/Users/junheelee/Downloads/Godot.app/Contents/MacOS/Godot --rendering-driver opengl3 --resolution 1280x800 res://tools/ScreenshotQA.tscn -- --qa=casino`

### 검증
- `CompileCheck` 통과.
- 카지노 전용 QA 실행 확인: `08_jeongseon_casino`, `09a/09`, `10a/10`, `11`, `12`, `12a`, `12b` 총 9장 생성.

## 2026-06-21 (슬롯머신 릴 심볼 드로잉 고도화)

### 수정
- `scenes/SlotMachineGame.gd`: 슬롯 릴 중앙 표시를 텍스트 라벨 교체 방식에서 코드 드로잉 심볼 타일 방식으로 변경.
- 릴 유리창 안에 상/중/하 심볼 스트립, 타일 경계, 유리 하이라이트, 세로 가이드, 스핀 중 모션 라인을 추가해 실제 슬롯머신 릴이 움직이는 느낌을 강화.
- `7/BAR/CHERRY/BELL/LEMON`을 각각 전용 드로잉 심볼로 표시하고, 기존 라벨 자식은 숨겨 레이아웃 텍스트가 릴 위에 떠 보이지 않게 정리.
- 레몬 심볼은 노란 과일형 바디와 내부 라벨을 추가해 단순 막대처럼 보이던 문제를 줄임.

### 검증
- `CompileCheck` 통과.
- `ScreenshotQA`: `11_slot_machine` 직접 확인. 릴 심볼/페이라인/버튼/레버/트레이 겹침 없음.

## 2026-06-21 (바카라/블랙잭 테이블 연출 강화)

### 수정
- `scenes/BaccaratTable.gd`: 베팅 단계에 PLAYER/TIE/BANKER/PAIR 실제 펠트 베팅존, 선택 금액 칩 스택, 사이드 베팅 스트립을 추가.
- 바카라 딜/결과 화면을 단순 카드 행에서 좌우 PLAYER/BANKER 카드존이 있는 테이블 화면으로 재구성. 결과 단계에서는 실제로 없는 세 번째 카드를 뒤집힌 카드로 표시하지 않도록 수정.
- `scenes/BlackjackTable.gd`: 베팅 단계에 블랙잭 반원 테이블, 베팅 서클, 칩 스택, 카드 슈, 딜러 실루엣을 추가.
- 블랙잭 플레이/결과 화면을 딜러존/플레이어존/베팅칩이 한 화면에 들어오는 테이블형 UI로 변경. 딜러 홀카드, 기본전략 힌트, 액션 버튼은 유지.
- `tools/ScreenshotQA.gd`: 바카라 QA 캡처 대기 시간을 늘려 6장 딜 상황에서도 결과 화면을 안정적으로 찍도록 조정.

### 검증
- `CompileCheck` 통과.
- `ScreenshotQA`: `09a_baccarat_betting`, `09_baccarat_table`, `10a_blackjack_betting`, `10_blackjack_table` 직접 확인. 카드/칩/테이블 영역의 큰 겹침 없음.

## 2026-06-21 (정선 카지노 허브 게임 카드 아트 개선)

### 수정
- `scenes/JeongseonCasino.gd`: 카지노 허브 게임 카드 상단의 공용 `card_back.png`/`poker_chip_icon.png` 텍스처 표시를 제거하고, 바카라/블랙잭/슬롯/룰렛/다이사이/빅휠별 미니 테이블/기기 아트를 코드 드로잉으로 표시.
- `scenes/MainGame.gd`, `scenes/TutorialOverlay.gd`, `scenes/HoldemClub.gd`: 결함 이력이 있는 `assets/ui/poker_chip_icon.png` 런타임 참조를 제거하고, 정렬된 denomination 칩 SVG(`chip_10k.svg`)로 교체.
- `docs/ASSET_QA.md`: `poker_chip_icon.png`를 legacy/deprecated로 명시하고 active runtime에서는 `assets/ui/chips/chip_*.svg` 또는 코드 드로잉을 쓰도록 기록.

### 의도
- 카지노 첫 화면이 동일 카드/칩 아이콘 반복으로 보이던 문제를 줄이고, 각 미니게임이 서로 다른 실제 테이블/기기처럼 읽히게 함.
- 중앙 문양/배치 문제가 있던 구형 칩 PNG가 다시 플레이어 화면에 노출되지 않도록 차단.

## 2026-06-21 (출시용 에셋 제작 파이프라인 정립)

### 수정
- `docs/PRODUCTION_ASSET_PIPELINE.md` 신규 추가. raw AI 이미지/오디오가 아니라 상용 출시 가능한 리소스로 승격하기 위한 Gate 0~4(정본 확인, 스펙 고정, 제작/보정, Godot 통합, 플레이어 관점 QA)를 정의.
- 에셋 등급(C/B/A/S), 외부 이미지/오디오 툴 사용 원칙, 라이선스 금지/허용 기준, P0~P3 우선순위, 외부 제작 요청 템플릿을 문서화.
- `docs/ASSETS_BRIEF.md`, `assets/VISUAL_AUDIO_UPGRADE_BRIEF.md`, `docs/ASSET_QA.md`, `docs/AUDIO_QA.md`가 새 production pipeline을 참조하도록 연결.

### 의도
- 앞으로 이미지/오디오를 "예쁜 생성물" 기준이 아니라 "게임 스토리와 상업 출시 정합성을 통과한 리소스" 기준으로 관리.
- Claude가 스토리/이벤트를 확장해도 Codex 외형 작업이 캐릭터/배경/CG/오디오 레이어 분리를 유지하도록 기준 고정.

## 2026-06-20 (룰렛 테이블 연출 강화)

### 수정
- `scenes/RouletteTable.gd`: 상단 휠 영역에 실제 테이블 펠트, 선택 베팅 패널, 결과/스핀 콜 패널, 딜러 실루엣, 베팅 칩 스택을 추가해 빈 공간을 줄임.
- 휠 스핀 중 공 잔상, 상단 포인터, 결과 번호 포켓 하이라이트를 추가.
- 숫자 베팅 매트를 단순 0~36 순차 버튼 배열에서 룰렛판에 가까운 3줄 배치(0 + 3/6/9..., 2/5/8..., 1/4/7...)로 변경.
- 숫자 버튼 갱신을 버튼 메타데이터 기반으로 바꿔 실제 배치와 선택/결과 강조가 어긋나지 않게 수정.

### 검증
- `./tools/audit.sh` 통과: ERROR 0 / WARNING 0, 밸런스 밴드 통과, Godot compile clean.
- `ScreenshotQA`: `12_roulette_table` 직접 확인. 휠/정보 패널/칩/숫자 매트 겹침 없음.

## 2026-06-20 (홀덤/경마 시야 가림 핫픽스)

### 수정
- `scenes/HoldemClub.gd`: 홀덤 베팅 칩을 팟까지 선으로 연결하던 연출 제거. 각 좌석 앞 테이블 위에 독립 칩 스택으로 표시되도록 변경.
- 중앙 팟 칩과 `POT` 금액 텍스트가 겹치지 않도록 팟 칩 위치와 금액 표시 위치를 분리.
- `scenes/RaceTrack.gd`: 경마 라이브 순위판을 주로 내부가 아니라 결승선 오른쪽 사이드 영역으로 이동. 1번 레인 말이 순위판에 가려지지 않도록 트랙 오른쪽 패딩 확보.

### 검증
- `./tools/audit.sh` 통과: ERROR 0 / WARNING 0, 밸런스 밴드 통과, Godot compile clean.
- `ScreenshotQA`: `06_holdem_club`, `07a_racetrack_race` 직접 확인. 홀덤 칩선 제거 및 경마 1번 레인 가림 해소.

## 2026-06-20 (슬롯머신 기기형 릴 연출 강화)

### 수정
- `scenes/SlotMachineGame.gd`: 기존 단일 심볼 카드형 릴을 상/중/하 3단 릴 창으로 변경해 실제 슬롯머신 내부 릴처럼 보이도록 개선.
- 릴 페이스에 유리 하이라이트, 중앙 페이라인, 상하 그림자, 내부 세로 가이드를 추가.
- 캐비닛 오버레이에 측면 크롬 라인, 나사, 우측 레버, 하단 페이아웃 트레이를 추가.
- 스핀 중 램프 점멸과 릴 정지 순간의 작은 충격 애니메이션을 추가.

### 검증
- `./tools/audit.sh` 통과: ERROR 0 / WARNING 0, 밸런스 밴드 통과, Godot compile clean.
- `ScreenshotQA`: `11_slot_machine` 직접 확인. 릴 창/레버/트레이/버튼 겹침 없음.

## 2026-06-20 (홀덤 테이블 시각화 강화)

### 수정
- `scenes/HoldemClub.gd`: 상대 목록/커뮤니티/내 패가 세로로 나뉘던 UI를 실제 오벌 포커 테이블 패널로 재구성.
- 좌우 상대 좌석, 하단 플레이어 좌석, 중앙 팟 칩 더미, 보드 카드 영역, 베팅 칩 트레일을 한 화면 안에 배치해 “테이블에 앉아 플레이한다”는 공간감을 강화.
- 쇼다운 시 승자 좌석 금색 테두리/글로우와 상대 카드 공개 애니메이션을 추가.

### 검증
- `./tools/audit.sh` 통과: ERROR 0 / WARNING 0, 밸런스 밴드 통과, Godot compile clean.
- `ScreenshotQA`: `06_holdem_club`, `06a_holdem_showdown` 직접 확인. 테이블 중앙 배치, 카드/좌석/버튼 겹침 없음.

## 2026-06-20 (경마 미니게임 질주 연출 강화)

### 수정
- `scenes/RaceTrack.gd`: 경마 질주 화면에 주로 패널, 레일, 거리 마커, 출발 게이트, 결승 게이트, 체크무늬 결승선, 라이브 순위판을 추가.
- 말/기수 실루엣 크기를 키우고 색상 아웃라인, 새들 번호판, 속도선/흙먼지 연출을 보강해 말이 배경에 묻히지 않도록 개선.
- 레이스 중 말발굽 느낌의 반복 SFX(`casino_reel` 저볼륨)와 마지막 직선 진입 SFX/흔들림을 추가.
- 결과 화면에서 레이스 중 콜 메시지가 남던 문제를 제거하고, `PHOTO FINISH` 패널을 추가해 1~3착 결승선 통과 장면을 시각화.

### 검증
- `./tools/audit.sh` 통과: ERROR 0 / WARNING 0, 밸런스 밴드 통과, Godot compile clean.
- `ScreenshotQA`: `07_racetrack_betting`, `07a_racetrack_race`, `07b_racetrack_result` 직접 확인. 질주/결과 화면 정상 배치.

## 2026-06-20 (빅휠 슬롯 분산 배치 수정)

### 수정
- `scenes/BigWheelGame.gd`: 빅휠 원판을 배당별 큰 덩어리 파이차트에서 54칸 실제 쇼휠형 분산 슬롯으로 변경. `1/2/5/10/20/JOKER`를 사이사이에 섞되 기존 확률 카운트(24/15/7/4/2/2)는 유지.
- 스핀 목표 계산도 섞인 슬롯 배열을 기준으로 바꿔, 결과 세그먼트와 실제 포인터가 멈추는 칸이 어긋나지 않도록 수정.
- pulled main의 `MainGame.gd` 타입 추론 컴파일 오류(`_asset :=`)를 `float` 명시로 수정.

### 검증
- `./tools/audit.sh` 통과: ERROR 0 / WARNING 0, 밸런스 밴드 통과, Godot compile clean.
- `ScreenshotQA`: `12a_bigwheel` 직접 확인. 배당 칸 분산 표시 및 화면 내 정상 배치 확인.

## 2026-06-20 (P0~P3 콘텐츠 확장 2차 — 이스터에그/분석/흥행/개연성)

> 역할 분담: Codex=외형(이미지/오디오/이펙트/UI·UX/카지노). Claude=내용. CONTENT_ROADMAP.md 우선순위대로 진행.

### P0 이스터에그 (총 8종, easter_eggs.json)
- 1차 6종: 고시원도사/삼각김밥/새벽4시/정직함의값/거울속도박꾼/조용한부자.
- 2차 2종 회귀자각: egg_deja_vu(2회+ 데자뷔)/egg_veteran_return(4회+ 베테랑). GameState.start_new_game에 total_runs 기반 is_repeat_run/is_veteran_run 플래그 추가.

### P1 분석요소 (완료)
- get_playstyle_label() 9종 분류 + peak_asset 추적(serialize 포함).
- 엔딩화면: 플레이스타일 진단 + "정점대비 N% 지킴".
- 엔딩 도감: MetaProgression.discovered_endings 영구누적 + get_ending_collection_progress(). 엔딩화면 "📖 N/29 발견"(+✨NEW) + 시작화면 스플래시 노출.

### P2 개연성 감사 (1차)
- 스크립트 스캔으로 직업/거주 상태 vs 묘사 충돌 탐지.
- jobs_004/jobs_010(팀장 야근/면담)·subway_hell_9(출근길) → has_job:true.
- mother_seoul_visit/rel_family_visit_seoul(좁은 방 보여주기) → housing:gosiwon; rel_sns_compare/family_002 텍스트 완화.
- EN/KR 조건 동기화 4건. 역방향·점원 전제 false positive 확인.

### P3 흥행 시그니처 (총 6종, viral_events.json)
- 갓생(기존0): godsaeng_start(3지선다)/godsaeng_paradox(번아웃 역설).
- geojibang_chat(거지방 지출검열), leading_room_joined(리딩방 회비사기).
- debt_invest_margin_call(주식 빚투 반대매매 D-1), gig_delivery_night(배달 N잡 생존).

### P5 도박 중독 서사 아크 (카지노 서사 영역 허용 후, 미니게임 메커니즘 미변경)
- gambling_rock_bottom (중독80+): 진짜 바닥 클라이맥스 — 단도박모임/아버지고백/더깊이(crypto_ghost 직전 분기).
- 회복 3종: recovery_first_week(금단)→recovery_relapse_test(재발유혹 분기)→recovery_one_month_clean(동그라미30개 구원).
- 기존 금단선택지(deleted_gambling_apps/tried_to_quit_gambling)를 in_recovery_started로 회복 아크에 연결.
- beat_addiction 업적 + MetaProgression.beat_addiction_ever 영구 플래그.
- 구원 엔딩 gambling_recovery(B급): "강남 못 갔어도 자신을 잃지 않았다". 엔딩 30개(finish_run 30:30 매핑).

### 검증
- 총 이벤트 1036개. Godot v4.6.2 헤드리스 프로젝트 임포트 클린.
- audit.py ERROR 0 / WARNING 0. 밸런스 밴드 불변.


## 2026-06-20 (스토리/게임성/흥행 콘텐츠 확장 — 역할 분담: Claude=내용)

> 역할 분담 확정: 코덱스 = 외형(이미지/오디오/이펙트/UI·UX/카지노). Claude = 스토리·개연성·재미·밸런스·공략성·게임성·흥행·이스터에그·분석요소.

### P0 — 이스터에그 발견형 6종 (easter_eggs.json 신규)
- egg_gosiwon_sage(고시원 30개월+ 수행), egg_triangle_kimbap(극빈 생존 코미디), egg_4am_clarity(정신력18↓ 바닥 자각·회복보상), egg_honest_paradox(정석18+ 자산1억미만 사회비평), egg_gambling_mirror(중독 자각 경고), egg_quiet_rich(20억인데 고시원).
- hidden+rarity 확률 발동 (legendary 0.4% / rare 1.2%, 운 보정). EN 번역 완료.

### P1 — 분석요소 강화
- `GameState.get_playstyle_label()`: 9종 분류(승부사/롤러코스터/관계형/원칙주의자/개척자/소진형/생존형/탐험가/균형형).
- `peak_asset` 추적(check_game_over+finish_run, serialize 포함). 엔딩화면 "최고자산 중 N% 지킴".
- `finish_run` 요약 확장: route, events_seen, peak_asset, playstyle.
- 엔딩 도감: `MetaProgression.discovered_endings` 영구 누적(run_history 50캡과 무관) + `get_ending_collection_progress()` + 엔딩화면 "📖 N/29 발견" + 신규시 ✨NEW.

### P3 — 흥행 시그니처 4종 (viral_events.json 신규)
- 갓생(기존 0개 갭): godsaeng_start(3지선다)/godsaeng_paradox(번아웃 역설).
- geojibang_chat(거지방 지출검열 문화), leading_room_joined(리딩방 회비 사기 폭로).

### 추가 (직전 세션 연속)
- 엔딩직전 분기씬 3종(arc_pre_ending.json, t>=234): 마지막 한 걸음/다섯 번째 겨울/마지막 통화.
- F·C급 엔딩 텍스트 200→400자+ 확장, arc_jaehyuk·arc_father 루트 변형.
- docs/CONTENT_ROADMAP.md 신규(P0~P4 우선순위).

### 검증
- 총 이벤트 1024개. Godot v4.6.2 헤드리스 프로젝트 임포트 클린(스크립트 에러 0).
- `tools/audit.py` ERROR 0 / WARNING 0. 밸런스 밴드 전부 통과(불변).


## 2026-06-20 (글쓰기 밀도·아크 완성도 강화 — Metacritic 90 목표)

### 신규 콘텐츠 (35개)
- **34세 독립 씬 3개** (`arc_midgame.json`): 루틴의 덫(t62-76)/부모님 서울 방문(t77-88)/2년째 자각(t89-96). orthodox·unorthodox·low_mental 변형 포함.
- **건강 이벤트 10개 + 코미디 이벤트 10개** (`life_events.json`): 수면 빚·운동·식사거름·요통 등 / 점심 메뉴·엘리베이터 침묵·프린터·1+1 등.
- **현수 아크 6개** (`arc_hyunsu.json` 신규): 같이 공부→시험날→합격/불합격→새 길→나중에 재회. cast_stages.json 현수 단계 1→10개 확장.
- **어머니 이벤트 3개** (`callback_events_28.json` 신규): 비교 전화/서울 방문/한강 화해.
- **엔딩 직전 궤적별 분기 씬 3개** (`arc_pre_ending.json` 신규, t>=234): 마지막 한 걸음(자산 2.5억↑)/다섯 번째 겨울(3억↓)/마지막이 될지 모르는 통화(아버지 화해).

### 글쓰기 강화
- **F/C급 엔딩 텍스트 확장** (endings.json): burnout/mental_break/bankruptcy/ordinary_life 200자→400자+. 응급실·정신과 진료실·추심 전화·편의점 500원 등 구체 장면.
- **arc_jaehyuk 3개** (01_reunion/03_pitch/04a_ghost): orthodox/unorthodox 변형 + 조종 구조 분석 묘사.
- **arc_father_04_visit**: "미안하다" 반응 무언의 장면 강화.
- **arc_father_02_signal/03_hospital**: low_mental/orthodox/unorthodox 변형 추가.

### 시스템
- `StoryMode._render_current()`: 루트·상태별 description_* 변형 렌더링 시스템.
- `GameState.apply_effects()`: route_orthodox/route_unorthodox 키 지원.
- `DataRegistry`: arc_hyunsu/arc_pre_ending/callback_events_28 등록.
- `MainGame._next_arc_id()`: 현수 아크 체인 + arc_34 + pre-ending 트리거.
- `audit.py`: EN/KR 조건 패리티 검사 #8 추가 (98건 수정), description_* 루트키 화이트리스트.

### 검증
- `tools/audit.py`: ERROR 0 / WARNING 0.
- 전체 신규/수정 콘텐츠 EN 번역 완료.


## 2026-06-20 (룰렛/빅휠/다이사이 카지노 물체감 패스)

### 수정
- `scenes/RouletteTable.gd`: 숫자 베팅판을 항상 보이는 룰렛 매트로 전환하고, 숫자 클릭 시 단일 숫자 베팅으로 자동 전환되도록 수정. 룰렛 휠 외곽 목재/금속 링, 볼 그림자, 허브 디테일을 보강하고 1280×800 화면에서 스크롤바가 생기지 않도록 전체 높이를 재압축.
- `scenes/BigWheelGame.gd`: 상단 전구 줄과 `BIG WHEEL` 마키를 추가하고, 쇼휠 외곽 링/볼트/포인터 마운트/스탠드를 그려 원판만 떠 있는 느낌을 줄임.
- `scenes/DaiSaiTable.gd`: 주사위 영역에 테이블 트레이, 유리 돔 하이라이트, 주사위 그림자/내부 하이라이트를 추가해 버튼형 UI보다 실제 테이블 오브젝트처럼 보이도록 개선.

### 검증
- `./tools/audit.sh` 통과: ERROR 0 / WARNING 0, 밸런스 밴드 통과, Godot compile clean.
- `ScreenshotQA`: `12_roulette_table`, `12a_bigwheel`, `12b_daisai_table` 직접 확인. 룰렛 스크롤바 없음, 빅휠/다이사이 주요 UI 화면 내 정상 배치.

## 2026-06-20 (슬롯머신 캐비닛화 + 바카라 테이블 중앙 정렬)

### 수정
- `scenes/SlotMachineGame.gd`: 슬롯 화면을 단순 UI 패널에서 실제 슬롯머신 캐비닛처럼 보이도록 재구성. 상단 램프, `LUCKY 7` 마키, CREDIT/BET/WIN 디지털 미터, 간이 페이테이블, 금색 릴 프레임, 페이라인 바, 물리 버튼형 `MAX BET`/`BET ONE`/`SPIN`, 하단 payout tray를 추가.
- `scenes/BaccaratTable.gd`: 바카라 베팅/딜링 화면을 중앙 펠트 테이블 패널 안에 고정 배치. 오른쪽 로드맵 여백 때문에 테이블이 왼쪽으로 밀려 보이던 offset을 제거하고, 카드 크기를 키워 테이블 위 플레이 감각을 강화.

### 검증
- `./tools/audit.sh` 통과: ERROR 0 / WARNING 0, 밸런스 밴드 통과, Godot compile clean.
- `ScreenshotQA`: `09a_baccarat_betting`, `09_baccarat_table`, `11_slot_machine` 직접 확인. 바카라 테이블 중앙 정렬 및 슬롯 화면 스크롤/클리핑 없음.

## 2026-06-20 (다이사이 카지노 미니게임 추가)

### 추가
- `systems/DaiSai.gd`: 다이사이/식보 수학 모델 추가. 빅/스몰, 홀짝, 싱글, 페어, ANY TRIPLE, 특정 트리플, 합계 4~17 베팅의 순배당 계산을 GameState와 분리된 순수 모델로 구현.
- `scenes/DaiSaiTable.gd`: 정선 카지노 내부 배경 위 중앙 테이블형 다이사이 미니게임 추가. Godot 드로잉 주사위, 롤 애니메이션, 베팅 버튼 하이라이트, 결과 히스토리, 칩 SVG 베팅 단위, 승패 사운드/진동 연동 포함.
- `JeongseonCasino.gd`: 허브에 6번째 게임 카드 `다이사이` 추가 및 용어 설명 보강.
- `TutorialOverlay.gd`: 다이사이 첫 진입 튜토리얼 추가.
- `MetaProgression.gd`: 다이사이 15라운드 칭호 `주사위의 밤` 추가.
- `ScreenshotQA.gd`: `12b_daisai_table.png` 자동 캡처 및 튜토리얼 억제 목록에 `daisai` 추가.

### 검증
- `./tools/audit.sh` 통과: ERROR 0 / WARNING 0, 밸런스 밴드 통과, Godot compile clean.
- `ScreenshotQA`: 31장 재캡처 완료. `08_jeongseon_casino`, `12b_daisai_table` 직접 확인.

## 2026-06-20 (외형 담당 분리 + 룰렛/빅휠 카지노 프레임 패스)

### 수정
- `scenes/StoryMode.gd`: 클로드 최신 메인 병합 후 발생한 `GameState.get("...", default)` Godot Object 호출 문법 오류를 직접 프로퍼티 접근으로 수정. `housing_months`는 현재 주거 ID 기준 딕셔너리 조회로 정리.
- `scenes/RouletteTable.gd`: 카지노 내부 배경/암막/중앙 펠트 테이블 프레임을 추가하고, 룰렛 휠 패널 높이를 키워 검은 보드 위 UI가 아니라 실제 카지노 테이블처럼 보이도록 조정.
- `scenes/BigWheelGame.gd`: 카지노 내부 배경/암막/중앙 기기 프레임을 추가하고, 빅휠 반지름과 휠 영역 높이를 키워 작은 UI 아이콘 느낌을 줄임.
- `scenes/BlackjackTable.gd`: 베팅/플레이/결과 화면을 중앙 펠트 테이블 패널 안에 배치하고, 카드 크기와 카드 행 정렬을 키워 블랙잭 테이블 위에서 플레이하는 느낌을 강화.

### 검증
- `./tools/audit.sh` 통과: ERROR 0 / WARNING 0, 밸런스 밴드 통과, Godot compile clean.
- `ScreenshotQA`: 30장 재캡처 완료. `10a_blackjack_betting`, `10_blackjack_table`, `12_roulette_table`, `12a_bigwheel` 직접 확인.

## 2026-06-20 (3~5년차 아크 + 챕터 카드 시네마틱 + 10개 영역 게임 분석)

### 추가
- `content/events/arc_midgame.json`: 35세(3개) / 36세(3개) / 37세(3개) 아크 씬 총 9개 신규 작성
- `content/events_en/arc_midgame.json`: 9개 EN 번역 동기화 (KR/EN 50개 파리티)
- `scenes/StoryMode.gd`: 챕터 카드 시네마틱 (`_render_chapter_card_cinematic()`) — 블랙 배경 + 페이드인 타이틀 시퀀스
- `scenes/MainGame.gd`: `_next_arc_id()` 섹션 8 트리거 8개 → 23개 (연도 마커 + 챕터 내부 씬 분리)
- `docs/IMPROVEMENT_ANALYSIS.md`: 13개 영역 게임 분석 + 우선순위 매트릭스 (P0~P3)

### 수정
- `content/events_en/life_events.json`: EN 조건 불일치 6건 수정 (jeongseon_visited/route_orthodox 플래그 오류)

---

## 2026-06-20 (영어 시작 화면 + 엔딩 CG + 카지노 칩 UI + 바카라 가독성 패스)

### 추가
- `tools/LocaleSurfaceCheck.tscn`/`.gd`를 추가해 영어 설정 시 StartMenu와 OpeningCinematic 핵심 문구가 영어로 표시되는지 검증.
- `ScreenshotQA`에 영어 시작 화면 캡처 `00b_start_menu_en.png`를 추가.
- `tools/StoreScreenshotExport.tscn`/`.gd`를 추가해 `/tmp/gangnamdream_qa`의 QA 캡처에서 Steam 스토어 후보 8장을 1280×720으로 자동 추출하고 `manifest.md`/`manifest.json`을 생성.
- 엔딩 전용 CG P1 3종 추가: `assets/cg/ending_gangnam_dream.png`, `assets/cg/ending_empty_house.png`, `assets/cg/ending_crypto_ghost.png`.
- `ScreenshotQA`에 빅휠 본체 캡처 `12a_bigwheel.png`를 추가.
- `ScreenshotQA`에 홀덤 쇼다운 `06a_holdem_showdown`, 경마 베팅/질주/결과 `07_racetrack_betting`, `07a_racetrack_race`, `07b_racetrack_result` 캡처를 추가해 미니게임 핵심 상태를 자동 검수.

### 수정
- StartMenu의 헤더, 스토리 소개, 난이도 카드, 런 테마 카드, 저장 슬롯, 설정 팝업, 콘텐츠 안내, 시작 버튼을 `LocaleManager` 기준으로 영어/한국어 분기.
- SplashScreen과 OpeningCinematic을 저장된 언어 설정에 맞춰 영어로 표시하고, 영어 모드에서는 한글 로고 이미지를 숨겨 첫 인상이 한국어로 남지 않게 조정.
- 엔딩 모달은 전용 CG가 있을 때만 와이드 컷신 프리뷰를 표시하도록 변경. 전용 CG가 없는 엔딩에는 잘못 맞춘 배경 fallback을 금지해 정합성 없는 이미지 노출을 막는다.
- `gangnam_dream`, `empty_house`, `crypto_ghost` 엔딩에 전용 `cg` 필드를 연결해 배경 프리뷰가 아니라 엔딩별 컷신으로 마무리되게 변경.
- 엔딩 설명도 이벤트 텍스트와 같은 포맷터를 통과시켜 `{name}`, `{money}`, `{assets}` 같은 플레이스홀더가 그대로 보이지 않도록 수정.
- 미니게임 진입 시 MainGame 루트 UI, 정보 패널, 모달 레이어, 비네팅/플래시를 숨기고 미니게임 노드를 앞으로 올려 `2026년 1월` 같은 배경 HUD가 카지노/경마/홀덤 뒤에 남지 않도록 수정.
- 바카라 테이블 레이아웃을 스크롤 컨테이너 좌상단 배치에서 중앙 고정 폭 풀스크린 배치로 변경하고, 카드 행과 베팅 상태를 중앙 정렬.
- 슬롯머신, 홀덤, 스캘핑 결과 반영을 직접 `GameState.money +=/-=` 대신 `GameState.add_money()`로 통일해 실제 자산과 HUD 갱신 신호가 같이 흐르도록 수정.
- `AudioManager.play_casino_result()`를 추가해 경마/홀덤/바카라/블랙잭/룰렛/빅휠의 승패·대박 결과 사운드와 컨트롤러 진동 피드백을 손익 규모 기준으로 통일.
- 바카라 테이블 배경에 불투명 베이스를 깔아 뒤의 MainGame HUD/시스템창이 비쳐 보이지 않도록 수정.
- `docs/ENDING_ART.md`에 런타임 엔딩 프리뷰 정책과 전용 CG 우선순위를 갱신.
- `CGRuntimeCheck`/`VisualCropQA`/`ScreenshotQA`에 신규 엔딩 CG 검수 케이스를 추가.
- 슬롯/룰렛/빅휠 베팅 금액 버튼에 `assets/ui/chips/*` denomination 칩 SVG를 연결해 블랙잭/바카라와 같은 카지노 UI 언어로 통일.
- 룰렛은 베팅 금액 선택 후 버튼 하이라이트가 즉시 갱신되도록 스테이크 버튼 참조/refresh 경로를 추가.
- 빅휠은 남아 있던 이모지성 HUD/버튼/조커 표기를 `현금`, `SPIN`, `규칙`, `JOKER` 텍스트로 정리.
- 홀덤/경마/블랙잭 배경에 불투명 베이스를 먼저 깔고, 슬롯/룰렛/빅휠 루트 배경 alpha를 1.0으로 고정해 MainGame 대시보드가 미니게임 뒤에 비쳐 보이던 문제를 차단.
- 홀덤 visible UI(`STACK`, 승패 메시지)와 블랙잭/바카라/슬롯 로그·배너의 카지노 이모지 텍스트를 제거해 카드/칩 에셋 중심의 톤으로 통일.

### 검증
- `./tools/audit.sh` 통과: ERROR 0 / WARNING 0, 밸런스 밴드 통과, Godot compile clean.
- `LocaleSurfaceCheck`: `LOCALE_SURFACE_CHECK_OK`
- `AudioAssetCheck`: `AUDIO_ASSET_CHECK_OK bgm=7 ambience=5 sfx=28`
- `CGRuntimeCheck`: `CG_RUNTIME_CHECK_OK`
- `SmokeRace`: `SMOKE_ALL_OK`
- `ScreenshotQA`: 30장 재캡처 완료. `09a_baccarat_betting`, `09_baccarat_table`, `08_jeongseon_casino`, `13_ending_gangnam_win`, `15_ending_stable_success`, `17_ending_orthodox_pinnacle` 직접 확인.
- `StoreScreenshotExport`: `STORE_SCREENSHOT_EXPORT_OK dir=/tmp/gangnamdream_store_screenshots count=8`

## 2026-06-19 (BGM 연속성 + 첫 면접 배경 + 초상화 레이아웃 패스)

### 추가
- `assets/backgrounds/office_interview_day.png`를 추가해 첫 면접/면접관/인터뷰 이벤트가 야근용 밤 사무실 배경을 쓰지 않도록 분리.
- `tools/BGMContinuityCheck.tscn`/`.gd`를 추가해 같은 BGM 컨텍스트 재진입 시 재생 위치가 0초로 리셋되지 않는지 검증.
- `ScreenshotQA`에 첫 면접 스토리 캡처 `00a_story_interview.png`를 추가.

### 수정
- `BGMPlayer.start()`/`start_menu()`가 이미 같은 트랙을 재생 중이면 다시 `play()`하지 않고 유지하도록 변경.
- 이벤트 종료 후 메인으로 돌아올 때 idle ambience를 복구하고, StoryMode 이벤트 렌더 시 장소 ambience를 갱신.
- `ImageRegistry`에 `office_interview_day`를 등록하고, 면접 키워드/태그가 일반 office보다 먼저 낮 면접실로 추론되도록 정리.
- `arc_intro_01_meal`, 희귀 면접 이벤트 2종, exec interview 체인 이벤트의 배경을 `office_interview_day`로 명시.
- MainGame 좌측 초상화 패널과 StoryMode 우측 초상화 프레임을 키워 인물이 더 VN식으로 존재감 있게 보이도록 조정.

### 검증
- `./tools/audit.sh` 통과: ERROR 0 / WARNING 0, 밸런스 밴드 통과, Godot compile clean.
- `BGMContinuityCheck`: `BGM_CONTINUITY_OK`
- `AudioAssetCheck`: `AUDIO_ASSET_CHECK_OK bgm=7 ambience=5 sfx=28`
- `CGRuntimeCheck`: `CG_RUNTIME_CHECK_OK`
- `SmokeRace`: `SMOKE_ALL_OK`
- `ScreenshotQA`: 24장 재캡처 완료 (`00a_story_interview` 추가).

## 2026-06-19 (카드/칩 Texture + 상점 팔레트 패스)

### 추가
- `assets/ui/card_front_base.svg`를 추가해 블랙잭/바카라/홀덤의 visible card가 같은 카드 제품군처럼 보이도록 통일.
- `assets/ui/chips/chip_1k.svg`~`chip_1m.svg` denomination 칩 세트를 추가.
  - 중앙 장식/문양 없이 실제 칩형 인레이, 흰 edge insert, 동심원, 숫자 denomination 중심으로 구성.
- `ScreenshotQA`에 베팅 전 화면 캡처 2장 추가: `09a_baccarat_betting`, `10a_blackjack_betting`.

### 수정
- 블랙잭/바카라 stake 버튼에 금액별 칩 Texture를 연결하고 버튼 폭/아이콘 최대 너비를 보정.
- 블랙잭/바카라/홀덤 카드 앞면을 절차적 패널에서 `card_front_base.svg` + 랭크/무늬 오버레이 구조로 교체.
- 상점의 보라색 포인트를 생활/경제 UI에 맞는 녹색 계열로 정리.
- `ScreenshotQA` 시작 메뉴 캡처 후 남는 StartMenu 노드를 재귀적으로 제거해 초반 캡처가 같은 화면으로 고정되는 문제를 수정.

### 검증
- `./tools/audit.sh` 통과: ERROR 0 / WARNING 0, 밸런스 밴드 통과, Godot compile clean.
- `AudioAssetCheck`: `AUDIO_ASSET_CHECK_OK bgm=7 ambience=5 sfx=28`
- `CGRuntimeCheck`: `CG_RUNTIME_CHECK_OK`
- `SmokeRace`: `SMOKE_ALL_OK` (Godot 종료 시 리소스 정리 경고는 남음)
- `ScreenshotQA`: 23장 재캡처 완료.

## 2026-06-19 (오디오 P1 + 모달 UI 스킨 4차)

### 추가
- 장소 ambience 5종과 엔딩 stinger 3종을 로컬 생성·import.
  - `amb_goshiwon_room`, `amb_seoul_rain`, `amb_hangang_riverside`, `amb_office_room`, `amb_casino_floor`
  - `sfx_ending_stinger_good`, `sfx_ending_stinger_bad`, `sfx_ending_stinger_legend`
- `BGMPlayer`에 BGM과 별개로 낮은 ambience 레이어를 추가하고 이벤트/주거/카지노 진입 상황에 따라 자동 전환.
- `AudioManager` 엔딩 stinger 분류를 엔딩 grade/ID 기준으로 연결.
- `ScreenshotQA`에 투자 주변 보조 모달 3장 추가: `02a_bank_modal`, `02b_shop_modal`, `02c_system_menu`.

### 수정
- 투자/은행/상점/시스템 모달에 SVG/Icon 기반 버튼과 섹션 헤더를 적용해 게시판형 텍스트 버튼 느낌을 줄임.
- 큰 모달 제목의 잔여 이모지 접두어를 제거해 헤더 톤을 통일.
- `AudioAssetCheck`가 BGM/SFX뿐 아니라 ambience 파일도 검증하도록 확장.

### 검증
- `./tools/audit.sh` 통과: ERROR 0 / WARNING 0, 밸런스 밴드 통과, Godot compile clean.
- `AudioAssetCheck`: `AUDIO_ASSET_CHECK_OK bgm=7 ambience=5 sfx=28`
- `CGRuntimeCheck`: `CG_RUNTIME_CHECK_OK`
- `SmokeRace`: `SMOKE_ALL_OK`
- `ScreenshotQA`: 21장 재캡처 완료.

## 2026-06-19 (UI 스킨 P1 3차 + 카지노 본체 물체감 1차)

### 수정
- MainGame 정보 패널 탭명과 행동 카테고리 모달의 잔여 이모지/프로토타입식 버튼 문구를 정리.
- 블랙잭/바카라 HUD, 제목, 규칙, 딜/히트/스탠드/다음 라운드 버튼을 텍스트 중심 카지노 테이블 UI 톤으로 정리.
- 슬롯머신 릴을 플랫폼 이모지 대신 `7`/`BAR`/`CHERRY`/`BELL`/`LEMON` 고정 심볼 타일로 렌더링.
- 룰렛 화면에 Godot Canvas 기반 휠/볼 드로잉을 추가해 숫자 결과 생성기 느낌을 줄임.
- 경마 HUD/정보상/결과 화면의 잔여 이모지 문구를 정리.
- `ScreenshotQA`에 바카라/블랙잭/슬롯/룰렛 본체 캡처 4장을 추가하고, 출력 폴더를 매 실행마다 비우도록 수정.
- `SmokeRace`가 카운트다운 타이머를 남기지 않도록 스모크 전용 countdown skip 경로를 추가.

### 버그 수정
- 슬롯 니어미스 판정이 표시용 문자열 `symbols`를 숫자로 비교하던 런타임 오류를 `reels` 숫자 배열 기준으로 수정.
- RaceTrack 카운트다운의 로컬 재귀 Callable이 헤드리스 스모크에서 null 연결 에러를 내던 문제를 헬퍼 함수로 분리해 수정.

### 검증
- `./tools/audit.sh` 통과: ERROR 0 / WARNING 0, 밸런스 밴드 통과, Godot compile clean.
- `AudioAssetCheck`: `AUDIO_ASSET_CHECK_OK bgm=7 sfx=25`
- `CGRuntimeCheck`: `CG_RUNTIME_CHECK_OK`
- `SmokeRace`: `SMOKE_ALL_OK`
- `ScreenshotQA`: 18장 재캡처 완료 (`09_baccarat_table`~`12_roulette_table` 추가).

## 2026-06-19 (UI 스킨 P1 2차 + 메뉴/튜토리얼 QA 확장)

### 수정
- StartMenu 난이도/런 테마 카드를 이모지 기반에서 SVG 아이콘 기반 카드로 교체.
- StartMenu 설정/삭제/시작/콘텐츠 안내 버튼 문구를 상업 UI 톤으로 정리.
- Splash `PRESS ANY KEY` 루프 트윈을 dismiss 시 kill하도록 수정해 ScreenshotQA 경고 제거.
- TutorialOverlay 중앙 아이콘을 플랫폼 이모지 대신 카드/칩/통일 SVG Texture로 교체.
- ScreenshotQA에 `00_start_menu.png` 캡처를 추가하고, 미니게임 자동 튜토리얼을 suppress해 홀덤/경마 본체 화면이 QA에 찍히도록 수정.
- 홀덤/경마 상단 조작 UI의 이모지/물음표 버튼을 텍스트 중심으로 정리.
- StoryMode 배경을 `STRETCH_KEEP_ASPECT_COVERED`로 전환하고 상단 HUD를 텍스트 상태바로 정리.

### 검증
- `./tools/audit.sh` 통과: ERROR 0 / WARNING 0, 밸런스 밴드 통과, Godot compile clean.
- `AudioAssetCheck`: `AUDIO_ASSET_CHECK_OK bgm=7 sfx=25`
- `CGRuntimeCheck`: `CG_RUNTIME_CHECK_OK`
- `ScreenshotQA`: 14장 재캡처 완료 (`00_start_menu.png` 추가, 홀덤 실제 핸드 화면 캡처).
- 참고: ScreenshotQA 종료 시 Godot resource cleanup 경고가 남지만 exit code는 0이고 모든 캡처는 정상 생성됨.

## 2026-06-19 (UI 스킨 P1 + 정선 카지노 허브 오브젝트화 1차)

### 수정
- MainGame 상단 HUD를 텍스트/이모지 나열에서 SVG 아이콘 기반 상태칩으로 교체.
- MainGame 직접 행동 목록을 단순 텍스트 버튼에서 아이콘, 제목, 보조 설명, AP/무료 배지가 있는 액션 카드로 교체.
- 첫 시작 안내 모달을 긴 문서형 튜토리얼에서 4개 규칙 카드 + 시작 버튼 구조로 축소.
- 정선 카지노 허브에서 이모지 게임 아이콘을 제거하고 `card_back.png`/`poker_chip_icon.png` 기반 오브젝트 프레임으로 교체.
- 정선 카지노 허브 헤더/하단 안내 여백 보정, 입장 버튼 casino SFX 연결, 허브 open 페이드인 추가.

### 검증
- `./tools/audit.sh` 통과: ERROR 0 / WARNING 0, 밸런스 밴드 통과, Godot compile clean.
- `AudioAssetCheck`: `AUDIO_ASSET_CHECK_OK bgm=7 sfx=25`
- `CGRuntimeCheck`: `CG_RUNTIME_CHECK_OK`
- `ScreenshotQA`: 13장 재캡처 후 MainGame/정선 카지노 허브 시각 확인.

## 2026-06-19 (플레이어 체감 표면 QA + 동적 연출 1차)

### 런타임 QA
- 실제 Godot 렌더러로 `tools/ScreenshotQA.tscn` 실행. 캡처 위치: `/tmp/gangnamdream_qa/`.
- `tools/VisualCropQA.tscn` 통과: 배경/초상화 crop QA 15장 정상.
- `tools/AudioAssetCheck.tscn` 최초 실패 확인: 카지노 전용 SFX 8개가 코드에 연결돼 있으나 실제 wav 파일이 없었음.
- `tools/CGRuntimeCheck.tscn` 최초 실패 확인: `gangnam_dream` 승리 엔딩에 과거 병실 CG를 기대하던 낡은 QA 로직.

### 수정
- `docs/PLAYER_FACING_POLISH_AUDIT.md` 추가: UI/UX, 이미지 에셋, 오디오 에셋, 미니게임 표면, Godot motion 계획을 플레이어 체감 기준으로 정리.
- 카지노 SFX 8종 생성 및 import:
  - `sfx_casino_card`, `sfx_casino_bet`, `sfx_casino_coin`, `sfx_casino_spin`
  - `sfx_casino_reel`, `sfx_casino_win`, `sfx_casino_lose`, `sfx_casino_jackpot`
- 빨간 위기 비네팅을 실제 위급 상태 전용으로 축소: 건강 25 이하 또는 정신력 15 이하에서만 강하게 점등.
- 대시보드/행동 비네팅 진입 시 category tint와 feedback flash를 즉시 해제하도록 수정.
- MainGame 배경을 `STRETCH_KEEP_ASPECT_COVERED`로 전환하고 미세한 배경 드리프트를 추가.
- `CGRuntimeCheck` 수정: 엔딩 CG 함수와 preview는 synthetic ending으로 검증하고, `gangnam_dream`은 병실 CG를 쓰지 않는 것을 확인.
- StartMenu 레거시 문구 `100만원` → `50만원` 수정.

### 검증
- `AudioAssetCheck`: `AUDIO_ASSET_CHECK_OK bgm=7 sfx=25`
- `CGRuntimeCheck`: `CG_RUNTIME_CHECK_OK`
- `ScreenshotQA`: 13장 재캡처 완료.

## 2026-06-19 (Claude cloud 브랜치 병합 정리 + Codex 비주얼 에셋 재적용)

### 영문 번역 완료
- `life_events.json`: 62→111개 (49개 신규 번역)
  - 시즌/일상, 구직/직장, 스타트업·정치 루트, 아버지 화해 아크,
    카지노 이벤트, 생존 모드, 로맨스 트랙, 자기계발, 동창 이벤트 등
- `relationship_events.json`: 4→53개 (49개 신규 번역)
  - 직장 역학, 가족 방문, 지연 아크(6종), 상철 아크(5종),
    다은 아크(3종), 소셜/로맨틱 이벤트, 멘토 관계 등
- **총합: 978/970 이벤트 번역 (100% 커버리지)**

### main 병합 (Codex 비주얼 에셋 재적용)
- Codex 비주얼 에셋: 정선 카지노 내부/입구/외관, 헬스장, 한강, 남산, 카드/칩 이미지
- BaccaratTable.gd, BlackjackTable.gd, JeongseonCasino.gd 씬 업데이트
- ImageRegistry.gd 배경 라우팅 갱신
- `./tools/audit.sh` ERROR 0 / WARNING 0 통과 (main 기준)

### 커밋
- `e186279` — feat: complete EN translations for life_events and relationship_events
- `3f6b91c` — docs: update CLAUDE.md and WORK_LOG for EN translation completion

---

## 2026-06-18 후반30 — NG+ 엔딩 시스템 전체 구현

### 설계
- 1회차에서 도달 불가, 2회차 이후만 가능한 엔딩 3종
- MetaProgression에 영구 플래그 3종 누적 저장 (런 간 기억)
- 2회차에서 핵심 인물 첫 만남 씬이 교체되는 분기 이벤트 3종

### MetaProgression.gd 수정
- `meta` 프로퍼티 alias 추가 (`data`와 동일 객체, 외부 접근 편의)
- `record_run()`에 NG+ 플래그 누적: `sangchul_truth_ever_known` / `father_passed_ever` / `daeun_ending_ever_seen`

### ng_plus_events.json 신규 생성 (3종)
- `arc_sangchul_ng_meet`: 두 번째 첫 만남 — 모른 척(ng_playing_sangchul) vs 즉시 대면(ng_confronted_sangchul_early)
- `arc_daeun_ng_meet`: 이번엔 다르게 — 처음부터 진심(ng_committed_to_daeun) vs 그냥 지나침
- `arc_father_ng_call`: 이번엔 먼저 — 주말에 내려감(ng_father_priority) vs 짧게 끊음

### endings.json 수정 — 3종 추가 (총 30 엔딩)
- `full_circle` (S+): 상철 청산 + 30억 + 아버지 생존
- `second_love` (A+): 다은과 함께 + 10억+
- `guardian` (A+): 아버지 지킴 + 화해

### GameState.gd 수정
- `check_game_over()` 최우선 NG+ 분기 3종 추가 (기존 30억 체크 앞)

### MainGame.gd 수정
- `_next_arc_id()`: NG+ 라우팅 블록 삽입 (2구간 첫 만남 앞)
- `_show_ending()`: grade_colors/emojis에 S+/A+ 추가, ending_bg_map 3종 추가
- `_ending_run_summary()`: NG+ 엔딩 3종 요약 추가
- `_ending_cast_epilogue()`: good 목록에 NG+ 3종 추가
- `_ending_next_run_hints()`: 1회차 플래그 기반 2회차 암시 힌트 3종

### DataRegistry.gd / BGMPlayer.gd 수정
- ng_plus_events.json 등록
- BGMPlayer good endings에 NG+ 3종 추가

### 검증
- ERROR 0 / WARNING 0 / 밸런스 밴드 전부 통과

## 2026-06-18 후반29 — 풀 플레이스루 시뮬레이션 + 중반전 공백 수정

### 플레이스루 시뮬레이션 결과
- Python 시뮬레이터 작성 (270턴 전체 arc 순서 추적)
- 발견: arc_father_06_confession이 arc_sangchul_03_seen에 의존 → 자산 1M 미만이면 아버지 고백 씬 차단
- 발견: t68-t145 구간 7-9개월 무조건 발동 아크 공백
- 발견: 신규 드라마 아크(arc_father_06_confession, arc_sangchul_confrontation, arc_jaehyuk_mirror) 모두 정상 발동 확인

### 수정 1 — arc_father_06_confession 조건 완화
- `arc_sangchul_03_seen` → `arc_sangchul_02_seen` (커피 1회면 이름 인식 가능)
- 효과: 투자 루트 미선택 플레이어도 아버지 고백 씬 접근 가능 (t56+에 발동)

### 수정 2 — 중반전 공백 구간 연도 마커 3종 추가 (arc_midgame.json)
- `arc_year_one_half` (t68-90, 1년 반): 편의점 캔커피 장면, 1년 반 정산
- `arc_year_two_half` (t120-140, 2년 반): 2년 반 지침/방향 점검
- `arc_year_three_half` (t168-188, 3년 반): 수학적 가능/불가능 판단
- 효과: 최대 공백 12개월 → 7개월로 감소, 총 아크 이벤트 72개

### 최종 시뮬레이션 결과
- 총 아크 72개 / DB 미존재 0개 / 플레이타임 약 252분(4h 12m)
- 연도 마커 8종 전부 정상 발동
- 최대 아크 공백 7개월 (이전 12개월)

## 2026-06-18 후반28 — 스토리 전면 개편: 임상철 반전 + 아버지 비극 아크

### 핵심 반전 설계 및 구현
- **중심 아이디어**: 임상철이 아버지를 망하게 한 박상진의 소개인이었다
- 첫 만남("아버지한테 보여드리고 싶어서요")에서 상철은 처음부터 알고 있었음
- 이 반전이 모든 상철 씬을 소급해서 재해석하게 만듦

### 신규 파일: content/events/arc_drama.json (5개 아크 이벤트)
- `arc_father_06_confession` (t≥56): 아버지 고백 — "임가라고" → 민준 내부 충격 (mental -8~14), 세 가지 반응
- `arc_sangchul_confrontation` (t≥60): 진실 알게 된 후 대면/묻어두기/이탈 3분기
- `arc_sangchul_reckoning` (follow_up): 상철 "미안하다" → 신고(sangchul_reported)/용서/역이용
- `arc_jaehyuk_mirror` (t≥60): 재혁 보증 요청 = 아버지 실수 반복, mental -5~15
- `arc_father_passing` (t≥64): 세 번의 부재 끝 아버지 별세, mental -25~40

### content/endings.json — sangchul_reckoning [B] 추가
- "강남은 없었다. 근데 그 전화 한 통이 6년의 빚보다 더 무거운 걸 내려놓게 해줬다."
- 총 엔딩 27종으로 증가

### content/meta/cast_stages.json — 신규 스테이지
- father: `"passed"` 추가
- sangchul: `"exposed"`, `"cut_off"` 추가

### autoloads/GameState.gd — finish_run() 분기 수정
- `father_passed` → 30억 달성 시 empty_house (보여줄 사람 없는 집)
- `sangchul_reported` + 아버지 생존 → sangchul_reckoning 엔딩
- `father_passed` 시 late_call 차단 (타임리밋)

### scenes/MainGame.gd — _next_arc_id() 연결 4종 추가
- arc_father_passing (t≥64, 병원 알고도 미방문)
- arc_father_06_confession (t≥56, 방문+05+sangchul_03)
- arc_sangchul_confrontation (t≥60, sangchul_truth_known)
- arc_jaehyuk_mirror (t≥60, aftermath_seen)
- arc_father_04_visit에 father_passed 가드 추가

### 감사 결과
- ERROR 0 / WARNING 0 / 밸런스 밴드 전부 통과

## 2026-06-18 후반27 (자율 QA 4차 — 심층 무결성 전수 감사)

### 선택지 안내 텍스트 '스트레스' → '정신력-' 3건 수정
- `amb_jeonse_00[2]`, `amb_holiday_00[0]`, `reunion_rsvp_00[0]`
- 스탯 통합 후 선택지 괄호 힌트에 삭제된 "스트레스" 표기 잔재
- 실제 effects는 이미 `mental` 키 사용 중 — 표시 불일치만 수정

### 전수 심층 감사 항목 (모두 통과)

| 체크 항목 | 결과 |
|---|---|
| 끊긴 follow_up 참조 | 0 |
| 유효하지 않은 cast_effects PID | 0 |
| 유효하지 않은 cast_effects 값 키 | 0 |
| 유효하지 않은 cast stage 전환 | 0 |
| 잘못된 relationship_effects 형식 | 0 |
| 매핑 누락 portrait ID (25종) | 0 |
| 매핑 누락 background ID (27종) | 0 |
| 누락 arc 이벤트 ID (106종) | 0 |
| 누락 milestone/chapter_card ID (5종) | 0 |
| 고아 플래그 (코드 설정분 포함) | 0 |
| 미구현 condition 키 | 0 |
| 랜덤 풀 노출 arc 이벤트 | 0 |
| has_job:false 잔재 | 0 |
| 이중발동 위험 follow_up 타겟 | 0 (cooldown:9999 보호) |
| modify_hidden_stat("stress") 미리디렉트 | 0 |

### 검증 내용 요약
- 959개 이벤트 cast/relationship/follow_up 교차 검증 완료
- 11개 "고아 플래그" — 실제로는 `_resolve_opportunity()` win_flag/lose_flag 및 GameState.gd 직접 대입으로 정상 설정
- hyunsu cast_effects 21개 — stage 전환 없이 affinity/met/flags만 사용 (cast_stages 단일 stage와 일치)
- `class_reunion_lie_exposed`: follow_up 체인 AND 랜덤 풀 양쪽 노출 가능하나 cooldown:9999로 이중 발동 방지
- audit.sh: ERROR 0 / WARNING 0 / 밸런스 밴드 전부 통과

## 2026-06-17 후반26 (자율 QA 3차 — relationship_effects 형식 버그 + 최종 9종 체크)

### relationship_effects dict 형식 버그 16종 수정
- GDScript: `for rel_effect in choice.get("relationship_effects", []):`
  dict를 순회하면 키(문자열) 반복 → `apply_relationship_effect("affinity")` 호출 → 조용히 실패
- 15건: relationship_events.json (social_life_*, romance_*, family_*, jobs_*)
- 1건: hidden_events.json (hidden_chaebol_elevator[0])
- 모두 부정확한 `affinity` 키(실제는 `affection`) + 유효하지 않은 타입 사용
  → 의도된 관계 생성이 아닌 데드 코드 → 제거 처리

### 최종 체크리스트 (959개 이벤트 전수)
| 체크 항목 | 결과 |
|---|---|
| 빈 result_text | 0 |
| 빈 choice text | 0 |
| 누락 category | 0 |
| 비보호 weight=0 | 0 |
| 끊긴 follow_up | 0 |
| 잘못된 housing 조건 | 0 |
| dict형식 relationship_effects | 0 |
| 잘못된 job_id 조건 | 0 |
| 잘못된 cast stage 참조 | 0 |

## 2026-06-17 후반25 (자율 QA 2차 — 조건 시스템 전수 감사 + housing 버그 수정)

### 자율 QA 루프 — 전수 조건/효과 감사 완료

#### jiyeon_gangnam_moment housing='gangnam' 무발동 버그 수정 (CRITICAL)
- `conditions.housing: "gangnam"` — HOUSING_DATA에 없는 타입 (유효값: gosiwon/oneroom/villa/apartment)
- 이 이벤트는 한지연과 연인 관계 + 강남 입성 직전에 발동해야 하는 고자산 구간 이벤트
- 수정: `housing: "gangnam"` → `min_assets: 2000000000` + `min_turn: 180`

#### EventManager min_assets / max_assets 조건 신규 추가
- `get_total_asset_value()` 기반으로 총 자산(현금+포트폴리오-대출) 조건 지원
- 이벤트에서 고자산 구간 가중치 조정에 활용 가능

#### 전수 감사 항목 (모두 통과)
- 조건 키 화이트리스트: has_portfolio/has_relationship/min_stress/max_stress/min_addiction 등
  모두 EventManager에 구현 확인 (valid_cond_keys set 불완전했던 것 — 실제 버그 없음)
- 효과 키 전수: VALID_EFFECT_KEYS 완전 일치, unknown 0건
- cast stage / cast_effects: 유효 PID 외 사용 0건
- opportunity 블록: 19개 모두 올바른 stake_ratio/success_rate 형식 (win_text/lose_text는 없는 필드)
- deferred_follow_up 3종: 모두 대상 이벤트 존재 확인
- 전체 arc IDs 125종 / milestone IDs 16종 / story pool 7종: 모두 JSON 파일 내 존재
- _seen 플래그 92종: 이벤트 choices.flags 또는 코드에서 모두 설정됨
- 인물별 cast affinity 극값(-100): arc_jaehyuk_04a_ghost/04b_counter 의도된 배신 이벤트
- job_id/job_category/housing 조건: 모두 유효 열거값 사용

## 2026-06-17 후반24 (자율 QA 심화 — follow_up 이벤트 은닉 + 카테고리 필드 119종 보완)

### 자율 QA 루프 — 심화 감사 완료

#### follow_up 전용 이벤트 hidden=true 처리
- weight=0이지만 hidden=false·conditions={} 인 이벤트 3종 추가 수정
  - race_tip_seller_02: hidden=true (race_tip_seller_01의 follow_up 전용)
  - butterfly_mystery_info_details: hidden=true (butterfly_gangnam_encounter의 follow_up 전용)
  - rare_lottery_result: hidden=true (rare_convenience_lottery의 follow_up 전용)
- EventManager._effective_weight()는 max(0.01, weight) → weight=0도 0.01 가중치로 풀 노출 가능
  이 패턴의 모든 위반 0건으로 완전 소거

#### BGM 엔딩 분류 수정
- lonely_rich (A), late_call (B) → BGMPlayer good 목록에 추가 (good 엔딩 BGM)
- MainGame._ending_cast_epilogue good 목록에도 late_call 추가
- 나머지 A/B 엔딩 분류 이상 없음 (empty_house/jaehyuk_way는 의도적 bad BGM — 테마상 적절)

#### 콜백 이벤트 category 필드 119종 보완
- callback_events_18~26.json의 모든 이벤트에 category 누락 → 틴트 효과 미적용 버그
- 이벤트 ID·태그 기반 자동 추론: relationship/family/jobs/gambling/investment/social 분류
- 0건 누락 → 완전 보완

#### 전수 감사 항목 (신규)
- follow_up_event 대상 중 랜덤 풀 노출 가능 이벤트: 0건
- 모든 follow_up 대상 ID 존재 확인: 0건 dangling
- follow_up 순환 참조 확인: 0건
- 캐스트 effects PID 유효성: 모두 cast_stages.json 등록됨
- MetaProgression 17개 플래그 모두 설정됨 확인
- deferred_follow_up 대상 존재 + hidden 확인: 0건 이상
- 26개 엔딩 + finish_run() 1:1 완전 대응 확인 (재검증)
- _next_arc_id 98개 _seen 플래그 모두 이벤트에서 설정됨 확인
- 마일스톤 이벤트 ID 11개 모두 JSON 존재 확인

## 2026-06-17 후반23 (자율 QA 계속 — 고아 플래그·쿨다운 버그·경마 숨김 수정)

### 자율 QA 루프 계속 — 추가 버그 수정

#### 고아 플래그 heard_driver_story 수정
- callback_heard_driver_story_echo가 조건 플래그 heard_driver_story를 읽지만 소스 이벤트가 없었음
- life_events2.json에 late_taxi_driver_00 이벤트 추가 (양쪽 선택지 모두 플래그 설정)

#### 캘린더 타이밍 버그 3종 추가 수정
- callback_quit_for_better_job_check: min_turn 6→12 ("3개월")
- callback_jiyeon_took_deal_consequence: min_turn 8→12 ("3개월")
- callback_mystery_info_reported_outcome: min_turn 6→12 ("3개월")

#### 경마 follow_up 내러티브 모순 수정
- race_number_three_result: hidden=true + racetrack_visited 조건 추가
- 경마장 미방문 상태에서 무작위 풀에 노출되는 설정 모순 방지

#### 콜백 이벤트 cooldown=null 버그 119종 수정
- cooldown: null → int(null)=0 → 쿨다운 미적용으로 25개 이벤트 후 재발동 가능 버그
- callback_events_18~26.json의 플래그 조건 있는 1회성 에코 콜백 전부 cooldown:999 적용

#### 시스템 감사 추가 완료 항목
- JobSystem.gd: 승진/퇴직 로직 정상 확인, drama_office_politics 연결 확인
- NewsManager.gd: 뉴스 감정별 fear_greed 조정 로직 확인
- EndingSystem.gd: get_score() 월 기반 계산 정상
- DataRegistry.gd: EVENT_PATHS 56개 모두 존재, 미등록 파일 없음
- 26개 엔딩 모두 finish_run() 호출과 endings.json 1:1 대응 확인
- 956개 이벤트 고유 ID 확인
- follow_up_event 대상 모두 유효 확인
- 캐스트 stage 선언-사용 교차 검증 완료
- 루트 조건/설정 시스템 정상 확인
- 아이템/자산/직업 JSON 구조 검증 완료

## 2026-06-17 후반22 (자율 QA — stress+mental 이중 적용 버그 전수 수정 + 시스템 코드 감사)

### 자율 QA 루프 — 이중 정신력 패널티 버그 전수 수정

#### stress+mental 공존 효과 1201건 일괄 수정 (44개 파일)
- 구 dual-stat 설계에서 events effects에 "stress"와 "mental"이 공존하던 이벤트들
- 스트레스→정신력 통합 이후 동일 축에 중복 적용: `stress:25, mental:-20` → 실제 mental -45
- drama_events.json: 87건 (×0.65 스케일링 — 극단값 완화)
- 나머지 43개 파일: 1114건 (완전합산 → JSON 명시, 현행 동작 유지)
- 최악 사례 수정: drama_crypto_result_big choice[1] mental -60 → -39

#### 캘린더 시대 타이밍 버그 추가 수정 10종
- butterfly_events 4종: mystery_info_result_win/scam(4→12), drunk_investor_callback(5→20), resume_lie_caught(4→16)
- callback_events 6종: asked_father_health_update(6→24), coin_let_go_space(6→24), cafe_stole_walked_echo(6→24), cafe_smart_loss_rethink(8→24), cafe_learned_humility_test(8→24), health_treated_followup(4→12)

#### 상철 이중 만남 버그 수정
- sangchul_meet(랜덤풀)와 arc_sangchul_01_meet(코드 트리거) 두 경로가 독립적 플래그 사용
- 랜덤 만남 발동 시 arc_sangchul_met_seen이 미설정 → 이후 투자 가이드 아크 미발동 버그
- MainGame._next_arc_id() 진입 시 sangchul_met → arc_sangchul_met_seen 자동 동기화

#### 시스템 코드 감사 완료 항목
- RelationshipSystem.gd: modify_hidden_stat("stress") 리다이렉트 정상 확인
- MetaProgression.gd: reached_max_stress 플래그 (mental<=15) 올바르게 추적 확인
- InvestmentSystem.gd: 레버리지/마진콜 로직 검증 (65% 하락 시 청산, ~40% 손실)
- GameState.serialize(): 3개 transient 변수 SERIALIZE_EXEMPT 정상 등록 확인
- EventManager._weighted_pick(): 모든 이벤트 weight=0이면 첫 항목 반환 — 엣지케이스 인지
- 종료조건(check_game_over): 30억 엔딩분기 7종, 38세 타임리밋 8종 정상 작동 확인
- audit.sh: ERROR 0, WARNING 0, 밸런스 밴드 전부 통과

---

## 2026-06-17 후반21 (자율 QA — 캘린더 콜백 타이밍 대규모 수정 + 내러티브 품질 개선)

### 자율 QA 루프 — 캘린더 시대 타이밍 버그 전수 수정

#### 콜백 이벤트 40종 min_turn 월→주 변환 (11개 파일)
- 패턴: "N개월이 됐다" 텍스트를 가진 콜백이 min_turn=N(구 월 단위)으로 남아있던 버그
- 예시: "1년이 됐다" 콜백 → min_turn 12→48, "6개월이 됐다" → 8→24, "10개월이 됐다" → 10→40
- 대상: callback_events_2/3/4/5/6/7/8/9/11/17.json, investment_events.json
- chapter_break_turn15: min_turn 15→60 ("서울에 온 지 15개월" 문구 정합)
- arc_endgame_sixmonths: 트리거 t>=220→t>=216 ("남은 시간 24주" 문구, 240-220=20주 불일치)

#### 최종 스프린트 콜백 3종 타이밍 수정
- callback_final_sprint_aggressive/defensive/reflective_echo: min_turn 10→208
- 원본 이벤트(final_stretch_check) t=200~216에 발동, 콜백은 "두 달 후" 서술 → min_turn=208 필요

#### 내러티브 품질 수정 5건
- story_three_year: "스물셋" → "서른여섯" (3년차=36세, 구버전 주인공 나이 잔재)
- callback_wallet_job_taken_result: min_turn 6→26 ("입사 3개월째" 문구에 맞춰 12주 여유)
- chain_scammer_again: min_turn 2→12 ("3개월 전 {name}의 표정" 문구와 정합)
- hidden_011 (링크드인): has_job=true 추가 ("지금 회사보다 좋은 건지" 현재 직장 전제)
- hidden_016 (회의실): has_job=true 추가 (사무실 배경 이벤트)

#### 품질 확인 항목
- 2217개 선택지 모두 result_text 있음 (빈 값 0건)
- drama_events, shadow_events, chain_events, rare_encounter_events 전수 확인
- family 59개, comedy 14개, jobs 94개 이벤트 카테고리별 검토 완료
- audit.sh: ERROR 0, WARNING 0, 밸런스 밴드 전부 통과

---

## 2026-06-17 후반20 (자율 QA — 캘린더 잔존 버그 수정 + 전수 교차검증)

### 자율 QA 루프

#### 캘린더 잔존 버그 수정 (arc_midgame.json 3건 + MainGame.gd 1건 + life_events.json 1건)
- `arc_midpoint_reckoning`: 설명문 "2년 반이 지났다/5년의 절반/남은 시간 30개월" 제거
  - t>=30주(=7.5개월) 발동 씬에 맞지 않는 텍스트 (구 월 캘린더 시절 작성)
  - result_text "2년 반 동안 포기하지 않았다" → "지금까지 포기하지 않았다"
- `arc_career_ceiling`: MainGame.gd `job_tenure >= 12` → `>= 6`
  - t=28~38주 구간에서 12개월 재직은 수학적으로 불가능한 조건
  - 설명문 "1년이 됐다. 승진도 했다." → "반년이 됐다. 이젠 좀 자리가 잡힌 것 같다."
- `arc_late_game_push`: 설명문 "이제 1년 남짓 남았다. 마지막 구간." 제거
  - t>=45주(=11개월) 시점에 1년 남은 것이 아님 (4+년 잔여)
- `selfdev_invest_seminar`: `flag: "arc_sangchul_met_seen"` 조건 추가
  - 상철 소개 전 발동 시 "상철이 링크를 보냈다" 문구가 맥락 없이 등장하는 버그

#### 전수 교차검증 완료
- 106개 arc 이벤트 ID → JSON 존재 100% (regex 미탐지 3개는 조건부 ternary 정상 트리거)
- 26개 finish_run → 26개 endings.json 100% 커버
- 11개 milestone 이벤트 모두 JSON 존재 확인
- 카테고리별 이벤트 분포: social 156, story 146, relationship 91, jobs 94, investment 65 등
- 958개 이벤트, 빈 result_text 0건, 불가능 조건 5건 수정
- audit.sh: ERROR 0, WARNING 0, 밸런스 밴드 전부 통과

---

## 2026-06-17 후반19 (시네마틱 누아르 비주얼 오버홀 + ScreenshotQA 검증)

### 시네마틱 누아르 팔레트 전환
- AI 목업 느낌 원인 분석: SaaS 블루 #5b9cf6 × 26, 영문 대문자 헤더, 평면 배경, 균일한 카드 그리드
- 해결 방향: "시네마틱 누아르" — 앤틱 골드 강조, 래디얼 그라디언트 배경, 항상 켜진 비네팅, 한국어 헤더

#### MainGame.gd
- COL_GOLD/COL_GOLD_BRIGHT/COL_GOLD_DIM/COL_INK/COL_TEXT/COL_TEXT_DIM/COL_DANGER 상수 추가
- 배경: 평면 ColorRect → 래디얼 GradientTexture2D (#19131a→#070509)
- 다크 오버레이: Color(0.03, 0.022, 0.04, 0.74) 따뜻한 흑갈
- 제목 강조: "강남드림" → 골드+볼드 폰트
- 구분선 "│" → 골드 딤 색상
- 섹션 헤더 "PLAYER"/"LOG" → "─ 인물"/"─ 기록" 한국어+골드+볼드
- `#5b9cf6` → `#c9a227` 전수 교체 (26건)

#### StoryMode.gd / StartMenu.gd
- `#5b9cf6` → `#c9a227` 교체 (각 1건, 3건)

#### vignette.gdshader
- 시네마틱 베이스 비네트 추가: 평상시에도 상시 점등 (따뜻한 흑갈 가장자리)
- base_edge = smoothstep(0.42, 0.95, dist), alpha 0.5

### ScreenshotQA 실행 및 검증
- 14장 캡처 완료 (`/tmp/gangnamdream_qa/`)
- 전체 렌더링 정상 확인 (배경 이미지·비네팅·이벤트 텍스트·모달 UI 모두 표시됨)
- 위기 비네팅(shot 03): 의도적으로 강한 빨강+어두움 — 정상
- 도박 씬(shot 01): 누아르 분위기 정상
- 투자·인맥 모달(shot 02·05): 오버레이 정상

### 검증
- audit.sh ERROR 0 / WARNING 0 / 밸런스 밴드 전부 통과

---

## 2026-06-17 후반18 (Steam 데모 품질 벤치마크 — UI 폴리싱 11종)

### 스팀 데모 품질 분석 (Disco Elysium·Citizen Sleeper·Balatro·Hades)
- 핵심 패턴 정리: 선택 전 결과 힌트 / 한눈에 읽히는 바 / 배경 분위기 신호 / 체력 임박 경보

### MainGame.gd 개선
1. **선택지 효과 미리보기** (`_choice_effects_preview()`) — Disco Elysium 스타일
   - stress→mental 병합 로직 통일 (`_show_effects_float`와 동일한 처리)
   - 각 선택지 버튼 아래 `❤+5 🧠-3 💰+50만` 형식 표시, 스태거 페이드인
   - 버튼+미리보기를 VBoxContainer(sep=3)로 묶어 시각적 연관 명확화
2. **스킬 미니바** (`_set_stat_value()`) — 지력/사회성/투자감각/행운/외모/평판 5칸 바 표시
3. **AP 보충 애니메이션** (`_animate_ap_refill()`) — Citizen Sleeper 주사위 굴림 참고
   - 각 AP가 0.12초 간격으로 순차 점등 (⚡○○ → ⚡⚡○ → ⚡⚡⚡)
4. **카테고리 틴트 오버레이** (`_apply_category_tint()`) — Balatro 배경 전환 참고
   - 재앙/건강=빨강, 도박=골드, 투자=녹색, 사회=보라, 정치=파랑 반투명 오버레이
5. **활력 임박 펄스** (`_pulse_vital_critical()` / `_pulse_vital_warning()`) — Hades 참고
   - ≤15: 더블 플래시(0.35초), ≤30: 단일 약한 페이드
6. **목표 바 시간 압박** (`_goal_time_lbl`) — 남은 개월 수 색상 표시 (12개월=빨강, 24개월=노랑)
7. **BBCode 색상 효과 표시** — `_show_vignette()` 스탯 변화 초록/빨강/금색으로 구분
8. **Space/Enter 타이핑 스킵** — `_unhandled_input()`에 `ui_accept` 핸들러 추가

### StoryMode.gd 개선
9. **선택지 효과 미리보기** (`_choice_effect_preview()`) — MainGame과 동일한 로직
   - `_SM_STAT_EMOJI` 상수 추가, 선택지 그룹 컨테이너 구조로 변경

### 검증
- audit.sh ERROR 0 / WARNING 0 / 밸런스 밴드 전부 통과

---

## 2026-06-17 후반16 (자율 QA 루프 — ArubaGame/표시 버그 2종 수정)

### 후반15: ArubaGame health_delta 미전달 버그
- `ArubaGame.closed` signal에 `health_delta: int` 파라미터 누락
- 결과 화면에 건강 변동 표시되지만 실제 GameState에 미적용 상태였음
- DELIVERY 배달 건수×1, CARDS 선택지 health 효과 → 이제 실제 적용
- `_on_aruba_closed`: `total_health_delta = -3 + health_delta`로 기본+변동 합산

### 후반16: stress+mental 병합 덮어쓰기 표시 버그 (858개 이벤트 영향)
- `_show_effects_float`, `_show_vignette`: effects dict에서 "stress"가 "mental"보다 앞에 오면
  stress→mental 변환값이 "mental" 키 처리 시 덮어씌워지던 표시 버그
- 실제 GameState 적용은 apply_effects에서 독립 처리라 정상이었으나 화면 표시가 틀렸음
- 예: `{"stress":-3,"mental":1}` → 정신 +1 표시 (수정 후: 정신 +4)
- 두 함수 모두 "mental" 키를 누산 방식으로 변경

### 전수 검증 항목
- endings.json 26개 모두 background 커버리지 확인 (JSON 필드 또는 ending_bg_map)
- deferred_follow_up 3개 모두 유효 확인
- has_job:false 조건 완전 제거 확인
- news_templates 79개 / assets 18개 / jobs 15개 필수 필드 확인
- EventManager max_stress/min_stress 변환 로직 정상 확인
- 전 미니게임 stress/mental 라우팅 확인 (ArubaGame/HoldemClub/ScalpingGame/JobHunt/Casino)
- 챕터카드 5종 flags set/read 교차 확인
- audit.sh ERROR 0 / WARNING 0 / 밸런스 밴드 전부 통과

---

## 2026-06-17 후반10 (자율 QA 루프 — 데드코드 정리 + mental 누락 버그 + AP 비네팅 연결)

### AP 비네팅 배열 데드코드 정리 및 연결
- **`_ap_study`**: STUDY_READ/EXERCISE/MEDITATE/INVEST_VIGNETTES 4개 풀 연결 (4개 고정 씬 → 40개 다양한 씬)
- **`_ap_network`**: NETWORK_VIGNETTES 연결 (5개 단순 텍스트 → 10개 다양한 효과 씬)
- **SAVE_VIGNETTES / RESUME_VIGNETTES / INTERVIEW_VIGNETTES**: 완전 데드코드 — 삭제
- 네트워크 버튼 레이블 "사회성 +1" → "사교력+, 평판+ (정신력 소모)"로 실제 효과 반영

### _ap_startup_work / _ap_create_content mental 효과 누락 버그
- `"mental" or k == "stress" or k == "reputation"` 패턴에서 mental을 modify_hidden_stat으로 잘못 라우팅
- modify_hidden_stat은 "mental" case 없음 → 효과 무시됨
- STARTUP_VIGNETTES 10개 항목 중 4개의 mental 효과가 조용히 무시되던 것 수정

### 전수 검증
- 26개 엔딩 ID ↔ finish_run 호출 100% 매핑 확인
- 3개 deferred_follow_up 모두 유효한 참조
- opportunity 블록 구조 정상 확인
- arc_four_months_in 트리거 정상 (t>=15 + flag 조건)
- audit.sh ERROR 0 / WARNING 0 / 밴드 통과

---

## 2026-06-17 후반9 (자율 QA 루프 — 스트레스 잔존 UI 전수 수정 + 이벤트 조건 버그)

### 스트레스→정신력 UI 잔존 참조 전수 수정
1. **MetaProgression PERK_RULES** — "주거" 보너스: `stress/-1/-4` → `mental/+1/+4`
2. **`_show_vignette`** — eff dict stress → mental 병합(부호 반전): REST/SELFDEV 비네팅이 "정신력 +N"으로 올바르게 표시
3. **`_show_effects_float`** — 동일 병합 처리: 이벤트 선택 float 화면도 정신력으로 표시
4. **충격 이벤트 감지** — `effective_mental_delta = mental + (-stress)` 계산: stress:15 이상 이벤트도 critical 연출 발동
5. **MainGame UI 텍스트** — stat_map, `_stat_name`, perk stat_kr, 관계 힌트, 버튼 라벨, 로그, 건강 위기 설명
6. **ArubaGame/JobHuntMiniGame** — 결과 화면 "스트레스 %+d" → "정신력 %+d"(부호 반전)
7. **StoryMode** — 튜토리얼 팝업에서 "스트레스" 제거

### has_job:false → no_job:true 11건 (이벤트 절대 미발동 버그)
`has_job: false`는 `if bool(false)` = 항상 false → 해당 이벤트가 절대 발동 안 됨.
수정: amb_mlm_00, survival 계열 4건, rare_encounter 3건, chain 2건, butterfly 1건.

### 전수 검증
- 942개 이벤트 JSON 파싱 OK
- 108개 arc ID, 11개 milestone ID 모두 존재
- cast_stages 교차 검증 통과
- audit.sh ERROR 0 / WARNING 0 / 밴드 통과

---

## 2026-06-17 후반8 (자율 QA 루프 — 이벤트·엔딩·코드 정밀 점검)

### 자율 정적 QA — 발견 및 수정 항목
1. **result_text 빈칸 30건 일괄 수정** (10개 파일):
   amb_scenarios 4건 / amb_scenarios2-4·6 5건 / callback_events 6건 /
   scenario_cafe 9건 / scenario_cafe_callback 6건.
   CLAUDE.md 규칙: result_text 빈 문자열 금지.
2. **opportunity 이중 mental 페널티 정리** (GameState.gd):
   stress→mental 머지 잔류 — `modify_stat("mental",-3)` + `modify_stat("mental",-6)` 연속 호출
   → `modify_stat("mental",-9)` 단일 호출로 통합(동작 동일, 코드 명확화).
3. **jaehyuk_way 엔딩 배경 수정** (endings.json):
   `gangnam_apartment` → `gangnam_night`. ENDING_ART.md 명세(밤의 어두운 강남) 대로 수정.
   endings.json `background` 필드가 ending_bg_map보다 우선이어서 오배치됐던 버그.
4. **ending_bg_map 중복 항목 제거** (MainGame.gd):
   endings.json으로 이미 커버되는 stable_success·orthodox_pinnacle·crypto_ghost 항목 제거.

### 정적 QA 확인 — 이상 없음
- 26개 엔딩 모두 finish_run 호출 대응 확인
- 108개 아크 이벤트 전원 JSON 존재 확인
- 25개 portrait ID 전원 ImageRegistry 등록 확인
- 27개 background ID(이벤트용) 전원 ImageRegistry 등록 확인
- deferred_follow_up 체인 942개 이벤트 전원 유효
- 챕터 카드 5종(33~37) 플래그 정상 설정 확인
- 시리얼라이즈 완전성 — 3개 transient 변수 SERIALIZE_EXEMPT 정상 처리

---

## 2026-06-17 후반7 (스크린샷 QA 자동화 + 엔딩 아트 전수 점검)

### 실제 렌더러 스크린샷 QA (`tools/ScreenshotQA.tscn`)
xvfb+x11+opengl3로 MainGame을 실제 렌더링해 PNG 캡처(헤드리스 더미 렌더러는 빈 텍스처).
이벤트/투자모달+라인차트/위기비네팅/AP대시보드/인맥/홀덤/경마/카지노/엔딩 13종 캡처.
`add_child.call_deferred` + 전환 트윈 40프레임 차단으로 StoryMode 이탈 방지.

### QA가 잡은 실버그
- 시작안내·튜토리얼·주거안내의 "스트레스" 별도 기제 문구 3곳 → 정신력 통합 서술
- 비네팅 빨강 가장자리가 stress 제거로 사망 → 신체 위기(건강≤35/정신력≤20)로 재점등
- **gangnam_dream 승리 엔딩에 아버지 임종 CG** 오배치 → 제거

### 엔딩 배경/CG 전수 점검 (`docs/ENDING_ART.md`)
26개 엔딩 배경 적합성 점검. 펜트하우스 모순 2건(stable_success/orthodox_pinnacle),
코인중독 배경 부정확 1건(crypto_ghost) 수정. **애매한 건 억지 배치 대신 매니페스트에
"신규 에셋 필요"로 표시** — 향후 이미지/오디오 제작 기준 문서화.

## 2026-06-17 후반6 (스트레스→정신력 통합 + 고닷 활용 + 컴파일 수정)

### 스트레스 → 정신력 단일 스탯 통합
이중 정신 스탯(`stress` 높을수록 나쁨 / `mental` 높을수록 좋음)을 `mental` 하나로 통합. `stress` 변수 완전 제거.
적용 계층 리다이렉트 방식으로 JSON 600여 개 이벤트는 미수정 — 데이터의 "stress" 키는 그대로 두고, 적용·조건·가중치 코드에서 전부 mental로 변환.
- `GameState`: `var stress` 선언·serialize·load·DIFFICULTY_DATA(start_stress/pressure_stress) 제거. `modify_hidden_stat("stress",X)` → `modify_stat("mental",-X)`
- `EventManager`: `max_stress:N`→`mental<(100-N)`, `min_stress:N`→`mental>(100-N)`, 가중치 `stress>70`→`mental<30`
- `BGMPlayer` 위기 트리거 `mental<=25` / `InvestmentSystem` 판단페널티 `(70-mental)/250` / `RelationshipSystem` 신뢰감속 `mental<25`
- `MainGame._update_vignette` stress_norm 0.0 고정 (셰이더 불변)
- 밸런스: stress 양수622(+3582)·음수594(-2514) → mental 풀에 순 -1068 추가. 밴드 전부 통과(무직100%/직장0%/베팅14.8%)

### 고닷 컴파일 에러 4종 수정 (그동안 Mac 경로라 audit에서 스킵돼 미검출)
`tier` 중복 선언 제거, `phase := turn%4` → `: int =`, 헬퍼 4종(`_button`/`_small_button`/`_label`/`_wrap_label`) 반환 타입 명시 → `:=` 호출부 일괄 해소. 전체 컴파일 깨끗 확인.

### 레버리지 UI 연결 + 스토리 게이팅 + 내러티브 3종 (이전 세션 작업 정리)
레버리지 투자 버튼 연결(투자감각 30), 투자 게이팅(arc_invest_guidance_seen), 도박 조기진입 차단(gambling_006+arc_sangchul_met_seen), holdem 2·racetrack 1 이벤트.

## 2026-06-16 후반5 (도박 잠금 + 데모 이벤트 + 초상화)

### StoryMode 초상화 액자 프레임 제거
골드 테두리·어두운 매트·그림자 제거. 배경 위에 초상화 직접 표시.

### 도박 이벤트 조기 노출 버그 수정
`race_first_visit`(조건 없음 → hidden:true), `holdem_first_visit`(조건 없음 → entered_network 필요). 게임 시작 직후 경마장·홀덤 버튼이 나타나던 버그 해결.

### 데모 전용 아크 이벤트 — "4개월째" (t=15)
t=10(상철) ~ t=19(재혁) 사이 비어있던 구간에 한강 다리 한밤 씬 삽입. 정석/비정석/침묵 세 선택지로 캐릭터 성향 강화. `demo_resolved`/`demo_seeking_shortcut` 플래그.

## 2026-06-16 후반4 (튜토리얼 정비)

### 튜토리얼 캘린더 오류 수정
TutorialOverlay main_game 슬라이드에 잔류한 "1턴=1달" 모델 오류 전면 교체. "매주(= 1턴)", "38세(240턴)", "다음 주 ▶"로 실제 캘린더 반영.

### 더블 팝업 방지
TutorialOverlay → `_show_tutorial()` 모달 연속 표시 문제. `TutorialOverlay._seen` 체크로 이미 슬라이드를 본 경우 모달 생략.

### 선택 철학 슬라이드 추가
TutorialOverlay 4번째 슬라이드: "정석(안정) vs 비정석(속도), 둘 다 강남 가능 둘 다 망함" — 게임 핵심 철학을 첫 화면에서 전달.

### 죽은 코드 제거
`_show_tutorial_intro()` (호출처 없음, "AP 3개" 오류) 49줄 제거.

## 2026-06-16 후반3 (종합 버그 수정 — 데모 검수 준비)

### 캘린더 혼용 버그 6종
BGMPlayer(late_tense 조건·hustle 판정) / MetaProgression(loner_title) / MainGame(카페 콜백 무한루프·arc_after_scam 가드·_next_milestone_id 8개 비교·개월 표시) / EndingSystem(점수 계산) — 전부 월 단위 `me` 기반으로 수정.

### 이벤트 min_turn/max_turn ×4 일괄 변환 (55건)
캘린더 마이그레이션(월→주) 이후 JSON 이벤트 조건 미반영. life_events·relationship_events·callback_events·hidden·investment·amb_scenarios7 12개 파일, 55개 이벤트. "반환점"·"마지막 겨울"·father arc 타이밍 정상화.

### 엔딩 시스템 완성도
BGMPlayer good 목록 9종 추가 / ending_bg_map 16종 추가 / _ending_run_summary 10종 / _ending_cast_epilogue good 분류 10종.

### drama_events 플래그 버그 (CRITICAL)
`startup_exit`·`political_winner` 엔딩 달성 불가 버그 수정. `effects.flag` → `flags[]` 이동 (5건).

### JobSystem 승진 phantom salary
`effective_salary` 필드 도입으로 승진 후 퇴직 시 정확한 월급 차감.

## 2026-06-16 후반2 (SimRun 수정 + 챕터1 루트 이벤트 5종 추가)

### SimRun.gd 루프 상한
- `turn <= 64` → `244`, guard `300` → `260`. 척추 증명이 실제 5년(240주)을 커버하도록.

### 챕터1 루트·테마별 반응 이벤트 5종
arc_events.json에 추가, _next_arc_id() t8 블록에 트리거 연결:
- `arc_ch1_invest_first_chart` (route_invest): HTS 첫 날
- `arc_ch1_career_first_spec` (route_career): 자소서 첫 줄 (선택지 3개)
- `arc_ch1_startup_first_idea` (route_startup): 아이디어 노트
- `arc_ch1_theme_network_first` (theme_network_run): 재테크 스터디 첫 모임
- `arc_ch1_theme_invest_deep` (theme_invest_run): 차트 3시간
이로써 route_invest/career/startup + theme_network_run/theme_invest_run 플래그가 실제 이벤트 조건으로 읽힘 (고아 플래그에서 활성 조건으로 전환).

## 2026-06-16 후반 (AP 정리 + 내레이션 버그 수정)

### AP 기본값 정리
- `GameState.gd` `var action_points = 3` → 2. `start_new_game()`이 항상 2로 덮어쓰므로 선언도 일치시킴.

### 내레이션·마감힌트 turn→개월 버그 수정 (MainGame.gd)
- 배경: 캘린더가 turn=주(240턴=5년) 모델인데, `_month_narration()`은 turn을 개월로 취급(구 60턴 모델 잔재)
- 수정: `var me = (age-33)*12 + month` 도입 → `t==12` 등 모든 비교를 `me` 기반으로 교체
- 마감 힌트: `60 - turn + 1` → `(38 - age)*12 - month + 1`
- CLAUDE.md "60턴" → "60개월 = 240턴(주)" 수정
- 오딧 ERROR 0 / WARNING 0 유지

## 2026-06-16 (챕터 카드 + 챕터1 반응형 밀도 강화 + 고아 플래그 콜백)

### 세션 목표
메인 브랜치 머지 후 챕터 구조 추가 + Chapter 1 이벤트의 정적 고정 문제 해결 + 편의점 알바 개연성 문제 수정 + 고아 플래그 콜백 연결

### 챕터 카드 (chapter_cards.json, DataRegistry.gd)
- 챕터1(시작)~챕터5(강남) 타이틀 카드 5종 신규 작성
- 배신 → 균열, 입성 또는 실패 → 강남 (스포일러 방지)
- 프롤로그 분리: prologue_done → chapter_card_33 (챕터1 시작) → 챕터 진행
- 연도별 챕터 경계: 34/35/36/37세에 각 챕터 카드 자동 트리거

### t9 반응형 씬 (arc_events.json)
- `arc_first_expense_shock` 제거 → 자산 기반 3분기 분기
  - `arc_money_check_low` (순자산 < 100만): 통장 충격 씬
  - `arc_money_check_mid` (100만~3천만): 첫 성장 씬
  - `arc_money_check_high` (3천만+): 자만 경고 씬
- `arc_gosiwon_wall` (t11, 고시원 조건): 얇은 벽 새벽 3시

### 알바/편의점 정합성 수정
- `arc_intro_02_dad_call`: "편의점 야간 알바" 배경 → "고시원 방 새벽 3시" (일반화)
- `arc_jiyeon_02_store`: 플레이어=점원 설정 → 플레이어=손님 (편의점 앞에서 나오는 씬)
- `rare_celeb_convenience`, `rare_drunk_wisdom`, `rare_night_alva_find`, `chain_envelope_owner_return`, `callback_heard_drunk_wisdom_echo`: `has_job: false` 버그 → `job_id: job_01` 조건으로 교체
- `relationship_events.json`의 `daeun_meet` 이벤트 삭제 (플레이어=점원 고정 서사 모순)
- `arc_daeun_01_meet` 선택지에 `daeun_met`, `daeun_first_kind` 플래그 추가

### `instant_legend` 히든 엔딩
- GameState.gd: 33세(age<=33) + 자산 30억 도달 시 `finish_run("instant_legend")` 분기
- endings.json: 히든 엔딩 "신화" 추가 (grade: "?", 50만원 → 3개월 → 30억 서사)
- MainGame.gd: grade_colors/grade_emojis에 "?" = 보라/👁 추가, `_ending_run_summary()`에 `instant_legend` 케이스 추가

### Chapter 1 고아 플래그 콜백 (callback_events_27.json)
- 7개 신규 콜백 이벤트 (t13~24 내에서 발동):
  - `callback_parttime_survived` (considered_parttime): 편의점 공고 앞에서
  - `callback_budget_check_in` (budget_planned): 예산표 재점검
  - `callback_mid_goal_echo` (set_monthly_goal): 그때 정한 목표 돌아보기
  - `callback_quiet_money_patience` (kept_quiet_money): 아무도 모른다
  - `callback_early_greed_humbled` (early_greed): 자만의 댓가
  - `callback_gosiwon_wall_echo` (knocked_on_wall): 그 방에 짐이 없었다
  - `callback_stayed_grounded_echo` (stayed_grounded): 운이었다

### 감사
- 전 커밋 후 `daeun_met/daeun_first_kind` 플래그 고아 에러 → `arc_daeun_01_meet` 패치로 해결
- `has_job: false` 조건 버그 발견 및 전체 수정 (`if bool(false)`는 항상 false)
- `EventManager.gd`: `job_id` 조건 키 신규 추가

## 2026-06-16 (arc_midgame 대규모 확장 — 감정 밀도 강화)

### 세션 목표
전 세션에 확인된 문제: 미니게임 제거 후 중반부(턴 15~50) 감정 장면이 너무 희박함 → 29개 arc 이벤트로 채움

### 신규 arc 이벤트 (arc_midgame.json: 10개 → 29개)
4개 배치(커밋)로 나눠서 추가:

**배치 1 (아크 트리거 4종)**
- `arc_social_comparison` (t28~35): 동창 조우, 잘 나가는 친구 앞에서
- `arc_first_real_win` (자산 5천만+): 처음으로 "돈을 모았다"는 감각
- `arc_hyunsu_new_path` (t42~50, 불합격 후): 현수가 고시원을 떠난다
- `arc_career_ceiling` (t28~38, 재직 12개월+): 월급의 구조적 한계 자각

**배치 2 (감정 장면 3종)**
- `arc_hyunsu_drift` (t36~41): 불합격 후 현수가 조용히 달라져간다
- `arc_goal_vertigo` (t32~42): 반환점 이후 30억이 갑자기 낯선 숫자가 되는 순간
- `arc_housing_new_life`: 고시원 탈출 직후 새 집 첫날 밤

**배치 3 (1억 고독·사표·아버지 약)**
- `arc_money_loneliness` (자산 1억+): 누구에게도 말할 수 없는 1억
- `arc_quit_job`: 자발적 퇴사 — 팀장 앞에서의 마지막 장면 (just_quit_job 플래그 연동)
- `arc_father_medication` (t22~32): 아버지 혈압약 문자 — 조용한 신호

**배치 4 (후반 이정표 3종)**
- `arc_almost_there` (자산 10억+): 10억 돌파 후 20억이 더 무겁게 느껴지는 역설
- `arc_daeun_trace` (t43~50, 보낸 경우): 편의점에서 다은이 있던 자리를 본다
- `arc_final_stretch` (자산 20억+, t47+): 강남대로에서 5년 전 그 아파트를 다시 올려다본다

**배치 5 (관계 심화·사기 후독백·임상철 인간화)**
- `arc_daeun_money_gap` (t28~35, 함께): 다은에게 자산을 숨길지 말할지
- `arc_sangchul_human` (t30~42): 임상철이 인천 출신임을 처음 말한 한우집 밥자리
- `arc_after_scam`: 재혁 사기 직후 다음 날 멍한 내적 독백

**배치 6 (루틴·취업초기·강남집값)**
- `arc_first_job_week`: 취직 첫 주 — 출근 루틴과 회의감
- `arc_night_routine` (t12~22, 고시원): 현수는 인강 / 나는 차트 — 같은 밤 다른 방향
- `arc_gangnam_real_estate` (자산 25억+, t50+): 부동산 앱에서 강남 아파트를 처음 진지하게 본다

### 기타
- `JobSystem.gd`: `quit_job(voluntary=true)` 시 `just_quit_job` 플래그 자동 세트
- 모든 배치 후 `./tools/audit.sh` — ERROR 0 / WARNING 0 확인 후 커밋

## 2026-06-16 (그림자 이벤트 시스템 — 테마/메카닉 괴리 해소)

### 핵심 문제 해결: 선택의 장기 파장
- **근본 진단**: 선택이 즉각 결과로 끝나기 때문에 "불평등 테마를 플레이한다"가 아니라 "숫자를 최적화한다"가 게임 경험으로 됨
- **해법**: deferred_events 시스템 — 선택 후 N턴이 지나 잊을 때쯤 과거 선택이 새 이벤트로 돌아옴

### 구현 내용
- **GameState.gd**: `deferred_events: Array` 변수 선언 + new_run 초기화 + `add_deferred_event(id, delay)` / `pop_ready_deferred_events()` 헬퍼
- **EventManager.gd**: 선택지 JSON에 `deferred_follow_up` + `deferred_delay` 키 지원 추가
- **MainGame.gd** `_next_arc_id()`: 매 턴 시작 시 `pop_ready_deferred_events()` 호출 — 발동된 그림자가 해당 턴 arc 슬롯을 차지
- **shadow_events.json**: 그림자 이벤트 6개 (수금 전화, 소문, 예전 약속 — 각각 4~7턴 후 콜백)
- **tools/audit.py**: `deferred_follow_up` / `deferred_delay` CHOICE_KEYS 화이트리스트 + 체인 끊김 검사 추가

### 그림자 이벤트 목록
- `shadow_loan_collector` → `shadow_loan_answer` (4턴 후): 출처 모를 수금 전화, 내가 맺은 관계의 이면
- `shadow_snitch_rumor` → `shadow_snitch_found` (5턴 후): 소문의 출처 추적 — 아는 사람이었음
- `shadow_old_promise` → `shadow_promise_again` (7턴 후): 창업 약속, 잊을 때쯤 다시 온다

### 감사 결과
- ERROR 0 / WARNING 0 / 밸런스 밴드 전부 통과

## 2026-06-15 (데모 점수 올리기 — CryptoGame + 튜토리얼 개선)

### 코인 단타 미니게임 (CryptoGame.gd 신규)
- 3라운드 코인 롱/숏 예측 게임
- 5캔들 흐름 표시, 12초 타이머, 롱/숏/패스 3선택
- 투자감각 20→추세 힌트, 40→강도, 60→직감 표시
- 해금 조건: investment_skill >= 10 (시작값 12이므로 초반부터 접근 가능)
- MainGame 연동: crypto_game 오버레이, _open_crypto/_on_crypto_closed

### 튜토리얼 텍스트 수정
- "📚 정석 루트 / 📈 비정석 루트" 라벨 제거 (유저 요청: 노출 금지)
- "💼 안정을 쌓으면 / 📈 속도를 쌓으면" 으로 대체 — 성향을 가르치되 이름 붙이지 않음

## 2026-06-15 (30억 경로 명확화 + 아크 흐름 정비)

### 30억 경로 가이드
- `arc_invest_guidance` 이벤트 추가 (arc_events.json): 12턴 이후 임상철이 "월급만으론 불가능, 투자해야 한다"는 방향 명시
- `_next_arc_id()` 트리거 추가: t>=12 + sangchul_met + !invest_guidance_seen
- `arc_sangchul_03_network` 조건 완화: 500만 → 100만원 (초반 진행 막힘 해소)

### 아크 흐름 정비
- 아크 패널 힌트에 턴 타이밍 표시 (임상철 "17개월차 이후", 재혁 "19개월차 이후", 지연 "17개월차+" 등)
- 임상철 아크 단계에 "투자 조언" 항목 추가

### 골 바 마일스톤
- `_refresh_goal_bar()`: 현재 자산 구간에 따라 "→ 1억 / 5억 / 10억 / 20억 / 30억!" 표시

## 2026-06-15 (AP 전면 게임화 완료 — LifeSkillsMiniGame)

### 절약·인맥·자기계발 미니게임
- `scenes/LifeSkillsMiniGame.gd` 신규 작성 (3모드 통합)
  - `Mode.BUDGET` (절약): 6개 지출 항목 토글 퍼즐, 목표 15만원, 항목별 스탯 패널티 즉시 적용
    - 식비절약(-건강), 카페·술금지(+스트레스), 문화생활취소(-정신) 등 트레이드오프
    - 200k↑→quality3, 150k↑→2, 80k↑→1, else→0
  - `Mode.NETWORK` (인맥): 5인 NPC 풀에서 3인 랜덤 선택, 10초 타이머 순차 대화
    - 성격 유형(열정형/분석형/경쟁형/친화형)별 적절한 대응으로 score 차등
    - 결과: 사회성+1~3, 평판+1 (quality3)
  - `Mode.STUDY` (자기계발): 4주제(독서/운동/명상/재테크) 선택 → 각 3문 8초 퀴즈
    - quality에 따라 기본 스탯 획득량 0.3x~1.5x 배율 적용
- `MainGame.gd` 통합: `_ap_save_money/network/study` 모두 미니게임 호출로 교체
- `_on_life_skills_closed`: 모드·quality·extra_money 분기 처리

## 2026-06-15 (구직 미니게임 통합 — JobHuntMiniGame)

### 자소서·면접 AP 사용처 게임화
- `scenes/JobHuntMiniGame.gd` 신규 작성 (497줄)
  - `Mode.RESUME`: 4문항 선택지 채점 (3/1/0점, 타이머 없음)
  - `Mode.INTERVIEW`: 5문항 압박 타이머 (10s, 깜짝 문항 5s), 타임아웃 시 스트레스 +2 자동 진행
  - quality 0-3 산정: score/max 비율 0.85+→3(우수), 0.6+→2(양호), 0.35+→1(무난), else→0(재작성필요)
  - 타이머 바 색상 실시간 변환: 녹색>60%, 황색30-60%, 적색<30%
- `MainGame.gd` 통합
  - `job_hunt_game` var 선언 + `_ready()`에서 인스턴스화 & 시그널 연결
  - `_ap_write_resume()`·`_ap_interview_prep()`: 빈네트 랜덤 → `job_hunt_game.open(mode)` 호출로 교체
  - `_on_job_hunt_closed(stress_delta, quality)`: 이력서/면접 분기 후 quality 차등 스탯 적용
    - 우수(3): 지력+2 or 사회성+2, 플래그 세팅
    - 양호(2): 지력+1 or 사회성+1, 플래그 세팅
    - 무난(1): 운+1 or 보조 없음
    - 실패(0): 스트레스 추가 +1

## 2026-06-15 (생존게임 패키지 + 알바 미니게임 v2)

### 생존게임 첫 6개월
- 정착 지원금 단축: `month <= 3` → `month <= 1` (2개월차부터 즉시 생존 압박)
- `arc_job_first_rejection`: t>=8 무직 시 불합격 메일 확정 등장, 이력서 다듬기 선택 시 `resume_polished` 획득
- `arc_rescue_job` 안전망 트리거 t>=5 → t>=10 (불합격 경험 후 자연스러운 수순)
- 생존 이벤트 4종: 월세 납부일 공포 / 삼각김밥 두 개 / 채용 공고 밤샘 / 취업한 친구 인스타

### 알바 미니게임 v2 — 직종별 전용 게임플레이
- job_01(편의점): 바코드 스캔 타이밍 게임 (ScanBarDraw 내부 클래스 커스텀 렌더링)
  - 바늘 왕복 + 아이템마다 속도 가속 + 퍼펙트/굿/미스 즉각 피드백
- job_02(배달): 루트 최적화 퍼즐 (6주문, 총 140분 > 제한 120분 → 선택 전략 필요)
  - 실시간 소요 시간 + 예상 수입 업데이트, 초과 주문 자동 비활성화
- 그 외: 상황 카드 모드 유지

## 2026-06-15 (머지 + 정선 카지노 확정 + 캐릭터 기반 해금)

### origin/main 머지 충돌 해소 (6개 파일)
- `CLAUDE.md`: 두 브랜치 상태 블록 통합
- `autoloads/MetaProgression.gd`: "정선 카지노 상주자" 칭호 채택
- `content/events/life_events.json`: `gambling_tempted` 플래그 체인 유지
- `scenes/BaccaratTable.gd` / `scenes/BlackjackTable.gd`: "정선 카지노" 주석 채택
- `scenes/MainGame.gd`: 7곳 충돌 — 주 단위 guard 유지 + 정선 카지노 허브 채택

### 정선 카지노 명칭 통일
- 카지노 명칭 확정: **정선 카지노** (상표 아님, 지명 서술어)
- `arc_sangchul_casino_invite` 텍스트: "강원도 카지노" → "정선 카지노"
- 카지노 버튼 조건: `casino_club_introduced` 플래그 (상철 아크 완료 후 해금)
- 메인 브랜치 JeongseonCasino 허브 채택 (바카라·블랙잭·슬롯·룰렛·빅휠 단일 진입)

## 2026-06-15 (REVIEW_ANALYSIS A항목 완료)

### A-1 관계 감각 강화
- `_ap_contact_person()` 후 모달 닫고 스토리 영역에 인물 리액션 타이핑 (`_show_contact_reaction()`)
- 기존 `_contact_flavor()`의 인물별 대사가 이제 이벤트 패널에 확인 버튼과 함께 표시됨

### A-2 AP 즉각 피드백
- 월말 결산에 AP 사용 패턴 코멘트 삽입 (`_get_ap_pattern_comment()`)
- 도박 집중/자기계발 집중/혼합 등 8가지 분기
- 도박 미니게임 close handler에 `turn_action_log` 항목 추가 (경마장/홀덤/정선카지노/바카라/블랙잭)

### A-3 도박 경고 연출 강화
- addiction 50 돌파 → 붉은 화면 플래시 (1회)
- addiction 70 돌파 → "당신은 지금 문제가 생기고 있습니다" 강제 팝업
- addiction 90 이상 → 월말 결산 상단 붉은 경고 배너 (매달)

### A-5 투자 자산 차별화 표시
- `content/assets.json` 18종 자산에 특성 태그 3개씩 추가
- 투자 패널 자산 헤더 하단에 `[저변동] [분기배당] [한국 대형주]` 형식으로 표시

### A-4 금융 용어 툴팁
- 은행 패널 + 투자 패널에 "📖 용어" 버튼 추가 (`_open_glossary()`)
- 카지노 허브 하단에 "📖 용어 설명" 버튼 추가 (`_show_casino_glossary()`)
- 은행 4개 용어 (신용등급/변동금리/레버리지/마진콜)
- 투자 7개 용어 (포트폴리오/배당률/레버리지ETF/마진콜/공포탐욕/하우스엣지/RTP)
- 카지노 7개 용어 (하우스엣지/RTP/배당률/내추럴/커미션/더블다운/마틴게일)

### A-6 월말 서사 로그 강화
- 월말 결산에 현재 상태 기반 서사 1줄 (`_get_month_narrative()`)
- 무직 장기/첫 출근/정신력 위험/중독/자산 마일스톤 등 조건별 내레이션
## 2026-06-15 (정선 카지노 카지노/헬스장 배경 추가)

### 서울 랜드마크 배경
- `assets/backgrounds/hangang_riverside_walk.png`를 새로 추가했다.
  - 용도: 한강 산책, 휴식, 러닝, 한지연 한강 고백, 최종 회고 콜백 등 서울 랜드마크가 장면 의미인 이벤트.
  - 사양: 1280x800 PNG, 한강 산책로·강물·다리·스카이라인·벤치·가로등이 보이는 주인공 눈높이 구도.
  - 반복 배경 규칙에 맞춰 주연/조연처럼 읽히는 전경 인물, 읽히는 간판, 로고, 워터마크를 배제했다.
- `assets/backgrounds/namsan_tower_view.png`를 새로 추가했다.
  - 용도: 남산/서울타워를 직접 말하는 향후 서울 랜드마크·야경·성공/고독 회고 이벤트.
  - 사양: 1280x800 PNG, 남산타워가 명확히 보이는 야간 전망 산책로 구도.
- `ImageRegistry.BACKGROUNDS["hangang_riverside"]` / `["namsan_tower"]`를 등록했다.
- `ImageRegistry.infer_background_id()`와 `tools/background_semantic_audit.py`에 한강/남산 키워드를 추가했다.
  - 한강 키워드는 social/exercise/gym보다 먼저 처리해, "한강을 달렸다"가 헬스장으로 가는 문제를 막았다.
  - 남산/서울타워 키워드는 향후 이벤트 추가 시 일반 거리나 강남 야경으로 빠지지 않게 했다.
- `MainGame._get_bg_for_vignette()`도 한강/남산 키워드를 운동·명상·휴식 분기보다 먼저 본다.
- `hangang_chicken`, `jiyeon_confession`, `callback_final_sprint_reflective_call`에 `background: "hangang_riverside"`와 `hangang` 태그를 명시했다.

### 이미지 에셋
- `assets/backgrounds/casino_interior.png`를 새로 추가했다.
  - 용도: 블랙잭/바카라 공통 카지노 테이블 배경.
  - 사양: 1280x800 PNG, 실제 정선 카지노 레퍼런스를 반영한 밝은 공용 카지노 플로어. 스테인드글라스풍 천장, 검은 기둥, 빨강/노랑 소용돌이 카펫, 슬롯머신 열, 초록 테이블 게임을 포함한다.
  - 저작권/상표 리스크를 피하기 위해 보도사진을 그대로 복제하지 않고, 전경 손 없음, 명확한 얼굴 없음, 읽히는 로고/텍스트/워터마크 없음 기준을 유지했다.
  - 반복 배경 규칙에 맞춰 주연/조연처럼 읽히는 인물은 넣지 않고, 먼 배경의 익명 실루엣만 허용했다.
- `assets/backgrounds/jeongseon_casino_exterior.png`를 새로 추가했다.
  - 용도: 정선 카지노 도착/퇴장/귀가 버스/재입장 충동/중독 자각 이벤트용 산속 리조트 외관 배경.
  - 사양: 1280x800 PNG, 항공뷰가 아니라 주인공이 차량 하차 지점/진입로에서 입구를 바라보는 눈높이 구도. 정선 카지노 레퍼런스의 산속 리조트·청록색 지붕·호텔 타워·입구 캐노피·순환도로 인상을 반영하되, 실제 사진/워터마크/상표/읽히는 간판은 복제하지 않는다.
- `assets/backgrounds/jeongseon_casino_entrance.png`를 새로 추가했다.
  - 용도: 정선 카지노 카지노 입구/로비/출입 게이트/서비스 데스크/재입장 충동 이벤트용 문턱 배경.
  - 사양: 1280x800 PNG, 일반 `CASINO` 사인만 사용하고 실제 로고·브랜드·보도사진 구도·읽히는 안내문은 배제했다.
- `assets/backgrounds/gym_interior.png`를 새로 추가했다.
  - 용도: 운동/헬스장/피트니스 이벤트 전용 배경.
  - 사양: 1280x800 PNG, 러닝머신·스쿼트랙·덤벨랙·케이블 머신이 명확히 보이는 한국 동네 헬스장.
  - 병원/클리닉으로 오인될 침대·의료장비·의사 이미지를 배제했다.
- `ImageRegistry.BACKGROUNDS["casino"]`를 등록해 이후 Claude/Codex가 카지노 이벤트/씬에서 경로 하드코딩 없이 호출할 수 있게 했다.
- `ImageRegistry.BACKGROUNDS["jeongseon_casino_exterior"]`를 등록하고, 정선 카지노 문구/태그가 있는 이벤트를 외관 배경으로 우선 추론하게 했다.
- `ImageRegistry.BACKGROUNDS["jeongseon_casino_entrance"]`를 등록하고, 정선 카지노 입구/로비/입장/재입장 문구는 입구 배경으로 우선 추론하게 했다.
- `jeongseon_big_loss_bus`는 외관, `jeongseon_big_win_urge`와 `jeongseon_addiction_notice`는 입구 배경으로 명시했다.
- `ImageRegistry.BACKGROUNDS["gym"]` / `["exercise"]`를 기존 옥상 임시 배경에서 `gym_interior.png`로 교체했다.
- `JeongseonCasino.gd` 허브 첫 화면에도 `casino_interior.png`를 깔아, 개별 테이블 진입 전부터 실제 정선 카지노에 가까운 장소감이 보이게 했다.
- 블랙잭/바카라 배경 오버레이를 조정해 새 카지노 배경이 지나치게 어둡게 죽지 않도록 했다.
- `BlackjackTable.gd`, `BaccaratTable.gd`의 카드 위젯을 고급화했다.
  - 기존 40x56 텍스트 라벨 카드에서 54x76 카드 패널로 확대했다.
  - 앞면은 코너 랭크/무늬, 중앙 대형 무늬, 미세 그림자/라운딩을 갖춘 카드로 렌더링한다.
  - 뒷면은 이미 교체해둔 `assets/ui/card_back.png` 텍스처를 직접 사용한다.
- `assets/ui/card_back.png`, `assets/ui/poker_chip_icon.png`를 좌표 기반으로 다시 작성했다.
  - 카드 뒷면은 레퍼런스처럼 중앙 사각 패턴과 중심 메달리온이 한 축에 놓이도록 재정렬했다.
  - 포커 칩은 중앙 클럽 심볼을 제거하고, 빈 중앙 원·동심원 링·외곽 흰색 인레이·안쪽 점선 디테일을 같은 중심점에서 그리도록 수정했다.

### 정합성
- 블랙잭/바카라 씬이 이미 직접 참조하던 `res://assets/backgrounds/casino_interior.png`의 빈 파일 문제를 해소했다.
- 정선 카지노 사후 이벤트가 일반 도박/투자 폰 배경으로 빠질 수 있던 문제를 외관/입구 배경 명시 연결로 차단했다.
- 정선 카지노 허브가 평면 패널처럼 보이던 문제를 줄이고, Claude의 튜토리얼/미니게임 연출 패스와 Codex의 배경 에셋 패스를 통합했다.
- 헬스장/운동 지문이 병원이나 일반 휴식 배경으로 보이는 문제를 줄였다.
- 카드 앞면은 이미지 생성 대신 코드 렌더링으로 유지해 랭크/무늬 오표기 리스크를 줄였다.
- 카드/칩 UI는 생성형 이미지가 아니라 기하 좌표 기반 래스터로 관리해 중앙축과 인레이 배치 흔들림을 방지한다.
- `assets/ASSET_INDEX.md`, `docs/ROADMAP.md`, `docs/RELEASE_NOTES.md`에 반영했다.

---

## 2026-06-14 (정선 카지노 리네이밍 + GAME_ANALYSIS.md)

### 정선 카지노 리네이밍
- 구 카지노 허브 파일 → `JeongseonCasino.gd` 파일명 변경
- 코드 식별자: 구 카지노 식별자 → `jeongseon_casino`, 구 open/closed 콜백 → `_open_jeongseon_casino` / `_on_jeongseon_casino_closed`
- 플래그 전체: `hangang_session_loss/win/first_visit/quit_vow/self_aware` → `jeongseon_*`
- 이벤트 ID: `hangang_big_loss_bus/big_win_urge/addiction_notice` → `jeongseon_big_loss_bus/big_win_urge/addiction_notice`
- 표시 텍스트: MainGame, TutorialOverlay, MetaProgression, life_events.json, EventData.gd 모두 "정선 카지노"로 통일
- `hangang_chicken` (한강 치맥 이벤트)은 카지노와 무관 — 유지

### GAME_ANALYSIS.md 신규 추가
- 14개 카테고리 전체 게임 설계 분석 문서 (`docs/GAME_ANALYSIS.md`)
- audit ERROR 0 / WARNING 0 확인 후 커밋·푸시 완료

---

## 2026-06-14 (스탯 정리 + 정선 카지노 사후 이벤트)

### 스탯 UI 정리
- `stress` (스트레스)를 플레이어 UI에서 완전히 제거. 내부 메커니즘은 유지.
  - 헤더 바이탈 HUD: 건강/정신 2개 바로 축소
  - 스탯 패널: stress 행 제거
  - 플로팅 텍스트: stress 효과 숨김 (_STAT_KR에서 제거)
  - 어드바이스/내레이션: 스트레스 임계값 기반 → 정신력 임계값 기반으로 전환
  - 내부적으로 stress는 계속 누적되고 매달 정신력에 영향을 줌 (hidden mechanic)

### 정선 카지노 사후 이벤트
- `JeongseonCasino.open()`: 첫 방문 환영 메시지 + `jeongseon_first_visit` 플래그
  세션 시작 시 임시 플래그 초기화
- `JeongseonCasino._close()`: 손익 기준 플래그 설정 (손실 50만↑ / 수익 100만↑)
  방문마다 addiction_tendency +3
- `life_events.json`: 정선 카지노 사후 이벤트 3종 추가
  - `jeongseon_big_loss_bus` — 귀가 버스 성찰
  - `jeongseon_big_win_urge` — 재방문 충동
  - `jeongseon_addiction_notice` — 중독 자각 (min_addiction 60)

## 2026-06-14 (정선 카지노 카지노 5종 완성)

### 신규 수학 모델 (systems/)
- `SlotMachine.gd`: 3릴 슬롯 — 5심볼, 32칸 릴스트립, 이론 RTP 90%, 777=200x 잭팟
- `Roulette.gd`: 유럽식 룰렛 — 0~36, 10가지 베팅 타입, HE 2.703%
- `BigWheel.gd`: 빅식스 휠 — 54칸, 6구역, 조커 45:1, 구역별 HE 11~22%

### 신규 UI 씬 (scenes/)
- `SlotMachineGame.gd`: 3릴 애니메이션(0.08s 셔플→1.5s 정지), 베팅/히스토리/잔액, 잭팟 플래시
- `RouletteTable.gd`: 번호 선택기, 스핀 애니메이션(숫자 빠른 전환→정지), 컬러 원형 히스토리
- `BigWheelGame.gd`: 54칸 휠 `_draw()` 렌더링, ease-out 회전 애니메이션, 포인터 삼각형
- `JeongseonCasino.gd`: 5게임 허브 — 바카라·블랙잭·슬롯·룰렛·빅휠 카드 레이아웃, 하위게임 종료→허브 복귀

### MainGame.gd 업데이트
- 개별 바카라/블랙잭 버튼 2개 → `_open_jeongseon_casino()` 단일 버튼으로 통합
- JeongseonCasino 허브에 5개 하위게임 레퍼런스 주입

### MetaProgression.gd
- 슬롯 마스터리 칭호 "잭팟 사냥꾼" (20스핀 이상)
- 룰렛 마스터리 칭호 "제로의 지배자" (15스핀 이상)
- 빅휠 마스터리 칭호 "바늘의 눈" (15스핀 이상)

### 품질
- `python3 tools/audit.py` → ERROR 0 / WARNING 0

## 2026-06-14 (튜토리얼 시스템 + 미니게임 퀄리티 2차 패스)

### TutorialOverlay 세션 튜토리얼 시스템
- `scenes/TutorialOverlay.gd` — `class_name TutorialOverlay`, `static var _seen`으로 세션당 1회 표시
- `maybe_show(id, parent)` / `force_show(id, parent)` 정적 API
- 게임별 슬라이드 콘텐츠: baccarat·blackjack·holdem(2슬라이드)·slot·roulette·bigwheel·scalping·trading·racetrack
- `main_game` 3슬라이드 추가: 목표 설명 / 대시보드 읽는 법 / 한 달 흐름
- MainGame._continue_after_story()에 maybe_show("main_game") 삽입 (프롤로그 직후 1회)

### JeongseonCasino 허브 개선
- `_add_game_card()`에 `tutorial_id` 파라미터 추가
- 각 게임 카드에 '❓ 규칙' 보조 버튼 추가 (force_show 연결)

### 전 게임 씬 인게임 도움말 버튼
- 슬롯·룰렛·빅휠·바카라·블랙잭·홀덤·스캘핑·투자·경마 헤더/액션열에 ❓ 버튼 추가

### AudioManager 버그 수정
- RouletteTable·BigWheelGame의 `AudioManager.play_sfx()` → `AudioManager.play()` 전환
  (play_sfx는 존재하지 않는 메서드 — SFX가 조용히 무시되던 버그)

### 미니게임 연출 강화 (2차 패스)
- SlotMachineGame: JACKPOT 3회 깜빡임 + 릴 패널 골드 테두리 / 빅윈 2회 플래시 / 니어미스 '아깝다!' 연출
- RouletteTable: 결과 확정 시 숫자 레이블 scale 팝 펄스 트윈
- BlackjackTable: 딜 후 content_root scale 0.94→1.0 팝 + screen_flash
- RaceTrack: 3→2→1→출발! 카운트다운 오버레이 (레이스 시작 전)
- MainGame: 건강 ≤ 30 / 정신 ≤ 30 / 스트레스 ≥ 80 시 vital 레이블 alpha 펄스 경보

### 품질
- `python3 tools/audit.py` → ERROR 0 / WARNING 0 (전 커밋 통과)

## 2026-06-15 (이미지 의미 매핑 2차 + 게임감 연출)

### 투자 미니게임 프레젠테이션 1차
- `ScalpingGame.gd`를 선 그래프 중심에서 캔들형 차트로 강화했다.
  - 가격 변화를 캔들 바디/윅으로 표시하고, 현재가 라벨을 차트 위에 직접 표시한다.
  - BUY/SELL 마커를 차트 위에 남겨 진입·청산 타이밍을 플레이어가 복기할 수 있게 했다.
  - MARKET OPEN, BUY, PROFIT/LOSS 배너와 화면 플래시, 손실 시 차트 흔들림, 이익 시 손익 펄스를 추가했다.
- `TradingFloor.gd`에 평균단가선과 체결 피드백을 추가했다.
  - 보유 종목의 평균단가를 차트 수평선으로 표시한다.
  - 매수/매도 시 BUY/TAKE PROFIT/CUT LOSS 배너, 화면 플래시, 차트 펄스/흔들림을 추가했다.
  - 매도 전 현재가·평단·비율로 예상 실현손익을 계산해 승패 SFX를 다르게 재생한다.

### 미니게임 독립 품질 기준 확장
- 기존 경마·홀덤·투자 기준에 더해, 새로 구현 중인 정선 카지노 계열 전체를 독립 게임급 품질 대상으로 포함했다.
- 현재 포함 대상은 블랙잭, 바카라이며, Claude가 앞으로 추가할 카지노 게임도 같은 기준을 따른다.
- 정선 카지노 게임은 룰 정확도만으로는 부족하다. 카드 딜, 칩 이동, 딜러 콜, 승패 배너, 테이블 사운드, 세션 통계, 재도전 루프까지 갖춰야 한다.
- 유저 기준을 "플래시게임 수준에서 2만원짜리 게임 품질로 올릴 것"으로 재정의했다. 앞으로 미니게임은 단순 모달이 아니라 화면 밀도, 반응성, 사운드, 애니메이션, 세션 UX를 갖춘 제품 레벨로 본다.

### 정선 카지노 카지노 프리미엄 연출 1차
- Claude가 push한 `origin/main` 50c9130을 fast-forward로 병합했다.
  - 포함 내용: 정선 카지노 허브, 슬롯머신, 룰렛, 빅휠, 스캘핑 캔들스틱 업그레이드.
  - Codex의 스캘핑 손익 배너/플래시 연출은 Claude의 `_trade_history` 구조 위로 병합했다.
- 새 `BigWheelGame.gd`의 Variant 기반 타입 추론 한 줄을 명시 타입으로 교정해 Godot 4.6 컴파일을 통과시켰다.
- `BlackjackTable.gd`에 테이블 게임 피드백 레이어를 추가했다.
  - DEAL/HIT/STAND/DOUBLE DOWN/SPLIT/DEALER/WIN/LOSE/PUSH 중앙 배너를 추가했다.
  - 액션별 화면 플래시, 더블다운·패배 흔들림, 승리 펄스를 추가했다.
  - 기존에 `_flash()`가 참조하던 메시지 라벨을 실제 skeleton에 추가해 오류 가능성을 줄였다.
- `BaccaratTable.gd`에 딜러 콜 느낌의 진행 연출을 추가했다.
  - 베팅 시 BET 배너, 딜 시작 시 NO MORE BETS 배너를 표시한다.
  - 카드 공개 시 PLAYER CARD/BANKER CARD 배너와 색상 플래시를 넣었다.
  - 결과 정산 후 PLAYER WINS/BANKER WINS/TIE 및 손익 배너, 승리 펄스/패배 흔들림을 추가했다.

### 메인 병합 및 카지노 컴파일 안정화
- Claude가 push한 `origin/main` ebfa19e를 fast-forward로 병합했다.
  - 포함 내용: 정선 카지노 바카라/블랙잭 신규 구현, 홀덤 팟오즈/핸드히스토리/1-3팟 레이즈, life/drama/relationship 이벤트 정리.
- Codex 로컬 변경과 충돌난 `CLAUDE.md`, `scenes/HoldemClub.gd`를 수동 병합했다.
  - 홀덤은 Claude의 팟오즈/핸드히스토리와 Codex의 POT/칩 버스트/페이즈 배너 연출을 모두 유지한다.
- 새 블랙잭 코드가 Godot 4.6 엄격 타입 검사에서 실패하던 문제를 수정했다.
  - `systems/Blackjack.gd`, `scenes/BlackjackTable.gd`의 Variant 기반 `:=` 추론을 명시 타입으로 교정.
  - 룰/밸런스 의미 변경 없이 컴파일 안정성만 보강했다.

### 배경 의미 매핑
- `ImageRegistry.infer_background_id()` 장소 우선순위를 보강했다.
  - 카페/커피, 편의점, 회사/면접, 지하철, 부동산/전세/청약/재개발, 도서관/스터디카페, 홀덤, 경마, 복권 키워드를 broad category보다 먼저 본다.
  - `holdem`/`racetrack` 태그는 `gambling` 기본 폴백보다 우선해 각각 `holdem_club`, `racetrack_betting`/`racetrack_track`으로 간다.
  - 일반 단어 `카드`/`running`처럼 오탐이 큰 키워드는 추론에서 제외했다.
- `content/events/callback_events_21.json`의 홀덤/경마 echo 이벤트 4종에 명시 category/tags/background/cooldown을 추가했다.
- `tools/background_semantic_audit.py`를 런타임 추론과 맞춰 갱신하고 `docs/BACKGROUND_SEMANTIC_AUDIT.md`를 재생성했다.
  - 리뷰 후보는 225건에서 103건으로 감소.
  - 잔여 103건은 회식/회상/장소 전환처럼 자동 확정이 위험한 후보라 실기 QA에서 사람이 판정한다.

### 게임감 연출
- MainGame 선택 결과에 SFX, 플래시, 배경 흔들림, 상단 자금 펄스, 결과 타이틀 펄스를 추가했다.
- 경마 미니게임에 베팅 차감 SFX, 출발 플래시/흔들림, 적중/실패 플래시, 결과 숫자 펄스를 추가했다.
- 경마 미니게임 2차 프레젠테이션 패스를 추가했다.
  - 베팅 화면은 `racetrack_betting_hall.png`, 레이스 시작 후에는 `racetrack_track_view.png`로 배경을 전환한다.
  - 질주 말 실루엣 위에 레인 컬러 기반 기수/새들 오버레이를 코드로 합성해 "실제 기수가 달리는" 느낌을 보강했다.
  - 레인 노면, 흙먼지, 속도선, 비선형 질주 흔들림, 선두 교체/마지막 직선 실황 메시지를 추가했다.
- 홀덤 미니게임에 핸드 시작/보드 공개 플래시, 레이즈 타격감, 쇼다운 승패 플래시/흔들림, 세션 결과 펄스를 추가했다.
- 홀덤 미니게임 2차 프레젠테이션 패스를 추가했다.
  - 중앙 `POT` 라벨과 칩 아이콘을 추가해 판돈이 계속 보이게 했다.
  - NEW HAND/FLOP/TURN/RIVER/SHOWDOWN 및 CALL/RAISE/FOLD/CHECK 배너를 추가했다.
  - 콜/레이즈/블라인드/AI 액션 때 칩 버스트 파티클을 띄워 팟에 돈이 들어가는 감각을 보강했다.
  - 카드 크기를 키우고 커뮤니티/홀카드 공개 시 카드열 펄스를 넣었다.

### 미니게임 품질 기준
- 경마·홀덤·투자·카지노 계열은 단순 부가 기능이 아니라 게임의 대중적 재미를 책임지는 핵심 축으로 본다.
- 목표 기준을 "미니게임 하나만 떼어도 팔 수 있는 수준"으로 상향했다.
- 1차 방향은 룰 추가보다 플레이 피드백, 애니메이션, 사운드, 승패 연출, 반복 숙련감이 먼저다.
- 이번 패스에서 경마와 홀덤은 "정적 모달"에서 "연출이 있는 미니게임"으로 1차 상승했다. 다음 단계는 전용 SFX/스프라이트/실기 QA다.

### 검증
- `python3 -m py_compile tools/background_semantic_audit.py`
- `python3 -c "import json; json.load(open('content/events/callback_events_21.json', encoding='utf-8'))"`
- `git diff --check`
- `./tools/audit.sh` — ERROR 0 / WARNING 0, Godot 전체 스크립트 컴파일 깨끗
- `origin/main` ebfa19e 병합 후 `./tools/audit.sh` 재실행 — ERROR 0 / WARNING 0, Godot 전체 스크립트 컴파일 깨끗
- 투자 미니게임 프레젠테이션 1차 후 `./tools/audit.sh` 재실행 — ERROR 0 / WARNING 0, Godot 전체 스크립트 컴파일 깨끗
- 카지노 프리미엄 연출 1차 후 `./tools/audit.sh` 재실행 — ERROR 0 / WARNING 0, Godot 전체 스크립트 컴파일 깨끗
- `origin/main` 50c9130 병합 후 `./tools/audit.sh` 재실행 — ERROR 0 / WARNING 0, Godot 전체 스크립트 컴파일 깨끗

## 2026-06-13 (실제 화면 배경 의미 매핑 1차 수정)

### 메인 최신화 확인
- `git fetch origin main` / `git pull --ff-only origin main` 실행.
- 로컬 `main`은 이미 `origin/main` 최신(`e21b23e`)과 동일했고, 추가 fast-forward 대상은 없었다.

### 버그픽스 (Codex)
- 유저 QA: `집들이` 결과 지문에서 "방 안을 한 바퀴 둘러봤다"가 나오는데 카페/비 오는 거리 계열 배경처럼 보이는 문제 확인.
- 원인: 명시 `background`가 없는 이벤트가 `social`/`health` 같은 broad category 폴백을 먼저 타면서, 구체 장소 의미(`housing`, `gym`, 본문 속 방/헬스장)가 덮였다.
- `ImageRegistry.infer_background_id()`의 우선순위를 수정:
  - `friend_housewarming` / `housewarming_alone` / `집들이` / `방 안` / `옆 건물` 계열은 현재 주거 배경으로 매핑.
  - `gym` / `exercise` / `헬스장` / `운동` 계열은 병원보다 먼저 운동 배경 ID로 매핑.
  - `hospital` / 병원·의사·검진·응급실 텍스트만 병원 배경으로 매핑.
  - `family` 계열 StoryMode 폴백도 `restaurant`가 아니라 `dad_house`로 정렬.
  - 배경 추론은 현재 장면의 제목/본문/태그만 보고, 선택지/결과문 텍스트는 보지 않게 조정해 선택지만으로 시작 배경이 바뀌는 문제를 방지.
- `ImageRegistry.BACKGROUNDS`에 `rooftop_day`, `gym`, `exercise`, `military` alias 추가.
- `MainGame.gd`의 루틴 비네트(`운동`, `독서`, `명상`, `재테크`, `저축`, `인맥`)가 직전 이벤트 배경을 그대로 물고 가던 문제 수정:
  - 비네트용 배경 선택 함수 추가.
  - 결과/비네트 표시 중에는 빈 `current_event` 새로고침이 배경을 기본값으로 되돌리지 않도록 transient background lock 추가.
  - MainGame 이벤트 배경 추론을 `ImageRegistry` 공통 규칙으로 통합해 StoryMode와 판단 차이를 줄임.

### 검증
- `./tools/audit.sh` 통과: ERROR 0 / WARNING 0, 밸런스 밴드 통과, Godot 전체 스크립트 컴파일 깨끗.

## 2026-06-13 (콜백 이벤트 배치 23~26 완료 — dead flag 전수 연결 마무리)

### 추가된 것 (claude/game-polish 브랜치)
- **콜백 이벤트 배치 23~26** (48개 KR+EN): 잔여 dead flag 전수 콜백 연결 완료
  - 배치 23: 재혁(4) / 지연(3) / 다은(3) / spec 전문화(3) / fell_to_darkness/escaped_dirty_money (15개)
  - 배치 24: spec_elite/social_climber/social_entrepreneur / jaehyuk_trusted_fully/stood_up / jiyeon_took_money / daeun_chose_her/committed / 카페 결말 6종 (14개 — jiyeon_walked_away는 배치 10과 중복 제거)
  - 배치 25: 체인 6종 / political_candidate/winner / final_sprint 3종 / parent_took_loan/paid_full / guarantee_compromise / mystery_info_paid_off (15개)
  - 배치 26: mystery_info_scammed/resolved / resume_lie_doubled_down / resume_lied_toeic (4개)
- `DataRegistry.gd`: callback_events_23~26 등록
- 총 콜백 이벤트: 배치 1~26, **dead flag 전수 연결 완료**

---

## 2026-06-13 (콜백 이벤트 배치 17~22 완성 + main merge)

### 추가된 것 (claude/game-polish 브랜치)
- **콜백 이벤트 배치 17~22** (89개 KR+EN): dead flag 89개 콜백 이벤트로 연결
  - 배치 17: 재혁/아버지/상철/신용/거짓말 계열 (14개)
  - 배치 18: 다은(supportive/guarded/understood/deflected) / 지갑 / 신용 / 코인 / 회식 / climber / elite / 아버지화해 (15개)
  - 배치 19: 그림자투자 / 보증 / 프리랜서 / SNS / 솔로창업 / 전세 / 다은재연결 / 시기연료 / 선언 / SNS삭제 (15개)
  - 배치 20: father_going_soon / startup 3종 / jobswitch 3종 / headhunted / 동창회 / 친구고백 / 도박앱삭제 / 바닥 / 아버지약속 / gray팁 / 바른길 (15개)
  - 배치 21: 코인거절/경고 / 홀덤빅윈/끊음 / 경마추격/빅윈 / 보증거절/보증섬 / 전세보험 O/X / 부모거절 / 이력서고백 / 동창솔직 / 지갑반환 / 주운돈 (15개)
  - 배치 22: 크리에이터 3종 / 프리랜서시작 / ETF 2종 / 내부정보 2종 / USB / 신용손상/선긋기 / FOMO / 낯선사람 / 승진 / 자격증 (15개)
- `DataRegistry.gd`: callback_events_17~22 등록

### 버그픽스
- `scenario_cafe.json` `cafe_00`: "무직 주제에" 텍스트 → 제거
- `investment_events.json` `finance_012`: `max_money: 500000` 조건 추가
- `life_events.json` `season_lunar_new_year`: `no_job: true` 조건 추가

### main merge
- VISUAL_AUDIO P2/P3 완료 (main) + 콜백 배치 work (브랜치) merge

---

## 2026-06-13 (VISUAL_AUDIO P2 public venue 배경 패스)

### 공공장소 배경 실루엣 원칙 정리 (Codex)
- 유저 피드백: PC방/경마장/식당 같은 공공장소가 완전히 비어 있으면 오히려 부자연스럽다.
- 배경 원칙을 "무조건 무인"에서 "반복 주연/조연처럼 읽히는 인물 금지, 공공장소는 작고 어두운 익명 실루엣 허용"으로 정정.
- `docs/ASSET_CONTINUITY_CHECKLIST.md`, `docs/BACKGROUND_CONTINUITY_AUDIT.md`, `assets/ASSET_INDEX.md`, `assets/VISUAL_AUDIO_UPGRADE_BRIEF.md`에 새 기준 기록.

### P2 public venue 배경 교체 (Codex)
- 7개 리뷰 배경을 1280×800으로 교체:
  - `seoul_rainy_street.png`
  - `hometown_train_station.png`
  - `library.png`
  - `restaurant_korean.png`
  - `pc_bang_interior.png`
  - `racetrack_betting_hall.png`
  - `holdem_club_interior.png`
- PC방/경마장/홀덤/식당/도서관은 얼굴 없는 배경 실루엣을 허용해 장소의 자연스러움을 살림.
- 홀덤 배경은 전경 손/팔 없이 실제 홀덤 테이블, 카드, 칩만 보이게 교체.
- `/tmp/gangnamdream_p2_review_backgrounds_after.png` QA 시트 생성.
- 배경 감사 현황을 36 pass / 0 review / 0 fix / 0 quarantined로 갱신.

### P2 CG/키아트 최종 패스 (Codex)
- CG 런타임/크롭 기준 재확인: `tools/VisualCropQA`와 `tools/CGRuntimeCheck` 기준 `start`, `jiyeon_crash`, `jaehyuk_reveal`, `ending_father`가 현재 1280×800 런타임에서 핵심 정보를 유지함.
- `gangnam_dream_keyart_rooftop.png`를 1920×1080 textless master key art로 교체: 낡은 서울 옥상, 뒤돌아선 김민준, 멀리 보이는 강남 스카이라인 대비를 강화.
- Steam store material 3종을 새 마스터 키아트에서 파생:
  - `steam_capsule_main.png` 616×353
  - `steam_header.png` 460×215
  - `steam_capsule_small.png` 231×87
- Steam 캡슐 제목은 이미지 생성 모델에 맡기지 않고 로컬 폰트로 `GANGNAM DREAM` / `강남드림`을 합성해 가독성 유지.
- `/tmp/gangnamdream_p2_keyart_after.png` QA 시트 생성.
- VISUAL_AUDIO P2 배경/CG/키아트 품질 교체 완료 처리. 다음 단계는 P3 BGM/SFX 품질 교체.

### P3 BGM/SFX 품질 교체 (Codex)
- `tools/generate_audio_assets.py` 추가: 외부 음악 생성 서비스 없이 deterministic local synthesis로 BGM/SFX를 재생성하는 스크립트.
- BGM 7종을 Ogg Vorbis stereo 44100 Hz로 재생성:
  - `bgm_menu.ogg`, `bgm_gosiwon.ogg`, `bgm_main.ogg`, `bgm_apartment.ogg`, `bgm_crisis.ogg`, `bgm_victory.ogg`, `bgm_ending.ogg`
- 기존 `bgm_gosiwon.ogg`가 `file` 기준 Theora video로 잡히던 문제를 Ogg Vorbis audio로 교체해 해결.
- SFX 17종을 mono 44100 Hz WAV로 재생성. 기존 14종 외에 무음 호출이던 `sfx_buy.wav`, `sfx_sell.wav`, `sfx_tab_open.wav` 추가.
- `AudioManager._SFX_FILES`에 `buy`, `sell`, `tab_open` 매핑과 프로시저럴 폴백 추가.
- BGM import 설정 정리: menu/gosiwon/main/apartment/crisis/ending loop=true, victory loop=false.
- `tools/AudioAssetCheck.gd` / `tools/AudioAssetCheck.tscn` 추가. 결과: `AUDIO_ASSET_CHECK_OK bgm=7 sfx=17`.
- `docs/AUDIO_QA.md` 추가: 파일 타입, 길이, loop/import 설정, 검증 명령 기록.

## 2026-06-12 (비주얼+오디오 업그레이드 준비)

### 정본 맵/확장 규칙 문서화 (Codex)
- `docs/CANON_MAP.md` 추가: 하드 캐논, 주요 인물, 메인 아크, 폐기/legacy 설정, DLC/주기 업데이트 확장 게이트 정리.
- `STORY_BIBLE.md`의 구 시작 자금 300만원을 현재 런타임 정본인 50만원으로 수정.
- 고시원 월세 표기를 현재 기본 고정 지출 65만원으로 수정.
- 향후 콘텐츠 확장은 canon delta → state/ID 예약 → 에셋 규칙 → JSON/코드 → audit/인게임 QA 순서로 진행하기로 명문화.

### 가족 배경 정합성 격리 (Codex)
- `family_living_room.png` 확인 결과, 큰 대가족 액자와 안정적인 화목 가정집 신호가 민준 가족 정본(아버지 보증사기, 부모 분리, 민준 혼자 서울 고시원)과 충돌.
- `ImageRegistry.gd`의 `dad_house`와 `MainGame.gd`의 `BG_FAMILY`를 임시로 `restaurant_korean.png`에 매핑해 production 기본 가족 배경에서 격리.
- `CANON_MAP.md`, `ASSET_QA.md`, `ASSET_INDEX.md`, `DECISIONS.md`에 가족 집 배경 재생성 기준 기록: 창원/지방 노동자 가정, 낡고 조용한 거실, 작은 오래된 가족사진 1개 이하, 대가족 단체사진 금지.
- `docs/ASSET_CONTINUITY_CHECKLIST.md` 추가: 이미지가 암시하는 가족 구성, 경제 수준, 방 구조, 차량, 소품을 canon QA 대상으로 명문화.
- 구 `IMAGE_PROMPTS.md` / `ASSETS_BRIEF.md`의 가족 거실 프롬프트에서 대가족/일반 화목한 집 신호를 제거하고 민준 아버지의 창원 노동자 가정 기준으로 교정.

### 한지연 투명 포트레이트 + 가족 거실 재생성 (Codex)
- `npc_mentor.png`, `npc_jiyeon_warm.png`, `npc_jiyeon_cold.png`를 같은 얼굴/의상/나이를 유지한 한지연 3표정 투명 PNG로 교체.
- 크로마키 원본에서 배경 제거 후 512×768 RGBA로 저장. 모서리 알파 0 검증 완료.
- `family_living_room.png`를 1280×800으로 재생성: 대가족 액자, 부유한 서울 아파트, 큰 전망창 없이 낡은 창원 노동자 가정 거실로 교정.
- 새 가족 거실이 정합성 검수를 통과해 `ImageRegistry.gd`의 `dad_house`와 `MainGame.gd`의 `BG_FAMILY`를 `family_living_room.png`로 재연결.
- `/tmp/gangnamdream_jiyeon_new_portraits.png` 검수 시트 생성.

### 김민준 핵심 투명 포트레이트 교체 (Codex)
- `main_character_neutral_goshiwon.png`, `main_character_tired.png`, `main_character_determined.png`, `main_character_happy.png`, `main_character_shocked.png`를 배경 없는 512×768 RGBA 포트레이트로 교체.
- 파일명 `neutral_goshiwon`은 레거시 이름으로 유지하되, 실제 이미지는 고시원 배경을 포함하지 않도록 정리.
- 기존 happy/shocked의 폰 소품 문제를 제거하고 얼굴 표정만으로 감정이 읽히도록 교체.
- `/tmp/gangnamdream_minjun_new_portraits.png` 검수 시트 생성. 첫 neutral 크롭에 옆 포즈 조각이 섞인 것을 재크롭해 제거.

### 현수 호감형 재디자인 (Codex)
- `npc_close_friend.png`를 26-27세 통통한 공시생 후배 느낌의 512×768 RGBA 투명 포트레이트로 교체.
- 이전 고구분성 버전은 민준과의 식별성은 좋았지만, 중년/비호감 인상이 강해 비주얼노벨 조연 매력이 떨어진다고 판단.
- 첫 등장 이벤트의 "스물여섯 정도" 및 민준을 "형"이라 부르는 대사에 맞춰 `CANON_MAP.md`, `STORY_BIBLE.md`, `CHARACTER_VISUAL_BIBLE.md`, 에셋 브리프의 36세/30대 초반 문구를 교정.
- `/tmp/gangnamdream_minjun_hyunsu_readability.png` 비교 시트 생성: 민준은 마른 검은 스웨트셔츠, 현수는 통통한 안경+올리브 후드+버건디 티셔츠로 구분.

### 김민준 직업별 의상 포트레이트 (Codex)
- `main_character_unemployed.png`, `main_character_part_time.png`, `main_character_office.png`, `main_character_corporate.png`를 512×768 RGBA 투명 포트레이트로 추가.
- `/tmp/gangnamdream_minjun_outfit_variants.png` 비교 시트 생성. 같은 얼굴/나이/체형을 유지하면서 무직 기본복, 알바 캐주얼, 일반 사무직, 대기업 정장을 구분.
- `ImageRegistry.get_player_context_portrait()` 추가: 현재 직업 카테고리/티어에 따라 주인공 평상시 포트레이트 의상을 자동 선택.
- `MainGame._get_portrait_path()`를 `ImageRegistry` 기준으로 정렬해 대시보드와 이벤트 `player_normal`/`player_determined`/`player_suit`가 같은 의상 규칙을 사용.
- `main_character_30s.png`는 방 배경이 박힌 레거시 이미지라 기본 런타임 상태 포트레이트에서 제외.

### 반복 보조 NPC 투명 포트레이트 교체 (Codex)
- 기존 `npc_goshiwon_owner.png`, `npc_team_lead.png`, `npc_seongjun.png`, `npc_tip_seller.png`는 512×768 RGBA였지만 모서리 알파가 255라 실제로는 배경 포함 이미지였음을 확인.
- 4종을 같은 한국 만화풍 VN 스타일의 512×768 RGBA 투명 포트레이트로 교체: 고시원 원장(58세 운영자), 팀장(47세 직장 상사), 박성준(34세 고교 친구·9급 공무원), 경마장 정보상(45-50세).
- 박성준은 금융권 연락처가 아니라 고교 친구/공무원 정본으로 에셋 인덱스 설명을 교정.
- `/tmp/gangnamdream_minor_npc_transparent_pass.png` QA 시트 생성. 네 파일 모두 모서리 알파 0 검증 완료.

### 성준/팀장 구분성 재교정 (Codex)
- 팀장과 성준이 모두 검은 머리·안경·직장인 계열이라 첫눈에 닮아 보이는 문제를 확인.
- `npc_seongjun.png`를 안경 없는 34세 공무원 친구 이미지로 재생성: muted cardigan/jacket, 체크 셔츠, ID lanyard, 부드러운 체념 표정.
- 팀장은 흰 셔츠·넥타이·팔짱·안경의 압박형 상사 실루엣으로 유지해 역할 대비를 강화.
- `/tmp/gangnamdream_teamlead_seongjun_readability.png`에서 팀장/성준/민준/현수 동시 비교 완료. 네 파일 모두 모서리 알파 0 검증.

### 전체 배경 2차 정합성 감사 (Codex)
- `ImageRegistry`, `MainGame`, 미니게임 씬, StartMenu 직접 참조를 합쳐 production/direct 배경 36장을 확인.
- `late_night_room.png`가 큰 창문과 다른 방 구조를 가져 고시원 밤/정신력 이벤트 정본과 충돌한다고 판단. `ImageRegistry.BACKGROUNDS["late_night"]`와 `MainGame.BG_NIGHT_ROOM`를 `goshiwon_room.png`로 변경해 runtime에서 격리.
- 변경 후 production/direct 배경은 35장. `/tmp/gangnamdream_backgrounds_production_after_remap.png` QA 시트 생성.
- `docs/BACKGROUND_CONTINUITY_AUDIT.md` 추가: 24 pass, 6 review, 5 fix, 1 quarantined 판정 기록.
- 재생성 대상 확정: `convenience_store_night.png`(카운터 직원 실루엣), `gangnam_day.png`/`gangnam_night_street.png`/`gangnam_station_exit.png`(전경 주인공형 실루엣), `penthouse_view.png`(엔딩 배경 내 남성 실루엣), 선택적 `late_night_room.png` canonical night variant.

### 편의점 배경 person-free 재생성 (Codex)
- `convenience_store_night.png`를 새벽 2시 한국 편의점 내부로 재생성. 카운터, 진열대, 유리창 밖 빗길은 유지하되 직원/손님/인물 실루엣을 제거.
- 1280×800 RGB PNG로 저장하고 첫 인게임 QA용 PASS로 갱신.
- 배경 감사 현황을 25 pass / 6 review / 4 fix / 1 quarantined로 업데이트.

### 배경 실패컷 재생성 완료 (Codex)
- `gangnam_day.png`, `gangnam_night_street.png`, `gangnam_station_exit.png`를 전경 주인공형 인물 없는 neutral Gangnam 배경으로 재생성.
- `penthouse_view.png`를 사람/실루엣 없는 empty luxury ending background로 재생성.
- `late_night_room.png`는 새로 그리지 않고 `goshiwon_room.png`를 기반으로 4am 색보정 변형을 만들어 같은 방 구조를 보존. `ImageRegistry.BACKGROUNDS["late_night"]`와 `MainGame.BG_NIGHT_ROOM`를 다시 `late_night_room.png`로 연결.
- `/tmp/gangnamdream_background_regen_complete.png`와 `/tmp/gangnamdream_backgrounds_production_final.png` QA 시트 생성.
- 배경 감사 현황을 30 pass / 6 review / 0 fix / 0 quarantined로 업데이트.

### 현수 이벤트/호칭 정합성 교정 (Codex)
- `amb_coin_00` / `amb_coin_warn`의 `형(야)` 혼합 대사를 `형` 기준으로 정리.
- `rel_hyunsu_loan`의 "야, 나..." 대사를 26-27세 후배가 민준에게 부탁하는 말투로 교정.
- `chicken_franchise_neighbor`가 현수 포트레이트를 쓰면서 "옆방 선배/2년 선배"로 서술되던 문제를 "옆방 후배 현수" 사건으로 교정.
- 고등학교 친구 보증 이벤트 `amb_guarantee_00`이 현수 호감도를 올리던 잘못된 `cast_effects.hyunsu`를 KO/EN 모두 제거.
- EN 현수 첫 등장에 `hyung` 호칭을 추가해 영어판에서도 형/동생 관계가 드러나도록 정렬.

### 인게임 크롭 QA (Codex)
- `tools/VisualCropQA.gd` / `tools/VisualCropQA.tscn` 추가. Godot headless dummy renderer가 SubViewport 스크린샷을 반환하지 않아, 실제 에셋 파일을 직접 읽고 MainGame/StoryMode/CG 크롭 수학을 CPU 합성으로 재현하는 방식으로 구현.
- `/tmp/gangnamdream_crop_qa/visual_crop_qa_sheet.png` 생성: StoryMode 7조합, MainGame 4조합, CG fullscreen 4조합 총 15장.
- P1 결과: 고시원/late-night 방 구조 일치, 편의점 무인 배경, 강남 day/night/station 배경, 가족집, 핵심 포트레이트 크롭에서 신규 P0/P1 실패 없음.
- CG 파일 자체는 fullscreen crop QA 통과. 다만 코드 검색상 이벤트/엔딩 `cg` 키가 StoryMode/Ending 화면에서 실제로 표시되는 연결은 별도 다음 작업으로 남김.

### 한지연 사고 CG 얼굴 정합성 교정 (Codex)
- 유저 피드백: `jiyeon_crash.png`의 한지연 얼굴이 투명 포트레이트 한지연과 다른 사람처럼 읽힘.
- `npc_mentor.png`, `npc_jiyeon_warm.png`, `npc_jiyeon_cold.png`를 정본 참조로 사용해 사고 CG를 재생성하고 1280×800으로 리샘플링해 교체.
- 유지한 사건 정본: 비 오는 강남 야간 도로, 검은 Mercedes-Benz S-Class급 세단, 운전석 앞문에서 내리는 지연, 자전거 두 바퀴, 왼쪽의 김민준.
- `/tmp/gangnamdream_jiyeon_crash_identity_qa.png` 비교 시트 생성 및 `tools/VisualCropQA` 재실행 완료.

### CG 런타임 표시 연결 (Codex)
- StoryMode가 이벤트 JSON의 `cg` 키를 읽어 `ImageRegistry.get_cg()`로 전체화면 CG를 표시하도록 연결.
- CG 장면에서는 별도 포트레이트 프레임을 숨기고, 텍스트 박스/이름표만 유지해 CG와 포트레이트가 겹치지 않게 조정.
- MainGame 엔딩 화면이 `endings.json`의 `cg` 키를 읽어 엔딩 배경으로 사용하고, 모달 안에 와이드 CG 프리뷰를 추가하도록 연결.
- `tools/CGRuntimeCheck.gd` / `tools/CGRuntimeCheck.tscn` 추가. `arc_jiyeon_01_crash`의 StoryMode CG 연결과 `gangnam_dream`의 엔딩 CG 경로/프리뷰 생성을 헤드리스에서 검증.

### 한지연 31세 정본 스캔 (Codex)
- 한지연 관련 활성 메인 아크(`arc_jiyeon_01_crash` 이후)는 서른 초반/긴 검은 머리/크림 수트/검은 Mercedes-Benz S-Class급 세단 기준으로 정렬되어 있음을 확인.
- 구 `relationship_events.json`의 `jiyeon_meet`→`jiyeon_confession` 체인은 `min_turn:9999`, `hidden:true`, `weight:0.0`으로 비활성 상태이며, 40대 멘토 텍스트는 활성 이벤트에서 발견되지 않음.
- 남아 있는 `박지연`/`40s mentor` 표현은 deprecated/과거 로그 맥락으로만 유지한다. production 정본은 `CANON_MAP.md`와 `CHARACTER_VISUAL_BIBLE.md`의 31세 한지연.

### 한지연 정본/정합성 교정 (Codex)
- 한지연 역할을 "멘토"가 아니라 31세 강남 금수저 / 위험한 투자 히로인 / 로맨스 상대역으로 재정의.
- `assets/CHARACTER_VISUAL_BIBLE.md` 추가: 긴 검은 머리, 크림/블랙 수트, 예쁘고 위험하고 고혹적인 인상, 배경 없는 투명 포트레이트 원칙, 단발 중년 멘토상 금지.
- `STORY_BIBLE.md`, `assets/VISUAL_AUDIO_UPGRADE_BRIEF.md`, `docs/ASSET_GAP_SPEC.md`, `assets/ASSET_INDEX.md`, `docs/ASSET_QA.md`의 한지연 설명을 정본에 맞춰 수정.
- 첫 접촉 사고 차량을 흰색 BMW가 아니라 `jiyeon_crash.png`와 맞는 검은 메르세데스 벤츠 S클래스급 세단으로 통일.
- 구 `relationship_events.json`의 `jiyeon_meet`→`jiyeon_confession` 랜덤 체인을 legacy 비활성화. 정본 첫 만남은 `arc_jiyeon_01_crash`만 사용.

### P1 비주얼 에셋 생성/연결 (Codex)
- `assets/VISUAL_AUDIO_UPGRADE_BRIEF.md` 기준 P1 누락 이미지 10장 생성.
- NPC 표정 파생 7장 추가:
  - `npc_daeun_smile.png`, `npc_daeun_sad.png`
  - `npc_father_weak.png`
  - `npc_sangchul_serious.png`
  - `npc_jiyeon_warm.png`, `npc_jiyeon_cold.png`
  - `npc_jaehyuk_shadow.png`
- 신규 배경 3장 추가:
  - `restaurant_korean.png`
  - `library.png`
  - `street_seoul_day.png`
- `ImageRegistry.gd`에서 기존 alias를 실제 파생 파일로 연결.
- `/tmp/gangnamdream_p1_visual_upgrade_qa.png` 검수 시트 생성. P1 신규 에셋 해상도 확인: 초상화 512×768, 배경 1280×800.
- `./tools/audit.sh` 통과: ERROR 0, WARNING 0. Godot 컴파일 체크 중 신규 PNG `.import` 파일 생성 확인.
- 시작 CG 재생성 후보 1장은 고시원답지 않은 대형 전망창 때문에 폐기. 이후 `start.png`를 큰 창문 없는 고시원 장면으로 교체: 침대 발치/화면 하단 책상, 강남은 폰 화면의 목표 이미지로만 암시.
- `goshiwon_room.png`도 같은 구조(작은 환기창, 침대, 침대 발치 낮은 책상)로 재생성해 시작 CG와 공간 연속성 통일.
- `ending_father.png` 교체: 강남 전망 장면 → 병실에서 아버지 손을 잡는 감정 CG.
- 이후 유저 QA로 반복 주연 초상화에 배경이 포함되면 장소 정합성이 계속 깨진다는 문제를 확정. 주연/핵심 반복 인물은 투명 포트레이트, 배경은 무인 장소, CG만 인물+배경 허용으로 에셋 파이프라인 전환.
- 일반 투자 장면에서 멀티모니터 배경이 뜨는 문제를 방지하기 위해 `trading` 레거시 키를 `investment_phone.png` 스케일로 폴백. 멀티모니터는 스캘핑/전문 투자 장면 전용으로 분리.

### 추가된 것
- **VISUAL_AUDIO_UPGRADE_BRIEF.md** (`assets/`): 이미지/오디오 에이전트용 전체 교체 스펙
  - P1 크리티컬: 주인공 7포즈 + NPC 14장 + 핵심 배경 10장 + CG 2장
  - P2 완전 품질: 나머지 배경 20장 + CG 2장 + 키아트 4장
  - P3 오디오: BGM 7트랙 + SFX 14종
  - 장면별 영문 프롬프트, 기술 스펙(1280×800 배경 / 512×768 초상화 / 1280×720 CG)
  - ImageRegistry 업데이트 가이드 포함
- **ImageRegistry.gd**: 누락 배경 5개 추가 (library, restaurant, street, apartment, convenience_store)

### 배경
- 단순 파일 누락만이 아닌 플레이스홀더 수준의 모든 이미지를 교체 대상으로 결정
- 오디오도 동일하게 전체 재생성 대상

---

## 2026-06-12 (100명 리뷰어 분석 기반 게임 폴리시)

### 추가된 것
- **새 이벤트 54개** — KO 베이스 4파일 + EN 오버레이 4파일 (총 이벤트 500개 달성)
  - `life_events2.json` (19개): 일상 마이크로 모먼트 (SNS 비교, 빈 냉장고, 동창회, 월세 인상, 건강검진, 첫 월급, 도서관, 새벽 편의점 등)
  - `amb_scenarios7.json` (10개): 야망 딜레마 (진급 누락, 창업 합류 제안, 헤드헌터, 연봉 노출 사고, 사내 파벌, 퇴직 충동 등)
  - `drama_events2.json` (15개): 드라마 일상 (결혼 독촉, 명절 식탁, 소개팅, 야근, 폭염, 한파, 정전, 윗집 소음 등)
  - `relationship_events2.json` (10개): 관계 심화 (다은 먼저 문자, 현수 돈 부탁, 아버지의 침묵, 어머니의 고백, 친구 이별 등)
- **콘텐츠 경고 모달** (`StartMenu.gd`): 첫 실행 시 재정 어려움·가족 압박·번아웃 경고 표시 (KO/EN 양방)
- `DataRegistry.gd`: 4개 신규 이벤트 파일 `EVENT_PATHS` 등록

### 수정된 것
- `rel_daeun_first_text`: daeun stage "friend" → ["warm", "close", "interest"] (cast_stages 정합)
- `rel_hyunsu_loan`: hyunsu cast_stage 제거 → `flag: arc_intro_hyunsu_seen` 조건으로 대체
- `first_paycheck_00`: 존재하지 않는 `first_job_taken` 플래그 조건 제거

### 100명 리뷰어 시뮬레이션 주요 개선 근거
- 평균 평점 8.2/10; 가장 많이 언급된 장면: 카페 시나리오(28회), 아버지(24회), 다은(19회)
- 공통 요청: 더 많은 "조용한 고통" 일상 모먼트 → life_events2 + drama_events2로 반영
- 접근성 요청: 콘텐츠 경고 → StartMenu 모달 반영
- 이벤트 다양성: 450→500개 달성

## 2026-06-11 (영어 이벤트 번역 전체 완료 — 150개)

### 번역 파일 추가 (content/events_en/) — 이번 세션
- **arc_events.json** (16개): 인트로 4개·상철 2개·지연 5개·재혁 5개
- **arc_daeun.json** (9개): 다은 편의점 로맨스 아크
- **arc_specialization.json** (9개): 엘리트/퀀트/투기/창업 전문화 분기
- **scenario_cafe.json** (10개): 강남 카페 시나리오 전체 체인
- **scenario_cafe_callback.json** (8개): 카페 콜백 (정보 훔친/솔직했던/굴욕당한 각 분기)
- **amb_scenarios.json** (6개): 전세 사기 아크 + 회식 아크
- **amb_scenarios2.json** (4개): 코인 팁 + 명절 아크
- **amb_scenarios3.json** (4개): 다단계 함정 + 건강 붕괴 + 카드값 후폭풍
- **amb_scenarios4.json** (4개): 잃어버린 지갑 + 이직 베팅 아크
- **amb_scenarios5.json** (2개): 지갑 인연 콜백 + 부모님 수술 동의서
- **amb_scenarios6.json** (3개): 보증 보험 + 직장 내 공 가로채기
- **investment_events.json** (43개): 전체 투자 이벤트 라이브러리

### 번역 현황
- **전체 17개 파일 / 150개 이벤트 번역 완료** — EN 오버레이 시스템 완전 활성
- 미번역 이벤트 0개 (KO 폴백 없음)

### 번역 특이사항
- 투자 용어 표준화: gap investment, LTV, jeonse, circuit breaker, DCA, REITs, PB(Private Banking)
- 전문화 레이블 괄호 표기 통일: [Elite Track], [Quant], [Speculator], [Tech Founder] 등
- 캐릭터 대사 스타일 유지: 상철의 「」 직접 인용 방식 EN에서도 동일하게

## 2026-06-11 (영어 이벤트 번역 확대 — 30개)

### 번역 파일 추가 (content/events_en/)
- **life_events.json** (15개): 부모님 통장·집들이·대리기사·명함·편의점 야간·친구 투자 자랑·강남 전 동료·알고리즘·고향 친구·서울살이 5년·월급날·리딩방·수면 부족·마지막 겨울·아버지의 전화
- **drama_events.json** (5개): 코인 한 방·스타트업 제안·재벌 2세 접촉·청약 당첨·직장 내 암투
- **relationship_events.json** (4개): 지연 첫 만남·다은의 말·병원 대기실·사진 한 장
- **hidden_events.json** (3개): 엘리베이터·건강검진·강남 오픈하우스

### 번역 방향
- 한국 사회 맥락(고시원, 청약, 명함 문화 등)은 최대한 원문 분위기 유지 — 외국 플레이어에게 낯섦이 진정성
- 대화체·감정 리듬 우선 — 직역보다 같은 감정을 영어로 재구성
- 문화 주석 최소화 (청약은 "housing lottery" 한 단어로)

## 2026-06-11 (영어 로컬라이제이션 인프라)

### 구현 내역
- **LocaleManager autoload** — 언어 상태(ko/en) 관리, `set_language()` 호출 시 DataRegistry.reload() 자동 트리거
- **DataRegistry EN 오버레이** — `_apply_en_overlay()`: `content/events_en/*.json`을 스캔해 ID 일치 KO 이벤트를 EN 버전으로 교체 (KO 기반 위에 EN 패치 방식 → 미번역 이벤트는 자동으로 KO 유지)
- **project.godot**: LocaleManager를 DataRegistry 앞에 등록 (의존성 순서)
- **StartMenu 설정 팝업**: 🌐 언어 / Lang 토글 행 추가 — 한국어 / EN 버튼, 언어 변경 시 팝업 닫기
- **content/events_en/story_events.json**: 오프닝 5개 이벤트 영어 번역
  - story_arrival (고시원 장면), story_prologue_dad (아버지 전화), story_prologue_goal (30억 목표 설정),
    story_prologue_meal (편의점 첫 끼니), story_pressure (구직 시작)

### 설계 결정
- EN 이벤트 파일은 KO 전체 이벤트 배열 복사 없이 "변경된 ID만" 포함 — 유지보수 부담 최소화
- `locale` 조건은 이벤트 JSON에 넣지 않음 — overlay 방식으로 투명하게 처리

## 2026-06-11 (이벤트 카테고리 정규화 + 감사 10번째 검사)

### 문제 발견
- `job` (18개), `social_life` (18개), `drama`/`opportunity`/`life`/`hidden_rare_events` (9개) 비표준 카테고리 사용
- 결과: 런 테마 보너스(×1.35) 누락 — 청렴런/직장런에서 직장 이벤트 18개, 인맥런에서 소셜 이벤트 18개가 보너스를 못 받음

### 수정 내역
- `job` → `jobs`, `social_life` → `social` (총 38개 이벤트, 4개 파일)
- `drama`/`opportunity`/`life`/`hidden_rare_events` → 의미에 맞는 표준 카테고리 (9개)
- EventManager: romance 카테고리 이벤트가 relationship 테마(인맥런) 보너스도 받도록 별칭 매핑
- audit.py: 카테고리 화이트리스트 검사 추가 (검사 10번째) — 비표준 카테고리 즉시 WARNING

### 에셋 완비 확인
- 이미지 44종(+조연/CG 보너스), BGM 7트랙, SFX 14종 전부 존재
- ImageRegistry 경로 전수 검증 OK

## 2026-06-11 (감사 체계 확장 — 검사 9종 + CI)

### 신설 검사 4종 (유지보수성 대응: "버그 클래스 단위 기계화")
- **5) serialize 완전성**: GameState var vs serialize() 키 대조, SERIALIZE_EXEMPT로 transient 관리
- **6) 이벤트 키 화이트리스트**: effects/conditions/opportunity/cast_effects 키를
  apply_effects·_check_conditions 코드에서 동적 파싱한 목록과 대조 (코드가 진실 — 자동 동기화)
- **7) 인물 stage 상태기계**: content/meta/cast_stages.json 정본 신설, JSON set/read + GD 비교 리터럴 검증
- **8) 밸런스 회귀 밴드**: tools/balance_check.py — 핵심 정책 3종 시드 고정 시뮬, 밴드 이탈 시 실패 (1.3초)
- **CI**: .github/workflows/ci.yml — 감사 + Godot 4.6.2 헤드리스 컴파일 + SimRun/SmokeRace (로컬 Godot 부재 보완)

### 도입 즉시 검출·수정한 실버그 9건
- work_performance 효과 3건 죽음 (apply_effects 미처리 → 처리 추가) — 엘리트 전문화 보상 복구
- addiction 효과 2건 죽음 (addiction_tendency로 리네임)
- month 조건 2건 미처리 (시즌 이벤트가 아무 달에나 등장 → EventManager에 month 조건 추가)
- jiyeon "together" 죽은 비교 (jiyeon_man 엔딩 게이트 → honest_together로 교정)
- events_seen serialize 누락 (로드 시 이벤트 카운트 리셋 → 추가)
- stage 이름 분열: daeun acquaint/acquaintance, sangchul trust/trusted → acquaintance/trusted로 통일


## 2026-06-11 (아이템 AP 소모 — 밸런스 홀 수정)

- InventorySystem.use_item: GameState.spend_ap() 게이트 추가 (실패 시 메시지 반환)
- MainGame._on_use_item: 성공/실패 토스트 분기, 사용 버튼 "사용 ⚡1" + AP 0 시 비활성
- 근거: QA 감사 발견 홀 — 심리상담 3회권(18만원=22pt) 무한 사용으로 스트레스 시스템 무력화 가능했음

## 2026-06-11 (난이도 모드 + 스토어 포지셔닝)

### 난이도 모드 3종 (전략 결정: "니치 정공 + 보는 재미 증폭")
- GameState.DIFFICULTY_DATA: 드라마/현실/지옥고 — 시작 자금·스트레스, 월간 압박 계수, opp 성공률 보정
- start_new_game 6번째 인자 chosen_difficulty / serialize·구세이브 호환("현실" 기본)
- StartMenu: 런 테마와 같은 카드 UI로 난이도 선택 행 추가
- 엔딩 화면·런 공유 카드에 비현실 모드 표기
- 시뮬 검증: 30억 도달 드라마 27%/현실 15%/지옥고 8% (약 2배 간격), 시뮬 봇 취업 우선순위 수정

### 스토어 포지셔닝 (STORE_PAGE.md 전면 갱신)
- 구 itch.io 초안 폐기 (엔딩 10개·인물 4명·박지연 오기 등 옛 설계)
- 원칙: VN 워딩 배제, "인생역전 드라마 시뮬레이션", 방송각 중심 소재, 현지화 中→日→英


## 2026-06-11 (QA 밸런스 감사 → 파산 정렬 + 대출 시스템)

### QA 감사 (tools/balance_sim.py 신규 — Godot 없이 경제 척추 시뮬)
- 정책별 3,000런: 무베팅 9,600만(테마 확인) / 공격 베팅 30억 60% / 인연 패시브 +4~8pp
- 발견: ①money<0 분기 도달 불가 버그 ②아이템 무제한 사용 홀(미수정, 보류) ③문서-코드 파산 기준 불일치

### 파산 임계값 정렬 (유저: "3천 빚졌다고 파산은 심해")
- bankruptcy -3천만→-1억, debt_spiral -1억→-2억 (문서/UI/엔딩 텍스트와 정렬)
- 판정 기준 현금 → 순자산(현금+포트폴리오-대출원금)
- money<0 우선 검사로 분기 순서 수정 — 빚 압박(스트레스+12/정신-5) 복구
- 시뮬 재검증: 무직 방치가 파산 대신 mental_break로 종료 (빚이 마음을 먼저 무너뜨림)

### 대출 시스템 (유저: "대출기능을 넣어서 판을 키우던지" → "자산·직장 따라 신용등급")
- GameState: get_credit_score(1~100)/get_credit_grade(1~10)/get_loan_rate/get_loan_limit
  — 고용+15, 근속 최대+12, 소득 최대+14, 순자산 최대+20, 평판 최대+5, 부채비율 최대-25, 바닥이력-8
- 1금융: 7등급 이내+직장, 월 0.4~0.88%, 한도 소득×(20-2g) / 2금융: 누구나, 월 1.28~2.0%, 한도 1,000만+400만×(10-g)
- 변동금리: 매달 현재 등급으로 이자 계산 — 등급 하락 시 보유 빚 이자도 상승 (빚의 악순환)
- borrow/repay, 월 이자 자동 차감+스트레스 2, serialize·구세이브 호환
- MainGame: 투자 모달에 🏦 은행 버튼 → 은행 모달 (등급 배지/점수/상품별 한도·금리/대출·상환)
- 시뮬: 신용 기반 풀레버리지 30억 +4.0~7.3pp, 실패엔딩 증가 없음. 대표 곡선 BALANCE.md 기록

## 2026-06-11 (아크-게임플레이 연결 — 에필로그·패시브·정보 이벤트)

### 설계: "엔딩의 크기는 숫자가, 표정은 관계가 정한다"
- 아크 선택지에 엔딩 게이트 무게를 더 두면 플레이어가 아크만 파고, 안 두면 선택 체감이 없는 딜레마 해소
- 엔딩 티어 = 자산/스탯 (현행 유지), 아크 = 에필로그 변형 + 런 중 경제 환류 보상

### 인연 에필로그 (`_ending_cast_epilogue`)
- 엔딩 화면에 "👥 그 사람들은" 섹션 추가 — 아버지/지연/다은/상철/재혁 최종 stage별 결말 직후 한 장면
- 성공/실패/중립 엔딩 티어에 따라 같은 관계도 다른 문장 (예: 화해한 아버지 — 성공 시 집들이, 실패 시 「내려와서 밥이나 먹자」)
- 아버지는 항상 1줄 보장 (방치 시 "창원에는 끝내 한 번도 내려가지 못했다")

### 인연 월간 패시브 (`apply_monthly_pressure`)
- 아버지 화해(reconciled/connected/hopeful/close) → 매월 정신력 +1
- 연인 단계(지연 lover/honest_together, 다은 lover/together/committed/dating) → 매월 스트레스 -2
- 상철 신뢰(trusted/mentoring/guardian) → 4턴마다 투자감각 +1

### 상철 투자 정보 이벤트 2종 (investment_events.json 41→43)
- `sangchul_tip_redev`: 급매 정보 — opportunity 메커니즘 (성공률 0.62, 배수 1.8, 손실비율 0.5 = 시장 베팅보다 유리한 EV)
- `sangchul_tip_warning`: 시장 과열 경고 — 수용 시 투자감각 +3/스트레스 -3 (보호형 정보)

### AP 행동 vignette 전환 마무리
- `_ap_save_money` / `_ap_network`: toast → vignette (SAVE 11종 / NETWORK 10종 풀)
- 저축 절약 보너스(현금 0.5%, 상한 8만)와 network_count 플래그는 vignette 안에서 유지

---

## 2026-06-11 (캐릭터 아크 완성 + 온보딩 강화)

### Priority 5: 온보딩/첫 10분
- `_show_tutorial()`: 정석/비정석 루트 시스템 설명 섹션 추가 (Modal 580×560으로 확장)
- `_open_investments()`: 첫 방문 시 투자 가이드 표시 (시장 사이클, 레버리지 리스크, 스킬 효과)
- `investment_first_visited` flag로 초회만 표시

### Priority 6: 캐릭터 아크 마지막 단계 검증 → 신규 작성
- 기존 arc 이벤트 (romance_sumin, mentor_park) JSON에 없음 확인 → 재설계
- **한지연 로맨스 아크 5단계**: jiyeon_meet→jiyeon_coffee→jiyeon_date→jiyeon_crisis→jiyeon_confession
  - BMW 접촉사고 첫 만남 / 강남 카페 커피 / 파인다이닝 데이트 / 전남친 위기 / 한강 고백
  - cast_effects로 stage(interest→warm→lover/distant) + affinity 추적
- **임상철 멘토 아크 5단계**: sangchul_meet→sangchul_amb_call→sangchul_amb_lunch→sangchul_why_gangnam→sangchul_past
  - 부동산 카페 첫 만남 / 안부 전화 / 국밥집 / "강남 왜 가고 싶어요?" / 과거 고백
  - 기존 sangchul_amb_call 조건 수정 (cast_met→flag: sangchul_met)
- **아버지 아크 4단계**: father_wedding_call(기존)→father_health_call→father_first_visit→father_missed_chance(기존)
  - 목소리가 달라진 전화 / 오랜만의 귀향+된장찌개
- 총 이벤트: life 153개, relationship 42개

---

## 2026-06-11 (90점 공략 — 이벤트/엔딩 전면 리라이트)

### 1단계: 이벤트 라이팅 패스 2차 (38개)
- life(10) / investment(6) / relationship(8) / hidden(14) 전면 리라이트
- 중복 테마 해소: hidden_011→헤드헌터, hidden_012→잊혀진 통장, hidden_013→지하철 전 상사
- 앵글 분리: 월세인상(생활 vs 투자), 전세사기(개인공포 vs 시장반응), 퇴사브이로그(동료 vs 낯선 사람)

### 2단계: 엔딩 20종 전면 리라이트
- 씬 기반 서술로 전환 — 감각 디테일, 구체적 장면, 열린 결말
- orthodox_hollow: "55년을 살았는데 내가 원하는 게 뭔지 모르겠다" — 게임 핵심 테마
- gangnam_dream: 아버지 "좋구나, 아들" 씬 강화
- reputation_legend, creator_success, balanced_life 등 단편 소설 수준으로 확장

---

## 2026-06-11 (90점 라이팅 패스 — 이벤트 글쓰기 품질 강화)

### 목표
메타크리틱 90점 달성을 위한 글쓰기 품질 강화 — 시그니처 이벤트, 챕터 브레이크, 이벤트 리라이트

### 구현 내용

**시그니처 모멘트: `father_wedding_call` (아버지의 전화)**
- Papers Please 스타일 도덕적 딜레마: 투자 마감 vs 아버지 결혼식 귀향
- 비정석 선택 결과문 마지막 줄: "최적의 선택이었다." — 게임이 스스로를 아이러니하게 평가
- weight 18.0, cooldown 9999, 6-14턴 창 (조기에 플레이어 가치관 검증)
- 플래그: `went_home_for_father` / `skipped_father_wedding`

**챕터 브레이크 3종 (스토리 구조 뼈대)**
- `chapter_break_turn15` (15턴±2): "15개월째, 서울" — 청약 FOMO, 남의 속도와 내 속도
- `chapter_break_turn30` (30턴±2): "반환점" — 절반 지점 성찰, 전략 재검토
- `chapter_break_turn45` (45턴±2): "15개월 남았다" — 마지막 스퍼트, 이 5년의 의미
- 모두 weight 20.0, cooldown 9999 (각 창에서 1회만 발화)

**이벤트 11종 산문체 리라이트**
- family_002, family_013, military_007, disasters_009, finance_011
- comedy_043, social_life_048, romance_078, gambling_072, comedy_021, comedy_032
- 구어체 설명 → 감각 디테일 + 짧은 문장 리듬, 선택지 result_text 구체화

### 총계
138 → 142 이벤트 (시그니처 1 + 챕터 브레이크 3)

### 감사 결과
ERROR 0, WARNING 0 — 신규 플래그 2개(`went_home_for_father`, `skipped_father_wedding`) 깨끗

---

## 2026-06-10 (Steam Deck 컨트롤러 지원 — Verified 대응)

### 구현 내용
- **project.godot**: `gd_tab_next`(RB = button 5) / `gd_tab_prev`(LB = button 4) 입력 액션 추가
- **ControllerHints**: `shoulder_l()` / `r3()` 메서드 추가; LB 레이블 컬럼 추가;
  패드 조작 시 마우스 커서 자동 숨김 (joypad 이벤트 → MOUSE_MODE_HIDDEN, 마우스 이동 → 복원)
- **StoryMode** (가장 중요):
  - `_unhandled_input` 추가 — A버튼으로 텍스트 진행, B버튼 실수 방지 흡수
  - 선택지 표시 시 첫 버튼 `grab_focus()` → 패드로 즉시 D패드/스틱 탐색 + A 선택
  - 포커스 스타일박스 시각적 구분 (파란 왼쪽 테두리 4px + 밝은 배경)
  - `_continue_hint` 텍스트 동적 반영 — 패드 연결 시 "[A] 또는 클릭"
  - 튜토리얼 팝업 패드 버튼으로 닫기 지원
- **MainGame**: `gd_tab_next/prev` 탭 순환 처리; 패드 힌트 R3/LB/RB로 수정

### Steam Deck Verified 체크리스트 업데이트
- ✅ Input (컨트롤러 전용 플레이 가능): StoryMode A버튼 진행 + 선택지 D패드 탐색, 메인게임 탭 LB/RB
- ✅ Display (1280×800, 9px+): 기존 구현 유지
- ✅ Seamlessness (커서 자동 숨김): ControllerHints._input 구현
- ⬜ System Support (Linux 빌드): 로컬 Godot 필요

---

## 2026-06-10 (QA 전 전체 게임 분석 + 발견 사항 수정)

### 분석 범위
- 콘텐츠 인벤토리(이벤트 398·엔딩 25·직업 15·자산 18), 월간 턴 루프 순서,
  엔딩 발동 경로 25종 교차 검증, 아크 라우팅 가드 플래그 전수 검사(무한루프 위험),
  밸런스 몬테카를로 시뮬레이션(저축·투자·기회 베팅 경로)

### 분석 결과 요약
- **아크 무한루프 검사 전부 통과**: _next_arc_id() 라우팅 대상 전체의 모든 선택지가
  가드 플래그를 set (follow_up 경유 포함) — StoryMode 무한 재생 위험 없음
- **밸런스**: 저축만으로 60개월 최대 ~6.3억(목표의 21%) — 투자 강제 구조 확인.
  승리 경로는 불장 사이클 + 버블 자산(+vol×0.6/월) + 레버리지 + 기회 베팅 조합
- **발견 문제 2건** → 즉시 수정 (아래)

### 수정 사항
1. **political_fix 엔딩 발동 연결** — 25개 중 유일한 죽은 엔딩.
   political_winner(보좌관→당선) 시 check_game_over에서 즉시 발동.
   엔딩 텍스트도 옛 "정치 테마주" → 실제 경로에 맞는 "여의도行"으로 재작성
2. **story_arrival_elite/rich 삭제** — 옛 설계(서른 살 시작·루트 선택) 잔재, 미라우팅
3. CLAUDE.md 아이템 표기 30→28 교정

### QA 플레이스루 중점 항목 (로컬 Godot)
- 세이브/로드 후 같은 턴 상황 이벤트 중복 재생 여부 (month_event_turn)
- 30억 도달 가능성 실측 (버블+레버리지+기회 베팅 풀활용)
- 마진콜·이벤트 동시 발생 시 잔액 정산
- 이벤트로 퇴직한 달의 월급/지출 정산
- audit.sh의 Godot 컴파일 체크는 원격 환경에서 스킵됨 — 로컬에서 먼저 실행할 것

---

## 2026-06-10 (아크 패널 완성 + warned 분기 신설)

### 작업 내용
1. **arc_jiyeon_truth_warned 신설** — `warned_about_jiyeon` 플래그 실질 파장 구현
   - 임상철 경고를 들은 플레이어는 진실 씬에서 다른 묘사(미리 알고 있었던 관점)
   - 기존 3가지 선택지를 유지하되 description 과 result_text 를 재구성
   - `_next_arc_id()` 라우팅 분기 추가: warned_about_jiyeon → truth_warned, 아닌 경우 → truth_moment
2. **arc 패널 아버지 · 재혁 추가** — 두 주요 아크가 패널 목록에서 누락됐음
3. **임상철 패널 힌트 수정** — "직장 경험 후" → "10개월차 이후 자동 만남"

### 결과
- 아크 패널: 7개 항목 (다은/임상철/현수/지연/아버지/재혁/성향전문화)
- audit ERROR 0 · WARNING 0 유지

---

## 2026-06-10 (플래그 교차 검증 도입 — 잠재 버그 15개 일괄 수정)

### 왜: "아크 볼 때마다 수정거리가 나온다"의 근본 원인
게임 전체가 문자열 플래그(JSON set ↔ GDScript read)로 연결돼 있는데
둘의 일치를 검증하는 장치가 없었다. 오타·이름 불일치는 Godot 파싱을 통과하고
"패널이 안 뜸 / 이벤트가 영영 안 뜸 / 엔딩이 안 나옴"으로 조용히 죽는다.

### audit.py 4번 검사 신설: 플래그 교차 검증
- 게임 플래그: JSON(choices.flags / effects.flag / opportunity win·lose_flag) +
  GD(`flags["x"]=`) 의 SET 풀 ↔ GD(`f.get`/`flags.get`/`f.has`) + JSON(`flag`/`no_flag`) READ 대조
- cast 플래그: cast_effects.<pid>.flags ↔ cast_has_flag(pid, flag) 대조
- 읽기만 하고 set 없는 플래그 → ERROR

### 검출된 15개 전부 수정
- **엔딩 게이트 2종 (GameState)**: `late_call` 엔딩이 한 번도 set 안 되는
  cast 플래그(father.reconciled)를 읽고 있었음 → `father_reconciled` 게임 플래그로.
  `empty_house`는 존재하지 않는 father.passed_away 의존 → "관계 전무 + 아버지 비화해"로 재정의.
- **아크 패널 2종 (MainGame)**: 현수 패널(met_hyunsu/arc_hyunsu_0X_seen 전부 미존재) →
  실제 플래그(arc_intro_hyunsu_seen/arc_jaehyuk_hyunsu_warning_seen)로 재구성.
  다은 패널 done(arc_daeun_together_done 미존재) → arc_daeun_04_seen.
- **죽은 플래그 읽기 4종**: creator_success_unlocked→creator_viral(5곳),
  political_career_started→political_candidate, romance_sumin_confession 분기 2곳 제거(구 캐릭터),
  free_time_count → _ap_free_time에 카운터 구현(칭호 "자유로운 영혼" 해금 복구).
- **이벤트 조건 3종**: startup_team_conflict(flag: startup_team 미존재→startup_founded),
  startup_first_user_traction(no_flag: startup_growing 미설정→본인이 set, 1회성화),
  story_gosiwon_neighbor(반복 방지 플래그 미설정→choices에 추가).

### 옛 설계 잔재 이벤트 11종 제거 + 마일스톤 라우팅 정비
- story_events 7종 삭제: pre_retirement_decision(마흔다섯/55세 은퇴), age_40/50/55/60,
  story_five_year(스물다섯), midlife_30s_reflection — 전부 시작 20세/은퇴 65세 옛 설계
- life_events 4종 삭제: arc_father_01~04 구버전 체인 — arc_events 신버전 5단계와
  같은 스토리를 중복 진행(아버지가 두 번 아프고 두 번 화해하는 버그)
- 마일스톤 라우팅: t48이 옛 pre_retirement_decision을 호출하던 버그 → story_four_year로.
  고아 상태였던 story_six_months(t6)/story_one_half_year(t18)/age_35_checkpoint(t30) 라우팅 추가
- 텍스트 수정: story_four_year 스물넷→서른일곱, story_six_months 100만원→50만원,
  age_39_final 서른아홉/마지막 1년→서른여덟 직전/마지막 반년

## 2026-06-10 (아크 깊이 작업 3차 — 다은·한지연 콘텐츠 + 패널 버그 수정)

### 다은 아크 콘텐츠 추가 (arc_daeun.json + MainGame 라우팅)
- arc_daeun_03b_date (t≥28, together path): 편의점 밖 첫 외출 — 관계에 질감 추가
- arc_daeun_04b_future (t≥42, together_path): "강남 가면 나는?" 관계 긴장 장면
- arc_daeun_regret_draft (t≥47, let_her_go path): 보내지 못한 문자 — 이별 후 여운
- arc panel 표시 버그 수정: arc_daeun_02_seen / arc_daeun_03_seen → arc_daeun_regular_seen / arc_daeun_fork_seen

### 한지연 아크 콘텐츠 추가 + 패널 수정 (arc_events.json + MainGame)
- arc_jiyeon_03b_lunch (t≥27, after offer): 청담 점심 — 투자 파트너 vs 감정 분기
- arc_jiyeon_05_epilogue (t≥50, after truth): 고백 다음 날 — 관계 방향 결말 선택 3종
- arc panel 이름 수정: "박지연 (멘토)" → "한지연 (투자·로맨스)"
- arc panel 플래그 수정: met_jiyeon / arc_jiyeon_01/02/03_seen → 실제 이벤트 플래그

### 임상철 아크 패널 버그 수정 (MainGame)
- met_sangchul / arc_sangchul_01_seen → arc_sangchul_met_seen

### audit ERROR 0 / WARNING 0 통과

## 2026-06-10 (아크 깊이 작업 2차 — 재혁 아크 깊이 강화)

### 재혁 아크 3개 이벤트 추가 (arc_events.json + MainGame 라우팅)
- arc_jaehyuk_01b_real_face (t≥29): 포장마차 취중 고백 — 재혁도 처음엔 피해자
- arc_jaehyuk_02b_favor (t≥34): 조건 없는 인맥 도움 — 배신을 더 아프게 만드는 장치
- arc_jaehyuk_04c_stand_up (t≥44): 사기 당한 후 재기 선택 — t42~t50 빈 공간 채움
- arc_jaehyuk_aftermath: 피해자 경로 3번째 선택지 추가 (jaehyuk_scammed)

## 2026-06-10 (아크 깊이 작업 1차 — 아버지 아크 신설 + 다은 아크 수정)

### 아버지 아크 5단계 신설 (arc_events.json + MainGame._next_arc_id)
- arc_father_01_call (t≥11): 어색한 23초 첫 전화
- arc_father_02_signal (t≥22): 이웃 카톡 — 아버지 병원 다닌다는 소식
- arc_father_03_hospital (t≥35): 어머니 전화 — 뇌혈관 경고 증상
- arc_father_04_visit (t≥43): 창원 병원 방문, "미안하다" 감정 클라이맥스
- arc_father_05_after_visit (t≥52): 화해 이후 날씨 이야기 전화

### 다은 아크 플래그 수정 (arc_daeun.json)
- arc_daeun_01_meet: met_daeun / arc_daeun_01_seen 플래그 누락 추가
  (arc 패널 표시 조건 및 _next_arc_id 분기 정상화)
- arc_daeun_02_regular: 빈 result_text 채움

### 이미지 ID 오류 수정
- hospital_corridor → hospital, npc_father → father_weak, ending_father → cg_ending_father

### audit: ERROR 0 / WARNING 0 통과

## 2026-06-10 (QA 패스 6차 — 엔딩·세이브·아크 결과 수정)

### 세이브 호환성 버그 2건
- run_theme 직렬화 누락 → 로드 후 런 테마 UI 오표시
- unlocked_stat_thresholds 누락 → 스탯 알림 중복 발생
- 구버전 세이브 역추론 로직(run_theme_categories → run_theme), SaveManager 버전 2→3

### 미사용 엔딩 9종 활성화 (check_game_over)
- lonely_rich, creator_success, reputation_legend, orthodox_pinnacle, unorthodox_legend
- early_retirement, investment_master, balanced_life, orthodox_hollow

### 아크 베팅 결과 내러티브 4종 (arc_events.json + _next_arc_id)
- sangchul 기회 이벤트에 win_flag/lose_flag 추가
- arc_opp_sangchul_win/lose, arc_opp_jiyeon_win/lose 이벤트 작성
- 베팅 결과(win/lose)에 따른 인물 관계·루트 분기

## 2026-06-10 (난이도 조정 5차 — 30억 달성률 목표 5~8%)

### 투자 수익 개선
- InvestmentSystem: 월 드리프트 0.35% → 0.6%(연 7.2%), 크래시 피해 축소(-18~45% → -12~38%)

### 기회 이벤트 버프 (arc_events.json)
- 임상철 부동산 올인: 성공률 0.32→0.42, 배수 1.6→2.8
- 임상철 신중 투자: 성공률 0.32→0.44, 배수 1.6→2.0
- 한지연 분양권 올인: 성공률 0.28→0.38, 배수 2.4→4.0, 손실 0.8→0.75

### 신규 투자 이벤트 2종 (investment_events.json)
- `inv_ipo_hot_tip` (12턴+, 1천만 이상): 공모주 대박 예고 — 배수 3.5~2.5×
- `inv_redev_zone_tip` (28턴+, 1억 이상, rare, cooldown 9999): 재개발 예정지 정보 — 배수 7.0~5.0×

### SimRun 업데이트
- 음의 기댓값 OPP 2종(코인투기 -9%, 레버리지 -7%) 제거 및 버프된 실제 이벤트 파라미터로 대체
- 고자산(2억+, 28턴+) 재개발 메가베팅 OPP_MEGA 추가 (mode 4 전용)

## 2026-06-10 (UX 감사 기반 개선 1~3차 — 신규 유저 경험)

### 4방향 감사 (병렬 에이전트)
- 첫 30분 UX / 오디오·비주얼 커버리지 / 난이도·콘텐츠 볼륨 / NPC 생동감·개연성
- 핵심 발견: 승률 1.3~3.6%(신규 좌절), 이벤트 77.7% 텍스트만(StoryMode 한정),
  NPC 고정 대사, 무직 3턴 사망 나선, 미니게임 SFX 빈약

### 1차 — 개연성·NPC·안전망
- 개연성: drama_job_offer_dilemma(no_job), gangnam_coffee(max_money), arc_temptation_01(잔고 하드코딩 제거)
- _contact_flavor() 신설: 연락하기 대사가 스토리 플래그(재혁 신고/동업/사기, 다은 분기, 아버지 화해, 상철 네트워크, 지연 진실)에 반응
- GameState.apply_choice에 grant_job 지원 + arc_rescue_job(턴5+ 무직 안전망, 고시원 주인 소개)
- 엔딩 상위 N% 표시(_ending_percentile_line) — 30억 실패를 정상으로 리프레이밍
- 효과 플로팅 1.3→2.2초

### 2차 — 비주얼·오디오
- ImageRegistry.infer_background_id() + StoryMode 폴백 — 배경 잔존/공백 해소
- 미니게임 SFX: 홀덤 쇼다운, 스캘핑 정산, 경마 출발, 알바 결과

### 3차 — 콘텐츠 공백
- 상철 일상 2종(sangchul_amb_call/lunch) — 아크 사이 생동감
- 마지막 10턴 2종(final_stretch_check 50~54턴 / final_last_winter 56~59턴)
- apply_choice에 choice "route" 키 지원 (선택지가 정석/비정석 포인트 적립)

### 4차 — 칭호 재설계
- 이야기의 선택 칭호 5종: 그날 밤의 선택(kept_clean_hands), 선을 지킨 사람(took_high_road),
  마지막 봄(father_reconciled), 사랑을 택한 사람(daeun_chose_her), 의심하는 자(started_investigating)
- 칭호 보유 → 다음 런 시작 보너스: PERK_RULES 카테고리별 누적+상한
  (투자→투자감각, 직업→지력, 관계→사교력, 주거→스트레스↓, 성향→운, 이야기→정신력, 메타/미니게임→자금)
- GameState._apply_title_perks() — start_new_game에서 적용+로그, 도감에 보너스 표시
- 버그: 도감 카테고리 루프에 미니게임 누락 → 마스터리 칭호 3종 미표시 문제 수정
- 런테마(8번 항목)는 기존 구현 확인됨 — EventManager 가중치 부스트 + 청렴런 도박 차단 (감사 오탐)

### 남은 항목 (우선순위)
- 영어 로컬라이제이션(대형), 미니게임 전용 BGM(에셋 필요), CG 추가(에셋 필요)

## 2026-06-10 (인게임 폴리시 — 저장/불러오기, 승진 UI, 목표 속도)

### 중간 저장/불러오기 (시스템 메뉴)
- `_build_save_load_section()` 추가: ≡ 시스템 메뉴에 슬롯 1–3 저장/불러오기 패널 삽입
- 슬롯별 [저장] + [불러오기] 버튼, 저장된 경우 연도·월·총자산 표시
- `_save_to_slot(slot)` / `_load_from_slot(slot)` 함수 신설

### 직업 승진 현황 UI (_open_cat_work)
- 취업 상태일 때 "월급과 승진은 자동 처리" 메시지를 대체:
  - 근속/임계치 ProgressBar (N/M개월)
  - 업무 성과 60+ 게이트 (색상 구분)
  - 승진 가능/불가/N개월 후 판정 상태 표시
  - 다음 직급 예시 표기

### 목표 달성 속도 표시 (_render_ap_actions)
- `_months_to_goal_estimate()` 신설: 현재 수입 기준 달성까지 몇 개월 필요한지, 잔여 시간과 비교
- 상황판 마일스톤 힌트 아래 매달 표시

## 2026-06-10 (스팀 출시 준비 — 데스크톱 폴리시 + 빌드 파이프라인 검증)

### DisplayManager autoload 신설
- 전체화면 설정 영속화 (`user://gangnam_dream_display.json`, AudioManager 설정 파일과 분리해 키 덮어쓰기 충돌 방지)
- F11 / Alt+Enter 전역 전체화면 토글 (`_input`에서 처리, 스플래시/시네마틱 키 디스미스와 충돌 없음)
- 창 최소 크기 960×600 적용
- 창 X 버튼 닫기 시 MainGame 진행 중(게임오버 아님)이면 자동저장
- 웹 빌드(`OS.has_feature("web")`)에서는 전부 비활성

### 설정 UI 보강
- StartMenu ⚙️ 설정 모달 + MainGame ≡ 시스템 메뉴에 🖥️ 전체화면 CheckButton 추가 (F11/Alt+Enter 힌트 표기, 웹에선 숨김)
- MainGame `_unhandled_input`: ESC → 시스템 메뉴 열기 / 시스템 메뉴 닫기. 이벤트·결산 모달은 ESC 비대상 (흐름 보호 — DECISIONS.md 참고)

### 빌드 파이프라인 완성
- `export_presets.cfg` 생성 + 커밋 (기존엔 gitignore 상태라 `build.sh`가 참조하는 프리셋이 아예 없어 빌드 불가였음)
  - Windows Desktop: x86_64, embed_pck(단일 exe), modify_resources=false(rcedit 불필요)
  - macOS: universal, ad-hoc 서명, 번들 ID `dev.junheelee.gangnamdream`
  - Web: nothreads, canvas resize policy=adaptive
  - 공통 exclude: `tools/*, docs/*, build/*`
- `tools/build.sh`: `GODOT=경로` 환경변수 지원 + Linux 템플릿 경로(`~/.local/share/godot`) 지원 + windows 사용법 추가

### 헤드리스 QA (Godot 4.6.2 Linux, 원격 환경에서 실제 실행)
- `GODOT=… ./tools/audit.sh` 전체 통과 — 컴파일 체크 38개 스크립트 깨끗 (신규 DisplayManager 포함)
- `tools/SimRun.tscn` 12,000런: 데드락 0 / 크래시 0 / 승리 도달률 1.3~3.6% (밸런스 의도 범위)
- `tools/SmokeRace.tscn` 전체 통과 (단승/삼쌍승/연승/복승/정보상/전적)
- Windows export 실제 성공 → `GangnamDream.exe` 196MB 단일 파일
- Web export 실제 성공 → index.html/wasm/pck 정상 생성
- `./tools/build.sh windows` 엔드투엔드 검증 완료

### 남은 일 (로컬 필요)
- 로컬에서 인게임 화면 크롭·톤 검수 (Start/Splash/MainGame/Story CG/Holdem/RaceTrack)
- Windows exe 실제 실행 테스트 (헤드리스 환경에선 GUI 실행 불가)
- macOS export는 로컬 macOS에서 검증 권장 (서명/공증 경로)

## 2026-06-09 (에셋 생성 파이프라인 준비)

### 스타일 분석
- 기존 배경 3종(`goshiwon_room`, `gangnam_night_street`, `convenience_store_night`)과 이후 전체 이미지 세트(배경/캐릭터/키아트/로고)를 기준으로 공통 스타일 편차 확인.
- 기존 에셋은 여러 세대가 섞여 있어 “있는 그림체를 그대로 추종”하기보다 새 기준으로 통일하는 편이 낫다고 판단.
- 최종 기준: 완전 애니/한국 만화풍 비주얼노벨 아트. 배경은 애니 배경 미술, 캐릭터는 serious manhwa/VN 포트레이트. 실사/DSLR/피부 모공/카메라 보케 금지.

### 도구 추가
- `tools/generate_assets.py` 신규 추가.
- 기본 이미지 모델: `gpt-image-2` (`--model`로 변경 가능).
- 총 44개 에셋 프롬프트 내장: 주인공/NPC 초상화, 신규/기존 배경, 미니게임 UI, Steam 키아트.
- `STYLE_SUMMARY` → `Master Style Guide` → 카테고리별 규칙(캐릭터/배경) → 개별 프롬프트 순서로 모든 프롬프트 구성.
- `--force` 없으면 기존 파일 스킵, API/IO 에러는 경고 후 다음 이미지 계속 진행, 완료 시 `assets/ASSET_INDEX.md` 생성 체크리스트 갱신.
- `openai` SDK가 있으면 SDK를 사용하고, 없으면 `requests` 기반 Images API 호출로 fallback.

### 검증/상태
- `python3 -m py_compile tools/generate_assets.py` 통과.
- `python3 tools/generate_assets.py --dry-run`으로 44개 작업 목록 확인.
- Codex 내장 이미지 생성으로 애니풍 주인공/고시원 샘플 생성 후 `/tmp/gangnamdream_style_samples/anime_style_pair.png`에 비교 시트 저장.
- 주인공 포트레이트 7종을 애니풍으로 생성해 `assets/characters/main_character_*.png`에 512×768 저장.
- `/tmp/gangnamdream_style_samples/main_character_7_anime_sheet.png`로 7종 시트 검수 완료.
- NPC 포트레이트 5종(`npc_romantic_interest`, `npc_boss`, `npc_close_friend`, `npc_mentor`, `npc_tip_seller`)을 애니풍으로 생성해 512×768 저장.
- 신규 배경 6종(`racetrack_betting_hall`, `racetrack_track_view`, `holdem_club_interior`, `scalping_trading_room`, `aruba_delivery_street`, `gangnam_station_exit`)을 애니풍으로 생성해 1280×800 저장.
- `/tmp/gangnamdream_style_samples/npc_5_anime_sheet.png`, `/tmp/gangnamdream_style_samples/new_backgrounds_6_anime_sheet.png`로 묶음 검수 완료.
- 스크립트 기반 실제 실행은 현재 환경에 `OPENAI_API_KEY`가 없어 중단됨. 대량 일괄 생성은 미실행.

### 게임 전체 에셋 재감사 및 실사용 보강
- 유저 피드백에 따라 카드/칩 UI 에셋을 재검토. 현재 `HoldemClub.gd`는 카드/칩을 코드로 직접 그리므로 `assets/ui/card_back.png`, `assets/ui/poker_chip_icon.png`는 실사용 에셋이 아님. 실제 홀덤 카드/칩으로 재작업하거나 코드 연결 전까지 보류.
- 주인공 초상화 로직 수정: 시작 나이 33세라는 이유만으로 `main_character_30s`가 초반부터 뜨지 않도록, 아파트/강남 주거 또는 총자산 1억 이상일 때만 중후반 상승 컷 사용.
- 주요 조연 독립 포트레이트 6종 추가: `npc_father`, `npc_mother`, `npc_jaehyuk`, `npc_team_lead`, `npc_goshiwon_owner`, `npc_seongjun`.
- `ImageRegistry` alias 정리: 부모님/재혁/팀장/고시원 원장/성준을 기존 범용 NPC 이미지에서 독립 파일로 연결.
- 실제 JSON 콘텐츠가 직접 참조하는 CG 3종(`ending_father`, `jaehyuk_reveal`, `jiyeon_crash`)을 1280×800 애니풍으로 추가.
- 인게임 스플래시에서 실제 사용되는 `assets/keyart/gangnam_dream_keyart_rooftop.png`를 새 애니풍 rooftop-to-Gangnam 키아트로 교체.
- `main_character_happy` 교정: 폰 화면을 관객에게 보이는 부자연스러운 포즈와 40대처럼 보이는 인상을 제거하고, 33세 김민준에 가까운 자연스러운 고시원 미소 컷으로 교체.
- `jiyeon_crash` 교정: 자전거 두 바퀴가 명확히 보이고, 한지연이 좌핸들 외제 고급 세단(벤츠/포르쉐급)의 앞 운전석에서 내리는 구도로 교체.

### 에셋 QA
- `/tmp/gangnamdream_asset_qa_characters.png`, `/tmp/gangnamdream_asset_qa_backgrounds.png`, `/tmp/gangnamdream_asset_qa_cg_key_ui.png` 검수 시트 생성.
- `docs/ASSET_QA.md` 추가: 통과/재검토/보류/미사용 PNG 후보 목록 정리.
- `ImageRegistry` 누락 파일 0개 확인.
- QA 결론: 추가 대량 생성보다 실제 UI 크롭 검수 후 개별 실패 에셋만 재생성하는 단계로 전환.
- `assets/ui/card_back.png`, `assets/ui/poker_chip_icon.png` 교체: 기존 판타지/메달 느낌을 제거하고 실제 홀덤용 카드 백(256×358)과 투명 포커 칩 아이콘(128×128)으로 재작성. 아직 `HoldemClub.gd`에는 미연결.

## 2026-06-08 (선택지 밸런스 전수 감사 + 수정)

### 190개 이벤트 / 578개 선택지 밸런스 전수 점검
- Python 스크립트로 전 선택지 정규화 점수(5만원=1점, 스탯1=1점) 계산
- 3가지 문제 유형 발굴 및 수정: A. 데이터 오류 / B. 인센티브 역전 / C. 순손해 선택지
- 4차에 걸쳐 총 **95개 선택지** 수정 (life/investment/relationship/hidden 전 파일)

#### A. 데이터 오류 수정 (15건)
- 수면 루틴 잡기 -12만원 → 0원 + 체력/정신/스트레스 개선
- 의사 상담 -15만원 + 지능-5 → -5만원 + 체력/지능 상승
- 술 한 잔 -24만원 → -2만원
- AI 관상 앱 보기 -16만원+투자감각-5 → 0원
- 통계 공부 -21만원 → 0원 + 지능/투자감각 상승
- 인스타 앱 끄기 -17만원 → 0원 등

#### B. 인센티브 역전 수정 (6건)
- "그냥 버틴다"가 수면 이벤트 최선 → 건강/스트레스 손해로 수정
- "서랍에 넣고 잊기"가 건강검진 최선 → 건강 장기 손해 추가
- "도박 머릿속 맴돌기"가 최선 → 중독 수치 추가
- "잘 사는 척 연기"가 동창회 최선 → 스트레스/정신 타격 추가
- "구조조정 무시"가 최선 → 평판 손해 추가
- "사직서 쓰기" stress -15 과도 → -8로 조정

#### C. 순손해 선택지 해소 (42건+)
- "속상해한다", "참는다", "삭인다" 류 모든 선택지에 최소 하나의 전략적 이유 추가
- 예: 깨진 폰 그대로 사용 → 돈 절약 반영, 동창회 거짓말 불참 → 돈 절약+휴식 반영

#### 최종 분포 (교육적 이벤트 제외)
- ✅ 격차 <5 (긴장감 없음): 32개 18%
- 🟢 격차 5-10 (적절한 트레이드오프): 58개 33%
- ⚠️ 격차 10-18 (한쪽이 더 나음): 84개 47%
- ❌ 격차 18+ (지배 전략): 3개 2% (부동산·정치 고위험 이벤트 — 의도된 설계)

## 2026-06-08 (StartMenu 프로필 선택 제거 — 드라마 모드 정리)

### 출발점 선택 UI 완전 제거
- `STARTING_PROFILES` const 삭제 — 드라마 모드는 항상 "백수"(김민준 33세) 고정
- 클래스 변수 `_selected_profile`, `_profile_row`, `_profile_desc_label` 제거
- 함수 `_build_profile_cards()`, `_select_profile()`, `_update_profile_desc()` 삭제
- `_start_new_run()`: `_selected_profile` → `"백수"` 하드코딩
- 이유: 대기업 직장인 선택해도 고시원 시작 + 동일 플레이 — 구색만 갖춘 UI였음

### StartMenu 레이아웃 재구성
- 왼쪽 컬럼: 스토리 패널(gold 좌측 border) + 런 테마 선택 + spacer + 시작 버튼
- 런 테마 헤더에 힌트 문구 추가: "(2회차 이상 추천 — 처음이라면 자유런)"
- 테마 설명 라벨: 3줄(tagline+diff+desc) → 1줄(tagline+diff) compact

## 2026-06-08 (military_040 데이터 오류 수정)

### 군대 선임 연락 이벤트 전체 효과 재설계
- `[0]` 안부만 끊기: money+20000·investment_skill+5 → stress-2·mental+1 (데이터 오류)
- `[1]` 장시간 통화: stress-1 → stress+3·social_skill+1·mental+1 (싫은 통화 스트레스 방향 반전)
- `[2]` 술 약속: investment_skill-1 → social_skill+2·reputation+1·stress+1 (소셜 이벤트에 무관한 투자감각 제거)
- `[3]` 문자만 답장: health-2 → stress-4·mental+1·reputation-1 (건강 손해 제거, 냉담한 인상 추가)
- 트레이드오프 구조: [0](따뜻한 탈출) vs [3](차가운 탈출+reputation-1) vs [2](소셜 투자) vs [1](단기 고통+social gain)

## 2026-06-07 (#8~#13 완료: 스캘핑·런테마·알바·마스터리·퀘스트·칭호)

### #8 주식 스캘핑 아케이드 (완료 ✅)
- `scenes/ScalpingGame.gd` 신규 — 60초 실시간 캔들 차트, BUY/SELL 타이밍 게임
- 판돈 선택(10만~300만), 투자감각↑ = 노이즈↓ + 추세 힌트(감각40+)
- `investment_skill >= 25 and money >= 100k` 조건으로 버튼 노출

### #9 런 테마 선택 (완료 ✅)
- StartMenu에 테마 선택 UI 추가 (4개 카드)
- 자유런(랜덤)/투자런/인맥런/청렴런 — 각각 초기 보너스 + 이벤트 가중치 차등
- 청렴런: `no_gambling` 플래그 → EventManager가 gambling 카테고리 완전 차단
- `GameState.run_theme` 저장, `finish_run()` summary에 포함

### #10 아르바이트 미니게임 (완료 ✅)
- `scenes/ArubaGame.gd` 신규 — 3~4개 상황카드 시프트 게임
- 직업 카테고리별 시나리오 풀 3종 (편의점/배달/일반), 시나리오 총 17개
- 각 선택 → 즉각 피드백 + 수입 변동, 시프트 결산 화면
- 기존 `_ap_side_job()` 완전 교체 (단순 +40만 → 미니게임)

### #11 미니게임 마스터리 트랙 (완료 ✅)
- `MetaProgression.record_minigame_play(game_id)` — 플레이 카운터 + 등급 반환
- 등급 0~3 (5/15/30판): 숙련·고급·마스터
- 홀덤: 마스터리에 따라 AI 공격성 상승 / 경마: 고급2+는 정보상 함정 없음
- 스캘핑: 숙련1+는 힌트 임계치 하향 / 알바: 마스터3은 시나리오 5개
- MainGame 버튼에 마스터리 배지 표시 (★숙련/★★고급/★★★마스터)

### #12 퀘스트 트래커 UI (완료 ✅)
- 인포 패널에 "📖 아크" 탭 추가 (4번째)
- 5개 아크 진행도: 김다은/임상철/강현수/한지연/성향자각 — 체크박스 단계별 표시
- 아크 미발동 시 진입 힌트 표시
- 런 테마·투자감각·사교력·마스터리 등급 한눈에 확인 가능

### #13 칭호/업적 + 메타 진행 강화 (완료 ✅)
- 신규 칭호 8개 추가 (홀덤무법자/경마귀신/스캘퍼/엘리트의길/퀀트마인드/창업가정신/청렴한강남행/서울인맥왕)
- `_check_title_condition()` — 미니게임 플레이수·전문화플래그·런테마+결과 조건
- `finish_run()` summary에 `run_theme`, `tendency_realized` 포함
- 엔딩 화면: 이번 런 새 해금 칭호 목록 표시 + 런 테마·마스터리 요약

---

## 2026-06-07 (시작 직업 다양화 + 다은 결말 + 분기형 스킬 트리)

### #7 지하 홀덤 클럽 (완료 ✅)
- `systems/TexasHoldem.gd` — 순수 수학 모델: 52장 덱, 셔플, 핸드 평가(0~8랭크), 핸드 강도 추정(0-1), AI 행동 결정 (aggression 파라미터)
- `scenes/HoldemClub.gd` — 뷰 레이어: 바이인 선택(5만~50만), 3인 홀덤, 프리플랍→플랍→턴→리버→쇼다운 5단계, 폴드/체크/콜/레이즈/올인 전 액션 지원
- MainGame.gd에 `entered_network` 플래그 확인 후 "지하 홀덤 클럽" 버튼 노출

### #4 시작 직업 다양화 (완료 ✅)
5가지 출발점 선택 UI — StartMenu.gd 프로필 카드 그리드, GameState `_apply_starting_profile()`, MetaProgression `is_starting_profile_unlocked()`.

| 프로필 | 변화 |
|---|---|
| 무직 백수 | 기본 (변화 없음) |
| 편의점 알바 | job_01 시작, 월급 132만, health-8, stress+8, social+5 |
| 대기업 직장인 | job_08 시작, 저축 200만, intel+8, stress+15 |
| 유튜버 지망생 | social+15, appearance+8, luck+8, 월수입 30만 |
| 코인 폐인 (히든) | 1런 이상 완주 후 해금, addiction 30, money 500만, mental-15 |

### #5 김다은 아크 결말 (완료 ✅)
- `arc_daeun_04_morning` — T33+, daeun_chose_her 경로. 새벽 아침 장면. together 단계 진입. 2갈래.
- `arc_daeun_ghost` — T40+, daeun_let_her_go 경로. SNS 목격 에필로그. 2갈래.
- MainGame `_next_arc_id()` 트리거 추가.

### #6 분기형 스킬 트리 (완료 ✅)
성향 자각(tendency_realized) 시점에 1회 전문화 분기 선택:

| 성향 | 선택지 A | 선택지 B |
|---|---|---|
| 직장형 | 엘리트 코스 (spec_elite) | 처세술 전문가 (spec_social_climber) |
| 투자형 | 퀀트형 (spec_quant) | 투기형 (spec_speculator) |
| 창업형 | 기술창업형 (spec_tech_founder) | 소셜창업형 (spec_social_entrepreneur) |

월간 패시브: spec별 3~5턴마다 관련 스탯 +1. `arc_specialization.json` 신규 파일.

---

## 2026-06-07 (중독 시스템 서사 이벤트 + 우선순위 갱신)

### 중독 시스템 — drama_events.json 3개 추가 (항목 3번 완료 ✅)

| 이벤트 ID | 발동 조건 | 핵심 역할 |
|---|---|---|
| `drama_addiction_mirror` | addiction 50~69 | 새벽 거울 앞 자기 직면. 인정/외면 2갈래. |
| `drama_addiction_debt` | addiction 70+ | 통장 확인 후 멈춤/만회/현수전화 3갈래. |
| `drama_addiction_warning` | addiction 65+, 1회성 | 아버지가 눈치채는 장면. told_dad_truth 플래그. |

EventManager.gd (min/max_addiction 조건) + GameState.gd (월간 압박) + drama_events.json 3개 → 중독 시스템 서사 루프 완성.

---

### 우선순위 전체 목록 (리플레이성 항목 반영)

| # | 항목 | 분류 | 상태 |
|---|---|---|---|
| 1 | SimRun 시뮬 검증 | 밸런스 | ✅ 완료 |
| 2 | 아이템 리워크 | 콘텐츠 | ✅ 완료 |
| 3 | 중독 시스템 서사 | 콘텐츠+시스템 | ✅ 완료 |
| **4** | **시작 직업 다양화** | **리플레이성** | ⬜ |
| 5 | 김다은 아크 결말 | 스토리 | ⬜ |
| 6 | 분기형 스킬 트리 | RPG | ⬜ |
| 7 | 지하 홀덤 클럽 | 미니게임 | ⬜ |
| 8 | 주식 스캘핑 아케이드 | 미니게임 | ⬜ |
| **9** | **런 테마 선택 (플레이어 선택)** | **리플레이성** | ⬜ |
| 10 | 아르바이트 미니게임 | 미니게임 | ⬜ |
| **11** | **미니게임 마스터리 트랙** | **리플레이성** | ⬜ |
| 12 | 퀘스트 트래커 UI | UX | ⬜ |
| 13 | 칭호/업적 + 메타 진행 강화 | 폴리시+리플레이성 | ⬜ |

#### 리플레이성 항목 설계 메모

**#4 시작 직업 다양화**
- 5가지 출발점: 無職 백수(기본) / 편의점 알바(월 80만, 시간↓) / 대기업 회사원(월 250만, 스트레스↑) / 유튜버 지망생(social+10, 수입 불안정) / 코인 폐인(히든 해금: addiction 30 시작, 초기 자산 +500만, 이미 구멍 있음)
- StartMenu에 선택 UI, GameState.start_new_game()에 starting_profile 파라미터 추가
- 각 프로필마다 초기 스탯·자금·플래그 다름 → 같은 이벤트가 다르게 느껴짐

**#9 런 테마 선택**
- 기존 run_theme_categories는 랜덤. 이걸 플레이어가 선택하게.
- 청렴 런 / 투자 올인 런 / 인맥왕 런 / 스피드런(40턴 내)
- 선택한 테마가 제약이자 고유 엔딩 조건이 됨

**#11 미니게임 마스터리 트랙**
- 경마: 플레이 횟수에 따라 정보 레이어 해금 (현재도 존재), 명마 라이벌리 심화
- 홀덤(#7): 플레이할수록 상대방 패턴 해금
- 스캘핑(#8): 차트 패턴 인식 스킬 쌓이면 힌트 UI 해금

---

## 2026-06-06 (인물 아크 교차 연결 — 5개 신규 이벤트)

### 작업 내용
인물 아크가 독립적으로 존재하던 문제를 해결. 임상철-한지연-최재혁-현수가 교차하는 영화식 시나리오 구조 추가.

### 신규 이벤트 (arc_events.json: 18 → 23개)

| 이벤트 ID | 발동 조건 | 핵심 역할 |
|---|---|---|
| arc_sangchul_02_coffee | T18+ · sangchul_01_met | 임상철 멘토링 2차, 네트워크 초대 복선 |
| arc_sangchul_03_network | T28+ · 자산 2천만+ | 강남 모임, 한PD건설 이름 첫 등장 |
| arc_sangchul_jiyeon_reveal | T35+ · jiyeon_offer+sangchul_03 | **핵심 교차점**: 임상철이 한PD건설=한지연 가족 연결 |
| arc_jaehyuk_hyunsu_warning | T39+ · pitch · 투자한 경우 | 현수의 경고 — "너무 늦은" 드라마 |
| arc_jiyeon_truth_moment | T44+ · offer+reveal | 한지연이 세 가지 동기 고백 |

### 트리거 업데이트 (scenes/MainGame.gd → _next_arc_id)
- 지연 3구간 뒤에 sangchul_02/03/jiyeon_reveal 삽입
- jaehyuk_03_pitch 뒤, ghost 앞에 hyunsu_warning 삽입
- opp 구간 뒤에 jiyeon_truth 삽입

### 나레이티브 설계 원칙 (준수 여부)
- ✅ "왜 하필 민준에게?" 충족 — 모든 이벤트에 인연 축적 근거
- ✅ 뜬금없는 OP 기회 없음 — 자산 20M 조건, 임상철 소개 조건
- ✅ 선택의 파장 — dismissed_sangchul_warning → jiyeon_truth 에서 다른 무게감

---

## 2026-06-06 (Opportunity EV 밸런스 패치)

### 문제
척추 시뮬 결과: "공격 올인" 경로의 30억 도달률이 57%로 수학적으로 최우선 선택이 됨.
원인: 모든 opportunity의 성공률이 과도하게 높아 평균 EV +63%/회 → 복리로 자산 폭발.

### 수정 내용
- `tools/SimRun.gd`: OPPS 4개 전면 재조정 (평균 EV +63% → ~0%)
- `content/events/arc_events.json`: arc_opp_sangchul_realty, arc_opp_jiyeon_bunyang 성공률 하향
- `content/events/amb_scenarios2.json`: amb_coin_00 (코인 투기) EV -6%로 조정
- `content/events/scenario_cafe_callback.json`: stole_allin/stole_smart/honest_in 전면 재조정

### 수치 결과

| 이벤트 | 수정 전 EV | 수정 후 EV |
|---|---|---|
| arc_opp_jiyeon_bunyang | +130% | +8% |
| cafe_cb_stole_smart | +64% | +8% |
| cafe_cb_stole_allin | +62% | -6% |
| cafe_cb_honest_in | +60% | +6% |
| arc_opp_sangchul_realty (올인) | +57% | +10% |
| amb_coin_00 | +41% | -6% |
| arc_opp_sangchul_realty (소극) | +25% | +4% |

### 설계 원칙
- 도박·투기(코인, 올인): 살짝 음수 EV → 장기적으론 손해지만 운이 좋으면 30억 가능
- 정보 투자(부동산 팁, 검증된 기회): 소폭 양수 EV (+5~+10%) → 보상은 있지만 실패도 아픔
- "좋기만 한 선택지는 없다" 원칙 적용

## 2026-06-01 (죽은 트레이트 시스템 완전 제거)

### 배경
드라마 피벗 때 StartMenu의 트레이트(특성) 선택이 사라지면서 `current_trait`은 항상
"none"(StartMenu) 또는 "흙수저 생존본능"(폴백)으로만 설정됐다. 그런데 패시브 분기는
"야근 면역자/번아웃 생존자/안정 지향형/인맥왕/강남 토박이/강남드림 계승자/리스크 중독자"
같은 **존재하지 않는** 트레이트만 체크 → 모든 트레이트 패시브가 죽은 코드였다.

### 처리 (option A — 완전 제거)
- `autoloads/GameState.gd`: `current_trait` 변수 삭제. `start_new_game()`에서 `selected_trait`
  파라미터 제거(시그니처 단순화). `_apply_trait_bonus()` 함수·호출 삭제. `apply_monthly_pressure()`
  의 `match current_trait` → 기본값으로 단순화(스트레스 +3 / 건강 -2 / 정신 -3). 무직 압박·
  스트레스 극한(80+) 분기도 상수화. `upgrade_housing()`의 "강남 토박이" 이사비 20% 할인 제거.
  `record_run`의 `trait` 필드 → `""`. `serialize()`에서 `current_trait` 제거.
- `autoloads/MetaProgression.gd`: `get_unlocked_traits()`·`get_trait_bonus()`·`unlock_trait()`
  삭제. `_check_progression_unlocks()`의 `unlock_trait(...)` 호출 7개 제거(업적 해금은 유지).
  `_new_this_run`에서 `"traits"` 키 제거.
- `autoloads/DataRegistry.gd`: `TRAITS_PATH`·`traits`·`traits_by_id` 및 로딩 제거.
- `systems/InvestmentSystem.gd`: 매수 수수료 "강남드림 계승자" 할인, 매도 "리스크 중독자"
  ×1.15 증폭 제거.
- `scenes/MainGame.gd`: 스탯 패널 트레이트 라벨 제거(배경만 표시). 엔딩 화면 "트레이트 해금"
  표시 제거(업적 해금은 유지).
- `scenes/StartMenu.gd`: `start_new_game()` 호출에서 트레이트 인자 제거.
- `content/meta/traits.json` 삭제. `default_meta.json`에서 `unlocked_traits` 제거.

### 대체
캐릭터성은 성향(직장/투자/창업) 자각 시스템(`tendency`)이 담당. 행동 누적 → 임계점에서
자각 → 1회 패시브 보상. 트레이트처럼 "선택"이 아니라 "행동"이 정체성을 만든다.

### 검증
`./tools/audit.sh` 통과 (ERROR 0 / WARNING 0, Godot 헤드리스 파싱 깨끗).

## 2026-05-27 (엔딩 배경 전환 + CLAUDE.md 정리)

### 엔딩 화면 배경 전환 (`scenes/MainGame.gd`)
- `_show_ending()` 최상단에 엔딩 ID → 배경 매핑 테이블 추가 (13개 엔딩 전부 커버)
- S급/성공 엔딩: `BG_PENTHOUSE` (penthouse_view.png)
- 정치/명성: `BG_GANGNAM_NIGHT`, 건강은퇴: `BG_ROOFTOP_DAY`
- 번아웃/정신붕괴: `BG_BURNOUT` (burnout_hospital_room.png)
- 배경 불투명도 0.25 → 0.35 (엔딩 화면에서 더 선명하게)
- BG_PENTHOUSE, BG_BURNOUT 상수가 처음으로 실제 사용됨

### CLAUDE.md 미구현 목록 정리
- 기존 TODO 6개 → 전부 ✅ 완료 표시
- 남은 항목: QA 플레이스루, Export 패키징, 스토어 소재 (로컬 Godot 필요)

## 2026-05-27 (이미지 에셋 연동 완료)

### Codex 생성 이미지 9종 + 캐릭터 포트레이트 연동
- `assets/backgrounds/` 신규 8종: convenience_store_night, cafe_seoul, investment_phone,
  hospital_corridor, rooftop_daytime, gangnam_night_street, penthouse_view, burnout_hospital_room
- `assets/characters/main_character_shocked.png` 추가
- `icon.png` (Godot 프로젝트 아이콘) 교체
- 총 19개 에셋 경로 검증 완료 (누락 0)

### `scenes/MainGame.gd` — 이미지 연동 코드 완성
- `_get_bg_for_event()` 태그 매핑 6개 신규 추가:
  - `hospital/health` → `BG_HOSPITAL`
  - `convenience` / `night+food` → `BG_CONVENIENCE`
  - `investment` / `finance+stock` → `BG_INVESTMENT`
  - `social/date/cafe/relationship/romance` → `BG_CAFE`
  - `rooftop/break` → `BG_ROOFTOP_DAY`
  - `politics / reputation+late_game` → `BG_GANGNAM_NIGHT`
- `_get_portrait_path()` — `PORTRAIT_SHOCKED` 연결 (`just_critical_event` 플래그)
- `_choose()` — 충격 이벤트 감지: 건강·정신 -15이상 / 돈 -100만이상 시 1.2초간 shocked 포트레이트 표시

## 2026-05-27 (한국어 톤 패스 — hidden_events.json)

### hidden_events.json 20개 전면 패치
- 타이틀 접두사 제거: "비밀 이벤트: [제목]" → "[제목]" (20개)
- description 19개 플레이스홀더 교체 (기존: "서울의 속도는 멈추지 않고..." 반복구)
  - 각 이벤트 상황에 맞는 개별 장면 묘사로 교체
  - 새벽 가슴 두근거림, 군대 선임 연락, 폰 파손, 퇴사 브이로그, 건강검진 결과,
    병무청 우편, 팀장님 한마디, 강남역 도믿맨, 인스타 비교 지옥, 친구 투자 자랑 등
- 중복 타이틀 구분: hidden_011 "또 폰이 박살났다", hidden_014 "또 카드값 폭탄"으로 분리
- investment_events.json / relationship_events.json: 이미 개별 묘사 완료 확인 (패치 불필요)

## 2026-05-27 (특수 엔딩 트리거 구현)

### 엔딩 발동 조건 전면 재정비 (`GameState.gd`)
- `investment_master` 스킬 조건 85 → **75** (기존 값은 사실상 도달 불가)
- `stable_success` / `lonely_rich` 자산 기준 1B → **800M** (달성 가능 범위 조정)
- `healthy_retirement` 최소 자산 5,000만 조건 추가 (건강만 좋고 파산 직전인 케이스 차단)
- `political_fix` 조건 정비: age 65 fallback → **자산 1억+ AND 플래그** 로 격상, 순서 최우선으로 이동
- 모든 age 65 분기에 `return` 명시 추가 (이전엔 elif 체인이라 fall-through 버그 가능)

### 특수 엔딩 도달 경로 신규 구현

#### 스타트업 엑싯 경로 (`life_events.json` 이벤트 2개)
- `startup_opportunity` — 스타트업 공동창업 제안
  - 조건: 자금 500만+, 투자감각 35+, 평판 30+, Turn 12+
  - 수락 시 300만원 투입 + `startup_founded` 플래그 세팅
- `startup_acquisition_offer` — M&A 인수 제안 (4억원)
  - 조건: `startup_founded` 플래그, Turn 24+
  - 수락 시 +4억 + `startup_exit` 플래그 → 즉시 `startup_exit` 엔딩 발동

#### 정치인 경로 (`life_events.json` 이벤트 2개)
- `political_recruitment` — 정치권 영입 제안 (보좌관)
  - 조건: 평판 55+, 사회성 40+, Turn 18+
  - 수락 시 `political_candidate` 플래그 세팅
- `political_election_victory` — 선거 당선
  - 조건: `political_candidate` 플래그, 평판 70+, Turn 30+
  - 수락 시 -1,000만원 + `political_winner` 플래그 → 65세에 `political_fix` 엔딩

#### 코인 망령 경로 (`investment_events.json` 6개 선택지)
- `gambling_002` 레버리지 풀베팅 → `addiction_tendency` +15
- `gambling_007` 소액 질러보기 / 링크 클릭 → +10 / +8
- `gambling_020` 전 재산 몰아넣기 / 흔들림 → +25 / +5
- `inv_crypto_mania` 소액 참여 → +8
- `addiction_tendency` 90 도달 시 `crypto_ghost` 엔딩 발동

## 2026-05-27 (스플래시 화면 추가)

### 타이틀 스플래시 씬 신규 구현
- `scenes/SplashScreen.gd` / `SplashScreen.tscn` 신규 생성
- `project.godot` 메인씬: `StartMenu.tscn` → `SplashScreen.tscn`
- 연출 시퀀스 (총 ~4.5초):
  1. 검정 → 페이드인 (SceneTransition)
  2. 옥상 키아트 배경 서서히 등장 (38% 불투명)
  3. 로고 이미지 페이드인
  4. "강남드림" 한글 타이틀 (64px)
  5. "GANGNAM DREAM" 영문 부제 + 구분선
  6. "서울에서 살아남아라" 태그라인
  7. "― 2030년대 서울, 당신의 이야기 ―" 컨텍스트
  8. "아무 키나 눌러 계속" 힌트 (깜빡임 3회)
  9. 자동 전환 / 키·마우스 클릭으로 스킵

## 2026-05-27 (UI 대시보드 개선 — 바이탈 HUD + 진행 바)

### 탑바 바이탈 HUD 추가 (Football Manager 스타일)
- `_build_top_bar()`: AP 레이블 우측에 `vitals_row` HBoxContainer 삽입
  - `vital_health` (❤ + 숫자 + 6칸 블록바), `vital_mental` (🧠), `vital_stress` (😤)
  - 세퍼레이터 `│` 로 AP / 바이탈 / 머니 시각적 구분
  - 건강/정신: 30↓ 빨강, 50↓ 노랑, 정상 초록/파랑
  - 스트레스: 80↑ 빨강, 60↑ 노랑, 정상 민트
- `_refresh_vitals()` 신규 메서드: `_refresh_all()` 호출 시 바이탈 갱신
- `_bar_str(value, max_val, bars)` 신규 헬퍼: `"█".repeat(filled) + "░".repeat(empty)` 블록 진행 바 생성

### 스탯 패널 진행 바 표시
- `_set_stat_value()`: 건강/정신/스트레스 항목에 10칸 블록 진행 바 추가 (`63  ██████░░░░`)
- 기타 스탯(지력, 사회성 등)은 기존 숫자 표시 유지

## 2026-05-27 (Polish Beta — 투자 차트 히스토리 + 한국어 톤 패스)

### 투자 차트 히스토리 시각화
- `MainGame._open_investments()`:
  - 포트폴리오 보유 시 전체 수익률 요약 헤더 추가 (원금 → 현재가치, 수익률 %)
  - 자산별 2줄 표시: ①자산명·리스크·현재가 ②스파크라인 + 1개월/3개월/12개월 변동률
- `MainGame._render_sidebars()` 시황 티커: 6개월 미니 스파크라인 추가

### 한국어 톤 패스
- `life_events.json` 플레이스홀더 설명 35개 → **전부 제거** (0개 남음)
  - 교체 대상: family, social_life, politics, gambling, military, health, disasters, comedy, finance, romance 카테고리 전반
  - 톤: 2030 서울 청년의 자조적·관찰적 시선. 과장 없이 담백한 일상 문장

## 2026-05-27 (Polish Beta — 관계/직업/엔딩 3종 개선)

### 관계 패널 능동 상호작용
- `MainGame.gd`: `_ap_network()` → `_ap_socialize()` + `_open_relationship_manager()` 모달로 교체
  - 관계 유형별 전용 행동: 친구=커피, 연인=데이트(친밀도 60+ 기준), 멘토=조언/근황보고(신뢰 50+ 기준), 비즈니스=파트너 미팅, 가족=통화
  - "새 인연 만들기" 선택지: 사회성 +3, 50% 확률 인연 생성 (이름 풀 16개)
  - 각 행동 후 turn_action_log, add_log, toast 피드백 연동

### 직업별 이벤트 조건 강화
- `EventManager.gd`: `min_job_tier`, `max_job_tier`, `job_category` 조건 추가
- `life_events.json`: 12개 이벤트 조건 패치
  - 직업 없이 뜨던 이벤트 5개에 `has_job: true` 추가 (첫 회식, 업무 카톡, 연차, 피드백, 험담)
  - 이직/퇴사 이벤트 3개: `has_job: true` + 설명 교체 (플레이스홀더 제거)
  - 야근/성과/프로젝트 이벤트 3개: `min_job_tier: 2` 추가 (T2+ 직장에서만)

### 엔딩 화면 메타 진행도 표시
- `MetaProgression.gd`: `_new_this_run` 딕셔너리 추가, `record_run()` 시작 시 초기화
  `unlock_trait()` / `unlock_achievement()` 호출 시 신규 해금이면 목록에 추가
  `get_new_unlocks()` 메서드 추가
- `MainGame.gd `_show_ending()`: 새 해금 트레이트/업적 표시 (🔓 섹션, 업적 ID→한글명 매핑)

## 2026-05-27 (밸런스 패스 — 초반 생존성 개선)

### 수치 조정
- **고시원 월세**: 800,000원 → **650,000원** — 설계 기준(CLAUDE.md) 불일치 수정. 신규 플레이어가 Turn 2에 현금위기(-30만)로 즉시 패닉하던 문제 해소. 1개월 여유 버퍼 확보.
- **무직 스트레스 이중계산 제거**: `JobSystem.process_monthly_job()` 무직 시 +2 스트레스 제거. `apply_monthly_pressure()`에서 이미 +6/월 처리 중. 총 무직 스트레스 +8 → **+6/월**으로 정상화.
- **T3 직업 스트레스 곡선**: 공공기관 계약직(+2→+3), 부동산 중개보조(+3→+4). T3 직업이 T1 직업과 동일한 스트레스를 가지면서 월급은 훨씬 높던 우열 구도 해소.

### 분석 내용
- 15개 직업 전체 스트레스·급여 커브 검토
- `InvestmentSystem.gd` 수익 구조 분석: drift +0.3%/월, 크래시 확률 및 위험도 밸런스 적절 — 조정 불필요
- `assets.json` 18개 자산 변동성·최소 투자금 검토 — 현행 유지

## 2026-05-27 (이벤트 확충 — Content Alpha 달성)

### 콘텐츠 추가
- 투자 이벤트 14 → **30개** (+16): 리밸런싱, 단톡방 주식 정보, 시장 폭락 경보, 배당금 입금, 손절 결정, 공모주 청약, ETF 공부, 부동산 버블 공포, 경기침체 우려, 투자 서적, 선배 내부 정보, 금융소득 과세, 적립식 투자, 코인 광풍, 해외 주식, 1년 수익률 점검
- 관계 이벤트 15 → **30개** (+15): 멘토 커피, 동료 갈등, 소개팅, 친구 이별 위로, 부모님 상경, 전 연인 연락, 사무실 뒷담화, 썸 진전, 사업 파트너 제안, SNS 비교, 멘토 쓴소리, 가족 대출 부탁, 팀 회식, 네트워킹 세미나, 새벽 통화

### 품질 개선
- 기존 투자 14개 + 관계 15개 설명 전면 개선: 동일한 플레이스홀더 텍스트를 이벤트별 개별 장면 묘사로 교체

### Content Alpha 달성 현황
| 콘텐츠 | 목표 | 현재 | 상태 |
|--------|------|------|------|
| 일반 생활 이벤트 | 100개+ | 106개 | ✅ |
| 투자 이벤트 | 30개 | 30개 | ✅ |
| 관계 이벤트 | 30개 | 30개 | ✅ |
| 히든 이벤트 | 20개 | 20개 | ✅ |
| 직업 | 15개 | 15개 | ✅ |
| 아이템 | 30개 | 30개 | ✅ |
| 엔딩 | 10개 | 14개 | ✅ |

## 2026-05-27 (첫 30분 몰입도 개선)

### 버그 수정 (Critical)
- `story_arrival_elite`, `story_arrival_rich` → `follow_up_event: "story_pressure"` 누락 수정.
  명문대/금수저 배경에서 구직 해금(`story_job_unlocked`)이 永久 잠겼던 문제.
- `story_first_workday`, `story_first_paycheck_feel`, `story_first_savings_milestone`, `story_six_months`, `story_one_year` → `seen` 플래그 누락 수정.
  매 턴 무한 반복 트리거 방지 (`flags: ["...seen"]` 형식으로 통일).
- story 이벤트가 random pool에 노출되지 않도록 `conditions: {min_turn: 9999}` 추가.

### 신규 콘텐츠
- `first_job_rejection` (life_events.json): 구직 해금 후 무직 상태 단발 이벤트. 첫 취업 전 긴장감 서사 추가.
- `convenience_midnight_snack` (life_events.json): 자정 편의점 도시락 딜레마. 초반 6개월 이내 한정.
- `small_unexpected_win` (life_events.json): 5만원 발견 행운 이벤트. luck≥40, 초반 한정.

### 튜토리얼/UX 개선
- `MainGame.gd`: `tutorial_step >= 3` 조건 추가 — Turn 1 액션 단계에서 "서울 첫 달!" 힌트 표시.
- `MainGame.gd`: 첫 취업 시 🎉 특별 토스트 피드백 (housing_up SFX + 초록 강조색). 이직 시 기존 노란 토스트 유지.

### 라이벌 시스템
- `RivalSystem.gd`: Turn 2에 라이벌 첫 소개 메시지 자동 표시. 이름·나이·출발선 공개, 경쟁 의식 조기 형성.

## 2026-05-16 (Meta-Progression First Pass)

### 기능 구현
- `content/meta/traits.json` 신규 생성 — 5종 트레이트 정의 (id, unlock 조건, description, bonus).
- `DataRegistry.gd` — `TRAITS_PATH` 상수, `traits` 배열 및 `traits_by_id` 딕셔너리 추가. `reload()`에 로드 로직 포함.
- `MetaProgression.gd`:
  - `get_trait_bonus()` — `data["trait_bonuses"]` 딕셔너리 하드코딩 방식 → `DataRegistry.traits` 룩업으로 교체.
  - `_check_progression_unlocks()` — 엔딩 기반 언락 추가: `stable_success`/`ordinary_life` → 안정 지향형, `gangnam_dream` → 강남드림 계승자.
- `StartMenu.gd` — `trait_desc_label` 추가. 트레이트 선택 시 `_on_trait_selected()` 콜백으로 설명 + 보너스 요약 실시간 표시.

## 2026-05-16 (Init)
- Standardized project management around an independent GitHub Desktop repository.
- Published the Godot project to GitHub.
- Added documentation structure for future requirements, roadmap, decisions, and release notes.

## 2026-05-16 (Prototype Improvement Pass)

### 버그 수정
- `GameState.check_game_over()` 엔딩 ID 불일치 수정 (`health_collapse` 등 → `burnout` 등).
- 65세 도달 시 자산 기준으로 `stable_success` / `ordinary_life` 분기 추가.
- `_set_stat_value()` warn/danger 파라미터 순서 역전 버그 수정 (건강/정신력 색상 기준 정상화).

### UI 개선 (MainGame.gd)
- 모달 `ScrollContainer` 추가.
- 모달 타이틀 + X 닫기 버튼 구조로 개편.
- 메인메뉴 복귀 버튼 추가 (자동저장 후 이동).
- 인벤토리 "사용" 버튼 추가 → `InventorySystem.use_item()` 연결.
- 투자 모달: 매수 금액 선택(10만/50만/100만), 분할 매도(25%/50%/전량), 수익률 표시.
- 시장 티커: 전달 대비 등락률(%) + 리스크 점 표시.
- 로그 BBCode 활성화, 타입별 색상 구분.
- 스탯 패널 색상 경고 (건강/정신력/스트레스).
- 이벤트 선택 후 `result_text` 결과 화면 추가.
- 엔딩 화면: 등급 색상, 새 런 / 메뉴 버튼 추가.
- 뉴스 루머 표시 (`[루머]` 접두사).
- 관계 패널 한국어 유형 표기, 친밀도 레이블.

### 콘텐츠 교체
- `items.json` 30개 플레이스홀더 → 실제 한국 생활 아이템.
- `jobs.json` 15개 설명 교체, 카테고리 정정.
- `endings.json` 10개 설명 전면 교체.
- 이벤트 `result_text` 584개 전체 생성.

### 문서화
- `CLAUDE.md` 생성 (Codex 세션 컨텍스트).
- `docs/` 전체 오늘 세션 반영.

## 2026-05-16 (QA & Toast Integration)

### 버그 수정
- `EndingSystem.evaluate_current_ending()` 엔딩 ID 불일치 수정 — `health_collapse` → `burnout`, `mental_burnout` → `mental_break`, `debt_spiral` → `bankruptcy`, `ordinary_retirement` → `ordinary_life`, `upper_middle` → `stable_success`. (`GameState.check_game_over()`는 이전 패스에서 수정됐으나 이 함수는 누락됐었음.)

### UI 개선
- `NotificationToast` 연결 완료 — `MainGame.gd`에 `_toast_container` 및 `_show_toast()` 추가.
- 저장, 직업 변경, 매수, 매도, 아이템 구매/사용 시 토스트 피드백 표시.

## 2026-05-16 (Appearance Stat Implementation)

### 기능 구현
- `appearance` 스탯 효과 전면 구현.
  - **UI**: 스탯 패널에 `외모` 항목 추가 (기존에 저장만 되고 미표시였음).
  - **직업 요건**: `유튜브 크리에이터`(min 55), `보험 영업직`(min 48), `외국계 세일즈`(min 52)에 `min_appearance` 요건 추가.
  - **JobSystem**: `_check_requirements()`에 `min_appearance` 케이스 추가.
  - **RelationshipSystem**: 외모 60 이상일 때 연애 관계(`romantic`) 호감도 월간 감소 차단.

## 2026-05-16 (Save/Load Validation)

### 버그 수정
- `GameState.load_from_dict()` — JSON 역직렬화 시 int 필드가 float으로 복원되는 버그 수정. `age`, `health`, `mental` 등 14개 필드에 명시적 `int()` 변환 추가. (미수정 시 UI에 `"50.0"` 등으로 표시됨)
- `SaveManager.load_game()` — 저장 파일 버전 불일치 시 경고 없이 로드하던 문제 수정. `push_warning()` 추가 및 미래 마이그레이션 훅 위치 확보.
- `SaveManager.save_game()` — `action_log`/`news_log`/`event_log` 무한 증가 방지. 각각 최근 100/60/100개로 캡 적용.


## 2026-06-08 (UI 대수술 + 버그 수정)

### RaceTrack / HoldemClub 버그 수정
- `RaceTrack.gd`: `Color("#0a0d12", 0.75 if ...)` → `Color()` 후 `.a` 별도 대입 (GDScript 불안정 생성자 우회)
- `HoldemClub.gd`: bg ColorRect alpha 0.8 고정 → 이미지 없으면 1.0 (불투명)으로 수정
- 두 오버레이 모두 `mouse_filter = MOUSE_FILTER_IGNORE` 명시

### 목표 진행바 추가
- `_build_goal_bar(parent)` — 상단 바 아래 24px 얇은 바
- 현재 자산 / 30억 달성률 실시간 표시 (0.01% 단위)
- 진행도 색상: 파랑(초반) → 녹색 → 금색 → 주황(60%+)
- 잔여 시간 1년 이하면 % 색상 경고

### 첫 런 튜토리얼 모달
- `_maybe_show_tutorial()` — `GameState.flags["tutorial_shown"]` 1회 체크
- 첫 AP 화면 진입 시 자동 표시 (프롤로그 이후)
- 목표/진행방식/주의사항/첫 달 추천 4섹션

### 월별 추천 행동 표시
- `_recommend_action()` — 상태 기반 이번 달 최우선 행동 제안
- 경고 없을 때 `event_body` 마지막에 "💡 이번 달 추천" 표시
- 상태 우선순위: 무직 → 스트레스 높음 → 첫 월급 전 → 투자 가능 → 자기계발

## 2026-06-12 — 콜백 이벤트 5차 배치
- callback_events_5.json (KR) + events_en/callback_events_5.json (EN) 생성
- DataRegistry.gd에 경로 추가
- 17개 이벤트: chaebol_contact, approached_shadow_investors, declined_sangchul_deal, jeonse_ignored, checked_registry, wallet_took_cash, wallet_ignored, fomo_invested, declared_dream(turn40), deleted_sns, envy_fuel, came_clean_to_friend, borrowed_from_parents, escaped_dirty_money, heard_father_young_story, asked_father_health, freelance_started
- audit.sh ERROR 0 / WARNING 20 (기존) 통과
- 배치 1~5 누적 87개 콜백 이벤트

## 2026-06-25 (5권 구조 연말 클로징 씬 4종)

### 수정 내용

#### 연말 클로징 씬 신규 (arc_year_close.json)
- `arc_year1_close` (t44-48): "33세의 마지막 밤" — 고시원 천장 금, 1년 생존 반성
  - description_if_known: jaehyuk_scammed / entered_network / hit_rock_bottom
  - stance 플래그: year1_resolve / year1_numb
- `arc_year2_close` (t92-96): "34세의 마지막 밤" — 거리의 밤, 달라진 것들 점검
  - description_if_known: jaehyuk_stood_up / crossed_line / chose_money_over_father / year1_resolve / year1_numb (cross-year echo)
  - stance 플래그: year2_confident / year2_conflicted
- `arc_year3_close` (t140-144): "35세의 마지막 밤" — 한강 어두운 밤, 진실의 무게
  - description_if_known: father_confession_heard / sangchul_truth_known / arc_y3_jiyeon_departure_seen / year2_confident / year2_conflicted
  - stance 플래그: year3_eyes_open / year3_weighted / year3_avoidant
- `arc_year4_close` (t188-192): "36세의 마지막 밤" — 옥상에서 본 도시, 마지막 1년
  - description_if_known: father_passed / crossed_line / year3_avoidant / year3_weighted / year3_eyes_open / sangchul_truth_known
  - stance 플래그: year4_final_resolve / year4_self_known

#### gangnam_dream 엔딩 year4 stance 변주 2종
- year4_final_resolve: "다짐한 것이 현실이 됐다" — 마지막 1년 다짐 페이오프
- year4_self_known: "그 사람이 강남에 있다" — 자기 인식 페이오프

#### MainGame.gd _next_arc_id()
- 연말 창구 4개 dispatch 추가 (t44-48 / t92-96 / t140-144 / t188-192)

#### 시스템
- DataRegistry.gd: arc_year_close.json 등록
- content/events_en/arc_year_close.json: 전체 EN 오버레이
- debt_baseline: 228 (endings.json 읽기 미스캔 2건)
- audit ERROR 0/WARNING 0/밴드 통과

## 2026-06-25 (로맨스 시스템 재설계 — Y5 게이트)

### 수정 내용

#### 다은 아크 Y1-Y4 재프레임 (arc_daeun.json + events_en)
- arc_daeun_03_fork: "같이 잘 살아봐요" → "같이 버텨봐요" (lover stage → close, 우정 다짐)
- arc_daeun_03b_date: "데이트" → "처음 나간 날" (dating→warm, 연인 플래그 제거)
- arc_daeun_04_morning: 침대 옆 장면 → 새벽 3시 메시지 씬 (함께 있음 암시 제거)
- arc_daeun_04b_future: daeun_committed → daeun_close_bond (사랑 선언→우정 다짐으로)

#### Y5 로맨스 게이트 신규 (arc_romance_y5.json)
- arc_daeun_y5_feelings (t≥193, daeun_close_bond + moral_stage≥0): 4년 만에 말하는 장면
- arc_jiyeon_y5_feelings (t≥193, arc_jiyeon_03b_seen + moral_stage≤-1): 두 개의 강남

#### 결혼 변주 (endings.json + endings_en.json)
- with_daeun [daeun_romance_started]: "편의점 삼각김밥 → 강남 열쇠 옆"
- jiyeon_man [jiyeon_romance_started]: "두 사람의 강남"

#### 시스템 수정
- MainGame.gd: Y5 romance dispatch, 내레이션 romance_started 분기
- GameState.gd: dating stage 참조 제거 → close/lover
- DataRegistry: arc_romance_y5.json 등록
- audit ERROR 0/WARNING 0/밴드 통과

## 2026-06-25 (다은 우정 재프레임 완성 + 현수 Y4-Y5 + Steam App ID)

### 수정 내용

#### 다은 Y2-Y5 우정 재프레임 (연애는 Y5 게이트로 단일화)
- arc_daeun_05_together: 동거 암시("냉장고에 다은 물건") 제거 → 자주 들르는 깊은 우정. committed→close
- arc_daeun_year3_together: "같이 지낸 2년"→"안 지 2년", committed→close
- arc_daeun_year4_together: 강남 취직 씬, 잘못된 "형" 호칭 제거, committed→close
- arc_daeun_year5_ending: 친구 finale 기본 + description_if_known[daeun_romance_started] 연애 변주

#### 엔딩 라우터 버그 수정 (CRITICAL)
- with_daeun 엔딩이 cast stage 기준이라, 우정 플레이어가 year5_ending에서 together stage를 얻으면 연애 엔딩 오발동 → daeun_romance_started 플래그 기준으로 변경 (GameState.gd:1457)
- 죽은 cast-stage 정리: committed/dating 읽기 4곳 제거 (MainGame 2곳, GameState 2곳)
- Y4 다은/지연 상호배타 체크에 daeun_close_bond 추가

#### 현수 Y4-Y5 아크 공백 해소 (arc_hyunsu.json +2, KR+EN)
- hyunsu_year4_echo (t≥150, hyunsu_passed OR hyunsu_pivoted): 자리잡은 현수 vs 아직 달리는 나 (안정 vs 야망 거울)
- hyunsu_year5_call (t≥200): 5년 끝 영상통화, crossed_line/father_passed 반응형
- MainGame.gd dispatch 2개 (hyunsu_pass_news 뒤)

#### Steam App ID 정리
- STEAM_APP_ID / STEAM_FALLBACK_URL 클래스 상수화 — 출시 시 1곳만 교체
- 플레이스홀더면 깨진 /app/STEAM_APP_ID/ 대신 상점 검색 URL로 안전 폴백

#### 검증
- audit ERROR 0/WARNING 0/밴드 통과, 전 JSON 파싱 OK

## 2026-06-25 (지연 로맨스 Y5 단일화 정합성)

### 수정 내용 (다은 재프레임의 거울 — 지연도 동일 버그 구조)
- 문제: jiyeon_man 엔딩이 cast stage(honest_together=Y2 t56-64 / lover=Y4) 기준 → Y5 전 연애 엔딩 발동 가능. Y5 return은 아무것도 formalize 안 함.
- jiyeon_man 라우터: stage → jiyeon_romance_started 플래그 기준 (GameState.gd)
- arc_jiyeon_year5_return CH0: jiyeon_romance_started + stage lover 부여 (Y5 = 연애 확정 지점)
- arc_jiyeon_year4_seoul CH0: lover → honest_together (Y4는 감정 인정, 확정은 Y5 이연)
- _ending_cast_epilogue: 지연 연애 분기 stage→플래그 게이트, honest_together는 비연애 깊은유대 티어로
- arc_jiyeon_y5_feelings 중복 가드: 부산 귀환 아크(year4_call/year5_return/news) 탄 플레이어 제외
- honest_together = "깊은 정직 유대(연애 전)"로 의미 유지 → Y2 텍스트/콜백 무수정(리스크 최소)
- audit ERROR 0/WARNING 0/밴드 통과

## 2026-06-25 (Y1-Y5 전체 정합성 QA + 후속 수정)

### 점검 방식
4개 영역 병렬 정밀 추적(서브에이전트): 다은 아크 / 지연 아크 / 타임라인·스타베이션 / 기타아크+엔딩.

### 결과: 블로커·데드엔드 없음, 엔딩 우선순위 회귀 없음
- 엔딩 우선순위: 30억 블록(GameState 1424)이 age>=38 연애 블록(1454)보다 먼저 return → 30억 승자는 gangnam_dream 유지, with_daeun이 가로채지 않음
- 다은/지연 연애 상호배타 구조적 확정 (moral_stage 분리 + daeun 경로 라우팅)
- 연말 클로징(t44-48 등)·현수 Y4-Y5·연애 Y5 게이트 전부 도달 가능, 스타베이션 없음
- age=38은 t241에 도달 → Y5(t193-240) 48턴 완주, t>=200 콘텐츠도 실행됨

### 후속 수정 3건
- [지연 MAJOR] respected/trust 플레이어 Y4 지연 비트 공백 → year4_seoul 게이트에 respected/trust 추가
- [다은 MINOR] 우정 finale(together stage)의 엔딩 에필로그 연인 톤 누수 → daeun_romance_started 플래그 게이트
- [다은 MINOR] cast_stages.json 죽은 stage(dating/committed) 제거
- audit ERROR 0/WARNING 0/밴드 통과
