# 성향·관계·생활 칭호의 세 언어 표시

#### [~] ORDER-245 성향·관계·생활 칭호 현지화

[~] 착수 — 2026-09-12, Codex. 기준 main `eb7e2154db7ef1911cd7f7d682b0abdc86530264`.
제품 `fb4cf1195a39c2ec231d2a2731dc4cfaf902de4a`. 일회성20표면/1배치다.
243/244의 exact41e06cd CI는 별도로 진행 중이며 이 배치의 PASS로 가져오지 않는다.

## 단위와 보호선

기존10칭호의 name/desc20표면을 한 배치로 JA·zh-CN·zh-TW 각20문구 번역한다.
steady_youth, elite_course, outsider_title, dangerous_dreamer, my_own_way,
free_spirit, seoul_love, social_king_title, loner_title, stress_survivor가 전부다.
이미 존재하는 KO/EN·50칭호 ID/조건/보너스/저장·기존9번역은 바꾸지 않는다.

깊이3문: 제거하면 이20표면이 비한국어에서 영어로 남는다. 새 선택·24주 상태 변화는
없다. 나머지31칭호와 경쟁하므로 연속된 이20표면부터 닫는다. 1년/5년 영향은
표시와 검증 기반뿐이다. 5년 회고의 조기해금, legacy AP의 free_time_count,
romantic와 상호교제의 차이, 관계5명과 친한친구5명의 차이는 원문 채무로 보존한다.
스트레스 문장은 진단·완치로 바꾸지 않는다. 공개GO1/인간OPEN45/본편HOLD 유지.

## 파일 소유권

- Rawls: `autoloads/MetaProgression.gd` selected10, `tools/ja_translation_pipeline.py`
  새20 registry/실제 current 집계/역사 관측, 신규 `tools/meta_title_locale_successor.py`,
  `tools/chapter1_core_loop_v2_causal_ledger_check.py`의 successor gate/hook.
- Plato: 신규 `tools/meta_title_locale_successor_self_test.py`,
  `tools/MetaTitleLocaleCheck.tscn`, `tools/run_meta_title_locale_qa.sh`.
- Root: `locale/ui_ja.json`, `locale/ui_zh-CN.json`, `locale/ui_zh-TW.json`,
  `content/meta/full_game_localization.json`의 신규60 공식수용,
  `tools/audit.sh`, `tools/audit_scope.json`의 영향검사/역사wrapper 배선.
- Root 운영: CLAUDE, 실행 큐2, active/archive245, WORK_LOG, STATUS, localization backlog,
  `docs/agent_review_decisions.json` 및 `docs/agent_reviews/ORDER-245.json`.
  `docs/history/WORK_LOG_2026-09-12_localization.md`에 기존 WORK 전체를 raw 보존한 뒤
  최신 링크·최근 항목만 현재 WORK에 둔다. 손실·요약 대체 없이 원형 SHA를 결속한다.
- Poincare: 번역60·source/test 전체·실행증거 비저자 검수. 제품 저작 금지.

## 현재 검사와 역사 증거

244 old helper/self18 원형을 재발급하지 않는다. 새 successor는 MP/pipeline 현재
raw를 먼저 검증한 뒤 이번 block과 소수 hook만 역제거하여 5bc/f761을 복원한다.
기존18을 명시적 역사 fixture wrapper에서 실행하고 실제 physical pins와 fixture
pins를 분리한다. 새 current 정상·변조와 실제 Chapter snapshot gate는 별도 검증한다.
243 MainGame helper/new28, 옛 ledger/map/pin, runtime MainGame/GameState/LocaleManager,
human/project·공개manifest·손상된로컬mirror는 raw 보존한다.

사전 recipe/기대는 저작 전에 고정한다. 미작성 current source의 SHA를 미리 관측한
것처럼 쓰지 않는다. 실제 승인 source가 생긴 뒤 첫 실행 전에 exact input을 결속한다.
정상base가 실패한 mutant 거부를 유효 PASS로 세지 않는다.

실제 소비자는 기존100과 신규100을 분리한다. 기존95는 직접 current,5 unselected41
그룹은 신규10 current dictionary 검증 후 name/desc만 역사 관측한다. 미가공 actual을
남기고 기대가 틀리면 실패한다. 원래35함수 중 _run/_unselected 외33과 원래상수·
표본은 보존한다. 새20그룹×5언어와 조건23(참10/거짓13), 해금 A9+B1을 고정한다.
preautoload namespace 격리, actual caller, state/disk 복구, stdout+Godot 오류 검사는
그대로다. 전체 엔딩·렌더·원어민·인간 실플레이 관측으로 부르지 않는다.

## 실행 계획

원문/실제 조건 → 60직접 번역·독립 전량검토 → 현 source/사전/actual fixture →
source 유한군·L1 같은60·actual old100/new100 → 공식 export/check/import →
수용원장 기존38638 역복원·전체 수용 L1 및 영향검사1회 → 독립 단위판정.
예상 신규60→38698/b100은 실제 수용 전까지 예측이다.
이전 CI는 exact243/244 후보에만 묶으며 새source의 성공으로 재사용하지 않는다.
추가 실패 범위는 별도 작은 선언으로 분리한다. 기존 인간 판정 승격/출시 권한0.

## 첫 실행과 잔여 게이트

- 최종 번역표60은 독립 전량 승인(c8b05761), UI3 기존 키 수정0·추가20씩이다.
- 첫 L1 collector는 Path 미정의로 도달0(44e047e0). 새 span 안 import1행만
  수리해 JA173228d3/helper5dc0f6dd로 재결속했다. 재실행60은58통과/2수량오탐
  (c538abdd): 원문 ‘두 길 사이’의 CN/TW 숫자2를 발명으로 오인한다.
  번역은 정확하므로 별도 작은 수량검사 수리를 선언한 뒤 같은60을 재검증한다.
- actual200 첫 실행02c6b566·26.43초·exit0: old100(95current+5history), new100,
  restored1·19입력 전후exact·두 log 오류0. 독립 readback66f2f346 필수0.
- 첫 source self37a134fe는 raw/registry18통과, semantic6은 호출수38가정에서
  미도달, 역사18 실행0이다. 전체 MP에는 기존 get_mastery_label5를 포함해43이
  있다. guard만43/20/23으로 바로잡은 동일24는 전부 통과했고, 별도 역사18도
  통과했다(03648349, 11입력exact). 실패와 사전24 기대는 유지한다.
- 공식 export/check/import·portable 추가60·전체수용L1·최종named·단위판정은
  아직 미실행이다. 수용38638/b99/meta9, 공개GO1/인간OPEN45/본편HOLD 유지.

## 사전 근거

후속 같은60 L1은94836b22/오류0이며, c399f54 exact HEAD에서 공식
export/check/import 각3이 exit0다. UI변경0인 검증된 결과를 수용한 뒤 portable에
신규60만 추가해38698/b100/meta9, 기존38638 raw 역복원 exact를 확인했다.
위 최초 미실행 기록은 당시 관측으로 보존한다. 전체수용L1·최종named11·
독립 최종 단위판정은 아직 미실행이며 본편HOLD는 유지한다.

- private `order244-next-title-history-scope.md`: 87572979ec415372692136a714f8e47b96ad16f9f2208700cc02ca82b2a89af1
- private `order244-next-meta-title-consumer-plan.json`: f615e97c910e3112224a95c24d14ff6fc6e38af429d7b5ed3bfb18c5e1cb476e
- private `order243-next-meta-title-rebinding.json`: 154800a0a5f1a50367ded05244a44f6517e911e743d68e7004227e0749d39f99
