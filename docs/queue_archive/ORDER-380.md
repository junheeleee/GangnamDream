# ORDER-380 — 중국어 직업 상태 잘림·교정 증명

[x] 2026-09-28. 독립 work_unit 한정 GO. 부모 ORDER-379 화면 배치는 HOLD다.

- 최종 source `ffc564fcaee1d28826f19819f51f996dc7241a80`, tree `33b44313d226190f55cf0ea73f8f1211b6482490`. [독립 보고](../agent_reviews/ORDER-380.json).
- 기존 상태 1키×CN/TW 2값을 공식 replace-existing 영수증으로 교정. accepted40832 불변, batch148→149. 교정은 신규 번역 수가 아니다. 제품 전이 `7727253→14547a1` 세 경로만 허용하며 append 일반 경계는 유지한다.
- clean 실행 `f30de0d4e29aba5f637d7359d2282a9f2ba0c420`: 표적12검사+선택조회1, 새 교정 self와 current guard/consumer5 포함 PASS. 실행→최종 소스 차이는 보고가 소유한다.
- 10준비화면/92lookup을 다시 관측했고 CN/TW T2/T4 상태4관측은 292px에서 217.0px로 줄어 288px 안에 들어왔다. 실제 제품/typed state/실사용자 파일 불변. 전체 화면 결과는 패드 T3 두 결함×2지역 때문에 여전히 FAIL이며 기존 닫기 glyph 부채8도 보존한다.
- first/second/third/fourth 실패 원본을 삭제하거나 PASS로 바꾸지 않았다. 자연진입·새입력·채용·정산·원어민·인간·물리 관측0, 공개GO1·인간OPEN45 보존. 본편/새package HOLD.
- 승격: I18N_INFRASTRUCTURE의 기존 수용 절에 기존값 교정의 별도 영수증/비중복 집계 및 수용 동결 전 실제 폭 확인 원칙. 정확 키·commit·검사/소유 범위는 일회성이다.

## 최초 선언 원문 보존

# Active Queue Spec: ORDER-380

> Canonical status and execution order are indexed in `docs/CODEX_QUEUE.md`.

#### [~] ORDER-380 [P0·현지화 수리] 직업 상태 문구의 잘림과 정확한 교정 영수증

**[~] 2026-09-28 Codex 착수 — 아래 파일만 소유한다.** 부모 ORDER-379/157.
기준 `c1603017732de4053771f908ece71416704434bd`. 379 second의 실제 CN T2
상태 Label은 292px/288px이고 `_label`은 clip_text=true다. 379는 수리 전 HOLD.

## 깊이 3문·단위
1. 지우면: 새 중국어 상태 문구가 잘리고, append 전용 검사가 정식 교정도 막는다.
2. 24주 차이: 게임 진행·수치는 변경하지 않고 현재 취업 상태를 온전히 읽게 한다.
3. 경쟁: 런타임/전역 레이아웃 확대 대신 같은 뜻의 짧은 문장과 좁은 교정 증명을 쓴다.
문구 1키×CN/TW 2값과 그 교정 전이 검증 1개, 서로 결속된 1배치다.

## 소유권
- root: `locale/ui_zh-CN.json`, `locale/ui_zh-TW.json`의
  `마포 첫 면접 완료 · 다음 지원 진행 중`만 간결화. 후보는
  CN `麻浦首次面试完成 · 后续应聘中`, TW `麻浦首場面試完成 · 後續應徵中`.
- root: `content/meta/full_game_localization.json`의 해당 accepted target 2개와
  accepted checksum만 갱신, 기존 batch148개를 그대로 둔 채 `ui_correction`
  batch1개에 새 공식 export/replace-existing/check/import header·receipt2와
  교정 전 target hash를 결속. 신규 수용 수 증가0, 기존379 receipt 원형 보존.
- compat357: `tools/ui_translation_append.py`, 기존
  `tools/ui_translation_append_self_test.py`만. append 일반 검증은 엄격히 유지;
  봉인한 실제 교정 commit/직접 parent/3경로/blob/전후값과 한 correction 행만
  검증한다. 비교용 역상과 실제 current raw를 구별한다. 이웃변조·확대·rollback 거부.
- root: 이 사양/완료 archive, 큐 두 인덱스, CLAUDE 현재행, WORK_LOG,
  생성 STATUS, agent 원장/보고, 필요 시 I18N의 기존 수용 절 한 곳만.
- root/screen_path_probe: git-private 379/380 증거·helper. root만 격리 엔진 실행.
- r3_route_probe: 비저자 두 값 및 교정 경계·실행·PNG·최종 source 검수.
공유 파일 동시 저작 금지. 런타임/폰트/KO/EN/JA/다른 번역/인간원장/공개demo 비소유.

## 표적 검증과 완료
- 첫/second 실패 원본을 보존한다. 표적 화면을 실패하더라도 수집하여 나머지
  결함을 한 번에 분리하고, fail을 PASS로 바꾸지 않는다.
- 새 교정 전이 self와 current guard, 영향받는 현행 consumer 정상 경로만 실행.
  변경 없는 역사 self·전체 감사·240주는 반복하지 않는다. registry/context/queue/diff 포함.
- 379의 동일 10준비화면·92 lookup을 교정 뒤 재관측. 두 지역 T2의 실제폭과
  glyph/bounds, 실사용자 파일/격리/저장 불변을 확인한다. 기존 닫기 ✕ glyph는
  원래 실패노드와 별도 OPEN 부채로 보존하고 전체 glyph PASS로 부르지 않는다.
- 독립 work_unit source GO 뒤 379/380을 각각 닫는다. 실제입력/자연진입/채용/
  정산/원어민/인간/물리 관찰 주장은 추가하지 않는다. 본편/새 package HOLD.

## 규범 판정
이번 키·값·Git 전이는 일회성 수리다. 교정도 새 공식 영수증과 변경 이력을
보존한다는 원칙만 필요하면 기존 I18N 수용 절에서 설명한다.
