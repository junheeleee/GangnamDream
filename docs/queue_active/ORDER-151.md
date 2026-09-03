# Active Queue Spec: ORDER-151

> Canonical status and execution order are indexed in `docs/CODEX_QUEUE.md`.

#### [~] ORDER-151 [P0·화면 정합] M54 현재 집·기간, W224 편의점, 카지노 숙박 제안의 실제 맥락을 맞춘다

**[~] 2026-09-03 Codex 착수 — 만지는 파일은 아래 소유권만.** 기준 제품은
`236d8eb2c532172c60da3fafce0fc1b768e38049`, 검토 wrapper는
`af511eea06d7435aea833b0a72307bf85572c300`이다. 사용자 전달 기록은
**Codex 화면 관찰: Property REJECT / General REJECT / 전체 HOLD**이며 독립
인간 인증이 아니다. 자동 검사·이전 후보의 인간 GO를 이 관찰에 합산하지 않는다.
원문과 제한은 `docs/DEMO_FIXLOG.md`의 2026-09-03 항목이 소유한다.

## 깊이 3문

1. **신혼집 resolver를 다시 바꿔야 하는가?** 아니다. M54 `age_39_final`에
   배경이 없어 경제 주거값으로 추정하는 것이 원인이다. 실제 집을 명시하는
   `current_housing`을 사건에 붙이고 경제 주거·이혼·저장 규칙은 보존한다.
2. **카지노 소개를 받았으면 오늘 이용했다고 써도 되는가?** 아니다. 그 플래그는
   현재 방문·베팅을 증명하지 않는다. 원래 코드의 선택 효과는 마음·중독 성향뿐이며
   숙박·베팅·손실 영수증이 없다. 현재 집에 도착한 숙박 안내와 민준의 답장으로
   좁히고, 두 기존 callback도 제안에 보인 관심/사양만 회수하게 한다. 새로운 방문
   시스템이나 확정 예약·이동·베팅·금전 손실은 만들지 않는다.
3. **M54를 뒤로 옮겨 반년을 맞출 것인가?** 아니다. 같은 M54 진입과 HUD를
   유지하고 기본 도입·다섯 변형·선택·결과를 이번 달 포함 일곱 달로 정렬한다.

## 표적 단위와 보존선

- `age_39_final`: 현재 집 배경, M54 일곱 달. 고정 24주·반년 표현 제거. 첫 선택의
  투자 계획 입력은 실제 체결 없는 현재 효과와 일치시킨다. 선택 수·index·효과·
  완료 flag·milestone ingress는 그대로다.
- `arc_y5_father_trace_custody`: 편의점 배경·장소·생활음을 함께 맞춘다. 두 원장
  영수증, 다은에게 사본만 전달하는 범위, 미전달 갈래는 byte 보존한다.
- `casino_comp_offer`: 과거 소개 후 현재 집에 받은 비개인화 숙박 안내. 두 선택은
  사양 또는 가능한 날짜 문의이며, 답장의 발신만 성립한다. 결과까지 현재 집이고
  카지노 이용·예약 확정·여행·칩 교환·손실을 대신 실행하지 않는다.
- `callback_casino_{declined,accepted}_comp_echo`: 기존 플래그의 공통 사실인
  제안에 대한 태도만 회수한다. 옛 저장에도 새 카지노 방문을 합성하지 않는다.
- 공개 `story_demo_rc` M01~M06 BUILD `2026.08.31.1`와 번역/패키지 바이트,
  `project.godot`, M55 블레이저·무초상, W207/W230, W237 삼십 분,
  W240 실제 삭제·같은 밤 선발신, 아버지 기억·민서 원격, 지갑 동의 세 root,
  30억 즉시엔딩·경제식·엔딩·원본 slot 01·02는 비소유다.

## 정확한 파일 소유권

- 제품 KO/EN: `content/events{,_en}/{story_events,gambling_narrative,callback_events_50}.json`
  위 exact root만, `content/events/arc_year3_drama.json` custody 배경만.
- 연출 계약: `content/meta/{story_rules,exposed_event_state_contracts}.json`,
  `assets/{event_visual_contracts,scene_audio_manifest,scene_direction_manifest}.json`의
  위 root에 해당하는 항목만. 새 자산·새 root·새 flag·공통 런타임 변경은 없다.
- 회귀: `tools/{chapter5_human_reject_audit.py,Chapter5HumanRejectCheck.gd,
  StoryPlaybackCheck.gd}`. 실제 StoryMode 도입·결과 문단·KO/EN·미혼/결혼/이혼을
  검사한다. 기존 resolver 단독 PASS로 이번 화면 수리를 대신하지 않는다.
