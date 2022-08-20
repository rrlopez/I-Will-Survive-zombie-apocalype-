extends CanvasModulate

var time = 20
var speed = 0.2

signal dayStarted

func _ready():
	$Animation.play("cycle")
	$Animation.playback_speed = speed
	$Animation.seek(time)

func _process(delta):
	time = fmod(time+(speed*delta), 180)
	if(time<90): day(delta)


func day(_delta):
	var sunPosition = $AmbiantLight.global_position
	var shadows = self.get_tree().get_nodes_in_group('shadow')
	for shadow in shadows:
		var parent = shadow.get_parent()
		if(!parent.visible): continue
		var parentsPosition = parent.global_position
		var position = sunPosition+parentsPosition
		var distance = min(50, parentsPosition.distance_to(position)*0.3)
		var direction = position.direction_to(parentsPosition).rotated(deg2rad(-parent.rotation_degrees))
		
		shadow.position = Vector2(direction.x*distance, direction.y*distance)
		shadow.modulate.a = min(1, (0.5-abs(sin(deg2rad(time))-0.5))*4)
	
	$AmbiantLight.global_position = Vector2(((time-45)*5)+60, ((abs(sin(deg2rad(time))-0.5))*200)+10)


func dayStarted():
	emit_signal("dayStarted")
