extends Node2D
## Add this as a child of Enemy to make them highly visible for debugging.
## Shows enemy position, direction, and aggro state.

var enemy: Node = null
var label: Label = null

func _ready() -> void:
	enemy = get_parent()
	z_index = 100  # Draw on top
	
	# Create visible circle
	queue_redraw()
	
	# Create label showing state
	label = Label.new()
	label.position = Vector2(-50, -80)
	label.add_theme_color_override("font_color", Color.YELLOW)
	label.add_theme_font_size_override("font_size", 20)
	add_child(label)

func _draw() -> void:
	# Draw proximity detection circle (green, 80 pixels)
	var proximity_range := 80.0
	draw_arc(Vector2.ZERO, proximity_range, 0, TAU, 32, Color(0.0, 1.0, 0.0, 0.6), 2.0)
	draw_circle(Vector2.ZERO, proximity_range, Color(0.0, 1.0, 0.0, 0.1))
	
	# Draw enemy body (red circle - smaller)
	draw_circle(Vector2.ZERO, 25, Color(1.0, 0.0, 0.0, 0.5))
	draw_arc(Vector2.ZERO, 25, 0, TAU, 32, Color.RED, 2.0)
	
	# Draw facing direction arrow (yellow arrow pointing forward - smaller)
	var arrow_length := 50.0
	var arrow_end := Vector2(arrow_length, 0)
	var arrow_side1 := Vector2(arrow_length - 10, -8)
	var arrow_side2 := Vector2(arrow_length - 10, 8)
	
	# Draw bright yellow arrow
	draw_line(Vector2.ZERO, arrow_end, Color.YELLOW, 3.0)
	draw_line(arrow_end, arrow_side1, Color.YELLOW, 3.0)
	draw_line(arrow_end, arrow_side2, Color.YELLOW, 3.0)
	
	# Draw vision cone (cyan, 400 pixels, forward-facing, ±35°)
	var cone_angle := deg_to_rad(35.0)
	var cone_length := 400.0
	var cone_left := Vector2(cos(-cone_angle), sin(-cone_angle)) * cone_length
	var cone_right := Vector2(cos(cone_angle), sin(cone_angle)) * cone_length
	
	# Vision cone lines
	draw_line(Vector2.ZERO, cone_left, Color.CYAN, 1.5)
	draw_line(Vector2.ZERO, cone_right, Color.CYAN, 1.5)
	draw_line(cone_left, cone_right, Color(0.0, 1.0, 1.0, 0.3), 1.5)
	
	# Fill vision cone
	var points := PackedVector2Array([Vector2.ZERO, cone_left, cone_right])
	draw_colored_polygon(points, Color(0.0, 1.0, 1.0, 0.08))

func _process(_delta: float) -> void:
	if not enemy:
		return
	
	queue_redraw()
	
	# Keep label upright (counter-rotate)
	if label and enemy:
		label.rotation = -enemy.rotation
	
	# Update label
	var state_text := "IDLE"
	if enemy.has_method("get_opponent"):
		var opponent = enemy.get_opponent()
		if opponent:
			state_text = "CHASING!"
	
	if label:
		var rotation_deg := rad_to_deg(enemy.rotation)
		label.text = "ENEMY\n%s\nRot: %.0f°" % [state_text, rotation_deg]

