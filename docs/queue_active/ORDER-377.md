# Active Queue Spec: ORDER-377

#### [~] ORDER-377 — 알바 화면 지역 글꼴 연결과 정확한 검증 승계

**[~] 2026-09-28 착수 — 만지는 파일: `scenes/ArubaGame.gd`의 local Theme3행, `tools/ui_translation_append.py`, `tools/ui_translation_append_self_test.py`, `tools/order365_ui_receipt_compat.py`, `tools/chapter1_core_loop_v2_causal_ledger_check.py`의 정확 font승계 연결, 필요시 `tools/audit_scope.json` 등록, 큐·CLAUDE현재상태·작업/독립검수 기록.** 376의 번역은 별도 소유다.

## 확인된 결함과 제한

- 원본 `cca9239`의 실제 MainGame 생성 Aruba 동일인스턴스 CN→TW 준비화면에서22노드씩 모두 font_base가 빈 문자열, 공용 FontKit 참조 불일치. 기존 금액/보통 글자도 CN `万/元/准/标/韩`, TW `一/元/般/萬/韓` glyph누락. `.git/full-game-localization/order376-font-first/`에원본FAIL44·exit1·로그·전후hash보존. 사용자저장/소스불변, 입력/자연진입/정산/PNG0.
- JobHunt의 승인된3행과같이 `_ready`에서 local Theme.default_font를 FontKit.ui_regular 공유참조로 연결한다. 전역font·문구·수치·레이아웃값·폰트파일·MainGame·저장·공개데모·배송언어 불변.
- 이3행은 source manifest와 Chapter1 역사핀에 걸린다. 기존핀은 바꾸지 않고 정확한 Git parent/tree/diff1file/old-new blob·SHA 및3행 역삭제를 증명한다. 현재실물/원문leaf는 그대로 관측하며 역사 manifest/핀 비교용 projection만 명시적으로분리한다. 기존374 header와 새376 header는 각 실제source Git에결속한다.
- 임의source변경 허용, raw위조, 다른파일폰트수리, 기존검사기대값완화, 새compat모듈·gameplay시스템 추가0.

## 소유·표적 검증

- root: runtime3행·별도제품commit·실제font/render 실행·기록. compat357: 지정도구 최소수리/자가증거, runtime/번역 비소유. screen_path_probe: private376 관측helper만. r3_route_probe: 비저자runtime/도구/증거검수.
- 깊이3문: 빠지면 실제 중국어가유실된다; 게임선택/상태는불변이다; 화면에서읽어야하는시간/수당/응대문구의동일공간을보존한다.
- 기존strict2locale진단은수리후동일helper재실행. 376의신규100×2 실제화면은공유하되폰트수리증거와번역범위를분리한다. 추가 KO/EN/JA 지역경로·동일참조전환은짧은별도준비관측으로검사하며입력/사람증거로부르지않는다.
- 정확3행proof 양성및rollback/혼합/주변바이트/각행/claim/path/admission/Git객체/재호출실패음성은bounded검사로실행. 변경된append검사기의기존self147도한번회귀하며옛312/1955/689/240주는반복하지않는다. 현재365normal·Chapter1 normal·연관consumer와언어/context/queue/diff표적만실행한다. 전체감사PASS는주장하지않는다.
- source-bound export가원문변경전것이면원본을보존하고새후보로다시export한다. 수용행·옛batch를수정해서최신인척하지않는다.
- 독립 GO는 이font연결work_unit만이다. 공개GO1·인간OPEN45·원어민/물리OPEN·본편/새packageHOLD유지. 전이/모집단/소유지시는일회성,새정본규범승격0.
