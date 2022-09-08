class_name Placesable extends StaticBody2D

var staticData = null
var data = null

func init():
	for stat in data.stats:
		data.stats[stat] = Factory.stats.create(stat, data.stats[stat], self)

func hurt(dmg):
	return data.stats.health.setVal(Factory.statsModifiers.create("subtruct", {"name": "Health", "amount": dmg}))
	
func healthStatCallback(health):
	if(health.val<=0): queue_free()
