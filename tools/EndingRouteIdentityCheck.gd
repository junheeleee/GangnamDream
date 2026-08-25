extends Node
## 종결 자산이 같아도 5년 동안 실제로 걸은 전략이 고유 결산으로 이어지는지 실행한다.

var _failures: Array[String] = []
var _received_endings: Array[String] = []

func _ready() -> void:
	GameState.game_over.connect(_on_game_over)
	_check_startup_before_generic_gangnam()
	_check_first_year_gangnam_is_instant_legend()
	_check_generic_gangnam_waits_for_final_week()
	_check_full_circle_waits_for_final_week()
	_check_father_passed_gangnam_is_empty_house()
	_check_father_passed_blocks_late_call()
	_check_daeun_reckoning_blocks_instant_gangnam()
	_check_failure_stays_immediate_after_goal()
	_check_committed_investor_before_career()
	_check_uncommitted_investor_stays_career()
	_check_legacy_investment_master_path()
	_check_orthodox_before_career()
	_check_unorthodox_before_career()
	_check_balanced_before_career()
	_check_plain_career_fallback()
	if not _failures.is_empty():
		for failure in _failures:
			push_error("ENDING_ROUTE_IDENTITY_CHECK_FAIL " + failure)
		get_tree().quit(1)
		return
	print("ENDING_ROUTE_IDENTITY_CHECK_OK cases=15")
	get_tree().quit(0)

func _prepare_case(age_value: int = 38) -> void:
	MetaProgression.data = DataRegistry.default_meta.duplicate(true)
	MetaProgression._new_this_run = {"achievements": []}
	GameState.start_new_game()
	GameState.age = age_value
	GameState.money = 0.0
	GameState.portfolio = {}
	GameState.loans = {"bank": 0.0, "second": 0.0}
	GameState.reputation = 5
	GameState.health = 65
	GameState.mental = 60
	GameState.route_orthodox = 0
	GameState.route_unorthodox = 0
	GameState.investment_skill = 15
	GameState.tendency_realized = ""
	GameState.current_job = {}
	GameState.flags = {}
	GameState.relationships = []

func _set_tier_four_job() -> void:
	GameState.current_job = {"id": "job_08", "name": "route fixture", "tier": 4}
	GameState.flags["max_job_tier"] = 4

func _expect_route(label: String, expected: String) -> void:
	var before := _received_endings.size()
	GameState.check_game_over()
	if _received_endings.size() != before + 1:
		_failures.append("%s emitted %d endings instead of one" % [label, _received_endings.size() - before])
		return
	var actual := _received_endings[-1]
	if actual != expected:
		_failures.append("%s routed to %s instead of %s" % [label, actual, expected])

func _expect_no_route(label: String) -> void:
	var before := _received_endings.size()
	GameState.check_game_over()
	if _received_endings.size() != before:
		_failures.append("%s emitted an ending before the finale" % label)
	if GameState.is_game_over:
		_failures.append("%s marked the run over before the finale" % label)

func _check_startup_before_generic_gangnam() -> void:
	_prepare_case(34)
	GameState.money = 3_200_000_000.0
	GameState.flags["startup_exit"] = true
	_expect_route("startup acquisition", "startup_exit")

func _check_first_year_gangnam_is_instant_legend() -> void:
	_prepare_case(33)
	GameState.turn = 48
	GameState.money = 3_200_000_000.0
	MetaProgression.data["sangchul_truth_ever_known"] = true
	GameState.flags["father_reconciled"] = true
	GameState.flags["cleared_father_debt_from_sangchul"] = true
	_expect_route("first-year 3B arrival", "instant_legend")

func _check_generic_gangnam_waits_for_final_week() -> void:
	_prepare_case(34)
	GameState.turn = 49
	GameState.money = 3_200_000_000.0
	GameState.cast["father"]["affinity"] = 60
	_expect_no_route("ordinary 3B arrival")
	if GameState.peak_asset < GameState.GANGNAM_TARGET:
		_failures.append("ordinary 3B arrival did not persist its peak achievement")
	var goal_snapshot: Dictionary = GameState.serialize().duplicate(true)
	GameState.start_new_game()
	GameState.load_from_dict(goal_snapshot)
	if GameState.peak_asset < GameState.GANGNAM_TARGET:
		_failures.append("ordinary 3B achievement did not survive serialization")
	GameState.money = 2_500_000_000.0
	_expect_no_route("post-goal asset decline")
	GameState.turn = 240
	GameState.age = 37
	GameState.flags["arc_final_week_seen"] = true
	_expect_route("ordinary 3B finale after decline", "gangnam_dream")

