extends Control
## ArubaGame — 아르바이트 시프트 미니게임.
## 3~4개 상황카드 → 즉각 선택 → 시프트 결산.
## 직업 카테고리에 따라 다른 시나리오 풀을 사용.
## MainGame이 overlay로 붙이고 open()으로 표시. AP는 호출 전에 소비.

signal closed(earned: int, stress_delta: int)

const BASE_PAY := 400_000   # 기본 알바비

# ── 시나리오 데이터 ────────────────────────────────────────────────
# 각 시나리오: { scene, choices: [{text, money, stress, health, tip}] }
# tip: 선택 후 잠깐 보여주는 단문 결과 메시지

const SCENARIOS_CONVENIENCE = [
	{
		"scene": "밤 11시. 술 취한 손님이 계산대에 기대며 시비를 건다. 편의점 알바 첫 시간.",
		"choices": [
			{"text": "조용히 계산만 빠르게 끝낸다", "money": 0, "stress": 3, "health": 0, "tip": "별 탈 없이 넘어갔다."},
			{"text": "\"금방 계산해드릴게요\" 차분하게 대응한다", "money": 3000, "stress": 0, "health": 0, "tip": "손님이 고맙다며 팁을 남겼다."},
			{"text": "점장에게 메시지를 보낸다", "money": 0, "stress": -2, "health": 0, "tip": "점장이 나와줬다. 짧게 훈수만 들었다."},
		]
	},
	{
		"scene": "새벽 2시. 재고 정리 도중 냉동고 문이 고장났다. 혼자다.",
		"choices": [
			{"text": "응급처치 테이프로 임시 고정한다", "money": 0, "stress": 2, "health": -1, "tip": "아침에 점장이 알아챘지만 솜씨를 칭찬했다."},
			{"text": "점장에게 즉시 전화한다", "money": 0, "stress": 5, "health": 0, "tip": "심야에 불러냈다. 눈치가 보인다."},
			{"text": "보고서를 꼼꼼하게 남겨두고 계속 일한다", "money": 5000, "stress": -1, "health": 0, "tip": "다음날 점장이 잘 처리했다며 보너스를 줬다."},
		]
	},
	{
		"scene": "손님이 유통기한 지난 샌드위치를 들고 왔다. 실수로 진열한 것 같다.",
		"choices": [
			{"text": "죄송하다며 즉시 교환해준다", "money": 0, "stress": 2, "health": 0, "tip": "손님은 만족했다. 기록에는 남았다."},
			{"text": "점장 오기 전에 조용히 처리한다", "money": 0, "stress": -2, "health": 0, "tip": "아무도 모르게 넘어갔다."},
			{"text": "솔직하게 내 실수였다고 인정한다", "money": -5000, "stress": 4, "health": 0, "tip": "시말서를 썼지만 점장은 정직함을 높이 샀다."},
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
			{"text": "절차대로 본사 처리를 안내한다", "money": 0, "stress": 2, "health": 0, "tip": "손님은 불만이었지만 규정이다."},
			{"text": "점장에게 먼저 확인한다", "money": 0, "stress": -1, "health": 0, "tip": "점장이 처리해줬다. 문제없이 마무리됐다."},
			{"text": "내 돈으로 먼저 주고 정산한다", "money": -50000, "stress": -2, "health": 0, "tip": "손님은 고마워했다. 나중에 돌려받았다."},
		]
	},
]

