class_name Notif extends Sprite

var defaultPosition = Vector2.ZERO
var parent = null

var timer = 1

func init(_position):
	defaultPosition = _position
	parent = get_parent()
	setPosition()

func _process(delta):
	setPosition()
	timer-=delta
	if timer<0: queue_free()

func setPosition():
	position = defaultPosition.rotated(deg2rad(-parent.global_rotation_degrees+Globals.camera.global_rotation_degrees))
	rotation_degrees = -parent.global_rotation_degrees+Globals.camera.global_rotation_degrees
