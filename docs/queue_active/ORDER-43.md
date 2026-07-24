# Active Queue Spec: ORDER-43

> Canonical status is indexed in `docs/CODEX_QUEUE.md`. This file preserves the full active specification so sessions only load the order they are executing.

#### [~] ORDER-43 [P0·오디오 REWORK] 파형 합성 전면 퇴출 — 실제 녹음·샘플 기반 팔레트
**[~] 착수 (2026-07-23 Codex) — 만지는 파일:** `docs/CODEX_QUEUE.md`, `CLAUDE.md`, `docs/DECISIONS.md`, `docs/AUDIO_QA.md`, `docs/DEMO_FIXLOG.md`, `docs/QA_CHECKLIST.md`, `docs/WORK_LOG.md`, `docs/RELEASE_NOTES.md`, `assets/audio/AUDIO_SOURCE_LEDGER.md`, `assets/audio/AUDIO_PROMPTS.md`, 신규 오디오 출처·크레딧 원장, `assets/scene_audio_manifest.json`, `assets/game_audio_manifest.json`, `assets/mod_asset_manifest.json`, `autoloads/BGMPlayer.gd`, `autoloads/AudioManager.gd`, `tools/generate_audio_p1_assets.py`, `tools/audio_source_audit.py`, `tools/scene_audio_contract_check.py`, `tools/AudioAssetCheck.gd`, `tools/BGMContinuityCheck.gd`, `tools/GameAudioContractCheck.gd`, 신규 샘플 임포트 도구, 교체 대상 `assets/audio/*.wav`, `assets/audio/*.ogg`와 각 `.import`. 기존 사용자 변경 `project.godot`은 건드리지 않는다.

**사용자 청취 NO-GO (2026-07-23):** "소리가 전혀 안어울려" / "무슨 뿅뽀ㅛㅇ뿅 스페이스 슈팅게임같아" / "모든 소리를 파형 코드합성 절대 하지말고 실제녹음과 샘플기반 팔레트로 만들어". ORDER-42의 길이·RMS·배선 자동 PASS는 청취 실패를 뒤집지 못한다. `sine/square/tri/bell/noise` 파형으로 피아노·폴리·룸톤을 흉내 낸 소스 선택이 원인이다.

**불변 규칙:** 출시 표면의 음악·앰비언스·폴리·UI·미니게임 효과음은 실제 현장 녹음 또는 실악기/상업 샘플 라이브러리 기반 렌더만 허용한다. 원본 녹음의 편집·레이어·EQ·컴프레션·리버브·루프·러드니스 정규화는 허용하지만, 오실레이터/노이즈 생성으로 원음을 만드는 코드와 런타임 `_tone` 대체음은 출시 등록 키에서 금지한다. 모든 파일은 출처 URL·저작자/공급자·라이선스·원본 파일명·SHA-256·편집 내역을 원장에 가진다.

**범위 확장 (2026-07-23 Codex) — 추가로 만지는 파일:** `tools/generate_audio_assets.py`, `tools/generate_gangnam_ui_sfx.py`, `tools/generate_launch_audio.py`. 네 합성 생성기는 출시 에셋을 쓸 수 없도록 퇴역시키고, `autoloads/BGMPlayer.gd`의 `_bake_procedural` 및 `autoloads/AudioManager.gd`의 `_tone/_chord` 누락 폴백도 제거한다. 파일 누락은 전자음 대체가 아니라 명시적 오류·무음으로 실패하며 감사에서 차단한다.

**RC 원장 범위 확장 (2026-07-23 Codex) — 추가로 만지는 파일:** `docs/BUILD_PIPELINE.md`. ORDER-43 구현 커밋의 별도 clean worktree에서 만든 Windows/macOS/Linux·Steam Deck 데모 revision·tree·매니페스트·산출물 SHA-256과 macOS 패키지 부팅 결과를 외부 표본 정본으로 교체한다.

**실행 순서:** ①신규 합성 모티프·폴리·룸톤을 즉시 격리해 잘못된 전자음이 재생되지 않게 한다 ②상업 이용 가능한 실제 녹음 SFX 라이브러리와 샘플 연주 음악을 확보한다 ③프롤로그 10분을 우선 재구성해 청취 기준점을 만든다 ④승인된 팔레트만 데모 24주와 본편에 확산한다 ⑤합성 자산 재유입 금지 감사와 clean 3플랫폼 RC를 통과한다. 자동 게이트 완료 뒤에도 사용자 청취 GO 전에는 닫지 않는다.

