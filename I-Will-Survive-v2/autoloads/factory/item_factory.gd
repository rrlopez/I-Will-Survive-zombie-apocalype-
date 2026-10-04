class_name ItemFactory extends RefCounted
## ItemFactory — instantiates item UI nodes from data.
## Phase 0 stub. Full implementation in Phase 8.

## Create an item node by name (e.g. "bandage", "m13").
## `quantity` — initial stack size.
## `type` — optional override for item sub-type ("craftable", etc.).
func create(_name: String, _quantity: int = 1, _type: String = "") -> Node:
	push_warning("ItemFactory.create: not yet implemented (Phase 8) — name: %s" % _name)
	return null
