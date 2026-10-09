# ORDER-502 — 중국어 인연 에필로그·다음 삶 힌트16키

#### [x] ORDER-502 [전체 현지화] CN/TW 기존 엔딩 UI32값 — 2026-10-09

착수 — 만지는 파일: locale/ui_zh-CN.json·ui_zh-TW.json 신규16키씩,
content/meta/full_game_localization.json 해당32영수증·배치1. 운영 파일은
큐/L3 이어보기·본 사양/완료archive·WORK_LOG·CLAUDE 마지막 갱신·생성STATUS만.
게임원문·조건·효과·엔딩라우팅·runtime·저장·기존 번역·JA·도구는 비소유다.

## 판정 단위 / 깊이3문

- 지우면: 아버지·지연의 이후와 다시 시작할 가능성을 중국어 대신 영어로 읽는다.
- 독자: MainGame._ending_cast_epilogue의 아버지8·지연5 정적 호출 →
  _ending_epilogue_card/_wrap_label, _ending_next_run_hints의 NG+3 →
  최대3개 _wrap_label이다. 실제 소비자는 21133/21175에서 호출된다.
- 경쟁: 엔딩 선택·후일담을 새로 쓰지 않는다. 이전500 여정요약과 별개인 기존
  인물 후일담/힌트16키의 폴백만 채운다. 새로운 게임상태 변화는 없다.

## 정확 선택 — 공식 한 배치16

기준 source manifest b7d4a4a0418151a18274c73e702d1e149a91c7a11611bece742b3e143acbd2ea.
scenes/MainGame.gd 22107·22109·22111·22114·22116·22118·22120·22122의
아버지8, 22135·22137·22139·22141·22143의 지연5,
22322·22324·22326의 다음 삶3 한국어 legacy키만. 모두 CN/TW미존재·JA존재·
public-demo protected=false·builtin_overlay_static_only임을 현재 collector로 확인했다.

아버지 생존3/사망3/미연락2를 섞지 않는다. 월2통화·1시간 지각·창원1방문·
5년/한 번도 못감·거래와 통장숫자·빈 병실을 보존한다. 지연 앞2문구만
romance_started 분기이고 나머지는 존중/상처/거리다. 새로운 연애·이별을
발명하지 않는다. NG+는 rc=0·각 경험조건·최대3노출이고 확정 보상이 아니다.
아버지 전화는 먼저 받기이지 먼저 걸기가 아니다. 창원은 昌原,
Han Jiyeon·Im Sangchul·Daeun 등 정본 이름을 쓰며 미승인 한자를 만들지 않는다.

## 실행 / 검증 / 증거 경계

선언commit/push 후 공식 export/check/import16씩. CN/TW저자는 KO 직접
private response 각각1파일만 소유하며 서로 변환하지 않는다. root는 원공식
receipt header/SHA2·source/target32를 기존 원장에 결속하고, 비저자는 원문16/
실제소비자16/번역32·원영수증·기존4파일 raw 역상·actual Git source를 전수 검수한다.
기존 ui_translation_append와 EN/Hangul·JA UI·ZH·i18n·multilingual·공개/legacy
demo 영향 검사만. 전체 local audit/240주·새 검사/이력/계측/재사용 도구·형식보고0.

Mac잠금으로 실제폭/입력 미관찰이며 원어민·물리패드 OPEN·본편출시 HOLD다.
project.godot·사용자 저장·shipping language·공개M01~M06·역사 인간판정 불변.
개발 스킬의 현지화 프로필·선선언·독립 지역 저작·비저자 검수·표적검사를 적용한다.
새규범0·위 절차/배치 범위는 일회성이다. 자동PASS는 재미·원어민/사람GO가 아니다.

## 수용 결과 — 2026-10-09 / 정적 소비자 번역 한정 GO

선언b1e65023 → 제품010ece9ff19ce201f281d76a745d21cf66e7b931 main commit/push.
KO16/실제소비자16/CN·TW32값을 직접 지역별 저작하고 비저자 전수 대조했다.
월2통화 검사 오탐만 별도504에서 수리한 뒤 정상 문안을 공식 수용했다.
공식 export/check/import16×2·원header/SHA2·current source/target32와 기존
4파일 raw 역상 PASS. accepted42293→42325/batches297→298/UI2030→2046씩,
JA3055 불변, CN/TW legacy1805→1821/2952/context29/29/dynamic150/701다.
원영수증 CN a0351054f8a99afe5ca249529553fb7aa39fdd0e3bacd882406bcce9c9890f94,
TW 0d509561a1239cf1dee8c923691566fc473cca6cb7f4a20ec51e1d8a66c4f32f다.

비저자 phone_independent_review actual Git current_proof(base fedae9d1→제품
010ece9)는 제품전이1·JA0/CN16/TW16·32receipt/배치1·선언b1e65023/current
manifest b7d4 일치GO·blocking0이다. 중간504 tool/ops를 UI전이에 섞지 않았다.
HEAD 제품3파일+생성STATUS5줄만·clean/origin동기다. EN/Hangul·JA UI·ZH·i18n·
multilingual·공개storydemo·legacy demo 표적8검사 및 context/queue/diff PASS.

기존 번역/JA/원장 metadata·게임원문/엔딩동작/저장/project·공개M01~M06·
shipping language·과거 인간판정 불변. 새규범0/절차 일회성이다. 개발 스킬의
선선언·독립 지역 저작/비저자 검수·기존 원장·표적 검증을 적용했다.
현재 전체 INCOMPLETE/CI진행 중·실제화면/원어민/물리패드 OPEN·출시 HOLD다.
다음은 발견된 기존 일본어4오역과 원장 설명의30억 단위 오타를 별도503으로 다룬다.
