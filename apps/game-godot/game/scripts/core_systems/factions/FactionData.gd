extends RefCounted
class_name FactionData

const FACTIONS := [
	{
		"id": "chii",
		"name": "CHII",
		"display_name": "CHII",
		"tagline": "Clean recruitment. Proven systems.",
		"description": "A clean, trustworthy campaign with a well-maintained, reliable image."
	},
	{
		"id": "ethereum_dynamics",
		"name": "Ethereum Dynamics",
		"display_name": "Ethereum Dynamics",
		"tagline": "We want you. Yes, you.",
		"description": "Aggressive recruitment that overshot its mark; seen as cannon‑fodder leadership."
	},
	{
		"id": "null_accord",
		"name": "The Null Accord",
		"display_name": "The Null Accord",
		"tagline": "Quiet strength. Absolute resolve.",
		"description": "Opposing faction branding: restrained, high‑contrast, and not flashy."
	}
]

static func get_by_id(faction_id: String) -> Dictionary:
	for faction in FACTIONS:
		if faction.get("id", "") == faction_id:
			return faction
	return FACTIONS[0]

static func get_display_name(faction_id: String) -> String:
	return get_by_id(faction_id).get("display_name", "Unknown")
