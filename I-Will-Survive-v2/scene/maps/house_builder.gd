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
## BSP: don't split rooms that are this wide/tall or narrower (in door-width units).
const MAX_ROOM_TILES: int = MAX_ROOM_UNITS
## BSP: don't create a room smaller than this in either dimension (in door-width units).
const MIN_ROOM_TILES: int = MIN_ROOM_UNITS
## Door width in pixels (sized to match one grid unit - one complete cell).
const DOOR_WIDTH_PX: int = 96
## Wall thickness in pixels.
const WALL_THICKNESS_PX: int = 12
## Minimum room size in door-width units (2 = 2 × 96px = 192px).
const MIN_ROOM_UNITS: int = 2
## Maximum room size before BSP splits (5 = 5 × 96px = 480px).
const MAX_ROOM_UNITS: int = 5
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

	# ── Step 1: Convert lot from tiles to grid units, then create footprint ───
	# Grid unit = DOOR_WIDTH_PX = 96px = 3 tiles
	# All coordinates must be exact multiples of grid units
	var tiles_per_unit: int = DOOR_WIDTH_PX / ts  # 96 / 32 = 3 tiles per grid unit
	
	# Convert lot rect to grid units (round to ensure integer grid coords)
	var lot_units := Rect2i(
		lot_rect.position.x / tiles_per_unit,
		lot_rect.position.y / tiles_per_unit,
		lot_rect.size.x / tiles_per_unit,
		lot_rect.size.y / tiles_per_unit)
	
	# Shrink by 1 grid unit on all sides for footprint
	var build_rect := Rect2i(
		lot_units.position.x + 1,
		lot_units.position.y + 1,
		lot_units.size.x - 2,
		lot_units.size.y - 2)

	if build_rect.size.x < MIN_ROOM_UNITS or build_rect.size.y < MIN_ROOM_UNITS:
		return null   # lot too small

	# ── House Node2D (not yet in tree — children added first) ─────────────────
	var house := Node2D.new()
	house.set_script(load("res://scene/entities/houses/house.gd"))
	house.name = "House"
	# NOTE: parent.add_child(house) is called at the VERY END so that _ready()
	# fires after the full subtree (including VisibleOnScreenNotifier2D) is built.

	# ── Step 2: Floor (convert units to pixels) ───────────────────────────────
	var floor_cr := ColorRect.new()
	floor_cr.color    = Color(0.55, 0.52, 0.48)
	floor_cr.position = Vector2(build_rect.position.x * DOOR_WIDTH_PX, build_rect.position.y * DOOR_WIDTH_PX)
	floor_cr.size     = Vector2(build_rect.size.x * DOOR_WIDTH_PX, build_rect.size.y * DOOR_WIDTH_PX)
	floor_cr.z_index  = 0
	house.add_child(floor_cr)

	# ── Step 3: BSP room division (already in door-width units) ────────────────
	var rooms: Array = []
	var splits: Array = []   # Array of {axis, px_unit, start_unit, length_unit}
	_bsp_split(build_rect, rng, rooms, splits)

	# ── Step 4: Spawn anchors (convert room units back to pixels) ─────────────
	var furniture_anchors: Array[Vector2] = []
	var loot_spawns: Array[Vector2]       = []
	var enemy_spawns: Array[Vector2]      = []

	for room: Rect2i in rooms:
		# Convert from door-width units to pixels
		var center_px := Vector2(
			(room.position.x + room.size.x * 0.5) * DOOR_WIDTH_PX,
			(room.position.y + room.size.y * 0.5) * DOOR_WIDTH_PX)
		if room.size.x >= 2 and room.size.y >= 2:  # at least 2 door-widths
			furniture_anchors.append(center_px)
		if rng.randf() < 0.4:
			loot_spawns.append(center_px + Vector2(
				rng.randf_range(-32.0, 32.0),
				rng.randf_range(-32.0, 32.0)))
		if rng.randf() < 0.3:
			enemy_spawns.append(center_px)

	house.set_meta("furniture_anchors", furniture_anchors)
	house.set_meta("loot_spawns",       loot_spawns)
	house.set_meta("enemy_spawns",      enemy_spawns)
	(house as House).capacity = maxi(1, enemy_spawns.size())

	# ── Step 5: Exterior walls (convert units to pixels) ──────────────────────
	var front_door_offset: int = rng.randi_range(-DOOR_WIDTH_PX, DOOR_WIDTH_PX)
	var back_door: bool        = rng.randf() < 0.5
	_build_exterior_walls(house, build_rect, facing, front_door_offset, back_door, DOOR_WIDTH_PX)

	# ── Step 6: Interior walls (solid walls only, no doors to avoid overlaps) ──
	for split: Dictionary in splits:
		_build_interior_wall_solid(house, build_rect, split, DOOR_WIDTH_PX)

	# ── Step 7: Roof + fade Area2D ─────────────────────────────────────────────
	var roof := ColorRect.new()
	roof.color    = Color(0.22, 0.20, 0.18)
	roof.position = Vector2(build_rect.position.x * DOOR_WIDTH_PX, build_rect.position.y * DOOR_WIDTH_PX)
	roof.size     = Vector2(build_rect.size.x * DOOR_WIDTH_PX, build_rect.size.y * DOOR_WIDTH_PX)
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
		build_rect.size.x * DOOR_WIDTH_PX + expand * 2,
		build_rect.size.y * DOOR_WIDTH_PX + expand * 2)
	trigger_shape.shape    = rect_shape
	trigger_shape.position = Vector2(
		build_rect.position.x * DOOR_WIDTH_PX + build_rect.size.x * DOOR_WIDTH_PX * 0.5,
		build_rect.position.y * DOOR_WIDTH_PX + build_rect.size.y * DOOR_WIDTH_PX * 0.5)
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
	sensor_rect.size      = Vector2(build_rect.size.x * DOOR_WIDTH_PX + expand * 2, build_rect.size.y * DOOR_WIDTH_PX + expand * 2)
	sensor_shape.shape    = sensor_rect
	sensor_shape.position = Vector2(
		build_rect.position.x * DOOR_WIDTH_PX + build_rect.size.x * DOOR_WIDTH_PX * 0.5,
		build_rect.position.y * DOOR_WIDTH_PX + build_rect.size.y * DOOR_WIDTH_PX * 0.5)
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
		Vector2(build_rect.position.x * DOOR_WIDTH_PX, build_rect.position.y * DOOR_WIDTH_PX),
		Vector2(build_rect.size.x * DOOR_WIDTH_PX, build_rect.size.y * DOOR_WIDTH_PX))
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


