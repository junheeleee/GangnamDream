# ORDER-472 — 후속 회상 정렬·연말 수첩 반복·마지막 해 시간 사실 수리

#### [~] ORDER-472 [사용자 후속] 지정 초안 여섯 사건과 직접 회상 두 곳

**착수 선언 — 2026-10-06.** 사용자 지정 PROSE_DRAFT_CH2_CH5_2026-10-03의
여섯 사건을 다음 별도 단위로 처리한다. 471 최종 읽기에서 확인한 직접 독자 두 잎을
먼저 정렬한다. 471은 이 새 불일치를 범위 밖이라는 말로 완료하지 않고 연결 검증까지
열어 둔다. 아래 선언을 커밋·push한 뒤 구현한다.

## 한 배치의 경계와 깊이 3문

- 지우면: 471의 중립 일정 수리를 읽는 다음 장면이 미발생 전송·예약 확정을 회상한다.
  첫해·둘째 해 마감의 같은 수첩 몸짓, 겨울 골목 배경/책상 본문 충돌, 자산·기간 오인도 남는다.
- 24주 뒤 차이: 기존 keeps_records/year2_confident/year2_conflicted 및 모든 후속 선택·독자는
  그대로 둔다. 새 상태를 만들지 않고 플레이어가 실제로 고른 이력의 서술만 맞춘다.
- 경쟁: 첫해 기록/숫자/속도, 둘째 해 일정/이름과 시간/목표의 기존 선택과 대가를 보존한다.
  현수·다은의 기간 수리는 선택의 성공이나 관계 회복을 새로 보장하지 않는다.

## 정확한 원문 모집단 — 한국어40잎, 영어40잎

- arc_year_one_mark: description, housing memory3, 선택0/1의 text·result — 8.
- arc_year2_close: description, 기존 DIK8, 선택0/1/2의 text·result — 15.
- hyunsu_year5_call 및 father_passed: 각 title·description·DIK2·선택1 result — 5씩.
- arc_daeun_year5_apart: description — 1.
- arc_daeun_year5_ending: description·DIK3의 지정 기간 문구 — 4.
- arc_y4_body_witness 및 arc_y4_body_witness_hyunsu:
  description_memory_if_known/arc_y4_missed_cost_seen&arc_y4_missed_cost_repaired_person — 각1.
  author_only 지연 독자는 보존한다. 동일 flag의 두 생산자 모두가 보장하는 달력의 재방문
  시각·이동 시간 고려만 회수한다. 과거 상대·두 시각 전송·예약/접수/확정·치료/관계 회복은
  단정하지 않는다. W157→W164의7턴을 직전 행동으로 압축하지 않는다.

## 초안 적용 판단

원문은 사용자 지정 KO/EN 초안을 따른다. 다음은 실제 소비자/정본 대조로 확인한
같은 잎 안의 수리이며 새 게임 규칙이 아니다.

- 첫해 memory는 본문 대체가 아니라 뒤에 추가된다. 세 memory의 새해 도입·출력지 펼침·
  달력 결론을 되풀이하지 않고 주거 상담표의 고유 사실만 이어 붙인다. 각1문단과 토큰을 유지한다.
- 선택한 EN 잎은 정본의 과거형으로 정렬한다. 명시적으로 보존하라는 첫해 선택2(index2)는
  건드리지 않으며 그 기존 EN 현재형 부채를 이번 전체 시제 GO로 포장하지 않는다.
- privacy memory의 KO/EN 이름 토큰을 각각1회로 맞춘다. JA/zh는 확정 KO 토큰을 따른다.
- crossed_line의 ‘다음에는 세 글자’는 숫자를 빼고 실제 남은 글만 쓴다.
- apart 기존 KO3/EN4문단은 각 원문의 문단 수를 유지한다. 무관한 문단 패리티 수리는 하지 않는다.
- 현수 사망 기본 본문은 첫 문단만 고친다. 다은 ending은 지정 기간 줄만 바꾸고 얇음·
  내일 도달/소유 단정 등 전체 장면 부채를 해소했다고 하지 않는다.
- 420은 description 단독 하한이 아니라 실제 분기·후속을 포함한 micro 분류다.
  임의로 문장 길이를 늘리지 않고 실제 감사의 계산을 사용한다.

## 선언 파일과 소유

- root 원문·공식 수용: content/events{,_en,_ja,_zh-CN,_zh-TW}/ 안의
  arc_midgame.json, arc_year_close.json, arc_hyunsu.json, arc_daeun_extension.json,
  arc_chapter_themes.json — 정확25경로. content/meta/full_game_localization.json 포함26.
  KO/EN source10커밋 → 목표어15+원장1의 공식 receipt16커밋으로 분리한다.
  신규 잎0, JA/zh-CN/zh-TW 각40·합계120 기존 수용 교정만 한다.
