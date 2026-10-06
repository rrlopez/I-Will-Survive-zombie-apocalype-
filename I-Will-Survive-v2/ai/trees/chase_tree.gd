class_name ChaseTree
## ChaseTree — aggressive enemy that always chases the player.
## Sets player as opponent, then uses BasicAI logic.

static func create() -> BTTreeResource:
	var tree := BTTreeResource.new()
	
	# Root sequence
	var root := BTSequence.new()
	
	# 1. Set player as target
	var set_player := BTSetPlayerAsOpponent.new()
	
	# 2. Use basic AI combat logic
	# We'll create a simplified version inline since we can't reference the full BasicAI
	var combat_selector := BTSelector.new()
	
	# --- Attack branch ---
	var attack_sequence := BTSequence.new()
	var has_opponent := BTHasOpponent.new()
	var validate := BTValidateOpponent.new()
	var is_in_range := BTIsOpponentInRange.new()
	var cooldown_ready := BTAttackCooldownReady.new()
	var choose_attack := BTChooseAttack.new()
	choose_attack.cooldown = 1.0
	var execute_attack := BTExecuteAttack.new()
	attack_sequence.children = [has_opponent, validate, is_in_range, cooldown_ready, choose_attack, execute_attack]
	
	# --- Chase branch ---
	var chase_sequence := BTSequence.new()
	var has_opponent2 := BTHasOpponent.new()
	var set_chase_dest := BTSetChaseDestination.new()
	var request_path := BTRequestPath.new()
	var navigate := BTNavigatePath.new()
	chase_sequence.children = [has_opponent2, set_chase_dest, request_path, navigate]
	
	combat_selector.children = [attack_sequence, chase_sequence]
	
	root.children = [set_player, combat_selector]
	
	# Wrap in repeat
	var repeat := BTRepeat.new()
	repeat.times = 0  # Infinite
	repeat.child = root
	
	tree.root = repeat
	return tree
