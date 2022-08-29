class_name Stat extends Resource

var modifiers = []
var multiplier = 0
var id
var name
var agent

var defaultVal
var maxVal
var val

func init(data, _agent):
	initValues(data, _agent)

func initValues(data, _agent):
	id = data.id
	name = data.name
	maxVal = data.val
	defaultVal = data.val
	val = data.val
	multiplier = data.multiplier
	agent = _agent
	
func addModifier(modifier):
	modifiers.append(modifier)
	recompute()

func removeModifier(modifier):
	modifiers.erase(modifier)
	recompute()

func recompute():
	var amount = agent.data.stats.level.val*multiplier
	val = defaultVal+amount
	maxVal = defaultVal+amount
	for modifier in modifiers:
		maxVal = modifier.execute(maxVal)
		setVal(modifier)

func setVal(modifier):
	val = min(modifier.execute(val), maxVal)
	
func reset():
	recompute()
	
func getInfo():
	return {"name": name, "value": String(val)}

func serialize():
	return {
		"difference": maxVal - val,
	}

func deserialize(savedData):
	val = maxVal-savedData.difference
