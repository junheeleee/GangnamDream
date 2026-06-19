# 엔딩 아트 점검 & 신규 에셋 필요 목록

> 2026-06-17 스크린샷 QA로 26개 엔딩의 배경·CG 매핑을 전수 점검.
> 2026-06-20 엔딩 화면 런타임을 보강해, 전용 CG가 없는 엔딩도 엔딩별 배경을
> 모달 내부 와이드 컷신 프리뷰로 표시한다.
> **원칙: 애매한 엔딩에 있는 에셋을 억지로 끼우지 않는다.** 톤이 안 맞으면
> 모순되지 않는 중립 배경으로 임시 처리하고, 여기에 "신규 에셋 필요"로 표시한다.
> 나중에 전용 이미지/오디오 소스를 만들어 넣을 때 이 문서를 기준으로 한다.

범례: ✅ 기존 에셋 적합 / 🎨 임시(중립) — 전용 에셋 있으면 더 좋음 / 🆕 신규 에셋 필요(우선)

---

## 배경 매핑 현황 (26종)

### ✅ 기존 에셋 적합 — 추가 작업 불필요

| 엔딩 | 배경 | 근거 |
|---|---|---|
| gangnam_dream (S) | gangnam_apartment | 30억·강남 입성 클라이맥스 |
| empty_house (A) | gangnam_apartment | 강남 아파트지만 곁에 아무도 없음 |
| with_daeun (A) | convenience_night | 편의점에서 처음 만난 다은 — 정본 일치 |
| jiyeon_man (A) | gangnam_day | 한지연과 함께 강남 입성 |
| jaehyuk_way (B) | gangnam_night | 수단 안 가리고 오른 강남, 밤 |
| late_call (B) | ktx_window(고향행 기차) | KTX 창원행·아버지 전화 — 정본 일치 |
| burnout (F) | burnout_hospital | 과로로 입원 |
| mental_break (F) | burnout_hospital | 마음이 꺾여 무너짐 |
| bankruptcy (F) | seoul_rainy | 빚 1억·비 오는 거리의 절망 |
| debt_spiral (F) | seoul_rainy | 빚 2억·고시원 |
| political_fix (B) | gangnam_night | 여의도 금배지, 밤의 권력감 |
| reputation_legend (A) | gangnam_night | 서울의 전설 |
| unorthodox_legend (A) | gangnam_night | 아웃사이더 5억 승리 |
| healthy_retirement (B) | rooftop_day | 55세 한강 조깅 — 정본 일치 |
| early_retirement (A) | rooftop_day | 알람 없는 아침, 평온 |
| balanced_life (B) | rooftop_day | 나만의 균형 |
| lonely_rich (A) | penthouse | 10억·거실 혼자 야경 — 정본 일치 |
| investment_master (A) | penthouse | 재테크 달인, 성공 |
| startup_exit (A) | penthouse | 엑싯 성공 |
| instant_legend (?) | gangnam_apartment | 50만→30억 신화 |
| ordinary_life (C) | seoul_rainy | 서울 외곽 빌라·평범, 비 오는 거리 |
| orthodox_hollow (C) | seoul_rainy | 공허한 성공, 감정 없는 회색 |

### 🎨 이번에 모순 제거(임시 중립 처리) — 전용 에셋 있으면 격상

| 엔딩 | 변경 | 사유 / 신규 에셋이 있으면 이상적 |
|---|---|---|
| stable_success (B) | penthouse → **rooftop_day** | 본문 "10억·강남은 아니었지만 흔들리지 않는 삶". 펜트하우스는 강남 럭셔리를 주장해 모순 → 차분한 옥상으로 중립화. 🆕 **"강남 아닌 중산층 안정 — 소박하지만 단단한 집/거실"** 전용 배경이 있으면 더 정확 |
| orthodox_pinnacle (A) | penthouse → **restaurant** | 본문 "2억·강남은 아니었다" + "팀 회식 자리" → 회식 식당(텍스트 근거). 펜트하우스 모순 제거. 🆕 **"정석파의 소박한 자부심 — 회식/사무실"** 전용 컷이 있으면 격상 |
| crypto_ghost (F) | seoul_rainy → **trading_room** | 본문 "코인 차트 중독·호가창" → 트레이딩 화면(더 정확). 🆕 **"중독으로 황폐해진 방 + 차트 불빛"** 전용 CG가 이상적 |

