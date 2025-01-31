extends Node

@onready var layer_one = $LayerOne
@onready var layer_two = $LayerTwo
@onready var layer_three = $LayerThree
@onready var layer_four = $LayerFour


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	layer_one.move(-8,1)
	layer_two.move(-3,1)
	layer_three.move(3,1)
	layer_four.move(8,1)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
