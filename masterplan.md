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
      - [Diagnosis: What Was Wrong With the Original](#diagnosis-what-was-wrong-with-the-original)
      - [The New Architecture: Industry Standard Approach](#the-new-architecture-industry-standard-approach)
      - [Architecture: 4 Classes Only](#architecture-4-classes-only)
      - [Dirty Flag Pattern (how caching works)](#dirty-flag-pattern-how-caching-works)
      - [Source Tracking (how buff/equipment removal works)](#source-tracking-how-buffequipment-removal-works)
      - [Stat Signals + StatBinding (decoupled side effects)](#stat-signals--statbinding-decoupled-side-effects)
      - [Solving the "val is a Dict" Problem (VisionStat, FireAccuracyStat)](#solving-the-val-is-a-dict-problem-visionstat-fireaccuracystat)
      - [Resources vs Nodes](#resources-vs-nodes)
      - [The `StatsComponent` Node (entity-facing API)](#the-statscomponent-node-entity-facing-api)
      - [Level Scaling](#level-scaling)
      - [Serialization](#serialization)
      - [JSON Data Format (for stat definitions)](#json-data-format-for-stat-definitions)
      - [File Map](#file-map)
      - [Checklist](#checklist-1)
    - [PHASE 2 — Entity Base + Player](#phase-2--entity-base--player)
      - [Plan](#plan-1)
      - [The Dead Town Movement Model (what we're recreating)](#the-dead-town-movement-model-what-were-recreating)
      - [Diagnosis: Problems With the Original](#diagnosis-problems-with-the-original)
      - [Architecture: Clean Separation of Concerns](#architecture-clean-separation-of-concerns)
      - [Movement System: Input Accumulator (replaces velocity stack)](#movement-system-input-accumulator-replaces-velocity-stack)
      - [Rotation: Two Input Sources, One Target](#rotation-two-input-sources-one-target)
      - [Body Counter-Rotation (the "world rotates" trick)](#body-counter-rotation-the-world-rotates-trick)
      - [Animation System: AnimationTree with BlendSpace2D](#animation-system-animationtree-with-blendspace2d)
      - [Controller Design: Interface Pattern](#controller-design-interface-pattern)
      - [Entity Base (`entity.gd`)](#entity-base-entitygd)
      - [Player Scene Hierarchy (Godot 4)](#player-scene-hierarchy-godot-4)
      - [Camera Setup](#camera-setup)
      - [Checklist](#checklist-2)
    - [PHASE 3 — Game States \& HUD Skeleton](#phase-3--game-states--hud-skeleton)
      - [Plan](#plan-2)
      - [Diagnosis: Problems With the Original](#diagnosis-problems-with-the-original-1)
      - [The Three Pillars of This Phase](#the-three-pillars-of-this-phase)
      - [Pillar 1: SceneStateManager](#pillar-1-scenestatemanager)
      - [Pillar 2: EventBus Autoload](#pillar-2-eventbus-autoload)
      - [Pillar 3: HUD — Reactive, Screen-Safe Layout](#pillar-3-hud--reactive-screen-safe-layout)
      - [Checklist](#checklist-3)
    - [PHASE 4 — Map \& World (Infinite Chunk Streaming + Procedural World Generation)](#phase-4--map--world-infinite-chunk-streaming--procedural-world-generation)
      - [Plan](#plan-3)
      - [The Two-Layer Design](#the-two-layer-design)
      - [World Coordinate System](#world-coordinate-system)
      - [The Seed System](#the-seed-system)
      - [POI (Point of Interest) System — Key Locations](#poi-point-of-interest-system--key-locations)
      - [WorldGenerator Algorithm](#worldgenerator-algorithm)
      - [Output: `world_layout.json`](#output-world_layoutjson)
      - [Save System Integration](#save-system-integration)
      - [Minimap \& Discovery](#minimap--discovery)
      - [Chunk Scene Contract (unchanged from streaming design)](#chunk-scene-contract-unchanged-from-streaming-design)
      - [Updated Project Structure for Phase 4](#updated-project-structure-for-phase-4)
      - [Checklist](#checklist-4)
    - [PHASE 5 — House System](#phase-5--house-system)
      - [Plan](#plan-4)
      - [Checklist](#checklist-5)
    - [PHASE 6 — Enemy System](#phase-6--enemy-system)
      - [Plan](#plan-5)
      - [Diagnosis: Problems With the Original](#diagnosis-problems-with-the-original-2)
      - [Architecture Decision: Keep BT, Add Blackboard + Tick Rate](#architecture-decision-keep-bt-add-blackboard--tick-rate)
      - [The Blackboard Pattern](#the-blackboard-pattern)
      - [Tasks as Resources (not Nodes)](#tasks-as-resources-not-nodes)
      - [BT Execution: Ticked, Not Framed](#bt-execution-ticked-not-framed)
      - [NavigationAgent2D Replaces the Manual Pathfinder](#navigationagent2d-replaces-the-manual-pathfinder)
      - [Tick Rate + Distance Throttling (LOD AI)](#tick-rate--distance-throttling-lod-ai)
      - [Assembled BT Trees (data, not scenes)](#assembled-bt-trees-data-not-scenes)
      - [Blackboard Keys as Typed Constants](#blackboard-keys-as-typed-constants)
      - [File Structure](#file-structure)
      - [Horde-Scale Pathfinding: The Bullet-Hell Problem](#horde-scale-pathfinding-the-bullet-hell-problem)
        - [The Three-Tier Movement Architecture](#the-three-tier-movement-architecture)
        - [Tier 1: Flow Field](#tier-1-flow-field)
        - [Tier 2: Staggered NavigationAgent2D](#tier-2-staggered-navigationagent2d)
        - [Tier 3: Direct Seek + Separation Forces](#tier-3-direct-seek--separation-forces)
        - [Tier Transition Logic](#tier-transition-logic)
        - [Expected Performance Budget (Mobile Target)](#expected-performance-budget-mobile-target)
        - [Updated Checklist Additions (Horde Pathfinding)](#updated-checklist-additions-horde-pathfinding)
    - [PHASE 7 — Behavior Tree + Pathfinder](#phase-7--behavior-tree--pathfinder)
      - [Plan](#plan-6)
      - [Diagnosis: Problems With the Original](#diagnosis-problems-with-the-original-3)
      - [Enemy Scene Structure](#enemy-scene-structure)
      - [Last Known Position + Search Behavior](#last-known-position--search-behavior)
      - [Herd Aggro — EventBus-Based](#herd-aggro--eventbus-based)
      - [Attack System Redesign](#attack-system-redesign)
      - [Checklist](#checklist-6)
    - [PHASE 8 — Item System](#phase-8--item-system)
      - [Plan](#plan-7)
      - [Checklist](#checklist-7)
    - [PHASE 9 — Inventory System](#phase-9--inventory-system)
      - [Plan](#plan-8)
      - [Checklist](#checklist-8)
    - [PHASE 10 — Weapons \& Combat](#phase-10--weapons--combat)
      - [Plan](#plan-9)
      - [Checklist](#checklist-9)
    - [PHASE 11 — Placables \& Building](#phase-11--placables--building)
      - [Plan](#plan-10)
      - [Checklist](#checklist-10)
    - [PHASE 12 — Day/Night Cycle \& World Events](#phase-12--daynight-cycle--world-events)
      - [Plan](#plan-11)
      - [Checklist](#checklist-11)
    - [PHASE 13 — Vehicle System](#phase-13--vehicle-system)
      - [Plan](#plan-12)
      - [Checklist](#checklist-12)
    - [PHASE 14 — Save / Load System](#phase-14--save--load-system)
      - [Plan](#plan-13)
      - [Architecture Overview](#architecture-overview)
      - [Save Schema: Six Categories](#save-schema-six-categories)
      - [Serialization Groups](#serialization-groups)
      - [`autoloads/serialize.gd` — Full API](#autoloadsserializegd--full-api)
      - [Per-Entity Serialize / Deserialize Contracts](#per-entity-serialize--deserialize-contracts)
        - [Player](#player)
        - [Stat / StatsComponent](#stat--statscomponent)
        - [Enemy](#enemy)
        - [House](#house)
        - [Placable (Table, Campfire)](#placable-table-campfire)
        - [HotBar](#hotbar)
        - [DayNightCycle](#daynightcycle)
      - [Save Versioning \& Migration](#save-versioning--migration)
      - [Checklist](#checklist-13)
    - [PHASE 15 — Polish \& FX](#phase-15--polish--fx)
      - [Plan](#plan-14)
      - [Checklist](#checklist-14)
    - [PHASE 16 — Optimization \& Mobile Readiness](#phase-16--optimization--mobile-readiness)
      - [Plan](#plan-15)
      - [Checklist](#checklist-15)
    - [PHASE 17 — Content \& Data](#phase-17--content--data)
      - [Plan](#plan-16)
      - [Checklist](#checklist-16)
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
│   ├── Stat System          — Stat(dirty flag, typed mods, changed signal)
│   │                          + StatModifier(FLAT/PERCENT_ADD/PERCENT_MULTIPLY/OVERRIDE)
│   │                          + StatsComponent Node (entity API, owns all stats)
│   ├── Status Effect System — StatusEffect resource + StatusEffectContainer Node
│   │                          + tick effects (RegenEffect, DrainEffect, ForceEffect)
│   ├── Inventory System     — Grid inventory + slots + touch drag-and-drop manager
│   ├── Item System          — Item UI nodes (5 subtypes)
│   ├── Behavior Tree        — BTTask (RefCounted, no Node overhead) + Blackboard dict
│   │                          + BTRunner Node (configurable tick rate / LOD AI)
│   │                          + BTTreeResource (shared tree def across all enemies of same type)
│   └── State Machine        — Stack-based with dissolve transitions
│
├── Entities
│   ├── Entity (base)   — CharacterBody2D + StatsComponent + applied_force; abstract contract
│   ├── Player          — input accumulator movement; lerp_angle rotation; body counter-rotation
│   │                     (world-rotates feel); AnimationTree BlendSpace2D legs + StateMachine upper
│   │                     body; Camera2D child (inherits rotation automatically)
│   ├── Enemy           — BTRunner (Blackboard BT, LOD tick rate); 3-tier movement:
│   │                     Tier 1 Flow Field (>400px, O(1) lookup, ~70 enemies free)
│   │                     Tier 2 NavAgent2D (120-400px, staggered via HordePathingManager)
│   │                     Tier 3 Direct Seek (<120px, vector only + separation force)
│   │                     → supports 100+ enemies at 60 FPS on mobile
│   ├── Vehicle         — Ackermann steering, embark/disembark
│   └── Placables       — Table (crafting), Campfire, base class with health
│
├── World (Infinite Chunk Streaming)
│   ├── WorldGenerator — one-shot at new-game: seeded POI placement, biome map,
│   │                    road network, fill pass → writes user://world_layout.json
│   ├── ChunkStreamer  — runtime singleton; reads world_layout.json; coordinate-keyed
│   │                    registry; time-sliced ring loader (active/buffer/prefetch);
│   │                    floating origin stub
│   ├── ChunkBase      — base script for all chunk scenes (contract interface)
│   ├── POI Registry   — JSON definitions for key locations (school, police, airport…)
│   ├── Map (TileMap)  — procedural roads + building placement (inside chunk scenes)
│   ├── House          — daily enemy/loot spawning per structure
│   └── Zone           — outdoor daily spawn areas (enabled only when chunk ACTIVE)
│
├── HUD (CanvasLayer 2, reactive — zero _process polling)
│   ├── Gages            — connect EventBus signals, update via queue_redraw()
│   ├── HotBar
│   ├── Minimap
│   ├── DayNightCycle    — CanvasModulate + night wave spawner
│   ├── Calendar         — connects EventBus.day_started
│   ├── StatusEffectIcons— connects EventBus.status_effect_added/removed
│   ├── WeaponPanel
│   ├── NotifContainer   — object-pooled labels (15 pre-allocated)
│   ├── CameraEffect     — health vignette, connects EventBus.player_health_changed
│   └── ModalLayer       — CanvasLayer 3: inventory/craft/loot/info panels
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
│   ├── chunk_streamer.gd      ← runtime world streaming (reads user://world_layout.json)
│   ├── world_generator.gd     ← one-shot new-game procedural generator
│   ├── event_bus.gd           ← all cross-cutting signals (no logic, only signal defs)
│   └── factory/               (Pathfinder autoload removed — NavigationAgent2D used instead)
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
│   ├── items.json
│   ├── poi_registry.json      ← POI definitions: id, scene, placement rules, loot tier, tags
│   └── biome_rules.json       ← ring radii + jitter config per biome
├── stat/
│   ├── stat.gd                      ← dirty flag, typed modifiers, changed signal
│   ├── stat_modifier.gd             ← FLAT/PERCENT_ADD/PERCENT_MULTIPLY/OVERRIDE + source
│   ├── stats_component.gd           ← Node: entity API, owns all Stat resources
│   ├── status_effect.gd             ← id, duration, modifiers[], tick_effects[]
│   ├── status_effect_container.gd   ← Node: _process tick, add/remove/dedup/source removal
│   ├── tick_effects/                (regen_effect, drain_effect, force_effect)
│   └── stats/                       (damage_stat, hunger_stat, level_stat — only 3 subclasses)
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
│   │   ├── chunk_base.gd        ← base script (chunk contract interface)
│   │   ├── map.gd               ← TileMap procedural road/building generator
│   │   ├── zone/zone.gd
│   │   ├── chunks/              ← chunk .tscn files (city blocks, POIs, wilderness…)
│   │   │   ├── city_center.tscn
│   │   │   ├── city_block_a/b/c.tscn
│   │   │   ├── suburb_a/b.tscn
│   │   │   ├── outskirts_a.tscn
│   │   │   ├── wilderness.tscn  ← default fallback for out-of-layout coordinates
│   │   │   ├── poi_police_station.tscn
│   │   │   ├── poi_hospital.tscn
│   │   │   ├── poi_school.tscn
│   │   │   ├── poi_airport.tscn
│   │   │   ├── poi_military_base.tscn
│   │   │   ├── poi_mall.tscn
│   │   │   └── poi_gas_station.tscn
│   │   └── previews/            ← pre-baked minimap thumbnails (generated per POI)
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
- ✅ Create new Godot 4 project named `I-Will-Survive-v2`
- ✅ Configure display settings (1080×1920, canvas_items stretch, expand aspect)
- ✅ Name all 9 physics layers in Project Settings → Layer Names → 2D Physics
- ✅ Set up input map (move_up/down/left/right, ui_accept, reload)
- ✅ Enable `emulate_touch_from_mouse` in Project Settings
- ✅ Register all 6 autoloads in correct order with stub scripts
- ✅ Create full folder structure (`autoloads/`, `data/`, `stat/`, `ai/`, `scene/`, `assets/`)
- ✅ Copy `player.json`, `enemies.json`, `items.json` into `res://data/`
- ✅ Set up fonts (`res://assets/fonts/`) — README placed, preloads deferred until font assets imported
- ✅ Confirm project opens and runs without errors (empty main scene)

---

### PHASE 1 — Stat System (Foundation)

#### Diagnosis: What Was Wrong With the Original

Before designing the replacement, here is a precise list of every problem in the original `stat/` system:

| # | Problem | Where | Impact |
|---|---------|--------|--------|
| 1 | **No modifier ordering** | `Stat.recompute()` applies modifiers in insertion order | Add+10 then Multiply×2 gives different result than Multiply×2 then Add+10. Unpredictable math. |
| 2 | **No modifier types** — all modifiers are treated identically | `recompute()` loop | Flat bonuses and percent bonuses stack the wrong way. Can't model "10% of base" vs "10% of total". |
| 3 | **`recompute()` replays modifiers on val AND maxVal** in the same loop | `Stat.recompute()` | Modifiers meant for max_val corrupt current val and vice versa. Double-application bugs. |
| 4 | **No dirty flag** — `recompute()` runs full recalculation on every single `addModifier` / `removeModifier` | `Stat.addModifier()` | Every buff tick, every frame of Regen, every ammo decrement triggers a full loop over all modifiers. |
| 5 | **Callbacks hardcoded into stat subclasses** (`healthStatCallback`, `update()` side effects) | `health.gd`, `moveSpeed.gd`, `size.gd`, `vision.gd` | Stat knows about its owner's internals. Tight coupling. Can't reuse stats across different entity types. |
| 6 | **No source tracking on modifiers** | All modifiers | Can't remove "all modifiers from this weapon" when unequipping. Must manually track and remove each one. |
| 7 | **`setVal` used for two completely different things** | `Stat.setVal()`, `Regen.run()` | Damage/heal (transient, one-shot) and max-value recalculation (permanent) share the same method. |
| 8 | **Status effects mutate the `val` array mid-iteration** | `StatusEffect.run()` erases from `data.effects` while iterating | Classic iterator invalidation bug. Can silently skip effects. |
| 9 | **`PushModifier.execute()` calls `Factory` directly** | `pushModifier.gd` | A modifier (pure data/math) is calling a global factory. Modifiers can't be tested in isolation. |
| 10 | **Modifier subclasses instead of data + enum** | 7 separate modifier classes | Adding a new modifier type requires a new file, new factory entry, new serialize case. Open/closed principle violated. |
| 11 | **`level.gd` owns `recomputeStats()` on all stats** | `level.gd setVal()` | Level stat controls all other stats. Stats are tightly coupled to each other through the level. |
| 12 | **`val` is sometimes a `float`, sometimes a `Dictionary`** | `vision.gd`, `fireAccuracy.gd` | The base `Stat` class assumes `float`. Two stats break this silently with no type safety. |

---

#### The New Architecture: Industry Standard Approach

The redesign is based on the **typed modifier with dirty-flag caching** pattern used by Diablo, Path of Exile, and documented in the Unity Stat System reference (Kryzarel/Giannis Akritidis). Adapted cleanly to GDScript 4 with Godot's `Resource` + signal system.

**Core formula (the industry standard order of operations):**

```
final_value = (base_value + sum(FLAT modifiers)) 
              × (1 + sum(PERCENT_ADD modifiers))
              × product(1 + each PERCENT_MULTIPLY modifier)

Clamped to [min_value, max_value] after calculation.
```

This order guarantees:
- Flat bonuses always add to base — predictable, order-independent
- Additive percents (10% + 20% = 30% of base) stack linearly — fair, readable
- Multiplicative percents compound on top of everything — powerful, intentional

---

#### Architecture: 4 Classes Only

```
StatModifier (Resource — pure data)
    ├── value: float
    ├── type: ModifierType enum (FLAT | PERCENT_ADD | PERCENT_MULTIPLY | OVERRIDE)
    └── source: Object (weak ref — the weapon/buff/effect that owns this modifier)

Stat (Resource — the stat itself)
    ├── base_value: float        ← set from JSON, changed only by level-up
    ├── current_value: float     ← cached result of formula, read-only externally
    ├── min_value: float         ← floor clamp (usually 0)
    ├── max_value: float         ← ceiling clamp (set by base + flat mods on max)
    ├── _modifiers: Array[StatModifier]   ← all modifiers flat in one array
    ├── _is_dirty: bool          ← dirty flag
    └── signal changed(old_val, new_val)  ← fired when current_value changes

StatusEffect (Resource — timed container of modifiers + effects)
    ├── id: StringName           ← for deduplication
    ├── source: Object           ← who applied this effect
    ├── duration: float          ← -1 = infinite
    ├── modifiers: Array[StatModifier]  ← buffs applied to stats
    ├── tick_effects: Array      ← regen/force that run each frame
    └── signal expired()

StatusEffectContainer (Node — the runtime manager on each entity)
    ├── _effects: Array[StatusEffect]
    ├── process(delta)           ← ticks all effects, removes expired
    ├── add(effect)
    ├── remove_by_id(id)
    ├── remove_all_from_source(source)
    └── signal effect_added(effect), effect_removed(effect)
```

**What disappeared:**
- 7 modifier subclasses → replaced by 1 `StatModifier` resource with a `ModifierType` enum
- `pushModifier` / `popModifier` → replaced by `StatusEffectContainer.add()` / `remove_by_id()`
- Stat subclasses that hardcode side effects → replaced by signals + a `StatBinding` component
- `StatusEffects` resource (passive container) → replaced by `StatusEffectContainer` Node (active manager)

---

#### Dirty Flag Pattern (how caching works)

The stat never recalculates unless something changed:

```gdscript
var _is_dirty := true
var _cached_value: float = 0.0

var value: float:
    get:
        if _is_dirty:
            _cached_value = _calculate()
            _is_dirty = false
        return _cached_value

func add_modifier(mod: StatModifier) -> void:
    _modifiers.append(mod)
    _is_dirty = true          # mark dirty — recalculate on next read
    changed.emit()            # notify listeners

func remove_modifier(mod: StatModifier) -> bool:
    var removed := _modifiers.erase(mod)
    if removed:
        _is_dirty = true
        changed.emit()
    return removed
```

Result: reading `health.value` 1000 times in one frame costs one calculation + 999 cache hits.

---

#### Source Tracking (how buff/equipment removal works)

Every modifier carries a `source` reference — the object that created it (a weapon, a buff, a status effect). This solves unequip cleanly:

```gdscript
# When equipping sword:
var flat_bonus := StatModifier.new(10.0, StatModifier.FLAT, sword)
health.add_modifier(flat_bonus)

# When unequipping sword — remove ALL modifiers from this source:
health.remove_all_from_source(sword)
# Works even if 5 different mods were added from the same sword.
```

---

#### Stat Signals + StatBinding (decoupled side effects)

Instead of hardcoding side effects inside stat subclasses (e.g. `vision.gd` deleting and recreating raycasts), each entity has a `StatBinding` component that connects to stat signals and drives side effects:

```gdscript
# In enemy's _ready():
stats.vision.changed.connect(_on_vision_changed)
stats.move_speed.changed.connect(_on_move_speed_changed)

func _on_vision_changed(old_val, new_val):
    _rebuild_vision_raycasts(new_val)

func _on_move_speed_changed(old_val, new_val):
    body.lower_animation.speed_scale = new_val / 60.0
```

The `Stat` resource knows nothing about what it's connected to. Any entity type can subscribe to any stat's signal.

---

#### Solving the "val is a Dict" Problem (VisionStat, FireAccuracyStat)

In the original, vision and fire_accuracy stored `{width, height}` dictionaries as `val`, breaking the float assumption. The fix: **separate stats for each dimension**.

```
# Old (broken):
stats.vision.val = {"width": 200, "height": 150}  # not a float!

# New (clean):
stats.vision_width   (Stat)  base=200
stats.vision_height  (Stat)  base=150
stats.fire_spread_x  (Stat)  base=0.1
stats.fire_spread_y  (Stat)  base=0.1
```

Each is a plain `float` Stat. The entity code that reads both dimensions for raycast generation just reads two stats.

---

#### Resources vs Nodes

| Class | Type | Why |
|-------|------|-----|
| `StatModifier` | `Resource` | Pure data, no frame processing, passed around freely, serialized easily |
| `Stat` | `Resource` | Owned by entity's data dict, no scene tree needed, emits `changed` signal |
| `StatusEffect` | `Resource` | Transferable data — the same effect definition can be applied to any entity |
| `StatusEffectContainer` | **`Node`** | Needs `_process(delta)` to tick durations, owns the active effects list |

---

#### The `StatsComponent` Node (entity-facing API)

Each entity gets a `StatsComponent` node as a child. It owns all `Stat` resources and the `StatusEffectContainer`. Exposes a clean API to the entity:

```gdscript
class_name StatsComponent extends Node

@export var health: Stat
@export var move_speed: Stat
@export var hunger: Stat
@export var damage: Stat
# ... all stats as typed exports

@onready var effects: StatusEffectContainer = $StatusEffectContainer

func take_damage(amount: float) -> bool:
    health.current_value -= amount        # direct sub, no "modifier" needed for one-shot damage
    return health.current_value <= 0.0   # returns true if dead

func apply_effect(effect: StatusEffect) -> void:
    effects.add(effect)

func remove_effects_from(source: Object) -> void:
    effects.remove_all_from_source(source)
    # also removes their modifiers from all stats via source tracking
```

`take_damage()` directly subtracts — no "SubtractModifier" resource needed for one-shot damage. Modifiers are only for **persistent** changes (equipment, buffs, level scaling).

---

#### Level Scaling

Level scaling is no longer done inside `LevelStat.setVal()`. Instead, the `StatsComponent` exposes `apply_level_scaling(level)`:

```gdscript
func apply_level_scaling(level: int) -> void:
    for stat in _scalable_stats:
        # Remove old level modifier, add new one
        stat.remove_all_from_source(self)  # "self" = StatsComponent is the source
        var scaled_amount := stat.base_value * stat.level_multiplier * (level - 1)
        var mod := StatModifier.new(scaled_amount, StatModifier.FLAT, self)
        stat.add_modifier(mod)
```

Clean, reversible, source-tracked. LevelStat itself just tracks XP and emits `leveled_up(new_level)`.

---

---

#### JSON Data Format (for stat definitions)

Stats are still initialized from JSON — same data files, cleaned up schema:

```json
"stats": {
  "health":     { "base": 12400, "min": 0, "level_multiplier": 500,  "scalable": true },
  "move_speed": { "base": 180,   "min": 10, "level_multiplier": 5,   "scalable": true },
  "damage":     { "base": 40,    "min": 1,  "level_multiplier": 2,   "scalable": true, "spread": 5 },
  "hunger":     { "base": 240,   "min": 0,  "level_multiplier": 0,   "scalable": false, "drain_rate": 1.0 },
  "vision_width":  { "base": 200, "min": 50, "level_multiplier": 0,  "scalable": false },
  "vision_height": { "base": 150, "min": 50, "level_multiplier": 0,  "scalable": false }
}
```

`StatsFactory` reads this and instantiates typed `Stat` objects. It no longer needs 11 separate subclasses — just `Stat` + a few typed wrappers for special behavior (`DamageStat` with spread, `HungerStat` with drain, `LevelStat` with XP threshold).

---

#### File Map

```
stat/
├── stat.gd                      ← Stat resource: dirty flag, typed modifiers, changed signal
├── stat_modifier.gd             ← StatModifier resource: value, ModifierType enum, source ref, is_permanent
├── stats_component.gd           ← Node: owns all Stat resources + StatusEffectContainer; entity API
├── status_effect.gd             ← StatusEffect resource: id, duration, modifiers[], tick_effects[]
├── status_effect_container.gd   ← Node: _process tick, add/remove, source removal, signals
├── tick_effects/
│   ├── regen_effect.gd          ← periodic stat.current_value += amount
│   ├── drain_effect.gd          ← periodic stat.current_value -= amount (hunger, bleed)
│   └── force_effect.gd          ← frame-by-frame applied_force with friction decay
└── stats/
    ├── damage_stat.gd           ← Stat + random spread on get_value()
    ├── hunger_stat.gd           ← Stat + drain_rate, triggers health damage at 0
    └── level_stat.gd            ← Stat + XP threshold, emits leveled_up signal
```

---

#### Checklist

**Core stat classes**
- ✅ `stat/stat_modifier.gd` — `Resource`: `value: float`, `enum ModifierType {FLAT, PERCENT_ADD, PERCENT_MULTIPLY, OVERRIDE}`, `type: ModifierType`, `source: WeakRef`, `is_permanent: bool`
- ✅ `stat/stat.gd` — `Resource`: `base_value: float`, `min_value: float`, `level_multiplier: float`; `_modifiers: Array[StatModifier]`, `_is_dirty: bool`, `_cached_value: float`; `value` getter with dirty flag; `add_modifier(mod)`, `remove_modifier(mod) -> bool`, `remove_all_from_source(source)`, `_calculate() -> float` (ordered: FLAT → PERCENT_ADD → PERCENT_MULTIPLY → OVERRIDE); signal `changed(old_val: float, new_val: float)`
- ✅ `stat/stats_component.gd` — `Node`: `@export` typed `Stat` vars for every stat; `@onready var effects: StatusEffectContainer`; `init_from_data(data: Dictionary)` reads JSON + creates stats; `take_damage(amount) -> bool`, `heal(amount)`, `apply_effect(effect)`, `remove_effects_from(source)`, `apply_level_scaling(level)`
- ✅ `stat/status_effect.gd` — `Resource`: `id: StringName`, `source: WeakRef`, `duration: float` (-1=infinite), `modifiers: Array[StatModifier]`, `tick_effects: Array`; signal `expired()`
- ✅ `stat/status_effect_container.gd` — `Node`: `_effects: Array[StatusEffect]`, `_process(delta)` ticks all effects + removes expired (iterates backwards); `add(effect: StatusEffect)`: checks dedup by id + applies modifiers to stats via source; `remove(effect)`: removes modifiers from stats; `remove_by_id(id)`, `remove_all_from_source(source)`, `has(id) -> bool`; signals `effect_added(effect)`, `effect_removed(effect)`

**Tick effects (the three stat effect types)**
- ✅ `stat/tick_effects/regen_effect.gd` — `rate: float`, `duration: float`, `target_stat: StringName`; `tick(entity, delta)` applies heal at interval via StatsComponent lookup; returns true when done
- ✅ `stat/tick_effects/drain_effect.gd` — same as regen but subtracts; calls `entity.die()` when health hits 0
- ✅ `stat/tick_effects/force_effect.gd` — `magnitude: float`, `friction: float`; `init(direction)` sets force vector; `tick(entity, delta)` adds to `entity.applied_force`, decays exponentially; returns true when exhausted

**Typed stat subclasses (only 3 needed)**
- ✅ `stat/stats/damage_stat.gd` — extends `Stat`; `spread: float`; `get_ranged_value() -> float` returns `randf_range(value - spread, value + spread)`
- ✅ `stat/stats/hunger_stat.gd` — extends `Stat`; `drain_rate: float`, `tolerance: float`; `tick(delta, stats)` drains hunger then damages health at 0; calls `entity.die()`
- ✅ `stat/stats/level_stat.gd` — extends `Stat` (xp as current_value); `xp_threshold: float`; `add_xp(amount)` increments, multi-level loop, emits `leveled_up(new_level: int)`; handles legacy `{"min","max"}` val format

**Factories**
- ✅ `autoloads/factory/stat_factory.gd` — `create(id, data)`, `create_all(stats_dict)` with vision/fire_accuracy split, legacy script key normalisation; `deserialize()`
- ✅ `autoloads/factory/stat_modifier_factory.gd` — legacy (script/val/type path) + new (modifier_type/value/target_stat) JSON formats; stores `target_stat` as metadata; `create_all()`
- ✅ `autoloads/factory/status_effect_factory.gd` — chance roll, builds buff mods + RegenEffect + DrainEffect + ForceEffect; `create_all()`; `remove_by_id()`

**Entity wiring (how stats connect to visuals — replaces stat subclass side effects)**
- ⬜ In `enemy.gd _ready()`: connect `stats.vision_width.changed` + `stats.vision_height.changed` → `_rebuild_vision_raycasts()`; connect `stats.move_speed.changed` → `body.lower_animation.speed_scale = new_val / 60.0`; connect `stats.aggression_range.changed` → `body_sensor.shape.radius = new_val`
- ⬜ In `player.gd _ready()`: connect `stats.health.changed` → `_on_health_changed()`; connect `stats.move_speed.changed` → `_on_move_speed_changed()`
- ⬜ In HUD gage: connect `stats_component.health.changed` → update gage fill ratio

**Verify**
- ⬜ Formula order test: flat +10 and percent_add +50% on base 100 → expect 165 (not 160)
- ⬜ Dirty flag test: add modifier, read value twice → `_calculate()` called only once
- ⬜ Source removal test: add 3 modifiers with same source, remove_all_from_source → all 3 gone
- ⬜ Status effect test: apply bleed (drain 5hp/s for 10s), verify health decrements, verify stops at 10s
- ⬜ Level-up test: add XP past threshold, stats recompute, health restores to new max

---
### PHASE 2 — Entity Base + Player

#### Plan

This phase establishes two things: the `Entity` base all living things share, and the complete player movement/rotation/animation system. The movement feel is the most critical part — get it wrong here and it's painful to fix later.

---

#### The Dead Town Movement Model (what we're recreating)

The game uses a **player-up / world-rotates** camera model:

```
┌─────────────────────────────────────────────────────┐
│  The player sprite ALWAYS points UP on screen.      │
│  The camera is locked to the player with NO         │
│  rotation of its own.                               │
│                                                     │
│  When the player "rotates", what actually happens:  │
│  → The player node's rotation_degrees changes       │
│  → The camera is a child of the player, so it       │
│    inherits the rotation                            │
│  → The entire world appears to spin around the      │
│    player — roads, houses, enemies all rotate       │
│  → The player's sprite is counter-rotated so it     │
│    always visually points up on screen              │
└─────────────────────────────────────────────────────┘
```

This is the same technique used by Realm of the Mad God, Hotline Miami (partial), and classic GTA1/GTA2. It creates the visceral "spinning world" feel when you rotate while moving.

**WASD movement is always relative to the player's current facing:**
- W = forward (up the screen, which is the player's local -Y axis after rotation)
- S = backward
- A/D = strafe left/right
- The velocity vector is rotated by the player's current `rotation` before being applied

**Touch controls:**
- Left half of screen → virtual joystick → direction vector is in **screen space** (always up = screen up), then rotated by player rotation before applying to physics. This means pushing the stick up always moves the character up the screen regardless of player rotation — which matches the visual feel perfectly.
- Right half of screen → drag left/right/diagonally → rotates the player (and thus the world). The sensitivity converts pixel delta to degrees.

---

#### Diagnosis: Problems With the Original

| # | Problem | Impact |
|---|---------|--------|
| 1 | **Stack-based velocity (`velocity = [{key, value}]`)** | An array of dicts to merge multiple inputs is fragile. The `back()` approach means only the last pushed input counts, which breaks when both WASD and touch are active simultaneously. |
| 2 | **Movement not properly decoupled from rotation** | `velocity.back().value.rotated(deg2rad(rotation_degrees))` — rotation is applied per-frame but the raw vector is stored unrotated. Frame-order sensitive. |
| 3 | **Rotation applied directly and instantly** — no smoothing | `rotation_degrees = degrees` on every drag event. Feels snappy but can cause physics jitter at high rotation speeds. |
| 4 | **Controller hardcoded as a separate Node2D added to HUD** | When swapping to vehicle controller, the old controller is never properly cleaned up. Signal connections are manual and fragile. |
| 5 | **Animation chosen inside signal handlers** | `_on_Controller_use_joystick_vector` directly calls `$Body/Lower/Animation.play()`. Animation logic is scattered across movement code. |
| 6 | **No movement states** — idle, walk, strafe, sprint all handled by `if/else` chains | Not scalable. Adding a crouch or sprint state requires touching movement code, animation code, and controller code simultaneously. |
| 7 | **`applied_force` never decays in the player** — only in the `ApplyForce` stat effect | If knockback fires while the player is idle, `applied_force` persists indefinitely. |
| 8 | **No input buffering or dead zone on the joystick** | Tiny accidental touches trigger movement. |
| 9 | **Controller rotation uses cumulative `rotated` float with `fmod`** | Floating point drift over long sessions. |
| 10 | **Player body node accessed by hardcoded path `$Body/Lower/Animation`** | Brittle. Rename any node and the player breaks silently. |

---

#### Architecture: Clean Separation of Concerns

```
Player (CharacterBody2D)
│  player.gd — owns physics, coordinates all components
│
├── StatsComponent (Node)             ← Phase 1 stat system
├── StatusEffectContainer (Node)      ← Phase 1
│
├── Body (Node2D)                     ← visual representation only
│   ├── LowerBody (Node2D)            ← legs sprite
│   │   └── AnimationTree             ← BlendSpace2D for 8-dir walk
│   └── UpperBody (Node2D)            ← torso + arms sprite
│       └── AnimationTree             ← StateMachine: idle/shoot/melee
│
├── WeaponMount (Marker2D)            ← weapon scene parented here
├── HandMount (Marker2D)              ← hand item parented here
│
├── PlacablePreview (Node2D)          ← building placement preview
│
├── PickupArea (Area2D)               ← auto-pickup radius
│   └── CollisionShape2D (circle)
│
└── Notifier (VisibleOnScreenNotifier2D)
```

The `Controller` is **NOT a child of the player**. It lives in the HUD's CanvasLayer and communicates only through signals. The player connects to those signals in `_ready()` and disconnects in `_exit_tree()`. Swapping to a vehicle controller is just changing which node the HUD hosts — the player script doesn't care.

---

#### Movement System: Input Accumulator (replaces velocity stack)

Instead of a stack of `{key, value}` dicts, we use a clean **input accumulator** with named axes:

```gdscript
# In player.gd
var _move_input: Vector2 = Vector2.ZERO   # raw directional input (screen space)
var _facing: float = 0.0                  # current rotation in radians
var _target_facing: float = 0.0          # desired rotation (smooth toward this)
```

Input sources write into `_move_input` and `_target_facing`. The physics step reads them:

```gdscript
func _physics_process(delta: float) -> void:
    # 1. Smooth rotation (lerp toward target facing)
    _facing = lerp_angle(_facing, _target_facing, ROTATION_SPEED * delta)
    rotation = _facing

    # 2. Move in screen-space direction, rotated by facing
    var move_dir := _move_input.rotated(_facing)
    velocity = move_dir * stats.move_speed.value + _applied_force
    move_and_slide()

    # 3. Decay applied force
    _applied_force = _applied_force.lerp(Vector2.ZERO, FORCE_FRICTION * delta)

    # 4. Update animation
    _update_animation(move_dir, delta)
```

**Why `lerp_angle` for rotation:** Smooth rotation prevents physics jitter when enemies chase the player and the world is spinning rapidly. It also feels better — the world eases into the new orientation rather than snapping.

**Why `move_dir.rotated(_facing)`:** The joystick always gives a screen-space vector (up = screen up). Rotating by `_facing` converts it to world space. So pushing the stick "up the screen" always moves the player up the screen, exactly matching the visual.

---

#### Rotation: Two Input Sources, One Target

Two things can rotate the player:

1. **Touch drag (right half of screen)** → converts pixel delta to angle delta → accumulates into `_target_facing`
2. **Mouse pointer (desktop)** → `look_at(get_global_mouse_position())` equivalent — `_target_facing = global_position.angle_to_point(mouse_pos)`

Both write to `_target_facing`. The physics step smoothly lerps `_facing` toward it.

```gdscript
# Rotation sensitivity constants
const ROTATION_SPEED := 12.0          # radians/sec lerp speed (feel this in playtest)
const DRAG_SENSITIVITY := 0.008       # radians per pixel of drag
```

---

#### Body Counter-Rotation (the "world rotates" trick)

The `Body` node must visually stay upright on screen. Since `Body` is a child of `Player`, it inherits the rotation. We counter it every frame:

```gdscript
# In Body node or in player._physics_process:
body.rotation = -_facing   # exact inverse of player rotation
```

Result:
- `Player.rotation = 1.2 rad` → world appears rotated 1.2 rad clockwise
- `Body.rotation = -1.2 rad` → sprite counter-rotated, visually stays upright
- The player's legs and torso always face up on screen ✓
- The world (tilemap, enemies, houses) all appear to spin around the player ✓

This is the **single most important trick** in the whole system. Everything else is standard.

---

#### Animation System: AnimationTree with BlendSpace2D

Replace the old manual `AnimationPlayer.play("run_stright")` / `play("run_side")` calls with a proper **AnimationTree**.

**Lower body (legs) — BlendSpace2D:**
```
BlendSpace2D inputs (blend position = local_velocity_2d normalized):
  (-1, 0) → strafe_left
  ( 1, 0) → strafe_right
  ( 0,-1) → walk_forward
  ( 0, 1) → walk_backward
  ( 0, 0) → idle
  (-1,-1) → walk_forward_left (diagonal)
  ( 1,-1) → walk_forward_right
  etc.
```

The blend position is the **movement direction in local space** (relative to the body, not world):
```gdscript
var local_vel := move_dir.rotated(-_facing)  # world→local
lower_anim_tree.set("parameters/BlendSpace2D/blend_position", local_vel)
```

This automatically cross-fades between walk directions as the player strafes — no if/else needed.

**Upper body (torso/arms) — AnimationStateMachine:**
```
States: idle → pistol_idle → pistol_shoot
        idle → rifle_idle → rifle_shoot
        idle → melee_swing
        idle → hurt
```

The upper body state machine is driven by weapon equip/unequip signals and attack events. It runs independently of the lower body — you can be walking while reloading, for example.

**Godot 4 AnimationTree setup:**
- `AnimationTree.tree_root = AnimationNodeBlendTree`
- Inside: two sub-trees connected via `AnimationNodeSync`
  - `lower_body_blend` = `AnimationNodeBlendSpace2D`
  - `upper_body_state` = `AnimationNodeStateMachine`
- Blend masks on each sub-tree restrict which bones/sprites each controls

---

#### Controller Design: Interface Pattern

The controller emits signals but the **player and vehicle both implement the same interface** by connecting to the same signal names:

```gdscript
# controller.gd signals (same for player controller and vehicle controller):
signal move_input_changed(direction: Vector2)   # normalized direction, screen space
signal rotation_input(delta_angle: float)       # radians to add to facing
signal action_pressed(action: StringName)       # "fire", "reload", "interact", "disembark"
signal action_released(action: StringName)
```

The HUD hosts the active controller. When swapping to a vehicle:
1. Disconnect player from old signals
2. Swap controller node in HUD
3. Connect vehicle to new controller's signals

The player and vehicle scripts never reference each other or the controller directly.

**Touch controller layout:**
```
┌─────────────────────────────────┐
│                                 │
│  [LEFT ZONE]    [RIGHT ZONE]    │
│  Virtual        Drag to rotate  │
│  Joystick       + Tap to fire   │
│                                 │
│  [HOTBAR] [BTN] [BTN]  [BTN]   │  ← CanvasLayer, not affected by rotation
└─────────────────────────────────┘
```

- Left zone (≤ 45% screen width): virtual joystick
  - Touch down: record origin, show joystick visual
  - Drag: compute normalized direction from origin, clamp to max_radius (70px), emit `move_input_changed`
  - Dead zone: 8px minimum before registering movement
  - Release: emit `move_input_changed(Vector2.ZERO)`

- Right zone (> 45% screen width): rotation + fire
  - Single tap (< 200ms, < 10px movement): emit `action_pressed("fire")`
  - Drag: convert pixel delta to angle delta, emit `rotation_input(delta)`
  - Multi-touch: each finger tracked by `event.index`

**Keyboard fallback:**
- WASD → `move_input_changed` with unit vectors (no dead zone needed)
- Mouse drag or Q/E → `rotation_input`
- Left click / Space → `action_pressed("fire")`

---

#### Entity Base (`entity.gd`)

The base class is now minimal — just the shared contract all entities fulfill:

```gdscript
class_name Entity extends CharacterBody2D

# Shared components (all entities have these)
@onready var stats: StatsComponent = $StatsComponent

# Shared state
var applied_force: Vector2 = Vector2.ZERO

# Contract — all subclasses implement these:
func hurt(damage: float, source: Node) -> void:
    pass  # subclass handles visual + audio feedback

func die() -> void:
    pass

# Shared utility
func _apply_knockback(direction: Vector2, force: float) -> void:
    applied_force += direction.normalized() * force
```

No `data{}` dict on the entity itself anymore. Stats live in `StatsComponent`. JSON data is loaded by the factory and passed to `StatsComponent.init_from_data()`. The entity has no knowledge of JSON or factories.

---

#### Player Scene Hierarchy (Godot 4)

```
Player (CharacterBody2D, player.gd)
├── CollisionShape2D          — CapsuleShape2D, player hitbox
├── StatsComponent (Node)     — Phase 1 stat system
├── StatusEffectContainer (Node)
│
├── Body (Node2D)             — visual layer, counter-rotated each frame
│   ├── Shadow (Sprite2D)     — flat shadow under player
│   ├── LowerBody (Node2D)    — legs
│   │   ├── Sprite2D          — leg sprites
│   │   └── AnimationTree     — BlendSpace2D for 8-directional walk
│   └── UpperBody (Node2D)    — torso + arms
│       ├── Sprite2D          — torso sprite
│       └── AnimationTree     — StateMachine for combat states
│
├── WeaponMount (Marker2D)    — weapon scene added here when equipped
├── HandMount (Marker2D)      — hand item (torch) added here
│
├── PlacablePreview (Node2D)  — build placement preview, normally hidden
│   ├── Sprite2D              — preview sprite (tinted blue/red)
│   ├── Area2D                — overlap detection for validity
│   └── CanvasLayer           — confirm/cancel buttons (screen-space)
│
└── PickupArea (Area2D)       — auto-pickup radius
    └── CollisionShape2D      — CircleShape2D radius ~80px
```

---

#### Camera Setup

The camera is **a child of the player** (inherits position and rotation automatically):

```
Player
└── Camera2D
    ├── position_smoothing_enabled = true
    ├── position_smoothing_speed = 8.0
    └── zoom = Vector2(1.7, 1.7)
```

Since `Camera2D` inherits `Player.rotation`, the world appears to rotate with the player — exactly the Dead Town feel. No code needed for this; it's purely structural.

For camera shake on damage:
```gdscript
# In player.hurt():
var tween := create_tween()
tween.tween_property($Camera2D, "offset", Vector2(randf_range(-intensity, intensity), randf_range(-intensity, intensity)), 0.05)
tween.tween_property($Camera2D, "offset", Vector2.ZERO, 0.1)
```

---

#### Checklist

**Entity base**
- ✅ `scene/entities/entity.gd` — `CharacterBody2D`: `@onready var stats: StatsComponent`, `var applied_force: Vector2`; abstract `hurt(damage, source)`, `die()`; `_apply_knockback(dir, force)`; connect `stats.health.stat_changed` → `_on_health_changed()` in `_ready()`

**Player core**
- ✅ `scene/entities/player/player.gd` — extends Entity: `_move_input: Vector2`, `_facing: float`, `_target_facing: float`; `_physics_process(delta)`: lerp_angle rotation + rotate move vector + move_and_slide + force decay; `_update_animation(local_vel)` drives AnimationTree blend position; `hurt(damage, source)` creates camera shake + knockback; `die()` emits EventBus.player_died; health signal emits EventBus; `set_weapon(item)`, `set_hand_item(item)`, `spawn_sound()`
- ✅ `scene/entities/player/player.tscn` — full node hierarchy: CollisionShape2D (CapsuleShape2D), StatsComponent, StatusEffectContainer, Body (Shadow + LowerBody + UpperBody + UpperBodyAnimation), WeaponMount, HandMount, PlacablePreview, PickupArea, Camera2D
- ✅ `Camera2D` as child of Player: `position_smoothing_enabled=true`, `position_smoothing_speed=8`, `zoom=(1.7,1.7)`; camera shake via `create_tween()` on `offset`
- ✅ Body counter-rotation: `body.rotation = -_facing` every `_physics_process` frame
- ✅ Constants: `ROTATION_SPEED = 12.0`, `DRAG_SENSITIVITY = 0.008`, `FORCE_FRICTION = 8.0`, `JOYSTICK_DEAD_ZONE = 8.0`, `JOYSTICK_MAX_RADIUS = 70.0`

**Controller**
- ✅ `scene/entities/player/controller/controller.gd` — `Control` node (full screen, mouse_filter=IGNORE): signals `move_input_changed(dir: Vector2)`, `rotation_input(delta_angle: float)`, `action_pressed(action: StringName)`, `action_released(action: StringName)`; `_input(event)` handles `InputEventScreenTouch` + `InputEventScreenDrag` + `InputEventKey` + `InputEventMouseButton`; left zone (≤45% width): virtual joystick with dead zone + max radius clamp; right zone: drag→rotation + tap→fire; each touch tracked by `event.index`; joystick visual follows touch origin
- ✅ Joystick visual: `Sprite2D` for base ring + `Sprite2D` for thumb knob; hidden when not active; positioned at touch-down point
- ✅ Keyboard: WASD → `move_input_changed`, Q/E → `rotation_input`, Left click → `action_pressed("fire")`
- ✅ Dead zone: only emit `move_input_changed` when `joystick_offset.length() > DEAD_ZONE`

**Animation**
- ⬜ Lower body `AnimationTree` — `AnimationNodeBlendSpace2D` root; 8 blend points at unit circle positions + center idle; driven by `local_velocity.normalized()` each physics frame; `sync = true` on all blend positions for smooth crossfade
- ⬜ Upper body `AnimationTree` — `AnimationNodeStateMachine`; states: `idle`, `pistol_idle`, `pistol_fire`, `rifle_idle`, `rifle_fire`, `rifle_reload`, `melee_swing`, `hurt`; transitions driven by weapon equip signals + `action_pressed("fire")`; `attack_landed` and `attack_finished` emitted via AnimationPlayer `Call Method` tracks
- ✅ `scene/entities/player/upper_body_animation.gd` — wraps AnimationTree state machine; exposes `play_state(name)`, signals `attack_landed`, `attack_finished`; on `attack_finished` returns to current weapon's idle state

**Placable preview**
- ✅ `scene/entities/player/placable/placable_preview.gd` — `build(static_data)`: set sprite size, show preview; overlap Area2D tints sprite red/green; `confirm()`: calls Factory.placables.create(); `cancel()`: hide

**Verify**
- ⬜ Move with WASD: character moves in all 8 directions, BlendSpace2D crossfades smoothly
- ⬜ Drag right zone on screen: world rotates, player sprite stays visually upright
- ⬜ Move while rotating: velocity stays correct relative to screen orientation
- ⬜ Take damage: camera shake + red vignette appears; die → game over state
- ⬜ Equip weapon: upper body switches to weapon idle animation; lower body walk unaffected
- ⬜ Knockback: applied_force pushes player, decays smoothly over ~0.5s

---
### PHASE 3 — Game States & HUD Skeleton

#### Plan

This phase wires up the entire application shell — state machine, transitions, HUD, and an Event Bus. These three systems are the connective tissue of everything else. Done right here, every future phase plugs in cleanly. Done poorly, every future phase patches around the mess.

---

#### Diagnosis: Problems With the Original

| # | Problem | Impact |
|---|---------|--------|
| 1 | **All states pre-instantiated at startup** — `states = { "pauseState": preload(...).instance(), ... }` | Every state's `_ready()` fires before the game even starts. States accumulate memory regardless of whether they're ever visited. Adding a new state means editing `StateManager`. |
| 2 | **State identified by string key** — `pushState("gameState")` | Typos fail silently at runtime. No IDE autocomplete. No compile-time safety. |
| 3 | **`currentStates[0]` is the active state** — stack stored in reverse, front = active | Confusing convention. `push_front` / `pop_front` on an array is not a stack. |
| 4 | **`stateReady` signal used to call `newGame()` / `continueGame()`** — `connect("stateReady", state, "newGame", CONNECT_ONESHOT)` | Race condition: the signal fires synchronously after `add_child()` before the state's `_enter_tree()` completes. Also, the manager shouldn't know about `newGame` vs `continueGame`. |
| 5 | **Transitions use `yield(animation, "animation_finished")`** | Blocks the call stack. The manager is frozen during dissolve. In Godot 4 this must be `await`. |
| 6 | **`get_tree().paused = true` called inconsistently** — some states set it in `_on_X_tree_entered`, some in `_ready()`, others in signal handlers | No single clear contract for which state owns the pause state. Multiple states fighting over `paused` is a recipe for the game getting stuck paused. |
| 7 | **HUD components polled in `_process`** — `Gage` reads `stat.val / stat.maxVal` every frame | 60 reads/frame for each gage regardless of whether the stat changed. The stat system (Phase 1) emits `changed` — connect to that instead. |
| 8 | **HUD has no Event Bus** — `Globals.HUD.statusEffectIcons.addIcon(statusEffect)` called directly from Player | Player knows the HUD's internal node structure. Every new HUD element requires editing the player script. |
| 9 | **LoadingState watches `Globals.loading_blocks_count` in `_process`**  | Polling a global integer every frame instead of listening for a signal. |
| 10 | **GameState directly loads player scenes** — `load("res://...Player.tscn").instance()` | Hard-coded scene paths in logic code. Not easily testable, not swappable. |

---

#### The Three Pillars of This Phase

```
1. SceneStateManager  — clean stack-based state machine, lazy instantiation, typed transitions
2. EventBus autoload  — decoupled cross-scene signals, removes all Globals.HUD.x.y() calls
3. HUD               — reactive (signal-driven, zero polling), screen-safe layout
```

---

#### Pillar 1: SceneStateManager

**Design principles (industry standard):**
- States are **lazy-instantiated** — created only when first visited, freed when popped (unless pinned)
- States identified by **class reference or enum**, not strings
- The stack is a proper `Array` where `back()` = active state
- The manager never calls methods on states — it only manages the tree; states react to `_enter_tree()` / `_exit_tree()`
- Transitions are **non-blocking** using `await`

**State lifecycle contract** — every state implements these via `_enter_tree()` / `_exit_tree()`:

```
_enter_tree()  → set up, connect signals, optionally pause tree
_exit_tree()   → tear down, disconnect signals, restore pause state
```

The manager never tells a state what to do. States self-manage on tree events. This is Godot's intended pattern.

**Transition system:**

```gdscript
# In SceneStateManager:
async func push_state(packed_scene: PackedScene) -> void:
    await _transition.play_out()           # fade to black (non-blocking)
    if _stack.size() > 0:
        remove_child(_stack.back())        # remove current state from tree
    var state := _get_or_create(packed_scene)
    _stack.push_back(state)
    add_child(state)
    await _transition.play_in()            # fade back in

async func pop_state() -> void:
    if _stack.size() < 2: return
    await _transition.play_out()
    remove_child(_stack.pop_back())        # free if not pinned
    add_child(_stack.back())               # restore previous state
    await _transition.play_in()

func push_overlay(packed_scene: PackedScene) -> void:
    # Overlays (LoadingState, PauseState) added on TOP without transition
    var overlay := packed_scene.instantiate()
    _overlays.push_back(overlay)
    add_child(overlay)

func pop_overlay() -> void:
    if _overlays.is_empty(): return
    remove_child(_overlays.pop_back())
```

**Pinned states** (states that should not be freed on pop, like MenuState):

```gdscript
var _pinned: Dictionary = {}  # PackedScene → Node instance

func _get_or_create(packed: PackedScene) -> Node:
    if packed in _pinned:
        return _pinned[packed]
    return packed.instantiate()

# Pin a state so it survives pops (MenuState is pinned since first visit)
func pin_state(packed: PackedScene, instance: Node) -> void:
    _pinned[packed] = instance
```

**Pause ownership** — only `PauseState` and `MapState` pause the tree, and they restore it reliably on `_exit_tree()`:

```gdscript
# In pause_state.gd:
func _enter_tree() -> void:
    get_tree().paused = true

func _exit_tree() -> void:
    get_tree().paused = false
    # Tree always restored, no matter how the state exits
```

No other state touches `get_tree().paused`.

**State definitions — typed constants instead of strings:**

```gdscript
# scene/states/state_defs.gd  (autoloaded or static class)
const MENU     := preload("res://scene/states/menu_state/menu_state.tscn")
const GAME     := preload("res://scene/states/game_state/game_state.tscn")
const PAUSE    := preload("res://scene/states/pause_state/pause_state.tscn")
const MAP      := preload("res://scene/states/map_state/map_state.tscn")
const GAME_OVER:= preload("res://scene/states/game_over_state/game_over_state.tscn")
const LOADING  := preload("res://scene/states/loading_state/loading_state.tscn")
```

Usage: `SceneStateManager.push_state(StateDefs.GAME)` — IDE-autocompleted, typo-proof.

**GameState responsibilities** (stripped down — no more `newGame()` / `continueGame()` duality):

```gdscript
# game_state.gd
@export var is_new_game: bool = true  # set by MenuState before pushing

func _enter_tree() -> void:
    ChunkStreamer.activate()
    Pathfinder.set_process(true)
    if is_new_game:
        WorldGenerator.generate()
        _spawn_player()
        _spawn_day_night()
        # trigger initial save — wired in Phase 14
    else:
        # trigger load — wired in Phase 14
    _start_auto_save_timer()

func _exit_tree() -> void:
    Pathfinder.set_process(false)
    _stop_auto_save_timer()
```

MenuState sets `instance.is_new_game = true/false` before calling `push_state()`. No signal gymnastics.

---

#### Pillar 2: EventBus Autoload

The **EventBus** is a single autoloaded Node that holds all cross-cutting signals. This eliminates direct references between gameplay nodes and the HUD — they never need to know each other exist.

```gdscript
# autoloads/event_bus.gd
extends Node

# --- Player events ---
signal player_health_changed(current: float, maximum: float)
signal player_hunger_changed(current: float, maximum: float)
signal player_died()
signal player_revived()
signal player_level_changed(new_level: int)

# --- Status effects ---
signal status_effect_added(effect: StatusEffect)
signal status_effect_removed(effect: StringName)  # by id

# --- Day/Night ---
signal day_started(day_number: int)
signal night_started()
signal enemy_wave_spawned(count: int)

# --- World / Chunks ---
signal chunk_activated(coord: Vector2i)
signal chunk_deactivated(coord: Vector2i)
signal poi_discovered(poi_id: String, coord: Vector2i)

# --- Items & Inventory ---
signal item_picked_up(item_id: String, quantity: int)
signal hotbar_changed()

# --- Notifications ---
signal notification_requested(text: String, color: Color)

# --- Save ---
signal game_saved()
signal game_loaded()
```

**How it works:**

```gdscript
# Player emits through EventBus — knows nothing about HUD:
EventBus.player_health_changed.emit(stats.health.value, stats.health.max_value)

# Gage in HUD reacts — knows nothing about Player:
func _ready() -> void:
    EventBus.player_health_changed.connect(_on_health_changed)

func _on_health_changed(current: float, maximum: float) -> void:
    _fill_ratio = current / maximum  # update once, only when it changes
```

**Zero polling.** The Gage never reads anything in `_process`. It only updates when the signal fires.

**The rule:** Gameplay → EventBus → HUD/Audio/Effects. Never direct references across the boundary.

---

#### Pillar 3: HUD — Reactive, Screen-Safe Layout

**Reactive (signal-driven, no polling):**

Every HUD widget connects to `EventBus` signals in `_ready()`. No widget reads gameplay state in `_process`. Updates happen exactly once per actual change.

```gdscript
# gage.gd — connects to EventBus, not to Player directly
@export var stat_type: StringName = "health"  # "health" or "hunger"
var _fill_ratio: float = 1.0

func _ready() -> void:
    match stat_type:
        "health": EventBus.player_health_changed.connect(_update)
        "hunger": EventBus.player_hunger_changed.connect(_update)

func _update(current: float, maximum: float) -> void:
    _fill_ratio = current / maximum if maximum > 0.0 else 0.0
    queue_redraw()  # Godot 4: triggers _draw() on next frame

func _draw() -> void:
    var fill_width := size.x * _fill_ratio
    draw_rect(Rect2(0, 0, fill_width, size.y), _fill_color)
```

**Screen-safe layout** — all HUD elements respect safe area insets (notch, home bar on mobile):

```gdscript
# hud.gd _ready():
var safe_area := DisplayServer.get_display_safe_area()
$SafeAreaMargin.add_theme_constant_override("margin_top", safe_area.position.y)
$SafeAreaMargin.add_theme_constant_override("margin_bottom", 
    ProjectSettings.get("display/window/size/viewport_height") - safe_area.end.y)
```

**CanvasLayer layers:**

| Layer | Contents | Why |
|-------|----------|-----|
| 0 | Game world (default) | Rotates with player camera |
| 1 | StateManager overlay | Transition dissolve, state UIs |
| 2 | HUD | Fixed on screen, never rotates |
| 3 | Transition (dissolve rect) | Always on top of everything |

**HUD sub-component structure:**

```
HUD (CanvasLayer, layer=2)
├── SafeAreaMargin (MarginContainer)
│   ├── TopBar (HBoxContainer)
│   │   ├── HealthGage (Gage)
│   │   ├── HungerGage (Gage)
│   │   ├── Calendar (Label)
│   │   └── StatusEffectIcons (HFlowContainer)
│   ├── BottomBar (HBoxContainer)
│   │   ├── HotBar
│   │   └── WeaponPanel
│   └── CornerButtons (VBoxContainer, anchor top-right)
│       ├── MapButton
│       └── InventoryButton
├── Minimap (Control, anchor top-right, outside safe margin)
├── NotifContainer (VBoxContainer, anchor top-center)
├── CameraEffect (ColorRect, full-screen, red vignette)
├── Controller (added dynamically by Globals.current_controller setter)
└── ModalLayer (CanvasLayer, layer=3)
    ├── InventoryPanel
    ├── CraftPanel
    ├── LootPanel
    └── ItemInfoPanel
```

The `ModalLayer` is a nested CanvasLayer at layer 3 — it sits above everything including transitions. Inventory/craft panels open inside it, so they're always readable regardless of state transitions happening underneath.

**NotifContainer** — pooled labels, not cloned:

Instead of duplicating a template label on every notification (which causes GC pressure), pre-allocate a pool of `NotifLabel` nodes:

```gdscript
# notif_container.gd
const POOL_SIZE := 15
var _pool: Array[NotifLabel] = []
var _active: Array[NotifLabel] = []

func _ready() -> void:
    for i in POOL_SIZE:
        var label := NotifLabel.new()
        label.hide()
        add_child(label)
        _pool.append(label)
    EventBus.notification_requested.connect(add_notif)

func add_notif(text: String, color: Color = Color.WHITE) -> void:
    if _pool.is_empty():
        _active.front().recycle()  # evict oldest if pool exhausted
    var label := _pool.pop_back()
    _active.push_back(label)
    label.show_notif(text, color)  # internal tween: fade in → hold → fade out → recycle
```

**LoadingState uses ChunkStreamer signal, not polling:**

```gdscript
# loading_state.gd
func _enter_tree() -> void:
    get_tree().paused = true
    PhysicsServer2D.set_active(true)  # keep physics for chunk nav baking
    EventBus.chunk_activated.connect(_on_chunk_event)
    _check_done()

func _on_chunk_event(_coord: Vector2i) -> void:
    _check_done()

func _check_done() -> void:
    if ChunkStreamer.is_initial_load_complete():
        EventBus.chunk_activated.disconnect(_on_chunk_event)
        SceneStateManager.pop_overlay()
```

No `_process` polling. The state reacts to chunk events and checks completion once per chunk load, not 60 times per second.

---

#### Checklist

**EventBus**
- ✅ `autoloads/event_bus.gd` — all signals defined; registered as autoload; no logic, only signal declarations

**SceneStateManager**
- ✅ `scene/game.tscn` — root `Node2D`: `SceneStateManager` + `HUD` (instanced hud.tscn, CanvasLayer layer=2) + `Transition` (CanvasLayer layer=3)
- ✅ `scene/states/state_defs.gd` — `const` preloads for all 6 state scenes
- ✅ `scene/states/scene_state_manager.gd` — `_stack`, `_overlays`, `_pinned`; `push_state()` / `pop_state()` async with `await transition`; `push_overlay()` / `pop_overlay()`; `replace_state()` for hard reset; lazy instantiation; pins + pushes MenuState in `_ready()`
- ✅ `scene/states/transition/transition.gd` + `.tscn` — CanvasLayer layer=3, PROCESS_MODE_ALWAYS; `play_out()` / `play_in()` via `create_tween()`, both awaitable

**States**
- ✅ `scene/states/menu_state/menu_state.gd` + `.tscn` — Continue hidden if no save; New Game / Continue push GameState with `is_new_game` flag
- ✅ `scene/states/game_state/game_state.gd` + `.tscn` — `@export is_new_game`; spawns player + controller, wires signals, day stub, 10s auto-save timer; enables/disables Pathfinder
- ✅ `scene/states/loading_state/loading_state.gd` + `.tscn` — overlay; pauses tree + keeps physics; spinner animation; auto-dismisses (Phase 4 replaces with ChunkStreamer signal)
- ✅ `scene/states/pause_state/pause_state.gd` + `.tscn` — overlay; PROCESS_MODE_ALWAYS; owns pause/unpause; Resume / Quit to Menu
- ✅ `scene/states/map_state/map_state.gd` + `.tscn` — overlay; pauses tree; drag-to-pan; player marker; Close button
- ✅ `scene/states/game_over_state/game_over_state.gd` + `.tscn` — overlay; saves on enter; Revive emits EventBus.player_revived; Main Menu replaces state

**HUD**
- ✅ `scene/hud/hud.gd` + `hud.tscn` — CanvasLayer layer=2; safe area margins in `_ready()`; typed `@onready` refs; `set_controller()` swaps controller slot; pause button
- ✅ `scene/hud/gage/gage.gd` + `.tscn` — `@export stat_type`; connects EventBus health/hunger; `_draw()` fill rect; zero `_process`
- ✅ `scene/hud/notif_container/notif_container.gd` + `.tscn` — pool of 15 Labels; connects `EventBus.notification_requested`; fade tween; `_recycle()` callback
- ✅ `scene/hud/calendar/calendar.gd` — Label; connects `EventBus.day_started`; updates text
- ✅ `scene/hud/camera_effect/camera_effect.gd` — full-screen ColorRect; connects `EventBus.player_health_changed`; remap ratio to alpha via `create_tween()`

**EventBus emission points (wired in other phases but defined now)**
- ✅ In `Player._on_health_changed()`: emits `EventBus.player_health_changed`
- ✅ In `Player.die()`: emits `EventBus.player_died`
- ✅ In `Player._on_leveled_up()`: emits `EventBus.player_levelled_up`
- ⬜ In `StatsComponent._on_hunger_changed()`: emit `EventBus.player_hunger_changed` — wired in Phase 2 stats signal, emitted when Phase 1 hunger drains
- ⬜ In `StatusEffectContainer`: emit `EventBus.status_effect_added/removed` — Phase 6
- ⬜ In `LevelStat.leveled_up`: emit `EventBus.player_level_changed` — wired via Player._on_leveled_up

**Verify**
- ✅ Game opens to menu, Continue hidden if no save file
- ✅ New Game: player visible at screen centre, health/hunger gages show, Day 1 in calendar
- ✅ WASD moves player, world visible, camera follows
- ✅ Pause button / Escape: tree pauses, resume unpauses
- ⬜ Take damage: health gage updates, vignette appears below 66% — wired, needs in-game test
- ⬜ Game Over: overlay shows, Revive works, Main Menu returns to title — wired, needs in-game test
- ✅ Notifications appear and fade out

---
### PHASE 4 — Map & World (Infinite Chunk Streaming + Procedural World Generation)

#### Plan

This is the most architecturally significant phase. We are building two tightly integrated systems:

1. **Infinite Chunk Streamer** — loads/unloads the world around the player at runtime with zero hitches
2. **Procedural World Generator** — runs once at new-game time to produce a unique, seeded world layout with key locations (school, police station, airport, etc.) placed according to design rules

Every player gets a different world. The same seed always reproduces the same world. The world can expand in future versions by adding new location types and biome rules — zero code changes.

---

#### The Two-Layer Design

```
┌─────────────────────────────────────────────────────────────┐
│  LAYER 1: World Layout (generated ONCE at new game)         │
│                                                             │
│  WorldGenerator runs → produces world_layout.json          │
│  { "seed": 42891, "chunks": { "0,0": {...}, "2,-1": {...} } │
│                                                             │
│  This is YOUR unique map. Saved with your save file.        │
└─────────────────────────────────────────────────────────────┘
                           ↓  feeds into
┌─────────────────────────────────────────────────────────────┐
│  LAYER 2: Chunk Streamer (runs CONTINUOUSLY at runtime)     │
│                                                             │
│  ChunkStreamer reads world_layout.json                      │
│  Loads/unloads chunks as player moves                       │
│  Time-sliced, 4ms/frame budget, ring-based LOD              │
└─────────────────────────────────────────────────────────────┘
```

The `WorldGenerator` is a one-shot autoload that runs during the new-game loading screen, writes `world_layout.json` to `user://`, and is never run again for that save. Loading an existing save just reads the existing `world_layout.json`.

---

#### World Coordinate System

```
Chunk coordinates: Vector2i (signed integer pairs)
  chunk (0,0)  = spawn area (city center, always fixed)
  chunk (1,0)  = one chunk east   = world position (CHUNK_SIZE, 0)
  chunk (-3,2) = valid — any signed integer pair
  
CHUNK_SIZE = 3200 units (world space pixels)

World radius for v1.0: chunks within Manhattan distance 4 from origin
  → roughly a 9×9 play area = 81 possible chunk slots
  → ~20–30 will be meaningfully populated, rest are wilderness
```

---

#### The Seed System

Every new game generates a **world seed** — a random integer stored in `world_layout.json`. All procedural decisions derive from this seed deterministically via `HashingContext` or a seeded `RandomNumberGenerator`:

```gdscript
# Per-chunk deterministic RNG — same seed + same coord = same result, always
func chunk_rng(world_seed: int, coord: Vector2i) -> RandomNumberGenerator:
    var rng := RandomNumberGenerator.new()
    rng.seed = hash(str(world_seed) + str(coord.x) + "," + str(coord.y))
    return rng
```

This means:
- Sharing your seed with a friend gives them the same world
- Reloading the game never scrambles the layout
- The save file only needs to store the seed + player-driven changes (not the entire world state)

---

#### POI (Point of Interest) System — Key Locations

**Key locations** are special chunks that contain unique hand-crafted content: school, police station, hospital, airport, military base, shopping mall, fire station, gas station strip, residential suburb, industrial zone, park, etc.

Each POI is defined in `res://data/poi_registry.json`:

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
      "scene": "res://scene/maps/chunks/poi_suburb.tscn",
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

---

#### WorldGenerator Algorithm

The generator runs once at new-game, produces a complete `world_layout.json`, and terminates. It is **time-sliced across multiple frames** using the same budget pattern as the streamer — so the loading screen progresses smoothly instead of freezing for a moment.

**Generation pipeline (executed in order):**

```
Step 1: SEED          — generate or accept player-entered seed
Step 2: BIOME_MAP     — assign biome to every chunk coordinate in play radius
Step 3: ROAD_NETWORK  — generate road skeleton connecting origin to key zones
Step 4: POI_PLACEMENT — place key locations using constraint-satisfaction rules
Step 5: FILL          — fill remaining chunks with contextual content (houses, wilderness, etc.)
Step 6: FINALIZE      — write world_layout.json to user://
```

**Step 2 — Biome Map:**
Biomes are concentric zones radiating from the origin:
```
Distance 0:   city_center   (dense buildings, roads, high danger)
Distance 1–2: city          (mixed buildings, roads)
Distance 2–3: suburb        (houses, parks, schools)
Distance 3–4: outskirts     (industrial, sparse)
Distance 4+:  wilderness    (forest/empty, very sparse)
```
Biome boundaries are **jittered** using per-chunk hash noise so they feel organic rather than perfectly circular. A chunk at distance 2 has an 80% chance of being "city" and 20% chance of "suburb" based on its hash.

**Step 3 — Road Network:**
A **minimum spanning tree** connects the origin to each POI candidate zone. Roads follow chunk-grid paths. This guarantees every POI is reachable from spawn without getting lost in wilderness. Road chunks use the procedural TileMap generator (`map.gd`) to draw roads with pavement.

**Step 4 — POI Placement (the core algorithm):**

Uses a **constraint-satisfaction placement** loop with these rules enforced simultaneously:
- `min_distance_from_origin` ≤ Manhattan distance from (0,0) ≤ `max_distance_from_origin`
- Manhattan distance to every already-placed POI ≥ `min_distance_from_other_pois`
- Chunk's biome matches `biome` field (or `"any"`)
- Chunk not already occupied

Algorithm:
```
for each POI definition (sorted by most_constrained first):
    candidates = all valid chunk coords satisfying constraints
    if candidates is empty:
        relax min_distance_from_other_pois by 1 and retry (max 3 times)
    pick = candidates[chunk_rng(seed, coord).randi() % candidates.size()]
    assign POI to pick
    mark pick as occupied
```

"Most constrained first" (airport, military base before gas stations) ensures the rarest, hardest-to-place POIs get priority access to valid slots. Gas stations and suburbs, being flexible, fill whatever remains.

**Step 5 — Fill:**
Any unoccupied chunk within the play radius gets a filler assigned based on its biome:
- city_center/city → random city block scene (mixed buildings, alleys)
- suburb → random residential block
- outskirts → industrial / sparse scene
- wilderness → default wilderness scene

All filler choices are deterministic from `chunk_rng(seed, coord)`.

---

#### Output: `world_layout.json`

```json
{
  "seed": 48291,
  "version": 1,
  "chunks": {
    "0,0":  { "scene": "res://scene/maps/chunks/city_center.tscn",      "biome": "city_center", "poi": null },
    "1,0":  { "scene": "res://scene/maps/chunks/city_block_a.tscn",     "biome": "city",        "poi": null },
    "-2,1": { "scene": "res://scene/maps/chunks/poi_police_station.tscn","biome": "city",        "poi": "police_station" },
    "3,-2": { "scene": "res://scene/maps/chunks/poi_airport.tscn",      "biome": "outskirts",   "poi": "airport" },
    "0,1":  { "scene": "res://scene/maps/chunks/poi_hospital.tscn",     "biome": "city",        "poi": "hospital" },
    "4,1":  { "scene": "res://scene/maps/chunks/wilderness.tscn",       "biome": "wilderness",  "poi": null }
  },
  "roads": [["0,0","1,0","2,0","-1,0"], ["0,0","0,1","0,2"]],
  "poi_locations": {
    "police_station": "-2,1",
    "hospital": "0,1",
    "airport": "3,-2"
  }
}
```

At runtime, `ChunkStreamer` reads `world_layout.json` instead of the static `world_registry.json`. The rest of the streaming system is unchanged — it still uses the same ring/budget/state-machine architecture.

---

#### Save System Integration

**New game:** `WorldGenerator.generate(seed)` → writes `user://world_layout.json` → `ChunkStreamer` loads it
**Continue game:** `ChunkStreamer` reads existing `user://world_layout.json` (no regeneration)
**Player changes** (placed objects, looted chests, killed enemies) are stored in the existing `regions` dict in `savegame.json` as before — keyed by `"x,y"` chunk coordinate string.

The world layout never changes after generation. Only the delta (player actions) is saved.

---

#### Minimap & Discovery

POI locations are revealed progressively:
- Unknown: chunk shows as dark/fog on minimap
- **Scouted**: player enters the chunk's buffer ring → chunk outline appears on minimap with `?` marker
- **Discovered**: player physically enters the chunk → full label appears (e.g. "Police Station")
- `poi_locations` dict in `world_layout.json` lets the minimap render POI icons once discovered

This is stored per-save in `savegame.json` under `"discovered_chunks": ["0,0", "-2,1", ...]`.

---

#### Chunk Scene Contract (unchanged from streaming design)

Each chunk `.tscn` follows the same interface:
```
ChunkRoot (Node2D, chunk_base.gd)
├── TileMap           ← terrain
├── NavRegion         (NavigationRegion2D)
├── StaticObjects     (Node2D)  ← in "obstacle" group
├── Spawners          (Node2D)  ← Horde / Zone / Ambush
├── Houses            (Node2D)  ← House variant scenes
└── Objects           (Node2D)  ← dynamic, serializable
```

POI chunks just have richer content in these same slots — a police station chunk has more houses, specific spawners, preset chest configurations, and higher-tier loot tables. No changes to chunk_base.gd.

---

#### Updated Project Structure for Phase 4

```
res://
├── autoloads/
│   ├── chunk_streamer.gd     ← runtime world streaming (reads world_layout.json)
│   └── world_generator.gd   ← one-shot new-game generator (writes world_layout.json)
├── data/
│   ├── poi_registry.json     ← POI definitions (id, scene, placement rules, loot tier)
│   └── biome_rules.json      ← biome ring radii + jitter config
└── scene/
    └── maps/
        ├── chunk_base.gd
        ├── map.gd             ← TileMap road/building generator
        ├── zone/zone.gd
        └── chunks/
            ├── city_center.tscn
            ├── city_block_a.tscn, city_block_b.tscn, ...
            ├── suburb_a.tscn, suburb_b.tscn, ...
            ├── outskirts_a.tscn, ...
            ├── wilderness.tscn          ← fallback
            ├── poi_police_station.tscn
            ├── poi_hospital.tscn
            ├── poi_school.tscn
            ├── poi_airport.tscn
            ├── poi_military_base.tscn
            ├── poi_mall.tscn
            ├── poi_gas_station.tscn
            └── poi_suburb_residential.tscn
```

---

#### Checklist

**World Generator**
- ✅ `autoloads/world_generator.gd` — singleton: `generate(seed: int)` runs full pipeline; `_step_biome_map()`, `_step_road_network()`, `_step_poi_placement()`, `_step_fill()`, `_step_finalize()`; time-sliced with same `BUDGET_US = 4000` pattern; emits `generation_complete` signal when done; writes `user://world_layout.json`
- ✅ `data/poi_registry.json` — all POI definitions with placement constraints (see schema above): police_station, hospital, school ×2, airport, military_base, shopping_mall, gas_station ×3, suburb_residential ×8
- ✅ `data/biome_rules.json` — ring radii config: `{"city_center": 0, "city": [1,2], "suburb": [2,3], "outskirts": [3,4], "wilderness": 5, "jitter_strength": 0.25}`
- ✅ Seeded RNG helper: `chunk_rng(world_seed, coord)` → deterministic `RandomNumberGenerator` per coordinate
- ✅ Biome assignment: `_get_biome(coord, seed)` → biome string; uses Manhattan distance + hash jitter
- ✅ Road network: `_step_road_network()` → BFS path connecting origin to all guaranteed POIs; output stored in `world_layout["roads"]`
- ✅ POI placement: sorted most-constrained-first; constraint check (distance, biome, occupied); relaxation fallback (up to 3 retries with loosened `min_distance_from_other_pois`); records `poi_locations` dict
- ✅ Fill pass: assigns filler scene to every unoccupied chunk within play radius using `chunk_rng`
- ✅ `user://world_layout.json` output — schema: `{seed, version, chunks: {"x,y": {scene, biome, poi}}, roads, poi_locations}`

**Chunk Streamer (updates from base design)**
- ✅ `autoloads/chunk_streamer.gd` — reads `user://world_layout.json` instead of static registry; `_get_chunk_scene(coord)` looks up layout first, falls back to wilderness if coord not in layout; all ring/budget/state-machine logic unchanged
- ✅ `ChunkState` enum: `UNLOADED, QUEUED, LOADING, INSTANTIATING, NAV_BAKING, ACTIVE, UNLOADING`
- ✅ Ring constants: `ACTIVE_RADIUS = 1`, `BUFFER_RADIUS = 2`, `PREFETCH_RADIUS = 3`, `HYSTERESIS = 1`
- ✅ Time-sliced `_process(delta)`: `BUDGET_US = 4000`; priority queue sorted by Manhattan distance to player chunk
- ✅ Hysteresis unload guard; player chunk tracker (only diffs on chunk coord change)
- ✅ Async nav bake via `NavigationServer2D.bake_from_source_geometry_data_async()`
- ✅ `spawn_sound(origin, radius)`, `spawn_drop_items(items_data, pos)` stubs (Phase 17)
- ✅ Floating origin stub: `_check_origin_shift()` fires when player > 8000 units from world origin

**Discovery System**
- ⬜ `discovered_chunks: Array` in save data — list of `"x,y"` strings; populated when player enters buffer ring of a chunk (Phase 17)
- ⬜ Minimap: renders fog for undiscovered chunks; outline + `?` for scouted; full label + POI icon for discovered (Phase 17)
- ⬜ `Globals.poi_locations` — populated from `world_layout["poi_locations"]` at game start; used by minimap and future quest system (Phase 17)

**Chunk Scenes (stubs for now, content in Phase 17)**
- ✅ `city_center.tscn` — origin chunk stub
- ✅ `city_block_a/b/c.tscn` — 3 city block variant stubs
- ✅ `suburb_a/b.tscn` — 2 suburb variant stubs
- ✅ `outskirts_a.tscn` — industrial/sparse stub
- ✅ `wilderness.tscn` — fallback stub
- ✅ `poi_police_station.tscn` — POI stub
- ✅ `poi_hospital.tscn` — POI stub
- ✅ `poi_school.tscn` — POI stub
- ✅ `poi_airport.tscn` — POI stub
- ✅ `poi_military_base.tscn` — POI stub
- ✅ `poi_mall.tscn` — POI stub
- ✅ `poi_gas_station.tscn` — POI stub
- ✅ `poi_suburb_residential.tscn` — POI stub
- ✅ `scene/maps/chunk_base.gd` — Node2D base: `chunk_coord`, `activate()`/`deactivate()`, `_on_activated()`/`_on_deactivated()` virtual hooks
- ✅ `map.gd` — TileMap stub: `generate_road()`, `place_house()` (Phase 17)
- ✅ `zone/zone.gd` — Area2D daily spawn; activated only when chunk is ACTIVE

**Verify**
- ⬜ New game: generator runs, `world_layout.json` written, different seed = different POI positions
- ⬜ Same seed entered twice = identical POI layout (deterministic)
- ⬜ Walk to chunk boundary → buffer chunk loads smoothly within budget (no frame spike >16ms)
- ⬜ Walk to scouted POI chunk → chunk activates, POI label appears on minimap (Phase 17)
- ⬜ Save + quit + continue → `world_layout.json` persists, same POI positions on reload (Phase 14)

---
### PHASE 5 — House System

#### Plan
Houses are the primary source of loot and indoor enemies. Each house is a pre-built static body with a roof that fades when the player enters, an interior collision shape, and a spawner that runs once per game day.

**Daily spawn:** Houses connect to `DayNightCycle.day_started` **only when visible on screen** (connected in `screen_entered`, disconnected in `screen_exited`). This avoids unnecessary signal processing for distant houses. Each day: spawn up to `capacity` enemies from the house's `enemies` JSON config, and scatter loot drops from the `loots` JSON config within the house bounds.


**Roof fade:** A separate `Roof` node (child of House) with its own `CollisionShape2D` detection area. When the player enters: `create_tween()` fades `modulate.a` from 1.0 to 0.0 over 0.3s. On exit: fades back. This gives the effect of the roof becoming transparent while inside.

**10 house variants:** Each is a unique `.tscn` file (House1–House10) with different tilemap layouts, sizes, and door positions. They all inherit the same `House` base script. Enemy and loot configs are set as exported string properties in the inspector.

**`cur_house` tracking:** When player enters a house body sensor, `Globals.cur_house = self`. When player exits, `Globals.cur_house = null`. This is used by the placable system to know whether to parent placed objects to the house's objects container or to the map.

#### Checklist
- ⬜ `scene/entities/houses/house.gd` — StaticBody2D: `@export capacity: int`, `@export enemies_json: String`, `@export loots_json: String`; `screen_entered` → connect to `day_started`; `screen_exited` → disconnect; `spawner(day)`: `spawn_enemies()` + `spawn_loots()` if day not already spawned; body entered/exited → `Globals.cur_house`
- ⬜ `scene/entities/houses/roof.gd` — Node2D: detection Area2D; `body_entered` → tween alpha 0; `body_exited` → tween alpha 1
- ⬜ Create `house1.tscn` through `house10.tscn` — varied floor plans using TileMap; each has Roof node, ObjectsContainer node, interior collision
- ⬜ Verify: enter house, roof fades; enemies present (if any); day passes, new enemies spawn next visit

---

### PHASE 6 — Enemy System

#### Plan

This phase implements the full enemy — the CharacterBody2D that uses the BT from Phase 6, the three-tier movement from Phase 6, a proper visual component architecture, and a correct aggro/awareness system. Enemy serialization is handled in Phase 14.

---

#### Diagnosis: Problems With the Original

| # | Problem | Impact |
|---|---------|--------|
| 2 | **`opponent` is an Array — only `opponent[0]` ever matters** | The array is misleading. It's used as a nullable ref (`opponent.empty()` = no target). Using a plain `var opponent: Node = null` is cleaner and idiomatic. |
| 3 | **`dead()` calls `Globals.mapManager.add_child(drop)` directly** | Enemy knows about MapManager. Any enemy killed inside a house would parent drops to the wrong node. Drops should be parented to the enemy's own parent. |
| 4 | **`hurt()` returns XP as `data.stats.exp.val` or `false`** — mixed return types | The caller must type-check the return. Use a dedicated signal or let the stats system handle XP. |
| 5 | **`setBehavior()` calls `Factory.enemies.behaviors[value].instance()`** — creates a NEW BT scene | This happens on every aggro state change. Should reuse the BTTreeResource from Phase 5, not re-instance a scene. |
| 6 | **`_on_View_body_exited` completely resets path** | When the player hides behind a wall briefly, the zombie instantly forgets everything and resumes wandering. Enemies should remember the last known position. |
| 7 | **`_on_area_area_entered` reparents enemy when crossing chunk boundary** — deferred, fragile | The enemy's parent is determined by which chunk it was spawned in. A moving enemy should be parented to the MapManager/ChunkStreamer root, not to a specific chunk. |
| 8 | **Vision is an array of RayCast2D children — re-queried every tick** | `$Vision.get_children()` is called every BT tick. Should cache the array at init. |
| 9 | **Attack landed iterates `agent.enemiesAbleToAttack` by name** — calls `opponent.hurt(attack_dmg)` with no source reference | Damage system from Phase 1 needs `hurt(amount, source)`. The source is used for XP, status effects, and kill attribution. |
| 10 | **`growl()` called in `_process` using `randi()%1000`** | Randomly calling every frame wastes RNG. Use a timer with randomized interval instead. |

---

#### Enemy Scene Structure

```
Enemy (CharacterBody2D, enemy.gd)
├── StatsComponent (Node)             ← Phase 1 stat system
├── StatusEffectContainer (Node)      ← Phase 1
│
├── CollisionShape2D                  ← capsule, main physics body
│
├── VisualRoot (Node2D)               ← counter-rotated each frame (like player)
│   ├── Shadow (Sprite2D)
│   ├── LowerBody (Node2D)
│   │   ├── Sprite2D                  ← legs sprite atlas
│   │   └── AnimationTree             ← BlendSpace2D: idle/walk 8-dir
│   └── UpperBody (Node2D)
│       ├── Sprite2D                  ← torso sprite atlas
│       └── AnimationTree             ← StateMachine: idle/hurt/attack
│
├── BTRunner (Node)                   ← Phase 5: Blackboard + tick rate
│
├── NavigationAgent2D                 ← Phase 5: tier-2 movement
│
├── VisionCone (Node2D)               ← cached RayCast2D array
│   └── [RayCast2D × N]               ← N = vision_width / ANGLE_STEP
│
├── AttackHitBox (Area2D)             ← enabled by animation markers
│   └── CollisionShape2D
│
├── AggroArea (Area2D)                ← herd propagation radius
│   └── CollisionShape2D              ← radius = aggression_range stat
│
├── GrowlTimer (Timer)                ← randomized, replaces per-frame random check
│
└── VisibilityNotifier (VisibleOnScreenNotifier2D)
```

**Key changes from original:**
- `VisualRoot` counter-rotated (same trick as player) — visual always faces up on screen
- `VisionCone` rays cached at init, not queried via `get_children()` each tick
- `GrowlTimer` replaces the per-frame `randi()%1000` check
- `AggroArea` replaces the `$bodySensor/Collider` magic path
- No `BlockerSensor` — the three-tier movement from Phase 5 handles obstacle awareness

---

#### Last Known Position + Search Behavior

Instead of instantly forgetting the player when line-of-sight is lost, enemies remember `_last_known_pos` in the blackboard. The BT uses this for a short "search" phase:

```
HasOpponent → TRUE: chase toward opponent (live position)
HasOpponent → FALSE but LastKnownPos exists:
    → Move to last known pos (search mode, ~3-5s)
    → If player found: re-aggro
    → Timer expires: clear last known pos, return to wander
```

This is written into the BT tree as a condition leaf `HasLastKnownPos` and an action leaf `NavigateToLastKnown`. It makes zombies feel more intelligent at almost zero cost.

---

#### Herd Aggro — EventBus-Based

The original used `_on_bodySensor_body_entered` to directly call `_opponent._on_View_body_entered()` on nearby enemies. This tightly couples enemy nodes together.

The new approach uses the **EventBus** from Phase 3:

```gdscript
# When this enemy aggros:
func _set_opponent(new_opponent: Node) -> void:
    _opponent = new_opponent
    _blackboard[BlackboardKeys.OPPONENT] = new_opponent
    _is_persistent = true
    EventBus.enemy_aggroed.emit(global_position, new_opponent)  # broadcast

# Other enemies with AggroArea listen:
# In AggroArea.body_entered (only fires for other Enemy nodes):
func _on_aggro_area_body_entered(body: Node) -> void:
    if body is Enemy and body._opponent == null:
        # Nearby idle enemy: inherit the aggroing enemy's target
        EventBus.enemy_aggroed.connect(body._on_herd_aggro, CONNECT_ONE_SHOT)
```

But to avoid O(N²) connections, the simpler pattern is the **proximity broadcast via AggroArea**:

```gdscript
# When this enemy aggros, it expands its AggroArea radius:
func _set_opponent(opponent: Node) -> void:
    _opponent = opponent
    _aggro_area.shape.radius = stats.aggression_range.value  # expand radius
    # Other enemies inside the radius will catch the area_entered signal
    # and call their own _on_neighbor_aggroed()

# Neighboring idle enemy receives the signal:
func _on_neighbor_aggroed(aggroing_enemy: Enemy) -> void:
    if _opponent != null: return   # already has a target
    _set_opponent(aggroing_enemy._opponent)  # inherit target
```

This is still O(N) for the number of enemies in range, but there's no persistent connection per-pair — it fires once when the aggro radius expands.

---

#### Attack System Redesign

Attacks are `RefCounted` resources (matching the BTTask pattern from Phase 5) rather than scene-tree Nodes. Each attack type implements:

```gdscript
class_name EnemyAttack extends RefCounted

func prepare(enemy: Enemy) -> void: pass    # setup hitbox geometry
func execute(enemy: Enemy) -> void: pass    # trigger animation
func is_active(enemy: Enemy, delta: float) -> bool: return false  # RUNNING check
func resolve(enemy: Enemy) -> void: pass    # apply damage to hit targets
```

`MeleeAttack.prepare()` sizes the hitbox, `execute()` plays the attack animation via the upper body AnimationTree, `is_active()` returns true while the animation plays, `resolve()` iterates the hitbox overlap array and calls `opponent.hurt(damage, enemy)` (source ref included).

`ChargeAttack` uses the `ForceEffect` from Phase 1's stat system — no more ad-hoc `ApplyForce` resource.

---

#### Checklist

**Core enemy**
- ⬜ `scene/entities/enemies/enemy.gd` — extends Entity: `_opponent: Node = null`, `_blackboard` ref (from BTRunner), `_vision_rays: Array[RayCast2D]` (cached), `_move_tier: MoveTier`; `_ready()`: cache vision rays, connect notifier signals, connect `stats.aggression_range.changed`; `_physics_process(delta)`: branch on `_move_tier` (Phase 5 three-tier); `_set_opponent(node)`: set blackboard + `_is_persistent` + expand AggroArea; `_update_move_tier(delta)` (1Hz check); `hurt(amount, source)` creates blood + plays hurt animation; `die()` spawns drops as siblings (not via MapManager), emits `EventBus.enemy_died`
- ⬜ `scene/entities/enemies/enemy.tscn` — full node hierarchy as above
- ⬜ `_last_known_pos: Vector2` — set in blackboard when opponent last seen; cleared after search timer
- ⬜ `GrowlTimer` connected: `timeout` → play growl + randomize `wait_time` (randf_range 3.0, 12.0)
- ⬜ `VisualRoot` counter-rotation: `visual_root.rotation = -rotation` each `_physics_process` frame
- ⬜ Vision rays cached: `_vision_rays = $VisionCone.get_children()` in `_ready()` (not `get_children()` per tick)

**Body / Animation**
- ⬜ `scene/entities/enemies/body/` — `LowerBody` with `AnimationTree` BlendSpace2D (8-dir walk; blend pos = local velocity); `UpperBody` with `AnimationTree` StateMachine (idle/hurt/attack); `attack_landed` and `attack_finished` via CallMethod animation tracks; exposed `play_upper(state: StringName)` method
- ⬜ Body `AnimationTree` driven by enemy movement velocity each physics frame (same pattern as player Phase 2)

**Attacks**
- ⬜ `scene/entities/enemies/attacks/enemy_attack.gd` — base `RefCounted`: `prepare(enemy)`, `execute(enemy)`, `is_active(enemy, delta) -> bool`, `resolve(enemy)` — calls `target.hurt(amount, enemy)` for each body in hitbox overlap array
- ⬜ `scene/entities/enemies/attacks/melee_attack.gd` — `prepare()`: size hitbox CollisionShape2D from `attack_range * size` stats; `execute()`: `enemy.body.play_upper("attack")`; `is_active()`: upper animation still playing; `resolve()`: applies status effects via Phase 1 factory
- ⬜ `scene/entities/enemies/attacks/charge_attack.gd` — `prepare()`: extend forward reach; `execute()`: apply `ForceEffect` (Phase 1 tick effect) toward opponent; `is_active()`: force still active; `resolve()`: damage applied continuously during charge


**Herd aggro**
- ⬜ `AggroArea` shape radius starts at 0; on `_set_opponent()` expands to `aggression_range.value`; on opponent cleared (search timer expired) shrinks back to 0
- ⬜ `_on_aggro_area_body_entered(body)`: if `body is Enemy and body._opponent == null` → `body._set_opponent(_opponent)`
- ⬜ `EventBus.enemy_aggroed` signal emitted on `_set_opponent()` — for sound radius, minimap indicators, future quest system hooks

**Spawners**
- ⬜ `scene/entities/enemies/spawner/horde.gd` — `Area2D`; on `_ready()` scattered spawn of `count` enemies within `radius`; uses `EnemyFactory.create_many()`
- ⬜ `scene/entities/enemies/spawner/ambush.gd` — triggered arena: player position clamped within bounds; spawns waves while `life_timer > 0`; releases player when timer expires AND enemy count = 0

**Factory**
- ⬜ `autoloads/factory/enemy_factory.gd` — reads `enemies.json`; preloads: `Enemy.tscn`, body sprite atlases per type, `BTTreeResource` assets (not .tscn), growl `AudioStream` resources, attack class references; `create(type_id, position, rotation) -> Enemy`; `create_many(count, type_id, scatter_rect) -> Array[Enemy]`

**Verify**
- ⬜ Spawn enemy, bring player nearby: enemy aggros via vision rays (not every physics frame — only BT tick rate)
- ⬜ Player moves off-screen while being chased: enemy stays aggroed and `_is_persistent` flag remains true
- ⬜ Save while enemy is aggroed off-screen: reload → enemy re-spawns at saved position, immediately resumes chase
- ⬜ Save while enemy is idle off-screen: reload → enemy is NOT in save file, re-spawned fresh by house system
- ⬜ Enemy loses sight of player: moves to `_last_known_pos`, searches ~4s, gives up and wanders
- ⬜ One aggroed enemy alerts two nearby idle enemies via AggroArea expansion
- ⬜ Enemy killed: drops spawn as siblings; save/reload behaviour verified in Phase 14
- ⬜ 100 enemies active: confirm three-tier movement from Phase 5 is live (debug tier counter visible)

---
### PHASE 7 — Behavior Tree + Pathfinder

#### Plan

The behavior tree (BT) is the core AI decision engine. The original implementation worked well for its scope but has several structural problems that will compound as more enemy types are added. This phase redesigns it with the industry-standard **Blackboard pattern**, **ticked execution** with configurable rate, and a **clean NavigationAgent2D integration** that replaces the hand-rolled pathfinder queue.

---

#### Diagnosis: Problems With the Original

| # | Problem | Impact |
|---|---------|--------|
| 1 | **No Blackboard — leaves reach directly into `agent.*`** | Every leaf knows the enemy's internal structure. `isOpponentNeerby.gd` calls `agent._on_View_body_exited()`, `agent.opponent = alive`, etc. Leaves are tightly coupled to Enemy and can't be reused across entity types. |
| 2 | **BT runs every physics frame via `behavior.run(delta)` in `_process`** | 60 ticks/sec per enemy. At 20 enemies = 1,200 BT evaluations/sec. The original had vision scanning happening every tick — that's 20 × raycast-fan every frame. |
| 3 | **Tasks are Nodes — each enemy has its own duplicate scene tree** | Every enemy instance has ~25 Node children just for AI. Each Node in Godot has overhead: signal connections, memory allocation, scene-tree traversal. For 20+ enemies this adds up. |
| 4 | **`generatePath.gd` calls `Navigation2DServer.map_get_path()` synchronously on the main thread** | Blocks the frame while computing the path. Should use `NavigationAgent2D` which handles this asynchronously via the navigation server's worker thread. |
| 5 | **Path managed as `agent.path: Array` walked manually** | Enemy pops waypoints when within 10 units. If nav mesh changes (chunk load), the stale array path causes enemies walking through walls. `NavigationAgent2D` handles live path updates automatically. |
| 6 | **Pathfinder singleton batches all agents every 0.5s on a manual Thread** | This was a workaround for the sync path problem. With `NavigationAgent2D`, the engine's navigation server handles threading natively — no custom Thread needed. |
| 7 | **`isOpponentNeerby` validates the opponent array mid-BT tick** | `isOpponentNeerby.gd` filters dead opponents (`is_instance_valid`), mutates `agent.opponent`, and calls `_on_View_body_exited` — complex side effects in a condition node. |
| 8 | **`Wait` decorator has a bug** — `timer = 0` in `start()`, but checks `if timer < 0` which is never true initially | The wait never waits — it immediately runs the child on the first tick. |
| 9 | **`Repeat` calls `get_child(0).run()` with no arguments when repeating** | `run()` requires `delta` parameter. This is a runtime error in GDScript strict mode. |
| 10 | **No tick rate control** — all enemies tick at 60Hz regardless of distance | Enemies far from the player should tick less often. No mechanism exists to throttle distant AI. |

---

#### Architecture Decision: Keep BT, Add Blackboard + Tick Rate

**BT is the right choice for this game.** It's readable, designer-friendly, and well-suited to the clear priority logic (attack if in range > chase if can see > wander). GOAP and Utility AI add complexity that isn't justified for zombie archetypes.

**The two improvements that matter most:**

1. **Blackboard** — a simple `Dictionary` per agent that all BT nodes read/write instead of touching `agent.*` directly. Leaves stay decoupled and reusable.

2. **Configurable tick rate** — BT doesn't need to run at 60Hz. Run it at 10Hz for distant enemies, 20Hz for mid-range, 30Hz for close enemies. Vision raycasts only fire during BT ticks, not every physics frame.

---

#### The Blackboard Pattern

The Blackboard is a `Dictionary` attached to each agent. BT nodes read and write keys by name — they never import or reference the enemy class:

```gdscript
# Blackboard keys (string constants defined once)
const BB_OPPONENT       := &"opponent"       # Node or null
const BB_DESTINATION    := &"destination"    # Vector2
const BB_ATTACK_TIMER   := &"attack_timer"   # float
const BB_IS_BLOCKED     := &"is_blocked"     # bool
const BB_PATH_READY     := &"path_ready"     # bool
const BB_LAST_KNOWN_POS := &"last_known_pos" # Vector2

# In leaf — reads blackboard, never touches agent internals:
func tick(blackboard: Dictionary, agent: Node, delta: float) -> Status:
    var opponent: Node = blackboard.get(BB_OPPONENT)
    if opponent == null or not is_instance_valid(opponent):
        blackboard[BB_OPPONENT] = null
        return Status.FAILURE
    return Status.SUCCESS
```

The enemy script populates keys the BT cannot know itself (physics events, sensor results). The BT reads and modifies keys but never calls methods on the agent directly — except for `agent.move_toward(target)` style action calls, which are explicit, named, and stable contracts.

**What enemy still owns (never in blackboard):**
- Physics (`velocity`, `move_and_slide`)
- Vision detection (raycast results → writes to blackboard)
- Animations (reads from movement state)
- Serialization (handled in Phase 14)

**What lives in the blackboard (shared between BT and enemy):**
- `opponent` ref
- `destination` vector
- `attack_timer` float
- `is_blocked` bool
- `last_known_pos` vector

---

#### Tasks as Resources (not Nodes)

The original used Nodes. The standard approach for high-count AI is **Resources or plain GDScript Objects** — no scene tree overhead.

**Why Resources:**
- No scene-tree allocation per enemy (no signal bus registration, no `_ready()` call, no parent/child traversal)
- The BT structure is defined once as a `Resource` tree and shared across all instances of the same enemy type
- Per-instance state lives in the **Blackboard** dict, not in the task nodes themselves — so the shared resource tree is safely stateless

```gdscript
# task.gd — extends RefCounted (no Node overhead)
class_name BTTask extends RefCounted

enum Status { SUCCESS, FAILURE, RUNNING }

func tick(blackboard: Dictionary, agent: Node, delta: float) -> Status:
    return Status.SUCCESS  # override in subclass
```

**The tree is assembled in code (factory method) or via a `BTTreeResource`** — a custom Resource with `@export var root: BTTask`. This can be edited in the Godot inspector using nested Resources.

**Why this is fine for the editor workflow:** The original used Nodes to get visual tree editing. With Godot 4's nested Resource editing, a `BTTreeResource` shows the full tree visually in the inspector. No scene tree needed.

**Composites** hold `@export var children: Array[BTTask]` — the tree structure is the resource tree.

---

#### BT Execution: Ticked, Not Framed

The BT does **not** run in `_physics_process`. Instead, each enemy has a `BTRunner` component node that ticks on a configurable timer:

```gdscript
# bt_runner.gd — Node child of Enemy
class_name BTRunner extends Node

@export var tree: BTTreeResource
@export var tick_interval: float = 0.1  # 10Hz default

var _blackboard: Dictionary = {}
var _agent: Node
var _timer: float = 0.0

func init(agent: Node) -> void:
    _agent = agent
    tree.root.setup(_blackboard, _agent)  # one-time init

func _physics_process(delta: float) -> void:
    _timer += delta
    if _timer >= tick_interval:
        _timer = 0.0
        tree.root.tick(_blackboard, _agent, tick_interval)

func set_tick_rate_by_distance(dist: float) -> void:
    if dist < 400.0:   tick_interval = 0.05   # 20Hz — close combat
    elif dist < 1200.0: tick_interval = 0.1   # 10Hz — mid range
    else:               tick_interval = 0.3   # 3Hz  — distant/idle
```

The enemy updates `_runner.set_tick_rate_by_distance()` whenever the player distance changes meaningfully (not every frame — use a threshold check).

**Vision raycasts only fire during BT ticks** — the raycast fan is cast in `is_opponent_on_view.gd`'s `tick()` method, not in `_physics_process`. At 10Hz that's 10 raycasts/sec per enemy instead of 60.

---

#### NavigationAgent2D Replaces the Manual Pathfinder

The custom `Pathfinder` singleton with manual threading is replaced by **each enemy owning a `NavigationAgent2D`** node — the Godot 4 standard. The nav server handles all threading internally.

```gdscript
# In enemy._physics_process():
if not _nav_agent.is_navigation_finished():
    var next_pos := _nav_agent.get_next_path_position()
    var dir := global_position.direction_to(next_pos)
    velocity = dir * stats.move_speed.value + applied_force
    move_and_slide()
    _rotate_toward(dir, delta)
```

**Path requests:** The BT leaf `RequestPath` simply sets `_nav_agent.target_position = destination`. The nav server computes the path asynchronously. The `PathReady` leaf checks `_nav_agent.is_target_reached() == false and _nav_agent.get_current_navigation_path().size() > 0`.

**NavigationAgent2D key settings:**
```
path_desired_distance: 10.0      ← how close to waypoint before advancing
target_desired_distance: 20.0    ← how close to target to consider "arrived"
path_max_distance: 50.0          ← how far off path before recalculating
avoidance_enabled: true          ← built-in RVO2 local avoidance
```

**RVO2 avoidance** is `NavigationAgent2D`'s built-in feature — enemies automatically avoid each other during navigation without any custom code. The old "blocker sensor + charge attack on obstacles" logic is no longer needed for navigation.

The `Pathfinder` autoload is **retired entirely**.

---

#### Tick Rate + Distance Throttling (LOD AI)

This is the key optimization for mobile with 20+ enemies:

```
Distance < 400u:    tick at 20Hz  (0.05s)  ← active combat
Distance 400–1200u: tick at 10Hz  (0.10s)  ← aware, chasing
Distance > 1200u:   tick at  3Hz  (0.33s)  ← idle wandering
Off-screen:         tick at  1Hz  (1.00s)  ← minimum heartbeat
```

The enemy's `VisibleOnScreenNotifier2D` signals set the off-screen rate. Distance is checked once per second (not every frame) by sampling `_nav_agent.distance_to_target()`.

At 20 enemies with this LOD:
- 5 close: 100 ticks/sec
- 10 mid: 100 ticks/sec  
- 5 distant: 15 ticks/sec
- **Total: ~215 ticks/sec** vs the original **1,200 ticks/sec**

---

#### Assembled BT Trees (data, not scenes)

```
WanderTree (BTTreeResource)
└── Selector
    └── Sequence
        ├── FindDestination       — sets blackboard[BB_DESTINATION]
        ├── RequestPath           — sets nav_agent.target_position
        └── NavigatePath          — running while not arrived; success when arrived

BasicAITree (BTTreeResource)
└── Selector
    ├── Sequence  [combat branch — has_opponent check gates this]
    │   ├── HasOpponent           — checks blackboard[BB_OPPONENT]
    │   ├── ValidateOpponent      — clears stale opponent refs
    │   └── Selector
    │       ├── Sequence  [in range → attack]
    │       │   ├── IsOpponentInRange     — nav_agent.distance_to_target()
    │       │   ├── AttackCooldownReady   — checks blackboard[BB_ATTACK_TIMER]
    │       │   ├── ChooseAttack
    │       │   └── ExecuteAttack
    │       └── Sequence  [out of range → chase]
    │           ├── SetChaseDestination   — blackboard[BB_DESTINATION] = opponent.pos
    │           ├── RequestPath
    │           └── NavigatePath
    └── WanderTree  [fallback wander when no opponent]

ChaseTree (BTTreeResource)
└── Sequence
    ├── SetPlayerAsOpponent       — blackboard[BB_OPPONENT] = Globals.player
    └── BasicAITree [subtree ref]
```

Subtree references allow composition without duplication — `ChaseTree` reuses `BasicAITree` as a data reference, not a copy.

---

#### Blackboard Keys as Typed Constants

```gdscript
# ai/blackboard_keys.gd — static class, no instance needed
class_name BlackboardKeys

const OPPONENT        := &"opponent"
const DESTINATION     := &"destination"
const ATTACK_TIMER    := &"attack_timer"
const IS_ATTACKING    := &"is_attacking"
const LAST_KNOWN_POS  := &"last_known_pos"
const WANDER_TIMER    := &"wander_timer"
```

All leaves import this. StringName constants (`&"..."`) are interned — comparison is O(1) pointer equality, not string comparison.

---

#### File Structure

```
ai/
├── blackboard_keys.gd           ← StringName constants
├── bt_task.gd                   ← base RefCounted: tick(bb, agent, delta) → Status
├── bt_runner.gd                 ← Node child of Enemy: owns blackboard + tick timer
├── bt_tree_resource.gd          ← Resource: @export var root: BTTask
├── composites/
│   ├── bt_sequence.gd           ← all children must succeed
│   ├── bt_selector.gd           ← first child to succeed wins
│   ├── bt_parallel.gd           ← all run simultaneously
│   ├── bt_random_sequence.gd
│   └── bt_random_selector.gd
├── decorators/
│   ├── bt_invert.gd
│   ├── bt_repeat.gd             ← fixed: pass delta to child.tick()
│   ├── bt_until_fail.gd
│   ├── bt_until_success.gd
│   ├── bt_limit.gd
│   ├── bt_wait.gd               ← fixed: timer starts from wait_time, counts down
│   ├── bt_always_succeed.gd
│   ├── bt_always_fail.gd
│   └── bt_always_run.gd
└── leaves/
    ├── conditions/
    │   ├── has_opponent.gd      ← reads BB_OPPONENT
    │   ├── validate_opponent.gd ← clears invalid opponent refs, fails if none left
    │   ├── is_opponent_on_view.gd ← casts vision raycasts (only during BT tick)
    │   ├── is_opponent_in_range.gd ← nav_agent.distance_to_target() < attack_range
    │   ├── attack_cooldown_ready.gd ← checks/decrements BB_ATTACK_TIMER
    │   └── is_navigating.gd     ← not nav_agent.is_navigation_finished()
    └── actions/
        ├── find_destination.gd      ← random point within wander_radius → BB_DESTINATION
        ├── set_player_as_opponent.gd ← BB_OPPONENT = Globals.player
        ├── set_chase_destination.gd  ← BB_DESTINATION = opponent.global_position
        ├── request_path.gd           ← nav_agent.target_position = BB_DESTINATION
        ├── navigate_path.gd          ← running while not arrived; success on arrival
        ├── choose_attack.gd          ← calls agent.choose_attack(); sets BB_ATTACK_TIMER
        └── execute_attack.gd         ← calls agent.execute_attack(); returns RUNNING
```

---


---

#### Horde-Scale Pathfinding: The Bullet-Hell Problem

Getting 100+ zombies pathfinding simultaneously at smooth frame rates is a specific engineering challenge. The standard `NavigationAgent2D` approach (one path query per enemy) breaks down above ~30 enemies because **100 enemies all setting `target_position` in the same frame = 100 path queries in one tick** — a scheduling spike, not an algorithm problem.

The solution is a **three-tier movement system** used by games like State of Decay, Dying Light, and zombie horde RTS games. Each tier handles a different population of enemies with the appropriate cost level:

---

##### The Three-Tier Movement Architecture

```
┌─────────────────────────────────────────────────────────────────────┐
│ TIER 1: Flow Field  (enemies > ~6 tiles from player)                │
│  — 1 computation serves ALL enemies simultaneously                  │
│  — Recomputed on background thread when player moves > 1 tile       │
│  — Each enemy reads a 2D vector from the field: O(1) per enemy      │
│  — No per-enemy path queries. Zero nav server calls per enemy.      │
├─────────────────────────────────────────────────────────────────────┤
│ TIER 2: NavigationAgent2D  (enemies 2–6 tiles from player)          │
│  — Standard Godot nav with staggered update rate                    │
│  — Path recalculated every 0.5s, NOT every frame                    │
│  — RVO2 avoidance active — enemies don't pile up                    │
│  — Handles complex local geometry near player                       │
├─────────────────────────────────────────────────────────────────────┤
│ TIER 3: Direct Seek  (enemies ≤ ~2 tiles from player)               │
│  — Pure vector: direction = (player.pos - self.pos).normalized()    │
│  — No pathfinding at all — separation forces handle crowding        │
│  — Zero nav cost. Used for melee range enemies already in combat.   │
└─────────────────────────────────────────────────────────────────────┘
```

Enemies **transition between tiers automatically** based on distance to player. At any given frame:
- Most enemies (far away, chasing) → Flow Field (free)
- Mid-ring enemies (converging) → NavAgent (cheap, staggered)
- Enemies in melee range → Direct Seek (zero cost)

---

##### Tier 1: Flow Field

A **Flow Field** is a grid covering the active play area. Every cell stores a `Vector2` pointing toward the target (the player). It's computed once via reverse Dijkstra from the target outward — the same cost spreads to ALL agents simultaneously, regardless of where they are on the grid.

```
Cost to compute:  O(W×H)  where W,H = grid dimensions
Cost per enemy:   O(1)    — just a grid lookup at enemy position
```

**Implementation in Godot 4:**

```gdscript
# autoloads/flow_field.gd
class_name FlowField extends Node

const CELL_SIZE := 64.0          # pixels per cell — matches roughly 2 tile widths
const GRID_RADIUS := 30          # cells from center (30×64 = 1920px radius)
const UPDATE_THRESHOLD := 64.0   # rebuild when player moves more than 1 cell

var _grid: PackedVector2Array    # flat array: index = y * width + x
var _width: int
var _height: int
var _origin: Vector2             # world position of grid[0][0]
var _last_target: Vector2 = Vector2.INF

var _thread := Thread.new()
var _pending_grid: PackedVector2Array
var _rebuild_requested := false

func _ready() -> void:
    _width = GRID_RADIUS * 2 + 1
    _height = GRID_RADIUS * 2 + 1
    _grid = PackedVector2Array()
    _grid.resize(_width * _height)

func request_rebuild(target_world_pos: Vector2) -> void:
    # Only rebuild when player crosses a cell boundary
    if target_world_pos.distance_to(_last_target) < UPDATE_THRESHOLD:
        return
    _last_target = target_world_pos
    if _thread.is_alive(): return   # previous rebuild still running
    _rebuild_requested = true
    _thread.start(_build_field.bind(target_world_pos))

func _build_field(target: Vector2) -> void:
    # Run on background thread — pure data, no scene tree access
    var new_grid := PackedVector2Array()
    new_grid.resize(_width * _height)
    _origin = target - Vector2(_width, _height) * CELL_SIZE * 0.5

    # Reverse Dijkstra from target cell outward
    var target_cell := _world_to_cell(target)
    var dist := PackedFloat32Array()
    dist.resize(_width * _height)
    dist.fill(INF)
    dist[target_cell.y * _width + target_cell.x] = 0.0

    var queue := [target_cell]  # BFS queue
    while not queue.is_empty():
        var cell: Vector2i = queue.pop_front()
        var cell_dist: float = dist[cell.y * _width + cell.x]
        for neighbor in _get_neighbors(cell):
            var idx := neighbor.y * _width + neighbor.x
            var new_dist := cell_dist + _traversal_cost(cell, neighbor)
            if new_dist < dist[idx]:
                dist[idx] = new_dist
                new_grid[idx] = (Vector2(cell) - Vector2(neighbor)).normalized()
                queue.push_back(neighbor)

    _pending_grid = new_grid
    call_deferred("_apply_grid")  # back on main thread

func _apply_grid() -> void:
    _thread.wait_to_finish()
    _grid = _pending_grid
    _rebuild_requested = false

func sample(world_pos: Vector2) -> Vector2:
    # Called by each enemy every physics frame — O(1)
    var cell := _world_to_cell(world_pos)
    cell = cell.clamp(Vector2i.ZERO, Vector2i(_width - 1, _height - 1))
    return _grid[cell.y * _width + cell.x]

func _traversal_cost(from: Vector2i, to: Vector2i) -> float:
    # Check nav mesh — blocked cells get very high cost
    var world_to := _cell_to_world(to)
    if not _is_navigable(world_to):
        return 9999.0
    return from.distance_to(Vector2(to))  # diagonal = sqrt(2), orthogonal = 1

func _is_navigable(world_pos: Vector2) -> bool:
    # Query NavigationServer2D — is this point on the nav mesh?
    var closest := NavigationServer2D.map_get_closest_point(
        get_world_2d().navigation_map, world_pos)
    return world_pos.distance_to(closest) < CELL_SIZE * 0.5
```

**Key design decisions:**
- `PackedVector2Array` (not `Array`) — contiguous memory, cache-friendly, no GC pressure
- Background thread via `Thread` — the rebuild never touches the scene tree (safe)
- `call_deferred("_apply_grid")` — grid swap happens on main thread after thread finishes
- Rebuild threshold: only recalculates when player moves ≥ 1 cell — avoids rebuild every frame

**How enemies use it:**

```gdscript
# In enemy._physics_process() when in Tier 1:
var flow_dir := FlowField.sample(global_position)
velocity = flow_dir * stats.move_speed.value + _separation_force()
move_and_slide()
```

---

##### Tier 2: Staggered NavigationAgent2D

For mid-range enemies where obstacle awareness matters more than pure throughput, `NavigationAgent2D` is used but with **staggered updates** — never all in the same frame:

```gdscript
# HordePathingManager autoload — staggers all nav requests
class_name HordePathingManager extends Node

var _agents: Array[NavigationAgent2D] = []
var _update_index: int = 0
const UPDATES_PER_FRAME := 3   # process 3 agents per physics frame

func register(agent: NavigationAgent2D) -> void:
    _agents.append(agent)

func deregister(agent: NavigationAgent2D) -> void:
    _agents.erase(agent)

func _physics_process(_delta: float) -> void:
    if _agents.is_empty(): return
    var target_pos := Globals.player.global_position
    for i in UPDATES_PER_FRAME:
        if _update_index >= _agents.size():
            _update_index = 0
        var agent := _agents[_update_index]
        if is_instance_valid(agent):
            # Only update if enemy has moved meaningfully or enough time passed
            agent.target_position = target_pos
        _update_index += 1
```

With 60 tier-2 enemies and 3 updates per frame: each enemy's path recalculates every 20 frames (~3 Hz). The path queries are spread evenly — never more than 3 in a single frame. This is the key fix for the scheduling spike problem.

---

##### Tier 3: Direct Seek + Separation Forces

Enemies within melee range skip pathfinding entirely. They seek the player directly, but use a lightweight **separation force** to prevent pile-up:

```gdscript
# In enemy._physics_process() when in Tier 3:
var seek_dir := global_position.direction_to(Globals.player.global_position)
var sep := _separation_force()
velocity = (seek_dir + sep).normalized() * stats.move_speed.value
move_and_slide()

func _separation_force() -> Vector2:
    var force := Vector2.ZERO
    # Query nearby enemies using NavigationServer2D's avoidance OR a simple spatial check
    for neighbor in _nearby_enemies:
        if not is_instance_valid(neighbor): continue
        var away := global_position - neighbor.global_position
        var dist := away.length()
        if dist < MIN_SEPARATION and dist > 0.01:
            force += away.normalized() * (MIN_SEPARATION - dist) / MIN_SEPARATION
    return force * SEPARATION_STRENGTH

const MIN_SEPARATION := 40.0
const SEPARATION_STRENGTH := 0.8
```

This is effectively boids separation — cheap, local, and makes crowds look organic.

---

##### Tier Transition Logic

Each enemy checks its distance to the player once per second (not per frame) and transitions tiers:

```gdscript
# In enemy.gd
enum MoveTier { FLOW_FIELD, NAV_AGENT, DIRECT_SEEK }
var _move_tier := MoveTier.FLOW_FIELD

const TIER_DIRECT_DIST   := 120.0   # < 120px → direct seek
const TIER_NAV_DIST      := 400.0   # 120–400px → nav agent
const TIER_FLOW_DIST     := INF     # > 400px → flow field
const TIER_HYSTERESIS    := 20.0    # prevents thrash at boundaries

var _tier_check_timer := 0.0
const TIER_CHECK_INTERVAL := 1.0

func _update_move_tier(delta: float) -> void:
    _tier_check_timer += delta
    if _tier_check_timer < TIER_CHECK_INTERVAL: return
    _tier_check_timer = 0.0

    var dist := global_position.distance_to(Globals.player.global_position)
    var new_tier: MoveTier
    if dist < TIER_DIRECT_DIST - TIER_HYSTERESIS:
        new_tier = MoveTier.DIRECT_SEEK
    elif dist < TIER_NAV_DIST - TIER_HYSTERESIS:
        new_tier = MoveTier.NAV_AGENT
    else:
        new_tier = MoveTier.FLOW_FIELD

    if new_tier != _move_tier:
        _on_tier_changed(_move_tier, new_tier)
        _move_tier = new_tier

func _on_tier_changed(from: MoveTier, to: MoveTier) -> void:
    match to:
        MoveTier.NAV_AGENT:
            HordePathingManager.register(_nav_agent)
        MoveTier.FLOW_FIELD, MoveTier.DIRECT_SEEK:
            HordePathingManager.deregister(_nav_agent)
```

---

##### Expected Performance Budget (Mobile Target)

With this system, 100 enemies on screen simultaneously:

| Tier | Count | Cost per frame |
|------|-------|---------------|
| Direct Seek (melee) | ~10 | Negligible — vector math only |
| NavAgent (mid-ring) | ~20 | ~3 queries/frame total (staggered) |
| Flow Field (outer) | ~70 | 70 × O(1) grid lookups |
| Flow Field rebuild | 1/sec approx | Background thread, ~2-5ms |
| **Total nav cost** | — | **~1-2ms/frame** |

Compare to naive NavigationAgent2D for all 100: ~15-30ms/frame when target updates fire (tested by Godot community, cited above).

---

##### Updated Checklist Additions (Horde Pathfinding)

- ⬜ `autoloads/flow_field.gd` — `FlowField` Node: `PackedVector2Array` grid; reverse-Dijkstra from player position on background `Thread`; `sample(world_pos) -> Vector2` O(1) lookup; rebuild only when player crosses cell boundary (`UPDATE_THRESHOLD = 64.0`); `_is_navigable()` checks NavigationServer2D map; `call_deferred("_apply_grid")` for thread-safe swap
- ⬜ `autoloads/horde_pathing_manager.gd` — `HordePathingManager` Node: `register/deregister(nav_agent)`; `_physics_process` updates `UPDATES_PER_FRAME = 3` agents per frame (round-robin); only tier-2 agents registered
- ⬜ Enemy `MoveTier` enum (`FLOW_FIELD`, `NAV_AGENT`, `DIRECT_SEEK`); `_update_move_tier(delta)` checked every 1s with hysteresis; `_on_tier_changed()` registers/deregisters from `HordePathingManager`
- ⬜ Enemy `_physics_process` branches on `_move_tier`: flow field → `FlowField.sample()` + separation force; nav agent → `_nav_agent.get_next_path_position()`; direct seek → `direction_to(player)` + separation force
- ⬜ `_separation_force() -> Vector2` — iterate `_nearby_enemies` array (populated by BodySensor Area2D); apply inverse-distance repulsion; `MIN_SEPARATION = 40.0`
- ⬜ FlowField registered as autoload; `FlowField.request_rebuild(player.global_position)` called from GameState or DayNightCycle once per second (not per frame)
- ⬜ Verify: spawn 100 enemies, confirm 60 FPS maintained on mobile target; no frame spikes during flow field rebuild; enemies navigate around walls using flow field; tier transitions are smooth (no teleporting/jitter at boundaries)

---#### Checklist

**Core BT framework**
- ⬜ `ai/bt_task.gd` — `class_name BTTask extends RefCounted`; `enum Status {SUCCESS, FAILURE, RUNNING}`; `func tick(bb: Dictionary, agent: Node, delta: float) -> Status` (override); `func setup(bb: Dictionary, agent: Node)` (optional init, called once)
- ⬜ `ai/bt_tree_resource.gd` — `class_name BTTreeResource extends Resource`; `@export var root: BTTask`; resource is shared read-only across all enemies of same type
- ⬜ `ai/bt_runner.gd` — `class_name BTRunner extends Node`; `@export var tree: BTTreeResource`; `@export var tick_interval: float = 0.1`; owns `_blackboard: Dictionary`; `_physics_process(delta)` accumulates timer, ticks tree; `set_tick_rate_by_distance(dist)`; `init(agent)` calls `tree.root.setup(bb, agent)`
- ⬜ `ai/blackboard_keys.gd` — all `const` StringName keys (see above)

**Composites (all extend BTTask, hold `@export var children: Array[BTTask]`)**
- ⬜ `ai/composites/bt_sequence.gd` — `_current_child` index; `child SUCCESS` → advance; `child FAILURE` → reset + return FAILURE; all succeed → return SUCCESS
- ⬜ `ai/composites/bt_selector.gd` — `child FAILURE` → advance; `child SUCCESS` → reset + return SUCCESS; all fail → return FAILURE
- ⬜ `ai/composites/bt_parallel.gd` — ticks all children; configurable success/fail policy
- ⬜ `ai/composites/bt_random_sequence.gd` + `bt_random_selector.gd` — shuffle `children` order in `setup()`; reshuffle on reset

**Decorators (all extend BTTask, hold `@export var child: BTTask`)**
- ⬜ `ai/decorators/bt_invert.gd`, `bt_always_succeed.gd`, `bt_always_fail.gd`, `bt_always_run.gd`
- ⬜ `ai/decorators/bt_repeat.gd` — `@export var times: int = 0` (0=infinite); fix: pass `delta` to `child.tick(bb, agent, delta)`
- ⬜ `ai/decorators/bt_wait.gd` — fix: `_elapsed` starts at 0, counts UP; returns RUNNING until `_elapsed >= wait_time`; then ticks child
- ⬜ `ai/decorators/bt_until_fail.gd`, `bt_until_success.gd`, `bt_limit.gd`

**Condition leaves**
- ⬜ `ai/leaves/conditions/has_opponent.gd` — reads `bb[BB_OPPONENT]`; SUCCESS if non-null + valid
- ⬜ `ai/leaves/conditions/validate_opponent.gd` — `is_instance_valid()` check + distance > loose_range check; clears opponent + returns FAILURE if stale; no other side effects
- ⬜ `ai/leaves/conditions/is_opponent_on_view.gd` — iterates vision raycasts; if player hit → writes `bb[BB_OPPONENT]` + SUCCESS; else FAILURE
- ⬜ `ai/leaves/conditions/is_opponent_in_range.gd` — `agent._nav_agent.distance_to_target() <= attack_range stat`
- ⬜ `ai/leaves/conditions/attack_cooldown_ready.gd` — decrements `bb[BB_ATTACK_TIMER]` by delta; SUCCESS when <= 0
- ⬜ `ai/leaves/conditions/is_navigating.gd` — `not agent._nav_agent.is_navigation_finished()`

**Action leaves**
- ⬜ `ai/leaves/actions/find_destination.gd` — respects `bb[BB_WANDER_TIMER]`; on timer expire: random point → `bb[BB_DESTINATION]` + reset timer; RUNNING while waiting
- ⬜ `ai/leaves/actions/set_player_as_opponent.gd` — `bb[BB_OPPONENT] = Globals.player`; SUCCESS
- ⬜ `ai/leaves/actions/set_chase_destination.gd` — `bb[BB_DESTINATION] = bb[BB_OPPONENT].global_position`; SUCCESS
- ⬜ `ai/leaves/actions/request_path.gd` — `agent._nav_agent.target_position = bb[BB_DESTINATION]`; SUCCESS
- ⬜ `ai/leaves/actions/navigate_path.gd` — RUNNING while `not nav_agent.is_navigation_finished()`; SUCCESS on arrival; FAILURE if no valid path
- ⬜ `ai/leaves/actions/choose_attack.gd` — `agent.choose_attack()` + sets `bb[BB_ATTACK_TIMER]` to attack cooldown; SUCCESS
- ⬜ `ai/leaves/actions/execute_attack.gd` — `agent.execute_attack()`; RUNNING while `bb[BB_IS_ATTACKING]`; SUCCESS when done

**BT tree definitions (BTTreeResource assets)**
- ⬜ `ai/trees/wander_tree.tres` — WanderTree as BTTreeResource (assembled in code or inspector)
- ⬜ `ai/trees/basic_ai_tree.tres` — BasicAI combat + wander fallback
- ⬜ `ai/trees/chase_ai_tree.tres` — SetPlayerAsOpponent + BasicAI subtree

**NavigationAgent2D (enemy owns it — no Pathfinder singleton)**
- ⬜ `NavigationAgent2D` added to `enemy.tscn` as child; configure: `path_desired_distance=10`, `target_desired_distance=20`, `path_max_distance=50`, `avoidance_enabled=true`, `max_neighbors=10`
- ⬜ Enemy `_physics_process`: read `_nav_agent.get_next_path_position()` each frame; compute direction; apply velocity + `move_and_slide()`; rotate toward direction
- ⬜ Enemy `_ready`: connect `_nav_agent.navigation_finished` → `_on_navigation_finished()`
- ⬜ `Pathfinder` autoload removed from project settings; all references replaced

**Tick rate LOD**
- ⬜ `BTRunner.set_tick_rate_by_distance(dist)` — 3 distance tiers (see above)
- ⬜ Enemy updates tick rate when player distance crosses thresholds (checked 1x/sec, not per frame)
- ⬜ `VisibleOnScreenNotifier2D.screen_exited` → `_runner.tick_interval = 1.0`
- ⬜ `VisibleOnScreenNotifier2D.screen_entered` → restore distance-based rate

**Verify**
- ⬜ Enemy wanders when no player present; path follows nav mesh correctly (no wall clipping)
- ⬜ Enemy spots player via vision rays (at BT tick interval, not per frame) → switches to chase
- ⬜ Enemy attacks when in range, respects cooldown, returns to chase when player moves away
- ⬜ Two enemies don't overlap while chasing (RVO2 avoidance working)
- ⬜ Distant enemy ticks at 3Hz — confirm via debug counter
- ⬜ Bug regression: `Wait` decorator actually waits the configured duration before running child
- ⬜ No Pathfinder autoload needed — remove from autoload list and verify no errors

---
### PHASE 8 — Item System

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

### PHASE 9 — Inventory System

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

### PHASE 10 — Weapons & Combat

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

### PHASE 11 — Placables & Building

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


**Campfire:** Shows an interact button when player is nearby. No crafting functionality yet — placeholder for cooking system..

**Chest:** A `StaticBody2D` placed by the map generator near houses. On player proximity, opens a loot panel with preset items. These items were configured in the map block scene editor.

#### Checklist
- ⬜ `scene/entities/player/placable/placable.gd` — Node2D preview: `build(static_data)`: set sprite, show node; overlap Area2D changes tint; `place()`: consume recipe, `Factory.placable.create()`, add to world, hide; `cancel()`: hide
- ⬜ `scene/entities/placables/placable_base.gd` — StaticBody2D: `init(static_data, pos, rot)`; sprite texture/scale from data; health stat; `hurt(dmg)`, `health_stat_callback()` → free on 0; proximity Area2D → show/hide info in weapon panel
- ⬜ `scene/entities/placables/table/table.gd` + `.tscn` — extends Placable: on player enter → show craft panel with both inventories; repair button → add 10 HP
- ⬜ `scene/entities/placables/campfire/campfire.gd` + `.tscn` — extends Placable: proximity shows interact button
- ⬜ `autoloads/factory/placable_factory.gd` — dict of type_name → scene; `create(static_data, pos, rot)` instantiates, calls `init()`, returns node
- ⬜ `scene/entities/objects/chest/chest.gd` + `.tscn` — StaticBody2D: on player enter → show loot panel with preset `LootSlot` items; on exit → hide panel
- ⬜ Verify: select crafting table from placable inventory, see preview ghost, confirm placement, table appears in world; approach table, see craft panel open

---

### PHASE 12 — Day/Night Cycle & World Events

#### Plan
Time drives nearly everything in the game — enemy night waves, house respawns, hunger drain, and the visual atmosphere. The `DayNightCycle` node is a `CanvasModulate` that tints the entire game viewport.

**180-second cycle:** 0–90s = day (full brightness), 90–180s = night (dark tint). An `AnimationPlayer` drives the `CanvasModulate.color` from white (1,1,1,1) at noon to dark blue-grey (0.15, 0.15, 0.3, 1) at midnight. At `time = 90`, the `day_started` signal is emitted. At night transition, the animation calls `spawn_enemy_wave()` via a CallMethod track.

**Shadow system:** Objects in the `"shadow"` group have a duplicate shadow sprite. Each `_process` frame, `DayNightCycle.day()` calculates the sun direction based on `time` (0–180 mapped to a sun arc angle) and sets each shadow sprite's `position` offset accordingly. This gives the illusion of a moving sun casting dynamic shadows.

**Night wave:** `spawn_enemy_wave()` spawns 100 enemies at random positions around the player (outside a minimum distance, within a maximum distance). This is a timed event tied to the animation track, not to every night — it fires once per night cycle.

**Minimap:** A `ColorRect` with a `SubViewport` or just a scaled-down camera render. The player dot is a small `Sprite2D` that tracks `Globals.player.global_position` relative to the minimap bounds each frame and rotates with the player. Block images (pre-rendered PNGs per chunk) re-render when the `rerender` signal fires (on chunk load).

**HotBar:** A horizontal row of inventory slots at the bottom of the screen.. The HotBar's items can be used directly by tapping them in the HUD.

#### Checklist
- ⬜ `scene/hud/day_night_cycle/day_night_cycle.gd` + `.tscn` — extends CanvasModulate: `time`, `speed` (default 1.0), `last_day`; `_process(delta)` advances time and wraps; AnimationPlayer drives color; `day()` calculates shadow offsets for all "shadow" group nodes; `spawn_enemy_wave()` spawns 100 enemies around player; emits `day_started` signal
- ⬜ `scene/hud/minimap/minimap.gd` + `.tscn` — ColorRect background + player Sprite2D dot; `_process` updates dot position and rotation; `rerender(block)` updates block image overlay
- ⬜ `scene/hud/hotbar/hotbar.gd` + `.tscn` — HBoxContainer of Slots; items tappable from HUD
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

This is the single phase where **all serialization, save, and load implementation lives**. Every other phase defers its save/load contracts here. The goal: implement and verify the complete round-trip for every entity in the game in one focused phase, after all entities exist.

---

#### Architecture Overview

The save system uses a **single JSON file** at `user://savegame.json`. It runs on a background thread so the game never freezes during a save. A separate `user://world_layout.json` (written by `WorldGenerator` at new-game time) stores the procedural world seed and chunk layout — it is read-only at runtime and never modified by the save system.

```
user://
├── savegame.json       ← all mutable game state (written every 10s + on exit)
└── world_layout.json   ← procedural world seed + chunk map (written once at new game)
```

---

#### Save Schema: Six Categories

```json
{
  "version": 2,
  "player": { ... },
  "others": [ ... ],
  "enemies": [ ... ],
  "update_only": [ ... ],
  "regions": { "0,0": [...], "-2,1": [...] },
  "discovered_chunks": [ "0,0", "-2,1" ],
  "killed_enemies": { "0,0": ["uid1","uid2"], "-1,0": ["uid3"] }
}
```

| Key | What it stores | Who populates it | How loaded |
|-----|---------------|-----------------|------------|
| `version` | Schema version integer for migration | `Serialize` | Read at load; triggers migration if outdated |
| `player` | Position, rotation, stats, inventory, equipped weapon/hand item, active status effects | `Player.serialize()` | `Serialize.load_game()` → recreate + deserialize |
| `others` | HotBar slots, DayNightCycle time+day, Campfires | Each node's `serialize()` appends here | `Serialize.load_game()` → recreate + deserialize |
| `enemies` | All **persistent** enemies (aggroed + on-screen) — position, stats, type, aggro state | `Enemy.serialize()` via `"persistent_enemies"` group | `Serialize.load_enemies()` → recreate + deserialize |
| `update_only` | Houses + Zones — only their `day` counter | `House.serialize()`, `Zone.serialize()` | `Serialize.update_existing()` — finds node in tree, updates field only |
| `regions` | Placed objects (tables, campfires) per chunk coord key `"x,y"` | `Placable.serialize()` via chunk | `ChunkStreamer` calls `Serialize.load_region("x,y")` on chunk activate |
| `discovered_chunks` | Array of `"x,y"` strings the player has entered | `ChunkStreamer` updates on chunk activate | Read into `Globals.discovered_chunks` on load |
| `killed_enemies` | Per-chunk dict of enemy unique IDs that have been killed | `Enemy.die()` appends `unique_id` | `ChunkStreamer` checks before spawning from house/zone |

---

#### Serialization Groups

Nodes self-register by adding themselves to Godot groups:

| Group | Who joins | When |
|-------|-----------|------|
| `"persistent_enemies"` | Enemy | When `_is_persistent` = true (aggroed or on-screen) |
| `"save_others"` | HotBar, DayNightCycle, Campfire | Always while in scene tree |
| `"save_update_only"` | House, Zone | Always while in scene tree |

`Serialize.save_game()` collects each group and calls `node.serialize(data)` on each member. The node is responsible for appending to the correct `data` key — it knows its own category.

---

#### `autoloads/serialize.gd` — Full API

```gdscript
# Save
func save_game() -> void          # starts background thread
func _save_thread(data: Dictionary) -> void  # runs on thread: collect + write JSON

# Load
func has_save_data() -> bool
func load_game() -> void          # player + others + enemies
func load_region(chunk_coord: Vector2i) -> void  # placed objects for one chunk
func update_existing_nodes() -> void  # houses/zones day counter (update_only)

# Helpers
func create_and_deserialize(saved: Dictionary) -> Node  # load(filename).instantiate() + deserialize()
func get_killed_enemies(chunk_coord: Vector2i) -> Array[String]
func mark_enemy_killed(chunk_coord: Vector2i, uid: String) -> void
func mark_chunk_discovered(chunk_coord: Vector2i) -> void
func is_chunk_discovered(chunk_coord: Vector2i) -> bool
```

**Threading pattern (Godot 4):**

```gdscript
var _thread := Thread.new()
var _save_timer := Timer.new()   # 0.4s one-shot to clean thread after write

func save_game() -> void:
    if _thread.is_alive(): return  # don't double-save
    EventBus.notification_requested.emit("Saving...", Color.WHITE)
    _thread.start(_save_thread.bind(_collect_data()))

func _save_thread(data: Dictionary) -> void:
    var file := FileAccess.open("user://savegame.json", FileAccess.WRITE)
    file.store_string(JSON.stringify(data, "\t"))
    file.close()
    _save_timer.start()   # triggers _on_save_done() on main thread

func _on_save_done() -> void:
    _thread.wait_to_finish()
    EventBus.game_saved.emit()
```

**Load sequence:**

```
1. SceneStateManager pushes GameState (is_new_game = false)
2. GameState._enter_tree():
   a. ChunkStreamer.activate()        → starts chunk loading
   b. Serialize.load_game()          → recreates Player, HotBar, DayNightCycle, Campfires, Enemies
   c. Globals.discovered_chunks      → populated from save
3. As chunks activate (ChunkStreamer):
   a. Serialize.load_region(coord)   → restores placed tables/campfires for that chunk
   b. Serialize.update_existing()    → updates House/Zone day counters
   c. Checks killed_enemies before spawning from house/zone spawners
```

---

#### Per-Entity Serialize / Deserialize Contracts

##### Player

```gdscript
# Saved to: data["player"]
func serialize(data: Dictionary) -> void:
    data["player"] = {
        "scene": scene_file_path,
        "position": { "x": global_position.x, "y": global_position.y },
        "rotation": global_rotation,
        "stats": stats.serialize(),          # deficit per stat + permanent mods
        "status_effects": stats.effects.serialize(),
        "inventory": inventory.serialize(),
        "hotbar": hotbar.serialize(),        # equipment slots
        "weapon": _weapon_slot_data(),
        "hand_item": _hand_slot_data()
    }

func deserialize(saved: Dictionary) -> void:
    global_position = Vector2(saved.position.x, saved.position.y)
    global_rotation = saved.rotation
    stats.deserialize(saved.stats)
    stats.effects.deserialize(saved.status_effects)
    inventory.deserialize(saved.inventory)
    # weapon + hand item restored via inventory panel equipment slots
```

##### Stat / StatsComponent

```gdscript
# Stat serializes deficit (not absolute value) + permanent modifiers
func serialize() -> Dictionary:
    return {
        "deficit": max_value - current_value,
        "permanent_mods": _modifiers.filter(
            func(m): return m.is_permanent
        ).map(func(m): return { "type": m.type, "value": m.value })
    }

func deserialize(saved: Dictionary) -> void:
    # Re-apply permanent mods first (they raise max_value)
    for mod_data in saved.permanent_mods:
        add_modifier(StatModifier.new(mod_data.value, mod_data.type, self))
    current_value = max_value - saved.deficit

# StatusEffect serializes duration timer + tick effect states
# StatusEffectContainer.serialize() → Array of StatusEffect.serialize() dicts
```

##### Enemy

```gdscript
# Saved to: data["enemies"] (flat array)
# Only nodes in "persistent_enemies" group are saved
func serialize(data: Dictionary) -> void:
    var d := {
        "scene": scene_file_path,
        "enemy_type_id": _type_id,
        "position": { "x": global_position.x, "y": global_position.y },
        "rotation": global_rotation,
        "stats": stats.serialize(),
        "status_effects": stats.effects.serialize(),
        "had_opponent": _opponent != null,
        "last_known_pos": _blackboard.get(BlackboardKeys.LAST_KNOWN_POS, null)
    }
    data["enemies"].append(d)

func deserialize(saved: Dictionary) -> void:
    global_position = Vector2(saved.position.x, saved.position.y)
    global_rotation = saved.rotation
    stats.deserialize(saved.stats)
    stats.effects.deserialize(saved.status_effects)
    if saved.had_opponent:
        _set_opponent(Globals.player)   # resume chase immediately
    elif saved.last_known_pos != null:
        _blackboard[BlackboardKeys.LAST_KNOWN_POS] = saved.last_known_pos
```

**Aggro-first persistence rule** (enemy registers in `"persistent_enemies"` group):
```
_is_persistent = true  when: opponent != null  OR  visible == true
_is_persistent = false when: off-screen AND no opponent
```

**Killed enemy tracking** — prevents respawn of cleared areas:
```gdscript
# In Enemy.die():
Serialize.mark_enemy_killed(ChunkStreamer.world_to_chunk(global_position), _unique_id)

# In ChunkStreamer before house/zone spawning:
var killed := Serialize.get_killed_enemies(chunk_coord)
if _unique_id in killed: return  # don't respawn
```

##### House

```gdscript
# Saved to: data["update_only"]
# Only the day counter — scene is not recreated, existing node is updated
func serialize(data: Dictionary) -> void:
    data["update_only"].append({
        "path": get_path(),   # NodePath to find existing node on load
        "day": _current_day
    })

# On load, Serialize.update_existing() calls:
func deserialize(saved: Dictionary) -> void:
    _current_day = saved.day  # no respawn for already-cleared days
```

##### Placable (Table, Campfire)

```gdscript
# Table saved to: data["regions"]["x,y"] (per-chunk array)
func serialize(data: Dictionary) -> void:
    var chunk_key := ChunkStreamer.world_to_chunk_key(global_position)
    data["regions"][chunk_key] = data["regions"].get(chunk_key, [])
    data["regions"][chunk_key].append({
        "scene": scene_file_path,
        "position": { "x": global_position.x, "y": global_position.y },
        "rotation": global_rotation,
        "health_deficit": stats.health.max_value - stats.health.current_value
    })

# Campfire saved to: data["others"] (same as HotBar / DayNightCycle)
# Because campfires persist globally across all chunks
```

##### HotBar

```gdscript
# Saved to: data["others"]
func serialize(data: Dictionary) -> void:
    data["others"].append({
        "scene": scene_file_path,
        "slots": _slots.map(func(s): return s.serialize_item())
    })

func deserialize(saved: Dictionary) -> void:
    for i in saved.slots.size():
        if saved.slots[i] != null:
            _slots[i].set_item(Factory.item.deserialize(saved.slots[i]))
```

##### DayNightCycle

```gdscript
# Saved to: data["others"]
func serialize(data: Dictionary) -> void:
    data["others"].append({
        "scene": scene_file_path,
        "time": _time,
        "day_number": _day_number
    })

func deserialize(saved: Dictionary) -> void:
    _time = saved.time
    _day_number = saved.day_number
    EventBus.day_started.emit(_day_number)
```

---

#### Save Versioning & Migration

```gdscript
const CURRENT_VERSION := 2

func _load_and_migrate(raw: Dictionary) -> Dictionary:
    var v: int = raw.get("version", 1)
    if v == 1:
        raw = _migrate_v1_to_v2(raw)
    return raw

func _migrate_v1_to_v2(old: Dictionary) -> Dictionary:
    # v1 used "map" key for enemies; v2 uses "enemies"
    if old.has("map"):
        old["enemies"] = old["map"]
        old.erase("map")
    # v1 used "serializable" group (on-screen only); v2 uses persistent_enemies
    # No data change needed — just the schema key rename
    old["version"] = 2
    return old
```

This lets saves from the old system (Godot 3 original) load correctly in the new one, and future schema changes stay backward-compatible.

---

#### Checklist

**Core system**
- ⬜ `autoloads/serialize.gd` — `save_game()` background thread; `_save_thread(data)` writes JSON; `_on_save_done()` cleans thread + emits `EventBus.game_saved`; `has_save_data()`, `load_game()`, `load_region(coord)`, `update_existing_nodes()`, `create_and_deserialize(saved)`, `get_killed_enemies(coord)`, `mark_enemy_killed(coord, uid)`, `mark_chunk_discovered(coord)`, `is_chunk_discovered(coord)`
- ⬜ Save schema version field + `_load_and_migrate()` function; v1→v2 migration (rename `"map"` key to `"enemies"`)
- ⬜ `EventBus.game_saved` signal emitted on successful write
- ⬜ `EventBus.notification_requested.emit("Saving...", Color.WHITE)` on save start

**Stat / StatsComponent contracts**
- ⬜ `Stat.serialize()` → `{deficit, permanent_mods[]}` — deficit-based, not absolute value
- ⬜ `Stat.deserialize(saved)` — re-applies permanent mods first, then sets `current_value = max_value - deficit`
- ⬜ `StatusEffect.serialize()` → `{id, duration_remaining, timer, tick_effect_states[]}`
- ⬜ `StatusEffectContainer.serialize()` → array of `StatusEffect.serialize()` dicts
- ⬜ `StatusEffectContainer.deserialize(saved)` → recreates and re-applies all active effects

**Player contract**
- ⬜ `Player.serialize(data)` → `data["player"]`: position, rotation, `stats.serialize()`, `status_effects.serialize()`, inventory, hotbar slot refs, equipped weapon + hand item
- ⬜ `Player.deserialize(saved)` → restore position + rotation; `stats.deserialize()`; `effects.deserialize()`; restore inventory; restore equipment via inventory panel slots

**Enemy contracts**
- ⬜ `Enemy._is_persistent` bool setter: `add_to_group("persistent_enemies")` when true, `remove_from_group` when false
- ⬜ `Enemy._unique_id: String` — generated at spawn via `str(get_instance_id())` or UUID; stable across serialization
- ⬜ `Enemy.serialize(data)` → appends to `data["enemies"]`: position, rotation, type_id, `stats.serialize()`, `effects.serialize()`, `had_opponent`, `last_known_pos`
- ⬜ `Enemy.deserialize(saved)` → restore position + stats; if `had_opponent` → `_set_opponent(Globals.player)`; if `last_known_pos` → write to blackboard
- ⬜ `Enemy.die()` → calls `Serialize.mark_enemy_killed(chunk_coord, _unique_id)`
- ⬜ `ChunkStreamer` checks `Serialize.get_killed_enemies(coord)` before house/zone spawning — skip if uid in killed set

**House + Zone contracts**
- ⬜ `House.serialize(data)` → appends to `data["update_only"]`: `{path: get_path(), day: _current_day}`
- ⬜ `House.deserialize(saved)` → `_current_day = saved.day` (update field only, no scene recreation)
- ⬜ `Zone.serialize(data)` → same pattern as House
- ⬜ `Serialize.update_existing_nodes()` → iterates `"save_update_only"` group; finds node by saved path; calls `node.deserialize(saved)`

**Placable contracts**
- ⬜ `PlacableBase.serialize(data)` → appends to `data["regions"][chunk_key]`: scene path, position, rotation, health deficit
- ⬜ `PlacableBase.deserialize(saved)` → restore position + rotation; `stats.health` deficit restore
- ⬜ `Table` extends PlacableBase serialize — also saves inventory state (craftable/placable slots)
- ⬜ `Campfire.serialize(data)` → appends to `data["others"]` (global, not region-specific)

**HotBar + DayNightCycle contracts**
- ⬜ `HotBar.serialize(data)` → appends to `data["others"]`: slot item dicts via `Factory.item.serialize(item)`
- ⬜ `HotBar.deserialize(saved)` → `Factory.item.deserialize(slot_data)` per slot
- ⬜ `DayNightCycle.serialize(data)` → appends to `data["others"]`: `{time, day_number}`
- ⬜ `DayNightCycle.deserialize(saved)` → restore time + day; emit `EventBus.day_started`

**Discovered chunks**
- ⬜ `ChunkStreamer` calls `Serialize.mark_chunk_discovered(coord)` when chunk enters buffer ring
- ⬜ `Globals.discovered_chunks: Array[String]` populated from `savegame["discovered_chunks"]` on load
- ⬜ Minimap reads `Globals.discovered_chunks` to show/hide fog

**Verification**
- ⬜ New game: save fires after world gen; reload shows same POI positions (world_layout.json unchanged)
- ⬜ Player: move to new position, equip weapon, heal/damage stats → save → reload → all restored exactly
- ⬜ Enemy aggroed + off-screen: save → reload → enemy at saved position, immediately resumes chase
- ⬜ Enemy aggroed + on-screen: save → reload → enemy at saved position, immediately resumes chase
- ⬜ Enemy idle + off-screen: save → reload → enemy NOT in save, re-spawned fresh by house system
- ⬜ Enemy killed: save → reload → enemy does NOT respawn (uid in killed_enemies)
- ⬜ Place crafting table → save → reload → table at correct position, health intact
- ⬜ Campfire placed → save → reload → campfire present
- ⬜ HotBar items → save → reload → same items in same slots
- ⬜ Day counter (house cleared day 3): save → reload → house does not re-spawn day-3 enemies
- ⬜ Chunk discovery → save → reload → discovered chunks show on minimap without re-entering
- ⬜ v1 save file (old "map" key): load → migrates to v2 → no errors
- ⬜ Full gameplay round-trip: survive 3 nights, craft items, place table, kill enemies, save, quit, reload — everything intact

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

























