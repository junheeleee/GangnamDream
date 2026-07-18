extends Node
## ORDER-23: 프롤로그의 세 선택과 수첩 문장이 이후 플레이에 남는지 검증한다.

const MainGameScript = preload("res://scenes/MainGame.gd")

const CHAIN := {
	"story_arrival": "story_knee_door",
	"story_knee_door": "story_knee_witness",
	"story_knee_witness": "story_knee_choice",
	"story_knee_choice": "story_last_payment_wait",
	"story_last_payment_wait": "story_last_payment_word",
	"story_last_payment_word": "story_last_payment_exit",
	"story_last_payment_exit": "story_prologue_dad",
	"story_prologue_dad": "story_prologue_goal",
	"story_prologue_goal": "story_prologue_meal",
}
const IDENTITY_FLAGS := {
	"story_knee_choice": ["knee_day_faced", "knee_day_froze", "knee_day_turned"],
	"story_last_payment_word": ["last_payment_endured", "last_payment_spoke", "last_payment_smiled"],
	"story_prologue_goal": ["notebook_motive_family", "notebook_motive_proof", "notebook_motive_survival"],
}
const MOTIVE_SENTENCES_KO := {
	"notebook_motive_family": "아버지가 그 거실에 서는 걸 본다",
	"notebook_motive_proof": "우리를 무너뜨린 세계에 내 이름으로 선다",
	"notebook_motive_survival": "다시는 돈 앞에 무릎 꿇지 않는다",
}
const MEMORY_READERS := {
	"arc_father_06_confession": ["knee_day_faced", "knee_day_froze", "knee_day_turned"],
	"arc_sangchul_confrontation": ["knee_day_faced", "knee_day_froze", "knee_day_turned"],
	"amb_guarantee_00": ["last_payment_endured", "last_payment_spoke", "last_payment_smiled"],
}

var _failures: Array[String] = []
var _original_language := "ko"

func _ready() -> void:
	_original_language = LocaleManager.language
	_check_chain_and_identity_choices()
	_check_memory_readers()
	_check_notebook_recall()
	_check_demo_father_contacts()
	LocaleManager.language = _original_language
	DataRegistry.reload()
	if not _failures.is_empty():
		for failure in _failures:
			push_error("MOTIVATION_IMPRINT_FAIL " + failure)
		get_tree().quit(1)
		return
	print("MOTIVATION_IMPRINT_OK chain=9 identity=9 readers=9 motives=3 father_contacts=3")
	get_tree().quit(0)

func _check_chain_and_identity_choices() -> void:
	LocaleManager.language = "ko"
	DataRegistry.reload()
	for event_id in CHAIN:
		var event: Dictionary = DataRegistry.find_event(event_id)
		_expect(not event.is_empty(), "missing prologue event %s" % event_id)
		if event.is_empty():
			continue
		var choices: Array = event.get("choices", [])
		_expect(not choices.is_empty(), "prologue event has no choice: %s" % event_id)
		for choice in choices:
			_expect(str(choice.get("follow_up_event", "")) == str(CHAIN[event_id]),
				"%s does not lead to %s" % [event_id, CHAIN[event_id]])

	for event_id in IDENTITY_FLAGS:
		var event: Dictionary = DataRegistry.find_event(event_id)
		var choices: Array = event.get("choices", [])
		var expected_flags: Array = IDENTITY_FLAGS[event_id]
		_expect(choices.size() == 3, "%s must have exactly three identity choices" % event_id)
		if choices.size() != expected_flags.size():
			continue
		for index in range(choices.size()):
			GameState.start_new_game()
			GameState.apply_choice(event, choices[index])
			var expected_flag := str(expected_flags[index])
			_expect(bool(GameState.flags.get(expected_flag, false)),
				"%s choice %d did not set %s" % [event_id, index, expected_flag])
			var saved: Dictionary = GameState.serialize()
			GameState.start_new_game()
			GameState.load_from_dict(saved)
			_expect(bool(GameState.flags.get(expected_flag, false)),
				"%s did not survive save/load" % expected_flag)

