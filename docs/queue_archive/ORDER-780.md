# ORDER-780 — 본편 선택 방식 간체·번체 UI

#### [x] ORDER-780 · 선택 방식 중국어 UI

부모157/C5. `locale/ui_zh-CN.json`·`locale/ui_zh-TW.json`의
투자 중심/인연 중심/원칙 우선/꾸준한 생활 4개씩만 신규 append.
MainGame의 진행 화면·엔딩 기록의 기존 선택 방식 조회만 채운다.
기본 자유 선택은 두 소비자 모두 표시하지 않아 비소유. 일본어 기존값 유지.
원장·큐·현황·기록·독립 보고 외 코드·KO/EN·공개 데모·저장·언어 선택 변경0.

제품 `8f16dd9f268029201b9c07b1f39e7ae3b5c54b09`, check/import 4×2,
four-file append delta·Git history proof·데모/EN 통과. UI 신규8/본문 정정0.
제품 CI41841440573 진행 중, 실화면 미관측. [독립 검수](../agent_reviews/order780-approach-ui-cjk.md).
