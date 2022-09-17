class_name MoveSpeedStat extends Stat

func init(data, _agent):
	initValues(data, _agent)
	update()


func recompute():
	.recompute()
	update()
	
func update():
	agent.body.lowerBodyAnimation.playback_speed=val/60

	
func deserialize(savedData):
	.deserialize(savedData)
	update()
