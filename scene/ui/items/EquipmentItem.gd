class_name EquipmentItem extends Item

func init(itemData, _staticData):
	.init(itemData, _staticData)
	
	data["object"] = Factory.equipments.create(Globals.player, self)
	for stat in data.stats:
		Constants.rand.randomize()
		data.stats[stat] = Factory.stats.create(stat, data.stats[stat], data.object)

	for sideEffect in data.sideEffects:
		for i in sideEffect.effects.size():
			var effect = sideEffect.effects[i]
			effect.stats["duration"] = 0
			sideEffect.effects[i] = Factory.statusEffects.statusEffects[effect.script].new()
			sideEffect.effects[i].init(effect.stats)
	
	data["object"].recomputeStats()

func use():
	var slot = Globals.HUD.inventoryPanel.current_inventories[0][staticData.equipment_type]
			
	if(slot.item):
		var new_item = slot.item
		slot.pick_item()
		slot.put_item(self)
		return new_item
	else: 
		slot.put_item(self)
		return null

func getInfo():
	var info = .getInfo()
	info["btnText"] = "Equip"
	
	var statsContent = []
	for stat in data.stats: statsContent.append(data.stats[stat].getInfo())
	
	info.sections.append({
		"title": "STATS",
		"content":statsContent
	})
	return info
	
func serialize():
	var serializedData = {
		"id":data.id,
		"quantity":data.quantity,
		"stats": {}
	}
	for stat in data.stats: serializedData.stats[stat] = data.stats[stat].serialize()
	return serializedData


func deserialize(savedData):
	.deserialize(savedData)
	for stat in data.stats:
		data.stats[stat].deserialize(savedData.stats[stat])
