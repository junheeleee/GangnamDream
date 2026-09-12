# 미니게임 칭호 9종 세 언어 현지화

#### [~] ORDER-250 미니게임 칭호 번역

[~] 착수 — 2026-09-12, Codex. 아래 clean 검토 HEAD에서 로컬 선언한다.
248/249 최종 보고서 작성과 겹치는 동안 private 저작·계획만 병행하고,
그 두 단위의 보고서 마감 뒤 소유 제품을 적용한다. 원격247 두 실행은
exact07ef에서 SUCCESS로 종료했으며, 이 새 후보의 CI로 빌리지 않는다.
사전 관측 source는 `72169bdec241c7574c939b32b097b71694562915`,
tree `cebe503ba69f1f1b3d5e1f055090e040099e7abc`이며 검토 HEAD는
`03c26aaac20262987d4f2871e6c9cdf718e15a4a`다. 두 신원을 혼동하지 않는다.
현재 MP 59337B/afe8bda8 원형을 다음 단일 단계의 이전 바이트로 삼는다.
근거는 private `post248-minigame9-next-scope.json` 16817B/8ed9fb58과
`post248-minigame9-preflight.json` 19603B/51b55853이다. 최종 핀은 선언 때 재결속한다.

## 모집단·진행량

선택 ID는 `holdem_master_title`, `racetrack_master_title`,
`scalping_master_title`, `baccarat_master_title`, `blackjack_master_title`,
`slot_master_title`, `roulette_master_title`, `bigwheel_master_title`,
`daisai_master_title`이다. name/desc 18표면을 KO에서 JA/CN/TW로 직접 저작한다.
18 KO/EN source-pair SHA:
`759bf62c168586e4209520e4e1a876ee6537a832d9de40070d73941dfcfebf8f`.
현재 세 언어 UI 값과 literal 수용54는 모두 부재다. 공식 source/protection은
새 lookup 후 collector로 확인하며, 미리 추정한 leaf 수를 실측으로 쓰지 않는다.
현 수용38764/b101/meta9(JA12920/CN·TW12922)와 기존 UI 원형을 보존한다.
신규54가 모두 수용된 뒤에만38818/b102/meta9(JA12938/CN·TW12940)로 갱신한다.
칭호 현지화는 기존30→39이며 다른11칭호·상위 UI 부모 번역은 이번 범위 밖이다.
깊이3문: 없으면 이9종은 EN 폴백이다. 선택·24주·1년/5년·저장 상태는 변경0.
남은 전체 UI 대신 실제 소비자까지 검증 가능한 이18표면을 단일 단위로 닫는다.

## 원문·조건·마스터리 경계

KO/EN 원문18과 실제 조건9는 바꾸지 않는다. 8종은 counter>=15, slot만>=20이다.
원문 단위 채무7은 별도 유지한다: holdem/racetrack/baccarat/blackjack의
판·경주·라운드·핸드 서술과 세션 집계, roulette/bigwheel/daisai의
매 결과+유효 종료1 집계다. 슬롯777 회상은 counter20이 보장하지 않는 별도 채무다.
scalping15는 완료 게임 수이며 개별 매매 수가 아니다. 1분 문구로 조기 종료를 숨기지 않는다.
2.7%는 하우스엣지 근사,45:1은 배당 비율,세 개는 주사위3개다. 원화로 변환하지 않는다.
승리·상대 읽기·중단 불가·기본전략 비유를 새 성공 조건이나 의학적 진단으로 강화하지 않는다.
마스터리[0,5,15,30]와 칭호 획득은 별개다. 15/20의 칭호는 grade2이며 grade3는30이다.
칭호 보너스·등급 효과·producer9·게임 규칙·ID·세이브는 원형이며 번역문에 효과를 보태지 않는다.

## 소유권

- Rawls: `autoloads/MetaProgression.gd`, `tools/ja_translation_pipeline.py`,
  `tools/meta_title_locale_successor.py`, `tools/chapter1_core_loop_v2_causal_ledger_check.py`.
  새9 lookup18·단일 successor 단계·명시 역사 hook만 소유하며 번역54 초안은 private로 저작한다.
- Plato: `tools/meta_title_locale_successor_self_test.py`의 새 current 대조와
  기존19/24/18 원형을 유지하는 명시 역사 관측 배선. 먼저 정상·유효 변조·OFF를 고정한다.
- ROOT: `tools/MetaTitleLocaleCheck.tscn`, `tools/run_meta_title_locale_qa.sh`의
  기존310 보존·신규95 실제 소비자; `locale/ui_ja.json`, `locale/ui_zh-CN.json`,
  `locale/ui_zh-TW.json`의 승인54 추가; `tools/audit_scope.json`의 영향 차선;
  `content/meta/full_game_localization.json`의 공식 수용. 제품 소유는 합계12파일이다.
