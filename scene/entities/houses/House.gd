extends Area2D

onready var tween = $Roof/Tween

var data = {}

func _ready():
	data = Factory.houses.create('normal')
	spawnEnemies()

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
		add_child(enemy)
	
