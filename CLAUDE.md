# CLAUDE.md — 강남드림 (Gangnam Dream)

> **세션 시작 시 이 파일을 가장 먼저 읽는다. 30초 안에 현재 상태를 파악하고 작업을 시작한다.**

---

## 🔴 현재 상태 (매 세션 종료 시 업데이트)

| 항목 | 내용 |
|---|---|
| **단계** | **Metacritic 90 목표 — 스토리/게임성/흥행 콘텐츠 확장 (역할 분담: Codex=외형, Claude=내용)** |
| **최근 완료** | **2026-06-30** — **Codex Tendency Modal Accent Pass**: `A Pattern Emerges` 성향 팝업의 보상 라인이 네온 초록처럼 튀던 문제를 낮은 잉크 계열 accent로 보정. 숨은 모럴 시스템명은 노출하지 않고 성향 보상 안내만 기록장 톤으로 유지. `ScreenshotQA --qa=tendency-en` 직접 확인. |
| **이전** | **2026-06-30** — **Codex Product Genre Copy Trim**: `project.godot` 제품 설명에 남아 있던 `RPG` 표기를 제거해 현재 장르 기대를 `인터랙티브 드라마 / 라이프 시뮬레이션`으로 정렬. 영어 한글 감사 `content_issues=0` 재확인. |
| **이전** | **2026-06-30** — **Codex Opening Cinematic Ink-Line Pass**: 오프닝 시네마틱의 완전한 검은 배경에 아주 낮은 대비의 계좌/영수증형 선 레이어를 추가해 빈 화면 느낌을 줄이고 `Gangnam Ink` 표면과 연결. `tools/audit.sh`, `ScreenshotQA --qa=start-en` 통과 및 첫/마지막 카드 직접 확인. |
| **이전** | **2026-06-30** — **Codex Start Tagline Alignment Pass**: 시작 메뉴 대기 화면의 장르 태그라인을 영어판 `SEOUL STATUS LIFE SIM`으로 본편 스플래시와 통일하고 대비를 한 단계 올려 해외 유저가 읽을 수 있게 보정. `tools/audit.sh`, `ScreenshotQA --qa=start-en` 통과 및 스플래시 직접 확인. |
| **이전** | **2026-06-30** — **Codex Ending Epilogue Source Cleanup**: 엔딩 인연 에필로그 원문 앞의 `👨‍🦳/👩/💜/☕/🏢/📱/🎓` 장식을 제거해 `_ending_plain_text()` 필터 의존을 낮춤. 직접 UI 텍스트 이모지 스캔은 닫기 `✕` 1건만 남음. `tools/audit.sh`, `ScreenshotQA --qa=endings-en` 통과 및 대표 엔딩 직접 확인. |
| **이전** | **2026-06-30** — **Codex Toast Source Surface Cleanup**: 공통 필터에 의존하던 토스트/행동 로그 원문의 `💳/⚡/🤝/🏦/🏠/📖/👔/💾` 표면을 제거. 직접 UI 텍스트 스캔 결과 남은 노출 후보는 닫기 `✕`와 별도 `_ending_plain_text()`로 정리되는 엔딩 원문뿐. `tools/audit.sh`, `ScreenshotQA --qa=ap-en` 통과. |
| **이전** | **2026-06-30** — **Codex Genre Label Alignment Pass**: 시작 스플래시에 남아 있던 `KOREAN LIFE ROGUELIKE`와 현재 제품/정본 문서의 로그라이크 표기를 제거하고 `KOREAN LIFE SIM`, interactive drama / life sim 방향으로 정리. `roguelike/로그라이크` 현재 표면·정본 검색 0건, `tools/audit.sh`, `ScreenshotQA --qa=start-en` 직접 확인. |
| **이전** | **2026-06-30** — **Codex Start Notice CTA Surface Pass**: 시작 전 콘텐츠 안내 모달의 `Understood` 확인 버튼이 순백 웹 버튼처럼 보이던 문제 수정. 어두운 잉크 버튼+좌측 스트립+포커스 테두리로 맞춰 시작 메뉴/데모 CTA와 같은 버튼 질감으로 통일했다. `tools/audit.sh`, `ScreenshotQA --qa=start-en` 직접 확인. |
| **이전** | **2026-06-30** — **Codex Primary CTA Surface Pass**: 데모 종료/위시리스트 주 CTA가 순백 웹 버튼처럼 떠 보이던 문제 수정. `_primary_cta_button()`을 어두운 잉크 버튼, 밝은 좌측 스트립, 얇은 포커스 테두리 중심으로 재정의해 모노톤 고급화 방향과 맞췄다. `tools/audit.sh`, `ScreenshotQA --qa=demo-end-en` 직접 확인. |
| **이전** | **2026-06-30** — **Codex Month/Share Text Surface Pass**: 월말 등급 데이터의 내부 `emoji` 키를 `badge` 텍스트로 교체하고, 엔딩 결과 복사 텍스트의 `👤/💰/🏠/📍/📖/🏆` 표면을 제거. 월말 결산은 `LOG/TOP/RISK` 배지로 유지하고 공유 카드는 plain text 기록장 톤으로 정리했다. `tools/audit.sh`, `english_hangul_audit.py` content_issues=0, `ScreenshotQA --qa=demo-end-en` 직접 확인. |
| **이전** | **2026-06-30** — **Codex Money Burst Surface Pass**: 큰 금액 획득 시 화면에 뿌려지던 `💰/✨` 문자 이펙트를 제거하고, amber/ivory 금속 파편이 짧게 흩어지는 코드 네이티브 이펙트로 교체. `ScreenshotQA --qa=ap-en`에 `ap_en_03c_money_burst` 캡처 추가, `tools/audit.sh`, `english_hangul_audit.py` content_issues=0, 직접 캡처 확인. |
| **이전** | **2026-06-30** — **Codex AP Vignette Surface Pass**: AP 행동 결과 팝업의 `📚/💼/💰/🤝`식 제목과 `💰/❤/🧠/📖`식 효과 라벨을 제거하고 `Self-Dev`, `Money`, `Mental`, `Intelligence` 같은 텍스트 기반 표면으로 통일. `ScreenshotQA --qa=ap-en`에 AP 결과 팝업 캡처를 추가해 영어판에서 한글/이모지 없이 보이는지 확인했다. `tools/audit.sh`, `english_hangul_audit.py` content_issues=0, `ap_en_03b_ap_vignette` 직접 확인. |
| **이전** | **2026-06-30** — **Codex Junpac Games Splash Pass**: 첨부된 JUNPAC GAMES 브랜드 보드 기반으로 첫 부트 스플래시에 퍼블리셔 프리롤 추가. 검정 바탕, amber `J`, ivory `P`, ember red dot, `JUNPAC / GAMES` 워드마크를 코드 네이티브 UI로 구성하고 기존 Gangnam Dream 타이틀 컷으로 자연스럽게 전환되게 했다. `ScreenshotQA --qa=start-en`에 publisher 컷 캡처 추가, `tools/audit.sh`, `english_hangul_audit.py` content_issues=0, 스플래시 2컷 직접 확인. |
| **이전** | **2026-06-29** — **Codex AP Recommendation Surface Pass**: `This Week` 포커스 카드의 추천 행동 원문에서 `📚/🤝/📈/⏰/🏙/💼/🌊`류 표면 아이콘 제거. 추천 문구가 필터링에 의존하지 않고 `Self-Dev or Invest → ...` 같은 텍스트 UI로 직접 렌더되게 정리했다. `tools/audit.sh`, `english_hangul_audit.py` content_issues=0, `ScreenshotQA --qa=ap-en` 및 AP 화면 직접 확인. |
| **이전** | **2026-06-29** — **Codex StoryMode Popup Surface Pass**: StoryMode 관계 변화 토스트와 첫 스탯/호감도 안내 팝업 제목의 `❤/📊` 표면을 제거. `Affinity — Bonds With People`, `Stats & Resources`처럼 텍스트 기반으로 유지해 VN 표면의 모바일 앱 감을 낮췄다. `tools/audit.sh`, `ScreenshotQA --qa=story-en`, StoryMode emoji scan 0건 확인. |
| **이전** | **2026-06-29** — **Codex Controller Hint Surface Pass**: MainGame 선택지/AP 화면의 게임패드 힌트에서 `🎮`, 제한시간 라벨에서 `⏱`를 제거해 Steam Deck/PC 표면이 모바일 앱처럼 보이지 않도록 정리. 패드 힌트는 `[A] Choose [Menu]` 계열 텍스트로 유지하고 타이머는 `Time N`/`남은 시간 N`으로 통일했다. `tools/audit.sh` 통과, `rg "🎮|⏱"` 0건 확인. |
| **이전** | **2026-06-29** — **Codex System Modal Surface Pass**: 월별 호재/위기·스탯 해금·성향 자각 표면의 모바일 emoji와 직접적인 시스템 알림 톤을 제거. 성향 자각 모달을 `A Pattern Emerges`/`습관이 굳어진다` 내면 비트로 재작성하고 전용 낮은 모달 크기를 적용해 빈 목업 패널 느낌을 줄였다. `ScreenshotQA --qa=tendency-en` 신규 스코프 추가. `tools/audit.sh`, `english_hangul_audit.py` content_issues=0, 전용 캡처 직접 확인. |
| **이전** | **2026-06-29** — **Codex VN Choice Effect Surface Pass**: MainGame/StoryMode 선택지 효과 미리보기와 StoryMode 결과 토스트의 스탯 emoji(`💰/🧠/📈` 등)를 텍스트 라벨(`Money`, `Health`, `Mental`) 기반으로 교체. `STAT_INFO` icon 필드를 제거해 VN 핵심 표면이 모바일 이모지 UI로 보이지 않게 정리했다. `audit.sh`, `english_hangul_audit.py` content_issues=0, `ScreenshotQA --qa=story-en` 선택지 화면 직접 확인. |
| **이전** | **2026-06-29** — **Codex Work Modal Surface Pass**: 취업 후 `Work · Career` 모달의 기본 Godot `ProgressBar`를 얇은 커스텀 미터(`_mini_progress_meter`)로 교체하고, `Promotable ✓ / Not promotable ✗` 표면을 `Promotion ready / Below requirement` 텍스트로 정리. 상황 카드의 카테고리 emoji도 KR/EN 텍스트 태그로 교체해 잠재 누수 제거. `ScreenshotQA --qa=job-en`에 `job_en_00c_work_employed` 캡처 추가. `audit.sh`, `english_hangul_audit.py` content_issues=0, Work 모달 직접 확인. |
| **이전** | **2026-06-29** — **Codex Living Modal Empty-State Pass**: AP `Living` 모달이 이사 조건 미달 시 거의 빈 화면으로 뜨던 문제 수정. 현재 주거/월 고정비/현금과 다음 이사 목표/필요 현금/부족액을 비활성 상태 카드로 보여줘 “미완성 빈 모달”이 아니라 다음 목표가 보이도록 했다. 영어 배지 잘림(`Current`)은 `Now`로 축약. `audit.sh`, `english_hangul_audit.py` content_issues=0, `ScreenshotQA --qa=ap-en` Living 모달 직접 확인. |
| **이전** | **2026-06-29** — **Codex Info Panel Monotone Pass**: 정보 패널 하위 탭의 강한 섹션색/관계색/마켓 티커색을 `_info_signal_hex()`/`_info_text_hex()`로 `Gangnam Ink` 무채색 축에 맞춰 낮췄다. Market/Relationships/Keepsakes/Story 탭이 네온·모바일 앱 팔레트가 아니라 기록장 같은 표면으로 보이도록 카드 테두리, 값 바, ticker 보유액 표시(`• KRW`)를 정리. `audit.sh`, `english_hangul_audit.py` content_issues=0, `ScreenshotQA --qa=ap-en` 시장/관계/아이템 탭 직접 확인. |
| **이전** | **2026-06-29** — **Codex Log / Info Panel Surface Pass**: `GameState.action_log` 원문은 유지하되 표시층에서 `_clean_log_surface_text()`와 BBCode 대괄호 escape를 적용해 정보 패널 Log/AP 이번 주 기록/월말 행동 요약에 `✓/💼/📈/🎰/✨`류 플랫폼 이모지가 노출되지 않게 했다. 정보 패널 주거값 앞의 주거 emoji도 제거. `ScreenshotQA --qa=ap-en`에 AP 행동 로그 및 Info Log 샘플을 심어 영어 Steam Deck 표면 직접 확인. `audit.sh`, `english_hangul_audit.py` content_issues=0, AP 캡처 확인. |
| **이전** | **2026-06-29** — **Codex AP Warning + Toast Surface Pass**: AP 상황판 경고의 `⚠/🚨` 표면을 텍스트형 위험 라벨로 바꾸고, 토스트 공통 표시 직전 필터(`_clean_surface_message`)를 추가해 `💾/💳/🔓/⚡/🏦/📈`류 플랫폼 이모지가 알림 UI에 노출되지 않게 했다. `ScreenshotQA --qa=ap-en`에 `ap_en_03a_ap_warnings` 경고 상태 캡처를 추가하고 정상 AP/경고 AP/돈 모달 직접 확인. `audit.sh` 통과. |
| **이전** | **2026-06-29** — **Codex Career Modal Continuity Pass**: 직업 선택/취업 준비도/취업 완료 로그가 직전 Job Hunt 미니게임과 톤이 끊기지 않도록 정리. `✅/📋/🔒/🎉/💼` 표면을 `RESUME READY/MISSING`, `INTERVIEW READY/NEEDED`, `LOCKED`, `First job` 같은 텍스트형 표기로 교체하고, 직업 목록의 네온 초록 요구조건/골드 버튼을 `Gangnam Ink` 저채도 계열로 낮췄다. `ScreenshotQA --qa=job-en`에 work category + jobs missing/ready 3컷 추가. `audit.sh`, `english_hangul_audit.py` content_issues=0, `job_en_00~05+04a` 직접 확인. |
| **이전** | **2026-06-29** — **Codex Job Hunt Surface Pass**: 취업/면접 미니게임을 모바일 앱식 이모지 표면(`🖊/🎯/⚡/✦/✗/★`)에서 중앙 채용 평가표 카드로 재정리했다. 질문/힌트/피드백/결과 등급은 `Grade A~D`, `Strong answer`, `Pressure question` 같은 텍스트 표기로 통일하고 버튼·타이머를 `Gangnam Ink` 무채색 계열로 낮춤. `ScreenshotQA --qa=job-en` 신규 스코프로 이력서 질문/피드백/결과+면접/압박질문 캡처 가능. `audit.sh`, `english_hangul_audit.py`, `job_en_01~05+04a` 직접 확인. |
| **이전** | **2026-06-29** — **Codex Tutorial Surface Pass**: 튜토리얼 오버레이 본문에 남아 있던 플랫폼 이모지(`💡/🎰/1️⃣/🔴` 등)를 표시 직전 `Tip:`/`Warning:`/텍스트 표기로 변환해 영어판·Steam Deck 표면에서 모바일 앱/AI 목업처럼 보이는 신호를 낮췄다. `ScreenshotQA --qa=tutorial-en` 신규 스코프를 추가해 메인 튜토리얼 3장+바카라+슬롯만 빠르게 캡처 가능하게 했다. `audit.sh` 통과, `tutorial_en_01~05` 직접 확인. |
| **이전** | **2026-06-29** — **Codex Start Menu Meta Badge Pass**: StartMenu 내부 `PRESS ANY KEY` 스플래시의 누적 기록/엔딩 도감 진행도를 이모지 문장(`📖 Endings...`)에서 작은 무채색 메타 배지(`RUNS/BEST/ENDINGS`)로 교체했다. 영어 금액 포맷도 `KRW 1240.0M`→`KRW 1.2B`처럼 B 단위를 지원. `ScreenshotQA --qa=start-en`에 `start_en_02a_start_menu_press_any_key` 캡처를 추가하고 해당 화면/메인 시작 화면 직접 확인. `audit.sh`, `english_hangul_audit.py` 통과. |
| **이전** | **2026-06-29** — **Codex Title Collection Surface Pass**: 칭호 도감이 모바일 배지 목록처럼 보이던 `🏆/🔒/🎁` 표면을 제거하고, 해금/미해금/희귀도 정보를 `OWNED/HIDDEN` 무채색 배지 카드로 재구성했다. 칭호 해금 토스트/로그도 플랫폼 이모지 없이 `Title Unlocked` 계열로 정리. `ScreenshotQA --qa=title-en` 신규 스코프 추가 및 `title_en_01_title_collection` 직접 확인(UNCOMMON 배지 잘림 수정 포함). `audit.sh`, `english_hangul_audit.py` 통과. |
| **이전** | **2026-06-29** — **Codex Ending Modal Emoji Surface Cleanup**: 엔딩 모달이 모바일 결과창처럼 보이게 하던 노출 이모지/플랫폼 아이콘을 제거했다. 등급 헤더의 큰 이모지, 인연 에필로그/스탯/다음 런 힌트/발자취/도감/공유 버튼의 `📋/🔁/📊/💰/🏆`류 표면을 정리하고, route identity도 엔딩 카드와 같은 plain label을 쓰도록 맞췄다. QA는 수정 부위 기준으로 `ScreenshotQA --qa=endings-en`만 실행하고 `ending_en_15_ending_stable_success`, `ending_en_14_ending_bankruptcy` 직접 확인. `audit.sh`, `english_hangul_audit.py` 통과. |
| **이전** | **2026-06-29** — **Codex Hidden Moral Surface Leak Fix**: 엔딩 카드에 `Moral Trace`, `Gray/Black/White`처럼 숨은 `MORAL_TINT` 시스템을 대놓고 보여주던 문제 수정. 엔딩 카드의 공개 메타칩은 `Last Home / Path / Final Assets`로 제한하고, hidden moral 값 막대도 목표 자산 진행 막대로 교체했다. 도덕 상태는 앞으로도 색·질감·명암으로만 체감되어야 하며 UI 텍스트로 설명하지 않는다. `ScreenshotQA --qa=endings-en` 직접 확인, `audit.sh`, `english_hangul_audit.py` 통과. |
| **이전** | **2026-06-29** — **Codex Ending Card Surface Polish Pass**: 전용 CG 없는 엔딩 카드가 플레이스홀더처럼 보이던 문구를 보정. `RUN FINALE`→`FINAL RECORD`, 기본 설명문을 등급별 완성 문장으로 교체. `ScreenshotQA --qa=endings-en`의 엔딩별 대표 시드도 보정해 bankruptcy/stable_success 등 카드 내부 최종 자산이 본문과 맞게 표시되도록 했다. ※ 직후 Hidden Moral Surface Leak Fix에서 hidden moral 명시 문구는 전부 제거. |
| **이전** | **2026-06-29** — **Codex Targeted Screenshot QA Pass**: 매번 카지노까지 도는 비효율을 줄이기 위해 `ScreenshotQA`를 수정 부위별 스코프로 분리. `--qa=start-en`, `--qa=story-en`, `--qa=ap-en`, `--qa=demo-end-en`, `--qa=endings-en` 추가. `docs/QA_CHECKLIST.md`에 Targeted Screenshot QA 매트릭스를 추가해 카지노는 카지노/미니게임 변경 때만 돌리도록 운영 기준화했다. 신규 스코프 5종 전부 exit code 0 확인, `audit.sh`, `english_hangul_audit.py` 통과. |
| **이전** | **2026-06-29** — **Codex English Copy Micro-Polish Pass**: 영어 데모 blackbox QA에서 어색하게 보이던 첫 면접 문장 `A job app led to this`를 `A job posting led to this`로 보정하고, 데모 종료 진행률을 `Progress to Gangnam (Seoul's status district): ...` 형식으로 정리했다. `ScreenshotQA --qa=demo-blackbox --lang=en` 통과 및 첫 면접/데모 종료 CTA 직접 확인(종료 시 기존 Texture/RID cleanup 경고만 잔존). |
| **이전** | **2026-06-29** — **Codex Gangnam Meaning EN Onboarding Pass**: 외국인 플레이어가 `Gangnam`을 단순 지명으로 지나치지 않도록 스플래시/오프닝/시작 메뉴/튜토리얼/목표 힌트에 `Seoul's status district`, `wealth, status, arrival` 의미를 짧게 삽입. 과설명은 피하고 초반 표면에서 강남=계급 상승 상징임을 반복 노출하도록 정리했다. `ScreenshotQA --qa=demo-blackbox --lang=en` 통과 및 스플래시/오프닝 최종 카드/시작 메뉴 직접 확인(종료 시 기존 Texture/RID cleanup 경고만 잔존). |
| **이전** | **2026-06-29** — **Codex Month Summary Surface Pass**: 데모 월말 요약 모달의 플랫폼 이모지(`📊/💼/📈/🎯`) 노출을 제거. 월 등급은 `LOG/OK/TOP/HOLD/RISK` 무채색 배지로 표시하고, 행동 로그/목표 진행/경고 라인을 텍스트 기반으로 정리해 기록창과 같은 `Gangnam Ink` 표면 톤에 맞췄다. `ScreenshotQA --qa=demo-blackbox --lang=en` 통과 및 데모 요약 모달 직접 확인(종료 시 기존 Texture/RID cleanup 경고만 잔존). |
| **이전** | **2026-06-29** — **Codex Weekly AP Slot Surface Pass**: AP 화면 `This Week` 카드의 남은 행동 슬롯이 긴 흰 막대처럼 늘어나던 문제를 고정 폭 작은 슬롯으로 교체. Steam Deck/영어 화면에서 행동 횟수 피드백이 로딩바가 아니라 게임 UI 슬롯처럼 보이도록 정리했다. `ScreenshotQA --qa=demo-blackbox --lang=en` 통과 및 AP 루프 캡처 직접 확인(종료 시 기존 Texture/RID cleanup 경고만 잔존). |
| **이전** | **2026-06-29** — **Codex Start Menu Save Slot Surface Pass**: 시작 메뉴 우측 저장 슬롯의 기본 삭제 버튼을 빨간 `Delete`에서 무채색 `X` 보조 액션으로 낮추고, 2차 확인 상태에서만 `Delete?`/`삭제 확인` 위험색이 뜨도록 정리. 첫 화면 시선이 저장 삭제가 아니라 `Start New Story`/계속하기에 남도록 보정했다. `audit.sh`, `english_hangul_audit.py`, `ScreenshotQA --qa=demo-blackbox --lang=en` 통과 및 영어 시작 메뉴 캡처 직접 확인(종료 시 기존 Texture/RID cleanup 경고만 잔존). |
| **이전** | **2026-06-29** — **Codex Demo Record Surface Pass**: 데모 종료 6개월 기록창의 목업감을 낮춤. `📖/📊/▶` 이모지 섹션 헤더를 제거하고, 영어 직업 요약 `Working at Office Worker`를 `Current work: Office Worker`로 보정. 목표 문구도 `Gangnam Dream KRW 3B goal`로 정리. `audit.sh`, `english_hangul_audit.py`, 영어/한국어 `ScreenshotQA --qa=demo-blackbox` 통과 및 데모 종료 CTA 직접 확인(종료 시 기존 Texture/RID cleanup 경고만 잔존). |
| **이전** | **2026-06-29** — **Codex Demo Opening Copy Guard**: 오프닝 카피가 도덕 붕괴를 미리 해설하던 문제 수정. 스플래시/오프닝 마지막 카드는 `KRW 500K → KRW 3B / 5년 / 정답 없음`처럼 표면 목표만 제시하고, 인간성 변화·UI 붕괴는 플레이 중 선택 누적으로 체감되도록 숨김. `audit.sh`, `english_hangul_audit.py`, `LocaleSurfaceCheck`, 영어/한국어 `ScreenshotQA --qa=demo-blackbox` 통과(종료 시 기존 Texture/RID cleanup 경고만 잔존). |
| **이전** | **2026-06-29** — **Codex Demo Opening Promise Pass**: 데모 첫인상 강화. 스플래시 태그라인을 `KRW 500K → KRW 3B / 5년` 중심으로 교체하고, 오프닝 시네마틱 마지막 카드를 `Your next five years begin now` + START/GOAL/TIME 스탯 칩으로 재구성. 영어/한국어 `ScreenshotQA --qa=demo-blackbox`로 스플래시와 오프닝 최종 카드 직접 확인. `audit.sh`, `english_hangul_audit.py`, `LocaleSurfaceCheck` 통과(종료 시 기존 Texture/RID cleanup 경고만 잔존). |
| **이전** | **2026-06-29** — **Codex Demo AP Focus Surface Pass**: 데모 첫 30분 반복 루프인 AP 행동 화면을 Steam Deck/영어 기준으로 보강. `This Week` 카드에 남은 AP를 슬롯으로 시각화하고, 추천 행동 문구의 이모지 노이즈와 어색한 영어 목표 문장을 정리. 직접 행동 카드는 짧은 reveal 애니메이션으로 게시판식 정적 화면 느낌을 줄였다. `audit.sh`, `english_hangul_audit.py`, `ScreenshotQA --qa=surface-en` 통과 및 `surface_en_03_ap_actions` 직접 확인(종료 시 기존 Texture/RID cleanup 경고만 잔존). |
| **이전** | **2026-06-29** — **Codex Gangnam Ink StoryMode Surface Pass**: StoryMode/VN 화면을 `Gangnam Ink` 표면 언어에 연결. 배경에 `background_grade`/`moral_surface` 셰이더를 적용하고, `MORAL_TINT`에 따라 배경 dim·텍스트 박스·이름표·상단 HUD·챕터 카드·튜토리얼 팝업·토스트가 회색/흑/백 축으로 변하도록 정리. 스토리 선택지는 금색/갈색과 작은 효과 미리보기를 제거하고 matte 번호 선택지+패드 포커스+초상화 후퇴 연출로 교체. `ScreenshotQA --qa=surface-en`에 영어 선택지 캡처 `surface_en_02b_story_choices` 추가. `audit.sh`, `english_hangul_audit.py`, `ScreenshotQA --qa=surface-en`, `ScreenshotQA --qa=demo-blackbox --lang=en` 통과(종료 시 기존 Texture/RID cleanup 경고만 잔존). |
| **이전** | **2026-06-29** — **Codex Gangnam Ink Scene Transition Pass**: 전역 `SceneTransition`을 단순 검은 페이드에서 `MORAL_TINT` 연동 전환으로 교체. Gray=matte receipt/page lines, Black=ink edge burn+닫히는 질감, White=차갑고 밝은 clarity fade. 전환 SFX/짧은 게임패드 펄스는 추가하되 BGM은 재시작하지 않도록 `BGMContinuityCheck`로 검증. `ScreenshotQA --qa=transition` 신규 스코프로 `transition_black/gray/white` 중간 프레임 캡처 가능. `audit.sh`, `BGMContinuityCheck`, `AudioAssetCheck`, `english_hangul_audit.py`, `ScreenshotQA --qa=transition`, `ScreenshotQA --qa=demo-blackbox --lang=en` 통과(종료 시 기존 Texture/RID cleanup 경고만 잔존). |
| **이전** | **2026-06-29** — **Codex English Surface + Ending Art Governance Pass**: `ScreenshotQA --qa=surface-en` 신규 스코프로 영어 시작 화면/AP/정보패널/관계/홀덤/경마/정선 카지노 6종/대표 엔딩을 1280×800 일괄 캡처. 영어 엔딩/칭호/이벤트 표면의 `「」` 따옴표를 영어권 표준 따옴표로 보정하고, 전용 CG 없는 엔딩에는 잘못된 배경 이미지를 억지로 붙이지 않는 `Gangnam Ink` 엔딩 카드 UI를 추가. `docs/ENDING_ART.md`, `docs/NEW_ASSET_REQUESTS.md`, `docs/ASSET_GAP_SPEC.md`를 34개 엔딩 기준 P0/P1 CG 큐로 갱신. `audit.sh`, `english_hangul_audit.py`, `CGRuntimeCheck`, `ScreenshotQA --qa=surface-en` 통과(종료 시 기존 Texture/RID cleanup 경고만 잔존). |
| **이전** | **2026-06-28** — **Codex Demo Blackbox Surface QA Pass**: `ScreenshotQA --qa=demo-blackbox` 신규 스코프로 스플래시→오프닝→시작 메뉴→콘텐츠 안내→챕터 카드→초반 5개 스토리→AP 루프→데모 종료 CTA까지 1280×800 양언어 캡처 가능. 실제 캡처 기준 수정: 스플래시 2030s→2026, 구형 금색 로고 제거 후 모노톤 텍스트 로고 통일, 콘텐츠 안내창 중앙 정렬, 데모 6개월 기록 총자산 이중합산 수정, QA 언어 강제 저장값 보정. `audit.sh`, `english_hangul_audit.py`, `ScreenshotQA --qa=demo-blackbox --lang=en/ko` 통과(종료 시 기존 Texture/RID cleanup 경고만 잔존). |
| **이전** | **2026-06-28** — **Codex Minigame Micro-Haptics Pass**: 슬롯 스핀 시작/릴 정지, 다이사이 롤 시작/결과 착지, 경마 마지막 직선/결승 판정에 `AudioManager.pulse_gamepad()` 기반 짧은 촉감 펄스 추가. 다이사이 컵은 rolling 중 시간 기반 wobble/lift로 실제로 흔들리는 느낌을 강화. `audit.sh`, `ScreenshotQA --qa=casino-en`, 기본 `ScreenshotQA` 통과 및 슬롯/다이사이/경마 캡처 직접 확인(종료 시 기존 Texture/RID cleanup 경고만 잔존). |
| **이전** | **2026-06-28** — **Codex Steam Deck/English Surface QA Pass**: 1280×800 영어/카지노/데모 표면 QA를 재실행하고 직접 캡처 확인. 영어 정보 패널 주거명이 원시 ID `goshiwon`처럼 보이던 것을 UI 전용 `Goshiwon Room` 표기로 보정하고, `ScreenshotQA` 정보 패널 캡처가 타이핑 도중 잡히지 않도록 `_finish_typing()` 안정화. `audit.sh`, `english_hangul_audit.py`, `ScreenshotQA --qa=casino-en`, `ScreenshotQA --lang=en` 통과(종료 시 기존 Texture/RID cleanup 경고만 잔존). |
| **이전** | **2026-06-28** — **Codex Casino Tactile Pass**: `AudioManager.play_delayed()` 추가로 카지노 카드/칩 SFX를 순차 재생 가능하게 했다. 바카라는 베팅 칩 이동·코인 SFX·약한 진동·좌우 카드 슬라이드 인, 블랙잭은 첫 딜 순차 카드 SFX·베팅/더블/스플릿 칩 이동·딜러/플레이어 카드 슬라이드 인, 홀덤은 블라인드/콜/레이즈/보드공개/쇼다운 SFX를 카지노 계열로 보정. 빅휠/룰렛 하단 결과 메시지 겹침 수정. `CompileCheck`, `ScreenshotQA --qa=casino-en` 통과 및 직접 캡처 확인. |
| **이전** | **2026-06-28** — **Codex Demo AP Loop + CTA Surface Pass**: AP 화면에 주차 기준 `이번 주 / This Week` 포커스 카드(남은 선택 수·월 현금흐름·총자산·추천 행동)를 추가하고, `Monthly net`/`Next Month`류 표면 문구를 주간 AP 루프에 맞게 보정. 데모 완료 요약과 Steam 위시리스트를 밝은 primary CTA로 격상. `ScreenshotQA --qa=demo-flow`가 AP 루프/데모 완료 요약/데모 엔딩 CTA까지 캡처하도록 확장. |
| **이전** | **2026-06-28** — **Codex Demo Flow Surface QA**: `ScreenshotQA --qa=demo-flow` 추가로 Steam 데모 초반 흐름(OpeningCinematic → Chapter 1 카드 → intro 01~04 → chapter close)을 영어/한국어로 빠르게 캡처 가능하게 했다. StoryMode 챕터 카드에서 상단 HUD 패널이 겹치던 문제 수정. 초반 `arc_intro_02_dad_call` 편의점 밤 배경을 고시원 방으로 교체하고, 현수 첫 만남은 실제 보유 배경에 맞춰 공용 주방 앞 복도로 문구 보정. |
| **이전** | **2026-06-28** — **Codex Gangnam Ink Surface Lock**: 최종 표면 언어 `Gangnam Ink` 정본(`docs/GANGNAM_INK_ART_DIRECTION.md`) 추가. 배경 필터에 종이결·잉크 번짐·pale fade·edge burn을 추가하고 `MORAL_TINT`에 연결. Black 표면 부식색을 브라운 rust에서 차가운 흑회색 ink/concrete로 교체. `UI_ART_DIRECTION`/`MORAL_TINT`/`NEW_ASSET_REQUESTS`/`DECISIONS`/`ROADMAP`에 향후 이미지·CG·UI 작업 기준 반영. |
| **이전** | **2026-06-28** — **Codex Moral Surface Continuity Pass**: 본편 기본 배경/딤 오버레이를 흑회색 축으로 낮추고, 시간대 앰비언트·이벤트 카테고리 틴트를 저채도 moral signal로 변환. 선택지 구분선/효과 미리보기/패드 힌트/AP 섹션 문구/정보 패널 탭을 `moral_role` 팔레트에 연결. 엔딩·데모 종료 화면의 보상색을 텍스트용 `_moral_text_accent()`와 테두리용 `_moral_gray_accent()`로 분리해 Black 경로에서도 읽히게 보정. 엔딩 스탯 그리드 값 라벨 최소폭/clip 문제 수정. `ScreenshotQA` full + moral 캡처로 본편/정보패널/엔딩 직접 확인. |
| **이전** | **2026-06-28** — **Codex Start Surface Monochrome Pass**: StartMenu 로고/스토리 패널/난이도·런테마 카드/새 게임 CTA/슬롯 포커스/콘텐츠 안내/언어 토글을 금색·초록에서 회색/흰색 축으로 통일. MainGame 공통 섹션 헤더와 상점 아이템 카드 구조색도 현재 `MORAL_TINT`에 맞는 회색 액센트로 낮춤. `ScreenshotQA` full 캡처로 시작 화면 KR/EN, 투자/상점/메인 AP 화면 직접 확인. |
| **이전** | **2026-06-28** — **Codex MORAL_TINT 무채색 비주얼 리셋 + 선택 직후 체감 피드백**: 게임 기본 UI/배경을 금색·남색 누아르에서 회색/진회색/검정/연회색/흰색 축으로 재정의. `background_grade.gdshader`로 배경 이미지 채도 제거, `moral_surface.gdshader`로 Black 부식·White 선명도, MainGame 상단 HUD/초상화 패널/목표바/선택지/버튼 UI-wide palette 동기화. 돈 HUD는 Black에서만 비정상적으로 밝게 남김. 선택 직후 actual tint delta를 감지해 Black 방향은 화면 암전·표면 부식·돈 HUD 맥박, White 방향은 본문/표면 선명도 맥박으로 원인-결과를 체감시킴. `ScreenshotQA --qa=moral` 3상태+echo 캡처 검증. |
| **이전** | **2026-06-25** — **Y1-Y5 전체 정합성 QA + 후속 수정**: 4영역 병렬 추적(다은/지연/타임라인/엔딩). 블로커·데드엔드 없음, 30억>연애 엔딩 우선순위 회귀 없음 확인. 수정: 지연 respected/trust 플레이어 Y4 공백→year4_seoul 게이트 확장, 다은 우정 finale 에필로그 톤 누수→플래그 게이트, 죽은 stage(dating/committed) 제거. audit 통과. |
| **이전** | **2026-06-25** — **지연 로맨스 Y5 단일화 정합성**: jiyeon_man 엔딩 stage(honest_together Y2/lover Y4)→jiyeon_romance_started 플래그 게이트. Y5 return이 연애 formalize(lover+flag). Y4 seoul lover→honest_together. 에필로그/중복가드 정리. honest_together='연애 전 깊은 유대'로 의미 유지(콜백 무수정). audit 통과. |
| **이전** | **2026-06-25** — **다은 우정 재프레임 완성 + 현수 Y4-Y5 + Steam App ID**: 다은 Y2-Y5(05_together/year3/year4/year5) committed→close 우정 전환, 연애는 Y5 게이트 단일화. with_daeun 엔딩 오발동 버그 수정(stage→daeun_romance_started 플래그). 죽은 stage(committed/dating) 정리. 현수 hyunsu_year4_echo/year5_call 신규(안정 vs 야망 거울). Steam App ID 상수화+폴백. audit ERROR 0/WARNING 0/밴드 통과. |
| **이전** | **2026-06-25** — **로맨스 시스템 재설계 (Y5 게이트 + 경로 연동)**: 다은 Y1-Y4 아크 우정 재프레임. arc_romance_y5.json 신규 — `arc_daeun_y5_feelings`(moral_stage≥0) / `arc_jiyeon_y5_feelings`(moral_stage≤-1) Y5 첫 고백. with_daeun/jiyeon_man 결혼 변주. |
| **이전** | **2026-06-25** — **5권 구조 연말 클로징 씬 4종 + cross-year echo 체인** |
| **이전** | **2026-06-24** — **재혁/다은 서사 심화 + MORAL_TINT 확장 7차 + §4 시그널 준비**: ①재혁 엔딩 분기(jaehyuk_way+2변주/gangnam_dream+1/late_call+1) + 에필로그 4종 신규 분기(stood_up/night_real/trusted/opening_up). ②다은 Y4 `arc_daeun_year4_quiet` 신규 씬(지연 갈등 이후 행복 비트) + arc_daeun_year5_ending 카페약속 페이오프. ③weight<3 이벤트 29선택지 tint 부여. ④GameState `moral_tint_changed(norm, stage)` 시그널 추가. audit ERROR 0/WARNING 0/밴드 통과. |
| **이전** | **2026-06-24** — **다은/지연 로맨스 상호배타 + 지연 Y4-Y5 아크 완성**: ①지연 Y4-Y5 5개 이벤트(부산 첫 전화/서울 방문 표준·갈등 2버전/Y5 귀환·소식) — Y3 부산 출발 이후 Y4-Y5 공백 해소. ②`_next_arc_id()` 분기: 다은 연인 경로(daeun_together_path/lover/together/committed)→`arc_jiyeon_year4_seoul_daeun`(지연에게 솔직 tint+5 vs 침묵 tint-5), 아니면 일반 서울 방문. ③`arc_jiyeon_year5_news` description_if_known 2종(솔직한 작별↔침묵, KR+EN) — write-only→read 전환, baseline 226 유지. ④jiyeon_man 엔딩 `lover` stage 포함. audit ERROR 0/WARNING 0/밴드 통과. |
| **이전** | **2026-06-24** — **MORAL_TINT 6차 확장 (shadow/chain/butterfly/NG+ 고도덕강도) + cut_sangchul_network 엔딩 변주**: ①shadow_events 8종(사채/거짓/고발 -2~-5/+3~+5), work_events 1종(팀장 직접 대화 +4), story_events 2종(프롤로그 아버지 챙기기/짧게 끊기 ±2), butterfly 5종(내부정보 거절+2/구입-5/신고+5/즉시투자-6), chain_events 8종(봉투 +8/-8 게임 최대값, 사기꾼 제보+6/-5, 임원 면접 솔직+5/-3), drama_events 2종(도박 회복 솔직+5/-2). ②NG+ 8종 — 상철 알면서 이용 -6/직접 대면 +7, 아버지 전화 재무시 -2/방문+3, 카지노 재입장 자기기만-4/거부+3, 도박꾼 외면-3/손 내밀기+5. ③endings.json + endings_en.json: stable_success/ordinary_life/balanced_life 3엔딩에 `cut_sangchul_network` description_if_known 추가(KR+EN). write-only→read 전환. audit ERROR 0/WARNING 0/밴드 통과. |
| **이전** | **2026-06-24** — **MORAL_TINT 밸런스 수정 + 흉터 비네트**: ①투자/생활 이벤트 29개 선택지에 tint 추가(투자 20개: 내부정보-5/올인-4/레버리지-3/지하네트워크-3/재개발내부정보-3/빚투자-3/FOMO-2/물타기-2 + 원칙거절+4/원칙투자+2 등; 생활 9개: 합리화-2/체념-1/자기방임-1 등). 기존 양수 편향(70%) 개선. ②흉터 비네트(scar vignette): `crossed_line`/`chose_money_over_father` 최초 설정 시 band 전이보다 우선 표시 — "잠에서 깼다. 뭔가 없어진 것 같은 느낌이었다..." / "아버지가 마지막으로 말했던 것을 기억하려 했다...". `pending_scar_vignette` GameState에 추가, SERIALIZE_EXEMPT 등록. audit ERROR 0/WARNING 0/밴드 통과. |
| **이전** | **2026-06-24** — **UI 복잡도 최적화 (드라마 몰입 강화)**: ①스탯 패널에서 6개 스킬 수치(지력/사교력/외모/투자감각/행운/평판) 숨김 — 내부 메커니즘 유지, 화면엔 건강/정신력/자산/직업/주거만 표시. ②AP 행동 목록 단순화 — "자기계발" 직접 풀 랜덤 실행(모달 없음), "심화 독서" 별도 버튼 제거, 경마장/홀덤/스캘핑/카지노 4개 → "도박장" 단일 버튼(하위 모달). ③런 정보 패널 스킬 숫자 제거 → 성향 라벨로 대체. audit ERROR 0/WARNING 0/밴드 통과. |
| **이전** | **2026-06-24** — **description_if_known 3종 + 죽은 플래그 연결**: ①`arc_sangchul_casino_invite`에 `sangchul_truth_known` 변주 추가 — 아버지를 망가뜨린 그가 보내는 "편하게 와요" 카지노 문자가 달리 읽힘(KR+EN). ②`arc_father_passing`에 `father_mentally_updated` 변주 추가 — Y3에 아버지와 진짜 대화를 나눈 플레이어만 보는 마지막 인사(KR+EN). ③`father_mentally_updated` write-only 플래그 → 서사 독자로 전환. debt_baseline 210→209. audit ERROR 0/arc_flow_sim ✓. |
| **이전** | **2026-06-24** — **재혁/지연/아버지/엔딩 서사 무결성 수정 3종**: ①지연 진실 씬이 상철 네트워크 전용으로 잠겨 비상철 플레이어 영구 차단 → t>=70 자연 발견 대체 트리거 추가. ②arc_father_passing t>=64(Y2 초반 7개월 뒤 조기 발화) → t>=100 + arc_father_medication_seen 게이트 추가. ③empty_house 엔딩: father_passed=true인데 lonely_rich로 잘못 라우팅되던 버그 → OR 조건 수정. audit ERROR 0/WARNING 0/밴드 통과/arc_flow_sim ✓. |
| **이전** | **2026-06-24** — **서사 무결성 수정 5종 (내러티브 QA 후속)**: ①다은 morning 2번 선택지에 `daeun_together_path` 플래그 누락 → 추가(Y3~Y5 아크 계속 불가 데드엔드 수정). ②`arc_daeun_year3_apart` 트리거: `arc_daeun_ghost_seen` 강제가 `daeun_breakup_accepted` 경로를 막던 것 → OR 조건 추가. ③상철 "5년 전 아버지를 무너뜨린" → "몇 년 전" (6년 빚 상환 타임라인과 모순 수정, 2곳). ④Y5 echo 4종(weight/path_cost) "작년" → "2년 전" (Y3→Y5 시간 간격 수정, KR+EN). ⑤`arc_34_two_years_in` 윈도우 t<=96 → t<=100 확장(경쟁 우선순위 아래 starved 방지). audit ERROR 0/WARNING 0/밴드 통과/arc_flow_sim ✓. |
| **이전** | **2026-06-24** — **연차별 챕터 테마 분배 (17개 신규 이벤트)**: 보장 스토리 비트 집계로 Y2~Y5가 챕터 테마(확장/무게/균열) 미구현임을 발견 → Y3 "무게" 3종(orthodox/unorthodox_weight route 반응형 + path_cost), Y4 "균열" 2종(trust_crack 믿었던 사람이 흔든다 + unexpected_hand 예상치 못한 사람이 잡는다), Y2 "확장" 2종(money_attracts_money + doors_open), Y5 echo 콜백 8종(stance 플래그 페이오프, pay-it-forward 포함). KR+EN 동기화. **결과: Y1=34/Y2=10/Y3=9/Y4=10/Y5=7(+echo8)** — 5막 구조 명확화. write-only 210 유지(echo가 전부 소비), audit ERROR 0/WARNING 0/밴드 통과. |
| **이전** | **2026-06-23** — **MORAL_TINT 5차 확장 135개 (콜백/앰비언트/이스터에그/히든/레어)**: callback 23종(father_promise강남못가도모신다+7/lied_interview자백+7/health_collapse+5/-5/lie_echo+6/-5/truth_echo+5/-4)+amb_scenario 14종(parent_hospital+8/-5/wallet_00정직+7/gambling_mirror앱삭제+7/health_00+5/nonprofit_00의미+6)+easter_eggs 8종(gambling_mirror+7/-6/honest_paradox+6/-3/veteran_return+4/-4)+hidden/rare 28종(wallet_executive+7/-5/night_alva_find+6/-6/hidden_016당당히+4/FOMO-3+3). KR+EN 동기화. 전체 **482/3090 (15.6%)**. audit ERROR 0/WARNING 0/밴드 통과. |
| **이전** | **2026-06-23** — **MORAL_TINT 스파인 확장 2차 (arc_events + arc_midgame)**: arc_events.json 33개 tint 부여(아버지 아크 전 씬·재혁 pitch·지연 epilogue·자소서 정직·상철 거절). arc_midgame.json 25개 tint 부여(첫 수익 아버지 전화·외로움·약 전달·37세 평화·다은 솔직 고백·현수 응원). KR+EN 동기화. 전체 232/3090 (7.5%) — 서사 핵심 파일은 100% 완료. audit ERROR 0/WARNING 0/밴드 통과. |
| **이전** | **2026-06-23** — **MORAL_TINT 밴드 전이 비네트**: `shift_moral_tint()`가 밴드 경계(0/±1/±2) 넘으면 `pending_tint_vignette` 기록 → `_on_result_confirmed()` 직후 `_show_moral_beat()` 띄움. 비네트 3종 KR+EN(0→−1 "밥에서 맛이 안 났다"/−1→−2 "거울에서 5년 전 얼굴 못 떠올림"/회복 "오랜만에 웃었다"). 숫자·스탯 없이 순 본문. audit SERIALIZE_EXEMPT 등록. 헤드리스+xvfb 검증 완료. |
| **이전** | **2026-06-23** — **★MORAL_TINT 신규 시스템 착수 (색으로 보는 자기 파괴)**: 게임 핵심 신규 시스템. "회색 시작 → 인간성=하양 / 돈=검정" 단일 축. `docs/MORAL_TINT.md` 스펙 + 엔진 코어(GameState.moral_tint −100~+100·shift·moral_stage·moral_tint_norm·tint 효과 키·흉터 상한[crossed_line→−20/death-ignored→0]·serialize). 상철+아버지 스파인 tint 수직 슬라이스. 헤드리스 검증(누적·회복·밴드·흉터·라운드트립) 통과. 플레이어 숫자 미노출 — Codex가 moral_tint_norm()/moral_stage() 구독해 칠함(NEW_ASSET_REQUESTS.md 핸드오프). |
| **이전** | **2026-06-23** — **데모 빌드 export QA (Windows + Linux/Steam Deck)**: export 템플릿 4.6.2로 Linux/Steam Deck(167MB ELF, xvfb 18초 무에러 부팅) + Windows(201MB PE32+) 빌드·실행 검증. 산출물 gitignore. |
| **이전** | **2026-06-23** — **다은/지연/재혁 아크 reachability 트레이스 (데드엔드 없음 확정)**: 세 인물 아크의 상한 윈도우 전수 점검. 다은(affinity 게이트=의도)·지연 전부 하한 트리거만 → 윈도우 데드엔드 없음. 재혁은 wait(t38~41) 1개 바운드뿐인데 pitch 지연 시 스킵 가능하나 코어(ghost→standup, 하한 트리거)는 항상 도달 — 선택적 페이싱 비트라 허용. 결론: 4개 인물 중 데드엔드는 상철 known_offer뿐(직전 수정 완료), 나머지 안전. |
| **이전** | **2026-06-23** — **상철 진실 아크 타임라인 reachability 정밀 점검 + 데드엔드 수정**: 전체 체인(01→02→03→deduction→offguard→human→known_offer→reflex→confrontation→reckoning→엔딩) 오프라인 트레이스. 발견: 네트워크 합류 늦은(자산<100만 장기) 추론 플레이어가 human 윈도우(t30~42) 놓쳐 known_offer 영구 스킵되는 데드엔드 → `arc_sangchul_human` 상한 t42→t52 확장으로 해결. 트레이스 검증: 조기/늦은(t40)/매우늦은(t48) 네트워크 전부 offer·reflex·confrontation 도달. t50+ 합류는 deduction 윈도우 닫혀 confession 경로(데드엔드 아님). Godot 컴파일 클린. |
| **이전** | **2026-06-23** — **description_if_known 엔딩 변주 실기 렌더 검증(xvfb)**: QAVariants 하니스로 실제 opengl3 렌더 캡처 — jaehyuk_way(used_fully)/late_call(used_fully·truth_known)/gangnam_dream(3변주) KR + EN 2컷 전부 변주 본문이 정확히 렌더됨 확인. EN jaehyuk_way "He started out hating him, and ended up exactly him" 영어 정상. description_if_known 엔진 엔딩 경로 end-to-end 검증 완료(이벤트 경로는 기존 검증). 임시 하니스 삭제. |
| **이전** | **2026-06-23** — **late_call(비-강남) 엔딩에 상철 진실 변주 2종**: 진실을 안 채 강남에 못 닿고 아버지와 화해한 플레이어에게 무게 부여(KR+EN). ①`sangchul_used_fully`: 끝까지 이용했는데도 강남 미달 — "팔 건 다 팔았는데, 남은 건 국밥 한 그릇과 말할 수 없는 것 하나". ②`sangchul_truth_known`(일반): 진실을 아버지 평안 위해 혼자 짊어짐 — "어쩌면 이게 강남보다 어려운 일이었는지도". 우선순위 used_fully>truth_known, reported는 sangchul_reckoning 분기라 충돌 없음. 런타임 양언어 확인. ERROR 0/WARNING 0. |
| **이전** | **2026-06-23** — **상철 진실 4경로 엔딩 페이오프 완비 + 에필로그 톤 점검**: `gangnam_dream`에 `sangchul_quietly_distanced` 변주 추가("빌리지 않았다" — 그의 사다리 없이 도달). 이로써 상철 진실 전 경로 엔딩 분기 완성: used_fully/leveraged→jaehyuk_way, truth_buried/forgiven/quietly_distanced→gangnam_dream 3변주, reported→sangchul_reckoning. task② 검증 결과 다은/지연/재혁은 stage가 관계 건강 정직 반영(착취-while-close 패턴 없음) + 재혁 에필로그 이미 플래그 기반 → 상철 톤버그는 고유 케이스로 확정. KR+EN 동기화. ERROR 0/WARNING 0. |
| **이전** | **2026-06-23** — **엔딩 EN 검증 + gangnam_dream 상철 진실 변주 2종 + 에필로그 착취 톤버그 수정**: ①`_ending_run_summary`/`_ending_cast_epilogue` 전수 _tr() 처리 확인 — 34개 엔딩 + 모든 인연 분기 완전 이중언어. ②`gangnam_dream`에 `description_if_known` 2종(KR+EN): `sangchul_truth_buried`(진실을 묻고 올라온 승리), `sangchul_forgiven`(원망 내려놓은 손에 등기가). crossed_line 미설정이라 jaehyuk_way 가로채기 없이 gangnam_dream 도달 — 라우팅+런타임 검증. ③인연 에필로그 톤버그 수정: 착취 플레이어(`sangchul_used_fully`/`sangchul_leveraged`)가 stage 기반 따뜻한 "국밥 같이 먹는다" 라인을 받던 것 → 플래그 우선 분기로 "필요하면 또 쓸 것이다"/"좋은 지렛대였다" 라인 추가(KR+EN). Godot 55개 컴파일 클린. ERROR 0/WARNING 0. |
| **이전** | **2026-06-23** — **엔딩 EN 번역 인프라 + 34개 엔딩 전체 영어화**: 엔딩이 그동안 KR 전용(EN 오버레이 인프라 없음)이었음 — 풀 릴리스 전 필수. ①`content/endings_en.json` 신규 — 34개 엔딩 전체 영어 번역(title+description+jaehyuk_way description_if_known). ②`DataRegistry._apply_endings_en_overlay()` — events_en 패턴 미러, language=="en"일 때 텍스트 필드 영어로 덮어씀. ③`{name}`/`{housing}` 플레이스홀더 보존. ④런타임 검증 완료(EN모드→"Gangnam Dream", KR모드→"강남드림"). ERROR 0/WARNING 0/Godot 55개 컴파일 클린/밴드 통과. |
| **이전** | **2026-06-23** — **drift EN 5종 + jaehyuk_way 상철 변주 엔딩 + 파스 에러 수정**: ①relationship drift 5종(daeun_drift_quiet/sangchul_becomes_primary/daeun_birthday_missed/sangchul_world_absorbed/jiyeon_notices_daeun) EN 번역 — KR/EN 완전 동기화. ②`jaehyuk_way` 엔딩에 `description_if_known`(sangchul_used_fully) 변주 추가 — 상철을 끝까지 이용해 강남에 닿은 플레이어 전용("그를 미워하며 시작해서, 정확히 그가 되어 끝났다"). `_show_ending()`에 지식 반응형 변주 엔진 추가. 체인 완성: used_sangchul_knowingly→leveraged_cost→sangchul_used_fully+crossed_line→30억→jaehyuk_way 상철 변주. ③`var t` 셰도잉 파스 에러 수정(MainGame.gd:3288 for t→th) — 엄격 파서가 잡은 기존 버그, Godot 55개 스크립트 클린. ERROR 0/WARNING 0/밸런스 밴드 통과. |
| **이전** | **2026-06-23** — **상철 이후 중간 씬 2종 (알면서도 이용하는 구간 t38~59)**: deduction으로 진실을 일찍 안 플레이어가 대면(t60) 전까지 알면서도 상철을 계속 이용한다 — "사람이 도구가 되는 순간". ①`arc_sangchul_known_offer`(t38~55): 유용한 제안을 알면서 받음, money+180만+`used_sangchul_knowingly`. ②`arc_sangchul_known_reflex`(t50~59): 자기가 상철처럼 사람을 계산하는 걸 발견, `rationalized_using_people`. ③두 플래그를 confrontation/reckoning `description_if_known`에 페이오프 배선(KR+EN). confession 경로(t56+)는 대면 직행 — 스스로 알아챈 자만 무게를 더 오래 진다는 비대칭. ERROR 0/WARNING 0. |
| **이전** | **2026-06-23** — **선택지 텍스트 전수 재작성 + arc_sangchul_mirror + EN 오버레이**: ①선택지 219개(life/relationship/investment/hidden/callback 26개 파일) 게임동사→인간행동으로 재작성. ②`arc_sangchul_mirror` 이벤트(KR+EN) 추가 — t50~90 상철이 "나랑 비슷해요" 고백 씬, 3가지 반응. ③`arc_father_03_hospital` 4번째 선택지(상철 병원 인맥, `sangchul_helped_with_father` 플래그) KR+EN. ④arc_sangchul_confrontation/reckoning `description_if_known` EN 번역 추가(거울 인식·부정 2경로). ⑤선택지 효과 미리보기를 money/health/mental 3종으로 축소(스킬/관계는 서사로 발견). ERROR 0/WARNING 0. |
| **이전** | **2026-06-23** — **발견 레이어(Discovery Layer)**: ①`description_if_known` 엔진 추가(StoryMode.gd) — {플래그:대체본문} 매핑, 진실을 알면 같은 장면이 다르게 읽힘. ②`arc_sangchul_deduction` 신규 이벤트(KR+EN) — 지력55+/비정통 플레이어가 한PD건설 단서로 자가발견. ③상철 따뜻한 장면 6개(coffee/network/offguard/human/why_gangnam/past) KR+EN `description_if_known` 추가. ④arc_father_06_confession deduced+clue_noted 2경로 대응. ⑤audit.py description_if_known 키 flag-read 인식 추가. ERROR 0/WARNING 0. |
| **이전** | **2026-06-22** — **Steam 데모 QA + 위시리스트 CTA**: ①Steam 데모 크리티컬 패스 검증(OpeningCinematic→arc_chapter1_close 전 이벤트 확인). ②callback_events_35~54 416개 flag-triggered 콜백 전수 reachable 확인(opportunity.win_flag/lose_flag 경로 포함). ③EN 커버리지 100% (1369/1369) 재확인. ④밸런스 밴드 전부 통과. ⑤`_show_demo_ending()`에 Steam 위시리스트 CTA 버튼 추가 (KR/EN, App ID TODO 주석). ERROR 0/WARNING 0. |
| **이전** | **2026-06-22** — **Phase 3 유기성 배선 완료**: EventManager._effective_weight() cast 큐레이션 + 직업카테고리 + fear_greed 연동, GameState._resolve_opportunity() 상철affinity 성공률 보너스, JobSystem appearance→업무능력/승진→social_skill+1, jeonse/housing 태그 3건. + inert 이벤트 106개 전수 연결(callback_19~26). |
| **추가 완료** | **2026-06-20 (도박 서사)** — 도박 중독 풀아크 + 회복 3종 + beat_addiction 업적 + **구원 엔딩 gambling_recovery(B급)**. ※카지노 미니게임 메커니즘 미변경(서사만). |
| **Codex 추가 완료** | **2026-06-20~22 (외형)** — PC/Steam Deck 공통 Readability Pass 1~3(전역 폰트·버튼·모달·포커스 기준 상향, 모달 760×610/스크롤 리셋, 룰렛 숫자 매트 58×34 확대·상태 배지, 투자 자산/상점 아이템 카드화, 우측 정보 패널 400px 확대 및 관계·소지품·스토리 카드화, AP 세부 모달 카드화), 영어판 표면 QA 강화(`ScreenshotQA` 영어 메인 HUD/행동 모달/정보 패널 캡처 추가, 영어 로고/날짜/금액/주거명/인물명/로그/관계 단계 라벨 정리), 빅휠 54칸 슬롯 쇼휠·상태 플레이트, 경마 질주 화면(주로/게이트/순위판/PHOTO FINISH)과 결과 정산 보드, 홀덤 오벌 테이블 재배치와 쇼다운 판정 패널·팟 이동 라인, 투자 모달 MARKET BOARD(장세·공포/탐욕·리스크·계좌 요약), 슬롯머신 캐비닛·릴 심볼 코드 드로잉·payout tray 코인 연출 보강, 다이사이 주사위 컵·콜 패널 보강, 룰렛 테이블 베팅/딜러/포켓 하이라이트·중앙 숫자 위치 핫픽스, 룰렛 부유 칩 제거·숫자 매트 중앙 정렬·winning pocket 콜아웃·스핀/결과 QA 분리. 정선 카지노 허브 게임 카드 상단을 바카라/블랙잭/슬롯/룰렛/다이사이/빅휠별 코드 드로잉 미니 아트로 교체하고 카드 그림자/타입 라벨/버튼 스타일을 보강. 구형 `poker_chip_icon.png` 런타임 참조를 제거해 centered denomination chip SVG로 대체. 바카라/블랙잭 베팅·딜·결과 화면을 펠트 테이블/베팅존/카드존/칩 스택 중심 UI로 재구성. `docs/PRODUCTION_ASSET_PIPELINE.md` 추가로 상용 출시 에셋 Gate 0~4·A/S등급 정립. |
| **이전 (15차)** | **2026-06-21 (15차)** — **Steam 후킹 강화 (오프닝 훅 5종)**: ①KR 수학 오류 수정: "30억÷200만=1,250개월=104년" → "1,500개월=125년" (arc_intro_02 4개 변형 모두). ②EN prologue_goal: "최저시급으로 82년 — 그가 가진 건 5년뿐이다" 연결 (오프닝 시네마틱 통계와 개인 선택 순간 연결). ③OpeningCinematic 7번째 카드 추가: "어떤 선택이 강남을 만드는지, 아무도 가르쳐준 적 없다." (게임 정체성 훅). ④arc_chapter1_close 신규 아크: t=8 현수 라면 씬 후 챕터1 클로즈/데모 종료 포인트 (EN 오버레이 포함). audit ERROR 0/WARNING 0, 밴드 통과. |
| **이전 (14차)** | **2026-06-21 (14차)** — **계절 클러스터링 + 플래그→콜백 체인 + EN 문화 설명 강화**: ①계절 클러스터링(min_turn+cooldown=48): 봄벚꽃/장마/폭염/한파/설날/추석/수능/신년운세/붕어빵/연말정산 시즌 정확 배치. ②플래그→콜백 체인(callback_events_34.json 7개): jeonse사기 해소/회식충성 보상/꼰대 반전/야근 번아웃/연말정산 환급/분리수거 이웃신뢰. 키 이벤트 선택지에 플래그 추가(jeonse_protected/tax_claimed_well/hoesik_loyal/overtime_boundary/challenged_kkondae/recycling_diligent). ③EN 문화 설명: 전세+확정일자 메커니즘, 연말정산 설명, 회식 문화적 무게, 꼰대 정의, 예비군 ₩150만 벌금, 주민센터 확정일자 중요성. audit ERROR 0/WARNING 0, 밴드 통과. 이벤트 1166개. |
| **이전 (13차)** | **2026-06-21 (13차)** — **한국 체험 배치 5~13 완료 + 튜토리얼/오버레이 버그 수정 (35개 이벤트, 이벤트 1159개)**: ①생활생존 ②기후/계절 ③지정학 ④운세 ⑤행정인프라 ⑥디지털/SNS ⑦교육문화(학원/수능/고시/영어학원) ⑧명절(추석귀성/설날세뱃돈/혼자명절) ⑨직장문화(회식/야근/꼰대/사내정치/연봉협상). + TutorialOverlay EN 완전 지원(한국어 전용 버그 수정), story_events EN stress→mental 잔존 3개 수정, arc_intro EN 오버레이 effects 덮어쓰기 버그(reputation 손실) 수정. docs/NEW_ASSET_REQUESTS.md 작성(Codex용 신규 에셋 위시리스트). audit ERROR 0/WARNING 0, 밴드 통과. |
| **Steam 한 줄 피치 (확정)** | **KR**: "빚을 다 갚고 남은 건 50만원. 강남까지 30억이 필요하다. 5년밖에 없다." **EN**: "₩500,000 in the bank. ₩3B to reach Gangnam, Seoul's status district. Five years, no guarantee." |
| **Steam 데모 범위** | **시작**: OpeningCinematic(7카드) → 프롤로그 3씬 → chapter_card_33 → arc_intro_01~04 (t=2~7) **종료**: arc_chapter1_close (t=8) → 계속 플레이 → t=24 데모 엔딩 스크린(Steam 위시리스트 CTA 포함). 실 플레이타임: 초반 20~30분 + 자유 탐색. |
| **다음 작업** | **Codex 최종 검수 Phase 2 계속** — Steam Deck/영어판 표면 회귀 반복 → 엔딩별 컷신/CG 우선순위 재점검 → 데모 첫 30분의 이미지/오디오/전환 연출 A급 후보 정리. Steamworks 등록 후 STEAM_APP_ID 실제값 교체, 다은/지연 연애 Y5 단일화 회귀 QA. **이미지/오디오/UI + 카지노 미니게임 메커니즘은 Codex 영역 — Codex는 `docs/PRODUCTION_ASSET_PIPELINE.md`와 `docs/GANGNAM_INK_ART_DIRECTION.md` 기준으로 상용 에셋 관리. Claude는 서사/밸런스/번역 중심.** |
| **마지막 업데이트** | 2026-06-30 (Codex: Tendency Modal Accent Pass — 성향 팝업 보상 라인 색감 보정.) |

