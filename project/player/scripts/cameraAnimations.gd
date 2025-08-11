extends Camera3D

var basePosition
var baseRotation

@onready var player = $".."
var playerVelMngr

@export_category("Lean")
@export var lean_max_deg: float = 2.0
@export var lean_speed: float = 10.0
@export var lean: bool = false

@export_category("3rd Person")
@export var thirdPoffset = Vector3(0,0,0)
@export var thirdP: bool = false

@export_category("landBob")
@export var bobCurve: Curve
@export var bobSpeed: float = 5
@export var bob: bool = false
var bobCounter = 0
var hitdafloor = false

func _ready():
	playerVelMngr = player.velMngr
	basePosition = position
	baseRotation = rotation

func _physics_process(delta):
	position = basePosition
	
	# lean
	var axis := 0.0
	if lean:
		if Input.is_action_pressed("a"):
			axis -= 1.0
		if Input.is_action_pressed("d"):
			axis += 1.0
		
		var target = baseRotation.z + deg_to_rad(axis * lean_max_deg)
		rotation.z = lerp_angle(rotation.z, target, clamp(lean_speed * delta, 0.0, 1.0))
	
	# 3rd Person
	if thirdP:
		position += thirdPoffset
	
	# landBob, wtf even is this
	if bob:
		if player.is_on_floor() and not hitdafloor:
			hitdafloor = true
			bobCounter = 0
		elif not player.is_on_floor():
			hitdafloor = false
		if bobCounter >= 0:
			bobCounter += delta
			if bobCounter > 1/bobSpeed:
				bobCounter = -1
		position.y -= bobCurve.sample(bobCounter*bobSpeed)
