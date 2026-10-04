class_name DamageStat extends Stat
## DamageStat — Stat with random spread on final output.
## get_ranged_value() returns a randomised result within [value-spread, value+spread].

@export var spread: float = 0.0

func init_from_data(data: Dictionary) -> void:
	super.init_from_data(data)
	spread = float(data.get("spread", 0.0))

func get_ranged_value() -> float:
	if spread <= 0.0:
		return value
	return randf_range(value - spread, value + spread)
