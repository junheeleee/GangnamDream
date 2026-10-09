# ORDER-498 — 중국어 HUD·수첩 UI30키

#### [~] ORDER-498 [전체 현지화] CN/TW 상태·수첩60값 — 2026-10-09

착수 — 만지는 파일: locale/ui_zh-CN.json·ui_zh-TW.json 신규30키씩,
content/meta/full_game_localization.json 해당60영수증·배치2. 운영 파일은
큐/L3 이어보기·본 사양/완료archive·WORK_LOG·CLAUDE 마지막 갱신·생성STATUS만.
도구·게임원문·런타임·기존 번역·JA·형식 보고/판정원장은 비소유다.

## 판정 단위 / 깊이3문

- 지우면: 기존 MainGame의 상단 일정/휴대폰·남은 행동 횟수·수첩과 능력치 이름이
  중국어에서 영어로 폴백한다. 아버지 현재 상태와 남은 시간을 자기 언어로 읽지 못한다.
- 독자: _build_top_bar·_ap_remaining_text·_notebook_father_state_line·_open_notebook·
  _stat_name의30키와 _refresh_all·_show_ap_action_commit·_render_ap_actions·
  _add_ap_section_header 공유독자를 합친 실제37호출 → LocaleManager.ui 지역사전.
  아버지 사망의 단조증거가 생존 단계보다 우선하며 수첩은 관찰만 한다.
- 경쟁: 기존 번역/문맥29ID/공개M01~M06를 덮지 않는다. 이미 채운 투자 화면은
  반복하지 않는다. 기존 HUD/수첩 번역이며 StoryMode 기능·상태 전이 증량이 아니다.

## 정확 선택 / 공식 두 배치15+15

### A15

- 일정
- 확정한 이번 달 계획을 본다
- 휴대폰
- 문자·통화 기록과 연락처를 연다 (P / %s)
- 다음 주 ›
- 아버지에게는 이제 전화를 걸 수 없다.
- 아버지는 병원 이야기를 피하고 있다.
- 아버지는 짧은 전화만 남긴다.
- 아버지는 괜찮다는 말만 반복한다.
- 아버지는 먼저 전화를 끊지 않는다.
- 이번 주 확정
- 한 번만 선택
- %d번 남음 (+%d)
- %d번 남음
- 수첩

### B15

- 처음 적은 문장
- 숫자보다 먼저 적었던 이유
- 서울에 온 뒤 {months}개월
- 남은 시간
- {weeks}주
- 처음 약속한 5년
- 덮는다
- 지능
- 사회성
- 외모
- 평판
- 중독도
- 도박충동
- 업무성과
- 월수입

## 실행 / 검증 / 경계

간체·번체 저자 둘은 KO 직접 private response 두 파일씩만 소유한다. root는
먼저 선언commit/push, 공식 export/check/import15+15·원영수증 header/SHA4와
source/target를 원장에 결속한다. 비저자는 KO30/실제37소비자·60값·원영수증4·
기존4파일 raw 역상·actual Git source를 메시지로 검수한다. 새 도구/보고0이다.

일정은 확정 계획 조회, 휴대폰은 문자/통화/연락처다. 남은 행동 횟수와 보너스,
확정/선택 명령을 구분한다. {months}/{weeks}/%d/%s·5년·›와 단축키 P 보존.
사망 뒤 통화 불가·병원 회피·짧은 전화·괜찮다는 반복·먼저 끊지 않음을 구분한다.
정신/지능·중독도/도박충동·업무성과/월수입을 섞거나 도덕 등급을 만들지 않는다.

기존 ui_translation_append·현재 원장·EN/Hangul·JA UI·ZH·i18n·multilingual·
공개/legacy 데모 영향 검사만. 원문/저장 동작 변경0이므로 전체 local audit/
엔진240주·새 이력/계측/재사용 도구0. Mac잠금으로 실제폭/입력 미관찰/OPEN,
원어민·물리패드 OPEN·전체출시 HOLD다. project.godot·사용자 저장·shipping language·
공개데모·역사 인간판정 불변·새규범0/절차 일회성이다.
