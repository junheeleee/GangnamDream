extends Control
## ArubaGame v2 — 직종별 전용 알바 미니게임
## job_01 편의점 야간: 바코드 스캔 타이밍 게임
## job_02 배달 라이더: 루트 최적화 퍼즐
## 그 외: 상황 카드 선택 (기존 방식)
## MainGame이 overlay로 붙이고 open()으로 표시. AP는 호출 전에 소비.

signal closed(earned: int, stress_delta: int)

enum Mode { CARDS, BARCODE, DELIVERY }

const BASE_PAY := 400_000

# ── 상황 카드 데이터 ──────────────────────────────────────────────
const SCENARIOS_CONVENIENCE = [
	{
		"scene": "밤 11시. 술 취한 손님이 계산대에 기대며 시비를 건다.",
		"choices": [
			{"text": "조용히 계산만 빠르게 끝낸다", "money": 0, "stress": 3, "health": 0, "tip": "별 탈 없이 넘어갔다."},
			{"text": "\"금방 계산해드릴게요\" 차분하게 대응한다", "money": 3000, "stress": 0, "health": 0, "tip": "손님이 고맙다며 팁을 남겼다."},
			{"text": "점장에게 메시지를 보낸다", "money": 0, "stress": -2, "health": 0, "tip": "점장이 나와줬다. 짧게 훈수만 들었다."},
		]
	},
	{
		"scene": "새벽 2시. 재고 정리 도중 냉동고 문이 고장났다. 혼자다.",
		"choices": [
			{"text": "응급처치 테이프로 임시 고정한다", "money": 0, "stress": 2, "health": -1, "tip": "아침에 점장이 솜씨를 칭찬했다."},
			{"text": "점장에게 즉시 전화한다", "money": 0, "stress": 5, "health": 0, "tip": "심야에 불러냈다. 눈치가 보인다."},
			{"text": "보고서를 꼼꼼하게 남겨두고 계속 일한다", "money": 5000, "stress": -1, "health": 0, "tip": "다음날 점장이 보너스를 줬다."},
		]
	},
	{
		"scene": "손님이 유통기한 지난 샌드위치를 들고 왔다.",
		"choices": [
			{"text": "죄송하다며 즉시 교환해준다", "money": 0, "stress": 2, "health": 0, "tip": "손님은 만족했다."},
			{"text": "점장 오기 전에 조용히 처리한다", "money": 0, "stress": -2, "health": 0, "tip": "아무도 모르게 넘어갔다."},
			{"text": "솔직하게 내 실수였다고 인정한다", "money": -5000, "stress": 4, "health": 0, "tip": "점장은 정직함을 높이 샀다."},
		]
	},
	{
		"scene": "단골 할머니가 계산이 틀렸다며 화를 낸다. 실제로 계산은 맞다.",
		"choices": [
			{"text": "영수증을 보여드리며 차분히 설명한다", "money": 2000, "stress": 2, "health": 0, "tip": "오해가 풀렸다. 다음에 또 오셨다."},
			{"text": "그냥 200원을 돌려드린다", "money": -200, "stress": -3, "health": 0, "tip": "갈등은 사라졌다. 속은 좀 쓰렸다."},
			{"text": "모른 척 묻어간다", "money": 0, "stress": 1, "health": -1, "tip": "기분이 영 안 좋다."},
		]
	},
	{
		"scene": "복권 당첨자가 나왔다! 5만원 당첨. 손님이 현금으로 즉시 달라고 한다.",
		"choices": [
			{"text": "절차대로 본사 처리를 안내한다", "money": 0, "stress": 2, "health": 0, "tip": "규정대로 처리됐다."},
			{"text": "점장에게 먼저 확인한다", "money": 0, "stress": -1, "health": 0, "tip": "문제없이 마무리됐다."},
			{"text": "내 돈으로 먼저 주고 정산한다", "money": -50000, "stress": -2, "health": 0, "tip": "나중에 돌려받았다."},
		]
	},
]

