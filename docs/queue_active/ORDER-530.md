# ORDER-530 — 실제 앱 종료 ObjectDB 누수 객체 진단

#### [~] ORDER-530 [P1·종료 품질] 경고의 실제 객체명을 얻고 수리 대상을 좁힌다

**착수 — 2026-10-10 / 선언commit·push 뒤 실행.** [529](../queue_archive/ORDER-529.md)의
상철3선택·정산1→M05 기능/보존은 한정GO지만 정상CmdQ가 새 ObjectDB 종료누수
경고1건을 남겨 전체REWORK다. 현재 로그에는 객체명이 없다. 추정 정리코드를 넣지
않고 동일 설치앱의 verbose 한 번으로 실제 타입/신원을 얻는다. 이 오더는 진단만이며
확인된 소비자의 소스수리·재발급은 별도 선언한다. M05나머지 진행보다 우선한다.

## 깊이3문

1. 이 진단이 없으면 정상 종료에서 남는 객체를 추측으로 고치거나 경고를 숨기게 된다.
2. 선택·정산을 더하지 않고 같은 M5 저장/첫문단/대화기록 읽기만 재현한다.
3. 기존 원고·효과·입력·공개본을 보존하며 실제 종료 로그의 객체와 소유자만 판정한다.

## 대상·소유·실행

- exact package source25fc879d39a6593e244b3905d7782f22560676c2/tree
  de0898823de1cbb26ea9cfe7c5a7ccd0233b5e6a, BUILD2026.10.10.1/icu-break.
  [manifest](../agent_reviews/ORDER-526-manifest.json) SHA
  7a435023dbb662de53f02012242ffa04b106f0b56f86ab5ca6c5eab7bdf50072의 기존
  설치앱·ICU namespace만 사용한다. 원manifest NOT_RUN/공개GO 불승계다.
- root 소유: 본사양/큐·부모302·CLAUDE·WORK_LOG·생성STATUS·판정원장과 private
  `.git/order530-shutdown-20261010/` raw. 제품코드/원고/번역/project/기존helper/
  사용자저장/새checker·runner·오더별보고/재발급은 비소유다.
- source/docs/helper는 입구부터 독립 final fresh까지 동결한다. 529의 immutable57+
  raw7개를58곳으로 봉인하고 helper5/seed2/W238/player33를 전량 대조한다.
  ICU namespace의 현재9파일만 정상UI 쓰기를 허용한다. 현재save17239B/785cc062…,
  M5/elapsed16/closed[1..4]/pressure4/turn17/choice7·settlement4/498만원·70·73/
  지력66/tint13/AP2·재혁unknown0을 직접 읽고 입구에 봉인한다.
  다음 실행에서 회전할 529 Godot912B/e4aaafa0… 원로그는 새530 raw에 바이트 그대로
  먼저 보존한다. 봉인된529 raw7은 바꾸지 않으며 저장복사와 로그보존을 구별한다.
- native screenshot 접근 확인 뒤 기존builder.run_command로 설치 binary에
  **진단인자 `--verbose` 하나만** 추가해 OS1회 실행한다. 정상Continue→M05첫문단
  자연완독→정상대화기록open/현재문단읽기/close→CmdQ. 본문advance/선택/정산/
  AUTO/skip/hold/연타/설정/수동save/복사/주입0, 종료 뒤 닫힌앱 AX조회0이다.
  verbose의 타이밍 변화나 단발 비재현은 원인 해소/무경고 제품GO가 아니다.
  이 첫 탐침은 M04 연속 장면의 원실행 경로를 다시 재현한 것이 아니다.
- 원 stdout/stderr/Godot의 동일경고 거울을 중복 합산하지 않고 실제 leaked instance
  타입·ID/리소스 경로·원consumer 소유경로를 대조한다. 기존529의 경고는 보존하며
  알려진 실패 예외/검사 삭제/청취GO로 돌리지 않는다. 객체명이 없거나 비재현이면
  미확정으로 남기고 반복 실행·추정수리 대신 다음 최소 원인표적 범위를 선언한다.
- own/parent 부재/editor61385생존, exit/신원·parse/script/engine fatal/경고/누수,
  선택7·정산4/월·수치·cast·inventory 불변값과 source/보호 before=after=fresh를
  비저자가 직접 대조한 뒤 진단 범위만 판정한다. 필요 도구는 기존snapshot/admit/
  builder뿐이다. source수리·새앱/529 합격·M05이후·다른언어·인간/원어민/물리/
  청취·본편/출시HOLD다.

## 읽기 전용 준비

phone_cn_author는 대화기록 overlay의 자식소유/close queue_free·단순값 기록,
M5 camera=none·portrait idle Tween과 _exit_tree를 읽었다. 현재 직접 RefCounted
고리를 확정하지 못했으며 초상Tween도 후보일 뿐이다. phone_independent_review는
529 원경고1건/거울1건·기능/보존과 종료품질의 분리를 확인했다. 준비는 실행/원인확정
또는 수리GO가 아니다. 개발스킬의 실제소비자·표적검증·원본보존/독립판정 적용,
일회성/새규범·정본승격0이다.

## 실제 입구 — 2026-10-10 / 화면 접근 대기

선언c1bba19·생성STATUS0d7e076 main push/clean 뒤 기존 사용자Godot창 screenshot이
Mac locked/automatic unlock unavailable을 반환했다. 앱실행/입력/저장복사·주입/
입구전량snapshot0, 보안우회0이다. private raw의 preflight-locked.json
(567B/dbebe3eebb05926285701251fd4f9995bfc61f9eab3b49b9596691f1e016813b)만 남긴다.
비저자 phone_independent_review는 노트 작성 전 clean0d7e076·앱process0와 runtime9
전체=529after/save17239B·editor61385생존을 좁게 대조했다. 잠금은 root native 관찰이며
58곳 입구전량을 재검수하거나 실제진단에 GO를 준 것은 아니다.
529의 실제실행/보존 판정과 이 새입구 실패를 구별한다. 잠금 해제 뒤 fresh 입구에서
계속하며 현재까지 verbose 진단·객체명확정·수리GO는 미실행이다.
