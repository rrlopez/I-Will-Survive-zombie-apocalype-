class_name LevelStat extends Stat

var experience = 0
var maxExperience = 0

func init(_name, _val, _agent):
	.init(_name, _val, _agent)
	maxExperience = val*Constants.EXP_MULTIPLYER


func setVal(modifier):
	experience = modifier.execute(experience)
	levelUp()
	
func levelUp():
	if experience >= maxExperience:
		val +=1
		maxVal = val
		defaultVal = val
		experience=experience-maxExperience
		maxExperience = val*Constants.EXP_MULTIPLYER
		levelUp()

	
func serialize():
	return {
		"val": val,
		"experience": experience,
	}

func deserialize(savedData):
	val = savedData.val
	experience = savedData.experience
	maxExperience = val*Constants.EXP_MULTIPLYER
