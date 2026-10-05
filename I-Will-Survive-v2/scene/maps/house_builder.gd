class_name HouseBuilder
## Static house-construction utility called from ChunkBase._on_activated().
## All positions are in chunk-local pixels (tile_coord * TILE_SIZE).
## (0,0) = chunk top-left; the chunk scene is already offset in world space.
##
## IMPORTANT: all children are added to `house` before `parent.add_child(house)`.
## This ensures _ready() fires bottom-up after the full node tree is built,
## so house.gd's _ready() can safely access $VisibleOnScreenNotifier2D.

## Minimum building dimensions (tiles). Lots smaller than this are skipped.
const MIN_BUILD_TILES: int = 12
## BSP: don't split rooms that are this wide/tall or narrower (tiles).
const MAX_ROOM_TILES: int = 15
## BSP: don't create a room smaller than this in either dimension (tiles).
const MIN_ROOM_TILES: int = 7
## Door width in pixels (1.875 tiles × 32 px = 60 px).
const DOOR_WIDTH_PX: int = 60
## Wall thickness in pixels (increased for better collision stability).
const WALL_THICKNESS_PX: int = 8
## Roof trigger expansion in pixels (added to all sides of building footprint).
const ROOF_TRIGGER_EXPANSION_PX: int = 64


## Build a house for `lot` and add it as a child of `parent`.
## Returns the House Node2D, or null if the lot is too small.
## lot keys: "rect" (Rect2i tile coords), "facing" (int), "lot_type" (String), "biome" (String).
## All pixel positions are chunk-local.
static func build_house(
		lot: Dictionary,
		parent: Node,
		rng: RandomNumberGenerator) -> Node2D:

	var ts: int      = Constants.TILE_SIZE        # 32
	var setback: int = Constants.LOT_SETBACK      # 2
	var lot_rect: Rect2i = lot["rect"]
	var facing: int      = lot["facing"]          # 0=N, 1=E, 2=S, 3=W

	# ── Step 1: Footprint ──────────────────────────────────────────────────────
	# Shrink lot_rect to get the building footprint:
	#   front (street side): setback + 1 pavement tile = 3 tiles
	#   sides and back: 1 tile each
	var front_shrink: int = setback + 1   # 3 tiles
	var side_shrink:  int = 1
	var build_rect: Rect2i

	match facing:
		0:  # front faces North (top)
			build_rect = Rect2i(
				lot_rect.position.x + side_shrink,
				lot_rect.position.y + front_shrink,
				lot_rect.size.x - side_shrink * 2,
				lot_rect.size.y - front_shrink - side_shrink)
		1:  # front faces East (right)
			build_rect = Rect2i(
				lot_rect.position.x + side_shrink,
				lot_rect.position.y + side_shrink,
				lot_rect.size.x - front_shrink - side_shrink,
				lot_rect.size.y - side_shrink * 2)
		2:  # front faces South (bottom)
			build_rect = Rect2i(
				lot_rect.position.x + side_shrink,
				lot_rect.position.y + side_shrink,
				lot_rect.size.x - side_shrink * 2,
				lot_rect.size.y - side_shrink - front_shrink)
		_:  # front faces West (left), facing == 3
			build_rect = Rect2i(
				lot_rect.position.x + front_shrink,
				lot_rect.position.y + side_shrink,
				lot_rect.size.x - front_shrink - side_shrink,
				lot_rect.size.y - side_shrink * 2)

	if build_rect.size.x < MIN_BUILD_TILES or build_rect.size.y < MIN_BUILD_TILES:
		return null   # lot too small — open space / garden

	# ── House Node2D (not yet in tree — children added first) ─────────────────
	var house := Node2D.new()
	house.set_script(load("res://scene/entities/houses/house.gd"))
	house.name = "House"
	# NOTE: parent.add_child(house) is called at the VERY END so that _ready()
	# fires after the full subtree (including VisibleOnScreenNotifier2D) is built.

	# ── Step 2: Floor ──────────────────────────────────────────────────────────
	var floor_cr := ColorRect.new()
	floor_cr.color    = Color(0.55, 0.52, 0.48)
	floor_cr.position = Vector2(build_rect.position.x * ts, build_rect.position.y * ts)
	floor_cr.size     = Vector2(build_rect.size.x * ts, build_rect.size.y * ts)
	floor_cr.z_index  = 0
	house.add_child(floor_cr)

	# ── Step 3: BSP room division ──────────────────────────────────────────────
	var rooms: Array = []
	var splits: Array = []   # Array of {axis, px, start, length} split-line descriptors
	_bsp_split(build_rect, rng, rooms, splits)

	# ── Step 4: Spawn anchors ──────────────────────────────────────────────────
	var furniture_anchors: Array[Vector2] = []
	var loot_spawns: Array[Vector2]       = []
	var enemy_spawns: Array[Vector2]      = []

	for room: Rect2i in rooms:
		var center_px := Vector2(
			(room.position.x + room.size.x * 0.5) * ts,
			(room.position.y + room.size.y * 0.5) * ts)
		if room.size.x >= 3 and room.size.y >= 3:
			furniture_anchors.append(center_px)
		if rng.randf() < 0.4:
			loot_spawns.append(center_px + Vector2(
				rng.randf_range(-16.0, 16.0),
				rng.randf_range(-16.0, 16.0)))
		if rng.randf() < 0.3:
			enemy_spawns.append(center_px)

	house.set_meta("furniture_anchors", furniture_anchors)
	house.set_meta("loot_spawns",       loot_spawns)
	house.set_meta("enemy_spawns",      enemy_spawns)
	(house as House).capacity = maxi(1, enemy_spawns.size())

	# ── Step 5: Exterior walls ─────────────────────────────────────────────────
	var front_door_offset: int = rng.randi_range(-ts, ts)
	var back_door: bool        = rng.randf() < 0.5
	_build_exterior_walls(house, build_rect, facing, front_door_offset, back_door, ts)

	# ── Step 6: Interior walls (from BSP splits) ───────────────────────────────
	for split: Dictionary in splits:
		_build_interior_wall(house, build_rect, split, rng, ts)

	# ── Step 7: Roof + fade Area2D ─────────────────────────────────────────────
	var roof := ColorRect.new()
	roof.color    = Color(0.22, 0.20, 0.18)
	roof.position = Vector2(build_rect.position.x * ts, build_rect.position.y * ts)
	roof.size     = Vector2(build_rect.size.x * ts, build_rect.size.y * ts)
	roof.z_index  = 10
	house.add_child(roof)
	(house as House).set_roof(roof)

	# Roof fade trigger Area2D (fires for player only), expanded for early fade.
	var trigger := Area2D.new()
	trigger.collision_layer = 0
	trigger.collision_mask  = Constants.LAYER_PLAYER
	trigger.name            = "RoofTrigger"
	var trigger_shape := CollisionShape2D.new()
	var rect_shape    := RectangleShape2D.new()
	var expand: int = ROOF_TRIGGER_EXPANSION_PX
	rect_shape.size         = Vector2(
		build_rect.size.x * ts + expand * 2,
		build_rect.size.y * ts + expand * 2)
	trigger_shape.shape    = rect_shape
	trigger_shape.position = Vector2(
		build_rect.position.x * ts + build_rect.size.x * ts * 0.5,
		build_rect.position.y * ts + build_rect.size.y * ts * 0.5)
	trigger.add_child(trigger_shape)
	house.add_child(trigger)
	trigger.body_entered.connect(func(_b: Node2D) -> void: (house as House).fade_roof_out())
	trigger.body_exited.connect( func(_b: Node2D) -> void: (house as House).fade_roof_in())

	# ── Step 8: cur_house sensor Area2D ───────────────────────────────────────
	var sensor := Area2D.new()
	sensor.collision_layer = 0
	sensor.collision_mask  = Constants.LAYER_PLAYER
	sensor.name            = "HouseSensor"
	var sensor_shape := CollisionShape2D.new()
	var sensor_rect  := RectangleShape2D.new()
	# Expand sensor beyond building footprint (reuse expand variable from above)
	sensor_rect.size      = Vector2(build_rect.size.x * ts + expand * 2, build_rect.size.y * ts + expand * 2)
	sensor_shape.shape    = sensor_rect
	sensor_shape.position = Vector2(
		build_rect.position.x * ts + build_rect.size.x * ts * 0.5,
		build_rect.position.y * ts + build_rect.size.y * ts * 0.5)
	sensor.add_child(sensor_shape)
	house.add_child(sensor)
	sensor.body_entered.connect(func(_b: Node2D) -> void:
		Globals.cur_house = house)
	sensor.body_exited.connect( func(_b: Node2D) -> void:
		if Globals.cur_house == house:
			Globals.cur_house = null)

	# ── Step 9: VisibleOnScreenNotifier2D ──────────────────────────────────────
	var notifier := VisibleOnScreenNotifier2D.new()
	notifier.rect = Rect2(
		Vector2(build_rect.position.x * ts, build_rect.position.y * ts),
		Vector2(build_rect.size.x * ts, build_rect.size.y * ts))
	notifier.name = "VisibleOnScreenNotifier2D"
	house.add_child(notifier)

	# ── Finally: add house to scene tree ──────────────────────────────────────
	# _ready() fires bottom-up here: notifier → sensor → trigger → roof → house
	# house.gd _ready() finds $VisibleOnScreenNotifier2D correctly.
	parent.add_child(house)

	return house


