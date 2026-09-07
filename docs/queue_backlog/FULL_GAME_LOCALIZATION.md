# Full-game localization — remaining scope

2026-09-07 사용자 직접 지시로 M01~M60의 일본어·중국어 간체·번체 번역을 시작한다.
현재 실행 배치와 우선순위는 `../CODEX_QUEUE.md`, 지속 규칙은
`../I18N_INFRASTRUCTURE.md`가 소유한다. 이 문서는 큰 활성 오더가 아니라
누락 없이 후속 15~25단위 배치를 고르는 전체 범위 지도다.

- 사건: packaged 1,813개/12,415 leaf. shipping 1,708/11,674와 author-only
  105/741을 따로 계측한다. 133개의 Chapter5 reader text도 포함한다.
- 엔딩: 35개/268 leaf, 조건별 변형을 포함한다. 첫 배치의 세 root 이후 나머지를
  누락 없이 원문 대조한다.
- catalog: assets/jobs/items/achievements/clues/thoughts/news 7섹션/834 leaf.
- UI: 정적·문맥 key와 동적 pair를 합집합으로 계측한다. 기존 demo 동적 701키만
  본편 전체 동적 분모인 것처럼 사용하지 않는다.
- runtime: 대상 언어 overlay가 모든 수집 필드를 실제로 읽는지, 조건별 reader,
  돈/이름/주거/뉴스/연말/후일담의 영어 직행 경로가 남는지 별도 배치에서 수리한다.
- QA: source/target 완전성, 지역 문자·금액·토큰·문단, 한글/영어 누출, save/resume,
  지역 primary 폰트, 1280×800/960×600 실제 화면을 대상 언어별로 검증한다.
- 출시: 번역 텍스트 수용은 원어민 자연스러움이나 본편 재미 GO가 아니다. 기존
  M01~M06 공개 데모를 덮지 않고 별도 전체판 후보에서 검토한다.

배치마다 완료·미완료·source 변경으로 낡은 번역을 분리한다. 한국어에 새 텍스트가
생기면 그 source hash만 재번역 대상으로 되돌린다. 영어 중역이나 간번 문자 변환을
새 독립 번역으로 세지 않는다.
