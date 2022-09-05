extends Node2D

signal dataSaved

var defaultData = {
	"player": null,
	"others": [],
	"map": []
}

var thread_timer = Timer.new()
var filePath = "user://savegame.json"
var data = defaultData
var thread

func _ready():
	thread_timer.connect("timeout", self,"savingDone")
	thread_timer.wait_time = 0.4
	thread_timer.one_shot = true
	add_child(thread_timer)

func saveGame():
	if thread: return
	thread = Thread.new()
	thread.start(self, "saving", data)


func saving(_threadData):
	Globals.HUD.notifs.addNotif('saved...')
	data = defaultData.duplicate(true)
	
	var serializables = get_tree().get_nodes_in_group('serializable')
	for node in serializables: node.serialize(data)
	
	var save_game = File.new()
	save_game.open(filePath, File.WRITE)

	save_game.store_line(to_json(data))
	save_game.close()
	thread_timer.start()


func savingDone():
	thread.wait_to_finish()
	thread = null
	emit_signal("dataSaved")
	

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
	deserializeScene(game_data.player)
	for otherData in game_data.others: deserializeScene(otherData)
	save_game.close()
	
	
func loadMap():
	var save_game = File.new()
	if not save_game.file_exists(filePath):
		return # Error! We don't have a save to load.

	save_game.open(filePath, File.READ)
	var game_data = parse_json(save_game.get_as_text())
	for otherData in game_data.map: deserializeScene(otherData)
	save_game.close()
	
	
func deserializeScene(savedData):
	var new_object = load(savedData["filename"]).instance()
	get_node(savedData["parent"]).add_child(new_object)
	new_object.deserialize(savedData)
