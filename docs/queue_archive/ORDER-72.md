# Archived Queue Spec: ORDER-72

> Canonical status and execution order are indexed in `docs/CODEX_QUEUE.md`.

#### [x] ORDER-72 [P0·출시 범위] 심의·스토어 설문에 답할 실제 콘텐츠를 센다

**착수 파일:** `content/meta/release_content_inventory.json`,
`tools/release_content_inventory.py`, `tools/audit.sh`, `tools/audit_scope.json`,
`docs/CONTENT_RATING_INVENTORY.md`, `docs/STEAM_PAGE.md`,
`docs/MASTER_RELEASE_AUDIT.md`, `docs/QA_CHECKLIST.md`, `docs/PROPOSALS.md`,
`docs/CONTEXT_INDEX.md`, `docs/context_manifest.json`과 큐/완료 증거 문서.

**착수 설계 판정:** 현재 10개 export preset은 모두 `all_resources`이고
`tools/*, docs/*, build/*`만 제외한다. 따라서 V2 데모에서 도달하지 못하는
5년 사건·카지노/경마/홀덤 런타임도 업로드 패키지에는 들어간다. 한 원장을
`24주 V2 도달 / 240주 본편 도달 / 패키지 포함·현재 비도달`로 나누고,
도박·선정성·폭력성·공포·언어·범죄·음주/흡연/약물의 내용 축과 생성형 AI·
온라인 기능을 각각 소유 파일, 진입점, 표현 강도에 연결한다.

**실행 중 정합 확장:** 실제 패키지는 활성 `ImageRegistry` 246장만으로 설명되지
않았다. source raster 292장 중 game pack 대상은 284장이고, Registry 외부 source
46장 중 38장도 포함된다. `.gdignore` 아래 상점 스크린샷 8장만 source-only다.
기존 AI 결정도 코드·오디오 제작 보조와 대표 실행 검수를 빠뜨려 현 증거와
충돌했으므로 `DECISIONS.md`의 최신 대체 결정과 공시 래칫으로 함께 정렬했다.
이 확장 때문에 `docs/AUDIO_QA.md`와 `docs/DECISIONS.md`도 만졌다.

## 깊이 3문

1. 지우면 `all_resources` export에 들어가는 도박·성인 주제를 네 미니게임만으로
   오판하고, 구 RC와 다른 빌드에 같은 설문 답을 재사용한다.
2. 게임 상태는 바꾸지 않지만 어떤 콘텐츠를 포함/제외할지의 사용자 결정이 달라진다.
3. KO/EN 데모 출고 범위, 전체 5년판, 접근 불가하지만 패키지에 든 리소스가 경쟁한다.

## 배치 A — 재현 가능한 인벤토리

- 10개 preset, KO/EN 사건·엔딩, 실제 런타임 진입과 package filter를 함께 따라
  내용 7축과 생성형 AI·온라인 사실을 기계 원장으로 고정했다.
- V2 fresh-start는 프롤로그 12건과 W1–24 55건의 합집합 67건으로 계산하며,
  full corpus 1,597건과 package 포함을 같은 값으로 취급하지 않는다.
- candidate ID·KO/EN 본문, ending 본문, raster 경로·파일, legacy foreground
  조건, V2 동적 root를 fingerprint와 self-test 13건으로 잠갔다.

## 배치 B — 사용자 결정 경계

- 최종 연령 등급·콘텐츠 삭제·export filter 변경은 모두 `user_required`로
  유지했다. 인벤토리는 사업·법무 결론이 아니라 후보 build의 사실 증거다.
- 열린 제안 5건 상한은 설계·사업 제안에만 적용한다. 완성된 RC의 재미·문체·
  A/V·물리 입력 등 사람 판정 목록에는 수량 제한이 없으며 `human_gates.json`이
  정확한 후보·표본·합격 기준을 소유한다.

## 완료 증거

- 원장: `RELEASE_CONTENT_INVENTORY_OK presets=10 events_ko_en=1597/1597
  axes=9 network_apis=0 decisions=user_required`
