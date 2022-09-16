extends Node2D

signal dataSaved

var defaultData = {
	"player": null,
	"others": [],
	"map": [],
	"updateOnly": [],
	"regions": {}
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
	if Globals.curRegion: data.regions[Globals.curRegion.name] = []
	
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
	createAndDeserializeScene(game_data.player)
	for otherData in game_data.others: createAndDeserializeScene(otherData)
	defaultData.regions = game_data.regions
	save_game.close()
	
	
func loadMap():
	var save_game = File.new()
	if not save_game.file_exists(filePath):
		return # Error! We don't have a save to load.
		
	save_game.open(filePath, File.READ)
	var game_data = parse_json(save_game.get_as_text())
	for otherData in game_data.map: createAndDeserializeScene(otherData)
	for updateOnlyData in game_data.updateOnly: deserializeScene(updateOnlyData)
	save_game.close()

func loadRegion(name):
	if defaultData.regions.has(name):
		for otherData in defaultData.regions[name]: createAndDeserializeScene(otherData)
	
func createAndDeserializeScene(savedData):
	var new_object = load(savedData["filename"]).instance()
	get_node(savedData["parent"]).add_child(new_object)
	new_object.deserialize(savedData)
	
func deserializeScene(savedData):
	return
	get_node(savedData["path"]).deserialize(savedData)
