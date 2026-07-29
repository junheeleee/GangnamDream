extends Node
## ORDER-57: deterministic phone state, app visibility, and device purchase gate.

const PHONE := preload("res://systems/PhoneSystem.gd")

var _failures: Array[String] = []


func _ready() -> void:
	_check_contract_surface()
	_check_app_visibility()
	_check_live_bank_snapshot()
	_check_state_migration()
	_check_purchase_guards_and_receipt()
	if _failures.is_empty():
		print(
			"PHONE_SYSTEM_CHECK_OK state=schema2/starter/migration "
			+ "apps=essential5/investment_flag/leisure_discovery/games_hidden "
			+ "bank=live/no_mirror devices=4/demo2 "
			+ "purchase=week13/180000/receipt/save favorite=opt_in/change/save "
			+ "guards=unknown/early/insufficient/duplicate/downgrade/planned_blocked "
			+ "neutrality=story/odds/returns/relationship")
		get_tree().quit(0)
		return
	for failure in _failures:
		push_error("PHONE_SYSTEM_CHECK_FAIL: %s" % failure)
	get_tree().quit(1)


func _check_contract_surface() -> void:
	var config := PHONE.phone_config()
	_expect(int(config.get("schema_version", 0)) == 2,
		"phone config schema is not 2")
	var home_grid: Array = config.get("home_grid", [])
	_expect(home_grid.size() == 2 \
			and int(home_grid[0]) == 4 and int(home_grid[1]) == 2,
		"phone home is not a 4x2 grid")
	_expect(PHONE.device_specs().size() == 4,
		"phone contract does not expose four ordered devices")
	_expect(int(PHONE.device_spec("starter").get("price", -1)) == 0 \
			and int(PHONE.device_spec("refurbished").get("price", -1)) == 180_000 \
			and int(PHONE.device_spec("midrange").get("price", -1)) == 550_000 \
			and int(PHONE.device_spec("flagship").get("price", -1)) == 1_200_000,
		"device prices drifted from the approved ladder")
	_expect(int(PHONE.device_spec("starter").get(
			"available_from_week", 0)) == 1 \
			and int(PHONE.device_spec("refurbished").get(
				"available_from_week", 0)) == 13 \
			and int(PHONE.device_spec("midrange").get(
				"available_from_week", 0)) == 25 \
			and int(PHONE.device_spec("flagship").get(
				"available_from_week", 0)) == 49,
		"device availability weeks drifted")
	_expect(bool(PHONE.device_spec("starter").get(
			"runtime_implemented", false)) \
			and bool(PHONE.device_spec("refurbished").get(
				"runtime_implemented", false)) \
			and not bool(PHONE.device_spec("midrange").get(
				"runtime_implemented", true)) \
			and not bool(PHONE.device_spec("flagship").get(
				"runtime_implemented", true)),
		"only starter and refurbished devices may charge money at runtime")
	_expect(bool(PHONE.device_spec("starter").get(
			"purchasable_in_demo", false)) \
			and bool(PHONE.device_spec("refurbished").get(
				"purchasable_in_demo", false)) \
			and not bool(PHONE.device_spec("midrange").get(
				"purchasable_in_demo", true)) \
			and not bool(PHONE.device_spec("flagship").get(
				"purchasable_in_demo", true)),
		"only starter and refurbished devices may be demo purchases")
	_expect((PHONE.device_spec("refurbished").get(
			"features", []) as Array).has("home_favorite_app"),
		"refurbished phone does not advertise its implemented home favorite")
	var mutated := PHONE.device_spec("refurbished")
	mutated["price"] = 1
	_expect(int(PHONE.device_spec("refurbished").get("price", 0)) == 180_000,
		"device_spec leaked its mutable config dictionary")


