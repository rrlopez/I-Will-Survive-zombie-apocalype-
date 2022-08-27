extends CanvasLayer

export(NodePath) onready var lootPanel = get_node(lootPanel) as Window
export(NodePath) onready var itemInfo = get_node(itemInfo) as ItemInfoWindow
export(NodePath) onready var inventoryPanel = get_node(inventoryPanel) as Window
export(NodePath) onready var craftPanel = get_node(craftPanel) as Window
export(NodePath) onready var controller = get_node(controller) as Node2D
export(NodePath) onready var cameraEffect = get_node(cameraEffect) as Sprite
export(NodePath) onready var statusEffectIcons = get_node(statusEffectIcons) as GridContainer
export(NodePath) onready var weaponPanel = get_node(weaponPanel) as ColorRect
export(NodePath) onready var notifs = get_node(notifs) as VBoxContainer

var hotbar setget setHotbar

func _init():
	Globals.HUD = self

func _ready():
	Globals.inventoryManager.panels.append(lootPanel)
	Globals.inventoryManager.panels.append(inventoryPanel)

func setHotbar(value):
	hotbar = value
	add_child(hotbar)
	move_child(hotbar, 7)
