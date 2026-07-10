extends Node
## SeoulTraceCheck — 장소 기록의 주간 초기화와 저장 호환성을 검증한다.

func _ready() -> void:
	GameState.start_new_game()
	GameState.register_action_axis("money", "work")
	GameState.register_action_axis("human", "store")
	var work: Dictionary = GameState.action_places_this_week.get("work", {})
	var store: Dictionary = GameState.action_places_this_week.get("store", {})
	if int(work.get("money", 0)) != 1 or int(store.get("human", 0)) != 1:
		_fail("place visits did not follow registered AP actions")
		return
	if GameState.recent_action_places != ["work", "store"]:
		_fail("recent place path did not preserve action order")
		return

	var snapshot: Dictionary = GameState.serialize()
	GameState.action_places_this_week = {}
	GameState.recent_action_places = []
	GameState.load_from_dict(snapshot)
	if not GameState.action_places_this_week.has("work") or GameState.recent_action_places != ["work", "store"]:
		_fail("place trace did not survive save/load")
		return

	GameState.finalize_action_axis_week()
	if not GameState.action_places_this_week.is_empty():
		_fail("weekly place visits did not reset at week end")
		return
	if GameState.recent_action_places != ["work", "store"]:
		_fail("week end erased the recent route trace")
		return

	var legacy: Dictionary = snapshot.duplicate(true)
	legacy.erase("action_places_this_week")
	legacy.erase("recent_action_places")
	GameState.action_places_this_week = {"city": {"count": 9}}
	GameState.recent_action_places = ["city"]
	GameState.load_from_dict(legacy)
	if not GameState.action_places_this_week.is_empty() or not GameState.recent_action_places.is_empty():
		_fail("legacy save retained stale place trace state")
		return

	print("SEOUL_TRACE_OK visits=2 save=1 weekly_reset=1 legacy=1")
	get_tree().quit(0)

func _fail(message: String) -> void:
	push_error("SEOUL_TRACE_FAIL " + message)
	get_tree().quit(1)
