extends Node

var soundEffects = {}
var soundEffect:AudioStreamPlayer

var curType

func _ready():
	soundEffect = AudioStreamPlayer.new()
	for file in Utils.get_files("res://assets/sfx"):
		soundEffects[file.get_basename()] = load("res://assets/sfx/"+file)

func play(type):
	if(curType!=type):
		curType = type
		soundEffect.stream = soundEffects[type]
	soundEffect.play()
