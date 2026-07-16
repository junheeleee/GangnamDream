# Tier-1 정점 체인 감사

> 기준일: 2026-07-16 · 정본: `docs/ROMANCE_SYSTEM.md` §8 · 재현: `python3 tools/peak_scene_chain_audit.py --markdown`

## 판정 계약

- **링크**: 같은 플레이 세션에서 `follow_up_event`로 실제 연속 재생되는 이벤트 수다. 몇 주 뒤 스케줄러로 다시 등장하는 후속편은 한 장면으로 세지 않는다.
- **선택점**: 선택지가 두 개 이상인 이벤트 수다. 계속 버튼 역할의 단일 선택지는 비트지만 선택점은 아니다.
- **패널**: StoryMode가 `\n\n` 기준으로 나누는 본문·선택 결과 화면과 선택 도크를 합친 실제 입력 표면 수다.
- **대화**: 해당 경로에서 왕복하는 인용 대사의 수다. 독백만 긴 장면을 대화 장면으로 오인하지 않는다.
- **PASS**: 모든 분기가 2~4링크, 2~3선택점, 6패널 이상, 대사 2회 이상을 만족한다. 하나라도 짧은 분기가 있으면 `EXPAND`다.
- KO가 게임플레이 정본이며 EN은 같은 이벤트·선택지 수를 가져야 한다. 라우팅·기존 최종 선택·효과·플래그는 확장 중에도 불변이다.

## 2026-07-16 기준선 및 현재 래칫

| 정점 | 루트 이벤트 | 링크 | 선택점 | 패널 | 대화 | 판정 |
|---|---|---:|---:|---:|---:|---|
| 그 밤 | `arc_daeun_first_night` | 1 | 1 | 10 | 2-4 | EXPAND |
| 다은 첫날밤 | `arc_daeun_wedding_night` | 1 | 1 | 7 | 4 | EXPAND |
| 지연 첫날밤 | `arc_jiyeon_wedding_night` | 1 | 1 | 6 | 2-5 | EXPAND |
| 다은 첫 키스 | `arc_daeun_first_kiss` | 1 | 1 | 5 | 2-3 | EXPAND |
| 지연 첫 키스 | `arc_jiyeon_first_kiss` | 1 | 1 | 5 | 2-4 | EXPAND |
| 어머니의 밥상 | `arc_daeun_hometown_2` | 1 | 1 | 8 | 2-3 | EXPAND |
| 좁은 방 | `arc_jiyeon_narrow_room_2` | 1 | 1 | 7-8 | 3-4 | EXPAND |
| 다은 남산 | `arc_date_namsan_daeun` | 2 | 2 | 9 | 4-6 | **PASS** |
| 지연 남산 | `arc_date_namsan_jiyeon` | 2 | 2 | 9 | 6-8 | **PASS** |
| 다은 바다 | `arc_season_sea_daeun` | 1 | 1 | 6 | 3-4 | EXPAND |
| 지연 바다 | `arc_season_sea_jiyeon` | 1 | 1 | 5 | 6 | EXPAND |
| 다은 불꽃 | `arc_season_fireworks_daeun` | 1 | 1 | 4 | 2-3 | EXPAND |
| 지연 불꽃 | `arc_season_fireworks_jiyeon` | 1 | 1 | 3 | 2-4 | EXPAND |
| 다은 프로포즈 | `arc_daeun_proposal` | 3 | 2 | 25-26 | 9-10 | **PASS** |
| 다은 결혼식 | `arc_daeun_wedding_day` | 4 | 2 | 33 | 3 | **PASS** |
| 지연 결혼 격차 | `arc_jiyeon_wedding_gap` | 3 | 3 | 22-23 | 6-8 | **PASS** |
| 지연 심판 | `arc_jiyeon_verdict` | 1 | 1 | 9-10 | 3-8 | EXPAND |
| 다은 이혼 담판 | `arc_daeun_final_choice` | 1 | 1 | 8-10 | 1-2 | EXPAND |
| 상철 첫 만남 | `arc_sangchul_01_meet` | 1 | 1 | 8 | 4-6 | EXPAND |
| 상철 진실 추론 | `arc_sangchul_deduction` | 1 | 1 | 8-10 | 0 | EXPAND |
| 상철 대면·심판 | `arc_sangchul_confrontation` | 2-3 | 2-3 | 20-30 | 4-15 | **PASS** |
| 상철 카지노 유혹 | `arc_sangchul_casino_invite` | 1 | 1 | 6 | 1 | EXPAND |
| 아버지 병상 | `father_hospital_wait` | 2 | 2 | 17-19 | 4-7 | **PASS** |
| 아버지 별세 | `arc_father_passing` | 3 | 2 | 16-17 | 3-5 | **PASS** |
| 23초 KTX 통화 | `arc_father_call_on_ktx` | 2-3 | 2 | 14-23 | 4-9 | **PASS** |
| 현수 재회 | `hyunsu_reunion_later` | 1 | 0 | 10 | 3 | EXPAND |
| 재혁 ghost | `arc_jaehyuk_04a_ghost` | 1-2 | 1-2 | 8-14 | 0 | EXPAND |
| 재혁의 진짜 얼굴 | `arc_jaehyuk_mirror` | 1 | 1 | 7 | 1-3 | EXPAND |

