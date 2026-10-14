# ORDER-632 — 갈림길의 지속 이력·보유 자원 단정 수리

#### [~] ORDER-632 [정합] 3년 관성·수면/확률·돈/사람 목록 — 2026-10-15

KOEN 월순서 사실 수리다. 실제M18/612 하나HOLD·새월0·5언어유지·
JAzh다듬기/수용0·누락만·맥 접근 복구시 같은M18 우선이다.

## 근거·깊이 3문

MainGame8426..8429는 t154..170/reality_check_seen만으로 갈림길을 연다.
돈·기술·실패·연락할 사람·계획의3년지속·수면·미래도착확률을 검사하지 않는다.
envy 두flag는 callback_envy_fuel_echo의 과거 선택 하나만 생산하며 오늘까지
매일 같은 분노/비교·덜무서움의 지속을 보장하지 않는다. trusting_instinct는
egg_deja_vu가 실제밤의 선택을 생산하므로 이번 변경대상이 아니다.
현재 횡단보도 선택과 실제 확인한 항목만 쓰는 목록으로 바꾼다.
삭제하면 never_stop/pivoted_to_safe/plays_hand→three_promises 기억독자를 끊는다.
24주 뒤까지 원래 flags/선택결과 효과는 유지하며 새상태를 추가하지 않는다.
같은 자리는 기존계획 유지·방향수정·현재자원 확인이 경쟁한다.
M39 세 promises의 plays_hand가 응답할사람이 있었다고 역추정하는 debt는 별도후속,
source 한정 GO를 chain GO로 확대하지 않는다.

## 정확 소유

root content/events/arc_midgame.json 및 content/events_en/arc_midgame.json의
arc_year_three_crossroads만. choices[0..2].result_text 6잎·choices[2].text 2잎,
description_if_known.envy_released/envy_still_burning 4잎, 총12잎이다.
choice0은 지금 건너는 행동/계획유지, EN appointment는 KO에맞는 행동으로;
choice1의 수면회복/도착확률 두사실은 알수없는미래로;
choice2는 긍정자원/실패학습/응답인맥/두페이지/충분함 대신 확인목록 작성으로 고친다.
envy DIK는 실제 과거 선택과 현재 회고를 분리한다. choice result 각3문단,
각name1·DIK각4문단/name1·DIK앞2/끝문단·key순서 유지.
base description·trusting DIK·choice0/1text·제목·조건·효과·flags·다른사건·
코드/경제/저장/자산/음악/JAzh/번역원장/project/preset/BuildInfo/공개데모 불변.
새목록UI/계획편집기/상태/flag/기능을 만들지 않는다.

release 내용지문이 실제 stale일 때만 content/meta/release_content_inventory.json의
해당 내용hash와 실제생성보고 docs/CONTENT_RATING_INVENTORY.md 동일지문만 최소정렬한다.
root 큐2/이사양/archive/CLAUDE현재행/WORK_LOG/.git/order632-20261015/ 증거 소유.
독립 a1_qa_release_audit는 private review.md/review.json만 소유한다.
추가agent/engine/UI/Git변경/대규모보호census/검사신설/479·481사업0.
612월별metadata는 한커밋마감 전까지 이번선언/제품/마감commit에서 제외한다.
기존앱/격리W69/구raw불변·old native핀새HEAD실행허가 아님.

## 검증·한계

12잎 전수 KOEN·생산자/독자·전체파일 byte 역변환·비소유 보존 확인.
audit_select --list 뒤 관련기존비엔진검사만·전체audit/engine/자연240/새월0.
KO변경 official JA/CN/TW inventory각1회 관측만·수용/원고쓰기0.
context/queue/self/diff·현황판advisory/전용commit0.
일회성·승격0·구저장산문 migration0·source≠월/chain/native/5언어/인간/출시GO.
자동 게이트는 도달 가능성과 계약 충족의 증거이지 재미·깊이·문체의 증거가 아니다.
