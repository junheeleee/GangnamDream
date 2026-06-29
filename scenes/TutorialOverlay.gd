extends Control
class_name TutorialOverlay
## TutorialOverlay — 미니게임 첫 진입 시 뜨는 튜토리얼 오버레이.
## TutorialOverlay.maybe_show("game_id", parent) 한 줄로 붙인다.
## 세션당 1회만 표시 (static _seen 딕셔너리로 추적).

signal dismissed

const CARD_BACK_TEX := preload("res://assets/ui/card_back.png")
const CHIP_TEX := preload("res://assets/ui/chips/chip_10k.svg")
const UI_ICON_PATHS := {
	"goal": "res://assets/ui/icons/icon_goal.svg",
	"ap": "res://assets/ui/icons/icon_ap.svg",
	"health": "res://assets/ui/icons/icon_health.svg",
	"invest": "res://assets/ui/icons/icon_invest.svg",
	"scalping": "res://assets/ui/icons/icon_scalping.svg",
	"racetrack": "res://assets/ui/icons/icon_racetrack.svg",
}

# ── 세션 추적 (정적 — 앱 실행 중 유지) ──────────────────────────
static var _seen: Dictionary = {}

static func maybe_show(game_id: String, parent: Control) -> void:
	if _seen.get(game_id, false):
		return
	_show(game_id, parent)

static func force_show(game_id: String, parent: Control) -> void:
	_show(game_id, parent)

static func _show(game_id: String, parent: Control) -> void:
	var slides: Array = _get_slides(game_id)
	if slides.is_empty():
		return
	_seen[game_id] = true
	var overlay := TutorialOverlay.new()
	overlay._slides = slides
	overlay._game_id = game_id
	parent.add_child(overlay)

# ── 슬라이드 콘텐츠 ─────────────────────────────────────────────
# 각 항목: {icon, title, body}
static func _localized_slide(icon: String, title_ko: String, title_en: String, body_ko: String, body_en: String) -> Dictionary:
	return {
		"icon": icon,
		"title": LocaleManager.ui(title_ko, title_en),
		"body": _clean_body_for_surface(LocaleManager.ui(body_ko, body_en)),
	}

static func _clean_body_for_surface(text: String) -> String:
	var out := text
	var en := LocaleManager.is_english()
	var replacements := [
		["7️⃣ 7️⃣ 7️⃣", "777"],
		["🃏 🃏 🃏", "BAR BAR BAR"],
		["🍒 🍒 🍒", "Cherry Cherry Cherry" if en else "체리 체리 체리"],
		["🔔 🔔 🔔", "Bell Bell Bell" if en else "벨 벨 벨"],
		["🍒 🍒", "Two cherries" if en else "체리 2개"],
		["1️⃣", "1."],
		["2️⃣", "2."],
		["3️⃣", "3."],
		["7️⃣", "7"],
		["🍒", "Cherry" if en else "체리"],
		["🔔", "Bell" if en else "벨"],
		["💡 ", "Tip: " if en else "힌트: "],
		["💡", "Tip:" if en else "힌트:"],
		["⚠ ", "Warning: " if en else "주의: "],
		["⚠", "Warning:" if en else "주의:"],
		["🎉 ", ""],
	]
	for pair in replacements:
		out = out.replace(str(pair[0]), str(pair[1]))

	for token in [
		"🔵 ", "🔴 ", "🟡 ", "🟢 ", "⚫ ", "🟣 ",
		"💰 ", "❤ ", "🧠 ", "💼 ", "📈 ", "🎰 ",
		"🃏 ", "🏇 ", "👥 ", "⭐ ", "📊 ", "📖 ",
		"✨ ", "🚀 ", "🎯 ", "🏠 ",
	]:
		out = out.replace(token, "")
	return out

