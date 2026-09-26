extends Node
## Component regression only: real Table actions, fixed cards, independent cash oracle.
## Requires StoryNameplateBootstrap before autoloads; never reads a player namespace.
## Does not certify AA splitting, split naturals, dealer peek, prose, or human input.

const TABLE := preload("res://scenes/BlackjackTable.gd")
const BASE := 100_000
const START_CASH := 10_000_000.0
const CASES_PER_LOCALE := 24
const SESSION_LENGTH := 12
const BETTING := 0
const PLAYER_TURN := 1
const RESULT := 3

var _table: Control
var _failures: Array[String] = []
var _context := "bootstrap"
var _cases := 0
var _locales := 0
var _expected_wallet := START_CASH
var _session_start := START_CASH
var _session_net := 0.0
var _session_rounds := 0
var _session_counts := [0, 0, 0] # wins, losses, pushes: per hand, not per round.
var _history_nets: Array = []
var _last_signal_cash := START_CASH
var _trace: Array = []
var _current_action := ""
var _ko_results: Dictionary = {}


func _ready() -> void:
	Engine.max_fps = 60
	if not _check_isolation():
		get_tree().quit(1)
		return
	print("STORY_NAMEPLATE_QA_USER_DIR=%s" % OS.get_user_data_dir())
	await get_tree().process_frame # Deferred autoload reads use the fresh directory.
	TutorialOverlay._seen["blackjack"] = true
	SaveManager.set_setting("vibration_enabled", false)
	GameState.money_changed.connect(_on_money_changed)
	var fixtures := _fixtures()
	_expect(fixtures.size() == CASES_PER_LOCALE, "fixture inventory must contain 24 cases")
	for language in ["ko", "en"]:
		LocaleManager.set_language(language)
		GameState.money = START_CASH
		_expected_wallet = START_CASH
		_last_signal_cash = START_CASH
		_table = TABLE.new()
		add_child(_table)
		for index in range(fixtures.size()):
			_context = "%s/%s" % [language, fixtures[index]["id"]]
			if index % SESSION_LENGTH == 0:
				_open_session()
			await _run_case(fixtures[index])
		_kill_motion()
		_table.queue_free()
		_table = null
		await get_tree().process_frame
		_locales += 1
	GameState.money_changed.disconnect(_on_money_changed)
	await _release_audio()
	_expect(_cases == 48 and _locales == 2, "executed fixture inventory incomplete")
	if not _failures.is_empty():
		for failure in _failures:
			print("BLACKJACK_ACCOUNTING_ASSERT_FAIL " + failure)
		print("BLACKJACK_ACCOUNTING_CHECK_FAIL cases=%d locales=%d failures=%d" % [
			_cases, _locales, _failures.size()])
		get_tree().quit(1)
		return
	print("BLACKJACK_ACCOUNTING_CHECK_OK cases=%d locales=%d" % [_cases, _locales])
	get_tree().quit(0)


func _check_isolation() -> bool:
	var bootstrap := get_tree().get_script() as Script
	var qa_namespace := OS.get_environment("STORY_NAMEPLATE_QA_NAMESPACE")
	var pattern := RegEx.new()
	var valid := pattern.compile("^GangnamDream_StoryNameplateQA_[0-9a-f]{32}$") == OK
	valid = valid and pattern.search(qa_namespace) != null
	valid = valid and bootstrap != null
	if bootstrap != null:
		valid = valid and bootstrap.resource_path == "res://tools/StoryNameplateBootstrap.gd"
	valid = valid and bool(ProjectSettings.get_setting("application/config/use_custom_user_dir", false))
	valid = valid and str(ProjectSettings.get_setting("application/config/custom_user_dir_name", "")) == qa_namespace
	valid = valid and OS.get_user_data_dir().get_file() == qa_namespace
	if not valid:
		push_error("BLACKJACK_ACCOUNTING_CHECK_FAIL exact pre-autoload isolation required")
	return valid