func _check_full_circle_waits_for_final_week() -> void:
	_prepare_case(34)
	GameState.turn = 49
	GameState.money = 3_200_000_000.0
	MetaProgression.data["sangchul_truth_ever_known"] = true
	GameState.flags["father_reconciled"] = true
	GameState.flags["cleared_father_debt_from_sangchul"] = true
	_expect_no_route("full-circle 3B arrival")
	GameState.turn = 240
	GameState.age = 37
	GameState.flags["arc_final_week_seen"] = true
	_expect_route("full-circle finale", "full_circle")

func _check_father_passed_gangnam_is_empty_house() -> void:
	_prepare_case(34)
	GameState.money = 3_200_000_000.0
	GameState.flags["father_passed"] = true
	GameState.flags["father_reconciled"] = true
	GameState.flags["arc_final_week_seen"] = true
	GameState.cast["father"]["affinity"] = 60
	_expect_route("3B arrival after father passed", "empty_house")

func _check_father_passed_blocks_late_call() -> void:
	_prepare_case()
	GameState.flags["father_reconciled"] = true
	GameState.flags["father_passed"] = true
	_expect_route("reconciled father already passed", "ordinary_life")

func _check_daeun_reckoning_blocks_instant_gangnam() -> void:
	_prepare_case(34)
	GameState.money = 3_200_000_000.0
	GameState.flags["daeun_married"] = true
	GameState.flags["used_daeun_as_means"] = true
	GameState.flags["arc_final_week_seen"] = true
	var before := _received_endings.size()
	GameState.check_game_over()
	if _received_endings.size() != before or GameState.is_game_over:
		_failures.append("3B arrival bypassed Daeun's pending final reckoning")
	GameState.flags["arc_daeun_final_choice_seen"] = true
	_expect_route("3B arrival after Daeun reckoning", "gangnam_dream")

func _check_failure_stays_immediate_after_goal() -> void:
	_prepare_case(34)
	GameState.money = 3_200_000_000.0
	GameState.health = 0
	_expect_route("fatal health after 3B arrival", "burnout")
	_prepare_case(34)
	GameState.mental = 0
	_expect_route("fatal mental state", "mental_break")
	_prepare_case(34)
	GameState.money = -150_000_000.0
	_expect_route("bankruptcy threshold", "bankruptcy")
	_prepare_case(34)
	GameState.money = -250_000_000.0
	_expect_route("debt spiral threshold", "debt_spiral")
	_prepare_case(34)
	GameState.addiction_tendency = 90
	_expect_route("addiction threshold", "crypto_ghost")

func _check_committed_investor_before_career() -> void:
	_prepare_case()
	GameState.money = 188_000_000.0
	GameState.investment_skill = 90
	GameState.tendency_realized = "invest"
	GameState.route_orthodox = 5
	GameState.route_unorthodox = 40
	_set_tier_four_job()
	_expect_route("committed investor", "investment_master")

func _check_uncommitted_investor_stays_career() -> void:
	_prepare_case()
	GameState.money = 188_000_000.0
	GameState.investment_skill = 80
	GameState.tendency_realized = "invest"
	GameState.route_orthodox = 5
	GameState.route_unorthodox = 40
	_set_tier_four_job()
	_expect_route("investor below mastery", "career_climber")

func _check_legacy_investment_master_path() -> void:
	_prepare_case()
	GameState.money = 500_000_000.0
	GameState.investment_skill = 55
	GameState.route_unorthodox = 10
	_set_tier_four_job()
	_expect_route("legacy 500M investor", "investment_master")

func _check_orthodox_before_career() -> void:
	_prepare_case()
	GameState.money = 1_000_000_000.0
	GameState.route_orthodox = 40
	GameState.route_unorthodox = 5
	_set_tier_four_job()
	_expect_route("orthodox strategy", "orthodox_pinnacle")

func _check_unorthodox_before_career() -> void:
	_prepare_case()
	GameState.money = 500_000_000.0
	GameState.route_orthodox = 5
	GameState.route_unorthodox = 40
	_set_tier_four_job()
	_expect_route("unorthodox strategy", "unorthodox_legend")

func _check_balanced_before_career() -> void:
	_prepare_case()
	GameState.money = 150_000_000.0
	GameState.route_orthodox = 20
	GameState.route_unorthodox = 18
	_set_tier_four_job()
	_expect_route("balanced strategy", "balanced_life")

func _check_plain_career_fallback() -> void:
	_prepare_case()
	GameState.money = 150_000_000.0
	GameState.route_orthodox = 10
	GameState.route_unorthodox = 0
	_set_tier_four_job()
	_expect_route("plain career", "career_climber")

func _on_game_over(ending_id: String) -> void:
	_received_endings.append(ending_id)
