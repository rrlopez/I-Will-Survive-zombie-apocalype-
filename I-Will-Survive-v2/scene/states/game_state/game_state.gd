class_name GameState extends Node2D
## GameState — active gameplay state.
## Spawns player, starts world generation (new game) or reads layout (continue).
## ChunkStreamer activated/deactivated with this state.

@export var is_new_game: bool = true

const PLAYER_SCENE := preload("res://scene/entities/player/player.tscn")
const AUTO_SAVE_INTERVAL := 10.0   ## Phase 14 wires this up

var _save_timer: float = 0.0
var _player: Player = null


func _enter_tree() -> void:
	ChunkStreamer.activate()
	Pathfinder.enable()

	if is_new_game:
		# Connect to generation_complete then generate.
		WorldGenerator.generation_complete.connect(_on_generation_complete, CONNECT_ONE_SHOT)
		WorldGenerator.generate(0)   # 0 = random seed
		EventBus.notification_requested.emit("Generating world…")
	else:
		# Continue game: layout already exists, streamer reads it directly.
		_on_generation_complete()


func _exit_tree() -> void:
	ChunkStreamer.deactivate()
	Pathfinder.disable()
	_save_timer = 0.0


func _process(delta: float) -> void:
	_save_timer += delta
	if _save_timer >= AUTO_SAVE_INTERVAL:
		_save_timer = 0.0
		# Phase 14: Serialize.save_game()


func _on_generation_complete() -> void:
	_spawn_player()
	_spawn_day_night_stub()
	EventBus.notification_requested.emit("World ready!")


func _spawn_player() -> void:
	_player = PLAYER_SCENE.instantiate()
	_player.position = Vector2(540, 960)
	add_child(_player)

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
