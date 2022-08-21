extends Camera2D

var shake = null
var lastZoom = Vector2.ZERO
	
func _process(delta):
	if shake:
		if shake.timer>0:
			Constants.rand.randomize()
			offset.x = Constants.rand.randf_range(-1, 1)*shake.intensity
			Constants.rand.randomize()
			offset.y = Constants.rand.randf_range(-1, 1)*shake.intensity
			shake.timer-=delta
			zoom = lastZoom+Vector2(0.02, 0.02)
		else:
			offset = Vector2.ZERO
			zoom = lastZoom
			shake = null


func attachTo(newParent, _zoom, offset):
	var cameraParent = get_parent()
	if(cameraParent): cameraParent.remove_child(self)

	rotating = true
	zoom = Vector2(_zoom, _zoom)
	lastZoom = Vector2(_zoom, _zoom)
	rotation_degrees = 0
	position = Vector2(0, _zoom*-offset)

	newParent.add_child(self)
