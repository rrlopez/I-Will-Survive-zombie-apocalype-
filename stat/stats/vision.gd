class_name VissionStat extends Stat

func _init(_name, _val, _agent):
	_val.width = Constants.rand.randi_range(_val.width.min, _val.width.max)
	_val.height = Constants.rand.randi_range(_val.height.min, _val.height.max)
	initValues(_name, _val, _agent)
	update()


func setVal(modifier):
	val.width = modifier.execute(val.width, modifier.val.width)
	val.height = modifier.execute(val.height, modifier.val.height)


func recompute():
	val = defaultVal
	for modifier in modifiers:
		maxVal.width = modifier.execute(maxVal.width, modifier.val.width)
		maxVal.height = modifier.execute(maxVal.height, modifier.val.height)
		setVal(modifier)
	update()
		

func update():
	for ray in agent.vision.get_children(): ray.queue_free()
	for ray in Globals.mapManager.spawnRays(val.width, val.height):
		ray.set_collision_mask_bit(5, true)
		ray.enabled = true
		agent.vision.add_child(ray)
