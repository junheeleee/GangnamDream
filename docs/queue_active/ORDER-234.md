# Active Queue Spec: ORDER-234

> Canonical status and execution order are indexed in `docs/CODEX_QUEUE.md`.

#### [~] ORDER-234 [전체 현지화] 설정11단위·UI20키 번역

**[~] 2026-09-10 착수 — 아래 파일만 소유한다.** 사용자 전체 번역·개발 위임과
ORDER-157을 따른다. clean main `ca41a70b9686db06f4b2a759d8ea42c804c5f370` / tree `6c7075ebef8691fbb33a80c47792bfdaa4659261` 기준이다.
직전 갤러리81과 그 독립 GO를 이번60 검수에 합산하지 않는다.

## 깊이 3문·실측 배치 예외

1. 없으면 무엇이 빠지는가? 실제 시작 메뉴 설정과 조건부 모드 관리의 중국어 안내가 영어로 남는다.
2. 바뀌는 미래 상태는? 텍스트만 바뀐다. 음량/화면/색각/진동/모드 순서 및 저장값 변화0이다.
3. 무엇과 경쟁하는가? 화면 모드와 접근성·모드 적용 시점을 명료하게 구분하도록 옮긴다.

실물은 한 설정 표면의11판정단위·20문구다. WORK_UNIT의15~25는 첫 실행 재조정 대상이며,
선택지나 모드 종류를 억지로 쪼개15를 채우지 않는다. 이 소형 표면11의 일회성 예외를 채택한다.
ROOT는20 KO/JA값, 사전조사 및 StartMenu2240–2645/2780–3135와
MainGame19932–20090의 실제 공유소비자를 직접 읽었다. sourceKO/EN는변경하지 않는다.

사전조사32524B/SHA20559d9e78484c247ebe1feffdc51f9fd3a78e8cc17f4773ede2666a6e46d30e.
source records SHAe6e5510b841a2e2c48f2db291d0f20da1c6ad24abc1f7edd40e43b55a0ce0c23.
20 sourceleaf/locale, JA기존20·CN/TW각20 null, context/printf/LF/name0, 보호/기수용0.

## 정확한11단위·20키

1. BGM 배경음량: BGM
2. 화면 모드와 세 선택지: 화면 모드 / 창모드 / 테두리 없음 / 전체화면
3. 창 해상도: 창 해상도
4. 동작 감소 설명: 카메라·초상·날씨 움직임을 최소화합니다.
5. 진동 사용 여부: 진동
6. 색각 접근성 제목: 색각 접근성
7. 모드 관리 진입과 설명: 모드 관리 / 데이터 모드의 활성화와 로드 순서를 변경합니다.
8. 모드 적용 시점 안내: 변경은 다음 실행부터 적용됩니다. 위에 있는 모드가 먼저 로드됩니다.
9. 로드 순서 앞뒤 이동: 먼저 로드 / 나중에 로드
10. 네 모드 종류의 구분: 이미지·오디오 교체 / 커스텀 이벤트 / 밸런스 프리셋 / 색 테마
11. 제3자 고지 진입과 설명: 제3자 고지 / 게임 엔진·서체·음원의 출처와 라이선스를 확인합니다.

## 파일 소유·병렬 분담

- Plato: locale/ui_ja.json 위20 기존값 KO 직접 검수·필요 정밀화.
- Rawls: locale/ui_zh-CN.json 신규20 KO 직접 저작.
- Poincare: locale/ui_zh-TW.json 신규20 KO 직접 저작; 간체 자동 변환0.
- 비저자: Rawls→JA / Poincare→CN / Plato→TW 각20 전량. ROOT 통합.
- ROOT: content/meta/full_game_localization.json에60/batch1만 추가. 기존38095/b93/meta9와
  선택 밖 UI key/value/order/raw를 역제거 보존한다. 기존 JA 탭5행도 비선택 원형이다.
- 조건부 코드4: tools/full_game_localization.py, tools/full_game_localization_self_test.py,
  tools/ja_translation_pipeline.py, tools/zh_translation_audit.py. 첫20 L1의 실제 오탐에만
  actual/다른 정상/유효 변조/source-OFF와 비저자 증거를 먼저 봉인해 국소 수리한다.
  전역 면제·전체 leaf 완화·기대 변경0. 유효한 지역 표기 정밀화와 검사 오탐을 구분한다.
