# ORDER-590 — 현수 발령 식사의 16주 인용 정합

#### [~] ORDER-590 [정합] KO/EN 회상2잎 착수 — 2026-10-13

M20의589 독립검수에서 발견한 직접 종속 수리다. 현재HEAD
df516aa8768978866c3c3502bf0777fc04d05467/tree245980bb19f2d56e914a4ded51d9f0f4d91b56ce
위589 소유 source2파일만 dirty다. KOacb77fb682c80d4498dd6658dd67020337789d38ca03acfe2640c42f2fd2d1fd,
EN3dd2aec54ddc5bd2cd0ab6f7758e3b10d6846a5ecba090f9b4bfa078a9b99d89를 보존한다.
589를 미완료/HOLD로 두고590 선언을 먼저 commit/push, 최종 정합 뒤 두 작업을
한 구현 커밋으로 묶어 어느 쪽의 잘못된 인용도 main에 중간 배포하지 않는다.

## 근거·깊이·소유

producer arc_hyunsu.json:414–417는 hyunsu_departure_meal +16주 callback을 만든다.
reader callback_events_41.json:94–99는 그 식사를 회상하며 옛 질문을 직접 인용한다.
589의 주거 독립 질문과 달라져 하지 않은 말을 기억한다. 방치하면 선택의 사실을
위조하고, 반대 선택에는 callback가 생기지 않는다. 새 상태/후속을 만들지 않는다.

- root content/events/callback_events_41.json:
  callback_hyunsu_departure_meal_echo.description의 질문 한 구절만
  형은 언제 여기 나가요→형은 다음에 어디로 갈 거예요.
- root content/events_en/callback_events_41.json 같은 description에서
  Hyung, when are you getting out of here?→Where are you headed next, hyung?
  producer와 같은 질문, 기존 Not sure/글쎄 응답·영수증·현재주소·나머지 bytes exact.
- 필요시 content/meta/release_content_inventory.json 실제 contentSHA 및
  docs/CONTENT_RATING_INVENTORY.md 공식보고만. 불변이면 수정0.
- root metadata 큐2·590/589 사양과 마감archive·WORK_LOG·CLAUDE 현재행.
  rework_batch_plan은 새 .git/order590-20261013/independent-review.md만 소유;
  기존589 보고는 독립 scope4잎/후속HOLD를 명시하며 과거결과를 덮지 않는다.

조건/효과/flags/choices/result/16주·최소96주·장소/연출/저장/전체나머지 source exact.
원장/JAzh 다듬기·수용0·5언어 유지. 이 callback의 기존 result 시간 표현은 이번
새질문으로 생긴 결함이 아니므로 여기 붙이지 않고 해당 월의 사실 판독에 남긴다.

## 검수·경계

선언→2quote patch→공식3locale inventory(after589-v2를 실제before로 재사용)→
EN coverage/Hangul·story consistency·event_director·narrative continuity/spine·
speech/audio·i18n·demo scope/story demo/JA/ZH·release 지문/보고·context/queue/diff.
최종 producer/reader 질문 pair·선행과16주 routing/두span역복원·비소유/데모72/
공개14/CJK/원장/project/Human을 독립 source로 직접 대조한다. 독립GO/표적실패0
전589/590 완료0. 원어민/실제화면/전체언어완료가 아니다. 새tools/검사/등록/
selftest/엔진/전체audit/240주·실제월0, 장면추가/격상0·기존미선언T3다.
project.godot/사용자저장·설정/원559seed·앱/옛raw/과거인간 비소유·접근0.
gangnamdream-dev/WORK_UNIT의 생산자↔독자·소유·한영표적/관찰 분리 적용·일회성/승격0.
실제M17 Mac잠금HOLD 하나·해제즉시562 원W68 우선·CI빨강 새월0·M21 선행0,
공개GO·인간OPEN45·전체언어/본편/출시HOLD·종료잔여 유지.

## 실제 결과

미완료. 자동 계약은 재미·깊이·문체·인간/원어민/물리패드 증거가 아니다.
