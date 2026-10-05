# Phase 4 Implementation Plan — Map & World (Infinite Chunk Streaming + Procedural World Generation)

## Context (from codebase exploration)

- **Project root:** `c:\Users\ADMIN\Documents\workspace\games\I-Will-Survive-zombie-apocalype-\I-Will-Survive-v2`
- **All code paths below are relative to project root unless stated otherwise.**
- **Existing autoloads registered:** Constants, Globals, Utils, Factory, Serialize, Pathfinder, EventBus — in that order.
- **EventBus already has** `chunk_loaded`/`chunk_unloaded` signals; Phase 4 adds `chunk_activated`/`chunk_deactivated`/`poi_discovered`.
- **`scene/maps/`** already has empty subdirs: `chunks/`, `previews/`, `zone/` (each with `.gdkeep`). No `.gd` or `.tscn` files exist there yet.
- **`loading_state.gd`** has an auto-dismiss stub (`AUTO_DISMISS = 0.5s`) with a comment saying Phase 4 replaces it with ChunkStreamer signal.
- **`game_state.gd`** calls `Pathfinder.enable()/disable()` in `_enter_tree`/`_exit_tree`. Phase 4 adds ChunkStreamer activation and WorldGenerator call here.
- **Godot 4 scene format:** `.tscn` files use `[gd_scene]` header, resource UIDs, and the text scene format shown below in item 4.
- **No testing framework exists** — verification is done by opening the Godot editor (no parse errors) and running the game.

---

## Ordered Implementation Plan

- [ ] 1. **Add new EventBus signals for Phase 4**
      The existing `event_bus.gd` has `chunk_loaded`/`chunk_unloaded` (old names). Phase 4 code will emit `chunk_activated`/`chunk_deactivated` (the names used in `loading_state.gd` and the masterplan). Also add `poi_discovered`.
      Files to modify: `autoloads/event_bus.gd`
      Changes:
      - Add after the existing chunk signals:
        ```gdscript
        @warning_ignore("unused_signal") signal chunk_activated(coord: Vector2i)
        @warning_ignore("unused_signal") signal chunk_deactivated(coord: Vector2i)
        @warning_ignore("unused_signal") signal poi_discovered(poi_id: String, coord: Vector2i)
        ```
      Verify: Open project in Godot editor — no parse errors in event_bus.gd.

