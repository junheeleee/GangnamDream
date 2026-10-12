# ORDER-574 — 구저장 호환 연락처 화면 중국어 번역

#### [~] ORDER-574 [현지화·호환 UI] 착수 — 2026-10-12

ORDER-157의 전체 번역 위임 안에서 현재 CoreLoopPlanner가 읽는 23키의
CN/TW 누락46개만 채운다. 정상 full-story 입구의 누락이나 월별 실제 관찰로
세지 않는다. 기준 main73e108377e481d524b0b5550d75a1ac6d835e2fe/tree
612e3d192338b2fc433000364f96e9ab5b0d52fb다. 선행 CI38239853653은
11:59:51Z static success/Godot 전체 감사 step6 in_progress이며 녹색 미확정이다.
M17/562 하나만 OS잠금 HOLD·새 월0, 사용자 잠금 해제 요청0을 유지한다.

## 깊이 3문·실제 소비자

1. 번역이 없으면 구저장 연락처의 접촉 수단·만남 기록이 중국어 대신 EN으로
   나온다. 이 UI는 휴면 함수가 아니다. SaveManager의 legacy namespace load→
   GameState V2 state 보존→MainGame initialize_for_run→enabled W1~24의
   non-Seoul plan→_core_loop_v2_open_saved_plan→CoreLoopPlanner people 버튼→
   _open_info_view(2)→_build_people_surface→LocaleManager.ui→row로 읽힌다.
2. 이미 고른 행동/관계 stage·memory를 설명할 뿐 선택·24주 결과·저장을
   바꾸지 않는다. 이름 미교환, 연락처 미교환, 아직 없는 다음 약속을 보존한다.
3. 동일한 호환 연락처 화면의 heading/수단/익명명/아버지·현수·다은 기록만
   묶는다. 새 버튼·기억·정상 본편 진입·기능 부활을 만들지 않는다.

| KO source key | CoreLoopPlanner.gd 소비자 |
|---|---|
| 지금까지 만난 사람 | _build_people_surface |
| 연락수단 · 저장된 전화번호 | _contact_method_copy |
| 연락수단 · 카카오톡 대화 | _contact_method_copy |
| 연락수단 · 받은 명함의 번호 | _contact_method_copy |
| 연락처 없음 · 찾아갈 편의점만 알고 있다 | _contact_method_copy |
| 연락수단 없음 · 전화번호나 메시지를 주고받지 않았다 | _contact_method_copy |
| 24시간 편의점 야간 직원 | _character_name |
| 검은 세단 운전자 | _character_name |
| 연락처는 저장돼 있다. 이번 달에는 아직 통화하지 않았다. | _relationship_copy/father |
| 짧게 통화했다. 서로의 목소리를 듣고 통화를 마쳤다. | _relationship_copy/father |
| 현수가 먼저 다시 공부하자고 했고, 같은 시간을 함께 쓰기로 했다. | _relationship_copy/hyunsu |
| 공용 주방에서 만난 현수에게 내가 먼저 카카오톡을 보내 함께 공부할 날을 잡았다. | _relationship_copy/hyunsu |
| 공용 주방에서 처음 이야기를 나눴다. 아직 함께할 약속은 없다. | _relationship_copy/hyunsu |
| 내가 다시 찾아간 뒤, 다음 화요일에도 서로의 한 주를 묻기로 했다. | _relationship_copy/daeun |
| 내가 다시 찾아간 뒤, 다음에는 서로 늦은 끼니를 거르지 않았는지 확인하기로 했다. | _relationship_copy/daeun |
| 이름을 안 뒤 다시 편의점에 찾아가, 내가 먼저 세 번째 대화를 시작했다. | _relationship_copy/daeun |
| 이름을 안 뒤 다시 편의점에 찾아가, 내가 먼저 다은의 야간 근무를 물었다. | _relationship_copy/daeun |
| 내가 다시 편의점에 찾아가, 다은의 이름을 불러 말을 걸었다. | _relationship_copy/daeun |
| 내가 다시 편의점에 찾아가, 다은에게 지난번 일을 고맙다고 말했다. | _relationship_copy/daeun |
| 내가 편의점에 다시 찾아가 먼저 인사했고, 이번에는 서로 이름을 알았다. | _relationship_copy/daeun |
| 내가 편의점에 다시 찾아가, 그날 못 한 고맙다는 말을 먼저 건넸다. | _relationship_copy/daeun |
| 새벽 편의점에서 이름을 들었다. 다시 찾아갈지는 아직 정하지 않았다. | _relationship_copy/daeun |
| 새벽 편의점에서 인사만 나눴다. 이름은 아직 모른다. | _relationship_copy/daeun |

## 정확한 소유·독립 검수

- root: locale/ui_zh-CN.json, locale/ui_zh-TW.json의 위 신규 키,
  content/meta/full_game_localization.json accepted/checksum/UI batch1만.
- root: 큐2/이 사양(마감 archive)/WORK_LOG·CLAUDE 현재행, CN KO 직접 저작.
- mod_layer_ci: TW KO 직접 초안·private 응답만, tracked 편집0.
- manual_save_ci: 실제 KO23/target46·소비자·공식 receipt 독립 검수만.
- rework_batch_plan: fresh before/final 보존·4파일 exact inverse·비소유 검수만.

KO/EN/JA·게임 runtime/조건/효과/플래그·검사/collector·source manifest·
project/presets·출시 언어·공개 데모 원문/pin·사용자/공개 저장/설정·Human/
과거 판정·옛 raw/seed/app은 비소유다. 새 도구/검사/등록·검증비용/재사용
최적화·엔진/컴파일/실제 입력·전체 audit/240주·새 월0이다.

## 수용·마감

선언 commit/push 뒤 공식 export/check/import --accept로 신규 잎만 처리한다.
JA 존재·CN/TW 이전값 null·protected=false를 확인하고 KO에서 각 지역어를
독립 저작한다. root의 소비자 열람 중 인접 EN 노출은 공개하며 중역·간번 변환0이다.
원receipt header/digest를 portable batch에 보존하고 기존 accepted/batch/사전
prefix와 4파일 역방향 바이트를 확인한다. 기존 UI append verifier를 바꾸지 않는다.
표적 언어/원장·i18n coverage·EN 한글·데모·context/queue/diff만 검사한다.
새 실패0·독립 source/receipt·비소유 GO 뒤 한정 번역 수용으로 닫는다.
실제 화면/원어민/인간/물리패드 OPEN·전체 번역 INCOMPLETE·출시 HOLD다.
강남드림 개발 스킬/I18N 정본을 적용하며 위 모집단·소유·검증은 일회성/승격0이다.