**세션 시작 시 위 "다음 작업"부터 시작한다. 유저가 다른 지시를 하면 그쪽 우선.**

---

## ✅ 이번 세션 완료 목록 (2026-06-17, 컨텍스트 압축 대비)

### 후반18 (최신) — Steam 데모 품질 벤치마크 UI 폴리싱 11종

#### Disco Elysium 벤치마크 — 선택지 효과 미리보기
- `_choice_effects_preview()` 신규 함수: effects dict를 stress→mental 변환 후 이모지+부호 형식으로 압축
- `_reveal_choices()`: 버튼+미리보기 레이블을 VBoxContainer(sep=3)로 묶어 시각적 연관 명확화
- StoryMode에도 동일 패턴 추가 (`_choice_effect_preview()` + `_SM_STAT_EMOJI` 상수)

#### Citizen Sleeper 벤치마크 — 한눈에 읽히는 스탯
- `_set_stat_value()` 확장: 스킬류(지력/사회성 등) 5칸 미니바 표시 (max=80 기준)
- `_animate_ap_refill()`: AP 보충 시 0.12초 간격 순차 점등 (주사위 굴림 연상)

#### Balatro 벤치마크 — 배경 분위기 신호
- `_category_tint: ColorRect` 오버레이 추가 (MOUSE_FILTER_IGNORE)
- `_apply_category_tint()`: 이벤트 카테고리별 반투명 컬러 (재앙=빨강, 도박=골드, 투자=녹색 등)
- `_render_event()` 진입·복귀 시 틴트 적용/해제

