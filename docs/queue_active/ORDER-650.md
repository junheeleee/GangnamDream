# ORDER-650 — 실행 없는 고위험 거래를 계획 저장 사실로 맞춘다

#### [~] ORDER-650 [정합] M54 고위험 계획과 마지막 주 회상 — 2026-10-15

649 source 사실 수리 뒤 확인된 선택·후일 회상 수리다. 실제 M18/612만 열려 있고 새 월은 시작하지 않는다.
5언어는 유지한다. 실제 KO/EN 확정 전 JA/zh 다듬기·수용은 하지 않는다.

## 판단 근거와 깊이 3문

현재 arc_endgame_sixmonths choice0은 주문 금액·확인·체결음·시장 결과 대기를 말한다.
그러나 실제 효과는 luck+4/mental−6/tint−2와 기존 seen/final_gamble_taken뿐이다.
대상·금액·수량·포지션·주문·체결·정산 receipt는 없다. 거래를 새로 구현하지 않는다.
WORK_UNIT의 위임된 내부 제품 판단과 비저자 a1의 선행 읽기는 실제 동작에 맞춘
고위험 계획 저장을 권고했다. 이는 없는 거래 기능의 완성·제거가 아니라 거짓 산문 약속 수리다.

선택을 지우면 위험 방향의 결단과 final_gamble_taken 독자를 잃는다.
기존 정신·운·tint 및 후일 flag는 남되 투자 성과나 돈의 이동은 약속하지 않는다.
지킬 계획을 남기는 choice1, 잠시 숫자 밖으로 나가는 choice2와 경쟁한다.
계획을 저장할 때 사용할 돈·감수할 손실·멈출 조건을 적는 행위와 그 떨림만 보존한다.

실제 generic 입구는 MainGame.gd:8468 W216~237, 마지막 generic reader는
_generic_finale_arc_id의 at_turn==240이다. 정상 W216에서 24주라도 늦은 입구는 그렇지 않다.
W239라는 선행 읽기의 추정은 사용하지 않는다. 회상은 마지막 구간 어느 밤의 저장만 말한다.
StoryMode description_if_known은 앞선 true key를 먼저 쓰므로 이 독자가 모든 런에서 보인다고 주장하지 않는다.

## 정확한 소유

root:
- content/events/arc_midgame.json 및 content/events_en/arc_midgame.json:
  arc_endgame_sixmonths choices0.text/result_text 각2잎, 총4.
- content/events/arc_drama.json 및 content/events_en/arc_drama.json:
  arc_final_week description_if_known.final_gamble_taken 각1잎, 총2.

총6잎만. 다른 선택/결과·DK·title·본문·금액·효과·flags·조건·indices·receipt·코드·schema·저장 불변.
final_gamble_taken은 호환용 기존 키다. 기존 저장의 과거 로그 문구는 다시 쓰거나 이주하지 않는다.
JA/zh 원고·번역원장·자산음악·project·사용자 save/설정·공개 데모·과거 인간 판정 불변.
실제 stale인 경우만 content/meta/release_content_inventory.json의 영향 content SHA와
docs/CONTENT_RATING_INVENTORY.md 같은 생성 셀을 정렬한다. counts/IDs/다른 축/public snapshot 불변.
큐2/이사양/archive/CLAUDE 현재행/WORK_LOG/.git/order650-20261015/ root 소유.
독립 a1_qa_release_audit는 해당 private review.md/json만. 제품/Git/engine/UI/새 agent 쓰기0.
612의 기존 dirty4는 모든 커밋에서 제외한다.

## 검증과 한계

6잎 전수 map·KOEN 의미·문단/name·의도 숫자 제거·4원고 inverse byte exact.
audit_select --list는 선택만. audit/consistency/ENcoverage/영어한글/spine/chapter5/continuity/release 표적8.
최종KO 기준 공식 JA/CN/TW inventory 각1회, 번역 수용0/다듬기0.
context/queue/diff0 및 정확 staged path, 기존 효과/flags/호환 불변을 확인한다.
engine/전체 audit/자연240/새checker/최적화/비용계측0.
독립 GO는 source 사실 수리만이다. 실제 M54/M18·native·전체경제·전체 후일 체인·구로그 문자열·5언어·출시 HOLD.
M55EN1잎/M56KOEN4잎·최종주 다른 DK는 후속 별도 범위다. 이번에 붙이지 않는다.
일회성 수리·새 정본 승격 없음.
자동 게이트는 도달 가능성과 계약 충족의 증거이지 재미·깊이·문체의 증거가 아니다.
