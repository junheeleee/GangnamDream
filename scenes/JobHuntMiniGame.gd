extends Control
## JobHuntMiniGame — 자소서 작성 & 모의 면접 미니게임
## Mode.RESUME : 자소서 문항 선택 (4문항, 채점형)
## Mode.INTERVIEW : 압박 면접 Q&A (타이머 압박, 5문항)
## MainGame이 overlay로 붙이고 open(mode)으로 표시.

signal closed(stress_delta: int, quality: int)
# quality: 0=불합격수준, 1=무난, 2=좋음, 3=우수

enum Mode { RESUME, INTERVIEW }

# ── 자소서 문항 ──────────────────────────────────────────────────
const RESUME_QUESTION_POOL = [
	{
		"q": "지원동기를 서술하시오.",
		"hint": "면접관이 가장 먼저 읽는 문항. 진정성이 핵심.",
		"choices": [
			{"text": "이 분야에서 쌓은 경험을 실무에 적용해 함께 성장하고 싶습니다.", "score": 3},
			{"text": "성장 가능성이 있다고 판단해 지원하게 됐습니다.", "score": 1},
			{"text": "연봉 조건이 괜찮고 집에서 가까워서 지원했습니다.", "score": 0},
		]
	},
	{
		"q": "본인의 강점을 구체적인 경험과 함께 서술하시오.",
		"hint": "추상적인 단어보다 구체적인 사례가 설득력 있다.",
		"choices": [
			{"text": "데이터 분석과 빠른 업무 처리 능력입니다. 이전 업무에서 처리 속도를 30% 개선한 경험이 있습니다.", "score": 3},
			{"text": "성실하고 책임감이 강합니다. 맡은 일은 끝까지 완수합니다.", "score": 1},
			{"text": "특별한 강점은 없지만 열심히 하겠습니다.", "score": 0},
		]
	},
	{
		"q": "단점과 그 극복 과정을 서술하시오.",
		"hint": "단점을 인정하면서 극복 과정까지 보여주는 것이 핵심.",
		"choices": [
			{"text": "계획 수립이 부족했습니다. 업무 일지를 매일 작성하는 습관을 만들어 개선했습니다.", "score": 3},
			{"text": "완벽주의 성향으로 업무 처리가 느릴 때가 있습니다.", "score": 1},
			{"text": "단점은 딱히 없는 것 같습니다.", "score": 0},
		]
	},
	{
		"q": "입사 후 3년, 5년 포부를 서술하시오.",
		"hint": "구체적인 시간표와 목표가 신뢰감을 준다.",
		"choices": [
			{"text": "1년 내 업무를 완전히 파악하고, 3년 후에는 팀의 핵심 인재로 성장하겠습니다.", "score": 3},
			{"text": "열심히 배우며 회사에 기여하겠습니다.", "score": 1},
			{"text": "일단 들어가 봐야 알겠습니다.", "score": 0},
		]
	},
	{
		"q": "팀 내 갈등 상황에서 어떻게 대처하나요?",
		"hint": "갈등 해결 능력과 협업 역량을 보여주는 문항.",
		"choices": [
			{"text": "먼저 상대방의 입장을 충분히 듣고, 공통된 목표를 기준으로 합의점을 찾습니다.", "score": 3},
			{"text": "상급자에게 중재를 요청합니다.", "score": 1},
			{"text": "갈등을 피하고 조용히 넘어가려 합니다.", "score": 0},
		]
	},
	{
		"q": "본인의 실패 경험과 그로부터 배운 점을 서술하시오.",
		"hint": "실패를 인정하는 용기와 성장 의지를 보여준다.",
		"choices": [
			{"text": "프로젝트 마감 실패 경험이 있습니다. 이후 주간 체크리스트를 도입해 재발을 방지했습니다.", "score": 3},
			{"text": "큰 실패는 없었지만 작은 실수에서 배웠습니다.", "score": 1},
			{"text": "딱히 기억나는 실패가 없습니다.", "score": 0},
		]
	},
	{
		"q": "빠르게 변화하는 업무 환경에 어떻게 적응하나요?",
		"hint": "변화 대응력과 학습 의지를 어필하는 문항.",
		"choices": [
			{"text": "변화의 핵심을 빠르게 파악하고, 관련 자료와 교육을 스스로 찾아 학습합니다.", "score": 3},
			{"text": "상사나 동료에게 방향을 물어보고 따릅니다.", "score": 1},
			{"text": "변화가 안정되기를 기다렸다가 움직입니다.", "score": 0},
		]
	},
	{
		"q": "본인이 이 직무에 적합한 이유를 서술하시오.",
		"hint": "직무 요건과 나의 경험을 연결하는 것이 핵심.",
		"choices": [
			{"text": "직무 요건에 명시된 역량 세 가지를 각각 경험과 연결해 구체적으로 설명합니다.", "score": 3},
			{"text": "관련 업무에 관심이 많고 열심히 할 자신이 있습니다.", "score": 1},
			{"text": "다른 곳에서도 비슷한 일을 해봤습니다.", "score": 0},
		]
	},
]
const RESUME_QUESTIONS_PER_SESSION: int = 4

