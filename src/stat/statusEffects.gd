class_name StatusEffects extends Resource

var agent = null
var val = []

func _init(_agent):
	agent = _agent
		
func run(delta):
	for statusEffect in val: statusEffect.run(agent, delta)
	
func addVal(statusEffect):
	val.append(statusEffect)

func removeVal(statusEffect):
	val.erase(statusEffect)

func remove(statusEffect):
	statusEffect.remove()

func setVal(modifier):
	modifier.execute(self)
	
func reset():
	for statusEffect in val: remove(statusEffect)

func serialize():
	var serializedData = []
	for statusEffect in val: serializedData.append(statusEffect.serialize())
	return serializedData

func deserialize(savedData):
	val = savedData
	for i in val.size(): val[i] = Factory.statusEffects.deserialize(val[i], agent)
