class_name ChargeAttack extends EnemyAttack
## Charge attack: applies forward force effect toward opponent, damages on contact.
## Uses ForceEffect from Phase 1 stat system.

var _is_charging: bool = false
var _charge_duration: float = 1.5  # Duration of charge in seconds
var _charge_timer: float = 0.0
var _charge_damage: float = 0.0
var _charge_force: float = 500.0

func prepare(enemy: Enemy) -> void:
	_charge_damage = enemy.stats.damage.value * 1.5 if enemy.stats and enemy.stats.damage else 20.0  # Charge does more damage
	
	# Extend hitbox forward for charge
	var hitbox := enemy.attack_hitbox
	if hitbox:
		var shape_node := hitbox.get_node_or_null("CollisionShape2D") as CollisionShape2D
		if shape_node and shape_node.shape is CircleShape2D:
			var range_val := enemy.stats.attack_range.value if enemy.stats and enemy.stats.attack_range else 32.0
			(shape_node.shape as CircleShape2D).radius = range_val * 1.5

func execute(enemy: Enemy) -> void:
	_is_charging = true
	_charge_timer = _charge_duration
	
	# Enable hitbox
	if enemy.attack_hitbox:
		enemy.attack_hitbox.monitoring = true
	
	# Apply charge force toward opponent
	var opponent := enemy.get_opponent()
	if opponent:
		var direction := enemy.global_position.direction_to(opponent.global_position)
		enemy.applied_force += direction * _charge_force
	
	# Play charge animation
	if enemy.body_upper and enemy.body_upper.has_method("play_upper"):
		enemy.body_upper.play_upper("attack")
	
	# TODO Phase 15: Play charge sound/growl

func is_active(enemy: Enemy, delta: float) -> bool:
	if not _is_charging:
		return false
	
	_charge_timer -= delta
	
	# Continue applying forward force during charge
	var opponent := enemy.get_opponent()
	if opponent:
		var direction := enemy.global_position.direction_to(opponent.global_position)
		enemy.applied_force += direction * (_charge_force * 0.1)  # Sustained force
	
	return _charge_timer > 0.0

func resolve(enemy: Enemy) -> void:
	_is_charging = false
	_charge_timer = 0.0
	
	# Disable hitbox
	if enemy.attack_hitbox:
		enemy.attack_hitbox.monitoring = false
		
		# Apply damage to all bodies hit during charge
		var bodies := enemy.attack_hitbox.get_overlapping_bodies()
		for body in bodies:
			if body == enemy:
				continue
			
			if body.has_method("hurt"):
				body.hurt(_charge_damage, enemy)
				
				# Apply knockback to target
				if body.has_method("_apply_knockback"):
					var direction := enemy.global_position.direction_to(body.global_position)
					body._apply_knockback(direction, _charge_force * 0.5)
