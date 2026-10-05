extends RefCounted
## ParticleFactory — spawns particle effect scenes (blood, dust, muzzle flash).
## Phase 0 stub. Full implementation in Phase 15.

func create(_effect_id: String, _position: Vector2 = Vector2.ZERO, _parent: Node = null) -> Node:
	push_warning("ParticleFactory.create: not yet implemented (Phase 15) — id: %s" % _effect_id)
	return null
