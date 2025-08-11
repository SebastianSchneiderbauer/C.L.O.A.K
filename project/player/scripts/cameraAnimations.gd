extends Camera3D

var basePosition
var baseRotation
var baseFov

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
	baseFov = fov

func _physics_process(delta):
	position = basePosition
	
	var leanAxis := 0.0
	if lean:
		if Input.is_action_pressed("a"):
			leanAxis -= 1.0
		if Input.is_action_pressed("d"):
			leanAxis += 1.0
		var target = baseRotation.z + deg_to_rad(leanAxis * lean_max_deg)
		rotation.z = lerp_angle(rotation.z, target, clamp(lean_speed * delta, 0.0, 1.0))
	
	if thirdP:
		position += thirdPoffset
	
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
		position.y += bobCurve.sample(bobCounter*bobSpeed) * -pow((player.landingGravity.y)/11,2)
	player.get_child(3).text = str((player.landingGravity.y)/11) + " | " + str(player.landingGravity)
