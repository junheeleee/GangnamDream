# Active Queue Spec: ORDER-172

> Canonical status and execution order are indexed in `docs/CODEX_QUEUE.md`.

#### [~] ORDER-172 [P0·전체 현지화] 가족·직장·친구 관계 사건을 옮긴다

**[~] 2026-09-07 Codex 착수 — 아래 정확50 ID의 JA·zh-CN·zh-TW text-only
overlay, 원문 결속 검사·수용 기록·증거 문서만 소유한다.**
사용자의 전체 게임 번역 지시를 이어간다. 이전10,194/meta9·공개 working baseline·
배경 제품53493fe를 보존하며, 제품 표시·출시 언어 승격이나 도달성 수리는 하지 않는다.

## 깊이 3문

1. 가족·직장·친구와 만나는 일반 사건이 폴백으로 남아 있어 본편의 언어가 끊긴다.
   조건부 회상과 부모 생사 대안을 함께 원문에 결속해 번역한다.
2. 선택·돈·동의·관계 단계·장소·시간·생사·연출/라우팅 변경0이다.
   원문에 없는 회신·합의·방문·부활·소유를 추가하지 않는다.
3. 다른 생활 사건·UI·소비자와 경쟁하므로 A25/B25 두 배치로만 판정한다.
   이 파일의 남은5 root나 원문 수리를 끼워 넣지 않는다.

## 배치 A — 일반 가족·직장25 roots /208 leaf /9,198 KO자

- `social_life_001`
- `rel_job_change_offer`
- `jobs_004`
- `family_005`
- `social_life_006`
- `family_007`
- `social_life_008`
- `jobs_010`
- `social_life_012`
- `family_014`
- `family_016`
- `romance_017`
- `romance_020`
- `jobs_026`
- `romance_029`
- `rel_mentor_coffee`
- `rel_coworker_conflict`
- `rel_blind_date_setup`
- `rel_friend_breakup_support`
- `rel_family_visit_seoul`
- `rel_ex_reunion`
- `rel_coworker_gossip`
- `rel_romantic_progress`
- `rel_business_partner_idea`
- `rel_family_visit_seoul_father_passed`

source aggregate `1d6149d82df4e654cbfbbec70a43586d6d4c975ead6d15019fa17756cdad4ae2`.

## 배치 B — 친구·주연 관계25 roots /172 leaf /9,258 KO자

- `rel_sns_compare`
- `rel_mentor_harsh_advice`
- `rel_family_loan_request`
- `rel_coworker_team_dinner`
- `rel_networking_seminar`
- `rel_late_night_call`
- `rel_friend_big_success`
- `rel_mentor_life_question`
- `rel_family_proud_call`
- `rel_online_community_tribe`
- `rel_ex_encounter`
- `sangchul_why_gangnam`
- `sangchul_past`
- `daeun_regular`
- `daeun_share`
- `daeun_feeling`
- `daeun_choice`
- `jiyeon_world_gap`
- `jiyeon_mother`
- `jiyeon_gangnam_moment`
- `sangchul_opportunity`
- `sangchul_last_lesson`
- `father_hospital_wait`
- `father_hospital_results`
- `father_old_photo`

source aggregate `43009abc676d0decbb3b38be9c6540feb7eea90da4fc5bca157438c8898b6b90`.

총50 roots/380 leaf/18,456 KO자다. 전부 표준 필드이며 B의
sangchul_why_gangnam/sangchul_past known2를 포함한다.
memory/scalar/reader/foreshadow0, locale별 target/accepted0이다.
전체 source aggregate
`ce323593474a3cbe0fe26181c6b0688029a7fb2a60141504a67416014e0b8b97`.
lifecycle=shipping·protected=false·builtin_overlay_static_only다.
현재 foreground allowlist는 father_hospital_wait·father_old_photo이고,
wait의 두 선택이 hidden father_hospital_results로 이어진다(2 edges/1 pair).
나머지47 shipping 원고는 현재 foreground/bridge 허용이나 직접 ID 호출을 확인하지
못했다. 부모 별세 variant 매핑이 있어도 원본 방문 root의 전경 호출 허용은 별도다.
따라서 데이터 포함과 실제 도달성을 같은 주장으로 세지 않는다.
분모 밖 relationship_effects[].name14위치/10고유 이름은 표시 소비자 미지원으로
분리한다. 본문380 수용을 이름 consumer나 제품 도달성 완료로 부르지 않는다.

