extends Control
## Debug radar showing enemy positions relative to player.
## Attach this to a Control node in your UI.

var radar_size := 200.0
var radar_range := 1000.0  # How many pixels in game world = full radar

func _ready() -> void:
	# Position in corner
	position = Vector2(10, 10)
	size = Vector2(radar_size, radar_size)

func _draw() -> void:
	# Background
	draw_rect(Rect2(Vector2.ZERO, Vector2(radar_size, radar_size)), Color(0, 0, 0, 0.7))
	
	# Border
	draw_rect(Rect2(Vector2.ZERO, Vector2(radar_size, radar_size)), Color.WHITE, false, 2.0)
	
	# Center (player)
	var center := Vector2(radar_size, radar_size) * 0.5
	draw_circle(center, 5, Color.GREEN)
	
	# Get player position
	if not Globals.player or not is_instance_valid(Globals.player):
		return
	
	var player: Node2D = Globals.player
	if not player is Node2D:
		return
	
	# Draw enemies
	var enemies := get_tree().get_nodes_in_group("enemies")
	for enemy in enemies:
		if not enemy is Node2D:
			continue
		
		# Calculate relative position
		var rel_pos := enemy.global_position - player.global_position
		
		# Scale to radar
		var radar_pos := center + (rel_pos / radar_range) * (radar_size * 0.5)
		
		# Clamp to radar bounds
		radar_pos = radar_pos.clamp(Vector2.ZERO, Vector2(radar_size, radar_size))
		
		# Check if enemy has opponent (is chasing)
		var is_chasing := false
		if enemy.has_method("get_opponent"):
			is_chasing = enemy.get_opponent() != null
		
		# Draw enemy dot
		var color := Color.RED if is_chasing else Color.ORANGE
		draw_circle(radar_pos, 4, color)
		
		# Draw distance text
		var distance := rel_pos.length()
		if distance < radar_range:
			var dist_text := str(int(distance))
			draw_string(ThemeDB.fallback_font, radar_pos + Vector2(6, 0), dist_text, HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color.WHITE)

func _process(_delta: float) -> void:
	queue_redraw()
