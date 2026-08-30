# 강남드림 — 현재 상태

> **자동 생성 문서다. 손으로 고치지 않는다** — 다음 생성에서 지워진다.
> 값을 바꾸려면 이 파일이 아니라 원본(큐 표·정본 JSON·콘텐츠)을 고친다.
>
> 재생성: `python3 tools/project_dashboard.py --md docs/STATUS.md`
> 전 구간 선택 그래프를 대화형으로 보려면:
> `python3 tools/project_dashboard.py` → `build/project_dashboard.html`
>
> 생성 시각 · 커밋: `2026-08-30 15:43 UTC · 66718fd5`

**개발용이다.** 아래는 `tint`·`route_*`와 정확한 수치를 그대로 적는다.
플레이어에게 노출하지 않는 값이므로 이 문서를 플레이어 대상 자료로 쓰지 않는다.

## 사람만 할 수 있는 판정

**초록불은 계약을 지켰다는 뜻이지 좋다는 뜻이 아니다.** 아래는 자동 검사가
대신할 수 없어 남아 있는 것이며, 원장은
[`human_gates.json`](human_gates.json)이 소유한다.

> **활성 demo_rc 주의:** 데모 제품 경계는 W1~24 CTA다. BUILD 2026.08.22.1은 숫자 여력 네 장을 쓰는 `서울의 네 주` active 내부 demo_rc다. exact clean revision ebc58a839d64d8810b9da5548c20e58bc43c9e30 / tree f978a22525b678ef83619dc50094a6dada75f190, manifest 8a34920038962a4ba0885ad6189d92dc6d3c3ee2780020f3894938d380613177와 세 artifact hash를 BUILD_PIPELINE이 소유한다. exact detached 재검증에서 full/surface matrix와 InputMatrix·Controller·GameAudio·DemoBuild·PlaytestFlavor marker가 PASS했고, InputMatrix의 계약상 허용된 리소스 3개 종료 noise 밖 금지 오류는 0이다. 증거 root는 build/qa/order98-demo-rc-rebind다. BUILD 2026.08.11.2 / 573606은 역사 후보이고 order99 BUILD .3 저장 게이트는 별도 고정이다. 자동 증거는 사람·실기기·연속 A/V·원어민·출시 GO를 대신하지 않으며 외부 30분 package/session은 미발급이다. ORDER-124 BUILD 2026.08.24.3은 story_demo_rc가 대체한 역사 후보이고 story-first 본편 이관은 HOLD다.

