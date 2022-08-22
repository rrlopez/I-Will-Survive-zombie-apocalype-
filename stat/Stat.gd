class_name Stat extends Resource

var modifiers = []
var name
var agent
var defaultVal
var maxVal
var val

func init(_name, _val, _agent):
	_val = Constants.rand.randi_range(_val.min, _val.max)
	initValues(_name, _val, _agent)

func initValues(_name, _val, _agent):
	name = _name
	maxVal = _val
	defaultVal = _val
	val = _val
	agent = _agent
	
func addModifier(modifier):
	modifiers.append(modifier)
	recompute()

func removeModifier(modifier):
	modifiers.erase(modifier)
	recompute()

func recompute():
	val = defaultVal
	maxVal = defaultVal
	for modifier in modifiers:
		maxVal = modifier.execute(maxVal)
		setVal(modifier)

func setVal(modifier):
	val = min(modifier.execute(val), maxVal)
	
func reset():
	modifiers = []
	recompute()
