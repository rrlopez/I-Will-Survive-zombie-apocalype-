extends ColorRect

var maxWidth = 0
var stat = null

export(NodePath) onready var label  = get_node(label) as Label

func _ready():
	maxWidth = $rect.rect_size.x
	yield(get_tree(),"idle_frame")
	stat = Globals.player.data.stats.level

func _process(_delta):
	$rect.rect_size = Vector2((stat.experience*maxWidth)/stat.maxExperience, $rect.rect_size.y)
	label.text = "lvl "+String(stat.val)
