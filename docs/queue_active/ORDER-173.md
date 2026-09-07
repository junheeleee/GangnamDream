# Active Queue Spec: ORDER-173

> Canonical status and execution order are indexed in `docs/CODEX_QUEUE.md`.

#### [~] ORDER-173 [P0·전체 현지화] 남은 관계·부모 대화를 옮긴다

**[~] 2026-09-07 Codex 착수 — 아래 정확15 ID의 JA·zh-CN·zh-TW text-only
overlay, 원문 결속 검사·수용 기록·증거 문서만 소유한다.**
사용자의 전체 게임 번역 지시를 이어간다. 이전11,334/meta9·공개 working baseline·
배경 제품53493fe를 보존하며 제품 표시·출시 언어 승격이나 도달성 수리는 하지 않는다.

## 깊이 3문

1. 관계 파일의 남은 장면과 부모·옛 친구 대화가 폴백이면 본편 언어가 끊긴다.
   앞선50행을 보존하며 원문에 명시된 행동과 미확정 초대를 구분해 옮긴다.
2. 선택·돈·동의·관계 단계·장소·시간·생사·연출/라우팅 변경0이다.
   원문에 없는 회신·합의·방문·부활·소유를 추가하지 않는다.
3. 다른 생활 사건·UI·소비자와 경쟁하므로15단위 한 배치로 판정한다.
   기존 source 오류를 번역에서 수리하거나 인접 사건을 더하지 않는다.

## 배치 A — 관계·부모15 roots /94 leaf /4,145 KO자

`content/events/relationship_events.json`의 남은5 roots/28 leaf/924 KO자:

- `daeun_drift_quiet`
- `sangchul_becomes_primary`
- `daeun_birthday_missed`
- `sangchul_world_absorbed`
- `jiyeon_notices_daeun`

`content/events/relationship_events2.json` 전체10 roots/66 leaf/3,221 KO자:

- `rel_daeun_first_text`
- `rel_hyunsu_loan`
- `rel_sangchul_wisdom`
- `rel_father_silent`
- `rel_mother_confession`
- `rel_friend_breakup`
- `rel_old_flame_00`
- `rel_mentor_wisdom`
- `rel_coworker_secret`
- `rel_childhood_rival`

source aggregate
`f17ead3c26c8605d6b9d7d2cdc7db3bdb7392961db361fd3375982d4377f8a92`.
전부 표준 필드94, known/memory/scalar/reader/foreshadow0, 분모 밖 name0이다.
shipping·protected=false·builtin_overlay_static_only이며 세 locale target/accepted0.
독립 직접 대조와 ROOT 수집치가 일치했다.

현재 foreground0, director bridge2(sangchul_becomes_primary/world_absorbed)를
확인했다. 제품 GDScript 직접 ID·source follow/deferred 입출력 edge·thought/
demo/release ingress는 찾지 못했다. 이 정적 탐색으로 나머지13의 모든 실제
비도달을 증명하지 않는다. primary와 father_silent의 no_flag father_passed는
별세 flag·사망 장면 영수증·passed stage를 모두 차단한다.
first_text의 message/received/remote_actor=daeun은 물리 동석이 아니다.

## 정확한 파일 소유권

각 `content/events_<ja|zh-CN|zh-TW>/relationship_events.json`에5행만 추가한다.
기존50행/380문구의 바이트·순서·source/target hash를 보존한다.
각 locale의 신규 `relationship_events2.json`은 위10행만 작성한다.
언어별 작성자1명, KO 직접 저작·다른 작성자/ROOT의 읽기 전용 전수 L2다.
영어 중역·간번 자동변환0, 키·조건 순서·선택 배열·개행·토큰·수량·인물 사실 보존.

ROOT는 full_game_localization.py·full_game_localization_self_test.py·
zh_translation_audit.py·audit_scope.json, content/meta/full_game_localization.json,
이 사양·CODEX_QUEUE·CLAUDE·WORK_LOG·생성STATUS·전체 현지화 backlog를 소유한다.
부팅 예산을 위해 완료170 WORK_LOG절은 기존9/7 현지화 history 앞으로 원문 이동한다.
완료159~172의 L1/L2 수량 설명을 담은 이전 큐 행은 기존9월 queue_archive에
원문 보존하고 링크를 남긴다. 각 활성 행·이름·순서·[~]·L1/L2 PASS·L3 OPEN은
현재 큐에 유지한다. 사람 게이트를 닫거나 활성 의무·지속 규칙을 삭제하지 않는다.

KO/EN·runtime·save·routing·human_gates·catalog/endings·공개·폰트·배포 비소유.
실제 선택 원문에 걸린 오탐만 정상/변조 짝으로 수리하고 독립 검토한다.

## 원문·제품 경계

- rel_mother_confession 결과0의 '어머니가 딸/아들이 아닌 한 사람'은 주체/관계
  비교가 어긋난 원문이다. '어머니가 엄마가 아닌 한 사람'으로 몰래 고치지 않는다.
- relationship_events2의23선택 모두 도덕·관계·보상 설명 괄호를 원문이 가진다.
  숨은 도덕 표면 규칙과 대조할 source 부채이지, 번역에서 새로 노출하거나 지울
  권한이 아니다. 해당 표면 그대로 옮기고 별도 source 수리로 분리한다.
- friend_breakup의 '고마워' 두 글자, 오늘 생일→늦었지만, 노트 선택→메모앱,
  현수의 친밀 호칭과 first_meeting만의 진입, 다은 최초 선연락 주장과 과거 이력
  조건 부재는 원문 확인점이다. 번역에서 숫자·친밀·최초 여부를 조용히 바꾸지 않는다.
- 현수의 계좌 전달은 송금으로 바꾸지 않으며, 원문에 명시된 한 달 뒤 반환은
  반대로 지우지 않는다. 다은 커피/옛 친구 식사 초대에 새 수락·날짜 확정·동석0.
  기존 메시지 답장·미응답·부모 생사 경계를 그대로 유지한다.

## 검증과 증거

- source manifest `edf845a7164b8fedc9ec027be7a7edc381a3dcdf67ff58c2858d44a3237b64b8`.
- 최초 source×3 보존, 최종 source/response/receipt3쌍 발급.
- 282문구 KO 독립 전수 L2, 이전11,334/meta9·oldbatch25·공개·기존행 보존.
- full-game-localization-overlays 표적12개 차선·EN·diff와 source/hash 검사.
  원어민·실제 화면·L3 OPEN, 전체 INCOMPLETE·full/main/product HOLD,
  출시 M01~M06 BUILD2026.08.31.1 사용자 GO 유지.

이 소유권·배치·증거 절차는 일회성이다. 지속 규칙은 I18N_INFRASTRUCTURE와
언어별 용어집이 소유하며 새로운 서사·상품·출시 규칙을 만들지 않는다.
