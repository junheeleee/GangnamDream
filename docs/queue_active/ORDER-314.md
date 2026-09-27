# Active Queue Spec: ORDER-314

> Canonical status and execution order are indexed in `docs/CODEX_QUEUE.md`.

#### [~] ORDER-314 수리된 데모 KO/EN 실제 화면·입력 표적 검수

2026-09-27 착수. 사용자 개발·내부 검수 위임과 부모302의 잔여 화면 검수에 따른다.
기준 clean main `149f339747805940868dcbfe758d5a83dfe81a31`.

## 깊이 3문과 범위

- 없으면: 문자열 수리의 실제 표시·선택 결과 소비자가 미관측이다.
- 상태 차이: 새 게임 규칙을 만들지 않는다. 선택 전후 실제 이력·결과를 대조한다.
- 경쟁: 전체 회귀 반복 대신 시작 안내/M04 월세/M06 회상·무명 직원 소비자를 우선한다.
- 한 배치: KO/EN 각 home, M04 월세 본문/선택/결과, M06 회상/선택/결과/recap의
  8표면(총16 목표), 1280×800 실제 렌더와 엔진에 dispatch한 합성 키 press/release.
  필요한 본문 pagination 중간 캡처는 추가 증거이며 별도 완성 단위로 세지 않는다.
  이번은 OS 물리 키보드/패드, 인간 독해, 원어민 판정이 아니다.
- 월 진입은 기존 공개 controller의 QA fixture로 이전 선택·정산을 준비하고,
  관측할 StoryMode 본문·선택·결과 이동은 입력 dispatch로 한다. fixture 도약은
  사용자 처음부터 끝까지 입력 완주로 세지 않는다. M04 coffee 분기는 별도 미관측이다.

## 파일 소유와 검증

- root: 이 사양·큐2개·부모302 진행 꼬리·CLAUDE 현재행·WORK_LOG·생성STATUS;
  `.git/full-game-localization/order314-*` 중 launcher/사용자보존 census/raw 증거.
- `/root/screen_path_probe`: private `order314-screen.gd`, `order314-screen.tscn`,
  `order314-bootstrap.gd`만. 기존 런타임을 instantiate하며 제품 파일 변경 금지.
- 독립 검수자: private review 및 `docs/agent_reviews/ORDER-314.json`만.
  저자와 다른 에이전트가 모든 실제 PNG·입력 로그·source pin·원문을 검토한다.
- 제품 코드/원고/번역/게임효과/공개 package/과거 수용·인간·판정 원장은 무수정.
  결함 발견 시 이번 검수 결과를 보존하고 수리는 새 파일 범위로 별도 선언한다.
- pre-autoload fresh RuntimeQA32hex namespace, HOME 유지, 사용자 저장/설정 전후
  census/hash 동일, source/helper SHA·commit/tree 전후 동일, timeout과 프로세스 정리.
- 각 실행 exit0, exact marker, stdout/stderr/Godot 로그 오류0, 실제 PNG 크기 확인.
  raw 로그와 실패 증거를 지우지 않는다. 기존 5언어 headless/720검사 재실행 없음.
- 완료 시 context/queue/diff/생성STATUS 표적검사. 위임 작업한정 판정만 별도 기록하며
  제품·패키지 GO는 발급하지 않는다. 전체302·본편 HOLD, 인간OPEN45·공개GO1 보존.
- 이 사양은 일회성 검수 지시다. 입력·안전영역 정본은 INPUT_MATRIX와
  CONTROLLER_UX_STRATEGY를 따르며 새 규범을 만들지 않는다.

## 2026-09-27 실제 관측 결과 — 안전 여백 REWORK, 미완료

- 선언/현재행 정리 뒤 frozen source는 `eb285b3cecdad43fd5eb0dd518da29775d113fab`,
  tree `138108b2216257d611e2230660b7d6409f5b8c42`다. 제품 수정은 0이다.
