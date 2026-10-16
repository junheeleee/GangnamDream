# ORDER-704 — 트레일러 목표 컷의 구 AP 진입을 현재 수첩으로 정렬

#### [~] ORDER-704 [C5 화면 없는 source 준비] 목표 컷 생산자1개 — 2026-10-16

## 근거·exact 범위

main388db78 CI38851221082 전체감사 success/실제입력 진행·전체녹색 미확정이다.
새실제월/M36을 열지 않고 C5 준비만 한다. CLAUDE 본편행동판0 및 현재
MainGame._render_ap_actions의 full-owner return과 달리 trailer02는 구MainGame/AP
진입을 호출하고 TRAILER_PRODUCTION은 AP판을 광고한다. 현재 캡처/영상이 실제
AP판인지 빈표면인지는 미관찰이며, source 불일치만 수리한다. 기존보류오더 재개0.

root 저작: `tools/ScreenshotQA.gd::_shot_trailer_goal_dashboard`의 MainGame
boot/APrender/직접save/dispose 꼬리만 기존 `_shot_story_event` 호출로 대체한다.
`story_prologue_goal` 완성본문/선택표시(true,true), 기존 frame key
`trailer_02_goal_dashboard`/settle0.55를 쓴다. 기존초기 W1/2026Jan/50만원/무직/
AP2와 flags 초기화는 그대로다. 기존motivation scope의 같은 StoryMode
수첩3선택을 재사용하며 새사건/대본/선택/효과/라우팅/자산을 만들지 않는다.
`docs/TRAILER_PRODUCTION.md`의4~8초 설명과 source준비/실화면 미검수 경계만
정렬하고 2026-07-13 생산증거는 역사 증거로 보존한다.

root metadata: 이사양/archive·CODEX_QUEUE/L3순번·WORK_LOG·CLAUDE 현재행,
`.git/order704-trailer-goal-20261016/`의원2파일/선언/before·after·검사raw/핀.
비저자 `/root/av_audio_status`는 source/지정private원문을 직접읽고 private
independent-review.{md,json} 두보고만 쓴다. Git/engine/UI/실사용자data 접근0.
root도 엔진/앱/실사용자 저장·설정 접근0·새capture/MP4/자산/외부업로드0.
선언commit 먼저·마감commit은 확인된source준비만·현황판전용commit0.

## 검증·판정 경계

깊이3문: C5 현재게임과다른AP광고 생산자를 제거; 제품선택/장기상태변화0;
같은4초slot의 현재StoryMode표면으로대체하며 사용자UI/저장과경쟁0.
증거양식: 호출producer→StoryMode/기존story_prologue_goal→timeline30/60s
두4초consumer; 상태=fixture생산자1개; 포기비용/서사위치/기존계층불변;
닫는것=목표컷 source준비만. 출력파일명22개/시간·caption·음향·다른함수·
sharedhelper·V2/Gallery/modal/제품runtime·content675·timeline·과거영상 불변.

전체raw역산으로 한helper밖0과 문서허용절밖0을 독립대조한다. 기존
`tools/trailer/trailer_check.py`, english_hangul, player_surface_language 정상/
self-test, feature_liveness 및 문서표적5/diff만 실행한다. audit_select의넓은
ScreenshotQA 매칭에 포함되는 V2완주/모달/Gallery/전체compile은 변경범위가
아니며 로컬재실행0·CI제품검사보존. source관측을 compile/capture로 바꾸지않는다.
새tool/wholeaudit/240주/새예외/검사완화0. 후속격리 KO/EN02실화면/네MP4/
정상속도·청취는 남으며 이작업은 이를 완료로 표시하지 않는다. 스포일러 등 다른
기존컷은 이번에 수용/새품질GO하지 않는다. 이후mainCI 녹색뒤 M36이 우선이다.
개발스킬 비소유보존/독립/표적 적용·일회성/승격0.

자동 게이트는 도달 가능성과 계약 충족의 증거이지 재미·깊이·문체의 증거가 아니다.
