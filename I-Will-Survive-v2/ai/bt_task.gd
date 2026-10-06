class_name BTTask extends Resource
## BTTask — base class for all behavior tree nodes.
## Tasks are Resources (not Nodes) for zero scene-tree overhead.
## All BT logic runs via tick() calls, not _process().

enum Status {
	SUCCESS,   # Task completed successfully
	FAILURE,   # Task failed
	RUNNING    # Task is ongoing, continue next tick
}

## Called once when the BT is first initialized (optional).
## Use for one-time setup, caching references, etc.
func setup(_blackboard: Dictionary, _agent: Node) -> void:
	pass

## Called every BT tick. Override in subclasses.
## Returns Status indicating task result.
func tick(_blackboard: Dictionary, _agent: Node, _delta: float) -> Status:
	return Status.SUCCESS

## Called when the task needs to reset its state (optional).
## Used by composites when restarting sequences/selectors.
func reset() -> void:
	pass
