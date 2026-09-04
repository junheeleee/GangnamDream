# Archived Queue Spec: ORDER-154

> Canonical status and execution order are indexed in `docs/CODEX_QUEUE.md`.

#### [x] ORDER-154 [P0·화자 표시] 결혼 첫날·비교본 보관의 혼합 대화 이름표를 숨긴다

**[~] 2026-09-05 Codex 착수 — 아래 exact 범위만 소유한다.** 기준은
`0e8c3633df7b415109b508a0ae88c0e240ee928a`이며 ORDER-153 제품
`f4c7fd9092b229d50ce4a742e64ffe42cb648b4c`의 문서 종료 직계 자식이다.
이 배치는 새 전체 후보나 사람 GO가 아니며 두 Chapter 5 사람 gate는 OPEN,
full·main·product는 HOLD다.

## 깊이 3문

1. **왜 이름표의 화자를 문단마다 추론하지 않는가?** 다섯 사건의 산문은 서술,
   민준의 직접 말, 다은의 직접 말이 한 event 안에서 섞인다. 현재 event-level
   presentation에는 문단별 화자 표기가 없으므로 초상 이름을 자동 화자로 내보내면
   반드시 거짓 이름표가 생긴다. 대사 파서나 공통 StoryMode를 새로 만들지 않고,
   이미 M51에서 검증한 exact `nameplate_role=hidden` 계약을 적용한다.
2. **이름표를 숨기기 위해 초상을 지워야 하는가?** 아니다. 결혼 첫날 네 링크의
   다은 실내복 초상과 비교본 장면의 피곤한 민준 초상은 장면 연기와 연속성을
   소유한다. 초상·프레임·배경·CG reveal을 유지하고 이름표만 숨긴다.
3. **다른 혼합 장면까지 넓힐 것인가?** 아니다. 관찰된 exact 다섯 id만 고친다.
   지연 첫날밤, M51의 이미 숨겨진 두 장면, 일반·원격 이름표 대조군은 회귀로만
   읽는다. 남은 배경 불일치는 별도 오더에서 실제 settled frame을 먼저 확인한다.

## 20개 표적 단위

1. 기준 제품과 선언 기준의 `story_rules.json` equality를 기록한다.
2. KO `arc_daeun_wedding_night` 도입·선택·결과의 이름표 노출을 실패로 잡는다.
3. EN 같은 root의 이름표 노출을 실패로 잡는다.
4. KO `arc_daeun_wedding_night_tea` 도입·결과의 이름표 노출을 실패로 잡는다.
5. EN tea 링크의 이름표 노출을 실패로 잡는다.
6. KO `arc_daeun_wedding_night_honest` 도입·결과의 이름표 노출을 실패로 잡는다.
7. EN honest 링크의 이름표 노출을 실패로 잡는다.
8. KO `arc_daeun_wedding_night_choice` 도입·두 결과의 이름표 노출을 실패로 잡는다.
9. EN final 링크의 이름표 노출을 실패로 잡는다.
10. root choice 0이 tea로, tea가 final로 이어지는 실제 StoryMode 체인을 재생한다.
11. root choice 1이 honest로, honest가 final로 이어지는 실제 체인을 재생한다.
12. final choice 0의 기존 정신·tint·다은 affinity·seen flag를 그대로 확인한다.
13. final choice 1의 기존 효과와 같은 완료 flag를 그대로 확인한다.
14. final result 문단 0은 신혼집·다은 초상, 문단 1부터는 아침 CG이며 이름표는
    전 구간 숨김인지 확인한다.
15. KO `arc_y5_father_trace_custody` choice 0의 도입·결과에서 민준 이름이 다은
    발화의 화자로 노출되지 않음을 확인한다.
16. KO 같은 root choice 1의 도입·결과와 미전달 사실을 보존한다.
17. EN custody 두 선택이 KO와 같은 숨김·사실 경계를 쓰는지 확인한다.
18. 일반 대면·원격 메시지 대조군과 ORDER-152 두 hidden root가 각각 자기 표시를
    복구하고 이전 이름표를 누출하지 않는지 확인한다.
19. 다섯 presentation 외 KO/EN 원고·선택·효과·초상·배경·오디오·CG 계약의
    byte/hash 불변을 확인한다.
20. 공개 M01~M06, Chapter 5 두 경로, 저장·로케일 왕복과 변경 영향 선택 회귀를
    통과한다.

