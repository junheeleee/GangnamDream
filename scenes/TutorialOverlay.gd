extends Control
class_name TutorialOverlay
## TutorialOverlay — 미니게임 첫 진입 시 뜨는 튜토리얼 오버레이.
## TutorialOverlay.maybe_show("game_id", parent) 한 줄로 붙인다.
## 세션당 1회만 표시 (static _seen 딕셔너리로 추적).

signal dismissed

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
static func _get_slides(game_id: String) -> Array:
	match game_id:
		"baccarat":
			return [{
				"icon": "🃏",
				"title": "바카라 — 기본 규칙",
				"body": (
					"카드 합이 [b]9에 가까운[/b] 쪽이 이겨요!\n"
					+ "10·J·Q·K = [b]0점[/b]  /  A = [b]1점[/b]  /  나머지 = 숫자 그대로\n\n"
					+ "[color=#4a9eff]🔵 뱅커 베팅[/color] — 이기면 베팅금의 [b]0.95배[/b] 수익\n"
					+ "   (5% 커미션, 하지만 이길 확률이 제일 높아요)\n"
					+ "[color=#ff5555]🔴 플레이어 베팅[/color] — 이기면 [b]1배[/b] 수익\n"
					+ "[color=#f0c040]🟡 타이 베팅[/color] — 이기면 [b]8배[/b] 수익\n"
					+ "   (두 패가 완전히 같을 때만 — 잘 안 나와요!)\n\n"
					+ "[color=#aaffaa]💡 처음이라면 [b]뱅커[/b]에 꾸준히 베팅해보세요.\n"
					+ "   카지노 게임 중 손실이 제일 적은 베팅이에요.[/color]"
				)
			}]
		"blackjack":
			return [{
				"icon": "🂡",
				"title": "블랙잭 — 기본 규칙",
				"body": (
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
				)
			}]
		"holdem":
			return [
				{
					"icon": "♠",
					"title": "텍사스 홀덤 — 기본 규칙",
					"body": (
						"내 [b]2장[/b] + 공개 [b]5장[/b] 중 최강 [b]5장[/b] 조합!\n\n"
						+ "[b][콜][/b]  상대방 베팅에 맞추기\n"
						+ "[b][레이즈][/b]  더 많이 베팅하기\n"
						+ "[b][체크][/b]  그냥 넘기기 (베팅 없을 때만)\n"
						+ "[b][폴드][/b]  포기 (베팅금 포기)\n\n"
						+ "[color=#aaffaa]💡 팟 오즈 힌트를 확인해보세요.\n"
						+ "   [b]+EV[/b]가 표시되면 콜/레이즈가 유리해요![/color]"
					)
				},
				{
					"icon": "🏆",
					"title": "홀덤 — 패 순위 (강한 순)",
					"body": (
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
				}
			]
		"slot":
			return [{
				"icon": "🎰",
				"title": "슬롯머신 — 기본 규칙",
				"body": (
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
				)
			}]
		"roulette":
			return [{
				"icon": "🎡",
				"title": "룰렛 — 기본 규칙",
				"body": (
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
				)
			}]
		"bigwheel":
			return [{
				"icon": "🎯",
				"title": "빅휠 — 기본 규칙",
				"body": (
					"바퀴를 돌려 [b]바늘이 멈추는 구역[/b]에 베팅하세요!\n\n"
					+ "[color=#e74c3c]🔴 1배[/color]  24칸 — 제일 많이 있어요 (이기기 쉬움)\n"
					+ "[color=#3498db]🔵 2배[/color]  15칸\n"
					+ "[color=#2ecc71]🟢 5배[/color]  7칸\n"
					+ "[color=#f39c12]🟡 10배[/color]  4칸\n"
					+ "[color=#9b59b6]🟣 20배[/color]  2칸\n"
					+ "[color=#f1c40f]🃏 조커 45배[/color]  2칸 — 잘 안 나오지만 대박!\n\n"
					+ "[color=#aaffaa]💡 처음이라면 [b]1배[/b]로 시작해보세요.\n"
					+ "   가장 자주 이길 수 있어요![/color]"
				)
			}]
		"scalping":
			return [{
				"icon": "⚡",
				"title": "스캘핑 트레이딩 — 기본 규칙",
				"body": (
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
				)
			}]
		"trading", "invest":
			return [{
				"icon": "📊",
				"title": "투자 화면 — 기본 규칙",
				"body": (
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
				)
			}]
		"racetrack":
			return [{
				"icon": "🏇",
				"title": "경마 — 기본 규칙",
				"body": (
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
				)
			}]
		"main_game":
			return [
				{
					"icon": "🏙",
					"title": "강남드림 — 게임 목표",
					"body": (
						"당신은 [b]김민준, 33세, 백수[/b].\n"
						+ "통장에 [b]50만원[/b]이 전부예요.\n\n"
						+ "목표는 딱 하나 —\n"
						+ "[color=#f0c040][b]5년 안에 자산 30억을 모아\n강남에 입성하는 것![/b][/color]\n\n"
						+ "매달(= 1턴)마다 [b]행동 포인트(AP)[/b]를 써서\n"
						+ "취업·투자·도박·인간관계 등을 선택하세요.\n\n"
						+ "[color=#aaffaa]💡 38세(60턴)가 되면 게임이 끝나요.\n"
						+ "   시간이 곧 자원이에요 — 매 달을 낭비하지 마세요![/color]"
					)
				},
				{
					"icon": "📊",
					"title": "대시보드 읽는 법",
					"body": (
						"[b]상단 스탯 바[/b]를 항상 확인하세요:\n\n"
						+ "  💰 [b]자산[/b] — 현금 + 포트폴리오 총합\n"
						+ "  ❤ [b]건강[/b] — 0이 되면 입원 or 사망\n"
						+ "  🧠 [b]정신력[/b] — 0이 되면 멘탈 붕괴\n"
						+ "  😤 [b]스트레스[/b] — 100이 되면 번아웃\n\n"
						+ "건강·정신력은 매달 자동으로 줄어요.\n"
						+ "무직이면 더 빨리 떨어지니 주의!\n\n"
						+ "[color=#aaffaa]💡 첫 달에는 [b]구직활동[/b]으로\n"
						+ "   일자리부터 구하는 게 안전해요.[/color]"
					)
				},
				{
					"icon": "⚡",
					"title": "한 달의 흐름",
					"body": (
						"매달 이렇게 진행돼요:\n\n"
						+ "1️⃣  [b]이달의 상황[/b] — 뉴스·이벤트 확인\n"
						+ "2️⃣  [b]선택[/b] — 행동 포인트(AP)를 써서 반응\n"
						+ "3️⃣  [b]다음 달 ▶[/b] — 시간이 흘러 다음 달로\n\n"
						+ "[b]AP를 쓸 수 있는 행동들:[/b]\n"
						+ "  💼 구직활동  📈 투자  🎰 강원랜드\n"
						+ "  🃏 홀덤  🏇 경마  👥 인맥 관리  등\n\n"
						+ "[color=#aaffaa]💡 AP가 남아도 다음 달로 넘어갈 수 있어요.\n"
						+ "   하지만 낭비하면 목표 달성이 어려워요![/color]"
					)
				}
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
var _icon_lbl: Label
var _title_lbl: Label

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
	card_sb.bg_color             = Color("#0e1424")
	card_sb.border_color         = Color("#3a5080")
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

	# 아이콘
	_icon_lbl = Label.new()
	_icon_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_icon_lbl.add_theme_font_size_override("font_size", 52)
	vbox.add_child(_icon_lbl)

	# 제목
	_title_lbl = Label.new()
	_title_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_title_lbl.add_theme_font_size_override("font_size", 22)
	_title_lbl.add_theme_color_override("font_color", Color("#e8d87c"))
	_f(_title_lbl, true)
	vbox.add_child(_title_lbl)

	# 구분선
	var sep := ColorRect.new()
	sep.custom_minimum_size = Vector2(0, 1)
	sep.color = Color("#2a3a5a")
	vbox.add_child(sep)

	# 본문
	_body_lbl = RichTextLabel.new()
	_body_lbl.bbcode_enabled = true
	_body_lbl.scroll_active = false
	_body_lbl.fit_content = false
	_body_lbl.custom_minimum_size = Vector2(0, 310)
	_body_lbl.add_theme_font_size_override("normal_font_size", 15)
	_body_lbl.add_theme_color_override("default_color", Color("#d8e0f0"))
	_f(_body_lbl)
	vbox.add_child(_body_lbl)

	# 하단 행 (페이지 + 버튼)
	var bottom_row := HBoxContainer.new()
	bottom_row.add_theme_constant_override("separation", 12)
	vbox.add_child(bottom_row)

	_page_lbl = Label.new()
	_page_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_page_lbl.add_theme_font_size_override("font_size", 13)
	_page_lbl.add_theme_color_override("font_color", Color("#5a6a8a"))
	_f(_page_lbl)
	bottom_row.add_child(_page_lbl)

	_next_btn = Button.new()
	_next_btn.custom_minimum_size = Vector2(180, 44)
	_next_btn.add_theme_font_size_override("font_size", 16)
	var btn_sb := StyleBoxFlat.new()
	btn_sb.bg_color = Color("#2a5a9a")
	btn_sb.set_corner_radius_all(6)
	btn_sb.content_margin_left  = 16
	btn_sb.content_margin_right = 16
	_next_btn.add_theme_stylebox_override("normal", btn_sb)
	var btn_hov := btn_sb.duplicate()
	btn_hov.bg_color = Color("#3a70c0")
	_next_btn.add_theme_stylebox_override("hover", btn_hov)
	_next_btn.add_theme_color_override("font_color", Color.WHITE)
	_f(_next_btn, true)
	_next_btn.pressed.connect(_on_next)
	bottom_row.add_child(_next_btn)

func _show_slide(idx: int) -> void:
	if idx >= _slides.size():
		_dismiss()
		return
	var slide: Dictionary = _slides[idx]
	_icon_lbl.text  = str(slide.get("icon", ""))
	_title_lbl.text = str(slide.get("title", ""))
	_body_lbl.text  = str(slide.get("body", ""))

	var total: int = _slides.size()
	if total > 1:
		_page_lbl.text = "%d / %d" % [idx + 1, total]
	else:
		_page_lbl.text = ""

	if idx < total - 1:
		_next_btn.text = "다음  ▶"
	else:
		_next_btn.text = "✅  이해했어요!"

func _on_next() -> void:
	_slide_idx += 1
	if _slide_idx >= _slides.size():
		_dismiss()
	else:
		_show_slide(_slide_idx)

func _dismiss() -> void:
	emit_signal("dismissed")
	queue_free()