| 범위 | 판정 | 후보 | 표본·환경 | 합격 기준 | 소유 |
|---|---|---|---|---|---|
| activity_task_expansion · 3개월 나흘 야간 재고조사의 세 작업 대상, 보통 완료, 무리하기, 결과 장면과 다음 달 기억 | **재고조사 약속 수행 장면의 행동감**<br><sub>자동 검사는 조합·수치·저장·입력을 증명한다. 두 번의 선택이 실제 일을 처리한 감각인지, 웹 버튼 퀴즈인지 판단하지 못한다.</sub> | `demo_rc · ACTIVE ebc58a83 / manifest 8a349200` | inventory_task_first_play<br>같은 demo_rc에서 키보드 또는 패드로 재고조사 수행 장면을 처음부터 결과 장면까지 진행<br>보통 완료 한 번과 무리하기 한 번을 서로 다른 저장에서 비교 | 플레이어가 자신이 처리한 일, 남긴 일, 그 대가를 자기 말로 설명할 수 있음<br>선택이 숨은 정답 찾기나 웹 버튼 퀴즈가 아니라 실제 주간 약속을 수행하는 감각으로 읽힘<br>수행 화면과 결과 산문이 한 장면처럼 이어지며 다른 행동으로 확산할 근거가 생김 | `ORDER-92` |
| chapter5-finale, claim:full-play-ready · 같은 chapter5_finale_rc에서 M49 계약 원문부터 M60 마지막 선발신·엔딩 후일담까지 이어지는 KO 기준 경로 | **5장 M49~M60 정상 속도 인과·격동·결말 체험**<br><sub>자동 검사는 19+9개의 장면 기능, 선택 영수증, 무이체와 엔딩 연결을 증명한다. 계약 문서가 사람 사이의 압박으로 읽히는지, 마지막으로 갈수록 더 치밀해지는지는 정상 속도 플레이어만 판정한다.</sub><br><strong>판정: Claude(사용자 위임) — 조건부 · 재작성: arc_y5_property_not_executed_notice, arc_y5_remaining_jaehyuk_or_self, arc_y5_final_father_answer_passed, arc_final_countdown_property_not_executed</strong><br><sub>판정: Claude(사용자 위임) — CONDITIONAL. 방법은 이전 회차와 다르다. 실제 MainGame 주간 우선순위 체인(causal→finale→arc→milestone)과 실제 StoryMode를 Godot 4.6.2로 구동해 W193~W240을 선택 세트 2개로 완주하고, 책턴5 KO 화면을 1280x800으로 렌더해 육안 확인했다. 이전 반려 2건은 닫혔다. W207 선택 2는 화면에서 배경 cafe·초상 daeun_normal·이름표 김다은으로 이동하고 선택 0·1은 meeting·상철을 유지한다. W230은 출입문→민서 입장→빈 의자 착석이 민서의 첫 현장 행동보다 먼저 오며 cafe·무초상이다. W217 다은 블레이저와 W220 arc_y5_room_consent_receipt 무초상도 유지된다. 밀도는 48주 중 39주가 작성 뿌리를 가지고 최장 공백 4주, 47장면 22352자, 실제 선택 레일 37개이며 W235→W238→W239→W240 서명→같은 턴 다은 선발신→선택별 엔딩 후일담까지 상승이 작동한다. 허위 소유·이체·읽음·답장·재회 0. 조건은 종막 뿌리가 모두 영수증 한 줄 문단 더미로 열리는 점이다. W240은 본 장면 전에 넨 줄이 먼저 놓여 마지막 밤이 색인으로 시작한다. 인과 회수 장치 자체는 유지하되 최소 두 줄을 장면 첫 이미지에 융합할 것을 권고한다. 연속 오디오·물리 패드·EN 패리티·움직임 속 전환 체감은 이 회차에서 판정하지 않았다.</sub><br><sub>정본 서명: 사용자 최종 GO 대기</sub> | `chapter5_finale_rc · ACTIVE 002a493d / manifest 7ada31a8` | chapter5_finale_first_normal_reading<br>새로 발급된 동일 chapter5_finale_rc에서 M49~M60을 건너뛰기 없이 정상 독해 속도로 진행<br>M53 보증과 M55 공동 결정에서 무엇을 포기했는지, M57 접수와 M60 서명이 무엇을 바꿨는지 유도 없이 기록<br>검은 화면·장면 중복·주차 건너뜀·선택 뒤 허위 이체나 답장이 없는지 연속 확인 | 문서가 정보 카드가 아니라 상철·다은·민서·재혁과의 압박과 책임으로 읽힘<br>M49~M60의 긴장이 엔딩으로 갈수록 되풀이가 아니라 더 좁아지는 선택과 실제 포기로 상승함<br>무이체 결말이 빈 결말이 아니라 닫힌 문·쓴 시간·먼저 보낸 말의 결과로 남고 사용자 최종 GO | `ORDER-134` |
| chapter5-finale, claim:full-play-ready · 같은 chapter5_finale_rc의 general_near_goal_father_passed 경로에서 M49부터 W240 서명·같은 턴 선발신·엔딩 후일담까지 이어지는 KO 기준 체험 | **5장 일반 문턱 경로 M49~M60 정상 속도 선택 회수**<br><sub>자동 검사는 M51·W220·M56·M59의 정확한 선택이 W237의 오늘 포기와 W240의 실제 삭제·선발신에 도달함을 증명한다. 그 회수가 장부 정리가 아니라 기억과 사람의 압박으로 읽히고, 끝으로 갈수록 실제로 좁아지는지는 정상 속도 플레이어만 판정한다.</sub><br><strong>판정: Claude(사용자 위임) — 전량 반려</strong><br><sub>판정: Claude(사용자 위임) — REJECT. 방법은 실제 MainGame 주간 우선순위 체인과 실제 StoryMode를 Godot 4.6.2로 구동한 W193~W240 완주 2회와 챕터5 KO 1280x800 렌더 검수다. 픽스처 기준선은 실제 192주 챕터5 세이브 사본이다. 이전 반려 사유 가운데 둘은 닫혔다. W237은 색인·첨부·봉인 정리가 아니라 ‘오늘 남은 삼십 분을 어디에 쓸 것인가’가 주동사이고 양쪽 가지 모두 실제 비용을 남긴다. W240은 세 주소 삭제 또는 수첩 첫 장 30억 두 줄 삭제라는 되돌릴 수 없는 행동에 영수증을 남기고 같은 턴 선발신과 선택별 엔딩 후일담으로 이어진다. W220→W224 회수도 선택별로 화면에 실제로 붙는다. 막는 사유는 둘이다. 첫째는 모양이다. 48주 중 28주만 작성 뿌리를 가지고 20주가 비며 W225~W233이 9주 연속, W238~W239가 2주 연속 작성 전경 사건 없이 제네릭 표면으로 떨어진다. 같은 48주에 property는 39주·최장 공백 4주· 22352자인데 general은 17003자로 24% 적다. 마지막 분기가 조여지지 않고 얇아진다. ORDER-135가 선언한 결함이 뿌리 4개로는 닫히지 않았다. 둘째는 W224 품질이다. 아버지 기일 주에서 W220 회수가 장면의 마지막 이미지 뒤에 각주로 붙고 ‘그 녹음의 시각이 오늘 사진 옆 약봉지의 날짜와 이어졌다’처럼 연결을 설명한다. 선택지는 옛 제네릭 3개 그대로여서 플레이어는 회수를 읽되 그것으로 행동할 수 없고, 한 가지는 65자 결과로 끝난다. 이 프로필의 인간선 정점이 그 해에서 가장 약한 작성 비트다. 무응답·미소유·무이체· 아버지 불부활·혼자 있는 W240·검은 화면·잘림 0은 보존됐다. 연속 오디오·물리 패드·EN 패리티는 이 회차에서 판정하지 않았다.</sub><br><sub>정본 서명: 사용자 최종 GO 대기</sub> | `chapter5_finale_rc · ACTIVE 002a493d / manifest 7ada31a8` | chapter5_general_near_goal_first_normal_reading<br>정확히 active인 chapter5_finale_rc에서 W193 뒤 자동 진행 없이 M49~M60을 정상 독해 속도로 진행<br>앞일을 보지 않고 M51·W220·M56·M59를 선택한 뒤 W237의 오늘 비용과 W240 실제 포기·선발신에서 무엇이 되돌아오는지 기록<br>검은 화면·장면 중복·허위 답장·소유·이체와 민서·아버지의 허위 동석이 없는지 연속 확인 | 앞선 선택이 장부 요약이 아니라 현재의 압박과 구체 행동으로 돌아옴<br>비트 수 할당 없이 긴장이 W240으로 갈수록 반복이 아니라 더 좁아지는 해석과 실제 사람 행동으로 상승함<br>혼자 있는 장소, 원격 민서, 별세한 아버지, 미소유 부동산, 무이체의 사실 경계가 끝까지 유지되고 사용자 최종 GO | `ORDER-135` |
| claim:controller · 공개 데모의 Steam Deck·DualSense·Switch Pro 지원 주장 | **물리 Steam Deck·DualSense·Switch Pro 실기기**<br><sub>InputMatrixCheck는 매핑과 글리프를 본다. 손에 쥐었을 때의 오작동은 실기기에서만 나온다.</sub> | `demo_rc · ACTIVE ebc58a83 / manifest 8a349200` | demo_physical_controller_matrix<br>Steam Deck·DualSense·Switch Pro를 각각 실제 장치에서 확인<br>배포 대상 플랫폼 패키지와 동일한 demo_rc 사용 | 각 장치에서 잘못 누름·포커스 소실·입력 지연 없이 데모 진행<br>Steam Deck에서 장면 전환 프레임 드롭과 셰이더 컴파일 끊김이 체험을 훼손하지 않음 | `USER-P0N` |
| claim:ja · 일본어 본문·엔딩·카탈로그를 출시 언어로 표시하는 주장 | **일본어 원어민 검수**<br><sub>커버리지 검사는 키 누락과 한글 누출을 잡는다. 자연스러움은 원어민만 안다.</sub> | `full_rc · ACTIVE 6c91e11c / manifest 1cef15ff` | ja_native_release_review<br>일본어 본문·엔딩·카탈로그와 대표 15장 캡처<br>게임 문맥을 아는 일본어 원어민 검수자 | 의미 반전·누락·한글 누출·번역투가 출시 표면에 없음<br>원어민이 자연스러운 일본어 출시본으로 GO | `ORDER-21` |
| claim:ja-demo, demo-release · 같은 demo_rc의 실제 24주 일본어 장면·선택·계획판·연락폰·오프닝·CTA | **일본어 24주 데모 원어민 문맥 검수**<br><sub>완전성 검사는 누락과 영어 우회를 잡는다. 한국어 정본의 인물 목소리·관계 거리·함축·돈의 체감·선택 인과가 자연스러운 일본어 장면으로 남았는지는 원어민의 직접 대조가 필요하다.</sub> | `demo_rc · ACTIVE ebc58a83 / manifest 8a349200` | ja_demo_native_context_review<br>게임 문맥과 한국어를 함께 이해하는 일본어 원어민 검수자<br>같은 demo_rc에서 ja_translation_audit.py --scope ui 및 --scope demo --strict PASS: legacy UI 2,816/2,816·context UI 29/29(총 UI 2,845/2,845)·72사건·467본문·701동적·4자산<br>같은 demo_rc를 새 세이브로 시작해 24주와 CTA까지 정상 속도로 독해<br>한 경로에 나오지 않은 합법 도달 72개 사건과 모든 선택·결과를 한국어 정본과 직접 대조 | 오역·누락·한글 누출·불필요한 영어 혼용·번역투가 없음<br>인물별 말투와 관계 거리, 대화의 함축과 여운, 원화 금액의 체감, 선택과 결과의 인과가 한국어 정본과 같은 장면으로 읽힘<br>원어민이 일본어 24주 데모 주장에 GO | `ORDER-81` |
| claim:ja-story-demo · story_demo_rc의 M01~M06 실제 11사건·모든 선택·결과·도달 UI 117개 일본어 표면 | **M01~M06 story demo 일본어 원어민 출시 claim 검수**<br><sub>구조·fallback·폰트·화면 자동 검사는 자연스러운 인물 말투와 한국 생활 맥락의 설명량을 승인하지 못한다. 로컬 플레이는 가능하지만 일본어 지원을 출시 언어로 주장하기 전 원어민 직접 대조가 필요하다.</sub> | `story_demo_rc · ACTIVE 16675f6c / manifest 90ca3643` | story_demo_ja_native_context_review<br>한국어 정본과 게임 문맥을 함께 이해하는 일본어 원어민 검수자<br>exact story_demo_rc BUILD 2026.08.25.1과 story_demo_localization_audit.py PASS 11사건·82 leaf·UI 117을 사용<br>M01 두 선택, M02 두 경로, M03~M05, M06 다섯 선택과 결과를 한국어 정본에 직접 대조하고 960×600·1280×800 실제 화면을 확인 | 오역·누락·한글 누출·불필요한 영어 혼용·번역투가 없음<br>인물 말투·관계 거리·원화와 고시원 등 한국 맥락·선택 인과가 자연스러운 일본어 장면으로 읽힘<br>Noto Sans JP 자형·줄바꿈·안전영역에 원어민 GO | `ORDER-126` |
| claim:zh-CN-demo, demo-release · 같은 demo_rc의 실제 24주 zh-CN 장면·선택·정적 UI·계획판·연락폰·오프닝·CTA | **중국어 간체 24주 데모 중국 본토 원어민 문맥 검수**<br><sub>엄격 검사는 누락·문자권·원화·글꼴을 잡지만 한국어 정본의 인물 목소리·관계 거리·함축·여운·한국 문화 설명량이 중국 본토의 자연스러운 장면으로 남았는지는 원어민의 직접 대조가 필요하다.</sub> | `demo_rc · ACTIVE ebc58a83 / manifest 8a349200` | zh_cn_demo_native_context_review<br>한국어와 게임 문맥을 함께 이해하는 중국 본토 원어민 검수자<br>해당 demo_rc에서 zh_translation_audit.py --lang zh-CN --strict PASS: legacy UI 2,816/2,816·context UI 29/29·72사건·467본문·701동적·4자산과 프로젝트 소유 SC 글꼴 준비 완료<br>같은 demo_rc를 새 세이브로 시작해 24주와 CTA까지 정상 속도로 독해<br>한 경로에 나오지 않은 합법 도달 72개 사건과 모든 선택·결과를 한국어 정본과 직접 대조<br>SC 글꼴이 JP 공유 한자보다 먼저 선택되는 실제 화면을 Windows·macOS·Linux/Steam Deck에서 확인 | 오역·누락·한글·가나·미번역 영어·지역 문자 혼용·번역투가 없음<br>인물별 말투와 관계 거리, 대화의 함축과 여운, 원화 금액의 체감과 모든 날짜·시각·기간·횟수·부호, 한국 문화 설명량, 선택과 결과의 인과가 한국어 정본과 같은 장면으로 읽힘<br>공식 근거 없는 인명 한자가 없고 실제 SC 자형·줄바꿈·안전영역이 자연스러움<br>중국 본토 원어민이 zh-CN 24주 데모 주장에 GO | `ORDER-82` |
| claim:zh-CN-story-demo · story_demo_rc의 M01~M06 실제 11사건·모든 선택·결과·도달 UI 117개 zh-CN 표면 | **M01~M06 story demo 간체 중국어 원어민 출시 claim 검수**<br><sub>엄격 검사는 간체 문자·SC primary·토큰·구조를 잡지만 중국 본토의 자연스러운 어휘, 인물 온도와 한국 문화 설명량을 승인하지 못한다. 로컬 플레이와 중국 본토 유통 주장은 분리한다.</sub> | `story_demo_rc · ACTIVE 16675f6c / manifest 90ca3643` | story_demo_zh_cn_native_context_review<br>한국어 정본과 게임 문맥을 함께 이해하는 중국 본토 원어민 검수자<br>exact story_demo_rc BUILD 2026.08.25.1과 story_demo_localization_audit.py PASS 11사건·82 leaf·UI 117, Noto Sans SC primary를 사용<br>M01 두 선택, M02 두 경로, M03~M05, M06 다섯 선택과 결과를 한국어 정본에 직접 대조하고 960×600·1280×800 실제 화면을 확인 | 오역·누락·한글·가나·미번역 영어·지역 문자 혼용·번역투가 없음<br>인물 말투·관계 거리·원화와 고시원 등 한국 맥락·선택 인과가 중국 본토의 자연스러운 간체 장면으로 읽힘<br>Noto Sans SC 자형·줄바꿈·안전영역에 원어민 GO | `ORDER-126` |
| claim:zh-TW-demo, demo-release · 같은 demo_rc의 실제 24주 zh-TW 장면·선택·정적 UI·계획판·연락폰·오프닝·CTA | **중국어 번체 24주 데모 대만 원어민 문맥 검수**<br><sub>간체 검수나 문자 변환은 대만의 어휘·관계 말투·자형·문화 설명을 승인할 수 없다. 한국어 정본의 장면성과 돈의 체감을 보존했는지는 대만 원어민의 별도 직접 대조가 필요하다.</sub> | `demo_rc · ACTIVE ebc58a83 / manifest 8a349200` | zh_tw_demo_native_context_review<br>한국어와 게임 문맥을 함께 이해하는 대만 원어민 검수자<br>해당 demo_rc에서 zh_translation_audit.py --lang zh-TW --strict PASS: legacy UI 2,816/2,816·context UI 29/29·72사건·467본문·701동적·4자산과 프로젝트 소유 TC 글꼴 준비 완료<br>같은 demo_rc를 새 세이브로 시작해 24주와 CTA까지 정상 속도로 독해<br>한 경로에 나오지 않은 합법 도달 72개 사건과 모든 선택·결과를 한국어 정본과 직접 대조<br>TC 글꼴이 JP 공유 한자보다 먼저 선택되는 실제 화면을 Windows·macOS·Linux/Steam Deck에서 확인 | 오역·누락·한글·가나·미번역 영어·지역 문자 혼용·번역투가 없음<br>인물별 말투와 관계 거리, 대화의 함축과 여운, 원화 금액의 체감과 모든 날짜·시각·기간·횟수·부호, 한국 문화 설명량, 선택과 결과의 인과가 한국어 정본과 같은 장면으로 읽힘<br>공식 근거 없는 인명 한자가 없고 실제 TC 자형·줄바꿈·안전영역이 자연스러움<br>대만 원어민이 zh-TW 24주 데모 주장에 GO | `ORDER-82` |
| claim:zh-TW-story-demo · story_demo_rc의 M01~M06 실제 11사건·모든 선택·결과·도달 UI 117개 zh-TW 표면 | **M01~M06 story demo 번체 중국어 원어민 출시 claim 검수**<br><sub>간체 검수나 문자 변환은 대만의 어휘·관계 말투·자형과 한국 문화 설명량을 승인하지 못한다. 로컬 플레이는 가능하지만 번체 지원 출시 claim 전 별도 원어민 대조가 필요하다.</sub> | `story_demo_rc · ACTIVE 16675f6c / manifest 90ca3643` | story_demo_zh_tw_native_context_review<br>한국어 정본과 게임 문맥을 함께 이해하는 대만 원어민 검수자<br>exact story_demo_rc BUILD 2026.08.25.1과 story_demo_localization_audit.py PASS 11사건·82 leaf·UI 117, Noto Sans TC primary를 사용<br>M01 두 선택, M02 두 경로, M03~M05, M06 다섯 선택과 결과를 한국어 정본에 직접 대조하고 960×600·1280×800 실제 화면을 확인 | 오역·누락·한글·가나·미번역 영어·지역 문자 혼용·번역투가 없음<br>인물 말투·관계 거리·원화와 고시원 등 한국 맥락·선택 인과가 대만의 자연스러운 번체 장면으로 읽힘<br>Noto Sans TC 자형·줄바꿈·안전영역에 원어민 GO | `ORDER-126` |
| core_loop_v2_month1_expansion · 새 V2 저장 1개월차의 네 주간 여력 배치부터 W3 현수 세계 사건과 W4 첫 유혹·월말 수첩까지 | **첫 달 서울 사이클이 게임으로 읽히는가**<br><sub>자동 검사는 네 여력·네 노드, 진전·대가·기한, 저장과 인과 소유권을 증명한다. 배치할 때 실제로 망설이고 다음 주 결과를 자기 결정으로 느끼는지는 사용자 플레이만 판정한다.</sub> | `demo_rc · ACTIVE ebc58a83 / manifest 8a349200` | demo_month1_seoul_cycle_first_play<br>같은 demo_rc의 새 저장에서 튜토리얼만 보고 첫 달 서울 사이클을 시작<br>네 번의 배치와 임계 수행·세계 사건·월말 수첩을 정상 독해<br>유도 문구 없이 가장 고민한 배치, 얻은 것, 치른 대가, 놓친 기회, 현수 첫 만남의 소유자를 말함 | 플레이어가 여력 하나를 어느 노드에 왜 배치했는지와 그 대가를 기억함<br>현수를 미리 계획한 것이 아니라 세계 사건으로 만났다고 이해함<br>임계 장면과 놓친 특별 기회를 앞선 주간 배치 결과로 연결함<br>화면을 카드 채우기나 정답 고르기가 아니라 한정된 힘으로 한 달을 운영하는 게임으로 받아들임 | `ORDER-94` |
| demo · 3월 방 안의 장부와 4월 주거복지 상담, 1년·5년 뒤 기억 회수 | **3·4개월차 생활 장면과 장기 기억 판정**<br><sub>자동 검사는 일반 결과 카드가 사라지고 기억이 다시 읽히는지 증명한다. 장면이 실제 경험으로 남고 후대 회상이 같은 선택을 새 의미로 돌려주는지는 사람이 읽어야 안다.</sub> | `demo_rc · ACTIVE ebc58a83 / manifest 8a349200` | demo_user_deep_scene_review<br>같은 demo_rc에서 3월 장부 장면을 정상 속도로 읽고 두 선택을 각각 확인<br>같은 commit/tree의 읽기 전용 개발 체크포인트에서 3월의 첫 청구서·1년차·2장·5장 회수를 확인<br>같은 demo_rc에서 4월 주거복지 상담의 세 기준을 각각 확인하고, 같은 commit/tree의 읽기 전용 개발 체크포인트에서 첫 이사·1년차·마지막 주 회상을 확인 | 3월 장부가 수치 결과 카드가 아니라 한 번의 생활 경험으로 남고 두 선택 모두 민준에게 가능한 답으로 읽힘<br>4월에 고른 방의 기준이 후대 장면에서 문장을 반복하지 않고 잔액·혼자 있을 공간·시간의 다른 의미로 돌아옴<br>사용자 최종 GO | `ORDER-83` |
| demo · Core Loop V2의 1~24주 전체와 주 25 진입 전 기록 CTA | **데모 24주 전환·사람 GO**<br><sub>자동 게이트는 도달성과 계약을 본다. 24주가 하나의 이야기로 읽히는지는 사람 판정이 남는다.</sub> | `demo_rc · ACTIVE ebc58a83 / manifest 8a349200` | demo_user_normal_reading<br>demo_rc를 새 세이브로 시작해 24주와 CTA까지 정상 독해<br>중간 저장·복귀를 포함해 장면과 월간 전환을 기록 | 1~24주가 끊긴 기능 묶음이 아니라 하나의 이야기로 읽힘<br>24주 회고와 CTA가 갑작스러운 차단이 아니라 다음을 궁금하게 만드는 종결로 작동<br>사용자 최종 GO | `ORDER-57` |
| demo · Core Loop V2의 1~6개월 네 여력·직업/생계/사람/회복 노드·세계 시계·임계 수행·다음 달 영수증으로 이어지는 24주 전략 | **주간 루프가 재미있는가 — 망설임과 전략**<br><sub>루프 검사는 선택지 수와 도달성을 본다. 망설였는지는 사람만 안다.</sub> | `demo_rc · ACTIVE ebc58a83 / manifest 8a349200` | demo_user_normal_reading<br>demo_rc 24주 정상 독해 플레이<br>망설인 장면·선택 원문과 다르게 플레이할 의향을 기록<br>24주 직후 유도 없이 이 게임에서 반복해서 한 일과 가장 재미있었던 행동을 한 문장으로 설명 | 같은 주에 함께 할 수 없는 네 노드와 기한 사이에서 실제 고민이 생김<br>월별 노드와 사건이 바뀌어 24회의 배치가 같은 선택의 복제로 느껴지지 않음<br>플레이어가 게임의 핵심을 한정된 시간을 배치하고 포기한 것의 대가를 뒤에서 사는 생활 선택으로 설명하며, 대화 버튼만 고르는 게임으로 축소해 기억하지 않음<br>다르게 플레이하면 다른 5년이 될 것 같다는 사람 GO | `ORDER-26` |
| demo · KO/EN 데모 1~24주를 정상 독해 속도로 진행하는 체험 | **정상 속도 데모 24주 플레이**<br><sub>페이싱 검사는 사건 수와 간격을 센다. 지루한지는 세어지지 않는다.</sub> | `demo_rc · ACTIVE ebc58a83 / manifest 8a349200` | demo_normal_reading_full_run<br>같은 demo_rc에서 KO와 EN 각 1회<br>처음부터 24주 CTA까지 정상 독해 속도로 진행<br>언어 선택부터 24주 CTA까지 실제 경과 시간과 연속 확인 입력으로 넘긴 구간을 기록 | 반복 입력과 장면 간격을 포함한 24주 몰입에 사람 GO<br>75~95분 pre-playtest 목표를 실제 경과 시간으로 유지하거나 재조정하고, 목표 밖 결과를 자동 완주 추정치로 덮지 않음<br>자동 완주나 추정 플레이타임을 사람 판정으로 대신하지 않음 | `ORDER-22` |
| demo · KO/EN 데모 1~24주의 장면·폰·월간 계획·첫 청구서 연속 A/V | **데모 24주 연속 A/V 청취**<br><sub>계약 검사는 큐 존재와 파일 재생을 본다. 24주 동안 침묵·반복·음량 피로가 장면 흐름을 깨는지는 연속해서 들어야 안다.</sub> | `demo_rc · ACTIVE ebc58a83 / manifest 8a349200` | demo_av_human_review<br>같은 demo_rc의 KO/EN 24주 경로를 헤드폰·노트북 스피커·거실 TV에서 연속 청취<br>저장·복귀와 장면/폰/결산 전환을 포함 | 대사 가독성·장소 식별·음악 피로·효과음 반복에 사람 GO<br>무음·잘린 큐·장면 밖 잔류·갑작스러운 음량 변화가 24주 흐름을 깨지 않음 | `ORDER-57` |
| demo · 데모 시작 흐름·장면·폰·선택·결산·CTA의 표면 물성 | **화면이 싸구려 웹 모달이 아니라 이 게임의 물건으로 보이는가**<br><sub>surface_coherence는 분열의 흔적을 센다. 세지 못하는 것은 통일된 화면이 좋은가다.</sub> | `demo_rc · ACTIVE ebc58a83 / manifest 8a349200` | demo_surface_human_review<br>KO/EN demo_rc를 720p·800p·1080p에서 검토<br>마우스·패드 양쪽으로 실제 선택과 폰 표면을 조작 | 화면이 범용 웹 버튼 묶음이 아니라 강남드림의 같은 물건으로 보임<br>표면 전환 뒤 폰트·테마·포커스·재질이 다른 제품처럼 갈라지지 않음 | `ORDER-63` |
| demo · 데모 주연의 같은 감정군 표정·자세·시선 연기 | **표정 문법 — 같은 감정을 인물마다 다르게 연기하는가**<br><sub>자산 검사는 파일 유무를 본다. 연기의 차이는 나란히 놓고 봐야 안다.</sub> | `demo_rc · ACTIVE ebc58a83 / manifest 8a349200` | demo_cast_identity_review<br>같은 감정군의 주연 표정·자세·시선을 나란히 검토<br>실제 demo_rc 장면 크기에서 확인 | 같은 감정도 인물마다 고유한 표정·자세·시선 문법으로 읽힘 | `ORDER-64` |
| demo · 데모에 노출되는 주연 6인의 64 px 실루엣 | **64 px 실루엣 — 인물이 64픽셀에서 구분되는가**<br><sub>서명표는 소품과 모티프의 존재를 센다. 알아보는지는 눈으로 봐야 한다.</sub> | `demo_rc · ACTIVE ebc58a83 / manifest 8a349200` | demo_cast_identity_review<br>같은 크기·무채색 조건으로 주연 6인을 나란히 검토<br>실제 demo_rc 화면과 원본 자산을 함께 확인 | 이름·색·배경 없이도 여섯 인물을 서로 구분할 수 있음 | `ORDER-64` |
| demo · 데모에 노출되는 주연의 대표 장면과 고유 소품·욕망·모순 | **장면 소유 — 다른 인물로 대체 불가능한 장면을 갖는가**<br><sub>기계는 인물이 등장하는 장면 수를 센다. 대체 가능한지는 읽어야 안다.</sub> | `demo_rc · ACTIVE ebc58a83 / manifest 8a349200` | demo_cast_identity_review<br>주연별 대표 데모 장면을 이름을 가리고 교차 독해<br>대사·행동·소품을 다른 주연으로 바꿀 수 있는지 기록 | 각 주연이 다른 인물로 대체하면 무너지는 대표 장면을 하나 이상 가짐 | `ORDER-64` |
| demo · 무설명 30분 외부 정상 독해 — 24주 완주·위시리스트 판정과는 별도 | **외부 정상 독해 10인 플레이 (현재 0/10)**<br><sub>정합 검사는 모순을 잡지 재미를 잡지 않는다. 처음 읽는 사람만 아는 것이 있다.</sub> | `demo_rc · ACTIVE ebc58a83 / manifest 8a349200` | demo_external_readthrough_10<br>같은 revision과 manifest의 10명<br>EN 3명 이상<br>서사 게임 경험자·비경험자 각 4명 이상<br>개인정보 없는 무설명 30분 세션 | P0 기술 오류 세션 0<br>구체적인 다음 3주 계획 2점이 10명 중 7명 이상<br>playtest_report가 READY_FOR_HUMAN_VERDICT이고 원문을 사람이 검토해 GO | `ORDER-28` |
| demo · 새 V2의 프롤로그 지원부터 면접·125년 계산·아버지 부재중 전화·첫 계획까지 | **첫 계획 전 125년 장면이 동기를 만드는가**<br><sub>자동 검사는 숫자·순서·저장을 증명한다. 목표의 벽을 이해했는지, 정답을 강요받았는지, 장면이 하나처럼 이어졌는지는 사람에게 물어야 한다.</sub> | `demo_rc · ACTIVE ebc58a83 / manifest 8a349200` | demo_opening_first_five_minutes<br>같은 새 demo_rc를 처음 설치한 상태에서 설명 없이 첫 계획판까지 진행<br>선택 직후 유도 문구 없이 아래 세 질문에 답함 | 30억원이 평범한 월급 계획으로는 닿기 어렵다는 벽을 계획 전에 이해함<br>투자나 창업이 유일한 정답으로 제시됐다고 느끼지 않음<br>지원·면접·계산·아버지 연락이 따로 뜨는 카드가 아니라 한 흐름처럼 이어짐 | `ORDER-87` |
| demo · 아버지에게 한 응답 하나만 다른 두 24주 경로와 기존 21주 건강 신호·24주 첫 청구서의 후속 문구 | **아버지 응답의 작은 차이가 다음 장면에서 느껴지는가**<br><sub>자동 검사는 여섯 기억이 기존 장면의 정확한 문구 하나만 읽고 추가 카드나 점수를 만들지 않는다고 증명한다. 앞선 응답이 되돌아온 차이를 플레이어가 자연스럽게 알아차리는지는 사람이 정상 속도로 읽어야 한다.</sub> | `demo_rc · ACTIVE ebc58a83 / manifest 8a349200` | demo_father_memory_two_paths<br>같은 demo_rc의 두 저장이 아버지 장면에서 고른 응답 하나만 다르고 나머지 선택·상태·진행 속도는 같음<br>디버그 설명이나 문구 차이 안내 없이 각 경로를 해당 기존 후속 장면까지 정상 속도로 독해<br>후속 장면 직후 무엇이 달랐고 왜 달랐다고 느꼈는지 플레이어의 말로 기록 | 플레이어가 앞선 아버지 응답과 이어지는 구체적인 후속 문구 차이를 유도 없이 알아차림<br>기억 회수를 위해 새로 뜬 사건 카드나 결과 카드가 0개이고 기존 장면 안의 작은 완결로 느껴짐<br>숨은 관계 점수·능력치 보상·칭찬이나 비난·정답 선택으로 읽히는 요소가 0개임 | `ORDER-88` |
| demo · 프롤로그 정체성 선택과 24주 동안 반복된 민준의 동기 | **동기 문장을 플레이어가 실제로 기억하는가**<br><sub>각인 검사는 문장이 노출됐는지만 안다. 기억은 사람에게 물어야 한다.</sub> | `demo_rc · ACTIVE ebc58a83 / manifest 8a349200` | demo_user_normal_reading<br>demo_rc 24주 정상 독해 직후 유도 없이 질문<br>민준의 다음 일이 궁금한지와 플레이어가 고른 수첩 문장을 함께 기록 | 플레이어가 자신이 고른 수첩 문장을 기억함<br>민준에게 다음에 무슨 일이 생길지 궁금하다는 사람 판정 | `ORDER-23` |
| demo-release · P-10의 ORDER-86 exact 22단위 원장(72사건/447본문·543동적 호출/536고유키·활동 147), ORDER-88 중간 snapshot(73/471·686/657), active demo_rc 실측(72/467·730/701) 사이의 set/hash delta 전수 재대조 | **24주 영어 목소리 임의 3단위 원어민 대조**<br><sub>구조·누출 검사는 문장이 존재하고 사실이 맞는지 확인한다. 이름을 가려도 화자와 관계 단계가 들리는지, 자연스러운 영어이면서 한국어의 거리와 함축을 보존하는지는 사람이 읽어야 판정할 수 있다.</sub> | `demo_rc · ACTIVE ebc58a83 / manifest 8a349200` | demo_en_voice_random_three<br>ORDER-86 exact 모집단·ORDER-88 중간 snapshot·active demo_rc 실측의 set/hash delta를 고정하고 모든 새·변경 사건·동적 표면·활동 대사를 active 22단위 원장에 전수 재대조한 증거<br>같은 demo_rc와 delta가 반영된 active 22단위 전수 원장에서 사용자가 임의의 서로 다른 3단위를 고름<br>영어 원어민 또는 준원어민이 화자 이름을 가리고 관계 단계와 목소리의 차이를 설명<br>한국어 정본과 함께 의미·함축·관계 거리·숫자·날짜를 직접 대조<br>세 단위 중 하나라도 번역투·평탄화·과장된 호칭이면 표본만 고치지 않고 22단위를 전량 재검토 | 이름을 가려도 화자와 상대 관계가 문장 길이·직접성·머뭇거림·축약형·호칭으로 구별됨<br>자연스러운 영어이면서 한국어의 의미·함축·사실·관계 거리를 바꾸지 않음<br>데모에서 oppa와 -ssi는 0이고 hyung은 관계가 작동하는 자리에서만 선택적으로 쓰임<br>사용자 최종 GO | `ORDER-86` |
| demo-release · P-9의 정본 2단위·자동 검사 1단위·24주 원고 16단위·한영 대조 1단위로 구성된 20단위 전수 원장 | **24주 산문 임의 3단위 정상 독해**<br><sub>자동 검사는 도달 범위·시각·구조·플레이스홀더를 잠글 수 있지만, 설명형 꼬리가 실제로 사라졌는지와 이미지·행동의 여운이 자연스러운지는 사람이 정상 속도로 읽어야 판정할 수 있다.</sub> | `demo_rc · ACTIVE ebc58a83 / manifest 8a349200` | demo_user_prose_random_three<br>같은 demo_rc와 ORDER-85 전수 원장에서 사용자가 임의의 서로 다른 3단위를 고름<br>한국어 장면은 정상 속도로 읽고, 대응 영어는 같은 사실·행동·마지막 이미지를 말하는지 함께 확인<br>세 단위 중 하나라도 번역투·설명형 꼬리·사실 훼손이면 표본만 고치지 않고 20단위를 전량 재검토 | 장면이 방금 보여 준 감정이나 선택 의미를 마지막 문장으로 다시 해설하지 않음<br>날짜·금액·화자 지식·선택 결과가 바뀌지 않고 한국어와 영어가 같은 장면으로 읽힘<br>사용자 최종 GO | `ORDER-85` |
| full · 1~5장 대표 정점·연결·Quiet/Echo/Decision·활동·엔딩의 연속 A/V | **장별 헤드폰·노트북·TV 연속 청취**<br><sub>자동 검사는 파일 존재와 계약만 본다. 반복이 지겨운지, 따로 찾아들을 만한지는 들어야 안다.</sub> | `full_rc · ACTIVE 6c91e11c / manifest 1cef15ff` | full_av_human_review<br>각 장 대표 경로를 헤드폰·노트북 스피커·거실 TV에서 청취<br>USER-P0N 최종 A/V 판정과 같은 full_rc 사용 | 대사 가독성·장소 식별·음악 피로·효과음 반복·Moral 사람층 변화가 모두 GO<br>같은 장소 재시작과 장면 밖 잔류가 사람 청취에서 거슬리지 않음 | `ORDER-43` |
| full · ORDER-104 핵심 장면 원고 23편의 정본 승격 | **ORDER-104 핵심 장면 원고 사용자 최종 서명**<br><sub>Claude의 위임 표본 판정은 작품성 판단을 제공하지만 정본을 최종 승인하는 사용자의 서명을 대신하지 않는다.</sub><br><strong>판정: Claude(사용자 위임) — 합격</strong><br><sub>판정: Claude(사용자 위임) — 합격. arc_y4_body_witness에서 다은이 문턱에 멈춰 허락을 묻는 행동을 근거로 삼음.</sub><br><sub>정본 서명: 사용자 최종 GO 대기</sub> | `full_rc · ACTIVE 6c91e11c / manifest 1cef15ff` | order104_seed9821_random_three<br>803a372d4314d58d9ee03038bca3897bc2e18630 원문 모집단 23편<br>seed 9821 추출 1/3: arc_y4_body_witness — 새벽 두 시의 다은 [신규] 합격<br>seed 9821 추출 2/3: arc_final_countdown_not_executed — 도장 없는 마지막 장 [신규] 합격<br>seed 9821 추출 3/3: arc_jaehyuk_04a_ghost — 연락 두절 [개작] 합격<br>인물 목소리·지금 잃는 것·다음을 기다리게 하는 여운 세 축 | 사용자가 Claude 위임 합격을 명시적으로 최종 GO하거나 뒤집어 재판정 범위를 정함 | `ORDER-104` |
| full · ORDER-105 M02~M12 원고 20편의 정본 승격 | **ORDER-105 M02~M12 원고 사용자 최종 서명**<br><sub>Claude의 위임 표본 판정은 작품성 판단을 제공하지만 정본을 최종 승인하는 사용자의 서명을 대신하지 않는다.</sub><br><strong>판정: Claude(사용자 위임) — 합격</strong><br><sub>판정: Claude(사용자 위임) — 합격. arc_goshiwon_goodbye의 좋았다고 부르기 어려운 시간과 조건대로만 남지 않는 기억을 근거로 삼음.</sub><br><sub>정본 서명: 사용자 최종 GO 대기</sub> | `full_rc · ACTIVE 6c91e11c / manifest 1cef15ff` | order105_seed9821_random_three<br>803a372d4314d58d9ee03038bca3897bc2e18630 원문 모집단 20편<br>seed 9821 추출 1/3: arc_temptation_fallout — 빌려준 계좌의 반환 요청 [개작] 합격<br>seed 9821 추출 2/3: arc_y1_sangchul_open_door — 주소와 소개인 [신규] 합격<br>seed 9821 추출 3/3: arc_goshiwon_goodbye — 고시원을 나오는 날 [개작] 합격<br>인물 목소리·지금 잃는 것·다음을 기다리게 하는 여운 세 축 | 사용자가 Claude 위임 합격을 명시적으로 최종 GO하거나 뒤집어 재판정 범위를 정함 | `ORDER-105` |
| full · ORDER-106 M13~M24 원고 24편의 정본 승격 | **ORDER-106 M13~M24 원고 사용자 최종 서명**<br><sub>Claude의 위임 표본 판정은 작품성 판단을 제공하지만 정본을 최종 승인하는 사용자의 서명을 대신하지 않는다.</sub><br><strong>판정: Claude(사용자 위임) — 합격</strong><br><sub>판정: Claude(사용자 위임) — 합격. arc_y2_hospital_door가 송금 이유와 못 가는 이유를 한 문장으로 합치지 않은 점을 근거로 삼음.</sub><br><sub>정본 서명: 사용자 최종 GO 대기</sub> | `full_rc · ACTIVE 6c91e11c / manifest 1cef15ff` | order106_seed9821_random_three<br>803a372d4314d58d9ee03038bca3897bc2e18630 원문 모집단 24편<br>seed 9821 추출 1/3: arc_y2_casino_chosen_door — 카지노 문 앞에서 [신규] 합격<br>seed 9821 추출 2/3: arc_y2_hospital_door — 창원 병실의 주말 [신규] 합격<br>seed 9821 추출 3/3: arc_34_routine_trap — 루틴의 덫 [개작] 합격<br>인물 목소리·지금 잃는 것·다음을 기다리게 하는 여운 세 축 | 사용자가 Claude 위임 합격을 명시적으로 최종 GO하거나 뒤집어 재판정 범위를 정함 | `ORDER-106` |
| full · ORDER-107 원고 20편과 지목 장면의 재작성 | **ORDER-107 M25~M36 원고 사용자 최종 서명**<br><sub>ORDER-117 구현 후보의 지목 장면은 Claude가 직접 재판정해 GO했지만, 사용자 위임 판정은 사용자의 최종 서명을 대신하지 않는다.</sub><br><strong>판정: Claude(사용자 위임) — 합격</strong><br><sub>판정: Claude(사용자 위임) — 합격. ORDER-117의 arc_y3_father_after_visit_document KO/EN 재작성본을 새 무작위 추출이 아닌 직접 1/1로 재판정했다. 아버지의 현재 통화 목소리, 계약의 마지막 두 장·오늘 답장·부자 사이 체면 중 지금 잃는 것, 다음 통화를 기다리게 하는 여운이 모두 GO다. 기존 seed 표본 이력은 보존하며 사용자 최종 GO는 OPEN이다.</sub><br><sub>정본 서명: 사용자 최종 GO 대기</sub> | `full_rc · ACTIVE 6c91e11c / manifest 1cef15ff` | order107_seed9821_random_three<br>803a372d4314d58d9ee03038bca3897bc2e18630 원문 모집단 20편<br>seed 9821 추출 1/3: arc_y3_father_after_visit_document — 두 문서의 같은 칸 [신규] 미달; ORDER-117 대상<br>seed 9821 추출 2/3: arc_y3_truth_heard_by_none — 전송하지 않은 문장 [신규] 합격<br>seed 9821 추출 3/3: arc_y3_cost_after_repaid — 두 장의 날짜 [신규] 합격<br>인물 목소리·지금 잃는 것·다음을 기다리게 하는 여운 세 축<br>ORDER-117 후보 e32c69b32acfbf6c5f1ced13cc88bf85ac5df563 / tree a6f0a4050862e717d7eb4b365b557bcc5a409e3f의 arc_y3_father_after_visit_document 재작성본을 기존 seed 표본으로 대체하지 않고 같은 세 축으로 직접 재판정 | 새 장면이 아버지의 현재 목소리·부자 사이 현재 손실·다음 여운을 모두 가짐<br>Claude(사용자 위임)가 재작성본을 직접 재판정해 GO<br>사용자가 ORDER-107에 최종 GO | `ORDER-107` |
| full · ORDER-108 M39~M48 원고 25편의 정본 승격 | **ORDER-108 M39~M48 원고 사용자 최종 서명**<br><sub>Claude의 위임 표본 판정은 작품성 판단을 제공하지만 정본을 최종 승인하는 사용자의 서명을 대신하지 않는다.</sub><br><strong>판정: Claude(사용자 위임) — 합격</strong><br><sub>판정: Claude(사용자 위임) — 합격. arc_y4_family_partner_collision에서 돈 뒤에는 사람에게 설명하지 않아도 된다고 믿을까 두렵다는 아버지의 말을 근거로 삼음.</sub><br><sub>정본 서명: 사용자 최종 GO 대기</sub> | `full_rc · ACTIVE 6c91e11c / manifest 1cef15ff` | order108_seed9821_random_three<br>803a372d4314d58d9ee03038bca3897bc2e18630 원문 모집단 25편<br>seed 9821 추출 1/3: arc_y4_year_close_daeun — 빈칸을 먼저 보여 주는 밤 [신규] 합격<br>seed 9821 추출 2/3: arc_y4_bill_night_unattached — 한 통화와 열린 화면들 [신규] 합격<br>seed 9821 추출 3/3: arc_y4_family_partner_collision — 같은 식탁의 미래 [개작] 합격<br>인물 목소리·지금 잃는 것·다음을 기다리게 하는 여운 세 축 | 사용자가 Claude 위임 합격을 명시적으로 최종 GO하거나 뒤집어 재판정 범위를 정함 | `ORDER-108` |
| full · ORDER-109 보정 16편과 지목 장면의 재작성 | **ORDER-109 반복·보고체·시계 도입 보정 사용자 최종 서명**<br><sub>ORDER-117 구현 후보의 지목 장면은 Claude가 직접 재판정해 GO했지만, 사용자 위임 판정은 사용자의 최종 서명을 대신하지 않는다.</sub><br><strong>판정: Claude(사용자 위임) — 합격</strong><br><sub>판정: Claude(사용자 위임) — 합격. ORDER-117의 arc_y2_money_structure KO/EN 재작성본을 새 무작위 추출이 아닌 직접 1/1로 재판정했다. 실제 수취인의 현재 목소리, 다음 주 생활비·잠·먼저 전화하지 못한 체면 중 지금 잃는 것, 다음 연락의 순서를 기다리게 하는 여운이 모두 GO이며 non-live 분기에 인물을 발명하지 않았다. 기존 seed 표본 이력은 보존하며 사용자 최종 GO는 OPEN이다.</sub><br><sub>정본 서명: 사용자 최종 GO 대기</sub> | `full_rc · ACTIVE 6c91e11c / manifest 1cef15ff` | order109_seed9821_random_three<br>803a372d4314d58d9ee03038bca3897bc2e18630 원문 모집단 16편<br>seed 9821 추출 1/3: arc_y3_cost_after_distanced — 관리실의 무표기 봉투 [개작] 합격; M34 수리 확인<br>seed 9821 추출 2/3: arc_y2_money_structure — 첫 상환액의 출처 [개작] 미달; ORDER-117 대상<br>seed 9821 추출 3/3: arc_y3_cost_after_forgiven — 식은 커피의 거리 [개작] 합격; M34 수리 확인<br>인물 목소리·지금 잃는 것·다음을 기다리게 하는 여운 세 축<br>ORDER-117 후보 e32c69b32acfbf6c5f1ced13cc88bf85ac5df563 / tree a6f0a4050862e717d7eb4b365b557bcc5a409e3f의 arc_y2_money_structure 재작성본을 기존 seed 표본으로 대체하지 않고 같은 세 축으로 직접 재판정 | 새 장면이 실제 상대의 목소리·현재 손실·다음 여운을 모두 가지며 non-live 분기에 임의 인물을 만들지 않음<br>Claude(사용자 위임)가 재작성본을 직접 재판정해 GO<br>사용자가 ORDER-109에 최종 GO | `ORDER-109` |
| full · ORDER-110 마지막 해 기준 세로줄 20편의 정본 승격 | **ORDER-110 마지막 해 기준 세로줄 사용자 최종 서명**<br><sub>Claude의 위임 표본 판정은 작품성 판단을 제공하지만 정본을 최종 승인하는 사용자의 서명을 대신하지 않는다.</sub><br><strong>판정: Claude(사용자 위임) — 합격</strong><br><sub>판정: Claude(사용자 위임) — 합격. arc_y5_jaehyuk_return_call_reference의 친구라는 말이 답이면서 부탁의 재료가 되는 양면성을 근거로 삼음.</sub><br><sub>정본 서명: 사용자 최종 GO 대기</sub> | `full_rc · ACTIVE 6c91e11c / manifest 1cef15ff` | order110_seed9821_random_three<br>803a372d4314d58d9ee03038bca3897bc2e18630 원문 모집단 20편<br>seed 9821 추출 1/3: arc_y5_sangchul_review_receipt — 빨간 원의 사본 [신규] 합격<br>seed 9821 추출 2/3: arc_y5_final_offer_reference_delivery — 같은 일곱 장 [신규] 합격<br>seed 9821 추출 3/3: arc_y5_jaehyuk_return_call_reference — 돌아온 이유를 듣는 통화 [신규] 합격; 정점급<br>인물 목소리·지금 잃는 것·다음을 기다리게 하는 여운 세 축 | 사용자가 Claude 위임 합격을 명시적으로 최종 GO하거나 뒤집어 재판정 범위를 정함 | `ORDER-110` |
| full · ORDER-111 신규 마지막 해 대체 세로줄 24편의 정본 승격 | **ORDER-111 마지막 해 대체 세로줄 사용자 최종 서명**<br><sub>Claude의 위임 표본 판정은 작품성 판단을 제공하지만 정본을 최종 승인하는 사용자의 서명을 대신하지 않는다.</sub><br><strong>판정: Claude(사용자 위임) — 합격</strong><br><sub>판정: Claude(사용자 위임) — 합격. arc_y5_final_week_jiyeon_outbound가 앞 장면의 지연 요구를 이월해 세 선택이 각각 다른 것을 포기하게 한 점을 근거로 삼음.</sub><br><sub>정본 서명: 사용자 최종 GO 대기</sub> | `full_rc · ACTIVE 6c91e11c / manifest 1cef15ff` | order111_seed9821_random_three<br>803a372d4314d58d9ee03038bca3897bc2e18630 원문 모집단 24편<br>seed 9821 추출 1/3: arc_y5_final_week_jiyeon_outbound — 지연에게 먼저 보낸 말 [신규] 합격<br>seed 9821 추출 2/3: arc_final_countdown_other_filing_executed — 두 이름이 남은 마지막 장 [신규] 합격<br>seed 9821 추출 3/3: arc_y5_name_copy_delivered_jiyeon — 지연 손에 간 접수 사본 [신규] 합격<br>인물 목소리·지금 잃는 것·다음을 기다리게 하는 여운 세 축 | 사용자가 Claude 위임 합격을 명시적으로 최종 GO하거나 뒤집어 재판정 범위를 정함 | `ORDER-111` |
| full, year5-r1b · ORDER-112 career 16편 중 보존 1편과 재판정 15편 | **ORDER-112 career 세로줄 사용자 최종 서명**<br><sub>ORDER-117 구현 후보의 보존 1편 제외 career 15편은 Claude가 전수 재판정해 모두 GO했지만, 사용자 위임 판정은 사용자의 최종 서명이나 R1b replacement contract를 대신하지 않는다.</sub><br><strong>판정: Claude(사용자 위임) — 합격</strong><br><sub>판정: Claude(사용자 위임) — 합격. 보존한 arc_y5_after_goal_hyunsu_career를 제외하고 ORDER-117 명시 15편 arc_y5_contract_cover_career, arc_y5_contract_reviewer_delivery_minseo_career, arc_y5_protection_boundary_hyunsu_career, arc_y5_minseo_goal_cost_career, arc_y5_final_offer_career_boss, arc_y5_career_reviewer_receipt_minseo, arc_y5_three_in_room_career, arc_y5_three_in_room_decision_career, arc_y5_name_on_line_career_self, arc_y5_name_copy_delivered_hyunsu_career, arc_y5_people_verdict_career_hyunsu, arc_y5_contract_execution_career, arc_y5_contract_result_delivered_hyunsu_career, arc_final_countdown_career_executed, arc_y5_final_week_hyunsu_career_outbound의 KO/EN을 무작위 표본으로 대체하지 않고 15/15 전수 판정했다. 각 편의 인물 목소리·지금 잃는 것·다음 여운 세 축과 KO/EN 동인이 모두 GO다. 사용자 최종 GO는 OPEN이고 R1b는 HOLD다.</sub><br><sub>정본 서명: 사용자 최종 GO 대기</sub> | `full_rc · ACTIVE 6c91e11c / manifest 1cef15ff` | order112_seed9821_random_three<br>803a372d4314d58d9ee03038bca3897bc2e18630 원문 모집단 16편<br>seed 9821 추출 1/3: arc_y5_after_goal_hyunsu_career — 이름보다 먼저 물을 것 [신규] 합격; 보존 대상<br>seed 9821 추출 2/3: arc_y5_contract_result_delivered_hyunsu_career — 실행본을 건넨 시각 [신규] 미달; 코드 토큰 4<br>seed 9821 추출 3/3: arc_y5_name_copy_delivered_hyunsu_career — 회전문 앞의 두 번째 사본 [신규] 미달; 코드 토큰 6<br>인물 목소리·지금 잃는 것·다음을 기다리게 하는 여운 세 축<br>ORDER-117 후보 e32c69b32acfbf6c5f1ced13cc88bf85ac5df563 / tree a6f0a4050862e717d7eb4b365b557bcc5a409e3f의 career 모집단 16편<br>arc_y5_after_goal_hyunsu_career는 KO 0f813ff0292bb46f1e03cac8fbf66e79d807f88d7238a0c671a04782e32bc923 / EN 875b9e909f882712bf380b265c593327208599834bf339fc7d3acbe97fed2982 byte-exact 보존<br>arc_y5_people_verdict_career_hyunsu를 포함한 나머지 15편 전수 낭독; 무작위 3편으로 대체하지 않음 | arc_y5_after_goal_hyunsu_career KO/EN object가 위 SHA로 exact 보존됨<br>Claude(사용자 위임)가 나머지 15편 각각을 세 축 모두 GO로 판정<br>사용자가 ORDER-112에 최종 GO<br>이 GO만으로 R1b를 열지 않고 별도 replacement contract 전까지 HOLD | `ORDER-112` |
| full, year5-r1b · ORDER-118 startup 16편 재설계와 마지막 해 코드 토큰 제거 후보 | **ORDER-118 startup 재설계 사용자 최종 서명**<br><sub>사람·시간 중심의 새 16편은 L1/L2와 fresh 위임 표본 판정을 통과했지만, 사용자 위임 판정은 사용자의 최종 GO나 R1b replacement contract를 대신하지 않는다.</sub><br><strong>판정: Claude(사용자 위임) — 합격</strong><br><sub>판정: Claude(사용자 위임) — 합격. active spec의 정확한 1..16 root 순서에 Python 3 random.Random(9821).sample(roots, 3)을 적용한 fresh 표본은 #11 arc_y5_startup_c2_copy_delivered_cofounder, #2 arc_y5_startup_c0_reviewer_delivery_minseo, #3 arc_y5_startup_boundary_cofounder다. KO/EN 직접 낭독에서 공동창업자·민서·팀의 고유 목소리, 팀의 기다린 한 시간·민서와의 저녁·빠른 통화와 설명권의 현재 손실, 다음 질문과 다음 자리의 여운이 세 편 모두 GO다. 하나라도 미달이면 전량 반려하는 규칙을 적용했고 미달 0이었다. 2026-08-21의 #10/#13/#15 반려는 이전 후보의 historical cohort로 별도 보존하며, 사용자 최종 GO는 OPEN이고 R1b는 HOLD다.</sub><br><sub>정본 서명: 사용자 최종 GO 대기</sub> | `full_rc · ACTIVE 6c91e11c / manifest 1cef15ff` | order118_seed9821_random_three<br>후보 f425b812d72664c2baeeb746aa6ce0b5f6299c0f / tree 4c0a659e972140660ae6d75968fcffef0c081cee의 새 startup 모집단 16편<br>seed 9821 무작위 3편; 판정자가 실제 추출 알고리즘과 root 3개를 판정 기록에 명시<br>인물 목소리·지금 잃는 것·다음을 기다리게 하는 여운 세 축 | career와 다른 끝맺음·기록 방식 아닌 선택·사람의 현재 비용에 위임 낭독 GO<br>플레이어 노출 코드 토큰 0과 R1b 비활성 경계 유지<br>새 16편 무작위 3편의 Claude(사용자 위임) 판정 뒤 사용자 최종 GO | `ORDER-118` |
| order119-close, demo, full · active demo_rc에서 ORDER-119가 교체한 KO/EN 결과·영수증·임계 변화·wrapper·칭호 표면과 같은 후보의 KO PlayStation full-gamepad 결과 산문 | **ORDER-119 결과 산문·시스템 언어 제거 사용자 최종 판정**<br><sub>자동 검사는 금지 토큰·수치 폴백·한영 구조·도달성과 네 렌더 경로의 계약을 증명하지만, 실제 화면의 결과가 스탯 정산표가 아니라 세계 안의 변화로 읽히는지는 사람이 판정해야 한다.</sub> | `demo_rc · ACTIVE ebc58a83 / manifest 8a349200` | order119_real_render_surface_review<br>active demo_rc BUILD 2026.08.22.1의 exact commit/tree/manifest를 사용<br>서로 다른 HOME/XDG/OUT에서 직렬 캡처한 1280×800 KO/EN demo-experience 실렌더<br>같은 후보의 KO PlayStation full-gamepad 실렌더<br>같은 후보의 1280×800 KO/EN 칭호 도감 실렌더 | 결과와 영수증이 정확한 스탯 증감·호감도·등급·배수·해금표가 아니라 1~3문장의 관찰 가능한 세계 변화로 읽힘<br>안 고른 선택은 하지 않은 행동만 남기고 정확한 보상·숨은 수치·판정 기준을 다시 설명하지 않음<br>임계 변화·wrapper·칭호 이름과 설명이 내부 run theme나 숨은 계산을 해설하지 않고 사람·시장·읽는 방식의 변화로 자연스럽게 읽힘<br>위 KO/EN·gamepad 실렌더 전체를 본 사용자가 ORDER-119에 최종 GO | `ORDER-119` |
| order124-close, story-only-product-migration · 월간 행동판 없이 실제 StoryMode 선택과 자동 네 주·월세·생활 압박만으로 M01~M06을 완주하는 독립 체험판 | **M01~M06 story-first 공개 데모 사용자 판정**<br><sub>BUILD 2026.08.25.1 자동 증거는 다섯 언어, 실제 두 M01 경로, 자동 24주·정산 6회, 수동 저장 뒤 exact cold resume, 검은 전환막과 입력 차단 해제, AP 표면 0을 증명한다. 월간 행동판 없이도 선택과 대가가 게임으로 읽히는 재미는 증명하지 못하므로 사용자가 직접 판정해야 한다.</sub> | `story_demo_rc · ACTIVE 16675f6c / manifest 90ca3643` | story_demo_m1_m6_story_choice_only<br>active story_demo_rc BUILD 2026.08.25.1 exact 16675f6ce310adb477da9ab3431c2edfe15ab278 / tree aed6904fc95345a867d2762f0bb8a62e65b32ce1의 앱 `GangnamDream-StoryDemo`에서 새로 시작. 반려 ORDER-103, BUILD .2, 이전 order124_rc와 기존 demo_rc는 사용하지 않음<br>마우스·키보드·실제 패드 중 하나로 M01~M06의 실제 StoryMode 문장과 선택을 정상 속도로 완주<br>장면 사이 시간감, M01→M02 대가, M06에서 포기한 일을 유도 문구 없이 말하고, 저장 뒤 앱을 완전히 닫아 이어하기 위치가 기대와 같은지 확인 | 월간 행동판이 없어도 실제 장면 안에서 선택하고 있다는 감각이 있음<br>M01 선택의 M02 생활 대가와 M06에서 하나만 끝내는 포기가 자연스럽게 읽힘<br>장면 사이 자동 시간·경제가 너무 빠르거나 별도 관리 화면처럼 느껴지지 않음<br>사용자가 story_demo_rc에 최종 GO한 뒤에만 별도 제품 이관 오더에서 본편 플레이 표면의 반복 월간·주간 행동 진입 제거를 시작하며, 저장 호환 AP 데이터·엔진 코드 삭제는 별도 승인 없이는 하지 않음 | `ORDER-124` |
| order97-close, claim:ja-demo · Batch A의 StartMenu 16호출과 StoryMode 7호출, 총 23개 lookup-before-format 이동 표면 | **ORDER-97 Batch A 실제 UI 임의 3표면 대조**<br><sub>템플릿·인자·키 수 자동 검사는 lookup provenance를 증명하지만 시작·기록·설정·장면 화면의 최종 문맥과 값이 사람에게 맞게 읽히는지는 실제 후보 표면을 봐야 한다. 최신 demo_rc는 발급됐고 사람 판정만 남는다.</sub> | `demo_rc · ACTIVE ebc58a83 / manifest 8a349200` | order97_batch_a_ui_format_random_three<br>현재 소스로 다시 발급한 같은 demo_rc와 ORDER-97 exact registry에서 사용자가 서로 다른 실제 표면 3개를 임의 선택<br>각 표면의 KO와 EN 최종 문자열이 migration 전 authored byte와 같은지 대조<br>일본어 사전 hit가 안정 템플릿과 대상 인자를 쓰며 영어 fallback이나 교차 언어 금액을 남기지 않는지 실제 화면에서 확인<br>같은 최종 demo_rc의 JA StartMenu·gallery·Story·i18n-layout에서 가나·한자·일본어 문장부호가 한 Noto Sans JP 굵기로 읽히고 줄바꿈·잘림이 없는지 확인<br>세 표면 중 하나라도 틀리면 표본만 고치지 않고 Batch A 23호출을 전량 재검토 | 세 실제 표면 모두 올바른 일본어 문맥·값·placeholder·줄바꿈으로 읽힘<br>JA 가나·한자·일본어 문장부호의 획 굵기와 정렬이 한 서체 역할로 보이고 잘림이 없음<br>KO/EN authored bytes와 숫자·날짜·금액 의미가 보존됨<br>사용자가 Batch A에 최종 GO | `ORDER-97` |
| order97-close, claim:ja-demo · Batch B의 GameState 4·MainGame 1·CommunicationPhone 3·ArubaGame 1·SeoulCycleBoard 2·CoreLoopPlanner 13, 총 24개 lookup-before-format 이동 표면 | **ORDER-97 Batch B 실제 UI 임의 3표면 대조**<br><sub>정적 원장은 남은 호출과 돈 formatter의 소유권을 증명하지만 계획판·연락폰·배달·재고조사 표면의 최종 문맥, 복수형, 고정 일정과 돈 단위는 같은 후보의 실제 화면에서 사람이 확인해야 한다. 최신 demo_rc는 발급됐고 사람 판정만 남는다.</sub> | `demo_rc · ACTIVE ebc58a83 / manifest 8a349200` | order97_batch_b_ui_format_random_three<br>현재 소스로 다시 발급한 같은 demo_rc와 ORDER-97 exact registry에서 사용자가 서로 다른 실제 표면 3개를 임의 선택<br>각 표면의 KO와 EN 최종 문자열이 migration 전 authored byte와 같은지 대조<br>일본어 사전 hit와 영어 fallback의 인자 provenance, placeholder 결과, 고정 일정·복수형·원화 의미를 실제 화면에서 확인<br>같은 최종 demo_rc의 JA core-loop 계획판·서울 보드·연락폰·i18n-layout에서 가나·한자·일본어 문장부호가 한 Noto Sans JP 굵기로 읽히고 줄바꿈·잘림이 없는지 확인<br>세 표면 중 하나라도 틀리면 표본만 고치지 않고 Batch B 24호출을 전량 재검토 | 세 실제 표면 모두 올바른 일본어 문맥·값·placeholder·줄바꿈으로 읽힘<br>JA 가나·한자·일본어 문장부호의 획 굵기와 정렬이 한 서체 역할로 보이고 잘림이 없음<br>KO/EN authored bytes와 정확 원화의 숫자·부호·쉼표·단위 의미가 보존됨<br>사용자가 Batch B에 최종 GO | `ORDER-97` |
| order98-close, claim:controller · Batch A 15단위의 title/archive/save/completion/MainGame/Story 페이지·탭·화면 도구와 세 브랜드 글리프 | **ORDER-98 Batch A 의미 입력 임의 3표면 실기기 대조**<br><sub>자동 입력은 action·edge·상태 불변을 증명하지만, 처음 잡은 사람이 포커스 레일을 훑지 않고 L1/R1과 L2/R2의 역할을 바로 읽는지는 실제 손으로 판정해야 한다.</sub> | `demo_rc · ACTIVE ebc58a83 / manifest 8a349200` | order98_semantic_controller_batch_a_random_three<br>같은 active demo_rc와 ORDER-98 Batch A 15단위 원장에서 사용자가 서로 다른 실제 표면 3개를 임의 선택<br>실제 Steam Deck·DualSense·Switch Pro 중 해당 표면의 표시 글리프와 일치하는 패드로 정상 속도 수행<br>D-pad·ABXY·L1/R1·L2/R2 안내만 보고 코드·마우스·키보드 없이 핵심 행동을 첫 시도에 완료<br>한 표면이라도 잘못된 trigger 방향·숨은 확정·포커스 소실·12회 초과 왕복이면 표본만 고치지 않고 Batch A 15단위를 전량 재검토 | 세 표면 모두 L1/R1은 sibling group, L2/R2는 이전/다음 페이지 또는 감소/증가로 즉시 읽힘<br>확정·저장·불러오기·진행·종료가 trigger로 실행되거나 모달 뒤로 누수되는 경우 0<br>현재 장치 글리프·화면 동사·실제 입력이 일치하고 사용자 최종 GO | `ORDER-98` |
| order98-close, claim:controller · Batch B의 8 직접 게임, 큰 단위 값 조절, 중앙 진동 profile과 title/MainGame/Story 진동 설정 | **ORDER-98 Batch B 직접 게임·진동 임의 3표면 실기기 대조**<br><sub>자동화는 stake와 profile 호출을 셀 수 있지만, trigger 방향이 손에 자연스럽고 의미 진동은 구별되면서 30분 동안 피로하지 않은지는 실제 패드로만 판정할 수 있다.</sub> | `demo_rc · ACTIVE ebc58a83 / manifest 8a349200` | order98_semantic_controller_batch_b_random_three<br>같은 active demo_rc와 ORDER-98 Batch B 원장에서 사용자가 서로 다른 직접 게임 3개를 임의 선택<br>각 게임에서 L2 감소·R2 증가, 그룹 이동, 베팅·라운드·결과·재시작 또는 안전 종료를 실제 패드로 수행<br>같은 30분 구간에서 일반 포커스·탭·페이지·값 미리보기의 무진동과 의미 commit·위험·결과·물리 비트의 구분성을 확인<br>title/MainGame/Story에서 진동 OFF와 0%를 각각 켠 뒤 진행 중 cue 즉시 정지와 이후 무진동을 확인<br>한 게임이라도 오입력·잘못된 trigger 방향·disabled 상태 변화·일상 진동 피로·OFF 누출이 있으면 Batch B 15단위를 전량 재검토 | 세 게임 모두 L2 감소·R2 증가와 L1/R1 그룹 역할을 첫 시도에 구분함<br>일반 탐색은 조용하고 의미 profile은 화면·소리와 함께 서로 구별되며 30분 동안 거슬리지 않음<br>진동 OFF·0%에서 실제 출력 0이고 모든 정보·선택·결과가 그대로이며 사용자 최종 GO | `ORDER-98` |
| order99-close, demo · BUILD 2026.08.11.3에서 사용자 원본 autosave의 격리 복사본으로 1월 4주차 완료 상태부터 월말 수첩과 2월 1주차 보드까지 복구하는 경로 | **ORDER-99 BUILD 2026.08.11.3 실제 저장 복구 사용자 확인**<br><sub>자동 회귀는 격리 복사본의 저장 정합과 Month 2 진입을 증명하지만, 실제 사용자의 원래 막힌 저장이 정상 입력만으로 이어지는지는 사용자가 같은 후보에서 확인해야 한다.</sub> | `order99_build_3_rc · ACTIVE 22f1f2ac / manifest 96e76edd` | order99_build_3_user_save_recovery<br>고정 order99_build_3_rc BUILD 2026.08.11.3과 사용자 primary/bak의 격리 복사본을 원래 playtest 저장 이름으로 사용<br>새 게임이나 수동 JSON 편집 없이 W4 close → Month 1 notebook → confirm → turn 5 Month 2 board → autosave → reload를 정상 입력으로 진행<br>검사 전후 사용자 원본 primary SHA-256 84d49b2e28874c62c82ba0acf28d0fcba7f1ef284db5023b1e1a577cd0e46995와 mtime을 대조 | 사용자가 막힌 저장에서 월말 수첩을 거쳐 Month 2 보드에 도달하고 다시 불러와 계속할 수 있음<br>돈 675,000원·몸 56·마음 52, W1~W4 네 배치, 유혹 선택과 W4 followup이 보존되고 효과·영수증 중복이 0<br>원본 primary/bak은 불변이며 사용자가 ORDER-99에 최종 GO | `ORDER-99` |
| reference-system-implementation · REFERENCE_SYSTEM_VERDICTS.md의 44단위 전수 판정표와 그중 가져온다로 판정된 32단위 | **참조 시스템 판정표 채택 항목 임의 3단위 대조**<br><sub>자동 검사는 44단위 판정표의 구조와 기존 시스템 소유자를 확인할 수 있지만, 채택 항목이 강남드림 안에서 구체적으로 그려지고 서로를 지우지 않는지는 사람이 함께 읽어야 판정할 수 있다. active demo_rc는 발급됐지만 사람 판정 증거는 아직 없다.</sub> | `demo_rc · ACTIVE ebc58a83 / manifest 8a349200` | reference_system_verdicts_random_three<br>같은 demo_rc와 ORDER-95 전수 판정표에서 사용자가 가져온다 32단위 중 서로 다른 3단위를 임의 선택<br>각 단위가 강남드림에서 무엇이 되는지와 세 단위를 함께 적용해도 서로를 지우지 않는지 설명<br>세 단위 중 하나라도 구체적으로 그려지지 않거나 서로를 지우면 표본만 고치지 않고 44단위를 전량 재검토 | 세 채택 단위 모두 기존 강남드림 요소에 붙은 구체적인 변화로 읽히고 함께 놓아도 각자의 역할이 남음<br>사용자가 같은 demo_rc의 판정표 품질에 최종 GO<br>이 GO는 구현 승인이 아니며 실제 구현에는 별도 후속 오더와 사용자 승인이 필요함 | `ORDER-95` |