#### Hades 벤치마크 — 활력 임박 경보
- `_pulse_vital_critical()`: ≤15 더블 플래시 (Hades 체력바 임박 플래시 참고)
- `_pulse_vital_warning()`: ≤30 단일 약한 페이드
- `_goal_time_lbl`: 남은 개월 ≤12=빨강·≤24=노랑·그외=회색

#### 기타 폴리싱
- `_show_vignette()` 스탯 효과: BBCode `[color]` 초록/빨강/금색 표시
- `_unhandled_input()`: `ui_accept`(Space/Enter) → 타이핑 스킵 (VN 표준)

### 후반16 (이전) — ArubaGame/표시 버그 2종 수정

#### ArubaGame health_delta 미전달 버그 (후반15)
- `ArubaGame.closed` signal에 `health_delta: int` 파라미터 누락 → 결과 화면에 건강 변동 표시되지만 실제 GameState에 미적용
- `signal closed(earned, stress_delta, health_delta)` 추가, `_on_aruba_closed` 수신측 업데이트
- DELIVERY 모드 배달 건수·CARDS 모드 선택지 건강 효과 이제 실제 적용됨

#### stress+mental 병합 덮어쓰기 표시 버그 (후반16)
- `_show_effects_float`, `_show_vignette`: effects dict에서 "stress"가 "mental"보다 앞에 오면 stress→mental 변환값이 덮어씌워지던 표시 버그 (858개 이벤트 선택지 영향)
- 두 함수 모두 "mental" 키 처리 시 누산 방식으로 변경 (GameState.apply_effects는 원래 올바름)
- 예: `{"stress":-3,"mental":1}` → 정신 +4 표시 (기존: +1)

