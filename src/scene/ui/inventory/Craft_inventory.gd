class_name Craft_inventory extends Inventory

func add_item(item):
	.add_item(item)

func put_item(item):
	if get_item(item.staticData.id): return item.data.quantity
	.put_item(item)
