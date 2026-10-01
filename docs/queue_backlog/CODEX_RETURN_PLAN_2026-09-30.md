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
| 2b | ORDER-398 2장 F1 (P0 선행) | `arc_jaehyuk_aftermath` 선택 라벨의 내부 경로 태그 노출과 조건 없는 선택. 문장 배치를 기다리지 않고 먼저 고친다 | 392 |
| 3 | ORDER-391 (기존) | 중국어 8값 독립검수·실제 폰트 화면 | 392·393 |
| 4 | ORDER-394 (신규) | PR #30 이전부터 실패하던 main 검사 6종 원인 분리 | 392 |
| 5 | ORDER-302 (기존) | 체험판 대본 수리 successor package | 394 |
| 6 | ORDER-352 (기존) | 5장 대본 정합, Claude 초안 `b0efea56` 반영 | 392·394, 5장 HOLD 수리와 겹침 확인 |
| 7 | ORDER-395 (신규) | 3장 서른다섯 설날 장면 소결함 2건 | 394 |
| 7b | ORDER-396 (신규) | 4년차 정점 산문의 계약어 누출 수리(아버지 임종·KTX·상철 대면 변형) | 394, 5장 HOLD 수리와 파일 겹침 확인 |
| 7c | ORDER-397 (신규) | 지연 5년차 고백을 다은과 같은 밀도로, 재혁 결정 장면, 소결함 2건 | 394 |
| 7d | ORDER-398 (신규·부모) | 문장 개선 프로그램: 전체 1,708 사건을 [기준서](PROSE_REVISION_MASTER_PLAN.md)와 [목록](PROSE_REVISION_INVENTORY.md)으로 A→C상위→B→E 순 배치 처리. 395~397은 첫 배치다 | 397 |
| 7d' | ORDER-399 (신규) | 이야기 본문 `{name}`을 이름(민준/Minjun)으로 치환(DECISIONS 2026-09-30) | 394 |
| 7e | ORDER-398 배치: [1장](PROSE_REVISION_CH1.md) | 1장 63장면 판독 완료. 사실 결함 6건, 재작성 7장면, 끝·예고 약 25곳. 주인공 이름 표기는 사용자 판단 | 398 |
| 7f | ORDER-398 배치: [2장](PROSE_REVISION_CH2.md) | 2장 53장면 판독 완료: 사실·표면 결함 8건(P0 1건), 재작성 7장면, 끝·예고 약 30곳 | 398 |
| 7g | ORDER-398 배치: [3장](PROSE_REVISION_CH3.md) | 3장 56장면 판독 완료: 사실 결함 6건, 서술자 도덕 판정·분류어 노출 6곳, 재작성 6장면, 끝·예고 약 20곳 | 398 |
| 7h | ORDER-398 배치: [4장](PROSE_REVISION_CH4.md) | 4장 판독 완료: 사실 결함 13건(지연 변형 6개 도달 불가 의심·청혼 시간·명의 전제 중복), 계약어·도덕 해설 약 40곳, 재작성 5묶음 | 398 |
| 7i | ORDER-398 배치: [5장](PROSE_REVISION_CH5.md) | 5장 중 ORDER-148 범위 밖 판독 완료: 사실 결함 10건(다은 엔딩 전야 '오랜 친구', 지연 결혼 준비 존대, 명의 시점), 판정·예고 9묶음, 재작성 3장면, 장부 반복 7회 정리, 148에 R3 입력 18건 | 398·148 |
| 7j | ORDER-398 배치: [엔딩](PROSE_REVISION_ENDINGS.md) | 엔딩 35종 판독 완료: 조건·본문 불일치 13건(P0: 살아 있는 미화해 아버지를 `empty_house`가 사망으로 씀), 교훈 7묶음(변형 복제로 약 50곳), 얇은 엔딩 재작성 5, 판정 2건 | 398 |
| 7k | 사용자 판정 3건 구현(DECISIONS 2026-10-01) | ① 4장 `_jiyeon` 변형 6개 author_only: `MainGame.gd` `_chapter_four_relationship_event_id`가 지연 파트너일 때 unattached로 가게 하고 6개 호출부의 지연 id를 뺀다. 6개 이벤트를 `weight=0`·`hidden=true`·`conditions={min_turn:9999}`로 맞추고 `event_lifecycle.json` 원장(목록·counts·sha256)에 넣는다. `chapter4_causal_route_audit.py` 승격 목록에서 빼고, `HiddenFeatureCheck.gd` 주입과 `release_content_inventory` 수치를 갱신한다. ② `arc_daeun_later_echo`의 "저도 여기 있어요" 선택에 함께하는 경로 조건(`daeun_romance_started` 유지·미이별)을 건다. 데모 고정 파일이므로 `demo_localization_scope` ORDER-369 pin을 함께 갱신한다. 같은 파일의 2장 F1(P0, `arc_jaehyuk_aftermath` 경로명 노출)·5장 F9(삼각김밥)와 3장 도덕 해설 `arc_jaehyuk_04b_counter`("선택의 순간이다", "거울 보기가 부끄럽지 않았다", "빠르게. 더럽게.")도 이때 함께 고친다. | instant_legend 문장 삭제는 Claude가 반영 완료 |
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

