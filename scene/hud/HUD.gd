extends CanvasLayer

export(NodePath) onready var lootPanel = get_node(lootPanel) as Window
export(NodePath) onready var inventoryPanel = get_node(inventoryPanel) as Window
export(NodePath) onready var craftPanel = get_node(craftPanel) as Window
export(NodePath) onready var controller = get_node(controller) as Node2D
export(NodePath) onready var miniMap = get_node(miniMap) as Control


func _init():
	Globals.HUD = self

func _ready():
	Globals.inventoryManager.panels.append(lootPanel)
	Globals.inventoryManager.panels.append(inventoryPanel)


func _process(_delta):
	$fps.text = str(Engine.get_frames_per_second())

