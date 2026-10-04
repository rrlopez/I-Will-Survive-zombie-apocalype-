class_name StatFactory extends RefCounted
## StatFactory — instantiates Stat resources from JSON data dicts.

const _LEGACY_SCRIPT_MAP: Dictionary = {
	"health": "health", "hunger": "hunger", "level": "level",
	"moveSpeed": "move_speed", "damage": "damage", "ammo": "ammo",
	"size": "size", "vision": "vision", "fireAccuracy": "fire_accuracy",
	"aggressionRange": "aggression_range", "default": "default",
}

func create(stat_id: String, data: Dictionary) -> Stat:
	var canonical := _normalise_id(stat_id, data)
	var stat: Stat
	match canonical:
		"damage": stat = DamageStat.new()
		"hunger": stat = HungerStat.new()
		"level":  stat = LevelStat.new()
		_:        stat = Stat.new()
	stat.init_from_data(data)
	return stat

func create_all(stats_data: Dictionary) -> Dictionary:
	var result: Dictionary = {}
	for raw_id in stats_data:
		var data: Dictionary = stats_data[raw_id]
		var canonical := _normalise_id(raw_id, data)

		if canonical == "vision":
			var val = data.get("val", {})
			if val is Dictionary:
				var wd := data.duplicate(); wd["val"] = float(val.get("width",  200.0)); wd["name"] = "Vision Width"
				result["vision_width"]  = create("vision_width",  wd)
				var hd := data.duplicate(); hd["val"] = float(val.get("height", 150.0)); hd["name"] = "Vision Height"
				result["vision_height"] = create("vision_height", hd)
			continue

		if canonical == "fire_accuracy":
			var val = data.get("val", {})
			if val is Dictionary:
				var xd := data.duplicate(); xd["val"] = float(val.get("x", 10.0)); xd["name"] = "Fire Spread X"
				result["fire_spread_x"] = create("fire_spread_x", xd)
				var yd := data.duplicate(); yd["val"] = float(val.get("y", 10.0)); yd["name"] = "Fire Spread Y"
				result["fire_spread_y"] = create("fire_spread_y", yd)
			continue

		result[canonical] = create(canonical, data)
	return result

func _normalise_id(raw_id: String, data: Dictionary) -> String:
	var script_key := str(data.get("script", ""))
	if script_key != "" and _LEGACY_SCRIPT_MAP.has(script_key):
		return _LEGACY_SCRIPT_MAP[script_key]
	if _LEGACY_SCRIPT_MAP.has(raw_id):
		return _LEGACY_SCRIPT_MAP[raw_id]
	return raw_id
