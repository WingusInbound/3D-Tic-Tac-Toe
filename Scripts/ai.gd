extends Node3D

# read board
# decide on turn
# submit to turn function

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func select_move(map, weights) -> Object:
	# Make helper vars
	var highest_list: Array = []
	var highest_val: int = 0

	# Iterate through weight_map, making a list of the highest values
	for square in weights:
		if weights[square] == highest_val:
			highest_list.append(square)
		if weights[square] > highest_val:
			highest_val = weights[square]
			highest_list.clear()
			highest_list.append(square)

	# Pick a random key from among highest weights
	var list_len = len(highest_list)
	var move_key = highest_list[randi_range(0, list_len - 1)]
	return map[move_key]

func get_moves(map: Dictionary) -> Dictionary:
	var map_copy = map.duplicate()
	for tile in map_copy:
		if tile.value != 0:
			map_copy.erase(tile.key)
	return map_copy

	
