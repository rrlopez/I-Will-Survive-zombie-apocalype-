class_name House extends Node2D
## Runtime house node created by HouseBuilder.
## Manages roof fade, cur_house tracking, and daily spawn stubs.

## Maximum enemies that can be active inside this house at once.
var capacity: int = 3

## The last day enemies/loot were spawned. -1 = never.
var spawn_day: int = -1

# ── Internal refs set by HouseBuilder ────────────────────────────────────────
var _roof: ColorRect  = null  ## The roof ColorRect node
var _roof_tween: Tween = null ## Active tween (killed before starting a new one)


func _ready() -> void:
	# VisibleOnScreenNotifier2D connects / disconnects day_started to save resources.
	var notifier: VisibleOnScreenNotifier2D = $VisibleOnScreenNotifier2D
	notifier.screen_entered.connect(_on_screen_entered)
	notifier.screen_exited.connect(_on_screen_exited)


func _on_screen_entered() -> void:
	EventBus.day_started.connect(_on_day_started)


func _on_screen_exited() -> void:
	if EventBus.day_started.is_connected(_on_day_started):
		EventBus.day_started.disconnect(_on_day_started)


func _on_day_started(day_number: int) -> void:
	if spawn_day == day_number:
		return   # already spawned this day
	spawn_day = day_number
	spawn_enemies()
	spawn_loot()


## Stub — Phase 6 will implement actual enemy spawning.
func spawn_enemies() -> void:
	var spawns: Array = get_meta("enemy_spawns", []) as Array
	print("[House] spawn_enemies: %d anchors at day %d" % [spawns.size(), spawn_day])


## Stub — Phase 8 will implement actual loot spawning.
func spawn_loot() -> void:
	var spawns: Array = get_meta("loot_spawns", []) as Array
	print("[House] spawn_loot: %d anchors at day %d" % [spawns.size(), spawn_day])


# ── Roof fade (called from HouseBuilder after roof node is created) ──────────

## Store a reference to the roof ColorRect so fade methods can tween it.
func set_roof(roof_node: ColorRect) -> void:
	_roof = roof_node


func fade_roof_out() -> void:
	if not is_instance_valid(_roof):
		return
	if is_instance_valid(_roof_tween):
		_roof_tween.kill()
	_roof_tween = create_tween()
	_roof_tween.tween_property(_roof, "modulate:a", 0.0, 0.3)


func fade_roof_in() -> void:
	if not is_instance_valid(_roof):
		return
	if is_instance_valid(_roof_tween):
		_roof_tween.kill()
	_roof_tween = create_tween()
	_roof_tween.tween_property(_roof, "modulate:a", 1.0, 0.3)
