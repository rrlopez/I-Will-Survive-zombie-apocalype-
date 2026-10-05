class_name HUD extends CanvasLayer
## HUD — CanvasLayer layer 2. Reactive, screen-safe layout.
## Holds typed refs to all sub-components. Never polls _process.
## GameState calls set_controller() to swap the active input controller.

@onready var health_gage:      Gage           = $SafeArea/Layout/TopBar/Gages/HealthGage
@onready var hunger_gage:      Gage           = $SafeArea/Layout/TopBar/Gages/HungerGage
@onready var calendar:         Calendar       = $SafeArea/Layout/TopBar/Gages/Calendar
@onready var notif_container:  NotifContainer = $SafeArea/Layout/NotifContainer
@onready var camera_effect:    CameraEffect   = $CameraEffect
@onready var _controller_slot: Control        = $ControllerSlot
@onready var _pause_btn:       Button         = $SafeArea/Layout/TopBar/PauseBtn

func _ready() -> void:
	Globals.hud = self
	_apply_safe_area()
	_pause_btn.pressed.connect(_on_pause_pressed)

func _apply_safe_area() -> void:
	var safe := DisplayServer.get_display_safe_area()
	var vp   := get_viewport().get_visible_rect().size
	var margin := $SafeArea as MarginContainer
	margin.add_theme_constant_override("margin_top",    safe.position.y)
	margin.add_theme_constant_override("margin_bottom", int(vp.y) - safe.end.y)
	margin.add_theme_constant_override("margin_left",   safe.position.x)
	margin.add_theme_constant_override("margin_right",  int(vp.x) - safe.end.x)

## Swap the active controller node inside the HUD controller slot.
## Does NOT touch Globals.current_controller — Globals setter owns that value.
func set_controller(controller: Control) -> void:
	for child in _controller_slot.get_children():
		_controller_slot.remove_child(child)
	if controller:
		_controller_slot.add_child(controller)

func _on_pause_pressed() -> void:
	Globals.state_manager.push_overlay(StateDefs.PAUSE)
