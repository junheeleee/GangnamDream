extends Control
## JobHuntMiniGame — 자소서 작성 & 모의 면접 미니게임
## Mode.RESUME : 자소서 문항 선택 (4문항, 채점형)
## Mode.INTERVIEW : 압박 면접 Q&A (타이머 압박, 5문항)
## MainGame이 overlay로 붙이고 open(mode)으로 표시.

signal closed(stress_delta: int, quality: int)
# quality: 0=불합격수준, 1=무난, 2=좋음, 3=우수

enum Mode { RESUME, INTERVIEW }

const COL_BG := "#050506"
const COL_PANEL := "#101012"
const COL_PANEL_SOFT := "#151518"
const COL_LINE := "#303036"
const COL_TEXT := "#e3e3df"
const COL_TEXT_DIM := "#9b9b94"
const COL_TEXT_FAINT := "#666660"
const COL_ACCENT := "#c8c2ad"
const COL_GOOD := "#b7c9b6"
const COL_WARN := "#b9a56a"
const COL_BAD := "#c46f6f"

# ── 자소서 문항 ──────────────────────────────────────────────────
const RESUME_QUESTION_POOL = [
	{
		"q": "지원동기를 서술하시오.",
		"q_en": "Describe your motivation for applying.",
		"hint": "면접관이 가장 먼저 읽는 문항. 진정성이 핵심.",
		"hint_en": "The first answer a recruiter reads. Sincerity matters.",
		"choices": [
			{"text": "단기 일을 이어가며 익힌 현장 대응력을 한 직장에서 오래 쌓아 가고 싶어 지원했습니다.", "text_en": "After a series of short-term jobs, I want to build on the practical skills I've gained and grow over the long term at one company.", "score": 3},
			{"text": "성장 가능성이 있다고 판단해 지원하게 됐습니다.", "text_en": "I applied because I believe this role has growth potential.", "score": 1},
			{"text": "연봉 조건이 괜찮고 집에서 가까워서 지원했습니다.", "text_en": "The salary looked decent, and the office is close to home.", "score": 0},
		]
	},
	{
		"q": "본인의 강점을 구체적인 경험과 함께 서술하시오.",
		"q_en": "Describe your strengths with a concrete example.",
		"hint": "추상적인 단어보다 구체적인 사례가 설득력 있다.",
		"hint_en": "Specific examples are more convincing than vague traits.",
		"choices": [
			{"text": "맡은 시간과 정산을 끝까지 확인하는 습관입니다. 여러 단기 일을 오갈 때도 근무 기록을 빠뜨리지 않았습니다.", "text_en": "My strength is making sure every shift and payment is fully accounted for. Even across short-term jobs, I never missed an entry in my work records.", "score": 3},
			{"text": "성실하고 책임감이 강합니다. 맡은 일은 끝까지 완수합니다.", "text_en": "I am diligent and responsible. I finish whatever I take on.", "score": 1},
			{"text": "특별한 강점은 없지만 열심히 하겠습니다.", "text_en": "I do not have any special strengths, but I will work hard.", "score": 0},
		]
	},
	{
		"q": "단점과 그 극복 과정을 서술하시오.",
		"q_en": "Describe a weakness and how you worked to overcome it.",
		"hint": "단점을 인정하면서 극복 과정까지 보여주는 것이 핵심.",
		"hint_en": "Admit the weakness, then show the process of improvement.",
		"choices": [
			{"text": "당장 갚아야 할 돈부터 처리하느라 장기 계획을 자주 미뤘습니다. 지금은 지원 마감과 지출을 주 단위로 기록하고 있습니다.", "text_en": "I often put off long-term plans because I was focused on debts that had to be paid right away. Now I track application deadlines and expenses week by week.", "score": 3},
			{"text": "완벽주의 성향으로 업무 처리가 느릴 때가 있습니다.", "text_en": "My perfectionism can sometimes slow down my work.", "score": 1},
			{"text": "단점은 딱히 없는 것 같습니다.", "text_en": "I cannot think of any real weaknesses.", "score": 0},
		]
	},
	{
		"q": "입사 후 3년, 5년 포부를 서술하시오.",
		"q_en": "Describe your goals after three and five years at the company.",
		"hint": "구체적인 시간표와 목표가 신뢰감을 준다.",
		"hint_en": "A concrete timeline and goal sound more credible.",
		"choices": [
			{"text": "1년 안에 업무를 익히고, 3년 뒤에는 혼자 프로젝트를 맡겠습니다. 5년 뒤에는 새로 온 동료가 업무를 익도록 도울 수 있는 사람이 되겠습니다.", "text_en": "Within one year I will learn the role, and within three years I will own projects independently. Within five years, I want to be able to help new teammates learn the work.", "score": 3},
			{"text": "열심히 배우며 회사에 기여하겠습니다.", "text_en": "I will work hard to learn and contribute to the company.", "score": 1},
			{"text": "일단 들어가 봐야 알겠습니다.", "text_en": "I won't know until I actually join the company.", "score": 0},
		]
	},
	{
		"q": "팀 내 갈등 상황에서 어떻게 대처하나요?",
		"q_en": "How do you handle conflict within a team?",
		"hint": "갈등 해결 능력과 협업 역량을 보여주는 문항.",
		"hint_en": "This tests conflict resolution and collaboration.",
		"choices": [
			{"text": "먼저 상대방의 입장을 충분히 듣고, 공통된 목표를 기준으로 합의점을 찾습니다.", "text_en": "I first listen to the other person's position, then look for common ground around the team's goal.", "score": 3},
			{"text": "상급자에게 중재를 요청합니다.", "text_en": "I ask a manager to mediate.", "score": 1},
			{"text": "갈등을 피하고 조용히 넘어가려 합니다.", "text_en": "I avoid the conflict and try to move on quietly.", "score": 0},
		]
	},
	{
		"q": "본인의 실패 경험과 그로부터 배운 점을 서술하시오.",
		"q_en": "Describe a failure and what you learned from it.",
		"hint": "실패를 인정하는 용기와 성장 의지를 보여준다.",
		"hint_en": "This shows honesty and a willingness to grow.",
		"choices": [
			{"text": "빚을 갚는 데만 매달려 정규직 준비를 오래 미뤘습니다. 이제는 생계와 지원 일정을 함께 관리하고 있습니다.", "text_en": "I was so focused on paying off debt that I put off preparing for full-time work. Now I manage both living expenses and application deadlines.", "score": 3},
			{"text": "큰 실패는 없었지만 작은 실수에서 배웠습니다.", "text_en": "I have not had a major failure, but I have learned from small mistakes.", "score": 1},
			{"text": "딱히 기억나는 실패가 없습니다.", "text_en": "I cannot really remember any failures.", "score": 0},
		]
	},
	{
		"q": "빠르게 변화하는 업무 환경에 어떻게 적응하나요?",
		"q_en": "How do you adapt to a rapidly changing work environment?",
		"hint": "변화 대응력과 학습 의지를 어필하는 문항.",
		"hint_en": "Show adaptability and a willingness to learn.",
		"choices": [
			{"text": "변화의 핵심을 빠르게 파악하고, 관련 자료와 교육을 스스로 찾아 학습합니다.", "text_en": "I quickly identify what is changing, then seek out relevant resources and training on my own.", "score": 3},
			{"text": "상사나 동료에게 방향을 물어보고 따릅니다.", "text_en": "I ask my manager or coworkers for direction and follow it.", "score": 1},
			{"text": "변화가 안정되기를 기다렸다가 움직입니다.", "text_en": "I wait until the change settles before taking action.", "score": 0},
		]
	},
	{
		"q": "본인이 이 직무에 적합한 이유를 서술하시오.",
		"q_en": "Explain why you are a good fit for this role.",
		"hint": "직무 요건과 나의 경험을 연결하는 것이 핵심.",
		"hint_en": "Connect the role requirements to your experience.",
		"choices": [
			{"text": "공고의 핵심 업무를 단기 현장에서 실제로 해 본 일과 하나씩 연결해 적었습니다.", "text_en": "I matched each core duty in the posting with experience I'd actually gained in short-term roles.", "score": 3},
			{"text": "관련 업무에 관심이 많고 열심히 할 자신이 있습니다.", "text_en": "I'm interested in the work and confident I can work hard.", "score": 1},
			{"text": "다른 곳에서도 비슷한 일을 해봤습니다.", "text_en": "I have done something similar elsewhere.", "score": 0},
		]
	},
]
const RESUME_QUESTIONS_PER_SESSION: int = 4

