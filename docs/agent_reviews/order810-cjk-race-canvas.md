# ORDER-810 — 본편 경마 CJK 장내 표지 독립 검수

판정: **GO — 세 draw 표지와 JA/CN/TW 기존 사전에 신규 연결한 9값에 한정.**
검수자 `/root/review_791`, 작성자 `/root`, 검수일 2026-11-06 KST.
후보 `bdfce09e7a077f53d50b1ff4a8a3e2e2a899e9d1`, tree `074bfcb06660184fc39e3257c67f000681f1afd3`.
선언 `b0415829c594a68fd36f5b52bb79107ccf7987ff`, 공식 source-only 결속 `9b570d51d7cd1e3f007858a6d0451d6f9751df6a`.

실제 `RaceTrack._draw_finish_gate`, `_draw_live_board`, `_draw_finish_photo`의 세 호출, 그리기 좌표·바탕/테두리·글자 크기/색·정렬, 기존 `ThemeDB.fallback_font`를 대조했다. 세 호출의 기존 문자열·폰트와 helper를 역적용하면 선언의 RaceTrack 전체 바이트로 돌아간다. JA/CN/TW 대상은 번들 `FontKit.ui_regular()` 역할을 쓰고, KO/EN·기타 언어·`is_demo_build`가 참인 데모는 기존 영어 표지와 기존 전달 폰트로 돌아간다. UIStyle은 언어 변경 시 공유 역할 리소스의 대상 폰트를 바꾼다. 실행 환경에 따라 fallback과 역할이 같은 객체일 수 있으므로 분기 자체의 동일성은 코드 역대조로 판단했다.

한국어 ‘결승선’, ‘실시간 순위’, ‘사진 판정’을 실제 위치와 각 지역 번역에 직접 대조했다. JA `ゴール`·`暫定順位`·`写真判定`은 결승선, 경주 중 변동 가능한 순위, 결승 사진 판정이다. CN `终点线`·`实时排名`·`终点摄影判定`, TW `終點線`·`即時名次`·`終點攝影判定`도 같은 세 기능을 보존한다. 진행 중 순위를 최종 결과로 바꾸거나, 결과 캔버스의 사진 판정을 새 촬영 기능으로 뜻바꾸지 않는다.

`MainGame`의 full-story 경마 예약/저장 뒤 overlay 열기와 닫힌 실제 세션의 정산 영수증·원래 주차 복귀를 코드로 확인했다. RaceTrack의 경기 진행·착순 계산·베팅·정산·입력·저장 경로는 수정하지 않았다. 공개 데모 동결 제품/manifest와 데모 번역 표면도 그대로다. 아래 demo 실행은 `GameState.is_demo_build()` 분기의 격리 검사이며 실제 공개 데모 앱 실행·재빌드가 아니다. 준비 언어 허용 범위 또한 늘리지 않았다.

작성자의 격리 harness와 full/demo stdout·stderr·Godot 로그를 직접 대조했다. 별도의 새 격리 namespace에서 각 18행이 일치하고 빈 stderr 및 script/parse/error/warning 없음. full은 현지화9·유지9·글리프37, demo는 현지화0·유지18이다. harness는 11/12/12px에서 폭 상한 70/250/220과 글리프·역할, 금액/플래그 불변을 검사했다. 문자열/폰트/폭 수치 증거이며 실화면, 픽셀 배치, 실제 레이스와 저장 IO를 실행한 판정은 아니다. 독립 검수자는 엔진을 재실행하지 않았다.

선언 revision의 export 3묶음(9파일)은 읽기 전용 이력이며 해당 batch 수용 영수증이 없다. 실제 `RaceTrack` 한 파일을 담은 source-only revision에서 다시 결속한 공식 source로 현재 canonical 순수 `check_batch` 세 개, 5필드 응답·null 이전 target·공식 영수증을 확인했다. 기존 사전 키·수용에는 없던 9값이며 전체 사전3·현지화 원장 byte 역복원, 이전 399배치, 비소유 14 Git blob을 확인했다. 공식 최종 check/import 로그는 각각 3값과 빈 stderr를 보여 준다. 독립 검사 exit0, 수용 후 공식 CLI 재실행0. JA UI clean/beta·데모5/14/100/122·EN1813/35 clean·CJK skeleton 로그를 읽었다. lane47은 검사 선택 목록이다.

원자료 49파일 `.git/localization-cjk-race-canvas-20261106.0T3NSm/`의 크기/SHA·집합 SHA와 영수증/두 revision은 동반 JSON에 결속했다. 이전 판정 368개는 그대로 보존하고 work_unit 한 건만 추가한다. 자동 게이트는 도달 가능성과 계약 충족의 증거이지 재미·깊이·문체의 증거가 아니다. 이 GO는 지정 표지의 source/격리 검사에 한정하며 실제 화면·레이스·저장/불러오기·원어민·사람 플레이·물리 패드·대표 완주·후보 CI·외부 게시/출시는 미관찰이다.
