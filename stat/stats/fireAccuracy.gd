class_name FireAccuracyStat extends Stat

func init(data, _agent):
	initValues(data, _agent)


func setVal(modifier):
	val.x = modifier.execute(val.x, modifier.val.x)
	val.y = modifier.execute(val.y, modifier.val.y)


func recompute():
	var amount = agent.data.stats.level.val*multiplier
	val.x = defaultVal.x+amount
	val.y = defaultVal.y+amount
	maxVal.x = defaultVal.x+amount
	maxVal.y = defaultVal.y+amount
	for modifier in modifiers:
		maxVal.x = modifier.execute(maxVal.x, modifier.val.x)
		maxVal.y = modifier.execute(maxVal.y, modifier.val.y)
		setVal(modifier)
		


func serialize():
	return {
		"difference": {
			"x": maxVal.x - val.x,
			"y": maxVal.y - val.y
		}
	}

func deserialize(savedData):
	val.x = maxVal.x-savedData.difference.x
	val.y = maxVal.y-savedData.difference.y
