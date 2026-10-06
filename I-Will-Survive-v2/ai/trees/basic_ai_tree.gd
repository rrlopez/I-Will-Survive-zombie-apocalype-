class_name BasicAITree
## BasicAITree — main enemy AI with combat and wander behaviors.
## Structure:
## Selector
##   ├── Combat Branch (if has opponent)
##   │   ├── Validate opponent
##   │   └── Selector
##   │       ├── Attack (if in range)
##   │       └── Chase (if out of range)
##   └── Wander (fallback when no opponent)

static func create() -> BTTreeResource:
	var tree := BTTreeResource.new()
	
	# === DETECT PLAYER BRANCH (if no opponent) ===
	var detect_sequence := BTSequence.new()
	var has_no_opponent := BTInvert.new()
	has_no_opponent.child = BTHasOpponent.new()
	
	# Try to detect player (proximity OR vision)
	var detect_player := BTDetectNearbyPlayer.new()
	detect_player.detection_range = 80.0  # Proximity range (short, 360°)
	# Vision range is 400 pixels (longer, cone-shaped, defined by raycasts)
	
	detect_sequence.children = [has_no_opponent, detect_player]
	
	# === LOSE PLAYER BRANCH (if opponent exists but too far) ===
	var lose_sequence := BTSequence.new()
	var has_opponent_check := BTHasOpponent.new()
	var lose_player := BTLosePlayer.new()
	lose_player.lose_distance = 600.0  # Lose player if they get this far
	lose_sequence.children = [has_opponent_check, lose_player]
	
	# === COMBAT BRANCH ===
	var combat_sequence := BTSequence.new()
	
	# Check for opponent
	var has_opponent := BTHasOpponent.new()
	
	# Validate opponent
	var validate_opponent := BTValidateOpponent.new()
	
	# Combat selector: attack or chase
	var combat_selector := BTSelector.new()
	
	# --- Attack branch ---
	var attack_sequence := BTSequence.new()
	var is_in_range := BTIsOpponentInRange.new()
	var cooldown_ready := BTAttackCooldownReady.new()
	var choose_attack := BTChooseAttack.new()
	choose_attack.cooldown = 1.5
	var execute_attack := BTExecuteAttack.new()
	attack_sequence.children = [is_in_range, cooldown_ready, choose_attack, execute_attack]
	
	# --- Chase branch ---
	var chase_sequence := BTSequence.new()
	var set_chase_dest := BTSetChaseDestination.new()
	var request_path := BTRequestPath.new()
	var navigate := BTNavigatePath.new()
	chase_sequence.children = [set_chase_dest, request_path, navigate]
	
	combat_selector.children = [attack_sequence, chase_sequence]
	combat_sequence.children = [has_opponent, validate_opponent, combat_selector]
	
	# === WANDER BRANCH (Fallback) ===
	# Use AlwaysSucceed decorator so wander doesn't block when destination is reached
	var wander_sequence := BTSequence.new()
	var find_dest := BTFindDestination.new()
	find_dest.wander_radius = 300.0
	find_dest.idle_min = 2.0   # seconds to stand still after arriving
	find_dest.idle_max = 5.0   # randomised per destination
	var wander_move := BTWanderToDestination.new()
	wander_sequence.children = [find_dest, wander_move]
	
	# Wrap in AlwaysSucceed so it doesn't block the tree
	var wander_always := BTAlwaysSucceed.new()
	wander_always.child = wander_sequence
	
	# === ROOT SELECTOR ===
	# Priority order: detect > lose > combat > wander
	# The selector tries each branch in order, succeeding on the first SUCCESS/RUNNING
	# This means if detect or combat return RUNNING, wander never executes
	var root := BTSelector.new()
	root.children = [detect_sequence, lose_sequence, combat_sequence, wander_always]
	
	# Wrap in repeat
	var repeat := BTRepeat.new()
	repeat.times = 0  # Infinite
	repeat.child = root
	
	tree.root = repeat
	return tree
