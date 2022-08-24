class_name FireAccuracyStat extends Stat

func init(_name, _val, _agent):
	_val.x = Constants.rand.randi_range(_val.x.min, _val.x.max)
	_val.y = Constants.rand.randi_range(_val.y.min, _val.y.max)
	initValues(_name, _val, _agent)


func setVal(modifier):
	val.x = modifier.execute(val.x, modifier.val.x)
	val.y = modifier.execute(val.y, modifier.val.y)


func recompute():
	val = defaultVal
	for modifier in modifiers:
		maxVal.x = modifier.execute(maxVal.x, modifier.val.x)
		maxVal.y = modifier.execute(maxVal.y, modifier.val.y)
		setVal(modifier)
		


func serialize(script = "fireAccuracy"):
	return .serialize(script)
