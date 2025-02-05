extends Node3D

# Public

# Private
var square_map = {} # Tracks the state of the game as a dict
var current_turn: int # 0 or 1, toggles current player
var current_player: Player # Player object of current player, used to change per player settings
var players: Array # Used to contain and refer to Player objects
var winner # String representing the winning row of tiles

# On Ready
@onready var win_check: Node3D = $WinCheck
@onready var ui: UI = $UI_Canvas
@onready var ai_player: Node = $AI
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
		# AI Turn
		GlobalVars.game_state = GlobalVars.GameState.AI_TURN

		# TODO: AI will need to:
		# Read square_map and choose a move
		var key = ai_player.select_move(square_map)   ### TODO

		# Find the tile and pass the object to update_tile()
		var coords: Vector3 = ai_player.get_box_coords(key)
		update_tile(world_gen.locate_tile(coords))   ### TODO

		# Pass the key from square_map to process_turn()
		process_turn(key)

	else:
		# Setting game state to Player Turn enables selection of squares by human player
		# Selection is routed through _on_tile_selected and passed to process_turn()
		GlobalVars.game_state = GlobalVars.GameState.PLAYER_TURN


# Triggered when a box is clicked by a human player
func _on_tile_selected(tile):
	if GlobalVars.game_state != GlobalVars.GameState.PLAYER_TURN:
		return
	# Plays audio
	world_gen.audio_player.stream = load(current_player.sound_path)
	world_gen.audio_player.play()
	# Updates tile according to current player
	update_tile(tile)
	# Converts positional data to string and passes to process_turn()
	process_turn(tile.get_string_coords())


# Takes in a tile object and updates it according to current player
func update_tile(tile):
	tile.value = current_player.value
	tile.selected = true
	tile.update_color()


# Records move on square_map, and checks for wins
# If win_check.validate returns a value, the current player has won
func process_turn(key):
	GlobalVars.game_state = GlobalVars.GameState.VALIDATION
	# Record move on square_map
	var move = {key: current_player.value}
	square_map.merge(move,true)

	# Check for winner
	winner = win_check.validate(key)
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


# Called after "game_win" animation is finished playing
# Displays winning row, shrinks other squares and rotates the cube
func show_win():
	for key in square_map:
		if key in winner:
				continue
		else:
			var tile = square_map[key]
			if tile.value == 0:
				tile.anim_player.play("shrink")
			else:
				tile.anim_player.play("shrink_player")
	world_gen.cube_anim_player.play("rotate")
	world_gen.camera_anim_player.play("rotate")


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "play_game":
		game_manager()
	elif anim_name == "game_win":
		GlobalVars.game_state = GlobalVars.GameState.DONE
		show_win()
		ui.game_over()


class Player:
	var mesh: StandardMaterial3D
	var color: Color
	var value: int
	var sound_path: String
