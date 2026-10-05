class_name Calendar extends Label
## Calendar — shows the current day number.
## Connects to EventBus.day_started. Zero _process polling.

func _ready() -> void:
	text = "Day 1"
	EventBus.day_started.connect(_on_day_started)

func _on_day_started(day_number: int) -> void:
	text = "Day %d" % day_number