### 후반10 (이전) — 데드코드 AP 비네팅 연결 + mental 누락 버그 수정

#### AP 비네팅 배열 연결 및 정리
- `_ap_study`: 4개 고정 씬 → STUDY_READ/EXERCISE/MEDITATE/INVEST_VIGNETTES 40개 씬 (10×4 풀)
- `_ap_network`: 5개 단순 텍스트 씬 → NETWORK_VIGNETTES 10개 (효과 다양화)
- SAVE_VIGNETTES / RESUME_VIGNETTES / INTERVIEW_VIGNETTES 데드 상수 삭제
- 네트워크 버튼 레이블 "사회성 +1" → "사교력+, 평판+ (정신력 소모)"

#### _ap_startup_work / _ap_create_content mental 효과 누락 버그
- "mental"을 modify_hidden_stat으로 잘못 라우팅 → 효과 무시됨
- STARTUP_VIGNETTES 4개 항목의 mental 효과 복원

#### 전수 검증 항목
- 26개 엔딩 ↔ finish_run 호출 100% 매핑 확인
- 3개 deferred_follow_up 유효
- opportunity 블록 구조 정상
- arc_four_months_in 트리거 정상 (t>=15 + flag)

### 후반9 — 스트레스 잔존 UI 전수 수정 + has_job 버그 수정

