extends Line2D

func _ready():
	$Animation.play("fired")

func remove():
	self.queue_free()
