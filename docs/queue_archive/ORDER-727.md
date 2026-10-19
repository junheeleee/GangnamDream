# ORDER-727 — 게임을 부팅하지 않는 상점 이미지 내보내기

#### [x] ORDER-727 [C5 화면 없는 준비] 완료 — 2026-10-19

main20d41ff/run39095135418 success·예외0·Mac잠금. 726에서 발견한 고정 공용tmp와
기존 출력 삭제 문제를 피하는 오프라인 exporter 한 단위를 구현한다. 촬영 producer는
별도이며 실제 앱 C1은 잠금 해제 뒤715 동일W151부터 재개한다.

## exact 소유

root: tools/store_shot_export.py, tools/store_shot_export_self_test.py,
tools/audit_scope.json, docs/STORE_SHOTLIST.md 재생성절,
docs/QA_CHECKLIST.md store-asset절·store scope표1행, 이사양/archive, CODEX_QUEUE의727행/C5,
CLAUDE 그다음행, WORK_LOG 새기록, CODEX_QUEUE_L3_PENDING 순번만 임시 +1/마감복원.
기존715/724의 미커밋 월기록은 별도 보존한다.
root private: .git/order727-store-export-20261019/{baseline.json,checks.json,
completion.json}와 checks/ 원로그만. 독립 검수자는 같은 디렉터리의
independent-review.md/json만 쓰며 그 외 파일 읽기·표적 테스트를 한다.
제품/옛GDScript/설정/저장/8장자산/JAzh/공개데모/과거판정 수정0.

## 한 단위·검증

Python/Pillow로 caller가 지정한 원본 manifest와 정확한 영어1280x800 PNG8장을
검증해 중앙1280x720으로 자른다. 원본/후보신원/촬영증거 파일 SHA를 결과에 연결한다.
기존 디렉터리 재사용·삭제·덮어쓰기·공용tmp입력 fallback·Godot/앱 부팅0.
새 전용 출력 폴더만 생성하고 실패 시 부분 출력은 보존하되 완료manifest/성공표식0.
정상 PNG decode와 hash/roster/크기/출력보존/실패경로를 합성 fixture로 검사한다.
Pillow는 로컬 이미지 처리 의존성; 기존 dependency-free 제품 검사와 CI는 유지한다.
촬영 증거의 진실성/현재 후보 일치/시각 품질은 별도 검수이며 hash 일치로 승인하지 않는다.

깊이3문: 제거하면 옛 게임부팅 export만 남는다. 게임상태와 장기선택은 바꾸지 않는다.
경쟁 대상은 재사용 공용tmp 출력이며 fresh 디렉터리로 분리한다.
표적 self-test·audit_scope verify·문서 영향검사·diff, 비저자 실제코드/증거 검수.
실촬영·시각판정·C1·전체C5·외부 업로드 GO0. 지속 사용법은 STORE_SHOTLIST에 승격,
나머지는 일회성. 자동 게이트는 도달 가능성과 계약 충족의 증거이지 재미·깊이·문체의 증거가 아니다.

## 결과

선언4c6c6d8. 독립검수 /root/store_export_review의
`.git/order727-store-export-20261019/independent-review.md/json`에서
GO_OFFLINE_EXPORT_SOURCE_CONTRACT_ONLY. 저자 합성17테스트와 비저자 직접17테스트
각각 통과, 실제 촬영/게임실행0. 보고서 source5개 SHA와 완료 커밋은 completion.json에
대조한다. 사용자/실원본 이미지는 생성·크롭·교체하지 않았다.
독립MD5673B/SHA256 6dce44d032553525ef44e2289b186179d202fb31fbcbd61bef11352278af28c7,
JSON3312B/SHA256 e96b3bf7d698085fbcc072794d97cacefee24f2dd2a578b596967d43e15b9427.

첫 source 표적실행은 queue순번 충돌로 exit1이며 checks/source.log 그대로 보존했다.
임시727행 추가에 맞춰 이어보기 순번만 +1한 뒤 docs-complete.log의 문서5검사exit0,
등록verify181·원합성17통과를 각각 구분한다. 마감에서727행 제거·이어보기순번복원.
진행중빈 docs.log는 완료근거가 아니며 실제 종료는 checks.json/completion.json에 연결한다.
Mac잠금으로715 W151 실제진행0, 715/724월기록 미커밋 유지. 현재의 새 도구 파일은
다음715 fresh admission에서 별도로 대조해야 하며 과거 tools4 허용핀을 재사용하지 않는다.
승격: STORE_SHOTLIST 재생성절의 오프라인 사용법. source수용은 실촬영격리/시각품질/
C1/C4/전체C5/출시승인이 아니다. 그 밖의 실행/검수 지시는 일회성이다.
