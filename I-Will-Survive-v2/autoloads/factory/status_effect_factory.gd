class_name StatusEffectFactory extends RefCounted
## StatusEffectFactory — creates StatusEffect resources from JSON descriptor dicts.
## Phase 0 stub. Full implementation in Phase 1.

## Create a StatusEffect and apply it to `opponent`.
## Rolls chance, checks for duplicate id, wraps stat effects, calls opponent.add_status_effect().
func create(_data: Dictionary, _opponent: Object, _source: Object = null) -> Resource:
	push_warning("StatusEffectFactory.create: not yet implemented (Phase 1)")
	return null
