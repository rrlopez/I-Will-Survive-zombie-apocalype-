class_name AmmoStat extends Stat

func init(_name, _val, _agent):
	.init(_name, _val, _agent)
	update()

func recompute():
	.recompute()
	update()


func setVal(modifier):
	.setVal(modifier)
	update()
	
func update():
	Globals.HUD.weaponPanel.label.text = String(val)

func serialize(script = "ammo"):
	return .serialize(script)
