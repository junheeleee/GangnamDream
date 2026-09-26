extends Node
## Component-only accounting probe. Actual Table bet/deal/reveal/result/exit paths.
## Requires fresh pre-autoload storage; no screenshots, human input or EV claims.
## Expected cash is literal, never derived from the production payout functions.

const TABLE := preload("res://scenes/BaccaratTable.gd")
const CHIP := 100_000
const START_CASH := 10_000_000.0
const BETTING := 0
const DEALING := 1
const RESULT := 2
const LAYOUTS := {
	# Raw IDs: the model consumes P1/P2/B1/B2, then optional P3/B3.
	# Its interleaved-deal comment is not the actual shoe-consumption contract.
	"draw_player": {"cards": [2,1,0,1,2,2], "p": [2,1,2], "b": [0,1,2], "totals": [8,6], "naturals": [false,false], "pairs": [false,false], "result": "player", "shoe_pct": 30},
	"player": {"cards": [4,3,3,2], "p": [4,3], "b": [3,2], "totals": [9,7], "naturals": [true,false], "pairs": [false,false], "result": "player", "shoe_pct": 31},
	"banker": {"cards": [3,2,4,3], "p": [3,2], "b": [4,3], "totals": [7,9], "naturals": [false,true], "pairs": [false,false], "result": "banker", "shoe_pct": 31},
	"tie": {"cards": [2,4,1,5], "p": [2,4], "b": [1,5], "totals": [8,8], "naturals": [true,true], "pairs": [false,false], "result": "tie", "shoe_pct": 31},
	"player_pair": {"cards": [3,16,0,5], "p": [3,16], "b": [0,5], "totals": [8,7], "naturals": [true,false], "pairs": [true,false], "result": "player", "shoe_pct": 31},
	"banker_pair": {"cards": [0,5,3,16], "p": [0,5], "b": [3,16], "totals": [7,8], "naturals": [false,true], "pairs": [false,true], "result": "banker", "shoe_pct": 31},
	"both_pairs": {"cards": [3,16,29,42], "p": [3,16], "b": [29,42], "totals": [8,8], "naturals": [true,true], "pairs": [true,true], "result": "tie", "shoe_pct": 31},
	"pair_mixed": {"cards": [3,16,3,4], "p": [3,16], "b": [3,4], "totals": [8,9], "naturals": [true,true], "pairs": [true,false], "result": "banker", "shoe_pct": 31},
}

var _table: Control
var _failures: Array[String] = []
var _context := "bootstrap"
var _cases := 0
var _locales := 0
var _cash := START_CASH
var _start_cash := START_CASH
var _commission := 0.0
var _net := 0.0
var _rounds := 0
var _counts: Array = [0,0,0] # outcomes: player, banker, tie; not bet wins.
var _road: Array = []
var _closed_signals := 0
var _last_cash := START_CASH
var _deltas: Array = []
var _logs: Array = []
var _expected_steps: Array = []
var _actual_steps: Array = []
var _expected_surfaces: Array = []
var _actual_surfaces: Array = []
var _ko_financial: Dictionary = {}


func _ready() -> void:
	Engine.max_fps = 60
	if not _check_isolation():
		get_tree().quit(1)
		return
	print("STORY_NAMEPLATE_QA_USER_DIR=%s" % OS.get_user_data_dir())
	await get_tree().process_frame
	TutorialOverlay._seen["baccarat"] = true
	SaveManager.set_setting("vibration_enabled", false)
	GameState.money_changed.connect(_on_money_changed)
	GameState.log_added.connect(_on_log_added)
	var fixtures: Array = _fixtures()
	_expect(fixtures.size() == 18, "fixture inventory must contain 18 cases")
	for language in ["ko", "en"]:
		LocaleManager.set_language(language)
		_table = TABLE.new()
		add_child(_table)
		_table.connect("closed", _on_closed)
		for fixture in fixtures:
			_context = "%s/%s" % [language, fixture["id"]]
			await _run_case(fixture)
		_kill_motion()
		_table.queue_free()
		_table = null
		await get_tree().process_frame
		_locales += 1
	GameState.money_changed.disconnect(_on_money_changed)
	GameState.log_added.disconnect(_on_log_added)
	await _release_audio()
	_expect(_cases == 36 and _locales == 2, "executed fixture inventory incomplete")
	if not _failures.is_empty():
		for failure in _failures:
			print("BACCARAT_ACCOUNTING_ASSERT_FAIL " + failure)
		print("BACCARAT_ACCOUNTING_CHECK_FAIL cases=%d locales=%d failures=%d" % [_cases, _locales, _failures.size()])
		get_tree().quit(1)
		return
	print("BACCARAT_ACCOUNTING_CHECK_OK cases=%d locales=%d" % [_cases, _locales])
	get_tree().quit(0)


