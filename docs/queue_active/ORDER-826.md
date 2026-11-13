# ORDER-826 — 월말 ScreenshotQA의 CJK 원화 검사

#### [~] ORDER-826 · 월말 ScreenshotQA의 CJK 원화 검사

C3/C5. `tools/ScreenshotQA.gd` 월말 현금 fixture의 기대 원화 표기만 소유.
JA/간체/번체를 정식 검사하고, KO/EN의 정확한 숫자·부호·0 표기 및 기존
레이아웃·포커스 조건을 유지한다. 실제 제품·번역·고정 앱·사용자 저장·공개
데모 불변. 현재는 화면 없는 격리 검사만; 실캡처와 C1 완주는 별개. 일회성.
