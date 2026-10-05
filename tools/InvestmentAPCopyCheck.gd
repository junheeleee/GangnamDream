extends Node
## Prepared component probes, not rendered UI, natural input, or executed trades.
## Always enter through StoryNameplateBootstrap, before any game autoload starts.

class TradeProbe extends Node:
	var calls: Array = []

	func buy_asset(asset_id, amount) -> Dictionary:
		calls.append(["buy", asset_id, amount])
		return {"success": false, "message": "probe:mutation_reached"}

	func sell_asset(asset_id, ratio) -> Dictionary:
		calls.append(["sell", asset_id, ratio])
		return {"success": false, "message": "probe:mutation_reached"}

	func buy_asset_leveraged(asset_id, amount) -> Dictionary:
		calls.append(["leverage", asset_id, amount])
		return {"success": false, "message": "probe:mutation_reached"}


class MainProbe extends "res://scenes/MainGame.gd":
	var observed_toasts: Array = []
	var closed_count := 0

	func _show_toast(message: String, color: Color = Color("#8892a4")):
		observed_toasts.append([message, color.to_html()])

	func _close_modal(_play_sound: bool = true, _resume_flow: bool = true):
		closed_count += 1


const EXPECTED := {
	"ko": "행동력이 없습니다",
	"en": "No Action Points",
	"ja": "行動力がありません",
	"zh-CN": "行动力已用尽",
	"zh-TW": "行動力已用盡",
}
const TRADES := [
	["buy", "_on_buy_asset", 200000.0],
	["sell", "_on_sell_asset", 0.5],
	["leverage", "_on_leverage_buy", 200000.0],
]
var failures: Array[String] = []
var rows: Array = []


func _ready() -> void:
	call_deferred("_run")


func _expect(ok: bool, message: String) -> void:
	if not ok:
		failures.append(message)


func _trade_state(game: MainProbe) -> Dictionary:
	return {
		"ap": GameState.action_points,
		"money": GameState.money,
		"portfolio": GameState.portfolio.duplicate(true),
		"pending": GameState.pending_weekly_commitment.duplicate(true),
		"action_log": game.turn_action_log.duplicate(true),
		"axes": GameState.action_axis_this_week.duplicate(true),
		"records": GameState.action_records_this_week.duplicate(true),
	}


func _probe(locale: String, trade: Array, available: bool) -> void:
	var game := MainProbe.new()
	var mutation := TradeProbe.new()
	game.investment_system = mutation
	var before := _trade_state(game)
	game.call(str(trade[1]), "probe_asset", trade[2])
	var expected_toast: String = "probe:mutation_reached" if available else str(EXPECTED[locale])
	var expected_calls: Array = [[trade[0], "probe_asset", trade[2]]] if available else []
	var actual := {
		"toasts": game.observed_toasts.duplicate(true),
		"closed": game.closed_count,
		"mutation_calls": mutation.calls.duplicate(true),
		"unchanged": before == _trade_state(game),
	}
	var expected := {
		"toasts": [[expected_toast, "ff4444ff"]],
		"closed": 0 if available else 1,
		"mutation_calls": expected_calls,
		"unchanged": true,
	}
	var passed: bool = actual == expected
	var phase: String = "restored_probe" if available else "ap_zero"
	_expect(passed, "%s/%s/%s" % [locale, str(trade[0]), phase])
	var row := {"locale": locale, "trade": trade[0], "phase": phase,
		"passed": passed, "expected": expected, "actual": actual}
	rows.append(row)
	print("INVESTMENT_AP_COPY_CASE=" + JSON.stringify(row))
	game.free()
	mutation.free()


func _run() -> void:
	var qa_namespace467 := OS.get_environment("STORY_NAMEPLATE_QA_NAMESPACE")
	if not qa_namespace467.begins_with("GangnamDream_StoryNameplateQA_") \
			or OS.get_user_data_dir().get_file() != qa_namespace467:
		push_error("INVESTMENT_AP_COPY_CHECK_FAIL pre-autoload isolation missing")
		get_tree().quit(1)
		return
	print("STORY_NAMEPLATE_QA_USER_DIR=" + OS.get_user_data_dir())
	var old_language: String = LocaleManager.language
	for locale: String in EXPECTED:
		LocaleManager.set_language(locale)
		GameState.pending_weekly_commitment = {}
		GameState.is_game_over = false
		GameState.year = 2026
		GameState.month = 3
		GameState.week_of_month = 1
		GameState.turn = 9
		GameState.action_points = 0
		GameState.max_action_points = 2
		GameState.action_axis_this_week = {"money": 0, "human": 0}
		GameState.action_records_this_week = []
		GameState.money = 1000000.0
		GameState.portfolio = {"probe_asset": {"amount": 10.0, "average_cost": 100.0}}
		for trade: Array in TRADES:
			_probe(locale, trade, false)
		var month_ended: bool = GameState.advance_calendar()
		GameState.restore_ap()
		var restored: bool = not month_ended and GameState.year == 2026 \
			and GameState.month == 3 and GameState.week_of_month == 2 \
			and GameState.turn == 10 and GameState.action_points == 2
		_expect(restored, locale + "/same_month_weekly_restore")
		print("INVESTMENT_AP_COPY_RESTORE=" + JSON.stringify({"locale": locale,
			"passed": restored, "month": GameState.month, "week": GameState.week_of_month,
			"turn": GameState.turn, "ap": GameState.action_points, "month_ended": month_ended}))
		for trade: Array in TRADES:
			_probe(locale, trade, true)
	LocaleManager.set_language(old_language)
	await get_tree().process_frame
	if not failures.is_empty():
		for failure: String in failures:
			push_error("INVESTMENT_AP_COPY_CHECK_FAIL " + failure)
		get_tree().quit(1)
		return
	print("INVESTMENT_AP_COPY_CHECK_OK cases=30 locales=5 weekly_restores=5 prepared_component_only=true")
	get_tree().quit(0)