func _fixtures() -> Array:
	# Ranks use 1=A, 2..10. Deal order is dealer/dealer/player/player;
	# split draws for the split hand FIRST, then main. All totals below are fixed.
	# Each fixture gives gross return, net, [wins, losses, pushes], final
	# [main, split, dealer] totals. No expected payout calls production math.
	return [
		_case("none_win", [10,7,8,8,10,10], ["split","stand","stand"], 4, 2, [2,0,0], [18,18,17]),
		_case("none_push", [10,8,8,8,10,10], ["split","stand","stand"], 2, 0, [0,0,2], [18,18,18]),
		_case("none_loss", [10,8,8,8,8,8], ["split","stand","stand"], 0, -2, [0,2,0], [16,16,18]),
		_case("none_bust", [10,8,8,8,10,10,10,10], ["split","hit","hit"], 0, -2, [0,2,0], [28,28,18]),
		_case("main_win", [10,7,8,8,10,2,8], ["split","stand","double"], 6, 3, [2,0,0], [18,18,17]),
		_case("main_push", [10,8,8,8,10,2,8], ["split","stand","double"], 3, 0, [0,0,2], [18,18,18]),
		_case("main_loss", [10,8,8,8,8,2,6], ["split","stand","double"], 0, -3, [0,2,0], [16,16,18]),
		_case("main_bust", [10,8,8,8,10,10,10,10], ["split","hit","double"], 0, -3, [0,2,0], [28,28,18]),
		_case("split_win", [10,7,8,8,2,10,8], ["split","double","stand"], 6, 3, [2,0,0], [18,18,17]),
		_case("split_push", [10,8,8,8,2,10,8], ["split","double","stand"], 3, 0, [0,0,2], [18,18,18]),
		_case("split_loss", [10,8,8,8,2,8,6], ["split","double","stand"], 0, -3, [0,2,0], [16,16,18]),
		_case("split_bust", [10,8,8,8,10,10,10,10], ["split","double","hit"], 0, -3, [0,2,0], [28,28,18]),
		_case("both_win", [10,7,8,8,2,2,8,8], ["split","double","double"], 8, 4, [2,0,0], [18,18,17]),
		_case("both_push", [10,8,8,8,2,2,8,8], ["split","double","double"], 4, 0, [0,0,2], [18,18,18]),
		_case("both_loss", [10,8,8,8,2,2,6,6], ["split","double","double"], 0, -4, [0,2,0], [16,16,18]),
		_case("both_bust", [10,8,8,8,10,10,10,10], ["split","double","double"], 0, -4, [0,2,0], [28,28,18]),
		_case("ordinary_win", [10,7,10,8], ["stand"], 2, 1, [1,0,0], [18,0,17]),
		_case("ordinary_push", [10,8,10,8], ["stand"], 1, 0, [0,0,1], [18,0,18]),
		_case("ordinary_loss", [10,9,10,8], ["stand"], 0, -1, [0,1,0], [18,0,19]),
		_case("ordinary_double_win", [10,7,5,6,7], ["double"], 4, 2, [1,0,0], [18,0,17]),
		_case("natural_win", [10,9,1,10], [], 2.5, 1.5, [1,0,0], [21,0,19]),
		_case("natural_push", [1,10,1,10], [], 1, 0, [0,0,1], [21,0,21]),
		_case("split_win_main_loss", [10,9,8,8,2,10,10], ["split","double","stand"], 4, 1, [1,1,0], [18,20,19]),
		_case("split_push_main_loss", [10,9,8,8,2,10,9], ["split","double","stand"], 2, -1, [0,1,1], [18,19,19]),
	]


func _case(id: String, ranks: Array, actions: Array, gross: float, net: float,
		counts: Array, totals: Array) -> Dictionary:
	return {"id": id, "ranks": ranks, "actions": ["deal"] + actions,
		"gross": gross * BASE, "net": net * BASE, "counts": counts, "totals": totals}


func _open_session() -> void:
	_table.call("open")
	_session_start = _expected_wallet
	_session_net = 0.0
	_session_rounds = 0
	_session_counts = [0, 0, 0]
	_history_nets.clear()
	_expect(float(GameState.money) == _expected_wallet, "open changed wallet")
	_expect(int(_table.get("_phase")) == BETTING, "open did not enter betting")
	_check_session()


