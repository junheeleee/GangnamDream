# WORK_LOG.md — 강남드림 작업 기록

이전 원문 전체는 [2026-10-04 구직 메뉴까지의 기록](history/WORK_LOG_2026-10-04_pre_order405.md)에 바이트 그대로 보존했다.

## 2026-10-04 (Codex — 승진 안내의 숨은 확률 비노출 수리 착수)

- [406](queue_active/ORDER-406.md) 선언 b615316을 main에 먼저 푸시했다.
  MainGame 한 줄 checkpoint cd42885: 대상 자격만 표시하며 35% 확률 노출 제거.
  승진 조건·실제 계산·JobSystem 불변. 중간 checkpoint는 완료 GO가 아니다.
- 일본어·간체·번체 새 3문구의 사전 독립 의미검수와 공식3교환 수용 완료.
  export/check 각3언어 PASS, UI JA3044/CN1467/TW1467·원장41122/b176.
  old JA 문구·기존 receipt/header 불변. 실제 화면·영향 검수는 다음 후보에서 진행한다.
  연결 도구 6파일·실제 5언어 한 줄 화면 검수·독립 검토는 파일 소유를 나눠 병렬화했다.
  원어민·인간·물리 관측 및 본편/새package 승인은 그대로 남는다.

## 2026-10-04 (Codex — 돈·투자 안내 중문 실제 소비 검수)

- 플레이어 개선: 첫 월급·상철 대화의 투자 잠금, 직업별 부업명·9만원 보수,
  투자/절약 효과·무료시장분석 안내를 CN/TW로 읽을 수 있다.
- [405 완료](queue_archive/ORDER-405.md): source5958417·32값·공식2batch.
  UI1466키씩, accepted41119/b173. 8PNG/32lookup/72binding,
  22cards82px·modal190/card154 strict-fit. 최장preview343/348px·잘림면제0.
- CN 월세 용어를 月租로 수리하여 CN만 재검사. 첫 화면검사 실패는 실제market
  money축을 helper가빈값으로오독한 원인; 제품수정 없이 새r1로14.857초PASS.
  원본실패와원본helpers를 보존하고 전체8PNG 독립 직접읽기 수행.
- source/player34/helper26 및8typed복원·warmupdelta0. 원어민·인간·물리패드,
  자연취업/진입/Back·실제행동은 미관측. 공개GO1·인간OPEN45·본편/새packageHOLD.
- normal11종+조회1 PASS666.615초·source2,971파일/helper27불변.
  [독립 보고](agent_reviews/ORDER-405.json)에 현재 후보·실패·원본SHA를 결속했다.
- 일회성 사양이며 상시규범 추가0. 다음 [406](queue_active/ORDER-406.md)은
  승진 안내의 숨은정확확률 노출만 KO/EN/JA/CN/TW에서 수리한다.

## 2026-10-04 (Codex — 돈·투자 모달 중국어 안내 착수)

- [405](queue_archive/ORDER-405.md): CN/TW16키씩32값 공식2교환 수용, 8화면 검수 전.
  기존 기록은 무손실 이동했고 신규 역사파일은405 새 source 후보에 포함한다.
  전체판/새packageHOLD·인간OPEN45·공개GO1 보존. 완료 판정은 독립검수 후 별도기록.
