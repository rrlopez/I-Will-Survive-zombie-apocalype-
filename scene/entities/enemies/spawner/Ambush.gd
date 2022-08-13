extends Node2D

export(NodePath) onready var collider  = get_node(collider) as CollisionShape2D
export(NodePath) onready var enemies  = get_node(enemies) as Node2D
 

var data = {
	"size": 1000
}

var triggered = false
var life = 10


func _process(delta):
	if !triggered: return
	Globals.player.global_position.x = clamp(Globals.player.global_position.x, global_position.x-data.size/2-Constants.WIDTH/1.5, global_position.x+data.size/2+Constants.WIDTH/1.5)
	Globals.player.global_position.y = clamp(Globals.player.global_position.y, global_position.y-data.size/2-Constants.HEIGHT/1.5, global_position.y+data.size/2+Constants.HEIGHT/1.5)
	Globals.camera.global_position.x = clamp(Globals.player.global_position.x, global_position.x-data.size/2, global_position.x+data.size/2)
	Globals.camera.global_position.y = clamp(Globals.player.global_position.y, global_position.y-data.size/2, global_position.y+data.size/2)
	
	if enemies.get_children().size()<20:
		for _i in 100:
			Constants.rand.randomize()
			var position = global_position.normalized().rotated(Constants.rand.randi_range(-360, 360))* Constants.rand.randi_range(data.size, data.size*1.5)
			var enemy = Factory.enemies.create('normal', position.x, position.y, 0)
			enemy.data.behavior = "chase"
			enemies.add_child(enemy)
	
	life-=delta
	if(life<0 and enemies.get_children().size()<1):
		Globals.player.addCamera()
		queue_free()


func _on_Trigger_body_entered(body):
	Globals.camera.rotating = false
	Globals.camera.position = Vector2(0, 0)
	triggered = true