const SCENARIOS_DELIVERY = [
	{
		"scene": "비가 쏟아진다. GPS가 이 골목으로 가라는데, 포장이 젖을 것 같다.",
		"choices": [
			{"text": "속도를 올려 빠르게 배달한다", "money": 3000, "stress": 3, "health": -2, "tip": "음식은 겨우 살았다. 몸이 좀 힘들다."},
			{"text": "편의점에서 봉지를 사서 싼다", "money": -1000, "stress": -1, "health": 0, "tip": "손님이 꼼꼼하다며 별 5개를 줬다."},
			{"text": "배달 앱에 상황을 알린다", "money": 0, "stress": 1, "health": 0, "tip": "아무 일 없이 넘어갔다."},
		]
	},
	{
		"scene": "손님이 주소를 틀리게 써놨다. 전화가 안 된다.",
		"choices": [
			{"text": "인근을 돌며 찾아본다", "money": 0, "stress": 4, "health": -1, "tip": "10분 뒤 손님이 다시 전화했다. 별로 안 고마워한다."},
			{"text": "배달 앱 고객센터에 연락한다", "money": 5000, "stress": -1, "health": 0, "tip": "고객센터가 환불 대신 처리비를 줬다."},
			{"text": "입구에 두고 사진 찍어 알린다", "money": 0, "stress": 0, "health": 0, "tip": "표준적인 처리. 별점 3개."},
		]
	},
	{
		"scene": "오토바이 접촉사고가 났다. 작은 긁힘이고 상대방이 그냥 가자고 한다.",
		"choices": [
			{"text": "번호판 찍어두고 보험 처리한다", "money": -10000, "stress": 3, "health": 0, "tip": "정식 처리. 시간이 좀 걸렸다."},
			{"text": "상대방 말대로 그냥 넘어간다", "money": 0, "stress": -2, "health": -2, "tip": "나중에 좀 찜찜했다."},
			{"text": "현장에서 합의금을 받는다", "money": 30000, "stress": 1, "health": 0, "tip": "빠르게 해결됐다."},
		]
	},
	{
		"scene": "같은 구역에서 일하는 배달 기사가 콜을 가로채는 것 같다.",
		"choices": [
			{"text": "증거를 모아 신고한다", "money": 0, "stress": 3, "health": 0, "tip": "플랫폼에서 패널티를 줬다. 시간이 걸렸다."},
			{"text": "직접 말을 건다", "money": 10000, "stress": 1, "health": 0, "tip": "어색했지만 이후로 달라졌다."},
			{"text": "무시하고 더 빠르게 치고 나간다", "money": 5000, "stress": 2, "health": -1, "tip": "속도로 따돌렸다. 몸이 조금 더 힘들다."},
		]
	},
]

const SCENARIOS_GENERAL = [
	{
		"scene": "내일 마감인 보고서가 있는데 부장이 야근을 부탁했다.",
		"choices": [
			{"text": "자정까지 남아서 끝낸다", "money": 20000, "stress": 6, "health": -2, "tip": "초과 수당이 붙었다. 몸이 힘들다."},
			{"text": "내 업무만 끝내고 퇴근한다", "money": 0, "stress": 0, "health": 0, "tip": "원칙적이다. 상사 눈치가 살짝 보인다."},
			{"text": "다음날 일찍 나와서 마무리하겠다 제안한다", "money": 5000, "stress": -2, "health": 0, "tip": "상사가 대안에 만족했다."},
		]
	},
	{
		"scene": "카페 마감 청소 중. 손님이 15분 전에 들어와 자리를 잡았다.",
		"choices": [
			{"text": "영업시간 종료를 정중히 알린다", "money": 0, "stress": -1, "health": 0, "tip": "손님이 이해하고 나갔다."},
			{"text": "그냥 청소하면서 눈치를 준다", "money": 0, "stress": 2, "health": 0, "tip": "분위기가 어색해졌다."},
			{"text": "오늘 것은 놔두고 더 이른 부분만 청소한다", "money": 3000, "stress": -3, "health": 0, "tip": "손님이 팁을 남기고 갔다."},
		]
	},
	{
		"scene": "오전 오픈 담당인데 키를 잃어버렸다. 30분 뒤 오픈이다.",
		"choices": [
			{"text": "사장에게 즉시 연락한다", "money": -10000, "stress": 5, "health": 0, "tip": "잔소리를 들었다. 다음 달 임금에서 열쇠 복사비가 빠졌다."},
			{"text": "가방을 샅샅이 다시 뒤진다", "money": 0, "stress": 2, "health": 0, "tip": "사물함 안에 있었다. 아슬아슬하게 제때 열었다."},
			{"text": "인근 직원에게 연락해 부탁한다", "money": -5000, "stress": -1, "health": 0, "tip": "도움을 받아 해결했다. 저녁에 커피 한 잔 샀다."},
		]
	},
	{
		"scene": "월급날인데 사장이 이번 달 하루 늦는다고 한다. 두 번째다.",
		"choices": [
			{"text": "그러시겠냐고 넘어간다", "money": 0, "stress": 3, "health": 0, "tip": "속이 쓰리다."},
			{"text": "근로계약서 조항을 언급하며 부탁한다", "money": 0, "stress": 1, "health": 0, "tip": "다음날 입금됐다."},
			{"text": "노동부 신고를 검토한다", "money": 0, "stress": -2, "health": 0, "tip": "결국 제때 입금됐다. 사장이 눈치를 챘을지도."},
		]
	},
]

var _rng := RandomNumberGenerator.new()
var _scenarios: Array = []
var _current_idx: int = 0
var _earned: int = BASE_PAY
var _stress_delta: int = 0
var _health_delta: int = 0
var _log: Array = []

