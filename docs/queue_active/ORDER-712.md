# ORDER-712 — 대표 경로 M19~M36 그림 가시성 집계

#### [~] ORDER-712 착수 — 2026-10-16 · C1/C2 · DECISIONS A2

PR39는 9f0d077로 병합했고 A1/710과 A5/711은 마감했다. 최신 사용자 지시대로
1→5→2→3→4이며 주도권·서사 게임 구조를 유지한다. 새 행동판/자유 이동0.

## 한정 목표·깊이 3문

장소·사람·행동을 읽는 데 필요한 그림이 실제 본문에서 빠졌는지 확인한다.
서사/효과/선택을 새로 쓰지 않는 관측 단위이며 24주 상태 차이를 만들지 않는다.
그림이 보였다는 관측과 정본에 맞는 그림이라는 판단, 과거 후보와 현 후보를 분리한다.

현재 대표 경로는 M36 완료/첫 W145 미선택이다. read113은 도달 목록 앵커이지
그림113장 또는 전부 합격이라는 뜻이 아니다. 먼저 기존 자료 형식이 같은
M19~M36 18개월을 한 배치로 집계한다. M01~M18/미래 M37~M60은 미관측을 남기고
이 범위 완료를 A2 전체 완료로 확대하지 않는다. 다음 실제 월은 정상 C1에 결합한다.

분모는 월/package/turn/event/진입회차, 하위 증거는 intro 또는 실제 선택 result/
source 문단·visual segment/원캡처다. 동일 컷 반복을 제거하고 BG/초상/CG를 각각
표시·확인된 부재·계약상 숨김/비대상·미관측으로 나눈다. 전환 black/타자 partial/
메뉴/History/월말 행정/chapter_card는 안정된 본문과 구분한다. CG의 portrait0,
bg_focus/portrait_role:none/reveal 전 숨김은 정상일 수 있고 원계약을 확인한다.
전화·회상은 채널만으로 숨김을 추정하지 않고 remote inset 계약을 읽는다.
폴백/직전 배경 잔존은 texture non-null만으로 합격 처리하지 않는다.

## exact 소유·병렬 분리

- root: 이 사양/archive, `docs/CODEX_QUEUE.md`, `docs/CODEX_QUEUE_L3_PENDING.md`,
  `CLAUDE.md` 현재행, `docs/WORK_LOG.md`, 새 결과 보고
  `docs/queue_backlog/A2_VISUAL_CENSUS_2026-10-16.md`만 쓴다.
- private `.git/order712-visual-census-20261016/`: root는 before/모집단/기존 원자료 핀/
  통합 집계/표적 raw/통합 영수증만. 원자료는 읽기 전용이며 이전 보고를 고치지 않는다.
- `/root/av_audio_status`: private `m19-m27-observations.{md,json}`만 작성.
  M19~M27의 기존 실제 캡처·입력 원장·발급 후보를 직접 읽어 분류한다.
- `/root/m32_path_review`: private `m28-m36-observations.{md,json}`와
  `visual-consumers.{md,json}`만 작성. M28~M36과 시각 소비자/원계약을 직접 읽는다.
- 비저자 `/root/m32_isolation_review`: private `independent-census.{md,json}`만.
  모집단·핀·분류·집계와 작성자들이 읽은 실제 원컷을 직접 검수한다. 첫 배치 전수.
- 에이전트는 Git/QA/engine/native UI/사용자 앱·저장 접근0. root만 Git/표적 검증.
  제품 source/자산/엔진/앱/저장/설정/project/preset/공개/기존 판정 수정0.
  확인 결함이 있으면 원컷과 기대 계약으로 봉인하고 별도 exact 수리 사양을 선언한다.

## 수용·C1 병행

그림 전무/필수 레이어 누락 확정/의도된 무그림/자료 부족/연출 부채를 분리한다.
정적 path 누락이나 미확정 의심은 actual 실패0·unknown은 통과0이다. 원월 후보와
현재 후보 사이의 소비자·문단 경계·조건·자산 영향 범위를 대조할 수 없는 관측은
과거 관측으로만 남긴다. KO/EN·CJK 본문/원장·오디오·R6·새 시스템은 비소유다.

현재 제품 9c7dee4 CI38915933286은 진행 중이며 녹색으로 세지 않는다. 실제 실패가
나오면 먼저 수리하고 새 월을 열지 않는다. 전체 success 뒤 보존 W145/M37에서
새 정상 C1 후보로 즉시 재개하며 A2 과거 집계가 완주를 기다리게 하지 않는다.
열린 실제 월 최대2/월별 관측·마감1commit·완료월/보조경로 재플레이0·H3/HOLD 보존.

문서 영향 선택은 `audit_select --list`만 확인하고 context/queue/diff 및 독립 원컷
검수로 마감한다. 새 engine/240주/전체 로컬 audit/중복 UI 캡처0.
규범은 최신 DECISIONS/기존 시각 정본이 소유한다. 이 범위·실행 지시는 일회성이다.
자동 게이트는 도달 가능성과 계약 충족의 증거이지 재미·깊이·문체의 증거가 아니다.
