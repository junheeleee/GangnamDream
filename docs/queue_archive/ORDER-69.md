# Archived Queue Spec: ORDER-69

> Canonical status and execution order are indexed in `docs/CODEX_QUEUE.md`.

#### [x] ORDER-69 [P0·밸런스] 24주 합법 경로가 정점 전에 무너지지 않게 한다

**착수 파일:** `content/meta/demo_core_loop_v2.json`,
`content/events/scenario_cafe_callback.json`, `autoloads/GameState.gd`,
`tools/demo_core_loop_v2_audit.py`, `tools/core_loop_v2_balance_sim.py`,
`tools/CoreLoopV2ECheck.gd`, `tools/CoreLoopV2HandoffCheck.gd`,
`scenes/MainGame.gd`, `docs/BALANCE.md`, `docs/CORE_LOOP_V2.md`,
`docs/QA_CHECKLIST.md`, `docs/PROPOSALS.md`와 큐/증거 문서.

**실행 중 발견한 정합 확장:** 25~48주 실제 scheduler를 claim하자 V2가 대체한
첫 달 장면이 7개월차에 재생되고, 후반 카페 선택이 대포통장 거절 플래그를
위조하는 것이 드러났다. 사용자의 장기-flow·모순 수리 지시에 따라 위 두 production
파일과 legacy save migration을 같은 인계 회귀에 포함한다. 0.5원·0원 베팅처럼
240주 화폐 정책을 바꾸는 발견은 `PROPOSALS.md`의 별도 사용자 결정으로 남긴다.

**사용자 승인 (2026-08-03):** `PROPOSALS.md` P-1 권고대로 진행한다.

## 깊이 3문

1. 지우면 무직 생계+성장 합법 경로가 필수 clean 사건 포함 12주 말에
   `mental_break`로 종료된다(사건을 뺀 종전 계산은 약 16주).
2. 고른 루틴에 따라 24주 정신력·현금·건강이 다르며 회복의 가치는 남는다.
3. 생계·성장·회복 세 자리가 같은 월간 시간 슬롯을 경쟁한다.

## 배치 A — 원장과 실제 압박 정렬

- V2의 `livelihood.unemployed`, `livelihood.employed`, `growth` 정신 효과만
  `-1 → +1`로 바꾸고 `recovery +3`과 5년 공통 월말 압박은 보존한다.
- 설명·정적 시뮬레이터·런타임이 `50만원/건강65/정신60`, 실제 계획·필수 사건·
  거절 결과·여섯 번의 월말 압박을 같은 순서로 읽게 한다.
- 월말 압박의 game-over 검사 뒤 포기비용이 0 이하로 내려가도 recap이 열리는
  순서 결함을 고쳐, 포기비용 직후 다시 `check_game_over()`하고 종료한다.

## 배치 B — 거짓 안전과 장기 인계 모순 제거

- Python은 3루틴 조합 × clean/return/deeper × 보수적/강경 선택의 18 kernel을,
  Godot은 최소 clean 미취업, clean 취업+회복, return+회복, deeper 결과 확인의
  네 경로를 1주부터 실제 실행한다.
- 21주에 90을 대입하거나 receipt/snapshot만 조립하지 않는다. 24주 clean 저점,
  return 저점, 회복 고점 저장을 그대로 25~48주에 이어 Week 48 결산까지 검사하고
  V2 효과가 24주 뒤 추가되지 않음을 잠근다.
- V2가 소비한 `opening_interview_math`와 완료한 `hyunsu_first_meet`의 durable
  receipt를 본편 scheduler가 읽어 7개월차에 첫 달 계산과 `서울 첫 두 달`을
  재생하지 않게 한다. 카페의 정직한 투자 선택은 대포통장 거절 전용
  `kept_clean_hands`를 만들지 않으며, 둘을 함께 가진 구 저장은 구체적인
  `lent_account`를 보존하고 오염된 clean 파생 플래그만 제거한다.

## 완료 증거

- 필수 사건·foreground·포기비용까지 포함한 1~24주 full-route 경로별 범위 기록
- 루틴·필수 사건만 따른 clean/취업/회복 개입 return/deeper 경로의 24주 이전
  `mental_break`: `0`; 의도된 위험 사망은 원인 선택 ID가 로그에 남음
- 변경 뒤 branch-only 참고 범위: 생계+성장 clean `정신39~47/건강24~31`,
  return `1~10/20~27`, deeper `23~33/24~31`; 이름 있는 component full-route가
  출시 지원 기준선을 별도로 소유함
