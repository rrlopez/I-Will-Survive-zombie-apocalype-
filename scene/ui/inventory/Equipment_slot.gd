class_name Equipment_slot extends Slot


export(NodePath) onready var placeholder  = get_node(placeholder) as TextureRect

func _ready():
	placeholder.texture = Constants.placeholders[type]


func set_item(new_item):
	.set_item(new_item)
	placeholder.hide()

func pick_item():
	.pick_item()
	placeholder.show()

func put_item(new_item):
	.put_item(new_item)
	placeholder.hide()

func use_item():
	if Globals.HUD.inventoryPanel.current_inventories[2].put_item(item) == 0:
		pick_item()
		emitItemChanged()
