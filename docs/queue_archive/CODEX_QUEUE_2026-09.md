## 큐 포인터 원문 보존 (2026-09-07)

작성 당시 머리말과 기존 함정 포인터의 원문이다. 현재 의무나 판정의 삭제가 아니다.

```text
# CODEX_QUEUE.md — Codex 작업 대기열·실행 스펙 (2026-07-07 Claude 작성)

## 과거 사고 사례와 공통 함정

기존 공통 함정은 [보존본](queue_archive/CODEX_QUEUE_2026-09.md)에 원문 그대로 있다.

---

```

## 현지화 수용 상세 (2026-09-07)

완료한 기계·원문 대조 수량을 담은 이전 인덱스 행의 원문 보존이다.
각 오더는 L3 OPEN인 채 활성 큐에 남으며, 아래 [~]도 완료/승격으로 바꾸지 않는다.

```text
| 순서 | 상태 | 항목 | 실행 사양 | 현재 게이트 |
|---:|:---:|---|---|---|
| 1 | [~] | ORDER-172 · 가족·직장·친구 번역 | [172](queue_active/ORDER-172.md) | 1,140번역 L1/L2 · L3 OPEN |
| 2 | [~] | ORDER-171 · 데이트·계절 장면 번역 | [171](queue_active/ORDER-171.md) | 627번역 L1/L2 · L3 OPEN |
| 3 | [~] | ORDER-170 · 결혼·가족 장면 번역 | [170](queue_active/ORDER-170.md) | 618번역 L1/L2 · L3 OPEN |
| 4 | [~] | ORDER-169 · 일본어 원화 단위 정밀화 | [169](queue_active/ORDER-169.md) | 기존2문구 L1/L2 · L3 OPEN |
| 5 | [~] | ORDER-168 · 다은 관계·통화 번역 | [168](queue_active/ORDER-168.md) | 492번역 L1/L2 · L3 OPEN |
| 6 | [~] | ORDER-167 · 종막 서명·선발신 번역 | [167](queue_active/ORDER-167.md) | 591번역 L1/L2 · L3 OPEN |
| 7 | [~] | ORDER-166 · 마지막 해 번역 | [166](queue_active/ORDER-166.md) | 1,074번역 L1/L2 · reader78/언어 · L3 OPEN |
| 8 | [~] | ORDER-165 · 데모 간체 수량 정밀화 | [165](queue_active/ORDER-165.md) | 한 문장 수리 L1/L2 · L3 OPEN |
| 9 | [~] | ORDER-164 · 4년차와 아버지 경과 번역 | [164](queue_active/ORDER-164.md) | 1,380번역 L1/L2 · 조건128/언어 · L3 OPEN |
| 10 | [~] | ORDER-163 · 3년차와 장기 후속 번역 | [163](queue_active/ORDER-163.md) | 1,089번역 L1/L2 · foreshadow4/언어 · L3 OPEN |
| 11 | [~] | ORDER-162 · M07~M24 연결 사건 번역 | [162](queue_active/ORDER-162.md) | 837번역 L1/L2 · 조건변형28 보존 · L3 OPEN |
| 12 | [~] | ORDER-161 · catalog 전체 번역 | [161](queue_active/ORDER-161.md) | 2,502문구 L1/L2 · 신규2,485·기존수리1 · L3 OPEN |
| 13 | [~] | ORDER-160 · 남은 결말18종 번역 | [160](queue_active/ORDER-160.md) | 387번역 L1/L2 · 엔딩35종 본문 채움 · L3 OPEN |
| 14 | [~] | ORDER-159 · 일상·회복 결말 14종 번역 | [159](queue_active/ORDER-159.md) | 249번역 L1/L2 · 비표시 메타 제외 · L3 OPEN |
```

추가 보관: 저작·제품·기계·Codex 관찰 근거의 이전5행이다. 입력 QA·후속156·
원어민/사람 OPEN·HOLD/REJECT와 활성 의무는 현재 큐에 그대로 남는다.

