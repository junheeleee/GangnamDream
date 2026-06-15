extends Control
## ArubaGame v3 — 직종별 전용 알바 미니게임
## job_01 편의점 야간: 손님 응대 게임 (3-슬롯 멀티태스킹, 오버쿡 스타일)
## job_02 배달 라이더: 루트 최적화 퍼즐
## 그 외: 상황 카드 선택
## MainGame이 overlay로 붙이고 open()으로 표시. AP는 호출 전에 소비.

signal closed(earned: int, stress_delta: int)

enum Mode { CARDS, CONVENIENCE, DELIVERY }

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
			{"text": "영수증을 보여드리며 차분히 설명한다", "money": 2000, "stress": 2, "health": 0, "tip": "오해가 풀렸다."},
			{"text": "그냥 200원을 돌려드린다", "money": -200, "stress": -3, "health": 0, "tip": "갈등은 사라졌다."},
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

# ── 편의점 손님 유형 (10명 풀, 매 시프트 랜덤) ───────────────────
const CUSTOMER_TYPES = [
	{
		"emoji": "🛒", "name": "계산 손님",
		"text": "저기요, 계산이요.",
		"patience": 12.0, "urgency": 1,
		"actions": [
			{"text": "빠르게 스캔한다", "bonus": 2_000, "stress": 0, "tip": "뚝딱 처리됐다."},
			{"text": "\"잠깐만요~\" 다른 손님 먼저", "bonus": -1_000, "stress": 1, "tip": "한숨 쉬며 기다렸다."},
		]
	},
	{
		"emoji": "😤", "name": "진상 손님",
		"text": "야! 왜 이렇게 느려!",
		"patience": 6.0, "urgency": 3,
		"actions": [
			{"text": "\"죄송합니다\" 차분히 대응", "bonus": 0, "stress": 2, "tip": "간신히 진정됐다."},
			{"text": "\"불편하셨다면 더 노력하겠습니다\"", "bonus": 1_000, "stress": 1, "tip": "오히려 미안해했다."},
			{"text": "무시하고 다른 손님 먼저", "bonus": -2_000, "stress": 5, "tip": "점장한테 신고한다고."},
		]
	},
	{
		"emoji": "👵", "name": "단골 할머니",
		"text": "총각, 나 봤어요? 매일 오는데.",
		"patience": 16.0, "urgency": 0,
		"actions": [
			{"text": "반갑게 인사하며 응대한다", "bonus": 5_000, "stress": -1, "tip": "세뱃돈 같은 거라며 주셨다."},
			{"text": "바쁜 척 빠르게 처리한다", "bonus": 0, "stress": 1, "tip": "섭섭해하셨다."},
		]
	},
	{
		"emoji": "🍺", "name": "취한 손님",
		"text": "야... 소주 어디 있어요?",
		"patience": 9.0, "urgency": 2,
		"actions": [
			{"text": "친절하게 안내한다", "bonus": 0, "stress": 1, "tip": "고맙다며 갔다."},
			{"text": "\"많이 드셨는데 괜찮으세요?\"", "bonus": 2_000, "stress": 0, "tip": "감동받았다며 팁을."},
			{"text": "못 본 척한다", "bonus": -1_000, "stress": 2, "tip": "혼자 한참 헤맸다."},
		]
	},
	{
		"emoji": "📦", "name": "교환 손님",
		"text": "이거 어제 샀는데 불량이에요.",
		"patience": 10.0, "urgency": 1,
		"actions": [
			{"text": "영수증 확인 후 즉시 교환", "bonus": 2_000, "stress": 1, "tip": "깔끔하게 처리됐다."},
			{"text": "점장에게 물어봐야 한다고 설명", "bonus": -1_000, "stress": 2, "tip": "손님이 불만이다."},
		]
	},
	{
		"emoji": "📬", "name": "택배 손님",
		"text": "택배 여기 맡겼는데요.",
		"patience": 11.0, "urgency": 1,
		"actions": [
			{"text": "등록번호 확인 후 찾아준다", "bonus": 1_000, "stress": 0, "tip": "빠르게 처리됐다."},
			{"text": "뒤에 있을 거라고 알아서 찾으라 한다", "bonus": -500, "stress": 1, "tip": "손님이 불만 표정."},
		]
	},
	{
		"emoji": "💳", "name": "포인트 손님",
		"text": "포인트 카드요! 이거 적립 됐어요?",
		"patience": 9.0, "urgency": 1,
		"actions": [
			{"text": "영수증 보고 재적립 처리", "bonus": 1_000, "stress": 0, "tip": "감사합니다! 하며 갔다."},
			{"text": "\"계산 전에 말씀해야...\"", "bonus": -500, "stress": 2, "tip": "다시는 안 온다고."},
		]
	},
	{
		"emoji": "🤔", "name": "길 묻는 손님",
		"text": "저기, 삼각김밥 어디 있어요?",
		"patience": 13.0, "urgency": 0,
		"actions": [
			{"text": "직접 자리에서 안내한다", "bonus": 1_000, "stress": 0, "tip": "고마워하며 여러 개 샀다."},
			{"text": "방향만 손으로 가리킨다", "bonus": 0, "stress": 0, "tip": "찾아갔다."},
		]
	},
]

