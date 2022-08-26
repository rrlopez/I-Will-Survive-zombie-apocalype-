extends ColorRect

export(NodePath) onready var sprite = get_node(sprite) as TextureRect
export(NodePath) onready var label = get_node(label) as Label
export(NodePath) onready var cooldown = get_node(cooldown) as ColorRect


func setCooldown(percent):
	percent = min(percent, 100)
	cooldown.rect_position = Vector2(60-(percent/2),92)
	cooldown.rect_scale = Vector2(percent,1)
