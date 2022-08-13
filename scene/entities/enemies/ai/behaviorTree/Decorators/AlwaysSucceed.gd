extends Task

class_name AlwaysSucceed, "res://scene/entities/enemies/ai/behaviorTree/icons/always-succeed.png"

func run(delta):
	if get_child_count() > 0:
		get_child(0).run(delta)
	success()

# Ignore child failure
func child_fail():
	pass

# Ignore child success
func child_success():
	pass