# UI
var _root_vb: VBoxContainer
var _scene_lbl: Label
var _choice_vb: VBoxContainer
var _progress_lbl: Label
var _feedback_lbl: Label
var _feedback_timer: float = 0.0
var _waiting_feedback: bool = false

func _ready() -> void:
	_rng.randomize()
	set_anchors_preset(Control.PRESET_FULL_RECT)
	_build_ui()
	visible = false
	set_process(false)

func _process(delta: float) -> void:
	if _waiting_feedback:
		_feedback_timer -= delta
		if _feedback_timer <= 0.0:
			_waiting_feedback = false
			set_process(false)
			_current_idx += 1
			if _current_idx >= _scenarios.size():
				_show_result()
			else:
				_show_scenario(_current_idx)

# ── 진입 ──────────────────────────────────────────────────────────
func open() -> void:
	_earned = BASE_PAY
	_stress_delta = 0
	_health_delta = 0
	_log = []
	_current_idx = 0
	_scenarios = _pick_scenarios()
	_build_content()
	visible = true
	_show_scenario(0)

func _pick_scenarios() -> Array:
	var pool: Array
	var job_id: String = GameState.current_job.get("id", "")
	match job_id:
		"job_01": pool = SCENARIOS_CONVENIENCE
		"job_02": pool = SCENARIOS_DELIVERY
		_:         pool = SCENARIOS_GENERAL
	var shuffled: Array = pool.duplicate()
	shuffled.shuffle()
	# 마스터리 등급에 따라 시나리오 수 증가
	var mastery: int = MetaProgression.get_mastery("aruba")
	var count: int = 3
	if GameState.social_skill >= 50: count = 4
	if mastery >= 2: count = maxi(count, 4)  # 고급: 항상 4개
	if mastery >= 3: count = 5               # 마스터: 5개 (보너스 시나리오)
	return shuffled.slice(0, mini(count, shuffled.size()))

# ── UI 빌드 ───────────────────────────────────────────────────────
func _build_ui() -> void:
	var bg := ColorRect.new()
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.color = Color("#06090f")
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

	# 헤더
	var hdr := HBoxContainer.new()
	_root_vb.add_child(hdr)
	var title_lbl := Label.new()
	title_lbl.text = "💼 알바 시프트"
	title_lbl.add_theme_font_size_override("font_size", 17)
	title_lbl.add_theme_color_override("font_color", Color("#f0b429"))
	title_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hdr.add_child(title_lbl)
	_progress_lbl = Label.new()
	_progress_lbl.add_theme_font_size_override("font_size", 12)
	_progress_lbl.add_theme_color_override("font_color", Color("#5a6a8a"))
	hdr.add_child(_progress_lbl)

	var sep := HSeparator.new()
	sep.add_theme_color_override("color", Color("#1a2030"))
	_root_vb.add_child(sep)

	# 상황 텍스트
	_scene_lbl = Label.new()
	_scene_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_scene_lbl.add_theme_font_size_override("font_size", 14)
	_scene_lbl.add_theme_color_override("font_color", Color("#d0d8e0"))
	_scene_lbl.custom_minimum_size = Vector2(0, 70)
	_root_vb.add_child(_scene_lbl)

	# 피드백 레이블 (선택 후 잠깐 표시)
	_feedback_lbl = Label.new()
	_feedback_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_feedback_lbl.add_theme_font_size_override("font_size", 12)
	_feedback_lbl.add_theme_color_override("font_color", Color("#3dba6a"))
	_feedback_lbl.custom_minimum_size = Vector2(0, 24)
	_root_vb.add_child(_feedback_lbl)

	# 선택지
	_choice_vb = VBoxContainer.new()
	_choice_vb.add_theme_constant_override("separation", 7)
	_root_vb.add_child(_choice_vb)

func _build_content() -> void:
	_scene_lbl.text = ""
	_feedback_lbl.text = ""
	for ch in _choice_vb.get_children():
		ch.queue_free()

# ── 시나리오 표시 ──────────────────────────────────────────────────
func _show_scenario(idx: int) -> void:
	var sc: Dictionary = _scenarios[idx]
	_scene_lbl.text = sc["scene"]
	_feedback_lbl.text = ""
	_progress_lbl.text = "%d / %d" % [idx + 1, _scenarios.size()]

	# 선택지 재생성
	for ch in _choice_vb.get_children():
		ch.queue_free()

	var choices: Array = sc["choices"]
	for ci in range(choices.size()):
		var choice: Dictionary = choices[ci]
		var btn := _choice_btn(choice["text"])
		var cap_ci: int = ci
		btn.pressed.connect(func(): _on_choice(sc, cap_ci))
		_choice_vb.add_child(btn)

