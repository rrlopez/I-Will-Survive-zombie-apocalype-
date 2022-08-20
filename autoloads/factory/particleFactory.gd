class_name ParticleFactory extends Node

var bloodScene = preload("res://scene/entities/objects/blood/blood.tscn")


func createBlood(position, color):
	var blood = bloodScene.instance()
	blood.global_position = position
	blood.self_modulate = color
	Globals.mapManager.add_child(blood)
