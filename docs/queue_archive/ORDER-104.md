# Archived Queue Spec: ORDER-104

> Canonical status and execution order are indexed in `docs/CODEX_QUEUE.md`.

#### [x] ORDER-104 [P0·서사 원고] 처음부터 완결까지 22개 핵심 장면의 실제 원고를 쓴다

**사용자 지시 (2026-08-18):** “내가 지금 밖이라 확인해볼 수 없어. 일단
스토리랑 지문, 선택지에 모든 시간을 할애해 처음부터 완결까지.” 사용자가 돌아올
때까지 시스템·UI·저장·밸런스 확장은 멈추고, 60개월 전체의 실제 원고를 우선한다.

## 깊이 3문

1. 60개월 표만 있고 실제 장면이 없으면 지워도 체감이 같다. 특히 4·5장 고유
   경로는 실제 KO/EN 원고가 절반 이하라 후반 관계 폭발과 완결이 존재하지 않는다.
2. 다시 M01~M06만 다듬으면 이미 반복한 24주 편중을 재현한다. 첫 배치는 M01의
   첫 선, 각 장의 결정·보스, Ch4 청구서, Ch5 이름·서명까지 처음과 끝의 기준
   장면을 함께 쓴다. 단, 서로 다른 관계 경로의 장면을 한 실행선인 것처럼
   주장하지 않는다.
3. 도달 라우팅까지 같은 배치에 넣으면 원고 판단과 시스템 결함이 섞인다. 이번에는
   사건 원고와 선택의 인과만 쓰고 `EXPAND/needs_rule`로 정직하게 표시한다. 실제
   스케줄·StoryLedger·엔딩 라우팅은 다음 이관 오더가 소유한다.

## 배치 — 22개 판정 단위

1. M01 `arc_temptation_01` — 첫 불법 제안의 사람·돈·몸의 즉시 대가.
2. M12 `arc_year1_close` — 첫 선과 첫해에 지킨 사람을 다음 장의 질문으로 잠근다.
3. M23 `arc_34_parents_visit` — 사람을 거쳐 연 문과 가족 문턱을 같은 밤에 둔다.
4. M23 `arc_father_04_visit` — 병실에 들어갈지 피할지 실제 대면에서 결정한다.
5. M24 `arc_year2_close` — 열린 문·병실 문·보호한 사람을 3장 입력으로 남긴다.
6. M30 `arc_jaehyuk_04a_ghost` — 친구의 서명과 아버지 보증의 닮은 모양을 본다.
7. M33 `arc_sangchul_confrontation` — 진실을 어떻게 소유할지 상철 앞에서 고른다.
8. M36 `arc_year3_close` — 그 선택을 들은 사람과 4장의 청구서를 예고한다.
9. M39 `arc_y4_three_promises` — 돈·가족·사랑이 같은 주말 한 프레임에서 충돌한다.
10. M41 `arc_y4_body_witness` — 몸의 이상을 본 사람 또는 부재를 실제 장면으로 남긴다.
11. M42 `arc_y4_family_partner_collision` — 가족과 연인이 같은 식탁에서 서로 말한다.
12. M45 `arc_y4_borrowed_name` — 타인의 이름을 계약에 쓰는 문제를 원문 동의로 묻는다.
13. M46 `arc_y4_bill_night` — 몸·아버지·연인에게 온 청구서의 부재와 도착을 보여 준다.
14. M48 `arc_year4_close` — 몸의 목격자와 마지막 연락을 최종해의 보호 맥락으로 잠근다.
15. M52 `arc_y5_final_offer` — 경제 경로마다 다른 서류로 같은 도덕 질문을 연다.
16. M54 `arc_sangchul_final_door` — 상철의 마지막 문과 차가운 커피를 실제로 회수한다.
17. M55 `arc_y5_three_in_room` — 제안자·검토자·보호 대상이 실제 같은 방에 모인다.
18. M55 `arc_y5_three_in_room_decision` — 역할이 겹친 사람의 이해충돌까지 확정한다.
19. M57 `arc_y5_name_on_line` — 누구의 이름과 시간을 담보로 쓸지 최종 사실로 남긴다.
20. M58 `arc_y5_people_verdict` — 무연애 경로에서 현수·민서의 서로 다른 판정으로
    이름 사용의 값을 보여 준다. 다은 기준 경로의 M58은 기존
    `arc_daeun_final_choice`를 재사용한다.
21. M60 `arc_final_countdown` — 5년의 선택을 마지막 서명 한 줄에 회수한다.
22. M60 `arc_final_week` — 목표 달성 여부와 별개로 남은 사람의 이후를 보여 준다.

각 단위는 300~800자 규모의 핵심 교환을 갖고, `도착 → 교환 → 압박 상승 →
전환 → 선택 → 경로별 결과 → 여운` 중 해당 장면에 필요한 고리를 실제 문장으로
쓴다. 선택은 요약 태도 3개가 아니라 서로 다른 것을 지키고 놓치게 한다. 그달의
선택된 약속 또는 직전 receipt가 첫 문장·참석자·부재·선택지 중 최소 하나에
드러나야 하며, 장기 결정은 기존 7개를 늘리지 않는다.

이번 22단위는 하나의 실행 가능한 세로 루트가 아니라 **기준 경로 원고와 대체
경로 앵커 묶음**이다. Ch4 기준 경로는 다은·상철·아버지가 실제로 충돌하고,
Ch5 기준 경로는 상철이 가져와 검토한 계약, 재혁의 보증 부탁, 다은의 이름이
같은 회의실에서 부딪친다.
`arc_y5_people_verdict`는 별도의 무연애 경로에서 현수·민서가 만나는 장면이다.
M55 기준 원고에서 상철은 제안자와 검토자를 함께 맡지만 다은·재혁과는 다른
사람이다. 지연·무연애·전원 분리·다른 배우 합류 같은 조합은 이 공용문으로 덮지
않고 각자의 NEW fallback으로 남긴다. 따라서 `needs_rule`인 기준 원고도 이 정확한
출연 조합 외에는 라우팅하지 않는다.

