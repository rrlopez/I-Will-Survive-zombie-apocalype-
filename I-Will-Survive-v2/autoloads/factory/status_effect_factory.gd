class_name StatusEffectFactory extends RefCounted
## StatusEffectFactory — builds and applies StatusEffect resources from JSON.

func create(data: Dictionary, stats_component: StatsComponent,
		source: Object = null, attacker_node: Node = null) -> StatusEffect:
	var chance := float(data.get("chance", 100.0))
	if chance < 100.0 and randf() * 100.0 > chance:
		return null

	var se := StatusEffect.new()
	se.id           = StringName(str(data.get("id",   "")))
	se.display_name = str(data.get("name",  ""))
	se.icon_path    = str(data.get("icon",  ""))
	se.duration     = float(data.get("duration", -1.0))
	if source:
		se.set_source(source)

	for effect_data in data.get("effects", []):
		_build_effect(effect_data, se, stats_component, source, attacker_node)

	stats_component.apply_effect(se)
	return se

func create_all(effects_array: Array, stats_component: StatsComponent,
		source: Object = null, attacker_node: Node = null) -> void:
	for effect_data in effects_array:
		if effect_data is Dictionary:
			create(effect_data, stats_component, source, attacker_node)

func remove_by_id(id: StringName, stats_component: StatsComponent) -> void:
	if stats_component.effects:
		stats_component.effects.remove_by_id(id)

func _build_effect(effect_data: Dictionary, se: StatusEffect,
		stats_component: StatsComponent, source: Object, attacker_node: Node) -> void:
	var script_key := str(effect_data.get("script", "")).to_lower()
	var stats: Dictionary = effect_data.get("stats", {})

	match script_key:
		"buff":
			var dur := float(stats.get("duration", -1.0))
			if dur >= 0.0 and (se.duration < 0.0 or dur < se.duration):
				se.duration = dur
			for mod_data in stats.get("modifiers", []):
				se.modifiers.append(Factory.stat_modifiers.create(mod_data, source))

		"regen":
			var r := RegenEffect.new()
			r.duration    = float(stats.get("duration", -1.0))
			r.rate        = float(stats.get("rate",      0.2))
			r.target_stat = &"health"
			r.amount      = _extract_amount(stats.get("modifiers", []))
			se.tick_effects.append(r)

		"drain":
			var d := DrainEffect.new()
			d.duration    = float(stats.get("duration", -1.0))
			d.rate        = float(stats.get("rate",      0.2))
			d.target_stat = &"health"
			d.amount      = _extract_amount(stats.get("modifiers", []))
			se.tick_effects.append(d)

		"applyforce", "apply_force":
			var fe := ForceEffect.new()
			fe.magnitude = float(stats.get("force",    200.0)) * 100.0
			fe.friction  = float(stats.get("friction",   0.05))
			if attacker_node and stats_component.get_parent():
				fe.init(attacker_node.global_position.direction_to(
						stats_component.get_parent().global_position))
			else:
				fe.init(Vector2.RIGHT)
			se.tick_effects.append(fe)

		_:
			push_warning("StatusEffectFactory: unknown script '%s'" % script_key)

func _extract_amount(modifiers: Array) -> float:
	for md in modifiers:
		if md is Dictionary:
			var val = md.get("val", {})
			if val is Dictionary:
				return absf(float(val.get("amount", 1.0)))
	return 1.0