const INTERVIEW_QUESTION_POOL = [
	{
		"id": "employment_gap",
		"q": "이력서에 6년 공백이 있네요. 설명해 주시겠어요?",
		"q_en": "There is a six-year gap on your resume. Could you explain it?",
		"timer": 10.0, "surprise": false,
		"choices": [
			{"text": "아버지의 보증으로 생긴 가족 빚을 갚느라 일을 이어 갔습니다. 지금은 정리돼 다시 취업을 준비하고 있습니다.", "text_en": "I spent those years working to repay family debt caused by my father's loan guarantee. That debt is settled now, and I'm ready to return to full-time work.", "score": 3},
			{"text": "개인적인 사정이 있었습니다. 이제는 집중할 수 있습니다.", "text_en": "I had some personal circumstances to deal with. I can focus on work now.", "score": 1},
			{"text": "특별한 이유는 없고 그냥 쉬었습니다.", "text_en": "There was no special reason. I just took time off.", "score": 0},
		]
	},
	{
		"q": "저희 회사 지원동기가 무엇인가요?",
		"q_en": "Why did you apply to our company?",
		"timer": 10.0, "surprise": false,
		"choices": [
			{"text": "귀사의 성장세와 사업 방향이 제 커리어 목표와 맞닿아 있어 지원했습니다.", "text_en": "Your company's growth and strategic direction align with my career goals.", "score": 3},
			{"text": "찾아보다가 관심이 생겼습니다. 좋은 회사라고 생각합니다.", "text_en": "I looked into the company and became interested. It seems like a good workplace.", "score": 1},
			{"text": "마침 공고가 떠서 넣어봤습니다.", "text_en": "I just happened to see the posting, so I applied.", "score": 0},
		]
	},
	{
		"q": "5년 후 본인의 모습은 어떨 것 같나요?",
		"q_en": "Where do you see yourself in five years?",
		"timer": 10.0, "surprise": false,
		"choices": [
			{"text": "이 분야의 전문가로서 팀을 이끄는 역할을 하고 싶습니다.", "text_en": "I want to become a specialist in this field and eventually lead a team.", "score": 3},
			{"text": "더 좋은 포지션으로 성장해 있을 것 같습니다.", "text_en": "I think I'll be in a better position by then.", "score": 1},
			{"text": "솔직히 잘 모르겠습니다.", "text_en": "Honestly, I'm not sure.", "score": 0},
		]
	},
	{
		"q": "돌발: 지금 이 자리에서 스스로를 한 단어로 표현한다면?",
		"q_en": "Curveball: If you had to describe yourself in one word right now, what would it be?",
		"timer": 5.0, "surprise": true,
		"choices": [
			{"text": "\"성실함\" — 맡은 일은 반드시 끝내는 사람입니다.", "text_en": "\"Reliable.\" I'm someone who always finishes what I take on.", "score": 3},
			{"text": "(잠시 침묵) \"...열정적인 사람입니다.\"", "text_en": "(After a pause.) \"...Passionate.\"", "score": 1},
			{"text": "(당황) \"...글쎄요... 잘 모르겠습니다.\"", "text_en": "(Flustered.) \"...Well... I'm not sure.\"", "score": 0},
		]
	},
	{
		"q": "마지막으로 하고 싶은 말씀 있으신가요?",
		"q_en": "Is there anything else you'd like to add?",
		"timer": 8.0, "surprise": false,
		"choices": [
			{"text": "오늘 좋은 기회를 주셔서 감사합니다. 합류하게 된다면 최선을 다하겠습니다.", "text_en": "Thank you for the opportunity to interview today. If I have the chance to join the team, I'll give it my best.", "score": 3},
			{"text": "(아무 말도 못 하고 인사만)", "text_en": "(You say nothing and just bow.)", "score": 1},
			{"text": "연봉 협상은 어떻게 되나요?", "text_en": "How does salary negotiation work?", "score": 0},
		]
	},
	{
		"q": "동료가 실수를 했는데 마감이 얼마 안 남았습니다. 어떻게 하겠습니까?",
		"q_en": "A coworker made a mistake and the deadline is close. What would you do?",
		"timer": 10.0, "surprise": false,
		"choices": [
			{"text": "먼저 문제의 범위를 파악하고, 팀과 협력해 최단 시간 내 해결책을 찾겠습니다.", "text_en": "I would first identify the scope of the issue, then work with the team to find the fastest solution.", "score": 3},
			{"text": "상황을 상사에게 즉시 보고하겠습니다.", "text_en": "I would report the situation to my manager immediately.", "score": 1},
			{"text": "그것은 동료의 책임이므로 제 업무에 집중하겠습니다.", "text_en": "That is my coworker's responsibility, so I would focus on my own work.", "score": 0},
		]
	},
	{
		"q": "돌발: 지금 바로 저를 설득해서 제품을 하나 파세요.",
		"q_en": "Curveball: Sell me a product right now.",
		"timer": 5.0, "surprise": true,
		"choices": [
			{"text": "(침착하게) 이 펜은 오늘 하루를 기록하는 도구입니다. 오늘 내린 결정들을 잊고 싶지 않으시죠?", "text_en": "(Calmly.) This pen records your day. You wouldn't want to forget the decisions you made today, would you?", "score": 3},
			{"text": "(당황하며) 음... 이 펜은 잘 써지고 가격도 합리적입니다.", "text_en": "(Flustered.) Well... this pen writes smoothly and the price is reasonable.", "score": 1},
			{"text": "(웃으며 넘김) 저는 영업직 지원자가 아닌데요.", "text_en": "(Laughing it off.) I'm not applying for a sales role.", "score": 0},
		]
	},
	{
		"q": "업무 중 우선순위가 충돌할 때 어떻게 결정하나요?",
		"q_en": "How do you decide when work priorities conflict?",
		"timer": 10.0, "surprise": false,
		"choices": [
			{"text": "긴급도와 중요도를 나눠 정리한 뒤, 팀장과 처리 순서를 확인하겠습니다.", "text_en": "I rank tasks by urgency and importance, then confirm priorities with the team lead.", "score": 3},
			{"text": "먼저 들어온 일을 먼저 처리합니다.", "text_en": "I handle tasks in the order they came in.", "score": 1},
			{"text": "모든 일을 동시에 처리하려 노력합니다.", "text_en": "I try to handle everything at the same time.", "score": 0},
		]
	},
	{
		"q": "최근 해 온 일 가운데 이 직무에 도움이 되는 경험이 있나요?",
		"q_en": "What experience from your recent work would help you in this role?",
		"timer": 10.0, "surprise": false,
		"choices": [
			{"text": "여러 단기 현장에서 손님 응대와 정산을 맡았습니다. 업무가 달라도 인수인계와 마감 확인은 빠뜨리지 않았습니다.", "text_en": "I handled customer service and cash reconciliation at several short-term jobs. Even though the jobs varied, I never skipped a handover or closing check.", "score": 3},
			{"text": "이것저것 해 봤습니다. 들어가면 금방 배울 수 있습니다.", "text_en": "I've done a bit of everything. I can pick things up quickly once I start.", "score": 1},
			{"text": "정규직이 아니어서 도움이 될 만한 경험은 없습니다.", "text_en": "None of it was full-time, so I don't think any of it would help.", "score": 0},
		]
	},
	{
		"q": "공식적인 리더 경험이 없다면, 협업할 때 무엇을 맡았나요?",
		"q_en": "If you haven't held a formal leadership role, what responsibilities did you take on when working with others?",
		"timer": 10.0, "surprise": false,
		"choices": [
			{"text": "교대할 사람이 바로 일할 수 있도록 남은 업무와 정산 내용을 기록해 전달했습니다.", "text_en": "I documented unfinished tasks and payment details so the next person could start right away.", "score": 3},
			{"text": "제 몫을 먼저 끝낸 뒤 바쁜 사람을 도왔습니다.", "text_en": "I finished my share first, then helped whoever was busy.", "score": 1},
			{"text": "제 일만 하면 된다고 생각했습니다.", "text_en": "I thought I only had to worry about my own work.", "score": 0},
		]
	},
]
const INTERVIEW_QUESTIONS_PER_SESSION: int = 5

