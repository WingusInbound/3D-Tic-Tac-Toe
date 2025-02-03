extends Node3D

# Public
var value: int

# Private
var selected: bool = false
var main: Node3D

# On Ready
@onready var mesh: MeshInstance3D = $MeshInstance3D
@onready var anim_player: AnimationPlayer = $AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if is_inside_tree():
		main = get_node("/root/Main")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_area_3d_mouse_entered() -> void:
	if selected:
		return
	if main.game_state == GlobalVars.GameState.PLAY:
		mesh.material_override = main.current_player.color


func _on_area_3d_mouse_exited() -> void:
	if selected:
		return
	else:
		mesh.material_override = null


func _on_area_3d_input_event(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	if event.is_action_pressed("left_click"):
		if selected:
			return
		if main.game_state == GlobalVars.GameState.PLAY:
			mesh.material_override = main.current_player.color
			value = main.current_player.value
			Messenger.SELECTED.emit(self)
			selected = true
