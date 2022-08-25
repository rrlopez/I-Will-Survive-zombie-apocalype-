extends Node2D

signal serialize
var filePath = "user://savegame.json"
var data = []
var timer = 5

func _process(delta):
	if timer < 0:
		timer = 5
		data=[]
		emit_signal("serialize", data)
		saveGame()
	else: timer-=delta


func saveGame():
	print("save")
	var save_game = File.new()
	save_game.open(filePath, File.WRITE)

	save_game.store_line(to_json(data))
	save_game.close()


func loadGame():
	print("load")
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