# ── 상태 ─────────────────────────────────────────────────────────
var current_mode: Mode = Mode.RESUME  # MainGame이 closed 핸들러에서 읽음
var application_submission_mode: bool = false
var _mode: Mode = Mode.RESUME
var _active_questions: Array = []  # 이번 세션에 사용할 랜덤 문항
var _choice_layouts: Array = []  # 문항별 표시 순서. 최고점 답의 위치를 세션 안에서 분산한다.
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
var _choice_vb: BoxContainer
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
				fill.bg_color = Color(COL_BAD)
				_timer_bar.add_theme_stylebox_override("fill", fill)
			elif _timer_left < _timer_max * 0.6:
				var fill := StyleBoxFlat.new()
				fill.bg_color = Color(COL_WARN)
				_timer_bar.add_theme_stylebox_override("fill", fill)
		if _timer_left <= 0.0:
			_on_timeout()

# ── 진입 ─────────────────────────────────────────────────────────
func open(mode: Mode, application_submission: bool = false) -> void:
	BGMPlayer.enter_activity_ambience("office")
	_mode = mode
	current_mode = mode
	application_submission_mode = application_submission \
		and mode == Mode.RESUME
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
		# 면접: 이 게임의 실제 6년 공백 질문과 돌발 문항을 반드시 포함한다.
		var surprises: Array = INTERVIEW_QUESTION_POOL.filter(func(q): return q.get("surprise", false))
		var required: Array = INTERVIEW_QUESTION_POOL.filter(
			func(q): return q.get("id", "") == "employment_gap")
		var normals: Array = INTERVIEW_QUESTION_POOL.filter(
			func(q): return not q.get("surprise", false) \
				and q.get("id", "") != "employment_gap")
		surprises.shuffle()
		normals.shuffle()
		var picked_surprise: Array = surprises.slice(0, 1)
		var picked_normal: Array = normals.slice(
			0, INTERVIEW_QUESTIONS_PER_SESSION - required.size() - 1)
		_active_questions = required + picked_normal + picked_surprise
		_active_questions.shuffle()
	_build_choice_layouts()

	_clear_content()
	visible = true

	match _mode:
		Mode.RESUME:
			_header_lbl.text = LocaleManager.ui("자기소개서 작성", "Resume Writing")
			_start_common()
		Mode.INTERVIEW:
			_header_lbl.text = LocaleManager.ui("모의 면접", "Mock Interview")
			_start_common()

