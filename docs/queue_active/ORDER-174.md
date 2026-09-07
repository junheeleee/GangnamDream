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

## 수리 결과 — L1/L2 수용·L3 OPEN

- 선언 `d5f5b2a1d919a20f1a6a940ba8be809cbab604dc` 뒤 정확 두 치환만 적용했다.
  KO·기존 고정 존대 규칙의 독립 대조를 통과했다. 이전172의 말투 권고2만 철회하며
  다른 의미·문화 정밀화를 되돌리지 않는다. 관계 단계·돈·연락·생사 변화0이다.
- 첫 export는 --group 누락으로 쓰기 전에 실패했다. ROOT의 두 치환만 되돌려
  파일=선언 HEAD를 확인한 뒤 정상 초기 source를 발급하고 두 치환을 재적용했다.
  초기3행 SHA `9f3b216167423dd59d1fe800e3b1cb5921c19f3efde930f81a124f2ecedf2169`,
  previous_target 두 값은 기존 수용과 정확히 같다. 최종source/response/receipt
  check/import --accept PASS·changed_files0, 기존 private 증거 덮어쓰기0이다.
- 최종2-record aggregate `91201c1ac263ffb359d2ce4d94558ff58393a937aa9531c8c5d0ba0d704732d0`.
  파일 SHA `d1e4133133962de4963d42d06d923e4fce485eca53ca0abfdab2bac938fe7757`.
  portable checksum `52f09844d410de3215eaa8196178fdba3bf319d63004a5cf25595823e03d0f74`.
  총11,616 유지, 나머지11,614/meta9·oldbatch26을 보존했다. 수리 batch1만 추가했다.
- 완료171절1,555bytes SHA `ea432b363f0ffff9b399fa3d1ccadef830fda7d8611b4397bce8395bf4cd39d8`를
  기존 history18,382bytes 앞으로 원문 이동했다. 새19,937bytes SHA
  `e814f72b6330af4c5f993dd4abf91dd72bdbb0494c8c1937416fa8131d66a1a0`, 끝 LF2 보존이다.
  큐5행을 설명 포함969bytes의 추가 절로 기존 archive에 원문 보관했다.
  절 SHA `2ff3c5aff8f45fb3edb4df39efb30fb714d13b63896118bef9de4826f7916540`.
  다른 기존 보관 내용·활성 이름/상태/입력 QA/후속156·사람 판정과 규칙은 보존했다.
- KO/EN·CN/TW·runtime·공개·폰트·저장·human_gates 변경0, 원문 manifest 불변.
  L3·원어민·화면 OPEN, 전체 INCOMPLETE·full/main/product HOLD·출시 데모 GO 유지.
- 최종12개 표적 차선·별도 EN·diff PASS, portable11,616 source/hash/L1 오류0.
  차선 실제 stdout만 git-private order174-final-checks.log에 보존했다.
  4,224bytes SHA `8d5fd2a4b0c247b270ae91f8a79128b65afe586d8b68ffd44b962aec900e488c`.
