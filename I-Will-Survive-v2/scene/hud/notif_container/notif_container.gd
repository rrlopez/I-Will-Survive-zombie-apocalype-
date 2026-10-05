class_name NotifContainer extends VBoxContainer
## NotifContainer — pooled notification label feed.
## Pre-allocates 15 NotifLabel nodes. add_notif() pulls from pool,
## shows the label with a fade-in/hold/fade-out tween, then returns it to pool.
## Zero allocation at runtime after _ready().

const POOL_SIZE  := 15
const HOLD_TIME  := 2.5
const FADE_TIME  := 0.3

var _pool:   Array = []
var _active: Array = []

func _ready() -> void:
	for i in POOL_SIZE:
		var lbl := Label.new()
		lbl.hide()
		lbl.add_theme_font_size_override("font_size", 14)
		lbl.modulate.a = 0.0
		add_child(lbl)
		_pool.append(lbl)
	EventBus.notification_requested.connect(add_notif)

func add_notif(text: String) -> void:
	var lbl: Label
	if _pool.is_empty():
		# Evict oldest active notif
		lbl = _active.pop_front()
		lbl.show()
	else:
		lbl = _pool.pop_back()
		lbl.show()

	lbl.text    = text
	lbl.modulate.a = 0.0
	_active.push_back(lbl)

	var tween := lbl.create_tween()
	tween.tween_property(lbl, "modulate:a", 1.0, FADE_TIME)
	tween.tween_interval(HOLD_TIME)
	tween.tween_property(lbl, "modulate:a", 0.0, FADE_TIME)
	tween.tween_callback(_recycle.bind(lbl))

func _recycle(lbl: Label) -> void:
	lbl.hide()
	_active.erase(lbl)
	_pool.push_back(lbl)
