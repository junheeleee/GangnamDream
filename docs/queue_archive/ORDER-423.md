# ORDER-423 — 선택 카드의 위험도를 다시 보이게 한다

#### [x] ORDER-423 [P1·UI] SceneFirst 위험도 최소폭 수리

**[~] 착수 — 2026-10-04.** 421 최초 actual24.431초 FAIL을 보존한다.
CN/TW 8화면의 risk24개는 실제12px/SC·TC폰트·높이18px 정상이나 폭1px으로
필요36~48px를 담지 못한다. 원본8PNG에서도 위험도가 보이지 않는다.
나머지 카드텍스트192행·typed8복원·32taps/64이벤트는 산출됐지만 421은 HOLD다.

## 판정 범위·소유

- Root: scenes/MainGame.gd::_make_demo_decision_card risk_label의 actual font/size/
  uppercase text에서 산출한 최소폭만 추가. 단독 제품커밋으로 exact 계보를 만든다.
  큐·본사양·421 상태기록·CLAUDE·WORK_LOG·생성STATUS·archive·판정원장/보고,
  새 private423 정상검수 runner. 실패원본/기존 helper 수정0.
- /root/receipt_bridge392: tools/main_game_locale_history.py의 새 exact predecessor,
  tools/ui_translation_append.py source-manifest 연결, tools/decision_risk_width_self_test.py
  새 focused, tools/audit_scope.json 등록/차선. 기존 proof·focused 본문/봉인본 수정0.
- /root/receipt_tests392: 새 private421-r1 화면입력 및 private423 KO/EN/JA 실제카드
  관측 helper. 기존421 원본 helper/8PNG/관측값은 불변이다.
- /root/independent392: 제품diff·source 역상/실제collector·반례·실제PNG/입력
  독립검수. 421/422/423은 최종 동일 후보에서 별도 범위판정을 남긴다.
- 게임플레이·조건·KO/EN/JA/중문번역·원장41442/b195·폰트·project.godot·인간원장/
  공개demo/출시manifest 변경0. 위험도 의미·수치·글자크기·clip/ellipsis 규칙 유지.

## 수리·검수

- fixed36/48폭·글자축소·본문축약이 아니라 실제 resolved font와 해당문구 폭을 쓴다.
  risk가 공간을 차지해도 기존 rail/ONE·title·subtitle·now/cost/later가 겹치거나
  화면/카드 밖으로 나가지 않아야 한다. 새로운 디자인·행동 추가가 아니다.
- Main 단독 before/after commit/tree/blob/raw·direct-parent/ancestor/path population과
  exact 역상으로 앞선12단계 source 계보를 보존한다. 새 current raw와 모든 승인된
  predecessor manifest만 허용하고 raw변조/다른파일/누락/forged Git/실패402는 거부한다.
  현재 collector의 KO/EN/source leaf/기존 receipt 의미는 불변, runtime만 달라진다.
- 새 focused는 국소수리/전체raw/실제collector/source census/현재공식원장·기존 수용
  경계만 검사한다. 과거 focused/full/240주 재실행0.
- 421의 같은 CN/TW4상태×2지역8화면·risk24개를 새후보에서 재검수한다.
  realplayer34·typed입력/복원·meta파일·선택미확정·focus0→1→2→1→0의32taps/64
  합성이벤트도 같은 실행에서 확인한다. 폰트12/fullfit/소유glyph/clip조상 검사를 낮추지 않는다.
- KO/EN/JA 대표 실제3카드 화면을 추가해 shared consumer risk/rail/badge/3카드
  전체fit/비중첩/폰트와 상태복원을 확인한다. 준비상태·합성입력만의 증거이며
  자연스토리도달/실물패드/미실행선택효과/원어민·인간품질은 미관측이다.
  LOW/MEDIUM 외 ASSET RISK1~5/HIGH/UNCERTAIN도 같은 builder에 실제 붙인
  보조카드에서 5언어 전수측정한다. 보조카드를 자연 ingress/실행효과로 세지 않는다.
- 미실행421 normal은 폐기하지 않고 원본 helper를 보존한다. 새423 runner에서
  421·422·423 공통 정상검증과 두 새focused를 최종 같은후보에 최대3병렬1회 수행한다.
  실패하면 원본보존 후 해당 영향만 재검수한다. 현미검수로 미번역 저작을 무한정 미루지 않는다.

일회성 제품결함수리/상시규범추가0. 자동PASS는 계약증거이지 문체·재미·출시GO가 아니다.
공개GO1·인간OPEN45·본편/새packageHOLD·B3/B4와 실제관찰 한계는 유지한다.

## 완료 — 2026-10-04

- 동일 후보 source1d0753c/tree3db905b 독립 범위한정 GO: [봉인 보고](../agent_reviews/ORDER-423.json).
- ORDER423_UI_OK screens=3 actual_cards=9 auxiliary_cards=15 locales=5 raw=0 actions=0; ORDER421_R1_UI_OK screens=8.
- 공통 normal15행(검증14+차선조회1) 단1회/903.372초 PASS. 원본 FAIL·과거 판정·인간 원장은 보존한다.
- 일회성/새 상시규범0. 자동PASS는 계약증거이지 문체·재미·출시GO가 아니다. 본편/새packageHOLD·B3/B4·원어민/인간/물리 미관측 유지.
