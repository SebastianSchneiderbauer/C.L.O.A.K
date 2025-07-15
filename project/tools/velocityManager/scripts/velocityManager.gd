class_name VelocityManager

extends RefCounted

var velocities: Dictionary = {}

func getAllVelocities() -> Dictionary:
	return velocities

func getVelocity(id: String) -> Velocity:
	return velocities[id]

func killVelocity(id: String):
	velocities.erase(id)

func updateVelocity(id: String, updated: Velocity):
	velocities[id] = updated

func addConstantVelocity(velocity: Vector3, id: String ) -> void: #yes the id is forced, just to make it a good habit
	var newVelocity: Velocity = Velocity.new(velocity, 0, 0, id)
	velocities[id] = newVelocity

func addSmoothVelocity(velocity: Vector3, id: String ) -> void: #yes the id is forced, just to make it a good habit
	var newVelocity: Velocity = Velocity.new(velocity, 1, 0, id)
	velocities[id] = newVelocity

func addDecreasingVelocity(velocity: Vector3, decrease: float ,id: String ) -> void: #yes the id is forced, just to make it a good habit
	var newVelocity: Velocity = Velocity.new(velocity, 2, decrease, id)
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
