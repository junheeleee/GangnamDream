# ORDER-218 — 승인된 자각 알림과 역사 소스 지문 정합

> [x] 완료 — 구현·명시 차선·독립 검토 뒤 작업 범위 GO. 본편 전체 HOLD.

## 원인과 수리

원격 a283a4e의 CI34328097684/job102389983534는 year5 지문6건과 causal
지문1건으로 실패했다. ROOT의 수리 전 직접 재현도6/1이다. 정적 job 성공을
전체 CI 성공으로 합산하지 않는다. 원래 실패는 private order218-ci-preflight.json에 남긴다.

ORDER215가 승인한 MainGame metadata5줄(4삽입/1삭제)의 고정183B 전이만 연결했다.
현재77c690b8f4f41d9559b6aac25eb78d5de31d42be423dddbd3e889cf3287c67dd에서
고정 두 구간을 역치환하면 predecessor
3e15f8e44839857a4ad04ee3b1727f9869f72ebbb7cfe9153dfcf9f1d756629d가 된다.
현재 전체 raw·정확한 경로·원 registry·고정 inverse를 함께 확인한 뒤에만 옛 감사에
옛 소스를 보여준다. 현재 파일로 expected를 재계산하거나 옛 pin을 덮지 않았다.
MainGame·제품 manifest·human 원장·기존 승인 근거는 수정0이다.

## 구현자 회귀

Poincare가 코드 전에 봉인한22개/guard, 총44개가 기대대로 통과했다.
정상 current만 허용하며 rollback·다른 경로·raw15변조·registry 덮기를 거부했다.
새 inline27개/guard는 이44개와 중복하며 독립 표본으로 합산하지 않는다.
registry 제거/확장·역치환 손상·역사 pin을 current로 덮는 경계도 직접 검사했다.
기존 전역244/277은 그대로다. 지정 관측 hook과 새 helper를 역제거하면
두 전체 AST가 baseline과 정확히 같다. 기존 assert를 없애지 않았다.

- year5 전체 self487 = 기존460 + 신규27, exit0.
- causal 전체 self564 = 기존537 + 신규27, exit0(첫 실행641.61초).
- 신규 첫 실패0. 이전 원격/로컬6+1 실패와 별도이며 덮어쓰지 않았다.

검토 제품 C1:27baec9718ca62d498df2c1bd8481f4ed1bbca71.
동결 guard 지문:

- year5:609238B/bc25d913c1e6e7d760f21363320334ee41a1b4f18e32e0ae1b4f2ad150b93c93
- causal:1447618B/1bb65227fbd4de11017afa624d9c13e1f5b33596725336189357e2a1bee55cc2

private order218-own-final.json:11778B/
bdb0a40c5c5e08dad4bcc12afac669ae347f5da1ad183295bb2b41a1bf5d67fe.
이는 작성자 회귀이고 독립 검사·새 원격 CI·실제 플레이 증거가 아니다.
입력 관찰은 변경하지 않은 [ORDER215](ORDER-215.md)의 controlled W17뿐이다.
원어민·인간 독해·물리 패드·새240주·전체 품질은 미판정이다.

## 독립 검토와 최종 차선

Rawls가 구현 후 독립 입력58개를 실행 전에 봉인했다. raw30·projection14·
registry8·production6 전부 PASS, 필수 지적0이다. 다른 경로/별칭·반쪽 롤백·
중복 metadata·다른 함수·역사 pin 덮기를 거부하며, 순수 hash projection은
단독 권한이 아님을 실제 production raw 검사로 확인했다.
MainGame·manifest·causal 원장·release inventory·human·입력 QA·project.godot·
옛215 보고서를 선언 Git 객체와 직접 비교했다. 보호12입력 전후 불변이고,
지정 hook만 역제거하면 기존 전체 AST exact다.
private order218-rawls-independent-result.json:24250B/
c082ade8aef9e4c66f0348f61d904e0f22b1affad7220c774e8d8af635e09bd3.
이58개는 저자44나 self487/564에 합산하지 않는다.

명시 realization-protected-hash-reconciliation을 clean19b1933에서 --list 후1회
실행했다.11항목 모두 통과: year5 본검사/self487, causal 본검사/self564,
공개 demo 본검사/self4, full-body52, queue-index, scope140, context/queue.
출력은 private order218-final-named-lane.json에 보존했다.
동결 후 두 guard와 MainGame·역사 manifest는 변경0이다.

최종 source6bc268859d9854e78c55bd4ffb5360ba657f567e,
tree9c729fba6a0ef7df6567a51a656fc61b3242706e의 **ORDER-218 작업 범위 GO**.
C1→판정 source 변경은217 수용/상태 문서뿐이고218 두 guard와 보호 제품은 같다.
실제 명시 차선 HEAD19b1933과 차이는 STATUS뿐이다.
원격 전체 CI 성공은 관측 전 주장하지 않는다. 본편 HOLD·새 인간 플레이·
원어민·화면·물리 패드·외부 출고 미판정은 유지한다.

## 선언 사양 원문 — 아래 상태는 착수 시점의 역사

