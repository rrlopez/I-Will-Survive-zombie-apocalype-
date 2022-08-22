class_name StatusEffectFactory extends Node

var statusEffects = {
	'applyForce': ApplyForce,
	'buff': Buff,
	"regen": Regen
}

	
func create(data, oponent, parent):
	Constants.rand.randomize()
	if Constants.rand.randi()%100>data.chance: return
	for statusEffect in oponent.statusEffects.val:
		if statusEffect.data.id == data.id:
			statusEffect.reset()
			return
	
	for i in data.effects.size():
		var effect = data.effects[i]
		data.effects[i] = statusEffects[effect.script].new(effect.stats, oponent, parent)
	
	oponent.addStatusEffect(StatusEffect.new(data))
	
