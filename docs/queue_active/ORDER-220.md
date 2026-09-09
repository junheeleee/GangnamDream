# Active Queue Spec: ORDER-220

> [~] 착수 — 선택 효과의 번역 소비자 한 곳과 그 표적 회귀만.

#### [~] ORDER-220 [P0] 선택 미리보기 일본어 건강·정신 표시

기준 main c0dac7467a23e64e0148fe9f049a915694857a7f.
## 깊이와 결함

1. 기존 JA 건강=健康/정신=精神이 있는데 _choice_effects_preview가 is_english 분기로
   건너뛰어 Health/Mental을 내보낸다. 번역 존재와 플레이 표면이 끊긴 실제 소비자 결함이다.
2. 선택 상태/효과·24주 결과를 바꾸지 않는다. 고르기 전 읽는 언어만 바로잡는다.
3. stat 우선순위·돈·줄 간격·다른 정보량과 경쟁하지 않으며 health/mental만 기존 _tr로 보낸다.

_render_event→_reveal_choices→_choice_effects_preview→실제 Label이 대상이다.
13개 direct-EN 분기 조사 중 확인된 이 소비자만 수리한다. CN/TW에 해당 UI 키가
없는 경우 영어 fallback이 정상이며 새 번역 사전을 이 작업에 끼우지 않는다.
LocaleManager.is_english의 non-KO 계약, community overlay 우선순위와 cache를 바꾸지 않는다.

## 소유

- Rawls: scenes/MainGame.gd의 해당 소비자, 신규 tools/ChoicePreviewLocaleCheck.gd,
  tools/ChoicePreviewLocaleCheck.tscn, tools/ChoicePreviewLocaleCheck.gd.uid,
  tools/run_choice_preview_locale_qa.sh.
  테스트 전용 초기화는 autoload보다 먼저 격리하고 실제 사용자 저장/설정을 읽거나 쓰지 않는다.
- Poincare: tools/year5_reference_route_audit.py,
  tools/chapter1_core_loop_v2_causal_ledger_check.py의 exact 새 byte 전이와 해당 self hook만.
  219 TW2파일 동결·반납 뒤 이 두 파일을 순차 소유한다.
- ROOT: tools/audit_scope.json의 전용 named 차선/검사 정확 등록, CLAUDE.md,
  docs/queue_active/ORDER-220.md, docs/queue_archive/ORDER-220.md,
  docs/CODEX_QUEUE.md, docs/CODEX_QUEUE_L3_PENDING.md, docs/WORK_LOG.md,
  generated docs/STATUS.md, docs/agent_review_decisions.json의 새220 기록만.
- KO/EN prose·data/effects·UI dictionaries·LocaleManager·StoryMode·입력·저장·레이아웃·폰트·
  project.godot·공개판·인간/출시 manifest·완료215/218 증거는 비소유다.

## 코드 전 기대값과 회귀

Rawls는 구현 전 유한 실제 입력/기대값을 private proof에 봉인한다.
health3/mental2/stress5/intelligence99는 KO 건강+3 정신-3, EN Health+3 Mental-3,
JA 健康+3 精神-3, CN/TW Health+3 Mental-3이다(표시 간격은 기존 그대로).
money의 ₩/KRW·수치·부호는 기존 각 언어 출력 그대로다. 기대값을 수정 후 제품에서 생성하지 않는다.
양/음/0·stress 반전/mental 합산/상쇄·숨긴 stat·순서·원본 dictionary 불변,
locale 재선택과 community override/부분키 fallback을 실제 component에서 검증한다.
자가 표적1회 뒤 ROOT가 caller Label/격리·결과를 별도로 읽고 실제 Godot에서 실행한다.
headless 표적은 렌더나 정상 속도 전체 플레이로 기록하지 않는다.