```text
| 16 | [~] | ORDER-158 · 본편 8장면 번역 | [158](queue_active/ORDER-158.md) | KO 직접 20단위 · 세 언어 독립 · 원어민 OPEN |
| 17 | [~] | ORDER-157 · 본편 일본어·중국어 전체 번역 | [157](queue_active/ORDER-157.md) | 전체 분모·증분 배치 · 엔딩 75문구 검사 · 원어민 OPEN |
| 18 | [~] | ORDER-156 · Ch5 생활 routine 실제 배경 | [156](queue_active/ORDER-156.md) | 제품 53493fe · 입력 QA 잔여 · 사람 OPEN·HOLD |
| 19 | [~] | ORDER-151 · Ch5 장소·기간·카지노 맥락 | [151](queue_active/ORDER-151.md) | 두 경로 Codex 6/6 · 배경 수리 후속 156 · 사람 OPEN·HOLD |
| 23 | [~] | ORDER-147 · runtime identity | [147](queue_active/ORDER-147.md) | matrix GREEN · human REJECT |
```

# CODEX_QUEUE 2026-09 이동 보존

> 2026-09-07 부팅 예산에 닿은 공통 함정 절을 보존했다(상대 링크 경로만 조정).
> 현재 실행 순서와 상태는 ../CODEX_QUEUE.md가 소유한다. 완료 판정 기록이 아니다.

## 과거 사고 사례와 공통 함정

2026-07-07 이전의 병합 프로토콜·표면 용어 원칙·코드 앵커는 [queue_archive/CODEX_QUEUE_2026-07.md](CODEX_QUEUE_2026-07.md)에 보존한다. 지금도 유효한 함정만 남긴다.

- 유저 표면 문자열은 `_tr(kr,en)` 필수 — `_tr` 밖 한글 리터럴은 `english_hangul_audit.py`가 실패시킨다.
- 새 GameState var는 `serialize()` 또는 `tools/audit.py` `SERIALIZE_EXEMPT` 등록.
- MainGame은 StoryMode 다녀오면 재생성된다 — 턴 상태는 GameState 경유.
- 이벤트 JSON 루트의 새 키는 `tools/audit.py` `EVENT_ROOT_KEYS` 화이트리스트 선등록.
- 내부 시스템 용어(런/몽타주/tint/moral/축)는 플레이어 화면 노출 금지.
- 모든 신규 카피는 설교 방지 원칙(DECISIONS) 검수를 통과한다.

### legacy 부모 계획과 본편 범위

- legacy V2 부모: [57](../queue_backlog/ORDER-57.md), [58](../queue_backlog/ORDER-58.md),
  [59](../queue_backlog/ORDER-59.md), [61](../queue_backlog/ORDER-61.md),
  [62](../queue_backlog/ORDER-62.md), [63](../queue_backlog/ORDER-63.md),
  [64](../queue_backlog/ORDER-64.md), [66](../queue_backlog/ORDER-66.md),
  [67](../queue_backlog/ORDER-67.md)
- 본편 M07~M60 / Chapter 1 뒤 49~240주: [60](../queue_backlog/ORDER-60.md),
  [65](../queue_backlog/ORDER-65.md), [77](../queue_backlog/ORDER-77.md),
  `ORDER-64` 전 자산 확산, `ORDER-67` 나머지 구조화
- 열린 사람 판정과 정확한 scope/RC/표본/합격 기준은
  [`human_gates.json`](../human_gates.json)만 소유한다. 실행 큐에 사람 게이트 전용
  가짜 오더를 남기지 않는다.

## legacy V2 호환 보존선

옛 W1~W24 V2 `demo_rc`는 `runtime_default=false`인 내부 저장 호환·회귀·역사
증거다. ORDER-101 baseline 47·blocked 3, W1~8 save matrix, W24 뒤 U01..U20
모집단과 관련 코드·데이터·검사는 삭제하지 않지만, 이를 미래 공개 데모나
M01~M06 GO의 대체 후보로 다시 발급하지 않는다.

## 2026-07-07 초기 앵커 안내

> 전략 맥락: Steam "압도적으로 긍정적"이 목표 지표, 5레버는 `CLAUDE.md` 현재 상태 참조.
> 신규 정본 선독: `docs/DECISIONS.md` 2026-07-07 5건(Godot 네이티브 완성 / 외부 파이프라인 / 설교 방지 5원칙 / AP 축 / EN 표기).
> **앵커 주의**: 아래 파일:라인은 2026-07-07 HEAD 기준 — 라인은 ±30 오차 허용, 함수명으로 찾을 것.

## 정본 승격 이유

이유: 활성 오더는 완료 시 아카이브로 옮겨지고 부팅 문서는 아카이브를 읽지 않는다. 인덱스 항목은 표에서 제거되고 현재 상태는 매번 덮어쓴다. **오더 안에만 있는 규칙은 닫히는 순간 어떤 새 세션에도 도달하지 않는다.**
