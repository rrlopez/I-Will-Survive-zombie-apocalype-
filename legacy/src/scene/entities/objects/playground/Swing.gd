extends Sprite

func _ready():
	hide()
	
	
func _on_visibility_screen_entered():
	show()


func _on_visibility_screen_exited():
	hide()
