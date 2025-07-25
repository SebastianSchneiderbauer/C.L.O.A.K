extends CharacterBody3D

@export_group("Velocity Curves")
@export var jumpVelocityFalloff:Curve

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
var wallJumpTimer: float = 0 
var wallJumpTimerMax: float = 0.5
var direction:Vector3 = Vector3(0,0,0)
var input_dir:Vector2
var wallrungravity: Vector3 = Vector3(0,-1,0)
var wallVector: Vector3 # used for walljumps (normal of all walls you touch)
var wallJumpStrength: float = 6
func move(delta: float):
	basic_movement(delta)
	jump()
	velocity = velMngr.getTotalVelocity(delta)
	
	move_and_slide()
	
	# calculate the wallVector
	if is_on_wall():
		wallVector = Vector3(0,0,0)
		for i in range(get_slide_collision_count()):
			var collision = get_slide_collision(i)
			if collision.get_normal().dot(Vector3.UP) < 0.1: # wall (not floor or ceiling)
				wallVector += collision.get_normal()
		
		wallVector = wallVector.normalized()
	elif is_on_floor():
		wallVector = Vector3(0,0,0)
func basic_movement(delta: float):
	input_dir = Input.get_vector("a", "d", "w", "s")
	direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	var inputVel: Vector3 = Vector3.ZERO
	
	if direction != Vector3.ZERO:
		inputVel.x = direction.x * moveSpeed
		inputVel.z = direction.z * moveSpeed
		
		# fix walljump
		wallJumpTimer += delta
		if velMngr.hasVelocity("walljump") and wallJumpTimer < wallJumpTimerMax:
			var toward_wall_amount := inputVel.dot(wallVector)
			if toward_wall_amount < 0.0:
				inputVel -= wallVector * toward_wall_amount
	
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
	if (is_on_wall() and inputVelocity != null and inputVelocity._direction == Vector3(0,0,0)): #or Input.is_action_just_pressed("space"):
		velMngr.killVelocity("walljump")
	
	if Input.is_action_just_pressed("space"):
		if is_on_wall():
			wallJumpTimer = 0
			
			velMngr.addConstantVelocity(wallVector*wallJumpStrength, "walljump")
			
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
	#set VSYNC mode
	DisplayServer.window_set_vsync_mode(0)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	velMngr.addConstantVelocity(gravity, "gravity")

@export_group("AverageFPS")
@export var calculateAverageFPS: bool
@export var fpsAverageRange: int # frames, not the time
@onready var fpsRingBuffer: RingBuffer = RingBuffer.new(fpsAverageRange)
func setDebugLabel(delta):
	# add fps counter
	var fps = round(1/delta)
	label.text = "-FPS: "+str(fps)
	fpsRingBuffer.add(fps)
	
	if calculateAverageFPS:
		# calculate the average fps from the ringbuffer
		var fpsRange = fpsRingBuffer.getAll()
		var fpsAverage := 0.0
		var validEntries = 0
		for pastFPS in fpsRange:
			fpsAverage += pastFPS
			if pastFPS != 0:
				validEntries += 1
		fpsAverage /= validEntries
		label.text += " | " + str(fpsAverage) + " | " + str(validEntries) + " / " + str(fpsAverageRange) + "\n"
	else:
		label.text += "\n"
	
	# velocity visualizer in text form
	var type0:Array[Velocity] = []
	var type1:Array[Velocity] = []
	var velocities = velMngr.getAllVelocities()
	for id in velocities:
		if velocities[id]._type == 0:
			type0.append(velocities[id])
		else:
			type1.append(velocities[id])
	if not type0.is_empty():
		label.text += "-TYPE 0:\n"
		for vel in type0:
			label.text += " " + str(vel) + "\n"
	if not type1.is_empty():
		label.text += "-TYPE 1:\n"
		for vel in type1:
			label.text += " " + str(vel) + "\n"
func _process(delta):
	handle_mouse_look()
	setDebugLabel(delta)
func _physics_process(delta):
	move(delta)
