# ORDER-506 — 레버리지 성공 알림의 중복 배수 표시 수리

#### [x] ORDER-506 [표면 수리] 투입현금×2 표시 — 2026-10-09

선언 범위 — 만지는 파일: scenes/MainGame.gd _on_leverage_buy 성공toast의 format_money
인자1개와 미사용local exposure1줄, tools/InvestmentAPCopyCheck.gd 기존 prepared
component의 성공/실패 표본만. 운영 파일은 큐/L3·본 사양/완료archive·WORK_LOG·
CLAUDE 마지막 갱신·생성STATUS만. 새 도구/검사/이력/계측/재사용 작업0이다.
경제producer·원문/번역/원장·저장구조·플래그/라우팅·project는 비소유다.

## 판정 단위 / 깊이3문

- 지우면: 현금20만원 매수의 노출액40만원이 다시×2로 보여 80만원처럼 읽힌다.
- 독자: 매수버튼 현금×2 → InvestmentSystem cash_committed/exposure →
  MainGame 성공toast다. 로그와 주간 영수증은 현금/노출액을 이미 정확히 나눈다.
- 경쟁: 수수료·수량·잔액·레버리지배수·강제청산을 바꾸지 않고 성공표시 인자만 맞춘다.

root와 비저자 phone_cn_author가 실제producer197~243/독자18250~18300를 대조했다.
exposure=cash_committed*2는 정상 경제·영수증/주간결산의 반환값이므로 유지한다.
toast의 기존KO/EN/JA/CN/TW 템플릿·%s×2는 그대로, 인자만cash_committed로 쓴다.
기준Git fac9a82(505 마감). 공개M01~M06·기존505 번역/영수증·사용자저장·
shipping language·과거사람판정은 바꾸지 않는다.

## 실행 / 검증

선언commit/push 후 root는 runtime2곳만 수리. 독립test저자는 기존
InvestmentAPCopyCheck의 MainProbe와 실제InvestmentSystem을 사용해 5locale의
성공(서로다른현금2표본)·잔액부족/없는자산/AP0·주간owner성공을 준비한다.
기존30 AP0/복원표본을 유지하고 toast의현금×2·로그현금·실제cash/quantity/fee·
노출액·AP/영수증을 각각 대조한다. 다른state/autoload는 fixture 격리안에서만 다룬다.
fixture가 실제로 실행한 수와 한계를 기록하며 준비만을 PASS로 부르지 않는다.
거래·문구 component의 효과음은 fixture에서만 설정을 보관→비활성→복원한다.
제품 AudioManager·기존 오디오 계약 검사는 그대로며 실제 청취 PASS를 주장하지 않는다.

root가 기존 StoryNameplateBootstrap 사전-autoload fresh namespace로만 기존
InvestmentAPCopyCheck와 MoneyIntegrityCheck를 실행, exact marker+exit와 stdout/engine
두로그의 parse/script/engine 오류0 확인. 제품2파일 diff역상, 원문/locale/원장/project
불변, EN/Hangul·JA UI·ZH·i18n·공개/legacy demo 영향 및 기존 AP copy검사·audit
구조·등록/context/queue/diff를 확인한다. source 원문/소비자/승인LeafSHA는 불변,
MainGame 파일 해시/current manifest와 줄번호 기반 미승인후보SHA 변화는 구분해
기록한다. 전체audit/240주0.
비저자가 실제Git최종diff·성공/실패증거를 보고 수용범위만 판정한다.

Mac잠금으로 실제toast화면/폭/입력 미관찰·원어민/물리패드 OPEN·출시HOLD다.
UI프로필의 숫자우선 짧은피드백과 기존입력불변을 적용한다. 개발 스킬의 선선언·
파일소유분리·독립검수·표적검증 적용. 새규범0·범위/절차 일회성이다.

## 완료 증거 / 한정 판정

- 선언 `0b11e79c2109991c539a048c85ad19dceb309c6e` → 제품
  `e1acd2b8d116bd6aa03df441451940ba42138221` main commit/push.
  MainGame는 미사용local 삭제1줄·toast 인자 exposure→cash_committed만 변경.
  20만원 투입은 20만원×2, 노출액40만원·수수료3천원·수량은 실제producer 그대로다.
- 기존30 AP0/복원 + 실제성공10/실패15/주간owner5 =60. 정상엔진 fresh2회 각각
  60/60·복원5·exit0·exact marker·stdout+stderr/engine 오류·경고0.
  namespace는 `GangnamDream_StoryNameplateQA_` 뒤
  `5df2125cbe6da0660437fafa00ea12e9`, `8ee8a83756e67dc24b374283ef4f50f8`.
  `/tmp/gangnam-order506.BUEBwC/investment.component.godot.log` 및
  `investment.component2.godot.log`에 표본/marker 실물, stdout/exit는 실행주체의
  메모리 검사/tool 기록이다. 준비 UI override·SFX 분리, 화면/자연입력/청취 아님.
- MoneyIntegrityCheck도 fresh `a456c68df5d6e991f2bfb097641e7972`에서
  exit0/exact marker/양쪽 오류0, `money.godot.log` 보존. 실제저장33파일·project/
  3UI/원장5파일은 최종 두 실행 각각 전후hash 불변·Git raw도 독립 대조했다.
- 효과음 켠 초기 normal은 60/60 뒤 shutdown resource1 ERROR로 수용하지 않았다.
  pool stop/stream=null·4frame·cache clear도 재현돼 해결 판정을 철회했다.
  같은 폴더의 `investment.godot.log`, `investment.final.godot.log`,
  `investment.clean.godot.log`, `investment.cache_release*.godot.log` 보존.
  verbose 단발 성공도 해결로 쓰지 않는다. 최종 fixture는 비대상 SFX만
  보관→비활성→복원하며 추정 teardown은 전부 제거했다. 제품 오디오/별도 오디오
  검사는 그대로다. 구체 누수원인 해소·실제 청취/제품 오디오 GO는 주장하지 않는다.
- 비저자 phone_independent_review가 두 로그의60행/5복원·locale별12·15성공의
  현금/노출/fee/owner를 재대조해 거래/표시 component 한정 GO. 실제 Git
  fac9a824→e1acd2b8 endpoint도 runtime2수정·실행fixture blob동일·기타제품0 확인,
  HEAD=origin/main/clean GO. phone_cn_author도 source를 독립 대조했다.
  UI1947호출 원문/소비자 불변, 17505잎 중17488 SHA 동일·미승인 ui_unverified17은
  줄번호 -1/source_path/SHA만 변화·승인receipt0. 전체LeafSHA 불변이라 쓰지 않는다.
  현재 manifest `f971c7193ba3a68299e166f2734f507f577001bc1ecc83cc940551abd038fb85`.
  역사 header/영수증은 그대로, locale3/원장/원문/경제/Audio/project raw 불변.
- AP copy self-test42·EN/Hangul·JA UI·ZH·i18n·공개/legacy demo·구조audit·등록179의
  영향10검사/context/queue/diff PASS. 전체audit/240주·새검사/이력/계측/재사용0.
  이전 fedae9d1 CI37911666004 녹색 확인·최신main CI진행 중. Mac잠금/실제화면·
  입력·청취/원어민/물리패드 OPEN·전체번역 INCOMPLETE·출시HOLD 유지.