func _get_questions() -> Array:
	return _active_questions

func _build_choice_layouts() -> void:
	_choice_layouts.clear()
	if _active_questions.is_empty():
		return
	var best_slot_offset := randi_range(0, 2)
	for question_index in range(_active_questions.size()):
		var question: Dictionary = _active_questions[question_index]
		var choices: Array = question.get("choices", []).duplicate(true)
		choices.shuffle()
		if choices.size() >= 3:
			var best_index := 0
			var best_score := -1
			for choice_index in range(choices.size()):
				var score := int((choices[choice_index] as Dictionary).get("score", 0))
				if score > best_score:
					best_score = score
					best_index = choice_index
			var target_slot := (question_index + best_slot_offset) % 3
			if best_index != target_slot:
				var displaced = choices[target_slot]
				choices[target_slot] = choices[best_index]
				choices[best_index] = displaced
		_choice_layouts.append(choices)

func _choices_for_question(question_index: int) -> Array:
	if question_index >= 0 and question_index < _choice_layouts.size():
		return _choice_layouts[question_index]
	if question_index >= 0 and question_index < _active_questions.size():
		return (_active_questions[question_index] as Dictionary).get("choices", [])
	return []

func _clear_content() -> void:
	for ch in _content_vb.get_children():
		ch.queue_free()
	_content_vb.alignment = BoxContainer.ALIGNMENT_BEGIN
	_q_lbl = null
	_hint_lbl = null
	_choice_vb = null
	_feedback_lbl = null
	_timer_bar = null

