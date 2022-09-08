class_name Placesable extends StaticBody2D

export(NodePath) onready var sprite  = get_node(sprite) as TextureRect

var staticData = null
var data = null

func init():
	sprite.rect_position = Vector2(-staticData.size.x/2, -staticData.size.y/2)
	sprite.rect_min_size = Vector2(staticData.size.x, staticData.size.y)
	sprite.texture = Factory.items.itemObjectTexture[staticData.id]
	
	for stat in data.stats:
		data.stats[stat] = Factory.stats.create(stat, data.stats[stat], self)

func hurt(dmg):
	return data.stats.health.setVal(Factory.statsModifiers.create("subtruct", {"name": "Health", "amount": dmg}))
	
func healthStatCallback(health):
	if(health.val<=0): queue_free()



func serialize(_savedData): 
	var serializedData = {
		"filename" : get_filename(),
		"parent" : get_parent().get_path(),
		"position":{
			"x": position.x,
			"y": position.y
		},
		"global_rotation_degrees": global_rotation_degrees,
		"data": data.duplicate(true),
	}
	for stat in serializedData.data.stats: 
		serializedData.data.stats[stat] = data.stats[stat].serialize()
		
	return serializedData


func deserialize(savedData):
	position = Vector2(savedData.position.x, savedData.position.y)
	global_rotation_degrees = savedData.global_rotation_degrees
	data = Factory.items.dynamicData[savedData.data.id].duplicate(true)
	staticData = Factory.items.staticData[savedData.data.id]
	init()
	
	for stat in savedData.data.stats: data.stats[stat].deserialize(savedData.data.stats[stat])
	
