class_name Player extends Entity

export(NodePath) onready var weapon_container  = get_node(weapon_container) as Node2D
export(NodePath) onready var hand_container  = get_node(hand_container) as Node2D
export(NodePath) onready var placable  = get_node(placable) as Node2D
export(NodePath) onready var body  = get_node(body) as Node2D
export(NodePath) onready var notif  = get_node(notif) as Sprite


var velocity = [{'key': 'default', 'value': Vector2()}]
var inventory:Inventory
var craftInventory:Inventory
var weapon = null

var controller

func _ready():
	data = Utils.import_data("res://data/player.json")
	.ready()
	controller = Constants.player_controllerScene.instance()
	controller.connect("use_joystick_vector", self, "_on_Controller_use_joystick_vector")
	controller.connect("on_joystick_release", self, "_on_Controller_on_joystick_release")
	controller.connect("use_rotateArea_degrees", self, "_on_Controller_use_rotateArea_degrees")
	Globals.currentController = controller
	
	_on_player_tree_entered()
	
	inventory = Utils.createInventory(data.inventory)
	craftInventory = Utils.createInventory(data.craft_inventory, "craft_inventory")
	Globals.HUD.inventoryPanel.add_inventory(inventory)
	

func _process(delta):
	._process(delta)
	data.stats.hunger.run(delta)

func _physics_process(delta):
	var motion = velocity.back().value.rotated(deg2rad(rotation_degrees))*data.stats.move_speed.val
	move_and_slide((motion+applyedForce)*delta, Vector2.UP)


func setupInventory():
	inventory.size = 40
	inventory.inventory_name = "Inventory"

	inventory.add_item(load("res://scene/ui/items/data/Cristal.tscn").instance())
	Globals.HUD.inventoryPanel.add_inventory(inventory)

func addCamera():
	Globals.camera.attachTo(self, 1.5, 220)
	
func hurt(dmg):
	Factory.particles.createBlood(global_position, Color.red)
	Globals.camera.shake = {"timer": 0.2, "intensity": 3}
	global_rotation-=Constants.rand.randi_range(-1, 1)*0.15
	if ._hurt(dmg):
		dead()
		return true

func dead():
	yield(get_tree(),"idle_frame")
	yield(get_tree(),"idle_frame")
	Globals.stateManager.pushState("gameOverState")


func healthStatCallback(health):
	if(health.val<=0): dead()
	elif(health.val<health.maxVal/1.5 and health.val>0):
		var scale = max((2-1.2/(((health.maxVal)/health.val)))+1.2, 1.2)
		var alpha = 0.6-(0.6/((health.maxVal)/health.val))
		Globals.HUD.cameraEffect.visible = true
		Globals.HUD.cameraEffect.modulate.a = alpha
		Globals.HUD.cameraEffect.scale = Vector2(scale, scale)
	else: Globals.HUD.cameraEffect.visible = false


func addStatusEffect(statusEffect):
	.addStatusEffect(statusEffect)
	Globals.HUD.statusEffectIcons.addIcon(statusEffect)

func removeStatusEffect(statusEffect):
	.removeStatusEffect(statusEffect)
	Globals.HUD.statusEffectIcons.removeIcon(statusEffect)


func _on_Controller_on_joystick_release(key):
	velocity = Utils.filter(velocity, key)
	if(velocity.size()>1):
		if(abs(velocity.back().value.x) < abs(velocity.back().value.y)):$Body/Lower/Animation.play("run_stright")
		else:$Body/Lower/Animation.play("run_side")
	else: $Body/Lower/Animation.stop(false)


func _on_Controller_use_joystick_vector(vector):
	if(vector.value.length() > 0):
		velocity.push_back({'key': vector.key, 'value': vector.value*Constants.MOVE_SPEED_MULTIPLYER})
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
	$Body/Lower/footstep.play()
	
	
func setWeapon(item):
	for child in weapon_container.get_children(): weapon_container.remove_child(child)
	if(item):
		if item.data.has("object"): weapon_container.add_child(item.data.object)
		else: weapon_container.add_child(Factory.weapons.create(self, item.data))
		weapon = item
			
		$Body/Upper/Animation.play(weapon.data.static.animation_type)
	else:
		$Body/Upper/Animation.play("run")

func _on_Pickup_body_entered(_body):
	_body.pick_item()
