# 강남드림 — 현재 상태

> **자동 생성 문서다. 손으로 고치지 않는다** — 다음 생성에서 지워진다.
> 값을 바꾸려면 이 파일이 아니라 원본(큐 표·정본 JSON·콘텐츠)을 고친다.
>
> 재생성: `python3 tools/project_dashboard.py --md docs/STATUS.md`
> 전 구간 선택 그래프를 대화형으로 보려면:
> `python3 tools/project_dashboard.py` → `build/project_dashboard.html`
>
> 생성 시각 · 커밋: `2026-07-31 11:12 UTC · 7382ebef`

**개발용이다.** 아래는 `tint`·`route_*`와 정확한 수치를 그대로 적는다.
플레이어에게 노출하지 않는 값이므로 이 문서를 플레이어 대상 자료로 쓰지 않는다.

## 한눈에

| 지표 | 값 | 뜻 |
|---|---:|---|
| 사건 | 1,581 | KR 이벤트 전체 |
| 선택 2+ 사건 | 1,484 | 판정 대상 |
| 체인(장면) | 65 | 2비트 이상 |
| 연출 보유 사건 | 100 | 전체의 6% |
| 정답 선택 | 414 | 선택 2+ 사건의 27% |
| 테마 우회 | 2,116 | UIStyle 밖 override |
| 수동 스타일 | 260 | StyleBoxFlat 직접 생성 |
| 테마 리소스 | 0 | 늘어야 하는 지표 |
| 팔레트 밖 색 | 678 | 정본 12색 대비 |
| 진입점 없는 스크립트 | 2 | 래칫 |
| 서명 알려진 결함 | 5 | 악화만 실패 |
| 1비트·무연출 사건 | 53 | 밀도 하한 미달 |

## 오더

정본은 [`CODEX_QUEUE.md`](CODEX_QUEUE.md)의 활성 인덱스이고 여기는 그 사본이다.

