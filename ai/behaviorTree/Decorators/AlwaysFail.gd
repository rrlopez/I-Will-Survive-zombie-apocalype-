extends Task

class_name AlwaysFail, "../icons/always-fail.png"

func run(delta):
	if get_child_count() > 0:
		get_child(0).run(delta)
	fail()

# Ignore child success
func child_success():
	pass

# Ignore child failure
func child_fail():
	pass
