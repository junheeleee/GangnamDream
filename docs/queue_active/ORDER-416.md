# ORDER-416 — 실제 반응 본문에 지역 서체를 연결한다

#### [~] ORDER-416 [P1·UI] 선물을 받은 사람의 대사를 번들 서체로 읽는다

**[~] 착수 — 2026-10-04.** 사용자 개발·독립검수·main 커밋/푸시 위임.
415 실제 화면에서 발견한 결함 한 건의 선행 수리이며 번역 범위를 늘리지 않는다.

## 판정 단위·근거

- MainGame::_build_story_panel event_body는 크기/색만 설정해 기본 Open Sans로 해석된다.
  sourcecff41a6의 24개 실제노드에서 shared_role=false, CJK glyph owned=false,
  SC/TC primary 미사용을 관측했다. 화면에 글자가 보인다는 사실만으로 통과하지 않는다.
- 기존 FontKit의 stable regular/bold를 연결한다. 언어 전환은 같은 리소스가 갱신한다.
  비용·친밀도·이후 관계·선택·시간·저장에는 변화가 없다.
- 19px scene-first는 UI_ART_DIRECTION의 VN19~21px 및 기존 실제 코드와 정합이다.
  415의18px/false 기대만 바로잡고 제품 크기·연출을 변경하지 않는다.

## 정확 소유

- Root: scenes/MainGame.gd::_build_story_panel의 event_body normal_font/bold_font 연결만.
  큐·이 사양·CLAUDE·WORK_LOG·생성STATUS·완료archive·agent review 보고/판정 원장.
- /root/receipt_tests392: 새 private415-r1 및416 검사helper만. 기존helper/실패원본 수정0.
- /root/independent392: 읽기전용 코드·실제노드·PNG·검사 독립검수와 최종보고.
- FontKit·GameState·번역사전/원장·폰트파일·StoryMode·씬상태/크기·입력·공개demo·
  인간원장·project.godot·출시manifest 비소유. 범용 검사/새기능0.

## 검수

- 정확 MainGame raw 차이로 두 font override 외 코드/문구/조건 불변을 검증한다.
- pre-autoload 격리된 실제 MainGame, 1280×800, 415 CN/TW24전달/6PNG를 함께 재검수.
  이전48실패를 보존하며 정상19px·scene-first와 빈 commitment를 정직하게 관측한다.
- 동일 생성본문에서 KO/EN/JA/CN/TW 언어 전환, regular/bold 실제 해석 객체·웨이트·
  번들primary/fallback·glyph 소유 및 실제 본문 표시를 표적검수한다.
  강조 스타일은 실제 리소스 연결 검사와 화면 관측 범위를 구분한다.
- source/helper/실제player 불변, 정상마커+stdout/Godot로그 오류검사를 요구한다.
  415 최종후보의 정상 영향검사를 공유하고 신규 본문서체 표적증거만 추가한다.
  전체감사/240주/변경없는 과거검사 반복0. 실패 시 해당 영향만 재실행한다.

## 경계

일회성 수리·기존 FontKit/타이포 계약을 적용하며 상시규범 추가0.
자동PASS는 계약증거이지 재미·문체·출시GO가 아니다. 본편/새packageHOLD,
공개GO1·인간OPEN45·원어민/인간/물리 미관측 및415의 연애전 호칭위험을 유지한다.