## 정확한 파일 소유권

각 `content/events_<ja|zh-CN|zh-TW>/relationship_events.json`에 위50 ID만
신규 text-only 행으로 작성한다. 원문 전체55행 중 다음5행은 제외한다:
daeun_drift_quiet, sangchul_becomes_primary, daeun_birthday_missed,
sangchul_world_absorbed, jiyeon_notices_daeun.

각 언어 작성자1명, 교차 L2 읽기 전용. KO 직접 저작하며 영어 중역·간번 자동변환0.
키·조건 순서·선택 배열·개행·토큰·수량·인물 사실을 보존한다.
ROOT는 `tools/full_game_localization.py`, `tools/full_game_localization_self_test.py`,
`tools/zh_translation_audit.py`, `tools/audit_scope.json`,
`content/meta/full_game_localization.json`, 이 사양·CODEX_QUEUE·CLAUDE·WORK_LOG·
생성STATUS·전체 현지화 backlog를 소유한다. 부팅 예산을 위해 완료169 WORK_LOG절은
기존 `docs/history/WORK_LOG_2026-09-07_localization.md` 앞으로 원문 이동한다.
지속 규칙·활성 오더·사람 게이트는 삭제하지 않는다.

KO/EN·runtime·save·routing·human_gates·catalog/endings·공개·폰트·배포 비소유.
실제 선택 원문에 걸리는 수량·호칭 오탐만 정상/변조 짝으로 수리하고 독립 검토한다.

## 원문·제품 경계

- rel_ex_reunion 선택1의 읽음과 결과의 읽지 않음, family_007의 '고마워'를
  두 글자로 세는 원문은 각 source leaf대로 옮긴다. 번역에서 조용히 맞추지 않는다.
- family_016의 오빠(언니)는 고정 남성 MC와 대조할 템플릿 확인점이며, 친구
  민준은 동명이인 여부 미확정이다. 외동 명시는 찾지 못했으므로 형제 자체를
  정본 위반으로 단정하지 않는다. 임의 개명·성별/형제 삭제를 하지 않는다.
- rel_family_visit_seoul 두 대안의 이미 도착한 도입→방문 미루기, 메시지에서
  카페 동석으로 넘어가는 관계 장면은 원문 연출 확인점이다. 회신을 새로 삽입하지
  않으며 원문에 실제 명시된 답장·수락·읽음은 반대로 지우지 않는다.
- daeun_regular~choice의 다은 고객/프리랜서와 주인공 계산원은 현 주연 아크와
  대조할 기존 원문 역할 확인점이다. 번역에서 다은을 점원으로 바꿔 수리하지 않는다.
- family_007의30만원 송금과 money=+430000, daeun_feeling의 거절 뒤 date flag,
  jiyeon_gangnam_moment의20억 자산만으로 전입/열쇠를 서술하는 것은 현 비전경
  원문의 별도 정합 확인점이다. 번역에서 수치·소유·연애 flag를 몰래 수리하지 않는다.
- father_hospital_results의 빈 종이컵은 앞 선택의 컵 생성/물 상태와 별도 대조한다.
  아버지 생존 전제와 별세 방문 대안을 보존한다. 정적 확인을 실플레이 판정으로
  올리지 않는다. 다른 발견도 source key/근거로 backlog에 분리한다.

## 검증과 증거

- source manifest `edf845a7164b8fedc9ec027be7a7edc381a3dcdf67ff58c2858d44a3237b64b8`.
- 최초 A/B source×3을 보존하고 최종 source/response/receipt6쌍을 발급한다.
- 1,140문구·known2/언어의 KO 독립 전수 L2. 돈·수량·주체·생사·연락 단계·
  회수·문단·토큰을 대조한다. 이전10,194/meta9·oldbatch23·공개를 보존한다.
- full-game-localization-overlays 표적 차선·EN·diff와 source/hash 검사.
  원어민·실제 화면·L3 OPEN, 전체 INCOMPLETE·full/main/product HOLD,
  출시 M01~M06 BUILD2026.08.31.1 사용자 GO 유지.

이 소유권·배치·증거 절차는 일회성이다. 지속 규칙은 I18N_INFRASTRUCTURE와
언어별 용어집이 소유하며 새로운 서사·상품·출시 규칙을 만들지 않는다.