const INTERVIEW_QUESTION_POOL = [
	{
		"q": "이력서에 6년 공백이 있네요. 설명해 주시겠어요?",
		"timer": 10.0, "surprise": false,
		"choices": [
			{"text": "집안 사정으로 부모님을 돌봐야 했습니다. 그 기간에도 자격증 공부를 병행했습니다.", "score": 3},
			{"text": "개인적인 사정이 있었습니다. 이제는 집중할 수 있습니다.", "score": 1},
			{"text": "특별한 이유는 없고 그냥 쉬었습니다.", "score": 0},
		]
	},
	{
		"q": "저희 회사 지원동기가 무엇인가요?",
		"timer": 10.0, "surprise": false,
		"choices": [
			{"text": "귀사의 성장세와 사업 방향이 제 커리어 목표와 맞닿아 있어 지원했습니다.", "score": 3},
			{"text": "찾아보다가 관심이 생겼습니다. 좋은 회사라고 생각합니다.", "score": 1},
			{"text": "마침 공고가 떠서 넣어봤습니다.", "score": 0},
		]
	},
	{
		"q": "5년 후 본인의 모습은 어떨 것 같나요?",
		"timer": 10.0, "surprise": false,
		"choices": [
			{"text": "이 분야의 전문가로서 팀을 이끄는 역할을 하고 싶습니다.", "score": 3},
			{"text": "더 좋은 포지션으로 성장해 있을 것 같습니다.", "score": 1},
			{"text": "솔직히 잘 모르겠습니다.", "score": 0},
		]
	},
	{
		"q": "⚡ 돌발: 지금 이 자리에서 스스로를 한 단어로 표현한다면?",
		"timer": 5.0, "surprise": true,
		"choices": [
			{"text": "\"성실함\" — 맡은 일은 반드시 끝내는 사람입니다.", "score": 3},
			{"text": "(잠시 침묵) \"...열정적인 사람입니다.\"", "score": 1},
			{"text": "(당황) \"...글쎄요... 잘 모르겠습니다.\"", "score": 0},
		]
	},
	{
		"q": "마지막으로 하고 싶은 말씀 있으신가요?",
		"timer": 8.0, "surprise": false,
		"choices": [
			{"text": "오늘 좋은 기회를 주셔서 감사합니다. 합류하게 된다면 최선을 다하겠습니다.", "score": 3},
			{"text": "(아무 말도 못 하고 인사만)", "score": 1},
			{"text": "연봉 협상은 어떻게 되나요?", "score": 0},
		]
	},
	{
		"q": "동료가 실수를 했는데 마감이 얼마 안 남았습니다. 어떻게 하겠습니까?",
		"timer": 10.0, "surprise": false,
		"choices": [
			{"text": "먼저 문제의 범위를 파악하고, 팀과 협력해 최단 시간 내 해결책을 찾겠습니다.", "score": 3},
			{"text": "상황을 상사에게 즉시 보고하겠습니다.", "score": 1},
			{"text": "그것은 동료의 책임이므로 제 업무에 집중하겠습니다.", "score": 0},
		]
	},
	{
		"q": "⚡ 돌발: 지금 바로 저를 설득해서 제품을 하나 파세요.",
		"timer": 5.0, "surprise": true,
		"choices": [
			{"text": "(침착하게) 이 펜은 오늘 하루를 기록하는 도구입니다. 오늘 당신이 내린 결정, 잊고 싶지 않으시죠?", "score": 3},
			{"text": "(당황하며) 음... 이 펜은 잘 써지고 가격도 합리적입니다.", "score": 1},
			{"text": "(웃으며 넘김) 저는 영업직 지원자가 아닌데요.", "score": 0},
		]
	},
	{
		"q": "업무 중 우선순위가 충돌할 때 어떻게 결정하나요?",
		"timer": 10.0, "surprise": false,
		"choices": [
			{"text": "긴급도와 중요도를 기준으로 매트릭스를 만들고, 팀장과 우선순위를 확인합니다.", "score": 3},
			{"text": "먼저 들어온 일을 먼저 처리합니다.", "score": 1},
			{"text": "모든 일을 동시에 처리하려 노력합니다.", "score": 0},
		]
	},
	{
		"q": "이전 직장을 떠난 이유가 무엇인가요?",
		"timer": 10.0, "surprise": false,
		"choices": [
			{"text": "성장 한계를 느꼈고, 더 넓은 환경에서 역량을 키우고 싶어 새로운 기회를 찾았습니다.", "score": 3},
			{"text": "연봉이 낮아서입니다.", "score": 0},
			{"text": "상사와 맞지 않아서 퇴사했습니다.", "score": 1},
		]
	},
	{
		"q": "본인의 리더십 경험을 구체적으로 말씀해 주세요.",
		"timer": 10.0, "surprise": false,
		"choices": [
			{"text": "프로젝트 팀장 역할을 맡아 일정 관리와 갈등 조율을 담당했고, 목표 기한 내 완료했습니다.", "score": 3},
			{"text": "공식 리더 경험은 없지만 비공식적으로 팀을 도왔습니다.", "score": 1},
			{"text": "리더십 경험은 없습니다.", "score": 0},
		]
	},
]
const INTERVIEW_QUESTIONS_PER_SESSION: int = 5