func _check_memory_readers() -> void:
	for language in ["ko", "en"]:
		LocaleManager.language = language
		DataRegistry.reload()
		for event_id in MEMORY_READERS:
			var event: Dictionary = DataRegistry.find_event(event_id)
			var memory_map: Dictionary = event.get("description_memory_if_known", {})
			for raw_flag in MEMORY_READERS[event_id]:
				var flag := str(raw_flag)
				var text := str(memory_map.get(flag, "")).strip_edges()
				_expect(not text.is_empty(), "%s lacks memory reader %s (%s)" % [event_id, flag, language])
				if language == "en":
					_expect(not _contains_hangul(text), "%s English memory leaked Hangul: %s" % [event_id, flag])

func _check_notebook_recall() -> void:
	var game = MainGameScript.new()
	for flag in MOTIVE_SENTENCES_KO:
		GameState.start_new_game()
		GameState.flags[flag] = true
		GameState.turn = 13
		LocaleManager.language = "ko"
		var sentence_ko := str(game._notebook_motive_sentence())
		_expect(sentence_ko == str(MOTIVE_SENTENCES_KO[flag]), "Korean notebook sentence mismatch for %s" % flag)
		var ritual_ko := str(game._notebook_ritual_line())
		_expect(ritual_ko.contains(sentence_ko) and ritual_ko.contains("3개월째"),
			"Korean notebook ritual lost sentence or month: %s" % ritual_ko)
		var saved: Dictionary = GameState.serialize()
		GameState.start_new_game()
		GameState.load_from_dict(saved)
		_expect(str(game._notebook_motive_sentence()) == sentence_ko,
			"notebook motive did not survive save/load: %s" % flag)

		LocaleManager.language = "en"
		var sentence_en := str(game._notebook_motive_sentence())
		var ritual_en := str(game._notebook_ritual_line())
		_expect(not sentence_en.is_empty() and not _contains_hangul(sentence_en),
			"English notebook sentence is missing or leaked Hangul: %s" % sentence_en)
		_expect(ritual_en.contains(sentence_en) and ritual_en.contains("Month 3"),
			"English notebook ritual lost sentence or month: %s" % ritual_en)
	game.free()

func _check_demo_father_contacts() -> void:
	var fixtures := [
		{"turn": 14, "unset": "arc_father_01_seen", "expected": "arc_father_01_call"},
		{"turn": 16, "unset": "arc_father_quiet_call_seen", "expected": "arc_father_quiet_call"},
		{"turn": 21, "unset": "arc_father_02_done", "expected": "arc_father_02_signal"},
	]
	var game = MainGameScript.new()
	var had_father_meta := MetaProgression.meta.has("father_passed_ever")
	var father_meta_before: Variant = MetaProgression.meta.get("father_passed_ever", false)
	MetaProgression.meta["father_passed_ever"] = false
	for fixture in fixtures:
		GameState.start_new_game()
		_mark_completion_flags()
		GameState.turn = int(fixture["turn"])
		GameState.flags.erase(str(fixture["unset"]))
		var actual := str(game._next_arc_id(GameState.turn, true))
		_expect(actual == str(fixture["expected"]),
			"week %d father contact expected=%s actual=%s" % [fixture["turn"], fixture["expected"], actual])
	if had_father_meta:
		MetaProgression.meta["father_passed_ever"] = father_meta_before
	else:
		MetaProgression.meta.erase("father_passed_ever")
	game.free()

func _mark_completion_flags() -> void:
	for event in DataRegistry.get_all_events():
		for choice in event.get("choices", []):
			for raw_flag in choice.get("flags", []):
				var flag := str(raw_flag)
				if flag.ends_with("_seen") or flag.ends_with("_done") or flag.ends_with("_closed"):
					GameState.flags[flag] = true
	GameState.flags["prologue_done"] = true
	GameState.flags["arc_daeun_met"] = true

func _contains_hangul(text: String) -> bool:
	var regex := RegEx.new()
	regex.compile("[가-힣]")
	return regex.search(text) != null

func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)
