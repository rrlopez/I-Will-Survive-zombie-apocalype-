class_name StatusEffectFactory extends Node

var statusEffects = {
	'applyForce': ApplyForce,
	'buff': Buff,
	"regen": Regen
}

	
func create(data, oponent, parent):
	for i in data.effects.size():
		var effect = data.effects[i]
		data.effects[i] = statusEffects[effect.script].new(effect.stats, oponent, parent)
		
	oponent.statusEffects.append(StatusEffect.new(data))
	
