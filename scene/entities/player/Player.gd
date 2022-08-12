class_name Player extends KinematicBody2D

export(NodePath) onready var weapon_container  = get_node(weapon_container) as Node2D
export(NodePath) onready var hand_container  = get_node(hand_container) as Node2D
export(NodePath) onready var placable  = get_node(placable) as Node2D

var velocity = [{'key': 'default', 'value': Vector2()}]
var inventory:Inventory
var craftInventory:Inventory

var data = {
	"stats":{
		"size": 50,
		"move_speed": 120
	},
	"inventory": {
		"name": "Inventory",
		"size": 36,
		"items": [
			{ "name": "machette", "quantity": 1},
			{ "name": "AMT AutoMag III", "quantity": 1},
			{ "name": "m13", "quantity": 1},
			{ "name": "m14", "quantity": 1},
			{ "name": "crystal", "quantity": 65},
		]
	},
	"craft_inventory": {
		"name": "Craftables",
		"slot_type": "craft",
		"size": 36,
		"items": [
			{ "name": "crafting table", "quantity": 1},
		]
	}
}

var controller

func _ready():
	controller = Constants.player_controllerScene.instance()
	controller.connect("use_joystick_vector", self, "_on_Controller_use_joystick_vector")
	controller.connect("on_joystick_release", self, "_on_Controller_on_joystick_release")
	controller.connect("use_rotateArea_degrees", self, "_on_Controller_use_rotateArea_degrees")
	Globals.currentController = controller
	
	
	$Body/Lower/Animation.playback_speed=data.stats.move_speed/60
	data.stats.move_speed*=Constants.MOVE_SPEED_MULTIPLYER
	_on_player_tree_entered()
	
	inventory = Utils.createInventory(data.inventory)
	craftInventory = Utils.createInventory(data.craft_inventory, "craft_inventory")
	Globals.HUD.inventoryPanel.add_inventory(inventory)
	


func _physics_process(delta):
	var motion = velocity.back().value.rotated(deg2rad(rotation_degrees))* delta
	move_and_slide(motion, Vector2.UP)



func setupInventory():
	inventory.size = 40
	inventory.inventory_name = "Inventory"

	inventory.add_item(load("res://scene/ui/items/data/Cristal.tscn").instance())
	Globals.HUD.inventoryPanel.add_inventory(inventory)

func addCamera():
	var cameraParent = Globals.camera.get_parent()
	if(cameraParent): cameraParent.remove_child(Globals.camera)

	var zoom = 1.5
	Globals.camera.rotating = true
	Globals.camera.zoom = Vector2(zoom, zoom)
	Globals.camera.rotation_degrees = 0
	Globals.camera.position = Vector2(0, zoom*-220)

	add_child(Globals.camera)


func _on_Controller_on_joystick_release(key):
	velocity = Utils.filter(velocity, key)
	if(velocity.size()>1):
		if(abs(velocity.back().value.x) < abs(velocity.back().value.y)):$Body/Lower/Animation.play("run_stright")
		else:$Body/Lower/Animation.play("run_side")
	else: $Body/Lower/Animation.stop(false)


func _on_Controller_use_joystick_vector(vector):
	if(vector.value.length() > 0):
		velocity.push_back({'key': vector.key, 'value': vector.value*data.stats.move_speed})
		if(abs(velocity.back().value.x) < abs(velocity.back().value.y)):$Body/Lower/Animation.play("run_stright")
		else:$Body/Lower/Animation.play("run_side")
	else:
		_on_Controller_on_joystick_release(vector.key)


func _on_Controller_use_rotateArea_degrees(degrees):
	rotation_degrees = degrees


func _on_player_tree_entered():
	velocity = [{'key': 'default', 'value': Vector2()}]
	visible = true
	set_collision_layer_bit(0, true)
	set_collision_mask_bit(3, true)
	$Collider.disabled = false
	$Body/Lower/Animation.stop(false)



func _on_Player_tree_exited():
	visible = false
	set_collision_layer_bit(0, false)
	set_collision_mask_bit(3, false)
	velocity = [{'key': 'default', 'value': Vector2()}]
	$Collider.disabled = false
	$Body/Lower/Animation.stop(false)


func spawnSound():
	Globals.mapManager.spawnSound(self, 150)
	
	
func setWeapon(item):
	for child in weapon_container.get_children(): child.queue_free()
	if(item):
		var weapon = Constants.weapons[item.data.static.animation_type].instance()
		weapon.data = item.data
		weapon_container.add_child(weapon)
		$Body/Upper/Animation.play(item.data.static.animation_type)
	else:
		$Body/Upper/Animation.play("run")
	


func _on_Pickup_body_entered(body):
	body.pick_item()
