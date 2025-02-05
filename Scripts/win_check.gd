"""
WinCheck
Call validate(selected) where selected is a 3 digit coordinate as a string (eg 231)
Returns a list of such strings if main.square_map shows those 4 boxes have values that sum to abs(cube_size)
"""

extends Node3D

@onready var main = get_parent()

var possible_wins: Array = []

func validate(selected):
	get_potential_wins(selected)
	get_cross_diagonal_wins(selected)
	return check_wins()


# Creates a list of all possible winstates the key could be in
func get_potential_wins(key):
	"""
	For each of the 3 dimensions, splits the cube into 4 planes
	The key will be in the same position on each plane, representing a cardinal win through the cube
	The key may be in either a forward or back diagonal across the plane
	A cord position is selected to represent the dimension
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
		for i in range(0,GlobalVars.cube_size):
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
							diagonal_assembly += str((GlobalVars.cube_size - 1) - i)
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
	elif int(local_cords[0]) + int(local_cords[1]) == GlobalVars.cube_size - 1:
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
		for i in range(0, GlobalVars.cube_size):
			cross_assembly = ""
			for j in range (0,3):
				cross_assembly += str(i)
			cross_list.append(cross_assembly)

	# Else, the differing position is incremented while the others are decremented
	# Eg 330, 221, 112, 003
	elif int(diff) == GlobalVars.cube_size - 1 - int(shared):
		for i in range(0, GlobalVars.cube_size):
			cross_assembly = ""
			for cord_pos in range(0,3):
				if cord_pos == diff_pos:
					cross_assembly += str(i)
				else:
					cross_assembly += str(GlobalVars.cube_size - 1 - i)
			cross_list.append(cross_assembly)

	# If cross list not empty, add to possible wins
	if len(cross_list) > 0:
		cross_list.append("cross")
		possible_wins.append(cross_list)


func check_wins():
	# Checks each row in list of possible wins
	for row in possible_wins:
		var counter = 0

		# Checks if there are 4 selected boxes in that row
		for tile_coord in row:
			if tile_coord in ["diag1", "diag2", "card", "cross"]:
				continue
			var tile = main.square_map[tile_coord]
			counter += tile.value
		if abs(counter) == GlobalVars.cube_size:
			return row
