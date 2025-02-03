extends Node3D

# Public

# Private
var square_map = {}
var current_turn: int
var current_player: Player
var players: Array
var winner

# On Ready
@onready var win_check: Node3D = $WinCheck
@onready var ui: UI = $UI_Canvas
@onready var ai_player: Node = $Ai
@onready var world_gen: Node = $WorldGen


# Called when the node enters the scene tree for the first time.
func _ready() -> void:

	# Set Connections
	var _connections = Messenger.SELECTED.connect(_on_tile_selected)

	# Create Player Objects and store in array
	var player_one: Player = Player.new()
	player_one.mesh = preload("res://Assets/player_one_square.tres")
	player_one.sound_path = "res://Assets/Sounds/Retro11.wav"
	player_one.value = 1
	var player_two: Player = Player.new()
	player_two.mesh = preload("res://Assets/player_two_square.tres")
	player_two.sound_path = "res://Assets/Sounds/Retro12.wav"
	player_two.value = -1
	players = [player_one, player_two]

	GlobalVars.game_state = GlobalVars.GameState.MAIN_MENU
	ui.main_menu()
	# Player leaving main menu triggers start_game() via _on_animation_player_animation_finished


# Runs every physics frame
func _process(_delta) -> void:
	if Input.is_action_just_pressed("pause") and GlobalVars.game_state == GlobalVars.GameState.PLAYER_TURN:
		ui.toggle_pause()


# Game Manager
func game_manager():
	pass


# Called during Ready, chooses and sets starting player
func start_game():
	$DemoCube.visible = false # Hide demo cube
	current_turn = randi_range(0, 1) # Choose random starting player
	current_player = players[current_turn] # Set starting player
	players[0].color = GlobalVars.player_one_color
	players[1].color = GlobalVars.player_two_color
	world_gen.setup_game()


# Triggered when a box is clicked
# Collects data from selected box and calls for applicable changes
func _on_tile_selected(square):
	if GlobalVars.game_state != GlobalVars.GameState.PLAYER_TURN:
		return
	world_gen.audio_player.stream = load(current_player.sound_path)
	world_gen.audio_player.play()
	var key = get_string_coords(square.position)
	var move = {key: square.value}
	square_map.merge(move,true)
	turn(key)


# Determines if the selected box results in a win
# Otherwise, toggle current player
func turn(key):
	winner = win_check.validate(key)
	if winner:
		GlobalVars.game_state = GlobalVars.GameState.ENDING
		if current_turn == 0:
			print("Player 1 Wins!")
		else:
			print("Player 2 Wins")
		world_gen.cube_anim_player.play_backwards("game_win")
		world_gen.camera_anim_player.play_backwards("game_win")
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
	world_gen.cube_anim_player.play("rotate")
	world_gen.camera_anim_player.play("rotate")
	GlobalVars.game_state = GlobalVars.GameState.DONE
	ui.game_over()


# Returns positional cordinates of a box as a 3 digit string
func get_string_coords(coords: Vector3) -> String:
	var temp_string: String = ""
	temp_string += str(coords.x + (GlobalVars.cube_size / 2))
	temp_string += str(coords.y)
	temp_string += str(coords.z + (GlobalVars.cube_size / 2))
	return temp_string


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "game_win":
		show_win()
	elif anim_name == "play_game":
		GlobalVars.game_state = GlobalVars.GameState.PLAYER_TURN


class Player:
	var mesh: StandardMaterial3D
	var color: Color
	var value: int
	var sound_path: String
