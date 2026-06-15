extends Control
## LifeSkillsMiniGame — 절약·인맥·자기계발 인터랙티브 미니게임
## Mode.BUDGET:  지출 절약 퍼즐 — 항목 토글 후 확인
## Mode.NETWORK: 속성 인맥 카드 — NPC 3인 순차 대화 (10초 타이머)
## Mode.STUDY:   자기계발 플래시카드 — 주제 선택 후 3문 퀴즈 (8초 타이머)

signal closed(quality: int, extra_money: int)

enum Mode { BUDGET, NETWORK, STUDY }

# ── 절약 항목 ─────────────────────────────────────────────────────
const BUDGET_ITEMS: Array = [
	{"label": "🍱 식비 절약 (편의점 도시락)", "save": 80000,
	 "fx": {"health": -5}},
	{"label": "☕ 카페·술 자제", "save": 60000,
	 "fx": {"stress": 3}},
	{"label": "🎬 문화생활 취소", "save": 50000,
	 "fx": {"mental": -5}},
	{"label": "🚌 대중교통 전환 (승용차 반납)", "save": 40000,
	 "fx": {"social_skill": -1}},
	{"label": "📱 통신비 요금제 변경", "save": 25000,
	 "fx": {}},
	{"label": "📺 구독서비스·OTT 해지", "save": 40000,
	 "fx": {"intelligence": -2}},
]
const BUDGET_TARGET: int = 200000

# ── 인맥 NPC 풀 ──────────────────────────────────────────────────
const NETWORK_NPCS: Array = [
	{
		"name": "김 사장", "job": "부동산 공인중개사",
		"personality": "열정형",
		"desc": "카페에서 우연히 대화가 시작됐다.",
		"choices": [
			{"text": "\"요즘 강남 분위기 어떤가요?\"", "score": 3},
			{"text": "\"나중에 연락드릴게요.\"", "score": 1},
			{"text": "명함을 받고 슬쩍 가방에 넣는다", "score": 0},
		]
	},
	{
		"name": "이진수", "job": "스타트업 대표",
		"personality": "분석형",
		"desc": "스터디 모임에서 처음 만났다.",
		"choices": [
			{"text": "사업 계획을 경청하며 질문을 건넨다", "score": 3},
			{"text": "\"투자자는 어떻게 만나셨어요?\"", "score": 2},
			{"text": "스마트폰을 보며 듣는 척 한다", "score": 0},
		]
	},
	{
		"name": "박 과장", "job": "대기업 5년차 선배",
		"personality": "경쟁형",
		"desc": "동창회에서 10년 만에 만났다.",
		"choices": [
			{"text": "서로의 근황을 나누며 명함을 교환한다", "score": 3},
			{"text": "내 이력을 어필한다", "score": 1},
			{"text": "어색해서 화장실에 다녀온다", "score": 0},
		]
	},
	{
		"name": "최민아", "job": "재테크 동호회원",
		"personality": "친화형",
		"desc": "독서 모임 옆자리에서 대화가 시작됐다.",
		"choices": [
			{"text": "최근 읽은 재테크 책 이야기를 나눈다", "score": 3},
			{"text": "연락처를 자연스럽게 받는다", "score": 2},
			{"text": "관심 없는 척 먼저 자리를 뜬다", "score": 0},
		]
	},
	{
		"name": "정현호", "job": "프리랜서 개발자",
		"personality": "분석형",
		"desc": "공유오피스 카페테리아에서 우연히 마주쳤다.",
		"choices": [
			{"text": "프로젝트 경험을 함께 논의한다", "score": 3},
			{"text": "\"부업으로 얼마나 버세요?\"", "score": 1},
			{"text": "바쁜 척 노트북만 본다", "score": 0},
		]
	},
]
const NETWORK_TIMER: float = 15.0
const NETWORK_COUNT: int = 3

