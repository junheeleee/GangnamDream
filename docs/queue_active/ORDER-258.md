# 정보 패널 번역과 출신 배경 오역 수리

#### [~] ORDER-258 정보 패널 번역

[~] 착수 — 2026-09-13, Codex. 기준 clean main
`d56f4722622d46c256060bf8079e333f4e3bf474`, tree
`772e31f0aaf53bfecfd871ad36d96f4279ec25e8`. 공식39022/b106/meta9는
그대로이며 신규 수용은 아직0이다. 기존 현지화 계약의 일회성 적용이다.

## 한 단위와 근거

기존 정보 패널17 legacy키와 건강의 기존 BODY 문맥1을 번역·수용한다.
JA 금수저의 金ずる(돈줄)는 출생 배경과 다르므로 이1값만 독립 승인 뒤 고친다.
나머지JA17은 보존하며 CN/TW는 각각18키를 한국어에서 직접 작성한다.
BODY context를 빼면 중국어 legacy 건강이 해당 문맥의 폴백까지 바꾸므로
기존 `ui.situation.body_tag`도 같은 단위에 포함한다. 새 ID·화면·기능은0이다.

사전 scope `post257-next-info-panel-scope.json` SHA22af9a23a3a083402b5564cde18f9403123d44b1f9cf5cfd7377c8eefda863e2,
비저자 `post257-next-info-panel-independent-review.json` SHA062ad2556336da0b942485bc1d9fcc659dab9056549a88c71d1316b362cb891b는
private `.git/full-game-localization/`에 보존한다. 실제 collector·54언어 승인·GO는 아니다.

깊이3문: 제거하면 중국어 정보 라벨이 영어 폴백으로 남고 일본어 출신 의미가 틀린다.
선택·24주 상태·1년/5년 경제·서사의 변화는0이다. 표시 소비자 수리와 경쟁하지만
이미 존재하는 lookup의 누락을 우선 메운다. 실제 화면·언어 즉시갱신은 별도다.

## 고정18과 소비자

MainGame `_build_top_bar`: 정보.
`_build_info_panel`: 정보 기록, 스탯, 배경, 지방 상경, 명문대 중퇴, 금수저,
인물, 기록, 시황, 소지품, 스토리.
`_stat_name`: 직업, 건강, 정신, 총자산.
`_refresh_info_panel_hint`: `%s/%s 탭 · %s 뒤로`.
`_situation_category_tag`: `ui.situation.body_tag`(KO 건강 / EN BODY).

17 legacy의 다른 호출까지 포함한23 literal과 context1을 구분한다. 직업/기록의
기존 career/archive/record context, 관계·주거의 수용값은 보존한다. 총자산은
현금만이 아니며 원화 표시·실제 값은 바꾸지 않는다. 힌트3개 %s 순서를 보존한다.
번역이 Node.name인 네 선택탭은 유효하고 서로 달라야 하며 관계탭·5탭 순서는 그대로다.
현재 일반 새 시작은 지방 상경이고 나머지 출신은 legacy/save 값이다. 새 선택지가 아니다.
패널의 정적 라벨은 생성시 조회하며 언어 변경 때 전부 갱신되지 않는 기존 한계를
완료로 세지 않는다. BODY의 현행 StoryMode 도달이나 실제 패드 관찰도 주장하지 않는다.

## 파일 소유권

- ROOT 제품: `locale/ui_ja.json`의 금수저1값만, `locale/ui_zh-CN.json`과
  `locale/ui_zh-TW.json` 각각18 append, `content/meta/full_game_localization.json`의
  공식54기록·batch1, `tools/audit_scope.json`의 explicit-only `info-panel-locale-only` 차선1.
- ROOT 운영: `CLAUDE.md`, `docs/CODEX_QUEUE.md`, `docs/CODEX_QUEUE_L3_PENDING.md`,
  본 사양·`docs/queue_archive/ORDER-258.md`, `docs/WORK_LOG.md`, `docs/STATUS.md`,
  `docs/queue_backlog/FULL_GAME_LOCALIZATION.md`, `docs/agent_review_decisions.json`,
  `docs/agent_reviews/ORDER-258.json`.
- Rawls는 private54언어표만 저작, Poincare는 언어·적용·공식수용·단위를 비저자 검수한다.
  제품 적용·collector·QA·import·Git·원격은 ROOT만 맡는다. 별도243 역사 RO는 병렬이다.

위 외 게임코드·수치·저장·수집기·기존 검사·audit.sh·project.godot·개인 세이브·
human ledger·공개 후보·손상 mirror를 보존한다. old39022 portable 전체와 각 사전의
선택 변경 외 raw 역복원이 exact여야 한다. 새 엔진 fixture·545·Chapter·전체감사0이다.

## 적용·검증·판정

1. 한국어에서 작성한54를 독립 전수검토하고 의미·문맥·placeholder를 확정한다.
2. 현재collector18 ID·source hash·보호여부·owner/API를 확인한다. 사전검토의
   공개 보호교집합0을 예상하나 실제 보호표시가 다르면 먼저 조사한다. L1 뒤 사전을 적용한다.
3. 편집 전 source export를 보존하고 수동 적용 뒤 clean source에서 재export/check/import한다.
   공식 receipt·실제사전·source/target hash 결속 뒤에만 portable54를 더한다.
   목표39076/b107/meta9는 수용 전 완료값으로 쓰지 않는다.
4. 전체 수용 L1·old39022 raw 역복원·명시10+always2의 고유12를 수행한다:
   full_game_localization self, ZH self, JA pipeline self, JA UI, story_demo self/normal,
   EN coverage, 등록verify, queue_index self, agent_review self 및 기존context/queue.
   selector 실제 목록을 확인하며 no-renames commit diff 전체가 소유경로 안인지 검증한다.
5. 첫 실패/출력·검토 exact source/HEAD와 미관측 한계를 독립 최종보고에 묶는다.
   승인 후 원형보관·원장1·metadata 검사만 마감한다. 새 발견은 다음 소범위다.

기계 PASS는 도달성·계약 증거이지 재미·문체·실제 패널/언어갱신·렌더·원어민·
인간 플레이·물리 패드 증거가 아니다. 번역·수용 한정 단위판정만 가능하며
공개GO1·인간OPEN45·본편HOLD를 유지한다. 새 영구 규칙·출시 승격0이다.