# ── 상태 ─────────────────────────────────────────────────────────
var current_mode: Mode = Mode.RESUME  # MainGame이 closed 핸들러에서 읽음
var _mode: Mode = Mode.RESUME
var _active_questions: Array = []  # 이번 세션에 사용할 랜덤 문항
var _q_idx: int = 0
var _total_score: int = 0
var _stress_delta: int = 0
var _timer_left: float = 0.0
var _timer_max: float = 10.0
var _timer_active: bool = false
var _waiting: bool = false
var _wait_timer: float = 0.0

# ── UI ───────────────────────────────────────────────────────────
var _root_vb: VBoxContainer
var _header_lbl: Label
var _progress_lbl: Label
var _content_vb: VBoxContainer
var _q_lbl: Label
var _hint_lbl: Label
var _choice_vb: VBoxContainer
var _feedback_lbl: Label
var _timer_bar: ProgressBar

# ── 초기화 ───────────────────────────────────────────────────────
func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_build_base_ui()
	visible = false
	set_process(false)

func _process(delta: float) -> void:
	if _waiting:
		_wait_timer -= delta
		if _wait_timer <= 0.0:
			_waiting = false
			_q_idx += 1
			var questions := _get_questions()
			if _q_idx >= questions.size():
				_show_result()
			else:
				_show_question()
		return

	if _timer_active and _mode == Mode.INTERVIEW:
		_timer_left -= delta
		if is_instance_valid(_timer_bar):
			_timer_bar.value = maxf(_timer_left / _timer_max, 0.0) * 100.0
			# 색상 경고
			if _timer_left < _timer_max * 0.3:
				var fill := StyleBoxFlat.new()
				fill.bg_color = Color("#c83030")
				_timer_bar.add_theme_stylebox_override("fill", fill)
			elif _timer_left < _timer_max * 0.6:
				var fill := StyleBoxFlat.new()
				fill.bg_color = Color("#c8a020")
				_timer_bar.add_theme_stylebox_override("fill", fill)
		if _timer_left <= 0.0:
			_on_timeout()

