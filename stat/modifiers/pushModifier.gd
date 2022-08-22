class_name PushModifier extends Resource

var element
var type

func _init(_element, _type=null):
	element = _element
	type = _type

func execute(array, _element = element):
	Factory.statusEffects.create(_element.duplicate(true))