func _check_isolation() -> bool:
	var bootstrap: Script = get_tree().get_script() as Script
	var qa_namespace: String = OS.get_environment("STORY_NAMEPLATE_QA_NAMESPACE")
	var pattern := RegEx.new()
	var valid: bool = pattern.compile("^GangnamDream_StoryNameplateQA_[0-9a-f]{32}$") == OK
	valid = valid and pattern.search(qa_namespace) != null and bootstrap != null
	if bootstrap != null:
		valid = valid and bootstrap.resource_path == "res://tools/StoryNameplateBootstrap.gd"
	valid = valid and bool(ProjectSettings.get_setting("application/config/use_custom_user_dir", false))
	valid = valid and str(ProjectSettings.get_setting("application/config/custom_user_dir_name", "")) == qa_namespace
	valid = valid and OS.get_user_data_dir().get_file() == qa_namespace
	if not valid:
		push_error("BACCARAT_ACCOUNTING_CHECK_FAIL exact pre-autoload isolation required")
	return valid


func _fixtures() -> Array:
	# Each round specifies literal gross cash return, new unpaid fee, and net.
	# P12+B1+PP1 is a winning pair but total net -5k, using only the 100k chip.
	return [
		_case("player_win", [_round("draw_player", ["P"], 200_000, 0, 100_000)]),
		_case("player_loss", [_round("banker", ["P"], 0, 0, -100_000)]),
		_case("banker_win", [_round("banker", ["B"], 200_000, 5_000, 95_000)]),
		_case("banker_loss", [_round("player", ["B"], 0, 0, -100_000)]),
		_case("tie_win", [_round("tie", ["T"], 900_000, 0, 800_000)]),
		_case("tie_loss", [_round("player", ["T"], 0, 0, -100_000)]),
		_case("player_tie_refund", [_round("tie", ["P"], 100_000, 0, 0)]),
		_case("banker_tie_refund", [_round("tie", ["B"], 100_000, 0, 0)]),
		_case("mixed_tie_refunds", [_round("tie", ["P","B","T"], 1_100_000, 0, 800_000)]),
		_case("player_pair_win", [_round("player_pair", ["PP"], 1_200_000, 0, 1_100_000)]),
		_case("player_pair_loss", [_round("banker_pair", ["PP"], 0, 0, -100_000)]),
		_case("banker_pair_win", [_round("banker_pair", ["BP"], 1_200_000, 0, 1_100_000)]),
		_case("banker_pair_loss", [_round("player_pair", ["BP"], 0, 0, -100_000)]),
		_case("both_pairs_win", [_round("both_pairs", ["PP","BP"], 2_400_000, 0, 2_200_000)]),
		_case("banker_pair_mixed", [_round("pair_mixed", ["P","P","P","P","P","P","P","P","P","P","P","P","B","PP"], 1_400_000, 5_000, -5_000)]),
		_case("player_banker_negative", [_round("banker", ["P","B"], 200_000, 5_000, -5_000)]),
		_case("multi_round_commission", [_round("banker", ["B"], 200_000, 5_000, 95_000), _round("banker", ["B"], 200_000, 5_000, 95_000), _round("player", ["B"], 0, 0, -100_000)]),
		_case("reopen_empty", []),
	]


func _round(layout: String, bets: Array, gross: int, fee: int, net: int) -> Dictionary:
	return {"layout": layout, "bets": bets, "gross": gross, "fee": fee, "net": net}


func _case(id: String, rounds: Array) -> Dictionary:
	return {"id": id, "rounds": rounds}


