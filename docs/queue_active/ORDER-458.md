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

1. 3leaf×5언어 exact semantic diff, gameplay불변, story-consistency/scene-direction,
   영어 coverage, 공식 export/check/import와 지정 full-game-localization-overlays 차선.
   새 checker/인프라를 만들지 않고 기존검사/일회성 prepared fixture를 재사용한다.
2. KO/EN 실제 StoryMode에서 두 root 설명·경고 결과·후속 두 결과를 표적으로 확인한다.
   낮은 자산과97% 상태 모두에서 목표 문구가 모순 없고 phone배지/local초상/같은배경을
   유지하는지 본다. 이 직접 준비 검사는457의 정상 플레이나 전체경로 완료가 아니다.
3. root 실제화면 관찰 + 비저자 원문/증거 한정판정, candidate/receipt/증거 SHA 결속,
   context/queue/diff. 456·302·whole audit·240주·Property를 반복하지 않는다.
   미관찰 경로/원어민/인간/물리패드·본편/새package HOLD를 그대로 남긴다.

이 수리가 없으면 현재 자산과 음성 통화의 지식 범위가 매 재노출마다 모순된다.
새 선택을 만들지 않으므로24주 후 상태·선택 경쟁은 기존 그대로다. 서사 위치는
ambient coin warning2root, 계층 증량0, 닫는 선택0이다. 기존 통화 정합 규칙 적용이며
범위·파일 소유·표적 절차는 **일회성**이다.