현재 MainGame1139343B/77c690b8f4f41d9559b6aac25eb78d5de31d42be423dddbd3e889cf3287c67dd.
새 승인 N은 실제 저작 동결·ROOT diff 확인 뒤만 계산한다. N의 정확 소유 hunk만
역치환→77c690→기존215 3e15→역사 체인으로 연결한다. 옛 pin/상수/manifest/validator 불변.
현재 raw 검증을 projection보다 먼저 하고 rollback·다른 파일·타 바이트 변경은 거부한다.
private order220-guard-chain-readonly-plan.json 14900B/
b04e3385c4d37b49719bc1e758a4388ee376b0880607f534ce6efca30606e58f가
guard당26개 사전 변이 설계를 소유한다. 실제 N/hunk로 결속한 입력을 guard 저작 전에 봉인한다.
기존 self 관측 hook은 파일당2곳만 잇고 assert·변조와 옛 전체 AST는 명시 역치환으로 보존한다.

## 완료 경계

저자 focused 검사와 old modal27만 먼저 실행하며 기존 전체487/564 self는 반복하지 않는다.
ROOT 독립 변이·raw 역치환·보호 지문 검수 뒤 전용 named 차선 --list→최종1회를 실행한다.
그 차선은 두 실제 guard/전체 self, demo self/실제, full-body self, 신규 Godot component,
queue/index/scope/context를 포함한다. stdout와 Godot log 양쪽 오류·필수 marker를 검사한다.
기존 causal coverage gap/blocked와 인간 OPEN을 가짜 완료로 바꾸지 않는다.
깨끗한 새 exact source·독립 검수 보고를 작업 GO에 결속하고 원문 사양을 archive한다.
원어민·화면·인간·물리·본편 전체 GO나 외부 출시의 증거로 합산하지 않는다.

지속 언어 routing 규칙은 기존 I18N_INFRASTRUCTURE가 소유한다. 이번 exact 소유·전이·절차는 일회성이다.
자동 게이트는 도달성과 계약 증거이지 재미·깊이·문체의 증거가 아니다.

## 2026-09-09 필수 QA 통합 보완 선언 — 제품 범위 추가 없음

clean source65f97eb100e630bedd7993a893406ec495fc5c6b에서 최종 overlay 차선이
JA pipeline self와 ZH UI context에서 실패했다. 승인한 literal _tr2 때문에
실제 호출3342/legacy3308이 과거 계획3340/3306보다2개 늘어난 정확한 의존 결함이다.
번역·MainGame·UI dictionary·공개 manifest를 바꾸는 신규 제품 범위가 아니다.
기존 실패 원형을 보존하고 같은220의 필수 검사 통합 파일만 아래처럼 추가 소유한다.

- Rawls: tools/ja_translation_pipeline.py의 현재 UI inventory 검증과 그 focused self만.
  전달받은 UiCall에서 MainGame/_choice_effects_preview/legacy의 건강/Health,
  정신/Mental을 각1회 검증한다. 삭제·중복·함수/KO/EN 이동을 거부한다.
- 관측 calls·통계3342/3308은 그대로 반환한다. 원형 계약을 변형하지 않은 별도
  기대 view에서 current_source_snapshot의 두 count와 final phase의 두 count만
  고정 등록2를 더한다. 발견 개수에 따른 자동 허용·호출 필터·일반 숫자 면제는 금지다.
- 디스크 demo_localization_scope 전체 raw, ORDER96 상수·107-key·34 migration·29 IDs,
  key SHA·baseline/A/B phase와 기존69 self는 원형을 보존한다. 기존 final3340/3306
  기대값과 새 실제3342/3308은 따로 검증한다. 정상·변조를 코드 전에 봉인한다.
- ROOT: 기존 audit_scope 소유 안에 이 파일과 명시 choice-preview-ui-inventory 차선을
  등록한다. 실패2와 새 focused 회귀만 다시 실행하고, 이미 진행 중인 원래220 차선의
  두 긴 self·Godot을 이유 없이 재실행하지 않는다. 소스/검사 입력 불변을 별도로 결속한다.
  독립 고정10입력은 private order220-root-ui-inventory-precode.json에 코드 전 봉인했다.
- 기존219 수용 원형·L2·교환은 불변이다. 새 pipeline을 쓰는 최종 전량 L1은 입력 지문과
  함께 재확인한다. 같은 실패의 수리·재검을 새 블라인드 표본으로 세지 않는다.

이 파일 소유 보완과 검사 순서는 이번 오더 한정이다. 두 활성 배치와 제품 범위는 유지한다.
