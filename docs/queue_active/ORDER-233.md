# Active Queue Spec: ORDER-233

> Canonical status and execution order are indexed in `docs/CODEX_QUEUE.md`.

#### [~] ORDER-233 [전체 현지화] 갤러리20단위·UI27키 번역

**[~] 2026-09-10 착수 — 아래 파일만 소유한다.** 사용자 전체 번역·개발 위임과
ORDER-157을 따른다. clean main84b611f668eb3bb84db0f7671da611e47e607297 /
tree e63c8a5eee68d83387e52ae012878e155b269984 기준이다. 이전 ORDER-232의72 수용·
독립 GO를 새81의 검수에 합산하지 않는다.

## 깊이 3문·판정 대상

1. 없으면 무엇이 빠지는가? 시작 메뉴 갤러리의 CG/명장면/비밀 기록과 열람·해금 안내다.
2. 바뀌는 미래 상태는? 텍스트만 바뀐다. 실제 회상·해금·저장 정책은 바꾸지 않는다.
3. 무엇과 경쟁하는가? 다시 보는 기록의 식별과 현재 진행을 바꾸지 않는다는 경계를 명료하게 한다.

ROOT는27 KO/EN/기존JA와 StartMenu955–1485 소비자를 직접 읽었다.
사전조사26311B/SHA4d0b7b9a18ad74cd94a4073bedc223d958940e8bbf04019faa26b24b670ca2c9,
현재 재결속4495B/SHA4ed42b2e6ae8a6049687754101fdb151cb3ff1b33186071c134e66b6364bb5f1.
source records SHA049fed8643a58dcea79a9207f9329002c3f522a8d1b11e0103a6cf0cdcc2a37d.
context ID3·템플릿5/printf7·LF0/name0, 보호0/기수용0이다. JA기존27과 CN/TW누락각27.

## 정확한20판정 단위·27키

1. 탐색 제목: ui.navigation.archive
2. 재열람 안내: 지나온 장면은 남지만, 다시 보는 선택은 현재를 바꾸지 않습니다.
3. CG 탭: CG
4. 회상 탭: 명장면
5. 비밀 탭: 비밀 기록
6. 이동 힌트: 탭 이동 / 페이지
7. 페이지 버튼: ui.archive.previous_page / 다음
8. 수집 진행: CG  %d / %d ; 회상  %d / %d ; 발견된 비밀  %d
9. 잠긴 CG: 아직 보지 못한 장면 / 미해금
10. 기록 제목 fallback: ui.archive.record_fallback
11. 회상 안내: 열람 전용 · 선택은 현재 기록을 바꾸지 않음 / 이 장면을 본 뒤 열립니다.
12. 비밀 일련번호: 비밀 기록 %02d
13. 비밀 빈 상태: 아직 드러난 비밀 기록이 없습니다.
14. 엔딩 fallback: 엔딩 기록
15. 장면 fallback: 장면 기록 / 장면 기록 %02d
16. 시작 CG: 시작의 기록
17. 계절 분류: 계절의 기록
18. 첫 키스 분류: 첫 키스
19. 밤 분류: 그 밤
20. 특별 분류: 특별한 이야기

27 exact leaf IDs는 .git/full-game-localization/order233-leaf-ids.json,
1426B/SHA90b401a5dcd507b61dac573f2753913e01b8880788ac97e54c1a09c1df19ec7e.
쉼표 포함 원문이 있으므로 공식 export는 --group ui --leaf-ids <JSON> --limit27을 쓴다.
context3은 KO source가 아니라 owner/path로 현재 번역값을 결속한다.

## 파일 소유·분담

- Plato: locale/ui_ja.json 위27 기존값 KO 직접 검수·필요 정밀화.
- Rawls: locale/ui_zh-CN.json 신규27 직접 저작.
- Poincare: locale/ui_zh-TW.json 신규27 직접 저작. 간체 변환이 아니다.
- 비저자 전량81: Rawls→JA / Poincare→CN / Plato→TW. ROOT 통합.
- ROOT: content/meta/full_game_localization.json에 검수81/batch1만 추가.
  기존38014/b92/meta9 및 선택 밖 모든 UI key/value/order/raw를 역제거 보존한다.
