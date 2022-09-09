class_name CraftableItem extends Item

func _ready():
	label_quantity.visible = false
	set_name("craft")

func use():
	if canCraft(): 
		if .use(): return self
	return self

func cooldownFinished():
	for item in staticData.recipe:
		var slot = Globals.player.inventory.get_item(item.name)
		slot.add_item_quantity(-item.quantity)
	Globals.player.inventory.put_item(Factory.items.create(data.id, staticData.craft_amount))
	Globals.HUD.notifs.addNotif(staticData.name+" x"+String(staticData.craft_amount))
	pass

func canCraft():
	if Globals.player.inventory.is_full(): 
		Globals.HUD.notifs.addNotif("Inventory is full!")
		return false
	for item in staticData.recipe:
		if !Globals.player.inventory.get_item(item.name):
			Globals.HUD.notifs.addNotif("Required item is incomplete!")
			return false
	return true

func getInfo():
	var info = .getInfo()
	info["btnText"] = "Craft"
	
	info.sections.append(getRecipeInfo())
	
	var needInfo = getNeedInfo()
	if needInfo: info.sections.append(needInfo)
	
	return info
	
	
func getRecipeInfo():
	var recipeContent = []
	for item in staticData.recipe:
		recipeContent.append({
			"labelType": 0,
			"icon": Factory.items.itemTexture[item.name],
			"value": "x "+String(item.quantity),
		})
	
	return{
		"title": "RECIPE",
		"columns": 6,
		"vseparation": 5,
		"content":recipeContent
	}
	
func getNeedInfo():
	var needContent = []
	for item in staticData.recipe:
		var slot = Globals.player.inventory.get_item(item.name)
		var quantity = item.quantity
		if slot: quantity = max(0, quantity - slot.item.data.quantity)
		if quantity==0: continue
		
		needContent.append({
			"labelType": 0,
			"icon": Factory.items.itemTexture[item.name],
			"value": "x "+String(quantity),
		})
	
	if needContent.size()<1: return null
	return{
		"title": "NEED",
		"columns": 6,
		"vseparation": 5,
		"content":needContent
	}
