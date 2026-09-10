# Active Queue Spec: ORDER-235

> Canonical status and execution order are indexed in `docs/CODEX_QUEUE.md`.

#### [~] ORDER-235 [전체 현지화] 엔딩 기록19단위·UI52키 번역

**[~] 2026-09-10 착수 — 아래 파일만 소유한다.** 사용자 전체 번역·개발 위임과
ORDER-157을 따른다. 종료234 이후 clean main `486f9d37754e16e68189f182f6b3795c02c2e7ce` /
tree `24a3031a788fc1c993e0b349dee0466e7f2563b3`가 기준이다. private 초안의 생성은 선언이나 착수가 아니다.
직전 설정60과 그 회귀·독립 판정을 새156의 검수로 합산하지 않는다.

## 깊이 3문·배치

1. 없으면 무엇이 빠지는가? 엔딩 진행과 시간·연락 기록의 중국어 표면이 영어로 남고,
   기존 일본어의 ‘연락 원장=院長に連絡’, ‘주=株’ 오역이 기록 의미를 바꾼다.
2. 바뀌는 미래 상태는? 텍스트만 바뀐다. 엔딩·관계·기록 수치·해금·재시작·공유 효과는 그대로다.
3. 무엇과 경쟁하는가? 장면 계속/크레딧/이전/다음 기록과 네 선택 범주의 의미를 구분한다.

하나의 엔딩 기록 표면19판정단위·52문구다. 여러 관련 표제를 함께 판단하며52개 낱말을
52단위라고 세지 않는다. 각 언어52 전량을 직접 읽어 총156을 검수한다.
ROOT도52 KO/EN/JA·69calls와 실제 MainGame/GameState/CoreLoopPlanner 소비자를 직접 읽었다.
이 사전 원문 읽기는 이후 새 번역156의 독립 검수나 실행 도달 증거를 대신하지 않는다.
원문 수집은 이전234 중1회였고 현재 선언에는 그 원형 및 실제파일을 재결속한다.
초기38095/b93 관측과 이후38155/b94 metadata-only 재결속을 구분한다.

사전조사 `order234-next-ui-preflight.json` 73059B /
SHA `9b1b88ba10cca8f40880251f3f42be2ada4aa26dba2780fb7d1ced34ccccdb1f`.
source map SHA `677c19221f81a5a01625e82bdc039efa5ccae5691edcb833ffb4f4f9c25656ee`:
`{leafID:{source_sha256}}`의 canonical JSON이며 배열 digest가 아니다.
정확 IDs는 `order235-leaf-ids.json` 2620B /
SHA `0bf5b20a923dbe46172b3d6c5944e4778ac8884ef895a69ca0fa7c532b8ad00f`.
JA기존52, CN/TW각52 null; LF/name/context0. printf8개(6leaf), brace6개(5leaf).
collector format_template=false와 실제 후치 printf/.format을 혼동하지 않는다.
선택 보호0·기수용0·ORDER23420키와 중복0, 실제 literal caller69곳이다.

## 정확한19단위·52키

1. 마지막 장면 제목과 엔딩 대체 제목: 마지막 장면 / 엔딩
2. 장면 진행 수와 다음 단계: 장면 %d / %d / 장면 계속 / 크레딧으로
3. 이전 페이지와 크레딧 이후 진행: 이전 / 크레딧 뒤로
4. 제작 주체·엔진·플레이어에 대한 감사: 제작 / Godot Engine으로 제작 / 그리고 이 5년을 살아 준 당신에게.
5. 인물 후일담의 제목과 읽기 관점: 후일담 / 그 사람들은 / 같은 결말도 곁에 누가 남았는지에 따라 다른 표정을 갖는다.
6. 시간 기록의 제목과 비평가적 안내: 기록 I / 시간의 기록 / 평가 대신, 이 5년이 어디에 남았는지만 적는다.
7. 마지막 장의 단계와 이동 버튼: 기록 II · 마지막 장 / 마지막 장 / 마지막 기록
8. 남은 기록·다음 삶 화면 제목: 기록 III / 남은 것과 다음 삶
9. 다시 시작과 메인 메뉴 이동: 다시 시작 / 메인 메뉴
10. 신규 기록 유무와 업적·칭호 표시: 새로 열린 기록 / 새로 열린 기록 없음 / 업적: %s / 칭호: 「%s」  %s
11. 선택한 방식·난이도·마스터리의 표제: 선택한 방식: %s / 난이도: %s / 미니게임 마스터리: (원문 후행 공백1)
12. 연도별 장면 기록 제목과 연차: 5년의 기록 / 5년, 다섯 장면 / 남겨 둔 장면들 / %d년 차
13. 선택 기록의 네 범주와 주 단위: 선택의 흔적 / 돈만 / 사람만 / 둘 다 / 어느 쪽도 아님 / 주
14. 분류 가능한 기록과 복원할 수 없는 옛 주차: 네 칸을 합치면 살아온 주 수가 된다. / 이전 저장의 {n}주는 어느 칸이었는지 되살릴 수 없다.
15. 연락 기록 표제와 빈 기록 상태: 연락 원장 / 기록된 인연 없음 / 기록 없음
16. 먼저 연락한 횟수: 먼저 연락한 횟수  {n}회
17. 마지막 연락의 상대 주차: 마지막 연락  {when} / 이번 주 / 1주 전 / {n}주 전
18. 간직한 물건 목록 표제: 간직한 것들
19. 기록 날짜와 누적 주차: {date} · {weeks}주차

