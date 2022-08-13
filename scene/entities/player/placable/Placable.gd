class_name Placable extends Node2D

export(NodePath) onready var controller  = get_node(controller) as CanvasLayer
export(NodePath) onready var collider  = get_node(collider) as CollisionShape2D
export(NodePath) onready var sprite  = get_node(sprite) as TextureRect

var itemData = null
var enable = true

func build(new_itemData):
	itemData = new_itemData
	Globals.inventoryManager.hide()
	
	position = Vector2(0, -(50+itemData.static.size.y/2))
	sprite.rect_position = Vector2(-itemData.static.size.x/2, -itemData.static.size.y/2)
	sprite.rect_min_size = Vector2(itemData.static.size.x, itemData.static.size.y)
	sprite.texture = itemData.static.object_texture
	collider.shape.extents = Vector2(-itemData.static.size.x/2, -itemData.static.size.y/2)
	_on_Placable_body_exited(null)
	show()



func _on_CancelBtn_pressed():
	Globals.HUD.craftPanel.show()
	hide()


func _on_PlaceBtn_pressed():
	if(!enable): return
	var item = Factory.placables.create(itemData, global_position, Globals.player.rotation_degrees)
	Globals.mapManager.add_child(item)
	_on_CancelBtn_pressed()



func show():
	for child in controller.get_children(): child.show()
	sprite.show()
	.show()
	
	
func hide():
	if(visible):
		itemData = null
		
		position = Vector2(0, 0)
		sprite.rect_position = Vector2(0, 0)
		sprite.rect_min_size = Vector2(0, 0)
		sprite.texture = null
		collider.shape.extents = Vector2(0, 0)
		
		for child in controller.get_children(): child.hide()
		sprite.hide()
	.hide()



func _on_Placable_body_entered(_body):
	enable = false
	sprite.self_modulate = Color("5aef6a6a")


func _on_Placable_body_exited(_body):
	enable = true
	sprite.self_modulate = Color("5a6f6aef")
