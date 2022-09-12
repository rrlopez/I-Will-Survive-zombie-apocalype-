class_name Player extends Entity

export(NodePath) onready var weapon_container  = get_node(weapon_container) as Node2D
export(NodePath) onready var hand_container  = get_node(hand_container) as Node2D
export(NodePath) onready var placable  = get_node(placable) as Node2D
export(NodePath) onready var body  = get_node(body) as Node2D
export(NodePath) onready var notif  = get_node(notif) as Sprite
export(NodePath) onready var collider = get_node(collider) as CollisionShape2D


var velocity = [{'key': 'default', 'value': Vector2()}]
var inventory:Inventory
var craftableInventory:Inventory
var placableInventory:Inventory

var controller

func _ready():
	._ready()
	controller = Constants.player_controllerScene.instance()
	controller.connect("use_joystick_vector", self, "_on_Controller_use_joystick_vector")
	controller.connect("on_joystick_release", self, "_on_Controller_on_joystick_release")
	controller.connect("use_rotateArea_degrees", self, "_on_Controller_use_rotateArea_degrees")
	Globals.currentController = controller
	
	_on_player_tree_entered()
	collider.shape.radius = Constants.BLOCK_SIZE*2
	
	Globals.player = self

func init():
	data = Utils.import_data("res://data/player.json")
	.init()
	recomputeStats()
	inventory = Utils.createInventory(data.inventory)
	placableInventory = Utils.createInventory(data.placable_inventory, "craft_inventory")
	craftableInventory = Utils.createInventory(data.craftable_inventory, "craft_inventory")
	Globals.HUD.inventoryPanel.add_inventory(inventory)
	

func _process(delta):
	._process(delta)
	data.stats.hunger.run(delta)

func _physics_process(delta):
	var motion = velocity.back().value.rotated(deg2rad(rotation_degrees))*data.stats.move_speed.val
	motion = move_and_slide((motion+applyedForce)*delta, Vector2.UP)


func setupInventory():
	inventory.size = 40
	inventory.inventory_name = "Inventory"

	inventory.add_item(load("res://scene/ui/items/data/Cristal.tscn").instance())
	Globals.HUD.inventoryPanel.add_inventory(inventory)

func addCamera():
	Globals.camera.attachTo(self, 1.7, 220)
	
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

func setHandItem(item):
	for child in hand_container.get_children(): hand_container.remove_child(child)
	if(item):
		hand_container.add_child(item.data.object)
		
	
func setWeapon(item):
	for child in weapon_container.get_children(): weapon_container.remove_child(child)
	if(item):
		Globals.HUD.infoPanel.addItem(item.data.object)
		weapon_container.add_child(item.data.object)
		body.upperBodyAnimation.play(item.staticData.animation_type)
	else:
		body.upperBodyAnimation.play("run")

func _on_Pickup_body_entered(dropItem):
	dropItem.pick_item()
	
	

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
		"placableInventory": craftableInventory.serialize(),
		"craftableInventory": craftableInventory.serialize(),
		"statusEffects": statusEffects.serialize(),
		"data": data.duplicate(true)
	}
	for stat in serializedData.data.stats: 
		serializedData.data.stats[stat] = data.stats[stat].serialize()
	
	if(weapon_container.get_child_count()>0): serializedData.weapon = weapon_container.get_child(0).serialize()
	if(hand_container.get_child_count()>0): serializedData.handItem = hand_container.get_child(0).serialize()
	
	savedData["player"] = serializedData



func deserialize(savedData):
	data = Utils.import_data("res://data/player.json")
	global_position = Vector2(savedData.global_position.x, savedData.global_position.y)
	global_rotation_degrees = savedData.global_rotation_degrees
	controller.rotated = global_rotation_degrees
	.init()
	
	for stat in savedData.data.stats: data.stats[stat].deserialize(savedData.data.stats[stat])
	
	placableInventory = Utils.createInventory(data.placable_inventory, "craft_inventory")
	craftableInventory = Utils.createInventory(data.craftable_inventory, "craft_inventory")
	inventory = Utils.deserializeInventory(savedData.inventory)
	Globals.HUD.inventoryPanel.add_inventory(inventory)
	
	for i in savedData.statusEffects.size(): 
		addStatusEffect(Factory.statusEffects.deserialize(savedData.statusEffects[i], self))
	
	if savedData.has("weapon"): 
		Globals.HUD.inventoryPanel.current_inventories[0].weapon.put_item(Factory.items.deserialize(savedData.weapon))
	if savedData.has("handItem"): 
		Globals.HUD.inventoryPanel.current_inventories[0].hand.put_item(Factory.items.deserialize(savedData.handItem))
