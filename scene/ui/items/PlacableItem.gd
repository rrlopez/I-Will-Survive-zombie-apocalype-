class_name PlacableItem extends Item

func use():
	if canBuild():
		Globals.HUD.craftPanel.hide()
		Globals.player.placable.build(staticData)
	return self

func canBuild():
	for item in staticData.recipe:
		if !Globals.player.inventory.get_item(item.name):
			return false
	return true

func getInfo():
	var info = .getInfo()
	info["btnText"] = "Build"
	
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
