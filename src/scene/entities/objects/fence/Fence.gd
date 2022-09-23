extends StaticBody2D

export(int) var health = 100
onready var sprite = $Sprite

var shake = {
	"timer": 0,
	"intensity": 3
}

func _init():
	hide()

func hurt(_dmg):
	health-=_dmg
	self.set_process(true)
	shake.timer = 0.2
	if health<0:
		self.call_deferred("queue_free")

	
func _process(delta):
	if shake.timer>0:
		Constants.rand.randomize()
		sprite.offset.x = Constants.rand.randf_range(-1, 1)*shake.intensity
		Constants.rand.randomize()
		sprite.offset.y = Constants.rand.randf_range(-1, 1)*shake.intensity
		shake.timer-=delta
	else:
		sprite.offset = Vector2.ZERO
		self.set_process(false)



func _on_visibility_screen_entered():
	show()


func _on_visibility_screen_exited():
	hide()