# ── BSP helpers ───────────────────────────────────────────────────────────────

## Recursive BSP split. Appends leaf rooms to `rooms`, split-line descriptors to `splits`.
static func _bsp_split(
		rect: Rect2i,
		rng: RandomNumberGenerator,
		rooms: Array,
		splits: Array) -> void:

	var can_split_h: bool = rect.size.y > MAX_ROOM_TILES
	var can_split_v: bool = rect.size.x > MAX_ROOM_TILES

	if not can_split_h and not can_split_v:
		rooms.append(rect)
		return

	var split_horizontal: bool
	if can_split_h and can_split_v:
		split_horizontal = rng.randf() < 0.5
	elif can_split_h:
		split_horizontal = true
	else:
		split_horizontal = false

	if split_horizontal:
		var min_split: int = rect.position.y + MIN_ROOM_TILES
		var max_split: int = rect.position.y + rect.size.y - MIN_ROOM_TILES
		if min_split > max_split:
			rooms.append(rect)
			return
		var split_y: int = rng.randi_range(min_split, max_split)
		splits.append({"axis": "h", "px": split_y, "start": rect.position.x, "length": rect.size.x})
		_bsp_split(
			Rect2i(rect.position.x, rect.position.y, rect.size.x, split_y - rect.position.y),
			rng, rooms, splits)
		_bsp_split(
			Rect2i(rect.position.x, split_y, rect.size.x, rect.position.y + rect.size.y - split_y),
			rng, rooms, splits)
	else:
		var min_split: int = rect.position.x + MIN_ROOM_TILES
		var max_split: int = rect.position.x + rect.size.x - MIN_ROOM_TILES
		if min_split > max_split:
			rooms.append(rect)
			return
		var split_x: int = rng.randi_range(min_split, max_split)
		splits.append({"axis": "v", "px": split_x, "start": rect.position.y, "length": rect.size.y})
		_bsp_split(
			Rect2i(rect.position.x, rect.position.y, split_x - rect.position.x, rect.size.y),
			rng, rooms, splits)
		_bsp_split(
			Rect2i(split_x, rect.position.y, rect.position.x + rect.size.x - split_x, rect.size.y),
			rng, rooms, splits)


