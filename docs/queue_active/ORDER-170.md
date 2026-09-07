# Active Queue Spec: ORDER-170

> Canonical status and execution order are indexed in `docs/CODEX_QUEUE.md`.

#### [~] ORDER-170 [P0·전체 현지화] 다은·지연의 결혼과 가족 장면을 옮긴다

**[~] 2026-09-07 Codex 착수 — 아래 정확34 ID의 JA·zh-CN·zh-TW text-only
overlay, 원문 결속 검사·수용 기록·증거 문서만 소유한다.**
사용자 전체 게임 번역 지시를 이어가며 기존8,949/meta9·공개 working baseline·
배경 제품53493fe를 보존한다. 일본어 원화2문구의169 수정도 기존 수용 기준이다.

## 깊이 3문

1. **없으면 무엇이 깨지는가?** 결혼 준비·가족 만남·첫날밤·5년차 관계 회수가
   폴백 언어로 돌아간다. 생존/별세 대안을 함께 옮겨 동일 경로의 누락을 막는다.
2. **선택을 바꾸는가?** 비용·효과·시간·관계·생사·계약·라우팅 변경0이다.
   원문이 실제로 보낸 답장과 만남만 보존한다. 모든 회신을 금지하는 것도 왜곡이다.
3. **무엇과 경쟁하는가?** 나머지 관계·생활 사건·UI·소비자 번역이다.
   판정 가능한 각 source root를 단위로 A19/B15 두 배치를 구성했다.
   같은 관계 체인이라도 각 원문/번역 hash와 수용 판정은 독립이다.

## 배치 A — 다은19 roots /113 leaf /13,491 KO자

- `arc_daeun_the_test`
- `arc_daeun_wedding_prep`
- `arc_daeun_wedding_day`
- `arc_daeun_wedding_groom_side`
- `arc_daeun_wedding_groom_side_father_passed`
- `arc_daeun_wedding_walk`
- `arc_daeun_wedding_aisle`
- `arc_daeun_hometown_1`
- `arc_daeun_hometown_2`
- `arc_daeun_hometown_2_father_passed`
- `arc_daeun_hometown_table_hands`
- `arc_daeun_hometown_table_daughter`
- `arc_daeun_hometown_table_decision`
- `arc_daeun_wedding_night`
- `arc_daeun_wedding_night_tea`
- `arc_daeun_wedding_night_honest`
- `arc_daeun_wedding_night_choice`
- `arc_daeun_y5_feelings`
- `callback_daeun_committed_gangnam_eve`

source aggregate `25c73d1d546befa79abb472db3f58207af2f2aaab85e66a13202b9e2b0360ffe`.

## 배치 B — 지연15 roots /93 leaf /11,341 KO자

- `arc_jiyeon_wedding_gap`
- `arc_jiyeon_wedding_guest_list`
- `arc_jiyeon_wedding_gap_decision`
- `arc_jiyeon_wedding_gap_father_passed`
- `arc_jiyeon_wedding_guest_list_father_passed`
- `arc_jiyeon_narrow_room_1`
- `arc_jiyeon_narrow_room_2`
- `arc_jiyeon_narrow_room_silence`
- `arc_jiyeon_narrow_room_truth`
- `arc_jiyeon_narrow_room_decision`
- `arc_jiyeon_wedding_night`
- `arc_jiyeon_wedding_night_window`
- `arc_jiyeon_wedding_night_glass`
- `arc_jiyeon_wedding_night_choice`
- `arc_jiyeon_y5_feelings`

source aggregate `06212570363eaf0f979956a796821982ce943833c050bd1f81acde2237cb63b0`.

총206 leaf/24,832 KO자, 표준206=title34+description34+선택/결과116+known22.
조건 A11/B11, memory/scalar/reader/foreshadow0. 전체 source aggregate
`97452e37e418954ebb59d7c97f59d846c82dde4406be53db36ad9b3cbc54f366`.
독립 원문 추출과 ROOT collector가 일치했다. 전부 shipping/protected=false,
builtin_overlay_static_only, locale별 target/accepted0이다.

