# Phase 5 — Lot & House System: Implementation Plan

> Codebase read: constants.gd, chunk_streamer.gd, chunk_base.gd, globals.gd,
> event_bus.gd, world_generator.gd. All decisions below are grounded in what
> was actually read.

---

## Key Discoveries From Codebase

- `world_generator.gd` already has `world_seed: int` and a `chunk_rng()` instance
  method. Phase 5 needs a **static** version on `ChunkStreamer` so chunk scenes can
  call it without importing WorldGenerator.
- `scene/entities/houses/` directory already exists (has `.gdkeep`).
- `chunk_base.gd` exposes an empty `_on_activated()` virtual hook — correct insertion
  point for LotPlanner + HouseBuilder calls.
- `globals.gd` has `var cur_house = null` with comment "typed in Phase 5" — update
  type annotation there.
- `event_bus.gd` already declares `signal day_started(day_number: int)`.
- `world_layout["roads"]` is `Array[Array]` where each inner array is `Array[String]`
  of `"x,y"` chord strings (e.g. `["0,0","1,0","2,0"]`). `get_road_edges()` must
  parse this structure.
- `ChunkStreamer.CHUNK_SIZE = 3200`. With `TILE_SIZE = 32`, that gives 100 tiles per
  side — matching `CHUNK_TILES = 100`.
- `chunk_base.gd` uses `chunk_coord: Vector2i` set before `add_child()` — available
  in `_on_activated()`.

---

## Architecture Decisions

**Decision 1 — LotPlanner and HouseBuilder as static classes, not autoloads.**
They are pure functions with no state and no Node overhead. GDScript `static func`
inside a named class file is the right tool. They get called from `chunk_base.gd`
`_on_activated()` and nowhere else.

**Decision 2 — chunk_rng as a static method on ChunkStreamer, not WorldGenerator.**
ChunkBase needs to call it without coupling to WorldGenerator. ChunkStreamer already
holds `_world_layout` and is the natural owner of chunk-level helpers. The identical
hash formula from WorldGenerator is copied so both produce the same sequence for the
same inputs.

**Decision 3 — Wall collision: StaticBody2D per wall segment, gap at door.**
Each wall segment (the portions on either side of a door gap) becomes one
`StaticBody2D` with a `RectangleShape2D`. The door gap is just the absent segment —
no door Node, just missing wall. Interior walls likewise split at door positions.

**Decision 4 — Floor drawn before walls in z-order.**
Floor ColorRect has `z_index = 0` (default), exterior walls `z_index = 1`, interior
walls `z_index = 1`, roof ColorRect `z_index = 10`. This layers correctly.

**Decision 5 — Roof fade Area2D uses collision layer 1 (player) only.**
`collision_mask = Constants.LAYER_PLAYER` (= `1 << 0` = 1). body_entered/exited
fire only for the player.