# ── 진입 ─────────────────────────────────────────────────────────
func open(mode: Mode) -> void:
	_mode = mode
	current_mode = mode
	_q_idx = 0
	_total_score = 0
	_stress_delta = 0
	_timer_active = false
	_waiting = false

	# 매 세션마다 문항 풀에서 랜덤 선택
	if _mode == Mode.RESUME:
		var pool: Array = RESUME_QUESTION_POOL.duplicate()
		pool.shuffle()
		_active_questions = pool.slice(0, RESUME_QUESTIONS_PER_SESSION)
	else:
		# 면접: 돌발 문항 1개는 반드시 포함
		var surprises: Array = INTERVIEW_QUESTION_POOL.filter(func(q): return q.get("surprise", false))
		var normals: Array = INTERVIEW_QUESTION_POOL.filter(func(q): return not q.get("surprise", false))
		surprises.shuffle()
		normals.shuffle()
		var picked_surprise: Array = surprises.slice(0, 1)
		var picked_normal: Array = normals.slice(0, INTERVIEW_QUESTIONS_PER_SESSION - 1)
		_active_questions = picked_normal + picked_surprise
		_active_questions.shuffle()

	_clear_content()
	visible = true

	match _mode:
		Mode.RESUME:
			_header_lbl.text = "🖊 자기소개서 작성"
			_start_common()
		Mode.INTERVIEW:
			_header_lbl.text = "🎯 모의 면접"
			_start_common()

func _get_questions() -> Array:
	return _active_questions

func _clear_content() -> void:
	for ch in _content_vb.get_children():
		ch.queue_free()
	_q_lbl = null
	_hint_lbl = null
	_choice_vb = null
	_feedback_lbl = null
	_timer_bar = null

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
	_header_lbl.text = "📋 취업 준비"
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
	_content_vb.add_theme_constant_override("separation", 10)
	_content_vb.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_root_vb.add_child(_content_vb)

# ── 공통 시작 ────────────────────────────────────────────────────
func _start_common() -> void:
	# 면접 모드: 타이머 바
	if _mode == Mode.INTERVIEW:
		_timer_bar = ProgressBar.new()
		_timer_bar.min_value = 0
		_timer_bar.max_value = 100
		_timer_bar.value = 100
		_timer_bar.show_percentage = false
		_timer_bar.custom_minimum_size = Vector2(0, 8)
		var fill := StyleBoxFlat.new()
		fill.bg_color = Color("#2a7a3a")
		_timer_bar.add_theme_stylebox_override("fill", fill)
		_content_vb.add_child(_timer_bar)

	# 질문 텍스트
	_q_lbl = Label.new()
	_q_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_q_lbl.add_theme_font_size_override("font_size", 14)
	_q_lbl.add_theme_color_override("font_color", Color("#e8eaf0"))
	_q_lbl.custom_minimum_size = Vector2(0, 56)
	_content_vb.add_child(_q_lbl)

	# 힌트 (자소서 모드)
	_hint_lbl = Label.new()
	_hint_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_hint_lbl.add_theme_font_size_override("font_size", 11)
	_hint_lbl.add_theme_color_override("font_color", Color("#4a6a7a"))
	_hint_lbl.custom_minimum_size = Vector2(0, 18)
	_content_vb.add_child(_hint_lbl)

	# 피드백 (선택 후)
	_feedback_lbl = Label.new()
	_feedback_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_feedback_lbl.add_theme_font_size_override("font_size", 12)
	_feedback_lbl.add_theme_color_override("font_color", Color("#3dba6a"))
	_feedback_lbl.custom_minimum_size = Vector2(0, 22)
	_content_vb.add_child(_feedback_lbl)

	# 선택지
	_choice_vb = VBoxContainer.new()
	_choice_vb.add_theme_constant_override("separation", 7)
	_content_vb.add_child(_choice_vb)

	set_process(true)
	_show_question()

