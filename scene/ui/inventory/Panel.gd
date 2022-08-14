class_name Window extends NinePatchRect

export(String) var title = ""
export(NodePath) onready var soundOpen  = get_node(soundOpen) as AudioStreamPlayer
export(NodePath) onready var container  = get_node(container) as Control
export(NodePath) onready var label  = get_node(label) as Label

var current_inventories:Array = []

func _ready():
	Globals.inventoryManager.connect("inventory_opened", self, "_on_inventory_opened")
	for inventory in container.get_children(): add_inventory(inventory)
	label.text = title



func _on_inventory_opened(inventory: Inventory):
	add_inventory(inventory)
	show()

	
func add_inventory(inventory):
	if(current_inventories.size()==0): rect_size.y = 20
	if(current_inventories.has(inventory)): return
	container.add_child(inventory)
	current_inventories.append(inventory)
	rect_size.y += inventory.rect_size.y + container.get_constant("separation")


func remove_inventory(inventory):
	if(current_inventories.has(inventory)):
		container.remove_child(inventory)
		current_inventories.erase(inventory)
		rect_size.y -= inventory.rect_size.y + container.get_constant("separation")

func clear_inventory():
	for inventory in current_inventories:
		container.remove_child(inventory)
		current_inventories.erase(inventory)
		rect_size.y -= inventory.rect_size.y + container.get_constant("separation")


func show():
	soundOpen.play()
	.show()
	


func close():
	hide()


func _on_CloseBtn_released():
	close()
