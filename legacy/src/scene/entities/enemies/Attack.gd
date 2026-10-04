extends Node2D

func prepare(agent):
	get_child(0).prepare(agent)

func isAttacking(agent):
	get_child(0).isAttacking(agent)

func landed(agent):
	get_child(0).landed(agent)
