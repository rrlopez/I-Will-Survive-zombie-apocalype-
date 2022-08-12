class_name Stat_range extends Resource

var stat
var minimum: float
var maximum: float

func _init(data):
	stat = data.stat
	maximum = data.maximum
	minimum = data.minimum

func get_value(scale, needed_stat):
	if(stat == needed_stat):
		return round(lerp(minimum, maximum, scale))
	return 0
