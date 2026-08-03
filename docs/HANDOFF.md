# HANDOFF.md — 세션 인수인계

> **6,000바이트 상한.** 상태는 `CLAUDE.md`, 실행 순서·상태는
> [`CODEX_QUEUE.md`](CODEX_QUEUE.md), 자동으로 만들 수 없는 판정은
> [`human_gates.json`](human_gates.json)이 각각 한 번만 소유한다. 이 파일은
> 세션 경계에서 꼭 알아야 할 위험만 적고 순서를 복사하지 않는다.

## 지금 상황

- `ORDER-72`는 `24주 V2 도달 / 240주 full 도달 / package 포함·현재 비도달`을
  분리한 출시 콘텐츠 원장을 닫았다. 10개 preset은 모두 `all_resources`이고,
  KO/EN 사건은 각 1,597건이다. V2 공식 fresh-start 표면은 67건이지만 full
  사건·카지노·경마·홀덤·단타와 뒤쪽 로맨스/범죄/가족 콘텐츠도 pack에 들어간다.
- source raster 292장 중 활성 스토리 246장, game pack 대상 284장이다.
  ImageRegistry 외부 source 46장 중 38장은 pack에 있고 `.gdignore` 상점
  스크린샷 8장만 source-only다. 최종 시각 판정은 아직 사용자 몫이다.
- clean 구현 `1408609`의 Windows Full/V2 pack은 각 1,412 entries이고 해시는
  `1f742a5c…b297` / `ba14d823…50d2`다. V2 ZIP을 별도 flavor 인자 없이
  `--main-pack`으로 마운트해 전용 진입 1·retail 0·저장 충돌 0·24주 cutoff를
  확인했다. 이는 로컬 package 사실 증거이지 외부 RC나 출시 GO가 아니다.
- 생성형 AI 공시는 일부 2D·서사·EN뿐 아니라 코드와 녹음/샘플 기반 오디오
  제작 보조도 포함한다. 활성 이미지는 전수 목록화·검사했지만 모든 문안·코드
  경로를 사람이 인게임 전수 플레이했다고 주장하지 않는다.
- 최종 연령 등급·삭제·export filter는 `user_required`다. 열린 제안 5건 상한은
  설계·사업 제안에만 적용하며 사람 판정 목록에는 상한이 없다. 현재 13개
  human gate는 `demo_rc/full_rc REBUILD 대기`라 완성된 동일 RC 뒤 전체 절차를
  사용자에게 제공한다.
- 원래 `main` 작업트리의 Claude/사용자 변경과 사용자 소유 `project.godot`은
  별도 clean worktree에서 수정·스테이징·복구하지 않았다.

## 반드시 남겨 둘 정합 위험

- `gambling_rock_bottom`은 조건상 `addiction >= 80`과 미소비 flag만 요구하지만
  산문은 빈 통장과 빌린 돈을 확정한다. 실제 현금·부채와 모순될 수 있다. 다음
  사용자 승인 정합 작업에서 조건을 보강하거나 상태별 산문으로 나눠야 하며,
  현재 문장을 잔액/부채의 사실 증거로 쓰면 안 된다.
- ORDER-69의 component PASS는 프롤로그에서 만든 실제 demo-flavor 저장을
  정식판 MainGame 25주 UI로 여는 증거가 아니다. 완료 저장은 아직 CTA/V2
  차단에 막히며 P-4 결정 대상으로 남는다.
- 카페 기회 정산은 `.5원`을 저장하며 0원 `stake_ratio`도 투자 플래그를 만들 수
  있다. 현금 단위·구매력 가드는 P-6 결정 전까지 해결된 것으로 말하지 않는다.

## 출시 증거 경계

- `BUILD_PIPELINE.md`의 `e849a6a` 외부 RC는 V2 이전 역사 빌드다. 새 표본이나
  출시 GO에 재사용하지 않는다.
- 새 V2 RC는 모든 데모 P0가 main에 들어간 뒤 clean worktree에서 발급한다.
  정확한 commit/tree/manifest/플랫폼 해시 전에는 후보 리비전을 지어 쓰지 않는다.
- 외부 30분 이해도, 정상 속도 24주 완주, 연속 A/V, 물리 패드는 서로 다른
  판정이다. 자동 package·도달성 PASS가 이 중 하나도 대신하지 않는다.

## 다음 세션 복귀

1. `CLAUDE.md`와 `CODEX_QUEUE.md`를 읽는다.
2. 원래 사용자 작업트리와 clean 통합 worktree를 혼동하지 않는다.
3. 실행 표 맨 위의 막히지 않은 오더 하나만 선언 커밋 뒤 착수한다.
4. 완료 RC가 생기기 전 판정 목록을 축약하지 말고, 생긴 뒤 `human_gates.json`의
   모든 항목을 정확한 후보·표본·합격 기준과 함께 사용자에게 준다.

## 열려 있는 사용자 결정

- `PROPOSALS.md` P-4~P-7: 실제 데모 저장→정식판 25주 브리지, 치명 비용
  미리보기, 1원 단위·0원 투자 가드, 125년 동기와 옛 `mindset_*` 재편.
- 최종 콘텐츠 등급·지역별 설문 답·콘텐츠 삭제·export filter. 인벤토리는 후보
  build의 사실만 소유하며 에이전트가 이 결론을 자동 확정하지 않는다.
