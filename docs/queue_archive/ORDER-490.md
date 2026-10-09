# ORDER-490 — 현재 진로와 방문 장소의 산문 사실 수리

#### [x] ORDER-490 완료 — 현재 진로·현수 방문 사실5잎×5언어, EXPOSED 실제 PASS — 2026-10-09

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

## 실제 결과 / 한정 판정

- 선언5c48461 → KO/EN source9d09b1a205e53e2791914bf8e0365df8158f9e63 →
  최종 source be3f616b6df1c3a275155e80f7c0db369569e4bb, 모두 main commit/push.
  원문5잎×5언어=25값/20파일. JSON·raw 역상: gameplay0/비소유 값·바이트0.
  실제 도메인 정렬은 person_deal relationship1뿐이다. 교정 뒤 탐지에서 사라진
  employment3을 등록해 잘못된 산문을 숨기지 않았고 검사/CI/등록 변경0이다.
- 도달 경로: MainGame.gd:7579 아버지 생존·방문·커피 사건 목격/turn>=102,
  MainGame.gd:8019 turn108~138/현재 route, MainGame.gd:8114 turn130~155/아버지 생존,
  arc_hyunsu.json:85 hyunsu_exam_day_seen/min_turn25. 커피 제안 기억은 수락/거절
  모두에서 사실이며 현수의 현재 취업·임용·민준의 직업/주거는 전제가 아니다.
  NARRATIVE_CONTINUITY_AUDIT_OK routes2/localesko-en — Python trace, 실기기 관찰 아님.
- 생산자↔독자: content/events/arc_chapter_themes.json:3,
  arc_drama.json:213, arc_year3_drama.json:535, arc_hyunsu.json:85 ↔
  autoloads/DataRegistry.gd:148/150(text-only overlay) ↔ scenes/StoryMode.gd:2588/3509.
  상태: 산문의 근무/동료 단정→실제 과거 커피·현재 자동이체·직업 중립 전화,
  현수 방문 장소의 불명확성→현수가 사는 고시원 명시. 수치·플래그·조건 변화0.
  포기 비용/미래 독자/계층: 기존 선택·회수·분기 불변, 새 심화0.
  서사 위치: 기존3장 M32 진실·M35 첫 전화/느린 축적, 현수 합격 결과 회수.
  닫는 것: EXPOSED_STATE_EXIT 실제 실패6→0, known2→1(PEAK/2026-10-16 보존).
- KO 직접 source-bound 공식 export/check/import --accept --replace-existing:
  JA/CN/TW 각5잎·4파일 PASS, 새 coverage0. source manifest
  027b91ddf60658cf4199dd800a31c1345de0f5297c6a22d412c9125f30095cd0;
  official header/수용 영수증3 보존, accepted41887 불변/15해시 교정/batches285→286.
  accepted checksum3b9537d3beefda137aa8d041ad07c65de8906e960736e89264787309d006216e.
  각 수용 응답·현재 원문·현재 overlay와 committed receipt15 일치/translation_errors0.
  기존 원장 전역 metadata·옛285batch·비소유 receipts 불변. 전체 상태 INCOMPLETE,
  native/rendered OPEN을 유지한다. 중국어 자동 변환·영어 pivot0.
- EXPOSED_STATE_CONSISTENCY_AUDIT_OK roots380/exposed531/sensitive523/neutral8,
  employment103/father_life169/housing218/location486/relationship260.
  EN coverage/Hangul(content issues0/format52)·narrative continuity·speech register
  (events1813/contracts28)·story consistency(unclassified0)·scene audio contract
  (cg75/peak115/ambience39/music20/demo45/foley41)·prose recall(current40/locale) PASS.
  보호 데모 scope72/467/skeleton, public14/100, JA demo72/467/errors0와 ZH demo PASS;
  i18n coverage strictEN1813/1813/endings35 PASS. 더 넓은 ZH UI/dynamic 미완성은 별개다.
  release inventory 실제 변동 gambling/sexuality/fear 지문3만 갱신/생성 보고 일치,
  current1813/story_demo1806/shipping1696/author_only110/axes9/network0 PASS.
- 독립 manifest_alignment_review가 최종 source/25값의 raw 역상·실제 ingress·
  KO와 번역15·공식 수용3/현재receipt15·도메인1·지문3을 직접 읽고 EXPOSED를
  재실행해 source 사실·번역·수용 정합 GO/blocking0. KNOWN 정확1행 삭제와
  PEAK/Codex/2026-10-16 보존까지 최종 검수했다. 새 formal보고/에이전트 원장0.
  과거 인간 판정·runtime·저장·project·공개 M01~M06/arc_events 변화0.
  기존 영향 검사만 실행/전체 audit·엔진240주·새 도구·계측·이력 검사0.
  운영 종료: CONTEXT_MANIFEST_CHECK_OK boot_bytes30054/docs595/classified595/
  links187/invariants15; QUEUE_CONSISTENCY_OK active78/in_progress76/max_batches2;
  두 큐의 선언 전7549d4b 바이트 복귀/diff --check PASS, 기존 생성 STATUS 갱신.
  Mac 잠금으로 화면 미실행, 원어민·인간플레이·물리패드 미관찰, 본편 출시 HOLD.
  자동 계약 PASS는 재미·깊이·문체/사람 GO가 아니다. 새 main CI는 별도 확인한다.
  개발 스킬의 선선언·정본/사용자 변경 보존·표적 검증·작은 diff를 적용했다.
