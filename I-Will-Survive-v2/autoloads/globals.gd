extends Node
## Globals — runtime node references shared across the whole game.
## Set by each system's _ready(). Never polled — use signals for reactivity.

# ── Core nodes ────────────────────────────────────────────────────────────────
var camera: Camera2D                 = null
var player: Player                   = null
var hud: HUD                         = null
var state_manager: SceneStateManager = null

# ── World / map ───────────────────────────────────────────────────────────────
var map_manager: Node   = null
var day_night_cycle: Node = null
var cur_region: String  = ""
var cur_house           = null   # typed in Phase 5

# ── Chunk loading progress ────────────────────────────────────────────────────
var loading_blocks_count: int = 0

# ── Active controller (player or vehicle) ─────────────────────────────────────
var _current_controller: Node = null

var current_controller: Node:
	get:
		return _current_controller
	set(controller):
		_current_controller = controller
		if hud:
			hud.set_controller(controller as Control)
