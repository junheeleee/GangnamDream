# 문장 개선 3장 작업지시서 (M25~M36, 2026-09-30 Claude 판독)

> 기준은 [`PROSE_REVISION_MASTER_PLAN.md`](PROSE_REVISION_MASTER_PLAN.md)다. 3장 이야기·정점 장면 56개의 KO 원문을
> 전부 직접 읽고 내린 판정이다. 재혁 배신 체인과 상철 대면은 [`PEAK_PROSE_REVIEW_2026-09-30.md`](PEAK_PROSE_REVIEW_2026-09-30.md)와
> ORDER-396·397의 판정을 그대로 따른다. 설날 장면(`arc_35_birthday`)은 ORDER-395가 맡는다.
> 순서가 의심스러운 장면은 `MainGame.gd` 스케줄로 확인했다.

## 진행 상태

2026-10-01 Claude가 배치10에서 F1·F2·F4·F5와 F3의 연애 기간을 KO/EN/JA/zh에 반영했다. F3의 동거 서술("같은 방")은 `ROMANCE_SYSTEM` 대조가 필요해 남겼고, F6(다은 고향과 부산 예식장)은 정본 판정이 필요하다. 같은 날 도덕 해설 표 중 `cost_of_knowing`·`sangchul_deeper_room`·`35_orthodox/unorthodox_weight`를 반영했다. `arc_jaehyuk_04b_counter`는 데모 고정 파일이라 Codex 7k에 넣었다. 장면별 판정은 남았다.

## 결론

3장은 **탐정 구조가 가장 잘 짜인 장**이다. 기준 장면은 다음과 같다.

- 상철 추론 체인(`arc_sangchul_deduction*`): 사건번호, 폐업 등록부, 마포 주소가 한 칸씩 맞아 들어간다.
- `arc_sangchul_buried_silence`: "이제 이 침묵은 무지가 아니라 계약이었다."
- `arc_sangchul_stairwell`: 세 걸음.
- `arc_daeun_first_night` 체인
- `arc_35_alone`, `arc_goal_vertigo`

약점은 세 가지다.

1. **서술자가 도덕 판정을 직접 말한다**(`arc_jaehyuk_04b_counter`).
2. **내부 분류어가 산문에 드러난다**("정석/비정석").
3. **장 마감이 주제문을 여러 번 되풀이한다.**

## 이야기 사실 결함

| # | 위치 | 결함 | 수리 |
|---:|---|---|---|
| F1 | `arc_jaehyuk_sangchul_echo` 본문 | "투자 얘기를 하는 친구가 있다고, 군대 선임이었다고." 재혁은 같은 내무반 **동기**다(`arc_jaehyuk_01_reunion`, `_ghost_message`의 "군대 동기"). | "군대 동기"로 바꾼다. |
| F2 | `arc_y3_hyunsu_verdict` | "최종 면접에서 떨어졌다고. 4년의 끝이었다." 이 장면은 현수가 합격도 방향 전환도 하지 않은 경로에서 `t >= 133`에 열린다(`MainGame.gd` 8317). 현수는 M01에 이미 "공시 4년째"였으므로 이 시점에는 6년이 넘는다. | 기간을 바로잡는다("여섯 해가 넘는 시험의 끝"). 또는 단정하지 않는다. EN도 함께 확인한다. |
| F3 | `arc_daeun_year3_together` 변형 `daeun_romance_started` | "연인이 된 지 2년이 넘었다." 이 장면은 `t >= 100`에 열리고, `daeun_romance_started`의 생산자는 `arc_daeun_04b_future`(`t >= 86`)와 5년차 고백뿐이다. 따라서 연애 기간은 몇 달이다. 같은 변형의 "같은 방, 같은 새벽"(동거)이 정본인지도 확인이 필요하다. | 연애 기간을 "사귄 지 몇 계절"처럼 맞춘다. 동거 서술은 `ROMANCE_SYSTEM.md`와 대조한다. |
| F4 | `arc_jiyeon_year3` 본문 | "상철의 소개, 처음 배운 짧은 매매." 지연과 민준은 자전거 사고로 만났다(`arc_jiyeon_01_crash`). | "빗길의 사고, 처음 배운 짧은 매매"처럼 정본 첫 만남으로 바꾼다. |
| F5 | 상철을 만나는 장소 | `arc_father_06_confession` 선택1·2와 `arc_sangchul_deduction_decision`은 "같은 카페, 같은 자리에서 차트를 가르쳐주던"이라고 쓴다. 정본의 상철 공간은 신촌 부동산 사무실이다(`STORY_BIBLE.md` 184~201, `arc_sangchul_01_*`). 3장에는 카페 대면(`confrontation`)도 있어 둘이 섞였다. | "같은 사무실 책상에서"처럼 정본 장소로 맞춘다. |
| F6 | `arc_daeun_year3_apart`, `_year5_apart`, `callback_daeun_deferred_silence` | 헤어진 경로에서 다은의 결혼식이 "부산 예식장"이다. 함께하는 경로의 다은 고향은 모두 "시골"이다. 다른 도시에서 식을 올리는 설정일 수 있다. | 낮은 우선순위다. `STORY_BIBLE`에 다은 고향을 한 줄로 적고 맞는지 확인한다. |