const CONV_TOTAL := 10           # 시프트당 총 손님 수
const CONV_SLOTS := 3            # 동시 처리 슬롯
const CONV_SLOT_H := 72.0        # 슬롯 패널 높이 (px)
const CONV_TIMEOUT_STRESS := 2   # 타임아웃당 스트레스 (기본; urgency 3이면 +1 추가)

# ── 배달 루트 상수 ────────────────────────────────────────────────
const DEL_TIME_BUDGET := 120
const DEL_BASE_BONUS := 8_000
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

# CONVENIENCE 상태
var _conv_queue: Array = []                          # 아직 미등장 손님
var _conv_slots: Array = [null, null, null]          # 현재 슬롯 손님 데이터
var _conv_slot_patience: Array = [0.0, 0.0, 0.0]    # 잔여 인내심 (초)
var _conv_selected: int = -1                         # 선택된 슬롯 (-1 = 없음)
var _conv_feedback_slot: int = -1                    # 피드백 표시 중인 슬롯
var _conv_action_cooldown: float = 0.0               # 액션 후 짧은 대기
var _conv_served: int = 0                            # 처리 완료 손님 수 (성공+실패)
var _conv_good: int = 0                              # 성공 응대 수
# 패널 참조
var _conv_slot_panels: Array = []                    # 3개 Panel 노드
var _conv_slot_bars: Array = []                      # 3개 ProgressBar 노드
var _conv_slot_name_lbls: Array = []                 # 3개 이름 Label
var _conv_slot_text_lbls: Array = []                 # 3개 대사/상태 Label
var _conv_fill_styles: Array = []                    # 3개 ProgressBar fill StyleBox
var _conv_action_vb: VBoxContainer = null            # 액션 버튼 영역
var _conv_score_lbl: Label = null

# DELIVERY 상태
var _del_selected: Array = []
var _del_order_btns: Array = []
var _del_status_lbl: Label = null
var _del_confirm_btn: Button = null

# ── UI 참조 ───────────────────────────────────────────────────────
var _root_vb: VBoxContainer
var _header_lbl: Label
var _progress_lbl: Label
var _content_vb: VBoxContainer

# CARDS UI
var _scene_lbl: Label
var _choice_vb: VBoxContainer
var _feedback_lbl: Label

# ── 초기화 ───────────────────────────────────────────────────────
func _ready() -> void:
	_rng.randomize()
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_build_base_ui()
	visible = false
	set_process(false)

