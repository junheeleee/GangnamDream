extends Node
## 이사 전 유물 비트의 트리거, 선택 결과, 현지화, 후속 침묵을 런타임으로 검증한다.

const MainGameScript = preload("res://scenes/MainGame.gd")
const StoryModeScript = preload("res://scenes/StoryMode.gd")

var _failures: Array[String] = []
var _original_language := "ko"

func _ready() -> void:
	_original_language = LocaleManager.language
	_check_keep_path()
	_check_leave_path()
	LocaleManager.language = _original_language
	DataRegistry.reload()
	if not _failures.is_empty():
		for failure in _failures:
			push_error("HOUSING_KEEPSAKE_CHECK_FAIL " + failure)
		get_tree().quit(1)
		return
	print("HOUSING_KEEPSAKE_CHECK_OK oldest=1 keep=1 leave=1 localized=2 silence=1 route_delta=0")
	get_tree().quit(0)

func _check_keep_path() -> void:
	_start_affordable_run()
	var game = MainGameScript.new()
	if game._housing_keepsake_event_id() != "":
		_fail("the keepsake beat opened without an artifact")
	var first_move: Dictionary = GameState.upgrade_housing()
	if not first_move.get("success", false) or GameState.housing != "oneroom":
		_fail("the ordinary first move did not reach the one-room studio")

	GameState.add_item("artifact_jaehyuk_photo", 1)
	GameState.add_item("artifact_daeun_note", 1)
	GameState.route_orthodox = 7
	GameState.route_unorthodox = 4
	var mental_before: int = int(GameState.mental)
	var tint_before: float = float(GameState.moral_tint)
	var event_id: String = game._housing_keepsake_event_id()
	if event_id != "arc_housing_keepsake":
		_fail("the next eligible move did not open the keepsake beat")
	if GameState.housing != "oneroom":
		_fail("housing changed before the keepsake choice")
	if str(GameState.flags.get("pending_housing_keepsake_id", "")) != "artifact_jaehyuk_photo":
		_fail("the oldest artifact was not selected")
	var saved: Dictionary = GameState.serialize()
	var saved_flags: Dictionary = saved.get("flags", {})
	if str(saved_flags.get("pending_housing_keepsake_id", "")) != "artifact_jaehyuk_photo":
		_fail("the pending keepsake was absent from run serialization")

	_check_localized_surface("ko", "포장마차 셀카")
	_check_localized_surface("en", "Pojangmacha Selfie")
	LocaleManager.language = "ko"
	DataRegistry.reload()
	var event: Dictionary = DataRegistry.find_event(event_id)
	if event.has("background"):
		_fail("the keepsake event hard-coded a room instead of using the current housing")
	if ImageRegistry.infer_background_id(event, GameState.housing) != "apartment":
		_fail("the keepsake event did not infer the pre-move one-room background")
	var result_preview := GameState.format_event_text(str(event.get("choices", [])[0].get("result_text", "")))
	if not result_preview.contains("포장마차 셀카") or result_preview.contains("{keepsake}"):
		_fail("the keep result lost its keepsake name before effects were applied")
	GameState.apply_choice(event, event.get("choices", [])[0])
	if GameState.housing != "villa":
		_fail("the keep choice did not finish the requested move")
	if not GameState.has_item("artifact_jaehyuk_photo") or not GameState.has_item("artifact_daeun_note"):
		_fail("the keep choice removed an artifact")
	if GameState.mental != mental_before or not is_equal_approx(GameState.moral_tint, tint_before):
		_fail("the keep choice changed mental health or moral tint")
	_assert_route_unchanged("keep", 7, 4)
	if not GameState.flags.get("arc_housing_keepsake_seen", false):
		_fail("the keep choice did not close the one-time beat")
	if GameState.flags.has("pending_housing_keepsake_id"):
		_fail("the keep choice left a pending artifact behind")
	if game._housing_keepsake_event_id() != "":
		_fail("the one-time beat retriggered on a later move")
	print("HOUSING_KEEPSAKE_EVIDENCE keep oldest=artifact_jaehyuk_photo old_room=oneroom new_room=villa items=2")
	game.free()

