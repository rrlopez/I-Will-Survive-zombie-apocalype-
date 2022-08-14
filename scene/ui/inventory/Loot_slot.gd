class_name Loot_slot extends Slot


export(NodePath) onready var soundPick  = get_node(soundPick) as AudioStreamPlayer

func use_item():
	soundPick.play()
	var inventory = Globals.player.inventory
	if item.data.static.type == "placable": inventory = Globals.player.craftInventory
	var remainder = inventory.put_item(item)
	if remainder < 1: pick_item()
	else: item.set_quantity(remainder)
