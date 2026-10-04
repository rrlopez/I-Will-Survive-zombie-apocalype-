class_name Stat extends Resource
## Stat — a single numeric game stat backed by a dirty-flag cache.
##
## Formula (industry-standard order of operations):
##   final = (base + Σ FLAT)
##           × (1 + Σ PERCENT_ADD)
##           × Π (1 + each PERCENT_MULTIPLY)
##   clamped to [min_value, max_value]
##   OVERRIDE beats all: if any OVERRIDE modifier present, returns its value.

@export var base_value: float       = 0.0
@export var min_value: float        = 0.0
@export var max_value: float        = -1.0   ## -1 = uncapped
@export var level_multiplier: float = 0.0
@export var stat_name: String       = ""

var _modifiers: Array[StatModifier] = []
var _is_dirty: bool                 = true
var _cached_value: float            = 0.0

signal stat_changed(old_val: float, new_val: float)

# ── Value (dirty-flag cached) ─────────────────────────────────────────────────

var value: float:
	get:
		if _is_dirty:
			var old := _cached_value
			_cached_value = _calculate()
			_is_dirty = false
			if _cached_value != old:
				stat_changed.emit(old, _cached_value)
		return _cached_value
	set(v):
		var clamped := _clamp_value(v)
		var old     := _cached_value
		_cached_value = clamped
		_is_dirty     = false
		if _cached_value != old:
			stat_changed.emit(old, _cached_value)

# ── Modifier management ───────────────────────────────────────────────────────

func add_modifier(mod: StatModifier) -> void:
	_modifiers.append(mod)
	_mark_dirty()

func remove_modifier(mod: StatModifier) -> bool:
	var idx := _modifiers.find(mod)
	if idx == -1:
		return false
	_modifiers.remove_at(idx)
	_mark_dirty()
	return true

func remove_all_from_source(owner_object: Object) -> void:
	var n := 0
	for i in range(_modifiers.size() - 1, -1, -1):
		if _modifiers[i].belongs_to(owner_object):
			_modifiers.remove_at(i)
			n += 1
	if n > 0:
		_mark_dirty()

func remove_temporary_modifiers() -> void:
	var n := 0
	for i in range(_modifiers.size() - 1, -1, -1):
		if not _modifiers[i].is_permanent:
			_modifiers.remove_at(i)
			n += 1
	if n > 0:
		_mark_dirty()

func has_modifier_from(owner_object: Object) -> bool:
	for mod in _modifiers:
		if mod.belongs_to(owner_object):
			return true
	return false

# ── Initialization ────────────────────────────────────────────────────────────

func init_from_data(data: Dictionary) -> void:
	base_value       = float(data.get("base",             data.get("val", 0.0)))
	min_value        = float(data.get("min",              0.0))
	max_value        = float(data.get("max",              -1.0))
	level_multiplier = float(data.get("level_multiplier", data.get("multiplier", 0.0)))
	stat_name        = str(data.get("name", ""))
	_cached_value    = base_value
	_is_dirty        = true

func reset() -> void:
	remove_temporary_modifiers()
	value = base_value

# ── Internal ──────────────────────────────────────────────────────────────────

func _mark_dirty() -> void:
	_is_dirty = true
	var _v := value   # force recalc + signal emit this frame

func _calculate() -> float:
	var flat_sum:                 float = 0.0
	var percent_add_sum:          float = 0.0
	var percent_multiply_product: float = 1.0
	var override_val:             float = 0.0
	var has_override:             bool  = false

	for mod in _modifiers:
		match mod.type:
			StatModifier.ModifierType.FLAT:
				flat_sum += mod.value
			StatModifier.ModifierType.PERCENT_ADD:
				percent_add_sum += mod.value
			StatModifier.ModifierType.PERCENT_MULTIPLY:
				percent_multiply_product *= (1.0 + mod.value)
			StatModifier.ModifierType.OVERRIDE:
				override_val = mod.value
				has_override = true

	if has_override:
		return _clamp_value(override_val)

	var result := (base_value + flat_sum) \
		* (1.0 + percent_add_sum) \
		* percent_multiply_product
	return _clamp_value(result)

func _clamp_value(v: float) -> float:
	v = maxf(v, min_value)
	if max_value >= 0.0:
		v = minf(v, max_value)
	return v
