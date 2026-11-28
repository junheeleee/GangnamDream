extends RefCounted
## ORDER-840 G2: the hold'em club's four regulars (full run only).
##
## Two of four fixed people sit at each visit, chosen by the week. Each has a
## style (aggression, bluff rate) and two tells. The behaviour is always on
## the table — a raise can come with "Manager Do touches his chips twice" —
## with the ledger's odds whether or not it means anything; the player's
## notebook gains one tell's meaning every few visits. Reading it is the edge.
## One regular (Boss Yoon) runs out of money and asks for a loan on the
## stairs, then stops coming; one (Ms. Han) quits. Their state lives in the
## `holdem_regulars` flag so a later scene can read who is gone and what was
## lent.

const LEDGER_PATH := "res://content/meta/holdem_regulars_ledger.json"
const STATE_FLAG := "holdem_regulars"

static var _ledger_cache: Dictionary = {}


static func ledger() -> Dictionary:
	if _ledger_cache.is_empty():
		var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(LEDGER_PATH))
		_ledger_cache = parsed if parsed is Dictionary else {}
	return _ledger_cache


static func regular(rid: String) -> Dictionary:
	for raw in ledger().get("regulars", []):
		if str((raw as Dictionary).get("id", "")) == rid:
			return raw
	return {}


static func ids() -> Array:
	var out: Array = []
	for raw in ledger().get("regulars", []):
		out.append(str((raw as Dictionary).get("id", "")))
	return out


## The state dictionary inside flags, created on first use.
static func state(flags: Dictionary) -> Dictionary:
	var raw: Variant = flags.get(STATE_FLAG, null)
	if not (raw is Dictionary):
		raw = {}
		flags[STATE_FLAG] = raw
	var st: Dictionary = raw
	for key in ["visits", "gone", "gone_turn"]:
		if not (st.get(key, null) is Dictionary):
			st[key] = {}
	if not st.has("lent"):
		st["lent"] = 0
	if not st.has("news_shown"):
		st["news_shown"] = false
	return st


static func is_gone(flags: Dictionary, rid: String) -> bool:
	return (state(flags)["gone"] as Dictionary).has(rid)


static func visits(flags: Dictionary, rid: String) -> int:
	return int((state(flags)["visits"] as Dictionary).get(rid, 0))


static func tells_known(flags: Dictionary, rid: String) -> int:
	var per := maxi(1, int(ledger().get("visits_per_tell", 2)))
	var tells: Array = regular(rid).get("tells", [])
	return mini(tells.size(), floori(float(visits(flags, rid)) / float(per)))


## Two seats for this week. Regulars who are gone never sit again.
static func seat(flags: Dictionary, turn: int) -> Array:
	var pool: Array = []
	for rid in ids():
		if not is_gone(flags, rid):
			pool.append(rid)
	var rng := RandomNumberGenerator.new()
	rng.seed = hash("holdem_regulars:%d" % turn)
	for i in range(pool.size() - 1, 0, -1):
		var j := rng.randi_range(0, i)
		var tmp: Variant = pool[i]
		pool[i] = pool[j]
		pool[j] = tmp
	return pool.slice(0, mini(int(ledger().get("seats", 2)), pool.size()))


## Called once a visit ends. Counts the visit for each seated regular when
## enough hands were played and returns the tell notes newly written.
static func record_visit(flags: Dictionary, seated: Array, hands: int) -> Array:
	var learned: Array = []
	if hands < int(ledger().get("min_hands_for_visit", 3)):
		return learned
	var st := state(flags)
	for rid in seated:
		var before := tells_known(flags, str(rid))
		(st["visits"] as Dictionary)[rid] = visits(flags, str(rid)) + 1
		var after := tells_known(flags, str(rid))
		for k in range(before, after):
			learned.append(tell_note(str(rid), k))
	return learned


static func debt_due(flags: Dictionary, seated: Array, turn: int) -> bool:
	var debt: Dictionary = ledger().get("debt", {})
	var rid := str(debt.get("regular", ""))
	return seated.has(rid) and not is_gone(flags, rid) \
		and visits(flags, rid) >= int(debt.get("min_visits", 4)) \
		and turn >= int(debt.get("min_turn", 97))


static func loan_amount() -> int:
	return int((ledger().get("debt", {}) as Dictionary).get("loan", 3_000_000))


## The stairs scene's answer. Either way he stops coming.
static func settle_debt(flags: Dictionary, turn: int, lent: int) -> void:
	var rid := str((ledger().get("debt", {}) as Dictionary).get("regular", ""))
	var st := state(flags)
	(st["gone"] as Dictionary)[rid] = "debt"
	(st["gone_turn"] as Dictionary)[rid] = turn
	st["lent"] = lent


static func debt_news_due(flags: Dictionary, turn: int) -> bool:
	var debt: Dictionary = ledger().get("debt", {})
	var rid := str(debt.get("regular", ""))
	var st := state(flags)
	if not is_gone(flags, rid) or bool(st.get("news_shown", false)):
		return false
	return turn >= int((st["gone_turn"] as Dictionary).get(rid, 0)) + int(debt.get("news_gap_weeks", 8))


static func mark_news_shown(flags: Dictionary) -> void:
	state(flags)["news_shown"] = true


## After a counted visit: the regular who quits says so at the table.
static func quit_due(flags: Dictionary, seated: Array) -> bool:
	var quit: Dictionary = ledger().get("quit", {})
	var rid := str(quit.get("regular", ""))
	return seated.has(rid) and not is_gone(flags, rid) \
		and visits(flags, rid) >= int(quit.get("min_visits", 5))