# ── 자기계발 퀴즈 ─────────────────────────────────────────────────
const STUDY_TOPICS: Array = [
	{"id": "read",     "label": "📖 독서",       "color": "#5b9cf6",
	 "stat": "intelligence",    "gain": 4},
	{"id": "exercise", "label": "🏃 운동",       "color": "#f59e0b",
	 "stat": "health",          "gain": 10},
	{"id": "meditate", "label": "🧘 명상",       "color": "#8b5cf6",
	 "stat": "mental",          "gain": 18},
	{"id": "invest",   "label": "📊 재테크 공부", "color": "#10b981",
	 "stat": "investment_skill","gain": 3},
]
const STUDY_QUESTIONS: Dictionary = {
	"read": [
		{"q": "책의 핵심 내용을 기억하는 가장 효과적인 방법은?",
		 "choices": [
			 {"text": "읽은 후 요점을 노트에 직접 써본다", "score": 3},
			 {"text": "밑줄을 많이 그어 표시해둔다", "score": 1},
			 {"text": "반복해서 빠르게 훑어 읽는다", "score": 0},
		 ]},
		{"q": "비문학 책 독해에서 가장 중요한 습관은?",
		 "choices": [
			 {"text": "챕터마다 스스로에게 질문을 던지며 읽는다", "score": 3},
			 {"text": "모르는 단어를 모두 사전에서 찾는다", "score": 1},
			 {"text": "처음부터 끝까지 쉬지 않고 읽는다", "score": 0},
		 ]},
		{"q": "독서를 장기 습관으로 만드는 핵심 전략은?",
		 "choices": [
			 {"text": "매일 정해진 시간에 20분씩 꾸준히 읽는다", "score": 3},
			 {"text": "하루에 100페이지 목표를 잡는다", "score": 1},
			 {"text": "기분이 좋을 때만 읽는다", "score": 0},
		 ]},
		{"q": "논픽션 책을 읽기 전 가장 효율적인 준비 방법은?",
		 "choices": [
			 {"text": "목차를 먼저 훑고 핵심 질문을 미리 떠올린다", "score": 3},
			 {"text": "서문부터 천천히 읽기 시작한다", "score": 1},
			 {"text": "아무 준비 없이 바로 읽는다", "score": 0},
		 ]},
		{"q": "읽은 책의 내용을 실생활에 적용하는 가장 좋은 방법은?",
		 "choices": [
			 {"text": "핵심 아이디어 하나를 골라 즉시 작은 행동으로 실천한다", "score": 3},
			 {"text": "책 전체를 다시 한 번 읽는다", "score": 1},
			 {"text": "다음 책을 바로 읽는다", "score": 0},
		 ]},
		{"q": "독서 속도를 높이면서도 이해도를 유지하는 방법은?",
		 "choices": [
			 {"text": "핵심 문장과 주변부 내용을 구별해 속독·정독을 병행한다", "score": 3},
			 {"text": "무조건 빠르게 읽는 연습을 반복한다", "score": 1},
			 {"text": "한 글자씩 소리 내어 읽는다", "score": 0},
		 ]},
	],
	"exercise": [
		{"q": "운동 후 근육 회복에 가장 중요한 것은?",
		 "choices": [
			 {"text": "충분한 수면과 단백질 섭취", "score": 3},
			 {"text": "냉탕·온탕을 교대로 한다", "score": 1},
			 {"text": "바로 다음 날 더 강하게 운동한다", "score": 0},
		 ]},
		{"q": "지방 연소에 효과적인 유산소 심박수 구간은?",
		 "choices": [
			 {"text": "최대 심박수의 60~80% (지방 연소 구간)", "score": 3},
			 {"text": "최대 심박수의 90% 이상 (고강도)", "score": 1},
			 {"text": "심박수는 중요하지 않다", "score": 0},
		 ]},
		{"q": "워밍업이 중요한 이유는?",
		 "choices": [
			 {"text": "근육과 관절에 혈류를 공급해 부상을 예방한다", "score": 3},
			 {"text": "운동 의지를 높이는 심리적 효과", "score": 1},
			 {"text": "칼로리를 미리 소모해 효율을 높인다", "score": 0},
		 ]},
		{"q": "근력 운동 시 '점진적 과부하' 원칙이란?",
		 "choices": [
			 {"text": "시간이 지남에 따라 무게·횟수·강도를 점차 늘린다", "score": 3},
			 {"text": "매번 동일한 무게로 안정적으로 운동한다", "score": 1},
			 {"text": "첫날부터 최대 무게로 시작해 익숙해진다", "score": 0},
		 ]},
		{"q": "공복 유산소 운동의 실제 효과는?",
		 "choices": [
			 {"text": "지방 산화가 소폭 증가하나 총 칼로리 소모는 비슷하다", "score": 3},
			 {"text": "지방이 2배 이상 빠르게 연소된다", "score": 0},
			 {"text": "근육 손실이 일어나 역효과다", "score": 1},
		 ]},
		{"q": "운동 직후 단백질 섭취의 이상적인 타이밍은?",
		 "choices": [
			 {"text": "운동 후 30분~2시간 이내 (골든타임)", "score": 3},
			 {"text": "운동 전날 저녁에 미리 충분히 섭취한다", "score": 1},
			 {"text": "타이밍보다 총 하루 섭취량이 중요하다", "score": 2},
		 ]},
	],
	"meditate": [
		{"q": "마음 챙김 명상의 핵심 원리는?",
		 "choices": [
			 {"text": "현재 순간을 판단 없이 관찰한다", "score": 3},
			 {"text": "과거를 반성하고 미래를 계획한다", "score": 1},
			 {"text": "잡념이 생기면 즉시 억누른다", "score": 0},
		 ]},
		{"q": "스트레스 해소에 효과적인 호흡법은?",
		 "choices": [
			 {"text": "4초 흡기, 7초 참기, 8초 호기 (4-7-8 호흡법)", "score": 3},
			 {"text": "코로 빠르게 들이쉬고 입으로 내쉰다", "score": 1},
			 {"text": "가능한 한 빠르게 10번 심호흡한다", "score": 0},
		 ]},
		{"q": "명상의 과학적으로 입증된 효과는?",
		 "choices": [
			 {"text": "코르티솔(스트레스 호르몬) 수치를 낮춘다", "score": 3},
			 {"text": "수면을 줄여도 집중력을 유지시킨다", "score": 0},
			 {"text": "뇌를 완전히 비워 에너지를 보충한다", "score": 1},
		 ]},
		{"q": "명상 중 잡념이 떠올랐을 때 올바른 대처법은?",
		 "choices": [
			 {"text": "잡념을 알아채고 부드럽게 호흡으로 주의를 되돌린다", "score": 3},
			 {"text": "잡념을 강하게 밀쳐내고 집중에 집착한다", "score": 0},
			 {"text": "명상을 중단하고 다시 시작한다", "score": 1},
		 ]},
		{"q": "MBSR(마음 챙김 기반 스트레스 감소) 프로그램의 핵심은?",
		 "choices": [
			 {"text": "8주간 신체 감각·감정·생각을 비판단적으로 관찰하는 훈련", "score": 3},
			 {"text": "긍정적인 생각만 반복하는 확언 기법", "score": 0},
			 {"text": "수면 시간을 늘려 뇌를 휴식시키는 것", "score": 1},
		 ]},
		{"q": "일상 속 '비공식 명상' 실천 방법으로 가장 적절한 것은?",
		 "choices": [
			 {"text": "설거지나 걷기 등 단순 작업 중 현재 감각에 집중한다", "score": 3},
			 {"text": "출퇴근 시 팟캐스트를 들으며 스트레스를 해소한다", "score": 1},
			 {"text": "하루 1시간 공식 명상만이 효과가 있다", "score": 0},
		 ]},
	],
	"invest": [
		{"q": "분산 투자의 핵심 목적은?",
		 "choices": [
			 {"text": "개별 자산의 변동성 위험을 줄인다", "score": 3},
			 {"text": "세금을 합법적으로 줄인다", "score": 1},
			 {"text": "한 번에 최대 수익을 올린다", "score": 0},
		 ]},
		{"q": "복리(compound interest)의 핵심 원리는?",
		 "choices": [
			 {"text": "이자에도 이자가 붙어 시간이 지날수록 가속 성장한다", "score": 3},
			 {"text": "원금이 두 배가 되면 이자율도 두 배가 된다", "score": 0},
			 {"text": "투자 금액이 클수록 이자율이 높아진다", "score": 1},
		 ]},
		{"q": "PER(주가수익비율)이 낮을 때 일반적으로 의미하는 것은?",
		 "choices": [
			 {"text": "주가가 이익 대비 저평가되어 있을 가능성", "score": 3},
			 {"text": "배당금이 높다는 지표", "score": 1},
			 {"text": "회사의 성장성이 매우 높다는 신호", "score": 0},
		 ]},
		{"q": "인플레이션이 투자에 미치는 영향은?",
		 "choices": [
			 {"text": "현금의 실질 구매력이 감소하므로 자산 투자가 유리해진다", "score": 3},
			 {"text": "모든 투자 자산의 가치가 동일하게 하락한다", "score": 0},
			 {"text": "주식시장은 항상 인플레이션보다 높은 수익을 낸다", "score": 1},
		 ]},
		{"q": "부동산 투자 시 '레버리지'의 의미는?",
		 "choices": [
			 {"text": "대출을 이용해 자기 자본 대비 더 큰 자산을 운용한다", "score": 3},
			 {"text": "여러 부동산을 동시에 매수해 위험을 분산한다", "score": 1},
			 {"text": "시세보다 낮은 가격에 급매물을 잡는 전략", "score": 0},
		 ]},
		{"q": "72의 법칙(Rule of 72)이란?",
		 "choices": [
			 {"text": "72를 연이율로 나누면 원금이 두 배 되는 기간(년)이 나온다", "score": 3},
			 {"text": "72개월(6년) 이상 보유하면 수익이 보장된다는 규칙", "score": 0},
			 {"text": "포트폴리오를 72종목으로 분산해야 한다는 원칙", "score": 1},
		 ]},
	],
}
const STUDY_TIMER: float = 8.0
const STUDY_QUESTIONS_PER_SESSION: int = 3  # 풀에서 랜덤으로 선택할 문항 수

