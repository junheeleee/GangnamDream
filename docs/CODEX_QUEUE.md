# CODEX_QUEUE.md — Codex 작업 대기열·실행 스펙 (2026-07-07 Claude 작성)

> **Codex 세션 시작 시 이 파일을 CLAUDE.md 직후에 읽는다.** 위에서부터 우선순위순.
> 최초 작성 시점의 전략·앵커 주의는 [보존본](queue_archive/CODEX_QUEUE_2026-09.md#2026-07-07-초기-앵커-안내)에 있다.

---

## 과거 사고 사례와 공통 함정

기존 공통 함정은 [보존본](queue_archive/CODEX_QUEUE_2026-09.md)에 원문 그대로 있다.

---

## 운영 프로토콜 v3 (2026-08-03 사용자 지시 — 분석·계획·설계·검토 반복)

> 사용자 결정: Codex와 Claude 모두 분석·오더 분해·구현·검토를 할 수 있다.
> 사람 이름으로 지휘권을 나누지 않고 **단일 실행 큐, 작은 사양, 선언 커밋,
> 정확한 파일 소유권과 증거**로 충돌을 막는다. 최종 제품·서사·밸런스 결정권은
> 사용자에게 있다.

**루프**: ①실물과 1년/5년 파급을 분석 → ②1~2배치 사양과 검증을 먼저 설계 →
③선언 커밋 → ④구현 → ⑤수치·정합·한영·런타임 검토 → ⑥실패 원인을 고쳐 같은
게이트 재실행. 새 범위는 현재 오더에 붙이지 않고 새 오더/사용자 제안으로 분리한다.

**착수 선언**: 실행자는 오더에 착수하는 순간 큐와 사양을 `[~]`로 바꾸고, 정확한
파일 범위를 적은 **선언 커밋을 작업 커밋과 분리해 먼저 만든다.** 다른 에이전트는
그 범위를 건드리지 않는다. 원격 push는 사용자가 요청한 동기화 흐름에서만 하며,
로컬 선언 커밋 자체가 작업 소유권의 정본이다. 완료 시 증거를 남기고 `[x]`로 닫아
아카이브한다.
**정본 승격 판정 (2026-07-30 유저 승인 — 완료 조건)**: 오더를 `[x]`로 닫기 전에 **그 오더가 만든 규범 문장을 훑어 각각을 둘 중 하나로 판정한다** — ⓐ 계속 유효한 규칙이면 정본 소유자 문서에 승격하고 완료 보고에 `승격: <파일>:<절>`을 적는다, ⓑ 이 오더에서만 유효한 작업 지시면 `일회성`으로 명시한다. 판정하지 않은 규범 문장을 남긴 채 닫지 않는다.

이유: 활성 오더는 완료 시 아카이브로 옮겨지고 부팅 문서는 아카이브를 읽지 않는다. 인덱스 항목은 표에서 제거되고 현재 상태는 매번 덮어쓴다. **오더 안에만 있는 규칙은 닫히는 순간 어떤 새 세션에도 도달하지 않는다.**

승격 시 주의: 정본 소유자 한 곳만 갱신하고 다른 문서에 복사하지 않는다. 본문에 오더 번호나 진행 상태를 쓰지 않는다 — 오더가 끝나도 유효한 문장이어야 한다. 기존 정본에 이미 같은 규칙이 있는지 먼저 확인하되, **오더는 한국어이고 `assets/*VISUAL_BIBLE.md` 등 자산 정본은 영어이므로 한쪽 언어로만 검색하면 있는 규칙을 없다고 오판한다.** 두 언어로 확인하거나 소유자 문서의 해당 절을 직접 읽는다.

**작업 단위 규격 (2026-07-30 유저 지시 — 완료 조건)**: 한 단위는 하나의 판정 가능한 것(원고 300~800자 또는 파일 1~3개), 한 배치는 서로 의존하지 않는 15~25단위다. 착수 전 `깊이 3문`, 완료 시 `증거 양식`, 판정은 L1 기계·L2 자가·L3 사람 표본. **배치 20단위마다 사용자가 무작위 3개를 보고 하나라도 불합격이면 전량 반려한다.** 대형 다단계 오더를 만들지 않고 새 발견은 새 오더로 분리한다. 전체 규격은 [WORK_UNIT.md](WORK_UNIT.md)가 소유한다.

**Codex 사전 승인 대기 항목**(오더 없이 착수 금지): 정본 규칙 변경 / finish_run·엔딩 라우팅 / 밸런스 밴드 밖 수치 / 오더에 없는 신규 시스템 / **반쪽 기능의 완성 또는 제거**. 반쪽을 자기 판단으로 완성하는 것은 수리처럼 보이는 오더 밖 신규 작업이며, 이 저장소가 반쪽을 쌓아 온 경로다. 만들 근거도 지울 근거도 정본 인용이어야 하고, 인용할 정본이 없으면 판단이 아니라 의견이므로 `POST_LAUNCH_NOTES.md`에 기록만 한다. 그 외(표면·아트·QA·기존 큐 항목)는 기존처럼 자율.
**Tier1 정점 산문**(§8 레지스트리)은 Codex가 초안 작성까지, 커밋 후 Claude 판정·리터치를 받는다(불합격 시 리라이트).

### 실행 오더 인덱스

> **우선순위와 상태의 단일 정본은 이 표다.** `CLAUDE.md`와 `HANDOFF.md`는
> 순서를 복사하지 않고 이 표만 가리킨다. `queue_active/`에는 지금 착수 가능한
> 1~2배치 사양만 둔다. 큰 부모 계획은 `queue_backlog/`, 사람 판정은
> `human_gates.json`, 완료 기록은 `queue_archive/`가 소유한다.
>
> 실행자는 맨 위의 막히지 않은 항목 하나만 읽고 선언 커밋을 만든다. 상태는 이
> 표와 사양 머리말을 함께 바꾸며, 불일치는 자동 검사가 실패시킨다.

| 순서 | 상태 | 항목 | 실행 사양 | 현재 게이트 |
|---:|:---:|---|---|---|
| 1 | [~] | ORDER-169 · 일본어 원화 단위 정밀화 | [169](queue_active/ORDER-169.md) | 기존2문구 · L3 OPEN |
| 2 | [~] | ORDER-168 · 다은 관계·통화 번역 | [168](queue_active/ORDER-168.md) | 492번역 L1/L2 · L3 OPEN |
| 3 | [~] | ORDER-167 · 종막 서명·선발신 번역 | [167](queue_active/ORDER-167.md) | 591번역 L1/L2 · L3 OPEN |
| 4 | [~] | ORDER-166 · 마지막 해 번역 | [166](queue_active/ORDER-166.md) | 1,074번역 L1/L2 · reader78/언어 · L3 OPEN |
| 5 | [~] | ORDER-165 · 데모 간체 수량 정밀화 | [165](queue_active/ORDER-165.md) | 한 문장 수리 L1/L2 · L3 OPEN |
| 6 | [~] | ORDER-164 · 4년차와 아버지 경과 번역 | [164](queue_active/ORDER-164.md) | 1,380번역 L1/L2 · 조건128/언어 · L3 OPEN |
| 7 | [~] | ORDER-163 · 3년차와 장기 후속 번역 | [163](queue_active/ORDER-163.md) | 1,089번역 L1/L2 · foreshadow4/언어 · L3 OPEN |
| 8 | [~] | ORDER-162 · M07~M24 연결 사건 번역 | [162](queue_active/ORDER-162.md) | 837번역 L1/L2 · 조건변형28 보존 · L3 OPEN |
| 9 | [~] | ORDER-161 · catalog 전체 번역 | [161](queue_active/ORDER-161.md) | 2,502문구 L1/L2 · 신규2,485·기존수리1 · L3 OPEN |
| 10 | [~] | ORDER-160 · 남은 결말18종 번역 | [160](queue_active/ORDER-160.md) | 387번역 L1/L2 · 엔딩35종 본문 채움 · L3 OPEN |
| 11 | [~] | ORDER-159 · 일상·회복 결말 14종 번역 | [159](queue_active/ORDER-159.md) | 249번역 L1/L2 · 비표시 메타 제외 · L3 OPEN |
| 12 | [~] | ORDER-158 · 본편 8장면 번역 | [158](queue_active/ORDER-158.md) | KO 직접 20단위 · 세 언어 독립 · 원어민 OPEN |
| 13 | [~] | ORDER-157 · 본편 일본어·중국어 전체 번역 | [157](queue_active/ORDER-157.md) | 전체 분모·증분 배치 · 엔딩 75문구 검사 · 원어민 OPEN |
| 14 | [~] | ORDER-156 · Ch5 생활 routine 실제 배경 | [156](queue_active/ORDER-156.md) | 제품 53493fe · 입력 QA 잔여 · 사람 OPEN·HOLD |
| 15 | [~] | ORDER-151 · Ch5 장소·기간·카지노 맥락 | [151](queue_active/ORDER-151.md) | 두 경로 Codex 6/6 · 배경 수리 후속 156 · 사람 OPEN·HOLD |
| 16 | [~] | ORDER-150 · Ch5 human REJECT 수리 | [150](queue_active/ORDER-150.md) | 후속 151 exact 재플레이 대기 · 두 사람 gate OPEN · HOLD |
| 17 | [ ] | ORDER-148 · 5장 종막의 부정 종결 습관을 푼다(사실은 유지) | [148](queue_active/ORDER-148.md) | ORDER-150 exact 제품 뒤 재계측 · 금지 사실은 한 건도 삭제 금지 · 선행 대기 |
| 18 | [ ] | ORDER-149 · 프롤로그 세 비트가 같은 속도로 지나가는 문제를 푼다 | [149](queue_active/ORDER-149.md) | `P-18` 1층만 · `FADE_SECONDS` 0.52 하나를 세 비트가 공유·hold 3.10/3.10/3.00 · 새 자산 0 · 미착수 |
| 19 | [~] | ORDER-147 · runtime identity | [147](queue_active/ORDER-147.md) | matrix GREEN · human REJECT |
| 20 | [~] | ORDER-146 · ledger | [146](queue_active/ORDER-146.md) | 후속 151 새 exact 후보 · 두 replay OPEN |
| 21 | [~] | ORDER-145 · 후보 | [145](queue_active/ORDER-145.md) | HOLD |
| 22 | [~] | ORDER-143 · graph | [143](queue_active/ORDER-143.md) | M01~M06 보호 · HOLD |
| 23 | [~] | ORDER-144 · trace | [144](queue_active/ORDER-144.md) | PENDING · human OPEN |
| 24 | [~] | ORDER-142 · volume | [142](queue_active/ORDER-142.md) | M01~M60 · HOLD |
| 25 | [~] | ORDER-138 · finale | [138](queue_active/ORDER-138.md) | human REJECT · HOLD |
| 26 | [~] | ORDER-137 · Ch5 수리 | [137](queue_active/ORDER-137.md) | human REJECT · HOLD |
| 27 | [~] | ORDER-135 · 일반 경로 | [135](queue_active/ORDER-135.md) | human REJECT · HOLD |
| 28 | [~] | ORDER-119 · 표면 언어 | [119](queue_active/ORDER-119.md) | 사용자 GO OPEN |
| 29 | [~] | ORDER-118 · startup | [118](queue_active/ORDER-118.md) | 사용자 GO OPEN · R1b HOLD |
| 30 | [~] | ORDER-117 · career | [117](queue_active/ORDER-117.md) | 사용자 GO OPEN · R1b HOLD |
| 31 | [~] | ORDER-99 · SAVE-P0 | [99](queue_active/ORDER-99.md) | 사용자 확인 대기 |
| 32 | [~] | ORDER-97 · LOC-0.5 | [97](queue_active/ORDER-97.md) | L3 대기 |
| 33 | [~] | ORDER-98 · PAD-1 | [98](queue_active/ORDER-98.md) | 물리 패드 L3 OPEN |

### legacy V2 보존선과 본편 M07~M60 관리선

공개 출시 데모는 active `story_demo_rc` BUILD `2026.08.31.1`의 **M01~M06**에서
끝나며 사용자 GO다. 한 달 네 주라 내부 계측이 `weeks=24`인 것은 범위를
M07~M24로 늘린다는 뜻이 아니다. M01~M06 공개 데모를 더 확장하거나 새
`demo_rc`로 교체하는 자식 대기선은 없다. JA·zh-CN·zh-TW 원어민 판정은 각각
OPEN으로 남는다.

옛 내부 V2의 호환·재발급 금지는 [보존선](queue_archive/CODEX_QUEUE_2026-09.md#legacy-v2-호환-보존선)을 따른다.

이후 자식 작업은 공개 데모 증량이 아니라 **본편 M07~M60**의 장면·선택·회수·
정점 밀도를 M01~M60 전체에서 관리한다. 앞 작업의 실측값을 입력으로 쓰고, 차례가
오면 서로 의존하지 않는 15~25단위의 1~2배치 오더로 위 표에 올린다.

1. M01~M06 제품 바이트와 사용자 GO를 동결하고 세 원어민 게이트만 별도로 닫는다.
2. legacy W1~W24 V2의 저장·영수증·회귀 계약은 호환 경로에서만 보존한다.
3. M07~M60은 story map·typed graph·fresh-title trace로 공백과 잘못된 ingress를 먼저 찾는다.
4. 장면 수를 맞추지 않고 실측 결손만 15~25단위 표적 원고·연출 배치로 수리한다.
5. Chapter 5 두 경로는 새 exact 후보의 M49~M60 정상 속도 재플레이 전까지 HOLD다.
6. 2026-09-07 사용자 지시로 M01~M60 JA·zh-CN·zh-TW 번역을 지금 시작한다. 원문 hash로 이후 변경을 검출하며 출시·원어민 GO는 별도다.
7. 전체 본편은 `product_go=HOLD`, `human_density_gate=OPEN`을 닫기 전 승격하지 않는다.

### legacy 부모 계획과 본편 범위

부모 참조와 사람 게이트 소유 원문은 [이동 보존본](queue_archive/CODEX_QUEUE_2026-09.md#legacy-부모-계획과-본편-범위)에 그대로 있다.

### 완료·반려 이력

**정본은 [`queue_archive/CODEX_QUEUE_2026-08.md`](queue_archive/CODEX_QUEUE_2026-08.md)다**
(그 이전은 [2026-07 스냅샷](queue_archive/CODEX_QUEUE_2026-07.md)).
완료 항목과 복구 오더로 이관한 반려 시도는 여기 쌓지 않고 그리로 내린다 —
**예산이 모자라면 압축이 아니라 이동이다.**

- 상세 작업 결과는 [WORK_LOG.md](WORK_LOG.md), 사용자 노트와 라운드 판정은
  [DEMO_FIXLOG.md](DEMO_FIXLOG.md), 설계 결정은 [DECISIONS.md](DECISIONS.md)가 정본이다.

## 공통 검증 (모든 항목)
```bash
python3 tools/audit_select.py -- <변경 파일...>
git diff --check
```
- ORDER-124는 전용 M01~M06 스토리 선택 차선만 쓰며 기존 24주·240주 검사를 실행하지 않는다.
- ORDER-118은 startup 16편·코드 토큰 표면·invalidated 계약만 검사한다. R1b·save·
  dispatcher·transaction·ending·JA/ZH는 건드리지 않고 전체 감사·240주를 생략한다.
- ORDER-117은 지목 2편과 career 15편·보존 1편만 검사하며 story map·계약·runtime·
  save·ending을 byte-exact로 둔다.
- 카피·번역 변경은 해당 언어 감사, 화면 변경은 해당 ScreenshotQA 범위만 더한다.
- `./tools/audit.sh`와 240주 검사는 활성 사양이 공통 스키마·스케줄러·엔딩을
  바꾸거나 챕터 승인·demo/full RC를 판정할 때만 실행한다.
- 완료 시 CLAUDE.md 현재 상태 + docs/WORK_LOG.md 갱신, 이 파일 해당 항목에 `[x]`+날짜.
