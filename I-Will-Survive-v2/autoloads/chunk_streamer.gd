extends Node
## ChunkStreamer — runtime infinite chunk loading/unloading.
## Reads user://world_layout.json written by WorldGenerator.
## Time-sliced: processes up to BUDGET_US microseconds per frame.
## Emits EventBus.chunk_activated / chunk_deactivated.

enum ChunkState {
	UNLOADED,
	QUEUED,
	LOADING,
	INSTANTIATING,
	NAV_BAKING,
	ACTIVE,
	UNLOADING,
}

const CHUNK_SIZE: int = 3200
const ACTIVE_RADIUS: int = 1
const BUFFER_RADIUS: int = 2
const PREFETCH_RADIUS: int = 3
const HYSTERESIS: int = 1          # extra chunks before unloading
const BUDGET_US: int = 4000
const ORIGIN_SHIFT_THRESHOLD: float = 8000.0

const FALLBACK_SCENE: String = "res://scene/maps/chunks/wilderness.tscn"

## The scene tree node under which all chunk instances are added.
var _chunk_root: Node2D = null
var _world_container: Node2D = null  ## rotates to create "world spins" effect
## coord (Vector2i) → { state, instance, scene_path }
var _chunk_registry: Dictionary = {}
## Ordered queue of coords to process next.
var _process_queue: Array[Vector2i] = []
## The chunk the player was in last frame.
var _player_chunk: Vector2i = Vector2i(-9999, -9999)
## True once activate() has been called.
var _active: bool = false
## Parsed world layout.
var _world_layout: Dictionary = {}
## World seed extracted from world_layout.json (Phase 5).
var world_seed: int = 0
## Loaded PackedScenes cache: path → PackedScene.
var _scene_cache: Dictionary = {}


func _ready() -> void:
	set_process(false)


## Called by GameState._enter_tree().
func activate() -> void:
	if _active:
		return
	_active = true
	# WorldContainer rotates to create the "world spins" effect.
	# ChunkRoot lives inside it so all chunks rotate together.
	var world_container := Node2D.new()
	world_container.name = "WorldContainer"
	get_tree().current_scene.add_child(world_container)
	_world_container = world_container

	_chunk_root = Node2D.new()
	_chunk_root.name = "ChunkRoot"
	world_container.add_child(_chunk_root)

	_load_world_layout()
	set_process(true)


## Called by GameState._exit_tree().
func deactivate() -> void:
	if not _active:
		return
	_active = false
	set_process(false)
	_unload_all_chunks()
	if is_instance_valid(_chunk_root):
		_chunk_root.queue_free()
		_chunk_root = null
	if is_instance_valid(_world_container):
		_world_container.queue_free()
		_world_container = null
	_chunk_registry.clear()
	_process_queue.clear()
	_player_chunk = Vector2i(-9999, -9999)
	_world_layout = {}
	_scene_cache = {}


## Returns true when all ACTIVE_RADIUS chunks around (0,0) are active.
## Used by LoadingState to know when to dismiss.
func is_initial_load_complete() -> bool:
	for x: int in range(-ACTIVE_RADIUS, ACTIVE_RADIUS + 1):
		for y: int in range(-ACTIVE_RADIUS, ACTIVE_RADIUS + 1):
			var coord := Vector2i(x, y)
			var d: int = abs(x) + abs(y)
			if d > ACTIVE_RADIUS:
				continue
			if coord not in _chunk_registry:
				return false
			if _chunk_registry[coord]["state"] != ChunkState.ACTIVE:
				return false
	return true


func _process(_delta: float) -> void:
	if not _active:
		return
	if not is_instance_valid(Globals.player):
		return

	# Track player chunk position using real world coords (unaffected by visual rotation)
	var player_pos: Vector2 = Globals.player.position
	var new_chunk := Vector2i(
		floori(player_pos.x / float(CHUNK_SIZE)),
		floori(player_pos.y / float(CHUNK_SIZE))
	)
	if new_chunk != _player_chunk:
		_player_chunk = new_chunk
		_rebuild_queue()

	# Time-sliced processing
	var budget_end: int = Time.get_ticks_usec() + BUDGET_US
	while not _process_queue.is_empty() and Time.get_ticks_usec() < budget_end:
		var coord: Vector2i = _process_queue.pop_front()
		_advance_chunk(coord)

	_check_origin_shift(Globals.player.position)


