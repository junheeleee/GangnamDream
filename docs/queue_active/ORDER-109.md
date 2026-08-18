# Active Queue Spec: ORDER-109

> Canonical status and execution order are indexed in `docs/CODEX_QUEUE.md`.

#### [~] ORDER-109 [P0·문학 보정] M34 여섯 결말을 여섯 사건으로 다시 쓰고, 계약 보고체와 시계형 도입을 산문으로 되돌린다

**사용자 전달 전수 낭독 (2026-08-18):** M01~M36 원고 87편의 산문·인물 목소리·
감각은 합격선 이상이다. 그러나 M34 여섯 terminal은 모두 문자/음성/공식 통지의
같은 장면이고, ORDER-107에는 ‘답장을 사실로 만들지 않았다’는 작가 계약이 산문으로
새며, ORDER-106 신규 15편 중 9편은 숫자 시각으로 시작해 근무일지처럼 읽힌다.
정점으로 판정된 M33/M39/M41/M42/M45/M46/M17/M19는 문학적으로 개작하지 않는다.

## 깊이 3문

1. M34는 `reported/forgiven/leveraged/repaid/buried/distanced`라는 서로 다른 도덕적
   결말이다. 후속 장면의 차이는 통보 매체가 아니라 그 결말에서만 벌어질 수 있는
   사건이어야 한다. 이 여섯 root는 새 결정을 하나 더 묻지 않는 consequence delivery로
   바꾸고, 데이터 형식상 필요한 버튼은 각 장면의 단일 진행 동작 하나만 둔다.
2. ‘읽음·답장을 보장하지 않는다’는 작가 계약은 계속 지키되 화자가 계약을 보고하지
   않는다. 꺼진 화면, 눌리지 않은 재생 삼각형, 엎어 둔 휴대폰, 발송 시각과 빈 답장 칸
   같은 물성만 남긴다.
3. 정확한 시각은 비용과 마감을 증명하므로 지우지 않는다. 다만 아홉 장면의 첫 문장은
   사람·냄새·종이·화면·소리로 열고, 숫자 시각은 두 번째 문장 안으로 옮긴다.

## 배치 — 정확히 16개 root

### A. M34 여섯 terminal: 각 3택 → 단일 consequence delivery

1. `arc_y3_cost_after_reported` — 신고 뒤 경찰서 사건창구의 참고인 출석 통지.
   접수번호와 대기번호가 같은 종이에 찍히고, 신고가 끝이 아니라 자기 시간을 다시
   내놓는 일임을 보여 준다. 단일 진행은 참고인 대기석에 앉는 현재 행동이다.
2. `arc_y3_cost_after_forgiven` — 용서 뒤 처음 다시 마주친 상철과 식은 커피 한 잔.
   사과를 받아들인 것과 예전 거래 방식으로 돌아가는 것이 다름을 대화와 거리로 보인다.
3. `arc_y3_cost_after_leveraged` — 실제 접수대에서 `소개자: 임상철`이 찍힌 우대 배지와
   일반 수수료표가 함께 출력된다. 이미 얻은 이익이 자기 이름 옆에 남는 사건이다.
4. `arc_y3_cost_after_repaid` — 은행 무인발급기의 `입금자 임상철` 거래내역과 아버지의
   오래된 완납확인서를 겹쳐 본다. 돌아온 돈이 지난 시간을 대신 갚지 못한다.
5. `arc_y3_cost_after_buried` — 진실을 묻은 뒤 기록 없는 새 좌석 번호와 소개 카드가
   도착한다. 침묵이 비공식 호의를 허락한 것처럼 쓰이는 현재 대가를 보여 준다.
6. `arc_y3_cost_after_distanced` — 관계를 끊은 뒤 현재 주소 관리실에 상철 사무소 발신의
   무표기 봉투가 도착한다. 거리를 둔 선택이 생활공간까지 침범당하는 사건이 된다.

여섯 root는 KO/EN 모두 description 300~800자, choice 정확히 1개다. 기존
`weight:0`, `hidden:true`, `conditions.min_turn:9999`와 다른 비텍스트 필드는 보존하고
effects/flags/follow-up/writer를 만들지 않는다. 한 개뿐인 choice는 새 분기가 아니라
장면을 끝까지 통과시키는 현재 동작이며, 미래 반응·용서·거래·법적 결과를 보장하지 않는다.

### B. ORDER-107 계약 보고체 1 root

