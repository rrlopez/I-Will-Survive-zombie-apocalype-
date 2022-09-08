extends Placesable

export(NodePath) onready var sprite  = get_node(sprite) as TextureRect
export(NodePath) onready var collider  = get_node(collider) as CollisionShape2D
export(NodePath) onready var areaCollider  = get_node(areaCollider) as CollisionShape2D
export(NodePath) onready var buttons  = get_node(buttons) as Node2D

var inventory: Inventory

func init():
	yield(get_tree(), "idle_frame")
	.init()
	sprite.rect_position = Vector2(-staticData.size.x/2, -staticData.size.y/2)
	sprite.rect_min_size = Vector2(staticData.size.x, staticData.size.y)
	sprite.texture = Factory.items.itemObjectTexture[staticData.id]
	
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
	var serializedData = {
		"filename" : get_filename(),
		"parent" : get_parent().get_path(),
		"global_position":{
			"x": global_position.x,
			"y": global_position.y
		},
		"global_rotation_degrees": global_rotation_degrees,
		"inventory": inventory.serialize(),
		"data": data.duplicate(true),
	}
	for stat in serializedData.data.stats: 
		serializedData.data.stats[stat] = data.stats[stat].serialize()
		
		
	savedData.regions[Globals.curRegion.name].append(serializedData)



func deserialize(savedData):
	global_position = Vector2(savedData.global_position.x, savedData.global_position.y)
	global_rotation_degrees = savedData.global_rotation_degrees
	data = Factory.items.dynamicData[savedData.data.id].duplicate(true)
	staticData = Factory.items.staticData[savedData.data.id]
	.init()
	
	for stat in savedData.data.stats: data.stats[stat].deserialize(savedData.data.stats[stat])
	
	inventory = Utils.deserializeInventory(savedData.inventory)
	
