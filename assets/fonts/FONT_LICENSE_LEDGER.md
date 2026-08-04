# FONT_LICENSE_LEDGER.md — 서체 출처·라이선스 원장

> 오디오의 `AUDIO_SOURCE_MANIFEST.json`과 같은 규율이다. **저작권·버전 문구는
> 요약 페이지가 아니라 배포된 폰트 파일의 `name` 테이블(nameID 0·5·13·14)에서
> 직접 읽어 옮겼다.**

## 규율

- **SIL OFL·CC0 등 임베딩과 재배포가 명시적으로 허용된 것만** 쓴다.
- `무료 상업 이용 가능`과 `폰트 파일 임베딩 가능`은 다르다. 라이선스 원문의
  embedding·redistribution 조항을 직접 확인한다.
- **OFL은 라이선스 사본 동봉을 요구한다.** 이 원장의 모든 서체는
  `assets/fonts/` 안에 사본을 갖는다. 사본 없는 서체는 출시 차단이다.
- 서체를 교체·추가하면 이 표를 같은 커밋에서 갱신한다.

## 채택 서체

| 파일 | 패밀리 | 버전 | 저작권 | 라이선스 사본 | 역할 | SHA-256(앞 16) |
|---|---|---|---|---|---|---|
| `Pretendard-Regular.ttf` | Pretendard | 1.309 | Copyright © 2023 Kil Hyung-jin | [`OFL-Pretendard.txt`](OFL-Pretendard.txt) | 본문 | `6d0af5258997aec7` |
| `Pretendard-Medium.ttf` | Pretendard | 1.309 | Copyright © 2023 Kil Hyung-jin | [`OFL-Pretendard.txt`](OFL-Pretendard.txt) | 본문 | `3bae579377eb8e9a` |
| `Pretendard-SemiBold.ttf` | Pretendard | 1.309 | Copyright © 2023 Kil Hyung-jin | [`OFL-Pretendard.txt`](OFL-Pretendard.txt) | 본문 | `5e1c548732af7087` |
| `Pretendard-Bold.ttf` | Pretendard | 1.309 | Copyright © 2023 Kil Hyung-jin | [`OFL-Pretendard.txt`](OFL-Pretendard.txt) | 본문 강조 | `c16b88c670d23e83` |
| `NotoSansJP-Variable.ttf` | Noto Sans JP | 2.004-H2;hotconv 1.0.118;makeotfexe 2.5.65603 | (c) 2014-2021 Adobe (http://www.adobe.com/), with Reserved Font Name 'Source'. | [`OFL-NotoSansJP.txt`](OFL-NotoSansJP.txt) | 일본어 | `c2f3b4d463500a2d` |
| `NotoColorEmoji.ttf` | Noto Color Emoji | 2.051;GOOG;noto-emoji:20250818:e92753bfa55fd449e427d4d325f9c8c40408c74e | Copyright 2022 Google Inc. | [`OFL-NotoColorEmoji.txt`](OFL-NotoColorEmoji.txt) | 이모지 폴백 | `72a635cb3d2f3524` |

## 패밀리 출처

| 패밀리 | 제공자 | 공식 출처 |
|---|---|---|
| Pretendard | Kil Hyung-jin | https://github.com/orioncactus/pretendard |
| Noto Sans JP | Adobe and Google | https://github.com/notofonts/noto-cjk |
| Noto Color Emoji | Google | https://github.com/googlefonts/noto-emoji |

## 중국어 전용 서체 차단 상태

간체(`zh-CN`)와 번체(`zh-TW`) 전용 서체는 아직 채택하지 않았다. 현재의
`NotoSansJP-Variable.ttf`가 일부 공통 한자를 표시하더라도 일본식 자형을 먼저
선택할 수 있으므로 중국어 출시 증거가 아니다. 두 언어는 각각 공식 SC/TC 파일,
OFL 사본, 전체 SHA-256, `FontKit`의 언어별 우선 체인, Windows·macOS·Linux/
Steam Deck 실제 글리프 검사를 같은 변경에서 갖추기 전까지 차단한다.

빈 중국어 폰트 경로는 누락이 아니라 이 차단 상태를 코드로 고정한 것이다. 임의의
OS 폰트나 출처·버전이 확인되지 않은 바이너리를 넣어 우회하지 않는다.

## 라이선스 사본 무결성

| 라이선스 사본 | SHA-256 |
|---|---|
| `OFL-Pretendard.txt` | `9884c81482f64d1a80941098f152c0c9ea944d57ed45bf38324a2601a50b9ef1` |
| `OFL-NotoSansJP.txt` | `babcfe66c8a098b2fa279bc724a3a342f8124f77ce18941fbcc1bbb39823cded` |
| `OFL-NotoColorEmoji.txt` | `6b8fb65f9c022d3902191c5fe93f3d02ecfd88256db16eb187b4f136e5916b68` |

전부 **SIL Open Font License 1.1**이다. OFL은 임베딩·수정·재배포를 허용하되
**폰트 자체의 단독 판매를 금지**하며 라이선스 사본 동봉을 요구한다. 게임에
임베드해 판매하는 것은 허용된다.

`Noto Sans JP`는 예약 서체명 `Source`를 갖는다. **파생 서체를 만들 경우 그 이름을
쓸 수 없다.** 현재는 원본을 그대로 임베드하므로 해당되지 않는다.

## 아직 정해지지 않은 것

`SURFACE_MATERIAL.md` §3이 폰트 역할을 셋으로 나눴다 — 본문(Pretendard 유지),
제목·화자명(세리프/명조), 숫자(등폭). **뒤의 둘은 아직 서체가 없다.**

후보를 고를 때 이 원장의 규율이 그대로 적용된다. 라이선스를 확정하지 못한 서체는
후보에서 제외한다 — **애매하면 쓰지 않는다.**

## 빌드에 실제로 들어가는가

라이선스 사본이 저장소에만 있고 **출하 빌드에 포함되지 않으면 OFL을 만족하지
못한다.** `export_presets.cfg`의 포함 필터와 게임 내 고지 화면이 이 사본에 닿아야
한다. 현재 설정의 `제3자 고지`에서 세 패밀리의 출처와 OFL 1.1 전문을 읽을 수
있으며, 고지 데이터는 이 원장과 실제 파일에서 결정론적으로 생성한다.
