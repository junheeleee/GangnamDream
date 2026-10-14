# ORDER-651 — M55 영어 카페 회상의 잘못된 수년 경과 수리

#### [x] ORDER-651 [정합] 이전 카페 만남을 수년 전으로 늘리지 않는다 — 2026-10-15

650 source 마감 뒤 확인된 M55 EN 한 문장만 수리한다.
실제 M18/612는 같은 수정 앱 재검수 HOLD, 새 월0/열린 실제월1.
5언어 유지·KO/EN 실제 확정 전 JA/zh 다듬기 중단/누락만.

## 근거·깊이 3문

arc_minseo_02_real의 실제 첫 카페 동석 입구는 MainGame.gd:8549 t>=160이다.
arc_y5_general_debt_memory_reconnect는 같은 코드:7588 exact W220에서 열린다.
그 과거 만남은 늦어질 수 있어도 최대60주이며, 수년 경과 조건은 없다.
EN choices1.result_text의 years earlier만 확정되지 않은 시간을 만든다.
KO 대응은 오래전으로 고정 연수를 말하지 않으므로 그대로 둔다.

장면/선택을 지우면 상환 사본과 실제 자기 답신을 혼자 펼쳐 두는 기억을 잃는다.
기존 general debt memory 영수증/후행 reader는 남고 새 관계/만남/연락/기간을 만들지 않는다.
같은 자리의 혼자 음성 메모와 혼자 카페 기록이 경쟁한다. 두 매체 선택의 효과는 변경0.

## 소유

root content/events_en/arc_pre_ending.json:
arc_y5_general_debt_memory_reconnect/choices/1/result_text 정확1잎.
years earlier만 빼고 첫 동석의 과거성·카페·혼자 있음·상환 사본/메모는 보존.
KO/다른 EN/JAzh/원장·금액·flags·조건·indices·receipt·schema·코드·저장·사용자설정/project/demo/human 불변.
실제 영향이 관측될 때만 content/meta/release_content_inventory.json의 content SHA 및
docs/CONTENT_RATING_INVENTORY.md 동일 생성 셀을 정렬. counts/IDs/다른 축/public snapshot 불변.
큐2/사양/archive/CLAUDE현재행/WORK_LOG/.git/order651-20261015/ root 소유.
비저자 a1_qa_release_audit private review.md/json만; 제품/Git/engine/UI/새agent 쓰기0.
612 월별 dirty4는 모든 커밋에서 제외한다.

## 검증·한계

EN1잎 전체 byte 역변환·문단/name/digits exact·KOEN 의미·실제입구/consumer 확인.
audit_select --list는 선택만. audit/consistency/ENcoverage/영어한글/release 표적5.
KO source/input 불변을 확인해650의 공식3 inventory와 manifest/핀을 재사용한다.
EN-only 수정에 같은 KO inventory·continuity·자연240을 이유 없이 다시 돌리지 않는다.
context/queue/diff0·정확stage목록·독립 source-fact 한정 GO.
engine/전체audit/새checker/비용/최적화0. 실제 M55/M18/native/전체체인/5언어/352선행/출시 HOLD.
M56 missed4잎은 다음 별도범위·M57 읽기는 쓰기 없는 독립 발견만·이번 원고 모집단에 추가0.
일회성 수리·새 정본 승격 없음.
자동 게이트는 도달 가능성과 계약 충족의 증거이지 재미·깊이·문체의 증거가 아니다.

## 마감 — source 사실 수리 한정

- 후보23deb531c502a4d5fd109bc7faff8e54c59524af/tree77d532d806c004e17ca3e51a861cba05f7af2fce.
- EN1잎의 years earlier만 제거·본문 inverse/문단/name/digits/비소유 byte exact. 새 만남/연락/기간/상태0·release 정렬 불필요.
- 표적5 actual0·selection36은 실행 아님. KO tracked collector 입력 불변, 650 공식 inventory3/manifest9471d2adbc7ab614ecfa9168c91f8ed17279ea0d809355ad4137af80a831f879는 이전 증거 재사용이다. 새 inventory0/새 번역수용0·INCOMPLETE/native OPEN/invalid117·44·42.
- 비저자 a1_qa_release_audit GO_SOURCE_FACT_ONLY·차단0. root 전문/1제품/4증거/3이전 inventory 핀 확인.
- .git/order651-20261015/review.md4273B/SHA256841787116d99886abd0a658e87109fce87e6e933f6f6b5260512efc1a66b7aa8.
- review.json4574B/SHA256cc8bceb6c4dab830268503845b8ce1151d8a7e8d017a8fab576263fa5b705c51. 같은 폴더 map/proof/targeted/inventory-reuse가 실제 후보·원문·검사·재사용 경계를 결속한다.
- 부팅 출력 일부 잘림은 CLAUDE/큐 개별 전문 읽기로 복구했고, 이미 main이 읽은 필수 서사 정본은 6216a1bd 불변 확인 후 재사용했다.
- 실제M18/M55/native/전체체인/5언어/352선행/출시 HOLD·engine/전체audit/자연240/새checker0·사용자 저장/설정/project/demo/human 보존·612 dirty4 제외/새월0.
- 다음은 M56 missed4잎 별도 수리이며 M57 발견2잎은 미착수다. 일회성/새 정본 승격0·개발스킬 표적·독립·보존 적용.
자동 게이트는 도달 가능성과 계약 충족의 증거이지 재미·깊이·문체의 증거가 아니다.
