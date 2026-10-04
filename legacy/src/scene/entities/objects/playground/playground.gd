extends Sprite

func _init():
	hide()


func _on_visibility_screen_entered():
	show()


func _on_visibility_screen_exited():
	hide()
