# Phase 4 — Procedural World Generation & Chunk Streaming

Phase 4 introduces `WorldGenerator` (one-shot layout generation) and `ChunkStreamer` (runtime infinite streaming), backed by `ChunkBase`, `Zone`, `map.gd`, `loading_state.gd`, `game_state.gd`, and 15 chunk `.tscn` files. The implementation is broadly correct and follows the masterplan architecture. Watch for: one confirmed runtime crash (`Array[Dictionary]` typed mismatch in `world_generator.gd`), two confirmed Variant-inference warnings that may become errors depending on per-file warning settings, and the `_begin_load` double-enqueue pattern that needs a close read to confirm it doesn't double-process in the wrong state.

**Verdict**: NEEDS_CHANGES

---

## High-level view

WorldGenerator is correctly structured as a per-frame state machine (one step per `_process` call), writing the layout to `user://world_layout.json` on a background thread using `Thread.start(Callable)` — Godot 4 API, not Godot 3. The `chunk_rng` helper is properly deterministic: same seed + coord always produces the same sequence because it uses `hash(str(seed) + "," + str(x) + "," + str(y))` as the RNG seed before any `randi()` calls.

ChunkStreamer's time-sliced design uses `Time.get_ticks_usec() + BUDGET_US` as a wall-clock budget per frame — no blocking while-loop. The state machine (QUEUED → LOADING → INSTANTIATING → NAV_BAKING → ACTIVE) is driven correctly, and the double `push_front` in `_begin_load` and `_begin_instantiate` is intentional: it lets a chunk advance two steps within one budget window rather than waiting a full frame per step.

The `_poi_defs` typed-array assignment is a confirmed runtime crash. `JSON.parse_string` returns an untyped `Array` for the "pois" value, and assigning that to `Array[Dictionary]` throws a runtime type error in Godot 4. This breaks world generation on every new-game start.

The Variant inference on `var poi_result := JSON.parse_string(...)` and `var biome_result := JSON.parse_string(...)` in `_step_load_data`, and `var result := JSON.parse_string(...)` in `_load_world_layout`, are confirmed unguarded (no `@warning_ignore("inference_on_variant")`). The project does not have a global `treat_warnings_as_errors` setting, but earlier in this project's history the same pattern caused "Warning treated as error" failures on other files. Whether this fires depends on per-file editor strictness settings; it should be suppressed proactively.

Autoload order in `project.godot` is correct: `EventBus` is declared before `WorldGenerator` and `ChunkStreamer`, so signal references resolve at boot. `WorldGenerator` appears before `ChunkStreamer` as required.

The 15 chunk `.tscn` files all exist, all reference `chunk_base.gd`, and all have `StaticObjects` in group `"obstacle"`. POI scenes match the IDs and paths declared in `poi_registry.json`. The `EventBus` has both `chunk_activated(coord: Vector2i)` and `chunk_deactivated(coord: Vector2i)` signals. No `serialize()`/`deserialize()` methods appear in any Phase 4 file. `game_state.gd` only calls `WorldGenerator.generate()` when `is_new_game` is true; the continue path skips it. `loading_state.gd` uses `ChunkStreamer.is_initial_load_complete()` as the gate, not a timer alone.

There is a gap in `_get_biome`: effective distances in the range (4.0, 5.0) — between `outskirts_range[1]` and `wilderness_min` — fall through to the final `else` branch which returns `"outskirts"`. With jitter_strength=0.25 and PLAY_RADIUS=4 (max Manhattan distance 8), chunks at distance 4 with negative jitter can land in this gap. The result is "outskirts" for those cells, which is reasonable behavior, but the gap exists silently rather than by explicit design.

---

<details>
<summary>Issues (3)</summary>

1. **`_poi_defs` typed-array runtime crash** — `_poi_defs` is declared `Array[Dictionary]` but assigned from `(poi_result as Dictionary).get("pois", [])`, which returns an untyped `Array`. Godot 4 throws a runtime type error on this assignment. Fix: use `Array[Dictionary](_poi_defs_raw)` coercion or assign via a loop, or change the declaration to `var _poi_defs: Array = []` and add a type annotation comment.

