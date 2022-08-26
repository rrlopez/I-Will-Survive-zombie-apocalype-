class_name Weapon extends Node2D

var isPressed
var lastFired = 0 
var parent

var data

func init(_parent, _data):
	data = _data
	parent = _parent
	data.object = self
	for stat in data.stats:
		Constants.rand.randomize()
		data.stats[stat] = Factory.stats.create(stat, data.stats[stat], self)

func hit(body):
	for statusEffect in data.statusEffects:
		Factory.statusEffects.create(statusEffect.duplicate(true), body, parent)
	body.hurt(parent, data.stats.fire_dmg.val)

func setLastFired(value):
	lastFired = value


func serialize():
	var serializedData = data.duplicate(true)
	serializedData.erase('object')
	serializedData.serialized = true
	
	for stat in data.stats: 
		serializedData.stats[stat] = data.stats[stat].serialize()
	for sideEffect in serializedData.sideEffects: 
		for i in sideEffect.effects.size(): 
			sideEffect.effects[i] = sideEffect.effects[i].serialize()
		
	return serializedData


func deserialize(_parent, _data):
	data = _data
	parent = _parent
	data.object = self
	
	for stat in data.stats: data.stats[stat] = Factory.stats.deserialize(data.stats[stat], self)