### 전 화면 계측 (2026-09-30 Claude, 브랜치 head 기준)

ScreenshotQA의 start·story·job·casino·people·title·ending 경로를 KO·zh-CN으로 돌렸다.
캡처 160회마다 화면에 보이는 비ASCII 텍스트 컨트롤의 해석 폰트를 확인했고, Godot 기본
폰트를 쓰는 고유 컨트롤이 77개 나왔다(임시 탐침, 커밋 안 함). 범위는 다음과 같다.

| 위치 | 대상 | 비고 |
|---|---|---|
| `StartMenu.gd` | 메인 메뉴 버튼 전부(계속하기·새 이야기·불러오기·기록·설정·게임 종료), 부제·"아무 키나 누르세요"·조작 안내, 불러오기 화면(제목·슬롯·페이지·뒤로), 콘텐츠 안내 화면 | **첫 화면 전체다.** 이 파일에서 폰트를 직접 지정한 곳은 제목 3곳(`FontKit.ui_bold()`)뿐이다. |
| `SplashScreen.gd` | 언어 선택 버튼("한국어 KO" 등) | |
| `StoryMode.gd` | 기록 화면 페이지 버튼("슬롯 1–5 [PageUp]") | |
| `MainGame.gd` | `event_body`·`log_box`·`ticker_rtl` | 위 표와 같다. |

Label·Button이 MainGame에서는 정상인 것은 MainGame이 개별 지정하기 때문이다. 전역
경로(`UIStyle`의 `ThemeDB.fallback_font`)는 어떤 컨트롤에도 닿지 않는다. 따라서 아래
범위 3의 **(a) 전역 수리를 권고한다.** 개별 지정으로는 StartMenu 한 파일에만 수십 곳이
필요하다. (a)의 가장 작은 형태는 UIStyle이 기본 폰트를 FontKit regular로 두는 한 곳
수정이다(예: 프로젝트 Theme의 `default_font`, 또는 `ThemeDB.get_default_theme().default_font`).
전 화면 캡처 전후 비교로 줄바꿈·잘림을 판정한다.

같은 실행에서 기존 ScreenshotQA 단언 4건이 실패했다(탐침은 실패 뒤에도 계속 진행함).
395와 별개로 394에서 판정한다.
- ORDER-97 기록 페이지 버튼 기대값 "슬롯 1–5"와 실제 "슬롯 1–5  [PageUp]"가 다르다(KO).
- 장면 설정 툴팁 기대값이 영어 "Scene settings (F10)"인데 실제는 "场景设置（F10）"다(zh-CN). 번역 뒤 기대값이 낡은 것으로 보인다.
- `clean_run_title` 관찰 문구 "lost the exact observational copy"(KO·zh-CN).

### 깊이 3문