## 당신의 결정을 기다리는 것

에이전트가 작업 중 부딪혀 올린 제안이다. 규칙·상한은
[`PROPOSALS.md`](PROPOSALS.md)가 소유하며, 21일이 지나면 감사가 실패한다.

| | 제안 | 안 하면 계속 내는 것 | 권고 | 열림 |
|---|---|---|---|---|
| `P-18` | 프롤로그에 리듬이 없다 — 기술은 다 있는데 모든 비트가 같은 속도다 | 하면: (1)은 프롤로그 데이터 구조가 한 칸 늘고 KO/EN 두 해상도 | ****(1)만 먼저 한다.** 새 자산이 0이고 되돌리기 쉬우며, 실물을 보고** | 2026-08-11 |
| `P-17` | 열어 둘 것과 안 정해진 것을 가른다 — 본편이 딛고 선 사실 셋 | 하면: 세 사실을 확정해야 하고 ①②는 사용자 결정이 필요하다. | ****한다. 다만 답을 채우는 일이 아니라 경계를 긋는 일로 한다.**** | 2026-08-10 |

## 한눈에

| 지표 | 값 | 뜻 |
|---|---:|---|
| 사건 | 1,800 | KR 이벤트 전체 |
| 선택 2+ 사건 | 1,659 | 판정 대상 |
| 체인(장면) | 71 | 2링크 이상 |
| 연출 보유 사건 | 172 | 전체의 9% |
| 정답 선택 | 417 | 선택 2+ 사건의 25% |
| 테마 우회 | 2,116 | UIStyle 밖 override |
| 수동 스타일 | 260 | StyleBoxFlat 직접 생성 |
| 테마 리소스 | 0 | 늘어야 하는 지표 |
| 팔레트 밖 색 | 681 | 정본 12색 대비 |
| 진입점 없는 스크립트 | 2 | 래칫 |
| 서명 알려진 결함 | 5 | 악화만 실패 |
| 1링크·무연출 사건 | 77 | 독립 노출 재검토 |