func _process(delta: float) -> void:
	match _mode:
		Mode.CONVENIENCE:
			if _conv_action_cooldown > 0.0:
				_conv_action_cooldown -= delta
				if _conv_action_cooldown <= 0.0:
					if _conv_feedback_slot >= 0:
						_conv_free_slot(_conv_feedback_slot)
						_conv_feedback_slot = -1
			else:
				for i in range(CONV_SLOTS):
					if _conv_slots[i] == null:
						continue
					if i == _conv_feedback_slot:
						continue
					_conv_slot_patience[i] -= delta
					_conv_refresh_bar(i)
					if _conv_slot_patience[i] <= 0.0:
						_conv_timeout(i)
						break  # avoid modifying array mid-iteration
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
	_del_selected = []
	_card_idx = 0
	_card_waiting = false
	_conv_served = 0
	_conv_good = 0
	_conv_selected = -1
	_conv_feedback_slot = -1
	_conv_action_cooldown = 0.0
	_conv_slots = [null, null, null]
	_conv_slot_patience = [0.0, 0.0, 0.0]
	_conv_queue = []

	var job_id: String = GameState.current_job.get("id", "")
	match job_id:
		"job_01": _mode = Mode.CONVENIENCE
		"job_02": _mode = Mode.DELIVERY
		_:        _mode = Mode.CARDS

	_clear_content()
	visible = true

	match _mode:
		Mode.CONVENIENCE:
			_header_lbl.text = "🏪 편의점 야간 시프트"
			_start_convenience()
		Mode.DELIVERY:
			_header_lbl.text = "🛵 배달 루트 설정"
			_start_delivery()
		Mode.CARDS:
			_header_lbl.text = "💼 알바 시프트"
			_start_cards()

func _clear_content() -> void:
	for ch in _content_vb.get_children():
		ch.queue_free()
	_conv_slot_panels = []
	_conv_slot_bars = []
	_conv_slot_name_lbls = []
	_conv_slot_text_lbls = []
	_conv_fill_styles = []
	_conv_action_vb = null
	_conv_score_lbl = null
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
# CONVENIENCE 모드 — 오버쿡 스타일 손님 응대 게임
# ══════════════════════════════════════════════════════════════════
func _start_convenience() -> void:
	# 손님 큐 준비 (CUSTOMER_TYPES를 가중치로 섞어 10명)
	var pool: Array = CUSTOMER_TYPES.duplicate()
	pool.shuffle()
	# 진상 손님은 1명 이하
	var angry_added := false
	for c in pool:
		if _conv_queue.size() >= CONV_TOTAL:
			break
		if c["name"] == "진상 손님":
			if angry_added:
				continue
			angry_added = true
		_conv_queue.append(c.duplicate(true))
	# 부족하면 일반 손님으로 채우기
	while _conv_queue.size() < CONV_TOTAL:
		_conv_queue.append(CUSTOMER_TYPES[0].duplicate(true))

	# fill StyleBox 3개 미리 생성
	for i in range(CONV_SLOTS):
		var fill := StyleBoxFlat.new()
		fill.bg_color = Color("#2a7a3a")
		_conv_fill_styles.append(fill)

	# 슬롯 패널 3개 생성
	var slots_vb := VBoxContainer.new()
	slots_vb.add_theme_constant_override("separation", 5)
	_content_vb.add_child(slots_vb)

	for i in range(CONV_SLOTS):
		var panel := Panel.new()
		panel.custom_minimum_size = Vector2(0, CONV_SLOT_H)
		panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var panel_st := StyleBoxFlat.new()
		panel_st.bg_color = Color("#0d1420")
		panel_st.set_corner_radius_all(6)
		panel.add_theme_stylebox_override("panel", panel_st)
		slots_vb.add_child(panel)
		_conv_slot_panels.append(panel)
		_conv_slot_bars.append(null)
		_conv_slot_name_lbls.append(null)
		_conv_slot_text_lbls.append(null)

		# 패널 클릭 핸들러 (1회 연결)
		var cap_i: int = i
		panel.gui_input.connect(func(event: InputEvent):
			if event is InputEventMouseButton:
				var mb := event as InputEventMouseButton
				if mb.button_index == MOUSE_BUTTON_LEFT and mb.pressed:
					_conv_click_slot(cap_i))

	# 점수 라벨
	_conv_score_lbl = Label.new()
	_conv_score_lbl.add_theme_font_size_override("font_size", 12)
	_conv_score_lbl.add_theme_color_override("font_color", Color("#5a8a6a"))
	_content_vb.add_child(_conv_score_lbl)

	# 액션 영역 (클릭 시 동적 버튼 표시)
	var action_sep := HSeparator.new()
	action_sep.add_theme_color_override("color", Color("#1a2030"))
	_content_vb.add_child(action_sep)

	_conv_action_vb = VBoxContainer.new()
	_conv_action_vb.add_theme_constant_override("separation", 6)
	_conv_action_vb.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_content_vb.add_child(_conv_action_vb)

	var hint := Label.new()
	hint.text = "↑ 손님 패널을 클릭해서 응대하세요"
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint.add_theme_font_size_override("font_size", 11)
	hint.add_theme_color_override("font_color", Color("#3a4a5a"))
	_conv_action_vb.add_child(hint)

	_conv_update_score_lbl()
	set_process(true)

	# 첫 손님 3명 즉시 등장
	for i in range(CONV_SLOTS):
		_conv_spawn_into(i)

