# ORDER-741 — 월급 한계 장면의 JA/zh 정합

> Canonical status and execution order are indexed in `docs/CODEX_QUEUE.md`.

#### [~] ORDER-741 · 월급 한계 장면의 JA/zh 정합

2026-11-03 root 착수, 부모157·C5. 소유는7×3=21개 기존 번역 정정이다.

## 소유권·깊이 3문 (일회성)

- `content/events_{ja,zh-CN,zh-TW}/arc_midgame.json`의 `arc_career_ceiling`만:
  description, description_if_known의 sangchul_mirror_deal_face_up/
  sangchul_mirror_hospital_face_up, choices/0/result_text,
  choices/1/text·result_text, choices/2/result_text.
- `content/meta/full_game_localization.json` 이21개 수용과 별도 correction,
  원 batch/수용·이전 target 지문 보존. 제목·나머지 선택 비소유.
- 이 사양·157·큐·CLAUDE·11-03 WORK_LOG·독립 보고/판정만.

1. 제거하면: 현재 폰 장면을 다음날 사무실/퇴근 지하철/사원증·모니터로
   고정하고 매일 밤 행동을 발명하는 낡은 번역이 남는다.
2. 선택 대가: 월급은 기반으로 유지/이직 탐색 시작/역할을 확인하고 다음근무를
   여는 세 행동, 병동과 거래 명함의 각각 치른 값을 보존한다.
3. 경쟁: 실제 감사가 잡은 source 불일치와 선택의 정반대 과거를 UI채우기보다
   먼저 정합한다. 새 우열·승리·현재직장 사실은 만들지 않는다.

한국어에서 JA/CN/TW 독립 번역, fresh export/check 뒤 독립 전독을 받고
명시 replace import. 숫자/30억원/토큰/개행/지역 문자·HEAD 대비 소유21값만
변경됐는지 역대조한다. 기존 도구 self-test는 반복하지 않고 실제 수용·
공개데모/EN·scope 진단 변화·context/queue/diff만 확인한다.
KO/EN·gameplay·공개데모·저장·project.godot·allowlist 비소유.
전체차선/전체번역·화면/원어민·외부출시 완료는 판정하지 않는다.

도달 경로: stale source7문구와 실제 KR/목표 장면 직접 대조.
생산자↔독자: KR arc_career_ceiling → 기존 built-in overlay.
바꾸는 상태: stale21 → 현재 source21; 신규 커버리지0.
포기 시 잃는 것: 모든 직업에서 성립하는 현재 폰·장부·다음근무의 사실.
서사 위치/계층: 기존 월급 한계 사건·원본 계층 불변.
닫는 것: source21 정합만. 규범은 기존 I18N 정본 적용·승격0.

## 검사 실물

수용 전 독립 원문7/목표21 전독, mirror/receipt의 실제 KO 문맥까지 확인했다.
JA/CN의 ‘병동에 물리적으로 자신이 없던 시간’ 구체화2곳을 지적받아 실제
연락 무응답의 비용으로 수정했다. 첫 두 초안은 pre-review.response에 보존,
독립 재대조에서 해당 구절1곳씩 외 source/id/metadata/나머지 값 불변 수용.
최종 공식 check/import7×3·stderr0, delta21/3파일·원수용/비소유값 불변,
scope1194→1173(stale1170=언어별390+요약3)으로 이21개만 해소했다.
공개데모5언어/100leaf/122UI·EN1813/35 clean·context/queue/diff 확인.
원자료 `.git/localization-career-20261103/`, 불변 self-test 재실행0.
전체 번역·차선·앱/화면·원어민·원격CI는 이 증거로 완료 판정하지 않는다.