**Decision 6 — chunk_base.gd _on_activated() creates a Houses node if absent.**
Not every chunk scene will have a `$Houses` node in its .tscn (they're stubs).
`_on_activated()` creates `Node2D` named "Houses" dynamically if
`get_node_or_null("Houses")` returns null.

**Decision 7 — Globals.cur_house typed as Node2D (not the house.gd class).**
Avoids a circular dependency. Phase 6 will access it as `Node2D` and read metadata.

**Decision 8 — House node is a plain Node2D with house.gd attached, not a scene.**
HouseBuilder creates it in code (`Node2D.new()`), sets the script, configures it, then
adds it to the Houses container. No .tscn file needed for the runtime house node.

---

## Implementation Plan

- [ ] 1. **Add Phase 5 constants to `autoloads/constants.gd`.**
      Append five new const lines after the existing `# ── World ──` block:
      ```
      const TILE_SIZE:      int = 32
      const CHUNK_TILES:    int = 100   # CHUNK_SIZE / TILE_SIZE = 3200/32
      const STREET_WIDTH:   int = 4     # road lane in tiles
      const PAVEMENT_WIDTH: int = 2     # sidewalk in tiles
      const LOT_SETBACK:    int = 2     # gap from lot edge to building front
      ```
      Files: `autoloads/constants.gd`
      Verify: Open Godot editor — project parses with no errors (check Output panel).

- [ ] 2. **Add ChunkStreamer helpers: `world_seed`, `chunk_rng()`, `get_biome()`, `get_road_edges()`.**
      Exact edits to `autoloads/chunk_streamer.gd`:

      a. Add a `var world_seed: int = 0` property near the top (after `_world_layout`).

      b. In `_load_world_layout()`, after `_world_layout = result as Dictionary`, add:
         `world_seed = int(_world_layout.get("seed", 0))`

      c. Add a static helper after `_load_world_layout()`:
         ```gdscript
         ## Deterministic per-chunk RNG. Same inputs always produce the same sequence.
         static func chunk_rng(seed_val: int, coord: Vector2i) -> RandomNumberGenerator:
             var rng := RandomNumberGenerator.new()
             rng.seed = hash(str(seed_val) + "," + str(coord.x) + "," + str(coord.y))
             return rng
         ```
         Note: identical hash formula to WorldGenerator.chunk_rng — intentional.

      d. Add `get_biome()` instance method:
         ```gdscript
         ## Returns biome string for this chunk from world_layout.
         ## Falls back to "wilderness" if the chunk is not in the layout.
         func get_biome(coord: Vector2i) -> String:
             var key := "%d,%d" % [coord.x, coord.y]
             var chunks: Dictionary = _world_layout.get("chunks", {})
             if key in chunks:
                 return (chunks[key] as Dictionary).get("biome", "wilderness")
             return "wilderness"
         ```

      e. Add `get_road_edges()` instance method:
         ```gdscript
         ## Returns which of the 4 edges of this chunk have a road entering.
         ## 0=North (y-1), 1=East (x+1), 2=South (y+1), 3=West (x-1).
         ## Reads world_layout["roads"] which is Array[Array[String]].
         func get_road_edges(coord: Vector2i) -> Array[int]:
             var edges: Array[int] = []
             var roads: Array = _world_layout.get("roads", [])
             var key := "%d,%d" % [coord.x, coord.y]
             # Neighbour offsets indexed by edge number
             var neighbours: Array[Vector2i] = [
                 Vector2i(coord.x, coord.y - 1),  # 0 = North
                 Vector2i(coord.x + 1, coord.y),  # 1 = East
                 Vector2i(coord.x, coord.y + 1),  # 2 = South
                 Vector2i(coord.x - 1, coord.y),  # 3 = West
             ]
             for road_path: Array in roads:
                 # A road enters edge N if this chunk and its northern neighbour
                 # are both in the same road path (adjacent entries or any entries).
                 var path_set: Dictionary = {}
                 for s: String in road_path:
                     path_set[s] = true
                 if key not in path_set:
                     continue
                 for edge_idx: int in range(4):
                     var nb_key := "%d,%d" % [neighbours[edge_idx].x, neighbours[edge_idx].y]
                     if nb_key in path_set and edge_idx not in edges:
                         edges.append(edge_idx)
             return edges
         ```
         Edge case: if `_world_layout` is empty (no world_layout.json), returns `[]`
         — LotPlanner handles empty road_edges by placing isolated/wilderness lots.

      Files: `autoloads/chunk_streamer.gd`
      Verify: Open Godot editor — project parses with no errors.

- [ ] 3. **Create `scene/maps/lot_planner.gd` — static lot generation.**
      Full file content:
      ```gdscript
      class_name LotPlanner

      ## Lot size tables by biome [min_w, max_w, min_d, max_d, max_lots, pattern].
      ## All values in tiles.
      const LOT_TABLE: Dictionary = {
          "city_center": {"min_w": 6,  "max_w": 10, "min_d": 8,  "max_d": 12, "max_lots": 20, "pattern": "dense"},
          "city":        {"min_w": 8,  "max_w": 12, "min_d": 10, "max_d": 16, "max_lots": 14, "pattern": "street"},
          "suburb":      {"min_w": 10, "max_w": 18, "min_d": 14, "max_d": 22, "max_lots": 8,  "pattern": "street"},
          "outskirts":   {"min_w": 16, "max_w": 30, "min_d": 20, "max_d": 40, "max_lots": 4,  "pattern": "sparse"},
          "wilderness":  {"min_w": 12, "max_w": 20, "min_d": 16, "max_d": 24, "max_lots": 2,  "pattern": "isolated"},
      }

      ## Returns Array of lot dicts. Each dict:
      ##   { "rect": Rect2i (tile coords, chunk-local),
      ##     "facing": int (0=N,1=E,2=S,3=W — street side),
      ##     "lot_type": String,
      ##     "biome": String }
      ## coord is the chunk's grid coordinate (used only to look up table; not for positions).
      ## road_edges is Array[int] from ChunkStreamer.get_road_edges().
      ## rng is already seeded for this chunk.
      static func generate_lots(
              coord: Vector2i,
              biome: String,
              road_edges: Array,
              rng: RandomNumberGenerator) -> Array:
          @warning_ignore("unused_parameter")
          var _coord := coord  # kept for possible future use
          var table: Dictionary = LOT_TABLE.get(biome, LOT_TABLE["wilderness"])
          var max_lots: int = table["max_lots"]
          var lots: Array = []
          var chunk_tiles: int = Constants.CHUNK_TILES   # 100
          var street_w: int = Constants.STREET_WIDTH     # 4
          var pave_w:   int = Constants.PAVEMENT_WIDTH   # 2

          # Edge pixels we must avoid: use 1-tile margin so lots don't touch chunk border.
          const BORDER: int = 1

          if road_edges.is_empty() or biome in ["wilderness", "outskirts"]:
              # Isolated lots: scatter 0–max_lots randomly with no street constraint.
              var count: int = rng.randi_range(0, max_lots)
              for _i in range(count):
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
                          "rect": candidate,
                          "facing": rng.randi_range(0, 3),
                          "lot_type": "isolated",
                          "biome": biome,
                      })
              return lots

          # Street-based placement: for each road edge, place a street then lots on both sides.
          for edge: int in road_edges:
              if lots.size() >= max_lots:
                  break
              # Street runs along the edge (2 tiles inset from that edge).
              # "street_axis": 0 = horizontal street (N or S edge),
              #               1 = vertical street (E or W edge).
              var is_horizontal: bool = (edge == 0 or edge == 2)  # N or S
              # Street band position (in tiles, chunk-local):
              var street_start: int  # tile offset from the near edge
              var facing_inner: int  # direction from lot toward street
              var facing_outer: int  # direction from lot away from street
              match edge:
                  0:  # North edge → street at y = pave_w + 1
                      street_start  = pave_w + 1
                      facing_inner  = 2   # lots south of street face north (toward it)
                      facing_outer  = 0
                  1:  # East edge → street at x = chunk_tiles - (pave_w + 1 + street_w)
                      street_start  = chunk_tiles - pave_w - 1 - street_w
                      facing_inner  = 3   # lots west of street face east
                      facing_outer  = 1
                  2:  # South edge → street at y = chunk_tiles - (pave_w + 1 + street_w)
                      street_start  = chunk_tiles - pave_w - 1 - street_w
                      facing_inner  = 0   # lots north of street face south
                      facing_outer  = 2
                  _:  # West edge (3)
                      street_start  = pave_w + 1
                      facing_inner  = 1   # lots east of street face west
                      facing_outer  = 3

              # Place lots on BOTH sides of the street along the full chunk width.
              # Side A: between chunk edge and street. Side B: between street and interior.
              for side in [0, 1]:
                  if lots.size() >= max_lots:
                      break
                  var cursor: int = BORDER
                  var end_pos: int = chunk_tiles - BORDER
                  while cursor < end_pos and lots.size() < max_lots:
                      var w: int = rng.randi_range(table["min_w"], table["max_w"])
                      var d: int = rng.randi_range(table["min_d"], table["max_d"])
                      if cursor + w > end_pos:
                          break
                      # Determine position based on side and edge orientation.
                      var lot_rect: Rect2i
                      if is_horizontal:
                          # Street runs left-right. Side A = above street, side B = below.
                          if side == 0:
                              # Above the street: lot bottom aligns with street_start - 1
                              var ry: int = max(BORDER, street_start - d)
                              lot_rect = Rect2i(cursor, ry, w, d)
                          else:
                              # Below the street: lot top = street_start + street_w + 1
                              var ry: int = street_start + street_w + 1
                              if ry + d > chunk_tiles - BORDER:
                                  break
                              lot_rect = Rect2i(cursor, ry, w, d)
                      else:
                          # Street runs top-bottom. Side A = left, side B = right.
                          if side == 0:
                              var rx: int = max(BORDER, street_start - w)
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
                              "rect": lot_rect,
                              "facing": facing,
                              "lot_type": _lot_type_for_biome(biome, rng),
                              "biome": biome,
                          })
                      cursor += w + rng.randi_range(1, 3)  # small gap between lots

          # If street lots didn't fill quota and biome is dense, add cluster interior lots.
          if biome in ["city_center", "city"] and lots.size() < max_lots:
              var attempts: int = 30
              while attempts > 0 and lots.size() < max_lots:
                  attempts -= 1
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
                          "rect": candidate,
                          "facing": rng.randi_range(0, 3),
                          "lot_type": _lot_type_for_biome(biome, rng),
                          "biome": biome,
                      })
          return lots

      ## Returns true if candidate Rect2i overlaps any existing lot.
      ## Uses a 1-tile padding between lots.
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
      ```
      Files: `scene/maps/lot_planner.gd` (new file)
      Verify: Open Godot editor — project parses, LotPlanner class appears in class
      autocomplete with no errors.

- [ ] 4. **Create `scene/entities/houses/house.gd` — runtime house Node2D.**
      This script is applied to the Node2D created by HouseBuilder. Full content:
      ```gdscript
      class_name House extends Node2D
      ## Runtime house node created by HouseBuilder.
      ## Manages roof fade, cur_house tracking, and daily spawn stubs.

      ## Maximum enemies that can be active inside this house.
      var capacity: int = 3

      ## The last day enemies/loot were spawned. -1 = never.
      var spawn_day: int = -1

      # ── Internal refs (set by HouseBuilder after build) ──────────────────────
      var _roof: ColorRect = null   ## The roof ColorRect node
      var _roof_tween: Tween = null ## Active tween (cancel before starting a new one)

      func _ready() -> void:
          # VisibleOnScreenNotifier2D connects/disconnects day_started to save resources.
          var notifier := $VisibleOnScreenNotifier2D
          notifier.screen_entered.connect(_on_screen_entered)
          notifier.screen_exited.connect(_on_screen_exited)

      func _on_screen_entered() -> void:
          EventBus.day_started.connect(_on_day_started)

      func _on_screen_exited() -> void:
          if EventBus.day_started.is_connected(_on_day_started):
              EventBus.day_started.disconnect(_on_day_started)

      func _on_day_started(day_number: int) -> void:
          if spawn_day == day_number:
              return   # already spawned today
          spawn_day = day_number
          spawn_enemies()
          spawn_loot()

      ## Stub — Phase 6 will implement actual enemy spawning.
      func spawn_enemies() -> void:
          var spawns: Array = get_meta("enemy_spawns", []) as Array
          print("[House] spawn_enemies: %d anchors at day %d" % [spawns.size(), spawn_day])

      ## Stub — Phase 8 will implement actual loot spawning.
      func spawn_loot() -> void:
          var spawns: Array = get_meta("loot_spawns", []) as Array
          print("[House] spawn_loot: %d anchors at day %d" % [spawns.size(), spawn_day])

      # ── Roof fade (called from HouseBuilder after roof is set up) ────────────
      func set_roof(roof_node: ColorRect) -> void:
          _roof = roof_node

      func fade_roof_out() -> void:
          if not is_instance_valid(_roof):
              return
          if is_instance_valid(_roof_tween):
              _roof_tween.kill()
          _roof_tween = create_tween()
          _roof_tween.tween_property(_roof, "modulate:a", 0.0, 0.3)

      func fade_roof_in() -> void:
          if not is_instance_valid(_roof):
              return
          if is_instance_valid(_roof_tween):
              _roof_tween.kill()
          _roof_tween = create_tween()
          _roof_tween.tween_property(_roof, "modulate:a", 1.0, 0.3)
      ```
      Files: `scene/entities/houses/house.gd` (new file)
      Verify: Open Godot editor — project parses with no errors.

- [ ] 5. **Create `scene/maps/house_builder.gd` — static house construction.**
      This is the largest new file. Full implementation:

      ```gdscript
      class_name HouseBuilder

      ## Minimum building dimensions (tiles). Lots smaller than this get skipped.
      const MIN_BUILD_TILES:  int = 4
      ## BSP: don't split a room that is this wide/tall or smaller (tiles).
      const MAX_ROOM_TILES:   int = 6
      ## BSP: don't create a room smaller than this in either dimension (tiles).
      const MIN_ROOM_TILES:   int = 3
      ## Door width in pixels (1.5 tiles × 32 = 48 px).
      const DOOR_WIDTH_PX:    int = 48

      ## Build a house on `lot` and add it as child of `parent`.
      ## Returns the House Node2D, or null if the lot is too small.
      ## `lot` keys: rect (Rect2i tile coords), facing (int), lot_type, biome.
      ## All pixel positions are chunk-local (0,0 = chunk top-left).
      static func build_house(lot: Dictionary, parent: Node, rng: RandomNumberGenerator) -> Node2D:
          var ts: int = Constants.TILE_SIZE        # 32
          var setback: int = Constants.LOT_SETBACK # 2
          var lot_rect: Rect2i = lot["rect"]
          var facing: int = lot["facing"]          # 0=N,1=E,2=S,3=W

          # ── Step 1: Footprint ─────────────────────────────────────────────────
          # Shrink lot_rect to get building footprint:
          #   front (street side): setback + 1 pavement tile = 3 tiles
          #   sides and back: 1 tile each
          var front_shrink: int = setback + 1   # 3 tiles
          var side_shrink:  int = 1
          var build_rect: Rect2i = lot_rect

          match facing:
              0:  # front = north (top)
                  build_rect = Rect2i(
                      lot_rect.position.x + side_shrink,
                      lot_rect.position.y + front_shrink,
                      lot_rect.size.x - side_shrink * 2,
                      lot_rect.size.y - front_shrink - side_shrink)
              1:  # front = east (right)
                  build_rect = Rect2i(
                      lot_rect.position.x + side_shrink,
                      lot_rect.position.y + side_shrink,
                      lot_rect.size.x - front_shrink - side_shrink,
                      lot_rect.size.y - side_shrink * 2)
              2:  # front = south (bottom)
                  build_rect = Rect2i(
                      lot_rect.position.x + side_shrink,
                      lot_rect.position.y + side_shrink,
                      lot_rect.size.x - side_shrink * 2,
                      lot_rect.size.y - side_shrink - front_shrink)
              _:  # front = west (left, facing=3)
                  build_rect = Rect2i(
                      lot_rect.position.x + front_shrink,
                      lot_rect.position.y + side_shrink,
                      lot_rect.size.x - front_shrink - side_shrink,
                      lot_rect.size.y - side_shrink * 2)

          if build_rect.size.x < MIN_BUILD_TILES or build_rect.size.y < MIN_BUILD_TILES:
              return null   # lot too small for a house

          # ── House Node2D ──────────────────────────────────────────────────────
          var house := Node2D.new()
          house.set_script(load("res://scene/entities/houses/house.gd"))
          house.name = "House"
          parent.add_child(house)

          # ── Step 2: Floor ─────────────────────────────────────────────────────
          var floor_rect := ColorRect.new()
          floor_rect.color    = Color(0.55, 0.52, 0.48)
          floor_rect.position = Vector2(build_rect.position.x * ts, build_rect.position.y * ts)
          floor_rect.size     = Vector2(build_rect.size.x * ts, build_rect.size.y * ts)
          floor_rect.z_index  = 0
          house.add_child(floor_rect)

          # ── Step 3: BSP room division ─────────────────────────────────────────
          var rooms: Array = []
          var splits: Array = []   # Array of {axis, px} split lines for interior walls
          _bsp_split(build_rect, rng, rooms, splits)

          # ── Step 4: Spawn anchors ─────────────────────────────────────────────
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
                  loot_spawns.append(center_px + Vector2(rng.randf_range(-16, 16), rng.randf_range(-16, 16)))
              if rng.randf() < 0.3:
                  enemy_spawns.append(center_px)

          house.set_meta("furniture_anchors", furniture_anchors)
          house.set_meta("loot_spawns", loot_spawns)
          house.set_meta("enemy_spawns", enemy_spawns)
          house.capacity = maxi(1, enemy_spawns.size())

          # ── Step 5: Exterior walls ────────────────────────────────────────────
          # Front door: centred ± small rng offset, 48 px wide.
          var front_door_offset: int = rng.randi_range(-ts, ts)
          var back_door: bool = rng.randf() < 0.5

          _build_exterior_walls(house, build_rect, facing, front_door_offset, back_door, ts)

          # ── Step 6: Interior walls (from BSP splits) ─────────────────────────
          for split: Dictionary in splits:
              _build_interior_wall(house, build_rect, split, rng, ts)

          # ── Step 7: Roof + fade Area2D ────────────────────────────────────────
          var roof := ColorRect.new()
          roof.color    = Color(0.22, 0.20, 0.18)
          roof.position = Vector2(build_rect.position.x * ts, build_rect.position.y * ts)
          roof.size     = Vector2(build_rect.size.x * ts, build_rect.size.y * ts)
          roof.z_index  = 10
          house.add_child(roof)
          (house as House).set_roof(roof)

          # Roof trigger Area2D (player layer only), slightly inset.
          var trigger := Area2D.new()
          trigger.collision_layer = 0
          trigger.collision_mask  = Constants.LAYER_PLAYER
          trigger.name            = "RoofTrigger"
          var trigger_shape := CollisionShape2D.new()
          var rect_shape := RectangleShape2D.new()
          var inset: float = 4.0
          rect_shape.size = Vector2(
              build_rect.size.x * ts - inset * 2,
              build_rect.size.y * ts - inset * 2)
          trigger_shape.shape    = rect_shape
          trigger_shape.position = Vector2(
              build_rect.position.x * ts + build_rect.size.x * ts * 0.5,
              build_rect.position.y * ts + build_rect.size.y * ts * 0.5)
          trigger.add_child(trigger_shape)
          house.add_child(trigger)
          trigger.body_entered.connect(func(_body: Node2D): (house as House).fade_roof_out())
          trigger.body_exited.connect(func(_body: Node2D): (house as House).fade_roof_in())

          # ── Step 8: cur_house sensor Area2D ──────────────────────────────────
          var sensor := Area2D.new()
          sensor.collision_layer = 0
          sensor.collision_mask  = Constants.LAYER_PLAYER
          sensor.name            = "HouseSensor"
          var sensor_shape := CollisionShape2D.new()
          var sensor_rect := RectangleShape2D.new()
          sensor_rect.size = Vector2(build_rect.size.x * ts, build_rect.size.y * ts)
          sensor_shape.shape    = sensor_rect
          sensor_shape.position = Vector2(
              build_rect.position.x * ts + build_rect.size.x * ts * 0.5,
              build_rect.position.y * ts + build_rect.size.y * ts * 0.5)
          sensor.add_child(sensor_shape)
          house.add_child(sensor)
          sensor.body_entered.connect(func(_body: Node2D): Globals.cur_house = house)
          sensor.body_exited.connect(func(_body: Node2D):
              if Globals.cur_house == house:
                  Globals.cur_house = null)

          # ── Step 9: VisibleOnScreenNotifier2D ─────────────────────────────────
          var notifier := VisibleOnScreenNotifier2D.new()
          notifier.rect = Rect2(
              Vector2(build_rect.position.x * ts, build_rect.position.y * ts),
              Vector2(build_rect.size.x * ts, build_rect.size.y * ts))
          notifier.name = "VisibleOnScreenNotifier2D"
          house.add_child(notifier)

          return house

      # ── BSP helpers ──────────────────────────────────────────────────────────

      ## Recursive BSP. Appends leaf rooms to `rooms`, split lines to `splits`.
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

          # Choose split axis: prefer the longer dimension; randomize when equal.
          var split_horizontal: bool
          if can_split_h and can_split_v:
              split_horizontal = rng.randf() < 0.5
          elif can_split_h:
              split_horizontal = true
          else:
              split_horizontal = false

          if split_horizontal:
              # Split y. Room A: rect.y to split_y. Room B: split_y to rect.y+rect.h.
              var min_split: int = rect.position.y + MIN_ROOM_TILES
              var max_split: int = rect.position.y + rect.size.y - MIN_ROOM_TILES
              if min_split > max_split:
                  rooms.append(rect)
                  return
              var split_y: int = rng.randi_range(min_split, max_split)
              splits.append({"axis": "h", "px": split_y, "start": rect.position.x, "length": rect.size.x})
              _bsp_split(Rect2i(rect.position.x, rect.position.y, rect.size.x, split_y - rect.position.y), rng, rooms, splits)
              _bsp_split(Rect2i(rect.position.x, split_y, rect.size.x, rect.position.y + rect.size.y - split_y), rng, rooms, splits)
          else:
              var min_split: int = rect.position.x + MIN_ROOM_TILES
              var max_split: int = rect.position.x + rect.size.x - MIN_ROOM_TILES
              if min_split > max_split:
                  rooms.append(rect)
                  return
              var split_x: int = rng.randi_range(min_split, max_split)
              splits.append({"axis": "v", "px": split_x, "start": rect.position.y, "length": rect.size.y})
              _bsp_split(Rect2i(rect.position.x, rect.position.y, split_x - rect.position.x, rect.size.y), rng, rooms, splits)
              _bsp_split(Rect2i(split_x, rect.position.y, rect.position.x + rect.size.x - split_x, rect.size.y), rng, rooms, splits)

      # ── Wall builders ─────────────────────────────────────────────────────────

      ## Build the 4 exterior walls with door gaps.
      ## facing: which wall has the front door (0=N top, 1=E right, 2=S bottom, 3=W left).
      ## front_door_offset: pixel offset from centre to shift door position (clamped).
      ## back_door: add a door on the opposite wall if true.
      static func _build_exterior_walls(
              house: Node2D,
              build_rect: Rect2i,
              facing: int,
              front_door_offset: int,
              back_door: bool,
              ts: int) -> void:
          var px := build_rect.position.x * ts
          var py := build_rect.position.y * ts
          var pw := build_rect.size.x * ts
          var ph := build_rect.size.y * ts
          const WALL_T: int = 4   # wall thickness in pixels

          # ── Top wall (North) ──────────────────────────────────────────────────
          if facing == 0:
              _wall_with_door(house, Rect2(px, py, pw, WALL_T),
                  true, front_door_offset)
          elif back_door and facing == 2:
              _wall_with_door(house, Rect2(px, py, pw, WALL_T),
                  true, 0)
          else:
              _solid_wall(house, Rect2(px, py, pw, WALL_T))

          # ── Bottom wall (South) ───────────────────────────────────────────────
          if facing == 2:
              _wall_with_door(house, Rect2(px, py + ph - WALL_T, pw, WALL_T),
                  true, front_door_offset)
          elif back_door and facing == 0:
              _wall_with_door(house, Rect2(px, py + ph - WALL_T, pw, WALL_T),
                  true, 0)
          else:
              _solid_wall(house, Rect2(px, py + ph - WALL_T, pw, WALL_T))

          # ── Left wall (West) ──────────────────────────────────────────────────
          if facing == 3:
              _wall_with_door(house, Rect2(px, py, WALL_T, ph),
                  false, front_door_offset)
          elif back_door and facing == 1:
              _wall_with_door(house, Rect2(px, py, WALL_T, ph),
                  false, 0)
          else:
              _solid_wall(house, Rect2(px, py, WALL_T, ph))

          # ── Right wall (East) ─────────────────────────────────────────────────
          if facing == 1:
              _wall_with_door(house, Rect2(px + pw - WALL_T, py, WALL_T, ph),
                  false, front_door_offset)
          elif back_door and facing == 3:
              _wall_with_door(house, Rect2(px + pw - WALL_T, py, WALL_T, ph),
                  false, 0)
          else:
              _solid_wall(house, Rect2(px + pw - WALL_T, py, WALL_T, ph))

      ## Build an interior wall (from a BSP split line) with one centred door gap.
      static func _build_interior_wall(
              house: Node2D,
              _build_rect: Rect2i,
              split: Dictionary,
              rng: RandomNumberGenerator,
              ts: int) -> void:
          var axis: String = split["axis"]
          var split_tile: int = split["px"]
          var start_tile: int = split["start"]
          var length_tile: int = split["length"]
          var split_px: int  = split_tile * ts
          var start_px: int  = start_tile * ts
          var length_px: int = length_tile * ts
          const WALL_T: int = 4
          # Place door at a random position along the wall.
          var door_offset: int = rng.randi_range(
              int(length_px * 0.2), int(length_px * 0.8))
          if axis == "h":
              _wall_with_door(house, Rect2(start_px, split_px, length_px, WALL_T),
                  true, door_offset - length_px / 2, true)
          else:
              _wall_with_door(house, Rect2(split_px, start_px, WALL_T, length_px),
                  false, door_offset - length_px / 2, true)

      ## Add a StaticBody2D + ColorRect for a solid (no door) wall.
      static func _solid_wall(house: Node2D, rect: Rect2) -> void:
          var body := StaticBody2D.new()
          body.collision_layer = Constants.LAYER_WALL
          body.collision_mask  = 0
          var shape := CollisionShape2D.new()
          var rs := RectangleShape2D.new()
          rs.size = rect.size
          shape.position = rect.position + rect.size * 0.5
          shape.shape = rs
          body.add_child(shape)
          house.add_child(body)

          var cr := ColorRect.new()
          cr.color    = Color(0.30, 0.28, 0.25)
          cr.position = rect.position
          cr.size     = rect.size
          cr.z_index  = 1
          house.add_child(cr)

      ## Add two wall segments with a door gap in the middle.
      ## `horizontal`: true = wall runs left-right (split on x), door gap cuts y-span.
      ##               false = wall runs top-bottom (door gap cuts x-span).
      ## `door_offset`: pixels from wall centre to shift the door (clamped to keep segments ≥ 4px).
      ## `is_interior`: use interior wall colour if true.
      static func _wall_with_door(
              house: Node2D,
              wall_rect: Rect2,
              horizontal: bool,
              door_offset: int,
              is_interior: bool = false) -> void:
          var color := Color(0.40, 0.38, 0.35) if is_interior else Color(0.30, 0.28, 0.25)
          const WALL_T: int = 4
          var door_w: float = HouseBuilder.DOOR_WIDTH_PX

          if horizontal:
              # Wall rect spans left-right. Door gap is a horizontal cut.
              var wall_len: float = wall_rect.size.x
              var centre: float   = wall_rect.position.x + wall_len * 0.5 + door_offset
              var door_left: float  = clampf(centre - door_w * 0.5,
                  wall_rect.position.x + 4.0, wall_rect.position.x + wall_len - door_w - 4.0)
              var door_right: float = door_left + door_w

              # Left segment
              var left_w: float = door_left - wall_rect.position.x
              if left_w > 0.0:
                  var seg := Rect2(wall_rect.position.x, wall_rect.position.y, left_w, wall_rect.size.y)
                  _wall_segment(house, seg, color)

              # Right segment
              var right_w: float = wall_rect.position.x + wall_len - door_right
              if right_w > 0.0:
                  var seg := Rect2(door_right, wall_rect.position.y, right_w, wall_rect.size.y)
                  _wall_segment(house, seg, color)
          else:
              # Wall runs top-bottom. Door gap cuts vertically.
              var wall_len: float = wall_rect.size.y
              var centre: float   = wall_rect.position.y + wall_len * 0.5 + door_offset
              var door_top: float    = clampf(centre - door_w * 0.5,
                  wall_rect.position.y + 4.0, wall_rect.position.y + wall_len - door_w - 4.0)
              var door_bottom: float = door_top + door_w

              var top_h: float = door_top - wall_rect.position.y
              if top_h > 0.0:
                  var seg := Rect2(wall_rect.position.x, wall_rect.position.y, wall_rect.size.x, top_h)
                  _wall_segment(house, seg, color)

              var bot_h: float = wall_rect.position.y + wall_len - door_bottom
              if bot_h > 0.0:
                  var seg := Rect2(wall_rect.position.x, door_bottom, wall_rect.size.x, bot_h)
                  _wall_segment(house, seg, color)

      ## Add one wall segment: StaticBody2D collision + ColorRect visual.
      static func _wall_segment(house: Node2D, rect: Rect2, color: Color) -> void:
          var body := StaticBody2D.new()
          body.collision_layer = Constants.LAYER_WALL
          body.collision_mask  = 0
          var shape := CollisionShape2D.new()
          var rs := RectangleShape2D.new()
          rs.size = rect.size
          shape.position = rect.position + rect.size * 0.5
          shape.shape = rs
          body.add_child(shape)
          house.add_child(body)

          var cr := ColorRect.new()
          cr.color    = color
          cr.position = rect.position
          cr.size     = rect.size
          cr.z_index  = 1
          house.add_child(cr)
      ```
      Edge cases:
      - If `build_rect < MIN_BUILD_TILES`: `build_house()` returns `null` early.
      - If BSP `min_split > max_split` (room can't be split further): leaf appended directly.
      - If door_left clamp forces segments to 0 width (very narrow wall): `if left_w > 0.0`
        guard skips the degenerate segment.
      - Interior door offset clamped to `[20%, 80%]` of wall length to avoid door at corners.

      Files: `scene/maps/house_builder.gd` (new file)
      Verify: Open Godot editor — project parses with no errors.

- [ ] 6. **Update `scene/maps/chunk_base.gd` `_on_activated()` to call LotPlanner + HouseBuilder.**
      Replace the empty `func _on_activated() -> void:\n\tpass` body with:
      ```gdscript
      func _on_activated() -> void:
          # Phase 5: Procedural lot and house generation.
          var rng: RandomNumberGenerator = ChunkStreamer.chunk_rng(
              ChunkStreamer.world_seed, chunk_coord)
          var biome: String = ChunkStreamer.get_biome(chunk_coord)
          var road_edges: Array = ChunkStreamer.get_road_edges(chunk_coord)
          var lots: Array = LotPlanner.generate_lots(chunk_coord, biome, road_edges, rng)

          # Ensure Houses container node exists.
          var houses_node: Node2D = get_node_or_null("Houses") as Node2D
          if houses_node == null:
              houses_node = Node2D.new()
              houses_node.name = "Houses"
              add_child(houses_node)

          for lot: Dictionary in lots:
              HouseBuilder.build_house(lot, houses_node, rng)
      ```
      Notes:
      - `ChunkStreamer.chunk_rng()` is now a static method — called on the class directly.
        But since ChunkStreamer is an autoload/singleton, calling
        `ChunkStreamer.chunk_rng(...)` also works (GDScript allows both for static methods).
      - `ChunkStreamer.world_seed` will be 0 if `world_layout.json` hasn't been loaded yet
        (e.g. first-run before WorldGenerator completes). This is acceptable: a seed of 0
        still produces deterministic results, just the same for all chunks until the real
        seed loads. In practice `_on_activated()` only fires after the streamer is active,
        which is after `world_layout.json` is loaded.

      Files: `scene/maps/chunk_base.gd`
      Verify: Open Godot editor — project parses with no errors.

- [ ] 7. **Update `autoloads/globals.gd` — type `cur_house` as `Node2D`.**
      Change:
      ```gdscript
      var cur_house           = null   # typed in Phase 5
      ```
      To:
      ```gdscript
      var cur_house: Node2D   = null   ## Current house the player is inside (set by HouseBuilder sensor)
      ```
      Files: `autoloads/globals.gd`
      Verify: Open Godot editor — no parse errors.

- [ ] 8. **Update `masterplan.md` Phase 5 checklist — mark completed items.**
      Mark every Phase 5 checklist item `⬜` → `✅`:
      - Constants items (TILE_SIZE, CHUNK_TILES, STREET_WIDTH, PAVEMENT_WIDTH, LOT_SETBACK)
      - ChunkStreamer additions (get_road_edges, get_biome, world_seed, chunk_rng)
      - LotPlanner items (all 6)
      - HouseBuilder items (all 7)
      - House runtime node item
      - ChunkBase integration item
      Leave the Verify items marked `⬜` (they require runtime testing).
      Files: `masterplan.md`
      Verify: Read the file — all implementation checklist items show ✅.

---

## Edge Cases and Decisions Summary

| Situation | Handling |
|-----------|----------|
| `world_layout.json` missing (`world_seed = 0`) | Seed 0 is valid; lots generate deterministically but identically for all chunks. Acceptable during early game before generator runs. |
| Lot too small for a house after setback | `build_house()` returns `null`, lot is silently skipped (open space / garden). |
| BSP can't split (room at min size already) | Leaf appended directly without splitting. No infinite recursion. |
| Door clamp forces 0-width wall segment | `if left_w > 0.0` / `if right_w > 0.0` guards prevent degenerate StaticBody2D. |
| Wilderness/outskirts chunk with no roads | `road_edges` is empty → isolated lot path; 0–2 randomly placed lots. |
| `$Houses` node missing from chunk .tscn | Created dynamically in `_on_activated()` via `get_node_or_null("Houses")`. |
| Two Area2D (RoofTrigger + HouseSensor) both use LAYER_PLAYER mask | They serve different purposes; both fire for the player but set different state. This is intentional. |
| Interior wall door offset calculation | Clamped to [20%, 80%] of wall length in `_build_interior_wall()` to prevent door at wall corners. |
| `rng` reused across all lots in a chunk | The same `rng` instance is passed to both `LotPlanner.generate_lots()` and each `HouseBuilder.build_house()` call, advancing the sequence. This is deterministic: same seed = same sequence = same houses. |