1. **왜 지금인가?** 391의 폰트 판정과 Steam Deck 출시 가독성이 이 경로에 걸려 있다.
   플레이어가 가장 먼저 보는 시작 메뉴가 OS 폰트에 기대고 있다.
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

### Claude 사전 진단 (2026-09-30, main `9fb7ff21` 깨끗한 worktree)

main 이력을 커밋 단위로 거슬러 올라가 처음 실패한 커밋을 찾았다. **여섯 가지 모두
콘텐츠 결함이 아니다.** 의도된 수정 뒤에 해시·계약·기준값을 갱신하지 않은 것이
다섯, 설계상 정상 추가를 막는 구조가 하나다.

| 검사 | 처음 실패 | 원인 | 권고 처리 |
|---|---|---|---|
| `exposed_state_consistency_audit` ① `hyunsu_result_pass` KO/EN | `506e4c8f` (9/27, ORDER-309 1장 수리) | 민준·현수가 같은 고시원 옆방이라는 정본에 맞춰 "현수가 사는 고시원"을 "복도를 따라 걸어가 현수의 방문 앞"으로 바꿨다. 검사는 `exposed_event_state_contracts.json` 2349행의 `hyunsu_residence` 문맥으로 옛 문구를 요구한다. | 문장은 정본이 맞다. 문맥을 1장 옆방 정본에 맞는 값(예: `chapter_one_canon`, 스케줄러 소유 확인)으로 바꾸거나, 옆방 문맥용 판정 문구로 교체한다. |
| `exposed_state_consistency_audit` ② `arc_minjun_first_call` | `ef896982` (9/27, ORDER-350 3장 수리) | 현수 대사가 "그냥, 공부."에서 "오늘은 출근 안 해요."로 바뀌어 `employment` 도메인이 감지된다. 계약(958행)에는 `father_life, location, relationship`만 있다. | 사실은 맞다. 합격이면 공무원, 불합격이면 35~50주 `hyunsu_pivot` 재취업이고, 이 장면은 130~155주다. 계약에 `employment`를 선언하고, 가드 근거로 불합격 경로 재취업 시점을 적는다. |
| `full_game_volume_audit` graph ko/en mapped hash | `506e4c8f` (같은 1장 수리) | 의도된 산문 수정 뒤 관측 기준값을 갱신하지 않았다. 이후 3·4장 수리도 해시를 바꿨다. | ORDER-142 규칙대로 현재 head에서 M01~M60 차이를 검토한 뒤 한 번 갱신한다. |
| `full_game_runtime_trace_audit` runner seal | `03059e52` (9/27) 이후 `tools/audit.sh` 6회 수정 | `AUDIT_RUNNER_SHA256`(c906ff8b…)는 9/12 `ea7bf234` 버전이다. 이후 추가된 검사 13개의 `*_EXIT` 변수는 모두 마지막 집계 목록에 들어 있어 실패 전파는 유지된다(Claude가 diff를 대조함). | 현재 `audit.sh`로 재봉인하고, 주석에 추가된 13개 EXIT를 적는다. |
| `order350_source_compat`·`order351_source_compat` | `003b68c7` (9/28, 351 승인 뒤 첫 중국어 번역 추가) | 두 검사가 `full_game_localization.json`을 승인 당시 successor 바이트로 고정한다. 그래서 이후 정상적인 번역 수용이 모두 "successor 초과"가 된다. 이후 모든 번역 커밋에서 계속 실패한다. | 구조 수리다. ledger는 append-only 검증(`ui_translation_append`/원장 digest)으로 확인하고, 350/351 소유 원문 leaf만 exact로 고정한다. 392와 같이 설계한다. |
| `ci_localization_reconciliation_self_test` | `a332f746` (9/28) | `tools/main_game_locale_history.py`가 바뀌었는데 `new_run_log_locale_self_test.py`의 ORDER267 `BINDING["code"]` 핀(734fab4d…, 9/20 `3adb96da` 버전)을 갱신하지 않았다. | 현재 파일로 핀과 inverse를 갱신하거나, 역사 검사를 해당 커밋 시점 파일로 읽게 바꾼다. |
| `full_body_translation_scope --self-test` | 점진적 악화 (Codex 9/29 기록 420초 timeout → Claude 측정 3000초에도 미완료) | 멈춘 게 아니라 느려지는 구조다. faulthandler 스택을 보면 `build_scope`→`order365_ui_receipt_compat.fresh_validation_proof`→`ui_translation_append.validate_history`가 UI·원장 경로 커밋 242개를 매번 처음부터 재생한다. 커밋마다 10.8MB `full_game_localization.json`을 `order313_source_compat._loads`→`_canonical`(json.dumps)로 여러 번 재직렬화하고, 자체 검사는 이를 여러 번 부른다. 이력이 늘수록 시간이 선형 이상으로 는다. | 성공 캐시가 아니라 **내용 주소 memo**로 푼다. git blob sha를 키로 파싱·정규화 결과를 한 프로세스 안에서만 재사용하고, 판정은 매번 새로 한다. 또는 한 실행에서 proof를 한 번만 만들어 넘긴다. "mutable success cache 금지" 원칙과 충돌하지 않는지 파일 머리말 계약과 대조한다. |