# ── Wall builders ─────────────────────────────────────────────────────────────

## Build the 4 exterior walls with door gaps.
## facing: which wall has the front door (0=N top, 1=E right, 2=S bottom, 3=W left).
## front_door_offset: pixel offset from wall centre to shift the door (clamped inside helper).
## back_door: add a door gap on the opposite wall if true.
static func _build_exterior_walls(
		house: Node2D,
		build_rect: Rect2i,
		facing: int,
		front_door_offset: int,
		back_door: bool,
		ts: int) -> void:

	var px: float = build_rect.position.x * ts
	var py: float = build_rect.position.y * ts
	var pw: float = build_rect.size.x * ts
	var ph: float = build_rect.size.y * ts
	const WALL_T: int = WALL_THICKNESS_PX

	# North wall
	if facing == 0:
		_wall_with_door(house, Rect2(px, py, pw, WALL_T), true,  front_door_offset, false)
	elif back_door and facing == 2:
		_wall_with_door(house, Rect2(px, py, pw, WALL_T), true,  0, false)
	else:
		_solid_wall(house, Rect2(px, py, pw, WALL_T))

	# South wall
	if facing == 2:
		_wall_with_door(house, Rect2(px, py + ph - WALL_T, pw, WALL_T), true,  front_door_offset, false)
	elif back_door and facing == 0:
		_wall_with_door(house, Rect2(px, py + ph - WALL_T, pw, WALL_T), true,  0, false)
	else:
		_solid_wall(house, Rect2(px, py + ph - WALL_T, pw, WALL_T))

	# West wall
	if facing == 3:
		_wall_with_door(house, Rect2(px, py, WALL_T, ph), false, front_door_offset, false)
	elif back_door and facing == 1:
		_wall_with_door(house, Rect2(px, py, WALL_T, ph), false, 0, false)
	else:
		_solid_wall(house, Rect2(px, py, WALL_T, ph))

	# East wall
	if facing == 1:
		_wall_with_door(house, Rect2(px + pw - WALL_T, py, WALL_T, ph), false, front_door_offset, false)
	elif back_door and facing == 3:
		_wall_with_door(house, Rect2(px + pw - WALL_T, py, WALL_T, ph), false, 0, false)
	else:
		_solid_wall(house, Rect2(px + pw - WALL_T, py, WALL_T, ph))


