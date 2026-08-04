# Active Queue Spec: ORDER-82

> Canonical status and execution order are indexed in `docs/CODEX_QUEUE.md`.

#### [ ] ORDER-82 [P1·현지화 준비] 중국어 간체와 번체를 별도 작품·글꼴·검수 계약으로 준비한다

**사용자 근거 (2026-08-04):** 24주 데모까지 일본어·중국어 준비를 시작하되,
한 편의 소설·영화라는 기준과 한국어 정본을 잃지 않는다. 중국어는 일본어의
결과물을 기계 변환하는 부속 언어가 아니며 중국 본토와 대만의 자형·어휘·관계
말투·문화 설명을 서로 다른 판정으로 다룬다.

> 선행 조건: ORDER-81이 실제 24주 공통 범위·영어 우회 0 계약을 완료해야 한다.
>
> 배치 A — 간체·번체 정본과 엄격 감사 준비:
> `docs/I18N_GLOSSARY_ZH.md`, `tools/zh_translation_audit.py`,
> `content/meta/demo_localization_scope.json`, `tools/demo_localization_scope.py`,
> `tools/audit.sh`, `tools/audit_scope.json`.
>
> 배치 B — 글꼴·사람 판정·완료 기록:
> `autoloads/FontKit.gd`, `tools/I18nInfrastructureCheck.gd`,
> `assets/fonts/FONT_LICENSE_LEDGER.md`, `docs/I18N_INFRASTRUCTURE.md`,
> `docs/QA_CHECKLIST.md`, `docs/human_gates.json`,
> `CLAUDE.md`, `docs/CODEX_QUEUE.md`, `docs/DEMO_FIXLOG.md`,
> `docs/WORK_LOG.md`, `docs/RELEASE_NOTES.md`, `docs/STATUS.md`,
> `docs/queue_active/ORDER-82.md`, `docs/queue_archive/ORDER-82.md`.

이 준비 오더는 중국어 본문·UI 사전을 생성하지 않고 언어를 노출하지 않는다.
SC/TC 폰트 바이너리·OFL·제3자 고지는 공식 파일과 해시를 확인해 한 묶음으로
도입할 수 있을 때만 별도 구현한다. 일본어 폰트가 우연히 표시한 한자를 중국어
출시 증거로 인정하지 않는다.

## 깊이 3문

1. 지우면 간체·번체가 빈 영어 폴백인 상태를 준비 완료로 오인하거나, 일본식
   자형을 중국어 글꼴로 내보낼 위험이 남는다.
2. 지역별 용어·금지형·글꼴 체인·원어민 판정을 분리하면 기계 변환으로 인물
   목소리와 한국 현실을 평평하게 만드는 일을 막는다.
3. 번역 전에 엄격 실패 조건을 만들면 수치·선택 구조를 오버레이가 덮거나 본편
   25~240주까지 범위를 부풀리는 일을 방지한다.

## 배치 A — 두 중국어의 번역 정본과 실패 게이트

- zh-CN과 zh-TW는 한국어 원문에서 각각 번역한다. OpenCC 등으로 한쪽 결과를
  다른 쪽으로 일괄 변환하지 않는다.
- 인명 한자를 근거 없이 만들지 않는다. 공식 한자 표기나 사용자·네이티브 결정
  전에는 영문 로마자 폴백을 준비 상태로 유지하고 출시 정본으로 주장하지 않는다.
- 강남·고시원·전세·원화·한국 회사와 기관, 다은/지연/아버지의 관계 호칭,
  날짜·만/억 읽기, 설교투 금지, 자리표시자·BBCode·줄바꿈 보존을 간체·번체
  필수형과 금지형으로 따로 적는다.
- `--lang zh-CN/zh-TW --strict`는 정확한 24주 사건·선택 구조, 번역 가능 필드만,
  한글·가나 0, 빈값 0, 원화 의미, 지역별 용어, 동적 표면과 영어 우회 0을
  요구한다. 기본 준비 모드는 현재 미번역 수를 숨기지 않고 보고한다.

## 배치 B — 언어별 글꼴 체인과 사람 판정

- 전역 `JP→emoji` 폴백 뒤에 SC/TC를 단순 append하지 않는다. 공유 한자가 먼저
  일본식 자형으로 잡히지 않도록 활성 언어별 JP·SC·TC 폰트 체인을 만든다.
- 프로젝트 소유 SC/TC 폰트와 OFL, 원장, 패키지 고지, 실제 사용 코드포인트를
  Windows·macOS·Linux/Steam Deck에서 검증하기 전까지 두 언어는 비노출이다.
- zh-CN은 중국 본토 원어민, zh-TW는 대만 원어민이 한국어 정본과 직접 대조한다.
  번역투·관계 거리·함축·돈 규모·한국 문화 설명량·자형·줄바꿈을 각각 판정하며
  자동 통과가 사람 GO를 대신하지 않는다.
- 두 사람 게이트는 `claim:zh-CN-demo`, `claim:zh-TW-demo`만 막아 KO/EN 데모
  출시에 영향을 주지 않는다.

## 검증

- `python3 tools/demo_localization_scope.py --lang zh-CN`
- `python3 tools/demo_localization_scope.py --lang zh-TW`
- `python3 tools/zh_translation_audit.py --self-test`
- `python3 tools/context_manifest_check.py`
- `python3 tools/queue_consistency_check.py`
- `GODOT=<경로> ./tools/audit.sh`
- `git diff --check`

## 증거 양식

- `ZH_DEMO_PREP lang=<zh-CN|zh-TW> events=<n>/<all> dynamic=<n>/<all> font=<blocked|ready> shipping=0`
- `ZH_FONT_ROUTE lang=<code> primary=<path> shared_han_jp_first=0 glyphs=<covered>/<required>`
- L3: 지역별 원어민이 한국어 원문과 같은 revision의 정상 속도 24주·분기 replay를 판정한 기록.

