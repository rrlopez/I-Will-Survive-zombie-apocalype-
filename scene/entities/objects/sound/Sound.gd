extends Area2D

var origin = null

func _ready():
	$Animation.play("expand")
	global_position = origin.global_position


func _on_Animation_animation_finished(_anim_name):
	self.queue_free()


func _on_Sound_body_entered(body):
	body._on_View_body_entered(origin)
