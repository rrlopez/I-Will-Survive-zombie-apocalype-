# I Will Survive (Zombie Apocalypse) — Godot 4 Master Recreation Plan

> **Game Concept:** A top-down 2D zombie survival game inspired by Dead Town. The player scavenges a procedurally populated open world, fights zombie waves, manages hunger and health, crafts/builds, drives vehicles, and survives escalating nights. Designed **mobile-first** (virtual joystick + rotate-to-aim touch controls) with full keyboard fallback.

---

## Table of Contents
- [I Will Survive (Zombie Apocalypse) — Godot 4 Master Recreation Plan](#i-will-survive-zombie-apocalypse--godot-4-master-recreation-plan)
  - [Table of Contents](#table-of-contents)
  - [1. Tech Stack \& Godot 4 Decisions](#1-tech-stack--godot-4-decisions)
  - [2. Architecture Overview](#2-architecture-overview)
  - [3. Project Structure](#3-project-structure)
  - [4. Phase Plans \& Checklists](#4-phase-plans--checklists)
    - [PHASE 0 — Project Setup](#phase-0--project-setup)
      - [Plan](#plan)
      - [Checklist](#checklist)
    - [PHASE 1 — Stat System (Foundation)](#phase-1--stat-system-foundation)
      - [Plan](#plan-1)
      - [Checklist](#checklist-1)
    - [PHASE 2 — Entity Base + Player](#phase-2--entity-base--player)
      - [Plan](#plan-2)
      - [Checklist](#checklist-2)
    - [PHASE 3 — Game States \& HUD Skeleton](#phase-3--game-states--hud-skeleton)
      - [Plan](#plan-3)
      - [Checklist](#checklist-3)
    - [PHASE 4 — Map \& World](#phase-4--map--world)
      - [Plan](#plan-4)
      - [Checklist](#checklist-4)
    - [PHASE 5 — Behavior Tree + Pathfinder](#phase-5--behavior-tree--pathfinder)
      - [Plan](#plan-5)
      - [Checklist](#checklist-5)
    - [PHASE 6 — Enemy System](#phase-6--enemy-system)
      - [Plan](#plan-6)
      - [Checklist](#checklist-6)
    - [PHASE 7 — Item System](#phase-7--item-system)
      - [Plan](#plan-7)
      - [Checklist](#checklist-7)
    - [PHASE 8 — Inventory System](#phase-8--inventory-system)
      - [Plan](#plan-8)
      - [Checklist](#checklist-8)
    - [PHASE 9 — Weapons \& Combat](#phase-9--weapons--combat)
      - [Plan](#plan-9)
      - [Checklist](#checklist-9)
    - [PHASE 10 — Placables \& Building](#phase-10--placables--building)
      - [Plan](#plan-10)
      - [Checklist](#checklist-10)
    - [PHASE 11 — House System](#phase-11--house-system)
      - [Plan](#plan-11)
      - [Checklist](#checklist-11)
    - [PHASE 12 — Day/Night Cycle \& World Events](#phase-12--daynight-cycle--world-events)
      - [Plan](#plan-12)
      - [Checklist](#checklist-12)
    - [PHASE 13 — Vehicle System](#phase-13--vehicle-system)
      - [Plan](#plan-13)
      - [Checklist](#checklist-13)
    - [PHASE 14 — Save / Load System](#phase-14--save--load-system)
      - [Plan](#plan-14)
      - [Checklist](#checklist-14)
    - [PHASE 15 — Polish \& FX](#phase-15--polish--fx)
      - [Plan](#plan-15)
      - [Checklist](#checklist-15)
    - [PHASE 16 — Optimization \& Mobile Readiness](#phase-16--optimization--mobile-readiness)
      - [Plan](#plan-16)
      - [Checklist](#checklist-16)
    - [PHASE 17 — Content \& Data](#phase-17--content--data)
      - [Plan](#plan-17)
      - [Checklist](#checklist-17)
    - [FUTURE PHASES (Post-Core)](#future-phases-post-core)
  - [Key Implementation Reference](#key-implementation-reference)
    - [CharacterBody2D Movement (Godot 4)](#characterbody2d-movement-godot-4)
    - [Threaded Operations](#threaded-operations)
    - [Signal Connections](#signal-connections)
    - [Await (replaces yield)](#await-replaces-yield)
    - [NavigationAgent2D (Godot 4 nav API)](#navigationagent2d-godot-4-nav-api)
    - [JSON I/O](#json-io)

---

## 1. Tech Stack & Godot 4 Decisions

| Area | Old (Godot 3.x) | New (Godot 4.x) |
|------|-----------------|-----------------|
| Entity movement | `KinematicBody2D` + `move_and_slide(vel * delta)` | `CharacterBody2D` + `velocity` property + `move_and_slide()` |
| Navigation | `Navigation2DServer` + `NavigationPolygonInstance` | `NavigationServer2D` + `NavigationRegion2D` + `NavigationAgent2D` |
| Threading | `Thread.start(self, "method", data)` | `Thread.start(callable.bind(data))` |
| Async/yield | `yield(signal)` | `await signal` |
| Signals | `connect("sig", self, "method")` | `signal_name.connect(callable)` |
| Tweens | Tween node + `interpolate_property` | `create_tween()` with chained calls |
| VisibilityNotifier | `VisibilityEnabler2D` | `VisibleOnScreenNotifier2D` |
| Exports | `export(NodePath) onready var x` | `@export var x: NodePath` + `@onready` |
| Packed arrays | `PoolVector2Array` etc. | `PackedVector2Array` etc. |
| JSON | `parse_json(str)` | `JSON.parse_string(str)` |
| File I/O | `File.new()` | `FileAccess.open()` |
| Physics Server | `Physics2DServer` | `PhysicsServer2D` |
| Class icons | `class_name Foo, "icon.png"` | `@icon("path")` annotation |

**Godot 4 features we will use:**
- `@export_group` / `@export_subgroup` to organize inspector properties
- Typed `Resource` classes for stats, modifiers, attacks, status effects
- `NavigationAgent2D.target_position` + `get_next_path_position()` (new nav API)
- `create_tween()` for all animations and camera shake
- `VisibleOnScreenNotifier2D` for enemy LOD and serialization group management
- `SubViewport` for minimap rendering
- Pure GDScript — no GDExtension needed

---

## 2. Architecture Overview

```
Game (game.tscn)
├── Autoloads (Singletons)
│   ├── Constants     — preloaded scenes, tile size, multipliers, RNG
│   ├── Globals       — runtime node refs (camera, player, HUD, mapManager…)
│   ├── Factory       — root factory aggregating all sub-factories
│   ├── Serialize     — threaded JSON save/load
│   ├── Pathfinder    — async nav request queue (0.5s batch thread)
│   └── Utils         — file I/O, inventory helpers, array filters
│
├── Core Systems
│   ├── Stat System          — Stat resource + 11 typed subclasses + 7 modifiers
│   ├── Status Effect System — StatusEffect container + Buff/Regen/ApplyForce
│   ├── Inventory System     — Grid inventory + slots + touch drag-and-drop manager
│   ├── Item System          — Item UI nodes (5 subtypes)
│   ├── Behavior Tree        — Task/Leaf/5 Composites/10 Decorators + 18 leaves
│   └── State Machine        — Stack-based with dissolve transitions
│
├── Entities
│   ├── Entity (base CharacterBody2D)
│   ├── Player          — stack-velocity movement, 3 inventories, weapons, build preview
│   ├── Enemy           — BT-driven, async pathfinding, vision rays, herd aggro
│   ├── Vehicle         — Ackermann steering, embark/disembark
│   └── Placables       — Table (crafting), Campfire, base class with health
│
├── World
│   ├── MapManager    — owns World, spawns sounds & drops
│   ├── World         — 5×5 RegionSensor grid (25 chunks × BLOCK_SIZE)
│   ├── RegionSensor  — threaded chunk load/unload + NavRegion2D generation
│   ├── Map (TileMap) — procedural roads + building placement
│   ├── House         — daily enemy/loot spawning per structure
│   └── Zone          — outdoor daily spawn areas
│
├── HUD (CanvasLayer 2)
│   ├── Gages (health, hunger)
│   ├── HotBar
│   ├── Minimap
│   ├── DayNightCycle (CanvasModulate + night wave spawner)
│   ├── Calendar
│   ├── StatusEffectIcons
│   ├── WeaponPanel
│   └── NotifContainer
│
└── Game States (stack)
    ├── MenuState
    ├── GameState      — creates Player, DayNightCycle, HotBar; auto-save 10s
    ├── LoadingState   — overlay; pauses tree but keeps physics for chunk loading
    ├── PauseState
    ├── MapState       — fullscreen panning map
    └── GameOverState  — revive or return to menu
```

---

## 3. Project Structure

```
res://
├── autoloads/
│   ├── constants.gd
│   ├── globals.gd
│   ├── utils.gd
│   ├── serialize.gd
│   ├── pathfinder.gd
│   └── factory/
│       ├── factory.gd
│       ├── enemy_factory.gd
│       ├── item_factory.gd
│       ├── equipment_factory.gd
│       ├── placable_factory.gd
│       ├── stat_factory.gd
│       ├── stat_modifier_factory.gd
│       ├── status_effect_factory.gd
│       └── particle_factory.gd
├── data/
│   ├── player.json
│   ├── enemies.json
│   └── items.json
├── stat/
│   ├── stat.gd
│   ├── status_effect.gd
│   ├── status_effects.gd
│   ├── modifiers/         (add, subtract, multiply, divide, set, push, pop)
│   ├── stat_effects/      (apply_force, buff, regen)
│   └── stats/             (health, hunger, level, move_speed, damage, ammo,
│                           size, vision, fire_accuracy, aggression_range, default)
├── ai/
│   ├── behavior_tree/
│   │   ├── task.gd
│   │   ├── leaf.gd
│   │   ├── composites/    (sequence, selector, parallel, random_sequence, random_selector)
│   │   └── decorators/    (invert, repeat, until_fail, until_success, limit,
│   │                       skip, always_succeed, always_fail, always_run, wait)
│   ├── leaves/            (18 leaf scripts — see Phase 5)
│   └── trees/             (wander_ai.tscn, basic_ai.tscn, chase_ai.tscn)
├── scene/
│   ├── game.tscn
│   ├── states/            (state_manager, menu, game, loading, pause, map, game_over)
│   ├── hud/               (hud, gage, hotbar, minimap, day_night_cycle,
│   │                       calendar, status_effects, weapon_panel, notif_container)
│   ├── entities/
│   │   ├── entity.gd
│   │   ├── player/        (player, controller, placable preview)
│   │   ├── enemies/       (enemy, body, attacks, spawner)
│   │   ├── houses/        (house base + 10 variants, roof)
│   │   ├── vehicles/      (vehicle, vehicle_controller)
│   │   ├── items/         (weapons/range, weapons/melee, hand_items)
│   │   ├── placables/     (placable_base, table, campfire)
│   │   └── objects/       (blood, chest, drop_item, projectile, notif, sound)
│   ├── maps/
│   │   ├── world.tscn
│   │   ├── map.tscn
│   │   ├── map_manager/
│   │   ├── region_sensor/
│   │   ├── zone/
│   │   └── maps/          (25 block.tscn files)
│   └── ui/
│       ├── inventory/     (inventory, slot, craft_inventory, equipment_slot,
│       │                   weapon_slot, loot_slot, panel, player_inventory_panel,
│       │                   inventory_manager)
│       └── items/         (item base, consumable, craftable, equipment,
│                           placable, resource)
└── assets/
    ├── sprites/
    ├── sfx/
    ├── fonts/
    └── tilesets/
```

---

## 4. Phase Plans & Checklists

> **Legend:** ⬜ Not started | 🔄 In progress | ✅ Complete

---
### PHASE 0 — Project Setup

#### Plan
This phase creates the clean Godot 4 project skeleton that all other phases build on. Nothing game-logic is written here — the goal is a correctly configured project with the right folder structure, autoloads registered, physics layers named, and input actions defined so every subsequent phase can reference them without reconfiguration.

**Project settings to configure:**
- Display size: `1080×1920` portrait (mobile target). Enable `stretch/mode = canvas_items` and `stretch/aspect = expand` so the game scales to any screen.
- Physics layers (2D): Layer 1=player, Layer 2=enemy, Layer 3=object, Layer 4=obstacle, Layer 5=sensor, Layer 6=wall, Layer 7=drop_item, Layer 8=house, Layer 9=region_sensor
- Input map: `move_up/down/left/right` (WASD + arrow keys), `ui_accept`, `reload` (R key). Touch is handled in code, not via input map.
- Enable `emulate_touch_from_mouse = true` for desktop testing.
- Set `physics/2d/thread_model = multi_threaded` for background nav polygon generation.

**Autoloads to register (order matters — Constants before everything else):**
1. `Constants` — `res://autoloads/constants.gd`
2. `Globals` — `res://autoloads/globals.gd`
3. `Utils` — `res://autoloads/utils.gd`
4. `Factory` — `res://autoloads/factory/factory.gd`
5. `Serialize` — `res://autoloads/serialize.gd`
6. `Pathfinder` — `res://autoloads/pathfinder.gd`

**Stub implementations:** Each autoload starts as a minimal stub (just `extends Node`) so the project opens without errors. They get fleshed out in their respective phases.

**Data files:** Copy `player.json`, `enemies.json`, `items.json` from the old project into `res://data/`. No changes needed yet — they will be verified in Phase 17.

#### Checklist
- ⬜ Create new Godot 4 project named `I-Will-Survive-v2`
- ⬜ Configure display settings (1080×1920, canvas_items stretch, expand aspect)
- ⬜ Name all 9 physics layers in Project Settings → Layer Names → 2D Physics
- ⬜ Set up input map (move_up/down/left/right, ui_accept, reload)
- ⬜ Enable `emulate_touch_from_mouse` in Project Settings
- ⬜ Register all 6 autoloads in correct order with stub scripts
- ⬜ Create full folder structure (`autoloads/`, `data/`, `stat/`, `ai/`, `scene/`, `assets/`)
- ⬜ Copy `player.json`, `enemies.json`, `items.json` into `res://data/`
- ⬜ Set up fonts (`res://assets/fonts/`) — import Roboto or equivalent at sizes 8 and 16
- ⬜ Confirm project opens and runs without errors (empty main scene)

---

### PHASE 1 — Stat System (Foundation)

#### Plan
The stat system is the backbone of every entity, weapon, status effect, and crafting recipe in the game. It must be solid before anything else is built. Everything references stats.

**Core concept:** A `Stat` is a `Resource` (not a Node) that holds a numeric value. It has a `default_val` set from JSON data, a `max_val` computed from level scaling, and a current `val`. Modifiers (also Resources) are applied to the stat temporarily or permanently. The stat calls back to its owning `agent` (entity) when the value changes — this is how health triggers death, hunger triggers starvation, etc.

**Modifier pipeline:**
```
stat.set_val(SubtractModifier.new(10))   # deal 10 damage
→ modifier.execute(current_val)          # returns new value
→ val = clamp(result, 0, max_val)
→ agent.health_stat_callback(self)       # triggers death check
```

**Permanent modifiers** (from level-up or equipment) are stored in `modifiers[]` and replayed during `recompute()`. One-shot modifiers (damage, heal) are applied directly and discarded.

**Level scaling:** Each stat has a `multiplier`. When the player levels up, `recompute()` recalculates `max_val = default_val + (level - 1) * multiplier`. The stat's `val` is adjusted to maintain the same deficit (e.g. if player was 200 HP below max, they stay 200 below the new max).

**StatusEffect container (`status_effects.gd`):** A resource that owns an array of `StatusEffect` resources. Each `StatusEffect` wraps one or more stat effects (Buff, Regen, ApplyForce). The container's `run(delta)` ticks all effects each frame and removes expired ones.

**Factory pattern:** `StatFactory` maps string names from JSON (e.g. `"health"`, `"move_speed"`) to their GDScript classes. This lets JSON data drive which stat type gets instantiated without hardcoding.

**Key design decisions:**
- Stats are Resources (not Nodes) — they travel with `data{}` dict, can be duplicated, and serialized as plain dicts without needing a scene tree.
- The `agent` reference is set at `init()` time and is a weak reference pattern — the stat doesn't own the entity.
- `set_val` vs `add_modifier`: `set_val` is for transient changes (damage, consume, regen tick). `add_modifier` is for persistent changes (equipment buffs, level-up bonuses).

#### Checklist
- ⬜ `stat/stat.gd` — Base `Stat` resource: `val`, `max_val`, `default_val`, `modifiers[]`, `multiplier`, `agent`; implement `add_modifier()`, `remove_modifier()`, `recompute()`, `set_val(modifier)`, `reset()`, `serialize()`, `deserialize()`
- ⬜ `stat/modifiers/add_modifier.gd` — `execute(val)` returns `val + amount`
- ⬜ `stat/modifiers/subtract_modifier.gd` — `execute(val)` returns `val - amount`
- ⬜ `stat/modifiers/multiply_modifier.gd` — `execute(val)` returns `val * amount`
- ⬜ `stat/modifiers/divide_modifier.gd` — `execute(val)` returns `val / amount`
- ⬜ `stat/modifiers/set_modifier.gd` — `execute(val)` returns `amount` (ignores current val)
- ⬜ `stat/modifiers/push_modifier.gd` — adds a StatusEffect to the agent's container
- ⬜ `stat/modifiers/pop_modifier.gd` — removes a StatusEffect from the agent's container by id
- ⬜ `stat/stat_effects/apply_force.gd` — stores force direction + magnitude; `run(agent, delta)` adds to `agent.applied_force`, decays by friction each frame, returns true when exhausted
- ⬜ `stat/stat_effects/buff.gd` — `add(opponent)` calls `stat.add_modifier()`; `run(delta)` counts duration; `remove(agent)` calls `stat.remove_modifier()`
- ⬜ `stat/stat_effects/regen.gd` — `run(delta)` applies modifier at `rate` interval; stops after `duration` (-1 = infinite)
- ⬜ `stat/stats/health_stat.gd` — overrides `set_val()` to call `agent.health_stat_callback(self)`; returns true if `val <= 0`
- ⬜ `stat/stats/hunger_stat.gd` — overrides `run(delta)` to drain val over time; at 0 applies damage to health at `hunger_tolerance` rate
- ⬜ `stat/stats/level_stat.gd` — overrides `set_val()` to accumulate XP; calls `level_up()` when XP >= threshold; `level_up()` increments level, resets health to full, calls `agent.recompute_stats()`
- ⬜ `stat/stats/move_speed_stat.gd`, `damage_stat.gd`, `ammo_stat.gd`, `size_stat.gd`, `vision_stat.gd`, `fire_accuracy_stat.gd`, `aggression_range_stat.gd`, `default_stat.gd` — minimal overrides as needed
- ⬜ `stat/status_effect.gd` — Resource wrapping `id`, `effects[]`, `duration`; `run(delta)` ticks all effects; removes self when all effects done
- ⬜ `stat/status_effects.gd` — Container resource: `add_val(se)`, `remove_val(se)`, `run(delta)`, `reset()`, `serialize()`, `deserialize()`
- ⬜ `autoloads/factory/stat_factory.gd` — dict mapping `"health" → HealthStat` etc.; `create(id, data, agent)` instantiates correct class
- ⬜ `autoloads/factory/stat_modifier_factory.gd` — dict mapping `"add" → AddModifier` etc.; `create(name, data)` and `create_all(array)`
- ⬜ `autoloads/factory/status_effect_factory.gd` — `create(data, opponent, parent)`: rolls chance, checks for duplicate id, instantiates stat effects, wraps in StatusEffect, calls `opponent.add_status_effect(se)`

---

### PHASE 2 — Entity Base + Player

#### Plan
The player is the first living thing in the game. This phase produces a movable player character you can test in an empty scene before any world, enemies, or UI exist.

**Entity base (`entity.gd`):** A `CharacterBody2D` with a `data{}` dict (populated from JSON), a `StatusEffects` container, and an `applied_force` Vector2 for knockback/charge. The `init()` method is called manually (not `_ready()`) because entities are spawned by factories after the scene tree is ready. `init()` creates the StatusEffects container and instantiates all stats via `Factory.stat.create()`.

**Player movement — stack-based velocity:** The player can receive movement from multiple simultaneous sources (left joystick, WASD key presses). Each source pushes a `{key, value}` dict onto a `velocity_stack` array. The last entry wins. On release, entries are removed by key. This cleanly handles the case where you release one WASD key while another is still held. Final motion: `velocity = velocity_stack.back().value.rotated(rotation) * move_speed`.

**Controller design:** The controller is a separate `Control` node added dynamically to the HUD (not the player). This is critical for vehicles — when the player enters a vehicle, `Globals.current_controller` is swapped to the vehicle controller without touching the player node. The controller emits signals that the player (or vehicle) connects to.

- Left half of screen: virtual joystick. Touch start records origin; move calculates normalized direction vector. Emits `use_joystick_vector(key, vector)`.
- Right half of screen: drag rotates player. Emits `use_rotate_area_degrees(degrees)`.
- WASD: mapped to the same joystick signals with unit vectors.

**Player scene node hierarchy:**
```
Player (CharacterBody2D)
├── Collider (CollisionShape2D) — CircleShape2D, radius = BLOCK_SIZE * 2
├── Body (Node2D)
│   ├── Lower (Node2D) — legs sprite + AnimationPlayer (run_straight, run_side, idle)
│   └── Upper (Node2D) — torso sprite + AnimationPlayer (run, pistol, rifle, melee…)
├── WeaponContainer (Node2D) — active weapon scene lives here
├── HandContainer (Node2D) — active hand item (torch) lives here
├── PlacablePreview (Node2D) — building placement preview
└── Pickup (Area2D) — detects DropItem bodies to auto-pick up
```

**Health feedback:** When health drops below 50%, a full-screen red vignette `ColorRect` (in HUD) scales and fades in proportionally. This is handled in `health_stat_callback()` via a formula that maps HP% to alpha and scale.

**Godot 4 note:** `move_and_slide()` no longer takes velocity as a parameter. Assign `self.velocity` then call `move_and_slide()`. Also no `delta` multiplication needed — Godot 4 handles it internally with the physics tick.

#### Checklist
- ⬜ `scene/entities/entity.gd` — `CharacterBody2D`: `data{}`, `status_effects`, `applied_force`; `init()`, `_process(delta)` runs status effects, `_hurt(modifier)`, `revive()`, `recompute_stats()`, `add_status_effect()`, `remove_status_effect()`
- ⬜ `autoloads/constants.gd` — `BLOCK_SIZE = 3200`, `MOVE_SPEED_MULTIPLIER = 100`, `EXP_MULTIPLIER = 100`, `STAT_RANDOM = 0.7`, screen size constants, `rng` (RandomNumberGenerator), preloaded scene references (filled in later phases)
- ⬜ `autoloads/globals.gd` — typed vars: `var camera: Camera2D`, `var player: CharacterBody2D`, `var hud`, `var map_manager`, `var day_night_cycle`, `var state_manager`, `var cur_region: String`, `var cur_house`, `var loading_blocks_count: int`, `var current_controller` (with setget that swaps controller into HUD)
- ⬜ `scene/entities/player/player.gd` — extends Entity; `velocity_stack: Array`, `inventory`, `craftable_inventory`, `placable_inventory`; `init()` reads `data/player.json`, calls `Entity.init()`, creates 3 inventories; `_physics_process()` moves with stacked velocity; `hurt()`, `dead()` → pushes GameOverState, `health_stat_callback()`, `set_weapon()`, `set_hand_item()`, `spawn_sound()`, serialize/deserialize
- ⬜ `scene/entities/player/controller/controller.gd` — `Control` node covering full screen; left-half touch → joystick; right-half touch → rotate; WASD → joystick signals; signals: `use_joystick_vector`, `on_joystick_release`, `use_rotate_area_degrees`
- ⬜ `scene/entities/player/player.tscn` — full node hierarchy as above
- ⬜ `scene/entities/player/upper_body_animation.gd` — wraps AnimationPlayer; on `attack_landed` and `attack_finished` animation track markers, emits corresponding signals
- ⬜ Verify: player moves in all 8 directions with WASD, rotates on mouse drag (emulated touch), stays still when no input

---

### PHASE 3 — Game States & HUD Skeleton

#### Plan
This phase wires up the game loop shell — you can open the game, press New Game, see the player in an empty world, and open the pause menu. No world or enemies yet, but the state flow and HUD structure are in place.

**State machine design:** A `StateManager` node holds a stack of state scenes. States are `Control` nodes that cover the full screen (or part of it for overlays). Transitions play a dissolve animation (fade to black, swap, fade in). The manager exposes:
- `push_state(name)` — transitions to a new state
- `pop_state()` — goes back to the previous state  
- `add_overlay_state(name)` / `remove_overlay_state(name)` — for non-exclusive overlays like LoadingState

States connect to `Globals` and signals during `_enter_tree()` and disconnect in `_exit_tree()`.

**State responsibilities:**
| State | Responsibility |
|-------|---------------|
| MenuState | Show title, New Game / Continue buttons. Checks `Serialize.has_save_data()` to show/hide Continue. |
| GameState | Creates and adds Player + DayNightCycle + HotBar to scene. Starts 10s auto-save timer. Enables Pathfinder's physics process. On exit: disables Pathfinder. |
| LoadingState | Overlay. On enter: `get_tree().paused = true` but `PhysicsServer2D` keeps running for chunk loading. Watches `Globals.loading_blocks_count`; when it hits 0, removes self. |
| PauseState | `get_tree().paused = true`. Resume: unpause + pop. Quit: pop to MenuState. |
| MapState | `get_tree().paused = true`. Shows full-screen map image + player marker. Touch drag pans. |
| GameOverState | Saves game. Shows Revive / Main Menu. Revive calls `Globals.player.revive()` and unpauses. |

**HUD structure:** A `CanvasLayer` at layer 2 (so it renders above the game). The HUD script holds typed references to all sub-components. Sub-components are initialized with stub functionality in this phase and fleshed out in later phases.

**Gage:** A simple `ColorRect` with an inner `ColorRect`. Every `_process` frame it sets `inner.size.x = outer.size.x * (stat.val / stat.max_val)`. It connects to the player's stat by string name after the player is created (`Globals.player` set).

**NotifContainer:** A `VBoxContainer` at the top of the screen. `add_notif(text)` duplicates a `Label` template, animates it in with a tween, and removes it after 3 seconds. Max 15 visible at once — oldest is removed first.

#### Checklist
- ⬜ `scene/game.tscn` — Root `Node2D` with `StateManager` + `HUD` (CanvasLayer)
- ⬜ `scene/states/state_manager/state_manager.gd` — stack array, `push_state()`, `pop_state()`, `add_overlay_state()`, `remove_overlay_state()`, dissolve transition using `create_tween()`
- ⬜ `scene/states/menu_state/menu_state.gd` + `.tscn` — title label, New Game button, Continue button (hidden if no save); on New Game: create GameState and push; on Continue: create GameState, set `load_existing = true`, push
- ⬜ `scene/states/game_state/game_state.gd` + `.tscn` — `new_game()`: instantiates Player + DayNightCycle + HotBar, adds to MapManager; `continue_game()`: calls `Serialize.load_game()`; 10s Timer → `Serialize.save_game()`; enables/disables `Pathfinder.set_physics_process()`
- ⬜ `scene/states/loading_state/loading_state.gd` + `.tscn` — overlay spinner; pauses tree on enter; watches `Globals.loading_blocks_count` in `_process`; removes self when count = 0
- ⬜ `scene/states/pause_state/pause_state.gd` + `.tscn` — pause/unpause tree; Resume and Quit buttons
- ⬜ `scene/states/map_state/map_state.gd` + `.tscn` — full screen map view with player dot; touch drag to pan; Close button
- ⬜ `scene/states/game_over_state/game_over_state.gd` + `.tscn` — Revive and Main Menu buttons; calls `Serialize.save_game()` on enter
- ⬜ `scene/hud/hud.gd` + `hud.tscn` — CanvasLayer layer 2; typed `@onready` refs to all sub-nodes; `inventory_panel`, `loot_panel`, `item_info`, `craft_panel`, `camera_effect`, `status_effect_icons`, `info_panel`, `notifs`, `hotbar_container`, `minimap`
- ⬜ `scene/hud/gage/gage.gd` + `.tscn` — `ColorRect` with inner `ColorRect`; `stat_name: String` export; connects to player stat each frame check
- ⬜ `scene/hud/notif_container/notif_container.gd` + `.tscn` — `VBoxContainer`; `add_notif(text)`: clone label template, tween alpha in/out, max 15 notifs
- ⬜ `scene/hud/calendar/calendar.gd` + `.tscn` — Label; connects to `day_night_cycle.day_started` signal; increments displayed day
- ⬜ Verify: game opens to menu, New Game transitions to empty world, Escape opens pause, Resume returns to game

---

### PHASE 4 — Map & World

#### Plan
This phase creates the scrolling open world made of dynamically loaded map chunks. By the end you can run the player around the world and see chunks load/unload as you cross region boundaries.

**Chunk system design:** The world is a 5×5 grid of regions. Each region is `BLOCK_SIZE` (3200 units) wide and tall. The `World` node places 25 `RegionSensor` Area2D nodes at their respective grid offsets at startup. When the player (or any body) enters a sensor, it loads that region's `block.tscn` in a background thread. When the player exits, the block is freed.

Each `block.tscn` is a self-contained pre-built scene containing a `TileMap`, `NavigationRegion2D`, static environment objects (trees, benches, fences), and spawner nodes. In Godot 4, `NavigationRegion2D` bakes its navigation polygon automatically when added to the scene — we trigger a rebake via `NavigationServer2D.region_bake_navigation_polygon()` after the block's obstacles are all in place.

**Loading sequence:**
1. Player crosses into sensor → sensor starts thread loading `block.tscn`
2. `Thread` calls `ResourceLoader.load()` on the block scene
3. On thread done → `call_deferred("_on_block_loaded", packed_scene)` → instantiate + add to scene tree
4. `Globals.loading_blocks_count` decrements when block is ready
5. `LoadingState` removes itself when count = 0

**Navigation polygon generation:** After adding the block, iterate all nodes in group `"obstacle"` within that block. Build a `NavigationPolygon` from the block bounds, subtract polygon holes for each obstacle's collision shape, assign to `NavigationRegion2D`, bake.

**Procedural map (`map.gd`):** The TileMap uses a `TileSet` with these terrain tiles:
- ID 0: grass (fill)
- ID 1: road center
- ID 2: road shoulder
- ID 3: pavement

`generate_road(size, width)` picks random points on the grid, connects them with L-shaped paths, then places houses along roadsides. `place_house(pos, rotated)` checks if the tile at that position is grass (not yet occupied) before instantiating a house scene.

**MapManager** is the parent node for the World and all dynamically spawned entities (enemies, drops, sounds). It exposes:
- `spawn_sound(origin, radius)` — creates a temporary `Area2D` circle that zombies react to
- `spawn_drop_items(items_data, position)` — rolls each item's rarity%, creates `DropItem` nodes

**Zone system:** `Zone` is an `Area2D` placed in block scenes. It connects to `DayNightCycle.day_started` only when visible on screen (optimization). Each day it spawns enemies and loot within its bounds.

#### Checklist
- ⬜ `autoloads/utils.gd` — `import_data(path)` using `FileAccess` + `JSON.parse_string()`, `filter(list, key)`, `get_files(path)` using `DirAccess`, `file_exists(path)`, `get_prop(obj, dot_path)`, `find_node_descendants_in_group(node, group)`
- ⬜ `scene/maps/map_manager/map_manager.gd` + `.tscn` — Node2D; instantiates `world.tscn` as child; `spawn_sound(origin, radius)`, `spawn_drop_items(items_data, pos)`
- ⬜ `scene/maps/world.gd` + `world.tscn` — Area2D; in `_ready()` creates 25 RegionSensor nodes at correct `BLOCK_SIZE * grid_offset` positions; `on_map_load()` called by GameState after player added; `map_loaded(block)` decrements `Globals.loading_blocks_count`
- ⬜ `scene/maps/region_sensor/region_sensor.gd` — Area2D per chunk; `_on_body_entered()` starts load thread; `_on_body_exited()` frees block; `_generate_nav_polygon()` bakes NavigationRegion2D from obstacle group; `_on_block_child_entered_tree()` calls `Serialize.load_region(name)`; sets `Globals.cur_region`
- ⬜ `scene/maps/map.gd` — TileMap extending Node2D; `draw_grass(size)`, `generate_road(size, width)`, `connect_points(p1, p2)` L-shaped road drawing, `generate_path(path, width)`, `place_house(point, offset, rotated)` — all using Godot 4 `TileMap.set_cell(layer, coords, source_id, atlas_coords)`
- ⬜ Set up `TileSet` resource with grass, road center, road shoulder, pavement tiles (placeholder colors are fine for now)
- ⬜ `scene/maps/zone/zone.gd` — Area2D; connects to `day_started` on screen enter, disconnects on screen exit; `spawn_enemies()`, `spawn_loots()` each day
- ⬜ Create 25 `block.tscn` stub files (one per region directory) — each is a `Node2D` with a `TileMap` child filled with grass tiles and a `NavigationRegion2D`
- ⬜ Verify: run game, walk player in cardinal directions, watch chunks load/unload (use print statements or visible chunk borders)

---

### PHASE 5 — Behavior Tree + Pathfinder

#### Plan
The enemy AI is driven by a custom behavior tree (BT). This was the most elegant part of the original codebase and we are recreating it faithfully with Godot 4 syntax. The BT runs entirely on the main thread each frame but pathfinding requests are offloaded to a background thread.

**Behavior Tree architecture:**
- `Task` (Node) — base class. Holds status enum (FRESH, RUNNING, FAILED, SUCCEEDED, CANCELLED). `run(delta)` is called every frame while the task is active. Leaf nodes call `success()`, `fail()`, or `running()` to report their result. Composite and Decorator nodes override `child_success()`, `child_fail()`, `child_running()` to implement their logic.
- `Leaf` (extends Task) — stores `agent` ref. No child iteration in `start()`.
- Composites process children one at a time (Sequence, Selector) or all at once (Parallel).
- Decorators wrap a single child and modify its result.

**Why Tasks are Nodes (not Resources):** Being Nodes lets us assemble behavior trees visually in the Godot editor by adding child nodes under a root Task. The factory just calls `.duplicate()` on a preloaded BT scene. This is exactly how it was done in the original.

**Assembled BT trees (saved as .tscn):**
```
WanderAI (Selector)
└── Sequence
    ├── FindDestination (Leaf)     — picks random wander point
    ├── RequestPath (Leaf)         — enqueues to Pathfinder
    ├── Repeat
    │   └── GeneratePath (Leaf)   — waits (running) until path arrives
    └── UntilFail
        └── NavigatePath (Leaf)   — runs until path finished or opponent found

BasicAI (Selector)
├── Sequence (combat branch)
│   ├── HasOpponent
│   ├── Selector
│   │   ├── Sequence (attack in range)
│   │   │   ├── IsOpponentInRange
│   │   │   ├── IsAttackCooldown
│   │   │   └── AttackOpponent
│   │   └── Sequence (chase)
│   │       ├── RequestPath
│   │       ├── Repeat → GeneratePath
│   │       └── UntilFail → NavigatePath
└── [WanderAI subtree]

ChaseAI (Sequence)
├── FindOpponent (always sets Globals.player as target)
└── [BasicAI combat branch]
```

**Pathfinder singleton:** Maintains a queue of `{agent, from, to}` dicts. Every 0.5 seconds a `Thread` processes the entire queue: for each entry it calls `NavigationServer2D.map_get_path(map_rid, from, to, optimize)`, converts the result to a `PackedVector2Array`, and calls `agent.generate_path(path)` via `call_deferred`. The thread is only active during GameState (`set_process(false)` otherwise).

**Godot 4 nav note:** `NavigationServer2D.map_get_path()` can be called from a thread safely. Get the map RID via `get_world_2d().navigation_map`.

#### Checklist
- ⬜ `ai/behavior_tree/task.gd` — Node base: `enum Status {FRESH, RUNNING, FAILED, SUCCEEDED, CANCELLED}`; `status`, `control` (parent task), `agent`; `run(delta)`, `start(agent)` recursively inits children, `cancel()`, `success()`, `fail()`, `running()`, `child_success()`, `child_fail()`, `child_running()`
- ⬜ `ai/behavior_tree/leaf.gd` — extends Task; `start(agent)` stores agent only (no child loop)
- ⬜ `ai/behavior_tree/composites/sequence.gd` — runs children left to right; `child_success` → advance; `child_fail` → fail self
- ⬜ `ai/behavior_tree/composites/selector.gd` — runs children left to right; `child_fail` → advance; `child_success` → succeed self
- ⬜ `ai/behavior_tree/composites/parallel.gd` — runs all children simultaneously; configurable success/fail policy
- ⬜ `ai/behavior_tree/composites/random_sequence.gd` + `random_selector.gd` — shuffle children order before running
- ⬜ `ai/behavior_tree/decorators/invert.gd`, `repeat.gd`, `until_fail.gd`, `until_success.gd`, `limit.gd`, `skip.gd`, `always_succeed.gd`, `always_fail.gd`, `always_run.gd`, `wait.gd` — 10 decorators
- ⬜ `ai/leaves/find_opponent.gd` — calls `agent._on_view_body_entered(Globals.player)`; always succeeds
- ⬜ `ai/leaves/find_destination.gd` — sets `agent.destination` to random point within wander radius; succeeds
- ⬜ `ai/leaves/has_opponent.gd` — succeeds if `agent.opponent` not empty
- ⬜ `ai/leaves/is_opponent_on_view.gd` — scans vision RayCasts; if Player found, triggers aggro; fails/succeeds accordingly
- ⬜ `ai/leaves/is_opponent_nearby.gd` — checks distance to opponent vs `aggression_range` stat
- ⬜ `ai/leaves/is_opponent_in_range.gd` — checks if `attack_range` RayCast is colliding
- ⬜ `ai/leaves/is_attacking.gd` — returns RUNNING if `agent.cur_attack.is_attacking(delta)`, else FAILED
- ⬜ `ai/leaves/is_attack_cooldown.gd` — manages `agent.attack_timer`; succeeds when cooldown elapsed
- ⬜ `ai/leaves/choose_attack.gd` — calls `agent.choose_attack()`; always succeeds
- ⬜ `ai/leaves/attack_opponent.gd` — calls `agent.attack()`; succeeds
- ⬜ `ai/leaves/request_path.gd` — calls `Pathfinder.request_path(agent)`; sets `agent.is_path_generated = false`; succeeds
- ⬜ `ai/leaves/is_path_generated.gd` — succeeds if `agent.is_path_generated`; else fails
- ⬜ `ai/leaves/generate_path.gd` — returns RUNNING until `agent.is_path_generated`; then succeeds
- ⬜ `ai/leaves/navigate_path.gd` — succeeds while path is non-empty and walking; fails when path done or opponent found
- ⬜ `ai/leaves/is_blocked.gd` — checks `agent.blocked_timer`; succeeds (meaning IS blocked) if stuck
- ⬜ `ai/leaves/is_visible.gd` — checks `agent.visible`
- ⬜ `ai/leaves/always_running.gd`, `always_success.gd` — utility leaves
- ⬜ Assemble `ai/trees/wander_ai.tscn`, `basic_ai.tscn`, `chase_ai.tscn` as scene trees of BT nodes
- ⬜ `autoloads/pathfinder.gd` — queue array; `request_path(agent)` enqueues; 0.5s timer starts thread; thread calls `NavigationServer2D.map_get_path()` for each entry; delivers via `agent.call_deferred("generate_path", path)`; `set_process(false)` by default — GameState enables it

---
### PHASE 6 — Enemy System

#### Plan
Enemies are the core challenge. Each zombie is an autonomous agent driven by a behavior tree, navigating the world via async pathfinding, and cooperating with nearby zombies via a herd aggro system.

**Enemy scene structure:**
```
Enemy (CharacterBody2D)
├── Collider (CollisionShape2D)       — capsule shape
├── Body (Node2D)                      — loaded dynamically from enemy JSON data
│   ├── Lower (Node2D + AnimationPlayer) — legs: idle, run_straight, run_side
│   └── Upper (Node2D + AnimationPlayer) — torso: idle, hurt, attack
├── Vision (Node2D)                    — array of RayCast2D at ANGLE_BETWEEN_RAYS intervals
├── AttackRange (RayCast2D)            — used by IsOpponentInRange leaf
├── BlockerSensor (RayCast2D)          — detects walls/obstacles for stuck detection
├── HitBox (Area2D + CollisionShape2D) — attack hitbox, enabled by animation
├── BodySensor (Area2D + CollisionShape2D) — herd aggro propagation radius
├── Pickup (Area2D)                    — detects player entering melee range
└── Notifier (VisibleOnScreenNotifier2D)
```

**Path following:** Enemy receives a `PackedVector2Array` from `Pathfinder`. It follows `path[0]`, pops it when within 10 units. Rotates toward direction each frame at `angle_speed`. If position hasn't changed for 1 second (stuck), clears path and requests a new one.

**Vision system:** A fan of `RayCast2D` nodes spread at `ANGLE_BETWEEN_RAYS` intervals. Each frame, if any ray hits the player layer, aggro is triggered. Rays are disabled when enemy already has an opponent (no need to scan) or is off-screen (optimization).

**Herd aggro:** When a zombie spots the player, `_on_body_sensor_body_entered` fires for nearby idle enemies — they receive the player target without needing to see them themselves. This creates the realistic effect of one zombie alerting a group.

**On-screen/off-screen optimization via VisibleOnScreenNotifier2D:**
- Entered screen → add to `"serializable"` group, set `visible = true`, enable vision
- Exited screen (no opponent) → remove from group, disable process/physics_process, disable vision
- Exited screen (has opponent) → keep processing but hide (still chasing)

**Attack system:** Each enemy has an `attacks[]` array loaded from JSON. An `Attack` is a Resource (not a Node). On aggro, `choose_attack()` randomly picks one and sets it as `cur_attack`. The attack resource drives itself: `use()` sets up the attack geometry, `attack()` plays the animation, `is_attacking(delta)` returns true while active, `landed()` iterates `enemies_able_to_attack` and applies damage + status effects.

**Two attack types:**
- `MeleeAttack` — sizes a hitbox CollisionShape2D, plays "attack" animation. HitBox overlap array feeds `landed()`.
- `ChargeAttack` — creates an `ApplyForce` status effect pushing toward the player. The charge dissipates via friction. On next attack cycle, charges again.

**Serialization strategy:** Only on-screen enemies (those in `"serializable"` group) are saved. This is acceptable because off-screen enemies without opponents are essentially idle and can be re-spawned by the house/zone system on next load.

#### Checklist
- ⬜ `scene/entities/enemies/enemy.gd` — extends Entity: `opponent[]`, `path[]`, `behavior` (BT root), `attacks[]`, `cur_attack`, `attack_timer`, `enemies_able_to_attack[]`, `is_path_generated`, `destination`, `last_position`, `blocked_timer`; `init()` loads body, inits stats, picks growl, assigns BT, creates attacks; `_physics_process()` → `move(delta)`; `_process()` → `behavior.run(delta)` + `growl()`; `generate_path(path)`, `move(delta)`, `hurt(dmg, opponent)`, `dead()`, `choose_attack()`, `attack()`, `set_enable_vision(enabled)`, `get_destination()`
- ⬜ `scene/entities/enemies/enemy.tscn` — full node hierarchy as above
- ⬜ `scene/entities/enemies/body/body.tscn` + `body.gd` — Node2D with lower/upper sprite AnimationPlayers; exposed `lower_body_animation` and `upper_body_animation` references
- ⬜ `scene/entities/enemies/attacks/attack.gd` — base Resource: `agent`, `data`; `use()`, `attack()`, `is_attacking(delta)`, `landed()`; `landed()` iterates `agent.enemies_able_to_attack`, applies status effects via `Factory.status_effect.create()`, calls `body.hurt(damage, agent)`
- ⬜ `scene/entities/enemies/attacks/melee_attack.gd` — `use()`: size hitbox from `attack_range * size` stats; `attack()`: play "attack" animation; `is_attacking()`: animation still playing
- ⬜ `scene/entities/enemies/attacks/charge_attack.gd` — `use()`: extend attack range to vision_height/2, re-enable body collider; `attack()`: create `ApplyForce` effect toward opponent, disable collider; `is_attacking(delta)`: run force tick, return true while active; on force done: call `use()` to prep next charge
- ⬜ `autoloads/factory/enemy_factory.gd` — reads `enemies.json`; preloads: Enemy.tscn, body scenes per enemy type, BT scenes (wander/basic/chase), growl AudioStreams, attack script classes; `create(name, x, y, rotation)`, `create_many(count, data)`
- ⬜ Connect `VisibleOnScreenNotifier2D` signals: `screen_entered` → add to serializable group, enable process; `screen_exited` → conditionally disable
- ⬜ `scene/entities/enemies/spawner/horde.gd` — Area2D; on `_ready()` spawns up to 100 enemies scattered within radius
- ⬜ `scene/entities/enemies/spawner/ambush.gd` — triggered arena: locks player in bounds, keeps spawning enemies until timer ends and all enemies cleared
- ⬜ Enemy serialization: `serialize(data)` → appends to `data["map"]`; `deserialize(saved)` → restores position, rotation, stats, behavior, attacks
- ⬜ Verify: spawn one enemy, it wanders; bring player nearby, it chases; player shoots it, it dies and drops item

---

### PHASE 7 — Item System

#### Plan
Items are `TextureRect` UI nodes — they live in inventory slots as visual objects, not in the game world. Each item subtype overrides `use()` with its specific behavior. The item's appearance (icon texture, quantity label, cooldown sweep) is self-managed.

**Item class hierarchy:**
```
Item (TextureRect)
├── ConsumableItem     — use: apply modifiers + status effects to player
├── CraftableItem      — use: check recipe → start cooldown → produce item
├── EquipmentItem      — use: swap into equipment slot → spawn weapon/torch in world
├── PlacableItem       — use: check recipe → show building preview
└── ResourceItem       — no use(); just stacks
```

**Cooldown sweep:** A `TextureProgress` node overlaid on the item icon. Its `value` (0–100) decreases over time. While `value > 0`, `use()` is blocked. This provides the visual feedback for weapon fire rate, crafting timer, and consumable cooldowns.

**`get_info()` design:** Each item subtype builds a dict describing its properties for the info panel. Sections include STATS, RECIPE, NEED (missing ingredients), EFFECTS, SKILLS (on-hit status effects). The info panel reads this dict and renders typed rows.

**ItemFactory:** Reads `items.json` on startup. Builds two dicts:
- `static_data[id]` — shared, never changes (name, icon path, type, recipe, effects config)
- `dynamic_data[id]` — template for per-instance data (quantity, current stats, cooldown state)

`create(id, quantity, type)` deep-copies `dynamic_data[id]`, sets quantity, instantiates the correct Item subclass scene, returns it. The `type` override is for cases where the same item JSON entry is used as multiple item types.

**EquipmentItem special init:** On creation, `init()` instantiates the weapon/torch scene from `EquipmentFactory`, stores it as `data.object`. The scene is not added to the tree yet — it gets added by `Player.set_weapon()` when equipped. Also creates `Stat` resources for weapon stats (damage, range, accuracy, ammo) from the item's dynamic data.

#### Checklist
- ⬜ `scene/ui/items/item.gd` — TextureRect base: `static_data{}`, `data{}`, `sweep` (TextureProgress); `_process(delta)` ticks cooldown sweep; `set_quantity(v)`, `add_item_quantity(v)` respects `stock_size`, returns remainder; `use()` checks cooldown; `get_info()` returns base dict; `serialize()`, `deserialize()`
- ⬜ `scene/ui/items/consumable_item.gd` — `use()`: decrement quantity; apply `data.modifiers[]` to player stats via `Factory.stat_modifier.create()`; apply `data.add_status_effects[]` and remove `data.remove_status_effects[]`
- ⬜ `scene/ui/items/craftable_item.gd` — `use()`: `can_craft()` checks inventory for all recipe ingredients; if yes, starts cooldown timer; `_on_cooldown_finished()` consumes ingredients from inventory, calls `Factory.item.create()` for output, puts in inventory
- ⬜ `scene/ui/items/equipment_item.gd` — `init()`: calls `Factory.equipment.create(parent, self)`, stores scene in `data.object`; creates stat Resources from dynamic data; processes `side_effects[]` (e.g. slow player while firing); `use()`: puts self into equipment slot
- ⬜ `scene/ui/items/placable_item.gd` — `use()`: `can_craft()` checks recipe; if yes, calls `Globals.player.placable.build(static_data)`
- ⬜ `scene/ui/items/resource_item.gd` — no `use()` override; inherits stacking from base
- ⬜ `autoloads/factory/item_factory.gd` — reads `items.json`; preloads icon textures; `create(id, qty, type)` → deep copy data + instantiate correct scene; `deserialize(saved)` → recreate item from save dict
- ⬜ Item info panel (`scene/ui/items/item_info/`) — reads `item.get_info()` dict; renders sections: name, description, stats rows, recipe rows (with have/need counts), effects list
- ⬜ Verify: create a consumable and equipment item in code, call `use()` on each, confirm correct behavior

---

### PHASE 8 — Inventory System

#### Plan
The inventory is a grid of `Slot` nodes. Items live in slots as child nodes. The `InventoryManager` singleton handles all drag-and-drop interaction for touch screens.

**Slot:** A `NinePatchRect` that holds 0 or 1 Item child. `put_item(item)` tries to stack (if same id and not full) then places in empty slot. `pick_item()` removes and returns the item. `is_full()` checks if item quantity equals `stock_size`.

**Inventory grid:** A `GridContainer`-based `Control`. The `size` property setter creates/destroys `Slot` nodes to match. `put_item(item)` scans slots: first tries stacking into existing same-id slots, then fills the first empty slot. Returns any remainder if all slots are full.

**Three inventory types used by player:**
1. `inventory` (36 slots) — main bag
2. `craftable_inventory` (24 slots, CraftInventory type) — shows craftable blueprints
3. `placable_inventory` (24 slots, CraftInventory type) — shows buildable blueprints

`CraftInventory` extends `Inventory` with one override: `put_item` rejects duplicate item IDs (each blueprint appears only once).

**Player inventory panel:** A special panel with pre-placed `EquipmentSlot` nodes for weapon, hand item, and armor. When a weapon slot's item changes, it signals `Globals.player.set_weapon()`.

**InventoryManager (touch drag-and-drop):**
- Tracks `item_in_hand`, `prev_slot`, `cur_slot`
- Touch down on slot: start 0.4s long-press timer; if held → show item info panel; if released early → might be tap
- Touch drag: detach item from slot, follow finger
- Touch release on slot: stack/swap logic
- Double-tap: `slot.use_item()`
- All interaction goes through this single manager node — individual slots don't handle input directly

**Panel (Window):** A floating `Control` panel. `add_inventory(inv)` reparents the inventory `GridContainer` into the panel's scroll container. Multiple inventories can be shown in the same panel (e.g. the crafting table shows both craftable and placable inventories).

#### Checklist
- ⬜ `scene/ui/inventory/slot.gd` — NinePatchRect: `item` ref, `set_item()`, `pick_item()`, `put_item(item)`, `use_item()`, `is_full()`, `item_changed` signal
- ⬜ `scene/ui/inventory/inventory.gd` — Control + GridContainer: `size` setget, `columns`, `add_item(item)`, `put_item(item)`, `get_item(id)`, `is_full()`, `serialize()`, `deserialize()`; creates Slot children dynamically
- ⬜ `scene/ui/inventory/craft_inventory.gd` — extends Inventory; `put_item()` rejects if same-id item already present
- ⬜ `scene/ui/inventory/equipment_slot.gd` — extends Slot: `type` export; `put_item()` only accepts items matching type; emits `item_changed` signal with old + new item
- ⬜ `scene/ui/inventory/weapon_slot.gd` — extends EquipmentSlot; type = "weapon"
- ⬜ `scene/ui/inventory/loot_slot.gd` — extends Slot; for loot containers (chests)
- ⬜ `scene/ui/inventory/panel.gd` — Control: `add_inventory(inv)`, `show()`, `close()`; ScrollContainer inside
- ⬜ `scene/ui/inventory/player_inventory_panel.gd` — extends Panel; pre-placed hand/armor/weapon EquipmentSlots; `_on_weapon_slot_item_changed(old, new)` → `Globals.player.set_weapon(new)`; `_on_hand_slot_item_changed(old, new)` → `Globals.player.set_hand_item(new)`
- ⬜ `scene/ui/inventory/inventory_manager.gd` — autoloaded Control; handles all touch/click input for every inventory slot in the scene; `_input(event)`: tracks press position, drag, release; `update_slot()` handles stack/swap; long-press timer shows item info
- ⬜ `autoloads/utils.gd` additions — `create_inventory(data, type)`, `deserialize_inventory(saved_data)`, `create_item(inventory, data)` (handles overflow recursively)
- ⬜ Verify: open inventory panel, drag item between slots, drag to equip slot, double-tap to use consumable

---

### PHASE 9 — Weapons & Combat

#### Plan
Combat is the core gameplay loop. The player uses weapons (ranged or melee) to kill zombies. Weapons live as Node2D children of the player's `WeaponContainer`. They are created by `EquipmentFactory` and managed by `EquipmentItem`.

**Weapon base (`weapon.gd`):** Holds `is_pressed` (fire button held), `parent` (Player), `item` (EquipmentItem), `data` (weapon stats dict). The `_process(delta)` loop runs `side_effects` — persistent effects active while holding the weapon (e.g. machine gun slows the player's move speed). `hit(body)` applies on-hit status effects and calls `body.hurt(damage)`, then grants XP to player.

**Ranged weapon flow:**
1. Fire button pressed → `is_pressed = true`
2. Each `_process`: if `is_pressed` and cooldown elapsed → `fire(delta)`
3. `fire()`: play gunshot sound, create `RayCast2D` with spread from `fire_accuracy` stat, check collision
4. If hit: call `hit(body)`, decrement ammo, update weapon panel display
5. If `ammo.val == 0`: enter reload mode, show cooldown bar, tick `reload_duration` timer
6. Reload done: pull ammo from player inventory or hotbar

**Melee weapon flow:**
1. Fire button pressed → `is_pressed = true`
2. `_process`: if pressed and cooldown elapsed → play "melle_attack" animation on upper body
3. Animation track marker "attack_landed" → enable hitbox `CollisionShape2D` via `set_deferred("disabled", false)`
4. `_on_hitbox_body_entered(body)` → `hit(body)`
5. Animation track marker "attack_finished" → disable hitbox, start cooldown

**Upper body animation:** The `UpperBodyAnimation` script wraps the player's upper AnimationPlayer and emits `attack_landed` / `attack_finished` signals at specific animation keyframes. Weapons connect to these signals on `init()`.

**Projectile visual:** A `Line2D` with two points (origin, hit point or max range). On spawn: plays a short "fired" animation (fade out), then `queue_free()`. It's purely cosmetic — actual hit detection is done by `RayCast2D` in the same frame.

**Torch:** Extends `PointLight2D` (Godot 4 equivalent of `Light2D`). Sets `texture_scale` from the item's size stat value.

**Equipment factory:** Maps JSON `script_name` strings to preloaded weapon scenes:
```
"pistol" → res://scene/entities/items/weapons/range/pistol.tscn
"rifle"  → res://scene/entities/items/weapons/range/rifle.tscn
"melle"  → res://scene/entities/items/weapons/melee/melee.tscn
"torch"  → res://scene/entities/items/hand_items/torch.tscn
```

#### Checklist
- ⬜ `scene/entities/items/weapons/weapon.gd` — Node2D base: `is_pressed`, `last_fired`, `parent`, `item`, `data`; `init(parent, item)` sets refs and connects to upper body animation; `hit(body)` applies status effects + calls `body.hurt()` + `parent.data.stats.level.set_val(xp_modifier)`; `_process(delta)` runs side effects; `recompute_stats()`
- ⬜ `scene/entities/items/weapons/range/range_weapon.gd` — extends Weapon: `fire(delta)` at attack_speed rate; `create_projection()` RayCast2D with fire_accuracy spread; plays SFX; creates projectile Line2D; decrements ammo; calls `hit()`; `reloading(delta)` ticks reload_duration toward max, shows info panel cooldown; `_on_reload_btn_pressed()` pulls ammo from inventory; `get_info_panel_text()` returns ammo string
- ⬜ `scene/entities/items/weapons/range/pistol.tscn`, `rifle.tscn`, `machine_gun.tscn` — minimal scenes inheriting RangeWeapon script
- ⬜ `scene/entities/items/weapons/melee/melee.gd` — extends Weapon: `_process()` plays attack animation on press; hitbox enable/disable on animation markers; `_on_hitbox_body_entered(body)` → `hit(body)`
- ⬜ `scene/entities/items/weapons/melee/melee.tscn` — Node2D + HitBox (Area2D + CollisionShape2D, starts disabled)
- ⬜ `scene/entities/objects/projectile/projectile.gd` + `.tscn` — Line2D: on `_ready()` play "fired" animation (tween alpha 1→0) then `queue_free()`
- ⬜ `scene/entities/items/hand_items/torch.gd` + `.tscn` — extends PointLight2D; `init(parent, item)`: `texture_scale = item.data.stats.size.val`
- ⬜ `autoloads/factory/equipment_factory.gd` — dict of script_name → preloaded scene; `create(parent, item)` instances scene, calls `init(parent, item)`, returns node
- ⬜ `scene/entities/player/upper_body_animation.gd` — AnimationPlayer wrapper; emits `attack_landed` and `attack_finished` at animation keyframe calls; on `attack_finished` replays weapon idle animation type
- ⬜ `scene/hud/weapon_panel/weapon_panel.gd` + `.tscn` — stack-based info display (weapon + nearby table can both show); shows icon, ammo text from `weapon.get_info_panel_text()`, cooldown progress bar
- ⬜ Verify: equip pistol from inventory, fire at enemy, enemy takes damage and dies; equip machete, swing, melee hitbox connects

---

### PHASE 10 — Placables & Building

#### Plan
Players can place objects (crafting tables, campfires) in the world by selecting them from the placable inventory. A preview ghost shows placement validity before confirming.

**Placement preview:** When `PlacableItem.use()` is called, `Player.placable.build(static_data)` is called. The placable preview node (always a child of the player) becomes visible, showing a semi-transparent sprite of the object. An `Area2D` detects overlaps:
- No overlaps: sprite tint = blue (valid)
- Any overlap: sprite tint = red (blocked)

A confirm button (or tap) on the preview calls `place()`:
1. Check recipe ingredients in inventory
2. Consume ingredients
3. Call `Factory.placable.create(static_data, global_position, rotation)`
4. Add to `Globals.cur_house.objects_container` if inside a house, else to `map_manager`
5. Hide preview

**Placable base:** All placed objects extend `StaticBody2D`. On `init()`: set sprite texture and scale from `static_data`. Has a health stat — when it reaches 0, the object is freed. Shows HP in the weapon info panel when player is nearby (uses the same stack-based weapon panel).

**Table (crafting table):** When player enters the table's Area2D:
- Show craft panel with `placable_inventory` (smithing recipes) and `craftable_inventory` (regular recipes)
- Repair button adds 10 HP via an `AddModifier`
Serializes to `regions` dict (persists per map region).

**Campfire:** Shows an interact button when player is nearby. No crafting functionality yet — placeholder for cooking system. Serializes to `others` (global save, not region-specific).

**Chest:** A `StaticBody2D` placed by the map generator near houses. On player proximity, opens a loot panel with preset items. These items were configured in the map block scene editor.

#### Checklist
- ⬜ `scene/entities/player/placable/placable.gd` — Node2D preview: `build(static_data)`: set sprite, show node; overlap Area2D changes tint; `place()`: consume recipe, `Factory.placable.create()`, add to world, hide; `cancel()`: hide
- ⬜ `scene/entities/placables/placable_base.gd` — StaticBody2D: `init(static_data, pos, rot)`; sprite texture/scale from data; health stat; `hurt(dmg)`, `health_stat_callback()` → free on 0; proximity Area2D → show/hide info in weapon panel; `serialize(data)`, `deserialize(saved)`
- ⬜ `scene/entities/placables/table/table.gd` + `.tscn` — extends Placable: on player enter → show craft panel with both inventories; repair button → add 10 HP; serializes to `data["regions"][cur_region]`
- ⬜ `scene/entities/placables/campfire/campfire.gd` + `.tscn` — extends Placable: proximity shows interact button; serializes to `data["others"]`
- ⬜ `autoloads/factory/placable_factory.gd` — dict of type_name → scene; `create(static_data, pos, rot)` instantiates, calls `init()`, returns node
- ⬜ `scene/entities/objects/chest/chest.gd` + `.tscn` — StaticBody2D: on player enter → show loot panel with preset `LootSlot` items; on exit → hide panel
- ⬜ Verify: select crafting table from placable inventory, see preview ghost, confirm placement, table appears in world; approach table, see craft panel open

---

### PHASE 11 — House System

#### Plan
Houses are the primary source of loot and indoor enemies. Each house is a pre-built static body with a roof that fades when the player enters, an interior collision shape, and a spawner that runs once per game day.

**Daily spawn:** Houses connect to `DayNightCycle.day_started` **only when visible on screen** (connected in `screen_entered`, disconnected in `screen_exited`). This avoids unnecessary signal processing for distant houses. Each day: spawn up to `capacity` enemies from the house's `enemies` JSON config, and scatter loot drops from the `loots` JSON config within the house bounds.

**Saving the day counter:** Each house saves only its `day` value to `data["update_only"]`. On load, `Serialize.deserialize_scene()` finds the existing house node and updates only the day field — it doesn't reinstantiate the scene. This is the `update_only` save category.

**Roof fade:** A separate `Roof` node (child of House) with its own `CollisionShape2D` detection area. When the player enters: `create_tween()` fades `modulate.a` from 1.0 to 0.0 over 0.3s. On exit: fades back. This gives the effect of the roof becoming transparent while inside.

**10 house variants:** Each is a unique `.tscn` file (House1–House10) with different tilemap layouts, sizes, and door positions. They all inherit the same `House` base script. Enemy and loot configs are set as exported string properties in the inspector.

**`cur_house` tracking:** When player enters a house body sensor, `Globals.cur_house = self`. When player exits, `Globals.cur_house = null`. This is used by the placable system to know whether to parent placed objects to the house's objects container or to the map.

#### Checklist
- ⬜ `scene/entities/houses/house.gd` — StaticBody2D: `@export capacity: int`, `@export enemies_json: String`, `@export loots_json: String`; `screen_entered` → connect to `day_started`; `screen_exited` → disconnect; `spawner(day)`: `spawn_enemies()` + `spawn_loots()` if day not already spawned; body entered/exited → `Globals.cur_house`; `serialize()` → `data["update_only"]`; `deserialize()` updates `day` only
- ⬜ `scene/entities/houses/roof.gd` — Node2D: detection Area2D; `body_entered` → tween alpha 0; `body_exited` → tween alpha 1
- ⬜ Create `house1.tscn` through `house10.tscn` — varied floor plans using TileMap; each has Roof node, ObjectsContainer node, interior collision
- ⬜ Verify: enter house, roof fades; enemies present (if any); day passes, new enemies spawn next visit

---

### PHASE 12 — Day/Night Cycle & World Events

#### Plan
Time drives nearly everything in the game — enemy night waves, house respawns, hunger drain, and the visual atmosphere. The `DayNightCycle` node is a `CanvasModulate` that tints the entire game viewport.

**180-second cycle:** 0–90s = day (full brightness), 90–180s = night (dark tint). An `AnimationPlayer` drives the `CanvasModulate.color` from white (1,1,1,1) at noon to dark blue-grey (0.15, 0.15, 0.3, 1) at midnight. At `time = 90`, the `day_started` signal is emitted. At night transition, the animation calls `spawn_enemy_wave()` via a CallMethod track.

**Shadow system:** Objects in the `"shadow"` group have a duplicate shadow sprite. Each `_process` frame, `DayNightCycle.day()` calculates the sun direction based on `time` (0–180 mapped to a sun arc angle) and sets each shadow sprite's `position` offset accordingly. This gives the illusion of a moving sun casting dynamic shadows.

**Night wave:** `spawn_enemy_wave()` spawns 100 enemies at random positions around the player (outside a minimum distance, within a maximum distance). This is a timed event tied to the animation track, not to every night — it fires once per night cycle.

**Minimap:** A `ColorRect` with a `SubViewport` or just a scaled-down camera render. The player dot is a small `Sprite2D` that tracks `Globals.player.global_position` relative to the minimap bounds each frame and rotates with the player. Block images (pre-rendered PNGs per chunk) re-render when the `rerender` signal fires (on chunk load).

**HotBar:** A horizontal row of inventory slots at the bottom of the screen. Serialized in `data["others"]` so items persist across sessions. The HotBar's items can be used directly by tapping them in the HUD.

#### Checklist
- ⬜ `scene/hud/day_night_cycle/day_night_cycle.gd` + `.tscn` — extends CanvasModulate: `time`, `speed` (default 1.0), `last_day`; `_process(delta)` advances time and wraps; AnimationPlayer drives color; `day()` calculates shadow offsets for all "shadow" group nodes; `spawn_enemy_wave()` spawns 100 enemies around player; emits `day_started` signal
- ⬜ `scene/hud/minimap/minimap.gd` + `.tscn` — ColorRect background + player Sprite2D dot; `_process` updates dot position and rotation; `rerender(block)` updates block image overlay
- ⬜ `scene/hud/hotbar/hotbar.gd` + `.tscn` — HBoxContainer of Slots; serializes slot contents to `data["others"]`; `deserialize()` restores items
- ⬜ `scene/hud/status_effects/status_effects.gd` + `stat_icon.gd` + `.tscn` — GridContainer of icons; `add_icon(se)` duplicates icon template; `remove_icon(se)` removes matching icon
- ⬜ `scene/hud/weapon_panel/weapon_panel.gd` + `.tscn` — stack-based: `add_item(item)`, `del_item(item)`; shows icon + text + cooldown bar for top-of-stack item
- ⬜ Verify: watch modulate change from bright to dark over 90s; night wave triggers; shadows shift direction during day

---

### PHASE 13 — Vehicle System

#### Plan
Vehicles are drivable `CharacterBody2D` nodes with physics that simulate real car handling. When the player enters a vehicle, the game seamlessly swaps from player control to vehicle control.

**Ackermann steering model:** Uses two virtual wheel positions (front and rear) to calculate turning. The vehicle body rotates the front wheel by `steering_angle` based on input, then computes the vehicle's angular velocity from the angle between front/rear wheel headings. This gives natural, realistic turning with a minimum turn radius.

**Physics:** `velocity = velocity.length() * forward_direction`. Acceleration: add `engine_power` along forward. Deceleration: apply friction + drag. Traction (high speed vs low speed) affects how much angular velocity is applied. Braking: apply `brake_power` opposing velocity.

**Embark/disembark:**
1. Player enters door Area2D → `Player` becomes invisible + collision disabled; `Vehicle` takes ownership via `Globals.current_controller` swap to `VehicleController`; camera attaches to vehicle
2. Disembark signal from controller → player re-enables, exits at vehicle door position, camera returns to player, `Globals.current_controller` swaps back

**Zone reparenting:** Same problem as enemies — when the vehicle crosses a chunk boundary, it may be a child of the wrong RegionSensor node. The same deferred `reparent()` trick is used: on `area_entered`, call `call_deferred("reparent")` which removes from current parent and adds to `map_manager`.

#### Checklist
- ⬜ `scene/entities/vehicles/vehicle.gd` + `.tscn` — CharacterBody2D: Ackermann steering simulation; `engine_power`, `friction`, `drag`, `brake_power`, `steering_angle`, `slip_speed`, `wheel_base`, `traction_fast`, `traction_slow`; door Area2D: `body_entered` → embark player; `_on_controller_use_disembark()` → disembark; zone boundary reparenting
- ⬜ `scene/entities/vehicles/vehicle_controller.gd` — Control node (same as player controller but vehicle-specific): touch right-drag → steer; keyboard up/down → accelerate/brake; disembark button; signals: `use_accelerate`, `use_brake`, `use_disembark`, `use_rotate_area_degrees`, `use_rotate_area_released`
- ⬜ Verify: approach vehicle, enter, drive around with controls, exit back to player control

---

### PHASE 14 — Save / Load System

#### Plan
The save system stores the entire game state as a single JSON file. It runs on a background thread to avoid freezing the game during the save operation.

**Save data categories:**
| Key | What it stores | How loaded |
|-----|---------------|------------|
| `player` | Player position, stats, inventory, equipped items | `create_and_deserialize_scene()` |
| `others` | HotBar slots, DayNightCycle time, Campfires | `create_and_deserialize_scene()` |
| `map` | All on-screen serializable enemies at save time | `create_and_deserialize_scene()` |
| `update_only` | Houses, Zones — only the `day` field | `deserialize_scene()` (updates existing node) |
| `regions` | Placed objects per region name (tables, etc.) | `load_region(name)` called by RegionSensor on load |

**Serialization contract:** Any node that should be saved adds itself to the `"serializable"` group (enemies do this on `screen_entered`). Every serializable node implements `serialize(data)` which appends its saved dict to the appropriate `data` key. `deserialize(saved)` rebuilds the node state from that dict.

**Threading:** `save_game()` starts a `Thread` that collects all serializable nodes, serializes them, and writes the JSON file. A 0.4s timer after the thread finishes calls `thread.wait_to_finish()` to clean up safely. The game continues running during the save.

**Load sequence:**
1. GameState calls `Serialize.load_game()` → recreates player + others
2. World's `on_map_load()` calls `Serialize.load_map()` → recreates enemies + updates houses
3. Each RegionSensor on block load calls `Serialize.load_region(name)` → recreates placed objects

**Godot 4 changes:** `FileAccess.open(path, FileAccess.WRITE)` instead of `File.new()`. `JSON.parse_string(text)` instead of `parse_json()`. `Thread.start(callable.bind(data))` instead of `Thread.start(self, "method", data)`. `call_deferred` still works the same.

#### Checklist
- ⬜ `autoloads/serialize.gd` — save structure `{player, others, map, update_only, regions}`; `save_game()` starts thread; `_saving_thread(data)` collects serializable group, serializes all, writes JSON via `FileAccess`; `saving_done()` timer cleans thread; `has_save_data()`, `load_game()`, `load_map()`, `load_region(name)`, `create_and_deserialize_scene(saved)`, `deserialize_scene(saved)`
- ⬜ Verify all entity `serialize()` / `deserialize()` implementations: Player, Enemy, HotBar, DayNightCycle, Table, Campfire
- ⬜ Full round-trip test: start game, move player, equip weapon, place table, save, quit, load — confirm everything restored correctly

---

### PHASE 15 — Polish & FX

#### Plan
This phase adds the juice — visual and audio feedback that makes combat feel satisfying and the world feel alive.

**Blood particles:** `CPUParticles2D` with directional burst. `ParticleFactory.create_blood(position, color)` instances a pre-configured blood scene at world position. Red for player, green for zombies.

**Camera shake:** On player `hurt()`, set `Globals.camera.shake = {timer: 0.2, intensity: 3}`. The Camera2D script applies a random offset each frame while `timer > 0`, decaying by delta.

**Health vignette:** A full-screen `ColorRect` with red modulate in HUD. When health < 50% max: `alpha = 0.6 * (1 - health_ratio)`, `scale = lerp(1.0, 2.0, 1 - health_ratio)`. This creates a closing red frame effect near death.

**Aggro notification:** A `Sprite2D` showing a `!` icon. Instantiated as child of Enemy on first aggro. Positions itself relative to camera rotation (always faces up in screen space). Frees after 1 second.

**Drop item burst:** `RigidBody2D` with a one-shot random impulse on spawn (`apply_impulse(random_direction * random_strength)`). Has a life timer (default 30s) after which it `queue_free()`.

**Footstep sounds:** `Player.spawn_sound()` creates a temporary `Area2D` circle. Any Enemy inside the circle that has no opponent will trigger aggro (calls `_on_view_body_entered(player)`). This simulates sound propagation without raycasting.

**SFX system:** `autoloads/sfx.gd` loads all audio files from `assets/sfx/` into a dict by filename. `play(type)` plays the AudioStreamPlayer, switching stream only when the type changes (avoids restarting the same sound).

#### Checklist
- ⬜ `autoloads/factory/particle_factory.gd` — `create_blood(position, color)`: instance blood CPUParticles2D, set color, add to map_manager, auto-free on finish
- ⬜ `scene/entities/objects/blood/blood.gd` + `.tscn` — CPUParticles2D: `emitting = true`, `one_shot = true`; connects `finished` → `queue_free()`
- ⬜ Camera shake — Camera2D script: `shake` dict property; `_process()` applies random `offset` while timer > 0, decays
- ⬜ Health vignette — `ColorRect` in HUD: `camera_effect`; updated in `Player.health_stat_callback()`
- ⬜ `scene/entities/objects/notif/notif.gd` + `.tscn` — Sprite2D with `!` texture: positions relative to camera; 1s Timer → `queue_free()`
- ⬜ `scene/entities/objects/drop_item/drop_item.gd` + `.tscn` — RigidBody2D: random impulse on ready; life Timer auto-free; `pick_item()` → add to player inventory, show pickup notif
- ⬜ `autoloads/sfx.gd` — loads all sfx from `assets/sfx/` into dict; `play(type)` manages AudioStreamPlayer
- ⬜ Footstep sound propagation — `Player.spawn_sound()` creates temporary Area2D circle; enemies in range trigger aggro
- ⬜ Zombie growl — in Enemy `_process()`: random chance check each frame; if not already playing, play growl sound
- ⬜ Verify: shoot enemy → blood splatter + camera shake; player hurt → red vignette appears; pick up item → notif shows

---

### PHASE 16 — Optimization & Mobile Readiness

#### Plan
The game targets mobile devices running 60 FPS with 20+ zombies on screen. Key optimizations from the original codebase are preserved and enhanced.

**Vision raycast culling:** Raycasts are expensive. Disable all vision rays when:
- Enemy already has an opponent (no need to search)
- Enemy is off-screen (`VisibleOnScreenNotifier2D.screen_exited`)
Re-enable when back on screen with no opponent.

**Process culling:** Off-screen enemies with no opponent are removed from `"serializable"` group and their `set_process(false)` + `set_physics_process(false)` are called. Their `VisibilityEnabler`-equivalent logic manually manages this via the notifier signals.

**Chunk management:** Only the 3×3 blocks centered on the player's current chunk are active. The outer ring (16 blocks) remain unloaded. This is enforced by the RegionSensor design.

**Pathfinding batch:** The Pathfinder processes ALL queued agents in a single 0.5s batch rather than requesting paths every frame per enemy. For 20 enemies, this reduces nav server calls from 1200/s to 40/s.

**Navigation polygon generation:** Called via `call_deferred()` after block add — doesn't block the main thread.

**Mobile testing:**
- Enable `project_settings/input_devices/pointing/emulate_touch_from_mouse` in dev
- Test touch joystick dead zone and sensitivity on real device
- Profile with Godot's built-in profiler; target < 5ms/frame physics, < 8ms/frame render

#### Checklist
- ⬜ Vision raycast on/off controlled by `set_enable_vision(enabled)` — called on opponent change and screen events
- ⬜ Enemy `set_process(false)` + `set_physics_process(false)` on screen exit (no opponent); re-enable on screen enter
- ⬜ Confirm only 9 chunks max are ever in scene tree simultaneously
- ⬜ Pathfinder batches all requests in single 0.5s thread cycle
- ⬜ NavRegion2D bake called via `call_deferred` (non-blocking)
- ⬜ Touch joystick: dead zone, max radius clamp, visual feedback circle
- ⬜ Profile with 20 enemies: confirm stable 60 FPS on mid-range Android target
- ⬜ Verify camera, input, and UI scale correctly across 16:9, 18:9, and 20:9 screens

---

### PHASE 17 — Content & Data

#### Plan
Port and verify all game data from the original project's JSON files. Add all weapon scenes, house variants, and status effects so the game has a complete content pass.

**items.json entries to port:**
- Consumables: bandage, bread
- Placables: crafting table, smithing table, campfire
- Hand items: torch
- Melee weapons: machete
- Ranged weapons: AMT AutoMag III (pistol), m13 (rifle), m14 (rifle), machine gun
- Resources: rifle ammo, machine gun ammo, wood, stone, cloth, gasoline, alcohol

**enemies.json entries to port:**
- normal zombie — wander behavior, melee attack, drops ammo/bandage
- charger zombie — basic behavior, charge attack, Open Wounds status effect (70%: 200s speed debuff + 20s bleed)

**Status effects to implement:**
- Open Wounds: SubtractModifier on health at rate; MultiplyModifier reducing move_speed for duration
- Inspire: AddModifier on move_speed for 2s (from bandage)
- Knockback: ApplyForce toward attacker direction (70% on most weapons)

**player.json starting inventory:** m13 + 999 rifle ammo, machine gun + 999 MG ammo, machete, 20x bandage, 20x bread, 2x each resource, torch. Placable inventory: crafting table, campfire.

#### Checklist
- ⬜ Port and verify `items.json` — all 15+ item entries with correct types, recipes, stats, effects
- ⬜ Port and verify `enemies.json` — normal + charger with full attack configs and status effect data
- ⬜ Port and verify `player.json` — base stats and full starting inventory
- ⬜ All weapon .tscn files: pistol, rifle (m13/m14), machine_gun, machete — each with correct node hierarchy and script
- ⬜ Status effects fully wired: Open Wounds, Inspire, Knockback — test each triggers and expires correctly
- ⬜ Recipe chains verified: torch → bandage → crafting table → campfire → smithing table → m13
- ⬜ 10 house .tscn variants with varied layouts and enemy/loot config set in inspector
- ⬜ All 25 map block .tscn files filled with proper road/building content (not just grass stubs)
- ⬜ Full gameplay test: new game → survive 3 nights → craft all items → place all placables → save + load

---

### FUTURE PHASES (Post-Core)
- ⬜ Additional zombie types (crawler, tank, spitter — new enemy JSON entries + BT variants)
- ⬜ Multiplayer co-op (Godot 4 ENet/WebRTC)
- ⬜ Map editor / custom block builder tool
- ⬜ More vehicle types (motorcycle, truck)
- ⬜ Skill tree / perks system on level-up
- ⬜ Quest / mission system
- ⬜ Safe zones / NPC traders
- ⬜ Advanced crafting tiers (workbench → forge → lab)
- ⬜ Mobile Android APK packaging + signing

---

## Key Implementation Reference

### CharacterBody2D Movement (Godot 4)
```gdscript
# Assign velocity then call move_and_slide() — no delta needed
velocity = direction * speed + applied_force
move_and_slide()
# applied_force decays each frame via ApplyForce stat effect
```

### Threaded Operations
```gdscript
# Starting a thread
var thread := Thread.new()
thread.start(_my_method.bind(argument))

# Cleaning up (must call from main thread)
thread.wait_to_finish()
```

### Signal Connections
```gdscript
# Basic connection
some_signal.connect(_on_callback)

# With bound arguments
some_signal.connect(_on_callback.bind(extra_arg))

# One-shot (auto-disconnects after first fire)
some_signal.connect(_on_callback, CONNECT_ONE_SHOT)
```

### Await (replaces yield)
```gdscript
await get_tree().process_frame
await animation_player.animation_finished
await get_tree().create_timer(1.0).timeout
```

### NavigationAgent2D (Godot 4 nav API)
```gdscript
# Set target
nav_agent.target_position = destination

# In _physics_process:
if nav_agent.is_navigation_finished():
    return
var next_pos = nav_agent.get_next_path_position()
var direction = global_position.direction_to(next_pos)
velocity = direction * move_speed
move_and_slide()
```

### JSON I/O
```gdscript
# Read
var file := FileAccess.open("res://data/player.json", FileAccess.READ)
var data: Dictionary = JSON.parse_string(file.get_as_text())
file.close()

# Write
var file := FileAccess.open("user://savegame.json", FileAccess.WRITE)
file.store_string(JSON.stringify(data))
file.close()
```
