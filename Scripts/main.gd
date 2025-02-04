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
@onready var world_gen: Node3D = $WorldGen


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
	# Player leaving main menu triggers start_game() via _on_start_button_pressed()


# Runs every physics frame
func _process(_delta) -> void:
	if Input.is_action_just_pressed("pause") and GlobalVars.game_state == GlobalVars.GameState.PLAYER_TURN:
		ui.toggle_pause()


# Called during Ready, chooses and sets starting player
func start_game():
	GlobalVars.game_state = GlobalVars.GameState.SETUP
	$DemoCube.visible = false # Hide demo cube
	current_turn = randi_range(0, 1) # Choose random starting player
	current_player = players[current_turn] # Set starting player
	players[0].color = GlobalVars.player_one_color
	players[1].color = GlobalVars.player_two_color
	world_gen.setup_game()
	# Animation after setup triggers game_manager() via _on_animation_player_animation_finished


# Initiates Primary Game Loop
func game_manager():

	if current_turn == 1 and GlobalVars.ai_toggle:
		GlobalVars.game_state = GlobalVars.GameState.AI_TURN

		# TODO: AI Stuff
		# Call record_move(), passing a square object representing AI move

	else:
		# Setting game state to Player Turn enables selection of squares by human player
		# Selection is routed through _on_tile_selected and passed to record_move()
		GlobalVars.game_state = GlobalVars.GameState.PLAYER_TURN


# Triggered when a box is clicked by a human player
# Plays audio and passes data to record_move()
func _on_tile_selected(tile):
	if GlobalVars.game_state != GlobalVars.GameState.PLAYER_TURN:
		return
	world_gen.audio_player.stream = load(current_player.sound_path)
	world_gen.audio_player.play()
	record_move(tile)


# Converts square object coordinants, records that move on square_map
# and passes coords to check_wins()
func record_move(square):
	GlobalVars.game_state = GlobalVars.GameState.VALIDATION
	var key = get_string_coords(square.position)
	var move = {key: square.value}
	square_map.merge(move,true)
	check_wins(key)


# Runs choosen coords through WinCheck, if there is a return value, the current player has won
func check_wins(coord):
	winner = win_check.validate(coord)
	if winner:
		GlobalVars.game_state = GlobalVars.GameState.ENDING
		if current_turn == 0:
			print("Player 1 Wins!")
		else:
			print("Player 2 Wins")
		world_gen.cube_anim_player.play_backwards("game_win")
		world_gen.camera_anim_player.play_backwards("game_win")
		# show_win() triggered after animation via _on_animation_player_animation_finished()

	# If no winner, switch player and restart game loop
	else:
		current_turn = (current_turn + 1) % 2
		current_player = players[current_turn]
		game_manager()


# Returns positional cordinates of a box as a 3 digit string
func get_string_coords(coords: Vector3) -> String:
	var temp_string: String = ""
	temp_string += str(coords.x + (GlobalVars.cube_size / 2))
	temp_string += str(coords.y)
	temp_string += str(coords.z + (GlobalVars.cube_size / 2))
	return temp_string


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "game_win":
		world_gen.show_win()
		ui.game_over()
	elif anim_name == "play_game":
		game_manager()


class Player:
	var mesh: StandardMaterial3D
	var color: Color
	var value: int
	var sound_path: String