const SCENARIOS_DELIVERY = [
	{
		"scene": "비가 쏟아진다. 포장이 젖을 것 같다.",
		"choices": [
			{"text": "속도를 올려 빠르게 배달한다", "money": 3000, "stress": 3, "health": -2, "tip": "음식은 겨우 살았다."},
			{"text": "편의점에서 봉지를 사서 싼다", "money": -1000, "stress": -1, "health": 0, "tip": "손님이 별 5개를 줬다."},
			{"text": "배달 앱에 상황을 알린다", "money": 0, "stress": 1, "health": 0, "tip": "아무 일 없이 넘어갔다."},
		]
	},
	{
		"scene": "손님이 주소를 틀리게 써놨다. 전화가 안 된다.",
		"choices": [
			{"text": "인근을 돌며 찾아본다", "money": 0, "stress": 4, "health": -1, "tip": "10분 뒤 손님이 다시 전화했다."},
			{"text": "배달 앱 고객센터에 연락한다", "money": 5000, "stress": -1, "health": 0, "tip": "고객센터가 처리비를 줬다."},
			{"text": "입구에 두고 사진 찍어 알린다", "money": 0, "stress": 0, "health": 0, "tip": "별점 3개."},
		]
	},
	{
		"scene": "오토바이 접촉사고가 났다. 작은 긁힘이고 상대방이 그냥 가자고 한다.",
		"choices": [
			{"text": "번호판 찍어두고 보험 처리한다", "money": -10000, "stress": 3, "health": 0, "tip": "정식 처리. 시간이 걸렸다."},
			{"text": "상대방 말대로 그냥 넘어간다", "money": 0, "stress": -2, "health": -2, "tip": "나중에 찜찜했다."},
			{"text": "현장에서 합의금을 받는다", "money": 30000, "stress": 1, "health": 0, "tip": "빠르게 해결됐다."},
		]
	},
	{
		"scene": "같은 구역 배달 기사가 콜을 가로채는 것 같다.",
		"choices": [
			{"text": "증거를 모아 신고한다", "money": 0, "stress": 3, "health": 0, "tip": "플랫폼에서 패널티가 부과됐다."},
			{"text": "직접 말을 건다", "money": 10000, "stress": 1, "health": 0, "tip": "이후로 달라졌다."},
			{"text": "무시하고 더 빠르게 치고 나간다", "money": 5000, "stress": 2, "health": -1, "tip": "속도로 따돌렸다."},
		]
	},
]

const SCENARIOS_GENERAL = [
	{
		"scene": "내일 마감인 보고서가 있는데 부장이 야근을 부탁했다.",
		"choices": [
			{"text": "자정까지 남아서 끝낸다", "money": 20000, "stress": 6, "health": -2, "tip": "초과 수당이 붙었다."},
			{"text": "내 업무만 끝내고 퇴근한다", "money": 0, "stress": 0, "health": 0, "tip": "원칙적이다."},
			{"text": "다음날 일찍 나와서 마무리하겠다 제안한다", "money": 5000, "stress": -2, "health": 0, "tip": "상사가 만족했다."},
		]
	},
	{
		"scene": "카페 마감 청소 중. 손님이 15분 전에 들어와 자리를 잡았다.",
		"choices": [
			{"text": "영업시간 종료를 정중히 알린다", "money": 0, "stress": -1, "health": 0, "tip": "손님이 이해하고 나갔다."},
			{"text": "그냥 청소하면서 눈치를 준다", "money": 0, "stress": 2, "health": 0, "tip": "분위기가 어색해졌다."},
			{"text": "청소를 미루고 손님이 갈 때까지 기다린다", "money": 3000, "stress": -3, "health": 0, "tip": "손님이 팁을 남기고 갔다."},
		]
	},
	{
		"scene": "오전 오픈 담당인데 키를 잃어버렸다. 30분 뒤 오픈이다.",
		"choices": [
			{"text": "사장에게 즉시 연락한다", "money": -10000, "stress": 5, "health": 0, "tip": "잔소리를 들었다."},
			{"text": "가방을 샅샅이 다시 뒤진다", "money": 0, "stress": 2, "health": 0, "tip": "사물함 안에 있었다."},
			{"text": "인근 직원에게 부탁한다", "money": -5000, "stress": -1, "health": 0, "tip": "저녁에 커피 한 잔 샀다."},
		]
	},
	{
		"scene": "월급날인데 사장이 이번 달 하루 늦는다고 한다. 두 번째다.",
		"choices": [
			{"text": "그러시겠냐고 넘어간다", "money": 0, "stress": 3, "health": 0, "tip": "속이 쓰리다."},
			{"text": "근로계약서 조항을 언급하며 부탁한다", "money": 0, "stress": 1, "health": 0, "tip": "다음날 입금됐다."},
			{"text": "노동부 신고를 검토한다", "money": 0, "stress": -2, "health": 0, "tip": "결국 제때 입금됐다."},
		]
	},
]

