extends CharacterBody3D

var direction:Vector3 = Vector3(0,0,0)
var input_dir:Vector2
@onready var camera:Camera3D = $camera
var mouse_delta:Vector2 = Vector2.ZERO
var sensitivity:float = 0.1 # editable from outside

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	if event is InputEventMouseMotion:
		mouse_delta = event.relative

func handle_mouse_look(delta:float):
	var rotation_x = -mouse_delta.y * sensitivity# * delta * 100
	var rotation_y = -mouse_delta.x * sensitivity# * delta * 100
	camera.rotation_degrees.x = clamp(camera.rotation_degrees.x + rotation_x, -90, 90)
	rotation_degrees.y += rotation_y
	mouse_delta = Vector2.ZERO

func _physics_process(delta): # "main"
	pass
func _process(delta): # "another main"
	handle_mouse_look(delta)
