class_name Weapon_slot extends Equipment_slot

func use_item():
	Globals.HUD.infoPanel.delItem()
	.use_item()