# ── 바코드 스캔 상수 ──────────────────────────────────────────────
const BC_TOTAL := 8            # 스캔 아이템 수
const BC_BAR_W := 280          # 스캔 바 너비 (ScanBarDraw.TX/TW와 반드시 일치)
const BC_TARGET_X := 105       # 목표 구간 시작 x
const BC_TARGET_W := 70        # 목표 구간 너비
const BC_PERFECT_W := 28       # 퍼펙트 구간 너비 (목표 중심)
const BC_NEEDLE_W := 5         # 바늘 너비
const BC_SPEED_BASE := 180.0   # 1번째 아이템 속도 (px/s)
const BC_SPEED_ADD := 13.0     # 아이템마다 가속
const BC_EARN_PERFECT := 36_000
const BC_EARN_GOOD := 14_000
const BC_ITEMS_POOL = [
	"삼각김밥 참치마요", "컵라면 신라면", "핫도그", "바나나우유",
	"에너지 음료", "냉동 만두", "아이스 아메리카노", "크림빵",
	"허니버터칩", "닭가슴살 샐러드", "편의점 도시락", "껌 자일리톨"
]

# ── 배달 루트 상수 ────────────────────────────────────────────────
const DEL_TIME_BUDGET := 120   # 총 배달 가능 시간 (분)
const DEL_BASE_BONUS := 8_000  # 배달 완료 1건당 기본 보너스
const DEL_ORDERS_DATA = [
	{"name": "홍대 치킨", "time": 18, "tip": 5_000, "info": "1층 · 18분"},
	{"name": "신촌 피자", "time": 30, "tip": 11_000, "info": "3층 · 30분"},
	{"name": "여의도 오피스 런치", "time": 45, "tip": 18_000, "info": "22층 · 45분"},
	{"name": "이대 야식", "time": 25, "tip": 8_000, "info": "4층 · 25분"},
	{"name": "공덕역 카페", "time": 14, "tip": 4_000, "info": "1층 · 14분"},
	{"name": "마포 공사장 도시락", "time": 8, "tip": 2_500, "info": "1층 · 8분"},
]

# ── 상태 변수 ─────────────────────────────────────────────────────
var _rng := RandomNumberGenerator.new()
var _mode: Mode = Mode.CARDS
var _earned: int = BASE_PAY
var _stress_delta: int = 0
var _health_delta: int = 0

# CARDS 상태
var _scenarios: Array = []
var _card_idx: int = 0
var _card_waiting: bool = false
var _card_timer: float = 0.0

# BARCODE 상태
var _bc_item_idx: int = 0
var _bc_needle_x: float = 0.0
var _bc_needle_dir: float = 1.0
var _bc_speed: float = BC_SPEED_BASE
var _bc_results: Array = []   # "perfect" | "good" | "miss"
var _bc_waiting: bool = false
var _bc_wait_timer: float = 0.0
var _bc_can_scan: bool = false
var _bc_shuffled: Array = []

# DELIVERY 상태
var _del_selected: Array = []  # DEL_ORDERS_DATA 인덱스, 클릭 순서

# ── UI 노드 참조 ──────────────────────────────────────────────────
var _root_vb: VBoxContainer
var _header_lbl: Label
var _progress_lbl: Label
var _content_vb: VBoxContainer

# CARDS UI
var _scene_lbl: Label
var _choice_vb: VBoxContainer
var _feedback_lbl: Label

# BARCODE UI
var _bc_item_lbl: Label
var _bc_bar          # ScanBarDraw 인스턴스 (동적 타입)
var _bc_zone_lbl: Label
var _bc_hist_lbl: Label
var _bc_scan_btn: Button

# DELIVERY UI
var _del_order_btns: Array = []
var _del_status_lbl: Label
var _del_confirm_btn: Button

