class_name ConsumableItem extends Item

func init(itemData, staticData): 
	.init(itemData, staticData)
	Factory.statsModifiers.createAll(data.modifiers)
	Factory.statsModifiers.createAll(data.addedEffects)
	Factory.statsModifiers.createAll(data.removedEffects)

func use():
	set_quantity(data.quantity-1)
	for modifier in data.modifiers:
		Utils.getProp(Globals.player, modifier.type).setVal(modifier)
	for modifier in data.addedEffects:
		Utils.getProp(Globals.player, modifier.type).setVal(modifier)
	for modifier in data.removedEffects:
		Utils.getProp(Globals.player, modifier.type).setVal(modifier)
		
		
	if(data.quantity<1): return null
	return self

func getInfo():
	var info = .getInfo()
	info["btnText"] = "Use"
	if data.modifiers.size() > 0:
		if data.modifiers.size()>0:
			info.sections.append(getSectionInfo(data.modifiers, "EFFECTS", 4))
		if data.addedEffects.size()>0:
			info.sections.append(getSectionInfo(data.addedEffects, "ADDS", 1))
		if data.removedEffects.size()>0:
			info.sections.append(getSectionInfo(data.removedEffects, "REMOVES", 10))
	return info

func getSectionInfo(array, title, columns):
	var content = []
	for modifier in array: content.append(modifier.getInfo())
	
	return{
		"title": title,
		"columns": columns,
		"vseparation": 5,
		"content":content
	}


func serialize():
	return {
		"id":data.id,
		"quantity":data.quantity
	}
