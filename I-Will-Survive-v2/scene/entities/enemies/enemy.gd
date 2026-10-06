class_name Enemy extends Entity
## Enemy — AI-controlled hostile entity with behavior tree, three-tier movement, and herd aggro.
## Phase 6 implementation following the masterplan.

# ── Movement Tier System ──────────────────────────────────────────────────────
enum MoveTier {
	FLOW_FIELD,        ## Tier 1: Far from player, uses flow field (Phase 7)
	NAVIGATION_AGENT,  ## Tier 2: Mid-range, uses NavigationAgent2D
	DIRECT_SEEK        ## Tier 3: Close to player, direct steering + separation
}

# ── Constants ─────────────────────────────────────────────────────────────────
const FORCE_FRICTION: float = 0.85
const TIER_CHECK_INTERVAL: float = 1.0  # Check tier transition every 1 second
const SEARCH_DURATION: float = 4.0      # How long to search last known position

# ── Components (references set in _ready) ─────────────────────────────────────
@onready var visual_root: Node2D = $VisualRoot
@onready var navigation_agent: NavigationAgent2D = $NavigationAgent2D
@onready var vision_cone: Node2D = $VisionCone
@onready var attack_hitbox: Area2D = $AttackHitBox
@onready var aggro_area: Area2D = $AggroArea
@onready var growl_timer: Timer = $GrowlTimer
@onready var body_lower: Node2D = $VisualRoot/LowerBody
@onready var body_upper: Node2D = $VisualRoot/UpperBody
@onready var bt_runner: Node = $BTRunner if has_node("BTRunner") else null

# ── State ─────────────────────────────────────────────────────────────────────
var _opponent: Node = null
var _blackboard: Dictionary = {}
var _move_tier: MoveTier = MoveTier.FLOW_FIELD
var _vision_rays: Array[RayCast2D] = []
var _is_persistent: bool = false  # True = save this enemy (aggroed or special)
var _tier_check_timer: float = 0.0
var _search_timer: float = 0.0
var _current_attack: Resource = null  # EnemyAttack instance

# ── Initialization ────────────────────────────────────────────────────────────

func _ready() -> void:
	super._ready()
	
	# Configure stats from factory metadata if present
	if has_meta("enemy_definition") and Factory and Factory.enemies:
		var enemy_def: Dictionary = get_meta("enemy_definition")
		Factory.enemies.configure_enemy_stats(self, enemy_def)
	
	# Cache vision rays FIRST
	if vision_cone:
		for child in vision_cone.get_children():
			if child is RayCast2D:
				_vision_rays.append(child)
	
	# Update vision rays to 400 pixel range (hard-coded for now)
	var vision_range: float = 400.0
	for i in range(_vision_rays.size()):
		var ray := _vision_rays[i]
		var angle := (TAU / _vision_rays.size()) * i
		ray.target_position = Vector2(cos(angle), sin(angle)) * vision_range
	
	if not _vision_rays.is_empty():
		print("[ENEMY] Set ", _vision_rays.size(), " vision rays to range: ", vision_range)
	
	# Initialize blackboard
	_blackboard[BlackboardKeys.OPPONENT] = null
	_blackboard[BlackboardKeys.DESTINATION] = global_position
	_blackboard[BlackboardKeys.ATTACK_TIMER] = 0.0
	_blackboard[BlackboardKeys.IS_BLOCKED] = false
	_blackboard[BlackboardKeys.PATH_READY] = false
	_blackboard[BlackboardKeys.LAST_KNOWN_POS] = Vector2.ZERO
	
	# Connect aggression range changes to update aggro area
	if stats and stats.has_stat("aggression_range"):
		stats.get_stat("aggression_range").stat_changed.connect(_on_aggression_range_changed)
		# Initialize aggro area radius immediately
		if aggro_area:
			var aggro_shape := aggro_area.get_node_or_null("CollisionShape2D") as CollisionShape2D
			if aggro_shape and aggro_shape.shape is CircleShape2D:
				var aggro_range := stats.aggression_range.value if stats.aggression_range else 50.0
				(aggro_shape.shape as CircleShape2D).radius = aggro_range
	
	# Connect growl timer
	if growl_timer:
		growl_timer.timeout.connect(_on_growl_timer_timeout)
		growl_timer.wait_time = randf_range(3.0, 12.0)
		growl_timer.start()
	
	# Connect aggro area
	if aggro_area:
		aggro_area.body_entered.connect(_on_aggro_area_body_entered)
	
	# Initialize navigation agent
	if navigation_agent:
		navigation_agent.velocity_computed.connect(_on_navigation_velocity_computed)
	
	# Initialize BT Runner BEFORE setting blackboard values so it creates its internal blackboard
	if bt_runner:
		bt_runner.init(self)
		# Now share the same blackboard reference
		_blackboard = bt_runner.get_blackboard()
		# Set blackboard initial values
		_blackboard[BlackboardKeys.OPPONENT] = null
		_blackboard[BlackboardKeys.DESTINATION] = global_position
		_blackboard[BlackboardKeys.ATTACK_TIMER] = 0.0
		_blackboard[BlackboardKeys.IS_BLOCKED] = false
		_blackboard[BlackboardKeys.PATH_READY] = false
		_blackboard[BlackboardKeys.LAST_KNOWN_POS] = Vector2.ZERO
		# Set initial tick rate based on distance to player
		_update_bt_tick_rate()
	
	# Connect visibility notifier for LOD
	if has_node("VisibilityNotifier"):
		var notifier := get_node("VisibilityNotifier") as VisibleOnScreenNotifier2D
		if notifier:
			notifier.screen_entered.connect(_on_screen_entered)
			notifier.screen_exited.connect(_on_screen_exited)

