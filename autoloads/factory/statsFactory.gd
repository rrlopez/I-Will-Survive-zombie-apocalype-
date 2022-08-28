class_name StatsFactory extends Node

var stats = {
	'fireAccuracy': FireAccuracyStat,
	'ammo': AmmoStat,
	
	'health': HealthStat,
	'size': SizeStat,
	'moveSpeed': MoveSpeedStat,
	'aggressionRange': AggressionRangeStat,
	'vision': VisionStat,
	'hunger': HungerStat,
	'level': LevelStat,
	'default': DefaultStat
}

	
func create(name, data, agent):
	var stat = stats[data.script].new()
	stat.init(name, data.val, agent)
	return stat

func deserialize(data, agent):
	var stat = stats[data.script].new()
	stat.deserialize(data, agent)
	return stat
