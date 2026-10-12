# ORDER-573 — 번역값과 내부 난이도 ID 비교 수리

#### [x] ORDER-573 [P1·현지화 소비자] 완료 — 2026-10-12

기준8831ab245962e28a1be39e0abecd41df9f540102/tree
ef4936ca788ecd5bd4eb70ae52387bd88760064e의 확인된 결함 한 건이다.
DECISIONS 2026-06-30의 단일 시작/기본 현실·구저장 난이도 보존을 따른다.
선행572 CI38234550774는10:40:44Z in_progress/null, 완료를 추정하지 않는다.
M17/562 OS잠금 HOLD 하나·새 월0을 유지한다.

## 깊이 3문·정확한 범위

1. 기본 ID 현실을 번역값 現実와 비교해 일본어 엔딩 상세와 복사 기록에만
   불필요한 난이도 행이 나타난다. community 번역값도 같은 문제를 만든다.
2. 두 소비자의 조건만 안정적인 저장 ID 현실과 직접 비교한다. KO/EN 기본행
   숨김과 legacy 드라마/지옥고 행 표시는 유지한다. 밸런스/엔딩 선택/저장0이다.
3. 표시 문구는 그대로다. 오직 비교에 쓰이던 UI 현실 키1개는 소비자가 없어지며
   JA 사전의 고아 멤버 현실:現実 하나를 함께 제거한다. 해당 accepted/batch는
   세 언어 모두0이다. 더미 소비자/extra-key 면제/이력 핀 변경을 만들지 않는다.

## 소유·병렬

- root: scenes/MainGame.gd의 _ending_add_unlocks와 _run_card_text 조건2줄,
  locale/ui_ja.json의 위 고아 멤버1개, tools/english_hangul_audit.py의
  정확한 내부 ID 비교2형태 면제와 기존 self-test의 좁은 양성/반례만.
- root: 큐2/이 사양(마감 archive)/CLAUDE 현재행/WORK_LOG.
- manual_save_ci: 읽기 전용 독립 소비자·diff·5언어×3ID/변조 번역값 source
  검토 및 private review만. 저자가 아님.
- rework_batch_plan: private before/final 보존·Git 비소유/JA inverse 검토만.
- mod_layer_ci: 선행/새 CI actual snapshot 한 번씩, private 증거만.

content 원문/EN/CN/TW/원장/accepted/manifest/pin·GameState/LocaleManager·
project/presets·저장/설정·공개 데모/과거 인간 판정/옛 raw/seed/app은 비소유다.
새 도구·등록·검증 비용/재사용 최적화·새 월·엔진·실제 입력0이다.

## 표적 수용·증거 경계

선언 commit/push 후 수정한다. 기존 audit_select 영향 목록85는 전체 실행 명령이
아니다. 이 변경은 엔딩 라우팅/스키마/스케줄러가 아니라 두 표시 조건만이므로
전체 audit/240주는 실행하지 않는다. EN_HANGUL/self-test·JA UI·ZH skeleton·
i18n coverage·full localization inventory·demo localization all/story demo·
context/queue/diff를 표적으로 실행한다. source collector에서 현실 잎만 빠지고
나머지 source 잎·accepted/batch·데모 계약은 유지되는지 독립 확인한다.

원결함은 실제 현재 source/JA dictionary로 재현하고, 수정 조건의 KO/EN/JA/CN/TW
기본/legacy ID와 임의 community 번역값 독립성을 source 수준에서 검토한다.
직접 표시/print·다른 변수/문자열·inline 누출은 EN 예외가 거부해야 한다.
신규 실패0·비저자 source/보존 GO 뒤 source 수리 한정으로 닫는다.
컴파일/렌더/native 화면은 OS잠금으로 미실행이며 새 앱 판정이 아니다.
전체 번역 INCOMPLETE·원어민/인간/물리패드 OPEN·본편/출시 HOLD를 유지한다.
기존 강남드림 개발 스킬/I18N 정본을 적용한다. 위 범위·순서·검증은 일회성,
새 규범 승격0이며 내부 ID와 번역 표면을 분리하는 기존 원칙의 수리다.

## 마감 — source 수리 한정

