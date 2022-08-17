class_name Stat extends Resource

var modifiers = []
var name
var agent
var defaultVal
var maxVal
var val

func init(_name, _val, _agent):
	_val = Constants.rand.randi_range(_val*0.7, _val)
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
	for modifier in modifiers:
		maxVal+=modifier.val
		addVal(modifier.val)

func addVal(amout):
	val = min(val+amout, maxVal)