static func settle_quit(flags: Dictionary, turn: int) -> void:
	var rid := str((ledger().get("quit", {}) as Dictionary).get("regular", ""))
	var st := state(flags)
	(st["gone"] as Dictionary)[rid] = "quit"
	(st["gone_turn"] as Dictionary)[rid] = turn


## The behaviour seen at the table for one AI decision, or "".
## A bluff tell shows on a raise; a strong tell on a raise or call. Whether it
## means anything follows the ledger's odds, not the notebook.
static func observed_tell(rid: String, decision: Dictionary, rng: RandomNumberGenerator) -> String:
	var action := str(decision.get("action", ""))
	if action != "raise" and action != "call":
		return ""
	var show: Dictionary = ledger().get("tell_show", {})
	var bluffing := bool(decision.get("bluff", false))
	var strong := not bluffing and float(decision.get("strength", 0.0)) >= float(ledger().get("strong_hand", 0.72))
	var tells: Array = regular(rid).get("tells", [])
	for k in range(tells.size()):
		var kind := str((tells[k] as Dictionary).get("kind", ""))
		if kind == "bluff" and action != "raise":
			continue
		var truth := bluffing if kind == "bluff" else strong
		if rng.randf() < float(show.get("true" if truth else "false", 0.0)):
			return tell_seen(rid, k)
	return ""


# ── Text ─────────────────────────────────────────────────────────

static func _tr(ko: String, en: String) -> String:
	return LocaleManager.ui(ko, en)


static func display_name(rid: String) -> String:
	match rid:
		"park_driver": return _tr("박 기사", "Mr. Park")
		"yoon_boss": return _tr("윤 사장", "Boss Yoon")
		"do_manager": return _tr("도 실장", "Manager Do")
		"han_teacher": return _tr("한 선생", "Ms. Han")
	return "?"


static func description(rid: String) -> String:
	match rid:
		"park_driver": return _tr("택시를 몬다. 말이 없고, 오래 앉아 있는다.", "Drives a cab. Says little, sits long.")
		"yoon_boss": return _tr("판이 작으면 지루해한다.", "Gets bored when the pot is small.")
		"do_manager": return _tr("농담이 많고, 지는 날에도 웃는다.", "Jokes a lot, and laughs even on losing nights.")
		"han_teacher": return _tr("학원 강사. 팟을 셀 때 입술이 움직인다.", "A cram-school teacher. Her lips move when she counts the pot.")
	return ""


static func tell_seen(rid: String, k: int) -> String:
	match "%s:%d" % [rid, k]:
		"park_driver:0": return _tr("박 기사가 등을 의자에 붙인다.", "Mr. Park leans back into his chair.")
		"park_driver:1": return _tr("박 기사가 칩을 한 줄로 반듯하게 민다.", "Mr. Park pushes his chips in a perfectly neat line.")
		"yoon_boss:0": return _tr("윤 사장의 목소리가 커진다.", "Boss Yoon's voice gets louder.")
		"yoon_boss:1": return _tr("윤 사장이 시계를 풀어 내려놓는다.", "Boss Yoon takes off his watch and sets it down.")
		"do_manager:0": return _tr("도 실장이 칩을 두 번 만진다.", "Manager Do touches his chips twice.")
		"do_manager:1": return _tr("도 실장이 말이 없다.", "Manager Do has gone quiet.")
		"han_teacher:0": return _tr("한 선생이 물을 마신다.", "Ms. Han takes a sip of water.")
		"han_teacher:1": return _tr("한 선생이 팟을 두 번 센다.", "Ms. Han counts the pot twice.")
	return ""


static func tell_note(rid: String, k: int) -> String:
	match "%s:%d" % [rid, k]:
		"park_driver:0": return _tr("박 기사 — 좋은 패가 오면 등을 의자에 붙인다.", "Mr. Park — when the cards are good, he leans back.")
		"park_driver:1": return _tr("박 기사 — 허세를 부릴 땐 칩을 너무 반듯하게 민다.", "Mr. Park — when he bluffs, his chips go in too neat a line.")
		"yoon_boss:0": return _tr("윤 사장 — 패가 없을수록 목소리가 커진다.", "Boss Yoon — the less he holds, the louder he gets.")
		"yoon_boss:1": return _tr("윤 사장 — 진짜 패면 시계를 풀어 내려놓는다.", "Boss Yoon — when the hand is real, the watch comes off.")
		"do_manager:0": return _tr("도 실장 — 블러프할 때 칩을 두 번 만진다.", "Manager Do — when he bluffs, he touches his chips twice.")
		"do_manager:1": return _tr("도 실장 — 패가 좋으면 농담이 사라진다.", "Manager Do — when his hand is good, the jokes stop.")
		"han_teacher:0": return _tr("한 선생 — 확신이 서면 계산을 멈추고 물을 마신다.", "Ms. Han — when she is sure, she stops counting and drinks water.")
		"han_teacher:1": return _tr("한 선생 — 블러프는 드물다. 할 때는 팟을 두 번 센다.", "Ms. Han — she rarely bluffs. When she does, she counts the pot twice.")
	return ""


static func gone_line(rid: String, reason: String) -> String:
	if reason == "quit":
		return _tr("%s — 그만뒀다.", "%s — quit.") % display_name(rid)
	return _tr("%s — 더 이상 오지 않는다.", "%s — doesn't come anymore.") % display_name(rid)