- 선언76078a6178d513e18a44db1ccbe0c2d012f856ab/tree
  c147459182e8f19456f70ea18394d02824f8ba8f를 먼저 commit/push했다.
  실제 MainGame 두 조건만 stable ID 비교로 바꿨고 JA 고아 멤버1개를 지웠다.
  기존 GameState 기본값/legacy fallback/난이도 수치/표시문구/엔딩 분기는 그대로다.
- EN 감사는 MainGame의 정확한 두 비교만 내부 ID로 인정한다. 기존 self-test에
  양성2·누출/다른 변수·값·파일 음성6을 더해41 actual0이다. EN 누출 검사를
  끄거나 일반 한글·출력 문장을 면제하지 않았다.
- 표적8 명령 actual0: EN_HANGUL/self-test, JA UI, ZH all skeleton,
  i18n coverage, full localization inventory, demo localization all, story demo.
  공식 inventory는 default JA 한 언어이며 INCOMPLETE/OPEN·invalid58을 보고한다.
  inventory 실행 성공을 전체 번역/엄격 gate 통과로 바꾸지 않았다.
- 실제 collector 잎17505→17504·UI 호출3478→3476·고유키2981→2980이다.
  현실 잎1개만 없어지고 나머지 잎 SHA256
  84d046326c911443faec8dd1d060ab5033e11f6bae5c55a8ca4811a868beb9d7은 exact다.
  MainGame 바이트 변경에 따른 현재 source manifest는
  c13d47f56851ab9f26567d53a53db1f13e39d5931881f8f1bd2c7ab91a71e19b이다.
  역사 source pin/원장/accepted/batch316은 다시 쓰지 않았다.

| 제품 파일 | bytes | SHA256 |
|---|---:|---|
| scenes/MainGame.gd | 1161076 | cd84426e0b0e2f5c4c307f66a13f558597a9c651de6e1cfff042b7c32143faf2 |
| locale/ui_ja.json | 303345 | ac8f7923c253f62c96a5f574153f62ad0f55eeff94377c04cce82397864bda3e |
| tools/english_hangul_audit.py | 31241 | c52422c4143a0426cb6573280bd4c4516ecdd275aa5ae64b30c755f83ba24dac |

원자료는 .git/order573-20261012/의 실제 tool 반환 targeted-tests.json,
공식 inventory-after.json, collector-before/collector-proof.json과 독립 검수다.
targeted-tests SHA4989d4f3ade6beac278b30151a5f5dad0f075816520cc0212822ba921002059c,
collector-proof SHAf6de7d8f1f769941ef9d5c012cc871ca40a2b242223e3ee2dae346e31a20d78d다.
원결함과 KO/EN/JA/CN/TW×3 stable ID·community 임의값 독립성은 source 판독이며
실제 앱/컴파일/렌더/원어민 판정은 아니다. 전체 audit/240주/엔진/새 월0이다.
기존 강남드림 개발 스킬/I18N 원칙을 적용했다. 일회성/승격0,
전체 번역 INCOMPLETE·원어민/인간/물리패드 OPEN·M17 OS잠금 HOLD 하나·출시 HOLD다.
구현 commit/tree·first-parent/push·새 CI 관측은 commit 뒤 private postcommit으로
실제 신원을 결속한다. 현황판 단독 후속 커밋은 만들지 않는다.

- 독립 source 검수 blocker0·source-only GO다. root가 source-review.md 전문을
  읽었으며 SHA17aca9b00cd9ac6f8c0342086467ac7562e0c998d77d6c68cdd55405600f1d3d다.
  10:56:21Z fresh 보존 검수17/17 true·dirty3 한정GO, 보호51/876·비소유3356·
  old572raw23/원장 전체/accepted/batch316/CN/TW exact다. MainGame/JA/감사기
  전체바이트 역방향도 통과했다. 이후 root의 마감 metadata는 별도 diff로 확인한다.
  root가 preservation-review.md 전문4743B도 읽었다(SHA
  fe8281d68b0ea70435cd7e1bfca49d5d6ab9c62a0bdb0c025061044b880c2eed).
  preservation-final.json SHA는00241e5c871baf11be991b57a378f4b999e200d1e101cd632c71475bf2703f3f다.
- 최초 마감 context 검사는 CLAUDE 18003B/상한18000B로 FAIL했다. 상태 문구만
  줄여 해당 검사를 재실행해 actual0이다. 제품/번역/검사 상한은 바꾸지 않았다.