# ── 상태 ─────────────────────────────────────────────────────────
var current_mode: Mode = Mode.BUDGET
var _mode: Mode = Mode.BUDGET

# BUDGET
var _budget_selected: Array = [false, false, false, false, false, false]
var _budget_total_lbl: Label
var _budget_panels: Array = []

# NETWORK
var _net_score: int = 0
var _net_idx: int = 0
var _net_npcs: Array = []

# STUDY
var _study_topic: Dictionary = {}
var _study_qs: Array = []
var _study_idx: int = 0
var _study_score: int = 0

# 공통 타이머
var _timer_left: float = 0.0
var _timer_max: float = 10.0
var _timer_active: bool = false
var _timer_bar: ProgressBar
var _timer_style: StyleBoxFlat

# UI
var _root_vb: VBoxContainer
var _header_lbl: Label
var _progress_lbl: Label
var _content_vb: VBoxContainer
var _feedback_lbl: Label

# ── 초기화 ───────────────────────────────────────────────────────
func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_build_base_ui()
	visible = false
	set_process(false)

func _process(delta: float) -> void:
	if not _timer_active:
		return
	_timer_left -= delta
	if is_instance_valid(_timer_bar):
		var ratio: float = maxf(_timer_left / _timer_max, 0.0)
		_timer_bar.value = ratio * 100.0
		if is_instance_valid(_timer_style):
			if ratio > 0.6:
				_timer_style.bg_color = Color("#2a7a3a")
			elif ratio > 0.3:
				_timer_style.bg_color = Color("#c8a020")
			else:
				_timer_style.bg_color = Color("#c83030")
	if _timer_left <= 0.0:
		_timer_active = false
		_on_timeout()

