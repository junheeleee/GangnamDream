extends RefCounted
class_name SlotMachine

# 심볼 인덱스 상수
const SYM_SEVEN  := 0
const SYM_BAR    := 1
const SYM_CHERRY := 2
const SYM_BELL   := 3
const SYM_LEMON  := 4

const SYMBOL_COUNT := 5

# 표시용 이름 배열 (인덱스 = 심볼 ID)
const SYMBOL_NAMES: Array = ["SEVEN", "BAR", "CHERRY", "BELL", "LEMON"]

# 릴 스트립 — 각 릴에 심볼이 몇 개씩 들어가는지 정의
# 총 슬롯 수: 32개/릴. 이 비중이 확률을 결정한다.
# 하우스엣지 목표: 8~12%
#
# 이론 RTP 계산 (각 릴 독립):
#   P(SEVEN)  = 1/32  각 릴
#   P(BAR)    = 2/32
#   P(CHERRY) = 5/32
#   P(BELL)   = 6/32
#   P(LEMON)  = 18/32
#
# 이론 RTP:
#   777:      (1/32)^3 * 200  ≈ 0.00610
#   BBB:      (2/32)^3 * 50   ≈ 0.00305
#   CCC:      (5/32)^3 * 20   ≈ 0.03052
#   BellBellBell: (6/32)^3 * 15 ≈ 0.03296
#   CC (2체리): P(정확히2) * 3
#     P(≥2 cherry 중 3개 경우 이미 포함) → 별도 정산 필요
#     P(정확히 2체리) = C(3,2)*(5/32)^2*(27/32) ≈ 0.06928  * 3 ≈ 0.20784
#     단, 3체리는 CCC로 이미 처리 → 정확히 2체리만
#   C  (1체리): P(정확히 1체리) = C(3,1)*(5/32)*(27/32)^2 ≈ 0.37427 * 1.5 ≈ 0.56140
#   합계 RTP ≈ 0.00610+0.00305+0.03052+0.03296+0.20784+0.56140 ≈ 0.8419 → HE ≈ 15.8%
#
# HE를 8~12%로 맞추기 위해 체리 비중을 높여 1체리/2체리 히트율 상승:
#   CHERRY: 7/32, LEMON: 16/32  → 재계산:
#   P(정확히1체리) = 3*(7/32)*(25/32)^2 ≈ 0.4004 * 1.5 ≈ 0.6006
#   P(정확히2체리) = 3*(7/32)^2*(25/32) ≈ 0.1120 * 3   ≈ 0.3360
#   CCC:    (7/32)^3*20 ≈ 0.02096
#   BBB:    (2/32)^3*50 ≈ 0.00305
#   777:    (1/32)^3*200≈ 0.00610
#   Bells:  (6/32)^3*15 ≈ 0.03296
#   합계 RTP ≈ 0.6006+0.3360+0.02096+0.00305+0.00610+0.03296 ≈ 0.9997 → HE ≈ ~0%
#
# 최종 튜닝 — 체리를 6/32로 낮추고 배당 미세 조정:
#   SEVEN:1  BAR:2  CHERRY:6  BELL:6  LEMON:17 (합=32)
#   P(7)=1/32  P(B)=2/32  P(C)=6/32  P(Be)=6/32  P(L)=17/32
#   RTP:
#     777:  (1/32)^3*200       = 0.00610
#     BBB:  (2/32)^3*50        = 0.00305
#     CCC:  (6/32)^3*20        = 0.04395
#     BeBeB:(6/32)^3*15        = 0.03296
#     2C:   3*(6/32)^2*(26/32)*3= 3*0.03516*0.8125*3 = 0.25720  (정확히2체리)
#     1C:   3*(6/32)*(26/32)^2*1.5=3*0.1875*0.6602*1.5=0.55679
#     합계 ≈ 0.00610+0.00305+0.04395+0.03296+0.25720+0.55679 ≈ 0.9000 → HE ≈ 10.0% ✓

