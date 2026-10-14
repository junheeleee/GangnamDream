# ORDER-633 — 갈림길 선택 뒤 실제 후행 회상 연결

#### [~] ORDER-633 [정합] 독자 선후·미보장 인맥 사실 최소 수리 — 2026-10-15

실제 M18/612 하나 HOLD·새월0. 접근복구시 동일M18 우선, CI빨강 새월0.
5출시언어 유지·KOEN확정 전 JAzh다듬기/기존수용0·신규누락만 채운다.

## 근거·깊이 3문

MainGame7452..7456 promises t153은 crossroads8426..8429 t154..170보다 앞선다.
현재 관측한 정상 선후에서는 기존 독자가 선택 뒤 회수하지 못한다.
기존 plays_hand는 돈·기술·연락할 사람의 항목만 적어도 응답/창구를 보장한다.
사건 시간을 옮기면 보호된 주차와 다른 사건이 바뀌므로 기존 후행 단일독자
arc_final_year_start에 같은 선택의 회고를 추가한다. W192 year4_close→
W193 reckoning→final_year_start 공통 followup 및 W193..208 복구는 기존대로다.
삭제하면 세 선택의 실제 후행 독자가 없어지고, 24주 뒤 기존 선택 flags는 구별된다.
후행 회고는 23~39주 뒤이며 24주 즉시회수/자연240/UI 관찰을 주장하지 않는다.
기존계획 유지·방향수정·현재항목 확인이 같은 자리에서 경쟁한다.

## 정확한 소유

root:
- content/events/arc_chapter_themes.json 및 content/events_en/arc_chapter_themes.json:
  arc_y4_three_promises / _jiyeon_and_deal / _deal_only 의
  description_memory_if_known.plays_hand KOEN6잎만 사실 중립화.
  구저장 호환을 위해 map/key/순서와 다른 기억을 보존한다.
- content/events/arc_midgame.json 및 events_en/events_ja/events_zh-CN/events_zh-TW의
  arc_midgame.json: arc_final_year_start에 description_memory_if_known 신규3잎씩.
  arc_year_three_crossroads_seen&never_stop / &pivoted_to_safe / &plays_hand
  기존 seen+선택flag로만 회고하며 outcome만 있는 고아flag는 읽지 않는다.
  총 신규15잎·기존수리6잎. 기존 본문/DIK/선택/효과/flags/게임수치/주차 불변.
  JA/CN/TW는 KO에서 각각 직접 작성한 신규누락9잎만; 기존번역/수용원장 불변.
- tools/ProseRecallCheck.gd: 기존 격리 test에 --crossroads-only 표적 prepared case 추가.
  정상337case/marker/기존검사 불변·새상시검사/새도구/성능사업0.
- 내용지문 실제stale일 때만 release_content_inventory.json 해당hash와
  docs/CONTENT_RATING_INVENTORY.md 실제생성 동일행 최소정렬.
- 큐2/이사양/archive/CLAUDE현재행/WORK_LOG/.git/order633-20261015/ 증거.

독립 a1_qa_release_audit: .git/order633-20261015/review.md 및 review.json만.
저자와 파일소유 분리·추가agent0·독립검수자 제품/engine/UI/Git 쓰기0.
612 월별 metadata는 선언/제품/마감 모두 제외·월별한commit 유지.
사용자 저장/설정/project/preset/BuildInfo/공개demo/human/기존raw/app 불변.
기존 CJK early plays_hand9잎 사실채무는 동결중 남으며 5언어 wholechain GO0.

## 검증·판정 경계

audit_select --list 후 기존 관련정적검사만. chapter4_causal_route_audit /
arc_flow_sim / ENcoverage / i18ncoverage / narrative·schema·locale 신규leaf검증.
ProseRecallCheck는 기존 StoryNameplateBootstrap + fresh HOME/3XDG/UUID namespace로
autoload 전 격리. 5locale 각 noflag/seen-only/outcome-only/3single/멀티flag,
현재reckoning DIK3×상기상태, 생산선택3의 적용→후행회고/state불변을 확인한다.
marker+exit0+stdout와Godotlog parse/script/engine오류0 모두 필요하다.
전체audit/자연240/실제UI/새월0·source/준비형consumer≠native/인간/출시GO.
새도구를 찾기 전에 rg --files로 실제 경로와 기존 opt-in fixture를 확인한다.
KO확정 뒤 official locale inventory는 각1회 관측·수용0.
L2 전수21잎/문단·토큰·비소유byte역변환, independent 전수 source 판정.
일회성 지시·새정본승격0.
자동 게이트는 도달 가능성과 계약 충족의 증거이지 재미·깊이·문체의 증거가 아니다.