func _choice_btn(text: String) -> Button:
	var btn := Button.new()
	btn.text = text
	btn.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	btn.custom_minimum_size = Vector2(0, 36)
	btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var st := StyleBoxFlat.new()
	st.bg_color = Color("#0e1a2a")
	st.set_corner_radius_all(6)
	var hov := st.duplicate()
	hov.bg_color = Color("#1a2e44")
	btn.add_theme_stylebox_override("normal", st)
	btn.add_theme_stylebox_override("hover", hov)
	btn.add_theme_stylebox_override("pressed", hov)
	btn.add_theme_color_override("font_color", Color("#c8d8e8"))
	btn.add_theme_font_size_override("font_size", 13)
	return btn

# ── 선택 처리 ─────────────────────────────────────────────────────
func _on_choice(sc: Dictionary, choice_idx: int) -> void:
	var choice: Dictionary = sc["choices"][choice_idx]
	var m: int = int(choice.get("money", 0))
	var s: int = int(choice.get("stress", 0))
	var h: int = int(choice.get("health", 0))

	_earned += m
	_stress_delta += s
	_health_delta += h

	var tip: String = choice.get("tip", "")
	var money_str: String = ("  %+d원" % m) if m != 0 else ""
	_feedback_lbl.text = "→ " + tip + money_str
	_log.append("[%d] %s → %s" % [choice_idx + 1, choice["text"], tip])

	# 선택지 비활성화
	for ch in _choice_vb.get_children():
		if ch is Button:
			ch.disabled = true

	AudioManager.play("click")

	# 0.9초 후 다음 상황
	_feedback_timer = 0.9
	_waiting_feedback = true
	set_process(true)

# ── 결과 화면 ─────────────────────────────────────────────────────
func _show_result() -> void:
	_scene_lbl.text = ""
	_feedback_lbl.text = ""
	_progress_lbl.text = "완료"

	for ch in _choice_vb.get_children():
		ch.queue_free()

	# 결과 패널
	var result_vb := VBoxContainer.new()
	result_vb.add_theme_constant_override("separation", 8)
	_choice_vb.add_child(result_vb)

	var finish_lbl := Label.new()
	finish_lbl.text = "시프트 끝"
	finish_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	finish_lbl.add_theme_font_size_override("font_size", 15)
	finish_lbl.add_theme_color_override("font_color", Color("#f0b429"))
	result_vb.add_child(finish_lbl)

	var earn_lbl := Label.new()
	earn_lbl.text = "+%s원" % str(_earned).pad_zeros(0)
	earn_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	earn_lbl.add_theme_font_size_override("font_size", 24)
	earn_lbl.add_theme_color_override("font_color", Color("#3dba6a") if _earned >= BASE_PAY else Color("#e85d5d"))
	result_vb.add_child(earn_lbl)

	var stat_row := HBoxContainer.new()
	stat_row.alignment = BoxContainer.ALIGNMENT_CENTER
	stat_row.add_theme_constant_override("separation", 16)
	result_vb.add_child(stat_row)
	if _stress_delta != 0:
		var sl := Label.new()
		sl.text = "스트레스 %+d" % _stress_delta
		sl.add_theme_font_size_override("font_size", 11)
		sl.add_theme_color_override("font_color", Color("#e85d5d") if _stress_delta > 0 else Color("#3dba6a"))
		stat_row.add_child(sl)
	if _health_delta != 0:
		var hl := Label.new()
		hl.text = "건강 %+d" % _health_delta
		hl.add_theme_font_size_override("font_size", 11)
		hl.add_theme_color_override("font_color", Color("#e85d5d") if _health_delta < 0 else Color("#3dba6a"))
		stat_row.add_child(hl)

	var ok_btn := Button.new()
	ok_btn.text = "퇴근하기"
	ok_btn.custom_minimum_size = Vector2(0, 40)
	var ok_st := StyleBoxFlat.new()
	ok_st.bg_color = Color("#0e3a2a")
	ok_st.set_corner_radius_all(6)
	ok_btn.add_theme_stylebox_override("normal", ok_st)
	ok_btn.add_theme_color_override("font_color", Color("#e8eaf0"))
	ok_btn.add_theme_font_size_override("font_size", 14)
	ok_btn.pressed.connect(_on_finish)
	result_vb.add_child(ok_btn)

func _on_finish() -> void:
	MetaProgression.record_minigame_play("aruba")
	visible = false
	closed.emit(_earned, _stress_delta)