func _run_case(fixture: Dictionary) -> void:
	var failure_start := _failures.size()
	var start_wallet := _expected_wallet
	var paid := 0.0
	var expected_steps: Array = []
	var actual_steps: Array = []
	_trace.clear()
	_last_signal_cash = float(GameState.money)
	_table.call("_pad_next_hand")
	_table.set("_stake", BASE)
	var shoe: Array = []
	for rank in fixture["ranks"]:
		shoe.append(int(rank) - 1)
	# 100 > six-deck cut threshold 78, so _deal cannot replace the fixed prefix.
	while shoe.size() < 100:
		shoe.append(1)
	_table.set("_shoe", shoe)
	var actions: Array = fixture["actions"]
	for index in range(actions.size()):
		var action := str(actions[index])
		_current_action = action
		var last_action := index == actions.size() - 1
		var debit := float(BASE) if action in ["deal", "split", "double"] else 0.0
		var credit := float(fixture["gross"]) if last_action else 0.0
		paid += debit
		var expected_cash := start_wallet - paid + credit
		var expected_deltas: Array = []
		if debit > 0:
			expected_deltas.append(-debit)
		if credit > 0:
			expected_deltas.append(credit)
		var trace_start := _trace.size()
		if action != "deal":
			_expect(int(_table.get("_phase")) == PLAYER_TURN, "action outside player phase: " + action)
			_expect(action in _table.call("_available_pad_actions"), "unavailable action: " + action)
		match action:
			"deal": _table.call("_deal")
			"split": _table.call("_do_split")
			"double": _table.call("_double_down")
			"hit": _table.call("_hit")
			"stand": _table.call("_stand")
		if action == "deal":
			_expect(int(_table.get("_split_stake")) == 0, "deal retained split principal")
			_expect((_table.get("_split") as Array).is_empty(), "deal retained split cards")
			_expect(not bool(_table.get("_split_active")), "deal retained active split")
			_expect(not bool(_table.get("_dbl_down")), "deal retained main double")
		var actual_deltas: Array = []
		for entry in _trace.slice(trace_start):
			actual_deltas.append(entry["delta"])
		# Exact operand consumed by the table's ON TABLE draw call; not a screenshot claim.
		var on_table := int(_table.get("_stake")) + int(_table.get("_split_stake"))
		if bool(_table.get("_dbl_down")):
			on_table += int(_table.get("_stake"))
		expected_steps.append({"action": action, "cash": expected_cash, "deltas": expected_deltas, "on_table_operand": paid})
		actual_steps.append({"action": action, "cash": GameState.money, "deltas": actual_deltas, "on_table_operand": on_table})
		_expect(float(GameState.money) == expected_cash, "wallet after %s expected=%s actual=%s" % [action, expected_cash, GameState.money])
		_expect(actual_deltas == expected_deltas, "cash transactions after %s expected=%s actual=%s" % [action, expected_deltas, actual_deltas])
		_expect(float(on_table) == paid, "ON TABLE operand after %s expected=%s actual=%s" % [action, paid, on_table])
		_expect(int(_table.get("_phase")) == (RESULT if last_action else PLAYER_TURN), "unexpected phase after " + action)
	_expected_wallet += float(fixture["net"])
	_expect(start_wallet - paid + float(fixture["gross"]) == _expected_wallet, "fixture cash oracle inconsistent")
	_session_net += float(fixture["net"])
	_session_rounds += 1
	for index in range(3):
		_session_counts[index] += int(fixture["counts"][index])
	_history_nets.append(fixture["net"])
	if _history_nets.size() > 10:
		_history_nets.pop_front()
	_check_session()
	var history: Array = _table.get("_hand_history")
	var actual_history: Array = []
	for entry in history:
		actual_history.append(entry.get("net"))
		_expect(bool(entry.get("won")) == (float(entry.get("net", 0)) > 0), "history won flag disagrees with its net")
	_expect(actual_history == _history_nets, "rolling history nets mismatch")
	var totals := [_points(_table.get("_player")), _points(_table.get("_split")), _points(_table.get("_dealer"))]
	_expect(totals == fixture["totals"], "fixed card totals expected=%s actual=%s" % [fixture["totals"], totals])
	var expected := {"steps": expected_steps, "cash": _expected_wallet, "round_net": fixture["net"],
		"session_net": _session_net, "rounds": _session_rounds, "counts": _session_counts.duplicate(),
		"history_nets": _history_nets.duplicate(), "totals": fixture["totals"]}
	var actual := {"steps": actual_steps, "cash": GameState.money,
		"round_net": history.back().get("net") if not history.is_empty() else null,
		"session_net": _table.get("_net"), "rounds": _table.get("_rounds"),
		"counts": [_table.get("_wins"), _table.get("_losses"), _table.get("_pushes")],
		"history_nets": actual_history, "totals": totals}
	if LocaleManager.language == "ko":
		_ko_results[fixture["id"]] = actual.duplicate(true)
	else:
		_expect(actual == _ko_results.get(fixture["id"]), "KO/EN financial parity mismatch")
	print("BLACKJACK_ACCOUNTING_CASE=" + JSON.stringify({"case": fixture["id"], "locale": LocaleManager.language,
		"ranks": fixture["ranks"], "expected": expected, "actual": actual,
		"passed": _failures.size() == failure_start}))
	_cases += 1
	_kill_motion()
	await get_tree().process_frame