# ── Physics Process ───────────────────────────────────────────────────────────

func _physics_process(delta: float) -> void:
	# Sync opponent from blackboard (BT updates it)
	var old_opponent = _opponent
	if _blackboard.has(BlackboardKeys.OPPONENT):
		_opponent = _blackboard[BlackboardKeys.OPPONENT]
	
	# If opponent changed, immediately update move tier
	if old_opponent != _opponent:
		_update_move_tier()
		if _opponent:
			print("[ENEMY] Opponent acquired! tier=", _move_tier)
	
	# Update movement based on tier FIRST
	_update_movement(delta)
	
	# Rotate to face movement direction AFTER velocity is set
	if velocity.length() > 10.0:  # Only rotate if actually moving
		var target_rotation := velocity.angle()
		var angle_speed_val: float = stats.angle_speed.value if stats and stats.angle_speed else 5.0
		rotation = lerp_angle(rotation, target_rotation, angle_speed_val * delta)
	
	# Counter-rotate visual root (same as player)
	if visual_root:
		visual_root.rotation = -rotation
	
	# Decay applied force
	applied_force = applied_force.lerp(Vector2.ZERO, FORCE_FRICTION)
	
	# Check tier transitions periodically
	_tier_check_timer += delta
	if _tier_check_timer >= TIER_CHECK_INTERVAL:
		_tier_check_timer = 0.0
		_update_move_tier()
		_update_bt_tick_rate()  # Keep tick rate in sync with distance
	
	# Handle search timer for last known position
	if _search_timer > 0.0:
		_search_timer -= delta
		if _search_timer <= 0.0:
			_blackboard[BlackboardKeys.LAST_KNOWN_POS] = Vector2.ZERO

# ── Movement System ───────────────────────────────────────────────────────────

func _update_movement(_delta: float) -> void:
	match _move_tier:
		MoveTier.FLOW_FIELD:
			# Phase 7: Flow field implementation
			_apply_flow_field_movement()
		MoveTier.NAVIGATION_AGENT:
			_apply_navigation_agent_movement()
		MoveTier.DIRECT_SEEK:
			_apply_direct_seek_movement()
	
	# Apply movement
	var final_velocity := velocity + applied_force
	velocity = final_velocity
	move_and_slide()

func _apply_flow_field_movement() -> void:
	# Check if we're in wander mode (no opponent but has destination)
	if not _opponent and _blackboard.has(BlackboardKeys.DESTINATION):
		var destination = _blackboard[BlackboardKeys.DESTINATION]
		if destination and destination is Vector2:
			var distance: float = global_position.distance_to(destination)
			if distance > 30.0:
				var direction: Vector2 = global_position.direction_to(destination)
				var wander_speed: float = 50.0
				if stats and stats.move_speed:
					wander_speed = stats.move_speed.value * 0.5
				velocity = direction * wander_speed
				return
	
	# No opponent and no valid destination - stop
	velocity = Vector2.ZERO