static func _get_slides(game_id: String) -> Array:
	match game_id:
		"baccarat":
			return [_localized_slide(
				"🃏",
				"바카라 — 기본 규칙",
				"Baccarat — Basic Rules",
				(
					"카드 합이 [b]9에 가까운[/b] 쪽이 이겨요!\n"
					+ "10·J·Q·K = [b]0점[/b]  /  A = [b]1점[/b]  /  나머지 = 숫자 그대로\n\n"
					+ "[color=#4a9eff]🔵 뱅커 베팅[/color] — 이기면 베팅금의 [b]0.95배[/b] 수익\n"
					+ "   (5% 커미션, 하지만 이길 확률이 제일 높아요)\n"
					+ "[color=#ff5555]🔴 플레이어 베팅[/color] — 이기면 [b]1배[/b] 수익\n"
					+ "[color=#f0c040]🟡 타이 베팅[/color] — 이기면 [b]8배[/b] 수익\n"
					+ "   (두 패가 완전히 같을 때만 — 잘 안 나와요!)\n\n"
					+ "[color=#aaffaa]💡 처음이라면 [b]뱅커[/b]에 꾸준히 베팅해보세요.\n"
					+ "   카지노 게임 중 손실이 제일 적은 베팅이에요.[/color]"
				),
				(
					"Bet on which hand lands closest to [b]9[/b].\n"
					+ "10/J/Q/K = [b]0[/b]  /  A = [b]1[/b]  /  other cards keep their value\n\n"
					+ "[color=#4a9eff]🔵 Banker[/color] — pays [b]0.95x[/b] profit when it wins\n"
					+ "   (5% commission, but the strongest base odds)\n"
					+ "[color=#ff5555]🔴 Player[/color] — pays [b]1x[/b] profit\n"
					+ "[color=#f0c040]🟡 Tie[/color] — pays [b]8x[/b] profit\n"
					+ "   (only when both hands tie exactly)\n\n"
					+ "[color=#aaffaa]💡 New players should start with steady [b]Banker[/b] bets.\n"
					+ "   It is one of the lowest-loss casino bets.[/color]"
				)
			)]
		"blackjack":
			return [_localized_slide(
				"🂡",
				"블랙잭 — 기본 규칙",
				"Blackjack — Basic Rules",
				(
					"[b]21[/b]에 가장 가깝게 만들어야 해요!\n"
					+ "A = 1 또는 11  /  J·Q·K = 10  /  나머지 = 숫자\n\n"
					+ "[b][히트][/b]  카드 1장 더 받기\n"
					+ "[b][스탠드][/b]  이 패로 승부\n"
					+ "[b][더블다운][/b]  베팅 2배 + 카드 딱 1장만 더\n"
					+ "[b][스플릿][/b]  같은 카드 2장이면 두 패로 나누기\n\n"
					+ "딜러는 [b]17 이상[/b]에서 무조건 멈춰요.\n"
					+ "21을 넘으면 [color=#ff5555][b]버스트[/b][/color] — 자동 패배!\n"
					+ "처음 2장이 A+10이면 [color=#f0c040][b]블랙잭[/b][/color] — 1.5배 수익!\n\n"
					+ "[color=#aaffaa]💡 화면의 [b]힌트 보기[/b] 버튼을 누르면\n"
					+ "   지금 상황에서 최선의 선택을 알려줘요![/color]"
				),
				(
					"Get as close to [b]21[/b] as possible without going over.\n"
					+ "A = 1 or 11  /  J/Q/K = 10  /  other cards keep their value\n\n"
					+ "[b][Hit][/b]  Take one more card\n"
					+ "[b][Stand][/b]  Keep this hand\n"
					+ "[b][Double][/b]  Double the bet and take exactly one card\n"
					+ "[b][Split][/b]  Split two equal cards into two hands\n\n"
					+ "The dealer always stops at [b]17+[/b].\n"
					+ "Over 21 is a [color=#ff5555][b]bust[/b][/color] — instant loss.\n"
					+ "A+10 on the first two cards is [color=#f0c040][b]blackjack[/b][/color] — 1.5x profit.\n\n"
					+ "[color=#aaffaa]💡 Use [b]Show Hint[/b] to see the basic-strategy move.[/color]"
				)
			)]
		"holdem":
			return [
				_localized_slide(
					"♠",
					"텍사스 홀덤 — 기본 규칙",
					"Texas Hold'em — Basic Rules",
					(
						"내 [b]2장[/b] + 공개 [b]5장[/b] 중 최강 [b]5장[/b] 조합!\n\n"
						+ "[b][콜][/b]  상대방 베팅에 맞추기\n"
						+ "[b][레이즈][/b]  더 많이 베팅하기\n"
						+ "[b][체크][/b]  그냥 넘기기 (베팅 없을 때만)\n"
						+ "[b][폴드][/b]  포기 (베팅금 포기)\n\n"
						+ "[color=#aaffaa]💡 팟 오즈 힌트를 확인해보세요.\n"
						+ "   [b]+EV[/b]가 표시되면 콜/레이즈가 유리해요![/color]"
					),
					(
						"Build the best [b]5-card[/b] hand from your [b]2 hole cards[/b] and [b]5 community cards[/b].\n\n"
						+ "[b][Call][/b]  Match the current bet\n"
						+ "[b][Raise][/b]  Put in more money\n"
						+ "[b][Check][/b]  Pass when no bet is owed\n"
						+ "[b][Fold][/b]  Give up the hand and your committed chips\n\n"
						+ "[color=#aaffaa]💡 Watch the pot-odds hint.\n"
						+ "   If it shows [b]+EV[/b], calling or raising is usually profitable.[/color]"
					)
				),
				_localized_slide(
					"🏆",
					"홀덤 — 패 순위 (강한 순)",
					"Hold'em — Hand Rankings",
					(
						"[b]1위[/b]  로열 플러시  — A K Q J 10 같은 무늬\n"
						+ "[b]2위[/b]  스트레이트 플러시  — 연속 숫자 + 같은 무늬\n"
						+ "[b]3위[/b]  포카드  — 같은 숫자 4장\n"
						+ "[b]4위[/b]  풀하우스  — 쓰리카드 + 원페어\n"
						+ "[b]5위[/b]  플러시  — 같은 무늬 5장\n"
						+ "[b]6위[/b]  스트레이트  — 연속 숫자 5장\n"
						+ "[b]7위[/b]  쓰리카드  — 같은 숫자 3장\n"
						+ "[b]8위[/b]  투페어  — 페어 2쌍\n"
						+ "[b]9위[/b]  원페어  — 같은 숫자 2장\n"
						+ "[b]10위[/b]  하이카드  — 아무것도 없을 때 가장 높은 카드\n\n"
						+ "[color=#aaffaa]💡 처음엔 페어 이상이 나오면 레이즈해보세요![/color]"
					)
					,
					(
						"[b]1[/b]  Royal Flush — A K Q J 10, same suit\n"
						+ "[b]2[/b]  Straight Flush — sequence, same suit\n"
						+ "[b]3[/b]  Four of a Kind — four cards of one rank\n"
						+ "[b]4[/b]  Full House — three of a kind + pair\n"
						+ "[b]5[/b]  Flush — five cards, same suit\n"
						+ "[b]6[/b]  Straight — five-card sequence\n"
						+ "[b]7[/b]  Three of a Kind — three cards of one rank\n"
						+ "[b]8[/b]  Two Pair — two separate pairs\n"
						+ "[b]9[/b]  One Pair — one pair\n"
						+ "[b]10[/b]  High Card — no made hand\n\n"
						+ "[color=#aaffaa]💡 Early on, consider raising when you make at least a pair.[/color]"
					)
				)
			]
		"slot":
			return [_localized_slide(
				"🎰",
				"슬롯머신 — 기본 규칙",
				"Slot Machine — Basic Rules",
				(
					"[b]SPIN[/b] 버튼을 눌러 3개 릴을 돌려요!\n"
					+ "같은 그림이 나오면 당첨!\n\n"
					+ "[color=#f0c040][b]7️⃣ 7️⃣ 7️⃣[/b][/color]  = [b]200배[/b]  🎉 대박 잭팟!\n"
					+ "[b]🃏 🃏 🃏[/b]  = [b]50배[/b]\n"
					+ "[b]🍒 🍒 🍒[/b]  = [b]20배[/b]\n"
					+ "[b]🔔 🔔 🔔[/b]  = [b]15배[/b]\n"
					+ "[b]🍒 🍒[/b]  (2개 이상)  = [b]3배[/b]\n"
					+ "[b]🍒[/b]  (1개)  = [b]1.5배[/b]  (작은 당첨)\n\n"
					+ "[color=#aaffaa]💡 체리(🍒)가 가장 많이 나와요!\n"
					+ "   잭팟(7️⃣)을 노리려면 베팅금을 크게 해보세요.[/color]"
				),
				(
					"Press [b]SPIN[/b] to roll the three reels.\n"
					+ "Matching symbols pay out.\n\n"
					+ "[color=#f0c040][b]7 7 7[/b][/color]  = [b]200x[/b] jackpot\n"
					+ "[b]BAR BAR BAR[/b]  = [b]50x[/b]\n"
					+ "[b]Cherry Cherry Cherry[/b]  = [b]20x[/b]\n"
					+ "[b]Bell Bell Bell[/b]  = [b]15x[/b]\n"
					+ "[b]Two cherries[/b]  = [b]3x[/b]\n"
					+ "[b]One cherry[/b]  = [b]1.5x[/b]\n\n"
					+ "[color=#aaffaa]💡 Cherries appear most often.\n"
					+ "   Bigger bets make jackpot hits matter more.[/color]"
				)
			)]
		"roulette":
			return [_localized_slide(
				"🎡",
				"룰렛 — 기본 규칙",
				"Roulette — Basic Rules",
				(
					"0~36 숫자 중 하나에 공이 떨어져요.\n"
					+ "베팅 후 [b]SPIN[/b]을 누르세요!\n\n"
					+ "[b]쉬운 베팅 (약 48.6% 확률) → 1배 수익[/b]\n"
					+ "  🔴 빨강 / ⚫ 검정  /  홀수 / 짝수\n"
					+ "  낮음(1-18) / 높음(19-36)\n\n"
					+ "[b]중간 베팅 (약 32.4%) → 2배 수익[/b]\n"
					+ "  1묶음(1-12) / 2묶음(13-24) / 3묶음(25-36)\n\n"
					+ "[b]단일숫자 (2.7%) → 35배 수익[/b]\n"
					+ "  숫자 하나를 정확히 맞추면 대박!\n\n"
					+ "[color=#ff5555]⚠ 0이 나오면 빨강/검정/홀짝 등 모두 패배해요.[/color]\n"
					+ "[color=#aaffaa]💡 처음이라면 빨강 또는 검정부터 해보세요![/color]"
				),
				(
					"The ball lands on one number from 0 to 36.\n"
					+ "Place a bet, then press [b]SPIN[/b].\n\n"
					+ "[b]Even-money bets (about 48.6%) → 1x profit[/b]\n"
					+ "  Red / Black / Odd / Even / Low / High\n\n"
					+ "[b]Dozens (about 32.4%) → 2x profit[/b]\n"
					+ "  1-12 / 13-24 / 25-36\n\n"
					+ "[b]Straight number (2.7%) → 35x profit[/b]\n"
					+ "  Hit the exact number for the biggest standard payout.\n\n"
					+ "[color=#ff5555]⚠ If 0 hits, red/black/odd/even style bets lose.[/color]\n"
					+ "[color=#aaffaa]💡 New players should start with red or black.[/color]"
				)
			)]
		"bigwheel":
			return [_localized_slide(
				"🎯",
				"빅휠 — 기본 규칙",
				"Big Wheel — Basic Rules",
				(
					"바퀴를 돌려 [b]바늘이 멈추는 구역[/b]에 베팅하세요!\n\n"
					+ "[color=#e74c3c]🔴 1배[/color]  24칸 — 제일 많이 있어요 (이기기 쉬움)\n"
					+ "[color=#3498db]🔵 2배[/color]  15칸\n"
					+ "[color=#2ecc71]🟢 5배[/color]  7칸\n"
					+ "[color=#f39c12]🟡 10배[/color]  4칸\n"
					+ "[color=#9b59b6]🟣 20배[/color]  2칸\n"
					+ "[color=#f1c40f]🃏 조커 45배[/color]  2칸 — 잘 안 나오지만 대박!\n\n"
					+ "[color=#aaffaa]💡 처음이라면 [b]1배[/b]로 시작해보세요.\n"
					+ "   가장 자주 이길 수 있어요![/color]"
				),
				(
					"Bet on the segment where the [b]pointer stops[/b].\n\n"
					+ "[color=#e74c3c]Red 1x[/color]  24 slots — most common\n"
					+ "[color=#3498db]Blue 2x[/color]  15 slots\n"
					+ "[color=#2ecc71]Green 5x[/color]  7 slots\n"
					+ "[color=#f39c12]Yellow 10x[/color]  4 slots\n"
					+ "[color=#9b59b6]Purple 20x[/color]  2 slots\n"
					+ "[color=#f1c40f]Joker 45x[/color]  2 slots — rare, huge payout\n\n"
					+ "[color=#aaffaa]💡 Start with [b]1x[/b] if you want frequent wins.[/color]"
				)
			)]
		"daisai":
			return [_localized_slide(
				"🎲",
				"다이사이 — 기본 규칙",
				"Dai Sai — Basic Rules",
				(
					"세 개의 주사위를 굴려 결과에 베팅하는 게임이에요.\n\n"
					+ "[b]BIG[/b]  합계 11~17  → [b]1배[/b] 수익\n"
					+ "[b]SMALL[/b]  합계 4~10  → [b]1배[/b] 수익\n"
					+ "단, [color=#ff5555][b]트리플[/b][/color]이 나오면 BIG/SMALL은 패배!\n\n"
					+ "[b]싱글[/b]  선택 숫자가 나온 개수만큼 수익\n"
					+ "[b]페어[/b]  같은 숫자 2개 이상 → [b]8배[/b]\n"
					+ "[b]ANY TRIPLE[/b]  아무 트리플 → [b]24배[/b]\n"
					+ "[b]특정 트리플[/b]  예: 333 정확히 → [b]150배[/b]\n"
					+ "[b]합계 베팅[/b]  4~17 합계를 정확히 맞추면 6~60배\n\n"
					+ "[color=#aaffaa]💡 처음이라면 BIG/SMALL로 흐름을 보고,\n"
					+ "   대박을 노릴 때만 트리플이나 합계에 소액 베팅하세요.[/color]"
				),
				(
					"Roll three dice and bet on the result.\n\n"
					+ "[b]BIG[/b]  Total 11-17  → [b]1x[/b] profit\n"
					+ "[b]SMALL[/b]  Total 4-10  → [b]1x[/b] profit\n"
					+ "But any [color=#ff5555][b]triple[/b][/color] makes BIG/SMALL lose.\n\n"
					+ "[b]Single[/b]  Pays by how many times your number appears\n"
					+ "[b]Pair[/b]  Two or more of the same number → [b]8x[/b]\n"
					+ "[b]Any Triple[/b]  Any triple → [b]24x[/b]\n"
					+ "[b]Specific Triple[/b]  Exact triple, e.g. 333 → [b]150x[/b]\n"
					+ "[b]Total[/b]  Exact total from 4-17 pays 6x-60x\n\n"
					+ "[color=#aaffaa]💡 Start with BIG/SMALL, then use small stakes for triples or totals.[/color]"
				)
			)]
		"scalping":
			return [_localized_slide(
				"⚡",
				"스캘핑 트레이딩 — 기본 규칙",
				"Scalping Trading — Basic Rules",
				(
					"[b]60초[/b] 안에 사고 팔아 수익을 내세요!\n\n"
					+ "[b]캔들 차트 읽는 법[/b]\n"
					+ "  🟢 초록 막대 = 가격 [b]오름[/b]\n"
					+ "  🔴 빨간 막대 = 가격 [b]내림[/b]\n\n"
					+ "[b]이동평균선[/b]\n"
					+ "  [color=#f0c040]노란선 MA5[/color] = 5개 평균 (단기 추세)\n"
					+ "  [color=#4a90e8]파란선 MA20[/color] = 20개 평균 (장기 추세)\n\n"
					+ "노란선이 파란선 [b]위[/b]로 올라오면 → [color=#00c896][b]BUY 신호[/b][/color]\n"
					+ "노란선이 파란선 [b]아래[/b]로 내려오면 → [color=#ff5252][b]SELL 신호[/b][/color]\n\n"
					+ "[color=#aaffaa]💡 타이밍이 전부예요!\n"
					+ "   수익이 나면 빨리 파세요 — 60초는 짧아요![/color]"
				),
				(
					"Buy and sell within [b]60 seconds[/b] to lock in profit.\n\n"
					+ "[b]Candles[/b]\n"
					+ "  Green bars mean price moved [b]up[/b]\n"
					+ "  Red bars mean price moved [b]down[/b]\n\n"
					+ "[b]Moving averages[/b]\n"
					+ "  [color=#f0c040]Yellow MA5[/color] = short-term trend\n"
					+ "  [color=#4a90e8]Blue MA20[/color] = long-term trend\n\n"
					+ "Yellow crossing [b]above[/b] blue → [color=#00c896][b]BUY signal[/b][/color]\n"
					+ "Yellow crossing [b]below[/b] blue → [color=#ff5252][b]SELL signal[/b][/color]\n\n"
					+ "[color=#aaffaa]💡 Timing is everything. If you are ahead, take profit quickly.[/color]"
				)
			)]
		"trading", "invest":
			return [_localized_slide(
				"📊",
				"투자 화면 — 기본 규칙",
				"Investment Screen — Basic Rules",
				(
					"종목을 선택하고 사고팔아 자산을 늘려요!\n\n"
					+ "[b]캔들 차트 읽는 법[/b]\n"
					+ "  🟢 초록 막대 = 그달 가격이 [b]올랐어요[/b]\n"
					+ "  🔴 빨간 막대 = 그달 가격이 [b]내렸어요[/b]\n\n"
					+ "[b]이동평균선[/b]\n"
					+ "  [color=#f0c040]노란선 MA5[/color] = 5개월 평균 (단기)\n"
					+ "  [color=#4a90e8]파란선 MA20[/color] = 20개월 평균 (장기)\n"
					+ "  → 노란선이 파란선 위로 오면 상승 신호!\n\n"
					+ "[b]매수[/b] = 종목 사기  /  [b]매도[/b] = 종목 팔기\n"
					+ "보유 중인 종목의 [b]손익(%)[/b]이 실시간으로 표시돼요.\n\n"
					+ "[color=#aaffaa]💡 처음엔 [b]코스피 ETF[/b]나 [b]S&P500[/b]처럼\n"
					+ "   변동성이 낮은 종목부터 시작해보세요![/color]"
				),
				(
					"Pick an asset, buy or sell, and grow your net worth.\n\n"
					+ "[b]Candles[/b]\n"
					+ "  Green bars mean the monthly price moved [b]up[/b]\n"
					+ "  Red bars mean the monthly price moved [b]down[/b]\n\n"
					+ "[b]Moving averages[/b]\n"
					+ "  [color=#f0c040]Yellow MA5[/color] = 5-month average\n"
					+ "  [color=#4a90e8]Blue MA20[/color] = 20-month average\n"
					+ "  Yellow above blue usually signals strength.\n\n"
					+ "[b]Buy[/b] adds a position. [b]Sell[/b] closes part or all of it.\n"
					+ "Your current profit/loss is shown in real time.\n\n"
					+ "[color=#aaffaa]💡 Start with lower-volatility assets such as KOSPI ETF or S&P 500.[/color]"
				)
			)]
		"racetrack":
			return [_localized_slide(
				"🏇",
				"경마 — 기본 규칙",
				"Horse Racing — Basic Rules",
				(
					"말을 골라 베팅하고 레이스를 관전하세요!\n\n"
					+ "[b]폼 지수 읽기[/b]\n"
					+ "  ⭐ 별이 많을수록 최근 성적이 좋아요\n"
					+ "  낮은 배당 = 이길 확률 높음\n"
					+ "  높은 배당 = 이길 확률 낮지만 대박 가능!\n\n"
					+ "[b]베팅 방법[/b]\n"
					+ "  1위 맞추기 (단승) — 가장 기본\n"
					+ "  복수로 베팅 가능\n\n"
					+ "[color=#ff5252]⚠ 경마는 중독성이 있어요. 잃어도 되는 금액만 베팅하세요.[/color]\n\n"
					+ "[color=#aaffaa]💡 폼이 좋은 말이 항상 이기진 않아요.\n"
					+ "   1~3위권 말을 고르는 게 안전해요![/color]"
				),
				(
					"Choose horses, place a bet, and watch the race.\n\n"
					+ "[b]Reading form[/b]\n"
					+ "  More stars mean stronger recent performance\n"
					+ "  Lower odds mean higher public confidence\n"
					+ "  Higher odds are risky, but can swing a run\n\n"
					+ "[b]Bet types[/b]\n"
					+ "  Win: pick the winner\n"
					+ "  Place / Exacta style bets use multiple horses\n\n"
					+ "[color=#ff5252]⚠ Horse racing is addictive. Bet only money you can afford to lose.[/color]\n\n"
					+ "[color=#aaffaa]💡 Strong form does not guarantee a win. Safer bets focus on top contenders.[/color]"
				)
			)]
		"main_game":
			return [
				_localized_slide(
					"🏙",
					"강남드림 — 게임 목표",
					"Gangnam Dream — Your Goal",
					(
						"당신은 [b]김민준, 33세, 백수[/b].\n"
						+ "통장에 [b]50만원[/b]이 전부예요.\n\n"
						+ "목표는 딱 하나 —\n"
						+ "[color=#f0c040][b]5년 안에 자산 30억을 모아\n강남에 입성하는 것![/b][/color]\n\n"
						+ "매주(= 1턴)마다 [b]행동 포인트(AP)[/b]를 써서\n"
						+ "취업·투자·도박·인간관계 등을 선택하세요.\n\n"
						+ "[color=#aaffaa]💡 38세(240턴)가 되면 게임이 끝나요.\n"
						+ "   1달 = 4주 = 4턴. 5년 = 60달 = 240턴.[/color]"
					),
					(
						"You are [b]Kim Minjun, 33, unemployed[/b].\n"
							+ "Your bank account holds [b]KRW 500,000[/b]. That's it.\n\n"
							+ "One goal —\n"
							+ "[color=#f0c040][b]Build KRW 3 billion in assets\nwithin 5 years and reach Gangnam.[/b][/color]\n\n"
						+ "Every week (= 1 turn), spend [b]Action Points (AP)[/b]\nto work, invest, gamble, build relationships.\n\n"
						+ "[color=#aaffaa]💡 The game ends when you turn 38 (240 turns).\n"
						+ "   1 month = 4 weeks = 4 turns. 5 years = 240 turns.[/color]"
					)
				),
				_localized_slide(
					"📊",
					"대시보드 읽는 법",
					"Reading the Dashboard",
					(
						"[b]상단 스탯 바[/b]를 항상 확인하세요:\n\n"
						+ "  💰 [b]자산[/b] — 현금 + 포트폴리오 총합\n"
						+ "  ❤ [b]건강[/b] — 0이 되면 입원 or 사망\n"
						+ "  🧠 [b]정신력[/b] — 0이 되면 번아웃·멘탈 붕괴\n\n"
						+ "건강·정신력은 매달 자동으로 줄어요.\n"
						+ "무직이면 더 빨리 떨어지니 주의!\n\n"
						+ "[color=#aaffaa]💡 첫 주에는 [b]구직활동[/b]으로\n"
						+ "   일자리부터 구하는 게 안전해요.[/color]"
					),
					(
						"Watch the [b]stat bar at the top[/b] at all times:\n\n"
						+ "  💰 [b]Assets[/b] — cash + portfolio total\n"
						+ "  ❤ [b]Health[/b] — hits 0: hospitalization or worse\n"
						+ "  🧠 [b]Mental[/b] — hits 0: burnout, breakdown\n\n"
						+ "Both drain automatically each month.\nUnemployed? They drain faster.\n\n"
						+ "[color=#aaffaa]💡 Your first week: use [b]Job Search[/b]\n"
						+ "   to find work before anything else.[/color]"
					)
				),
				_localized_slide(
					"⚡",
					"한 주의 흐름",
					"The Weekly Loop",
					(
						"매주 이렇게 진행돼요:\n\n"
						+ "1️⃣  [b]이번 주 상황[/b] — 뉴스·이벤트 확인\n"
						+ "2️⃣  [b]선택[/b] — 행동 포인트(AP)를 써서 반응\n"
						+ "3️⃣  [b]다음 주 ▶[/b] — 한 주가 흘러 다음 주로\n\n"
						+ "[b]AP를 쓸 수 있는 행동들:[/b]\n"
						+ "  💼 구직활동  📈 투자  🎰 정선 카지노\n"
						+ "  🃏 홀덤  🏇 경마  👥 인맥 관리  등\n\n"
						+ "[color=#aaffaa]💡 AP가 남아도 다음 주로 넘어갈 수 있어요.\n"
						+ "   하지만 낭비하면 목표 달성이 어려워요![/color]"
					),
					(
						"Each week goes like this:\n\n"
						+ "1️⃣  [b]This Week[/b] — read the news and events\n"
						+ "2️⃣  [b]Choose[/b] — spend AP to respond\n"
						+ "3️⃣  [b]Next Week ▶[/b] — advance to the next week\n\n"
						+ "[b]Ways to spend AP:[/b]\n"
						+ "  💼 Job Hunt  📈 Invest  🎰 Casino\n"
						+ "  🃏 Hold'em  🏇 Races  👥 Network  and more\n\n"
						+ "[color=#aaffaa]💡 Unused AP carries over — but\n"
						+ "   wasting turns makes the goal much harder.[/color]"
					)
				),
				_localized_slide(
					"⚖",
					"선택이 쌓이면 삶이 된다",
					"Choices Become a Life",
					(
						"매주 어떤 행동을 반복하느냐가\n"
						+ "당신이 [b]어떤 사람인지[/b]를 결정합니다.\n\n"
						+ "[color=#a78bfa]💼 안정을 쌓으면[/color]\n"
						+ "  취업·승진·저축·자기계발이 길이 됩니다.\n"
						+ "  느리지만 무너지지 않는다.\n\n"
						+ "[color=#f0b429]📈 속도를 쌓으면[/color]\n"
						+ "  투자·레버리지·사업·도박이 길이 됩니다.\n"
						+ "  빠르지만 한 번에 무너진다.\n\n"
						+ "[color=#aaffaa]둘 다 강남에 갈 수 있고, 둘 다 망할 수 있다.[/color]\n"
						+ "쌓인 선택에 따라 [b]다른 이벤트와 다른 엔딩[/b]이 열립니다."
					),
					(
						"What you do week after week\ndetermines [b]who you become[/b].\n\n"
						+ "[color=#a78bfa]💼 Build stability[/color]\n"
						+ "  Jobs, promotions, savings, self-improvement.\n"
						+ "  Slow — but you don't collapse.\n\n"
						+ "[color=#f0b429]📈 Build speed[/color]\n"
						+ "  Investing, leverage, startups, gambling.\n"
						+ "  Fast — but one bad break ends it all.\n\n"
						+ "[color=#aaffaa]Both paths can reach Gangnam. Both can fail.[/color]\n"
						+ "Your pattern of choices unlocks [b]different events\nand different endings[/b]."
					)
				)
			]
	return []