## Build an interior wall (from a BSP split line) with door occupying full grid cell.
## Walls sit centered on grid boundaries between rooms.
## Doors occupy exactly one full grid cell (96px) at grid-aligned positions.
static func _build_interior_wall_solid(
		house: Node2D,
		_build_rect: Rect2i,
		split: Dictionary,
		unit_px: int) -> void:

	var axis: String     = split["axis"]
	var split_unit: int  = split["px"]  # This is in grid units
	var start_unit: int  = split["start"]
	var length_unit: int = split["length"]
	
	# Convert to pixels - wall is centered on grid boundary
	var split_px: float  = float(split_unit  * unit_px)
	var start_px: float  = float(start_unit  * unit_px)
	var length_px: float = float(length_unit * unit_px)
	const WALL_T: int    = WALL_THICKNESS_PX
	const HALF_T: float  = WALL_T * 0.5
	
	# Place door in the center of the wall (no offset, door occupies full grid cell)
	if axis == "h":
		# Horizontal wall centered on grid line with door occupying full grid cell
		_wall_with_door(house, 
			Rect2(start_px, split_px - HALF_T, length_px, float(WALL_T)),
			true, 0, true)  # offset=0, door spans full 96px grid cell
	else:
		# Vertical wall centered on grid line with door occupying full grid cell
		_wall_with_door(house, 
			Rect2(split_px - HALF_T, start_px, float(WALL_T), length_px),
			false, 0, true)  # offset=0, door spans full 96px grid cell


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


## Split a wall rect into segments with a door gap that occupies a full grid cell.
## horizontal: true  = wall runs left-right (door gap cuts along X).
##             false = wall runs top-bottom (door gap cuts along Y).
## door_offset: pixels from wall centre to shift the door position (snapped to grid).
## is_interior: use the interior wall colour when true.
static func _wall_with_door(
		house: Node2D,
		wall_rect: Rect2,
		horizontal: bool,
		door_offset: int,
		is_interior: bool = false) -> void:

	var color: Color  = Color(0.40, 0.38, 0.35) if is_interior else Color(0.30, 0.28, 0.25)
	var door_w: float = float(DOOR_WIDTH_PX)  # Full grid cell width = 96px
	
	if horizontal:
		# Wall runs horizontally (left-right)
		var wall_len: float = wall_rect.size.x
		var wall_start: float = wall_rect.position.x
		
		# Find center of wall and snap door to nearest grid boundary
		var wall_center: float = wall_start + wall_len * 0.5 + float(door_offset)
		var door_center_unit: int = roundi(wall_center / door_w)  # Snap to grid unit
		var door_left: float = float(door_center_unit) * door_w - door_w * 0.5
		var door_right: float = door_left + door_w
		
		# Clamp door to stay within wall bounds (at grid boundaries)
		door_left = clampf(door_left, wall_start, wall_start + wall_len - door_w)
		door_right = door_left + door_w
		
		# Left wall segment (only draw if there's space)
		var left_w: float = door_left - wall_start
		if left_w > 0.5:  # At least half a pixel
			_wall_segment(house,
				Rect2(wall_start, wall_rect.position.y, left_w, wall_rect.size.y), color)
		
		# Right wall segment (only draw if there's space)
		var right_w: float = wall_start + wall_len - door_right
		if right_w > 0.5:  # At least half a pixel
			_wall_segment(house,
				Rect2(door_right, wall_rect.position.y, right_w, wall_rect.size.y), color)
	else:
		# Wall runs vertically (top-bottom)
		var wall_len: float = wall_rect.size.y
		var wall_start: float = wall_rect.position.y
		
		# Find center of wall and snap door to nearest grid boundary
		var wall_center: float = wall_start + wall_len * 0.5 + float(door_offset)
		var door_center_unit: int = roundi(wall_center / door_w)  # Snap to grid unit
		var door_top: float = float(door_center_unit) * door_w - door_w * 0.5
		var door_bottom: float = door_top + door_w
		
		# Clamp door to stay within wall bounds (at grid boundaries)
		door_top = clampf(door_top, wall_start, wall_start + wall_len - door_w)
		door_bottom = door_top + door_w
		
		# Top wall segment (only draw if there's space)
		var top_h: float = door_top - wall_start
		if top_h > 0.5:  # At least half a pixel
			_wall_segment(house,
				Rect2(wall_rect.position.x, wall_start, wall_rect.size.x, top_h), color)
		
		# Bottom wall segment (only draw if there's space)
		var bot_h: float = wall_start + wall_len - door_bottom
		if bot_h > 0.5:  # At least half a pixel
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
	rs.size        = rect.size
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
