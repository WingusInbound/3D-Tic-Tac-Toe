extends Node3D

@export var player_color: Color
@export var ai_color: Color

# Public
var game_state: int = GlobalVars.GameState.START
var current_player: Player

# Private
var square_map = {}
var current_turn: int
var players: Array
var winner

# On Ready
#@onready var layer_one = $LayerOne
#@onready var layer_two = $LayerTwo
#@onready var layer_three = $LayerThree
#@onready var layer_four = $LayerFour
#@onready var layers = [layer_one, layer_two, layer_three, layer_four]
#@onready var cube_anim_player = $AnimationPlayer
@onready var win_check: Node3D = $WinCheck
@onready var ui: UI = $UI_Canvas
@onready var cube_anim_player: AnimationPlayer = $CubeAnimationPlayer
@onready var camera_anim_player: AnimationPlayer = $CameraAnimationPlayer
@onready var camera: Camera3D = $Camera3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var _connections = Messenger.SELECTED.connect(_on_tile_selected)
	var player_one: Player = Player.new()
	player_one.color = preload("res://Assets/player_one_square.tres")
	player_one.value = 1
	var player_two: Player = Player.new()
	player_two.color = preload("res://Assets/player_two_square.tres")
	player_two.value = -1
	players = [player_one, player_two]
	ui.main_menu()


# Called during Ready, chooses and sets starting player
func start_game():
	current_turn = randi_range(0, 1)
	current_player = players[current_turn]
	cube_anim_player.play("play_game")
	camera_anim_player.play("play_game")
	

func _process(_delta) -> void:
	if Input.is_action_just_pressed("pause") and game_state == GlobalVars.GameState.PLAY:
		ui.toggle_pause()


# Triggered when a box is clicked
# Collects data from selected box and calls for applicable changes
func _on_tile_selected(square):
	if game_state != GlobalVars.GameState.PLAY:
		return
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
	winner = win_check.validate(key)
	if winner:
		game_state = GlobalVars.GameState.ENDING
		if current_turn == 0:
			print("Player 1 Wins!")
		else:
			print("Player 2 Wins")
		anim_player.play_backwards("game_win")
	else:
		current_turn = (current_turn + 1) % 2
		current_player = players[current_turn]


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
	game_state = GlobalVars.GameState.DONE
	ui.game_over()


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "game_win":
		show_win()
	elif anim_name == "play_game":
		game_state = GlobalVars.GameState.PLAY


class Player:
	var color: StandardMaterial3D
	var value: int
