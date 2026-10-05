class_name Gage extends Control
## Gage — reactive health/hunger bar. Zero _process polling.
## Connects to EventBus signals in _ready() and redraws only on actual change.
## Uses _draw() for the fill rect — no child ColorRect needed.

@export var stat_type: StringName = &"health"   ## "health" or "hunger"
@export var fill_color: Color     = Color(0.77, 0.26, 0.26, 1)
@export var bg_color: Color       = Color(0.15, 0.15, 0.15, 1)
@export var icon_texture: Texture2D = null

var _fill_ratio: float = 1.0

func _ready() -> void:
	match stat_type:
		&"health": EventBus.player_health_changed.connect(_on_stat_changed)
		&"hunger": EventBus.player_hunger_changed.connect(_on_stat_changed)

func _on_stat_changed(_old: float, new_val: float, max_val: float) -> void:
	_fill_ratio = clampf(new_val / max_val if max_val > 0.0 else 0.0, 0.0, 1.0)
	queue_redraw()

func _draw() -> void:
	var r := Rect2(Vector2.ZERO, size)
	# Background
	draw_rect(r, bg_color)
	# Fill
	var fill := Rect2(Vector2.ZERO, Vector2(size.x * _fill_ratio, size.y))
	draw_rect(fill, fill_color)
	# Icon (left side)
	if icon_texture:
		var icon_size := Vector2(size.y, size.y)
		draw_texture_rect(icon_texture, Rect2(Vector2.ZERO, icon_size), false)
