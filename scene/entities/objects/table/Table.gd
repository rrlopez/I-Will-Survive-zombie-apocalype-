extends StaticBody2D

export(NodePath) onready var sprite  = get_node(sprite) as TextureRect
export(NodePath) onready var collider  = get_node(collider) as CollisionShape2D
export(NodePath) onready var areaCollider  = get_node(areaCollider) as CollisionShape2D
export(NodePath) onready var openBtn  = get_node(openBtn) as TouchScreenButton

var data = null
var inventory: Inventory

func _ready():
	sprite.rect_position = Vector2(-data.static.size.x/2, -data.static.size.y/2)
	sprite.rect_min_size = Vector2(data.static.size.x, data.static.size.y)
	sprite.texture = data.static.object_texture
	
	collider.shape.extents = Vector2(data.static.size.x/2, data.static.size.y/2)
	areaCollider.shape.extents = collider.shape.extents + Vector2(10, 10)
	
	inventory = Utils.createInventory(data.static.inventory)
	inventory.slot_type = "crafting_slot"


func _on_OpenBtn_pressed():
	openBtn.hide()
	Globals.inventoryManager.hide()
	Globals.HUD.craftPanel.label.text = data.static.name
	Globals.HUD.craftPanel.clear_inventory()
	Globals.HUD.craftPanel.add_inventory(inventory)
	Globals.HUD.craftPanel.show()


func _on_Area_body_entered(_body):
	openBtn.show()


func _on_Area_body_exited(_body):
	Globals.HUD.craftPanel.hide()
	openBtn.hide()
