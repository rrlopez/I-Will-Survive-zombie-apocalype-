extends Area2D

export(NodePath) onready var collider  = get_node(collider) as CollisionShape2D

var opponents = []

func _on_hitBox_body_entered(body):
	opponents.append(body)


func _on_hitBox_body_exited(body):
	opponents.erase(body)
