class_name EquipmentItem extends Item

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

func serialize():
	if(data.has("object")):
		var serializedData = data.duplicate(true)
		serializedData.erase("object")
		serializedData["serialized"] = true
		for stat in data.stats: serializedData.stats[stat] = data.stats[stat].serialize()
		return serializedData
	else: return data

func deserialize(savedData):
	data = savedData
