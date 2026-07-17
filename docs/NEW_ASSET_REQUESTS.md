# 신규 에셋 요청 목록
> 이미지/오디오는 Codex 영역. 이 파일은 콘텐츠 팀(Claude)이 필요하다고 판단한 에셋을 기록하는 용도.
> **기존 배경/포트레이트로 임시 처리 중인 것들** — 더 몰입감을 위해 전용 에셋이 있으면 좋음.

---

## 🖼 배경 이미지 (Background)

### 우선순위 높음 (High)

> 2026-07-01 Codex: 아래 4종은 전용 배경을 추가하고 `ImageRegistry` 자동 추론에 연결함.

| 요청 ID | 설명 | 현재 대체 | 사용 이벤트 |
|---|---|---|---|
| `hagwon_street` | 밤 10시 대치동 학원가. 학생들이 쏟아지는 골목. 형광등 간판들. | 전용 배경 추가 완료 | kx_hagwon |
| `suneung_test_hall` | 수능 시험장 복도 또는 교실 분위기. 긴장감. | 전용 배경 추가 완료 | kx_suneung_day |
| `community_center` | 주민센터 번호표 대기실. 공공 건물 특유의 조명. | 전용 배경 추가 완료 | kx_jumin_center |
| `jjimjilbang` | 찜질방 내부. 황토방, 나무 베개, 빨간 유니폼. | 전용 배경 추가 완료 | kx_jjimjilbang (korea_leisure) |

### 우선순위 중간 (Medium)

> 2026-07-01 Codex: `cherry_blossom_path`, `saju_cafe`, `military_base_gate`, `company_dinner_restaurant`, `heatwave_city`는 전용 배경과 장소 ambience를 추가하고 `ImageRegistry` 자동 추론에 연결함.

| 요청 ID | 설명 | 현재 대체 | 사용 이벤트 |
|---|---|---|---|
| `cherry_blossom_path` | 벚꽃 만개한 여의도 또는 석촌호수 길. 분홍빛 꽃잎. | 전용 배경 추가 완료 | kx_spring_cherry |
| `saju_cafe` | 사주카페 내부. 촛불, 사주 책, 별자리 장식. | 전용 배경 추가 완료 | kx_saju_cafe |
| `military_base_gate` | 군부대 정문 또는 예비군 훈련장 입구. | 전용 배경 추가 완료 | kx_reserve_duty |
| `company_dinner_restaurant` | 고기집 회식. 삼겹살 연기, 소주잔. | 전용 배경 추가 완료 | kx_hoesik |
| `heatwave_city` | 아지랑이 피어오르는 도심. 폭염 도시 거리. | 전용 배경 추가 완료 | kx_heatwave |

### 우선순위 낮음 (Low, Nice-to-have)

> 2026-07-01 Codex: `chuseok_highway`, `fine_dust_sky`, `open_chat_screen`은 전용 배경과 장소 ambience를 추가하고 `ImageRegistry` 자동 추론에 연결함.

| 요청 ID | 설명 | 현재 대체 | 사용 이벤트 |
|---|---|---|---|
| `chuseok_highway` | 명절 귀성길 고속도로. 빨간 브레이크등 물결. | 전용 배경 추가 완료 | kx_chuseok_traffic |
| `monsoon_street` | 장마 빗속 골목. 우산 행렬. | `street_rainy` + `sfx_monsoon_rain`으로 처리 완료 | kx_monsoon |
| `fine_dust_sky` | 미세먼지로 뿌연 서울 하늘. 회색빛 도시. | 전용 배경 추가 완료 | kx_fine_dust |
| `open_chat_screen` | 오픈채팅 화면 분위기 배경. 특정 브랜드/실제 UI 로고 없이 추상 채팅만 표시. | 전용 배경 추가 완료 | kx_open_chat, geojibang_chat |
| `daechi_library` | 새벽 도서관 열람실. 고시생 옆 빈자리. | 보류 — `kx_gosi_study`는 실제로 고시원 복도 이벤트라 도서관 배경 적용 금지. 기존 `library.png` 장면에는 `amb_library_room` 추가 완료 | kx_gosi_study 재작성 시 재검토 |

---

## 🎵 오디오 (SFX / BGM)