- [ ] 2. **Create `data/poi_registry.json`**
      Defines all POI types the world generator will place. Follows the schema from masterplan exactly. The `suburb_residential` POI references `poi_suburb_residential.tscn` (masterplan uses `poi_suburb.tscn` in one place but lists `poi_suburb_residential.tscn` in the chunk file list — use `poi_suburb_residential.tscn` as the canonical filename).
      Files to create: `data/poi_registry.json`
      Content (all 8 POI types, 19 total placements):
      ```json
      {
        "pois": [
          {
            "id": "police_station",
            "scene": "res://scene/maps/chunks/poi_police_station.tscn",
            "biome": "city",
            "min_distance_from_origin": 1,
            "max_distance_from_origin": 3,
            "min_distance_from_other_pois": 2,
            "guaranteed": true,
            "count": 1,
            "loot_tier": "high",
            "enemy_density": "high",
            "tags": ["weapons", "ammo", "police_gear"]
          },
          {
            "id": "hospital",
            "scene": "res://scene/maps/chunks/poi_hospital.tscn",
            "biome": "city",
            "min_distance_from_origin": 1,
            "max_distance_from_origin": 3,
            "min_distance_from_other_pois": 2,
            "guaranteed": true,
            "count": 1,
            "loot_tier": "high",
            "enemy_density": "medium",
            "tags": ["medical", "food"]
          },
          {
            "id": "school",
            "scene": "res://scene/maps/chunks/poi_school.tscn",
            "biome": "suburb",
            "min_distance_from_origin": 2,
            "max_distance_from_origin": 4,
            "min_distance_from_other_pois": 1,
            "guaranteed": true,
            "count": 2,
            "loot_tier": "medium",
            "enemy_density": "high",
            "tags": ["food", "tools", "books"]
          },
          {
            "id": "airport",
            "scene": "res://scene/maps/chunks/poi_airport.tscn",
            "biome": "outskirts",
            "min_distance_from_origin": 3,
            "max_distance_from_origin": 5,
            "min_distance_from_other_pois": 3,
            "guaranteed": true,
            "count": 1,
            "loot_tier": "very_high",
            "enemy_density": "very_high",
            "tags": ["vehicles", "fuel", "military", "rare_weapons"]
          },
          {
            "id": "military_base",
            "scene": "res://scene/maps/chunks/poi_military_base.tscn",
            "biome": "outskirts",
            "min_distance_from_origin": 3,
            "max_distance_from_origin": 5,
            "min_distance_from_other_pois": 3,
            "guaranteed": true,
            "count": 1,
            "loot_tier": "very_high",
            "enemy_density": "very_high",
            "tags": ["military_gear", "vehicles", "rare_weapons"]
          },
          {
            "id": "shopping_mall",
            "scene": "res://scene/maps/chunks/poi_mall.tscn",
            "biome": "suburb",
            "min_distance_from_origin": 2,
            "max_distance_from_origin": 4,
            "min_distance_from_other_pois": 2,
            "guaranteed": true,
            "count": 1,
            "loot_tier": "high",
            "enemy_density": "very_high",
            "tags": ["food", "clothing", "tools", "electronics"]
          },
          {
            "id": "gas_station",
            "scene": "res://scene/maps/chunks/poi_gas_station.tscn",
            "biome": "any",
            "min_distance_from_origin": 1,
            "max_distance_from_origin": 4,
            "min_distance_from_other_pois": 1,
            "guaranteed": true,
            "count": 3,
            "loot_tier": "medium",
            "enemy_density": "low",
            "tags": ["fuel", "food", "tools"]
          },
          {
            "id": "suburb_residential",
            "scene": "res://scene/maps/chunks/poi_suburb_residential.tscn",
            "biome": "suburb",
            "min_distance_from_origin": 1,
            "max_distance_from_origin": 4,
            "min_distance_from_other_pois": 0,
            "guaranteed": false,
            "count": 8,
            "loot_tier": "low",
            "enemy_density": "medium",
            "tags": ["food", "tools", "clothing"]
          }
        ]
      }
      ```
      Verify: `JSON.parse_string(FileAccess.get_file_as_string("res://data/poi_registry.json"))` returns non-null in Godot (run a one-line test via the editor Output). No parse errors on project open.

- [ ] 3. **Create `data/biome_rules.json`**
      Specifies the ring radii for each biome and the jitter strength for organic-feeling biome edges.
      Files to create: `data/biome_rules.json`
      ```json
      {
        "city_center": 0,
        "city": [1, 2],
        "suburb": [2, 3],
        "outskirts": [3, 4],
        "wilderness": 5,
        "jitter_strength": 0.25
      }
      ```
      Verify: File opens without JSON errors.

- [ ] 4. **Create `scene/maps/chunk_base.gd`**
      Base script for all chunk scenes. Defines the chunk contract: coordinate, lifecycle hooks, and the group-based discovery membership. Does NOT serialize — the central Serialize autoload (Phase 14) handles that.
      Files to create: `scene/maps/chunk_base.gd`
      ```gdscript
      class_name ChunkBase extends Node2D
      ## Base script for all chunk scenes.
      ## Chunk scenes assign chunk_coord before add_child().
      ## activate() / deactivate() are called by ChunkStreamer.
      ## Override _on_activated() / _on_deactivated() in subclasses (Phase 17).

      ## Chunk grid coordinate (set by ChunkStreamer before adding to tree).
      var chunk_coord: Vector2i = Vector2i.ZERO

      ## Called by ChunkStreamer after nav bake completes.
      func activate() -> void:
          set_process(true)
          set_physics_process(true)
          _on_activated()

      ## Called by ChunkStreamer when the chunk leaves the active ring.
      func deactivate() -> void:
          set_process(false)
          set_physics_process(false)
          _on_deactivated()

      ## Override in subclasses to start spawners, connect day signal, etc.
      func _on_activated() -> void:
          pass

      ## Override in subclasses to stop spawners, disconnect signals, etc.
      func _on_deactivated() -> void:
          pass
      ```
      Verify: No parse errors in Godot editor.

