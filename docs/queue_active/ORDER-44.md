# Active Queue Spec: ORDER-44

> Canonical status is indexed in `docs/CODEX_QUEUE.md`. 근거 원장은
> [`docs/SCRIPT_REVIEW_2026-07-24.md`](../SCRIPT_REVIEW_2026-07-24.md).

#### [ ] ORDER-44 [P0·정합 위생] 외부 테스트 오염 방지 — 죽은 인물·오기·도달불가·시제 확정 수리

## 왜 P0인가

전부 **플레이로 도달하는 확정 오류**다(각본 리뷰 적대 검증 통과분 포함). 외부 정상
독해 표본을 받기 전에 닫아야 한다 — 죽은 아버지가 초인종을 누르거나 미스터리 단서
성씨가 틀리면 테스터의 신뢰가 첫 장면에서 깨진다. 신규 콘텐츠 금지, 문장 수리·
플래그 연결·조건 배선만으로 전부 해결 가능하다.

## 수리 항목 (근거는 SCRIPT_REVIEW 해당 event_id 참조)

### A. 죽은 인물 재등장 (코드 가드 누락)
1. **`gangnam_dream` 엔딩** — `father_passed` 런에도 "초인종이 울린다. 아버지다"가
   발화. `GameState.check_game_over` 30억 분기에 `father_passed` 가드를 추가해
   기존 `empty_house`로 라우팅(같은 캐스케이드 `sangchul_reckoning`의 기존 가드 패턴 복제).
2. **`late_call` 엔딩** — 라우팅이 `father_reconciled`만 보고 `father_passed`를 안 봐
   죽은 아버지와 국밥 통화. 조건에 `and not flags.get("father_passed")` 추가(2587 패턴 복제).
3. **`father_missed_chance`·`rel_father_silent`·`father_health_call`·`father_first_visit`·
   `father_reconcile`·`father_hospital_wait`·`father_old_photo` + 아버지 전화 콜백
   (`callback_father_going_soon_echo`, `callback_delayed_visiting_dad_consequence` 등)** —
   conditions에 `no_flag: father_passed`를 일괄 배선(아크 쪽엔 이미 같은 가드가 있음).

### B. 인물 정보 오염 (오기)
4. **`callback_sangchul_jiyeon_connection`** — "이지연씨" → "**한지연씨**". 성 '한'이
   한PD건설 미스터리 단서라 오기는 반전 정보 자체를 오염(전 콘텐츠 유일 1건).
5. **`callback_events_7`의 재혁 콜백 3건**(`felt_kindness_echo`,`stood_up_aftermath`,
   `refused_news`) — "이재혁" → "**최재혁**"(정본 15곳 최재혁).

### C. 인물 궤적 모순
6. **현수 요리↔회계 충돌** — `arc_hyunsu_new_path`(조리학원·주방)가 신규 런 정본인데
   t70+ `hyunsu_reunion_later`는 "회계법인 취직". new_path/drift의 '조리학원·주방'
   문장을 fallback `hyunsu_pivot`의 회계 재시작 산문으로 정렬하거나 reunion 본문을
   직업 무관 표현으로 수리. 회계 설정은 구세이브 fallback 전용임에 유의.
7. **`arc_y3_hyunsu_verdict`** — t133에 "최종 면접 탈락, 3년의 끝"이 이미 끝난 t25
   공시 결과와 t60 취직을 부정. 트리거에 `no_flag hyunsu_pivoted`(또는 `hyunsu_reconnected`)
   연결 + 잔존 경로 "3년"→"4년"·"5년째"→"3년째" 숫자 정렬 + 유일 반말 대사 존댓말화.

### D. 도달 불가 콘텐츠 (배선 오류)
8. **다은 `arc_daeun_money_gap`(t28~35)·`arc_daeun_trace`(t43~50)** — 트리거 창이 원인
   플래그(`daeun_chose_her` t≥58, `ghost_seen` t≥72)보다 앞서 영구 사문. 창을
   `money_gap` t60~70, `trace` t76~84로 이동.
