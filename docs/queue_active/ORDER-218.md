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
