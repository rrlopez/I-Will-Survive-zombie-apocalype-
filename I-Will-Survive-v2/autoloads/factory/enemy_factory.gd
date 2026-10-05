extends RefCounted
## EnemyFactory — instantiates enemy scenes from data.
## Phase 0 stub. Full implementation in Phase 6.

## Create an enemy by type id (e.g. "normal", "charger").
## Returns null until Phase 6 wires up the actual scenes.
func create(id: String, _position: Vector2 = Vector2.ZERO) -> Node:
	push_warning("EnemyFactory.create: not yet implemented (Phase 6) — id: %s" % id)
	return null
