class_name PlacableFactory extends Node

var placesables = {
	"table": preload("res://scene/entities/objects/table/Table.tscn")
}

	
func data(name):
	var data = placesables[name]
	return data	
	
	
func create(data, position, rotation):
	var placable = placesables[data.static.placable_type].instance()
	placable.data = data
	placable.global_position = position
	placable.rotation_degrees = rotation
	return placable