# ── 기반 UI ──────────────────────────────────────────────────────
func _build_base_ui() -> void:
	var bg := ColorRect.new()
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.color = Color(COL_BG)
	add_child(bg)
	_add_room_surface()

	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(center)

	var frame := PanelContainer.new()
	frame.custom_minimum_size = Vector2(980, 520)
	var frame_style := StyleBoxFlat.new()
	frame_style.bg_color = Color(COL_PANEL)
	frame_style.border_color = Color(COL_LINE)
	frame_style.set_border_width_all(1)
	frame_style.set_corner_radius_all(4)
	frame.add_theme_stylebox_override("panel", frame_style)
	center.add_child(frame)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 24)
	margin.add_theme_constant_override("margin_right", 24)
	margin.add_theme_constant_override("margin_top", 20)
	margin.add_theme_constant_override("margin_bottom", 20)
	frame.add_child(margin)

	_root_vb = VBoxContainer.new()
	_root_vb.add_theme_constant_override("separation", 10)
	margin.add_child(_root_vb)

	var hdr := HBoxContainer.new()
	hdr.add_theme_constant_override("separation", 12)
	_root_vb.add_child(hdr)
	_header_lbl = Label.new()
	_header_lbl.text = LocaleManager.ui("취업 준비", "Job Prep")
	_header_lbl.add_theme_font_size_override("font_size", 17)
	_header_lbl.add_theme_color_override("font_color", Color(COL_ACCENT))
	_header_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hdr.add_child(_header_lbl)
	_progress_lbl = Label.new()
	_progress_lbl.add_theme_font_size_override("font_size", 12)
	_progress_lbl.add_theme_color_override("font_color", Color(COL_TEXT_FAINT))
	hdr.add_child(_progress_lbl)

	var sep := HSeparator.new()
	sep.add_theme_color_override("color", Color(COL_LINE))
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
		fill.bg_color = Color("#565d55")
		_timer_bar.add_theme_stylebox_override("fill", fill)
		var bg := StyleBoxFlat.new()
		bg.bg_color = Color("#1a1a1c")
		bg.border_color = Color(COL_LINE)
		bg.set_border_width_all(1)
		_timer_bar.add_theme_stylebox_override("background", bg)
		_content_vb.add_child(_timer_bar)

	_content_vb.add_child(_make_scene_strip())

	# 질문 텍스트
	_q_lbl = Label.new()
	_q_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_q_lbl.add_theme_font_size_override("font_size", 14)
	_q_lbl.add_theme_color_override("font_color", Color(COL_TEXT))
	_q_lbl.custom_minimum_size = Vector2(0, 56)
	_content_vb.add_child(_q_lbl)

	# 힌트 (자소서 모드)
	_hint_lbl = Label.new()
	_hint_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_hint_lbl.add_theme_font_size_override("font_size", 11)
	_hint_lbl.add_theme_color_override("font_color", Color(COL_TEXT_FAINT))
	_hint_lbl.custom_minimum_size = Vector2(0, 18)
	_content_vb.add_child(_hint_lbl)

	# 피드백 (선택 후)
	_feedback_lbl = Label.new()
	_feedback_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_feedback_lbl.add_theme_font_size_override("font_size", 12)
	_feedback_lbl.add_theme_color_override("font_color", Color(COL_GOOD))
	_feedback_lbl.custom_minimum_size = Vector2(0, 22)
	_content_vb.add_child(_feedback_lbl)

	# 선택지
	_choice_vb = HBoxContainer.new()
	_choice_vb.add_theme_constant_override("separation", 10)
	_content_vb.add_child(_choice_vb)

	set_process(true)
	_show_question()