| ID | 제목 | 상태 | 현재 게이트 |
|---|---|---|---|
| `ORDER-57` | Core Loop V2 데모 재구축 | 진행 | D 1~20주 AUTO PASS. E 밀도 REWORK·생계 백필을 month 6보다 먼저 확정(미확정 시 재작업). +direction 백필 43건(ORDER-60 판정). 이어서 21~24주 첫 청구서·6개월 회고·시작폰 세대감. 전환·사람 GO OPEN |
| `ORDER-60` | 프롤로그부터 전면 재검토 | 진행 | 배치 1·2 완료(·), P0 0건. 3~7은 데모 출고 뒤 |
| `ORDER-62` | 기능 생존·킬링포인트 감사 | 미착수 | 기계 축 완료(Claude) — 고아 스크립트 래칫(feature_liveness_audit). 남은 것은 네 판정·킬링포인트 전수 판정, 제거는 사용자 승인 뒤 |
| `ORDER-61` | 정본 공백 (심의·접근성·저장·성능·오디오·리스크) | 미착수 | 미착수. 배치 1(등급·심의)이 P0 — 도박 4종 5,496줄에 GRAC·Steam 언급이 정본 0개. 등급은 사용자 결정. 나머지 다섯은 독립 |
| `ORDER-59` | 정합 기반 (지식 원장·다은 phase·규칙 화계) | 미착수 | 미착수. 대화량을 늘리기 전에 선행한다 — 화자도 지식도 표현할 자리가 없고 다은 phase가 typed fact가 아니다. 신규 장면에만 필수, 기존 1,581건은 래칫 |
| `ORDER-58` | 데모 평가 후속 | 미착수 | 미착수. 축 대칭·유혹 밀도·선택지 중립. ORDER-57 E 뒤, 영어 유혹 선택지 수리만 선행 가능. 구현보다 정본 배치를 먼저. 장르·스토어 약속은 사용자 결정 대기 |
| `ORDER-67` | `.gd` 분해 (한 파일이 전부인 상태) | 미착수 | 미착수. ORDER-57 E 뒤, ORDER-63 배치 3 앞. MainGame.gd 19,984줄=전체 21%, 함수 688·signal 0. 테마 override 645건(27%)이 여기 있어 배치 3을 막는다. 첫 칼은 미접촉 316함수 7,267줄 |
| `ORDER-63` | 표면 단일 언어 (UI·폰트·테마) | 미착수 | 배치 1·2 완료(Claude) — 계측기(surface_coherence_audit)·물성 정본(SURFACE_MATERIAL). 배치 3(테마 단일 출처)이 화면을 바꾼다. 데모 화면만 |
| `ORDER-64` | 서명·연속성 강제 | 미착수 | 배치 1·2 완료(Claude) — 서명표를 identity_signature.json으로 승격·배선. 알려진 결함 5건은 래칫. 배치 3~7(모티프·음색·채택률·연속성) 미착수 |
| `ORDER-65` | 장이 닫는 것을 실제로 닫는다 | 미착수 | 데모 출고 뒤. narrative_spine이 장마다 닫는 동사를 선언하는데 구현이 0 — 3장이 시간 팔기를 닫는다면서 JobSystem에 장 게이팅이 없다. 소비자 없는 정본 |
| `ORDER-66` | 제품 패키징 (크레딧·버전·고지) | 미착수 | 미착수. 빠진 것 셋 — 엔딩 크레딧·게임 버전 문자열·게임 내 제3자 고지. 폰트 OFL 사본과 빌드 포함은 선수리 완료. Steam SDK는 심의 뒤 별도 |
| `ORDER-43` | 실제 녹음/샘플 오디오 REWORK | 진행 | 장별 사람 연속 청취 |
| `USER-P0N` | 데모 장면 연출 문법 240주 전 구간 확산 | 진행 | 정상 속도·실기기·A/V 사람 판정 |
| `ORDER-21` | 일본어 번역 웨이브 | 진행 | 데모 GO 뒤 본문 번역·15장 캡처·원어민 검수 |
| `ORDER-23` | 동기 각인 수술 | 진행 | 동기 문장 기억 여부 사람 판정 |
| `ORDER-22` | 주간 루프 몰입 수리 | 진행 | 정상 속도 몰입·재미 사람 판정 |
| `ORDER-28` | 240주 전체 재구성 | 진행 | 외부 정상 독해 10인 플레이 0/10 |
| `ORDER-26` | AP 의미화 | 진행 | 망설임·전략 재미 사람 판정 |

## 다섯 장 — 무엇을 열고 무엇을 닫는가

장마다 동사를 하나 열고 이전 동사를 하나 닫는다.
닫히는 쪽이 이 작품이 인접작과 갈라지는 지점이다.

### 1장 · 남은 사람 <sub>1–48주</sub>

> 정직하게 살아서는 닿을 수 없는 목표 앞에서 민준은 첫 선을 넘는가?

- **연다** — 시간을 판다 — 알바·지원·공부의 기본 동사 세트
- **닫는다** — (1장은 열기만 한다)
- **압력** — 이번 달 생존
- **실패** — 이번 달을 넘기지 못한다

### 2장 · 문을 여는 값 <sub>49–96주</sub>

> 기회가 사람의 얼굴로 올 때 민준은 호의와 거래를 구분할 수 있는가?

- **연다** — 사람이 기회를 가져온다 — 혼자서는 찾을 수 없는 기회가 소개로만 온다
- **닫는다** — 혼자 버는 것으로는 따라가지 못한다. 시간당 노동의 천장이 보인다
- **압력** — 관계 유지비 — 사람을 통해 오는 기회는 사람에게 쓸 시간을 요구한다
- **실패** — 유지비를 내지 못해 문이 열리지 않는다

### 3장 · 같은 손 <sub>97–144주</sub>

> 상처의 진실을 알게 된 민준은 가해자를 심판하는가, 이용하는가, 닮아 가는가?

- **연다** — 남의 돈을 움직인다 — 레버리지·보증·타인 자본
- **닫는다** — 시간 팔기가 무의미해진다. 알바 한 주가 기회비용 이하가 되어 1장의 생존 동사가 죽는다
- **압력** — 그 수단이 아버지를 무너뜨린 것과 같다는 걸 알고도 쓰는가
- **실패** — 남의 돈에 깔린다

