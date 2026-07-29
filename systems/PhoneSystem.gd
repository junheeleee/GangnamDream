extends RefCounted
## ORDER-57 phone state and purchase contract.
##
## The saved state owns device history and immutable purchase receipts. Current
## date, cash, debt, market, and relationship values remain in GameState and
## are read on demand.

const SCHEMA := 2
const STARTER_DEVICE_ID := "starter"


static func phone_config() -> Dictionary:
	var raw: Variant = DataRegistry.demo_core_loop_v2.get("phone", {})
	if not raw is Dictionary:
		return {}
	return (raw as Dictionary).duplicate(true)


static func default_state() -> Dictionary:
	return {
		"schema": SCHEMA,
		"current_device_id": STARTER_DEVICE_ID,
		"owned_device_ids": [STARTER_DEVICE_ID],
		"purchase_receipts": [],
		"favorite_app_id": "",
	}


static func normalized_state(raw: Variant) -> Dictionary:
	var state := default_state()
	if not raw is Dictionary:
		return state
	var source: Dictionary = raw
	# Accept the two short-lived prototype aliases, but never retain unknown
	# keys. This also strips accidental mirrors of live GameState values.
	var device_id := str(source.get(
		"current_device_id",
		source.get("device_id", source.get("device", STARTER_DEVICE_ID))
	)).strip_edges().to_lower()
	if not device_spec(device_id).is_empty():
		state["current_device_id"] = device_id
	var valid_ids: Array = []
	for raw_spec in device_specs():
		if raw_spec is Dictionary:
			valid_ids.append(str((raw_spec as Dictionary).get("id", "")))
	var owned_ids: Array = [STARTER_DEVICE_ID]
	var raw_owned: Variant = source.get("owned_device_ids", [])
	if raw_owned is Array:
		for raw_id in raw_owned:
			var owned_id := str(raw_id).strip_edges().to_lower()
			if valid_ids.has(owned_id) and not owned_ids.has(owned_id):
				owned_ids.append(owned_id)
	if not owned_ids.has(str(state["current_device_id"])):
		owned_ids.append(str(state["current_device_id"]))

	var receipts: Array = []
	var receipt_devices: Array = []
	var raw_receipts: Variant = source.get("purchase_receipts", [])
	if raw_receipts is Array:
		for raw_receipt in raw_receipts:
			if not raw_receipt is Dictionary:
				continue
			var receipt: Dictionary = raw_receipt
			var receipt_keys := [
				"device_id",
				"previous_device_id",
				"price",
				"turn",
				"balance_before",
				"balance_after",
			]
			if not receipt_keys.all(func(key): return receipt.has(key)):
				continue
			var bought_id := str(
				receipt.get("device_id", "")).strip_edges().to_lower()
			var previous_id := str(
				receipt.get("previous_device_id", "")).strip_edges().to_lower()
			var price := float(receipt.get("price", -1.0))
			var receipt_turn := int(receipt.get("turn", 0))
			var balance_before := float(
				receipt.get("balance_before", 0.0))
			var balance_after := float(receipt.get("balance_after", 0.0))
			if not valid_ids.has(bought_id) \
					or not valid_ids.has(previous_id) \
					or bought_id == STARTER_DEVICE_ID \
					or receipt_devices.has(bought_id) \
					or price < 0.0 \
					or receipt_turn < 1 \
					or absf(
						(balance_before - price) - balance_after) > 0.001:
				continue
			var bought := device_spec(bought_id)
			var previous := device_spec(previous_id)
			if int(bought.get("tier", -1)) <= int(previous.get("tier", -1)):
				continue
			receipts.append({
				"device_id": bought_id,
				"previous_device_id": previous_id,
				"price": price,
				"turn": receipt_turn,
				"balance_before": balance_before,
				"balance_after": balance_after,
			})
			receipt_devices.append(bought_id)
			if not owned_ids.has(bought_id):
				owned_ids.append(bought_id)

	var ordered_owned: Array = []
	for valid_id in valid_ids:
		if owned_ids.has(valid_id):
			ordered_owned.append(valid_id)
	state["owned_device_ids"] = ordered_owned
	state["purchase_receipts"] = receipts
	var favorite_app_id := str(
		source.get("favorite_app_id", "")).strip_edges().to_lower()
	if _device_supports_home_favorite(str(state["current_device_id"])) \
			and _configured_app_ids().has(favorite_app_id) \
			and favorite_app_id not in ["device", "games"]:
		state["favorite_app_id"] = favorite_app_id
	return state


