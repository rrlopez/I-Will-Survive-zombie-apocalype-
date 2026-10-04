class_name StatusEffectContainer extends Node
## StatusEffectContainer — runtime manager node for StatusEffects.
## Child of StatsComponent. Ticks effects, removes expired ones,
## applies/removes modifiers cleanly via metadata routing.

signal effect_added(effect: StatusEffect)
signal effect_removed(effect: StatusEffect)

var _effects: Array[StatusEffect] = []
var _stats: StatsComponent = null   ## set by StatsComponent._ready()

# ── Public API ────────────────────────────────────────────────────────────────

func add(effect: StatusEffect) -> void:
	if effect.id != &"":
		remove_by_id(effect.id)   # dedup — last-applied wins
	_effects.append(effect)
	_apply_modifiers(effect)
	effect_added.emit(effect)

func remove(effect: StatusEffect) -> void:
	var idx := _effects.find(effect)
	if idx != -1:
		_remove_at(idx)

func remove_by_id(id: StringName) -> void:
	for i in range(_effects.size() - 1, -1, -1):
		if _effects[i].id == id:
			_remove_at(i)
			return

func remove_all_from_source(owner_object: Object) -> void:
	for i in range(_effects.size() - 1, -1, -1):
		var src := _effects[i].source_object()
		if src != null and src == owner_object:
			_remove_at(i)

func has(id: StringName) -> bool:
	for e in _effects:
		if e.id == id:
			return true
	return false

func clear() -> void:
	for i in range(_effects.size() - 1, -1, -1):
		_remove_at(i)

# ── Tick ──────────────────────────────────────────────────────────────────────

func tick(delta: float) -> void:
	for i in range(_effects.size() - 1, -1, -1):
		var effect := _effects[i]
		var entity := _get_entity()

		# Tick tick_effects, remove exhausted ones
		var exhausted: Array = []
		for te in effect.tick_effects:
			if entity and te.has_method("tick"):
				if te.tick(entity, delta):
					exhausted.append(te)
		for te in exhausted:
			effect.tick_effects.erase(te)

		# Advance duration
		if effect.tick(delta):
			_remove_at(i)

# ── Internal ──────────────────────────────────────────────────────────────────

func _remove_at(idx: int) -> void:
	var effect := _effects[idx]
	_remove_modifiers(effect)
	_effects.remove_at(idx)
	effect.expired.emit()
	effect_removed.emit(effect)

func _apply_modifiers(effect: StatusEffect) -> void:
	if _stats == null:
		return
	for mod in effect.modifiers:
		_route_modifier(mod, true)

func _remove_modifiers(effect: StatusEffect) -> void:
	if _stats == null:
		return
	for mod in effect.modifiers:
		_route_modifier(mod, false)

func _route_modifier(mod: StatModifier, adding: bool) -> void:
	if not mod.has_meta("target_stat"):
		push_warning("StatusEffectContainer: modifier missing 'target_stat' meta — skipping")
		return
	var stat_name: StringName = mod.get_meta("target_stat")
	var stat: Stat = _stats.get_stat(stat_name)
	if stat == null:
		return
	if adding:
		stat.add_modifier(mod)
	else:
		stat.remove_modifier(mod)

func _get_entity() -> Node:
	if _stats:
		return _stats.get_parent()
	return null
