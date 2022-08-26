extends Light2D

var data
var parent

func ready():
	data.object = self
		
	texture_scale = data.stats.size.val

func init(_parent, _data):
	parent = _parent
	data = _data
	
	for stat in data.stats: data.stats[stat] = Factory.stats.create(stat, data.stats[stat], self)
	ready()

func serialize():
	var serializedData = data.duplicate(true)
	serializedData.erase('object')
	serializedData.serialized = true
	
	for stat in data.stats: 
		serializedData.stats[stat] = data.stats[stat].serialize()

	return serializedData
	
func deserialize(_parent, _data):
	data = _data
	parent = _parent
	
	for stat in data.stats: data.stats[stat] = Factory.stats.deserialize(data.stats[stat], self)
	ready()
