class_name StatModifier extends Resource
## StatModifier — pure data. No logic, no Node, no side effects.
## Replaces the 7 legacy modifier subclasses with a single typed enum approach.
##
## Application order (enforced by Stat._calculate()):
##   1. FLAT             — base + sum(all FLAT)
##   2. PERCENT_ADD      — × (1 + sum(all PERCENT_ADD))
##   3. PERCENT_MULTIPLY — × product(1 + each PERCENT_MULTIPLY)
##   4. OVERRIDE         — ignores all above, returns this value directly

enum ModifierType {
	FLAT,             ## +/- flat amount added to base before any percent math
	PERCENT_ADD,      ## additive percent of base (10% + 20% = 30%, not 32%)
	PERCENT_MULTIPLY, ## multiplicative on top of everything else (compounding)
	OVERRIDE,         ## forces value to exactly this amount
}

@export var value: float = 0.0
@export var type: ModifierType = ModifierType.FLAT
@export var is_permanent: bool = false

var _source: WeakRef = null

static func make(p_value: float, p_type: ModifierType,
		p_source: Object = null, p_permanent: bool = false) -> StatModifier:
	var m := StatModifier.new()
	m.value        = p_value
	m.type         = p_type
	m.is_permanent = p_permanent
	if p_source != null:
		m._source = weakref(p_source)
	return m

func source_object() -> Object:
	if _source == null:
		return null
	return _source.get_ref()

func belongs_to(owner_object: Object) -> bool:
	var src := source_object()
	return src != null and src == owner_object
