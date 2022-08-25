extends Node2D

#export(NodePath) onready var upperBodyAnimation  = get_node(upperBodyAnimation) as AnimationPlayer
#export(NodePath) onready var lowerBodyAnimation  = get_node(lowerBodyAnimation) as AnimationPlayer

onready var upperBodyAnimation = $Upper/Animation
onready var lowerBodyAnimation = $Lower/Animation
