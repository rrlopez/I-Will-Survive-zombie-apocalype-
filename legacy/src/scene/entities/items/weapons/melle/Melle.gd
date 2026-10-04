extends Weapon

export(NodePath) onready var hitBox  = get_node(hitBox) as CollisionShape2D

func _ready():
	parent.body.connect("attackLanded", self, "attackLanded")
	parent.body.connect("attackFinished", self, "attackFinished")
	parent.body.upperBodyAnimation.playback_speed = item.data.stats.attack_speed.val/10
	

func _process(delta):
	if isPressed:
		if lastFired >= item.data.stats.attack_speed.val/10:
			Globals.player.body.upperBodyAnimation.play("melle_attack")
			lastFired=0
		else: lastFired += delta

func _on_fireBtn_pressed():
	lastFired=item.data.stats.attack_speed.val
	isPressed = true


func _on_hitBox_body_entered(body):
	.hit(body)
	
func attackFinished():
	hitBox.set_deferred("disabled", true)

func attackLanded():
	hitBox.set_deferred("disabled", false)


func _on_fireBtn_released():
	isPressed = false


func _on_Melle_tree_entered():
	Globals.HUD.infoPanel.updateText(self)
	Globals.HUD.infoPanel.cooldown.hide()

func getInfoPanelText():
	return ""
