class_name PlacableItem extends Item

func use():
	Globals.HUD.craftPanel.hide()
	Globals.player.placable.build(data)
	return self


