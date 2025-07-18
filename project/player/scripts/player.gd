extends CharacterBody3D

var velMngr: VelocityManager = VelocityManager.new()

#gravity stuff
const realGravity:Vector3 = Vector3(0,-9.81,0)
var gravity: Vector3 = realGravity
var gravityIncrease: float = 7
var gravityMax: float = -15

#basic movement
var moveSpeed: float = 12
var maxJumps: int = 2
var jumpTracker: int = 0
var jumpVector: Vector3 = Vector3(0,16,0)
var direction:Vector3 = Vector3(0,0,0)
var input_dir:Vector2
var wallrungravity: Vector3 = Vector3(0,-1,0)
func move(delta: float):
	basic_movement()
	jump()
	velocity = velMngr.getTotalVelocity(delta)
	
	#gravity increase implementation
	if velocity.y > 0 or is_on_floor():
		velMngr.updateVelocity("gravity", gravity)
	else:
		var gravityVel = velMngr.getVelocity("gravity")._direction
		if gravityVel.y - gravityIncrease * delta > gravityMax:
			gravityVel.y -= gravityIncrease * delta
		velMngr.updateVelocity("gravity", gravityVel)
	if is_on_wall() and velocity.y < wallrungravity.y:
		velocity.y = wallrungravity.y
	
	move_and_slide()
func basic_movement():
	input_dir = Input.get_vector("a", "d", "w", "s")
	direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	var inputVel: Vector3 = Vector3.ZERO
	
	if direction != Vector3.ZERO:
		inputVel.x = direction.x * moveSpeed
		inputVel.z = direction.z * moveSpeed
	
	if velMngr.hasVelocity("input"):
		var oldVel: Velocity = velMngr.getVelocity("input")
		oldVel._direction = inputVel
		velMngr.updateVelocity("input", oldVel)
	else:
		velMngr.addConstantVelocity(inputVel, "input")
func jump():
	if is_on_floor():
		jumpTracker = 0
	
	if Input.is_action_just_pressed("space") and jumpTracker < maxJumps:
		jumpTracker += 1
		velMngr.updateVelocity("gravity", gravity) #reset maybe too high gravity
		
		if velMngr.hasVelocity("jump"):
			var oldVel: Velocity = velMngr.getVelocity("jump")
			oldVel._direction = jumpVector
			velMngr.updateVelocity("jump", oldVel)
		else:
			velMngr.addSmoothVelocity(jumpVector, "jump")

#temporary debug
@onready var label = $gravitydebug

#camera
@onready var camera:Camera3D = $camera
var mouse_delta:Vector2 = Vector2.ZERO
var sensitivity:float = 1 # editable from outside, later 😉
func handle_mouse_look():
	var rotation_x = -mouse_delta.y * sensitivity
	var rotation_y = -mouse_delta.x * sensitivity
	camera.rotation_degrees.x = clamp(camera.rotation_degrees.x + rotation_x, -90, 90)
	rotation_degrees.y += rotation_y
	mouse_delta = Vector2.ZERO
func _input(event):
	if event is InputEventMouseMotion:
		mouse_delta = event.relative

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	velMngr.addConstantVelocity(gravity, "gravity")

func _physics_process(delta):
	move(delta)
func _process(delta):
	handle_mouse_look()
	label.text = str(velMngr.getAllVelocities())
