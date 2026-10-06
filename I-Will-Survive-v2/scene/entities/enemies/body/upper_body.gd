extends Node2D
## UpperBody — torso/arms visual component.
## AnimationTree with StateMachine for idle/hurt/attack states.

@onready var animation_tree: AnimationTree = $AnimationTree
@onready var sprite: Sprite2D = $Sprite2D

signal attack_landed
signal attack_finished

func _ready() -> void:
	if animation_tree:
		animation_tree.active = true

## Play a specific upper body animation state (idle/hurt/attack).
func play_upper(state_name: String) -> void:
	if not animation_tree:
		return
	
	# Set state machine travel (Phase 7 will have proper StateMachine setup)
	if animation_tree.tree_root:
		animation_tree.set("parameters/StateMachine/transition_request", state_name)

## Called by animation via CallMethod track when attack hits.
func _on_attack_landed() -> void:
	attack_landed.emit()

## Called by animation via CallMethod track when attack animation completes.
func _on_attack_finished() -> void:
	attack_finished.emit()
