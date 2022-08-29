class_name ConsumableItem extends Item

func init(itemData, staticData): 
	.init(itemData, staticData)
	Factory.statsModifiers.createAll(data.modifiers)

func use():
	set_quantity(data.quantity-1)
	for modifier in data.modifiers:
		Utils.getProp(Globals.player, modifier.type).setVal(modifier)
	if(data.quantity<1): return null
	return self

func getInfo():
	var info = .getInfo()
	info["btnText"] = "Use"
	return info

func serialize():
	return {
		"id":data.id,
		"quantity":data.quantity
	}
