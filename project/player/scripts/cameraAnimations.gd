extends Camera3D

var basePosition
var baseRotation

@onready var player = $".."
var playerVelMngr

@export_category("Lean")
@export var lean_max_deg: float = 2.0
@export var lean_speed: float = 10.0
@export var lean: bool = false

func _ready():
	playerVelMngr = player.velMngr
	basePosition = position
	baseRotation = rotation

func _physics_process(delta):
	var axis := 0.0
	if lean:
		if Input.is_action_pressed("a"):
			axis -= 1.0
		if Input.is_action_pressed("d"):
			axis += 1.0
		
		var target = baseRotation.z + deg_to_rad(axis * lean_max_deg)
		rotation.z = lerp_angle(rotation.z, target, clamp(lean_speed * delta, 0.0, 1.0))
