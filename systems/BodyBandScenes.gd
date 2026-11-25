extends RefCounted
## ORDER-836 M1 — the body warns before it ends the run.
##
## Health and mental each sit in one of four bands (SYSTEMS_DESIGN §3,
## thresholds `[첫 실행 재조정]`): stable >=60, caution 40~59, danger 20~39,
## collapse <20. When a stat drops into a lower band, the next free full-story
## week (no arc/milestone owns it) plays one existing scene that shows the body,
## never the number. Each band fires at most once per chapter per stat, and a
## scene is never reused, so a slide toward burnout/mental_break always passes
## through a danger scene first (D1 2026-11-24: two burnout runs had none).
##
## State lives in one flag, read and written only here:
##   flags["body_band_state"] = {"last": {"health": int, "mental": int},
##                               "fired": ["health:2:3", ...], "used": [event_id]}

const STATE_FLAG := "body_band_state"
const STATS: Array[String] = ["health", "mental"]
const BAND_STABLE := 0
const BAND_CAUTION := 1
const BAND_DANGER := 2
const BAND_COLLAPSE := 3

# Existing shipped scenes in five languages. Order is preference.
const SCENES := {
	"health": {
		BAND_CAUTION: ["health_sleep_debt", "health_checkup_reminder"],
		BAND_DANGER: ["work_burnout_monday", "drama_burnout_warning", "health_checkup_00"],
	},
	"mental": {
		BAND_CAUTION: ["health_insomnia"],
		BAND_DANGER: ["health_mental_burnout_signal", "health_burnout_signal"],
	},
}
# Scenes whose prose assumes a workplace.
const NEEDS_JOB: Array[String] = ["work_burnout_monday"]


static func band_of(value: Variant) -> int:
	var v := float(value) if (value is int or value is float) else 100.0
	if v >= 60.0:
		return BAND_STABLE
	if v >= 40.0:
		return BAND_CAUTION
	if v >= 20.0:
		return BAND_DANGER
	return BAND_COLLAPSE


static func chapter_of(turn: int) -> int:
	return clampi(int((maxi(turn, 1) - 1) / 48) + 1, 1, 5)


static func _state(flags: Dictionary) -> Dictionary:
	var raw: Variant = flags.get(STATE_FLAG, {})
	var state: Dictionary = (raw as Dictionary).duplicate(true) if raw is Dictionary else {}
	if not state.get("last", null) is Dictionary:
		state["last"] = {}
	if not state.get("fired", null) is Array:
		state["fired"] = []
	if not state.get("used", null) is Array:
		state["used"] = []
	return state


static func _pick(stat: String, band: int, used: Array, has_job: bool) -> String:
	var key := BAND_DANGER if band >= BAND_DANGER else BAND_CAUTION
	for event_id: String in (SCENES[stat] as Dictionary).get(key, []):
		if used.has(event_id):
			continue
		if event_id in NEEDS_JOB and not has_job:
			continue
		return event_id
	return ""


## Returns the event to play this free week ("" for none) and records it.
## `values` maps stat -> current value; `event_exists` filters ids the data
## registry cannot resolve. Pure on everything except flags[STATE_FLAG].
static func take_scene(flags: Dictionary, values: Dictionary, turn: int,
		has_job: bool, event_exists: Callable) -> String:
	var state := _state(flags)
	var last: Dictionary = state["last"]
	var fired: Array = state["fired"]
	var used: Array = state["used"]
	var chapter := chapter_of(turn)
	var chosen := ""
	# Danger before caution, health before mental: the worse signal speaks first.
	var order: Array = []
	for stat: String in STATS:
		order.append([stat, band_of(values.get(stat, 100))])
	order.sort_custom(func(a: Array, b: Array) -> bool:
		return int(a[1]) > int(b[1]))
	for row: Array in order:
		var stat := str(row[0])
		var band := int(row[1])
		var previous := int(last.get(stat, BAND_STABLE))
		if band <= previous:
			# Same or better: remember the recovery so a later slide speaks again.
			last[stat] = band
			continue
		var fired_key := "%s:%d:%d" % [stat, mini(band, BAND_DANGER), chapter]
		if chosen.is_empty() and not fired.has(fired_key):
			var event_id := _pick(stat, band, used, has_job)
			if not event_id.is_empty() and bool(event_exists.call(event_id)):
				chosen = event_id
				fired.append(fired_key)
				used.append(event_id)
				last[stat] = band
			elif event_id.is_empty():
				# Nothing left to show for this band; do not wait on it forever.
				last[stat] = band
		elif fired.has(fired_key):
			last[stat] = band
		# Otherwise keep it pending for the next free week.
	state["last"] = last
	state["fired"] = fired
	state["used"] = used
	flags[STATE_FLAG] = state
	return chosen
