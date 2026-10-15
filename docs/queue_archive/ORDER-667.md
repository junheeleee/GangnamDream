# ORDER-667 — 사실 수리 뒤 KO/EN 장면 감각 복원

#### [x] ORDER-667 [산문·정합] PR #33의 44곳을 한영으로 다시 읽는다 — 2026-10-15

사용자 직접 지시: PR #33 main 병합, E절 문안과 A~D 대안을 KO/EN에 적용하고 목록 44곳을 재검토한다. 앞으로 사실 수리의 빈자리에 현재 장면의 감각 하나를 넣는다.
PR 병합 abda6a7. 모집단은 [검수 문서](../queue_backlog/PROSE_FLATTENING_REVIEW_2026-10-15.md)의 표 순서와 E절이다.

## 근거·깊이 3문

허위 과거를 지우는 과정에서 현재 장면의 긴장과 인물 행동까지 사라졌다.
통째 삭제하면 선행 선택이 남긴 몸·사물·침묵의 회수도 사라진다.
24주 뒤 상태 차이와 같은 자리의 경쟁 선택은 기존 flags/effects/독자가 소유하며 이번에는 산문만 고친다.
DIK는 실제 생산 선택을 대조한다. 목표 달성·생사·관계·주거를 새로 단정하지 않는다.

## 배치 A

표 1~22번 KO/EN 전수. 사실·장소·채널·인물의 지식은 유지하고, 추상 회상·부정 헤지로 채운 자리를 현재 장면의 감각·행동으로 고친다. 이미 구체성이 살아 있으면 유지 이유를 기록한다.

## 배치 B

표 23~44번 KO/EN 전수와 승인된 E절의 선택 text/result_text 및 final_gamble_taken 회수 각 한 쌍. E는 승인 문안을 쓰고 실제 거래·예약 기능을 만들지 않는다. A~D 대안은 해당 잎에 적용하며, 실제 정본과 충돌하는 사실이 발견되면 근거와 수정 이유를 명시한다.

## 정확한 파일 소유권

- content/events/ 및 content/events_en/의 arc_daeun_extension.json, arc_drama.json, arc_events.json, arc_hyunsu.json, arc_midgame.json, arc_year3_drama.json, arc_year_close.json: 표의 잎만. E의 선택 text/result_text 두 잎은 arc_midgame, final_week 회수 한 잎은 실제 소유 파일 arc_drama에 추가한다.
- content/endings.json, content/endings_en.json: crypto_ghost description, empty_house description_if_known/father_passed만.
- docs/SCENE_TIER.md 공통 산문 계약에 지속 규칙 승격, docs/DECISIONS.md 이유, CLAUDE.md 현재 상태, docs/WORK_LOG.md 이번 항목, 큐의 이번 행·active/archive 사양.
- 실제 내용 SHA가 바뀌면 content/meta/release_content_inventory.json 및 생성 docs/CONTENT_RATING_INVENTORY.md의 내용 지문을 정렬한다. 문장 변경으로 키워드 탐색 후보가 달라지면 관측 count·file count·ID 지문도 함께 정렬하되 사건/엔딩 roster·공개 후보·정성 내용축·등급 판단은 불변이다. 새 ‘입술을’의 ‘술을’ 부분일치도 후보 관측일 뿐 실제 음주 추가가 아니다.
- 사적 검수·대조 증거: .git/prose-review-20261015/. 새 검사 도구·오더별 상설 보고를 만들지 않는다.

조건·효과·flags·선택 순서·DIK 순서·엔딩 라우팅·자산·저장·경제·공개 데모·project.godot·JA/zh·번역 원장은 불변. 시작 시 dirty M18 4파일은 별도 바이트로 보존하고 커밋에서 제외한다.

## 검증·판정

44쌍과 E 3쌍의 전수 의미·KOEN·실제 생산자/독자, changed JSON path 및 비산문 데이터 불변 대조. 독립 검수자는 자신이 쓰지 않은 범위 전수 읽기.
context_manifest_check, queue_consistency_check, audit_select --list 뒤 기존 영향 비엔진 검사, en_coverage_check, diff --check. JA/CN/TW official inventory는 변경 검출만 관측·수용0.
자동 게이트는 도달 가능성과 계약 충족의 증거이지 재미·깊이·문체의 증거가 아니다.
실제 앱·원어민·물리 패드·출시 판단은 미관찰. 같은 M18/612 HOLD와 공개 데모 GO를 보존한다.
지속 규칙은 SCENE_TIER 공통 산문 계약 소유, 나머지 파일 범위·배치·증거 지시는 일회성이다.

