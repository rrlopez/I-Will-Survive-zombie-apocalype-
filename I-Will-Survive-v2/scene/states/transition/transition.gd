class_name Transition extends CanvasLayer
## Transition — fullscreen fade-to-black dissolve between states.
## Always on top (layer 3). Runs with PROCESS_MODE_ALWAYS so it works while paused.
## SceneStateManager awaits play_out() before swapping scenes, then play_in() after.

@onready var _rect: ColorRect = $ColorRect

const FADE_DURATION := 0.25

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_rect.color   = Color(0, 0, 0, 0)
	_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE

## Fade to black. Await this before swapping the scene.
func play_out() -> void:
	_rect.mouse_filter = Control.MOUSE_FILTER_STOP  # block input during transition
	var tween := create_tween()
	tween.tween_property(_rect, "color", Color(0, 0, 0, 1), FADE_DURATION)
	await tween.finished

## Fade back in. Await this after the new scene is added.
func play_in() -> void:
	var tween := create_tween()
	tween.tween_property(_rect, "color", Color(0, 0, 0, 0), FADE_DURATION)
	await tween.finished
	_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