# ── 진입 ─────────────────────────────────────────────────────────
func open(mode: Mode) -> void:
	_mode = mode
	current_mode = mode
	_timer_active = false
	_clear_content()
	visible = true
	set_process(true)

	match _mode:
		Mode.BUDGET:
			_header_lbl.text = "💰 이번달 허리띠 조르기"
			_budget_selected = [false, false, false, false, false, false]
			_budget_panels = []
			_budget_total_lbl = null
			_build_budget_ui()
		Mode.NETWORK:
			_header_lbl.text = "🤝 인맥 넓히기"
			_net_score = 0
			_net_idx = 0
			_net_npcs = NETWORK_NPCS.duplicate()
			_net_npcs.shuffle()
			_net_npcs = _net_npcs.slice(0, NETWORK_COUNT)
			_show_npc()
		Mode.STUDY:
			_header_lbl.text = "📚 자기계발"
			_study_topic = {}
			_study_qs = []
			_study_idx = 0
			_study_score = 0
			_progress_lbl.text = ""
			_build_study_topic_ui()

# ── 공통 UI 빌더 ─────────────────────────────────────────────────
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
	_header_lbl.add_theme_font_size_override("font_size", 17)
	_header_lbl.add_theme_color_override("font_color", Color("#5b9cf6"))
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

func _clear_content() -> void:
	for ch in _content_vb.get_children():
		ch.queue_free()
	_timer_bar = null
	_timer_style = null
	_feedback_lbl = null
	_budget_total_lbl = null
	_budget_panels = []