9. **`gangnam_dream` dik[startup_exit]** — `check_game_over`가 startup_exit를 30억보다
   먼저 판정해 이 dik 문단은 발화 불가. 해당 문단을 `startup_exit` 엔딩 dik로 이식하고
   gangnam_dream 쪽 키 제거.
10. **상철 진실 증발** — 대면(`sangchul_truth_known` 필수)이 추론 스탯 게이트(지력55+/
    비정통20+ · t104~124)와 아버지 고백(`visited_father` 등) 둘 다 놓치면 통째로 소진.
    추론 창 상한(t124) 제거 또는 아버지 고백 의존을 t상한 도달 시 완화하는 폴백 조건 추가.
11. **`arc_sangchul_ng_meet`** — NG+ '모른 척' 분기가 `sangchul_truth_known`을 안 세워
    재독자 dik가 잠들고 추론 씬이 '첫 발견'을 주장. choice[0]에 `sangchul_truth_known`
    추가 또는 추론 트리거에 `no_flag ng_playing_sangchul`.
12. **`sangchul_meet` 랜덤 경합** — 가중치 10 랜덤 조우가 정본 첫 만남(커피잔 반 박자)을
    선점·중복. `arc_sangchul_01_answer`에 `sangchul_met` 플래그 추가 + `sangchul_meet`
    조건에 `no_flag arc_sangchul_met_seen`으로 상호 배타화.

### E. 시제·수치 정렬 (사실 오류)
13. **보증 사기 연대 "십수 년"↔"6년" 계열 어긋남** — 프롤로그 정본은 27세·6년 전.
    `arc_drama`·`arc_web_crossbeams`·`arc_jiyeon_married`·`arc_year_close`·
    `arc_sangchul_deduction_case`·`reckoning`의 "십수 년" 5~6곳을 "십 년 가까이"/"그 시절"
    계열로, `deduction_decision`·`arc_father_06`의 "몇 년 전"을 그와 통일.
14. **`arc_job_first_rejection`** — "6개월 공백" → "**6년 공백**"(KR·EN 동시).
15. **`arc_gangnam_visit_alone`** — 존재하지 않는 "임상철 씨 차에서 본 강남" 회상.
    실제 겪은 장면(정류장 광고판 "당신의 자리가 되는 도시" 또는 cafe_00)으로 교체 또는 삭제.
16. **`arc_final_stretch`** — "5년 전" 하드코딩(t47+ 발화 시 거짓). 상대 시제("처음 서울에
    온 해")로 수리. 창은 손대지 않음.
17. **`orthodox_hollow` 엔딩** — "55세에 통장을 열었다"(폐기된 55세 마감 잔재). "서른여덟에"로
    수리, `ordinary_life`·`stable_success`·`healthy_retirement` condition의 "age >= 55" 3곳도 정렬.
18. **`gangnam_dream` dik[jiyeon_romance_started] 오발화** — `jiyeon_left` 상태에서 "한지연과
    함께" 변주가 첫 매치 dik 선택기로 오발화. `_resolved_ending_description`에 부정 가드
    (jiyeon 키는 `jiyeon_left` 시 스킵) 또는 finish_run 직전 '함께 상태' 파생 플래그로 키 교체.

## 검증

- `GODOT=<경로> ./tools/audit.sh` → "✅ 감사 통과"
- `python3 tools/english_hangul_audit.py` (EN 오버레이 동시 수리분 커버리지)
- `python3 tools/arc_flow_sim.py` (아크 트리거·조건 변경분)
- 대표 런 실입력으로 ①father_passed 런의 엔딩이 empty_house로 라우팅 ②sangchul 첫
  만남 단일 발화 ③현수 궤적 단일화를 확인. 완료 시 SCRIPT_REVIEW 항목에 수리 표시.