## 원고 원칙

- 선택 전에는 위험의 모양만 보이고 정확한 먼 결과는 숨긴다.
- 마지막 문장은 의미를 해설하지 않고 행동·사물·침묵·공간 이미지로 닫는다.
- 다은·지연·현수·아버지·상철·재혁은 이름만 언급하지 않고 실제 말과 반응을 한다.
- KO가 원문이고 EN은 직역보다 장면 의도·호칭·시제를 보존한다.
- 기존 강한 장면은 ID와 생산 사실을 보존하며, NEW 원고는 실제 KO/EN에 존재한
  뒤 `EXPAND/needs_rule`로만 바꾼다. 아직 쓰지 않은 fallback은 NEW로 남긴다.
- 마지막 서명과 후일담을 써도 현행 조기 `finish_run()`과 35개 엔딩 판정은 이번
  배치에서 고치지 않는다. 원고 완료와 실제 도달 완료를 같은 주장으로 세지 않는다.

## 정확한 파일 소유권

**선언·마감:** `CLAUDE.md`, `docs/CODEX_QUEUE.md`, 이 사양,
`docs/WORK_LOG.md`. 부팅 예산을 지키기 위한 원문 이동만
`docs/history/WORK_LOG_2026-08-04.md`가 함께 소유한다.

**KO/EN 원고:** `content/events/arc_events.json`, `content/events/arc_midgame.json`,
`content/events/arc_year_close.json`, `content/events/arc_drama.json`,
`content/events/arc_chapter_themes.json`, `content/events/arc_pre_ending.json`과
동일 이름의 `content/events_en/` 6파일.

**월간 상태:** `content/meta/story_map.json`. `tools/story_map_audit.py`는 기준
출연진 분리로 낡은 단일 self-test fixture 하나를 같은 의미의 fallback fixture로
옮기는 정합만 소유한다. `content/meta/narrative_spine.json`과
`tools/narrative_spine_audit.py`는 새 M55 회의를 `planned`에서 실제 Ch5
anchor/reader로 승격하는 정합만 소유한다. `content/meta/story_rules.json`은
결정 생산자·독자를 정확히 결속할 때만 수정한다.

그 밖의 런타임·UI·저장·밸런스·빌드·자산·번역 파일과 `project.godot`은 수정하지
않는다.

## 완료 증거

- 22개 root가 KO/EN에 모두 존재하고 선택 수·순서·후속 ID가 맞는다.
- 신규 base root만 `EXPAND/needs_rule`, 미집필 fallback은 `NEW/planned`로 남는다.
- 선택 결과가 장기 결정 7개를 늘리거나 독자 없는 영구 flag를 만들지 않는다.
- JSON duplicate-key, `story_map_audit`, 한영 coverage, story consistency,
  `audit_select --list`로 영향 목록 확인, `git diff --check`만 실행한다.
- 전체 감사·240주 시뮬레이션·Godot 장시간 검사는 실행하지 않는다.

## 2026-08-18 L1/L2 결과

- 22개 기준 root와 M60 미접수 보조 root 1개를 KO/EN에 작성했다. 기존 11개
  root는 텍스트 외 게임 구조를 보존했고, 신규 12개 root는 실제 원고가 있는
  `EXPAND/needs_rule`로 승격했다. 미집필 배우·결과 조합은 NEW로 남겼다.
- Ch4 기준은 다은·상철·아버지, Ch5 기준은 상철의 제안·검토 이해충돌,
  재혁의 보증 요청, 다은의 이름이다. M58은 별도 무연애 현수·민서 장면이다.
  접수·미실행·미접수와 다른 명의 결과는 서로의 문장을 재사용하지 않는다.
- `story_map` 일반/자가 75건, narrative spine, 한영 coverage, story consistency,
  말투, 정점 장면 32개, 14 JSON strict parse, 22+1 root 구조 계약과 diff 검사가
  통과했다. 전체 감사·240주·Godot는 실행하지 않았다.
- Claude 위임 L3는 seed 9821 무작위 3편 낭독으로 완료했다. 정본 서명인 사용자
  최종 GO는 `docs/human_gates.json`에서 OPEN으로 유지한다.

## 2026-08-21 L3 판정

- 방법: 이 오더의 22개 판정 단위 모집단에서 seed 9821 무작위 3편. 별도 M60
  미접수 보조 root는 모집단에 합치지 않았다. 축은 인물 목소리 / 지금 잃는 것 /
  다음을 기다리게 하는 여운.
- **판정: Claude(사용자 위임) — 합격.** Claude 판정 요약은
  `arc_y4_body_witness`에서 다은이 문턱에 멈춰 허락을 묻는 행동이다.
- **사용자 최종 GO: 미서명(OPEN).** 위임 판정과 정본 서명을 합치지 않는다.

## 정본·일회성 판정

- 새 정본 승격 없음. 배우·선행조건 발명 금지와 현재 손실·먼 결과 비노출은
  `CLAUDE.md`, `docs/STORY_CONSISTENCY_SYSTEM.md`,
  `docs/CHOICE_CONSEQUENCE_SYSTEM.md`가 이미 소유한다.
- 정확한 root 목록·배우 조합·파일 범위·검사는 이 오더만의 일회성 지시다.