# ── 인스턴스 ─────────────────────────────────────────────────────
var _slides: Array = []
var _game_id: String = ""
var _slide_idx: int = 0

var _font: FontFile
var _font_bold: FontFile
var _body_lbl: RichTextLabel
var _page_lbl: Label
var _next_btn: Button
var _icon_tex: TextureRect
var _title_lbl: Label
var _ui_icon_cache: Dictionary = {}

func _ready() -> void:
	_font      = load("res://assets/fonts/Pretendard-Regular.ttf") as FontFile
	_font_bold = load("res://assets/fonts/Pretendard-Bold.ttf") as FontFile
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	z_index = 200
	_build_ui()
	_show_slide(0)

func _f(n: Object, bold: bool = false) -> void:
	var ft: FontFile = _font_bold if bold else _font
	if ft and n:
		n.add_theme_font_override("font", ft)
		if n is RichTextLabel:
			n.add_theme_font_override("normal_font", ft)
			n.add_theme_font_override("bold_font", _font_bold if _font_bold else ft)

func _build_ui() -> void:
	# 배경 (어두운 반투명 오버레이)
	var bg := ColorRect.new()
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.color = Color(0.0, 0.0, 0.0, 0.75)
	add_child(bg)

	# 카드 패널 (중앙 정렬)
	var card := PanelContainer.new()
	card.set_anchors_preset(Control.PRESET_CENTER)
	card.offset_left   = -320
	card.offset_right  = 320
	card.offset_top    = -280
	card.offset_bottom = 280
	var card_sb := StyleBoxFlat.new()
	card_sb.bg_color             = Color("#100d14")   # 누아르 다크
	card_sb.border_color         = Color("#8a7320")   # 어두운 골드
	card_sb.set_border_width_all(2)
	card_sb.set_corner_radius_all(12)
	card_sb.content_margin_left   = 28
	card_sb.content_margin_right  = 28
	card_sb.content_margin_top    = 24
	card_sb.content_margin_bottom = 24
	card.add_theme_stylebox_override("panel", card_sb)
	add_child(card)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 12)
	card.add_child(vbox)

	# 아이콘 — 플랫폼 이모지 대신 통일된 UI texture 사용
	var icon_frame := PanelContainer.new()
	icon_frame.custom_minimum_size = Vector2(0, 58)
	var icon_frame_st := StyleBoxFlat.new()
	icon_frame_st.bg_color = Color(0, 0, 0, 0.0)
	icon_frame_st.content_margin_top = 0
	icon_frame_st.content_margin_bottom = 0
	icon_frame.add_theme_stylebox_override("panel", icon_frame_st)
	vbox.add_child(icon_frame)
	var icon_center := CenterContainer.new()
	icon_frame.add_child(icon_center)
	_icon_tex = TextureRect.new()
	_icon_tex.custom_minimum_size = Vector2(52, 52)
	_icon_tex.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_icon_tex.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_icon_tex.mouse_filter = Control.MOUSE_FILTER_IGNORE
	icon_center.add_child(_icon_tex)

	# 제목
	_title_lbl = Label.new()
	_title_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_title_lbl.add_theme_font_size_override("font_size", 22)
	_title_lbl.add_theme_color_override("font_color", Color("#c9a227"))   # 앤틱 골드
	_f(_title_lbl, true)
	vbox.add_child(_title_lbl)

	# 구분선
	var sep := ColorRect.new()
	sep.custom_minimum_size = Vector2(0, 1)
	sep.color = Color("#3a2e1a")   # 따뜻한 다크 구분선
	vbox.add_child(sep)

	# 본문
	_body_lbl = RichTextLabel.new()
	_body_lbl.bbcode_enabled = true
	_body_lbl.scroll_active = false
	_body_lbl.fit_content = false
	_body_lbl.custom_minimum_size = Vector2(0, 310)
	_body_lbl.add_theme_font_size_override("normal_font_size", 15)
	_body_lbl.add_theme_color_override("default_color", Color("#d8d2c4"))   # 따뜻한 아이보리
	_f(_body_lbl)
	vbox.add_child(_body_lbl)

	# 하단 행 (페이지 + 버튼)
	var bottom_row := HBoxContainer.new()
	bottom_row.add_theme_constant_override("separation", 12)
	vbox.add_child(bottom_row)

	_page_lbl = Label.new()
	_page_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_page_lbl.add_theme_font_size_override("font_size", 13)
	_page_lbl.add_theme_color_override("font_color", Color("#6a5e42"))   # 세피아 딤
	_f(_page_lbl)
	bottom_row.add_child(_page_lbl)

	_next_btn = Button.new()
	_next_btn.custom_minimum_size = Vector2(180, 44)
	_next_btn.add_theme_font_size_override("font_size", 16)
	var btn_sb := StyleBoxFlat.new()
	btn_sb.bg_color = Color("#3a2c0a")   # 어두운 골드 버튼
	btn_sb.border_color = Color("#c9a227")
	btn_sb.border_width_left = 1; btn_sb.border_width_right = 1
	btn_sb.border_width_top = 1; btn_sb.border_width_bottom = 1
	btn_sb.set_corner_radius_all(6)
	btn_sb.content_margin_left  = 16
	btn_sb.content_margin_right = 16
	_next_btn.add_theme_stylebox_override("normal", btn_sb)
	var btn_hov := btn_sb.duplicate()
	btn_hov.bg_color = Color("#5a4510")
	_next_btn.add_theme_stylebox_override("hover", btn_hov)
	_next_btn.add_theme_color_override("font_color", Color("#e3c45a"))   # 밝은 골드
	_f(_next_btn, true)
	_next_btn.pressed.connect(_on_next)
	bottom_row.add_child(_next_btn)