## 정확한 파일 소유권

- 제품: `content/meta/story_rules.json`의 exact 다섯 event presentation만.
  첫날밤 네 id에는 `in_person`·다은 신혼집·player+daeun·현지 초상·hidden
  이름표와 기존 배경/초상 기대를 명시한다. custody는 기존 presentation에
  `nameplate_role=hidden`만 추가한다.
- 회귀: `tools/StoryNameplateCheck.gd`의 실제 StoryMode fixture를 위 체인과
  custody 두 선택까지 확장한다. 필요하면 기존 bootstrap·runner는 동작을
  바꾸지 않는 범위에서 fixture 등록만 갱신한다.
- 정적 보호: `tools/chapter5_human_reject_audit.py`의 custody presentation 기대와
  exact 다섯 범위·mutation만 추가한다. 새 허용 목록이나 기준 완화는 금지한다.
- 파생 관측: 영향 선택이 실제로 요구하는 current `story_rules.json` source hash와
  exact predecessor→successor 층만 해당 원장에 추가한다. ORDER-151/152/153의
  역사 상수·수량·debt·threshold는 바꾸지 않는다.
- 기록: 이 사양, `docs/{CODEX_QUEUE,WORK_LOG,DEMO_FIXLOG,STATUS}.md`, `CLAUDE.md`.
  `docs/human_gates.json`은 변경하지 않는다.

## 비소유·보존선

`content/events*/`의 원고·선택·효과·follow-up, `scenes/StoryMode.gd`,
`autoloads/`·`systems/`, 첫날밤 배경·초상·아침 CG와 reveal timing,
custody 편의점 배경·생활음·민준 초상, 지연 첫날밤, M55 복장·무초상,
W238 재혁 회수, W240 무응답·무이체, 30억 즉시엔딩, `project.godot`, 원본 slot
01·02, 공개 M01~M06 데모는 비소유다. 이름표 수리를 근거로 JA/zh 원고를
재번역하거나 배경 결함을 함께 고치지 않는다.

## 검증·완료 경계

- 제품 수정 전에 실제 StoryMode가 다섯 root의 거짓 초상 이름을 노출하는
  fail-first 로그와 SHA-256을 남긴다. 정적 존재 검사만으로 대체하지 않는다.
- 같은 실행기에서 KO/EN 두 결혼 체인·custody 두 선택·언어 갱신·선택/결과·
  일반/원격 대조군을 통과하고, 정확한 초상 texture와 final CG 전환도 확인한다.
- context/queue/JSON, story consistency, Chapter 5, 관련 역사 감사, 영향 선택을
  통과한다. 기존 허용 Godot 종료 경고를 오류·경고 0으로 과장하지 않는다.
- L1/L2는 정상 독해 속도 사람 플레이와 재미 판정을 대신하지 않는다. 남은 배경
  묶음까지 닫은 새 exact 제품/review 후보에서만 두 경로 M49→M60→후일담→6/6
  재플레이를 요청한다.

**규범 소유권:** 혼합 산문에서 초상 이름을 실제 발화자로 허위 표시하지 않는 것은
기존 `STORY_CONSISTENCY_SYSTEM.md`와 `story_rules.json`의 표시 사실 계약을
적용한다. 첫날밤 공간·초상·아침 reveal은 `assets/FIRST_MORNING_VISUAL_BIBLE.md`,
관계 효과는 `docs/ROMANCE_SYSTEM.md`가 계속 소유한다. exact 다섯 id와 이번
파일·증거 범위는 일회성이다.

## 완료 영수증 — 2026-09-05

- 선언 `6a16bce3b7f5de4dc5e2f877dff5dbee4c5cfce6`의 직계 제품 commit은
  `18006c9c529a9359452e39c7cd8c9ad98bb907eb`, tree
  `338e309f9313bb37455fded903a1cb52fbf381bd`, source manifest SHA-256은
  `c4f26a3f7b78f3045cf2180324f89510b93de41a8607b1d118097028f6e1714c`다.
  제품 의미 변화는 `story_rules.json`의 결혼 첫날 네 presentation 신규 등록과
  M56 custody presentation의 `nameplate_role=hidden` 한 필드뿐이다. 나머지 여섯
  파일은 검사·영향 관측층이다.
