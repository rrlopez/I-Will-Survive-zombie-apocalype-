extends Node2D


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



func _on_BagBtn_pressed():
	if(Globals.HUD.inventoryPanel.visible): 
		Globals.HUD.inventoryPanel.close()
		Globals.HUD.itemInfo.hide()
		Globals.HUD.hotbar.rect_position = Vector2(610, 12)
	else: 
		Globals.HUD.hotbar.rect_position = Vector2(350, 29)
		Globals.player.placable.hide()
		Globals.HUD.craftPanel.hide()
		Globals.HUD.inventoryPanel.show()


func _on_mapBtn_pressed():
	Globals.stateManager.pushState("mapState")



func _on_pauseBtn_pressed():
	Globals.stateManager.pushState("pauseState")
