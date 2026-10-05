class_name UpperBodyAnimation extends Node
## UpperBodyAnimation — wraps the upper body AnimationTree StateMachine.
## Exposes play_state() for external code and re-emits animation track signals
## (attack_landed, attack_finished) as typed GDScript signals.
##
## Attach to: Player/Body/UpperBody as a child Node.
## Expects a sibling AnimationTree node named "AnimationTree".

signal attack_landed    ## emitted by AnimationPlayer "Call Method" track mid-swing
signal attack_finished  ## emitted when attack animation fully completes

@onready var _anim_tree: AnimationTree = get_node_or_null("../AnimationTree")

## The AnimationNodeStateMachine playback object — used to travel between states.
var _state_machine: AnimationNodeStateMachinePlayback = null

## The state name to return to after an attack finishes (set when weapon equipped).
var _idle_state: StringName = &"idle"

func _ready() -> void:
	if _anim_tree:
		_anim_tree.active = true
		_state_machine = _anim_tree.get("parameters/StateMachine/playback")

# ── Public API ────────────────────────────────────────────────────────────────

## Transition the upper body state machine to `state_name`.
## Valid states (defined in AnimationTree): idle, pistol_idle, pistol_fire,
## rifle_idle, rifle_fire, rifle_reload, melee_swing, hurt.
func play_state(state_name: StringName) -> void:
	if _state_machine:
		_state_machine.travel(state_name)

## Set the idle state to return to after attack_finished.
## Called by Player when equipping a weapon.
func set_idle_state(state_name: StringName) -> void:
	_idle_state = state_name

# ── Called by AnimationPlayer "Call Method" tracks ────────────────────────────
## These method names must match exactly what is set in the AnimationTree tracks.

func _anim_attack_landed() -> void:
	attack_landed.emit()

func _anim_attack_finished() -> void:
	attack_finished.emit()
	# Return to the weapon's idle state automatically
	play_state(_idle_state)
