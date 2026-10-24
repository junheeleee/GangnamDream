# ORDER-729 — 다은 취업 발화의 영어 인칭 수리

#### [~] ORDER-729 [C2 EN 사실] 착수 — 2026-10-24

## 실제 결함과 한 단위
724 aa 동일18.1 W155 카페약속 c0 결과P1 실제 원컷
`m39aa-06-result-p1.jpg` 237545B SHA e79d2909612cec909516e70d4ebfeeb987fd5c809db3bdfc171e47f7f0c915d8:
다은이 “you can't believe you work here now.”라고 말한다. KO의 자기 취업 발화를
직업{}인 민준의 취업으로 바꾼 반대사실이다. root와 독립 native가 같은 원컷으로 확인,
P1 즉시STOP·P2/완료/W156입력0. 최종저장375164B/05ee 시작과exact.
정적 의심을 치명결함으로 승격한 것이 아니라 실제 선택 뒤 확인한 C2 수리다.

EN `callback_daeun_gangnam_first_echo.choices[0].result_text`의 인용문만
“I can't believe I work here now.”로 복구한다. 현재 다은이 창밖을 보는 행동·카페·
민준의 커피/바깥 위치는 유지한다. 허위 과거/새감각/비트/연출을 추가하지 않는다.
SCENE_TIER 공통산문계약·용어집의 화자→청자 경계를 적용한다.

## exact 파일 소유
root 제품: `content/events_en/callback_events_39.json` 위 인용문 1곳만.
root metadata: 본사양→`docs/queue_archive/ORDER-729.md`,
`docs/CODEX_QUEUE.md`, `docs/CODEX_QUEUE_L3_PENDING.md` 순번,
`CLAUDE.md` 현재행, `docs/WORK_LOG.md` 최신항목.
root private `.git/order729-daeun-person-20261024/`:
`declaration.patch`, `closure.patch`, `verify.py`, `verification.json`,
`checks.stdout.log`, `checks.stderr.log`, `index-receipt.json`.
독립 /root/m39aa_source: 같은 private 디렉터리의 `independent-review.md`,
`independent-review.json`만. 724 저장검수 후 별도 원문·수정·실제컷·검증을 직접 읽는다.
724 월별 기존 dirty 4문서는 이 수리 커밋과 분리하여 보존한다.

## 검사·판정 경계
깊이3문: 삭제하면 다은/민준 취업 주체가 잘못 남음; 선택의 24주 뒤 효과와 비용은
불변; 기존 두 카페 약속 선택의 경쟁 유지. 도달155↔실제c0/P1,
생산자 daeun_gangnam_first↔callback conditions, 기존 계층 승격0.
1문장 대체를 역산하면 선언 HEAD EN 바이트exact, KO/다른leaf/토큰/문단/효과불변.
KO/EN 한 쌍 직접독해·EN한글/빈값·패리티·기존 관련사실검사와 docs 표적만 실행.
공통스키마/엔진/경제/스케줄러 불변이므로 전체로컬/240주/새엔진검사0.
수정앱 검수는 새 격리후보의 같은05ee 저장에서 별도 재개하며 source GO로 대체하지 않는다.
CJK다듬기/원번역원장/project/사용자저장·설정/18.1/PCK/공개demo/인간판정 변경0.
보고는 실제source SHA/원컷/표적결과에 결속하고 source 한정GO만 발급한다.
승격0·기존정본적용·나머지 지시는 일회성.
자동 게이트는 도달 가능성과 계약 충족의 증거이지 재미·깊이·문체의 증거가 아니다.
