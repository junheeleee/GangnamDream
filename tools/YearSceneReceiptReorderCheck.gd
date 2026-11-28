extends Node
## W240 soft-lock regression (838 D1 policy runs, 2026-11-24).
##
## The year-5 curation (arc_year5_scene, W236) stores a read receipt with the
## chosen row index and scene. Its rows are rebuilt from the scenes seen in that
## year, and W240 always adds arc_final_countdown, which can reorder them. The
## old receipt check compared the saved scene with the *live* row at the saved
## index, so a legitimate receipt read as tampered, FullStoryFlow.valid_session()
## turned false, close_result() refused the countdown result and the run never
## reached its ending (3 of 6 policy runs). The fixture below is the real year-5
## seen list of one of those runs.

const FULL_STORY_FLOW := preload("res://systems/FullStoryFlow.gd")
const YEAR5_SEEN: Array[String] = [
	"chapter_card_37", "arc_37_reckoning", "arc_final_year_start",
	"arc_daeun_year5_apart", "arc_daeun_wedding_day", "arc_daeun_wedding_groom_side",
	"arc_daeun_wedding_walk", "arc_daeun_wedding_aisle", "arc_daeun_wedding_night",
	"arc_daeun_wedding_night_honest", "arc_daeun_wedding_night_choice",
	"hyunsu_year5_call", "arc_minseo_03b_not_arrived", "arc_37_burn_or_light",
	"age_39_final", "arc_endgame_sixmonths", "arc_37_ending_peace",
	"arc_daeun_final_choice", "arc_daeun_final_choice_name",
	"arc_daeun_final_choice_decision", "arc_pre_ending_winter",
	"arc_pre_ending_father_call", "arc_year5_scene",
]
const CURATION_EVENT := "arc_year5_scene"
const CURATION_TURN := 236

var _failures: Array[String] = []


func _ready() -> void:
	await get_tree().process_frame
	_check_receipt_survives_reorder()
	if not _failures.is_empty():
		for failure in _failures:
			push_error("YEAR_SCENE_RECEIPT_REORDER_CHECK_FAIL " + failure)
		get_tree().quit(1)
		return
	print("YEAR_SCENE_RECEIPT_REORDER_CHECK_OK reordered=1 survives=1 rejects=7")
	get_tree().quit(0)


func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)


func _check_receipt_survives_reorder() -> void:
	GameState.start_new_game()
	GameState.turn = CURATION_TURN
	GameState.flags[FULL_STORY_FLOW.STATE_KEY] = {"profile": FULL_STORY_FLOW.PROFILE_FULL}
	GameState.run_seen_scenes_by_year["5"] = YEAR5_SEEN.duplicate()
	var event: Dictionary = DataRegistry.find_event(CURATION_EVENT)
	_expect(int(event.get("year_scene_year", 0)) == 5,
		"fixture event lost its year-5 curation identity")
	var rows := GameState.build_year_scene_choices(5)
	_expect(rows.size() == 4, "year-5 curation no longer offers four rows")
	if rows.size() != 4:
		return
	var index := 3
	var scene_id := str((rows[index] as Dictionary)["year_scene"]["scene_id"])
	_expect(GameState.record_year_scene(5, scene_id), "fixture could not record its year-5 scene")
	GameState.event_log.append({
		"turn": CURATION_TURN, "event_id": CURATION_EVENT,
		"choice_index": index, "choice": "", "result": "",
	})
	GameState.events_seen = GameState.event_log.size()
	var receipt := {
		"turn": CURATION_TURN,
		"event_id": CURATION_EVENT,
		"choice_index": index,
		"expression": false,
		"applied_tuple": {"turn": CURATION_TURN, "event_id": CURATION_EVENT, "choice_index": index},
		"applied_sequence": GameState.events_seen,
		"year_scene": {"year": 5, "scene_id": scene_id},
	}
	_expect(FULL_STORY_FLOW._valid_read_record(receipt, CURATION_TURN),
		"fresh year-5 curation receipt was rejected")

	# W240: the countdown is always seen after the curation.
	GameState.turn = 240
	GameState.record_run_scene_seen("arc_final_countdown")
	var rebuilt := GameState.build_year_scene_choices(5)
	_expect(rebuilt.size() == 4 \
			and str((rebuilt[index] as Dictionary)["year_scene"]["scene_id"]) != scene_id,
		"fixture no longer reorders the chosen row; the check would prove nothing")
	_expect(FULL_STORY_FLOW._valid_read_record(receipt, CURATION_TURN),
		"W236 year-5 receipt read as tampered after W240 reordered the rows (ending soft-lock)")

	for bad_year_scene in [
		{"year": 4, "scene_id": scene_id},
		{"year": 5.5, "scene_id": scene_id},
		{"year": true, "scene_id": scene_id},
		{"year": "5", "scene_id": scene_id},
		{"year": 5, "scene_id": "order838_wrong_scene"},
		{"year": 5, "scene_id": scene_id, "extra": true},
	]:
		var damaged := receipt.duplicate(true)
		damaged["year_scene"] = bad_year_scene
		_expect(not FULL_STORY_FLOW._valid_read_record(damaged, CURATION_TURN),
			"year-5 receipt accepted a wrong/type-bad/extra-field binding: %s" % [bad_year_scene])
	var chosen := GameState.get_year_scene_selection(5)
	GameState.year_scenes["year_scene_5"] = str((rebuilt[index] as Dictionary)["year_scene"]["scene_id"])
	_expect(not FULL_STORY_FLOW._valid_read_record(receipt, CURATION_TURN),
		"year-5 receipt accepted a scene other than the recorded selection")
	GameState.year_scenes["year_scene_5"] = chosen
