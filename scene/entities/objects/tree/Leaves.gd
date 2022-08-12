extends Area2D

onready var tween = $Tween

func _on_Leaves_body_entered(_body):
	tween.interpolate_property($Texture, "modulate", Color(1,1,1,1), Color(1,1,1,0.3), 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.start()


func _on_Leaves_body_exited(_body):
	tween.interpolate_property($Texture, "modulate", Color(1,1,1,0.3), Color(1,1,1,1), 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.start()
