extends Node2D

var filePath = "user://savegame.json"
var data = []

func saveGame():
	Globals.HUD.notifs.addNotif('saved...')
	data=[]
	
	for node in get_tree().get_nodes_in_group('serializable'): node.serialize(data)
	
	var save_game = File.new()
	save_game.open(filePath, File.WRITE)

	save_game.store_line(to_json(data))
	save_game.close()

func hasLoadData():
	var save_game = File.new()
	return save_game.file_exists(filePath)

func loadGame():
	Globals.HUD.notifs.addNotif('loaded...')
	var save_game = File.new()
	if not save_game.file_exists(filePath):
		return # Error! We don't have a save to load.

	save_game.open(filePath, File.READ)
	var game_data = parse_json(save_game.get_as_text())
	for data in game_data:
		var new_object = load(data["filename"]).instance()
		get_node(data["parent"]).add_child(new_object)
		new_object.deserialize(data)
	save_game.close()
