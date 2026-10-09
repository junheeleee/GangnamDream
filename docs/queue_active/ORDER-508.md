# ORDER-508 — 중국어 행동 미리보기·추천 UI33키

#### [~] ORDER-508 [전체 현지화] CN/TW 기존 UI66값 — 2026-10-09

착수 — 만지는 파일: locale/ui_zh-CN.json·ui_zh-TW.json 신규33키씩,
content/meta/full_game_localization.json 해당66영수증·배치2. 운영 파일은
큐/L3·본 사양/완료archive·WORK_LOG·CLAUDE 마지막 갱신·생성STATUS만.
게임원문·조건·수치·runtime/경제/저장·기존 번역/JA·도구는 비소유다.

## 판정 단위 / 정확한 두 배치

- 지우면: 행동 전 위험·AP·시간/능력 변화와 상황별 추천이 영어로 남는다.
- 독자: MainGame._ap_action_preview → AP 카드, _recommend_action → 상황별 안내다.
- 경쟁: 행동/추천 기능은 그대로 두고 기존 미번역 표면만 채운다.

기준Git2746b64f6e107ef9cf7325b03a09bb1b25858586,
source manifest f971c7193ba3a68299e166f2734f507f577001bc1ecc83cc940551abd038fb85.
현재 collector MainGame.gd13826~13878 정적 미존재17키와11182~11245 미존재16키.
모두 CN/TW동시미존재·JA존재·protected=false·builtin_overlay_static_only이며
private leaf ID배열과 공식 source batch에 exact 선택을 결속한다.

첫17은 행동의 위험/비용/후속 시간, 두 번째16은 취업·휴식·주거·투자·후반 추천.
숫자·부호·범위·원화·토큰·관계 거리·선택 후 비용·최대4주·1~3주 인과를 보존한다.
전세/빌라는 기존 지역 용어, 상철은 승인 로마자, 30억은30亿/億韩元/韓元이다.
원문 조언을 실제 보장이나 새 조건으로 강화하지 않는다. 원문 결함 발견 시 별도 범위다.

## 실행 / 증거 경계

선언commit/push 후 공식export/check/import17+16씩. CN/TW KO직접 독립 저자는
private 지역response 각2파일만 소유. root가 원header/SHA4·66source/target을 원장에
연결하고 비저자가 KO33/실제독자/66값·영수증·기존4파일raw·actual Git을 전수 대조한다.
기존 EN/Hangul·JA UI·ZH·i18n·multilingual·공개/legacy demo 영향8검사와
기존 ui_translation_append만. 전체audit/240주·새검사/이력/계측/재사용도구·형식보고0.
project/사용자저장/공개M01~M06/shipping language/과거인간판정 불변.
스킬의 선선언·독립저작/비저자·원장·표적검증 적용. 새규범0/절차일회성.
실제폭/입력/원어민/물리패드 OPEN·전체번역 INCOMPLETE·출시HOLD다.
