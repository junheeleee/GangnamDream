# Active Queue Spec: ORDER-53

> Canonical status is indexed in `docs/CODEX_QUEUE.md`.
> 선행: [`ORDER-52`](ORDER-52.md) T2 — **유저 승인 완료(2026-07-26): 엔진 배열 확장 (가)안 채택.**
> ORDER-52가 `[~]`인 동안 그 파일을 건드리지 않기 위해 T2를 이 오더로 분리했다.
> **착수 조건: ORDER-52 T1 완료·커밋 후** (`arc_events.json`·`arc_drama.json` 등 파일이 겹친다).

#### [~] 착수 — 만지는 파일: `autoloads/{DataRegistry,EventManager,GameState}.gd`, `content/events/{arc_drama,arc_events,callback_events_2}.json`, `content/events_en/callback_events_2.json`, `content/meta/story_rules.json`, `assets/{event_visual_contracts,scene_direction_manifest}.json`, `tools/{event_schedule,audit,event_director_audit,narrative_continuity_audit,narrative_spine_audit,arc_flow_sim,convergence_sim,mod_pack_validator}.py`, `tools/{EventDirectorCheck,ScreenshotQA}.gd`, `docs/{BALANCE,CODEX_QUEUE,WORK_LOG}.md`, `docs/queue_active/{ORDER-52,ORDER-53}.md`, `CLAUDE.md`

ORDER-53 [P1·엔진 확장 + 배선] 한 선택지에 예약 여럿 — T2 3행 부활

## 배경

ORDER-52 선별에서 **값어치 최상위 3건**이 "이미 예약이 있는 선택지"에 걸려 배선 불가였다.
원인은 엔진이 choice당 예약을 **문자열 하나만** 읽기 때문이다(Claude 코드 검증):

```gdscript
# autoloads/GameState.gd:1093~1095 (현재)
var deferred_id := str(choice.get("deferred_follow_up", "")).strip_edges()
if not deferred_id.is_empty():
    add_deferred_event(deferred_id, int(choice.get("deferred_delay", 6)))
```

유저가 **(가) 배열 허용**을 승인했다. 한 줄 확장으로 이후 부활·후속 배선의 상한이 사라진다.

## A. 엔진 확장 계약

`GameState.gd`의 위 지점에서 `deferred_follow_up`이 **문자열 또는 배열**을 받게 한다.

- **문자열**(기존): 지금 동작 그대로. 기존 81건 배선은 **한 글자도 바뀌지 않아야 한다.**
- **배열**: 각 원소는 ①문자열 id — 이 경우 delay는 선택지의 `deferred_delay`(기본 6)를 공유,
  또는 ②`{"id": "<event_id>", "delay": <int>}` — 원소별 delay를 갖는다. 혼용 허용.
- 빈 문자열·빈 id 원소는 조용히 무시(현재 `is_empty()` 가드와 동일한 관용도).
- `add_deferred_event()`(`GameState.gd:2903`)는 **수정하지 않는다** — 이미 event_id로 중복을
  제거하고 더 이른 `trigger_turn`을 남기므로 배열이 같은 id를 두 번 담아도 안전하다.
- 저장 포맷 `deferred_events`(`{event_id, trigger_turn}` 배열)는 **불변** — 세이브 마이그레이션 불요.

**감사 동반 수정** — `tools/audit.py`가 현재 문자열만 가정한다:
- `:327` `dfu = ch.get("deferred_follow_up", "")` 존재성 검사 → 배열의 **모든 원소**를 검사하도록.
  (이 검사가 "그림자 체인 끊김"을 막는 기존 게이트다 — 배열에서 빠지면 사문이 재발한다.)
- `:1040`·`:1045` 체인 추적 루프도 배열 원소를 전부 따라가게.
- `:639` 키 화이트리스트는 이미 `deferred_follow_up`·`deferred_delay`를 포함하므로 변경 불요.

## B. T2 배선 3행 (Claude가 슬롯 점유를 실파일로 확인)

