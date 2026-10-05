class_name PlacablePreview extends Node2D
## PlacablePreview — shows a ghost preview of a placable before placement.
## Tints green when placement is valid, red when blocked by overlap.
## Attach as child of Player.

# ── Node refs ─────────────────────────────────────────────────────────────────
@onready var _sprite:       ColorRect         = $Sprite2D
@onready var _overlap_area: Area2D            = $OverlapArea

# ── State ─────────────────────────────────────────────────────────────────────
var _static_data: Dictionary = {}
var _can_place: bool         = true

const COLOR_VALID:   Color = Color(0.3, 1.0, 0.3, 0.6)
const COLOR_BLOCKED: Color = Color(1.0, 0.3, 0.3, 0.6)

# ── Lifecycle ─────────────────────────────────────────────────────────────────

func _ready() -> void:
	hide()
	if _overlap_area:
		_overlap_area.body_entered.connect(_on_overlap_entered)
		_overlap_area.body_exited.connect(_on_overlap_exited)

# ── Public API ────────────────────────────────────────────────────────────────

## Show preview for a placable item's static_data dict.
## static_data must contain "size": {"x": float, "y": float} and optionally a texture path.
func build(static_data: Dictionary) -> void:
	_static_data = static_data
	_can_place   = true

	# Resize collision shape to match placable size
	var size := Vector2(
		float(static_data.get("size", {}).get("x", 88.0)),
		float(static_data.get("size", {}).get("y", 88.0))
	)
	var col := _overlap_area.get_node_or_null("CollisionShape2D")
	if col and col.shape is RectangleShape2D:
		(col.shape as RectangleShape2D).size = size

	if _sprite:
		_sprite.modulate = COLOR_VALID

	show()


## Confirm placement: consume ingredients, spawn the placable, hide preview.
func confirm() -> void:
	if not _can_place:
		return

	# Check recipe (Phase 8 inventory will handle ingredient consumption properly)
	var _recipe: Array = _static_data.get("recipe", [])
	var player := get_parent() as Player
	if player == null:
		return

	# Spawn the placable via factory (Phase 11 fully implements PlacableFactory)
	var placable_id: String = _static_data.get("id", "")
	if placable_id != "":
		Factory.placables.create(placable_id, global_position)

	cancel()


## Hide the preview without placing.
func cancel() -> void:
	_static_data = {}
	hide()

# ── Overlap detection ─────────────────────────────────────────────────────────

func _on_overlap_entered(_body: Node) -> void:
	_can_place = false
	if _sprite:
		_sprite.modulate = COLOR_BLOCKED


func _on_overlap_exited(_body: Node) -> void:
	# Only turn valid if no other bodies remain
	if _overlap_area and _overlap_area.get_overlapping_bodies().is_empty():
		_can_place = true
		if _sprite:
			_sprite.modulate = COLOR_VALID
