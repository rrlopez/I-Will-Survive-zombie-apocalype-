class_name DamageStat extends Stat

var span = 5

func init(data, _agent):
	initValues(data, _agent)

func getVal():
	Constants.rand.randomize()
	return Constants.rand.randi_range(max(val-span, 0), val+span)

func getInfo():
	var info = .getInfo()
	info.value = String(max(val-span, 0)) + " - " + String(val+span)
	return info