func _make_timer_bar() -> void:
	_timer_bar = ProgressBar.new()
	_timer_bar.min_value = 0
	_timer_bar.max_value = 100
	_timer_bar.value = 100
	_timer_bar.show_percentage = false
	_timer_bar.custom_minimum_size = Vector2(0, 8)
	_timer_style = StyleBoxFlat.new()
	_timer_style.bg_color = Color("#2a7a3a")
	_timer_bar.add_theme_stylebox_override("fill", _timer_style)
	_content_vb.add_child(_timer_bar)

func _make_label(text: String, size: int = 13, color: String = "#c8cfe0",
		autowrap: bool = false) -> Label:
	var lbl := Label.new()
	lbl.text = text
	lbl.add_theme_font_size_override("font_size", size)
	lbl.add_theme_color_override("font_color", Color(color))
	if autowrap:
		lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	return lbl

func _make_button(text: String, color: String = "#2a3a5a") -> Button:
	var btn := Button.new()
	btn.text = text
	btn.add_theme_font_size_override("font_size", 13)
	btn.add_theme_color_override("font_color", Color("#d0d8f0"))
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(color)
	sb.corner_radius_top_left = 6; sb.corner_radius_top_right = 6
	sb.corner_radius_bottom_left = 6; sb.corner_radius_bottom_right = 6
	btn.add_theme_stylebox_override("normal", sb)
	var sb_hov := sb.duplicate() as StyleBoxFlat
	sb_hov.bg_color = Color(color).lightened(0.15)
	btn.add_theme_stylebox_override("hover", sb_hov)
	btn.custom_minimum_size = Vector2(0, 38)
	return btn

# ── BUDGET 모드 ───────────────────────────────────────────────────
func _build_budget_ui() -> void:
	_content_vb.add_child(_make_label(
		"줄일 수 있는 지출을 골라보세요.\n단, 일부 항목은 생활에 영향이 있습니다.",
		12, "#5a7a9a", true))

	var sub := _make_label("목표: %s 이상 절약" % _fmt(BUDGET_TARGET), 12, "#3a8a5a")
	_content_vb.add_child(sub)

	var sep := HSeparator.new()
	sep.add_theme_color_override("color", Color("#1a2030"))
	_content_vb.add_child(sep)

	for i in BUDGET_ITEMS.size():
		var item: Dictionary = BUDGET_ITEMS[i]
		var p := PanelContainer.new()
		var sb := StyleBoxFlat.new()
		sb.bg_color = Color("#0d1525")
		sb.corner_radius_top_left = 6; sb.corner_radius_top_right = 6
		sb.corner_radius_bottom_left = 6; sb.corner_radius_bottom_right = 6
		sb.border_color = Color("#1e2a3a")
		sb.border_width_top = 1; sb.border_width_bottom = 1
		sb.border_width_left = 1; sb.border_width_right = 1
		p.add_theme_stylebox_override("panel", sb)
		p.mouse_filter = Control.MOUSE_FILTER_STOP
		_budget_panels.append(p)

		var row := HBoxContainer.new()
		row.mouse_filter = Control.MOUSE_FILTER_IGNORE
		row.add_theme_constant_override("separation", 8)
		p.add_child(row)

		var lbl := _make_label(item["label"], 13, "#c8cfe0")
		lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
		row.add_child(lbl)

		# 절약금액
		var save_lbl := _make_label("+" + _fmt(item["save"]), 13, "#2db56a")
		save_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
		row.add_child(save_lbl)

		# 패널티 표시
		var fx: Dictionary = item.get("fx", {})
		var pen_text: String = ""
		for k in fx:
			var v: int = int(fx[k])
			pen_text += " %s%d" % ["/" if v < 0 else "/+", v]
		if not pen_text.is_empty():
			var pen_lbl := _make_label(pen_text.strip_edges(), 11, "#c86060")
			pen_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
			row.add_child(pen_lbl)

		var idx_capture := i
		p.gui_input.connect(func(ev: InputEvent) -> void:
			if ev is InputEventMouseButton and ev.pressed and ev.button_index == MOUSE_BUTTON_LEFT:
				_toggle_budget(idx_capture))
		_content_vb.add_child(p)

	# 합계 + 확인 버튼
	var bot := HBoxContainer.new()
	bot.add_theme_constant_override("separation", 12)
	_content_vb.add_child(bot)

	_budget_total_lbl = _make_label("총 절약: 0원 / 목표 %s" % _fmt(BUDGET_TARGET), 13, "#5a8abf")
	_budget_total_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bot.add_child(_budget_total_lbl)

	var confirm := _make_button("이번주 생활하기", "#1a4a7a")
	confirm.custom_minimum_size = Vector2(140, 38)
	confirm.pressed.connect(_on_budget_confirm)
	bot.add_child(confirm)

