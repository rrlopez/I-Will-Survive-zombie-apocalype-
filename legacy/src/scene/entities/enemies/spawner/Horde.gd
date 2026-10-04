extends Area2D

export(NodePath) onready var collider  = get_node(collider) as CollisionShape2D

var data = {
	"size": 300
}

func _ready():
	collider.shape.radius = max(data.size, collider.shape.radius)
	for enemy in Globals.mapManager.spawnEnemies(Vector2(data.size, data.size), 100):
		add_child(enemy)
