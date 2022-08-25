extends StaticBody2D

export(NodePath) onready var sprite  = get_node(sprite) as TextureRect
export(NodePath) onready var collider  = get_node(collider) as CollisionShape2D
export(NodePath) onready var areaCollider  = get_node(areaCollider) as CollisionShape2D
export(NodePath) onready var light  = get_node(light) as Light2D
export(NodePath) onready var buttons  = get_node(buttons) as Node2D

var data = null

func _ready():
	yield(get_tree(), "idle_frame")
	sprite.rect_position = Vector2(-data.static.size.x/2, -data.static.size.y/2)
	sprite.rect_min_size = Vector2(data.static.size.x, data.static.size.y)
	sprite.texture = Factory.items.itemObjectTexture[data.static.id]
	collider.shape.radius = data.static.size.x/2
	areaCollider.shape.radius = collider.shape.radius + 10


func _on_Area_body_entered(body):
	buttons.show()


func _on_Area_body_exited(body):
	buttons.hide()


func _on_removeBtn_pressed():
	queue_free()



func serialize(savedData): 
	savedData.append({
		"filename" : get_filename(),
		"parent" : get_parent().get_path(),
		"global_position":{
			"x": global_position.x,
			"y": global_position.y
		},
		"global_rotation_degrees": global_rotation_degrees,
		"data": data
	})



func deserialize(savedData):
	global_position = Vector2(savedData.global_position.x, savedData.global_position.y)
	global_rotation_degrees = savedData.global_rotation_degrees
	data = savedData.data
	
