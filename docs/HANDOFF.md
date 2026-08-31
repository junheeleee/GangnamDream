# HANDOFF.md — 세션 인수인계

> **6,000바이트 상한.** 상태는 `CLAUDE.md`, 실행 순서·상태는
> [`CODEX_QUEUE.md`](CODEX_QUEUE.md), 자동으로 만들 수 없는 판정은
> [`human_gates.json`](human_gates.json)이 각각 한 번만 소유한다. 이 파일은
> 세션 경계에서 꼭 알아야 할 위험만 적고 순서를 복사하지 않는다.

## 지금 상황

- 공개 출시 데모는 **M01~M06**에서 끝나는 active `story_demo_rc`이고 사용자
  GO다. 한 달 네 주라 내부 실행이 24주·정산 6회인 것은 M07~M24 공개 범위를
  뜻하지 않는다.
- exact 공개 후보는 BUILD `2026.08.31.1`, active
  `story_demo_rc` package source `362578d8f4c0781fe35f643a74cc3037e7a80b21`
  / tree `e7f50b065b3369afa1894df8292756a95f94fd11`, 제품 `4e80a63e`다.
  manifest는 `50eed10b18c2c2b056f875a8df55230dc07b5535c55e59ddb89fff1d64e91870`이다.
  실제 ZIP `956ac935` 안 PCK `0e606643`은 1,481 entry·KO/EN 사건 1,806건·
  shipping 1,696건·author-only 110건이며, 현재 본편 개발 소스의
  1,812/1,707/105와 별도 원장으로 검증한다. ZIP의 실행 앱 7파일과 PCK의
  raster/audio import 437개·모든 payload MD5도 frozen source와 직접 대조한다.
  BUILD `2026.08.25.1`과 ORDER-124 BUILD `.3`은 역사 증거다. 이 GO는 저장 호환
  AP 데이터·엔진 삭제나 legacy V2 기본 활성화 승인으로 해석하지 않는다.
- 옛 W1~W24 V2 `demo_rc` BUILD `2026.08.22.1`, exact
  `ebc58a839d64d8810b9da5548c20e58bc43c9e30` / tree
  `f978a22525b678ef83619dc50094a6dada75f190`는 `runtime_default=false` 내부 저장
  호환·회귀 증거다. 미래 공개 데모가 아니다. BUILD `2026.08.11.2` / `573606`은
  역사 후보, BUILD `.3`은 ORDER-99 저장 복구 전용 후보다.
- 본편은 M01~M60 전체이며 `product_go=HOLD`, `human_density_gate=OPEN`이다.
  Chapter 5 property/general 두 정상 속도 게이트도 OPEN이며, 새 exact 후보의
  M49~M60 전체 재플레이 전에는 승격하지 않는다. 공개 데모의 JA·zh-CN·zh-TW
  원어민 자연스러움 게이트도 각각 OPEN이다.
- 240주 `full_rc` 자동 증거는 BUILD `2026.08.24.5`, exact
  `6c91e11c128c4535f5c5852845b0e7309947e162` / tree
  `da15e65977849ab8bf912f3612fa9fd511eee99d`, manifest
  `1cef15ff75eba4e04b45d6d672ce53c8c9365d3d5a3840c51467c49a75178c8a`다.
  세 플랫폼·전체 감사·KO/EN 240주·장별 저장·pack/고지·R1b 비도달은 PASS지만
  현재 본편 GO나 Chapter 5 사람 판정을 대신하지 않는다.
- P-4의 W1~W24 V2 저장→W24 CTA→W25 bridge는 legacy 호환 게이트다. 공개 데모
  길이와 무관하며 현재 playtest 저장이 격리돼 있어 OPEN이다.
- 최종 연령 등급·삭제·export filter와 본편 출시 GO는 계속 사용자 소유다.
- 원래 `main` 작업트리의 Claude/사용자 변경과 사용자 소유 `project.godot`은
  별도 clean worktree에서 수정·스테이징·복구하지 않았다.

