# ORDER-807 — 지연의 좁은 방 선택 결과 CJK 독립 검수

판정: **GO — JA/CN/TW의 날 선 대답 결과 3곳과 JA 포옹 결과 1곳의 지정 구간에 한정.**
검수자 `/root/review_791`, 작성자 `/root`, 검수일 2026-11-06 KST.
후보 `2440b7e7b377080bd6e8c34aab59715be31f7bd5`, tree `40598b3b2370f504ec37e58c485192fcf208d15a`.
기준 선언 `95cbbe68fbd062a61fb89b660aaf250bca771c57`.

실제 한국어 `arc_jiyeon_narrow_room_2`·`arc_jiyeon_narrow_room_decision` 본문·선택·결과, 침묵과 진실의 두 후속 장면, 지정된 이전/최종 대상 4개 전체를 직접 대조했다.

- `narrow_room_2.choices[1]`: 지연이 정면으로 보고, 본능적으로 날 선 대답을 돌려줄 것 같았지만 입술이 잠깐 멎는다. JA `鋭い言葉を返す`, CN/TW `回一句带刺的话／回一句帶刺的話`가 예상의 대상을 말로 명시한다. 날카로운 입술 모양이나 실제 먼저 쏘아붙인 대사를 만들지 않는다. 이후 질문이 싫지만 틀리진 않다는 두 대사와 시선은 그대로다.
- `narrow_room_decision.choices[0]` JA: 말 대신 실제로 그녀를 안는 행동은 `抱きしめた`로 기존 선택 문구 `抱きしめる`와 맞는다. 몸이 처음 굳었다가 이마를 어깨에 묻고, 라면이 불어도 둘이 움직이지 않는 다음 행위가 보존됐다. 성관계·별도 행동·추가 감정을 발명하지 않았다.

`DataRegistry._merge_choice_overlay`는 같은 KO 배열 인덱스에 번역을 합치고, `StoryMode`는 원래 버튼 인덱스에서 동일 `choices[idx]`의 `result_text`와 후속을 각각 읽는다. 선택0의 silence와 선택1의 truth, 그 두 장면의 decision 합류는 동일하다. 상태 효과는 별도 경로이며 해당 KO 필드·플래그·호감도·비소유 선택은 바뀌지 않았다. 코드상 연결을 확인했으며 실제 선택 입력이나 화면을 실행하지 않았다.

현재 canonical collector의 순수 `check_batch` 3개, 실제 shipping KO, 5필드 응답·이전 target·공식 영수증을 독립 확인했다. 지정 구간 이외의 바이트·`{name}`·문단 경계와 CN의 기존 compact 서식은 보존됐다. 전체 대상 JSON3과 현지화 원장 byte 역복원, 이전 396배치 및 동일 source superseded 수용4, 비소유 15 Git blob을 확인했다. diff는 세 대상 JSON·원장·CLAUDE 상태뿐이다. 기존 정정4·신규0이며 KO/EN·다른 선택/언어/변형·저장·공개 데모는 그대로다.

공식 export/check/import 로그에 JA2/CN1/TW1 및 빈 stderr가 남아 있다. 독립 순수 검사는 실제 exit0이며 수용 후 공식 CLI는 다시 실행하지 않았다. 데모5/14/100/122, EN1813/35 clean, CJK skeleton 로그를 읽었고 lane11은 선택 목록이다. 원자료 34파일 `.git/localization-cjk-jiyeon-narrow-results-20261106.jjCiM4/`의 개별 크기/SHA·집합 SHA, 영수증과 이전 target은 동반 JSON에 결속했다. 기존 판정 365개는 그대로 보존하고 이 work_unit 한 건만 추가한다.

자동 게이트는 도달 가능성과 계약 충족의 증거이지 재미·깊이·문체의 증거가 아니다. 이번 GO는 직접 원문 대조와 보존 검사에 따른 일회성 source 판정이다. 실제 엔진·화면·원어민·사람 플레이·물리 패드·대표 완주·후보 CI·외부 게시/출시는 미관찰이다.
