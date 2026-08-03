# Active Queue Spec: ORDER-73

> Canonical status and execution order are indexed in `docs/CODEX_QUEUE.md`.

#### [x] ORDER-73 [P0·패키징] 실제 버전·세이브·제3자 고지를 하나로 묶는다

> 착수 — 플레이어는 시작 화면에서 데모/정식판/V2를 구분하고, 저장 목록에서
> 다른 빌드 출처와 호환 여부를 읽으며, 설정에서 실제 포함된 엔진·서체·오디오
> 고지를 열 수 있게 한다. 빌드 ID는 호환 키가 아니라 테스트 산출물 진단값이다.
>
> 배치 A 파일: `systems/BuildInfo.gd`, `autoloads/SaveManager.gd`,
> `scenes/StartMenu.gd`, `tools/build.sh`, `tools/build_identity_audit.py`,
> `tools/ManualSaveCheck.gd`, `tools/PlaytestFlavorCheck.gd`,
> `tools/First30SecondsCheck.gd`.
>
> 배치 B 파일: `assets/third_party/THIRD_PARTY_COMPONENTS.json`,
> `assets/third_party/GODOT_ENGINE_LICENSE.txt`,
> `assets/third_party/GODOT_ENGINE_COPYRIGHT.txt`,
> `content/meta/third_party_notices.json`, `tools/third_party_notice_audit.py`,
> `assets/audio/AUDIO_SOURCE_MANIFEST.json`,
> `assets/audio/AUDIO_SOURCE_LEDGER.md`,
> `assets/audio/AUDIO_THIRD_PARTY_NOTICES.md`,
> `tools/build_sample_audio_assets.py`, `tools/audio_source_audit.py`,
> `export_presets.cfg`,
> `assets/fonts/OFL-NotoColorEmoji.txt`, `assets/fonts/OFL-Pretendard.txt`,
> `assets/fonts/FONT_LICENSE_LEDGER.md`,
> `scenes/StartMenu.gd`, `tools/ScreenshotQA.gd`, `tools/audit.sh`,
> `tools/audit_scope.json`, `docs/QA_CHECKLIST.md`, `docs/BUILD_PIPELINE.md`,
> `docs/MASTER_RELEASE_AUDIT.md`,
> `content/meta/release_content_inventory.json`,
> `docs/CONTENT_RATING_INVENTORY.md`, `docs/STATUS.md`.
>
> 전체 감사 범위 확장 (2026-08-03) — 추가로 만지는 파일:
> `autoloads/UIStyle.gd`. 신규 고지 화면이 화면별 `StyleBox`·테마 오버라이드
> 래칫을 늘리는 것을 전체 감사에서 검출했다. 새 기준선을 올리지 않고 기존 전역
> 스타일 소유자를 재사용해 같은 화면을 구성한다. 색·레이아웃·기능 계약은
> 바꾸지 않는다.
>
> 전체 감사 범위 확장 (2026-08-03) — 추가로 만지는 파일:
> `locale/ui_ja.json`. 새 시작 화면의 저장 호환·제3자 고지 `_tr` 키 18개를
> 비출시 일본어 UI 사전에도 동일 키로 등록해 strict UI 패리티를 복구한다.
> 일본어 본문·출시 언어 노출은 열지 않는다.
>
> 종료 파일: `CLAUDE.md`, `docs/CODEX_QUEUE.md`, `docs/WORK_LOG.md`,
> `docs/queue_archive/ORDER-73.md`. `project.godot`, 서사·밸런스·게임 콘텐츠는
> 이 작업에서 만지지 않는다.

## 깊이 3문

1. 지우면 화면에는 버전이 있어도 세이브와 테스트 증거가 어느 빌드인지 알 수 없고,
   라이선스 고지는 패키지 파일을 직접 열어야만 보인다.
2. 다른 빌드의 세이브를 읽을 때 호환/경고 판단이 달라진다.
3. 개발·플레이테스트·retail flavor와 세이브 호환 정책이 같은 식별자를 경쟁한다.

## 배치 A — 낡은 진단 폐기와 메타 배선

- 기존 `BuildInfo.gd`, 시작 화면 버전, 엔딩 크레딧을 재사용하고 ‘없음’ 전제를
  폐기한다. 게임 버전·빌드 ID·flavor를 세이브 메타와 진단 표면에 연결한다.
