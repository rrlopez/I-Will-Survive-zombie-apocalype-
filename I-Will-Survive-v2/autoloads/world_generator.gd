extends Node
## WorldGenerator — one-shot procedural world layout generator.
## Call generate(seed) once at new-game start.
## Runs time-sliced across frames (one step per frame) so loading screen stays smooth.
## Emits generation_complete when user://world_layout.json is written.

@warning_ignore("unused_signal")
signal generation_complete

const PLAY_RADIUS: int = 4
@warning_ignore("unused_private_class_variable")
const BUDGET_US: int = 4000
@warning_ignore("unused_private_class_variable")
const CITY_CENTER: Vector2i = Vector2i.ZERO

# Filler scenes by biome
const FILLER_SCENES: Dictionary = {
	"city_center": "res://scene/maps/chunks/city_center.tscn",
	"city":        "res://scene/maps/chunks/city_block_a.tscn",
	"suburb":      "res://scene/maps/chunks/suburb_a.tscn",
	"outskirts":   "res://scene/maps/chunks/outskirts_a.tscn",
	"wilderness":  "res://scene/maps/chunks/wilderness.tscn",
}

# City block variants for fill pass
const CITY_VARIANTS: Array[String] = [
	"res://scene/maps/chunks/city_block_a.tscn",
	"res://scene/maps/chunks/city_block_b.tscn",
	"res://scene/maps/chunks/city_block_c.tscn",
]
const SUBURB_VARIANTS: Array[String] = [
	"res://scene/maps/chunks/suburb_a.tscn",
	"res://scene/maps/chunks/suburb_b.tscn",
]

var world_seed: int = 0
var _step_index: int = -1   # -1 = idle
var _layout: Dictionary = {}
var _occupied: Dictionary = {}   # Vector2i -> true
var _poi_defs: Array = []  # Array of Dictionary; untyped to accept JSON-parsed values
var _biome_rules: Dictionary = {}
var _write_thread: Thread = Thread.new()


func _ready() -> void:
	set_process(false)


## Start the generation pipeline. seed_value=0 means pick a random seed.
func generate(seed_value: int = 0) -> void:
	if seed_value == 0:
		world_seed = randi()
	else:
		world_seed = seed_value
	_layout = {"seed": world_seed, "version": 1, "chunks": {}, "roads": [], "poi_locations": {}}
	_occupied = {}
	_step_index = 0
	set_process(true)


func _process(_delta: float) -> void:
	match _step_index:
		0: _step_load_data()
		1: _step_biome_map()
		2: _step_poi_placement()
		3: _step_road_network()
		4: _step_fill()
		5: _step_finalize()
		_: set_process(false)


# ── Step 0: Load data files ────────────────────────────────────────────
func _step_load_data() -> void:
	var poi_text: String = FileAccess.get_file_as_string("res://data/poi_registry.json")
	var poi_result: Variant = JSON.parse_string(poi_text)
	if poi_result is Dictionary:
		_poi_defs = (poi_result as Dictionary).get("pois", [])

	var biome_text: String = FileAccess.get_file_as_string("res://data/biome_rules.json")
	var biome_result: Variant = JSON.parse_string(biome_text)
	if biome_result is Dictionary:
		_biome_rules = biome_result as Dictionary
	_step_index = 1


# ── Step 1: Biome map ─────────────────────────────────────────────────
func _step_biome_map() -> void:
	# Biome is computed on demand in _get_biome(); no pre-computation needed.
	# Mark origin as city_center immediately.
	_layout["chunks"]["0,0"] = {
		"scene": FILLER_SCENES["city_center"],
		"biome": "city_center",
		"poi": null
	}
	_occupied[Vector2i.ZERO] = true
	_step_index = 2


# ── Step 2: POI placement ─────────────────────────────────────────────
func _step_poi_placement() -> void:
	# Sort by most constrained first: smallest (max - min) distance window.
	var sorted_pois: Array = _poi_defs.duplicate()
	sorted_pois.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		var window_a: int = a.get("max_distance_from_origin", 5) - a.get("min_distance_from_origin", 1)
		var window_b: int = b.get("max_distance_from_origin", 5) - b.get("min_distance_from_origin", 1)
		return window_a < window_b
	)

	for poi_def: Dictionary in sorted_pois:
		var count: int = poi_def.get("count", 1)
		for _i: int in range(count):
			_place_poi(poi_def)
	_step_index = 3


