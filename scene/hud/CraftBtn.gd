extends TouchScreenButton


func _on_CraftBtn_pressed():
	if(Globals.HUD.craftPanel.visible): 
		Globals.HUD.craftPanel.close()
	else: 
		Globals.player.placable.hide()
		Globals.HUD.inventoryPanel.hide()
		Globals.HUD.craftPanel.clear_inventory()
		Globals.HUD.craftPanel.label.text = "Blueprints"
		Globals.HUD.craftPanel.add_inventory(Globals.player.craftInventory)
		Globals.HUD.craftPanel.show()
