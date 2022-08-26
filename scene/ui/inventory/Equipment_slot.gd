class_name Equipment_slot extends Slot

export(NodePath) onready var placeholder  = get_node(placeholder) as TextureRect
export(NodePath) onready var soundEquip  = get_node(soundEquip) as AudioStreamPlayer
export(NodePath) onready var soundUnequip  = get_node(soundUnequip) as AudioStreamPlayer

func _ready():
	placeholder.texture = Factory.items.placeholders[type]

	if item:
		item_container.add_child(item)

func set_item(new_item):
	.set_item(new_item)
	placeholder.hide()

func pick_item():
	for sideEffect in item.data.sideEffects:
		for effect in sideEffect.effects:
			effect.remove(Globals.player)
	.pick_item()
	placeholder.show()

func put_item(new_item):
	.put_item(new_item)
	if(item.data.has("object")):
		for sideEffect in item.data.sideEffects:
			for effect in sideEffect.effects:
				for modifier in effect.data.modifiers:
					Utils.getProp(Globals.player, modifier.type).addModifier(modifier)
				effect.reset()
	elif(item.data.has("serialized")):
		for sideEffect in item.data.sideEffects:
			sideEffect = Factory.statusEffects.deserialize(sideEffect)
			for effect in sideEffect.data.effects:
				for modifier in effect.data.modifiers:
					Utils.getProp(Globals.player, modifier.type).addModifier(modifier)
				effect.reset()
	else:
		for sideEffect in item.data.sideEffects:
			for i in sideEffect.effects.size():
				var effect = sideEffect.effects[i]
				effect.stats["duration"] = 0
				sideEffect.effects[i] = Factory.statusEffects.statusEffects[effect.script].new()
				sideEffect.effects[i].init(effect.stats, Globals.player, Globals.player)
	soundEquip.play()
	placeholder.hide()

func use_item():
	if Globals.HUD.inventoryPanel.current_inventories[2].put_item(item) == 0:
		soundUnequip.play()
		pick_item()
		emitItemChanged()
