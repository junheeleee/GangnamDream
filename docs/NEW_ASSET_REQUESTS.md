# 신규 에셋 요청 목록
> 이미지/오디오는 Codex 영역. 이 파일은 콘텐츠 팀(Claude)이 필요하다고 판단한 에셋을 기록하는 용도.
> **기존 배경/포트레이트로 임시 처리 중인 것들** — 더 몰입감을 위해 전용 에셋이 있으면 좋음.

---

## 🖼 배경 이미지 (Background)

### 우선순위 높음 (High)

| 요청 ID | 설명 | 현재 대체 | 사용 이벤트 |
|---|---|---|---|
| `hagwon_street` | 밤 10시 대치동 학원가. 학생들이 쏟아지는 골목. 형광등 간판들. | `street` | kx_hagwon |
| `suneung_test_hall` | 수능 시험장 복도 또는 교실 분위기. 긴장감. | `office_interview_day` | kx_suneung_day |
| `community_center` | 주민센터 번호표 대기실. 공공 건물 특유의 조명. | `realestate_office` | kx_jumin_center |
| `jjimjilbang` | 찜질방 내부. 황토방, 나무 베개, 빨간 유니폼. | `gym` | kx_jjimjilbang (korea_leisure) |

### 우선순위 중간 (Medium)

| 요청 ID | 설명 | 현재 대체 | 사용 이벤트 |
|---|---|---|---|
| `cherry_blossom_path` | 벚꽃 만개한 여의도 또는 석촌호수 길. 분홍빛 꽃잎. | `hangang_riverside` | kx_spring_cherry |
| `saju_cafe` | 사주카페 내부. 촛불, 사주 책, 별자리 장식. | `cafe` | kx_saju_cafe |
| `military_base_gate` | 군부대 정문 또는 예비군 훈련장 입구. | `street` | kx_reserve_duty |
| `company_dinner_restaurant` | 고기집 회식. 삼겹살 연기, 소주잔. | `restaurant` | kx_hoesik |
| `heatwave_city` | 아지랑이 피어오르는 도심. 폭염 특보 전광판. | `street` | kx_heatwave |

### 우선순위 낮음 (Low, Nice-to-have)

| 요청 ID | 설명 | 현재 대체 | 사용 이벤트 |
|---|---|---|---|
| `chuseok_highway` | 명절 귀성길 고속도로. 빨간 브레이크등 물결. | `subway` | kx_chuseok_traffic |
| `monsoon_street` | 장마 빗속 골목. 우산 행렬. | `street` | kx_monsoon |
| `fine_dust_sky` | 미세먼지로 뿌연 서울 하늘. 회색빛 도시. | `street` | kx_fine_dust |
| `open_chat_screen` | 카카오 오픈채팅 화면 분위기 배경. | `goshiwon_room` | kx_open_chat |
| `daechi_library` | 새벽 도서관 열람실. 고시생 옆 빈자리. | `goshiwon_room` | kx_gosi_study |

---

## 🎵 오디오 (SFX / BGM)

| 요청 ID | 설명 | 트리거 |
|---|---|---|
| `sfx_civil_defense_siren` | 민방위 사이렌 소리 (2-3초). 일시 재생. | kx_civil_defense_siren 이벤트 진입 시 |
| `sfx_cherry_petals` | 벚꽃 바람 소리. 부드러운 앰비언스. | kx_spring_cherry 이벤트 |
| `sfx_monsoon_rain` | 장마 빗소리. 고시원 창문 빗방울. | kx_monsoon 이벤트 |
| `bgm_hoesik` | 회식 분위기 BGM. 노래방 + 삼겹살집 소음 믹스. | kx_hoesik 이벤트 |

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

1. **즉시 필요**: `jjimjilbang` (기존 gym이 너무 다름), `hagwon_street` (밤 학원가는 고유한 비주얼)
2. **다음 스프린트**: `cherry_blossom_path`, `saju_cafe`, `community_center`
3. **나중에**: 나머지 전부

> 업데이트: 2026-06-21