**진행 보고 (2026-07-23 Codex):** BGM 20·앰비언스 47·SFX 67, 총 134개를 실제 현장/사물 녹음과 녹음된 Yamaha C5 샘플 기반으로 교체했다. Sonniss·Owlish·Kenney·Horse Gallop·Salamander Piano·Keyboard Soundpack·Storm & Siren·Crash Collision 8개 라이브러리의 URL·저작자·라이선스·원본 파일명·원본/출력 SHA-256·편집 이력을 파일별 매니페스트에 고정했다. 네 합성 생성기와 런타임 합성 폴백을 퇴역시켰고 출처 감사는 `recordings_or_samples=134 procedural=0`을 통과했다. Godot 134개 재임포트, 장면/게임 계약, KO PlayStation·EN Xbox 24주 각 630/634입력과 전체 55스크립트 감사도 통과했다. clean revision `cf9208533449a99a11e24f0844fc09398bf670f0`, tree `13743beba3084893e397d96fd2d374952ff9c9d5`에서 Windows/macOS/Linux·Steam Deck RC를 발급하고 3종 해시를 재검산했으며 macOS 패키지도 격리 HOME에서 부팅했다. 매니페스트 SHA-256은 `1bf5033935811a8e86867c25ef5b173090ffa3dda85c214690de00e373c00d46`이다. 사용자 청취는 OPEN이므로 `[~]`를 유지한다.

**데모 장소음 후속 보고 (2026-07-23 Codex):** 사용자의 고시원 야외 소음 지적 뒤 24주 소스 의미를 전수 추적했다. 고시원에 섞인 지하철 역사, 편의점의 푸드코트, 사무실/학교의 지하철 홀, 체온계 스캐너, 트럭 버스, 스포츠 관중 결혼식, 라디오 룰렛, 줄자·계수기 슬롯, 자동차 문 경마 게이트를 제거했다. 고시원은 아파트 룸톤·냉장고·시계와 긴 무음 간격의 천·기침·수도·복도 발걸음으로 재구성하고 전용 복도 베드를 분리했다. 편의점·사무실·병원·헬스장·카지노·결혼식과 주요 사물음은 실제 해당 공간/물체 CC0 녹음을 고정했다. 프롤로그 페이지·펜·옷 폴리를 추가하고 계산대·면접 서류·전화 진동을 실제 문단으로 이동했으며 `night→rain` 추론을 삭제했다. 현행 인벤토리는 BGM 20·앰비언스 49·SFX 70, 총 139개·소스 레코드 20개·합성 0이다. Ogg 20곡은 파일명 기반 스트림 시리얼·페이지 CRC로 결정화해 전체 139개 연속 두 빌드의 해시가 일치한다. 출처 의미 감사, Godot 139개 로드, 장면/게임/Moral/BGM 연속성, KO/EN `demo-flow` 16컷이 통과했다.

**데모 완주 프로필 범위 확장 (2026-07-23 Codex) — 추가로 만지는 파일:** `docs/DEMO_EXPERIENCE_AUDIT.md`. 장소음 수리 뒤 빠른 렌더만으로 패리티를 주장하지 않고 KO PlayStation·EN Xbox 24주 실제 입력 프로필을 다시 발급한다. 사건/선택/직접 결정, 장소음·사람층·음악 키, 마지막 사건과 입력 수를 양언어 비교하며 게임 규칙이나 본문은 바꾸지 않는다.

**최신 RC 보고 (2026-07-23 Codex):** KO PlayStation·EN Xbox 실제 24주를 630/634입력으로 다시 완주해 동일 46사건·35선택·11장소음·5사람층·10음악 키·41명시 음악 사건과 마지막 `hyunsu_exam_day`를 확인했다. 전체 `audit.sh`는 55개 GDScript 컴파일까지 `✅ 감사 통과`했다. 별도 clean worktree의 revision `eceeb6e78799d9b3c775f03bdf2475fbcbb4a78d`, tree `da84bb080e42d8888f85e9b211b3f19d8662c2d3`에서 fresh import·데모 계약 뒤 Windows/macOS/Linux·Steam Deck RC를 발급했다. 매니페스트 SHA-256은 `b383f4eda8e2a01a54ef1137d2f686a62e45a64c2861f65ec905a64813e2a94e`, 산출물은 Windows `9d18ff6006341ca64e5f251382c4d151060a7df39116c51296dd93cea8423536`, macOS `8c077120813ce36d12796fa4267252efa3b2546a92357e866086d8c4921b5ffb`, Linux·Steam Deck `9780488b08db3b9ee6bfe4c93a1ad9f15257d3a29cffb51aafc7f76c52ec7a25`다. 로컬 복사 뒤 3종을 재검산했고 macOS 패키지는 격리 HOME에서 실제 부팅해 신규 오디오 리소스를 오류 없이 로드했다. 구현·배포 후보는 완료됐지만 사람 연속 청취 전까지 ORDER-43은 `[~]`를 유지한다.
