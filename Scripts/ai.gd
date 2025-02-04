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

func select_move(map) -> String:
	var selection = map.keys()[randi() % map.size]
	return selection.key


# Takes in a 3 digit string and returns Vector3 coordinates
func get_box_coords(key) -> Vector3:
	var temp_vector: Vector3
	temp_vector.x = int(key[0]) - (GlobalVars.cube_size / 2)
	temp_vector.y = int(key[1])
	temp_vector.z = int(key[2]) - (GlobalVars.cube_size / 2)
	return temp_vector
