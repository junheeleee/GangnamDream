# Gangnam Dream Recording And Sample Palette

Updated: 2026-07-23

이 파일은 더 이상 생성형 음악 프롬프트 모음이 아니다. 강남드림 출시
오디오의 녹음·샘플 선택과 후반 작업 기준이다.

## 절대 규칙

- 원음은 실제 현장/사물 녹음 또는 녹음된 실악기 샘플만 사용한다.
- 오실레이터, 생성 노이즈, 코드 파형, 합성 피아노/벨/클릭, 런타임 합성
  폴백을 사용하지 않는다.
- 컷 편집, 레이어, 루프, 리샘플링, 제한된 피치 이동, EQ, 컴프레션,
  리버브와 러드니스 정규화는 허용한다.
- 잘못된 소리는 무음보다 나쁘다. 장면과 맞지 않으면 semantic key를
  유지한 채 다른 녹음으로 교체한다.
- 모든 출력은 `AUDIO_SOURCE_MANIFEST.json`에 원본 파일명, 라이선스,
  원본·출력 SHA-256과 편집 이력을 남긴다.

## 출시 팔레트

| 계층 | 팔레트 | 금지 |
|---|---|---|
| 음악 | Yamaha C5 실제 녹음 샘플로 연주한 절제된 피아노, 충분한 무음과 잔향 | 로파이 비트 상시 반복, 신스 패드, 모바일 보상 징글 |
| 장소 | 서울의 교통·비·HVAC·냉장고·방·물·군중 현장 녹음 | 합성 바람/비/룸톤, 장소와 무관한 범용 노이즈 |
| 사람층 | 말이 식별되지 않는 실제 군중과 생활 기척 | 텍스트 언어와 충돌하는 알아들을 수 있는 외국어 대사 |
| UI | 종이, 카드, 얕은 래치, 작은 기계 접점의 실제 녹음 | 레이저, 뿅 소리, 음정형 클릭, 매 포커스 이동 효과음 |
| 카지노 | 실제 카드, 칩, 주사위, 휠·기계 접점 | 한 효과음을 카드·칩·주사위에 공용 사용 |
| 경마 | 실제 말발굽, 출발 게이트, 실제 군중의 단계적 상승 | 짧은 발굽 한 번의 기계적 반복, 합성 환호 |
| 장면 폴리 | 전화 진동, 종이, 문, 발걸음, 계산대, 컵, 교통의 실제 녹음 | 산문을 전부 효과음으로 밑줄 긋기 |

## 음악 역할

- `menu`, `early`, `hustle`, `late_tense`는 로비 전용이다. 일반 서사에
  자동으로 흘리지 않는다.
- `family`, `survival`, `hyunsu`, `ambition`, `daeun`, `jiyeon`은 인물과
  주제의 짧은 실피아노 모티프다. 장면 경계마다 처음부터 재시작하지 않는다.
- `intimate`, `reckoning`, `grief`, `wonder`, `wedding_processional`은
  명시된 정점 문단만 소유한다. 감정을 미리 스포일러하지 않는다.
- `casino_floor`와 `casino_table`은 같은 92 BPM·16마디·동일 위상의 두
  편곡이다. 테이블 진입은 재시작이 아니라 같은 재생 위치의 압력 상승이다.
- 한 번 재생하는 테마는 억지 루프하지 않는다. 루프 곡은 녹음 잔향을
  시작부로 감아 이음새를 숨기되 박자 길이를 바꾸지 않는다.

## Moral Tint의 소리

장소의 실제 기계음과 날씨는 남는다. Black으로 갈수록 별도의 사람 기척만
멀어지고 좁아지며, White로 갈수록 공기와 생활감이 돌아온다. 선악 징글,
도덕 점수 음성, 과장된 공포 드론은 넣지 않는다. 플레이어가 설명을 듣기
전에 서울에서 사람이 사라졌다는 사실을 뒤늦게 깨닫게 한다.

## 소스 라이브러리

현행 134개 마스터는 다음 여덟 라이브러리에서만 출발한다.

- Sonniss GDC 2026 Game Audio Bundle: 현장음·폴리·기계·군중
- Owlish Media Sound Effects: 종이·천·전화·물·발걸음
- Kenney Casino Audio 1.1: 카드·칩·주사위
- Horse Gallop on Different Surfaces: 말발굽
- Salamander Grand Piano V3: Yamaha C5 실악기 샘플
- Keyboard Soundpack #1: 타건
- Storm & Siren: 사이렌
- Crash Collision: 충돌

정확한 URL, 저작자, 라이선스와 고지는 `AUDIO_SOURCE_LEDGER.md`,
`AUDIO_THIRD_PARTY_NOTICES.md`, `AUDIO_SOURCE_MANIFEST.json`을 따른다.

## 빌드와 차단 게이트

```bash
python3 tools/build_sample_audio_assets.py --validate-only
python3 tools/build_sample_audio_assets.py
python3 tools/audio_source_audit.py
```

`build_sample_audio_assets.py`는 녹음 파일의 디코드·편집·믹스와 실피아노
샘플 시퀀싱만 수행한다. 이전 `generate_audio_assets.py`,
`generate_audio_p1_assets.py`, `generate_gangnam_ui_sfx.py`,
`generate_launch_audio.py`는 읽기 전용 호환 감사기로 퇴역했으며 파일을
생성할 수 없다. 런타임도 누락 파일을 합성해 채우지 않는다.

자동 PASS는 출처, 해시, 길이, 무음, 클리핑, 로드와 배선만 증명한다.
프롤로그 전체, 45~90분 데모, 카지노 10연속 라운드, 결혼식과 엔딩은
헤드폰·노트북 스피커·거실 TV에서 사람이 들어야 출시 승인된다.
