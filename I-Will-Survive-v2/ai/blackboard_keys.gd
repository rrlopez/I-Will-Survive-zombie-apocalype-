class_name BlackboardKeys
## BlackboardKeys — typed constants for behavior tree blackboard access.
## StringName constants are interned — comparison is O(1) pointer equality.

const OPPONENT := &"opponent"              # Node or null
const DESTINATION := &"destination"         # Vector2
const ATTACK_TIMER := &"attack_timer"       # float
const IS_ATTACKING := &"is_attacking"       # bool
const LAST_KNOWN_POS := &"last_known_pos"   # Vector2
const WANDER_TIMER := &"wander_timer"       # float
const PATH_READY := &"path_ready"           # bool
const IS_BLOCKED := &"is_blocked"           # bool
