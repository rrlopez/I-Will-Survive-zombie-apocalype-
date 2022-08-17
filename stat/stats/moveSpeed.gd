class_name MoveSpeedStat extends Stat

func _init(_name, _val, _agent):
	init(_name, _val, _agent)
	addVal(val)

func addVal(amout):
	.addVal(amout)
	agent.lowerBodyAnimation.playback_speed=val/60