### 4장 · 청구서 <sub>145–192주</sub>

> 사람과 몸이 성공의 비용으로 청구될 때 민준은 무엇을 먼저 지불하는가?

- **연다** — 규모를 고른다 — 되돌리기 어려운 크기의 판
- **닫는다** — 몸과 관계가 자원에서 제약으로 바뀐다. 소모하고 회복하던 것의 상한이 내려가고, 기다려 주던 사람이 더는 기다리지 않는다
- **압력** — 대신 내 줄 사람이 없다
- **실패** — 청구서를 몸이나 사람으로 낸다

### 5장 · 이름을 적는 사람 <sub>193–240주</sub>

> 마지막 숫자 앞에서 민준은 누구의 이름과 시간을 담보로 서명하는가?

- **연다** — 서명한다 — 되돌릴 수 없는 한 번의 결정
- **닫는다** — 대부분의 문이 이미 닫혀 있다. 새 기회가 오지 않고 남은 것으로만 한다
- **압력** — 지킬 것을 지킬 수 있는가
- **실패** — 다 얻고 아무도 남지 않는다

## 주연 여섯 — 서명

팬이 인물을 알아보는 근거는 렌더 품질이 아니라 같은 소품이 매번 그 자리에
있다는 사실이다. `언급`은 자산 정본이 그 소품을 실제로 말한 횟수이며,
**0이면 소품이 선언만 되고 지켜지지 않는다는 뜻이다.**

| 인물 | 욕망과 모순 | 소유 소품 | 오디오 모티프 | 언급 |
|---|---|---|---|---:|
| **Kim Daeun**<br>`daeun` | Has little to spare but notices what other people need | Handwritten post-it and the same hair clip in every outfit | Close felt piano and soft room tone, never cute chimes | 2 |
| **Father**<br>`father` | Shame makes him withdraw from the son he is trying to protect | 23-second call screen and debt records | Bare room tone with the four-note theme missing its last note | 0 |
| **Choi Jaehyuk**<br>`jaehyuk` | His kindness may be sincere and useful at the same time | Pocha photograph with a darkened second reading | Dry finger snap or shutter transient over Minjun's motif | 0 |
| **Han Jiyeon**<br>`jiyeon` | Offers the fastest path upward while refusing to be merely a guide | Unbranded black luxury-car key and angular earring | Cool piano interval with a held unresolved note | 7 |
| **Kim Minjun**<br>`minjun` | Wants a different life without knowing what may remain of him | Folded account statement showing the starting balance, never a luxury prop at launch | Four-note theme that can clear, distort, or hollow out | 0 |
| **Im Sangchul**<br>`sangchul` | The hand offering a ladder may be the hand that built the trap | Business card with handwritten number | Low brushed rhythm and one muted brass breath | 2 |

## 데모 24주 — 번들 56개

`행동`은 결과 카드이고 `장면`만 집필된 체인을 갖는다. `미집필`은 아직 없다.

