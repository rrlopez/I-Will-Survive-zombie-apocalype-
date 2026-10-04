class_name Gage extends ColorRect

export(Color) var rectColor
export(Color) var iconColor
export(Texture) var iconTexture
export(String) var statName
var maxWidth = 0
var stat = null

func _ready():
	$rect.color = rectColor
	$icon.modulate = iconColor
	$icon.texture = iconTexture
	maxWidth = $rect.rect_size.x
	yield(get_tree(),"idle_frame")
	stat = Globals.player.data.stats[statName]

func _process(_delta):
	$rect.rect_size = Vector2((stat.val*maxWidth)/stat.maxVal, $rect.rect_size.y)