## 오더

정본은 [`CODEX_QUEUE.md`](CODEX_QUEUE.md)의 활성 인덱스이고 여기는 그 사본이다.

| ID | 제목 | 상태 | 현재 게이트 |
|---|---|---|---|
| `ORDER-140` | 거절 불가 비트가 런을 끝내지 못하게 막는다 | 미착수 | W188 별세 마지막 비트가 선택지 1개에 mental -40 · mental≤40이면 종료 재현 · 클래스 2건 · 미착수 |
| `ORDER-139` | 진입 자산보다 몇 배 큰 고정 차감을 막는다 | 미착수 | W3 잔고 50만 → 체납 350만 재현 · 버그 클래스 2건 · 외부 세션 선결 · 미착수 |
| `ORDER-138` | 투자 기준 밖 5장의 연속 공백과 아버지 기일 회수를 고친다 | 미착수 | general 28/48 최장 9주, 직장형 27/48 최장 6주 · 화면 픽스처 2건 선행 수리 · 미착수 |
| `ORDER-137` | 5장 실플레이 반려 4건을 표적 수리한다 | 진행 | 새 제품 002a493 / tree ce156f4 / manifest 7ada31a8 · 위임 L3에서 property CONDITIONAL(반려 2건 닫힘)·general REJECT · 잔여는 ORDER-138 · 두 L3와 사용자 최종 GO OPEN · main HOLD |
| `ORDER-135` | 25억 문턱·아버지 별세 일반 런의 선택을 W240에 잇는다 | 진행 | 002a493에서 W237·W240·회수는 통과 · 위임 L3는 W225~W233 9주 공백과 W224 각주형 회수로 다시 REJECT · 수리는 ORDER-138 · 사용자 최종 GO/main HOLD |
| `ORDER-119` | 게임 전체 플레이어 표면에서 스탯·시스템 언어 제거 | 진행 | 제품·QA 36파일+package 2 · exact clean full audit·KO/EN 24주·KO 240주·BUILD 2026.08.22.1 3플랫폼 · active demo_rc · 사용자 최종 GO OPEN |
| `ORDER-118` | startup 전면 재설계·코드 토큰 제거 | 진행 | L1/L2 GO · 16편/27선택·코드 토큰 0 · seed 9821 위임 L3 GO · 사용자 최종 GO OPEN · R1b HOLD |
| `ORDER-117` | 107/109 국소 수리·career 15편 재판정 | 진행 | L1/L2 GO · 18단위 전수·16 roots 재작성·코드 토큰 0 · 위임 L3 GO · 사용자 최종 GO OPEN · R1b HOLD |
| `ORDER-124` | 월간 행동판 없이 스토리 선택만으로 M01~M06을 잇는다 | 진행 | BUILD 2026.08.25.1 macOS story_demo_rc active (16675f6) · 5 locale·24주·정산 6·영수증 9 L1/L2 GO · 사용자 L3 OPEN · 엔진 AP 삭제 비승인 |
| `ORDER-99` | SAVE-P0 첫 달 4주차 진행 불능을 복구한다 | 진행 | BUILD .3 L1/L2 — 사용자 저장 확인 대기 |
| `ORDER-97` | LOC-0.5 전에 UI 템플릿을 번역 | 진행 | L1/L2 — 최신 후보·A/B 각 3표면 L3 대기 |
| `ORDER-98` | PAD-1 포커스 레일을 의미 버튼으로 줄인다 | 진행 | active demo_rc exact full/surface·입력·컨트롤러·오디오 L1/L2 PASS · 물리 패드 A/B 각 3표면 L3 OPEN |

