extends RefCounted
## ORDER-834 B2 — the gambling branch, years 1-2.
##
## C6 (2026-11-24): the full story exposed zero gambling-category events, and the
## W76 Jeongseon invitation ("같이 가겠습니다" -> casino_club_introduced) had no
## reader. The existing racetrack mentor still opens the door (tempted + 1M won,
## W12+) and the first visit opens the real racetrack minigame. After that, on
## free weeks, the authored racetrack, Jeongseon and hold'em scenes follow in
## ledger order, each behind the fact that makes it possible (visited the track,
## met the mentor, went to Jeongseon, entered Sangchul's network). Their choices
## carry the authored wagers and addiction tendency that later years read.
## A run that never took the bait never sees any of this. Deterministic.

const ENGINE := preload("res://systems/BranchBeats.gd")
const LEDGER_PATH := "res://content/meta/gamble_branch_ledger.json"
const STATE_FLAG := "gamble_branch_state"

static var _ledger_cache: Dictionary = {}


static func ledger() -> Dictionary:
	if _ledger_cache.is_empty():
		_ledger_cache = ENGINE.load_ledger(LEDGER_PATH)
	return _ledger_cache


static func take_scene(flags: Dictionary, turn: int, has_job: bool, event_exists: Callable,
		data: Dictionary = {}) -> String:
	var source: Dictionary = data if not data.is_empty() else ledger()
	return ENGINE.take(source, STATE_FLAG, flags, {"turn": turn, "has_job": has_job}, event_exists)
