# HANDOFF.md — 세션 인수인계

> **6,000바이트 상한.** 상태는 `CLAUDE.md`, 실행 순서·상태는
> [`CODEX_QUEUE.md`](CODEX_QUEUE.md), 자동으로 만들 수 없는 판정은
> [`human_gates.json`](human_gates.json)이 각각 한 번만 소유한다. 이 파일은
> 세션 경계에서 꼭 알아야 할 위험만 적고 순서를 복사하지 않는다.

## 지금 상황

- 본편 Chapter 1 제작 단위는 W1~48 한 해지만 데모 제품 범위는 W1~24이며
  W24 CTA에서 끝난다. ORDER-100의 48슬롯 인과 원장과 W25~48 공백은 본편
  제작 사실이고 데모 출시·RC·사람 판정의 조건이 아니다.
- BUILD `2026.08.11.3`은 사용자의 W4 교착 저장을 살린 W1~24 audited-prefix
  체크포인트다. 데모 경계는 맞지만 아직 같은 demo_rc의 사람·플랫폼 GO가 없어
  공개 승인본이 아니다. W25~48 legacy 폴백은 본편 Chapter 1 완성으로 세지 않는다.
- P-4의 제품 bridge는 실제 W1~24 demo-flavor 저장→W24 CTA→정식판 W25다.
  현재 playtest 저장은 격리돼 있으므로 이 별도 이월·출시 게이트는 OPEN이다.
- 최종 연령 등급·삭제·export filter와 실제 사람 GO는 계속 사용자 소유다.
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
- 최종 demo_rc는 W1~24의 모든 P0가 main에 들어간 뒤 clean worktree에서 발급한다.
  정확한 commit/tree/manifest/플랫폼 해시 전에는 후보 리비전을 지어 쓰지 않는다.
- 외부 30분 이해도, 정상 속도 W1~24 완주, 연속 A/V, 물리 패드는 같은 demo_rc의
  서로 다른 판정이다. `.3`의 자동 package·도달성 PASS가 이 중 하나도 대신하지
  않는다. W25~48은 이 판정 뒤 별도 본편 제품선이다.

## 다음 세션 복귀

1. `CLAUDE.md`와 `CODEX_QUEUE.md`를 읽는다.
2. 원래 사용자 작업트리와 clean 통합 worktree를 혼동하지 않는다.
3. 실행 표 맨 위의 막히지 않은 오더 하나만 선언 커밋 뒤 착수한다.
4. 완료 RC가 생기기 전 판정 목록을 축약하지 말고, 생긴 뒤 `human_gates.json`의
   모든 항목을 정확한 후보·표본·합격 기준과 함께 사용자에게 준다.

## 열려 있는 사용자 결정

- `PROPOSALS.md` P-5~P-7: 치명 비용 미리보기, 1원 단위·0원 투자 가드,
  125년 동기와 옛 `mindset_*` 재편. P-4의 W24→W25 demo-save bridge는
  데모 길이와 별개인 OPEN 이월·출시 게이트다.
- 최종 콘텐츠 등급·지역별 설문 답·콘텐츠 삭제·export filter. 인벤토리는 후보
  build의 사실만 소유하며 에이전트가 이 결론을 자동 확정하지 않는다.
