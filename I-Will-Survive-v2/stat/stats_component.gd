class_name StatsComponent extends Node
## StatsComponent — entity-facing stat API node.
## Owns all Stat resources + StatusEffectContainer.
## Lives as a direct child of every Entity (Player, Enemy, Placable, etc.).

# ── Stat exports ──────────────────────────────────────────────────────────────
@export_group("Core")
@export var health:     Stat = Stat.new()
@export var move_speed: Stat = Stat.new()

@export_group("Survival")
@export var hunger:           Stat = Stat.new()
@export var hunger_tolerance: Stat = Stat.new()

@export_group("Combat")
@export var damage:           Stat = Stat.new()
@export var attack_speed:     Stat = Stat.new()
@export var attack_range:     Stat = Stat.new()
@export var attack_sound:     Stat = Stat.new()
@export var aggression_range: Stat = Stat.new()
@export var ammo:             Stat = Stat.new()
@export var reload_duration:  Stat = Stat.new()
@export var reload_rate:      Stat = Stat.new()

@export_group("Body")
@export var size:        Stat = Stat.new()
@export var angle_speed: Stat = Stat.new()

@export_group("Vision")
@export var vision_width:  Stat = Stat.new()
@export var vision_height: Stat = Stat.new()

@export_group("Accuracy")
@export var fire_spread_x: Stat = Stat.new()
@export var fire_spread_y: Stat = Stat.new()

@export_group("Levelling")
@export var level: Stat = Stat.new()   ## replaced with LevelStat in init_from_data
@export var exp:   Stat = Stat.new()

# ── Status effect container ────────────────────────────────────────────────────
@onready var effects: StatusEffectContainer = $StatusEffectContainer

# ── Internal lookup table ─────────────────────────────────────────────────────
var _stat_map: Dictionary = {}

# ── Forwarded signals ─────────────────────────────────────────────────────────
signal health_changed(old_val: float, new_val: float)
signal move_speed_changed(old_val: float, new_val: float)
signal hunger_changed(old_val: float, new_val: float)
signal level_changed(new_level: int)

# ── Lifecycle ─────────────────────────────────────────────────────────────────

func _ready() -> void:
	if effects:
		effects._stats = self
	_rebuild_stat_map()
	_connect_forward_signals()

func _physics_process(delta: float) -> void:
	if effects:
		effects.tick(delta)
	if hunger is HungerStat:
		(hunger as HungerStat).tick(delta, self)

# ── Initialization ────────────────────────────────────────────────────────────

func init_from_data(data: Dictionary) -> void:
	for stat_id in data:
		var stat_data: Dictionary = data[stat_id]
		stat_data["id"] = stat_id
		var instance := _create_stat_for_id(stat_id, stat_data)
		instance.init_from_data(stat_data)
		_set_stat(stat_id, instance)
	_rebuild_stat_map()
	_connect_forward_signals()

# ── Entity API ────────────────────────────────────────────────────────────────

## Returns true if entity should die.
func take_damage(amount: float) -> bool:
	health.value = maxf(health.value - amount, health.min_value)
	return health.value <= 0.0

func heal(amount: float) -> void:
	health.value = health.value + amount

func apply_effect(effect: StatusEffect) -> void:
	if effects:
		effects.add(effect)

func remove_effects_from(source: Object) -> void:
	if effects:
		effects.remove_all_from_source(source)
	for stat in _stat_map.values():
		(stat as Stat).remove_all_from_source(source)

func apply_level_scaling(new_level: int) -> void:
	for stat in _stat_map.values():
		var s := stat as Stat
		if s.level_multiplier == 0.0:
			continue
		s.remove_all_from_source(self)
		if new_level > 1:
			var scaled := s.base_value * s.level_multiplier * float(new_level - 1)
			s.add_modifier(StatModifier.make(scaled, StatModifier.ModifierType.FLAT, self, true))

func get_stat(stat_name: StringName) -> Stat:
	return _stat_map.get(stat_name, null)

func has_stat(stat_name: StringName) -> bool:
	return _stat_map.has(stat_name)

# ── Internal ──────────────────────────────────────────────────────────────────

func _connect_forward_signals() -> void:
	if health and not health.stat_changed.is_connected(_on_health_changed):
		health.stat_changed.connect(_on_health_changed)
	if move_speed and not move_speed.stat_changed.is_connected(_on_move_speed_changed):
		move_speed.stat_changed.connect(_on_move_speed_changed)
	if hunger and not hunger.stat_changed.is_connected(_on_hunger_changed):
		hunger.stat_changed.connect(_on_hunger_changed)
	if level is LevelStat and not (level as LevelStat).leveled_up.is_connected(_on_leveled_up):
		(level as LevelStat).leveled_up.connect(_on_leveled_up)

func _on_health_changed(o: float, n: float)     -> void: health_changed.emit(o, n)
func _on_move_speed_changed(o: float, n: float) -> void: move_speed_changed.emit(o, n)
func _on_hunger_changed(o: float, n: float)     -> void: hunger_changed.emit(o, n)
func _on_leveled_up(lvl: int)                   -> void: level_changed.emit(lvl)

func _rebuild_stat_map() -> void:
	_stat_map = {
		&"health": health, &"move_speed": move_speed,
		&"hunger": hunger, &"hunger_tolerance": hunger_tolerance,
		&"damage": damage, &"attack_speed": attack_speed,
		&"attack_range": attack_range, &"attack_sound": attack_sound,
		&"aggression_range": aggression_range, &"ammo": ammo,
		&"reload_duration": reload_duration, &"reload_rate": reload_rate,
		&"size": size, &"angle_speed": angle_speed,
		&"vision_width": vision_width, &"vision_height": vision_height,
		&"fire_spread_x": fire_spread_x, &"fire_spread_y": fire_spread_y,
		&"level": level, &"exp": exp,
	}

func _set_stat(stat_id: String, instance: Stat) -> void:
	match stat_id:
		"health":                          health           = instance
		"move_speed", "moveSpeed":         move_speed       = instance
		"hunger":                          hunger           = instance
		"hunger_tolerance":                hunger_tolerance = instance
		"damage":                          damage           = instance
		"attack_speed":                    attack_speed     = instance
		"attack_range":                    attack_range     = instance
		"attack_sound":                    attack_sound     = instance
		"aggression_range","aggressionRange": aggression_range = instance
		"ammo":                            ammo             = instance
		"reload_duration":                 reload_duration  = instance
		"reload_rate":                     reload_rate      = instance
		"size":                            size             = instance
		"angle_speed":                     angle_speed      = instance
		"vision_width":                    vision_width     = instance
		"vision_height":                   vision_height    = instance
		"fire_spread_x":                   fire_spread_x    = instance
		"fire_spread_y":                   fire_spread_y    = instance
		"level":                           level            = instance
		"exp":                             exp              = instance
		_: _stat_map[StringName(stat_id)]  = instance

func _create_stat_for_id(stat_id: String, _data: Dictionary) -> Stat:
	match stat_id:
		"damage": return DamageStat.new()
		"hunger": return HungerStat.new()
		"level":  return LevelStat.new()
		_:        return Stat.new()
