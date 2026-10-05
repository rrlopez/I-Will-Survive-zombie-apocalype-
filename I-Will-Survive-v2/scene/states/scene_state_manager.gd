class_name SceneStateManager extends Node
## SceneStateManager — stack-based game state machine.
##
## Design principles (masterplan Phase 3):
##   • States are lazy-instantiated — created on first visit, freed on pop (unless pinned)
##   • No string keys — use StateDefs.MENU, StateDefs.GAME, etc.
##   • Transitions are non-blocking via await
##   • States self-manage via _enter_tree() / _exit_tree() — manager never calls methods on states
##   • Overlays (Pause, Loading) stack ON TOP without replacing the current state
##   • Only PauseState / MapState pause the tree — no other state touches get_tree().paused

@onready var _transition: Transition = $"../Transition"

var _stack:    Array[Node] = []
var _overlays: Array[Node] = []
var _pinned:   Dictionary  = {}   ## PackedScene → Node (survives pops)

func _ready() -> void:
	Globals.state_manager = self
	var menu_packed: PackedScene = StateDefs.MENU
	var menu: Node = menu_packed.instantiate()
	pin_state(menu_packed, menu)
	_stack.push_back(menu)
	add_child(menu)

# ── Primary state stack ───────────────────────────────────────────────────────

func push_state(packed: PackedScene) -> void:
	await _transition.play_out()

	if _stack.size() > 0:
		remove_child(_stack[_stack.size() - 1])

	var state: Node = _get_or_create(packed)
	_stack.push_back(state)
	add_child(state)

	await _transition.play_in()


func pop_state() -> void:
	if _stack.size() < 2:
		return

	await _transition.play_out()

	var current: Node = _stack[_stack.size() - 1]
	_stack.resize(_stack.size() - 1)
	remove_child(current)
	if not _is_pinned(current):
		current.queue_free()

	add_child(_stack[_stack.size() - 1])

	await _transition.play_in()


func replace_state(packed: PackedScene) -> void:
	await _transition.play_out()

	for i in _stack.size():
		var s: Node = _stack[i]
		remove_child(s)
		if not _is_pinned(s):
			s.queue_free()
	_stack.clear()

	var new_state: Node = _get_or_create(packed)
	_stack.push_back(new_state)
	add_child(new_state)

	await _transition.play_in()

# ── Overlay stack ─────────────────────────────────────────────────────────────

func push_overlay(packed: PackedScene) -> void:
	var overlay: Node = packed.instantiate()
	_overlays.push_back(overlay)
	add_child(overlay)


func pop_overlay() -> void:
	if _overlays.is_empty():
		return
	var overlay: Node = _overlays[_overlays.size() - 1]
	_overlays.resize(_overlays.size() - 1)
	remove_child(overlay)
	overlay.queue_free()

# ── Pinning ───────────────────────────────────────────────────────────────────

func pin_state(packed: PackedScene, instance: Node) -> void:
	_pinned[packed] = instance

# ── Internal ──────────────────────────────────────────────────────────────────

func _get_or_create(packed: PackedScene) -> Node:
	if _pinned.has(packed):
		return _pinned[packed] as Node
	return packed.instantiate()

func _is_pinned(node: Node) -> bool:
	return _pinned.values().has(node)
