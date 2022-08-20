extends Camera2D

var shake setget setShake
var lastZoom = 1
	
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

func setShake(value):
	shake = value
	lastZoom = zoom
