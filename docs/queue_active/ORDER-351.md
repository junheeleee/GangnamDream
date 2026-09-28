# Active Queue Spec: ORDER-351

> Canonical status and execution order are indexed in `docs/CODEX_QUEUE.md`.

#### [~] ORDER-351 [P1·본편] 4장 M37~M48 대본의 아버지 행방·영어 표기 정합을 고친다

**2026-09-27 Claude 발행.** 본편 대본 정합 검토 계획
([FULL_GAME_SCRIPT_REVIEW](../queue_backlog/FULL_GAME_SCRIPT_REVIEW.md))의 배치
R4다. story_map M37~M48 root 16장면(3년치 영수증, 민서 등장·재회, 36세 갈림길,
세 약속, 놓친 두 자리, 새벽 두 시의 다은, 같은 식탁, 세 줄의 값, KTX 열한 분,
빌린 이름, 청구서 밤, 아버지 위기·별세, 비워 둔 한 칸, 36세 결산)을 KO/EN으로
읽고, 아버지 병세는 `MainGame.gd` 스케줄과 `ROMANCE_SYSTEM.md` 다은 라인(t168
상견례)에 대조했다.

## 깊이 3문

1. **왜 지금인가?** 4장은 아버지 임종으로 가는 장이다. 아버지가 입원 중인지 식당에
   나올 수 있는지가 장면마다 다르면 가장 무거운 장면의 신뢰가 무너진다.
2. **무엇을 바꾸지 않는가?** gameplay key, 선택 수, 효과, 이벤트 ID, 스케줄 조건,
   의료 경과 판정(2-of-3), 경제 수치는 바꾸지 않는다. 문장 구절만 더하거나 바꾼다.
3. **순서는?** 3장 오더(ORDER-350) 뒤. 본편 HOLD와 사람 게이트는 바꾸지 않는다.

## 수리 목록

### 2026-09-28 후속362 — 콘텐츠 검토 기록 수리, 통합 HOLD 유지

- 마지막360 기준부터 현재까지 후보 네 사건의 KO/EN 전문과 변경8문구를
  저자·비저자가 각각 읽었다. 아버지 퇴원/재입원 설명뿐이며 기존 사실·강도,
  7축 후보 ID/개수/파일은 동일하다. crime/alcohol content SHA 두 필드와
  생성표만 갱신했다. 다른 문구·게임 코드·번역 수용은 추가 변경0이다.
- inventory normal 및 self45, context/queue 네 검사 PASS. 최초351의
  exit1·3오류와361의1장 두 실패는 역사 그대로 보존한다. 이번 수리는
  [362](../queue_archive/ORDER-362.md) clean source 독립 GO에 별도 결속했다. 본편 GO는 아니다.
  [363](ORDER-363.md)의 역사 비교 연결과 실제 후속 검수 전까지351/361 HOLD다.

### 2026-09-28 후속361 — 검증 연결 구현, 통합 HOLD 유지

- 아래 최초13종11PASS/2FAIL 기록과 원래 HOLD 보고는 역사로 보존한다.
  [361](ORDER-361.md)에서 current admission 연결을 구현해 full-body normal/self162
  PASS를 관측했다. 기존87문구/48receipt와 게임 코드는 추가 변경하지 않았다.
- 361의 표적19종은17PASS/2FAIL. 1장 normal/self가 이전360의 콘텐츠 검토
  지문 변경을 역사 비교에 연결하지 못해 중단했다. 원형 pin은 그대로 보존한다.
  [362](../queue_archive/ORDER-362.md)의 crime/alcohol 두 지문 실제 검토 후,
  [363](ORDER-363.md)이360·362의 정확한 기록 전이를 연결한다.
- 351은362·363 뒤 실제 후속 검수까지 HOLD다. 과거 화면64준비상태/70PNG를
  다시 실행하거나 현재 자연 입력·원어민·인간·물리 패드 관찰로 바꾸지 않았다.

### 2026-09-28 수리·화면 확인 — 통합은 HOLD

