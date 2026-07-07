# SCENE_DIRECTION.md — 씬 연출 디렉션 키 (스키마 + 연출 대본)

> 정본 결정(2026-07-07, 유저 승인): **애니메이션 제작 없이, Godot 네이티브 기능만으로 연출을 완성한다.**
> 연출 = 타이밍·소리·정적·정지화면의 카메라. 준거: Disco Elysium/Kentucky Route Zero. 반례: 감정 강요 QTE("Press F").
> 분담: 스키마·연출 대본(이 문서)=Claude / StoryMode 렌더러 구현·사운드 소스 선택=Codex (`docs/CODEX_QUEUE.md` 5.5).

---

## 1. 스키마 — 이벤트 JSON 루트의 선택적 `direction` 키

```json
{
  "id": "arc_father_passing",
  "direction": { "pace": "slow", "amb": "cut", "sting": "loss", "camera": "drift", "hold": 1.2 }
}
```

| 필드 | 값 | 의미 (구현 가이드) |
|---|---|---|
| `pace` | `"slow"` \| `"beat"` | slow=타이핑 속도 ~0.6배. beat=문단(\n\n) 사이 0.5~0.8s 정지. 둘 다 스킵 입력은 항상 허용 — 연출이 조작을 가두면 안 됨 |
| `amb` | `"cut"` \| `"duck"` | cut=씬 진입 시 앰비언스 페이드아웃(소리가 먼저 사라진다). duck=−8dB로 가라앉힘. 씬 종료 시 자동 복원 |
| `sting` | `"reveal"` \| `"loss"` \| `"cold"` | 원샷 스팅어 — 의도만 명명, 실제 사운드는 Codex 선택. reveal=진실이 드러나는 낮은 현. loss=상실. cold=서늘함(상철 계열). **BGM 재시작 금지** — 스팅어는 레이어 |
| `camera` | `"slow_zoom"` \| `"drift"` | 배경 정지화면의 Ken Burns — slow_zoom=중앙 1.00→1.04 (씬 길이에 걸쳐), drift=수평 미세 팬. 초상화에는 적용하지 않음(호흡 스케일 1~2%는 Codex 재량의 전역 옵션) |
| `hold` | 0.5~2.0 (초) | 본문 타이핑 완료 후 선택지 등장까지 강제 정적. **최대 2.0** — 그 이상은 연출이 아니라 구속 |

- dik 변주가 발화해도 direction은 동일 적용(장면 단위 속성).
- **audit 등록 필수**: 첫 사용 시 `tools/audit.py` `EVENT_ROOT_KEYS`에 `"direction"` 추가 + 필드/값 화이트리스트 검사 한 줄(미지의 값이 조용히 무시되는 클래스 방지).
- EN 오버레이에는 direction을 두지 않는다(게임플레이·연출 키는 KR 소스에만 — 기존 원칙).

## 2. 사용 규율 (설교 방지 5원칙의 연출판)

1. **전체 이벤트의 ~5% 이하, 아크 정점 비트에만.** 일상 이벤트에 slow를 걸면 화폐가치가 죽는다 — 희소성이 곧 효과다.
2. **감정을 명령하지 않는다.** slow+sting+hold 풀스택은 런 전체에서 3~4회만(아버지·대면·이혼급). 나머지는 1~2개 필드만.
3. **조작 존중**: 어떤 연출도 스킵/입력을 막지 않는다. hold만 예외(≤2s).
4. 어둠의 장면과 빛의 장면에 같은 수준의 연출을 준다(2원칙: 어둠의 문장 품질과 동일).

## 3. 연출 대본 (1차 — 정점 비트 16장면)

| 이벤트 id | direction | 의도 |
|---|---|---|
| `arc_temptation_01` | `{"sting":"cold"}` | 12초 타이머가 이미 연출의 본체 — 봉투가 열리는 순간의 서늘함 한 음만 |
| `arc_sangchul_01_meet` | `{"camera":"drift"}` | 첫 만남은 가볍게 — 관찰의 카메라 |
| `arc_sangchul_deduction` | `{"pace":"beat","sting":"reveal"}` | 단서가 맞물리는 박자, 진실의 현 |
| `arc_father_06_confession` | `{"pace":"slow","amb":"duck"}` | 고백은 느리게, 세상은 반 발 물러나서 |
| `arc_sangchul_confrontation` | `{"pace":"slow","amb":"cut","sting":"cold","hold":1.5}` | 풀스택 ① — 게임의 척추 대면 |
| `arc_sangchul_reckoning` | `{"pace":"beat","sting":"reveal"}` | 정산의 박자 |
| `arc_father_passing` | `{"pace":"slow","amb":"cut","sting":"loss","camera":"drift","hold":2.0}` | 풀스택 ② — 소리가 먼저 사라진다 |
| `arc_daeun_02b_dream` | `{"amb":"duck"}` | "강남 못 가도 민준씨는" — 편의점 소음이 가라앉는 순간 |
| `arc_daeun_04_morning` (고백) | `{"pace":"slow","camera":"drift"}` | 느린 아침 |
| `arc_daeun_proposal` | `{"pace":"slow","camera":"slow_zoom","hold":1.0}` | 반지 — 줌은 여기 한 번 |
| `arc_daeun_wedding_day` | `{"camera":"slow_zoom","sting":"reveal"}` | 텅 빈/채워진 신랑석이 보이는 줌 |
| `arc_daeun_final_choice` | `{"pace":"slow","amb":"cut","sting":"loss","hold":1.5}` | 풀스택 ③ — 서류 위의 결혼 |
| `arc_jiyeon_verdict` | `{"pace":"slow","amb":"duck","sting":"cold"}` | "오빠가 이렇게 살 사람인 줄 몰랐어" |
| `arc_jiyeon_y5_feelings` | `{"camera":"drift","amb":"duck"}` | 재회의 밤공기 |
| `arc_37_burn_or_light` | `{"pace":"beat"}` | 마지막 해의 자문 — 박자만 |
| `age_39_final` | `{"pace":"slow","hold":1.5}` | 5년의 끝, 정적 |

- 후속 후보(2차): 밴드 전이 moral beat(엔진 레벨 — Codex 재량), chapter_cards(`camera:drift` 일괄), 데모 플래시포워드(풀스택 ④ 예약).
- **로맨스 명장면 4종 예약**(ROMANCE_SYSTEM.md 7절 구현 시): 어머니의 밥상 `{"pace":"slow","amb":"duck"}` / 밤 버스 `{"camera":"drift","hold":1.5}` / 좁은 방 `{"amb":"cut","hold":1.5}` / 벚꽃(어둠 변주) `{"pace":"slow","sting":"cold"}`.
- 적용 방법: 위 id의 KR 이벤트에 `direction` 키 추가는 렌더러 구현과 **같은 커밋**에서(키만 먼저 넣으면 audit 미지 키 ERROR).

## 4. 구현 순서 (Codex)

1. `tools/audit.py` EVENT_ROOT_KEYS + direction 필드 검사 → 2. StoryMode 렌더러(pace/hold → 타이핑 엔진, amb → BGMPlayer, sting → AudioManager 레이어, camera → 배경 TextureRect 트윈) → 3. 위 대본 16장면 키 삽입 → 4. `ScreenshotQA --qa=story-en` + `BGMContinuityCheck`(sting이 BGM 재시작 안 함) + 대면/프로포즈 씬 직접 확인.
