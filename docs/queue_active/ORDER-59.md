# Active Queue Spec: ORDER-59

> Canonical status is indexed in `docs/CODEX_QUEUE.md`.

#### [ ] ORDER-59 [P0·정합 기반] 지식 원장 · 다은 phase · 규칙 기반 화계

**왜 지금인가 (2026-07-30 사용자 지시):** 앞으로의 작업이 대화량과 비트를
늘리는 것인데, 지금 구조로는 늘릴수록 모순이 생긴다. 사용자가 지목한 실패
형태가 전부 같은 구멍에서 나온다 — 현수가 본 적 없는 다은을 언급하고, 민준만
겪은 일을 남이 알고, 연도에 맞지 않는 대사를 하고, 호감 없는 다은이 연인처럼
말한다.

**실측 근거:** `story_rules.json`의 사건 179개는 하위 키가 `logic`과
`presentation` 둘뿐이다. **누가 말하는지도, 그 인물이 무엇을 아는지도 표현할
자리가 없다.** `fact_types`는 셋뿐이고(`father.life`,
`relationship.jiyeon.phase`, `sangchul.truth_resolution`) **다은 관계 단계는
typed fact가 아니다.** `speech_register_audit.py`는 사건 ID를 하드코딩한 회귀
락이라 새로 쓰는 장면을 자동으로 보호하지 못한다.

이 오더는 [`ENGINEERING_PLAN.md`](../ENGINEERING_PLAN.md)의 `F`를 수행한다.
작업은 [`WORK_UNIT.md`](../WORK_UNIT.md) 규격을 따른다 — 단위를 작게 자르고,
배치는 서로 의존하지 않게 묶고, 표본 검수를 받는다.

---

## 배치 1 — 다은 phase (6단위)

### 단위 1 · fact 정의

`content/meta/story_rules.json`의 `fact_types`에 `relationship.daeun.phase`를
추가한다. 지연과 **대칭 구조**를 쓰되 값은 다은의 실제 아크에서 뽑는다.

기존 지연: `unmet / acquainted / dating / married / married_compromised /
married_as_selves / left`

다은 아크의 실제 플래그(사용 횟수): `daeun_met`(7), `daeun_talked`(4),
`daeun_shared`(4), `daeun_romance_started`(8), `daeun_married`(5),
`daeun_ended`(5), `daeun_divorced`(1), `used_daeun_as_means`(1).

**값을 확정하기 전에 `docs/ROMANCE_SYSTEM.md`의 다은 라인을 읽는다** —
편의점 만남(t9) → 단골 → 꿈 이야기 → 갈림길(t23) → 고백/연애 →
프로포즈(t150+) → 결혼식(t200) → 상철의 시험(t182) → 최종 선택(t228).
`chose_daeun`과 `daeun_engaged`는 코드에 존재하지 않으므로 **값 이름을 실제
플래그에서 만들고 없는 상태를 발명하지 않는다.**

### 단위 2~5 · 생산자·독자 배선

**정본 규칙: 새 플래그는 생산자와 실제 독자를 함께 가져야 한다. write-only·
inert 기준선은 0이다.** 정의만 추가하고 배선하지 않으면 이 오더는 실패다.

지연이 쓰는 문법을 그대로 쓴다 — 사건의 `requires: [{fact, is}]`와
`sets: {"<선택 인덱스>": [{fact, set}]}`. 참고 위치는
`story_rules.json`의 `relationship.jiyeon.phase` 소비 지점이다.

단위를 아크 구간으로 자른다.

| 단위 | 구간 |
|---|---|
| 2 | 첫 만남 ~ 단골 (`arc_daeun_01_meet` 계열) |
| 3 | 갈림길 ~ 연애 시작 |
| 4 | 프로포즈 ~ 결혼 |
| 5 | 상철의 시험 ~ 최종 선택 |

### 단위 6 · 회귀 잠금

`story_consistency_audit.py`가 다은 phase의 생산자·독자를 지연과 같은 수준으로
검사한다. 전이 역행, 생산자 없는 값, 독자 없는 값은 실패다.

**보존:** 기존 플래그를 지우지 않는다. phase는 기존 플래그 위에 얹는 타입
계약이며, 저장 호환과 기존 엔딩 라우팅을 바꾸지 않는다.

---

## 배치 2 — 지식 원장 (단위 수는 착수 시 확정)

### 원칙

> **인물은 알 경로가 증명되지 않은 것을 언급할 수 없다.**

