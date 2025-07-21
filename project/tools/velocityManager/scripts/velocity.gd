class_name Velocity
extends RefCounted

var _direction: Vector3
var _oriDirection: Vector3
var _directionMin: Vector3 #used as the lower limit when decreasing
var _type: int #0 = constant, 1 following a curve, 2 constant decrease
var _decreaseCurve: Curve
var _decreaseTime: float
var _decreaseCounter: float = 0
var _id: String #easier work for programmers instead of it being a number

func _init(direction: Vector3, type: int, decrease, duration: float, id: String):
	_direction = direction
	_oriDirection = direction
	_directionMin = _direction * 0.01 # 1% of the original is seen as the limit to save compute time
	_type = type
	
	_decreaseTime = duration
	if _type == 1:
		_decreaseCurve = decrease
	
	_id = id

func decrease(delta:float):
	if _type == 0:
		_decreaseCounter += delta
		if _decreaseCounter > _decreaseTime:
			_direction = Vector3.ZERO
	else:
		_decreaseCounter += delta
		var lookupValue = _decreaseCounter/_decreaseTime # for velocitys that end with non zero values, like a walljump
		if lookupValue > 1:
			lookupValue = 1
		_direction = _decreaseCurve.sample(lookupValue) * _oriDirection

func _to_string():
	return  _id + ": "+ str(_direction)
