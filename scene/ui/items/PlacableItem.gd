class_name PlacableItem extends Item

func use():
	Globals.HUD.craftPanel.hide()
	Globals.player.placable.build(staticData)
	return self


func getInfo():
	var info = .getInfo()
	info["btnText"] = "Build"
	return info
