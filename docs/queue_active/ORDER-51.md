# Active Queue Spec: ORDER-51

> Canonical status is indexed in `docs/CODEX_QUEUE.md`. 근거: 각본 리뷰 3차(지연 회수 엔진 2축 정독).
> **Claude 직접 코드 검증 완료(2026-07-26)** — 아래 수치는 리뷰어 주장이 아니라 저장소에서 재현한 사실이다.

#### [~] 착수 — 만지는 파일: `content/events/callback_events_14.json`, `content/events/callback_events_34.json`, `content/events_en/callback_events_14.json`, `content/events_en/callback_events_34.json`, `tools/event_director_audit.py`, `tools/ScreenshotQA.gd`, `docs/BALANCE.md`, `docs/CODEX_QUEUE.md`, `docs/queue_active/ORDER-51.md`, `CLAUDE.md`, `docs/WORK_LOG.md`

ORDER-51 [P1 + ⚠설계 판단] 지연 회수 엔진 — 도달 불가 코퍼스와 도달분 3건 수리

## 검증된 사실 (Claude 재현)

각본 리뷰의 마지막 미검토 표면(`chain_events.json` 12체인 + 비인물 콜백)을 정독한 결과,
**"늦은 회수" 코퍼스의 대부분이 플레이어에게 도달하지 않는다.** 리뷰어 주장을 그대로 믿지
않고 저장소에서 직접 재현했다:

| 사실 | 수치 | 재현 방법 |
|---|---|---|
| 콜백 총량 | **620건** (55파일, id 중복 0) | `content/events/callback_events*.json` 카운트 |
| 그중 도달 가능 | **24건 (3.9%)** | `event_director.json`의 `foreground_event_ids`(61) + `bridge_event_ids`(18) 교집합 |
| chain 체인 도달 가능 | **0/12** | 허용목록 2건뿐이고 그 씨앗이 목록 밖 → 연쇄 사망 |
| 대체 발화 경로 | **0건** | 전 이벤트의 `follow_up_event`/`deferred_follow_up`/`next_event` 중 `callback_`·`chain_`를 가리키는 포인터 0, 아크 스케줄러(`_next_arc_id`)도 반환 0 |

경로가 하나뿐임도 확인했다: `MainGame.gd` → `EventManager.draw_situations()` →
`EventManager.gd:444 if not is_foreground_random_event(event): continue` → 허용목록.
따라서 목록 밖 콜백·체인은 **조건이 아무리 성립해도 영원히 발화하지 않는다.**

**중요한 맥락:** 이 상태는 사고가 아니라 `ORDER-37` 콘텐츠 다이어트(랜덤 후보 1,032 →
전경 61 + 다리 18)의 결과다. 다이어트의 의도는 *무관한 단문이 전경을 빼앗는 것*을 막는
것이었지, 회수 층을 죽이는 것이 아니었다. 또한 주간 Echo는 콜백이 아니라 **행동 원장**을
읽는다(`_demo_director_recent_action_record`) — 즉 "늦은 회수" 약속의 일부는 Echo·dik가
이미 수행 중이고, 콜백 코퍼스는 그와 별개로 잠들어 있다.

## A. 즉시 수리 — 도달 가능 24건 안의 결함 3건 (P1, 판단 불요)

리뷰가 지적한 결함 15건 중 **플레이어가 실제로 보는 것은 아래 3건뿐**이다(나머지 12건은
죽은 콘텐츠 안이라 B의 판단 전에는 손대지 않는다 — 낭비 방지).

1. **`callback_jeonse_scam_narrow`** — 산문이 선언한 손실이 실제 차감액의 **10배**. 전세
   사기 회수 장면인데 통장에서 나가는 돈이 산문의 1/10. 산문↔`effects` 정렬(밴드 확인,
   `BALANCE.md` 기록). KR·EN 동시.
2. **`callback_recycling_neighbor`** — 잔존 설교. 서술자가 한국 사회를 강의하는 종결문이
   하필 도달 가능한 표면에 있다. `ORDER-46` 패턴대로 **마지막 격언 문장 삭제**, 직전 행동
   묘사로 끝맺기.
