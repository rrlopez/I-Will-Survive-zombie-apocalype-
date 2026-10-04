class_name ForceEffect extends RefCounted
## ForceEffect — frame-by-frame knockback applied to entity.applied_force.
## tick() returns true when force magnitude drops below threshold.

@export var magnitude: float = 200.0
@export var friction: float  = 0.05

const EXHAUSTED_THRESHOLD := 1.0

var _force: Vector2         = Vector2.ZERO
var _initial_force: Vector2 = Vector2.ZERO

func init(direction: Vector2) -> void:
	_force         = direction.normalized() * magnitude
	_initial_force = _force

func tick(entity: Node, _delta: float) -> bool:
	if _force.length() < EXHAUSTED_THRESHOLD:
		if "applied_force" in entity:
			entity.applied_force = Vector2.ZERO
		return true
	if "applied_force" in entity:
		entity.applied_force += _force
	_force *= friction
	return false
