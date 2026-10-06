class_name Player extends Entity
## Player — the player character.
##
## Movement model (Dead Town / world-rotates feel):
##   • Player node rotates in world space (_facing).
##   • Body child is counter-rotated so the sprite always faces UP on screen.
##   • Camera2D is a child of Player → inherits rotation → world appears to spin.
##   • Input is in screen space (up = up on screen), rotated by _facing before
##     applying to physics so the movement always matches what the player sees.
##
## Input accumulator pattern:
##   Controller emits move_input_changed(dir) → stored in _move_input.
##   Controller emits rotation_input(delta)   → accumulated into _target_facing.
##   _physics_process reads both each frame — no stack, no race conditions.

# ── Node references ───────────────────────────────────────────────────────────
@onready var _body:             Node2D   = $Body
@onready var _weapon_mount:     Marker2D = $WeaponMount
@onready var _hand_mount:       Marker2D = $HandMount
@onready var _pickup_area:      Area2D   = $PickupArea
@onready var _camera:           Camera2D = $Camera2D
@warning_ignore("unused_private_class_variable")
@onready var _placable_preview: Node2D   = $PlacablePreview  ## Phase 11
@warning_ignore("unused_private_class_variable")
@onready var _upper_anim:       Node     = $Body/UpperBody/UpperBodyAnimation  ## Phase 10

# ── Movement state ────────────────────────────────────────────────────────────
var _move_input: Vector2    = Vector2.ZERO  ## screen-space direction from controller
var _facing: float          = 0.0           ## current rotation in radians (world)
var _target_facing: float   = 0.0           ## desired rotation (lerped toward)

# ── Equipped items ────────────────────────────────────────────────────────────
var _current_weapon = null    ## active weapon node (Phase 10)
var _current_hand_item = null ## active hand item node (torch etc.) (Phase 10)

# ── Lifecycle ─────────────────────────────────────────────────────────────────

func _ready() -> void:
	super._ready()   # connects stats.health.stat_changed → _on_health_changed

	# Load player stats from data file
	var player_data: Dictionary = Utils.import_data("res://data/player.json")
	if player_data and player_data.has("stats"):
		stats.init_from_data(player_data["stats"])

	# Register in Globals
	Globals.player = self
	
	# Add to player group for enemy AI detection
	add_to_group("player")
	
	print("Player registered: ", self, " at position: ", global_position)

	# Connect pickup area
	_pickup_area.body_entered.connect(_on_pickup_area_body_entered)

	# Connect level-up to stat scaling
	if stats.level is LevelStat:
		(stats.level as LevelStat).leveled_up.connect(_on_leveled_up)


func _physics_process(delta: float) -> void:
	# ROTATION MODEL:
	# Camera rotates +_facing → view rotates clockwise
	# Player body ALSO rotates +_facing → cancels out, appears upright on screen
	# Physics body (Player node) does NOT rotate → collision stays stable
	
	# Rotate camera to spin the world view
	_camera.rotation = _facing
	
	# Offset camera forward (in rotated space) so player appears lower on screen
	# This gives more view ahead and less behind
	_camera.position = Vector2(0, -200).rotated(_facing)
	
	# Rotate body by same amount to cancel camera's visual rotation
	# Camera rotates view +45°, body rotates +45° in world → appears at 0° on screen
	_body.rotation = _facing
	
	# Movement: input is in screen space. Since camera is rotated but player physics
	# body is NOT rotated, we need to rotate input to match the camera's rotation.
	var world_dir := _move_input.rotated(_facing)
	var speed := stats.move_speed.value if stats.move_speed else 180.0
	
	# Calculate target velocity in world space
	var target_velocity := world_dir * speed + applied_force
	velocity = velocity.lerp(target_velocity, 15.0 * delta)
	
	move_and_slide()

	# Decay applied_force
	applied_force = applied_force.lerp(Vector2.ZERO, Constants.FORCE_FRICTION * delta)

	# Animation
	_update_animation(_move_input)


# ── Controller signal handlers ────────────────────────────────────────────────

