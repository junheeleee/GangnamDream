# ORDER-458 — 코인 권유 통화의 자산·원격 지식 정합 수리

#### [~] ORDER-458 [P1·사실 수리] 두 사건·3문구·5언어

**[~] 착수 — 2026-10-05.** 457 실제 General W193→W195 독해에서
29.3억/97%인데 목표까지 까마득하다는 독백, 음성 통화 상대의 표정/얼굴을
직접 본 듯한 지문, 후속 통화 배지 소실을 확인했다. 457은 완료가 아니다.

## 범위·소유

- claude_handoff_review: `content/events/amb_scenarios2.json`,
  `content/events_en/amb_scenarios2.json`의 `amb_coin_00.description`,
  `amb_coin_00.choices[2].result_text`, `amb_coin_warn.description`만 작성한다.
  `content/meta/story_rules.json`에 후속 `amb_coin_warn`의 기존 통화와 동일한
  phone/local-player presentation을 선언하되 player_tired를 보존한다.
- root: 공식 export/check/import를 통한 `content/events_ja/amb_scenarios2.json`,
  `content/events_zh-CN/amb_scenarios2.json`, `content/events_zh-TW/amb_scenarios2.json`
  같은3문구와 `content/meta/full_game_localization.json`의 새 교정 receipt9개,
  `assets/event_visual_contracts.json`의 amb_coin_warn 기존 background/portrait 고정1행,
  파생 `assets/scene_direction_manifest.json`, 큐/L3·CLAUDE·이 사양/보관·457진행·
  WORK_LOG·생성STATUS·agent_review_decisions를 소유한다.
- receipt_tests392: 비제품 `.git/chapter5-replay/order458*` 표적 준비 fixture/실행기만
  작성 가능하다. 제품·기존 QA 수정/실행은 하지 않는다. root만 프로젝트 실행한다.
- independent392: 전체 변경 원문·준비 화면/검사 증거를 직접 검토하고 마지막
  `docs/agent_reviews/ORDER-458.json`만 작성한다. 인간/원어민 관찰로 기록하지 않는다.

## 수리와 불변선

현재 자산과 무관하게 원래30억 목표를 떠올리는 문구로 고친다. 감정은 들리는
목소리로만 전달하고, 실제로 이어지는 음성 통화를 후속 presentation에 명시한다.
금액 조건 분기·사건/선택/효과/확률/플래그/후속 라우팅·제목·자산·오디오 변경0이다.
번역은 한국어에서 각 언어로 직접 작성하고 token/수치/문단을 보존한다. 기존 target
hash에 결속한 공식 `--replace-existing` 교정으로 기록하며 coverage 증량은0이다.
공개 데모·인간 원장·원본seed2·실제player34·457의 새W195checkpoint는 변경하지 않는다.

## 검증과 완료

첫 story-consistency 검사에서 새 expected_background의 대응 visual계약 누락1건을
확인했다. 기존자산을 고정하는 위1행은 phone수리의 필수 의존이며 별도 선언커밋 뒤
추가한다. 검사완화/신규자산/오디오변경은 하지 않는다.

1. 3leaf×5언어 exact semantic diff, gameplay불변, story-consistency/scene-direction,
   영어 coverage, 공식 export/check/import와 현재 코퍼스 기본 검사를 사용한다.
   새 checker/인프라를 만들지 않고 기존검사/일회성 prepared fixture를 재사용한다.
2. KO/EN 실제 StoryMode에서 두 root 설명·경고 결과·후속 두 결과를 표적으로 확인한다.
   낮은 자산과97% 상태 모두에서 목표 문구가 모순 없고 phone배지/local초상/같은배경을
   유지하는지 본다. 이 직접 준비 검사는457의 정상 플레이나 전체경로 완료가 아니다.
3. root 실제화면 관찰 + 비저자 원문/증거 한정판정, candidate/receipt/증거 SHA 결속,
   context/queue/diff. 456·302·whole audit·240주·Property를 반복하지 않는다.
   미관찰 경로/원어민/인간/물리패드·본편/새package HOLD를 그대로 남긴다.

### 검사 비용 관측 뒤 표적 재선언 — 2026-10-05

처음 선택한 `full-game-localization-overlays`11행은 변경하지 않은 검사 도구의
역사 변이 self-test를 포함했다. 첫 `full_body_translation_scope.py --self-test`가
1315.966초 동안 미완료여서 root가 SIGINT로 중단했다(exit−2). 원로그는
`.git/chapter5-replay/order458-localization-lane.log`에 보존하며 PASS가 아니다.
뒤10행은 미실행이다. 검사코드·정본·스키마를 바꾸지 않은 이번3문구 교정에서
역사 변이의 반복 전체 증명을 재검증하는 대신, 다음 현재 데이터 검사를 먼저 선언한다.

- `python3 -B tools/full_body_translation_scope.py` — 현재 source/closure/protection 기본 검사1회.
- `python3 -B tools/audit.py` — 현재 사건/효과/플래그 구조.
- `python3 -B tools/i18n_coverage_check.py` — 현재5언어 overlay 구조/토큰/수치.
- 마감 metadata의 context/queue/판정원장/diff 검사.

이미 통과한 공식9교정의 receipt/header/token/문단, 15leaf exact 변경 및
비소유 전체바이트 역상, story-consistency/scene-direction/visual/EN,
KO/EN24페이지·16PNG·8선택과 비저자 전수 독해는 그대로 결속한다.
새 checker·새 차선·감사 완화0이며 미완료 self-test를 성공으로 바꾸지 않는다.
이 일회성 범위 조정은 사용자가 위임한 효율적 검수에 따른 것이며,
현재 데이터 검사에서 실패하면 수리/추가선언 전까지 완료하지 않는다.

이 수리가 없으면 현재 자산과 음성 통화의 지식 범위가 매 재노출마다 모순된다.
새 선택을 만들지 않으므로24주 후 상태·선택 경쟁은 기존 그대로다. 서사 위치는
ambient coin warning2root, 계층 증량0, 닫는 선택0이다. 기존 통화 정합 규칙 적용이며
범위·파일 소유·표적 절차는 **일회성**이다.
