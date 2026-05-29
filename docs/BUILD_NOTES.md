# Gangnam Dream Build Notes

---

## ⚡ 로컬 빠른 시작 (집에서 풀 받자마자)

### 1. git pull
```bash
cd /Users/junheelee/Documents/GitHub/GangnamDream
git pull origin claude/continued-work-r1CE2
```

### 2. Godot 에디터에서 열기
1. Godot 4.6 실행
2. **Import → Browse** → `/Users/junheelee/Documents/GitHub/GangnamDream/project.godot` 선택
3. Import & Edit 클릭

### 3. 즉시 실행 (F5)
- 메인 씬: `res://scenes/SplashScreen.tscn` (자동 설정됨)
- 첫 실행 시 SplashScreen → StartMenu → MainGame 흐름
- 스크립트 에러 없으면 바로 플레이 가능

### 4. JSON 검증 (선택)
```bash
python3 -c "
import json, glob
for f in glob.glob('content/**/*.json', recursive=True):
    try:
        json.load(open(f))
        print(f'OK  {f}')
    except Exception as e:
        print(f'ERR {f}: {e}')
"
```

---

## QA 플레이스루 체크리스트 (로컬 실행 후)

### Launch
- [ ] SplashScreen 애니메이션 (~4.5초) 정상 표시
- [ ] 아무 키로 스킵 가능
- [ ] StartMenu 배경/로고 표시
- [ ] 트레이트 선택 후 게임 시작

### Turn 1–3 (초반)
- [ ] 탑바 바이탈 HUD (❤건강 🧠정신 😤스트레스 블록 바)
- [ ] AP 행동 클릭 → 스탯 플로트 애니메이션 표시
- [ ] 이벤트 발생 → 배경 이미지 카테고리별 전환 확인
- [ ] 선택지 클릭 → 결과 텍스트 화면
- [ ] 다음 달 버튼 → 월 결산 모달
- [ ] 뉴스 티커 표시

### 취업 (Turn 3–6)
- [ ] 직업 찾기 → 직업 목록 모달
- [ ] 취업 시 토스트 피드백 (🎉 초록)
- [ ] 월급 반영 확인
- [ ] 라이벌 메시지 표시 (Turn 2)

### 투자 (첫 월급 이후)
- [ ] 투자 탭 활성화
- [ ] 매수 (10만/50만/100만) 정상 동작
- [ ] 분할 매도 (25%/50%/전량) 정상 동작
- [ ] 스파크라인 + 수익률 표시

### 관계 (Turn 5+)
- [ ] 🤝 인맥관리 → 관계 유형별 선택지 모달
- [ ] 새 인연 만들기 → 관계 패널에 추가

### 충격 이벤트
- [ ] 건강/정신 -15이상 선택지 → PORTRAIT_SHOCKED 1.2초 표시

### 저장/불러오기
- [ ] 메인메뉴 복귀 → 자동저장 토스트
- [ ] 불러오기 → 스탯/포트폴리오/관계 전부 복원

### 엔딩
- [ ] 건강 0 → burnout → 병원 병실 배경
- [ ] 자산 20억 → gangnam_dream → 펜트하우스 배경
- [ ] 새 런 시작 → 정상 초기화

---

## Web Export

### 사전 조건
1. Godot → Editor → Export Templates → Download (Web 4.6 선택)

### 빌드
```
Project → Export → Add → Web
Export Path: build/web/index.html
[Export Project] 클릭
```

### 로컬 미리보기
```bash
cd build/web
python3 -m http.server 8080
# http://localhost:8080 접속
```

---

## Build Record

### 2026-05-27 (Polish Beta — 코드 완료)
```
Version:    polish-beta
Branch:     claude/continued-work-r1CE2
Godot:      4.6
Platform:   (로컬 실행 미완)
Result:     정적 검토 통과. 런타임 QA 대기.
Assets:     배경 14종 + 포트레이트 5종 = 19개 확인
Audio:      절차적 생성 (BGM/SFX 외부 파일 없음)
Known:
  - UI 기본 Godot 폰트 (한국어 가독성 미검증)
  - BGM/SFX 사인파 합성 (실제 오디오 미연동)
  - 모달 오버플로, 해상도 레이아웃 미검증
Next:       로컬 F5 → QA 체크리스트 순서대로
```