## Called by Controller when joystick moves. `dir` is screen-space normalized.
func on_move_input_changed(dir: Vector2) -> void:
	_move_input = dir

## Called by Controller on drag. `delta_angle` in radians.
func on_rotation_input(delta_angle: float) -> void:
	_target_facing += delta_angle
	_facing = _target_facing  ## snap immediately on desktop input — no lerp lag

## Called by Controller on action (fire, reload, interact).
func on_action_pressed(action: StringName) -> void:
	match action:
		&"fire":
			if _current_weapon and _current_weapon.has_method("fire"):
				_current_weapon.fire()
		&"reload":
			if _current_weapon and _current_weapon.has_method("reload"):
				_current_weapon.reload()

func on_action_released(_action: StringName) -> void:
	pass

# ── Entity overrides ──────────────────────────────────────────────────────────

func hurt(_damage: float, _source: Node = null) -> void:
	var died := stats.take_damage(_damage)

	# Camera shake
	var tween := create_tween()
	var intensity := clampf(_damage * 0.05, 2.0, 20.0)
	tween.tween_property(_camera, "offset",
		Vector2(randf_range(-intensity, intensity), randf_range(-intensity, intensity)), 0.05)
	tween.tween_property(_camera, "offset", Vector2.ZERO, 0.1)

	# Knockback from source direction
	if _source:
		_apply_knockback(_source.global_position.direction_to(global_position), _damage * 2.0)

	if died:
		die()


func die() -> void:
	# Phase 3 will push GameOverState via SceneStateManager.
	# For now emit through EventBus so Phase 3 can wire it up.
	EventBus.player_died.emit()
	queue_free()


func _on_health_changed(old_val: float, new_val: float) -> void:
	# Emit for HUD gage and camera effect (Phase 3)
	var max_hp := stats.health.max_value if stats.health.max_value >= 0.0 else stats.health.base_value
	EventBus.player_health_changed.emit(old_val, new_val, max_hp)

# ── Equipment API (fleshed out Phase 10) ─────────────────────────────────────

func set_weapon(weapon_node: Node) -> void:
	if _current_weapon:
		_weapon_mount.remove_child(_current_weapon)
	_current_weapon = weapon_node
	if weapon_node:
		_weapon_mount.add_child(weapon_node)


func set_hand_item(item_node: Node) -> void:
	if _current_hand_item:
		_hand_mount.remove_child(_current_hand_item)
	_current_hand_item = item_node
	if item_node:
		_hand_mount.add_child(item_node)

# ── Sound ─────────────────────────────────────────────────────────────────────

## Spawn a sound event at player position (Phase 6 enemies react to this).
func spawn_sound(radius: float) -> void:
	if Globals.map_manager and Globals.map_manager.has_method("spawn_sound"):
		Globals.map_manager.spawn_sound(global_position, radius)

# ── Pickup ────────────────────────────────────────────────────────────────────

func _on_pickup_area_body_entered(body: Node) -> void:
	# Phase 8 will handle DropItem pickup logic
	if body.has_method("pick_up"):
		body.pick_up(self)

# ── Level-up ──────────────────────────────────────────────────────────────────

func _on_leveled_up(new_level: int) -> void:
	stats.apply_level_scaling(new_level)
	# Restore health to full on level-up
	stats.health.value = stats.health.max_value if stats.health.max_value >= 0.0 else stats.health.base_value
	EventBus.player_levelled_up.emit(new_level)

# ── Animation ─────────────────────────────────────────────────────────────────

func _update_animation(world_move_dir: Vector2) -> void:
	# Convert world-space move direction to local space for BlendSpace2D
	if not _body:
		return
	var lower_body := _body.get_node_or_null("LowerBody")
	if not lower_body:
		return
	var anim_tree := lower_body.get_node_or_null("AnimationTree")
	if not anim_tree:
		return
	# Local velocity: rotate world dir back by facing so "forward" = (0,-1)
	var local_vel := world_move_dir.rotated(-_facing)
	anim_tree.set("parameters/BlendSpace2D/blend_position", local_vel)
