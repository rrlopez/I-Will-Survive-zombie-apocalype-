class_name StatusEffectFactory extends Node

var statusEffects = {
	'applyForce': ApplyForce
}

	
func create(data, oponent, parent):
	oponent.statusEffects.append(statusEffects[data.type].new(data.stats, oponent, parent))
	