- 파생 영수증: `content/meta/{release_content_inventory,demo_localization_scope}.json`,
  `docs/CONTENT_RATING_INVENTORY.md`,
  `tools/{year5_reference_route_audit.py,chapter1_core_loop_v2_causal_ledger_check.py,
  full_body_translation_scope.py,full_game_volume_baseline.json}`의 현재 실측 hash와
  source observation만. 역사 원장·수량·밀도 기준선을 완화하지 않는다.
- 프로토콜: 이 사양, `docs/{CODEX_QUEUE,DEMO_FIXLOG,WORK_LOG,STATUS}.md`,
  `docs/human_gates.json`, `CLAUDE.md`. 오래된 WORK_LOG는
  `docs/history/WORK_LOG_2026-08-26.md`로 손실 없이 이동할 수 있다.

## 검증과 다음 판정

L1은 변경 범위 감사·한영·정합·후속 의미 독자·배경/기간 mutation을 검사한다.
L2는 실제 StoryMode로 모든 결과의 배경/생활음/기간을 확인하고 새 exact RC 발급
전 전체 감사를 실행한다. 이는 모두 회귀 증거이며 인간 플레이를 대신하지 않는다.

`chapter5_finale_rc`는 수리 중 `waiting_rebuild`였고 아래 새 제품 등록 후
`active`다. 후보 식별자일 뿐 GO가 아니며 두 사람 gate는 OPEN,
full·main·product는 HOLD다. 지갑 사양 후 무약속·무동석·무식당은 af511ee 화면
관찰 통과이며 수락 결과는 **미관찰**이다. 제품 커밋과 런타임 diff 0인 docs-only
직계 자식 review HEAD를 새로 봉인한 뒤, 두 경로 M49→M60→후일담→6/6 정상 속도
재플레이와 지갑 수락 결과의 별도 실제 관찰을 요청한다. 최종 사용자 GO 전에는
완료·main 승격·독립 인간 인증을 선언하지 않는다.

## 수리와 회귀 증거 — 2026-09-03

- 7개 사건 파일의 exact 9개 KO/EN 객체만 변경했다. custody는 KO 배경 한 값만
  바꾸고 원문·두 선택을 보존했다. 나머지는 원문/표현만 바뀌며 gameplay projection은
  선언 커밋과 같다. scene direction은 카지노 제안 한 root만 `explicit_move`에서
  `remote`로 옮겼고 demo localization scope는 바이트 불변이다.
- M54의 실제 HUD 7과 모든 기본/조건부 도입·결과가 일치한다. 경제 주거를 덮지
  않고 완결 결혼의 신혼집, 미혼/이혼의 현재 집을 실제 StoryMode에 표시한다.
- 카지노 소개 플래그는 오늘 이용·베팅의 증거가 아니므로 비개인화 안내로 좁혔다.
  두 결과는 발신만 만들며, 옛 저장에서 읽는 두 callback도 거절/관심이라는
  공통 사실만 회수한다. 조건을 뒤로 미뤄 결함을 숨기지 않았다.
- Chapter 5 정적 self-test **50**, 최초 변경 도구의 표적 감사 **6**, 실제 StoryMode
  **156 fixtures / 1,044 sequential pages**, KO/EN×미혼/결혼/이혼이 GREEN이다.
  기존 지갑 수락→도착/거절→무도착 테스트는 그대로 통과했다.
- 전환 분류까지 교정한 최종 StoryPlayback 로그는
  `/private/tmp/gangnamdream-order151-story-final.PMPkTY/{target,full,render}.log`,
  별도 OpenGL 1280×800 렌더 32장은
  `/private/tmp/gangnamdream-order151-rendered-final.n1qFlf`다. M54 신혼집,
  W224 편의점, KO/EN 카지노 도입·결과가 일치하며 성공 marker와
  script/parse/engine 오류·누수 0을 함께 확인했다. 이는 L2이고 인간 인증이 아니다.
- 최초 전체 감사 `gangnamdream-order151-audit.OphqT6/full-audit.log`는 전환
  매니페스트 갱신 누락을 발견한 **실패 증거**다. 제공 생성기로 카지노 한 root의
  분류만 고쳤다. catalog self-test 2, year5 self-test 222(9객체/12제품 파일),
  정확 과거 상수 448개 보존과 표적 화면 재검증이 통과했다. 첫 프레임 제한 중단의
  불완전 캡처 `gangnamdream-order151-shots.QcLxAg`도 PASS 증거로 쓰지 않는다.
