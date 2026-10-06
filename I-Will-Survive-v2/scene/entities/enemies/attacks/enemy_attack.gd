class_name EnemyAttack extends Resource
## Base class for enemy attacks (melee, charge, ranged, etc.)
## Attacks are Resources, not Nodes, for zero scene-tree overhead.
## Each attack implements a 4-phase lifecycle: prepare → execute → is_active → resolve

## Setup phase: Size hitboxes, calculate geometry, etc.
func prepare(_enemy: Enemy) -> void:
	pass

## Execution phase: Trigger animations, play sounds, enable hitboxes.
func execute(_enemy: Enemy) -> void:
	pass

## Check if attack is still active (animation playing, charge moving, etc.)
## Returns true while attack is RUNNING, false when complete.
func is_active(_enemy: Enemy, _delta: float) -> bool:
	return false

## Resolution phase: Apply damage to all targets in hitbox, apply effects.
## Called after is_active returns false or when animation markers trigger it.
func resolve(_enemy: Enemy) -> void:
	pass
