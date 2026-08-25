extends Node
## 종결 자산이 같아도 5년 동안 실제로 걸은 전략이 고유 결산으로 이어지는지 실행한다.

var _failures: Array[String] = []
var _received_endings: Array[String] = []

const FINAL_SIGNATURE_APPLY_IDS := [
	"gangnam_dream", "empty_house", "with_daeun", "jiyeon_man", "jaehyuk_way",
	"late_call", "stable_success", "ordinary_life", "lonely_rich", "investment_master",
	"reputation_legend", "healthy_retirement", "orthodox_pinnacle", "orthodox_hollow",
	"balanced_life", "unorthodox_legend", "early_retirement", "full_circle",
	"gangnam_dream_white", "gambling_recovery", "career_climber", "career_burnout",
	"sangchul_reckoning", "writer",
]

const FINAL_SIGNATURE_EXCLUDED_IDS := [
	"burnout", "mental_break", "bankruptcy", "crypto_ghost", "debt_spiral",
	"instant_legend", "startup_exit", "second_love", "guardian", "creator_success",
	"political_fix",
]

const FINAL_SIGNATURE_CASES := {
	"final_signature_owned": "owned",
	"final_signature_collateral": "collateral",
	"final_signature_people": "people",
}

func _ready() -> void:
	GameState.game_over.connect(_on_game_over)
	_check_final_signature_coda_contract()
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
	print("ENDING_ROUTE_IDENTITY_CHECK_OK routes=15 coda_apply=72 coda_excluded=33")
	get_tree().quit(0)


func _check_final_signature_coda_contract() -> void:
	var expected_ids: Array[String] = []
	expected_ids.append_array(FINAL_SIGNATURE_APPLY_IDS)
	expected_ids.append_array(FINAL_SIGNATURE_EXCLUDED_IDS)
	expected_ids.sort()
	var catalog_ids: Array[String] = []
	var seen_ids: Dictionary = {}
	var seen_cgs: Dictionary = {}
	for ending_variant in DataRegistry.endings:
		if not ending_variant is Dictionary:
			_failures.append("ending catalog contains a non-Dictionary row")
			continue
		var ending: Dictionary = ending_variant
		var ending_id := str(ending.get("id", ""))
		var cg_id := str(ending.get("cg", ""))
		if seen_ids.has(ending_id):
			_failures.append("ending catalog duplicated id %s" % ending_id)
		seen_ids[ending_id] = true
		catalog_ids.append(ending_id)
		if cg_id != "cg_ending_%s" % ending_id:
			_failures.append("%s changed its dedicated CG id to %s" % [ending_id, cg_id])
		if seen_cgs.has(cg_id):
			_failures.append("ending catalog shared CG %s" % cg_id)
		seen_cgs[cg_id] = true
	catalog_ids.sort()
	if catalog_ids != expected_ids:
		_failures.append("final-signature 24/11 partition does not equal the 35 ending catalog")

	var applied := 0
	var excluded := 0
	for ending_id in expected_ids:
		for flag_id: String in FINAL_SIGNATURE_CASES:
			var input_flags := {flag_id: true, "unrelated_run_fact": true}
			var before := input_flags.duplicate(true)
			var coda: Dictionary = EndingSystem.final_signature_coda(ending_id, input_flags)
			if input_flags != before:
				_failures.append("%s/%s mutated the run flags" % [ending_id, flag_id])
			if ending_id in FINAL_SIGNATURE_APPLY_IDS:
				applied += 1
				_check_signature_payload(ending_id, flag_id, coda)
			else:
				excluded += 1
				if not coda.is_empty():
					_failures.append("excluded ending %s returned %s" % [ending_id, flag_id])
	if applied != 72 or excluded != 33:
		_failures.append("final-signature matrix drifted apply=%d excluded=%d" % [applied, excluded])

	var invalid_cases: Array = [
		["unknown_ending", {"final_signature_owned": true}],
		["ordinary_life", {}],
		["ordinary_life", {"final_signature_owned": false}],
		["ordinary_life", {"final_signature_owned": true, "final_signature_people": true}],
		["ordinary_life", {
			"final_signature_owned": true,
			"final_signature_collateral": true,
			"final_signature_people": true,
		}],
		["ordinary_life", {"final_signature_unknown": true}],
		["ordinary_life", {
			"final_signature_owned": true,
			"final_signature_unknown": false,
		}],
		["ordinary_life", {"final_signature_owned": "true"}],
		["ordinary_life", null],
		["ordinary_life", []],
		["ordinary_life", "final_signature_people"],
	]
	for invalid_case in invalid_cases:
		var coda: Dictionary = EndingSystem.final_signature_coda(
			invalid_case[0], invalid_case[1])
		if not coda.is_empty():
			_failures.append("invalid final-signature input returned a coda: %s" % [invalid_case])

	var first_payload: Dictionary = EndingSystem.final_signature_coda(
		"ordinary_life", {"final_signature_owned": true})
	first_payload["kind"] = "mutated_by_test"
	var second_payload: Dictionary = EndingSystem.final_signature_coda(
		"ordinary_life", {"final_signature_owned": true})
	if str(second_payload.get("kind", "")) != "owned":
		_failures.append("final-signature resolver leaked a mutable shared payload")


func _check_signature_payload(
		ending_id: String, flag_id: String, coda: Dictionary) -> void:
	var keys: Array = coda.keys()
	keys.sort()
	if keys != ["kind", "text", "text_en"]:
		_failures.append("%s/%s returned payload keys %s" % [ending_id, flag_id, keys])
		return
	if str(coda.get("kind", "")) != str(FINAL_SIGNATURE_CASES[flag_id]):
		_failures.append("%s/%s returned kind %s" % [ending_id, flag_id, coda.get("kind", "")])
	if str(coda.get("text", "")).strip_edges().is_empty() \
			or str(coda.get("text_en", "")).strip_edges().is_empty():
		_failures.append("%s/%s returned an empty KO/EN coda" % [ending_id, flag_id])
	var surface := "%s %s" % [coda.get("text", ""), coda.get("text_en", "")]
	if "final_signature_" in surface:
		_failures.append("%s/%s leaked an internal flag onto the player surface" % [ending_id, flag_id])

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
