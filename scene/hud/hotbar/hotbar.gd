class_name HotBar extends PanelContainer

export(NodePath) onready var slot_container  = get_node(slot_container) as GridContainer

export (int) var size
var slot_type = "hotbar"

var slots:Array = []

func init():
	for s in size:
		var new_slot = Constants.slotScene.slot.instance()
		slots.append(new_slot)
	Globals.HUD.hotbar = self

func _ready():
	for slot in slots: slot_container.add_child(slot)
	Globals.inventoryManager.emit_signal("inventory_ready", self)

func get_item(itemID):
	for s in slots:
		if s.item and s.item.data.static.id == itemID: return s
	return null


func serialize(savedData):
	var serializedItems = []
	for s in slots: 
		if s.item: serializedItems.append(s.item.serialize())
		else: serializedItems.append(null)
	savedData.append({
		"filename" : get_filename(),
		"parent" : get_parent().get_path(),
		"rect_global_position":{
			"x": 610,
			"y": 12
		},
		"size": size,
		"items": serializedItems,
	})

func deserialize(savedData):
	rect_global_position = Vector2(savedData.rect_global_position.x, savedData.rect_global_position.y)
	size = savedData.size
	
	for item in savedData.items:
		var new_slot = Constants.slotScene.slot.instance()
		if item : new_slot.set_item(Factory.items.deserialize(item))
		slots.append(new_slot)
		slot_container.add_child(new_slot)
		
	
	Globals.inventoryManager.emit_signal("inventory_ready", self)
	Globals.HUD.hotbar = self