공통 교훈: 해시로 고정한 파일을 고치는 커밋은 같은 커밋에서 고정값도 갱신해야
한다. 한 번 놓치면 이후 모든 커밋에서 빨간 줄이 되고, 새 사고가 그 속에 묻힌다.

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
| 2 | EN: 본문은 현재형인데 선택 라벨("Replied", "Called dad")과 결과문("rewrote", "Closed")은 과거형이다. "Dad"/"dad" 대소문자도 섞였다. | 본문을 과거형으로 맞추고(DECISIONS 2026-09-30, P-9 4번 재판정), 선택지는 명령형 현재로 바꾼다("Reply 'Yes, I did' and open the planner"). 호칭은 "Dad"로 통일한다. |

gameplay key·효과·선택 수는 바꾸지 않는다. 완료 조건: `en_coverage_check.py`와
`audit_select.py -- <변경 파일>` PASS, JA/ZH 오버레이는 원문 hash 변경 검출 규칙에 따른다.

---

## ORDER-396 [P1·산문] 4년차 정점 장면의 계약어 누출을 푼다

근거는 [`PEAK_PROSE_REVIEW_2026-09-30.md`](PEAK_PROSE_REVIEW_2026-09-30.md)다. 4년차
`arc_y4_*`는 1만 자당 계약어가 59.9회로, 일반 사건(3.4)의 17배다. 결과문 끝이
이미지 대신 규칙 해설("길이 닫혔다", "사실로 남았다")로 닫힌다.

### 깊이 3문

1. **왜 지금인가?** 아버지 임종은 가족 축의 최대 정점이다. JA/ZH 번역이 이 원문을
   세 배로 복제하기 전에 고쳐야 한다(P-9 "왜 지금인가"와 같은 이유).
2. **무엇을 바꾸지 않는가?** 사실·선택 수·플래그·효과·스케줄·인과 원장 fact. 문장만
   고친다. "지켜야 할 것" 목록의 문장은 건드리지 않는다.
3. **GO는 어떻게 되는가?** Claude 또는 비저자 독립 판정을 거친다. 원어민·인간 게이트는
   OPEN으로 남는다.

### 범위 (1배치)

1. 검수 문서 패턴1 표의 끝 문장 10곳: 이미지나 행동으로 닫는다.
2. 패턴2의 선택지 예고 문장 4곳: 지우거나 이미지 문장으로 바꾼다.
3. 패턴3 "나중에 꾸미지 못하도록" 동기 3곳: 하나만 남기거나 모두 지운다.
4. 패턴4의 두 장면(`arc_father_passing`, `arc_sangchul_confrontation`): 변형마다 원문의
   핵심 비트를 넣고, 플래그별 차이는 한 문단 삽입으로 다시 쓴다.
