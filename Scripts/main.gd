extends Node3D

enum {PLAYER_ONE, PLAYER_TWO}  

@onready var layer_one = $LayerOne
@onready var layer_two = $LayerTwo
@onready var layer_three = $LayerThree
@onready var layer_four = $LayerFour
@onready var anim_player = $AnimationPlayer 
@onready var layers = [layer_one, layer_two, layer_three, layer_four]

@export var player_color: Color
@export var ai_color: Color

var square_map = {}
var possible_wins: Array = []
var current_turn: int
var current_player: Player
var players: Array
var winner
var game_over = false

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
	set_square_map(layers)
	start_game()

func start_game():
	# Play animation
	# Set current turn
	# Set current player
	current_turn = randi_range(0, 1) 
	current_player = players[current_turn]

func turn(key):
	current_turn = (current_turn + 1) % 2
	current_player = players[current_turn]
	get_potential_wins(key)
	winner = check_wins(possible_wins)
	if winner:
		if current_turn == 1:
			print("Player 1 Wins!")
		else:
			print("Player 2 Wins")
		game_over = true
		anim_player.play_backwards("game_win")
			

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("spacebar"):
		anim_player.play("play_game")


func set_square_map(layers):
	for i in layers:
		var children = i.get_children()
		for child in children:
			var key = get_string_coords(child.position)
			square_map.get_or_add(key, child.value)
	
	
func tile_selected(square):
	var key = get_string_coords(square.position)
	var move = {key: square.value}
	square_map.merge(move,true)
	turn(key)


func get_string_coords(coords: Vector3) -> String:
	var temp_string: String = ""
	temp_string += str(coords.x + 2)
	temp_string += str(coords.y)
	temp_string += str(coords.z + 2)
	return temp_string


func get_potential_wins(key):
	possible_wins = []
	get_cardinal_wins(key)
	#temp_array.append_array(get_diagonal_wins())
	#temp_array.append_array(get_weird_diagonal_wins())
	

func get_cardinal_wins(key):
	for plane in range(0,3):
		var box_cord: String
		var row_list: Array = []

		# Each of the 4 possible values
		for i in range(0,4):
			box_cord = ""

			# Represents each position on the cord
			for cord_digit in range(0,3):
				# If the position is the one being modified, use i
				if cord_digit == plane:
					box_cord += str(i)
				# Otherwise, use value from original clicked box
				else:
					box_cord += str(key[cord_digit])

			# Add cord to row
			row_list.append(box_cord)
		# Add row to list of possible wins
		possible_wins.append(row_list)
	#print(possible_wins)
	
	
func check_wins(wins):
	# Checks each row in list of possible wins
	for row in wins:
		var counter = 0

		# Checks if there are 4 selected boxes in that row
		for cord in row:
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
			

class Player: 
	var color: StandardMaterial3D
	var value: int


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "game_win":
		show_win()
