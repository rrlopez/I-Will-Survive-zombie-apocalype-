extends Node

var WIDTH = ProjectSettings.get_setting("display/window/size/width")
var HEIGHT = ProjectSettings.get_setting("display/window/size/height")

const MOVE_SPEED_MULTIPLYER = 100
const EXP_MULTIPLYER = 100
const ANGLE_BETWEEN_RAYS = deg2rad(5)
const STAT_RANDOM = 0.7
var BLOCK_SIZE = 3200


var rand = RandomNumberGenerator.new()

var fonts = {
	8:preload("res://font/font_8.tres"),
	16:preload("res://font/font_16.tres")
}


var slotScene = {
	"slot": preload("res://scene/ui/inventory/Slot.tscn"),
	"equipment_slot": preload("res://scene/ui/inventory/Equipment_slot.tscn"),
	"loot_slot": preload("res://scene/ui/inventory/Loot_slot.tscn")
}

var vehicle_controllerScene = preload("res://scene/entities/vehicles/Controller.tscn")
var player_controllerScene = preload("res://scene/entities/player/controller/Controller.tscn")

var itemArea = preload("res://scene/ui/items/itemArea.tscn")

var notif = {
	"reloadAmmo": preload("res://assets/gui/reloadNotif.png"),
	"noAmmo": preload("res://assets/gui/noAmmoNotif.png")
}


var infoSectionScene = load("res://scene/ui/items/itemInfo/info_section.tscn")
var labelType = [
	load("res://scene/ui/items/itemInfo/labelType0.tscn"),
	load("res://scene/ui/items/itemInfo/labelType1.tscn"),
	load("res://scene/ui/items/itemInfo/labelType2.tscn"),
]
	