- 최종 clean 소스 `50e0d412fa6b35097319ca7a3c0e35b32c745f07`, tree
  `1ee7ddd995276504375d176282834804579375df`에 독립 [보고](../agent_reviews/ORDER-351.json)를
  결속했다. SHA `5097c0644efd03fc85946aa9bbeb1901ad4b8a44c0f8bdff841442c50453295a`.
  독립 검수자는 원고87·원본 PNG70장 전수를 읽어 추가 필수 결함0을 기록했으나,
  아래 실패2종 때문에 판정은 HOLD다. 기존119판정/97보고를 보존하고 각1개만
  추가(120/98)한다. 후속361·362는 미구현이며 새 source-bound 재판정이 필요하다.
- 제품 `3f0aa92dc9c3bdefd6a333fa84481a318baad907`, 직접 부모
  `6297e8cbcd4e77278055b5e332f545ea32de90f9`. 선언한12파일만 변경했다.
  KO16/EN23 + JA·CN·TW 각16 =87 기존 text leaf, 구조/효과/순서/새키0이다.
- 한국어 직접 번역48의 전후 source export·새 check/import3쌍을 보존했다.
  옛 batch3은 stale source로 거절. 기존 receipt48만 갱신, 총40302/b142,
  이전141batch/meta9/보류72 불변이다. importer 재직렬화는 원래 형식으로
  되돌려 허용 문구 외 raw 변경0을 확인했다. 원어민 완료로 세지 않는다.
- EN 전세 주석은 이전 설명 장면의 노출이 보장되지 않아 대사 밖 짧은 한 구절로
  남겼다. 해당 본문 개행8→6 외 토큰/문단 불변이다. M25 원문은 수요일 통화일
  뿐 퇴원 명시가 아니므로 위 사양의 해석과 구분한다. W153/167/174의 새 구절이
  재입원·퇴원 사이를 명시한다. KTX 과거 집 회상은 바꾸지 않았다.
- 원고 독립 검수에서 KO 조사2곳·EN 재입원 목적처럼 읽히는 수식2곳과
  장소 수신자 직역투를 고친 뒤39+48문구 전수 재대조, 필수 결함0이다.
- 실제 StoryMode 최초5실행 PASS: 5언어64준비상태·254페이지 label·28선택결과,
  PNG70장 생성. 매 실행1375소스/원본 사용자34파일 전후 동일, marker/로그 오류0.
  원고 파일 oracle 대조와 직접 handler/typing 완료 호출이며 자연 입력·정상 통독·
  전체게임 플레이가 아니다. root가 직접 읽은 대표 PNG9장에서는 잘림을 못 봤다.
- 정적 명시13종은11PASS/2FAIL. 인과·호칭·한영·번역264 등은 통과했지만
  full-body old350 current admission6경로와 release inventory2축+생성표 실패는
  그대로다. 77개 영향선택은77개 실행이나 전체 shell 통과가 아니다.
- 결과 index `order351-results-index.json` SHA
  `e4f983f6fc234e9272e40677344fdb24db52c990e61ab097d4906b9bb6ead081`,
  정적 summary SHA `1086ab3eaf68f8c2d94968c2b6747eaae0da805686ccc8f172518d25dfcc22e3`.
  선언HEAD의 dirty 제품 바이트에서 검사했으며 뒤 clean commit 재실행은 아니다.
- 별도 [361](ORDER-361.md) 검증 연결과 [362](../queue_archive/ORDER-362.md) 콘텐츠 지문
  재검토를 선언했다. 두 후속은 미구현이며351 통합 HOLD를 해제하지 않는다.
  최종 후보 독립 판정은 새 별도 보고에 결속한다. 이전119판정/97보고와
  인간OPEN45·옛공개GO1, 본편/새package HOLD를 보존한다.
- 규범은 일회성/기존 WORK_UNIT·I18N 적용, 새 정본 규칙0. 개발 스킬의
  선행 선언·파일 소유 분리·원문 직접 번역·표적 검증·독립 전수 검토를 적용했다.
  자동 검사는 재미·깊이·문체나 원어민/인간/물리 패드 감각의 관측이 아니다.

### 2026-09-28 착수 — 만지는 파일과 증거 경계

- 기준 main `2a6cafe86eecbdba1a48a9933e77e3eadf3bdcba`, 사용자 변경0.
  350·359의 통합 후속 GO와 360 기록 수리 뒤 시작한다.
