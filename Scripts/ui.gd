class_name UI
extends CanvasLayer

# Public

# Private
var paused: bool = false

@onready var main = get_parent()
@onready var start_menu: VBoxContainer = $UI/StartMenu
@onready var options_menu: VBoxContainer = $UI/OptionsMenu
@onready var player_one: ColorPickerButton = $UI/OptionsMenu/Player1Color/ColorPickerButton
@onready var player_two: ColorPickerButton = $UI/OptionsMenu/Player2Color/ColorPickerButton
@onready var pause_menu: VBoxContainer = $UI/PauseMenu
@onready var end_menu: VBoxContainer = $UI/EndMenu
@onready var audio_player: AudioStreamPlayer = get_node("/root/Main/AudioStreamPlayer")


func main_menu() -> void:
	start_menu.visible = true
	options_menu.visible = false
	pause_menu.visible = false
	end_menu.visible = false
	player_one.color = GlobalVars.player_one_color
	player_two.color = GlobalVars.player_two_color
	


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
	audio_player.stream = load("res://Assets/Sounds/Minimalist11.wav")
	audio_player.play()
	await audio_player.finished
	get_tree().quit()


func _on_start_button_pressed() -> void:
	start_menu.visible = false
	end_menu.visible = false
	audio_player.stream = load("res://Assets/Sounds/Minimalist11.wav")
	audio_player.play()
	main.start_game()


func _on_resume_button_pressed() -> void:
	audio_player.stream = load("res://Assets/Sounds/Minimalist11.wav")
	audio_player.play()
	toggle_pause()


func _on_restart_button_pressed() -> void:
	audio_player.stream = load("res://Assets/Sounds/Minimalist11.wav")
	audio_player.play()
	await audio_player.finished
	get_tree().reload_current_scene()


func _on_options_pressed() -> void:
	audio_player.stream = load("res://Assets/Sounds/Minimalist11.wav")
	audio_player.play()
	start_menu.visible = false
	options_menu.visible = true


func _on_options_resume_button_pressed() -> void:
	audio_player.stream = load("res://Assets/Sounds/Minimalist11.wav")
	audio_player.play()
	GlobalVars.player_one_color = player_one.color
	GlobalVars.player_two_color = player_two.color
	start_menu.visible = true
	options_menu.visible = false
