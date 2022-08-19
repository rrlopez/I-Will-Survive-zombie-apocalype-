class_name Entity extends KinematicBody2D

var data = {}
var statusEffects = []

var applyedForce: Vector2 = Vector2.ZERO

func ready():
	for stat in data.stats:
		Constants.rand.randomize()
		data.stats[stat] = Factory.stats.create(stat, data.stats[stat], self)
	
func _process(delta):
	for statusEffect in statusEffects: statusEffect.run(self, delta)
	

func _hurt(dmg):
	return data.stats.health.setVal(Factory.statsModifiers.create("subtruct", dmg))
