# ORDER-561 — 계획표 선택의 허위 소득 감소 약속 수리

#### [x] ORDER-561 [P1·사실 정합] source 수리 완료 — 2026-10-11

559 actual M16의 소득 삭제 약속과 자동 생계 불일치 REWORK를 수리한다.
같은 파일의 M18에서도 같은 유형의 단정을 source로 확인했다. M18은 native
미관측이며 실제 플레이에서 발견했다고 쓰지 않는다. 선언 main push 뒤 구현한다.

## 깊이 3문·판단

1. 수입을 줄였다는 본문/결과와 매주 같은 자동 수입은 함께 참일 수 없다.
   다음 주 임금 삭감의 금액·기간·직업·once 시스템을 새로 발명하지 않는다.
2. 현재 승인된 자동 생계와 선택 효과를 보존하며, 일정표의 계획 한 줄을 지우고
   검토/수면/연락 계획을 적는 현재 행동으로 바꾼다. 실제 근무 취소·소득 감소·
   미래 시간 확보는 보장하지 않는다. 원래 문안이 이미 참이었다고 재해석하지 않는다.
3. intro·두 결과의 같은 약속까지 10잎×5언어를 함께 정렬한다. memory의 kept/broke
   독자는 선택한 계획의 유지/변경을 계속 회수한다. 후속 날짜 위험은 별도이며 비소유다.

## 파일 소유·고정 범위

- cjk_wrap_diagnosis: 선언 때 큐2 순번만, push 뒤
  `content/events/arc_midgame.json`, `content/events_en/arc_midgame.json`의 아래10잎만.
- phone_cn_author: `content/events_ja/arc_midgame.json`,
  `content/events_zh-CN/arc_midgame.json`, `content/events_zh-TW/arc_midgame.json`의
  같은10잎을 KO에서 직접 번역한다. `content/meta/full_game_localization.json`의
  current source/accepted30교정·현재checksum/새 correction batch만 소유한다.
  root+비저자 응답 전수 수용 승인 뒤 공식 export/check/import를 쓴다. 영어중역/
  간번변환0, 과거batch/census·수용개수·다른accepted/역사지문은 보존한다.
- root: 이 사양/큐마감/WORK_LOG/CLAUDE 현재행·private561 자료, 영향이 확인될 때만
  `content/meta/release_content_inventory.json`, `docs/CONTENT_RATING_INVENTORY.md` 지문.
- phone_independent_review: exact50잎·기존효과/flag/index/소비자·공식30영수증·
  원자료/비소유 보존을 읽기 전용 전수 검수한다. formal 보고/판정원장행0이다.

M16 `arc_34_routine_trap` 7잎: description, description_orthodox,
description_unorthodox, description_if_known.set_morning_routine,
choices[0].result_text, choices[1].text/result_text.
M18 `arc_year_one_half` 3잎: description, choices[1].text/result_text.

다른text·title·choice0text·조건/효과/flags/index/직업/금액/라우팅/deferred/시각·
저장schema·MainGame/StoryMode/FullStoryFlow/원seed·사용자 저장/설정·Human·공개demo/
arc_events.json·project/presets/BuildInfo·앱/원raw는 비소유다. 새scene/tier/자산0이다.

## 표적 검증·경계

- 기존 safety snapshot/file_record/run_command/write_json을 private561에서 재사용,
  실제558/560 app·559 W68/raw/runtime·공개/player/Human/원프로젝트와 비소유tracked를
  보호한다. 원자료를 바꾸거나 새 영구 runner/checker/이력 검사·등록을 만들지 않는다.
- 정확10 leaf-id만 locale별 공식 export→check→import --accept --replace-existing.
  root가 KO/EN20잎과 번역30잎을 읽고 비저자가 전수 확인한 뒤 수용한다. 각 locale
  응답/원target hash/accepted receipt/checksum을 결속한다. 신규coverage0이다.
