class_name SizeStat extends Stat

func init(_name, _val, _agent):
	.init(_name, _val, _agent)
	update()

func recompute():
	.recompute()
	update()
	
func update():
	agent.scale = Vector2(val/100.0, val/100.0)

	
func deserialize(savedData):
	.deserialize(savedData)
	update()
