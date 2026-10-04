# ORDER-439 — 홀덤의 패와 승패·정산을 중국어로 읽는다

#### [~] ORDER-439 [P1·현지화] SHOWDOWN·RESULT·패순위 19키의 간체·번체 38값

**[~] 착수 — 2026-10-04.** 비동기 입력 수리를 마친 같은 게임 소스에서 남은
승패·정산·패 이름 소비자를 번역한다. 사용자 계속 개발·main 커밋/푸시 위임이다.

## 범위·소유

- root: private439 정확 KO 목록·TW 초안·공식 export/check/import·append 증거·normal,
  `locale/ui_zh-CN.json`, `locale/ui_zh-TW.json`, `content/meta/full_game_localization.json`,
  CLAUDE·큐/L3·이 사양/보관본·WORK_LOG·생성STATUS·agent 보고/판정.
- claude_handoff_review: private439 CN 초안만, 한국어에서 직접 저작한다.
- receipt_tests392: 새 private439 격리 Python/GD/scene helper와
  `tools/audit_scope.json`의 명시 `holdem-result-zh` 차선만.
- independent392: 비저자 원문·38값 전수 의미·helper·실제 화면/입력·최종 증거 검수.
  모든 실제 교환·검사·엔진은 root만 실행한다. 기존 helper·실패/성공 증거 불변.
- KO/EN/JA·Holdem/TexasHoldem/Main/GameState/Meta/LocaleManager/FontKit·돈/AI/덱/승패
  규칙·AP/저장·인간원장·공개데모/출시 manifest 불변. 기존199판정/177보고 보존.

## 번역 모집단 — 정확 19키

1. `쇼다운`
2. `   [color=#5a6a7a]승률 %d%% (%dW/%dL)[/color]`
3. `현재: %s`
4. `%s으로 승리! +%s`
5. `%s가 이겼습니다 (%s)`
6. `%s 승리`
7. `%s · POT %s 정산`
8. `%d핸드 플레이`
9. `홀덤 클럽에서 %s 땄다.`
10. `홀덤 클럽에서 %s 잃었다.`
11. `하이카드`
12. `원페어`
13. `투페어`
14. `트리플`
15. `스트레이트`
16. `플러시`
17. `풀하우스`
18. `포카드`
19. `스트레이트 플러시`

## 구현·표적 검수

- 간체/번체를 서로 변환하지 않고 한국어에서 각각 작성한다. placeholder 순서·부호·
  원화·태그·선행3공백·LF를 보존한다. 패 이름은 실제 0~8순위와 결속한다.
- 공식19값×2batch export/check/import와4파일 raw 역상을 검증한다. 목표는
  accepted41694/b211·CN/TW1752·JA3044다. JA19는 기존 사전값이므로 신규 수용으로 세지 않는다.
- proven pre-autoload 지역별 격리1프로세스. 각 지역 독립 승/패2표본은 합법
  52고유 카드(사용11/남음41)·RIVER 응답완료 상태를 준비한 뒤 실제 dispatcher로
  SHOWDOWN을 생성한다. 승자·메시지·rank·font 직접 주입0, 자연 ingress 주장은 아니다.
- 각 표본 actual Esc→RESULT·Enter→Main Close와 SHOWDOWN/RESULT/Main 로그3화면,
  총12PNG를 읽는다. 방향 커서가 없는 단계의 허위 방향순회0. Tutorial 취소와 실제
  raw/tap 수는 관측대로 별도 집계한다. net0/거액 손실·side-pot 전수 증거가 아니다.
- 대표 스트레이트플러시 승리/하이카드 패배 외7종은 합법7장 best_hand와 실제
  현재패 Label reader를 지역별 계측한다. 이14개는 정산0 준비 reader이며 자연 판으로 세지 않는다.
- SHOWDOWN의 팟±30k와 RESULT의 순익+20k/−10k를 구분한다. cash5M/AP2/mental60,
  buy-in100k·각stack90k·pot30k 준비에서 실제 hidden·Meta 파일·로그·Main회수 AP−1
  및 축/장소/행동/UI metadata 효과를 독립 계산한다. 기대 현금·승패를 결과에 덮어쓰지 않는다.
- 번역19키를 실제 소비자에 결속하고12px 메시지/11px 현재패/13px played·SHOWDOWN
  상세·승률/히스토리 축약과 Main RichText의 SC/TC normal/bold·glyph·폭/높이·겹침을 확인한다.
- busy가 있으면 복원 입구에서 즉시 중단한다. timer/tween 뒤 whole typed 상태·pending 타입·
  generation/RNG·GameState·Meta raw bytes·Main 의미 focus·논리BGM/Controller 복원,
  실제player34 바이트 불변. node identity/audio playhead/global visual RNG 보존 주장은 하지 않는다.
- 같은 clean 후보에서 receipt/fullbody·ZH/EN·context/queue/diff/등록8검증+차선조회1만
  fresh 실행한다. JA/게임소스 byte 보존,438 회귀/과거 focused/434서사4종은 참조/NOT_RUN.
  전체감사·240주·성능A/B 반복0. 실패 증거를 보존하고 원인 수리 후 같은 범위를 재검수한다.

## 깊이·한계·일회성

- 번역을 빼면 선택 결과·정산·패 이름이 영어 fallback이다. 이 작업은 기존 선택의
  이해를 복구하며 새 선택층/경쟁/24주 상태 차이·경제 규칙을 추가하지 않는다.
- 후속 베팅 문구·규칙 동적4키의 collector 누락·직접 영어 배너/POT/STACK/BET/WIN/LOSS·
  카드 저대비는 별도 후속 범위다. 전체 홀덤 번역/정산 완료를 주장하지 않는다.
- 이 저작/검수 지시는 **일회성**이며 상시 정본 추가0. 자동PASS는 계약 증거다.
  실제 인간OPEN45·공개GO1·원어민/인간/물리패드 미관측·본편/새package HOLD를 유지한다.

## 공식 수용·화면 검수 시작점

- 440 오탐 수리를 `f411887`에서 검증하고 `b8e118d`로 독립GO 마감했다. 원래439 export 기준 `5bca6fd`와 새 통합 기준을 구분하며 원헤더·실패 증거를 덮어쓰지 않는다. 두 기준의 번역4파일 원문은 동일하다.
- CN19/TW19 공식 check/import와 raw4파일 append 역상 PASS. accepted41694/b211·CN/TW1752·JA3044, 기존 번역/게임 소스 불변. 아직 실제화면·입력 PASS는 아니다.
- 최초 실행 전 비저자 helper 검수에서 normal 집계필드 누락과 기준커밋 오류를 수리했다. 새 helper만 실제관측 tutorial 집계를 전달하며, 완료440 증거·검사기를 그대로 결속한다. 과거 runtime/focused 반복0.