- 운영: CLAUDE.md, docs/CODEX_QUEUE.md, docs/CODEX_QUEUE_L3_PENDING.md,
  docs/WORK_LOG.md, docs/STATUS.md, docs/queue_backlog/FULL_GAME_LOCALIZATION.md,
  이 사양, docs/queue_archive/ORDER-234_L1_L2_RESULTS.md, tools/audit_scope.json,
  docs/agent_review_decisions.json, docs/agent_reviews/ORDER-234.json.
  사적 helper/원문/receipt/검수/QA는 .git/full-game-localization/order234-*.
- 감사는 기존 full-game-localization-overlays 명시 차선 owned_paths에 사양/보고만 추가한다.
  UI3 등록 재사용, 자동 paths/Godot 선택 규칙 변경0.

StartMenu/MainGame/LocaleManager/ModLoader/DisplayManager/AudioManager/SaveManager·gameplay·
설정·사용자 모드·세이브·SHIPPING_LANGUAGES·폰트·project.godot·공개 데모·인간 원장은 비소유다.
같은 화면의 보호6키(닫기/동작 감소/설정/언어/진동 강도/효과음)와 공개UI121, 직전갤러리/저장
번역 및 모든 선택 밖 값을 보존한다. 실제 설정·언어 전환·소리·진동·모드 활성화 실행0이다.

## 의미·도달 경계

- _open_settings_popup→volume builder→display builder로 실제 연결된다.
  화면모드/해상도5키는 non-web, 모드9키는 발견한 모드가 있을 때, 나머지6키는 공통이다.
  MainGame 공유7 호출은 같은 의미를 유지한다. 이것은 소스 소비자 확인이며 실플레이 도달 증거가 아니다.
- 창모드/테두리 없음/전체화면 구분과 창모드일 때만 해상도 선택을 보존한다.
  동작을 최소화한다는 문장을 모든 애니메이션 완전 정지로 증폭하지 않는다.
- 모드는 다음 실행부터 적용, 위쪽부터 먼저 로드라는 방향을 유지한다.
  모드명/버전/IDs/사용자 파일·내용은 읽거나 수정하지 않는다.
- BGM은 원문 약어이며 배경음량 label이다. MainGame의 raw BGM/SFX와 숫자 %d%%는 별도다.
  raw 소비자 수리나 숫자 포맷 번역으로 합산하지 않는다.
- 색각 접근성 제목만 번역한다. built-in/community 테마명은 KO/EN 직결 소비자여서 별도 미지원이며
  도덕 점수를 노출하거나 이번20으로 설정 전체 완료를 주장하지 않는다.
- 제3자 고지는 진입/제목fallback과 안내만이다. 동적 법적 고지/라이선스 전문·내용·효력은 비소유다.
- 언어의 native display name·선택 가능 언어와 현재 패키지/서체는 그대로다.
  공개GO/인간45OPEN·본편HOLD 유지. 실제 화면·원어민·동적 UI는 미관찰이다.

## 검증·마감

1. 선언·동기화 뒤 공식 exact leaf-ids initial20×3. JA기존20/null40·기존원형 봉인.
2. 직접 저작·첫 L1 각1회, 모든 실패 원형 보존·국소 수정 후영향검사. 비저자60 전량 대조.
3. clean C1 final export/check/import3쌍은 locale명시·changed_files0.
   response 생성 전에 source/current/3L2자체digest/fullproofSHA/언어집합3/수량60을 결속한다.
4. 새60을 추가하고 기존38095/b93/meta9 raw 역복원·보호원형 확인.
5. 전체수용 hash/L1 1회와 명시12 차선1회를 전후 입력 봉인한다. context/queue/diff표적검사.
   실패면원형과 영향 재실행을 기록하며 Godot/full/240실행0이다.
6. source-like 문서까지 exact C2 뒤 비저자 work_unit234 최종판정. 이후metadatawrapper만 추가.
   기존WORK37253B/SHA4aa9d663b47bce51bffa32e572e10141ba38bff948b66e28ff1d58e213820e10/EOF2는 신규항목을 역제거해 확인한다.
   이력이동0, STATUS clean생성·검사, main/번역브랜치 비파괴동기화.

성공 때만38155(JA12717/CN·TW12719)/b94/meta9다.60=기존JA20검수+CN/TW신규40이며
60개 모두 신규 저작이라 하지 않는다. 자동 검사는 회귀일 뿐 재미·문체·원어민 승인과 다르다.
승격: 지속 규칙은 기존 I18N/WORK_UNIT 정본. 이번11단위 예외·키/소유/마감은 일회성.
