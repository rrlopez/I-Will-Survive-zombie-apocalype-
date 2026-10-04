class_name StatModifierFactory extends RefCounted
## StatModifierFactory — creates StatModifier resources from JSON descriptor dicts.
## Phase 0 stub. Full implementation in Phase 1.
##
## New modifier type system (replaces the 7 legacy modifier subclasses):
##   FLAT | PERCENT_ADD | PERCENT_MULTIPLY | OVERRIDE
## Each modifier also carries a source reference for clean removal on unequip.

func create(_data: Dictionary, _source: Object = null) -> Resource:
	push_warning("StatModifierFactory.create: not yet implemented (Phase 1)")
	return null

func create_all(_array: Array, _source: Object = null) -> Array:
	push_warning("StatModifierFactory.create_all: not yet implemented (Phase 1)")
	return []
