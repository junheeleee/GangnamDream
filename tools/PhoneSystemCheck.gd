extends Node
## Fixed communication-phone contract and schema-2 purchase retirement gate.

const PHONE := preload("res://systems/PhoneSystem.gd")

var _failures: Array[String] = []


func _ready() -> void:
	_check_fixed_contact_surface()
	_check_new_game_and_normalization()
	_check_valid_purchase_refund_once()
	_check_damaged_or_forged_receipts_refund_zero()
	_check_device_runtime_contract_is_gone()
	if _failures.is_empty():
		print(
			"PHONE_SYSTEM_CHECK_OK state=schema3/retired/unknown_keys_stripped "
			+ "surface=portrait/messages_contacts/inbound_call/phone_kakao_card "
			+ "new_game_refund=0 legacy_valid_refund=180000/once "
			+ "damaged_forged_refund=0 runtime_devices=0 purchases=0 favorites=0")
		get_tree().quit(0)
		return
	for failure in _failures:
		push_error("PHONE_SYSTEM_CHECK_FAIL: %s" % failure)
	get_tree().quit(1)


func _check_fixed_contact_surface() -> void:
	var config := PHONE.phone_config()
	_expect(int(config.get("schema_version", 0)) == 3,
		"phone config schema is not 3")
	_expect(config.keys().size() == 4 \
			and config.has("persistent_fields") \
			and config.has("surface") \
			and config.has("legacy_migration"),
		"phone config retained an app grid, device ladder, or unknown root")
	_expect(config.get("persistent_fields", []) == [
		"schema",
		"device_purchase_retired",
		"legacy_refund_applied",
		"legacy_refund_amount",
	], "phone config persistent fields drifted")
	var surface := PHONE.surface_contract()
	_expect(surface == {
		"orientation": "portrait",
		"tabs": ["messages", "contacts"],
		"message_surfaces": ["inbound_message", "call_log"],
		"contact_methods": ["phone", "kakao", "business_card"],
	}, "phone is not the fixed portrait contact surface")
	var migration: Dictionary = config.get("legacy_migration", {})
	_expect(int(migration.get("source_schema", 0)) == 2 \
			and str(migration.get("refundable_device_id", "")) == "refurbished" \
			and str(migration.get("previous_device_id", "")) == "starter" \
			and int(migration.get("price", 0)) == 180_000 \
			and int(migration.get("available_from_week", 0)) == 13 \
			and bool(migration.get("refund_once", false)) \
			and migration.keys().size() == 6,
		"legacy migration config drifted from the only real purchase")
	var mutated := PHONE.surface_contract()
	mutated["tabs"] = ["device"]
	_expect(PHONE.surface_contract().get("tabs", []) == ["messages", "contacts"],
		"surface_contract leaked mutable config state")


func _check_new_game_and_normalization() -> void:
	GameState.start_new_game()
	var starting_money := float(GameState.money)
	_expect(GameState.phone_state == PHONE.default_state(),
		"new game did not start with a settled schema-3 phone state")
	_expect(is_equal_approx(
		float(GameState.phone_state.get("legacy_refund_amount", -1.0)), 0.0) \
			and is_equal_approx(float(GameState.money), starting_money),
		"new game invented a retired-device refund")

	var normalized := PHONE.normalized_state({
		"schema": 3,
		"device_purchase_retired": false,
		"legacy_refund_applied": false,
		"legacy_refund_amount": 180_000,
		"current_device_id": "refurbished",
		"purchase_receipts": [_valid_receipt()],
		"money": 99_999_999,
		"unknown": true,
	})
	_expect(normalized == {
		"schema": 3,
		"device_purchase_retired": true,
		"legacy_refund_applied": true,
		"legacy_refund_amount": 180_000.0,
	}, "schema-3 normalization retained device fields or unknown mirrors")
	_expect(is_equal_approx(float(
		PHONE.migration_result(normalized).get("refund_amount", -1.0)), 0.0),
		"settled schema-3 state became refundable again")
	_expect(PHONE.normalized_state("damaged save") == PHONE.default_state(),
		"non-dictionary phone save did not recover without a refund")

	var missing_phone: Dictionary = GameState.serialize().duplicate(true)
	missing_phone.erase("phone_state")
	GameState.phone_state = {"schema": 2, "unknown": true}
	GameState.load_from_dict(missing_phone)
	_expect(GameState.phone_state == PHONE.default_state() \
			and is_equal_approx(float(GameState.money), starting_money),
		"save without phone_state inherited stale runtime state or a refund")


func _check_valid_purchase_refund_once() -> void:
	GameState.start_new_game()
	GameState.flags["phone_refund_neutrality_probe"] = true
	GameState.portfolio = {"kospi": {"quantity": 2}}
	GameState.cast["daeun"]["affinity"] = 17
	var legacy_save: Dictionary = GameState.serialize().duplicate(true)
	legacy_save["money"] = 320_000.0
	legacy_save["turn"] = 20
	legacy_save["phone_state"] = _valid_legacy_state()

	GameState.money = -9_999_999.0
	GameState.phone_state = {"schema": 999, "unknown": true}
	GameState.load_from_dict(legacy_save)
	_expect(is_equal_approx(float(GameState.money), 500_000.0),
		"valid retired purchase did not refund exactly KRW 180,000")
	_expect(GameState.phone_state == {
		"schema": 3,
		"device_purchase_retired": true,
		"legacy_refund_applied": true,
		"legacy_refund_amount": 180_000.0,
	}, "valid retired purchase did not settle to the exact schema-3 state")
	_expect(bool(GameState.flags.get("phone_refund_neutrality_probe", false)) \
			and GameState.portfolio == {"kospi": {"quantity": 2}} \
			and int(GameState.cast["daeun"].get("affinity", 0)) == 17,
		"phone refund changed unrelated story, market, or relationship state")

	var settled_save: Dictionary = GameState.serialize().duplicate(true)
	GameState.money = -8_888_888.0
	GameState.phone_state = {}
	GameState.load_from_dict(settled_save)
	_expect(is_equal_approx(float(GameState.money), 500_000.0) \
			and GameState.phone_state == settled_save.get("phone_state", {}),
		"saving then reloading a settled refund added money a second time")


