# ORDER-589 — M20 현수 발령의 무조건 동거 회상

#### [~] ORDER-589 [정합] KO/EN 4잎 수리 착수 — 2026-10-13

기준 clean main717d5aee808d1e92b8a3f1dbd3575f93a93a4e0c/
tree4bb7d0f26c2788c91127c3476ed2ca2cf4afde13. M17→19 뒤 M20의 story_map과
실제 새 문턱4개/KOEN 본문·변형·선택·결과를 읽었다. source 관찰이지 실제월 GO가
아니다. Mac잠금·실제M17 HOLD 하나, 해제 즉시562 원W68 우선·CI빨강 새월0.

## 근거·깊이

MainGame:8152–8154 hyunsu_pass_news는 W80+/hyunsu_passed/미열람만 요구한다.
GameState:1642–1656 이사·MainGame:7640–7644 탈출 회상이 먼저 완료돼도 열리며
현 본문은 현수의 고시원을 방문한다고 쓴다. 그러나 choice0는 언제 여기 나가냐/
한 명 먼저 나갔다고 현재 동거·선후를, choice1은 다음날 빈방/공용 주방과 새벽
소리 부재를 민준의 직접 관찰처럼 쓴다. 현재 주거/재방문 근거0이다.

1. 이미 이사한 경로의 주소/관찰을 발명하지 않아야 한다.
2. 게임플레이·24주 상태차이0, 새 선택/주거/재방문/연락·사진을 추가하지 않는다.
3. 현수의 현 짐싸기·발령지로 떠남, 그 자리를 방문하고 돌아가는 현재 장면으로
   닫는다. 순대국밥/비용/호감·친구를 보내는 여운과 확인된 라면 기억은 유지한다.

## 소유·대체

- root 제품 content/events/arc_hyunsu.json 및 content/events_en/arc_hyunsu.json의
  hyunsu_pass_news choices[0/1].result_text 각각2잎, 총4잎 안의 아래 구절만.
  choice0 질문을 형은 다음에 어디로 갈 거예요 / Where are you headed next,
  hyung으로; 끝 선후 단정을 현수는 다음 주에 발령지로 떠난다 / Next week,
  Hyunsu would leave for his new posting으로 바꾼다. 기존 글쎄/식사/계산서 유지.
  choice1 다음날/며칠간 직접 부재관찰 두 문단을 현재 냄비 포장→기존2시 물끓음
  기억→민준 복도·계단 출발/테이프 소리로 쓴다. 처음 감사/서툰 악수 문단 exact.
- 의존 지문 content/meta/release_content_inventory.json의 실제 content SHA만,
  docs/CONTENT_RATING_INVENTORY.md 공식 보고만; 불변이면 수정0.
- root metadata 큐2·이 사양/완료archive·WORK_LOG·CLAUDE 현재행만.
  manual_save_ci 새 .git/order589-20261013/independent-review.md,
  rework_batch_plan 새 preservation-review.md만 소유한다. 다른 파일/쓰기0.

description의 방4년은 공부4년과 다른 사실이라 미확정으로 수리0, choices/effects/
flags/조건/후속16주/비용/관계/주거·런타임/시각/오디오 나머지 bytes exact다.
KOEN 확정까지 JAzh 다듬기/원장수용0·출시5언어 유지·source2잎 정합대기는 공개한다.
직전588 after3locale를 실제 원관측 before로 재사용, 새수집이라고 보고하지 않는다.

## 검수·경계

선언 commit/push→4잎 한정수리→공식3locale inventory after→EN coverage/Hangul·
narrative continuity/spine·story consistency·exposed_state·speech/audio·i18n·
demo scope/story demo/JA/ZH demo·release 지문/보고·context/queue/diff.
원문span 역복원/게임플레이·데모72/공개14·CJK/원장/비소유 독립 대조, 의미 전4잎
독립판독·source GO/새제품게이트실패0 전 완료0. 번역 정합대기를 전체언어 오류0으로
덮지 않는다. 새tool/검사/등록/selftest/엔진/native/전체audit/240주 실행0.

장면추가/격상·자산/연출0·기존미선언T3, 전장면 승인0. project.godot/사용자 저장·
설정/원559seed·앱/옛raw·human원장 비소유·접근0. gangnamdream-dev/WORK_UNIT의
조건·소유·한영 표적검수/관찰 분리 적용·일회성/승격0. 자동 계약은 재미·깊이·문체/
인간·원어민·물리패드 증거가 아니다. 공개GO·인간OPEN45·전체언어/본편/출시HOLD·
종료잔여 유지. CI717d5ae run38347941886 진행중/완료미확정·M21 선행0.

## 실제 결과

미완료. 실제M20/월 완료를 source 수리로 대신하지 않는다.
