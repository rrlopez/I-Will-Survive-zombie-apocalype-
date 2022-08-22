extends TextureRect

var statusEffectName = null
var icon = ""

func _ready():
	texture = load("res://assets/statusEffectIcons/"+icon+".png")
