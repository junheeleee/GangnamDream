# Active Queue Spec: ORDER-310

> Canonical status and execution order are indexed in `docs/CODEX_QUEUE.md`.

#### [~] ORDER-310 [P0·EN] 상철 현재 장면과 데모 대사 인용을 정렬한다

2026-09-27 Codex 선언. 승인302의 잔여5를 실행한다. 기준 clean
`0f0b5e85cd9262f8efb4ccf2d20b7b9deaed7efa`. 새 공개 출고 권한이 아니다.

## 깊이 3문·범위

- 지우면: M04 첫 만남만 과거 서술이라 현재형인 두 경로와 합류에서 시점이 튄다.
  `I18N_GLOSSARY.md` P-9와 DECISIONS 2026-08-04가 현재 장면 현재형을 소유한다.
  지난 읽기 전용 조사에서 제안한 나머지8leaf 과거형화는 채택하지 않는다.
- 장기 상태: 시제·인용·문단 수리만 하며 선택/수치/상태/24주 결과는 바꾸지 않는다.
- 경쟁: 기존 대사 의미·회상 시제·화자별 말투를 보존하며 장면 추가와 경쟁시키지 않는다.

한 배치21문자열, 제품3파일:

1. `content/events_en/arc_events.json`: meet description/orthodox/unorthodox와
   결과0/1의 현재 행동만 현재형(5). 대사·막 지나간 일·가정법은 일괄 치환하지 않는다.
2. 같은 파일: clean description1, Jiyeon 선택0~2/결과1~2(5), answer
   선택0~2/결과1~2(5), reunion 결과0(1)의 직접 대사/문자만 straight double quote.
   apostrophe와 대사 속 `'why'`는 보존한다(12).
3. 같은 파일: reunion description의 마지막 대사 앞 누락된 빈 줄1개를 KO와 맞춘다(1).
4. `content/events_en/core_loop_v2_events.json`: first_bill 결과3/4의 인용2.
5. `playtests/order124/StoryChoiceM1M6Playtest.gd`: 무명 야간직원 EN 결과의 인용1.

공개11장면은 월별 분기 합집합, M04는 meet→measure 또는 coffee→answer다.
소비자 모집단은 정적76leaf+controller 대체3문자열 및 M06 이전선택5개 재표시다.
14 authored-node 감사와 혼동하지 않는다. 이 배치가 전11장면의 모든 시제를
현재형으로 정리했다는 주장은 하지 않는다. KO/JA/CN/TW·게임조건/효과·금액·날짜·
토큰·그 외 개행·역사 패키지/인간/수용/판정 원장은 무수정이다.

## 소유·검증

- root: 위 제품3파일, 이 사양·302진행 메모·큐·WORK_LOG·CLAUDE 현재행·생성STATUS,
  새 private `order310-*` 저작/보존/격리 실행 증거. 기존 private 증거는 덮지 않는다.
- `/root/blackjack_accounting_tests`: 311에서만 역사 검사 호환 저작.
- `/root/release_status_crosscheck`: 새 private `order310-check-*`의 독립 기계 보존 검사;
  제품/311검사 파일 저작 금지. 76+3 소비자 경계, 숫자/토큰/선택/외부파일 보존 확인.
- 비저자 `/root/blackjack_accounting_review`: 실제21leaf와 M04연쇄·11장면 인용 전수,
  raw 증거 직접 확인 후 private `order310-review*.json`, `order311-review*.json`과
  `docs/agent_reviews/ORDER-310.json`, `ORDER-311.json`만 작성. 저작자와 분리한다.
- EN coverage/Hangul, story-demo 지역 정합·밀도, exact diff와311 후계 검사.
  controller 인용 이스케이프가 실제 GDScript에서 읽히는지 새 격리된 데모 전용
  5언어 진행/저장 검사1회로 확인한다. 사용자 저장/설정/project.godot/HOME 불변.
  full audit·legacy24/240주·이미 완료한 런타임을 이유 없이 반복하지 않는다.
- 실제화면/입력·원어민/인간/물리패드·새패키지 후보 판정은 별도 OPEN.
  자동 게이트는 도달성·계약 증거이지 재미·깊이·문체의 증거가 아니다.
  310/311의 독립 작업한정 판정은 전체302/본편 GO로 승격하지 않는다.

규범은 기존 P-9와 WORK_UNIT 적용이며 파일/표본/단계 지시는 일회성이다.
