extends Node2D
## LowerBody — legs/locomotion visual component.
## AnimationTree with BlendSpace2D for 8-directional walk animation.

@onready var animation_tree: AnimationTree = $AnimationTree
@onready var sprite: Sprite2D = $Sprite2D

func _ready() -> void:
	if animation_tree:
		animation_tree.active = true

## Update animation blend position based on movement velocity.
## Called from enemy._physics_process with local velocity vector.
func update_animation(local_velocity: Vector2) -> void:
	if not animation_tree:
		return
	
	# Normalize velocity for blend space (-1 to 1 range)
	var blend_position := local_velocity.normalized()
	
	# Set blend space parameters (Phase 7 will have proper BlendSpace2D setup)
	if animation_tree.tree_root:
		animation_tree.set("parameters/BlendSpace2D/blend_position", blend_position)