## Rebuild the ordered work queue whenever the player crosses a chunk boundary.
func _rebuild_queue() -> void:
	var unload_radius: int = PREFETCH_RADIUS + HYSTERESIS

	# Queue chunks in prefetch radius that are not yet loaded.
	var needed: Dictionary = {}
	for x: int in range(_player_chunk.x - PREFETCH_RADIUS, _player_chunk.x + PREFETCH_RADIUS + 1):
		for y: int in range(_player_chunk.y - PREFETCH_RADIUS, _player_chunk.y + PREFETCH_RADIUS + 1):
			var coord := Vector2i(x, y)
			var d: int = abs(coord.x - _player_chunk.x) + abs(coord.y - _player_chunk.y)
			if d <= PREFETCH_RADIUS:
				needed[coord] = true

	# Unload chunks beyond hysteresis radius.
	for coord in _chunk_registry.keys():
		var cv := coord as Vector2i
		var d: int = abs(cv.x - _player_chunk.x) + abs(cv.y - _player_chunk.y)
		if d > unload_radius:
			var entry: Dictionary = _chunk_registry[cv]
			if entry["state"] == ChunkState.ACTIVE:
				_begin_unload(cv)

	# Build sorted queue (closest first).
	_process_queue.clear()
	var to_queue: Array[Vector2i] = []
	for coord in needed.keys():
		var cv := coord as Vector2i
		var state: int = ChunkState.UNLOADED
		if cv in _chunk_registry:
			state = _chunk_registry[cv]["state"]
		if state == ChunkState.UNLOADED:
			to_queue.append(cv)
			_set_chunk_state(cv, ChunkState.QUEUED)

	to_queue.sort_custom(func(a: Vector2i, b: Vector2i) -> bool:
		var da: int = abs(a.x - _player_chunk.x) + abs(a.y - _player_chunk.y)
		var db: int = abs(b.x - _player_chunk.x) + abs(b.y - _player_chunk.y)
		return da < db
	)
	_process_queue = to_queue


## Drive one chunk through the state machine.
func _advance_chunk(coord: Vector2i) -> void:
	if coord not in _chunk_registry:
		return
	var entry: Dictionary = _chunk_registry[coord]
	match entry["state"]:
		ChunkState.QUEUED:
			_begin_load(coord)
		ChunkState.LOADING:
			_begin_instantiate(coord)
		ChunkState.INSTANTIATING:
			_begin_nav_bake(coord)
		ChunkState.NAV_BAKING:
			pass   # waiting for async callback
		_:
			pass


func _begin_load(coord: Vector2i) -> void:
	var scene_path: String = _get_chunk_scene_path(coord)
	if scene_path not in _scene_cache:
		var packed: PackedScene = load(scene_path)
		if packed:
			_scene_cache[scene_path] = packed
		else:
			push_error("ChunkStreamer: failed to load scene: " + scene_path)
			_chunk_registry.erase(coord)
			return
	_set_chunk_state(coord, ChunkState.LOADING)
	# Re-enqueue so _advance_chunk can drive LOADING → INSTANTIATING next frame.
	_process_queue.push_front(coord)


func _begin_instantiate(coord: Vector2i) -> void:
	var scene_path: String = _get_chunk_scene_path(coord)
	var packed: PackedScene = _scene_cache.get(scene_path)
	if not packed:
		_chunk_registry.erase(coord)
		return
	var instance: Node = packed.instantiate()
	if instance is ChunkBase:
		(instance as ChunkBase).chunk_coord = coord
	instance.position = Vector2(coord.x * CHUNK_SIZE, coord.y * CHUNK_SIZE)
	_chunk_root.add_child(instance)
	_chunk_registry[coord]["instance"] = instance
	_set_chunk_state(coord, ChunkState.INSTANTIATING)
	# Queue nav bake next frame
	_process_queue.push_front(coord)


func _begin_nav_bake(coord: Vector2i) -> void:
	var entry: Dictionary = _chunk_registry[coord]
	var instance: Node = entry.get("instance")
	if not is_instance_valid(instance):
		_set_chunk_state(coord, ChunkState.ACTIVE)
		_on_chunk_active(coord)
		return
	var nav_region: NavigationRegion2D = instance.get_node_or_null("NavRegion")
	if not nav_region or not nav_region.navigation_polygon:
		# No nav polygon on this chunk (stub) — skip baking, go straight to active.
		_set_chunk_state(coord, ChunkState.ACTIVE)
		_on_chunk_active(coord)
		return
	_set_chunk_state(coord, ChunkState.NAV_BAKING)
	# Async bake: gather geometry then bake.
	var source_data := NavigationMeshSourceGeometryData2D.new()
	NavigationServer2D.parse_source_geometry_data(
		nav_region.navigation_polygon,
		source_data,
		nav_region
	)
	NavigationServer2D.bake_from_source_geometry_data_async(
		nav_region.navigation_polygon,
		source_data,
		_on_nav_bake_done.bind(coord)
	)


func _on_nav_bake_done(coord: Vector2i) -> void:
	if coord not in _chunk_registry:
		return
	_set_chunk_state(coord, ChunkState.ACTIVE)
	_on_chunk_active(coord)


func _on_chunk_active(coord: Vector2i) -> void:
	var entry: Dictionary = _chunk_registry[coord]
	var instance: Node = entry.get("instance")
	if instance is ChunkBase:
		(instance as ChunkBase).activate()
	EventBus.chunk_activated.emit(coord)


func _begin_unload(coord: Vector2i) -> void:
	if coord not in _chunk_registry:
		return
	_set_chunk_state(coord, ChunkState.UNLOADING)
	var entry: Dictionary = _chunk_registry[coord]
	var instance: Node = entry.get("instance")
	if is_instance_valid(instance):
		if instance is ChunkBase:
			(instance as ChunkBase).deactivate()
		instance.queue_free()
	EventBus.chunk_deactivated.emit(coord)
	_chunk_registry.erase(coord)


