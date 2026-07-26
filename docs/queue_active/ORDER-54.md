# Active Queue Spec: ORDER-54

> Canonical status is indexed in `docs/CODEX_QUEUE.md`.
> 선행 계보: [`ORDER-51`](../queue_archive/ORDER-51.md)(사문 발견) → `ORDER-52`(콜백 32건 부활)
> → `ORDER-53`(예약 배열 확장). 이 오더는 그 계보의 **마지막 남은 휴면 코퍼스**를 닫는다.
> **Claude 코드 검증 완료(2026-07-26)** — 아래 수치·계약은 저장소에서 재현한 사실이다.

#### [~] 착수 — 만지는 파일: `content/events/{chain_events,rare_encounter_events}.json`, `content/events_en/{chain_events,rare_encounter_events}.json`, `content/meta/event_director.json`, `tools/{audit,event_director_audit,arc_flow_sim}.py`, `tools/{EventDirectorCheck,ScreenshotQA}.gd`, `docs/{BALANCE,CODEX_QUEUE,WORK_LOG}.md`, `docs/queue_active/ORDER-54.md`, `CLAUDE.md`

ORDER-54 [P1·체인 부활] 씨앗-수확 12체인을 되살린다

## 배경과 결정

ORDER-51이 확인한 마지막 휴면 덩어리다. 감사가 지금도 정직하게 경고 중이다:
`WARNING event director: dormant delayed corpus remains pending design callback=564 chain=12`.

`chain_events.json` 12체인은 **낯선 사람에게 베푼 사소한 친절이 8~12주 뒤 취업·주거·소득으로
돌아오는** 씨앗-수확 그물이다(반찬가게 → 아들 채용, 지갑 반환 → 전무 점심 → 계열사 면접,
이웃 축하 → 월세 지원 공고). 인물망이 아니라 낯선 사람 기반이라 리뷰 그물에서 늦게 발견됐다.

**Claude 판단으로 부활을 결정했다.** ORDER-37 콘텐츠 다이어트가 막은 것은 "무관한 단문 1,000개가
전경을 빼앗는 것"이고, 여기서 필요한 건 **씨앗 5건**이다 — 규모가 두 자릿수 다르고, 체인은
단문이 아니라 8~12주짜리 인과 서사다. 다만 결함을 **먼저 고치고** 되살린다.

## 설계 — ORDER-53 배열 확장을 활용한 최소 침습

체인은 씨앗(랜덤 조우)과 수확(조건부 후속)의 2단 구조라 둘의 배선 방식이 다르다.

- **씨앗 5건은 허용목록에 넣는다.** 작성형 생산자가 없는 진짜 랜덤 조우라 예약 배선 대상이
  아니다. `foreground_event_ids` 61 → 66.
- **수확은 허용목록에 넣지 않는다.** ORDER-53이 확장한 `deferred_follow_up` 배열로 **씨앗의
  해당 선택지에서 8~12주 예약**한다. 이 방식의 이득 셋:
  1. 허용목록 증가가 +5로 끝난다(체인 12건을 넣으면 +17).
  2. 리뷰가 지적한 **"지연이 강제되지 않는다"**가 동시에 해결된다 — 현재 수확 조건은 절대턴
     `min_turn`뿐이라 씨앗 다음 주에 터질 수 있고(강제 간격 0~4주) 상한도 없다. 예약은 상대
     간격을 확정한다.
  3. 수확은 전경 풀에 들어가지 않으므로 `foreground_min_description_chars`(160) 계약을 만족할
     필요가 없다. 현재 12건 중 10건이 111~154자로 미달인데, **산문을 늘리려고 없는 장면을
     발명하지 않아도 된다.**
- **이미 허용목록에 있는 수확 2건**(`chain_envelope_owner_return`, `chain_interior_offer`)은
  목록에서 **제거**하고 예약으로 통일한다. 목록에 남기면 씨앗 없이 랜덤 발화하거나 예약과
  타이밍이 경합한다.

## A. 부활 전 필수 결함 수리

### A-1. 취업을 선언하는데 실제로 취업하지 않는다 (high)
- **`chain_interior_offer`#0** — 결과문이 "첫 달 월급 280만원"이라 선언하는데 `effects`는
  `money 500000` 1회뿐이고 `grant_job`이 없다. 실제 상태는 **무직·월수입 0**으로 남는다.
  `content/jobs.json`에 280만원 자리도 없다(`job_04` 271만 / `job_05` 317만).
  → 기존 job id 중 현장 관리직 성격에 맞는 행에 `grant_job`을 연결하고 결과문 금액을 그 행의
  급여와 맞춘다. **동시에 `conditions`에 `"no_job": true`를 추가**한다 — 형제 두 건
  (`chain_banchan_son`·`chain_exec_interview`)은 이미 이 게이트를 갖는데 이 이벤트만 없어
  대기업 재직 중인 민준에게도 현장직 제안이 열린다.
- **`chain_exec_interview`#0** — 계열사 면접 합격 서사인데 `grant_job`이 없다. 같은 방식으로
  기존 job id를 연결한다. (`no_job` 게이트는 이미 있음 — 유지.)

### A-2. 선택 전에 결과를 확정 고지한다 (medium)
`chain_neighbor_civil_servant`#1의 선택지 텍스트가 "나중에 하려다 마감을 놓친다" 식으로
자기 결과를 미리 알려 준다. 정본은 "미래 결과를 선택 전에 확정적으로 해설하지 않는다"이다.
→ 행동만 남기고 결과 고지를 뺀다("다음 주에 하기로 한다" 계열).

