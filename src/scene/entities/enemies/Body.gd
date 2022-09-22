extends Node2D

signal attackLanded
signal attackFinished

onready var upperBodyAnimation = $Upper/Animation
onready var lowerBodyAnimation = $Lower/Animation


func onAttackLanded():
	emit_signal("attackLanded")


func onAttackFinished():
	emit_signal("attackFinished")
