extends CharacterBody3D

@export var doGravityIncrease: bool 
@export var jumpVelocityFalloff:Curve
@export var wallJumpVelocityFalloff:Curve

var velMngr: VelocityManager = VelocityManager.new()

# gravity stuff
const realGravity:Vector3 = Vector3(0,-9.81,0)
var gravity: Vector3 = realGravity
var gravityIncrease: float = 7
var gravityMax: float = -15

# basic movement
var moveSpeed: float = 12
var maxJumps: int = 2
var jumpTracker: int = 0
var jumpVector: Vector3 = Vector3(0,16,0)
var wallJumpVector: Vector3 = Vector3(0,32,0)
var direction:Vector3 = Vector3(0,0,0)
var input_dir:Vector2
var wallrungravity: Vector3 = Vector3(0,-1,0)
var wallVector: Vector3 # used for walljumps (normal of all walls you touch)
var wallJumpStrength: float = 6
func move(delta: float):
	basic_movement()
	jump()
	velocity = velMngr.getTotalVelocity(delta)
	
	# gravity increase implementation
	if doGravityIncrease:
		if velocity.y > 0 or is_on_floor():
			velMngr.updateVelocity("gravity", gravity)
		else:
			var gravityVel = velMngr.getVelocity("gravity")._direction
			if gravityVel.y - gravityIncrease * delta > gravityMax:
				gravityVel.y -= gravityIncrease * delta
			velMngr.updateVelocity("gravity", gravityVel)
		if is_on_wall() and velocity.y < wallrungravity.y:
			velocity.y = wallrungravity.y
	
	# make the walljump workable
	
	
	move_and_slide()
	
	# calculate the wallVector
	if is_on_wall():
		wallVector = Vector3(0,0,0)
		for i in range(get_slide_collision_count()):
			var collision = get_slide_collision(i)
			if collision.get_normal().dot(Vector3.UP) < 0.1: # wall (not floor or ceiling)
				wallVector += collision.get_normal()
		
		wallVector = wallVector.normalized()
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
		velMngr.killVelocity("walljump")
	
	# kill the infinit walljump velocity when needed. base condition + jump (can be expanded later)
	var inputVelocity
	if velMngr.hasVelocity("input"):
		inputVelocity = velMngr.getVelocity("input")
	if (is_on_wall() and inputVelocity != null and inputVelocity._direction == Vector3(0,0,0)) or Input.is_action_just_pressed("space"):
		velMngr.killVelocity("walljump")
	
	if Input.is_action_just_pressed("space"):
		if is_on_wall():
			velMngr.addCurveVelocity(wallVector*wallJumpStrength, wallJumpVelocityFalloff, 0.6, "walljump")
			
			if velMngr.hasVelocity("input") and false:
				var oldVel: Velocity = velMngr.getVelocity("input")
				oldVel._direction /= 2
				velMngr.updateVelocity("input", oldVel)
			
			# reset jumps
			jumpTracker = 0
		else:
			# return if you lack normal jumps
			if jumpTracker >= maxJumps:
				return
			
			# decrease normal jumps
			jumpTracker += 1
		
		# you need a jump even when walljumping
		velMngr.updateVelocity("gravity", gravity) #reset maybe too high gravity
		
		if velMngr.hasVelocity("jump"):
			var oldVel: Velocity = velMngr.getVelocity("jump")
			oldVel._direction = jumpVector
			velMngr.updateVelocity("jump", oldVel)
		else:
			velMngr.addCurveVelocity(jumpVector,jumpVelocityFalloff,1, "jump")

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
	#Engine.time_scale = 0.1
	
	handle_mouse_look()
	
	#velocity visualizer in text form
	var type0:Array[Velocity] = []
	var type1:Array[Velocity] = []
	var velocities = velMngr.getAllVelocities()
	for id in velocities:
		if velocities[id]._type == 0:
			type0.append(velocities[id])
		else:
			type1.append(velocities[id])
	if not type0.is_empty():
		label.text = "TYPE 0:\n"
		for vel in type0:
			label.text += " " + str(vel) + "\n"
	if not type1.is_empty():
		label.text += "TYPE 1:\n"
		for vel in type1:
			label.text += " " + str(vel) + "\n"
