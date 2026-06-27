extends Node

signal item_purchased(item: Dictionary)
signal item_used(item: Dictionary)

func purchase_item(item_id):
	var item = DataRegistry.get_item(item_id)
	if item.is_empty():
		return {"success": false, "message": LocaleManager.ui("존재하지 않는 아이템입니다.", "Item does not exist.")}
	var price = float(item.get("price", 0.0))
	if GameState.money < price:
		return {"success": false, "message": LocaleManager.ui("돈이 부족합니다.", "Not enough money.")}
	GameState.add_money(-price)
	GameState.add_item(item_id, 1)
	GameState.add_log(LocaleManager.ui("%s 구매", "Purchased %s") % item.get("name", item_id), "item")
	item_purchased.emit(item)
	return {"success": true, "message": LocaleManager.ui("구매 완료", "Purchase complete")}

func use_item(item_id):
	var item = DataRegistry.get_item(item_id)
	if item.is_empty():
		return {"success": false, "message": LocaleManager.ui("아이템 오류", "Item error")}
	# 회복도 시간이다 — 사용은 행동력 1을 소모한다.
	# (무제한 사용 시 돈으로 스트레스 시스템을 우회하는 홀이 있었음. BALANCE.md 2026-06-11)
	if not GameState.spend_ap():
		return {"success": false, "message": LocaleManager.ui("행동력이 없습니다 — 다음 달에 사용하세요", "No AP left — use it next month")}
	GameState.apply_effects(item.get("effects", {}))
	if bool(item.get("one_time", true)):
		GameState.remove_item(item_id, 1)
	GameState.add_log(LocaleManager.ui("%s 사용", "Used %s") % item.get("name", item_id), "item")
	item_used.emit(item)
	return {"success": true, "message": LocaleManager.ui("사용 완료", "Use complete")}

func process_monthly_items():
	for owned in GameState.inventory:
		var item = DataRegistry.get_item(owned.get("id", ""))
		GameState.apply_effects(item.get("passive_effects", {}))

func get_shop_items():
	return DataRegistry.items
