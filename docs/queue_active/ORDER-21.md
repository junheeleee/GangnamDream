# Active Queue Spec: ORDER-21

> Canonical status is indexed in `docs/CODEX_QUEUE.md`. This file preserves the full active specification so sessions only load the order they are executing.

#### [~] ORDER-21 [P1] 일본어 번역 웨이브 — ⛔ 부분 보류 (Claude 판정 2026-07-13, 유저 지시)
**보류 범위: 본문 번역(`content/events_ja/**`·`endings_ja`) 생성 중단.** 사유: 유저가 데모 체감 미완을 제기 — 데모 피드백 수리가 Y1 텍스트를 다시 쓸 수 있어 지금 번역=재작업. **계속 허용(인프라성)**: 용어집·호칭 정본표·폰트 번들·파이프라인/게이트 도구·ui_ja 표면 사전. **본문 번역 재개 조건: 유저의 데모 GO 판정** (실플레이 후). 이미 생성된 본문이 있으면 커밋은 유지하되 계속 생성하지 말 것.
**인프라 착수 — 만지는 파일:** `docs/I18N_GLOSSARY_JA.md`, `locale/ui_ja.json`, `assets/fonts/NotoSansJP-*`, `assets/fonts/OFL-NotoSansJP.txt`, `autoloads/FontKit.gd`, `autoloads/UIStyle.gd`, `tools/i18n_coverage_check.py`, `tools/multilingual_surface_audit.py`, `tools/ja_translation_pipeline.py`, `tools/ja_translation_audit.py`, `tools/I18nInfrastructureCheck.gd`, `tools/ScreenshotQA.gd`, `tools/audit.sh`, `docs/I18N_INFRASTRUCTURE.md`, `docs/QA_CHECKLIST.md`, `docs/CODEX_QUEUE.md`, `docs/WORK_LOG.md`, `docs/RELEASE_NOTES.md`, `CLAUDE.md`.
1. **선행 산출물**: `docs/I18N_GLOSSARY_JA.md` — 용어집(고시원=コシウォン(gloss)/전세/9급/라면=ラーメン 등) + **호칭 정본표**: 다은→"ミンジュンさん"+です・ます체(진심의 격식) / 지연→"オッパ"(オッパ 표기 유지)+タメ口는 연애 확정 후(도도·직설 — 그 전엔 です체) / 민준→두 여성에게 です・ます 기조. 부끄러움 문법 주석 포함.
2. **번역**: KR 원본 기준(EN 아님 — 중역 금지), events_ja/ 오버레이 + endings_ja + ui 사전. 산문 밀도 유지(§8 톤 — 축역 금지), dik 패리티 필수.
3. **검증**: 언어 일반화된 coverage/패리티 게이트 + ScreenshotQA ja 표본 15컷(줄바꿈·글리프).
4. **네이티브 스팟체크 게이트**: 핵심 20씬(§8 레지스트리) 목록을 뽑아 유저에게 전달 — 네이티브 검수자 확보는 유저 몫. 검수 반영 전까지 "베타 번역" 딱지.
5. zh-CN 웨이브는 ja 파이프라인 검증 후 별도 오더.

**인프라 진행 보고 (2026-07-14 Codex):** 공식 Noto Sans JP 가변 TTF와 OFL을 번들하고 프로젝트 폰트 폴백으로 연결해 히라가나·가타카나·한자·문장부호 실글리프와 1280x800 줄바꿈을 통과했다. KR 정본 직역 파이프라인은 기본 UI 전용이며 `events/endings/catalog`은 명시적 `--allow-body` 없이는 `BODY_TRANSLATION_HELD`로 실패한다. UI 표면 1,957개를 원문 대조 교정해 `ui_ja` 베타로 채우고 한글·엔화·자리표시자·줄바꿈·호칭·도박/트리플·잠금/해금 극성 감사를 전체 audit에 연결했다. 일본어는 여전히 선택 화면·Steam에서 비노출이며, 이벤트·엔딩·카탈로그 본문과 15컷·네이티브 검수는 유저 데모 GO 전까지 보류한다. 따라서 ORDER-21은 `[~]` 유지한다.