- 로드된 KO/EN DataRegistry의 실제 `remote` 분류도 검사했다. 최종 별도 로그
  `/private/tmp/gangnamdream-order151-direction-positive.MdWu4b/{stdout,runtime}.log`는
  성공 marker·종료 0·오류/누수 0이다. 테스트 안에서 새 process-local QA 저장
  공간을 먼저 만들며 full-mode·실제 프로젝트 설정·원본 저장은 바꾸지 않는다.
- 교정 후 최종 전체 감사
  `/private/tmp/gangnamdream-order151-audit-final.4EA6Sn/full-audit.log`는 종료 0과
  `✅ 감사 통과`다. 68-script compile, Chapter 5 50·year5 222·인과 원장 481건과
  실제 로드된 장면 전환 분류까지 통과했다. 통합 감사의 기존 종료 자원 경고 허용
  정책은 바꾸지 않았다. 표적 테스트의 오류·누수 0은 통합 전체의 경고 0 선언이 아니다.
- 아래 새 제품 커밋을 docs-only 직계 자식 검토 후보로 등록한다.
  두 경로의 정상 속도 전체 재플레이 및 지갑 수락 실관찰은 여전히 OPEN이다.

## 새 exact source-checkout 후보

- 브랜치: `codex/order151-chapter5-scene-context`
- 제품 commit: `2f91f4265613e57c8e3aaf34ab4f7f0971699f92`
- 제품 tree: `0c36eac8a45430c726c5e8d4812c1217918db3b1`
- source manifest SHA-256: `fabfcbe47a861ba37b3221c122fe8beab09499a8712b2ef8621944b3e7a2b89e`
- 이 신원을 등록한 review wrapper는 제품의 문서 전용 직계 자식이다. 실제 검토에는
  별도로 전달한 정확한 review HEAD를 사용하고, 부모가 위 제품인지와 런타임 diff 0을
  확인한다. wrapper의 전체 tree는 제품 tree와 다르므로 두 신원을 혼용하지 않는다.
- 새 설치 패키지·BUILD_ID·공개 M6 버전을 발급한 것이 아니다. 기존 설치 앱이나
  사용자 작업 중인 main에서 이 수리가 반영됐다고 가정하지 않는다.

## 재플레이 인계의 일회성 주의

- 후보의 `commit/tree/manifest_sha256`은 제품 부모의 신원이다. source manifest는
  `git ls-tree -r --full-tree <제품 commit> | shasum -a 256`으로 산출하며 패키지
  artifact manifest가 아니다. review HEAD는 `CLAUDE.md`·`docs/**`만 바꾼 직계
  자식이어야 한다. 제품 신원 검사와 wrapper의 부모·런타임 diff 0 검사는 분리한다.
- 검토 checkout은 별도로 전달한 review HEAD와 정확히 같고 clean이어야 한다.
  저장 파일의 `source_commit`은 실행 바이너리/checkout 신원이 아니다. 기존 W193
  두 seed의 `83d3f350…` 출처는 그대로 두고 새 제품 신원으로 덮어쓰지 않는다.
- `investment_property_daeun` slot 01 원본 SHA-256은
  `7239040565920fcb2ffad0d606078ce9a436c8ae2ddd5fd2ed29542ff83bd3af`,
  `general_near_goal_father_passed` slot 02는
  `5f4b5a0f6842e8ac726ee45b3c361ad1a45dc6c665c89009fe812acec5cf6aa8`다.
  두 원본은 수리 후에도 불변임을 다시 확인했다. 새 플레이는 별도 저장 공간의
  복사본만 사용하고 두 프로세스를 함께 실행하지 않는다.
- 각 경로는 정상 독해 속도·개별 UI 입력으로 M49→M60→후일담→6/6까지 기록한다.
  카지노나 지갑 수락 결과를 못 봤다면 미관찰로 남긴다. 직접 이벤트 호출·자동
  넘김·정적 원고 확인을 그 실제 관찰로 대체하지 않는다.
- 이번 렌더 QA에서 `--quit-after`는 초가 아니라 프레임 한도였다. 캡처를 재현할
  때는 `--max-fps 60`과 충분한 프레임 한도를 함께 줘 조기 종료를 PASS로 오인하지 않는다.

**규범 소유권:** 현재 집·채널·장소·미확정 사실 경계는 기존
`STORY_CONSISTENCY_SYSTEM.md`/`story_rules.json` 정본을 적용한다. 위 후보 신원,
파일 소유권·재검증 절차는 이 수리의 일회성 지시다.
