# ORDER-495 — 중국어 대출·상환 UI16키

#### [x] ORDER-495 [전체 현지화] CN/TW 은행 안내32값 — 2026-10-09

착수 — 만지는 파일: locale/ui_zh-CN.json·ui_zh-TW.json의 신규16키씩,
content/meta/full_game_localization.json의 해당32영수증·배치1. 운영 파일은
큐/L3 이어보기·본 사양/완료archive·WORK_LOG·CLAUDE 마지막 갱신·생성STATUS만.
도구·원문·런타임·기존 번역·새 formal 검수/판정원장은 비소유다.

## 판정 단위 / 깊이3문

- 지우면: 기존 은행의 대출·상환, 금리·신용 조건과 부채 위험 안내가 중국어에서
  영어로 폴백한다. 숫자와 단위를 읽어도 무엇을 빌리고 갚는지 판단하기 어렵다.
- 독자: MainGame._open_bank16호출·_open_leverage_investments1 공유호출,
  LocaleManager.ui→지역 사전. 잔액은 대출원금이며 한도까지는 남은 한도 대출이다.
  GameState의 등급1이 우량/7이내 1금융, 변동금리와 현금 범위 상환을 보존한다.
- 경쟁: JA기존값·중국어 기존값·공개M01~M06를 보존한다. 기존 MainGame 은행
  UI의 번역만이며 StoryMode 기능 완성·경제 정책 변경이 아니다. 수용16키만 닫는다.

## 정확 선택16

- 대출 / 상환
- 빚은 도구다. 다만 이자는 매달, 반드시, 먼저 나간다.
- 행동력 소비 없음 — 대출은 즉시 현금, 상환은 즉시 부채 감소.
- 금융 용어
- 현금 %s   |   순자산 %s
- 신용등급  %d등급 (%s)  — 점수 %d/100
- 직장·근속·소득·자산이 등급을 올리고, 부채 비율과 잔고 바닥 이력이 깎습니다.\n금리는 변동금리 — 등급이 떨어지면 보유한 빚의 이자도 같이 오릅니다.
- 위험: 순자산 마이너스 — -1억이면 파산, -2억이면 빚의 소용돌이입니다.
- %s — 월 이자 %.2f%% (연 %.1f%%)
- `  직장(소득)이 있어야 신용대출이 가능합니다.`
- `  신용 %d등급 — 1금융은 7등급 이내만 가능합니다. 등급을 올리세요.`
- `  잔액 %s / 한도 %s`
- `  (월 이자 %s)`
- 한도까지
- 전액 상환
- 투자 화면으로

## 실행 / 검증 / 경계

지역별 저자 둘은 KO 직접 private response만 소유한다. root는 선언commit/push 뒤
기존 공식 export/check/import, 원영수증 header/SHA·source/target 원장 결속을 한다.
비저자는 KO/17실제소비자·32값·원영수증·기존4파일 raw 역상·실제Git source를
메시지로 검수한다. 새 도구/보고0·새규범0·절차 일회성이다.

원화 -1억/-2억·등급 방향·월/연 금리 precision·대출잔액/현금 구분·포맷을 보존한다.
기존 ui_translation_append·현재 원장·EN/Hangul·JA UI·ZH·i18n·보호 데모 영향만.
게임원문·경제/저장/엔딩동작 변경0이므로 전체 local audit/엔진240주/새 계측0.
Mac잠금으로 실제폭/입력은 미관찰/OPEN, 원어민·물리패드·전체출시HOLD다.
project.godot·사용자 저장·shipping language·공개 데모·역사 인간판정은 불변이다.

## 수용 결과 — 2026-10-09 / 은행 정적 번역 범위만 GO

선언0cda0e4 → 제품6939838e8e9508bfabc559e7f2b9434c3bf6e558를 main commit/push했다.
기존 금액 parser의 월 이자 오탐을 별도496에서 먼저 수리했다. 정상 문안에
가짜 원화를 넣지 않았다. KO16키·17소비자·CN/TW32값을 저자2/비저자가 대조했다.
대출원금/현금·남은 한도·등급 방향·보유 빚의 변동 이자·-1억/-2억 원화·포맷
정밀도를 보존했다. 원문/런타임/저장/기존 번역·JA·공개 데모 변화0이다.

공식 check/import16씩 PASS, accepted42021→42053·batch290→291·UI1894→1910씩.
CN/TW legacy1685/2952·context29/29·dynamic150/701로 전체 INCOMPLETE를 구분했다.
원영수증 CNd126f7150651d5e5c951d6a6f362461a758199f3f673e9bb1a63193df201f8e3 /
TWf333a4cf49bb6e811443fef401b4567c933cf4639a8b9fa54a93bda61074f6e2,
원공식header2·현재32 source/target/committed receipt·기존4파일 raw 역상 PASS.
비저자의 actual Git current_proof(base6c1d96e→제품6939838)는 transition1/32receipt/배치1,
선언Git/현재 source manifest b7d4a4a0418151a18274c73e702d1e149a91c7a11611bece742b3e143acbd2ea
일치를 검증했다. 중간496 tool/운영 commit은 UI 전이를 늘리지 않았다.

EN/Hangul·JA UI·ZH·i18n·multilingual·공개/legacy 데모 영향검사 PASS·blocking0.
직전492 ef97d8c의 CI37889060971 녹색, 최신 후보 CI는 진행/대기 중이다.
새 도구/형식 보고/판정원장·전체 local audit/엔진240주0·새규범0·절차 일회성이다.
Mac잠금으로 실제폭/입력 미관찰·원어민/물리패드 OPEN·전체출시 HOLD다.