- 회복을 쓴 return 지원 경로의 실제 24주 결과는 `H69/M73`, 실행 중 최저는
  `H61/M56`이다. 첫 실행 전 임시 하한 `H15/M10`은 폐기하며, branch-only
  return 강경의 `M1`은 출시 지원 checkpoint가 아닌 경계 회귀로만 남긴다.
- clean 저점·return 저점·회복 고점이 값 재설정 없이 Week 48 결산 도달
- 5년 공통 압박·`finish_run`·회복 수치 변경: `0`
- 구 오염 저장에서 이미 지급된 정신력 +10이나 Meta 칭호는 출처를 안전하게
  역산할 수 없어 자동 회수하지 않는다. 잘못된 future prose/route 생산만 차단한다.

## 정본 승격 판정

- **승격:** `docs/BALANCE.md`의 `2026-08-03 — 24주 정신력 생존성과 1장
  파급`이 세 루틴 변경값·불변값, 18 kernel, 네 W24 component 기준선과
  W25→48 정확 원장·저점·결정적 검사 정책을 소유한다.
- **승격:** `docs/CORE_LOOP_V2.md`의 `현재 구현 경계`와 `24주 제작 게이트`가
  decline 뒤 game-over 순서, durable V2→legacy 대체 receipt, dirty/clean
  플래그 불변식·구 저장 migration, component-runtime와 제품 UI 이월의 경계를
  소유한다.
- **승격:** `docs/QA_CHECKLIST.md`의 Core Loop V2 survivability·Year-One
  component carryover·demo-save continuation 행과 자동 onboarding gate가
  지속 회귀 조건과 사람/UI 비증거 범위를 소유한다.
- **일회성:** 착수 파일 목록, 종전 오계산 수열, 고정 RNG seed의 실제 숫자,
  fatal ordering fixture의 시작 현금과 종료 전 오디오 drain 시간은 이번 구현·
  진단 세부다. 제품 밸런스나 플레이어 정책으로 승격하지 않는다.

## 완료 보고 (2026-08-03)

- V2 무직/재직 생계와 성장 정신력을 `-1→+1`로 바꾸고 회복 `+3`, 여섯
  월말 압박, 5년 경제와 `finish_run`은 보존했다. 18 branch-only kernel은
  모두 생존했고 H20~79/M1~89다.
- 네 1→24주 component 경로는 W24에
  `-906,500/H28/M68`, `3,443,500/H42/M93`,
  `-2,086,500/H69/M73`, `4,373,500/H23/M52`로 끝난다. 임의 Week-21
  수치 reset·과거 receipt seed 없이 실제 계획·필수 사건·포기·월말을 실행했다.
- 같은 네 snapshot의 W48은 `1,763,500/H25/M41`,
  `12,006,537.5/H30/M56`, `583,500/H65/M47`,
  `5,840,787.5/H26/M61`이며 최저 H/M은 각각 `24/34`, `30/47`,
  `61/22`, `23/41`이다. 24주 이후 V2 효과·receipt·수치 정규화 0건,
  48주 첫해 결산과 49주 34세 경계가 정확하다.
- due decline이 정신력 1을 0으로 내리면 보통 월말과 24주 경계 모두 회고·CTA
  전에 `mental_break`로 끝난다. H5의 `urgent_paid_shift`는 `burnout`, 같은
  상태의 `body_rest`는 생존해 마지막 선택의 인과도 잠겼다.
- 소비 완료된 `opening_interview_math`와 완료된 `hyunsu_first_meet`이 옛 첫 달
  장면 두 개의 7개월차 재등장을 막는다. 카페 정직 투자는 더 이상
  `kept_clean_hands`를 위조하지 않으며 dirty/clean 오염 저장은 구체적인
  `lent_account`를 보존해 future prose와 경로만 바로잡는다.
- `context_manifest_check`, 큐 정합, 정적 감사, 18-kernel 시뮬레이션, V2 감사,
  240주 아크 흐름, E verbose, Handoff strict-exact, 58개 GDScript 컴파일과
  `GODOT=… ./tools/audit.sh` 전체 감사가 PASS했다. E/Handoff는 타이머·오디오·
  ObjectDB 누수 0이다.
- 자동 PASS는 실제 MainGame 프롤로그→24주 CTA 저장을 정식판에서 여는 제품
  이월, 선택 전 위험 표시, 1원·0원 투자 정책, 125년 동기 재편, 정상 속도
  재미·연속 A/V를 닫지 않는다. 각각 열린 P-4~P-7과 사람 게이트로 남겼다.
