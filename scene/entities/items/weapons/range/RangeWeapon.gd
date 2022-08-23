extends Weapon

export(NodePath) onready var soundFire  = get_node(soundFire) as AudioStreamPlayer

var projectileScene = preload("res://scene/entities/objects/projectile/Projectile.tscn")
var isReloading = false
var ammoInventorySlot = null

func _ready():
	$Texture.texture = data.static.object_texture
	$Projection.global_position = get_parent().global_position
	lastFired = data.stats.fire_speed.val


func _process(delta):
	fire(delta)
	
	
func fire(delta):
	if(!reloading(delta) and isPressed):
		if(lastFired >= data.stats.fire_speed.val):
			soundFire.play()
			lastFired = 0
			
			createProjection()
			
			var projectile = createProjectile()
			
			if($Projection.is_colliding()):
				var collider = $Projection.get_collider()
				projectile.points[1] =  $Projection.get_collision_point() - $Nozzle.global_position

				if(collider.get_class() == 'KinematicBody2D'): .hit(collider)
			else:
				projectile.points[1] =  $Projection.cast_to - Vector2(60, 0)
				projectile.rotation_degrees = $Projection.global_rotation_degrees
				
			Globals.mapManager.spawnSound(Globals.player, data.stats.fire_sound.val)
			Globals.mapManager.add_child(projectile)
			
			data.stats.ammo.setVal(Factory.statsModifiers.create("subtruct", 1))
			if data.stats.ammo.val<1: _on_reloadBtn_pressed()
			
		else: lastFired += (100*delta)
	else: lastFired = data.stats.fire_speed.val


func reloading(delta):
	if ammoInventorySlot and isReloading:
		if data.stats.reload_duration.val<data.stats.reload_duration.maxVal:
			data.stats.reload_duration.setVal(Factory.statsModifiers.create("add", delta))
		else:
			var currentAmmo = data.stats.ammo.val
			data.stats.ammo.setVal(Factory.statsModifiers.create("add", min(data.stats.reload_rate.val, ammoInventorySlot.item.data.quantity)))
			ammoInventorySlot.add_item_quantity(currentAmmo-data.stats.ammo.maxVal)
			
			if !ammoInventorySlot.item:
				if data.stats.ammo.val>0: isReloading = false
				ammoInventorySlot = null
			else:
				if data.stats.ammo.val<data.stats.ammo.maxVal: 
					data.stats.reload_duration.setVal(Factory.statsModifiers.create("set", 0))
				else: isReloading = false
			
	
	return isReloading

func createProjection():
	Constants.rand.randomize()
	$Projection.cast_to.x = data.stats.fire_range.val + Constants.rand.randf_range(-data.stats.fire_accuracy.val.x, data.stats.fire_accuracy.val.x)
	Constants.rand.randomize()
	$Projection.cast_to.y = Constants.rand.randf_range(-data.stats.fire_accuracy.val.y, data.stats.fire_accuracy.val.y)


func createProjectile():
	var projectile = projectileScene.instance()
	projectile.position = $Nozzle.global_position
	return projectile


func _on_fireBtn_pressed():
	Globals.player.placable.hide()
	Globals.inventoryManager.hide()
	$Projection.enabled = true
	isPressed = true


func _on_fireBtn_released():
	$Projection.enabled = false
	isPressed = false


func _on_reloadBtn_pressed():
	data.stats.reload_duration.setVal(Factory.statsModifiers.create("set", 0))
	ammoInventorySlot = parent.inventory.get_item(data.static.ammo_type)
	isReloading = true
