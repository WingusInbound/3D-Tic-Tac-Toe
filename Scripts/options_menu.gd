extends VBoxContainer

@onready var cube_size_display_label: Label = $CubeSize/HBoxContainer/Label2


func _ready():
	cube_size_display_label.text = str(GlobalVars.cube_size)


func _on_cube_size_minus_button_pressed() -> void:
	if GlobalVars.cube_size > 4:
		GlobalVars.cube_size -= 2
		cube_size_display_label.text = str(GlobalVars.cube_size)


func _on_cube_size_plus_button_pressed() -> void:
	if GlobalVars.cube_size < 10:
		GlobalVars.cube_size += 2
		cube_size_display_label.text = str(GlobalVars.cube_size)
