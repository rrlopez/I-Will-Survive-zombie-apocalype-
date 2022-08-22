extends GridContainer

onready var statIconScene = preload("res://scene/hud/statusEffects/statIcon.tscn")


func addIcon(statusEffect):
	var icon = statIconScene.instance()
	icon.statusEffectName = statusEffect.data.name
	icon.icon = statusEffect.data.icon
	add_child(icon)
	
func removeIcon(statusEffect):
	for child in get_children():
		if child.statusEffectName == statusEffect.data.name:
			remove_child(child)
			return