7. `arc_y3_father_avoidance_document` — C1의 ‘답은 보장되지 않았다’를 봉인된 봉투와
   발신 시각 아래 음성 사서함 표시로, C2의 ‘읽음이나 답장을 사실로 만들지 않았다’를
   눌리지 않은 재생 삼각형과 봉투 위에 엎어진 휴대폰으로, C3의 ‘아버지가 읽거나
   받아들였다고 쓰지 않았다’를 닫힌 봉투 옆 파란 `일요일 8시` 달력 칸으로 바꾼다.
   선택 수·행동·즉시 손실·구조는 그대로다. 최초 집계 밖에 있던 C1까지 포함하면
   실제 제거 대상은 20문장이다.

M34의 같은 보고체 17문장은 A의 전면 재작성에서 자연히 사라져야 한다. 전체 KO/EN에서
`읽음/답장/반응을 확인하지 않았다`, `turn ... into a fact`, `did not check/wait for a
reply/reaction` 같은 계약 보고 패턴을 다시 세어, 목표 root 안 잔존 0을 확인한다.

### C. ORDER-106 숫자 시각 도입 9 roots

8. `arc_y2_money_structure` — 처리비 네 글자로 연다.
9. `arc_y2_bank_limit_review` — 따뜻한 계산표와 토너 냄새로 연다.
10. `arc_y2_sangchul_source_review` — 소개인이 빈 수취인 칸을 두드리는 손톱으로 연다.
11. `arc_y2_chosen_door_none` — 회색 알림 안에 남은 주소로 연다.
12. `arc_y2_open_door_cost` — 담당자 칸이 빈 정산서로 연다.
13. `arc_y2_open_door_cost_explanation` — 식은 종이컵과 펴지 않은 자료로 연다.
14. `arc_y2_open_door_cost_cancel_repeat` — 좌석 번호 아래 붙은 문장으로 연다.
15. `arc_y2_daeun_relationship_fork` — 다은 명찰의 커피·비닐 냄새로 연다.
16. `arc_y2_relationship_fork_unattached` — 접힌 자국 위에 겹친 새 월세 숫자로 연다.

각 root는 숫자 시각을 description 두 번째 문장 안에 그대로 보존한다. choices/result와
비텍스트 구조는 선언 commit과 동일하고, KO/EN은 첫 이미지·시각·인과가 대응한다.

## 파일 소유권

- KO: `content/events/arc_year3_drama.json`, `arc_events.json`,
  `arc_chapter_themes.json`, `arc_daeun.json`, `arc_midgame.json`
- EN: 위와 같은 이름의 `content/events_en/` 5파일
- 기록: 이 사양, `CLAUDE.md`, `docs/CODEX_QUEUE.md`, `docs/WORK_LOG.md`, 생성
  `docs/STATUS.md`, 필요하면 ORDER-106/107의 완료 증거 문구만 정정

`story_map`, `story_rules`, 런타임·UI·저장·밸런스·자산·번역 대상 언어는 수정하지 않는다.
대상 밖 event object는 선언 commit과 동일하게 보존한다.

## 완료 증거

- [x] exact 16 roots만 바뀌고 대상 밖 object drift 0.
- [x] M34 6 roots가 각 1 choice이며 여섯 장면의 사건·장소·주요 물건이 서로 다르다.
- [x] M34 6 roots와 father avoidance의 계약 보고체 패턴이 KO/EN 모두 0.
- [x] ORDER-106 9 roots는 숫자 시각 시작 0, 같은 시각 정보 보존 9/9.
- [x] M34 신규 KO description 300~800자, KO/EN choice·placeholder·의미 대응.
- [x] strict duplicate-key JSON, EN coverage, story consistency, speech register,
  context/queue, exact scope, `git diff --check` 통과.
- [x] 독립 L2에서 반복 장면·설계 설명 누출·가짜 선택·시간/공간 점프·KO/EN P0/P1 0.
- [ ] 기존 ORDER-106/107 사람 L3는 그대로 보류하며, 사용자가 돌아오면 보정본을 포함해
  각 배치 무작위 3개를 판정한다.

## 사람 판정

M34 여섯 편을 연달아 읽어도 같은 우체국을 여섯 번 방문한 느낌이 없어야 한다.
한 편이라도 terminal 이름만 바꾼 같은 장면이거나, 계약 준수를 화자가 해설하거나,
시각 도입을 사물 문장으로 단순 앞치환만 해 리듬이 그대로면 이 보정 배치를 반려한다.
