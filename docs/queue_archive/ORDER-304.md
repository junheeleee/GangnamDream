# ORDER-304 — 재혁 EN3leaf 수정의 역사 검사 호환

[x] 2026-09-27. 비저자 작업 한정 GO. ORDER-302 전체·본편·출시는 HOLD다.

- source `ae0a302574998c5415ff7a2e0428f80006648cf5`, tree `a1360b304b37c8fbc3fe4377d631e5f8fe431b35`.
- [독립 보고](../agent_reviews/ORDER-304.json) SHA `0202c23adebbc748d055c9720f400b16c4e786b185da89a4bb1687ba8cd2f76e`.
- 정확한 EN 파일/객체 및3leaf 전이만 역투영한다. payload/context/bytes/hash와155
  파일 census를 연결했으며 역사 hash/registry 및 raw 현재 원고는 바꾸지 않았다.
- volume은 실제 `graph:en_mapped_immediate` SHA 한 값만 갱신. 저장 observations·
  기존 부채30·outlier12·HOLD 불변이며 현재 report는 새 EN 본문을 그대로 계측한다.
- 최초실패3오류와 새단문중복/155census 수리 중 실패2→1 원본을 보존했다.
  `I'll be in touch.`는 다른 사건에도 있어 whole-file/whole-leaf identity로 구별했다.
- 최종 year5 normal 및 self552(신규39포함), exact3leaf/토큰/개행/역치환 보존 PASS.
  volume normal/self14는 같은 원고·baseline을 사용한8c57aa7 결과를 재사용한다.
  EN coverage/Hangul/story-demo3종은 원고3fb9890 결과를 재사용한다.
- 최종 private 원문: `order302-demo-check-year5-after-third.json`
  `f5e9f6a41619a21d1f5f5cfa1bcb3bea3d1adffd392ca83beef9c3df9bce1fca`,
  `year5-self-after-third` `968c49fa227f4cef6674c5a3b77d762bfb52c16213ab64dfca7ec1703e98db25`,
  `preservation-third` `9bb2ac3eef8c97006d7675d77181b3bedeb1a50d72e1a30775ba78233900a334`.
  모두 input1214 전후 동일/exit0/stderr0. 파일명 약칭의 prefix는 `order302-demo-check-`다.
- 도달/상태: static 원문 대조만; gameplay/저장/효과/공개 package 변경0, 새엔진0,
  화면0·입력0. producer=EN reunion3leaf, reader=기존 StoryMode overlay이며 이번에
  실제 화면을 관찰하지 않았다. 포기 손실=오역 지속/과거검사실패, 서사위치=M05
  기존 장면(신규저작0·tier 재판정 없음). 닫는 것=exact 역사 검사 호환만.
- 자동 PASS는 품질 GO가 아니다. 위 GO는 비저자에게 검수받은 이 작업만이며,
  사람·원어민·물리패드·새package·전체게임 판정은 미관측이다.
- 규범 판정: 모두 일회성/기존 WORK_UNIT 보존·위임 규칙 적용, 새 정본 규칙 없음.
  마감 metadata 검사는 후속 WORK_LOG에 별도 기록한다.

## 착수 선언 원문 보존

# Active Queue Spec: ORDER-304

> Canonical status and execution order are indexed in `docs/CODEX_QUEUE.md`.

#### [~] ORDER-304 [표적 QA] 재혁 EN3leaf 수정과 과거 기준선을 구분한다

**2026-09-27 Codex 선언.** ORDER-302 A의 실제3문장 수리 `3fb9890`에서
year5 역사 검사3오류와 volume source hash1오류를 재현했다. 기존 승인·밀도
부채를 없애지 않고 새 문장과 과거 기준선을 정확히 구분하는 일회성 호환 수리다.

## 깊이 3문과 범위

1. 제거 손실: 승인된 영어 오역 수정이 과거 Ch5 객체 변경으로 오인되어 표적 검사가 실패한다.
2. 장기 상태: 원고·플래그·경제·입력·저장·과거 manifest/registry/GO는 그대로다.
3. 경쟁: QA의 historical inverse만 추가하며 현재 원문을 읽는 runtime/현재 volume 관측은 숨기지 않는다.

- 저자 `/root/blackjack_accounting_tests`: `tools/year5_reference_route_audit.py`만.
  exact EN 파일/이벤트/수정 전후 객체 SHA 및3leaf inverse를 최신 역사 projection에
  연결한다. bytes/hash도 exact transition만 허용한다. 다른 값·배열 순서·타입·경로·
  ID 변이는 지우지 않는다. 과거 expected hash/registry는 바꾸지 않는다.
  내장 self-test에 정상·변조·idempotence 경계를 추가한다.
- root: `tools/full_game_volume_baseline.json`의 `source_hashes.graph:en_mapped_immediate`
  한 값만 실제 새 관측으로 갱신한다. `current_report()` 비교에서 나머지 section 및
  observations/allowlisted_findings 동일을 확인했다. 자동 전체 baseline 재생성은 하지 않는다.
- root: 이 사양→`docs/queue_archive/ORDER-304.md`, 큐 두 파일 순번, WORK_LOG,
  생성 STATUS, CLAUDE 현재 행, `docs/agent_review_decisions.json` 새304행,
  독립 보고 정확복사 `docs/agent_reviews/ORDER-304.json`, 새 private
  `.git/full-game-localization/order302-demo-*`/`order304-*` 증거·helper.
- 비저자 `/root/blackjack_accounting_review`: 새 private `order304-review*.json` 및
  302-A 보고. 제품·검사기 저작과 분리한다. 다른 언어 독해는 별도 읽기 전용 보조다.

## 증거와 완료

- 실패 원본 `order302-demo-check-year5-before.json`/`volume-before.json` 보존.
- year5/volume 표적 normal+self-test,3leaf inverse-byte/토큰/개행 및
  baseline 한 hash 외 byte 보존, 기존 부채30·outlier12·HOLD 유지.
- EN coverage/Hangul/story-demo는 동일 원고 `3fb9890`의 기존 PASS 재사용.
- context/queue/audit_select/diff/dashboard 확인 및 실제 source 신원에 결속한 비저자 판정.
- 전체 감사·240주·엔진·화면·사람/원어민·물리패드·외부출시 판정은 하지 않는다.
  ORDER-302 전체는 계속 `[~]`,303은 그 뒤 대기다.
- 모든 추가 지시는 일회성이다. WORK_UNIT의 증거/역사 보존 규칙을 바꾸지 않는다.
