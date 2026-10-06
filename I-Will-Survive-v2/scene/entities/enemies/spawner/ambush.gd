class_name AmbushSpawner extends Area2D
## Ambush spawner — triggered arena that spawns waves of enemies.
## Clamps player position within bounds until all enemies defeated or timer expires.

@export var enemy_type: String = "zombie"
@export var wave_count: int = 3              ## Number of waves to spawn
@export var enemies_per_wave: int = 4        ## Enemies in each wave
@export var wave_interval: float = 10.0      ## Seconds between waves
@export var arena_duration: float = 60.0     ## Max duration before arena releases
@export var spawn_radius: float = 300.0      ## Distance from center to spawn enemies

var _is_active: bool = false
var _waves_spawned: int = 0
var _enemies_alive: int = 0
var _player: Node = null
var _arena_bounds: Rect2
var _life_timer: float = 0.0

@onready var wave_timer: Timer = $WaveTimer
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

func _ready() -> void:
	# Connect signals
	body_entered.connect(_on_body_entered)
	
	if wave_timer:
		wave_timer.timeout.connect(_on_wave_timer_timeout)
		wave_timer.wait_time = wave_interval
		wave_timer.one_shot = false
	
	# Calculate arena bounds from collision shape
	if collision_shape and collision_shape.shape is RectangleShape2D:
		var rect_shape := collision_shape.shape as RectangleShape2D
		var size := rect_shape.size
		_arena_bounds = Rect2(
			global_position.x - size.x / 2.0,
			global_position.y - size.y / 2.0,
			size.x,
			size.y
		)

func _physics_process(delta: float) -> void:
	if not _is_active:
		return
	
	# Update life timer
	_life_timer -= delta
	
	# Clamp player within arena bounds
	if _player and is_instance_valid(_player):
		var clamped_pos := Vector2(
			clampf(_player.global_position.x, _arena_bounds.position.x, _arena_bounds.position.x + _arena_bounds.size.x),
			clampf(_player.global_position.y, _arena_bounds.position.y, _arena_bounds.position.y + _arena_bounds.size.y)
		)
		_player.global_position = clamped_pos
	
	# Check victory/timeout conditions
	if _life_timer <= 0.0 or (_waves_spawned >= wave_count and _enemies_alive <= 0):
		_end_ambush()

func _on_body_entered(body: Node) -> void:
	if _is_active or not body.is_in_group("player"):
		return
	
	# Activate ambush
	_is_active = true
	_player = body
	_life_timer = arena_duration
	
	# Spawn first wave immediately
	_spawn_wave()
	
	# Start wave timer for subsequent waves
	if wave_timer:
		wave_timer.start()
	
	# Visual/audio feedback
	# TODO Phase 15: Play ambush start sound, camera shake

func _on_wave_timer_timeout() -> void:
	if _waves_spawned < wave_count:
		_spawn_wave()
	else:
		wave_timer.stop()

func _spawn_wave() -> void:
	if not Factory or not Factory.enemies:
		push_warning("AmbushSpawner: Factory.enemies not available")
		return
	
	_waves_spawned += 1
	
	# Spawn enemies in a circle around the arena center
	var parent_node := get_parent()
	for i in enemies_per_wave:
		var angle := (TAU / enemies_per_wave) * i
		var offset := Vector2(cos(angle), sin(angle)) * spawn_radius
		var spawn_pos := global_position + offset
		
		var enemy = Factory.enemies.create_enemy(enemy_type, spawn_pos, angle + PI)
		if enemy:
			parent_node.add_child(enemy)
			_enemies_alive += 1
			
			# Track enemy death
			if enemy.has_signal("tree_exiting"):
				enemy.tree_exiting.connect(_on_enemy_died)
			
			# Force aggro on player
			if enemy.has_method("set_opponent") and _player:
				enemy.set_opponent(_player)

func _on_enemy_died() -> void:
	_enemies_alive -= 1

func _end_ambush() -> void:
	_is_active = false
	_player = null
	
	if wave_timer:
		wave_timer.stop()
	
	# Visual/audio feedback
	# TODO Phase 15: Play victory/escape sound
	
	# Remove spawner
	queue_free()
