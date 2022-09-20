extends Placesable

export(NodePath) onready var collider  = get_node(collider) as CollisionShape2D
export(NodePath) onready var areaCollider  = get_node(areaCollider) as CollisionShape2D
export(NodePath) onready var buttons  = get_node(buttons) as Node2D

func init():
	.init()
	yield(get_tree(), "idle_frame")
	collider.shape.radius = staticData.size.x/2
	areaCollider.shape.radius = collider.shape.radius + 10


func _on_Area_body_entered(_body):
	buttons.show()


func _on_Area_body_exited(_body):
	buttons.hide()


func _on_removeBtn_pressed():
	queue_free()



func serialize(savedData): 
	savedData.others.append(.serialize(savedData))



func deserialize(savedData):
	.deserialize(savedData)
	
