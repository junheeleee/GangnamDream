extends Node
## ORDER-837 B1 regression: the recall ledger is sound, a free week only speaks
## once three silent weeks have passed, rest weeks stay quiet, recalls go oldest
## decision first and never repeat, time-anchored prose respects its window,
## state survives a JSON save, and every recall exists in all five languages.

const RECALL := preload("res://systems/RhythmRecall.gd")
const OVERLAY_DIRS: Array[String] = [
	"res://content/events_en", "res://content/events_ja",
	"res://content/events_zh-CN", "res://content/events_zh-TW",
]

var _failures: Array[String] = []
var _rows: Array = []


func _ready() -> void:
	await get_tree().process_frame
	_rows = RECALL.ledger()
	_check_ledger()
	_check_gap_and_rest()
	_check_order_and_reuse()
	_check_elapsed_window()
	_check_json_round_trip()
	_check_overlays()
	if not _failures.is_empty():
		for failure in _failures:
			push_error("RHYTHM_RECALL_CHECK_FAIL " + failure)
		get_tree().quit(1)
		return
	print("RHYTHM_RECALL_CHECK_OK recalls=%d anchored=%d gap=4 rest=3 order=3 window=6 json=1 locales=5" % [
		_rows.size(), _rows.filter(func(r: Dictionary) -> bool: return r.has("elapsed_weeks")).size()])
	get_tree().quit(0)


func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)


func _always(_event_id: String) -> bool:
	return true


func _check_ledger() -> void:
	_expect(_rows.size() >= 100, "recall ledger lost its rows (%d)" % _rows.size())
	var seen_ids := {}
	var seen_decisions := {}
	for raw in _rows:
		var row: Dictionary = raw
		var event_id := str(row.get("event_id", ""))
		var flags: Array = row.get("requires_flags", [])
		_expect(event_id.begins_with("callback_") or event_id.begins_with("cb_"),
			"non-callback recall in ledger: " + event_id)
		_expect(not seen_ids.has(event_id), "recall listed twice: " + event_id)
		seen_ids[event_id] = true
		var key := ",".join(PackedStringArray(flags))
		_expect(not flags.is_empty() and not seen_decisions.has(key),
			"decision recalled twice or without seed: " + event_id)
		seen_decisions[key] = true
		var event: Dictionary = DataRegistry.find_event(event_id)
		_expect(not event.is_empty() and not (event.get("choices", []) as Array).is_empty(),
			"recall event missing or has no choice: " + event_id)
		_expect(not row.has("elapsed_weeks") or not (row.get("decision_events", []) as Array).is_empty(),
			"time-anchored recall cannot find its decision: " + event_id)


func _first_row_flags() -> Dictionary:
	var flags := {}
	for flag_id in (_rows[0] as Dictionary)["requires_flags"]:
		flags[str(flag_id)] = true
	return flags


func _check_gap_and_rest() -> void:
	var rows := [{"event_id": "callback_fixture_a", "requires_flags": ["seed_a"]}]
	var flags := {"seed_a": true}
	_expect(RECALL.take_scene(flags.duplicate(), 10, 7, [], _always, rows) == "",
		"recall spoke after only two silent weeks")
	_expect(RECALL.take_scene(flags.duplicate(), 10, 6, [], _always, rows) == "callback_fixture_a",
		"fourth silent week stayed silent")
	_expect(RECALL.take_scene(flags.duplicate(), 4, -1, [], _always, rows) == "",
		"recall spoke inside the opening month")
	var mourning := flags.duplicate()
	mourning["father_passed"] = true
	_expect(RECALL.take_scene(mourning, 190, 180, [], _always, rows) == "",
		"recall broke the mourning rest")
	_expect(RECALL.take_scene(flags.duplicate(), 190, 180, [], _always, rows) == "callback_fixture_a",
		"living-father W190 treated as mourning")
	_expect(RECALL.take_scene(flags.duplicate(), 239, 230, [], _always, rows) == "",
		"recall broke the finale rest")