- artifact flavor와 현재 run mode를 분리한다. full↔legacy demo 저장 이월은
  유지하고 V2 playtest namespace만 격리한다. 미래 save schema는 상태 적용 전에
  거부하며, 빌드 ID 차이는 경고만 하고 진행을 막지 않는다.

## 배치 B — 원장에서 생성한 고지

- 실제 포함 자산/서체 라이선스 원장에서 게임 내 제3자 고지 화면을 만든다.
- 라이선스 의무를 과장하지 않고 패키지 사본·메타데이터·인게임 접근성을 구분한다.
- Godot Engine MIT 사본을 포함하고, 오디오 21개 원천과 서체 6개/3패밀리는
  기존 원장에서 결정론적으로 생성한다. 제공자·라이선스는 UI 코드에 손으로
  복사하지 않는다.
- 영문 고지 화면에 노출되던 두 OFL 사본의 한국어 내부 조사 메모는 법적 원문과
  분리한다. 실제 저작권 문구와 OFL 1.1 전문은 그대로 보존한다.
- 말발굽 pack의 혼합 라이선스를 pack 단위 CC BY로 과장하지 않는다. 실제 출하
  파일이 쓴 `ground.mp3`의 D4XX·CC0 per-file 기록을 원천 manifest와 생성기에
  남기고, 게임 내 고지와 필수 저작자표시 수를 그 실제 사용분에서 계산한다.
- Godot 자체 MIT만으로 엔진에 포함된 제3자 라이브러리를 덮지 않는다. 공식
  4.6.2-stable `COPYRIGHT.txt`를 hash 고정해 패키지와 게임 내 엔진 탭에서
  접근할 수 있게 한다.

## 완료 증거

- 화면/세이브/빌드 매니페스트 식별자 불일치: `0`
- 고지 원장에 없는 수기 항목: `0`
- 기존 크레딧·버전 중복 구현: `0`

## 완료 결과 (2026-08-03)

- `build_identity_audit.py --self-test` 51개 fixture와 실제 수동 저장·첫 30초·
  flavor 검사가 통과했다. 미래 schema와 잘못된 identity는 상태 적용 전에
  거부하며, 다른 build ID는 진단 경고로만 남는다.
- `third_party_notice_audit.py --self-test` 15개 fixture가 통과했다. clean Full과
  V2 export pack은 각각 필수 고지 10파일을 바이트 단위로 모두 포함했고,
  1,416개 entry 집합 해시는 양쪽 모두
  `34dab9f7257329d5ccdae0ce35a4924ad6a63451053f14cfdb44cf37aebf87b3`이다.
  Full pack SHA-256은
  `0ee6372ec9bc7dae3cb4c0591dba4688578711548424b950a66e818c7a0a32ec`,
  V2 pack SHA-256은
  `34581a12a71e5e9ac9fb638d3b52386a1f7c648a2f2a84d1ef8d3a06617f75b8`다.
- KO/EN 960×600·1280×800 고지 화면 16장을 실제 렌더했다. 탭 전환 전후 고정
  헤더 픽셀은 동일했고, 스크롤 포커스의 2px 외곽선과 긴 본문·푸터·안전영역을
  원본 RGBA와 육안으로 확인했다.
- 전체 감사는 오류·경고 0과 `✅ 감사 통과`로 끝났다. UIStyle 표면 래칫은
  기존 기준선(StyleBox 260, override 2,116, color 678)을 늘리지 않았고,
  일본어 비출시 UI 사전도 2,585키 strict parity를 유지했다.

## 규범 승격 판정

- 승격: `docs/BUILD_PIPELINE.md`의 `산출물 식별과 저장 호환`,
  `제3자 고지 스모크`, `시각 스모크` 절 — 다음 산출물에도 계속 적용할
  identity·호환·pack·화면 검증 계약.
- 승격: `docs/MASTER_RELEASE_AUDIT.md`의
  `Artifact Identity, Save, and Third-Party Notice Gate` 절 — 출시 후보의
  통합 차단 기준.
- 승격: `docs/QA_CHECKLIST.md`의 release identity/notice 표 행과 `Save/Load` 절 —
  수동·자동 QA에서 계속 확인할 사용자 표면과 저장 정책.
- 일회성: 이번 오더의 두 범위 확장 선언, 임시 pack 경로, 위 pack SHA-256과
  구현 시점 수량은 이 아카이브의 재현 증거이며 다음 작업의 고정 규칙이 아니다.