# ── 스캔 바 시각화 (내부 클래스) ─────────────────────────────────
class ScanBarDraw extends Control:
	# 외부 클래스의 BC_TARGET_X/W 등과 반드시 일치해야 함
	const TX := 105
	const TW := 70
	const PW := 28
	const NW := 5

	var needle_x: float = 0.0

	func set_needle(x: float) -> void:
		needle_x = x
		queue_redraw()

	func zone_at(x: float) -> String:
		var center := TX + TW * 0.5
		if abs(x - center) <= PW * 0.5:
			return "perfect"
		elif x >= TX and x <= TX + TW:
			return "good"
		return "miss"

	func _draw() -> void:
		var w := int(size.x)
		var h := int(size.y)
		if w <= 0 or h <= 0:
			return
		# 배경 (미스 구간)
		draw_rect(Rect2(0, 0, w, h), Color("#080e1c"))
		# 굿 구간 (초록)
		draw_rect(Rect2(TX, 3, TW, h - 6), Color("#1a4a1a"))
		# 퍼펙트 구간 (밝은 초록, 목표 중심)
		var px := TX + int((TW - PW) * 0.5)
		draw_rect(Rect2(px, 5, PW, h - 10), Color("#2a8a3a"))
		# 바늘 (흰색)
		var nx := int(needle_x - NW * 0.5)
		draw_rect(Rect2(nx, 0, NW, h), Color("#f8faff"))
		# 양끝 경계 마커
		draw_rect(Rect2(0, int(h * 0.2), 3, int(h * 0.6)), Color("#2a3a5a"))
		draw_rect(Rect2(w - 3, int(h * 0.2), 3, int(h * 0.6)), Color("#2a3a5a"))

# ── 초기화 ───────────────────────────────────────────────────────
func _ready() -> void:
	_rng.randomize()
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_build_base_ui()
	visible = false
	set_process(false)

func _process(delta: float) -> void:
	match _mode:
		Mode.BARCODE:
			if _bc_waiting:
				_bc_wait_timer -= delta
				if _bc_wait_timer <= 0.0:
					_bc_waiting = false
					_bc_item_idx += 1
					if _bc_item_idx >= BC_TOTAL:
						_show_result()
					else:
						_bc_show_item()
			elif _bc_can_scan:
				_bc_needle_x += _bc_speed * _bc_needle_dir * delta
				if _bc_needle_x >= BC_BAR_W:
					_bc_needle_x = BC_BAR_W
					_bc_needle_dir = -1.0
				elif _bc_needle_x <= 0.0:
					_bc_needle_x = 0.0
					_bc_needle_dir = 1.0
				if _bc_bar != null:
					_bc_bar.set_needle(_bc_needle_x)
		Mode.CARDS:
			if _card_waiting:
				_card_timer -= delta
				if _card_timer <= 0.0:
					_card_waiting = false
					_card_idx += 1
					if _card_idx >= _scenarios.size():
						_show_result()
					else:
						_show_scenario(_card_idx)

# ── 진입 ─────────────────────────────────────────────────────────
func open() -> void:
	_earned = BASE_PAY
	_stress_delta = 0
	_health_delta = 0
	_bc_results = []
	_del_selected = []
	_bc_item_idx = 0
	_card_idx = 0
	_card_waiting = false
	_bc_waiting = false
	_bc_can_scan = false

	var job_id: String = GameState.current_job.get("id", "")
	match job_id:
		"job_01": _mode = Mode.BARCODE
		"job_02": _mode = Mode.DELIVERY
		_:        _mode = Mode.CARDS

	_clear_content()
	visible = true

	match _mode:
		Mode.BARCODE:
			_header_lbl.text = "🏪 편의점 야간 시프트"
			_start_barcode()
		Mode.DELIVERY:
			_header_lbl.text = "🛵 배달 루트 설정"
			_start_delivery()
		Mode.CARDS:
			_header_lbl.text = "💼 알바 시프트"
			_start_cards()

func _clear_content() -> void:
	for ch in _content_vb.get_children():
		ch.queue_free()
	_bc_bar = null
	_bc_scan_btn = null
	_bc_item_lbl = null
	_bc_zone_lbl = null
	_bc_hist_lbl = null
	_del_order_btns = []
	_del_status_lbl = null
	_del_confirm_btn = null

