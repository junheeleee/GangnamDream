# ORDER-564 — 프롤로그 통화 종료 표시 수리

#### [~] ORDER-564 착수 — 2026-10-12

만지는 파일: `scenes/StoryMode.gd`, `tools/ManualSaveCheck.gd`,
`docs/CODEX_QUEUE.md`, `docs/CODEX_QUEUE_L3_PENDING.md`, 이 사양,
`docs/WORK_LOG.md`, `CLAUDE.md`. 완료 시 사양을 queue_archive로 이동한다.

## 실물·깊이 3문

- actual534 fresh의 KO 선택0 결과 source2에서 통화가 끝났는데 badge/inset/nameplate가
  남았다. `.git/order534-rework-fresh-20261011/observations.json`2859B/
  SHAed89b1a98a35051ad9aefb9be9d8c5f22c8bbcb2299c47c2bf5673ed94aefb7e.
  현 소비자는 `arc_hyunsu_new_path`만 보정하므로 프롤로그에는 적용되지 않는다.
- 이 수리가 없으면 끝난 통화를 현재 대화로 오인한다. 결과 source 문단 경계를
  화면 페이지/언어 문자열과 분리한다. 선택0은 source2, 선택1은 source1부터 끝난다.
- 24주 뒤 상태를 새로 만드는 선택 작업이 아니다. 기존 효과·father affinity·
  follow_up·choice/read receipt와 한번 적용 계약을 그대로 두는 표시 버그 수리다.
- 통화 중 표시와 종료 서술의 배타성이 대상이다. 새 연출/대사/장면/시스템은0이다.
  근거: STORY_CONSISTENCY_SYSTEM의 Runtime Visual Grammar와 기존 source 결과문.

## 소유·구현

- root: StoryMode의 기존 paragraph presentation consumer와 기록만.
- manual_save_ci: 기존 ManualSaveCheck의 프롤로그 두 선택·5언어·cold result·
  언어 갱신·다음 phone event reset·효과/receipt once 표적 fixture만.
- mod_layer_ci: 읽기전용 source/fixture/실행 원자료 독립 검수만.
- 신규 영구도구/checker/등록/범용 연출 플랫폼·전체 audit/240주·검증 비용 작업0.
  기존 W40 회귀는 유지한다. registry·원고·번역·release inventory는 바꾸지 않는다.

## 표적 검증·완료 경계

- 기존 pre-autoload bootstrap·fresh HOME/3XDG의 headless 검사만 실행한다.
  scoped prologue와 W40 fixture, CompileCheck, StoryPresenceCheck 및 관련 정적
  영어한글·다국어·서사 연속성·데모 계약을 검증한다. actual exit와 marker 및
  stdout/stderr/Godot log 오류를 함께 읽고 사용자/공개/원raw/seed 보존을 대조한다.
- audit_select --list로 영향 목록만 확인한다. 전체 목록의 월/240주 회귀 실행0.
  제품 검사를 삭제하거나 KNOWN_FAILURES를 넓혀 통과시키지 않는다.
- OS 잠금 중 native 앱/UI 입력0. headless source 회귀 한정 완료와 실제 수정화면
  미관측 HOLD를 구분한다. 본편 M17은562 하나만 열려 있고 새 월 플레이0이다.
- project.godot·실제 사용자 저장·공개 demo artifact·인간 OPEN45·옛 판정 불변.
  원어민/인간/물리패드/청취·전체 본편/출시 GO가 아니다. 새규범0·일회성이다.

## 결과

선언 뒤 구현·표적 검증·독립 검수 대기. 실제 수정화면은 미관측이다.
