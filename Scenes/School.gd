extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var rand = RandomNumberGenerator.new()
enum {CLASSROOM, HALLWAY, CAFETERIA, PLAYGROUND, GARDEN}
onready var player_hp = get_node("CanvasLayer/Prompt/Stats/PlayerInfo/HP")
onready var player_int = get_node("CanvasLayer/Prompt/Stats/PlayerInfo/INT")
onready var player_str = get_node("CanvasLayer/Prompt/Stats/PlayerInfo/STR")
onready var enemy_hp = get_node("CanvasLayer/Prompt/Stats/EnemyInfo/HP")
onready var enemy_int = get_node("CanvasLayer/Prompt/Stats/EnemyInfo/INT")
onready var enemy_str = get_node("CanvasLayer/Prompt/Stats/EnemyInfo/STR")
onready var actors = [get_node("CharacterOffset"), get_node("Character"), get_node("EnemyOffset"), get_node("Enemy")]
onready var label = get_node("CanvasLayer/Prompt/VBoxContainer/Label")
enum {PLAYERTURN, PLAYERMOVE, PLAYERPROCESS, ENEMYTURN, ENEMYMOVE, ENEMYPROCESS, ROUNDEND}
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
	player_hp.set_text("5")
	enemy_hp.set_text("5")
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
	# Process player turn
	# Player rolls dice and move num on dice
	# Switches to enemy turn when done
	if state == PLAYERTURN:
		if Input.is_action_just_pressed("RollDice"):
			var steps = rand.randi_range(1, 6)
			label.text = "You rolled a " + String(steps)
			state = PLAYERMOVE
			yield(get_tree().create_timer(1.0), "timeout")
			label.text = ""
			move_actor(steps, actors, true)
#			state = ENEMYTURN
	if state == ENEMYTURN:
		var steps = rand.randi_range(1, 6)
		label.text = "Enemy rolled a " + String(steps)
		state = ENEMYMOVE
		yield(get_tree().create_timer(1.0), "timeout")
		label.text = ""
		move_actor(steps, actors, false)
#		state = ROUNDEND
#		state = PLAYERTURN
#	yield(get_tree().create_timer(1.0), "timeout")
	
#	if state == ROUNDEND:
#		end_of_round()
#		state = PLAYERTURN
	

func move_actor(steps, actors, is_player):
	var actor_indices = []
	var offset = actors[0]
	var character = actors[1]
	if is_player:
		state = PLAYERMOVE
		offset = actors[0]
		character = actors[1]
		actor_indices = [0, 1]
	else:
		state = ENEMYMOVE
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
				move_one_step(actors, actor_indices, -1, 0)
			GOUP:
				move_one_step(actors, actor_indices, 0, -1)
		yield(get_tree().create_timer(.5), "timeout")
	position_on_map = [offset.position.x/192, offset.position.y/192]
	process_space(actors, is_player,  actor_indices, indices[position_on_map[0]][position_on_map[1]])
#	yield(get_tree().create_timer(1.0), "timeout")
	yield(get_tree().create_timer(3.0), "timeout")
	if is_player:
		state = ENEMYTURN
	else:
		state = PLAYERTURN


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
	var offset = indices[0]
	var actual = indices[1]
	actors[offset].position.x += x * 192
	actors[offset].position.y += y * 192
	actors[actual].position.x += x * 192
	actors[actual].position.y += y * 192


func process_space(actors, is_player, indices, current_room):
	var offset = actors[indices[0]]
	var actor = actors[indices[1]]
	var other_offset = actors[indices[0]]
	var actor_name = ""
	if is_player:
		actor_name = "Player"
	else:
		actor_name = "Enemy"
	print(current_room)
	match current_room:
		CLASSROOM:
			print("in classroom")
			actor.intelligence += 1
			label.text = actor_name + " attended class for an hour"
			yield(get_tree().create_timer(1.5), "timeout")
			label.text = actor_name + " gained +1 intelligence!"
			if is_player:
				player_int.set_text(str(actor.intelligence))
			else:
				enemy_int.set_text(str(actor.intelligence))
		HALLWAY:
			print("in hallway")
			label.text = "Just in the hallway right now"
			yield(get_tree().create_timer(1.5), "timeout")
			label.text = "Nothing too important really happens"
		CAFETERIA:
			print("in cafeteria")
			actor.health += 1
			label.text = "The school food filled " + actor_name + " up"
			yield(get_tree().create_timer(1.5), "timeout")
			label.text = actor_name + " gained +1 health!"
			if is_player:
				player_int.set_text(str(actor.intelligence))
			else:
				enemy_int.set_text(str(actor.intelligence))
		PLAYGROUND:
			print("in playground")
			actor.strength += 1 
			label.text = actor_name + " worked out on the monkeybars"
			yield(get_tree().create_timer(1.5), "timeout")
			label.text = actor_name + " gained +1 strength!"
			if is_player:
				player_int.set_text(str(actor.strength))
			else:
				enemy_int.set_text(str(actor.intelligence))
			

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
