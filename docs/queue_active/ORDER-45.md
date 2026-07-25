# Active Queue Spec: ORDER-45

> Canonical status is indexed in `docs/CODEX_QUEUE.md`. 근거 원장은
> [`docs/SCRIPT_REVIEW_2026-07-24.md`](../SCRIPT_REVIEW_2026-07-24.md).
> 호칭/스피치 정본은 [`docs/ROMANCE_SYSTEM.md`](../ROMANCE_SYSTEM.md)가 소유한다.

#### [~] ORDER-45 [P0·정본 집행] 호칭·스피치 정본 붕괴 전수 수리

> **2026-07-25 착수 — 만지는 파일**
>
> - 정본: `docs/ROMANCE_SYSTEM.md`
> - 지연: `content/events/arc_events.json`, `callback_events_24.json`,
>   `arc_romance_y5.json`, `relationship_events.json`,
>   `arc_jiyeon_married.json`, `arc_romance_specials.json`,
>   `callback_events_23.json`
> - 다은: `content/events/arc_events.json`, `callback_events_18.json`,
>   `arc_daeun_extension.json`, `arc_daeun_married.json`,
>   `arc_midgame.json`, `callback_events_44.json`
> - 상철: `content/events/callback_events_12.json`,
>   `content/events/callback_events_17.json`
> - 회귀·기록: `tools/speech_register_audit.py`, `tools/audit.sh`,
>   `docs/SCRIPT_REVIEW_2026-07-24.md`, `CLAUDE.md`, `docs/WORK_LOG.md`,
>   이 활성 사양과 큐 인덱스

## 정본 (어겨진 규칙)

- 다은→민준: **"민준씨" + 존댓말** 고정(관계 단계 무관, 진심·따뜻).
- 지연→민준: 연애 확정 **전** 존댓말, 확정 **후** "오빠" + 반말.
- 민준은 두 여성·멘토 상철에게 **존댓말 기조**.

리뷰 결과 이 정본이 여러 스레드에서 산발적으로 무너져 있고, 특히 지연 `year5_return`이
공들여 연출한 '첫 반말' 비트가 앞선 반말 위반들로 무효화된다. 전부 **문장 수리(어미
교정)** 범위. 효과·플래그·ID·조건 불변. EN 오버레이는 로마자 호칭이라 대개 무영향이나
KR 수리 시 함께 점검.

## 수리 항목

### 지연 (연애 확정 전 반말 / 확정 후 존댓말 혼재)
1. **`arc_opp_jiyeon_bunyang`** — 연애 확정 훨씬 전(t45+)에 전면 반말·"너"("너한테만
   말하는 거야", "몰라서 물어?"), 민준도 반말("왜 나한테 이걸 줘?"). 인접 offer/truth/lose가
   전부 존댓말이므로 이 이벤트 대사만 존댓말화("오빠한테만 말하는 거예요" 계열).
2. **`callback_jiyeon_took_money_echo`** — transaction 단계(t19+) 반말. 쌍둥이
   `callback_jiyeon_took_money_weight`는 존댓말이므로 그쪽에 맞춰 존댓말화.
3. **`arc_jiyeon_y5_feelings`** — `jiyeon_romance_started`가 이 이벤트로 비로소 서는데
   도입 문자가 이미 반말. 도입을 존댓말로("이번 달에 서울 올라와요. 보고 싶으면 연락해요.").
4. **`jiyeon_world_gap`·`jiyeon_mother`·`jiyeon_gangnam_moment`** vs
   `callback_jiyeon_together_echo` — 같은 `jiyeon_together` 상태의 어투가 이벤트마다
   갈림. **확정 후 반말**이 정본이므로 존댓말 쪽(world_gap/mother/gangnam_moment)을
   반말로 통일(확정 후 연출 의도와 일치).
5. **`arc_jiyeon_verdict_decision`** — 같은 노드에서 민준 어투가 선택지마다 반전(선택0
   반말/선택1 존댓말). 존댓말 기조로 통일. `arc_jiyeon_narrow_room_2`·`wedding_night`의
   민준 반말도 존댓말화.
6. **`callback_jiyeon_gangnam_called_echo`** — 원 장면은 존댓말인데 콜백 민준 "됐어"
   반말. 원 장면에 맞춰 존댓말화.

### 다은 (존댓말 고정 위반)
7. **`arc_daeun_later_echo`** — 다은 "나도 여기 있어"(반말), 민준 "거의 다 왔어"(반말).
   둘 다 존댓말화.
8. **`callback_daeun_understood_echo`**(callback_events_18) — 다은 "너한테만 하는 말이야",
   "같이 할 수 있을 줄 몰랐어" → "민준씨한테만 하는 말이에요", "…몰랐어요".
9. **`arc_daeun_year5_ending`** — 민준 "같이 온 거야. 너 아니었으면…"(반말·"너"). 존댓말화.
10. **`arc_daeun_year3_together`**·**`arc_daeun_final_choice_name`**("다은아") — 민준 반말.
    같은 시기 프로포즈·첫날밤이 존댓말이므로 레지스터 왕복 제거(존댓말 통일).
11. **(도달 불가지만 ORDER-44 수리 시 동시 교정)** `arc_daeun_money_gap` 다은 대사 전면 반말.

### 민준→상철·현수 (존댓말 기조 위반)
12. **`callback_events_12/17`의 상철 경고 콜백 4건**(`dismissed`,`heeded`,`deal_regret`,
    `took_tip`) — 52세 멘토에게 반말("네 말이 맞았어" 등). 해요체로("말씀이 맞았어요" 등).
13. **`arc_y3_hyunsu_verdict`의 현수 유일 반말 대사** — 존댓말화(ORDER-44 항목7과 동일
    이벤트, 함께 처리).

## 검증

- `GODOT=<경로> ./tools/audit.sh` → "✅ 감사 통과"
- `python3 tools/english_hangul_audit.py`
- 지연 `year5_return` 경로를 실렌더해 '첫 반말' 비트가 앞선 위반 제거로 실제 첫 반말이
  되는지 육안 확인. 다은 정점(프로포즈·결혼·최종선택) 존댓말 일관성 확인.