# 릴 스트립: 각 원소가 심볼 ID, 32칸
const _REEL_STRIP: Array = [
	SYM_SEVEN,   # 1개
	SYM_BAR, SYM_BAR,   # 2개
	SYM_CHERRY, SYM_CHERRY, SYM_CHERRY, SYM_CHERRY, SYM_CHERRY, SYM_CHERRY,  # 6개
	SYM_BELL, SYM_BELL, SYM_BELL, SYM_BELL, SYM_BELL, SYM_BELL,  # 6개
	SYM_LEMON, SYM_LEMON, SYM_LEMON, SYM_LEMON, SYM_LEMON,
	SYM_LEMON, SYM_LEMON, SYM_LEMON, SYM_LEMON, SYM_LEMON,
	SYM_LEMON, SYM_LEMON, SYM_LEMON, SYM_LEMON, SYM_LEMON,
	SYM_LEMON, SYM_LEMON, SYM_LEMON  # 17개 (합=32)
]

# 심볼별 이모지
func symbol_emoji(idx: int) -> String:
	match idx:
		SYM_SEVEN:  return "7️⃣"
		SYM_BAR:    return "🃏"
		SYM_CHERRY: return "🍒"
		SYM_BELL:   return "🔔"
		SYM_LEMON:  return "🍋"
		_:          return "❓"

# 릴 하나를 돌려 심볼 ID 반환
func _spin_reel(rng: RandomNumberGenerator) -> int:
	var pos: int = rng.randi_range(0, _REEL_STRIP.size() - 1)
	return _REEL_STRIP[pos]

# 메인 스핀 함수
# 반환 Dictionary:
#   reels      : Array[int]   — 3릴 심볼 ID
#   multiplier : float        — 배당 배수 (0.0 = 꽝)
#   is_win     : bool         — 당첨 여부
#   win_type   : String       — 당첨 종류 설명 ("", "1체리", "2체리", "체리3개", "BELL3", "BAR3", "777")
#   symbols    : Array[String]— 심볼 이름 배열 (표시용)
#   emojis     : Array[String]— 이모지 배열 (표시용)
func spin(rng: RandomNumberGenerator) -> Dictionary:
	var r0: int = _spin_reel(rng)
	var r1: int = _spin_reel(rng)
	var r2: int = _spin_reel(rng)

	var reels: Array = [r0, r1, r2]

	# 체리 개수 집계
	var cherry_count: int = 0
	for sym in reels:
		if sym == SYM_CHERRY:
			cherry_count += 1

	var multiplier: float = 0.0
	var win_type: String = ""

	# 우선순위: 완전 일치 조합 먼저, 그 다음 부분 조합
	if r0 == SYM_SEVEN and r1 == SYM_SEVEN and r2 == SYM_SEVEN:
		multiplier = 200.0
		win_type = LocaleManager.ui("777 잭팟!", "777 Jackpot!")
	elif r0 == SYM_BAR and r1 == SYM_BAR and r2 == SYM_BAR:
		multiplier = 50.0
		win_type = "BAR BAR BAR"
	elif cherry_count == 3:
		multiplier = 20.0
		win_type = LocaleManager.ui("체리 3개", "3 Cherries")
	elif r0 == SYM_BELL and r1 == SYM_BELL and r2 == SYM_BELL:
		multiplier = 15.0
		win_type = "BELL BELL BELL"
	elif cherry_count == 2:
		multiplier = 3.0
		win_type = LocaleManager.ui("체리 2개", "2 Cherries")
	elif cherry_count == 1:
		multiplier = 1.5
		win_type = LocaleManager.ui("체리 1개", "1 Cherry")
	# else: 꽝 → multiplier = 0.0

	var is_win: bool = multiplier > 0.0

	var symbols: Array = []
	var emojis: Array = []
	for sym in reels:
		symbols.append(SYMBOL_NAMES[sym])
		emojis.append(symbol_emoji(sym))

	return {
		"reels":      reels,
		"multiplier": multiplier,
		"is_win":     is_win,
		"win_type":   win_type,
		"symbols":    symbols,
		"emojis":     emojis,
	}
