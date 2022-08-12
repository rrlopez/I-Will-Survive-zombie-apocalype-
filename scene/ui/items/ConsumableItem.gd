class_name ConsumableItem extends Item

func _init(itemData): init(itemData)

func use():
	set_quantity(data.quantity-1)
	if(data.quantity<1): return null
	return self
