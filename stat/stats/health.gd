class_name HealthStat extends Stat

func _init(_name, _val, _agent):
	init(_name, _val, _agent)

func setVal(modifier):
	.setVal(modifier)
	if(val<maxVal/2):
		var scale = lerp(1.2, 2, val)#((val*2)/(maxVal/2), 1.2)
		var alpha = lerp(0, 0.4, val)#min((val*0.4)/(maxVal/2),0)
		Globals.HUD.cameraEffect.modulate.a = alpha
		Globals.HUD.cameraEffect.scale = Vector2(scale, scale)
	
	if(val<1): return true
	return false
