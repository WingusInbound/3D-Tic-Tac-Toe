extends Node3D

@onready var mesh: MeshInstance3D = $MeshInstance3D

@export var highlight_color: Color
@export var color: Color

var selected: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_area_3d_mouse_entered() -> void:
	mesh.material_override.albedo_color = highlight_color


func _on_area_3d_mouse_exited() -> void:
	if selected:
		return
	else:
		mesh.material_override.albedo_color = color


func _on_area_3d_input_event(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	if event.is_action_pressed("left_click"):
		print("Left Clicked")
		mesh.material_override.albedo_color = highlight_color
		selected = true
