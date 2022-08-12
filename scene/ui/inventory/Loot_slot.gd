class_name Loot_slot extends Slot

func use_item():
	var inventory = Globals.player.inventory
	if item.data.static.type == "placable": inventory = Globals.player.craftInventory
	var remainder = inventory.put_item(item)
	if remainder < 1: pick_item()
	else: item.set_quantity(remainder)
