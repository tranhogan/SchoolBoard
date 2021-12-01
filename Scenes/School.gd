extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	var classroom = preload("res://Prefabs/Classroom.tscn")
	var hallway = preload("res://Prefabs/Hallway.tscn")
	var gym = preload("res://Prefabs/Gym.tscn")
	
	var classrooms = instantiate_classrooms(classroom)
	instantiate_hallways(hallway)
	instantiate_gyms(gym)
	
	for i in range(5):
		add_child(classrooms[i])
		print(classrooms[i].name)
#	add_child(classroom_instance)
#	for i in range(10):
#		add_child(classroom_instance)
#	var children = get_children()
#	var children1 = get_child(0)
#	print(children)
#	print(children[0].name)
#	for i in range(get_child_count()):
#		print(children[i].name)
	#var classroom_node = get_node("classroom_instance")
	#classroom->set_transform(0, 0)
#	pass # Replace with function body.

func instantiate_classrooms(classroom):
	var array = []
	for i in range(5):
		array.append(classroom.instance())
	return array

func instantiate_hallways(hallway):
	return 0

func instantiate_gyms(gym):
	return 0


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
