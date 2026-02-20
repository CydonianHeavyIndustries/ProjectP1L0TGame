extends Node
class_name EconomySystem

signal inventory_updated
signal credits_updated

const ITEM_DATABASE = preload("res://scripts/core_systems/economy/ItemDatabase.gd")
const DEBUG_CONFIG = preload("res://scripts/core_systems/DebugConfig.gd")

func _save_manager() -> Node:
	return get_node_or_null("/root/SaveManager")

func add_credits(amount: int) -> void:
	if amount == 0:
		return
	var save_manager = _save_manager()
	if save_manager and save_manager.has_method("add_credits"):
		save_manager.add_credits(amount)
	emit_signal("credits_updated")

func spend_credits(amount: int) -> bool:
	var save_manager = _save_manager()
	var ok := false
	if save_manager and save_manager.has_method("spend_credits"):
		ok = save_manager.spend_credits(amount)
	if ok:
		emit_signal("credits_updated")
	return ok

func get_credits() -> int:
	var save_manager = _save_manager()
	if save_manager and save_manager.has_method("get_currency"):
		return save_manager.get_currency().get("credits", 0)
	return 0

func get_inventory_items() -> Array:
	var save_manager = _save_manager()
	if save_manager and save_manager.has_method("get_inventory"):
		return save_manager.get_inventory().get("items", [])
	return []

func add_item(item_id: String, amount: int = 1) -> void:
	if ITEM_DATABASE.get_item(item_id).is_empty():
		if DEBUG_CONFIG.LOGGING:
			print("[EconomySystem] Unknown item: ", item_id)
		return

	var save_manager = _save_manager()
	if save_manager == null or not save_manager.has_method("get_inventory"):
		return
	var inventory = save_manager.get_inventory()
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
	if save_manager.has_method("set_inventory_items"):
		save_manager.set_inventory_items(items)
	emit_signal("inventory_updated")

func remove_item(item_id: String, amount: int = 1) -> bool:
	var save_manager = _save_manager()
	if save_manager == null or not save_manager.has_method("get_inventory"):
		return false
	var inventory = save_manager.get_inventory()
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
			if save_manager.has_method("set_inventory_items"):
				save_manager.set_inventory_items(items)
			emit_signal("inventory_updated")
			return true
	return false