## 다섯 장 — 무엇을 열고 무엇을 닫는가

장마다 동사를 하나 열고 이전 동사를 하나 닫는다.
닫히는 쪽이 이 작품이 인접작과 갈라지는 지점이다.

### 1장 · 남은 사람 <sub>1–48주</sub>

> 정직하게 살아서는 닿을 수 없는 목표 앞에서 민준은 첫 선을 넘는가?

- **연다** — 시간을 판다 — 알바·지원·공부의 기본 동사 세트
- **닫는다** — (1장은 열기만 한다)
- **압력** — 이번 달 생존
- **실패** — 이번 달을 넘기지 못한다

### 2장 · 문을 여는 값 <sub>49–96주</sub>

> 기회가 사람의 얼굴로 올 때 민준은 호의와 거래를 구분할 수 있는가?

- **연다** — 사람이 기회를 가져온다 — 혼자서는 찾을 수 없는 기회가 소개로만 온다
- **닫는다** — 혼자 버는 것으로는 따라가지 못한다. 시간당 노동의 천장이 보인다
- **압력** — 관계 유지비 — 사람을 통해 오는 기회는 사람에게 쓸 시간을 요구한다
- **실패** — 유지비를 내지 못해 문이 열리지 않는다

### 3장 · 같은 손 <sub>97–144주</sub>

