class_name MoveSpeedStat extends Stat

func init(_name, _val, _agent):
	.init(_name, _val, _agent)
	update()


func recompute():
	.recompute()
	update()
	
func update():
	agent.body.lowerBodyAnimation.playback_speed=val/60

	
func deserialize(savedData):
	.deserialize(savedData)
	update()