- [ ] 5. **Create `scene/maps/map.gd`**
      TileMap subclass stub. Full road/building generation happens in Phase 17. Phase 4 only needs the stub so chunk scenes can reference it without errors.
      Files to create: `scene/maps/map.gd`
      ```gdscript
      class_name MapTileMap extends TileMap
      ## Procedural road and building placement — full implementation in Phase 17.
      ## Phase 4 stub: methods exist but do nothing.

      ## Called by city/suburb chunk scenes to draw road tiles along a path.
      ## path_coords: Array[Vector2i] — chunk-local tile coordinates of the road.
      func generate_road(_path_coords: Array) -> void:
          pass  # Phase 17

      ## Called by city chunk scenes to place a house tile cluster.
      ## origin: Vector2i — top-left tile position. size: Vector2i — tile dimensions.
      func place_house(_origin: Vector2i, _size: Vector2i) -> void:
          pass  # Phase 17
      ```
      Verify: No parse errors in Godot editor.

- [ ] 6. **Create `scene/maps/zone/zone.gd`**
      Area2D that triggers daily outdoor spawns. Only connects to `EventBus.day_started` when the parent chunk is ACTIVE. `_on_activated()` / `_on_deactivated()` are called by the chunk via ChunkBase lifecycle. Full spawn logic added in Phase 17.
      Files to create: `scene/maps/zone/zone.gd`
      ```gdscript
      class_name Zone extends Area2D
      ## Outdoor daily spawn zone. Active only when parent chunk is ACTIVE.
      ## Full spawn implementation in Phase 17.

      @export var enemy_density: String = "medium"
      @export var spawn_radius: float = 400.0

      var _is_active: bool = false

      ## Called by the chunk's _on_activated().
      func on_chunk_activated() -> void:
          _is_active = true
          if EventBus.day_started.is_connected(_on_day_started):
              return
          EventBus.day_started.connect(_on_day_started)

      ## Called by the chunk's _on_deactivated().
      func on_chunk_deactivated() -> void:
          _is_active = false
          if EventBus.day_started.is_connected(_on_day_started):
              EventBus.day_started.disconnect(_on_day_started)

      func _on_day_started(_day_number: int) -> void:
          if not _is_active:
              return
          # Phase 17: spawn enemies within spawn_radius using enemy_density
          pass
      ```
      Verify: No parse errors in Godot editor.

- [ ] 7. **Create all chunk `.tscn` stub files (14 files)**
      Every chunk scene follows the same node structure from the masterplan. They all use `chunk_base.gd`. Content (tiles, objects, spawners) is added in Phase 17. The `.tscn` files must be valid Godot 4 text scene format.

      **Node structure for every chunk:**
      ```
      ChunkRoot (Node2D) — script: res://scene/maps/chunk_base.gd
      ├── TileMap         — no script, no tileset yet (Phase 17)
      ├── NavRegion       (NavigationRegion2D) — no nav polygon yet (Phase 17)
      ├── StaticObjects   (Node2D) — added to group "obstacle"
      ├── Spawners        (Node2D)
      ├── Houses          (Node2D)
      └── Objects         (Node2D)
      ```

      **Files to create** (all under `scene/maps/chunks/`):

      Each file uses this exact template (substitute the `[chunk_name]` in the comment):

      ```
      [gd_scene load_steps=2 format=3]

      [ext_resource type="Script" path="res://scene/maps/chunk_base.gd" id="1_base"]

      [node name="ChunkRoot" type="Node2D"]
      script = ExtResource("1_base")

      [node name="TileMap" type="TileMap" parent="."]

      [node name="NavRegion" type="NavigationRegion2D" parent="."]

      [node name="StaticObjects" type="Node2D" parent="."]

      [node name="Spawners" type="Node2D" parent="."]

      [node name="Houses" type="Node2D" parent="."]

      [node name="Objects" type="Node2D" parent="."]
      ```

      The `StaticObjects` node must be in the "obstacle" group. In Godot 4 text scene format, add this line immediately after the `[node name="StaticObjects" ...]` line:
      ```
      groups = ["obstacle"]
      ```

      **Create all 14 files** with the above template:
      - `scene/maps/chunks/city_center.tscn`
      - `scene/maps/chunks/city_block_a.tscn`
      - `scene/maps/chunks/city_block_b.tscn`
      - `scene/maps/chunks/city_block_c.tscn`
      - `scene/maps/chunks/suburb_a.tscn`
      - `scene/maps/chunks/suburb_b.tscn`
      - `scene/maps/chunks/outskirts_a.tscn`
      - `scene/maps/chunks/wilderness.tscn`
      - `scene/maps/chunks/poi_police_station.tscn`
      - `scene/maps/chunks/poi_hospital.tscn`
      - `scene/maps/chunks/poi_school.tscn`
      - `scene/maps/chunks/poi_airport.tscn`
      - `scene/maps/chunks/poi_military_base.tscn`
      - `scene/maps/chunks/poi_mall.tscn`
      - `scene/maps/chunks/poi_gas_station.tscn`
      - `scene/maps/chunks/poi_suburb_residential.tscn`

      Note: The masterplan checklist lists 14 chunks; `poi_suburb_residential.tscn` is the 15th added from the POI registry. Create all 15 files (the checklist mentions it as the `poi_suburb.tscn` variant; use `poi_suburb_residential.tscn`). That gives 16 files total counting `poi_suburb_residential.tscn`. Recount from masterplan: city_center, city_block_a/b/c (4), suburb_a/b (2), outskirts_a (1), wilderness (1), poi_police_station, poi_hospital, poi_school, poi_airport, poi_military_base, poi_mall, poi_gas_station, poi_suburb_residential = **15 files total**.

      Verify: Open Godot editor — all 15 `.tscn` files import without errors and each scene's root node shows `chunk_base.gd` as its script in the Scene panel.