func _show_question() -> void:
	var questions := _get_questions()
	var q: Dictionary = questions[_q_idx]
	_progress_lbl.text = "%d / %d" % [_q_idx + 1, questions.size()]

	_q_lbl.text = _loc(q, "q")
	if is_instance_valid(_hint_lbl):
		_hint_lbl.text = _loc(q, "hint")
	if is_instance_valid(_feedback_lbl):
		_feedback_lbl.text = ""

	for ch in _choice_vb.get_children():
		ch.queue_free()

	var choices: Array = _choices_for_question(_q_idx)
	var choice_buttons: Array[Button] = []
	for ci in range(choices.size()):
		var c: Dictionary = choices[ci]
		var btn := _make_btn("%02d\n%s" % [ci + 1, _loc(c, "text")], COL_PANEL_SOFT, 14)
		btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
		btn.custom_minimum_size = Vector2(0, 132)
		btn.size_flags_vertical = Control.SIZE_EXPAND_FILL
		btn.size_flags_stretch_ratio = 1.0
		btn.pressed.connect(func(): _on_choose(ci))
		btn.mouse_entered.connect(func():
			if btn.visible and not btn.disabled:
				btn.grab_focus()
		)
		_choice_vb.add_child(btn)
		choice_buttons.append(btn)
	_configure_horizontal_focus(choice_buttons)

	# 면접 타이머 설정
	if _mode == Mode.INTERVIEW:
		_timer_max = float(q.get("timer", 10.0))
		_timer_left = _timer_max
		_timer_active = true
		if is_instance_valid(_timer_bar):
			_timer_bar.value = 100.0
			# 돌발 질문 표시 (짧은 타이머)
			if q.get("surprise", false):
				_hint_lbl.text = LocaleManager.ui("압박 질문 — %d초 안에 대답하세요", "Pressure question — answer within %d seconds.") % int(_timer_max)
				_hint_lbl.add_theme_color_override("font_color", Color(COL_BAD))
			else:
				_hint_lbl.text = LocaleManager.ui("%d초 안에 대답하세요", "Answer within %d seconds.") % int(_timer_max)
				_hint_lbl.add_theme_color_override("font_color", Color(COL_TEXT_FAINT))
			# 타이머 바 색상 리셋
			var fill := StyleBoxFlat.new()
			fill.bg_color = Color("#565d55")
			_timer_bar.add_theme_stylebox_override("fill", fill)

