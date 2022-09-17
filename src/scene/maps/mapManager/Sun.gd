extends Node2D

var time = 0
var speed = 1

func _process(delta):
	time = fmod(time+(speed*delta), 180)
	if(time<90): day(delta)


func day(delta):
	var shadows = self.get_tree().get_nodes_in_group('shadow')
	var sunPosition = self.global_position
	for shadow in shadows:
		var parent = shadow.get_parent()
		var parentsPosition = parent.global_position
		var position = sunPosition+parentsPosition
		var distance = min(parent.data.size, parentsPosition.distance_to(position)*0.3)
		var direction = position.direction_to(parentsPosition).rotated(deg2rad(-parent.rotation_degrees))
		
		shadow.position = Vector2(direction.x*distance, direction.y*distance)
		shadow.modulate.a = min(1, (0.5-abs(sin(deg2rad(time))-0.5))*4)
		
	self.global_position = Vector2(((time-45)*5)+60, ((abs(sin(deg2rad(time))-0.5))*200)+10)
