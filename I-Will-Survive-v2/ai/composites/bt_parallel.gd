class_name BTParallel extends BTTask
## BTParallel — executes all children simultaneously.
## Configurable success/failure policy.

enum Policy {
	REQUIRE_ONE,   # Succeed/fail when one child succeeds/fails
	REQUIRE_ALL    # Succeed/fail when all children succeed/fail
}

@export var children: Array[BTTask] = []
@export var success_policy: Policy = Policy.REQUIRE_ALL
@export var failure_policy: Policy = Policy.REQUIRE_ONE

func setup(blackboard: Dictionary, agent: Node) -> void:
	for child in children:
		if child:
			child.setup(blackboard, agent)

func tick(blackboard: Dictionary, agent: Node, delta: float) -> Status:
	if children.is_empty():
		return Status.SUCCESS
	
	var success_count: int = 0
	var failure_count: int = 0
	var running_count: int = 0
	
	for child in children:
		if not child:
			continue
		
		var status := child.tick(blackboard, agent, delta)
		
		match status:
			Status.SUCCESS:
				success_count += 1
			Status.FAILURE:
				failure_count += 1
			Status.RUNNING:
				running_count += 1
	
	# Check failure policy
	if failure_policy == Policy.REQUIRE_ONE and failure_count > 0:
		reset()
		return Status.FAILURE
	elif failure_policy == Policy.REQUIRE_ALL and failure_count == children.size():
		reset()
		return Status.FAILURE
	
	# Check success policy
	if success_policy == Policy.REQUIRE_ONE and success_count > 0:
		reset()
		return Status.SUCCESS
	elif success_policy == Policy.REQUIRE_ALL and success_count == children.size():
		reset()
		return Status.SUCCESS
	
	# Still running
	return Status.RUNNING

func reset() -> void:
	for child in children:
		if child:
			child.reset()