즉시 후속32 choice edges/26 root pairs가 이 범위 안에 있다. 유일한 지연
연결은 y5_feelings.choice0→callback_daeun_committed_gangnam_eve(delay8)이다.
callback에 추가 후속은 없다. MainGame의 hometown1→2·narrow_room1→2·결혼식→
첫날밤은 완료 플래그 선택이며 실제 플레이 도달성은 여기서 승인하지 않는다.

## 정확한 파일 소유권

각 `content/events_<ja|zh-CN|zh-TW>/`의 아래5파일에서 위34 ID만 추가한다.

- `arc_daeun_married.json`:7roots44 leaf
- `arc_jiyeon_married.json`:5roots36 leaf
- `arc_romance_specials.json`:19roots102 leaf
- `arc_romance_y5.json`:2roots17 leaf
- `callback_events_2.json`:1root7 leaf

언어별 작성자1명, 교차 L2 읽기 전용. 기존행 값/순서/raw prefix·조건 키/순서·
배열/개행/토큰을 보존하고 신규행만 추가한다. KO 직접 저작, 영어 중역·간번 변환0.
ROOT는 `tools/full_game_localization.py`, `tools/full_game_localization_self_test.py`,
`tools/zh_translation_audit.py`, `tools/audit_scope.json`,
`content/meta/full_game_localization.json`, 이 사양·CODEX_QUEUE·CLAUDE·WORK_LOG·
생성STATUS·전체 현지화 backlog를 소유한다. 부팅 예산 때문에 완료167 WORK_LOG절은
기존 `docs/history/WORK_LOG_2026-09-07_localization.md`로 원문 이동 보존한다.

KO/EN·runtime·저장·routing·human_gates·catalog/endings·공개·폰트·배포는 비소유다.
실제 원문에 걸린 수량·호칭 오탐만 정상/변조 짝으로 수리하고 독립 검토한다.
기존 baseline을 완화하거나 의미를 검사에 맞춰 바꾸지 않는다.

## 원문 사실 경계

- wedding_prep의 견적480만+1800만+500만+400만=3180만과 결과/효과3100만은
  원문 확인점이다. 준비 결과는 식 종료·사진 수령인데 뒤 wedding_day는 입장 전이다.
  번역에서 금액이나 시간축을 몰래 수리하지 않는다.
- 지연 narrow_room1에서 이미 민낯을 보지만 wedding_night_choice는 '처음 보는
  얼굴'이다. 문학적 새 아침인지 첫 노출 충돌인지는 원문 확인점으로 분리한다.
- 아버지 별세 대안은 사진·빈자리와 생전 기억이다. 실제 동석/통화를 만들지 않는다.
- callback의 선택0은 국밥 저녁과 방 두 개 메모이며 계약/소유 완료가 아니다.
  선택1의 '알겠어요'는 원문이 명시한 실제 회신이므로 삭제하지 않는다.
- 원문 대조는 새 인간 REJECT나 기존 Property GO 해제 증거가 아니다.

## 검증과 증거

- source manifest `edf845a7164b8fedc9ec027be7a7edc381a3dcdf67ff58c2858d44a3237b64b8`.
- 최초 source A/B×3을 보존하고 최종 source/response/receipt6쌍을 발급한다.
- 세 언어618문구를 다른 작성자가 KO 전수 대조한다. 생사·약속·동의·연수·
  금액·장소·인물·수량·관계 단계와 조건22/언어를 검사한다.
- 이전8,949/meta9·공개·기존행 보존. L1 표적 차선·EN·diff·결속과 독립 L2.
  L3·원어민·실제 화면 OPEN, 전체 INCOMPLETE·full/main/product HOLD·배포 데모 GO.

사양의 범위·증거·소유권은 일회성이다. 지속 규칙은 I18N_INFRASTRUCTURE와
각 용어집이 소유하며 새로운 서사·상품·출시 규칙을 만들지 않는다.