> 상처의 진실을 알게 된 민준은 가해자를 심판하는가, 이용하는가, 닮아 가는가?

- **연다** — 남의 돈을 움직인다 — 레버리지·보증·타인 자본
- **닫는다** — 시간 팔기가 무의미해진다. 알바 한 주가 기회비용 이하가 되어 1장의 생존 동사가 죽는다
- **압력** — 그 수단이 아버지를 무너뜨린 것과 같다는 걸 알고도 쓰는가
- **실패** — 남의 돈에 깔린다

### 4장 · 청구서 <sub>145–192주</sub>

> 사람과 몸이 성공의 비용으로 청구될 때 민준은 무엇을 먼저 지불하는가?

- **연다** — 규모를 고른다 — 되돌리기 어려운 크기의 판
- **닫는다** — 몸과 관계가 자원에서 제약으로 바뀐다. 소모하고 회복하던 것의 상한이 내려가고, 기다려 주던 사람이 더는 기다리지 않는다
- **압력** — 대신 내 줄 사람이 없다
- **실패** — 청구서를 몸이나 사람으로 낸다

### 5장 · 이름을 적는 사람 <sub>193–240주</sub>

> 마지막 숫자 앞에서 민준은 누구의 이름과 시간을 담보로 서명하는가?

- **연다** — 문서 상태를 고정하고 책임을 서명한 뒤 먼저 연락한다
- **닫는다** — 대부분의 문이 이미 닫혀 있다. 새 기회가 오지 않고 남은 것으로만 한다
- **압력** — 지킬 것을 지킬 수 있는가
- **실패** — 다 얻고 아무도 남지 않는다

