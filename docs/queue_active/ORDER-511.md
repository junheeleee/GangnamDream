# ORDER-511 — 중국어 구직 준비·지원 결과 UI20키

#### [~] ORDER-511 [전체 현지화] CN/TW 기존 UI40값 — 2026-10-09

착수 — 만지는 파일: locale/ui_zh-CN.json·ui_zh-TW.json 신규20키씩,
content/meta/full_game_localization.json 해당40영수증·배치1. 운영 파일은
큐/L3·본 사양/완료archive·WORK_LOG·CLAUDE 마지막 갱신·생성STATUS만.
게임원문·조건·수치·runtime/경제/저장·기존 번역/JA·도구는 비소유다.

## 단위 / 깊이 3문

- 지우면: 준비 평가의 실제 반응, 지원 대기·실패·취업 결과와 경력 잠금이 영어로 남는다.
- 24주 뒤 상태: 번역은 상태를 바꾸지 않는다. 기존 지원 결과/준비 보너스의 의미를 보존한다.
- 경쟁: Mac잠금으로 실제 W200 재로드가 막힌 동안 부모157의 현재 미번역 UI만 채운다.

기준Git a9db2f07b76282a34a47a630c7723624f1c860be,
source manifest f81a37c4ad465a404e3f0fdf842af6342ae4e9c21cafccb39a4982c17c119c0b.
MainGame._job_hunt_quality_result11830~11839의8문장,
_ap_job_hunt15992 대기1, _on_job_selected19751~19799의6키,
JobSystem.apply_for_job45~56의4키와 get_available_jobs104 경력잠금1 =20키.
현재 CN/TW동시미존재·JA존재·protected=false·builtin_overlay_static_only다.
아래 exact 목록과 공식 source batch가 선택을 결속한다.

1. 첫 장을 넘기기 전에 지우고 다시 쓸 문장이 더 많이 보였다.
2. 빈칸은 메웠지만 두 번째 장에서 다시 손이 멈췄다.
3. 지원서는 끝까지 읽을 수 있는 모양을 갖췄고, 고칠 문장 몇 개가 남았다.
4. 첫 문장과 마지막 경력이 한 사람의 이야기로 이어졌다.
5. 첫 질문 뒤에 준비한 문장이 끊겼고, 빈 의자만 오래 보였다.
6. 마지막 답은 끝까지 갔지만, 문을 나선 뒤 한 문장이 계속 걸렸다.
7. 면접관은 다음 질문 전에 지원서를 한 번 더 넘겨봤다.
8. 면접관은 종이를 덮지 않고 다음 출근 가능 날짜를 물었다.
9. 이미 지원서를 보냈다. 연락을 기다리는 중이다.
10. 지원 조건을 다시 확인하세요
11. 지원할 수 없습니다
12. `  (준비 보너스 +%d 업무능력)`
13. 구직활동 → %s 취업%s
14. 첫 취업 — %s  월 %s%s
15. %s  월 %s%s
16. . 준비해 간 서류와 답변은 채용 자리에서도 그대로 쓰였다.
17. . 준비해 간 서류는 채용 자리에서도 그대로 쓰였다.
18. . 연습해 둔 답변은 채용 자리에서도 그대로 쓰였다.
19. %s 취업. 월급 %s%s
20. 🔒 Tier %d 경력 필요 — 낮은 직급에서 먼저 경험 쌓기

## 실행 / 경계

선언commit/push 후 공식 export/check/import. CN/TW는 KO에서 각각 직접 저작하고
private 지역 response만 소유한다. root는 overlay/원장, 비저자는 KO20/실제독자/
40값·원header/SHA2·raw 역상·actual Git을 전수 대조한다. 숫자/순서/추가 보장 없이
평가의 차이·종이/의자/문밖 여운·지원 가능 날짜 질문·준비 보너스/월급·Tier조건을 보존한다.
기존 EN/Hangul·JA UI·ZH·i18n·multilingual·공개/legacy demo 영향8검사,
ui_translation_append·context/queue/diff만 쓴다. 전체audit/240주·새검사/도구/형식보고0.
project/사용자저장/공개M01~M06/shipping language/과거인간판정 불변.
실제폭/입력/원어민/물리패드 OPEN·전체번역 INCOMPLETE·출시HOLD다.
개발 스킬은 선선언·독립 지역 저작/비저자·기존 원장·표적검증에 적용한다.
새규범0/이 절차 일회성. 510의 실제 재로드/전체CI는 별도 OPEN으로 보존한다.
