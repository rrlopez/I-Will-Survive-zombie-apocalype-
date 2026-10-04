class_name EquipmentFactory extends Node

var equipments = {
	"pistol": preload("res://scene/entities/items/weapons/range/Pistol.tscn"),
	"riffle": preload("res://scene/entities/items/weapons/range/Riffle.tscn"),
	"machine gun": preload("res://scene/entities/items/weapons/range/MachineGun.tscn"),
	"melle": preload("res://scene/entities/items/weapons/melle/Melle.tscn"),
	"torch": preload("res://scene/entities/items/handItems/torch.tscn")
}

	
#func data(name):
#	var data = weapons[name]
#	return data	
	
	
func create(parent, item):
	var equipment = equipments[item.staticData.script].instance()
	equipment.init(parent, item)
	return equipment

func deserialize(parent, data):
	var equipment = equipments[data.static.script].instance()
	equipment.deserialize(parent, data)
	return equipment
