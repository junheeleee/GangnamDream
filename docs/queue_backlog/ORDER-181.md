# Active Queue Spec: ORDER-181

> Canonical status and execution order are indexed in `docs/CODEX_QUEUE.md`.

#### [~] ORDER-181 [P0·전체 현지화] 창업·정치·정선과 생활 전환을 옮긴다

**[~] 2026-09-08 Codex 착수 — 아래25 ID의 세 언어 text-only overlay,
원문 결속 검사·수용 기록·증거 문서만 소유한다.**
직전14,355번역(언어별4,785)·메타9·batch32와 공개 working baseline·
별도 배경 제품53493fe를 착수 직전 재확인해 보존한다. 사용자의 전체 게임 번역 지시를 이어간다.

## 깊이 3문

1. 창업·정치의 큰 선택과 정선에서 돌아온 밤도 다른 언어에서 같은 책임을 남겨야 한다.
2. 수령·계약·당선·검색·예약·금단 결심과 도달성 조건은 변경0이다.
3. 남은 사건·UI·소비자와 경쟁하므로25단위 한 배치에 한정한다.

## 배치 A — 생활 전환25 roots /178 leaf /7,630 KO자

전부 `content/events/life_events.json`의 다음25개다. 아래는 KO 상대순서다.

- `politics_005`
- `gambling_006`
- `military_007`
- `health_008`
- `health_019`
- `comedy_021`
- `politics_038`
- `gambling_039`
- `comedy_043`
- `startup_opportunity`
- `startup_acquisition_offer`
- `political_recruitment`
- `political_election_victory`
- `final_stretch_check`
- `chapter_break_turn15`
- `chapter_break_turn30`
- `chapter_break_turn45`
- `are_you_happy`
- `jeongseon_big_loss_bus`
- `jeongseon_big_win_urge`
- `jeongseon_addiction_notice`
- `comedy_lunch_menu`
- `comedy_elevator_awkward`
- `comedy_office_printer`
- `comedy_group_chat`

source aggregate
`8e5b91bf1d90fe8fb4e3f1f92cfd3ddd92fc3cd508e6b7a68e3f1b38c4ca29a7`.
제목25+본문25+64선택/결과128=178. known/memory/reader/foreshadow/밖name0.
전부 shipping·protected=false·builtin_overlay_static_only다.
대상3언어 target/accepted0과 직전180 교집합0을 선언 직전 확인한다.
life_events의 comedy_wrong_floor/comedy_autocorrect는 다음 범위에 남긴다.

명시 foreground/bridge/fallback/context0, 정적 storymap closure 교집합0,
autoloads/systems/scenes의 대상 literal0, 직접/지연 후속의 유입/비어 있지
않은 유출0이다. 이는 패키지 번역 범위이지 전체 비도달·플레이 GO가 아니다.
military_007은 min_turn11뿐이고 has_job/commute/context가 없으나 마지막
직장 comedy4종은 has_job:true다. 정선3 flag는 실제 게임 후 소비되지만
현재 버스/카지노 장소를 이번 번역이 새로 보장하지 않는다.
startup_founded/exit·gambling_tempted·happy3·final_sprint3·금단 결심의
밖 callback·엔딩·경마 멘토 소비자는 번역 분모에 추가하지 않는다.

## 파일 소유권

각 `content/events_<ja|zh-CN|zh-TW>/life_events.json`에 위25행만 추가한다.
기존 값·raw row·행 상대순서·source/target hash를 유지하고 새25행 내부의
KO 상대순서를 따른다. 기존 배열 전체 재정렬0, gameplay key 복사0.
KO 직접 저작과 다른 작성자/ROOT의 전수 L2. 영어 중역·간번 자동변환0.
문단·토큰·수량·인물/사실 경계를 보존한다.

ROOT는 full_game_localization.py·full_game_localization_self_test.py·
zh_translation_audit.py·audit_scope.json, content/meta/full_game_localization.json,
이 사양·CODEX_QUEUE·CODEX_QUEUE_L3_PENDING·CLAUDE·WORK_LOG·생성STATUS·
전체 현지화 backlog를 소유한다. 필요하면 완료178 WORK_LOG절만 기존9/7
현지화 history 앞으로 원문 이동하고 기존 내용·끝 개행도 보존한다.
실제 번역에서 재현한 검사 오탐만 좁은 문맥과 정상/변조 짝으로 수리한다.
KO/EN·runtime·save·routing·human_gates·life_events2·catalog/endings·공개·
폰트·배포 비소유다. 수용 후 같은 활성 이어보기로 옮기되 [~]·L3 OPEN 유지.

