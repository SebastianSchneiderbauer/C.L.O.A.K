class_name Velocity
extends RefCounted

var _direction: Vector3
var _directionMin: Vector3 #used as the lower limit when decreasing
var _type: int #0 = constant, 1 halfed every x seconds, 2 constant decrease
var _decrease: float # how much it decreases per second in total length
var _id: String #easier work for programmers instead of it being a number

func _init(direction: Vector3, type: int, decrease: float, id: String):
	_direction = direction
	_directionMin = _direction * 0.1 # 10% of the original is seen as the limit to save compute time
	_type = type
	_decrease = decrease
	_id = id

func decrease(delta:float):
	if _type == 1: #we ignore type 0 since it just does not decrease
		_direction *= pow(0.5,delta) # halve the direction every second
	elif _type == 2:
		_direction -= _direction.normalized() * _decrease * delta

func _to_string():
	return "direction: " + str(_direction) + " type: " + str(_type)
