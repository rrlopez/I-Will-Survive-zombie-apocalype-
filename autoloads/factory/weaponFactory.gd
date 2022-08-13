class_name WeaponFactory extends Node

var weapons = {
	"pistol": preload("res://scene/entities/items/weapons/range/Pistol.tscn"),
	"riffle": preload("res://scene/entities/items/weapons/range/Riffle.tscn")
}

	
func data(name):
	var data = weapons[name]
	return data	
	
	
func create(name, data):
	var weapon = weapons[name].instance()
	weapon.data = data
	return weapon