## 원문 사실·부채 경계

- 사기 광고 차단 뒤 실제4만원 반환은 원문 사실이나 앞 입금 장면이 없다.
  창업의 지분20%·300만원 실제 계약/차감과 인수20%·32억원 서명/입금도
  보존한다. 30억원 이스터에그의 엔딩 라우팅은 이번 번역에서 변경0이다.
- 정치 사건은 실제 보좌진 임명, 후속은 공천장/선거사무소 계약까지다.
  political_election_victory ID를 따라 산문에 당선을 보충하지 않는다.
  정치 flag를 읽는 GameState의 political_fix 엔딩과 외부 callback은 당선으로
  읽으므로 생산자·소비자 불일치를 별도 원문 부채로 남긴다. 보좌진3년과
  min_turn120/앞선72 조건의 기간도 번역에서 새로 보증하지 않는다.
- military_007의 고정33세·2년 전 예비군 종료와 취업 조건 없는 회의/반차는
  별도 확인점이다. 실제 반차 신청과 원격 교육 자격 검색은 다르다.
  건강019의5만원 의사 상담 예약을 새 검사 결과로, 건강008의 약국 수면제 검색을
  약 구매·복용으로 키우지 않는다. 9:12회의·금요일 오전 마감은 보존한다.
- 이미 닫은 영상의 끝까지 보기 선택, 버스가 이미 움직이는 도입 뒤 출발
  선택은 원문 재진입/압축으로 남긴다. 썸네일30대·280만조회·1.2만댓글·
  6분12초/4분30초·보험 영업은 그대로 옮긴다.
- final_stretch의38세까지1년 미만·5년 전과 min_turn200~216, chapter45의
  60개월 중15개월 남음과5년 경험은 별도 기간 부채다. chapter15의 친구
  청약 당첨과2년 뒤 입주는 지금 집 소유가 아니다.147좋아요는 보존한다.
- 정선 큰 수익 뒤 도박 오류는 인물 머릿속 설명이지 확률 보증이 아니다.
  한 달 중단은 결심이지 완주가 아니며 실제 round/손익 flag의 수치 조건을
  원문에 없는 설명으로 추가하지 않는다.
- 직장 단톡200전체/198회신/199번째 주인공 답·팀장 이모티콘은 실제 원문이다.
  프린터의 대리 직급·30분+10분, 점심20분/상상10분/식사5분 또는5분 지각,
  기능 괄호3 leaf와 창업 자금 괄호1 leaf, 총4 leaf는 임의 정정·삭제하지 않는다.

## 검증

원문 manifest
`edf845a7164b8fedc9ec027be7a7edc381a3dcdf67ff58c2858d44a3237b64b8`.
초기source3 보존, 최종source/response/receipt3쌍과534문구 독립 KO 대조.
named full-game-localization-overlays를 --list로 확인 후 실행, EN·diff와
portable 전량 source/hash를 검사한다. 전체 INCOMPLETE·full/main/product HOLD,
L3/원어민/화면 OPEN·출시 M01~M06 BUILD2026.08.31.1 사용자 GO 유지.

이 범위·배치·증거 절차는 일회성이다. 지속 규칙은 I18N_INFRASTRUCTURE와
언어별 용어집이 소유하며 새 서사·제품·출시 규칙을 만들지 않는다.

## 번역 결과 — L1/L2 수용·L3 OPEN

- 선언 `e26bb60c3ae91dd448b7e477c81cdf6f45df2970` 뒤25 roots/178 leaf씩
  KO 직접 저작하고 세 언어534문구를 다른 작성자 또는 ROOT가 전수 대조했다.
  JA의 청약 선정에 없던 추첨 방식과 커피 한 잔을 정밀화하고 '한마디씩'도
  살렸다. TW 점심 제목은 미결정 진행 상황을 명료화했다. CN 필수/권고0.
  변경 JA3/TW1은 재대조·역치환 시 이전 파일 전체 SHA 일치를 확인했다.