| 번들 | 형태 | 종류 | 주차 | 인물 |
|---|---|---|---|---|
| `cafe_world_glimpse` | 장면 | temptation | 6–7 |  |
| `daeun_player_return` | 장면 | pursuit | 15–16 | daeun |
| `daeun_return_after_distance` | 장면 | pursuit | 15–16 | daeun |
| `daeun_shared_dream` | 장면 | pursuit | 20–20 | daeun |
| `daeun_third_greeting` | 장면 | pursuit | 20–20 | daeun |
| `daeun_world_meet` | 장면 | encounter | 10–12 | daeun |
| `demo_collision` | 미집필 | boss |  | father |
| `father_first_call` | 장면 | care | 1–3 | father |
| `father_health_signal` | 장면 | care | 21–21 | father |
| `father_quiet_call` | 장면 | care | 9–12 | father |
| `first_temptation_boss` | 장면 | boss | 4–4 |  |
| `hyunsu_exam_eve` | 미집필 | care | 23–23 | hyunsu |
| `hyunsu_first_meet` | 장면 | encounter | 1–3 | hyunsu |
| `hyunsu_player_reachout` | 장면 | pursuit | 5–6 | hyunsu |
| `hyunsu_study_followup` | 장면 | pursuit | 9–12 | hyunsu |
| `jaehyuk_plain_reunion_echo` | 장면 | pursuit | 20–20 | jaehyuk |
| `jaehyuk_world_meet` | 장면 | encounter | 13–16 | jaehyuk |
| `jiyeon_bus_stop_reunion` | 장면 | encounter | 15–16 | jiyeon |
| `jiyeon_second_crossing` | 장면 | pursuit | 20–20 | jiyeon |
| `jiyeon_world_meet` | 장면 | encounter | 10–12 | jiyeon |
| `m1_convenience_trial_shift` | 행동 | livelihood | 1–3 |  |
| `m1_mirae_application` | 행동 | career | 1–1 |  |
| `m1_phone_off_sunday` | 행동 | recovery | 1–3 |  |
| `m1_youth_center_resume_clinic` | 행동 | growth | 1–3 |  |
| `m2_mirae_result_message` | 장면 | consequence | 5–5 |  |
| `m2_rain_delivery_shift` | 행동 | livelihood | 6–7 |  |
| `m2_seorin_application` | 행동 | career | 5–6 |  |
| `m2_sleep_debt_sunday` | 행동 | recovery | 5–8 |  |
| `m2_youth_center_mock_interview` | 행동 | growth | 7–7 |  |
| `m3_empty_saturday` | 행동 | recovery | 9–11 |  |
| `m3_hanbit_application` | 행동 | career | 9–9 |  |
| `m3_inventory_shift` | 행동 | livelihood | 9–11 |  |
| `m3_library_job_board` | 행동 | growth | 9–12 |  |
| `m3_room_ledger` | 행동 | recovery | 9–12 |  |
| `m3_seorin_result_message` | 장면 | consequence | 9–9 |  |
| `m4_certificate_session` | 행동 | growth | 13–15 |  |
| `m4_dodam_application` | 행동 | career | 13–13 |  |
| `m4_hanbit_interview` | 장면 | career | 14–14 |  |
| `m4_health_check_day` | 행동 | recovery | 13–16 |  |
| `m4_housing_welfare_consultation` | 행동 | growth | 13–16 |  |
| `m4_logistics_shift` | 행동 | livelihood | 13–15 |  |
| `m5_city_service_application` | 행동 | career | 17–17 |  |
| `m5_employment_contract_clinic` | 행동 | growth | 17–20 |  |
| `m5_evening_spreadsheet_class` | 행동 | growth | 17–20 |  |
| `m5_hanbit_offer_message` | 장면 | consequence | 17–17 |  |
| `m5_last_empty_sunday` | 행동 | recovery | 17–20 |  |
| `m5_weekend_move_shift` | 행동 | livelihood | 17–20 |  |
| `m6_holiday_night_shift` | 행동 | livelihood |  |  |
| `m6_last_study_group` | 행동 | growth |  |  |
| `m6_no_plans_day` | 행동 | recovery |  |  |
| `m6_public_recruitment` | 행동 | career |  |  |
| `opening_interview_math` | 장면 | consequence | 2–4 |  |
| `sangchul_second_coffee` | 장면 | pursuit | 20–20 | sangchul |
| `sangchul_world_meet` | 장면 | encounter | 13–14 | sangchul |
| `sns_pressure_night` | 장면 | reflection | 5–8 |  |
| `temptation_consequence` | 장면 | consequence | 8–8 |  |

## 정답 선택 414건

한 선택이 [`DEMO_TIER_AUDIT.md`](DEMO_TIER_AUDIT.md)가 고정한 축 아홉에서
모두 우월하고, 최소 한 축에서 낫고, 후속도 플래그도 갈리지 않는 자리다.
**고민이 아니라 답이 있다.** 판정은 `tools/project_dashboard.py`의
`dominant_index()`가 소유한다.

