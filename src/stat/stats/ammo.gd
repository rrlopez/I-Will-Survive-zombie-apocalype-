class_name AmmoStat extends Stat

func init(data, _agent):
	.init(data, _agent)

func recompute():
	.recompute()


func setVal(modifier):
	.setVal(modifier)
	
func getInfo():
	var info = .getInfo()
	info.value = String(val) + "/" + String(maxVal)
	return info

func deserialize(savedData):
	.deserialize(savedData)
