# ORDER-652 — M56 미룬 연락을 실패한 발신으로 회상하는 오류 수리

#### [~] ORDER-652 [정합] 아버지 접촉 missed 독자의 실제 답신 회수 — 2026-10-15

651 M55 source 사실 수리 마감 뒤 M56 confirmed4잎만 고친다.
실제 M18/612는 동일 수정 앱 재검수 HOLD·새 월0/열린 실제월1.
5출시언어 유지·KOEN 실제 확정 전 JA/zh 다듬기 중단/누락만.

## 실제 근거와 깊이 3문

W185 arc_y4_father_crisis_contact choice2는 오늘은 이동/통화할 수 없다는 답신을 보내며
father_crisis_contact_missed를 만든다. 후속 arc_y4_father_final_contact_missed 본문은
아버지에게 건 발신도 부재중 전화도 없었고, 병동 첫 연락과 자기 답신 시각이 남았다고 명시한다.
표현 선택 어느 것을 골라도 그 앞선 답신은 이미 성립한다. 보내지 않은 문장은 별도다.
GameState._chapter5_finale_father_snapshot은 exactly one 연락 flag일 때만 해당 mode를 잠그며
충돌/없음은 records_only로 둔다. missed==entry array index2다.
실제 W221 alive/passed 두 root에서 StoryMode의 typed reader가 이 row를 선택해 prepend한다.
현재 응답 없는 마지막 발신/last outgoing call은 source의 답신 미룸을 가짜 전화로 바꾼다.

row를 삭제하면 여행/연결통화/미룸/기록만의 서로 다른 접촉 기억을 잃는다.
앞선 선택의 실제 비용과 mode, W221 기록 다루기 선택과 후일 receipt는 남긴다.
같은 자리의 실제 대면/통화 기록과 경쟁하는 과거행위이지, 새로운 전화나 관계회복을 만들지 않는다.
아버지 생사 판정/의료/경제를 변경하지 않고 어느 생사에서도 실제 두 메시지만 회수한다.

## 정확한 소유

root:
content/events/arc_year3_drama.json, content/events_en/arc_year3_drama.json
arc_y5_father_trace_alive_exact 및 arc_y5_father_trace_passed_exact 각각
chapter5_finale_reads.texts[1][2] = KO2+EN2/총4잎.
두 잎은 실제 병동의 첫 연락과 이동·통화를 미룬 자기 답신의 날짜·시각만 말한다.
다른 texts row/description/DK/선택·효과·조건·금액·flag·indices·typed source·receipt·schema·코드·저장 불변.
missed라는 legacy mode 키나 과거 로그를 이주하지 않는다. 모호한 며칠/days는 불확정이므로 손대지 않는다.
JAzh/번역원장·자산음악·project·사용자 save설정/demo/human 불변.
실제 영향이 관측될 때만 content/meta/release_content_inventory.json의 영향 content SHA 및
docs/CONTENT_RATING_INVENTORY.md 동일 생성 셀 정렬·counts/IDs/다른축/public snapshot 불변.
큐2/사양/archive/CLAUDE현재행/WORK_LOG/.git/order652-20261015/ root 소유.
비저자 a1_qa_release_audit private review.md/json만·제품/Git/engine/UI/새agent 쓰기0.
612 월별 dirty4를 모든 커밋에서 제외한다.

## 표적 검수와 한계

4잎 전수 map·KOEN 의미·문단/name/digits·2원고 full inverse byte exact.
audit_select --list 선택만, audit/consistency/ENcoverage/영어한글/spine/continuity/chapter5_finale/release 표적8.
최종KO 기준 공식JA/CN/TW inventory 각1회·동결 번역의 freshness 차이를 숨기거나 수용하지 않는다.
context/queue/diff0·정확 staged path·독립 source 사실 한정 GO.
engine/전체audit/자연240/새checker/비용·최적화0.
실제M18/M56/native/전체부자관계·의료·후일체인/5언어/352선행/출시 HOLD.
M57 전달/자필 전제2잎은 다음 별도범위, M58 이상 미검수. 원고 모집단 추가0.
일회성 수리·새 정본 승격 없음.
자동 게이트는 도달 가능성과 계약 충족의 증거이지 재미·깊이·문체의 증거가 아니다.