- root 원고 소유: `content/events/arc_chapter_themes.json`,
  `content/events/arc_drama.json`, `content/events_en/arc_chapter_themes.json`,
  `content/events_en/arc_drama.json`, `content/events_en/arc_new_characters.json`.
  아래 1~6번의 기존 text leaf만 수정한다. 기존 선택 수·순서·효과·flags·ID·
  의료 경과·스케줄·채널·원화/수치·공개 패키지 불변, 새 장면/키0.
- #1의 같은 W153 입원 단절은 `arc_y4_three_promises_jiyeon_and_deal`과
  `arc_y4_three_promises_deal_only`에도 있으므로 기존 본문 세 변형을 함께 맞춘다.
  #4는 기존 `description_if_known`의 실제 우선 소비 문장도 포함한다.
  무연애 경로의 자기 야간 진료를 연인/새 인물 약속으로 바꾸지 않는다.
- `/root/compat357` 번역 소유: `content/events_ja/`, `content/events_zh-CN/`,
  `content/events_zh-TW/`의 `arc_chapter_themes.json`, `arc_drama.json` 6파일에서
  바뀐 한국어 대응 leaf만 각각 한국어에서 직접 번역한다. 원고·원장 저작과 분리.
  기존 병원 표기가 이미 같은 경우 다시 번역하지 않는다.
- root 수용 소유: `content/meta/full_game_localization.json`의 해당 기존 receipt만.
  원고 수정 전 source export, 수정 뒤 target 저작 전 export를 따로 보존하고
  check/import로 결속한다. 새 전체판 완료·원어민 판정은 만들지 않는다.
- `/root/r3_route_probe`는 원문·변형·전체 차이·증거를 독립 읽기 검수한다.
  `/root/screen_path_probe`는 private 표적 검사/실제 StoryMode 표시 증거만 소유한다.
  임시 harness·원문/검사 결과는 `.git/full-game-localization/order351-*`에 둔다.
- 마감 소유: 이 사양·CODEX_QUEUE·WORK_LOG·생성 STATUS·CLAUDE 현재행,
  새 `docs/agent_reviews/ORDER-351.json`·판정원장 append. 필요 시 이 사양의
  archive 이동과 큐 두 파일 순번 -1만. 로그40KB 여백이 없어 기존 원문 전체를
  새 `docs/history/WORK_LOG_2026-09-28_pre_order351.md`로 손실 없이 이동한 뒤 기록한다.
- 먼저 영향 검사 목록을 확인하되 선택 개수를 실행 통과로 세지 않는다.
  고정 해시 입구가 원고를 거절하면 실패를 보존하고 별도 검증 연결 오더를 선언한다.
  옛 source pin·역사 판정·공개 demo·인간 원장을 덮지 않는다.
- 이 선언은 일회성. 본편/새package HOLD·원어민/인간/물리 미관측과 자동 증거를
  구분한다. 별도 심화 저작·민서 기억 결함·외부 출시·상점·지출·법률 인증0.

