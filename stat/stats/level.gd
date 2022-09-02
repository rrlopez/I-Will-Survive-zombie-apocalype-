class_name LevelStat extends Stat

var experience = 0
var maxExperience = 0

func init(data, _agent):
	Constants.rand.randomize()
	data.val = Constants.rand.randi_range(data.val.min, data.val.max)
	initValues(data, _agent)
	defaultVal = maxExperience


func recompute():
	maxExperience = defaultVal + agent.data.stats.level.val*multiplier
	for modifier in modifiers:
		maxExperience = modifier.execute(maxExperience)
		setVal(modifier)


func setVal(modifier):
	experience = modifier.execute(experience)
	if experience >= maxExperience:
		levelUp()
		agent.data.stats.health.val = agent.data.stats.health.maxVal
		for stat in agent.data.stats:
			 agent.data.stats[stat].recompute()
	
	
func levelUp():
	if experience >= maxExperience:
		val +=1
		maxVal = val
		defaultVal = val
		experience=experience-maxExperience
		maxExperience = defaultVal + agent.data.stats.level.val*multiplier
		levelUp()

	
func serialize():
	return {
		"val": val,
		"experience": experience,
	}

func deserialize(savedData):
	val = savedData.val
	experience = savedData.experience
	agent.recomputeStats()
