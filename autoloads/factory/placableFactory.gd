class_name PlacableFactory extends Node

var placesables = {
	"table": preload("res://scene/entities/objects/table/Table.tscn")
}

	
func data(name):
	var data = placesables[name]
	return data	
	
	
func create(name):
	var placable = placesables[name].instance()
			
	return placable