func _on_choose(choice_idx: int) -> void:
	if _waiting:
		return
	_timer_active = false

	var questions := _get_questions()
	var choices := _choices_for_question(_q_idx)
	if choice_idx < 0 or choice_idx >= choices.size():
		return
	var choice: Dictionary = choices[choice_idx]
	var score: int = int(choice.get("score", 0))
	_total_score += score

	# 피드백 텍스트
	var feedback_text: String
	var feedback_color: String
	match score:
		3:
			feedback_text = LocaleManager.ui("평가 양호 — 설득력 있는 답변입니다.", "Strong answer — clear and credible.")
			feedback_color = COL_GOOD
			_stress_delta -= 1
		1:
			feedback_text = LocaleManager.ui("평가 보통 — 무난한 답변입니다.", "Acceptable answer — safe, not memorable.")
			feedback_color = COL_TEXT_DIM
		_:
			feedback_text = LocaleManager.ui(
				"평가 미흡 — 내용의 설득력이 부족합니다.",
				"Weak answer — the writing is not convincing."
			) if _mode == Mode.RESUME else LocaleManager.ui(
				"평가 미흡 — 면접관의 표정이 굳었다.",
				"Weak answer — the interviewer goes still."
			)
			feedback_color = COL_BAD
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
		_feedback_lbl.text = LocaleManager.ui("시간 초과 — 침묵이 흘렀다.", "Time out — silence hangs in the room.")
		_feedback_lbl.add_theme_color_override("font_color", Color(COL_BAD))
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
	_content_vb.alignment = BoxContainer.ALIGNMENT_CENTER
	_progress_lbl.text = LocaleManager.ui("완료", "Done")

	var questions := _get_questions()
	var max_score: int = questions.size() * 3
	var ratio: float = float(_total_score) / float(max_score)
	var quality: int
	var grade_text: String
	var grade_color: String

	if ratio >= 0.85:
		quality = 3
		grade_text = LocaleManager.ui("평가 A", "Grade A")
		grade_color = COL_ACCENT
	elif ratio >= 0.6:
		quality = 2
		grade_text = LocaleManager.ui("평가 B", "Grade B")
		grade_color = COL_GOOD
	elif ratio >= 0.35:
		quality = 1
		grade_text = LocaleManager.ui("평가 C", "Grade C")
		grade_color = COL_TEXT_DIM
	else:
		quality = 0
		grade_text = LocaleManager.ui("평가 D", "Grade D")
		grade_color = COL_BAD

	AudioManager.play("money_gain" if quality >= 2 else ("click" if quality == 1 else "money_loss"))

	var title_lbl := Label.new()
	title_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_lbl.add_theme_font_size_override("font_size", 15)
	title_lbl.add_theme_color_override("font_color", Color(COL_ACCENT))
	title_lbl.text = LocaleManager.ui("자기소개서 완성", "Resume Complete") if _mode == Mode.RESUME else LocaleManager.ui("모의 면접 종료", "Mock Interview Complete")
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
	score_lbl.add_theme_color_override("font_color", Color(COL_TEXT_FAINT))
	score_lbl.text = LocaleManager.ui("점수 %d / %d", "Score %d / %d") % [_total_score, max_score]
	_content_vb.add_child(score_lbl)

	# 결과에 따른 설명
	var desc_lbl := Label.new()
	desc_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	desc_lbl.add_theme_font_size_override("font_size", 13)
	desc_lbl.add_theme_color_override("font_color", Color(COL_TEXT_DIM))
	match quality:
		3:
			if _mode == Mode.RESUME:
				desc_lbl.text = LocaleManager.ui("채용 담당자의 눈에 띌 만한 자기소개서다. 지력이 올랐다.", "This resume could catch a recruiter's eye. Intelligence improved.")
			else:
				desc_lbl.text = LocaleManager.ui("압박에도 흔들리지 않았다. 면접 스킬이 확실히 올랐다.", "You stayed steady under pressure. Your interview skill clearly improved.")
		2:
			if _mode == Mode.RESUME:
				desc_lbl.text = LocaleManager.ui("부족하진 않다. 서류 통과 가능성이 생겼다.", "It is not bad. You now have a chance to pass screening.")
			else:
				desc_lbl.text = LocaleManager.ui("잘 했지만 아쉬운 부분도 있었다. 연습이 됐다.", "You did well, though parts were rough. Good practice.")
		1:
			if _mode == Mode.RESUME:
				desc_lbl.text = LocaleManager.ui("평범한 자기소개서다. 통과할 수도, 안 될 수도 있다.", "It is an ordinary resume. It might pass, or it might not.")
			else:
				desc_lbl.text = LocaleManager.ui("실수가 있었다. 그래도 경험이 됐다.", "You made mistakes, but it still counted as experience.")
		_:
			if _mode == Mode.RESUME:
				desc_lbl.text = LocaleManager.ui("솔직히 이 자기소개서로는 서류도 힘들다. 다시 써야 한다.", "Honestly, this resume will struggle to pass screening. Rewrite it.")
			else:
				desc_lbl.text = LocaleManager.ui("면접이 많이 힘들었다. 정신이 많이 소모됐다.", "The interview was rough. It drained you mentally.")
	_content_vb.add_child(desc_lbl)

	# 스트레스 표시
	var final_stress_delta := _final_stress_delta(quality)
	if final_stress_delta != 0:
		var stat_lbl := Label.new()
		stat_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		stat_lbl.add_theme_font_size_override("font_size", 11)
		stat_lbl.add_theme_color_override("font_color",
			Color(COL_BAD) if final_stress_delta > 0 else Color(COL_GOOD))
		stat_lbl.text = LocaleManager.ui(
			"정신력 %+d", "Mental %+d") % (-final_stress_delta)
		_content_vb.add_child(stat_lbl)

	var result_cta := LocaleManager.ui(
		"지원서 검토로", "Review Application") \
		if application_submission_mode else LocaleManager.ui("확인", "Confirm")
	var ok_btn := _make_btn(result_cta, "#20201f", 15)
	ok_btn.custom_minimum_size = Vector2(0, 46)
	ok_btn.pressed.connect(func(): _on_finish(quality))
	_content_vb.add_child(ok_btn)
	ok_btn.call_deferred("grab_focus")

func _on_finish(quality: int) -> void:
	BGMPlayer.leave_activity_ambience("office")
	get_viewport().gui_release_focus()
	visible = false
	closed.emit(_final_stress_delta(quality), quality)

# ── 헬퍼 ─────────────────────────────────────────────────────────
func _final_stress_delta(quality: int) -> int:
	return _stress_delta + (1 if quality == 0 else 0)

func _unhandled_input(event: InputEvent) -> void:
	if not visible or _waiting:
		return
	var joy_south := event is InputEventJoypadButton \
			and (event as InputEventJoypadButton).pressed \
			and int((event as InputEventJoypadButton).button_index) == JOY_BUTTON_A
	if not event.is_action_pressed("ui_accept") and not joy_south:
		return
	var focused := get_viewport().gui_get_focus_owner() as Button
	if focused == null or not is_ancestor_of(focused) or focused.disabled:
		return
	focused.pressed.emit()
	get_viewport().set_input_as_handled()

func _configure_horizontal_focus(buttons: Array[Button]) -> void:
	if buttons.is_empty():
		return
	for index in range(buttons.size()):
		var button := buttons[index]
		var previous := buttons[maxi(0, index - 1)]
		var following := buttons[mini(buttons.size() - 1, index + 1)]
		button.focus_neighbor_left = button.get_path_to(previous)
		button.focus_neighbor_right = button.get_path_to(following)
		button.focus_previous = button.get_path_to(previous)
		button.focus_next = button.get_path_to(following)
	buttons[0].call_deferred("grab_focus")