## 도덕 해설·분류어 (CLAUDE.md 불변 규칙)

| 위치 | 문장 | 지시 |
|---|---|---|
| `arc_jaehyuk_04b_counter` 본문 끝 | "선택의 순간이다. {name}은 어떤 사람이 될 것인가." | 지운다. 재혁의 질린 얼굴에서 끊는다(R3). |
| 같은 장면 선택1 | 상철의 "잘했어. 돈보다 중요한 걸 지켰네." + "{name}은 빈손이었지만, 거울 보기가 부끄럽지 않았다." | 도덕 승인이다. 상철의 대사는 인물 말이라 남길 수 있지만, 서술자의 "거울 보기가 부끄럽지 않았다"는 지운다. 이 문장은 `arc_jaehyuk_aftermath` 선택1(2장 F1)에도 똑같이 있다. |
| 같은 장면 선택3 | "{name}은 선을 넘었다. 강남은 가까워질 것이다. / 빠르게. 더럽게." | 서술자가 도덕을 판정한다. "선을 넘었다"와 "더럽게"를 지운다. 이어지는 "아버지한테 보여줄 그 집이, 이런 돈으로 사는 집이어도 되는 걸까"는 인물의 질문이라 남긴다. |
| `arc_y3_cost_of_knowing` 선택1 끝 | "기록을 남긴다고 출처가 깨끗해지는 것은 아니었다." | 서술자의 판정이다. 지운다. 본문의 선택지 나열("알면서 쓸 것인지, … 닫을 것인지 오늘 행동으로 남겨야 했다")도 지운다(R3·R4). |
| `arc_y3_sangchul_deeper_room` 선택2 끝 | "그래도 {name}은 그게 값을 한 거라고 생각했다." | 자기 승인이다. 앞 문장 "돌아서는 데 쓴 힘은 아무 장부에도 안 적힌다."에서 끝낸다. |
| `arc_35_orthodox_weight`, `arc_35_unorthodox_weight` | "3년째 정석을 지켰다", "이게 정석의 무게였다", "3년째 비정석이었다", "이게 비정석의 무게였다" | `description_orthodox/unorthodox` 경로의 내부 분류어가 산문에 드러난다. 결과는 모두 격언이다("한 방을 노리는 사람은 한 방에 잃기도 한다", "전부를 거는 사람은 전부를 잃는다", "차트는 도망가지 않는다"). **재작성한다.** 분류어 없이 그 사람의 하루(적금 이체 알림, 새벽 3시의 차트)로 쓴다. |

## 장면별 판정

### 배치 1 — M25~M28