func _apply_navigation_agent_movement() -> void:
	if not navigation_agent:
		velocity = Vector2.ZERO
		return
	
	if not _opponent:
		velocity = Vector2.ZERO
		return
	
	# Update navigation target to current opponent position
	navigation_agent.target_position = _opponent.global_position
	
	# Check if target is reachable - fall back to direct seek if not
	if not navigation_agent.is_target_reachable():
		_apply_direct_seek_movement()
		return
	
	if navigation_agent.is_navigation_finished():
		velocity = Vector2.ZERO
		return
	
	var next_position := navigation_agent.get_next_path_position()
	var direction := global_position.direction_to(next_position)
	var move_speed: float = stats.move_speed.value if stats and stats.move_speed else 100.0
	velocity = direction * move_speed

func _apply_direct_seek_movement() -> void:
	if not _opponent:
		velocity = Vector2.ZERO
		return
	
	var direction := global_position.direction_to(_opponent.global_position)
	var move_speed: float = stats.move_speed.value if stats and stats.move_speed else 100.0
	velocity = direction * move_speed
	
	# Simple separation from nearby enemies
	var separation := _calculate_separation_force()
	velocity += separation

func _calculate_separation_force() -> Vector2:
	var separation := Vector2.ZERO
	var nearby_enemies := get_tree().get_nodes_in_group("enemies")
	
	for enemy in nearby_enemies:
		if enemy == self or not is_instance_valid(enemy):
			continue
		
		var distance := global_position.distance_to(enemy.global_position)
		if distance < 50.0 and distance > 0.0:  # Separation radius
			var away: Vector2 = global_position - enemy.global_position
			separation += away.normalized() / distance
	
	return separation * 100.0  # Separation strength

func _update_move_tier() -> void:
	if not _opponent:
		_move_tier = MoveTier.FLOW_FIELD
		return
	
	var distance := global_position.distance_to(_opponent.global_position)
	
	if distance < 150.0:  # Close range
		_move_tier = MoveTier.DIRECT_SEEK
	else:  # Mid+ range - always use nav agent when opponent exists
		_move_tier = MoveTier.NAVIGATION_AGENT

func _on_navigation_velocity_computed(safe_velocity: Vector2) -> void:
	velocity = safe_velocity

# ── Opponent & Aggro System ───────────────────────────────────────────────────

func set_opponent(new_opponent: Node) -> void:
	if _opponent == new_opponent:
		return
	
	_opponent = new_opponent
	_blackboard[BlackboardKeys.OPPONENT] = new_opponent
	
	if new_opponent:
		_is_persistent = true
		
		# Expand aggro area to alert nearby enemies
		if aggro_area and stats.has_stat("aggression_range"):
			var aggro_shape := aggro_area.get_node("CollisionShape2D") as CollisionShape2D
			if aggro_shape and aggro_shape.shape is CircleShape2D:
				var aggro_range := stats.aggression_range.value if stats and stats.aggression_range else 200.0
				(aggro_shape.shape as CircleShape2D).radius = aggro_range
		
		# Set navigation target
		if navigation_agent:
			navigation_agent.target_position = new_opponent.global_position
		
		# Broadcast aggro event
		EventBus.enemy_aggroed.emit(global_position, new_opponent)
	else:
		# Shrink aggro area back
		if aggro_area:
			var aggro_shape := aggro_area.get_node("CollisionShape2D") as CollisionShape2D
			if aggro_shape and aggro_shape.shape is CircleShape2D:
				(aggro_shape.shape as CircleShape2D).radius = 0.0

func clear_opponent() -> void:
	set_opponent(null)
	_is_persistent = false

func set_last_known_position(pos: Vector2) -> void:
	_blackboard[BlackboardKeys.LAST_KNOWN_POS] = pos
	_search_timer = SEARCH_DURATION

func _on_aggro_area_body_entered(body: Node) -> void:
	# Herd aggro: nearby idle enemies inherit this enemy's target
	if body is Enemy and body._opponent == null and _opponent != null:
		body.set_opponent(_opponent)

func _on_aggression_range_changed(_old_val: float, new_val: float) -> void:
	# Update aggro area when aggression range stat changes
	if _opponent and aggro_area:
		var aggro_shape := aggro_area.get_node("CollisionShape2D") as CollisionShape2D
		if aggro_shape and aggro_shape.shape is CircleShape2D:
			(aggro_shape.shape as CircleShape2D).radius = new_val

# ── Vision System ─────────────────────────────────────────────────────────────