func _place_poi(poi_def: Dictionary) -> void:
	var min_dist: int = poi_def.get("min_distance_from_origin", 1)
	var max_dist: int = poi_def.get("max_distance_from_origin", 3)
	var min_sep: int = poi_def.get("min_distance_from_other_pois", 1)
	var biome_req: String = poi_def.get("biome", "any")
	var poi_id: String = poi_def.get("id", "")
	var scene_path: String = poi_def.get("scene", "")

	var placed: bool = false
	for attempt: int in range(4):   # 0 = normal, 1–3 = relaxed sep
		var effective_sep: int = max(0, min_sep - attempt)
		var candidates: Array[Vector2i] = []
		for x: int in range(-PLAY_RADIUS, PLAY_RADIUS + 1):
			for y: int in range(-PLAY_RADIUS, PLAY_RADIUS + 1):
				var coord := Vector2i(x, y)
				if coord in _occupied:
					continue
				var dist: int = abs(x) + abs(y)
				if dist < min_dist or dist > max_dist:
					continue
				if biome_req != "any" and _get_biome(coord) != biome_req:
					continue
				if not _check_poi_separation(coord, effective_sep):
					continue
				candidates.append(coord)
		if candidates.is_empty():
			continue
		var rng: RandomNumberGenerator = chunk_rng(world_seed, Vector2i(attempt * 1000, candidates.size()))
		var pick: Vector2i = candidates[rng.randi() % candidates.size()]
		var key: String = "%d,%d" % [pick.x, pick.y]
		_layout["chunks"][key] = {
			"scene": scene_path,
			"biome": _get_biome(pick),
			"poi": poi_id
		}
		_layout["poi_locations"][poi_id] = key
		_occupied[pick] = true
		placed = true
		break
	if not placed:
		push_warning("WorldGenerator: could not place POI '%s' — skipped." % poi_id)


func _check_poi_separation(coord: Vector2i, min_sep: int) -> bool:
	for existing in _occupied.keys():
		var ec := existing as Vector2i
		if abs(coord.x - ec.x) + abs(coord.y - ec.y) < min_sep:
			return false
	return true


# ── Step 3: Road network ──────────────────────────────────────────────
func _step_road_network() -> void:
	var roads: Array[Array] = []
	var poi_locs: Dictionary = _layout.get("poi_locations", {})
	for _poi_id in poi_locs.keys():
		var coord_str: String = poi_locs[_poi_id]
		var parts: PackedStringArray = coord_str.split(",")
		if parts.size() < 2:
			continue
		var target := Vector2i(int(parts[0]), int(parts[1]))
		var path: Array = _bfs_path(Vector2i.ZERO, target)
		if not path.is_empty():
			roads.append(path)
	_layout["roads"] = roads
	_step_index = 4


## BFS shortest path through chunk grid between two coords.
## Returns Array of "x,y" strings.
func _bfs_path(from: Vector2i, to: Vector2i) -> Array:
	if from == to:
		return []
	var visited: Dictionary = {}
	var parent: Dictionary = {}
	var queue: Array[Vector2i] = [from]
	visited[from] = true
	var dirs: Array[Vector2i] = [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]
	while not queue.is_empty():
		var cur: Vector2i = queue.pop_front()
		for d: Vector2i in dirs:
			var next: Vector2i = cur + d
			if next in visited:
				continue
			if abs(next.x) > PLAY_RADIUS + 1 or abs(next.y) > PLAY_RADIUS + 1:
				continue
			visited[next] = true
			parent[next] = cur
			if next == to:
				# Reconstruct path
				var path: Array = []
				var step: Vector2i = to
				while step != from:
					path.push_front("%d,%d" % [step.x, step.y])
					step = parent[step]
				path.push_front("%d,%d" % [from.x, from.y])
				return path
			queue.append(next)
	return []   # no path found (shouldn't happen in a bounded grid)


