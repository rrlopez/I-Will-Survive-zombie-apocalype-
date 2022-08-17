class_name SizeStat extends Stat

func _init(_name, _val, _agent):
	init(_name, _val, _agent)
	update()

func setVal(modifier):
	.setVal(modifier)
	update()
	
func update():
	agent.scale = Vector2(val/100.0, val/100.0)