func _show_question() -> void:
	var questions := _get_questions()
	var q: Dictionary = questions[_q_idx]
	_progress_lbl.text = "%d / %d" % [_q_idx + 1, questions.size()]

	_q_lbl.text = q["q"]
	if is_instance_valid(_hint_lbl):
		_hint_lbl.text = q.get("hint", "")
	if is_instance_valid(_feedback_lbl):
		_feedback_lbl.text = ""

	for ch in _choice_vb.get_children():
		ch.queue_free()

	var choices: Array = q["choices"]
	for ci in range(choices.size()):
		var c: Dictionary = choices[ci]
		var btn := _make_btn(c["text"], "#0e1a2e", 13)
		btn.pressed.connect(func(): _on_choose(ci))
		_choice_vb.add_child(btn)

	# 면접 타이머 설정
	if _mode == Mode.INTERVIEW:
		_timer_max = float(q.get("timer", 10.0))
		_timer_left = _timer_max
		_timer_active = true
		if is_instance_valid(_timer_bar):
			_timer_bar.value = 100.0
			# 돌발 질문 표시 (짧은 타이머)
			if q.get("surprise", false):
				_hint_lbl.text = "⚡ 돌발 질문! — %d초 안에 대답하세요" % int(_timer_max)
				_hint_lbl.add_theme_color_override("font_color", Color("#e85d5d"))
			else:
				_hint_lbl.text = "%d초 안에 대답하세요" % int(_timer_max)
				_hint_lbl.add_theme_color_override("font_color", Color("#4a6a7a"))
			# 타이머 바 색상 리셋
			var fill := StyleBoxFlat.new()
			fill.bg_color = Color("#2a7a3a")
			_timer_bar.add_theme_stylebox_override("fill", fill)

func _on_choose(choice_idx: int) -> void:
	if _waiting:
		return
	_timer_active = false

	var questions := _get_questions()
	var q: Dictionary = questions[_q_idx]
	var choice: Dictionary = q["choices"][choice_idx]
	var score: int = int(choice.get("score", 0))
	_total_score += score

	# 피드백 텍스트
	var feedback_text: String
	var feedback_color: String
	match score:
		3:
			feedback_text = "✦ 훌륭한 답변입니다."
			feedback_color = "#f0e040"
			_stress_delta -= 1
		1:
			feedback_text = "○ 무난한 답변입니다."
			feedback_color = "#7a9ab0"
		_:
			feedback_text = "✗ 면접관의 표정이 굳었다."
			feedback_color = "#e85d5d"
			_stress_delta += 1

	if is_instance_valid(_feedback_lbl):
		_feedback_lbl.text = feedback_text
		_feedback_lbl.add_theme_color_override("font_color", Color(feedback_color))

	for ch in _choice_vb.get_children():
		if ch is Button:
			ch.disabled = true

	AudioManager.play("click" if score >= 1 else "money_loss")
	_waiting = true
	_wait_timer = 0.85

func _on_timeout() -> void:
	_timer_active = false
	_stress_delta += 2
	if is_instance_valid(_feedback_lbl):
		_feedback_lbl.text = "⏱ 시간 초과 — 침묵이 흘렀다."
		_feedback_lbl.add_theme_color_override("font_color", Color("#e85d5d"))
	for ch in _choice_vb.get_children():
		if ch is Button:
			ch.disabled = true
	AudioManager.play("money_loss")
	_waiting = true
	_wait_timer = 0.85