func _run_case(fixture: Dictionary) -> void:
	var failure_start: int = _failures.size()
	var reopen: bool = fixture["id"] == "reopen_empty"
	# Reopen observes the preceding 2-win/1-loss session without assigning cash.
	_start_cash = START_CASH + 90_000.0 if reopen else START_CASH
	if not reopen:
		GameState.money = START_CASH
	_cash = _start_cash
	_last_cash = float(GameState.money)
	_commission = 0.0
	_net = 0.0
	_rounds = 0
	_counts = [0,0,0]
	_road.clear()
	_closed_signals = 0
	_deltas.clear()
	_logs.clear()
	_expected_steps.clear()
	_actual_steps.clear()
	_expected_surfaces.clear()
	_actual_surfaces.clear()
	GameState.gambling_tendency = 0
	GameState.addiction_tendency = 0
	_table.call("open")
	_table.call("_set_stake", CHIP)
	_record_step("open", BETTING, 0, [])
	for round_fixture in fixture["rounds"]:
		_run_round(round_fixture)
	var last_bets: int = 0
	if not reopen:
		var final_round: Dictionary = fixture["rounds"].back()
		last_bets = (final_round["bets"] as Array).size() * CHIP
	var last_phase: int = RESULT if not reopen else BETTING
	var due: float = _commission
	_cash -= due
	_commission = 0.0
	_table.call("_on_exit")
	var exit_deltas: Array = [{"amount": -due, "commission": 0.0}] if due > 0 else []
	_record_step("exit", last_phase, last_bets, exit_deltas)
	_expect(not _table.visible, "exit did not hide table")
	_expect(float(GameState.money) - _start_cash == _net, "exit cash delta differs from after-fee net")
	var commission_logs: Array = _commission_logs()
	_table.call("_on_exit")
	_record_step("repeat_exit", last_phase, last_bets, [])
	_expect(_commission_logs() == commission_logs, "repeat exit added commission payment log")
	# closed emits twice in the existing API; mastery re-recording is not repaired here.
	_expect(_closed_signals == 2, "existing closed signal count changed")
	var expected_logs: Array = []
	if due > 0:
		expected_logs.append(_text("바카라 커미션 정산 -%s", "Baccarat commission paid -%s") % _money(due))
	var expected: Dictionary = {"steps": _expected_steps.duplicate(true), "cash": _cash, "commission": 0.0,
		"net": _net, "summary": {"game_id": "baccarat", "rounds": _rounds, "net": _net},
		"rounds": _rounds, "counts": _counts.duplicate(), "road": _road.duplicate(),
		"round_surfaces": _expected_surfaces.duplicate(true), "commission_logs": expected_logs, "closed_signals": 2}
	var actual: Dictionary = {"steps": _actual_steps.duplicate(true), "cash": GameState.money,
		"commission": _table.get("_commission"), "net": _table.get("_net"), "summary": _table.call("get_session_summary"),
		"rounds": _table.get("_rounds"), "counts": [_table.get("_p_wins"), _table.get("_b_wins"), _table.get("_ties")],
		"road": (_table.get("_road") as Array).duplicate(), "round_surfaces": _actual_surfaces.duplicate(true),
		"commission_logs": _commission_logs(), "closed_signals": _closed_signals}
	_expect(actual == expected, "final cash/summary/consumer signature mismatch")
	var financial: Dictionary = actual.duplicate(true)
	financial.erase("round_surfaces")
	financial.erase("commission_logs")
	if LocaleManager.language == "ko":
		_ko_financial[fixture["id"]] = financial
	else:
		_expect(financial == _ko_financial.get(fixture["id"]), "KO/EN financial parity mismatch")
	print("BACCARAT_ACCOUNTING_CASE=" + JSON.stringify({"case": fixture["id"], "locale": LocaleManager.language,
		"expected": expected, "actual": actual, "passed": _failures.size() == failure_start}))
	_cases += 1
	_kill_motion()
	await get_tree().process_frame


