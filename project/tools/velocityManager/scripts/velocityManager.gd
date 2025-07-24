class_name VelocityManager

extends RefCounted

var velocities: Dictionary = {}

func getAllVelocities() -> Dictionary:
	return velocities

func getVelocity(id: String) -> Velocity:
	if not velocities.has(id):
		return null
	
	return velocities[id]

func getVelocityVector(id: String) -> Vector3:
	if not velocities.has(id):
		return Vector3(0,0,0)
	
	return velocities[id]._direction

func hasVelocity(id: String) -> bool:
	return velocities.has(id)

func killVelocity(id: String):
	if not velocities.has(id):
		return
	
	velocities.erase(id)

func updateVelocity(id: String, updated): # updated is either a Velocity or Vector
	if not velocities.has(id):
		return
	
	if updated is Velocity:
		velocities[id] = updated
		velocities[id]._decreaseCounter = 0
	elif typeof(updated) == TYPE_VECTOR3:
		velocities[id]._direction = updated
		velocities[id]._decreaseCounter = 0
	elif updated is Curve:
		velocities[id]._decreaseCurve = updated
		velocities[id]._decreaseCounter = 0

#func _init(direction: Vector3, type: int, decrease, duration: float, id: String):
func addConstantVelocity(velocity: Vector3, id: String, duration: float = INF) -> void: #yes the id is forced, just to make it a good habit
	if velocity != Vector3.ZERO:
		var newVelocity: Velocity = Velocity.new(velocity, 0, 0, duration, id)
		velocities[id] = newVelocity

func addCurveVelocity(velocity: Vector3, fallOff:Curve, duration:float, id: String ) -> void: #yes the id is forced, just to make it a good habit
	if velocity != Vector3.ZERO:
		var newVelocity: Velocity = Velocity.new(velocity, 1, fallOff, duration, id)
		velocities[id] = newVelocity

func getTotalVelocity(delta: float) -> Vector3: #this takes deltatime for decrease to work
	if velocities.size() == 0:
		return Vector3.ZERO
	
	var totalVelocity: Vector3 = Vector3.ZERO
	var to_remove: Array[String] = []
	
	for id in velocities:
		var vel = velocities[id]
		totalVelocity += vel._direction
		vel.decrease(delta)
		
		if vel._direction.length() < vel._directionMin.length():
			to_remove.append(id)
	
	for id in to_remove:
		killVelocity(id)
	
	return totalVelocity
