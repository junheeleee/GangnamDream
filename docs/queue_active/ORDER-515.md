# ORDER-515 — 야간 습득물의 영어 명사를 본문과 맞춘다

#### [~] ORDER-515 [P2·EN 정합] rare_night_alva_find 결과 두 잎 bag→envelope

**착수 — 2026-10-10.** 457 실제 EN 플레이에서 손님이 본문의 envelope 대신
bag을 가져가는 결과를 읽었다. 원문/두 결과를 직접 대조해 가져오는 다른 선택에도
같은 불일치가 있음을 확인했다. 514는 Mac 잠금으로 실제 입력0/HOLD이므로
화면 없이 가능한 이 확인된 두 잎을 먼저 고친다.

## 단위·영향

- 지우면: 같은 물건이 발견→반환/가져옴에서 바뀌어 장면 인과가 흐려진다.
- 장기 상태: 이름·50만원·30분·10만원과 두 선택/후속 영수증의 의미를 유지한다.
- 경쟁: 한국어 봉투나 JA/zh의 현재 일관된 명사를 다시 저작하지 않는다.
  수치·도덕 해설·문체·새 사건을 함께 고치지 않는다.

## 착수·파일 소유

- root `content/events_en/rare_encounter_events.json`: exact
  `rare_night_alva_find:/choices/0/result_text`의 `took the bag`과
  `/choices/1/result_text`의 `took the bag out`에서 명사만 envelope로 교체한다.
  나머지 bytes·토큰·문단·선택 순서/텍스트는 불변이다.
- root `content/meta/release_content_inventory.json`, `docs/CONTENT_RATING_INVENTORY.md`:
  기존 검사에서 달라진 current-source content 지문만 수리한다. 공개 demo package
  manifest·등급·event count/IDs·intensity를 바꾸거나 baseline을 넓히지 않는다.
  영향이 없으면 이 두 파일도 변경0이다.
- root 운영: 이 사양/완료 archive·큐/이어보기 순번·WORK_LOG·CLAUDE 마지막갱신·
  생성STATUS·필요한 별도 판정 원장 결속. 새 오더별 report/checker/runner0.
- `/root/phone_tw_author`는 KR/EN·JA/zh 대응/원장 영향과 최종 두 잎을 독립 읽기
  검토한다. root 외 제품 파일 작성0. 기존 JA/zh hash·수용 영수증은 보존한다.

## 검증·완료

선언 commit/push 뒤 구현한다. 기존 audit_select로 이 EN 경로 영향 검사를 고르고,
EN coverage/Hangul·서사 연속성·장면음악·speech register·release inventory·demo
고정·context/queue/diff를 표적으로 확인한다. KR source/JA·zh target 불변이므로
그 잎에 새 수용 영수증을 발급하거나 번역 coverage를 늘렸다고 세지 않는다.
필요하면 기존 full-game inventory로 source hash/accepted 상태 불변을 확인한다.
독립 원문 대조·두 잎 외 diff0·새 실패0 전에 완료하지 않는다.

이 수리는 원고 증량이 아니라 같은 명사 정합만 복구한다. 실제 화면/자연 입력·
원어민·물리패드·전체제품·출시 GO를 주장하지 않는다. project.godot·사용자 저장·
원본 seed·공개 데모·과거 인간 판정·게임플레이/수치/조건/flags/후속은 변경0.
새 정본 규칙0·일회성이다.
