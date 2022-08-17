class_name VissionStat extends Stat

func _init(_name, _val, _agent):
	_val.width = Constants.rand.randi_range(_val.width*0.7, _val.width)
	_val.height = Constants.rand.randi_range(_val.height*0.7, _val.height)
	initValues(_name, _val, _agent)
	addVal(val)


func addVal(amount):
	val.width = amount.width
	val.height = amount.height
	
	for ray in agent.vision.get_children(): ray.queue_free()
	for ray in Globals.mapManager.spawnRays(val.width, val.height):
		ray.set_collision_mask_bit(5, true)
		ray.enabled = false
		agent.vision.add_child(ray)


func recompute():
	val = defaultVal
	for modifier in modifiers:
		maxVal.height+=modifier.val.height
		maxVal.width+=modifier.val.width
		addVal(modifier.val)
