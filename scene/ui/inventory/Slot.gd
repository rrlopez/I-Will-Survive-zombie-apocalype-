class_name Slot extends NinePatchRect

signal item_changed

export(NodePath) onready var item_container  = get_node(item_container) as Control
export(NodePath) onready var area  = get_node(area) as Area2D

var item
export(String) var type 

func _ready():
	if item:
		item_container.add_child(item)


func set_item(new_item):
	item = new_item


func pick_item():
	item_container.remove_child(item)
	item = null


func put_item(new_item):
	item = new_item
	yield(get_tree(),"idle_frame")
	item_container.add_child(new_item)
	emitItemChanged()
	

func emitItemChanged():
	emit_signal("item_changed", item)

func use_item():
	if(item): 
		var new_item = item.use()
		pick_item()
		if(new_item): put_item(new_item)

func add_item_quantity(value):
	item.add_item_quantity(value)
	if item.data.quantity<1: pick_item()

func is_full():
	if item and item.data.quantity >= item.data.static.stock_size: return true
	return false


func _on_area_area_entered(area):
	Globals.inventoryManager.cur_slot = self