- 기존 en_coverage/english_hangul/narrative_continuity/scene_audio_contract/
  speech_register·full localization inventory3언어·release inventory·demo scope/
  story localization·context/queue/diff를 실행한다. selector --list는 선택만 한다.
  실제 exit/elapsed/stdout/stderr를 남기고 변경30잎 invalid0·새실패0을 요구한다.
  기존JA invalid58·전체 INCOMPLETE/원어민OPEN·옛HOLD/FAIL은 소급 변경하지 않는다.
- 엔진/build/UI·저장편집·전체audit/240주·종료누수탐침·479/481·STATUS단독커밋0이다.
  문안source GO만 가능하며 559 원관측REWORK·560 패키지GO·새앱/5언어화면·WinLinux/
  사람/원어민/물리패드/청취·본편/출시 HOLD는 별개다. 자동 계약은 재미·깊이·문체/
  인간 품질 증거가 아니다. 다음은 원559 W68의 정상 월별 실제 앱 검수다.

## 실제 결과

선언9ba25c1824df48673bd4e6f105544a10398552a9/treea1435ea7b27f98807c8c6e176c8cc97cbd08a8f1 뒤 exact10잎×5언어만 수정했다.
실제 소득/근무 취소 약속을 계획표의 삭제·검토 기입으로 정렬했다. gameplay·다른
text·choice indices·효과/flags/소비자/저장/라우팅은 불변이다. KO 선택0 결과의
‘먼저 비우기로 정해 둔 시간이’ 한 구절은 root가 소유를 인수해 수리했다.

- 최초 check JA0/CN1(duration_hour), v2 JA0/CN1/TW1(entity)는 한국어 수식어를
  수량으로 읽은 실패다. 원raw/응답을 보존하고 검사기·번역의 숫자를 조작하지 않았다.
  v3 source manifest b847b101300bff7ff2ebad57391fd6cc5f1a8c93a5b7a1944394eb665f7d0c46,
  기존30번역 text는 exact이며 새source headers로 공식 check3/import3 actual0.
- accepted30 교정·현재checksum9814258378c008bfd3c0b2f302d6924c2851acfe624856e3e91b8de3fd0046f9,
  correction1행만 추가(310→311). 수용개수 JA13159/CN14696/TW14696·310 역사prefix·
  다른accepted/역사census는 exact다. 신규coverage0이며 세 locale INCOMPLETE/nativeOPEN이다.
- 표적13 actual0/실패0/stderr0, 변경locale10잎씩 invalid0. JA 기존invalid58,
  CN/TW0 그대로다. release inventory PASS여서 임의 지문/심의문서 수정0이다.
  static-results12372B/SHAda61ae1c36bd91b7a404da2070893e46e793452596e38fafcd4c28563081f593,
  author-after-final64635B/SHA2e390d9fb0f01bff3db240403704b9149946025d5418560a00dc2c75c08ea67b.
- root 전20 KO/EN·전30번역과 원장diff를 읽었고 phone_independent_review가
  비저자로 실제50잎/accepted30·33실행66원stream·최종metadata와 fresh보존을
  전수 대조해 source 정합·보존 한정 GO로 판정했다. 보호22그룹249entries·
  비소유tracked3338·엔진/templates35 exact, 큐2는 pre561 b20ed43 bytes exact다.
  최종 context PASS(boot30671)/queue PASS(active81,in_progress79)/diff PASS다.
- source 사실 정렬만 GO다. 559 실제 REWORK는 옛앱 관측으로 보존하며 새앱에서
  고쳐진 문안을 봤다는 뜻이 아니다. M18 native0·CJK5화면/WinLinux/인간/원어민/
  물리패드/청취·전체번역/본편/출시 HOLD. 다음은 원559 W68 정상 월별 검수다.
  엔진/UI/build/전체audit/240주/누수탐침/새checker/등록/formal보고/판정원장행/
  STATUS단독커밋0. 새규범0·모든 범위 지시는 일회성이다. 자동 계약은 재미·깊이·
  문체/인간 품질의 증거가 아니다.