func _unload_all_chunks() -> void:
	for coord in _chunk_registry.keys():
		var entry: Dictionary = _chunk_registry[coord as Vector2i]
		var instance: Node = entry.get("instance")
		if is_instance_valid(instance):
			if instance is ChunkBase:
				(instance as ChunkBase).deactivate()
			instance.queue_free()
	_chunk_registry.clear()


# ── Helpers ───────────────────────────────────────────────────────────

func _load_world_layout() -> void:
	var path: String = "user://world_layout.json"
	if not FileAccess.file_exists(path):
		push_warning("ChunkStreamer: no world_layout.json found; all chunks will use fallback.")
		return
	var text: String = FileAccess.get_file_as_string(path)
	var result: Variant = JSON.parse_string(text)
	if result is Dictionary:
		_world_layout = result as Dictionary
		world_seed = int(_world_layout.get("seed", 0))
	else:
		push_error("ChunkStreamer: failed to parse world_layout.json")


func _get_chunk_scene_path(coord: Vector2i) -> String:
	var key: String = "%d,%d" % [coord.x, coord.y]
	var chunks: Dictionary = _world_layout.get("chunks", {})
	if key in chunks:
		var entry: Dictionary = chunks[key]
		return entry.get("scene", FALLBACK_SCENE)
	return FALLBACK_SCENE


func _set_chunk_state(coord: Vector2i, state: int) -> void:
	if coord not in _chunk_registry:
		_chunk_registry[coord] = {"state": state, "instance": null}
	else:
		_chunk_registry[coord]["state"] = state


func _check_origin_shift(player_pos: Vector2) -> void:
	if player_pos.length() > ORIGIN_SHIFT_THRESHOLD:
		push_warning("ChunkStreamer: player beyond origin shift threshold — floating origin not yet implemented (Phase 16).")


## Stub — Phase 17 will instantiate a sound scene at origin.
@warning_ignore("unused_parameter")
func spawn_sound(_origin: Vector2, _radius: float) -> void:
	pass


## Stub — Phase 17 will spawn drop item scenes at pos.
@warning_ignore("unused_parameter")
func spawn_drop_items(_items_data: Array, _pos: Vector2) -> void:
	pass


# ── Phase 5 helpers ───────────────────────────────────────────────────────────

## Deterministic per-chunk RNG. Same inputs always produce the same sequence.
static func chunk_rng(seed_val: int, coord: Vector2i) -> RandomNumberGenerator:
	var rng := RandomNumberGenerator.new()
	rng.seed = hash(str(seed_val) + "," + str(coord.x) + "," + str(coord.y))
	return rng


## Returns biome string for this chunk from world_layout.
## Falls back to "wilderness" if the chunk is not in the layout.
func get_biome(coord: Vector2i) -> String:
	var key := "%d,%d" % [coord.x, coord.y]
	var chunks: Dictionary = _world_layout.get("chunks", {})
	if key in chunks:
		return (chunks[key] as Dictionary).get("biome", "wilderness")
	return "wilderness"


## Returns which of the 4 edges of this chunk have a road entering.
## 0=North (y-1), 1=East (x+1), 2=South (y+1), 3=West (x-1).
## Reads world_layout["roads"] which is Array[Array[String]].
func get_road_edges(coord: Vector2i) -> Array[int]:
	var edges: Array[int] = []
	var roads: Array = _world_layout.get("roads", [])
	var key := "%d,%d" % [coord.x, coord.y]
	# Neighbour keys indexed by edge number
	var neighbour_keys: Array[String] = [
		"%d,%d" % [coord.x, coord.y - 1],  # 0 = North
		"%d,%d" % [coord.x + 1, coord.y],  # 1 = East
		"%d,%d" % [coord.x, coord.y + 1],  # 2 = South
		"%d,%d" % [coord.x - 1, coord.y],  # 3 = West
	]
	for road_path: Array in roads:
		# Build a set of all chunk keys in this road path.
		var path_set: Dictionary = {}
		for s: String in road_path:
			path_set[s] = true
		if key not in path_set:
			continue
		for edge_idx: int in range(4):
			if neighbour_keys[edge_idx] in path_set and edge_idx not in edges:
				edges.append(edge_idx)
	return edges


## Set world rotation — rotates WorldContainer around the player's position.
func set_world_rotation(angle: float) -> void:
	if not is_instance_valid(_world_container):
		return
	if not is_instance_valid(Globals.player):
		return
	
	# Rotate the container
	_world_container.rotation = angle
	
	# Get player's exact center position in world space
	var player_center: Vector2 = Globals.player.global_position
	
	# Calculate the rotated position of the player center
	var rotated_center: Vector2 = player_center.rotated(angle)
	
	# Offset container so the player's center stays at the same visual position
	# This ensures rotation pivots exactly around the player's collision center
	_world_container.global_position = player_center - rotated_center