#### 스트레스→정신력 UI 잔존 참조 일괄 수정
- MetaProgression PERK_RULES "주거" 보너스: `stress/-1/-4` → `mental/+1/+4` (로그 "스트레스 -1" → "정신력 +1")
- `_show_vignette`: eff dict에서 stress → mental 병합(부호 반전) — REST/SELFDEV 비네팅 올바르게 표시
- `_show_effects_float`: 동일 병합 처리 — 이벤트 선택 float도 정신력으로 표시
- 충격 이벤트 감지: stress 효과 포함해 `effective_mental_delta` 계산 (stress:15 이상도 critical 발동)
- MainGame stat_map, `_stat_name`, perk stat_kr에서 "stress" 항목 제거
- 관계 힌트 텍스트 "스트레스 -N" → "정신력 +N", 버튼 라벨/로그/설명문 전수 수정
- ArubaGame/JobHuntMiniGame 결과 화면 "스트레스 %+d" → "정신력 %+d" (부호 반전)
- StoryMode 튜토리얼 팝업 스탯 목록에서 "스트레스" 제거

#### has_job:false → no_job:true 11건 수정
- 조건 `has_job: false`는 `if bool(false)` = 항상 false → 이벤트 절대 미발동 버그
- 수정 대상: amb_mlm_00, survival_rent_due/convenience_meal/job_portal_night/friend_sns, rare_interview_classmate/rejection_then_call/interview_pivot, chain_banchan_son/exec_interview, butterfly_resume_lie