- KO/EN 각 8 논리 표면을 실제 1280×800에서 관측했다. 최종 settled PNG는
  KO47/EN48(총95)이며 월세70만원, 시작 안내의 야간 단기 일, 빗길 회상,
  이름을 모르는 야간 직원 결과, 현재형·인용·선택이력 소비자를 대조했다.
- M04 meet0→measure0→answer1, M06 무명직원0 경로다. 관측 구간은 실제
  StoryMode에 합성 키 press/release KO180/EN184 edge로 진행했다. 이전 월은 fixture로
  준비했으므로 처음부터 끝까지 사용자 입력 완주가 아니다. 각 9선택/영수증9,
  6정산·24주·turn25·현금632만원이 recap과 일치했다. coffee 분기는 미관측이다.
- 첫 KO/EN 실행은 애니메이션 도중 찍힌 흐린 선택지·인물 전환이 있었다. 원형
  `order314-*-first`와 첫 helper를 보존했다. private 캡처 대기를10→40프레임으로
  늘리고 유효 alpha를 기록한 `order314-*-settled`에서 안정된 최종 화면을 확인했다.
  제품 애니메이션을 고친 것이 아니다. 총 실제 실행4회, 최종2회 63.5571/64.5174초.
- 최종 두 실행 모두 exit0·exact marker 각1·ENTRY 각3·3로그 오류/누수0,
  사용자43파일 및 선택 source/helper1223핀 전후 불변, 종료 후 자식 잔존0이다.
  최종 helper SHA `1fa9d7d833603ad60286564a6196410fcb8c4af272f36c581925004296894111`,
  launcher SHA `6753783c975a55b87d85ff62ed51582da89ca9c9bf93ad776df17d5ee3a829d8`.
- 실제 렌더에서 StoryMode 설정·대화기록 y4/설정 right1266·HUD left24,
  home/recap 제목 left20·언어 버튼 right1260을 확인했다. 정본2.5%의
  x32..1248/y20..780 밖이다. 본문·선택지는 읽히지만 전체 화면 적합 GO는 아니다.
  독립 [보고](../agent_reviews/ORDER-314.json)와 새 [315](ORDER-315.md) 수리로 분리한다.
- 이 항목은 `[~]`로 남긴다. PNG 관찰·합성 키 경로는 인간·원어민·물리 패드/OS 입력·
  정상 속도 독해·오디오 평가·새패키지 승인으로 승격하지 않는다. 부모302/본편 HOLD,
  옛 공개GO1·인간OPEN45·공식수용40299/private153/보류72와 과거 판정은 보존한다.
- 독립 비저자 판정: `ORDER-314-SAFE-01` P2 필수 수리1건, 작업한정 REWORK.
  공개 보고 SHA `3e5294c07f73cbd6f5ea661aeda63bab061f1866aadcace7133979ac156c4403`.
  최종95PNG 전수 독립 관찰·219실행/보조파일 hash 대조다. 선택지가 뜨면 마지막
  산문이 가려지는 캡처가 있으므로 telemetry의 본문을 화면 독해로 세지 않는다.
  앞선 수정21문구 전부 또는 모든 원문 문단을 눈으로 관측했다고 주장하지 않는다.
- 첫 마감에서 queue81/진행75·queue-self25·humanOPEN45/DONE1·agent-self222·
  기존96판정 byte prefix/97행/168증거파일 보존 검사는 PASS였다. context는 부모302가
  16447byte로16000 한도를 넘어 FAIL1을 보존했다. 완료 A/B 선언·검증 원문을
  `queue_archive/ORDER-302_L1_L2_RESULTS.md`로 이동하고 부모에는 링크를 남겼다.
  이는 완료 기록 이동이며 부모302를 닫거나 역사 사실을 요약·삭제한 것이 아니다.
  영향 있는 context/queue/이동 byte 보존만 재검사하고 엔진·222검사는 반복하지 않는다.