**현재 래칫:** 28개 중 PASS 9, 확장 부채 19. `tools/audit.sh`는 부채가 19보다 늘거나 남산 두 골드 스탠다드·다은 프로포즈·다은 결혼식·지연 결혼 격차·상철 대면·아버지 병상·아버지 별세·23초 KTX 통화가 퇴행하면 실패한다.

## 집행 순서

1. ✅ `arc_daeun_proposal`: `마지막 잔 → 내년 이맘때 → 프로포즈` 3링크와 2선택점으로 확장했다. 수락·보류 효과와 플래그는 최종 링크에만 남고, 수락 CG는 결과 문단 1에서만 열린다.
2. ✅ `arc_daeun_wedding_day`: `다은 어머니 반응 → 신랑석 상태 → 다은의 입장 → 두 사람 근접` 4링크와 2선택점으로 확장했다. 민준 선입장·다은 후입장, 어머니 혼주 한복, 아버지 혼주 정장/별세 빈자리/현수 단독 상태, 소형·풀 커플 변주를 서로 다른 컷으로 분리하고 기존 최종 효과를 고정했다.
3. ✅ `arc_jiyeon_wedding_gap`: `볼룸 압력 → 비어 있는 신랑석 명단 → 최종 비용 선택` 3링크와 3선택점으로 확장했다. 선택 전 계급 압력이라는 기존 CG 사실을 유지하고, 최종 비용·플래그·호감도 효과는 마지막 링크에만 남겼다.
4. ✅ `arc_sangchul_confrontation`: 심판 직행·식은 커피·문밖 세 걸음의 2~3링크와 2~3선택점으로 확장하고 여섯 최종 결과 계약을 보존했다.
5. ✅ `father_hospital_wait`: 창원 병원 대기→결과지 2링크·2선택점으로 확장했다. 기다리는 방식은 상태를 선점하지 않으며, 결과를 외면하거나 함께 읽는 기존 최종 효과는 마지막 링크에만 남는다.
6. ✅ `arc_father_passing`: 현재 주거의 네 번째 전화 → 겨울 서울역 승강장/투자 딜룸 → 창원 빈 병실/다음 날 통보의 네 경로를 3링크·2선택점으로 분리했다. 앞 두 링크에는 상태가 없고, 기존 KTX·딜 효과와 아버지 별세 플래그는 각 마지막 링크에만 남는다.
7. ✅ `arc_father_call_on_ktx`: 창원중앙역을 지나친 서울행 KTX → 저장한 23초/연락처 → 현재 통화 버튼의 2~3링크·2선택점으로 확장했다. 과거 아버지는 창원 집의 원격 기억 프레임으로만 보이며, 기존 `mental -5/tint +15/called`와 `mental -10/tint +3/uncalled` 결과는 마지막 링크에 그대로 남는다.
8. **다음:** 첫 키스 2종·첫날밤 2종, 재혁, 어머니의 밥상·좁은 방, 심판·이혼, 계절 정점 순으로 부채를 낮춘다.

각 정점은 별도 착수 선언·커밋·KO/EN 렌더를 갖는다. 사용자 Round 2 피드백이 들어오면 즉시 멈추고 ORDER-22/23 재수리를 우선한다.
