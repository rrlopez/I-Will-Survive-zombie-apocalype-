class_name PlacableItem extends Item

func _init(itemData): init(itemData)

func use():
	Globals.HUD.craftPanel.hide()
	Globals.player.placable.build(data)
	return self
