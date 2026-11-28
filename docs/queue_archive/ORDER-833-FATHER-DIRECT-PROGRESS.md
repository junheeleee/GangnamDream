# ORDER-833 — W188 선택 한 번·구 저장 보존

## [~] 2026-11-22 착수 선언

기준 `c77d2a671cd1bc874d8f167a8ca4ae0eace4b58b` / tree
`c9c5f1df7d84a9b81a349558a5dbd5bd24fac196`. 사망시각5언어 수리는 정상push,
임종P0 전체는 아직 미완이다. 열린 Claude PR22는 문서2파일로 이 범위와 겹치지 않는다.

### 정확한 소유권 — 19경로

- `scenes/StoryMode.gd`: 정확 두 middle의 live노출/직접진행·원래index2 입력과
  KTX 결과 컷만. 이미 적용된 구0/1 결과 복원과 read-only snapshot은 보존한다.
- `content/events{,_en,_ja,_zh-CN,_zh-TW}/arc_drama.json` 5개: platform/deal_room
  도입2·새 index2 text/result 각2만5언어. 옛0/1 객체와 기존kind/edge/값 불변.
  새2는 기존 non-expression 기록으로 terminal만 잇고 효과/flag/예약은 넣지 않는다.
- 추가 선언: root choice1의 `text_if_moral.white` 한 leaf도5언어로 정정한다.
  ‘아직 결정을 미룰 수 있다’는 중간 재선택 제거와 충돌하므로 실제 거래진행과
  거래 뒤 병동연락 의도로 맞춘다. root기본text/kind/edge·효과/저장역사 불변.
  공식review2 6×3은 이미수용완료라 다시검사하지 않고 새1leaf×3만 별도교환한다.
- `content/meta/full_game_localization.json`: KO독립6leaf×3 공식 교환·현재/옛수용.
  CJK 배열에는 빈object1만 먼저 확장해 정식export한다. 임시번역·검증기수정0.
- `tools/{chapter4_causal_route_audit.py,peak_scene_chain_audit.py,scene_audio_contract_check.py,
  StoryBackgroundContextCheck.gd,ManualSaveCheck.gd}` 5개: 옛4경로 보존·신규2경로의
  실제 visible=[2]/힌트/효과·receipt/후속·KTX/cold/hot/손상거절을 강화한다.
- `content/meta/release_content_inventory.json`, `docs/CONTENT_RATING_INVENTORY.md`:
  바뀐원문 현행지문만. 역사패키지·내용분류/등급·설문은 그대로다.
- `CLAUDE.md`, `docs/WORK_LOG.md` 같은KST항목,
  `docs/queue_active/ORDER-833.md`, `docs/CODEX_QUEUE.md`, 이 파일 5개.

### 계약과 검증

한 체인 T1, 현재주거→승강장/회의실→빈병실/통화의 기존 전용자산·연출/음향을
유지한다. 병동 대 거래는 root에서만 고른다. 다음 middle은 선택한 곳의 감각·비용을
겪고 Enter/클릭으로 넘어가며 선택 레일을 다시 열지 않는다. 화면의 단일 가짜 선택0.

구 middle0/1은 저장 호환 원본이다. 물리삭제/재번호화/edge변경/receipt재작성0.
새2는 실제index2로 적용·기록해 기존 FullStoryFlow 검증을 그대로 거친다.
expression으로 바꾸면 events_seen/그 독자가 달라지므로 쓰지 않는다. FullStoryFlow,
GameState, SaveManager, savekey/형식·의료2-of-3·deathwriter/terminal효과/500만원 불변.

신규 root2갈래×5언어, old0/1 live직접호출 거절, 구4결과/완료receipt·로그절단·손상
거절·재개 시 effects중복0, 기존choice2 직접진행·W188 KTX컷/다른장면 회귀를 검사한다.
공식6leaf×3 수용·독립 전수·EN/한글/JA/zh·서사/정점/컴파일·정본큐·차분을 확인한다.
순번/길이가 늘었다고 게이트를 완화하지 않는다. 실제runtime 계약과 구호환 경계를
같이 잠그고 기존검사·실패증거는 보존한다.

단일 선택 수리 전에는 root의 분기별 버튼 의도도 함께 읽는다. 옛 저장 보존을
이유로 새 플레이어에게 재선택할 수 있다는 거짓 기대를 남기지 않는다(이번 단위 지시).

W190 전용 유품그림·direction/cue는 별도 자산단위 OPEN이다. 이 단위가 끝나도
임종P0 전체/원어민·사람·실화면·청취·출시GO로 확대하지 않는다. 실제저장·공개RC·
project.godot·외부업로드 변경0. 범위 지시는 일회성, 규범은 기존정본을 따른다.

## 2026-11-23 Claude 인수 — main CI 표지 1줄 (사용자 승인)

Codex 부재(약 1주) 동안 main CI `MANUAL_SAVE_EXIT`만 해소한다. `tools/ManualSaveCheck.gd`
terminal_cases의 `arc_father_passing_deal_morning` `result_marker`를 `c77d2a67` 이전 결과 문구
"정확히 5백만원"에서 현재 결과에만 있는 "입금 내역에 5백만원이 찍혀 있었다"로 맞췄다. 단언·경로·
재개 조건은 그대로다. 위 19경로의 나머지(단일 딜레마·구저장 호환·StoryMode·산문)는 Codex 소유로 남는다.

## [~] 2026-11-29 재개·저장 검사 선언

PR44는 merge `9a4bd7f`로94커밋을 보존했다. 결과 표지 한 줄도 포함됐다.
PR45는 main 대상으로 바뀌었고 head `34b25ba`의 실제 CI는 진행 중이다.
839~841은 최신 사용자/11-27 결정대로 Claude 소유다. 그 제품 파일은 수정하지 않는다.

이 단위의 추가 소유: `tools/ManualSaveCheck.gd`의 글자 크기 변경 후 source
진행점 검사와 홀덤·정선·매매 활동의 실제 pending/closed 영수증·디스크 재개 검사.
단언/저장 검증을 줄이지 않는다. 글자가 자연스럽게 진행되는 프레임과 복원 시점을
구분해 검사하고, 활동은 실제 선택/화면/닫기 경로로 검증한다. PR45 의존분은 병합 뒤
검사한다. 기록 경로는 이 파일·활성833·큐·CLAUDE·같은 날짜 WORK_LOG다.

지속 작업사본은 `/Users/junheelee/.codex/worktrees/gangnam-integration-20261129/GangnamDream`.
예전 임시 작업사본과 교환/검증 폴더는 실제 파일0으로 확인됐다. 삭제 원인은 미관측이다.
그곳의 미커밋 직접진행WIP와 검증은 현재 제품/재검증 증거로 세지 않는다. 커밋된
`c77d2a6`와 원장 이력/구 저장은 보존하며 새 실제 원문·이전target 지문으로 재개한다.
원본244변경·project.godot·실제 저장·공개RC·인간 판정은 변경하지 않는다.
