# ORDER-493 — 중국어 문맥 UI17키

#### [x] ORDER-493 [전체 현지화] CN/TW 문맥별 영어 폴백34값 — 2026-10-09

착수 — 만지는 파일: locale/ui_zh-CN.json·ui_zh-TW.json의 신규17 context키씩,
content/meta/full_game_localization.json의 해당34영수증·배치1. 운영 파일은
큐/L3 이어보기·본 사양/완료archive·WORK_LOG·CLAUDE 마지막 갱신·생성STATUS만.
도구·원문·런타임·기존 번역·새 formal 검수/판정원장은 비소유다.

## 판정 단위 / 깊이3문

- 지우면: 기존 planner·Holdem·MainGame21곳의 모호한 한국어17키가 중국어에서
  영어로 폴백하거나 구형 공통뜻을 쓴다. context ID가 역할을 분리한다.
- 독자: LocaleManager.ui_context의 community context→community legacy→builtin
  context→builtin legacy→EN 조회. 실제 호출/역할을 확인하고 기존 키·선택·상태는
  바꾸지 않는다. Skill의 실제 intelligence 효과, 설정의 테이블 준비 단계,
  대기의 주택 자금 부족, 인연의 상대 이름 폴백, 기억의 물품 그림 자리표시를 구별한다.
- 경쟁: JA29context는 이미 있으며 비소유다. CN/TW12→29/29 문맥키 수용이지
  legacy1644/2952·dynamic150/701·전체 UI나 본편 출시 완료가 아니다.

## 정확 선택17 / 실행

ui.planner.skill_axis; ui.planner.income_axis; ui.planner.people_axis;
ui.choice.noun_label; ui.holdem.setup_action; ui.completion.unrecorded_value;
ui.week.spent_status; ui.situation.civic_tag; ui.situation.event_fallback;
ui.job.application_noun; ui.action.creating_content; ui.forgone.relationship_fallback;
ui.situation.life_tag; ui.choice.keep_action; ui.housing.requirement_state;
ui.gambling.venues_title; ui.saving.activity_title.

두 중국어 지역 저자는 각각 KO 직접 private response만 소유한다. root는 먼저 선언
commit/push, 기존 공식 export/check/import, 원영수증 header/SHA·source/target 원장
결속만 한다. 비저자는 원문/21소비자·34번역·전후4파일 raw 역상·실제 Git source
manifest/영수증을 메시지로 검수한다. 새 도구/보고0·새규범0·절차 일회성이다.

## 표적 검증 / 경계

기존 ui_translation_append 전후 증분·현재 full_game_localization 영수증,
EN/Hangul·JA UI·ZH·i18n·보호 데모 영향 검사만 실행한다. latest DECISIONS의
번역 배치 상한에 따라 전체 local audit/엔진240주/계측·이력 도구를 만들지 않는다.
Mac 잠금으로 실제 폭/입력은 미관찰·OPEN이다. 원어민·물리패드·shipping language·
사용자 저장·공개 M01~M06·project.godot·과거 인간 판정은 불변, 본편 출시 HOLD다.

## 수용 결과 — 2026-10-09 / 텍스트 범위만 GO

선언eb0e57c → 제품1d90f58cc832e9fcce55ac3093fbf262e4d81ab0를 main에 올렸다.
CN/TW 한국어 직접17씩 저작·비저자34값/21소비자 전수 대조·blocking0이다.
기억은 물품 그림없음 자리표시 명사 記憶/记忆, 지력은 실제 intelligence 智力,
주택 대기는 부족현금 資金不足/资金不足, 인연은 인물자리 對方/对方로 수용했다.
원문·기존 번역·일본어·런타임·저장·데모·project 변화0이다.

공식 check/import 각17 PASS, accepted41937→41971·batch288→289, UI1852→1869씩.
CN/TW current context29/29·legacy1644/2952·dynamic150/701로 분모를 구분했다.
원영수증 CN004f155e12e807a41f7bdccc02de6174eee5c10f0039753fd1afcd30c5b000dc /
TWe6513d87331e6794b80ed85446b6d55dd6dcf9c450aa4d7f2d1dcaba9f776ec1,
현재34 source/target/committed receipt·header2·raw 역상 PASS.
비저자의 actual Git current_proof는 baseef97d8c→제품1d90f58 transition1/34추가·배치1,
실제 선언Git/현재 source manifest b7d4a4a0418151a18274c73e702d1e149a91c7a11611bece742b3e143acbd2ea
일치를 확인했다. 기존4파일 원바이트를 지키는 신규추가만 있으며 formal 보고/도구0이다.

EN/Hangul·JA UI·ZH·i18n·multilingual·공개/legacy 데모 영향검사 PASS.
직전491 전체CI7df56fd run37884109402 성공 확인·최신492/493는 진행 중이다.
전체 local audit/엔진·새 계측0. 렌더/원어민/물리패드 OPEN·전체게임/출시 HOLD,
현재 문맥17키 수용만 닫는다. 새규범0·절차 일회성·넓은 I18N 정본은 불변이다.
