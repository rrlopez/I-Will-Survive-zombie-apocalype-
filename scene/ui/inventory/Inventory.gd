class_name Inventory extends NinePatchRect

export(String) var inventory_name
export(String) var slot_scene_type = "slot" setget set_inventory_slot_scene_type
export(float) var columns = 6 setget set_inventory_column
export(int) var size = 0 setget set_inventory_size
export(String) var slot_type = "" setget set_slot_type

export(NodePath) onready var title  = get_node(title) as Label
export(NodePath) onready var slot_container  = get_node(slot_container) as GridContainer


var slots:Array = []

func _ready():
	for slot in slots:
		slot_container.add_child(slot)
		
	set_title()
	set_column()
	Globals.inventoryManager.emit_signal("inventory_ready", self)
	
func set_title():
	title.text = inventory_name
	
func set_column():
	slot_container.columns = columns

func set_inventory_size(value):
	size = value
	set_inventory_column(columns)
	set_inventory_slot_scene_type(slot_scene_type)
	
func set_inventory_slot_scene_type(value):
	slot_scene_type = value
	for s in slots: s.queue_free()
	slots = []
	for s in size:
		var new_slot = Constants.slotScene[value].instance()
		new_slot.type = slot_type
		slots.append(new_slot)

func set_inventory_column(value):
	columns = value
	rect_min_size.y = 85 + (ceil(size/columns)-1)*55

func set_slot_type(value):
	slot_type = value
	for s in slots: s.type = value
	
func add_item(item):
	for s in slots:
		if not s.item:
			s.set_item(item)
			return
			
			
func put_item(item):
	for s in slots:
		if s.item and s.item.data.static.id == item.data.static.id:
			if !s.is_full(): 
				item.data.quantity = s.item.add_item_quantity(item.data.quantity)
				if item.data.quantity<1: return 0
	
	if(item.data.quantity):
		for s in slots:
			if !s.item:
				var quantity = item.data.quantity
				item.data = item.data.duplicate(true)
				item.data.quantity = 0
				s.put_item(item)
				var remainder = s.item.add_item_quantity(quantity)
				
				return remainder 
	return item.data.quantity

func has_item(itemID):
	for s in slots:
		if s.item and s.item.data.static.id == itemID: return true
	return false


func _on_Inventory_mouse_entered():
	Globals.inventoryManager.cur_inventory = self


func _on_Inventory_mouse_exited():
	Globals.inventoryManager.cur_inventory = null
