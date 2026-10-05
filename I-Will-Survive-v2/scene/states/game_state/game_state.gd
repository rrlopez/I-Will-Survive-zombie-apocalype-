class_name GameState extends Node2D
## GameState — active gameplay state.
## Spawns player, day/night cycle stub, starts auto-save timer.
## is_new_game is set by MenuState before push_state().

@export var is_new_game: bool = true

const PLAYER_SCENE    := preload("res://scene/entities/player/player.tscn")
const AUTO_SAVE_INTERVAL := 10.0

var _save_timer: float = 0.0
var _player: Player = null

func _enter_tree() -> void:
	Pathfinder.enable()

	if is_new_game:
		_spawn_player()
		_spawn_day_night_stub()
		EventBus.notification_requested.emit("New game started")
	else:
		# Phase 14 will call Serialize.load_game() here
		_spawn_player()
		EventBus.notification_requested.emit("Game loaded")


func _exit_tree() -> void:
	Pathfinder.disable()
	_save_timer = 0.0


func _process(delta: float) -> void:
	_save_timer += delta
	if _save_timer >= AUTO_SAVE_INTERVAL:
		_save_timer = 0.0
		Serialize.save_game()


func _spawn_player() -> void:
	_player = PLAYER_SCENE.instantiate()
	_player.position = Vector2(540, 960)   # centre of 1080×1920 viewport
	add_child(_player)

	# Add controller to HUD controller slot and wire signals
	var ctrl_scene := preload("res://scene/entities/player/controller/controller.tscn")
	var ctrl: PlayerController = ctrl_scene.instantiate()
	if Globals.hud:
		Globals.hud.set_controller(ctrl)

	ctrl.move_input_changed.connect(_player.on_move_input_changed)
	ctrl.rotation_input.connect(_player.on_rotation_input)
	ctrl.action_pressed.connect(_player.on_action_pressed)
	ctrl.action_released.connect(_player.on_action_released)
	Globals._current_controller = ctrl


func _spawn_day_night_stub() -> void:
	# Phase 12 implements the real DayNightCycle.
	# For now just emit day_started so calendar + HUD initialise correctly.
	EventBus.day_started.emit(1)