| 파일 | 건수 |
|---|---:|
| `life_events.json` | 20 |
| `callback_events_25.json` | 13 |
| `investment_events.json` | 13 |
| `callback_events_14.json` | 12 |
| `callback_events_13.json` | 11 |
| `callback_events_16.json` | 11 |
| `callback_events_17.json` | 11 |
| `callback_events_21.json` | 11 |
| `drama_events2.json` | 11 |
| `callback_events_11.json` | 10 |
| `callback_events_19.json` | 10 |
| `callback_events_20.json` | 10 |
| `callback_events_22.json` | 10 |
| `callback_events_12.json` | 9 |
| `callback_events_23.json` | 9 |

상위 15개 파일만 적는다(전체 82개 파일).

## 선택 마인드맵 — 데모 체인 28개

체인 하나가 장면 하나다([`SCENE_TIER.md`](SCENE_TIER.md) §0).
지금 짓고 있는 데모 구간만 그린다 — 전 구간 65체인은 HTML 쪽에서 본다.
`⚠︎연출없음`은 `direction` 키가 없다는 뜻이고, 그 비트는 아직 끝나지 않았다.

<details><summary><b>1+1</b> — 1비트 · 선택점 1 (<code>arc_daeun_01_meet</code>)</summary>

```mermaid
flowchart TD
  arc_daeun_01_meet["1+1 ⚠︎연출없음"]
```

</details>

<details><summary><b>전화</b> — 1비트 · 선택점 1 (<code>arc_father_01_call</code>)</summary>

```mermaid
flowchart TD
  arc_father_01_call["전화 ⚠︎연출없음"]
```

</details>

<details><summary><b>카톡 하나</b> — 1비트 · 선택점 1 (<code>arc_father_02_signal</code>)</summary>

```mermaid
flowchart TD
  arc_father_02_signal["카톡 하나 ⚠︎연출없음"]
```

</details>

<details><summary><b>일요일 저녁</b> — 1비트 · 선택점 1 (<code>arc_father_quiet_call</code>)</summary>

```mermaid
flowchart TD
  arc_father_quiet_call["일요일 저녁 ⚠︎연출없음"]
```

</details>

<details><summary><b>첫 면접</b> — 2비트 · 선택점 2 (<code>arc_intro_01_meal</code>)</summary>

```mermaid
flowchart TD
  arc_intro_01_meal["첫 면접 ⚠︎연출없음"]
  arc_intro_02_dad_call["통장에 찍힌 숫자 ⚠︎연출없음"]
  arc_intro_01_meal -->|"'가족 빚을 갚고 있었습니다' — 담담하게 말했"| arc_intro_02_dad_call
  arc_intro_01_meal -->|"'개인 사업을 준비했습니다' — 그럴듯하게 포장"| arc_intro_02_dad_call
```

</details>

<details><summary><b>새벽 두 시</b> — 1비트 · 선택점 1 (<code>arc_intro_03_sns</code>)</summary>

```mermaid
flowchart TD
  arc_intro_03_sns["새벽 두 시 ⚠︎연출없음"]
```

</details>

<details><summary><b>옆방</b> — 2비트 · 선택점 2 (<code>arc_intro_04_hyunsu</code>)</summary>

```mermaid
flowchart TD
  arc_intro_04_hyunsu["옆방 ⚠︎연출없음"]
  arc_chapter1_close["서울에서의 첫 두 달 ⚠︎연출없음"]
  arc_intro_04_hyunsu -->|"'저도 아직 모르겠어요. 찾는 중이에요.'"| arc_chapter1_close
  arc_intro_04_hyunsu -->|"'강남 갈 거예요. 5년 안에.'"| arc_chapter1_close
```

</details>

<details><summary><b>접촉</b> — 1비트 · 선택점 1 (<code>arc_jiyeon_01_crash</code>)</summary>

```mermaid
flowchart TD
  arc_jiyeon_01_crash["접촉 ⚠︎연출없음"]
```

</details>

<details><summary><b>또, 너</b> — 1비트 · 선택점 1 (<code>arc_jiyeon_02_store</code>)</summary>

```mermaid
flowchart TD
  arc_jiyeon_02_store["또, 너 ⚠︎연출없음"]
```

</details>

