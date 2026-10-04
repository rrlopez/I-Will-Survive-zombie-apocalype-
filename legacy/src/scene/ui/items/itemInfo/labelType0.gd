extends HBoxContainer

func init(text):
	get_child(0).texture = text.icon
	get_child(1).text = text.value