- 수정 전 정적 검사는 네 결혼 presentation의 28개 필드와 custody 이름표 1개,
  합계 29건을 실패시켰다. 로그 `/private/tmp/gangnamdream-order154-red-static.log`,
  SHA-256 `079bd9e7dc2fc8d4fef69dd05d1bec3726188637c211caf0e3ce6193c8383118`.
  수정 전 실제 StoryMode는 24경우·262문단에서 exact 다섯 root의 거짓 초상
  이름표 274건을 재현했다. 보존 stdout은
  `/var/folders/yr/mf2mg8vn7yld9rk4rf3qh2y80000gn/T/gangnam-story-nameplate-1g1hl4_9/stdout.log`,
  SHA-256 `61af7815a8cfdad207b2f8def3b0f67d749c6d23f7d9d5c2346991e96c24a426`다.
- 수정 뒤 정적 로그 `/private/tmp/gangnamdream-order154-green-static.log`는
  SHA-256 `23ab43ba12b551d5da441c3bb32022355d5db4aa8d07b300314f754097612a22`,
  self-test는 71건이다. 같은 실제 StoryMode 검사는 KO/EN 결혼 체인 8개,
  custody 4개, 아침 CG 8회, 262문단, 표시 갱신 118회, 로케일 왕복 24회,
  대조 control 32개를 실패 0으로 통과했다. stdout SHA-256은
  `61a1eeaf556a488922de947fdb42443aa1f0f2d7652d448063aab03b338cca4c`,
  Godot log는 `a75fe20c64396e860d84bc97088d6a7f8dc67abf9edb62dc993b7f08d093f286`,
  runner receipt는 `09418d40dd9a0b45fa9746bd7de31daee9f5337ed3a9bfd8605c8d3c683ff5b4`다.
- 최종 7파일 영향 선택은 43개를 순차 실행해 전부 종료 0이었다. Chapter 5 두
  경로, StoryPlayback 156경우·1,044문단, 공개 M01~M06 세 경로, 68-script
  compile, story/volume/Year 5/Chapter 1 장부를 포함한다. Chapter 1 장기
  self-test는 502건이다. 로그 `/private/tmp/gangnamdream-order154-final-impact.log`,
  SHA-256 `d03895fb30eb4bd239d32c5935b736194a8e0430302d0fe31b114e6581ba609f`.
  `StoryPresenceCheck`의 기존 종료 자원 경고 등 허용 출력을 오류·경고 0으로
  과장하지 않는다.
- 독립 읽기 전용 리뷰는 exact 제품 commit/tree, 다섯 presentation 의미,
  KO/EN 원고·choice/effect·StoryMode·초상·배경·CG·audio 불변과 위 실제 체인을
  다시 확인해 blocker 0 / 코드리뷰 APPROVE로 판정했다. 이는 제품 GO나 인간 GO가
  아니다. 두 Chapter 5 사람 gate는 OPEN, full·main·product는 HOLD이며 남은
  배경 묶음 전에는 플레이를 요청하지 않는다.
- **규범 판정:** 지속 규칙은 새 문서 문장이 아니라 정본
  `content/meta/story_rules.json`의 exact 다섯 표시 계약으로 승격됐다. 혼합 산문에서
  단일 초상 이름을 거짓 화자로 만들지 않는 원칙은 기존
  `docs/STORY_CONSISTENCY_SYSTEM.md`가 이미 소유한다. 다섯 id·증거 경로·파일
  소유권은 일회성이다.

### L2 완료 증거

```text
도달 경로      : StoryNameplate runner → actual StoryMode → KO/EN wedding tea|honest → final choice → morning CG / M56 custody choice 0|1
생산자 ↔ 독자   : story_rules.presentation.nameplate_role ↔ DataRegistry.get_story_presentation ↔ StoryMode._show_portrait/refresh
바꾸는 상태     : 새 게임 상태 없음; 표시만 hidden, 기존 선택 효과·flag·follow-up 불변
포기 시 잃는 것 : 수정 전 274개 actual narrated/mixed-speaker false-nameplate failures
서사 위치       : M51 결혼 첫날 연쇄 4 root / M56 W224 비교본 보관 1 root
장면 계층       : 대면 초상·신혼집/편의점 배경·오디오·아침 CG 유지, 이름표만 숨김
닫는 것         : 다은/민준 초상 이름이 혼합 산문의 현재 발화자로 허위 노출되는 경우 0
```
