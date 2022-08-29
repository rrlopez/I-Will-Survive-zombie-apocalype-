class_name Weapon extends Node2D

var isPressed
var lastFired = 0 
var parent

var item
var data

func init(_parent, _item):
	parent = _parent
	item = _item
	data = _item.data
	
func hit(body):
	for statusEffect in item.data.statusEffects:
		Factory.statusEffects.create(statusEffect.duplicate(true), body, parent)
	var experience = body.hurt(parent, item.data.stats.fire_dmg.val)
	if experience:
		parent.data.stats.level.setVal(Factory.statsModifiers.create("add", experience))

func setLastFired(value):
	lastFired = value

func recomputeStats():
	for stat in data.stats: data.stats[stat].recompute()

func serialize():
	return item.serialize()


func deserialize(_parent, _data):
	parent = _parent
	item.deserialize(_data)

