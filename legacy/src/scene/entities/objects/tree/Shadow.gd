extends Node2D

onready var tween = $Tween


func _on_Leaves_body_entered(_body):
	var opacity = self.modulate.a
	tween.interpolate_property(self, "modulate", Color(0, 0, 0, opacity), Color(0, 0, 0, 0), 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.start()


func _on_Leaves_body_exited(_body):
	var opacity = self.modulate.a
	tween.interpolate_property(self, "modulate", Color(0, 0, 0, 0), Color(0, 0, 0, opacity), 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.start()
