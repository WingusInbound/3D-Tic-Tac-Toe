extends Node

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
