# ORDER-740 — 둘째 해 장면의 JA/zh 정합

> Canonical status and execution order are indexed in `docs/CODEX_QUEUE.md`.

#### [~] ORDER-740 · 둘째 해 장면의 JA/zh 정합

2026-11-03 root 착수, 부모157·C5. 소유는 기존 번역6×3=18개 정정이다.

## 범위와 깊이 3문 (일회성)

- `content/events_{ja,zh-CN,zh-TW}/arc_midgame.json`만:
  `arc_34_two_years_in`의 title/description/description_orthodox/
  description_unorthodox, `arc_year_one_half`의 title/description.
- `content/meta/full_game_localization.json`: 이18개 수용과 별도 correction,
  원 수용/이전 target 지문 보존. 기타 번역·choices 비소유.
- 큐·157·이 사양·CLAUDE·11-03 WORK_LOG·독립 보고/판정만.

1. 제거하면: 현재 ‘둘째 해의 어느 밤’을 ‘18개월째/둘째 해 끝’으로 한정하고
   조건 없이 ‘큰 함정에 빠지지 않았다’는 과거를 발명하는 번역이 남는다.
2. 선택 대가: 현관 열쇠·현재 잔액·한 달 계획/검토/휴식의 뜻을 보존하며
   선택/효과/기억·라우팅을 바꾸지 않는다.
3. 경쟁: 확인된 stale source 중 시기/경험을 단정하는 실제 차이를 먼저 수리한다.

KO에서 JA/CN/TW 독립 직접 번역. fresh export/check 뒤 독립 전독을 받고
명시 replace import한다. 숫자·원화·토큰·개행·지역 문자와 HEAD 대비 소유18값만
변경됐는지 확인한다. 기존 도구 self-test는 불변이므로 반복하지 않고 실제
수용/역대조/공개데모·EN coverage·scope 진단 변화·context/queue/diff만 검사한다.
KO/EN·공개데모·게임로직·project.godot·사용자 저장·allowlist 비소유.
전체 차선/전체5언어·렌더·원어민·출시 완료는 판정하지 않는다.

도달 경로: 기존 source mismatch와 원문/목표 두 사건 직접 대조.
생산자↔독자: KR arc_midgame → 기존 built-in overlay consumer.
바꾸는 상태: stale18 → 현재 source18; 신규 커버리지0.
포기 시 잃는 것: 둘째 해의 열린 시기·실제 손/열쇠 감각·검토 선택의 뜻.
서사 위치/계층: 기존 두 사건·계층 불변.
닫는 것: source18 정합만. 규범은 기존 I18N 정본 적용·승격0.

## 검사 실물

수용 전 독립 원문6/목표18 전독, 초안의 열린 시기·현재 동작·계획 의미에
차단 결함0. 자가 검토에서 JA/TW 제목을 신체에 밴 도시 습관의 의미로 정렬했다.
첫 TW check는 원문에 없는 `機會兩個字`의 수량2를 거절해 `機會這個詞`로
초안만 수정했다. 검사 완화0·원실패 stderr 보존, 최종 check/import6×3·stderr0.
`LOCALIZATION_CORRECTION_DELTA_OK`18/3파일·비소유값/이력 불변,
scope1212→1194(stale1191=각397+요약3)로 이18개만 해소했다.
공개데모5언어/100leaf/122UI·EN1813/35 clean, context/queue/diff 표적 확인.
원자료 `.git/localization-midgame-20261103/`, 무변경 self-test 재실행0.
전체 번역·차선·앱/화면·원어민·remote 전체CI는 이 증거에 포함하지 않는다.
