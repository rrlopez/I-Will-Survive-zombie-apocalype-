class_name GameOverState extends Control
## GameOverState — overlay shown on player death.
## Revive restores player and unpauses. Main Menu clears to menu.

func _enter_tree() -> void:
	get_tree().paused = true
	Serialize.save_game()

func _exit_tree() -> void:
	get_tree().paused = false

func _on_btn_revive_pressed() -> void:
	EventBus.player_revived.emit()
	Globals.state_manager.pop_overlay()

func _on_btn_menu_pressed() -> void:
	get_tree().paused = false
	Globals.state_manager.replace_state(StateDefs.MENU)
