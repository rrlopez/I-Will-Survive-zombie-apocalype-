class_name CameraEffect extends ColorRect
## CameraEffect — fullscreen red vignette that intensifies as health drops.
## Connects to EventBus.player_health_changed. Zero _process polling.
## Fades in below 66% health, full intensity at 10% health.

const THRESHOLD := 0.66   ## health ratio below which vignette starts appearing
const MIN_ALPHA := 0.0
const MAX_ALPHA := 0.75

func _ready() -> void:
	color   = Color(0.53, 0.03, 0.03, 0.0)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	EventBus.player_health_changed.connect(_on_health_changed)

func _on_health_changed(_old: float, new_val: float, max_val: float) -> void:
	var ratio := clampf(new_val / max_val if max_val > 0.0 else 0.0, 0.0, 1.0)

	var target_alpha: float
	if ratio >= THRESHOLD:
		target_alpha = MIN_ALPHA
	else:
		# Map [THRESHOLD → 0] to [0 → MAX_ALPHA]
		target_alpha = remap(ratio, THRESHOLD, 0.0, MIN_ALPHA, MAX_ALPHA)

	var tween := create_tween()
	tween.tween_property(self, "color:a", target_alpha, 0.3)
