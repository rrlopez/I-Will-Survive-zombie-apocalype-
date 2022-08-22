extends StaticBody2D

export(NodePath) onready var sprite  = get_node(sprite) as TextureRect
export(NodePath) onready var collider  = get_node(collider) as CollisionShape2D
export(NodePath) onready var light  = get_node(light) as Light2D

var data = null

func _ready():
	sprite.rect_position = Vector2(-data.static.size.x/2, -data.static.size.y/2)
	sprite.rect_min_size = Vector2(data.static.size.x, data.static.size.y)
	sprite.texture = data.static.object_texture
	collider.shape.radius = data.static.size.x/2
