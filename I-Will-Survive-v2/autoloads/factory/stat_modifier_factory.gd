extends RefCounted
## StatModifierFactory — creates StatModifier resources from JSON descriptor dicts.
## Supports both legacy JSON (script/val/type) and new format (modifier_type/value/target_stat).

const _LEGACY_MAP: Dictionary = {
	"add":      StatModifier.ModifierType.FLAT,
	"subtruct": StatModifier.ModifierType.FLAT,
	"subtract": StatModifier.ModifierType.FLAT,
	"multiply": StatModifier.ModifierType.PERCENT_MULTIPLY,
	"divide":   StatModifier.ModifierType.PERCENT_MULTIPLY,
	"set":      StatModifier.ModifierType.OVERRIDE,
}

const _TYPE_NAME_MAP: Dictionary = {
	"FLAT":             StatModifier.ModifierType.FLAT,
	"PERCENT_ADD":      StatModifier.ModifierType.PERCENT_ADD,
	"PERCENT_MULTIPLY": StatModifier.ModifierType.PERCENT_MULTIPLY,
	"OVERRIDE":         StatModifier.ModifierType.OVERRIDE,
}

func create(data: Dictionary, source: Object = null) -> StatModifier:
	var mod_type: StatModifier.ModifierType
	var mod_value: float
	var target_stat: StringName = &""

	if data.has("modifier_type"):
		mod_type    = _TYPE_NAME_MAP.get(str(data["modifier_type"]).to_upper(), StatModifier.ModifierType.FLAT)
		mod_value   = float(data.get("value", 0.0))
		target_stat = StringName(str(data.get("target_stat", "")))
	elif data.has("script"):
		var script_key := str(data.get("script", "add")).to_lower()
		mod_type = _LEGACY_MAP.get(script_key, StatModifier.ModifierType.FLAT)

		var val_dict = data.get("val", {})
		mod_value = float(val_dict.get("amount", 0.0)) if val_dict is Dictionary else float(val_dict)

		if script_key in ["subtruct", "subtract", "divide"]:
			mod_value = -mod_value

		var type_path := str(data.get("type", ""))
		if type_path.contains("stats."):
			var parts := type_path.split(".")
			if parts.size() >= 3:
				target_stat = StringName(parts[parts.size() - 1])
	else:
		push_warning("StatModifierFactory.create: unrecognised format — %s" % str(data))
		return StatModifier.make(0.0, StatModifier.ModifierType.FLAT, source)

	var mod := StatModifier.make(mod_value, mod_type, source)
	if target_stat != &"":
		mod.set_meta("target_stat", target_stat)
	return mod

func create_all(array: Array, source: Object = null) -> Array[StatModifier]:
	var result: Array[StatModifier] = []
	for data in array:
		if data is Dictionary:
			result.append(create(data, source))
	return result
