# Active Queue Spec: ORDER-47

> Canonical status is indexed in `docs/CODEX_QUEUE.md`. 근거 원장은
> [`docs/SCRIPT_REVIEW_2026-07-24.md`](../SCRIPT_REVIEW_2026-07-24.md) 「챕터 구조 판정」·「240주 편성」.
> 편성 정본은 `content/meta/event_director.json`, 장면 스파인은 `content/meta/narrative_spine.json`.

#### [~] ORDER-47 [P1·편성/구조] 장 결산·환불선 밀도·중반 반복·4장 함몰·4→5 중복

> **2026-07-25 착수 — 만지는 파일**
>
> - 편성 정본: `content/meta/event_director.json`,
>   `content/meta/narrative_spine.json`
> - 사건: `content/events/{arc_year_close,arc_midgame,arc_chapter_themes,life_events}.json`
>   및 같은 이름의 `content/events_en/` 오버레이
> - 사건 창·편성 런타임: `scenes/MainGame.gd`
> - 구조 회귀: `tools/{event_director_audit,full_run_pacing_audit,narrative_continuity_audit,narrative_spine_audit,arc_flow_sim}.py`
>   중 새 구조 계약에 필요한 파일
> - 수치·기록: `docs/BALANCE.md`, `docs/SCRIPT_REVIEW_2026-07-24.md`,
>   `CLAUDE.md`, `docs/WORK_LOG.md`, 이 활성 사양과 큐 인덱스

## 진단

5장 스파인과 장 경계 3→4(구분·연속 5/5)는 견고하나, 각본 리뷰가 **네 구조 약점**을
확정했다: ①1장 보스가 최약(2시간 환불선 정점이 빈다) ②환불선 t25~48 보장 밀도 절벽
③중반 '계산기/장부 독백' 6~7회 연속 ④4장 함몰(앵커로 가림)·4→5 '1년 남았다' 3연속.
신규 콘텐츠 금지 — 창 게이트 재배치·결어 문장 차별화·dik 재연결·결산 result_text 보강만.

## 수리 항목

### 1장 보스 결산 보강 — high
1. **`arc_year1_close`** — 131자·한 줄 결과로 다섯 결산 중 최약, 장 간판 베팅(대포통장)을
   dik로 호명 안 함. 기존 `arc_chapter1_close`("여기서 30억이 나올 수 있는가")·
   `arc_four_months_in`의 한강 감각 문장을 본문·result_text로 **재배치**하고, 기존 플래그
   `kept_clean_hands`/`fell_to_darkness`/`escaped_dirty_money`를 dik로 연결해 대포통장
   선택을 결산에서 호명. 결과문 3종을 `year1_resolve`/`year1_numb` 독자 경로로 차등.
   부수: 조건의 `month [12]`가 스케줄러 창(t44~48)과 어긋나는 죽은 데이터이면 정리.

### 환불선 t25~48 밀도 절벽 — high
2. **`event_director.json:full_run_pacing`** — decision_weeks가 t48까지 [29,37,44] 3회뿐,
   echo_weeks 첫 항목이 t51이라 t25~50 Echo 0. **편성표만 수리**: echo_weeks에 t33 부근
   1회 추가(현수 시험 결과 t25 확정의 여파 회수), decision 29/37 사이에 기존 sangchul_02
   (t28)·jiyeon_02(t34) 창과 정렬된 주 1개 이동 배치.

### 중반 계산장면 6~7연속 — high
3. **`arc_goal_vertigo` 구간(t121~148)** — `arc_midpoint_reckoning`→`year_two_half`→
   `goal_vertigo`→`arc_35_path_cost`→`arc_35_habit_check`→`year3_close`→`arc_36_reality_check`가
   같은 '혼자 계산기/장부' 문법으로 적층. **창 재배치**: `arc_35_path_cost` 창(t135~144)을
   t148+로 밀거나 Echo 회수로 강등, `arc_36_reality_check` 창을 t150~158로 늦춰 year3_close
   와의 연속 계산 장면을 끊음.

### 2장 시간 마커 결어 중복 — medium
4. **`arc_34_two_years_in`** — `year_one_mark`/`year_one_half`/`34_two_years_in`이 같은
   "버텼다" 결어 반복(year1_close·story_six_months 포함 t24~100에 4회). temporal spine
   `second_year_becomes_home`이 이미 셋을 한 축으로 선언했으므로 가운데 마커
   (`year_one_half`) 결어를 '몸에 밴 도시의 습관' 쪽 기존 문장으로 교체, "버텼다"는 year1_close만.
5. **`arc_year_two_pressure`** — SNS/동창 비교가 같은 창의 `arc_social_comparison`과
   주제·창 중복. 창 분리(social t92~104, pressure t105~115) 또는 무직/재직 상호배타 게이트.

### 4장 함몰 — medium
6. **4장 30뿌리 함몰** — `arc_year_three_half`가 주석에 "t168-188 공백 구간 앵커(무조건)"로
   자백된 구멍 메우기, `arc_36_night_doubt`도 같은 창 덧댐. **재배치**: 창이 넓은 3장 후반
   이벤트를 t160~185 공백대로 이동 조정, `chapter_break_turn45`(t180~188)가 `arc_year4_close`
   (t188~192)와 겹쳐 회고 연속 발화하는 창 경계를 t176~184로 좁힘.

### 4→5 '1년 남았다' 3연속 + 5장 구포맷 스텁 — medium
7. **`arc_final_year_start`** — `arc_year4_close`"1년 남았다"→`arc_37_reckoning`→
   `arc_final_year_start`"이제 1년이 남았다"가 3연속. + 이 이벤트는 구포맷(category
   "social", 1~2문장 result_text)이라 밀도 단차. description을 "정산 다음 날" 시점으로
   수리해 '1년 선언' 중복 제거하고, reckoning follow_up으로 유지하되 각 선택 result_text
   마지막 문장을 이 본문 서두로 이월해 한 호흡으로 병합.
8. **`arc_37_burn_or_light`** — 고자산 런에서 t194~209 무조건 비트 공백(`arc_late_game_push`가
   28억 미만 게이트). 시작 턴을 t204 부근으로 당기거나 기존 `arc_final_stretch`/
   `arc_gangnam_real_estate` 미발화분이 이 창에서 회수되도록 게이트 상한 조정.

### 2·4장 결산 밀도 — medium
9. **`arc_year2_close`·`arc_year4_close`** — 무드 선택+한 줄 결과로 장 카드 밀도를 못 받침.
   dik가 이미 풍부(각 5~6개)하므로 기본 description을 늘리지 말고, 무플래그 런에서도
   보편 dik 키(`year1_resolve`/`year3_weighted` 계열)가 기본 본문을 대체하도록 키 순서 재배치.

## 검증

- `GODOT=<경로> ./tools/audit.sh` → "✅ 감사 통과"
- `python3 tools/arc_flow_sim.py`(창·조건 변경분 잼 확인)
- 편성 변경은 대표 A/B 경로 실입력으로 t25~48 보장 밀도 상승·중반 계산장면 연속 해소·
  4→5 '1년 남았다' 단일화를 재측정. 밸런스 밴드 영향분은 `docs/BALANCE.md` 기록.
