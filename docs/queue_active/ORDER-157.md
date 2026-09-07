# Active Queue Spec: ORDER-157

> Canonical status and execution order are indexed in `docs/CODEX_QUEUE.md`.

#### [~] ORDER-157 [P0·전체 현지화] M01~M60 일본어·간체·번체 번역의 전체 분모와 안전한 증분 배치를 연다

**[~] 2026-09-07 Codex 착수 — 아래 파일만 소유한다.** 사용자가
“일본어 중국어까지 게임 전체 다 번역해”라고 명시했다. 이전의 본편 동결 뒤
번역 대기는 이 직접 지시로 해제한다. 번역 착수 승인이지 게임·번역 출시 GO는
아니다. 원문 기준은 `53493fe7abbbbb82f0e56352da22acb2fe63b034`이며, Chapter 5
배경 수리 후보의 검증과 독립된 `codex/full-game-localization`에서 작업한다.

## 깊이 3문

1. **데모 번역을 전체판에 복사하면 끝나는가?** 아니다. 현재 packaged 1,813사건의
   12,415 text leaf에는 shipping 1,708/11,674와 author-only 105/741이 함께 있다.
   엔딩 35종의 조건별 변형, catalog, 정적·동적 UI도 각각 분모가 필요하다.
2. **영어 중역이나 간체→번체 변환으로 속도를 얻을 것인가?** 아니다. 세 언어는
   한국어 원문에서 독립 작성한다. 기존 말투·호칭·지역 용어와 원화 의미를 유지한다.
3. **대량 생성 성공을 완료로 셀 것인가?** 아니다. source hash와 문맥을 잠근
   작은 배치의 초안→구조/토큰/숫자/문자 검사→원문 대조→대상 오버레이 수용을
   반복한다. 기존 공개 데모 번역은 보존하고 원어민/실제 화면 판정은 OPEN이다.

## 첫 배치 — 20개 표적 단위

1. packaged·shipping·author-only 사건과 표준/Chapter5 reader leaf를 각각 계측한다.
2. 35개 엔딩의 모든 조건별 변형과 표시 조건을 계측한다.
3. catalog 7개 섹션의 실제 텍스트 leaf를 계측한다.
4. 현재 정적 UI·문맥 ID를 기존 collector로 계측한다.
5. 기존 demo 동적 표면과 본편 동적 한국어/영어 pair의 누락을 드러낸다.
6. source revision/hash·target locale·필드 경로를 가지는 증분 번역 원장을 만든다.
7. 공개 M01~M06의 이미 번역된 leaf와 UI를 덮지 않는 merge를 검사한다.
8. KO 직접 번역과 JA/SC/TC 독립 생성 문맥을 각각 고정한다.
9. 생성 응답의 누락·추가·중복 id와 빈 번역을 거부한다.
10. gameplay key·선택 index·조건·숫자·토큰·문단의 보존을 검사한다.
11. 한글 잔재·지역 문자·금지 통화·미승인 인명 한자를 검사한다.
12. source가 바뀐 cache와 손상된 batch를 재사용하지 못하게 한다.
13. 133개 Chapter5 nested reader의 번역 수집과 실제 loader 지원 여부를 기록한다.
14. JA: `instant_legend`, `with_daeun`, `late_call`의 모든 text/변형을 직접 번역한다.
15. zh-CN: 같은 세 root를 한국어에서 독립 번역한다.
16. zh-TW: 같은 세 root를 한국어에서 독립 번역한다.
17. 세 언어의 금액·사람 관계·아버지 생사·행동/응답 의미를 원문과 대조한다.
18. 기존 데모 번역과 KO/EN·런타임·저장 바이트가 변하지 않았는지 확인한다.
19. 검사 실패 사례와 재개 가능한 진행률을 기록하고 독립 리뷰를 받는다.
20. 다음 15~25단위 번역 배치를 전체 원장의 미완료 범위에서 발급한다.

첫 세 root는 파이프라인·말투 대조 표본이지 전체 35엔딩 완료나 사용자 L3
표본의 대체가 아니다. 이후에도 사건·엔딩·catalog·UI의 미완료를 실제 분모로
관리하며 “번역 예정”을 번역된 문자열로 세지 않는다.

## 정확한 파일 소유권

- 새 `tools/full_game_localization.py`와 필요한 전용 self-test, 새
  `content/meta/full_game_localization.json`: 전체 분모·증분 배치·source 해시·검사.
- `content/endings_{ja,zh-CN,zh-TW}.json`의 위 세 root 텍스트만.
- 필요 시 `tools/ja_translation_pipeline.py`, `tools/full_body_translation_scope.py`의
  collector/관측 분리만. 기존 UI/공개 데모 규칙·역사 기준선은 완화하지 않는다.
- `tools/audit_scope.json`의 새 검사 등록, `docs/I18N_INFRASTRUCTURE.md`의
  사용자 승인·증분 번역 상태, `docs/queue_backlog/FULL_GAME_LOCALIZATION.md`의
  전체 남은 범위, 이 사양·큐·WORK_LOG·STATUS·CLAUDE·DECISIONS 기록.
- 번역 초안 cache는 worktree 전용 git-private 경로다. 생성기가 직접 공개 데모를
  덮거나 기존 번역 파일들을 먼저 삭제하는 경로는 사용하지 않는다.

## 비소유·판정 경계

KO/EN 원고·사람 사실·효과·확률·일정·엔딩 라우팅·`project.godot`·원본 저장·
공개 `story_demo_rc` M01~M06 바이트·`SHIPPING_LANGUAGES`·Steam 표기는 비소유다.
번역을 위해 실제 loader 변경이 필요하면 다음 독립 배치에 exact 파일을 선언한다.
전체판·Chapter 5 사람 gate와 세 언어 원어민 gate는 계속 OPEN/HOLD다.

**규범 소유권:** 언어·호칭·문화·통화는 기존 I18N 용어집을 그대로 적용한다.
증분 직접 번역·source 변경 검출·초안/수용/원어민 판정 분리는
`I18N_INFRASTRUCTURE.md`에 승격한다. 위 세 root·20단위·파일 소유권은 일회성이다.
