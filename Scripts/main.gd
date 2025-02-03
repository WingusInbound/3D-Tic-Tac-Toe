extends Node3D

# Public
var game_state: int = GlobalVars.GameState.START
var current_player: Player

# Private
var square_map = {}
var current_turn: int
var players: Array
var winner
var cube_size: int
var half_size: int

# On Ready
@onready var layer_one = $LayerOne
@onready var layer_two = $LayerTwo
@onready var layer_three = $LayerThree
@onready var layer_four = $LayerFour
@onready var layers = [layer_one, layer_two, layer_three, layer_four]
@onready var win_check: Node3D = $WinCheck
@onready var ui: UI = $UI_Canvas
@onready var square = preload("res://Scenes/square.tscn")
@onready var cube_anim_player: AnimationPlayer = $CubeAnimationPlayer
@onready var camera_anim_player: AnimationPlayer = $CameraAnimationPlayer
@onready var camera: Camera3D = $Camera3D
@onready var spotlight: SpotLight3D = $SpotLight3D
@onready var audio_player: AudioStreamPlayer = $AudioStreamPlayer
@onready var ai_player: Node = $Ai




# Called when the node enters the scene tree for the first time.
func _ready() -> void:

	var _connections = Messenger.SELECTED.connect(_on_tile_selected)
	var player_one: Player = Player.new()
	player_one.mesh = preload("res://Assets/player_one_square.tres")
	player_one.sound_path = "res://Assets/Sounds/Retro11.wav"
	player_one.value = 1
	var player_two: Player = Player.new()
	player_two.mesh = preload("res://Assets/player_two_square.tres")
	player_two.sound_path = "res://Assets/Sounds/Retro12.wav"
	player_two.value = -1
	players = [player_one, player_two]
	set_spotlight()
	ui.main_menu()


# Runs every physics frame
func _process(_delta) -> void:
	if Input.is_action_just_pressed("pause") and game_state == GlobalVars.GameState.PLAYER_TURN:
		ui.toggle_pause()


# Game Manager
func game_manager():
	pass


# Called during Ready, chooses and sets starting player
func start_game():
	for i in layers:
		i.visible = false
	current_turn = randi_range(0, 1)
	current_player = players[current_turn]
	cube_anim_player.play("play_game")
	camera_anim_player.play("play_game")
	cube_size = GlobalVars.cube_size
	half_size = GlobalVars.cube_size/2
	players[0].color = GlobalVars.player_one_color
	players[1].color = GlobalVars.player_two_color
	set_cube()
	set_camera()


# Called during Ready, updates spotlight location
func set_spotlight() -> void:
	spotlight.position = Vector3(0,50,0)


# Called during Ready, creates the Node for the cube, each layer, and the squares.
func set_cube() -> void:
	# Creates Cube node and adds it to the tree
	var cube = Node3D.new()
	cube.name = "Cube"
	add_child(cube)
	var cube_node: Node3D = get_node("/root/Main/Cube") # Gets Cube node
	# For each layer, y, in cube_size
	for y in range(cube_size):
		var temp_layer = Node3D.new() # Create a new node
		temp_layer.name = "Layer" + str(y) # Sets layer name
		cube_node.add_child(temp_layer) # Adds node as child of Cube
		var layer_node: Node3D = get_node("/root/Main/Cube/" + str(temp_layer.name)) # Get Layer node
		# For each dimension, x
		for x in range(cube_size):
			# For each dimension, z
			for z in range(cube_size):
				var temp_square = square.instantiate()
				temp_square.name = "Square" + str(x*cube_size+z) # Names square node
				layer_node.add_child(temp_square)
				temp_square.global_position = Vector3(x-half_size,y,z-half_size)
				var temp_key = get_string_coords(temp_square.position)
				square_map.get_or_add(temp_key,temp_square.value)
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


# Called in Ready, set camera starting position and animations
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


# Triggered when a box is clicked
# Collects data from selected box and calls for applicable changes
func _on_tile_selected(square):
	if game_state != GlobalVars.GameState.PLAYER_TURN:
		return
	audio_player.stream = load(current_player.sound_path)
	audio_player.play()
	var key = get_string_coords(square.position)
	var move = {key: square.value}
	square_map.merge(move,true)
	turn(key)


# Determines if the selected box results in a win
# Otherwise, toggle current player
func turn(key):
	winner = win_check.validate(key)
	if winner:
		game_state = GlobalVars.GameState.ENDING
		if current_turn == 0:
			print("Player 1 Wins!")
		else:
			print("Player 2 Wins")
		cube_anim_player.play_backwards("game_win")
		camera_anim_player.play_backwards("game_win")
	else:
		current_turn = (current_turn + 1) % 2
		current_player = players[current_turn]


func show_win():
	var cube_node: Node3D = get_node("/root/Main/Cube")
	var layers = cube_node.get_children()
	for i in layers:
		var children = i.get_children()
		for child in children:
			var temp_key = get_string_coords(child.position)
			if str(temp_key) in winner:
				continue
			else:
				if child.value == 0:
					child.anim_player.play("shrink")
				else:
					child.anim_player.play("shrink_player")
	cube_anim_player.play("rotate")
	camera_anim_player.play("rotate")
	game_state = GlobalVars.GameState.DONE
	ui.game_over()


# Returns positional cordinates of a box as a 3 digit string
func get_string_coords(coords: Vector3) -> String:
	var temp_string: String = ""
	temp_string += str(coords.x + half_size)
	temp_string += str(coords.y)
	temp_string += str(coords.z + half_size)
	return temp_string


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "game_win":
		show_win()
	elif anim_name == "play_game":
		game_state = GlobalVars.GameState.PLAYER_TURN


class Player:
	var mesh: StandardMaterial3D
	var color: Color
	var value: int
	var sound_path: String