## 소유권

- Plato: `locale/ui_ja.json` 선택52 기존값을 KO 직접 검수·필요 정밀화.
- Rawls: `locale/ui_zh-CN.json` 신규52 KO 직접 저작.
- Poincare: `locale/ui_zh-TW.json` 신규52 KO 직접 저작. CN 자동변환·EN 중역0.
- 비저자 전량: Rawls→JA / Poincare→CN / Plato→TW, 각52. ROOT 통합.
- ROOT: `content/meta/full_game_localization.json`에156/batch1만 추가.
  기존38155/b94/meta9·선택 밖UI key/value/order/raw 보존. JA기존 탭5도 선택 밖 원형 유지.
- 조건부 코드4: `tools/full_game_localization.py`,
  `tools/full_game_localization_self_test.py`, `tools/ja_translation_pipeline.py`,
  `tools/zh_translation_audit.py`. 실제 첫52 L1의 정당한 오탐이 있을 때만,
  actual/자연형/유효 변조/key·source-OFF 및 독립 입력을 코드 전에 봉인해 좁게 수리.
  기존 함수·기대·핀 원형과 최초 실패 보존, 전역 면제/검사 맞춤 산문/전체 문장 허용0.
- 운영: `CLAUDE.md`, `docs/CODEX_QUEUE.md`, `docs/CODEX_QUEUE_L3_PENDING.md`,
  `docs/WORK_LOG.md`, `docs/STATUS.md`, `docs/queue_backlog/FULL_GAME_LOCALIZATION.md`,
  이 사양, `docs/queue_archive/ORDER-235_L1_L2_RESULTS.md`, `tools/audit_scope.json`,
  `docs/agent_review_decisions.json`, `docs/agent_reviews/ORDER-235.json`.
- ROOT 추가 보관 소유: `docs/history/WORK_LOG_2026-09-07_localization.md`의 아래 exact999B raw prepend만.
- 사적 helper/원문/첫 L1/receipt/검수/QA는 `.git/full-game-localization/order235-*`.
  감사는 기존 full-game-localization-overlays 명시 차선의 사양·보고 경로만 등록한다.
  자동 경로선택·Godot/full/240 확대0.

MainGame/CoreLoopPlanner/LocaleManager/GameState/EndingSystem 및 모든 KO/EN·소비자·
story 조건/효과·설정/사용자 저장·SHIPPING_LANGUAGES·폰트·project·공개/인간 원장은 비소유다.
이 사양은 본문52의 번역만이며 드러난 동적 소비자 결함을 고치는 권한을 포함하지 않는다.

## 의미·소비자 경계

- MainGame.game_over→_show_ending→0마지막 장면/1크레딧/2후일담/3시간 기록/4마지막 장/
  5기록·다음 삶 연결을 소스로 확인했다. 이것은 실제 플레이·도달 실행 증거가 아니다.
- ‘크레딧 뒤로’는 이전으로 되돌아감이 아니라 크레딧 이후로 진행한다. 장면/총 장면 두 슬롯과
  기록 I/II/III를 보존한다. 재시작·메인 메뉴 버튼의 실제 상태 변경은 그대로 둔다.
