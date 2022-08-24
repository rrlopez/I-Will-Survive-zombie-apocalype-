class_name WeaponFactory extends Node

var weapons = {
	"pistol": preload("res://scene/entities/items/weapons/range/Pistol.tscn"),
	"riffle": preload("res://scene/entities/items/weapons/range/Riffle.tscn"),
	"melle": preload("res://scene/entities/items/weapons/melle/Melle.tscn")
}

	
func data(name):
	var data = weapons[name]
	return data	
	
	
func create(parent, data):
	var weapon = weapons[data.static.animation_type].instance()
	weapon.init(parent, data)
	return weapon

func deserialize(parent, data):
	var weapon = weapons[data.static.animation_type].instance()
	weapon.deserialize(parent, data)
	return weapon