# ── 기반 UI ──────────────────────────────────────────────────────
func _build_base_ui() -> void:
	var bg := ColorRect.new()
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.color = Color("#060a12")
	add_child(bg)

	var margin := MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 24)
	margin.add_theme_constant_override("margin_right", 24)
	margin.add_theme_constant_override("margin_top", 20)
	margin.add_theme_constant_override("margin_bottom", 20)
	add_child(margin)

	_root_vb = VBoxContainer.new()
	_root_vb.add_theme_constant_override("separation", 10)
	margin.add_child(_root_vb)

	var hdr := HBoxContainer.new()
	_root_vb.add_child(hdr)
	_header_lbl = Label.new()
	_header_lbl.text = "💼 알바 시프트"
	_header_lbl.add_theme_font_size_override("font_size", 17)
	_header_lbl.add_theme_color_override("font_color", Color("#f0b429"))
	_header_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hdr.add_child(_header_lbl)
	_progress_lbl = Label.new()
	_progress_lbl.add_theme_font_size_override("font_size", 12)
	_progress_lbl.add_theme_color_override("font_color", Color("#5a6a8a"))
	hdr.add_child(_progress_lbl)

	var sep := HSeparator.new()
	sep.add_theme_color_override("color", Color("#1a2030"))
	_root_vb.add_child(sep)

	_content_vb = VBoxContainer.new()
	_content_vb.add_theme_constant_override("separation", 8)
	_content_vb.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_root_vb.add_child(_content_vb)

# ══════════════════════════════════════════════════════════════════
# CARDS 모드
# ══════════════════════════════════════════════════════════════════
func _start_cards() -> void:
	var job_id: String = GameState.current_job.get("id", "")
	var pool: Array
	match job_id:
		"job_01": pool = SCENARIOS_CONVENIENCE
		"job_02": pool = SCENARIOS_DELIVERY
		_:        pool = SCENARIOS_GENERAL

	var shuffled := pool.duplicate()
	shuffled.shuffle()
	var mastery := MetaProgression.get_mastery("aruba")
	var count := 3
	if GameState.social_skill >= 50: count = 4
	if mastery >= 2: count = maxi(count, 4)
	if mastery >= 3: count = 5
	_scenarios = shuffled.slice(0, mini(count, shuffled.size()))

	_scene_lbl = Label.new()
	_scene_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_scene_lbl.add_theme_font_size_override("font_size", 14)
	_scene_lbl.add_theme_color_override("font_color", Color("#d0d8e0"))
	_scene_lbl.custom_minimum_size = Vector2(0, 70)
	_content_vb.add_child(_scene_lbl)

	_feedback_lbl = Label.new()
	_feedback_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_feedback_lbl.add_theme_font_size_override("font_size", 12)
	_feedback_lbl.add_theme_color_override("font_color", Color("#3dba6a"))
	_feedback_lbl.custom_minimum_size = Vector2(0, 22)
	_content_vb.add_child(_feedback_lbl)

	_choice_vb = VBoxContainer.new()
	_choice_vb.add_theme_constant_override("separation", 7)
	_content_vb.add_child(_choice_vb)

	set_process(true)
	_show_scenario(0)

func _show_scenario(idx: int) -> void:
	var sc: Dictionary = _scenarios[idx]
	_scene_lbl.text = sc["scene"]
	_feedback_lbl.text = ""
	_progress_lbl.text = "%d / %d" % [idx + 1, _scenarios.size()]

	for ch in _choice_vb.get_children():
		ch.queue_free()
	for ci in range(sc["choices"].size()):
		var btn := _make_btn(sc["choices"][ci]["text"], "#0e1a2a", 13)
		btn.pressed.connect(func(): _on_cards_choice(sc, ci))
		_choice_vb.add_child(btn)

func _on_cards_choice(sc: Dictionary, ci: int) -> void:
	var choice: Dictionary = sc["choices"][ci]
	_earned += int(choice.get("money", 0))
	_stress_delta += int(choice.get("stress", 0))
	_health_delta += int(choice.get("health", 0))
	_feedback_lbl.text = "→ " + str(choice.get("tip", ""))
	for ch in _choice_vb.get_children():
		if ch is Button:
			ch.disabled = true
	AudioManager.play("click")
	_card_waiting = true
	_card_timer = 0.9

