class_name Entity extends KinematicBody2D

var data = {}
var statusEffects = null

var applyedForce: Vector2 = Vector2.ZERO

func _ready():
	pass

func init():
	statusEffects = StatusEffects.new(self)
	for stat in data.stats:
		data.stats[stat] = Factory.stats.create(stat, data.stats[stat], self)
	
func _process(delta):
	statusEffects.run(delta)
	

func _hurt(dmg):
	return data.stats.health.setVal(Factory.statsModifiers.create("subtruct", {"name": "Health", "amount": dmg}))


func revive():
	for stat in data.stats: data.stats[stat].reset()
	statusEffects.reset()


func addStatusEffect(statusEffect):
	statusEffects.addVal(statusEffect)

func removeStatusEffect(statusEffect):
	statusEffects.removeVal(statusEffect)


func recomputeStats():
	for stat in data.stats: data.stats[stat].recompute()