- ROOT 운영: CLAUDE·큐2·본 active/archive·WORK_LOG·STATUS·현지화 backlog·
  agent_review_decisions·agent_reviews/ORDER-250.json. 선언·큐·Git·공개 쓰기는 ROOT만 한다.
- Poincare: 언어54·소스/검사 코드·실행 증거·최종 source의 비저자 독립 검토.

## 현재 원형 우선·역사 관측

새 actual whole raw를 먼저 검증한 뒤 새9 단계를 역변환하여 현재248 원형으로 돌린다.
그 뒤에만 기존248→245→244 역사 관측을 연결한다. 과거 raw를 현재로 허용하지 않는다.
registry·중간 핀·추가 LF·잘못된 owner/EN/API·누락/중복·위조 hash는 고정 대조로 거부한다.
JA 실제 calls/stats를 보고하며 옛 수치로 덮지 않는다. 새18 lookup은 공식 실측 전 예상이다.
구 helper/함수/상수와19/24/18 기대를 다시 발급하지 않고 작은 한 단계와 outer hook만 추가한다.
`audit.sh`,249 검사기2,구244 helper/self,MainGame/GameState/LocaleManager,
조건·producer·assets/fonts·project·공개 manifest·인간 원장은 변경0이다.

## 실제 소비자·모집단

기존 old100/NEXT100/A11 110의 ID와 기대 원형을 보존한다. 보존군5+5+5에만
새9 전체 current dictionary를 독립 기대와 먼저 대조한 뒤 name/desc만 역사 투영한다.
실패하면 actual을 그대로 돌려 거부한다. 구310은295 direct+15한정 history로 구분한다.
신규는 getter9×5=45와 의미그룹10×5=50의95다. 총405이며100 맞춤 분할은 하지 않는다.
의미그룹은 비선택41,unknown/custom,잠김/해금 도감,조건·마스터리,
해금 반환·중복,toast+log,월간 component toast/log0,ending cache,언어·저장이다.
8종14/15/29/30 및 slot19/20/29/30의36벡터×5=180은 nested이며 그룹 수에 더하지 않는다.
각 벡터의 칭호 조건과 등급을 함께 확인한다. 새 그룹 ID·내부 관측 수를 구현 전에 봉인한다.
초기화·실제 refresh 뒤 before를 잡고 독립 expected/after/delta·디스크·입력 핀을 보존한다.
잠김은 기존 미발견 이름/빈 desc다. false 알림도 해금·toast는 유지하고 game log만0이다.
언어 변경 후 재취득/reopen과 이미 저장된 ending 캐시를 구분한다. 사용자 저장은 읽지 않는다.
기존 preautoload 격리·namespace·process 종료·stdout/stderr/Godot log·복구 경계를 재사용한다.

## 검증·마감·원격 경계

선언 후 pre-code source 대조·소비자 roster·언어 기대를 먼저 고정하고 독립 검토한다.
source-only clean checkpoint에서 공식 collector/export18×3·hash·보호집합·초기 핀을 봉인한다.
쉼표와45:1이 KO 키에 있으므로 JSON leaf-ID 목록/공식 owner·path를 쓴다. 콜론 분해로 추정하지 않는다.
승인54 적용 후 같은54 첫 L1을1회 실행하고 실패·stdout/stderr·전후 핀을 전량 보존한다.
새 원인이 발견되면 이 선언의 기존 기대를 완화하지 않고 별도 작은 단위로 분리한다.
현재 UI/source 동결 뒤 공식 final export/check/import와 신규54/기존38764 raw 역복원을 검증한다.
전체 수용 L1·영향 명시 차선·새 source/기존 역사 회귀·격리 old310+new95는 ROOT가 실행을 조율한다.
최초 실패와 수정 후 결과를 분리하며 입력이나 모집단을 통과용으로 줄이거나 정상 기대를 역작성하지 않는다.
로컬 full audit·240주·무관한 전체 회귀는 추가하지 않는다. 실제 실행을 중복하지 않는다.
기존247 CI는 immutable07ef의 별도 원격 증거이며 새 source의 CI 통과로 빌리지 않는다.
로컬 선언 뒤 소유 작업·표적 검증은 진행하되 관련 원격 실행의 terminal 확인 전 refs/push는 보류한다.
이미 종료된 실행을 새 대기 상태로 기록하지 않는다. 동기화와 새 원격 결과 판정은 ROOT가 맡는다.
최종 exact source·공식 수용·독립 단위판정 후 마감한다. native/render/인간플레이·본편GO는 별도다.
공개GO1·인간OPEN45·본편HOLD를 유지한다. 이 제한은 이번 작업의 일회성 사양이며 새 규범이 아니다.
