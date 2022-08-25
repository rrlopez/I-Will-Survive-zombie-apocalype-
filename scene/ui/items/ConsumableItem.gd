class_name ConsumableItem extends Item

func init(itemData): 
	.init(itemData)
	Factory.statsModifiers.createAll(data.modifiers)

func use():
	set_quantity(data.quantity-1)
	for modifier in data.modifiers:
		Utils.getProp(Globals.player, modifier.type).setVal(modifier)
	if(data.quantity<1): return null
	return self

func serialize():
	var serializedData = data.duplicate(true)
	for i in data.modifiers.size(): serializedData.modifiers[i] = data.modifiers[i].serialize()
	return serializedData

func deserialize(savedData):
	data = savedData
	for i in data.modifiers.size(): data.modifiers[i] = Factory.statsModifiers.deserialize(data.modifiers[i])