활성 사양 원형을 보관했다. 위 완료 판정이 현재 상태이며, 아래 소유·절차는
이 작업의 일회성 지시이지 다른 작업의 권한이 아니다.

````markdown
# Active Queue Spec: ORDER-218

> [~] 착수 — 감사2의 승인된 입력 metadata 지문 전이만. 2026-09-09 사용자 개발·검수 위임.

#### [~] ORDER-218 [P0·CI 정합] 자각 알림 수리와 역사 소스 지문을 연결한다

기준 main d45672552965c223a483656fc8ce2b9242bad92e. 번역217의 저작6파일과
숫자 검사3파일은 병렬 소유이며 이 수리에서 수정·스테이징하지 않는다.

## 문제와 한 단위

- remote a283a4e4cf3161a8d3d90c55be3dabefd5c934eb의 CI34328097684,
  job102389983534 전체 감사에서 year5 지문6·chapter1 causal 지문1이 실패했다.
  정적 job은 성공이며 전체 CI는 실패다. ROOT 현 source의 직접 재현도6/1이다.
- 승인 ed8067c421d646abb015a6ef8521a4eaaf9eb290의 MainGame 변경은
  자각 알림 입력 소유 metadata 4삽입/1삭제다. 실제 KO gamepad·EN keyboard
  controlled W17 증거와 한계는 변경 불가한 ../queue_archive/ORDER-215.md에 있다.
- 깊이: 전이를 인식하지 않으면 승인된 입력 수리를 CI가 계속 차단한다.
  임의 소스 변경과 이 승인 변경은 다른 상태여야 한다. 과거 pin을 덮는 것과
  완전한 고정 byte 역치환을 경쟁시켜, 후자를 택한다. 새 게임 선택은 만들지 않는다.

## 고정 신원과 보호

경로는 scenes/MainGame.gd 하나다. predecessor SHA256은
3e15f8e44839857a4ad04ee3b1727f9869f72ebbb7cfe9153dfcf9f1d756629d,
승인 current는77c690b8f4f41d9559b6aac25eb78d5de31d42be423dddbd3e889cf3287c67dd.
현재 파일을 expected로 계산하지 않고 exact 경로·원 predecessor·승인 current·
고정 5줄 diff와 byte inverse를 함께 검사한다. 다른 편집/경로/되돌림을 면제하지 않는다.

이전 year5 manifest의 protected_hashes/files/전이표, causal ledger의 source_hashes,
기존 서사/인간 증거/공개 데모 pin은 수정0이다. 옛 ORDER150/156 검사는 자기
바이트를 보되, 승인 current 검사는 현재 전체 바이트까지 검증해야 한다.
인간/원어민/물리 관찰과 전체 제품 HOLD는 불변이다.

## 소유와 검증

- Poincare 구현: tools/year5_reference_route_audit.py,
  tools/chapter1_core_loop_v2_causal_ledger_check.py만. 기존 함수·고정값·assert를
  삭제하거나 비활성화하지 않는다. exact successor/inverse 및 새 반례를 추가한다.
  MainGame raw를 직접 읽는 기존 self 두 관측 지점은 명시적인 고정 projection으로
  연결할 수 있다. 그 외 기존 self AST/fixture와 원형을 역치환 검증한다.
- ROOT 운영: 이 사양, docs/queue_archive/ORDER-218.md, tools/audit_scope.json,
  docs/CODEX_QUEUE.md, docs/CODEX_QUEUE_L3_PENDING.md, CLAUDE.md,
  docs/WORK_LOG.md, generated docs/STATUS.md, agent_review_decisions.json의218 새 기록만.
- Rawls 독립: 실제 코드·제품 불변·역치환·회귀 증거 읽기, private 증거만.
  작성자 자가검사와 최종 독립 검수는 별개다.
- KO/EN/locale/runtime/save/font/assets/project.godot/제품 manifest/인간 원장/217
  제품·도구 파일 수정0. 현재 병렬 변경은 되돌리거나 넓게 스테이징하지 않는다.
- 먼저 정상 current·고정 predecessor, 잘못된 old/current/path, 한 줄 추가/삭제,
  metadata 일부누락·다른값·다른함수 변경·원 registry를 current로 덮기·역치환 실패를
  실제 비교 함수에 넣을 유한 반례를 봉인한다. 이후 좁게 구현하고 기존 self도 실행한다.
- named realization-protected-hash-reconciliation을 --list 후 단독 실행한다.
  두 정적 본검사·기존/신규 self, 공개 localization·full-body scope·queue-index·
  등록/context/queue/diff를 검사한다. 전체 audit/Godot/240주 반복은 하지 않는다.
- 독립 필수 지적0 뒤 정확 소스의 작업 GO만 별도 원장에 기록한다. 새 커밋 원격
  CI 성공은 관측 전 주장하지 않는다. 옛 실제 입력 관찰을 새 인간 실플레이로 세지 않는다.

선언·전이·증거·소유 절차는 일회성이다. 새 정본 규칙·새 게임 기능은 없다.
````
