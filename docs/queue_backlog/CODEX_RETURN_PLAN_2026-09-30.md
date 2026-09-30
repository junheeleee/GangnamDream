# Codex 복귀 작업지시서 (2026-09-30 Claude 설계)

> 부모 계획이다. 실행 순서의 정본은 여전히 `docs/CODEX_QUEUE.md` 표다.
> 아래 새 오더(392~395)는 착수할 때 해당 절을 `docs/queue_active/ORDER-N.md`로
> 옮기고 표에 행을 올린 뒤 선언 커밋을 만든다. 이 파일은 Claude 브랜치
> `claude/game-launch-prep-5l8u32`(PR #31)에만 있고, main에는 아직 없다.

## 결론

Codex는 돌아오면 **먼저 main의 검사를 복구하고(392), 이미 만든 수리를 들이고
(393·352), 그다음 5장 HOLD 사슬로 돌아간다.** 새 원고는 그 뒤다. main이 빨간
상태에서 콘텐츠를 더 얹으면 모든 후속 병합이 같은 검사에 막힌다.

## 현재 사실 (2026-09-30 확인)

- main `9fb7ff21`. PR #30(`0f5852d0`)이 ORDER-391 중국어 8값을 수용원장 영수증
  없이 병합했다. 그래서 `story_graph_contract_audit`·`chapter5_human_reject_audit`·
  `year5_reference_route_audit --self-test`·`order365_ui_receipt_compat`가
  `UI/receipt/source/target additions differ: zh-CN`으로 실패한다(Codex가
  `e89f3ed`에서 재현, WORK_LOG 2026-09-30).
- PR #30 이전부터 main에서 실패하던 검사: `full_game_runtime_trace_audit`(runner seal
  drift), `full_game_volume_audit`(graph en/ko mapped immediate hash drift),
  `exposed_state_consistency_audit`(errors=3), `order350/351_source_compat`
  (ledger가 승인 successor 초과), `full_body_translation_scope --self-test`(timeout),
  `ci_localization_reconciliation_self_test`(prerequisite 실패). 원인은 Claude가
  분리하지 못했다.
