class_name BTTreeResource extends Resource
## BTTreeResource — behavior tree data container.
## The tree structure is shared read-only across all enemies of the same type.
## Per-instance state lives in the blackboard (Dictionary), not in the tree.

@export var root: BTTask = null

## Initialize the tree (called once per agent instance).
func initialize(blackboard: Dictionary, agent: Node) -> void:
	if root:
		root.setup(blackboard, agent)

## Execute one tick of the behavior tree.
func tick(blackboard: Dictionary, agent: Node, delta: float) -> BTTask.Status:
	if not root:
		return BTTask.Status.FAILURE
	
	return root.tick(blackboard, agent, delta)
