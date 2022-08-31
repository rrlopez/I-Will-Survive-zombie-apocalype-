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
			effect.stats["duration"] = -1
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
	info.sections.append(getStatsInfo())
	if data.sideEffects.size() > 0:
		info.sections.append(getSideEffectsInfo())
	if data.statusEffects.size() > 0:
		info.sections.append(getStatusEffectsInfo())
	return info
	
	
func getStatsInfo():
	var statsContent = []
	for stat in data.stats: statsContent.append(data.stats[stat].getInfo())
	
	return{
		"title": "STATS",
		"columns": 3,
		"vseparation": 5,
		"content":statsContent
	}
	
	
func getStatusEffectsInfo():
	var effectsContent = []
	for statusEffect in data.statusEffects: 
		var effects = []
		for effect in statusEffect.effects.duplicate(true): 
			var e = Factory.statusEffects.statusEffects[effect.script].new()
			e.init(effect.stats)
			for info in e.getInfo():
				effects.append(info)
		
		effectsContent.append({
			"labelType": 1,
			"name": statusEffect.name,
			"value": String(statusEffect.chance)+"%",
			"effects": effects
		})
	
	
	return{
		"title": "SKILLS",
		"columns": 1,
		"vseparation": 20,
		"content":effectsContent
	}


func getSideEffectsInfo():
	var effects = []
	for statusEffect in data.sideEffects: 
		for effect in statusEffect.effects.duplicate(true): 
			for info in effect.getInfo():
				effects.append(info)
		
	return{
		"title": "EFFECTS",
		"columns": 4,
		"vseparation": 5,
		"content":effects
	}
	
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