| 장면 | 판정 | 지시 |
|---|---|---|
| `arc_daeun_05_together` | 유지 | |
| `arc_father_05_after_visit`, `arc_father_quiet_call` | 유지 | |
| `arc_y3_father_avoidance_document` | 예고 | 본문 둘째·셋째 문단("오늘 할 일은 … 아니라 … 일이었다", "어느 쪽이든 침묵으로 끝내지 않고 전송 또는 발신 시각을 남겨야 했다")은 설계 규칙을 인물의 과제로 말한다(R3·R4). 첫 문단의 18초 음성과 등기 봉투에서 끊는다. 결과는 유지한다. |
| `arc_daeun_hometown_1`, `arc_daeun_year3_apart` | 유지(F6) | |
| `arc_jiyeon_father_records` (T1) | **재작성** | 544자로 얇다. 현재형이 섞였다("안다", "모른다", "생각한다"). 본문 끝이 "말할 수 있다. 아니면, 삼킬 수 있다."로 선택지를 예고한다(R3). 선택1 끝 "편한 게 죄는 아니지만 — 이제 그녀는 그 편함이 어디서 왔는지 안다."는 도덕 해설이다. 지연 앞의 사물 하나(아버지 회사 로고가 찍힌 무언가)와 지연의 0.5초 균열로 다시 쓴다. |
| `arc_jiyeon_year3` | F4 | |
| `arc_jaehyuk_03_pitch` (T1) | 표기 | 현재형("기울인다", "낮춘다", "두드린다", "짓는다")을 과거형으로 바꾼다. 선택2 끝 "그 본능이 나중에 {name}을 살릴지도 몰랐다"(미래 암시)를 지운다. |
| `arc_year_two_pressure` | **재작성** | 현재형이고 결과 셋이 격언이다("사람이 좋으면 어떤 소식이든 반갑다. 내 길은 내가 간다", "세상이 더 단순해진 느낌"). 민기의 청첩장이라는 사물 하나로 다시 쓴다. |
| `arc_35_orthodox_weight`, `_unorthodox_weight` | **재작성** | 위 분류어 표와 같다. |
| `arc_daeun_year3_together` | F3 | 결과는 유지한다. |
| `arc_jaehyuk_hyunsu_warning` | 유지(소폭) | 선택1 "어렵게 어렵게"는 1장 `_03b_lunch`에도 있다. 한쪽을 다른 말로 바꾼다. |
| `arc_y3_jiyeon_departure` | 유지 | |

### 배치 2 — M29~M31

| 장면 | 판정 | 지시 |
|---|---|---|
| `arc_jaehyuk_wait` | 표기 | 본문 현재형("다음 주다", "없다", "모르겠다", "숫자가 된다")을 과거형으로 바꾼다. |
| `arc_sangchul_known_offer` | 유지 | |
| `arc_why_gangnam_real` | 끝 | 선택1 "증명하려는 마음이 나쁜 건 아니다."(도덕 승인)와 선택3 "모른다는 것을 아는 것. 그게 3년 전보다 나아진 것일 수도 있었다."(R2)를 지운다. 선택2는 기준 장면이다. |
| `arc_35_alone`, `arc_goal_vertigo` | 유지 | 기준 장면이다. |
| `arc_daeun_first_night` 체인 | 유지(1줄) | `_decision` 선택2 끝 "서른 몇의 연애는 — 조급하지 않아서, 오히려 단단했다."(R2)만 지운다. 바로 앞 문장("서두르지 않아도 되는 사이라는 게 이상하게 더 깊었다")이 같은 말을 이미 한다. |
| `arc_jaehyuk_04b_counter` | 도덕 표 | 현재형 "질린다"도 과거형으로 바꾼다. |
| `arc_jaehyuk_photo_in_dark` | 유지 | |
| `arc_after_scam` | 끝·표기 | 선택1 "잃은 건 잃은 거다. 남은 게 있다. 그걸로 다시 시작하면 된다."(R2, 현재형)를 행동으로 바꾼다. |
| `arc_midpoint_reckoning` | **결과 재작성** | 본문은 좋다. 결과 셋이 모두 격언이다("이제부터가 진짜다", "버티는 사람이 남는 게임이기도 하다", "빠른 것보다 올바른 게 낫다고 배웠다"). 라벨의 행동(다른 창을 연다, 핸드폰을 내려놓는다, 백지를 꺼낸다)이 결과에 없다. 라벨의 행동을 결과의 첫 비트로 쓴다. |
| `arc_sangchul_known_reflex` | 유지 | "편해졌다는 게 — 가장 무서운 부분이었다"는 남긴다. |
| `arc_y3_ledger_grind` | 유지 | |
| `arc_y3_ledger_kept` | 끝 | 선택1 "느린 게 지는 건 아니라고, 처음으로 믿어졌다."를 지운다. `arc_35_orthodox_weight`와 같은 문장이다. |
| `arc_year_two_half` | **결과 재작성** | 결과 둘이 격언이다("그걸로 됐다", "지쳐있는 상태로 하는 결정은 틀리기 쉽다. 잠깐 쉬어야 한다"). 라벨에 "2년 반 전의 민준"이 문자열로 들어 있어 ORDER-399와 맞춘다. |

