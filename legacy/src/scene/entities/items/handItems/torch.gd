extends Light2D

var item
var data
var parent

func _ready():
	texture_scale = item.data.stats.size.val

func init(_parent, _item):
	parent = _parent
	item = _item
	data = _item.data
	
func recomputeStats():
	for stat in data.stats: data.stats[stat].recompute()

func serialize():
	return item.serialize()
	
func deserialize(_parent, _data):
	parent = _parent
	item.deserialize()