# ══════════════════════════════════════════════════════════════════
# BARCODE 모드 — 바코드 스캔 타이밍 게임
# ══════════════════════════════════════════════════════════════════
func _start_barcode() -> void:
	_bc_shuffled = BC_ITEMS_POOL.duplicate()
	_bc_shuffled.shuffle()
	_bc_shuffled = _bc_shuffled.slice(0, BC_TOTAL)
	_bc_speed = BC_SPEED_BASE
	_bc_needle_x = 0.0
	_bc_needle_dir = 1.0

	var guide := Label.new()
	guide.text = "바늘이 초록 구간에 들어올 때 [삐빅!] 을 누르세요."
	guide.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	guide.add_theme_font_size_override("font_size", 12)
	guide.add_theme_color_override("font_color", Color("#7a9ab0"))
	_content_vb.add_child(guide)

	_bc_item_lbl = Label.new()
	_bc_item_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_bc_item_lbl.add_theme_font_size_override("font_size", 20)
	_bc_item_lbl.add_theme_color_override("font_color", Color("#e8eaf0"))
	_bc_item_lbl.custom_minimum_size = Vector2(0, 30)
	_content_vb.add_child(_bc_item_lbl)

	# 스캔 바 (커스텀 드로우)
	_bc_bar = ScanBarDraw.new()
	_bc_bar.custom_minimum_size = Vector2(BC_BAR_W, 38)
	_bc_bar.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	_content_vb.add_child(_bc_bar)

	_bc_zone_lbl = Label.new()
	_bc_zone_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_bc_zone_lbl.add_theme_font_size_override("font_size", 16)
	_bc_zone_lbl.add_theme_color_override("font_color", Color("#3dba6a"))
	_bc_zone_lbl.custom_minimum_size = Vector2(0, 24)
	_content_vb.add_child(_bc_zone_lbl)

	_bc_hist_lbl = Label.new()
	_bc_hist_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_bc_hist_lbl.add_theme_font_size_override("font_size", 14)
	_bc_hist_lbl.add_theme_color_override("font_color", Color("#4a6a4a"))
	_bc_hist_lbl.custom_minimum_size = Vector2(0, 22)
	_content_vb.add_child(_bc_hist_lbl)

	_bc_scan_btn = _make_btn("삐빅!", "#0d3a1a", 20)
	_bc_scan_btn.custom_minimum_size = Vector2(0, 56)
	_bc_scan_btn.pressed.connect(_bc_on_scan)
	_content_vb.add_child(_bc_scan_btn)

	set_process(true)
	_bc_show_item()

func _bc_show_item() -> void:
	_progress_lbl.text = "%d / %d" % [_bc_item_idx + 1, BC_TOTAL]
	if is_instance_valid(_bc_item_lbl):
		_bc_item_lbl.text = _bc_shuffled[_bc_item_idx]
	if is_instance_valid(_bc_zone_lbl):
		_bc_zone_lbl.text = ""
	_bc_needle_x = 0.0
	_bc_needle_dir = 1.0
	_bc_speed = BC_SPEED_BASE + _bc_item_idx * BC_SPEED_ADD
	if _bc_bar != null:
		_bc_bar.set_needle(_bc_needle_x)
	_bc_can_scan = true
	if is_instance_valid(_bc_scan_btn):
		_bc_scan_btn.disabled = false

func _bc_on_scan() -> void:
	if not _bc_can_scan or _bc_waiting:
		return
	_bc_can_scan = false
	if is_instance_valid(_bc_scan_btn):
		_bc_scan_btn.disabled = true

	var zone := _bc_bar.zone_at(_bc_needle_x) if _bc_bar != null else "miss"
	_bc_results.append(zone)

	match zone:
		"perfect":
			_earned += BC_EARN_PERFECT
			_stress_delta -= 1
			if is_instance_valid(_bc_zone_lbl):
				_bc_zone_lbl.text = "✦ 퍼펙트!"
				_bc_zone_lbl.add_theme_color_override("font_color", Color("#f0e040"))
			AudioManager.play("money_gain")
		"good":
			_earned += BC_EARN_GOOD
			if is_instance_valid(_bc_zone_lbl):
				_bc_zone_lbl.text = "✓ 굿"
				_bc_zone_lbl.add_theme_color_override("font_color", Color("#3dba6a"))
			AudioManager.play("click")
		"miss":
			_stress_delta += 1
			if is_instance_valid(_bc_zone_lbl):
				_bc_zone_lbl.text = "✗ 미스"
				_bc_zone_lbl.add_theme_color_override("font_color", Color("#e85d5d"))
			AudioManager.play("money_loss")

	_bc_update_hist()
	_bc_waiting = true
	_bc_wait_timer = 0.75

func _bc_update_hist() -> void:
	var s := ""
	for r in _bc_results:
		match r:
			"perfect": s += "★"
			"good":    s += "○"
			"miss":    s += "✗"
	if is_instance_valid(_bc_hist_lbl):
		_bc_hist_lbl.text = s

