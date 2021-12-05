extends Camera2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var speed = 50000
const zoom_val = Vector2(.1, .1)
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if get_zoom() <= zoom_val:
		speed = 10000
	else:
		speed = 30000
	if Input.is_action_just_pressed("Up"):
		if global_position.y > 0:
			global_position += Vector2.UP * delta * speed
	elif Input.is_action_just_pressed("Down"):
		if global_position.y < 2000:
			global_position += Vector2.DOWN * delta * speed
	elif Input.is_action_just_pressed("Left"):
		if global_position.x > 0:
			global_position += Vector2.LEFT * delta * speed
	elif Input.is_action_just_pressed("Right"):
		if global_position.x < 2000:
			global_position += Vector2.RIGHT * delta * speed
	elif Input.is_action_just_released("ZoomIn"):
		set_zoom(get_zoom() - zoom_val)
	elif Input.is_action_just_released("ZoomOut"):
		set_zoom(get_zoom() + zoom_val)