func _conv_spawn_into(slot_idx: int) -> void:
	if _conv_queue.is_empty():
		return
	var customer: Dictionary = _conv_queue.pop_front()
	_conv_slots[slot_idx] = customer
	_conv_slot_patience[slot_idx] = float(customer.get("patience", 10.0))
	_conv_build_slot_content(slot_idx)

func _conv_build_slot_content(slot_idx: int) -> void:
	var panel: Panel = _conv_slot_panels[slot_idx]
	# 기존 콘텐츠 제거
	for ch in panel.get_children():
		ch.queue_free()

	var customer: Dictionary = _conv_slots[slot_idx]
	if customer == null:
		return

	# 패널 스타일 리셋 (선택 해제)
	var st := StyleBoxFlat.new()
	st.bg_color = Color("#0d1420")
	st.set_corner_radius_all(6)
	panel.add_theme_stylebox_override("panel", st)

	var margin := MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 10)
	margin.add_theme_constant_override("margin_right", 8)
	margin.add_theme_constant_override("margin_top", 7)
	margin.add_theme_constant_override("margin_bottom", 7)
	margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_child(margin)

	var hb := HBoxContainer.new()
	hb.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hb.add_theme_constant_override("separation", 8)
	margin.add_child(hb)

	# 이모지 + 이름
	var info_vb := VBoxContainer.new()
	info_vb.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	info_vb.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hb.add_child(info_vb)

	var name_lbl := Label.new()
	name_lbl.text = "%s  %s" % [customer.get("emoji", "👤"), customer.get("name", "손님")]
	name_lbl.add_theme_font_size_override("font_size", 13)
	name_lbl.add_theme_color_override("font_color", Color("#dde8f0"))
	name_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	info_vb.add_child(name_lbl)
	_conv_slot_name_lbls[slot_idx] = name_lbl

	var text_lbl := Label.new()
	text_lbl.text = "\"%s\"" % customer.get("text", "")
	text_lbl.add_theme_font_size_override("font_size", 11)
	text_lbl.add_theme_color_override("font_color", Color("#5a7a8a"))
	text_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	text_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	info_vb.add_child(text_lbl)
	_conv_slot_text_lbls[slot_idx] = text_lbl

	# 인내심 바 + 긴급도
	var bar_vb := VBoxContainer.new()
	bar_vb.custom_minimum_size = Vector2(72, 0)
	bar_vb.alignment = BoxContainer.ALIGNMENT_CENTER
	bar_vb.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hb.add_child(bar_vb)

	var bar := ProgressBar.new()
	bar.min_value = 0
	bar.max_value = 100
	bar.value = 100
	bar.show_percentage = false
	bar.custom_minimum_size = Vector2(72, 10)
	bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	bar.add_theme_stylebox_override("fill", _conv_fill_styles[slot_idx])
	bar_vb.add_child(bar)
	_conv_slot_bars[slot_idx] = bar

	var urg: int = int(customer.get("urgency", 1))
	var urg_lbl := Label.new()
	urg_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	urg_lbl.add_theme_font_size_override("font_size", 10)
	urg_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	match urg:
		0:
			urg_lbl.text = "느긋"
			urg_lbl.add_theme_color_override("font_color", Color("#5a9a5a"))
		1:
			urg_lbl.text = "보통"
			urg_lbl.add_theme_color_override("font_color", Color("#6a8a9a"))
		2:
			urg_lbl.text = "급함"
			urg_lbl.add_theme_color_override("font_color", Color("#c8a020"))
		_:
			urg_lbl.text = "긴급!"
			urg_lbl.add_theme_color_override("font_color", Color("#e85d5d"))
	bar_vb.add_child(urg_lbl)

