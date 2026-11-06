# ORDER-803 — 본편 저장 목록 CJK 장면명

#### [~] ORDER-803 · 본편 저장 목록 CJK 장면명

부모157/C5. 착수 — `autoloads/SaveManager.gd` 요약 조회(저장 당시
언어 읽기), `autoloads/LocaleManager.gd` 순수 표시 투영,
`scenes/StartMenu.gd` 두 슬롯 목록과 `scenes/StoryMode.gd` 슬롯 제목,
`tools/I18nInfrastructureCheck.gd` 표적 회귀만 소유한다.
검증 가능한 본편 수동 장면 기록의 자동 장 제목을 현재 JA/CN/TW
정확 event ID의 리터럴 제목으로 표시한다. 동일 언어·KO/EN·공개 데모·
호환 불가/모드/사용자·불명 기록·미해결 제목은 원표시를 보존한다.
파일 저장/스키마/로드 결과/선택/이벤트/번역 데이터 변경0.
격리 headless로 CJK·예외·원딕셔너리 불변, 데모/EN·독립 검수.
실화면/실제 저장 실행/사람 판정과 별개. 이번 수리의 일회성 범위다.