| 장 | 파일 | 생산자#선택지 | 기존 예약(유지) | 추가할 예약 |
|:--:|---|---|---|---|
| 4 | `arc_drama.json` | `arc_sangchul_reckoning`#2 | `arc_sangchul_year3` (delay 1) | `callback_sangchul_leveraged_cost` (delay 12) |
| 3 | `arc_events.json` | `arc_jaehyuk_04b_counter`#1 | `arc_jaehyuk_aftermath` (delay 1) | `callback_jaehyuk_exploited_retaliate` (delay 12) |
| 3 | `arc_events.json` | `arc_jaehyuk_04b_counter`#2 | `arc_jaehyuk_aftermath` (delay 1) | `callback_jaehyuk_partnered_reckoning` (delay 14) |

기존 예약을 **대체하지 말 것** — 배열에 나란히 담아 둘 다 살린다. delay가 1 대 12~14로 갈려
같은 주에 두 예약이 겹치지 않는다(아크 슬롯 잠식 방지).

**왜 이 3건인가** — 선별에서 값어치 최상위였다:
- `callback_sangchul_leveraged_cost` — 아버지를 무너뜨린 사람의 죄책감을 자산처럼 쓴 대가가
  거울로 청구된다. 상철과 재혁을 같은 프레임에 세우는 유일한 콜백(돈·가족·신념이 한 장면).
  *"언젠가 최재혁의 눈빛에서 봤던 게, 거기 있었다."*
- `callback_jaehyuk_partnered_reckoning` — '빠르게. 더럽게.' 손잡은 판이 실제 정산으로 돌아온다.
  *"나오는 길에 손을 씻었다. 두 번."*
- `callback_jaehyuk_exploited_retaliate` — 갈취 수익이 역협박으로 실제로 줄어드는 유일한 재혁 콜백.

## C. 부활 전 필수 산문 수리 (3건 — ORDER-52의 제약 2와 동일 이유)

예약 발화는 `EventManager.gd:718`이 `queue_event`로 직행해 **conditions를 재검사하지 않는다.**
성립하지 않는 상태를 전제한 문장은 그대로 거짓이 된다.

1. **`callback_jaehyuk_partnered_reckoning`** — 산문과 effects 액수 불일치. choice0 결과문
   "원래 비율대로 받았다. 5800만원" ↔ `effects.money` 15,000,000, choice1 "3200만원" ↔ 8,000,000.
   한쪽으로 통일(밴드 확인, `BALANCE.md` 기록).
2. **`callback_jaehyuk_exploited_retaliate`** — choice0 결과문 "일주일 뒤 돈이 들어왔다… 원금은
   됐다" ↔ `effects.money` -3,000,000이 정반대로 읽힌다. 이미 받은 3배분을 반납하고 원금만
   남긴다는 정산을 문장에서 밝힌다.
3. **`callback_sangchul_leveraged_cost`** — 산문 결함 없음(선별 판정 `needs_prose_fix: none`).
   다만 예약 착지(t≈144)에서 상철 대면 이후 상태를 전제하지 않는지 확인만 한다.

## 검증

- `GODOT=<경로> ./tools/audit.sh` → "✅ 감사 통과", `python3 tools/english_hangul_audit.py`
- **기존 81건 회귀가 최우선** — 배열 확장이 문자열 경로를 건드리지 않았음을 증명한다.
  기존 `deferred_follow_up` 문자열 배선의 발화 시점·횟수가 확장 전후로 동일해야 한다.
- `python3 tools/arc_flow_sim.py` — T1 34행에 3행이 더해지므로 상한 있는 아크 8종
  (ORDER-52 검증 항목)의 도달률을 재확인한다.
- 대표 경로 실주행으로 `arc_jaehyuk_04b_counter` 선택 시 **aftermath(1주)와 콜백(12~14주)이
  둘 다 발화**하고 서로 삼키지 않음을 계측한다. 같은 id 중복 예약 0도 확인.
- 세이브 왕복: 확장 전 세이브를 확장 후 빌드에서 로드해 `deferred_events`가 보존되는지.
