extends VBoxContainer

export(NodePath) onready var title  = get_node(title) as Label
export(NodePath) onready var content  = get_node(content) as GridContainer

var info = null

func _ready():
	title.text = info.title
	for text in info.content:
		var item = content.get_child(0).duplicate()
		item.get_child(0).text = text.name
		item.get_child(1).text = text.value
		item.show()
		content.add_child(item)
