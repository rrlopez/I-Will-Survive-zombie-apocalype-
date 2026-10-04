extends Node
## Globals — runtime node references shared across the whole game.
## All vars start null; each phase's init code sets them as systems come online.

# ── Core nodes ───────────────────────────────────────────────────────────────
var camera: Camera2D             = null
var player: CharacterBody2D      = null
var hud: CanvasLayer             = null
var state_manager: Node          = null

# ── World / map ───────────────────────────────────────────────────────────────
var map_manager: Node            = null
var day_night_cycle: Node        = null
var cur_region: String           = ""
var cur_house                    = null   # typed in Phase 5

# ── Chunk loading progress (watched by LoadingState) ─────────────────────────
var loading_blocks_count: int    = 0

# ── Active controller (player or vehicle) ────────────────────────────────────
var _current_controller: Node    = null

var current_controller: Node:
	get:
		return _current_controller
	set(controller):
		# Swap the controller node inside HUD.controller container
		if hud and hud.has_node("Controller"):
			var slot: Node = hud.get_node("Controller")
			for child in slot.get_children():
				slot.remove_child(child)
			if controller:
				slot.add_child(controller)
		_current_controller = controller