func _check_order_and_reuse() -> void:
	var rows := [
		{"event_id": "callback_old", "requires_flags": ["old"]},
		{"event_id": "callback_new", "requires_flags": ["new"]},
		{"event_id": "callback_unseeded", "requires_flags": ["never"]},
	]
	var flags := {"old": true, "new": true}
	_expect(RECALL.take_scene(flags, 20, 10, [], _always, rows) == "callback_old",
		"recall did not start with the oldest decision")
	_expect(RECALL.take_scene(flags, 30, 20, [], _always, rows) == "callback_new",
		"recall repeated or skipped the next decision")
	_expect(RECALL.take_scene(flags, 40, 30, [], _always, rows) == "",
		"recall used an unseeded or spent scene")


func _check_elapsed_window() -> void:
	var rows := [{"event_id": "callback_two_months", "requires_flags": ["seed"],
		"decision_events": ["decision_x"], "elapsed_weeks": 8}]
	var log := [{"turn": 20, "event_id": "decision_x", "choice_index": 0}]
	_expect(RECALL.take_scene({"seed": true}, 25, 10, log, _always, rows) == "",
		"'two months ago' spoke five weeks after the decision")
	_expect(RECALL.take_scene({"seed": true}, 28, 10, log, _always, rows) == "callback_two_months",
		"'two months ago' missed its window")
	_expect(RECALL.take_scene({"seed": true}, 33, 10, log, _always, rows) == "",
		"'two months ago' spoke thirteen weeks after the decision")
	_expect(RECALL.take_scene({"seed": true}, 28, 10, [], _always, rows) == "",
		"time-anchored recall spoke without its decision in the log")
	var vague := [{"event_id": "callback_some_months", "requires_flags": ["seed"],
		"decision_events": ["decision_x"], "elapsed_weeks": 16, "elapsed_vague": true}]
	_expect(RECALL.take_scene({"seed": true}, 29, 10, log, _always, vague) == "callback_some_months"
			and RECALL.take_scene({"seed": true}, 27, 10, log, _always, vague) == ""
			and RECALL.take_scene({"seed": true}, 53, 10, log, _always, vague) == "",
		"'some months ago' ignored its wide window")
	# Every recall whose prose says "...지 두 달" or "석 달 전" carries a window.
	for raw in _rows:
		var row: Dictionary = raw
		var event: Dictionary = DataRegistry.find_event(str(row["event_id"]))
		var text := str(event.get("description", ""))
		for phrase in ["지 두 달", "게 두 달 전", "석 달 전", "게 한 달 전"]:
			if text.contains(phrase):
				_expect(row.has("elapsed_weeks"), "time-anchored prose lacks a window: " + str(row["event_id"]))


func _check_json_round_trip() -> void:
	var rows := [
		{"event_id": "callback_old", "requires_flags": ["old"]},
		{"event_id": "callback_new", "requires_flags": ["new"]},
	]
	var flags := {"old": true, "new": true}
	RECALL.take_scene(flags, 20, 10, [], _always, rows)
	var loaded: Dictionary = JSON.parse_string(JSON.stringify(flags))
	_expect(RECALL.take_scene(loaded, 30, 20, [], _always, rows) == "callback_new",
		"recall state lost its meaning after a JSON save/load")


func _check_overlays() -> void:
	var ids := {}
	for raw in _rows:
		ids[str((raw as Dictionary)["event_id"])] = true
	for dir_path in OVERLAY_DIRS:
		var found := {}
		var dir := DirAccess.open(dir_path)
		if dir == null:
			_failures.append("overlay directory missing: " + dir_path)
			continue
		for file_name in dir.get_files():
			if not file_name.ends_with(".json"):
				continue
			var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(dir_path + "/" + file_name))
			var events: Variant = parsed.get("events", []) if parsed is Dictionary else parsed
			if not events is Array:
				continue
			for event in events:
				if event is Dictionary and ids.has(str(event.get("id", ""))):
					found[str(event["id"])] = true
		_expect(found.size() == ids.size(),
			"%s lacks %d recall scenes" % [dir_path.get_file(), ids.size() - found.size()])
