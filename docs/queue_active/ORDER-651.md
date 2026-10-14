# ORDER-651 — M55 영어 카페 회상의 잘못된 수년 경과 수리

#### [~] ORDER-651 [정합] 이전 카페 만남을 수년 전으로 늘리지 않는다 — 2026-10-15

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
