extends Node3D

enum {PLAYER_ONE, PLAYER_TWO}
enum GameState {START, PLAY, END}

const CUBE_SIZE: int = 4

@export var player_color: Color
@export var ai_color: Color

# Public
var game_state: int = GameState.START
var current_player: Player

# Private
var square_map = {}
var possible_wins: Array = []
var current_turn: int
var players: Array
var winner

@onready var layer_one = $LayerOne
@onready var layer_two = $LayerTwo
@onready var layer_three = $LayerThree
@onready var layer_four = $LayerFour
@onready var anim_player = $AnimationPlayer
@onready var layers = [layer_one, layer_two, layer_three, layer_four]


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var _connections = Messenger.SELECTED.connect(tile_selected)
	var player_one: Player = Player.new()
	player_one.color = preload("res://Assets/player_one_square.tres")
	player_one.value = 1
	var player_two: Player = Player.new()
	player_two.color = preload("res://Assets/player_two_square.tres")
	player_two.value = -1
	players = [player_one, player_two]
	set_square_map()
	start_game()


# Called during Ready, sets up map of cube
func set_square_map():
	for i in layers:
		var children = i.get_children()
		for child in children:
			var key = get_string_coords(child.position)
			square_map.get_or_add(key, child.value)


# Called during Ready, chooses and sets starting player
func start_game():
	current_turn = randi_range(0, 1)
	current_player = players[current_turn]


# Unpacks cube when Spacebar pushed
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("spacebar"):
		if game_state == GameState.START:
			anim_player.play("play_game")
			game_state = GameState.PLAY

		elif game_state == GameState.END:
			get_tree().reload_current_scene()


# Triggered when a box is clicked
# Collects data from selected box and calls for applicable changes
func tile_selected(square):
	var key = get_string_coords(square.position)
	var move = {key: square.value}
	square_map.merge(move,true)
	turn(key)


# Returns positional cordinates of a box as a 3 digit string
func get_string_coords(coords: Vector3) -> String:
	var temp_string: String = ""
	temp_string += str(coords.x + 2)
	temp_string += str(coords.y)
	temp_string += str(coords.z + 2)
	return temp_string


# Determines if the selected box results in a win
# Otherwise, toggle current player
func turn(key):
	print("Key: ", key)
	possible_wins = []
	get_potential_wins(key)
	get_cross_diagonal_wins(key)
	winner = check_wins()
	if winner:
		if current_turn == 0:
			print("Player 1 Wins!")
		else:
			print("Player 2 Wins")
		anim_player.play_backwards("game_win")
	else:
		current_turn = (current_turn + 1) % 2
		current_player = players[current_turn]


# Creates a list of all possible winstates the key could be in
func get_potential_wins(key):
	"""
	For each of the 3 dimensions, splits the cube into 4 planes
	The key will be in the same position on each plane, representing a cardinal win through the cube
	The key may be in either a forward or back diagonal across the plane
	A cord position is selected to represet the dimension
	For cardinal wins that position is incremented to represent each plane
	For diagonal wins that position is locked to check diags across that plane
	"""

	var cardinal_assembly: String # Assemblies used in finding neighboring boxes when checking wins
	var diagonal_assembly: String
	var diag_type: int # 0 = none, 1 = forward, 2 = back
	var diag_toggle: int = 0 # Used to find the second altered digit on the back diag
	var card_list: Array = [] # Lists representing a group of 4 neighboring boxes
	var diag_list: Array = []

	# Marks which cord position represents the relative dimension
	for dimension in range(0,3):
		diag_toggle = 0
		card_list = []
		diag_list = []
		# Checks if key is part of a diagonal on this plane
		diag_type = get_diag_type(dimension, key)

		# Iterates through each possible postional value
		for i in range(0,CUBE_SIZE):
			cardinal_assembly = ""
			diagonal_assembly = ""

			# Represents each position on the cord
			for cord_digit in range(0,3):

				# If cord position relates to relative dimension
				if cord_digit == dimension:
					# Cardinal uses i to represent the plane number
					cardinal_assembly += str(i)
					# Diagonal copies the key value for that position
					diagonal_assembly += key[cord_digit]

				else:
					# Cardinal copies the key value for that position
					cardinal_assembly += key[cord_digit]
					# Forward diag
					if diag_type == 1:
						diagonal_assembly += str(i)
					# Back diag
					elif diag_type == 2:
						# First modified digit set to i
						if diag_toggle == 0:
							diagonal_assembly += str(i)
							diag_toggle += 1
						# Second digit set to max value - i
						else:
							diagonal_assembly += str((CUBE_SIZE - 1) - i)
							diag_toggle -= 1

			# Add cords to rows
			card_list.append(cardinal_assembly)
			if diag_type != 0:
				diag_list.append(diagonal_assembly)
		# Add rows to list of possible wins
		card_list.append("card")
		possible_wins.append(card_list)
		if len(diag_list) > 0:
			diag_list.append("diag" + str(diag_type))
			possible_wins.append(diag_list)