- 초기179행 source3은 저작 전 target=null과 같은 원문178을 보존한다.
  최종 source/response check·import --accept3개 PASS·changed_files0.
  기존 private 증거는 덮지 않고 작성된 target만 수용했다.
- 최종178-record aggregate JA
  `3fce54a6847e0597423ded6e4e59380aaee1d76b1925eef0bb99c3cf67f47c3c`,
  CN `3e3b1e942b454a1abf2d17ea8617caeded05a91425e9ceb275515d5db222f029`,
  TW `833ded74237d783eac2502e24cab7c5516a84cd81b1e80d9ba8641582c38bdb4`.
  신규534·누적14,889(언어별4,963), 사건503종3,895/locale다.
  이전14,355/meta9·batch32·기존104행761문구의 값·raw row·상대순서를 보존했다.
  새25행 내부는 KO 상대순서이며 life_events2 전체는 변경0이다.
- 선언 메모의 '영상30초'를 실제 원문 '30대'로 정정했다. 영상 길이는6분12초,
  성공담 구간은4분30초다. 기능 괄호3+창업 자금1의 총4 leaf도 명시했다.
  건강019는 이미 검진 결과가 있는 상태의5만원 의사 상담 예약으로 정확히 적었다.
  번역은 원문을 따랐으며 오기대로30초나 새 검사 완료를 추가하지 않았다.
- JA의 한 달 결심/예상3문맥을 native time ordered stream에 결속해 실제
  오탐2를 닫았다. 정상4/대표변조21 독립 PASS, full self176=기존174+신규2.
  일·년 단위/부호/반복 개수/완주·행동 긍정형 변경을 면제하지 않는다.
- ZH는 조회수280만·영상372초/270초·30대 반복·메시지200/198·199번째를
  실제 원문 수량/단위와 불일치 증인에 결속했다. 해당 유튜버 제목의 YouTube와
  현수막 명사 오탐도 수리했다. 전역 숫자/영어 허용·event ID 면제0이다.
  독립 검토의 인명 조사 회귀와1메시지 수량 차용2범위는 별도 종결했다.
  현수막만 제외해 현수랑/에게서/와의 기존 이름 보호를 유지하고,
  단톡의 한 공지는9시 팀장 공지 문맥에만 결속한다.
  ZH self3427=기존3363+작성56+종결8. 자동 수량 검사는 전 언어 의미 인증이 아니다.
- 완료178절1,178bytes만 기존 history27,928bytes 앞으로 원문 이동했다.
  새29,106bytes SHA `ca62eff9a294cb0c6d5cdfa82d5ccd2521761f5fb8e67c60e0c6f8e6f578c669`,
  기존 내용·끝 LF2를 유지한다. 검수행은 같은 활성 이어보기로만 이동한다.
- 실제4만원 반환·300만원/20% 창업 계약·32억원 서명/입금과 공천장/선거사무소
  계약을 보존한다. 정치 flag의 밖 당선 회수, 기간/주거·영상/버스 압축은
  원문 확인점으로 남기고 한 달 중단 결심을 완주로 바꾸지 않았다.
  KO/EN·runtime·공개·fonts·save·human_gates 변경0, 원본 checkout 쓰기0.
  full/main/product HOLD·전체 INCOMPLETE·L3/원어민/화면 OPEN·출시 데모 GO 유지.

- portable checksum `0b720099848b9b945efc7886e2562ac1ef0def4ecd752203c45769610caa495a`.

## 최종 표적 검사 증거

실제 named12 PASS(scope52·full self176·JA69·ZH3427·공개14/100/121),
EN1813/1813·엔딩35/35·감사 ERROR0/WARNING0을 확인했다.
수용14,889문구 전량 source/target hash와 L1 오류0, 기존 보존·교환 영수증·
이력 원문 이동도 독립 인수로 대조했다. 중국어 JP-first 폰트 차단은 남아 있다.
이는 회귀 증거이며 실제 플레이·원어민 GO가 아니다.
실제 stdout `order181-final-checks.log` 4,225bytes SHA
`1605d96880fab36fe124cde161bc96612968728e93f6de000859fdd44d2488a9`를
기존 증거와 분리 보존했다. 마지막 문서 추가 뒤 context·queue·diff를 재확인한다.