### A-3. 서술자 격언·회계 정산 문장 (medium)
24개 선택지 결과 중 격언 종결 9행("정직은 수익률이 늦게 터지는 투자였다", "기회는 미루지
않는 사람 거다", "인생의 길은 가끔 반찬가게를 지나서 난다" ↔ "인생은 가끔 그런 데서 방향을
튼다"는 근접 중복), 씨앗을 금액으로 환산하는 회계 문장 2행("월 280만원이 되어 돌아왔다",
"이삿날 박스 세 번 나른 게 120만원이 됐다").
→ ORDER-46 패턴대로 **마지막 격언 문장 삭제**, 직전 행동·감각 묘사로 끝맺는다. 회계 문장은
사건의 사실만 남기고 인과를 계산해 주지 않는다.

### A-4. 4체인이 같은 결말로 수렴 (medium)
반찬가게·지갑·이웃·인테리어 네 체인이 전부 "감사한 낯선 사람이 일자리·현금을 준다"로 끝나고
종결 문장까지 근접 중복이다. → 각 체인의 종결을 고유 사물·동작으로 차등화한다(신규 장면 없이
기존 문장 재배치·교체).

### A-5. 두 번째 선택지가 막다른 길 (medium)
12건 중 11건의 두 번째 선택지가 하류 플래그를 남기지 않아, 거절·보류를 고르면 서사가 끊긴다.
`chain_banchan_reunion`은 정반대로 갈린 두 선택이 2비트 뒤 **동일 플래그로 수렴**해 갈림이
무효가 된다. → 최소한 거절 분기에도 상태를 남겨 이후 콜백·dik가 읽을 수 있게 한다
(`chain_envelope_guilt`가 이미 `envelope_kept_final`로 이 일을 정확히 하고 있으니 그 패턴을 따른다).

### A-6. ⚠ 리뷰어 주장 중 **기각**한 것 (Claude 정정)
1차 리뷰는 `chain_neighbor_civil_servant`의 `money +1,200,000`을 "이삿짐 박스 세 번에 120만원 —
보상이 씨앗 크기를 완전히 이탈"이라 판정했으나, **실파일 확인 결과 사실이 아니다.** 이 돈은
공무원이 된 이웃이 알려 준 **청년 월세 지원 공고 6개월치(월 20만 × 6)**이고, 결과문도
"월세 지원 6개월. 총 120만원"으로 출처를 밝힌다. 놓치는 분기(#1)도 `mental -10`과 "120만원이
손가락 사이로 빠져나갔다"로 대가가 있다. **동기가 정당하므로 수치를 건드리지 않는다.**
회계 문장(A-3)만 수리 대상이다.

## B. 씨앗 5건 — 산문 확장 후 허용목록 편입

전경 풀 계약(`meets_foreground_contract`, `tools/event_director_audit.py:443~457`)은 ①선택지 ≥2
②`description` ≥160자 ③각 `result_text` ≥ 하한 ④선택 간 물질적 대비를 요구한다. 현재 씨앗은
전부 설명이 미달이다.

| 씨앗 | 현재 desc | 파일 |
|---|--:|---|
| `rare_market_kind_stranger` | 103자 | `rare_encounter_events.json` |
| `rare_wallet_executive` | 86자 | `rare_encounter_events.json` |
| `rare_night_alva_find` | 94자 | `rare_encounter_events.json` |
| `rare_goshiwon_neighbor_success` | 83자 | `rare_encounter_events.json` |
| `rare_celeb_convenience` | 114자 | `rare_encounter_events.json` |

→ 각 씨앗의 설명을 **160자 이상으로 확장**한다. 이는 신규 사건이 아니라 **기존 장면의 밀도
보강**이며(감각 구체·시간 늘리기), 동결 안에서 허용된다. 발명 금지 — 이미 그 장면에 있는
사물·장소·인물만 쓴다. 확장 후 `foreground_event_ids`에 5건을 추가한다.
`butterfly_mystery_info_result_scam`은 이미 목록에 있으므로 그대로 둔다.

## C. 수확 예약 배선

씨앗의 **플래그를 세우는 선택지**에 `deferred_follow_up`을 단다. 이미 예약이 있으면 ORDER-53
배열 문법으로 나란히 담는다. 권장 간격은 **8~12주**(리뷰의 "8~12주 뒤 회수" 설계 의도).
2단 체인(씨앗 → 중간 → 최종)은 중간 노드의 선택지에서 다시 예약해 사슬을 잇는다.

착수 시 실제 플래그 생산 지점을 grep으로 특정해 배선표를 이 파일에 기록한 뒤 구현한다.
수확 12건의 `conditions.min_turn`은 **하한 보험으로만 남기고** 상대 간격은 예약이 소유한다.

## 검증

- `python3 tools/audit.py` → ERROR 0/WARNING 0, write-only 플래그 0, inert 0
- `python3 tools/event_director_audit.py` → **`chain_reachable`이 0에서 12로**, 휴면 경고의
  `chain=12`가 사라진다. `foreground` 61 → 66, 씨앗 5건이 전경 계약을 통과한다.
- `python3 tools/arc_flow_sim.py` — 예약이 아크 슬롯을 잠식하므로 상한 있는 아크의 도달률
  회귀를 확인한다(ORDER-52 검증 항목과 동일한 8종).
- `GODOT=<경로> ./tools/audit.sh` → "✅ 감사 통과", `python3 tools/english_hangul_audit.py`
- 대표 A/B 240주 실주행으로 **씨앗 발화 → 8~12주 뒤 수확 발화**를 실제로 계측하고, 취업
  분기에서 `current_job`·`monthly_income`이 실제로 바뀌는지 확인한다.
- KR·EN 동시 수리. 수치 변경분은 `docs/BALANCE.md` 기록.
