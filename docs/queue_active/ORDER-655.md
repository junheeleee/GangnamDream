# ORDER-655 — M58 다은 기억물의 실제 글귀와 잘못 센 개수 정합

#### [~] ORDER-655 [정합] 같은 포스트잇을 원문대로 회수 — 2026-10-15

654 source 사실수리 뒤 M58 artifact_daeun_note 정합4잎만 고친다.
Mac 잠금중 같은 M18/612 실제 재검수 HOLD·열린 실제월1/새월0.
5언어 유지·KOEN 실제확정 전 JAzh 다듬기중단/누락만·번역수용0.

## 근거·깊이 3문

content/items.json:22 원문 '밥 먹고 다녀.'는 공백/문장부호 제외5음절인데 세 글자라 한다.
DataRegistry.gd:253 EN 'Eat properly.'는2단어인데 Three words라 한다.
arc_daeun_04_morning choices0:491 item생산·MainGame.gd:7868 t>=76/chose_her.
MainGame.gd:7929..7935 married/wedding_day/used_as_means/notdivorced/notseen
뒤 final_choice→kitchen/name→decision choices2는 item을 요구한다.
KO consumer:366은 실제 item과 다른 '잘 챙겨 먹어요.'를 인용하며 세 글자를 재차 말한다.
EN consumer:102는 quote는 같지만 Three words/those three words를 반복한다.
기억물 장면을 지우면 현재 서명 포기와 과거 돌봄의 구체적인 회수를 잃는다.
실제 item문구를 보존하고 같은 글귀로 회수한다. 기존서명/포기/유물경로3선택과
효과 mental20/tint10/affinity22 및 flags/item보유/후일차이는 바꾸지 않는다.

## 소유·검증

root content/items.json artifact_daeun_note.description 1잎:
실제 quote 보존·세 글자→짧은 글귀(숫자5로 바꾸지 않는다).
autoloads/DataRegistry.gd ITEM_TEXT_EN.artifact_daeun_note.description 1잎:
실제 quote 보존·Three words→A short note(숫자2로 바꾸지 않는다).
content/events/arc_daeun_married.json 및 content/events_en/arc_daeun_married.json:
arc_daeun_final_choice_decision choices2.result_text 각1/총2잎.
KO인용은 item원문으로/잘못된 두개수지칭은 비수량글귀로, EN은 비수량words로.
다른 문장·기간(서랍 보관 몇 년은 미확정/이번에 수리 주장0)/문단/name/선택·효과·조건/
flags/itemgive·음악/자산/코드함수/schema/저장·JAzh·번역원장·사용자save설정/project/demo/human 불변.
실제 영향시에만 release_content_inventory contentSHA/동일 생성문서셀 정렬·기타축/수량/공개exact.
큐2/active/archive/CLAUDE현재행/WORK_LOG/.git/order655-20261015/ root 소유.
비저자 a1_qa_release_audit는 private review.md/json만·제품/Git/engineUI/새agent쓰기0.
612 pending dirty4 및 WORK_LOG suffix3555B 모든커밋 제외·바이트보존.
audit_select --list 선택만·audit/consistency/ENcoverage/영어한글/spine/continuity/release 표적7.
4잎 full inverse·DataRegistry단일문자열/다른코드 exact·공식JA/CN/TW inventory각1/수용0.
context/queue/diff0·고정제품commit/tree/핀·독립4잎 전수 source사실 한정검수.
engine/전체audit/자연240/새checker/비용·최적화0.
실제M18/M58/native/전체부부·관계체인/5언어/352선행/출시 HOLD.
M59~60 본문은 다음읽기·이번 범위추가0. 일회성수리·새정본승격0.
자동 게이트는 도달 가능성과 계약 충족의 증거이지 재미·깊이·문체의 증거가 아니다.