| # | 위치 | 결함 | 수리 방향 |
|---:|---|---|---|
| 1 | 아버지 행방: `arc_y4_three_promises`(W153) 본문, `arc_y4_family_partner_collision`·`_jiyeon`(W167) 본문, `arc_father_call_on_ktx`·`_number`(W174) 본문. 모두 KO/EN | 마지막 입원 장면은 M24 병실이고 M25에는 아버지가 수요일 낮에 먼저 전화한다(퇴원 뒤). 4장은 설명 없이 W153에 “아버지 병동”, W167에 아버지가 서울 식당을 예약해 다은과 마주 앉고, W174에 다시 “아버지가 있는 병원”이다. 퇴원·재입원이 한 번도 나오지 않는다. | 아버지를 식탁에 두는 연애 정본(t168 상견례)을 유지하고 구절만 더한다. W153 “다시 입원한 아버지의 병동”, W167 “퇴원 뒤 처음 서울에 올라온 아버지”, W174 “다시 병원으로 돌아간 아버지”. 새 장면이나 플래그는 만들지 않는다. |
| 2 | EN 병원 이름: `content/events_en/arc_chapter_themes.json`(5곳) ↔ `content/events_en/arc_events.json`(5곳) | 같은 “창원 성심병원”이 한쪽은 “Changwon Sacred Heart Hospital”, 다른 쪽은 “Changwon Sungsim Hospital”이다. | 고유명사 음역 “Sungsim”으로 통일한다. JA/zh 오버레이도 한 표기로 맞춘다. |
| 3 | `content/events_en/arc_new_characters.json` `arc_minseo_01_meet` 본문 | 대사 속 “[rented deposit-only]”와 별도 문단 “[Jeonse: Korea's unique …]”가 번역자 주석처럼 본문에 그대로 나온다. EN 규칙은 문맥으로 못 푸는 명사만 첫 등장에 짧게 설명한다. | 대괄호 두 곳을 지우고, 이 장면이 EN 첫 등장이면 대사 밖 한 구절로(“on jeonse—a large deposit instead of monthly rent—”) 설명한다. 앞 장면에서 이미 설명됐으면 설명 없이 쓴다. |
| 4 | `content/events/arc_chapter_themes.json` `arc_36_unexpected_hand`·`_person_deal` 본문·선택, 같은 EN | “사람·진료 창구”, “병동이 아닌 사람·진료 창구”, “누구 또는 어느 창구”가 플레이어 화면에 그대로 나온다. 변형 슬롯 이름처럼 읽힌다. | 놓친 사람을 가리키는 자연어로 바꾼다(예: “기다리게 한 사람” / “the person he left waiting”). 다은·지연·무연애 경로 모두에 참인 표현을 쓴다. |
| 5 | `content/events/arc_chapter_themes.json` `arc_35_path_cost` 선택 2 결과, 같은 EN | “미뤘던 전화 한 통을 걸었다. 혹은 검진을 예약했다.” 서술자가 무엇을 했는지 정하지 않는다. | 한 행동으로 확정한다(예: 전화). |
| 6 | `content/events_en/arc_chapter_themes.json` `arc_y4_family_partner_collision` 선택 1 결과 | 다은이 민준의 아버지를 “Father”라고 부른다. KO “아버님”의 직역이라 영어에서는 자기 아버지를 부르는 말로 읽힌다. | “sir”로 바꾼다. 지연 변형에도 같은 호칭이 있으면 함께 맞춘다. |

## 판단만 남기는 항목 (이 오더에서 고치지 않는다)

- **4장 root 대부분이 W 단위 편성 의도(“W153 shipping StoryMode가 …”)를 beat
  intent에 적고 있다.** 산문의 인물 행동은 의도대로지만, 장면 설명문(“누구도 다른
  약속을 대신 취소해 주지 않았다”, “아버지도 다은도 이미 식탁에 앉아 있는 사람처럼
  말하지 않았다”)이 시스템 계약을 산문으로 옮긴 문장으로 읽힌다. EXPAND 저작 때
  감각 장면으로 다시 쓴다.
- **민서가 M37 선택 2(말을 걸지 않음) 경로에서도 M40에 “그날 오셨던 분이죠?”라고
  알아본다.** 청중 한 명을 기억하는 근거가 약하다. 민서 5장 도착 장면과 함께 보기
  위해 R5 뒤로 미룬다.

## 결함 아님으로 확인한 것

- 다은의 “민준씨”(붙여 씀): `ROMANCE_SYSTEM.md` 호칭 표 정본이다.
- M45 “같이 산 시간”: 다은 라인은 프로포즈(t150+) 뒤 “우리 집” 아크가 있다.
- 36세 갈림길의 “마감까지 2년이 채 남지 않았다”, “36세의 마지막 밤”: 나이·기한 계산과 맞다.

## 완료 조건

- 1~6번이 KO/EN(해당 시 JA/zh-CN/zh-TW 오버레이 포함)에 반영된다.
- `python3 tools/en_coverage_check.py`와 `python3 tools/audit_select.py -- <변경 파일>`
  PASS. 해시 고정 검사가 걸리면 기존 소유 오더의 갱신 규칙을 따른다.
- `WORK_LOG`와 이 사양 머리말·큐 행 상태를 함께 갱신한다.
- 원어민·외부 플레이테스트 게이트는 OPEN으로 남는다.
