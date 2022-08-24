extends Node2D

var data = []
signal serialize
var timer = 0

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
	save_game.open("user://savegame.json", File.WRITE)

	save_game.store_line(to_json(data))
	save_game.close()


func loadGame():
	print("load")
	var save_game = File.new()
	if not save_game.file_exists("user://savegame.json"):
		return # Error! We don't have a save to load.

	save_game.open("user://savegame.json", File.READ)
	var game_data = parse_json(save_game.get_as_text())
	for data in game_data:
		var new_object = load(data["filename"]).instance()
		get_node(data["parent"]).add_child(new_object)
		new_object.deserialize(data)
	save_game.close()
