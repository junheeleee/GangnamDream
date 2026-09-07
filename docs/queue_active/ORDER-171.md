# Active Queue Spec: ORDER-171

> Canonical status and execution order are indexed in `docs/CODEX_QUEUE.md`.

#### [~] ORDER-171 [P0·전체 현지화] 첫 입맞춤과 데이트·계절 장면을 옮긴다

**[~] 2026-09-07 Codex 착수 — 아래 정확36 ID의 JA·zh-CN·zh-TW text-only
overlay, 원문 결속 검사·수용 기록·증거 문서만 소유한다.**
사용자의 전체 게임 번역 지시를 이어간다. 이전9,567/meta9·공개 working baseline·
배경 제품53493fe를 보존하며, 제품 표시·출시 언어 승격이나 도달성 수리는 하지 않는다.

## 깊이 3문

1. 없으면 첫 입맞춤·남산·놀이공원·계절 만남에서 언어가 폴백으로 돌아간다.
   조건부 과거 회수와 실제 발화도 원문과 함께 옮겨 누락을 막는다.
2. 선택·돈·동의·관계 단계·장소·시간·생사·연출/라우팅 변경0이다.
   원문에 없는 키스·회신·약속·동석을 추가하지 않는다.
3. 남은 관계·일상·UI·소비자 번역과 경쟁하므로 사건별 원문/번역 hash로
   각각 판정하는 A16/B20 두 배치만 수행한다. 새 이야기와 인접 미선정 사건은 넣지 않는다.

## 배치 A — 첫 입맞춤·데이트16 roots /93 leaf /9,068 KO자

- `arc_daeun_first_kiss`
- `arc_daeun_first_kiss_ask`
- `arc_daeun_first_kiss_choice`
- `arc_daeun_first_kiss_wait`
- `arc_date_namsan_daeun`
- `arc_date_namsan_jiyeon`
- `arc_date_namsan_lock_daeun`
- `arc_date_namsan_lock_jiyeon`
- `arc_date_park_daeun`
- `arc_date_park_jiyeon`
- `arc_jiyeon_first_kiss`
- `arc_jiyeon_first_kiss_choice`
- `arc_jiyeon_first_kiss_silence`
- `arc_jiyeon_first_kiss_speak`
- `callback_amusement_child_reunion`
- `callback_amusement_photo_found`

source aggregate `33fed9bc7ad8382b49aaccc045d68dad387ffa2d03f7c50ba6a19b6f45b8c215`.

## 배치 B — 계절20 roots /116 leaf /11,597 KO자

- `arc_season_cherry_daeun`
- `arc_season_cherry_jiyeon`
- `arc_season_fireworks_daeun`
- `arc_season_fireworks_daeun_decision`
- `arc_season_fireworks_daeun_dress`
- `arc_season_fireworks_daeun_river`
- `arc_season_fireworks_jiyeon`
- `arc_season_fireworks_jiyeon_decision`
- `arc_season_fireworks_jiyeon_pace`
- `arc_season_fireworks_jiyeon_schedule`
- `arc_season_sea_daeun`
- `arc_season_sea_daeun_decision`
- `arc_season_sea_daeun_horizon`
- `arc_season_sea_daeun_years`
- `arc_season_sea_jiyeon`
- `arc_season_sea_jiyeon_decision`
- `arc_season_sea_jiyeon_route`
- `arc_season_sea_jiyeon_voice`
- `arc_season_snow_daeun`
- `arc_season_snow_jiyeon`

source aggregate `205bee341047760d2144cb1e7eb2a0663b9046fdaa17ae23d7f9eeb820a5664f`.

총36 roots/209 leaf/20,665 KO자, 전부 표준 필드이며 known5(A1/B4)다.
memory/scalar/reader/foreshadow0, locale별 현재 target/accepted0이다.
전체 source aggregate
`746d8773c1280bb44178715c10a2d8d538b83bda10193695f6c8e683532841a6`.
독립 직접 재귀 추출과 collector가 일치했다. lifecycle=shipping·protected=false,
builtin_overlay_static_only이며 각 locale 신규2파일이다.

