extends Area2D

var data = {
	"stats":{
		"size": 100
	}
}

func _ready():
	$Controller/Container.visible = false


func _on_Tree_body_entered(_body):
	$Controller/Container.visible = true


func _on_Tree_body_exited(_body):
	$Controller/Container.visible = false