## 반드시 남겨 둘 정합 위험

- `gambling_rock_bottom`은 조건상 `addiction >= 80`과 미소비 flag만 요구하지만
  산문은 빈 통장과 빌린 돈을 확정한다. 실제 현금·부채와 모순될 수 있다. 다음
  사용자 승인 정합 작업에서 조건을 보강하거나 상태별 산문으로 나눠야 하며,
  현재 문장을 잔액/부채의 사실 증거로 쓰면 안 된다.
- ORDER-69의 component PASS와 BUILD `.3`의 격리 W24 완료 저장은 실제
  demo-flavor 저장을 full MainGame에서 W25로 잇는 제품 bridge 증거가 아니다.
- 카페 기회 정산은 `.5원`을 저장하며 0원 `stake_ratio`도 투자 플래그를 만들 수
  있다. 현금 단위·구매력 가드는 P-6 결정 전까지 해결된 것으로 말하지 않는다.

## 출시 증거 경계

- `BUILD_PIPELINE.md`의 `e849a6a` 외부 RC는 V2 이전 역사 빌드다. 새 표본이나
  출시 GO에 재사용하지 않는다.
- legacy 내부 `demo_rc`의 manifest는
  `8a34920038962a4ba0885ad6189d92dc6d3c3ee2780020f3894938d380613177`다. exact detached
  재검증은 full/surface matrix와 ORDER-98의 다섯 runtime marker를 통과했고,
  InputMatrix의 계약상 허용된 리소스 3개 종료 noise 밖 금지 오류는 0이다.
- active `full_rc` artifact SHA-256은 Windows
  `b8d3f11f2e3655884360c52514030c988f04d425e58e56762180ca39e22bf0d5`, macOS ZIP
  `878fddb3d7fd81e88a812cfd2781c0c265b5e724a54938cad6f1fce10be99800`, Linux
  `759af7dd214ae2ce9fa5741fa66ba380a535cfde1ec20fd8e1d705c53e506a49`다.
  durable 자동 증거는 `build/qa/order125-full-rc/2026.08.24.5`에 있고 BUILD
  `.4`는 stale causal snapshot 3건 때문에 후보로 등록하지 않았다.
- legacy V2 외부 30분 package/session 묶음은 미발급이다. 이 경로의 정상 속도
  W1~W24·연속 A/V·물리 패드 OPEN은 저장 호환 실험의 미완료 판정으로 보존하되,
  사용자 GO가 끝난 공개 M01~M06 `story_demo_rc`를 막거나 대체하지 않는다.
- 공개 데모 GO와 별개로 JA·zh-CN·zh-TW 원어민 판정은 같은 exact
  `story_demo_rc`에서 각각 닫아야 한다. 자동 번역 감사만으로 닫지 않는다.

## 다음 세션 복귀

1. `CLAUDE.md`와 `CODEX_QUEUE.md`를 읽는다.
2. 원래 사용자 작업트리와 clean 통합 worktree를 혼동하지 않는다.
3. 실행 표 맨 위의 막히지 않은 오더 하나만 선언 커밋 뒤 착수한다.
4. 완료 RC가 생기기 전 판정 목록을 축약하지 말고, 생긴 뒤 `human_gates.json`의
   모든 항목을 정확한 후보·표본·합격 기준과 함께 사용자에게 준다.

## 열려 있는 사용자 결정

- `PROPOSALS.md` P-5~P-7: 치명 비용 미리보기, 1원 단위·0원 투자 가드,
  125년 동기와 옛 `mindset_*` 재편. P-4의 W24→W25 demo-save bridge는
  공개 데모 길이와 별개인 legacy V2 OPEN 이월 게이트다.
- 최종 콘텐츠 등급·지역별 설문 답·콘텐츠 삭제·export filter. 인벤토리는 후보
  build의 사실만 소유하며 에이전트가 이 결론을 자동 확정하지 않는다.
