class_name AmmoStat extends Stat

func _init(_name, _val, _agent):
	init(_name, _val, _agent)
	update()

func recompute():
	.recompute()
	update()


func setVal(modifier):
	.setVal(modifier)
	update()
	
func update():
	Globals.HUD.weaponPanel.label.text = String(val)