func get_diag_type(dimension, key):
	"""
	Removes dimentional position from cord to determine if key is part of
	forward diag (remaining numbers are equal) or
	back diag (remaining numbers sum to max cube value - 1)
	"""
	# Removes dimension from cord to compare remaining digits
	var local_cords: String = ""
	for cord_pos in range(0,3):
		# If cord_pos does not represent the dimension being checked
		if cord_pos != dimension:
			# Add the value from key in that position
			local_cords += key[cord_pos]
	if int(local_cords[0]) == int(local_cords[1]):
		return 1 # Forward diag
	elif int(local_cords[0]) + int(local_cords[1]) == CUBE_SIZE - 1:
		return 2 # Back diag
	else:
		return 0 # No diag on current plane


func get_cross_diagonal_wins(key):
	"""
	Cross diagonals observe the following pattern:
		The cords are either all the same (333)
		or there are 2 shared numbers and one different number X
		where X equals the max value minus the shared value (221, if cube size is 4)
	"""
	var shared: String = ""
	var diff: String = ""
	var diff_pos: int = -1
	var cross_assembly: String
	var cross_list: Array = []

	# Determines which number is different, and the position in the cord
	for cord_pos in range(0,3):
		if shared == "":
			shared = key[cord_pos]
		if key[cord_pos] == diff:
			diff = shared
			diff_pos = 0
			shared = key[cord_pos]
		if key[cord_pos] != shared:
			diff = key[cord_pos]
			diff_pos = cord_pos

	# If all numbers the same (no diff), cross is 000, 111, 222, 333
	if diff == "":
		for i in range(0, CUBE_SIZE):
			cross_assembly = ""
			for j in range (0,3):
				cross_assembly += str(i)
			cross_list.append(cross_assembly)

	# Else, the differing position is incremented while the others are decremented
	# Eg 330, 221, 112, 003
	elif int(diff) == CUBE_SIZE - 1 - int(shared):
		for i in range(0, CUBE_SIZE):
			cross_assembly = ""
			for cord_pos in range(0,3):
				if cord_pos == diff_pos:
					cross_assembly += str(i)
				else:
					cross_assembly += str(CUBE_SIZE - 1 - i)
			cross_list.append(cross_assembly)

	# If cross list not empty, add to possible wins
	if len(cross_list) > 0:
		cross_list.append("cross")
		possible_wins.append(cross_list)


func check_wins():
	# Checks each row in list of possible wins
	for row in possible_wins:
		#print("Row: ", row)
		var counter = 0

		# Checks if there are 4 selected boxes in that row
		for cord in row:
			if cord in ["diag1", "diag2", "card", "cross"]:
				continue
			counter += square_map[cord]
		if abs(counter) == 4:
			#print("WIN")
			return row


func show_win():
	#print(winner)
	for i in layers:
		var children = i.get_children()
		for child in children:
			#print(child.position)
			var temp_key = get_string_coords(child.position)
			#print(temp_key)
			if str(temp_key) in winner:
				continue
			else:
				if child.value == 0:
					child.anim_player.play("shrink")
				else:
					child.anim_player.play("shrink_player")
	anim_player.play("rotate")


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "game_win":
		game_state = GameState.END
		show_win()


class Player:
	var color: StandardMaterial3D
	var value: int
