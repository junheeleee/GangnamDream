# 강남드림 콘텐츠 로드맵 — 스토리/게임성/흥행 (Claude 담당)

> **역할 분담**: 코덱스 = 외형(이미지/오디오/이펙트/UI·UX). Claude = 스토리·개연성·재미·밸런스·공략성·게임성·흥행 요소·이스터에그·분석요소.
>
> 작성일 2026-06-20. 매 작업 후 체크박스 갱신.

---

## 현황 스냅샷 (2026-06-20)
- 총 이벤트 **1014개** (social 247 / story 170 / relationship 115 / jobs 99 / investment 68 / family 67 / finance 67 / gambling 49 / health 42 / comedy 24 …)
- 엔딩 **29개** (S 1 / S+ 1 / A+ 2 / A 11 / B 6 / C 2 / F 5 / ? 1)
- legendary(이스터에그급) 18 / hidden 115
- 밸런스 밴드 전부 통과 (무직 실패 100% / 직장 실패 0% / 베팅 30억 14.8%)
- 엔딩 화면 분석요소 충실: route_bar / milestones / percentile / cast_epilogue / next_run_hints

## 설계 철학 (불변)
- **주제의식**: "평범한 월급으로는 강남 못 간다" → 직장 무베팅이 30억에 못 닿는 건 의도된 사회 비평. 밸런스 '버그' 아님.
- 분기는 **어떤 사람이 되어 도달했는가**로 갈린다 (정석/비정석/관계/건강).

---

## 우선순위 작업 후보

### P0 — 이스터에그 (발견형 서프라이즈) 🔨 진행 중
현재 18개 legendary는 대부분 스탯 게이트형. **특이한/영리한 플레이를 보상하는 발견형**이 부족.
- [x] `easter_eggs.json` 1차 배치 6종: 고시원 도사 / 삼각김밥 연대기 / 새벽 4시 / 정직함의 값 / 거울 속 도박꾼 / 조용한 부자(20억인데 고시원)
- [x] 2차 배치: 회귀(NG+) 자각 2종 — egg_deja_vu(2회+ 데자뷔)/egg_veteran_return(4회+ 베테랑 회귀). GameState.start_new_game에 is_repeat_run/is_veteran_run 플래그 추가
- [ ] 3차 후보: 미니게임 마스터(카지노 영역 — Codex 협의 필요), 강남 오픈하우스 단골, 히든 엔딩 1종

### P1 — 분석요소 강화 (replayability) ✅ 대부분 완료
런 요약이 얇음 (route/최고자산/선택통계 미수집). 엔딩 분석은 이미 좋으나 **메타 누적 통계** 약함.
- [x] `finish_run` 요약에 route_orthodox/unorthodox, peak_asset, events_seen, playstyle 추가
- [x] 엔딩 화면 "플레이 스타일 한 줄 진단" (승부사/롤러코스터/관계형/원칙주의자/개척자/소진형/생존형/탐험가/균형형 9종)
- [x] peak_asset 추적 + 엔딩 화면 "최고 자산 중 N% 지킴" 표시
- [x] 엔딩 도감 — discovered_endings 영구 누적 + 엔딩 화면 "📖 N/29 발견" 컴플리션 후크
- [x] 시작화면 스플래시에 "📖 엔딩 도감 N/29 발견" 표시 (전부 발견 시 골드 강조) — 컴플리션 후크 메뉴 노출

### P2 — 개연성·일관성 감사 (foundational quality) ✅ 1차 완료
1024 이벤트 규모 → 서사 모순 점검. 스크립트 스캔 + 수동 검증.
- [x] 직업 상태 vs 묘사 충돌: jobs_004/jobs_010(팀장 야근/면담 — 무직에도 발동) + subway_hell_9(출근길 지옥철) → `has_job:true` 게이팅. (점원 전제 2건은 친구/현수 얘기로 false positive 확인)
- [x] 거주 상태 vs 묘사 충돌: mother_seoul_visit/rel_family_visit_seoul(부모께 좁은 방 보여주기 — 핵심) → `housing:gosiwon`; rel_sns_compare/family_002(보편 감정) → 고시원 텍스트 완화 (천장/방 책상)
- [x] 무직·강남거주 전제 역방향 스캔: 0건 (정상 게이팅)
- [x] EN/KR 조건 동기화 (audit #8): 변경 4건 EN 오버레이 갱신
- [ ] 인물 stage vs 대사 톤 충돌 (차후 audit #7 보강)

### P3 — 흥행 시그니처 이벤트 (viral moments) 🔨 진행 중
한국 사회 특수성 기반 "공유하고 싶은" 순간. (명절/전세사기/영끌은 기존 충실 — 중복 회피)
- [x] **갓생/자기계발** (기존 0개 → 갭 해소): godsaeng_start(3지선다)/godsaeng_paradox(번아웃 역설)
- [x] **거지방** geojibang_chat: 카톡 익명 지출 검열 문화 (frugal_month_challenge와 차별 — 사회/코미디)
- [x] **리딩방 심화** leading_room_joined: gambling_006(광고)의 후속 — 실제 가입 후 회비 사기 구조 폭로
- [x] 2차: 주식 빚투/반대매매(debt_invest_margin_call — 기존 0개 갭, 레버리지 시스템 보완), 플랫폼노동/배달(gig_delivery_night — 청년 N잡 생존 현실)
- [ ] 3차 후보: 오마카세 플렉스 압박(기존 4개), 비혼/욜로 성찰(기존 0개)

### P4 — 공략성 (전략 가독성)
숨은 경로를 발견 가능하게.
- [ ] 마일스톤 도달 시 "다음 단계" 미묘한 힌트 (과하지 않게)
- [ ] 첫 플레이 가이드 이벤트 (튜토리얼 외)

---

## 작업 로그
- 2026-06-20: 로드맵 작성. P0 1차 배치 착수.
