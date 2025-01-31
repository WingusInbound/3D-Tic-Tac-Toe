extends Node

@onready var layer_one = $LayerOne
@onready var layer_two = $LayerTwo
@onready var layer_three = $LayerThree
@onready var layer_four = $LayerFour
@onready var anim_player = $AnimationPlayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#layer_one.move(-8,1)
	#layer_two.move(-3,1)
	#layer_three.move(3,1)
	#layer_four.move(8,1)
	anim_player.play("layer_four_anim")
	
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
