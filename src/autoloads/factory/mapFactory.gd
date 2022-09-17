class_name MapFactory extends Node

var houses = {}

func _init():
	for house in Utils.import_data("res://data/maps.json"):
		houses[house.id] = house

func create(name):
	return houses[name]
	
