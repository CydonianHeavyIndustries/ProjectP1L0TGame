extends Node
class_name EconomySystem

signal inventory_updated
signal credits_updated

func add_credits(amount: int) -> void:
	if amount == 0:
		return
	SaveManager.add_credits(amount)
	emit_signal("credits_updated")

func spend_credits(amount: int) -> bool:
	var ok = SaveManager.spend_credits(amount)
	if ok:
		emit_signal("credits_updated")
	return ok

func get_credits() -> int:
	return SaveManager.get_currency().get("credits", 0)

func get_inventory_items() -> Array:
	return SaveManager.get_inventory().get("items", [])

func add_item(item_id: String, amount: int = 1) -> void:
	if ItemDatabase.get_item(item_id).is_empty():
		if DebugConfig.LOGGING:
			print("[EconomySystem] Unknown item: ", item_id)
		return

	var inventory = SaveManager.get_inventory()
	var items: Array = inventory.get("items", [])
	var updated := false
	for stack in items:
		if stack.get("id", "") == item_id:
			stack["qty"] = int(stack.get("qty", 0)) + amount
			updated = true
			break
	if not updated:
		items.append({"id": item_id, "qty": amount})
	inventory["items"] = items
	SaveManager.set_inventory_items(items)
	emit_signal("inventory_updated")

func remove_item(item_id: String, amount: int = 1) -> bool:
	var inventory = SaveManager.get_inventory()
	var items: Array = inventory.get("items", [])
	for stack in items:
		if stack.get("id", "") == item_id:
			var qty = int(stack.get("qty", 0))
			if qty < amount:
				return false
			qty -= amount
			stack["qty"] = qty
			if qty <= 0:
				items.erase(stack)
			SaveManager.set_inventory_items(items)
			emit_signal("inventory_updated")
			return true
	return false