func _check_session() -> void:
	var summary: Dictionary = _table.call("get_session_summary")
	_expect(float(GameState.money) == _expected_wallet, "cumulative wallet mismatch")
	_expect(float(_table.get("_net")) == _session_net, "cumulative net mismatch")
	_expect(float(_table.get("_net")) == float(GameState.money) - _session_start, "net != final cash - session start cash")
	_expect(int(_table.get("_rounds")) == _session_rounds, "round counter mismatch")
	_expect([_table.get("_wins"), _table.get("_losses"), _table.get("_pushes")] == _session_counts, "hand counters mismatch")
	_expect(summary == {"game_id": "blackjack", "rounds": _session_rounds, "net": _session_net}, "session summary mismatch")
	if _session_rounds == 0:
		_expect((_table.get("_hand_history") as Array).is_empty(), "open retained history")


func _on_money_changed(new_amount: float) -> void:
	_trace.append({"action": _current_action, "delta": new_amount - _last_signal_cash, "cash": new_amount})
	_last_signal_cash = new_amount


func _points(cards: Array) -> int:
	var total := 0
	var aces := 0
	for card in cards:
		var rank := int(card) % 13 + 1
		total += 11 if rank == 1 else mini(rank, 10)
		aces += 1 if rank == 1 else 0
	while total > 21 and aces > 0:
		total -= 10
		aces -= 1
	return total


func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(_context + ": " + message)


func _kill_motion() -> void:
	for tween in get_tree().get_processed_tweens():
		if tween.is_valid():
			tween.kill()


func _release_audio() -> void:
	_kill_motion()
	BGMPlayer.stop()
	_detach_audio(get_tree().root)
	AudioManager._sounds.clear()
	await AudioManager.drain_pending_timers_for_exit()
	BGMPlayer.stop()
	_detach_audio(get_tree().root)
	for player in AudioManager._pool.duplicate():
		if player is AudioStreamPlayer:
			player.stop()
			player.stream = null
			player.free()
	AudioManager._pool.clear()
	AudioManager._sounds.clear()
	# Give the audio server a complete mix period before exiting, including on
	# headless Dummy output. Frame-only waits can leave playback resources live.
	var since_mix := maxf(0.0, float(AudioServer.get_time_since_last_mix()))
	var to_mix := maxf(0.0, float(AudioServer.get_time_to_next_mix()))
	await get_tree().create_timer(clampf(since_mix + 2.0 * to_mix + 0.05, 0.05, 0.5)).timeout
	for _frame in range(8):
		await get_tree().process_frame


func _detach_audio(node: Node) -> void:
	if node is AudioStreamPlayer:
		(node as AudioStreamPlayer).stop()
		(node as AudioStreamPlayer).stream = null
	elif node is AudioStreamPlayer2D:
		(node as AudioStreamPlayer2D).stop()
		(node as AudioStreamPlayer2D).stream = null
	for child in node.get_children():
		_detach_audio(child)