## Build an interior wall (from a BSP split line) with one door gap.
static func _build_interior_wall(
		house: Node2D,
		_build_rect: Rect2i,
		split: Dictionary,
		rng: RandomNumberGenerator,
		ts: int) -> void:

	var axis: String     = split["axis"]
	var split_tile: int  = split["px"]
	var start_tile: int  = split["start"]
	var length_tile: int = split["length"]
	var split_px: float  = float(split_tile  * ts)
	var start_px: float  = float(start_tile  * ts)
	var length_px: float = float(length_tile * ts)
	const WALL_T: int    = WALL_THICKNESS_PX

	# Door placed at a random position [20%, 80%] along the wall to avoid corners.
	var door_offset: int = rng.randi_range(
		int(length_px * 0.2), int(length_px * 0.8))

	if axis == "h":
		# Horizontal interior wall at split Y, spans from start_px to start_px + length_px
		_wall_with_door(house, 
			Rect2(start_px, split_px, length_px, float(WALL_T)),
			true, door_offset - int(length_px / 2), true)
	else:
		# Vertical interior wall at split X, spans from start_px to start_px + length_px
		_wall_with_door(house, 
			Rect2(split_px, start_px, float(WALL_T), length_px),
			false, door_offset - int(length_px / 2), true)


## Add a StaticBody2D + ColorRect for a solid (no door) wall segment.
static func _solid_wall(house: Node2D, rect: Rect2) -> void:
	var body := StaticBody2D.new()
	body.collision_layer = Constants.LAYER_WALL
	body.collision_mask  = 0
	body.position = rect.position + rect.size * 0.5  # center the body
	
	var shape := CollisionShape2D.new()
	var rs    := RectangleShape2D.new()
	# Add 1px to each dimension to ensure overlap at corners
	rs.size        = rect.size + Vector2(1, 1)
	shape.position = Vector2.ZERO  # local to body, already centered
	shape.shape    = rs
	shape.one_way_collision = false
	body.add_child(shape)
	house.add_child(body)

	var cr := ColorRect.new()
	cr.color    = Color(0.30, 0.28, 0.25)
	cr.position = rect.position
	cr.size     = rect.size
	cr.z_index  = 1
	house.add_child(cr)