#### 검증
- 942개 이벤트 전수 JSON 파싱 OK
- 108개 arc 이벤트 ID 모두 존재 확인
- cast_stages 선언-사용 교차 검증 통과
- audit.sh ERROR 0 / WARNING 0 / 밸런스 밴드 전부 통과

### 후반8 — 자율 정적 QA 1차

#### 이벤트 result_text 빈칸 30건 수정
- amb_scenarios~6, callback_events_3~5, scenario_cafe, scenario_cafe_callback 파일

#### opportunity 이중 mental 패널티 단순화
- `_resolve_opportunity()` 실패 시 `-3`+`-6` 중복 → `-9` 단일화

#### jaehyuk_way 엔딩 배경 + bg_map 정리
- endings.json jaehyuk_way background: `gangnam_apartment` → `gangnam_night`
- ending_bg_map 사용 안 하는 엔트리 3개 제거 (stable_success, orthodox_pinnacle, crypto_ghost)

#### MetaProgression stress_survivor 칭호 텍스트 갱신
- 이름: "스트레스 끝판왕" → "멘탈 끝판왕", 설명 → "정신력 15 이하"

### 후반7 — 스크린샷 QA 자동화

#### 실제 렌더러 스크린샷 QA 하니스 (`tools/ScreenshotQA.tscn`/`.gd`)
- 헤드리스 더미 렌더러는 빈 텍스처 → **xvfb + x11 + opengl3**로 실제 렌더링 캡처
- 실행: `xvfb-run -a godot --display-driver x11 --rendering-driver opengl3 --resolution 1280x800 res://tools/ScreenshotQA.tscn`
- `.tscn` 부팅(autoload 로드) + `add_child.call_deferred` + 전환 트윈 40프레임 차단(StoryMode 이탈 방지)
- 4종 캡처: 이벤트(포트레이트·타이핑·선택지)/투자모달+라인차트/위기 비네팅/AP 대시보드 → `/tmp/gangnamdream_qa/`

#### QA가 잡은 통합 후속 모순 수정
- 시작 안내·튜토리얼·주거 안내에 남아있던 "스트레스" 별도 기제 문구 3곳 → 정신력 통합 서술로 교체
- `_update_vignette`: stress 제거로 죽었던 빨강 가장자리를 **신체 위기**(건강≤35 또는 정신력≤20)로 재점등. 저정신력=어두운 모서리 / 저건강=빨강

### 후반6 — 스트레스→정신력 통합 + 고닷 활용

#### 스트레스 → 정신력 단일 스탯 통합 (밸런스 결정)
- **결정**: `stress`(높을수록 나쁨) 변수 완전 제거 → `mental`(높을수록 좋음) 단일 축으로 통합
- **구현 방식**: 적용 계층 리다이렉트 (JSON 600여 개 미수정). 데이터는 "stress" 단어 유지하되 모두 mental로 변환
  - `GameState.apply_effects` — `"stress": X` → `modify_stat("mental", -X)` (기존부터 존재)
  - `GameState.modify_hidden_stat("stress", X)` → `modify_stat("mental", -X)` (변경)
  - `EventManager._check_conditions` — `max_stress: N` → `mental < (100-N)`, `min_stress: N` → `mental > (100-N)`
  - `EventManager._effective_weight` — `stress>70` → `mental<30`
  - `BGMPlayer` 위기 트리거 → `mental <= 25`
  - `InvestmentSystem` 판단 페널티 → `(70 - mental) / 250`
  - `RelationshipSystem` 신뢰 가속 감소 → `mental < 25`
  - `MainGame._update_vignette` — `stress_norm` 0.0 고정 (셰이더 불변, mental_norm만 작동)
  - `GameState.gd` — `var stress` 선언·serialize·load_from_dict·DIFFICULTY_DATA(start_stress/pressure_stress) 전부 제거
