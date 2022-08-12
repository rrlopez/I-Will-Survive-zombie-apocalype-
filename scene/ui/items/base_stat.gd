class_name Base_stat extends Resource

var stat_ranges = []
var scale: float

func _init(data, value):
	scale = value
	
	for stat_range in data:
		stat_ranges.append(Stat_range.new(stat_range))
