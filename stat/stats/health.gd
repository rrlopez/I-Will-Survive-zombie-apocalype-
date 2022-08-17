class_name HealthStat extends Stat

func _init(_name, _val, _agent):
	init(_name, _val, _agent)

func addVal(amout):
	.addVal(amout)
	if(val<1): 
		agent.queue_free()
		Globals.mapManager.spawnDropItems(agent.data.drops, agent.global_position)
		return true
	return false
