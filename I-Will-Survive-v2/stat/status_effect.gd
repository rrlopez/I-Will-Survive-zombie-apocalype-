class_name StatusEffect extends Resource
## StatusEffect — a timed bundle of StatModifiers + tick effects.
## Pure data resource. StatusEffectContainer Node drives its lifecycle.

@export var id: StringName   = &""
@export var display_name: String = ""
@export var icon_path: String    = ""
@export var duration: float      = -1.0   ## -1 = infinite

var _elapsed: float = 0.0
var modifiers: Array[StatModifier] = []
var tick_effects: Array = []

var _source: WeakRef = null

@warning_ignore("unused_signal")
signal expired()

func set_source(obj: Object) -> void:
	_source = weakref(obj)

func source_object() -> Object:
	if _source == null:
		return null
	return _source.get_ref()

## Advance elapsed. Returns true when expired.
func tick(delta: float) -> bool:
	if duration < 0.0:
		return false
	_elapsed += delta
	return _elapsed >= duration

func refresh() -> void:
	_elapsed = 0.0
