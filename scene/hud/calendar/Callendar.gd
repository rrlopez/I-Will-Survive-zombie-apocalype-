extends ColorRect

export(NodePath) onready var dayLabel = get_node(dayLabel) as Label

func _ready():
	yield(get_tree(),"idle_frame")
	Globals.mapManager.dayNightCycle.connect("dayStarted", self, "setDay")

func setDay(day):
	dayLabel.text = String(day)
