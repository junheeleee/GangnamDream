# Active Queue Spec: ORDER-174

> Canonical status and execution order are indexed in `docs/CODEX_QUEUE.md`.

#### [~] ORDER-174 [P0·현지화 수리] 다은의 일본어 존대를 복원한다

**[~] 2026-09-07 Codex 착수 — 아래 기존 JA2 leaf와 수용 기록만 소유한다.**
전체판 번역 도중 발견한 직전172 L2 권고의 정본 충돌이다.
`I18N_GLOSSARY_JA.md:호칭·말투`는 다은→민준을 연애 뒤에도 です・ます체로
잠근다. 한국어의 잠깐 가까워진 말투를 따라 반말을 권고한 판단을 철회하고
이미 있던 인물 말투 규칙을 복원한다. KO·정본 규칙이나 관계 단계는 바꾸지 않는다.

정확 `content/events_ja/relationship_events.json` 두 leaf만 수정한다.

- `events:daeun_share:/choices/0/result_text`:
  `それも勇気だね` → `それも勇気ですね` 한 번.
- `events:daeun_feeling:/choices/0/result_text`:
  `いいね。こういうの` → `いいですね。こういうの` 한 번.

source aggregate
`130f371b68ed633a2d0d4a8f1a7815800a088233e9f642cfdede0855893e5fe2`.
수리 전 target hash는 feeling
`4812debd76a66b04f47dd7ab54940f49bf812952e501223312a87ca3d0058fc7`,
share `40a25121820bec3616b3516b32cd2143f06891f32c6ddc033f4544ce0ddfaeb9`다.

## 깊이 3문

1. 없으면 이 두 대사에서 다은의 고정 존대가 갑자기 반말로 바뀐다.
2. 돈·선택·책임·생사·약속·관계 단계 변경0, 문장 말투만 복원한다.
3. 남은 생활/UI 번역과 경쟁하므로 발견 결함2문구만 수리한다.
   새 장면15~25개나 전체 대사 리라이트로 키우지 않는다.

## 소유권과 보존

ROOT는 위 exact2 target, content/meta/full_game_localization.json의 JA 수용2·
checksum·수리 기록, 이 사양·CODEX_QUEUE·CLAUDE·WORK_LOG·생성STATUS·
전체 현지화 backlog·tools/audit_scope.json 등록만 수정한다.
부팅 예산을 위해 이전157·158의 완료 저작 설명과156·151·147의 제품/기계/Codex
관찰 근거를 담은 큐5행은 기존9월 queue_archive에 원문 보관한다. 각 활성
행·이름·[~]·상대순서·미완료 입력 QA·후속156·원어민/사람 OPEN·HOLD/REJECT는
현재 큐에 유지한다. 사람 판정을 승격하거나 규칙/의무를 삭제하지 않는다.
필요한 최근 기록 공간은 완료171 WORK_LOG절을 기존9/7 현지화 history 앞으로
원문 이동해 확보한다.

기존 총11,616 중 나머지11,614·메타9·기존 batch26·다른 target/행순서 불변.
KO/EN·CN/TW·runtime·공개·fonts·human_gates·출시 파일은 비소유다.

## 검증

- 원문 manifest `edf845a7164b8fedc9ec027be7a7edc381a3dcdf67ff58c2858d44a3237b64b8`.
- 수정 전 exact2 source batch/기존 수용을 보존한다. apply_patch 두 치환 뒤
  최종 source/response/receipt를 발급하고 source와 target을 각각 결속한다.
  이전 target hash는 새 문구의 수용 증거로 재사용하지 않는다.
- 독립 KO·용어집 대조, 파일 전체 차이가 두 치환뿐임과 나머지11,614/meta9
  보존을 확인한다. 신규 번역 수 증가는0이다.
- full-game-localization-overlays 표적12개 차선·EN·diff, source/response check,
  import --accept(현재값과 같아 changed_files0)·portable 전량 source/hash 검사.
- 원어민·실제 화면·L3 OPEN, 전체 INCOMPLETE·full/main/product HOLD,
  M01~M06 BUILD2026.08.31.1 사용자 GO 유지.

소유권·수리 절차는 일회성이다. 다은의 지속 말투 규칙은 I18N_GLOSSARY_JA가 소유한다.