두 파일의 즉시 후속32 choice edges/26 root pairs는 범위 안에 닫힌다.
두 callback은 min_turn40·앞선 놀이공원 선택 flag를 가진 event_director bridge다.
단순 무작위 가중치로만 다루지 않는다. MainGame의 첫 키스·데이트·계절 함수와
호출 경로를 확인하되 legacy AP 호출을 현 제품의 실플레이 도달성으로 승격하지 않는다.

## 정확한 파일 소유권

각 `content/events_<ja|zh-CN|zh-TW>/`의 두 파일 전체가 위36 ID다.

- `arc_date_milestones.json`:16 roots93 leaf
- `arc_season_dates.json`:20 roots116 leaf

각 언어 작성자1명, 교차 L2 읽기 전용. KO 직접 저작하며 영어 중역·간번 자동 변환0.
키·조건 순서·선택 배열·개행·토큰·수량·인물 사실을 보존한다.
ROOT는 `tools/full_game_localization.py`, `tools/full_game_localization_self_test.py`,
`tools/zh_translation_audit.py`, `tools/audit_scope.json`,
`content/meta/full_game_localization.json`, 이 사양·CODEX_QUEUE·CLAUDE·WORK_LOG·
생성STATUS·전체 현지화 backlog를 소유한다. 부팅 예산을 위해 완료168 WORK_LOG절은
기존 `docs/history/WORK_LOG_2026-09-07_localization.md` 앞으로 원문 이동한다.
큐의 정본 승격 이유 문단만 기존 `docs/queue_archive/CODEX_QUEUE_2026-09.md`로
원문 이동하고 링크를 남긴다. 지속 규칙·활성 오더·사람 게이트는 삭제하지 않는다.

KO/EN·runtime·save·routing·human_gates·catalog/endings·공개·폰트·배포 비소유.
실제 선택 원문에 걸리는 수량·호칭 오탐만 정상/변조 짝으로 수리하고 독립 검토한다.

## 원문·제품 경계

- 남산 장면의 목표5년 회수와 datecount3+월 조건을 대조할 원문/진입 확인점이
  있다. 번역에서 연수를 몰래 바꾸거나 현 제품의 실제 도달 오류로 단정하지 않는다.
- 지연 놀이공원 결과0은 민준 사진이 망가진다고 하며 photo_found callback은
  그녀 얼굴이 망가졌다고 한다. 회수 주체 확인점을 번역과 분리한다.
- 다은 불꽃놀이 도입의 평소 소박한 사복과 이후 첫 근무복 밖 모습 발화는 원문
  확인점이다. ‘첫 드레스’로 조용히 고치거나 앞선 데이트를 삭제하지 않는다.
- 그 밖의 원문 장소/연속 동작 확인점은 source key와 근거를 backlog에 남긴다.
  실제 화면·플레이 관찰이나 새 인간 REJECT는 이 원고 대조로 발급하지 않는다.

## 검증과 증거

- source manifest `edf845a7164b8fedc9ec027be7a7edc381a3dcdf67ff58c2858d44a3237b64b8`.
- 최초 A/B source×3을 보존하고 최종 source/response/receipt6쌍을 발급한다.
- 627문구·조건5/언어의 KO 전수 독립 L2. 숫자·동의·주체·관계 단계·회수·
  인물/장소·문단과 토큰을 대조한다. 이전9,567/meta9·oldbatch21·공개를 보존한다.
- full-game-localization-overlays 표적 차선·EN·diff 및 source/hash 결속 검사.
  원어민·실제 화면·L3 OPEN, 전체 INCOMPLETE·full/main/product HOLD,
  출시 M01~M06 BUILD2026.08.31.1 사용자 GO 유지.

소유권·수량·배치·증거 절차는 일회성이다. 지속 규칙은 I18N_INFRASTRUCTURE와
언어별 용어집이 소유하며 새로운 서사·상품·출시 규칙을 만들지 않는다.
