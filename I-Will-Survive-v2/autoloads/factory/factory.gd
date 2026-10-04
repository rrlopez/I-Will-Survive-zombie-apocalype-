extends Node
## Factory — root aggregator. Access sub-factories via Factory.<name>.
## Each sub-factory is a plain RefCounted class instantiated here once.

const EnemyFactory        := preload("res://autoloads/factory/enemy_factory.gd")
const ItemFactory         := preload("res://autoloads/factory/item_factory.gd")
const EquipmentFactory    := preload("res://autoloads/factory/equipment_factory.gd")
const PlacableFactory     := preload("res://autoloads/factory/placable_factory.gd")
const StatFactory         := preload("res://autoloads/factory/stat_factory.gd")
const StatModifierFactory := preload("res://autoloads/factory/stat_modifier_factory.gd")
const StatusEffectFactory := preload("res://autoloads/factory/status_effect_factory.gd")
const ParticleFactory     := preload("res://autoloads/factory/particle_factory.gd")

var enemies:        EnemyFactory        = EnemyFactory.new()
var items:          ItemFactory         = ItemFactory.new()
var equipments:     EquipmentFactory    = EquipmentFactory.new()
var placables:      PlacableFactory     = PlacableFactory.new()
var stats:          StatFactory         = StatFactory.new()
var stat_modifiers: StatModifierFactory = StatModifierFactory.new()
var status_effects: StatusEffectFactory = StatusEffectFactory.new()
var particles:      ParticleFactory     = ParticleFactory.new()
