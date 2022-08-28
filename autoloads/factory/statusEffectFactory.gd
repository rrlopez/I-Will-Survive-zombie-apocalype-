class_name StatusEffectFactory extends Node

var statusEffects = {
	'applyForce': ApplyForce,
	'buff': Buff,
	"regen": Regen
}

	
func create(data, oponent=Globals.player, parent=Globals.player):
	Constants.rand.randomize()
	if Constants.rand.randi()%100>data.chance: return
	for statusEffect in oponent.statusEffects.val:
		if statusEffect.data.id == data.id:
			statusEffect.reset()
			return
	
	for i in data.effects.size():
		var effect = data.effects[i]
		data.effects[i] = statusEffects[effect.script].new()
		data.effects[i].init(effect.stats)
		data.effects[i].add(oponent, parent)
	
	var statusEffect = StatusEffect.new()
	statusEffect.init(data)
	oponent.addStatusEffect(statusEffect)
	
	
func deserialize(data, agent):
	for i in data.effects.size():
		var effect = data.effects[i]
		data.effects[i] = statusEffects[effect.script].new()
		data.effects[i].deserialize(effect, agent)
	var statusEffect = StatusEffect.new()
	statusEffect.init(data)
	
	return statusEffect