- **밸런스 영향 (정량)**: stress 양수 622건(+3582)→mental -3582, 음수 594건(-2514)→mental +2514. 순 -1068을 mental 풀에 추가 (기존 mental 순합 +3597 → 통합후 +2529). 휴식 액션 강화·그라인드 액션(이력서/면접/창업) 정신력 직접 소모. **밸런스 밴드 전부 통과** (무직 100%·직장 0%·베팅 30억 14.8%)

#### 고닷 렌더링 기능 적극 활용 (이전 세션 main 커밋 + 컴파일 수정)
- 타이핑 효과(visible_ratio), 비네팅 셰이더, 포트폴리오 라인차트, 화면 흔들기, [wave]/[shake] BBCode, 골바 트윈, 코인버스트, 앰비언트 시간대 틴트
- **컴파일 에러 4종 수정** (Godot 컴파일 체크가 그동안 Mac 경로라 스킵돼 미검출):
  - `tier` 변수 중복 선언 (MainGame 4094/4110)
  - `phase := turn % 4` 타입 추론 실패 → `: int =`
  - `_button`/`_small_button`/`_label`/`_wrap_label` 반환 타입 미선언 → `-> Button`/`-> Label` 추가 (`:=` 호출부 일괄 해소)

#### 레버리지 투자 UI 연결 + 스토리 게이팅
- `_open_investments()` 하단 레버리지 버튼 추가 (투자감각 30 게이트) — 죽은 함수 `_open_leverage_investments` 연결
- 투자 버튼 게이팅: `arc_invest_guidance_seen` 플래그 필요 (상철 대화 후)
- 도박 조기 진입 차단: `gambling_006` 조건에 `arc_sangchul_met_seen` 추가
- 내러티브 이벤트 3종 추가 (holdem 2 + racetrack 1)

---

## ✅ 이전 세션 완료 목록 (2026-06-16)

### 후반5

#### StoryMode 포트레이트 프레임 제거
- `scenes/StoryMode.gd` — 금색 테두리·다크 매트·그림자 완전 제거 → 투명 StyleBoxFlat으로 교체
- `stretch_mode`: `STRETCH_KEEP_ASPECT_COVERED` → `STRETCH_KEEP_ASPECT_CENTERED`

#### 도박 이벤트 게이팅 수정
- `content/events/racetrack_events.json` — `race_first_visit`: `hidden: true` 추가 (랜덤 풀 → follow_up 전용)
- `content/events/holdem_events.json` — `holdem_first_visit`: 조건 `{}` → `{ "flag": "entered_network" }` 추가
- 결과: 카지노/경마/홀덤 모두 상철 네트워크 가입(t=23) 이전에는 접근 불가

#### arc_four_months_in 데모 씬 추가
- `content/events/arc_midgame.json` 끝에 새 이벤트 추가 (t=15 트리거)
- `scenes/MainGame.gd` `_next_arc_id()` — t>=15 블록 추가
- 데모 t=14~19 공백 구간 채움: 한강 다리 정체감 씬, 3가지 선택지(orthodox/unorthodox/침묵)

#### TutorialOverlay 추가 수정 (후반4에서 이어서)
- 더블팝업 방지: `TutorialOverlay._seen["main_game"]` 체크 추가
- "다음 달 ▶" → "다음 주 ▶" 수정
- 철학 슬라이드 4번째 추가 (선택 성향 안내)
- `_show_tutorial_intro()` 죽은코드 제거 ("AP 3개" 오류 포함)

---

### 후반3 추가 버그 수정 (세션 재개 후)

#### 캘린더 혼용 버그 6종 (별도 커밋)
- `BGMPlayer.gd:75` — `turn >= 36` → `age >= 36` (late_tense BGM 9개월→36세)
- `BGMPlayer.gd` hustle 판정 → `me(개월)` 기준으로 전환
- `MetaProgression.gd:232` — loner_title `turn >= 30` → 월기준
- `MainGame.gd:1062` — 카페 콜백 무한루프 방지 폴백 추가
- `MainGame.gd:1360` — `arc_after_scam` `t >= 40` 가드 추가
- `MainGame.gd:1476` — `_next_milestone_id()` 전체 `t → me` 전환 (8개 비교)
- `MainGame.gd:4846` — 런 요약 "개월" 표시 수정
- `EndingSystem.gd:18` — `get_score()` `turn → months_elapsed`

#### 이벤트 min_turn/max_turn 월→주 일괄 변환 (×4, 55건)
- 캘린더 마이그레이션 후 JSON이 여전히 월 단위로 작성된 버그
- life_events 19개: chapter_break(반환점/15개월남음), final_stretch/last_winter, father arc 4종, class_reunion 등
- relationship_events 9개: sangchul/daeun/jiyeon 윈도우
- callback_events*.json 18개: happy/father/daeun/jiyeon/final_sprint
- hidden/investment/amb_scenarios7 나머지 6개
- 핵심 영향: "반환점" 씬 7.5개월→30개월, "마지막 겨울" 14개월→56개월, father arc 적절한 중후반 타이밍으로 정상화

#### 엔딩 시스템 완성도
- `BGMPlayer.on_ending()` good 목록에 신규 엔딩 9종 추가 (instant_legend 등 "ending_bad"로 잘못 재생되던 것 수정)
- `_show_ending()` ending_bg_map: 16개 신규 엔딩 배경 추가
- `_ending_run_summary()`: empty_house/jaehyuk_way/with_daeun/jiyeon_man 등 10종 전용 요약 추가
- `_ending_cast_epilogue()` good 분류: 신규 성공 엔딩 10종 추가

#### drama_events.json 플래그 설정 버그 (CRITICAL)
- `startup_exit`·`political_winner` 엔딩이 절대 달성 불가한 버그 수정
- `effects: { "flag": "startup_exit" }` → `flags: ["startup_exit"]`로 올바른 위치로 이동
- 5개 이벤트 전체 수정 (chaebol_connection, bought_apartment, joined_startup 포함)

#### JobSystem 승진 후 퇴직 phantom salary
- 승진 보너스가 `monthly_income`에 누적된 뒤 `quit_job()`에서 `base_salary`만 차감하던 버그
- `current_job["effective_salary"]` 필드 도입으로 정확히 추적

### 캘린더 시스템
- **turn = 1주(週)**. 1개월 = 4턴. 5년 = 240턴 = 60개월. 종료 조건 = `age >= 38`.
- balance_sim / SimRun / 구 문서는 "turn=월" 모델로 작성돼 있었음 — **이미 인지된 기술 부채**.
- `_month_narration()` 에서 `t`(주 카운터)를 월로 잘못 쓰던 것 → `me = (age-33)*12 + month`(경과 개월)로 전면 교체 완료.
- 마감 힌트 `turns_left`: `60 - turn + 1` → `(38 - age)*12 - month + 1` 수정 완료.

### AP
- `GameState.gd` 선언 기본값 `action_points = 3` → **2**. 실제 `start_new_game()`은 항상 2로 세팅. 선언값만 정리. 게임 동작 무변.

### 챕터 카드 (chapter_cards.json)
- 5종: `chapter_card_33`(시작) / `34`(확장) / `35`(무게) / `36`(균열) / `37`(강남)
- 트리거: `_next_arc_id()` 최상단 — prologue_done → chapter_33_seen → 이후 age별 자동 발동
- 플래그 일치 확인: `chapter_33_seen` ~ `chapter_37_seen` set/read 완벽 매칭 (무한루프 없음)

### t9 반응형 씬 (arc_events.json)
- `arc_money_check_low` / `mid` / `high` — `get_total_asset_value()` 구간별 3가지 다른 씬
- `arc_gosiwon_wall` (t11, gosiwon 거주 중에만)

### 알바/편의점 개연성 수정
- `has_job: false` 조건이 `if bool(false)` → 항상 false인 버그 발견 → **`job_id: "job_01"` 조건으로 전면 교체**
- 편의점 점원 고정 씬(`rare_celeb_convenience` 등 5개) 수정
- `arc_intro_02_dad_call`: "편의점 야간 알바" → "고시원 방 새벽 3시" (무직자에게도 맞는 설정)
- `arc_jiyeon_02_store`: 플레이어=점원 → 플레이어=손님(편의점 나오는 중)
- `relationship_events.json`의 `daeun_meet` 삭제 (플레이어=점원 고정 모순)
- `arc_daeun_01_meet`에 `daeun_met` / `daeun_first_kind` 플래그 추가 (고아 에러 해소)
- `EventManager.gd`: `job_id` 조건 키 신규 추가

### instant_legend 히든 엔딩
- `age <= 33` + 자산 30억 → `finish_run("instant_legend")` 분기 (GameState.gd)
- endings.json: grade `"?"`, title "신화", background "gangnam_apartment"
- MainGame.gd: `"?": "#a855f7"` (보라) / `"?": "👁"` grade 표시 추가

### Chapter 1 고아 플래그 콜백 (callback_events_27.json)
- 7개 이벤트, t13~24 범위 발동:
  - `callback_parttime_survived` ← `considered_parttime`
  - `callback_budget_check_in` ← `budget_planned`
  - `callback_mid_goal_echo` ← `set_monthly_goal`
  - `callback_quiet_money_patience` ← `kept_quiet_money`
  - `callback_early_greed_humbled` ← `early_greed`
  - `callback_gosiwon_wall_echo` ← `knocked_on_wall`
  - `callback_stayed_grounded_echo` ← `stayed_grounded`

### SimRun.gd 루프 상한 수정
- `turn <= 64`(16개월) → `turn <= 244`(전체 5년) — 척추 증명이 실제 풀게임 길이를 커버하도록
- guard 상한 `300` → `260` (244 + 버퍼)

### 챕터1 루트·테마별 반응 이벤트 5종 (arc_events.json)
- `arc_ch1_invest_first_chart` ← `route_invest` 플래그, t>=8: HTS 첫 날
- `arc_ch1_career_first_spec` ← `route_career` 플래그, t>=8: 자소서 첫 줄 (3가지 선택지)
- `arc_ch1_startup_first_idea` ← `route_startup` 플래그, t>=8: 아이디어 노트
- `arc_ch1_theme_network_first` ← `theme_network_run` 플래그, t>=8: 재테크 스터디 첫 모임
- `arc_ch1_theme_invest_deep` ← `theme_invest_run` 플래그, t>=8: 차트 3시간
- `_next_arc_id()` t8 블록 뒤에 5개 트리거 추가 (route/theme → 해당 플레이어에게만 발동)

### 오딧 / 밸런스
- ERROR 0, WARNING 0 유지 중
- 밸런스 밴드: 무직 실패 100%, 직장 실패 0%, 베팅 30억 도달 14.8% — 전부 통과

---

## 세션 프로토콜

### 시작 (3분 이내)
1. 이 파일 (`CLAUDE.md`) — 현재 상태 블록 확인 ✓ (지금 읽는 중)
2. `docs/ROADMAP.md` — 현재 단계 `[ ]` 항목 확인
3. `docs/WORK_LOG.md` 최근 3개 항목 — 지난 세션 마무리 상태 확인
4. **유저 지시가 없으면 "다음 작업"부터 바로 시작**

### 종료 (매 작업 후 필수)
1. `CLAUDE.md` 현재 상태 블록 업데이트 (다음 작업 갱신)
2. `docs/ROADMAP.md` — 완료 항목 `[x]` 처리
3. `docs/WORK_LOG.md` — 날짜 + 작업 내용 추가
4. `docs/RELEASE_NOTES.md` — `## Unreleased`에 변경사항 추가
5. `docs/DECISIONS.md` — 설계 결정이 있으면 날짜 + 근거 기록
6. 수치 조정 시 `docs/BALANCE.md` 업데이트

### ⭐ 커밋 전 정적 감사 (필수)
```bash
./tools/audit.sh
```
플레이 없이 옛/새 시스템 모순을 잡는다:
1. **dangling 동적 호출** — `self.call("_x")`/`Callable(self,"_x")`/헬퍼에 넘긴 함수명이
   실제 정의돼 있는지 (← 문자열 호출이라 Godot 파싱을 통과해버리는 "눌러도 무반응" 버그)