### 배치 3 — M32~M36

| 장면 | 판정 | 지시 |
|---|---|---|
| `arc_father_06_confession` (T1) | F5·반복 | 선택1의 "임. 상. 철."은 `arc_sangchul_deduction_decision` 선택1에도 똑같이 있다. 플레이어는 두 장면을 모두 볼 수 있으므로 한쪽만 남긴다. |
| `arc_jaehyuk_04c_stand_up` | 끝 | 선택1 "이건 비싼 수업료였다. 근데 수업료를 냈으면 뭔가는 배워야 했다."(R2)를 지운다. |
| `arc_jaehyuk_sangchul_echo` | F1 | 나머지는 기준 장면이다. |
| `arc_job_vs_invest` | 예고 | 본문 끝 "이 두 가지를 동시에 하는 게 — 가능한 걸까."를 지운다. |
| `arc_sangchul_deduction`·`_case`·`_career`·`_decision` | 유지(F5) | `_career` 선택 끝 "이제 남은 선택은 더 찾을지, 여기서 멈출지였다."(R3)를 지운다. |
| `arc_sangchul_jiyeon_reveal` | 유지 | 순서는 스케줄상 `arc_jiyeon_father_records` 앞으로 보장된다(`t >= 124`, father_records는 reveal 이후). |
| `arc_sangchul_buried_silence`, `_stairwell`, `arc_y3_sangchul_deeper_room` | 유지(도덕 표 1곳) | |
| `arc_y3_cost_of_knowing` | 도덕 표 | 선택3 끝 "…지킬 책임도 함께 생겼다"(R1)도 지운다. |
| `arc_y3_hyunsu_verdict` | F2 | 나머지는 유지한다. "세상이 끝난 사람은 커피를 마시지 않는다"는 남긴다. |
| `arc_minjun_first_call` | 유지 | 2장 진단(ORDER-394)의 `employment` 계약만 따른다. |
| `arc_year3_close` (T1 챕터 마감) | **본문·변형 끝 정리** | 결과 셋은 기준 장면이다(갈비뼈에 닿는 봉투 모서리). 본문이 주제를 해설하고("좋은 사람과 나쁜 사람 … 같은 얼굴 안에서 갈라지지 않았다", "모를 때는 선택이 쉬웠다 …") 선택지를 예고한다("…둘지, … 볼지 정해야 했다"). 변형 여섯 개의 끝도 모두 주제문이다("상철처럼 이기지 않는 법을 찾는 시간", "그를 이기는 방식까지 그에게 배우지 않는 일", "같은 방향으로 갈지, 같은 사람으로 갈지", "모른 척하는 것과 모르는 것은 이제 같은 말이 아니었다"). **주제문은 장 전체에서 한 번만 쓴다.** `sangchul_truth_known` 변형의 문장 하나만 남기고, 나머지는 한강의 물빛과 흐린 서명 같은 이미지로 닫는다. |

## 반복 문구 (장을 넘어)

이 문구들은 한 번만 남긴다.

- "거울 보기가 부끄럽지 않았다": `arc_jaehyuk_aftermath`, `arc_jaehyuk_04b_counter`. 둘 다 지운다.
- "느린 게 지는 건 아니다": `arc_35_orthodox_weight`, `arc_y3_ledger_kept`.
- "임. 상. 철.": `arc_father_06_confession`, `arc_sangchul_deduction_decision`.
- "어렵게 어렵게": `arc_jiyeon_03b_lunch`, `arc_jaehyuk_hyunsu_warning`.

## 규모

- 재작성은 6장면이다: `jiyeon_father_records`, `year_two_pressure`, `35_orthodox_weight`, `35_unorthodox_weight`, `midpoint_reckoning` 결과, `year_two_half` 결과.
- 도덕 해설 삭제는 6곳, 끝 문장·예고 삭제는 약 20곳이다.
- 사실 결함은 6건이다.
- 나머지 약 30장면은 유지한다.
