# ORDER-653 — M57 공통 본문이 미전달·미자필 분기를 덮는 오류 수리

#### [~] ORDER-653 [정합] 전달·동의는 실제로 선택한 경로에서만 회수 — 2026-10-15

652 M56 source 수리 마감 뒤 M57 confirmed KOEN2잎만 고친다.
실제 M18/612 동일 수정 앱 재검수 HOLD·새 월0/열린 실제월1.
5언어 유지·KOEN 실제 확정 전 JA/zh 다듬기 중단/누락만.

## 근거·깊이 3문

live W227 arc_y5_name_on_line_daeun_routed는 active_when:null로 모든
W219 회의 선택3종×W224 보관 선택2종을 받는다.
W224 custody1은 자기 파일 봉인 시각/미전달만 남긴다. 전달 시각은 custody0에만 성립한다.
W219 decision0은 이름을 긋고, decision2에서는 다은이 펜을 잡지 않는다.
자필 범위는 decision1에만 생산되며 W220 자필 원본 receipt도 그 경로만 열린다.
기존 typed readrow3×2는 이 사실을 정확히 구분한 뒤 공통 본문 앞에 prepend한다.
그런데 공통 본문은 전달 시각과 내가 쓴 범위를 무조건 덧붙여 두 미성립 사실을 만든다.

본문을 지우면 현재 접수창구·다은의 요구·네 가지 행정 선택의 장면 약속을 잃는다.
현재 동의를 먼저 묻는 요구만 남기고 이전 전달/자필은 이미 올바른 조건부 readrow가 회수한다.
철회/자기낮은한도/확인보류/다은자료제외가 경쟁하며 기존 typed receipt와 경제 결과{}는 보존한다.
새 전달·자필·동의·거래·법적 인증을 생산하거나 기존 길을 제한하지 않는다.

## 정확한 소유

root content/events/arc_pre_ending.json 및 content/events_en/arc_pre_ending.json:
arc_y5_name_on_line_daeun_routed.description 각1/총2잎.
첫 문단의 무조건 전달 시각만 제거하고 다은의 과거 자필 단정을 현재 동의를 묻는 말로 정렬한다.
문단/name/digits227 exact·다른본문/typed readrows/4choices/results/금액·효과·조건·flags·indices·receipt·코드/schema/저장 불변.
JAzh/번역원장·자산음악·사용자 save설정/project/demo/human 불변.
실제 영향이 관측될 때만 content/meta/release_content_inventory.json 영향 contentSHA와
docs/CONTENT_RATING_INVENTORY.md 동일 생성 셀 정렬·counts/IDs/다른축/public snapshot exact.
큐2/사양/archive/CLAUDE현재행/WORK_LOG/.git/order653-20261015/ root 소유.
비저자 a1_qa_release_audit private review.md/json만·제품/Git/engineUI/새agent 쓰기0.
612 월별 dirty4는 모든 커밋에서 제외한다.

## 검증·한계

2잎 전수 map·한영 의미·3×2 조합의 producer/readrow/공통 본문 대조·2원고 full inverse byte.
audit_select --list 선택만·audit/consistency/ENcoverage/영어한글/spine/continuity/chapter5_finale/release 표적8.
공식 JA/CN/TW inventory 각1회·수용0/다듬기0/동결 freshness 차이 보존.
context/queue/diff0·정확stage·독립 source 사실 한정 GO.
engine/전체audit/자연240/새checker/비용·최적화0.
실제M18/M57/native/전체명의·경제·후일체인/5언어/352선행/출시 HOLD.
M58 기억물 기간·글귀3잎은 다음 별도범위, M59 이상 미검수. 이 원고 모집단에 추가0.
일회성 수리·새 정본 승격 없음.
자동 게이트는 도달 가능성과 계약 충족의 증거이지 재미·깊이·문체의 증거가 아니다.
