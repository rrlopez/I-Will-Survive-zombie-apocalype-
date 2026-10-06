class_name BTRunner extends Node
## BTRunner — executes behavior tree with configurable tick rate and LOD.
## Owns the blackboard (per-instance state) and ticks the shared tree resource.

@export var tree: BTTreeResource = null
@export var tick_interval: float = 0.1  # 10Hz default

var _blackboard: Dictionary = {}
var _agent: Node = null
var _timer: float = 0.0
var _is_initialized: bool = false

func _ready() -> void:
	set_physics_process(false)  # Wait for init

## Initialize the BT runner with the agent (Enemy).
## Call this after the agent is ready.
func init(agent: Node) -> void:
	_agent = agent
	_is_initialized = true
	
	if tree:
		tree.initialize(_blackboard, _agent)
		print("BTRunner initialized for ", agent.name, " with tree: ", tree, " root: ", tree.root)
	else:
		print("WARNING: BTRunner.init() called but tree is null for ", agent.name)
	
	set_physics_process(true)

func _physics_process(delta: float) -> void:
	if not _is_initialized or not tree or not _agent:
		return
	
	_timer += delta
	if _timer >= tick_interval:
		_timer = 0.0
		tree.tick(_blackboard, _agent, tick_interval)

## Set tick rate based on distance to player (LOD system).
## Distance < 400u:    20Hz (0.05s)  — active combat
## Distance 400-1200u: 10Hz (0.10s)  — chasing
## Distance > 1200u:    3Hz (0.33s)  — idle wandering
func set_tick_rate_by_distance(distance: float) -> void:
	if distance < 400.0:
		tick_interval = 0.05  # 20Hz
	elif distance < 1200.0:
		tick_interval = 0.1   # 10Hz
	else:
		tick_interval = 0.33  # 3Hz

## Set tick rate for off-screen enemies (minimum heartbeat).
func set_offscreen_tick_rate() -> void:
	tick_interval = 1.0  # 1Hz

## Set tick rate for on-screen enemies (restore normal rate).
func set_onscreen_tick_rate(distance: float = 1000.0) -> void:
	set_tick_rate_by_distance(distance)

## Get the blackboard dictionary for external access.
func get_blackboard() -> Dictionary:
	return _blackboard

## Set a blackboard value directly.
func set_blackboard_value(key: StringName, value: Variant) -> void:
	_blackboard[key] = value

## Get a blackboard value directly.
func get_blackboard_value(key: StringName, default: Variant = null) -> Variant:
	return _blackboard.get(key, default)
