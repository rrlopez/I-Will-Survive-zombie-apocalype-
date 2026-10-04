extends Node
## Constants — global read-only values and preloaded resources.
## Fleshed out progressively as each phase adds new scenes/resources.

# ── Display ──────────────────────────────────────────────────────────────────
var SCREEN_WIDTH: int  = ProjectSettings.get_setting("display/window/size/viewport_width")
var SCREEN_HEIGHT: int = ProjectSettings.get_setting("display/window/size/viewport_height")

# ── World ─────────────────────────────────────────────────────────────────────
const BLOCK_SIZE: int = 3200          # One chunk in world units

# ── Gameplay multipliers ───────────────────────────────────────────────────────
const MOVE_SPEED_MULTIPLIER: float = 100.0
const EXP_MULTIPLIER: float        = 100.0
const STAT_RANDOM: float           = 0.7   # ±variance applied to stat base values

# ── Physics layer masks (bit positions, 1-indexed → shift by layer-1) ─────────
const LAYER_PLAYER:        int = 1 << 0   # layer 1
const LAYER_ENEMY:         int = 1 << 1   # layer 2
const LAYER_OBJECT:        int = 1 << 2   # layer 3
const LAYER_OBSTACLE:      int = 1 << 3   # layer 4
const LAYER_SENSOR:        int = 1 << 4   # layer 5
const LAYER_WALL:          int = 1 << 5   # layer 6
const LAYER_DROP_ITEM:     int = 1 << 6   # layer 7
const LAYER_HOUSE:         int = 1 << 7   # layer 8
const LAYER_REGION_SENSOR: int = 1 << 8   # layer 9

# ── RNG (shared, seeded at game start) ────────────────────────────────────────
var rng := RandomNumberGenerator.new()

# ── Preloaded scenes (populated as phases add the actual scenes) ─────────────
# Phase 2+
var player_controller_scene: PackedScene  # = preload("res://scene/entities/player/controller/controller.tscn")
var vehicle_controller_scene: PackedScene # = preload("res://scene/entities/vehicles/vehicle_controller.tscn")

# Phase 3+
var drop_item_scene: PackedScene  # = preload("res://scene/entities/objects/drop_item.tscn")
var notif_scene: PackedScene      # = preload("res://scene/entities/objects/notif.tscn")

# Phase 8+
var slot_scenes: Dictionary = {}  # filled in Phase 8: {"slot": ..., "equipment_slot": ..., "loot_slot": ...}

# ── Fonts (populated once font assets are imported) ───────────────────────────
# Phase 0 stub — assign after importing fonts in the editor:
#   var fonts: Dictionary = {
#       8:  preload("res://assets/fonts/font_8.tres"),
#       16: preload("res://assets/fonts/font_16.tres"),
#   }
var fonts: Dictionary = {}