## 주연 여섯 — 서명

팬이 인물을 알아보는 근거는 렌더 품질이 아니라 같은 소품이 매번 그 자리에
있다는 사실이다. `언급`은 자산 정본이 그 소품을 실제로 말한 횟수이며,
**0이면 소품이 선언만 되고 지켜지지 않는다는 뜻이다.**

| 인물 | 욕망과 모순 | 소유 소품 | 오디오 모티프 | 언급 |
|---|---|---|---|---:|
| **Kim Daeun**<br>`daeun` | Has little to spare but notices what other people need | Handwritten post-it and the same hair clip in every outfit | Close felt piano and soft room tone, never cute chimes | 2 |
| **Father**<br>`father` | Shame makes him withdraw from the son he is trying to protect | 23-second call screen and debt records | Bare room tone with the four-note theme missing its last note | 0 |
| **Choi Jaehyuk**<br>`jaehyuk` | His kindness may be sincere and useful at the same time | Pocha photograph with a darkened second reading | Dry finger snap or shutter transient over Minjun's motif | 0 |
| **Han Jiyeon**<br>`jiyeon` | Offers the fastest path upward while refusing to be merely a guide | Unbranded black luxury-car key and angular earring | Cool piano interval with a held unresolved note | 7 |
| **Kim Minjun**<br>`minjun` | Wants a different life without knowing what may remain of him | Folded account statement showing the starting balance, never a luxury prop at launch | Four-note theme that can clear, distort, or hollow out | 0 |
| **Im Sangchul**<br>`sangchul` | The hand offering a ladder may be the hand that built the trap | Business card with handwritten number | Low brushed rhythm and one muted brass breath | 2 |

## 현재 구현 W1~24 audited prefix — 번들 60개

`행동`은 결과 카드이고 `장면`만 집필된 체인을 갖는다. `미집필`은 아직 없다.

| 번들 | 형태 | 종류 | 주차 | 인물 |
|---|---|---|---|---|
| `cafe_world_glimpse` | 장면 | temptation | 6–7 |  |
| `daeun_player_return` | 장면 | pursuit | 15–16 | daeun |
| `daeun_return_after_distance` | 장면 | pursuit | 15–16 | daeun |
| `daeun_shared_dream` | 장면 | pursuit | 20–20 | daeun |
| `daeun_third_greeting` | 장면 | pursuit | 19–20 | daeun |
| `daeun_world_meet` | 장면 | encounter | 10–12 | daeun |
| `demo_collision` | 장면 | boss | 24–24 | father |
| `father_first_call` | 장면 | care | 1–3 | father |
| `father_health_signal` | 장면 | care | 21–21 | father |
| `father_quiet_call` | 장면 | care | 9–12 | father |
| `first_temptation_boss` | 장면 | boss | 4–4 |  |
| `hyunsu_exam_eve` | 장면 | care | 23–23 | hyunsu |
| `hyunsu_first_meet` | 장면 | encounter | 1–3 | hyunsu |
| `hyunsu_player_reachout` | 장면 | pursuit | 5–6 | hyunsu |
| `hyunsu_study_followup` | 장면 | pursuit | 9–12 | hyunsu |
| `jaehyuk_plain_reunion_echo` | 장면 | pursuit | 19–20 | jaehyuk |
| `jaehyuk_world_meet` | 장면 | encounter | 13–16 | jaehyuk |
| `jiyeon_bus_stop_reunion` | 장면 | encounter | 15–16 | jiyeon |
| `jiyeon_second_crossing` | 장면 | pursuit | 19–20 | jiyeon |
| `jiyeon_world_meet` | 장면 | encounter | 10–12 | jiyeon |
| `m1_convenience_trial_shift` | 행동 | livelihood | 1–3 |  |
| `m1_mirae_application` | 행동 | career | 1–1 |  |
| `m1_phone_off_sunday` | 행동 | recovery | 1–3 |  |
| `m1_youth_center_resume_clinic` | 행동 | growth | 1–3 |  |
| `m2_mirae_result_message` | 장면 | consequence | 5–5 |  |
| `m2_rain_delivery_shift` | 행동 | livelihood | 6–7 |  |
| `m2_seorin_application` | 행동 | career | 5–6 |  |
| `m2_sleep_debt_sunday` | 행동 | recovery | 5–8 |  |
| `m2_youth_center_mock_interview` | 행동 | growth | 7–7 |  |
| `m3_empty_saturday` | 행동 | recovery | 9–11 |  |
| `m3_hanbit_application` | 행동 | career | 9–9 |  |
| `m3_inventory_shift` | 행동 | livelihood | 9–11 |  |
| `m3_library_job_board` | 행동 | growth | 9–12 |  |
| `m3_room_ledger` | 행동 | recovery | 9–12 |  |
| `m3_seorin_result_message` | 장면 | consequence | 9–9 |  |
| `m4_certificate_session` | 행동 | growth | 13–15 |  |
| `m4_dodam_application` | 행동 | career | 13–13 |  |
| `m4_hanbit_interview` | 장면 | career | 14–14 |  |
| `m4_health_check_day` | 행동 | recovery | 13–16 |  |
| `m4_housing_welfare_consultation` | 행동 | growth | 13–16 |  |
| `m4_logistics_shift` | 행동 | livelihood | 13–15 |  |
| `m5_city_service_application` | 행동 | career | 17–17 |  |
| `m5_employment_contract_clinic` | 행동 | growth | 17–20 |  |
| `m5_evening_spreadsheet_class` | 행동 | growth | 17–20 |  |
| `m5_hanbit_offer_message` | 장면 | consequence | 17–17 |  |
| `m5_last_empty_sunday` | 행동 | recovery | 17–20 |  |
| `m5_weekend_move_shift` | 행동 | livelihood | 17–20 |  |
| `m6_city_service_response` | 장면 | consequence | 23–23 |  |
| `m6_daeun_tuesday_followthrough` | 장면 | pursuit | 21–21 | daeun |
| `m6_dodam_response` | 장면 | consequence | 22–22 |  |
| `m6_gangnam_receipt_walk` | 장면 | reflection | 21–23 |  |
| `m6_holiday_night_shift` | 행동 | livelihood | 21–23 |  |
| `m6_last_study_group` | 행동 | growth | 21–23 |  |
| `m6_no_plans_day` | 행동 | recovery | 21–23 |  |
| `m6_public_recruitment` | 행동 | growth | 21–23 |  |
| `opening_interview_math` | 장면 | consequence | 1–4 |  |
| `sangchul_second_coffee` | 장면 | pursuit | 19–20 | sangchul |
| `sangchul_world_meet` | 장면 | encounter | 13–14 | sangchul |
| `sns_pressure_night` | 장면 | reflection | 5–8 |  |
| `temptation_consequence` | 장면 | consequence | 8–8 |  |

## 정답 선택 417건

한 선택이 [`DEMO_TIER_AUDIT.md`](DEMO_TIER_AUDIT.md)가 고정한 축 아홉에서
모두 우월하고, 최소 한 축에서 낫고, 후속도 플래그도 갈리지 않는 자리다.
**고민이 아니라 답이 있다.** 판정은 `tools/project_dashboard.py`의
`dominant_index()`가 소유한다.

| 파일 | 건수 |
|---|---:|
| `life_events.json` | 21 |
| `callback_events_25.json` | 13 |
| `investment_events.json` | 13 |
| `callback_events_14.json` | 12 |
| `callback_events_13.json` | 11 |
| `callback_events_16.json` | 11 |
| `callback_events_17.json` | 11 |
| `callback_events_21.json` | 11 |
| `drama_events2.json` | 11 |
| `callback_events_11.json` | 10 |
| `callback_events_19.json` | 10 |
| `callback_events_20.json` | 10 |
| `callback_events_22.json` | 10 |
| `callback_events_12.json` | 9 |
| `callback_events_23.json` | 9 |

상위 15개 파일만 적는다(전체 81개 파일).

## 선택 마인드맵 — 데모 체인 42개

체인 하나가 장면 하나다([`SCENE_TIER.md`](SCENE_TIER.md) §0).
지금 짓고 있는 데모 구간만 그린다 — 전 구간 65체인은 HTML 쪽에서 본다.
`⚠︎연출없음`은 `direction` 키가 없다는 뜻이고, 그 구현 링크는 아직 끝나지 않았다.

<details><summary><b>1+1</b> — 1링크 · 선택점 1 (<code>arc_daeun_01_meet</code>)</summary>

```mermaid
flowchart TD
  arc_daeun_01_meet["1+1"]
```

</details>

<details><summary><b>전화</b> — 1링크 · 선택점 1 (<code>arc_father_01_call</code>)</summary>

```mermaid
flowchart TD
  arc_father_01_call["전화"]
```

</details>

<details><summary><b>일요일 저녁</b> — 1링크 · 선택점 1 (<code>arc_father_quiet_call</code>)</summary>

```mermaid
flowchart TD
  arc_father_quiet_call["일요일 저녁"]
```

</details>

<details><summary><b>첫 면접</b> — 2링크 · 선택점 2 (<code>arc_intro_01_meal</code>)</summary>

```mermaid
flowchart TD
  arc_intro_01_meal["첫 면접"]
  arc_intro_02_dad_call["통장에 찍힌 숫자 ⚠︎연출없음"]
  arc_intro_01_meal -->|"'가족 빚을 갚고 있었습니다' — 담담하게 말했"| arc_intro_02_dad_call
  arc_intro_01_meal -->|"'개인 사업을 준비했습니다' — 그럴듯하게 포장"| arc_intro_02_dad_call
```

</details>

<details><summary><b>새벽 2시</b> — 1링크 · 선택점 1 (<code>arc_intro_03_sns</code>)</summary>

```mermaid
flowchart TD
  arc_intro_03_sns["새벽 2시"]
```

</details>

<details><summary><b>옆방</b> — 2링크 · 선택점 2 (<code>arc_intro_04_hyunsu</code>)</summary>

```mermaid
flowchart TD
  arc_intro_04_hyunsu["옆방"]
  arc_chapter1_close["서울에서의 첫 두 달 ⚠︎연출없음"]
  arc_intro_04_hyunsu -->|"'저도 아직 모르겠어요. 찾는 중이에요.'"| arc_chapter1_close
  arc_intro_04_hyunsu -->|"'강남 갈 거예요. 5년 안에.'"| arc_chapter1_close
```

