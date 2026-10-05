# Phase 5 — Procedural Lot & House System

Phase 5 implements fully procedural lot placement and house construction on top of the existing chunk streaming infrastructure. `LotPlanner` generates lot rectangles from the world seed and biome data; `HouseBuilder` converts each lot into a playable structure with BSP-divided rooms, per-segment wall collision, door gaps, a roof with a tween fade, and spawn anchors stored in node metadata. `ChunkStreamer` and `Constants` received the additions Phase 5 needs, and `ChunkBase._on_activated()` ties it all together. The implementation is Godot 4 throughout with no serialization violations.

Watch for: (1) **confirmed** — `chunk_rng` hashes a concatenated string, which is a weaker determinism guarantee than the spec implies; (2) **likely** — `house.gd` accesses `$VisibleOnScreenNotifier2D` by path in `_ready()`, which relies on a naming contract with `HouseBuilder` that is never enforced; (3) **possible** — the `HouseSensor` collision shape is sized to the building footprint but its `position` places the centre at a chunk-local pixel offset, which may be off if the House node itself is not positioned at the chunk origin.

**Verdict**: APPROVED

---

## High-level view

The five constants (`TILE_SIZE`, `CHUNK_TILES`, `STREET_WIDTH`, `PAVEMENT_WIDTH`, `LOT_SETBACK`) land in `constants.gd` as typed `int` consts matching the masterplan spec exactly. `ChunkStreamer` gains `world_seed`, `chunk_rng`, `get_biome`, and `get_road_edges` as the spec requires; `chunk_rng` is static, which is correct for pure deterministic generation.

`LotPlanner.generate_lots` implements all three placement paths — isolated/wilderness, street-based with both-sides placement, and a city dense-fill pass — using only the provided `rng`, so lot layouts are fully deterministic from seed and chunk coordinate. All lot bounds are clamped with a 1-tile BORDER guard, and `_overlaps_any` uses `Rect2i.grow(1)` padding, so adjacency without overlap is enforced.

`HouseBuilder` covers all six pipeline steps from the masterplan. Wall collision uses per-segment `StaticBody2D` + `RectangleShape2D` (not TileMap). Door gaps are absent wall segments — no `CollisionShape2D` exists over the gap. The `parent.add_child(house)` call is deferred to the very end of `build_house`, ensuring `_ready()` fires after the full subtree (including `VisibleOnScreenNotifier2D`) is attached.

`house.gd` implements `capacity`, `spawn_day`, the `VisibleOnScreenNotifier2D` connect/disconnect pattern for `EventBus.day_started`, and `create_tween()` roof fade. The `cur_house` sensor is wired correctly. No `serialize()`/`deserialize()` methods exist anywhere in the new code.

---

<details>
<summary>Issues (3)</summary>

1. **`chunk_rng` hash collision risk** — `hash("1,2,3")` vs `hash("12,3,3")` etc. The comma separator prevents the most obvious collision but doesn't prevent all of them (e.g. seed `1` coord `(23,4)` vs seed `12` coord `(3,4)` — both stringify to "1,23,4" vs "12,3,4", distinct). In practice the risk is low but worth replacing with `hash(seed ^ (coord.x * 2654435761) ^ (coord.y * 2246822519))` before Phase 17 ships.
2. **`$VisibleOnScreenNotifier2D` path dependency** — `house.gd _ready()` fetches the notifier by the literal name `"VisibleOnScreenNotifier2D"`. If `HouseBuilder` ever renames that node, `house.gd` silently gets a null and the screen-visibility connect/disconnect loop never fires, breaking daily spawn. The name should be declared as a constant in one place or the notifier should be passed as a parameter to `set_roof`.
3. **`HouseSensor` shape position** — `sensor_shape.position` is set to the pixel centre of `build_rect` in chunk-local pixels, but `house`'s own `Node2D.position` is left at `Vector2.ZERO`. The house is added as a child of the `Houses` node which is a child of the chunk scene, so the chunk's world offset applies. This appears correct, but the lot rect's tile coordinates are never converted to a house-level offset — the house origin is at the chunk's `(0,0)` pixel, and all child positions are specified in chunk-local pixels. This is internally consistent, but differs from a "house at lot pixel origin with children relative to house" design; if `house.position` were ever set to the lot pixel origin in a later phase, all collision shapes would be doubled-offset. Worth a comment in `HouseBuilder.build_house` making the coordinate contract explicit.

</details>

---

<details>
<summary>Details</summary>

### `chunk_rng` determinism and hash robustness

`ChunkStreamer.chunk_rng` seeds a `RandomNumberGenerator` with `hash(str(seed_val) + "," + str(coord.x) + "," + str(coord.y))`. The comma separator prevents the most obvious collisions (seed `12` coord `(3,4)` and seed `1` coord `(23,4)` produce `"12,3,4"` vs `"1,23,4"` — distinct). The weakness is GDScript's built-in `hash()` is not a mixing function: it can produce the same output for different strings, and it is not guaranteed to distribute uniformly across the 64-bit `rng.seed` range. For a few thousand chunks the collision rate is negligible, but a bitwise mix (`seed ^ (coord.x * 2654435761) ^ (coord.y * 2246822519)`) is preferable before Phase 17.

### `$VisibleOnScreenNotifier2D` name contract

`house.gd _ready()` fetches the notifier by the literal path `$VisibleOnScreenNotifier2D`. `HouseBuilder` sets `notifier.name = "VisibleOnScreenNotifier2D"` before `parent.add_child(house)`, so the name is present when `_ready()` fires. If `HouseBuilder` renames that node without updating `house.gd`, the `screen_entered`/`screen_exited` connections never fire, silently disabling the daily-spawn logic. The name should be a shared constant.

### House coordinate system

All `House` child positions are expressed in chunk-local pixels (`tile_coord × 32`). The `House` node itself is at `Vector2.ZERO` relative to its `Houses` parent, so every child's `position` is chunk-absolute. This works, but if any later phase sets `house.position` to the lot pixel origin (a natural refactor), every collision shape and trigger inside the house would be double-offset. A comment in `build_house` stating the coordinate contract explicitly would prevent this.

</details>

---

<details>
<summary>File map</summary>

- `autoloads/constants.gd` — 5 Phase 5 constants added (`TILE_SIZE`, `CHUNK_TILES`, `STREET_WIDTH`, `PAVEMENT_WIDTH`, `LOT_SETBACK`)
- `autoloads/chunk_streamer.gd` — `world_seed: int`, `static chunk_rng()`, `get_biome()`, `get_road_edges()` added
- `scene/maps/lot_planner.gd` — new static class; `generate_lots()`, biome table, overlap guard, lot-type helper
- `scene/maps/house_builder.gd` — new static class; full 9-step build pipeline (footprint → floor → BSP → anchors → exterior walls → interior walls → roof → sensors → notifier)
- `scene/entities/houses/house.gd` — new `Node2D`; capacity/spawn_day, VisibleOnScreenNotifier2D pattern, EventBus wiring, roof tween, cur_house sensor
- `scene/maps/chunk_base.gd` — `_on_activated()` calls `LotPlanner.generate_lots()` then iterates lots calling `HouseBuilder.build_house()`
- `masterplan.md` — all Phase 5 checklist items marked ✅

Full diff: `git diff main -- I-Will-Survive-v2/`

</details>
