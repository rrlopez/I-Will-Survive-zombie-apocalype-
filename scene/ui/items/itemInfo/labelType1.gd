extends VBoxContainer


onready var sprite  = $item2/PanelContainer/TextureRect
onready var _name  = $item2/VBoxContainer/HBoxContainer/value2
onready var value  = $item2/VBoxContainer/HBoxContainer/value3
onready var content  = $VBoxContainer

func init(text):
	_name.text = text.name
	value.text = text.value
	for effect in text.effects:
		var container  = content.get_child(0).duplicate()
		container.get_child(0).texture = effect.icon
		container.get_child(1).text = effect.value
		container.show()
		content.add_child(container)

