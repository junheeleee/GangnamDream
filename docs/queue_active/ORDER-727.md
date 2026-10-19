# ORDER-727 — 게임을 부팅하지 않는 상점 이미지 내보내기

#### [~] ORDER-727 [C5 화면 없는 준비] 착수 — 2026-10-19

main20d41ff/run39095135418 success·예외0·Mac잠금. 726에서 발견한 고정 공용tmp와
기존 출력 삭제 문제를 피하는 오프라인 exporter 한 단위를 구현한다. 촬영 producer는
별도이며 실제 앱 C1은 잠금 해제 뒤715 동일W151부터 재개한다.

## exact 소유

root: tools/store_shot_export.py, tools/store_shot_export_self_test.py,
tools/audit_scope.json, docs/STORE_SHOTLIST.md 재생성절,
docs/QA_CHECKLIST.md store-asset절, 이사양/archive, CODEX_QUEUE의727행/C5,
CLAUDE 그다음행, WORK_LOG 새기록. 기존715/724의 미커밋 월기록은 별도 보존한다.
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
