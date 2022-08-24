class_name Weapon_slot extends Equipment_slot

func put_item(new_item):
	.put_item(new_item)
	Globals.HUD.weaponPanel.show()
	Globals.HUD.weaponPanel.sprite.texture = Factory.items.itemTexture[new_item.data.static.id]

func use_item():
	.use_item()
	Globals.HUD.weaponPanel.hide()
