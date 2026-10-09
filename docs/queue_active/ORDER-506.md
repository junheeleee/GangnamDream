# ORDER-506 — 레버리지 성공 알림의 중복 배수 표시 수리

#### [~] ORDER-506 [표면 수리] 투입현금×2 표시 — 2026-10-09

착수 — 만지는 파일: scenes/MainGame.gd _on_leverage_buy 성공toast의 format_money
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
