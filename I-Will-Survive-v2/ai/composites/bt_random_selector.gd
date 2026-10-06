class_name BTRandomSelector extends BTSelector
## BTRandomSelector — selector with shuffled child order.
## Reshuffles on reset for varied behavior.

func setup(blackboard: Dictionary, agent: Node) -> void:
	_shuffle_children()
	super.setup(blackboard, agent)

func reset() -> void:
	super.reset()
	_shuffle_children()

func _shuffle_children() -> void:
	if children.is_empty():
		return
	
	# Fisher-Yates shuffle
	for i in range(children.size() - 1, 0, -1):
		var j := randi() % (i + 1)
		var temp := children[i]
		children[i] = children[j]
		children[j] = temp