func _check_app_visibility() -> void:
	GameState.start_new_game()
	_expect(GameState.phone_state == PHONE.default_state(),
		"new game did not initialize the starter phone state")
	_expect(str(PHONE.current_device().get("id", "")) == "starter",
		"new game does not own the starter phone")
	var essential := PHONE.visible_app_ids()
	_expect(essential == [
			"messages", "calendar", "contacts", "bank", "device"],
		"new game does not expose exactly the five essential apps")
	_expect(not essential.has("games"),
		"post-launch games app leaked into the demo")
	_expect(str(PHONE.can_set_favorite_app("bank").get(
			"reason", "")) == "device_not_supported",
		"starter phone accepted an upgrade-only home favorite")

	GameState.flags["entered_network"] = true
	GameState.flags["gambling_tempted"] = true
	_expect(not PHONE.visible_app_ids().has("leisure"),
		"generic network or temptation flags revealed leisure without a place")
	GameState.flags["has_received_paycheck"] = true
	_expect(PHONE.visible_app_ids().has("investment"),
		"paycheck flag did not reveal the neutral investment app")
	GameState.flags.erase("has_received_paycheck")
	GameState.flags["had_first_investment"] = true
	_expect(PHONE.visible_app_ids().has("investment"),
		"existing investment flag did not restore the investment app")
	GameState.flags["racetrack_visited"] = true
	var unlocked := PHONE.visible_app_ids()
	_expect(unlocked.has("leisure"),
		"actual racetrack discovery did not reveal leisure")
	_expect(not unlocked.has("games"),
		"device or app unlocks revealed the post-launch games app")


func _check_live_bank_snapshot() -> void:
	GameState.start_new_game()
	GameState.money = -310_000.0
	GameState.loans = {"bank": 1_000_000.0, "second": 200_000.0}
	var first := PHONE.bank_snapshot()
	_expect(is_equal_approx(float(first.get("balance", 0.0)), -310_000.0) \
			and is_equal_approx(float(first.get("arrears", 0.0)), 310_000.0),
		"bank snapshot hid the negative balance or arrears")
	_expect(is_equal_approx(float(first.get("loan_total", 0.0)), 1_200_000.0) \
			and first.get("loans", {}) == GameState.loans,
		"bank snapshot did not read the live loan owner")
	_expect(is_equal_approx(
			float(first.get("next_fixed_expense", 0.0)),
			float(GameState.get_monthly_required_cash())),
		"bank snapshot invented a different next fixed expense")
	GameState.money = 50_000.0
	var second := PHONE.bank_snapshot()
	_expect(is_equal_approx(float(second.get("balance", 0.0)), 50_000.0) \
			and is_equal_approx(float(second.get("arrears", -1.0)), 0.0),
		"bank snapshot did not refresh from live cash")
	for forbidden in [
			"turn", "year", "month", "week_of_month", "money", "loans",
			"market_prices", "portfolio", "relationships", "cast"]:
		_expect(not GameState.phone_state.has(forbidden),
			"phone state mirrored live field %s" % forbidden)


func _check_state_migration() -> void:
	GameState.start_new_game()
	GameState.phone_state = {
		"schema": 999,
		"current_device_id": "refurbished",
		"money": 9_999_999,
		"loans": {"bank": 1},
		"turn": 99,
		"relationships": {"daeun": "committed"},
		"unknown": true,
	}
	var normalized := PHONE.ensure_state()
	_expect(normalized == {
			"schema": 2,
		"current_device_id": "refurbished",
		"owned_device_ids": ["starter", "refurbished"],
		"purchase_receipts": [],
		"favorite_app_id": "",
		},
		"phone normalization retained mirrors or discarded a valid device")
	_expect(GameState.phone_state == normalized,
		"ensure_state did not write the normalized state")

	GameState.phone_state = {"device_id": "refurbished"}
	_expect(str(PHONE.ensure_state().get(
			"current_device_id", "")) == "refurbished",
		"prototype device_id alias did not migrate")
	GameState.phone_state = {"current_device_id": "imaginary"}
	_expect(PHONE.ensure_state() == PHONE.default_state(),
		"unknown saved device did not fall back to starter")
	_expect(PHONE.normalized_state("damaged save") == PHONE.default_state(),
		"non-dictionary phone save did not recover")

	var legacy: Dictionary = GameState.serialize()
	legacy.erase("phone_state")
	GameState.phone_state = {"current_device_id": "refurbished"}
	GameState.load_from_dict(legacy)
	_expect(GameState.phone_state == PHONE.default_state(),
		"save without phone_state inherited stale runtime state")
	var damaged: Dictionary = GameState.serialize()
	damaged["phone_state"] = ["not", "a", "dictionary"]
	GameState.phone_state = {"current_device_id": "refurbished"}
	GameState.load_from_dict(damaged)
	_expect(GameState.phone_state == PHONE.default_state(),
		"damaged serialized phone_state did not normalize")


