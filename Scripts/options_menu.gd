extends VBoxContainer

@onready var cube_size_display_label: Label = $CubeSize/CubeSizeSelector/Label2
@onready var ai_toggle_button: Button = $AIToggle/Button
@onready var audio_player: AudioStreamPlayer = get_node("/root/Main/AudioStreamPlayer")


func _ready():
	cube_size_display_label.text = str(GlobalVars.cube_size)
	ai_toggle_button.text = str(GlobalVars.ai_toggle).capitalize()


func _on_cube_size_minus_button_pressed() -> void:
	audio_player.stream = load("res://Assets/Sounds/Minimalist11.wav")
	audio_player.play()
	if GlobalVars.cube_size > 4:
		GlobalVars.cube_size -= 2
		cube_size_display_label.text = str(GlobalVars.cube_size)


func _on_cube_size_plus_button_pressed() -> void:
	audio_player.stream = load("res://Assets/Sounds/Minimalist11.wav")
	audio_player.play()
	if GlobalVars.cube_size < 8:
		GlobalVars.cube_size += 2
		cube_size_display_label.text = str(GlobalVars.cube_size)


func _on_ai_toggle_button_pressed() -> void:
	audio_player.stream = load("res://Assets/Sounds/Minimalist11.wav")
	audio_player.play()
	GlobalVars.ai_toggle = not GlobalVars.ai_toggle
	ai_toggle_button.text = str(GlobalVars.ai_toggle).capitalize()