func can_see_target(target: Node) -> bool:
	if not is_instance_valid(target) or _vision_rays.is_empty():
		return false
	
	if not target is Node2D:
		return false
	
	# Get direction to target in world space
	var to_target_world: Vector2 = global_position.direction_to((target as Node2D).global_position)
	# Convert to local space of this enemy (accounts for enemy rotation)
	var to_target_local: Vector2 = to_target_world.rotated(-rotation)
	
	# Enemy "forward" in local space is Vector2.RIGHT (0 radians)
	# Check if target is within the forward cone
	var cone_half_angle := deg_to_rad(35.0)  # ±35° = 70° cone (slightly wider than ray spacing)
	var angle_to_target := to_target_local.angle()
	
	# Normalize angle to -PI to PI range
	while angle_to_target > PI:
		angle_to_target -= TAU
	while angle_to_target < -PI:
		angle_to_target += TAU
	
	# Target not in cone at all - skip raycast checks
	if abs(angle_to_target) > cone_half_angle:
		return false
	
	# Target is in the cone direction - check if any ray actually hits it
	for ray in _vision_rays:
		if not ray.is_colliding():
			continue
		var collider := ray.get_collider()
		# Accept both the CharacterBody2D and any Area2D children of the target
		if collider == target:
			return true
		if collider is Node and collider.get_parent() == target:
			return true
	
	return false

# ── Combat System ─────────────────────────────────────────────────────────────

func hurt(damage: float, source: Node = null) -> void:
	super.hurt(damage, source)
	
	# Play hurt animation
	if body_upper and body_upper.has_method("play_upper"):
		body_upper.play_upper("hurt")
	
	# Create blood effect (Phase 15)
	# TODO: Spawn blood particle effect
	
	# Aggro on attacker if not already aggroed
	if not _opponent and source:
		set_opponent(source)

func die() -> void:
	super.die()
	
	# Spawn drops as siblings (not parented to MapManager)
	_spawn_drops()
	
	# Emit death event
	EventBus.enemy_died.emit(self, global_position)
	
	# Remove from scene
	queue_free()

func _spawn_drops() -> void:
	# Phase 8: Item drop system
	# TODO: Implement drop spawning based on enemy type and loot tables
	pass

# ── Attack System ─────────────────────────────────────────────────────────────

func execute_attack(attack: RefCounted) -> void:
	if not attack:
		return
	
	_current_attack = attack
	
	if attack.has_method("prepare"):
		attack.prepare(self)
	
	if attack.has_method("execute"):
		attack.execute(self)

func is_attack_active() -> bool:
	if not _current_attack:
		return false
	
	if _current_attack.has_method("is_active"):
		return _current_attack.is_active(self, get_physics_process_delta_time())
	
	return false

func resolve_attack() -> void:
	if not _current_attack:
		return
	
	if _current_attack.has_method("resolve"):
		_current_attack.resolve(self)
	
	_current_attack = null

# ── Audio ─────────────────────────────────────────────────────────────────────

func _on_growl_timer_timeout() -> void:
	# Play growl sound
	# TODO: Phase 15 - Play audio via AudioStreamPlayer2D
	
	# Randomize next growl
	growl_timer.wait_time = randf_range(3.0, 12.0)

# ── Getters ───────────────────────────────────────────────────────────────────

func get_blackboard() -> Dictionary:
	return _blackboard

func get_opponent() -> Node:
	return _opponent

func is_persistent() -> bool:
	return _is_persistent

func get_move_tier() -> MoveTier:
	return _move_tier


# ── BT Tick Rate Management ───────────────────────────────────────────────────

func _update_bt_tick_rate() -> void:
	if not bt_runner:
		return
	
	# Get player reference
	var player: Node = null
	if Globals.player and is_instance_valid(Globals.player):
		player = Globals.player
	
	if not player or not is_instance_valid(player):
		# No player, use slow tick rate
		bt_runner.tick_interval = 0.33
		return
	
	if player is Node2D:
		var distance: float = global_position.distance_to(player.global_position)
		bt_runner.set_tick_rate_by_distance(distance)

func _on_screen_entered() -> void:
	if bt_runner:
		_update_bt_tick_rate()

func _on_screen_exited() -> void:
	if bt_runner and not _opponent:
		# Off-screen and no opponent: minimum tick rate
		bt_runner.set_offscreen_tick_rate()