func _check_leave_path() -> void:
	_start_affordable_run()
	var first_move: Dictionary = GameState.upgrade_housing()
	if not first_move.get("success", false):
		_fail("leave-path setup could not reach the one-room studio")
	GameState.add_item("artifact_daeun_note", 1)
	GameState.add_item("artifact_jaehyuk_photo", 1)
	GameState.route_orthodox = 9
	GameState.route_unorthodox = 6
	GameState.mental = 60
	GameState.moral_tint = 0.0
	if GameState.prepare_housing_keepsake() != "artifact_daeun_note":
		_fail("leave path did not select the oldest artifact")

	var story = StoryModeScript.new()
	var artifact_event: Dictionary = DataRegistry.find_event("arc_daeun_final_choice")
	_assert_indices("artifact choice before leaving", story._visible_choice_indices(artifact_event), [0, 1, 2])
	var event: Dictionary = DataRegistry.find_event("arc_housing_keepsake")
	var result_preview := GameState.format_event_text(str(event.get("choices", [])[1].get("result_text", "")))
	if not result_preview.contains("다은이 남긴 포스트잇") or result_preview.contains("{keepsake}"):
		_fail("the leave result lost its keepsake name before removal")
	GameState.apply_choice(event, event.get("choices", [])[1])
	if GameState.housing != "villa":
		_fail("the leave choice did not finish the requested move")
	if GameState.has_item("artifact_daeun_note"):
		_fail("the leave choice kept the selected artifact")
	if not GameState.has_item("artifact_jaehyuk_photo"):
		_fail("the leave choice removed a newer artifact")
	if GameState.mental != 62 or not is_equal_approx(GameState.moral_tint, -2.0):
		_fail("the leave choice did not apply mental +2 and tint -2")
	_assert_route_unchanged("leave", 9, 6)
	_assert_indices("artifact choice after leaving", story._visible_choice_indices(artifact_event), [0, 1])
	if GameState.flags.has("pending_housing_keepsake_id"):
		_fail("the leave choice left a pending artifact behind")
	print("HOUSING_KEEPSAKE_EVIDENCE leave removed=artifact_daeun_note newer_kept=1 mental=62 tint=-2 hidden_choice=1")
	story.free()

func _check_localized_surface(language: String, expected_name: String) -> void:
	LocaleManager.language = language
	DataRegistry.reload()
	var event: Dictionary = DataRegistry.find_event("arc_housing_keepsake")
	if event.is_empty() or event.get("choices", []).size() != 2:
		_fail("%s keepsake event is missing or has the wrong choice count" % language)
		return
	var resolved := GameState.format_event_text(str(event.get("description", "")))
	if not resolved.contains(expected_name) or resolved.contains("{keepsake}"):
		_fail("%s keepsake name did not resolve to %s" % [language, expected_name])
	print("HOUSING_KEEPSAKE_EVIDENCE locale=%s name=%s choices=2" % [language, expected_name])

func _start_affordable_run() -> void:
	LocaleManager.language = "ko"
	DataRegistry.reload()
	GameState.start_new_game()
	GameState.money = 250_000_000.0

func _assert_route_unchanged(label: String, orthodox: int, unorthodox: int) -> void:
	if GameState.route_orthodox != orthodox or GameState.route_unorthodox != unorthodox:
		_fail("%s choice changed route points to %d/%d" % [
			label, GameState.route_orthodox, GameState.route_unorthodox])

func _assert_indices(label: String, actual: Array[int], expected: Array[int]) -> void:
	if actual != expected:
		_fail("%s expected=%s actual=%s" % [label, expected, actual])

func _fail(message: String) -> void:
	_failures.append(message)
