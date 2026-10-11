# ORDER-550 — 현수 통화 종료 표시 수리

#### [x] ORDER-550 [P1·확인된 표시 결함] 선택0 마지막 결과의 통화 표현을 끝낸다

**착수 — 2026-10-11.** 549 실제 앱에서 확인한 결과 마지막 문단의 통화 중 배지·
원격 초상·이름표 잔류 한 건만 수리한다. 이 선언을 main에 push한 뒤 구현한다.

## 깊이 3문

1. 수리하지 않으면 통화가 끝난 뒤에도 상대가 연결되어 있는 것으로 보인다.
   `arc_hyunsu_new_path` 선택0의 authored result source index2가 종료 경계다.
2. 새 선택·관계·24주 상태를 만드는 작업이 아니다. 기존 효과·영수증·저장·
   원문·번역은 불변이며 선택0 첫 두 결과 문단의 통화는 유지해야 한다.
3. 같은 자리의 다른 선택1/2, 다른 사건과 공용 통화 문법을 바꾸지 않는다.
   source index와 페이지 index를 혼동하지 않고, 마지막 문단이 분할되어도 같다.

## 파일 소유

- phone_cn_author: `scenes/StoryMode.gd`만. exact 사건·선택0·결과 단계·source index2
  이후에만 Registry presentation의 복사본을 narration/portrait none/nameplate hidden으로
  파생한다. live advance·v4 결과 복원·in-place 언어 변경이 같은 결정을 읽는다.
  registry 원형·공용 phone 기본값·원문 문자열 탐지·새 CG·효과/라우팅 수정0이다.
- cjk_wrap_diagnosis: 선언 큐2파일, 그 뒤 `tools/ManualSaveCheck.gd`만. 기존 W207
  live→disk/new Story→locale 패턴을 재사용하는 좁은 focus를 추가한다. 전체 Manual의
  기존 검사도 보존하며 whole/240주 실행·새 영구 runner/감사 등록·479/481 작업0이다.
- root: 이 사양, 큐 마감·보관, `CLAUDE.md` 현재행, `docs/WORK_LOG.md`,
  `docs/agent_review_decisions.json`, 새 `.git/order550-qa-20261011/` 일회성 실행 자료.
  격리 bootstrap/compile·선택된 정적·표적 엔진·기존 ScreenshotQA 실행은 root만 한다.
- phone_independent_review: 새 private 보호/검수 자료와
  `docs/agent_reviews/ORDER-550.json`만. 산출물2파일과 원문5언어 해당3결과,
  원실행3stream·선택/복원/언어 전환·픽셀/상태·보호 대조를 직접 읽어 판정한다.
- 549 원보고/manifest/REWORK·모든 과거 raw와 판정·Human·player·공개 데모·
  `project.godot`·원문·번역·story_rules·저장schema·소스 밖 자산은 비소유다.

## 검증 경계

- 기존 pre-autoload bootstrap과 snapshot/file_record/clean_environment/run_command를
  재사용한다. 새로운 HOME/XDG와 private QA 저장만 쓴다. fixture는 합성 표적 계약이며
  549 실제 이어보기/정상 무주입 플레이로 부르지 않는다. 이미 관측한 M10 재플레이0이다.
- compile 한 번, 좁은 Manual focus 한 번에서 r0/r1 연결 유지, r2 모든 페이지의
  배지·초상·이름표 숨김, r1/r2 disk 복원·동일 source 언어 전환, once 효과/로그,
  다른 선택1/2 및 다음 사건 reset을 확인한다. 새 실패가 있으면 원자료를 보존하고 수리한다.
- `audit_select --list`로 영향 목록만 확인하고 relevant 정적 검사를 실행한다.
  엔진 목록을 무격리로 자동 실행하지 않는다. 전체 감사·whole Manual·기존8/12/240주·
  종료 누수/ObjectDB 재탐침·검증 비용 최적화0이다. STATUS stale은 기존 비차단이다.
- 기존 ScreenshotQA의 사건/result 페이지 캡처를 재사용해 KO/EN1280×800의 연결
  문단과 종료 문단을 대조한다. 언어/해상도 자동 계약과 실제 인간/물리패드 관측은 별도다.
  앞선 native 관측/issued a0bc 패키지는 이번 source 수리와 구분한다.
- 실행 전후 current source/spec/helpers와 player/Human/기존293판정/549 포함 raw를
  fresh exact 대조한다. 실행 중 이 소스 후보는 동결하며 원로그/실패 증거를 삭제하지 않는다.