</details>

<details><summary><b>접촉</b> — 1링크 · 선택점 1 (<code>arc_jiyeon_01_crash</code>)</summary>

```mermaid
flowchart TD
  arc_jiyeon_01_crash["접촉"]
```

</details>

<details><summary><b>또, 너</b> — 1링크 · 선택점 1 (<code>arc_jiyeon_02_store</code>)</summary>

```mermaid
flowchart TD
  arc_jiyeon_02_store["또, 너"]
```

</details>

<details><summary><b>쉬운 돈</b> — 1링크 · 선택점 1 (<code>arc_temptation_01</code>)</summary>

```mermaid
flowchart TD
  arc_temptation_01["쉬운 돈"]
```

</details>

<details><summary><b>지나간 자리</b> — 1링크 · 선택점 0 (<code>arc_temptation_clean</code>)</summary>

```mermaid
flowchart TD
  arc_temptation_clean["지나간 자리"]
```

</details>

<details><summary><b>빌려준 계좌의 반환 요청</b> — 1링크 · 선택점 1 (<code>arc_temptation_fallout</code>)</summary>

```mermaid
flowchart TD
  arc_temptation_fallout["빌려준 계좌의 반환 요청"]
```

</details>

<details><summary><b>강남 카페</b> — 10링크 · 선택점 6 (<code>cafe_00</code>)</summary>

```mermaid
flowchart TD
  cafe_00["강남 카페"]
  cafe_listen_01["틈"]
  cafe_mind_01["아메리카노 한 잔의 시간"]
  cafe_peek_01["훔쳐본 것"]
  cafe_talk_01["말을 걸다"]
  cafe_caught_honest["들킨 솔직함"]
  cafe_humble["낮은 자세"]
  cafe_bluff_01["허세"]
  cafe_bluff_caught["들통"]
  cafe_bluff_recover["무너진 뒤"]
  cafe_00 -->|"조용히, 계속 엿듣는다"| cafe_listen_01
  cafe_00 -->|"신경 끄고 이력서나 본다"| cafe_mind_01
  cafe_listen_01 -->|"폴더를 슬쩍 펼쳐본다"| cafe_peek_01
  cafe_listen_01 -->|"그가 돌아오면 말을 걸어본다"| cafe_talk_01
  cafe_peek_01 -->|"솔직히 사과한다 — '죄송합니다, 관심이 많아서"| cafe_caught_honest
  cafe_talk_01 -->|"솔직하게 — '무직입니다. 배우고 싶습니다'"| cafe_humble
  cafe_talk_01 -->|"있는 척한다 — '저도 이쪽 일 좀 합니다'"| cafe_bluff_01
  cafe_bluff_01 -->|"아는 척 우긴다 — 대충 숫자를 던진다"| cafe_bluff_caught
  cafe_bluff_01 -->|"무너진다 — '...사실 모릅니다. 죄송합니다'"| cafe_bluff_recover
```

</details>

<details><summary><b>도시시설운영단 작업표 요청</b> — 1링크 · 선택점 0 (<code>v2_city_service_work_sample_message</code>)</summary>

```mermaid
flowchart TD
  v2_city_service_work_sample_message["도시시설운영단 작업표 요청"]
```

</details>

<details><summary><b>카운터의 첫 새벽</b> — 1링크 · 선택점 0 (<code>v2_convenience_trial_shift</code>)</summary>

```mermaid
flowchart TD
  v2_convenience_trial_shift["카운터의 첫 새벽"]
```

</details>

<details><summary><b>못 한 인사</b> — 1링크 · 선택점 1 (<code>v2_daeun_return_after_distance</code>)</summary>

```mermaid
flowchart TD
  v2_daeun_return_after_distance["못 한 인사"]
```

</details>

<details><summary><b>이번에는 먼저</b> — 1링크 · 선택점 1 (<code>v2_daeun_return_named</code>)</summary>

```mermaid
flowchart TD
  v2_daeun_return_named["이번에는 먼저"]
```

</details>

<details><summary><b>다음 화요일</b> — 1링크 · 선택점 1 (<code>v2_daeun_small_commitment</code>)</summary>

```mermaid
flowchart TD
  v2_daeun_small_commitment["다음 화요일"]
```

</details>

<details><summary><b>한마디 더</b> — 1링크 · 선택점 1 (<code>v2_daeun_third_greeting</code>)</summary>

```mermaid
flowchart TD
  v2_daeun_third_greeting["한마디 더"]
```

</details>

<details><summary><b>약속한 화요일</b> — 1링크 · 선택점 1 (<code>v2_daeun_tuesday_followthrough</code>)</summary>

```mermaid
flowchart TD
  v2_daeun_tuesday_followthrough["약속한 화요일"]
```

</details>

<details><summary><b>첫 청구서</b> — 3링크 · 선택점 2 (<code>v2_demo_first_bill_opening</code>)</summary>

```mermaid
flowchart TD
  v2_demo_first_bill_opening["첫 청구서"]
  v2_demo_first_bill["첫 청구서"]
  v2_demo_first_bill_ledger["첫 청구서"]
  v2_demo_first_bill_opening -->|"아버지의 마지막 문자를 다시 읽는다"| v2_demo_first_bill
  v2_demo_first_bill_opening -->|"잔액에서 이번 달 고정비를 빼 본다"| v2_demo_first_bill
  v2_demo_first_bill_opening -->|"손목과 허리 상태를 확인한다"| v2_demo_first_bill
  v2_demo_first_bill -->|"아버지에게 다시 전화한다"| v2_demo_first_bill_ledger
  v2_demo_first_bill -->|"한빛유통 월말 오류표를 끝낸다"| v2_demo_first_bill_ledger
  v2_demo_first_bill -->|"도시시설운영단 작업표를 제출한다"| v2_demo_first_bill_ledger
  v2_demo_first_bill -->|"다은이 일하는 편의점에 가서 식사를 묻는다"| v2_demo_first_bill_ledger
  v2_demo_first_bill -->|"재혁에게 먼저 이번 주 안부를 보낸다"| v2_demo_first_bill_ledger
  v2_demo_first_bill -->|"상철이 준 빈 메모지에 이번 달 지출을 맞춘다"| v2_demo_first_bill_ledger
  v2_demo_first_bill -->|"오늘 밤 급한 유급 일을 잡는다"| v2_demo_first_bill_ledger
  v2_demo_first_bill -->|"알람만 맞추고 침대에 눕는다"| v2_demo_first_bill_ledger
```

</details>

<details><summary><b>도담고객센터 채용 결과</b> — 1링크 · 선택점 0 (<code>v2_dodam_result_message</code>)</summary>

```mermaid
flowchart TD
  v2_dodam_result_message["도담고객센터 채용 결과"]
```

</details>

<details><summary><b>비워 둔 일요일</b> — 1링크 · 선택점 0 (<code>v2_empty_sunday</code>)</summary>

```mermaid
flowchart TD
  v2_empty_sunday["비워 둔 일요일"]
```

</details>

<details><summary><b>약국 봉투</b> — 1링크 · 선택점 1 (<code>v2_father_health_signal</code>)</summary>

```mermaid
flowchart TD
  v2_father_health_signal["약국 봉투"]
```

</details>

<details><summary><b>강남역 저녁 산책</b> — 1링크 · 선택점 1 (<code>v2_gangnam_receipt_walk</code>)</summary>

```mermaid
flowchart TD
  v2_gangnam_receipt_walk["강남역 저녁 산책"]
```

</details>

<details><summary><b>한빛유통 1차 면접</b> — 1링크 · 선택점 1 (<code>v2_hanbit_interview</code>)</summary>

```mermaid
flowchart TD
  v2_hanbit_interview["한빛유통 1차 면접"]
```

</details>

<details><summary><b>한빛유통 채용 연락</b> — 1링크 · 선택점 1 (<code>v2_hanbit_offer_message</code>)</summary>

```mermaid
flowchart TD
  v2_hanbit_offer_message["한빛유통 채용 연락"]
```

</details>

<details><summary><b>시험 전 마지막 문제</b> — 1링크 · 선택점 1 (<code>v2_hyunsu_exam_eve</code>)</summary>

```mermaid
flowchart TD
  v2_hyunsu_exam_eve["시험 전 마지막 문제"]
```

</details>

<details><summary><b>먼저 보낸 메시지</b> — 2링크 · 선택점 1 (<code>v2_hyunsu_player_reachout</code>)</summary>

```mermaid
flowchart TD
  v2_hyunsu_player_reachout["먼저 보낸 메시지"]
  v2_hyunsu_first_study["처음 함께한 한 시간"]
  v2_hyunsu_player_reachout -->|"내일 저녁으로 시간을 정한다"| v2_hyunsu_first_study
```

</details>

<details><summary><b>같은 시간</b> — 1링크 · 선택점 1 (<code>v2_hyunsu_study_followup</code>)</summary>

```mermaid
flowchart TD
  v2_hyunsu_study_followup["같은 시간"]
```

</details>

<details><summary><b>나흘째 바코드</b> — 1링크 · 선택점 0 (<code>v2_inventory_count_nights</code>)</summary>

```mermaid
flowchart TD
  v2_inventory_count_nights["나흘째 바코드"]
```

</details>

<details><summary><b>10년 만의 메시지</b> — 1링크 · 선택점 1 (<code>v2_jaehyuk_message</code>)</summary>

```mermaid
flowchart TD
  v2_jaehyuk_message["10년 만의 메시지"]
```

</details>

<details><summary><b>포장마차에서 다시</b> — 1링크 · 선택점 1 (<code>v2_jaehyuk_plain_reunion_echo</code>)</summary>

```mermaid
flowchart TD
  v2_jaehyuk_plain_reunion_echo["포장마차에서 다시"]
```

</details>

<details><summary><b>같은 동네 큰길</b> — 1링크 · 선택점 1 (<code>v2_jiyeon_second_crossing</code>)</summary>

```mermaid
flowchart TD
  v2_jiyeon_second_crossing["같은 동네 큰길"]
```

</details>

<details><summary><b>어긋난 한 줄</b> — 1링크 · 선택점 0 (<code>v2_logistics_class_session</code>)</summary>

```mermaid
flowchart TD
  v2_logistics_class_session["어긋난 한 줄"]
```

</details>

<details><summary><b>방 안의 장부</b> — 1링크 · 선택점 1 (<code>v2_m3_room_ledger_anchor</code>)</summary>

```mermaid
flowchart TD
  v2_m3_room_ledger_anchor["방 안의 장부"]
```

</details>

<details><summary><b>방을 고르는 기준</b> — 1링크 · 선택점 1 (<code>v2_m4_housing_consultation_anchor</code>)</summary>

```mermaid
flowchart TD
  v2_m4_housing_consultation_anchor["방을 고르는 기준"]
```

</details>

<details><summary><b>미래산업기술 채용 결과</b> — 1링크 · 선택점 0 (<code>v2_mirae_result_message</code>)</summary>

```mermaid
flowchart TD
  v2_mirae_result_message["미래산업기술 채용 결과"]
```

</details>

<details><summary><b>네 번째 집 앞</b> — 1링크 · 선택점 0 (<code>v2_moving_crew_days</code>)</summary>

```mermaid
flowchart TD
  v2_moving_crew_days["네 번째 집 앞"]
```

</details>

<details><summary><b>125년</b> — 1링크 · 선택점 1 (<code>v2_opening_return_math</code>)</summary>

```mermaid
flowchart TD
  v2_opening_return_math["125년"]
```

</details>

<details><summary><b>두 번째 믹스커피</b> — 1링크 · 선택점 1 (<code>v2_sangchul_demo_echo</code>)</summary>

```mermaid
flowchart TD
  v2_sangchul_demo_echo["두 번째 믹스커피"]
```

</details>

<details><summary><b>방 보러 간 날</b> — 4링크 · 선택점 2 (<code>v2_sangchul_housing_lead</code>)</summary>

```mermaid
flowchart TD
  v2_sangchul_housing_lead["방 보러 간 날"]
  arc_sangchul_01_measure["사람을 읽는 법"]
  arc_sangchul_01_coffee["종이컵 하나"]
  arc_sangchul_01_answer["그 질문"]
  v2_sangchul_housing_lead -->|"'제 사정을 어떻게 아셨어요?'"| arc_sangchul_01_measure
  v2_sangchul_housing_lead -->|"'커피만 마시고 가겠습니다.'"| arc_sangchul_01_coffee
  arc_sangchul_01_measure -->|"'그럼 저는 어디까지 갈 사람으로 보입니까?'"| arc_sangchul_01_answer
  arc_sangchul_01_coffee -->|"'그 질문에는 답할 수 있습니다.'"| arc_sangchul_01_answer
```

</details>

<details><summary><b>서린물산 채용 결과</b> — 1링크 · 선택점 0 (<code>v2_seorin_result_message</code>)</summary>

```mermaid
flowchart TD
  v2_seorin_result_message["서린물산 채용 결과"]
```

</details>

---

생성기: [`tools/project_dashboard.py`](../tools/project_dashboard.py) · 이 문서의 수치는 저장소의 현재 상태이며 손으로 적은 값이 아니다.
