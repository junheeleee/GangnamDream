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

## 본편 240주 전 구간 확산 (OPEN — 2026-07-24 사용자 지시)

데모 24주의 세밀한 오디오 수리는 본편 승인으로 간주하지 않는다. 현재 자동 계약은
활성 CG 74종, Tier-1 정점 사건 116종, 데모 사건 45종을 강하게 보호하지만 전체
카탈로그 1,565종의 5개 장 체험이 같은 밀도와 연속성을 갖는다는 증거는 아니다.

**후속 착수 시 추가로 만질 파일:** `assets/scene_audio_manifest.json`,
`assets/game_audio_manifest.json`, `autoloads/BGMPlayer.gd`,
`autoloads/AudioManager.gd`, `tools/scene_audio_contract_check.py`,
신규 전 구간 오디오 커버리지·런타임 추적 검사, `docs/AUDIO_QA.md`,
`docs/QA_CHECKLIST.md`, `docs/MASTER_RELEASE_AUDIT.md`,
`docs/CODEX_QUEUE.md`, `docs/WORK_LOG.md`, `CLAUDE.md`. 새 원음이 필요할 때만
출처 원장과 `assets/audio/`를 범위에 추가한다. `project.godot`은 제외한다.

### 적용 범위

1. **전 사건 의도 분류:** 모든 사건을 `명시 장면 계약`, `장소/계절/상태 프로필로
   해결`, `의도된 무음` 중 하나로 분류한다. 미분류와 우연한 기본 BGM 폴백은 0이어야
   한다.
2. **작성형 장면 확산:** 1~5장의 아크·관계·가족·직업·투자·상철·재혁·현수·지연·다은
   장면에 데모와 같은 장소음, 사람층, 원격 통신, 문단 타이밍 폴리, 지연된 음악 진입
   계약을 적용한다.
3. **랜덤 사건 절제:** 랜덤 사건은 장소와 실제 행동이 있을 때만 프로필 환경음과 물리
   폴리를 쓴다. 1,565개 모두에 효과음을 억지로 붙이지 않으며, 무음도 명시된 연출로
   기록한다.
4. **연속성:** 같은 장소·같은 체인의 환경음과 음악은 재시작하지 않는다. 이동,
   회상, 전화, 결과 배경, 미니게임 진입·복귀는 화면 전환과 같은 프레임에서
   크로스페이드하며 이전 장면 소리를 남기지 않는다.
5. **게임 활동:** 직업·투자·카지노·홀덤·경마의 반복 플레이는 물리 단계음,
   장소음, 음악 소유권과 피로도를 각각 검사한다. UI 확인음으로 물리 결과를
   대체하지 않는다.
6. **결말:** 엔딩 35종은 각 전용 CG의 장소·행동과 환경음이 일치해야 하며, 결말을
   미리 판정하는 승리/실패 징글은 사용하지 않는다.

### 완료 게이트

- 현재 카탈로그 전체에서 오디오 의도 미분류 0, 잘못된 장소 키 0, 존재하지 않는
  음원 키 0, 코드 합성 원음 0.
- 정석/사람 중심과 비정석/Black 대표 경로를 KO/EN 동일 시드로 각각 240주 완주해
  장별 장소음·사람층·음악·폴리 추적이 언어 간 일치한다.
- 5개 장 모두 대표 정점, 연결 장면, Quiet/Echo, 활동, 엔딩 표본을 포함하며 같은
  트랙의 불필요한 재시작과 장면 밖 잔류가 0이다.
- 장별 대표 경로를 이미지와 함께 헤드폰, 노트북 스피커, 거실 TV에서 연속 청취한다.
  대사 가독성, 장소 식별, 음악 피로, 효과음 반복, Moral 사람층 변화가 모두 GO여야
  한다.
- 전 구간 확산 뒤 새 clean Windows/macOS/Linux·Steam Deck RC를 발급한다. 기존
  데모 RC 해시는 최종 본편 오디오 승인 증거로 재사용하지 않는다.

### 자동 확산 보고 (2026-07-26 Codex)

- `scene_audio_manifest` version 11에서 한영 사건 1,565개를 사건 계약 225,
  CG 상속 6, 렌더 배경 프로필 1,334, 의도된 무음 0으로 중복 없이 분류했다.
  이미지 레지스트리의 배경 91종도 모두 명시 프로필을 가지며 신규·삭제 ID는
  `scene_audio_catalog.py`가 즉시 차단한다.
- 런타임의 제목·본문·태그·카테고리 키워드 추론과 보편적 고시원 방 폴백을
  제거했다. `current_housing`과 `current_workplace`만 실제 상태를 읽고,
  미검토 배경은 경고와 무음으로 실패한다.
- 정석/사람 중심과 비정석/Black 대표 경로를 한영 동일 구조로 240주씩
  추적했다. 총 960주에서 5개 장의 작성형 장면·프로필 연결부·음악 진입,
  활동 7종, 엔딩 2종의 소유권과 언어 패리티를 검증했다.
- 전체 `audit.sh`는 사건 1,565개, 오디오 139개, 합성 원음 0, 장면·게임·
  Moral·BGM 연속성, 한영 표면과 Godot 54개 스크립트 컴파일까지 통과했다.
- clean revision `e849a6af2aed4aa1c7fc5a7785f59ac1b7ac952d`, tree
  `95a0674b05987efd62558f7aab09a64df0056042`에서 fresh import·데모 계약과
  Windows/macOS/Linux·Steam Deck export를 통과했다. 매니페스트 SHA-256은
  `26287c8124bb0838dbe2062f5d8072d819b164569162af773c091ad28b644cab`,
  산출물은 Windows `ea0ab3fe50ff2a5038a23c6cd573c94963b0faacfb850e88726ba91c5806111f`,
  macOS `4495d2424b13bad545870bacc7a460b2764895c20f7d39dd8331a69676e232cd`,
  Linux·Steam Deck `6858217e11fc6820d00f5be4cacb13e16e7f859ad534aefbfa572449bd95a55a`다.
  로컬 복사 뒤 세 파일을 재검산했고 macOS 패키지는 격리 HOME에서 부팅했다.
- 남은 게이트는 장별 대표 경로의 헤드폰·노트북·거실 TV 연속 청취뿐이다.
  자동 추적과 패키지 부팅은 사람 청취 GO를 대신하지 않는다.