func _conv_clear_slot_panel(slot_idx: int) -> void:
	var panel: Panel = _conv_slot_panels[slot_idx]
	for ch in panel.get_children():
		ch.queue_free()
	_conv_slot_bars[slot_idx] = null
	_conv_slot_name_lbls[slot_idx] = null
	_conv_slot_text_lbls[slot_idx] = null
	# 빈 슬롯 스타일
	var st := StyleBoxFlat.new()
	st.bg_color = Color("#080e18")
	st.set_corner_radius_all(6)
	st.border_color = Color("#1a2030")
	st.set_border_width_all(1)
	panel.add_theme_stylebox_override("panel", st)

func _conv_refresh_bar(slot_idx: int) -> void:
	var bar: ProgressBar = _conv_slot_bars[slot_idx]
	if not is_instance_valid(bar) or _conv_slots[slot_idx] == null:
		return
	var max_p: float = float(_conv_slots[slot_idx].get("patience", 10.0))
	var ratio: float = clampf(_conv_slot_patience[slot_idx] / max_p, 0.0, 1.0)
	bar.value = ratio * 100.0
	var fill: StyleBoxFlat = _conv_fill_styles[slot_idx]
	if ratio > 0.5:
		fill.bg_color = Color("#2a7a3a")
	elif ratio > 0.25:
		fill.bg_color = Color("#c8a020")
	else:
		fill.bg_color = Color("#c83030")

func _conv_click_slot(slot_idx: int) -> void:
	if _conv_slots[slot_idx] == null:
		return
	if slot_idx == _conv_feedback_slot:
		return
	if _conv_action_cooldown > 0.0:
		return

	_conv_selected = slot_idx
	_conv_highlight_selected()
	_conv_show_actions(slot_idx)
	AudioManager.play("click")

func _conv_highlight_selected() -> void:
	for i in range(CONV_SLOTS):
		if _conv_slots[i] == null:
			continue
		var panel: Panel = _conv_slot_panels[i]
		var st := StyleBoxFlat.new()
		if i == _conv_selected:
			st.bg_color = Color("#0d2040")
			st.set_corner_radius_all(6)
			st.border_color = Color("#3a6aaa")
			st.set_border_width_all(2)
		else:
			st.bg_color = Color("#0d1420")
			st.set_corner_radius_all(6)
		panel.add_theme_stylebox_override("panel", st)

func _conv_show_actions(slot_idx: int) -> void:
	for ch in _conv_action_vb.get_children():
		ch.queue_free()

	var customer: Dictionary = _conv_slots[slot_idx]
	var who_lbl := Label.new()
	who_lbl.text = "%s %s 응대:" % [customer.get("emoji", ""), customer.get("name", "")]
	who_lbl.add_theme_font_size_override("font_size", 12)
	who_lbl.add_theme_color_override("font_color", Color("#a0b8c0"))
	_conv_action_vb.add_child(who_lbl)

	var actions: Array = customer.get("actions", [])
	for ai in range(actions.size()):
		var action: Dictionary = actions[ai]
		var btn := _make_btn(action["text"], "#0e1a2e", 13)
		btn.custom_minimum_size = Vector2(0, 38)
		var cap_slot: int = slot_idx
		var cap_ai: int = ai
		btn.pressed.connect(func(): _conv_handle(cap_slot, cap_ai))
		_conv_action_vb.add_child(btn)

