extends TouchScreenButton


func _on_BagBtn_pressed():
	if(Globals.HUD.inventoryPanel.visible): 
		Globals.HUD.inventoryPanel.close()
		Globals.HUD.itemInfo.hide()
	else: 
		Globals.player.placable.hide()
		Globals.HUD.craftPanel.hide()
		Globals.HUD.inventoryPanel.show()