- Claude 브랜치(PR #31, draft)의 커밋은 성격이 셋이다. **PR을 통째로 병합하지 않는다.**

| 커밋 | 내용 | 처리 오더 |
|---|---|---|
| `9db4a6e5` (`2efa189f`는 같은 내용 중복) | ORDER-391 CN/TW 8값의 공식 export(source `18dd16d6`)·import 영수증과 원장 batch 2건(161→163) | 392 |
| `ab6f52fe` | 투자·사람 화면 패드 안내에 `normal_font` 지정(4줄) | 393 |
| `b0efea56` | ORDER-352 5장 수리 7건 초안(5개 언어) | 352 |

- Claude가 올린 CN/TW 8PNG는 **폰트 증거로 무효**다. 당시 패드 안내 일반 글자가
  Godot 기본 Open Sans로 시작해 한자를 컨테이너 OS 폰트(WenQuanYi)에서 채웠다.
  문구 배치 증거로만 쓴다.

## 복귀 순서

| 순서 | 오더 | 한 줄 | 선행 |
|---:|---|---|---|
| 1 | ORDER-392 (신규) | main 수용원장 불일치 복구 | 없음 |
| 2 | ORDER-393 (신규) | UI 글자 칸 OS 폰트 의존 제거 | 392 |
| 3 | ORDER-391 (기존) | 중국어 8값 독립검수·실제 폰트 화면 | 392·393 |
| 4 | ORDER-394 (신규) | PR #30 이전부터 실패하던 main 검사 6종 원인 분리 | 392 |
| 5 | ORDER-302 (기존) | 체험판 대본 수리 successor package | 394 |
| 6 | ORDER-352 (기존) | 5장 대본 정합, Claude 초안 `b0efea56` 반영 | 392·394, 5장 HOLD 수리와 겹침 확인 |
| 7 | ORDER-395 (신규) | 3장 서른다섯 설날 장면 소결함 2건 | 394 |
| 8 | ORDER-150→151→156→146→148→137·138 (기존) | 5장 HOLD 사슬 | 기존 게이트 |
| 9 | ORDER-149 (기존) | 프롤로그 세 비트 속도 | 기존 게이트 |
| 10 | ORDER-157·158 (기존) | 본편 JA/ZH 번역 | 5장 원문 안정 뒤 |

392가 닫히기 전에는 3~10을 main에 병합하지 않는다. 4번(394)은 결과에 따라 5~7의
검사 차선을 바꿀 수 있으므로 5번 앞에 둔다.

---

## ORDER-392 [P0·기반] main 수용원장 불일치를 복구한다

### 깊이 3문

1. **왜 지금인가?** main의 공통 증명(`order365_ui_receipt_compat.fresh_validation_proof`)이
   실패하면 이를 쓰는 모든 감사가 멈춘다. 이 상태에서는 어떤 콘텐츠도 검증된
   채로 병합할 수 없다.
2. **무엇을 바꾸지 않는가?** 8개 중국어 값의 의미, 한국어 원문, 다른 언어, 검사의
   일반 판정 기준. 검사를 넓게 완화하거나 원장 영수증을 재구성·위조하지 않는다.
3. **GO는 어떻게 되는가?** 복구는 검사 정합일 뿐이다. 391 독립검수·원어민 게이트는
   OPEN으로 남는다.

### 범위

- 먼저 복구 경로를 하나 고르고 근거를 WORK_LOG에 남긴다. 후보는 둘이다.
  - (a) Claude `9db4a6e5`의 영수증을 검증해 들인다. 방법: 같은 source(`18dd16d6`)로
    export를 재실행해 manifest header를 대조하고, `full_game_localization.py check`로
    8값을 확인한다. 이어서 PR #30 전이를 기존 `validate_history`의 exact 전이
    등록 관례(`CORRECTION_AFTER_COMMIT`·`FEE_AFTER_COMMIT`와 같은 방식)에 맞춰
    `0f5852d0` 한 건으로 한정해 등록한다.
  - (b) PR #30의 8값을 되돌리고, 391을 현재 source에서 공식
    export→check→import `--accept`로 다시 들인다. 되돌림 전이도 이력 재생이
    받아야 하므로 (a)와 같은 exact 등록 여부를 먼저 확인한다.
- 둘 중 이력 재생과 향후 successor 관리가 단순한 쪽을 택한다. Claude 권고는 (a)다.
  값 자체는 공식 도구의 check를 통과했고, 필요한 것은 영수증과 전이 등록뿐이다.
- `order350/351_source_compat`의 "successor 초과"가 이 원장 변경으로 더 나빠지면
  같은 오더에서 exact successor로 정렬한다.

### 완료 조건

- `order365_ui_receipt_compat`, `story_graph_contract_audit`,
  `chapter5_human_reject_audit`, `year5_reference_route_audit --self-test`가
  PR #30 이전 상태로 돌아온다(PASS 또는 PR #30 이전과 같은 결과).
- `ui_translation_append.py validate_history` PASS. 등록한 exact 전이는 커밋 하나로
  한정되고 값·digest를 고정한다.
- 공식 원장 수용 수와 batch 수 변화를 WORK_LOG에 기록한다.

---

## ORDER-393 [P1·UI] 글자 칸이 OS 폰트에 기대지 않게 한다

### 발견 경위

Claude가 게임을 띄워 글자마다 실제로 그리는 폰트를 추적했다(2026-09-30).
`UIStyle._load_fonts()`는 `ThemeDB.fallback_font`를 FontKit 폰트로 바꾸지만, Godot
기본 테마가 자체 `default_font`(Open Sans SemiBold)를 갖고 있다. 그래서 폰트를
직접 지정하지 않은 RichTextLabel은 Open Sans로 시작하고, 한글·한자를 OS 폰트에서
채운다. `I18N_INFRASTRUCTURE.md`의 "OS 폰트는 경로에 들어오지 않는다" 원칙에 어긋나고,
CJK 폰트가 없는 환경에서는 글자가 깨질 수 있다.

MainGame 투자 화면 기준 실측은 다음과 같다. Label·Button은 정상이고, 가시
비ASCII RichTextLabel 가운데 KO 1개(사건 본문)가 기본 폰트였다. 확인된 대상:

| 대상 | 상태 |
|---|---|
| `_invest_pad_hint_label`, `_people_pad_hint_label` | `ab6f52fe`로 수리. CN→Noto Sans SC, TW→Noto Sans TC, 누락 0 |
| `event_body`(MainGame.gd 5366), `log_box`(5703), `ticker_rtl`(5732) | 미수리 |

### 깊이 3문

1. **왜 지금인가?** 391의 폰트 판정과 Steam Deck 출시 가독성이 이 경로에 걸려 있다.
2. **무엇을 바꾸지 않는가?** 글자 크기·색·문구. 폰트 역할(regular/bold)만 FontKit 경로로 맞춘다.
3. **GO는 어떻게 되는가?** 화면 변화가 있으므로 KO/EN/JA/CN/TW 해당 화면의 실제 캡처로 판정한다.

### 범위

1. `ab6f52fe`를 main에 들인다(cherry-pick).
2. 나머지 세 RichTextLabel에 같은 관례(`_font_regular`/`_font_bold` 지정)를 적용한다.
   사건 본문은 줄바꿈이 바뀔 수 있으므로 KO 1280x800 전후 캡처로 잘림을 확인한다.
3. 전역 방지책을 하나만 고른다. 후보는 둘이다.
   - (a) UIStyle이 프로젝트 Theme에 `default_font`를 지정한다.
   - (b) 기존 검사에 "가시 텍스트 컨트롤의 해석 폰트가 Godot 기본 테마 폰트면 실패"를
     더한다.
   (a)는 전 화면 영향이 크므로, 먼저 (b)로 전체 목록을 계측한 뒤 판단한다.
   다른 장면(StoryMode, 카지노 테이블 등)도 같은 방식으로 계측한다.

### 완료 조건

- 계측 대상 화면에서 Godot 기본 폰트를 쓰는 가시 텍스트 컨트롤이 0개다.
- 391의 CN/TW 8값을 번들 폰트로 다시 캡처해 391 증거를 교체한다.

---

## ORDER-394 [P1·기반] PR #30 이전부터 실패하던 main 검사를 원인별로 나눈다

### 깊이 3문

1. **왜 지금인가?** 빨간 검사가 늘 켜져 있으면 새 실패를 구분할 수 없다. Claude의
   PR #30 사고도 "원래 빨간 줄"에 묻혀 병합 전에 걸러지지 않았다.
2. **무엇을 바꾸지 않는가?** 콘텐츠·경제·스케줄. 원인 분리와 정당한 기준선 갱신만 한다.
3. **GO는 어떻게 되는가?** 없음. 검사 신뢰 회복이다.

### 범위

아래 여섯 검사마다 (1) 실패를 처음 만든 커밋, (2) 버그인지 의도된 변경 뒤 기준선 미갱신인지,
(3) 처리를 한 줄씩 판정한다. 처리는 수리, 소유 오더 규칙에 따른 기준선 갱신,
소유 오더로 이관 중 하나다.

- `full_game_runtime_trace_audit` (runner seal drift)
- `full_game_volume_audit` (`graph:en_mapped_immediate`, `graph:ko_mapped_immediate` hash drift; 소유 ORDER-142)
- `exposed_state_consistency_audit` (errors=3)
- `order350_source_compat`·`order351_source_compat` (ledger successor 초과; 392 결과 반영 후 재판정)
- `full_body_translation_scope --self-test` (timeout; 시간 예산인지 무한 대기인지)
- `ci_localization_reconciliation_self_test` (ORDER267 prerequisite)

### 완료 조건

- 여섯 검사의 판정표를 WORK_LOG와 이 사양에 남긴다. 수리한 것은 PASS, 이관한 것은
  소유 오더의 게이트 칸에 기록한다.
- 병합 전 "PR #30 이전 대비 새 실패 0"을 확인하는 절차를 `docs/CODEX_QUEUE.md`
  공통 검증에 한 줄로 넣을지 판단한다.

---

## ORDER-395 [P2·산문] 3장 서른다섯 설날 장면 소결함 2건

`content/events/arc_midgame.json` `arc_35_birthday`, 같은 EN 오버레이.

| # | 결함 | 수리 방향 |
|---:|---|---|
| 1 | 선택 1 "감사합니다 답장하고 계획표를 꺼냈다" — 아버지의 "떡국은 먹었냐" 문자에 아들이 "감사합니다"로 답하는 것은 부자 관계 말투와 맞지 않는다. 인용부호도 없다. | 관계에 맞는 짧은 답장(예: "“네, 먹었어요” 답장하고 계획표를 꺼냈다")으로 바꾼다. EN 동일. |
| 2 | EN: 본문은 현재형인데 선택 라벨("Replied", "Called dad")과 결과문("rewrote", "Closed")은 과거형이다. "Dad"/"dad" 대소문자도 섞였다. | DECISIONS 2026-08-04 P-9 #4(EN 서술 현재형)에 맞춰 결과문을 현재형으로, 호칭은 "Dad"로 통일한다. 선택 라벨은 같은 장 다른 장면의 관례를 따른다. |

gameplay key·효과·선택 수는 바꾸지 않는다. 완료 조건: `en_coverage_check.py`와
`audit_select.py -- <변경 파일>` PASS, JA/ZH 오버레이는 원문 hash 변경 검출 규칙에 따른다.

---

## 기존 오더에 덧붙이는 인계 사실

- **ORDER-391**: 폰트 판정은 393으로 답이 났다(수리 뒤 SC/TC 번들 경로, 누락 0).
  남은 것은 392 이후 원장 결속, 393 이후 번들 폰트 재캡처, 비저자 독립검수다.
- **ORDER-352**: 7건 모두 `b0efea56`에 5개 언어 초안이 있다.
  - 5번(민서)은 변형 순서를 thought_about_after → contacted_minseo&minseo_real_talk → contacted_minseo → minseo_real_talk로 바꿨다. 기본문은 real_talk 없는 회수와 연락 경로 구절이다.
  - 착수 조건(5장 HOLD 수리와 겹침)은 그대로다. 들일 때 대상 줄이 HOLD 수리로 바뀌었는지 먼저 대조한다.
  - KO 원문이 바뀌므로 ORDER-365 KO 경계와 JA/ZH 원문 hash 규칙의 successor 처리가 함께 필요하다.
- **Claude 권한 메모**: 이 세션의 Claude는 자동 권한 모드 때문에 검증 도구 수정과
  브랜치 되돌림을 실행하지 못했다. 그래서 위 수리는 Codex가 소유한다. 같은 일을
  Claude에게 다시 맡기려면 사용자가 권한 모드를 바꿔야 한다.
