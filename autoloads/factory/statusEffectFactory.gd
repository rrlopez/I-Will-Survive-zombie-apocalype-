class_name StatusEffectFactory extends Node

var statusEffects = {
	'applyForce': ApplyForce
}

	
func create(data):
	return statusEffects[data.type].new(data.stats)
	
