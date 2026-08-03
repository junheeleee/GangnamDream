# Active Queue Spec: ORDER-73

> Canonical status and execution order are indexed in `docs/CODEX_QUEUE.md`.

#### [~] ORDER-73 [P0·패키징] 실제 버전·세이브·제3자 고지를 하나로 묶는다

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
> `content/meta/third_party_notices.json`, `tools/third_party_notice_audit.py`,
> `assets/audio/AUDIO_THIRD_PARTY_NOTICES.md`, `export_presets.cfg`,
> `scenes/StartMenu.gd`, `tools/ScreenshotQA.gd`, `tools/audit.sh`,
> `tools/audit_scope.json`, `docs/QA_CHECKLIST.md`, `docs/BUILD_PIPELINE.md`,
> `docs/MASTER_RELEASE_AUDIT.md`.
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

## 완료 증거

- 화면/세이브/빌드 매니페스트 식별자 불일치: `0`
- 고지 원장에 없는 수기 항목: `0`
- 기존 크레딧·버전 중복 구현: `0`
