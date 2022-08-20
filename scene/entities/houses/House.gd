extends Area2D

export(NodePath) onready var enemies  = get_node(enemies) as Node2D

onready var tween = $Roof/Tween

var data = {
	"disabled": false
}

func _ready():
	data = Factory.houses.create('normal')

func _on_House_body_entered(body):
	if(body.name=='Player'):
		tween.interpolate_property($Roof/Texture, "modulate", Color(1,1,1,1), Color(1,1,1,0), 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		tween.start()


func _on_House_body_exited(body):
	if(body.name=='Player'):
		tween.interpolate_property($Roof/Texture, "modulate", Color(1,1,1,0), Color(1,1,1,1), 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		tween.start()


func spawnEnemies():
	var size = $Collider.shape.extents
	for enemy in Factory.enemies.createMany(size, data.enemies):
		enemies.add_child(enemy)


func _on_visibility_screen_entered():
	if enemies.get_child_count()<1:
		spawnEnemies()
