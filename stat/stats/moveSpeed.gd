class_name MoveSpeedStat extends Stat

func _init(_name, _val, _agent):
	init(_name, _val, _agent)
	update()

func setVal(modifier):
	.setVal(modifier)
	update()

func update():
	agent.body.lowerBodyAnimation.playback_speed=val/60
