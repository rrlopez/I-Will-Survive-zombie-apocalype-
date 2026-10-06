class_name MeleeAttack extends EnemyAttack
## Standard melee attack: enables hitbox, plays animation, applies damage on hit.

var _is_attacking: bool = false
var _attack_damage: float = 0.0
var _attack_range: float = 0.0

func prepare(enemy: Enemy) -> void:
	# Size the hitbox based on enemy's attack_range stat
	_attack_range = enemy.stats.attack_range.value if enemy.stats and enemy.stats.attack_range else 32.0
	_attack_damage = enemy.stats.damage.value if enemy.stats and enemy.stats.damage else 10.0
	
	# Update hitbox collision shape
	var hitbox := enemy.attack_hitbox
	if hitbox:
		var shape_node := hitbox.get_node_or_null("CollisionShape2D") as CollisionShape2D
		if shape_node and shape_node.shape is CircleShape2D:
			(shape_node.shape as CircleShape2D).radius = _attack_range

func execute(enemy: Enemy) -> void:
	_is_attacking = true
	
	# Enable hitbox
	if enemy.attack_hitbox:
		enemy.attack_hitbox.monitoring = true
	
	# Play attack animation
	if enemy.body_upper and enemy.body_upper.has_method("play_upper"):
		enemy.body_upper.play_upper("attack")
	
	# TODO Phase 15: Play attack sound

func is_active(enemy: Enemy, _delta: float) -> bool:
	if not _is_attacking:
		return false
	
	# Check if animation is still playing
	if enemy.body_upper and enemy.body_upper.has_node("AnimationTree"):
		var anim_tree := enemy.body_upper.get_node("AnimationTree") as AnimationTree
		if anim_tree:
			# Check animation state (simplified - Phase 7 will have proper state machine)
			return true  # Placeholder - will be updated in Phase 7
	
	return false

func resolve(enemy: Enemy) -> void:
	_is_attacking = false
	
	# Disable hitbox
	if enemy.attack_hitbox:
		enemy.attack_hitbox.monitoring = false
		
		# Apply damage to all overlapping bodies
		var bodies := enemy.attack_hitbox.get_overlapping_bodies()
		for body in bodies:
			if body == enemy:  # Don't hit self
				continue
			
			if body.has_method("hurt"):
				body.hurt(_attack_damage, enemy)
				
				# Apply status effects (Phase 6+)
				# TODO: Apply bleeding, poison, etc. via StatusEffectFactory
