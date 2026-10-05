class_name Entity extends CharacterBody2D
## Entity — base class for all living things (Player, Enemy, Placable).
## Provides the shared contract: StatsComponent, applied_force, hurt/die API.
## Subclasses override hurt() and die() to add their own feedback.

# ── Components ────────────────────────────────────────────────────────────────
@onready var stats: StatsComponent = $StatsComponent

# ── Shared physics state ──────────────────────────────────────────────────────
## External forces (knockback, charge) accumulate here each frame.
## Decayed by the subclass physics process (FORCE_FRICTION lerp).
var applied_force: Vector2 = Vector2.ZERO

# ── Lifecycle ─────────────────────────────────────────────────────────────────

func _ready() -> void:
	# Connect health signal so subclasses react via _on_health_changed()
	if stats:
		stats.health.stat_changed.connect(_on_health_changed)

# ── Contract — subclasses implement these ─────────────────────────────────────

## Called when the entity receives damage. Override to add visual/audio feedback.
## `damage`  — raw damage amount (already applied by caller via stats.take_damage)
## `source`  — the node that dealt the damage (used for knockback direction etc.)
func hurt(_damage: float, _source: Node = null) -> void:
	pass

## Called when health reaches 0. Override to handle death (drop loot, game over, etc.)
func die() -> void:
	pass

# ── Shared utility ────────────────────────────────────────────────────────────

## Add an impulse force in `direction` with given `force` magnitude.
## The force decays each physics frame via FORCE_FRICTION in the subclass.
func _apply_knockback(direction: Vector2, force: float) -> void:
	applied_force += direction.normalized() * force

# ── Internal ──────────────────────────────────────────────────────────────────

## Override in subclasses to react to health changes (vignette, death check, etc.)
func _on_health_changed(_old_val: float, _new_val: float) -> void:
	pass
