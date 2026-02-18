extends RefCounted
class_name ItemDatabase

const ITEMS := {
	"ore_iron": {
		"id": "ore_iron",
		"name": "Iron Ore",
		"description": "Raw extraction material. Used in basic fabrication.",
		"value": 10
	},
	"fuel_cell": {
		"id": "fuel_cell",
		"name": "Fuel Cell",
		"description": "Ship consumable used for short-range travel.",
		"value": 45
	},
	"med_patch": {
		"id": "med_patch",
		"name": "Med Patch",
		"description": "Light medical aid for field missions.",
		"value": 25
	}
}

static func get_item(item_id: String) -> Dictionary:
	return ITEMS.get(item_id, {})
