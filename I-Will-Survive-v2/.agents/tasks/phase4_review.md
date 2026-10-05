# Phase 4 — Procedural World Generation & Chunk Streaming

Phase 4 introduces WorldGenerator (one-shot procedural layout pipeline) and ChunkStreamer (runtime infinite streaming with time-slicing). WorldGenerator runs in time-sliced `_process()` steps, writes `user://world_layout.json` on a background thread, and emits `generation_complete`. ChunkStreamer drives a per-chunk state machine inside a 4 ms budget loop, using async nav-polygon baking and EventBus signals to manage the chunk lifecycle. The architecture is clean and the Godot 4 API usage is correct throughout — but there is a confirmed blocking defect in the ChunkStreamer state machine that will prevent any chunk from ever becoming active.

**Watch for:** `_begin_load` transitions a chunk to `LOADING` state but never re-adds the coord to `_process_queue`. Because `_rebuild_queue` only re-enqueues `UNLOADED` chunks, every chunk will be permanently stuck at `LOADING`. `is_initial_load_complete()` will never return `true` and the game will hang on the loading screen.

**Verdict**: CHANGES_REQUESTED

---

## High-level view

WorldGenerator's five-step pipeline (data load → biome map → POI placement → road network → fill pass) runs one step per `_process()` call. `chunk_rng` seeds via `hash(str(seed) + "," + str(x) + "," + str(y))`, making every RNG sequence deterministic per (seed, coord) pair. No Godot 3 API is used. `Thread.start` receives `_write_layout.bind(...)`, which is the correct Godot 4 Callable form. No serialize/deserialize methods exist anywhere in the v2 codebase.

ChunkStreamer's time-sliced loop is budget-gated correctly with `BUDGET_US = 4000`. The state machine has six states and advances chunks one step per pass. However, the `QUEUED → LOADING` transition (inside `_begin_load`) sets state to `LOADING` without re-queuing the coord, so the coord is never presented to the `LOADING → _begin_instantiate` branch. Every chunk stalls permanently at `LOADING`, and `is_initial_load_complete()` returns `false` forever.

GameState correctly gates `WorldGenerator.generate()` behind `is_new_game`, calling `_on_generation_complete()` directly on continue. LoadingState uses `ChunkStreamer.is_initial_load_complete()` (confirmed — not a timer-only approach) and disconnects its event listener on exit.

All 16 chunk `.tscn` files are present (14 required, 16 delivered). Every scene assigns `ChunkBase` as root script and has a `StaticObjects` node in the `"obstacle"` group. EventBus declares `chunk_activated(coord: Vector2i)` and `chunk_deactivated(coord: Vector2i)`. Both `WorldGenerator` and `ChunkStreamer` appear in the `[autoload]` section of `project.godot` in that order, after `EventBus`.

---

<details>
<summary>Issues (1)</summary>

1. **Chunk state machine stall at LOADING** — `_begin_load` sets state to `LOADING` but does not re-add `coord` to `_process_queue`. `_rebuild_queue` only re-enqueues `UNLOADED` chunks, so no LOADING chunk can ever advance to `INSTANTIATING`. Fix: add `_process_queue.push_front(coord)` at the end of `_begin_load`, mirroring the same pattern already used at the end of `_begin_instantiate`.

</details>

---

<details>
<summary>Details</summary>

### Chunk state machine stall — confirmed blocking defect

The `_process` loop pops a coord from `_process_queue` and calls `_advance_chunk(coord)`. `_advance_chunk` dispatches on `entry["state"]`:

```
QUEUED       → _begin_load()
LOADING      → _begin_instantiate()
INSTANTIATING → _begin_nav_bake()
NAV_BAKING   → pass (waiting for async callback)
```

`_begin_load` loads the `PackedScene` into `_scene_cache` and sets state to `LOADING`. It does not call `_process_queue.push_front(coord)`. The coord leaves the queue at `LOADING` and is never seen again by `_advance_chunk`.

