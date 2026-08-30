extends Node
## Throwaway probe: 118 authored callback events declare no `weight` key.
## Their required flags all have producers. Can the director ever draw them?

const SAMPLES := 4000

func _ready() -> void:
	_probe()
	get_tree().quit(0)

func _probe() -> void:
	var cases: Array[Dictionary] = [
		{"id": "callback_chain_banchan_regular_echo",
			"flag": "chain_banchan_regular", "turn": 100},
		{"id": "callback_chain_neighbor_friend_echo",
			"flag": "chain_neighbor_friend", "turn": 100},
		{"id": "callback_political_winner_echo",
			"flag": "political_winner", "turn": 100},
		{"id": "callback_chain_interior_manager_echo",
			"flag": "chain_interior_manager", "turn": 100},
	]
	# Control: a callback that demonstrably fired in the full-run replays.
	var control := {"id": "callback_truth_echo",
		"flag": "told_truth_interview", "turn": 100}
	cases.append(control)

	for case in cases:
		var event_id := str(case["id"])
		var authored: Dictionary = DataRegistry.find_event(event_id)
		# A real mid-run save, not a fresh game: the director needs the chapter,
		# asset band and history a new game does not have. The control below
		# proves the fixture can draw callbacks at all.
		if not SaveManager.load_game(8):
			print("[draw] could not load slot 8")
			return
		GameState.flags[str(case["flag"])] = true
		GameState.turn = int(case["turn"])

		var passes_contract := EventManager._event_passes_hard_state_contracts(
			authored)
		# Walk draw_situations' own filter chain and report the first gate that
		# rejects this event, instead of guessing from the data shape.
		var gate := "passes-all"
		if not EventManager.is_foreground_random_event(authored):
			gate = "is_foreground_random_event"
		elif not EventManager._is_event_eligible(authored):
			gate = "_is_event_eligible"
		elif not EventManager._event_has_causal_context(authored):
			gate = "_event_has_causal_context"
		elif str(authored.get("rarity", "")) == "story":
			gate = "rarity==story"
		elif str(authored.get("category", "")) == "story":
			gate = "category==story"
		elif float(authored.get("weight", 1.0)) <= 0.0:
			gate = "weight<=0"
		print("[gate] %-46s rarity=%-9s category=%-10s -> %s" % [
			event_id, str(authored.get("rarity", "ABSENT")),
			str(authored.get("category", "ABSENT")), gate])
		var drawn := 0
		for attempt in range(SAMPLES):
			GameState.turn = int(case["turn"])
			var pool: Array = EventManager.draw_situations(1)
			if pool.is_empty():
				continue
			var did := str((pool[0] as Dictionary).get("id", ""))
			if did == event_id:
				drawn += 1
			EventManager.event_cooldowns.erase(did)
		print("[draw] %-46s weight=%-5s contract=%-5s drawn=%d/%d" % [
			event_id, str(authored.get("weight", "ABSENT")),
			str(passes_contract), drawn, SAMPLES])