# ── Step 4: Fill pass ─────────────────────────────────────────────────
func _step_fill() -> void:
	for x: int in range(-PLAY_RADIUS, PLAY_RADIUS + 1):
		for y: int in range(-PLAY_RADIUS, PLAY_RADIUS + 1):
			var coord := Vector2i(x, y)
			var key: String = "%d,%d" % [x, y]
			if key in _layout["chunks"]:
				continue   # already placed (origin or POI)
			var biome: String = _get_biome(coord)
			var scene: String = _get_filler_scene(coord, biome)
			_layout["chunks"][key] = {"scene": scene, "biome": biome, "poi": null}
	_step_index = 5


func _get_filler_scene(coord: Vector2i, biome: String) -> String:
	var rng: RandomNumberGenerator = chunk_rng(world_seed, coord)
	match biome:
		"city", "city_center":
			return CITY_VARIANTS[rng.randi() % CITY_VARIANTS.size()]
		"suburb":
			return SUBURB_VARIANTS[rng.randi() % SUBURB_VARIANTS.size()]
		"outskirts":
			return FILLER_SCENES["outskirts"]
		_:
			return FILLER_SCENES["wilderness"]


# ── Step 5: Finalize — write JSON ─────────────────────────────────────
func _step_finalize() -> void:
	set_process(false)
	_step_index = 6
	# Write on a thread so main thread isn't blocked by disk I/O.
	_write_thread = Thread.new()
	_write_thread.start(_write_layout.bind(_layout.duplicate(true)))


func _write_layout(layout: Dictionary) -> void:
	var json_str: String = JSON.stringify(layout, "\t")
	var f: FileAccess = FileAccess.open("user://world_layout.json", FileAccess.WRITE)
	if f:
		f.store_string(json_str)
		f.close()
	else:
		push_error("WorldGenerator: failed to write user://world_layout.json")
	# Signal must be emitted on main thread
	call_deferred("_on_write_done")


func _on_write_done() -> void:
	if _write_thread.is_started():
		_write_thread.wait_to_finish()
	generation_complete.emit()


# ── Helpers ───────────────────────────────────────────────────────────

## Deterministic per-chunk RNG. Same seed + coord always yields same sequence.
func chunk_rng(seed_val: int, coord: Vector2i) -> RandomNumberGenerator:
	var rng := RandomNumberGenerator.new()
	rng.seed = hash(str(seed_val) + "," + str(coord.x) + "," + str(coord.y))
	return rng


## Returns biome string for a chunk coordinate based on Manhattan distance + jitter.
func _get_biome(coord: Vector2i) -> String:
	var dist: int = abs(coord.x) + abs(coord.y)
	if dist == 0:
		return "city_center"
	var jitter_strength: float = _biome_rules.get("jitter_strength", 0.25)
	var rng: RandomNumberGenerator = chunk_rng(world_seed + 9999, coord)
	var jitter: float = rng.randf_range(-jitter_strength, jitter_strength)
	var effective_dist: float = float(dist) + jitter

	var city_range: Array[float] = []
	var raw_city: Array = _biome_rules.get("city", [1.0, 2.0])
	for v in raw_city:
		city_range.append(float(v))
	var suburb_range: Array[float] = []
	var raw_suburb: Array = _biome_rules.get("suburb", [2.0, 3.0])
	for v in raw_suburb:
		suburb_range.append(float(v))
	var outskirts_range: Array[float] = []
	var raw_outskirts: Array = _biome_rules.get("outskirts", [3.0, 4.0])
	for v in raw_outskirts:
		outskirts_range.append(float(v))
	var wilderness_min: float = float(_biome_rules.get("wilderness", 5))

	if effective_dist <= city_range[1]:
		return "city"
	elif effective_dist <= suburb_range[1]:
		return "suburb"
	elif effective_dist <= outskirts_range[1]:
		return "outskirts"
	elif effective_dist < wilderness_min:
		# Gap between outskirts boundary and wilderness minimum — treat as outskirts.
		return "outskirts"
	else:
		return "wilderness"
