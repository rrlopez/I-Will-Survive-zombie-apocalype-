class_name ConsumableItem extends Item

func _init(itemData): 
	init(itemData)
	Factory.statsModifiers.createAll(data.modifiers)

func use():
	set_quantity(data.quantity-1)
	for modifier in data.modifiers:
		var prop = Globals.player
		for type in modifier.type.split(".", true): prop = prop[type]
		prop.setVal(modifier)
	if(data.quantity<1): return null
	return self
