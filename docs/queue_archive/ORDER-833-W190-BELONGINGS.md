# ORDER-833 — W190 유품 장면의 T1 자산·연출

## [x] 2026-11-29 구현·표적 검수 마감

근거: 사용자 W188 사망 통보 통일·W189~192 유품 장면 지시, 부모833의 유품T1 OPEN.
후보 기준: main `78239d80a59be980aa1534662a3192691a845926`.
이 문서는 일회성 작업 소유권·증거이며 장면 정본은 새 visual bible에 둔다.

### 한 단위

두 `arc_y4_year_close_{daeun,unattached}`의 `father_passed` 본문에만 전용 CG·기존 direction·종이 동작 끝의 실제 녹음1회를 연결한다. 카페의 두 사람과 혼자 있는 현재 방은 다른 그림이다. 기존 생존/지연 분기, 5언어 문구·선택·효과·저장·500만원·event/asset 기존ID는 불변이다.

계층: narrative_spine boss의 T1. 전용 장소를 포함한 CG2개, 카페 두 주연 연기/방은 혼자, 무음 또는 단일 녹음 룸톤, 정확한 종이 폴리, 조건부 direction을 같은 단위로 검증한다. 자산 부재/품질 미달이면 미완료로 남긴다.

깊이3문: 제거하면 발인 뒤 유품을 대하는 실제 행동의 시청각 회수가 빠진다. 새 선택은 만들지 않으며 기존 세 결정과 장기 독자를 유지한다. 같은 자리의 관계/몸/가족 한도 결정은 서로 경쟁하고 그림·소리는 어느 쪽도 먼저 고르지 않는다.

### 정확한 파일 소유권

- root: `content/events/arc_year_close.json`(두 root의 cg_if_known만), `autoloads/ImageRegistry.gd`, `assets/{cg_acting_manifest,event_visual_contracts,scene_audio_manifest}.json`, 신규 `assets/FATHER_BELONGINGS_VISUAL_BIBLE.md`, 신규 `assets/cg/story/father_belongings_{cafe,desk}_w190_v1.png` 및 해당 `.png.import`.
- `/root/session_receipt_recon_1129`: `scenes/StoryMode.gd`, 신규 `assets/w190_belongings_paper.tres`, `docs/AUDIO_QA.md`의 이 장면 절만. 기존 W208의 transient typed-anchor/복원·재배치 방어를 두 사건+father_passed에 한정한다. 영구flag/savekey/공용 시스템 신설0.
- `/root/w188_current_contract_1129`: `tools/StoryBackgroundContextCheck.gd`의 W190 focus만. 기존 검사 삭제/완화0.
- 필요한 실측 동기화만: `docs/ART_AI_AUDIT.md`, `content/meta/release_content_inventory.json`, `docs/CONTENT_RATING_INVENTORY.md`.
- 11-29 추가 선언: `tools/scene_audio_contract_check.py`에 새 CG2개의 exact 무음/단일룸톤 계약과 부정검사를 등록한다. 현 검사에서 새 무음owner 미등록으로 거절됐다. 공통 허용집합 확대·기존 검사 삭제/완화0.
- 추가 등록 소유: `tools/art_resolution_baseline.json`의 새2자산 실측 행/집계만(기존327행·targets·bands 불변, 1080/4K 확대채무 유지). `.codex/skills/gangnamdream-dev/SKILL.md`에는 신규 raster의 해상도 원장 사전 선언 한 줄을 남긴다. 판정 기준 완화0.
- 운영: 이 파일, `docs/queue_active/ORDER-833.md`, `docs/{CODEX_QUEUE,WORK_LOG}.md`, `CLAUDE.md`, `docs/agent_review_decisions.json`, `docs/agent_reviews/ORDER-833-W190-belongings-20261129.json`.

Claude839~841 보호 파일·사용자 원본 worktree·project.godot·공개demo·기존 오디오 원본은 편집0. 그림은 built-in imagegen, 기존 y3 얼굴·화풍/실제 장소 참고, 새 원본으로 보존한다.

### 검증과 완료 경계

두 사건×생사×5언어, 종이 앵커 직전0/끝1/이후0, 자연 타이핑·완독·동일언어 cold전후·선택/결과·언어/글자/해상도 재배치, 의료 기억 추가문단, 주거3종, 생존/지연 불변과 전체상태 불변을 고립 namespace로 검사한다. 신규이미지 import·compile, 시청각/acting/서사·EN/보호demo·context/queue·diff와 표적 영향 검사를 실행한다. 실제 산출물 독립 전수 검수 뒤 커밋/정상push/실제CI를 추적한다.

자동 검사는 계약·타이밍 증거이지 정상속도 사람 청취·원어민·native 화면·물리패드·재미·출시 승인 아니다. 이들 OPEN과 부모833 남은 P0/P1은 유지한다.

## 결과

제품 `86c7928` / tree `55651e3`, 정확20경로. [독립 전수 GO](../agent_reviews/ORDER-833-W190-belongings-20261129.json).
도달: prepared W190 실제Main→Story 두root×생사×5언어×3선택=60.
생산자/독자: 두root cg_if_known ↔ ImageRegistry/StoryMode; resource10앵커 ↔ typed-paper 소비자.
상태: 기존원고·선택·효과·저장형식 불변, 두CG/조건부연출/종이1회만.
포기 시: 기존 관계/몸/가족3결정의 독자 그대로. 서사: Ch4 boss/W190, T1.
닫는 것: 유품T1 구현만. 원음청취·native입력·사람·전역JA·부모833·출시/이번CI 완료 아님.

최종: 종이30·주거6/기억6·실제v4동일process복원14/reflow4, 공식renderer40컷(5언어/2크기/큰글자/본문·3선택), compile78/Gallery20/전체Manual exit0·엔진오류누수0. Manual은 의도된저장fault/recovery warning30. 새오디오부정30·기존해상도327행/targets/bands 불변. 새2CG의1080×1.5/4K×3 확대채무와3기존원화warning 보존. EN/서사/보호demo/시청각/정본큐 감사 통과, 영향118목록 전수실행 아님.

실패: 첫QA타입2오류/TERM143, 카페가림2차수리, 실제cold 음악fade이월 수리, future-source cursor fixture 수리, editor import 종료RID/ObjectDB누수는 원자료 보존. import는exit0이나 clean통과로 세지 않는다. 불변274 self-test는exit0/tool출력잘림으로 최종GO 근거에서 제외. 원본user diff SHA 불변, 새로 생성된 비소유UID16개는 외부증거에 recoverable이동(사용자파일삭제0).

증거: `/Users/junheelee/.codex/gangnam-evidence/w190-belongings-20261129.WeCjtD`; built-in 생성·편집과 최종프롬프트/개별한계는 `assets/FATHER_BELONGINGS_VISUAL_BIBLE.md`. 영구규범 승격: 같은 bible/AUDIO_QA, 이 사양은 일회성이다.