2. **Variant-inference warnings in `_step_load_data` and `_load_world_layout`** — `var poi_result := JSON.parse_string(...)`, `var biome_result := JSON.parse_string(...)`, and `var result := JSON.parse_string(...)` all infer as Variant. No `@warning_ignore("inference_on_variant")` is present on these lines. Given that earlier files in this project triggered "Warning treated as error" for the same pattern, these should be suppressed with `@warning_ignore("inference_on_variant")` or typed explicitly as `Variant`.

3. **Biome gap between outskirts and wilderness is silent** — effective distances in (4.0, 5.0) fall to the final `else` → `"outskirts"` without an explicit case. With jitter ±0.25 on distance-4 chunks this is reachable. Not a crash, but the intent should be made explicit (either extend `outskirts_range` to cover 5.0 or add an explicit range check before the wilderness check).

</details>

---

<details>
<summary>Details</summary>

### Typed-array assignment crash in `_step_load_data`

`_poi_defs` is declared as `Array[Dictionary]` at line 40 of `world_generator.gd`. In `_step_load_data`, the assignment reads:

```gdscript
_poi_defs = (poi_result as Dictionary).get("pois", [])
```

`Dictionary.get()` returns a `Variant`. Even though the JSON value under "pois" is an array of dictionaries, Godot 4's type system enforces the container type at assignment time, not element-by-element. Assigning an untyped `Array` to `Array[Dictionary]` raises `Invalid assignment of property or key … with value of type 'Array'` at runtime. The generation pipeline never advances past step 0 on a new game. **Confirmed** — the declaration and the assignment are both visible in the file.

The fix is straightforward: either declare `var _poi_defs: Array = []` (and add a comment noting elements are `Dictionary`), or coerce the result:

```gdscript
var raw: Array = (poi_result as Dictionary).get("pois", [])
for entry in raw:
    _poi_defs.append(entry as Dictionary)
```

### Variant-inference warnings

`JSON.parse_string()` returns `Variant`. Godot 4's strict type inference warns when a `:=` declaration infers Variant. In `_step_load_data`:

```gdscript
var poi_result := JSON.parse_string(poi_text)    # Variant warning
var biome_result := JSON.parse_string(biome_text) # Variant warning
```

In `_load_world_layout`:

```gdscript
var result := JSON.parse_string(text)  # Variant warning
```

None of these have `@warning_ignore("inference_on_variant")`. The same pattern in `utils.gd` also lacks the annotation. This project has a history of treating specific inference warnings as errors (SceneStateManager.gd was an earlier example). The safest fix is to declare these explicitly as `Variant`:

```gdscript
var poi_result: Variant = JSON.parse_string(poi_text)
```

or add the annotation above each line. **Confirmed** by reading both files.



</details>

---

<details>
<summary>File map</summary>

| File | Change |
|------|--------|
| `autoloads/world_generator.gd` | New — one-shot procedural layout generator, 6-step frame-sliced pipeline, writes `user://world_layout.json` |
| `autoloads/chunk_streamer.gd` | New — runtime infinite streaming with 7-state machine, BUDGET_US time-slicing, async nav bake |
| `scene/maps/chunk_base.gd` | New — base class for all chunk scenes; activate/deactivate lifecycle |
| `scene/maps/zone/zone.gd` | New — Area2D spawn zone stub; connects EventBus.day_started when activated |
| `scene/maps/map.gd` | New — TileMap stub for Phase 17 road/house placement |
| `scene/states/game_state/game_state.gd` | Updated — conditionally calls WorldGenerator.generate() only for new game |
| `scene/states/loading_state/loading_state.gd` | Updated — gates dismissal on ChunkStreamer.is_initial_load_complete() |
| `data/poi_registry.json` | New — 8 POI definitions with biome, distance, and loot metadata |
| `data/biome_rules.json` | New — biome distance thresholds and jitter strength |
| `project.godot` | Updated — WorldGenerator and ChunkStreamer added to [autoload] section |
| `scene/maps/chunks/*.tscn` (×15) | New — all chunk scene stubs with TileMap, NavRegion, StaticObjects(obstacle), Spawners, Houses, Objects |

</details>
