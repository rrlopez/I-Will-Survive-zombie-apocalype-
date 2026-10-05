class_name MenuState extends Control
## MenuState — title screen. Pinned so it survives pops back to menu.

@onready var _btn_continue: Button = $VBoxContainer/BtnContinue

func _ready() -> void:
	_btn_continue.visible = Serialize.has_save_data()
	$VBoxContainer/BtnNewGame.pressed.connect(_on_btn_new_game_pressed)
	_btn_continue.pressed.connect(_on_btn_continue_pressed)

func _on_btn_new_game_pressed() -> void:
	Globals.state_manager.push_state(StateDefs.GAME)

func _on_btn_continue_pressed() -> void:
	Globals.state_manager.push_state(StateDefs.GAME)
