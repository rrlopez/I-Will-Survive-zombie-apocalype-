class_name PlacableFactory extends Node

var placesables = {
	"table": preload("res://scene/entities/placables/table/Table.tscn"),
	"campfire": preload("res://scene/entities/placables/campfire/Campfire.tscn")
}

	
func data(name):
	var data = placesables[name]
	return data	
	
	
func create(staticData, position, rotation):
	var placable = placesables[staticData.placable_type].instance()
	placable.staticData = staticData
	placable.data = Factory.items.dynamicData[staticData.id].duplicate(true)
	placable.global_position = position
	placable.rotation_degrees = rotation
	return placable