func _check_damaged_or_forged_receipts_refund_zero() -> void:
	var invalid_states: Array = []
	invalid_states.append("not a dictionary")
	invalid_states.append({"schema": 999, "purchase_receipts": [_valid_receipt()]})

	var invalid := _valid_legacy_state()
	invalid["current_device_id"] = "starter"
	invalid_states.append(invalid)
	invalid = _valid_legacy_state()
	invalid["owned_device_ids"] = ["starter"]
	invalid_states.append(invalid)
	invalid = _valid_legacy_state()
	invalid["owned_device_ids"] = ["starter", "refurbished", "midrange"]
	invalid_states.append(invalid)
	invalid = _valid_legacy_state()
	invalid["purchase_receipts"] = [_valid_receipt(), _valid_receipt()]
	invalid_states.append(invalid)
	invalid = _valid_legacy_state()
	_set_receipt_field(invalid, "price", 179_999.0)
	invalid_states.append(invalid)
	invalid = _valid_legacy_state()
	_set_receipt_field(invalid, "turn", 12)
	invalid_states.append(invalid)
	invalid = _valid_legacy_state()
	_set_receipt_field(invalid, "balance_after", 319_999.0)
	invalid_states.append(invalid)
	invalid = _valid_legacy_state()
	_set_receipt_field(invalid, "balance_after", -1.0)
	invalid_states.append(invalid)
	invalid = _valid_legacy_state()
	var missing_key_receipt: Dictionary = (
		invalid.get("purchase_receipts", [])[0] as Dictionary).duplicate(true)
	missing_key_receipt.erase("previous_device_id")
	invalid["purchase_receipts"] = [missing_key_receipt]
	invalid_states.append(invalid)
	invalid = _valid_legacy_state()
	_set_receipt_field(invalid, "forged_key", true)
	invalid_states.append(invalid)
	invalid = _valid_legacy_state()
	_set_receipt_field(invalid, "price", "180000")
	invalid_states.append(invalid)

	for index in range(invalid_states.size()):
		GameState.start_new_game()
		var save: Dictionary = GameState.serialize().duplicate(true)
		save["money"] = 123_456.0
		save["turn"] = 20
		save["phone_state"] = invalid_states[index]
		GameState.money = -1.0
		GameState.phone_state = {"schema": 2}
		GameState.load_from_dict(save)
		_expect(is_equal_approx(float(GameState.money), 123_456.0),
			"damaged or forged receipt %d produced a refund" % index)
		_expect(GameState.phone_state == PHONE.default_state(),
			"damaged or forged receipt %d survived normalization" % index)

	GameState.start_new_game()
	var time_travel_save: Dictionary = GameState.serialize().duplicate(true)
	time_travel_save["money"] = 123_456.0
	time_travel_save["turn"] = 12
	time_travel_save["phone_state"] = _valid_legacy_state()
	GameState.load_from_dict(time_travel_save)
	_expect(is_equal_approx(float(GameState.money), 123_456.0) \
			and GameState.phone_state == PHONE.default_state(),
		"receipt dated after the restored save turn produced a refund")


func _check_device_runtime_contract_is_gone() -> void:
	var source := FileAccess.get_file_as_string("res://systems/PhoneSystem.gd")
	for forbidden_signature in [
		"static func device_specs(",
		"static func device_spec(",
		"static func current_device(",
		"static func visible_app_ids(",
		"static func home_app_ids(",
		"static func favorite_app_id(",
		"static func can_set_favorite_app(",
		"static func set_favorite_app(",
		"static func bank_snapshot(",
		"static func can_purchase_device(",
		"static func purchase_device(",
	]:
		_expect(source.find(forbidden_signature) < 0,
			"retired public runtime API remains: %s" % forbidden_signature)
	for forbidden_config_key in [
		"home_grid", "app_order", "apps", "device_order", "devices",
		"purchase_contract", "tier_neutrality",
	]:
		_expect(not PHONE.phone_config().has(forbidden_config_key),
			"retired phone config key remains: %s" % forbidden_config_key)


func _valid_legacy_state() -> Dictionary:
	return {
		"schema": 2,
		"current_device_id": "refurbished",
		"owned_device_ids": ["starter", "refurbished"],
		"purchase_receipts": [_valid_receipt()],
		"favorite_app_id": "bank",
		# Unknown schema-2 mirrors are stripped but do not erase an otherwise
		# authentic immutable receipt.
		"money": 99_999_999,
		"unknown": true,
	}


func _valid_receipt() -> Dictionary:
	return {
		"device_id": "refurbished",
		"previous_device_id": "starter",
		"price": 180_000.0,
		"turn": 13,
		"balance_before": 500_000.0,
		"balance_after": 320_000.0,
	}


func _set_receipt_field(state: Dictionary, key: String, value: Variant) -> void:
	var receipts_raw: Variant = state.get("purchase_receipts", [])
	if not receipts_raw is Array or (receipts_raw as Array).is_empty():
		return
	var receipt: Dictionary = ((receipts_raw as Array)[0] as Dictionary).duplicate(true)
	receipt[key] = value
	state["purchase_receipts"] = [receipt]


func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)
