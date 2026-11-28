extends Node
## `daeun_married` means Minjun's own engagement with Daeun. A released Daeun's
## wedding photo (arc_daeun_year3_apart) used to write the same flag, so the
## 2026-11-26 D1 re-measure saw two runs let her go at W85, see her wedding
## photo at W102, then replay Minjun's own engagement/wedding arc with her from
## W155 and end in with_daeun. The photo now has its own receipt, its echo reads
## that receipt, and loading an old polluted save drops the alias.

var _failures: Array[String] = []


func _ready() -> void:
	await get_tree().process_frame
	_check_content()
	_check_save_migration()
	if not _failures.is_empty():
		for failure in _failures:
			push_error("DAEUN_MARRIED_MEANING_CHECK_FAIL " + failure)
		get_tree().quit(1)
		return
	print("DAEUN_MARRIED_MEANING_CHECK_OK content=3 migration=4")
	get_tree().quit(0)


func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)


func _choice_flags(event_id: String, index: int) -> Array:
	var event: Dictionary = DataRegistry.find_event(event_id)
	var choices: Array = event.get("choices", [])
	if index >= choices.size():
		return []
	return (choices[index] as Dictionary).get("flags", [])


func _check_content() -> void:
	var apart: Dictionary = DataRegistry.find_event("arc_daeun_year3_apart")
	_expect(not apart.is_empty(), "arc_daeun_year3_apart is missing")
	for index in (apart.get("choices", []) as Array).size():
		var flags := _choice_flags("arc_daeun_year3_apart", index)
		_expect("arc_daeun_year3_apart_seen" in flags and not "daeun_married" in flags,
			"Daeun's wedding photo choice %d still claims Minjun married her" % index)
	var echo: Dictionary = DataRegistry.find_event("callback_daeun_married_echo")
	_expect(str((echo.get("conditions", {}) as Dictionary).get("flag", "")) == "arc_daeun_year3_apart_seen",
		"the wedding-photo echo no longer reads the photo receipt")
	var engaged := false
	var proposal: Dictionary = DataRegistry.find_event("arc_daeun_proposal_answer")
	for index in (proposal.get("choices", []) as Array).size():
		if "daeun_married" in _choice_flags("arc_daeun_proposal_answer", index):
			engaged = true
	_expect(engaged, "the proposal no longer records Minjun's engagement")


func _round_trip(flags: Dictionary) -> Dictionary:
	GameState.start_new_game()
	for key in flags.keys():
		GameState.flags[key] = flags[key]
	var save: Dictionary = GameState.serialize().duplicate(true)
	GameState.start_new_game()
	GameState.load_from_dict(save)
	return GameState.flags


func _check_save_migration() -> void:
	var polluted := _round_trip({"daeun_let_her_go": true, "arc_daeun_year3_apart_seen": true,
		"daeun_married": true})
	_expect(not bool(polluted.get("daeun_married", false)) and bool(polluted.get("arc_daeun_year3_apart_seen", false)),
		"a released-Daeun save kept the polluted marriage flag")
	var engaged := _round_trip({"arc_daeun_proposal_seen": true, "daeun_married": true})
	_expect(bool(engaged.get("daeun_married", false)), "a real engagement lost its flag on load")
	var both := _round_trip({"arc_daeun_year3_apart_seen": true, "arc_daeun_proposal_seen": true,
		"daeun_married": true})
	_expect(bool(both.get("daeun_married", false)), "an engagement after the photo lost its flag on load")
	var underway := _round_trip({"arc_daeun_year3_apart_seen": true, "arc_daeun_our_home_seen": true,
		"daeun_married": true})
	_expect(bool(underway.get("daeun_married", false)),
		"a save already inside the married arc was cut mid-chain")
