extends PanelContainer

export(NodePath) onready var title  = get_node(title) as Label
export(NodePath) onready var content  = get_node(content) as GridContainer

var info = null

func _ready():
	title.text = info.title
	content.columns = info.columns
	content.add_constant_override("vseparation", info.vseparation)
	for text in info.content:
		var item = Constants.labelType[text.labelType].instance()
		content.add_child(item)
		item.init(text)
