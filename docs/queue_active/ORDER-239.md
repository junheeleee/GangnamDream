# Active Queue Spec: ORDER-239

> Canonical status and execution order are indexed in `docs/CODEX_QUEUE.md`.

#### [~] ORDER-239 [P0·현지화] 관계 이름과 새 관계 로그의 언어를 연결한다

**[~] 2026-09-10 Codex 착수 — 아래 파일만 소유한다.** 기준 clean
`3f13efd60f485d9e6bb267ecaabdca3c35797333`, tree
`6180f255e17752201ad19f332fe3ac43f24aca65`. 기존 관계 표시명21위치/14종의
저장 원문은 유지하고 표시 소비자만 연결한다. 준비 증거는 git-private
`order238-next-relationship-display-preflight.json` 및 `order238-relationship-collector-impact.json`.

## 깊이 3문과 판정 단위

1. 제거 시 결손: 번역된 사건을 골라도 관계 Label·새 로그에는 KO 역할이 그대로 남는다.
2. 24주/5년 상태 차이: 표시 언어만 바뀌며 ID·저장명·호감/신뢰·확률·돈·부모 생사 변화0.
3. 경쟁 대안: gameplay overlay나 저장명 이주 대신 exact 원문→표시 투영을 선택한다.

하나의 소비자 수리다. [첫 실행 재조정] 파일1~3 가정은 runtime+collector 배치와
UI3 배치로 분리한다. 표적은 역할14 + 이 이름을 받는 기존 로그6 =20 원문이다.
JA 기존7 보존·13신규, CN/TW 각각20 KO 직접 신규: 신규값53, 신규수용60 예상이다.
성공 전 이 수를 실적이라고 기록하지 않는다. 검수는 표본 대신20×3 전량이다.

## 정확한 소유권

- Plato: `systems/RelationshipSystem.gd`, `scenes/MainGame.gd`의 표시 함수와
  sidebar/VIP/종료/passive 이름 인수만; `tools/ja_translation_pipeline.py`의 exact14
  현재 inventory 추가(고유키13)와 자기회귀. 역사 manifest/107키/34 migration은 불변.
  `tools/full_game_localization.py`의 exact resolver/caller가 연결된 관계 진단 분리만,
  `tools/full_game_localization_self_test.py`의 새 표적 회귀. 원래 unsupported helper와
  기존 fixture/기대값을 지우지 않는다. 신규·누락·미확인 경로는 계속 unresolved다.
- ROOT: `locale/ui_ja.json`, `locale/ui_zh-CN.json`, `locale/ui_zh-TW.json`의 선택20만.
  `content/meta/full_game_localization.json` 신규60/b1만. 역사 top-level 분모·기존38437·
  b96·metadata9는 보존하고 현재 resolved 관측은 결과에 별도로 둔다.
- Rawls: `tools/RelationshipDisplayLocaleCheck.tscn`(embedded GDScript),
  `tools/run_relationship_display_locale_qa.sh`. 기존 StoryNameplateBootstrap와 격리
  storage/process helper는 읽기 재사용하며 원본 수정0. Godot 전 pre-autoload namespace,
  실제 post namespace, 시간제한·프로세스 종료·오류 양쪽 로그·exact marker를 검증한다.
- ROOT 운영: `tools/audit_scope.json`, `CLAUDE.md`, `docs/CODEX_QUEUE.md`,
  `docs/CODEX_QUEUE_L3_PENDING.md`, 이 사양과 `docs/queue_archive/ORDER-239.md`,
  `docs/WORK_LOG.md`, `docs/history/WORK_LOG_2026-09-07_localization.md`,
  `docs/STATUS.md`, `docs/queue_backlog/FULL_GAME_LOCALIZATION.md`,
  `docs/agent_review_decisions.json`, `docs/agent_reviews/ORDER-239.json`.
- 사적 준비·검사·검수: `.git/full-game-localization/order239-*` 및 공식 도구가 정한
  이번 source/target batch receipt만. Poincare는 비저자 전량 의미·최종 품질 검수.

## 원문과 안전선

가족, 강남 인맥, 부모님, 사업 파트너, 새벽 통화 친구, 소개팅 상대, 썸 상대,
업계 지인, 옆방 이웃, 인생 멘토, 전 연인, 직장 선배, 친한 친구, 카페 단골 친구.
같은 parents_family라도 부모님/형/사별 뒤 어머니가 다르다. ID/생사 flag로 이름을
재추론하지 않는다. exact14 외 custom·기번역·빈값·부분일치·공백은 그대로다.
카페 친구는 실제 직원이며 새 단골손님/점주·동거·상사·확정연애/재결합을 만들지 않는다.

기존 로그6은 관계 종료1·passive4·VIP 유인1이다. CN/TW 부모 템플릿도 번역해
영어 문장+번역 이름을 완성이라고 세지 않는다. affinity5·누락명 fallback2·빈 VIP
등 나머지 표면은 이번 번역 분모 밖이다. 기존 로그를 소급 재번역하지 않는다.
legacy VIP/AP는 격리 함수 호출 회귀이며 플레이 노출/반복 행동판 부활이 아니다.

KO3파일·12 event overlay·GameState/LocaleManager/DataRegistry/SaveManager·폰트·
project/SHIPPING_LANGUAGES·플레이어 저장·공개 M01~M06·인간 원장은 비소유다.
공개 GO1/인간 OPEN45/본편 HOLD, native/render/play/physical 관찰은 별도로 유지한다.

## 실행·증거 순서

1. 선언 commit/push 뒤 Rawls는 별도 승인 기대표와 기존 효과를 코드 전 고정한다.
   runtime/collector를 먼저 checkpoint하고 아직 UI를 건드리지 않은 상태에서
   공식 initial20×3 export한다. 신규13키가 없던 이전 원문 batch를 만들지 않는다.
2. ROOT가 KO 직접53값을 저작, Poincare가 기존7 포함60을 소비자와 전량 대조한다.
   첫 L1 진단과 실패를 보존한다. 새로운 validator 오탐 수리는 별도 선언 전 변경0.
3. actual Label/VIP/종료/passive5·5언어, exact/custom/shared-ID·생사·최초이름·
   언어전환·메모리 save roundtrip을 격리 검사한다. 표시 함수는 상태 불변,
   실제 효과 함수는 기존 수치/확률 흐름 보존을 따로 비교한다. 렌더 품질 GO가 아니다.
4. 동일 최종본문/소스로 final export/check/import 및 portable 신규수용을 결속한다.
   기존38437 hash+원형과 선택 밖 UI raw를 보존한다. 관련 collector 자기회귀와
   한정 차선1회, 전체수용 hash/L1 1회. 전체감사·240주·패키지 재빌드·공개출시0.
5. 결과 포함 exact source에서 비저자 최종 판정 후 metadata wrapper만 마감한다.
   완료228/229 원문은 history로 raw 이동해 WORK40000B 한도를 확보하고 역복원한다.

규범 승격 없음: 기존 I18N/WORK_UNIT 적용, 이번 파일·표본·절차는 일회성이다.