static func ensure_state() -> Dictionary:
	var state := normalized_state(GameState.phone_state)
	GameState.phone_state = state
	return state.duplicate(true)


static func device_specs() -> Array:
	var config := phone_config()
	var devices_raw: Variant = config.get("devices", {})
	var order_raw: Variant = config.get("device_order", [])
	if not devices_raw is Dictionary or not order_raw is Array:
		return []
	var devices: Dictionary = devices_raw
	var result: Array = []
	for raw_id in order_raw:
		var device_id := str(raw_id)
		var raw_spec: Variant = devices.get(device_id, {})
		if not raw_spec is Dictionary:
			continue
		var spec: Dictionary = (raw_spec as Dictionary).duplicate(true)
		spec["id"] = device_id
		result.append(spec)
	return result


static func device_spec(id: String) -> Dictionary:
	var wanted := id.strip_edges().to_lower()
	for raw_spec in device_specs():
		if not raw_spec is Dictionary:
			continue
		var spec: Dictionary = raw_spec
		if str(spec.get("id", "")) == wanted:
			return spec.duplicate(true)
	return {}


static func current_device() -> Dictionary:
	var state := ensure_state()
	return device_spec(str(state.get(
		"current_device_id", STARTER_DEVICE_ID)))


static func app_spec(id: String) -> Dictionary:
	var wanted := id.strip_edges().to_lower()
	var config := phone_config()
	var apps_raw: Variant = config.get("apps", {})
	if not apps_raw is Dictionary:
		return {}
	var raw_spec: Variant = (apps_raw as Dictionary).get(wanted, {})
	if not raw_spec is Dictionary:
		return {}
	var spec: Dictionary = (raw_spec as Dictionary).duplicate(true)
	spec["id"] = wanted
	return spec


static func visible_app_ids() -> Array:
	var config := phone_config()
	var order_raw: Variant = config.get("app_order", [])
	if not order_raw is Array:
		return []
	var result: Array = []
	for raw_id in order_raw:
		var app_id := str(raw_id)
		var spec := app_spec(app_id)
		if spec.is_empty():
			continue
		var availability_raw: Variant = spec.get("availability", {})
		if not availability_raw is Dictionary:
			continue
		var availability: Dictionary = availability_raw
		match str(availability.get("kind", "")):
			"always":
				result.append(app_id)
			"any_flag":
				for raw_flag in availability.get("flags", []):
					if bool(GameState.flags.get(str(raw_flag), false)):
						result.append(app_id)
						break
			# Post-launch games remain absent rather than advertising locked
			# future content in the 24-week demo.
			"post_launch":
				pass
	return result


static func home_app_ids() -> Array:
	var result := visible_app_ids()
	var favorite_id := favorite_app_id()
	if result.has(favorite_id):
		result.erase(favorite_id)
		result.push_front(favorite_id)
	return result


static func favorite_app_id() -> String:
	var state := ensure_state()
	return str(state.get("favorite_app_id", ""))


static func favorite_app_candidates() -> Array:
	var result: Array = []
	for raw_app_id in visible_app_ids():
		var app_id := str(raw_app_id)
		if app_id not in ["device", "games"]:
			result.append(app_id)
	return result


static func can_set_favorite_app(id: String) -> Dictionary:
	var app_id := id.strip_edges().to_lower()
	var current_id := str(ensure_state().get(
		"current_device_id", STARTER_DEVICE_ID))
	var result := {
		"ok": false,
		"reason": "device_not_supported",
		"app_id": app_id,
		"device_id": current_id,
	}
	if not _device_supports_home_favorite(current_id):
		return result
	if app_id not in favorite_app_candidates():
		result["reason"] = "app_not_available"
		return result
	result["ok"] = true
	result["reason"] = "ok"
	return result


static func set_favorite_app(id: String) -> Dictionary:
	var result := can_set_favorite_app(id)
	if not bool(result.get("ok", false)):
		return result
	var state := ensure_state()
	state["favorite_app_id"] = str(result.get("app_id", ""))
	GameState.phone_state = normalized_state(state)
	result["reason"] = "saved"
	return result


