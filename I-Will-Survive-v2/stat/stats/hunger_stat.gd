class_name HungerStat extends Stat
## HungerStat — Stat with automatic drain. When hunger hits 0 it damages health.
## Driven by StatsComponent._physics_process → HungerStat.tick(delta, stats).

@export var drain_rate: float = 1.0   ## hunger units lost per second
@export var tolerance: float  = 10.0  ## health damage per second while starving

func init_from_data(data: Dictionary) -> void:
	super.init_from_data(data)
	drain_rate = float(data.get("drain_rate", 1.0))
	tolerance  = float(data.get("tolerance",  10.0))

func tick(delta: float, stats: StatsComponent) -> void:
	if value > 0.0:
		value = value - drain_rate * delta
	else:
		var hp: Stat = stats.get_stat(&"health")
		if hp:
			hp.value = hp.value - tolerance * delta
			if hp.value <= 0.0:
				var entity: Node = stats.get_parent()
				if entity and entity.has_method("die"):
					entity.die()
