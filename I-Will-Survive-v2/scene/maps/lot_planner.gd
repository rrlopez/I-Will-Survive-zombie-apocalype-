class_name LotPlanner
## Static lot-generation utility called from ChunkBase._on_activated().
## All positions are in chunk-local tile coordinates (0,0 = chunk top-left).
## All methods are deterministic: same rng seed → same lots.

## Lot size tables by biome [min_w, max_w, min_d, max_d, max_lots, pattern].
## All dimensions in tiles.
const LOT_TABLE: Dictionary = {
	"city_center": {"min_w": 21, "max_w": 30, "min_d": 24, "max_d": 36, "max_lots": 8,  "pattern": "dense"},
	"city":        {"min_w": 24, "max_w": 36, "min_d": 27, "max_d": 42, "max_lots": 7,  "pattern": "street"},
	"suburb":      {"min_w": 30, "max_w": 45, "min_d": 33, "max_d": 52, "max_lots": 4,  "pattern": "street"},
	"outskirts":   {"min_w": 36, "max_w": 60, "min_d": 42, "max_d": 75, "max_lots": 2,  "pattern": "sparse"},
	"wilderness":  {"min_w": 27, "max_w": 42, "min_d": 33, "max_d": 52, "max_lots": 1,  "pattern": "isolated"},
}

