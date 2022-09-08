extends Placesable

export(NodePath) onready var collider  = get_node(collider) as CollisionShape2D
export(NodePath) onready var areaCollider  = get_node(areaCollider) as CollisionShape2D
export(NodePath) onready var buttons  = get_node(buttons) as Node2D

var inventory: Inventory

func init():
	.init()
	yield(get_tree(), "idle_frame")
	collider.shape.extents = Vector2(staticData.size.x/2, staticData.size.y/2)
	areaCollider.shape.extents = collider.shape.extents + Vector2(10, 10)
	
	inventory = Utils.createInventory(staticData.inventory)
	inventory.slot_type = "crafting_slot"


func _on_OpenBtn_pressed():
	buttons.hide()
	Globals.inventoryManager.hide()
	Globals.HUD.craftPanel.label.text = staticData.name
	Globals.HUD.craftPanel.clear_inventory()
	Globals.HUD.craftPanel.add_inventory(inventory)
	Globals.HUD.craftPanel.show()


func _on_Area_body_entered(_body):
	buttons.show()


func _on_Area_body_exited(_body):
	Globals.HUD.craftPanel.hide()
	buttons.hide()


func _on_removeBtn_pressed():
	self.queue_free()


func serialize(savedData): 
	var serializedData = .serialize(savedData)
	serializedData["inventory"] = inventory.serialize()
	savedData.regions[Globals.curRegion.name].append(serializedData)



func deserialize(savedData):
	.deserialize(savedData)
	
	inventory = Utils.deserializeInventory(savedData.inventory)
	
