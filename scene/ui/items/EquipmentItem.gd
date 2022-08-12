class_name EquipmentItem extends Item

func _init(itemData): init(itemData)

func use():
	var slot = Globals.HUD.inventoryPanel.current_inventories[0][data.static.type]
	if(slot.item):
		var new_item = slot.item
		slot.pick_item()
		slot.put_item(self)
		return new_item
	else: 
		slot.put_item(self)
		return null