- [ ] 8. **Create `autoloads/world_generator.gd`**
      One-shot generator. Called once per new game. Runs the 5-step pipeline time-sliced across frames using a coroutine (`await`) approach so the loading screen stays responsive. Uses a `Thread` to write the JSON file at the end.

      Design decisions:
      - Time-slicing uses a `_step_index` int + `_process()` that calls one step per frame and yields via `return` between steps. This avoids Thread complexity for the generator logic itself and keeps it on the main thread (safe for Godot node queries). Only the final file write uses a Thread.
      - `chunk_rng(world_seed, coord)` uses `hash(str(world_seed) + "," + str(coord.x) + "," + str(coord.y))` — deterministic, no collisions between seeds and coords that differ only by position.
      - `PLAY_RADIUS = 4` — Manhattan distance ceiling; `CITY_CENTER_COORD = Vector2i.ZERO`.
      - Biome assignment: compute Manhattan distance from origin; apply jitter using per-chunk hash in range `[-jitter_strength, +jitter_strength]`; find the biome whose range contains `(distance + jitter)`.
      - Road network: simple BFS-based path from origin to each guaranteed POI coord through chunk grid, not a true MST. This is sufficient for Phase 4 (full MST is overkill for a 9×9 grid).
      - POI placement: sort pois by `(max_distance_from_origin - min_distance_from_origin) + min_distance_from_other_pois` ascending (most constrained = smallest placement window). Retry up to 3 times loosening `min_distance_from_other_pois` by 1 each retry.
      - Fill pass: filler scene mapping by biome string (see below).
      - Writing: `FileAccess.open("user://world_layout.json", FileAccess.WRITE)`.

      Files to create: `autoloads/world_generator.gd`

      ```gdscript
      extends Node
      ## WorldGenerator — one-shot procedural world layout generator.
      ## Call generate(seed) once at new-game start.
      ## Runs time-sliced across frames (one step per frame) so loading screen stays smooth.
      ## Emits generation_complete when user://world_layout.json is written.

      signal generation_complete

      const PLAY_RADIUS: int = 4
      const BUDGET_US: int = 4000   # reserved for future multi-step frames
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
      var _poi_defs: Array = []
      var _biome_rules: Dictionary = {}
      var _write_thread: Thread = Thread.new()

      func _ready() -> void:
          set_process(false)

      ## Start the generation pipeline. seed=0 means pick a random seed.
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
          var poi_text := FileAccess.get_file_as_string("res://data/poi_registry.json")
          var poi_result: Variant = JSON.parse_string(poi_text)
          if poi_result is Dictionary:
              _poi_defs = poi_result.get("pois", [])

          var biome_text := FileAccess.get_file_as_string("res://data/biome_rules.json")
          var biome_result: Variant = JSON.parse_string(biome_text)
          if biome_result is Dictionary:
              _biome_rules = biome_result
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
              var rng := chunk_rng(world_seed, Vector2i(attempt * 1000, candidates.size()))
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
          for existing: Variant in _occupied.keys():
              var ec := existing as Vector2i
              if abs(coord.x - ec.x) + abs(coord.y - ec.y) < min_sep:
                  return false
          return true

      # ── Step 3: Road network ──────────────────────────────────────────────
      func _step_road_network() -> void:
          var roads: Array = []
          var poi_locs: Dictionary = _layout.get("poi_locations", {})
          for _poi_id: Variant in poi_locs.keys():
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
          var dirs: Array[Vector2i] = [Vector2i(1,0), Vector2i(-1,0), Vector2i(0,1), Vector2i(0,-1)]
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
          var rng := chunk_rng(world_seed, coord)
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
          _write_thread.start(_write_layout.bind(_layout.duplicate(true)))

      func _write_layout(layout: Dictionary) -> void:
          var json_str: String = JSON.stringify(layout, "\t")
          var f := FileAccess.open("user://world_layout.json", FileAccess.WRITE)
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
          var rng := chunk_rng(world_seed + 9999, coord)
          var jitter: float = rng.randf_range(-jitter_strength, jitter_strength)
          var effective_dist: float = float(dist) + jitter

          var city_range: Array = _biome_rules.get("city", [1, 2])
          var suburb_range: Array = _biome_rules.get("suburb", [2, 3])
          var outskirts_range: Array = _biome_rules.get("outskirts", [3, 4])
          var wilderness_min: float = float(_biome_rules.get("wilderness", 5))

          if effective_dist <= float(city_range[1]):
              return "city"
          elif effective_dist <= float(suburb_range[1]):
              return "suburb"
          elif effective_dist <= float(outskirts_range[1]):
              return "outskirts"
          elif effective_dist >= wilderness_min:
              return "wilderness"
          else:
              return "outskirts"
      ```

      Verify: No parse errors in Godot editor. Calling `WorldGenerator.generate()` from the Godot editor's script console (or via a test scene) completes and creates `user://world_layout.json` — check it exists via `OS.get_user_data_dir()` in the file system.