func _make_btn(text: String, bg_hex: String, font_size: int) -> Button:
	var btn := Button.new()
	btn.text = text
	btn.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var st := StyleBoxFlat.new()
	st.bg_color = Color(bg_hex)
	st.border_color = Color(COL_LINE)
	st.set_border_width_all(1)
	st.set_corner_radius_all(4)
	st.content_margin_left = 14
	st.content_margin_right = 14
	st.content_margin_top = 10
	st.content_margin_bottom = 10
	var hov := st.duplicate()
	hov.bg_color = Color("#202022")
	hov.border_color = Color(COL_TEXT_FAINT)
	var dis := st.duplicate()
	dis.bg_color = st.bg_color.darkened(0.4)
	dis.border_color = Color("#242428")
	btn.add_theme_stylebox_override("normal", st)
	btn.add_theme_stylebox_override("hover", hov)
	btn.add_theme_stylebox_override("pressed", hov)
	btn.add_theme_stylebox_override("disabled", dis)
	btn.add_theme_color_override("font_color", Color(COL_TEXT))
	btn.add_theme_color_override("font_hover_color", Color("#ffffff"))
	btn.add_theme_color_override("font_pressed_color", Color("#ffffff"))
	btn.add_theme_color_override("font_disabled_color", Color(COL_TEXT_FAINT))
	btn.add_theme_font_size_override("font_size", font_size)
	return btn

func _add_room_surface() -> void:
	var layer := Control.new()
	layer.set_anchors_preset(Control.PRESET_FULL_RECT)
	layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(layer)

	var wash := ColorRect.new()
	wash.set_anchors_preset(Control.PRESET_FULL_RECT)
	wash.color = Color("#0b0b0d", 0.64)
	wash.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(wash)

	_add_surface_rect(layer, Vector2(0.12, 0.14), Vector2(0.88, 0.145), Color("#23242a", 0.18))
	_add_surface_rect(layer, Vector2(0.16, 0.22), Vector2(0.84, 0.225), Color("#1a1b20", 0.20))
	_add_surface_rect(layer, Vector2(0.16, 0.78), Vector2(0.84, 0.785), Color("#25201a", 0.26))
	_add_surface_rect(layer, Vector2(0.22, 0.81), Vector2(0.78, 0.815), Color("#191714", 0.34))

	for x in [0.18, 0.34, 0.66, 0.82]:
		_add_surface_rect(layer, Vector2(x, 0.18), Vector2(x, 0.76), Color("#151820", 0.20), Vector2(1, 0))
	for x in [0.27, 0.73]:
		_add_surface_rect(layer, Vector2(x, 0.30), Vector2(x, 0.72), Color("#1f1d18", 0.22), Vector2(2, 0))

	_add_surface_rect(layer, Vector2(0.36, 0.10), Vector2(0.64, 0.105), Color("#c8c2ad", 0.08))
	_add_surface_rect(layer, Vector2(0.38, 0.125), Vector2(0.62, 0.127), Color("#c8c2ad", 0.05))

func _make_scene_strip() -> Panel:
	var strip := Panel.new()
	strip.custom_minimum_size = Vector2(0, 104)
	strip.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	strip.mouse_filter = Control.MOUSE_FILTER_IGNORE
	strip.clip_contents = true
	var st := StyleBoxFlat.new()
	st.bg_color = Color("#0b0b0d")
	st.border_color = Color("#232329")
	st.set_border_width_all(1)
	st.set_corner_radius_all(3)
	strip.add_theme_stylebox_override("panel", st)

	var background_path := "res://assets/ui/job_hunt/mock_interview_strip.png" \
			if _mode == Mode.INTERVIEW \
			else "res://assets/ui/job_hunt/resume_writing_strip.png"
	if ResourceLoader.exists(background_path):
		var scene_image := TextureRect.new()
		scene_image.set_anchors_preset(Control.PRESET_FULL_RECT)
		scene_image.texture = load(background_path)
		scene_image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		scene_image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
		scene_image.mouse_filter = Control.MOUSE_FILTER_IGNORE
		scene_image.modulate = Color(0.92, 0.92, 0.90, 1.0)
		strip.add_child(scene_image)

	var shade := ColorRect.new()
	shade.set_anchors_preset(Control.PRESET_FULL_RECT)
	shade.color = Color("#050506", 0.18 if _mode == Mode.RESUME else 0.24)
	shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	strip.add_child(shade)
	return strip

func _add_surface_rect(parent: Control, start_anchor: Vector2, end_anchor: Vector2, color: Color, offsets: Vector2 = Vector2.ZERO) -> void:
	var rect := ColorRect.new()
	rect.anchor_left = start_anchor.x
	rect.anchor_top = start_anchor.y
	rect.anchor_right = end_anchor.x
	rect.anchor_bottom = end_anchor.y
	rect.offset_left = 0
	rect.offset_top = 0
	rect.offset_right = maxf(1.0, offsets.x)
	rect.offset_bottom = maxf(1.0, offsets.y)
	rect.color = color
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(rect)

func _loc(data: Dictionary, key: String) -> String:
	var en_key := "%s_en" % key
	var korean := str(data.get(key, ""))
	var english := str(data.get(en_key, ""))
	return LocaleManager.ui(korean, english)