인물이 아는 것은 넷뿐이다. 직접 참여한 사건, 명시적으로 전달받은 것, 세계
공개 사실, 자기 자신. **화이트리스트가 아니라 블랙리스트로 가면 반드시
뚫린다.**

### 스키마

`story_rules.json`의 사건에 `speech` 블록을 더한다.

```json
"speech": {
  "speakers": ["hyunsu", "minjun"],
  "references": ["hyunsu.exam", "minjun.job_search", "goshiwon.kitchen"]
}
```

`references`는 그 장면의 대사가 건드리는 사실이다.

### 엄격도 — 존재가 아니라 전칭

**도달 가능한 모든 경로에서 알 수 있어야 통과한다.** 한 경로라도 모른 채
도달할 수 있으면 실패다. 그 대사를 조건부로 분기시키거나, 참조를 빼거나,
알게 되는 선행을 필수로 만든다.

`event_director_audit.py`가 이미 도달 경로를 계산하므로 그 인프라를 재사용한다.
새로 경로 계산기를 만들지 않는다.

### 적용 범위 — 여기가 핵심이다

**신규 장면에만 필수로 적용한다. 기존 1,581건은 래칫으로 악화만 막는다.**
전부 채우고 시작하면 영원히 시작하지 못한다. 앞으로 쓰는 것이 늘어나는
작업이므로 신규에만 걸어도 사용자가 지목한 문제는 막힌다.

기존 사건 소급은 인물별·장별로 나눈 **별도 오더**로 다룬다. 이 오더에
범위 확장으로 붙이지 않는다.

---

## 배치 3 — 규칙 기반 화계

`speech_register_audit.py`를 하드코딩 사건 목록에서 **규칙 기반**으로
전환한다. 지금 구조로는 새로 쓰는 장면이 보호받지 못한다.

사건이 `speech.speakers`와 그 시점 phase를 선언하면, 대사에서 호칭·어미·친밀
표현을 스캔해 단계 계약과 대조한다.

| 단계 | 호칭 | 화계 | 금지 |
|---|---|---|---|
| `unmet` | — | — | 이름·연락처·사적 사실 전부 |
| `acquainted` | `{성}씨` | 존댓말 | 반말, 애칭, 사적 약속 |
| `close` | 이름 | 존댓말 유지 | 애칭, 연인 전제 발화 |
| `dating` | 이름·애칭 | 혼용 | 결혼 전제 |
| `married` | 애칭 | 반말 허용 | — |

**위 표는 초안이다.** 실제 단계 이름은 단위 1에서 확정한 phase 값과
`ROMANCE_SYSTEM.md`의 호칭 정본을 따른다. 지연이 이미 `staged`로 관리되고
있으므로 그 패턴을 규칙화해 다은·현수·상철·재혁·민서로 확장한다.

기존 하드코딩 잠금은 **규칙이 같은 결과를 내는지 확인한 뒤에** 제거한다.
먼저 지우고 규칙을 만들지 않는다.

---

## 시점 계약 (배치 2에 포함)

`references`가 있으면 같은 원장으로 검사된다.

- 나이·연차 언급이 실제 주차와 일치한다.
- 직업·주거·자산 언급이 그 시점 상태와 일치한다(`ORDER-55`가 부분 구현).
- **아직 일어나지 않은 사건을 과거로 언급하지 않는다.**
- **이미 지난 사건을 미래로 언급하지 않는다.**

뒤 둘이 새로 필요한 것이다.

---

## 완료 뒤 이어지는 것

이 오더가 끝나면 `/scene-new` 스킬이 집필 시점에 화자가 아는 것과 관계 단계가
허용하는 것을 보여 줄 수 있다. 그것이 감사 왕복 비용을 없애는 지점이며
`ENGINEERING_PLAN`의 `C'`다.

인물 성경 8단위 배치는 **이 오더의 단위 1 이후**에 착수한다. 성경의
`자기 목표·모순·5년의 변화`가 지식 원장의 초기값이 되므로, 스키마가 먼저
있어야 이중 작업을 피한다.

## 금지·보존

- 기존 플래그 삭제, 저장 호환 변경, 엔딩 라우팅 변경 없음.
- 없는 관계 상태나 없는 인물을 발명하지 않는다.
- 기존 1,581 사건 소급은 이 오더가 아니다.
- 사용자 소유 `project.godot`은 건드리지 않는다.

## 검증

```bash
python3 tools/audit_select.py --base main    # 표적 감사
python3 tools/narrative_spine_audit.py
python3 tools/story_consistency_audit.py
python3 tools/speech_register_audit.py
./tools/audit.sh                              # 배치 마감에만
```
