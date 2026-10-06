extends Node2D
## Simple circle visual for the player (top-down view)
## Counter-rotates with camera to always appear upright on screen

func _ready() -> void:
	z_index = 10

func _process(_delta: float) -> void:
	# This node is a child of Player
	# Player.gd rotates the Body node by _facing to counter the camera rotation
	# We need to do the same thing - get the parent's _facing value
	var player = get_parent()
	if player and "_facing" in player:
		# Rotate by the same amount as the body to stay upright
		rotation = player._facing
	
	queue_redraw()

func _draw() -> void:
	# Draw player as a circle
	draw_circle(Vector2.ZERO, 20, Color(0.2, 0.75, 0.3))  # Green body
	draw_arc(Vector2.ZERO, 20, 0, TAU, 32, Color(0.0, 0.5, 0.2), 2.0)  # Dark green outline
	
	# Draw arrow pointing up (since the node rotates with _facing, this stays screen-upright)
	var up_direction := Vector2(0, -25)
	draw_line(Vector2.ZERO, up_direction, Color.WHITE, 3.0)
	draw_circle(up_direction, 3, Color.WHITE)  # Dot at the end
