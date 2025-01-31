extends Node3D


func move(x: int, y: int):
	var squares = self.get_children()
	for i in range(squares.size()):
		squares[i].position.x += x
		squares[i].position.y += y