2. **폐기 키워드** — 옛 설계 잔재(시작 나이·옛 마감·은퇴·가짜 랜덤 인물 이름 등) <!-- audit-ignore -->
   (코드 전체 + CLAUDE.md·STORY_BIBLE.md만 검사. 과거 로그 문서는 제외)
3. **이벤트 JSON 무결성** — 파싱/중복 id/없는 follow_up/없는 portrait·background·cg/빈 result_text
4. **플래그 교차 검증** — 코드/이벤트 조건이 읽는 플래그(`f.get`/`flags.get`/`flag`/`no_flag`/
   `cast_has_flag`)를 실제로 누가 set하는지 대조 (← 오타·이름 불일치로 패널/분기/이벤트가
   조용히 죽는 버그. 2026-06-10 도입 시점에 잠재 버그 15개 일괄 검출)
5. **serialize 완전성** — GameState var 선언 vs serialize() 키 대조 (← 저장 누락으로 로드 시
   조용히 리셋. transient 변수는 audit.py SERIALIZE_EXEMPT에 등록)
6. **이벤트 키 화이트리스트** — effects/conditions/opportunity/cast_effects 키를
   apply_effects·_check_conditions가 실제 처리하는 키와 대조 (← 오타 키가 조용히 무시되는
   버그. 2026-06-11 도입 시점에 죽은 효과 5건·죽은 조건 2건 검출)
7. **인물 stage 상태기계** — `content/meta/cast_stages.json`이 정본. 선언 안 된 stage를
   set/read하면 ERROR (← acquaint vs acquaintance 같은 "같은 단계의 두 이름" 서사 모순.
   **새 stage 추가 시 이 파일에 먼저 선언할 것**)
8. **밸런스 회귀 밴드** — balance_check.py가 핵심 정책 시뮬로 30억 도달률·실패율 밴드 검증
   (← 경제 파라미터 변경의 의도치 않은 파급. 의도된 변경이면 BALANCE.md 기록 + 밴드 갱신)
9. **죽은 아크 이벤트** — `min_turn>=9999`(트리거 전용)인데 코드/follow_up 어디서도
   호출 안 되는 이벤트 (← 구버전 아크가 신버전으로 교체되며 안 지워진 잔재 / `_next_arc_id`
   트리거 누락. 2026-06-22 도입 시점에 옛 지연 아크 16개 일괄 검출·제거)
10. **죽은 cast-stage 분기** — 코드/조건이 비교하는 cast stage인데 어떤 이벤트도 그 stage를
   set 안 하는 도달 불가 분기 (← 다은 with_daeun 엔딩이 committed를 안 보던 버그의 거울상.
   엔딩이 읽는 stage를 set하는 이벤트가 사라지면 조용히 죽는 분기를 잡는다)
11. **구조 부채 래칫** — write-only 플래그(set만 되고 조건/코드 참조 0) + inert 이벤트(선택지
   2개+인데 전 선택지 효과 동일) 수를 `tools/debt_baseline.json`에 고정. 초과하면 ERROR
   (← 난개발이 다시 자라지 못하게. 정리로 수가 줄면 baseline 낮춰 톱니 조임)
12. **Godot 헤드리스 파싱** (로컬 Godot 필요 — 없으면 CI가 수행)

ERROR 0 이면 통과. **새 함수·이벤트·인물·플래그·stage 추가 후 반드시 돌릴 것.**
푸시하면 GitHub Actions(`.github/workflows/ci.yml`)가 같은 감사 + Godot 컴파일/SimRun을 돌린다.

### JSON 수정 후
```bash
python3 -c "import json; json.load(open('파일.json'))"
```

### 새 이벤트 추가 시 체크
- `id`는 `snake_case`, 전체에서 고유
- `result_text` 반드시 채울 것 (빈 문자열 금지)
- `cooldown` 최소 3 이상 권장
- `conditions`가 없으면 `{}`

---

## 프로젝트 개요

- **한 줄 정의**: 33세 백수 김민준이 통장 50만원으로 시작해 5년(38세) 안에 자산 30억을 모아 강남에 입성하는 한국 사회 리얼리티 인터랙티브 드라마
- **장르**: 인터랙티브 드라마 / 비주얼노벨 (드라마처럼 "보는" 게임)
- **엔진**: Godot 4.6 (GDScript)
- **주요 언어**: 한국어 (UI, 이벤트, 뉴스, 설명)
- **설계 바이블**: `docs/GAME_DESIGN.md` — 반드시 읽고 기능을 추가할 것

---

## 디렉토리 구조

```
GangnamDream/
├── CLAUDE.md                  ← 이 파일 (항상 먼저 읽기)
├── project.godot
├── autoloads/
│   ├── DataRegistry.gd        # JSON 콘텐츠 로더 & 인덱스
│   ├── GameState.gd           # 런 상태, 스탯, 돈, 플래그, 직업, 관계, 포트폴리오
│   │                          # + route_orthodox/unorthodox, month_focus, housing_months
│   ├── EventManager.gd        # 조건/가중치/쿨다운/연쇄 이벤트
│   ├── NewsManager.gd         # 월별 뉴스 생성 & 시장 영향
│   ├── MetaProgression.gd     # 런 히스토리, 업적, 칭호(29개) 해금
│   └── SaveManager.gd         # 자동저장 + 다중 슬롯
├── content/
│   ├── events/
│   │   ├── life_events.json        # ~113개 일반 이벤트
│   │   ├── investment_events.json  # 30개 투자 이벤트
│   │   ├── relationship_events.json # 30개 관계 이벤트
│   │   └── hidden_events.json      # 20개 히든/희귀 이벤트
│   ├── assets.json            # 투자 자산
│   ├── jobs.json              # 직업 15개
│   ├── items.json             # 아이템 28개
│   ├── endings.json           # 엔딩 10개
│   ├── news_templates.json    # 뉴스 템플릿 79개
│   └── meta/default_meta.json # 메타 초기값 (unlocked_titles 포함)
├── systems/
│   ├── InvestmentSystem.gd    # 매수/매도, 레버리지, 마진콜, 배당
│   ├── JobSystem.gd           # 취업/퇴직/승진
│   ├── RelationshipSystem.gd  # 관계 패시브, 소멸
│   ├── InventorySystem.gd     # 아이템 구매/사용
│   └── EndingSystem.gd        # 엔딩 조회 & 점수
├── scenes/
│   ├── StartMenu.tscn / .gd   # 시작 화면, 저장 슬롯 (드라마 모드: 고정 시작)
│   └── MainGame.tscn / .gd    # 메인 대시보드 UI
├── ui_components/
│   ├── StatRow.gd
│   └── NotificationToast.gd
└── docs/
    ├── GAME_DESIGN.md         ← 게임 설계 바이블 (반드시 읽기)
    ├── ROADMAP.md             ← 개발 단계 & 체크박스
    ├── WORK_LOG.md            ← 날짜별 작업 기록
    ├── RELEASE_NOTES.md       ← 버전별 변경사항
    ├── DECISIONS.md           ← 설계 결정 근거
    ├── BALANCE.md             ← 밸런스 조정 이력
    └── BUILD_NOTES.md         ← 빌드/테스트 기록
```

---

## 핵심 설계 규칙 (불변)

### GDScript 아키텍처
- 모든 게임 데이터는 `content/` JSON으로 관리. 스크립트 하드코딩 금지.
- 전역 상태는 `GameState` autoload에만 저장.
- 시스템 스크립트(`systems/`)는 `GameState`를 읽고 쓰되 서로 직접 참조하지 않는다.
- UI는 `MainGame.gd`에서 `_refresh_all()`로 일괄 갱신.
- `stats_changed` 시그널 발생 → `_refresh_all()` 자동 호출.

### JSON 이벤트 형식
```json
{
  "id": "unique_snake_case_id",
  "title": "이벤트 제목",
  "description": "상황 설명 (2-4문장)",
  "category": "finance|family|jobs|social|gambling|health|investment|relationship|disasters|politics|comedy|military",
  "rarity": "common|uncommon|rare|legendary",
  "weight": 1.0,
  "hidden": false,
  "conditions": {
    "min_money": 0, "max_stress": 100, "min_intelligence": 0,
    "has_job": true, "flag": "flag_name",
    "min_route_orthodox": 0, "min_route_unorthodox": 0,
    "month_focus": "투자"
  },
  "tags": ["tag1", "tag2"],
  "cooldown": 6,
  "choices": [
    {
      "text": "선택지 텍스트",
      "effects": {
        "money": 100000, "health": -5, "mental": 3,
        "stress": -2, "intelligence": 1, "social_skill": 0,
        "investment_skill": 2, "luck": 0, "reputation": 1
      },
      "flags": ["flag_to_set"],
      "follow_up_event": "",
      "result_text": "선택 후 결과 텍스트 (1-3문장, 빈 문자열 금지)"
    }
  ]
}
```

### 엔딩 ID 매핑
| `finish_run()` 호출 | endings.json id |
|---|---|
| `finish_run("burnout")` | `burnout` |
| `finish_run("mental_break")` | `mental_break` |
| `finish_run("bankruptcy")` | `bankruptcy` |
| `finish_run("stable_success")` | `stable_success` |
| `finish_run("ordinary_life")` | `ordinary_life` |
| `finish_run("gangnam_dream")` | `gangnam_dream` |

특수 엔딩: `crypto_ghost`, `startup_exit`, `political_fix`, `lonely_rich`

---

## 밸런스 기준값

| 항목 | 값 |
|---|---|
| 시작 자금 | 500,000원 (백수, 통장 50만원) |
| 시작 나이 | **33세** (김민준) |
| 마감 기한 | **38세 = 5년 = 60개월 = 240턴(주)** (`age >= 38` 타임리밋) |
| 기본 고정 지출 | 650,000원/월 (고시원) → 원룸/빌라/아파트 전세 (HOUSING_DATA) |
| 건강 초기값 | 65 / 정신력 60 |
| 스트레스 초기값 | 35 |
| 월별 스트레스 자연 증가 | +3 (무직 시 추가 +3, 총 +6) |
| 월별 건강 자동 감소 | -2 |
| 월별 정신력 자동 감소 | -3 (무직 시 추가 -2, 총 -5) |
| **강남 입성(승리) 조건** | **총자산 30억 이상** → `finish_run("gangnam_dream")` |
| 파산 조건 | 순자산(현금+포트폴리오-대출) -1억 이하 (부채 나락 -2억) |
| 대출 | 신용등급(1~10, 직장·근속·소득·자산·부채로 산정)이 한도·금리 결정. 1금융 월 0.4~0.88%(연 ~4.9~11.1%)·소득 18~6배·7등급 이내 / 2금융 월 1.10~1.53%(연 ~14~20%)·4,600만~1,000만. **변동금리. 한국 법정 최고금리 연 20% 클램프(LEGAL_MAX_MONTHLY_RATE).** |

---

## 알려진 미구현 / 다음 작업

현재 코드 레이어는 모두 구현 완료. 아래는 로컬 Godot 필요 항목:

- **QA 플레이스루** — 실제 실행 후 스크립트 에러·UI 레이아웃·클릭 흐름 검증
- **빌드/Export 패키징** — Godot Export Templates 설치 후 Web/PC 빌드
- **스토어 페이지 소재** — 스크린샷, 설명문, 태그 (선택사항)

### 구현 완료 항목 (이전 TODO)
- ✅ `NotificationToast.gd` 연동
- ✅ 엔딩 화면 메타 진행도 업적 해금 표시
- ✅ `appearance` 스탯 효과 (직업 요건 3종 + 연애 호감도 감소 완화)
- ✅ 직업별 이벤트 트리거 조건 (`min_job_tier`, `max_job_tier`, `job_category`)
- ✅ 투자 차트 히스토리 시각화 (스파크라인, 수익률 요약)
- ✅ 관계 패널 능동 상호작용 (유형별 전용 선택지 모달)
- ✅ 특수 엔딩 6종 도달 경로 구현
- ✅ 배경 이미지 19종 이벤트 자동 매핑
- ✅ 엔딩 화면 배경 전환 (penthouse/burnout/gangnam_night/rooftop)
- ✅ FM SFX 14종 + BGM 6트랙 (AudioManager + BGMPlayer)
- ✅ Pretendard 한국어 폰트 적용
- ✅ 런 테마 시스템 (매 런 카테고리 2개 부스트)
- ❎ 트레이트(특성) 시스템 — 드라마 피벗으로 제거. 성향(tendency) 자각 시스템으로 대체.