# ══════════════════════════════════════════════════════════════════
# DELIVERY 모드 — 배달 루트 최적화 퍼즐
# ══════════════════════════════════════════════════════════════════
func _start_delivery() -> void:
	set_process(false)
	_progress_lbl.text = "루트 설정"

	var guide := Label.new()
	guide.text = "제한 시간 %d분. 배달할 순서대로 클릭하세요. (클릭 취소 가능)" % DEL_TIME_BUDGET
	guide.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	guide.add_theme_font_size_override("font_size", 12)
	guide.add_theme_color_override("font_color", Color("#7a9ab0"))
	_content_vb.add_child(guide)

	var orders_vb := VBoxContainer.new()
	orders_vb.add_theme_constant_override("separation", 5)
	_content_vb.add_child(orders_vb)

	for i in range(DEL_ORDERS_DATA.size()):
		var o: Dictionary = DEL_ORDERS_DATA[i]
		var btn := _make_btn(
			"%s  [%s]  팁 +%s" % [o["name"], o["info"], _fmt(o["tip"])],
			"#0e1a2e", 13)
		btn.custom_minimum_size = Vector2(0, 40)
		var cap_i: int = i
		btn.pressed.connect(func(): _del_toggle(cap_i))
		orders_vb.add_child(btn)
		_del_order_btns.append(btn)

	_del_status_lbl = Label.new()
	_del_status_lbl.add_theme_font_size_override("font_size", 13)
	_del_status_lbl.add_theme_color_override("font_color", Color("#c8a060"))
	_del_status_lbl.custom_minimum_size = Vector2(0, 22)
	_content_vb.add_child(_del_status_lbl)

	_del_confirm_btn = _make_btn("배달 출발!", "#0d3a1a", 15)
	_del_confirm_btn.custom_minimum_size = Vector2(0, 48)
	_del_confirm_btn.disabled = true
	_del_confirm_btn.pressed.connect(_del_confirm)
	_content_vb.add_child(_del_confirm_btn)

	_del_refresh_ui()

func _del_toggle(idx: int) -> void:
	var pos := _del_selected.find(idx)
	if pos >= 0:
		_del_selected.remove_at(pos)
	else:
		_del_selected.append(idx)
	_del_refresh_ui()

func _del_refresh_ui() -> void:
	var time_used := 0
	for i in _del_selected:
		time_used += int(DEL_ORDERS_DATA[i]["time"])

	for i in range(_del_order_btns.size()):
		var btn: Button = _del_order_btns[i]
		if not is_instance_valid(btn):
			continue
		var o: Dictionary = DEL_ORDERS_DATA[i]
		var sel_pos := _del_selected.find(i)
		var would_exceed := (time_used + int(o["time"])) > DEL_TIME_BUDGET and sel_pos < 0

		if sel_pos >= 0:
			btn.text = "%d번째  %s  [%s]  팁 +%s" % [sel_pos + 1, o["name"], o["info"], _fmt(o["tip"])]
			var st := StyleBoxFlat.new()
			st.bg_color = Color("#1a3a1a")
			st.set_corner_radius_all(5)
			btn.add_theme_stylebox_override("normal", st)
			btn.add_theme_color_override("font_color", Color("#6af0a0"))
			btn.disabled = false
		else:
			btn.text = "%s  [%s]  팁 +%s" % [o["name"], o["info"], _fmt(o["tip"])]
			var st := StyleBoxFlat.new()
			st.bg_color = Color("#0e1a2e" if not would_exceed else "#1a1218")
			st.set_corner_radius_all(5)
			btn.add_theme_stylebox_override("normal", st)
			btn.add_theme_color_override("font_color",
				Color("#c8d8e8") if not would_exceed else Color("#4a3a4a"))
			btn.disabled = would_exceed

	var tip_preview := 0
	var bonus_preview := 0
	for i in _del_selected:
		tip_preview += int(DEL_ORDERS_DATA[i]["tip"])
		bonus_preview += DEL_BASE_BONUS

	var remaining := DEL_TIME_BUDGET - time_used
	var status_color := "#3dba6a" if remaining >= 20 else "#f0b429" if remaining >= 0 else "#e85d5d"
	if is_instance_valid(_del_status_lbl):
		_del_status_lbl.text = "소요 %d분 / %d분 (여유 %d분)  |  예상 추가 수입 +%s" % [
			time_used, DEL_TIME_BUDGET, remaining, _fmt(tip_preview + bonus_preview)]
		_del_status_lbl.add_theme_color_override("font_color", Color(status_color))

	if is_instance_valid(_del_confirm_btn):
		_del_confirm_btn.disabled = _del_selected.is_empty()

