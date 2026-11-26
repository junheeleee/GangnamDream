extends RefCounted
## ORDER-834 B2.6 — the rock bottom is a scene, not a number (DECISIONS 2026-11-26).
##
## Gambling sessions raise addiction and nothing lowers it on its own. In the
## full story a run that reaches ADDICTION_BOTTOM meets the authored rock-bottom
## scene on its next free week, before any other system scene, so the player
## decides before addiction can end the run (GameState only ends a full run on
## addiction after "one more hand" or a relapse). A run that asked for help then
## walks the existing recovery arc on free weeks: the first week, the relapse
## test a month on, and the month-clean calendar a month after that.
## Mourning and finale weeks stay quiet. Deterministic (no RNG). State lives in
## one flag read and written only here:
##   flags["addiction_arc_state"] = {"last_turn": int}

const STATE_FLAG := "addiction_arc_state"
const ADDICTION_BOTTOM := 70
const REST_WEEKS := [[189, 192], [238, 240]]
## [event_id, flag that opens it, flag that closes it, weeks after the previous step]
const RECOVERY_STEPS := [
	["recovery_first_week", "in_recovery_started", "recovery_week_passed", 1],
	["recovery_relapse_test", "recovery_holding", "relapse_tested", 4],
	["recovery_one_month_clean", "recovery_proven", "beat_addiction", 4],
]


static func _in_rest(turn: int) -> bool:
	for weeks in REST_WEEKS:
		if turn >= int(weeks[0]) and turn <= int(weeks[1]):
			return true
	return false


## Returns this free week's addiction scene ("" for none) and records it.
## `event_open` must reject ids the registry cannot resolve or that already played.
static func take_scene(flags: Dictionary, turn: int, addiction: int,
		event_open: Callable) -> String:
	if _in_rest(turn):
		return ""
	var raw: Variant = flags.get(STATE_FLAG, {})
	var state: Dictionary = (raw as Dictionary).duplicate(true) if raw is Dictionary else {}
	var last := int(state.get("last_turn", -100))
	if turn == last:
		return ""
	var chosen := ""
	if addiction >= ADDICTION_BOTTOM and not bool(flags.get("hit_rock_bottom", false)) \
			and not bool(flags.get("in_recovery_started", false)):
		chosen = "gambling_rock_bottom"
	else:
		for step in RECOVERY_STEPS:
			if bool(flags.get(str(step[1]), false)) and not bool(flags.get(str(step[2]), false)):
				if turn - last >= int(step[3]):
					chosen = str(step[0])
				break
	if chosen.is_empty() or not bool(event_open.call(chosen)):
		return ""
	state["last_turn"] = turn
	flags[STATE_FLAG] = state
	return chosen
