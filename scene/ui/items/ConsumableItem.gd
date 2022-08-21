class_name ConsumableItem extends Item

func _init(itemData): 
	init(itemData)
	Factory.statsModifiers.createAll(data.modifiers)

func use():
	set_quantity(data.quantity-1)
	for modifier in data.modifiers:
		Globals.player.data.stats[modifier.type].setVal(modifier)
	if(data.quantity<1): return null
	return self
