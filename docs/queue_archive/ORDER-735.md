# ORDER-735 — 현재 Steam 캡슐 4규격 출력 경로

#### [x] ORDER-735 — 2026-10-30 4규격 source 준비 수용

C5. 최신 사용자 `고`에 따라 남은 캡슐 구규격·장르부제·세로형 누락을 보완한다.
공식근거: https://partner.steamgames.com/doc/store/assets/standard (10-30 확인).
Main1232x706/Header920x430/Small462x174/Vertical748x896, 제목 외 문구0.

깊이3문: 없으면 구규격을 새로 생성함 / 게임선택·제품상태 변경0 /
잠금 중 C5 source 준비만, 본편 대표 경로를 대체하지 않음.

## 정확한 소유

- root: 새 `tools/steam_capsules.json`, `tools/SteamCapsuleExport.gd`,
  `tools/SteamCapsuleExport.tscn`; `docs/STEAM_PAGE.md` §8/§7의 현행 규격 구분,
  `docs/IP_VISUAL_IDENTITY.md` 캡슐 계약, `tools/audit_scope.json` 표적검사 등록.
- 독립검수에서 발견한 같은 파일 §2의 옛 '소형만 태그라인 제외/세 인물' 충돌도
  정렬한다. 5언어 카피 원문은 보존하고 캡슐 외 사용으로 표시한다(제품 범위 추가0).
- 제작자 capsule_pipeline: 새 `tools/steam_capsule_export.py`,
  `tools/steam_capsule_export_self_test.py`만. 기존 store/trailer/bootstrap/wordmark 수정0.
- 독립 capsule_review: private `.git/order735-steam-capsules-20261030/review.md/.json`.
- root: 이 사양/마감 archive·큐 임시행·WORK_LOG 신규행·CLAUDE 준비행.

## 경계와 산출물

기존 1920x1080 master SHA3883727682c02ab78e3ce0980800a4aa04912a939b363d31ceed5496072c388b와
기존 GangnamWordmark를 그대로 재사용하는 native/code 출력 경로다. 새 인물·AI그림·
원본 이미지 편집0. 기존 `KeyArtExport`와 v2/무버전 PNG, 공개/앱/source9499는 비소유.
신규 출력은 별도 외부 fresh directory만; 기존 승인파일 덮기/삭제0.

가로2종은 기존 master/title-safe 구도를 보존한다. 작은형은 민준 얼굴+큰제목,
세로형은 빈 왼쪽 일부만 덜고 세 인물을 보존한 art band+별도 하단 제목의 준비 레이아웃.
글자/얼굴/작은 크기 품질은 실제 렌더 뒤 별도 확인하며 지금 승인하지 않는다.
제목 외 부제/장르/리뷰/CTA는 출력하지 않는다.

Python runner는 clean source snapshot·공식 엔진 선택/핀·pre-autoload fresh namespace,
fresh external output·원3로그·exit/timeout/표식/오류·4PNG decode·규격/비중복·입력SHA를
결속한다. 실제 실행에는 명시 render 요청과 잠금해제 확인을 요구한다.
잠금 중 모의/정적 계약 검사만. 실제Godot/캡슐렌더/그림교체/스토어/업로드0.
임의 합성 PNG 성공을 실제 캡슐·C5 완료로 세지 않는다.

735 변경으로 frozen89d8의ad2 재개준비는 자동재사용 불가다. 원ad/ad2/draft1/
HOLD/입구null/저장53a3 보존, 실제 재개 때 새 exact workspace pin과 독립입구가 필요하다.
이번 작업에서 재개 helper/plan/본편월별기록을 수정하거나 실제 앱을 실행하지 않는다.

검증: 영향목록 먼저, source-only/모의 반례·기존 keyart gate·queue/context/diff,
비저자 전수 검수. 지속규칙은 STEAM_PAGE/IP_VISUAL_IDENTITY로 승격,
작업소유·모의검사·현재출력 보류는 일회성.

## 마감 증거

도달: STEAM_CAPSULE_CHECK_OK count=4 scope=source_contract_only engine_runs=0;
STEAM_CAPSULE_EXPORT_SELF_TEST_OK tests=31 synthetic_only=1 engine_runs=0.
생산자↔독자: steam_capsules.json→SteamCapsuleExport→전용 Python runner.
상태: 구규격만→현행4규격/title-only/small·vertical 준비코드; 제품상태0.
포기시손실: 승인master를 덮지 않는 새 규격 생성경로. 서사/Tier 비해당.
닫는것:source 준비만. 실제 컴파일/렌더/시각/사람/패키지/출시0.

독립 capsule_review GO_SOURCE_PREPARATION_ONLY. 코드/문서8파일 전수 검수,
작은형font44→40·실제minimum vs선언box 거부 추가, §2옛태그라인 충돌 수리.
원master/8PNG/legacy exporter/wordmark/bootstrap/project 보존 exact.
source4/mock31/keyart/audit등록184/context/queue/diff 통과.
검수 `.git/order735-steam-capsules-20261030/review.md`
SHA2739757a0ebd0a1cfaee0eb8558b269e23dce563c24fff96744c640aae3f4099,
JSON SHA13b93cc679ffe577dd783ea69afeb99a18a2559f637755fef1eabed53de30720.
8파일 exact SHA는 보고에 결속. dirty root/선언82ad108의source검수이며 clean제품GO가 아니다.
승격: STEAM_PAGE §2/§7/§8 및 IP_VISUAL_IDENTITY TitleKeyArt/Wordmark계약.
자동 게이트는 도달 가능성과 계약 충족의 증거이지 재미·깊이·문체의 증거가 아니다.
