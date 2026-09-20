# Active Queue Spec: ORDER-284

> Canonical status and execution order are indexed in `docs/CODEX_QUEUE.md`.

#### [~] ORDER-284 [P0·전체 현지화] 타이틀 제3자 고지의 실제 동적 안내12개를 세 언어로 채운다

**[~] 2026-09-20 Codex 착수 — 아래19경로만 소유.** 부모 ORDER-157.
기준 `818eedf516cb33e92ba7b44006c2fe4c40066c44`.
설정·저장·대화기록의 확인한 literal 표면은 이미 사전에 있어 반복 저작하지 않는다.
읽기 전용 `post283-live-ui-scope.json`(16419B/SHA
9fc6ae2a114487a5a13582d43ebae90a677e7d803b2310a9157ced5f02e2ed0b)이
찾은 실제 StartMenu→설정→제3자 고지의 동적 chrome만 선택한다.

## 깊이 3문

1. 지우면: 타이틀의 고지 소개·탭·메타데이터 이름이 세 언어에서 영어 폴백한다.
2. 24주 상태: 안내 언어만 바꾸고 선택·재산·권리·의무·주차는 변경0이다.
3. 같은 자리 경쟁: 기존 lookup을 채울 뿐 새 시스템·탭·출시 언어 노출0이다.

## 정확한 대상과 계약

원본 `content/meta/third_party_notices.json`은 그대로 둔다.
surface의 intro/package_note, labels의 provider/copyright/license/source/
license_copy_required/attribution_required/voluntary_credit, sections engine/fonts/audio
각 title의 **12쌍×JA/CN/TW=36값**이다.
기존 surface.title·labels.license_terms 2쌍은 사전과 source ID/hash를 보존한다.
독립 provider는 실제 reader가 읽는 위 전체14 JSON 쌍만 검증한다.
실제 StartMenu::_notice_localized→LocaleManager.ui 소비를 근거로
기존 ui_unverified 신규12를 ui_notice_chrome으로 등록한다.
무관한 JSON쌍·법률본문·저작권본문·URL·파일명·자산명은 수용 대상으로 넓히지 않는다.

기존 static/context 역사 모집단·순서·해시 예외를 바꾸지 않는다.
provider 한 곳을 full collector, JA required/validation/extra 검사,
ZH source/validation/extra 검사에서 공유하며 임의 extra를 허용하지 않는다.
missing/extra/duplicate/non-string/section 변화와 실제14·신규12의 경계를
기존 full localization self-test에서 양성·음성으로 검증한다.
JA/CN/TW는 KO에서 각각 직접 저작하며 중역·문자변환0.
새 법률 판단·의무·보증·라이선스 번역이나 인증이 아니라 기존 안내의 현지화다.

## 파일 소유권

- tools/third_party_notice_ui.py: 정확 동적 고지 UI source provider.
- tools/full_game_localization.py, tools/ja_translation_audit.py,
  tools/zh_translation_audit.py: provider를 기존 소비자에 연결.
- tools/full_game_localization_self_test.py: 위 source/소비자 경계 반례.
- locale/ui_ja.json, locale/ui_zh-CN.json, locale/ui_zh-TW.json: 신규12키씩 append만.
- content/meta/full_game_localization.json: exact36 수용·1배치 append.
- docs/I18N_INFRASTRUCTURE.md: 동적 고지 UI와 법률본문 분리 계약을 소유.
- CLAUDE.md, docs/CODEX_QUEUE.md, docs/CODEX_QUEUE_L3_PENDING.md.
- docs/queue_active/ORDER-284.md, docs/queue_archive/ORDER-284.md.
- docs/WORK_LOG.md, docs/STATUS.md.
- docs/agent_review_decisions.json, docs/agent_reviews/ORDER-284.json.

old40067/b128/meta9·기존70판정·held72·공개121·KO/EN·런타임·사람원장·
project.godot·notice JSON/라이선스/출처원장·ja_translation_pipeline 비소유.
예전 source hash나 전체 게임 판정을 새 collector의 GO로 재사용하지 않는다.

## 검증과 판정

선정12·번역36 전수 비저자 대조. source-bound export/check/import를 locale별
실행하고 raw 최초실패를 보존한다. 기존40067 source/target와 UI/portable
역복원, 기존static2·공지JSON/법률파일·공개/인간 원형을 확인한다.
추가 provider/consumer 반례는 실제 실행하며, 기존 news-panel-locale-only의
고유12 체크리스트를 exact clean 후보에서 한 번 사용하고 종료 metadata6으로 닫는다.
새 helper는 standalone QA 프로그램이 아니라 기존 full self-test의 종속 모듈이다.
전체 audit·240주·엔진·화면·원어민·인간·물리패드 실행/관찰은 이 단위에 합산0.
일본어/중국어 strict 전체 완료, 공개 출고, 법률 인증이나 whole-product GO가 아니다.

규범 승격: I18N_INFRASTRUCTURE의 notice chrome/법률본문 경계.
12키 선정·파일소유·배치·검사 선택은 일회성이다.
자동 게이트는 도달 가능성과 계약 충족의 증거이지 재미·깊이·문체의 증거가 아니다.
