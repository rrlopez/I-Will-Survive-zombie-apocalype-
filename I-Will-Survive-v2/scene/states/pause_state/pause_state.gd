class_name PauseState extends Control
## PauseState — overlay. Owns the paused state — always restores on exit.

func _enter_tree() -> void:
	get_tree().paused = true

func _exit_tree() -> void:
	get_tree().paused = false

func _on_btn_resume_pressed() -> void:
	Globals.state_manager.pop_overlay()

func _on_btn_quit_pressed() -> void:
	get_tree().paused = false   # must unpause before replace_state
	Globals.state_manager.replace_state(StateDefs.MENU)
