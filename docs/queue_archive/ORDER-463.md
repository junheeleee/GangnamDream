# ORDER-463 — 프롤로그 시간 수리의 단일 source 전이를 번역 검수에 연결한다

#### [x] ORDER-463 [P1·수용 경계] 문안 불변인 프롤로그 타이밍의 정확한 source admission

**2026-10-05 완료 — source 수용 한정.** [독립 보고](../agent_reviews/ORDER-463.json).
149의 실제 화면·체감 및 본편/출시는 HOLD로 남긴다.

**[~] 착수 — 2026-10-05.** 149는 프롤로그 시간만 바꾸나 full_game_localization은
scenes/*.gd raw 전체를 manifest에 넣는다. 번역값/6개 동적키가 그대로여도 옛
manifest와 현재 원문은 다르므로 이를 조용히 무시하거나 receipt를 재발급하지 않는다.
수리된 실제 단일 제품 commit의 정확한 전이만 증명한다. 149의 연출/화면 판정과 분리한다.

## 한 단위·소유

- claude_handoff_review: 새 `tools/opening_rhythm_history.py`와
  `tools/ui_translation_append.py`의 새 EOF adapter만. 원prefix·현재모든pin/역상/캐시
  의미를 보존한다. 실제 제품commit은 root의149 표적검증 후 고정한다.
- receipt_tests392: 새 `tools/opening_rhythm_history_self_test.py`만(149 checker와
  파일소유 분리). root만 실행한다. actual Git와합성반례를 별도 계수한다.
- root: `tools/audit_scope.json`, 사양/큐/L3·WORK_LOG·생성STATUS·CLAUDE현재행·원장.
- independent392: 사전/실제 증거검수·마지막 `docs/agent_reviews/ORDER-463.json`만.
- 원고/번역사전/accepted41755/receipt231batch·공개pin·기존보고·human·player/seed/
  462앱·manifest·원본project 변경0. 새 source 허용은 OpeningCinematic1경로뿐이다.

## 계약·검증

1. 실제 Git before/aftercommit/tree/blob와단일경로전이, 149의 fade/hold/getter/6consumer
   전체byte역상, 현재HEAD/disk/raw/source_hashes를 결속한다. 문안·이미지·음향·경로·
   shader/켄번즈/입력은 byte-exact이며 임의hash·팬텀전이·섞인census를 거절한다.
2. 원 manifest matcher는 현재를 증명된 이전tuple로만 투영하고 기존 current_proof·
   원 collector와 source증명에 위임한다. 기준선 완화·실패cache·whole-run cache0.
3. 합성 반례와 실제 고정Git전이1회, collector1회로 entryID/6동적쌍 불변을 확인한다.
   current 기본full-body1회가 실제 전체receipt/manifest 수용을 확인한다. 이전
   자체검사전량/standalone365/엔진/240주/462빌더 재실행0,149 엔진검사와 중복0이다.
4. source·입력/보호대상 전후비교, 정확marker/exit/stderr·비저자 한정판정 뒤 main에
   정리한다.149 제품commit과 이adapter를 함께검증한 후 원격으로 올려 미연결 상태를
   공개main에 두지 않는다. 149화면/457/302runtime·본편/출시는 HOLD다.

없으면 새 번역검수에 정확한 현재원문 증거가 끊긴다. 선택/24주후 상태는 불변이고
경쟁하는 것은 불필요한재번역·넓은수용 허용과 검수시간이다. 규범은 이 단일전이/
파일소유/검사 지시로 일회성이며 기존 WORK_UNIT 적용·새 정본규칙0이다.

## 실제 수용 결과 (2026-10-05)

- clean `b565ffe4f15cbee0ff92ac5d4d164014970a2f89` / tree
  `a84e916689a927d769d971d06c0f516bcac7b4c7`에서 전체 수용1회453.09081초,
  exit0·정확 SOURCE_INVENTORY_ONLY marker·stderr0. 결과
  `build/qa_order149/fullbody1/result.json` SHA
  `67392ba8ba001073a2f3d2960d03144402458b798b83f668b9253b34cc4381e7`.
  전후3138 tracked bytes/HEAD/tree/status와 보호대상 모두 동일하다.
- focused56은 actual Git proof1/objects6/opening collector1/synthetic replay15다.
  full collector 실행은 이 focused에서0이며 위 full-body가 실제 전체를 담당한다.
  `focused1` 전체exit1은 WORK_LOG 문맥예산40346>40000 때문이었다. 새 최상단
  기록만 줄인 뒤 context만 재실행하여 PASS; 첫 실패를 전체PASS로 바꾸지 않는다.
- 전체 수용 뒤 `5b096f36ac892b96aefcf7288655edbbfa186de7`는 CLAUDE 현재3행만
  바꾼 source successor다. 그 이후 후보에서 전체수용을 재실행했다고 쓰지 않는다.
- 자동 PASS는 계약 증거이며 149의 화면/체감·원어민·물리 조작·출시 GO가 아니다.
  원문/사전/기존41755수용·231batch·과거보고·공개·human·player·seed는 불변이다.
