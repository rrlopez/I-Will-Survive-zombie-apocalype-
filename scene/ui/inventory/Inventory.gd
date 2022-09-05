class_name Inventory extends Control

export(String) var inventory_name
export(String) var slot_scene_type = "slot" setget set_inventory_slot_scene_type
export(int) var columns = 6
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
	set_inventory_slot_scene_type(slot_scene_type)
	
func set_inventory_slot_scene_type(value):
	slot_scene_type = value
	for s in slots: s.queue_free()
	slots = []
	for s in size:
		var new_slot = Constants.slotScene[value].instance()
		new_slot.type = slot_type
		slots.append(new_slot)

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
		if s.item and s.item.data.id == item.data.id:
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

func get_item(itemID):
	for s in slots:
		if s.item and s.item.data.id == itemID: return s
	return null


func _on_Inventory_mouse_entered():
	Globals.inventoryManager.cur_inventory = self


func _on_Inventory_mouse_exited():
	Globals.inventoryManager.cur_inventory = null
	

func serialize():
	var serializedItems = []
	for s in slots: 
		if s.item: serializedItems.append(s.item.serialize())
		else: serializedItems.append(null)
	return {
		"name": inventory_name,
		"size": size,
		"slot_type": slot_type,
		"slot_scene_type": slot_scene_type,
		"items": serializedItems,
		"columns": columns
	}

func deserialize(savedData):
	size = savedData.size
	inventory_name = savedData.name
	slot_scene_type = savedData.slot_scene_type
	slot_type = savedData.slot_type
	columns = savedData.columns
	for item in savedData.items:
		var new_slot = Constants.slotScene[slot_scene_type].instance()
		new_slot.type = slot_type
		if item : new_slot.set_item(Factory.items.deserialize(item))
		slots.append(new_slot)
