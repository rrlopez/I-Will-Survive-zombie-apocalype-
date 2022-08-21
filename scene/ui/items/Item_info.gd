class_name ItemInfoWindow extends NinePatchRect


export(NodePath) onready var item_name  = get_node(item_name) as Label

func display(slot:Slot):
	item_name.text = slot.item.data.static.name
	show()
	