- [ ] 9. **Create `autoloads/chunk_streamer.gd`**
      Runtime chunk loading/unloading singleton. Reads `user://world_layout.json`. Time-sliced with a 4ms per-frame budget. Uses a ChunkState enum state machine per chunk. Async nav baking via `NavigationServer2D`. Never freezes the main thread.

      Design decisions:
      - `_world_layout` is loaded once in `activate()`. Not re-read each frame.
      - `_chunk_registry`: `Dictionary` keyed by `Vector2i` → `Dictionary{state, instance, ...}`.
      - `_player_chunk` is updated each frame by converting `Globals.player.global_position / CHUNK_SIZE`.
      - Only processes the diff when `_player_chunk` changes (hysteresis: unload guard, not re-queued until `HYSTERESIS` chunks beyond unload radius).
      - `_process_queue`: `Array[Vector2i]` sorted by Manhattan distance to player chunk, processed in FIFO with budget check.
      - Nav baking: request geometry from the chunk's `NavRegion` node via `NavigationServer2D.bake_from_source_geometry_data()` using a `NavigationMeshSourceGeometryData2D`. The callback fires on the main thread.
      - `spawn_sound()` and `spawn_drop_items()` are empty stubs (Phase 17 fills them in).
      - Floating origin stub: `_check_origin_shift()` is called each frame but only logs a warning when the player exceeds 8000 units from world origin. Full floating origin is Phase 16.
      - `is_initial_load_complete()`: returns true when all chunks in `ACTIVE_RADIUS` around `(0,0)` are ACTIVE. Called by LoadingState.

      Files to create: `autoloads/chunk_streamer.gd`

      ```gdscript
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
      ## coord (Vector2i) → { state, instance, scene_path, bake_rid }
      var _chunk_registry: Dictionary = {}
      ## Ordered queue of coords to process next.
      var _process_queue: Array[Vector2i] = []
      ## The chunk the player was in last frame.
      var _player_chunk: Vector2i = Vector2i(-9999, -9999)
      ## True once activate() has been called.
      var _active: bool = false
      ## Parsed world layout.
      var _world_layout: Dictionary = {}
      ## Loaded PackedScenes cache: path → PackedScene.
      var _scene_cache: Dictionary = {}

      func _ready() -> void:
          set_process(false)

      ## Called by GameState._enter_tree().
      func activate() -> void:
          if _active:
              return
          _active = true
          _chunk_root = Node2D.new()
          _chunk_root.name = "ChunkRoot"
          get_tree().current_scene.add_child(_chunk_root)
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
          _chunk_registry.clear()
          _process_queue.clear()
          _player_chunk = Vector2i(-9999, -9999)
          _world_layout = {}

      func _process(_delta: float) -> void:
          if not _active:
              return
          if not is_instance_valid(Globals.player):
              return

          # Track player chunk position
          var player_pos: Vector2 = Globals.player.global_position
          var new_chunk: Vector2i = Vector2i(
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

          _check_origin_shift(player_pos)

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
          for coord: Variant in _chunk_registry.keys():
              var cv := coord as Vector2i
              var d: int = abs(cv.x - _player_chunk.x) + abs(cv.y - _player_chunk.y)
              if d > unload_radius:
                  var entry: Dictionary = _chunk_registry[cv]
                  if entry["state"] == ChunkState.ACTIVE:
                      _begin_unload(cv)

          # Build sorted queue (closest first).
          _process_queue.clear()
          var to_queue: Array[Vector2i] = []
          for coord: Variant in needed.keys():
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
          for coord: Variant in _chunk_registry.keys():
              var entry: Dictionary = _chunk_registry[coord as Vector2i]
              var instance: Node = entry.get("instance")
              if is_instance_valid(instance):
                  if instance is ChunkBase:
                      (instance as ChunkBase).deactivate()
                  instance.queue_free()
          _chunk_registry.clear()

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

      # ── Helpers ───────────────────────────────────────────────────────────

      func _load_world_layout() -> void:
          var path: String = "user://world_layout.json"
          if not FileAccess.file_exists(path):
              push_warning("ChunkStreamer: no world_layout.json found; all chunks will use fallback.")
              return
          var text: String = FileAccess.get_file_as_string(path)
          var result: Variant = JSON.parse_string(text)
          if result is Dictionary:
              _world_layout = result
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
      ```

      Verify: No parse errors in Godot editor. Run the game — opening a new game should trigger ChunkStreamer.activate() (once GameState is wired in the next step) without errors.

