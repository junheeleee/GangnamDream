extends Node
## Throwaway probe: can a fresh W3 run be pushed deep into negative cash by the
## ambient crypto all-in chain, and does the run survive it?

func _ready() -> void:
	_probe_pool_sizes()
	get_tree().quit(0)

## How many distinct ambient events can the director actually draw at each
## point of the run? A small pool is what a player experiences as repetition.
func _probe_pool_sizes() -> void:
	var slots := {1: 6, 49: 7, 97: 8, 145: 9, 193: 10}
	for at_turn in [3, 12, 24, 40, 60, 80, 110, 130, 160, 180, 200, 230]:
		var slot := 6
		for boundary in [193, 145, 97, 49, 1]:
			if at_turn >= boundary:
				slot = int(slots[boundary]); break
		if not SaveManager.load_game(slot):
			continue
		GameState.turn = at_turn
		var seen := {}
		for attempt in range(600):
			GameState.turn = at_turn
			var drawn: Array = EventManager.draw_situations(1)
			if drawn.is_empty():
				continue
			var did := str((drawn[0] as Dictionary).get("id", ""))
			seen[did] = int(seen.get(did, 0)) + 1
			EventManager.event_cooldowns.erase(did)
		var top := ""
		var top_n := 0
		for did in seen:
			if int(seen[did]) > top_n:
				top_n = int(seen[did]); top = str(did)
		print("[pool] W%-4d slot=%d distinct=%-4d top=%s (%.0f%%)" % [
			at_turn, slot, seen.size(), top, 100.0 * top_n / 600.0])

func _probe_eligibility() -> void:
	GameState.start_new_game("김민준", "지방_상경", "")
	GameState.flags["prologue_done"] = true
	GameState.turn = 3
	print("[start] money=%.0f turn=%d" % [GameState.money, GameState.turn])
	var authored: Dictionary = DataRegistry.find_event("drama_crypto_allin")
	print("[event] found=%s conditions=%s weight=%s rarity=%s" % [
		not authored.is_empty(), str(authored.get("conditions", {})),
		str(authored.get("weight", "")), str(authored.get("rarity", ""))])
	# Draw repeatedly from the real ambient pool and see whether the chain is
	# offered at all in the opening weeks.
	var seen := {}
	for attempt in range(400):
		GameState.turn = 3
		var drawn: Array = EventManager.draw_situations(1)
		if drawn.is_empty():
			continue
		var did := str((drawn[0] as Dictionary).get("id", ""))
		seen[did] = int(seen.get(did, 0)) + 1
		EventManager.event_cooldowns.erase(did)
	print("[pool] distinct ambient ids drawable at W3 = %d" % seen.size())
	print("[pool] drama_crypto_allin drawn %d times in 400 draws"
		% int(seen.get("drama_crypto_allin", 0)))
	var risky := 0
	for did in seen:
		if str(did).begins_with("drama_") or str(did).begins_with("rare_"):
			risky += 1
	print("[pool] drama_/rare_ ids drawable at W3 = %d" % risky)

func _probe_apply() -> void:
	GameState.start_new_game("김민준", "지방_상경", "")
	GameState.flags["prologue_done"] = true
	GameState.turn = 3
	var before := float(GameState.money)
	var allin: Dictionary = DataRegistry.find_event("drama_crypto_allin")
	if allin.is_empty():
		print("[apply] event missing")
		return
	# Choice 0 on the parent, then the worst branch of its authored follow-up.
	GameState.apply_choice(allin, (allin.get("choices", []) as Array)[0])
	var result: Dictionary = DataRegistry.find_event("drama_crypto_result_big")
	print("[apply] parent applied; money=%.0f" % GameState.money)
	for index in [0, 1]:
		GameState.money = before
		GameState.mental = 50
		var choice: Dictionary = (result.get("choices", []) as Array)[index]
		GameState.apply_choice(result, choice)
		print("[apply] choice %d '%s' : money %.0f -> %.0f (mental %d) game_over=%s" % [
			index, str(choice.get("text", "")).substr(0, 20),
			before, GameState.money, GameState.mental,
			str(GameState.check_game_over())])
