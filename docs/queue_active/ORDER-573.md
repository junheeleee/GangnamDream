# ORDER-573 — 번역값과 내부 난이도 ID 비교 수리

#### [~] ORDER-573 [P1·현지화 소비자] 진행 — 2026-10-12

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