func _run_round(fixture: Dictionary) -> void:
	var layout: Dictionary = LAYOUTS[fixture["layout"]]
	_table.call("_next_round")
	_record_step("next_round", BETTING, 0, [])
	var total: int = 0
	for bet in fixture["bets"]:
		_table.call("_add_bet", bet)
		total += CHIP
		_record_step("bet_" + str(bet), BETTING, total, [])
	var shoe: Array = layout["cards"].duplicate()
	while shoe.size() < 100: # six-deck cut threshold is 78; no random replacement.
		shoe.append(1)
	_table.set("_shoe", shoe)
	_table.call("_deal")
	# Deterministic frame delivery only: _process itself reveals every real card
	# and invokes _finish_result. Do not inject _result or call settlement directly.
	_table.set_process(false)
	_cash -= total
	_record_step("deal", DEALING, total, [{"amount": -float(total), "commission": _commission}], [0,0])
	var reveal_sides: Array = ["p","b","p","b"]
	if layout["p"].size() == 3:
		reveal_sides.append("p")
	if layout["b"].size() == 3:
		reveal_sides.append("b")
	var visible_counts: Array = [0,0]
	for index in range(reveal_sides.size()):
		_table.call("_process", 1.0)
		visible_counts[0 if reveal_sides[index] == "p" else 1] += 1
		_record_step("reveal_%d" % (index + 1), DEALING, total, [], visible_counts)
	var gambling_before: int = int(GameState.gambling_tendency)
	var addiction_before: int = int(GameState.addiction_tendency)
	var logs_before: int = _logs.size()
	_table.call("_process", 1.0)
	_cash += float(fixture["gross"])
	_commission += float(fixture["fee"])
	_net += float(fixture["net"])
	_rounds += 1
	var outcome_index: int = ["player", "banker", "tie"].find(layout["result"])
	_counts[outcome_index] += 1
	_road.append(str(layout["result"]).substr(0, 1).to_upper())
	var gain_deltas: Array = [{"amount": float(fixture["gross"]), "commission": _commission}] if int(fixture["gross"]) > 0 else []
	_record_step("result", RESULT, total, gain_deltas, visible_counts)
	_expect(float(GameState.money) - _start_cash - float(_table.get("_commission")) == float(_table.get("_net")), "cash - start - pending fee != net")
	_expect(_table.call("get_session_summary") == {"game_id": "baccarat", "rounds": _rounds, "net": _net}, "before-exit summary must already include fee")
	_expect(_logs.size() == logs_before + 1, "result must add exactly one round log")
	_expect(float(fixture["gross"]) - total - float(fixture["fee"]) == float(fixture["net"]), "literal oracle is internally inconsistent")
	_check_surfaces(fixture, layout, gambling_before, addiction_before)


func _record_step(action: String, phase: int, bets: int, deltas: Array, revealed: Array = []) -> void:
	var expected: Dictionary = {"action": action, "cash": _cash, "commission": _commission, "net": _net,
		"rounds": _rounds, "phase": phase, "bets": bets, "deltas": deltas}
	var actual: Dictionary = {"action": action, "cash": GameState.money, "commission": _table.get("_commission"),
		"net": _table.get("_net"), "rounds": _table.get("_rounds"), "phase": _table.get("_phase"),
		"bets": _table.call("_total_bet"), "deltas": _deltas.duplicate(true)}
	if not revealed.is_empty():
		expected["revealed"] = revealed.duplicate()
		actual["revealed"] = [(_table.get("_deal_p_visible") as Array).size(), (_table.get("_deal_b_visible") as Array).size()]
	_expected_steps.append(expected)
	_actual_steps.append(actual)
	_expect(actual == expected, "step %s expected=%s actual=%s" % [action, JSON.stringify(expected), JSON.stringify(actual)])
	_deltas.clear()


