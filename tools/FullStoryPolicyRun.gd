extends "res://tools/FullGameRuntimeTrace.gd"
## ORDER-838 D1 — new-story policy runner.
##
## Reuses the product-flow driver in FullGameRuntimeTrace.gd unchanged: fresh
## title, real StoryMode/MainGame controls, keyboard input, no save/flag/money
## injection. The only difference is how a story choice is picked: instead of a
## fixed index per event, a policy scores the *visible* choices from their
## authored effects and wording, with a seeded exploration rate so seeds spread.
##
## Output is the same JSONL trace; `tools/full_story_policy_summary.py` turns a
## set of traces into the ending distribution, M24/M48/M60 assets, gaps and
## decision-free months. This is a measurement tool, not a product gate.

const POLICY_MONEY_UNIT := 100000.0

var _policy_rng := RandomNumberGenerator.new()
var _policy_seeded := false
var _policy_pick_by_occurrence: Dictionary = {}


func _ensure_policy_seed() -> void:
	if _policy_seeded:
		return
	_policy_seeded = true
	_policy_rng.seed = int(_profile.get("seed", 1)) * 7919 + 17


func _choice_policy() -> Dictionary:
	var raw: Variant = _profile.get("choice_policy", {})
	return raw if raw is Dictionary else {}


func _score_choice(choice: Dictionary, policy: Dictionary) -> float:
	var score := 0.0
	var weights: Dictionary = policy.get("effect_weights", {})
	var effects: Variant = choice.get("effects", {})
	if effects is Dictionary:
		for key in (effects as Dictionary).keys():
			var value := float((effects as Dictionary)[key]) if \
					((effects as Dictionary)[key] is float \
					or (effects as Dictionary)[key] is int) else 0.0
			if str(key) == "money":
				value /= POLICY_MONEY_UNIT
			score += float(weights.get(str(key), 0.0)) * value
	var haystack := "%s %s %s" % [
		str(choice.get("text", "")),
		str(choice.get("follow_up_event", "")),
		JSON.stringify(choice.get("flags", [])),
	]
	var keywords: Dictionary = policy.get("keyword_weights", {})
	for word in keywords.keys():
		if haystack.contains(str(word)):
			score += float(keywords[word])
	return score


func _policy_index(current: Dictionary, visible_indices: Array[int]) -> int:
	_ensure_policy_seed()
	if visible_indices.is_empty():
		return -1
	if _policy_pick_by_occurrence.has(_story_occurrence_id):
		var cached := int(_policy_pick_by_occurrence[_story_occurrence_id])
		if cached in visible_indices:
			return cached
	var policy := _choice_policy()
	var choices: Array = current.get("choices", [])
	var pick := visible_indices[0]
	if _policy_rng.randf() < float(policy.get("explore_rate", 0.0)):
		pick = visible_indices[_policy_rng.randi_range(0, visible_indices.size() - 1)]
	else:
		var best := -INF
		for index in visible_indices:
			if index < 0 or index >= choices.size() \
					or not choices[index] is Dictionary:
				continue
			# Tiny seeded jitter breaks exact ties without favouring index 0.
			var value := _score_choice(choices[index], policy) \
					+ _policy_rng.randf() * 0.01
			if value > best:
				best = value
				pick = index
	_policy_pick_by_occurrence[_story_occurrence_id] = pick
	return pick


func _drive_story_choices(story: Node, current: Dictionary) -> void:
	if not _story_occurrence_id.is_empty() \
			and not _story_choice_recorded.has(_story_occurrence_id):
		var visible_indices: Array[int] = []
		for button in _visible_choice_buttons(story):
			visible_indices.append(int(button.get_meta("choice_index", -1)))
		var pick := _policy_index(current, visible_indices)
		if pick >= 0:
			var overrides: Dictionary = _profile.get("choice_overrides", {})
			overrides[str(current.get("id", ""))] = {
				"index": pick, "selection_mode": "policy",
			}
			_profile["choice_overrides"] = overrides
	await super(story, current)


func _drive_story_direct_choice(
		story: Node, current: Dictionary, direct_choice_index: int) -> void:
	if direct_choice_index >= 0:
		var overrides: Dictionary = _profile.get("choice_overrides", {})
		overrides[str(current.get("id", ""))] = {
			"index": direct_choice_index, "selection_mode": "direct",
		}
		_profile["choice_overrides"] = overrides
	await super(story, current, direct_choice_index)