- 변이 방어: `RELEASE_CONTENT_INVENTORY_SELF_TEST_OK cases=13`
- clean 구현 커밋 `1408609c1cde6d28ce392b3c1f97a62c51630f37`, tree
  `affa4ff95d35929140e90411bfe29d82aa03ee0d`에서 Windows Full/V2 pack을
  새로 만들었다.
- Full: 1,412 entries, ZIP SHA-256
  `1f742a5c89f81be7892b90ea421c3f9d695c18711b6a2fc5670ffee0839eb297`.
- V2: 1,412 entries, ZIP SHA-256
  `ba14d823ae79c229d0cd0cd3ef609dd5ce19c009c1fa804802d444b6041a50d2`.
- 두 pack의 entry-set SHA-256은
  `3efaa6110c74f405e043b2191380c4d8bbfd8dab1cffe927f97eb47b9f23305e`로
  같고, 사건 127+127파일·KO/EN 엔딩·원장 원문과 284 raster import target을
  모두 확인했다. 프로필을 바꿔 검사하면 두 feature 차이를 모두 거부한다.
- V2 pack을 `--main-pack`으로 무인자 마운트해
  `PLAYTEST_FLAVOR_CHECK_OK feature=core_loop_v2_playtest entry=1
  retail_entry=0 paths=14 collisions=0 presets=10 marker=1 runtime_default=0
  cutoff=24`를 확인했다.
- 종료 상태 전체 `GODOT=… ./tools/audit.sh`가 마지막 줄
  `✅ 감사 통과`로 끝났다.

## 정본 승격 판정

- **승격:** `content/meta/release_content_inventory.json`이 package inclusion,
  runtime loading, fresh-start reachability, 표현 강도, AI·온라인 사실과 최종
  사용자 결정 경계를 기계 정본으로 소유한다.
- **승격:** `docs/CONTENT_RATING_INVENTORY.md`는 위 원장의 재생성 가능한 사람
  검토면이며 수동 편집하지 않는다.
- **승격:** `docs/MASTER_RELEASE_AUDIT.md`와 `docs/QA_CHECKLIST.md`가 후보 build의
  실제 pack smoke와 심의 전 사람 검토 게이트를, `docs/STEAM_PAGE.md`가 제출
  공시 초안을 지속 소유한다.
- **승격:** `docs/DECISIONS.md`의 2026-08-03 대체 결정이 활성·비활성 raster
  모집단과 코드·오디오를 포함한 AI 제작 범위·검수 표현을 소유한다.
- **승격:** `docs/PROPOSALS.md`가 열린 제안 5건 상한과 무제한 사람 판정 목록을
  구분한다.
- **일회성:** 위 구현 commit/tree, 로컬 ZIP 크기·해시와 profile-swap 진단은
  이번 clean export 증거다. 외부 RC·최종 등급·출시 GO로 승격하지 않는다.

## 남은 정합 위험

- `gambling_rock_bottom`의 조건은 현재 `addiction >= 80`과 미소비 flag만 보지만
  산문은 빈 통장·빌린 돈을 확정한다. 현금·부채 상태와 어긋날 수 있으므로 다음
  승인된 정합 작업에서 조건 또는 상태별 산문을 맞춰야 한다. 이 오더는 사실을
  숨기거나 여섯 번째 제안으로 우회하지 않고, 콘텐츠·밸런스는 바꾸지 않았다.

## 완료 보고 (2026-08-03)

- export 포함 콘텐츠의 소유 파일/진입 가능성/표현 강도 누락 `0`, 기존 AI
  disclosure와 실제 제작 방식 모순 `0`, 최종 등급·삭제 자동 결정 `0`이다.
- 자동 검사는 패키지와 코드의 사실을 증명한다. 정상 속도 24주 재미·문체·연속
  A/V·물리 패드와 최종 심의 답은 완성된 동일 RC에서 사람이 판정한다.