- inventory 지문이 실제 변할 때만 content/meta/release_content_inventory.json과
  생성 docs/CONTENT_RATING_INVENTORY.md를 갱신한다. 가짜 지문/파일 변경 금지.
- order469_history: tools/order470_source_compat.py 및 자체검사,
  tools/pr31_intake_history.py 및 자체검사, tools/full_body_translation_scope.py.
  기존 typed Git/정확 JSON span 역상/호출 한정 proof를 재사용한다. 470의42·471의18은
  불변 끝점으로 유지하고472의120을 별도로 검증한다. PR31밖 Hyunsu5경로는 새 current
  admission과 역상 뒤 기존309/313/351 체인으로 이어지며 옛 핀을 바꾸지 않는다.
- order469_main: 새 tools/ProseRecallCheck.gd, tools/ProseRecallCheck.tscn.
  기존 Main/StoryMode/EventManager 소비자를 부르는 준비 검사만 소유한다.
- root: 새 tools/prose_recall_audit.py(--self-test), tools/audit_scope.json 등록.
- 검수 중 확인한 중국어 수량 오탐 추가 범위(2026-10-06):
  order469_history가 tools/zh_translation_audit.py와 새 tools/prose_counter_self_test.py를 소유한다.
  새 정확 KO 현수 원문에서도 기존 ‘한 뼘 더 조용’ 비유와 두 사람의 서로 다른 지도 지원을
  유지하고, 눈송이 두 개의 자연스러운 两片雪花/兩片雪花를 인식한다. 값·단위·횟수·source
  경계로 ‘딸깍 두 번’의 两声咔哒/兩聲喀噠와 ‘셋은’의 这三项/三者도 같은 정확 원문
  슬롯에서 인식한다. 일반 片/声/项 카운터 전체의 허용 범위는 넓히지 않는다. 다른 source
  경계 음성 사례는 계속 거절한다. target 문장을 검사 편의로 어색하게 바꾸지 않는다.
  root는 audit_scope 등록만 소유하며 별도 선언 커밋 뒤 구현한다.
- root 운영: CLAUDE현재, CODEX_QUEUE와 CODEX_QUEUE_L3_PENDING의 순번만,
  471상태/완료보관, 이 사양/완료보관,
  WORK_LOG, 생성STATUS, agent_review_decisions, 독립 보고 ORDER-471/472.json.
  비저자 order469_review는 두 보고 파일만 소유하고 모든 변경 원문·영수증·증거를 직접 읽는다.

arc_events5·demo 고정 핀·project.godot·Main/StoryMode/GameState·사용자 저장·seed·
과거 인간 판정·공개 package는 불변이다. 기존 old273/146/12623 전체 재실행을 기본으로 하지 않는다.
기존 tools/ChapterFourRelationshipCheck.gd와 tools/chapter4_causal_route_audit.py도 불변이다.

## 검증과 종료

1. 여덟 사건의 exact40잎 밖 raw, 모든 gameplay·배열/조건/memory 순서·문단·토큰을 대조한다.
2. 확정 KO 기준 변경 잎만 공식 export/check/import와 원장 영수증120을 수용한다.
3. EN coverage/한글, narrative continuity, scene audio, speech register, inventory,
   새 정적/준비 소비자, exact source10/receipt16와 변경 비교 이력·본문·데모를 표적 검증한다.
   한 fresh 입장 안에서 필요한 공통 이력을 공유하되 실제 모든 입장/종료/전후 보존을 남긴다.
4. 두 생산자×두 live reader×5언어와 플래그 음성, 실제 DIK/추가 memory,
   아버지 사망 변형, M13/W96/year5 경계와 기존 선택 결과를 준비 상태에서 확인한다.
5. 실제 StoryMode 최소3장면(year_one, year2 KO/EN, 현수 사망 변형)을 화면·입력으로 관찰한다.
   현재 사용자 저장을 쓰지 않고 pre-autoload 격리하며 자연 플레이/원어민/물리패드로 부르지 않는다.
6. 새 실패0 및 독립 판정 전 471/472를 완료하지 않는다. L2 전 칸·현재 후보 commit/tree,
   실제 실행/미실행·기존 부채와 자동 검사의 한계를 구분한다. 외부 출시 GO가 아니다.

정본 규범은 기존 소유 문서를 적용한다. exact 전이·배치·검증 순서는 일회성이다.
