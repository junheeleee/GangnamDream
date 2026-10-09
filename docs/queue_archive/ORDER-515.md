# ORDER-515 — 야간 습득물의 영어 명사를 본문과 맞춘다

#### [x] ORDER-515 [P2·EN 정합] rare_night_alva_find 결과 두 잎 bag→envelope

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

## 2026-10-10 완료 — 두 결과의 물건 정합 한정

구현 source `1cee2677aa2299d34ef2901b97a79cda194ac003` / tree
`039b8d995931b30ba9876f9523bfe6800cf6e500`. 선언 `bb14155`를 main에 push한 뒤
EN 파일 하나·위 결과 두 잎의 명사만 고쳤다. blob
`0e5acab1c712b3e05c1945de5e8ed52649d6df5e`, 파일 SHA256
`47af3c0f732d07a1f628c7e7ccfc50c7aa710e0ae858d2658f2574a96c970ddc`.

- 기존 영향 선택기는 EN 한 파일에35검사를 제안했다. 문장 명사만 바꾸므로
  DECISIONS 2026-10-08의 표적 비용 상한대로 전체 검사/새 도구/새 보고/엔진0이다.
- 실행한 기존 검사 모두 exit0: EN coverage, English Hangul(content0/format0,
  registry52), narrative continuity, scene audio(cg75/peak115/amb39/music20/
  demo45/foley41), speech register(KO1813/EN1813), release inventory
  (current1813, frozen demo1806/shipping1696/author_only110), demo localization scope,
  JA demo inventory1172/audit, ZH translation audit. 데모는72사건/467잎·dynamic701
  기존 범위를 유지하며 skeleton/beta를 shipping 완성으로 올리지 않았다.
- `/root/phone_tw_author`는 선언 source와 구현의 전체 파일 바이트를 직접 비교해
  정확 두 sentinel 각1회 교체 외 차이0을 확인했다. KO 원문·EN 본문·두 결과와
  JA/간체/번체 대응을 읽고 `{name}`/30분/10만원/50만원·문장부호·줄바꿈6/7·
  문단4/3·선택/효과/후속 불변을 대조했다. 보호 tracked523파일의 변경0을 확인했다.
- 비저자가 두 잎×JA/CN/TW 영수증6개를 기존 digest와 직접 대조해 source/target
  모두 일치했다. 원장 대상은 KO-source/JA·zh target이므로 EN 영수증 신규0이다.
  심의 candidate7축 어디에도 이 사건이 없고 전체 corpus ID/수량도 같아
  release inventory·생성 심의표 변경0이다. 공개 데모14사건 밖/legacy KO pin
  불변이다. 고정 공개 package의 예전 수량을 현재 shipping1702와 혼동하지 않는다.

독립 source 정합 한정 GO다. root가 실행한 기존 자동 검사는 위 결과로만 결속하며,
비저자는 공식 검사·엔진·CUA·파일쓰기0이다. package ZIP 재해시·실제 화면/자연입력·
원어민·인간·물리패드·전체 제품·출시 GO가 아니다. ORDER-514 실제 재플레이는
Mac 잠금/HOLD를 유지한다. 과거 인간 판정·사용자 저장·공개 데모는 변경0이다.