- 시간 기록은 돈만/사람만/둘 다/어느 쪽도 아님 네 범주의 주(week)다. 원장의 ledger 의미를
  원장(기관장)과 혼동하지 않는다. 이전 저장의 미분류주를 복구 가능/저장 손상으로 발명하지 않는다.
- ‘먼저 연락한 횟수’는 발신 횟수이며 회신·성공한 대화·첫 연락 한 번·상호 약속이 아니다.
  마지막 연락 상대주차·누적주차/date/when/n을 실제 소비 슬롯 그대로 옮긴다.
- 같은 시간 기록 및 종료 버튼의 비보호 문자열은 기존 demo caller에도 공유된다.
  데모 전용 ‘6개월 기록’은 선택하지 않았고, 공개 데모 확장이나 새 언어 공개 GO를 뜻하지 않는다.
- 미호출/불활성 ‘최종 기록’, 조건 비교 operand ‘현실’, 광역 공유 ‘누군가’도 제외한다.
  difficulty 비교에 번역함수를 쓰는 기존 문제는 source/runtime 채무로만 남긴다.
- 업적·칭호/설명·테마·난이도·마스터리·소지품의 동적 삽입값은 템플릿52의 수용과 별도다.
  알려진 테마의 _tr 호출과 다른 KO/EN 직결 소비자를 구별하고 소비자/딕셔너리 추가수리0.
- 엔딩 원문·최종 서명·인물 후일담·서랍 비밀·다음 삶 힌트·공유 본문·능력치/마일스톤 표면은
  이번52에 포함하지 않는다. 시제/생사/관계/해금 사실을 새로 쓰거나 스포일러를 당기지 않는다.
- ‘5년의 기록’ 등의 현 원문을 조기 엔딩 시간과 몰래 정렬하지 않는다. 원문 채무는 별도 기록한다.
  공개 GO/인간 OPEN/본편 HOLD, native/render/실플레이 미관찰은 그대로다.

## 초기 봉인·검증·마감

1. 선언·동기화 뒤 ROOT가 exact full40 HEAD를 인수로 공식 --leaf-ids/--limit52 initial3을
   순차 export한다. 각 파일53 JSONL행/52본문, JA52 previous-present·CN/TW104 null.
   initial/원문·기존raw/보호·코드4/portable를 봉인한 뒤 독립 확인 전 저작0.
2. 직접 저작·각52 최초 translation_errors L1 1회와 모든 진단을 원형 보존한다.
   실제 오류와 정상 표기 오탐을 구분하고 비저자156 전량 KO/consumer/target 대조를 수행한다.
3. 수정된 전체 source/target52records·3L2/digest를 최종 동일본문에 결속한 clean C1에서
   final export/check/import3쌍 changed_files0. initial/source/response/receipt와 이전표면을 보존한다.
4. 신규156/b95와 기존38155/b94/meta9 raw 역복원, UI 비선택과 보호 원형을 확인한다.
   전체수용 hash/L1 1회 및 명시12 차선1회는 ROOT가 최종 조합에 실행한다.
   실패원형과 같은 고정 입력 재검을 구분하고 전체QA를 반복해 분모를 부풀리지 않는다.
5. source-like 문서까지 exact C2에서 비저자 work_unit235 최종 판정.
   이후metadatawrapper만 결속하며 source 신원을 판정원장에서 역추정하지 않는다.
   기존 WORK 38724B/SHA 650aabe63728ce97e30e777694a94bc20c633bf70ef010e73d99aa1cd48e8fb0에서 완료219/220 한 절999B를 기존 history에 raw prepend한다.
   선언 후 WORK 37725B, 완료절 최대 2000B 예약; 합계 39725B ≤40000.
   새 절이 예약을 넘으면 먼저 명시 보관 범위를 재판정한다. 본문 압축/삭제0, WORK EOF2·history 원래 EOF1·이동 원형 역복원을 검증한다.
6. STATUS는 생성·검사하고 main/번역 브랜치는 ROOT가 비파괴 동기화한다.

성공했을 때만38311(JA12769/CN·TW12771)/b95/meta9다.
156=기존JA52검수+CN/TW신규104이며156신규 저작이라고 부르지 않는다.
자동 회귀는 재미·문체·원어민 승인과 다르다. 전체UI/본편완료율·public/full/native GO를 발급하지 않는다.
승격: 지속 규칙은 기존 I18N/WORK_UNIT 정본. 이번19단위·52키/파일/마감은 일회성.
