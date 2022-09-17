extends StaticBody2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	$Controller/Container.visible = false
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Area_body_entered(body):
	$Controller/Container.visible = true
	pass # Replace with function body.


func _on_Area_body_exited(body):
	$Controller/Container.visible = false
	pass # Replace with function body.