func _show_slide(idx: int) -> void:
	if idx >= _slides.size():
		_dismiss()
		return
	var slide: Dictionary = _slides[idx]
	_set_slide_icon(slide)
	_title_lbl.text = str(slide.get("title", ""))
	_body_lbl.text  = str(slide.get("body", ""))

	var total: int = _slides.size()
	if total > 1:
		_page_lbl.text = "%d / %d" % [idx + 1, total]
	else:
		_page_lbl.text = ""

	if idx < total - 1:
		_next_btn.text = LocaleManager.ui("다음 ›", "Next ›")
	else:
		_next_btn.text = LocaleManager.ui("이해했어요", "Got it")

func _set_slide_icon(slide: Dictionary) -> void:
	if not is_instance_valid(_icon_tex):
		return
	var icon_id := _icon_id_for_slide(slide)
	if icon_id == "card":
		_icon_tex.texture = CARD_BACK_TEX
		_icon_tex.modulate = Color.WHITE
	elif icon_id == "chip":
		_icon_tex.texture = CHIP_TEX
		_icon_tex.modulate = Color.WHITE
	else:
		_icon_tex.texture = _ui_icon_texture(icon_id)
		_icon_tex.modulate = Color("#c9a227")

func _icon_id_for_slide(slide: Dictionary) -> String:
	match _game_id:
		"baccarat", "blackjack", "holdem":
			return "card"
		"slot", "roulette", "bigwheel":
			return "chip"
		"racetrack":
			return "racetrack"
		"scalping":
			return "scalping"
		"trading", "invest":
			return "invest"
	var icon := str(slide.get("icon", ""))
	if _game_id == "main_game" and icon == "📊":
		return "health"
	if _game_id == "main_game" and icon == "⚡":
		return "ap"
	if _game_id == "main_game" and icon == "⚖":
		return "invest"
	return "goal"

func _ui_icon_texture(icon_id: String) -> Texture2D:
	if _ui_icon_cache.has(icon_id):
		return _ui_icon_cache[icon_id]
	var path: String = str(UI_ICON_PATHS.get(icon_id, ""))
	if path.is_empty() or not ResourceLoader.exists(path):
		_ui_icon_cache[icon_id] = null
		return null
	var res := load(path)
	var tex: Texture2D = res if res is Texture2D else null
	_ui_icon_cache[icon_id] = tex
	return tex

func _on_next() -> void:
	_slide_idx += 1
	if _slide_idx >= _slides.size():
		_dismiss()
	else:
		_show_slide(_slide_idx)

func _dismiss() -> void:
	emit_signal("dismissed")
	queue_free()