| 요청 ID | 설명 | 트리거 |
|---|---|---|
| `sfx_civil_defense_siren` | 민방위 사이렌 소리 (2-3초). 일시 재생. | 완료 — kx_civil_defense_siren 이벤트 진입 시 |
| `sfx_cherry_petals` | 벚꽃 바람 소리. 부드러운 앰비언스. | `amb_cherry_blossom` 장소 ambience로 처리 완료 |
| `sfx_monsoon_rain` | 장마 빗소리. 고시원 창문 빗방울. | 완료 — kx_monsoon 이벤트 진입 시 |
| `bgm_hoesik` | 회식 분위기 BGM. 노래방 + 삼겹살집 소음 믹스. | 완료 — `amb_company_dinner` 장소 ambience로 처리 |
| `amb_fine_dust_city` | 미세먼지 도심의 낮고 답답한 교통/공기 루프. | 완료 — fine dust 계열 이벤트 ambience |
| `amb_highway_traffic` | 명절 고속도로 정체의 낮은 차량 소음/브레이크 루프. | 완료 — chuseok/highway 계열 이벤트 ambience |
| `amb_open_chat_room` | 고시원 방 안의 휴대폰 알림/작은 진동/방 공기 루프. | 완료 — open chat 계열 이벤트 ambience |
| `amb_library_room` | 공공 도서관/열람실의 형광등, 책장 넘김, 낮은 키보드 소리. | 완료 — `library` 배경 이벤트 ambience |

---

## 🎬 엔딩 CG (P0/P1)

> 상세 기준: `docs/ENDING_ART.md`.
> 전용 CG는 예쁘기보다 먼저 정확해야 한다. 특히 주연 인물 얼굴, 나이, 관계, 공간 정본,
> `MORAL_TINT` 상태가 틀리면 연결하지 않는다.

### P0 — Next Fest/상점 스크린샷 후보

| 요청 ID | 연결 엔딩 | 설명 |
|---|---|---|
| `cg_ending_full_circle` | `full_circle` | 강남 펜트하우스/거실 창가. 상철 빚을 청산하고 아버지 이름을 돌려받는 S+ 진엔딩 |
| `cg_ending_gangnam_dream_white` | `gangnam_dream_white` | White moral route 전용. 강남 야경 앞, 차갑고 맑은 공기, 아무도 밟지 않고 도착한 고요함 |
| `cg_ending_with_daeun` | `with_daeun` | 작은 주방/외곽 빌라. 다은과 민준이 라면/커피를 사이에 두고 웃는 장면 |
| `cg_ending_second_love` | `second_love` | 강남 아파트 베란다. 다은은 야경을 보고 민준은 커피를 탄다 |
| `cg_ending_jiyeon_man` | `jiyeon_man` | 강남 고급 욕실/복도 거울. 고혹적이고 위험한 지연, 행복과 공허 사이의 민준 |
| `cg_ending_guardian` | `guardian` | 창원 병원 퇴원 날. 민준이 아버지 짐을 든다. 기존 병실 방문 CG와 구분 |
| `cg_ending_jaehyuk_way` | `jaehyuk_way` | 강남 아파트에서 커튼을 치는 민준. Black moral route, 돈만 남은 결말 |
| `cg_ending_sangchul_reckoning` | `sangchul_reckoning` | 경찰서 진술서/밤 카페. 강남 사다리를 스스로 치우는 손과 서류 |

### P1 — 정식 출시 전 보강

| 요청 ID | 연결 엔딩 | 설명 |
|---|---|---|
| `cg_ending_late_call` | `late_call` | KTX 창가, 폰을 쥔 손, 빗방울 |
| `cg_ending_instant_legend` | `instant_legend` | **완료.** 첫해 33세 민준, 등기 폴더, 한 상자와 낡은 가방만 놓인 비현실적으로 빈 강남 거실 |
| `cg_ending_startup_exit` | `startup_exit` | **완료.** 작은 창업 회의실, 서명 직후 놓은 펜, 민준 방향의 계약서·휴대폰 |
| `cg_ending_lonely_rich` | `lonely_rich` | 고급 거실에서 혼자 배달앱을 닫는 장면 |
| `cg_ending_orthodox_pinnacle` | `orthodox_pinnacle` | **완료.** 실제 한국 회식 테이블, 후배의 부러움과 물잔으로 내린 민준의 불확신 |
| `cg_ending_gambling_recovery` | `gambling_recovery` | 고시원 책상 달력의 동그라미. 카지노가 아니라 회복의 일상 |
| `cg_ending_bankruptcy` | `bankruptcy` | **완료.** 계산을 반복하다 멈춘 첫 파산 임계 |
| `cg_ending_debt_spiral` | `debt_spiral` | **완료.** 뒤집은 계산기와 놓아 버린 손의 더 깊은 부채 단계 |
| `cg_ending_burnout` | `burnout` | **완료.** 응급 관찰 침상 1인칭 시점, 형광등·연결된 링거·닿지 않은 뒤집힌 휴대폰. 정신과 `mental_break`와 공유 금지 |

