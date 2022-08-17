class_name Weapon extends Node2D

var isPressed
var lastFired = 0
var parent

var data

func hit(body):
	for statusEffect in data.statusEffects:
		Factory.statusEffects.create(statusEffect.duplicate(true), body, parent)
	body.hurt(parent, data.status.fire_dmg)
