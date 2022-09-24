extends StaticBody2D


func _ready():
	$Controller/Container.visible = false
	pass # Replace with function body.


func _on_Area_body_entered(body):
	$Controller/Container.visible = true
	pass # Replace with function body.


func _on_Area_body_exited(body):
	$Controller/Container.visible = false
	pass # Replace with function body.
