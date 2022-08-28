extends StaticBody2D

export(NodePath) onready var sprite  = get_node(sprite) as TextureRect
export(NodePath) onready var collider  = get_node(collider) as CollisionShape2D
export(NodePath) onready var areaCollider  = get_node(areaCollider) as CollisionShape2D
export(NodePath) onready var buttons  = get_node(buttons) as Node2D

var data = null
var inventory: Inventory

func _ready():
	yield(get_tree(), "idle_frame")
	sprite.rect_position = Vector2(-data.static.size.x/2, -data.static.size.y/2)
	sprite.rect_min_size = Vector2(data.static.size.x, data.static.size.y)
	sprite.texture = Factory.items.itemObjectTexture[data.static.id]
	
	collider.shape.extents = Vector2(data.static.size.x/2, data.static.size.y/2)
	areaCollider.shape.extents = collider.shape.extents + Vector2(10, 10)
	
	inventory = Utils.createInventory(data.static.inventory)
	inventory.slot_type = "crafting_slot"


func _on_OpenBtn_pressed():
	buttons.hide()
	Globals.inventoryManager.hide()
	Globals.HUD.craftPanel.label.text = data.static.name
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
	savedData.others.append({
		"filename" : get_filename(),
		"parent" : get_parent().get_path(),
		"global_position":{
			"x": global_position.x,
			"y": global_position.y
		},
		"global_rotation_degrees": global_rotation_degrees,
		"inventory": inventory.serialize(),
		"data": data
	})



func deserialize(savedData):
	global_position = Vector2(savedData.global_position.x, savedData.global_position.y)
	global_rotation_degrees = savedData.global_rotation_degrees
	data = savedData.data
	
	inventory = Utils.deserializeInventory(savedData.inventory)
	
