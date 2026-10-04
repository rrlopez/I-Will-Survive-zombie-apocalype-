class_name StatFactory extends RefCounted
## StatFactory — maps stat script-name strings from JSON to Stat subclasses.
## Phase 0 stub: registry is empty until Phase 1 creates the stat classes.
## Phase 1 will populate _registry and implement create() / deserialize().

var _registry: Dictionary = {
	# Populated in Phase 1:
	# "health":           HealthStat,
	# "hunger":           HungerStat,
	# "level":            LevelStat,
	# "move_speed":       MoveSpeedStat,  (was "moveSpeed" in legacy)
	# "damage":           DamageStat,
	# "ammo":             AmmoStat,
	# "size":             SizeStat,
	# "vision":           DefaultStat,    (split into vision_width / vision_height)
	# "fire_accuracy":    DefaultStat,    (split into fire_spread_x / fire_spread_y)
	# "aggression_range": DefaultStat,
	# "default":          DefaultStat,
}

## Instantiate a stat for `id` using `data` dict from JSON, bound to `agent`.
func create(_id: String, _data: Dictionary, _agent: Object) -> Resource:
	push_warning("StatFactory.create: not yet implemented (Phase 1) — id: %s" % _id)
	return null

## Re-hydrate a stat from serialized data.
func deserialize(_data: Dictionary, _agent: Object) -> Resource:
	push_warning("StatFactory.deserialize: not yet implemented (Phase 1)")
	return null
