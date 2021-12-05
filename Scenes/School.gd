extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var rand = RandomNumberGenerator.new()
enum {CLASSROOM, HALLWAY, CAFETERIA, PLAYGROUND, GARDEN}
onready var pawn = get_node("Pawn")
onready var character = get_node("Character")
onready var label = get_node("CanvasLayer/Control/VBoxContainer/Label")
enum {PLAYERTURN, PLAYERMOVE, ENEMYTURN, ENEMYMOVE}
enum {GOLEFT, GORIGHT, GOUP, GODOWN}
const CORNERS = {TOPLEFT=[0, 0], TOPRIGHT=[9,0], BOTLEFT=[0,9], BOTRIGHT=[9,9]}
var direction = GORIGHT
var state = PLAYERTURN
var map = []
# Called when the node enters the scene tree for the first time.
func _ready():
	var time = OS.get_time()
	# Seed for random function
	var time_seed = time.hour + time.minute + time.second
	rand.set_seed(time_seed)
	var classroom = preload("res://Prefabs/Classroom.tscn")
	var hallway = preload("res://Prefabs/Hallway.tscn")
	var playground = preload("res://Prefabs/Playground.tscn")
	var cafeteria = preload("res://Prefabs/Cafeteria.tscn")
	var garden = preload("res://Prefabs/Garden.tscn")
	var rooms = [classroom, hallway, cafeteria, playground, garden]
	var map = fill_map(rooms, 10)
	set_room_positions(map)

# Purpose: Create a 2d array with predefined rooms
# Paramaters: Array of rooms, size of nxn map
# Return: 2D array containing the game map
func fill_map(rooms, size):
	var playgrounds = 0
	var cafeterias = 0
	for i in range(size):
		map.append([])
		for j in range(size):
			# Rooms are populated on the edges of the map like Monopoly
			if (i == 0 or i == (size-1) or j == 0 or j == (size-1)):
				var random_num = rand.randi_range(0, 3)
				# Balance the number of cafeterias and playground, since these spaces are very advantageous
				if (random_num == CAFETERIA):
					cafeterias += 1
				elif (random_num == PLAYGROUND):
					playgrounds += 1
				if (cafeterias == 5 or playgrounds == 5):
					random_num = rand.randi_range(0, 1)
				var object = rooms[random_num]
				map[i].append(object.instance())
			# A patch of grass will represent the middle of the map
			else:
				map[i].append(rooms[4].instance())
	return map
	
func set_room_positions(map):
	for i in range(len(map)):
		for j in range(len(map[0])):
			map[i][j].position = Vector2(i * 192, j * 192)
			add_child(map[i][j])
	return 0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if state == PLAYERTURN:
		if Input.is_action_just_pressed("RollDice"):
			var steps = rand.randi_range(1, 6)
			label.text = "You rolled a " + String(steps)
			state = PLAYERMOVE
			yield(get_tree().create_timer(1.0), "timeout")
			label.text = ""
			move_player(steps)
			state = PLAYERTURN
	pass

func move_player(steps):
	if steps == 0:
		return
	var current_position = pawn.position
	var map_position = [pawn.position.x/192, pawn.position.y/192]
	print(compare_arrays(map_position, CORNERS.TOPLEFT))
	if compare_arrays(map_position, CORNERS.TOPLEFT):
		direction = GORIGHT
	elif compare_arrays(map_position, CORNERS.TOPRIGHT):
		direction = GODOWN
	elif compare_arrays(map_position, CORNERS.BOTRIGHT):
		direction = GOLEFT
	elif compare_arrays(map_position, CORNERS.BOTLEFT):
		direction = GOUP
		
	if direction == GORIGHT:
		pawn.position.x = pawn.position.x + 192
		character.position.x = character.position.x + 192
	elif direction == GODOWN:
		pawn.position.y = pawn.position.y + 192
		character.position.y = character.position.y + 192
	elif direction == GOLEFT:
		pawn.position.x = pawn.position.x - 192
		character.position.x = character.position.x - 192
	elif direction == GOUP:
		pawn.position.y = pawn.position.y - 192
		character.position.y = character.position.y - 192
	yield(get_tree().create_timer(.5), "timeout")
	move_player(steps - 1)	
	
	

func compare_arrays(array1, array2):
	if array1.size() != array2.size():
		return false
	for i in range(array1.size()):
		if array1[i] != array2[i]:
			return false
	return true
