class_name SizeStat extends Stat

func _init(_name, _val, _agent):
	init(_name, _val, _agent)
	update()

func setVal(modifier):
	.setVal(modifier)
	update()
	
func update():
	agent.scale = Vector2(val/100.0, val/100.0)
	agent.data.stats["move_speed"] = {"script": "moveSpeed", "val": agent.data.static.stats.move_speed-val}
	agent.data.stats["health"] = {"script": "health", "val": agent.data.static.stats.level*val}
