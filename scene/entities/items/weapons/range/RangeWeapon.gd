extends Weapon

export(NodePath) onready var soundFire  = get_node(soundFire) as AudioStreamPlayer
export(NodePath) onready var sprite  = get_node(sprite) as Sprite
export(NodePath) onready var projection  = get_node(projection) as RayCast2D

var projectileScene = preload("res://scene/entities/objects/projectile/Projectile.tscn")
var isReloading = false
var ammoInventorySlot = null

func _ready():
	sprite.texture = Factory.items.itemObjectTexture[item.data.id]
	projection.global_position = parent.global_position
	setLastFired(item.data.stats.fire_speed.val)


func _process(delta):
	fire(delta)
	
	
func fire(delta):
	if reloading(delta): return
	if isPressed:
		if(lastFired >= item.data.stats.fire_speed.val):
			soundFire.play()
			setLastFired(0)
			
			createProjection()
			
			var projectile = createProjectile()
			
			if($Projection.is_colliding()):
				var collider = $Projection.get_collider()
				projectile.points[1] =  $Projection.get_collision_point() - $Nozzle.global_position

				if(collider.get_class() == 'KinematicBody2D'): .hit(collider)
			else:
				projectile.points[1] =  $Projection.cast_to - Vector2(60, 0)
				projectile.rotation_degrees = $Projection.global_rotation_degrees
				
			Globals.mapManager.spawnSound(Globals.player, item.data.stats.fire_sound.val)
			Globals.mapManager.add_child(projectile)
			
			item.data.stats.ammo.setVal(Factory.statsModifiers.create("subtruct", 1))
			Globals.HUD.weaponPanel.label.text = String(item.data.stats.ammo.val)
			if item.data.stats.ammo.val<1: _on_reloadBtn_pressed()
			
		else: setLastFired(lastFired + (100*delta))
	elif lastFired < item.data.stats.fire_speed.val: setLastFired(item.data.stats.fire_speed.val)


func reloading(delta):
	if ammoInventorySlot and isReloading:
		if item.data.stats.reload_duration.val<item.data.stats.reload_duration.maxVal:
			item.data.stats.reload_duration.setVal(Factory.statsModifiers.create("add", delta))
			Globals.HUD.weaponPanel.setCooldown((item.data.stats.reload_duration.val/item.data.stats.reload_duration.maxVal)*100)
			return true
		else:
			var currentAmmo = item.data.stats.ammo.val
			item.data.stats.ammo.setVal(Factory.statsModifiers.create("add", min(item.data.stats.reload_rate.val, ammoInventorySlot.item.data.quantity)))
			ammoInventorySlot.add_item_quantity(currentAmmo-item.data.stats.ammo.maxVal)
			
			if !ammoInventorySlot.item: 
				ammoInventorySlot = null
				isReloading = false
			else:
				if item.data.stats.ammo.val<item.data.stats.ammo.maxVal: 
					item.data.stats.reload_duration.setVal(Factory.statsModifiers.create("set", 0))
				else: isReloading = false
	else:
		isReloading = false
		if item.data.stats.ammo.val<1: 
			parent.notif.texture = Constants.notif.noAmmo
			return true
		else: parent.notif.hide()
	
	return false

func createProjection():
	Constants.rand.randomize()
	$Projection.cast_to.x = item.data.stats.fire_range.val + Constants.rand.randf_range(-item.data.stats.fire_accuracy.val.x, item.data.stats.fire_accuracy.val.x)
	Constants.rand.randomize()
	$Projection.cast_to.y = Constants.rand.randf_range(-item.data.stats.fire_accuracy.val.y, item.data.stats.fire_accuracy.val.y)


func createProjectile():
	var projectile = projectileScene.instance()
	projectile.position = $Nozzle.global_position
	return projectile


func _on_fireBtn_pressed():
	Globals.player.placable.hide()
	Globals.inventoryManager.hide()
	$Projection.enabled = true
	isPressed = true
	if item.data.stats.ammo.val<1: _on_reloadBtn_pressed()


func _on_fireBtn_released():
	$Projection.enabled = false
	isPressed = false


func _on_reloadBtn_pressed():
	if isReloading: return
	item.data.stats.reload_duration.setVal(Factory.statsModifiers.create("set", 0))
	ammoInventorySlot = parent.inventory.get_item(item.staticData.ammo_type)
	if !ammoInventorySlot: ammoInventorySlot = Globals.HUD.hotbar.get_item(item.staticData.ammo_type)
	Globals.HUD.weaponPanel.setCooldown(0)
	parent.notif.show()
	parent.notif.texture = Constants.notif.reloadAmmo
	isReloading = true

func setLastFired(value):
	.setLastFired(value)
	Globals.HUD.weaponPanel.setCooldown(((value+1)/item.data.stats.fire_speed.val)*100)


func _on_RangeWeapon_tree_exiting():
	isReloading = false
	ammoInventorySlot = null
	parent.notif.hide()


func _on_Riffle_tree_entered():
	if item.data.stats.ammo.val<1: _on_reloadBtn_pressed()
	Globals.HUD.weaponPanel.label.text = String(item.data.stats.ammo.val)

