# ORDER-539 — 첫 근무 세 장면의 급여 시점 정합

#### [x] ORDER-539 [P1·원고 정합] 첫 근무 3종 × 5언어 — source 한정 GO

**완료 — 2026-10-10 / source 한정 GO.** 부모 [534](../queue_active/ORDER-534.md)의 정상 본편
입구 REWORK를 수리하기 위한 읽기 중 확인한 원고 결함이다. 538의 격리12주
source GO를 기본 본편·M07 GO로 확대하지 않는다.

## 깊이 3문·배치

1. 고정 `첫 월급까지 세 주/며칠`을 두면 월말 급여 owner와 장면의 시간이 충돌한다.
2. 새 선택을 만들지 않는다. 기존 취업 수락/거절·직업·급여·선택 효과를 보존하고
   현재 근무를 묘사하는 본문만 맞춘다. 취업한 주 이후·근속≤1은 정확7일이나
   급여미수령을 보장하지 않는다.
3. 원래 첫 근무 장면·선택 슬롯과 경쟁하는 새 입력/장면/관리판은 0이다.

모집단은 `arc_first_job_week`, `_convenience`, `_delivery`의 description
각 KO/EN/JA/zh-CN/zh-TW, **15잎 한 배치 전수 독립 검수**다. 장면 심화가 아니라
기존 장면의 확인된 기간·지급 주기 정합 수리다. 제목·선택·결과·연출은 그대로다.

## 정확한 파일 소유

- root: `content/events/arc_midgame.json`, `content/events_en/arc_midgame.json`의
  위 description 3개만. `content/meta/full_game_localization.json` 공식 수용,
  `content/meta/release_content_inventory.json` 실제 바뀐 지문만,
  `docs/CONTENT_RATING_INVENTORY.md` 필요시 기존 생성기 재생성.
- phone_cn_author: `.git/order539-qa-20261010/` 안 공식 export/response 초안만.
  JA·zh 두 지역은 KO에서 각각 직접 작성한다. 제품 overlay/원장은 root가
  공식 check/import로만 쓴다. 수용 대상은 `content/events_ja/arc_midgame.json`,
  `content/events_zh-CN/arc_midgame.json`, `content/events_zh-TW/arc_midgame.json`의
  같은 description 3개다.
- cjk_wrap_diagnosis: 도구·급여/소비자 읽기 검토만, 제품 저작0.
- phone_independent_review: 비저자 전수 검수·원본 보존·source/raw 결속,
  `docs/agent_reviews/ORDER-539.json`. root는 큐/L3 순번·이 사양·WORK_LOG·CLAUDE
  현재행·agent 판정원장·완료 archive만 관리한다. 기록 예산 초과 시 기존
  WORK_LOG 원문을 `docs/history/WORK_LOG_2026-10-10_pre_order539_close.md`에
  바이트 그대로 보관하고 live 링크를 잇는 통상 기록 회전도 root가 소유한다.

## 구현·검증 경계

- 고정 일주일/급여 잔여기간/배달 주간 지급 전제를 제거하고 현행 월말 지급과
  모순 없는 첫 근무 감각·교대·당월 정산표만 쓴다. 급여 액수/지급/일할 계산0변경.
- KO/EN 확정 후 정확3 leaf IDs로 locale별 export→직접 번역→check→
  `import --accept --replace-existing`를 수행한다. 옛 batch·영수증은 보존하고
  이번 correction은 새 coverage로 세지 않는다.
- 영향 검사 선택을 먼저 읽는다. EN coverage/한글·현행 번역 원장·서사 연속성·
  장면 음악·말투·demo 고정·release inventory·diff·기록 정합을 표적으로 실행한다.
  기존 실패는 전후 원문으로 귀속하고 새 실패0이어야 한다. 전체 감사/240주/비용
  도구/검사 완화/STATUS-only 추종commit0.
- gameplay/다른잎/공개 M01–M06 장면·demo pin·arc_events.json·프로필8/12·기본
  입구·V2·project·사용자 저장·역사 인간/에이전트 판정은 불변이다.
  엔진 실행이 필요한 경우만 기존 pre-autoload bootstrap/fresh HOME·XDG·namespace와
  3stream/exact marker를 사용한다. 함수 검사는 실제 앱/자연완독 증거가 아니다.

## 완료·남은 경계

15잎·공식9 correction·gameplay/다른행 불변·표적 새 실패0·정확 후보의 비저자
GO만 닫는다. 자동 계약은 재미·깊이·문체의 증거가 아니다. 원어민/실제 화면/
물리 패드/본편 입구534·M07·출시는 미관측/HOLD다.
W13 이후 실제 취업→근무→첫 급여 독자·cold resume, 상철의 두주 선행,
첫 사무근무 결과의 미보유 자산 단정은 별도 범위다. 새 cap만 늘리지 않는다.
새 정본 규칙0, 이 사양의 실행 지시는 일회성이다.

## 구현·표적 결과

KO/EN6·KO직접JA/CN/TW9의15description을 비저자가 전수 읽어 문안
preliminary GO, retouch0이다. 기간 단정만 제거하고 월말 지급·장면 감각을 맞췄다.
공식check/import6회 PASS, correction9를 새coverage로 세지 않고 기존306batch와
accepted개수를 보존한다. 기준HEAD980e793 뒤 작업트리 원문을 export했으므로
source_revision을 수정원문commit이라고 주장하지 않는다. 실제manifest/leaf SHA와
최종 제품commit의 본문을 독립 결속한다.

표적20검사20 PASS/새실패0, 원6회12stream+20회40stream을 private에 보존한다.
전체감사/기존census 실패수리/엔진·앱·실제화면·입력0이다. 최초 숫자/반복표기
불일치도 원형에 보존하고 동일사실로 정렬했으며 checker/예외 변경0이다.
현재15잎 외 gameplay·데모·저장/인간/과거판정 보존 및 clean source의 최종 보고는
결속 후 마감했다. 이 기록은 정상본편/M07/취업→급여 연결 GO가 아니다.
후기록의 WORK_LOG 40000B 예산 초과는 이전HEAD 원문39496B를 위 보관본으로
옮기고 현재절/링크만 live에 남겨 닫는다. 과거 원문은 삭제·재서술하지 않는다.

## 독립 최종 판정

[최종 보고](../agent_reviews/ORDER-539.json) 8561B/
`3f992dfc3b14e1f3324dd37be2f49631e4d5d785358c8c8882825f1951cd6910`는
clean main `2b7569db9637283ff9db5bb62c714217b76b2fa6` /
tree `1abf66e2a703869d7d12fbfc091b79c150ad5585`의 이 단위만 GO다.
15잎/9교정/지문1·공식12/정적40stream과 비소유제품2387·보호22그룹492파일/
player33·과거277판정·원문회전39496B를 전수 결속했다. 전체제품/실제화면/
534·M07/출시는 HOLD이며 새 정본승격0/실행지시 일회성이다.
