# Active Queue Spec: ORDER-48

> Canonical status is indexed in `docs/CODEX_QUEUE.md`. 근거 원장은
> [`docs/SCRIPT_REVIEW_2026-07-24.md`](../SCRIPT_REVIEW_2026-07-24.md).
> 명장면 루브릭 §8은 [`docs/ROMANCE_SYSTEM.md`](../ROMANCE_SYSTEM.md).

#### [~] ORDER-48 [P1·정점 산문 밀도] 밀도 역전 수리 — 유혹은 체인, 상실·확정은 세 문장

> **2026-07-25 착수 — 만지는 파일**
>
> - 로맨스 경첩: `content/events/{arc_daeun,arc_daeun_married}.json` 및
>   같은 이름의 `content/events_en/` 오버레이
> - 엔딩 산문: `content/endings.json`, `content/endings_en.json`
> - 회귀 계약: `tools/ending_distinctness_audit.py`, `tools/ScreenshotQA.gd`
> - 판정·기록: `docs/ENDING_AUDIT.md`,
>   `docs/SCRIPT_REVIEW_2026-07-24.md`, `CLAUDE.md`, `docs/WORK_LOG.md`,
>   이 활성 사양과 큐 인덱스
>
> 이미지·효과 수치·플래그 생산·엔딩 라우팅은 변경하지 않는다.

## 진단

각본 리뷰가 반복 확인한 패턴: **경첩 장면일수록 산문이 얇다.** 조기 연애 확정·이혼
상실이 결과 텍스트 한두 문단으로 압축되고, 극악 난이도 엔딩과 자산 결산 6종이 무변주·
동일 템플릿이다. §8 "정점은 두세 문장으로 처리 금지" 위반이 아크 경첩에서 발생한다.
신규 사건 금지 — 기존 문장의 시간 늘리기·박자 벌리기·dik 재연결·본문 중복 축약만.

## 수리 항목

### 로맨스 경첩 압축 해소 — medium
1. **`arc_daeun_04b_future` choice[3]** — 다은 연애 확정(`daeun_romance_started` 탄생점)이
   "웃다가, 울다가 했다. 둘은 연인이 됐다" 요약체. 본문에 이미 있는 계산기 불빛·눈이
   커지는 비트를 결과 텍스트에서 박자 단위로 늘리고 "웃다가 울다가"를 지문(붉어진 눈가·
   멈춘 손)으로 교체.
2. **`arc_daeun_final_choice_decision` choice[1]**(이혼) — 유혹은 3링크 체인인데 발각·담판·
   이혼이 세 문장. 도장 반환 비트와 "…언제부터 나를 서류로 봤어요?" 대사를 박자 단위로
   벌리고 "울지 않은 이유" 문장을 담판 정점으로 이동. 신규 장면 불요.

### 엔딩 밀도 역전 — medium
3. **`gangnam_dream_white`(S+ 진엔딩)** — 전체에서 가장 얇은 산문(무인물·무장면·dik 0)으로
   보상 곡선 역전. 일반 `gangnam_dream`의 기존 코다(`promise_reaffirmed`·
   `sangchul_quietly_distanced` 등 White 경로와 정합하는 문단)를 dik 키로 재연결해
   최소한 아버지·상철 실을 회수.
4. **자산 결산 6종**(`stable_success`·`orthodox_pinnacle`·`investment_master`·
   `unorthodox_legend`·`balanced_life`·`early_retirement`) — "숫자→강남은 못 갔다→그래도
   교훈" 동일 골격 + '본문 전체 복붙 + 말미 코다' dik 구조. 코다형 dik의 본문 중복 단락을
   절반으로 축약해 코다 비중을 키우고, 겹치는 수사("어쩌면 이게 진짜 꿈이었는지 모른다"류)를
   각 엔딩 고유 이미지로 교차 재배치.
5. **`gangnam_dream` dik[daeun_married] 허위 무결 주장** — crossed_line으로도 이 엔딩에
   도달 가능한데 "누구도 밟지 않고"라고 단언. "그녀를 서류로 쓰지 않고"로 관계 한정하거나
   crossed_line 인지 변주 키를 기존 코다 재배치로 연결.

### 무변주 엔딩 회수 결핍 — low/medium
6. **무변주 11종 중 핵심 결말**(`empty_house` 아버지 별세인데 화해·진실 무반영,
   `career_burnout`·`mental_break` 5년 원인 무회수 등) — 기존 dik 키 여유가 있으면
   최소 아버지/상철/로맨스 실 하나씩 회수하는 코다를 기존 문장 재배치로 연결. 커버리지는
   `python3 tools/en_coverage_check.py`의 엔딩 dik 패리티로 관리.

### 초기 파일 문체 정렬 — low
7. **`arc_daeun_01_meet` 등 초기 arc_daeun.json** — 선택지 괄호 메타 라벨("(인연 시작 /
   용기·약간의 거리)")이 감정 결과 사전 누설 + 후기 파일 문체 불일치. 괄호부 삭제만으로
   통일(효과는 flags/effects로 이미 구분, inert 아님).

## 검증

- `GODOT=<경로> ./tools/audit.sh` → "✅ 감사 통과"
- `python3 tools/en_coverage_check.py`(엔딩 dik 35/35 패리티 유지)
- 수리한 정점(다은 04b·final_choice, gangnam_dream_white)을 1280x800 실렌더해 §8
  6요소(감각·시간 늘리기·절제·여운) 충족을 육안 확인.
