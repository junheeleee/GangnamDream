# ROMANCE_SYSTEM.md — 로맨스/결혼 정본

> 두 히로인은 **반전된 거울**이다. 로맨스는 보상이 아니라 Question A("오르면서 같은 사람이 되지 않을 수 있는가")의 시험대다.
> 관련: `CLAUDE.md` 정본 규칙 · `docs/STORY_BIBLE.md` · 엔딩 라우팅은 `GameState.finish_run` 캐스케이드가 정본.

---

## 1. 두 히로인 — 반전된 거울

| | **김다은** | **한지연** |
|---|---|---|
| 정체 | 편의점 야간, 시골 어머니를 모시려 돈 모음 | 부동산 회사 회장 딸, 자기 것을 가지려 독립(부산 공인중개사) |
| 상징 | 민준이 **떠나온 세계** (소박·진심) | 민준이 **가려는 세계** (강남이 기본값) |
| 호칭 | 민준을 **"민준씨"** | 민준을 **"오빠"** |
| 스피치 | **존댓말** 일관 (진심의 격식) | **반말** — 단 **연애 확정 후부터**. 첫 만남~알던 사이는 존댓말 (분양딜 이벤트 등 기존 반말 구간은 친밀 구간이라 정합) |
| EN | "Minjun" (이름으로 부름 = 사람으로 봄) | "oppa" (로마자 유지) + 캐주얼 레지스터(축약형·직설) |
| 민준의 말 | 존댓말 기조 | 존댓말 기조 (그녀만 반말 — 도도함의 비대칭) |
| 시험 | 그녀를 **수단으로 쓰지 않을 수 있는가** | 그녀의 세계에 맞추다 **자기를 잃지 않을 수 있는가** |

## 2. 진행 구조

- **상호배타**: `daeun_romance_started` ↔ `jiyeon_romance_started`. 한쪽 시작 시 다른 쪽 Y5 고백(arc_*_y5_feelings) 게이트가 닫힌다 (MainGame `_next_arc_id` 조건).
- **조기 연애 가능**: Y2부터 플레이어 선택으로 시작 가능 (다은 confession 등). Y5 게이트 단일화 아님.
- **다은 라인**: 편의점 만남(t9)→단골→꿈 이야기→갈림길(t23)→…→고백/연애→**프로포즈(t150+)**→약혼 후 아크(`arc_daeun_married.json`): 우리 집의 의미(t155)→상견례(t168, father_passed 시 스킵)→스드메(t175, 소박 vs 과시)→결혼식(t200, 신랑석=5년간 사람에게 쓴 시간의 결산)→**상철의 시험(t182**, 아내를 서류로 쓰라는 제안)→**최종 선택(t228, 자산 18억~30억 미달 시에만**: 배신→`daeun_divorced`+crossed_line / 거부→`chose_daeun`). 정직하게 30억 도달한 기혼자는 최종 선택 없이 따뜻한 진엔딩.
- **지연 라인**: 재회→진짜 이유(내 거 하나)→부산 독립(Y3)→Y4 서울 방문→Y5 귀환/고백→결혼: **처가 눈높이 결혼식(t205**, 빚내서 맞춤 vs 형편대로)→**심판(t228, 자산 5억 미만 시에만**: "오빠가 이렇게 살 사람인 줄 몰랐어" — 붙잡음=`jiyeon_kept_by_diminishing`+crossed_line(자기를 잃음) / 보냄=`jiyeon_left`(자기를 지킴)).
- **이혼의 거울상**: 다은은 **그녀를 배신하면** 잃고, 지연은 **자기답게 살면** 잃는다. 어느 쪽도 트로피가 아니다.

## 3. 엔딩 라우팅 (finish_run 캐스케이드 순서가 정본)

- **30억 도달 시**: daeun_divorced→`lonely_rich` → daeun_married→`gangnam_dream`(진엔딩 변주) → jiyeon_romance_started(not left)→`gangnam_dream`(그녀 세계 진입 변주) → 이후 crossed_line→jaehyuk_way. **배우자 실이 crossed_line보다 먼저다.**
- **age>=38 시**: daeun_divorced→lonely_rich / jiyeon_left→ordinary_life / with_daeun / jiyeon_man(kept_by_diminishing이면 공허 변주).
- 엔딩 dik 변주: gangnam_dream[`used_daeun_as_means`(실금)>daeun_married>jiyeon_romance_started], lonely_rich[daeun_divorced], with_daeun[daeun_married], jiyeon_man[jiyeon_kept_by_diminishing], ordinary_life[jiyeon_left]. **순서 주의 — 배우자 변주가 항상-매치 키보다 앞.**

## 4. 한국 결혼 문화 = 돈 vs 사람 결정

스드메·예단·하객·청첩장·신혼여행은 장식이 아니라 **강남 자금과 경쟁하는 지출 선택**으로 구현한다. 민준의 텅 빈 신랑석(하객 없음)은 5년간 사람에게 쓴 시간의 결산 — `hyunsu_reconnected` 등 관계 플래그가 하객 dik로 회수된다.

## 5. 성인 콘텐츠 정책

본편=존엄 페이드아웃(성숙하되 명시 없음). 성인 patch slot은 구조만 — Claude는 tasteful 버전만 작성.

## 6. 작성 규칙 (신규 로맨스 콘텐츠 체크리스트)

1. 호칭/스피치 표를 지켰는가 (다은 존댓말·민준씨 / 지연 연애 후 반말·오빠)
2. 새 플래그에 독자(조건/dik/코드)가 있는가 (write-only 0 래칫)
3. 이미 심어진 실(계란말이·카페 약속·시골 어머니·부산 엽서·아버지 공장)을 **회수**하는가 — 발명보다 회수
4. 상호배타 게이트를 건드렸으면 `arc_flow_sim.py` 실행
5. KR+EN 동시 작성, 엔딩 dik이면 EN 패리티 키 확인
