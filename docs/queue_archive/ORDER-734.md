# ORDER-734 — 현재 Steam 스크린샷 크기와 기존 자료를 분리

#### [x] ORDER-734 — 2026-10-30 native 규격 source 준비 완료

C5 직접 기여. 사용자 `그럼해`의 잠금 중 잔여 완성 지시.
발견: 공식 Store Graphical Assets는 스크린샷 최소1920x1080·16:9를 요구한다.
기존1280x800→1280x720 파이프라인/승인8장은 현재 제출 규격을 충족하지 않는다.
근거: https://partner.steamgames.com/doc/store/assets/standard (2026-10-30 조회).

깊이3문: 없으면 새캡처도 구규격을 반복함 / 제품선택·저장상태 변경0 /
실제앱 잠금 동안 C5준비만, 대표경로·CJK후속과 경쟁하지 않음.

## exact 소유

- `tools/store_shot_export.py`: legacy 프로필 유지, 명시적인 `steam` 프로필에
  진짜1920x1200 원본→중앙1920x1080 crop. 저해상도 확대 금지.
- `tools/store_shot_capture.py`: 새 캡처는1920x1200 원본만·receipt 연결.
- 두 `tools/store_shot_{export,capture}_self_test.py`: 프로필·해상도·경계pixel·
  저해상도/혼합 입력 거부·legacy회귀·capture→export 연동 반례.
- `docs/STORE_SHOTLIST.md`, `docs/QA_CHECKLIST.md`: 기존8장/legacy근거 보존,
  새촬영 규격·프로필 명시. CLAUDE 현재준비행/WORK_LOG신규행/이사양과큐임시행.

비소유: ScreenshotQA·게임기능/저장·project.godot·기존PNG·공개데모·캡슐/아트.
이번은 이미지 편집/재생성 작업이 아니라 기존 도구의 native규격 입력/검증 경로다.

저자 locked_c2_audit(제품4파일), root(문서/마감), 독립 locked_media_audit.
시작 전 impact --list. 합성 source-only 검사와 독립전수리뷰 후 수용.
Mac잠금중 엔진/실촬영/기존이미지교체0. 시각/사람/출시/C5전체GO0.
계속사용규칙은 STORE_SHOTLIST/QA_CHECKLIST로 승격, 작업범위는 일회성.

## 마감 증거

도달 경로: STORE_SHOT_EXPORT_SELF_TEST_OK tests=38 synthetic_only=1 engine_runs=0;
STORE_SHOT_CAPTURE_SELF_TEST_OK tests=28 synthetic_only=1 engine_runs=0.
생산자↔독자:1920x1200 mockcapture receipt→export(profile=steam)→1920x1080.
바꾸는 상태: current규격경로없음→검증된source준비; 제품상태변경0.
포기시손실: 저해상도확대없는 새Steam이미지 생성경로. 서사/Tier비해당.
닫는것:도구source준비만. 실제원본/시각/사람/패키지/출시0.

독립 /root/locked_media_audit GO_NATIVE_SIZE_SOURCE_PREPARATION_ONLY.
최종38+28 반례전수·경계pixel·noresize·legacy회귀·receipt연동·실viewport경로source
검토완료. `.git/order734-steam-screenshot-size-20261030/independent-review.json`
5584B SHAcbb0d4fd21c8dd6ce9d970d855bb2a43a1c57b4c4d985b5e07d32998a16ccba3,
MD3128B SHAd19d122e78b3fd4431204ef89c37d8aa14f5ff75c2462b639434b4da95f8a2bb.
코드4파일·문서2파일의 SHA는 보고에 결속. 영향 목록 뒤 source-only 검사·queue/context/diff.
기존1280PNG·공개데모·29.1/live53a3 불변. 자동 게이트는 계약 증거이며 인간 관찰이 아니다.