func _del_confirm() -> void:
	var tip_total := 0
	for i in _del_selected:
		tip_total += int(DEL_ORDERS_DATA[i]["tip"])
	var delivery_count := _del_selected.size()
	_earned += tip_total + delivery_count * DEL_BASE_BONUS
	_stress_delta += maxi(delivery_count - 2, 0)   # 3건부터 스트레스
	_health_delta -= delivery_count
	_show_result()

# ══════════════════════════════════════════════════════════════════
# 결과 화면
# ══════════════════════════════════════════════════════════════════
func _show_result() -> void:
	set_process(false)
	_clear_content()
	_progress_lbl.text = "완료"

	AudioManager.play("money_gain" if _earned >= BASE_PAY else "money_loss")

	var finish_lbl := Label.new()
	finish_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	finish_lbl.add_theme_font_size_override("font_size", 15)
	finish_lbl.add_theme_color_override("font_color", Color("#f0b429"))
	_content_vb.add_child(finish_lbl)

	match _mode:
		Mode.BARCODE:
			var p := _bc_results.count("perfect")
			var g := _bc_results.count("good")
			var m := _bc_results.count("miss")
			finish_lbl.text = "시프트 종료  ★%d  ○%d  ✗%d" % [p, g, m]
		Mode.DELIVERY:
			finish_lbl.text = "배달 완료 — %d건" % _del_selected.size()
		Mode.CARDS:
			finish_lbl.text = "시프트 끝"

	var earn_lbl := Label.new()
	earn_lbl.text = "+%s" % _fmt(_earned)
	earn_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	earn_lbl.add_theme_font_size_override("font_size", 28)
	earn_lbl.add_theme_color_override("font_color",
		Color("#3dba6a") if _earned >= BASE_PAY else Color("#e85d5d"))
	_content_vb.add_child(earn_lbl)

	var stat_row := HBoxContainer.new()
	stat_row.alignment = BoxContainer.ALIGNMENT_CENTER
	stat_row.add_theme_constant_override("separation", 16)
	_content_vb.add_child(stat_row)
	if _stress_delta != 0:
		stat_row.add_child(_mini_lbl(
			"스트레스 %+d" % _stress_delta,
			"#e85d5d" if _stress_delta > 0 else "#3dba6a"))
	if _health_delta != 0:
		stat_row.add_child(_mini_lbl(
			"건강 %+d" % _health_delta,
			"#e85d5d" if _health_delta < 0 else "#3dba6a"))

	var ok_btn := _make_btn("퇴근하기", "#0e3a2a", 15)
	ok_btn.custom_minimum_size = Vector2(0, 46)
	ok_btn.pressed.connect(_on_finish)
	_content_vb.add_child(ok_btn)

func _on_finish() -> void:
	MetaProgression.record_minigame_play("aruba")
	visible = false
	closed.emit(_earned, _stress_delta)

# ── 헬퍼 ─────────────────────────────────────────────────────────
func _make_btn(text: String, bg_hex: String, font_size: int) -> Button:
	var btn := Button.new()
	btn.text = text
	btn.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var st := StyleBoxFlat.new()
	st.bg_color = Color(bg_hex)
	st.set_corner_radius_all(6)
	var hov := st.duplicate()
	hov.bg_color = st.bg_color.lightened(0.1)
	var dis := st.duplicate()
	dis.bg_color = st.bg_color.darkened(0.4)
	btn.add_theme_stylebox_override("normal", st)
	btn.add_theme_stylebox_override("hover", hov)
	btn.add_theme_stylebox_override("pressed", hov)
	btn.add_theme_stylebox_override("disabled", dis)
	btn.add_theme_color_override("font_color", Color("#e8eaf0"))
	btn.add_theme_color_override("font_disabled_color", Color("#4a5a6a"))
	btn.add_theme_font_size_override("font_size", font_size)
	return btn

func _mini_lbl(text: String, color_hex: String) -> Label:
	var lbl := Label.new()
	lbl.text = text
	lbl.add_theme_font_size_override("font_size", 11)
	lbl.add_theme_color_override("font_color", Color(color_hex))
	return lbl

func _fmt(v: int) -> String:
	if v >= 10_000_000:
		return "%.1f천만원" % (v / 10_000_000.0)
	elif v >= 1_000_000:
		return "%.1f백만원" % (v / 1_000_000.0)
	elif v >= 10_000:
		return "%d만원" % (v / 10_000)
	return "%d원" % v
