# Active Queue Spec: ORDER-130

> Canonical status and execution order are indexed in `docs/CODEX_QUEUE.md`.

#### [~] ORDER-130 [P0·종막 정본 복구] 문단 수를 극적 비트로 센 9·10·9 할당량을 제거하고 장면 기능으로 다시 판정한다

**사용자 승인·착수 선언 (2026-08-25):** 사용자는 10비트가 이야기 때문에
필요한지, 자신의 “10까지도 갈 수 있다”는 예시에 억지로 맞춘 것인지 물었다.
독립 재독과 `docs/SCENE_TIER.md` 대조 결과 ORDER-129가 예시를 정확한 문단 수
할당량으로 오해한 사실을 확인했다. 사용자의 최신 지시와 장면 정본에 따라
숫자 강제를 제거하고, 종막 골격은 보존하되 중복 설명을 압축한다.

**착수 기준선:** `cbb9e31bac964e4a405acc1cf54cfc207edf2ac4`의 exact clean
전체 감사 `✅ 감사 통과`. 이 초록불은 기술 기준선일 뿐, 문단 할당량의 서사
승인이 아니다.

**정확한 파일 범위:** `content/events/arc_pre_ending.json`,
`content/events_en/arc_pre_ending.json`, `content/events/arc_drama.json`,
`content/events_en/arc_drama.json`, `tools/peak_scene_chain_audit.py`,
`tools/year5_reference_route_audit.py`,
`tools/chapter1_core_loop_v2_causal_ledger_check.py`, `tools/audit_scope.json`,
`docs/CODEX_QUEUE.md`, 이 사양과 완료 시 `docs/queue_archive/ORDER-130.md`,
`docs/queue_archive/CODEX_QUEUE_2026-08.md`, `CLAUDE.md`,
`docs/WORK_LOG.md`, 생성본 `docs/STATUS.md`.

## 깊이 3문

1. 왜 10을 8로 바꾸는 작업이 아닌가? 8도 먼저 고정하면 같은 오류다. 필요한
   기능을 먼저 쓰고 패널 수는 관측값으로만 보고한다.
2. 왜 M57·M59의 구체 이름과 계약을 지금 넣지 않는가? 현재 제품에 믿을 수 있는
   영수증과 actor binding이 없으므로 임의로 넣으면 또 거짓 장면이 된다. 다음
   Chapter 5 제품 경로가 이를 소유한다.
3. 무엇을 보존하는가? 세 event ID, 조건, 선택문, effects, flags, follow-up,
   마지막 서명 coda 72/33, 엔딩 35 ID·CG·15 route는 바꾸지 않는다.

## 배치 A — 장면 기능 감사 복구 8단위

1. `\n\n` 문단 수를 meaning beat로 부르며 정확히 9·10·9를 강제하는 검사를 제거한다.
2. `arc_final_countdown → arc_final_week` follow-up 전체를 한 장면으로 측정한다.
3. 패널·선택·결과·memory 삽입 수는 합격 수치가 아니라 관측값으로만 출력한다.
4. summit은 장소·현재 자산/목표·경로 비용·부대비용·계약 전 문턱·현재 행동을
   순서 독립 기능으로 검사한다.
5. countdown은 출발 숫자·현재 결과·실제 기록·돈/사람 장부·비계약 빈 줄·세
   의미·상호배타 포기·결정 이후 비용을 기능으로 검사한다.
6. final week는 직전 서명·실제 대화의 현재 상태·세 발신 행동·상대 선택권·
   현재 물건·민준의 선행 행동을 기능으로 검사한다.
7. moral/signature 변형은 바뀌는 문단 번호가 아니라 경로별 의미와 공통 사실을 검사한다.
8. 허위 30억 도달·매입·등기·열쇠·계약, 상대 답장·만남·용서·화해 금지와
   non-prose shape·KO/EN placeholder·선택 순서는 그대로 고정한다.

## 배치 B — 자연스러운 종막 압축·동형 10단위

1. summit KO 기본의 중복 장소/매물, 계약 부재, 선택 예고 문단을 자연스럽게 합친다.
2. summit KO 정석·비정석 변형도 같은 기능 순서를 가지되 경로 비용만 다르게 쓴다.
3. summit EN 세 표면을 한국어와 같은 사실·이미지·행동으로 다시 쓴다.
4. summit의 아버지 결과는 자연스럽게 압축하고 걷기 결과의 네 기능은 유지한다.
5. countdown KO 기본·black·white에서 중복 입장과 펜/결정 문단을 합친다.
6. countdown EN 세 표면을 번역투 없이 같은 기능 순서로 쓴다.
7. 자기 이름·사람들 결과의 중복을 압축하고 담보 결과의 네 기능은 유지한다.
8. final week KO 기본·세 signature 변형에서 대화 부재 설명을 한 번만 남긴다.
9. final week EN과 세 결과를 KO와 동형으로 고치되 플레이어 발신만 확정한다.
10. exact object guard·Chapter 1 source guard·audit selector를 승인된 새 실물에
    재결합하고 표적 검사·self-test·diff·전체 감사의 failure flag 0을 판정한다.

## 완료 증거

- exact 문단 수 assertion은 0이며 패널 수는 관측값으로만 출력된다.
- KO/EN 모든 표면은 같은 기능·사실·placeholder·선택 순서를 가진다.
- 기존 선택·effects·flags·follow-up과 ending coda 72/33, 엔딩 35·CG 35·
  15 route가 불변이다.
- 허위 계약·매입·등기·열쇠와 상대 답장·만남·용서·화해가 0이다.
- exact clean 전체 감사가 failure flag 0으로 끝난다.

## 다음 경계

이 오더는 잘못된 숫자 할당량과 그로 인한 중복 산문만 고친다. M57 명의·제출,
M59 실제 계약 결과, 남은 인물의 actor binding을 M60과 마지막 주에 회수하는 일은
Chapter 5 제품 경로가 실제 영수증을 만든 뒤 별도 오더가 소유한다.