## Returns Array of lot Dictionaries:
##   { "rect": Rect2i (tile coords, chunk-local),
##     "facing": int (0=N, 1=E, 2=S, 3=W — the street side),
##     "lot_type": String,
##     "biome": String }
## coord  — the chunk's grid coordinate (kept for possible future use).
## biome  — biome string from ChunkStreamer.get_biome().
## road_edges — Array[int] from ChunkStreamer.get_road_edges().
## rng    — already-seeded RandomNumberGenerator (deterministic per chunk).
static func generate_lots(
		coord: Vector2i,
		biome: String,
		road_edges: Array,
		rng: RandomNumberGenerator) -> Array:
	@warning_ignore("unused_parameter")
	var _coord := coord  # reserved for future use
	var table: Dictionary = LOT_TABLE.get(biome, LOT_TABLE["wilderness"])
	var max_lots: int     = table["max_lots"]
	var lots: Array       = []
	var chunk_tiles: int  = Constants.CHUNK_TILES    # 100
	var street_w: int     = Constants.STREET_WIDTH   # 4
	var pave_w: int       = Constants.PAVEMENT_WIDTH # 2

	# 1-tile margin so lots never touch the chunk border seam.
	const BORDER: int = 1

	# ── Isolated / wilderness path ────────────────────────────────────────────
	if road_edges.is_empty() or biome in ["wilderness", "outskirts"]:
		var count: int = rng.randi_range(0, max_lots)
		for _i: int in range(count):
			if lots.size() >= max_lots:
				break
			var w: int = rng.randi_range(table["min_w"], table["max_w"])
			var d: int = rng.randi_range(table["min_d"], table["max_d"])
			var max_x: int = chunk_tiles - BORDER - w
			var max_y: int = chunk_tiles - BORDER - d
			if max_x < BORDER or max_y < BORDER:
				continue
			var rx: int = rng.randi_range(BORDER, max_x)
			var ry: int = rng.randi_range(BORDER, max_y)
			var candidate := Rect2i(rx, ry, w, d)
			if not _overlaps_any(candidate, lots):
				lots.append({
					"rect":     candidate,
					"facing":   rng.randi_range(0, 3),
					"lot_type": "isolated",
					"biome":    biome,
				})
		return lots

	# ── Street-based placement ────────────────────────────────────────────────
	for edge: int in road_edges:
		if lots.size() >= max_lots:
			break

		# street_start: tile offset of the road band measured from the near chunk edge.
		var street_start: int
		var is_horizontal: bool = (edge == 0 or edge == 2)   # N or S → horizontal road
		var facing_inner: int   # direction lots face when on the street side
		var facing_outer: int   # direction lots face when on the far side

		match edge:
			0:  # North edge — street near top
				street_start = pave_w + 1
				facing_inner = 2   # inner = south side of road, faces north
				facing_outer = 0
			1:  # East edge — street near right
				street_start = chunk_tiles - pave_w - 1 - street_w
				facing_inner = 3   # inner = west side of road, faces east
				facing_outer = 1
			2:  # South edge — street near bottom
				street_start = chunk_tiles - pave_w - 1 - street_w
				facing_inner = 0   # inner = north side of road, faces south
				facing_outer = 2
			_:  # West edge (3) — street near left
				street_start = pave_w + 1
				facing_inner = 1   # inner = east side of road, faces west
				facing_outer = 3

		# Place lots on both sides of the street (side 0 = near edge, side 1 = interior).
		for side: int in [0, 1]:
			if lots.size() >= max_lots:
				break
			var cursor: int  = BORDER
			var end_pos: int = chunk_tiles - BORDER
			while cursor < end_pos and lots.size() < max_lots:
				var w: int = rng.randi_range(table["min_w"], table["max_w"])
				var d: int = rng.randi_range(table["min_d"], table["max_d"])
				if cursor + w > end_pos:
					break
				var lot_rect: Rect2i
				if is_horizontal:
					# Street runs left-right; lots are above (side 0) or below (side 1) it.
					if side == 0:
						# Above: lot bottom touches street_start - 1
						var ry: int = maxi(BORDER, street_start - d)
						lot_rect = Rect2i(cursor, ry, w, d)
					else:
						# Below: lot top = street_start + street_w + 1
						var ry: int = street_start + street_w + 1
						if ry + d > chunk_tiles - BORDER:
							break
						lot_rect = Rect2i(cursor, ry, w, d)
				else:
					# Street runs top-bottom; lots are left (side 0) or right (side 1).
					if side == 0:
						var rx: int = maxi(BORDER, street_start - w)
						lot_rect = Rect2i(rx, cursor, w, d)
					else:
						var rx: int = street_start + street_w + 1
						if rx + w > chunk_tiles - BORDER:
							break
						lot_rect = Rect2i(rx, cursor, w, d)

				if lot_rect.position.x < BORDER or lot_rect.position.y < BORDER:
					cursor += rng.randi_range(table["min_w"], table["max_w"])
					continue
				if not _overlaps_any(lot_rect, lots):
					var facing: int = facing_inner if side == 1 else facing_outer
					lots.append({
						"rect":     lot_rect,
						"facing":   facing,
						"lot_type": _lot_type_for_biome(biome, rng),
						"biome":    biome,
					})
				cursor += w + rng.randi_range(1, 3)

	# ── Dense fill pass for city biomes ─────────────────────────────────────
	if biome in ["city_center", "city"] and lots.size() < max_lots:
		var attempts: int = 30
		while attempts > 0 and lots.size() < max_lots:
			attempts -= 1
			var w: int     = rng.randi_range(table["min_w"], table["max_w"])
			var d: int     = rng.randi_range(table["min_d"], table["max_d"])
			var max_x: int = chunk_tiles - BORDER - w
			var max_y: int = chunk_tiles - BORDER - d
			if max_x < BORDER or max_y < BORDER:
				continue
			var rx: int = rng.randi_range(BORDER, max_x)
			var ry: int = rng.randi_range(BORDER, max_y)
			var candidate := Rect2i(rx, ry, w, d)
			if not _overlaps_any(candidate, lots):
				lots.append({
					"rect":     candidate,
					"facing":   rng.randi_range(0, 3),
					"lot_type": _lot_type_for_biome(biome, rng),
					"biome":    biome,
				})
	return lots


## Returns true if candidate Rect2i overlaps any existing lot (with 1-tile padding).
static func _overlaps_any(candidate: Rect2i, lots: Array) -> bool:
	var padded := candidate.grow(1)
	for lot: Dictionary in lots:
		if padded.intersects(lot["rect"] as Rect2i):
			return true
	return false


## Choose lot_type based on biome.
static func _lot_type_for_biome(biome: String, rng: RandomNumberGenerator) -> String:
	match biome:
		"city_center", "city":
			return ["residential", "commercial"][rng.randi() % 2]
		"suburb":
			return "residential"
		"outskirts":
			return ["industrial", "residential"][rng.randi() % 2]
		_:
			return "isolated"