---

## 🎮 미니게임 브리프 (Codex 구현용)

### 인형뽑기 (Claw Machine) — 이미 docs/KOREA_EXPERIENCE_PLAN.md에 기록됨
- 이벤트: `kx_claw_machine` (korea_experience.json)
- 3회 시도, 성공률 30%, 실패하면 계속 도전 여부 선택

### 타로 카드 애니메이션 (Optional)
- 이벤트: `kx_tarot` (korea_fortune.json)
- 단순 플립 애니메이션으로 카드 한 장 뽑는 연출 (텍스트 이벤트에 시각적 레이어 추가)

---

## 🎨 MORAL_TINT — 테마색 시스템 (Codex 핸드오프) ★최우선

> 상세 스펙: `docs/MORAL_TINT.md`. 게임의 핵심 신규 시스템. **"회색 시작 → 인간성=하양 / 돈=검정"**.
> 엔진(Claude)과 2차 시각 연결(Codex)은 완료. 현재 `MainGame.gd`가 아래 신호를 구독해 배경 채도 제거/그레이딩·표면 부식/선명도 셰이더·상단 HUD/선택지/패널/버튼 UI-wide 무채색 palette·돈 HUD 글로우·엔딩 팔레트를 적용한다. 후속은 전환 타이밍, SFX 연동, 캐릭터 초상화/CG별 moral variant.
> 신규 이미지/CG/엔딩 컷신 생성은 `docs/GANGNAM_INK_ART_DIRECTION.md`의 prompt prefix와 Black/White variant 규칙을 먼저 붙인다. 기존 특정 AI 세대의 그림체를 따라가는 것보다 `Gangnam Ink` 필터를 통과했을 때 정합성이 유지되는지가 우선이다.

**구독할 신호 (GameState) — 시그널 기반, 폴링 불필요:**
```gdscript
GameState.moral_tint_changed.connect(func(norm: float, stage: int):
    # norm: -1.0(새까망) ~ 0.0(회색) ~ +1.0(새하양) — 색 보간용
    # stage: -2/-1/0/+1/+2 — 이산 효과 단계용
    _apply_moral_visuals(norm, stage)
)
```
- **run_started 시에도 발동** — 새 런 시작 시 norm=0.0 / stage=0 초기 상태로 리셋됨
- 즉시 현재값 읽기: `GameState.moral_tint_norm()`, `GameState.moral_stage()`

**칠할 것:**
1. **테마색 보간**: norm을 따라 전역 테마/액센트를 **검정(−1) ↔ 회색(0) ↔ 하양(+1)** 으로. 시작은 회색(0).
2. **돈 글로우 (반비례·핵심)**: stage가 검정(−1,−2)일수록 **자산 HUD 숫자만 반대로 더 밝게/형형하게.** 나머지 UI는 채도 빠지는데 돈만 빛남 = 시각적 주제문.
3. **틀어짐 (stage −2)**: 미세한 자간 어긋남·1px 패널 오프셋·멈칫하는 호버·차갑고 빨라진 타이핑. "게임이 아니라 내가 잘못된 것 같은" 불쾌함. (점프스케어 금지, 서서히)
4. **엔딩 팔레트**: `_show_ending` 진입 시 최종 `moral_tint_norm()`으로 엔딩 화면 색 결정. 검정 30억(jaehyuk_way)=새까만 화면+돈만 형광 / 하양(다은·화해)=따뜻.

**원칙**: 플레이어에게 숫자·게이지 절대 노출 금지. 변화는 *서서히* (한 선택에 확 바뀌지 않게 — norm은 ±8/100 단위로 움직임).

---

## 📝 우선순위 요약

1. **즉시 필요**: 완료 — `jjimjilbang`, `hagwon_street`, `suneung_test_hall`, `community_center`
2. **다음 스프린트**: 엔딩/핵심 아크 CG 우선순위 재검토, 신규 서사 데이터 반영 후 인물/장소 큐 재감사
3. **나중에**: 엔딩 CG + moral route별 핵심 컷신

> 업데이트: 2026-07-01