5. `arc_father_passing` 본문: 부고를 듣는 순간에 몸의 비트 하나를 더한다.
6. 경미 항목:
   - 선택 라벨 형식 통일(`_platform`·`_deal_room`·대면)
   - `_deal_room` 선택2의 전화 동작 불일치
   - "모르겠었다" 비문
   - 23초 통화 지칭 정리
   - `{name}`/"민준" 한 장면 안 통일
7. EN은 같은 커밋에서 다시 옮긴다. 검수 문서의 직역투 4건을 함께 닫는다.

`missed_on_ktx`의 "기록 방식 셋" 선택 구조 재설계는 이 오더에 넣지 않는다. 사용자
판단 항목이다. 5년차 같은 패턴은 ORDER-148에 이 검수 문서를 입력으로 붙인다.

### 완료 조건

- 계약어 밀도를 같은 방식으로 다시 재고, 수리 전후 수치를 WORK_LOG에 남긴다.
- 수리 장면 KO/EN을 실제 StoryMode에서 표시 확인하고 캡처를 남긴다.
- `en_coverage_check.py`와 `audit_select.py -- <변경 파일>` PASS. KO 원문 hash가 걸리는
  검사는 394에서 정리한 successor 규칙을 따른다.

---

## ORDER-397 [P1·산문] 정점 장면 2차 검수 수리

근거는 `PEAK_PROSE_REVIEW_2026-09-30.md` "2차" 표다. 범위는 KO/EN을 함께 고치는 1배치다.

1. `arc_jiyeon_y5_feelings`: 다은 대칭 비트(`arc_daeun_y5_feelings`)와 같은 밀도로 다시 쓴다.
   - 장소 한 곳, 지연의 지문 하나, "도도의 균열" 한 박자를 넣는다.
   - 머리말 "37세. 강남 근처."를 장면으로 바꾼다.
   - 선택2의 "강남으로 갔고"를 본문 사실과 대조한다.
   - 플래그·선택 수·효과는 유지한다.
2. `arc_jaehyuk_ghost_decision`
   - 본문 끝의 규칙 해설을 이미지로 바꾼다.
   - 결과문 셋에 각각 한 비트를 더한다.
   - 선택3 라벨과 결과의 사물을 하나로 맞춘다.
3. `arc_jaehyuk_01b_real_face`: KO 시제를 과거형으로 통일하고, 대사는 큰따옴표로 쓴다.
4. `arc_date_namsan_daeun`: 1~2년차에도 성립하도록 "5년을 좇아온 목표" 문구를 고친다.
5. ROMANCE_SYSTEM §8 레지스트리의 "남산 4문" 표기를 실제 ID(`arc_date_namsan_*`)로 정리한다.

**깊이 3문**
1. **왜 지금인가?** 지연 경로 플레이어가 같은 정점에서 절반 밀도의 장면을 받는다.
2. **무엇을 바꾸지 않는가?** 사실·선택·플래그·스케줄은 그대로 둔다.
3. **GO는 어떻게 되는가?** 비저자 판정을 받는다. 인간 게이트는 OPEN으로 둔다.

1번은 원고 재집필이라 WORK_UNIT의 위임 판정 절차를 따른다. 초안 뒤에 Claude나 비저자가
§8 6요소로 판정한다.

---

## ORDER-399 [P1·표면] 이야기 본문의 주인공을 이름으로 부른다

근거는 DECISIONS 2026-09-30(사용자 승인)이다.

### 깊이 3문
1. **왜 지금인가?** 서술 4,000곳이 "김민준은"으로 나오고, 다은이 "김민준씨"라고 부른다. 문장 개선
   배치(398)보다 먼저 들여야 판독 기준 화면이 고정된다.
2. **무엇을 바꾸지 않는가?** 세이브의 `player_name` 값, 사용자 지정 이름, 원고 문자열, NPC 이름표는 그대로 둔다.
3. **GO는 어떻게 되는가?** 전 언어 화면 캡처로 판정한다.

