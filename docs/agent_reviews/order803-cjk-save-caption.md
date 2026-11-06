# ORDER-803 — 본편 저장 목록 CJK 장면명 독립 검수

판정: **GO — 지원되는 본편 수동 장면 저장의 읽기 전용 표시 투영에 한정.**
검수자 `/root/review_791`, 작성자 `/root`, 검수일 2026-11-06 KST.
후보 `39372c98f5f92155347fe5af2003cf56b097e4d5`, tree `ad34560ae81f51ddab7d92c4164571da60f9416e`.
기준 선언 `7e6af6bcabceaa6d894e4a98658947bc6aa76ea6`.

## 실제 생산자·소비자와 예외

`StoryMode.build_save_resume_context`가 쓰는 `story_locale`과 `_save_story_to_slot`의 기존 자동 `챕터 %d · %s`/영어 대응 캡션을 확인했다. 본편 제품의 해당 `metadata.label` 작성 경로는 자동이며 지원되는 사용자 지정 이름 작성 경로는 발견하지 않았다. `SaveManager.get_save_info`만 이미 있는 `resume.story_locale`을 요약으로 노출한다. 저장 직렬화·스키마·호환 판정·파일 읽기 후보 선택·실제 불러오기 코드의 역대조는 동일했다.

`LocaleManager.full_story_slot_display_label`은 JA/CN/TW의 본편 실행, 양의 슬롯 번호, 호환·비QA·비모드, 정확한 StoryMode resume kind/scene, 본편 원본과 알려진 서로 다른 저장 언어를 요구한다. 현재 활성 모드도 제외한다. 챕터와 과거 기본 캡션 서식을 대조하고 빈 접미사를 거부하며, 저장 접미사를 ID로 해석하지 않는다. `DataRegistry.find_event`의 정확한 저장 ID와 중괄호 없는 비어 있지 않은 현행 제목을 읽고 기존 대상 서식을 사용한다. 해석할 수 없거나 서식이 실패하면 이전처럼 가장자리 공백을 정리한 원표시로 돌아간다. 자유문구와 다른 챕터 표시는 보존한다. 이 접두사 확인은 지원되는 생산자의 형태를 식별하는 가드이지, 수동 편집으로 같은 자동형을 모방한 임의 파일을 인증하는 수단은 아니다.

StartMenu의 일반·삭제 확인 슬롯 목록 둘과 StoryMode의 비공개 데모 슬롯 제목만 이 투영을 읽는다. StartMenu는 언어 적용/데이터 reload 이후 다시 그리며 StoryMode도 언어 적용 뒤 현재 이벤트를 다시 찾는다. 공개 StoryMode의 기존 별도 분기는 그대로다. KO/EN은 기존 표시와 같은 경로 결과로 남고, 같은 언어·자동저장·빈 라벨·호환불가·모드·불명·비정적 제목은 대체하지 않는다. 현재 언어의 원장/사전·저장 상태·진입 ID를 바꾸거나 언어 선택 허용 범위를 늘리지 않는다.

정확 역대조로 SaveManager 요약 1줄, LocaleManager preload와 투영 1곳, StartMenu 읽기 2곳, StoryMode 읽기 1곳, 회귀 fixture 및 CLAUDE 상태만 달라졌음을 확인했다. 비소유 13 Git blob과 공개 데모 inventory의 동결 제품 `4e80a63e89821094b8bab21b8d5c73ecfc9b6278`는 그대로다. 소스 검수는 배포 패키지 재빌드/재게시나 실사용 저장 파일 검수가 아니다.

## 격리 결과와 판정 결속

작성자의 초기 엔진 기록에는 fixture 패치 문법 오류가 남아 있다. 제품 라벨 결과로 세지 않았다. 고친 첫 실행은 `localized=6 preserved=44 immutable=3 real_saved_slots=0`이고, 확장 최종 실행은 `localized=9 story_reader=3 preserved=44 immutable=3 real_saved_slots=0`이다. 두 실행 모두 `I18N_INFRASTRUCTURE_CHECK_OK`, 각기 별도 격리 이름, 실행 전과 런타임 이름의 일치를 stdout/엔진 로그에서 확인했다. 초기 parse 증거와 달리 최종 두 묶음에는 의도된 서식 거절 경고 19개씩 외 SCRIPT/parse/ERROR가 없다. 독립 검수는 고정 자료와 코드의 읽기 전용 대조이며 별도 엔진 재실행은 하지 않았다.

회귀는 실제 registry 제목을 쓰는 언어 전환 9개, 인스턴스화한 StoryMode 읽기 3개, 제외 44개와 원본 요약 불변 3개를 포함한다. 타이틀 두 호출은 소스 대조이며 실화면 인스턴스/저장 IO를 검증한 것은 아니다. 데모 5언어/14사건/100문구/122UI, EN1813/35 clean, CJK skeleton 로그를 확인했다. lane79는 선택 목록이지 실행 증거가 아니다.

원자료 14파일 `.git/qa-cjk-slot-caption-20261106.jpFDGt/`의 크기/SHA·집합 SHA와 확인한 headless 표식은 동반 JSON에 결속했다. 이전 판정 361개를 그대로 보존하고 work_unit 판정 하나만 추가한다. 자동 게이트는 도달 가능성과 계약 충족의 증거이지 재미·깊이·문체의 증거가 아니다. 실제 저장/불러오기·렌더링·원어민·사람 플레이·물리 패드·M60 완주·후보 CI·외부 출시/게시 판정은 미관찰이다.
