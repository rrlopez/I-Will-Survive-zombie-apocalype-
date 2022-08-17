extends Weapon

export(NodePath) onready var soundFire  = get_node(soundFire) as AudioStreamPlayer

var projectileScene = preload("res://scene/entities/objects/projectile/Projectile.tscn")

func _ready():
	$Texture.texture = data.static.object_texture
	$Projection.global_position = get_parent().global_position
	lastFired = data.status.fire_speed


func _process(delta):
	fire(delta)
	
	
func fire(delta):
	if(isPressed):
		if(lastFired >= data.status.fire_speed):
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
				
			Globals.mapManager.spawnSound(Globals.player, data.status.fire_sound)
			Globals.mapManager.add_child(projectile)
			
		else: lastFired += (100*delta)
	else: lastFired = data.status.fire_speed
	

func createProjection():
	Constants.rand.randomize()
	$Projection.cast_to.x = data.status.fire_range + Constants.rand.randf_range(-data.status.fire_accuracy.x, data.status.fire_accuracy.x)
	Constants.rand.randomize()
	$Projection.cast_to.y = Constants.rand.randf_range(-data.status.fire_accuracy.y, data.status.fire_accuracy.y)


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
