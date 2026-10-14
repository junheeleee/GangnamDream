# ORDER-628 — 본편 월초 경제의 저장 경계 수리

#### [~] ORDER-628 [저장 정합] 착수 — 2026-10-14

실제612/M18의 첫W73에서 HUD−657만원/정신77과 디스크−6371703/정신87이
달랐다. 월말값은 정상1회이며, 달력autosave 뒤 _begin_month의 월초경제가
계산되고 선택전StoryMode CmdQ는 autosave하지 않는 순서가 원인이다.
화면만원반올림으로 정확돌발지출액수는미관측·약20만원이다.
발급9dea518f와현재a5b36d6의관련6파일byteexact를 독립상태검수자가확인했다.

## 깊이3문·한정범위

플레이어가 이미 본 월초 현금·정신/시장/뉴스 상태가 다음Continue에서 다시
추첨되지 않도록 한다. 계산을 지우거나 숫자/확률/원문/저장스키마를 바꾸지 않는다.
full-story의 정상calendar advance+complete_turn 뒤, 기존 durable calendar save
직전에 새달 첫주 경제를 계산한다. 이후 _begin_month는 기존marker로 inert다.
실패 재시도는 기존 full_story_calendar_save_pending 소유의 저장만 재시도하며
경제/RNG를 재실행하지 않아야 한다. StoryMode 전역종료저장은 확장하지 않는다.
이로써 월경계직후coldContinue와 저장실패재시도까지같은결과가이어진다.

root 소유: scenes/MainGame.gd의 _full_story_advance_week 한정 호출순서,
큐2/이사양/archive·CLAUDE현재행/WORK_LOG·.git/order628-20261014/ 새표적증거.
a1_state_economy_audit 소유: tools/ManualSaveCheck.gd의 기존 full-story production/
third-month/calendar-save-retry fixture 내 월초disk/live/marker/RNG회귀 assertions만.
m17_native_admission 또는 비저자검수자: 새독립source/보존보고만, 제품쓰기0.
서로소유파일교차쓰기0·기존checker재사용/새영구검사·self-test·비용사업0.

## 검증·완료경계

기존 full-story production/third-month/calendar-save-retry/월초inert의 관련표본을
검수 전 실제읽고 사용자HOME·3XDG·실제Godotuserdir·recoverylock을 격리한
검증에서 실행한다. 성공marker+stdout/Godot로그의parse/script/engine오류0을
함께확인한다. 정상월경계disk/live경제exact·marker==targetturn, failedsave후
저장재시도의RNG/상태불변·이어진_begin_month inert가 필요하다.
표적resolver목록은실행과구분·전audit/240주·정산/시장원문대량검사중복0.
게임원문/번역/효과·정산수치·저장schema·공개데모·사용자설정저장·project 불변.
source수리GO는 실제새앱검수GO가아니다. 612한달기록은이번선언/제품commit에서
제외하고, 새후보발급후 같은원W69→첫W73 실제재검수와한commit마감을이어간다.
다음월플레이0·CI빨강일때새월0·5언어/인간/원어민/패드/청취/출시HOLD유지.
이번지시는일회성·승격0. 자동 게이트는 도달 가능성과 계약 충족의 증거이지 재미·깊이·문체의 증거가 아니다.