<details><summary><b>쉬운 돈</b> — 1비트 · 선택점 1 (<code>arc_temptation_01</code>)</summary>

```mermaid
flowchart TD
  arc_temptation_01["쉬운 돈"]
```

</details>

<details><summary><b>지나간 자리</b> — 1비트 · 선택점 0 (<code>arc_temptation_clean</code>)</summary>

```mermaid
flowchart TD
  arc_temptation_clean["지나간 자리 ⚠︎연출없음"]
```

</details>

<details><summary><b>빌려준 계좌의 반환 요청</b> — 1비트 · 선택점 1 (<code>arc_temptation_fallout</code>)</summary>

```mermaid
flowchart TD
  arc_temptation_fallout["빌려준 계좌의 반환 요청 ⚠︎연출없음"]
```

</details>

<details><summary><b>강남 카페</b> — 10비트 · 선택점 6 (<code>cafe_00</code>)</summary>

```mermaid
flowchart TD
  cafe_00["강남 카페 ⚠︎연출없음"]
  cafe_listen_01["틈 ⚠︎연출없음"]
  cafe_mind_01["아메리카노 한 잔의 시간 ⚠︎연출없음"]
  cafe_peek_01["훔쳐본 것 ⚠︎연출없음"]
  cafe_talk_01["말을 걸다 ⚠︎연출없음"]
  cafe_caught_honest["들킨 솔직함 ⚠︎연출없음"]
  cafe_humble["낮은 자세 ⚠︎연출없음"]
  cafe_bluff_01["허세 ⚠︎연출없음"]
  cafe_bluff_caught["들통 ⚠︎연출없음"]
  cafe_bluff_recover["무너진 뒤 ⚠︎연출없음"]
  cafe_00 -->|"조용히, 계속 엿듣는다"| cafe_listen_01
  cafe_00 -->|"신경 끄고 이력서나 본다"| cafe_mind_01
  cafe_listen_01 -->|"폴더를 슬쩍 펼쳐본다"| cafe_peek_01
  cafe_listen_01 -->|"그가 돌아오면 말을 걸어본다"| cafe_talk_01
  cafe_peek_01 -->|"솔직히 사과한다 — '죄송합니다, 관심이 많아서"| cafe_caught_honest
  cafe_talk_01 -->|"솔직하게 — '무직입니다. 배우고 싶습니다'"| cafe_humble
  cafe_talk_01 -->|"있는 척한다 — '저도 이쪽 일 좀 합니다'"| cafe_bluff_01
  cafe_bluff_01 -->|"아는 척 우긴다 — 대충 숫자를 던진다"| cafe_bluff_caught
  cafe_bluff_01 -->|"무너진다 — '...사실 모릅니다. 죄송합니다'"| cafe_bluff_recover
```

</details>

<details><summary><b>못 한 인사</b> — 1비트 · 선택점 1 (<code>v2_daeun_return_after_distance</code>)</summary>

```mermaid
flowchart TD
  v2_daeun_return_after_distance["못 한 인사 ⚠︎연출없음"]
```

</details>

<details><summary><b>이번에는 먼저</b> — 1비트 · 선택점 1 (<code>v2_daeun_return_named</code>)</summary>

```mermaid
flowchart TD
  v2_daeun_return_named["이번에는 먼저 ⚠︎연출없음"]
```

</details>

<details><summary><b>다음 화요일</b> — 1비트 · 선택점 1 (<code>v2_daeun_small_commitment</code>)</summary>

```mermaid
flowchart TD
  v2_daeun_small_commitment["다음 화요일 ⚠︎연출없음"]
```

</details>

<details><summary><b>한마디 더</b> — 1비트 · 선택점 1 (<code>v2_daeun_third_greeting</code>)</summary>

```mermaid
flowchart TD
  v2_daeun_third_greeting["한마디 더 ⚠︎연출없음"]
```

</details>

<details><summary><b>한빛유통 1차 면접</b> — 1비트 · 선택점 1 (<code>v2_hanbit_interview</code>)</summary>

```mermaid
flowchart TD
  v2_hanbit_interview["한빛유통 1차 면접 ⚠︎연출없음"]
```

