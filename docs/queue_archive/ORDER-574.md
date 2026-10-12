# ORDER-574 — 구저장 호환 연락처 화면 중국어 번역

#### [x] ORDER-574 [현지화·호환 UI] 번역 수용 완료 — 2026-10-12

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

## 마감 — 구저장 호환 UI source 번역 한정

선언1e0859fddcc6a7b525139399a453532487f59288/tree
24bd68ade64d2118e333584ab4dd12c2bcbfa5d1를 먼저 commit/push했다.
CN/TW 각각 KO23 직접 저작·공식 export/check/import --accept actual0이다.
독립 manual_save_ci가 KO23↔최종46 전수 의미·receipt/제품3을 판독해 blocker0,
source/receipt GO다. CN의 끼니→저녁 한정·감사를 못한 시간부족 이유 추가·
혼합 화법3곳을 import 전에 고쳤다. TW는 KO 직접 별도 저작, 중역/간번 변환0이다.

| 완료 증거 칸 | 실제 값 / 소비자 |
|---|---|
| 도달 경로 | source 판독: MainGame.gd:1533 → CoreLoopPlanner.gd:2448 → :1739 → :1863; native 실행0 |
| 생산자 ↔ 독자 | locale/ui_zh-CN.json:2183 / ui_zh-TW.json:2183 ↔ scenes/CoreLoopPlanner.gd:1865 / :3038 / :3100 / :3117 |
| 바꾸는 상태 | 선택 KO23의 CN/TW target null46 → 문자열46; accepted14720→14743씩·JA13169 불변 |
| 포기 시 잃는 것 | legacy people heading/수단/익명/관계23키; V2 enabled W1~24·non-episode·non-Seoul 경로 한정 |
| 서사 위치 | 구저장 호환 관계 요약; 정상 본편 월별 플레이0 |
| 장면 계층 | 해당 없음·새 장면/선택/효과/조건/플래그0 |
| 닫는 것 | 번역46/원receipt2/UI batch1; rendered/native-reader/human/pad OPEN |

공식 header는 선언 revision·source manifest
c13d47f56851ab9f26567d53a53db1f13e39d5931881f8f1bd2c7ab91a71e19b 그대로다.
원 receipt semantic digest CN d98a3824e38f627b57a6ce280bde9c033b786012edf1873e13ed9499793c42c9,
TW e495ca5219ad76def2c56f88654b469d7513f684fabe315d188357c7baafecac를
portable batch에 보존했다. accepted checksum은
818062cf81457638087057f53407fa3ae15c01a21fcda7e3563d1df248621b7c다.
기존 accepted/batch316·JA 원본·원장 나머지 필드 불변, batch317이다.

| 제품 파일 | bytes | SHA256 |
|---|---:|---|
| locale/ui_zh-CN.json | 194892 | da7fa04c161c58164e47e12981c8f6b0e592e187dba004457a7ab3843449d123 |
| locale/ui_zh-TW.json | 195462 | 5151add19bc7a5c9e0af2ed37a8d484fc9577530df9aec8faa4655eda9085e28 |
| content/meta/full_game_localization.json | 11717684 | 176cd04ed859eb7fcc70d70e55e01254890d089957f98f3d53bc6e3ef4b2642e |

- import 후 표적7 명령 actual0: ZH all skeleton·JA UI·i18n coverage·
  demo localization all·story demo·공식 CN/TW inventory. 각 inventory invalid0,
  UI static2000/2980·missing980·receipted1920이다. 전역 INCOMPLETE/OPEN이며
  전체 UI 모집단은 정상 본편 노출률이 아니다. 명령 성공을 전체 번역 GO로 바꾸지 않는다.
- EN coverage/English zero-Hangul은 clean 선언 상태에서 actual0을 확인했다.
  이후 KO/EN/runtime exact 보존으로 귀속하며 이유 없는 재실행0이다.
  lane preview11 중 변경 없는 교환기/파이프라인 자체검사는 다시 돌리지 않았다.
  전체 audit/240주/엔진/컴파일/실제 입력/새 월0이다.
- 독립 rework_batch_plan의 12:21:21Z fresh 보존: 보호52/888·비소유3357·
  old573raw12 exact. 기존 validate_append로 4원본(JA 포함) 역방향 바이트·
  신규46receipt/batch1 PASS다. dirty 제품에는 committed current_proof GO를
  붙이지 않으며 커밋 뒤 신원/이력 확인과 구분한다. 검사/helper 변경0이다.
- 실제 raw는 .git/order574-20261012/의 batch/response·check-final-result.json·
  import-results.json·targeted-start/completions/completions-2.json·inventory2와
  독립 source/preservation 보고다. check raw SHA는
  471349d8107e8845ea4c6dab86b7f4babe7f1454209fbdc13e9ff70b33367300,
  import raw SHA는202c9bcf7229e2a2d3037eb3d29e63833f70256d139e5724c679eeba8ae7c513다.
  export 출력 자체는 private 재구성하지 않았고 공식 batch 원파일로 결속했다.

선행 CI38239853653은 runner 대기가 아니라 배정된 Godot job114779484619의
전체 audit step6 실행 중이었다(11:59:51Z,55분38초). 원인/완료는 미확정이다.
로그 조회의 unsupported400·목적 도구404 BlobNotFound는 원자료 보존,
취소/재실행/검사 수리0이다. preview 잘못된 옵션 결합은 올바른 호출로 고쳤고,
완료 전 inventory 파일 조회의 미생성 오류는 생성 뒤 읽기로 확인했다.
제품 게이트의 새 실패0이며 도구 호출 오류를 숨기거나 제품 실패로 바꾸지 않았다.

gangnamdream-dev/I18N의 직접 저작·소유·관찰 경계를 적용했다. 일회성/승격0,
M17/562 OS잠금 HOLD 하나·새 월0·사용자 잠금 해제 요구0·출시 HOLD다.
마감 metadata/context/queue/diff와 실제 commit/tree/first-parent/push·새 CI는
별도 확인하며 현황판 단독 후속 커밋0이다. 자동 계약 통과는 실제 재미/문체/
화면/원어민 GO가 아니며, 이번 source 비교 외 인간 증거를 발급하지 않는다.

root는 독립 source-review.md 전문14394B(SHA
818e99723ca655f54a9c1acae26b0b7cbca27324d47e65e3db926ac50d05537f),
preservation-review.md 전문3274B(SHA
bc735a3747e41c632cd09ec13435b0878ad7f5256205718aaed295f9d0bd5b0c),
preservation-final.json 전문10597B(SHA
8d06261ee68dabdfa767992e6fe13513e1d488dd8d4a48bb1825c25785e8f79d)를
읽었다. 보존 보조 비교의 self-digest 포함 false는 해당 필드를 뺀 공식 canonical
digest로 정정해20/20이며 원제품/receipt 변경0이다. 원 JSONL 단일JSON 조회·
없는 보조 필드 조회 오류도 보고에 보존했다. 마감 context/queue/diff actual0,
active78/in_progress76·max_batches2이며 기존 L3 판정은 그대로다.
