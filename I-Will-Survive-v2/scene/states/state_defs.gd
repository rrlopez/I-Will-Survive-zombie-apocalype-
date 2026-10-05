class_name StateDefs
## StateDefs — paths to all game state scenes.
## Uses load() instead of preload() to avoid cyclic reference errors
## that occur when state scenes reference SceneStateManager at parse time.

const MENU_PATH:      String = "res://scene/states/menu_state/menu_state.tscn"
const GAME_PATH:      String = "res://scene/states/game_state/game_state.tscn"
const LOADING_PATH:   String = "res://scene/states/loading_state/loading_state.tscn"
const PAUSE_PATH:     String = "res://scene/states/pause_state/pause_state.tscn"
const MAP_PATH:       String = "res://scene/states/map_state/map_state.tscn"
const GAME_OVER_PATH: String = "res://scene/states/game_over_state/game_over_state.tscn"

static var MENU:      PackedScene: get = _get_menu
static var GAME:      PackedScene: get = _get_game
static var LOADING:   PackedScene: get = _get_loading
static var PAUSE:     PackedScene: get = _get_pause
static var MAP:       PackedScene: get = _get_map
static var GAME_OVER: PackedScene: get = _get_game_over

static func _get_menu()      -> PackedScene: return load(MENU_PATH)
static func _get_game()      -> PackedScene: return load(GAME_PATH)
static func _get_loading()   -> PackedScene: return load(LOADING_PATH)
static func _get_pause()     -> PackedScene: return load(PAUSE_PATH)
static func _get_map()       -> PackedScene: return load(MAP_PATH)
static func _get_game_over() -> PackedScene: return load(GAME_OVER_PATH)