---

## CG(클로즈업 일러스트) 현황

현재 보유 CG는 4종뿐: `start`(시작 고시원), `jiyeon_crash`(접촉사고),
`jaehyuk_reveal`(재혁 폭로), `ending_father`(아버지 병실).

### 런타임 표시 정책
- 전용 `cg`가 있는 엔딩은 해당 CG를 배경과 모달 내부 와이드 프리뷰에 모두 사용한다.
- 전용 `cg`가 없는 엔딩은 엔딩별 `background`/fallback 배경을 모달 내부 와이드 프리뷰로 표시한다.
- 따라서 모든 엔딩은 최소 한 장의 시각 컷으로 마무리된다. 단, 이것은 전용 CG 대체가 아니라
  전용 CG가 입고되기 전의 런타임 품질 보강이다.

### 🔁 잘못 배치돼 제거한 것
- **gangnam_dream 의 `cg_ending_father` 제거** — 승리(초인종 울리는 강남 입성)에
  아버지 임종 병실 CG가 떠서 톤 정반대. cg 필드 삭제 → gangnam_apartment 배경으로 정상화.

### 🔁 유휴 에셋 — 전용 엔딩 생기면 배치
- **`ending_father.png`(아버지 병실, 손잡는 임종)** — 현재 어느 엔딩에도 안 쓰임.
  향후 **"아버지 임종/병실 화해" 엔딩**을 만들면 거기에 배치. 지금은 억지로 끼우지 않음.

### 🆕 엔딩 전용 CG가 있으면 임팩트가 큰 후보 (현재는 배경만)
> 모든 엔딩에 CG가 필요한 건 아니다. 아래는 "한 장의 그림"이 결말의 감정을
> 크게 끌어올릴 만한 엔딩들 — 신규 일러스트 제작 시 우선순위.

| 우선 | 엔딩 | 그렸으면 하는 장면 |
|---|---|---|
| ★★★ | gangnam_dream | 큰 창 거실에서 도시를 내려다보는 뒷모습 + 초인종 (승리의 정점) |
| ★★★ | empty_house | 같은 거실, 그러나 빈 식탁·꺼진 불 (이룬 자의 공허) |
| ★★★ | crypto_ghost | 어두운 방, 얼굴을 파랗게 물들이는 차트와 꺼지지 않는 거래소 화면 |
| ★★☆ | with_daeun | 외곽 빌라 주방, 둘이 라면 끓이는 장면 (편의점 회상과 대비) |
| ★★☆ | late_call | KTX 창가, 폰을 든 손과 흐르는 빗방울 (이미 배경은 적합) |
| ★★☆ | mental_break / burnout | 병실 천장을 보는 1인칭/측면 (강남 야경과 대비) |
| ★☆☆ | creator_success | 구독자 100만 알림이 쏟아지는 모니터 + 작은 작업방 |
| ★☆☆ | jiyeon_man | 화장실 거울 앞 혼자 선 남자 (가진 자의 균열) |

---

## 오디오 (참고 — 별도 점검 대상)

엔딩 BGM은 `BGMPlayer.on_ending()`이 good/bad로 분기해 기존 트랙 재사용 중.
엔딩별 **전용 스팅(짧은 엔딩 음악)** 은 아직 없음 — 신규 오디오 소스 제작 시
승리(gangnam_dream/instant_legend)·실패(burnout/mental_break)·씁쓸함(late_call/empty_house)
세 결의 전용 스팅이 있으면 결말 인상이 크게 달라진다. (우선순위 낮음)

---

## 체크리스트 (신규 에셋 입고 시)

- [ ] stable_success 전용 배경(중산층 안정) → 제작 후 `endings.json` background 교체
- [ ] orthodox_pinnacle 전용 컷 → 제작 후 교체
- [ ] crypto_ghost 전용 CG(황폐한 방+차트) → `cg` 필드 추가
- [ ] 아버지 임종/화해 엔딩 신설 시 `ending_father.png` 배치
- [ ] 승리/실패/씁쓸 엔딩 전용 CG (위 표 ★★★~★★☆)
- [ ] 엔딩 전용 BGM 스팅 3결
