extends Node3D

# Public
var value: int # -1 = Player Two selected, 1 = Player One selected
var key: String # Positional coordinate as a string ie 230
var weight: int # How highly the AI should prioritize this tile
var selected: bool = false

# Private
var main: Node3D

# On Ready
@onready var mesh: MeshInstance3D = $MeshInstance3D
@onready var anim_player: AnimationPlayer = $AnimationPlayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if is_inside_tree():
		main = get_node("/root/Main")
	pass # Replace with function body.


func configure(x,y,z) -> void:
	self.name = "Square" + str(x*GlobalVars.cube_size+z) # Names square node
	self.global_position = Vector3(x-(GlobalVars.cube_size / 2),y,z-(GlobalVars.cube_size / 2))
	self.key = str(x) + str(y) + str(z)
	main.square_map.get_or_add(self.key,self)
	calculate_starting_weight()


func calculate_starting_weight():
	# Uses key to determine if tile is on a corner, edge, flat, etc
	# Applies a value to weight
	pass


func _on_area_3d_mouse_entered() -> void:
	if selected:
		return
	if GlobalVars.game_state == GlobalVars.GameState.PLAYER_TURN:
		update_color()


func _on_area_3d_mouse_exited() -> void:
	if selected:
		return
	else:
		mesh.material_override = null


func _on_area_3d_input_event(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	if event.is_action_pressed("left_click"):
		if selected:
			return
		if GlobalVars.game_state == GlobalVars.GameState.PLAYER_TURN:
			Messenger.SELECTED.emit(self)


# Used to update the color of a square according to current player
func update_color():
	mesh.material_override = main.current_player.mesh
	mesh.material_override.albedo_color = main.current_player.color


# Returns positional cordinates of a box as a 3 digit string
func get_string_coords() -> String:
	var temp_string: String = ""
	temp_string += str(position.x + (GlobalVars.cube_size / 2))
	temp_string += str(position.y)
	temp_string += str(position.z + (GlobalVars.cube_size / 2))
	return temp_string