# ── 결과 ─────────────────────────────────────────────────────────
func _show_result() -> void:
	set_process(false)
	_clear_content()
	_progress_lbl.text = "완료"

	var questions := _get_questions()
	var max_score: int = questions.size() * 3
	var ratio: float = float(_total_score) / float(max_score)
	var quality: int
	var grade_text: String
	var grade_color: String

	if ratio >= 0.85:
		quality = 3
		grade_text = "우수  ★★★"
		grade_color = "#f0e040"
	elif ratio >= 0.6:
		quality = 2
		grade_text = "양호  ★★"
		grade_color = "#3dba6a"
	elif ratio >= 0.35:
		quality = 1
		grade_text = "무난  ★"
		grade_color = "#7a9ab0"
	else:
		quality = 0
		grade_text = "재작성 필요  ✗"
		grade_color = "#e85d5d"

	AudioManager.play("money_gain" if quality >= 2 else ("click" if quality == 1 else "money_loss"))

	var title_lbl := Label.new()
	title_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_lbl.add_theme_font_size_override("font_size", 15)
	title_lbl.add_theme_color_override("font_color", Color("#5b9cf6"))
	title_lbl.text = "자기소개서 완성" if _mode == Mode.RESUME else "모의 면접 종료"
	_content_vb.add_child(title_lbl)

	var grade_lbl := Label.new()
	grade_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	grade_lbl.add_theme_font_size_override("font_size", 24)
	grade_lbl.add_theme_color_override("font_color", Color(grade_color))
	grade_lbl.text = grade_text
	_content_vb.add_child(grade_lbl)

	var score_lbl := Label.new()
	score_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	score_lbl.add_theme_font_size_override("font_size", 12)
	score_lbl.add_theme_color_override("font_color", Color("#5a6a8a"))
	score_lbl.text = "점수 %d / %d" % [_total_score, max_score]
	_content_vb.add_child(score_lbl)

	# 결과에 따른 설명
	var desc_lbl := Label.new()
	desc_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	desc_lbl.add_theme_font_size_override("font_size", 13)
	desc_lbl.add_theme_color_override("font_color", Color("#9ab0c0"))
	match quality:
		3:
			if _mode == Mode.RESUME:
				desc_lbl.text = "채용 담당자의 눈에 띌 만한 자소서다. 지력과 사회성이 올랐다."
			else:
				desc_lbl.text = "압박에도 흔들리지 않았다. 면접 스킬이 확실히 올랐다."
		2:
			if _mode == Mode.RESUME:
				desc_lbl.text = "부족하진 않다. 서류 통과 가능성이 생겼다."
			else:
				desc_lbl.text = "잘 했지만 아쉬운 부분도 있었다. 연습이 됐다."
		1:
			if _mode == Mode.RESUME:
				desc_lbl.text = "평범한 자소서다. 통과할 수도, 안 될 수도 있다."
			else:
				desc_lbl.text = "실수가 있었다. 그래도 경험이 됐다."
		_:
			if _mode == Mode.RESUME:
				desc_lbl.text = "솔직히 이 자소서로는 서류도 힘들다. 다시 써야 한다."
			else:
				desc_lbl.text = "면접이 많이 힘들었다. 정신이 많이 소모됐다."
	_content_vb.add_child(desc_lbl)

	# 스트레스 표시
	if _stress_delta != 0:
		var stat_lbl := Label.new()
		stat_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		stat_lbl.add_theme_font_size_override("font_size", 11)
		stat_lbl.add_theme_color_override("font_color",
			Color("#e85d5d") if _stress_delta > 0 else Color("#3dba6a"))
		stat_lbl.text = "정신력 %+d" % (-_stress_delta)
		_content_vb.add_child(stat_lbl)

	var ok_btn := _make_btn("확인", "#0e3a2a", 15)
	ok_btn.custom_minimum_size = Vector2(0, 46)
	ok_btn.pressed.connect(func(): _on_finish(quality))
	_content_vb.add_child(ok_btn)

func _on_finish(quality: int) -> void:
	visible = false
	closed.emit(_stress_delta, quality)

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