func _toggle_budget(idx: int) -> void:
	_budget_selected[idx] = not _budget_selected[idx]
	var p: PanelContainer = _budget_panels[idx]
	var sb := StyleBoxFlat.new()
	if _budget_selected[idx]:
		sb.bg_color = Color("#112a18")
		sb.border_color = Color("#2a7a3a")
	else:
		sb.bg_color = Color("#0d1525")
		sb.border_color = Color("#1e2a3a")
	sb.corner_radius_top_left = 6; sb.corner_radius_top_right = 6
	sb.corner_radius_bottom_left = 6; sb.corner_radius_bottom_right = 6
	sb.border_width_top = 1; sb.border_width_bottom = 1
	sb.border_width_left = 1; sb.border_width_right = 1
	p.add_theme_stylebox_override("panel", sb)

	# 합계 갱신
	var total: int = 0
	for i in _budget_selected.size():
		if _budget_selected[i]:
			total += int(BUDGET_ITEMS[i]["save"])
	if is_instance_valid(_budget_total_lbl):
		var c: String = "#2db56a" if total >= BUDGET_TARGET else "#5a8abf"
		_budget_total_lbl.text = "총 절약: %s / 목표 %s" % [_fmt(total), _fmt(BUDGET_TARGET)]
		_budget_total_lbl.add_theme_color_override("font_color", Color(c))

func _on_budget_confirm() -> void:
	var total: int = 0
	var penalty_fx: Dictionary = {}
	for i in _budget_selected.size():
		if _budget_selected[i]:
			total += int(BUDGET_ITEMS[i]["save"])
			var fx: Dictionary = BUDGET_ITEMS[i].get("fx", {})
			for k in fx:
				penalty_fx[k] = int(penalty_fx.get(k, 0)) + int(fx[k])

	# 패널티 적용
	for k in penalty_fx:
		var val: int = int(penalty_fx[k])
		match k:
			"stress":
				GameState.modify_hidden_stat("stress", val)
			"mental":
				GameState.modify_hidden_stat("mental", val)
			_:
				GameState.modify_stat(k, val)

	var quality: int
	if total >= 250000:
		quality = 3
	elif total >= BUDGET_TARGET:
		quality = 2
	elif total >= 100000:
		quality = 1
	else:
		quality = 0
	_finish(quality, total)

# ── NETWORK 모드 ──────────────────────────────────────────────────
func _show_npc() -> void:
	_timer_active = false
	_clear_content()

	if _net_idx >= NETWORK_COUNT:
		_show_network_result()
		return

	_progress_lbl.text = "%d / %d" % [_net_idx + 1, NETWORK_COUNT]

	var npc: Dictionary = _net_npcs[_net_idx]

	_make_timer_bar()

	# NPC 이름 + 직함
	var name_lbl := _make_label(npc["name"] + "  |  " + npc["job"], 15, "#e8eaf0")
	_content_vb.add_child(name_lbl)

	# 성격 뱃지
	var badge_lbl := _make_label("[ " + npc["personality"] + " ]", 11, "#8a6aa0")
	_content_vb.add_child(badge_lbl)

	# 상황 설명
	var desc_lbl := _make_label(npc["desc"], 12, "#5a7a9a", true)
	_content_vb.add_child(desc_lbl)

	var sep := HSeparator.new()
	sep.add_theme_color_override("color", Color("#1a2030"))
	_content_vb.add_child(sep)

	_feedback_lbl = _make_label("", 12, "#3dba6a", true)
	_content_vb.add_child(_feedback_lbl)

	var choices: Array = npc["choices"]
	for c in choices:
		var btn := _make_button(str(c["text"]))
		btn.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		btn.custom_minimum_size = Vector2(0, 44)
		btn.pressed.connect(Callable(self, "_on_network_choice").bind(int(c["score"])))
		_content_vb.add_child(btn)

	_timer_left = NETWORK_TIMER
	_timer_max = NETWORK_TIMER
	_timer_active = true