- 자동 계약은 재미·깊이·문체의 증거가 아니다. source work_unit만 판정하며,
  549 package REWORK·옛 HOLD·strict FAIL·로그 사고·본편/출시 HOLD는 소급0이다.
  인간/원어민/물리패드·새 앱/OS cold·자연240주·출시/스토어/지출/인증 주장은0이다.

## 완료 증거 슬롯

- 도달 경로: `MANUAL_SAVE_HYUNSU_CALL_END_CHECK_OK choices=15 locales=5 disk_new_Story=10 same_source_locale=10 next_event_reset=5 r0/r1=connected r2_all_pages=hidden other_choices=unchanged effects/log/history/registry=once-preserved language=actual-ko-en/internal-ja-zh prepared_W40=1 natural_M10=0 new_OS_process=0` 1개.
- 생산자↔독자: `content/events/arc_midgame.json:416`의 선택0 결과 source2 ↔
  `scenes/StoryMode.gd:5336`; 확정 위치 소비자는 `:2641/:3253/:5820/:6568`.
- 바꾸는 상태: r0/r1 `phone/connected/remote` 유지 → r2 `narration/none/hidden`;
  15선택 원효과/로그 once·10복원/10locale 이후 serialize/history/Registry exact.
- 포기 시 잃는 것: 새 선택 0건; 기존 선택1/2의 통화 표현 불변(5언어 전결과 검사).
- 서사 위치: `arc_hyunsu_new_path`, Ch2/M10, choice0 result source2(5언어3문단).
- 장면 계층: 기존 사건 tier·CG·배경/음악·원문/번역/저장schema 변경0.
- 닫는 것: 549의 종료 후 배지/초상/이름표 잔류 **source 한정**. 원549 package REWORK 불변.
- 규범 판정: 새 규범0; 위 검증·소유 지시는 이 오더 일회성. 정본 승격0.

## 2026-10-11 마감 — source 단위 GO

- 선언 `d05b0dc555dc6399673f86cd5600ea8bf5ce6dda` main push 뒤 착수;
  검수 source `7b026c902b0b372238aa6b3b7365cd74f5e50493` / tree
  `ae0ad233983c55d8d0401403dddf99d7cbb0e6fa`. 제품26줄·기존 Manual214줄 추가만.
- `.git/order550-qa-20261011/`: prepare-01 import0/32.270345s(기존 nested project
  WARNING1 보존), compile-01 actual0/4.292396s/69, manual-01 actual0/9.587657s/40pages,
  render-ko-01 actual0/18.248625s, render-en-01 actual0/18.305617s.
  runtime4건 exact marker 각1/failure null/3stream ERROR·WARNING·ObjectDB0.
- 기존 ScreenshotQA를 재사용한 KO/EN1280×800 PNG6+상태JSON6 전량 직접 관측:
  r0/r1 배지·원격 초상·이름표 유지, r2 원문 완문과 함께 셋 모두 숨김.
  원배경/텍스트/진행 유지, 표본 내 새 잘림/tofu/EN한글0. 합성 source 렌더이며
  실제 정상 입력/새 issued 앱/M10 재플레이/인간·원어민·물리패드 관측이 아니다.
- 신규 정적7개 actual0/14stream exact: audit/en_coverage/inventory/player_language/
  story_consistency/feature_liveness/surface_coherence. EN_HANGUL는 동일 StoryMode
  바이트에서 앞선 terminal exit0 관측만; 새 private raw/새 검사로 합산0이다.
- [독립 보고](../agent_reviews/ORDER-550.json): phone_independent_review의5언어 원문·
  2소스·원실행3stream·PNG6/JSON6·종료 fresh 직접 검수. 보호121/1938 file+5symlink,
  tracked3336/nonowned3334·player33·Human/기존293판정·seed2/W238·helper5 exact.
  final seal15110B/SHA256 `08a2cc0c15e3c576d2403aab0d365723830af0a35da912b8003b3f5c53b4dc44`.
- 강제 page split0/JAzh native 화면0/새앱·OS cold0/자연240주0/전체CI0;
  옛547/546/544/534/HOLD·strict FAIL·로그 사고·원549 REWORK·본편/출시 HOLD 불변.
  CLAUDE/STATUS/정본/제품 동작 검사 수정0, metadata-only 마감으로 후보를 유지한다.
