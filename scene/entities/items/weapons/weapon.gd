class_name Weapon extends Node2D

var isPressed
var lastFired = 0
var parent

var data

func _ready():
	for stat in data.stats:
		Constants.rand.randomize()
		data.stats[stat] = Factory.stats.create(stat, data.stats[stat], self)

func hit(body):
	for statusEffect in data.statusEffects:
		Factory.statusEffects.create(statusEffect.duplicate(true), body, parent)
	body.hurt(parent, data.stats.fire_dmg.val)