func _conv_handle(slot_idx: int, action_idx: int) -> void:
	if _conv_slots[slot_idx] == null or _conv_feedback_slot == slot_idx:
		return

	var customer: Dictionary = _conv_slots[slot_idx]
	var action: Dictionary = customer["actions"][action_idx]

	var bonus: int = int(action.get("bonus", 0))
	_earned += bonus
	_stress_delta += int(action.get("stress", 0))
	if bonus > 0:
		_conv_good += 1
		AudioManager.play("money_gain")
	elif bonus < 0:
		AudioManager.play("money_loss")
	else:
		_conv_good += 1
		AudioManager.play("click")

	# 슬롯에 결과 텍스트 잠깐 표시
	var text_lbl: Label = _conv_slot_text_lbls[slot_idx]
	if is_instance_valid(text_lbl):
		text_lbl.text = "→ " + str(action.get("tip", "처리 완료"))
		text_lbl.add_theme_color_override("font_color", Color("#3dba6a") if bonus >= 0 else Color("#e85d5d"))
	var name_lbl: Label = _conv_slot_name_lbls[slot_idx]
	if is_instance_valid(name_lbl):
		name_lbl.text = "✓ " + str(customer.get("name", ""))

	# 액션 영역 지우기
	for ch in _conv_action_vb.get_children():
		ch.queue_free()
	_conv_selected = -1
	_conv_highlight_selected()

	_conv_served += 1
	_conv_feedback_slot = slot_idx
	_conv_action_cooldown = 0.7
	_conv_update_score_lbl()

func _conv_timeout(slot_idx: int) -> void:
	if _conv_slots[slot_idx] == null:
		return
	var customer: Dictionary = _conv_slots[slot_idx]
	var urgency: int = int(customer.get("urgency", 1))
	_stress_delta += CONV_TIMEOUT_STRESS + (1 if urgency >= 3 else 0)

	var text_lbl: Label = _conv_slot_text_lbls[slot_idx]
	if is_instance_valid(text_lbl):
		text_lbl.text = "😠 참다가 나가버렸다"
		text_lbl.add_theme_color_override("font_color", Color("#e85d5d"))
	var name_lbl: Label = _conv_slot_name_lbls[slot_idx]
	if is_instance_valid(name_lbl):
		name_lbl.text = "✗ " + str(customer.get("name", ""))

	if _conv_selected == slot_idx:
		_conv_selected = -1
		_conv_highlight_selected()
		for ch in _conv_action_vb.get_children():
			ch.queue_free()

	_conv_served += 1
	_conv_feedback_slot = slot_idx
	_conv_action_cooldown = 0.5
	AudioManager.play("money_loss")
	_conv_update_score_lbl()

func _conv_free_slot(slot_idx: int) -> void:
	_conv_slots[slot_idx] = null
	_conv_slot_patience[slot_idx] = 0.0
	_conv_clear_slot_panel(slot_idx)

	# 종료 조건: 모든 손님 처리 완료
	var all_done: bool = _conv_queue.is_empty()
	if all_done:
		for i in range(CONV_SLOTS):
			if _conv_slots[i] != null:
				all_done = false
				break
	if all_done:
		_show_result()
		return

	# 다음 손님 즉시 투입
	_conv_spawn_into(slot_idx)
	_conv_update_score_lbl()

func _conv_update_score_lbl() -> void:
	if not is_instance_valid(_conv_score_lbl):
		return
	var remaining: int = _conv_queue.size() + (CONV_TOTAL - _conv_served - _conv_queue.size())
	remaining = CONV_TOTAL - _conv_served
	_conv_score_lbl.text = "처리: %d / %d  |  남은 손님: %d명" % [
		_conv_served, CONV_TOTAL,
		_conv_queue.size() + _conv_slots.filter(func(s): return s != null).size()]

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
	_stress_delta += maxi(delivery_count - 2, 0)
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
		Mode.CONVENIENCE:
			finish_lbl.text = "시프트 종료  %d / %d명 응대 성공" % [_conv_good, CONV_TOTAL]
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