func _on_network_choice(score: int) -> void:
	if not _timer_active:
		return
	_timer_active = false
	_net_score += score
	# 버튼 비활성화
	for ch in _content_vb.get_children():
		if ch is Button:
			ch.disabled = true
	if is_instance_valid(_feedback_lbl):
		if score == 3:
			_feedback_lbl.text = "✓ 좋은 인상을 남겼다."
			_feedback_lbl.add_theme_color_override("font_color", Color("#3dba6a"))
		elif score >= 1:
			_feedback_lbl.text = "— 무난하게 대화를 마쳤다."
			_feedback_lbl.add_theme_color_override("font_color", Color("#a0a8c0"))
		else:
			_feedback_lbl.text = "✗ 어색하게 헤어졌다."
			_feedback_lbl.add_theme_color_override("font_color", Color("#c86060"))
	_net_idx += 1
	await get_tree().create_timer(1.0).timeout
	_show_npc()

func _show_network_result() -> void:
	_progress_lbl.text = "완료"
	_content_vb.add_child(_make_label("── 오늘의 만남 결과 ──", 14, "#5b9cf6"))

	var quality: int
	if _net_score >= 9:
		quality = 3
		_content_vb.add_child(_make_label("훌륭했습니다! 세 사람 모두 연락을 기대하고 있다.", 13, "#3dba6a", true))
	elif _net_score >= 6:
		quality = 2
		_content_vb.add_child(_make_label("좋은 인상을 남겼습니다.", 13, "#a8c8f0", true))
	elif _net_score >= 3:
		quality = 1
		_content_vb.add_child(_make_label("평범한 만남이었습니다.", 13, "#a0a8c0", true))
	else:
		quality = 0
		_content_vb.add_child(_make_label("어색하게 끝났습니다. 연습이 필요합니다.", 13, "#c86060", true))

	var btn := _make_button("확인", "#1a4a7a")
	btn.pressed.connect(func(): _finish(quality, 0))
	_content_vb.add_child(btn)

# ── STUDY 모드 ────────────────────────────────────────────────────
func _build_study_topic_ui() -> void:
	_progress_lbl.text = "주제 선택"
	_content_vb.add_child(_make_label("오늘 집중할 자기계발 분야를 고르세요.", 13, "#5a7a9a"))

	var sep := HSeparator.new()
	sep.add_theme_color_override("color", Color("#1a2030"))
	_content_vb.add_child(sep)

	for topic in STUDY_TOPICS:
		var btn := _make_button(topic["label"], "#1e2a45")
		btn.custom_minimum_size = Vector2(0, 50)
		btn.add_theme_font_size_override("font_size", 15)
		var t: Dictionary = topic
		btn.pressed.connect(func(): _start_study(t))
		_content_vb.add_child(btn)

func _start_study(topic: Dictionary) -> void:
	_study_topic = topic
	var pool: Array = STUDY_QUESTIONS[topic["id"]].duplicate()
	pool.shuffle()
	_study_qs = pool.slice(0, STUDY_QUESTIONS_PER_SESSION)
	_study_idx = 0
	_study_score = 0
	_header_lbl.text = "📚 " + str(topic["label"])
	_show_study_question()

func _show_study_question() -> void:
	_timer_active = false
	_clear_content()

	if _study_idx >= _study_qs.size():
		_show_study_result()
		return

	_progress_lbl.text = "%d / %d" % [_study_idx + 1, _study_qs.size()]

	_make_timer_bar()

	var q: Dictionary = _study_qs[_study_idx]
	var q_lbl := _make_label(str(q["q"]), 14, "#e8eaf0", true)
	q_lbl.custom_minimum_size = Vector2(0, 56)
	_content_vb.add_child(q_lbl)

	_feedback_lbl = _make_label("", 12, "#3dba6a", true)
	_content_vb.add_child(_feedback_lbl)

	var choices: Array = q["choices"]
	for c in choices:
		var btn := _make_button(str(c["text"]))
		btn.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		btn.custom_minimum_size = Vector2(0, 44)
		btn.pressed.connect(Callable(self, "_on_study_choice").bind(int(c["score"])))
		_content_vb.add_child(btn)

	_timer_left = STUDY_TIMER
	_timer_max = STUDY_TIMER
	_timer_active = true

