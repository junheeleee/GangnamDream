extends Node
## ORDER-834 B2.6 regression: addiction ends in a scene the player answers, not
## a number. The rock bottom comes first at 70, never twice; asking for help
## walks the recovery arc with its authored gaps (one week, a month, a month);
## a relapse or "one more hand" leaves the arc; mourning/finale weeks stay quiet;
## recovery locks the gambling habit calls until a relapse; the father-passed
## run gets the mother's variant and every father-passed variant clears the
## living-father gate (QA 2026-11-27: the variant had copied that gate and the
## rock bottom soft-locked after the father's death); and outside the full story
## addiction 90 still ends the run exactly as before.

const ARC := preload("res://systems/AddictionArc.gd")
const HABIT := preload("res://systems/BranchHabit.gd")

var _failures: Array[String] = []


func _ready() -> void:
	await get_tree().process_frame
	_check_rock_bottom()
	_check_recovery_steps()
	_check_exits_and_rest()
	_check_habit_lock()
	_check_father_variant()
	_check_legacy_game_over()
	if not _failures.is_empty():
		for failure in _failures:
			push_error("ADDICTION_ARC_CHECK_FAIL " + failure)
		get_tree().quit(1)
		return
	print("ADDICTION_ARC_CHECK_OK bottom=3 recovery=4 exits=3 habit_lock=2 father_variant=%d legacy=1" % (1 + EventManager.FATHER_PASSED_EVENT_VARIANTS.size()))
	get_tree().quit(0)


func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)


func _open(_event_id: String) -> bool:
	return true


func _check_rock_bottom() -> void:
	_expect(ARC.take_scene({}, 40, 69, _open) == "", "the rock bottom came before 70")
	var flags := {}
	_expect(ARC.take_scene(flags, 40, 70, _open) == "gambling_rock_bottom",
		"addiction 70 did not bring the rock bottom")
	_expect(ARC.take_scene(flags, 40, 75, _open) == "", "the same week offered a second addiction scene")
	_expect(ARC.take_scene({"hit_rock_bottom": true}, 60, 95, _open) == "",
		"the rock bottom came twice")


func _check_recovery_steps() -> void:
	var flags := {"hit_rock_bottom": true, "in_recovery_started": true}
	flags[ARC.STATE_FLAG] = {"last_turn": 40}
	_expect(ARC.take_scene(flags, 41, 50, _open) == "recovery_first_week",
		"asking for help did not lead to the first week")
	flags["recovery_week_passed"] = true
	flags["recovery_holding"] = true
	_expect(ARC.take_scene(flags, 44, 38, _open) == "", "the relapse test came before a month")
	_expect(ARC.take_scene(flags, 45, 38, _open) == "recovery_relapse_test",
		"the relapse test did not come a month on")
	flags["relapse_tested"] = true
	flags["recovery_proven"] = true
	_expect(ARC.take_scene(flags, 49, 23, _open) == "recovery_one_month_clean",
		"the month-clean calendar did not follow")


func _check_exits_and_rest() -> void:
	var deeper := {"hit_rock_bottom": true, "chose_deeper": true}
	_expect(ARC.take_scene(deeper, 70, 85, _open) == "", "one more hand still walked the recovery arc")
	var relapsed := {"hit_rock_bottom": true, "in_recovery_started": true, "recovery_week_passed": true,
		"recovery_holding": true, "relapse_tested": true, "relapsed": true}
	_expect(ARC.take_scene(relapsed, 90, 70, _open) == "", "a relapse still reached the month-clean scene")
	_expect(ARC.take_scene({}, 190, 80, _open) == "", "the rock bottom interrupted mourning")


func _check_habit_lock() -> void:
	var recovering := {"racetrack_visited": true, "in_recovery_started": true}
	_expect(HABIT.take_scene(recovering, 60, false, [], _open) == "",
		"the track called during recovery")
	var relapsed := {"racetrack_visited": true, "in_recovery_started": true,
		"recovery_holding": true, "relapsed": true}
	_expect(HABIT.take_scene(relapsed, 60, false, [], _open) == "habit_race_saturday",
		"a relapse did not reopen the track's call")


func _check_father_variant() -> void:
	# The confession test reads the Korean source; the saved language (English
	# by default) would otherwise swap in the EN overlay.
	var saved_language := str(LocaleManager.language)
	LocaleManager.set_language("ko")
	var variant_id := str(EventManager.FATHER_PASSED_EVENT_VARIANTS.get("gambling_rock_bottom", ""))
	var base: Dictionary = DataRegistry.find_event("gambling_rock_bottom")
	var variant: Dictionary = DataRegistry.find_event(variant_id)
	var base_choices: Array = base.get("choices", [])
	var variant_choices: Array = variant.get("choices", [])
	_expect(not variant.is_empty() and variant_choices.size() == base_choices.size()
			and str((variant_choices[1] as Dictionary).get("text", "")).contains("어머니")
			and not str((variant_choices[1] as Dictionary).get("result_text", "")).contains("아버지에게 전화")
			and (variant_choices[1] as Dictionary).get("flags", []) == (base_choices[1] as Dictionary).get("flags", []),
		"the father-passed rock bottom does not confess to the mother with the same consequences")
	LocaleManager.set_language(saved_language)
	var saved_passed: Variant = GameState.flags.get("father_passed", null)
	GameState.flags["father_passed"] = true
	for source_id in EventManager.FATHER_PASSED_EVENT_VARIANTS:
		var passed_id := str(EventManager.FATHER_PASSED_EVENT_VARIANTS[source_id])
		_expect(EventManager.call("_event_passes_hard_state_contracts", DataRegistry.find_event(passed_id)),
			"a father-passed variant still requires a living father: %s" % passed_id)
	if saved_passed == null:
		GameState.flags.erase("father_passed")
	else:
		GameState.flags["father_passed"] = saved_passed


func _check_legacy_game_over() -> void:
	var saved: Dictionary = GameState.serialize().duplicate(true)
	GameState.is_game_over = false
	GameState.addiction_tendency = 92
	GameState.flags.erase("chose_deeper")
	GameState.flags.erase("relapsed")
	GameState.check_game_over()
	_expect(GameState.is_game_over, "outside the full story addiction 90 no longer ended the run")
	GameState.call("_restore_serialized_snapshot_exact", saved)
	GameState.is_game_over = false