func _check_surfaces(fixture: Dictionary, layout: Dictionary, gambling_before: int, addiction_before: int) -> void:
	var round_net: float = float(fixture["net"])
	var is_natural: bool = (layout["result"] == "player" and layout["naturals"][0]) or (layout["result"] == "banker" and layout["naturals"][1])
	var natural_text: String = _text(" 내추럴", " natural") if is_natural else ""
	var round_log: String = _text("바카라 %s%s %s", "Baccarat %s%s %s") % [layout["result"], natural_text, _signed_money(round_net)]
	var commission_suffix := ""
	var fee_label := ""
	if _commission > 0:
		commission_suffix = _text("   커미션 [color=%s]%s[/color]", "   Commission [color=%s]%s[/color]") % ["#e8a05d", _money(_commission)]
		fee_label = _text("누적 커미션: %s (나갈 때 정산)", "Accumulated commission: %s (paid on exit)") % _money(_commission)
	var hud: String = _text("[b]현금 %s[/b]   |   %d라운드   W%d B%d T%d   손익 [b]%s[/b]   슈 %d%%%s", "[b]Cash %s[/b]   |   Round %d   W%d B%d T%d   P/L [b]%s[/b]   Shoe %d%%%s") % [
		_money(_cash), _rounds, _counts[0], _counts[1], _counts[2], _signed_money(_net), layout["shoe_pct"], commission_suffix]
	var banner: String = {"player": "PLAYER WINS", "banker": "BANKER WINS", "tie": "TIE"}[layout["result"]]
	if round_net != 0:
		banner += "  " + _signed_money(round_net)
	var expected_result: Dictionary = {"player": layout["p"], "banker": layout["b"], "player_val": layout["totals"][0],
		"banker_val": layout["totals"][1], "result": layout["result"], "player_natural": layout["naturals"][0],
		"banker_natural": layout["naturals"][1], "p_pair": layout["pairs"][0], "b_pair": layout["pairs"][1]}
	var expected: Dictionary = {"hud": hud, "round_log": {"message": round_log, "type": "money"}, "fee_label": fee_label,
		"banner": banner, "hidden_stat_delta": [2,0] if round_net > 0 else [0,2], "result": expected_result}
	var hud_label: RichTextLabel = _table.get("_hud_lbl") as RichTextLabel
	var actual: Dictionary = {"hud": hud_label.text, "round_log": _logs.back() if not _logs.is_empty() else {},
		"fee_label": _fee_label_text(), "banner": _last_result_banner(),
		"hidden_stat_delta": [int(GameState.gambling_tendency) - gambling_before, int(GameState.addiction_tendency) - addiction_before],
		"result": (_table.get("_result") as Dictionary).duplicate(true)}
	_expected_surfaces.append(expected)
	_actual_surfaces.append(actual)
	_expect(actual == expected, "round HUD/log/fee/banner/hidden-stat/result mismatch")


func _fee_label_text() -> String:
	var content: Node = _table.get("_content_root") as Node
	var prefix: String = _text("누적 커미션:", "Accumulated commission:")
	for label_text in _label_texts(content):
		if str(label_text).begins_with(prefix):
			return str(label_text)
	return ""


func _last_result_banner() -> String:
	var children: Array[Node] = _table.get_children()
	for index in range(children.size() - 1, -1, -1):
		var child: Node = children[index]
		if child is Control and (child as Control).z_index == 75:
			var labels: Array = _label_texts(child)
			if not labels.is_empty():
				return str(labels[0])
	return ""


func _label_texts(node: Node) -> Array:
	# _render queues old content without detaching it in the same stack.
	# Reject the entire queued subtree, not just a queued Label leaf.
	if node.is_queued_for_deletion():
		return []
	var labels: Array = []
	if node is Label:
		labels.append((node as Label).text)
	for child in node.get_children():
		labels.append_array(_label_texts(child))
	return labels


func _commission_logs() -> Array:
	var result: Array = []
	var prefix: String = _text("바카라 커미션 정산 -", "Baccarat commission paid -")
	for entry in _logs:
		if str(entry["message"]).begins_with(prefix):
			result.append(entry["message"])
	return result


func _on_money_changed(amount: float) -> void:
	# Observe pending debt at the synchronous debit signal: exit must consume it
	# before publishing cash, without recursively re-entering a broken baseline.
	_deltas.append({"amount": amount - _last_cash, "commission": _table.get("_commission")})
	_last_cash = amount


func _on_log_added(entry: Dictionary) -> void:
	_logs.append({"message": entry.get("message", ""), "type": entry.get("type", "")})


func _on_closed() -> void:
	_closed_signals += 1


func _text(ko: String, en: String) -> String:
	return ko if LocaleManager.language == "ko" else en


func _money(amount: float) -> String:
	return str(GameState.format_money(amount))


func _signed_money(amount: float) -> String:
	return "+" + _money(amount) if amount >= 0 else _money(amount)


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
			(player as AudioStreamPlayer).stop()
			(player as AudioStreamPlayer).stream = null
			player.free()
	AudioManager._pool.clear()
	AudioManager._sounds.clear()
	var since_mix: float = maxf(0.0, float(AudioServer.get_time_since_last_mix()))
	var to_mix: float = maxf(0.0, float(AudioServer.get_time_to_next_mix()))
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
