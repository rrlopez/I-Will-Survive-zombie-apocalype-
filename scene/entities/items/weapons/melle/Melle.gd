extends Node2D

var isPressed
var lastFired = 0
var parent

export(NodePath) onready var hitBox  = get_node(hitBox) as CollisionShape2D

var data

var knokback = {
	"id": "knockback",
	"name": "Knock back", 
	"type": "applyForce", 
	"stats": {
		"force": 200, 
		"friction": 0.05
	}
}

func _ready():
	parent.upperAnimation.connect("attackLanded", self, "attackLanded")
	parent.upperAnimation.connect("attackFinished", self, "attackFinished")
	parent.upperAnimation.playback_speed = data.status.fire_speed/10
	

func _process(delta):
	if isPressed:
		if lastFired >= data.status.fire_speed/10:
			Globals.player.upperAnimation.play("melle_attack")
			lastFired=0
		else: lastFired += delta

func _on_fireBtn_pressed():
	lastFired=data.status.fire_speed
	isPressed = true


func _on_hitBox_body_entered(body):
	Factory.statusEffects.create(knokback, body, parent)
	body.hurt(parent, data.status.fire_dmg)
	
func attackFinished():
	hitBox.disabled = true

func attackLanded():
	hitBox.disabled = false	


func _on_fireBtn_released():
	isPressed = false
