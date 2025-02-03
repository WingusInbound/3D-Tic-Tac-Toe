class_name UI
extends CanvasLayer

# Public

# Private
var paused: bool = false

@onready var main = get_parent()
@onready var start_menu: VBoxContainer = $UI/StartMenu
@onready var pause_menu: VBoxContainer = $UI/PauseMenu
@onready var end_menu: VBoxContainer = $UI/EndMenu


func main_menu() -> void:
	start_menu.visible = true


func toggle_pause() -> void:
	if not paused:
		Engine.time_scale = 0
		pause_menu.visible = true
	else:
		Engine.time_scale = 1
		pause_menu.visible = false
	paused = !paused


func game_over() -> void:
	end_menu.visible = true


func _on_quit_button_pressed() -> void:
	get_tree().quit()


func _on_start_button_pressed() -> void:
	start_menu.visible = false
	end_menu.visible = false
	main.start_game()


func _on_resume_button_pressed() -> void:
	toggle_pause()


func _on_restart_button_pressed() -> void:
	get_tree().reload_current_scene()


func _on_options_pressed() -> void:
	pass # Replace with function body.
