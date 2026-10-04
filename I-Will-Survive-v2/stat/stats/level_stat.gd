class_name LevelStat extends Stat
## LevelStat — XP + level tracking. base Stat.value = current XP.
## Level is stored separately. add_xp() handles multi-level-up correctly.

signal leveled_up(new_level: int)

var level: int           = 1
var xp_threshold: float  = 100.0
var _xp_multiplier: float = 100.0

func init_from_data(data: Dictionary) -> void:
	var raw_val = data.get("val", data.get("base", 1))
	if raw_val is Dictionary:
		Constants.rng.randomize()
		level = Constants.rng.randi_range(
			int(raw_val.get("min", 1)),
			int(raw_val.get("max", 1))
		)
	else:
		level = int(raw_val)

	_xp_multiplier = float(data.get("multiplier", data.get("level_multiplier", 100.0)))
	base_value     = float(level)
	min_value      = 0.0
	max_value      = -1.0
	stat_name      = str(data.get("name", "Level"))
	_recalculate_threshold()
	_cached_value = 0.0
	_is_dirty     = false

func add_xp(amount: float) -> void:
	_cached_value += amount
	_is_dirty      = false
	_check_level_up()

var xp: float:
	get: return value

func _check_level_up() -> void:
	while _cached_value >= xp_threshold:
		_cached_value -= xp_threshold
		level         += 1
		_recalculate_threshold()
		leveled_up.emit(level)

func _recalculate_threshold() -> void:
	xp_threshold = float(level) * _xp_multiplier