func _on_study_choice(score: int) -> void:
	if not _timer_active:
		return
	_timer_active = false
	_study_score += score
	for ch in _content_vb.get_children():
		if ch is Button:
			ch.disabled = true
	if is_instance_valid(_feedback_lbl):
		if score == 3:
			_feedback_lbl.text = "✓ 정확히 이해했습니다."
			_feedback_lbl.add_theme_color_override("font_color", Color("#3dba6a"))
		elif score >= 1:
			_feedback_lbl.text = "△ 부분적으로 맞습니다."
			_feedback_lbl.add_theme_color_override("font_color", Color("#c8a020"))
		else:
			_feedback_lbl.text = "✗ 다시 공부해야겠습니다."
			_feedback_lbl.add_theme_color_override("font_color", Color("#c86060"))
	_study_idx += 1
	await get_tree().create_timer(0.8).timeout
	_show_study_question()

func _show_study_result() -> void:
	_timer_active = false
	_progress_lbl.text = "완료"

	var max_score: int = _study_qs.size() * 3
	var ratio: float = float(_study_score) / float(max_score) if max_score > 0 else 0.0
	var quality: int
	if ratio >= 0.85:
		quality = 3
	elif ratio >= 0.6:
		quality = 2
	elif ratio >= 0.35:
		quality = 1
	else:
		quality = 0

	var topic_name: String = str(_study_topic.get("label", ""))
	_content_vb.add_child(_make_label("── %s 결과 ──" % topic_name, 14, "#5b9cf6"))

	var grade_text: String
	var grade_color: String
	match quality:
		3: grade_text = "우수 — 완벽하게 이해했습니다!"; grade_color = "#3dba6a"
		2: grade_text = "양호 — 충분히 습득했습니다."; grade_color = "#a8c8f0"
		1: grade_text = "무난 — 더 공부가 필요합니다."; grade_color = "#a0a8c0"
		_: grade_text = "부족 — 집중이 흐트러졌습니다."; grade_color = "#c86060"

	_content_vb.add_child(_make_label(grade_text, 13, grade_color, true))

	# 예상 스탯 효과 미리보기
	var stat: String = str(_study_topic.get("stat", ""))
	var base_gain: int = int(_study_topic.get("gain", 0))
	var actual_gain: int = _calc_study_gain(quality, base_gain)
	if not stat.is_empty():
		_content_vb.add_child(_make_label(
			"%s +%d" % [_stat_korean(stat), actual_gain], 12, "#5a9a7a"))

	var btn := _make_button("확인", "#1a4a7a")
	btn.pressed.connect(func(): _finish(quality, 0))
	_content_vb.add_child(btn)

# ── 공통 타임아웃 ─────────────────────────────────────────────────
func _on_timeout() -> void:
	match _mode:
		Mode.NETWORK:
			if is_instance_valid(_feedback_lbl):
				_feedback_lbl.text = "⏱ 시간 초과 — 어색하게 헤어졌다."
				_feedback_lbl.add_theme_color_override("font_color", Color("#c86060"))
			for ch in _content_vb.get_children():
				if ch is Button:
					ch.disabled = true
			_net_idx += 1
			await get_tree().create_timer(1.0).timeout
			_show_npc()
		Mode.STUDY:
			if is_instance_valid(_feedback_lbl):
				_feedback_lbl.text = "⏱ 시간 초과"
				_feedback_lbl.add_theme_color_override("font_color", Color("#c86060"))
			for ch in _content_vb.get_children():
				if ch is Button:
					ch.disabled = true
			_study_idx += 1
			await get_tree().create_timer(0.8).timeout
			_show_study_question()

# ── 종료 ─────────────────────────────────────────────────────────
func _finish(quality: int, extra_money: int) -> void:
	_timer_active = false
	set_process(false)
	visible = false
	closed.emit(quality, extra_money)

# ── 헬퍼 ─────────────────────────────────────────────────────────
func _calc_study_gain(quality: int, base: int) -> int:
	match quality:
		3: return int(base * 1.5)
		2: return base
		1: return int(base * 0.7)
		_: return int(base * 0.3)

func _stat_korean(stat: String) -> String:
	match stat:
		"intelligence": return "지력"
		"health": return "건강"
		"mental": return "정신력"
		"investment_skill": return "투자감각"
		"social_skill": return "사회성"
		_: return stat

func _fmt(amount: int) -> String:
	if amount >= 10000:
		return "%d만원" % (amount / 10000)
	return "%d원" % amount