## 마감 — 2026-10-15

PR #33 main병합 abda6a76c4f3ad49aecf28881e224fce463563af, GitHub closed/merged=true.
선언보완978e22d39bf682cc28d1fc2af6187775ad647a61 뒤
제품88cd5fa4580df65323ba12c3dff1e63514a4e7d7/tree d168f4925a460f07ec80932176ce9da2e0b69f7d를 main에반영했다.
표44쌍/KOEN88잎 전수:42쌍수리·2쌍유지(표28 result/표43 crypto base).
승인E3쌍별도적용:총47쌍/94잎, 변경45쌍/90scalar·유지2쌍.
A/B 승인KOexact·EN정렬, C/D미생산과거만현재감각으로좁힘·E한영exact.
실제생산선택/장소/지식경계와함께독립47/47 source품질GO/차단0.
원고16파일inverseexact·비산문/선택/DIK/flags/effects/경제/저장불변.
제품20은원고16+정본2+release2이며 공개demo/JAzh/번역원장/project불변.

승격: docs/SCENE_TIER.md 공통 산문 계약.
지운허위사실의빈자리를현재참인감각하나로채우고 생산선택을회수한다.
DECISIONS는이유/소유자링크만·나머지오더범위/증거지시는일회성.
개발스킬의표적·독립·보존 및장면계층의사실·감각경계를적용했다.

최종후보비엔진표적9 actualexit0: 인계final6+release1+본문수정후continuity/distinctness2.
공식afterinventory3 actual0·supportcontext/queue/diff0·selection89목록만.
초기check5/6/8/10/11/12는최종후보실행으로승격0.
strictProseRecall의동결JA정합실패first-fail1줄은보존·source-only40/40과구분.
실패잎총수미확정(보고의미증명3건문구는삭제교정·제품/검사불변).
release초기지문/후보실패도보존했고실측SHA/count/ID/noise/생성보고만정렬했다.
입술의술부분일치는음주사실이아니다. 공개roster/정성내용축/등급불변.

manifest65224b25ac1fb8bfbf16450bf735a8efc483b51b59c99951a9ab2bab5f21ce0c,
CJK invalid JA120→135/CN50→70/TW48→70·해결0·INCOMPLETE/nativeOPEN/수용0.
번역다듬기0·5언어/실제앱GO아님. E남은반년의지연입구W216~237우려는
정상반례미폐쇄·승인문안자동변경0/미확정잔여로보존한다.

root최종품질2/증거2보고전문과제품20·증거36핀재대조PASS.
.git/prose-review-20261015/final-prose-review.md14904B/624aee05bebf11ca413b84d1a1c7aae124df5afc1766a756a7ecca0725e5521b;
final-prose-review.json5774B/34da2d2936a7e59673747d70915f232dc542715f57bd4d909095ab7f958fc173.
final-evidence-review.md11331B/5355b3e1732ea643874f78e0668833907611932306f79a696f41df26ecc60fab;
final-evidence-review.json24979B/28e8b61045e0ed2173a9b6704bc2114e485e404c5e2e1c2714365e8503cea23e.
해당JSON이제품/사양/population/교차보고/원실패/원출력/raw3/보존을결속한다.
초기root inventory키/EN파일명대조오류2도원인과교정기록보존·원고/도구수정0.
중단된같은작업의원고를이어받았고확인된기존완료검사는이유없이반복0.

M18/612 dirty4와suffix3555B/a9da54e58a91283d1732eae4d0581400cf8dc499274eb1b8aa2ec95c3a7c693b
commit제외·바이트보존. 이월새실제관찰/마감commit0·열린실제월1/새월0.
CG세션잠금true·engine/native/전체audit/자연24·240/새checker/설정변경0.
실제M18/엔딩전체/원어민/물리패드/5언어/출시/CI전체녹색은HOLD·미관찰.
자동 게이트는 도달 가능성과 계약 충족의 증거이지 재미·깊이·문체의 증거가 아니다.
