extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var rand = RandomNumberGenerator.new()
enum {CLASSROOM, HALLWAY, CAFETERIA, PLAYGROUND, GARDEN}
onready var actors = [get_node("CharacterOffset"), get_node("Character"), get_node("EnemyOffset"), get_node("Enemy")]
onready var label = get_node("CanvasLayer/Prompt/VBoxContainer/Label")
enum {PLAYERTURN, PLAYERMOVE, ENEMYTURN, ENEMYMOVE, ROUNDEND}
enum {GOLEFT, GORIGHT, GOUP, GODOWN} 
enum {MORE_INT, MORE_STR, MORE_HP, DOUBLE_STR, MORE_MAX_HP, HALF_NEXT_DAMG}
const CORNERS = {TOPLEFT=[0, 0], TOPRIGHT=[9,0], BOTLEFT=[0,9], BOTRIGHT=[9,9]}
var state = PLAYERTURN
var map = []
var indices = []
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
		indices.append([])
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
				indices[i].append(random_num) # indices array is used to keep track of what room is at that specific board space
			# A patch of grass will represent the middle of the map
			else:
				map[i].append(rooms[4].instance())
				indices[i].append(4)
	return map
	
func set_room_positions(map):
	for i in range(len(map)):
		for j in range(len(map[0])):
			map[i][j].position = Vector2(i * 192, j * 192)
			add_child(map[i][j])
	return 0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if state == PLAYERTURN and state != ENEMYMOVE:
		if Input.is_action_just_pressed("RollDice"):
			var steps = rand.randi_range(1, 6)
			label.text = "You rolled a " + String(steps)
			state = PLAYERMOVE
			yield(get_tree().create_timer(1.0), "timeout")
			label.text = ""
			move_actor(steps, actors, true)
			state = ENEMYTURN
	if state == ENEMYTURN and state != PLAYERMOVE:
		var steps = rand.randi_range(1, 6)
		label.text = "Enemy rolled a " + String(steps)
		state = ENEMYMOVE
		yield(get_tree().create_timer(1.0), "timeout")
		label.text = ""
		move_actor(steps, actors, false)
#		state = ROUNDEND
		state = PLAYERTURN
	yield(get_tree().create_timer(1.0), "timeout")
	
#	if state == ROUNDEND:
#		end_of_round()
#		state = PLAYERTURN
	

func move_actor(steps, actors, is_player):
	var actor_indices = []
	var offset = actors[0]
	var character = actors[1]
	if is_player:
		offset = actors[0]
		character = actors[1]
		actor_indices = [0, 1]
	else:
		offset = actors[2]
		character = actors[3]
		actor_indices = [2, 3]
	var position_on_map = []
	for i in steps:
		position_on_map = [offset.position.x/192, offset.position.y/192]
		var direction = determine_direction(position_on_map, character.direction)
		character.direction = direction
		match direction:
			GORIGHT:
				move_one_step(actors, actor_indices, 1, 0)
			GODOWN:
				move_one_step(actors, actor_indices, 0, 1)
			GOLEFT:
				move_one_step(actors,actor_indices, -1, 0)
			GOUP:
				move_one_step(actors, actor_indices, 0, -1)
		yield(get_tree().create_timer(.5), "timeout")
	process_space(actors, actor_indices, indices[position_on_map[0]][position_on_map[1]])


func determine_direction(map_position, current_direction):
	var direction = current_direction
	if compare_arrays(map_position, CORNERS.TOPLEFT):
		direction = GORIGHT
	elif compare_arrays(map_position, CORNERS.TOPRIGHT):
		direction = GODOWN
	elif compare_arrays(map_position, CORNERS.BOTRIGHT):
		direction = GOLEFT
	elif compare_arrays(map_position, CORNERS.BOTLEFT):
		direction = GOUP
	return direction

func move_one_step(actors, indices, x, y):
	actors[indices[0]].position.x += x * 192
	actors[indices[1]].position.x += x * 192
	actors[indices[0]].position.y += y * 192
	actors[indices[1]].position.y += y * 192


func process_space(actors, indices, current_room):
	var offset = actors[indices[0]]
	var actor = actors[indices[1]]
	var other_offset = actors[indices[0]]
	match current_room:
		CLASSROOM:
			print("in classroom")
			actor.intelligence += 1
			label.text = "You attended class for an hour"
			yield(get_tree().create_timer(1.5), "timeout")
			label.text = "You gained +1 intelligence!"
		HALLWAY:
			print("in hallway")
		CAFETERIA:
			print("in cafeteria")
			actor.health += 1
			label.text = "The school food filled you up"
			yield(get_tree().create_timer(1.5), "timeout")
			label.text = "You gained +1 health!"
		PLAYGROUND:
			print("in playground")
			label.text = "You worked out on the monkeybars"
			yield(get_tree().create_timer(1.5), "timeout")
			label.text = "You gained +1 strength!"
			actor.strength += 1
			

func end_of_round():
	set_options()
	
func set_options():
	var options = get_node("CanvasLayer/Prompt/Options")
	options.set_visible(true)
	var options_list = []
	var response_list = []
#	var option1 = options.get_child(0)
#	var option2 = options.get_child(1)
#	var option3 = options.get_child(2)
	for i in range(3):
		options_list.append(options.get_child(i))
		var response = rand.randi_range(0, 5)
		response_list.append(response)
		set_response(options_list, i, response)


func set_response(list, index, response):
	var option = list[index]
	match response:
		MORE_INT:
			option.text = "+5 Intelligence"
		MORE_STR:
			option.text = "+5 Strength"
		MORE_HP:
			option.text = "+5 HP"
		DOUBLE_STR:
			option.text = "2x Strength"
		MORE_MAX_HP:
			option.text = "+5 Max HP"
		HALF_NEXT_DAMG:
			option.text = "Half next damage"
		

func game_over(condition):
	match condition:
		CLASSROOM:
			print("Player graduated! Congratulations!")
		CAFETERIA:
			print("Bullies forced player to drop out!")
		PLAYGROUND:
			print("Player has conquered high school!")
	yield(get_tree().create_timer(1.5), "timeout")
	get_tree().quit()

func compare_arrays(array1, array2):
	if array1.size() != array2.size():
		return false
	for i in range(array1.size()):
		if array1[i] != array2[i]:
			return false
	return true
