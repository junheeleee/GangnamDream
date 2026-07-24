extends Node
## 관계 stage와 독립된 1·3·5년 초상 앵커를 런타임으로 검증한다.

const EXPECTED_STAGE_BY_TURN := {
	1: "y1",
	96: "y1",
	97: "y3",
	192: "y3",
	193: "y5",
	240: "y5",
}

const CORE_EXPECTATIONS := {
	"daeun_normal": {
		1: "npc_romantic_interest.png",
		97: "npc_daeun_normal_y3.png",
		193: "npc_daeun_normal_y5.png",
	},
	"jiyeon_normal": {
		1: "npc_mentor.png",
		97: "npc_jiyeon_normal_y3.png",
		193: "npc_jiyeon_normal_y5.png",
	},
	"hyunsu_normal": {
		1: "npc_close_friend.png",
		97: "npc_hyunsu_normal_y3.png",
		193: "npc_hyunsu_normal_y5.png",
	},
	"jaehyuk_charisma": {
		1: "npc_jaehyuk.png",
		97: "npc_jaehyuk_normal_y3.png",
		193: "npc_jaehyuk_normal_y5.png",
	},
	"sangchul_normal": {
		1: "npc_boss.png",
		97: "npc_sangchul_normal_y3.png",
		193: "npc_sangchul_normal_y5.png",
	},
	"father_home": {
		1: "npc_father_home.png",
		97: "npc_father_home_y3.png",
		193: "npc_father_home_y5.png",
	},
}

var _failures: Array[String] = []

func _ready() -> void:
	GameState.start_new_game()
	ImageRegistry.reload_cast_visual_years()
	_check_stage_boundaries()
	_check_core_portraits()
	_check_player_job_portraits()
	_check_context_locks()
	_check_relationship_independence()
	if not _failures.is_empty():
		for failure in _failures:
			push_error("CAST_VISUAL_TIME_CHECK_FAIL " + failure)
		get_tree().quit(1)
		return
	print("CAST_VISUAL_TIME_CHECK_OK stages=3 core=7 player_jobs=4 locks=6 relationship_independent=1")
	get_tree().quit(0)

func _check_stage_boundaries() -> void:
	for turn_variant in EXPECTED_STAGE_BY_TURN:
		var turn_value := int(turn_variant)
		var actual := ImageRegistry.get_visual_time_stage(turn_value)
		var expected := str(EXPECTED_STAGE_BY_TURN[turn_variant])
		if actual != expected:
			_fail("turn %d expected stage=%s actual=%s" % [turn_value, expected, actual])

func _check_core_portraits() -> void:
	for portrait_id_variant in CORE_EXPECTATIONS:
		var portrait_id := str(portrait_id_variant)
		var turns: Dictionary = CORE_EXPECTATIONS[portrait_id_variant]
		for turn_variant in turns:
			var turn_value := int(turn_variant)
			var path := ImageRegistry.get_portrait_for_turn(portrait_id, turn_value)
			var expected_file := str(turns[turn_variant])
			if path.is_empty() or not path.ends_with(expected_file):
				_fail("%s turn %d expected=%s actual=%s" % [
					portrait_id, turn_value, expected_file, path])

func _check_player_job_portraits() -> void:
	var states := [
		{
			"job": {},
			"housing": "goshiwon",
			"expected": ["main_character_unemployed.png", "main_character_unemployed_y3.png", "main_character_unemployed_y5.png"],
		},
		{
			"job": {"id": "job_01", "category": "survival", "tier": 1},
			"housing": "goshiwon",
			"expected": ["main_character_part_time.png", "main_character_part_time_y3.png", "main_character_part_time_y5.png"],
		},
		{
			"job": {"id": "job_04", "category": "office", "tier": 2},
			"housing": "oneroom",
			"expected": ["main_character_office.png", "main_character_office_y3.png", "main_character_office_y5.png"],
		},
		{
			"job": {"id": "job_08", "category": "finance", "tier": 3},
			"housing": "apartment",
			"expected": ["main_character_corporate.png", "main_character_corporate_y3.png", "main_character_corporate_y5.png"],
		},
	]
	var turns := [1, 97, 193]
	for state_variant in states:
		var state: Dictionary = state_variant
		GameState.current_job = (state.get("job", {}) as Dictionary).duplicate(true)
		GameState.housing = str(state.get("housing", "goshiwon"))
		var expected: Array = state.get("expected", [])
		for index in range(turns.size()):
			GameState.turn = int(turns[index])
			var path := ImageRegistry.get_portrait("player_normal")
			if path.is_empty() or not path.ends_with(str(expected[index])):
				_fail("player job=%s turn=%d expected=%s actual=%s" % [
					GameState.current_job.get("id", "unemployed"),
					GameState.turn,
					expected[index],
					path,
				])

func _check_context_locks() -> void:
	var fixed_ids := [
		"father_past",
		"father_hospitalized",
		"daeun_sea",
		"jiyeon_first_snow",
		"hyunsu_accounting",
		"player_moral_black",
	]
	for portrait_id in fixed_ids:
		if not ImageRegistry.is_portrait_time_locked(portrait_id):
			_fail("%s is not declared time-locked" % portrait_id)
			continue
		var y1 := ImageRegistry.get_portrait_for_turn(portrait_id, 1)
		var y5 := ImageRegistry.get_portrait_for_turn(portrait_id, 240)
		if y1.is_empty() or y1 != y5:
			_fail("%s changed across time despite context lock: %s -> %s" % [portrait_id, y1, y5])

func _check_relationship_independence() -> void:
	GameState.start_new_game()
	GameState.apply_cast_effect("jiyeon", {"stage": "warm", "affinity": 9, "met": true})
	var before_stage := GameState.get_cast_stage("jiyeon")
	var before_affinity := GameState.get_cast_affinity("jiyeon")
	ImageRegistry.get_portrait_for_turn("jiyeon_normal", 1)
	ImageRegistry.get_portrait_for_turn("jiyeon_normal", 97)
	ImageRegistry.get_portrait_for_turn("jiyeon_normal", 193)
	if GameState.get_cast_stage("jiyeon") != before_stage \
			or GameState.get_cast_affinity("jiyeon") != before_affinity:
		_fail("visual time resolution mutated relationship state")

func _fail(message: String) -> void:
	_failures.append(message)