- 조건부 코드4: tools/full_game_localization.py, tools/full_game_localization_self_test.py,
  tools/ja_translation_pipeline.py, tools/zh_translation_audit.py. 첫27 L1의 실제 오탐만
  actual/다른 정상/유효 변조/source-OFF와 비저자 증거를 먼저 봉인해 국소 수리한다.
  전역 완화·전체 leaf 면제·기대 변경0.
- 운영: CLAUDE.md, docs/CODEX_QUEUE.md, docs/CODEX_QUEUE_L3_PENDING.md,
  docs/WORK_LOG.md, docs/STATUS.md, docs/queue_backlog/FULL_GAME_LOCALIZATION.md,
  이 사양, docs/queue_archive/ORDER-233_L1_L2_RESULTS.md, tools/audit_scope.json,
  docs/agent_review_decisions.json, docs/agent_reviews/ORDER-233.json.
  사적 helper/원문/receipt/검수/QA는 .git/full-game-localization/order233-*.
- 감사는 기존 명시 full-game-localization-overlays 차선 owned_paths에 사양/보고만 추가한다.
  기존 UI3 소유 등록을 재사용하며 자동 paths/Godot 선택 규칙을 넓히지 않는다.

KO/EN/source manifests·gameplay·StartMenu·LocaleManager·SaveManager·저장/설정/커스텀 이름·
폰트·SHIPPING_LANGUAGES·project.godot·공개 데모·인간 원장은 비소유다.
같은 화면 닫기/돌아가기·보호UI121·직전 저장UI72를 포함해 선택 밖은 보존한다.

## 의미·검수 경계

- 명장면의 기존 일본어 名物麺은 음식 오역이다. 비밀 빈 상태는 미발견이 없다는 뜻이 아니라
  아직 발견한 기록이 없다는 뜻이다. 두 결함을 수리하며 나머지25도 실제 KO와 대조한다.
- ui.navigation.archive=기록(갤러리), ui.archive.record_fallback=기록(제목 fallback),
  ui.archive.previous_page=이전은 다른 문맥이다. ID/호출/원문/해금 조건을 바꾸지 않는다.
- %d 다섯 개·%02d 두 개의 개수/순서/제로 패딩을 보존한다. 원문 CG는 그대로 가능하다.
- 잠긴 제목·미발견/해금 안내는 스포일러나 완료 사실을 새로 만들지 않는다.
  다시 보는 선택이 현재 기록을 바꾸지 않는다는 문장은 열람 안내의 번역이지 실행 증명이 아니다.
- 동적 DataRegistry 제목/업적·이미지·controller 글리프·회상 handler는 번역 범위 밖이다.
  실제 플레이·저장·삭제·해금·회상 실행0. UI 배치·component·해상도·원어민은 미관찰.
- 공개 GO/인간45OPEN·본편 HOLD 유지. 포착 UI3556+미확정329는 최종 전체 UI 분모가 아니다.

## 검증·마감

1. 선언 커밋·동기화 뒤 공식 initial27×3, 기존JA27/null54와 원형 입력 봉인.
2. 세 언어 직접 저작·첫 L1 각1회(실패 원형 보존)·비저자81 전량 대조.
3. context-aware source/현재값/비저자 records digest 결속을 final response 생성 전에 검증한다.
4. clean C1 official final export/check/import3쌍, 각 locale 명시·changed_files0.
   81 수용 후 기존38014/b92/meta9 raw 역복원, 보호 입력 원형을 확인한다.
5. 전체수용 hash/L1 1회·명시12 차선1회를 전후 입력 봉인. 실패면 실제 원형과 영향 재실행을
   기록한다. context/queue/diff 검사, Godot/full/240 실행0. 자동 통과는 재미·문체 GO가 아니다.
6. source-like 문서까지 exact C2에 묶고 비저자 work_unit233 판정 뒤 metadata wrapper만 추가.
   WORK 기존36125B·EOF2 원형을 실제 적용 후 확인하며 이력 이동0.
   STATUS clean 생성·검사, main/번역 브랜치 비파괴 동기화.

성공 때만38095(JA12697/CN·TW12699)/b93/meta9. 81=JA기존27검수+CN/TW신규54이며
81을 모두 신규 저작이라 하지 않는다. 기존 I18N/WORK_UNIT 정본 유지, 이번 키/소유/마감은 일회성.
