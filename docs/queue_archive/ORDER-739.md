# ORDER-739 — 첫해 결산의 JA/zh 현재 원문 정합

> Canonical status and execution order are indexed in `docs/CODEX_QUEUE.md`.

#### [x] ORDER-739 · 첫해 결산의 JA/zh 현재 원문 정합

2026-11-03 source24 정정만 독립GO. 부모157, C2/C5. 사용자 본편 일본어·중국어 완성 재개에
따라 실제 차선에서 검출한 stale receipt를 번역 직접 대조로 해소한다.

## 판정 단위와 소유권 (일회성)

- `content/events_{ja,zh-CN,zh-TW}/arc_year_close.json`의 `arc_year1_close` 8 leaf:
  `/choices/0/{text,result_text}`, `/description`, `/description_if_known/`의
  `entered_network`, `escaped_dirty_money`, `hit_rock_bottom`, `jaehyuk_scammed`,
  `kept_clean_hands`만. 8×3=24개 기존 번역의 수정이지 신규 커버리지가 아니다.
- `content/meta/full_game_localization.json` 이24개 current 수용과 별도 correction.
  기존 batch/영수증/이전 target 해시를 보존한다.
- 이 사양·157·큐·CLAUDE·11-03 WORK_LOG·독립 보고/판정만. 기타 제품 비소유.

## 깊이 3문과 검증

1. 제거하면: '지킨 것/미룬 것'을 '얻은 것/내준 것'으로 잘못 말하고,
   현재 원문이 없는 결론·천장 장면을 번역이 계속 만든다.
2. 선택 대가: 밤의 수첩/아버지 전화/잠 선택의 비용과 병렬 결산을 보존한다.
   새 효과·힌트·선택 우열을 넣지 않는다.
3. 경쟁: 전체 미완 중 실행된 감사가 발견한 실제 source 불일치를 먼저 수리한다.

공식 fresh export/check/import --replace-existing, KO 직접 독립 번역,
숫자·원화·토큰·개행·지역문자 검사와 원문8/목표24 전독. 비소유값·선택순서·
원장 이력 불변을 역대조한다. 기존 도구 반례 검사는738에서 실행했으므로
변경 없는 self-test 전체를 이유 없이 재실행하지 않는다. 실제 수용/패리티·
공개데모·scope 진단 수 변화를 확인한다. 광범위 stale 채무를 지문만 덮어 숨기지 않는다.
KO/EN·게임로직·공개 데모·저장·project.godot·retail allowlist 비소유.
실제 앱/원어민·전체5언어·전체차선·출시 완료는 이 범위 밖이다.

도달 경로: full_body scope source hash 불일치8×3와 실제 target 전독.
생산자↔독자: 현재 한국어 `arc_year1_close` → 기존 overlay consumer.
바꾸는 상태: 낡은 결산/허위 결론24 → 현재 선택·현재 감각24.
포기 시 잃는 것: W48 결산이 현재 KO 선택/장면과 같은 의미로 읽히는 것.
서사 위치/계층: 첫해 마지막 밤/W48, 원본 계층 불변.
닫는 것: 해당24문구 source/기계/독립 검수만; 전체 번역·화면 미완.
규범: 기존 I18N 정본 준수, 신규 규칙 승격 없음.

## 실제 검사

공식 check/import 언어별8개·stderr0, delta24/3파일·비소유값/이전수용불변 통과.
scope 진단1236→1212, stale source1233→1209(언어별411→403), 요약3 유지.
이root의 stale source24만 제거됐고 전체번역/전체차선은 여전히 미완이다.
원자료 `.git/localization-year1-20261103/`의 source/response/check/import/delta/scope.
738에서 실행한 변경 없는 검증도구 반례를 재실행하지 않았으며 제품과 공개데모
패리티는 이번 반영 뒤 다시 확인했다. 독립 검수는 원문8/목표24 전독 및 v2 16 재독 GO다.

독립 전독에서 CN `手册`의 안내서 의미와 CN/TW '연락을 미룬 이름'의
행동 축소를 지적받았다. 소유8leaf 안에서 개인 기록은 `笔记本`,
뒤로 미룬 사람의 넓은 의미로 수리했다. CN/TW fresh v2 export→check→import로
중간 target 해시를 결속했고 첫 초안·기계 영수증도 삭제하지 않았다.
`LOCALIZATION_REVIEW_FIX_CHAIN_OK`24·`LOCALIZATION_CORRECTION_DELTA_OK`24/3파일,
최종 공개데모·EN coverage·context/queue/diff 확인. 별도 검사 보고 MD의
문서 분류 누락은 context_manifest의 기존 audit_and_reports에 해당 폴더만 등록했다.

최종 [독립 보고](../agent_reviews/order739-year1-cjk.md): source24 정정만 GO.
실제 화면·원어민·전체 차선/번역·원격 CI는 이 판정에 포함하지 않는다.
