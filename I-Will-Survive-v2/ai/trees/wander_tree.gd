class_name WanderTree
## WanderTree — simple wander behavior.
## Finds a random destination, requests path, navigates to it, then repeats.

static func create() -> BTTreeResource:
	var tree := BTTreeResource.new()
	
	# Root: Sequence that repeats forever
	var root := BTSequence.new()
	
	# 1. Find a random destination
	var find_dest := BTFindDestination.new()
	find_dest.wander_radius = 400.0
	
	# 2. Request navigation path
	var request_path := BTRequestPath.new()
	
	# 3. Navigate to destination
	var navigate := BTNavigatePath.new()
	
	# Assemble sequence
	root.children = [find_dest, request_path, navigate]
	
	# Wrap in repeat to make it continuous
	var repeat := BTRepeat.new()
	repeat.times = 0  # Infinite
	repeat.child = root
	
	tree.root = repeat
	return tree