3. **`callback_formal_complaint_filed_echo`** — `min_turn`이 원천 플래그 생성 시점보다 훨씬
   일러 게이트가 사문 + 사전형 대괄호 라벨 잔존. `min_turn`을 생산자 이후로 올리고 라벨을
   `-는다/-ㄴ다` 종결로 수리.

## B. 설계 판단 — 도달 불가 596콜백 + 12체인 (⚠ 유저 결정 필요, 착수 금지)

이건 버그 수리가 아니라 **"늦은 회수를 무엇이 수행하는가"라는 설계 결정**이다. Claude가
임의로 정하지 않는다. 선택지와 비용:

- **(가) 정리·보류** — Echo + dik가 회수를 수행한다고 인정하고, 596콜백·12체인을
  `POST_LAUNCH_NOTES.md` 백로그로 내린다. 비용 최소. 리스크: 플래그 548개 중 상당수가
  "생산자만 있고 실질 독자는 잠든" 상태로 남아, 감사는 통과하나 약속은 비어 있다.
- **(나) 선별 부활** — 가장 값어치 있는 N건(예: 아버지·상철·재혁 계열 회수, 몸·전세 등
  실제 대가 회수)만 골라 **허용목록이 아니라 `deferred_follow_up`/`deferred_delay`로
  생산자 이벤트에서 직접 예약**한다. 이러면 랜덤 풀을 거치지 않아 다이어트 정본을 깨지
  않고 지연 회수가 확정 발화한다(엔진에 이미 있고 레포에서 81회 사용 중인 기능).
  비용 중간. **Claude 추천안.**
- **(다) 허용목록 확대** — 목록에 콜백을 대량 추가. 비용 최소지만 ORDER-37이 막았던
  "무관한 단문이 전경을 빼앗는" 문제가 재발하므로 **비추천**.

**✅ 유저 결정 (2026-07-26): (나) 선별 부활.** 후속 범위는 [`ORDER-52`](ORDER-52.md)가 소유한다 —
249건 정독 선별 → 최종 32건(37 배선행), T1 34행 즉시 배선 / T2 3행은 엔진 확장 승인 대기 /
부활 전 필수 산문 수리 25건. **B는 이 오더에서 종결되었으므로 여기서 추가 착수하지 않는다.**

## C. 재발 방지 게이트 (P1, B와 무관하게 가능)

`tools/audit.py`(또는 `event_director_audit.py`)에 **"조건이 성립해도 도달 불가한 이벤트"**
회귀 검사를 추가한다. 허용목록·다리·`deferred_follow_up`·아크 스케줄러 중 어느 경로로도
발화할 수 없는 이벤트 수를 집계해 기준선을 고정하고, 신규 사문이 늘면 실패시킨다.
지금의 사문 수(콜백 596 + 체인 12)는 기준선으로 기록하되 B의 결정 전까지는 경고로만 둔다.

## D. B가 (나)로 결정될 때 함께 처리할 잔존 결함 (지금은 착수 금지)

죽은 콘텐츠 안이라 부활 대상이 된 것만 수리한다: `callback_fomo_invested_result`(한 화면에
서로 다른 원금 2개), `callback_jeonse_ignored_result`(가입 불가한 보험을 사후 발명해 전액
회수 + 거짓 플래그 전파), `callback_coin_gambled_crash`(승패가 갈린 뒤에도 패배 서사 무조건
재생), `callback_gambling_memory`(18배 지급액 자릿수 불일치), `callback_chose_deeper_echo`
(중독 심화 분기가 순이득 — 대가 대칭 붕괴), 몸 계열 3연 골격 89.8%·선택지1 훈화 96.4%
잔존(ORDER-46이 선택지2만 수리), `chain_interior_offer`(월 280 관리직이 `grant_job` 없어
무직·월수입 0으로 남음), `chain_neighbor_civil_servant`(박스 세 번에 120만원).

## 검증

- A·C: `GODOT=<경로> ./tools/audit.sh` → "✅ 감사 통과", `python3 tools/english_hangul_audit.py`,
  수치 변경분 `docs/BALANCE.md` 기록.
- A는 도달 가능 3건이므로 실제 런타임 발화를 1280x800 실렌더로 확인.
- B는 유저 결정 후 별도 오더에서 검증 범위를 정한다.