</details>

<details><summary><b>한빛유통 채용 연락</b> — 1비트 · 선택점 1 (<code>v2_hanbit_offer_message</code>)</summary>

```mermaid
flowchart TD
  v2_hanbit_offer_message["한빛유통 채용 연락 ⚠︎연출없음"]
```

</details>

<details><summary><b>먼저 보낸 메시지</b> — 2비트 · 선택점 1 (<code>v2_hyunsu_player_reachout</code>)</summary>

```mermaid
flowchart TD
  v2_hyunsu_player_reachout["먼저 보낸 메시지 ⚠︎연출없음"]
  v2_hyunsu_first_study["처음 함께한 한 시간 ⚠︎연출없음"]
  v2_hyunsu_player_reachout -->|"내일 저녁으로 시간을 정한다"| v2_hyunsu_first_study
```

</details>

<details><summary><b>같은 시간</b> — 1비트 · 선택점 1 (<code>v2_hyunsu_study_followup</code>)</summary>

```mermaid
flowchart TD
  v2_hyunsu_study_followup["같은 시간 ⚠︎연출없음"]
```

</details>

<details><summary><b>10년 만의 메시지</b> — 1비트 · 선택점 1 (<code>v2_jaehyuk_message</code>)</summary>

```mermaid
flowchart TD
  v2_jaehyuk_message["10년 만의 메시지 ⚠︎연출없음"]
```

</details>

<details><summary><b>포장마차에서 다시</b> — 1비트 · 선택점 1 (<code>v2_jaehyuk_plain_reunion_echo</code>)</summary>

```mermaid
flowchart TD
  v2_jaehyuk_plain_reunion_echo["포장마차에서 다시 ⚠︎연출없음"]
```

</details>

<details><summary><b>같은 동네 큰길</b> — 1비트 · 선택점 1 (<code>v2_jiyeon_second_crossing</code>)</summary>

```mermaid
flowchart TD
  v2_jiyeon_second_crossing["같은 동네 큰길 ⚠︎연출없음"]
```

</details>

<details><summary><b>미래산업기술 채용 결과</b> — 1비트 · 선택점 0 (<code>v2_mirae_result_message</code>)</summary>

```mermaid
flowchart TD
  v2_mirae_result_message["미래산업기술 채용 결과 ⚠︎연출없음"]
```

</details>

<details><summary><b>두 번째 믹스커피</b> — 1비트 · 선택점 1 (<code>v2_sangchul_demo_echo</code>)</summary>

```mermaid
flowchart TD
  v2_sangchul_demo_echo["두 번째 믹스커피 ⚠︎연출없음"]
```

</details>

<details><summary><b>방 보러 간 날</b> — 4비트 · 선택점 2 (<code>v2_sangchul_housing_lead</code>)</summary>

```mermaid
flowchart TD
  v2_sangchul_housing_lead["방 보러 간 날 ⚠︎연출없음"]
  arc_sangchul_01_measure["사람을 읽는 법"]
  arc_sangchul_01_coffee["종이컵 하나"]
  arc_sangchul_01_answer["그 질문"]
  v2_sangchul_housing_lead -->|"'제 사정을 어떻게 아셨어요?'"| arc_sangchul_01_measure
  v2_sangchul_housing_lead -->|"'커피만 마시고 가겠습니다.'"| arc_sangchul_01_coffee
  arc_sangchul_01_measure -->|"'그럼 저는 어디까지 갈 사람으로 보입니까?'"| arc_sangchul_01_answer
  arc_sangchul_01_coffee -->|"'그 질문에는 답할 수 있습니다.'"| arc_sangchul_01_answer
```

</details>

<details><summary><b>서린물산 채용 결과</b> — 1비트 · 선택점 0 (<code>v2_seorin_result_message</code>)</summary>

```mermaid
flowchart TD
  v2_seorin_result_message["서린물산 채용 결과 ⚠︎연출없음"]
```

</details>

---

생성기: [`tools/project_dashboard.py`](../tools/project_dashboard.py) · 이 문서의 수치는 저장소의 현재 상태이며 손으로 적은 값이 아니다.
