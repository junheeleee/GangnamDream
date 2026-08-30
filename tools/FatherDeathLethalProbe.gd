extends Node
## Throwaway probe: arc_father_passing_hospital_room applies mental -40 on a
## single-choice rail. Can that unavoidable beat end the run outright?

var _finished: Array[String] = []

func _ready() -> void:
	if GameState.has_signal("run_finished"):
		GameState.connect("run_finished", Callable(self, "_on_finished"))
	_probe()
	get_tree().quit(0)

func _on_finished(ending_id: String) -> void:
	_finished.append(str(ending_id))

func _probe() -> void:
	var chain := [
		"arc_father_passing",
		"arc_father_passing_platform",
		"arc_father_passing_hospital_room",
	]
	print("[chain] %s" % str(chain))
	for start_mental in [95, 72, 55, 45, 40, 35, 25]:
		if not SaveManager.load_game(9):
			print("[probe] could not load slot 9")
			return
		GameState.turn = 188
		GameState.mental = start_mental
		GameState.is_game_over = false
		_finished.clear()
		var trail: Array[String] = []
		for event_id in chain:
			var ev: Dictionary = DataRegistry.find_event(event_id)
			if ev.is_empty():
				trail.append("%s:MISSING" % event_id)
				break
			var choices: Array = ev.get("choices", [])
			if choices.is_empty():
				break
			# Index 0 is the only option on the closing rail; on the two earlier
			# beats it is the "go to your father" branch.
			GameState.apply_choice(ev, choices[0])
			trail.append("%s→mental %d" % [event_id.replace("arc_father_passing", "…"), GameState.mental])
			GameState.check_game_over()
			if GameState.is_game_over:
				trail.append("GAME OVER")
				break
		print("[probe] 시작 mental %-3d : %s  ending=%s" % [
			start_mental, " | ".join(trail),
			str(_finished) if not _finished.is_empty() else "-"])
