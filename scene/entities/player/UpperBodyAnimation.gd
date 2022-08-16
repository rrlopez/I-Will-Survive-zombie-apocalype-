extends AnimationPlayer

signal attackLanded
signal attackFinished

func attackLanded():
	emit_signal("attackLanded")

func attackFinished():
	emit_signal("attackFinished")
	play(owner.weapon.data.static.animation_type)