## Split a wall rect into two segments with a door gap in the middle.
## horizontal: true  = wall runs left-right (door gap cuts along X).
##             false = wall runs top-bottom (door gap cuts along Y).
## door_offset: pixels from wall centre to shift the door position (clamped to fit).
## is_interior: use the interior wall colour when true.
static func _wall_with_door(
		house: Node2D,
		wall_rect: Rect2,
		horizontal: bool,
		door_offset: int,
		is_interior: bool = false) -> void:

	var color: Color  = Color(0.40, 0.38, 0.35) if is_interior else Color(0.30, 0.28, 0.25)
	var door_w: float = float(HouseBuilder.DOOR_WIDTH_PX)

	if horizontal:
		var wall_len: float   = wall_rect.size.x
		var centre: float     = wall_rect.position.x + wall_len * 0.5 + float(door_offset)
		var door_left: float  = clampf(centre - door_w * 0.5,
			wall_rect.position.x + 4.0,
			wall_rect.position.x + wall_len - door_w - 4.0)
		var door_right: float = door_left + door_w

		var left_w: float = door_left - wall_rect.position.x
		if left_w > 0.0:
			_wall_segment(house,
				Rect2(wall_rect.position.x, wall_rect.position.y, left_w, wall_rect.size.y), color)

		var right_w: float = wall_rect.position.x + wall_len - door_right
		if right_w > 0.0:
			_wall_segment(house,
				Rect2(door_right, wall_rect.position.y, right_w, wall_rect.size.y), color)
	else:
		var wall_len: float    = wall_rect.size.y
		var centre: float      = wall_rect.position.y + wall_len * 0.5 + float(door_offset)
		var door_top: float    = clampf(centre - door_w * 0.5,
			wall_rect.position.y + 4.0,
			wall_rect.position.y + wall_len - door_w - 4.0)
		var door_bottom: float = door_top + door_w

		var top_h: float = door_top - wall_rect.position.y
		if top_h > 0.0:
			_wall_segment(house,
				Rect2(wall_rect.position.x, wall_rect.position.y, wall_rect.size.x, top_h), color)

		var bot_h: float = wall_rect.position.y + wall_len - door_bottom
		if bot_h > 0.0:
			_wall_segment(house,
				Rect2(wall_rect.position.x, door_bottom, wall_rect.size.x, bot_h), color)


## Add one wall segment: StaticBody2D collision + ColorRect visual.
static func _wall_segment(house: Node2D, rect: Rect2, color: Color) -> void:
	var body := StaticBody2D.new()
	body.collision_layer = Constants.LAYER_WALL
	body.collision_mask  = 0
	body.position = rect.position + rect.size * 0.5  # center the body
	
	var shape := CollisionShape2D.new()
	var rs    := RectangleShape2D.new()
	# Add 1px to each dimension to ensure overlap at corners
	rs.size        = rect.size + Vector2(1, 1)
	shape.position = Vector2.ZERO  # local to body, already centered
	shape.shape    = rs
	shape.one_way_collision = false
	body.add_child(shape)
	house.add_child(body)

	var cr := ColorRect.new()
	cr.color    = color
	cr.position = rect.position
	cr.size     = rect.size
	cr.z_index  = 1
	house.add_child(cr)
