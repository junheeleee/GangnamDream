# ORDER-490 — 현재 진로와 방문 장소의 산문 사실 수리

#### [~] ORDER-490 착수 — 기존 EXPOSED 실패와 실제 직업 전제5잎 — 2026-10-09

## 근거 / 정확한 모집단

DECISIONS 2026-10-08의 기존 영향 검사 상한과 사용자 개발·품질 판단 위임을 따른다.
선행487은 실제 main CI 녹색으로 닫혔고488/489도 완료했다. 현재 EXPOSED 실패6은
직업 도메인 미등록3·관계 미등록1·현수 주거 명시 누락2다. 도메인만 덧붙여
미취업/비동료 경로의 잘못된 산문을 덮지 않고 실제 원문부터 수리한다.

- arc_35_orthodox_weight.description: 월급·퇴근·3년간 같은 급여 전제를 뺀다.
  자동이체·느린 축적·SNS 코인1억/동창 대비·가계부·앱 재개방은 보존한다.
- arc_father_06_confession.choices[0/1].result_text: 현재 같은 사무실/책상의
  동료·차트 지도를 확정하지 않는다. 이미 경험한 상철 사무소의 커피 제안으로
  얼굴을 연결하고 아버지의 무지·끊긴 대답·전화 쥔 손을 보존한다. EN Im 표기도 정렬한다.
- arc_minjun_first_call.choices[1].result_text: 현수의 근무를 단정하지 않는다.
  형/오랜만·휴식·밥 제안·한 달 뒤 약속을 보존한다.
- hyunsu_result_pass.description: 기존 메시지→복도→방문 이동에 현수가 사는
  고시원까지 찾아간 것을 명시한다. 합격·폰·흰 손끝·4년·첫 알림은 보존한다.
- 위5잎 KO/EN 각5, JA/CN/TW 각5의 기존값 교정이다. 새 coverage가 아니다.
- exposed_event_state_contracts의 위3사건 및 person_deal 도메인은 실제 교정 후
  탐지/본문 의미에 맞게만 정렬한다. person_deal은 relationship 등록만 하며
  본문/DIK/조건은 불변이다. job 조건 추가나 실패 검사 완화는 하지 않는다.

## 깊이 3문 / 제품 의미

- 없으면: 취업하지 않은 민준/현수에게 근무 사실이 붙고 커피 만남만 한 상철이
  현재 동료로 변한다. 현수 합격 방문도 민준의 현재 집과 혼동될 여지가 남는다.
- 24주 뒤: 기존 합격/전화/아버지 진실·모든 선택 효과와 미래 독자는 그대로다.
  새 취업·임용·초대·화해·예약·관계 상태를 만들지 않는다.
- 경쟁: 진로 자유와 기존 기억의 충격을 함께 지킨다. 현재 일자리/주거를
  고정하는 대신 실제 경험한 커피·기다린 합격·느린 잔고를 회수한다.

## 파일 소유와 금지

- root KO/EN: content/events{,_en}/arc_chapter_themes.json, arc_drama.json,
  arc_year3_drama.json, arc_hyunsu.json의 exact5잎만.
- root 공식 수용: 같은4파일의 content/events_ja, events_zh-CN, events_zh-TW;
  content/meta/full_game_localization.json. 확정 KO에서 각 지역 독립 저작,
  기존 export/check/import --accept --replace-existing로 바뀐5잎만 수용한다.
- root: content/meta/exposed_event_state_contracts.json의 선언한4행 도메인만.
  지문이 실제 바뀔 때만 release_content_inventory.json/CONTENT_RATING_INVENTORY.md
  기존 생성기로 갱신. EXPOSED 실제 PASS 뒤에만 KNOWN_FAILURES 정확1행 제거.
- 운영: CODEX_QUEUE/이어보기 순번, 이 사양/완료 archive, WORK_LOG, CLAUDE현재,
  생성 STATUS. 저자는 private exchange만, 비저자는 실제 diff·KO원문·번역·원장·
  ingress를 메시지로 독립 검수한다. 새 오더별 보고/판정 원장0.
- 조건·효과·플래그·선택 개수/순서·라우팅·runtime·자산·저장·project.godot·
  arc_events/공개 M01~M06·과거 인간/에이전트 판정은 불변. 새 검사/계측/이력 도구0.

## 표적 검증 / 종료

선언 commit/push → KO/EN 확정 source commit → official source-bound export와
교정 수용 → EN coverage/Hangul·narrative continuity·speech register·scene audio
contract·exposed state·story consistency·전체 원장/번역 overlay 영향 lane·release
inventory·보호 데모·context/queue/diff를 기존 검사로 실행한다.
전체 JSON 역상으로 비소유 prose/모든 gameplay 불변을 확인하고 비저자 메시지 검수
후 source/운영/생성 STATUS를 main에 commit/push한다. 기존 실패를 숨기지 않는다.
스케줄러/저장/엔딩 변화0이므로 전체 audit/엔진/240주 시뮬 반복0.
Mac 실제 화면은 잠금으로 미실행이며 원어민·인간·물리패드·출시 GO로 바꾸지 않는다.

새 규범0. 기존 STORY_BIBLE/STORY_CONSISTENCY/I18N_INFRASTRUCTURE/WORK_UNIT이
계속 소유한다. 이 파일 범위와 작업/검증 순서는 일회성이다.