### 범위
1. 치환 경로를 모두 찾아 이야기 본문용 이름 함수 하나로 모은다. 알려진 곳은 `GameState.format_event_text`, `StoryMode._story_player_display_name`, `CommunicationPhone`의 `{name}`, `MainGame`의 직접 `.replace("{name}", …)`다.
   - 정본 기본 이름이면 언어별 이름을 쓴다: 민준 / Minjun / ミンジュン / ZH 용어집 표기.
   - 사용자 지정 이름이면 그대로 쓴다.
2. UI 정보 표면(프로필·저장 슬롯 등)은 전체 이름을 유지한다. 명패(`ImageRegistry` "player")는 VN 관례에 따라 이름만 쓰는 것을 기본으로 하되, 화면별로 정해 기록한다.
3. 공식 자기소개·명의 문맥 4곳(`arc_sangchul_mirror_receipt` "보호자 {name}입니다", `v2_daeun_return_after_distance` "{name}입니다", `arc_temptation_fallout` "{name} 명의", `hidden_011` "{name}님")은 전체 이름으로 고정한다(2장 지시서 F6).
4. 텍스트를 비교하는 QA 기대값(ScreenshotQA·ChoicePreview·NewRunLog 등 "김민준"/"Kim Minjun" 단언)을 같은 커밋에서 갱신한다.
5. 데모 공개 빌드(BUILD `2026.08.31.1`)는 동결이다. 이 변경은 successor 후보와 본편에 들어간다.

### 완료 조건
- 저장소 전체에서 이야기 경로가 전체 이름을 내는 곳이 0곳임을 grep과 런타임 표본으로 확인한다.
- KO/EN/JA/ZH 각 3장면(서술·다은 대사·재혁 대사)을 캡처로 확인한다.
- 이름 규칙(2026-07) 회귀를 확인한다. 언어를 바꾸면 기본 이름이 따라 바뀌고, 사용자 지정 이름은 보존돼야 한다.

---

## 기존 오더에 덧붙이는 인계 사실

- **ORDER-302 (영어 시제, 2026-09-30 사용자 승인)**: DECISIONS 2026-09-30에 따라
  successor 데모 후보에서 M01~M06 EN 현재형 장면을 3인칭 과거형으로 되돌린다. 해당
  장면은 `arc_daeun_01_meet`, `arc_jiyeon_01_crash`, `arc_sangchul_01_meet`,
  `v2_demo_first_bill_opening`, `v2_jaehyuk_plain_reunion_echo`와 그 체인이다. 302의
  5번 항목("한 시제로 통일")은 이 방향으로 닫는다. 공개 BUILD `2026.08.31.1`은 동결이다.
- **ORDER-396과 P-20**: P-20(2026-09-27)이 5장 서류어 4.7배를 같은 뿌리로 진단했다.
  396은 같은 규칙("증거는 원장이, 산문은 사물 하나와 몸짓이")을 4장에 적용한다.

- **ORDER-391**: 폰트 판정은 393으로 답이 났다(수리 뒤 SC/TC 번들 경로, 누락 0).
  남은 것은 392 이후 원장 결속, 393 이후 번들 폰트 재캡처, 비저자 독립검수다.
- **ORDER-352**: 7건 모두 `b0efea56`에 5개 언어 초안이 있다.
  - 5번(민서)은 변형 순서를 thought_about_after → contacted_minseo&minseo_real_talk → contacted_minseo → minseo_real_talk로 바꿨다. 기본문은 real_talk 없는 회수와 연락 경로 구절이다.
  - 착수 조건(5장 HOLD 수리와 겹침)은 그대로다. 들일 때 대상 줄이 HOLD 수리로 바뀌었는지 먼저 대조한다.
  - KO 원문이 바뀌므로 ORDER-365 KO 경계와 JA/ZH 원문 hash 규칙의 successor 처리가 함께 필요하다.
- **Claude 권한 메모**: 이 세션의 Claude는 자동 권한 모드 때문에 검증 도구 수정과
  브랜치 되돌림을 실행하지 못했다. 그래서 위 수리는 Codex가 소유한다. 같은 일을
  Claude에게 다시 맡기려면 사용자가 권한 모드를 바꿔야 한다.
