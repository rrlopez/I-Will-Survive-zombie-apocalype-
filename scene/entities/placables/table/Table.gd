extends Placesable

export(NodePath) onready var collider  = get_node(collider) as CollisionShape2D
export(NodePath) onready var areaCollider  = get_node(areaCollider) as CollisionShape2D
export(NodePath) onready var buttons  = get_node(buttons) as Node2D

var inventories = []

func init():
	.init()
	yield(get_tree(), "idle_frame")
	collider.shape.extents = Vector2(staticData.size.x/2, staticData.size.y/2)
	areaCollider.shape.extents = collider.shape.extents + Vector2(10, 10)
	
	if staticData.has("placable_inventory"):
		var placableInventory = Utils.createInventory(staticData.placable_inventory)
		placableInventory.slot_type = "crafting_slot"
		inventories.append(placableInventory)
	
	if staticData.has("craftable_inventory"):
		var craftableInventory = Utils.createInventory(staticData.craftable_inventory)
		craftableInventory.slot_type = "crafting_slot"
		inventories.append(craftableInventory)
	

func _on_OpenBtn_pressed():
	buttons.hide()
	Globals.inventoryManager.hide()
	Globals.HUD.craftPanel.clear_inventory()
	Globals.HUD.craftPanel.label.text = staticData.name
	Globals.HUD.hotBarContainer.rect_position = Vector2(350, 29)
	for inventory in inventories:
		Globals.HUD.craftPanel.add_inventory(inventory)
	Globals.HUD.craftPanel.show()


func _on_Area_body_entered(_body):
	buttons.show()


func _on_Area_body_exited(_body):
	Globals.HUD.hotBarContainer.rect_position = Vector2(610, 12)
	Globals.HUD.craftPanel.hide()
	Globals.HUD.itemInfo.hide()
	buttons.hide()


func _on_removeBtn_pressed():
	self.queue_free()


func serialize(savedData): 
	var serializedData = .serialize(savedData)
	savedData.regions[Globals.curRegion.name].append(serializedData)



func deserialize(savedData):
	.deserialize(savedData)
	
	if staticData.has("placable_inventory"):
		var placableInventory = Utils.createInventory(staticData.placable_inventory)
		placableInventory.slot_type = "crafting_slot"
		inventories.append(placableInventory)
	
	if staticData.has("craftable_inventory"):
		var craftableInventory = Utils.createInventory(staticData.craftable_inventory)
		craftableInventory.slot_type = "crafting_slot"
		inventories.append(craftableInventory)
	
