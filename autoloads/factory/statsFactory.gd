class_name StatsFactory extends Node

var stats = {
	'fireAccuracy': FireAccuracyStat,
	'ammo': AmmoStat,
	
	'health': HealthStat,
	'size': SizeStat,
	'moveSpeed': MoveSpeedStat,
	'aggressionRange': AggressionRangeStat,
	'vission': VissionStat,
	'hunger': HungerStat,
	'default': DefaultStat
}

	
func create(name, data, agent):
	return stats[data.script].new(name, data.val, agent)
