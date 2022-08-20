extends CPUParticles2D

func _ready():
	self.emitting = true
	self.one_shot = true

func _process(delta):
	if !emitting: queue_free()
