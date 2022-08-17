class_name StatsFactory extends Node

var stats = {
	'health': HealthStat,
	'size': SizeStat,
	'moveSpeed': MoveSpeedStat,
	'aggressionRange': AggressionRangeStat,
	'vission': VissionStat,
	'default': DefaultStat,
}

	
func create(name, data, agent):
	return stats[data.script].new(name, data.val, agent)
	
