extends RefCounted
## Fixed communication-phone state and retired device-purchase migration.
##
## The runtime phone exposes messages and contacts only. Schema-2 device
## ownership is accepted solely to refund the one purchase that the shipped
## prototype could actually create; schema 3 then records that the retired
## purchase path has already been settled.

const SCHEMA := 3
const LEGACY_SCHEMA := 2
const RETIRED_DEVICE_ID := "refurbished"
const RETIRED_PREVIOUS_DEVICE_ID := "starter"
const RETIRED_DEVICE_PRICE := 180_000.0
const RETIRED_DEVICE_AVAILABLE_WEEK := 13


static func phone_config() -> Dictionary:
	var raw: Variant = DataRegistry.demo_core_loop_v2.get("phone", {})
	if not raw is Dictionary:
		return {}
	return (raw as Dictionary).duplicate(true)


static func surface_contract() -> Dictionary:
	var raw: Variant = phone_config().get("surface", {})
	if not raw is Dictionary:
		return {}
	return (raw as Dictionary).duplicate(true)


static func default_state() -> Dictionary:
	return {
		"schema": SCHEMA,
		"device_purchase_retired": true,
		"legacy_refund_applied": true,
		"legacy_refund_amount": 0.0,
	}


## Returns the canonical schema-3 state without changing live money. Loading a
## save must use migration_result() so GameState can apply the returned refund
## after every serialized field, including money, has been restored.
static func normalized_state(raw: Variant) -> Dictionary:
	return (migration_result(raw).get("state", default_state()) as Dictionary).duplicate(true)


## Produces a pure migration transaction. Unknown keys are never retained.
## Schema-3 input is always inert, which makes save -> load -> save idempotent.
static func migration_result(
		raw: Variant, restored_turn: Variant = null) -> Dictionary:
	var state := default_state()
	if _is_schema(raw, SCHEMA):
		var source: Dictionary = raw
		var recorded_amount: Variant = source.get("legacy_refund_amount", 0.0)
		if _is_finite_number(recorded_amount) \
				and _amounts_match(float(recorded_amount), RETIRED_DEVICE_PRICE):
			state["legacy_refund_amount"] = RETIRED_DEVICE_PRICE
		return {
			"state": state,
			"refund_amount": 0.0,
			"migrated_legacy_purchase": false,
		}

	var refund_amount := _legacy_refund_amount(raw, restored_turn)
	if refund_amount > 0.0:
		state["legacy_refund_amount"] = refund_amount
	return {
		"state": state,
		"refund_amount": refund_amount,
		"migrated_legacy_purchase": refund_amount > 0.0,
	}


static func ensure_state() -> Dictionary:
	var state := normalized_state(GameState.phone_state)
	GameState.phone_state = state
	return state.duplicate(true)


static func _legacy_refund_amount(
		raw: Variant, restored_turn: Variant = null) -> float:
	if not _is_schema(raw, LEGACY_SCHEMA):
		return 0.0
	var source: Dictionary = raw
	if str(source.get("current_device_id", "")).strip_edges().to_lower() \
			!= RETIRED_DEVICE_ID:
		return 0.0

	var owned_raw: Variant = source.get("owned_device_ids", [])
	if not owned_raw is Array:
		return 0.0
	var owned_ids: Array[String] = []
	for raw_id in owned_raw:
		if not raw_id is String:
			return 0.0
		var owned_id := str(raw_id).strip_edges().to_lower()
		if owned_id not in [RETIRED_PREVIOUS_DEVICE_ID, RETIRED_DEVICE_ID] \
				or owned_ids.has(owned_id):
			return 0.0
		owned_ids.append(owned_id)
	if owned_ids.size() != 2 \
			or not owned_ids.has(RETIRED_PREVIOUS_DEVICE_ID) \
			or not owned_ids.has(RETIRED_DEVICE_ID):
		return 0.0

	var receipts_raw: Variant = source.get("purchase_receipts", [])
	if not receipts_raw is Array or (receipts_raw as Array).size() != 1:
		return 0.0
	var receipt_raw: Variant = (receipts_raw as Array)[0]
	if not receipt_raw is Dictionary:
		return 0.0
	var receipt: Dictionary = receipt_raw
	var required_keys := [
		"device_id",
		"previous_device_id",
		"price",
		"turn",
		"balance_before",
		"balance_after",
	]
	if receipt.size() != required_keys.size() \
			or not required_keys.all(func(key): return receipt.has(key)):
		return 0.0
	if str(receipt.get("device_id", "")).strip_edges().to_lower() \
			!= RETIRED_DEVICE_ID \
			or str(receipt.get("previous_device_id", "")).strip_edges().to_lower() \
			!= RETIRED_PREVIOUS_DEVICE_ID:
		return 0.0
	for numeric_key in ["price", "turn", "balance_before", "balance_after"]:
		if not _is_finite_number(receipt.get(numeric_key)):
			return 0.0

	var price := float(receipt.get("price", 0.0))
	var receipt_turn_value := float(receipt.get("turn", 0.0))
	var receipt_turn := int(receipt_turn_value)
	var balance_before := float(receipt.get("balance_before", 0.0))
	var balance_after := float(receipt.get("balance_after", 0.0))
	if not _amounts_match(price, RETIRED_DEVICE_PRICE) \
			or receipt_turn_value != float(receipt_turn) \
			or receipt_turn < RETIRED_DEVICE_AVAILABLE_WEEK \
			or balance_before < RETIRED_DEVICE_PRICE \
			or balance_after < 0.0 \
			or not _amounts_match(balance_before - price, balance_after):
		return 0.0
	if restored_turn != null:
		if not _is_finite_number(restored_turn) \
				or receipt_turn > int(float(restored_turn)):
			return 0.0
	return RETIRED_DEVICE_PRICE


static func _is_schema(raw: Variant, expected: int) -> bool:
	if not raw is Dictionary:
		return false
	var schema_value: Variant = (raw as Dictionary).get("schema")
	return _is_finite_number(schema_value) \
		and is_equal_approx(float(schema_value), float(expected))


static func _is_finite_number(value: Variant) -> bool:
	return (value is int or value is float) and is_finite(float(value))


static func _amounts_match(left: float, right: float) -> bool:
	return absf(left - right) <= 0.001