func _check_purchase_guards_and_receipt() -> void:
	GameState.start_new_game()
	GameState.turn = 13
	GameState.money = 500_000.0
	_expect(str(PHONE.can_purchase_device("missing").get(
			"reason", "")) == "unknown_device",
		"unknown device was not rejected")
	_expect(str(PHONE.can_purchase_device("starter").get(
			"reason", "")) == "already_owned",
		"current starter phone was not rejected as already owned")
	GameState.phone_state = {
		"schema": 2,
		"current_device_id": "starter",
		"owned_device_ids": ["starter", "refurbished"],
		"purchase_receipts": [],
	}
	_expect(str(PHONE.can_purchase_device("refurbished").get(
			"reason", "")) == "already_owned" \
			and is_equal_approx(float(GameState.money), 500_000.0),
		"owned-device ledger did not block a repeat purchase")
	GameState.phone_state = PHONE.default_state()
	GameState.turn = 12
	_expect(str(PHONE.can_purchase_device("refurbished").get(
			"reason", "")) == "not_yet_available",
		"refurbished phone opened before week 13")
	GameState.turn = 13
	GameState.money = 179_999.0
	var insufficient := PHONE.purchase_device("refurbished")
	_expect(not bool(insufficient.get("ok", true)) \
			and str(insufficient.get("reason", "")) == "insufficient_funds" \
			and is_equal_approx(float(GameState.money), 179_999.0) \
			and str(GameState.phone_state.get(
				"current_device_id", "")) == "starter",
		"insufficient purchase changed money or device")

	GameState.money = 500_000.0
	GameState.flags["has_received_paycheck"] = true
	GameState.flags["racetrack_visited"] = true
	GameState.market_prices = {"kospi": 123.45}
	GameState.portfolio = {"kospi": {"quantity": 2}}
	GameState.cast["daeun"]["affinity"] = 17
	GameState.investment_skill = 33
	GameState.gambling_tendency = 21
	var before: Dictionary = GameState.serialize().duplicate(true)
	var bought := PHONE.purchase_device("refurbished")
	var receipt_raw: Variant = bought.get("receipt", {})
	var receipt: Dictionary = {}
	if receipt_raw is Dictionary:
		receipt = (receipt_raw as Dictionary).duplicate(true)
	_expect(bool(bought.get("ok", false)) \
			and str(bought.get("reason", "")) == "purchased",
		"valid refurbished purchase failed")
	_expect(is_equal_approx(float(GameState.money), 320_000.0) \
			and is_equal_approx(float(bought.get(
				"balance_after", 0.0)), 320_000.0),
		"refurbished purchase did not deduct exactly KRW 180,000")
	_expect(receipt == {
			"device_id": "refurbished",
			"previous_device_id": "starter",
			"price": 180_000.0,
			"turn": 13,
			"balance_before": 500_000.0,
			"balance_after": 320_000.0,
		},
		"purchase receipt did not preserve exact device, price, and balances")
	_expect(GameState.phone_state == {
		"schema": 2,
		"current_device_id": "refurbished",
		"owned_device_ids": ["starter", "refurbished"],
			"purchase_receipts": [{
				"device_id": "refurbished",
				"previous_device_id": "starter",
				"price": 180_000.0,
				"turn": 13,
				"balance_before": 500_000.0,
				"balance_after": 320_000.0,
			}],
		"favorite_app_id": "",
		},
		"purchase did not persist exact ownership and receipt history")
	_expect(PHONE.favorite_app_id().is_empty(),
		"refurbished purchase moved a home app without the player's choice")
	var bank_favorite := PHONE.set_favorite_app("bank")
	_expect(bool(bank_favorite.get("ok", false)) \
			and PHONE.favorite_app_id() == "bank" \
			and str(PHONE.home_app_ids()[0]) == "bank" \
			and str(PHONE.visible_app_ids()[0]) == "messages",
		"refurbished phone did not separate availability from home ordering")
	var changed_favorite := PHONE.set_favorite_app("contacts")
	_expect(bool(changed_favorite.get("ok", false)) \
			and PHONE.favorite_app_id() == "contacts" \
			and str(PHONE.home_app_ids()[0]) == "contacts",
		"refurbished phone could not change the first home app")
	_expect(str(PHONE.set_favorite_app("games").get(
			"reason", "")) == "app_not_available",
		"hidden games app became a selectable home favorite")
	var after: Dictionary = GameState.serialize()
	for raw_key in before:
		var key := str(raw_key)
		if key in ["money", "phone_state"]:
			continue
		_expect(before.get(key) == after.get(key),
			"phone tier changed unrelated serialized owner %s" % key)
	_expect(PHONE.visible_app_ids().has("investment") \
			and PHONE.visible_app_ids().has("leisure") \
			and not PHONE.visible_app_ids().has("games"),
		"device purchase changed app discovery rules")

	var money_after_purchase := float(GameState.money)
	var duplicate := PHONE.purchase_device("refurbished")
	_expect(str(duplicate.get("reason", "")) == "already_owned" \
			and is_equal_approx(float(GameState.money), money_after_purchase),
		"duplicate purchase charged money")
	var downgrade := PHONE.purchase_device("starter")
	_expect(str(downgrade.get("reason", "")) == "downgrade_blocked" \
			and is_equal_approx(float(GameState.money), money_after_purchase),
		"downgrade was allowed or charged money")

	GameState.turn = 25
	GameState.money = 2_000_000.0
	_expect(str(PHONE.can_purchase_device("midrange", true).get(
			"reason", "")) == "not_implemented" \
			and is_equal_approx(float(GameState.money), 2_000_000.0),
		"midrange phone became purchasable before its features were implemented")
	_expect(str(PHONE.can_purchase_device("midrange", false).get(
			"reason", "")) == "not_implemented",
		"midrange phone charged money in a full build without its features")
	GameState.turn = 49
	_expect(str(PHONE.can_purchase_device("flagship", true).get(
			"reason", "")) == "not_implemented" \
			and is_equal_approx(float(GameState.money), 2_000_000.0),
		"flagship became purchasable before its features were implemented")
	_expect(str(PHONE.can_purchase_device("flagship", false).get(
			"reason", "")) == "not_implemented",
		"flagship charged money in a full build without its features")

	var saved: Dictionary = GameState.serialize()
	GameState.start_new_game()
	GameState.load_from_dict(saved)
	_expect(str(PHONE.current_device().get("id", "")) == "refurbished" \
			and is_equal_approx(float(GameState.money), 2_000_000.0) \
			and (GameState.phone_state.get(
				"owned_device_ids", []) as Array).has("refurbished") \
			and (GameState.phone_state.get(
				"purchase_receipts", []) as Array).size() == 1,
		"purchased phone ownership or receipt did not survive save/load")
	_expect(PHONE.favorite_app_id() == "contacts" \
			and str(PHONE.home_app_ids()[0]) == "contacts",
		"home favorite did not survive save/load")


func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)