static func bank_snapshot() -> Dictionary:
	var live_loans: Dictionary = {}
	for raw_product in GameState.loans:
		var product := str(raw_product)
		live_loans[product] = maxf(
			0.0, float(GameState.loans.get(raw_product, 0.0)))
	var balance := float(GameState.money)
	return {
		"balance": balance,
		"loan_total": float(GameState.get_loan_total()),
		"loans": live_loans,
		"next_fixed_expense": float(GameState.get_monthly_required_cash()),
		"arrears": maxf(0.0, -balance),
	}


static func can_purchase_device(
		id: String, demo_build_override: Variant = null) -> Dictionary:
	var device := device_spec(id)
	var balance_before := float(GameState.money)
	var price := float(device.get("price", 0.0))
	var demo_limited := GameState.is_demo_build() \
		if demo_build_override == null else bool(demo_build_override)
	var result := {
		"ok": false,
		"reason": "unknown_device",
		"device": device,
		"price": price,
		"balance_before": balance_before,
		"balance_after": balance_before - price,
		"available_from_week": int(device.get("available_from_week", 0)),
	}
	if device.is_empty():
		return result
	if not bool(device.get("runtime_implemented", false)):
		result["reason"] = "not_implemented"
		return result

	var state := ensure_state()
	var current_id := str(state.get(
		"current_device_id", STARTER_DEVICE_ID))
	var current := device_spec(current_id)
	if str(device.get("id", "")) == current_id:
		result["reason"] = "already_owned"
		return result
	if int(device.get("tier", -1)) < int(current.get("tier", 0)):
		result["reason"] = "downgrade_blocked"
		return result
	if (state.get("owned_device_ids", []) as Array).has(
			str(device.get("id", ""))):
		result["reason"] = "already_owned"
		return result
	if demo_limited and not bool(device.get("purchasable_in_demo", false)):
		result["reason"] = "not_purchasable_in_demo"
		return result
	if GameState.turn < int(device.get("available_from_week", 1)):
		result["reason"] = "not_yet_available"
		return result
	if balance_before < price:
		result["reason"] = "insufficient_funds"
		return result
	result["ok"] = true
	result["reason"] = "ok"
	return result


static func purchase_device(
		id: String, demo_build_override: Variant = null) -> Dictionary:
	var result := can_purchase_device(id, demo_build_override)
	if not bool(result.get("ok", false)):
		return result

	var device: Dictionary = result.get("device", {})
	var price := float(result.get("price", 0.0))
	var balance_before := float(GameState.money)
	var state := ensure_state()
	var previous_device_id := str(state.get(
		"current_device_id", STARTER_DEVICE_ID))
	state["current_device_id"] = str(device.get("id", ""))
	var balance_after := balance_before - price
	var receipt := {
		"device_id": str(device.get("id", "")),
		"previous_device_id": previous_device_id,
		"price": price,
		"turn": int(GameState.turn),
		"balance_before": balance_before,
		"balance_after": balance_after,
	}
	var owned_ids: Array = state.get("owned_device_ids", [])
	if not owned_ids.has(str(device.get("id", ""))):
		owned_ids.append(str(device.get("id", "")))
	state["owned_device_ids"] = owned_ids
	var receipts: Array = state.get("purchase_receipts", [])
	receipts.append(receipt)
	state["purchase_receipts"] = receipts
	GameState.phone_state = normalized_state(state)
	GameState.add_money(-price)
	balance_after = float(GameState.money)
	result["ok"] = true
	result["reason"] = "purchased"
	result["balance_before"] = balance_before
	result["balance_after"] = balance_after
	result["receipt"] = receipt
	result["device"] = current_device()
	return result


static func _configured_app_ids() -> Array:
	var config := phone_config()
	var raw_order: Variant = config.get("app_order", [])
	return (raw_order as Array).duplicate() if raw_order is Array else []


static func _device_supports_home_favorite(device_id: String) -> bool:
	var spec := device_spec(device_id)
	var raw_features: Variant = spec.get("features", [])
	return raw_features is Array \
		and (raw_features as Array).has("home_favorite_app")
