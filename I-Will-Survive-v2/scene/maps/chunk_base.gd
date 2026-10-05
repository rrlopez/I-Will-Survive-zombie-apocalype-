class_name ChunkBase extends Node2D
## Base script for all chunk scenes.
## Chunk scenes assign chunk_coord before add_child().
## activate() / deactivate() are called by ChunkStreamer.
## Override _on_activated() / _on_deactivated() in subclasses (Phase 17).

const CHUNK_SIZE: int = 3200

## Chunk grid coordinate (set by ChunkStreamer before adding to tree).
var chunk_coord: Vector2i = Vector2i.ZERO

# ── Debug visuals (removed in Phase 17 when real art is in place) ─────────────
var _debug_rect: ColorRect = null
var _debug_label: Label    = null

func _ready() -> void:
	_add_debug_visuals()


func _add_debug_visuals() -> void:
	# Floor rect — distinct color per chunk type based on scene name
	_debug_rect = ColorRect.new()
	_debug_rect.size         = Vector2(CHUNK_SIZE, CHUNK_SIZE)
	_debug_rect.position     = Vector2.ZERO
	_debug_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_debug_rect.color        = _debug_color()
	add_child(_debug_rect)
	move_child(_debug_rect, 0)   # behind everything else

	# Coordinate label in the centre
	_debug_label = Label.new()
	_debug_label.text                   = "%d,%d\n%s" % [chunk_coord.x, chunk_coord.y, _short_name()]
	_debug_label.position               = Vector2(CHUNK_SIZE * 0.5 - 120, CHUNK_SIZE * 0.5 - 30)
	_debug_label.add_theme_font_size_override("font_size", 28)
	_debug_label.modulate               = Color(1, 1, 1, 0.7)
	add_child(_debug_label)

	# Border lines (just draw 4 ColorRects as thin borders)
	for side in [
		Rect2(0, 0, CHUNK_SIZE, 4),
		Rect2(0, CHUNK_SIZE - 4, CHUNK_SIZE, 4),
		Rect2(0, 0, 4, CHUNK_SIZE),
		Rect2(CHUNK_SIZE - 4, 0, 4, CHUNK_SIZE),
	]:
		var border := ColorRect.new()
		border.position     = side.position
		border.size         = side.size
		border.color        = Color(0, 0, 0, 0.5)
		border.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(border)


func _debug_color() -> Color:
	var name := scene_file_path.get_file()
	if "city_center" in name:   return Color(0.25, 0.25, 0.35, 1)   # dark blue-grey
	if "city_block"  in name:   return Color(0.22, 0.22, 0.30, 1)   # grey
	if "suburb"      in name:   return Color(0.20, 0.30, 0.20, 1)   # dark green
	if "outskirts"   in name:   return Color(0.28, 0.24, 0.18, 1)   # brown
	if "poi_police"  in name:   return Color(0.15, 0.15, 0.40, 1)   # deep blue
	if "poi_hospital" in name:  return Color(0.35, 0.15, 0.15, 1)   # red
	if "poi_school"  in name:   return Color(0.30, 0.30, 0.10, 1)   # olive
	if "poi_airport" in name:   return Color(0.10, 0.25, 0.35, 1)   # teal
	if "poi_military" in name:  return Color(0.15, 0.25, 0.15, 1)   # military green
	if "poi_mall"    in name:   return Color(0.30, 0.20, 0.30, 1)   # purple
	if "poi_gas"     in name:   return Color(0.30, 0.28, 0.10, 1)   # yellow-brown
	return Color(0.15, 0.20, 0.15, 1)                                # wilderness default


func _short_name() -> String:
	return scene_file_path.get_file().replace(".tscn", "").replace("_", " ")

# ── Lifecycle ─────────────────────────────────────────────────────────────────

## Called by ChunkStreamer after nav bake completes.
func activate() -> void:
	set_process_mode(PROCESS_MODE_INHERIT)
	# Update label now that chunk_coord is set by streamer
	if _debug_label:
		_debug_label.text = "%d,%d\n%s" % [chunk_coord.x, chunk_coord.y, _short_name()]
	_on_activated()


## Called by ChunkStreamer when the chunk leaves the active ring.
func deactivate() -> void:
	set_process_mode(PROCESS_MODE_DISABLED)
	_on_deactivated()


## Override in subclasses to start spawners, connect day signal, etc.
func _on_activated() -> void:
	pass


## Override in subclasses to stop spawners, disconnect signals, etc.
func _on_deactivated() -> void:
	pass
