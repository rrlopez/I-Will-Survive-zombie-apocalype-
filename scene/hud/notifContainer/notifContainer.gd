extends VBoxContainer

export(NodePath) onready var notif  = get_node(notif) as Label
var maxNotifCount = 15

func addNotif(text):
	var newNotif = notif.duplicate()
	add_child(newNotif)
	move_child(newNotif, 1)
	newNotif.text = text
	newNotif.show()
	if get_child_count() > maxNotifCount: get_child(maxNotifCount).queue_free()