- [ ] 10. **Register WorldGenerator and ChunkStreamer as autoloads in `project.godot`**
       The autoloads must be added after EventBus, in the order: `WorldGenerator` then `ChunkStreamer`. This order matters because ChunkStreamer calls `EventBus` signals, and WorldGenerator needs to exist before ChunkStreamer (though they don't reference each other directly here).
       Files to modify: `project.godot`
       Add these two lines in the `[autoload]` section, after `EventBus=...`:
       ```
       WorldGenerator="*res://autoloads/world_generator.gd"
       ChunkStreamer="*res://autoloads/chunk_streamer.gd"
       ```
       Final autoload order: Constants, Globals, Utils, Factory, Serialize, Pathfinder, EventBus, WorldGenerator, ChunkStreamer.
       Verify: Open project in Godot editor — Project → Project Settings → Autoload shows all 9 entries in order. No startup errors.

- [ ] 11. **Update `scene/states/game_state/game_state.gd`**
       Three changes needed:
       1. Call `WorldGenerator.generate()` and wait for `generation_complete` before activating ChunkStreamer on new game.
       2. Call `ChunkStreamer.activate()` in `_enter_tree` and `ChunkStreamer.deactivate()` in `_exit_tree`.
       3. Remove the 10s auto-save `_process` timer call to `Serialize.save_game()` — this is Phase 14. Replace with a plain `_process` that does nothing (or remove `_process` entirely; keep the timer var for Phase 14).

       Files to modify: `scene/states/game_state/game_state.gd`

       Replace the entire file with:
       ```gdscript
       class_name GameState extends Node2D
       ## GameState — active gameplay state.
       ## Spawns player, starts world generation (new game) or reads layout (continue).
       ## ChunkStreamer activated/deactivated with this state.

       @export var is_new_game: bool = true

       const PLAYER_SCENE := preload("res://scene/entities/player/player.tscn")
       const AUTO_SAVE_INTERVAL := 10.0   ## Phase 14 wires this up

       var _save_timer: float = 0.0
       var _player: Player = null

       func _enter_tree() -> void:
           ChunkStreamer.activate()
           Pathfinder.enable()

           if is_new_game:
               # Connect to generation_complete then generate.
               WorldGenerator.generation_complete.connect(_on_generation_complete, CONNECT_ONE_SHOT)
               WorldGenerator.generate(0)   # 0 = random seed
               EventBus.notification_requested.emit("Generating world…")
           else:
               # Continue game: layout already exists, streamer reads it directly.
               _on_generation_complete()

       func _exit_tree() -> void:
           ChunkStreamer.deactivate()
           Pathfinder.disable()
           _save_timer = 0.0

       func _process(delta: float) -> void:
           _save_timer += delta
           if _save_timer >= AUTO_SAVE_INTERVAL:
               _save_timer = 0.0
               # Phase 14: Serialize.save_game()

       func _on_generation_complete() -> void:
           _spawn_player()
           _spawn_day_night_stub()
           EventBus.notification_requested.emit("World ready!")

       func _spawn_player() -> void:
           _player = PLAYER_SCENE.instantiate()
           _player.position = Vector2(540, 960)
           add_child(_player)

           var ctrl_scene := preload("res://scene/entities/player/controller/controller.tscn")
           var ctrl: PlayerController = ctrl_scene.instantiate()
           if Globals.hud:
               Globals.hud.set_controller(ctrl)

           ctrl.move_input_changed.connect(_player.on_move_input_changed)
           ctrl.rotation_input.connect(_player.on_rotation_input)
           ctrl.action_pressed.connect(_player.on_action_pressed)
           ctrl.action_released.connect(_player.on_action_released)
           Globals._current_controller = ctrl

       func _spawn_day_night_stub() -> void:
           # Phase 12 implements the real DayNightCycle.
           EventBus.day_started.emit(1)
       ```

       Verify: Open the game → New Game → no errors in Output. The notification "Generating world…" then "World ready!" should appear.

- [ ] 12. **Update `scene/states/loading_state/loading_state.gd`**
       Replace the auto-dismiss timer stub with the ChunkStreamer signal approach described in the masterplan. The loading state checks `ChunkStreamer.is_initial_load_complete()` on each `chunk_activated` event.
       Files to modify: `scene/states/loading_state/loading_state.gd`

       Replace the entire file with:
       ```gdscript
       class_name LoadingState extends Control
       ## LoadingState — overlay shown while initial chunks load.
       ## Pauses tree but keeps physics active for nav polygon baking.
       ## Dismisses itself once ChunkStreamer reports initial load complete.

       @onready var _spinner: Label = $Spinner
       var _timer: float = 0.0

       func _enter_tree() -> void:
           get_tree().paused = true
           PhysicsServer2D.set_active(true)
           EventBus.chunk_activated.connect(_on_chunk_event)
           # Check immediately in case world is tiny and already done.
           _check_done()

       func _exit_tree() -> void:
           get_tree().paused = false
           if EventBus.chunk_activated.is_connected(_on_chunk_event):
               EventBus.chunk_activated.disconnect(_on_chunk_event)

       func _process(delta: float) -> void:
           _timer += delta
           var dots := ".".repeat(int(_timer * 3.0) % 4)
           _spinner.text = "Loading" + dots

       func _on_chunk_event(_coord: Vector2i) -> void:
           _check_done()

       func _check_done() -> void:
           if ChunkStreamer.is_initial_load_complete():
               Globals.state_manager.pop_overlay()
       ```

       Verify: Run the game → New Game → loading screen appears, eventually dismisses when the origin chunk (0,0) becomes ACTIVE. No infinite loading or crash.

- [ ] 13. **Update Phase 4 checklist in `masterplan.md`**
       Mark all completed Phase 4 checklist items with ✅. Items that are stubs (content for Phase 17) stay ⬜ with a note. Update the Phase 3 checklist for the two items that were deferred to Phase 4 (`loading_state` auto-dismiss replacement).
       Files to modify: `masterplan.md`
       Mark the following as ✅:
       - `autoloads/world_generator.gd` — singleton with full pipeline
       - `data/poi_registry.json`
       - `data/biome_rules.json`
       - Seeded RNG helper `chunk_rng()`
       - Biome assignment `_get_biome()`
       - Road network `_generate_roads()` (BFS implementation)
       - POI placement (sorted, constraint-satisfaction, relaxation)
       - Fill pass
       - `user://world_layout.json` output schema
       - `autoloads/chunk_streamer.gd` — reads layout, fallback, ring/budget/state-machine
       - `ChunkState` enum
       - Ring constants
       - Time-sliced `_process`
       - Hysteresis unload guard + player chunk tracker
       - Async nav bake via `NavigationServer2D.bake_from_source_geometry_data_async()`
       - `spawn_sound()`, `spawn_drop_items()` stubs
       - Floating origin stub
       - `city_center.tscn` through `poi_suburb_residential.tscn` (all 15 chunk stubs)
       - `map.gd` stub
       - `zone/zone.gd`
       - `chunk_base.gd`

       Leave ⬜ (Phase 17): Discovery/minimap system, `Globals.poi_locations` population.

       Verify: `masterplan.md` opens cleanly, checklist items are correctly marked.

---

## Key API Reference for Implementer

| Operation | Godot 4 API |
|-----------|-------------|
| Write file | `FileAccess.open("user://world_layout.json", FileAccess.WRITE)` then `.store_string(json)` |
| Read file | `FileAccess.get_file_as_string("user://world_layout.json")` |
| Parse JSON | `JSON.parse_string(text) -> Variant` — check `is Dictionary` before use |
| Stringify JSON | `JSON.stringify(dict, "\t")` |
| Background thread | `var t := Thread.new()` → `t.start(callable.bind(data))` → `t.wait_to_finish()` in deferred callback |
| Async nav bake | `NavigationServer2D.bake_from_source_geometry_data_async(nav_poly, source_data, callback: Callable)` |
| Parse nav geometry | `NavigationServer2D.parse_source_geometry_data(nav_poly, source_data, root_node)` |
| Signal one-shot | `signal.connect(callable, CONNECT_ONE_SHOT)` |
| Deferred call | `call_deferred("method_name")` — use when calling from a Thread |
| Chunk coord from world pos | `Vector2i(floori(pos.x / CHUNK_SIZE), floori(pos.y / CHUNK_SIZE))` |
| Hash for seeded RNG | `hash(str(seed) + "," + str(x) + "," + str(y))` |
| Ticks for budget | `Time.get_ticks_usec()` |

## File Creation Summary

| # | File | Action |
|---|------|--------|
| 1 | `autoloads/event_bus.gd` | Modify — add 3 signals |
| 2 | `data/poi_registry.json` | Create |
| 3 | `data/biome_rules.json` | Create |
| 4 | `scene/maps/chunk_base.gd` | Create |
| 5 | `scene/maps/map.gd` | Create |
| 6 | `scene/maps/zone/zone.gd` | Create |
| 7 | `scene/maps/chunks/city_center.tscn` | Create (stub) |
| 8 | `scene/maps/chunks/city_block_a.tscn` | Create (stub) |
| 9 | `scene/maps/chunks/city_block_b.tscn` | Create (stub) |
| 10 | `scene/maps/chunks/city_block_c.tscn` | Create (stub) |
| 11 | `scene/maps/chunks/suburb_a.tscn` | Create (stub) |
| 12 | `scene/maps/chunks/suburb_b.tscn` | Create (stub) |
| 13 | `scene/maps/chunks/outskirts_a.tscn` | Create (stub) |
| 14 | `scene/maps/chunks/wilderness.tscn` | Create (stub, fallback) |
| 15 | `scene/maps/chunks/poi_police_station.tscn` | Create (stub) |
| 16 | `scene/maps/chunks/poi_hospital.tscn` | Create (stub) |
| 17 | `scene/maps/chunks/poi_school.tscn` | Create (stub) |
| 18 | `scene/maps/chunks/poi_airport.tscn` | Create (stub) |
| 19 | `scene/maps/chunks/poi_military_base.tscn` | Create (stub) |
| 20 | `scene/maps/chunks/poi_mall.tscn` | Create (stub) |
| 21 | `scene/maps/chunks/poi_gas_station.tscn` | Create (stub) |
| 22 | `scene/maps/chunks/poi_suburb_residential.tscn` | Create (stub) |
| 23 | `autoloads/world_generator.gd` | Create |
| 24 | `autoloads/chunk_streamer.gd` | Create |
| 25 | `project.godot` | Modify — add 2 autoloads |
| 26 | `scene/states/game_state/game_state.gd` | Modify |
| 27 | `scene/states/loading_state/loading_state.gd` | Modify |
| 28 | `masterplan.md` | Modify — mark checklist items ✅ |
