# Active Queue Spec: ORDER-376

#### [~] ORDER-376 — 편의점 응대·배달 중국어 200문구

**[~] 2026-09-28 착수 — 만지는 파일: `locale/ui_zh-CN.json`, `locale/ui_zh-TW.json`, `content/meta/full_game_localization.json`의 신규 append, 큐·작업/독립 검수 기록 및 CLAUDE 현재상태.** 부모157 및 검수 효율화 위임에 따른 기존 내부/legacy 소비자 번역이다. 게임·수집기·공개데모 코드는 비소유다.

## 범위·깊이·소유

- 현재 `scenes/ArubaGame.gd`의 손님8유형/응답18개 51키, 배달6곳 이름·층/시간12키, 안내·긴급도·템플릿·결과·CTA37키: 한국어100키×간체/번체=200값, 20단위(손님8+배달6+공통6).
- 모두 실제 collector leaf, `builtin_overlay_static_only`, public 보호키 아님, 기존 양지역 accepted와 교집합0. 조건식 제목 `배달 루트 설정`·`비 오는 저녁 배달`은 collector leaf가 없어 제외한다. 이 두 영어 폴백은 잔여로 남기며 수집기 변경이나 전체화면 완역을 주장하지 않는다.
- CARDS 시나리오, 미도달 fallback, 양의 건강결과는 제외. 기존 `보통`·`완료`, KO/EN/JA, 모든 기존 번역/수용/사람 판정, 공개제품, 게임·저장·폰트 바이트를 보존한다.
- 깊이1: 빠지면 손님 말·응답·배달 보상을 영어로 읽어야 한다. `_loc`/`LocaleManager.ui`/`ui_format`이 실제 소비한다.
- 깊이2: 새 선택·상태·서사 결과를 추가하지 않는다. 응대 손익과 비 할증·추가 건강비용의 사실을 보존한다.
- 깊이3: 제한된 응대시간·배달시간 안에서 선택지가 경쟁한다. 번역이 특정 선택을 정답으로 설명하거나 비용을 숨기지 않는다.
- root: KO→TW 직접초안, 공식export/check/import·사전/원장 단일작성, 실제 표적실행 및 마감.
- compat357: KO→CN 직접초안 private 파일만. 번체 기계변환 금지.
- screen_path_probe: 선정 봉인 및 private 실제화면 helper만. 제품/번역 비소유.
- r3_route_probe: 비저자200값 전수 의미검수·스스로 고른 화면 표본·최종 work_unit 판정. 원어민/인간/물리 관측과 구별한다.

## 표적 증거와 효율

- target 편집 전 exact100 source export, 공식check/import 및375의 증분 header 방식 사용. 기존사전1181키씩/수용40534/b144와 원장 prefix를 정확 보존한다. UI2+원장3파일을 같은 제품커밋에 넣는다.
- 도구가 안 바뀌므로 새self147·역사312·1955/689·전체240주를 반복하지 않는다. 현행 append admission, 영향목록, 해당 언어/consumer·문맥/큐/차이 검사를 한 번 묶어 실행한다. 실패 원본은 보존하고 원인에 해당하는 검사만 재실행한다.
- 격리 pre-autoload1280×800 실제 Label/Button에서 양지역100키·placeholder/돈/시간·지역글꼴/glyph/경계를 검증한다. 손님8/응답18/timeout/결과/맑음·비 배달의 준비된 상태를 사용한다. 자연 AP 진입·전체플레이·raw입력·실시간 timeout·물리 패드로 부르지 않는다. 새 런타임 결함은 별도 선언 전 수정하지 않는다.
- 기존 입력/게임 결과는 불변 runtime 영향 연결이며 재실행으로 세지 않는다. 독립 GO는 번역200값 work_unit만, 본편/새package HOLD·원어민/인간/물리 OPEN·출시언어/외부상태 변경0.
- 이번 모집단·소유·검증 계획은 일회성. 기존 WORK_UNIT/I18N 정본을 쓰며 규범 승격0. 알려진 liveness Python-launcher 오탐은 비소유·미재실행으로 남긴다.
