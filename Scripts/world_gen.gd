"""
WorldGen
setup_game() is called at the end of start_game()
	- Builds the cube based on customizable size
	- Sets up cube and camera animations
show_win() is the final animation after a win
Both are called in main
"""

extends Node

var cube_size: int
var half_size: int

@onready var spotlight: SpotLight3D = $SpotLight3D
@onready var square_scene = preload("res://Scenes/square.tscn")
@onready var cube_anim_player: AnimationPlayer = $CubeAnimationPlayer
@onready var camera_anim_player: AnimationPlayer = $CameraAnimationPlayer
@onready var camera: Camera3D = $Camera3D
@onready var main: Node3D = $".."
@onready var audio_player: AudioStreamPlayer = $AudioStreamPlayer


func _ready():
	spotlight.position = Vector3(0,50,0)


# Called by main.start_game(), builds cube and playes starting animation
func setup_game():
	set_cube()
	set_camera()
	cube_anim_player.play("play_game")
	camera_anim_player.play("play_game")


# Creates the Node for the cube, each layer, and the squares.
func set_cube() -> void:

	# Set helper variables
	cube_size = GlobalVars.cube_size
	half_size = GlobalVars.cube_size/2

	# Creates Cube node and adds it to the tree
	var cube = Node3D.new()
	cube.name = "Cube"
	add_sibling(cube)
	var cube_node: Node3D = get_node("/root/Main/Cube") # Gets Cube node

	# For each layer, y, in cube_size
	for y in range(cube_size):

		# Create Layer
		var layer_assembly = Node3D.new() # Create a new node
		layer_assembly.name = "Layer" + str(y) # Sets layer name
		cube_node.add_child(layer_assembly) # Adds node as child of Cube
		var layer_node: Node3D = get_node("/root/Main/Cube/" + str(layer_assembly.name)) # Get Layer node

		# For each dimension, x
		for x in range(cube_size):
			# For each dimension, z
			for z in range(cube_size):

				# Create Square, and run configuration method
				var tile_assembly = square_scene.instantiate()
				layer_node.add_child(tile_assembly)
				tile_assembly.configure(x,y,z) # X, Y, Z represent position in cube

		# Set Animation Track for each layer
		set_layer_animation_track(y, layer_node)
	set_cube_animation_tracks()


# Called in set_cube, sets layer Animation Track
func set_layer_animation_track(y: int, node: Node3D) -> void:
	var cube_anim: Animation = cube_anim_player.get_animation("play_game") # Gets animation for Cube
	cube_anim.add_track(Animation.TYPE_POSITION_3D)
	cube_anim.track_set_path(y, str(node.get_path()))
	cube_anim.track_insert_key(y, 0, node.position)
	if y < half_size:
		# Negative X Position
		cube_anim.track_insert_key(y,2,Vector3(-(abs(y-half_size)*cube_size+abs(y-half_size)),0,0))
		cube_anim.track_insert_key(y,4,Vector3(-(abs(y-half_size)*cube_size+abs(y-half_size)),-y,0))
	else:
		# Positive X Position
		cube_anim.track_insert_key(y,2,Vector3((abs(y-half_size)*cube_size+abs(y-half_size)),0,0))
		cube_anim.track_insert_key(y,4,Vector3((abs(y-half_size)*cube_size+abs(y-half_size)),-y,0))


# Called in set_cube, sets cube animation tracks for rotation and game_win
func set_cube_animation_tracks() -> void:
	var cube_anim: Animation = cube_anim_player.get_animation("play_game")
	var cube_anim_game_win = cube_anim.duplicate()
	var cube_library: AnimationLibrary = cube_anim_player.get_animation_library("")
	cube_library.add_animation("game_win", cube_anim_game_win)
	var cube_rotation_anim: Animation = cube_anim_player.get_animation("rotate")
	cube_rotation_anim.add_track(2)
	cube_rotation_anim.track_set_path(0,"/root/Main/Cube")
	cube_rotation_anim.track_insert_key(0,0,Quaternion(Vector3(0,1,0),deg_to_rad(0)))
	cube_rotation_anim.track_insert_key(0,2.5,Quaternion(Vector3(0,1,0),deg_to_rad(180)))
	cube_rotation_anim.track_insert_key(0,5.0,Quaternion(Vector3(0,1,0),deg_to_rad(360)))


# Set camera starting position and animations
func set_camera() -> void:
	camera.position = Vector3(-(cube_size+2),cube_size+2,cube_size+2) # Set starting location for camera
	# Set animation track for play_game
	var camera_anim: Animation = camera_anim_player.get_animation("play_game")
	camera_anim.track_insert_key(0,0,camera.position)
	camera_anim.track_insert_key(0,2,Vector3(half_size-cube_size,cube_size+2,cube_size+3))
	if cube_size == 4:
		camera_anim.track_insert_key(0,4,Vector3(-(half_size+0.5),cube_size+half_size,0))
	elif cube_size == 6:
		camera_anim.track_insert_key(0,4,Vector3(-(half_size+0.5),cube_size*2,0))
	else:
		camera_anim.track_insert_key(0,4,Vector3(-(half_size+0.5),cube_size*2.5,0))
	# Duplicate play_game for game_win animation
	var camera_anim_game_win = camera_anim.duplicate()
	var library: AnimationLibrary = camera_anim_player.get_animation_library("")
	library.add_animation("game_win", camera_anim_game_win)
