extends Node2D
## Game — root scene. Holds SceneStateManager, HUD, and Transition.
## Nothing game-logic lives here — just wires up the three pillars
## so they are in the tree before any state or HUD node runs _ready().

func _ready() -> void:
	# Globals.state_manager and Globals.hud are set by their own _ready() calls.
	# Nothing to do here — the tree order guarantees correct init sequence:
	#   1. SceneStateManager._ready() → Globals.state_manager = self → pushes MenuState
	#   2. HUD._ready()               → Globals.hud = self
	#   3. Transition is available as sibling of SceneStateManager
	pass

func _input(event: InputEvent) -> void:
	# Global escape → pause (when in gameplay)
	if event.is_action_pressed("ui_cancel"):
		if Globals.state_manager and Globals.player:
			Globals.state_manager.push_overlay(StateDefs.PAUSE)