`_rebuild_queue` (called when the player crosses a chunk boundary) explicitly guards with `if state == ChunkState.UNLOADED`, so it won't rescue a stuck `LOADING` chunk either. The only way this could self-heal would be if `_rebuild_queue` erased stale `LOADING` entries from `_chunk_registry` and reset them to `UNLOADED` — which it does not.

`_begin_instantiate` correctly calls `_process_queue.push_front(coord)` after setting state to `INSTANTIATING`, establishing that the re-queue pattern is intentional and understood. The same one-liner is simply missing from `_begin_load`.

Because no chunk ever reaches `ACTIVE`, `is_initial_load_complete()` always returns `false`, and `LoadingState._check_done()` never calls `pop_overlay()`. The game is stuck on the loading screen indefinitely.

Fix:

```gdscript
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
    _process_queue.push_front(coord)   # ← add this line
```

### State machine — remaining transitions

`_begin_instantiate` re-queues with `push_front` so the same coord is processed again the next budget window at `INSTANTIATING` state, which calls `_begin_nav_bake`. Since all Phase 4 chunk scenes have empty `NavigationRegion2D` nodes (no `navigation_polygon` set), `_begin_nav_bake` skips async baking and goes directly to `ACTIVE` — so once the load stall is fixed, chunks will complete in two budget windows.

### WorldGenerator determinism and thread safety

`chunk_rng` seeds with `hash(str(seed_val) + "," + str(coord.x) + "," + str(coord.y))`. The same (seed, coord) pair always reconstructs the same sequence. The `_write_layout` background thread only reads a deep-duplicated `_layout` dictionary and does not touch any shared mutable state, which avoids data races. `call_deferred("_on_write_done")` correctly marshals the signal back to the main thread.

`_write_thread` is allocated twice: once at class level (`Thread.new()`) and again at the top of `_step_finalize`. The first allocation is wasted but harmless.

### Autoload order and API compliance

`project.godot` registers autoloads in this order: `Constants → Globals → Utils → Factory → Serialize → Pathfinder → EventBus → WorldGenerator → ChunkStreamer`. `WorldGenerator` and `ChunkStreamer` appear after `EventBus`, which is the correct dependency order since both emit and connect to EventBus signals. No Godot 3 APIs (`yield`, `.instance()`, old `connect()` form) appear in any v2 file.

### Scope compliance

No save/load logic, enemy AI, or house placement exists in Phase 4 files. `map.gd` and `zone.gd` contain stubs explicitly deferred to Phase 17. The `AUTO_SAVE_INTERVAL` constant and comment in `game_state.gd` are scaffolding comments, not implementations. No `serialize()` / `deserialize()` methods exist in any v2 class.

</details>

---

<details>
<summary>File map</summary>

| File | What changed |
|------|-------------|
| `autoloads/world_generator.gd` | New — five-step procedural layout pipeline with BFS road network and RNG-seeded biome/fill |
| `autoloads/chunk_streamer.gd` | New — time-sliced chunk state machine with async nav baking; contains the LOADING stall bug |
| `scene/maps/chunk_base.gd` | New — base class for all chunk scenes; activate/deactivate lifecycle hooks |
| `scene/maps/map.gd` | New — Phase 17 stub for TileMap road/house generation |
| `scene/maps/zone/zone.gd` | New — Phase 17 stub for outdoor spawn zone, connects to EventBus day_started |
| `scene/states/game_state/game_state.gd` | Updated — activates ChunkStreamer, gates WorldGenerator.generate() on is_new_game |
| `scene/states/loading_state/loading_state.gd` | Updated — uses ChunkStreamer.is_initial_load_complete() with MIN_DISPLAY_TIME guard |
| `data/poi_registry.json` | New — 8 POI definitions with biome, distance, and loot tier metadata |
| `data/biome_rules.json` | New — distance thresholds and jitter strength for biome assignment |
| `project.godot` | Updated — WorldGenerator and ChunkStreamer added to [autoload] |
| `scene/maps/chunks/*.tscn` | New — 16 chunk scenes (14+ required), all with ChunkBase script and obstacle group |

Full diff: `git diff main -- I-Will-Survive-v2/`

</details>
