class_name DrainEffect extends RefCounted
## DrainEffect — periodic stat drain (bleed, poison). tick() returns true when exhausted.

@export var target_stat: StringName = &"health"
@export var amount: float   = 5.0
@export var rate: float     = 0.2
@export var duration: float = -1.0

var _rate_timer: float  = 0.0
var _total_timer: float = 0.0

func tick(entity: Node, delta: float) -> bool:
	_rate_timer  += delta
	_total_timer += delta
	if _rate_timer >= rate:
		_rate_timer = 0.0
		var stats: StatsComponent = entity.get_node_or_null("StatsComponent")
		if stats:
			var stat: Stat = stats.get_stat(target_stat)
			if stat:
				stat.value = stat.value - amount
				if target_stat == &"health" and stat.value <= 0.0:
					if entity.has_method("die"):
						entity.die()
	return duration >= 0.0 and _total_timer >= duration
